# Future Directions: Tropical Divisor Theory and Machine-Checked Graph Geometry

## Synthesis

This research cycle established the formal foundations of tropical divisor theory on finite graphs: definitions of graph divisors, the Laplacian, chip-firing equivalence, canonical divisors, genus, and divisor rank, along with 25 machine-checked theorems including the canonical degree formula deg(K_G) = 2g − 2 and degree invariance under chip-firing. These results create a certified computational backbone for tropical geometry on graphs.

The five directions below form a coherent program advancing from this foundation. Direction 1 (full Riemann–Roch) is the immediate grand challenge, completing the Baker–Norine theorem in machine-checked form. Direction 2 (verified Dhar algorithm) provides the computational engine needed by all subsequent work. Directions 3–5 build outward: the critical group (Direction 3) connects to algebraic number theory and statistical physics; tropical Brill–Noether theory (Direction 4) links to classical algebraic geometry; and the Laplacian-rank bridge (Direction 5) connects to linear algebra and combinatorial optimization. Together, these would establish the first comprehensive formal tropical geometry engine.

---

## Direction 1: Full Baker–Norine Theorem (Grand Challenge)

**Conjecture:** For any finite connected graph G of genus g with canonical divisor K, and any divisor D on G:

r(D) − r(K − D) = deg(D) − g + 1

**Test:** 
- Formalize the statement in Lean 4 using the definitions from `Tropical/ChipFiring/Defs.lean`
- Prove it via the q-reduced divisor route: show that D is equivalent to a unique q-reduced divisor, establish the rank characterization via reduced divisors, and derive the identity from the complementation property of reduced divisors
- Computationally verify on all graphs with ≤ 7 vertices using the Python implementation

**Impact:** This would be the first machine-checked proof of a Riemann–Roch theorem in any setting — combinatorial, tropical, or classical. It would establish Lean 4 as a platform for certified algebraic geometry.

**Catalog References:** 
- `Tropical/ChipFiring/Theorems.lean`: `divisorDegree_laplacian_zero`, `degree_canonicalDivisor`, `linearEquivalent_degree_eq`
- `Tropical/ChipFiring/CompleteGraph.lean`: `completeGraph_genus`

**Proof Strategy:** 
1. Formalize q-reduced divisors: define `IsQReduced G D q` and prove existence/uniqueness
2. Prove the Dhar characterization: D ~ effective iff q-reduced form is non-negative on V\{q}
3. Prove the complementation lemma: if D_q is the q-reduced form of D, then (K−D)_q has a specific complementary structure
4. Derive Riemann–Roch from the complementation lemma

**Domain Bridges:** Algebraic geometry (classical Riemann–Roch), analysis (Laplace equation), combinatorics (chip-firing games)

**Lineage:** Extends `degree_canonicalDivisor` and `linearEquivalent_degree_eq` from this cycle

**Ambition:** Paradigm-shifting — first formal Riemann–Roch in any mathematical domain

---

## Direction 2: Verified Dhar Reduction Algorithm

**Conjecture:** The Dhar-based reduction algorithm terminates in O(deg(D) · |V|) steps and produces the unique q-reduced divisor in the linear equivalence class of D.

**Test:**
- Formalize the algorithm as a Lean 4 function with a termination proof
- Prove three properties: (1) output is linearly equivalent to input, (2) output is q-reduced, (3) output is unique in its equivalence class
- Benchmark against the Python implementation on random graphs with up to 100 vertices

**Impact:** Creates a certified computation pipeline: given a divisor, the algorithm produces a canonical representative with a machine-checked correctness certificate. This is the computational heart of all tropical divisor algorithms.

**Catalog References:**
- `Tropical/ChipFiring/Defs.lean`: `laplacianDivisor`, `LinearEquivalent`, `Effective`
- `Tropical/ChipFiring/Theorems.lean`: `divisorDegree_laplacian_zero`

**Proof Strategy:**
1. Define a well-founded measure: the sum Σ_v max(0, D(v)) decreases with each Dhar step (after the initial phase)
2. Use `Finset.sum` monotonicity arguments from Mathlib
3. For uniqueness: show that two q-reduced divisors in the same class must be equal by analyzing the lattice structure

**Domain Bridges:** Algorithms (verified computation), complexity theory (polynomial-time graph algorithms), formal methods (certified programs)

**Lineage:** Extends `linearEquivalent_refl`, `linearEquivalent_trans` from this cycle

**Ambition:** High — first verified divisor reduction algorithm in any theorem prover

---

## Direction 3: Critical Group and Tropical Jacobian

**Conjecture:** For any finite connected graph G, the group of degree-zero divisor classes (modulo chip-firing equivalence) is a finite abelian group whose order equals the number of spanning trees of G. For the complete graph K_n, this group is isomorphic to (ℤ/nℤ)^(n−2).

**Test:**
- Formalize the quotient group Jac(G) = Div⁰(G) / Prin(G) in Lean 4
- Prove finiteness using the Smith normal form of the Laplacian matrix
- Compute |Jac(K_n)| = n^(n−2) and verify against Cayley's formula
- For K₃, explicitly enumerate the 3 elements and verify the group table

**Impact:** Connects tropical geometry to algebraic number theory (discrete Jacobians), statistical physics (sandpile groups), and representation theory (Laplacian spectral theory). The sandpile group is used in chip-firing automata, cryptographic hash functions, and network reliability analysis.

**Catalog References:**
- `Tropical/ChipFiring/Defs.lean`: `LinearEquivalent`, `divisorDegree`
- `Tropical/ChipFiring/Theorems.lean`: `linearEquivalent_refl`, `linearEquivalent_symm`, `linearEquivalent_trans`

**Proof Strategy:**
1. Define `DivZero G` as the subgroup of degree-0 divisors
2. Show `LinearEquivalent G` restricted to degree-0 divisors is an equivalence relation (already proved)
3. Construct the quotient using Mathlib's `Quotient` API
4. Prove finiteness via the Smith normal form of the reduced Laplacian
5. Compute using `Fintype.card` and matrix determinant

**Domain Bridges:** Number theory (class groups), statistical physics (Abelian sandpile), coding theory (lattice codes)

**Lineage:** Builds directly on the equivalence relation proofs from this cycle

**Ambition:** High — first formal tropical Jacobian

---

## Direction 4: Tropical Brill–Noether Theory

**Conjecture:** (Graph-theoretic Brill–Noether) For a general graph of genus g, a divisor of degree d and rank r exists if and only if the Brill–Noether number ρ = g − (r+1)(g−d+r) ≥ 0. Moreover, when ρ ≥ 0, the space of such divisors has "dimension" ρ in an appropriate tropical sense.

**Test:**
- For each genus g ≤ 6, enumerate all combinatorial types of graphs and test the Brill–Norine rank for divisors of varying degree
- Compare against the classical Brill–Noether prediction ρ = g − (r+1)(g−d+r) ≥ 0
- Identify counterexamples for non-general graphs (graph-theoretic analogue of special curves)
- Formally verify the Brill–Noether existence theorem for K₃ (genus 1) and K₄ (genus 3)

**Impact:** Would establish the tropical analogue of one of the deepest results in algebraic geometry, providing combinatorial access to moduli-space phenomena. This connects directly to Baker's specialization lemma and the tropical proof of the classical Brill–Noether theorem.

**Catalog References:**
- `Tropical/ChipFiring/CompleteGraph.lean`: `completeGraph_genus`, rank computation
- `Catalog/Tropical/BrillNoether/`: existing Brill–Noether definitions

**Proof Strategy:**
1. Formalize the Brill–Noether number ρ(g,r,d) = g − (r+1)(g−d+r)
2. For specific graph families (complete graphs, complete bipartite), verify the existence claim computationally
3. For the formal proof, use the chip-firing reduction framework to construct explicit divisors of given rank

**Domain Bridges:** Algebraic geometry (moduli of curves), combinatorics (graph enumeration), representation theory

**Lineage:** Extends `completeGraph_genus` and rank definitions from this cycle

**Ambition:** Grand challenge — connecting tropical combinatorics to classical moduli theory

---

## Direction 5: Tropical Rank / Laplacian Minor Bridge

**Conjecture:** For any finite connected graph G, the Baker–Norine rank of certain canonical degree-zero divisor families is bounded below by the tropical rank of a Laplacian-minor matrix canonically attached to G. Specifically, for the divisor D_S = Σ_{v ∈ S} [v] − |S|·[q] associated to a vertex subset S ⊆ V\{q}, we conjecture:

r(D_S) ≥ trop_rank(L_S) − 1

where L_S is the submatrix of the Laplacian indexed by S, and trop_rank denotes the tropical rank (Develin–Santos–Sturmfels).

**Test:**
- Implement tropical matrix rank computation
- For all graphs on ≤ 7 vertices, compute both sides for all subsets S
- Search for counterexamples systematically
- If the conjecture survives, analyze the equality cases

**Impact:** Would bridge two major threads in tropical mathematics: the Baker–Norine divisor theory (based on graphs and chip-firing) and the tropical linear algebra program (based on matrices and valuations). This connection, if valid, would provide new rank lower bounds computable from linear algebra.

**Catalog References:**
- `Catalog/Tropical/FactorRank.lean`: tropical rank definitions
- `Tropical/ChipFiring/Defs.lean`: `divisorRank`, `laplacianDivisor`

**Proof Strategy:**
1. If the conjecture holds, look for a proof via the Kirchhoff matrix-tree theorem applied to minors
2. The tropical rank of L_S should relate to the number of "independent chip-firing moves" within S
3. This connects to the theory of generalized inverses of the Laplacian

**Domain Bridges:** Linear algebra (tropical matrices), combinatorial optimization (matroid theory), physics (Green's functions on graphs)

**Lineage:** Connects the chip-firing framework from this cycle to the tropical matrix theory in the existing catalog

**Ambition:** Paradigm-shifting — new bridge between tropical linear algebra and divisor theory
