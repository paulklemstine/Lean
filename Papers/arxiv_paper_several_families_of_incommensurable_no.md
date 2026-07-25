# Computational Evidence

## 1. The counting bridge is tight in the model

For the model on `(Fin n → Bool) × Bool`:

| n | volume bound | #invariant values | #commensurability classes | 2^n |
|---|--------------|-------------------|----------------------------|-----|
| 1 | ≤ 1          | 2                 | 2                          | 2   |
| 2 | ≤ 2          | 4                 | 4                          | 4   |
| 3 | ≤ 3          | 8                 | 8                          | 8   |
| 4 | ≤ 4          | 16                | 16                         | 16  |

Volume grows linearly (`≤ n`) while the number of classes grows as `2^n`; the
invariant count equals the class count exactly, so the inequality
`#values ≤ #classes` is realized as equality here. The commensurability relation
identifies the two decorations of each combinatorial type, so every class has size
exactly `2` — the relation is strictly coarser than equality, confirming the growth
is not an artifact of the discrete relation.

## 2. Gram off-diagonal entries `-cos(π/m)`

| m | angle π/m | cos(π/m)        | Gram entry −cos(π/m) |
|---|-----------|-----------------|----------------------|
| 2 | 90°       | 0               | 0                    |
| 3 | 60°       | 1/2             | −0.5                 |
| 4 | 45°       | √2/2 ≈ 0.707    | −0.707               |
| 5 | 36°       | ≈ 0.809         | −0.809               |
| 6 | 30°       | √3/2 ≈ 0.866    | −0.866               |
| ∞ | 0°        | → 1             | → −1 (excluded)      |

All finite entries lie in `(-1, 0]`, matching `gram_offdiagonal_mem_Ioc`. The
value `-1` is approached only as `m → ∞` (parallel facets / cusp), so it is never
attained for a finite dihedral order — exactly the half-open interval proved.

## 3. Classification headline figures (from the source paper)

The classification records `141` finite-volume hyperbolic Coxeter 5-polytopes with
`8` facets, of which `125` are noncompact and `16` compact (`141 = 125 + 16`).
These counts frame the qualitative regime (noncompact-dominated) in which the
exponential-growth construction operates.
