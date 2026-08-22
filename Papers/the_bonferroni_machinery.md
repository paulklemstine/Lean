# Computational evidence — cycle v19c, "which marginals feed the Bonferroni machinery"

All numbers below were produced inside the Lean project (`lake env lean` with
`#eval`) by *brute-force enumeration of the entire codebook space*
`H : α → Fin M`, so they are exact integer counts, not samples.  The two
head-line rows are additionally checked by the Lean kernel in
`Catalog/Geometry/ExactFailureMarginal.lean`
(`failure_count_check_three_two`, `failure_count_check_four_three`, both `decide`).

## 1. The exact failure count

Setting: `α = Fin n`, transmitted string `x = 0`, competitor set
`D = univ.erase 0`, so `k = n - 1`.  `failSet` is the set of codebooks for
which some competitor collides with `x`.

Conjectured law (now proved as `ExactFailure.card_failSet_exact`):

```
|failSet| = M^n − (M−1)^k · M^{n−k},      k = |D|
```

| n | M | brute-force `|failSet|` | law prediction | agree |
|---|---|------------------------|----------------|-------|
| 2 | 2 | 2   | 4 − 1·2 = 2      | ✓ |
| 3 | 2 | 6   | 8 − 1·2 = 6      | ✓ |
| 3 | 3 | 15  | 27 − 4·3 = 15    | ✓ |
| 4 | 2 | 14  | 16 − 1·2 = 14    | ✓ |
| 4 | 3 | 57  | 81 − 8·3 = 57    | ✓ |
| 5 | 2 | 30  | 32 − 1·2 = 30    | ✓ |
| 3 | 4 | 28  | 64 − 9·4 = 28    | ✓ |
| 4 | 4 | 148 | 256 − 27·4 = 148 | ✓ |

No counterexample was found; the search covered every codebook in each of the
eight spaces (up to 256 codebooks each).

## 2. Comparison of the four bounds

Exact probability `P = |failSet| / M^n` against

* Bonferroni (catalog, `AlmostLossless.failure_prob_lower_bound_real`): `k/(2M)`,
  valid only when `2(k−1) ≤ M`;
* second moment (new, `BonferroniMarginals.hashing_failure_prob_lower`): `k/(M+k−1)`, unconditional;
* harmonic lower bound from the exact law (`ExactFailure.failure_prob_ge_harmonic`): `k/(M+k)`;
* Shannon union bound (`ExactFailure.failure_prob_le_shannon`): `k/M`.

| n | M | k | `k/(2M)` | `k/(M+k−1)` | `k/(M+k)` | exact `P` | `k/M` |
|---|---|---|----------|-------------|-----------|-----------|-------|
| 2 | 2 | 1 | 1/4  | 1/2 | 1/3 | 1/2   | 1/2 |
| 3 | 2 | 2 | 1/2  | 2/3 | 1/2 | 3/4   | 1   |
| 3 | 3 | 2 | 1/3  | 1/2 | 2/5 | 5/9   | 2/3 |
| 4 | 2 | 3 | 3/4  | 3/4 | 3/5 | 7/8   | 3/2 |
| 4 | 3 | 3 | 1/2  | 3/5 | 1/2 | 19/27 | 1   |
| 5 | 2 | 4 | 1*   | 4/5 | 2/3 | 15/16 | 2   |
| 3 | 4 | 2 | 1/4  | 2/5 | 1/3 | 7/16  | 1/2 |
| 4 | 4 | 3 | 3/8  | 1/2 | 3/7 | 37/64 | 3/4 |

`*` the Bonferroni hypothesis `2(k−1) ≤ M` fails in that row (6 > 2), which is
exactly why the entry exceeds the true probability there; in every row where the
hypothesis holds the Bonferroni value is below the exact probability, and it is
*always* below the second-moment value `k/(M+k−1)` — the numerical shadow of the
proved comparison `BonferroniMarginals.chung_erdos_dominates_bonferroni`.

Observed ordering in every admissible row:
`k/(2M) ≤ k/(M+k−1)` and `k/(M+k) ≤ P ≤ k/M`, with `P → 1` as `k/M → ∞`.

## 3. Sharpness probe for the abstract marginal theorem

The abstract theorem `card_biUnion_lower_of_marginals` reads
`c·k·N ≤ m·|⋃A|·(c + m(k−1))`.  Enumerating the constant family
`A i = {0} ⊆ Fin 2` with `m = c = N = 2` and `k = 3` gives
LHS `= 2·3·2 = 12` and RHS `= 2·1·(2 + 2·2) = 12`: the inequality is *tight*.
The same family has `2m|⋃A| = 4 < 6 = kN`, so the Bonferroni-shaped conclusion
`|⋃A| ≥ kN/(2m)` is false without a pairwise hypothesis.  Both facts are
kernel-checked (`marginal_bound_sharp`,
`bonferroni_conclusion_fails_without_pairwise`, by `decide`).

## 4. OEIS

The exact counts for `M = 2` (2, 6, 14, 30, …) are `2^n − 2`, and for `M = 3`
(15, 57, …) are `3^n − 2^{n−1}·3`; these are shifted forms of the familiar
`a(n) = 2^n − 2` (A000918) and are recorded here only as a consistency check —
no new sequence is claimed.
