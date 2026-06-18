# The Arithmetic of Gluing: How Error-Correcting Codes Mirror the Shapes of Space

## A puzzle about putting things together

Imagine you have two perfect objects and you want to glue them into one. A
recurring miracle of mathematics is that *perfection often survives gluing*. If
you take two flawless crystals and fuse them edge to edge, sometimes the result
is a single, larger, equally flawless crystal. Sometimes it is not. Knowing in
advance which "perfect" properties are preserved by gluing — and which are
destroyed — is one of the deepest organizing principles in modern mathematics.

This article is about a precise and beautiful instance of that principle, one
that ties together three fields that, at first glance, have nothing to do with
one another:

- **The shape of four-dimensional space.** Topologists classify spaces by an
  algebraic fingerprint called the *intersection form*. Gluing two spaces
  together (the "connected sum") combines their fingerprints.
- **Crystal lattices and sphere packing.** The densest known ways to stack
  spheres in high dimensions come from exquisitely symmetric lattices, the most
  famous being the eight-dimensional lattice called **E8**.
- **Error-correcting codes.** The digital messages sent by your phone, by deep
  space probes, and by every CD ever pressed are protected by codes — clever
  sets of binary strings engineered so that errors can be detected and undone.

The thread connecting all three is a single, sharp number: **eight**. And the
operation connecting all three is **gluing**. What follows is the story of how a
property called *self-duality* — the mathematical signature of perfection in all
three worlds — behaves when you glue, and why a humble length-8 code is the exact
shadow of the magnificent E8 lattice.

## Codes as geometry

Let us start concretely. A **binary code** of length *n* is just a collection of
strings of 0s and 1s, each of length *n*. The strings in the collection are
called **codewords**. For example,

```
0000   1100   0011   1111
```

is a code of length 4 with four codewords.

Two numbers tell you almost everything about how a codeword behaves:

- The **weight** of a codeword is the number of 1s it contains. The weight of
  `1100` is 2; the weight of `1111` is 4.
- The **inner product** of two codewords counts the positions where *both* have
  a 1, then records whether that count is even (call it 0) or odd (call it 1).
  The inner product of `1100` and `0011` is 0 (they never share a 1); the inner
  product of `1100` and `1010` is 1 (they share exactly one position).

This "inner product" is the same dot product you met in geometry, but reduced
modulo 2. It lets us speak of codewords being **orthogonal** (inner product 0),
exactly as vectors can be perpendicular. And just as in geometry, we can ask for
the set of all vectors orthogonal to everything in our code — its **dual code**.

A code is called **self-dual** when it is *equal to its own dual*: every codeword
is orthogonal to every codeword (including itself), and conversely, any string
orthogonal to the whole code is already a codeword. Self-duality is a stringent,
beautiful balance condition. It forces the code to contain exactly the square
root of all possible strings — for length *n*, a self-dual code has exactly
2^(n/2) codewords, perfectly poised between too few and too many.

There is one more refinement. A codeword is **doubly even** if its weight is a
multiple of 4. A code is doubly even if *all* its codewords are. Double-evenness
is the combinatorial echo of a geometric condition called "evenness" on a
lattice, which in turn is the echo of a topological condition called "spin" on a
manifold. These are the three faces of the same coin.

## The headline code: the extended Hamming [8,4,4]

The star of our story is the **extended Hamming code** of length 8. It is built
from a small generator: four basis codewords whose combinations (there are
2^4 = 16 of them) form the whole code. Written out, its generator rows are

```
11111111
00001111
00110011
01010101
```

Every one of the 16 codewords you can build by adding subsets of these rows
(modulo 2) turns out to have weight 0, 4, or 8. Precisely:

- **1** codeword of weight 0 (the all-zeros string),
- **14** codewords of weight 4,
- **1** codeword of weight 8 (the all-ones string).

That accounts for all 16, and it can be summarized in a single polynomial called
the **weight enumerator**:

> **1 + 14·x⁴ + x⁸.**

Because every weight is a multiple of 4, the code is **doubly even**. Because the
generator rows are mutually orthogonal and there are exactly 16 = 2^(8/2)
codewords, the code is **self-dual**. And the smallest weight of any nonzero
codeword — the **minimum distance** — is 4, which is what lets the code correct
errors. These three facts give it its name: an `[8, 4, 4]` code (length 8,
dimension 4, minimum distance 4).

This little code is not just a useful gadget for telecommunications. It is the
**mod-2 shadow of the E8 lattice**. Through a classical recipe called
*Construction A*, you can build a lattice in 8-dimensional space directly from
this code; doing so reproduces E8, the densest sphere packing in dimension 8 and
one of the most symmetric objects in all of mathematics. The properties of the
code translate, line for line, into properties of the lattice:

| Code property                | Lattice property            |
|------------------------------|-----------------------------|
| self-dual                    | unimodular (self-dual)      |
| doubly even                  | even                        |
| length divisible by 8        | rank divisible by 8         |

## The miracle of eight

Here is the first deep theorem of our story, classically due to Gleason:

> **Gleason's Length Theorem.** *Every binary doubly-even self-dual code has
> length divisible by 8.*

This is a genuine miracle. There is no obvious reason a balance condition
(self-duality) together with a divisibility condition (doubly even) should
conspire to force the *length* of the code to be a multiple of 8. Yet it does,
always, with no exceptions.

The proof is a jewel of classical analysis dressed in combinatorial clothing. To
each codeword *x* one attaches the complex number **i^(weight of x)**, where
*i* is the imaginary unit (i² = −1). Summing this quantity over all strings, and
then summing again over the code, can be done in two completely different ways.
One way uses *character orthogonality* — the fact that, for a self-dual code, the
"sign sums" ∑(−1)^(inner product) collapse neatly to either the size of the code
or to zero. The other way factors the sum coordinate by coordinate, producing a
clean power of (1 + i). Setting the two evaluations equal yields a master
identity of startling economy:

> **(number of codewords) = (1 + i)ⁿ.**

Now comes the punchline. The left side is a *positive whole number*. The right
side is a complex number marching around the plane: the powers of (1 + i)
rotate by 45° each step and grow in size, returning to the positive real axis
only every **eight** steps, because (1 + i)⁸ = 16 while (1 + i)⁴ = −4 is
negative. For a positive integer to equal (1 + i)ⁿ, the exponent *n* must be a
multiple of 8. The period of a spiral in the complex plane becomes a hard
divisibility law about codes. That is the kind of bridge mathematicians live
for.

Applied to the extended Hamming code, the theorem instantly recovers the fact
that its length, 8, is divisible by 8 — not by inspecting all 256 candidate
strings, but as a special case of a universal law.

## The real story: what happens when you glue

The Hamming code is one perfect crystal. What if we want a bigger one? The most
natural way to combine two codes is **concatenation**: take a codeword *a* from a
code *C* (of length *m*) and a codeword *b* from a code *D* (of length *n*), and
glue them end to end into a single string *ab* of length *m + n*. The collection
of all such gluings is the **direct sum** of the two codes, written **C ⊕ D**.

This is the exact code-side mirror of gluing two manifolds with a connected sum,
or stacking two lattices into a block-diagonal pile. The central question of this
work is simple to state and delightful to answer:

> *Which properties of perfect codes survive concatenation?*

The answer is that **all of them do**, and the reasons are remarkably
transparent. Here are the closure theorems, each proved for codes of arbitrary
length.

**Weight is additive.** Gluing *a* and *b* simply puts their 1s side by side, so
the weight of the concatenation is the sum of the weights:

> weight(ab) = weight(a) + weight(b).

**The inner product is block-diagonal.** When you compare two glued codewords
*ab* and *cd*, the left halves only interact with left halves and right halves
only with right halves. There is no cross-talk:

> ⟨ab, cd⟩ = ⟨a, c⟩ + ⟨b, d⟩.

This single fact — that gluing introduces no interference between the blocks — is
the engine behind everything that follows. It is the combinatorial shadow of the
*block-diagonal* shape of a glued lattice's defining matrix, where the two
summands sit in separate corners and the off-diagonal blocks are zero.

**The count multiplies.** Since every pair (*a*, *b*) gives a distinct glued
codeword, the number of codewords in C ⊕ D is the product of the two counts:

> |C ⊕ D| = |C| · |D|.

This is the code-theoretic echo of the fact that the "volume" invariant
(the determinant) of a glued lattice is the product of the summands' volumes.

**Double-evenness survives.** If every codeword of *C* has weight divisible by 4,
and likewise for *D*, then because weight is additive, every glued codeword has
weight divisible by 4 too. Doubly even ⊕ doubly even = doubly even.

**Self-duality survives — the headline.** This is the deepest of the closure
theorems:

> **If C and D are each self-dual, then C ⊕ D is self-dual.**

One direction is easy: if *a* is orthogonal to all of *C* and *b* to all of *D*,
then by the block-diagonal formula, *ab* is orthogonal to every glued codeword.
The subtle direction is the converse — showing that *anything* orthogonal to the
whole glued code must actually be a legitimate concatenation of a *C*-word and a
*D*-word. The trick is elegant: because a self-dual code always contains the
all-zeros word, you can probe one block at a time. To test whether the left half
of a mystery vector lives in *C*, pair it with glued codewords of the form
"(*C*-word) followed by (all zeros)" — the right block contributes nothing, and
the left block is forced to satisfy exactly the orthogonality condition that
defines membership in *C*. The same trick with zeros on the left isolates the
right block. The zero vector becomes a precision instrument for examining each
half independently.

**Divisibility by 8 is additive.** Stacking these results: if *C* and *D* are
both doubly even and self-dual, so is C ⊕ D, and Gleason's theorem then applies
to the whole. Concretely, the length of C ⊕ D is divisible by 8 whenever the
lengths of *C* and *D* are. The "miracle of eight" is stable under gluing.

## The grand finale: E8 ⊕ E8

Now we can build something genuinely impressive without breaking a sweat. Take
two copies of the extended Hamming code and glue them:

> **Hamming ⊕ Hamming**

The result is a length-16 code. Without examining a single one of its 2^16 =
65,536 candidate strings by brute force, the closure theorems tell us everything:

- It is **self-dual** (self-duality survives gluing).
- It is **doubly even** (double-evenness survives gluing).
- It has exactly **256 = 16 · 16** codewords (counts multiply).
- Its length, **16**, is **divisible by 8** (divisibility is additive, via
  Gleason).

This length-16 code is the precise mod-2 shadow of the rank-16 lattice
**E8 ⊕ E8** — two copies of E8 stacked together. And here the story takes a final
twist that reaches all the way back to topology.

In dimension 16, there are exactly *two* even unimodular lattices: the glued one,
E8 ⊕ E8, and a second, genuinely indivisible lattice called D16⁺. The two cannot
be told apart by their "volume" or their evenness or their rank — yet one is a
connected sum and the other is irreducibly whole. On the code side, this is
mirrored by two doubly-even self-dual length-16 codes with the *same* weight
enumerator but different internal symmetry: one factors as Hamming ⊕ Hamming, and
one stubbornly refuses to factor at all. The drama of decomposability — whether a
perfect object is secretly two smaller perfect objects glued together — is
visible in the code, the lattice, and the manifold simultaneously.

## Why this matters

There is a temptation to view error-correcting codes as mere engineering and the
E8 lattice as mere ornament. The truth is the opposite: they are the same idea
seen from two heights. The combinatorial fact that gluing two Hamming codes
preserves self-duality is, line for line, the geometric fact that the connected
sum of two perfect manifolds preserves Poincaré duality. The number 8 that
governs the existence of even unimodular lattices is the same 8 that governs the
length of doubly-even self-dual codes — and both descend from a single spiral in
the complex plane making a full turn back to the positive real axis.

When you glue two perfect things, the imperfections you fear never appear,
because the inner product is block-diagonal: the two halves never interfere. That
single sentence is the heart of the matter. It explains why connected sums of
spin manifolds are spin, why orthogonal sums of even unimodular lattices are even
unimodular, and why concatenations of doubly-even self-dual codes are
doubly-even self-dual. Perfection, it turns out, is contagious — provided you
glue along the diagonal.
