# Hardware Implementations of Huffman/rANS coders.

While we often talk about compression algorithms in the software domain (or at least we have in EE274), in practice many compression schemes are implemented in hardware due to the ubiquity of data compression and the corresponding performance gains of hardware. Examples of common compression schemes implemented in hardware are Huffman codes, HEIC, JPEG, AV1, and LZ77/LZW (as well as tons more). This project aims to similarly practice implementing data compression in hardware. Specifically, I am implementing a Huffman coder and an rANS coder in hardware. Due to the mountain of existing implementations for these schemes and their many variants, I am not expecting these implemementations to be particularly novel, but I do expect they will be good practice and can also serve to illustrate the tradeoffs of implementing in the hardware domain vs. the software domain.



## Literature and Reference Implementations

Full references are linked and listed at the bottom. The first few references are materials related to Huffman coders and the last few correspond to rANS.

[An efficient finite-state machine implementation of Huffman decoders](#1)

I'll further note that since Huffman coding has been around for a while, many papers discussing straightforward implementations are fairly old (as is the case for the next one).

[Design and hardware implementation of a memory efficient Huffman decoding](#2)

After the huge amount of existing resources on hardware Huffman coders, I was a little surprised to see rANS discussion mainly kept in the software domain. I'm still looking for materials here, so additional suggestions are welcome!

[An FPGA-Based LOCO-ANS Implementation for Lossless and Near-Lossless Image Compression Using High-Level Synthesis](#3)


## Methods



## Progress
##### or see Timeline for chronological details

#### Huffman Coder
- [x] Implemented atomic encoder (one symbol at a time)
- [ ] Test coverage of atomic encoder
- [ ] Implemented atomic decoder
- [ ] Test coverage of atomic decoder
- [ ] Implemented parallel coder
- [ ] Test coverage of parallel coder

#### rANS
- [ ] Not scoped out yet.

## Timeline

#### Week of Nov. 7:
 - Started Huffman 
 
 
 
## References (Fuller Version)

<a id="1">[1]</a> 
Vikram Iyengar, Krishnendu Chakrabarty, "An efficient finite-state machine implementation of Huffman decoders," in Information Processing Letters, Volume 64, Issue 6, 1997, Pages 271-275, ISSN 0020-0190, https://doi.org/10.1016/S0020-0190(97)00176-2.(https://www.sciencedirect.com/science/article/pii/S0020019097001762)

<a id="2">[2]</a> 
R. Hashemian, "Design and hardware implementation of a memory efficient Huffman decoding," in IEEE Transactions on Consumer Electronics, vol. 40, no. 3, pp. 345-352, Aug. 1994, doi: 10.1109/30.320814.

<a id="3">[3]</a> 
T. Alonso, G. Sutter, and J. E. López de Vergara, “An FPGA-Based LOCO-ANS Implementation for Lossless and Near-Lossless Image Compression Using High-Level Synthesis,” Electronics, vol. 10, no. 23, p. 2934, Nov. 2021, doi: 10.3390/electronics10232934. [Online]. Available: http://dx.doi.org/10.3390/electronics10232934
