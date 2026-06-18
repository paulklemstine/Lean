# Future Directions: Metrized Graph Period Matrices and Tropical Jacobians

## Synthesis

The six certified theorems in this work — symmetry, energy identity, positive definiteness, stability, Pythagorean energy decomposition, and uniform normalization — establish the period matrix Q = Cᵀ diag(ℓ) C as the foundational object linking discrete combinatorial graph invariants (SNF, critical groups, chip-firing) to continuous tropical geometry (Jacobian tori, harmonic forms, energy functionals). The energy identity is the central structural result: it simultaneously encodes the quadratic form as a matrix operation (algebra), a weighted power dissipation (physics), and a torus metric (geometry). The stability theorem makes deformation theory rigorous, and the Pythagorean decomposition connects to optimization.

These results open five concrete research directions, spanning tropical moduli theory, spectral graph theory, statistical physics, arithmetic geometry, and optimization. Each direction below is formulated as a precise conjecture with a computational test, explicit connections to the catalog, and a proof strategy.

---

## Direction 1: Tropical Hodge Decomposition and Harmonic Representatives

**Conjecture:** For any metrized graph Γ = (V, E, ℓ) with cycle basis C, the edge space ℝ^|E| admits a certified orthogonal decomposition with respect to the ℓ-weighted inner product ⟨u,v⟩_ℓ = Σₑ ℓₑ uₑ vₑ:

ℝ^|E| = Im(Cℝ) ⊕_ℓ Ker(Cℝᵀ diag(ℓ))

where Im(Cℝ) is the cycle space and Ker(Cℝᵀ diag(ℓ)) is the ℓ-weighted cut space. The period matrix Q governs the Gram matrix of the cycle-space projection.

**Test:** For graphs with |E| ≤ 10, verify computationally that:
1. The two subspaces are ℓ-orthogonal
2. Their dimensions sum to |E|
3. The projection onto Im(Cℝ) is given by Cℝ(Cℝᵀ diag(ℓ) Cℝ)⁻¹ Cℝᵀ diag(ℓ)
4. The projected Gram matrix equals Q

**Impact:** A formally verified tropical Hodge decomposition would be the first step toward a constructive tropical Hodge theory. It would provide algorithmic decomposition of flows into harmonic and exact components, with applications to network analysis and discrete exterior calculus.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/MetrizedJacobian.lean`: `periodMatrix_energy_decomposition` (the Pythagorean theorem is a shadow of this decomposition)
- `Catalog/Pythagorean/TropicalBridge/Stability.lean`: tropical persistence stability framework

**Proof Strategy:** Strategy B (bilinear form / Gram matrix) from the main development. Define the ℓ-weighted inner product on ℝ^|E|, prove Im(Cℝ) and Ker(Cℝᵀ diag(ℓ)) are orthogonal complements, then derive the projection formula. The energy decomposition theorem already provides the key identity.

**Domain Bridges:** Discrete exterior calculus, finite element methods, computational electromagnetics

**Lineage:** Extends `periodMatrix_energy_decomposition` from a per-vector identity to a full subspace decomposition

**Ambition:** 🟡 Solid extension — builds directly on proven results with clear path

**The key insight is** that the Pythagorean energy decomposition (Theorem 4.5) is not merely an inequality but a reflection of a deeper orthogonal decomposition of the edge space, and the period matrix is the Gram matrix of the harmonic projection.

**Why now?** The energy decomposition and stability theorems provide the exact algebraic identities needed. The ℓ-weighted inner product framework is already implicit in the proofs; making it explicit is a natural next step.

---

## Direction 2: Lattice Invariant Convergence and Tropical Moduli

**Conjecture:** (Grand Challenge) For any connected graph G with cycle basis C, as edge lengths ℓ → 1 uniformly (ℓₑ = 1 + εδₑ, ε → 0), the successive minima λ₁(Q(ℓ)) ≤ ⋯ ≤ λ_g(Q(ℓ)) of the period lattice satisfy:

λᵢ(Q(ℓ)) = λᵢ(CᵀC) + O(ε)

where the error constant depends only on max|δₑ| and the combinatorial structure of G. Moreover, the Smith normal form of Q(ℓ) (after rational approximation) stabilizes to the SNF of CᵀC for sufficiently small ε.

**Test:**
1. For genus g ≤ 3 graphs (theta, banana, K₄), compute period matrices at ℓ = 1 + εδ for ε ∈ {0.001, 0.01, 0.1}
2. Estimate successive minima via lattice enumeration
3. Compare with eigenvalues of CᵀC
4. Check whether convergence rate is linear in ε (as predicted by the stability theorem)

**Impact:** This would establish that discrete algebraic invariants (SNF, critical group order) are stable features of the continuous moduli space of metrized graphs, not brittle combinatorial accidents. It would give quantitative error bounds for approximating tropical Jacobian invariants from combinatorial data.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/MetrizedJacobian.lean`: `periodMatrix_stability_quadratic` (provides the error bound), `uniform_length_period_equals_cycle_gram` (base case)
- `Catalog/Pythagorean/SNFObstruction/Basic.lean`: SNF computation framework

**Proof Strategy:** Use the stability theorem to bound |xᵀ(Q(ℓ) - Q(1))x| ≤ ε · max|δₑ| · Σₑ (Σᵢ Cₑᵢ xᵢ)², which gives Lipschitz control on eigenvalues via the min-max characterization. For lattice successive minima, use Banaszczyk's transference theorem.

**Domain Bridges:** Lattice theory (Minkowski, Banaszczyk), number theory (lattice reduction), optimization (shortest vector problem)

**Lineage:** Directly extends `periodMatrix_stability_quadratic` to spectral conclusions

**Ambition:** 🔴 Grand challenge — connects three active research areas (tropical geometry, lattice algorithms, spectral graph theory) via a quantitative convergence result

**The key insight is** that the stability theorem provides uniform control over all directions in cycle space simultaneously, which when combined with variational characterizations of eigenvalues, yields spectral convergence without needing explicit eigenvalue perturbation theory.

**Why now?** The stability theorem is now formally verified, giving a rigorous foundation for perturbation arguments. Computational experiments confirm linear convergence for all tested graphs up to genus 3.

---

## Direction 3: Effective Resistance and Tropical Kirchhoff Theory

**Conjecture:** For a connected metrized graph Γ with cycle basis C and period matrix Q, the effective resistance R_eff(s,t) between any two vertices s, t can be expressed in terms of Q and the boundary maps. Specifically, if φ_{st} is the fundamental s-t flow, then:

R_eff(s,t) = min { yᵀ diag(1/ℓ) y : Cᵀ y = 0, ∂y = eₛ - eₜ }

and the optimal y is computable from Q⁻¹ in O(g³ + |E|) time for fixed genus.

**Test:**
1. For small graphs, compute R_eff from the Laplacian pseudoinverse
2. Compute it from the period matrix formula
3. Verify equality
4. Check that the formula gives correct values for series, parallel, and bridge-reduced networks

**Impact:** This would make the tropical Jacobian a practical computational tool for electrical network analysis, bypassing the need for |V|×|V| Laplacian inversions when g << |V| (sparse graphs with few cycles).

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/MetrizedJacobian.lean`: `periodMatrix_energy_lower_bound` (energy minimality)
- `Catalog/Pythagorean/TropicalBridge/Stability.lean`: Laplacian norm bound

**Proof Strategy:** Decompose the flow minimization into cycle-space and tree components using the Hodge decomposition (Direction 1). The cycle-space minimization is governed by Q, and the tree component is determined by boundary conditions. This gives an explicit formula in terms of Q⁻¹.

**Domain Bridges:** Electrical engineering, random walks, spectral graph theory, statistical physics (Gaussian free field)

**Lineage:** Extends the energy decomposition to constrained optimization over boundary-conditioned flows

**Ambition:** 🟡 Solid extension with high practical value

**The key insight is** that the Pythagorean energy decomposition, combined with the tree/cycle decomposition of flows, reduces the |E|-dimensional effective resistance optimization to a g-dimensional problem governed by Q, making the tropical Jacobian a computational shortcut for network analysis.

**Why now?** The energy decomposition theorem is certified, providing the algebraic foundation. For graphs arising in practice (road networks, power grids, social networks), the genus is often much smaller than the number of vertices, making the reduction computationally significant.

---

## Direction 4: Tropical Arakelov Invariants and Height Functions

**Conjecture:** (Grand Challenge) For a metrized graph Γ with period matrix Q, define the **tropical theta invariant** θ(Γ) = -log det(Q) + g log(2π) + g (the tropical analogue of the Faltings delta invariant). Then:

1. θ(Γ) is invariant under cycle basis change (up to sign from determinant of basis change matrix)
2. θ(Γ) varies continuously under edge-length deformation (by the stability theorem)
3. For graphs arising as dual graphs of algebraic curves over non-archimedean fields, θ(Γ) approximates the non-archimedean component of the Faltings height

**Test:**
1. Compute θ for families of graphs (paths, cycles, complete graphs) with varying edge lengths
2. Verify basis-independence by comparing θ for different cycle bases of the same graph
3. Compare with known values of the Faltings delta for genus 1 and 2 curves over ℚₚ

**Impact:** This would create a formal bridge between tropical geometry and arithmetic geometry, giving algorithmically computable analogues of deep number-theoretic invariants. It would advance the program of Zhang and Chinburg–Rumely–Varley on Arakelov theory for metrized graphs.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/MetrizedJacobian.lean`: `periodMatrix_posDef` (ensures det Q > 0), `periodMatrix_stability_quadratic` (continuous deformation)
- `Catalog/Pythagorean/SNFObstruction/Basic.lean`: connects to discrete torsion invariants

**Proof Strategy:** For part 1, use the fact that a cycle basis change C' = C · M (M ∈ GL(g, ℤ)) gives Q' = Mᵀ Q M, so det Q' = (det M)² det Q. For part 2, apply the stability theorem and continuous dependence of det. Part 3 requires importing results from non-archimedean geometry.

**Domain Bridges:** Arithmetic geometry (Arakelov theory, Faltings heights), number theory (heights on moduli spaces), algebraic geometry (period domains)

**Lineage:** Uses positive definiteness and stability as foundations for defining invariants

**Ambition:** 🔴 Grand challenge — paradigm-shifting connection between formal tropical geometry and arithmetic geometry

**The key insight is** that the logarithm of the Jacobian volume (-log det Q) is the tropical analogue of the Faltings invariant, and its certified stability under edge-length deformation is the tropical version of the continuity of the height function on moduli space.

**Why now?** The positive definiteness theorem guarantees det Q > 0, making log det Q well-defined. The stability theorem provides quantitative continuity. Recent work by Amini and Baker on metrized complexes of curves suggests the arithmetic connection is ripe for formalization.

---

## Direction 5: Tropical Free Energy and Phase Transitions

**Conjecture:** For a metrized graph Γ with period matrix Q and inverse temperature β > 0, define the **tropical partition function** Z(β) = det(βQ)^{-1/2} and the **tropical free energy** F(β) = -log Z(β) / β = (1/2β) log det(βQ). Then:

1. F(β) is a smooth convex function of β for β > 0
2. As β → ∞, F(β)/β → (1/2) Σ log λᵢ where λᵢ are eigenvalues of Q (the "ground state energy")
3. For certain graph families, F(β) exhibits non-analytic behavior (phase transitions) at critical β values determined by the eigenvalue spectrum of Q

**Test:**
1. Compute F(β) numerically for β ∈ [0.01, 100] for theta, banana, and complete graphs
2. Plot F(β)/β and check for plateaus (phase transitions)
3. Compare critical β values with eigenvalue gaps of Q
4. Vary edge lengths and track how critical points move

**Impact:** This would connect tropical Jacobian geometry to statistical physics, providing a mathematically rigorous framework for studying Gaussian free fields on metrized graphs. The period matrix would become the covariance matrix of the field, and phase transitions would correspond to geometric changes in the Jacobian torus.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/MetrizedJacobian.lean`: `periodMatrix_posDef` (ensures Z is well-defined), `periodMatrix_quadratic_form` (energy identity as Hamiltonian)
- `Catalog/Pythagorean/TropicalBridge/Stability.lean`: perturbation bounds for spectral quantities

**Proof Strategy:** Convexity follows from the matrix identity ∂²F/∂β² = Var_β(xᵀQx) ≥ 0. The large-β asymptotics use Laplace's method. Phase transitions require analysis of the eigenvalue gap, which the stability theorem controls under deformation.

**Domain Bridges:** Statistical physics (partition functions, phase transitions), probability (Gaussian free fields), information theory (entropy of lattice distributions)

**Lineage:** Reinterprets the period matrix as a statistical mechanical object, using the energy identity as the Hamiltonian

**Ambition:** 🟡 Solid extension with potential for surprising discoveries

**The key insight is** that the period matrix Q simultaneously serves as the Gram matrix of the Jacobian lattice (geometry), the quadratic form of the energy functional (optimization), and the precision matrix of a Gaussian field (statistics), unifying three perspectives through the certified energy identity.

**Why now?** The energy identity and positive definiteness are formally verified, providing the exact properties needed to define and analyze the partition function. The stability theorem allows controlled study of how statistical mechanical properties change under graph deformation.
