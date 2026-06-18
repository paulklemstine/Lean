# Future Directions

## 1. Complete the Rank-2 Coincidence Theorem

**Status**: The rank-2 Dressian ↔ four-point condition is proved. The full coincidence Dr(2,n) = Trop(Gr(2,n)) requires proving that every four-point metric is tropically realizable.

**Strategy**: Formalize the classical result that every four-point metric is a tree metric (Buneman's theorem), then show tree metrics are realizable over the field of formal Puiseux series ℝ{{t}}. This requires:
- Defining weighted trees and path metrics
- Proving the four-point condition characterizes tree metrics
- Constructing explicit realizations via Puiseux series coordinates

**Impact**: Establishes the complete tropical-phylogenetic correspondence in rank 2, providing a formal foundation for tree reconstruction algorithms in computational biology.

## 2. Formalize Valuated Matroid Theory

**Status**: We use an ad-hoc definition of tropical Plücker relations. The full theory should use Dress-Wenzel valuated matroids.

**Strategy**: Define valuated matroids as functions w : {r-subsets} → ℝ ∪ {∞} satisfying the tropical Plücker relations (equivalently, the "exchange axiom" for valuated matroids). Prove:
- Every matroid with trivial valuation is a valuated matroid
- The Dressian parametrizes valuated matroids
- The tropical Grassmannian parametrizes realizable valuated matroids
- The support (set of finite-weight subsets) of a valuated matroid is a matroid

**Impact**: Creates a reusable library for tropical combinatorics, connecting matroid theory, tropical geometry, and algebraic combinatorics.

## 3. Build a Certified Non-Realizability Library

**Status**: The Fano matroid is proved non-representable over ℝ. Other non-representable matroids exist.

**Strategy**: Formalize additional non-representability results:
- The non-Fano matroid (dual of Fano): representable only over characteristic ≠ 2
- The Vámos matroid: not representable over ANY field
- MacLane's matroid, Pappus matroid, and other classical examples
- Each provides a point in the Dressian minus the tropical Grassmannian

**Impact**: A certified library of non-realizability obstructions, useful for:
- Algorithmic matroid theory
- Combinatorial optimization (matroid intersection, partition)
- Tropical moduli theory (understanding boundary strata)

## 4. Define Tropical Grassmannians via Initial Ideals

**Status**: Our InTropicalGrassmannian3 uses a simplified "initial matroid" characterization. The full definition uses tropical varieties and initial ideals.

**Strategy**: Formalize:
- Non-archimedean valued fields (Mathlib has some infrastructure)
- Tropicalization of polynomial ideals
- The Plücker ideal and its tropicalization
- Prove that Trop(Gr(r,n)) = tropicalization of the Plücker ideal

**Cross-domain connections**:
- Initial ideal theory connects to Gröbner bases and computational algebra
- Tropical varieties connect to Newton polytopes and toric geometry
- The secondary fan structure of the Dressian connects to regular subdivisions

## 5. Tropical Moduli of Curves and Phylogenetics

**Status**: The rank-2 result connects Dr(2,n) to tree metrics / phylogenetic trees.

**Strategy**: Formalize the identification:
- Trop(Gr(2,n)) ≅ M̄₀,ₙᵗʳᵒᵖ (tropical moduli of genus-0 curves with n marks)
- This is the space of metric trees with n labeled leaves
- The combinatorial types (tree topologies) correspond to maximal cones
- The Dressian fan structure encodes the phylogenetic tree space

**Applications**:
- Certified algorithms for phylogenetic tree reconstruction
- Tropical approaches to the moduli space M̄₀,ₙ
- Connections to cluster algebras and positive geometries

**Impact**: Bridges tropical algebraic geometry with computational biology, establishing formal foundations for statistical phylogenetics and geometric approaches to evolutionary inference.

---

Each direction above opens a new chapter in the formal verification of tropical geometry. The current work establishes the foundational language — PluckerVec, InDressian, InTropicalGrassmannian, and the separation theorem — on which this entire program can be built.
