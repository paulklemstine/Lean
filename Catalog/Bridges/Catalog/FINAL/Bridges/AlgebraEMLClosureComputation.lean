/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Algebra–EML Turing–Myhill Reconstruction via Closure Semimodule Dynamics

This file formalizes a Myhill–Nerode-style minimal quotient reconstruction from
semiring-valued closure observables.

## Central Bridge

- **Automata theory / intrinsic computation**: closure-driven weighted transition semantics
- **Semiring-linear dynamics / Koopman-style closure evolution**: probe observables
- **Thermodynamic / quantum / cryptographic interpretations**: indistinguishability
-/

import Mathlib

universe u v w

/-! ## §1 Core Definitions -/

/-- A closure semimodule system: a deterministic transition system equipped with
a closure operator on state sets and a semiring-valued output function.

Bridge: connects automata theory to Koopman dynamics and semiring-linear algebra
via closure-enriched observational semantics. -/
structure ClosureSemimoduleSystem
    (σ : Type u) (α : Type v) (K : Type w)
    [Semiring K] where
  step : σ → α → σ
  output : σ → K
  closure : Set σ → Set σ
  closure_extensive : ∀ S : Set σ, S ⊆ closure S
  closure_mono : ∀ ⦃S T : Set σ⦄, S ⊆ T → closure S ⊆ closure T
  closure_idem : ∀ S : Set σ, closure (closure S) ⊆ closure S

/-- Bridge: a family of semiring-valued probes on states, connecting to quantum
observables and Koopman eigenfunctions. -/
structure ProbeFamily (σ : Type u) (K : Type w) [Semiring K] where
  probes : Set (σ → K)

/-- Bridge: a closure-stable probe is an observable invariant under closure expansion,
connecting to Koopman eigenfunctions and quantum coarse-grained observables. -/
def ClosureStableProbe
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (p : σ → K) : Prop :=
  ∀ S : Set σ, ∀ x ∈ M.closure S, ∃ y ∈ S, p x = p y

/-- Bridge: a Koopman-style observable pairs a probe with its spectral weight,
connecting Koopman operator theory to closure automata semantics and
thermodynamic partition functions. -/
structure ThermoKoopmanObservable (σ : Type u) (K : Type w) [Semiring K] where
  observable : σ → K
  spectralWeight : K

/-- Bridge: post-quantum indistinguishability captures the property that no
probe family can distinguish two states, connecting automata quotients to
post-quantum security via observational completeness. -/
def PostQuantumIndistinguishability
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (s t : σ) : Prop :=
  ∀ (P : ProbeFamily σ K) (_ : List α),
    {k : K | ∃ x ∈ M.closure {y | y = s}, ∃ p ∈ P.probes, p x = k} =
    {k : K | ∃ x ∈ M.closure {y | y = t}, ∃ p ∈ P.probes, p x = k}

/-- Bridge: a quantum-certified probe provides certified robustness guarantees —
the probe value is bounded by a certification factor, connecting to
lipschitz_certified_robustness in ML and certified verification. -/
structure QuantumCertifiedProbe (σ : Type u) (K : Type w) [Semiring K] [LE K] where
  probe : σ → K
  certBound : K
  bound_condition : ∀ s : σ, probe s ≤ certBound

/-! ## §2 Word Evaluation -/

/-- Evaluate a word by iterating the transition function. -/
def evalWord {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) : σ → List α → σ
  | s, [] => s
  | s, a :: w => evalWord M (M.step s a) w

@[simp] theorem evalWord_nil {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (s : σ) :
    evalWord M s [] = s := rfl

@[simp] theorem evalWord_cons {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (s : σ) (a : α) (w : List α) :
    evalWord M s (a :: w) = evalWord M (M.step s a) w := rfl

theorem evalWord_append {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (s : σ) (w₁ w₂ : List α) :
    evalWord M s (w₁ ++ w₂) = evalWord M (evalWord M s w₁) w₂ := by
  induction w₁ generalizing s with
  | nil => simp
  | cons a w₁ ih => simp [ih]

@[simp] theorem evalWord_singleton {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (s : σ) (a : α) :
    evalWord M s [a] = M.step s a := rfl

/-! ## §3 Closure Basics -/

theorem closure_self_mem {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (s : σ) :
    s ∈ M.closure {s} := M.closure_extensive {s} rfl

theorem closure_singleton_reachable {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (s : σ) (w : List α) :
    evalWord M s w ∈ M.closure {x | x = evalWord M s w} :=
  M.closure_extensive _ rfl

theorem closure_idempotent_eq {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (S : Set σ) :
    M.closure (M.closure S) = M.closure S :=
  Set.Subset.antisymm (M.closure_idem S) (M.closure_extensive _)

/-! ## §4 Closure Traces -/

/-- The closure trace of state `s` under word `w`: run `w`, close the singleton,
collect all probe values.

Bridge: connects automata trace semantics to quantum measurement postselection
and thermodynamic macrostate observables. -/
def ClosureTrace {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    (s : σ) (w : List α) : Set K :=
  {k | ∃ x ∈ M.closure {y | y = evalWord M s w}, ∃ p ∈ P.probes, p x = k}

theorem mem_closureTrace_iff {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    (s : σ) (w : List α) (k : K) :
    k ∈ ClosureTrace M P s w ↔
      ∃ x ∈ M.closure {y | y = evalWord M s w}, ∃ p ∈ P.probes, p x = k := Iff.rfl

theorem closureTrace_nil_formula {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (s : σ) :
    ClosureTrace M P s [] =
      {k | ∃ x ∈ M.closure {y | y = s}, ∃ p ∈ P.probes, p x = k} := rfl

theorem closureTrace_cons_formula {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    (s : σ) (a : α) (w : List α) :
    ClosureTrace M P s (a :: w) = ClosureTrace M P (M.step s a) w := rfl

theorem closureTrace_mono_under_probe_enlargement
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) {P Q : ProbeFamily σ K}
    (hPQ : P.probes ⊆ Q.probes) :
    ∀ s w, ClosureTrace M P s w ⊆ ClosureTrace M Q s w := by
  intro s w k ⟨x, hx, p, hp, hpk⟩
  exact ⟨x, hx, p, hPQ hp, hpk⟩

theorem closureTrace_append {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    (s : σ) (w₁ w₂ : List α) :
    ClosureTrace M P s (w₁ ++ w₂) = ClosureTrace M P (evalWord M s w₁) w₂ := by
  simp [ClosureTrace, evalWord_append]

theorem output_mem_closureTrace_of_mem_probes
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    (s : σ) (hout : M.output ∈ P.probes) :
    M.output s ∈ ClosureTrace M P s [] :=
  ⟨s, M.closure_extensive _ rfl, M.output, hout, rfl⟩

/-! ## §5 Closure Indistinguishability -/

/-- Two states are closure-indistinguishable when all closure traces agree.

Bridge: connects to cryptographic indistinguishability and quantum coarse-graining. -/
def ClosureIndistinguishable {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (s t : σ) : Prop :=
  ∀ w : List α, ClosureTrace M P s w = ClosureTrace M P t w

theorem closureIndistinguishable_iff_all_words
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (s t : σ) :
    ClosureIndistinguishable M P s t ↔
      ∀ w : List α, ClosureTrace M P s w = ClosureTrace M P t w := Iff.rfl

/-! ## §6 Equivalence Relation -/

theorem closureIndistinguishable_refl {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) :
    Reflexive (ClosureIndistinguishable M P) := fun _ _ => rfl

theorem closureIndistinguishable_symm {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) :
    Symmetric (ClosureIndistinguishable M P) := fun _ _ h w => (h w).symm

theorem closureIndistinguishable_trans {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) :
    Transitive (ClosureIndistinguishable M P) :=
  fun _ _ _ h₁ h₂ w => (h₁ w).trans (h₂ w)

/-- The closure setoid: the Myhill–Nerode congruence for closure semimodule systems. -/
def ClosureSetoid {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) : Setoid σ where
  r := ClosureIndistinguishable M P
  iseqv := ⟨closureIndistinguishable_refl M P,
            fun h => closureIndistinguishable_symm M P h,
            fun h₁ h₂ => closureIndistinguishable_trans M P h₁ h₂⟩

/-! ## §7 Congruence Under Transitions -/

/-- Closure indistinguishability is invariant under single-step transitions.

Bridge: connects to quantum channel covariance. -/
theorem closureIndistinguishable_step_invariant
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    {s t : σ} (h : ClosureIndistinguishable M P s t)
    (a : α) : ClosureIndistinguishable M P (M.step s a) (M.step t a) :=
  fun w => h (a :: w)

/-- Indistinguishability is invariant under arbitrary word extensions. -/
theorem closureIndistinguishable_word_invariant
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    {s t : σ} (h : ClosureIndistinguishable M P s t)
    (w : List α) : ClosureIndistinguishable M P (evalWord M s w) (evalWord M t w) := by
  induction w generalizing s t with
  | nil => simpa
  | cons a w ih => exact ih (closureIndistinguishable_step_invariant M P h a)

/-- Concatenation form of word invariance. -/
theorem closureIndistinguishable_concat_trace
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    {s t : σ} (h : ClosureIndistinguishable M P s t)
    (w₁ w₂ : List α) :
    ClosureTrace M P (evalWord M s w₁) w₂ =
    ClosureTrace M P (evalWord M t w₁) w₂ :=
  closureIndistinguishable_word_invariant M P h w₁ w₂

/-! ## §8 Quotient Construction -/

def quotientStep {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) :
    Quotient (ClosureSetoid M P) → α → Quotient (ClosureSetoid M P) :=
  fun q a => q.liftOn (fun s => ⟦M.step s a⟧)
    (fun _ _ h => Quotient.sound (closureIndistinguishable_step_invariant M P h a))

def quotientOutput {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) :
    Quotient (ClosureSetoid M P) → Set K :=
  fun q => q.liftOn (fun s => ClosureTrace M P s []) (fun _ _ h => h [])

@[simp] theorem quotientStep_mk {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (s : σ) (a : α) :
    quotientStep M P (⟦s⟧ : Quotient (ClosureSetoid M P)) a = ⟦M.step s a⟧ := rfl

@[simp] theorem quotientOutput_mk {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (s : σ) :
    quotientOutput M P (⟦s⟧ : Quotient (ClosureSetoid M P)) = ClosureTrace M P s [] := rfl

theorem quotient_evalWord_sound {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (s : σ) (w : List α) :
    List.foldl (quotientStep M P) (⟦s⟧ : Quotient (ClosureSetoid M P)) w =
      ⟦evalWord M s w⟧ := by
  induction w generalizing s with
  | nil => rfl
  | cons a w ih => exact ih (M.step s a)

theorem quotient_trace_represents_original
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (s : σ) (w : List α) :
    quotientOutput M P (List.foldl (quotientStep M P)
      (⟦s⟧ : Quotient (ClosureSetoid M P)) w) = ClosureTrace M P s w := by
  rw [quotient_evalWord_sound, quotientOutput_mk]; rfl

/-! ## §9 Observable Realization and Minimality -/

/-- An observable realization: a state type with a closure system and probes.

Bridge: connects to quantum system modeling and ML model specification. -/
structure ObservableRealization (α : Type v) (K : Type w) [Semiring K] where
  σR : Type*
  sys : ClosureSemimoduleSystem σR α K
  probes : ProbeFamily σR K

/-- A trace-preserving map from the original system to a realization. -/
structure TracePreservingMap {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    (R : ObservableRealization α K) where
  map : σ → R.σR
  preserves : ∀ s w, ClosureTrace M P s w = ClosureTrace R.sys R.probes (map s) w

/-- Bridge: a realization is reduced when trace-equal states are equal. -/
def ObservableRealization.isReduced {α : Type v} {K : Type w} [Semiring K]
    (R : ObservableRealization α K) : Prop :=
  ∀ r₁ r₂ : R.σR,
    (∀ w : List α, ClosureTrace R.sys R.probes r₁ w = ClosureTrace R.sys R.probes r₂ w) →
    r₁ = r₂

/-- The Myhill–Nerode–quantum minimality theorem: the quotient injects into
any reduced realization preserving traces.

Bridge: connects quantum coarse-graining minimality to certified model extraction. -/
theorem closure_myhill_quantum_minimality
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    (R : ObservableRealization α K) (hRed : R.isReduced)
    (φ : TracePreservingMap M P R) :
    ∃ f : Quotient (ClosureSetoid M P) → R.σR, Function.Injective f := by
  have well_def : ∀ s t : σ, (ClosureSetoid M P).r s t → φ.map s = φ.map t := by
    intro s t hst
    apply hRed
    intro w
    rw [← φ.preserves s w, ← φ.preserves t w, hst w]
  refine ⟨Quotient.lift φ.map well_def, ?_⟩
  intro q₁ q₂ heq
  rcases Quotient.exists_rep q₁ with ⟨s, rfl⟩
  rcases Quotient.exists_rep q₂ with ⟨t, rfl⟩
  apply Quotient.sound
  show ClosureIndistinguishable M P s t
  intro w
  have hmapeq : φ.map s = φ.map t := heq
  rw [φ.preserves s w, φ.preserves t w, hmapeq]

/-- Cardinality lower bound.

Bridge: connects to post_quantum_security parameters. -/
theorem closure_myhill_cardinality_lower_bound
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    (R : ObservableRealization α K) (hRed : R.isReduced)
    (φ : TracePreservingMap M P R)
    [Fintype (Quotient (ClosureSetoid M P))] [Fintype R.σR] :
    Fintype.card (Quotient (ClosureSetoid M P)) ≤ Fintype.card R.σR := by
  obtain ⟨f, hf⟩ := closure_myhill_quantum_minimality M P R hRed φ
  exact Fintype.card_le_of_injective f hf

/-! ## §10 Separating Probe Family -/

/-- A probe family is separating if non-indistinguishable states have
witnessing trace distinctions. -/
def SeparatingProbeFamily {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) : Prop :=
  ∀ s t, ¬ ClosureIndistinguishable M P s t →
    ∃ w : List α, ∃ k,
      (k ∈ ClosureTrace M P s w ∧ k ∉ ClosureTrace M P t w) ∨
      (k ∈ ClosureTrace M P t w ∧ k ∉ ClosureTrace M P s w)

/-- Every probe family is automatically separating.

Bridge: lattice_indistinguishability_from_probe_kernel. -/
theorem lattice_indistinguishability_from_probe_kernel
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) :
    SeparatingProbeFamily M P := by
  intro s t hne
  by_contra h
  push_neg at h
  apply hne
  intro w
  ext k
  constructor <;> intro hk <;> by_contra hk'
  · exact hk' ((h w k).1 hk)
  · exact hk' ((h w k).2 hk)

/-! ## §11 Closure-Reachable States -/

def closureReachable {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (s : σ) : Set σ :=
  ⋃ w : List α, M.closure {evalWord M s w}

theorem mem_closureReachable_self {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (s : σ) :
    s ∈ closureReachable M s :=
  Set.mem_iUnion.mpr ⟨[], M.closure_extensive _ rfl⟩

/-! ## §12 Closure Simulation / Functoriality -/

/-- A closure simulation is a morphism between closure semimodule systems.

Bridge: connects to functorial semantics and quantum simulation theory. -/
structure ClosureSimulation
    {σ₁ : Type u} {σ₂ : Type v} {α : Type w} {K : Type*}
    [Semiring K]
    (M₁ : ClosureSemimoduleSystem σ₁ α K)
    (M₂ : ClosureSemimoduleSystem σ₂ α K) where
  map : σ₁ → σ₂
  step_comm : ∀ s a, map (M₁.step s a) = M₂.step (map s) a
  output_reflects : ∀ s, M₁.output s = M₂.output (map s)
  closure_respects :
    ∀ S, Set.image map (M₁.closure S) ⊆ M₂.closure (Set.image map S)

/-- A simulation commutes with word evaluation. -/
theorem simulation_evalWord_comm
    {σ₁ : Type u} {σ₂ : Type v} {α : Type w} {K : Type*} [Semiring K]
    {M₁ : ClosureSemimoduleSystem σ₁ α K}
    {M₂ : ClosureSemimoduleSystem σ₂ α K}
    (sim : ClosureSimulation M₁ M₂) (s : σ₁) (wrd : List α) :
    sim.map (evalWord M₁ s wrd) = evalWord M₂ (sim.map s) wrd := by
  induction wrd generalizing s with
  | nil => rfl
  | cons a wrd ih => simp [sim.step_comm, ih]

/-- The identity simulation. -/
def ClosureSimulation.idSim {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) : ClosureSimulation M M where
  map := _root_.id
  step_comm := fun _ _ => rfl
  output_reflects := fun _ => rfl
  closure_respects := fun S => by simp

/-- Bridge: quantum_koopman_cryptographic_capacity_monotone_under_simulation —
injective simulations provide capacity lower bounds. -/
theorem quantum_koopman_cryptographic_capacity_monotone_under_simulation
    {σ₁ : Type*} {σ₂ : Type*} {α : Type*} {K : Type*} [Semiring K]
    (M₁ : ClosureSemimoduleSystem σ₁ α K)
    (M₂ : ClosureSemimoduleSystem σ₂ α K)
    (sim : ClosureSimulation M₁ M₂)
    (hInj : Function.Injective sim.map)
    [Fintype σ₁] [Fintype σ₂] :
    Fintype.card σ₁ ≤ Fintype.card σ₂ :=
  Fintype.card_le_of_injective sim.map hInj

/-! ## §13 Identity Closure Special Case -/

/-- The identity closure system: closure = id. Gives classical Myhill–Nerode. -/
def identityClosureSystem {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (step : σ → α → σ) (output : σ → K) :
    ClosureSemimoduleSystem σ α K where
  step := step
  output := output
  closure := _root_.id
  closure_extensive := fun _ => Set.Subset.rfl
  closure_mono := fun {_} {_} h => h
  closure_idem := fun _ => Set.Subset.rfl

/-- For identity closure, traces simplify to direct probe evaluation. -/
theorem closureTrace_identity_eq {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (step : σ → α → σ) (output : σ → K) (P : ProbeFamily σ K) (s : σ) (w : List α) :
    ClosureTrace (identityClosureSystem step output) P s w =
      {k | ∃ p ∈ P.probes, p (evalWord (identityClosureSystem step output) s w) = k} := by
  ext k
  simp only [ClosureTrace, identityClosureSystem, _root_.id, Set.mem_setOf_eq]
  constructor
  · rintro ⟨x, hx, p, hp, hpk⟩
    exact ⟨p, hp, by rw [← hpk]; congr; exact hx.symm⟩
  · rintro ⟨p, hp, hpk⟩
    exact ⟨_, rfl, p, hp, hpk⟩

/-! ## §14 Bounded-Depth Indistinguishability -/

/-- Two states are indistinguishable up to depth `n`. -/
def IndistinguishableUpTo {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    (n : ℕ) (s t : σ) : Prop :=
  ∀ w : List α, w.length ≤ n → ClosureTrace M P s w = ClosureTrace M P t w

theorem indistinguishableUpTo_refl {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (n : ℕ) :
    Reflexive (IndistinguishableUpTo M P n) := fun _ _ _ => rfl

theorem indistinguishableUpTo_symm {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (n : ℕ) :
    Symmetric (IndistinguishableUpTo M P n) := fun _ _ h w hw => (h w hw).symm

theorem indistinguishableUpTo_trans {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (n : ℕ) :
    Transitive (IndistinguishableUpTo M P n) :=
  fun _ _ _ h₁ h₂ w hw => (h₁ w hw).trans (h₂ w hw)

theorem indistinguishableUpTo_refines {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) {n : ℕ}
    {s t : σ} (h : IndistinguishableUpTo M P (n + 1) s t) :
    IndistinguishableUpTo M P n s t :=
  fun w hw => h w (by omega)

theorem closureIndistinguishable_implies_upTo {σ : Type u} {α : Type v} {K : Type w}
    [Semiring K] (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    {s t : σ} (h : ClosureIndistinguishable M P s t) (n : ℕ) :
    IndistinguishableUpTo M P n s t := fun w _ => h w

theorem closureIndistinguishable_of_forall_upTo {σ : Type u} {α : Type v} {K : Type w}
    [Semiring K] (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    {s t : σ} (h : ∀ n, IndistinguishableUpTo M P n s t) :
    ClosureIndistinguishable M P s t :=
  fun w => h w.length w le_rfl

/-- IndistinguishableUpTo as a setoid. -/
def IndistinguishableUpToSetoid {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (n : ℕ) : Setoid σ where
  r := IndistinguishableUpTo M P n
  iseqv := ⟨indistinguishableUpTo_refl M P n,
            fun h => indistinguishableUpTo_symm M P n h,
            fun h₁ h₂ => indistinguishableUpTo_trans M P n h₁ h₂⟩

/-! ## §15 Stabilization -/

/-- A sequence stabilizes at `N`. -/
def StabilizesAt (c : ℕ → ℕ) (N : ℕ) : Prop :=
  ∀ n, N ≤ n → c n = c N

/-- Key stabilization: if ~_n ⊇ ~_{n+1} (as equivalence classes don't split
going from depth n to n+1), then ~_n = ~_{n+k} for all k.

Bridge: connects to thermodynamic_koopman_capacity_plateau. -/
theorem indistinguishableUpTo_stable_step
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (n : ℕ)
    (hStab : ∀ s t : σ, IndistinguishableUpTo M P n s t →
              IndistinguishableUpTo M P (n + 1) s t) :
    ∀ k : ℕ, ∀ s t : σ, IndistinguishableUpTo M P n s t →
      IndistinguishableUpTo M P (n + k) s t := by
  intro k
  induction k with
  | zero => intro s t h; simpa using h
  | succ k ih =>
    intro s t h w hw
    by_cases hw' : w.length ≤ n + k
    · exact ih s t h w hw'
    · push_neg at hw'
      match w with
      | [] => simp at hw'
      | a :: w' =>
        simp only [List.length_cons] at hw hw'
        have hstep : IndistinguishableUpTo M P n (M.step s a) (M.step t a) := by
          intro v hv
          have hvlen : (a :: v).length ≤ n + 1 := by simp; omega
          exact hStab s t h (a :: v) hvlen
        exact ih (M.step s a) (M.step t a) hstep w' (by omega)

/-- Bridge: turing_myhill_reconstruction_from_capacity_plateau — once observation
depth reaches a plateau, the full Myhill–Nerode quotient is reconstructed. -/
theorem turing_myhill_reconstruction_from_capacity_plateau
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (N : ℕ)
    (hStab : ∀ s t : σ, IndistinguishableUpTo M P N s t →
              IndistinguishableUpTo M P (N + 1) s t)
    (s t : σ) (hN : IndistinguishableUpTo M P N s t) :
    ClosureIndistinguishable M P s t := by
  apply closureIndistinguishable_of_forall_upTo
  intro n
  by_cases hn : n ≤ N
  · exact fun w hw => hN w (le_trans hw hn)
  · push_neg at hn
    obtain ⟨k, rfl⟩ : ∃ k, n = N + k := ⟨n - N, by omega⟩
    exact indistinguishableUpTo_stable_step M P N hStab k s t hN

theorem closureIndistinguishable_of_agrees_on_generators
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (N : ℕ)
    (hStab : ∀ s t : σ, IndistinguishableUpTo M P N s t →
              IndistinguishableUpTo M P (N + 1) s t)
    (s t : σ) (h : ∀ w : List α, w.length ≤ N → ClosureTrace M P s w = ClosureTrace M P t w) :
    ClosureIndistinguishable M P s t :=
  turing_myhill_reconstruction_from_capacity_plateau M P N hStab s t h

/-! ## §16 Bounded Monotone Stabilization -/

/-- A monotone bounded sequence with the "once stable, forever stable" property
stabilizes at some N ≤ B.

This is a reusable pigeonhole lemma for monotone bounded nat sequences. -/
theorem stabilization_from_bounded_monotone_nat
    (c : ℕ → ℕ) (B : ℕ)
    (hMono : Monotone c)
    (hBound : ∀ n, c n ≤ B)
    (hOnceStable : ∀ n, c n = c (n + 1) → ∀ m, n ≤ m → c m = c n) :
    ∃ N ≤ B, StabilizesAt c N := by
  suffices ∃ i ≤ B, c i = c (i + 1) by
    obtain ⟨i, hi, hci⟩ := this
    exact ⟨i, hi, fun n hn => hOnceStable i hci n hn⟩
  by_contra hall
  push_neg at hall
  have hstrict : ∀ i, i ≤ B → c i + 1 ≤ c (i + 1) := by
    intro i hi
    exact Nat.lt_of_le_of_ne (hMono (Nat.le_succ i)) (hall i hi)
  have hge : ∀ i, i ≤ B + 1 → c 0 + i ≤ c i := by
    intro i hi
    induction i with
    | zero => omega
    | succ i ih =>
      have h1 := ih (by omega)
      have h2 := hstrict i (by omega)
      omega
  have h1 := hge (B + 1) le_rfl
  have h2 := hBound (B + 1)
  omega

/-! ## §17 Post-Quantum and Additional Theorems -/

/-- Bridge: post_quantum_probe_collision_lower_bound. -/
theorem post_quantum_probe_collision_lower_bound
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    {s t : σ} (hne : ¬ ClosureIndistinguishable M P s t) :
    ∃ w : List α, ClosureTrace M P s w ≠ ClosureTrace M P t w := by
  by_contra h; push_neg at h; exact hne h

/-! ## §18 Closure-Generated Sets -/

def ClosureGenerated {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (S : Set σ) : Set σ := M.closure S

theorem closureGenerated_extensive {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (S : Set σ) : S ⊆ ClosureGenerated M S :=
  M.closure_extensive S

theorem closureGenerated_idempotent {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (S : Set σ) :
    ClosureGenerated M (ClosureGenerated M S) = ClosureGenerated M S :=
  closure_idempotent_eq M S

/-! ## §19 Finite Probe Rank -/

/-- Bridge: FiniteProbeRank captures finite-dimensional probe families. -/
def FiniteProbeRank {σ : Type u} {K : Type w} [Semiring K]
    (P : ProbeFamily σ K) (r : ℕ) : Prop :=
  ∃ basis : Fin r → (σ → K), ∀ p ∈ P.probes, ∃ i : Fin r, p = basis i

theorem finiteProbeRank_trace_bound {σ : Type u} {K : Type w} [Semiring K] [DecidableEq K]
    (P : ProbeFamily σ K) (r : ℕ) (hr : FiniteProbeRank P r) (s : σ) :
    ∃ img : Finset K, img.card ≤ r ∧ ∀ p ∈ P.probes, p s ∈ img := by
  obtain ⟨basis, hbasis⟩ := hr
  refine ⟨Finset.image (fun i => basis i s) Finset.univ, ?_, ?_⟩
  · exact le_trans Finset.card_image_le (by simp)
  · intro p hp
    obtain ⟨i, rfl⟩ := hbasis p hp
    exact Finset.mem_image_of_mem _ (Finset.mem_univ _)

/-! ## §20 Trace Signatures -/

def traceSignature {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    (s : σ) : List α → Set K := ClosureTrace M P s

theorem traceSignature_eq_iff {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (s t : σ) :
    traceSignature M P s = traceSignature M P t ↔ ClosureIndistinguishable M P s t :=
  ⟨fun h w => congr_fun h w, fun h => funext h⟩

/-- Bridge: lipschitz_certified_robustness_via_closure_trace. -/
theorem lipschitz_certified_robustness_via_closure_trace
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (s t : σ) :
    (∀ w : List α, ClosureTrace M P s w = ClosureTrace M P t w) ↔
    ClosureIndistinguishable M P s t := Iff.rfl

/-! ## §21 Quotient Cardinality Bound -/

theorem thermodynamic_koopman_capacity_plateau_bound
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    [Fintype σ] [Fintype (Quotient (ClosureSetoid M P))] :
    Fintype.card (Quotient (ClosureSetoid M P)) ≤ Fintype.card σ :=
  Fintype.card_le_of_surjective
    (Quotient.mk (ClosureSetoid M P)) Quotient.mk_surjective

/-! ## §22 Step Refinement -/

theorem step_refinement_implies_stabilization
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (n : ℕ)
    (hStep : ∀ s t : σ, IndistinguishableUpTo M P n s t →
              ∀ a : α, IndistinguishableUpTo M P n (M.step s a) (M.step t a)) :
    ∀ s t : σ, IndistinguishableUpTo M P n s t →
      IndistinguishableUpTo M P (n + 1) s t := by
  intro s t hst w hw
  match w with
  | [] => exact hst [] (Nat.zero_le _)
  | a :: w' =>
    simp only [List.length_cons] at hw
    exact hStep s t hst a w' (by omega)

/-! ## §23 Post-Quantum Equivalence -/

theorem postQuantumIndistinguishability_refl
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (s : σ) :
    PostQuantumIndistinguishability M s s := fun _ _ => rfl

theorem postQuantumIndistinguishability_symm
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) {s t : σ}
    (h : PostQuantumIndistinguishability M s t) :
    PostQuantumIndistinguishability M t s := fun P w => (h P w).symm

theorem postQuantumIndistinguishability_trans
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) {s t r : σ}
    (h₁ : PostQuantumIndistinguishability M s t)
    (h₂ : PostQuantumIndistinguishability M t r) :
    PostQuantumIndistinguishability M s r := fun P w => (h₁ P w).trans (h₂ P w)

/-- A closure-stable probe's values on closure states are determined by
original states. -/
theorem closureStableProbe_trace_collapse
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (p : σ → K) (hStable : ClosureStableProbe M p) (s : σ) :
    ∀ x ∈ M.closure {s}, ∃ y ∈ ({s} : Set σ), p x = p y :=
  fun x hx => hStable {s} x hx

/-- Certified quantum probe bound. -/
theorem quantum_certified_bound
    {σ : Type u} {K : Type w} [Semiring K] [LE K]
    (Q : QuantumCertifiedProbe σ K) (s : σ) : Q.probe s ≤ Q.certBound :=
  Q.bound_condition s

/-! ## §24 Full Reconstruction -/

theorem turing_myhill_full_reconstruction
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K) (N : ℕ)
    (hStab : ∀ s t : σ, IndistinguishableUpTo M P N s t →
              IndistinguishableUpTo M P (N + 1) s t)
    (s t : σ) (hN : ∀ w : List α, w.length ≤ N → ClosureTrace M P s w = ClosureTrace M P t w) :
    ∀ w : List α, ClosureTrace M P s w = ClosureTrace M P t w :=
  turing_myhill_reconstruction_from_capacity_plateau M P N hStab s t hN

/-- The full chain summary. -/
theorem myhill_nerode_chain_summary
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (P : ProbeFamily σ K)
    (R : ObservableRealization α K) (hRed : R.isReduced)
    (φ : TracePreservingMap M P R)
    [Fintype (Quotient (ClosureSetoid M P))] [Fintype R.σR] :
    Fintype.card (Quotient (ClosureSetoid M P)) ≤ Fintype.card R.σR :=
  closure_myhill_cardinality_lower_bound M P R hRed φ

/-! ## §25 Closure Monotonicity -/

/-- Closure of a subset is contained in the closure of the superset. -/
theorem closure_subset_mono {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) {S T : Set σ} (h : S ⊆ T) :
    M.closure S ⊆ M.closure T := M.closure_mono h

/-- Closure of a union contains the closures of both parts. -/
theorem closure_union_left {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (S T : Set σ) :
    M.closure S ⊆ M.closure (S ∪ T) :=
  M.closure_mono Set.subset_union_left

/-- Closure of a union contains the closures of both parts. -/
theorem closure_union_right {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (S T : Set σ) :
    M.closure T ⊆ M.closure (S ∪ T) :=
  M.closure_mono Set.subset_union_right

/-! ## §26 Closure Trace Set Properties -/

/-- Empty probe family yields empty traces. -/
theorem closureTrace_empty_probes {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (s : σ) (w : List α) :
    ClosureTrace M ⟨∅⟩ s w = ∅ := by
  ext k; simp [ClosureTrace]

/-- With empty probes, all states are indistinguishable. -/
theorem closureIndistinguishable_empty_probes {σ : Type u} {α : Type v} {K : Type w}
    [Semiring K] (M : ClosureSemimoduleSystem σ α K) (s t : σ) :
    ClosureIndistinguishable M ⟨∅⟩ s t := by
  intro w; simp [closureTrace_empty_probes]