/-
# A Brouwerian counterexample: the exact IVT has no continuous solution operator

This file makes precise the sense in which the *exact* intermediate value theorem
fails constructively, while the approximate one (proved in
`Logic/ConstructiveAnalysis/ConstructiveIVT.lean`) holds.

We use Bishop's standard family of "shelf" functions

  `shelf t x = min (x - 1) (max t (x - 2))`,   `t ∈ [-1,1]`, `x ∈ [0,3]`.

Each `shelf t` is `1`-Lipschitz (so it has the explicit modulus of uniform
continuity `ω = id`), and satisfies `shelf t 0 ≤ 0 ≤ shelf t 3`, so the approximate
IVT applies to the whole family uniformly (`shelf_approx_root`).  Nevertheless:

* `shelf_root_of_mem_Ioo` : if `1 < x < 2` and `shelf t x = 0` then `t = 0`;
* `no_continuous_root_selector` : there is **no continuous** map `t ↦ r t` on
  `[-1,1]` with `shelf t (r t) = 0`.

Since every constructively (in particular, computably) defined map `ℝ → ℝ` is
continuous, this shows that no constructive proof of the exact IVT can exist: the
root cannot be obtained continuously — let alone computably — from the data.
The hypothesis that rescues the exact IVT in `constructive_ivt` is a positive lower
slope bound; `shelf_zero_slope_bound_nonpos` shows that this is precisely what the
family violates at `t = 0`, where `shelf 0` is constant on `[1,2]`.
-/

import Mathlib
import Logic.ConstructiveAnalysis.ConstructiveIVT

namespace Bishop

open Set

/-- Bishop's "shelf" family: a `1`-Lipschitz family of functions on `[0,3]` whose
root jumps from `1` to `2` as the parameter `t` crosses `0`. -/
noncomputable def shelf (t x : ℝ) : ℝ := min (x - 1) (max t (x - 2))

lemma shelf_lipschitz (t x y : ℝ) : |shelf t x - shelf t y| ≤ |x - y| := by
  have h1 : |shelf t x - shelf t y| ≤ max |(x - 1) - (y - 1)| |max t (x - 2) - max t (y - 2)| :=
    abs_min_sub_min_le_max _ _ _ _
  have h2 : |max t (x - 2) - max t (y - 2)| ≤ max |t - t| |(x - 2) - (y - 2)| :=
    abs_max_sub_max_le_max _ _ _ _
  have h3 : |(x - 1) - (y - 1)| = |x - y| := by ring_nf
  have h4 : |(x - 2) - (y - 2)| = |x - y| := by ring_nf
  have h5 : max |t - t| |(x - 2) - (y - 2)| = |x - y| := by
    simp
  rw [h3] at h1
  rw [h5] at h2
  exact h1.trans (max_le le_rfl h2)

/-- The identity is an explicit modulus of uniform continuity for every `shelf t`. -/
theorem shelf_hasModulus (t : ℝ) (s : Set ℝ) : HasModulusOn (shelf t) s id :=
  fun _ε hε => ⟨hε, fun x _ y _ h => (shelf_lipschitz t x y).trans h⟩

lemma shelf_left (t : ℝ) : shelf t 0 ≤ 0 := by
  have : shelf t 0 ≤ (0 : ℝ) - 1 := min_le_left _ _
  linarith

lemma shelf_right (t : ℝ) : 0 ≤ shelf t 3 := by
  have h1 : (0 : ℝ) ≤ (3 : ℝ) - 1 := by norm_num
  have h2 : (0 : ℝ) ≤ max t (3 - 2) := le_max_of_le_right (by norm_num)
  exact le_min h1 h2

/-- **The approximate IVT applies to the whole family, uniformly.**  For every
parameter `t` and every accuracy `ε > 0` there is an explicitly computed grid point
of `[0,3]` at which `|shelf t|` is at most `ε` (the mesh condition `3/N ≤ ε` uses the
modulus `ω = id` and does not depend on `t`). -/
theorem shelf_approx_root (t : ℝ) {ε : ℝ} (hε : 0 < ε)
    {N : ℕ} (hN : 0 < N) (hstep : (3 - 0 : ℝ) / N ≤ ε) :
    ∃ k ≤ N, |shelf t (grid 0 3 N k)| ≤ ε :=
  exists_grid_abs_le (by norm_num) (shelf_hasModulus t (Icc 0 3)) hε hN hstep
    (shelf_left t) (shelf_right t)

/-- A root strictly between `1` and `2` can only occur at the parameter `t = 0`. -/
theorem shelf_root_of_mem_Ioo {t x : ℝ} (h1 : 1 < x) (h2 : x < 2) (h : shelf t x = 0) :
    t = 0 := by
  simp only [shelf] at h
  rcases min_cases (x - 1) (max t (x - 2)) with ⟨he, _⟩ | ⟨he, _⟩ <;> rw [he] at h
  · linarith
  · rcases max_cases t (x - 2) with ⟨he2, _⟩ | ⟨he2, _⟩ <;> rw [he2] at h <;> linarith

/-- At the parameter `t = 1` the unique root is `x = 1`. -/
theorem shelf_one_root {x : ℝ} (h : shelf 1 x = 0) : x = 1 := by
  simp only [shelf] at h
  rcases min_cases (x - 1) (max 1 (x - 2)) with ⟨he, hle⟩ | ⟨he, hle⟩ <;> rw [he] at h
  · linarith
  · rcases max_cases (1 : ℝ) (x - 2) with ⟨he2, _⟩ | ⟨he2, _⟩ <;> rw [he2] at h <;> linarith

/-- At the parameter `t = -1` the unique root is `x = 2`. -/
theorem shelf_neg_one_root {x : ℝ} (h : shelf (-1) x = 0) : x = 2 := by
  simp only [shelf] at h
  rcases min_cases (x - 1) (max (-1 : ℝ) (x - 2)) with ⟨he, hle⟩ | ⟨he, hle⟩ <;> rw [he] at h
  · rcases max_cases (-1 : ℝ) (x - 2) with ⟨he2, hlt⟩ | ⟨he2, hlt⟩ <;>
      rw [he2] at hle <;> linarith
  · rcases max_cases (-1 : ℝ) (x - 2) with ⟨he2, _⟩ | ⟨he2, _⟩ <;> rw [he2] at h <;> linarith

/-- **Brouwerian counterexample to the exact intermediate value theorem.**

There is no continuous choice of a root for the family `shelf t`, `t ∈ [-1,1]`,
even though each member is `1`-Lipschitz and changes sign on `[0,3]`.  Hence no
constructive (computable) procedure can produce exact roots from these data. -/
theorem no_continuous_root_selector :
    ¬ ∃ r : ℝ → ℝ, ContinuousOn r (Icc (-1 : ℝ) 1) ∧
      ∀ t ∈ Icc (-1 : ℝ) 1, shelf t (r t) = 0 := by
  rintro ⟨r, hcont, hroot⟩
  have hm1 : (-1 : ℝ) ∈ Icc (-1 : ℝ) 1 := by norm_num
  have hp1 : (1 : ℝ) ∈ Icc (-1 : ℝ) 1 := by norm_num
  have hr1 : r 1 = 1 := shelf_one_root (hroot 1 hp1)
  have hrm1 : r (-1) = 2 := shelf_neg_one_root (hroot (-1) hm1)
  have hsub : Icc (r 1) (r (-1)) ⊆ r '' Icc (-1 : ℝ) 1 :=
    intermediate_value_Icc' (by norm_num) hcont
  rw [hr1, hrm1] at hsub
  obtain ⟨t₀, ht₀, hv₀⟩ := hsub (show (3 / 2 : ℝ) ∈ Icc (1 : ℝ) 2 by norm_num)
  obtain ⟨t₁, ht₁, hv₁⟩ := hsub (show (7 / 4 : ℝ) ∈ Icc (1 : ℝ) 2 by norm_num)
  have h0 : t₀ = 0 := by
    refine shelf_root_of_mem_Ioo (x := r t₀) ?_ ?_ (hroot t₀ ht₀)
    · rw [hv₀]; norm_num
    · rw [hv₀]; norm_num
  have h1 : t₁ = 0 := by
    refine shelf_root_of_mem_Ioo (x := r t₁) ?_ ?_ (hroot t₁ ht₁)
    · rw [hv₁]; norm_num
    · rw [hv₁]; norm_num
  rw [h0] at hv₀
  rw [h1] at hv₁
  rw [hv₀] at hv₁
  norm_num at hv₁

/-- The extra hypothesis that makes the exact IVT constructive — a positive lower
slope bound — is exactly what this family violates: `shelf 0` is constant on
`[1,2]`, so it admits no positive slope bound on `[0,3]`. -/
theorem shelf_zero_slope_bound_nonpos {c : ℝ}
    (h : HasSlopeBoundOn (shelf 0) (Icc (0 : ℝ) 3) c) : c ≤ 0 := by
  have h1 : (1 : ℝ) ∈ Icc (0 : ℝ) 3 := by norm_num
  have h2 : (2 : ℝ) ∈ Icc (0 : ℝ) 3 := by norm_num
  have hs1 : shelf 0 1 = 0 := by simp [shelf]
  have hs2 : shelf 0 2 = 0 := by
    simp only [shelf]
    norm_num
  have := h 1 h1 2 h2 (by norm_num)
  rw [hs1, hs2] at this
  linarith

/-- **Comparison with the classical theorem.**  Classically the family does have
roots for every parameter — the classical IVT applies to each `shelf t` — but by
`no_continuous_root_selector` no such assignment can be made continuously in `t`. -/
theorem shelf_classical_root (t : ℝ) :
    ∃ x ∈ Icc (0 : ℝ) 3, shelf t x = 0 :=
  exists_root (by norm_num) (shelf_hasModulus t (Icc 0 3)) (shelf_left t) (shelf_right t)

end Bishop