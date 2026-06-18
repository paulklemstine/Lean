# Summary of changes for run 14d8ca2e-0019-44b5-89e3-0c60fa29ce94
## Tropical Brill-Noether Theory — Formalization Complete

### New Files Created (0 sorries, all proofs verified)

**`Catalog/Tropical/BrillNoether/Duality.lean`** — 8 fully proved theorems on the Brill-Noether number ρ(g,r,d) = g − (r+1)(g−d+r):
1. `brillNoether_alt_eq` — Two equivalent formulations agree: ρ = (r+1)d − rg − r(r+1)
2. `brillNoether_serre_duality` — **Serre duality**: ρ(g,r,d) = ρ(g, g−1−d+r, 2g−2−d), reflecting the classical K−D duality
3. `brillNoether_strictMono_d` — ρ is strictly monotone increasing in degree d
4. `degree_ge_rank_of_rho_nonneg` — ρ ≥ 0 and r ≥ 1 implies d ≥ r (divisor degree bounds rank)
5. `brillNoether_rank_zero` — ρ(g, 0, d) = d (rank-zero case)
6. `brillNoether_genus_zero` — ρ(0, r, d) = (r+1)(d−r) (rational curve case)
7. `brillNoether_neg_of_large_genus` — ρ < 0 when genus dominates
8. `brillNoether_eq_zero_iff` — ρ vanishes exactly when g = (r+1)(g−d+r)

**`Catalog/Tropical/BrillNoether/ChipFiring.lean`** — 9 fully proved theorems on graph chip-firing:
1. `graphLaplacian_sum_zero` — The graph Laplacian sums to zero (key structural property)
2. `degree_eq_of_linearEquiv` — **Chip-firing preserves degree** (degree invariance under linear equivalence)
3. `effective_degree_nonneg` — Effective divisors have nonnegative degree
4. `linearEquiv_refl` — Linear equivalence is reflexive
5. `linearEquiv_symm` — Linear equivalence is symmetric
6. `linearEquiv_trans` — Linear equivalence is transitive
7. `graphLaplacian_zero` — Laplacian of zero is zero
8. `graphLaplacian_add` — Laplacian is additive: Δ(f+g) = Δf + Δg
9. `graphLaplacian_neg` — Laplacian respects negation: Δ(−f) = −Δf

### Existing Files (unchanged, still compile)
- `Catalog/Tropical/BrillNoether/Defs.lean` — Core definitions (graph divisors, Laplacian, Baker-Norine rank, specialization)
- `Catalog/Tropical/BrillNoether/Core.lean` — CDPR existence theorem (allocations ↔ ρ ≥ 0, lattice paths ↔ ρ ≥ 0)

### `FUTURE_DIRECTIONS.md` — 5 research directions including:
1. Baker-Norine Riemann-Roch for graphs (building on our equivalence relation infrastructure)
2. Full CDPR theorem with metric structure
3. Specialization inequality and lifting
4. Tropical moduli space dimension
5. Chip-firing groups and Jacobians (matrix-tree theorem connection)

All 17 new theorems compile with zero sorries. Axioms used are only the standard `propext`, `Classical.choice`, and `Quot.sound`.