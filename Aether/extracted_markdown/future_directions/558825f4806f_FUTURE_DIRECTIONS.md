# Future Directions — The Fibonacci Rank of Apparition as a Lattice Morphism

## Synthesis

This cycle took the catalog's theory of the Fibonacci **rank of apparition**
`z(m) = apparitionRank m` (the least `k > 0` with `m ∣ F k`, proved to exist
unconditionally for every `m ≥ 1` in `Catalog/Novelty/FibApparitionExistence.lean`, with
the characterization `m ∣ F n ↔ z(m) ∣ n`) and asked a structural question: *how does `z`
interact with the divisibility lattice on moduli?* The new file is
`Catalog/Novelty/FibApparitionLattice.lean`, which imports and builds directly on the
existence file.

The central discovery is that `z` is a **join-morphism**: `z(lcm a b) = lcm(z a, z b)` for
**all** `a, b` (`apparitionRank_lcm`). This strictly generalizes the catalog's earlier
*coprime* multiplicativity `fibEntry(a·b) = lcm(z a, z b)` (only the `gcd a b = 1` case,
where `lcm a b = a·b`). The proof is conceptually clean and we isolated it as
`rankFunction_lcm_abstract`: the characterization says the "appearance set" of `m` is
exactly the multiples of `z(m)`, so taking `lcm` of moduli *intersects* appearance sets,
and the intersection of two sets-of-multiples is the set-of-multiples of the `lcm`. The
abstract lemma depends only on the "appearance ↔ rank divides index" pattern and on a
conjunctive `lcm` law — not on Fibonacci numbers at all. Extending `z` by `z(0) = 0`
(`apparitionRank_zero`) made the characterization total (`fib_dvd_iff_rank_dvd`), so the
join law and monotonicity (`apparitionRank_dvd_of_dvd`) hold with **no positivity
hypotheses whatsoever**.

The Critic phase produced the most informative negative result: the dual **meet law
fails**. `z(gcd a b) = gcd(z a, z b)` is false (`apparitionRank_meet_fails`), witnessed by
`a = 2, b = 17` (coprime, so `z(gcd) = z(1) = 1`, yet `gcd(z 2, z 17) = gcd(3, 9) = 3`).
The structural reason is sharp: `lcm(a,b) ∣ F n` is the *conjunction* of `a ∣ F n` and
`b ∣ F n`, whereas `gcd(a,b) ∣ F n` is *not* a Boolean combination of them — there is no
"or" law. So `z` respects the operation backed by "and" on appearance but not the one that
would need "or". Notably the witness has comparable ranks (`3 ∣ 9`), refuting the naive
guess that meet-failure is caused by `∣`-incomparable ranks; this asymmetry organizes the
directions below.

## Results Summary

- `apparitionRank_zero`: proved — `z(0) = 0`, the degenerate-modulus normalization that
  makes the characterization total.
- `fib_dvd_iff_rank_dvd`: proved — `m ∣ F n ↔ z(m) ∣ n` for **all** `m` (including
  `m = 0`), extending the catalog's `m ≥ 1` characterization.
- `apparitionRank_eq`: proved — pins down `z(m)` from a minimal positive witness; the
  computational workhorse for evaluating concrete ranks.
- `rankFunction_lcm_abstract`: proved — the join law for **any** abstract appearance/rank
  system, decoupled from Fibonacci specifics.
- `apparitionRank_lcm`: proved — **main result**, `z(lcm a b) = lcm(z a, z b)` for all
  `a, b`; generalizes the catalog's coprime multiplicativity.
- `apparitionRank_dvd_of_dvd`: proved — `z` is monotone for divisibility
  (`a ∣ b → z a ∣ z b`), an immediate corollary of the join law.
- `apparitionRank_one`, `apparitionRank_two`, `apparitionRank_seventeen`: proved —
  concrete ranks `z 1 = 1`, `z 2 = 3`, `z 17 = 9`.
- `apparitionRank_meet_fails`: proved (disproof) — explicit counterexample showing `z` is
  **not** a meet-morphism; a join-but-not-meet lattice map.

## Research Directions

### Direction 1: Transport the join law to multiplicative orders / Mersenne sequences
**Hypothesis**: For a base `a`, the rank of apparition `w(m)` of the sequence `u n = aⁿ − 1`
(the least `k > 0` with `m ∣ aᵏ − 1`, i.e. the multiplicative order of `a` mod `m` for `m`
coprime to `a`) satisfies `w(lcm p q) = lcm(w p, w q)`.
**Test**: Instantiate `rankFunction_lcm_abstract` with `appears m n := m ∣ aⁿ − 1` and the
order function, after proving the characterization `m ∣ aⁿ − 1 ↔ ord_m(a) ∣ n` (via
`ZMod`/`orderOf` API). The abstract lemma then closes it with two inputs.
**Why now**: `rankFunction_lcm_abstract` already exists and asks for exactly two inputs;
the catalog's `FibonacciEntryPointInvariant.lean` already supplies the Mersenne
strong-divisibility identity `gcd(aᵐ−1, aⁿ−1) = a^{gcd m n}−1`, half the machinery. The key
insight is that the join law never touched Fibonacci numbers — it is a statement about
"appearance = multiples of the rank," so any sequence with that characterization inherits
it for free.
**If true**: One abstract theorem unifies the apparition-lattice structure of Fibonacci
numbers and of multiplicative orders — a genuine cross-domain bridge.
**If false**: It would reveal that the order function lacks the clean appearance
characterization, pinpointing where the "set of multiples" picture degrades.

### Direction 2: Characterize exactly when the meet law holds
**Hypothesis**: `z(gcd a b) = gcd(z a, z b)` holds for a *characterizable* family of pairs;
since the obvious guess "ranks are `∣`-comparable" is already refuted by `a=2, b=17` (where
`3 ∣ 9` yet the law fails), the correct invariant is conjectured to involve how the prime
factorization of `gcd(a,b)` sits inside those of `a` and `b` — concretely, equality holds
iff `z(gcd a b) = gcd(z a, z b)` can be read off from a *primitive-divisor* alignment.
**Test**: Using `apparitionRank_eq` as an evaluator, run a computational census over small
`a, b`, classify the equality/failure pattern, then attempt a proof of the conjectured
characterization (the `⇐` direction should follow from the join law plus
`apparitionRank_dvd_of_dvd`).
**Why now**: This cycle produced both a clean failure and the exact tools
(`apparitionRank_eq`, the join law, monotonicity) to test boundary cases rapidly. The key
insight is that meet-failure is *not* a comparability phenomenon, so the next invariant
must be arithmetic (factorization-based) rather than order-theoretic.
**If true**: Completes the lattice picture — a decision procedure for when `z` is locally a
full lattice morphism.
**If false**: The refined counterexamples will expose a still-finer obstruction, likely
tied to ramification of primes dividing `gcd(a,b)`.

### Direction 3: Prime-power reduction and Wall's question
**Hypothesis**: `z(pᵉ) = p^{max(0, e − e₀)} · z(p)` where `e₀ = v_p(F_{z(p)})`; combined with
the join law, this reduces *all* rank computation to the prime case.
**Test**: Prove `z(p) ∣ z(pᵉ)` (already a special case of `apparitionRank_dvd_of_dvd`) and
`z(pᵉ) ∣ pᵉ⁻¹ · z(p)` using lifting-the-exponent for Fibonacci numbers from
`Catalog/Shared/FibonacciLTE.lean`; the exact power is Wall's question territory.
**Why now**: The join law (this cycle) plus existing LTE infrastructure means the only
missing piece is the prime-power case; everything composite then follows from
`apparitionRank_lcm` applied to a coprime factorization. The key insight is that the join
law turns "compute `z` on all of ℕ" into "compute `z` on prime powers."
**If true**: A complete, computable description of `z` from its prime values — the
apparition analogue of the fundamental theorem of arithmetic.
**If false**: A Wall–Sun–Sun-type prime is implicated; even a conditional proof would
sharpen the connection to that open problem.

### Direction 4: The appearance map as a poset embedding
**Hypothesis**: The map `m ↦ A(m) = {n | m ∣ F n}` satisfies `A(m) = z(m)·ℕ` and is
injective modulo equal rank: `A(a) = A(b) ↔ z a = z b`; moreover `A(a) ∪ A(b)` is almost
never again some `A(c)`.
**Test**: Prove `A(m) = {n | z(m) ∣ n}` directly from `fib_dvd_iff_rank_dvd`, then
`A(a) = A(b) ↔ z a = z b` by `Nat.dvd_antisymm`; recast `apparitionRank_meet_fails` as the
statement that appearance sets are not closed under union.
**Why now**: `fib_dvd_iff_rank_dvd` (this cycle) is exactly `A(m) = z(m)·ℕ` in disguise,
and `apparitionRank_meet_fails` is exactly non-closure under union. The key insight is that
the whole theory is the order-embedding `m ↦ z(m)ℕ`, and the meet failure is just the fact
that a union of two ideals of ℕ need not be an ideal.
**If true**: Reframes the theory as a clean order-embedding, clarifying which set
operations are preserved.
**If false**: Two moduli with different ranks sharing an appearance set would contradict
the characterization — a valuable correctness probe of the rank theory.

### Direction 5: Pisano period divisibility
**Hypothesis**: `z(m) ∣ π(m)` for every `m ≥ 1`, where `π(m)` is the Pisano period, and the
quotient `π(m)/z(m) ∈ {1, 2, 4}`.
**Test**: Build `π(m)` as the order of the `fibStep` permutation on `(0,1)` (already
defined in `FibApparitionExistence.lean`), prove `m ∣ F_{π(m)}` to get `z(m) ∣ π(m)` from
`fib_dvd_iff_rank_dvd`, then analyze the quotient.
**Why now**: The pigeonhole/permutation argument that proved apparition existence already
constructs the periodicity; extracting `π(m)` is a small step on the same `fibStep`
machinery, and `fib_dvd_iff_rank_dvd` converts "`m` divides `F_{π(m)}`" into divisibility
of ranks instantly. The key insight is that `fibStep`'s order *is* the Pisano period, so
the period and the rank live on the same object.
**If true**: The first formal link between rank of apparition and Pisano period in this
library — neither concept currently exists in Mathlib.
**If false** (quotient outside `{1,2,4}`): it contradicts a classical theorem, almost
certainly signaling a formalization bug — a useful correctness probe.
