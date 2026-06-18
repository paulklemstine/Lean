# Future Directions: Keller Map Reduction Theory

## Synthesis

The formally verified framework for Keller map reduction theory opens five distinct research corridors, unified by a single architectural insight: the Jacobian Conjecture decomposes into a chain of increasingly structured rigidity problems, each amenable to different mathematical tools. The normalization to identity linear part (Theorem 3) provides the entry point; the cubic homogeneous reduction (Theorem 4, interface) provides the target; and the Dixmier bridge (Theorem 5) provides the exit into noncommutative algebra. The directions below exploit this architecture by attacking different links in the chain, with at least two aiming for paradigm-shifting connections to other domains.

---

## Direction 1: Formal Bass–Connell–Wright Stable Embedding

**Conjecture**: The full Bass–Connell–Wright reduction can be formalized in Lean 4 by constructing an explicit stable embedding functor that lifts Keller maps of arbitrary degree to cubic homogeneous Keller maps in higher dimensions, preserving invertibility.

**Test**: Implement the stable embedding for specific maps (e.g., degree-4 maps in dimension 2) and verify that the lifted cubic map is Keller and that invertibility transfers correctly. A failure would indicate a flaw in the classical proof's constructive content.

**Impact**: Completing this formalization would close the last sorry in our framework, yielding the first machine-verified proof of the Bass–Connell–Wright theorem. This would be a landmark in formalized mathematics and would make the full reduction pipeline verified end-to-end.

**Catalog References**: `Algebra/Jacobian/KellerReduction.lean` (jacobian_reduces_to_cubic — the sorry to fill), `Catalog/Speculative/AutoResearch/Algebra/Jacobian/CubicReduction.lean` (existing interface).

**Proof Strategy**: Decompose into three verified stages: (a) show that adding dummy identity coordinates preserves Keller-ness and invertibility; (b) formalize the homogenization step using projective completion; (c) implement the degree-3 reduction by introducing auxiliary variables x' = (nonlinear terms of degree ≥ 4) and showing the enlarged system is cubic homogeneous and Keller.

**Domain Bridges**: Algebraic geometry (projective completion), commutative algebra (polynomial ring extensions).

**Lineage**: Builds directly on our normalization theorem (Theorem 3) and the polyComp_assoc infrastructure.

**Ambition**: Grand challenge — a complete formalization would be a first in the field.

---

## Direction 2: Weyl Algebra Construction and Concrete Dixmier Bridge

**Conjecture**: The first Weyl algebra A₁(k) can be formalized in Lean 4 as a quotient of the free algebra on generators x, d by the relation dx - xd = 1, and the Jacobian-to-Dixmier implication can be proved concretely (not just via True placeholder) using the symbol map on the associated graded.

**The key insight is** that the associated graded algebra gr(A_n) is isomorphic to the polynomial ring k[x₁,...,xₙ,ξ₁,...,ξₙ], so an endomorphism of A_n induces a polynomial endomorphism of k^{2n} whose Jacobian determinant is nonzero. This makes the bridge computable.

**Why now?** Mathlib has extensive quotient algebra infrastructure (QuotientAlgebra, TwoSidedIdeal) that didn't exist two years ago. The filtration theory needed for the associated graded is also emerging.

**Test**: Formalize A₁(k) and verify the commutation relation d*x^n = x^n*d + n*x^{n-1}. Then construct the symbol map and show it sends Weyl endomorphisms to polynomial maps. A concrete test: show that the Weyl automorphism σ(x) = x + d², σ(d) = d induces a Keller map.

**Impact**: Would transform the Dixmier bridge from an abstract placeholder to a concrete computational tool, enabling transfer of polynomial techniques to quantum operator theory.

**Catalog References**: `Catalog/Algebra/Jacobian/WeylAlgebra.lean` (existing IsWeylPair infrastructure), `Algebra/Jacobian/KellerReduction.lean` (cubic_jacobian_implies_dixmier).

**Proof Strategy**: Define A_n as Free k {x_i, d_i} / ⟨d_i x_j - x_j d_i - δ_{ij}⟩. Build the standard filtration by total degree. Show gr(A_n) ≅ k[x,ξ]. Construct the symbol map as the projection to leading terms.

**Domain Bridges**: Noncommutative algebra, quantum mechanics (canonical commutation relations), deformation quantization.

**Lineage**: Extends dixmier_of_jacobian_A1_abstract and jacobian_implies_dixmier_abstract from the catalog.

**Ambition**: Grand challenge — first formalized Weyl algebra with verified Dixmier bridge.

---

## Direction 3: Nilpotent Jacobian Inverse Formulas

**Conjecture**: For a cubic homogeneous Keller map F = Id + H with nilpotent Jacobian JH of index m, the formal inverse is exactly G = Σ_{k=0}^{m-1} (-1)^k H^{∘k} where H^{∘k} denotes the k-fold composition of H with itself (treating H as a perturbation).

**The key insight is** that the formal inverse series truncates at finite order when JH is nilpotent, giving an explicit polynomial formula for the inverse. This is computationally verifiable and leads to degree bounds.

**Why now?** Our framework's nilpotency theorems (isNilpotent_of_det_one_add_smul, charpoly_nilpotent_eq_X_pow) provide the formal foundation, and the polyComp_assoc infrastructure enables verified composition.

**Test**: For 3×3 nilpotent matrices of index 3, verify that the truncated inverse series gives exact inverses up to degree 9. Compute the inverse degree as a function of nilpotency index and dimension.

**Impact**: Would give constructive inverse formulas with verified degree bounds, directly applicable to polynomial automorphism groups and computational algebra systems.

**Catalog References**: `Algebra/Jacobian/KellerReduction.lean` (cubicHomog_hasIdentityLinearPart, jacobianMat_id_plus_H), `Catalog/Algebra/Jacobian/DruzkowskiTheory.lean` (hessianNilpotencyIndex).

**Proof Strategy**: By induction on nilpotency index. The key lemma: if (JH)^m = 0, then the m-th iterate of G_k = Id - H(G_{k-1}) stabilizes. This uses the chain rule for polynomial composition and the nilpotency hypothesis.

**Domain Bridges**: Computational algebra, symbolic computation.

**Lineage**: Direct extension of nilpotency theorems and Drużkowski structure theory.

**Ambition**: Solid extension — formulaic but with concrete computational payoff.

---

## Direction 4: Arithmetic Circuit Depth and Keller Obstructions

**Conjecture**: A polynomial map F : k^n → k^n whose coordinate functions have arithmetic circuit depth 0 (i.e., are linear forms plus constants) and satisfies the Keller condition must be a linear automorphism. More generally, circuit depth d forces the nonlinear part of a Keller map to have degree at most 3^d.

**The key insight is** that arithmetic circuit depth constrains the algebraic complexity of polynomial maps in a way that interacts with the Jacobian condition. Shallow circuits cannot realize the nonlinear structures needed for non-trivial Keller behavior, connecting invertibility to computational complexity.

**Why now?** The connection between algebraic complexity and polynomial automorphisms is unexplored in the formal verification world. Our linearPartMatrix and HasIdentityLinearPart definitions provide the starting point for depth analysis.

**Test**: Enumerate all polynomial maps of circuit depth ≤ 1 in dimension 2 over Q, check Keller condition, verify they are linear automorphisms (or at most quadratic). A depth-2 non-linear Keller map would be a breakthrough example.

**Impact**: Would establish a new bridge between the Jacobian Conjecture and computational complexity theory, potentially connecting P vs NP-type questions to polynomial invertibility.

**Catalog References**: `Algebra/Jacobian/KellerReduction.lean` (linearPartMatrix, keller_linear_part_det_ne_zero — the depth-0 case is essentially proved).

**Proof Strategy**: For depth 0: a Keller map with all linear coordinate functions has Jacobian matrix that is a constant matrix, so constant determinant iff the matrix is invertible, giving a linear automorphism. For depth d > 0: use the composition structure of circuits to bound degree of the nonlinear part.

**Domain Bridges**: Computational complexity theory (arithmetic circuits, VP vs VNP), algebraic geometry (degree bounds).

**Lineage**: Conceptual extension of the linear part invertibility theorem to the circuit model.

**Ambition**: Grand challenge — opens entirely new terrain connecting algebra to complexity.

---

## Direction 5: Sparse Support and Treewidth Bounds

**Conjecture**: Every cubic homogeneous Keller map F = Id + H over a characteristic-zero field, where the support graph of JH has treewidth at most 2, is polynomially invertible.

**The key insight is** that sparsity in the Jacobian of the nonlinear part constrains the combinatorial structure of the map. Low treewidth means the variables interact through a tree-like pattern, and tree-like systems are typically solvable by elimination.

**Why now?** Graph-theoretic methods in algebra are a hot topic (treewidth-bounded inference, sparse polynomial system solving), and our framework's clean definition of cubic homogeneous perturbations provides the right interface.

**Test**: For dimensions 2-5, enumerate all cubic homogeneous maps with sparse Jacobian (treewidth ≤ 2), compute Jacobian determinant symbolically, check Keller condition, attempt inverse. A counterexample disproves the conjecture. See demo.py for implementation.

**Impact**: Would identify a tractable subclass of the Jacobian Conjecture amenable to combinatorial methods, potentially leading to the first non-trivial positive results beyond dimension 2.

**Catalog References**: `Algebra/Jacobian/KellerReduction.lean` (IsCubicHomogeneousPerturbation, jacobianMat_H_entry_homog).

**Proof Strategy**: For treewidth ≤ 1 (forests): the Jacobian JH has a tree structure, so Gaussian elimination with no fill-in shows nilpotency directly. For treewidth 2: use tree decomposition to reduce to local 3×3 problems. Use strictUpperTriang_nilpotent as the base case.

**Domain Bridges**: Graph theory (treewidth), sparse linear algebra, parameterized complexity.

**Lineage**: Builds on strictly upper triangular nilpotency (proved) and cubic homogeneous properties.

**Ambition**: Solid extension with clear computational path to results.
