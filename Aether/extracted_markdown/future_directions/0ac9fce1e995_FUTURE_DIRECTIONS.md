# Future Directions — A Spectral Duality for Strong Divisibility Sequences, Seventh Cycle

## Synthesis

The previous cycle's `Catalog/Speculative/AutoResearch/StrongDivPrimitiveCriterion.lean` packaged a
*computational* primitive-divisor engine for arbitrary strong divisibility sequences
`u (gcd m n) = gcd (u m) (u n)`, living entirely inside the value monoid `(ℕ, gcd, ·)`. The catalog's
companion files (`Catalog/Applications/StrongDivisibilitySequences.lean`,
`UnifiedRankOfApparition.lean`) developed the apparition/rank *lattice* theory — again on the value
side.

This cycle opens the **dual / spectral side** in
`Catalog/Speculative/AutoResearch/StrongDivValuationDuality.lean`. Factoring every value into prime
powers translates the single multiplicative identity into an entire *family* of meet-semilattice
morphisms — one per prime `p` — carrying the gcd-semilattice on indices to the `min`-semilattice on
the `p`-adic valuation:

> `v_p(u (gcd m n)) = min (v_p(u m)) (v_p(u n))`, where `v_p = (·).factorization p`.

Crucially the translation is **faithful**: for a strictly positive sequence, strong divisibility is
*equivalent* to the assertion that every prime valuation is such a meet-morphism
(`isStrongDivSeq_iff_factorization_min`). This is a small Stone/Gelfand-flavoured duality —
"one identity in `(ℕ, gcd, ·)`" ⟺ "a spectral family of identities in `(ℕ, min)`" — and it sits
directly on top of the existing engine: `dvd_index_gcd` and the strong-div law are the only structural
inputs, and the concrete corollaries reuse `fib_isStrongDivSeq` / `mersenne_isStrongDivSeq` verbatim.

## Results Summary

* `factorization_index_gcd` — the full `Finsupp` meet:
  `(u (gcd m n)).factorization = (u m).factorization ⊓ (u n).factorization`.
* `factorization_index_min` — its prime-pointwise form, i.e. the meet-morphism / spectral law.
* `isStrongDivSeq_of_factorization_min` — the converse for positive sequences: a sequence all of whose
  prime valuations are meet-morphisms is a strong divisibility sequence.
* `isStrongDivSeq_iff_factorization_min` — the **duality**: the two formulations coincide.
* `factorization_mono_of_dvd` — `m ∣ n ⟹ v_p(u m) ≤ v_p(u n)` (valuation monotonicity along
  divisibility towers).
* `fib_factorization_gcd`, `mersenne_factorization_gcd` — the concrete spectral laws for `Nat.fib`
  and `aⁿ − 1`.

All results are `sorry`-free and depend only on `propext / Classical.choice / Quot.sound`.

## Research Directions

### 1. Lift the duality from `min` to a genuine lattice isomorphism on the support.

The spectral law shows each `v_p ∘ u : (ℕ, gcd) → (ℕ, min)` is a meet-morphism; conjecture that for a
strong divisibility sequence that is *also* a join-compatible sequence
(`u (lcm m n) = lcm (u m) (u n)`, which Fibonacci is **not** but `aⁿ − 1` *is*), each `v_p ∘ u` is a
full lattice morphism `(ℕ, gcd, lcm) → (ℕ, min, max)`, so the apparition data is a lattice quotient.
**The key insight is** that strong divisibility already forces `min` on the meet side, so the only
missing half is `max` on the join side, and the catalog's `simultaneous_apparition` join law
(`StrongDivSeq`) is exactly the value-side statement whose spectral shadow is `max`. **Why now?**
`factorization_index_min` is proved and the join law is already in the catalog; assembling them into a
single `Sublattice`/`LatticeHom` statement is a focused packaging task that turns two scattered facts
into one structural isomorphism.

### 2. Read the rank of apparition off the spectrum as a `min`-support threshold.

For a fixed prime `p`, define `z_p = ` least `n>0` with `1 ≤ v_p(u n)`; conjecture
`v_p(u n) ≥ 1 ↔ z_p ∣ n` follows *purely spectrally* from `factorization_index_min` plus
`factorization_mono_of_dvd`, recovering `UnifiedRankOfApparition.rank_dvd_iff` without ever leaving
the valuation side. **The key insight is** that the apparition set `{n | v_p(u n) ≥ 1}` is closed
under `gcd` (meet-morphism) and under multiples (monotonicity), and a subset of `ℕ` closed under both
gcd and multiples is exactly the multiples of its least positive element — a one-line lattice fact.
**Why now?** Both ingredients are now theorems in this file, so the rank theory can be *re-derived*
spectrally and unified with the existing value-side proof, exposing which results are genuinely
dual-invariant.

### 3. A lifting-the-exponent law as exact valuation arithmetic in the dual.

Sharpen monotonicity from the inequality `v_p(u m) ≤ v_p(u n)` (for `m ∣ n`) to the exact LTE-style
identity `v_p(u n) = v_p(u z_p) + v_p(n / z_p)` for `p ∣ u z_p`, `z_p ∣ n` (Fibonacci: `p ∉ {2,5}`),
i.e. the valuation grows by exactly the valuation of the cofactor index. **The key insight is** that
`factorization_mono_of_dvd` already pins the *order* of the valuation tower along `m ∣ n`, so LTE is
the statement that the spectral tower is not merely increasing but *affine in `v_p` of the index* —
converting the engine's `removePrimesOf` recursion into closed-form valuation arithmetic. **Why now?**
The catalog's `...Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors` already targets these
valuation bounds, and this file now supplies the abstract monotone skeleton they refine.

### 4. Use the faithful duality to *transport* theorems between value and spectral sides.

`isStrongDivSeq_iff_factorization_min` is an equivalence of data, so any theorem about
`min`-semilattice morphisms `ℕ → ℕ` transfers to a theorem about strong divisibility sequences and
vice versa; conjecture in particular that the **count** of primes with `v_p(u n) ≥ 1` (the number of
distinct prime divisors `ω(u n)`) is sub-/super-additive along the index lattice in a way governed
solely by the spectral support. **The key insight is** that a faithful duality lets one *choose the
easier side*: `ω(u n) = #{p | v_p(u n) ≥ 1}` is a cardinality of a `min`-support, a purely
combinatorial object, even though `u n` itself may be astronomically large. **Why now?** With the iff
established and `factorization_mono_of_dvd` controlling support inclusion, the support lattice
`n ↦ (u n).factorization.support` is now a well-defined monotone meet-morphism into `Finset ℕ`, ready
for combinatorial estimates.

### 5. Extend the duality beyond `ℕ` to Dedekind domains / global fields.

Replace `(·).factorization` by the family of normalized valuations of a Dedekind domain `R` and
conjecture that an `R`-valued strong divisibility sequence (`u(gcd m n) = gcd(u m, u n)` in the ideal
lattice) is equivalent to each place-wise valuation being a meet-morphism — the genuine
Stone/Gelfand statement "ideal-gcd structure ⟺ spectral (place-indexed) `min` structure".
**The key insight is** that the entire proof in this file uses only `factorization_gcd`
(`= ⊓` of valuations) and unique factorization, both of which hold for the divisor-valuation maps of
any Dedekind domain, so the duality is not special to `ℕ` — only the *positivity* bookkeeping is.
**Why now?** Mathlib's `HeightOneSpectrum` valuation API for Dedekind domains is mature, so the
abstract `min`/meet skeleton proven here can be re-typed over `IsDedekindDomain R` with the same
two-lemma core, generalizing Carmichael/Bang-style primitive divisors to number-field settings.
