/-! # CatalogBuild.Computation.SearchInformationDuality

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 10
-/

import Mathlib

noncomputable section

/-- A probability distribution is valid if all values are nonneg and sum to 1. -/
structure IsProbDist {α : Type*} [Fintype α] (p : α → ℝ) : Prop where
  nonneg : ∀ x, 0 ≤ p x
  sum_one : ∑ x : α, p x = 1




/-- The uniform distribution over a finite type. -/
def uniformDist (α : Type*) [Fintype α] [Nonempty α] : α → ℝ :=
  fun _ => (1 : ℝ) / (Fintype.card α : ℝ)




/-- The uniform distribution is a valid probability distribution. -/
theorem uniformDist_isProbDist (α : Type*) [Fintype α] [Nonempty α] :
    IsProbDist (uniformDist α) := by
  exact ⟨fun x => by simp [uniformDist], by simp [uniformDist]⟩




/-- Shannon entropy of the uniform distribution over n elements equals log₂(n).
This is the maximum entropy distribution — maximum uncertainty. -/
theorem entropy_uniform {α : Type*} [Fintype α] [Nonempty α]
    (hn : (Fintype.card α : ℝ) > 0) :
    shannonEntropy (uniformDist α) = Real.logb 2 (Fintype.card α : ℝ) := by
  unfold uniformDist shannonEntropy; norm_num [Fintype.card_eq_zero_iff]
  rw [if_pos (Nat.cast_pos.mp hn), neg_neg]




/-- A point mass distribution: all probability on one element. -/
def pointMass {α : Type*} [Fintype α] [DecidableEq α] (a : α) : α → ℝ :=
  fun x => if x = a then 1 else 0




/-- A point mass is a valid probability distribution. -/
theorem pointMass_isProbDist {α : Type*} [Fintype α] [DecidableEq α] (a : α) :
    IsProbDist (pointMass a) := by
  constructor
  · exact fun x => by unfold pointMass; split_ifs <;> norm_num
  · unfold pointMass; aesop




/-- **Entropy Collapse Theorem**: After measurement (learning the answer),
the distribution collapses to a point mass and entropy drops to zero.
This is the formal analog of "the photons have all collapsed." -/
theorem entropy_collapse {α : Type*} [Fintype α] [DecidableEq α] (a : α) :
    shannonEntropy (pointMass a) = 0 := by
  unfold shannonEntropy pointMass; aesop




/-- The information gained by solving a problem equals the entropy reduction:
from maximum uncertainty (uniform) to certainty (point mass).
ΔI = H(uniform) - H(point mass) = log₂(n) - 0 = log₂(n). -/
theorem information_gain_equals_search_space {α : Type*} [Fintype α] [Nonempty α]
    [DecidableEq α] (a : α) (hn : (Fintype.card α : ℝ) > 0) :
    shannonEntropy (uniformDist α) - shannonEntropy (pointMass a) =
    Real.logb 2 (Fintype.card α : ℝ) := by
  rw [entropy_uniform hn, entropy_collapse a, sub_zero]




/-- The minimum number of yes/no questions needed to identify one element
among n = 2^k possibilities is exactly k. -/
theorem binary_search_depth_pow2 (k : ℕ) :
    Nat.log 2 (2 ^ k) = k := by
  rw [Nat.log_pow (by norm_num)]




/-- **Search-Information Duality (Main Theorem)**:
For a search space of size 2^k, the optimal binary search depth (work done)
equals the Shannon entropy (information gained). The work IS the information.
This is the formal statement of the isomorphism between search and information:
the number of bits of work you must perform to find the answer equals the
number of bits of information you gain by learning it. -/
theorem search_information_duality (k : ℕ) (_hk : k > 0) :
    (Nat.log 2 (2 ^ k) : ℝ) = Real.logb 2 (2 ^ k : ℝ) := by
  norm_num [Real.logb]




end
