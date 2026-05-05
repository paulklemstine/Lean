# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-05 04:01*

## Next Steps

### 1. Elimination for Injective Variable Maps (Hilbert Basis Analogue)

The current `elimination_fg` theorem handles surjective variable maps `ι : τ → σ`. The harder and more geometrically relevant case is **injective** `ι` (embedding fewer variables into more), corresponding to elimination of variables from polynomial congruences.

This requires a Noetherian-type argument specific to idempotent semirings. In classical algebra, this follows from Hilbert's basis theorem. The idempotent analogue should exploit the lattice structure of idempotent semiring congruences.

**Conjecture**: For `ι : τ ↪ σ` an embedding of finite types and `S` a commutative idempotent semiring, `elimination_fg` holds without the surjectivity hypothesis.

### 2. Gröbner-Style Canonical Bases for Idempotent Congruences

Define a term ordering on `MvPolynomial σ S` for idempotent `S` and develop:
- Leading term extraction for congruence pairs
- S-polynomial analogues for congruence generators
- A Buchberger-style algorithm producing canonical generating sets
- Proof that the algorithm terminates (requires the Noetherian property)

### 3. Tropical Nullstellensatz via Finitely Presented Congruences

Using the elimination infrastructure:
- Define the tropical variety of a finitely presented congruence
- Prove that the variety determines the congruence (up to radical)
- Establish a correspondence between coordinate congruences and tropical algebraic sets
- Connect to existing formalized tropical geometry

### 4. Certified Congruence Decision Procedures

Strengthen the decidability result:
- Define explicit bounded-depth derivation certificates as inductive types
- Prove decidability for bounded certificates via finite search
- Establish completeness bounds: given generators of total degree ≤ d, prove that derivation depth is bounded by a computable function of d and the number of variables
- Implement a verified decision procedure for congruence membership

### 5. Functorial Theory: Pullback/Pushforward for Congruences

Generalize `eliminateCongruence` to a functorial framework:
- Define pushforward of congruences along arbitrary semiring homomorphisms
- Prove base-change properties for congruence generation
- Establish adjunction between pullback and pushforward
- Apply to morphisms of tropical polynomial semirings

### 6. Elimination Complexity Bounds

Bound the size of elimination generators:
- Given R with |R| = n generators of degree ≤ d in k variables
- Bound |eliminationGenerators| in terms of n, d, k
- Compare with classical doubly-exponential bounds for ideal elimination
- Explore whether idempotency gives better bounds

### 7. Applications to Neural Network Verification

For max-plus neural networks (ReLU networks viewed over the tropical semiring):
- Model network equivalence as congruence membership
- Use elimination to project out hidden-layer variables
- Derive certified bounds on network behavior from congruence certificates

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