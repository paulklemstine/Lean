# Future Directions: Tropical Amortized Complexity Analysis

This document outlines five concrete breakthrough research opportunities opened by the formalization of amortized analysis as tropical (min-plus) algebra.

---

## 1. Automated Synthesis of Potential Functions via Tropical Linear Programming

**Hypothesis:** The set of valid potential functions for a given data structure forms a tropical polyhedron (defined by difference constraints of the form Φ(s) - Φ(s') ≤ w(s,s')), and optimal potential functions can be computed by solving a tropical linear feasibility problem—equivalently, a shortest-path problem in a constraint graph.

**Proof Strategy:**
- Formalize tropical polyhedra as solution sets of systems `Φ(s_i) - Φ(s_j) ≤ c_{ij}`.
- Prove that the Bellman-Ford algorithm computes a feasible point (or detects infeasibility via a negative cycle) in this tropical polyhedron.
- Show that the optimal amortized bound is the value of a dual tropical linear program.
- Implement an automated potential-function synthesizer: given a state transition graph with edge costs, output a potential function minimizing the worst-case amortized charge.

**Cross-Domain Connections:**
- Tropical linear programming / tropical convexity (Develin–Sturmfels, Joswig)
- Parametric shortest paths and sensitivity analysis
- Abstract interpretation in program analysis (difference-bound matrices)

**Concrete Next Step:** Formalize the Bellman-Ford algorithm in Lean as a tropical LP solver and prove it finds the tightest potential function for any finite-state data structure.

---

## 2. Bellman Duality for Amortized Complexity Certificates

**Hypothesis:** There is a formal strong duality theorem connecting primal (optimal amortized schedule) and dual (potential function certificate) formulations of amortized analysis, analogous to LP duality in the tropical setting.

**Proof Strategy:**
- Define the primal problem: given actual costs, find amortized charges minimizing total charge subject to prefix-sum feasibility.
- Define the dual problem: find a potential function certifying the amortized bound.
- Prove weak duality (already done: accounting_potential_equiv establishes one direction).
- Prove strong duality: every achievable amortized bound has a witnessing potential function.
- Extend to the infinite-horizon (discounted/average) setting.

**Cross-Domain Connections:**
- Min-cost flow duality and reduced costs
- LP duality in the tropical semiring (Akian–Gaubert–Guterman)
- Competitive analysis of online algorithms (potential method as dual certificate)

**Concrete Next Step:** Formalize the dual characterization for finite-state systems and prove that the optimal potential function achieves the minimax amortized cost.

---

## 3. Weighted Automata Semantics of Data Structure Traces

**Hypothesis:** The trace of operations on a data structure can be modeled as a weighted word over a min-plus semiring, and amortized analysis corresponds to factoring this weighted language through a tropical semiring homomorphism.

**Proof Strategy:**
- Define weighted automata over the min-plus semiring (states = data structure configurations, transitions = operations with costs).
- Show that the cost of an operation sequence is the weight of the corresponding word in the weighted automaton.
- Prove that potential functions correspond to gauge transformations of the automaton (changing the weight representation without changing the language).
- Show that the optimal amortized bound equals the spectral radius of the transition matrix in the tropical semiring.

**Cross-Domain Connections:**
- Weighted automata theory (Droste–Kuich–Vogler)
- Tropical spectral theory and max-plus eigenvalues
- Regular model checking and verification
- Information-theoretic lower bounds via weighted language entropy

**Concrete Next Step:** Formalize min-plus weighted automata in Lean, define the tropical gauge transformation, and prove equivalence with the potential method.

---

## 4. Certified Resource Analysis for Functional Programs via Min-Plus DP

**Hypothesis:** Automatic resource analysis (AARA) systems—which assign potential-annotated types to functional programs—can be soundly grounded in the tropical amortized framework, giving machine-checked certificates for heap/stack/time bounds.

**Proof Strategy:**
- Define a simple functional language (λ-calculus with lists) with resource semantics.
- Formalize potential-annotated types as tropical type assignments.
- Prove that well-typed programs satisfy amortized resource bounds (soundness of AARA).
- Show that type inference reduces to tropical constraint solving (the connection to Direction 1).
- Implement a verified resource analyzer that outputs Lean-checked certificates.

**Cross-Domain Connections:**
- Automatic amortized resource analysis (Hofmann–Jost, Hoffmann et al.)
- Refinement types and liquid types
- Cost semantics for functional programs
- Verified compilation (CompCert, CakeML)

**Concrete Next Step:** Formalize the Hofmann-Jost type system for linear resource bounds in Lean, prove its soundness using the tropical telescoping theorem, and verify the resource bound of a concrete list-processing program.

---

## 5. Tropical Convexity of Feasible Amortized Analyses

**Hypothesis:** The set of all feasible amortized charge sequences for a given cost sequence forms a tropical convex set, and this geometric structure enables efficient enumeration and optimization over feasible analyses.

**Proof Strategy:**
- Define tropical convex sets and tropical polytopes (min-plus analogs of convex hulls and polyhedra).
- Prove that the feasibility condition (∀ prefix sums, ∑c ≤ ∑a) defines a tropical half-space intersection.
- Show that extreme points of this tropical polytope correspond to "tight" potential functions (where some prefix constraint is binding).
- Prove that the tropical convolution composition theorem preserves tropical convexity (the monoid structure on tropical polytopes under ⊗).
- Connect to the theory of tropical linear spaces and valuated matroids.

**Cross-Domain Connections:**
- Tropical convexity and tropical polytopes (Develin–Sturmfels, Joswig–Loho)
- Combinatorial optimization and polymatroid theory
- Algorithmic game theory (tropical analog of correlated equilibria)
- Persistent homology of tropical varieties

**Concrete Next Step:** Formalize tropical convex sets in Lean, prove that the set of feasible amortized analyses is tropically convex, and characterize its extreme points for the binary counter example.

---

## Summary Table

| Direction | Key Theorem Target | Estimated Difficulty | Primary Tool |
|-----------|-------------------|---------------------|-------------|
| 1. Tropical LP Synthesis | Bellman-Ford = tropical LP solver | Medium | Shortest paths |
| 2. Bellman Duality | Strong duality for amortized bounds | Medium-Hard | LP duality |
| 3. Weighted Automata | Gauge ↔ potential equivalence | Hard | Automata theory |
| 4. Certified AARA | Soundness of potential-annotated types | Hard | Type theory |
| 5. Tropical Convexity | Feasibility set is tropically convex | Medium | Tropical geometry |

---

## Team Directive

Each direction should be pursued by a team that:
1. States the main conjecture as a precise Lean theorem statement.
2. Identifies 3–5 helper lemmas needed for the proof.
3. Tests the helper lemmas computationally with `#eval` examples.
4. Proves the helper lemmas bottom-up, building toward the main theorem.
5. Documents cross-domain connections and applications.
6. Iterates: if a helper lemma fails, decompose further or try an alternative approach.

The tropical amortized framework provides a solid algebraic foundation. The next breakthrough is connecting this foundation to automated tools (Directions 1, 4), deeper mathematical structures (Directions 3, 5), and classical optimization duality (Direction 2).
