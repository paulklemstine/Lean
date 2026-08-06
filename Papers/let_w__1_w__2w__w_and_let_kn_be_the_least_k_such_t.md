# Computational evidence

All numbers below were computed by direct enumeration before the formal proofs were
written; every claim that is *asserted* in the final artefact is proved in Lean
(`Catalog/Pythagorean/TowerRadix.lean`, `Catalog/Pythagorean/MixedRadix.lean`) and none of
the statements below is relied on as evidence in place of a proof.

## 1. The tower weights

`W₀ = 1`, `Wₖ₊₁ = 2^Wₖ · Wₖ`:

| k | Wₖ | log₂ Wₖ = ∑_{i<k} Wᵢ |
|---|-----|----------------------|
| 0 | 1 | 0 |
| 1 | 2 | 1 |
| 2 | 8 | 3 |
| 3 | 2048 | 11 |
| 4 | 2^2059 (620 decimal digits) | 2059 |
| 5 | 2^(2^2059 + 2059) | 2^2059 + 2059 |

The identity `Wₖ = 2^(∑_{i<k} Wᵢ)` is visible in the third column and is proved as
`TowerRadix.W_eq_two_pow_sumW`.

## 2. `K(n)` versus `L₂(n)` (conjecture 1)

`K(n)` = least `k` with `n < Wₖ`; `L₂(n)` = number of iterations of `x ↦ ⌈log₂(x+1)⌉`
needed to reach a value `≤ 2`.

| n | K(n) | L₂(n) | K − L₂ |
|---|------|-------|--------|
| 0 | 0 | 0 | 0 |
| 1 | 1 | 0 | 1 |
| 2 | 2 | 0 | **2** |
| 3 | 2 | 1 | 1 |
| 7 | 2 | 2 | 0 |
| 8 | 3 | 3 | 0 |
| 1000 | 3 | 4 | −1 |
| 2047 | 3 | 4 | −1 |
| 2048 | 4 | 4 | 0 |
| 10¹⁸ | 4 | 4 | 0 |
| W₄ − 1 | 4 | 5 | −1 |

Exhaustive check on `0 ≤ n < 5000`: `max |K − L₂| = 2`, attained only at `n = 2`; the
difference distribution is `{−1: 1920, 0: 3077, 1: 2, 2: 1}`.  No counterexample to
`|K − L₂| ≤ 2` was found.  The formal proof (`TowerRadix.abs_K_sub_L2_le_two`) shows in
addition that the two one-sided bounds `K ≤ L₂ + 2` and `L₂ ≤ K + 1` are the true shape of
the estimate, so the value `+2` is attained but `−2` is not.

## 3. Zeckendorf indices (conjecture 5)

`Z(n)` = largest Fibonacci index `m` with `F_m ≤ n` (the top index of the canonical
Zeckendorf expansion).

| n | Z(n) | ⌊log₂ n⌋ + 1 |
|---|------|--------------|
| 1 | 2 | 1 |
| 2 | 3 | 2 |
| 3 | 4 | 2 |
| 10 | 6 | 4 |
| 100 | 11 | 7 |
| 10⁶ | 30 | 20 |
| 10¹² | 59 | 40 |

The bounds `⌊log₂ n⌋ + 1 ≤ Z(n) ≤ 2⌊log₂ n⌋ + 3` were checked for all `1 ≤ n < 20000`
(no failures) and are proved as `TowerRadix.Zidx_bounds`.  The ratio `Z(n)/log₂ n` hovers
around `1/log₂ φ ≈ 1.44`, consistent with the constants `1` and `2` in the formal bounds.

## 4. Compression bounds (conjectures 2 and 5)

For `k = 2` there are `W₂ = 8` valid tower representations and `∑_{i<2} Wᵢ = 3`, so a code
needs a codeword of length `≥ 3`; writing digit `0` in `W₀ = 1` bit and digit `1` in
`W₁ = 2` bits gives total length exactly `3`.

For a general interval `[0, n]` the naive bound `⌈log₂(n+1)⌉` is *false* for arbitrary
injective codes: with `n = 2` the code `0 ↦ ε`, `1 ↦ 1`, `2 ↦ 0` is injective with maximal
length `1 < 2 = ⌈log₂ 3⌉`.  This is formalized as
`TowerRadix.injective_code_can_beat_clog`, and the corrected bound
`⌈log₂(n+2)⌉ − 1` is `TowerRadix.exists_codeword_length_ge`.  For the tower families the
naive bound *is* correct, because `Wₖ` is exactly a power of two.

## 5. Balanced tower digits (conjecture 4)

Radices `rₖ = 2^(Wₖ+1)+1` and weights `Uₖ₊₁ = rₖUₖ`:

| k | rₖ | Uₖ | balanced range |
|---|----|----|----------------|
| 0 | 5 | 1 | {0} |
| 1 | 9 | 5 | [−2, 2] |
| 2 | 2^9+1 = 513 | 45 | [−22, 22] |

`U₂ = 45` is checked inside Lean with `decide`, and the representability of `x = 22` at
`k = 2` is an `example` in `Catalog/Pythagorean/MixedRadix.lean`.

## 6. OEIS

The weight sequence `1, 2, 8, 2048, 2^2059, …` grows too fast for a meaningful OEIS entry
beyond its first four terms; searching `1, 2, 8, 2048` returns the doubly exponential
family `a(n+1) = 2^a(n) · a(n)` only as a formula, not as a distinguished catalogued
sequence, so no OEIS identifier is claimed here.  The sequence of exponents
`0, 1, 3, 11, 2059` is the partial-sum sequence of the weights and likewise carries no
claimed identifier.
