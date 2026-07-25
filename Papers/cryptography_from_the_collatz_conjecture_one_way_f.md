# Computational evidence: iterated Collatz maps

## Small cases

For the map `T(n)=n/2` on even inputs and `T(n)=3n+1` on odd inputs, the canonical depth-`a` preimage of `y` is `2^a y`.

| `a` | `y` | canonical preimage | orbit to `y` |
|---:|---:|---:|:---|
| 1 | 5 | 10 | 10, 5 |
| 2 | 5 | 20 | 20, 10, 5 |
| 3 | 5 | 40 | 40, 20, 10, 5 |
| 4 | 7 | 112 | 112, 56, 28, 14, 7 |

The parameterized collision family begins:

| `k` | odd input `2k+1` | even input `12k+8` | common image |
|---:|---:|---:|---:|
| 0 | 1 | 8 | 4 |
| 1 | 3 | 20 | 10 |
| 2 | 5 | 32 | 16 |
| 3 | 7 | 44 | 22 |
| 4 | 9 | 56 | 28 |

## Sequence search

No OEIS identification is needed: both displayed sequences are elementary arithmetic progressions, and their formulas are proved directly.

## Counterexample hunt

The proposed inversion-hardness claim has a symbolic counterexample for every depth and target, not merely for a finite sample: `2^a y` is always a preimage of `y`. The proposed raw collision-resistance claim likewise has a symbolic counterexample at every positive depth: any one-step collision above persists under further common iteration.

## Conclusion

Finite sampling suggests the general identities, while the accompanying theorems establish them for all natural parameters. Computational evidence cannot support the original unrestricted cryptographic claims because explicit universal counterfamilies are already present.
