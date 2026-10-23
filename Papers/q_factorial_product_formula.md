# Computational evidence: q-factorial product formula and cyclotomic factorisation

These are exploratory checks done with a short exact-integer polynomial script
before writing the Lean proofs. They are **not** the verification; the
verification is the Lean file `Catalog/Applications/QBinomialQFactorial.lean`.

## 1. Small cases of `[n]_q!` (coefficients listed from `q^0` upward)

| n | `[n]_q!` coefficients | degree | sum = value at q=1 |
|---|---|---|---|
| 1 | 1 | 0 | 1 |
| 2 | 1 1 | 1 | 2 |
| 3 | 1 2 2 1 | 3 | 6 |
| 4 | 1 3 5 6 5 3 1 | 6 | 24 |
| 5 | 1 4 9 15 20 22 20 15 9 4 1 | 10 | 120 |
| 6 | 1 5 14 29 49 71 90 101 101 90 71 49 29 14 5 1 | 15 | 720 |

Degree is `C(n,2)` (proved: `qFactorial_int_natDegree`); the value at 1 is `n!`
(proved: `qFactorial_int_eval_one`). The coefficient rows are the Mahonian numbers
(the distribution of inversions in permutations), OEIS **A008302**.

## 2. Hunting for counterexamples

For all 136 pairs `0 ≤ k ≤ n ≤ 15` the script checked
* `[k]_q! · [n-k]_q! · ⟦n,k⟧_q = [n]_q!` (`⟦n,k⟧_q` computed with the q-Pascal
  recurrence used to define `qBinom`), and
* `⟦n,k⟧_q = ∏ { Φ_d(q) : 2 ≤ d ≤ n, k mod d + (n-k) mod d ≥ d }`.

There were **0 failures**. Both statements were then proved in general in Lean.

## 3. Examples of the carry rule

* `⟦7,2⟧_q = 1+q+2q²+2q³+3q⁴+3q⁵+3q⁶+2q⁷+2q⁸+q⁹+q¹⁰`. The carry moduli are
  `d ∈ {3,6,7}`, so `⟦7,2⟧_q = Φ_3 Φ_6 Φ_7`, with degree `2+2+6 = 10 = 2·5`.
* `⟦8,4⟧_q = Φ_5 Φ_6 Φ_7 Φ_8`, with degree `4+2+6+4 = 16`.
* At `q=1` the same rule gives `C(7,2) = Φ_3(1)Φ_6(1)Φ_7(1) = 3·1·7 = 21`, as in
  `choose_eq_prod_cyclotomic_eval_one`.
