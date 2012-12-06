# bio-ipcress

```bio-ipcress``` is a programmatic interface to the ```ipcress``` in-silico PCR software, which
is bundled with [exonerate](http://www.ebi.ac.uk/~guy/exonerate/).

You can run a PCR:
```ruby
require 'bio-ipcress'

#hits the first and last bits of the Methanocella_conradii_16s.fa
primer_set = Bio::Ipcress::PrimerSet.new(
  'GGTCACTGCTA','GGCTACCTTGTTACGACTTAAC'
  )

# Run ipcress on a template sequence, specified in as a FASTA file
results = Bio::Ipcress.run(
  primer_set,
  'Methanocella_conradii_16s.fa', #this file is in the test/data/Ipcress directory
  {:min_distance => 2, :max_distance => 10000})
#=> An array of Bio::Ipcress::Result objects, parsed from
#
#Ipcress result
#--------------
# Experiment: AE12_pmid21856836_16S
#    Primers: A B
#     Target: gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence
#    Matches: 19/20 14/15
#    Product: 502 bp (range 2-10000)
#Result type: forward
#
#...AAACTTAAAGGAATTGGCGG......................... # forward
#   ||||| ||| |||||| |||-->
#5'-AAACTYAAAKGAATTGRCGG-3' 3'-CRTGTGTGGCGGGCA-5' # primers
#                           <--| |||||||||||||
#..............................CGTGTGTGGCGGGCA... # revcomp
#--
#ipcress: gi|335929284|gb|JN048683.1|:filter(unmasked) AE12_pmid21856836_16S 502 A 826 1 B 1313 1 forward
#-- completed ipcress analysis"



# This Bio::Ipcress::Result object now holds info about the result:
results.length #=> 1

res = results[0]
res.experiment_name #=> 'AE12_pmid21856836_16S' 
res.primers #=> 'A B' 
res.target #=> 'gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence'
res.matches #=> '19/20 14/15' 
res.product #=> '502 bp (range 2-10000)' 
res.result_type #=> 'forward' 
res.forward_matching_sequence #=> 'AAACTTAAAGGAATTGGCGG' 
res.forward_primer_sequence #=> 'AAACTYAAAKGAATTGRCGG' 
res.reverse_primer_sequence #=> 'CRTGTGTGGCGGGCA' 
res.reverse_matching_sequence #=> 'CGTGTGTGGCGGGCA' 
res.length #=> 502
res.start #=> 826
res.forward_mismatches #=> 1 
res.reverse_mismatches #=> 1
```

There appears to be a slight bug in iPCRess, in the way it handles primers with 'wobble' bases like the
last base of AAACTY,
which indicates that both AAACTC and AAACTT are added as primers.
IPCress always suggests that there is at least a single mismatch,
when this is not always the case. To workaround this, the
```Result#recalculate_mismatches_from_alignments``` method re-computes the 
number of forward and reverse mismatches.

```ruby
#...AAACTTAAAGGAATTGGCGG......................... # forward
#   ||||| ||| |||||| |||-->
#5'-AAACTYAAAKGAATTGRCGG-3' 3'-CRTGTGTGGCGGGCA-5' # primers
#                           <--| |||||||||||||
#..............................CGTGTGTGGCGGGCA... # revcomp
res = Bio::Ipcress::Result.new
res.forward_matching_sequence = 'AAACTTAAAGGAATTGGCGG'
res.forward_primer_sequence = 'AAACTYAAAKGAATTGRCGG'
res.reverse_matching_sequence = 'CGTGTGTGGCGGGCA'
res.reverse_primer_sequence = 'CRTGTGTGGCGGGCA'

res.recalculate_mismatches_from_alignments #=> [0,0]
```

## Installation

```sh
gem install bio-ipcress
```

You'll also need to install [exonerate](http://www.ebi.ac.uk/~guy/exonerate/)
        
## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/wwood/bioruby-ipcress

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

If you use this software, please cite exonerate

## Biogems.info

This Biogem is published at [#bio-ipcress](http://biogems.info/index.html)

## Copyright

Copyright (c) 2012 Ben J Woodcroft. See LICENSE.txt for further details.

