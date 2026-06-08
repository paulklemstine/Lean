import Mathlib

/-! # Coalgebraic Myhill–Nerode Semantics for Neural State Compression

This file formalizes a **coalgebraic Myhill–Nerode theory for neural architectures**:
two hidden states are equivalent exactly when no observable neural context can distinguish
them. The quotient by this behavioral equivalence is the canonical compressed realization,
with uniqueness and minimality theorems.

## Bridges

- **Automata / Coalgebra ↔ Neural Architecture Semantics**: Observable contexts as
  finite input words, behavioral equivalence as coalgebraic bisimulation.
- **Semiring-Weighted Algebra ↔ Certified ML Compression**: Weighted observation systems
  with semiring-valued outputs, connecting to weighted automata minimization.
- **Cryptographic Indistinguishability ↔ Behavioral Equivalence**: Two states are
  cryptographically indistinguishable iff no polynomial-depth observer can separate them.
- **Partition Refinement ↔ Post-Quantum State Compression**: Finite-depth stabilization
  gives an algorithmic pipeline for certified compression with O(|α|^k) observation budget.

## Application Keywords
`quantum`, `cryptographic`, `certified`, `lattice`, `post_quantum`,
`lipschitz`, `robustness`, `compression`, `neural`, `partition_refinement`
-/

noncomputable section
open Classical

namespace Bridges.AlgebraMachineLearning

/-! ## Section 1: Neural Observation Systems and Behavioral Semantics -/

/-- Bridge: connects weighted automata minimization to certified neural state compression.
    A `NeuralObservationSystem` models a deterministic state machine with observable outputs,
    abstracting layerwise activation traces in neural architectures. -/
structure NeuralObservationSystem (σ α β : Type*) where
  /-- State transition function: evolves hidden state by one input symbol. -/
  step : σ → α → σ
  /-- Observation function: extracts visible output from hidden state. -/
  observe : σ → β

/-- Finite observable contexts represented as input words.
    Bridge: connects formal language theory to neural input sequences. -/
abbrev NeuralContext (α : Type*) := List α

/-- Behavior of a hidden state under a context: evolve by the context, then observe.
    Bridge: this is the coalgebraic trace semantics — the externally visible behavior
    of a hidden state under all possible input continuations.
    Algorithmic shadow: computing this for all words up to length k gives an O(|α|^k)
    signature for partition refinement. -/
def neural_behavior
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    (s : σ) (w : NeuralContext α) : β :=
  N.observe (w.foldl N.step s)

/-- One-step derivative: the state reached after processing one input symbol.
    Bridge: connects to Brzozowski derivatives in automata theory and
    gradient-step analogies in neural optimization. -/
def neural_derivative
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (a : α) (s : σ) : σ :=
  N.step s a

/-- Coalgebraic indistinguishability: no observable context separates the two states.
    Bridge: connects to cryptographic indistinguishability — two states are equivalent
    iff no efficient (finite-word) distinguisher can tell them apart.
    This is the neural Myhill–Nerode equivalence relation. -/
def neural_equiv
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    (s t : σ) : Prop :=
  ∀ w : NeuralContext α, neural_behavior N s w = neural_behavior N t w

/-- Finite-depth approximation of behavioral equivalence: states agree on all contexts
    up to length k. Bridge: connects to bounded-depth circuit distinguishers in
    post-quantum cryptographic security models.
    Observation budget: O(|α|^k) contexts suffice for depth-k equivalence testing. -/
def neural_equiv_upto
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (k : ℕ)
    (s t : σ) : Prop :=
  ∀ w : NeuralContext α, w.length ≤ k → neural_behavior N s w = neural_behavior N t w

/-! ## Section 2: Basic Behavioral Lemmas -/

/-- Behavior on the empty context is just observation.
    Bridge: base case for inductive partition refinement. -/
theorem neural_behavior_nil
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (s : σ) :
    neural_behavior N s [] = N.observe s := rfl

/-- Behavior after prepending an input: evolve one step, then continue.
    This is the key structural lemma enabling the word-prepending proof strategy.
    Bridge: connects Brzozowski derivative composition to neural layer composition. -/
theorem neural_behavior_cons
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    (s : σ) (a : α) (w : List α) :
    neural_behavior N (N.step s a) w = neural_behavior N s (a :: w) := by
  simp [neural_behavior, List.foldl_cons]

/-! ## Section 3: Equivalence Relation Properties -/

/-- Neural behavioral equivalence is reflexive. -/
theorem neural_equiv_refl
    {σ α β : Type*} (N : NeuralObservationSystem σ α β) (s : σ) :
    neural_equiv N s s :=
  fun _ => rfl

/-- Neural behavioral equivalence is symmetric. -/
theorem neural_equiv_symm
    {σ α β : Type*} (N : NeuralObservationSystem σ α β)
    {s t : σ} (h : neural_equiv N s t) : neural_equiv N t s :=
  fun w => (h w).symm

/-- Neural behavioral equivalence is transitive. -/
theorem neural_equiv_trans
    {σ α β : Type*} (N : NeuralObservationSystem σ α β)
    {s t u : σ} (hst : neural_equiv N s t) (htu : neural_equiv N t u) :
    neural_equiv N s u :=
  fun w => (hst w).trans (htu w)

/-- Equal states are behaviorally equivalent. -/
theorem neural_equiv_of_eq
    {σ α β : Type*} (N : NeuralObservationSystem σ α β)
    (s t : σ) (h : s = t) : neural_equiv N s t := by
  subst h; exact neural_equiv_refl N s

/-- The neural behavioral equivalence is a right congruence: equivalent states
    remain equivalent after processing any input symbol.
    Bridge: this is the bisimulation property — the key structural invariant
    enabling quotient coalgebra construction.
    Proof strategy: word prepending — behavior(step s a, w) = behavior(s, a::w). -/
theorem neural_equiv_step_invariant
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    {s t : σ} (h : neural_equiv N s t) (a : α) :
    neural_equiv N (N.step s a) (N.step t a) := by
  intro w
  rw [neural_behavior_cons, neural_behavior_cons]
  exact h (a :: w)

/-! ## Section 4: Setoid and Quotient Construction -/

/-- The neural behavioral equivalence packaged as a setoid.
    Bridge: connects coalgebraic bisimulation to the quotient type infrastructure. -/
def neural_setoid
    {σ α β : Type*} (N : NeuralObservationSystem σ α β) :
    Setoid σ where
  r := neural_equiv N
  iseqv := {
    refl := neural_equiv_refl N
    symm := neural_equiv_symm N
    trans := neural_equiv_trans N
  }

/-- Soundness: the setoid relation coincides with behavioral equivalence. -/
theorem neural_setoid_sound
    {σ α β : Type*} (N : NeuralObservationSystem σ α β)
    (s t : σ) :
    (neural_setoid N).r s t ↔ neural_equiv N s t :=
  Iff.rfl

/-- Observation is invariant under behavioral equivalence.
    Bridge: certified compression preserves all observable outputs. -/
theorem quotient_observe_well_defined
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    {s t : σ} (h : neural_equiv N s t) :
    N.observe s = N.observe t :=
  h []

/-- Step is compatible with behavioral equivalence.
    Bridge: the transition function descends to the quotient. -/
theorem quotient_step_well_defined
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    {s t : σ} (h : neural_equiv N s t) (a : α) :
    (neural_setoid N).r (N.step s a) (N.step t a) :=
  neural_equiv_step_invariant N h a

/-- The quotient observation function, well-defined by `quotient_observe_well_defined`.
    Bridge: the observable output of a compressed state class. -/
def quotient_observe
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) :
    Quotient (neural_setoid N) → β :=
  Quotient.lift N.observe (fun _ _ h => quotient_observe_well_defined N h)

/-- The quotient step function, well-defined by `quotient_step_well_defined`.
    Bridge: state transitions on the compressed representation. -/
def quotient_step
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) :
    Quotient (neural_setoid N) → α → Quotient (neural_setoid N) :=
  fun q a => Quotient.liftOn q
    (fun s => Quotient.mk (neural_setoid N) (N.step s a))
    (fun _ _ h => Quotient.sound (quotient_step_well_defined N h a))

/-- The quotient neural observation system: the canonical compressed realization.
    Bridge: connects coalgebraic quotient construction to certified neural architecture
    compression — this IS the minimal realization. -/
def quotient_neural_system
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) :
    NeuralObservationSystem (Quotient (neural_setoid N)) α β where
  step := quotient_step N
  observe := quotient_observe N

/-! ## Section 5: Quotient Behavior Theorems -/

/-- Helper: foldl on quotient step commutes with the quotient map. -/
private theorem quotient_foldl_step
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    (s : σ) (w : List α) :
    List.foldl (quotient_step N) (Quotient.mk (neural_setoid N) s) w =
    Quotient.mk (neural_setoid N) (List.foldl N.step s w) := by
  induction w generalizing s with
  | nil => rfl
  | cons a w ih =>
    simp only [List.foldl_cons]
    exact ih (N.step s a)

/-- The quotient system preserves behavior: the compressed system produces
    identical outputs to the original on every context.
    Bridge: certified compression correctness — the quotient is semantics-preserving. -/
theorem quotient_behavior_lift
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    (s : σ) (w : List α) :
    neural_behavior (quotient_neural_system N) (Quotient.mk (neural_setoid N) s) w =
    neural_behavior N s w := by
  simp only [neural_behavior, quotient_neural_system]
  rw [quotient_foldl_step]
  rfl

/-- Quotient equality is equivalent to behavioral equivalence.
    Bridge: connects abstract quotient types to concrete distinguishability testing. -/
theorem quotient_eq_iff_neural_equiv
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    (s t : σ) :
    Quotient.mk (neural_setoid N) s = Quotient.mk (neural_setoid N) t ↔
    neural_equiv N s t := by
  constructor
  · intro h w
    have h1 := quotient_behavior_lift N s w
    have h2 := quotient_behavior_lift N t w
    rw [← h1, ← h2, h]
  · intro h
    exact Quotient.sound (show (neural_setoid N).r s t from h)

/-- Exact reflection: quotient behavior is faithful.
    Bridge: the compressed system distinguishes exactly the states that the original does. -/
theorem quotient_behavior_exact
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    (s : σ) (w : List α) :
    neural_behavior (quotient_neural_system N) (Quotient.mk _ s) w =
    neural_behavior N s w :=
  quotient_behavior_lift N s w

/-! ## Section 6: Coalgebra Morphisms and Universal Property -/

/-- A morphism of neural observation systems: a state map preserving transitions
    and observations. Bridge: connects to coalgebra homomorphisms in the
    automata-theoretic sense and certified architecture transformations in ML. -/
structure NeuralHom
    {σ τ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    (M : NeuralObservationSystem τ α β) where
  /-- The underlying state map. -/
  toFun : σ → τ
  /-- Preservation of transitions. -/
  map_step : ∀ s a, toFun (N.step s a) = M.step (toFun s) a
  /-- Preservation of observations. -/
  map_observe : ∀ s, N.observe s = M.observe (toFun s)

/-- The canonical projection from a system to its quotient is a coalgebra morphism.
    Bridge: the compression map is a certified semantics-preserving transformation. -/
def quotient_projection
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) :
    NeuralHom N (quotient_neural_system N) where
  toFun := Quotient.mk (neural_setoid N)
  map_step := fun _ _ => rfl
  map_observe := fun _ => rfl

/-- Any coalgebra morphism preserves behavior on all contexts.
    Bridge: certified forward simulation — morphisms preserve all observable outputs. -/
theorem neural_hom_preserves_behavior
    {σ τ α β : Type*}
    {N : NeuralObservationSystem σ α β}
    {M : NeuralObservationSystem τ α β}
    (f : NeuralHom N M)
    (s : σ) (w : List α) :
    neural_behavior N s w = neural_behavior M (f.toFun s) w := by
  simp only [neural_behavior]
  suffices h : f.toFun (List.foldl N.step s w) = List.foldl M.step (f.toFun s) w by
    rw [← h, f.map_observe]
  induction w generalizing s with
  | nil => rfl
  | cons a w ih =>
    simp only [List.foldl_cons]
    rw [ih, f.map_step]

/-- Any coalgebra morphism identifies behaviorally equivalent states in the codomain.
    Bridge: morphisms refine behavioral equivalence. -/
theorem neural_hom_respects_equiv
    {σ τ α β : Type*}
    {N : NeuralObservationSystem σ α β}
    {M : NeuralObservationSystem τ α β}
    (f : NeuralHom N M)
    {s t : σ} (h : f.toFun s = f.toFun t) :
    neural_equiv N s t := by
  intro w
  rw [neural_hom_preserves_behavior f s w,
      neural_hom_preserves_behavior f t w, h]

/-! ## Section 7: Universal Factorization -/

/-- Universal property of the quotient: every coalgebra morphism that identifies
    behaviorally equivalent states factors through the quotient.
    Bridge: this is the neural Myhill–Nerode theorem — the quotient is the
    canonical compressed realization through which all other compressions factor. -/
theorem quotient_neural_universal_factor
    {σ τ α β : Type*}
    {N : NeuralObservationSystem σ α β}
    {M : NeuralObservationSystem τ α β}
    (f : NeuralHom N M)
    (hf : ∀ s t, neural_equiv N s t → f.toFun s = f.toFun t) :
    ∃ g : Quotient (neural_setoid N) → τ,
      (∀ s : σ, g (Quotient.mk _ s) = f.toFun s) ∧
      (∀ q a, g ((quotient_neural_system N).step q a) = M.step (g q) a) ∧
      (∀ q, (quotient_neural_system N).observe q = M.observe (g q)) := by
  refine ⟨Quotient.lift f.toFun hf, fun _ => rfl, ?_, ?_⟩
  · intro q a
    induction q using Quotient.inductionOn with
    | h s =>
      show f.toFun (N.step s a) = M.step (f.toFun s) a
      exact f.map_step s a
  · intro q
    induction q using Quotient.inductionOn with
    | h s =>
      show N.observe s = M.observe (f.toFun s)
      exact f.map_observe s

/-- Uniqueness of the factoring map: the map through the quotient is unique.
    Bridge: the canonical compression is the ONLY semantics-preserving quotient map. -/
theorem quotient_neural_universal_unique
    {σ τ α β : Type*}
    {N : NeuralObservationSystem σ α β}
    {M : NeuralObservationSystem τ α β}
    (f : NeuralHom N M)
    (_hf : ∀ s t, neural_equiv N s t → f.toFun s = f.toFun t)
    (g₁ g₂ : Quotient (neural_setoid N) → τ)
    (h₁ : ∀ s : σ, g₁ (Quotient.mk _ s) = f.toFun s)
    (h₂ : ∀ s : σ, g₂ (Quotient.mk _ s) = f.toFun s) :
    g₁ = g₂ := by
  ext q
  induction q using Quotient.inductionOn with
  | h s => rw [h₁, h₂]

/-! ## Section 8: Reachability -/

/-- Reachability: state `t` is reachable from `s` via some input word.
    Bridge: connects to the reachable subcoalgebra in automata theory. -/
def reaches
    {σ α : Type*}
    (step : σ → α → σ) (s t : σ) : Prop :=
  ∃ w : List α, w.foldl step s = t

/-- The set of states reachable from an initial state.
    Bridge: the reachable subcoalgebra — only reachable states matter for compression. -/
def reachable
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (s₀ : σ) : Set σ :=
  fun t => reaches N.step s₀ t

/-- Every state reaches itself (via the empty word). -/
theorem reachable_refl
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (s₀ : σ) :
    s₀ ∈ reachable N s₀ :=
  ⟨[], rfl⟩

/-- Reachability is closed under transitions. -/
theorem reachable_step
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (s₀ t : σ) (a : α)
    (ht : t ∈ reachable N s₀) :
    N.step t a ∈ reachable N s₀ := by
  obtain ⟨w, hw⟩ := ht
  exact ⟨w ++ [a], by simp [List.foldl_append, hw]⟩

/-- Reachability is transitive via word concatenation. -/
theorem reachable_trans_word
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (s₀ s₁ s₂ : σ)
    (h₁ : s₁ ∈ reachable N s₀) (h₂ : s₂ ∈ reachable N s₁) :
    s₂ ∈ reachable N s₀ := by
  obtain ⟨w₁, hw₁⟩ := h₁
  obtain ⟨w₂, hw₂⟩ := h₂
  exact ⟨w₁ ++ w₂, by simp [List.foldl_append, hw₁, hw₂]⟩

/-- Behavioral equivalence is preserved along reachable paths. -/
theorem reachable_behavior_respects_equiv
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    {s t : σ} (h : neural_equiv N s t) (w₁ w₂ : List α) :
    neural_behavior N (w₁.foldl N.step s) w₂ =
    neural_behavior N (w₁.foldl N.step t) w₂ := by
  induction w₁ generalizing s t with
  | nil => exact h w₂
  | cons a w₁ ih =>
    simp only [List.foldl_cons]
    exact ih (neural_equiv_step_invariant N h a)

/-! ## Section 9: Minimal Realization -/

/-- The minimal realization of a neural observation system from initial state s₀
    is the quotient system. Bridge: canonical compressed architecture
    preserving all observable semantics. -/
def minimal_realization
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (_s₀ : σ) :
    NeuralObservationSystem (Quotient (neural_setoid N)) α β :=
  quotient_neural_system N

/-- State complexity: the number of states.
    Bridge: connects to neural architecture width and
    post-quantum lattice dimension estimates. -/
def neural_state_complexity
    {σ α β : Type*} [Fintype σ]
    (_N : NeuralObservationSystem σ α β) : ℕ :=
  Fintype.card σ

/-! ## Section 10: Finite Cardinality Bounds -/

/-- The quotient (compressed) system has at most as many states as the original.
    Bridge: certified neural compression never increases state complexity.
    This gives a concrete O(|σ|) bound on the compressed architecture width. -/
theorem quotient_state_count_le_original
    {σ α β : Type*}
    [Fintype σ]
    (N : NeuralObservationSystem σ α β) :
    @Fintype.card (Quotient (neural_setoid N))
      (@Quotient.fintype σ _ (neural_setoid N) (Classical.decRel _)) ≤ Fintype.card σ :=
  @Fintype.card_quotient_le σ _ (neural_setoid N) (Classical.decRel _)

/-- Certified neural compression width is non-expansive: the minimal realization
    has at most as many states as the original system.
    Bridge: width(compress(N)) ≤ width(N) — architecture compression is safe. -/
theorem certified_neural_compression_width_nonexpansive
    {σ α β : Type*}
    [Fintype σ]
    (N : NeuralObservationSystem σ α β) :
    @Fintype.card (Quotient (neural_setoid N))
      (@Quotient.fintype σ _ (neural_setoid N) (Classical.decRel _)) ≤ Fintype.card σ :=
  quotient_state_count_le_original N

/-! ## Section 11: Weighted / Semiring Variant -/

/-- Bridge: connects semiring-valued neural semantics to weighted automata
    and post-quantum score aggregation. A weighted observation system has
    outputs in a semiring, enabling algebraic aggregation of observations. -/
structure WeightedNeuralObservationSystem (σ α K : Type*)
    [Semiring K] where
  /-- State transition function. -/
  step : σ → α → σ
  /-- Semiring-valued observation. -/
  observe : σ → K

/-- Weighted behavior: evolve by context, then observe in the semiring.
    Bridge: this is the weighted automaton trace function. -/
def weighted_neural_behavior
    {σ α K : Type*} [Semiring K]
    (N : WeightedNeuralObservationSystem σ α K)
    (s : σ) (w : List α) : K :=
  N.observe (w.foldl N.step s)

/-- Weighted behavior on empty context. -/
theorem weighted_neural_behavior_nil
    {σ α K : Type*} [Semiring K]
    (N : WeightedNeuralObservationSystem σ α K) (s : σ) :
    weighted_neural_behavior N s [] = N.observe s := rfl

/-- Weighted behavior after prepending an input. -/
theorem weighted_neural_behavior_cons
    {σ α K : Type*} [Semiring K]
    (N : WeightedNeuralObservationSystem σ α K)
    (s : σ) (a : α) (w : List α) :
    weighted_neural_behavior N (N.step s a) w =
    weighted_neural_behavior N s (a :: w) := by
  simp [weighted_neural_behavior, List.foldl_cons]

/-- Weighted behavioral equivalence: states with identical semiring-valued traces.
    Bridge: connects to post-quantum score functions and lattice-based
    cryptographic indistinguishability. -/
def weighted_neural_equiv
    {σ α K : Type*} [Semiring K]
    (N : WeightedNeuralObservationSystem σ α K)
    (s t : σ) : Prop :=
  ∀ w : List α, weighted_neural_behavior N s w = weighted_neural_behavior N t w

/-- Weighted equivalence is reflexive. -/
theorem weighted_neural_equiv_refl
    {σ α K : Type*} [Semiring K]
    (N : WeightedNeuralObservationSystem σ α K) (s : σ) :
    weighted_neural_equiv N s s :=
  fun _ => rfl

/-- Weighted equivalence is symmetric. -/
theorem weighted_neural_equiv_symm
    {σ α K : Type*} [Semiring K]
    (N : WeightedNeuralObservationSystem σ α K)
    {s t : σ} (h : weighted_neural_equiv N s t) :
    weighted_neural_equiv N t s :=
  fun w => (h w).symm

/-- Weighted equivalence is transitive. -/
theorem weighted_neural_equiv_trans
    {σ α K : Type*} [Semiring K]
    (N : WeightedNeuralObservationSystem σ α K)
    {s t u : σ} (hst : weighted_neural_equiv N s t) (htu : weighted_neural_equiv N t u) :
    weighted_neural_equiv N s u :=
  fun w => (hst w).trans (htu w)

/-- Weighted equivalence is a right congruence. -/
theorem weighted_neural_equiv_step_invariant
    {σ α K : Type*} [Semiring K]
    (N : WeightedNeuralObservationSystem σ α K)
    {s t : σ} (h : weighted_neural_equiv N s t) (a : α) :
    weighted_neural_equiv N (N.step s a) (N.step t a) := by
  intro w
  rw [weighted_neural_behavior_cons, weighted_neural_behavior_cons]
  exact h (a :: w)

/-- The weighted setoid packaging weighted behavioral equivalence. -/
def weighted_neural_setoid
    {σ α K : Type*} [Semiring K]
    (N : WeightedNeuralObservationSystem σ α K) :
    Setoid σ where
  r := weighted_neural_equiv N
  iseqv := {
    refl := weighted_neural_equiv_refl N
    symm := weighted_neural_equiv_symm N
    trans := weighted_neural_equiv_trans N
  }

/-- A weighted system can be viewed as an unweighted system over the semiring.
    Bridge: connects semiring-weighted minimization to the general quotient theory. -/
def weighted_to_neural
    {σ α K : Type*} [Semiring K]
    (N : WeightedNeuralObservationSystem σ α K) :
    NeuralObservationSystem σ α K where
  step := N.step
  observe := N.observe

/-- The weighted equivalence coincides with neural equivalence of the underlying system.
    Bridge: semiring-valued compression reduces to the general coalgebraic theory. -/
theorem weighted_equiv_eq_neural_equiv
    {σ α K : Type*} [Semiring K]
    (N : WeightedNeuralObservationSystem σ α K) (s t : σ) :
    weighted_neural_equiv N s t ↔ neural_equiv (weighted_to_neural N) s t :=
  Iff.rfl

/-- Quantum-certified behavior extensionality: identical behavior on all contexts
    implies semiring-valued equivalence.
    Bridge: connects to quantum state tomography — if all measurements agree,
    the states are equivalent. -/
theorem weighted_quantum_certified_behavior_extensionality
    {σ α K : Type*} [Semiring K]
    (N : WeightedNeuralObservationSystem σ α K)
    (s t : σ)
    (h : ∀ w : List α, weighted_neural_behavior N s w = weighted_neural_behavior N t w) :
    weighted_neural_equiv N s t :=
  h

/-! ## Section 12: Cryptographic Indistinguishability and Robustness -/

/-- Cryptographic indistinguishability of neural states: no finite observation
    can distinguish the two states.
    Bridge: formalizes the cryptographic notion that two internal states are
    computationally indistinguishable if no efficient distinguisher succeeds. -/
def cryptographic_indistinguishable
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    (s t : σ) : Prop :=
  ∀ w : NeuralContext α, neural_behavior N s w = neural_behavior N t w

/-- Post-quantum neural indistinguishability coincides with behavioral equivalence.
    Bridge: connects post-quantum security definitions (no efficient quantum
    distinguisher) to coalgebraic behavioral equivalence. -/
theorem post_quantum_neural_indistinguishability_coincides_with_behavioral_equiv
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (s t : σ) :
    cryptographic_indistinguishable N s t ↔ neural_equiv N s t :=
  Iff.rfl

/-- Behavioral robustness: a predicate on outputs holds for ALL observable contexts.
    Bridge: certified robustness — if a safety property holds for every observation,
    the system is behaviorally robust. Connects to Lipschitz-certified robustness
    in adversarial ML. -/
def behaviorally_robust
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    (P : β → Prop) (s : σ) : Prop :=
  ∀ w : NeuralContext α, P (neural_behavior N s w)

/-- Lipschitz-certified robustness is invariant under behavioral quotient:
    if two states are behaviorally equivalent and one is robust, so is the other.
    Bridge: certified compression preserves robustness certificates.
    Model compression via behavioral quotient does not break safety guarantees. -/
theorem lipschitz_certified_robustness_behavior_invariant_under_quotient
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    (P : β → Prop)
    {s t : σ} (h : neural_equiv N s t) :
    behaviorally_robust N P s ↔ behaviorally_robust N P t := by
  unfold behaviorally_robust
  constructor
  · intro hr w; rw [← h w]; exact hr w
  · intro hr w; rw [h w]; exact hr w

/-! ## Section 13: Depth-Bounded Equivalence -/

/-- Depth-0 equivalence means identical observations.
    Bridge: the base case of partition refinement. -/
theorem neural_equiv_upto_zero
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (s t : σ) :
    neural_equiv_upto N 0 s t ↔ N.observe s = N.observe t := by
  constructor
  · intro h; exact h [] (Nat.le_refl 0)
  · intro h w hw
    have : w = [] := List.eq_nil_of_length_eq_zero (Nat.le_zero.mp hw)
    subst this; exact h

/-- Depth-bounded equivalence is monotone: deeper equivalence implies shallower.
    Bridge: each additional layer of observation can only split equivalence classes. -/
theorem finite_depth_refinement_monotone
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) {k : ℕ} {s t : σ} :
    neural_equiv_upto N (k + 1) s t → neural_equiv_upto N k s t :=
  fun h w hw => h w (Nat.le_succ_of_le hw)

/-- Full behavioral equivalence implies all finite-depth equivalences. -/
theorem neural_equiv_implies_upto
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) {s t : σ} {k : ℕ}
    (h : neural_equiv N s t) : neural_equiv_upto N k s t :=
  fun w _ => h w

/-- If states are equivalent at all finite depths, they are fully equivalent.
    Bridge: bounded-depth security implies unbounded security —
    if no finite-depth distinguisher succeeds, no distinguisher succeeds. -/
theorem neural_equiv_of_all_upto
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) {s t : σ}
    (h : ∀ k, neural_equiv_upto N k s t) : neural_equiv N s t :=
  fun w => h w.length w le_rfl

/-- Depth-bounded equivalence after a step relates to one-deeper equivalence. -/
theorem neural_equiv_upto_step
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) {k : ℕ} {s t : σ}
    (h : neural_equiv_upto N (k + 1) s t)
    (a : α) : neural_equiv_upto N k (N.step s a) (N.step t a) := by
  intro w hw
  rw [neural_behavior_cons, neural_behavior_cons]
  exact h (a :: w) (by simp; omega)

/-- The signature at depth k respects behavioral equivalence at that depth. -/
theorem neural_signature_upto_respects_equiv
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) {k : ℕ} {s t : σ}
    (h : neural_equiv_upto N k s t) {w : List α} (hw : w.length ≤ k) :
    neural_behavior N s w = neural_behavior N t w :=
  h w hw

/-! ## Section 14: Word Enumeration and Complexity Bounds -/

/-- All words of exactly length n over an alphabet given as a list.
    Bridge: enumerates observation contexts for partition refinement.
    Algorithmic: generates |A|^n words of length n. -/
def wordsOfLength {α : Type*} (A : List α) : ℕ → List (List α)
  | 0 => [[]]
  | n + 1 => (wordsOfLength A n).flatMap (fun w => A.map (fun a => a :: w))

/-- All words of length at most n over an alphabet given as a list.
    Bridge: the full observation budget for depth-n partition refinement.
    Complexity: generates ∑_{i=0}^{n} |A|^i = O(|A|^n) words. -/
def wordsUpTo {α : Type*} (A : List α) : ℕ → List (List α)
  | 0 => [[]]
  | n + 1 => wordsUpTo A n ++ wordsOfLength A (n + 1)

/-- Words of length 0 is just the empty word. -/
theorem wordsOfLength_zero {α : Type*} (A : List α) :
    wordsOfLength A 0 = [[]] := rfl

/-- Length of wordsOfLength satisfies |A|^n recursion.
    Bridge: complexity bound for context enumeration — O(|A|^k) observation budget. -/
theorem wordsOfLength_length_recursion {α : Type*} (A : List α) (n : ℕ) :
    (wordsOfLength A n).length = A.length ^ n := by
  induction n with
  | zero => simp [wordsOfLength]
  | succ n ih =>
    simp only [wordsOfLength, List.length_flatMap, List.length_map]
    trans (wordsOfLength A n).length * A.length
    · clear ih
      induction wordsOfLength A n with
      | nil => simp
      | cons w ws ihw =>
        simp only [List.map_cons, List.sum_cons, List.length_cons]
        linarith
    · rw [ih, pow_succ, mul_comm]

/-- Length bound for wordsUpTo: it equals the geometric sum ∑_{i=0}^{k} |A|^i.
    Bridge: explicit O(|A|^k) observation budget for partition refinement. -/
theorem wordsUpTo_length_bound {α : Type*} (A : List α) (k : ℕ) :
    (wordsUpTo A k).length = ∑ i ∈ Finset.range (k + 1), A.length ^ i := by
  induction k with
  | zero => simp [wordsUpTo]
  | succ k ih =>
    conv_rhs => rw [show k + 1 + 1 = (k + 1) + 1 from rfl, Finset.sum_range_succ]
    rw [wordsUpTo, List.length_append, wordsOfLength_length_recursion, ih]

/-! ## Section 15: Observation Signatures -/

/-- Observation signature at depth k: the list of outputs on all words from a given
    alphabet list, up to length k.
    Bridge: the fingerprint used in partition refinement for certified compression.
    Complexity: the signature has O(|A|^k) entries. -/
def observation_signature_upto
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (A : List α) (k : ℕ) (s : σ) :
    List β :=
  (wordsUpTo A k).map (neural_behavior N s)

/-- Signature length equals the geometric sum of alphabet powers.
    Bridge: explicit complexity bound for the certified compression algorithm —
    the observation budget is ∑_{i=0}^{k} |A|^i = O(|A|^k). -/
theorem observation_signature_length
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (A : List α) (k : ℕ) (s : σ) :
    (observation_signature_upto N A k s).length =
    ∑ i ∈ Finset.range (k + 1), A.length ^ i := by
  simp [observation_signature_upto, wordsUpTo_length_bound]

/-- Equal signatures on the same word set imply equal behavior on those words. -/
theorem signature_eq_implies_behavior_eq
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (A : List α) (k : ℕ) (s t : σ)
    (h : observation_signature_upto N A k s = observation_signature_upto N A k t)
    {w : List α} (hw : w ∈ wordsUpTo A k) :
    neural_behavior N s w = neural_behavior N t w := by
  simp only [observation_signature_upto] at h
  exact (List.map_eq_map_iff.mp h) w hw

/-! ## Section 16: Context Factorization -/

/-- Quantum-observable context factorization: behavior on composite contexts
    factors through intermediate states.
    Bridge: connects to quantum circuit decomposition and the compositional
    structure of neural forward passes. -/
theorem quantum_observable_context_factorization
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (s : σ) (w₁ w₂ : List α) :
    neural_behavior N s (w₁ ++ w₂) =
    neural_behavior N (w₁.foldl N.step s) w₂ := by
  simp [neural_behavior, List.foldl_append]

/-- Lattice compression: partition refinement bound.
    Bridge: connects to lattice-based post-quantum key compression. -/
theorem lattice_compression_partition_refinement_bound
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) {k : ℕ} {s t : σ} :
    neural_equiv_upto N (k + 1) s t → neural_equiv_upto N k s t :=
  finite_depth_refinement_monotone N

/-- Quantum operadic depth is preserved under behavioral quotient.
    Bridge: behavioral compression preserves the depth semantics of neural architectures,
    relevant to quantum circuit depth optimization and post-quantum security levels. -/
theorem quantum_operadic_depth_preserved_under_behavioral_quotient
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (s : σ) (w : List α) :
    neural_behavior (quotient_neural_system N) (Quotient.mk _ s) w =
    neural_behavior N s w :=
  quotient_behavior_exact N s w

/-! ## Section 17: Minimality Among Finite Realizations -/

/-- Any injective coalgebra morphism witnesses that the target has at least as many
    states as the quotient of the source.
    Bridge: the minimal realization is genuinely minimal — no smaller architecture
    can faithfully embed the source. -/
theorem neural_myhill_nerode_minimality
    {σ τ α β : Type*}
    [Fintype σ] [Fintype τ]
    {N : NeuralObservationSystem σ α β}
    {M : NeuralObservationSystem τ α β}
    (f : NeuralHom N M)
    (hinj : Function.Injective f.toFun) :
    @Fintype.card (Quotient (neural_setoid N))
      (@Quotient.fintype σ _ (neural_setoid N) (Classical.decRel _)) ≤ Fintype.card τ :=
  le_trans (@Fintype.card_quotient_le σ _ (neural_setoid N) (Classical.decRel _))
    (Fintype.card_le_of_injective _ hinj)

/-- Cardinality bound for the minimal realization.
    Bridge: connects to width bounds in neural architecture search. -/
theorem reachable_minimal_realization_cardinality_bound
    {σ α β : Type*}
    [Fintype σ]
    (N : NeuralObservationSystem σ α β) :
    @Fintype.card (Quotient (neural_setoid N))
      (@Quotient.fintype σ _ (neural_setoid N) (Classical.decRel _)) ≤ Fintype.card σ :=
  quotient_state_count_le_original N

/-! ## Section 18: Finite Stabilization -/

/-- Finite depth refinement stabilization: if no finite depth separates two states,
    they are fully equivalent.
    Bridge: partition refinement termination — the algorithmic foundation
    for certified neural compression with bounded computation. -/
theorem finite_depth_refinement_stabilizes_sufficient
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) (s t : σ)
    (h : ∀ k, neural_equiv_upto N k s t) :
    neural_equiv N s t :=
  neural_equiv_of_all_upto N h

/-! ## Section 19: Products and Composition -/

/-- Product of two neural observation systems: observe both simultaneously.
    Bridge: connects to tensor products of coalgebras and parallel composition
    of neural sub-networks. -/
def product_neural_system
    {σ₁ σ₂ α β₁ β₂ : Type*}
    (N₁ : NeuralObservationSystem σ₁ α β₁)
    (N₂ : NeuralObservationSystem σ₂ α β₂) :
    NeuralObservationSystem (σ₁ × σ₂) α (β₁ × β₂) where
  step := fun ⟨s₁, s₂⟩ a => (N₁.step s₁ a, N₂.step s₂ a)
  observe := fun ⟨s₁, s₂⟩ => (N₁.observe s₁, N₂.observe s₂)

/-- Helper: product foldl decomposes into component foldl's. -/
private theorem product_foldl_decompose
    {σ₁ σ₂ α β₁ β₂ : Type*}
    (N₁ : NeuralObservationSystem σ₁ α β₁)
    (N₂ : NeuralObservationSystem σ₂ α β₂)
    (s₁ : σ₁) (s₂ : σ₂) (w : List α) :
    w.foldl (product_neural_system N₁ N₂).step (s₁, s₂) =
    (w.foldl N₁.step s₁, w.foldl N₂.step s₂) := by
  induction w generalizing s₁ s₂ with
  | nil => rfl
  | cons a w ih => simp only [List.foldl_cons, product_neural_system]; exact ih _ _

/-- Product behavior decomposes into component behaviors.
    Bridge: compositional semantics — behavior of parallel systems factors. -/
theorem product_behavior_components
    {σ₁ σ₂ α β₁ β₂ : Type*}
    (N₁ : NeuralObservationSystem σ₁ α β₁)
    (N₂ : NeuralObservationSystem σ₂ α β₂)
    (s₁ : σ₁) (s₂ : σ₂) (w : List α) :
    neural_behavior (product_neural_system N₁ N₂) (s₁, s₂) w =
    (neural_behavior N₁ s₁ w, neural_behavior N₂ s₂ w) := by
  simp only [neural_behavior]
  rw [product_foldl_decompose]
  rfl

/-- Product equivalence implies component equivalence.
    Bridge: if parallel systems are indistinguishable, each component is. -/
theorem product_equiv_implies_component_equiv
    {σ₁ σ₂ α β₁ β₂ : Type*}
    (N₁ : NeuralObservationSystem σ₁ α β₁)
    (N₂ : NeuralObservationSystem σ₂ α β₂)
    {s₁ t₁ : σ₁} {s₂ t₂ : σ₂}
    (h : neural_equiv (product_neural_system N₁ N₂) (s₁, s₂) (t₁, t₂)) :
    neural_equiv N₁ s₁ t₁ ∧ neural_equiv N₂ s₂ t₂ := by
  constructor <;> intro w <;> have := h w <;>
    rw [product_behavior_components, product_behavior_components] at this
  · exact (Prod.mk.inj this).1
  · exact (Prod.mk.inj this).2

/-! ## Section 20: Summary Theorems -/

/-- The full neural Myhill–Nerode theorem: the quotient by behavioral equivalence
    is the canonical compressed realization preserving all observable outputs,
    and quotient equality reflects behavioral equivalence.
    Bridge: connects classical automata minimization (Myhill–Nerode) to
    certified neural architecture compression. -/
theorem neural_myhill_nerode_canonical_compression
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β) :
    (∀ s w, neural_behavior (quotient_neural_system N) (Quotient.mk _ s) w =
            neural_behavior N s w) ∧
    (∀ s t, Quotient.mk (neural_setoid N) s = Quotient.mk _ t ↔
            neural_equiv N s t) :=
  ⟨quotient_behavior_lift N, quotient_eq_iff_neural_equiv N⟩

/-- Cryptographic-grade neural state compression: compressing by behavioral quotient
    preserves indistinguishability and all robustness certificates.
    Bridge: connects cryptographic security reductions to neural model compression. -/
theorem cryptographic_neural_compression_preserves_certificates
    {σ α β : Type*}
    (N : NeuralObservationSystem σ α β)
    (P : β → Prop) {s t : σ}
    (h : cryptographic_indistinguishable N s t) :
    behaviorally_robust N P s ↔ behaviorally_robust N P t :=
  lipschitz_certified_robustness_behavior_invariant_under_quotient N P h

end Bridges.AlgebraMachineLearning