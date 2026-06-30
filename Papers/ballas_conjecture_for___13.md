# Computational Evidence — Equiangular lines at angle arccos(1/3)

## 1. Small-case calculations of N_{1/3}(d)

Let N_{1/3}(d) be the maximum number of equiangular lines in ℝ^d with common
angle arccos(1/3). The conjectured/known values (Lemmens–Seidel 1973):

| d  | 2(d−1) | known/conjectured N_{1/3}(d) | regime |
|----|--------|------------------------------|--------|
| 2  | 2      | 3                            | small (≤ 28 plateau) |
| 3  | 4      | 6                            | small |
| 7  | 12     | 28                           | E₇ / 28-line exception |
| 14 | 26     | 28                           | plateau end |
| 15 | 28     | 28                           | crossover (2(d−1) = 28) |
| 16 | 30     | 30                           | linear regime |
| d ≥ 15 | 2(d−1) | 2(d−1)                  | linear regime |

The conjectured bound is `N_{1/3}(d) ≤ max{28, 2(d−1)}`: a flat plateau at 28 for
small d, then the linear law 2(d−1) once d ≥ 15.

## 2. The absolute bound this cycle proves

The unconditional square-tensor bound established here is `N_{1/3}(d) ≤ d²`.
Comparison with the conjectured optimum:

| d  | d² (proved here) | max{28, 2(d−1)} (conjectured) |
|----|------------------|-------------------------------|
| 2  | 4                | 28                            |
| 3  | 9                | 28                            |
| 7  | 49               | 28                            |
| 15 | 225              | 28                            |
| 30 | 900              | 58                            |

So `d²` is an honest, always-valid upper bound; it is quadratically weaker than
the conjectured linear law but requires only a single positivity (eigenvalue)
inequality. Refining `d²` → `d(d+1)/2` (Gerzon) → `2(d−1)` is precisely the
research gradient, each step adding more structure (symmetry of the tensor,
then the eigenvalue ≥ −3 constraint).

## 3. Spectral reformulation (the −3 phenomenon)

For an equiangular system with parameter α = 1/3, write the Gram matrix as
`G = I + (1/3)·S` where `S` is a symmetric 0/±1 "Seidel" matrix (0 diagonal).
PSD of `G` forces `λ_min(S) ≥ −3`. The number 3 = 1/α is exactly the
"spectral-radius order κ₁ = 2" parameter in Balla's framing (κ₁ witnessed by K₂).
The 28-line exception is the maximal Seidel graph on 28 vertices with smallest
eigenvalue −3 (related to the E₇ root system).

## 4. Counterexample hunt

- Tested the proved claim `N ≤ d²` against all tabulated small cases above: no
  violation (3 ≤ 4, 6 ≤ 9, 28 ≤ 49, …). Consistent.
- Tested the non-vacuousness witness: two unit vectors (1,0) and (1/3, √(8/9))
  in ℝ² have inner product exactly 1/3 and unit norm; this realizes N = 2 at the
  Balla angle, with 2 ≤ 2² = 4. Verified symbolically (norm via √(8/9)·√(8/9) =
  8/9, cross term 1/3·1 + √(8/9)·0 = 1/3).
- The hypothesis α² < 1 is necessary: at α = 1 two "lines" coincide and the count
  is unbounded relative to the diagonal pattern, so the constant-pattern matrix
  degenerates (off-diagonal = diagonal) and positive definiteness fails.

## 5. OEIS

The sequence of maxima N_{1/3}(d) for d = 2,3,… in the linear regime is just
2(d−1) = 2,4,6,8,…, i.e. the even numbers (OEIS A005843 shifted). The plateau
value 28 ties to the 28 bitangents / 28 equiangular lines in ℝ⁷ (E₇).
