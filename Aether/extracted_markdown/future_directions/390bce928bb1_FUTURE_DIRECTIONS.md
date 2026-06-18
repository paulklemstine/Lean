# Future Directions: Tropical Logic and Computability Thresholds

## Overview

The tropical undecidability threshold theorem establishes that multiplication is the exact dividing line between decidability and undecidability in tropical arithmetic. This foundational result opens five concrete, breakthrough-level research directions that connect tropical geometry, computability theory, automata theory, proof complexity, and formal verification.

---

## Direction 1: Tropical Matiyasevich Program

### Hypothesis
Every recursively enumerable set over ℕ is "tropically representable" — definable as the projection of the solution set of a tropical existential formula with multiplication.

### Proof Strategy
1. **Formalize the DPRM theorem in Lean 4**: The Davis-Putnam-Robinson-Matiyasevich theorem states that every r.e. set is Diophantine. Our embedding theorem (poly_system_iff_tropical) would then immediately yield tropical representability.
2. **Direct tropical encoding**: Alternatively, encode register machine computations directly as tropical formulas, bypassing the DPRM detour. The key gadgets needed:
   - State-selection using min-based one-hot encoding
   - Counter arithmetic using additive variables
   - Zero-test via auxiliary Boolean variables with min(x, 1-x) = 0 gadget
3. **Classification of tropically representable sets**: Characterize which sets are representable by mul-free formulas (these should be exactly the semilinear sets, by the Presburger connection).

### Cross-Domain Connections
- **Algebraic geometry**: Tropical representability connects to tropical varieties and amoeba theory
- **Computability theory**: Creates a new hierarchy: semilinear ⊂ Diophantine = tropically representable
- **Number theory**: May yield new Diophantine representations via tropical techniques

### Estimated Impact
High. Would unify tropical geometry with classical computability theory and provide new tools for both fields.

---

## Direction 2: Decidability Classification for Restricted Fragments

### Hypothesis
There exist natural intermediate fragments between mul-free and full polynomial tropical arithmetic where the decidability boundary can be precisely located.

### Specific Sub-Problems

**A. Degree-bounded multiplication**: Is tropical satisfiability with multiplication restricted to degree ≤ 2 (quadratic tropical formulas) decidable or undecidable?
- *Hypothesis*: Undecidable, since binary quadratic Diophantine equations (e.g., Pell's equation) already exhibit complex behavior.
- *Strategy*: Reduce from a known undecidable quadratic Diophantine problem, or prove decidability by reduction to the existential theory of the reals.

**B. Single-variable fragments**: Is tropical satisfiability with mul in a single variable decidable?
- *Hypothesis*: Decidable, since univariate polynomial satisfiability over ℤ is decidable (finite root search for each factor).
- *Strategy*: Prove that single-variable tropical formulas with mul can be decomposed into finitely many polynomial feasibility checks.

**C. Convex-only fragments**: What if we restrict to formulas where all atoms are inequalities (no equations)?
- *Hypothesis*: The pure inequality fragment with mul may remain undecidable, since polynomial inequalities can simulate equations via p² ≤ 0 ∧ 0 ≤ p² ↔ p = 0.
- *Strategy*: Formalize this equivalence and transfer undecidability.

**D. Fixed number of min operations**: What if the formula has at most k occurrences of tmin?
- *Hypothesis*: For k = 0 (no min), this is pure polynomial satisfiability — undecidable. For k > 0 with no mul, decidable. Mixed cases are open.

### Estimated Impact
Medium-High. Would create a fine-grained decidability landscape for tropical theories, analogous to the classification of decidable fragments of first-order logic.

---

## Direction 3: Matrix Reachability and Tropical Linear Algebra

### Hypothesis
The undecidability threshold extends to tropical matrix problems: reachability in min-plus linear systems is decidable, but reachability in systems with tropical polynomial (min-plus-times) dynamics is undecidable.

### Proof Strategy
1. **Formalize tropical matrix multiplication**: (A ⊗ B)_{ij} = min_k(A_{ik} + B_{kj}). This is mul-free and decidable.
2. **Tropical matrix power**: A^n for min-plus matrices. The Kleene star A* = ⊕_{n≥0} A^n computes all-pairs shortest paths. Decidable.
3. **Reachability with polynomial entries**: If matrix entries can involve multiplication of state variables, encode counter machine transitions as matrix products.
4. **Connect to the tropical eigenpair theorem**: Our existing `tropical_eigenpair_from_diagonal` result may provide structural lemmas about fixed points of tropical linear maps.

### Applications
- **Verification of timed automata**: Timed automata use min-plus matrices for clock semantics. Our decidability result guarantees that reachability in the linear fragment is decidable.
- **Control theory**: Min-plus linear systems model discrete-event systems (manufacturing, traffic). Decidability of reachability enables certified controller synthesis.
- **Weighted automata**: Weighted finite automata over the tropical semiring compute min-plus rational functions. Our threshold predicts which properties of weighted automata are decidable.

### Estimated Impact
High. Would connect tropical computability to automata theory and control theory, with direct practical applications.

---

## Direction 4: Complexity-Theoretic Completeness Results

### Hypothesis
Bounded tropical satisfiability (with mul, bounded variable domains) is NP-complete, and the mul-free variant has lower complexity (in P or NP).

### Specific Conjectures

**A. NP-completeness of bounded tropical SAT with mul**: When variables are restricted to {0, 1, ..., B} for some bound B given in unary, tropical satisfiability with mul is NP-complete.
- *Strategy*: Reduce from subset sum or 3-SAT. The reduction is likely straightforward since polynomial evaluation is in P.

**B. Polynomial-time solvability of mul-free tropical SAT**: The mul-free fragment reduces to integer linear feasibility (which is in NP, but the special structure of min-of-affine constraints may yield a P-time algorithm).
- *Strategy*: Show that the reduction to integer LP has polynomial size, and exploit the special structure (each constraint is a conjunction of comparisons between affine functions).

**C. PSPACE-completeness of quantified tropical formulas**: The full first-order theory of (ℤ, min, +) is decidable (by reduction to Presburger) — what is its exact complexity?
- *Known*: Presburger arithmetic has triply-exponential worst-case complexity for quantifier elimination. The tropical fragment may be better.

**D. Proof complexity lower bounds**: In tropical proof systems, are there tautologies that require exponentially long proofs? This connects to circuit complexity via the tropical-algebraic approach to VP vs VNP.

### Estimated Impact
Medium. Would place tropical satisfiability problems precisely in the computational complexity landscape.

---

## Direction 5: Tropical Interpretability and Logic Transfer

### Hypothesis
The embedding theorem generalizes to a full **interpretation theorem**: the first-order theory of (ℤ, min, +, ×) interprets the first-order theory of (ℤ, +, ×), enabling systematic transfer of logical results.

### Proof Strategy
1. **Define interpretability**: Theory T₁ interprets T₂ if there is a translation of formulas that preserves truth.
2. **Extend the embedding**: Currently we embed existential polynomial formulas. Extend to universal and alternating quantifiers.
3. **Transfer theorems**: Any undecidability, incompleteness, or complexity result for arithmetic transfers to tropical-with-mul.
4. **Converse question**: Does (ℤ, +, ×) interpret (ℤ, min, +, ×)? If yes, the theories are bi-interpretable and logically equivalent.

### Sub-Direction: Tropical Proof Systems
Define a tropical analogue of Hilbert-style or sequent calculus proof systems:
- Axioms: tropical identities (distributivity of + over min, etc.)
- Rules: substitution, modus ponens for tropical implications
- **Completeness question**: Is there a complete proof system for the valid sentences of tropical arithmetic (with or without mul)?
- Our threshold theorem implies: no complete recursive proof system exists for the full language with mul (by Gödel-style argument from undecidability).

### Cross-Domain Connections
- **Model theory**: Tropical interpretability creates new connections between model theory of ordered abelian groups and tropical geometry
- **Proof complexity**: Lower bounds for tropical proof systems would yield circuit complexity lower bounds via the Razborov-Rudich natural proofs framework
- **Semiring logic**: Extends to other idempotent semirings (max-plus, max-times, etc.) with analogous threshold theorems

### Estimated Impact
Very High. Would establish tropical logic as a new subfield with deep connections to mathematical logic, proof complexity, and algebraic geometry.

---

## Implementation Roadmap

### Phase 1 (3-6 months)
- Complete the TCM-to-tropical reduction (Direction 1, part 2)
- Prove NP-completeness of bounded tropical SAT with mul (Direction 4A)
- Implement a decision procedure for mul-free tropical SAT (Direction 2B)

### Phase 2 (6-12 months)
- Formalize the DPRM theorem in Lean 4, or connect to an existing formalization (Direction 1, part 1)
- Classify degree-2 fragments (Direction 2A)
- Develop tropical matrix reachability theory (Direction 3)

### Phase 3 (1-2 years)
- Full interpretability theorem (Direction 5)
- Tropical proof system foundations (Direction 5, sub-direction)
- Connect to weighted automata decidability (Direction 3, applications)

### Phase 4 (2-5 years)
- Complete decidability classification (Direction 2, all sub-problems)
- Tropical Matiyasevich program (Direction 1, part 3)
- Applications to neural network verification at scale (Direction 3, applications)

---

## Team Composition

Each direction benefits from collaboration across specialties:

- **Direction 1**: Computability theorists + tropical geometers
- **Direction 2**: Model theorists + formal verification experts
- **Direction 3**: Control theorists + automata theorists + formal methods researchers
- **Direction 4**: Complexity theorists + optimization researchers
- **Direction 5**: Proof theorists + algebraic logicians + formal verification experts

---

## Key Hypotheses for Experimental Validation

1. *The degree-2 threshold*: Test computationally whether random degree-2 tropical systems are harder to solve than degree-1 systems (measure solve time vs. variable count).
2. *Matrix reachability scaling*: Profile min-plus matrix power computation vs. min-plus-times matrix reachability to empirically locate the complexity gap.
3. *Proof length scaling*: Generate tropical tautologies of increasing size and measure proof search time in automated provers to detect potential exponential blowups.
4. *Neural network fragment*: Verify that real-world ReLU network verification instances fall within the decidable (mul-free) fragment, confirming the practical relevance of the threshold.

---

*Each of these directions represents a concrete, actionable research program with clear hypotheses, proof strategies, and cross-domain connections. The threshold theorem provides the foundation; these directions build the edifice of tropical computability theory.*
