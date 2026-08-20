import Probability.TalagrandConcentration

/-!
# Convex-distance isoperimetry, and the exact convex distance to a subcube

Two complements to the concentration package.

* `Talagrand.convex_isoperimetry` — the isoperimetric reading of Talagrand's
  inequality: if `A` carries at least half of the mass then the complement of its
  `t`-neighbourhood *for the convex distance* has mass at most `2 exp (-t/4)`.
* `Talagrand.dTsq_cylinder` — the convex distance to a **subcube** (a cylinder set
  `{y | ∀ i ∈ B, y i = c i}`) is computed *exactly*: it is the number of
  coordinates of `B` on which `x` disagrees with the pattern `c`.  Together with
  `Talagrand.dTsq_singleton` (the case `B = univ`) this shows that the general
  bound is attained on a family of sets of arbitrary size, so the exponent in the
  isoperimetric bound cannot be improved by a change of the geometry alone.
* `Talagrand.cylinder_concentration` — the resulting explicit deviation bound for
  subcubes, in which the convex distance has been eliminated in favour of a
  coordinate count.
-/

namespace Talagrand

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α] {n : ℕ}

/-- **Isoperimetry for the convex distance.**  If `A` carries at least half of the
mass, the set of points at squared convex distance at least `t` from `A` has mass
at most `2 exp (-t/4)`. -/
theorem convex_isoperimetry {p : Fin n → α → ℝ} (hp0 : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1) (A S : Finset (Fin n → α)) (hA : 1 / 2 ≤ mass p A)
    {t : ℝ} (hS : ∀ x ∈ S, t ≤ dTsq A x) :
    mass p S ≤ 2 * Real.exp (-(t / 4)) := by
  have hmain := mass_mul_mass_le_exp hp0 hp1 A S hS
  have hS0 : 0 ≤ mass p S := mass_nonneg hp0 S
  nlinarith

/-- The cylinder (subcube) of points following the pattern `c` on the coordinates
of `B`. -/
def cylinder (B : Finset (Fin n)) (c : Fin n → α) : Finset (Fin n → α) :=
  Finset.univ.filter (fun y => ∀ i ∈ B, y i = c i)

lemma mem_cylinder {B : Finset (Fin n)} {c y : Fin n → α} :
    y ∈ cylinder B c ↔ ∀ i ∈ B, y i = c i := by
  simp [cylinder]

/-- The pattern itself, extended by the coordinates of `x`, lies in the cylinder. -/
lemma patch_mem_cylinder (B : Finset (Fin n)) (c x : Fin n → α) :
    (fun i => if i ∈ B then c i else x i) ∈ cylinder B c := by
  rw [mem_cylinder]
  intro i hi
  simp [hi]

/-- **The convex distance to a subcube, exactly.**  For the cylinder fixing the
coordinates of `B` to the pattern `c`, the squared convex distance from `x` is the
number of coordinates of `B` on which `x` disagrees with `c`. -/
theorem dTsq_cylinder (B : Finset (Fin n)) (c x : Fin n → α) :
    dTsq (cylinder B c) x = ((B.filter (fun i => x i ≠ c i)).card : ℝ) := by
  classical
  have hAne : (cylinder B c).Nonempty := ⟨_, patch_mem_cylinder B c x⟩
  refine le_antisymm ?_ ?_
  · -- the patched point realises the value
    have hrep : IsRep (cylinder B c) x (fun i => hamm (x i) (if i ∈ B then c i else x i)) := by
      refine ⟨1, fun _ => 1, fun _ => (fun i => if i ∈ B then c i else x i),
        fun _ => zero_le_one, by simp, fun _ => patch_mem_cylinder B c x, fun i => by simp⟩
    refine le_trans (dTsq_le_of_isRep hrep) (le_of_eq ?_)
    unfold sqn
    have hstep : ∀ i : Fin n, hamm (x i) (if i ∈ B then c i else x i) ^ 2
        = if i ∈ B.filter (fun i => x i ≠ c i) then (1:ℝ) else 0 := by
      intro i
      by_cases hi : i ∈ B
      · by_cases hxc : x i = c i
        · simp [hi, hamm, hxc]
        · simp [hi, hamm, hxc, Finset.mem_filter]
      · simp [hi, hamm, Finset.mem_filter]
    rw [Finset.sum_congr rfl fun i _ => hstep i, Finset.sum_ite_mem, Finset.univ_inter,
      Finset.sum_const, nsmul_eq_mul, mul_one]
  · -- every representation vector is `1` on the disagreeing coordinates of `B`
    obtain ⟨v0, hv0⟩ := exists_isRep hAne x
    refine le_csInf ⟨sqn v0, v0, hv0, rfl⟩ ?_
    rintro s ⟨v, hv, rfl⟩
    have hone : ∀ i ∈ B.filter (fun i => x i ≠ c i), v i = 1 := by
      intro i hi
      obtain ⟨hiB, hix⟩ := Finset.mem_filter.mp hi
      obtain ⟨k, w, y, hw0, hw1, hyA, hveq⟩ := hv
      rw [hveq i, ← hw1]
      refine Finset.sum_congr rfl fun j _ => ?_
      have hyc : y j i = c i := (mem_cylinder.mp (hyA j)) i hiB
      rw [hyc]
      simp [hamm, hix]
    calc ((B.filter (fun i => x i ≠ c i)).card : ℝ)
        = ∑ _i ∈ B.filter (fun i => x i ≠ c i), (1:ℝ) := by
          rw [Finset.sum_const, nsmul_eq_mul, mul_one]
      _ = ∑ i ∈ B.filter (fun i => x i ≠ c i), (v i) ^ 2 := by
          refine Finset.sum_congr rfl fun i hi => ?_
          rw [hone i hi]; norm_num
      _ ≤ ∑ i, (v i) ^ 2 := by
          exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
            fun i _ _ => sq_nonneg _
      _ = sqn v := rfl

/-- **Deviation bound for subcubes**, with the convex distance eliminated: if every
point of `S` disagrees with the pattern `c` on at least `t` coordinates of `B`,
then the subcube `cylinder B c` and `S` cannot both be large. -/
theorem cylinder_concentration {p : Fin n → α → ℝ} (hp0 : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1) (B : Finset (Fin n)) (c : Fin n → α)
    (S : Finset (Fin n → α)) {t : ℝ}
    (hS : ∀ x ∈ S, t ≤ ((B.filter (fun i => x i ≠ c i)).card : ℝ)) :
    mass p (cylinder B c) * mass p S ≤ Real.exp (-(t / 4)) := by
  refine mass_mul_mass_le_exp hp0 hp1 _ S fun x hx => ?_
  rw [dTsq_cylinder]
  exact hS x hx

end Talagrand