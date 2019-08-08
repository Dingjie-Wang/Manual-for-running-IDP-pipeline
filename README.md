# Manual for running IDP pipeline

IDP is a gene Isoform Detection and Prediction tool from Second Generation Sequencing and PacBio Sequencing (also called Hybrid Sequencing) developed by Prof. Kin Fai Au. It offers very reliable gene isoform identification with high sensitivity. This a fork of the original IDP, the purpose is to better help people to run this software. The official distribution is available at: http://augroup.org/IDP/IDP

This manual contains more than just IDP, it has whole IDP pipeline which includes four steps: (1) Correct errors in long reads using short reads; (2) Align the corrected long reads; (3) Align the short reads; (4) Running IDP software. 

In the following, I will show you how to run IDP software through an example data. You should just clone this Git repository and use the example data from it. You can clone this repository and we'll work in the example directory. <br>
$ git clone https://github.com/jason-weirather/IDP.git <br>
$ cd IDP/example <br>
$ gunzip data/*.gz <br>
$ ls -lht data <br>

# 1. Correct errors in long reads using short reads
The first step is to perform error correction on long reads using long and short reads combined. We have included both ColoRMap, LoRDEC and LSC software that can accomplish this step. I recommend ColoRMap and LoRDEC for speed and comparable performance on larger datasets. <br>
(1) ColoRMap is available at:  https://github.com/sfu-compbio/colormap <br>
(2) LoRDEC is available at: http://www.atgc-montpellier.fr/lordec/ <br>
(3) LSC is available at: http://augroup.org/LSC/LSC <br>

As an example, in the following, I will show how to run ColoRMap software for error correction in long reads, which includes the following steps:
## (1) Installation <br>
In order to install ColoRMap, you should first fetch the source code from ColoRMap git repository. <br>
$ git clone --recursive https://github.com/sfu-compbio/colormap.git <br>
Then, you can running the following command to install: <br>
$ cd colormap <br>
$ make deps <br>
$ make <br>

## (2) Correcting long reads <br>
To correct long reads, you can use runCorr.sh script:<br>
$ runCorr.sh lr.fa sr.fa output pre 4 <br>

This runs shortest path correction algorithm for long reads stored in lr.fa by short reads stored in sr.fa using 4 threads. When this is done, the corrected long reads are stored in testCorr/pre_sp.fasta file. You need to rename pre_sp.fasta as corrected_lr.fasta.
Note: If you have paired-end short reads, you need to get a single interleaved/interlaced read file using fastUtils program. Then you can improve the correction using One-End Anchors algorithm. Please see the webpage: https://github.com/sfu-compbio/colormap for the details.

# 2. Align the corrected long reads
You could let IDP do this for you, but I caution against it. Its’ a slow process and the aligners can crash sometimes, so its’ better to just sort this out now and not deal with it in the IDP run. Here, we align the corrected long reads using GMAP software. 
 (1) Download GMAP software at:
 http://research-pub.gene.com/gmap/src/gmap-gsnap-2018-07-04.tar.gz
 (2) Detailed description for installation is available at: 
http://research-pub.gene.com/gmap/src/README 
In Linux, you can do the following command:
$ wget http://research-pub.gene.com/gmap/src/gmap-gsnap-2018-07-04.tar.gz 
$ tar –zxvf gmap-gsnap-2018-07-04.tar.gz
$ ./configure 
$ make 
$ make check 
$ make install 

 (3) Build a gmap index
In Linux, you can use the following command for building the gmap index
$ gmap_build -D ./ -d gmapindex ./chr20.fa
(4) Align the corrected long reads
$ # Align the corrected long reads
$ gmap -D ./ -d gmapindex -t 2 -f 1 -n 1 corrected_lr.fasta > corrected_lr.psl

# 3. Align the short reads
I will use hisat2 to align reads but run SpliceMap is included if you want a more classic approach to the IDP pipeline. For speed and stability I recommend hisat2 but it will require an additional processing step on our part.
(1) Download hisat2 software at:
http://ccb.jhu.edu/software/hisat2/dl/hisat2-2.1.0-Linux_x86_64.zip

(2) Detailed description for installation is available at:
https://ccb.jhu.edu/software/hisat2/index.shtml
In Linux, you can do the following command:
$ wget http://ccb.jhu.edu/software/hisat2/dl/hisat2-2.1.0-Linux_x86_64.zip
$ unzip hisat2-2.1.0-Linux_x86_64.zip
$ cd hisat2-2.1.0

(3) Build a hisat2 index
In Linux, you can do the following command:
$ hisat2-build chr20.fa hisat2/hisat2index

(4) Align the short reads
We can align the short reads by the following command:
$ hisat2 -x hisat2/hisat2index -U sr.fa -f -S sr.sam

(5) Get the SAM and BED file for SpliceMap format
Looks good! Unfortunately, IDP needs a different format than the garden variety bam. To accomodate this we will need to conver the bam into a SpliceMap format sam, and also create a junction file like SpliceMap does. We use helper scripts for this part.
$ # get SpliceMap format sam file (please install python-2.7 and R-3.5)
$ ./Au-public-master/iron/utilities/make_sam_splicemap_like.py sr.sam sr_trim.sam
$ Rscript ./Au-public-master/iron/utilities/make_sam_splicemap_like.R sr_trim.sam sr.splicemap-like.sam
$ # get SpliceMap format bed file
$ ./Au-public-master/iron/utilities/sam_to_splicemap_junction_bed.py -o sr.splicemap-like.junctions.bed sr.sam chr20.fa

# 4. Run IDP software
The psl option is the most convenient way to run IDP since it allows you to do your own alignment ahead of time as we have done here. To make this easier the IDP/examples folder contains a configuration file that points to the folders we've generated in this example. On a normal run you will create your own configuration file to describe the run. Now to actually run IDP. This configuration file has been set to use the files created in this example. In this example we are using an RPKM absolute and fraction cutoff rather than an FDR. The FDR does not execute well in small datasets or non-model organisms.
If you prepared related input files and created your own configuration file, you can run IDP by the following command:
$ ./bin/runIDP.py run.cfg 0
All of the output from IDP is automatically copied to the “output” directory, which includes isoform.gpd, isoform_detection.gpd, isoform_prediction.gpd and isoform.exp files.

