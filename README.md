# bio-ipcress

[![Build Status](https://secure.travis-ci.org/wwood/bioruby-ipcress.png)](http://travis-ci.org/wwood/bioruby-ipcress)

bio-ipcress is a library for programmatically interacting with the In-silico PCR Experiment Simulation System (iPCRess), 
available as part of the [http://www.ebi.ac.uk/~guy/exonerate/](exonerate) package.

## Installation

```sh
gem install bio-ipcress
```
To run an ipcress, you must also have ipcress itself installed. 

## Usage

```ruby
require 'bio-ipcress'

primer_set = Bio::Ipcress::PrimerSet.new('GGTCACTGCTA','GGCTACCTTGTTACGACTTAAC')
results = Bio::Ipcress.run(
   primer_set, 
   'test/data/Ipcress/Methanocella_conradii_16s.fa', 
   {:min_distance => 2, :max_distance => 10000}) # optional parameters
   #=> a set of Bio::Ipcress::Result objects (in this case containing 1, since there is only 1 amplification product) 

results[0].product #=> "1422 bp (range 2-10000)" 
results[0].target #=> "gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence"
```

A full anatomy of a parsed iPCRess result:

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

```
** Message: Loaded [1] experiments

Ipcress result
--------------
 Experiment: AE12_pmid21856836_16S   ## experiment_name
    Primers: A B   ## primers
     Target: gi|335929284|gb|JN048683.1|:filter(unmasked) Methanocella conradii HZ254 16S ribosomal RNA gene, partial sequence   ## target
    Matches: 19/20 14/15   ## matches
    Product: 502 bp (range 2-10000)   ## product
Result type: forward   ## result_type

...AAACTTAAAGGAATTGGCGG......................... # forward   ## forward_matching_sequence ('AAACTTAAAGGAATTGGCGG')
   ||||| ||| |||||| |||-->
5'-AAACTYAAAKGAATTGRCGG-3' 3'-CRTGTGTGGCGGGCA-5' # primers   ## forward_primer_sequence, reverse_primer_sequence
                           <--| |||||||||||||
..............................CGTGTGTGGCGGGCA... # revcomp   ## reverse_matching_sequence
--
ipcress: gi|335929284|gb|JN048683.1|:filter(unmasked) AE12_pmid21856836_16S 502 A 826 1 B 1313 1 forward   ## length (502), start (826), forward_mismatches (1), reverse_mismatches (1)
-- completed ipcress analysis
```

The API doc is online. For more code examples see the test files in
the source tree.

## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/wwood/bioruby-ipcress

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

bio-ipcress is currently unpublished. However, if you use this software, perhaps you would like to cite ipcress itself, as well as BioRuby and Biogem 
  
* [BioRuby: bioinformatics software for the Ruby programming language](http://dx.doi.org/10.1093/bioinformatics/btq475)
* [Biogem: an effective tool-based approach for scaling up open source software development in bioinformatics](http://dx.doi.org/10.1093/bioinformatics/bts080)

## Biogems.info

This Biogem is published at [#bio-ipcress](http://biogems.info/index.html)

## Copyright

Copyright (c) 2012 Ben J Woodcroft. See LICENSE.txt for further details.

