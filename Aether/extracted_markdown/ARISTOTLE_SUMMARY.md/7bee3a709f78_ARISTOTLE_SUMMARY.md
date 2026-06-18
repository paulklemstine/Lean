# Summary of changes for run 95491cd1-3801-4ac7-8399-427203bec033
## Tropical Amoebas, Ronkin Functions, and Maslov Dequantization

I added a new, self-contained development to the Tropical library:
`Catalog/Tropical/AmoebaRonkin.lean` (namespace `TropicalAmoeba`), plus
`FUTURE_DIRECTIONS.md`.

### What was proved (all theorems complete — zero `sorry`)
Working in log-modulus coordinates, each monomial `c·z^m` of a Laurent polynomial gives an
affine function `A(x) = log|c| + ⟨m,x⟩`. The file establishes:

- `affFun_convexOn` — each monomial log-modulus is convex (affine).
- `convexOn_finset_sup'` — a finite supremum of convex functions is convex (general helper).
- `tropPoly_convexOn` — **the tropical polynomial (amoeba spine) `max_i A_i` is convex**.
- `tropPoly_eq_affFun_of_dominant` — **piecewise linearity**: where one monomial dominates,
  the spine equals that single affine function.
- `dominantRegion_convex` — each amoeba-complement (dominance) region is convex.
- `tropPoly_slope_on_dominant` — the **order map**: the spine has constant slope `m_k` on a
  dominance region (a Newton-polytope lattice point), proved as `Δspine = ⟨m_k, x−y⟩`.
- `maslov_lower`, `maslov_upper` — two-sided bounds `trop f ≤ R_t ≤ trop f + t·log N` for the
  Maslov/Ronkin smoothing `R_t(x) = t·log Σ_i exp(A_i(x)/t)`.
- `maslov_dequantization_rate` — `|R_t − trop f| ≤ t·log N`.
- `maslov_tendsto` — **Maslov dequantization**: `R_t → trop f` as `t → 0⁺`.
- `ronkinDeform_convexOn` — the strengthening that `R_t` is convex for every fixed `t > 0`
  (log-sum-exp of affine functions), proved via the finite Hölder inequality.
- A boundary `example` showing that with a single monomial the spine is globally affine
  (hence convex but not strictly convex).

Each result carries a one–two sentence proof sketch in `-- !-- … -- !--` comments. The whole
module builds cleanly, and the main theorems were confirmed to depend only on the standard
axioms `propext`, `Classical.choice`, `Quot.sound` (no `sorry`, no extra axioms).

### Catalog synthesis
This extends the Maslov-dequantization theme of `TSM.zeroTemperature_limit`
(`SemiclassicalLimit.lean`) — where `F(β) → E₀` — into the geometric amoeba setting, and
builds on the log-sum-exp analysis of `LSEConvexity.lean`. The free-energy limit becomes the
convergence of the Ronkin smoothing to the amoeba spine.

### FUTURE_DIRECTIONS.md
Five falsifiable conjectures (strict convexity via Hölder equality; Legendre dual = Newton
polytope; tentacle counting via Farkas certificates; equi-Lipschitz/locally-uniform
dequantization; and an amoeba ↔ statistical-mechanics phase-diagram bridge), each with a
"The key insight is…" sentence and a "Why now?" justification.

### Build-configuration fix
The project's `lakefile.toml` was missing its source-directory mapping, so no module under
`Catalog/` resolved and nothing built. I added `srcDir = "Catalog"` to the package config;
the project (and the new module) now build correctly.