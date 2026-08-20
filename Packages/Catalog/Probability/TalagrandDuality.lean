import Probability.TalagrandConcentration

/-!
# The minimax identity for the convex distance

`Talagrand.dHamming_sq_le_dTsq` is the easy (Cauchy–Schwarz) half of Talagrand's
minimax description of the convex distance: every admissible weighted Hamming
distance is dominated by `d_T`.  This file proves that the inequality is in fact
an **equality**,

`dTsq A x = (sup { dHamming w A x | w ≥ 0, ∑ wᵢ² ≤ 1 })²`,

so that the convex distance *is* the largest weighted Hamming distance.  The
proof is the variational characterisation of the nearest point of a compact
convex set:

* the convex hull of the Hamming vectors is the continuous image of the standard
  simplex on `A`, hence compact, so the infimum defining `dTsq` is attained
  (`Talagrand.exists_dTsq_min`);
* at a minimiser `v` one has `⟨v, u⟩ ≥ ‖v‖²` for every point `u` of the hull
  (`Talagrand.inner_ge_sqn_of_min`), obtained by pushing the expansion of
  `t ↦ ‖(1-t)v + tu‖²` to `t → 0⁺`;
* the normalised minimiser `v/‖v‖` is then an admissible weight vector realising
  the supremum.

## Main results

* `Talagrand.exists_dTsq_min` — the infimum defining `dTsq` is attained.
* `Talagrand.dTsq_le_sq_dHamming` — the hard half of the minimax identity: there
  is an admissible `w` with `dTsq A x ≤ (dHamming w A x)²`.
* `Talagrand.dTsq_eq_sq_dTsup` — the minimax identity `dTsq = (sup …)²`.
-/

namespace Talagrand

open Finset

variable {α : Type*} [DecidableEq α] {n : ℕ}

/-! ### Convexity of the hull -/

/-- Each Hamming vector of a point of `A` lies in the hull. -/
lemma isRepW_point {A : Finset (Fin n → α)} {x y : Fin n → α} (hy : y ∈ A) :
    IsRepW A x (fun i => hamm (x i) (y i)) := by
  classical
  refine ⟨fun z => if z = y then 1 else 0, fun z => by dsimp only; split <;> norm_num, ?_,
    fun i => ?_⟩
  · rw [Finset.sum_ite_eq' A y (fun _ => (1 : ℝ))]
    simp [hy]
  · show hamm (x i) (y i) = ∑ z ∈ A, (if z = y then (1:ℝ) else 0) * hamm (x i) (z i)
    rw [Finset.sum_eq_single y]
    · simp
    · intro z _ hz; simp [hz]
    · intro h; exact absurd hy h

/-- The hull is convex. -/
lemma isRepW_convex {A : Finset (Fin n → α)} {x : Fin n → α} {u v : Fin n → ℝ}
    (hu : IsRepW A x u) (hv : IsRepW A x v) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    IsRepW A x (fun i => (1 - t) * u i + t * v i) := by
  obtain ⟨wu, hwu0, hwu1, hwu⟩ := hu
  obtain ⟨wv, hwv0, hwv1, hwv⟩ := hv
  refine ⟨fun z => (1 - t) * wu z + t * wv z, fun z => ?_, ?_, fun i => ?_⟩
  · have h1t : (0:ℝ) ≤ 1 - t := by linarith
    exact add_nonneg (mul_nonneg h1t (hwu0 z)) (mul_nonneg ht0 (hwv0 z))
  · show ∑ z ∈ A, ((1 - t) * wu z + t * wv z) = 1
    rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum, hwu1, hwv1]
    ring
  · show (1 - t) * u i + t * v i
      = ∑ z ∈ A, ((1 - t) * wu z + t * wv z) * hamm (x i) (z i)
    rw [hwu i, hwv i, Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun z _ => by ring

/-! ### Attainment of the infimum -/

/-- **The infimum defining the convex distance is attained.**  The hull is the image
of the standard simplex on `A` under a continuous map, hence compact. -/
lemma exists_dTsq_min {A : Finset (Fin n → α)} (hA : A.Nonempty) (x : Fin n → α) :
    ∃ v, IsRepW A x v ∧ sqn v = dTsq A x := by
  classical
  obtain ⟨y0, hy0⟩ := hA
  haveI : Nonempty {z : Fin n → α // z ∈ A} := ⟨⟨y0, hy0⟩⟩
  have hcont : Continuous (fun w : {z : Fin n → α // z ∈ A} → ℝ =>
      sqn (fun i => ∑ j : {z : Fin n → α // z ∈ A},
        w j * hamm (x i) ((j : Fin n → α) i))) := by
    unfold sqn
    exact continuous_finset_sum _ fun i _ =>
      (continuous_finset_sum _ fun j _ => (continuous_apply j).mul continuous_const).pow 2
  have hne : (stdSimplex ℝ {z : Fin n → α // z ∈ A}).Nonempty := by
    refine ⟨fun j => if j = ⟨y0, hy0⟩ then 1 else 0,
      fun j => by dsimp only; split <;> norm_num, ?_⟩
    simp
  obtain ⟨w, hw, hmin⟩ := (isCompact_stdSimplex _).exists_isMinOn hne hcont.continuousOn
  obtain ⟨hw0, hw1⟩ := hw
  -- the point of the hull attached to the minimising weight
  have hrep : IsRepW A x
      (fun i => ∑ j : {z : Fin n → α // z ∈ A}, w j * hamm (x i) ((j : Fin n → α) i)) := by
    refine ⟨fun z => if h : z ∈ A then w ⟨z, h⟩ else 0, fun z => ?_, ?_, fun i => ?_⟩
    · by_cases hz : z ∈ A
      · simpa [hz] using hw0 ⟨z, hz⟩
      · simp [hz]
    · rw [← Finset.sum_coe_sort A (fun z => if h : z ∈ A then w ⟨z, h⟩ else 0), ← hw1]
      exact Finset.sum_congr rfl fun j _ => by simp [j.2]
    · show ∑ j : {z : Fin n → α // z ∈ A}, w j * hamm (x i) ((j : Fin n → α) i)
        = ∑ z ∈ A, (if h : z ∈ A then w ⟨z, h⟩ else 0) * hamm (x i) (z i)
      rw [← Finset.sum_coe_sort A
        (fun z => (if h : z ∈ A then w ⟨z, h⟩ else 0) * hamm (x i) (z i))]
      exact Finset.sum_congr rfl fun j _ => by simp [j.2]
  refine ⟨_, hrep, ?_⟩
  · -- and it minimises `sqn` over the hull
    have key : ∀ u : Fin n → ℝ, IsRepW A x u →
        sqn (fun i => ∑ j : {z : Fin n → α // z ∈ A},
          w j * hamm (x i) ((j : Fin n → α) i)) ≤ sqn u := by
      intro u hu
      obtain ⟨Wu, hWu0, hWu1, hWuu⟩ := hu
      have hmem : (fun j : {z : Fin n → α // z ∈ A} => Wu (j : Fin n → α))
          ∈ stdSimplex ℝ {z : Fin n → α // z ∈ A} := by
        refine ⟨fun j => hWu0 _, ?_⟩
        rw [Finset.sum_coe_sort A Wu]
        exact hWu1
      have hfun : (fun i => ∑ j : {z : Fin n → α // z ∈ A},
          Wu (j : Fin n → α) * hamm (x i) ((j : Fin n → α) i)) = u := by
        funext i
        rw [hWuu i]
        exact Finset.sum_coe_sort A (fun z => Wu z * hamm (x i) (z i))
      have h := (isMinOn_iff.mp hmin) _ hmem
      rwa [hfun] at h
    refine le_antisymm ?_ (dTsq_le_of_isRepW hrep)
    refine le_csInf ⟨_, _, hrep.isRep, rfl⟩ ?_
    rintro s ⟨u, hu, rfl⟩
    exact key u hu.isRepW

/-! ### The variational inequality at a minimiser -/

/-- Expansion of the squared norm along a segment. -/
lemma sqn_segment (u v : Fin n → ℝ) (t : ℝ) :
    sqn (fun i => (1 - t) * u i + t * v i)
      = (1 - t) ^ 2 * sqn u + (2 * t * (1 - t)) * (∑ i, u i * v i) + t ^ 2 * sqn v := by
  unfold sqn
  rw [Finset.mul_sum, Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib,
    ← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- Expansion of the squared norm of a difference. -/
lemma sqn_sub_expand (u v : Fin n → ℝ) :
    ∑ i, (u i - v i) ^ 2 = sqn u - 2 * (∑ i, u i * v i) + sqn v := by
  unfold sqn
  rw [Finset.mul_sum, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- **The variational inequality.**  At a minimiser `v` of the squared norm on the
hull, every point `u` of the hull satisfies `⟨v, u⟩ ≥ ‖v‖²`. -/
lemma inner_ge_sqn_of_min {A : Finset (Fin n → α)} {x : Fin n → α} {v : Fin n → ℝ}
    (hv : IsRepW A x v) (hmin : sqn v = dTsq A x) {u : Fin n → ℝ} (hu : IsRepW A x u) :
    sqn v ≤ ∑ i, v i * u i := by
  have hkey : ∀ t : ℝ, 0 ≤ t → t ≤ 1 →
      sqn v ≤ (1 - t) ^ 2 * sqn v + (2 * t * (1 - t)) * (∑ i, v i * u i) + t ^ 2 * sqn u := by
    intro t ht0 ht1
    have h := dTsq_le_of_isRepW (isRepW_convex hv hu ht0 ht1)
    rw [sqn_segment] at h
    exact le_of_eq_of_le hmin h
  by_contra hcon
  push_neg at hcon
  -- `hcon : ∑ i, v i * u i < sqn v`; the expansion at small `t` gives a contradiction
  have hDnn : 0 ≤ sqn v - 2 * (∑ i, v i * u i) + sqn u := by
    have h := Finset.sum_nonneg (fun i (_ : i ∈ (Finset.univ : Finset (Fin n))) =>
      sq_nonneg (v i - u i))
    rw [sqn_sub_expand] at h
    exact h
  set s := sqn v with hsdef
  set P := ∑ i, v i * u i with hPdef
  set U := sqn u with hUdef
  set D := s - 2 * P + U with hDdef
  have hsP : 0 < s - P := by simp only [hsdef, hPdef]; linarith
  have hD1 : (0:ℝ) < D + 1 := by simp only [hDdef]; linarith
  set t := min 1 ((s - P) / (D + 1)) with htdef
  have ht0 : 0 < t := lt_min one_pos (div_pos hsP hD1)
  have ht1 : t ≤ 1 := min_le_left _ _
  have htle : t ≤ (s - P) / (D + 1) := min_le_right _ _
  have hexp := hkey t ht0.le ht1
  have hquad : 2 * t * (s - P) ≤ t ^ 2 * D := by nlinarith [hexp]
  have hlin : 2 * (s - P) ≤ t * D := by nlinarith [hquad, ht0]
  have htD : t * D ≤ s - P := by
    have h1 : t * (D + 1) ≤ s - P := by
      calc t * (D + 1) ≤ ((s - P) / (D + 1)) * (D + 1) :=
            mul_le_mul_of_nonneg_right htle hD1.le
        _ = s - P := by field_simp
    nlinarith [ht0.le, hDnn]
  linarith

/-! ### The minimax identity -/

/-- The hard half of the minimax identity: the convex distance is realised by an
admissible weight vector. -/
theorem dTsq_le_sq_dHamming {A : Finset (Fin n → α)} (hA : A.Nonempty) (x : Fin n → α) :
    ∃ w : Fin n → ℝ, (∀ i, 0 ≤ w i) ∧ (∑ i, (w i) ^ 2 ≤ 1) ∧
      dTsq A x ≤ (dHamming w A x) ^ 2 := by
  classical
  obtain ⟨v, hv, hmin⟩ := exists_dTsq_min hA x
  rcases eq_or_lt_of_le (dTsq_nonneg A x) with h0 | hpos
  · -- degenerate case: the convex distance vanishes
    refine ⟨fun _ => 0, fun _ => le_rfl, by simp, ?_⟩
    rw [← h0]
    positivity
  · have hs : 0 < sqn v := by rw [hmin]; exact hpos
    have hsr : 0 < Real.sqrt (sqn v) := Real.sqrt_pos.mpr hs
    refine ⟨fun i => v i / Real.sqrt (sqn v), fun i => ?_, ?_, ?_⟩
    · exact div_nonneg (hv.isRep.nonneg i) hsr.le
    · have hsum : ∑ i, (v i / Real.sqrt (sqn v)) ^ 2 = (∑ i, (v i) ^ 2) / (sqn v) := by
        rw [Finset.sum_div]
        exact Finset.sum_congr rfl fun i _ => by
          rw [div_pow, Real.sq_sqrt hs.le]
      have hid : (∑ i, (v i) ^ 2) = sqn v := rfl
      rw [hsum, hid, div_self (ne_of_gt hs)]
    · have hlow : Real.sqrt (sqn v) ≤ dHamming (fun i => v i / Real.sqrt (sqn v)) A x := by
        refine le_dHamming hA fun y hy => ?_
        have hinner : sqn v ≤ ∑ i, v i * hamm (x i) (y i) :=
          inner_ge_sqn_of_min hv hmin (isRepW_point hy)
        have hrw : ∑ i, v i / Real.sqrt (sqn v) * hamm (x i) (y i)
            = (∑ i, v i * hamm (x i) (y i)) / Real.sqrt (sqn v) := by
          rw [Finset.sum_div]
          exact Finset.sum_congr rfl fun i _ => by ring
        rw [hrw, le_div_iff₀ hsr]
        have hsq : Real.sqrt (sqn v) * Real.sqrt (sqn v) = sqn v :=
          Real.mul_self_sqrt hs.le
        linarith [hsq ▸ hinner]
      have hnn : 0 ≤ Real.sqrt (sqn v) := hsr.le
      have hsq2 : (Real.sqrt (sqn v)) ^ 2
          ≤ (dHamming (fun i => v i / Real.sqrt (sqn v)) A x) ^ 2 := by nlinarith
      rw [Real.sq_sqrt hs.le] at hsq2
      linarith [hsq2, hmin.ge, hmin.le]

/-- The supremum of the admissible weighted Hamming distances to `A`. -/
noncomputable def dTsup (A : Finset (Fin n → α)) (x : Fin n → α) : ℝ :=
  sSup {t : ℝ | ∃ w : Fin n → ℝ, (∀ i, 0 ≤ w i) ∧ (∑ i, (w i) ^ 2 ≤ 1) ∧ t = dHamming w A x}

lemma dTsupSet_nonempty (A : Finset (Fin n → α)) (x : Fin n → α) :
    {t : ℝ | ∃ w : Fin n → ℝ, (∀ i, 0 ≤ w i) ∧ (∑ i, (w i) ^ 2 ≤ 1) ∧
      t = dHamming w A x}.Nonempty :=
  ⟨dHamming (fun _ => 0) A x, ⟨fun _ => 0, fun _ => le_rfl, by simp, rfl⟩⟩

lemma dTsupSet_bddAbove (A : Finset (Fin n → α)) (hA : A.Nonempty) (x : Fin n → α) :
    BddAbove {t : ℝ | ∃ w : Fin n → ℝ, (∀ i, 0 ≤ w i) ∧ (∑ i, (w i) ^ 2 ≤ 1) ∧
      t = dHamming w A x} := by
  refine ⟨(n : ℝ) + 1, ?_⟩
  rintro t ⟨w, hw0, hw2, rfl⟩
  have h1 : (dHamming w A x) ^ 2 ≤ dTsq A x := dHamming_sq_le_dTsq hw0 hw2 hA x
  have h2 : dTsq A x ≤ n := dTsq_le_card hA x
  have h3 : 0 ≤ dHamming w A x := dHamming_nonneg hw0 A x
  nlinarith

/-- **Talagrand's minimax identity.**  The squared convex distance is the square of
the largest admissible weighted Hamming distance: the Cauchy–Schwarz bound
`Talagrand.dHamming_sq_le_dTsq` is sharp. -/
theorem dTsq_eq_sq_dTsup {A : Finset (Fin n → α)} (hA : A.Nonempty) (x : Fin n → α) :
    dTsq A x = (dTsup A x) ^ 2 := by
  have hne := dTsupSet_nonempty A x
  have hbdd := dTsupSet_bddAbove A hA x
  have hnn : 0 ≤ dTsup A x := by
    have h0 : dHamming (fun _ => 0) A x ≤ dTsup A x :=
      le_csSup hbdd ⟨fun _ => 0, fun _ => le_rfl, by simp, rfl⟩
    have h1 : 0 ≤ dHamming (fun _ : Fin n => (0:ℝ)) A x :=
      dHamming_nonneg (fun _ => le_rfl) A x
    linarith
  refine le_antisymm ?_ ?_
  · obtain ⟨w, hw0, hw2, hle⟩ := dTsq_le_sq_dHamming hA x
    have hmem : dHamming w A x ≤ dTsup A x := le_csSup hbdd ⟨w, hw0, hw2, rfl⟩
    have hnn' : 0 ≤ dHamming w A x := dHamming_nonneg hw0 A x
    nlinarith
  · have hub : dTsup A x ≤ Real.sqrt (dTsq A x) := by
      refine csSup_le hne ?_
      rintro t ⟨w, hw0, hw2, rfl⟩
      have h1 : (dHamming w A x) ^ 2 ≤ dTsq A x := dHamming_sq_le_dTsq hw0 hw2 hA x
      have h2 : 0 ≤ dHamming w A x := dHamming_nonneg hw0 A x
      have h3 := Real.sqrt_le_sqrt h1
      rwa [Real.sqrt_sq h2] at h3
    have hsq : (dTsup A x) ^ 2 ≤ (Real.sqrt (dTsq A x)) ^ 2 := by
      nlinarith [Real.sqrt_nonneg (dTsq A x)]
    rwa [Real.sq_sqrt (dTsq_nonneg A x)] at hsq

end Talagrand