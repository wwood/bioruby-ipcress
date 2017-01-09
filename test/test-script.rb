require 'helper'
require 'bio-commandeer'

class TestScript < Test::Unit::TestCase
  should "test 1 result" do
    path_to_script = File.join(File.dirname(__FILE__),'..','bin','pcr.rb')
    path_to_data = File.join(File.dirname(__FILE__),'data')

    expected = "target	mismatches_fwd	mismatches_rev	length	gc_of_forward_matching	gc_of_reverse_matching	gc_positions_of_forward_matching	gc_positions_of_reverse_matching
gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence	0	3	418	6	7	11010101100	00110011111
gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence	0	3	733	6	5	11010101100	00111100001
gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence	3	0	348	7	10	11010101101	1000010110001001100111
gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence	3	0	123	8	10	11011101101	1000010110001001100111
gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence	0	3	418	6	7	11010101100	00110011111
gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence	0	3	733	6	5	11010101100	00111100001
gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence	3	0	348	7	10	11010101101	1000010110001001100111
gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence	3	0	123	8	10	11011101101	1000010110001001100111
"
    assert_equal(expected, Bio::Commandeer.run("#{path_to_script} --primer1 GGTCACTGCTA --primer2 GGCTACCTTGTTACGACTTAAC --fasta #{path_to_data}/Ipcress/Methanocella_conradii_16s_twice.fa"))
  end
end
