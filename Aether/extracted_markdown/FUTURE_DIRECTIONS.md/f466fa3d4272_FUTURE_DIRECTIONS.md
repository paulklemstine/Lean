# Future Directions: Tropical Tree Automata and Compositional Min-Plus Semantics

This document outlines concrete next theorems and research directions opened by the formal verification of closure properties for weighted tree automata under tropical (min-plus) semantics.

---

## Direction 1: Tropical Determinization and Minimization for Tree Automata

### Exact Theorem Statement
For every weighted tree automaton `A` over a tropical semiring, there exists a **deterministic** weighted tree automaton `A_det` with at most exponentially many states such that `⟦A_det⟧(t) = ⟦A⟧(t)` for all trees `t`. Furthermore, every deterministic WTA admits a unique minimal equivalent WTA (up to isomorphism).

### Likely Lean Signature
```lean
theorem exists_deterministic_equivalent
    {σ : Type*} {arity : σ → ℕ} {Q : Type*}
    [Fintype Q] [Nonempty Q]
    (A : WTA σ arity Q) :
    ∃ (Q' : Type*) (_ : Fintype Q') (_ : Nonempty Q')
      (A' : DeterministicWTA σ arity Q'),
      ∀ t, eval_det A' t = eval A t

theorem minimal_deterministic_unique
    {σ : Type*} {arity : σ → ℕ}
    {Q₁ Q₂ : Type*} [Fintype Q₁] [Fintype Q₂]
    (A₁ : MinimalDeterministicWTA σ arity Q₁)
    (A₂ : MinimalDeterministicWTA σ arity Q₂)
    (h : ∀ t, eval_det A₁ t = eval_det A₂ t) :
    Fintype.card Q₁ = Fintype.card Q₂
```

### Proof Strategy
1. Define deterministic WTA as one where each node symbol and child-state assignment maps to a unique state (no infimum needed).
2. Use subset construction: states of `A_det` are functions `Q → ℝ` recording the cost of reaching each original state, quotiented by an equivalence.
3. Prove the Myhill-Nerode-style theorem for tropical tree languages to establish minimality.
4. Build on the existing `TropicalMyhillNerode.lean` in the catalog.

### Cross-Domain Significance
- **Compiler optimization**: Deterministic WTAs correspond to efficient single-pass tree traversals, foundational for optimizing compilers.
- **Dynamic programming**: Minimization reduces the state space of DP computations on syntax trees.
- **Learning theory**: Minimal automata are canonical representations, enabling grammatical inference for tree-structured data.

---

## Direction 2: Tropical Hadamard Product and Composition Closure

### Exact Theorem Statement
Given weighted tree automata `A₁, A₂` over the same ranked signature, there exists an automaton `A_had` such that for every tree `t`:
```
⟦A_had⟧(t) = ⟦A₁⟧(t) ⊗ ⟦A₂⟧(t) = ⟦A₁⟧(t) + ⟦A₂⟧(t)
```
(already proved) and furthermore, there exists `A_comp` for tree composition:
```
⟦A_comp⟧(t₁[t₂]) = ⟦A_comp⟧(composed tree)
```
where `t₁[t₂]` denotes the substitution of `t₂` into a designated leaf of `t₁`.

### Likely Lean Signature
```lean
theorem eval_composition
    {σ : Type*} {arity : σ → ℕ}
    {Q₁ Q₂ : Type*} [Fintype Q₁] [Nonempty Q₁] [Fintype Q₂] [Nonempty Q₂]
    (A₁ : WTA σ arity Q₁) (A₂ : WTA σ arity Q₂)
    (t₁ : ContextTree σ arity) (t₂ : RTree σ arity) :
    eval (compositionAutomaton A₁ A₂) (plug t₁ t₂) =
    evalContext A₁ t₁ (evalState A₂ t₂)
```

### Proof Strategy
1. Define `ContextTree` (trees with a hole) and `plug` (substitution).
2. Define `compositionAutomaton` with state space `Q₁ × Q₂`.
3. Prove by induction on `ContextTree`, using the product closure theorem at the plugging point.

### Cross-Domain Significance
- **Parsing**: Composition closure enables modular parser construction for context-free tree grammars.
- **Program analysis**: Compositional analysis of recursive programs via tree automata.
- **Operad theory**: Formally establishes that tropical WTAs form an algebra over the operad of trees.

---

## Direction 3: Tropical Spectral Theory for Tree Automata

### Exact Theorem Statement
For a weighted tree automaton `A` over a unary alphabet (linear chains), the evaluation semantics reduces to tropical matrix–vector multiplication, and the tropical eigenvalue of the transition matrix governs the asymptotic growth rate of `eval A` on chains of length `n`.

```
lim_{n→∞} (1/n) · eval A (chain n) = λ_trop(M_A)
```

where `λ_trop(M_A)` is the maximum cycle mean of the tropical transition matrix.

### Likely Lean Signature
```lean
theorem eval_chain_asymptotic
    {Q : Type*} [Fintype Q] [Nonempty Q]
    (A : WTA Unit (fun _ => 1) Q)
    (n : ℕ) :
    ∃ λ_trop : ℝ, ∀ ε > 0, ∃ N, ∀ n ≥ N,
      |eval A (chain n) / n - λ_trop| < ε

theorem tropical_eigenvalue_eq_cycle_mean
    {Q : Type*} [Fintype Q] [Nonempty Q]
    (A : WTA Unit (fun _ => 1) Q) :
    tropicalEigenvalue (transitionMatrix A) =
    maxCycleMean (transitionMatrix A)
```

### Proof Strategy
1. Restrict to unary trees (chains) and extract the transition matrix.
2. Prove the tropical Perron-Frobenius theorem for the transition matrix.
3. Connect the max cycle mean to the asymptotic growth rate using the CSR (critical graph) decomposition.
4. Build on existing `TropicalPathAlgebra.lean` in the catalog.

### Cross-Domain Significance
- **Performance analysis**: The tropical eigenvalue gives the throughput of recursive algorithms.
- **Queueing theory**: Tropical spectral theory governs max-plus linear systems arising in scheduling.
- **Complexity theory**: Connects automata state complexity to tropical algebraic complexity.

---

## Direction 4: Weighted MSO Logic and Tree Automata Equivalence

### Exact Theorem Statement
A tree series `S : RTree σ arity → ℝ` is tropical-recognizable (computed by some WTA) if and only if it is definable in weighted MSO logic over the tropical semiring.

### Likely Lean Signature
```lean
theorem wmso_iff_wta_recognizable
    {σ : Type*} {arity : σ → ℕ}
    (S : RTree σ arity → ℝ) :
    WMSODefinable S ↔ WTARecognizable S
```

### Proof Strategy
1. Define weighted MSO (WMSO) formulas over the tropical semiring.
2. Prove the forward direction: WMSO → WTA (by structural induction on formulas, using closure under product, union, and projection).
3. Prove the backward direction: WTA → WMSO (by encoding the run of a WTA as an MSO formula with tropical weights).
4. The closure theorems proved in this work are essential building blocks for the forward direction.

### Cross-Domain Significance
- **Verification**: Enables specification of tree cost properties in logic and automatic synthesis of automata.
- **Database theory**: Connects to cost-annotated query evaluation on tree-structured data.
- **Model theory**: Extends the classical Büchi-Elgot-Trakhtenbrot theorem to the weighted setting.

---

## Direction 5: Certified Tropical Parsing via Tree Automata

### Exact Theorem Statement
Given a weighted context-free grammar `G` with tropical weights, the CYK parsing algorithm correctly computes the minimum-cost parse tree, and this cost equals the evaluation of the canonical WTA associated to `G`.

### Likely Lean Signature
```lean
theorem cyk_correct
    {σ : Type*} {arity : σ → ℕ}
    (G : WeightedCFG σ)
    (w : List (Terminal σ)) :
    cykMinCost G w = eval (cfgToWTA G) (optimalParseTree G w)

theorem cfgToWTA_preserves_language
    {σ : Type*} {arity : σ → ℕ}
    (G : WeightedCFG σ)
    (t : RTree σ arity) :
    yieldCost G t = eval (cfgToWTA G) t
```

### Proof Strategy
1. Define weighted CFGs and the CYK dynamic programming algorithm.
2. Construct the canonical WTA from a CFG (states = nonterminals, transitions = productions).
3. Prove that CYK's DP table entries correspond to `evalState` of the WTA.
4. Use the product closure theorem to show that multi-objective parsing (optimizing multiple criteria) can be done via product automata.

### Cross-Domain Significance
- **Natural language processing**: Verified parsing algorithms for probabilistic/weighted grammars.
- **Bioinformatics**: RNA secondary structure prediction uses CYK-style algorithms on trees.
- **Verified compilers**: Certified cost analysis for parse-tree-based compiler phases.

---

## Meta-Direction: Building a Verified Tropical Algebra Library

The theorems proved here establish the first formally verified building blocks of a **tropical algebra of tree cost functions**. The natural next step is to build this into a comprehensive library:

1. **Tropical semiring typeclass hierarchy**: Formalize `TropicalSemiring`, `CompleteTropicalSemiring`, and their instances for `ℝ`, `ℝ≥0∞`, `WithTop ℝ`, `Tropical α`.
2. **Weighted automata over general semirings**: Generalize WTA from `ℝ` to arbitrary semirings, recovering boolean, probabilistic, and tropical automata as instances.
3. **Functor between automata and algebras**: Formalize the categorical equivalence between WTA and Σ-algebras in the tropical semiring, establishing automata as algebraic objects.
4. **Verified algorithms**: Implement and verify algorithms for WTA evaluation, determinization, minimization, and intersection, with complexity bounds.

This library would serve as the foundation for verified tropical computation across parsing, optimization, and machine learning.
