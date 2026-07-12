/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Tropical.Multiverse.Concrete

/-!
# A connector: multiverse quantifiers are tropical operations

This file is the **cross-domain bridge** of the project. It links two areas that look
unrelated:

* **Set-theoretic logic** — quantification over the universes of a (finite) multiverse:
  `∃ u, holds u s` ("`s` is possibly true") and `∀ u, holds u s` ("`s` is multiverse-true");
* **Tropical / min-plus algebra** — the semiring `Tropical (WithTop ℕ)` whose addition is
  `min` and whose multiplication is ordinary `+`.

The bridge is the map `boolToTrop : Bool → Tropical (WithTop ℕ)` sending `true ↦ 1` (`= trop 0`)
and `false ↦ 0` (`= trop ⊤`). We prove it is a **semiring homomorphism** from the Boolean
semiring `(Bool, ∨, ∧)` to the tropical semiring:

* `boolToTrop_or`  : `‖a ∨ b‖ = ‖a‖ + ‖b‖`   (disjunction ↦ tropical sum = `min`);
* `boolToTrop_and` : `‖a ∧ b‖ = ‖a‖ * ‖b‖`   (conjunction ↦ tropical product = `+`).

Consequently, quantification over a finite multiverse becomes a tropical big operator:

* `tropExists_eq_one_iff` : `∃ i, p i  ↔  (∑ i, ‖p i‖) = 1`   (existence ↦ tropical **sum**);
* `tropForall_eq_one_iff` : `∀ i, p i  ↔  (∏ i, ‖p i‖) = 1`   (universality ↦ tropical **product**).

Reading these through `Basic.lean`/`Concrete.lean`, **multiverse truth is the tropical product
of truth values and possibility is the tropical sum** (`multiverseTrue_iff_tropProd`,
`possiblyTrue_iff_tropSum`). The independence of CH then acquires a clean tropical signature
(`ch_tropical_signature`): its tropical sum over the multiverse is `1` while its tropical
product is not.
-/

namespace MultiverseSet.Bridge

open Tropical
open scoped BigOperators

/-- The bridge map: `true ↦ 1 = trop 0`, `false ↦ 0 = trop ⊤`. This embeds the Boolean
semiring into the tropical (min-plus) semiring. -/
noncomputable def boolToTrop (b : Bool) : Tropical (WithTop ℕ) := if b then 1 else 0

@[simp] lemma boolToTrop_true : boolToTrop true = 1 := rfl
@[simp] lemma boolToTrop_false : boolToTrop false = 0 := rfl

/-- **Disjunction is tropical addition (`min`).** The first homomorphism law of the bridge. -/
theorem boolToTrop_or (a b : Bool) : boolToTrop (a || b) = boolToTrop a + boolToTrop b := by
  cases a <;> cases b <;> simp

/-- **Conjunction is tropical multiplication (`+`).** The second homomorphism law of the bridge. -/
theorem boolToTrop_and (a b : Bool) : boolToTrop (a && b) = boolToTrop a * boolToTrop b := by
  cases a <;> cases b <;> simp

/-- `1` is the tropical minimum among the values in the image of `boolToTrop`. -/
lemma one_le_boolToTrop (b : Bool) : (1 : Tropical (WithTop ℕ)) ≤ boolToTrop b := by
  cases b
  · decide
  · simp

lemma boolToTrop_eq_one_iff (b : Bool) : boolToTrop b = 1 ↔ b = true := by
  cases b <;> simp

@[simp] lemma untrop_boolToTrop (b : Bool) :
    untrop (boolToTrop b) = if b then (0 : WithTop ℕ) else ⊤ := by
  cases b <;> rfl

/-- **Universal quantification ↦ tropical product.** Over a finite index type, `∀ i, p i`
holds iff the tropical product of the truth values equals the multiplicative unit `1`. -/
theorem tropForall_eq_one_iff {ι : Type} [Fintype ι] (p : ι → Prop) [DecidablePred p] :
    (∏ i, boolToTrop (decide (p i))) = 1 ↔ ∀ i, p i := by
  rw [Finset.prod_eq_one_iff_of_one_le' (fun i _ => one_le_boolToTrop _)]
  simp [boolToTrop_eq_one_iff]

/-- **Existential quantification ↦ tropical sum.** Over a finite index type, `∃ i, p i` holds
iff the tropical sum (`min`) of the truth values equals `1`. -/
theorem tropExists_eq_one_iff {ι : Type} [Fintype ι] (p : ι → Prop) [DecidablePred p] :
    (∑ i, boolToTrop (decide (p i))) = 1 ↔ ∃ i, p i := by
  rw [← untrop_inj_iff, Finset.untrop_sum']
  simp only [Function.comp_def, untrop_boolToTrop, untrop_one]
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    have hg : ∀ i, (if decide (p i) then (0 : WithTop ℕ) else ⊤) = ⊤ := by
      intro i; simp [hc i]
    have hinf : (Finset.univ.inf fun i => if decide (p i) then (0 : WithTop ℕ) else ⊤) = ⊤ :=
      le_antisymm le_top (Finset.le_inf (fun i _ => (hg i).ge))
    rw [hinf] at h
    exact (by decide : (⊤ : WithTop ℕ) ≠ 0) h
  · rintro ⟨i, hi⟩
    have hbot : (if decide (p i) then (0 : WithTop ℕ) else ⊤) = 0 := by simp [hi]
    refine le_antisymm ?_ bot_le
    calc (Finset.univ.inf fun j => if decide (p j) then (0 : WithTop ℕ) else ⊤)
        ≤ (if decide (p i) then (0 : WithTop ℕ) else ⊤) := Finset.inf_le (Finset.mem_univ i)
      _ = 0 := hbot

section Multiverse

open MultiverseSet

variable {M : Multiverse} [Fintype M.Universe]

/-- **Multiverse truth is the tropical product of truth values.** A statement is multiverse-true
iff the tropical product of its per-universe truth values equals `1`. -/
theorem multiverseTrue_iff_tropProd (s : M.Statement) [DecidablePred (fun u => M.holds u s)] :
    MultiverseTrue M s ↔ (∏ u, boolToTrop (decide (M.holds u s))) = 1 :=
  (tropForall_eq_one_iff (fun u => M.holds u s)).symm

/-- **Possibility is the tropical sum of truth values.** A statement is possibly true iff the
tropical sum (`min`) of its per-universe truth values equals `1`. -/
theorem possiblyTrue_iff_tropSum (s : M.Statement) [DecidablePred (fun u => M.holds u s)] :
    PossiblyTrue M s ↔ (∑ u, boolToTrop (decide (M.holds u s))) = 1 :=
  (tropExists_eq_one_iff (fun u => M.holds u s)).symm

end Multiverse

section Concrete

open MultiverseSet MultiverseSet.Concrete

/-- **The tropical signature of CH.** Over the concrete multiverse, the tropical *sum* of CH's
truth values is `1` (CH is possibly true) while the tropical *product* is not `1` (CH is not
multiverse-true). Independence is thus visible as a mismatch between the two tropical big
operators. -/
theorem ch_tropical_signature :
    (∑ u : Model, boolToTrop (decide (choldsB u Stmt.CH))) = 1 ∧
      (∏ u : Model, boolToTrop (decide (choldsB u Stmt.CH))) ≠ 1 := by
  constructor
  · rw [tropExists_eq_one_iff (fun u : Model => choldsB u Stmt.CH = true)]
    exact ⟨Model.L, by decide⟩
  · rw [Ne, tropForall_eq_one_iff (fun u : Model => choldsB u Stmt.CH = true)]
    intro h
    exact (by decide : choldsB Model.cohen Stmt.CH ≠ true) (h Model.cohen)

/-- **The tropical signature of ZFC.** Being multiverse-true, ZFC has *both* tropical sum and
tropical product equal to `1`. -/
theorem zfc_tropical_signature :
    (∑ u : Model, boolToTrop (decide (choldsB u Stmt.ZFC))) = 1 ∧
      (∏ u : Model, boolToTrop (decide (choldsB u Stmt.ZFC))) = 1 := by
  constructor
  · rw [tropExists_eq_one_iff (fun u : Model => choldsB u Stmt.ZFC = true)]
    exact ⟨Model.L, by decide⟩
  · rw [tropForall_eq_one_iff (fun u : Model => choldsB u Stmt.ZFC = true)]
    intro u; cases u <;> decide

end Concrete

end MultiverseSet.Bridge