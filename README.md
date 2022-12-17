# Hardware Implementations of Huffman/rANS coders.
(note: this used to be the milestone, but I've moved that [here](MILESTONE.md) and tried to refactor this document as a bit more of a general intro document to the repo, with some guidance for navigation and usage.)

While we often talk about compression algorithms in the software domain (or at least we have in EE274), in practice many compression schemes are implemented in hardware due to the ubiquity of data compression and the corresponding performance gains of hardware. Examples of common compression schemes implemented in hardware are Huffman codes, HEIC, JPEG, AV1, and LZ77/LZW (as well as tons more). This project aims to similarly practice implementing data compression in hardware. Specifically, I am implementing a Huffman coder and an rANS coder in hardware. Due to the mountain of existing implementations for these schemes and their many variants, I am not expecting these implemementations to be particularly novel, but I do expect they will be good practice and can also serve to illustrate the tradeoffs of implementing in the hardware domain vs. the software domain.

## Navigating the project

This repo blew up a bit as I was flushing my local stuff and preparing it for showcase so I put together a navigation guide. Most files break down one of two ways, listed below.

#### Writing and guides

In addition to this README, I prepared both a [milestone](MILESTONE.md) and [final report](REPORT.md) for this project. I hope to add some usage/verification guidance in specific READMEs, but that may have to come later. Also, my [presentation](https://docs.google.com/presentation/d/1ePWbsySpJ8HzIQ9NeXeXHjFsp2yc84qS68RiVC_vdvc/edit?usp=sharing) can be found at the link in case it's useful as well.

#### Code

The code in this repo breaks down three ways. First, my SystemVerilog implementations of Huffman and rANS coders can be found in [verilog](verilog). Second, hardware verification module code can be found in the [verification](dv) folder. Lastly, I also used the software implementations of these coders in [Stanford Compression Library](stanford_compression_library) as part of my development/verification process.

**Unfortunately, all of the hardware implementations require licensed software to run (even in simulation).** I use Synopsys VCS for simulation, which is available on the Stanford caddy machines, but I wanted to note this because it's currently a bit of work to get these implementations running (and I haven't even laid out a repeatable flow for synthesis/implementation to FPGA). I'm throwing together a Makefile which will hopefully be able to make this easier, but at time of writing a user will need some additional software/scripts that I can't add to the repo to run the code.

## Progress

#### Huffman Coder
- [x] Implemented atomic encoder (one symbol at a time)
- [x] Test coverage of atomic encoder
- [x] Implemented decoder
- [ ] Test coverage of decoder
- [x] Implemented parallel coder
- [ ] Test coverage of parallel coder

#### rANS
- [x] Implemented simple atomic encoder
- [x] Implemented decoder

#### Test Harness
 - [ ] Python code to run Stanford Compression Library and generate gold standard
 - [ ] Make/script to run gold/sim and check for correctness

## References (kept these as acknowledgements for materials I consulted while working on this project)

<a id="1">[1]</a> 
Vikram Iyengar, Krishnendu Chakrabarty, "An efficient finite-state machine implementation of Huffman decoders," in Information Processing Letters, Volume 64, Issue 6, 1997, Pages 271-275, ISSN 0020-0190, https://doi.org/10.1016/S0020-0190(97)00176-2.(https://www.sciencedirect.com/science/article/pii/S0020019097001762)

<a id="2">[2]</a> 
R. Hashemian, "Design and hardware implementation of a memory efficient Huffman decoding," in IEEE Transactions on Consumer Electronics, vol. 40, no. 3, pp. 345-352, Aug. 1994, doi: 10.1109/30.320814.

<a id="3">[3]</a> 
Taeyeon Lee and Jaehong Park, "Design and implementation of static Huffman encoding hardware using a parallel shifting algorithm," in IEEE Transactions on Nuclear Science, vol. 51, no. 5, pp. 2073-2080, Oct. 2004, doi: 10.1109/TNS.2004.834715.

<a id="4">[4]</a> 
T. Alonso, G. Sutter, and J. E. López de Vergara, “An FPGA-Based LOCO-ANS Implementation for Lossless and Near-Lossless Image Compression Using High-Level Synthesis,” Electronics, vol. 10, no. 23, p. 2934, Nov. 2021, doi: 10.3390/electronics10232934. [Online]. Available: http://dx.doi.org/10.3390/electronics10232934
