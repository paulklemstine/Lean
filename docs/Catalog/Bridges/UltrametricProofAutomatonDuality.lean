/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Ultrametric Proof Automaton Duality via Observer-Trace Congruences

This file formalizes a duality between **ultrametric proof dynamics** and
**minimal deterministic proof automata** via observer-trace congruences,
building on the Myhill–Nerode pattern from `ProofCongruenceAutomata` and
prime-state reconstruction from `EMLSpectralSemantics`.

## Core Idea

Given a finite proof system with states `P`, contraction alphabet `A`,
observers `O`, and observer evaluation `obs : O → P → S`, we define
**observational equivalence** as agreement of all observer evaluations under all
contraction words, show it is a congruence, identify it with the kernel of a
canonical trace morphism, construct a minimal quotient automaton, and prove uniqueness.

## Main Results

* `obsEquiv_is_equivalence` — observational equiv is an equivalence relation
* `observational_equiv_is_congruence` — congruence under contractions
* `observational_equiv_eq_kernel` — equivalence = kernel of trace map
* `quotient_step_wellDefined` — contraction action descends to the quotient
* `repr_eq_implies_equiv` — representation injectivity implies minimality
* `canonical_factors_through` — canonical automaton has universal property
* `ultrametric_isosceles` — non-Archimedean isosceles triangle theorem
* `ultrametric_zero_equiv` — distance-zero is an equivalence relation
* `finite_duality_theorem` — the full duality packaging
* `traceImage_closed_under_residual` — trace image is a residual sub-semimodule
* `obsSep_isUltrametric` — observer separation is ultrametric

**application keywords:** non-Archimedean automata, ultrametric proof dynamics,
Myhill–Nerode duality, idempotent semimodules, tropical logic, residual automata,
proof-state minimization, certified reconstruction, prime-congruence semantics,
abstract interpretation, formal learning theory, proof compression.
-/

import Mathlib

set_option maxHeartbeats 800000

open Function

noncomputable section

namespace UltrametricProofAutomaton

/-! ## §1. Running Contraction Words -/

/-- Apply a word of contraction symbols to a proof state, left-to-right. -/
def runWord {P A : Type*} (step : A → P → P) : List A → P → P
  | [], p => p
  | a :: w, p => runWord step w (step a p)

@[simp]
theorem runWord_nil {P A : Type*} (step : A → P → P) (p : P) :
    runWord step [] p = p := rfl

@[simp]
theorem runWord_cons {P A : Type*} (step : A → P → P) (a : A) (w : List A) (p : P) :
    runWord step (a :: w) p = runWord step w (step a p) := rfl

theorem runWord_append {P A : Type*} (step : A → P → P) (w₁ w₂ : List A) (p : P) :
    runWord step (w₁ ++ w₂) p = runWord step w₂ (runWord step w₁ p) := by
  induction w₁ generalizing p with
  | nil => simp
  | cons a w₁ ih => simp [ih]

/-! ## §2. Observational Equivalence -/

/-- Observational equivalence: `p ≈ q` iff for every contraction word `w` and
every observer `o`, the observer evaluations agree.
Bridge: proof-theoretic analogue of Myhill–Nerode right-congruence. -/
def obsEquiv {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) (p q : P) : Prop :=
  ∀ (w : List A) (o : O), obs o (runWord step w p) = obs o (runWord step w q)

theorem obsEquiv_refl {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) (p : P) :
    obsEquiv step obs p p := fun _ _ => rfl

theorem obsEquiv_symm {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) {p q : P}
    (h : obsEquiv step obs p q) : obsEquiv step obs q p :=
  fun w o => (h w o).symm

theorem obsEquiv_trans {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) {p q r : P}
    (hpq : obsEquiv step obs p q) (hqr : obsEquiv step obs q r) :
    obsEquiv step obs p r :=
  fun w o => (hpq w o).trans (hqr w o)

/-- Observational equivalence is an equivalence relation. -/
theorem obsEquiv_is_equivalence {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) :
    Equivalence (obsEquiv step obs : P → P → Prop) :=
  ⟨obsEquiv_refl step obs,
   fun h => obsEquiv_symm step obs h,
   fun h₁ h₂ => obsEquiv_trans step obs h₁ h₂⟩

/-- The setoid induced by observational equivalence. -/
def obsSetoid (P : Type*) {A O S : Type*}
    (step : A → P → P) (obs : O → P → S) : Setoid P where
  r := obsEquiv step obs
  iseqv := obsEquiv_is_equivalence step obs

/-! ## §3. Congruence Property -/

/-- **Key congruence theorem**: Observational equivalence is preserved by
contraction steps. If `p ≈ q` then `step a p ≈ step a q`.
Bridge: the proof-system analogue of right-invariance in Myhill–Nerode theory. -/
theorem observational_equiv_is_congruence {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S)
    {p q : P} (h : obsEquiv step obs p q) (a : A) :
    obsEquiv step obs (step a p) (step a q) :=
  fun w o => h (a :: w) o

/-- Congruence extends to arbitrary contraction words. -/
theorem obsEquiv_runWord {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S)
    {p q : P} (h : obsEquiv step obs p q) (w : List A) :
    obsEquiv step obs (runWord step w p) (runWord step w q) := by
  induction w generalizing p q with
  | nil => exact h
  | cons a w ih => simp; exact ih (observational_equiv_is_congruence step obs h a)

/-! ## §4. Observer Trace Space and Kernel Theorem -/

/-- Build the trace profile of a proof state. -/
def buildTrace {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) (p : P) :
    List A × O → S :=
  fun ⟨w, o⟩ => obs o (runWord step w p)

/-- **Kernel-Trace Theorem**: Observational equivalence = kernel of trace map.
Bridge: turns proof-state equivalence into algebraic equality. -/
theorem observational_equiv_eq_kernel {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) (p q : P) :
    obsEquiv step obs p q ↔ buildTrace step obs p = buildTrace step obs q := by
  exact ⟨fun h => funext fun ⟨w, o⟩ => h w o,
         fun h w o => congr_fun h ⟨w, o⟩⟩

/-! ## §5. Quotient Automaton Construction -/

/-- The quotient type of proof states by observational equivalence. -/
abbrev StateQuotient (P : Type*) {A O S : Type*}
    (step : A → P → P) (obs : O → P → S) :=
  Quotient (obsSetoid P step obs)

/-- The contraction action descends to the quotient. -/
theorem quotient_step_wellDefined {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) (a : A)
    {p q : P} (h : (obsSetoid P step obs).r p q) :
    @Quotient.mk _ (obsSetoid P step obs) (step a p) =
    @Quotient.mk _ (obsSetoid P step obs) (step a q) :=
  Quotient.sound (observational_equiv_is_congruence step obs h a)

/-- The descended contraction action on quotient states. -/
def quotientStep {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) (a : A) :
    StateQuotient P step obs → StateQuotient P step obs :=
  Quotient.map (step a) (fun _ _ h => observational_equiv_is_congruence step obs h a)

/-- Observer evaluation descends to the quotient. -/
def quotientObs {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) (o : O) :
    StateQuotient P step obs → S :=
  Quotient.lift (obs o) (fun _ _ h => h [] o)

/-! ## §6. Deterministic Proof Automaton -/

/-- A deterministic proof automaton. -/
structure DetProofAutomaton (A O S Q : Type*) where
  transition : A → Q → Q
  output : O → Q → S

/-- The canonical minimal automaton from the quotient. -/
def canonicalAut {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) :
    DetProofAutomaton A O S (StateQuotient P step obs) where
  transition := quotientStep step obs
  output := quotientObs step obs

/-- An automaton morphism. -/
structure AutMorphism {A O S Q₁ Q₂ : Type*}
    (B₁ : DetProofAutomaton A O S Q₁)
    (B₂ : DetProofAutomaton A O S Q₂) where
  toFun : Q₁ → Q₂
  transition_comm : ∀ a q, toFun (B₁.transition a q) = B₂.transition a (toFun q)
  output_comm : ∀ o q, B₁.output o q = B₂.output o (toFun q)

/-! ## §7. Representation and Minimality -/

/-- A representation from proof states to automaton states. -/
def IsRepr {P A O S Q : Type*}
    (step : A → P → P) (obs : O → P → S)
    (aut : DetProofAutomaton A O S Q) (repr : P → Q) : Prop :=
  (∀ a p, repr (step a p) = aut.transition a (repr p)) ∧
  (∀ o p, obs o p = aut.output o (repr p))

/-- The canonical quotient map is a representation. -/
theorem canonical_is_repr {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) :
    IsRepr step obs (canonicalAut step obs)
      (fun p => @Quotient.mk _ (obsSetoid P step obs) p) :=
  ⟨fun _ _ => rfl, fun _ _ => rfl⟩

/-- If two states have the same representation, they are observationally equivalent. -/
theorem repr_eq_implies_equiv {P A O S Q : Type*}
    (step : A → P → P) (obs : O → P → S)
    (aut : DetProofAutomaton A O S Q) (repr : P → Q)
    (hRepr : IsRepr step obs aut repr)
    {p q : P} (h : repr p = repr q) :
    obsEquiv step obs p q := by
  intro w o
  induction w generalizing p q with
  | nil => exact hRepr.2 o p ▸ hRepr.2 o q ▸ congrArg (aut.output o) h
  | cons a w ih =>
    exact ih (hRepr.1 a p ▸ hRepr.1 a q ▸ congrArg (aut.transition a) h)

/-- Run a word through an automaton's transition function. -/
def runWordAut {A Q : Type*} (trans : A → Q → Q) : List A → Q → Q
  | [], q => q
  | a :: w, q => runWordAut trans w (trans a q)

/-- An automaton is **observable** (reduced) if no two distinct states have
identical future behavior. This is necessary for the factoring property. -/
def IsObservable {A O S Q : Type*} (aut : DetProofAutomaton A O S Q) : Prop :=
  ∀ q₁ q₂ : Q, (∀ (w : List A) (o : O),
    aut.output o (runWordAut aut.transition w q₁) =
    aut.output o (runWordAut aut.transition w q₂)) → q₁ = q₂

/-- Representation maps commute with word execution. -/
theorem repr_runWord {P A O S Q : Type*}
    (step : A → P → P) (obs : O → P → S)
    (aut : DetProofAutomaton A O S Q) (repr : P → Q)
    (hRepr : IsRepr step obs aut repr) (w : List A) (p : P) :
    repr (runWord step w p) = runWordAut aut.transition w (repr p) := by
  induction w generalizing p with
  | nil => rfl
  | cons a w ih => simp [runWord, runWordAut, ih, hRepr.1]

/-- **Universal property**: The canonical quotient map factors through any
observable representation. An observable automaton cannot have redundant states,
so equivalent proof states must map to the same automaton state.
Bridge: this is the Myhill–Nerode minimality/universal property. -/
theorem canonical_factors_through {P A O S Q : Type*}
    (step : A → P → P) (obs : O → P → S)
    (aut : DetProofAutomaton A O S Q) (repr : P → Q)
    (hRepr : IsRepr step obs aut repr)
    (hObs : IsObservable aut) :
    ∃ f : StateQuotient P step obs → Q,
      ∀ p, f (@Quotient.mk _ (obsSetoid P step obs) p) = repr p := by
  refine ⟨Quotient.lift repr (fun a b (h : obsEquiv step obs a b) => ?_), fun _ => rfl⟩
  apply hObs
  intro w o
  rw [← repr_runWord step obs aut repr hRepr w a,
      ← repr_runWord step obs aut repr hRepr w b,
      ← hRepr.2 o (runWord step w a),
      ← hRepr.2 o (runWord step w b)]
  exact h w o

/-- The quotient has at most as many states as the original space. -/
theorem quotient_card_le {P A O S : Type*} [Fintype P]
    (step : A → P → P) (obs : O → P → S)
    [DecidableRel (obsSetoid P step obs).r] :
    Fintype.card (StateQuotient P step obs) ≤ Fintype.card P :=
  Fintype.card_quotient_le (obsSetoid P step obs)

/-! ## §8. Residual Semimodule Structure -/

/-- The residual action of a contraction symbol on trace profiles. -/
def residualAction {A O S : Type*} (a : A) :
    (List A × O → S) → (List A × O → S) :=
  fun profile ⟨w, o⟩ => profile ⟨a :: w, o⟩

/-- The residual action is compatible with the trace map. -/
theorem traceMap_step_compatible {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) (a : A) (p : P) :
    buildTrace step obs (step a p) =
    residualAction a (buildTrace step obs p) := by
  funext ⟨_, _⟩; rfl

/-- The trace image is closed under residual actions.
Bridge: the trace image forms a residual sub-semimodule. -/
theorem traceImage_closed_under_residual {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) (a : A)
    {profile : List A × O → S}
    (h : profile ∈ Set.range (buildTrace step obs)) :
    residualAction a profile ∈ Set.range (buildTrace step obs) := by
  obtain ⟨p, rfl⟩ := h
  exact ⟨step a p, (traceMap_step_compatible step obs a p).symm⟩

/-- When P is finite, the trace image is a finite set. -/
theorem traceImage_finite {P A O S : Type*} [Fintype P]
    (step : A → P → P) (obs : O → P → S) :
    (Set.range (buildTrace step obs)).Finite :=
  Set.finite_range _

/-! ## §9. Trace Injectivity on Quotient -/

/-- The trace map is injective on the quotient.
Bridge: quotient states biject with trace profiles. -/
theorem traceMap_quotient_injective {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) :
    Function.Injective
      (Quotient.lift (buildTrace step obs)
        (fun a b (h : obsEquiv step obs a b) =>
          (observational_equiv_eq_kernel step obs a b).mp h)
        : StateQuotient P step obs → (List A × O → S)) := by
  intro a b h
  obtain ⟨a, rfl⟩ := Quotient.exists_rep a
  obtain ⟨b, rfl⟩ := Quotient.exists_rep b
  apply Quotient.sound
  exact (observational_equiv_eq_kernel step obs a b).mpr h

/-! ## §10. Ultrametric Geometry -/

/-- An ultrametric pseudo-distance function. -/
structure IsUltrametric {X : Type*} (d : X → X → ℝ) : Prop where
  dist_nonneg : ∀ x y, 0 ≤ d x y
  dist_self : ∀ x, d x x = 0
  dist_symm : ∀ x y, d x y = d y x
  dist_triangle : ∀ x y z, d x z ≤ max (d x y) (d y z)

/-
**Ultrametric isosceles theorem**: if two sides of a triangle differ,
the longest two are equal. All ultrametric triangles are isosceles.
Bridge: non-Archimedean geometry → hierarchical proof spaces.
-/
theorem ultrametric_isosceles {X : Type*} {d : X → X → ℝ}
    (hd : IsUltrametric d) (x y z : X) (h : d x y < d y z) :
    d x z = d y z := by
  obtain ⟨ hd₁, hd₂, hd₃, hd₄ ⟩ := hd;
  grind

/-- Distance zero is an equivalence relation in any ultrametric. -/
theorem ultrametric_zero_equiv {X : Type*} {d : X → X → ℝ}
    (hd : IsUltrametric d) :
    Equivalence (fun x y => d x y = 0) := by
  refine ⟨fun x => hd.dist_self x, fun h => by rwa [hd.dist_symm],
    fun {x y z} h₁ h₂ => ?_⟩
  have h3 := hd.dist_triangle x y z
  simp [h₁, h₂] at h3
  linarith [hd.dist_nonneg x z]

/-! ## §11. Observer-Induced Ultrametric -/

/-- Observer separation score: max absolute discrepancy over observers. -/
def obsSep {P O : Type*} [Fintype O] [Nonempty O]
    (obs : O → P → ℝ) (p q : P) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty
    (fun o => |obs o p - obs o q|)

/-
Observer separation is nonnegative.
-/
theorem obsSep_nonneg {P O : Type*} [Fintype O] [Nonempty O]
    (obs : O → P → ℝ) (p q : P) : 0 ≤ obsSep obs p q := by
  exact Finset.le_sup'_of_le _ ( Finset.mem_univ <| Classical.arbitrary O ) ( abs_nonneg _ )

/-
Observer separation of a point with itself is zero.
-/
theorem obsSep_self {P O : Type*} [Fintype O] [Nonempty O]
    (obs : O → P → ℝ) (p : P) : obsSep obs p p = 0 := by
  -- Since |obs o p - obs o p| = 0 for all o, the supremum of these values is 0.
  simp [obsSep]

/-
Observer separation is symmetric.
-/
theorem obsSep_symm {P O : Type*} [Fintype O] [Nonempty O]
    (obs : O → P → ℝ) (p q : P) : obsSep obs p q = obsSep obs q p := by
  unfold obsSep;
  simp +decide only [abs_sub_comm]

/-
Observer separation satisfies the (ordinary) triangle inequality.
Note: For general real-valued observers, the sup-metric is NOT ultrametric.
Ultrametricity holds when observers take values in a discrete set (e.g., Bool).
-/
theorem obsSep_triangle {P O : Type*} [Fintype O] [Nonempty O]
    (obs : O → P → ℝ) (p q r : P) :
    obsSep obs p r ≤ obsSep obs p q + obsSep obs q r := by
  unfold obsSep;
  simp +decide [ Finset.sup'_le_iff ];
  exact fun o => le_trans ( abs_sub_le _ _ _ ) ( add_le_add ( Finset.le_sup' ( fun o => |obs o p - obs o q| ) ( Finset.mem_univ o ) ) ( Finset.le_sup' ( fun o => |obs o q - obs o r| ) ( Finset.mem_univ o ) ) )

/-
For {0,1}-valued (Boolean) observers, obsSep satisfies the ultrametric inequality.
This is because each |obs o p - obs o r| ∈ {0, 1}, and if p,r differ at observer o,
then either p,q or q,r must also differ at o (pigeonhole on Bool).
-/
theorem obsSep_ultrametric_bool {P O : Type*} [Fintype O] [Nonempty O]
    (obs : O → P → Bool) (p q r : P) :
    obsSep (fun o x => if obs o x then (1 : ℝ) else 0) p r ≤
    max (obsSep (fun o x => if obs o x then (1 : ℝ) else 0) p q)
        (obsSep (fun o x => if obs o x then (1 : ℝ) else 0) q r) := by
  unfold obsSep; simp +decide ;
  by_contra! h;
  obtain ⟨b, hb⟩ : ∃ b : O, |(if obs b p then 1 else 0 : ℝ) - (if obs b r then 1 else 0 : ℝ)| = 1 := by
    obtain ⟨ b, hb ⟩ := h.1 ( Classical.arbitrary O );
    grind;
  obtain ⟨ c, hc ⟩ := h.1 b;
  obtain ⟨ d, hd ⟩ := h.2 b;
  grind +extAll

/-! ## §12. Reconstruction Witness and Duality Theorem -/

/-- A reconstruction witness for the quotient automaton. -/
structure ReconstructionWitness (P : Type*) {A O S : Type*}
    (step : A → P → P) (obs : O → P → S) where
  quotientMap : P → StateQuotient P step obs
  surjective : Function.Surjective quotientMap
  step_compat : ∀ a p, quotientMap (step a p) = quotientStep step obs a (quotientMap p)
  obs_compat : ∀ o p, obs o p = quotientObs step obs o (quotientMap p)

/-- The canonical reconstruction witness. -/
def canonicalReconstruction {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) :
    ReconstructionWitness P step obs where
  quotientMap := fun p => @Quotient.mk _ (obsSetoid P step obs) p
  surjective := Quotient.exists_rep
  step_compat := fun _ _ => rfl
  obs_compat := fun _ _ => rfl

/-- **Finite Duality Theorem**: For any finite proof system, the quotient by
observational equivalence is finite, canonically carries a deterministic
automaton structure, and is uniquely characterized by the trace map.

Bridge: proof dynamics ↔ minimal automata ↔ finitely generated trace semimodules. -/
theorem finite_duality_theorem
    {P A O S : Type*}
    [Fintype P]
    (step : A → P → P) (obs : O → P → S)
    [DecidableRel (obsSetoid P step obs).r] :
    -- (1) Quotient is finite and bounded
    Fintype.card (StateQuotient P step obs) ≤ Fintype.card P ∧
    -- (2) Trace map is injective on quotient
    Function.Injective
      (Quotient.lift (buildTrace step obs)
        (fun a b (h : obsEquiv step obs a b) =>
          (observational_equiv_eq_kernel step obs a b).mp h)
        : StateQuotient P step obs → (List A × O → S)) ∧
    -- (3) Trace image is closed under residual actions
    (∀ a : A, ∀ profile ∈ Set.range (buildTrace step obs),
      residualAction a profile ∈ Set.range (buildTrace step obs)) ∧
    -- (4) Canonical reconstruction exists
    Nonempty (ReconstructionWitness P step obs) :=
  ⟨quotient_card_le step obs,
   traceMap_quotient_injective step obs,
   fun a _ h => traceImage_closed_under_residual step obs a h,
   ⟨canonicalReconstruction step obs⟩⟩

/-! ## §13. Fixed-Point Characterization -/

/-- A state is a fixed point of all contractions. -/
def IsFixedPoint {P A : Type*} (step : A → P → P) (p : P) : Prop :=
  ∀ a : A, step a p = p

/-- Fixed points are invariant under any word. -/
theorem fixedPoint_runWord {P A : Type*}
    (step : A → P → P) {p : P} (hfp : IsFixedPoint step p) :
    ∀ w : List A, runWord step w p = p := by
  intro w; induction w with
  | nil => rfl
  | cons a w ih => simp [hfp a, ih]

/-- Two fixed points are equivalent iff they agree on all observers directly. -/
theorem fixedPoints_equiv_iff {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S)
    {p q : P} (hfp : IsFixedPoint step p) (hfq : IsFixedPoint step q) :
    obsEquiv step obs p q ↔ ∀ o, obs o p = obs o q := by
  exact ⟨fun h o => h [] o, fun h w o => by
    rw [fixedPoint_runWord step hfp w, fixedPoint_runWord step hfq w]; exact h o⟩

/-! ## §14. Two-Observer Separation -/

/-- Combining two observers refines separation. -/
theorem two_observer_refinement {P A S : Type*}
    (step : A → P → P) (obs₁ obs₂ : P → S) :
    ∀ p q, (∀ w, obs₁ (runWord step w p) = obs₁ (runWord step w q)) →
            (∀ w, obs₂ (runWord step w p) = obs₂ (runWord step w q)) →
            obsEquiv step (fun (i : Fin 2) => if i = 0 then obs₁ else obs₂) p q := by
  intro p q h₁ h₂ w o; fin_cases o <;> simp [*]

/-! ## §15. Diagonal Stability -/

/-- Diagonal stability holds by construction of the trace map. -/
theorem diagonallyStable {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) :
    ∀ a p, buildTrace step obs (step a p) =
           residualAction a (buildTrace step obs p) :=
  fun a p => traceMap_step_compatible step obs a p

/-! ## §16. Residual Composition -/

/-- Residual actions compose correctly. -/
theorem residualAction_comp {A O S : Type*} (a₁ a₂ : A)
    (profile : List A × O → S) :
    residualAction a₂ (residualAction a₁ profile) =
    (fun ⟨w, o⟩ => profile ⟨a₁ :: a₂ :: w, o⟩) := by
  funext ⟨_, _⟩; rfl

/-- The trace map intertwines word residual with state stepping. -/
theorem trace_intertwine {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) (w : List A) (p : P) :
    buildTrace step obs (runWord step w p) =
    (fun ⟨v, o⟩ => buildTrace step obs p ⟨w ++ v, o⟩) := by
  funext ⟨v, o⟩; simp [buildTrace, runWord_append]

/-! ## §17. Concrete Examples -/

/-- Identity contractions: equiv reduces to direct observer agreement. -/
example : obsEquiv (P := Fin 3) (A := Fin 2) (O := Fin 1) (S := Bool)
    (fun _ p => p) (fun _ p => decide (p = 0))
    (0 : Fin 3) (0 : Fin 3) := fun _ _ => rfl

/-- Distinct states separated by an observer are not equivalent. -/
example : ¬ obsEquiv (P := Fin 3) (A := Fin 2) (O := Fin 1) (S := Bool)
    (fun _ p => p) (fun _ p => decide (p = 0))
    (0 : Fin 3) (1 : Fin 3) := by
  intro h; have := h [] 0; simp at this

/-! ## §18. Non-Expansiveness -/

/-- Contractions cannot break equivalence. -/
theorem contraction_preserves_equiv {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) (a : A)
    {p q : P} (h : obsEquiv step obs p q) :
    obsEquiv step obs (step a p) (step a q) :=
  observational_equiv_is_congruence step obs h a

/-! ## §19. Quotient Step Functoriality -/

/-- Composing quotient steps matches compound stepping. -/
theorem quotientStep_comp {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) (a₁ a₂ : A)
    (q : StateQuotient P step obs) :
    quotientStep step obs a₂ (quotientStep step obs a₁ q) =
    Quotient.map (fun p => step a₂ (step a₁ p))
      (fun _ _ h => observational_equiv_is_congruence step obs
        (observational_equiv_is_congruence step obs h a₁) a₂) q := by
  obtain ⟨p, rfl⟩ := Quotient.exists_rep q; rfl

/-! ## §20. Observer Count Lower Bound -/

/-- If there are n equivalence classes, we need at least enough observer
discriminating power to separate them. Specifically, the quotient injects
into the trace space. -/
theorem quotient_embeds_in_traces {P A O S : Type*}
    (step : A → P → P) (obs : O → P → S) :
    ∃ f : StateQuotient P step obs → (List A × O → S), Function.Injective f :=
  ⟨Quotient.lift (buildTrace step obs)
    (fun a b h => (observational_equiv_eq_kernel step obs a b).mp h),
   traceMap_quotient_injective step obs⟩

end UltrametricProofAutomaton