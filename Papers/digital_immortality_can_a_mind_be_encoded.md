# Computational Evidence: Connectome Description-Length Bounds

## 1. Small-case slot counts

`synapseSlots N = C(N,2)` = number of unordered neuron pairs.

| N   | synapseSlots N | connectomes = 2^slots |
|-----|----------------|-----------------------|
| 0   | 0              | 1                     |
| 1   | 0              | 1                     |
| 2   | 1              | 2                     |
| 3   | 3              | 8                     |
| 4   | 6              | 64                    |
| 5   | 10             | 1024                  |
| 10  | 45             | ~3.5 × 10^13          |
| 1000| 499500         | 2^499500              |

Verified in `MindEncodingBounds.lean`:
`#eval synapseSlots 5  -- 10`, `#eval synapseSlots 1000  -- 499500`,
and `example : Fintype.card (Connectome 5) = 1024`.

## 2. Quadratic sandwich check

The theorem `synapseSlots_sandwich` gives `(N-1)^2 ≤ 2·slots ≤ N^2`.
Spot checks:

* N=5:  (5-1)^2 = 16 ≤ 2·10 = 20 ≤ 25 = 5^2. ✓
* N=10: 81 ≤ 90 ≤ 100. ✓
* N=1000: 998001 ≤ 999000 ≤ 1000000. ✓

## 3. OEIS

The slot sequence `0,0,1,3,6,10,15,21,...` is the triangular numbers
**OEIS A000217** (shifted), and the connectome-count sequence
`1,1,2,8,64,1024,...` = `2^C(n,2)` is **OEIS A006125** (number of labeled
graphs on n nodes). Both confirm the quadratic exponent in the state count.

## 4. Counterexample hunt (boundary cases)

* The real quadratic corollary `uploading_energy_radius_quadratic` uses
  `((N:ℝ)-1)^2`. At N=0 this equals 1 while `2·slots = 0`, so the unguarded
  real bound would be **false** at N=0 — this is exactly why the theorem carries
  the hypothesis `1 ≤ N`. No counterexample exists in the guarded range.
* `no_lossless_compression` is checked at the boundary `M = 2^slots - 1`:
  compression into `1023` codewords for 5 neurons is impossible, matching the
  `1024` distinct connectomes.

## 5. Conclusion

All computational evidence is consistent with — and is discharged inside — the
formal results: the state count is exactly `2^C(N,2)`, the slot count is `Θ(N²)`,
and the minimum description length is quadratic in the neuron count.
