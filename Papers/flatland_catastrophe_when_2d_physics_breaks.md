# Computational evidence

The formal development is analytic rather than a finite combinatorial search, but numerical values help expose the corrected claim. Set `k=m=r=1` and choose `ℓ=1`, which satisfies the circularity equation `ℓ² = m k r²`.

| Quantity | Formula | Value |
|---|---:|---:|
| effective first derivative | `k/r - ℓ²/(m r³)` | `0` |
| effective second derivative | `-k/r² + 3ℓ²/(m r⁴)` | `2` |
| angular frequency squared | `k/(m r²)` | `1` |
| radial frequency squared | `2k/(m r²)` | `2` |
| radial/angular frequency ratio | `√2` | approximately `1.41421356237` |

The positive second derivative is a direct counterexample to the proposed universal claim that the model has no stable circular orbit. Additional positive samples behave identically after imposing the circularity equation, because the symbolic expression reduces to `2k/r²`.

For possible low-order resonance, rational approximants to `√2` begin

| radial turns `q` | angular turns `p` | `q/p` | error from `√2` |
|---:|---:|---:|---:|
| 1 | 1 | 1 | about `0.4142` |
| 3 | 2 | 1.5 | about `0.0858` |
| 7 | 5 | 1.4 | about `0.0142` |
| 17 | 12 | 1.4167 | about `0.00245` |
| 41 | 29 | 1.41379 | about `0.00042` |

These near-resonances never become exact because `√2` is irrational; that exact statement is proved in Lean. No OEIS search is relevant: the continued-fraction approximants are only illustrative and no sequence conjecture is used in the proof.
