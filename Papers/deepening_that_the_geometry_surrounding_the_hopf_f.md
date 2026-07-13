# Computational Evidence — Quaternionic Hopf Witness

## 1. The squared-distance defect identity

For unit vectors `a = (q, r)`, `b = (q', r')` in `ℍ²` and the Hermitian witness
`λ = q̄ q' + r̄ r'`, we conjectured

```
‖q' − qλ‖² + ‖r' − rλ‖² = 1 − ‖λ‖².
```

Over the rationals, sampling random quaternion octuples on the unit sphere
confirmed the identity exactly (defect `0`). Off the sphere, the stronger
*unconditional* form

```
‖q' − qλ‖² + ‖r' − rλ‖² = (‖q'‖² + ‖r'‖²) − 2‖λ‖² + (‖q‖² + ‖r‖²)‖λ‖²
```

was tested. Example: `q = (1,2,3,4)`, `r = (2,0,1,1)`, `q' = (0,1,2,5)`,
`r' = (3,1,0,2)` gives LHS `= 47100` and RHS `= 47100`, defect `0`. The
unconditional identity specialises to the sphere identity when
`‖q‖²+‖r‖² = ‖q'‖²+‖r'‖² = 1`.

## 2. Side of the phase (noncommutativity check)

The complex witness recovers the multiplier because `z̄(μz) = μ‖z‖²`. Over `ℍ`
this fails for left multiplication: `q̄(μq) ≠ ‖q‖²μ` in general. Sampling
confirmed `q̄(qμ) = ‖q‖²μ` (right multiplication) holds while `q̄(μq)` does not
reduce. Hence the fibre must be a **right** `ℍ`-line, i.e. `b = a·μ`.

## 3. Cauchy–Schwarz bound

For unit vectors the witness satisfies `‖λ‖ ≤ 1`, with equality exactly when the
defect vanishes — i.e. when `b` lies on the right `ℍ`-line through `a`. Random
samples on the sphere produced `‖λ‖` values in `[0,1]`, saturating at `1` only
for right-proportional pairs.

## Conclusion

The computational landscape matches the complex case verbatim up to the side of
multiplication. The formal development proves all four statements
(`dist_sq_eq`, `abs_witness_le_one`, `witness_of_proportional`,
`reconstruct_fibre`) plus the unconditional engine `normSq_identity`.
