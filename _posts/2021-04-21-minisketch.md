---
layout: pr
date: 2021-04-21
title: "Minisketch C++ code"
link: https://github.com/sipa/minisketch/tree/master
authors: [sipa]
components: ["math and cryptography"]
host: sipa
status: past
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

## Meeting Log

{% irc %}
19:00 <@jnewbery> #startmeeting
19:00 <jeremyrubin> hi
19:00 <@jnewbery> hi folks! Welcome to Bitcoin Core PR Review Club. A club about review Bitcoin Core PRs.
19:00 <@jnewbery> *reviewing
19:00 <schmidty> gi
19:00 <gleb> hi
19:00 <glozow> hi
19:00 <@jnewbery> feel free to say hi to let everyone know you're here
19:00 <lightlike> hi
19:00 <pglazman> hi
19:00 <svav> hi
19:00 <michaelfolkson> hi
19:00 <emzy> hi
19:01 <@jnewbery> anyone here for the first time?
19:01 <wiscojabroni> yes me!
19:01 <@jnewbery> welcome wiscojabroni!
19:02 <wiscojabroni> thank you!
19:02 <dictation> hi
19:02 <larryruane_> hi everyone
19:02 <sipa> hi everyone and welcome
19:02 <ssd> hi
19:02 <@jnewbery> just a couple of reminders: the host is here to guide the discussion with some prepared questions (here https://bitcoincore.reviews/minisketch), but feel free to ask questions at any time
19:03 <@jnewbery> no need to ask if you can ask. Just ask away! We're all here to learn
19:03 <@jnewbery> ok, over to sipa
19:03 <andrewtoth_> hi
19:03 <sipa> hi everyone
19:03 <murchin> hey
19:03 <hernanmarino> hi ! First timer here
19:03 <murchin> Hi Hernan :)
19:03 <sipa> this is a bit of an unusual review club too, as we're nkt reviewing a PR
19:04 <@jnewbery> welcome hernanmarino!
19:04 <sipa> but an enture project/repository
19:04 <dulcedu> hola!
19:04 <hernanmarino> thanks
19:04 <sipa> that means we're obviously not going as deep
19:05 <sipa> and i've tried to make the questions/summary primarily about code organization
19:05 <svav> Is the main purpose of libminisketch being used in Bitcoin Core to provide efficiency gains to the relay protocol Erlay?
19:05 <sipa> svav: indeed
19:05 <sipa> that's the only reason (for now) why we'd want it in bitcoin core
19:06 <jeremyrubin> sipa: not sure if covered before or if you want the focus to be on the algo, but maybe you could set up the general problem we're trying to solve for
19:06 <@jnewbery> jeremyrubin: https://bitcoincore.reviews/minisketch-26
19:06 <sipa> jeremyrubin: we already did two review clubs on the algo
19:06 <svav> When you refer to "fields", how many fields is this, and are these just the common fields of a Bitcoin transaction?
19:06 <sipa> svav: they refer to mathematical fields
19:07 <@jnewbery> We've gone over the high level concepts in a couple of previous review club sessions. I think it makes sense to focus on the c++ implementation here
19:07 <jeremyrubin> gotcha; will look at earlier notes!
19:07 <sipa> search for galois field on wikipedia, or read the transceipts of tbe previous review clubs
19:07 <jonatack> hi
19:07 <Gambo> hello!
19:08 <sipa> also i apologize for my slow and slightly erratic typing; i:m currently unable to do this from anywhere my phone
19:08 <sipa> so let's dive in with the first question
19:08 <sipa> Why is there a separate instantiation of the PinSketch algorithm for every field?
19:08 <dictation> Why is there a separate instantiation of the PinSketch algorithm for every field?
19:09 <sipa> and again, this refers to the specific galois fields used in the algorithm
19:09 <larryruane_> is this a classic space-time tradeoff? Separate instatiations means the compiler can optimize better?
19:09 <glozow> I thought (1) composability and (2) performance
19:09 <sipa> erlay specifically only uses the 32-bit field
19:09 <glozow> The fields have been chosen so that some sketch algorithms work for all of our fields. However, some operations are optimized per field so that you can just say like `field.`multiply these elements or `field.`solve quadratic root.
19:09 <lightlike> Because various precomputed values are used, which are different for different-sized field
19:09 <jeremyrubin> Also i'd imagine type safety is nice
19:09 <sipa> but even for 32 bits, we have 2 or 3 different implementation of that field
19:10 <glozow> e.g. I think we have a table `QRT_TABLE_N` for each field so that during poly root finding, we can quickly look up the solution for x^2 + x = a for each element in the field? (is that right?)
19:10 <sipa> yeah, all good answers
19:10 <dkf> This is out of my domain but a thought: because due to linearity we need to be able to accumulate all the fields for certain checks?
19:10 <sipa> glozow: that's correct, but it doesn't really require fulky instanticating the full algorithm fkr every fiekd
19:11 <sipa> it coukd just have a dispatch table too that says "if field_size == 32 use this QRT table"
19:11 <glozow> ah mhm
19:11 <sipa> but yes, in general the answer is just performance
19:11 <@jnewbery> What do SQR and QRT stand for in the precomputed values?
19:11 <sipa> we get an enormous speedup from being to inline everythig
19:11 <jonatack> istm it was for optimizing for some platforms
19:12 <svav> I've been told we are talking about mathematical fields, so if anyone needs a definition https://en.wikipedia.org/wiki/Field_(mathematics)
19:12 <glozow> jonatack: I think that's the templating by implementation
19:12 <larryruane_> jnewbery: I think square root and quadratic root
19:12 <jonatack> (and chip architectures)
19:12 <sipa> larryruane_: *square* and quadraric root
19:12 <sipa> not square root
19:13 <sipa> svav: indeed
19:13 <sipa> svav: but look at the previous two meetups
19:13 <@jnewbery> How long do those precomputed values take to calculate. Could it be done at compile time?
19:13 <sipa> jnewbery: they are primarily computed ar compile time, actually :)
19:14 <sipa> only a few constants are included in the source code
19:14 <sipa> they're generated using a sage script that takes a few minutes afaik
19:14 <glozow> is this the linear transformations of the tables in fields/*.cpp?
19:14 <sipa> with c++17 we could in theory do everything at compile time, but i don't know how slow it'f be
19:14 <glozow> oh the sage script
19:15 <sipa> i guess we're on question 2 nlw
19:15 <sipa> now
19:15 <larryruane_> very productive for me learning about fields was chapter 1 of Jimmy Song's book, Programming Bitcoin
19:15 <jeremyrubin> sipa: with incremental compilation should be a one-time cost if you put it in a depends-light header
19:15 <@jnewbery> any maybe less readable/reviewable to do it using c++ metaprograming than using a sage script?
19:15 <sipa> so: If you look at the fields/*.cpp files, you will notice there are large amounts of hardcoded linear transformation tables (with code for defining them in lintrans.h. Which tables do you see, and why are they useful?
19:15 <jeremyrubin> might be worth doing so so that it's "trust minimized"
19:16 <sipa> jeremyrubin: wut
19:16 <jeremyrubin> (carry on)
19:17 <glozow> I was confused what the `RecLinTrans` part does
19:17 <sipa> ok
19:17 <glozow> but I see: A table SQR_TABLE_N gives us a map from elem a -> square of a for the field GF(2^N).
19:17 <glozow> and A table QRT_TABLE_N gives us a map from a -> x such that x^2 + x = a for the field GF(2^N).
19:17 <sipa> correct
19:17 <sipa> also correct
19:17 <sipa> there are more
19:18 <glozow> There's also SQR2_TABLE_N, SQR4_TABLE_N,
19:18 <glozow> are those ^4 and ^8 or?
19:18 <sipa> close, but no
19:18 <sipa> SQR4 is a table going x -> x^(2^4)
19:19 <sipa> i.e. squaring 4 times
19:19 <sipa> why is it possible to have a table for that?
19:20 <glozow> why it's possible, like why we can calculate them ahead of time?
19:20 <sipa> maybe a better first question: what do these tables expand to at compile time?
19:21 <sipa> i'll give the answer, it's quite abstracted away
19:21 <glozow> compiler makes a `RecLinTrans<>` of the table -> makes a 2^N size array?
19:21 <glozow> 1 slot for each element in the field?
19:22 <sipa> not a 2^N size array, that'd be a bjt big if N=64
19:22 <sipa> it creates a series of tables of size 64
19:22 <@jnewbery> I only see SQR2_TABLE, SQR4_TABLE, etc in the clmul files. Is that right?
19:22 <sipa> jnewbery: correct
19:23 <sipa> jnewbery: they're used for computing inverses
19:23 <sipa> for clmul fields, multiplication is very fast, so fermat's little theorem is used
19:23 <sipa> well, i guess FLT doesn't actually apply here because it's not modulo a prime
19:23 <jeremyrubin> Is it so that we can factor an operation into a polynomial for inverse eqt and then do simpler operations?
19:23 <jeremyrubin> is that what you're asking?
19:24 <sipa> but for every field a constant a exists such that x^a is the inverse of x
19:24 <sipa> and for clmul fields, that is used tocinvert elememts
19:24 <sipa> and the SQTn tables are used for helping with that
19:25 <sipa> they let us "skip" a whole bunch of squarings at once
19:25 <sipa> for non-clmul fields, extgcd based inverses are used
19:25 <sipa> because it appears faster to do so
19:25 <glozow> just to clarify, are the fields not the same for clmul and non-clmul?
19:26 <sipa> the fields are mostly the same
19:26 <sipa> but the implementations differ
19:26 <sipa> so back to my earlier questions about the tables
19:27 <sipa> RecLinTrans expands to a compile-time *list* of tables, each with 64 entries
19:27 <jeremyrubin> because x^a = (y*z)^a, or x^a = x^b*x^c where a = b+c? so if we can get to known factored form we already have the ops done?
19:27 <sipa> and then actual evaluation looks at groups of 6 bits of the input field element, and looks up each in a different table
19:27 <sipa> and xors them (= adding in the field?
19:28 <sipa> jeremyrubin: not quite; the answer is simply that all these operations are 2-linear operations
19:28 <jonatack> groups of 8 bits?
19:28 <sipa> jonatack: no, 6
19:29 <sipa> jeremyrubin: because in GF(2^n) it is the case that (a+b)^2 = a^2 + b^2
19:29 <jeremyrubin> ah ok; I could probably answer this by looking at the actual inverse algorithm what it factors to. Can you define "2 linear"
19:29 <sipa> jeremyrubin: can we written as a multiplication by a matrix over GF(2)
19:29 <glozow> GF(2)-linear
19:29 <jeremyrubin> sipa: that seems like an important/cool property, makes sense. sorry if this was answered in prev session
19:29 <sipa> jeremyrubin: yes
19:30 <sipa> interpret the input element as a vector of bits, apply a GF(2) square matrix, and reinterpret the result as a field element
19:30 <sipa> this can be do for anything that raises to a power that is itself a power of 2
19:30 <jonatack> sipa: 6 as is? e.g. typedef RecLinTrans<uint64_t, 6, 6, 6, 6, 6, 6, 6, 5, 5, 5> StatTable57
19:30 <jonatack> ah no nvm
19:31 <sipa> jonatack: so that specfically means the 57-bit transformation is decomposed into 7 6-bit tables and 3 5-bit tables
19:31 <sipa> and that decomposition onjy works because the transformatjkn is linear
19:32 <sipa> otherwise we'd need a table entry for every field elememt
19:32 <sipa> which would be way too large
19:32 <sipa> does tbat make.sense?
19:32 <@jnewbery> it sounds like it makes sense :)
19:32 <sipa> haha
19:33 <jonatack> sipa: yes. i'm still looking for the 6 bit input though
19:33 <jonatack> :)
19:33 <sipa> jonatack: it's all generated at compile time
19:33 <sipa> in lintrans.h
19:33 <glozow> so when we're evaluating the square of an element in the 57-bit field,
19:33 <glozow> we split it into 7 groups of 6 bits + 3 groups of 5 bits, and we look it up in the table
19:33 <sipa> indeed
19:34 <jonatack> lintrans.h : "over 3 to 8 bits"
19:34 <glozow> and then xor the answers we get from these 10 tables
19:34 <sipa> jonatack: and here specifically 6
19:34 <glozow> and that gives us the square of the element?
19:34 <sipa> se all the 6es in the type definition
19:34 <sipa> glozow: indeed
19:34 <glozow> ahhhhhhh 🧠
19:35 <sipa> the Rec stands for recursive fwiw
19:35 <jeremyrubin> oh, thought it meant rectangular XD
19:35 <sipa> because it chops off M bits (5 or 6) evaluates them, and xors with a sub table which is again RecLinTrans, but for fewer bits
19:36 <jeremyrubin> Did I miss the justification for say 6 v.s. 7 bits?
19:36 <sipa> in c++14 i think there are cleaner ways of doibg so
19:36 <jeremyrubin> Experimentally picked?
19:36 <sipa> jeremyrubin: good questiion
19:36 <sipa> indeed, experimentally decided that mkre wasn't worth it
19:36 <sipa> on a few platforms
19:37 <sipa> ok
19:37 <sipa> Why are there instances of Sketch for different fields in separate .cpp files? Could all the generic ones be merged into a single file? Could the generic ones and the clmul ones be merged?
19:37 <jeremyrubin> gotcha. and it's a pure function so if that changes it can be adapter per platform
19:39 <sipa> hint: have you tried compiling the code?
19:39 <svav> Are there different instances of Sketch to account for different processors?
19:39 <@jnewbery> Can you build a version of this that only contains the field size that you want to use?
19:39 <jeremyrubin> https://github.com/sipa/minisketch/blob/93519923665787de63310e32d1188d7cd15cb4e9/src/minisketch.cpp
19:39 <jeremyrubin> this looks non conditional?
19:39 <sipa> jnewbery: i think i had a PR for that at some point
19:40 <sipa> jeremyrubin: what do you mean?
19:40 <@jnewbery> so that's not the reason for splitting them out into different files
19:40 <glozow> so i don't think it would make sense to merge clmul and non-clmul given that you'd only use 1 based on your architecture?
19:40 <jonatack> (a) maybe, (b) no? in minisketch.cpp, the Construct functions depend on #ifdef HAVE_CLMUL, so they need to be separate
19:40 <sipa> glozow: exactly
19:40 <jeremyrubin> as in if you use minisketch.cpp it pulls in all of the definitions
19:40 <sipa> you need separate compilation flags for building clmul code
19:41 <sipa> and the resulting code *cannot* be invoked unless you knkw yiu're on a clmul-supporting platform (at runtime)
19:41 <jeremyrubin> It's still not clear to me that the single file can't also ifdef?
19:41 <lightlike> when compiling, it seemt that the different types go into different libraries e.g. (libminisketch_field_clmul.la, libminisketch_field_generic.la)
19:42 <@jnewbery> Graph 4 in https://github.com/sipa/minisketch/blob/master/README.md seems to show that clmul is faster than generic for certain field sizes and slower for others
19:42 <sipa> so it would be possible to merge all the clmul_1byte clmul_2bytes ... etc into ome
19:42 <sipa> it's just split out so building is fadter and needs less ram
19:42 <sipa> it's pretty heavy already
19:42 <sipa> but the clmul_* and generic_* ones cannot be merged
19:43 <sipa> because they're built with strictly different compilation flags
19:43 <@jnewbery> because all this template instantiation use a lot of memory to compile?
19:43 <sipa> jnewbery: yeah, end user code should benchmark what is fastest
19:43 <sipa> jnewbery: indeed
19:44 <glozow> if you can use CLMUL implementation, why do you need both the CLMUL and CLMULTRI implementation for a field that has a `x^b + x^a + 1` modulus?
19:44 <sipa> glozow: either may be faster
19:44 <sipa> depending on tje hardware
19:45 <sipa> they're different algorityms and it's hard to say which one is faster when
19:45 <glozow> ah, okay
19:45 <sipa> i think for some fields it is clear, and those lack a CLMUL one
19:45 <@jnewbery> what would the advantage of just compiling just for a single field size? Smaller binary because of the precomputed tables and different template instantiations? Faster build? Anything else?
19:46 <sipa> jnewbery: API pain
19:46 <sipa> my goal is adding support for that
19:46 <sipa> but first adding a generic slow field implementation that works for all field sizes
19:46 <sipa> so that you don't get a library which doesn't support part of the functionality
19:47 <sipa> e.g. if used as a shared library
19:47 <sipa> so then it becomes a compile-time choice which fields to include optimozed implementations for
19:47 <sipa> rather than which ones to support at all
19:48 <sipa> Do you notice any optimizations in sketch_impl.h that weren’t present in the Python code?
19:49 <glozow> question: Why isn't this `const T* QRT` instead of `const F* QRT`? https://github.com/sipa/minisketch/blob/f9540772fac3c1e840208db8c3fe6894526ec1da/src/fields/generic_common_impl.h#L19
19:49 <glozow> I only saw the obvious one, L140 in the root-finding: for deg2 polynomials, direct quadratic solver -> calls `field.Qrt(input)`
19:50 <jonatack> from the last session: https://bitcoincore.reviews/minisketch-26-2#l-225 
19:50 <glozow> yeah, i used sipa's hint from last review club heh
19:50 <sipa> glozow: great question
19:51 <sipa> the size of runtime tables is different frkm compile-time tables
19:51 <sipa> these lookup tables are also created at runtime
19:51 <sipa> e.g. when there are muktiple multiplications with the same value
19:51 <sipa> then we preprocess that value into a lookup table
19:51 <glozow> oh is that why they're called StatTable vs DynTable?
19:52 <sipa> because multiplication with a constant is also linear
19:52 <sipa> indeed
19:52 <glozow> oooooooh
19:52 <sipa> and the DynTable uses smaller lookup tables
19:52 <sipa> 4 bit iirc
19:52 <sipa> instead of 6 bits
19:52 <sipa> also experimentally determined
19:53 <sipa> glozow: and yes, the direct quadratic solver is what i was goibg for in this question
19:53 <sipa> another possible answer is of course all the lookup tables
19:54 <sipa> What is tested in test-exhaust.cpp? This may be clearer if you look at PR #33.
19:55 <jonatack> agree, the new test file is much clearer afaict
19:55 <sipa> yeah the old one was really unfinished
19:55 <sipa> (and clearly missed some bugs...)
19:56 <jonatack> iterating on things really works
19:56 <@jnewbery> If the answer to your question isn't "everything", then the file is misnamed
19:56 <sipa> it is also bekng rebamed in #33
19:56 <sipa> being renamed
19:56 <svav> Forgive the basic question, but is the reason for all this Minisketch stuff just to add efficiency to Erlay? Is it involved in more fundamental cryptographic calculations for Bitcoin?
19:57 <sipa> svav: it is the implementation of the sketch algorithm used by erlay
19:57 <sipa> that's it
19:57 <@jnewbery> svav: https://bitcoincore.reviews/minisketch-26 and https://bitcoinops.org/en/topics/erlay/
19:57 <lightlike> svav: It is an integral part of Erlay, it doesn't add efficiency to it. Erlay adds efficiency to transaction relay.
19:57 <sipa> it's not "adding" efficiency; it is literally judt *the* implementation used for the sketching
19:58 <sipa> it is of course a highly optimized implementation, so that it ks efficient enough to be practically usable
19:58 <jonatack> sipa: before time is over, i'm keen to hear the answers to the last two questions
19:58 <svav> Thanks for the clarification
19:58 <sipa> For every field implementation Field there is a member type Field::Elem (which for all current fields is just an integer type), and invoking field operations goes through Field (e.g. multiplying two field elements a and b is done through field.Mul(a,b). A more intuitive design would be to make Field::Elem a separate class for each field, with its own member functions for finite field
19:58 <sipa> arithmetic (so that the above could be done...
19:59 <sipa> simply using a*b for example). Any idea why this approach is not used?
19:59 <glozow> any thoughts of f u z z ing the minisketch code? heh
19:59 <sipa> i'll just give the andwer
19:59 <sipa> if we'd do that, you'd get vectors with different types for every field
19:59 <michaelfolkson> Running a bit low on time so random question. Are there any specific code segments (C++) that demonstrate the speed and memory efficiency of the C++ code over the Python code segment and would be worth analyzing?
20:00 <glozow> i figured you'd need the tables to be static since they're field-wide
20:00 <@jnewbery> sipa: I've got to run now, but I'm curious is there's anything people here can do to help progress this? Would it help if someone opened the PR to add this to the Bitcoin Core repo?
20:00 <sipa> you'd have vector<FieldCLMul32> and vector<FieldGeneric22> etc
20:00 <jonatack> haaaah
20:00 <sipa> and all that vector code, along with all suppoting functions, woukd be ~1 MB of executable code
20:01 <sipa> with the vurrent approach they're all just std::vdctor<uint64_t>
20:02 <sipa> Bonus question: what is special about field size 58 (look at fields/clmul_8bytes.cpp)?
20:02 <sipa> jnewbery: i'm planning to PR it soon (after #33 and maybe a few follow-ups?
20:02 <glozow> sipa: is it specific to 58 only or are there other field sizes with the special property?
20:03 <@jnewbery> LOAD_TABLE/SAVE_TABLE ?
20:03 <sipa> glozow: for larger fields than 64 bit there would be more with this property
20:03 <@jnewbery> https://github.com/sipa/minisketch/blob/53757f736d4e75faf6c4127e8fb452b6a69c4626/src/fields/clmul_8bytes.cpp#L33-L34
20:03 <sipa> but so far, only 58 has it
20:04 <jonatack> jnewbery: indeed
20:04 <sipa> jnewbery: yes, LOAD/SAVE
20:04 <sipa> yet another answrr to question 2?
20:04 <sipa> jnewbery: what do those do?
20:05 <jonatack> conversion tables?
20:05 <sipa> indeed
20:05 <sipa> convert from/to what?
20:06 <jonatack> something about bistream modulus for the impl
20:06 <sipa> yeah
20:06 <svav> Something to do with StatTableTRI58 ???
20:06 <jonatack> gen_params.sage#L252
20:06 <glozow> oh different modulus but isomorphic? so you're permuting the elements?
20:07 <sipa> so what is happening here is that for field size 58 there exists a trinomial (x^58 + x^a + 1) irreducble modulis
20:07 <sipa> which is used for clmultri
20:07 <sipa> but there is also another modulus, which is shorter
20:07 <sipa> and the other field implementation uses that one
20:07 <sipa> yet, we want a stable API
20:08 <sipa> which consistently interprets bits on the wire the same way, regardless of imllementation
20:08 <glozow> and we want both because it's not clear which one would be faster?
20:08 <sipa> indeed
20:08 <sipa> but even if not, the API specifies the interpretation used publicly
20:09 <jonatack> thanks!
20:09 <sipa> if we"d for whatever reason decide to ise a different represnetation internally, we need to convert
20:09 <sipa> and why is thjs worth it? we do quadratically many operations internally
20:09 <sipa> but only linear work for conversion
20:10 <sipa> this was a surprising discovery for me that this conversion was so cheap (just another linear transformation)
20:10 <glozow> i gotta run but thank you sipa!!! peak nerd snipe
20:11 <sipa> i'm done as well
20:11 <jonatack> 👏👏👏
20:11 <sipa> thank you all for coming!
20:11 <svav> Thanks
20:11 <jesseposner> Thanks!
20:11 <larryruane_> thank you for presenting, sipa! really interesting!
20:11 <lightlike> Thanks!
20:11 <wiscojabroni> thanks!
20:11 <jeremyrubin> thanks!
20:12 <sipa> and apologies for the many typos, i"m a bit restricted right nlw
20:12 <jonatack> fantastic sesson, thank you sipa
20:12 <sipa> yw
{% endirc %}
