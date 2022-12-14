# Hardware Implementations of Huffman/rANS coders.

While we often talk about compression algorithms in the software domain (or at least we have in EE274), in practice many compression schemes are implemented in hardware due to the ubiquity of data compression and the corresponding performance gains of hardware. Examples of common compression schemes implemented in hardware are Huffman codes, HEIC, JPEG, AV1, and LZ77/LZW (as well as tons more). This project aims to similarly practice implementing data compression in hardware. Specifically, I am implementing a Huffman coder and an rANS coder in hardware. Due to the mountain of existing implementations for these schemes and their many variants, I am not expecting these implemementations to be particularly novel, but I do expect they will be good practice and can also serve to illustrate the tradeoffs of implementing in the hardware domain vs. the software domain.



## Literature and Reference Implementations

Full references are linked and listed at the bottom. The first few references are materials related to Huffman coders and the last few correspond to rANS.

I'll further note that since Huffman coding has been around for a while, many papers discussing straightforward implementations are fairly old (as is the case for the first two papers). This first paper discusses a finite-state machine implementation of Huffman decoders, which relies on the prefix-free property of Huffman codes to decode encoded symbols via state evolution. The prefix-free property makes this possible by guaranteeing that the state machine will not interpret a symbol stop erroneously even if it parses the bitstream one bit at a time. While not a very throughput-efficient implementation, it is quite space-efficient, and I ended up using it for the Huffman decoder to keep it interesting.

[An efficient finite-state machine implementation of Huffman decoders](#1)

This next paper is a similar space-efficiency optimization technique for Huffman decoders, and though I didn't end up using it, the paper is interesting to read.

[Design and hardware implementation of a memory efficient Huffman decoding](#2)

Finally, this last Huffman-related paper is a bit overspecific to a certain implementation of a real-time Huffman coder, but it has some useful discussion related to the serialization of the variable-length Huffman encoded symbols into a fixed-size buffer.

[Design and implementation of static Huffman encoding hardware using a parallel shifting algorithm](#3)

After the huge amount of existing resources on hardware Huffman coders, I was a little surprised to see rANS discussion mainly kept in the software domain. I'm still looking for materials here, so additional suggestions are welcome!

[An FPGA-Based LOCO-ANS Implementation for Lossless and Near-Lossless Image Compression Using High-Level Synthesis](#4)

Here's a few more papers I've looked at that go through software implementations but that have some application to hardware:



## Methods

For this project, I am implementing both a static (though generally reprogrammable) Huffman coder -- mostly as a "warmup" of sorts -- and an rANS coder in SystemVerilog.

The Huffman implementation is fairly simple, but still worth explaining, as it illustrates some of the concerns in hardware design. Encoding is straightforward: we assume that we have access to an externally-supplied stream of symbols, then we split these symbols many ways and encode them in parallel via lookup table. Doing this in hardware allows for this parallelization (though SIMD instructions manage similarly), and the lookup table will generally have access times equivalent or better than a generic CPU's cache access time. Lastly, the main important concern for the encoding side is re-serializing the data for storage/communication and eventual decoding. In my code, parallelized encoding is done in the `huff_encoder_atom` blocks, which are managed by the more general `huff_encoder` block, which coordinates the atoms and manages data flow.

Next is decoding for the Huffman coder. While there are many ways of implementing a Huffman decoder (one straightforward option would be to use a lookup table similar to the encoder), I was drawn to an old [solution](#1) that used a finite state machine to do the decoding, using the prefix-free property of Huffman codes to read the bitstream bit-by-bit and parse out symbols via state evolution. It's worth noting that this isn't a particularly throughput-optimized implementation (in contrast to the encoder). Instead, this implementation is designed more for logical simplicity / space efficiency. I chose it instead of a repeat of the LUT-based solution to illustrate (and practice) the range of solutions in this space.

Supporting the hardware implementation of the Huffman coder (and the rANS coder that follows), I've been working on a test harness that instantiates a functionally equivalent coder using the [stanford_compression_library](https://github.com/kedartatwawadi/stanford_compression_library/) and compares the encoded and decoded data to guarantee the functionality of the hardware implementation.

## Optimization demo

```python
def rans_base_encode_step(x,s):
   x_next = (x//freq[s])*M + cumul[s] + x%freq[s]
   return x_next
   
def rans_base_encode_step(x,s):
   div = int(x*inv_freq[s])
   x_next = M*div + cumul[s] + x - div*freq[s]
   return x_next
   
def rans_base_encode_step(x,s):
   div = int(x*inv_freq[s])
   x_next = div<<r + cumul[s] + x - div*freq[s]
   return x_next
```

## Progress
##### or see Timeline for chronological details

#### Huffman Coder
- [x] Implemented atomic encoder (one symbol at a time)
- [x] Test coverage of atomic encoder
- [x] Implemented decoder
- [ ] Test coverage of decoder
- [x] Implemented parallel coder
- [ ] Test coverage of parallel coder

#### Test Harness
 - [ ] Python code to run stanford_compression_library and generate gold standard
 - [ ] Make/script to run gold/sim and check for correctness

#### rANS
- [ ] Implemented simple atomic encoder
- [ ] Implemented decoder

## Timeline

#### Week of Nov. 7:
 - Started Huffman 

#### TODO Update
 
## References (Fuller Version)

<a id="1">[1]</a> 
Vikram Iyengar, Krishnendu Chakrabarty, "An efficient finite-state machine implementation of Huffman decoders," in Information Processing Letters, Volume 64, Issue 6, 1997, Pages 271-275, ISSN 0020-0190, https://doi.org/10.1016/S0020-0190(97)00176-2.(https://www.sciencedirect.com/science/article/pii/S0020019097001762)

<a id="2">[2]</a> 
R. Hashemian, "Design and hardware implementation of a memory efficient Huffman decoding," in IEEE Transactions on Consumer Electronics, vol. 40, no. 3, pp. 345-352, Aug. 1994, doi: 10.1109/30.320814.

<a id="3">[3]</a> 
Taeyeon Lee and Jaehong Park, "Design and implementation of static Huffman encoding hardware using a parallel shifting algorithm," in IEEE Transactions on Nuclear Science, vol. 51, no. 5, pp. 2073-2080, Oct. 2004, doi: 10.1109/TNS.2004.834715.

<a id="4">[4]</a> 
T. Alonso, G. Sutter, and J. E. L??pez de Vergara, ???An FPGA-Based LOCO-ANS Implementation for Lossless and Near-Lossless Image Compression Using High-Level Synthesis,??? Electronics, vol. 10, no. 23, p. 2934, Nov. 2021, doi: 10.3390/electronics10232934. [Online]. Available: http://dx.doi.org/10.3390/electronics10232934
