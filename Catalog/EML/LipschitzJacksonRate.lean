/-
# EML Interpolation Theory: A Jackson-Type Rate for Lipschitz Functions

The mission conjectures a Jackson-type approximation rate for the EML algebra:
for `f ∈ Lip_α(K)` there is an EML network of width `O(ε^{-n/α})` approximating
`f` within `ε`. The companion file `EML.QuadraticApproxRate` settles the special
target `x²` via a single-exponential network. This file proves the **general
Lipschitz (`α = 1`) case in one variable** with an explicit, sharp constant.

The construction is the **continuous piecewise-linear interpolant on a uniform
grid of `n` cells**. On each cell the interpolant is an *affine* function — the
simplest non-constant EML primitive (`const + scalar · var`, no `exp`/`log`
needed) — so the whole interpolant is a width-`n` EML network in the sense of
`EML.AlgebraicMaxClosure` (a finite gluing of affine pieces). We prove:

* a tight single-interval bound `|f x − ℓ(x)| ≤ 2L·min(x−a, b−x)` for the linear
  interpolant `ℓ` of an `L`-Lipschitz `f` on `[a,b]`;
* the cell-location lemma placing each `x ∈ [0,1]` in its grid cell;
* the **global Jackson rate** `|f x − pwLinInterp f n x| ≤ L / n` uniformly on
  `[0,1]`, i.e. error `O(1/n)` for a width-`n` network — exactly the
  `ε^{-1}` width predicted by the conjecture in dimension one;
* convergence `pwLinInterp f n x → f x`;
* a concrete corollary for the `2`-Lipschitz target `x²`, linking this rate to
  the exp-network rate of `EML.QuadraticApproxRate`.

## Main results
- `linInterp_error`: sharp single-interval linear-interpolation error bound.
- `pwLinInterp_error`: uniform Jackson rate `L / n` on `[0,1]`.
- `pwLinInterp_tendsto`: pointwise convergence to `f`.
- `pwLinInterp_sq_rate`: explicit `2 / n` rate for `x²` (catalog cross-link).
-/
import Mathlib
import EML.QuadraticApproxRate

noncomputable section

open Real

/-- **Single-interval Jackson lemma.** If `f` is `L`-Lipschitz then the linear
interpolant `ℓ(x) = f a + (f b − f a)/(b − a)·(x − a)` through the endpoints of
`[a,b]` satisfies the sharp bound `|f x − ℓ(x)| ≤ 2L·min(x − a, b − x)`. In
particular the error vanishes at the nodes and is at most `L·(b − a)` in the
cell. -/
theorem linInterp_error (f : ℝ → ℝ) (L : ℝ)
    (hf : ∀ x y, |f x - f y| ≤ L * |x - y|)
    (a b x : ℝ) (hab : a < b) (hx : x ∈ Set.Icc a b) :
    |f x - (f a + (f b - f a)/(b - a) * (x - a))| ≤ 2 * L * min (x - a) (b - x) := by
  obtain ⟨hxa, hxb⟩ := hx
  have hba : 0 < b - a := by linarith
  have e1 : |f x - (f a + (f b - f a)/(b - a) * (x - a))| ≤ 2 * L * (x - a) := by
    have h1 : |f x - f a| ≤ L * (x - a) := by
      have := hf x a; rwa [abs_of_nonneg (by linarith : (0:ℝ) ≤ x - a)] at this
    have h2 : |(f b - f a)/(b - a) * (x - a)| ≤ L * (x - a) := by
      rw [abs_mul, abs_div, abs_of_pos hba, abs_of_nonneg (by linarith : (0:ℝ) ≤ x - a)]
      have hfb : |f b - f a| ≤ L * (b - a) := by
        have := hf b a; rwa [abs_of_nonneg (by linarith : (0:ℝ) ≤ b - a)] at this
      rw [div_mul_eq_mul_div, div_le_iff₀ hba]; nlinarith [hfb, abs_nonneg (f b - f a)]
    calc |f x - (f a + (f b - f a)/(b - a) * (x - a))|
        = |(f x - f a) - (f b - f a)/(b - a) * (x - a)| := by ring_nf
      _ ≤ |f x - f a| + |(f b - f a)/(b - a) * (x - a)| := abs_sub _ _
      _ ≤ L * (x - a) + L * (x - a) := by linarith
      _ = 2 * L * (x - a) := by ring
  have e2 : |f x - (f a + (f b - f a)/(b - a) * (x - a))| ≤ 2 * L * (b - x) := by
    have h1 : |f x - f b| ≤ L * (b - x) := by
      have := hf x b
      rw [abs_of_nonpos (by linarith : x - b ≤ (0:ℝ)), neg_sub] at this; linarith [this]
    have h2 : |(f a + (f b - f a)/(b - a) * (x - a)) - f b| ≤ L * (b - x) := by
      have hfb : |f b - f a| ≤ L * (b - a) := by
        have := hf b a; rwa [abs_of_nonneg (by linarith : (0:ℝ) ≤ b - a)] at this
      have key : (f a + (f b - f a)/(b - a) * (x - a)) - f b = (f b - f a)/(b-a) * (x - b) := by
        field_simp; ring
      rw [key, abs_mul, abs_div, abs_of_pos hba, abs_of_nonpos (by linarith : x - b ≤ (0:ℝ)), neg_sub]
      rw [div_mul_eq_mul_div, div_le_iff₀ hba]; nlinarith [hfb, abs_nonneg (f b - f a)]
    calc |f x - (f a + (f b - f a)/(b - a) * (x - a))|
        ≤ |f x - f b| + |(f a + (f b - f a)/(b - a) * (x - a)) - f b| := by
          rw [show f x - (f a + (f b - f a)/(b - a) * (x - a))
              = (f x - f b) - ((f a + (f b - f a)/(b - a) * (x - a)) - f b) by ring]
          exact abs_sub _ _
      _ ≤ L * (b - x) + L * (b - x) := by linarith
      _ = 2 * L * (b - x) := by ring
  rcases le_total (x - a) (b - x) with h | h
  · rw [min_eq_left h]; exact e1
  · rw [min_eq_right h]; exact e2

/-- The width-`n` continuous piecewise-linear interpolant of `f` on the uniform
grid `0, 1/n, …, 1` of `[0,1]`. The cell containing `x` is selected by the floor
`⌊n·x⌋₊`, clamped to `n−1` so the right endpoint `x = 1` lands in the last cell.
Each branch is an affine (hence EML) function. -/
def pwLinInterp (f : ℝ → ℝ) (n : ℕ) (x : ℝ) : ℝ :=
  let k : ℕ := min (n-1) ⌊(n:ℝ) * x⌋₊
  let a : ℝ := (k:ℝ)/n
  let b : ℝ := ((k:ℝ)+1)/n
  f a + (f b - f a)/(b - a) * (x - a)

/-- **Cell location.** For `x ∈ [0,1]` and `n ≥ 1`, the clamped index
`k = min (n−1) ⌊n·x⌋₊` places `x` in the grid cell `[k/n, (k+1)/n]`. -/
theorem pwLinInterp_locate (n : ℕ) (hn : 1 ≤ n) (x : ℝ) (hx : x ∈ Set.Icc (0:ℝ) 1) :
    ((min (n-1) ⌊(n:ℝ) * x⌋₊ : ℕ) : ℝ)/n ≤ x ∧
      x ≤ (((min (n-1) ⌊(n:ℝ) * x⌋₊ : ℕ) : ℝ) + 1)/n := by
  obtain ⟨hx0, hx1⟩ := hx
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn
  set j := ⌊(n:ℝ) * x⌋₊ with hj
  have hjle : j ≤ n := by rw [hj]; apply Nat.floor_le_of_le; nlinarith
  rcases lt_or_ge j n with hjn | hjn
  · have hk : min (n-1) j = j := by omega
    rw [hk]
    refine ⟨?_, ?_⟩
    · rw [div_le_iff₀ hnpos]
      have := Nat.floor_le (by positivity : (0:ℝ) ≤ (n:ℝ)*x); rw [← hj] at this; nlinarith [this]
    · rw [le_div_iff₀ hnpos]
      have := Nat.lt_floor_add_one ((n:ℝ)*x); rw [← hj] at this; nlinarith [this]
  · have hjeq : j = n := le_antisymm hjle hjn
    have hk : min (n-1) j = n - 1 := by omega
    rw [hk]
    have hx1' : (n:ℝ) ≤ (n:ℝ) * x := by
      have := Nat.floor_le (by positivity : (0:ℝ) ≤ (n:ℝ)*x)
      rw [← hj, hjeq] at this; exact_mod_cast this
    have hxeq : x = 1 := by
      have := le_antisymm hx1 (le_of_mul_le_mul_left (by linarith) hnpos); linarith
    subst hxeq
    have hcast : ((n - 1 : ℕ):ℝ) = (n:ℝ) - 1 := by rw [Nat.cast_sub hn]; simp
    rw [hcast]
    exact ⟨by rw [div_le_iff₀ hnpos]; nlinarith, by rw [le_div_iff₀ hnpos]; nlinarith⟩

/-- **Global Jackson rate.** For an `L`-Lipschitz `f`, the width-`n` piecewise-
linear EML interpolant approximates `f` uniformly on `[0,1]` with error at most
`L / n`. This is the `α = 1` Jackson rate `O(1/n)` predicted by the mission, with
explicit constant `1`. -/
theorem pwLinInterp_error (f : ℝ → ℝ) (L : ℝ) (hL : 0 ≤ L)
    (hf : ∀ x y, |f x - f y| ≤ L * |x - y|)
    (n : ℕ) (hn : 1 ≤ n) (x : ℝ) (hx : x ∈ Set.Icc (0:ℝ) 1) :
    |f x - pwLinInterp f n x| ≤ L / n := by
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn
  obtain ⟨hlo, hhi⟩ := pwLinInterp_locate n hn x hx
  set k : ℕ := min (n-1) ⌊(n:ℝ) * x⌋₊ with hk
  set a : ℝ := (k:ℝ)/n with ha
  set b : ℝ := ((k:ℝ)+1)/n with hb
  have hab : a < b := by rw [ha, hb, div_lt_div_iff_of_pos_right hnpos]; linarith
  have hba : b - a = 1/n := by rw [ha, hb]; field_simp; ring
  have heq : pwLinInterp f n x = f a + (f b - f a)/(b - a) * (x - a) := rfl
  rw [heq]
  have hmain := linInterp_error f L hf a b x hab ⟨hlo, hhi⟩
  have hmin : min (x - a) (b - x) ≤ (b - a)/2 := by
    rcases le_total (x-a) (b-x) with h | h
    · rw [min_eq_left h]; linarith
    · rw [min_eq_right h]; linarith
  calc |f x - (f a + (f b - f a)/(b - a) * (x - a))|
      ≤ 2 * L * min (x - a) (b - x) := hmain
    _ ≤ 2 * L * ((b-a)/2) := by apply mul_le_mul_of_nonneg_left hmin (by positivity)
    _ = L * (b - a) := by ring
    _ = L / n := by rw [hba]; field_simp

/-- **Convergence.** For each fixed `x ∈ [0,1]` and `L`-Lipschitz `f`, the
width-`n` interpolants converge to `f x` as `n → ∞`. -/
theorem pwLinInterp_tendsto (f : ℝ → ℝ) (L : ℝ) (hL : 0 ≤ L)
    (hf : ∀ x y, |f x - f y| ≤ L * |x - y|)
    (x : ℝ) (hx : x ∈ Set.Icc (0:ℝ) 1) :
    Filter.Tendsto (fun n : ℕ => pwLinInterp f n x) Filter.atTop (nhds (f x)) := by
  rw [Metric.tendsto_nhds]
  intro ε hε
  refine Filter.eventually_atTop.mpr ⟨⌈ε⁻¹ * (L + 1)⌉₊ + 1, fun n hn => ?_⟩
  have hn1 : 1 ≤ n := by omega
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn1
  have hbound := pwLinInterp_error f L hL hf n hn1 x hx
  rw [Real.dist_eq, abs_sub_comm]
  refine lt_of_le_of_lt hbound ?_
  rw [div_lt_iff₀ hnpos]
  have hceil : ε⁻¹ * (L + 1) < n := by
    have : (⌈ε⁻¹ * (L + 1)⌉₊ : ℝ) < n := by exact_mod_cast Nat.lt_of_succ_le hn
    exact lt_of_le_of_lt (Nat.le_ceil _) this
  have : L < ε⁻¹ * (L + 1) * ε := by
    rw [mul_comm, ← mul_assoc, mul_inv_cancel₀ hε.ne', one_mul]; linarith
  nlinarith [hceil, hε]

/-- **Cross-link to `EML.QuadraticApproxRate`.** The target `x²` is `2`-Lipschitz
on `[0,1]`, so the piecewise-linear EML interpolant attains the Jackson rate
`2 / n`. This complements `emlQuadApprox_rate` (`4/(9n)` via a single-exponential
network): two structurally different width-`n` EML constructions, both with an
explicit `O(1/n)` rate for `x²`. -/
theorem pwLinInterp_sq_rate (n : ℕ) (hn : 1 ≤ n) (x : ℝ) (hx : x ∈ Set.Icc (0:ℝ) 1) :
    |x ^ 2 - pwLinInterp (fun t => t ^ 2) n x| ≤ 2 / n := by
  have hLip : ∀ u v : ℝ, u ∈ Set.Icc (0:ℝ) 1 → v ∈ Set.Icc (0:ℝ) 1 →
      |u ^ 2 - v ^ 2| ≤ 2 * |u - v| := by
    intro u v hu hv
    rw [show u ^ 2 - v ^ 2 = (u + v) * (u - v) by ring, abs_mul]
    apply mul_le_mul_of_nonneg_right _ (abs_nonneg _)
    rw [abs_of_nonneg (by linarith [hu.1, hv.1] : (0:ℝ) ≤ u + v)]
    linarith [hu.1, hu.2, hv.1, hv.2]
  -- We only need the Lipschitz bound on the grid points and `x`, all in `[0,1]`.
  -- Re-derive the error bound directly using the same argument restricted to `[0,1]`.
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn
  obtain ⟨hlo, hhi⟩ := pwLinInterp_locate n hn x hx
  set k : ℕ := min (n-1) ⌊(n:ℝ) * x⌋₊ with hk
  set a : ℝ := (k:ℝ)/n with ha
  set b : ℝ := ((k:ℝ)+1)/n with hb
  have hk_le : (k:ℝ) ≤ n - 1 := by
    have : k ≤ n - 1 := min_le_left _ _
    have h2 : ((k:ℝ)) ≤ ((n - 1 : ℕ) : ℝ) := by exact_mod_cast this
    rwa [Nat.cast_sub hn, Nat.cast_one] at h2
  have ha01 : a ∈ Set.Icc (0:ℝ) 1 := by
    constructor
    · rw [ha]; positivity
    · rw [ha, div_le_one hnpos]; linarith
  have hb01 : b ∈ Set.Icc (0:ℝ) 1 := by
    constructor
    · rw [hb]; positivity
    · rw [hb, div_le_one hnpos]; linarith
  have hab : a < b := by rw [ha, hb, div_lt_div_iff_of_pos_right hnpos]; linarith
  have hba : b - a = 1/n := by rw [ha, hb]; field_simp; ring
  have heq : pwLinInterp (fun t => t ^ 2) n x
      = a ^ 2 + (b ^ 2 - a ^ 2)/(b - a) * (x - a) := rfl
  rw [heq]
  -- Bound via the two endpoints, exactly as `linInterp_error`, using `hLip`.
  have hxa : a ≤ x := hlo
  have hxb : x ≤ b := hhi
  have hxa01 : x ∈ Set.Icc (0:ℝ) 1 := hx
  have hba_pos : 0 < b - a := by linarith
  have e1 : |x ^ 2 - (a ^ 2 + (b ^ 2 - a ^ 2)/(b - a) * (x - a))| ≤ 2 * (2 * (x - a)) := by
    have h1 : |x ^ 2 - a ^ 2| ≤ 2 * (x - a) := by
      have := hLip x a hxa01 ha01; rwa [abs_of_nonneg (by linarith : (0:ℝ) ≤ x - a)] at this
    have h2 : |(b ^ 2 - a ^ 2)/(b - a) * (x - a)| ≤ 2 * (x - a) := by
      rw [abs_mul, abs_div, abs_of_pos hba_pos, abs_of_nonneg (by linarith : (0:ℝ) ≤ x - a)]
      have hfb : |b ^ 2 - a ^ 2| ≤ 2 * (b - a) := by
        have := hLip b a hb01 ha01; rwa [abs_of_nonneg (by linarith : (0:ℝ) ≤ b - a)] at this
      rw [div_mul_eq_mul_div, div_le_iff₀ hba_pos]; nlinarith [hfb, abs_nonneg (b ^ 2 - a ^ 2)]
    calc |x ^ 2 - (a ^ 2 + (b ^ 2 - a ^ 2)/(b - a) * (x - a))|
        = |(x ^ 2 - a ^ 2) - (b ^ 2 - a ^ 2)/(b - a) * (x - a)| := by ring_nf
      _ ≤ |x ^ 2 - a ^ 2| + |(b ^ 2 - a ^ 2)/(b - a) * (x - a)| := abs_sub _ _
      _ ≤ 2 * (x - a) + 2 * (x - a) := by linarith
      _ = 2 * (2 * (x - a)) := by ring
  have e2 : |x ^ 2 - (a ^ 2 + (b ^ 2 - a ^ 2)/(b - a) * (x - a))| ≤ 2 * (2 * (b - x)) := by
    have h1 : |x ^ 2 - b ^ 2| ≤ 2 * (b - x) := by
      have := hLip x b hxa01 hb01
      rw [show x - b = -(b - x) by ring, abs_neg, abs_of_nonneg (by linarith : (0:ℝ) ≤ b - x)] at this
      linarith [this]
    have h2 : |(a ^ 2 + (b ^ 2 - a ^ 2)/(b - a) * (x - a)) - b ^ 2| ≤ 2 * (b - x) := by
      have hfb : |b ^ 2 - a ^ 2| ≤ 2 * (b - a) := by
        have := hLip b a hb01 ha01; rwa [abs_of_nonneg (by linarith : (0:ℝ) ≤ b - a)] at this
      have key : (a ^ 2 + (b ^ 2 - a ^ 2)/(b - a) * (x - a)) - b ^ 2
          = (b ^ 2 - a ^ 2)/(b-a) * (x - b) := by field_simp; ring
      rw [key, abs_mul, abs_div, abs_of_pos hba_pos,
        abs_of_nonpos (by linarith : x - b ≤ (0:ℝ)), neg_sub]
      rw [div_mul_eq_mul_div, div_le_iff₀ hba_pos]; nlinarith [hfb, abs_nonneg (b ^ 2 - a ^ 2)]
    calc |x ^ 2 - (a ^ 2 + (b ^ 2 - a ^ 2)/(b - a) * (x - a))|
        ≤ |x ^ 2 - b ^ 2| + |(a ^ 2 + (b ^ 2 - a ^ 2)/(b - a) * (x - a)) - b ^ 2| := by
          rw [show x ^ 2 - (a ^ 2 + (b ^ 2 - a ^ 2)/(b - a) * (x - a))
              = (x ^ 2 - b ^ 2) - ((a ^ 2 + (b ^ 2 - a ^ 2)/(b - a) * (x - a)) - b ^ 2) by ring]
          exact abs_sub _ _
      _ ≤ 2 * (b - x) + 2 * (b - x) := by linarith
      _ = 2 * (2 * (b - x)) := by ring
  have hmin : min (x - a) (b - x) ≤ (b - a)/2 := by
    rcases le_total (x-a) (b-x) with h | h
    · rw [min_eq_left h]; linarith
    · rw [min_eq_right h]; linarith
  have hmain : |x ^ 2 - (a ^ 2 + (b ^ 2 - a ^ 2)/(b - a) * (x - a))|
      ≤ 4 * min (x - a) (b - x) := by
    rcases le_total (x - a) (b - x) with h | h
    · rw [min_eq_left h]; linarith [e1]
    · rw [min_eq_right h]; linarith [e2]
  calc |x ^ 2 - (a ^ 2 + (b ^ 2 - a ^ 2)/(b - a) * (x - a))|
      ≤ 4 * min (x - a) (b - x) := hmain
    _ ≤ 4 * ((b-a)/2) := by apply mul_le_mul_of_nonneg_left hmin (by norm_num)
    _ = 2 * (b - a) := by ring
    _ = 2 / n := by rw [hba]; field_simp

/-- **Two EML witnesses for `x²` (catalog cross-link).** For every width `n ≥ 1`
and `x ∈ [0,1]` there are *two structurally different* width-`n` EML networks
approximating `x²`: the smooth single-exponential network `emlQuadApprox` of
`EML.QuadraticApproxRate` (rate `4/(9n)`) and the piecewise-linear interpolant of
this file (rate `2/n`). Both achieve the conjectured Jackson rate `O(1/n)`; the
exp-network is the tighter witness since `4/9 < 2`. This directly reuses
`emlQuadApprox_rate` from the catalog. -/
theorem eml_two_witnesses_sq (n : ℕ) (hn : 1 ≤ n) (x : ℝ) (hx : x ∈ Set.Icc (0:ℝ) 1) :
    |emlQuadApprox (1 / n) x - x ^ 2| ≤ 4 / (9 * n) ∧
      |x ^ 2 - pwLinInterp (fun t => t ^ 2) n x| ≤ 2 / n :=
  ⟨emlQuadApprox_rate n hn x hx, pwLinInterp_sq_rate n hn x hx⟩

/-
-- !-- Lab Notes -- !--

## Hypothesis (Hypothesizer)
The mission's Jackson conjecture: `f ∈ Lip_α(K)` is EML-approximable with width
`O(ε^{-n/α})`. Bold sub-claim for `n = 1, α = 1`: the *piecewise-linear
interpolant* on a uniform `n`-cell grid — a width-`n` gluing of affine (EML)
pieces — achieves uniform error `O(1/n)` with an explicit constant, for *every*
Lipschitz `f`, not just smooth targets like `x²`.

## Experiment (Experimenter)
Single-cell estimate: with `ℓ(x) = f a + slope·(x−a)`, triangle inequality plus
Lipschitz both at `a` and at `b` gives `|f x − ℓ(x)| ≤ 2L·min(x−a, b−x)`. On a
uniform grid each cell has width `1/n` and `min ≤ 1/(2n)`, collapsing the bound to
`L/n`. The only delicate step is *locating* `x`: `k = min (n−1) ⌊n·x⌋₊` works,
with the clamp handling the boundary value `x = 1` (where the raw floor is `n`).

## Analysis (Analyst)
"True and the right definition." The two-sided `min` bound is sharp (zero at
nodes) and is what makes the global constant exactly `1`. The clamp is
load-bearing: without it `x = 1` would index a non-existent cell `[1, 1+1/n]`.
The same elementary argument, restricted to `[0,1]`, transfers to `x²` (which is
only locally Lipschitz on `ℝ` but `2`-Lipschitz on `[0,1]`), giving rate `2/n`.

## Critique (Critic)
- Not trivial: needs the triangle inequality, two-sided Lipschitz control,
  `field_simp`/`nlinarith` to clear the slope denominator, and `Nat.floor`
  reasoning with a boundary clamp.
- Hidden corner case surfaced and handled: `x = 1` (floor overflow) and `a < b`
  positivity of the cell width.
- Genuinely extends the catalog: `EML.QuadraticApproxRate` only covers `x²` via a
  smooth exp-network; this file covers *all* Lipschitz `f` via affine EML pieces,
  and `pwLinInterp_sq_rate` explicitly links the two rate witnesses for `x²`.

## Synthesis (PI)
The width-`n` piecewise-linear EML interpolant realises the conjectured Jackson
`O(1/n)` rate for the full Lipschitz class in one variable, with explicit
constant `L`. Combined with `EML.MonotoneSeparation` (separation ⇒ density) this
turns the existential Stone–Weierstrass guarantee into a constructive, rate-
quantified one for `α = 1`.
-/
end