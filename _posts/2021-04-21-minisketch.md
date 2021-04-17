---
layout: pr
date: 2021-04-21
title: "Minisketch C++ code"
link: https://github.com/sipa/minisketch/tree/master
authors: [sipa]
components: ["math and cryptography"]
host: sipa
status: upcoming
commit:
---

## Notes

- [libminisketch](https://github.com/sipa/minisketch) is a library implementing
  the [PinSketch](https://www.cs.bu.edu/~reyzin/code/fuzzy.html) set reconciliation algorithm.
  It is the basis for the efficient relay protocol in
  [Erlay](https://arxiv.org/abs/1905.10518) (covered in a [previous review
  club](/18261)), but is generally usable for various
  applications that use set reconciliation.

- In yet another [previous](/minisketch-26-2) review club we covered
  some of the algorithms involved by looking at the
  [Python reimplementation](https://github.com/sipa/minisketch/blob/master/tests/pyminisketch.py).
  In this review club we will be looking at some of the C++ code instead that implements it
  efficiently.

- The codebase is roughly organized as follows:

  - The main entrance point into the library is
    [minisketch.cpp](https://github.com/sipa/minisketch/blob/master/src/minisketch.cpp).
    It is really just a collection of functions that construct `Sketch` objects (defined
    in [sketch.h](https://github.com/sipa/minisketch/blob/master/src/sketch.h)) for
    various fields, and then exposes C functions that invoke the corresponding `Sketch`
    member functions.

  - The actual meat of the PinSketch algorithm (including Berlekamp-Massey and the root
    finding algorithm) is in
    [sketch_impl.h](https://github.com/sipa/minisketch/blob/master/src/sketch_impl.h).
    The implementation code is instantiated separately using templates for every field
    implementation, but they all implement the virtual `Sketch` class, presenting a
    uniform interface that minisketch.cpp can use.

  - There are up to 3 distinct field implementations for every field size (libminisketch
    currently supports field sizes from 2 to 64 bits, inclusive):

    - The generic one that works on every platform, with common code in
      [fields/generic_common_impl.h](https://github.com/sipa/minisketch/blob/master/src/fields/generic_common_impl.h)
      and specific definitions in [fields](https://github.com/sipa/minisketch/blob/master/src/fields)/generic_*.cpp.
      It relies on a number of shared integer functions that help represent GF(2^bits) field elements
      as integers, found in [int_utils.h](https://github.com/sipa/minisketch/blob/master/src/int_utils).

    - Two ["clmul"](https://en.wikipedia.org/wiki/CLMUL_instruction_set)-based implementations that use
      intrinsics to access special instructions, and only run on certain x86/64 CPUs. These instructions
      are specifically designed to help with GF(2^n) multiplications, and they greatly improve performance
      when available (which is the case for pretty much all x86/64 CPUs since 2013 or so).
      One implementation is optimized for fields that have a modulus of the form `x^bits + x^a + 1`,
      while another works for any modulus. The common code for these can be found in
      [fields/clmul_common_impl.h](https://github.com/sipa/minisketch/blob/master/src/fields/clmul_common_impl.h),
      and specific field definitions in [fields](https://github.com/sipa/minisketch/blob/master/src/fields)/clmul_*.cpp.

  - Finally there are tests in [test-exhaust.cpp](https://github.com/sipa/minisketch/blob/master/src/test-exhaust.cpp)
    (extended and renamed to `test.cpp` in [PR #33](https://github.com/sipa/minisketch/pull/33))
    and benchmarks in [bench.cpp](https://github.com/sipa/minisketch/blob/master/src/bench.cpp).

## Questions

1. Why is there a separate instantiation of the PinSketch algorithm for every field?

2. If you look at the [fields](https://github.com/sipa/minisketch/blob/master/src/fields)/*.cpp files,
   you will notice there are large amounts of hardcoded linear transformation tables (with code for
   defining them in [lintrans.h](https://github.com/sipa/minisketch/blob/master/src/lintrans.h).
   Which tables do you see, and why are they useful? What do they expand to at compile time?

3. Why are there instances of `Sketch` for different fields in separate .cpp files? Could all the
   generic ones be merged into a single file? Could the generic ones and the clmul ones be merged?

4. Do you notice any optimizations in [sketch_impl.h](https://github.com/sipa/minisketch/blob/master/src/sketch_impl.h)
   that weren't present in the Python code?

5. What is tested in [test-exhaust.cpp](https://github.com/sipa/minisketch/blob/master/src/test-exhaust.cpp)?
   This may be clearer if you look at [PR #33](https://github.com/sipa/minisketch/pull/33).

6. For every field implementation `Field` there is a member type `Field::Elem` (which for all current
   fields is just an integer type), and invoking field operations goes through `Field` (e.g. multiplying
   two field elements `a` and `b` is done through `field.Mul(a,b)`. A more intuitive design would be
   to make `Field::Elem` a separate class for each field, with its own member functions for finite field
   arithmetic (so that the above could be done simply using `a*b` for example). Any idea why this approach
   is not used?

7. Bonus question: what is special about field size 58 (look at
   [fields/clmul_8bytes.cpp](https://github.com/sipa/minisketch/blob/master/src/fields/clmul_8bytes.cpp))?

## Appendix

_(notes added after the meeting)_
