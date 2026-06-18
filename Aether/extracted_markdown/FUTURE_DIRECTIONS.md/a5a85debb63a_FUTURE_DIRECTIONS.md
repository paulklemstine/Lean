# Future Directions

## 1. Transfinite Stratification for Non-Guarded Feedback

**Goal**: Extend the ω-chain convergence theorem to transfinite ordinal-indexed chains for well-founded but non-guarded feedback loops.

**Candidate theorem**:
```lean
theorem transfinite_kleene_lfp
    {α : Type*} [CompleteLattice α]
    {f : α → α} (hf : Monotone f) :
    sSup (Set.range (fun o : Ordinal => ordinalIterate f o ⊥)) = sInf {x | f x ≤ x}
```

**Interface**: Define `ordinalIterate f o ⊥` by transfinite recursion (successor = apply f, limit = sSup of prior stages). The key new ingredient is the closure ordinal theorem: every monotone function on a complete lattice of cardinality κ stabilizes by ordinal κ⁺. This would subsume the current ω-chain theory and handle circuits with unbounded but well-founded delay structures.

## 2. Tropical Bellman Fixed-Point Correspondence

**Goal**: Prove a bidirectional theorem connecting reversible trace invariants in the order-enriched setting with Bellman optimality equations in tropical (min-plus) semirings.

**Candidate theorem**:
```lean
theorem tropical_trace_eq_bellman_value
    {n : ℕ} (W : Fin n → Fin n → Tropical ℝ)
    (src tgt : Fin n)
    (hguarded : ∀ i j, W i j ≠ ⊤) :
    tropicalTrace W src tgt = bellmanIterate W src tgt n
```

**Interface**: Define `tropicalTrace` as the traced morphism in the category of matrices over `Tropical ℝ`, and `bellmanIterate` as the n-step Bellman iteration (shortest-path dynamic programming). The theorem says the category-theoretic trace equals the dynamic programming solution. This links the Lawvere–Kleene stratification to classical shortest-path algorithms and opens tropical geometry applications.

## 3. Certified Stabilization Bound Detection

**Goal**: Extract a verified algorithm that computes or bounds the stabilization index N for a guarded circuit, turning the collapse theorem into a practical tool.

**Candidate theorem**:
```lean
theorem stabilization_bound_decidable
    {α : Type*} [CompleteLattice α] [DecidableEq α]
    (step : α → α) (hstep : OmegaScottContinuous step)
    (hfin : Finite {x : α | ∃ n, x = step^[n] ⊥}) :
    ∃ N : ℕ, step^[N + 1] ⊥ = step^[N] ⊥ ∧
      ∀ M, step^[M + 1] ⊥ = step^[M] ⊥ → N ≤ M
```

**Interface**: Given a computable step function on a finite domain with decidable equality, find the minimal stabilization index. This would produce certified loop bounds for hardware verification of reversible circuits, with direct applications to RTL synthesis and model checking.

## 4. Uniqueness via Guardedness: When Least = Only

**Goal**: Formalize conditions under which the least temporal invariant is also the unique fixed point, and when it additionally preserves reversibility (isomorphism structure).

**Candidate theorem**:
```lean
theorem guarded_unique_fixed_point
    {α : Type*} [CompleteLattice α]
    (step : α → α) (hcont : OmegaScottContinuous step)
    (hcontractive : ∀ x y, step x = step y → x = y) :
    ∀ x, step x = x → x = sSup (Set.range (fun n => step^[n] ⊥))
```

**Interface**: Under injectivity (a form of "guardedness" or "contractivity"), every fixed point equals the Kleene fixed point. This captures when reversibility constraints force uniqueness of the temporal invariant. A stronger version would require `step` to be an order-isomorphism on its range, yielding a reversible fixed-point theorem.

## 5. Denotational Models of Quantum/Thermodynamic Reversibility

**Goal**: Link the stratified trace semantics to quantum channel fixed points and thermodynamic reversibility constraints.

**Candidate interface**:
```lean
structure QuantumTracedChannel (n : ℕ) where
  channel : Matrix (Fin n) (Fin n) ℂ → Matrix (Fin n) (Fin n) ℂ
  completely_positive : CompletelyPositive channel
  trace_preserving : TracePreserving channel
  fixed_state : Matrix (Fin n) (Fin n) ℂ
  is_fixed : channel fixed_state = fixed_state
  is_kleene_limit :
    fixed_state = sSup (Set.range (fun k => channel^[k] 0))
```

**Theorem target**: For a quantum channel Φ with a spectral gap (all non-trivial eigenvalues have modulus < 1), the Kleene chain Φ^[n](0) converges to the unique fixed state, and finite stabilization corresponds to the channel having finite mixing time. This connects the order-theoretic stratification to quantum error correction (syndrome extraction as traced feedback) and thermodynamic equilibrium (detailed balance as reversible trace).

---

Each direction extends the core contribution — that traced invariants are computable ω-limits of finite approximants — into a new domain. Directions 1-2 are pure mathematics; 3 is algorithmic; 4-5 bridge to physics and quantum computing.
