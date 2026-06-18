# Summary of changes for run 4ac8f6c7-84dc-483f-a227-22b7f6ff7202
## Completed: Tropical Brill–Noether Theory Core Theorems

### Lean file: `Catalog/Tropical/BrillNoether/Core.lean` (299 lines, 0 sorries)

All 14 main theorems compile cleanly with only standard axioms (propext, Classical.choice, Quot.sound). The file builds the algebraic and combinatorial foundations of Baker–Norine theory on finite graphs.

### Key theorems proved:

**Graph Laplacian & Chip-Firing (4 theorems):**
1. `tropicalLaplacian_sum_zero` — The graph Laplacian sums to zero over all vertices (discrete divergence theorem / charge conservation)
2. `tropicalLaplacian_add` — Laplacian is additive: Δ(f+g) = Δf + Δg (group homomorphism structure)
3. `tropicalLaplacian_zero` — Δ(0) = 0
4. `tropicalLaplacian_neg` — Δ(-f) = -Δf

**Linear Equivalence (4 theorems):**
5. `tropicalLinearEquiv_refl` — Reflexivity (witness f = 0)
6. `tropicalLinearEquiv_symm` — Symmetry (witness -f)
7. `tropicalLinearEquiv_trans` — Transitivity (witness f₁ + f₂)
8. `tropicalLinearEquiv_equivalence` — Full equivalence relation (enables Jacobian quotient)

**Degree Theory (3 theorems):**
9. `tropicalLinearEquiv_deg` — Chip-firing preserves divisor degree
10. `tropicalCanonicalDivisor_deg` — deg(K_G) = 2g − 2 (via handshaking lemma)
11. `neg_deg_no_effective_equiv` — Negative-degree divisors have rank −1

**Brill–Noether Number Algebra (5 theorems):**
12. `bnNumber_serre_duality` — ρ(g,r,d) = ρ(g, g−1−d+r, 2g−2−d) (tropical Serre duality)
13. `bnNumber_strict_mono_d` — ρ is strictly increasing in d
14. `bnNumber_rank_zero` — ρ(g,0,d) = d
15. `bnNumber_canonical_deg` — ρ at canonical degree
16. `bnNumber_genus_zero` — ρ(0,r,d) = (r+1)(d−r)

### FUTURE_DIRECTIONS.md

Contains 5 research directions extending the formalized infrastructure:
1. Full Baker-Norine Riemann-Roch via Dhar's burning algorithm
2. Jacobian group construction and matrix-tree theorem
3. Tropical linear series on metric graphs (CDPR theorem)
4. Specialization inequality with rank computation
5. Chip-firing on complete graphs and parking functions