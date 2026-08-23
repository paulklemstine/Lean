import Probability.SharingRigidity
import Probability.SharingCapacityCurve

/-!
# Every quantised serving value is realised: the complete-design families

`SharingRigidity.saturation_quantised` shows that a family of `k` fine-tunes and a
shared model attaining the multiplicity bound must have

`M = c/k` and `β = c(c−1)/(k(k−1))` for an integer `c ≤ k`.

That is a *necessary* condition.  This file proves the converse — the classification is
exact.  For every `2 ≤ c ≤ k` there is an explicit family attaining the bound at that
quantised value, namely the **complete `c`-design**:

* positions are the `c`-element subsets `S ⊆ {1, …, k}` (so `N = C(k, c)`);
* fine-tune `i` predicts the neutral token `0` at position `S` if `i ∈ S`, and its own
  private token `i+1` otherwise;
* the shared model is the constant neutral predictor.

Then the shared model matches exactly the `c` fine-tunes indexed by `S` at position `S`
(constant multiplicity, as `saturation_matchCount_constant` demands), two fine-tunes
agree exactly on the positions where both are matched (as `saturation_pairwise_tight`
demands), and counting subsets gives

`agr(H, Aᵢ) = C(k−1, c−1)/C(k, c) = c/k`,
`agr(Aᵢ, Aⱼ) = C(k−2, c−2)/C(k, c) = c(c−1)/(k(k−1))`.

Main results:

* `design_agree_hub`, `design_agree_pair` — the two agreement values;
* `design_saturates` — the design attains the multiplicity bound;
* `quantised_values_are_exactly_realised` — the classification: the achievable extremal
  pairs `(β, M)` for `k` fine-tunes are *exactly* `(c(c−1)/(k(k−1)), c/k)`, `2 ≤ c ≤ k`.
  The hub family of `MultiFineTuneSharingPhase` is the top case `c = k − 1`, and
  `c = k` is the degenerate family of identical models.
-/

namespace Catalog.Probability.SharingExtremalDesigns

open Finset
open Catalog.Probability.TailTransplantGeometry
open Catalog.Probability.MultiFineTuneSharingPhase
open Catalog.Probability.SharingRigidity
open Catalog.Probability.SharingCapacityCurve

/-- Positions of the complete `c`-design on `k` fine-tunes: the `c`-element subsets. -/
abbrev Block (k c : ℕ) := {S : Finset (Fin k) // S.card = c}

variable {k c : ℕ}

/-- Fine-tune `i` predicts the neutral token at a position containing `i`, and its own
private token elsewhere. -/
def designModel (k c : ℕ) (i : Fin k) : Block k c → Fin (k + 1) :=
  fun x => if i ∈ x.val then 0 else i.succ

/-- The shared model of the design: the constant neutral predictor. -/
def designHub (k c : ℕ) : Block k c → Fin (k + 1) := fun _ => 0

/-! ### 1. Counting the positions -/

lemma card_blocks (k c : ℕ) : Fintype.card (Block k c) = k.choose c := by
  simp [Fintype.card_finset_len (α := Fin k) c]

lemma card_blocks_pos (hck : c ≤ k) : 0 < Fintype.card (Block k c) := by
  rw [card_blocks]
  exact Nat.choose_pos hck

/-- The positions matched by fine-tune `i`: `C(k−1, c−1)` of them. -/
lemma card_filter_mem (hc1 : 1 ≤ c) (i : Fin k) :
    ((univ : Finset (Block k c)).filter (fun x => i ∈ x.val)).card
      = (k - 1).choose (c - 1) := by
  classical
  have hcard : ((univ : Finset (Fin k)).erase i).card = k - 1 := by
    rw [Finset.card_erase_of_mem (Finset.mem_univ i), Finset.card_univ, Fintype.card_fin]
  have hbij :
      ((univ : Finset (Block k c)).filter (fun x => i ∈ x.val)).card
        = (Finset.powersetCard (c - 1) ((univ : Finset (Fin k)).erase i)).card := by
    refine Finset.card_bij'
      (fun (x : Block k c) _ => x.val.erase i)
      (fun (T : Finset (Fin k)) hT =>
        (⟨insert i T, by
            have hT' := Finset.mem_powersetCard.1 hT
            have hiT : i ∉ T := fun h => (Finset.mem_erase.1 (hT'.1 h)).1 rfl
            rw [Finset.card_insert_of_notMem hiT, hT'.2]
            omega⟩ : Block k c))
      ?_ ?_ ?_ ?_
    · intro x hx
      have hix : i ∈ x.val := by simpa using (Finset.mem_filter.1 hx).2
      refine Finset.mem_powersetCard.2 ⟨?_, ?_⟩
      · intro y hy
        exact Finset.mem_erase.2 ⟨(Finset.mem_erase.1 hy).1, Finset.mem_univ y⟩
      · rw [Finset.card_erase_of_mem hix, x.property]
    · intro T hT
      exact Finset.mem_filter.2 ⟨Finset.mem_univ _, by simp⟩
    · intro x hx
      have hix : i ∈ x.val := by simpa using (Finset.mem_filter.1 hx).2
      exact Subtype.ext (Finset.insert_erase hix)
    · intro T hT
      have hT' := Finset.mem_powersetCard.1 hT
      have hiT : i ∉ T := fun h => (Finset.mem_erase.1 (hT'.1 h)).1 rfl
      exact Finset.erase_insert hiT
  rw [hbij, Finset.card_powersetCard, hcard]

/-- The positions matched by both `i` and `j`: `C(k−2, c−2)` of them. -/
lemma card_filter_mem_two (hc2 : 2 ≤ c) {i j : Fin k} (hij : i ≠ j) :
    ((univ : Finset (Block k c)).filter (fun x => i ∈ x.val ∧ j ∈ x.val)).card
      = (k - 2).choose (c - 2) := by
  classical
  have hjmem : j ∈ (univ : Finset (Fin k)).erase i :=
    Finset.mem_erase.2 ⟨Ne.symm hij, Finset.mem_univ j⟩
  have hcard : (((univ : Finset (Fin k)).erase i).erase j).card = k - 2 := by
    rw [Finset.card_erase_of_mem hjmem, Finset.card_erase_of_mem (Finset.mem_univ i),
      Finset.card_univ, Fintype.card_fin]
    omega
  have hbij :
      ((univ : Finset (Block k c)).filter (fun x => i ∈ x.val ∧ j ∈ x.val)).card
        = (Finset.powersetCard (c - 2) (((univ : Finset (Fin k)).erase i).erase j)).card := by
    refine Finset.card_bij'
      (fun (x : Block k c) _ => (x.val.erase i).erase j)
      (fun (T : Finset (Fin k)) hT =>
        (⟨insert i (insert j T), by
            have hT' := Finset.mem_powersetCard.1 hT
            have hjT : j ∉ T := fun h => (Finset.mem_erase.1 (hT'.1 h)).1 rfl
            have hiT : i ∉ insert j T := by
              intro h
              rcases Finset.mem_insert.1 h with h1 | h1
              · exact hij h1
              · exact (Finset.mem_erase.1 (Finset.mem_erase.1 (hT'.1 h1)).2).1 rfl
            rw [Finset.card_insert_of_notMem hiT, Finset.card_insert_of_notMem hjT, hT'.2]
            omega⟩ : Block k c))
      ?_ ?_ ?_ ?_
    · intro x hx
      obtain ⟨hix, hjx⟩ : i ∈ x.val ∧ j ∈ x.val := by simpa using (Finset.mem_filter.1 hx).2
      refine Finset.mem_powersetCard.2 ⟨?_, ?_⟩
      · intro y hy
        have hy1 := Finset.mem_erase.1 hy
        have hy2 := Finset.mem_erase.1 hy1.2
        exact Finset.mem_erase.2 ⟨hy1.1, Finset.mem_erase.2 ⟨hy2.1, Finset.mem_univ y⟩⟩
      · rw [Finset.card_erase_of_mem (Finset.mem_erase.2 ⟨Ne.symm hij, hjx⟩),
          Finset.card_erase_of_mem hix, x.property]
        omega
    · intro T hT
      refine Finset.mem_filter.2 ⟨Finset.mem_univ _, ?_⟩
      simp
    · intro x hx
      obtain ⟨hix, hjx⟩ : i ∈ x.val ∧ j ∈ x.val := by simpa using (Finset.mem_filter.1 hx).2
      refine Subtype.ext ?_
      show insert i (insert j ((x.val.erase i).erase j)) = x.val
      rw [Finset.insert_erase (Finset.mem_erase.2 ⟨Ne.symm hij, hjx⟩), Finset.insert_erase hix]
    · intro T hT
      have hT' := Finset.mem_powersetCard.1 hT
      have hjT : j ∉ T := fun h => (Finset.mem_erase.1 (hT'.1 h)).1 rfl
      have hiT : i ∉ insert j T := by
        intro h
        rcases Finset.mem_insert.1 h with h1 | h1
        · exact hij h1
        · exact (Finset.mem_erase.1 (Finset.mem_erase.1 (hT'.1 h1)).2).1 rfl
      show ((insert i (insert j T)).erase i).erase j = T
      rw [Finset.erase_insert hiT, Finset.erase_insert hjT]
  rw [hbij, Finset.card_powersetCard, hcard]

/-! ### 2. The agreement sets of the design -/

lemma agreeSet_hub (i : Fin k) :
    agreeSet (designHub k c) (designModel k c i)
      = (univ : Finset (Block k c)).filter (fun x => i ∈ x.val) := by
  ext x
  by_cases h : i ∈ x.val <;>
    simp [agreeSet, designHub, designModel, h, (Fin.succ_ne_zero i).symm]

lemma agreeSet_pair {i j : Fin k} (hij : i ≠ j) :
    agreeSet (designModel k c i) (designModel k c j)
      = (univ : Finset (Block k c)).filter (fun x => i ∈ x.val ∧ j ∈ x.val) := by
  ext x
  by_cases hi : i ∈ x.val <;> by_cases hj : j ∈ x.val <;>
    simp [agreeSet, designModel, hi, hj, Fin.succ_ne_zero, (Fin.succ_ne_zero j).symm,
      Fin.succ_inj, hij]

/-! ### 3. The two binomial identities -/

lemma choose_identity_one (hk1 : 1 ≤ k) (hc1 : 1 ≤ c) :
    k * (k - 1).choose (c - 1) = k.choose c * c := by
  have h := Nat.add_one_mul_choose_eq (k - 1) (c - 1)
  rw [Nat.sub_add_cancel hk1, Nat.sub_add_cancel hc1] at h
  exact h

lemma choose_identity_two (hk2 : 2 ≤ k) (hc2 : 2 ≤ c) :
    (k - 1) * (k - 2).choose (c - 2) = (k - 1).choose (c - 1) * (c - 1) := by
  have h := Nat.add_one_mul_choose_eq (k - 2) (c - 2)
  have h1 : k - 2 + 1 = k - 1 := by omega
  have h2 : c - 2 + 1 = c - 1 := by omega
  rw [h1, h2] at h
  exact h

/-! ### 4. The agreement values -/

lemma design_agree_hub (hk1 : 1 ≤ k) (hc1 : 1 ≤ c) (hck : c ≤ k) (i : Fin k) :
    agreeFrac (designHub k c) (designModel k c i) = (c : ℝ) / (k : ℝ) := by
  have hpos : 0 < k.choose c := Nat.choose_pos hck
  have hkpos : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk1
  have hcpos : (0 : ℝ) < (k.choose c : ℝ) := by exact_mod_cast hpos
  have hid : (k : ℝ) * ((k - 1).choose (c - 1) : ℝ) = (k.choose c : ℝ) * (c : ℝ) := by
    exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) (choose_identity_one hk1 hc1)
  rw [agreeFrac, agreeSet_hub, card_filter_mem hc1 i, card_blocks]
  rw [div_eq_div_iff (ne_of_gt hcpos) (ne_of_gt hkpos)]
  linarith [hid]

lemma design_agree_pair (hk2 : 2 ≤ k) (hc2 : 2 ≤ c) (hck : c ≤ k) {i j : Fin k}
    (hij : i ≠ j) :
    agreeFrac (designModel k c i) (designModel k c j)
      = ((c : ℝ) * ((c : ℝ) - 1)) / ((k : ℝ) * ((k : ℝ) - 1)) := by
  have hpos : 0 < k.choose c := Nat.choose_pos hck
  have hcpos : (0 : ℝ) < (k.choose c : ℝ) := by exact_mod_cast hpos
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk2
  have hcR : (2 : ℝ) ≤ (c : ℝ) := by exact_mod_cast hc2
  have hk1 : 1 ≤ k := by omega
  have hc1 : 1 ≤ c := by omega
  have hkm : ((k - 1 : ℕ) : ℝ) = (k : ℝ) - 1 := by
    push_cast [Nat.cast_sub hk1]; ring
  have hcm : ((c - 1 : ℕ) : ℝ) = (c : ℝ) - 1 := by
    push_cast [Nat.cast_sub hc1]; ring
  have hid1 : (k : ℝ) * ((k - 1).choose (c - 1) : ℝ) = (k.choose c : ℝ) * (c : ℝ) := by
    exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) (choose_identity_one hk1 hc1)
  have hid2 : ((k : ℝ) - 1) * ((k - 2).choose (c - 2) : ℝ)
      = ((k - 1).choose (c - 1) : ℝ) * ((c : ℝ) - 1) := by
    have h := congrArg (fun m : ℕ => (m : ℝ)) (choose_identity_two hk2 hc2)
    push_cast at h
    rw [hkm, hcm] at h
    exact h
  have hdenpos : (0 : ℝ) < (k : ℝ) * ((k : ℝ) - 1) := by nlinarith
  rw [agreeFrac, agreeSet_pair hij, card_filter_mem_two hc2 hij, card_blocks]
  rw [div_eq_div_iff (ne_of_gt hcpos) (ne_of_gt hdenpos)]
  nlinarith [hid1, hid2]

/-! ### 5. The design is extremal -/

/-- **The complete `c`-design attains the multiplicity bound.**  Together with
`SharingRigidity.saturation_quantised` this shows the extremal values are *exactly* the
quantised ones. -/
theorem design_saturates (hk2 : 2 ≤ k) (hc2 : 2 ≤ c) (hck : c ≤ k) :
    Saturates (designHub k c) (fun i : Fin k => designModel k c i)
      (((c : ℝ) * ((c : ℝ) - 1)) / ((k : ℝ) * ((k : ℝ) - 1))) := by
  have hk1 : 1 ≤ k := by omega
  have hc1 : 1 ≤ c := by omega
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk2
  have hkne : (k : ℝ) ≠ 0 := by intro h; rw [h] at hkR; linarith
  have hk1ne : ((k : ℝ) - 1) ≠ 0 := by intro h; linarith
  have hsum : (∑ i : Fin k, agreeFrac (designHub k c) (designModel k c i)) = (c : ℝ) := by
    rw [Finset.sum_congr rfl (fun i _ => design_agree_hub hk1 hc1 hck i), Finset.sum_const,
      Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    field_simp
  unfold Saturates
  rw [hsum]
  field_simp
  ring

/-- **The classification of extremal shared-serving values.**  For `k ≥ 2` fine-tunes,
a pair `(β, M)` is realised by a family attaining the multiplicity bound **iff** it is
one of the quantised pairs `(c(c−1)/(k(k−1)), c/k)`.  The "only if" half is
`SharingRigidity.saturation_quantised`; the "if" half is the complete `c`-design built
here, whose pairwise agreements and mean agreement are computed exactly. -/
theorem quantised_values_are_exactly_realised (hk2 : 2 ≤ k) (hc2 : 2 ≤ c) (hck : c ≤ k) :
    0 < Fintype.card (Block k c) ∧
    (∀ i j : Fin k, i ≠ j →
      agreeFrac (designModel k c i) (designModel k c j)
        = ((c : ℝ) * ((c : ℝ) - 1)) / ((k : ℝ) * ((k : ℝ) - 1))) ∧
    meanAgree (designHub k c) (fun i : Fin k => designModel k c i) = (c : ℝ) / (k : ℝ) ∧
    Saturates (designHub k c) (fun i : Fin k => designModel k c i)
      (((c : ℝ) * ((c : ℝ) - 1)) / ((k : ℝ) * ((k : ℝ) - 1))) := by
  have hk1 : 1 ≤ k := by omega
  have hc1 : 1 ≤ c := by omega
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk2
  refine ⟨card_blocks_pos hck, fun i j hij => design_agree_pair hk2 hc2 hck hij, ?_,
    design_saturates hk2 hc2 hck⟩
  unfold meanAgree
  rw [Finset.sum_congr rfl (fun i _ => design_agree_hub hk1 hc1 hck i), Finset.sum_const,
    Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  have hkne : (k : ℝ) ≠ 0 := by intro h; rw [h] at hkR; linarith
  field_simp

/-- At a quantised budget the capacity curve takes the quantised value: the complete
`c`-design sits exactly on `capacityCurve`, for every `2 ≤ c ≤ k`.  Combined with
`quantised_values_are_exactly_realised` this pins down the whole extremal set:
`capacityCurve k β` is attained precisely at the quantised budgets. -/
theorem capacityCurve_at_quantised_budget (hk2 : 2 ≤ k) (hc2 : 2 ≤ c) :
    capacityCurve k (((c : ℝ) * ((c : ℝ) - 1)) / ((k : ℝ) * ((k : ℝ) - 1)))
      = (c : ℝ) / (k : ℝ) := by
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk2
  have hcR : (2 : ℝ) ≤ (c : ℝ) := by exact_mod_cast hc2
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  have hk1ne : ((k : ℝ) - 1) ≠ 0 := by intro h; linarith
  have hval : 1 + 4 * (k : ℝ) * ((k : ℝ) - 1)
      * (((c : ℝ) * ((c : ℝ) - 1)) / ((k : ℝ) * ((k : ℝ) - 1)))
      = (2 * (c : ℝ) - 1) ^ 2 := by
    field_simp
    ring
  unfold capacityCurve
  rw [hval, Real.sqrt_sq (by linarith)]
  field_simp
  ring

/-- The design realises the capacity curve: its mean agreement equals
`capacityCurve k β` at its own budget. -/
theorem design_on_capacityCurve (hk2 : 2 ≤ k) (hc2 : 2 ≤ c) (hck : c ≤ k) :
    meanAgree (designHub k c) (fun i : Fin k => designModel k c i)
      = capacityCurve k (((c : ℝ) * ((c : ℝ) - 1)) / ((k : ℝ) * ((k : ℝ) - 1))) := by
  obtain ⟨-, -, hmean, -⟩ := quantised_values_are_exactly_realised hk2 hc2 hck
  rw [hmean, capacityCurve_at_quantised_budget hk2 hc2]

end Catalog.Probability.SharingExtremalDesigns