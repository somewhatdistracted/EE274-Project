# EE274 Final Report
Ian MacFarlane - ianpmac (at) stanford (dot) edu

## Hardware Implementations of Huffman/rANS coders.

While we often talk about compression algorithms in the software domain (or at least we have in EE274), in practice many compression schemes are implemented in hardware due to the ubiquity of data compression and the corresponding performance gains of hardware. Examples of common compression schemes implemented in hardware are Huffman codes, HEIC, JPEG, AV1, and LZ77/LZW (as well as tons more). This project aims to similarly practice implementing data compression in hardware. Specifically, I am implementing a Huffman coder and an rANS coder in hardware. Due to the mountain of existing implementations for these schemes and their many variants, I am not expecting these implemementations to be particularly novel, but I do expect they will be good practice and can also serve to illustrate the tradeoffs of implementing in the hardware domain vs. the software domain.

Note for viewers who previously read the project milestone: a fair amount of this content is repurposed from the milestone, though I've added several sections and filled out the results a bit.

### Literature and Reference Implementations

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



And a blog post I found quite useful in enumerating rANS optimizations:

[rANS with static probability distributions](https://fgiesen.wordpress.com/2014/02/18/rans-with-static-probability-distributions/)

## Methods and Implementation

For this project, I am implementing both a static (though generally reprogrammable) Huffman coder -- mostly as a "warmup" of sorts -- and an rANS coder in SystemVerilog. Click [here](verilog) if you want to see the implementation code directly.

### Huffman Coder

The Huffman implementation is fairly simple, but still worth explaining, as it illustrates some of the concerns in hardware design. 

#### Encoder-side
Encoding for a Huffman coder is straightforward, but it's first worth defining our inputs/outputs/etc. so that we can reason about how our module stands alone or fits into other hardware. For input, we assume we have access to a stream of symbols, perhaps given in parallel cycle-by-cycle. Ideally, we want to be able to feed new symbols in every clock cycle, so our module should work (pipelined or otherwise) to have a throughput equal to our input. Lastly, we want to output a serialized set of symbols such that we can easily read out the encoding data. 

Now that we've defined how this module integrates with its surroundings we can discuss the internals. As mentioned previously we assume that we have access to an externally-supplied stream of symbols, then we split these symbols many ways and encode them in parallel via lookup table. Doing this in hardware allows for a very high degree of parallelization (though SIMD instructions manage similarly). Lastly, the main important concern for the encoding side is re-serializing the data for storage/communication and eventual decoding. In this code, parallelized encoding is done in the [huff_encoder_atom](verilog/huff_encoder_atom.sv) blocks, which are managed by the more general [huff_encoder](verilog/huff_encoder.sv) block, which coordinates the atoms and manages data flow. I also define a [symbol_lut](verilog/symbol_lut.sv), which is really just a plug-and-play memory block that we use across all the implementations.

#### Decoder-side
Next is decoding for the Huffman coder. While there are many ways of implementing a Huffman decoder (one straightforward option would be to use a lookup table similar to the encoder), I was drawn to an old [solution](#1) that used a finite state machine to do the decoding, using the prefix-free property of Huffman codes to read the bitstream bit-by-bit and parse out symbols via state evolution. It's worth noting that this isn't a particularly throughput-optimized implementation (in contrast to the encoder). Instead, this implementation is designed more for logical simplicity / space efficiency. I chose it instead of a repeat of the LUT-based solution to illustrate (and practice) the range of solutions in this space.

In more concrete terms, the decoder works by reading the input encoded data bit-by-bit. As each bit is read, it is appended to an internal state of the decoder. As soon as the decoder state matches a known encoding, the state is reset and the encoding is copied to the output.

TODO: Expand on self-synchronizing parallelization.

### rANS

#### Encoder-side

###### Computational Optimizations to rANS encoding

```python
# original code
def rans_base_encode_step(x,s):
   x_next = (x//freq[s])*M + cumul[s] + x%freq[s]
   return x_next
   
# let inv_freq[s] = 1/freq[s]
# avoiding division and modulus makes the hardware much simpler
def rans_base_encode_step(x,s):
   div = int(x*inv_freq[s])
   x_next = M*div + cumul[s] + x - div*freq[s]
   return x_next
   
# let r = log2(M)
# turning a multiplication into a bitshift basically removes a
# calculation step in hardware
def rans_base_encode_step(x,s):
   div = int(x*inv_freq[s])
   x_next = div<<r + cumul[s] + x - div*freq[s]
   return x_next
```

#### Decoder-side

### Verification and Testing

Supporting the hardware implementation of the Huffman coder (and the rANS coder that follows), I've been working on a test harness that instantiates a functionally equivalent coder using the [stanford_compression_library](https://github.com/kedartatwawadi/stanford_compression_library/) and compares the encoded and decoded data to guarantee the functionality of the hardware implementation.

## Results and Conclusions



## References (Fuller Version)

<a id="1">[1]</a> 
Vikram Iyengar, Krishnendu Chakrabarty, "An efficient finite-state machine implementation of Huffman decoders," in Information Processing Letters, Volume 64, Issue 6, 1997, Pages 271-275, ISSN 0020-0190, https://doi.org/10.1016/S0020-0190(97)00176-2.(https://www.sciencedirect.com/science/article/pii/S0020019097001762)

<a id="2">[2]</a> 
R. Hashemian, "Design and hardware implementation of a memory efficient Huffman decoding," in IEEE Transactions on Consumer Electronics, vol. 40, no. 3, pp. 345-352, Aug. 1994, doi: 10.1109/30.320814.

<a id="3">[3]</a> 
Taeyeon Lee and Jaehong Park, "Design and implementation of static Huffman encoding hardware using a parallel shifting algorithm," in IEEE Transactions on Nuclear Science, vol. 51, no. 5, pp. 2073-2080, Oct. 2004, doi: 10.1109/TNS.2004.834715.

<a id="4">[4]</a> 
T. Alonso, G. Sutter, and J. E. López de Vergara, “An FPGA-Based LOCO-ANS Implementation for Lossless and Near-Lossless Image Compression Using High-Level Synthesis,” Electronics, vol. 10, no. 23, p. 2934, Nov. 2021, doi: 10.3390/electronics10232934. [Online]. Available: http://dx.doi.org/10.3390/electronics10232934
