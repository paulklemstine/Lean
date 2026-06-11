# The Arithmetic of "Too Few Codes": Why Shallow Machines Can Never Say Enough

Imagine you run a tiny publishing house whose entire catalog consists of
numbered cards. Card 0, card 1, card 2, and so on, up to some last card.
Each card carries exactly one picture. A customer walks in and asks for a
specific picture — say, a photograph of their grandmother. You can only sell
it if one of your cards happens to carry that exact image.

Now suppose you make a promise to your customers: *"You will never have to
flip past card number k."* Every picture worth having, you claim, sits on one
of the first few cards. It is a comforting promise. It is also, as we are about
to see, a mathematical impossibility the moment the world contains more
pictures than you have low-numbered cards.

This little parable is the whole story of a deep and ancient idea in computer
science — **incompressibility** — stripped down to its bare, finite skeleton.
The results below are exact, provable, and surprisingly sharp. They tell us
something permanent about the limits of short descriptions, shallow circuits,
small machine-learning models, and compressed files. And every one of them
follows from a single childlike observation: *you cannot point at more things
than you have fingers.*

## What is a "description," really?

Strip away the romance of computation and you are left with a humble object:
an **encoder**. An encoder is just a function that turns short labels into
things. Type a short code, get an output. A ZIP file is an encoder: feed it the
compressed bytes, out comes your document. A neural network is an encoder: feed
it weights, out comes a function. A circuit family is an encoder: feed it a
wiring diagram, out comes a Boolean function.

Let us be precise but gentle. Suppose there are `N` possible codes, numbered
`0, 1, 2, …, N−1`. An encoder `E` assigns to each code number `i` some output
`E(i)` living in a universe of objects we'll call `α`. The objects could be
images, numbers, functions, DNA strings — it does not matter.

We now define the **description complexity** of an object `x` to be the
*smallest code number that produces it*. If the smallest code that yields your
grandmother's photo is code number 5, then her photo has description complexity
5. If no code produces it at all, her photo is — relative to this encoder —
literally indescribable.

Formally, we say `x` **has description complexity at most k** when there exists
a code `i` with `i ≤ k` such that `E(i) = x`. In symbols:

> `x` has description complexity ≤ k  ⟺  ∃ i ≤ k with `E(i) = x`.

This is the finite, concrete cousin of *Kolmogorov complexity*, the celebrated
notion that measures the length of the shortest program that prints a given
string. Kolmogorov complexity lives in the infinite world of Turing machines
and is famously uncomputable. Our version lives in a finite world of numbered
cards — and everything about it is not only computable but provable down to the
last detail.

## The counting bound: the bottleneck nobody can widen

Here is the first theorem, and in a sense it is the only one — everything else
is a variation on its theme.

> **Counting Bound.** For any encoder `E` and any budget `k`, the number of
> *distinct* objects reachable by codes of index at most `k` is at most `k + 1`.

Why `k + 1` and not `k`? Because the codes `0, 1, 2, …, k` number exactly
`k + 1` of them — we count starting from zero, the way computers do. That is
the entire content. There are only `k + 1` low-numbered cards, so they can show
at most `k + 1` different pictures. If two cards happen to carry the same
picture, you get *fewer* distinct pictures, never more.

It sounds almost too obvious to dignify with the word "theorem." But notice how
much it forbids. It does not care how clever your encoder is. It does not care
whether `E` is a state-of-the-art compression algorithm or a random scribble.
It does not care how vast the universe `α` of possible objects is. **No
encoder, however ingenious, can make `k + 1` codes describe `k + 2` distinct
things.** The bottleneck is in the *number of codes*, and no amount of
cleverness widens it.

## Incompressibility: someone always gets left out

Turn the counting bound around and you get its more dramatic twin.

> **Incompressibility Principle.** If a collection `S` contains more than `k + 1`
> objects, then at least one object in `S` cannot be produced by any code of
> index at most `k`.

This is the rigorous version of the slogan every computer scientist has heard:
**"most things are incompressible."** If you have a million distinct files but
only a thousand short codes, then no matter how you assign codes, at least one
file — in fact, the overwhelming majority of them — must be left without a short
code. There simply are not enough short codes to go around. The pigeons
outnumber the holes.

The proof is a single, elegant move. Suppose, to the contrary, that *every*
object in `S` did have a short code. Then `S` would be contained in the set of
short-code outputs — but we just proved that set has at most `k + 1` elements.
So `S` would have at most `k + 1` elements, contradicting our assumption that it
has more. The contradiction forces some object to be indescribable. Clean,
final, no escape.

A second version of this says the same thing about an *entire finite universe*:
if the universe `α` itself contains more than `k + 1` objects, then for any
encoder whatsoever, some object of `α` has no short code. Incompressibility is
not a quirk of badly chosen examples; it is a law of arithmetic.

## Collisions: when the world is too small, codes must repeat

The third theorem flips the lens. Instead of asking "are there enough codes for
the objects?", it asks "are there too many codes for the objects?"

> **Collision Theorem.** If the universe `α` has fewer than `k + 1` objects, and
> we have at least `k + 1` codes available, then two *different* codes among the
> first `k + 1` must produce the *same* output.

This is the pigeonhole principle wearing its work clothes. If you have more
pigeons (codes) than holes (objects), two pigeons share a hole — two codes
collide on one output. In the language of hashing, you cannot avoid collisions
once you try to fit more keys than there are buckets. In the language of
cryptography, this is exactly why hash functions that compress data *must* have
collisions, the seed of every "birthday attack."

So our finite toolkit captures both sides of the descriptive ledger at once. Too
many objects and too few codes? Someone is indescribable. Too few objects and
too many codes? Codes must repeat. Either way, the arithmetic is merciless.

## The binary version: counting in bits

Real machines do not number their codes `0, 1, 2, …`; they spell them out in
bits. A description of length `k` bits is a string of `k` zeros and ones, and
there are precisely `2^(k+1) − 1` binary strings of length *at most* `k`
(adding up `1 + 2 + 4 + … + 2^k`). Plug that number in where we wrote `N`, and
the counting bound becomes the classical statement that launched a thousand
lower-bound proofs:

> **Kolmogorov-Style Bound.** At most `2^(k+1) − 1` objects can have a
> description of bitlength at most `k`.

The general principle behind it is even simpler than the counting bound: the
number of distinct outputs of *any* encoder with `M` codes is at most `M`. An
encoder cannot produce more distinct things than it has inputs. And its mirror
image:

> **Binary Incompressibility.** If the universe has more than `M` objects, then
> some object is not in the encoder's range at all — it has no code of length
> ≤ k whatsoever.

This is why you cannot write a lossless compressor that shrinks *every* file.
There are only so many short files; if your compressor mapped every long file to
a distinct short one, you would be claiming more short files exist than actually
do. Some file must grow. The dream of universal compression dies on the same
arithmetic that started this article: you cannot point at more things than you
have fingers.

## Why this matters far beyond cards and codes

It is tempting to dismiss all this as combinatorial bookkeeping. It is anything
but. The same counting skeleton, dressed in different costumes, underlies some
of the most important impossibility results in all of computer science.

**Circuit lower bounds.** Think of `E` as a catalog of shallow circuits, indexed
by their wiring. The counting bound says a depth-bounded family with only `k + 1`
configurations can realize at most `k + 1` distinct Boolean functions. Want to
compute a *zoo* of distinct functions? Then your circuit catalog must itself be
large. This is the seed of the entire field of circuit complexity: you cannot get
representational richness for free.

**Machine learning.** Let `E` be a learning algorithm that, given a short
description (a hypothesis index, a compressed model), outputs a predictor. A
hypothesis class describable in few bits contains few hypotheses. This is the
arithmetic heart of **Occam's razor** and **sample compression bounds**: simple
models — those with short descriptions — are necessarily few in number, which is
exactly why they generalize. Complexity that can be written down briefly cannot
be that complex.

**Cryptography.** A "random" secret living in a huge space is, by the
incompressibility principle, almost surely *not* the output of any small
encoder. That is what it means for a key to have genuine entropy: no short
recipe reproduces it. And the collision theorem is the reason secure hash
functions must, in principle, admit collisions — the security rests on those
collisions being *hard to find*, not on their being absent.

**Everyday compression.** Every time your phone tells you a file "cannot be
compressed further," it is brushing up against binary incompressibility. The file
already sits near the bottom of its descriptive barrel, and there is no shorter
code left to assign it.

## The beauty of the finite

What is remarkable about this collection of theorems is not their difficulty —
each proof is a single clean step — but their **certainty and reach**. Classical
Kolmogorov complexity is haunted by uncomputability: you can never actually
calculate the shortest description of a given string. Here, by retreating to the
finite world of numbered codes, we lose nothing essential and gain everything
concrete. The bounds are exact. The witnesses are explicit. The collisions are
guaranteed. Every claim is the kind a careful skeptic could check by hand on a
small example and trust forever on a large one.

The grand lesson is one of humility for our machines and clarity for our minds.
A description is a finite resource. Codes are countable. And once you count them,
the limits of what can be said, computed, compressed, or learned with a bounded
budget are not matters of engineering skill or future progress — they are
matters of arithmetic, fixed for all time the moment you decide how many cards
your catalog will hold.

You cannot point at more things than you have fingers. Everything else is a
corollary.
