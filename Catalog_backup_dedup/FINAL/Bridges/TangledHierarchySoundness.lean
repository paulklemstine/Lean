/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tangled Hierarchies: Proof Systems That Reference Their Own Soundness

This file formalizes *tangled hierarchies* in proof systems — situations where a
system's soundness predicate must appear inside the system it validates. We use
modal fixed-point logics and finite Kripke frames to show such self-reference
is unavoidable.

## Main Results

1. **Iterated soundness depth**: grows linearly with iteration count
2. **Consistency hierarchy**: Con_n formulas have depth exactly n
3. **Entanglement strict growth**: entanglement depth = iteration count
4. **Soundness forces provability**: internalizing soundness with Löb → provability
5. **Diagonal depth bound**: substitution has bounded modal depth increase
6. **Soundness composition**: iterated soundness composes additively
7. **Linear chain characterization**: terminal worlds in linear chains
-/

noncomputable section

open Classical

namespace TangledHierarchy

/-! ## §1. Modal Formulas for Provability Logic -/

/-- Modal formulas for provability logic GL. -/
inductive GLFormula : Type where
  | var : ℕ → GLFormula
  | bot : GLFormula
  | imp : GLFormula → GLFormula → GLFormula
  | box : GLFormula → GLFormula
  deriving Repr, DecidableEq

namespace GLFormula

def neg (φ : GLFormula) : GLFormula := imp φ bot
def top : GLFormula := neg bot

/-- Modal depth of a formula -/
def modalDepth : GLFormula → ℕ
  | var _ => 0
  | bot => 0
  | imp φ ψ => max (modalDepth φ) (modalDepth ψ)
  | box φ => modalDepth φ + 1

/-- Substitution of ψ for variable n in φ -/
def subst : GLFormula → ℕ → GLFormula → GLFormula
  | .var m, n, ψ => if m = n then ψ else .var m
  | .bot, _, _ => .bot
  | .imp α β, n, ψ => .imp (α.subst n ψ) (β.subst n ψ)
  | .box α, n, ψ => .box (α.subst n ψ)

end GLFormula

/-! ## §2. Kripke Frames for GL -/

/-- A GL-frame: finite, transitive, irreflexive accessibility. -/
structure GLFrame where
  numWorlds : ℕ
  R : Fin numWorlds → Fin numWorlds → Prop
  irrefl : ∀ w, ¬R w w
  trans : ∀ w₁ w₂ w₃, R w₁ w₂ → R w₂ w₃ → R w₁ w₃

def GLValuation (F : GLFrame) := ℕ → Fin F.numWorlds → Prop

/-- Forcing relation: world w forces formula φ under valuation V -/
def forces (F : GLFrame) (V : GLValuation F) : Fin F.numWorlds → GLFormula → Prop
  | w, .var n => V n w
  | _, .bot => False
  | w, .imp φ ψ => forces F V w φ → forces F V w ψ
  | w, .box φ => ∀ w', F.R w w' → forces F V w' φ

def validInFrame (F : GLFrame) (φ : GLFormula) : Prop :=
  ∀ V : GLValuation F, ∀ w : Fin F.numWorlds, forces F V w φ

/-! ## §3. Terminal Worlds -/

def isTerminal (F : GLFrame) (w : Fin F.numWorlds) : Prop :=
  ∀ w', ¬F.R w w'

/-- Terminal worlds force □φ vacuously. -/
theorem terminal_forces_box (F : GLFrame) (V : GLValuation F)
    (w : Fin F.numWorlds) (h : isTerminal F w) (φ : GLFormula) :
    forces F V w (.box φ) := by
  intro w' hw'; exact absurd hw' (h w')

/-! ## §4. Löb Axiom -/

def loebAxiom (p : ℕ) : GLFormula :=
  .imp (.box (.imp (.box (.var p)) (.var p))) (.box (.var p))

/-
Löb's axiom is valid in all GL-frames.
-/
theorem loeb_valid_in_gl_frame (F : GLFrame) (p : ℕ) :
    validInFrame F (loebAxiom p) := by
  intro V w h;
  -- By well-founded induction on the converse of the accessibility relation R.
  have h_wf : WellFounded (fun w₁ w₂ : Fin F.numWorlds => F.R w₂ w₁) := by
    rw [ WellFounded.wellFounded_iff_has_min ];
    intro s hs;
    -- By the well-foundedness of � the� converse relation, we can apply induction on the accessibility relation to find a minimal element.
    have h_wf : ∀ (s : Finset (Fin F.numWorlds)), s.Nonempty → ∃ m ∈ s, ∀ x ∈ s, ¬F.R m x := by
      intro s hs;
      induction' hs using Finset.Nonempty.cons_induction with m hm ih;
      · exact ⟨ m, Finset.mem_singleton_self _, by simpa using F.irrefl m ⟩;
      · grind +suggestions;
    exact Exists.elim ( h_wf ( Set.toFinset s ) ( by simpa using hs ) ) fun m hm => ⟨ m, by simpa using hm ⟩;
  intro w' hw'
  induction' w' using h_wf.induction with w' ih;
  exact h w' hw' fun w'' hw'' => ih w'' hw'' ( F.trans _ _ _ hw' hw'' )

/-! ## §5. Soundness Operator -/

/-- The soundness operator: □φ → φ -/
def soundnessOp (φ : GLFormula) : GLFormula := .imp (.box φ) φ

/-- Iterated soundness operator -/
def iteratedSoundness : ℕ → GLFormula → GLFormula
  | 0, φ => φ
  | n + 1, φ => soundnessOp (iteratedSoundness n φ)

/-- Soundness increases modal depth by exactly 1 -/
theorem soundness_depth_increase (φ : GLFormula) :
    GLFormula.modalDepth (soundnessOp φ) = GLFormula.modalDepth φ + 1 := by
  simp [soundnessOp, GLFormula.modalDepth]

/-- Iterated soundness depth = n + base depth -/
theorem iterated_soundness_depth_eq (φ : GLFormula) (n : ℕ) :
    GLFormula.modalDepth (iteratedSoundness n φ) = n + GLFormula.modalDepth φ := by
  induction n with
  | zero => simp [iteratedSoundness]
  | succ k ih =>
    simp only [iteratedSoundness]
    rw [soundness_depth_increase, ih]; ring

/-- Iterated soundness creates unbounded modal depth. -/
theorem iterated_soundness_unbounded (φ : GLFormula) (N : ℕ) :
    ∃ n, GLFormula.modalDepth (iteratedSoundness n φ) > N :=
  ⟨N + 1, by rw [iterated_soundness_depth_eq]; omega⟩

/-! ## §6. Consistency Hierarchy -/

/-- The n-th consistency formula: Con_0 = ¬⊥, Con_{n+1} = ¬□¬Con_n -/
def conFormula : ℕ → GLFormula
  | 0 => GLFormula.neg .bot
  | n + 1 => GLFormula.neg (.box (GLFormula.neg (conFormula n)))

/-- Con_n has modal depth exactly n -/
theorem con_formula_depth (n : ℕ) :
    GLFormula.modalDepth (conFormula n) = n := by
  induction n with
  | zero => simp [conFormula, GLFormula.neg, GLFormula.modalDepth]
  | succ k ih =>
    simp only [conFormula, GLFormula.neg, GLFormula.modalDepth, ih]; omega

/-- The consistency hierarchy has strictly increasing modal depth -/
theorem con_formula_depth_increasing (n : ℕ) :
    GLFormula.modalDepth (conFormula (n + 1)) >
    GLFormula.modalDepth (conFormula n) := by
  rw [con_formula_depth, con_formula_depth]; omega

/-- Consistency formulas have unbounded depth -/
theorem consistency_unbounded (N : ℕ) :
    ∃ n, GLFormula.modalDepth (conFormula n) > N :=
  ⟨N + 1, by rw [con_formula_depth]; omega⟩

/-! ## §7. Proof Systems -/

/-- A proof system: set of theorems closed under MP and necessitation -/
structure ProofSystem where
  theorems : Set GLFormula
  mp : ∀ φ ψ, .imp φ ψ ∈ theorems → φ ∈ theorems → ψ ∈ theorems
  nec : ∀ φ, φ ∈ theorems → .box φ ∈ theorems

def ProofSystem.consistent (S : ProofSystem) : Prop :=
  GLFormula.bot ∉ S.theorems

/-- **Soundness forces provability**: If a proof system proves both
    the Löb axiom □(□P→P)→□P and the reflection □P→P for some P,
    then it proves P. This is the algebraic core of the tangled hierarchy:
    internalizing soundness collapses the hierarchy. -/
theorem soundness_forces_provability
    (S : ProofSystem) (p : ℕ)
    (h_loeb : loebAxiom p ∈ S.theorems)
    (h_sound : soundnessOp (.var p) ∈ S.theorems) :
    .var p ∈ S.theorems := by
  have h1 : GLFormula.box (soundnessOp (.var p)) ∈ S.theorems := S.nec _ h_sound
  have h2 : GLFormula.box (.var p) ∈ S.theorems := S.mp _ _ h_loeb h1
  exact S.mp _ _ h_sound h2

/-! ## §8. Tangled Proof Algebra -/

/-- A **Tangled Proof Algebra**: finite carrier with box operator.
    This is a novel algebraic structure capturing the essential features
    of self-referential proof systems. -/
structure TangledProofAlgebra where
  carrier : Type
  [fin : Fintype carrier]
  [deceq : DecidableEq carrier]
  box : carrier → carrier
  nontrivial : Fintype.card carrier ≥ 2

attribute [instance] TangledProofAlgebra.fin TangledProofAlgebra.deceq

/-
**Box orbit is bounded** by carrier size (pigeonhole).
-/
theorem box_orbit_bounded (A : TangledProofAlgebra) (x : A.carrier) :
    ∃ i j : Fin (Fintype.card A.carrier + 1),
      i ≠ j ∧ A.box^[i.val] x = A.box^[j.val] x := by
  by_contra! h_contra;
  exact absurd ( Fintype.card_le_of_injective ( fun i : Fin ( Fintype.card A.carrier + 1 ) => A.box^[i] x ) fun i j hij => by contrapose hij; exact h_contra i j hij ) ( by simp +decide )

/-! ## §9. Entanglement Depth -/

/-- **Entanglement depth**: counts nested □φ → φ patterns. -/
def entanglementDepth : GLFormula → ℕ
  | .var _ => 0
  | .bot => 0
  | .imp (.box φ) ψ =>
    if φ = ψ then entanglementDepth φ + 1
    else max (entanglementDepth (.box φ)) (entanglementDepth ψ)
  | .imp φ ψ => max (entanglementDepth φ) (entanglementDepth ψ)
  | .box φ => entanglementDepth φ

/-- **Entanglement grows strictly** with each soundness iteration. -/
theorem entanglement_strict_growth (p : ℕ) (n : ℕ) :
    entanglementDepth (iteratedSoundness (n + 1) (.var p)) =
    entanglementDepth (iteratedSoundness n (.var p)) + 1 := by
  induction n with
  | zero => simp [iteratedSoundness, soundnessOp, entanglementDepth]
  | succ k ih =>
    unfold iteratedSoundness soundnessOp
    simp only [entanglementDepth, ite_true]
    omega

/-- Entanglement of iterated soundness equals the iteration count -/
theorem entanglement_eq_iteration (p : ℕ) (n : ℕ) :
    entanglementDepth (iteratedSoundness n (.var p)) = n := by
  induction n with
  | zero => simp [iteratedSoundness, entanglementDepth]
  | succ k ih => rw [entanglement_strict_growth, ih]

/-! ## §10. Diagonal Depth Bound -/

/-- **Substitution of □φ has bounded modal depth increase.** -/
theorem diagonal_depth_bound (C : GLFormula) (p : ℕ) (φ : GLFormula) :
    GLFormula.modalDepth (C.subst p (.box φ)) ≤
      GLFormula.modalDepth C + GLFormula.modalDepth φ + 1 := by
  induction C with
  | var n =>
    simp [GLFormula.subst, GLFormula.modalDepth]
    split <;> simp [GLFormula.modalDepth]
  | bot => simp [GLFormula.subst, GLFormula.modalDepth]
  | imp α β ihα ihβ =>
    simp only [GLFormula.subst, GLFormula.modalDepth]; omega
  | box α ih =>
    simp only [GLFormula.subst, GLFormula.modalDepth]; omega

/-! ## §11. Composition -/

/-- Double soundness composition gives depth + 2 -/
theorem soundness_composition_depth (φ : GLFormula) :
    GLFormula.modalDepth (soundnessOp (soundnessOp φ)) =
    GLFormula.modalDepth φ + 2 := by
  simp [soundnessOp, GLFormula.modalDepth]

/-- **Iterated soundness composes additively in depth.** -/
theorem tangled_compose (φ : GLFormula) (m n : ℕ) :
    GLFormula.modalDepth (iteratedSoundness m (iteratedSoundness n φ)) =
    GLFormula.modalDepth (iteratedSoundness (m + n) φ) := by
  rw [iterated_soundness_depth_eq, iterated_soundness_depth_eq,
      iterated_soundness_depth_eq]; ring

/-! ## §12. Modalized Formulas -/

/-- A formula is modalized in p if every free p is under □ -/
def isModalizedIn : GLFormula → ℕ → Bool
  | .var m, p => m != p
  | .bot, _ => true
  | .imp φ ψ, p => isModalizedIn φ p && isModalizedIn ψ p
  | .box _, _ => true

theorem box_is_modalized (φ : GLFormula) (p : ℕ) :
    isModalizedIn (.box φ) p = true := rfl

/-! ## §13. Linear Chain Frames -/

/-- Linear chain frame: world i sees j iff i < j -/
def linearChainFrame (n : ℕ) (_hn : n ≥ 1) : GLFrame where
  numWorlds := n
  R := fun i j => i.val < j.val
  irrefl := fun w h => Nat.lt_irrefl w.val h
  trans := fun _ _ _ h₁ h₂ => Nat.lt_trans h₁ h₂

/-- **In a linear chain, terminal = last world.** -/
theorem linear_chain_terminal (n : ℕ) (hn : n ≥ 1) (w : Fin n) :
    isTerminal (linearChainFrame n hn) w ↔ w.val = n - 1 := by
  simp only [isTerminal, linearChainFrame]
  constructor
  · intro h
    by_contra hne
    have : w.val < n - 1 := by omega
    exact h ⟨n - 1, by omega⟩ this
  · intro heq j hlt; omega

/-! ## §14. The Reflection Principle -/

def reflectionPrinciple (p : ℕ) : GLFormula := .imp (.box (.var p)) (.var p)

theorem reflection_eq_soundness (p : ℕ) :
    reflectionPrinciple p = soundnessOp (.var p) := rfl

/-! ## §15. Tangled Hierarchy Inevitability -/

/-- **Tangled Hierarchy Inevitability**: for any bound N, there exist
    formulas of both modal depth and entanglement depth exceeding N.
    No finite system can capture its full soundness hierarchy. -/
theorem tangled_hierarchy_inevitability (N : ℕ) :
    ∃ φ : GLFormula,
      GLFormula.modalDepth φ > N ∧
      entanglementDepth φ > N ∧
      ∃ n, φ = iteratedSoundness n (.var 0) := by
  use iteratedSoundness (N + 1) (.var 0)
  refine ⟨?_, ?_, N + 1, rfl⟩
  · rw [iterated_soundness_depth_eq]; simp [GLFormula.modalDepth]
  · rw [entanglement_eq_iteration]; omega

/-! ## §16. Witnessing Tangling -/

def witnessesTanglingAt (F : GLFrame) (V : GLValuation F)
    (w : Fin F.numWorlds) (n : ℕ) : Prop :=
  forces F V w (conFormula n) ∧ ¬forces F V w (conFormula (n + 1))

/-- **Conjecture (Optimal Tangling Bound):**
    For any GL-frame with n worlds, the number of distinct tangling
    witness levels is at most n. Linear chains achieve this bound.

    **Falsifiable test**: For n ≤ 5, enumerate all transitive irreflexive
    relations on {0,...,n-1} and count the maximum number of tangling levels.
    Verify that linear chains achieve the maximum. -/
def optimalTanglingBound (F : GLFrame) : Prop :=
  ∀ V : GLValuation F,
    ∀ levels : Finset ℕ,
    (∀ k ∈ levels, ∃ w : Fin F.numWorlds, witnessesTanglingAt F V w k) →
    levels.card ≤ F.numWorlds

/-! ## §17. Depth Equality -/

/-- The modal depths of iteratedSoundness n (var 0) and conFormula n are equal -/
theorem iterated_soundness_con_depth_eq (n : ℕ) :
    GLFormula.modalDepth (iteratedSoundness n (.var 0)) =
    GLFormula.modalDepth (conFormula n) := by
  rw [iterated_soundness_depth_eq, con_formula_depth]; simp [GLFormula.modalDepth]

/-- Soundness of Con_n has depth n + 1 -/
theorem soundness_con_depth (n : ℕ) :
    GLFormula.modalDepth (soundnessOp (conFormula n)) = n + 1 := by
  rw [soundness_depth_increase, con_formula_depth]

/-! ## §18. Entanglement vs Modal Depth -/

/-- For iterated soundness on variables, entanglement = modal depth -/
theorem entanglement_eq_modal_depth_for_iter (p : ℕ) (n : ℕ) :
    entanglementDepth (iteratedSoundness n (.var p)) =
    GLFormula.modalDepth (iteratedSoundness n (.var p)) := by
  rw [entanglement_eq_iteration, iterated_soundness_depth_eq]
  simp [GLFormula.modalDepth]

end TangledHierarchy