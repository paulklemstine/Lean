import Mathlib

/-!
# Talagrand's convex distance on finite product spaces: definitions

This file sets up the combinatorial/geometric objects underlying Talagrand's
concentration inequality on product spaces.

Throughout, the ambient space is the finite product `Fin n → α` for a finite
alphabet `α`.  For a subset `A` (a `Finset`) and a point `x`, Talagrand's
*convex distance* is

  `d_T(x, A) = min { ‖v‖₂ : v ∈ conv { (1[x i ≠ y i])_i : y ∈ A } }`.

Rather than invoking `convexHull`, we encode a point of the convex hull by an
explicit finite convex combination (`Talagrand.IsRep`), which makes the
inductive proof of the concentration inequality far more manageable.  We work
throughout with the *square* of the convex distance, `Talagrand.dTsq`, since
this is the quantity that appears in the exponential moment bound.

## Main definitions

* `Talagrand.hamm` — the one-coordinate Hamming indicator.
* `Talagrand.IsRep A x v` — `v` is a convex combination of the Hamming
  indicator vectors `y ↦ (1[x i ≠ y i])_i` for `y ∈ A`.
* `Talagrand.sqn` — the squared Euclidean norm on `Fin n → ℝ`.
* `Talagrand.dTsq A x` — the squared convex distance from `x` to `A`.
* `Talagrand.dHamming w A x` — the `w`-weighted Hamming distance from `x` to `A`.

## Main results

* `Talagrand.dTsq_nonneg`, `Talagrand.dTsq_le_of_isRep`, `Talagrand.exists_isRep_lt`
  — the basic infimum API.
* `Talagrand.dTsq_eq_zero_of_mem`, `Talagrand.dTsq_le_card` — degenerate bounds.
* `Talagrand.dTsq_mono` — antitonicity in the target set.
* `Talagrand.dHamming_sq_le_dTsq` — the duality inequality: the convex distance
  dominates every weighted Hamming distance with `∑ w i ^ 2 ≤ 1`.  This is the
  easy (Cauchy–Schwarz) half of Talagrand's minimax description of `d_T`, and
  it is exactly the half needed to derive weighted-Hamming concentration.
-/

namespace Talagrand

open Finset

variable {α : Type*} [DecidableEq α] {n : ℕ}

/-- The Hamming indicator of a single coordinate: `0` if the letters agree,
`1` otherwise. -/
def hamm (u v : α) : ℝ := if u = v then 0 else 1

@[simp] lemma hamm_self (u : α) : hamm u u = 0 := by simp [hamm]

lemma hamm_nonneg (u v : α) : 0 ≤ hamm u v := by
  unfold hamm; split <;> norm_num

lemma hamm_le_one (u v : α) : hamm u v ≤ 1 := by
  unfold hamm; split <;> norm_num

/-- The squared Euclidean norm. -/
def sqn (v : Fin n → ℝ) : ℝ := ∑ i, (v i) ^ 2

lemma sqn_nonneg (v : Fin n → ℝ) : 0 ≤ sqn v :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- `v` is a convex combination of the Hamming indicator vectors of the points
of `A`, as seen from `x`. -/
def IsRep (A : Finset (Fin n → α)) (x : Fin n → α) (v : Fin n → ℝ) : Prop :=
  ∃ (k : ℕ) (w : Fin k → ℝ) (y : Fin k → (Fin n → α)),
    (∀ j, 0 ≤ w j) ∧ (∑ j, w j = 1) ∧ (∀ j, y j ∈ A) ∧
    ∀ i, v i = ∑ j, w j * hamm (x i) (y j i)

lemma IsRep.nonneg {A : Finset (Fin n → α)} {x : Fin n → α} {v : Fin n → ℝ}
    (h : IsRep A x v) (i : Fin n) : 0 ≤ v i := by
  obtain ⟨k, w, y, hw0, _, _, hv⟩ := h
  rw [hv i]
  exact Finset.sum_nonneg fun j _ => mul_nonneg (hw0 j) (hamm_nonneg _ _)

lemma IsRep.le_one {A : Finset (Fin n → α)} {x : Fin n → α} {v : Fin n → ℝ}
    (h : IsRep A x v) (i : Fin n) : v i ≤ 1 := by
  obtain ⟨k, w, y, hw0, hw1, _, hv⟩ := h
  rw [hv i, ← hw1]
  refine Finset.sum_le_sum fun j _ => ?_
  calc w j * hamm (x i) (y j i) ≤ w j * 1 :=
        mul_le_mul_of_nonneg_left (hamm_le_one _ _) (hw0 j)
    _ = w j := mul_one _

/-- The squared convex distance of Talagrand. -/
noncomputable def dTsq (A : Finset (Fin n → α)) (x : Fin n → α) : ℝ :=
  sInf {s : ℝ | ∃ v, IsRep A x v ∧ s = sqn v}

lemma bddBelow_dTsqSet (A : Finset (Fin n → α)) (x : Fin n → α) :
    BddBelow {s : ℝ | ∃ v, IsRep A x v ∧ s = sqn v} := by
  refine ⟨0, ?_⟩
  rintro s ⟨v, -, rfl⟩
  exact sqn_nonneg v

lemma dTsq_nonneg (A : Finset (Fin n → α)) (x : Fin n → α) : 0 ≤ dTsq A x := by
  apply Real.sInf_nonneg
  rintro s ⟨v, -, rfl⟩
  exact sqn_nonneg v

lemma dTsq_le_of_isRep {A : Finset (Fin n → α)} {x : Fin n → α} {v : Fin n → ℝ}
    (h : IsRep A x v) : dTsq A x ≤ sqn v :=
  csInf_le (bddBelow_dTsqSet A x) ⟨v, h, rfl⟩

/-- Any point of `A` provides a representation vector, namely `0`. -/
lemma isRep_of_mem {A : Finset (Fin n → α)} {x : Fin n → α} (hx : x ∈ A) :
    IsRep A x (fun _ => 0) := by
  refine ⟨1, fun _ => 1, fun _ => x, fun _ => zero_le_one, by simp, fun _ => hx, fun i => ?_⟩
  simp

lemma dTsq_eq_zero_of_mem {A : Finset (Fin n → α)} {x : Fin n → α} (hx : x ∈ A) :
    dTsq A x = 0 := by
  refine le_antisymm ?_ (dTsq_nonneg A x)
  have := dTsq_le_of_isRep (isRep_of_mem hx)
  simpa [sqn] using this

/-- For a nonempty `A` there is at least one representation vector. -/
lemma exists_isRep {A : Finset (Fin n → α)} (hA : A.Nonempty) (x : Fin n → α) :
    ∃ v, IsRep A x v := by
  obtain ⟨y0, hy0⟩ := hA
  exact ⟨fun i => hamm (x i) (y0 i), 1, fun _ => 1, fun _ => y0,
    fun _ => zero_le_one, by simp, fun _ => hy0, fun i => by simp⟩

/-- The infimum defining `dTsq` is approached: near-optimal representations exist. -/
lemma exists_isRep_lt {A : Finset (Fin n → α)} (hA : A.Nonempty) (x : Fin n → α)
    {ε : ℝ} (hε : 0 < ε) : ∃ v, IsRep A x v ∧ sqn v < dTsq A x + ε := by
  obtain ⟨v0, hv0⟩ := exists_isRep hA x
  have hne : {s : ℝ | ∃ v, IsRep A x v ∧ s = sqn v}.Nonempty := ⟨sqn v0, v0, hv0, rfl⟩
  have : ∃ s ∈ {s : ℝ | ∃ v, IsRep A x v ∧ s = sqn v}, s < dTsq A x + ε := by
    apply exists_lt_of_csInf_lt hne
    exact lt_add_of_pos_right _ hε
  obtain ⟨s, ⟨v, hv, rfl⟩, hs⟩ := this
  exact ⟨v, hv, hs⟩

/-- Antitonicity of the convex distance in the target set.  (The nonemptiness
hypothesis is genuinely needed: for `A = ∅` the defining set is empty, so the
`sInf` degenerates to the junk value `0`.) -/
lemma dTsq_mono {A B : Finset (Fin n → α)} (hA : A.Nonempty) (hAB : A ⊆ B) (x : Fin n → α) :
    dTsq B x ≤ dTsq A x := by
  refine le_of_forall_pos_le_add fun ε hε => ?_
  obtain ⟨v, hv, hlt⟩ := exists_isRep_lt hA x hε
  obtain ⟨k, w, y, hw0, hw1, hy, hveq⟩ := hv
  have hv' : IsRep B x v := ⟨k, w, y, hw0, hw1, fun j => hAB (hy j), hveq⟩
  exact le_trans (dTsq_le_of_isRep hv') hlt.le

/-- `dTsq` is bounded by the number of coordinates. -/
lemma dTsq_le_card {A : Finset (Fin n → α)} (hA : A.Nonempty) (x : Fin n → α) :
    dTsq A x ≤ n := by
  obtain ⟨v, hv⟩ := exists_isRep hA x
  refine le_trans (dTsq_le_of_isRep hv) ?_
  calc sqn v = ∑ i, (v i) ^ 2 := rfl
    _ ≤ ∑ _i : Fin n, (1 : ℝ) := by
        refine Finset.sum_le_sum fun i _ => ?_
        have h0 := hv.nonneg i
        have h1 := hv.le_one i
        nlinarith
    _ = n := by simp

/-- The `w`-weighted Hamming distance from `x` to the set `A`. -/
noncomputable def dHamming (w : Fin n → ℝ) (A : Finset (Fin n → α)) (x : Fin n → α) : ℝ :=
  sInf {t : ℝ | ∃ y ∈ A, t = ∑ i, w i * hamm (x i) (y i)}

lemma dHammingSet_finite (w : Fin n → ℝ) (A : Finset (Fin n → α)) (x : Fin n → α) :
    {t : ℝ | ∃ y ∈ A, t = ∑ i, w i * hamm (x i) (y i)}.Finite := by
  have h : {t : ℝ | ∃ y ∈ A, t = ∑ i, w i * hamm (x i) (y i)}
      = (fun y => ∑ i, w i * hamm (x i) (y i)) '' (↑A : Set (Fin n → α)) := by
    ext t; simp [eq_comm]
  rw [h]
  exact A.finite_toSet.image _

lemma dHamming_le {w : Fin n → ℝ} {A : Finset (Fin n → α)} {x y : Fin n → α}
    (hy : y ∈ A) : dHamming w A x ≤ ∑ i, w i * hamm (x i) (y i) :=
  csInf_le (dHammingSet_finite w A x).bddBelow ⟨y, hy, rfl⟩

lemma dHamming_nonneg {w : Fin n → ℝ} (hw : ∀ i, 0 ≤ w i) (A : Finset (Fin n → α))
    (x : Fin n → α) : 0 ≤ dHamming w A x := by
  apply Real.sInf_nonneg
  rintro t ⟨y, -, rfl⟩
  exact Finset.sum_nonneg fun i _ => mul_nonneg (hw i) (hamm_nonneg _ _)

/-- **Duality inequality.**  For a nonnegative weight vector `w` of Euclidean norm at
most one, the `w`-weighted Hamming distance to `A` is dominated by the convex
distance.  (This is the Cauchy–Schwarz half of Talagrand's minimax formula.) -/
lemma dHamming_sq_le_dTsq {w : Fin n → ℝ} (hw : ∀ i, 0 ≤ w i) (hw2 : ∑ i, (w i) ^ 2 ≤ 1)
    {A : Finset (Fin n → α)} (hA : A.Nonempty) (x : Fin n → α) :
    (dHamming w A x) ^ 2 ≤ dTsq A x := by
  refine le_of_forall_pos_le_add fun ε hε => ?_
  obtain ⟨v, hv, hlt⟩ := exists_isRep_lt hA x hε
  obtain ⟨k, cw, y, hcw0, hcw1, hyA, hveq⟩ := hv
  -- the linear functional `⟨w, ·⟩` evaluated at the indicator vectors
  set c : Fin k → ℝ := fun j => ∑ i, w i * hamm (x i) (y j i) with hc
  have hknon : (Finset.univ : Finset (Fin k)).Nonempty := by
    rcases Finset.eq_empty_or_nonempty (Finset.univ : Finset (Fin k)) with h | h
    · rw [h] at hcw1; simp at hcw1
    · exact h
  obtain ⟨j0, -, hj0⟩ := Finset.exists_min_image Finset.univ c hknon
  have hmin : c j0 ≤ ∑ j, cw j * c j := by
    have : ∑ j, cw j * c j0 ≤ ∑ j, cw j * c j :=
      Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left (hj0 j (Finset.mem_univ j)) (hcw0 j)
    calc c j0 = (∑ j, cw j) * c j0 := by rw [hcw1, one_mul]
      _ = ∑ j, cw j * c j0 := by rw [Finset.sum_mul]
      _ ≤ ∑ j, cw j * c j := this
  have hinner : ∑ j, cw j * c j = ∑ i, w i * v i := by
    have : ∑ j, cw j * c j = ∑ j, ∑ i, cw j * (w i * hamm (x i) (y j i)) := by
      refine Finset.sum_congr rfl fun j _ => ?_
      rw [hc]
      simp [Finset.mul_sum]
    rw [this, Finset.sum_comm]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [hveq i, Finset.mul_sum]
    exact Finset.sum_congr rfl fun j _ => by ring
  have hcs : (∑ i, w i * v i) ^ 2 ≤ (∑ i, (w i) ^ 2) * (∑ i, (v i) ^ 2) :=
    Finset.sum_mul_sq_le_sq_mul_sq Finset.univ w v
  have hd : dHamming w A x ≤ ∑ i, w i * v i := by
    rw [← hinner]
    exact le_trans (dHamming_le (hyA j0)) hmin
  have hd0 : 0 ≤ dHamming w A x := dHamming_nonneg hw A x
  have hsq : (dHamming w A x) ^ 2 ≤ (∑ i, w i * v i) ^ 2 := by nlinarith
  have hvv : (∑ i, (w i) ^ 2) * (∑ i, (v i) ^ 2) ≤ sqn v := by
    have h0 : (0 : ℝ) ≤ ∑ i, (v i) ^ 2 := Finset.sum_nonneg fun i _ => sq_nonneg _
    calc (∑ i, (w i) ^ 2) * (∑ i, (v i) ^ 2) ≤ 1 * (∑ i, (v i) ^ 2) :=
          mul_le_mul_of_nonneg_right hw2 h0
      _ = sqn v := by rw [one_mul]; rfl
  linarith [hsq, hcs, hvv, hlt.le]

end Talagrand