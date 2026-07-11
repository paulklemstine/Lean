# Computational Evidence: Information-Theoretic Bounds on Encoding a Mind

Before formalizing, we probed the combinatorial landscape of connectome storage.

## 1. Small-case calculations

A connectome on `n` neurons carries one present/absent bit per candidate synapse, so it
has `C(n,2) = n(n-1)/2` bits of state and `2^{C(n,2)}` possible values.

| n (neurons) | C(n,2) synapses | # connectomes 2^C(n,2) | min lossless bits |
|-------------|-----------------|------------------------|-------------------|
| 1           | 0               | 1                      | 0                 |
| 2           | 1               | 2                      | 1                 |
| 3           | 3               | 8                      | 3                 |
| 4           | 6               | 64                     | 6                 |
| 5           | 10              | 1024                   | 10                |
| 10          | 45              | ~3.5e13                | 45                |
| 100         | 4950            | 2^4950                 | 4950              |

The minimum lossless code length equals `C(n,2)` exactly (identity code), confirming the
`IsLeast` characterization: the counting floor is attained, not merely approached.

## 2. Sequence identification

The synapse counts `C(n,2)` are the triangular numbers `0, 1, 3, 6, 10, 15, 21, ...`
(**OEIS A000217**). The connectome counts `2^{C(n,2)}` are `1, 2, 8, 64, 1024, ...`
(**OEIS A006125**, the number of labelled graphs on `n` nodes). This matches the model:
a connectome *is* a labelled simple graph on the `n` neurons.

## 3. Quadratic-growth check

We verified `(n-1)^2 ≤ 2·C(n,2) = n(n-1)` and `2·C(n,2) = n(n-1)` on `n = 0..20`:
both hold with equality-adjacent tightness (`(n-1)^2 = n(n-1) - (n-1)`), so the storage
cost is quadratic in the neuron count with leading term `n^2/2` bits — no sub-quadratic
lossless scheme exists.

## 4. Counterexample hunt (variable-length codes)

We tested whether *some* compression scheme could keep every connectome strictly under
`C(n,2)` bits. For `n = 3` (`m = C(3,2) = 3`), there are `2^3 = 8` connectomes but only
`2^3 - 1 = 7` bit strings of length `< 3` (lengths 0,1,2 give `1+2+4 = 7` strings). By
pigeonhole, any injective code must send some connectome to a codeword of length `≥ 3`.
No counterexample exists; the `−1` in the geometric sum `∑_{k<m} 2^k = 2^m − 1` is the
exact obstruction, and this generalizes to all `n`.

## Conclusion

The computational landscape fully supports every formalized claim: the counting floor is
sharp, quadratic, attained, and unbeatable even by variable-length compression. We
proceeded to formal proof with no pivots required.
