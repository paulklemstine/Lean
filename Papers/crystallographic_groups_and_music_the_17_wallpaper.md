# Computational evidence

## Small cases

The formal theorem predicts that a binary pattern constant on symmetry classes has one independent bit per class. For `m` classes, the number of invariant patterns is `2^m`.

| symmetry classes `m` | invariant binary patterns |
|---:|---:|
| 0 | 1 |
| 1 | 2 |
| 2 | 4 |
| 3 | 8 |
| 4 | 16 |
| 5 | 32 |
| 6 | 64 |

For maximal symmetry on a nonempty grid there is one class, hence exactly two patterns: all cells false and all cells true. This instance is proved in Lean, not merely sampled.

## OEIS search

The count `1, 2, 4, 8, 16, 32, 64, ...` is the powers-of-two sequence, OEIS A000079. The identification is only contextual; the Lean proof derives the formula directly from an equivalence of types.

## Counterexample hunt and scope check

No counterexample exists to the proved abstract claim: invariant functions are equivalent to functions on the quotient by construction, and the Lean kernel checks the equivalence and cardinality argument.

The broader proposed claim that there are “exactly 17 types of rhythm” is not established by the wallpaper-group classification. Wallpaper groups classify discrete, cocompact Euclidean isometry groups of the plane, whereas a finite onset grid may have a finite symmetry group, and an arbitrary musical equivalence notion need not be a Euclidean isometry group. The musical labels in the prompt are interpretations requiring empirical definitions and data. Accordingly, the formal result does not claim that a corpus has 17 classes or that its distribution follows any specified law.

## Representative quotient table

The theorem depends only on the number of symmetry orbits, not their shapes:

| grid cells | orbit sizes | classes | predicted invariant patterns |
|---:|---|---:|---:|
| 4 | 1+1+1+1 | 4 | 16 |
| 4 | 2+1+1 | 3 | 8 |
| 4 | 2+2 | 2 | 4 |
| 4 | 4 | 1 | 2 |

This illustrates the monotonic information loss produced when symmetry identifies cells.