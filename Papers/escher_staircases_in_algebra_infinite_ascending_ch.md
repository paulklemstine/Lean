# Computational evidence

The central issue is order-theoretic and is resolved symbolically rather than by large computation. Small cases nevertheless expose the orientation error immediately.

## Small-case calculations

For the divisibility conditions `D_n = {f | ∀z, 2^n ∣ f(z)}`:

| n | required divisibility | constant separator |
|---:|---:|---:|
| 0 | 1 | 1 is in `D_0`, not `D_1` |
| 1 | 2 | 2 is in `D_1`, not `D_2` |
| 2 | 4 | 4 is in `D_2`, not `D_3` |
| 3 | 8 | 8 is in `D_3`, not `D_4` |
| 4 | 16 | 16 is in `D_4`, not `D_5` |

Hence `D_{n+1} ⊊ D_n`, contrary to the proposed ascending orientation. The general calculation and strictness witness are proved in Lean in `Catalog/Algebra/EscherDivisibilityDisproof.lean`.

For the variable ideals in `k[x₀,x₁,…]`:

| n | rung `V_n` | separator for `V_n ⊊ V_{n+1}` |
|---:|---|---|
| 0 | `(0)` | `x₀` |
| 1 | `(x₀)` | `x₁` |
| 2 | `(x₀,x₁)` | `x₂` |
| 3 | `(x₀,x₁,x₂)` | `x₃` |

The general non-membership of the new variable is formally proved using a polynomial evaluation homomorphism.

## OEIS search

No OEIS search is relevant. The displayed values `1,2,4,8,16,…` are simply powers of two, and the research question concerns inclusion of ideals rather than discovery of an integer sequence.

## Counterexample hunt

- The advertised `2^n` construction is a counterexample to its own claimed orientation: it descends strictly.
- Finite polynomial rings are counterexamples to the claim that staircase height should equal the finite number of variables under the stated staircase definition: Hilbert's basis theorem rules out every infinite strict ascending chain.
- The supposedly extra “loop-back” condition, interpreted as containing zero in the intersection, holds for every collection of ideals and therefore does not distinguish examples.

## Summary

The finite table agrees with the fully general Lean proofs: divisibility powers descend, finite-variable polynomial rings admit no staircase, and countably infinite-variable polynomial rings admit an explicit ascending staircase.
