# Future Directions: Tropical Proof Complexity and Idempotent Theorem Discovery

## Overview

This document outlines 5 breakthrough-level research directions opened by the formalization of theorem discovery as tropical fixed-point computation. Each direction includes specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Tropical Proof Complexity Lower Bounds

### Vision
Use tropical algebraic methods to prove lower bounds on proof depth in specific inference systems, analogous to circuit complexity lower bounds via algebraic methods.

### Specific Hypotheses
- **H1.1:** For every monotone inference system on n propositions, there exists a derivable formula requiring depth Ω(n) in the worst case.
- **H1.2:** The tropical rank of the inference adjacency matrix lower-bounds the minimum proof depth of the hardest derivable formula.
- **H1.3:** Random inference graphs (Erdős-Rényi on rules) exhibit a sharp threshold for proof depth: below the threshold, most formulas have O(log n) depth; above it, Ω(n).

### Proof Strategies
1. Define tropical rank of the rule adjacency matrix M as the minimum dimension of a tropical factorization M = A ⊗ B.
2. Show that if the tropical rank is r, then the Kleene star M* requires at least r iterations to stabilize.
3. Connect to circuit complexity: viewing inference rules as gates, proof depth is circuit depth. Tropical rank bounds translate to depth-width tradeoffs.

### Cross-Domain Connections
- Algebraic circuit complexity (Bürgisser, 2000)
- Tropical convexity and rank (Develin & Sturmfels, 2004)
- Communication complexity (Kushilevitz & Nisan, 1997) — tropical rank relates to communication matrix rank

### Deliverables
- Formal definition of tropical proof complexity class
- At least one explicit lower bound for a concrete inference system
- Connection to Boolean circuit depth via tropical simulation

---

## Direction 2: Continuous Lattice Extension for First-Order Logic

### Vision
Extend the finite closure theory to countably infinite theorem spaces using continuous lattices and ordinal-indexed iteration, capturing first-order derivability.

### Specific Hypotheses
- **H2.1:** For compactly generated consequence operators (every consequence has a finite proof), the closure stabilizes at ω (the first infinite ordinal).
- **H2.2:** The completeness theorem (derivable ↔ ∈ closure) extends to the ω-indexed closure for recursively enumerable rule sets.
- **H2.3:** Tropical depth extends to ordinal-valued depth functions for infinite systems, with ω as the natural upper bound for finitely-generated rules.

### Proof Strategies
1. Replace `Finset σ` with `Set σ` and use Scott-continuous operators on the powerset lattice.
2. Define transfinite iterates: T_α = step(⋃_{β<α} T_β) for limit ordinals.
3. Prove stabilization at ω using compactness: every element of T_ω has a finite derivation, hence belongs to some T_n.

### Cross-Domain Connections
- Domain theory (Abramsky & Jung, 1994)
- Effective descriptive set theory
- Ordinal analysis of proof systems (Pohlers, 2009)

### Deliverables
- Formal framework for infinite closure in dependent type theory
- ω-stabilization theorem for compact consequence operators
- Hierarchy theorem relating closure ordinals to rule complexity

---

## Direction 3: Spectral Theory of Consequence Operators

### Vision
Develop a spectral theory for consequence operators viewed as tropical linear maps, where eigenvalues control convergence rates and proof depth bounds.

### Specific Hypotheses
- **H3.1:** The tropical spectral radius ρ of the inference adjacency matrix M satisfies: if ρ < 1 (in a suitable sense), then the system is "proof-finite" (bounded depth). If ρ ≥ 1, there exist arbitrarily deep proofs.
- **H3.2:** For strongly connected inference graphs, the tropical spectral radius equals the maximum average cycle weight, and controls the amortized proof depth per formula.
- **H3.3:** The tropical eigenvalues of M determine the "proof complexity spectrum" — a fingerprint characterizing the inference system up to proof-equivalence.

### Proof Strategies
1. Define tropical eigenvalues via the Rote-like characterization: λ is a tropical eigenvalue of M if M ⊗ v = λ ⊗ v for some tropical eigenvector v.
2. For acyclic inference graphs (no circular reasoning), show ρ = 0 and depth ≤ n-1.
3. For cyclic graphs (with lemma reuse), relate ρ to the longest cycle and show depth is bounded by n × ρ.
4. Use the Perron-Frobenius theorem for tropical matrices to show existence of a dominant eigenvalue for strongly connected components.

### Cross-Domain Connections
- Tropical eigenvalue theory (Akian, Bapat & Gaubert, 2006)
- Max-plus linear algebra (Heidergott, Olsder & van der Woude, 2006)
- Dynamical systems on lattices (convergence rates)

### Deliverables
- Definition of tropical spectrum for inference systems
- Classification: acyclic (ρ=0) vs cyclic (ρ>0) inference
- Spectral bound on proof depth: depth ≤ f(n, ρ)

---

## Direction 4: Applications to SAT Solving and Constraint Propagation

### Vision
Apply tropical closure theory to improve SAT solvers and constraint satisfaction algorithms by precomputing proof depth estimates and identifying hard clauses.

### Specific Hypotheses
- **H4.1:** Unit propagation in DPLL/CDCL SAT solvers is exactly stepRules iteration on the clause database. The tropical depth predicts propagation chain length.
- **H4.2:** Clauses with high tropical depth (expensive to derive) are good candidates for learned-clause deletion heuristics — they indicate complex inferences unlikely to be reused.
- **H4.3:** The tropical spectral radius of the clause dependency graph predicts solver running time better than existing heuristics (clause-variable ratio, community structure).

### Proof Strategies
1. Model a SAT instance as a rule system: each clause C = (l₁ ∨ ... ∨ lₖ) with assigned variables gives rise to rules (¬l₁, ..., ¬l_{k-1}) ⊢ lₖ.
2. Build the inference hypergraph and compute tropical distances from decision variables to derived literals.
3. Instrument a SAT solver to record actual propagation depths; compare with tropical predictions.
4. Use tropical depth estimates as a scoring function for variable ordering and clause deletion.

### Cross-Domain Connections
- CDCL SAT solving (Biere et al., 2009)
- Constraint propagation (Bessière, 2006)
- Pseudo-Boolean optimization as tropical optimization

### Deliverables
- Formal model of unit propagation as tropical closure
- Experimental comparison of tropical heuristics vs. VSIDS on SAT benchmarks
- Open-source SAT solver plugin using tropical depth estimates

---

## Direction 5: Categorical Semantics of Tropical Theorem Discovery

### Vision
Develop a categorical framework where inference systems are morphisms in a category of tropical modules, closure is a monad, and proof equivalence is a natural transformation.

### Specific Hypotheses
- **H5.1:** The closure operator defines a monad on the category of finite sets, with unit = axiom inclusion and multiplication = closure idempotence (closing a closed set does nothing).
- **H5.2:** Morphisms between inference systems (rule translations) correspond to tropical module homomorphisms that preserve proof depth up to bounded distortion.
- **H5.3:** The Eilenberg-Moore algebras of the closure monad are exactly the fixed points (closed theories), providing a categorical characterization of complete theories.

### Proof Strategies
1. Define the category FinSet_R of finite sets equipped with rule systems; morphisms are functions preserving derivability.
2. Show the closure operator C : FinSet → FinSet extends to a monad (unit: A ↪ C(A); mult: C(C(A)) = C(A)).
3. The Kleisli category of this monad has objects = axiom sets, morphisms = consequence-preserving maps.
4. Extend to tropical enrichment: replace Set with the category of modules over the min-plus semiring.

### Cross-Domain Connections
- Monads in computer science (Moggi, 1991; Wadler, 1995)
- Enriched category theory (Kelly, 1982)
- Algebraic theories and Lawvere theories
- Topos theory and categorical logic

### Deliverables
- Formal definition of the closure monad in dependent type theory
- Proof that Eilenberg-Moore algebras = closed theories
- Tropical enrichment giving proof-depth-aware categorical semantics

---

## Implementation Priority

| Direction | Difficulty | Impact | Time Estimate |
|-----------|-----------|--------|---------------|
| 1. Tropical Lower Bounds | High | Very High | 6-12 months |
| 2. Continuous Extension | Medium | High | 3-6 months |
| 3. Spectral Theory | High | Very High | 6-12 months |
| 4. SAT Applications | Medium | Very High | 3-6 months |
| 5. Categorical Semantics | Medium-High | Medium | 4-8 months |

**Recommended starting point:** Direction 4 (SAT applications) offers the most immediate practical impact and validates the theory experimentally. Direction 2 (continuous extension) is the most natural mathematical next step. Directions 1 and 3 are the most ambitious but potentially transformative.

---

## Cross-Cutting Themes

All five directions share common technical needs:
- Formal libraries for tropical linear algebra (min-plus matrices, Kleene star)
- Efficient algorithms for tropical matrix operations
- Benchmark inference systems for testing theoretical predictions
- Integration with existing proof assistants and SAT solvers

Building these shared tools should be prioritized as enabling infrastructure.
