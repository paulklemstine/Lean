# Computational Evidence — Symmetric Group Generation Probability

We study `p_n`, the probability that two **ordered**, independent, uniformly
random elements of the symmetric group `S_n = Equiv.Perm (Fin n)` generate the
whole group:

    p_n = (# ordered pairs (a,b) with ⟨a,b⟩ = S_n) / (n!)².

## 1. Small-case calculations (brute force, verified in Lean)

The generated subgroup `⟨a,b⟩` was computed by an explicit Finset fixpoint of
the closure operator `s ↦ s ∪ {xy} ∪ {x⁻¹}` and compared against `n!`.

| n | # generating ordered pairs | (n!)² | p_n            |
|---|----------------------------|-------|----------------|
| 2 | 3                          | 4     | **3/4 = 0.750**|
| 3 | 18                         | 36    | **1/2 = 0.500**|

These two values were obtained by `#eval` on a computable brute-force closure
(see the `genCount` experiment). `n = 4, 5` are correct in principle by the same
method but exceed the interactive evaluator's time budget here, so they are *not*
reported as verified.

## 2. Consistency with the proved bounds

* For every `n ≥ 2`, the file `SymmetricGroupGeneration.lean` proves
  `genProb ≤ 3/4`. Both computed values respect this: `3/4 ≤ 3/4` and
  `1/2 ≤ 3/4`.
* The complement bound `bothEvenProb = 1/4` (exact) is also consistent: at least
  `1/4` of all pairs are "both even" and therefore non-generating.

## 3. The asymptotic picture (Dixon 1969, not formalized)

A classical theorem of J. D. Dixon states that
`p_n → 3/4` as `n → ∞`. The intermediate values dip *below* `3/4` (e.g.
`p_3 = 1/2`), so the ceiling `3/4` proved here is attained at `n = 2` and again
only in the limit. This is exactly the behavior our parity argument explains:
the `1/4` mass of "both even" pairs is an unavoidable, `n`-independent loss, and
Dixon's theorem says that *asymptotically this is the only loss*.

## 4. Counterexample hunt

The universal claim under test is `genProb n ≤ 3/4` for `n ≥ 2`. No
counterexample is possible: the inclusion `genSet ⊆ {pairs not both even}` is
proved unconditionally, and the "both even" set has measure exactly `1/4`. The
computed cases (`3/4`, `1/2`) provide positive confirmation rather than a
counterexample.
