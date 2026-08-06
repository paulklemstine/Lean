/-
# Locating roots: what the grid search really delivers

`Bishop.exists_grid_abs_le` produces a grid point at which `|f|` is small.  Turning a
*small value* into a *small distance to a root* is the delicate step of the
intermediate value theorem, and `Bishop.constructive_ivt` does it with a global slope
bound `c > 0`, at the price of the factor `1/c`.

This file isolates the two sides of that step.

* `Bishop.exists_grid_near_root` : **the bracketing form of the search**.  With no
  non-degeneracy hypothesis whatsoever — only a modulus of uniform continuity and the
  sign condition `f a ≤ 0 ≤ f b` — the *sign-change* grid search returns a grid point
  within one mesh `(b-a)/N` of a genuine root.  The location comes from the bracket
  `f (grid k) ≤ 0 < f (grid (k+1))`, not from the size of `|f|`.

* `Bishop.local_nonconstancy_insufficient` : **a bound on `|f|` alone is not enough**,
  even under Bishop's local non-constancy hypothesis with an explicit modulus `ν`.
  The `1`-Lipschitz function `Bishop.dipFn η x = min (x-1) (|x-3| + η)` has the unique
  root `1`, satisfies local non-constancy with the explicit modulus `ν h = h/8`, and
  yet `|dipFn η 3| = η` is as small as one likes while `3` is at distance `2` from the
  root.  So no theorem of the form "`|f x|` small ⟹ `x` near a root" can be derived
  from local non-constancy alone.
-/

import Mathlib
import Logic.ConstructiveAnalysis.ConstructiveIVT

namespace Bishop

open Set

/-! ## 1. The bracketing form of the grid search -/

/-- **The sign-change grid search locates a genuine root, within one mesh.**

For a function with a modulus of uniform continuity on `[a,b]` and `f a ≤ 0 ≤ f b`,
the largest grid index `k` with `f (grid k) ≤ 0` satisfies: there is an exact root `r`
of `f` with `|grid k - r| ≤ (b-a)/N`.  No slope bound, and no other non-degeneracy
hypothesis, is needed — the accuracy of the *location* is the mesh itself. -/
theorem exists_grid_near_root {f : ℝ → ℝ} {a b : ℝ} {ω : ℝ → ℝ} {N : ℕ}
    (hab : a ≤ b) (hω : HasModulusOn f (Icc a b) ω) (hN : 0 < N)
    (hfa : f a ≤ 0) (hfb : 0 ≤ f b) :
    ∃ k ≤ N, ∃ r ∈ Icc a b, f r = 0 ∧ |grid a b N k - r| ≤ (b - a) / N := by
  classical
  have hN' : (0 : ℝ) < N := by exact_mod_cast hN
  have hmesh : 0 ≤ (b - a) / N := div_nonneg (by linarith) hN'.le
  set S : Finset ℕ := (Finset.range (N + 1)).filter (fun k => f (grid a b N k) ≤ 0) with hS
  have h0 : 0 ∈ S := by simp [hS, grid_zero, hfa]
  have hne : S.Nonempty := ⟨0, h0⟩
  set k := S.max' hne with hk
  have hkS : k ∈ S := S.max'_mem hne
  have hkrange : k ≤ N :=
    Nat.lt_succ_iff.mp (Finset.mem_range.mp (Finset.mem_filter.mp hkS).1)
  have hfk : f (grid a b N k) ≤ 0 := (Finset.mem_filter.mp hkS).2
  refine ⟨k, hkrange, ?_⟩
  rcases eq_or_lt_of_le hkrange with hkN | hkN
  · -- the search reached the right endpoint, where `f` vanishes
    have hgb : grid a b N k = b := by rw [hkN, grid_last hN]
    refine ⟨b, ⟨hab, le_rfl⟩, ?_, ?_⟩
    · rw [hgb] at hfk
      exact le_antisymm hfk hfb
    · rw [hgb, sub_self, abs_zero]
      exact hmesh
  · -- otherwise the next grid point brackets a root
    have hk1 : k + 1 ≤ N := hkN
    have hnot : (k + 1) ∉ S := by
      intro hmem
      have := S.le_max' _ hmem
      omega
    have hpos : 0 < f (grid a b N (k + 1)) := by
      by_contra h
      exact hnot (Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (by omega), not_lt.mp h⟩)
    have hmem1 : grid a b N k ∈ Icc a b := grid_mem_Icc hab hN hkrange
    have hmem2 : grid a b N (k + 1) ∈ Icc a b := grid_mem_Icc hab hN hk1
    have hsucc : grid a b N (k + 1) - grid a b N k = (b - a) / N := grid_succ_sub
    have hle : grid a b N k ≤ grid a b N (k + 1) := by linarith
    have hsubset : Icc (grid a b N k) (grid a b N (k + 1)) ⊆ Icc a b :=
      Icc_subset_Icc hmem1.1 hmem2.2
    have hcont : ContinuousOn f (Icc (grid a b N k) (grid a b N (k + 1))) :=
      hω.continuousOn.mono hsubset
    have h0mem : (0 : ℝ) ∈ Icc (f (grid a b N k)) (f (grid a b N (k + 1))) :=
      ⟨hfk, hpos.le⟩
    obtain ⟨r, hr, hfr⟩ := intermediate_value_Icc hle hcont h0mem
    refine ⟨r, hsubset hr, hfr, ?_⟩
    rw [abs_of_nonpos (by linarith [hr.1])]
    linarith [hr.2]

/-! ## 2. Local non-constancy does not locate approximate roots

Bishop's exact intermediate value theorem replaces a slope bound by *local
non-constancy*.  The following explicit function shows that this hypothesis, even
with an explicit modulus `ν`, does not let one conclude that a point with small
`|f|` is close to a root. -/

/-- A `1`-Lipschitz function on `[0,4]` with the single root `1` and a "near root" of
depth `η` at `x = 3`. -/
noncomputable def dipFn (η x : ℝ) : ℝ := min (x - 1) (|x - 3| + η)

lemma dipFn_lipschitz (η x y : ℝ) : |dipFn η x - dipFn η y| ≤ |x - y| := by
  have h1 : |dipFn η x - dipFn η y|
      ≤ max |(x - 1) - (y - 1)| |(|x - 3| + η) - (|y - 3| + η)| :=
    abs_min_sub_min_le_max _ _ _ _
  have h2 : |(x - 1) - (y - 1)| = |x - y| := by ring_nf
  have h3 : (|x - 3| + η) - (|y - 3| + η) = |x - 3| - |y - 3| := by ring
  have h4 : |(|x - 3| + η) - (|y - 3| + η)| ≤ |x - y| := by
    rw [h3]
    have hbd := abs_abs_sub_abs_le_abs_sub (x - 3) (y - 3)
    have he : (x - 3) - (y - 3) = x - y := by ring
    rw [he] at hbd
    exact hbd
  rw [h2] at h1
  exact h1.trans (max_le le_rfl h4)

/-- The identity is an explicit modulus of uniform continuity for `dipFn η`. -/
theorem dipFn_hasModulus (η : ℝ) (s : Set ℝ) : HasModulusOn (dipFn η) s id :=
  fun _ε hε => ⟨hε, fun x _ y _ h => (dipFn_lipschitz η x y).trans h⟩

lemma dipFn_zero_le (η : ℝ) : dipFn η 0 ≤ 0 := by
  have : dipFn η 0 ≤ (0 : ℝ) - 1 := min_le_left _ _
  linarith

lemma dipFn_four_nonneg (η : ℝ) (hη : 0 < η) : 0 ≤ dipFn η 4 := by
  have h1 : (0 : ℝ) ≤ (4 : ℝ) - 1 := by norm_num
  have h2 : (0 : ℝ) ≤ |(4 : ℝ) - 3| + η := by positivity
  exact le_min h1 h2

/-- The only root of `dipFn η` is `x = 1`. -/
theorem dipFn_root_unique {η r : ℝ} (hη : 0 < η) (h : dipFn η r = 0) : r = 1 := by
  have habs : 0 ≤ |r - 3| := abs_nonneg _
  simp only [dipFn] at h
  rcases min_cases (r - 1) (|r - 3| + η) with ⟨he, _⟩ | ⟨he, _⟩ <;> rw [he] at h <;> linarith

/-- Away from the two critical points `1` and `3`, the value of `dipFn η` is large. -/
theorem dipFn_abs_ge {η h z : ℝ} (hη : 0 < η) (h1 : h / 8 ≤ |z - 1|)
    (h3 : h / 8 ≤ |z - 3|) : h / 8 ≤ |dipFn η z| := by
  rcases le_total 1 z with hz | hz
  · have e1 : h / 8 ≤ z - 1 := by rwa [abs_of_nonneg (by linarith)] at h1
    have e2 : h / 8 ≤ |z - 3| + η := by linarith
    have : h / 8 ≤ dipFn η z := le_min e1 e2
    calc h / 8 ≤ dipFn η z := this
      _ ≤ |dipFn η z| := le_abs_self _
  · have e1 : h / 8 ≤ 1 - z := by
      rw [abs_of_nonpos (by linarith)] at h1; linarith
    have hle : dipFn η z ≤ z - 1 := min_le_left _ _
    have : dipFn η z ≤ -(h / 8) := by linarith
    calc h / 8 = -(-(h / 8)) := by ring
      _ ≤ -dipFn η z := by linarith
      _ ≤ |dipFn η z| := neg_le_abs _

/-- In any interval of length at least `h` there is a point at distance at least
`h/8` from both critical points `1` and `3`. -/
theorem exists_far_from_critical {x y h : ℝ} (hh : 0 < h) (hxy : x + h ≤ y) :
    ∃ z ∈ Icc x y, h / 8 ≤ |z - 1| ∧ h / 8 ≤ |z - 3| := by
  by_contra hcon
  push_neg at hcon
  have hp0 : |x - 1| < h / 8 ∨ |x - 3| < h / 8 := by
    by_cases hb : h / 8 ≤ |x - 1|
    · exact Or.inr (hcon x ⟨le_rfl, by linarith⟩ hb)
    · exact Or.inl (not_le.mp hb)
  have hp1 : |x + h / 3 - 1| < h / 8 ∨ |x + h / 3 - 3| < h / 8 := by
    have hmem : x + h / 3 ∈ Icc x y := ⟨by linarith, by linarith⟩
    by_cases hb : h / 8 ≤ |x + h / 3 - 1|
    · exact Or.inr (hcon _ hmem hb)
    · exact Or.inl (not_le.mp hb)
  have hp2 : |x + 2 * h / 3 - 1| < h / 8 ∨ |x + 2 * h / 3 - 3| < h / 8 := by
    have hmem : x + 2 * h / 3 ∈ Icc x y := ⟨by linarith, by linarith⟩
    by_cases hb : h / 8 ≤ |x + 2 * h / 3 - 1|
    · exact Or.inr (hcon _ hmem hb)
    · exact Or.inl (not_le.mp hb)
  rcases hp0 with h0 | h0 <;> rcases hp1 with h1 | h1 <;> rcases hp2 with h2 | h2 <;>
    · rw [abs_lt] at h0 h1 h2
      linarith [h0.1, h0.2, h1.1, h1.2, h2.1, h2.2]

/-- **Local non-constancy does not locate approximate roots.**

For every accuracy `δ ∈ (0,2)` there is a `1`-Lipschitz function on `[0,4]` with
`f 0 ≤ 0 ≤ f 4`, satisfying Bishop's local non-constancy condition with the explicit
modulus `ν h = h/8` — on every interval of length at least `h` the function takes a
value of absolute value at least `ν h` — and a point `x` with `|f x| ≤ ν δ / 2` whose
distance to *every* root of `f` exceeds `δ`.  So the passage from "`|f x|` is small"
to "`x` is near a root", which `Bishop.constructive_ivt` performs using a slope bound,
cannot be performed under local non-constancy alone. -/
theorem local_nonconstancy_insufficient {δ : ℝ} (hδ0 : 0 < δ) (hδ2 : δ < 2) :
    ∃ (f : ℝ → ℝ) (ν : ℝ → ℝ) (x : ℝ),
      HasModulusOn f (Icc (0 : ℝ) 4) id ∧ f 0 ≤ 0 ∧ 0 ≤ f 4 ∧
        (∀ h > 0, 0 < ν h) ∧
        (∀ h > 0, ∀ p q : ℝ, p + h ≤ q → ∃ z ∈ Icc p q, ν h ≤ |f z|) ∧
        x ∈ Icc (0 : ℝ) 4 ∧ |f x| ≤ ν δ / 2 ∧ ∀ r : ℝ, f r = 0 → δ < |x - r| := by
  have hη : 0 < δ / 32 := by linarith
  refine ⟨dipFn (δ / 32), fun h => h / 8, 3, dipFn_hasModulus _ _,
    dipFn_zero_le _, dipFn_four_nonneg _ hη, fun h hh => by linarith, ?_,
    ⟨by norm_num, by norm_num⟩, ?_, ?_⟩
  · intro h hh p q hpq
    obtain ⟨z, hz, h1, h3⟩ := exists_far_from_critical hh hpq
    exact ⟨z, hz, dipFn_abs_ge hη h1 h3⟩
  · have h3 : dipFn (δ / 32) 3 = δ / 32 := by
      simp only [dipFn]
      rw [show (3 : ℝ) - 3 = 0 by ring, abs_zero, zero_add]
      exact min_eq_right (by linarith)
    rw [h3, abs_of_pos hη]
    linarith
  · intro r hr
    rw [dipFn_root_unique hη hr]
    rw [show |(3 : ℝ) - 1| = 2 by rw [show (3 : ℝ) - 1 = 2 by ring]; exact abs_of_pos (by norm_num)]
    exact hδ2

end Bishop