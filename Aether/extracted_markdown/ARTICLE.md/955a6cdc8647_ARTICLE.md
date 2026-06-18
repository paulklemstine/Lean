# Counting to Infinity, and the Ordinal That Measures a Theory's Strength

## A number you can never reach by counting

Start with zero. Add one. Keep going. You will pass every whole number, but you
will never finish — there are infinitely many of them. Mathematicians long ago
decided not to be intimidated by this. They invented a new number to sit *just
past* all the finite numbers and called it **ω** ("omega"). It is the first
infinite ordinal: the smallest thing larger than 0, 1, 2, 3, and every finite
step you could ever take.

Once you have ω, the game does not stop. You can take ω + 1, ω + 2, then ω + ω
(written ω·2), then ω·3, and eventually ω·ω = ω². Keep climbing and you reach
ω raised to the ω, written ω^ω, and then ω^ω^ω, towers of omegas stacked as
high as you like. Each one dwarfs the last. These **ordinals** are the
mathematician's official ruler for measuring "how long" a well-ordered process
can run before it terminates.

This article is about a single, very special ordinal — one that turns out to be
a kind of fingerprint for an entire mathematical theory — and about a clean,
machine-checked proof of two facts about it that, surprisingly, had remained
loose ends in the world's largest formal mathematics library.

## The fixed point that refuses to grow

Look again at the tower of omegas:

$$0,\quad 1,\quad \omega,\quad \omega^\omega,\quad \omega^{\omega^\omega},\quad \dots$$

Each step is "raise ω to the previous ordinal." The numbers explode. But here is
the twist that makes infinity stranger than any finite intuition. If you take the
**limit** of this entire infinite tower — the smallest ordinal larger than every
rung — you arrive at an ordinal so large that raising ω to *it* changes nothing
at all:

$$\omega^{\varepsilon_0} = \varepsilon_0.$$

This ordinal is called **epsilon-nought**, written **ε₀**. It is the first
*fixed point* of the operation "ω to the power of." Exponentiation, the engine
that drove the whole tower upward, simply stalls when it reaches ε₀. You cannot
escape ε₀ by exponentiating; the operation has met its match.

Formally, ε₀ is the least ordinal that is closed under the tower process. In this
work it is captured by a clean identity. Define the finite ω-towers by

$$\mathrm{tower}(0) = 0, \qquad \mathrm{tower}(n+1) = \omega^{\mathrm{tower}(n)},$$

so the sequence is exactly $0, 1, \omega, \omega^\omega, \dots$. Then

$$\varepsilon_0 \;=\; \sup_{n \in \mathbb{N}} \mathrm{tower}(n).$$

Epsilon-nought is *precisely* the supremum of the finite towers — the Cantor
picture of ε₀ made into a one-line equation. (A subtle point that bites the
unwary: the towers are **strictly** increasing, but the slogan "every ordinal is
smaller than ω to its own power" is *false* exactly at ε₀, because ε₀ is the
fixed point. Strict growth of the tower works only because every rung sits
strictly *below* ε₀.)

## Why a logician cares about this particular number

Here is where ε₀ stops being a curiosity and becomes profound. In the 1930s the
logician Gerhard Gentzen proved that ordinary arithmetic — **Peano Arithmetic**,
or PA, the formal theory of the whole numbers with induction — is consistent. But
Gödel had shown that no sufficiently strong theory can prove its own consistency
using only its own resources. So Gentzen had to add *one* new ingredient: the
principle that you can do induction along the ordinals *up to ε₀*.

That single number is the exact price of arithmetic's consistency. Induction up
to any ordinal below ε₀ is provable inside PA; induction up to ε₀ itself is not,
and adding it suffices to prove PA consistent. We say ε₀ is the
**proof-theoretic ordinal** of PA. It is a numerical measure of the logical
strength of a theory — a single transfinite number that says "this is how far
arithmetic can see."

Stronger theories have larger fingerprints. **Kripke–Platek set theory** (KP), a
foundational fragment of set theory, has a proof-theoretic ordinal called the
**Bachmann–Howard ordinal**, vastly larger than ε₀. The dream of *ordinal
analysis* is to compute these fingerprints and compare theories by comparing
ordinals: a thermometer for mathematical strength.

## The notation problem, and the trick of "collapsing"

There is a practical obstacle. The Bachmann–Howard ordinal is far too large to
reach by stacking omega-towers. To even *name* such ordinals, logicians borrow
power from above. They reach up to an **uncountable** ordinal — call it **Ω**, a
"regular cardinal" so large it cannot be approached from below by any countable
sequence — use its bulk as raw material, and then *collapse* the result back down
into the countable world with a special function written **ψ** (psi). This is an
**ordinal collapsing function** (OCF). It is the central machine of modern
ordinal analysis, the device that lets a countable notation system borrow the
strength of the uncountable.

The headline target of this project is the iconic inequality

$$\varepsilon_0 \;<\; \psi(\Omega^{\omega}),$$

a statement that places the fingerprint of arithmetic strictly below a collapsed
value built over the uncountable base Ω. It is a sanity check and a signpost: the
collapsing machinery, even applied to a modest input Ω^ω, already overshoots the
strength of all of arithmetic.

## What this work proves — rigorously, and by machine

Everything below is fully formalized and checked, with no gaps. Three results
stand out.

**1. Epsilon-nought is countable.** This sounds almost obvious — ε₀ is a limit of
a countable tower, after all — but it had been left as an explicit open to-do in
Mathlib, the largest formal mathematics library in the world. The precise
statement is

$$\varepsilon_0 < \omega_1,$$

where ω₁ is the first *uncountable* ordinal. The proof is a genuine bridge
between two different mathematical neighborhoods. From the order-theory side: ε₀
is the supremum of the countably many finite towers. From the cardinal-arithmetic
side: ω₁ is *principal* under ordinal exponentiation — meaning if α and β are both
below ω₁, then so is α raised to β. So each finite tower stays safely countable,
and a countable supremum of countable ordinals is still countable. The result
falls out. (Equivalently, in cardinality terms, the size of ε₀ is strictly less
than ℵ₁.)

**2. The uncountable base is itself a fixed point.** A second clean fact explains
*why* you are allowed to base a collapsing function at Ω = ω₁ in the first place:

$$\omega^{\omega_1} = \omega_1.$$

The first uncountable ordinal is itself an ε-number — a fixed point of "ω to the
power of." This is exactly the closure property an OCF needs from its base: the
raw material is stable under the very operation the notation system runs on. It
is a small fact with a satisfying payoff, linking cardinal arithmetic to the
fixed-point hierarchy.

**3. The collapse inequality.** Package the ε-numbers as a normal,
order-preserving hierarchy ψE, where ψE(o) enumerates the ε-numbers in order and
ψE(0) = ε₀. This is a faithful, fully rigorous *model* of a collapsing function:
it is strictly increasing, and every single one of its values is a fixed point of
ω-exponentiation. Over the base Ω = ω₁ one then proves the headline analogue

$$\varepsilon_0 < \psi_E(\Omega^{\omega}),$$

the formal counterpart of ε₀ < ψ(Ω^ω). Alongside it sit the bridge inequalities
ε₀ < Ω (arithmetic's ordinal is countable, hence below the uncountable base) and
ε₀ < (Bachmann–Howard ordinal), placing PA strictly beneath a model of KP's
strength — exactly the PA → KP comparison the project set out to make.

## The most instructive failure

Good mathematics is often defined by the thing that *cannot* be done, and this
project found a sharp one. It is tempting to hope for a *monotone* (always
increasing, order-preserving) collapsing function that takes the uncountable Ω
and sends it *below* ω₁ — a tidy, well-behaved ψ with ψ(0) = ε₀ and ψ(Ω) < ω₁.

This is **provably impossible**, and the reason is beautiful. Any strictly
increasing map f on the ordinals obeys the iron law $a \le f(a)$: you can never
push an ordinal strictly *down* with an order-preserving function. So if f is
strictly monotone, then necessarily $\omega_1 \le f(\omega_1)$ — the value at Ω
cannot drop below Ω. Monotonicity is *itself* the obstruction to collapsing.

This is the precise, formal reason that the real ordinal collapsing functions of
Buchholz, Madore, and others *must* be non-monotone. They are intricate exactly
because they have to be: collapsing the uncountable into the countable is a feat
that no well-behaved increasing function can perform. The boundary result turns a
vague intuition ("OCFs are weird and jumpy") into a one-line theorem.

## Why it matters beyond logic

The idea that a single transfinite number can summarize the entire deductive
power of a theory is one of the quiet marvels of twentieth-century mathematics.
It turns the question "is this theory stronger than that one?" into the question
"is this ordinal bigger than that one?" — replacing a hazy philosophical
comparison with a precise arithmetic of infinity.

The same towers and fixed points reappear far from foundations. The ordinal ε₀ is
the engine behind *Goodstein's theorem*, a statement about perfectly ordinary
sequences of whole numbers that always, eventually, crash back down to zero —
even though they first balloon to sizes no calculator could print. The reason
they must terminate is that a hidden ordinal below ε₀ is quietly *decreasing* the
whole time, and ordinals, unlike integers, cannot decrease forever. Termination
proofs for programs, the well-foundedness arguments behind recursion, and the
comparison of axiom systems all draw on the same well: the unshakable fact that
the ordinals are well-ordered, so any descending process must stop.

What this project contributes is twofold. It closes a concrete, named gap in the
formal record — the countability of ε₀ — with a proof that genuinely braids
together order theory and cardinal arithmetic. And it lays down, in fully checked
form, the first rungs of the ladder that ordinal analysis climbs: the fixed-point
hierarchy, the closure of the uncountable base, the collapse inequality, and the
exact theorem explaining why honest collapsing functions cannot be tame.

Counting to infinity, it turns out, is not the end of the story. The real
question is how *far* you can count — and that distance, captured by a single
ordinal, is the truest measure of how much a piece of mathematics can know.
