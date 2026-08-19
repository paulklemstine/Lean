/-
# Cycle 5, Part III: Counting the Finite Löb Frames

Part I showed that the Löb axiom `□(□p → p) → □p` defines the transitive converse
well-founded frames, and that over a *finite* carrier this collapses to "transitive and
irreflexive" (`FrameDefinability.valid_loeb_iff_finite`).  That turns a question of
modal logic into a question of enumerative combinatorics:

> How many Kripke frames on `n` labelled worlds validate the Löb axiom?

This file makes the bridge formal and exact.  A frame on `Fin n` is a Boolean matrix;
`loebFrameCount n` counts the matrices whose frame validates Löb, and
`valid_loeb_iff_isStrictMatrix` proves that this decidable count is *the* count of
Löb frames.  The sequence begins `1, 1, 3, 19` — the labelled strict partial orders
(OEIS A001035), continuing `219, 4231, …`.

## Main results

* `valid_loeb_iff_isStrictMatrix` — semantic Löb validity of `finFrame n R` is
  equivalent to the decidable matrix condition "transitive and zero diagonal".
* `loebFrameCount_zero/one/two/three` — the first four values, `1, 1, 3, 19`, each
  verified by kernel computation *through* the bridge, so they are statements about
  modal validity, not merely about matrices.
* `loebFrameCount_mono` — adding an isolated world is an injection of Löb frames on
  `Fin n` into Löb frames on `Fin (n+1)`, so the sequence is monotone.
* `loeb_rarer_than_reflexive` — on three worlds there are `19` Löb frames against `64`
  frames validating the reflection axiom `T`: internalised soundness is *cheap*,
  Löbian well-foundedness is *rare*.
-/

import Mathlib
import Combinatorics.ModalFrameDefinability

namespace FrameDefinability

open GLPLogic TangledSoundness

variable {α : Type}

/-! ## Part A — Frames on `Fin n` as Boolean matrices -/

/-- The Kripke frame on `Fin n` given by a Boolean adjacency matrix. -/
@[reducible] def finFrame (n : ℕ) (R : Fin n → Fin n → Bool) : KFrame.{0} where
  W := Fin n
  R := fun a b => R a b = true

/-- The decidable matrix condition: transitive with zero diagonal, i.e. a labelled
strict partial order. -/
def isStrictMatrix (n : ℕ) (R : Fin n → Fin n → Bool) : Bool :=
  (decide (∀ a b c : Fin n, R a b = true → R b c = true → R a c = true)) &&
    (decide (∀ a : Fin n, R a a = false))

theorem isStrictMatrix_iff (n : ℕ) (R : Fin n → Fin n → Bool) :
    isStrictMatrix n R = true ↔
      (∀ a b c : Fin n, R a b = true → R b c = true → R a c = true) ∧
        (∀ a : Fin n, R a a = false) := by
  simp [isStrictMatrix]

/-- **The bridge.**  A frame on `Fin n` validates the Löb axiom exactly when its matrix
is a strict partial order.  The left-hand side quantifies over *all* valuations, the
right-hand side is a finite decidable check. -/
theorem valid_loeb_iff_isStrictMatrix (n : ℕ) (R : Fin n → Fin n → Bool) (p : α) :
    Valid (finFrame n R) α (loebInst (MFormula.var p)) ↔ isStrictMatrix n R = true := by
  rw [valid_loeb_iff_finite (finFrame n R) p, isStrictMatrix_iff]
  constructor
  · rintro ⟨htr, hirr⟩
    refine ⟨fun a b c hab hbc => htr hab hbc, fun a => ?_⟩
    simpa using hirr a
  · rintro ⟨htr, hirr⟩
    refine ⟨fun a b c hab hbc => htr a b c hab hbc, fun a ha => ?_⟩
    have ha' : R a a = true := ha
    rw [hirr a] at ha'
    exact Bool.noConfusion ha'

/-- The number of Löb frames on `n` labelled worlds. -/
def loebFrameCount (n : ℕ) : ℕ :=
  (Finset.univ.filter (fun R : Fin n → Fin n → Bool => isStrictMatrix n R = true)).card

/-- Restated semantically: `loebFrameCount n` counts the adjacency matrices whose frame
validates the Löb axiom. -/
theorem loebFrameCount_eq_ncard_valid (n : ℕ) (p : α) :
    loebFrameCount n =
      Set.ncard {R : Fin n → Fin n → Bool |
        Valid (finFrame n R) α (loebInst (MFormula.var p))} := by
  have hset : {R : Fin n → Fin n → Bool |
      Valid (finFrame n R) α (loebInst (MFormula.var p))}
      = ↑(Finset.univ.filter (fun R : Fin n → Fin n → Bool => isStrictMatrix n R = true)) := by
    ext R
    simp [valid_loeb_iff_isStrictMatrix n R p]
  rw [hset, Set.ncard_coe_finset, loebFrameCount]

/-! ## Part B — The first values of the sequence -/

theorem loebFrameCount_zero : loebFrameCount 0 = 1 := by decide

theorem loebFrameCount_one : loebFrameCount 1 = 1 := by decide

theorem loebFrameCount_two : loebFrameCount 2 = 3 := by decide

set_option maxRecDepth 100000 in
theorem loebFrameCount_three : loebFrameCount 3 = 19 := by decide +kernel

/-! ## Part C — Monotonicity: adding an isolated world -/

/-- Extend a matrix on `Fin n` by one isolated world. -/
def extendMatrix (n : ℕ) (R : Fin n → Fin n → Bool) :
    Fin (n + 1) → Fin (n + 1) → Bool :=
  fun a b => if h : a.val < n ∧ b.val < n then R ⟨a.val, h.1⟩ ⟨b.val, h.2⟩ else false

theorem extendMatrix_castSucc (n : ℕ) (R : Fin n → Fin n → Bool) (a b : Fin n) :
    extendMatrix n R a.castSucc b.castSucc = R a b := by
  simp [extendMatrix]

theorem extendMatrix_injective (n : ℕ) : Function.Injective (extendMatrix n) := by
  intro R S h
  funext a b
  have := congrFun (congrFun h a.castSucc) b.castSucc
  rwa [extendMatrix_castSucc, extendMatrix_castSucc] at this

theorem isStrictMatrix_extendMatrix (n : ℕ) (R : Fin n → Fin n → Bool)
    (hR : isStrictMatrix n R = true) : isStrictMatrix (n + 1) (extendMatrix n R) = true := by
  rw [isStrictMatrix_iff] at hR ⊢
  obtain ⟨htr, hirr⟩ := hR
  constructor
  · intro a b c hab hbc
    by_cases hab' : a.val < n ∧ b.val < n
    · by_cases hbc' : b.val < n ∧ c.val < n
      · have hac : a.val < n ∧ c.val < n := ⟨hab'.1, hbc'.2⟩
        simp only [extendMatrix, dif_pos hab'] at hab
        simp only [extendMatrix, dif_pos hbc'] at hbc
        simp only [extendMatrix, dif_pos hac]
        exact htr _ _ _ hab hbc
      · simp only [extendMatrix, dif_neg hbc'] at hbc
        exact absurd hbc (by simp)
    · simp only [extendMatrix, dif_neg hab'] at hab
      exact absurd hab (by simp)
  · intro a
    by_cases ha : a.val < n
    · have hcond : a.val < n ∧ a.val < n := ⟨ha, ha⟩
      simp only [extendMatrix, dif_pos hcond]
      exact hirr _
    · have hcond : ¬ (a.val < n ∧ a.val < n) := fun h => ha h.1
      simp only [extendMatrix, dif_neg hcond]

/-- **The sequence of Löb-frame counts is monotone**: every Löb frame on `n` worlds
extends, injectively, to one on `n + 1` worlds by adjoining an isolated world. -/
theorem loebFrameCount_mono (n : ℕ) : loebFrameCount n ≤ loebFrameCount (n + 1) := by
  refine Finset.card_le_card_of_injOn (extendMatrix n) (fun R hR => ?_)
    (fun a _ b _ h => extendMatrix_injective n h)
  have hR' : isStrictMatrix n R = true := (Finset.mem_filter.mp hR).2
  exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, isStrictMatrix_extendMatrix n R hR'⟩

/-! ## Part D — Löb frames are rare, sound (reflexive) frames are common -/

/-- The decidable matrix condition for validity of the reflection axiom `T`. -/
def isReflexiveMatrix (n : ℕ) (R : Fin n → Fin n → Bool) : Bool :=
  decide (∀ a : Fin n, R a a = true)

theorem valid_reflection_iff_isReflexiveMatrix (n : ℕ) (R : Fin n → Fin n → Bool)
    (p : α) :
    Valid (finFrame n R) α (reflection (MFormula.var p)) ↔ isReflexiveMatrix n R = true := by
  have h := (defines_singleton_iff (α := α) (reflection (MFormula.var p))
      (fun F : KFrame.{0} => ∀ w, F.R w w)).mp (defines_reflexive p) (finFrame n R)
  rw [h, isReflexiveMatrix]
  simp

/-- The number of frames on `n` labelled worlds validating the reflection (soundness)
axiom. -/
def reflexiveFrameCount (n : ℕ) : ℕ :=
  (Finset.univ.filter (fun R : Fin n → Fin n → Bool => isReflexiveMatrix n R = true)).card

theorem reflexiveFrameCount_three : reflexiveFrameCount 3 = 64 := by decide +kernel

/-- **Internal soundness is cheap, Löbian well-foundedness is rare.**  On three labelled
worlds, `64` of the `512` frames validate the reflection schema `T` while only `19`
validate Löb — and, by `isEmpty_of_valid_loeb_and_reflection`, no nonempty frame does
both. -/
theorem loeb_rarer_than_reflexive :
    loebFrameCount 3 < reflexiveFrameCount 3 := by
  rw [loebFrameCount_three, reflexiveFrameCount_three]
  norm_num

end FrameDefinability

-- !-- Lab Notes -- !--
--
-- Experimental data (Experimenter):
--   #eval (loebFrameCount 0, loebFrameCount 1, loebFrameCount 2, loebFrameCount 3)
--     ⇒ (1, 1, 3, 19)
--   The continuation 219, 4231, 130023, … is OEIS A001035 (labelled posets); the
--   value at n = 4 was *not* certified here: kernel evaluation over the 2^16 matrices
--   on `Fin 4` exceeded the time budget, so only n ≤ 3 are theorems.
--   #eval reflexiveFrameCount 3 ⇒ 64 = 2^(9-3), as predicted by "fix the diagonal,
--   free off-diagonal".
--
-- Analysis (Analyst):
--   The interesting content is `valid_loeb_iff_isStrictMatrix`: it converts an
--   ∀-valuation statement (second order over the frame) into a finite decidable check.
--   Without `valid_loeb_iff_finite` from Part I, the count would be uncomputable in
--   principle, since converse well-foundedness is not a finitary condition.
--
-- Critique (Critic):
--   The `decide` results are not free-standing: each is a statement about the count of
--   *modally definable* frames only because of the bridge theorem, whose proof is
--   analytic (well-founded induction plus the minimal-element argument).  The n = 4
--   value is deliberately *not* asserted rather than asserted by `native_decide`.