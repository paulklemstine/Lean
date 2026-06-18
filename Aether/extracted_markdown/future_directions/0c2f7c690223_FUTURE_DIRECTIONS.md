# Future Directions: Formalized Proof Complexity

This document outlines 5 concrete breakthrough next steps building on our formalized theory of resolution, width lower bounds, and proof system separation.

---

## 1. Full Ben-Sasson–Wigderson Width-Size Inequality

### Exact Theorem Statement

```lean
theorem resolution_size_lower_of_width
    {ν : Type} [Fintype ν] [DecidableEq ν]
    (F : CNF ν) (w₀ w : ℕ)
    (hw₀ : ∀ C ∈ F, C.card ≤ w₀)
    (hw : ∀ t : ResTree F ∅, w ≤ t.maxWidth) :
    ∀ t : ResTree F ∅,
      2 ^ ((w - w₀) ^ 2 / (4 * Fintype.card ν)) ≤ t.size
```

### Proof Strategy

The BSW argument works via random restrictions:
1. Choose a random partial assignment ρ that sets each variable independently with probability 1 - p (for appropriate p).
2. Show that the restricted proof F|_ρ has expected width at most w₀ + p·n.
3. If the original proof is short (size s), the restricted proof has few clauses.
4. A proof with few clauses and low width has width ≤ w₀ + O(√(s·log s / n)).
5. Setting p appropriately and using the width lower bound gives s ≥ 2^(Ω((w-w₀)²/n)).

### Required New Definitions

- Random restrictions on CNF formulas and proof trees
- Restricted proof tree construction
- Width of a proof tree under restriction
- Probabilistic argument formalization (expected value over restrictions)

### Cross-Domain Significance

This would be the first machine-verified super-polynomial lower bound in proof complexity. Combined with our PHP width lower bound, it would yield a formal proof that PHP requires exponential-size resolution proofs — the Haken theorem via the BSW route. This connects to information theory (random restrictions as compression) and probability (expected value arguments in formal proofs).

---

## 2. Tseitin Formula Lower Bounds via Expansion

### Exact Theorem Statement

```lean
def TseitinCNF (G : SimpleGraph V) [DecidableEq V] [Fintype V]
    (charge : V → ZMod 2) : CNF (V × V) := ...

theorem tseitin_resolution_width_lb
    (G : SimpleGraph V) [DecidableEq V] [Fintype V]
    (charge : V → ZMod 2)
    (h_odd : ∑ v, charge v ≠ 0)
    (h_expand : ∀ S : Finset V, S.card ≤ Fintype.card V / 2 →
      (G.neighborFinset S).card ≥ expansion_constant * S.card) :
    ∀ t : ResTree (TseitinCNF G charge) ∅,
      expansion_constant * (Fintype.card V / 4) ≤ t.maxWidth
```

### Proof Strategy

1. Define Tseitin formulas: for each vertex v with neighbors u₁,...,uₖ, add clauses encoding x_{v,u₁} ⊕ ... ⊕ x_{v,uₖ} = charge(v).
2. Show unsatisfiability when the sum of charges is odd (parity argument).
3. Use the expansion property: any small set S of vertices has many neighbors.
4. Show that narrow clauses (width < expansion * |V|/4) can be satisfied by suitable partial assignments that respect the Tseitin structure locally.
5. Conclude width lower bound via the satisfiability argument.

### Required New Definitions

- Tseitin formula encoding (XOR constraints as CNF)
- Graph expansion constant
- Boundary and neighborhood in SimpleGraph
- Partial assignments respecting local parity

### Cross-Domain Significance

Tseitin formulas on expander graphs are a cornerstone of proof complexity. This would connect our framework to spectral graph theory (expansion implies hardness), coding theory (parity check matrices), and cryptography (hash function hardness). It would also demonstrate the generality of our resolution infrastructure beyond PHP.

---

## 3. CDCL Performance Theorem

### Exact Theorem Statement

```lean
/-- A CDCL run is a sequence of decisions, unit propagations, and clause learning steps. -/
structure CDCLRun (F : CNF ν) where
  decisions : List (ν × Bool)
  learned_clauses : List (Clause ν)
  all_learned_derivable : ∀ C ∈ learned_clauses, ResDerives F C

/-- CDCL derives a resolution refutation. -/
theorem cdcl_implements_resolution (F : CNF ν) (run : CDCLRun F)
    (h_unsat : run.derives_contradiction) :
    ResDerives F ∅

/-- CDCL on PHP must learn a wide clause. -/
theorem cdcl_php_learns_wide_clause (n : ℕ) (hn : 0 < n)
    (run : CDCLRun (phpCNF (n+1) n))
    (h_refutes : run.derives_contradiction) :
    ∃ C ∈ run.learned_clauses, n ≤ C.card
```

### Proof Strategy

1. Formalize the CDCL algorithm as a state machine with decision, propagation, conflict analysis, and backjumping.
2. Prove that CDCL clause learning implements resolution: each learned clause is the resolvent of clauses in the current conflict graph.
3. Show that the CDCL run produces a resolution refutation (the set of learned clauses, combined with original clauses, derives ∅).
4. Apply our width lower bound: since the resolution refutation has width ≥ n, some learned clause must have width ≥ n.

### Required New Definitions

- CDCL state machine (assignment trail, decision level, conflict graph)
- Clause learning via first-UIP scheme
- Implication graph and conflict analysis
- Backjumping

### Cross-Domain Significance

This would be the first formal connection between proof complexity lower bounds and SAT solver performance. It would prove that CDCL cannot efficiently solve PHP — not just by observing empirical performance, but by mathematical deduction from the width lower bound. This has implications for SAT solver engineering, automated reasoning, and formal verification of solver correctness.

---

## 4. Polynomial Calculus and Degree Lower Bounds

### Exact Theorem Statement

```lean
/-- A polynomial calculus proof derives polynomial identities over a field. -/
inductive PCDerives (F : List (MvPolynomial ν R)) : MvPolynomial ν R → Prop
  | hyp : p ∈ F → PCDerives F p
  | boolean : PCDerives F (X v ^ 2 - X v)
  | add : PCDerives F p → PCDerives F q → PCDerives F (p + q)
  | mul : PCDerives F p → PCDerives F (c * p)

/-- PHP requires high degree in polynomial calculus. -/
theorem php_pc_degree_lb (n : ℕ) :
    ∀ π : PCProof (phpPolynomials (n+1) n) 1,
      n / 2 ≤ π.maxDegree
```

### Proof Strategy

1. Define polynomial calculus over fields (coefficients, monomials, degree).
2. Encode PHP as polynomial equations: Σ_j x_{i,j} = 1 for each pigeon, x_{i,j} · x_{k,j} = 0 for collisions, x_{i,j}² = x_{i,j} for boolean-ness.
3. Use the Razborov degree lower bound argument: define a "design" — a linear functional that vanishes on low-degree consequences of PHP.
4. Show that such a functional exists using properties of matchings.

### Required New Definitions

- Multivariate polynomials (via Mathlib's MvPolynomial)
- Degree of a polynomial calculus proof
- PHP as polynomial equations
- Designs / dual witnesses for degree lower bounds

### Cross-Domain Significance

Polynomial calculus lower bounds connect to algebraic geometry (Nullstellensatz), commutative algebra (ideal membership), and algebraic complexity theory. This would extend our proof system hierarchy beyond resolution and cutting planes. The degree-width connection (Impagliazzo-Pudlák-Sgall) would link our resolution width lower bound to the PC degree lower bound.

---

## 5. Random k-SAT Phase Transition and Resolution Complexity

### Exact Theorem Statement

```lean
/-- A random k-CNF formula with n variables and m clauses. -/
def randomKCNF (k n m : ℕ) (seed : ℕ) : CNF (Fin n) := ...

/-- Above the satisfiability threshold, random k-SAT is hard for resolution. -/
theorem random_ksat_resolution_hardness
    (k : ℕ) (hk : 3 ≤ k) (n : ℕ) (r : ℝ)
    (hr : r > satisfiability_threshold k) :
    ∀ F : CNF (Fin n),
      isTypicalRandomKCNF k n (⌊r * n⌋) F →
      ∀ t : ResTree F ∅,
        2 ^ (n ^ (1 / (k-1) - ε)) ≤ t.size
```

### Proof Strategy

1. Define random k-CNF formula generation.
2. Formalize the Chvátal-Szemerédi argument: random k-CNF near the satisfiability threshold has high resolution complexity.
3. Key lemma: with high probability over the random formula, small sets of clauses have many variables in their "boundary" — this is the expansion property of random hypergraphs.
4. Apply the BSW width-size inequality (from Direction 1) with the expansion-based width lower bound.

### Required New Definitions

- Random k-CNF generation (uniform random k-subsets of variables, random polarities)
- Satisfiability threshold (α_k ≈ 2^k ln 2 for large k)
- Typical random formula properties (expansion, independence)
- Probabilistic combinatorics infrastructure

### Cross-Domain Significance

The random k-SAT phase transition is one of the deepest phenomena in computational complexity, connecting to statistical physics (spin glasses, replica symmetry breaking), probability theory (sharp thresholds), and algorithm design (random restart strategies). A formal proof complexity analysis of random k-SAT would bridge the gap between worst-case lower bounds (PHP, Tseitin) and average-case hardness that governs practical solver performance. This direction has direct implications for cryptography (random SAT as a source of hard instances) and machine learning (constraint satisfaction in neural architectures).

---

## Summary

| Direction | Key Theorem | Cross-Domain Impact |
|-----------|-------------|-------------------|
| 1. BSW Width-Size | Exponential size from linear width | Information theory, compression |
| 2. Tseitin | Expansion → width | Spectral graph theory, coding theory |
| 3. CDCL | Solver learns wide clauses | SAT engineering, verification |
| 4. Polynomial Calculus | Degree lower bound | Algebraic geometry, complexity |
| 5. Random k-SAT | Phase transition hardness | Statistical physics, cryptography |

Each direction builds directly on the infrastructure established in this work: the resolution proof system, width analysis, and proof tree formalization. The next cycle should begin with Direction 1 (BSW inequality) as it unlocks the full exponential lower bound, and Direction 3 (CDCL theorem) as it has the most immediate practical impact.
