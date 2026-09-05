import Mathlib
import Applications.ModalFractionCapacity

/-!
# Why the modal fraction is blind: the tie ceiling is majorization-monotone

Third cycle on the law-change thread.  `Applications.ModalFractionCapacity` exhibited *two*
profiles with the same modal fraction and different ceilings.  This file explains the
phenomenon structurally: the tie ceiling is strictly antitone under **mass transfer** from a
smaller tie class to a larger one (a Robin-Hood step in reverse), while the modal fraction is
completely insensitive to any transfer that happens below the modal block.

## Main results

* `spearmanSq_le_of_cubeSum_le`, `spearmanSq_lt_of_cubeSum_lt` — at fixed sample size the
  ceiling is a strictly decreasing function of the cube mass.
* `ceiling_anti_transfer`, `ceiling_strict_anti_transfer` — moving mass `t` from a class of
  size `u` to a class of size `y ≥ u` never raises, and (for `t ≥ 1`, `u < y`) strictly lowers,
  the ceiling.  Equivalently, the ceiling is antitone for the majorization order on tie
  profiles.
* `transfer_family_same_modal` — a *continuum* of counterexamples to the conjectured budget:
  as long as the transfer stays below the modal block, the modal fraction is unchanged while
  the ceiling strictly drops.  The pair/split example of the previous cycle is one instance.
-/

open Catalog.Novelty.ZeroFitDialU64
open Catalog.MachineLearning.ZeroFitDialResolution
open Catalog.Applications.ModalFractionCapacity

namespace Catalog.Applications.ModalFractionTransfer

/-! ## 1. The ceiling as a decreasing function of the cube mass -/

lemma spearmanSq_le_of_cubeSum_le {L L' : List ℕ} (hsum : L.sum = L'.sum) (h : 2 ≤ L.sum)
    (hc : cubeSum L' ≤ cubeSum L) : spearmanSq L ≤ spearmanSq L' := by
  have h' : 2 ≤ L'.sum := hsum ▸ h
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hn
  have hq : ((L'.sum : ℕ) : ℚ) = ((L.sum : ℕ) : ℚ) := by rw [hsum]
  rw [spearmanSq_eq_cube_ratio L h, spearmanSq_eq_cube_ratio L' h', hq]
  gcongr

lemma spearmanSq_lt_of_cubeSum_lt {L L' : List ℕ} (hsum : L.sum = L'.sum) (h : 2 ≤ L.sum)
    (hc : cubeSum L' < cubeSum L) : spearmanSq L < spearmanSq L' := by
  have h' : 2 ≤ L'.sum := hsum ▸ h
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hn
  have hq : ((L'.sum : ℕ) : ℚ) = ((L.sum : ℕ) : ℚ) := by rw [hsum]
  rw [spearmanSq_eq_cube_ratio L h, spearmanSq_eq_cube_ratio L' h', hq]
  gcongr

/-! ## 2. The transfer inequality -/

lemma cubeSum_cons_cons (a b : ℕ) (rest : List ℕ) :
    cubeSum (a :: b :: rest) = (a : ℚ) ^ 3 + (b : ℚ) ^ 3 + cubeSum rest := by
  rw [cubeSum, cubeSum]
  ring

lemma sum_cons_cons_swap (a b t : ℕ) (rest : List ℕ) :
    (a :: (b + t) :: rest).sum = ((a + t) :: b :: rest).sum := by
  simp [List.sum_cons]
  omega

/-- **Transfer inequality for cube mass.**  Moving `t` units from a class of size `u` to a
class of size `y ≥ u` raises the cube mass. -/
lemma cubeSum_transfer_le {u y t : ℕ} (huy : u ≤ y) (rest : List ℕ) :
    cubeSum (u :: (y + t) :: rest) ≥ cubeSum ((u + t) :: y :: rest) := by
  have huyQ : (u : ℚ) ≤ (y : ℚ) := by exact_mod_cast huy
  have ht0 : (0 : ℚ) ≤ (t : ℚ) := by positivity
  have hu0 : (0 : ℚ) ≤ (u : ℚ) := by positivity
  rw [cubeSum_cons_cons, cubeSum_cons_cons]
  push_cast
  nlinarith [sq_nonneg ((t : ℚ)), mul_nonneg ht0 (sub_nonneg.2 huyQ),
    mul_nonneg (mul_nonneg ht0 ht0) (sub_nonneg.2 huyQ)]

lemma cubeSum_transfer_lt {u y t : ℕ} (huy : u < y) (ht : 1 ≤ t) (rest : List ℕ) :
    cubeSum ((u + t) :: y :: rest) < cubeSum (u :: (y + t) :: rest) := by
  have huyQ : (u : ℚ) + 1 ≤ (y : ℚ) := by exact_mod_cast huy
  have htQ : (1 : ℚ) ≤ (t : ℚ) := by exact_mod_cast ht
  have hu0 : (0 : ℚ) ≤ (u : ℚ) := by positivity
  rw [cubeSum_cons_cons, cubeSum_cons_cons]
  push_cast
  nlinarith [mul_nonneg hu0 (by linarith : (0 : ℚ) ≤ (t : ℚ)),
    mul_pos (by linarith : (0 : ℚ) < (t : ℚ)) (by linarith : (0 : ℚ) < (y : ℚ) - (u : ℚ))]

/-- **The tie ceiling is antitone under mass transfer to a larger class.**  (Equivalently: the
ceiling is antitone for the majorization order on tie profiles.) -/
theorem ceiling_anti_transfer {u y t : ℕ} (huy : u ≤ y) (rest : List ℕ)
    (h : 2 ≤ ((u + t) :: y :: rest).sum) :
    spearmanSq (u :: (y + t) :: rest) ≤ spearmanSq ((u + t) :: y :: rest) :=
  spearmanSq_le_of_cubeSum_le (sum_cons_cons_swap u y t rest)
    ((sum_cons_cons_swap u y t rest) ▸ h) (cubeSum_transfer_le huy rest)

/-- Strict form: a nonzero transfer to a strictly larger class strictly lowers the ceiling. -/
theorem ceiling_strict_anti_transfer {u y t : ℕ} (huy : u < y) (ht : 1 ≤ t) (rest : List ℕ)
    (h : 2 ≤ ((u + t) :: y :: rest).sum) :
    spearmanSq (u :: (y + t) :: rest) < spearmanSq ((u + t) :: y :: rest) :=
  spearmanSq_lt_of_cubeSum_lt (sum_cons_cons_swap u y t rest)
    ((sum_cons_cons_swap u y t rest) ▸ h) (cubeSum_transfer_lt huy ht rest)

/-! ## 3. A continuum of equal-modal, unequal-ceiling pairs -/

/-- **Modal-fraction blindness, general form.**  Fix a modal block `M` dominating everything
else.  Any transfer between two sub-modal classes leaves the modal fraction *exactly*
unchanged while strictly changing the tie ceiling.  The `pairProfile` / `splitProfile`
counterexample of `Applications.ModalFractionCapacity` is the special case `u = 0`,
`y = t = M`, `rest` a block of singletons. -/
theorem transfer_family_same_modal {M u y t : ℕ} (rest : List ℕ) (hM : y + t ≤ M) (hu : u + t ≤ M)
    (huy : u < y) (ht : 1 ≤ t) (hrest : ∀ m ∈ rest, m ≤ M) (hn : 2 ≤ M) :
    modalFrac (M :: u :: (y + t) :: rest) = modalFrac (M :: (u + t) :: y :: rest) ∧
      spearmanSq (M :: u :: (y + t) :: rest) < spearmanSq (M :: (u + t) :: y :: rest) := by
  have hsum : (M :: u :: (y + t) :: rest).sum = (M :: (u + t) :: y :: rest).sum := by
    simp [List.sum_cons]
    omega
  have hbig : 2 ≤ (M :: u :: (y + t) :: rest).sum := by
    simp only [List.sum_cons]
    omega
  have hmod1 : modalBlock (M :: u :: (y + t) :: rest) = M := by
    refine modalBlock_eq (List.mem_cons_self ..) ?_
    intro x hx
    rcases List.mem_cons.1 hx with rfl | hx
    · exact le_rfl
    rcases List.mem_cons.1 hx with rfl | hx
    · omega
    rcases List.mem_cons.1 hx with rfl | hx
    · omega
    · exact hrest x hx
  have hmod2 : modalBlock (M :: (u + t) :: y :: rest) = M := by
    refine modalBlock_eq (List.mem_cons_self ..) ?_
    intro x hx
    rcases List.mem_cons.1 hx with rfl | hx
    · exact le_rfl
    rcases List.mem_cons.1 hx with rfl | hx
    · omega
    rcases List.mem_cons.1 hx with rfl | hx
    · omega
    · exact hrest x hx
  constructor
  · rw [modalFrac, modalFrac, hmod1, hmod2, hsum]
  · -- strict transfer inequality, with `M` carried along in the tail
    have hMrest : cubeSum (M :: rest) = (M : ℚ) ^ 3 + cubeSum rest := by rw [cubeSum]
    have h1 : cubeSum (M :: u :: (y + t) :: rest) = cubeSum (u :: (y + t) :: (M :: rest)) := by
      rw [cubeSum_cons_cons, cubeSum_cons_cons, hMrest, cubeSum]
      ring
    have h2 : cubeSum (M :: (u + t) :: y :: rest) = cubeSum ((u + t) :: y :: (M :: rest)) := by
      rw [cubeSum_cons_cons, cubeSum_cons_cons, hMrest, cubeSum]
      ring
    refine spearmanSq_lt_of_cubeSum_lt hsum hbig ?_
    rw [h1, h2]
    exact cubeSum_transfer_lt huy ht (M :: rest)

end Catalog.Applications.ModalFractionTransfer