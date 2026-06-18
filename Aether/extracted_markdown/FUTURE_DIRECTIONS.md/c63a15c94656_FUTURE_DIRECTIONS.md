# Future Directions — The Rank of Apparition as a Universal Lattice Morphism

## Synthesis

The previous cycle distilled Fibonacci apparition theory down to a single **spine**, the
biconditional `m ∣ F n ↔ rank m ∣ n`, and re-derived it independently in three places:
`RankOfApparition.fibRank_dvd_iff`, `FibonacciApparitionLattice.fibEntry_lcm`, and the
primitivity layer of `StrongDivSeq`. This cycle performs the **Grothendieck-style
unification** those parallel threads were asking for. In
`Catalog/Bridges/AbstractRankOfApparition.lean` we define a single rank-of-apparition functor

```
rank u : (divisibility lattice of moduli) → (divisibility lattice of indices)
```

for an *arbitrary* strong divisibility sequence `u`, and prove the spine
(`rank_dvd_iff`), the order-morphism law (`rank_dvd_of_dvd`), the sharp join law
(`rank_lcm`), and the meet bound (`rank_gcd_dvd`) **once**, at this level of generality and
with no primitivity hypothesis. The Fibonacci theory drops out as the instance `Nat.fib`
(`fib_rank_lcm`), and — crucially — a genuinely new instance appears: the Mersenne sequence
`n ↦ aⁿ − 1`, whose rank of apparition is shown to **equal the multiplicative order**
`orderOf (a : ZMod d)` (`mersenne_rank_eq_orderOf`). The same arithmetic invariant now wears
two faces, one number-theoretic and one group-theoretic.

## Results Summary

- `rank_dvd_iff` — the universal spine for any strong divisibility sequence.
- `rank_dvd_of_dvd`, `hasRank_lcm`, `rank_lcm`, `rank_gcd_dvd` — `rank u` is an order
  morphism and a join (lcm) morphism, and a sub-meet-morphism of the divisibility lattice.
- `fib_isStrongDivSeq`, `fib_hasRank`, `fib_rank_lcm` — the Fibonacci instance, recovering
  the catalog's `fibEntry`/`fibRank` lattice laws as corollaries.
- `mersenne_isStrongDivSeq`, `mersenne_dvd_iff_pow_eq_one`, `mersenne_rank_eq_orderOf` — the
  cross-domain bridge: Mersenne rank of apparition = multiplicative order in `ZMod d`.

All theorems compile with `sorry = 0` and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Research Directions

### 1. The rank functor is a join morphism but provably not a meet morphism — measure the defect.

The abstract `rank_gcd_dvd` gives `rank u (gcd a b) ∣ gcd (rank u a) (rank u b)`, and the
Fibonacci witness `FibonacciApparitionLattice.fibEntry_gcd_not_exact` shows the divisibility
can be strict. **Conjecture:** for every strong divisibility sequence `u` whose terms are
eventually strictly increasing, the "meet defect" `gcd (rank u a) (rank u b) / rank u (gcd a b)`
is bounded by a quantity depending only on the prime that is shared between `a` and `b` but
"doubled" in the index lattice — concretely, it always divides `lcm (rank u a) (rank u b) /
rank u (lcm a b)`, which the join law forces to be `1`, so the defect should be controlled by
ramification at a single prime. The key insight is that **the failure of the meet law is
localized at exactly the primes where apparition indices ramify** (where `rank u (p^{k+1}) ≠
rank u (p^k)`), so the global lattice defect reduces to a purely local, per-prime computation.
Why now? We have the join law and the meet bound in one uniform statement, so the defect is
now a single well-typed quantity rather than an informal observation buried in the Fibonacci
file — it can finally be stated and bounded abstractly.

### 2. Wall's prime-power law as a fixed point of the rank functor under p-adic refinement.

For Fibonacci, the rank of a prime power satisfies Wall's law
`rank (p^{e+1}) = p · rank (p^e)` for `e` past the initial p-adic valuation of
`F_{rank p}`. With the abstract `rank` functor and the catalog's `fib_lte`
(Lifting-the-Exponent), this is exactly the statement that the rank functor **intertwines the
"multiply-modulus-by-p" map with the "multiply-index-by-p" map**, off a finite initial
segment. The key insight is that LTE is precisely the assertion that the rank functor commutes
with the p-adic Frobenius on both lattices, making Wall's law a naturality square rather than a
case analysis. **Falsifiable form:** `rank (fun n => aⁿ − 1) (p^{e+1}) = p · rank (...) (p^e)`
should hold for the Mersenne sequence too whenever `p ∤ a` and `p` is odd, with the *same*
exceptional initial segment governed by `v_p(a^{ord} − 1)`. Why now? `mersenne_rank_eq_orderOf`
turns this into a statement about `orderOf (a : ZMod (p^e))`, where the group-theoretic LTE for
multiplicative orders is already classical and within reach of the existing `fib_lte` machinery.

### 3. Density of joint apparition is multiplicative across independent sequences.

`StrongDivSeq.apparition_count` shows the apparition indices of a primitive divisor of `u n`
have natural density `1/n`. Combining two *different* strong divisibility sequences `u, v`
(e.g. Fibonacci and Mersenne), **conjecture:** the joint density of indices `k` with
`p ∣ u k` and `q ∣ v k` is exactly `1 / lcm(rank u p, rank v q)`, i.e. the two apparition
phenomena are asymptotically independent and the density multiplies through the lcm. The key
insight is that the spine turns each apparition condition into a congruence `rank ∣ k`, so the
joint set is an intersection of arithmetic progressions whose density is governed by the
Chinese Remainder Theorem on the two ranks — cross-sequence independence becomes coprimality of
the two ranks. Why now? We have a *single* `rank` definition that applies verbatim to both
sequences, so "the rank of `p` in Fibonacci" and "the rank of `q` in Mersenne" are now objects
of the same type and can be fed to one CRT/density argument.

### 4. A rank functor for any Lucas sequence, with the discriminant controlling totality.

Both `Nat.fib` and `n ↦ aⁿ − 1` are Lucas sequences `U_n(P, Q)`. **Conjecture:** every
non-degenerate Lucas sequence `U(P,Q)` with `gcd(P,Q)=1` is a strong divisibility sequence, so
the entire `AbstractRankOfApparition` development applies, and `HasRank (U(P,Q)) m` holds for
all `m` coprime to `Q` — with the rank dividing `m - (D/m)` where `D = P² − 4Q` is the
discriminant and `(D/m)` is the Jacobi symbol (the abstract analogue of the catalog's
`entry_point_dvd_sq_sub_one`). The key insight is that the discriminant `D` is the single datum
that determines totality of the rank functor, unifying Fibonacci (`D = 5`) and Mersenne-type
families under one parameterized object. Why now? The strong-divisibility hypothesis is the
*only* input to every abstract theorem in this file, so as soon as `U(P,Q)` is shown to satisfy
it, all four lattice laws transfer for free — no per-sequence reproof is needed.

### 5. Carmichael's primitive-divisor theorem as surjectivity of the rank functor onto a tail.

The catalog's `Catalog/Shared/CarmichaelProof.lean` verifies that `F_n` has a primitive prime
divisor for composite `n ∈ [13, 10000]` computationally, but leaves the infinite tail open (and
the file currently cannot even build, as it imports a missing `Shared.CarmichaelHelper`).
Restated through the rank functor, "`F_n` has a primitive prime divisor" is exactly "`n` is in
the **image** of `p ↦ rank Nat.fib p` over primes `p`", i.e. some prime has rank precisely `n`.
**Conjecture:** the rank functor `rank Nat.fib` is surjective onto `{n : n ∉ {1,2,6,12}}` when
restricted to prime moduli, and the cyclotomic-Fibonacci factor `Φ_n` (defined by
`F_n = ∏_{d∣n} Φ_d`) satisfies `Φ_n > n` for all `n > 12`, which forces a prime of rank exactly
`n`. The key insight is that surjectivity onto the tail is equivalent to the size bound
`Φ_n > (largest prime factor of n)`, converting an existence theorem into a single growth
estimate `Φ_n ≥ α^{φ(n)} − (smaller terms)`. Why now? With the abstract spine in hand, the only
missing ingredient is the cyclotomic factorization `F_n = ∏_{d∣n} Φ_d` and its size estimate;
the entry-point/LTE infrastructure (`fib_dvd_iff_entry_dvd`, `fib_lte`) already supplies the
classification of which primes can divide `Φ_n` non-primitively, so the remaining work is a
self-contained growth lemma rather than a from-scratch development.
