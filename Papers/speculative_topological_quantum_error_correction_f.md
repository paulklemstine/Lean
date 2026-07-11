# Computational Evidence: Homological Quantum Codes

Before formalization, we checked the central numerical claims on small cases.

## 1. Logical qubits = first Betti number

For the minimal cell structure of a closed orientable genus-`g` surface
(one 0-cell, `2g` 1-cells, one 2-cell) both boundary maps vanish over `𝔽₂`,
so `dim H₁ = 2g`. Small cases:

| genus `g` | `n` (edges) | `dim H₁ = k` | Euler char `2 - 2g` |
|-----------|-------------|--------------|---------------------|
| 0 (sphere)| 0           | 0            | 2                   |
| 1 (torus) | 2           | 2            | 0                   |
| 2         | 4           | 4            | -2                  |
| 3         | 6           | 6            | -4                  |

This matches the well-known ranks of `H₁` of surfaces (OEIS A005843, the even
numbers `2g`), and the toric-code count of `2` logical qubits at `g = 1`.

## 2. CSS dimension identity

For any length-three `𝔽₂` chain complex we tested `k + rank ∂₁ + rank ∂₂ = n`
on random small incidence matrices (sizes up to `6×6`) by direct rank
computation; the identity held in every trial, consistent with rank–nullity.

## 3. Triangle code `C₃` (nonzero boundary map)

Incidence matrix `∂₁ = !![1,0,1; 1,1,0; 0,1,1]`, `∂₂ = 0`.

- `rank ∂₁ = 2`, so `k = 3 - 2 - 0 = 1` logical qubit.
- Kernel of `∂₁` is spanned by `(1,1,1)` — the fundamental loop of the triangle.
- All nonzero kernel elements over `𝔽₂` equal `(1,1,1)`, of Hamming weight `3`;
  hence the systole (distance) is exactly `3`, giving a `[[3,1,3]]` code.

## 4. Systole / distance scaling (counterexample hunt for "O(√g)")

We tested the prediction that genus-`g` surface codes achieve distance `O(√g)`.
On square `L×L` toric layouts the standard code is `[[2L², 2, L]]`: with a single
handle (`g = 1`) distance grows like `√n`, not with `g`. Stacking `g` independent
`L×L` tori gives `k = 2g`, `n = 2gL²`, distance `L = √(n/(2g))`. Thus at fixed
physical size `n`, distance *decreases* as `1/√g`, contradicting a naive
"distance grows like `√g`" reading. The honest surviving statement is the
Bravyi–Poulin–Terhal-type trade-off `k · d² ≤ c · n`, recorded as a conjecture in
`FUTURE_DIRECTIONS.md`. This pivot is why the formalization proves the exact
dimension law and the systolic distance framework rather than the `O(√g)` claim.
