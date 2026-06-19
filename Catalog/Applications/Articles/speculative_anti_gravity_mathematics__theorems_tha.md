# The Theorems That Refuse to Fall: A Mathematics of Anti-Gravity

## A strange weightlessness at the heart of mathematics

Walk through any cathedral of mathematics — calculus, number theory, geometry — and
you will notice something architecturally odd. A handful of results hold up almost
everything else. Remove them and the ceiling collapses. Yet these same results are
often astonishingly *light*: their statements are short, their proofs are brief, and
a curious student can absorb them in an afternoon. The Pythagorean theorem. The
fundamental theorem of arithmetic. The fact that a continuous function on a closed
interval attains its maximum. Each one carries enormous structural load while
weighing almost nothing.

Compare this to engineering. In a bridge, the pieces that bear the most weight are
the most massive — the great steel trusses, the deep concrete piers. Load and bulk go
together. Mathematics seems to violate this intuition. Its load-bearing members are
frequently its *lightest* ones. We will call such results **anti-gravity theorems**:
they support a great deal, yet they resist the downward pull of complexity. They stay
aloft on almost no proof at all.

This article is about turning that poetic observation into something exact. We will
build a small, self-contained mathematical world in which "how much a result supports"
and "how much a result costs to prove" both have precise numerical meanings — and in
which the anti-gravity phenomenon becomes a theorem, not a metaphor. Remarkably, the
cleanest model of this idea lives not in some abstract logic of proofs, but in the
oldest playground of mathematics: the whole numbers and their factorizations.

## Weighing a theorem two ways

Imagine a fixed universe of size `N` — think of `N` as the total number of facts in
some mathematical world. Inside this universe we single out a particular result, which
we model as a positive whole number `d`. Two quantities describe `d`.

**Its weight (how much rests on it).** We define the *support* of `d` in the universe
`N` to be the integer

> `support(N, d) = ⌊N / d⌋`,

the number of times `d` fits into `N`. The smaller `d` is, the more multiples of it
fit beneath the ceiling `N`, and so the more of the universe leans on it. A result
that divides the world finely supports a lot; one that carves it coarsely supports
little. This is our model of *gravitational weight*: the number of dependents a result
carries.

**Its cost (how hard it is to prove).** Every positive integer `d` factors into
primes — `12 = 2 · 2 · 3`, `30 = 2 · 3 · 5`, and so on. We define the *proof cost* of
`d` to be the number of prime factors it has, **counted with multiplicity**:

> `proofCost(d) = Ω(d) =` the length of the list of prime factors of `d`.

So `proofCost(12) = 3` (the factors `2, 2, 3`), `proofCost(30) = 3` (the factors
`2, 3, 5`), `proofCost(7) = 1`, and `proofCost(1) = 0`. The intuition is that each
prime factor is an irreducible "step" you must take to build `d` from nothing — an
atom of justification. A number with few prime factors is a result with a short proof;
a number with many is one whose derivation grinds on and on.

With these two rulers in hand, an **anti-gravity theorem** is simply a number `d` that
is *heavy in support but cheap in cost* — large `support(N, d)`, small `proofCost(d)`.
The question is whether such numbers must exist, how cheap they can be, and how the two
rulers constrain each other. That is exactly what the mathematics below settles.

## The fundamental anti-gravity bound

Here is the keystone result of the whole development. It says that proof cost can never
outrun the *logarithm* of size.

> **The logarithmic cost bound.** For every positive integer `d`,
> `2^(proofCost(d)) ≤ d`.

In words: two raised to the proof cost of `d` is at most `d` itself. Equivalently,
taking logarithms, `proofCost(d) ≤ log₂ d`. No matter how you choose `d`, its number of
prime factors is bounded by the base-two logarithm of its magnitude.

Why is this true? Because the smallest possible prime is `2`. Every prime factor of `d`
is at least `2`, and the product of all those factors is exactly `d`. If `d` had `k`
prime factors, then `d` is a product of `k` numbers each at least `2`, so

> `d = (factor₁) · (factor₂) · ⋯ · (factorₖ) ≥ 2 · 2 · ⋯ · 2 = 2^k`.

Hence `2^k ≤ d`, which is precisely `2^(proofCost(d)) ≤ d`. The argument rests on one
humble fact — there is no prime smaller than two — applied relentlessly across the
whole factorization. (The general principle behind it, that a list of numbers each at
least `2` has product at least `2` to the length of the list, is the workhorse lemma of
the theory.)

This single inequality is the engine of anti-gravity. It tells us that *cheap proofs
correspond to small numbers* and, conversely, that *large numbers can hide expensive
proofs but small numbers cannot*. A number near `2^k` can require up to `k` steps to
build, but it can never require more. Proof cost is squeezed under a logarithmic
ceiling.

## The support trade-off: reach is capped by cost

Now we combine the two rulers. First a simple monotonicity principle about division:
if you increase the divisor, the quotient cannot increase.

> **Denominator antitonicity.** If `0 < a ≤ b`, then `⌊N / b⌋ ≤ ⌊N / a⌋`.

A bigger denominator means fewer copies fit beneath the ceiling. Combining this with
the logarithmic cost bound — where the bigger denominator is `d` and the smaller one is
`2^(proofCost(d))` — yields the central trade-off of the entire theory.

> **The anti-gravity support trade-off.** For every positive integer `d` and every
> universe size `N`,
> `support(N, d) ≤ ⌊N / 2^(proofCost(d))⌋`.

Read this slowly, because it is the moral of the story written as an inequality. The
support of a result — how much of the universe rests on it — is bounded above by `N`
divided by `2` raised to its proof cost. **Each additional unit of proof cost at most
halves the ceiling on how much the result can support.** A result that costs ten steps
to prove can support at most about `N / 1024` of the universe. A result that costs one
step can support up to `N / 2`. And a result that costs *nothing* can, in principle,
support the entire universe.

This is the precise sense in which expensive theorems cannot be load-bearing and only
cheap theorems can. Heavy proofs sink; light proofs float. The trade-off is not a
tendency or a heuristic — it is an exact bound that holds for every number without
exception.

## The lightest giants: units and primes

The model rewards us with vivid extreme cases that match mathematical experience
exactly.

**The number 1 — the ultimate anti-gravity object.** It has no prime factors at all,
so `proofCost(1) = 0`. Its support is `⌊N / 1⌋ = N`: it holds up the *entire* universe.
Zero cost, maximal weight. In our model the integer `1` is the perfect foundational
truth — the trivial fact that everything quietly depends on and that costs nothing to
establish. It is the mathematical analogue of the ground beneath the cathedral.

**The primes — the cheapest nontrivial load-bearers.** A prime `p` has exactly one
prime factor, itself, so `proofCost(p) = 1`. The trade-off then caps its support at
`⌊N / 2⌋`: a prime can hold up as much as half the universe on a single step of proof.
These are the lightest possible *nontrivial* results — the irreducible axioms of the
world, each shouldering up to half of everything for the price of one prime step. It is
no accident that the primes are exactly the numbers mathematicians treat as the atoms of
arithmetic.

**The opposite extreme — powers of two.** The number `2^k` has proof cost exactly `k`,
the largest cost possible for its size, since it is built from the smallest possible
prime repeated as many times as possible. Such numbers are the *heaviest* relative to
their magnitude: they pack maximal proof cost into minimal size, and the trade-off
correspondingly caps their support hard. They are the leaden theorems — laborious to
build and structurally peripheral.

Between these poles lies every other number, and the trade-off arranges them all on a
single axis from weightless-and-foundational to costly-and-marginal.

## Why anti-gravity theorems are everywhere

The model also explains the empirical hunch that anti-gravity results are not rare
curiosities but a substantial fraction of any mathematical world. The reason is that
cheap numbers are abundant. Because proof cost is bounded by `log₂ d`, the cost grows
agonizingly slowly as numbers get larger — doubling a number adds at most one to its
maximum possible cost. The vast majority of small numbers have only a few prime
factors, and small numbers are exactly the ones with large support. So the two
desirable properties — low cost and high support — pull in the *same* direction toward
the small numbers, and there are many small numbers carrying high weight.

This is the structural reason mathematics feels the way it does. The results you meet
first, the ones small and simple enough to teach to beginners, are precisely the ones
positioned to support the most. Difficulty and importance are not the same axis; in
fact, under this model they are gently opposed. The cathedral is held up by its
lightest stones because lightness and load-bearing capacity arise from the same source:
being small, being early, being divisible into the rest of the world.

## What we have actually proved

It is worth being exact about the claims, because every one of them is established with
full rigor in the underlying formal development. The complete logical content is:

1. **Support is division.** `support(N, d) = ⌊N / d⌋`, by definition — the count of how
   many times a result fits beneath the universe's ceiling.

2. **A product lemma.** Any list of natural numbers each at least `2` has product at
   least `2` raised to the length of the list. This is the combinatorial heart of the
   logarithmic bound.

3. **The logarithmic cost bound.** For positive `d`, `2^(proofCost(d)) ≤ d`. Proof cost
   never exceeds `log₂` of magnitude.

4. **Denominator antitonicity.** For `0 < a ≤ b`, `⌊N / b⌋ ≤ ⌊N / a⌋`. Larger divisors
   give smaller quotients.

5. **The anti-gravity support trade-off.** For positive `d`,
   `support(N, d) ≤ ⌊N / 2^(proofCost(d))⌋`. A result's reach is capped by the universe
   size divided by two to its proof cost.

These five statements together constitute a complete, exact theory of the anti-gravity
phenomenon in the integer model. Nothing here is conjectural; the surprising part is
that so faithful a picture of "important but easy" results can be captured by something
as elementary as counting prime factors.

## The view from here

We chose the integers as our laboratory because they make the two rulers — weight and
cost — perfectly concrete and let us prove sharp inequalities about them. But the
phenomenon the model captures is general, and the natural next steps are about carrying
it into richer settings. One can replace the all-or-nothing dependency "`d` divides
into `N`" with a *weighted* notion that records how many times or how critically one
result invokes another, and ask whether the same averaging bounds survive. One can
replace direct support with *transitive* support — counting not just the immediate
dependents of a result but everything reachable through them — and re-derive
anti-gravity against that stronger measure. And one can run the whole calculus on the
real dependency graph of a large mathematical library, extracting its empirically
anti-gravity results and comparing them with our intuitions about which lemmas are
"foundational."

What the integer model gives us is a proof of concept in the most literal sense: a
fully precise world in which the lightest theorems really do hold up the most, in which
the trade-off between proof cost and structural reach is an exact inequality, and in
which the humble number `1` sits at the bottom of everything, weightless and
indispensable. The cathedral's lightest stones bear its heaviest loads — and now we can
say exactly why.
