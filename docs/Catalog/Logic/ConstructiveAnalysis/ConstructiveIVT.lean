/-
# The constructive intermediate value theorem, with explicit modulus

In Bishop's constructive analysis the classical intermediate value theorem is not
available: from `f a ≤ 0 ≤ f b` one cannot compute a point where `f` vanishes
(see `Logic/ConstructiveAnalysis/BrouwerianCounterexamples.lean`).  What *is*
constructively valid, and what Bishop proves, are:

1. the **approximate intermediate value theorem**: for every `ε > 0` one can
   *compute* a point `x ∈ [a,b]` with `|f x| ≤ ε`, provided `f` comes with a
   modulus of uniform continuity `ω`;
2. the **exact intermediate value theorem** for functions that are, in an explicit
   quantitative sense, non-constant (here: with a positive lower slope bound `c`),
   together with an explicit modulus for the root.

Both are proved below.  The approximate root is produced by an entirely explicit
finite search on the grid `a + k(b-a)/N`, `0 ≤ k ≤ N`, where `N` is any integer with
`(b-a)/N ≤ ω ε`; the witness is the *largest* grid index at which `f` is `≤ 0`.

The final theorem `exists_reg_root` presents the root of such a function as a
Bishop real (a regular sequence of rationals) whose rational approximations are
explicitly grid points of the above finite search.
-/

import Mathlib
import Logic.ConstructiveAnalysis.BishopReals

namespace Bishop

open Set

/-- `ω` is a **modulus of uniform continuity** for `f` on `s`: an explicit map from
accuracies to accuracies, as required in Bishop's definition of a continuous
function on a compact interval. -/
def HasModulusOn (f : ℝ → ℝ) (s : Set ℝ) (ω : ℝ → ℝ) : Prop :=
  ∀ ε > 0, 0 < ω ε ∧ ∀ x ∈ s, ∀ y ∈ s, |x - y| ≤ ω ε → |f x - f y| ≤ ε

/-- A function with a modulus of uniform continuity is (classically) continuous. -/
theorem HasModulusOn.continuousOn {f : ℝ → ℝ} {s : Set ℝ} {ω : ℝ → ℝ}
    (hω : HasModulusOn f s ω) : ContinuousOn f s := by
  rw [Metric.continuousOn_iff]
  intro x hx ε hε
  obtain ⟨hpos, hmod⟩ := hω (ε / 2) (by linarith)
  refine ⟨ω (ε / 2), hpos, fun y hy hdist => ?_⟩
  have h1 : |x - y| ≤ ω (ε / 2) := by
    rw [abs_sub_comm]
    exact le_of_lt (by simpa [Real.dist_eq] using hdist)
  have := hmod x hx y hy h1
  have : |f y - f x| ≤ ε / 2 := by rw [abs_sub_comm]; exact this
  rw [Real.dist_eq]
  linarith

/-- The `k`-th point of the uniform grid of `N` subintervals of `[a,b]`. -/
noncomputable def grid (a b : ℝ) (N k : ℕ) : ℝ := a + k * (b - a) / N

lemma grid_zero (a b : ℝ) (N : ℕ) : grid a b N 0 = a := by simp [grid]

lemma grid_last {a b : ℝ} {N : ℕ} (hN : 0 < N) : grid a b N N = b := by
  have hN' : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  simp only [grid]
  field_simp
  ring

lemma grid_mem_Icc {a b : ℝ} {N k : ℕ} (hab : a ≤ b) (hN : 0 < N) (hk : k ≤ N) :
    grid a b N k ∈ Icc a b := by
  have hN' : (0 : ℝ) < N := by exact_mod_cast hN
  have hk' : (k : ℝ) ≤ N := by exact_mod_cast hk
  have hba : (0 : ℝ) ≤ b - a := by linarith
  constructor
  · have : 0 ≤ (k : ℝ) * (b - a) / N := by positivity
    simp only [grid]; linarith
  · have h : (k : ℝ) * (b - a) / N ≤ b - a := by
      rw [div_le_iff₀ hN']
      nlinarith
    simp only [grid]; linarith

lemma grid_succ_sub {a b : ℝ} {N k : ℕ} :
    grid a b N (k + 1) - grid a b N k = (b - a) / N := by
  simp only [grid]
  push_cast
  ring

/-- **Approximate intermediate value theorem with explicit modulus.**

If `f` has modulus of uniform continuity `ω` on `[a,b]`, if `f a ≤ 0 ≤ f b`, and if
`N ≥ 1` is chosen so that the mesh `(b-a)/N` is at most `ω ε`, then one of the `N+1`
grid points `a + k(b-a)/N` satisfies `|f| ≤ ε`.  The search is finite and explicit:
take the largest `k` with `f (grid k) ≤ 0`. -/
theorem exists_grid_abs_le {f : ℝ → ℝ} {a b : ℝ} {ω : ℝ → ℝ} {ε : ℝ} {N : ℕ}
    (hab : a ≤ b) (hω : HasModulusOn f (Icc a b) ω) (hε : 0 < ε)
    (hN : 0 < N) (hstep : (b - a) / N ≤ ω ε)
    (hfa : f a ≤ 0) (hfb : 0 ≤ f b) :
    ∃ k ≤ N, |f (grid a b N k)| ≤ ε := by
  classical
  set S : Finset ℕ := (Finset.range (N + 1)).filter (fun k => f (grid a b N k) ≤ 0) with hS
  have h0 : 0 ∈ S := by
    simp [hS, grid_zero, hfa]
  have hne : S.Nonempty := ⟨0, h0⟩
  set k := S.max' hne with hk
  have hkS : k ∈ S := S.max'_mem hne
  have hkrange : k ≤ N := by
    have := (Finset.mem_filter.mp hkS).1
    exact Nat.lt_succ_iff.mp (Finset.mem_range.mp this)
  have hfk : f (grid a b N k) ≤ 0 := (Finset.mem_filter.mp hkS).2
  refine ⟨k, hkrange, ?_⟩
  rcases eq_or_lt_of_le hkrange with hkN | hkN
  · -- the search reached the right endpoint: there `f` vanishes
    have : f (grid a b N k) = f b := by rw [hkN, grid_last hN]
    rw [this] at hfk ⊢
    have : f b = 0 := le_antisymm hfk hfb
    rw [this]
    simpa using hε.le
  · -- otherwise the next grid point has `f > 0`, and the mesh bound applies
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
    have hdist : |grid a b N k - grid a b N (k + 1)| ≤ ω ε := by
      have h1 : grid a b N k - grid a b N (k + 1) = -((b - a) / N) := by
        have := grid_succ_sub (a := a) (b := b) (N := N) (k := k)
        linarith
      have hN' : (0 : ℝ) < N := by exact_mod_cast hN
      have hnn : 0 ≤ (b - a) / N := by
        apply div_nonneg (by linarith) hN'.le
      rw [h1, abs_neg, abs_of_nonneg hnn]
      exact hstep
    have hmod := (hω ε hε).2 _ hmem1 _ hmem2 hdist
    have hdiff : f (grid a b N (k + 1)) - f (grid a b N k) ≤ ε := by
      have := abs_le.mp hmod
      linarith [this.1]
    rw [abs_of_nonpos hfk]
    linarith

/-- **Approximate intermediate value theorem, existential form.**  For a function
with a modulus of uniform continuity on `[a,b]` and `f a ≤ 0 ≤ f b`, every accuracy
`ε > 0` is met by some point of `[a,b]`. -/
theorem exists_abs_le_of_modulus {f : ℝ → ℝ} {a b : ℝ} {ω : ℝ → ℝ} {ε : ℝ}
    (hab : a ≤ b) (hω : HasModulusOn f (Icc a b) ω) (hε : 0 < ε)
    (hfa : f a ≤ 0) (hfb : 0 ≤ f b) :
    ∃ x ∈ Icc a b, |f x| ≤ ε := by
  obtain ⟨N, hN⟩ := exists_nat_gt ((b - a) / ω ε)
  have hωpos : 0 < ω ε := (hω ε hε).1
  have hNpos : 0 < N := by
    by_contra h
    push_neg at h
    interval_cases N
    · have : (0 : ℝ) ≤ (b - a) / ω ε := div_nonneg (by linarith) hωpos.le
      simp at hN
      linarith
  have hN' : (0 : ℝ) < N := by exact_mod_cast hNpos
  have hstep : (b - a) / N ≤ ω ε := by
    rw [div_le_iff₀ hN']
    have := (div_lt_iff₀ hωpos).mp hN
    linarith
  obtain ⟨k, hk, hfk⟩ := exists_grid_abs_le hab hω hε hNpos hstep hfa hfb
  exact ⟨grid a b N k, grid_mem_Icc hab hNpos hk, hfk⟩

/-! ## Exact roots under an explicit non-degeneracy assumption -/

/-- `f` increases at rate at least `c` on `s`: an explicit quantitative form of
"`f` is nowhere locally constant", which is what makes the *exact* intermediate
value theorem constructive. -/
def HasSlopeBoundOn (f : ℝ → ℝ) (s : Set ℝ) (c : ℝ) : Prop :=
  ∀ x ∈ s, ∀ y ∈ s, x ≤ y → c * (y - x) ≤ f y - f x

/-- **Explicit modulus for the root.**  If `f` has slope bound `c > 0` on `[a,b]`,
`r` is a root, and `|f x| ≤ ε`, then `x` is within `ε / c` of `r`. -/
theorem abs_sub_root_le {f : ℝ → ℝ} {a b c ε : ℝ} (hc : 0 < c)
    (hslope : HasSlopeBoundOn f (Icc a b) c)
    {r x : ℝ} (hr : r ∈ Icc a b) (hfr : f r = 0) (hx : x ∈ Icc a b) (hfx : |f x| ≤ ε) :
    |x - r| ≤ ε / c := by
  have hb := abs_le.mp hfx
  rcases le_total r x with h | h
  · have := hslope r hr x hx h
    rw [hfr] at this
    have : c * (x - r) ≤ ε := by linarith [hb.2]
    rw [abs_of_nonneg (by linarith), le_div_iff₀ hc]
    linarith
  · have := hslope x hx r hr h
    rw [hfr] at this
    have : c * (r - x) ≤ ε := by linarith [hb.1]
    rw [abs_of_nonpos (by linarith), le_div_iff₀ hc]
    linarith

/-- Under a positive slope bound the root is unique. -/
theorem root_unique {f : ℝ → ℝ} {a b c : ℝ} (hc : 0 < c)
    (hslope : HasSlopeBoundOn f (Icc a b) c)
    {r r' : ℝ} (hr : r ∈ Icc a b) (hfr : f r = 0) (hr' : r' ∈ Icc a b) (hfr' : f r' = 0) :
    r = r' := by
  have h := abs_sub_root_le hc hslope hr hfr hr' (ε := 0) (le_of_eq (by rw [hfr', abs_zero]))
  have : |r' - r| ≤ 0 := by simpa using h
  have := abs_eq_zero.mp (le_antisymm this (abs_nonneg _))
  linarith

/-- Existence of an exact root for a function given by a modulus of continuity with
`f a ≤ 0 ≤ f b`. -/
theorem exists_root {f : ℝ → ℝ} {a b : ℝ} {ω : ℝ → ℝ} (hab : a ≤ b)
    (hω : HasModulusOn f (Icc a b) ω) (hfa : f a ≤ 0) (hfb : 0 ≤ f b) :
    ∃ r ∈ Icc a b, f r = 0 := by
  have hcont : ContinuousOn f (Icc a b) := hω.continuousOn
  have h0 : (0 : ℝ) ∈ Icc (f a) (f b) := ⟨hfa, hfb⟩
  obtain ⟨r, hr, hfr⟩ := intermediate_value_Icc hab hcont h0
  exact ⟨r, hr, hfr⟩

/-- **Constructive intermediate value theorem with explicit modulus.**

For a function with modulus of uniform continuity `ω` and slope bound `c > 0` on
`[a,b]`, with `f a ≤ 0 ≤ f b`, there is a (unique) root `r`, and for every desired
accuracy `δ > 0` an explicitly computed grid point of mesh `≤ ω (c * δ)` lies within
`δ` of `r`.  The modulus of the root as a function of the desired accuracy is thus
`δ ↦ ω (c * δ)`. -/
theorem constructive_ivt {f : ℝ → ℝ} {a b c : ℝ} {ω : ℝ → ℝ} (hab : a ≤ b) (hc : 0 < c)
    (hω : HasModulusOn f (Icc a b) ω) (hslope : HasSlopeBoundOn f (Icc a b) c)
    (hfa : f a ≤ 0) (hfb : 0 ≤ f b) :
    ∃ r ∈ Icc a b, f r = 0 ∧
      ∀ δ > 0, ∀ N : ℕ, 0 < N → (b - a) / N ≤ ω (c * δ) →
        ∃ k ≤ N, |grid a b N k - r| ≤ δ := by
  obtain ⟨r, hr, hfr⟩ := exists_root hab hω hfa hfb
  refine ⟨r, hr, hfr, ?_⟩
  intro δ hδ N hN hstep
  obtain ⟨k, hk, hfk⟩ := exists_grid_abs_le hab hω (by positivity) hN hstep hfa hfb
  refine ⟨k, hk, ?_⟩
  have := abs_sub_root_le hc hslope hr hfr (grid_mem_Icc hab hN hk) hfk
  calc |grid a b N k - r| ≤ c * δ / c := this
    _ = δ := by field_simp

/-! ## The root as a Bishop real

Finally we present the root itself as a Bishop real: a regular sequence of
*rationals*, each term of which is one of the explicitly searched grid points. -/

/-- The rational grid point, whose image in `ℝ` is `grid a b N k`. -/
def gridQ (a b : ℚ) (N k : ℕ) : ℚ := a + k * (b - a) / N

lemma gridQ_cast (a b : ℚ) (N k : ℕ) :
    ((gridQ a b N k : ℚ) : ℝ) = grid (a : ℝ) (b : ℝ) N k := by
  simp only [gridQ, grid]
  push_cast
  ring

/-- **The root of a constructively presented function is a Bishop real.**

Given rational endpoints, a modulus of uniform continuity, and a positive slope
bound, the unique root of `f` on `[a,b]` is the limit of a regular sequence of
rationals, each term of which is an explicitly computed grid point. -/
theorem exists_reg_root {f : ℝ → ℝ} {a b : ℚ} {c : ℝ} {ω : ℝ → ℝ}
    (hab : a ≤ b) (hc : 0 < c)
    (hω : HasModulusOn f (Icc (a : ℝ) b) ω) (hslope : HasSlopeBoundOn f (Icc (a : ℝ) b) c)
    (hfa : f a ≤ 0) (hfb : 0 ≤ f b) :
    ∃ x : Reg, f x.toReal = 0 ∧ x.toReal ∈ Icc (a : ℝ) b ∧
      ∀ n : ℕ, ∃ N k : ℕ, 0 < N ∧ k ≤ N ∧ x.approx n = gridQ a b N k := by
  have hab' : (a : ℝ) ≤ b := by exact_mod_cast hab
  obtain ⟨r, hr, hfr, hgrid⟩ := constructive_ivt hab' hc hω hslope hfa hfb
  -- for each `n` choose a grid point within `1/(2(n+1))` of the root
  have hchoice : ∀ n : ℕ, ∃ p : ℕ × ℕ, 0 < p.1 ∧ p.2 ≤ p.1 ∧
      |((gridQ a b p.1 p.2 : ℚ) : ℝ) - r| ≤ 1 / (2 * (n + 1)) := by
    intro n
    set δ : ℝ := 1 / (2 * ((n : ℝ) + 1)) with hδdef
    have hδ : 0 < δ := by positivity
    have hωpos : 0 < ω (c * δ) := (hω (c * δ) (by positivity)).1
    obtain ⟨N, hNgt⟩ := exists_nat_gt (((b : ℝ) - a) / ω (c * δ))
    have hNpos : 0 < N := by
      by_contra h
      push_neg at h
      interval_cases N
      · have : (0 : ℝ) ≤ ((b : ℝ) - a) / ω (c * δ) := div_nonneg (by linarith) hωpos.le
        simp at hNgt
        linarith
    have hN' : (0 : ℝ) < N := by exact_mod_cast hNpos
    have hstep : ((b : ℝ) - a) / N ≤ ω (c * δ) := by
      rw [div_le_iff₀ hN']
      have := (div_lt_iff₀ hωpos).mp hNgt
      linarith
    obtain ⟨k, hk, hkr⟩ := hgrid δ hδ N hNpos hstep
    exact ⟨(N, k), hNpos, hk, by rw [gridQ_cast]; exact hkr⟩
  choose p hp using hchoice
  set q : ℕ → ℚ := fun n => gridQ a b (p n).1 (p n).2 with hq
  have hqr : ∀ n : ℕ, |((q n : ℚ) : ℝ) - r| ≤ 1 / (2 * (n + 1)) := fun n => (hp n).2.2
  have hreg : ∀ m n : ℕ, |q m - q n| ≤ 1 / (m + 1) + 1 / (n + 1) := by
    intro m n
    have hR : |((q m : ℚ) : ℝ) - ((q n : ℚ) : ℝ)| ≤ 1 / (m + 1) + 1 / (n + 1) := by
      have h1 : |((q m : ℚ) : ℝ) - ((q n : ℚ) : ℝ)|
          ≤ |((q m : ℚ) : ℝ) - r| + |r - ((q n : ℚ) : ℝ)| := abs_sub_le _ _ _
      have h2 := hqr m
      have h3 : |r - ((q n : ℚ) : ℝ)| ≤ 1 / (2 * (n + 1)) := by
        rw [abs_sub_comm]; exact hqr n
      have h4 : (1 : ℝ) / (2 * (m + 1)) ≤ 1 / (m + 1) := by
        have : (0 : ℝ) ≤ (m : ℝ) := Nat.cast_nonneg m
        exact one_div_le_one_div_of_le (by positivity) (by linarith)
      have h5 : (1 : ℝ) / (2 * (n + 1)) ≤ 1 / (n + 1) := by
        have : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
        exact one_div_le_one_div_of_le (by positivity) (by linarith)
      linarith
    have h' : ((|q m - q n| : ℚ) : ℝ) ≤ (((1 : ℚ) / (m + 1) + 1 / (n + 1) : ℚ) : ℝ) := by
      push_cast
      simpa using hR
    exact_mod_cast h'
  have hx : (⟨q, hreg⟩ : Reg).toReal = r := by
    refine Reg.toReal_eq_of_approx_le _ r 1 (fun n => ?_)
    have h2 := hqr n
    have h3 : (1 : ℝ) / (2 * (n + 1)) ≤ 1 * (1 / ((n : ℝ) + 1)) := by
      have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
      have : (1 : ℝ) / (2 * (n + 1)) ≤ 1 / ((n : ℝ) + 1) :=
        one_div_le_one_div_of_le (by positivity) (by linarith)
      linarith
    have happ : (⟨q, hreg⟩ : Reg).approx n = q n := rfl
    rw [happ]
    linarith
  refine ⟨⟨q, hreg⟩, ?_, ?_, ?_⟩
  · rw [hx]; exact hfr
  · rw [hx]; exact hr
  · intro n
    exact ⟨(p n).1, (p n).2, (hp n).1, (hp n).2.1, rfl⟩

end Bishop