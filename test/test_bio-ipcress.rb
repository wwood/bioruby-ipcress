require 'helper'
require 'stringio'

class TestBioIpcress < Test::Unit::TestCase
  should "test 1 result" do
    ipcress = "
Ipcress result
--------------
 Experiment: AE12_pmid21856836_16S
    Primers: A B
     Target: gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence
    Matches: 19/20 14/15
    Product: 502 bp (range 2-10000)
Result type: forward

...AAACTTAAAGGAATTGGCGG......................... # forward
   ||||| ||| |||||| |||-->
5'-AAACTYAAAKGAATTGRCGG-3' 3'-CRTGTGTGGCGGGCA-5' # primers
                           <--| |||||||||||||
..............................CGTGTGTGGCGGGCA... # revcomp
--
ipcress: gi|335929284|gb|JN048683.1|:filter(unmasked) AE12_pmid21856836_16S 502 A 826 1 B 1313 1 forward
-- completed ipcress analysis"
    results = Bio::Ipcress.parse(ipcress)
    assert_equal 1, results.length
    res = results[0]
    assert_equal 'AE12_pmid21856836_16S', res.experiment_name
    assert_equal 'A B', res.primers
    assert_equal 'gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence',
      res.target
    assert_equal '19/20 14/15', res.matches
    assert_equal '502 bp (range 2-10000)', res.product
    assert_equal 'forward', res.result_type
    assert_equal 'AAACTTAAAGGAATTGGCGG', res.forward_matching_sequence
    assert_equal 'AAACTYAAAKGAATTGRCGG', res.forward_primer_sequence
    assert_equal 'CRTGTGTGGCGGGCA', res.reverse_primer_sequence
    assert_equal 'CGTGTGTGGCGGGCA', res.reverse_matching_sequence
    assert_equal 502, res.length
    assert_equal 826, res.start
    assert_equal 1, res.forward_mismatches
    assert_equal 1, res.reverse_mismatches
  end
  
  should "test multi-experiment results" do
    ipcress = "
Ipcress result
--------------
 Experiment: AE12_pmid21856836_16S
    Primers: B B
     Target: gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence
    Matches: 10/15 14/15
    Product: 1085 bp (range 2-10000)
Result type: single_B

...ACGGGTTGTGGGAGC......................... # forward
   |||||  ||| |  |-->
5'-ACGGGCGGTGTGTRC-3' 3'-CRTGTGTGGCGGGCA-5' # primers
                      <--| |||||||||||||
.........................CGTGTGTGGCGGGCA... # revcomp
--
ipcress: gi|335929284|gb|JN048683.1|:filter(unmasked) AE12_pmid21856836_16S 1085 B 243 5 B 1313 1 single_B

Ipcress result
--------------
 Experiment: AE12_pmid21856836_16S
    Primers: A B
     Target: gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence
    Matches: 16/21 14/15
    Product: 503 bp (range 2-10000)
Result type: forward

...GAAACTTAAAGGAATTGGCGG......................... # forward
    ||    ||| |||||| |||-->
5'-AAACTYAAAAKGAATTGRCGG-3' 3'-CRTGTGTGGCGGGCA-5' # primers
                            <--| |||||||||||||
...............................CGTGTGTGGCGGGCA... # revcomp
--
ipcress: gi|335929284|gb|JN048683.1|:filter(unmasked) AE12_pmid21856836_16S 503 A 825 5 B 1313 1 forward

Ipcress result
--------------
 Experiment: AE12_pmid21856836_16S
    Primers: B B
     Target: gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence
    Matches: 10/15 14/15
    Product: 470 bp (range 2-10000)
Result type: single_B

...ACGGGTGGAGCCTGC......................... # forward
   ||||| || |  | |-->
5'-ACGGGCGGTGTGTRC-3' 3'-CRTGTGTGGCGGGCA-5' # primers
                      <--| |||||||||||||
.........................CGTGTGTGGCGGGCA... # revcomp
--
ipcress: gi|335929284|gb|JN048683.1|:filter(unmasked) AE12_pmid21856836_16S 470 B 858 5 B 1313 1 single_B
-- completed ipcress analysis
"
    results = Bio::Ipcress.parse(ipcress)
    assert_equal 3, results.length
    assert_equal 5, results[0].forward_mismatches
  end
  
  should "test recalculation of matches" do
    res = Bio::Ipcress::Result.new
    
    #...AAACTTAAAGGAATTGGCGG......................... # forward
    #   ||||| ||| |||||| |||-->
    #5'-AAACTYAAAKGAATTGRCGG-3' 3'-CRTGTGTGGCGGGCA-5' # primers
    #                           <--| |||||||||||||
    #..............................CGTGTGTGGCGGGCA... # revcomp
    res.forward_matching_sequence = 'AAACTTAAAGGAATTGGCGG'
    res.forward_primer_sequence = 'AAACTYAAAKGAATTGRCGG'
    res.reverse_matching_sequence = 'CGTGTGTGGCGGGCA'
    res.reverse_primer_sequence = 'CRTGTGTGGCGGGCA'
    assert_equal [0,0], res.recalculate_mismatches_from_alignments
    
    res.reverse_primer_sequence = 'CRTGTGTGGCGGGCT'
    assert_equal [0,1], res.recalculate_mismatches_from_alignments
    
    
    res.forward_primer_sequence = 'AAACTRAAAKGAATTGRCGG'
    res.reverse_primer_sequence = 'CRTGTGTGGCGGGCA'
    assert_equal [1,0], res.recalculate_mismatches_from_alignments, "mismatching wobble R"
  end
end
