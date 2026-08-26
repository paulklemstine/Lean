/-
# Window saturation, the matched filter, and the interior-argmax certificate

## Motivation (round-83 / exp 587, "B\*-transfer")

An empirical instrument used in the lab has the following shape.  A response
`y ∈ ℝⁿ` (one number per sampled modulus `N`) is regressed on a *window
statistic*

  `S_{w,B} = ∑_{ℓ ≤ B} w(ℓ) · v_ℓ`,

a weighted sum of per-prime indicator columns `v_ℓ ∈ ℝⁿ`.  One then records the
simple-regression coefficient of determination `R²(w, B)` as the window `B`
grows along a factor-`2` grid, and reads off the location `B*` of the maximum.
Empirically the curve rises, peaks at an *interior* grid point, and then falls
back — "saturation at `B* = 400`" — and the peak is *weight dependent*: the
`ℓ^{-1/2}` weight produces a clean interior maximum while the harmonic weight
`ℓ^{-1}` produces a flat plateau with an edge maximum.

This file isolates and proves the exact mathematics underlying that phenomenon,
for an *orthogonal-increment* model of the columns.  The results are:

* `Model.R2_eq_Rsq`, `rss_decomposition` — the window statistic really
  is being scored by the ordinary least-squares `R²` (the residual-sum-of-squares
  identity, which simultaneously proves `0 ≤ R² ≤ 1` and OLS optimality).
* `Model.noise_dilutes` — appending a column that is *orthogonal to the response*
  strictly **decreases** `R²`.  Saturation is not asymptotic flattening; it is
  strict dilution.
* `Model.matched_step_increases` — appending a column whose weighted slope is at
  least the running slope strictly **increases** `R²`.
* `Model.unique_interior_argmax` — in a *matched-signal-then-noise* window, the
  curve `B ↦ R²(w,B)` is strictly increasing up to `t` and strictly decreasing
  after `t`; hence the argmax set is exactly `{t}`, an interior maximum.
* `Model.R2_le_matched` — the **matched filter** `w(ℓ) = a_ℓ / s_ℓ` dominates every
  other weight *at every window simultaneously* ("plateau raised everywhere").
* `Model.matched_curve_monotone` — the matched-filter curve is monotone in `B`:
  it never has an interior maximum.
* `Model.R2_le_global`, `Model.R2_global_attained` — a global cap on the whole
  instrument: no weight and no window score above `E m / ‖y‖²`, and the matched
  filter at the full window attains it.
* `Model.interior_argmax_certifies_mismatch` — consequently, an interior maximum
  of the observed curve is a **certificate that the weight is not matched**.  A
  weight with an interior `B*` is provably suboptimal at the far window.
* `argmax_stable_of_margin` / `argmax_flip_of_small_margin` — the bootstrap
  caveat, made exact: the observed argmax is stable under perturbations smaller
  than half the top-two margin, and can be flipped by perturbations of the size
  of that margin.
* `saturationExample` — an explicit `4`-column model realising the whole
  phenomenon with computed curve `0, 1/2, 1, 2/3, 1/2` (non-vacuity check).

Everything is proved from scratch over `Mathlib`; no `sorry`.
-/
import Mathlib

open Finset

namespace WindowSaturation

/-! ## The sample space and its dot product -/

variable {n : ℕ}

/-- The Euclidean dot product on the sample space `Fin n → ℝ`. -/
def dot (u v : Fin n → ℝ) : ℝ := ∑ j, u j * v j

lemma dot_comm (u v : Fin n → ℝ) : dot u v = dot v u := by
  simp [dot, mul_comm]

lemma dot_self_nonneg (u : Fin n → ℝ) : 0 ≤ dot u u :=
  Finset.sum_nonneg fun _ _ => mul_self_nonneg _

/-- Expansion of the residual sum of squares of the fit `y ≈ b · x`. -/
lemma residual_identity (x y : Fin n → ℝ) (b : ℝ) :
    dot (fun j => y j - b * x j) (fun j => y j - b * x j)
      = dot y y - 2 * b * dot x y + b ^ 2 * dot x x := by
  have h : ∀ j : Fin n, (y j - b * x j) * (y j - b * x j)
      = y j * y j - 2 * b * (x j * y j) + b ^ 2 * (x j * x j) := by intro j; ring
  simp only [dot, h, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum]

/-- The coefficient of determination of the simple regression of `y` on `x`
(equivalently, the squared cosine between `x` and `y`). -/
noncomputable def Rsq (x y : Fin n → ℝ) : ℝ := (dot x y) ^ 2 / (dot x x * dot y y)

/-- **Residual decomposition.**  For every slope `b`, the residual sum of squares
splits into the irreducible part `‖y‖²(1 - R²)` and the squared distance of `b`
from the OLS slope.  This one identity contains both the interpretation of `Rsq`
as the OLS coefficient of determination and the bound `Rsq ≤ 1`. -/
lemma rss_decomposition {x y : Fin n → ℝ} (hx : 0 < dot x x) (hy : 0 < dot y y) (b : ℝ) :
    dot (fun j => y j - b * x j) (fun j => y j - b * x j)
      = dot y y * (1 - Rsq x y) + dot x x * (b - dot x y / dot x x) ^ 2 := by
  rw [residual_identity, Rsq]
  field_simp
  ring

/-- OLS optimality: no slope beats the fraction `1 - R²` of unexplained variance. -/
lemma rss_ge {x y : Fin n → ℝ} (hx : 0 < dot x x) (hy : 0 < dot y y) (b : ℝ) :
    dot y y * (1 - Rsq x y) ≤ dot (fun j => y j - b * x j) (fun j => y j - b * x j) := by
  rw [rss_decomposition hx hy b]
  nlinarith [sq_nonneg (b - dot x y / dot x x), hx.le]

/-- ... and the bound is attained at the OLS slope. -/
lemma rss_at_ols {x y : Fin n → ℝ} (hx : 0 < dot x x) (hy : 0 < dot y y) :
    dot (fun j => y j - (dot x y / dot x x) * x j) (fun j => y j - (dot x y / dot x x) * x j)
      = dot y y * (1 - Rsq x y) := by
  rw [rss_decomposition hx hy]
  simp

lemma Rsq_nonneg (x y : Fin n → ℝ) : 0 ≤ Rsq x y := by
  apply div_nonneg (sq_nonneg _)
  exact mul_nonneg (dot_self_nonneg x) (dot_self_nonneg y)

lemma Rsq_le_one (x y : Fin n → ℝ) : Rsq x y ≤ 1 := by
  rcases lt_or_eq_of_le (dot_self_nonneg x) with hx | hx
  · rcases lt_or_eq_of_le (dot_self_nonneg y) with hy | hy
    · have h0 : (0:ℝ) ≤ dot (fun j => y j - (dot x y / dot x x) * x j)
          (fun j => y j - (dot x y / dot x x) * x j) := dot_self_nonneg _
      rw [rss_at_ols hx hy] at h0
      nlinarith
    · simp [Rsq, ← hy]
  · simp [Rsq, ← hx]

/-! ## Orthogonal-increment window models -/

/-- A *window model*: `m` predictor columns `v 0, …, v (m-1)` in the sample space
`Fin n → ℝ`, pairwise orthogonal and nonzero, together with a nonzero response
`y`.  The orthogonality assumption is the mathematical idealisation of "distinct
primes contribute independent information". -/
structure Model (n m : ℕ) where
  /-- the predictor columns -/
  v : ℕ → Fin n → ℝ
  /-- the response -/
  y : Fin n → ℝ
  /-- each column in the window is nonzero -/
  self_pos : ∀ i < m, 0 < dot (v i) (v i)
  /-- distinct columns in the window are orthogonal -/
  orth : ∀ i < m, ∀ j < m, i ≠ j → dot (v i) (v j) = 0
  /-- the response is nonzero -/
  resp_pos : 0 < dot y y

namespace Model

variable {m : ℕ} (M : Model n m)

/-- Squared length of the `i`-th column. -/
def s (i : ℕ) : ℝ := dot (M.v i) (M.v i)

/-- Inner product of the `i`-th column with the response. -/
def a (i : ℕ) : ℝ := dot (M.v i) M.y

/-- The window statistic `S_{w,B} = ∑_{i < B} w i · v i`. -/
def agg (w : ℕ → ℝ) (B : ℕ) : Fin n → ℝ := fun j => ∑ i ∈ range B, w i * M.v i j

lemma s_pos {i : ℕ} (hi : i < m) : 0 < M.s i := M.self_pos i hi

/-- Numerator statistic: the inner product `⟪S_{w,B}, y⟫`. -/
def num (w : ℕ → ℝ) (B : ℕ) : ℝ := ∑ i ∈ range B, w i * M.a i

/-- Denominator statistic: the squared length `‖S_{w,B}‖²`. -/
def den (w : ℕ → ℝ) (B : ℕ) : ℝ := ∑ i ∈ range B, (w i) ^ 2 * M.s i

/-- The scored curve: `R²` of the regression of `y` on the window statistic. -/
noncomputable def R2 (w : ℕ → ℝ) (B : ℕ) : ℝ := (M.num w B) ^ 2 / (M.den w B * dot M.y M.y)

lemma agg_dot_y (w : ℕ → ℝ) (B : ℕ) : dot (M.agg w B) M.y = M.num w B := by
  simp only [dot, agg, Finset.sum_mul, num]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun i _ => ?_
  simp only [Model.a, dot, Finset.mul_sum, mul_assoc]

lemma agg_dot_self (w : ℕ → ℝ) {B : ℕ} (hB : B ≤ m) :
    dot (M.agg w B) (M.agg w B) = M.den w B := by
  simp only [dot, agg, Finset.sum_mul, Finset.mul_sum, den]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun i hi => ?_
  rw [Finset.sum_comm, Finset.sum_eq_single i]
  · simp only [Model.s, dot, Finset.mul_sum]
    exact Finset.sum_congr rfl fun j _ => by ring
  · intro k hk hki
    have h2 : ∑ j, w k * M.v k j * (w i * M.v i j) = w k * w i * dot (M.v k) (M.v i) := by
      simp only [dot, Finset.mul_sum]
      exact Finset.sum_congr rfl fun j _ => by ring
    have hkm : k < m := lt_of_lt_of_le (Finset.mem_range.mp hk) hB
    have him : i < m := lt_of_lt_of_le (Finset.mem_range.mp hi) hB
    rw [h2, M.orth k hkm i him hki, mul_zero]
  · intro h; exact absurd hi h

/-- The scalar curve `R2` really is the `R²` of the regression of the response on
the window statistic. -/
theorem R2_eq_Rsq (w : ℕ → ℝ) {B : ℕ} (hB : B ≤ m) : M.R2 w B = Rsq (M.agg w B) M.y := by
  rw [Rsq, R2, agg_dot_y, agg_dot_self M w hB]

lemma R2_nonneg (w : ℕ → ℝ) (B : ℕ) : 0 ≤ M.R2 w B := by
  refine div_nonneg (sq_nonneg _) (mul_nonneg ?_ M.resp_pos.le)
  exact Finset.sum_nonneg fun i _ => mul_nonneg (sq_nonneg _) (dot_self_nonneg _)

theorem R2_le_one (w : ℕ → ℝ) {B : ℕ} (hB : B ≤ m) : M.R2 w B ≤ 1 := by
  rw [R2_eq_Rsq M w hB]; exact Rsq_le_one _ _

/-! ### Recursions and elementary positivity -/

lemma num_succ (w : ℕ → ℝ) (B : ℕ) : M.num w (B + 1) = M.num w B + w B * M.a B := by
  simp [num, Finset.sum_range_succ]

lemma den_succ (w : ℕ → ℝ) (B : ℕ) : M.den w (B + 1) = M.den w B + (w B) ^ 2 * M.s B := by
  simp [den, Finset.sum_range_succ]

lemma den_nonneg (w : ℕ → ℝ) (B : ℕ) : 0 ≤ M.den w B :=
  Finset.sum_nonneg fun _ _ => mul_nonneg (sq_nonneg _) (dot_self_nonneg _)

lemma den_mono (w : ℕ → ℝ) {B C : ℕ} (h : B ≤ C) : M.den w B ≤ M.den w C := by
  refine Finset.sum_le_sum_of_subset_of_nonneg
    (fun x hx => Finset.mem_range.mpr (lt_of_lt_of_le (Finset.mem_range.mp hx) h)) ?_
  intro i _ _
  exact mul_nonneg (sq_nonneg _) (dot_self_nonneg _)

lemma sq_pos_of_ne_zero {x : ℝ} (hx : x ≠ 0) : 0 < x ^ 2 :=
  lt_of_le_of_ne (sq_nonneg x) (Ne.symm (pow_ne_zero 2 hx))

lemma den_pos_of_term {w : ℕ → ℝ} {B i : ℕ} (hi : i < B) (him : i < m) (hw : w i ≠ 0) :
    0 < M.den w B := by
  have hterm : 0 < (w i) ^ 2 * M.s i := mul_pos (sq_pos_of_ne_zero hw) (M.s_pos him)
  refine lt_of_lt_of_le hterm (Finset.single_le_sum (f := fun k => (w k) ^ 2 * M.s k)
    (fun k _ => mul_nonneg (sq_nonneg _) (dot_self_nonneg _)) (Finset.mem_range.mpr hi))

/-! ## The step calculus: when does one more column help? -/

/-- The exact one-step change of the ratio `A²/S`. -/
lemma step_diff {A S a c : ℝ} (hS : 0 < S) (hSc : 0 < S + c) :
    (A + a) ^ 2 / (S + c) - A ^ 2 / S = (S * a * (2 * A + a) - A ^ 2 * c) / (S * (S + c)) := by
  field_simp
  ring

/-- **Noise dilutes.**  Appending a column orthogonal to the response (`a B = 0`)
with a nonzero weight strictly decreases the score, provided the window already
carries signal.  This is the mechanism of the descending branch. -/
theorem noise_dilutes {w : ℕ → ℝ} {B : ℕ} (hBm : B < m) (hden : 0 < M.den w B)
    (hnum : M.num w B ≠ 0) (hnoise : M.a B = 0) (hwB : w B ≠ 0) :
    M.R2 w (B + 1) < M.R2 w B := by
  have hyy : 0 < dot M.y M.y := M.resp_pos
  have hc : 0 < (w B) ^ 2 * M.s B := mul_pos (sq_pos_of_ne_zero hwB) (M.s_pos hBm)
  have hden' : 0 < M.den w (B + 1) := by rw [den_succ]; linarith
  have hnumeq : M.num w (B + 1) = M.num w B := by rw [num_succ, hnoise, mul_zero, add_zero]
  rw [R2, R2, hnumeq, den_succ]
  rw [div_lt_div_iff₀ (by positivity) (by positivity)]
  have hpos : 0 < (M.num w B) ^ 2 := by positivity
  nlinarith [mul_pos (mul_pos hpos hc) hyy, hpos, hc, hyy, hden]

/-- **Signal helps.**  If the appended column's weighted slope is at least the
running slope of the window, the score strictly increases.  Precisely, with
`A = ⟪S,y⟫`, `S = ‖S‖²` and the new contributions `a = w_B a_B`, `c = w_B² s_B`,
the hypothesis is `a·S ≥ A·c` together with positivity. -/
theorem matched_step_increases {w : ℕ → ℝ} {B : ℕ} (hBm : B < m) (hden : 0 < M.den w B)
    (hnum : 0 < M.num w B) (ha : 0 < w B * M.a B)
    (hslope : (w B * M.a B) * M.den w B ≥ M.num w B * ((w B) ^ 2 * M.s B)) :
    M.R2 w B < M.R2 w (B + 1) := by
  have hyy : 0 < dot M.y M.y := M.resp_pos
  have hwB : w B ≠ 0 := by
    intro h; rw [h, zero_mul] at ha; exact lt_irrefl 0 ha
  have hc : 0 < (w B) ^ 2 * M.s B := mul_pos (sq_pos_of_ne_zero hwB) (M.s_pos hBm)
  rw [R2, R2, num_succ, den_succ]
  rw [div_lt_div_iff₀ (by positivity) (by positivity)]
  set A := M.num w B
  set S := M.den w B
  set p := w B * M.a B
  set c := (w B) ^ 2 * M.s B
  -- key algebra: `S·p·(2A+p) - A²·c > 0`
  have key : S * p * (2 * A + p) - A ^ 2 * c > 0 := by
    have h1 : A * (p * S) ≥ A * (A * c) := by
      apply mul_le_mul_of_nonneg_left _ hnum.le
      linarith [hslope]
    nlinarith [ha, hnum, hden, mul_pos hden ha]
  nlinarith [key, hyy, hden, hc]

/-! ## Matched signal, then noise: the unique interior argmax -/

section Saturation

variable {w : ℕ → ℝ} {t : ℕ}

/-- On a *matched* prefix the running numerator is a fixed multiple `ρ` of the
running denominator. -/
lemma num_eq_rho_den {rho : ℝ}
    (hmatch : ∀ i < t, w i * M.a i = rho * ((w i) ^ 2 * M.s i)) {B : ℕ} (hB : B ≤ t) :
    M.num w B = rho * M.den w B := by
  induction B with
  | zero => simp [num, den]
  | succ k ih =>
      have hk : k ≤ t := by omega
      rw [num_succ, den_succ, ih hk, hmatch k (by omega)]
      ring

lemma num_pos_of_matched (hpos : ∀ i < t, 0 < w i * M.a i) {B : ℕ} (hB1 : 1 ≤ B) (hBt : B ≤ t) :
    0 < M.num w B := by
  have : ∀ i ∈ range B, 0 < w i * M.a i := by
    intro i hi
    exact hpos i (lt_of_lt_of_le (Finset.mem_range.mp hi) hBt)
  refine Finset.sum_pos this ?_
  exact Finset.nonempty_range_iff.mpr (by omega)

lemma den_pos_of_matched (hpos : ∀ i < t, 0 < w i * M.a i) (htm : t ≤ m) {B : ℕ}
    (hB1 : 1 ≤ B) (hBt : B ≤ t) : 0 < M.den w B := by
  have hw0 : w 0 ≠ 0 := by
    intro h
    have := hpos 0 (by omega)
    rw [h, zero_mul] at this; exact lt_irrefl 0 this
  exact den_pos_of_term M (by omega) (by omega) hw0

/-- On a matched prefix, each extra column strictly increases the score. -/
theorem matched_prefix_step {rho : ℝ} (htm : t ≤ m)
    (hmatch : ∀ i < t, w i * M.a i = rho * ((w i) ^ 2 * M.s i))
    (hpos : ∀ i < t, 0 < w i * M.a i) {B : ℕ} (hBt : B < t) :
    M.R2 w B < M.R2 w (B + 1) := by
  rcases Nat.eq_zero_or_pos B with hB0 | hB1
  · -- from the empty window the score jumps from `0` to something positive
    subst hB0
    have h1 : M.R2 w 0 = 0 := by simp [R2, num, den]
    rw [h1]
    have hnum : 0 < M.num w 1 := num_pos_of_matched M hpos le_rfl (by omega)
    have hden : 0 < M.den w 1 := den_pos_of_matched M hpos htm le_rfl (by omega)
    have : 0 < (M.num w 1) ^ 2 / (M.den w 1 * dot M.y M.y) :=
      div_pos (pow_pos hnum 2) (mul_pos hden M.resp_pos)
    simpa [R2] using this
  · have hnum : 0 < M.num w B := num_pos_of_matched M hpos hB1 (by omega)
    have hden : 0 < M.den w B := den_pos_of_matched M hpos htm hB1 (by omega)
    refine matched_step_increases M (lt_of_lt_of_le hBt htm) hden hnum (hpos B hBt) ?_
    rw [hmatch B hBt, num_eq_rho_den M hmatch (le_of_lt hBt)]
    ring_nf
    exact le_rfl

/-- Beyond the signal block the numerator no longer moves. -/
lemma num_const_after (hnoise : ∀ i, t ≤ i → i < m → M.a i = 0) {B : ℕ} (htB : t ≤ B)
    (hBm : B ≤ m) : M.num w B = M.num w t := by
  induction B with
  | zero => have : t = 0 := by omega
            simp [this]
  | succ k ih =>
      rcases Nat.lt_or_ge t (k + 1) with hk | hk
      · have hk' : t ≤ k := by omega
        rw [num_succ, ih hk' (by omega), hnoise k hk' (by omega), mul_zero, add_zero]
      · have : t = k + 1 := by omega
        simp [this]

/-- Chaining a strict one-step increase. -/
lemma lt_of_step_up {f : ℕ → ℝ} {t : ℕ} (h : ∀ B, B < t → f B < f (B + 1)) :
    ∀ {B C : ℕ}, B < C → C ≤ t → f B < f C := by
  intro B C hBC hCt
  induction C with
  | zero => omega
  | succ k ih =>
      rcases Nat.lt_or_ge B k with hBk | hBk
      · exact lt_trans (ih hBk (by omega)) (h k (by omega))
      · have : B = k := by omega
        subst this; exact h B (by omega)

/-- Chaining a strict one-step decrease. -/
lemma lt_of_step_down {f : ℕ → ℝ} {t m : ℕ} (h : ∀ B, t ≤ B → B < m → f (B + 1) < f B) :
    ∀ {B C : ℕ}, t ≤ B → B < C → C ≤ m → f C < f B := by
  intro B C htB hBC hCm
  induction C with
  | zero => omega
  | succ k ih =>
      rcases Nat.lt_or_ge B k with hBk | hBk
      · exact lt_trans (h k (by omega) (by omega)) (ih hBk (by omega))
      · have : B = k := by omega
        subst this; exact h B htB (by omega)

/-- **Saturation theorem.**  Suppose the first `t` columns are *matched* to the
weight (their weighted contributions all have the same slope `rho` and are
strictly positive) and every later column in the window is pure noise
(orthogonal to the response) carrying a nonzero weight.  Then the score curve
`B ↦ R²(w,B)` is strictly increasing on `[0,t]` and strictly decreasing on
`[t,m]`: the argmax set is exactly `{t}`, a unique interior maximum. -/
theorem unique_interior_argmax {rho : ℝ} (htm : t ≤ m) (ht1 : 1 ≤ t)
    (hmatch : ∀ i < t, w i * M.a i = rho * ((w i) ^ 2 * M.s i))
    (hpos : ∀ i < t, 0 < w i * M.a i)
    (hnoise : ∀ i, t ≤ i → i < m → M.a i = 0)
    (hwne : ∀ i, t ≤ i → i < m → w i ≠ 0) :
    ∀ B ≤ m, B ≠ t → M.R2 w B < M.R2 w t := by
  have hnumt : 0 < M.num w t := num_pos_of_matched M hpos ht1 le_rfl
  have hdent : 0 < M.den w t := den_pos_of_matched M hpos htm ht1 le_rfl
  have hup : ∀ B, B < t → M.R2 w B < M.R2 w (B + 1) := fun B hB =>
    matched_prefix_step M htm hmatch hpos hB
  have hdown : ∀ B, t ≤ B → B < m → M.R2 w (B + 1) < M.R2 w B := by
    intro B htB hBm
    have hnumB : M.num w B = M.num w t := num_const_after M hnoise htB (by omega)
    have hdenB : 0 < M.den w B := lt_of_lt_of_le hdent (den_mono M w htB)
    exact noise_dilutes M hBm hdenB (by rw [hnumB]; exact ne_of_gt hnumt)
      (hnoise B htB hBm) (hwne B htB hBm)
  intro B hBm hBt
  rcases Nat.lt_or_ge B t with h | h
  · exact lt_of_step_up hup h le_rfl
  · have htB : t ≤ B := h
    have : t < B := lt_of_le_of_ne htB (Ne.symm hBt)
    exact lt_of_step_down hdown le_rfl this hBm

end Saturation

/-! ## The matched filter dominates every weight at every window -/

/-- The matched filter (a.k.a. the per-column regression slope) `w(i) = a i / s i`. -/
noncomputable def mf (i : ℕ) : ℝ := M.a i / M.s i

/-- The explained-signal functional `E B = ∑_{i<B} a i ² / s i`. -/
noncomputable def E (B : ℕ) : ℝ := ∑ i ∈ range B, (M.a i) ^ 2 / M.s i

lemma E_nonneg {B : ℕ} (hB : B ≤ m) : 0 ≤ M.E B :=
  Finset.sum_nonneg fun _ hi =>
    div_nonneg (sq_nonneg _) (M.s_pos (lt_of_lt_of_le (Finset.mem_range.mp hi) hB)).le

lemma E_mono {B C : ℕ} (hBC : B ≤ C) (hC : C ≤ m) : M.E B ≤ M.E C := by
  refine Finset.sum_le_sum_of_subset_of_nonneg
    (fun x hx => Finset.mem_range.mpr (lt_of_lt_of_le (Finset.mem_range.mp hx) hBC)) ?_
  intro k hk _
  exact div_nonneg (sq_nonneg _) (M.s_pos (lt_of_lt_of_le (Finset.mem_range.mp hk) hC)).le

lemma num_mf {B : ℕ} (hB : B ≤ m) : M.num M.mf B = M.E B := by
  refine Finset.sum_congr rfl fun i hi => ?_
  have hs : M.s i ≠ 0 := (M.s_pos (lt_of_lt_of_le (Finset.mem_range.mp hi) hB)).ne'
  show M.a i / M.s i * M.a i = M.a i ^ 2 / M.s i
  field_simp

lemma den_mf {B : ℕ} (hB : B ≤ m) : M.den M.mf B = M.E B := by
  refine Finset.sum_congr rfl fun i hi => ?_
  have hs : M.s i ≠ 0 := (M.s_pos (lt_of_lt_of_le (Finset.mem_range.mp hi) hB)).ne'
  show (M.a i / M.s i) ^ 2 * M.s i = M.a i ^ 2 / M.s i
  field_simp

/-- The matched-filter score is exactly the explained signal, normalised. -/
theorem R2_mf {B : ℕ} (hB : B ≤ m) : M.R2 M.mf B = M.E B / dot M.y M.y := by
  rw [R2, num_mf M hB, den_mf M hB]
  rcases eq_or_lt_of_le (M.E_nonneg hB) with h | h
  · simp [← h]
  · field_simp

/-- **No interior maximum for the matched filter.**  The matched-filter curve is
monotone in the window size: enlarging the window never hurts. -/
theorem matched_curve_monotone {B C : ℕ} (hBC : B ≤ C) (hC : C ≤ m) :
    M.R2 M.mf B ≤ M.R2 M.mf C := by
  rw [R2_mf M (le_trans hBC hC), R2_mf M hC]
  have hE := M.E_mono hBC hC
  have hyy := M.resp_pos
  gcongr

/-- **Matched filter dominance ("plateau raised everywhere").**  For *every*
weight and *every* window, the matched filter scores at least as high. -/
theorem R2_le_matched (w : ℕ → ℝ) {B : ℕ} (hB : B ≤ m) : M.R2 w B ≤ M.R2 M.mf B := by
  have hyy : 0 < dot M.y M.y := M.resp_pos
  rw [R2_mf M hB, R2]
  rcases eq_or_lt_of_le (M.den_nonneg w B) with hden | hden
  · -- degenerate window: every used weight vanishes, the score is `0`
    have h0 : M.num w B = 0 := by
      refine Finset.sum_eq_zero fun i hi => ?_
      have him : i < m := lt_of_lt_of_le (Finset.mem_range.mp hi) hB
      have hterm : (w i) ^ 2 * M.s i = 0 := by
        by_contra hne
        have hpos : 0 < (w i) ^ 2 * M.s i :=
          lt_of_le_of_ne (mul_nonneg (sq_nonneg _) (dot_self_nonneg _)) (Ne.symm hne)
        have : (w i) ^ 2 * M.s i ≤ M.den w B :=
          Finset.single_le_sum (f := fun k => (w k) ^ 2 * M.s k)
            (fun k _ => mul_nonneg (sq_nonneg _) (dot_self_nonneg _)) hi
        rw [← hden] at this; linarith
      have hwi : w i = 0 := by
        rcases mul_eq_zero.mp hterm with h | h
        · exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp h
        · exact absurd h (M.s_pos him).ne'
      simp [hwi]
    rw [h0, ← hden]
    simp [div_nonneg, M.E_nonneg hB, hyy.le]
  · -- Cauchy–Schwarz: `(∑ w a)² ≤ (∑ w² s)(∑ a²/s)`
    have hcs : (M.num w B) ^ 2 ≤ M.den w B * M.E B := by
      have key := Finset.sum_mul_sq_le_sq_mul_sq (range B)
        (fun i => w i * Real.sqrt (M.s i)) (fun i => M.a i / Real.sqrt (M.s i))
      have e1 : ∑ i ∈ range B, (w i * Real.sqrt (M.s i)) * (M.a i / Real.sqrt (M.s i))
          = M.num w B := by
        refine Finset.sum_congr rfl fun i hi => ?_
        have him : i < m := lt_of_lt_of_le (Finset.mem_range.mp hi) hB
        have hs : Real.sqrt (M.s i) ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr (M.s_pos him))
        field_simp
      have e2 : ∑ i ∈ range B, (w i * Real.sqrt (M.s i)) ^ 2 = M.den w B := by
        refine Finset.sum_congr rfl fun i hi => ?_
        have him : i < m := lt_of_lt_of_le (Finset.mem_range.mp hi) hB
        rw [mul_pow, Real.sq_sqrt (M.s_pos him).le]
      have e3 : ∑ i ∈ range B, (M.a i / Real.sqrt (M.s i)) ^ 2 = M.E B := by
        refine Finset.sum_congr rfl fun i hi => ?_
        have him : i < m := lt_of_lt_of_le (Finset.mem_range.mp hi) hB
        rw [div_pow, Real.sq_sqrt (M.s_pos him).le]
      rw [e1, e2, e3] at key
      exact key
    rw [div_le_div_iff₀ (by positivity) hyy]
    nlinarith [hcs, hyy, hden, M.E_nonneg hB]

/-- **Global cap on the instrument.**  No choice of weight and no choice of
window can score above the total explained signal `E m / ‖y‖²`. -/
theorem R2_le_global (w : ℕ → ℝ) {B : ℕ} (hB : B ≤ m) :
    M.R2 w B ≤ M.E m / dot M.y M.y := by
  refine le_trans (R2_le_matched M w hB) ?_
  rw [R2_mf M hB]
  have hE := M.E_mono hB (le_refl m)
  have hyy := M.resp_pos
  gcongr

/-- The cap is attained: by the matched filter at the full window. -/
theorem R2_global_attained : M.R2 M.mf m = M.E m / dot M.y M.y := R2_mf M (le_refl m)

/-! ## The interior-argmax certificate -/

lemma num_smul (c : ℝ) (w : ℕ → ℝ) (B : ℕ) :
    M.num (fun i => c * w i) B = c * M.num w B := by
  simp only [num, Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => by ring

lemma den_smul (c : ℝ) (w : ℕ → ℝ) (B : ℕ) :
    M.den (fun i => c * w i) B = c ^ 2 * M.den w B := by
  simp only [den, Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- `R²` only depends on the weight up to a nonzero global scale. -/
theorem R2_smul {c : ℝ} (hc : c ≠ 0) (w : ℕ → ℝ) (B : ℕ) :
    M.R2 (fun i => c * w i) B = M.R2 w B := by
  rw [R2, R2, num_smul, den_smul, mul_pow, mul_assoc]
  exact mul_div_mul_left _ _ (pow_ne_zero 2 hc)

lemma R2_congr {w w' : ℕ → ℝ} {B : ℕ} (h : ∀ i < B, w i = w' i) :
    M.R2 w B = M.R2 w' B := by
  have hn : M.num w B = M.num w' B :=
    Finset.sum_congr rfl fun i hi => by rw [h i (Finset.mem_range.mp hi)]
  have hd : M.den w B = M.den w' B :=
    Finset.sum_congr rfl fun i hi => by rw [h i (Finset.mem_range.mp hi)]
  rw [R2, R2, hn, hd]

/-- **Interior-argmax certificate.**  If the observed score curve has a strict
interior maximum — some window `t < m` scores strictly above the full window `m`
— then the weight in use is *provably not* the matched filter, not even up to a
global rescaling.  Equivalently: an interior `B*` is a diagnostic of weight
mismatch, never of the geometry of the columns alone. -/
theorem interior_argmax_certifies_mismatch {w : ℕ → ℝ} {t : ℕ} (htm : t < m)
    (hpeak : M.R2 w m < M.R2 w t) :
    ¬ ∃ c : ℝ, c ≠ 0 ∧ ∀ i < m, w i = c * M.mf i := by
  rintro ⟨c, hc, hw⟩
  have h1 : M.R2 w t = M.R2 M.mf t := by
    rw [R2_congr M (w' := fun i => c * M.mf i) (fun i hi => hw i (by omega)),
      R2_smul M hc]
  have h2 : M.R2 w m = M.R2 M.mf m := by
    rw [R2_congr M (w' := fun i => c * M.mf i) (fun i hi => hw i hi), R2_smul M hc]
  have := matched_curve_monotone M (le_of_lt htm) (le_refl m)
  rw [← h1, ← h2] at this
  linarith

end Model

/-! ## Bootstrap stability of the argmax location

The empirical caveat "`1600` sits only `0.0105` below the peak, so the bootstrap
argmax is bimodal" is exactly the following pair of statements about a finite
grid of scores. -/

/-- If `t` beats every other grid point by a margin `δ`, then every perturbation
of size `< δ/2` keeps `t` the unique argmax. -/
theorem argmax_stable_of_margin {G : Finset ℕ} {f g : ℕ → ℝ} {t : ℕ} {δ : ℝ}
    (hmax : ∀ u ∈ G, u ≠ t → f u + δ ≤ f t)
    (hpert : ∀ u ∈ G, |g u - f u| < δ / 2) (ht : t ∈ G) :
    ∀ u ∈ G, u ≠ t → g u < g t := by
  intro u hu hut
  have h1 : |g u - f u| < δ / 2 := hpert u hu
  have h2 : |g t - f t| < δ / 2 := hpert t ht
  have h1' : g u - f u < δ / 2 := lt_of_abs_lt h1
  have h2' : -(δ / 2) < g t - f t := neg_lt_of_abs_lt h2
  have := hmax u hu hut
  linarith

/-- Conversely, the bound `δ/2` in `argmax_stable_of_margin` is sharp: for every
`ε > 0` there is a perturbation of sup-norm at most `δ/2 + ε` that flips the
argmax from `t` to a runner-up `u₀` sitting `δ` below it.  (Bimodal bootstrap
tails are therefore expected exactly when the top-two gap is comparable to twice
the resampling noise.) -/
theorem argmax_flip_of_small_margin {f : ℕ → ℝ} {t u₀ : ℕ} {δ ε : ℝ} (hδ : 0 < δ)
    (hε : 0 < ε) (hne : u₀ ≠ t) (hgap : f t - f u₀ = δ) :
    ∃ g : ℕ → ℝ, (∀ u, |g u - f u| ≤ δ / 2 + ε) ∧ g t < g u₀ := by
  classical
  have hpos : (0:ℝ) ≤ δ / 2 + ε := by linarith
  refine ⟨fun u => if u = u₀ then f u + (δ / 2 + ε) else
      (if u = t then f u - (δ / 2 + ε) else f u), ?_, ?_⟩
  · intro u
    by_cases h : u = u₀
    · simp only [if_pos h, add_sub_cancel_left, abs_of_nonneg hpos]
      exact le_refl _
    · by_cases h' : u = t
      · simp only [if_neg h, if_pos h', sub_sub_cancel_left, abs_neg, abs_of_nonneg hpos]
        exact le_refl _
      · simp only [if_neg h, if_neg h', sub_self, abs_zero]
        linarith
  · show (if t = u₀ then f t + (δ / 2 + ε) else (if t = t then f t - (δ / 2 + ε) else f t))
        < (if u₀ = u₀ then f u₀ + (δ / 2 + ε) else
            (if u₀ = t then f u₀ - (δ / 2 + ε) else f u₀))
    rw [if_neg (Ne.symm hne), if_pos rfl, if_pos rfl]
    linarith

/-! ## A concrete realisation (non-vacuity)

Four orthonormal columns in `ℝ⁴`, response `y = (1,1,0,0)`, unit weights: the
first two columns are matched signal, the last two are pure noise.  The score
curve is `0, 1/2, 1, 2/3, 1/2`, with a unique interior maximum at `t = 2`. -/

/-- The standard basis column `e i` in `Fin 4 → ℝ`. -/
def e (i : ℕ) : Fin 4 → ℝ := fun j => if (j : ℕ) = i then 1 else 0

/-- The response `(1,1,0,0)`. -/
def yEx : Fin 4 → ℝ := fun j => if (j : ℕ) < 2 then 1 else 0

lemma dot_e_e {i k : ℕ} (hi : i < 4) (hk : k < 4) :
    dot (e i) (e k) = if i = k then 1 else 0 := by
  interval_cases i <;> interval_cases k <;> simp [dot, e, Fin.sum_univ_four]

lemma dot_e_y {i : ℕ} (hi : i < 4) : dot (e i) yEx = if i < 2 then 1 else 0 := by
  interval_cases i <;> simp [dot, e, yEx, Fin.sum_univ_four]

lemma dot_yEx_yEx : dot yEx yEx = 2 := by
  simp [dot, yEx, Fin.sum_univ_four]
  norm_num

/-- The explicit saturation example. -/
def saturationExample : Model 4 4 where
  v := e
  y := yEx
  self_pos := by
    intro i hi
    rw [dot_e_e hi hi]; norm_num
  orth := by
    intro i hi j hj hij
    rw [dot_e_e hi hj, if_neg hij]
  resp_pos := by
    rw [dot_yEx_yEx]; norm_num

lemma saturationExample_s {i : ℕ} (hi : i < 4) : saturationExample.s i = 1 := by
  show dot (e i) (e i) = 1
  rw [dot_e_e hi hi, if_pos rfl]

lemma saturationExample_a {i : ℕ} (hi : i < 4) :
    saturationExample.a i = if i < 2 then 1 else 0 := by
  show dot (e i) yEx = if i < 2 then 1 else 0
  rw [dot_e_y hi]

lemma saturationExample_yy : dot saturationExample.y saturationExample.y = 2 :=
  dot_yEx_yEx

/-- The example satisfies the hypotheses of the saturation theorem with unit
weights, `rho = 1` and `t = 2`, so its score curve has a unique interior
maximum at the window `B = 2`. -/
theorem saturationExample_interior_argmax :
    ∀ B ≤ 4, B ≠ 2 → saturationExample.R2 (fun _ => 1) B
      < saturationExample.R2 (fun _ => 1) 2 := by
  refine Model.unique_interior_argmax (rho := 1) saturationExample (by omega) (by omega)
    ?_ ?_ ?_ ?_
  · intro i hi
    rw [saturationExample_a (by omega), saturationExample_s (by omega), if_pos hi]
    norm_num
  · intro i hi
    rw [saturationExample_a (by omega), if_pos hi]
    norm_num
  · intro i h2i hi4
    rw [saturationExample_a hi4, if_neg (by omega)]
  · intro i _ _; norm_num

/-- The computed curve of the example: `0, 1/2, 1, 2/3, 1/2`. -/
theorem saturationExample_curve :
    saturationExample.R2 (fun _ => 1) 0 = 0 ∧
    saturationExample.R2 (fun _ => 1) 1 = 1/2 ∧
    saturationExample.R2 (fun _ => 1) 2 = 1 ∧
    saturationExample.R2 (fun _ => 1) 3 = 2/3 ∧
    saturationExample.R2 (fun _ => 1) 4 = 1/2 := by
  have ha : ∀ i < 4, saturationExample.a i = if i < 2 then 1 else 0 :=
    fun i hi => saturationExample_a hi
  have hs : ∀ i < 4, saturationExample.s i = 1 := fun i hi => saturationExample_s hi
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;>
    simp only [Model.R2, Model.num, Model.den, saturationExample_yy, Finset.sum_range_succ,
      Finset.sum_range_zero, ha 0 (by norm_num), ha 1 (by norm_num), ha 2 (by norm_num),
      ha 3 (by norm_num), hs 0 (by norm_num), hs 1 (by norm_num), hs 2 (by norm_num),
      hs 3 (by norm_num)] <;> norm_num

end WindowSaturation