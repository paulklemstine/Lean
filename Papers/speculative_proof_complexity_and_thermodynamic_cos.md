# Computational Evidence

The finite theorem gives, for an ensemble of `2^n` objects, at least `2^(n-1)` objects of complexity at least `n-1`. Its certified aggregate lower and upper bounds are `(n-1)2^(n-1)` and `n2^n`.

| `n` | ensemble size `2^n` | certified incompressible count | aggregate lower bound | aggregate upper bound |
|---:|---:|---:|---:|---:|
| 1 | 2 | 1 | 0 | 2 |
| 2 | 4 | 2 | 2 | 8 |
| 3 | 8 | 4 | 8 | 24 |
| 4 | 16 | 8 | 24 | 64 |
| 5 | 32 | 16 | 64 | 160 |
| 6 | 64 | 32 | 160 | 384 |
| 7 | 128 | 64 | 384 | 896 |
| 8 | 256 | 128 | 896 | 2048 |

No OEIS identification is needed: all columns are elementary closed forms.

The universal exponential-average claim fails the representative uniform binary model. Dividing the aggregate bounds by `2^n` gives a mean complexity between `(n-1)/2` and `n`, hence linear rather than exponential growth. The explicit two-proof construction also refutes the universal claim that shorter written proofs must have lower thermodynamic cost: written length can increase while description complexity and cost decrease.

These calculations are instances of the proved symbolic bounds in `Catalog/MachineLearning/ProofThermodynamics.lean`; they are included to expose scale and boundary behavior rather than as a substitute for the general argument.
