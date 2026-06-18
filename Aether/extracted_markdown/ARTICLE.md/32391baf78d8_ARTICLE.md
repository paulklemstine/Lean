# The Wandering Number: How a Drunkard Who Never Repeats Himself Reveals a Universal Constant

## A walk that can never cross its own path

Imagine you are standing at a street corner in an infinite, perfectly square city.
At every intersection you may step one block north, south, east, or west. There is
just one rule: you must never set foot on a corner you have already visited. No
loops, no backtracking onto your own trail, no figure-eights. Walk until you tire,
then count how many *distinct* routes of a given length you could possibly have taken.

This is the **self-avoiding walk** (SAW), one of the most innocent-looking objects in
all of mathematics — and one of the most stubbornly difficult. It was introduced by
the chemist Paul Flory in the 1940s as a model for long polymer molecules: a strand
of plastic or DNA floating in solution cannot pass through itself, so the geometry of
a SAW captures the shape of real macromolecules. Physicists later realized the same
combinatorial creature governs critical phenomena, phase transitions, and the
mysterious scaling laws that appear at the boundary between order and chaos.

The central quantity is deceptively simple. Let **c_n** be the number of self-avoiding
walks of length *n* that start at the origin of the square lattice ℤ². The first few
values are easy to find by hand:

- c_0 = 1 (the walk that stays put),
- c_1 = 4 (north, south, east, or west),
- c_2 = 12 (four first steps, three non-reversing second steps),
- c_3 = 36,
- c_4 = 100,
- c_5 = 284, …

These numbers explode. By length 71, c_n already exceeds the number of atoms in the
observable universe. No one has ever found — and most experts believe no one ever
will find — a simple formula for c_n. And yet, hidden inside this runaway sequence is
a single, perfectly well-defined number that tames it: the **connective constant**.

## The number that controls the explosion

Even though c_n grows astronomically, it does not grow *wildly*. It grows like a clean
exponential. That is, there is a fixed number μ — the connective constant — such that

> c_n behaves like μ^n for large n.

More precisely, the *n*-th root of the count settles down to a definite limit:

> **c_n^{1/n} → μ as n → ∞.**

So μ is the "average branching factor" of a self-avoiding walk: roughly how many
genuine choices you have at each step once the constraint of never repeating yourself
has been accounted for. On a square lattice you start with 4 directions, lose one
immediately to the no-backtracking rule (leaving 3), and lose a little more to the
subtler requirement of avoiding your distant past. The true value turns out to be

> **μ ≈ 2.638…**

a number that — remarkably — has no known closed form. It is not a fraction, not a
square root, not any expression anyone has managed to write down with the usual
symbols. It is simply *the* connective constant of ℤ², known today to dozens of decimal
places by heroic computer enumeration, yet algebraically mysterious.

## Why must the limit even exist?

Before we can talk about the *value* of μ, we have to be sure the limit c_n^{1/n}
*converges* at all. A priori the *n*-th roots could oscillate forever, never settling.
The proof that they do settle is a small miracle of economy, and it is the
mathematical heart of this work. It rests on one combinatorial observation.

**Submultiplicativity.** Take any self-avoiding walk of length *m + n*. Chop it at step
*m*. The first piece is a self-avoiding walk of length *m*. The second piece, once you
slide its starting point back to the origin, is a self-avoiding walk of length *n*.
Crucially, this chopping is *injective*: different long walks split into different
pairs of short walks. Therefore the number of long walks can be no larger than the
number of ways to pick a front half and a back half independently:

> **c_{m+n} ≤ c_m · c_n.**

This is the inequality we have formally verified. It says SAW counts are
*submultiplicative*. (The inequality is strict in general, because not every pair of
short walks glues back into a *valid* long walk — the back half might collide with the
front half.)

Take logarithms and the multiplication becomes addition:

> **log c_{m+n} ≤ log c_m + log c_n.**

A sequence obeying this is called **subadditive**, and subadditive sequences are
governed by a beautiful 1923 result of the Hungarian mathematician Mihály Fekete.

**Fekete's subadditive lemma.** If a sequence a_n satisfies a_{m+n} ≤ a_m + a_n, then
a_n / n converges — and its limit equals the infimum of all the ratios:

> **a_n / n → inf_k (a_k / k).**

Applied to a_n = log c_n, Fekete's lemma instantly delivers the existence of μ. The
quotients (log c_n)/n converge to a finite limit L, and exponentiating gives

> **c_n^{1/n} = exp((log c_n)/n) → exp(L) = μ.**

This is the **Hammersley–Morton theorem**: the connective constant of the
self-avoiding walk exists. We have formalized exactly this chain — submultiplicativity,
subadditivity of the logarithm, Fekete's lemma, and the exponential limit — as a
machine-checked proof. The one technical point Fekete needs is that the quotients are
bounded below, which is automatic here: every count satisfies c_n ≥ 1, so log c_n ≥ 0,
so every quotient is ≥ 0.

## The infimum is a gift to computation

Fekete's lemma gives something stronger than mere convergence. Because the limit is the
*infimum* of the ratios, the connective constant sits *below every single one* of the
root-counts:

> **μ ≤ c_n^{1/n} for every n ≥ 1.**

This is not a numerical accident; it is a theorem. And it is a spectacular gift to
anyone armed with a computer. It means that *any* finite, honest enumeration of walks —
no matter how short — yields a rigorous, guaranteed *upper bound* on μ. Compute c_{20},
take its twentieth root, and you have a number that the true connective constant
provably cannot exceed. Longer enumerations give tighter ceilings. This is the rigorous
backbone of the decades-long computational assault on μ, and we have proved the
underlying principle as a formal theorem.

## Trapping the constant from both sides

Knowing μ exists is one thing; knowing *where* it lives is another. We can pin it inside
a clean interval using two elementary but elegant arguments.

**The lower bound μ ≥ 2.** Consider only the walks that always step either *north* or
*east* — never south, never west. Each such "staircase" walk of length *n* is a free
choice of one bit per step (N or E), so there are exactly **2^n** of them. And every one
of them is automatically self-avoiding! The reason is lovely: along a north-east walk
the sum of the two coordinates, x + y, increases by exactly 1 at every step. A quantity
that strictly increases can never return to a previous value, so the walk can never
revisit a point. These 2^n monotone walks are a subset of all SAWs, hence

> **c_n ≥ 2^n,  and therefore  μ ≥ 2.**

We formalized this by injecting the bit-strings (Fin n → Bool) into self-avoiding walks
via partial-sum coordinates, then recovering each bit from the per-step change in the
x-coordinate to prove the map is injective.

**The upper bound μ ≤ 3.** After the very first step, the no-backtracking rule forbids
the reverse direction, leaving at most 3 choices at each subsequent step. So the number
of merely *non-reversing* walks is at most 4 · 3^{n-1}, and since every self-avoiding
walk is in particular non-reversing,

> **c_n ≤ 4 · 3^{n-1},  which gives  μ ≤ 3.**

The lower bound was clean to verify formally; the upper bound is recorded as a stated
conjecture in our development, because "never immediately backtrack" is a *local*
constraint that must be tracked along the entire walk rather than read off a single
monotone coordinate, and the bookkeeping is genuinely more delicate. Together the two
bounds trap the constant:

> **2 ≤ μ ≤ 3,**

a window comfortably containing the numerical value μ ≈ 2.638.

## A cautionary tale of two lattices

There is a famous closed-form constant lurking in this story, and it is easy to attach
it to the wrong lattice. The original research brief proposed that the connective
constant equals **(2 + √2)/2 ≈ 1.707**. This is incorrect — and the error is instructive.

The genuinely beautiful exact result belongs not to the *square* lattice but to the
*hexagonal* (honeycomb) lattice. In 1982 the physicist Bernard Nienhuis predicted,
using the non-rigorous but uncannily accurate methods of conformal field theory, that
the honeycomb connective constant should equal

> **μ_hex = √(2 + √2) ≈ 1.848.**

For thirty years this remained a conjecture. Then in 2012, in a celebrated paper in the
*Annals of Mathematics*, Hugo Duminil-Copin and Stanislav Smirnov proved it rigorously,
using a clever auxiliary quantity called the *parafermionic observable* that is almost
perfectly conserved along honeycomb walks. We have captured the algebraic essence of
their constant in formally verified form: the number √(2 + √2) satisfies

> **μ_hex² = 2 + √2,  and  μ_hex⁴ − 4·μ_hex² + 2 = 0,**

the latter being its minimal polynomial — the simplest integer equation it solves. We
also verified the companion fact that the *critical fugacity* x_c = 1/μ_hex is strictly
less than 1, the threshold that governs when the polymer's generating function
converges.

The honeycomb value √(2 + √2) ≈ 1.848 is smaller than the square-lattice value
≈ 2.638 for an intuitive reason: each vertex of the honeycomb has only 3 neighbors
instead of 4, so there are fewer directions to wander and the walk branches more slowly.
Neither equals the brief's 1.707; that number appears to be a garbled half of the
honeycomb constant. The lesson is a recurring one in this subject: the square lattice,
for all its everyday familiarity, is *harder* than the exotic-looking honeycomb, and it
guards its connective constant jealously, with no closed form known to this day.

## What the constant tells us about the world

Why should anyone outside pure combinatorics care about a number like 2.638…? Because
the connective constant is the gateway to *universality* — the deep principle that wildly
different physical systems share the same large-scale behavior near a critical point.

For polymer physics, μ sets the exponential rate at which the number of possible chain
configurations grows with chain length, which in turn controls the entropy, the free
energy, and ultimately the thermodynamics of dilute polymer solutions. The companion
exponents conjectured by Nienhuis — a susceptibility exponent γ = 43/32 and a swelling
exponent ν = 3/4 governing how the typical end-to-end distance of a long chain scales —
describe how a real polymer puffs up in a good solvent. These rational fractions, with
their suspiciously clean denominators, are signatures of the conformal symmetry that
emerges at criticality in two dimensions.

The square-lattice connective constant is, in a sense, a number we know *exists* with
total mathematical certainty, whose neighborhood we have mapped precisely (2 ≤ μ ≤ 3),
whose digits we can compute to high precision, and yet whose exact identity remains
beyond reach. It is a perfect emblem of the self-avoiding walk itself: simple to state,
impossible to fully tame, and quietly fundamental to the way nature folds its longest
molecules.

## The takeaway

From a single combinatorial inequality — that long walks split injectively into pairs
of shorter walks — flows the entire edifice. Submultiplicativity becomes subadditivity
of the logarithm; Fekete's century-old lemma converts subadditivity into convergence;
exponentiation turns convergence into the existence of the connective constant; and the
infimum structure of Fekete's limit turns every finite computation into a rigorous
bound. Two elementary geometric pictures — the monotone staircase walks and the
non-reversing walks — trap the constant between 2 and 3. And a careful reading of the
literature corrects a tempting but false closed form, reserving the elegant √(2 + √2)
for the honeycomb lattice where it truly belongs.

The drunkard who never repeats himself, it turns out, walks to the beat of a universal
number — one we have now placed on the firmest possible foundation.
