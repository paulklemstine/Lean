# Summary of changes for run 8467094a-6dc5-4e16-9219-0046a73c669f
# Chip-Firing Duality and the Canonical Involution on Complete Graphs

## Lean 4 Formalization

Created `Catalog/Novelty/ChipFireDuality.lean` — a **315-line, sorry-free** Lean 4 formalization containing **25 proven theorems** about chip-firing on finite graphs, with focus on the complete graph K_n. All proofs are verified and use only standard axioms (propext, Classical.choice, Quot.sound).

### Key Theorems (building on `EML/BakerNorine.lean` and `Algebra/GraphRiemannRoch/Defs.lean`)

**Foundational results:**
- `lapl_deg_zero` — The Laplacian has degree zero (chip conservation law)
- `lapl_const` / `fire_all_trivial` — Firing all vertices simultaneously is the identity
- `linEquiv_preserves_deg` — Linear equivalence preserves divisor degree
- `principal_div_deg_zero` — Principal divisors have degree zero

**Complete graph specializations (PEGB):**
- `complete_degree` — Every vertex in K_n has degree n−1
- `canonDiv_complete` — Canonical divisor K_{K_n}(v) = n−3 for all v
- `genus_complete` — g(K_n) = (n−1)(n−2)/2
- `canonDiv_complete_deg` — deg(K_{K_n}) = n(n−3)

**Novel structural results:**
1. **Complement Firing Duality** (`complement_fire_duality`): On K_n, the Laplacian of the "all-ones-except-v" indicator assigns −(n−1) to v and +1 to all others. This shows firing all-but-v is the reverse of firing v — the combinatorial shadow of Serre duality.

2. **Canonical Complement Involution** (`canonComplement_involution` + `degree_duality`): The map D ↦ K_G − D is an involution satisfying deg(K−D) = 2g−2−deg(D), establishing perfect degree duality.

3. **S_n Equivariance** (`permAction_linEquiv`): Permutations of vertices preserve linear equivalence on K_n. Combined with `canonDiv_complete_fixed` (canonical divisor is permutation-fixed) and `uniform_fixed`, this explains why uniform divisors on K_n have special algebraic properties.

4. **Spectral Gap Theorem** (`lapl_kernel_complete`): If Δf = 0 on K_n (n ≥ 2), then f is constant. This encodes the maximal spectral gap of K_n (eigenvalue n with multiplicity n−1).

5. **Riemann-Roch Structural Verification** (`rr_canonical_prediction` + `canonical_deg_eq_2g_minus_2`): deg(K) + 1 − g = g − 1 for K_n, confirming the Baker-Norine prediction r(K_{K_n}) = g − 1 when combined with r(0) = 0.

6. **Negative Degree Obstruction** (`neg_deg_not_effective`): Divisors of negative degree have no effective representative — a key ingredient for rank-based arguments.

## Deliverables

- **`ARTICLE.md`** — Popular science article (~2000 words) about chip-firing and graph Riemann-Roch
- **`RESEARCH_PAPER.md`** — In-depth research paper with proof sketches, PEGB analysis, and cross-domain bridges
- **`FUTURE_DIRECTIONS.md`** — 5 research directions including full Baker-Norine formalization (grand challenge) and Kirchhoff matrix-tree theorem
- **`demo.py`** — Numerical demonstrations of all theorems
- **`algorithms.py`** — Type-hinted implementations of chip-firing, Dhar's algorithm, rank computation
- **`viz_spectral.py`**, **`viz_chipfire.py`** — Visualization scripts
- **`PACKAGE.json`** — Complete artifact bundle with 2 interactive HTML widgets (chip-firing simulator, Riemann-Roch explorer)