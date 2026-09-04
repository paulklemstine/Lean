import Mathlib
import Geometry.SpearmanPermutohedronGap

/-!
# The `ℓ¹` face of the dial: Spearman's footrule, inversions, and a Diaconis–Graham bound

## Research context (FACT round-44 #2, exp 499, `T-DIAL-AXES`)

`Geometry.SpearmanPermutohedronGap` established that the Spearman reading of the `T`-dial is a
rescaled **squared Euclidean** distance `D` between two vertices of the permutohedron, and
extracted the quantisation gap that this forces.  The measurement protocol of the experiment,
however, is not intrinsically `ℓ²`: the "regime holds / `u` breaks" reading compares a rank
statistic against a downstream rate through a *threshold* `u`, and thresholded disagreement is
an `ℓ¹` / combinatorial quantity (how many pairs are ordered the wrong way, and how far each
item has to travel).

This file develops the `ℓ¹` face — Spearman's **footrule** `F σ τ = ∑ |σ i − τ i|` and the
**inversion count** `inv σ` — and pins it to the `ℓ²` face by two-sided comparison
inequalities.  The consequence for the dial programme is that the three natural
disagreement scales (`ℓ¹` travel, `ℓ²` travel, pairwise disorder) are equivalent up to
explicit factors, so a band violation in one is a band violation in all three; there is no
choice of metric that rescues a failing operating point.

## Main results

* `F_dist_triangle`, `F_right_invariant`, `F_eq_zero_iff`, `F_subadditive` — the footrule is a
  right-invariant metric on the symmetric group, and `σ ↦ F σ 1` is subadditive, i.e. a
  *length function*.
* `F_swap` — a transposition of `a` and `b` costs exactly `2|a − b|`.
* `F_le_D` and `D_le_pred_mul_F` — the `ℓ¹` and `ℓ²` readings are equivalent:
  `F ≤ D ≤ (n − 1) F`.
* `F_sq_le_card_mul_D` — the Cauchy–Schwarz refinement `F² ≤ n · D`.
* `footrule_le_two_mul_inv` — **the Diaconis–Graham upper bound** `F σ 1 ≤ 2 · inv σ`, proved
  by the displacement-counting argument: an item that must move `σ i − i` places to the right
  is involved in at least that many inversions as the left endpoint, and dually.
* `F_pos_of_inv_pos`, `inv_pos_of_ne_one` — the resulting equivalence of "some inversion
  exists" with "the footrule is positive" with "`σ ≠ 1`".
* `D_le_pred_mul_two_mul_inv` — chaining the above: `D σ 1 ≤ 2(n − 1) · inv σ`, an `ℓ²` bound
  from purely combinatorial disorder data.

## Lab notes

`labnote_footrule_le_D_fin3` and `labnote_dg_fin3` record the exhaustive `n = 3` check: the two
comparison inequalities and the Diaconis–Graham bound hold on all six vertices of the hexagon,
and `labnote_dg_sharp_fin3` exhibits the transposition `swap 0 2`, for which
`F = 4 = 2·inv − 2` is *not* tight, together with `swap 0 1`, for which `F = 2 = 2·inv` is
tight: the factor `2` cannot be improved.
-/

namespace Catalog.Geometry.SpearmanFootrule

open Finset Catalog.Geometry.SpearmanPermutohedron

variable {n : ℕ}

/-! ## Section 1. The footrule metric -/

/-- Spearman's footrule: the `ℓ¹` distance between two rank vectors. -/
def F (σ τ : Equiv.Perm (Fin n)) : ℤ := ∑ i, |rk σ i - rk τ i|

theorem F_nonneg (σ τ : Equiv.Perm (Fin n)) : 0 ≤ F σ τ :=
  Finset.sum_nonneg fun _ _ => abs_nonneg _

theorem F_comm (σ τ : Equiv.Perm (Fin n)) : F σ τ = F τ σ :=
  Finset.sum_congr rfl fun _ _ => abs_sub_comm _ _

theorem F_dist_triangle (σ τ π : Equiv.Perm (Fin n)) : F σ π ≤ F σ τ + F τ π := by
  unfold F
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_le_sum fun i _ => abs_sub_le _ _ _

theorem F_eq_zero_iff (σ τ : Equiv.Perm (Fin n)) : F σ τ = 0 ↔ σ = τ := by
  constructor
  · intro h
    have hall := (Finset.sum_eq_zero_iff_of_nonneg
      (fun i _ => abs_nonneg (rk σ i - rk τ i))).1 h
    ext i
    have hi := hall i (Finset.mem_univ i)
    have hrk : rk σ i = rk τ i := by
      have := abs_eq_zero.1 hi
      linarith
    unfold rk at hrk
    exact_mod_cast hrk
  · rintro rfl; simp [F]

theorem F_right_invariant (σ τ π : Equiv.Perm (Fin n)) : F (σ * π) (τ * π) = F σ τ := by
  unfold F
  simp_rw [rk_mul]
  exact Equiv.sum_comp π (fun i => |rk σ i - rk τ i|)

/-- `σ ↦ F σ 1` is a length function on the symmetric group. -/
theorem F_subadditive (σ τ : Equiv.Perm (Fin n)) : F (σ * τ) 1 ≤ F σ 1 + F τ 1 := by
  have h1 : F (σ * τ) τ = F σ 1 := by
    have := F_right_invariant σ 1 τ
    rwa [one_mul] at this
  calc F (σ * τ) 1 ≤ F (σ * τ) τ + F τ 1 := F_dist_triangle _ _ _
    _ = F σ 1 + F τ 1 := by rw [h1]

/-- A transposition costs exactly twice the distance it moves. -/
theorem F_swap (a b : Fin n) :
    F (Equiv.swap a b) 1 = 2 * |((a : ℕ) : ℤ) - ((b : ℕ) : ℤ)| := by
  have hzero : ∀ i ∈ (Finset.univ : Finset (Fin n)),
      i ∉ ({a, b} : Finset (Fin n)) → |rk (Equiv.swap a b) i - rk 1 i| = 0 := by
    intro i _ hi
    simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hi
    have : Equiv.swap a b i = i := Equiv.swap_apply_of_ne_of_ne hi.1 hi.2
    simp [rk, this]
  have hsub : ({a, b} : Finset (Fin n)) ⊆ Finset.univ := Finset.subset_univ _
  have hsum : F (Equiv.swap a b) 1
      = ∑ i ∈ ({a, b} : Finset (Fin n)), |rk (Equiv.swap a b) i - rk 1 i| :=
    (Finset.sum_subset hsub hzero).symm
  rcases eq_or_ne a b with rfl | hab
  · simp only [Equiv.swap_self, sub_self, abs_zero, mul_zero]
    exact (F_eq_zero_iff _ 1).2 rfl
  · rw [hsum, Finset.sum_pair hab]
    simp only [rk, Equiv.swap_apply_left, Equiv.swap_apply_right, Equiv.Perm.one_apply]
    rw [abs_sub_comm ((b : ℕ) : ℤ) ((a : ℕ) : ℤ)]
    ring

/-! ## Section 2. Comparison of the `ℓ¹` and `ℓ²` readings -/

lemma abs_le_sq (x : ℤ) : |x| ≤ x ^ 2 := by
  have h0 : 0 ≤ |x| := abs_nonneg x
  have hsq : x ^ 2 = |x| ^ 2 := (sq_abs x).symm
  rcases eq_or_lt_of_le h0 with h | h
  · rw [hsq, ← h]; norm_num
  · have h1 : 1 ≤ |x| := h
    nlinarith

/-- The `ℓ¹` reading never exceeds the `ℓ²` reading. -/
theorem F_le_D (σ τ : Equiv.Perm (Fin n)) : F σ τ ≤ D σ τ :=
  Finset.sum_le_sum fun _ _ => abs_le_sq _

lemma rk_sub_abs_le (σ τ : Equiv.Perm (Fin n)) (i : Fin n) :
    |rk σ i - rk τ i| ≤ (n : ℤ) - 1 := by
  have h1 : ((σ i : Fin n) : ℕ) < n := (σ i).isLt
  have h2 : ((τ i : Fin n) : ℕ) < n := (τ i).isLt
  unfold rk
  rw [abs_le]
  constructor <;> omega

/-- Conversely, the `ℓ²` reading is at most `(n − 1)` times the `ℓ¹` reading. -/
theorem D_le_pred_mul_F (σ τ : Equiv.Perm (Fin n)) : D σ τ ≤ ((n : ℤ) - 1) * F σ τ := by
  unfold D F
  rw [Finset.mul_sum]
  refine Finset.sum_le_sum fun i _ => ?_
  have hb := rk_sub_abs_le σ τ i
  have h0 := abs_nonneg (rk σ i - rk τ i)
  have hsq : (rk σ i - rk τ i) ^ 2 = |rk σ i - rk τ i| * |rk σ i - rk τ i| := by
    rw [abs_mul_abs_self, sq]
  rw [hsq]
  exact mul_le_mul_of_nonneg_right hb h0

/-- Cauchy–Schwarz: the footrule is controlled by `√(n · ∑d²)`. -/
theorem F_sq_le_card_mul_D (σ τ : Equiv.Perm (Fin n)) : (F σ τ) ^ 2 ≤ (n : ℤ) * D σ τ := by
  have h := sq_sum_le_card_mul_sum_sq (s := (Finset.univ : Finset (Fin n)))
    (f := fun i => |rk σ i - rk τ i|)
  have hcard : ((Finset.univ : Finset (Fin n)).card : ℤ) = (n : ℤ) := by simp
  have hD : ∑ i, |rk σ i - rk τ i| ^ 2 = D σ τ :=
    Finset.sum_congr rfl fun i _ => sq_abs _
  rw [hcard, hD] at h
  exact h

/-! ## Section 3. Inversions and the Diaconis–Graham bound -/

/-- Inversions with left endpoint `i`. -/
def rightInv (σ : Equiv.Perm (Fin n)) (i : Fin n) : Finset (Fin n) :=
  Finset.univ.filter (fun j => i < j ∧ σ j < σ i)

/-- Inversions with right endpoint `i`. -/
def leftInv (σ : Equiv.Perm (Fin n)) (i : Fin n) : Finset (Fin n) :=
  Finset.univ.filter (fun j => j < i ∧ σ i < σ j)

/-- The number of inversions of a permutation. -/
def inv (σ : Equiv.Perm (Fin n)) : ℕ := ∑ i, (rightInv σ i).card

/-- Counting inversions by their right endpoint gives the same total. -/
theorem inv_eq_sum_leftInv (σ : Equiv.Perm (Fin n)) : inv σ = ∑ i, (leftInv σ i).card := by
  unfold inv rightInv leftInv
  simp_rw [Finset.card_filter]
  rw [Finset.sum_comm]

lemma card_lt_pull (σ : Equiv.Perm (Fin n)) (c : Fin n) :
    (Finset.univ.filter (fun j => σ j < c)).card = (c : ℕ) := by
  rw [← Fin.card_Iio c]
  refine Finset.card_bij' (fun j _ => σ j) (fun v _ => σ.symm v) ?_ ?_ ?_ ?_
  · intro a ha
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha
    simpa using ha
  · intro b hb
    simp only [Finset.mem_Iio] at hb
    simpa using hb
  · intro a _; simp
  · intro b _; simp

lemma card_gt_pull (σ : Equiv.Perm (Fin n)) (c : Fin n) :
    (Finset.univ.filter (fun j => c < σ j)).card = n - 1 - (c : ℕ) := by
  rw [← Fin.card_Ioi c]
  refine Finset.card_bij' (fun j _ => σ j) (fun v _ => σ.symm v) ?_ ?_ ?_ ?_
  · intro a ha
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha
    simpa using ha
  · intro b hb
    simp only [Finset.mem_Ioi] at hb
    simpa using hb
  · intro a _; simp
  · intro b _; simp

/-- An item that has to travel `σ i − i` places to the right is the left endpoint of at least
that many inversions. -/
theorem displacement_le_rightInv (σ : Equiv.Perm (Fin n)) (i : Fin n) :
    ((σ i : Fin n) : ℕ) ≤ (i : ℕ) + (rightInv σ i).card := by
  classical
  set S : Finset (Fin n) := Finset.univ.filter (fun j => σ j < σ i) with hS
  have hcard : S.card = ((σ i : Fin n) : ℕ) := card_lt_pull σ (σ i)
  have hsplit : (S.filter (fun j => i < j)).card + (S.filter (fun j => ¬ i < j)).card = S.card :=
    Finset.card_filter_add_card_filter_not _
  have hright : S.filter (fun j => i < j) = rightInv σ i := by
    ext j
    simp only [hS, rightInv, Finset.mem_filter, Finset.mem_univ, true_and]
    tauto
  have hleft : S.filter (fun j => ¬ i < j) ⊆ Finset.Iio i := by
    intro j hj
    simp only [Finset.mem_filter, hS, Finset.mem_univ, true_and, not_lt] at hj
    have hne : j ≠ i := by
      rintro rfl
      exact absurd hj.1 (lt_irrefl _)
    exact Finset.mem_Iio.2 (lt_of_le_of_ne hj.2 hne)
  have hle : (S.filter (fun j => ¬ i < j)).card ≤ (i : ℕ) := by
    have := Finset.card_le_card hleft
    rwa [Fin.card_Iio] at this
  rw [hright, hcard] at hsplit
  omega

/-- Dually, an item that has to travel `i − σ i` places to the left is the right endpoint of at
least that many inversions. -/
theorem displacement_le_leftInv (σ : Equiv.Perm (Fin n)) (i : Fin n) :
    (i : ℕ) ≤ ((σ i : Fin n) : ℕ) + (leftInv σ i).card := by
  classical
  set T : Finset (Fin n) := Finset.univ.filter (fun j => σ i < σ j) with hT
  have hcard : T.card = n - 1 - ((σ i : Fin n) : ℕ) := card_gt_pull σ (σ i)
  have hsplit : (T.filter (fun j => j < i)).card + (T.filter (fun j => ¬ j < i)).card = T.card :=
    Finset.card_filter_add_card_filter_not _
  have hleft : T.filter (fun j => j < i) = leftInv σ i := by
    ext j
    simp only [hT, leftInv, Finset.mem_filter, Finset.mem_univ, true_and]
    tauto
  have hright : T.filter (fun j => ¬ j < i) ⊆ Finset.Ioi i := by
    intro j hj
    simp only [Finset.mem_filter, hT, Finset.mem_univ, true_and, not_lt] at hj
    have hne : j ≠ i := by
      rintro rfl
      exact absurd hj.1 (lt_irrefl _)
    exact Finset.mem_Ioi.2 (lt_of_le_of_ne hj.2 (Ne.symm hne))
  have hle : (T.filter (fun j => ¬ j < i)).card ≤ n - 1 - (i : ℕ) := by
    have := Finset.card_le_card hright
    rwa [Fin.card_Ioi] at this
  have hi : (i : ℕ) < n := i.isLt
  have hsi : ((σ i : Fin n) : ℕ) < n := (σ i).isLt
  rw [hleft, hcard] at hsplit
  omega

lemma abs_rk_le (σ : Equiv.Perm (Fin n)) (i : Fin n) :
    |rk σ i - rk 1 i| ≤ ((rightInv σ i).card : ℤ) + ((leftInv σ i).card : ℤ) := by
  have h1 := displacement_le_rightInv σ i
  have h2 := displacement_le_leftInv σ i
  have h1' : (((σ i : Fin n) : ℕ) : ℤ) ≤ ((i : ℕ) : ℤ) + ((rightInv σ i).card : ℤ) := by
    exact_mod_cast h1
  have h2' : ((i : ℕ) : ℤ) ≤ (((σ i : Fin n) : ℕ) : ℤ) + ((leftInv σ i).card : ℤ) := by
    exact_mod_cast h2
  have hR : (0 : ℤ) ≤ ((rightInv σ i).card : ℤ) := Int.natCast_nonneg _
  have hL : (0 : ℤ) ≤ ((leftInv σ i).card : ℤ) := Int.natCast_nonneg _
  unfold rk
  rw [abs_le]
  constructor <;> simp only [Equiv.Perm.one_apply] <;> linarith

/-- **Diaconis–Graham upper bound.**  The footrule of a permutation is at most twice its
inversion number. -/
theorem footrule_le_two_mul_inv (σ : Equiv.Perm (Fin n)) :
    F σ 1 ≤ 2 * (inv σ : ℤ) := by
  have hsum : F σ 1 ≤ ∑ i, (((rightInv σ i).card : ℤ) + ((leftInv σ i).card : ℤ)) :=
    Finset.sum_le_sum fun i _ => abs_rk_le σ i
  have hsplit : ∑ i, (((rightInv σ i).card : ℤ) + ((leftInv σ i).card : ℤ))
      = ((∑ i, (rightInv σ i).card : ℕ) : ℤ) + ((∑ i, (leftInv σ i).card : ℕ) : ℤ) := by
    push_cast
    rw [Finset.sum_add_distrib]
  have hleft : ((∑ i, (leftInv σ i).card : ℕ) : ℤ) = (inv σ : ℤ) := by
    rw [inv_eq_sum_leftInv]
  rw [hsplit, hleft] at hsum
  have : ((∑ i, (rightInv σ i).card : ℕ) : ℤ) = (inv σ : ℤ) := rfl
  rw [this] at hsum
  linarith

/-- An `ℓ²` bound from purely combinatorial disorder data. -/
theorem D_le_pred_mul_two_mul_inv (σ : Equiv.Perm (Fin n)) :
    D σ 1 ≤ ((n : ℤ) - 1) * (2 * (inv σ : ℤ)) := by
  have h1 := D_le_pred_mul_F σ 1
  have h2 := footrule_le_two_mul_inv σ
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp [D]
  · have hn1 : (0 : ℤ) ≤ (n : ℤ) - 1 := by
      have : (1 : ℤ) ≤ (n : ℤ) := by exact_mod_cast hn
      linarith
    nlinarith

/-- Positivity transfer: a nontrivial permutation has a positive footrule, hence inversions. -/
theorem F_pos_of_ne_one {σ : Equiv.Perm (Fin n)} (h : σ ≠ 1) : 0 < F σ 1 :=
  lt_of_le_of_ne (F_nonneg σ 1) (fun hc => h ((F_eq_zero_iff σ 1).1 hc.symm))

theorem inv_pos_of_ne_one {σ : Equiv.Perm (Fin n)} (h : σ ≠ 1) : 0 < inv σ := by
  have h1 := F_pos_of_ne_one h
  have h2 := footrule_le_two_mul_inv σ
  have : (0 : ℤ) < (inv σ : ℤ) := by linarith
  exact_mod_cast this

/-! ## Lab notes: exhaustive `n = 3` data -/

/-- Both comparison inequalities hold on all `36` vertex pairs of the hexagon. -/
theorem labnote_footrule_le_D_fin3 :
    ∀ σ τ : Equiv.Perm (Fin 3), F σ τ ≤ D σ τ ∧ D σ τ ≤ 2 * F σ τ := by
  decide

/-- The Diaconis–Graham bound holds on all six vertices. -/
theorem labnote_dg_fin3 : ∀ σ : Equiv.Perm (Fin 3), F σ 1 ≤ 2 * (inv σ : ℤ) := by
  decide

/-- The constant `2` in `footrule_le_two_mul_inv` cannot be lowered: for the adjacent
transposition `swap 0 1` the bound is attained (`F = 2 = 2·inv`), while for `swap 0 2` it is
strict (`F = 4 < 6 = 2·inv`). -/
theorem labnote_dg_sharp_fin3 :
    F (Equiv.swap (0 : Fin 3) 1) 1 = 2 * (inv (Equiv.swap (0 : Fin 3) 1) : ℤ) ∧
      F (Equiv.swap (0 : Fin 3) 2) 1 < 2 * (inv (Equiv.swap (0 : Fin 3) 2) : ℤ) := by
  decide

set_option maxRecDepth 100000 in
/-- **Evidence for the Diaconis–Graham lower bound.**  The companion inequality
`inv σ + T σ ≤ F σ 1`, where `T σ = |support σ| − |cycleType σ|` is the minimal number of
transpositions needed to build `σ`, is *not* proved here; this is the exhaustive check that it
holds on all `24` permutations of `Fin 4`.  (It was also checked by evaluation on `Fin 5` and
`Fin 6`.)  See `FUTURE_DIRECTIONS.md`. -/
theorem labnote_dg_lower_fin4 : ∀ σ : Equiv.Perm (Fin 4),
    (inv σ : ℤ) + ((σ.support.card - σ.cycleType.card : ℕ) : ℤ) ≤ F σ 1 := by
  decide

end Catalog.Geometry.SpearmanFootrule