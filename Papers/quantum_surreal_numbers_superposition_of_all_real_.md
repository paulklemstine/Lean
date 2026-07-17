# Computational Evidence

## Small-case calculations

For a two-branch state with amplitudes `a` and `b`, the exact normalized weights are

| amplitudes | first weight | second weight | observed weights |
|---|---:|---:|---:|
| `1, 1` | `1/2` | `1/2` | `1/2, 1/2` |
| `1, ε` | `1/(1+ε²)` | `ε²/(1+ε²)` | `1, 0` |
| `ε, ε` | `1/2` | `1/2` | `1/2, 1/2` |

Here `ε` is a positive infinitesimal and “observed” means taking standard parts after normalization. The third row is the key boundary case: an infinitesimal amplitude is not automatically invisible when the total norm is itself infinitesimal.

For the finite lexicographic model with three visible atoms, the reservoir has weight `(1,-3)` and each visible atom has weight `(0,1)`. Thus

| event | exact weight | first-coordinate standard part |
|---|---:|---:|
| empty | `(0,0)` | `0` |
| one visible atom | `(0,1)` | `0` |
| all three visible atoms | `(0,3)` | `0` |
| reservoir only | `(1,-3)` | `1` |
| full space | `(1,0)` | `1` |

These cases are instances of the proved closed form for arbitrary finite events.

## OEIS search results

No integer sequence is intrinsic to the claims, so an OEIS search is not applicable. The parameters describe normalized weights and finite event measures rather than a counting sequence.

## Counterexample hunt

The proposed test state with equal amplitudes on `|0⟩` and an infinitesimal-labelled ket does **not** make the latter unobservable. Normalized Born probabilities depend on amplitudes, not on the arithmetic magnitude of basis labels. With two equal nonzero amplitudes, both exact and observed probabilities are `1/2`.

A second counterexample rules out dropping the appreciable-norm hypothesis: the state with amplitudes `ε, ε` has infinitesimal squared norm, yet each normalized branch weight is exactly `1/2`, not `0`.

The corrected test uses amplitudes `1, ε`, producing observed probabilities `1, 0`.

## Tables and interpretation

The tables above supply the relevant finite calculations. No plot is informative because standard part creates a sharp collapse: all positive infinitesimal weights map exactly to zero, while appreciable weights retain their real shadows.
