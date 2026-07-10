# Computational Evidence

This note records the small-case computations that guided the formalization in
`ErdosRamseyLowerBound.lean`, `TuranEdgeBound.lean`, and `ProbabilisticMethod.lean`.

## 1. Erdős's counting inequality `2 · C(n,k) < 2^{C(k,2)}`

The counting theorem `not_arrows_of_two_mul_choose_lt` shows that whenever
`2 * (n.choose k) < 2 ^ (k.choose 2)`, the complete graph `K_n` has a 2-colouring with no
monochromatic `K_k`, i.e. `R(k,k) > n`.

For the explicit Erdős bound `R(k,k) > 2^{k/2}` we instantiate `n = 2^{⌊k/2⌋}`. The relevant
inequality `2 * (2^{⌊k/2⌋}.choose k) < 2 ^ (k.choose 2)` was checked for `k = 3..20`
(all `true`):

```
#eval (List.range 21).filter (3 ≤ ·) |>.map
  (fun k => (k, decide (2 * (2^(k/2)).choose k < 2^(k.choose 2))))
-- [(3,true),(4,true),(5,true),(6,true),(7,true),(8,true),(9,true),(10,true),
--  (11,true),(12,true),(13,true),(14,true),(15,true),(16,true),(17,true),
--  (18,true),(19,true),(20,true)]
```

Sample slack (`RHS − LHS`), showing the exponential comfort margin:

| k | ⌊k/2⌋ | n = 2^{⌊k/2⌋} | 2·C(n,k) | 2^{C(k,2)} |
|---|-------|---------------|----------|------------|
| 3 | 1     | 2             | 0        | 8          |
| 4 | 2     | 4             | 2        | 64         |
| 5 | 2     | 4             | 0        | 1024       |
| 6 | 3     | 8             | 56       | 32768      |
| 7 | 3     | 8             | 16       | 2097152    |
| 8 | 4     | 16            | 25740    | 268435456  |

The two integer-arithmetic ingredients of the general proof were isolated and checked:

* `half_mul_self_le`: `⌊k/2⌋ · k ≤ C(k,2) + ⌊k/2⌋` (equality for even `k`).
* `two_pow_half_succ_lt_factorial`: `2^{⌊k/2⌋+1} < k!` for `k ≥ 3`.

These yield `2 · C(2^{⌊k/2⌋}, k) < 2^{C(k,2)}` via the descending-factorial bound
`k! · C(n,k) = n^{\underline k} ≤ n^k`.

## 2. Concrete Ramsey lower bounds

The general theorem specializes (via `decide` on the finite arithmetic side) to:

* `not_arrows_5_4 : ¬ Arrows 5 4`  — `R(4,4) > 5` (indeed `2·C(5,4) = 10 < 2^6 = 64`).
* `not_arrows_8_6 : ¬ Arrows 8 6`  — `R(6,6) > 8 = 2^{6/2}` (`2·C(8,6) = 56 < 2^{15}`).

## 3. Turán's edge bound

`CliqueFree.card_edgeFinset_le_turan_real` gives `|E(G)| ≤ (1 − 1/r)·n²/2` for `K_{r+1}`-free
`G`. Sanity checks against the exact optimum (the Turán graph `T(n,r)`):

| n | r | (1−1/r)·n²/2 | max edges (Turán graph) |
|---|---|--------------|--------------------------|
| 4 | 2 | 4.0          | 4  (K_{2,2})             |
| 6 | 2 | 9.0          | 9  (K_{3,3})             |
| 6 | 3 | 12.0         | 12 (K_{2,2,2})           |
| 5 | 2 | 6.25         | 6                        |

The real bound is tight when `r | n` and otherwise slightly loose, as expected.

## 4. Independent Lovász Local Lemma

For mutually independent events, `iIndep_measure_iInter_compl_eq_prod` gives
`P(⋂ Aᵢᶜ) = ∏ (1 − P(Aᵢ))`, positive whenever every `P(Aᵢ) < 1`. This is the `d = 0`
degenerate case of the LLL and needs no counting; it is verified symbolically rather than
numerically.
