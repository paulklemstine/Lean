# Summary of changes for run fa5d00f7-6d65-433c-9193-4449ead1e020
## Tropical Amoebas and Ronkin Functions — Lean 4 Formalization

### Deliverables

**`Tropical/Amoeba.lean`** — A self-contained Lean 4 file with 6 fully-proved theorems (0 sorries, only standard axioms: propext, Classical.choice, Quot.sound). All theorems compile cleanly.

**`FUTURE_DIRECTIONS.md`** — 5 research conjectures extending the work.

### Theorems Proved

1. **`affineFunc_convexOn`** — Each affine function x ↦ a + n·x is convex on ℝ (ConvexOn ℝ univ).

2. **`tropicalPoly_convexOn`** — A tropical polynomial (max-plus convention), defined as the pointwise sup of finitely many affine functions over a nonempty Finset, is convex. Proved by induction on the Finset using `ConvexOn.sup`.

3. **`maslov_dequantization`** *(main result)* — The Maslov dequantization limit:
   ```
   lim_{h→0⁺} h · log(exp(a/h) + exp(b/h)) = max(a, b)
   ```
   This is the fundamental bridge from classical to tropical algebra, proved via factoring out the dominant exponential and squeeze theorem. The proof handles both cases (a ≥ b and b > a) separately, bounding the remainder by h·log(2) → 0.

4. **`maximalIndices_nonempty`** — At every point, at least one term of a tropical polynomial achieves the maximum.

5. **`complement_unique_max`** — On the complement of the tropical hypersurface (where the max is achieved by <2 terms), exactly one term achieves the maximum (∃! uniqueness).

6. **`tropicalPoly_eq_some_affine`** — At every point, the tropical polynomial equals some constituent affine function. Combined with `complement_unique_max`, this shows the tropical polynomial is locally affine on the complement of the tropical hypersurface — the tropical analogue of the Ronkin function being affine on amoeba complement components.

### Mathematical Significance

The formalization captures the core structural results of tropical geometry:
- **Convexity** of tropical polynomials (piecewise-linear convex functions)
- **Maslov dequantization** connecting classical algebra to tropical algebra via a limit
- **Tropical hypersurface** characterization as the non-smooth locus
- **Complement structure** as locally affine regions (tropical Ronkin function analogue)