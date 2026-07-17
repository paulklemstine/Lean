# Computational Evidence

## Small-case calculations

For the corrected two-branch state with amplitudes `1` and `ε`, the exact hyperreal Born weights are

| branch | exact weight | standard part |
|---|---:|---:|
| standard branch | `1 / (1 + ε²)` | `1` |
| infinitesimal-amplitude branch | `ε² / (1 + ε²)` | `0` |

Their exact sum is `1`. By contrast, two distinct branches with the common nonzero amplitude `a` have squared norm `2a²` and exact weight `1/2` each. This calculation exposes the counterexample to label-dependent suppression: an infinitesimal ket label does not suppress an appreciable amplitude.

For the lexicographic model with `n = 3`, write a weight `(r,s)` as `r + sε`:

| event | exact lexicographic mass | standard part |
|---|---:|---:|
| empty event | `(0,0)` | `0` |
| one visible atom | `(0,1)` | `0` |
| all three visible atoms | `(0,3)` | `0` |
| reservoir only | `(1,-3)` | `1` |
| full space | `(1,0)` | `1` |

For tropical reservoir weight `0` and visible penalty `M < 0`, the objective at the reservoir is `f(none)`, while at visible atom `i` it is `f(some i) + M`. Thus the reservoir is selected exactly throughout the tested dominance region `f(some i) + M ≤ f(none)`.

## OEIS search results

No integer sequence arises from these finite symbolic identities, so an OEIS comparison is not applicable.

## Counterexample hunt

The proposed state `(1/√2)|0⟩ + (1/√2)|ε⟩` assigns equal amplitudes to two distinct basis labels. Its two Born probabilities are both `1/2`; standard part leaves both equal to `1/2`. Therefore the claim that the `|ε⟩` outcome has probability zero is false as stated.

A second boundary test concerns the tropical bridge. With `M = -1`, `f(none) = 0`, and `f(some i) = 2`, the visible tropical score is `1`, exceeding the reservoir score `0`. Hence standard-part support and tropical maximization do not agree for arbitrary observables. The dominance hypothesis in the bridge theorem is necessary.

## Tables and plots

The relevant objects are finite two-level comparisons, so the tables above contain the complete small-case behavior; a plot would add no further information.
