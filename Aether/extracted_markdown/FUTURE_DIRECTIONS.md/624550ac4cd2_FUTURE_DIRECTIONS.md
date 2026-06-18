# Future Directions: Systolic Quantum Error Correction

## Synthesis

This research cycle established the **Systolic Code** framework, proving that F₂ chain complexes canonically produce CSS quantum codes (via ∂²=0 ⟹ CSS orthogonality) and that the code distance equals the systole of the underlying cell complex. The central discovery is the **BPT–Systolic equivalence**: the Bravyi-Poulin-Terhal bound from quantum information theory and Gromov's systolic inequality from differential geometry are dual perspectives on the same geometric constraint, both yielding d = O(√g) for genus-g surface codes.

The most promising cross-domain connection is between **spectral graph theory** and **code distance bounds**. The Cheeger inequality relates the spectral gap of the graph Laplacian to expansion, and expansion-based arguments yield code distance bounds (cf. `code_distance_from_expansion` in the catalog). If the systole can be related to the spectral gap of the chain complex Laplacian Δ = ∂∂* + ∂*∂, this would connect three domains: Riemannian geometry (systole), spectral theory (eigenvalues), and quantum error correction (code distance).

The highest breakthrough potential lies in Direction 1 (Spectral Systolic Codes), as it could yield *constructive* bounds — not just existence results — for quantum codes from spectral data, potentially leading to efficient algorithms for code design.

---

### Direction 1: Spectral Systolic Codes — Eigenvalues as Code Distance Bounds

**Conjecture**: For an F₂ chain complex with combinatorial Laplacian Δ₁ = ∂₁ᵀ∂₁ + ∂₂∂₂ᵀ acting on 1-chains, the systole (code distance) satisfies:

  d ≥ C · n₁ · λ₁(Δ₁)

where λ₁ is the smallest nonzero eigenvalue and C is a universal constant. This would be a discrete analog of Cheeger's inequality adapted to chain complexes.

**Test**: Compute λ₁(Δ₁) and the exact systole for toric codes with L = 2, 3, ..., 10. For the L×L torus, λ₁ should be O(1/L²) and d = L, so the ratio d/(n·λ₁) should converge. If the ratio diverges or oscillates, the conjecture (in this form) is falsified.

**Impact**: If true, this provides an *efficiently computable* lower bound on code distance (eigenvalues can be approximated in polynomial time, unlike the NP-hard exact distance). This would enable spectral design of quantum codes: optimize the spectrum of Δ₁ to maximize distance.

**Catalog References**: `code_distance_from_expansion` (Bridges/Sp4SpectralGap.lean), `Physics/SystolicQEC/Bounds.lean`

**Proof Strategy**: (1) Define the combinatorial Laplacian Δ₁ as a matrix over ℝ (or ℚ for computability). (2) Prove that any non-trivial cycle v satisfies ⟨v, Δ₁v⟩ ≥ λ₁·‖v‖² (Rayleigh quotient). (3) Show that ⟨v, Δ₁v⟩ relates to the weight of v via ∂₁ᵀ∂₁. (4) Combine to get wt(v) ≥ f(λ₁). The key lemma is relating the F₂ Hamming weight to the real inner product.

**Domain Bridges**: Spectral graph theory ↔ Quantum error correction ↔ Riemannian geometry

**Lineage**: Builds on the systolic code framework (Physics/SystolicQEC) and the expansion-distance bridge (Bridges/Sp4SpectralGap.lean).

**Ambition**: grand_challenge

---

### Direction 2: Sheaf Codes — Locally-Varying Quantum Error Correction

**Conjecture**: Replacing the constant coefficient system F₂ with a *sheaf* of F₂-modules on a cell complex produces quantum codes where the stabilizer structure varies over the complex. Specifically, for a sheaf F on a graph G with stalks of varying dimension, the sheaf cohomology H¹(G, F) gives a CSS code whose logical qubits correspond to sheaf cohomology classes, and the code distance is the *cosystole* of the sheaf (minimum weight of a non-trivial 1-cocycle).

**Test**: Construct a sheaf on the 3×3 torus grid where edge stalks have dimension 1 or 2 depending on position. Compute H¹ and the cosystole. Compare with the standard toric code [[18, 2, 3]]. If the sheaf code has higher distance with the same or fewer physical qubits, the construction is non-trivially useful.

**Impact**: Sheaf codes could interpolate between topological codes (constant sheaf = standard homological code) and algebraic-geometry codes (sheaves on algebraic curves). This would unify two major families of quantum codes.

**Catalog References**: `Physics/SystolicQEC/Core.lean` (F2ChainComplex, CSSCode)

**Proof Strategy**: (1) Define SheafComplex as a chain complex with varying-dimension stalks. (2) Prove the sheaf version of ∂²=0 ⟹ CSS orthogonality. (3) Define the sheaf systole. (4) Prove that constant sheaves recover the standard construction (consistency check). The key challenge is handling varying-dimension stalks in Lean's type system — use Sigma types or dependent matrices.

**Domain Bridges**: Algebraic geometry (sheaves) ↔ Quantum error correction ↔ Homological algebra

**Lineage**: Direct extension of the F₂ chain complex framework in Physics/SystolicQEC/Core.lean.

**Ambition**: grand_challenge

---

### Direction 3: Systolic Ratio Convergence for Optimal Hyperbolic Surfaces

**Conjecture**: For the genus-g surface with maximal systole-to-area ratio (generalizing the Bolza surface at g=2), the normalized systolic ratio converges:

  lim_{g→∞} sys(Σ_g)² / (4π(g-1)) = 4/3

where sys(Σ_g) is the systole with respect to the hyperbolic metric of area 4π(g-1).

**Test**: Compute systoles for arithmetic hyperbolic surfaces at genus g = 2, 3, 5, 7, 11, 13, 17, 19 (taking surfaces from congruence subgroups of PSL(2,ℤ)). Plot sys²/(4π(g-1)) and check convergence.

**Impact**: This would establish a precise constant in the Gromov systolic inequality for surfaces, resolving a 40-year-old open problem. For quantum codes, it gives the optimal achievable d²/n ratio.

**Catalog References**: `Physics/SystolicQEC/Bounds.lean` (systolic_ratio_bounded, distance_sqrt_genus)

**Proof Strategy**: (1) Formalize the Bolza surface as a quotient of the hyperbolic plane. (2) Compute its systole (known: sys = 2·arccosh(1+√2)). (3) For higher genus, use Kazhdan's property (T) for arithmetic lattices to bound the spectral gap, hence the systole via Direction 1's spectral bound. (4) Take limits using number-theoretic density of primes.

**Domain Bridges**: Hyperbolic geometry ↔ Number theory (arithmetic groups) ↔ Quantum codes

**Lineage**: Extends the genus-distance scaling theorems (genus_distance_scaling, distance_sqrt_genus).

**Ambition**: extension

---

### Direction 4: Chain Complex Products and Quantum LDPC Codes

**Conjecture**: The balanced tensor product of two F₂ chain complexes C and D produces a chain complex C ⊗ D whose CSS code has:
- n = n₁(C)·n₁(D) + n₀(C)·n₂(D) + n₂(C)·n₀(D)
- k = β₁(C)·β₁(D)
- d ≥ min(sys(C), sys(D))

Furthermore, iterating the product k times gives codes with d = Ω(n^{1-1/2^k}) — approaching linear distance.

**Test**: Implement the balanced product for two copies of the cycle graph C₅ (with trivial 2-cells). Compute the resulting code parameters. If k > 0 and d ≥ 5, the construction works.

**Impact**: This formalizes the Panteleev-Kalachev construction of asymptotically good quantum LDPC codes, arguably the biggest breakthrough in quantum coding theory in the last decade.

**Catalog References**: `Physics/SystolicQEC/Core.lean` (directSum, F2ChainComplex), `Physics/SystolicQEC/Bounds.lean` (productLength_comm)

**Proof Strategy**: (1) Define the tensor product of chain complexes (Künneth formula). (2) Prove ∂²=0 for the product complex. (3) Compute H₁ of the product via Künneth. (4) Bound the systole of the product from below using the systoles of the factors. Key lemma: a non-trivial cycle in the product projects to non-trivial cycles in both factors.

**Domain Bridges**: Homological algebra (Künneth) ↔ Quantum LDPC codes ↔ Combinatorics (expander graphs)

**Lineage**: Extends the direct sum construction in Physics/SystolicQEC/Core.lean to tensor products.

**Ambition**: extension

---

### Direction 5: Tropical Systolic Geometry and Code Families

**Conjecture**: The tropical analog of the systole — the shortest non-trivial cycle in a metric graph (tropical curve) — gives rise to quantum codes via the tropical chain complex. For a genus-g metric graph with edge lengths, the tropical systole satisfies a discrete Gromov inequality: sys² ≤ C · vol where vol = Σ lengths.

**Test**: Compute tropical systoles for random genus-5 metric graphs (100 samples). Verify sys²/vol ≤ 2 for all samples. If any violate this bound, the tropical Gromov conjecture is falsified.

**Impact**: Tropical geometry provides *combinatorially explicit* constructions, unlike smooth Riemannian geometry. Tropical codes would be the first family of quantum codes with fully explicit, polynomial-time constructible parameters achieving the systolic bound.

**Catalog References**: `Tropical/PersistentHomology` (tropical homology), `Physics/SystolicQEC/Bounds.lean`

**Proof Strategy**: (1) Define tropical chain complex (graph with edge lengths). (2) Define tropical systole (shortest cycle in weighted graph — this is Dijkstra/BFS). (3) Prove the tropical Gromov inequality using the cut-and-paste argument of Gromov adapted to graphs. (4) Construct the tropical CSS code and prove distance = tropical systole.

**Domain Bridges**: Tropical geometry ↔ Graph algorithms ↔ Quantum codes ↔ Combinatorial optimization

**Lineage**: Bridges the tropical homology work in the Catalog with the systolic QEC framework.

**Ambition**: extension
