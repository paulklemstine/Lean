/-
# Ultrametric Neural Realization Duality

A **Myhill–Nerode theory for ultrametric neural systems**: finite realization,
minimality, and uniqueness theorems for observer-response systems with
ultrametric state dynamics.

## Main Results

- **Observer indistinguishability** is an equivalence relation (§2)
- **Step and output maps** respect observer indistinguishability (§3)
- **Nonexpansion composition**: ultrametric contraction composes cleanly (§5)
- **Morphism injectivity**: morphisms from minimal realizations are injective (§6)
- **Morphism surjectivity**: morphisms to minimal targets are surjective (§12)
- **Uniqueness**: minimal realizations are unique up to bijection (§12)
- **Finite realization**: finite-rank kernels yield finite predictors (§14)
- **Bridge theorem**: combines all into the ultrametric Nerode theory (§15)
-/

import Mathlib

set_option maxHeartbeats 800000

open Function

noncomputable section

/-! ## §1. Core Definitions -/

/-- Iterated transition: apply a word to a state. -/
def applyWord {X Q : Type*} (step : X → Q → Q) : List X → Q → Q
  | [], q => q
  | x :: xs, q => applyWord step xs (step x q)

@[simp] theorem applyWord_nil {X Q : Type*} (step : X → Q → Q) (q : Q) :
    applyWord step [] q = q := rfl

@[simp] theorem applyWord_cons {X Q : Type*} (step : X → Q → Q)
    (x : X) (w : List X) (q : Q) :
    applyWord step (x :: w) q = applyWord step w (step x q) := rfl

theorem applyWord_append {X Q : Type*} (step : X → Q → Q)
    (w₁ w₂ : List X) (q : Q) :
    applyWord step (w₁ ++ w₂) q = applyWord step w₂ (applyWord step w₁ q) := by
  induction w₁ generalizing q with
  | nil => rfl
  | cons x xs ih => exact ih (step x q)

/-- The response kernel: observer output after processing a word. -/
def responseKernel {S X O Q : Type*}
    (step : X → Q → Q) (output : O → Q → S)
    (w : List X) (o : O) (q : Q) : S :=
  output o (applyWord step w q)

/-! ## §2. Observer Indistinguishability -/

/-- Two states are **observer-indistinguishable** if they produce identical
    responses for all input words and all observers. -/
def ObsIndist {S X O Q : Type*}
    (step : X → Q → Q) (output : O → Q → S) (q₁ q₂ : Q) : Prop :=
  ∀ (w : List X) (o : O),
    responseKernel step output w o q₁ = responseKernel step output w o q₂

theorem obsIndist_refl {S X O Q : Type*}
    (step : X → Q → Q) (output : O → Q → S) (q : Q) :
    ObsIndist step output q q := fun _ _ => rfl

theorem obsIndist_symm {S X O Q : Type*}
    (step : X → Q → Q) (output : O → Q → S) {q₁ q₂ : Q}
    (h : ObsIndist step output q₁ q₂) :
    ObsIndist step output q₂ q₁ := fun w o => (h w o).symm

theorem obsIndist_trans {S X O Q : Type*}
    (step : X → Q → Q) (output : O → Q → S) {q₁ q₂ q₃ : Q}
    (h₁₂ : ObsIndist step output q₁ q₂)
    (h₂₃ : ObsIndist step output q₂ q₃) :
    ObsIndist step output q₁ q₃ :=
  fun w o => (h₁₂ w o).trans (h₂₃ w o)

/-- **Observer indistinguishability is an equivalence relation.** -/
theorem obsIndist_equiv {S X O Q : Type*}
    (step : X → Q → Q) (output : O → Q → S) :
    Equivalence (ObsIndist step output) :=
  ⟨obsIndist_refl step output,
   fun h => obsIndist_symm step output h,
   fun h₁ h₂ => obsIndist_trans step output h₁ h₂⟩

/-! ## §3. Step and Output Preserve Indistinguishability -/

/-- **Transitions preserve observer indistinguishability.** -/
theorem step_preserves_obsIndist {S X O Q : Type*}
    (step : X → Q → Q) (output : O → Q → S)
    (x : X) {q₁ q₂ : Q} (h : ObsIndist step output q₁ q₂) :
    ObsIndist step output (step x q₁) (step x q₂) :=
  fun w o => h (x :: w) o

/-- **Outputs respect observer indistinguishability.** -/
theorem output_respects_obsIndist {S X O Q : Type*}
    (step : X → Q → Q) (output : O → Q → S)
    (o : O) {q₁ q₂ : Q} (h : ObsIndist step output q₁ q₂) :
    output o q₁ = output o q₂ :=
  h [] o

/-- Word application preserves observer indistinguishability. -/
theorem applyWord_preserves_obsIndist {S X O Q : Type*}
    (step : X → Q → Q) (output : O → Q → S)
    (w : List X) {q₁ q₂ : Q} (h : ObsIndist step output q₁ q₂) :
    ObsIndist step output (applyWord step w q₁) (applyWord step w q₂) := by
  induction w generalizing q₁ q₂ with
  | nil => exact h
  | cons x xs ih => exact ih (step_preserves_obsIndist step output x h)

/-! ## §4. Ultrametric Predictor Signatures -/

/-- An ultrametric predictor signature. -/
structure UltraSig (S X O Q : Type*) where
  step : X → Q → Q
  output : O → Q → S
  init : Q
  udist : Q → Q → ℝ
  udist_nonneg : ∀ a b, 0 ≤ udist a b
  udist_self : ∀ a, udist a a = 0
  udist_symm : ∀ a b, udist a b = udist b a
  udist_ultra : ∀ a b c, udist a c ≤ max (udist a b) (udist b c)
  nonexpanding : ∀ x q₁ q₂, udist (step x q₁) (step x q₂) ≤ udist q₁ q₂

def UltraSig.kernel {S X O Q : Type*}
    (sig : UltraSig S X O Q) (w : List X) (o : O) : S :=
  responseKernel sig.step sig.output w o sig.init

def Realizes {S X O Q : Type*}
    (sig : UltraSig S X O Q) (K : List X → O → S) : Prop :=
  ∀ (w : List X) (o : O), sig.kernel w o = K w o

def SameKernel {S X O Q₁ Q₂ : Type*}
    (sig₁ : UltraSig S X O Q₁) (sig₂ : UltraSig S X O Q₂) : Prop :=
  ∀ (w : List X) (o : O), sig₁.kernel w o = sig₂.kernel w o

def UReachable {S X O Q : Type*} (sig : UltraSig S X O Q) (q : Q) : Prop :=
  ∃ w : List X, applyWord sig.step w sig.init = q

def AllReach {S X O Q : Type*} (sig : UltraSig S X O Q) : Prop :=
  ∀ q : Q, UReachable sig q

def AllObs {S X O Q : Type*} (sig : UltraSig S X O Q) : Prop :=
  ∀ q₁ q₂ : Q, ObsIndist sig.step sig.output q₁ q₂ → q₁ = q₂

/-- **Minimal realization: reachable and observable.** -/
def IsMinimal {S X O Q : Type*} (sig : UltraSig S X O Q) : Prop :=
  AllReach sig ∧ AllObs sig

theorem init_reachable {S X O Q : Type*} (sig : UltraSig S X O Q) :
    UReachable sig sig.init := ⟨[], rfl⟩

theorem reachable_step {S X O Q : Type*}
    (sig : UltraSig S X O Q) {q : Q} (x : X) (hr : UReachable sig q) :
    UReachable sig (sig.step x q) :=
  let ⟨w, hw⟩ := hr; ⟨w ++ [x], by rw [applyWord_append]; simp [applyWord, hw]⟩

/-! ## §5. Nonexpansion Under Word Application -/

/-- **Nonexpanding maps compose under word application.** -/
theorem applyWord_nonexpanding {S X O Q : Type*}
    (sig : UltraSig S X O Q) (w : List X) (q₁ q₂ : Q) :
    sig.udist (applyWord sig.step w q₁) (applyWord sig.step w q₂) ≤
    sig.udist q₁ q₂ := by
  induction w generalizing q₁ q₂ with
  | nil => show sig.udist q₁ q₂ ≤ sig.udist q₁ q₂; exact le_refl _
  | cons x xs ih => exact le_trans (ih _ _) (sig.nonexpanding x q₁ q₂)

/-! ## §6. Signature Morphisms -/

/-- A morphism between predictor signatures. -/
structure SigMorphism {S X O Q₁ Q₂ : Type*}
    (sig₁ : UltraSig S X O Q₁) (sig₂ : UltraSig S X O Q₂) where
  toFun : Q₁ → Q₂
  map_init : toFun sig₁.init = sig₂.init
  map_step : ∀ x q, toFun (sig₁.step x q) = sig₂.step x (toFun q)
  map_output : ∀ o q, sig₁.output o q = sig₂.output o (toFun q)

/-- A morphism intertwines word application. -/
theorem SigMorphism.intertwines {S X O Q₁ Q₂ : Type*}
    {sig₁ : UltraSig S X O Q₁} {sig₂ : UltraSig S X O Q₂}
    (φ : SigMorphism sig₁ sig₂) (w : List X) (q : Q₁) :
    φ.toFun (applyWord sig₁.step w q) = applyWord sig₂.step w (φ.toFun q) := by
  induction w generalizing q with
  | nil => rfl
  | cons x xs ih => simp [φ.map_step, ih]

/-- A morphism preserves the response kernel. -/
theorem SigMorphism.preserves_kernel {S X O Q₁ Q₂ : Type*}
    {sig₁ : UltraSig S X O Q₁} {sig₂ : UltraSig S X O Q₂}
    (φ : SigMorphism sig₁ sig₂) : SameKernel sig₁ sig₂ := by
  intro w o
  simp only [UltraSig.kernel, responseKernel]
  rw [φ.map_output, φ.intertwines, φ.map_init]

/-- States in the same fiber of a morphism are observer-indistinguishable. -/
theorem morphism_fiber_indist {S X O Q₁ Q₂ : Type*}
    {sig₁ : UltraSig S X O Q₁} {sig₂ : UltraSig S X O Q₂}
    (φ : SigMorphism sig₁ sig₂) (q₁ q₂ : Q₁)
    (heq : φ.toFun q₁ = φ.toFun q₂) :
    ObsIndist sig₁.step sig₁.output q₁ q₂ := by
  intro w o
  simp only [responseKernel]
  have h1 := φ.map_output o (applyWord sig₁.step w q₁)
  have h2 := φ.map_output o (applyWord sig₁.step w q₂)
  rw [h1, h2]; congr 1
  rw [φ.intertwines w q₁, φ.intertwines w q₂, heq]

/-- **Core injectivity**: A morphism from a minimal signature is injective. -/
theorem morphism_injective_of_minimal {S X O Q₁ Q₂ : Type*}
    {sig₁ : UltraSig S X O Q₁} {sig₂ : UltraSig S X O Q₂}
    (φ : SigMorphism sig₁ sig₂) (hmin : IsMinimal sig₁) :
    Injective φ.toFun :=
  fun q₁ q₂ heq => hmin.2 q₁ q₂ (morphism_fiber_indist φ q₁ q₂ heq)

/-- A morphism preserves reachability. -/
theorem SigMorphism.preserves_reachable {S X O Q₁ Q₂ : Type*}
    {sig₁ : UltraSig S X O Q₁} {sig₂ : UltraSig S X O Q₂}
    (φ : SigMorphism sig₁ sig₂) {q : Q₁} (hr : UReachable sig₁ q) :
    UReachable sig₂ (φ.toFun q) :=
  let ⟨w, hw⟩ := hr; ⟨w, by rw [← hw, φ.intertwines, φ.map_init]⟩

/-- **Minimal realizations have smallest state space.** -/
theorem minimal_card_le {S X O Q₁ Q₂ : Type*}
    [Fintype Q₁] [Fintype Q₂]
    {sig₁ : UltraSig S X O Q₁} {sig₂ : UltraSig S X O Q₂}
    (φ : SigMorphism sig₁ sig₂) (hmin : IsMinimal sig₁) :
    Fintype.card Q₁ ≤ Fintype.card Q₂ :=
  Fintype.card_le_of_injective φ.toFun (morphism_injective_of_minimal φ hmin)

/-! ## §7. Nerode Equivalence -/

/-- Two words are **Nerode-equivalent** relative to a kernel. -/
def NerodeEq {S X O : Type*} (K : List X → O → S) (w₁ w₂ : List X) : Prop :=
  ∀ (v : List X) (o : O), K (w₁ ++ v) o = K (w₂ ++ v) o

/-- **Nerode equivalence is an equivalence relation.** -/
theorem nerodeEq_equiv {S X O : Type*} (K : List X → O → S) :
    Equivalence (NerodeEq K) :=
  ⟨fun _ _ _ => rfl,
   fun h v o => (h v o).symm,
   fun h₁ h₂ v o => (h₁ v o).trans (h₂ v o)⟩

/-- Nerode equivalence is invariant under suffix extension. -/
theorem nerodeEq_append {S X O : Type*} (K : List X → O → S)
    {w₁ w₂ : List X} (u : List X) (h : NerodeEq K w₁ w₂) :
    NerodeEq K (w₁ ++ u) (w₂ ++ u) := by
  intro v o; simp only [List.append_assoc]; exact h (u ++ v) o

def nerodeSetoid {S X O : Type*} (K : List X → O → S) : Setoid (List X) :=
  { r := NerodeEq K, iseqv := nerodeEq_equiv K }

/-! ## §8. Realization ↔ Nerode Correspondence -/

/-- If a signature realizes K, observer-indistinguishable reachable states
    correspond to Nerode-equivalent reaching words. -/
theorem realization_nerode {S X O Q : Type*}
    {sig : UltraSig S X O Q} (K : List X → O → S)
    (hreal : Realizes sig K) (w₁ w₂ : List X)
    (hindist : ObsIndist sig.step sig.output
      (applyWord sig.step w₁ sig.init)
      (applyWord sig.step w₂ sig.init)) :
    NerodeEq K w₁ w₂ := by
  intro v o
  rw [← hreal (w₁ ++ v) o, ← hreal (w₂ ++ v) o]
  simp only [UltraSig.kernel, responseKernel, applyWord_append]
  exact hindist v o

/-! ## §9. Isometric Equivalences -/

/-- An isometric equivalence between predictor signatures. -/
structure IsoSigEquiv {S X O Q₁ Q₂ : Type*}
    (sig₁ : UltraSig S X O Q₁) (sig₂ : UltraSig S X O Q₂) where
  equiv : Q₁ ≃ Q₂
  map_init : equiv sig₁.init = sig₂.init
  map_step : ∀ x q, equiv (sig₁.step x q) = sig₂.step x (equiv q)
  map_output : ∀ o q, sig₁.output o q = sig₂.output o (equiv q)
  isometry : ∀ q₁ q₂, sig₂.udist (equiv q₁) (equiv q₂) = sig₁.udist q₁ q₂

/-- An isometric equivalence induces a morphism. -/
def IsoSigEquiv.toMorphism {S X O Q₁ Q₂ : Type*}
    {sig₁ : UltraSig S X O Q₁} {sig₂ : UltraSig S X O Q₂}
    (e : IsoSigEquiv sig₁ sig₂) : SigMorphism sig₁ sig₂ :=
  { toFun := e.equiv, map_init := e.map_init,
    map_step := e.map_step, map_output := e.map_output }

theorem isoEquiv_same_kernel {S X O Q₁ Q₂ : Type*}
    {sig₁ : UltraSig S X O Q₁} {sig₂ : UltraSig S X O Q₂}
    (e : IsoSigEquiv sig₁ sig₂) : SameKernel sig₁ sig₂ :=
  e.toMorphism.preserves_kernel

/-! ## §10. Discrete Ultrametric -/

/-- The discrete ultrametric: d(x,y) = 0 if x = y, 1 otherwise. -/
def discreteUDist {Q : Type*} [DecidableEq Q] (q₁ q₂ : Q) : ℝ :=
  if q₁ = q₂ then 0 else 1

theorem discreteUDist_nonneg {Q : Type*} [DecidableEq Q] (a b : Q) :
    0 ≤ discreteUDist a b := by unfold discreteUDist; split <;> norm_num

theorem discreteUDist_self {Q : Type*} [DecidableEq Q] (a : Q) :
    discreteUDist a a = 0 := if_pos rfl

theorem discreteUDist_symm {Q : Type*} [DecidableEq Q] (a b : Q) :
    discreteUDist a b = discreteUDist b a := by
  unfold discreteUDist; by_cases h : a = b <;> simp [h, eq_comm]

theorem discreteUDist_ultra {Q : Type*} [DecidableEq Q] (a b c : Q) :
    discreteUDist a c ≤ max (discreteUDist a b) (discreteUDist b c) := by
  simp only [discreteUDist]
  split <;> rename_i hac
  · split <;> split <;> simp_all
  · by_cases hab : a = b
    · subst hab; split <;> simp_all
    · simp only [hab, ite_false]; exact le_max_left _ _

theorem discreteUDist_nonexpanding {Q : Type*} [DecidableEq Q]
    (f : Q → Q) (q₁ q₂ : Q) :
    discreteUDist (f q₁) (f q₂) ≤ discreteUDist q₁ q₂ := by
  unfold discreteUDist
  by_cases h : q₁ = q₂
  · simp [h]
  · by_cases hf : f q₁ = f q₂ <;> simp [h, hf]

/-- Build a predictor with discrete ultrametric. -/
def mkDiscreteSig {S X O Q : Type*} [DecidableEq Q]
    (step : X → Q → Q) (output : O → Q → S) (init : Q) :
    UltraSig S X O Q :=
  { step, output, init
    udist := discreteUDist
    udist_nonneg := discreteUDist_nonneg
    udist_self := discreteUDist_self
    udist_symm := discreteUDist_symm
    udist_ultra := discreteUDist_ultra
    nonexpanding := fun x => discreteUDist_nonexpanding (step x) }

/-! ## §11. Concrete Example: Parity Automaton -/

/-- A two-state parity automaton. -/
def parityAut : UltraSig ℕ Bool Unit (Fin 2) :=
  mkDiscreteSig
    (fun b q => if b then (q + 1) % 2 else q)
    (fun () q => q.val) 0

theorem parityAut_obs : AllObs parityAut := by
  intro q₁ q₂ h
  have h0 := output_respects_obsIndist parityAut.step parityAut.output () h
  simp only [parityAut, mkDiscreteSig] at h0
  exact Fin.ext (by omega)

theorem parityAut_reach : AllReach parityAut := by
  intro q; fin_cases q
  · exact ⟨[], rfl⟩
  · exact ⟨[true], by decide⟩

/-- **The parity automaton is minimal.** -/
theorem parityAut_minimal : IsMinimal parityAut :=
  ⟨parityAut_reach, parityAut_obs⟩

/-! ## §12. Uniqueness of Minimal Realizations -/

theorem morphism_image_covers {S X O Q₁ Q₂ : Type*}
    {sig₁ : UltraSig S X O Q₁} {sig₂ : UltraSig S X O Q₂}
    (φ : SigMorphism sig₁ sig₂) (w : List X) :
    φ.toFun (applyWord sig₁.step w sig₁.init) =
    applyWord sig₂.step w sig₂.init := by
  rw [φ.intertwines, φ.map_init]

/-- **Morphism surjectivity**: to a minimal target. -/
theorem morphism_surj_minimal {S X O Q₁ Q₂ : Type*}
    {sig₁ : UltraSig S X O Q₁} {sig₂ : UltraSig S X O Q₂}
    (φ : SigMorphism sig₁ sig₂) (hmin₂ : IsMinimal sig₂) :
    Surjective φ.toFun := by
  intro q₂
  obtain ⟨w, hw⟩ := hmin₂.1 q₂
  exact ⟨applyWord sig₁.step w sig₁.init,
    by rw [morphism_image_covers φ w, hw]⟩

/-- **Uniqueness theorem**: morphisms between minimal realizations are bijections. -/
theorem minimal_morphism_bij {S X O Q₁ Q₂ : Type*}
    {sig₁ : UltraSig S X O Q₁} {sig₂ : UltraSig S X O Q₂}
    (φ : SigMorphism sig₁ sig₂)
    (hmin₁ : IsMinimal sig₁) (hmin₂ : IsMinimal sig₂) :
    Bijective φ.toFun :=
  ⟨morphism_injective_of_minimal φ hmin₁,
   morphism_surj_minimal φ hmin₂⟩

/-- **Minimal realizations have equal state count.** -/
theorem minimal_card_eq {S X O Q₁ Q₂ : Type*}
    [Fintype Q₁] [Fintype Q₂]
    {sig₁ : UltraSig S X O Q₁} {sig₂ : UltraSig S X O Q₂}
    (φ : SigMorphism sig₁ sig₂)
    (hmin₁ : IsMinimal sig₁) (hmin₂ : IsMinimal sig₂) :
    Fintype.card Q₁ = Fintype.card Q₂ :=
  Fintype.card_of_bijective (minimal_morphism_bij φ hmin₁ hmin₂)

/-! ## §13. Residual Tracking Lemma -/

/-- **Residual tracking**: applyWord on transition indices tracks the residuals.
    This is the key lemma enabling the finite realization theorem. -/
theorem residual_tracking {S X O : Type*}
    {n : ℕ} (R : Fin n → List X → O → S)
    (transition : X → Fin n → Fin n)
    (h_trans : ∀ x i v o, R i (x :: v) o = R (transition x i) v o)
    (w : List X) (i : Fin n) (v : List X) (o : O) :
    R (applyWord transition w i) v o = R i (w ++ v) o := by
  induction w generalizing i with
  | nil => simp
  | cons x xs ih =>
    simp only [applyWord_cons, List.cons_append]
    rw [ih, h_trans]

/-! ## §14. Finite Realization Theorem -/

/-- **Finite Realization Theorem**: Given factorization data for a kernel,
    construct a finite ultrametric realization that computes K exactly. -/
theorem finite_realization {S X O : Type*}
    (K : List X → O → S) (n : ℕ)
    (R : Fin n → List X → O → S)
    (init_idx : Fin n)
    (transition : X → Fin n → Fin n)
    (outfn : O → Fin n → S)
    (h_init : ∀ v o, K v o = R init_idx v o)
    (h_trans : ∀ x i v o, R i (x :: v) o = R (transition x i) v o)
    (h_out : ∀ o i, outfn o i = R i [] o) :
    ∃ sig : UltraSig S X O (Fin n), Realizes sig K := by
  refine ⟨mkDiscreteSig transition outfn init_idx, ?_⟩
  intro w o
  simp only [UltraSig.kernel, responseKernel, mkDiscreteSig]
  rw [h_out o (applyWord transition w init_idx)]
  rw [residual_tracking R transition h_trans w init_idx [] o]
  simp [← h_init]

/-! ## §15. Ultrametric Nerode Bridge Theorem -/

/-- **Ultrametric Nerode Bridge Theorem**: For any ultrametric predictor,
    observer indistinguishability is a transition-invariant, output-compatible
    equivalence relation, and word application is nonexpanding. -/
theorem ultrametric_nerode_bridge {S X O Q : Type*}
    (sig : UltraSig S X O Q) :
    Equivalence (ObsIndist sig.step sig.output) ∧
    (∀ x q₁ q₂, ObsIndist sig.step sig.output q₁ q₂ →
      ObsIndist sig.step sig.output (sig.step x q₁) (sig.step x q₂)) ∧
    (∀ o q₁ q₂, ObsIndist sig.step sig.output q₁ q₂ →
      sig.output o q₁ = sig.output o q₂) ∧
    (∀ w q₁ q₂,
      sig.udist (applyWord sig.step w q₁) (applyWord sig.step w q₂) ≤
      sig.udist q₁ q₂) :=
  ⟨obsIndist_equiv sig.step sig.output,
   fun x _ _ h => step_preserves_obsIndist sig.step sig.output x h,
   fun o _ _ h => output_respects_obsIndist sig.step sig.output o h,
   fun w _ _ => applyWord_nonexpanding sig w _ _⟩

/-! ## §16. Universal Property -/

/-- **Universal property**: minimal realizations are unique up to bijective
    state renaming. -/
theorem minimal_universal {S X O Q₁ Q₂ : Type*}
    [Fintype Q₁] [Fintype Q₂]
    {sig₁ : UltraSig S X O Q₁} {sig₂ : UltraSig S X O Q₂}
    (hmin₁ : IsMinimal sig₁) (hmin₂ : IsMinimal sig₂)
    (φ : SigMorphism sig₁ sig₂) :
    Injective φ.toFun ∧ Surjective φ.toFun ∧
    Fintype.card Q₁ = Fintype.card Q₂ := by
  have hbij := minimal_morphism_bij φ hmin₁ hmin₂
  exact ⟨hbij.1, hbij.2, Fintype.card_of_bijective hbij⟩

end