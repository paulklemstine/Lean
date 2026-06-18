# Future Directions

## 1. Extending Closure/Galois Infrastructure to Submodules and Subalgebras

**Current state**: The closure operator framework is instantiated for intermediate fields via the Galois correspondence.

**Next step**: Show that the double-commutant construction on subalgebras (the bicommutant `A ↦ A'' = Comm(Comm(A))`) is a closure operator on the lattice of subalgebras of a ring. Prove that the closed elements (von Neumann algebras in the operator algebra case) form a complete lattice.

**Concrete target**:
```lean
def bicommutantClosure [Ring R] : ClosureOperator (Subalgebra R R) :=
  mkClosureOperator (fun A => A.centralizer.centralizer) sorry sorry sorry
```

This would connect abstract algebra to operator theory and provide a reusable interface for von Neumann algebra formalization.

## 2. Categorifying the Order Isomorphism

**Current state**: The Galois correspondence is packaged as an `OrderIso` between `IntermediateField F E` and `(Subgroup Gal(E/F))ᵒᵈ`.

**Next step**: Lift this to a *contravariant equivalence of categories*, where the morphisms are field embeddings (on one side) and group homomorphisms (on the other). This requires:
- Defining the category of intermediate fields with field embeddings as morphisms.
- Defining the opposite category of subgroups with group inclusions.
- Proving the Galois correspondence is a functor that is an equivalence.

**Impact**: This would unlock functorial machinery (natural transformations, adjunctions, limits/colimits) for Galois theory, enabling proofs by diagram chasing and abstract nonsense.

## 3. Transporting Combinatorial Statistics Along Algebraic Symmetries

**Current state**: `InvariantStatistic` defines functions constant on group orbits, with pullback/pushforward along equivariant maps.

**Next step**: Apply this to additive combinatorial quantities. Specifically:
- Define the autocorrelation function of a set $S ⊂ \mathbb{Z}$ as an invariant statistic under translation.
- Prove that the pair correlation function (Montgomery-type) is an invariant statistic under the Galois group acting on roots of unity.
- Show that the Sidon defect is preserved under equivariant bijections between difference sets.

**Concrete target**:
```lean
theorem autocorrelation_translation_invariant (S : Finset ℤ) (t : ℤ) :
    autocorrelation S = autocorrelation (S.map (Equiv.addRight t).toEmbedding)
```

This opens a bridge between additive combinatorics and algebraic symmetry methods.

## 4. Extracting Canonical Algorithms from Closure Normal Forms

**Current state**: Closure operators produce closed elements (normal forms) from arbitrary inputs.

**Next step**: Formalize the *algorithmic content* of closure operators:
- Given a finitely generated closure operator on a finite lattice, compute the closed elements by iterated application.
- Prove termination and correctness of the closure computation algorithm.
- Extract verified Lean code that computes canonical representatives of equivalence classes.

**Application**: In database theory, Armstrong's axioms define a closure operator on attribute sets. Computing functional dependency closures is equivalent to applying this closure operator. A verified implementation would provide certified database normalization.

**Concrete target**:
```lean
def closureCompute [Fintype α] [DecidableEq α] [PartialOrder α] 
    (c : ClosureOperator α) (a : α) : α :=
  -- compute c(a) by iteration, prove it terminates in ≤ |α| steps
```

## 5. Building a Unified Algebraic Fixed-Point Correspondence Library

**Current state**: We have demonstrated the pattern for one instance (Galois theory).

**Next step**: Create a systematic library of algebraic correspondences that are instances of closure operators:

| Construction | Ambient Lattice | Closure Operator | Closed Elements |
|-------------|----------------|-----------------|-----------------|
| Galois correspondence | Intermediate fields | fixedField ∘ fixingSubgroup | All (for Galois) |
| Topological closure | Subsets | closure in topology | Closed sets |
| Algebraic closure | Field extensions | algebraic closure | Algebraically closed |
| Radical of an ideal | Ideals | radical | Radical ideals |
| Normal closure | Subgroups | normal closure | Normal subgroups |
| Bicommutant | Subalgebras | double commutant | Von Neumann algebras |
| Convex hull | Subsets of vector space | convex hull | Convex sets |

For each row, instantiate `mkClosureOperator` and derive the complete lattice of closed elements. This would create a unified formalization pattern that dramatically reduces redundant effort.

**Concrete first targets**:
```lean
-- Topological closure
def topologicalClosureOp [TopologicalSpace α] : ClosureOperator (Set α) := sorry

-- Normal closure of subgroups  
def normalClosureOp [Group G] : ClosureOperator (Subgroup G) := sorry

-- Radical of ideals
def radicalClosureOp [CommRing R] : ClosureOperator (Ideal R) := sorry
```

Each instantiation would immediately yield a complete lattice theorem for the corresponding closed elements, with no additional proof effort beyond verifying the three closure properties.

---

## Priority Ranking

1. **Unified Fixed-Point Library** (Direction 5) — highest immediate impact, broadest applicability
2. **Submodule/Subalgebra Extension** (Direction 1) — concrete and achievable
3. **Combinatorial Statistics Transport** (Direction 3) — bridges two active research areas
4. **Algorithmic Extraction** (Direction 4) — practical verified software
5. **Categorification** (Direction 2) — deepest mathematically, but most infrastructure-heavy
