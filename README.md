# bed2wig

Description: This script converts bedGraph to fixedStep wig format with defined step size. Input file may be compressed as .gz.

Coordinates in bedGraph input are assumed to be 0-based (http://genome.ucsc.edu/goldenPath/help/bedgraph.html).

Coordinates in wig output are 1-based (http://genome.ucsc.edu/goldenPath/help/wiggle.html). 

Usage: 
  bedgraph_to_wig.pl --bedgraph input.bedgraph --wig output.wig --step step_size [--compact]

   --bedgraph : specify input file in bedGraph format.
   --genomeSize: specify genome chromosome size file.
 --wig : specify output file in fixedStep format.
 --step : specify step size. Note that span is set to be identical to step.
 --compact : if selected, steps with value equal to 0 will not be printed. This saves space but was not allowed in original wig format, thus some scripts using wig file as input may not understand it.
