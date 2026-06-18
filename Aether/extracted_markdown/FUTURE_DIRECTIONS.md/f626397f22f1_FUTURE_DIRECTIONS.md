# Future Directions — Fibonacci Rank of Apparition as a Lattice Morphism

## Synthesis

This cycle took the catalog's well-developed theory of the Fibonacci **rank of
apparition** `z(m) = apparitionRank m` (the least `k > 0` with `m ∣ F k`, proved to
exist unconditionally for every `m ≥ 1` in `Catalog/Novelty/FibApparitionExistence.lean`,
together with the characterization `m ∣ F n ↔ z(m) ∣ n`) and asked a structural
question: *how does `z` interact with the divisibility lattice on moduli?*

The central discovery is that `z` is a **join-morphism**: `z(lcm a b) = lcm(z a, z b)`
for **all** positive `a, b`. This strictly generalizes the catalog's earlier *coprime*
multiplicativity `z(a·b) = lcm(z a, z b)` (which is only the `gcd a b = 1` special case,
where `lcm a b = a·b`). The proof is conceptually clean: the characterization says the
"appearance set" of `m` is exactly the multiples of `z(m)`, so taking `lcm` of moduli
*intersects* appearance sets, and the intersection of two sets-of-multiples is the
set-of-multiples of the `lcm`. We isolated this as `rankFunction_lcm_abstract`, which
shows the join law is *purely formal* — it depends only on the "appearance ↔ rank
divides index" pattern and not on Fibonacci numbers at all.

The Critic phase produced the most informative negative result: the dual **meet-law
fails**. `z(gcd a b) = gcd(z a, z b)` is false, witnessed by `a = 2, b = 17`
(coprime, so `z(gcd) = z(1) = 1`, yet `gcd(z 2, z 17) = gcd(3, 9) = 3`). The structural
reason is sharp: `gcd(a,b) ∣ F n` is *not* a Boolean combination of `a ∣ F n` and
`b ∣ F n`, whereas `lcm(a,b) ∣ F n` *is* (it is their conjunction). So `z` respects the
operation that corresponds to "and" on appearance, but not the one that would need "or".
This asymmetry is the organizing insight for the directions below.

## Results Summary

- `apparitionRank_eq`: proved — pins down `z(m)` from a minimal witness; the
  computational workhorse for evaluating concrete ranks.
- `apparitionRank_lcm`: proved — **main result**, `z(lcm a b) = lcm(z a, z b)` for all
  positive `a, b`; generalizes the catalog's coprime multiplicativity.
- `apparitionRank_dvd_of_dvd`: proved — `z` is monotone for divisibility
  (`a ∣ b → z a ∣ z b`), an immediate corollary of the join law.
- `apparitionRank_one`, `apparitionRank_two`, `apparitionRank_seventeen`: proved —
  concrete ranks `z 1 = 1`, `z 2 = 3`, `z 17 = 9`.
- `apparitionRank_meet_fails`: proved (disproof) — explicit counterexample showing
  `z` is **not** a meet-morphism; a join-but-not-meet lattice map.
- `rankFunction_lcm_abstract`: proved — the join law holds for any abstract
  appearance/rank system, decoupling it from Fibonacci specifics.

## Research Directions

### Direction 1: Transport the join law to other strong divisibility sequences
**Hypothesis**: For the base-`a` Mersenne/repunit sequence `u n = aⁿ − 1`, the rank of
apparition `w(m)` (least `k > 0` with `m ∣ aᵏ − 1`, i.e. the multiplicative order of `a`
mod `m`) satisfies `w(lcm p q) = lcm(w p, w q)` for moduli coprime to `a`.
**Test**: Instantiate `rankFunction_lcm_abstract` with `appears m n := m ∣ aⁿ − 1` and
the order function, after proving the characterization `m ∣ aⁿ − 1 ↔ ord_m(a) ∣ n`
(Mathlib's `ZMod.orderOf` / `Nat.pow_sub_one`...). The abstract lemma then closes it.
**Why now**: `rankFunction_lcm_abstract` already exists and asks for exactly two inputs;
the catalog's `StrongDivSeq` file (`FibonacciEntryPointInvariant.lean`) already supplies
the Mersenne gcd identity `gcd(aᵐ−1, aⁿ−1) = a^{gcd m n}−1`, half the needed machinery.
**If true**: A single abstract theorem unifies the apparition-lattice structure of
Fibonacci numbers and of multiplicative orders — a genuine cross-domain bridge.
**If false**: It would reveal that the order function lacks the clean appearance
characterization, pinpointing where the "set of multiples" picture degrades.

### Direction 2: Characterize exactly when the meet-law holds
**Hypothesis**: `z(gcd a b) = gcd(z a, z b)` holds **iff** `z a ∣ z b` or `z b ∣ z a`
(i.e. the ranks are `∣`-comparable).
**Test**: Prove the `⇐` direction from the join law plus `apparitionRank_dvd_of_dvd`;
search computationally (with `apparitionRank_eq`) for a comparable-rank pair where it
*fails*, or an incomparable pair where it *holds*, to settle `⇒`.
**Why now**: This cycle produced both a clean failure (`a=2,b=17`, incomparable ranks
`3,9`... note `3 ∣ 9`, so the naive guess needs refinement!) and the exact tools
(`apparitionRank_eq`, the join law) to test boundary cases rapidly.
**If true**: Completes the lattice picture — `z` becomes a morphism precisely on chains.
**If false**: The counterexample (note `gcd(2,17)`: ranks `3,9` ARE comparable yet the
law fails, so the hypothesis as stated is likely refuted) will force a finer invariant,
probably involving how `gcd(a,b)` factors relative to `a` and `b`.

### Direction 3: Prime-power reduction and Wall's question
**Hypothesis**: `z(pᵉ) = p^{max(0, e − e₀)} · z(p)` where `e₀` is the `p`-adic valuation
of `F_{z(p)}`; combined with the join law this reduces *all* rank computation to primes.
**Test**: Prove `z(p) ∣ z(pᵉ)` and `z(pᵉ) ∣ pᵉ⁻¹ · z(p)` using LTE (lifting-the-exponent)
for Fibonacci numbers, which the catalog already has
(`Catalog/Shared/FibonacciLTE.lean`). The exact power is Wall's question territory.
**Why now**: The join law (this cycle) plus existing LTE infrastructure means the only
missing piece is the prime-power case; everything composite then follows for free.
**If true**: A complete, computable description of `z` on all of ℕ from its values on
primes — the apparition analogue of the fundamental theorem of arithmetic.
**If false**: A Wall–Sun–Sun-type prime would be implicated; even a conditional proof
would sharpen the connection to that open problem.

### Direction 4: The appearance map as a poset embedding
**Hypothesis**: The map sending `m` to its appearance set `A(m) = {n | m ∣ F n}` is a
lattice homomorphism `(ℕ_{≥1}, lcm, ·) → (sets of multiples, ∩, ?)` that is *injective
modulo equal rank*: `A(a) = A(b) ↔ z a = z b`.
**Test**: Prove `A(m) = z(m)·ℕ` from the characterization, then `A(a) = A(b) ↔ z a = z b`
by `Nat.dvd_antisymm`. Investigate whether `A(a) ∪ A(b)` is ever again some `A(c)`
(it generally is not — this is the meet-law failure in set language).
**Why now**: `apparitionRank_meet_fails` is exactly the statement that appearance sets
are not closed under union; framing it set-theoretically makes the obstruction precise.
**If true**: Reframes the entire theory as the order-embedding `m ↦ z(m)ℕ`, clarifying
which set operations the embedding preserves.
**If false**: Would mean two moduli with different ranks share an appearance set,
contradicting the characterization — a sanity check that, if it failed, would expose a
bug in the rank theory.

### Direction 5: Pisano period divisibility
**Hypothesis**: `z(m) ∣ π(m)` for every `m ≥ 1`, where `π(m)` is the Pisano period
(the period of `F mod m`), and moreover `π(m)/z(m) ∈ {1, 2, 4}`.
**Test**: Build the Pisano period from the `fibStep` permutation already defined in
`FibApparitionExistence.lean` (its order on `(0,1)`), prove `m ∣ F_{π(m)}` to get
`z(m) ∣ π(m)` from the characterization, then analyze the quotient.
**Why now**: The pigeonhole/permutation argument that proved apparition *existence* this
cycle's foundation already constructs the periodicity; extracting the period `π(m)` is a
small additional step on the same `fibStep` machinery.
**If true**: Gives the first formal link between rank of apparition and Pisano period in
this library — neither concept currently exists in Mathlib.
**If false** (i.e. the quotient takes a value outside `{1,2,4}`): It would contradict a
classical theorem, almost certainly signaling an error in the Pisano-period formalization
rather than new mathematics — a valuable correctness probe.
