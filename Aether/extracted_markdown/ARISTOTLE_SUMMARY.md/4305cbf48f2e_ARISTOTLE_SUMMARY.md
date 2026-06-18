# Summary of changes for run 51749b45-ae2e-4da1-a391-790b55287b34
## Completed: Structural Theorems on Chip-Firing for Complete Graphs

### Lean 4 Proofs (`Algebra/ChipFiringStructure.lean`)
Successfully formalized and machine-verified **17 theorems** (0 sorries) establishing the structural theory of chip-firing on complete graphs K_n. The file compiles cleanly with Mathlib. Key results:

1. **Spectral Gap Theorem** (`laplacian_kernel_constant`): On K_n (n ≥ 1), if Δf = 0 then f is constant. This characterizes the Laplacian kernel as exactly the constant functions — the algebraic backbone of chip-firing theory on K_n.

2. **Complement Firing Duality** (`complement_fire_duality`): On *any* finite graph, firing all vertices except v equals anti-firing v. Formally: Δ(1_{V\{v}}) = -Δ(1_{v}). This follows from fire-all triviality (Δ1 = 0) and Laplacian linearity.

3. **Permutation Equivariance** (`laplacian_perm_equivariant`, `linEquiv_perm_invariant`): The Laplacian of K_n commutes with permutations (σ·Δf = Δ(f∘σ⁻¹)), and consequently S_n preserves linear equivalence of divisors.

4. **Canonical Divisor Structure** (`canonical_complete_val`, `canonical_perm_fixed`, `canonical_unique_constant`): The canonical divisor of K_n is uniform (K(v) = n-3), permutation-invariant, and the unique constant divisor of degree n(n-3).

5. **Rank Obstruction** (`neg_deg_no_effective`): Negative degree divisors cannot be linearly equivalent to effective divisors.

Supporting results include: Laplacian degree-zero (`laplacian_deg_zero`), degree preservation under linear equivalence (`linEquiv_preserves_deg`), complete graph degree formula (`complete_degree`), explicit Laplacian formula on K_n (`laplacian_complete_eq`), and uniform divisor properties.

### Cross-Domain Bridge
The spectral gap theorem connects to information theory: K_n has information dimension n-1 (= rank of Jacobian group = number of independent chip-firing directions), the maximum possible for n vertices.

### Written Deliverables
- **ARTICLE.md**: Popular-science article (~2000 words) on the conservation-duality-symmetry triad in chip-firing
- **RESEARCH_PAPER.md**: Full research paper (~4000 words) with proofs, PEGB analysis, and discussion
- **FUTURE_DIRECTIONS.md**: 4 research directions including full Baker-Norine Riemann-Roch formalization (grand challenge) and extensions to strongly regular graphs and Cayley graphs

### Code Deliverables
- **demo.py**: Numerical demonstrations of all 5 main results
- **algorithms.py**: Type-hinted implementations of chip-firing algorithms
- **PACKAGE.json**: Complete package with 3 interactive HTML demos (chip-firing simulator, spectral gap explorer, complement duality visualizer)

### Catalog Lineage
Builds on `Catalog/Algebra/GraphRiemannRoch/Defs.lean` and `Catalog/EML/BakerNorine.lean`. Extends the spectral gap connection from `Catalog/Tropical/SymbolicDynamics/Core.lean`.