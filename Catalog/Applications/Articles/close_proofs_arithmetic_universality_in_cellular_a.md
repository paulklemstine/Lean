# The Secret Arithmetic of a Self-Drawing Triangle

## How a one-line rule for blinking cells turns out to be a calculator for prime numbers

Imagine a single row of light bulbs stretching off to infinity in both
directions. All of them are dark except one, glowing at the center. Now give
yourself one rule, and apply it over and over to generate the next row, and the
next, forever:

> **Each bulb in the new row turns on if exactly one of its two neighbors above
> was on, and turns off otherwise.**

That is the entire instruction. It is so simple you could teach it to a child
with two coins and a checkerboard. And yet, if you let it run and stack the rows
on top of one another, something uncanny appears: the **Sierpiński triangle**, an
infinitely intricate fractal of nested triangular holes, the same pattern you
find in the bracts of a Romanesco cauliflower, in certain seashells, and in the
foam of a breaking wave.

This rule has a name — *Rule 90* — and it belongs to the world of **cellular
automata**, the toy universes that the physicist Stephen Wolfram spent decades
arguing might be the true language of nature. For most of its life, Rule 90 has
been admired as a curiosity: proof that staggering complexity can crawl out of
near-total simplicity.

But there is a deeper story hiding inside it, and this article is about that
story. The Sierpiński triangle is not just *pretty*. It is a **picture of prime
numbers doing arithmetic**. The triangle's holes are exactly the places where a
certain count is divisible by 2. Change the rule slightly — work with three
states instead of two, or five, or any prime number of states — and the fractal
re-tiles itself according to that prime. The pattern is, in a precise and
provable sense, a *physical computer for modular arithmetic*.

The purpose of this article is to explain a single beautiful mechanism that
unites all of this: a phenomenon we call **p-adic renormalization**. It explains
why the triangle is self-similar, why it knows about prime numbers, and why —
when you zoom out by exactly the right factor — the whole roaring complexity
suddenly collapses into two clean beams of light.

---

## From bulbs to polynomials: the trick that changes everything

The first move is a change of language, and like all good changes of language it
makes the hard things easy.

Instead of tracking which bulbs are on, we write down a single algebraic
expression. We give each position on the line an address — an integer, positive
to the right of center, negative to the left — and we record a configuration as a
sum of powers of a formal symbol `T`. If the bulb at position `x` is on, we
include the term `T^x`. So a single lit bulb at the center is just `1` (that is,
`T^0`). A bulb at position 3 is `T^3`. A bulb at position −2 is `T^(-2)`, where
the negative exponent is perfectly legal — these are called **Laurent
polynomials**, and they allow exponents to run in both directions.

Why bother? Because now the *rule itself* becomes a piece of arithmetic. Saying
"each cell becomes the sum of its two neighbors" is exactly the same as
**multiplying** your whole expression by

> **caOp = T + T⁻¹.**

Multiplying by `T` shifts everything one step to the right; multiplying by `T⁻¹`
shifts everything one step to the left; adding the two results superimposes the
left-shifted and right-shifted copies. That is precisely the neighbor-sum rule.

And here is the magic of multiplication: applying the rule `t` times is just
raising that one element to the `t`-th power. The **entire space-time history of
the automaton** — every row, forever — is encoded in the powers

> **(T + T⁻¹)¹, (T + T⁻¹)², (T + T⁻¹)³, …**

We have replaced a dynamical process with the powers of a single number-like
object. Everything that follows is a consequence of squeezing this one stone.

There is one more ingredient: the coefficients live in **modular arithmetic**.
For the original blinking-bulb rule, a bulb is either on (1) or off (0), and two
"on" contributions cancel — `1 + 1 = 0` — because we only care whether the count
is *even or odd*. This is arithmetic modulo 2. But nothing forces us to stop at
2. We can let each cell hold a value from 0 to `p−1` for any prime `p`, and add
modulo `p`. This gives a whole family of automata, one for each prime, which we
will call the **additive cellular automata over the field with `p` elements**.

---

## The whole movie is Pascal's triangle

Once the rule is "multiply by `T + T⁻¹`," a classical theorem walks straight in
the front door: the **binomial theorem**. Expanding `(T + T⁻¹)^n` term by term
gives a sum over the familiar binomial coefficients `C(n, k)` — the entries of
**Pascal's triangle**. Carefully tracking the exponents, the result is an exact
closed form:

> **Generating-function law.** For every time step `n`,
> $$ (T + T^{-1})^{n} \;=\; \sum_{k=0}^{n} \binom{n}{k}\, T^{\,2k - n}. $$

Read out loud, this says: *the configuration at time `n` is literally the `n`-th
row of Pascal's triangle*, with the `k`-th entry parked at position `2k − n`.
(The exponents step by 2 because each cell only ever talks to cells of the same
parity — the lattice quietly splits into an even checkerboard and an odd one.)

Now recall that we are doing arithmetic modulo a prime `p`. A bulb is *off* —
there is a hole in the fractal — exactly when the corresponding binomial
coefficient is divisible by `p`. So the question "what does the space-time
diagram look like?" becomes the purely arithmetic question "**when is `C(n, k)`
divisible by `p`?**" The fractal is a divisibility table in disguise.

For `p = 2`, this is the famous observation that Pascal's triangle mod 2 *is* the
Sierpiński triangle: the odd entries trace out the solid cells, the even entries
carve out the holes. Our algebra reproduces this for free — and generalizes it to
every prime at once.

---

## The collapse: where renormalization comes in

Here is the heart of the matter, and it is genuinely surprising the first time
you see it.

Pascal's triangle mod `p` is, in general, a mess of intricate substructure.
There is no simple formula for a typical row. But if you look at the rows
numbered by **powers of `p`** — row 2, row 4, row 8 for `p = 2`; row 3, row 9, row
27 for `p = 3` — the mess vanishes completely. Every interior entry is divisible
by `p`, and only the two endpoints survive.

In the polynomial language this is a one-line statement, and it follows from one
of the most charming facts in all of algebra. In ordinary arithmetic,
`(a + b)^p` expands into a thicket of cross-terms. But when you are working
modulo a prime `p`, every one of those cross-terms is secretly a multiple of `p`
and therefore *equal to zero*. What remains is breathtakingly clean:

> $$ (a + b)^{p} \;=\; a^{p} + b^{p} \pmod p. $$

Generations of algebra students have been warned that this is the *wrong* way to
expand a binomial — so much so that it is nicknamed the **"freshman's dream."**
The twist is that in the world of prime modular arithmetic, the dream comes true.
It is the same fact, dressed in fancier clothes, that powers Fermat's Little
Theorem and the whole edifice of finite fields; mathematicians call the operation
"raise to the `p`-th power" the **Frobenius map**, and it is one of the load-
bearing pillars of modern number theory.

Apply the freshman's dream to our operator with `a = T` and `b = T⁻¹`:

> **One-step renormalization.**
> $$ (T + T^{-1})^{p} \;=\; T^{p} + T^{-p}. $$

In words: **after exactly `p` time steps, a single lit cell at the origin becomes
exactly two lit cells, at positions `+p` and `−p`.** All the intermediate
structure — the entire Pascal's-triangle filigree that built up over those `p`
steps — annihilates itself, leaving two lone beams shooting outward along the
edges of the light cone.

And because the freshman's dream can be applied again and again, the collapse
*iterates*. After `p²` steps the two beams sit at `±p²`; after `p³` steps, at
`±p³`; and in general:

> **The renormalization tower.** For every power `k`,
> $$ (T + T^{-1})^{\,p^{k}} \;=\; T^{\,p^{k}} + T^{-p^{k}}. $$

This is what physicists mean by **renormalization**. Squint at the automaton from
far away, sampling it only every `p` steps and rescaling space by a factor of
`p`, and you see *exactly the same automaton you started with*. The `p`-step map,
viewed at the coarser scale, **is** the one-step map. The system is a fixed point
of its own coarse-graining. That self-reproducing quality, repeated at every
scale `p`, `p²`, `p³`, …, is precisely the engine of the fractal's self-
similarity. The Sierpiński triangle looks the same at every magnification because
the algebra that generates it literally repeats itself every time you zoom by a
factor of `p`.

Because the rule is just multiplication, you can also place the seed anywhere you
like and the collapse simply rides along:

> **Translation-covariant seed.** Starting from a single lit cell at any position
> `a`,
> $$ (T + T^{-1})^{\,p^{k}} \cdot T^{a} \;=\; T^{\,a + p^{k}} + T^{\,a - p^{k}}. $$

The lone cell splits into two, equidistant by `p^k` to its left and right. The
physics does not care where you put the origin.

---

## Superposition for free

There is one more property worth pausing on, because it is what makes these
automata so analytically tractable — and so unlike the chaotic, unpredictable
cellular automata that populate Wolfram's zoo.

Since evolution is *multiplication*, and multiplication distributes over
addition, the automaton obeys a perfect **superposition principle**. If you start
two separate patterns and run them, the result is the same as running each
pattern alone and then overlaying the outcomes:

> **Additivity.**
> $$ (\text{caOp})^{t}\,(s_1 + s_2) \;=\; (\text{caOp})^{t}\, s_1 \;+\; (\text{caOp})^{t}\, s_2. $$

> **Homogeneity.** Scaling the input by a constant `c` scales the whole future by
> `c`:
> $$ (\text{caOp})^{t}\,(c \cdot s) \;=\; c \cdot \big((\text{caOp})^{t}\, s\big). $$

This is the exact discrete analogue of the superposition principle that governs
waves, electric fields, and quantum states. It means any complicated initial
condition can be understood as a sum of single-cell seeds, each of which we have
already solved completely. To know the future of *every* configuration, it
suffices to know the future of one lit bulb — and that future is the pair of
collapsing light-cone beams.

---

## Counting the survivors: a fractal census via prime digits

We can push the renormalization idea to a quantitative climax: *how many bulbs
are lit at time `t`?*

Combining the generating-function law with the collapse, the number of live cells
at time `t` is the number of binomial coefficients in row `t` that are **not**
divisible by `p`. A classical gem called **Lucas' theorem** answers exactly this:
write `t` in base `p` as a string of digits `d₀, d₁, d₂, …`; then the count of
surviving cells is the product

> $$ \#\{\text{live cells at time } t\} \;=\; \prod_i (d_i + 1). $$

This little formula is a complete census of the fractal, and it explains the
collapse from a new angle. When `t` is a power of `p`, its base-`p` representation
is a single `1` followed by zeros: digits `1, 0, 0, …`. The product is then
`(1+1)(0+1)(0+1)\cdots = 2`. **Exactly two cells survive** — the two beams of the
renormalization tower. At every other time, more digits are nonzero and the
diagram is busier. The sparsest moments in the life of the automaton are exactly
the powers of `p`, and the algebra tells us so with a one-line count over the
digits of a number.

So the texture of the fractal — dense here, empty there — is dictated entirely by
the *carries* that occur when you do addition in base `p`. The geometry of the
picture and the arithmetic of the prime are one and the same.

---

## Why this matters

It is tempting to file all of this under "beautiful but useless." That would be a
mistake, for several reasons.

**It is a bridge between two worlds.** Cellular automata belong to the study of
dynamical systems and complexity; the freshman's dream and Lucas' theorem belong
to number theory. The result above shows they are describing the *same object*
from two sides. A renormalization-group fixed point — a concept born in physics to
explain why water boils at a sharp temperature and why magnets lose their
magnetism at a critical point — turns out to be, in this setting, nothing but the
Frobenius map of prime arithmetic. Discovering that two great theories are secretly
the same is the most reliable way that mathematics advances.

**It is a model of exact self-similarity.** Most fractals in nature are only
approximately self-similar, and most renormalization arguments in physics are
approximate, asymptotic, or numerical. Here the self-similarity is *exact* and
provable: not "approximately two beams" but precisely two, not "roughly periodic"
but periodic on the nose at every scale `p^k`. Clean, exact examples are
priceless, because they are the ones we can fully understand and use as a
yardstick for the messy ones.

**It is a computer made of arithmetic.** The space-time diagram of this automaton
*computes binomial coefficients modulo a prime* — and through Lucas' theorem, it
computes facts about the base-`p` digits of integers. The same structures appear
in error-correcting codes, in pseudorandom number generation, and in the design
of hash functions. An additive cellular automaton is, quite literally, a
cheap-to-build engine for modular arithmetic, and understanding exactly when it
falls silent (the power-of-`p` collapses) tells an engineer exactly when such a
device is most predictable.

**It is a template for "arithmetic universality."** The original dream behind this
work was bold: that there is a whole class of simple local rules whose long-term
behavior, properly encoded, computes deep arithmetic. The additive case settles
the cleanest member of that class completely. It is a beachhead — a fully
understood example that shows the dream is not a fantasy, and that points the way
toward the harder, nonlinear rules where the arithmetic universality should be
richer still.

---

## The view from the top of the tower

Step back and look at what one change of language bought us. We started with an
infinite row of blinking bulbs and a rule a child could follow. By writing the
configuration as a Laurent polynomial, the rule became multiplication by
`T + T⁻¹`. The binomial theorem then handed us the entire space-time history as
Pascal's triangle. The freshman's dream — the "mistake" every algebra student is
told to avoid — collapsed that history, at every power-of-`p` time, into two
clean beams. And Lucas' theorem turned the resulting picture into a census
governed by the digits of numbers written in base `p`.

The Sierpiński triangle, it turns out, was never just a pretty fractal. It is the
shadow cast by the deepest reflex of prime arithmetic — the Frobenius map — onto a
line of blinking lights. Zoom out by a factor of the prime, and the shadow draws
itself again, forever. That is `p`-adic renormalization: the discovery that the
self-similarity of a simple universe and the arithmetic of prime numbers are, at
bottom, the very same idea.
