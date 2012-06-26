require 'bio'
require 'tempfile'

module Bio
  class Ipcress
    # A full Ipcress result looks something like this. Parse it into an array of Ipcress::Result objects
    #
    # ** Message: Loaded [1] experiments
    # 
    # Ipcress result
    # --------------
    #  Experiment: AE12_pmid21856836_16S
    #     Primers: A B
    #      Target: gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence
    #     Matches: 19/20 14/15
    #     Product: 502 bp (range 2-10000)
    # Result type: forward
    # 
    # ...AAACTTAAAGGAATTGGCGG......................... # forward
    #    ||||| ||| |||||| |||-->
    # 5'-AAACTYAAAKGAATTGRCGG-3' 3'-CRTGTGTGGCGGGCA-5' # primers
    #                            <--| |||||||||||||
    # ..............................CGTGTGTGGCGGGCA... # revcomp
    # --
    # ipcress: gi|335929284|gb|JN048683.1|:filter(unmasked) AE12_pmid21856836_16S 502 A 826 1 B 1313 1 forward
    # -- completed ipcress analysis
    def self.parse(ipcress_output_string)
      results = Results.new
      
      ipcress_output_string.split(/\nIpcress result\n--------------\n/m).each_with_index do |result_chunk, index|
        next if index == 0 # ignore the first chunk since that isn't a result
        
        lines = result_chunk.split("\n").collect{|l| l.strip}
        
        result = Result.new
        i=0
        result.experiment_name  = lines[i].match(/^Experiment: (.+)$/)[1]; i+=1
        result.primers     = lines[i].match(/^Primers: (.+)$/)[1]; i+=1
        result.target      = lines[i].match(/^Target: (.+)$/)[1]; i+=1
        result.matches     = lines[i].match(/^Matches: (.+)$/)[1]; i+=1
        result.product     = lines[i].match(/^Product: (.+)$/)[1]; i+=1
        result.result_type = lines[i].match(/^Result type: (.+)$/)[1]
        
        i+= 2
        result.forward_matching_sequence = lines[i].match(/^\.\.\.(\w+)\.+ \# forward$/)[1]
        i+= 2
        matching = lines[i].match(/^5'\-(\w+)-3' 3'\-(\w+)-5' \# primers$/)
        result.forward_primer_sequence = matching[1]
        result.reverse_primer_sequence = matching[2]
        i+= 2
        result.reverse_matching_sequence = lines[i].match(/^\.+(\w+)\.\.\. \# revcomp$/)[1]
        
        i+= 2
        matching = lines[i].match(/^ipcress: (\S+) (\S+) (\d+) [AB] (\d+) (\d+) [AB] (\d+) (\d+) (\S+)$/)
        result.length = matching[3].to_i
        result.start = matching[4].to_i
        result.forward_mismatches = matching[5].to_i
        result.reverse_mismatches = matching[7].to_i
        
        results.push result
      end
      return results
    end
    
    # Run ipcress
    #
    # * primer_set: a PrimerSet object with defined forward and reverse primers
    # * fasta_file: a String path to a fasta file that will be used as template
    # * options hash: contains less-used parameters
    # ** :min_distance: the minimum length of product to be amplified (default 100)
    # ** :max_distance: the maxmimum length of product to be amplified (default 1000)
    # ** :ipcress_path: path the ipcress executable (default 'ipcress')
    # ** :mismatches: number of mismatches allowable (-m parameter to ipcress binary, default 0)
    #
    # Return an array of parsed Result objects
    def self.run(primer_set, fasta_file, options={})
      raise unless primer_set.kind_of?(PrimerSet)
      raise unless fasta_file.kind_of?(String)
      options[:ipcress_path] ||= 'ipcress'
      
      Tempfile.open('ipcress') do |tempfile|
        # Write a tempfile that contains the primer set to be queried
        primers = primer_set.to_ipcress_format(options)
        tempfile.puts primers
        tempfile.close
        
        command = [
          options[:ipcress_path],
        ]
        if options[:mismatches]
          command.push '-m'
          command.push options[:mismatches].to_s
        end
        command.push tempfile.path
        command.push fasta_file

        Bio::Command.call_command_open3(command) do |stdin, stdout, stderr|
          out = stdout.read
          raise stderr.read if out == '' #if there is a problem running ipcress e.g. the fasta file isn't found
          
          return parse(out)
        end
      end
    end
    
    # A class to represent a pair of primers that will be used by Ipcress
    # to amplify from template DNA in-silico
    class PrimerSet
      attr_accessor :forward_primer, :reverse_primer
      
      def initialize(forward_primer, reverse_primer)
        @forward_primer = forward_primer
        @reverse_primer = reverse_primer
      end
      
      # To a string in the "ipcress file" format required for ipcress usage
      def to_ipcress_format(options={})
        options ||= {}
        options[:min_distance] ||= 100
        options[:max_distance] ||= 1000
        "ID1 #{@forward_primer} #{@reverse_primer} #{options[:min_distance]} #{options[:max_distance]}"
      end
    end

    # A collection of Ipcress Result objects for a given run
    class Results < Array
    end
    
    # Ipcress single result (single primer pair match)
    #
    # Attributes of this class should be largely obvious by inspecting the Ipcress output
    class Result
      attr_accessor :experiment_name
      
      attr_accessor :primers, :target, :matches, :product, :result_type
      
      # A String representing the matching part of the sequence
      attr_accessor :forward_matching_sequence
      
      # A String representing the matching primer
      attr_accessor :forward_primer_sequence
      
      # A String representing the matching primer
      attr_accessor :reverse_primer_sequence
      
      # A String representing the matching part of the sequence
      attr_accessor :reverse_matching_sequence
      
      attr_accessor :length, :forward_mismatches, :start, :reverse_mismatches
      
      # When there are wobbles in the primers, Ipcress always reports at
      # least 1 mismatch (1 for all matching wobbles plus regular mismatches).
      #
      # This method recalculates the mismatches by re-aligning the primers
      # against the sequences that they hit in this Result.
      #
      # Returns an array of 2 values corresponding to the number of mismatches
      # in the forward and revcomp primers, respectively.
      #
      # Assumes that there is only wobbles in the primers, not the sequence
      # (Does ipcress itself assume this?)
      def recalculate_mismatches_from_alignments
        calculate_mismatches = lambda do |seq, primer|
          mismatches = 0
          (0..(seq.length-1)).each do |position|
            regex = Bio::Sequence::NA.new(primer[position].downcase).to_re
            seqp = seq[position].downcase
            mismatches += 1 unless regex.match(seqp)
          end
          mismatches
        end
        
        return [
          calculate_mismatches.call(@forward_matching_sequence, @forward_primer_sequence),
          calculate_mismatches.call(@reverse_matching_sequence, @reverse_primer_sequence)
        ]
      end
    end
  end
end
