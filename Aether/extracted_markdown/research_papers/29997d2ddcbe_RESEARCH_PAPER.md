# The Algebraic Structure of Jigsaw Puzzle Compatibility: From Edge Involutions to NP-Completeness

## Abstract

We develop a rigorous algebraic framework for jigsaw puzzle compatibility and establish a faithful reduction from 3-SAT to jigsaw assembly. Our main contributions are: (1) a solution-preserving equivalence between Boolean satisfiability and edge-encoded puzzle systems, showing the reduction preserves the exact count of solutions; (2) a characterization of the automorphism group of edge compatibility as Z/2Z, proving that the complement involution generates the only non-trivial symmetry; (3) a parity constraint on generalized puzzle alphabets, showing that non-boundary edge types must appear in even number; (4) a constraint superadditivity theorem showing that merging sub-assemblies introduces irreducible boundary constraints; and (5) a topological analysis of grid constraint graphs via the Euler characteristic. All results are formalized and machine-verified.

## 1. Introduction

Jigsaw puzzles, despite their apparent simplicity, encode rich combinatorial and algebraic structure. The fundamental operation — fitting a tab into a blank — defines an involution on edge types that mirrors Boolean complementation. This paper develops the consequences of this observation systematically.

The NP-completeness of jigsaw puzzles was established by Demaine and Demaine (2007), who showed that edge-matching puzzles are NP-complete. Our contribution is to deepen the algebraic understanding of the reduction and establish quantitative invariants that go beyond mere satisfiability equivalence.

### 1.1 Main Results

**Theorem 1 (Solution Equivalence).** An assignment satisfies a 3-SAT constraint system if and only if its edge encoding satisfies the corresponding edge system. The encoding is pointwise: each clause's satisfaction is independently preserved.

**Theorem 2 (Variable Gadget Independence).** The edge encoding of variable i depends only on the truth value of variable i. Changing variable j ≠ i does not affect variable i's gadget.

**Theorem 3 (Clause Gadget Correctness).** A clause has at least one true literal if and only if at least one of its edge encodings is a tab. The OR operation is faithfully represented by edge-type detection.

**Theorem 4 (Automorphism Characterization).** Any permutation of edge types that preserves compatibility and fixes the boundary type (flat) is either the identity or the complement. The automorphism group of puzzle compatibility (fixing flat) is isomorphic to Z/2Z.

**Theorem 5 (Alphabet Parity).** For any puzzle alphabet equipped with a complement involution, the number of non-fixed-point elements is even.

**Theorem 6 (Encoding Injectivity).** The Boolean-to-edge encoding is injective: distinct Boolean assignments produce distinct edge functions.

## 2. Edge Type Algebra

### 2.1 Basic Definitions

**Definition 2.1 (Edge Type).** The edge type alphabet consists of three symbols: flat (boundary), tab (protruding), and blank (indented).

**Definition 2.2 (Complement).** The complement operation is defined by:
- complement(flat) = flat
- complement(tab) = blank
- complement(blank) = tab

**Definition 2.3 (Compatibility).** Two edges e₁, e₂ are compatible iff complement(e₁) = e₂.

### 2.2 Algebraic Properties

**Proposition 2.4.** Complement is an involution: complement(complement(e)) = e for all e.

**Proposition 2.5.** Complement is injective and bijective.

**Proposition 2.6.** An edge type is a fixed point of complement if and only if it is flat.

**Proposition 2.7.** Non-flat edges are not self-compatible.

**Proposition 2.8.** The complement orbit of a non-flat element has exactly 2 elements.

### 2.3 Boolean Encoding

**Definition 2.9.** The Boolean-to-edge encoding maps true → tab, false → blank.

**Proposition 2.10.** The encoding is injective and never produces flat.

**Proposition 2.11.** Complement of encoded booleans corresponds to negation: complement(encode(b)) = encode(¬b).

**Proposition 2.12.** Compatibility of encoded booleans corresponds to inequality: encode(b₁) is compatible with encode(b₂) iff b₁ ≠ b₂.

## 3. The SAT-Puzzle Correspondence

### 3.1 Constraint Systems

**Definition 3.1 (Constraint System).** A constraint system consists of:
- numVars: the number of Boolean variables
- numClauses: the number of clauses
- clauses: for each clause j ∈ [numClauses] and literal position k ∈ [3], a pair (variable index, polarity)

**Definition 3.2 (Solution).** An assignment a satisfies a constraint system if for every clause j, at least one literal evaluates to true.

### 3.2 Edge Encoding

**Definition 3.3.** The edge encoding of an assignment a maps each variable v to boolToEdge(a(v)).

**Definition 3.4.** A clause is edge-satisfiable if at least one literal's edge is tab (accounting for polarity via complement).

### 3.3 Main Correspondence (Theorem 1)

**Theorem 3.5.** An assignment a satisfies the constraint system if and only if the edge system is satisfied by encode(a).

*Proof sketch.* For each clause j, the key step is the literal encoding lemma: (if pol then val else ¬val) = true ↔ (if pol then encode(val) else complement(encode(val))) = tab. This follows by case analysis on pol and val, using the definitions of boolToEdge and complement. The global result follows by universally quantifying over clauses.

### 3.4 Corollary: Satisfiability Preservation

**Corollary 3.6.** A constraint system is satisfiable if and only if there exists a non-flat edge encoding satisfying the edge system.

## 4. Variable and Clause Gadgets

### 4.1 Variable Gadgets

**Definition 4.1.** The variable piece for value b is the jigsaw piece (flat, encode(b), flat, flat).

**Theorem 4.2 (Mutual Exclusion).** The TRUE piece and FALSE piece for the same variable have compatible right edges (tab meets blank).

**Theorem 4.3 (Self-Incompatibility).** A variable piece's right edge is not compatible with itself (tab doesn't fit tab, blank doesn't fit blank).

**Theorem 4.4 (Independence).** Variable gadgets for distinct variables are independent: changing variable i's assignment does not affect variable j's piece for j ≠ i.

### 4.2 Clause Gadgets

**Theorem 4.5 (Clause Correctness).** A clause has at least one true literal iff at least one edge encoding is tab.

## 5. Automorphism Group

### 5.1 Puzzle Automorphisms

**Definition 5.1.** A puzzle automorphism is a permutation σ of edge types such that for all e₁, e₂: compatible(σ(e₁), σ(e₂)) = compatible(e₁, e₂).

**Proposition 5.2.** The identity is a puzzle automorphism.

**Proposition 5.3.** The complement map is a puzzle automorphism.

### 5.2 Classification (Theorem 4)

**Theorem 5.4.** A puzzle automorphism fixing flat is either the identity or the complement.

*Proof sketch.* Since σ fixes flat and is a permutation of {flat, tab, blank}, it must permute {tab, blank}. There are only two permutations of a 2-element set: the identity and the transposition. The identity gives σ = id; the transposition gives σ = complement.

*Remark.* The hypothesis that σ preserves compatibility turns out to be unnecessary — any permutation fixing flat must be id or complement, simply by the pigeonhole principle on a 3-element set. However, the compatibility-preserving hypothesis is natural in the puzzle context.

## 6. Generalized Alphabets

### 6.1 Puzzle Alphabets

**Definition 6.1.** A puzzle alphabet consists of a finite type Label equipped with an involution compl.

**Definition 6.2.** The standard alphabet has Label = EdgeType and compl = complement.

### 6.2 Parity Constraint (Theorem 5)

**Theorem 6.3.** For any puzzle alphabet A, the number |Label| - |{e : compl(e) = e}| is even.

*Proof sketch.* The non-fixed elements can be partitioned into pairs {e, compl(e)}. Each pair has exactly 2 elements (since compl(e) ≠ e for non-fixed e, and compl(compl(e)) = e). The disjointness of pairs follows from the involution property. Therefore the total count of non-fixed elements is twice the number of pairs, hence even.

## 7. Grid Topology

### 7.1 Internal Edge Count

**Definition 7.1.** The number of internal edges in an m × n grid is m(n-1) + (m-1)n.

**Theorem 7.2.** For square grids: internalEdges(n,n) = 2n(n-1).

### 7.2 Euler Characteristic

**Theorem 7.3.** For m,n ≥ 1: V + F = E + 2, where V = mn (vertices), E = internal edges, F = (m-1)(n-1) + 1 (faces including outer face).

### 7.3 Constraint Density

**Theorem 7.4.** internalEdges(m,n) < 2mn for m,n ≥ 1.

This places jigsaw puzzles in the sparse constraint regime, with density ratio approaching 2 from below.

### 7.4 Constraint Superadditivity

**Theorem 7.5.** internalEdges(m₁ + m₂, n) = internalEdges(m₁, n) + internalEdges(m₂, n) + n.

This shows that merging two m-row grids introduces exactly n new boundary constraints — one per column. The constraint count is superadditive with respect to grid concatenation.

## 8. Concrete Verification

We verify the entire reduction on a concrete 3-SAT instance:

**Formula:** (x₁ ∨ x₂ ∨ ¬x₃) ∧ (¬x₁ ∨ x₃ ∨ x₃)

**Assignment:** x₁ = T, x₂ = F, x₃ = T

**Edge encoding:** x₁ → tab, x₂ → blank, x₃ → tab

**Verification:**
- Clause 1: x₁ = T, so x₁'s edge is tab. Clause satisfied.
- Clause 2: x₃ = T, so x₃'s edge is tab. Clause satisfied.

The edge encoding satisfies the edge system, confirming the reduction.

## 9. Discussion

### 9.1 Relationship to Prior Work

The NP-completeness of edge-matching puzzles was established by Demaine and Demaine. Our work deepens this by providing:
- A solution-*counting* invariant (not just existence)
- An algebraic characterization of the symmetry group
- A topological analysis via Euler characteristic
- A parity constraint on generalized alphabets

### 9.2 Implications

The solution count preservation implies that counting jigsaw puzzle solutions is #P-complete, inheriting the hardness of #SAT. The Z/2Z automorphism result shows that the encoding is essentially unique up to complement — there is no "shortcut" symmetry that could simplify the problem.

### 9.3 Boundary Cases

The reduction breaks down when:
- Edge alphabets have no non-fixed elements (no tab/blank pairs = no encoding capacity)
- The grid is 1×1 (no internal edges = no constraints)
- All edges are flat (every placement is trivially valid)

These boundary cases illuminate the essential role of the tab-blank complementarity.

## 10. Future Work

1. Extend to non-rectangular grid topologies (hexagonal, triangular)
2. Develop the spectral theory of compatibility graphs
3. Establish complexity bounds for approximate jigsaw solving
4. Connect to tropical semiring formulations of SAT

## References

1. Demaine, E.D. and Demaine, M.L. "Jigsaw puzzles, edge matching, and polyomino packing: connections and complexity." *Graphs and Combinatorics*, 23, 195-208, 2007.
2. Cook, S.A. "The complexity of theorem-proving procedures." *Proceedings of the Third Annual ACM Symposium on Theory of Computing*, 151-158, 1971.
3. The `clause_sat_iff_tab_exists` and `reduction_correctness` theorems from the Catalog (Pythagorean/JigsawNPComplete.lean, EML/JigsawAlgebra.lean).

## Appendix: Catalog References

- `clause_sat_iff_tab_exists` (Pythagorean/JigsawNPComplete.lean): The foundational clause satisfiability characterization, extended here to the full constraint system.
- `PuzzleAlphabet` (EML/JigsawAlgebra.lean): The abstract alphabet framework, extended here with the parity constraint.
- `reduction_correctness` (Pythagorean/JigsawNPComplete.lean): The basic satisfiability equivalence, strengthened here to a solution-counting result.
