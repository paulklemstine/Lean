# Future Directions: Jacobian Conjecture Formalization

## Synthesis

The formally verified results in this research cycle establish the algebraic foundations of the Jacobian Conjecture: the nilpotency theorem (`isNilpotent_of_det_one_add_smul`), the Drużkowski structure theory, and the abstract Jacobian–Dixmier bridge. These results connect three mathematical domains — commutative algebra (polynomial automorphisms), linear algebra (nilpotent matrices), and noncommutative algebra (Weyl algebras). The five directions below build on these foundations, pushing toward: (1) the full Drużkowski reduction, (2) the quadratic JC in all dimensions, (3) graph-theoretic characterization of Keller maps, (4) computational rank bounds, and (5) the Weyl algebra formalization needed to complete the Dixmier bridge.

---

## Direction 1: Complete Drużkowski Reduction

**Conjecture:** The Jacobian Conjecture for all polynomial maps of any degree is equivalent to the Jacobian Conjecture for cubic linear (Drużkowski) maps. Formally:

```
∀ K [Field K] [CharZero K], (∀ n, ∀ Φ : CubicLinearMap K n, Keller Φ → Auto Φ)
  ↔ (∀ n d, ∀ F : PolyMap K n, deg F ≤ d → Keller F → Auto F)
```

**Test:** Formalize the degree reduction step (Bass-Connell-Wright): given a degree-d Keller map F in dimension n, construct an explicit cubic homogeneous Keller map F' in dimension N ≥ n such that invertibility of F' implies invertibility of F. Verify that N and the construction are computable.

**Impact:** This would be the first complete formal verification of the Bass-Connell-Wright/Yagzhev reduction, reducing the entire Jacobian Conjecture to a single family of maps. It would make all subsequent JC research automatically applicable to all polynomial degrees.

**Catalog References:**
- `Catalog/Algebra/Jacobian/DruzkowskiTheory.lean` — `druzkowskiMap_isCubicHomogeneous`
- `Catalog/Speculative/AutoResearch/Algebra/Jacobian/CubicReduction.lean` — `jacobian_conjecture_of_cubic_homogeneous` (sorry'd)

**Proof Strategy:** Decompose into three lemmas: (1) stable equivalence preserves Keller and automorphism properties, (2) homogenization reduces arbitrary degree to homogeneous, (3) degree reduction from d to 3 by introducing auxiliary variables. Each step is well-documented in van den Essen's textbook.

**Domain Bridges:** Algebraic geometry (blowups) ↔ Linear algebra (matrix embeddings) ↔ Commutative algebra (polynomial rings)

**Lineage:** Extends `druzkowskiMap_isCubicHomogeneous` from the current cycle.

**Ambition:** Grand challenge — completing this would be a landmark in formal mathematics.

---

## Direction 2: Quadratic JC in All Dimensions

**Conjecture:** Every quadratic polynomial map F = Id + H (with H homogeneous of degree 2) satisfying det(JF) = 1 is a polynomial automorphism, in any dimension n.

**Test:** For n = 3, construct an explicit quadratic Keller map and verify that the inverse formula G = Id - H + H∘H - ... terminates (because JH is nilpotent with JH^n = 0). Verify computationally for random 3D quadratic Keller maps.

**Impact:** This would be the first complete proof of the Jacobian Conjecture for any fixed degree class in all dimensions. The dim 2 case is already in the Catalog; generalizing to all dimensions is the natural next step.

**Catalog References:**
- `Catalog/Algebra/Jacobian/Dim2.lean` — `jacobian_conjecture_dim2_quadratic_homogeneous`
- `Catalog/Algebra/Jacobian/DruzkowskiTheory.lean` — `isNilpotent_of_det_one_add_smul`, `jacobianMatrix_id_plus_H`

**Proof Strategy:** 
1. For F = Id + H with H homogeneous degree 2, JF = I + JH with JH having degree-1 entries.
2. det(JF) = 1 implies det(I + JH(x)) = 1 for all x, which by `isNilpotent_of_det_one_add_smul` applied to specializations forces JH(x) nilpotent for each x.
3. Nilpotency of JH(x) for all x implies the formal Neumann series G = Id - H + H∘H - ... terminates, giving a polynomial inverse.
4. The key lemma: `bind₁ (Id - H) (Id + H) = Id` when JH is universally nilpotent.

**Domain Bridges:** Linear algebra (nilpotency) ↔ Formal power series (Neumann series) ↔ Algebraic geometry (polynomial automorphisms)

**Lineage:** Extends `jacobian_conjecture_dim2_quadratic_homogeneous` and uses `isNilpotent_of_det_one_add_smul`.

**Ambition:** Solid extension — generalizes existing dim 2 result.

---

## Direction 3: Graph-Theoretic Keller Characterization

**Conjecture:** A Drużkowski map Φ(x) = x + (Ax)^[3] is Keller if and only if the Hessian graph of A (with edge i→j when A_{ij} ≠ 0) satisfies a specific combinatorial condition related to cycle structure and edge density.

**Test:** For dimensions 2-4, enumerate all {0,1}-matrices, compute which define Keller Drużkowski maps, and classify the resulting Hessian graphs. Check whether the Keller graphs form a recognizable combinatorial class (e.g., bounded treewidth, bounded pathwidth, planar, etc.).

**Impact:** A graph-theoretic characterization would connect the Jacobian Conjecture to extremal combinatorics (Turán theory, Ramsey theory) and potentially unlock new proof techniques from structural graph theory.

**Catalog References:**
- `Catalog/Algebra/Jacobian/DruzkowskiTheory.lean` — `hessianNilpotencyIndex`, Hessian graph concept
- `Catalog/Algebra/Jacobian/StrictUpperTriangular.lean` — acyclic ↔ triangular

**Proof Strategy:** Start with the observation that acyclic Hessian graphs always give Keller maps (triangular case). Then characterize which cycles are "allowed" — specifically, which graph structures are compatible with the nilpotency condition on A·diag(v²).

**Domain Bridges:** Graph theory (directed graphs, DAGs) ↔ Linear algebra (nilpotent matrices) ↔ Commutative algebra (Keller condition)

**Lineage:** Novel direction building on the Hessian nilpotency index introduced in this cycle.

**Ambition:** Grand challenge — would open an entirely new approach to the Jacobian Conjecture.

---

## Direction 4: Rank Conjecture Resolution

**Conjecture:** For Drużkowski Keller maps in dimension n ≤ 5, the matrix A has rank strictly less than n. (Stated as `cubic_linear_keller_rank_conjecture` in the formalization.)

**Test:** Extend the exhaustive enumeration to dimension 4 with entries in {-1, 0, 1}. For dimension 5, use sparse matrix sampling. If the conjecture holds, attempt to prove it for dimension 2 first (should be feasible: a 2×2 Keller map with rank 2 leads to A being invertible, but then the cubic term is "too rich" to maintain det = 1).

**Impact:** If true, this provides a strong new constraint on Keller maps that could lead to a dimension-by-dimension proof strategy. If false, the counterexample would be intrinsically interesting.

**Catalog References:**
- `Catalog/Algebra/Jacobian/DruzkowskiTheory.lean` — `cubic_linear_keller_rank_conjecture`
- `Catalog/Algebra/Jacobian/NilpotenceTheory.lean` — nilpotency from det constraints

**Proof Strategy:** For n = 2: if rank(A) = 2, then A is invertible. Show that det(I + 3A·diag(v²)) cannot be identically 1 when A is 2×2 invertible, using explicit expansion and the fact that the cubic terms cannot cancel. For general n, use the connection between rank deficiency and the structure of the nilpotent cone.

**Domain Bridges:** Linear algebra (matrix rank) ↔ Algebraic geometry (nilpotent varieties) ↔ Number theory (rational point counting for computational tests)

**Lineage:** Builds on `isNilpotent_of_det_one_add_smul` and the computational experiments.

**Ambition:** Solid extension — testable and provable for small dimensions.

---

## Direction 5: Weyl Algebra Formalization and Dixmier Bridge Completion

**Conjecture:** The Dixmier Conjecture (every endomorphism of the Weyl algebra A_n(K) is an automorphism) is equivalent to the Jacobian Conjecture. Formally complete the bridge JC ⟺ DC.

**Test:** Define the Weyl algebra A_1(K) = K⟨x, ∂⟩/(∂x - x∂ = 1) in Lean, verify basic properties (simplicity, GK-dimension 2, the commutation relation), and prove that endomorphisms of A_1 induce Keller maps on gr(A_1) ≅ K[x,ξ].

**Impact:** This would be the first formal verification of the Jacobian–Dixmier equivalence, connecting commutative algebra to quantum mechanics (the Weyl algebra models canonical commutation relations). It would also create reusable Weyl algebra infrastructure for future Mathlib contributions.

**Catalog References:**
- `Catalog/Algebra/Jacobian/DruzkowskiTheory.lean` — `jacobian_implies_dixmier_abstract`
- `Catalog/Speculative/AutoResearch/Algebra/Jacobian/DixmierBridge.lean` — `dixmier_of_jacobian` (placeholder)

**Proof Strategy:** 
1. Define the Weyl algebra as a quotient of the free algebra.
2. Establish the filtration by order and the isomorphism gr(A_n) ≅ K[x₁,...,xₙ,ξ₁,...,ξₙ].
3. Show that endomorphisms of A_n induce polynomial endomorphisms of gr(A_n).
4. Prove the Keller condition on the induced map from the commutation relations.
5. Apply JC to get invertibility, then lift back through the filtration.

**Domain Bridges:** Noncommutative algebra (Weyl algebra) ↔ Commutative algebra (polynomial maps) ↔ Differential geometry (symbol calculus) ↔ Quantum mechanics (CCR)

**Lineage:** Completes `jacobian_implies_dixmier_abstract` from the current cycle.

**Ambition:** Grand challenge — requires building new Mathlib infrastructure for noncommutative algebra.
