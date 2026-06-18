# Future Directions — The Rank-of-Apparition Engine, Seventh Cycle

## Synthesis

This cycle delivered `Catalog/Applications/StrongDivPrimitiveCriterion.lean`, a self-contained,
`sorry`-free upper floor on top of the abstract strong-divisibility theory in
`Catalog/Applications/StrongDivisibilitySequences.lean`. Where the parent file required the
caller to *supply* a primitive index before any apparition law could be invoked
(`StrongDivSeq.dvd_iff_index_dvd_of_primitive`, `StrongDivSeq.simultaneous_apparition`), this
cycle *manufactures* that index canonically from the divisor alone:

    rank u p := sInf {k | 0 < k ∧ p ∣ u k}.

The headline results are:

* `StrongDivSeq.rank_primitive` — the rank is always a primitive index, so the existence of a
  primitive index is never a side hypothesis again.
* `StrongDivSeq.dvd_iff_rank_dvd` — **the strong primitive-divisor criterion**:
  `p ∣ u m ↔ rank u p ∣ m`. The divisibility set of any divisor is *exactly* the multiples of
  its rank, for every strong divisibility sequence at once.
* `StrongDivSeq.isPrimitive_iff_eq_rank` — sharpens `StrongDivSeq.isPrimitive_unique`: the unique
  primitive index is *computable* as the rank.
* `StrongDivSeq.joint_dvd_iff_lcm_rank_dvd` — a rank-only join law:
  `(p ∣ u n ∧ q ∣ u n) ↔ lcm (rank u p) (rank u q) ∣ n`.
* `fib_dvd_iff_rank_dvd`, `mersenne_dvd_iff_rank_dvd` — the same criterion specialized to the
  Fibonacci sequence and the `aⁿ − 1` family, recovering both classical laws of apparition
  (Fibonacci entry points; multiplicative order) from one definition and one proof.

## Results Summary

Six new `sorry`-free theorems plus two corollary specializations, all depending only on the
standard axioms `propext`, `Classical.choice`, `Quot.sound`. The work strictly *extends* the
catalog (it imports and reuses `IsStrongDivSeq`, `IsPrimitive`, `dvd_iff_index_dvd_of_primitive`,
`isPrimitive_unique`, `fib_isStrongDivSeq`, `mersenne_isStrongDivSeq`) rather than reproving
anything, and it unifies the Fibonacci-specific apparition results with the Mersenne family.

## Research Directions

### Direction 1 — Multiplicativity of the rank over coprime divisors

Conjecture: for a strong divisibility sequence `u` and coprime appearing divisors `p`, `q`
(`Nat.Coprime p q`), the product `p * q` appears and `rank u (p*q) = lcm (rank u p) (rank u q)`.
This is the natural strengthening of `joint_dvd_iff_lcm_rank_dvd`: the join law says the *common*
apparition set is governed by the lcm of ranks; the conjecture says the rank of the *product*
divisor equals that lcm exactly. Falsifiable: a single counterexample with `p*q ∣ u n` for some
`n` not a multiple of `lcm (rank u p) (rank u q)` kills it. The key insight is that `p*q ∣ u n`
is equivalent to `p ∣ u n ∧ q ∣ u n` precisely when `p, q` are coprime, so the join law should
collapse into a rank identity. Why now? `joint_dvd_iff_lcm_rank_dvd` is already proven and
coprimality of divisors is exactly the hypothesis that turns `∧` of divisibilities into a single
divisibility (`Nat.Coprime.mul_dvd_of_dvd_of_dvd`), so the missing step is purely a rank lemma.

### Direction 2 — The rank divides the index period (Pisano/order bridge)

Conjecture: for the Fibonacci sequence, `rank Nat.fib p ∣ Nat.fib`-period-related quantities; more
precisely, for a prime `p`, `rank Nat.fib p ∣ p - (5 / p)` (Legendre symbol), the classical entry-
point divisibility law. Abstractly, for `u n = aⁿ - 1` with `gcd a p = 1`, `rank u p` equals the
multiplicative order of `a` mod `p`, hence divides `p - 1`. Falsifiable by direct computation over
small primes. The key insight is that the rank we defined is *definitionally* the entry point /
order, so the deep number-theoretic divisibility laws become statements about `rank` that can be
imported wholesale from Mathlib's `ZMod.orderOf` and Fibonacci-mod-`p` API. Why now? The criterion
`dvd_iff_rank_dvd` already identifies `rank` with the order/entry point operationally; connecting
it to `orderOf` is the bridge that lets every order theorem in Mathlib descend onto Fibonacci.

### Direction 3 — Density spectrum of joint apparition for k divisors

Conjecture: for appearing divisors `p₁,…,p_k`, the natural density of indices `n` with all
`pᵢ ∣ u n` equals `1 / lcm (rank u p₁) … (rank u p_k)`, generalizing the parent file's
`simultaneous_apparition_count` (which used given primitive indices) to the rank formulation, and
extending `joint_dvd_iff_lcm_rank_dvd` from two divisors to `k`. Falsifiable: compute the count
`#{e < N : ∀ i, pᵢ ∣ u (e+1)}` for a triple and compare with `N / lcm ...`. The key insight is
that `Finset.lcm` of the ranks turns the whole family into a single apparition class, so
`Nat.card_multiples` applies verbatim once the predicate is rewritten. Why now? The finite-family
join law `simultaneous_apparition_finset` already exists in the parent file; combining it with the
rank manufacturing of this cycle gives the counting statement essentially for free.

### Direction 4 — Failure boundary: sequences that are divisibility but not strong

Conjecture (adversarial): there exists a *divisibility* sequence `u` (i.e. `m ∣ n → u m ∣ u n`)
that is **not** a strong divisibility sequence and for which `dvd_iff_rank_dvd` is FALSE — there is
a divisor `p` and index `m` with `p ∣ u m` but `rank u p ∤ m`. This pins down exactly which
hypothesis in `dvd_iff_rank_dvd` is load-bearing: the strong (meet) law, not the weak divisibility
law. The key insight is that the forward direction of the criterion is the only place the meet law
`dvd_gcd_index_iff` is used, so dropping strongness should break precisely that direction while
leaving the backward direction intact. Why now? The proof of `dvd_iff_rank_dvd` is a one-liner
delegating to `dvd_iff_index_dvd_of_primitive`, so its hypothesis usage is transparent and a
minimal counterexample (e.g. a hand-built sequence on small indices) is within reach of `decide`.

### Direction 5 — Rank as a sequence invariant under reindexing

Conjecture: if `u` and `v` are strong divisibility sequences with `u = v ∘ φ` for a multiplicative
bijection `φ` of indices fixing primes, then `rank u p` and `rank v p` are related by `φ`. More
concretely, rank is preserved under passing from `Nat.fib` to the Lucas-paired sequence studied in
`Catalog/Applications/FibonacciLucasBridge.lean`. Falsifiable by computing ranks on both sides for
small `p`. The key insight is that the rank is the sInf of an apparition set, so any index
bijection that preserves the divisibility predicate transports the rank by its action on the
minimizer. Why now? The catalog already contains the Fibonacci–Lucas bridge, so the two sequences
and their cross-divisibility lemmas are in scope, making this a concrete reindexing experiment
rather than an abstract one.
