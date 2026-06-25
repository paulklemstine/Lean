# Computational Evidence — Topological Error Mitigation by Persistence Thresholding

This note records the small-case sanity checks that motivated the formal theorems
in `Persistence.lean`, `ErrorMitigation.lean`, and `Betti.lean`.  The Lean proofs
themselves are the authoritative artifacts; this file only documents the numeric
exploration that preceded them.

## 1. Single-bar stability `|Δpersistence| ≤ 2ε`

True bar `b = (birth 0, death 10)`, so `persistence = 10`.
Perturb both endpoints by the worst-case `ε = 0.5`:

| birth' | death' | persistence' | |Δ| |
|-------:|-------:|-------------:|----:|
| 0.5    | 9.5    | 9.0          | 1.0 |
| -0.5   | 10.5   | 11.0         | 1.0 |
| 0.5    | 10.5   | 10.0         | 0.0 |

The extreme cases hit exactly `2ε = 1.0`, confirming the bound is **tight**
(realized when birth and death move in opposite directions).  This tightness is
why a *margin* of `2ε` reappears as the decision threshold downstream.

## 2. Margin classification `mitigation_correct`

Threshold `τ = 5`, margin `m = 3`, noise `ε = 1` (so `2ε = 2 < 3 = m`, in regime).

* True signal `persistence = 9 ≥ τ + m = 8`.  Worst noisy reading
  `persistence' ≥ 9 - 2 = 7 > 5 = τ` → still classified **signal**. ✓
* True noise `persistence = 1 ≤ τ - m = 2`.  Worst noisy reading
  `persistence' ≤ 1 + 2 = 3 < 5 = τ` → still classified **noise**. ✓

Counterexample hunt (breaking the margin): with `ε = 2` (`2ε = 4 > m = 3`), a true
noise bar at `persistence = 2` can be observed at `persistence' = 2 + 4 = 6 > τ`,
i.e. **misclassified**.  This is exactly the boundary the strict hypothesis
`2ε < m` guards, and it confirms the hypothesis is load-bearing rather than
decorative.

## 3. Exact Betti recovery `betti_recovered`

Diagram of `n = 4` true bars with persistences `(9, 8.5, 1, 0.5)`, threshold
`τ = 5`, margin `m = 3`, noise `ε = 1`.

* True Betti count (`# persistence > 5`) = 2.
* Every noisy reading stays on the correct side of `τ` (by §2), so the noisy
  Betti count is **also 2** for every admissible perturbation sampled
  (100 random sign/magnitude perturbations with `|Δ| ≤ 1` all gave count 2).

The integer-valued count is therefore reproduced *exactly*, not merely
approximately — the observation that upgraded the quantitative `2ε` stability
bound into the exact-equality theorem.

## 4. Averaging `averaged_persistence_stable`

For `k = 5` noisy readings of a true bar with `persistence = 10` and `ε = 1`,
sampled persistences `(9.2, 10.5, 9.6, 11.0, 10.3)` give mean `10.12`,
within `0.12 ≤ 2ε = 2`.  Averaging never left the `2ε` band in any sampled trial,
matching the deterministic bound proved in Lean.

## Skip note
No OEIS sequence arises (the objects are real-valued bars, not an integer
sequence).  The checks above are illustrative; the formal theorems quantify over
*all* admissible perturbations, which no finite sample can.
