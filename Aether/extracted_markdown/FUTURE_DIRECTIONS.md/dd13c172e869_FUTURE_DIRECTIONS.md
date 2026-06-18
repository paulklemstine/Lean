# Future Directions: Newton Polytope Erosion Theory

## Synthesis

The shadow-erosion correspondence established here — identifying the quadratic shadow with Minkowski erosion of the Newton polytope — is the first bridge in a larger program connecting **derivative complexity** to **convex geometry**. All five directions below exploit this bridge from different angles: Direction 1 generalizes to arbitrary derivative orders, Direction 2 connects to Ehrhart counting theory, Direction 3 attacks the sparse obstruction problem structurally, Direction 4 bridges to tropical intersection theory and algebraic statistics, and Direction 5 pushes toward algorithmic applications in polynomial system solving. Together, they constitute a program where *calculus becomes geometry* — every question about "what survives differentiation" maps to a question about "what fits inside an eroded polytope."

---

## Direction 1: Higher-Order Erosion Hierarchy

**Conjecture:** For any k ≥ 1, the k-th universal shadow USh_k(S) (requiring u + β ∈ S for all β ∈ Δ_k(ℕ)) equals LP(Newt(S) ⊖ Δ_k(ℝ)) when S is lattice-saturated, where Δ_k(ℝ) = {β ∈ ℝ≥0ⁿ : ∑βᵢ = k}.

**Test:** Compute USh_k for k = 1, 2, 3, 4 on the standard simplex dilations mΔ_n for n = 2, 3 and m up to 20. Verify equality with erosion lattice points. Detect the critical dilation m*(k) below which the erosion is empty.

**Impact:** Establishes a complete hierarchy of derivative-geometric correspondences. The k = 1 case (first derivatives) should be classical; k = 2 is our present work; k ≥ 3 is new territory where the simplex kernel's geometry becomes richer.

**Catalog References:** `Pythagorean/NewtonErosion.lean` (Theorems 1–2), `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (quadratic shadow definition)

**Proof Strategy:** The same convexity argument applies: Δ_k(ℝ) is the convex hull of Δ_k(ℕ), the set {y : ι(u) + y ∈ Newt(S)} is convex, and lattice saturation provides the reverse inclusion. The formal proof should follow the same pattern as `universalQuadShadow_subset_erosionLattice` with k replacing 2.

**Domain Bridges:** Connects to partial differential equations (k-th order PDE symbol support) and representation theory (weight multiplicity under restriction).

**Lineage:** Direct generalization of Theorems 1–2.

**Ambition:** Extension — the proof method is known to generalize; the value is in the formal verification and the connection to the k-dependent erosion geometry.

---

## Direction 2: Ehrhart Polynomial of the Derivative Shadow

**Conjecture:** For a rational polytope P ⊂ ℝⁿ, the function E_P(m) := |USh₂(mP ∩ ℤⁿ)| is a polynomial in m for m ≥ 2, with leading term Vol(P) · mⁿ and sub-leading term involving the integral of h_Δ₂ over the facet normals of P, where h_Δ₂(c) = 2 max_i c_i is the support function of Δ₂.

**Test:** Compute E_P(m) for P = standard simplex, cube [0,1]ⁿ, cross-polytope, and a random 3D rational polytope, for m = 1, ..., 30. Fit polynomial regression and compare coefficients to geometric invariants (volume, surface area, Euler characteristic).

**Impact:** If confirmed, this establishes **derivative complexity as an Ehrhart invariant** — the first connection between integer-point geometry and differential algebra. The sub-leading coefficient would give a new geometric interpretation of "derivative surface loss."

**Catalog References:** `Pythagorean/NewtonErosion.lean` (erosion lattice definition, equality theorem)

**Proof Strategy:** Since USh₂(mP ∩ ℤⁿ) = LP(mP ⊖ Δ₂) for saturated supports, and mP ⊖ Δ₂ = m(P ⊖ (1/m)Δ₂), the Ehrhart function of the eroded polytope should be computable via Ehrhart-Macdonald reciprocity. The key technical challenge is handling the non-integer dilation of the kernel.

**Domain Bridges:** Directly connects to number theory (Ehrhart theory, lattice point counting) and computational algebra (polynomial system complexity bounds).

**Lineage:** Builds on Direction 1 and computational experiments in `demo.py`.

**Ambition:** Grand challenge — proving Ehrhart polynomiality for eroded polytopes requires new theory at the intersection of Ehrhart theory and morphological operations.

---

## Direction 3: Structural Characterization of the Sparse Gap

**Conjecture:** For non-saturated S, the gap set Gap(S) := EL(S) \ USh₂(S) is determined by the "deficiency complex" — the simplicial complex of missing lattice points and their quadratic neighborhoods. Specifically, u ∈ Gap(S) iff there exists β ∈ Δ₂(ℕ) such that u + β ∈ LP(Newt(S)) \ S.

**Test:** Enumerate all supports S ⊆ {0,...,6}² with |S| ≤ 15. For each non-saturated S, compute Gap(S) and verify the structural characterization. Classify the "minimal sparse obstructions" — supports where removing a single point from a saturated set creates a gap.

**Impact:** Would give a complete combinatorial description of when the geometric prediction fails, enabling algorithms that correct for sparsity. The deficiency complex could be a new invariant of sparse polynomials with connections to matroid theory.

**Catalog References:** `Pythagorean/NewtonErosion.lean` (Theorem 3: exists_newton_gap_of_not_saturated), `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (monotonicity)

**Proof Strategy:** The forward direction (gap implies missing point in neighborhood) follows from the proof of Theorem 2 — the only place saturation is used is to conclude u + β ∈ S from u + β ∈ LP(Newt(S)). The reverse direction requires showing that a single missing point in the quadratic neighborhood prevents u from entering the universal shadow.

**Domain Bridges:** Connects to matroid theory (sparse support as matroid truncation), coding theory (lattice codes with deleted positions), and algebraic statistics (missing interactions in log-linear models).

**Lineage:** Extends Theorem 3 from existence to structural characterization.

**Ambition:** Extension — the characterization is a natural refinement of the saturation condition, with clear proof strategy.

---

## Direction 4: Tropical Hessian Geometry via Support Erosion

**Conjecture:** The singular locus of a tropical hypersurface defined by a tropical polynomial with support S can be characterized in terms of the erosion LP(Newt(S) ⊖ Δ₂). Specifically, the tropical Hessian variety (defined by the tropical determinant of the Hessian matrix) has support contained in the erosion lattice, with equality for lattice-saturated supports.

**Test:** For tropical curves in ℝ² defined by degree-4 and degree-5 supports, compute the tropical Hessian via the tropical determinant formula, extract its support, and compare with the erosion lattice. Test on both saturated and sparse supports.

**Impact:** Would establish erosion geometry as a tool for detecting tropical singularities — a fundamental problem in tropical geometry where current methods rely on polyhedral subdivision rather than support-level arguments. This could lead to efficient singularity detection algorithms.

**Catalog References:** `Pythagorean/NewtonErosion.lean` (tropical shadow theorem), Catalog/Tropical/*.lean (tropical geometry infrastructure)

**Proof Strategy:** The tropical Hessian det(Hess_trop(f)) involves a max over n! terms, each being a sum of tropical second derivatives. The support of each such term is controlled by the shadow, hence by the erosion. The union over permutations gives the full Hessian support.

**Domain Bridges:** Connects to algebraic geometry (singularity theory), mathematical physics (zero-temperature phase transitions as tropical limits), and optimization (detecting non-smoothness in piecewise-linear objectives).

**Lineage:** Extends the tropical support theorem to the determinantal/Hessian setting.

**Ambition:** Grand challenge — connecting erosion to tropical intersection theory would require significant new tropical-geometric infrastructure.

---

## Direction 5: Algorithmic Newton Erosion for Polynomial System Solving

**Conjecture:** For polynomial systems f₁ = ··· = fₙ = 0 where each fᵢ has Newton polytope Pᵢ, the "derivative depth" — the maximum number of times all polynomials can be differentiated before some support becomes empty — equals min_i ⌊h_{Pᵢ}(c) / h_{Δ₁}(c)⌋ over unit vectors c, where h denotes support functions.

**Test:** Implement a Newton erosion oracle that, given Newton polytopes P₁,...,Pₙ, computes the derivative depth in O(n · |vertices|) time using support function evaluations. Compare with brute-force shadow computation for random polynomial systems in 3-5 variables.

**Impact:** Would give a fast geometric preprocessing step for polynomial system solvers: the derivative depth predicts how many jet-space reductions are possible, bounding the complexity of homotopy continuation and resultant methods.

**Catalog References:** `Pythagorean/NewtonErosion.lean` (erosion monotonicity, support function connection), `algorithms.py` (computational implementation)

**Proof Strategy:** The support function characterization h_{P⊖K}(c) = h_P(c) - h_K(c) (valid when the erosion is nonempty) reduces derivative depth to a linear optimization over polytope normals. This is a classical result in convex geometry that needs formalization.

**Domain Bridges:** Connects to computational algebraic geometry (polynomial system solving, homotopy methods), optimization (support function computation), and computer-aided design (morphological operations in geometric modeling).

**Lineage:** Application of the erosion theory to algorithmic problems.

**Ambition:** Extension — the support function formula is well-known in convex geometry; the novelty is the application to derivative depth and polynomial solving.
