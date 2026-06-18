# Future Directions: Chromatic Polynomial Infrastructure

This document outlines five concrete next-step research directions opened by our formalization of chromatic polynomials, each with exact theorem statements, proof strategies, and cross-domain impact.

---

## 1. Acyclic Orientation Reciprocity

### Theorem Statement
```lean
theorem SimpleGraph.acyclic_orientations_eq_abs_eval_neg_one
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) [DecidableRel G.Adj] :
  Fintype.card (G.AcyclicOrientation) =
    Int.natAbs (Polynomial.eval (-1 : ℤ) G.chromaticPolynomial)
```

### Why It Would Be a Breakthrough
Stanley's reciprocity theorem (1973) reveals that the chromatic polynomial evaluated at negative integers has combinatorial meaning: |χ_G(−1)| counts the number of acyclic orientations of G. This connects graph coloring to directed graph theory, topological combinatorics (via hyperplane arrangements), and algebraic topology (via the Möbius function on face lattices).

### Proof Strategy
1. Define `AcyclicOrientation G` as an orientation of edges of G with no directed cycles.
2. Prove the deletion-contraction recursion for acyclic orientations: a(G) = a(G\e) + a(G/e).
3. Show this recursion matches the recursion for |χ_G(−1)| via deletion-contraction of the chromatic polynomial.
4. Verify base case: edgeless graph has one acyclic orientation, and |χ_{E_n}(−1)| = 1.

### Required Infrastructure
- Definition of graph orientations and acyclicity
- Deletion-contraction for orientation counts (proved separately)
- Edge contraction operation for simple graphs

### Cross-Domain Impact
- **Combinatorics**: Connections to Tutte polynomial and the theory of hyperplane arrangements
- **Optimization**: Acyclic orientations arise in scheduling, Bayesian networks, and topological sorting
- **Algebraic topology**: Links to the broken circuit complex and Orlik-Solomon algebra

---

## 2. Chromatic–Tutte Specialization

### Theorem Statement
```lean
noncomputable def SimpleGraph.tuttePolynomial
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) [DecidableRel G.Adj] : Polynomial (Polynomial ℤ)

theorem SimpleGraph.chromaticPolynomial_eq_tutte_specialization
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) [DecidableRel G.Adj] :
  G.chromaticPolynomial =
    (-1) ^ (Fintype.card V - G.numComponents) *
    Polynomial.C (Polynomial.X - 1) ^ G.numComponents *
    (G.tuttePolynomial.eval₂ (Polynomial.C) (1 - Polynomial.X)).eval₂
      (Polynomial.C) 0
```

### Why It Would Be a Breakthrough
The Tutte polynomial T_G(x,y) is the universal deletion-contraction invariant for graphs. Proving that χ_G(q) = (−1)^{|V|−k(G)} q^{k(G)} T_G(1−q, 0) would establish the chromatic polynomial as a specialization of this universal object, immediately transferring all structural results about the Tutte polynomial to chromatic polynomials.

### Proof Strategy
1. Define the Tutte polynomial via the rank generating function over subsets of edges.
2. Prove the Whitney rank formula for both T_G and χ_G in terms of the same sum over edge subsets.
3. Verify the specialization algebraically by matching summands term-by-term.

### Required Infrastructure
- Definition of graphic matroid rank function
- Tutte polynomial definition and deletion-contraction
- Multivariate polynomial evaluation lemmas

### Cross-Domain Impact
- **Matroid theory**: Opens formalization of matroid invariants
- **Knot theory**: Tutte polynomial specializes to Jones polynomial for alternating links
- **Statistical physics**: Tutte polynomial encodes the full Potts model partition function

---

## 3. Real-Rootedness and Log-Concavity for Special Graph Classes

### Theorem Statement
```lean
theorem SimpleGraph.chromaticPolynomial_realRooted_chordal
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) [DecidableRel G.Adj]
  (hG : G.IsChordal) :
  ∀ z : ℂ, Polynomial.aeval z G.chromaticPolynomial = 0 → z.im = 0

theorem SimpleGraph.chromaticPolynomial_logConcave_coefficients
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) [DecidableRel G.Adj]
  (hG : G.IsChordal) :
  ∀ i, 1 ≤ i → i + 1 ≤ Fintype.card V →
    (G.chromaticPolynomial.coeff i) ^ 2 ≥
    G.chromaticPolynomial.coeff (i-1) * G.chromaticPolynomial.coeff (i+1)
```

### Why It Would Be a Breakthrough
The conjecture that chromatic polynomials of claw-free graphs are real-rooted has driven major developments in algebraic combinatorics. Proving real-rootedness for chordal graphs (where it's known to hold) would establish formalization infrastructure for coefficient inequalities and serve as a testbed for the claw-free case.

### Proof Strategy
1. Define chordal graphs via perfect elimination orderings.
2. Show that chordal graphs decompose as clique trees.
3. Prove that chromatic polynomial of chordal graph equals product of factors (x−k_i) from the elimination ordering.
4. Conclude real-rootedness from the product structure.

### Required Infrastructure
- Definition of chordal graphs and perfect elimination orderings
- Clique tree decomposition
- Real-rootedness implies log-concavity theorem (Newton's inequality)
- Complex polynomial evaluation

### Cross-Domain Impact
- **Algebraic combinatorics**: Log-concavity is central to the theory of matroids (Adiprasito-Huh-Katz)
- **Probability**: Log-concave sequences arise in random sampling and Markov chain mixing
- **Optimization**: Connections to convex optimization via log-concave distributions

---

## 4. Potts Partition Function Formalization

### Theorem Statement
```lean
noncomputable def PottsPartitionFunction
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) [DecidableRel G.Adj]
  (q : ℕ) (v : ℤ) : ℤ :=
  ∑ σ : V → Fin q,
    ∏ e in G.edgeFinset,
      (1 + v * if (σ e.out.1 = σ e.out.2) then 1 else 0)

theorem potts_specialization_chromatic
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) [DecidableRel G.Adj] (q : ℕ) :
  PottsPartitionFunction G q (-1) =
    Polynomial.eval (q : ℤ) G.chromaticPolynomial
```

### Why It Would Be a Breakthrough
The Potts model is fundamental in statistical mechanics. Showing that the chromatic polynomial is exactly the zero-temperature antiferromagnetic Potts partition function creates a certified bridge between graph theory and physics, enabling transfer of results in both directions.

### Proof Strategy
1. Define the Potts partition function with Boltzmann weights.
2. Expand the product using the Fortuin-Kasteleyn random cluster representation.
3. Match term-by-term with the Whitney rank formula for the chromatic polynomial.
4. Verify the specialization at v = −1.

### Required Infrastructure
- Potts model definitions (spin configurations, Boltzmann weights)
- Fortuin-Kasteleyn cluster expansion
- Product-to-sum conversion over edge subsets

### Cross-Domain Impact
- **Statistical physics**: Certified results about phase transitions
- **Probability theory**: Random cluster model connections
- **Computational physics**: Verified partition function evaluation

---

## 5. Certified Exact Coloring Counter

### Theorem Statement
```lean
def chromaticPolyCompute :
    (n : ℕ) → (edges : List (Fin n × Fin n)) → Polynomial ℤ

theorem chromaticPolyCompute_correct
  (n : ℕ) (edges : List (Fin n × Fin n)) :
  chromaticPolyCompute n edges =
    (graphFromEdgeList n edges).chromaticPolynomial

-- Extracted executable
#eval chromaticPolyCompute 5 [(0,1), (1,2), (2,3), (3,4), (4,0)]
```

### Why It Would Be a Breakthrough
Extracting a verified executable from the deletion-contraction recursion would produce the first certified exact coloring counter: a program whose output is guaranteed correct by its mathematical proof. This would be a landmark result in verified algorithms, applicable to graph isomorphism testing, SAT solving, and combinatorial optimization.

### Proof Strategy
1. Define a computable version of deletion-contraction using decidable graph operations.
2. Prove it agrees with the noncomputable chromaticPolynomial.
3. Use Lean's code extraction to produce executable code.
4. Benchmark on standard graph families.

### Required Infrastructure
- Decidable graph contraction (replacing Quotient with explicit vertex relabeling)
- Well-founded recursion on edge count
- Polynomial arithmetic in computable form
- Performance optimization (memoization, graph isomorphism pruning)

### Cross-Domain Impact
- **Verified algorithms**: First certified graph polynomial evaluator
- **Computational complexity**: Connections to #P-hardness and approximation algorithms
- **Software verification**: Template for extracting verified combinatorial algorithms

---

## Research Team Structure

Each direction should be pursued by a team with:
1. **Formalization lead**: Responsible for Lean 4 development and Mathlib integration
2. **Mathematical advisor**: Ensures proof strategies are sound and identifies shortcuts
3. **Cross-domain specialist**: Connects results to applications in physics, CS, or other fields

**Iteration cycle**: 
- Week 1-2: Define core concepts and state main theorem
- Week 3-4: Prove helper lemmas and build infrastructure
- Week 5-6: Attempt main theorem proof with subagent assistance
- Week 7-8: Polish, document, and prepare for Mathlib PR

**Priority ordering**: Direction 1 (acyclic orientations) and Direction 5 (certified counter) are most immediately achievable given the current infrastructure. Direction 2 (Tutte specialization) would have the highest mathematical impact. Directions 3 and 4 are longer-term but would open entirely new research programs.
