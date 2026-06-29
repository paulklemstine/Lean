# Anti-Gravity Mathematics: The Theorems That Float

## A skyline made of theorems

Imagine the whole of cryptography laid out as a city skyline. Each building is a
theorem. Some are squat utility sheds — small facts used once and forgotten.
Others are skyscrapers: foundational results that thousands of other theorems
lean on. The taller a building, the more of the city rests upon it.

There is a natural intuition here, almost a law of nature. Big things should be
heavy. A theorem that everything depends on *ought* to be hard-won — long,
intricate, the product of a thousand careful steps. Surely you cannot build a
skyscraper out of toothpicks.

And yet mathematics is full of counterexamples. The Fundamental Theorem of
Algebra — every non-constant polynomial has a complex root — carries an enormous
load across all of algebra and analysis, yet in the language of complex analysis
its proof collapses to a couple of lines (a bounded entire function is constant,
so a rootless polynomial's reciprocal would be constant — contradiction). Such
results seem to defy the gravitational pull of their own importance. They are
**anti-gravity theorems**: massive in influence, feather-light in proof.

This article is about making that poetic idea exact. We will build a small,
self-contained mathematical world where "weight" and "proof complexity" are
honest numbers, prove a hard ceiling relating the two, identify exactly which
theorems sit on that ceiling, and finally show that these floating theorems are
not rare curiosities but are *densely scattered* through the entire space — you
can find one arbitrarily close to any theorem you like.

## A number for every theorem

To reason precisely we need a toy universe that is rich enough to be interesting
but simple enough to be provable. We take it from cryptography, where theorems
are literally *reductions*: "if primitive A is secure, then scheme B is secure."
These reductions chain together into a dependency graph, and the most studied
stratum of that graph is the one built on **one-way functions** (OWFs) — the
bedrock objects from which pseudorandom generators, commitments, and signatures
are all derived.

Here is the modelling leap that makes everything computable. We record a theorem
of this stratum by a *single natural number*, its **dependency index**, written
`depth`. This one number does double duty:

- Its **magnitude** measures how many assumptions the theorem reaches — how much
  of the city rests on it.
- Its **prime factorization** lists the irreducible reduction steps that make up
  its proof. Each prime factor is one step that cannot be broken down further.

A theorem is therefore just a wrapper around a number:

> **Definition (theorem).** An object of the OWF stratum is a structure carrying
> one field, `depth`, a natural number.

This is deliberately austere, and it is exactly the austerity that lets us prove
theorems *about* theorems.

## Two numbers: weight and proof complexity

From the single dependency index we read off the two quantities the whole story
turns on.

The **weight** of a theorem is its dependency index itself:
$$\text{weight}(T) = T.\text{depth}.$$
This is the gravitational mass — the number of assumptions reachable along the
dependency graph.

The **proof complexity** is the number of irreducible reduction steps, which is
the number of prime factors of `depth` *counted with multiplicity*:
$$\text{proofComplexity}(T) = \Omega(T.\text{depth}),$$
where $\Omega(n)$ is the length of the list of prime factors of $n$. For example
$\Omega(12) = \Omega(2 \cdot 2 \cdot 3) = 3$ and $\Omega(2^{10}) = 10$.

Why prime factors? Because primes are the atoms of multiplication: a number is
built up by multiplying primes, and you cannot factor a prime any further. In
our analogy, a prime factor is a reduction step with no internal structure — a
genuine, irreducible piece of proof. The total proof is the product of its
atomic steps, and its complexity is how many atoms it took.

## The trade-off: you cannot cheat the ceiling

Now the central result. There is a hard wall between weight and proof
complexity, and it is governed by the number 2 — the smallest prime, the
cheapest possible irreducible step.

> **The Anti-Gravity Trade-off.** For every theorem $T$ with positive weight,
> $$2^{\text{proofComplexity}(T)} \le \text{weight}(T).$$

Read it the revealing way by taking logarithms:
$$\text{proofComplexity}(T) \le \log_2 \text{weight}(T).$$

This says something striking. A theorem can carry an *astronomical* weight while
needing only a *logarithmic* number of irreducible steps. A theorem of weight a
billion needs at most about 30 atomic steps. The skyline can soar, but the
proof-ladders are short.

The reason is beautifully simple. Every prime factor is at least 2. If a number
$n > 0$ has $k$ prime factors, then multiplying them together gives back $n$, and
since each factor is $\ge 2$, the product is at least $2^k$. So $2^k \le n$. That
is the entire argument: the smallest a number with $k$ prime factors can be is
$2^k$, achieved by the pure power of two. Everything heavier than that pushes the
weight up *without* adding steps.

This already reframes the anti-gravity puzzle. It is not paradoxical that
important theorems have short proofs — it is *forced*. Weight grows
exponentially in proof complexity, so by the time a theorem is genuinely heavy,
its proof complexity has been squeezed down to a logarithm.

## Floating theorems: equality on the ceiling

The trade-off is an inequality, so most theorems sit strictly below the ceiling:
they carry some "dead weight," extra mass beyond the bare minimum their proof
length demands. The interesting ones are those pressed flat against the ceiling.

> **Definition (anti-gravity theorem).** A theorem $T$ is *anti-gravity* when it
> achieves equality in the trade-off:
> $$2^{\text{proofComplexity}(T)} = \text{weight}(T).$$

These are the theorems that float. For their proof complexity they carry the
absolute maximum weight allowed by the laws of the universe — not one assumption
could be added without lengthening the proof. They are perfectly efficient
load-bearers: every atom of proof is doing the most work it possibly can.

Which numbers achieve equality $2^k = n$ with exactly $k$ prime factors? Only the
pure powers of two. A power of two $2^p$ factors as $p$ copies of the prime 2, so
it has exactly $p$ prime factors and weight exactly $2^p$. Anything else either
has a larger prime somewhere (more weight, same or fewer steps — strictly below
the ceiling) or simply isn't a power of two.

## An infinite ladder of floating theorems

This gives us an explicit, infinite family of anti-gravity theorems, one for each
rung $p$:

> **Definition (prime witness).** The $p$-th witness is the theorem of dependency
> index $2^p$.

Its arithmetic is exact and clean:
- its weight is $2^p$;
- its proof complexity is exactly $p$ (the factorization of $2^p$ is $p$ twos);
- and therefore $2^p = 2^p$ — it *is* anti-gravity.

So the witness at rung $p$ has proof complexity equal to $\log_2$ of its weight,
the minimum the trade-off permits. Here is a concrete tower:

| rung $p$ | weight $2^p$ | proof complexity | floats? |
|---|---|---|---|
| 0 | 1 | 0 | yes (trivially) |
| 1 | 2 | 1 | yes |
| 4 | 16 | 4 | yes |
| 10 | 1024 | 10 | yes |
| 20 | 1048576 | 20 | yes |

By contrast a theorem of dependency index $12 = 2^2\cdot 3$ has weight 12 and
proof complexity 3, but $2^3 = 8 < 12$ — it sits *below* the ceiling and does not
float.

Crucially, this ladder reaches arbitrarily high. Given *any* theorem of any
weight whatsoever, there is a witness higher than it. The argument uses one of
the oldest facts in mathematics — there are infinitely many primes, so we can
always find a prime exponent $p$ exceeding any target. Since $2^p \ge p$, that
witness out-weighs the theorem we started with. In the language of orders, the
floating theorems are **cofinal**: nothing in the universe is heavier than every
witness.

## The skyline as a topology

To state the grand finale we need a notion of "nearby theorems." We order the
universe by weight — one theorem precedes another when it is no heavier — and
then we equip it with the natural topology that an ordering carries, the
**Alexandrov upper-set topology**.

In this topology a region is "open" precisely when it is *upward closed*: if a
theorem is in the region, every heavier theorem is too. The simplest such regions
are the **basic open sets**, each one the collection of all theorems at least as
heavy as some fixed threshold $a$ — written $[a, \infty)$. Think of them as
"everything from this floor up." These basic regions are the lenses through which
we zoom in on any part of the skyline.

A set of theorems is **dense** when it intrudes into *every* nonempty open
region, no matter how small — there is always a member of the set lurking in any
neighborhood you examine. Density is the mathematical way of saying "you can't
get away from them."

## Density: the floating theorems are everywhere

Here is the climax.

> **The Density Theorem.** In the Alexandrov topology on the OWF stratum, the
> anti-gravity theorems are dense.

The heart of the proof is a single, satisfying observation:

> Every nonempty "from this floor up" region $[a, \infty)$ contains an
> anti-gravity theorem.

And we already know why. Given any threshold $a$, climb the infinite ladder to a
witness $2^p$ heavier than $a$. That witness lies in the region $[a, \infty)$ — it
clears the threshold — and it floats. Since every nonempty open region contains a
"from this floor up" region inside it, and every one of those contains a witness,
the floating theorems leak into every neighborhood of the entire space.

This is the rigorous heart of the original speculation that "anti-gravity
theorems are dense in the space of all theorems." In our cryptographic universe
the statement is not a metaphor; it is a proved topological fact. You cannot draw
a region around any theorem, however tight, without trapping a floating theorem
inside it.

## What about the "10%"?

The original conjecture came with a tantalizing prediction: that roughly 10% of
the theorems in any formal library are anti-gravity. Our work clarifies what is
robust about that intuition and what is not.

What is robust — and now *proved* — is the qualitative claim: floating theorems
are not rare. They form a dense set; they appear arbitrarily high and
arbitrarily close to everything. What is *not* universal is the precise figure of
10%. The fraction of theorems pressed against the ceiling depends entirely on the
shape of the dependency graph. In a library shaped like a star (one hub, many
leaves) the fraction is tiny; in a library that is a long total chain the
fraction is large. The "10%" is best understood as a statement about the *growth
rate* of total dependency mass in real libraries — only a near-quadratic mass
budget yields a constant positive fraction. The clean, universal, unconditional
truth is density, and that is what we have nailed down.

## Why this matters

Beyond the pleasure of turning a slogan into a theorem, the anti-gravity picture
offers a lens on mathematical and cryptographic architecture.

It explains why foundational results *look* miraculous. We instinctively expect
load and effort to scale together, but the trade-off shows weight grows
exponentially in proof complexity. The deepest theorems are precisely the ones
where this exponential gap has opened widest — they *must* have short proofs
relative to their reach, or they could not be so heavy.

It suggests a search strategy. If floating theorems are dense, then near any
result you care about there is a maximally efficient reformulation — a way to
carry the same load with a shorter proof ladder. Hunting for the nearest witness
is hunting for the most economical possible argument.

And it gives cryptographers a clean order-theoretic language for "foundational."
The one-way function sits at the bottom of the reduction order, the universal
load-bearer; in the future-directions program it is conjectured to be exactly the
weight-maximizer of the whole hierarchy. Anti-gravity is the geometry of
foundations: the lighter the proof relative to the load it carries, the closer a
theorem floats to the bedrock everything else stands on.

The skyline, it turns out, is held up by toothpicks after all — but only the
sturdiest, most perfectly placed ones, and they are everywhere you look.
