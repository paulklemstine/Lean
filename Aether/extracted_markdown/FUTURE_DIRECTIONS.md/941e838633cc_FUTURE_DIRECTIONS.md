# Future Directions: Tropical Automata Complexity Theory

## Overview

The formalization of polynomial-time decidability of tropical Nerode index for deterministic automata opens several concrete research directions. Each direction below includes specific theorem targets, proof strategies, and cross-domain connections.

---

## Direction 1: Nondeterministic Tropical Automata — The Complexity Jump

### Problem Statement
For *nondeterministic* tropical automata, the output on a word is the minimum over all accepting computation paths. Determine the exact complexity of Nerode equivalence and minimization in this setting.

### Specific Theorem Targets

```
-- Conjecture: NFA tropical equivalence is coNP-hard
theorem nfa_tropical_equiv_coNP_hard :
    ∃ (reduction : SAT_instance → NTropicalAutomaton × NTropicalAutomaton),
      polynomial_time reduction ∧
      ∀ φ, satisfiable φ ↔ ¬equiv (reduction φ).1 (reduction φ).2
```

```
-- Decidability (known): NFA tropical equivalence is decidable
theorem nfa_tropical_equiv_decidable :
    ∀ A B : NTropicalAutomaton, Decidable (equiv A B)
```

### Proof Strategy
- Encode SAT instances as cost-minimization problems over nondeterministic tropical automata.
- Use the existential quantifier in nondeterministic semantics to hide the satisfying assignment.
- The depth-refinement approach breaks because nondeterministic outputs are not determined by a single path.

### Why This Matters
This would precisely locate the complexity jump from deterministic (polynomial) to nondeterministic (likely coNP-hard) tropical minimization, analogous to the DFA vs NFA equivalence gap in classical automata theory.

---

## Direction 2: Tropical Bisimulation and Coalgebraic Semantics

### Problem Statement
Develop a coalgebraic theory of behavioral equivalence for tropical automata, showing that Nerode equivalence coincides with bisimulation equivalence in the deterministic case.

### Specific Theorem Targets

```
-- A deterministic tropical automaton is a coalgebra for the functor F(X) = X^Σ × ℕ∞
def tropicalCoalgebra (A : DetTropAut α σ) :
    σ → (α → σ) × WithTop ℕ

-- Bisimulation equivalence = Nerode equivalence
theorem bisim_eq_nerode (A : DetTropAut α σ) :
    ∀ q r, bisimilar A q r ↔ StateNerodeEq A q r

-- Final coalgebra gives the minimal realization
theorem final_coalgebra_is_minimal :
    ∃! (B : DetTropAut α (FinalCoalgebra F)),
      ∀ A : DetTropAut α σ, ∃! h : σ → FinalCoalgebra F, is_coalgebra_morphism h
```

### Proof Strategy
- Define tropical coalgebras using Mathlib's category theory infrastructure.
- Show the unique-morphism-to-final property characterizes the quotient.
- Use existing Mathlib coalgebra foundations if available, or build minimal infrastructure.

### Cross-Domain Connection
This connects tropical automata to the broader coalgebra program in semantics, enabling transfer of techniques from process algebra, reactive systems, and stream processing.

---

## Direction 3: Tropical Matrix Canonical Forms and Min-Plus Rank

### Problem Statement
Connect tropical automata minimization to tropical linear algebra, showing that the Nerode index equals the tropical rank of a certain matrix.

### Specific Theorem Targets

```
-- The Hankel matrix of a tropical language
def tropicalHankelMatrix (L : List α → WithTop ℕ) (prefixes suffixes : List (List α)) :
    Matrix (Fin m) (Fin n) (WithTop ℕ)

-- Nerode index = tropical rank of Hankel matrix (for appropriate notion of rank)
theorem nerode_index_eq_tropical_rank :
    nerodeIndex A = tropicalRank (tropicalHankelMatrix (language A) ...)
```

### Proof Strategy
- Define the tropical Hankel matrix whose (u,v)-entry is L(u·v).
- Show that Nerode equivalence classes correspond to tropical row equivalence in this matrix.
- Connect tropical rank (number of tropically independent rows) to the Nerode index.

### Why This Matters
This bridges automata theory and tropical linear algebra, opening connections to min-plus matrix multiplication, tropical convexity, and algebraic complexity theory.

---

## Direction 4: Certified Executable Minimizer via Code Extraction

### Problem Statement
Extract a verified executable program from the Lean formalization that takes a concrete tropical automaton and produces its minimal quotient.

### Specific Deliverables

```
-- A computable minimization function
def computeMinimalAutomaton (A : DetTropAut α σ) :
    Σ (β : Type) (_ : Fintype β), DetTropAut α β

-- Correctness certificate
theorem computeMinimalAutomaton_correct (A : DetTropAut α σ) :
    let ⟨β, _, B⟩ := computeMinimalAutomaton A
    (∀ q : σ, ∃ q' : β, stateResidual B q' = stateResidual A q) ∧
    Fintype.card β = nerodeIndex A
```

### Implementation Strategy
- Replace `noncomputable` definitions with computable alternatives.
- Use `DecidableEq` and `Fintype` instances to implement concrete comparison.
- Use Lean's code generation to extract executable code.
- Benchmark against hand-written implementations.

### Why This Matters
Certified code extraction produces verified software that is *provably correct by construction* — essential for safety-critical applications in control systems and network routing.

---

## Direction 5: Semiring Complexity Frontier

### Problem Statement
Systematically compare the complexity of Nerode equivalence and minimization across different semirings: Boolean, tropical (min-plus), max-plus, probabilistic (ℝ≥0), and the integers.

### Specific Theorem Targets

```
-- Boolean (classical): polynomial (known, reproved as corollary)
theorem boolean_minimization_poly : ...

-- Tropical min-plus (deterministic): polynomial (this work)
theorem tropical_det_minimization_poly : ...

-- Max-plus (deterministic): polynomial (should follow by duality)
theorem maxplus_det_minimization_poly : ...

-- Probabilistic: decidable but complexity unknown
theorem probabilistic_equiv_decidable : ...

-- Integer semiring: undecidable in general
theorem integer_weighted_equiv_undecidable : ...
```

### Proof Strategy
- Use the tropical formalization as a template for max-plus (dual semiring).
- For probabilistic automata, connect to the Schützenberger-type results on rational series.
- For undecidability results, reduce from Hilbert's tenth problem or the halting problem.

### Why This Matters
This would produce a comprehensive formal complexity map of weighted automata minimization, clarifying which semiring features enable tractability.

---

## Priority Ordering

1. **Direction 4** (Certified executable) — Most immediately useful; builds directly on current infrastructure.
2. **Direction 1** (Nondeterministic complexity) — Most theoretically impactful; identifies the tractability boundary.
3. **Direction 5** (Semiring frontier) — Broadest scope; creates a unified framework.
4. **Direction 2** (Coalgebraic semantics) — Deepest conceptually; connects to category theory.
5. **Direction 3** (Matrix canonical forms) — Most novel connections; bridges to tropical geometry.

---

## Cross-Cutting Infrastructure Needs

- **Weighted automata library**: Generic semiring-parameterized automata in Lean/Mathlib.
- **Tropical linear algebra**: Min-plus matrix operations, tropical determinant, tropical rank.
- **Complexity theory basics**: Polynomial-time reductions, complexity classes in Lean.
- **Coalgebra library**: Functorial semantics, final coalgebras, bisimulation.

Each direction is designed to be independently pursuable while contributing to a coherent formal complexity theory of weighted automata.
