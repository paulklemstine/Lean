# When Composition Loops Back: The Hidden Rhythm of Tensor Powers

## A machine that keeps multiplying itself

Imagine a machine that does only one thing: it takes whatever you give it and
glues a fixed object `X` onto the front. Feed it nothing — the empty bundle — and
it hands you back `X`. Feed it `X`, and you get `X` next to `X`. Feed *that* back
in, and you get three copies. Keep going, and you build a tower:

```
nothing,  X,  X·X,  X·X·X,  X·X·X·X,  ...
```

Each rung of the tower is a "tensor power" of `X`. In ordinary arithmetic, this
is just exponentiation: if `X` were the number 2, the tower would read
1, 2, 4, 8, 16. The tower only grows; it never comes back to where it started.

But objects in mathematics are richer than numbers, and "the same" is a subtler
idea than "equal." Two structures can be built from different parts and yet be
*indistinguishable* — interchangeable in every way that matters. When that
happens we say they are **isomorphic**. And once you allow yourself to say "this
rung looks exactly like that earlier rung," the tower can do something a column of
numbers never could: **it can loop back on itself.**

This article is about that loop — about what happens when a process of endless
self-composition quietly returns to an earlier state. It is a story that touches
the symmetries of physics, the periodic table of particle "charges," and the
deep idea that a system evolving forever in time might nonetheless be closed,
self-consistent, and finite. The mathematics that makes it precise lives in a
setting called a **monoidal category**, and the punchline is a clean,
fully verified set of theorems about when — and how — composition loops back.

## The stage: a world with a way to combine things

To tell the story we need a place where "gluing two things together" is a
first-class operation. Mathematicians call such a place a **monoidal category**.
It sounds technical, but the idea is everyday.

A monoidal category is a collection of *objects* together with a way to combine
any two of them into a new object. We write the combination of `A` and `B` as
`A ⊗ B` and read it "A tensor B." There are three ground rules, each of which is
something you already believe about combining things:

1. **There is a neutral object**, written `𝟙` (the "unit"). Combining anything
   with the unit changes nothing: `𝟙 ⊗ A` and `A ⊗ 𝟙` are both
   indistinguishable from `A`. (Think of `𝟙` as the empty bundle, or the number
   1, or doing nothing.)

2. **Regrouping doesn't matter.** Whether you combine `A` with `B` first, or
   `B` with `C` first, the result is indistinguishable: `(A ⊗ B) ⊗ C` looks
   exactly like `A ⊗ (B ⊗ C)`.

3. **These "looks exactly like" statements are not sloppy.** Each one is a
   genuine, named isomorphism — a precise dictionary translating one side into
   the other — and the dictionaries are required to fit together consistently.

That third rule is the secret ingredient, and it is exactly the "controlled
failure" this project is named for. In a monoidal category, regrouping a product
does *not* give you literally the same object on the nose. `(A ⊗ B) ⊗ C` and
`A ⊗ (B ⊗ C)` are typically different objects that happen to be isomorphic via a
canonical translator called the **associator**. Composition "loops back" not to
the identical thing, but to a faithful copy of it. This is the categorical version
of a causal loop: a process that returns you not to the literal past, but to a
state perfectly consistent with it.

Concrete examples of monoidal categories are everywhere:

- **Vector spaces**, with `⊗` the tensor product and `𝟙` the one-dimensional
  line of scalars. This is the language of quantum mechanics, where combining two
  systems means tensoring their state spaces.
- **Representations of a symmetry group** — the mathematical home of a particle's
  "charges." Combining two particles tensors their representations, and the
  Clebsch–Gordan rules of physics are statements about how those tensor products
  decompose.
- **Sets**, with `⊗` the Cartesian product and `𝟙` a one-element set.
- **Endless others**: chain complexes, modules, bundles, cobordisms (the arena of
  topological quantum field theory), and the string diagrams of quantum
  computing.

In every one of these worlds, our self-multiplying machine makes sense. Pick an
object `X` and start stacking.

## The tower, precisely

Let us name the rungs. Write `Xⁿ` for the `n`-fold tensor power of `X`, built
right-to-left:

- `X⁰ = 𝟙` (zero copies is the empty bundle, the unit),
- `Xⁿ⁺¹ = X ⊗ Xⁿ` (one more copy is `X` glued onto the front of the previous
  rung).

So `X¹ = X ⊗ 𝟙`, which is indistinguishable from `X` itself; `X² = X ⊗ (X ⊗ 𝟙)`;
and so on. The first genuinely useful fact about this tower is that **the
exponent rule survives the passage to objects**:

> **The Addition Law.** For any object `X` and any whole numbers `m` and `n`,
> the rung `Xᵐ⁺ⁿ` is isomorphic to `Xᵐ ⊗ Xⁿ`.

In symbols, `Xᵐ⁺ⁿ ≅ Xᵐ ⊗ Xⁿ`. This is the categorical echo of the schoolbook
identity `xᵐ⁺ⁿ = xᵐ · xⁿ`. It is not free: because our tower is built
right-associated, proving it requires carefully walking up the ladder and using
the associator to re-bracket the product at each step, while the unitor handles
the base case. But once established, it is the workhorse behind everything that
follows. It says the tower behaves like a faithful, structured exponential — the
arithmetic of exponents lifts intact into the world of objects.

## The loop: periodicity

Now to the heart of the matter. We say `X` **has a period `d` starting at `m`**
if some later rung is indistinguishable from an earlier one separated by exactly
`d` steps:

> `Xᵐ ≅ Xᵐ⁺ᵈ`.

Think of it as the tower catching its own tail: rung `m` and rung `m + d` are
interchangeable. We call `d` a **period** of `X` if `d` is a positive number and
such a coincidence happens at *some* starting point `m`. And we call `X`
**periodic** if it has any positive period at all.

When does this happen? In plain arithmetic, never — powers of 2 march off to
infinity and never repeat. But objects are not numbers, and repetition is common:

- If `X` is the unit object `𝟙` itself, then *every* rung is `𝟙`, so it has
  period 1, trivially.
- In the representation category of a finite cyclic symmetry, the "charges"
  literally cycle. An object can satisfy `X³ ≅ 𝟙 = X⁰`, exactly the
  three-fold periodicity of, say, the colour charges or the cube roots of unity.
- In any world where there are only finitely many distinct objects up to
  isomorphism — a *finite* monoidal category — the tower has nowhere infinite to
  go. With infinitely many rungs but finitely many possible values, two rungs
  must eventually coincide. The tower is **forced** to loop.

That last observation is worth pausing on. It is the categorical pigeonhole
principle, and it captures a genuinely physical intuition: **a system with a
finite number of states that evolves by repeating the same operation must, sooner
or later, return to a state it has already visited.** Once it does, it is trapped
in a cycle forever. This is precisely the logic of a closed timelike curve in
physics — a universe of finitely many configurations cannot escape its own past;
it loops, self-consistently, with some definite period. Our tower is a clean
algebraic model of exactly that phenomenon.

## The central theorem: a loop, once found, is everywhere

Here is the most striking result in the story, and the one the whole development
is organized around. Suppose you have spotted a loop at one particular height of
the tower — a witness that `Xᵐ ≅ Xᵐ⁺ᵈ`. A natural worry: maybe this is a fluke of
that particular rung. Maybe higher up the tower, the coincidence evaporates.

It does not. The loop is contagious.

> **Shift Invariance (the central theorem).** If `Xᵐ ≅ Xᵐ⁺ᵈ`, then for *every*
> additional height `k`, we also have `Xᵐ⁺ᵏ ≅ Xᵐ⁺ᵏ⁺ᵈ`.

In words: **a period found at one height is a period at every greater height.**
Once the tower has caught its tail, it stays caught all the way up. The reason is
beautifully simple. Suppose you already know `Xᵐ⁺ᵏ ≅ Xᵐ⁺ᵏ⁺ᵈ`. Glue one more copy
of `X` onto the front of *both* sides — an operation that always preserves
indistinguishability — and you get `X ⊗ Xᵐ⁺ᵏ ≅ X ⊗ Xᵐ⁺ᵏ⁺ᵈ`, which is to say
`Xᵐ⁺ᵏ⁺¹ ≅ Xᵐ⁺ᵏ⁺¹⁺ᵈ`. You have climbed one rung and the loop came with you. Start
from the original witness at height `m` and repeat: the loop propagates upward
forever.

This single, clean inductive idea — *tensor the isomorphism on the left by `X`* —
is the engine of the entire theory. It immediately gives a useful corollary:

> **Loops live arbitrarily high.** If `X` has period `d`, then for any target
> height `k` you can find a witness of period `d` starting *at least* as high as
> `k`. The looping behaviour is not confined to the bottom of the tower; it
> pervades the whole infinite ladder.

And it gives the most user-friendly entry point to the theory:

> **How to detect periodicity.** If you can find *any* two distinct heights
> `m < n` with `Xᵐ ≅ Xⁿ`, then `X` is periodic — with period exactly `n − m`.

So you never have to hunt for the elusive "starting point" of a loop. Any single
coincidence anywhere in the tower, between any two rungs, certifies that the
whole tower is periodic and pins down the period as the gap between them.

## The fundamental frequency

Once you know a tower loops, the next question is the one a physicist always
asks: *what is its frequency?* A periodic object may admit many periods at once —
if `d` is a period, intuitively so are its multiples — and among all of them
there is a smallest.

> **The Least Period exists.** Every periodic object `X` has a well-defined
> *minimal period*: the smallest positive number `d` that is a period of `X`. It
> is genuinely positive (never zero), it is genuinely a period (the loop really
> closes at that gap), and it is the floor beneath all others — no period of `X`
> is smaller.

This minimal period is the object's **fundamental frequency**, the tightest
rhythm in its self-multiplication. For the unit object it is 1. For a charge that
cycles every three steps it is 3. It is the single number that best summarizes how
`X` loops back on itself — the categorical analogue of the order of an element in
a group, or the base period of a vibrating string beneath all its harmonics.

That the minimal period exists at all is a quiet triumph of good foundations. The
set of periods of a periodic object is a nonempty set of positive whole numbers,
and every nonempty set of whole numbers has a least element. Translating that
principle into a concrete, computable handle on the fundamental frequency — one
that comes with a proof that it really is the smallest — completes the picture.

## Why this is the right kind of "loops back"

Return now to the title. The project began with a deceptively simple desire: to
understand structures where **composition is not associative on the nose, but
fails to be associative in a perfectly controlled way** — where `(f ∘ g) ∘ h` is
not literally `f ∘ (g ∘ h)`, but is canonically, coherently isomorphic to it. A
monoidal category is exactly such a structure for objects: regrouping a product
loops you back to an isomorphic, not identical, object, and the associator is the
precise law governing that loop.

The theory of periodic tensor powers takes this "controlled failure of strictness"
and runs with it to its natural conclusion. Because sameness means *isomorphism*
rather than *equality*, the tower of powers is free to fold back on itself. The
Addition Law shows the fold respects the arithmetic of exponents. The Shift
Invariance theorem shows that any single fold, anywhere, forces the whole tower
into a permanent rhythm. And the least period names that rhythm.

The real-world resonances are not decorative. In quantum field theory, the
"fusion rules" describing how anyons combine are literally statements about
tensor powers in a monoidal category, and their periodicities encode conservation
laws and selection rules. In the study of symmetry, an object satisfying
`Xᵈ ≅ 𝟙` is an element of finite order in a categorified group — a "charge" that
returns to neutral after `d` combinations, just as quarks combine in threes to
make colour-neutral hadrons. And in the philosophy of time, a finite-state
process condemned to repeat its single operation forever models a self-consistent
causal loop: it cannot run away to infinity, so it must close, and the least
period is the length of the cycle it is doomed — or privileged — to inhabit.

## The shape of certainty

What makes this story more than a pleasant analogy is that every claim in it is a
theorem, stated with full precision and checked without gaps. The definitions —
the tower of powers, periodicity at a height, the set of periods, the minimal
period — are explicit constructions, not hand-waving. The Addition Law, the Shift
Invariance theorem, the periodicity-detection criterion, and the existence,
minimality, and positivity of the least period are all established rigorously,
each following from the last by a short and honest argument.

The result is a small, self-contained theory of rhythm in the most abstract
setting where "combining" makes sense. It begins from one humble machine that
keeps gluing a copy of `X` onto the front of whatever it is handed, and it ends
with a precise account of when that endless process catches its own tail, how the
catch spreads through the entire tower, and what the deepest frequency of the loop
turns out to be.

Composition, it turns out, loves to loop back. The mathematics here is the map of
exactly how.
