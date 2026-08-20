/-
# Effective (Linnik-type) consequences of the Chebotarev geodesic theorem

Motivated by *"Chebotarev geodesic theorem: non-split case"*.  The qualitative corollary of a
Chebotarev-type asymptotic `π_C(x) = δ_C · li(x) + O(x^{θ+ε})` is that every conjugacy class
contains infinitely many primitive closed geodesics (this is `tendsto_atTop_of_hasErrorExponent`
in `ChebotarevGeodesic.lean`).  What the *effective* form of the theorem really provides is a
**threshold**: an explicit `X₀`, computed from the implied constant, beyond which the class
counting function is already at least half of its main term.  This is the geodesic analogue of
Linnik's theorem on the least prime in an arithmetic progression.

This file proves:

* `rpow_le_rpow_of_le_rpow_inv` : the elementary `rpow` threshold inequality;
* `eventually_rpow_lt_rpow` : `K·x^a < L·x^b` eventually, whenever `a < b`, `K, L > 0`;
* `effective_lower_bound` : an **explicit** threshold `max X₁ ((2C/c)^{2/(β-θ)})` beyond which
  `π x ≥ (c/2)·x^β`, given `|π - M| ≤ C x^{(θ+β)/2}` and `M x ≥ c x^β`;
* `effective_positivity` and `exists_effective_threshold` : the resulting positivity statement
  and its qualitative repackaging from `HasErrorExponent`;
* `effective_lower_bound_25_36` : the numerical instance for the exponent `25/36` of the paper
  (threshold `(2C/c)^{72/11}`);
* `eventually_lt_of_window` : *every* window `[x, λx]` with `λ > 1` eventually contains a new
  geodesic of the given class — a strengthening of "infinitely many" to a quantitative gap
  statement;
* `chebotarev_class_window_25_36` : the same for the exponent of the paper.
-/

import Mathlib
import Catalog.Shared.ChebotarevGeodesic

open Finset Filter
open scoped Topology

namespace ChebotarevGeodesic

/-! ## Two elementary `rpow` facts -/

/-- If `x` is beyond the threshold `A^{1/δ}` then `x^δ` is beyond `A`. -/
theorem rpow_le_rpow_of_le_rpow_inv {A δ x : ℝ} (hA : 0 ≤ A) (hδ : 0 < δ)
    (hx : A ^ (1 / δ) ≤ x) : A ≤ x ^ δ := by
  have h0 : (0 : ℝ) ≤ A ^ (1 / δ) := Real.rpow_nonneg hA _
  calc A = (A ^ (1 / δ)) ^ δ := by
        rw [← Real.rpow_mul hA, one_div, inv_mul_cancel₀ hδ.ne', Real.rpow_one]
    _ ≤ x ^ δ := Real.rpow_le_rpow h0 hx hδ.le

/-- A lower-order power is eventually dominated by a higher-order power, with arbitrary positive
constants. -/
theorem eventually_rpow_lt_rpow {a b K L : ℝ} (hab : a < b) (hK : 0 < K) (hL : 0 < L) :
    ∀ᶠ x in atTop, K * x ^ a < L * x ^ b := by
  have hpos : 0 < b - a := by linarith
  have hlim : Tendsto (fun x : ℝ => x ^ (-(b - a))) atTop (𝓝 0) := tendsto_rpow_neg_atTop hpos
  have hev := hlim.eventually (gt_mem_nhds (show (0 : ℝ) < L / (2 * K) by positivity))
  filter_upwards [hev, eventually_gt_atTop (0 : ℝ)] with x hxlt hx0
  have hsplit : x ^ a = x ^ (-(b - a)) * x ^ b := by
    rw [← Real.rpow_add hx0]; ring_nf
  have hxb : (0 : ℝ) < x ^ b := Real.rpow_pos_of_pos hx0 b
  have hkey : K * x ^ (-(b - a)) < L := by
    calc K * x ^ (-(b - a)) < K * (L / (2 * K)) := mul_lt_mul_of_pos_left hxlt hK
      _ = L / 2 := by field_simp
      _ < L := by linarith
  calc K * x ^ a = (K * x ^ (-(b - a))) * x ^ b := by rw [hsplit]; ring
    _ < L * x ^ b := mul_lt_mul_of_pos_right hkey hxb

/-! ## The effective threshold -/

/-- **Effective Chebotarev lower bound.**  Suppose the counting function `π` is approximated by
a main term `M` of size at least `c·x^β` with an error at most `C·x^{(θ+β)/2}` for `x ≥ X₁`
(this is the shape of an error exponent `θ`, evaluated at `ε = (β-θ)/2`).  Then for every

  `x ≥ max X₁ ((2C/c)^{2/(β-θ)})`

one already has `π x ≥ (c/2)·x^β`.  The threshold is completely explicit in the implied
constant `C`, the main-term constant `c` and the gap `β - θ`. -/
theorem effective_lower_bound {π M : ℝ → ℝ} {θ β c C X₁ : ℝ}
    (hc : 0 < c) (hC : 0 < C) (hθβ : θ < β) (hX₁ : 1 ≤ X₁)
    (hb : ∀ x ≥ X₁, |π x - M x| ≤ C * x ^ ((θ + β) / 2))
    (hM : ∀ x ≥ X₁, c * x ^ β ≤ M x) :
    ∀ x ≥ max X₁ ((2 * C / c) ^ (2 / (β - θ))), (c / 2) * x ^ β ≤ π x := by
  intro x hx
  have hxX₁ : X₁ ≤ x := le_trans (le_max_left _ _) hx
  have hxthr : (2 * C / c) ^ (2 / (β - θ)) ≤ x := le_trans (le_max_right _ _) hx
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le zero_lt_one (le_trans hX₁ hxX₁)
  set δ : ℝ := (β - θ) / 2 with hδdef
  have hδ : 0 < δ := by simp only [hδdef]; linarith
  have hAδ : (2 * C / c) ≤ x ^ δ := by
    refine rpow_le_rpow_of_le_rpow_inv (by positivity) hδ ?_
    have hone : (1 : ℝ) / δ = 2 / (β - θ) := by
      simp only [hδdef]
      rw [one_div, inv_div]
    rw [hone]; exact hxthr
  -- the error is at most half the main term
  have hsplit : x ^ β = x ^ ((θ + β) / 2) * x ^ δ := by
    rw [← Real.rpow_add hx0]
    congr 1
    simp only [hδdef]; ring
  have hxmid : (0 : ℝ) < x ^ ((θ + β) / 2) := Real.rpow_pos_of_pos hx0 _
  have hCd : C ≤ (c / 2) * x ^ δ := by
    have h4 : (c / 2) * (2 * C / c) ≤ (c / 2) * x ^ δ :=
      mul_le_mul_of_nonneg_left hAδ (by positivity)
    have h5 : (c / 2) * (2 * C / c) = C := by field_simp
    linarith
  have herr : C * x ^ ((θ + β) / 2) ≤ (c / 2) * x ^ β := by
    rw [hsplit]
    calc C * x ^ ((θ + β) / 2) ≤ ((c / 2) * x ^ δ) * x ^ ((θ + β) / 2) :=
          mul_le_mul_of_nonneg_right hCd hxmid.le
      _ = (c / 2) * (x ^ ((θ + β) / 2) * x ^ δ) := by ring
  have h1 : |π x - M x| ≤ C * x ^ ((θ + β) / 2) := hb x hxX₁
  have h2 : c * x ^ β ≤ M x := hM x hxX₁
  have h3 : M x - π x ≤ C * x ^ ((θ + β) / 2) := by
    have := abs_le.mp h1
    linarith [this.1]
  linarith

/-- Beyond the explicit threshold the counting function is positive: an effective bound for the
*least* geodesic in a given conjugacy class. -/
theorem effective_positivity {π M : ℝ → ℝ} {θ β c C X₁ : ℝ}
    (hc : 0 < c) (hC : 0 < C) (hθβ : θ < β) (hX₁ : 1 ≤ X₁)
    (hb : ∀ x ≥ X₁, |π x - M x| ≤ C * x ^ ((θ + β) / 2))
    (hM : ∀ x ≥ X₁, c * x ^ β ≤ M x) :
    ∀ x ≥ max X₁ ((2 * C / c) ^ (2 / (β - θ))), 0 < π x := by
  intro x hx
  have hx0 : (0 : ℝ) < x :=
    lt_of_lt_of_le zero_lt_one (le_trans hX₁ (le_trans (le_max_left _ _) hx))
  have hpos : (0 : ℝ) < (c / 2) * x ^ β := by positivity
  linarith [effective_lower_bound hc hC hθβ hX₁ hb hM x hx]

/-- From an abstract error exponent one extracts an effective threshold. -/
theorem exists_effective_threshold {π M : ℝ → ℝ} {θ β c : ℝ}
    (h : HasErrorExponent π M θ) (hc : 0 < c) (hθβ : θ < β)
    (hM : ∀ᶠ x in atTop, c * x ^ β ≤ M x) :
    ∃ X₀ ≥ (1 : ℝ), ∀ x ≥ X₀, (c / 2) * x ^ β ≤ π x := by
  obtain ⟨C, hC, X, hX, hb⟩ := h ((β - θ) / 2) (by linarith)
  obtain ⟨X', hX'⟩ := eventually_atTop.mp hM
  set X₁ : ℝ := max (max X X') 1 with hX₁def
  have hX₁ : 1 ≤ X₁ := le_max_right _ _
  have hb' : ∀ x ≥ X₁, |π x - M x| ≤ C * x ^ ((θ + β) / 2) := by
    intro x hx
    have : X ≤ x := le_trans (le_trans (le_max_left _ _) (le_max_left _ _)) hx
    have hbx := hb x this
    have he : θ + (β - θ) / 2 = (θ + β) / 2 := by ring
    rwa [he] at hbx
  have hM' : ∀ x ≥ X₁, c * x ^ β ≤ M x := by
    intro x hx
    exact hX' x (le_trans (le_trans (le_max_right _ _) (le_max_left _ _)) hx)
  refine ⟨max X₁ ((2 * C / c) ^ (2 / (β - θ))), le_trans hX₁ (le_max_left _ _), ?_⟩
  exact effective_lower_bound hc hC hθβ hX₁ hb' hM'

/-- **The numerical instance of the paper.**  With the exponent `θ = 25/36` and a main term of
size `c·x` (the size of `li x` up to logarithms), the error exponent evaluated at
`ε = 11/72` is `61/72`, and the effective threshold is `(2C/c)^{72/11}`. -/
theorem effective_lower_bound_25_36 {π M : ℝ → ℝ} {c C X₁ : ℝ}
    (hc : 0 < c) (hC : 0 < C) (hX₁ : 1 ≤ X₁)
    (hb : ∀ x ≥ X₁, |π x - M x| ≤ C * x ^ ((61 : ℝ) / 72))
    (hM : ∀ x ≥ X₁, c * x ^ (1 : ℝ) ≤ M x) :
    ∀ x ≥ max X₁ ((2 * C / c) ^ ((72 : ℝ) / 11)), (c / 2) * x ^ (1 : ℝ) ≤ π x := by
  have e₁ : ((25 : ℝ) / 36 + 1) / 2 = 61 / 72 := by norm_num
  have e₂ : (2 : ℝ) / (1 - 25 / 36) = 72 / 11 := by norm_num
  have key := effective_lower_bound (π := π) (M := M) (θ := 25 / 36) (β := 1)
    hc hC (by norm_num) hX₁ (by rwa [e₁]) hM
  rwa [e₂] at key

/-! ## Gaps: every window contains a new geodesic -/

/-- **Quantitative gap statement.**  If `π` has main term exactly `c·x^β` with error exponent
`θ < β`, then for every dilation factor `λ > 1` the window `[x, λx]` eventually contains a new
point counted by `π`: `π x < π (λ x)` for all large `x`.  Applied to a Chebotarev class counting
function this says that the geodesics in a fixed conjugacy class are eventually distributed with
*multiplicative gaps tending to 1*, a genuine strengthening of "infinitely many". -/
theorem eventually_lt_of_window {π : ℝ → ℝ} {θ β c lam : ℝ}
    (h : HasErrorExponent π (fun x => c * x ^ β) θ) (hc : 0 < c) (hβ : 0 < β) (hθβ : θ < β)
    (hlam : 1 < lam) :
    ∀ᶠ x in atTop, π x < π (lam * x) := by
  set ε : ℝ := (β - θ) / 2 with hεdef
  have hε : 0 < ε := by simp only [hεdef]; linarith
  set θ' : ℝ := θ + ε with hθ'def
  have hθ'β : θ' < β := by simp only [hθ'def, hεdef]; linarith
  obtain ⟨C, hC, X, hX, hb⟩ := h ε hε
  have hlam0 : (0 : ℝ) < lam := lt_trans zero_lt_one hlam
  have hlamβ : 1 < lam ^ β := Real.one_lt_rpow_iff_of_pos hlam0 |>.mpr (Or.inl ⟨hlam, hβ⟩)
  have hlamθ' : (0 : ℝ) < lam ^ θ' := Real.rpow_pos_of_pos hlam0 _
  have hdom := eventually_rpow_lt_rpow (a := θ') (b := β)
    (K := C * (lam ^ θ' + 1)) (L := c * (lam ^ β - 1)) hθ'β (by positivity) (by nlinarith)
  filter_upwards [hdom, eventually_ge_atTop X, eventually_ge_atTop (max X 1),
    eventually_gt_atTop (0 : ℝ)] with x hx hxX hxX1 hx0
  have hlamx : X ≤ lam * x := by nlinarith [le_trans (le_max_left X 1) hxX1]
  have h1 := hb x hxX
  have h2 := hb (lam * x) hlamx
  have e1 : (lam * x) ^ β = lam ^ β * x ^ β := Real.mul_rpow hlam0.le hx0.le
  have e2 : (lam * x) ^ θ' = lam ^ θ' * x ^ θ' := Real.mul_rpow hlam0.le hx0.le
  have hup : π x ≤ c * x ^ β + C * x ^ θ' := by
    have := abs_le.mp h1
    linarith [this.2]
  have hlow : c * (lam * x) ^ β - C * (lam * x) ^ θ' ≤ π (lam * x) := by
    have := abs_le.mp h2
    linarith [this.1]
  rw [e1, e2] at hlow
  -- combine: the gain `c(λ^β - 1)x^β` beats the two errors
  nlinarith [hx, hlow, hup, Real.rpow_pos_of_pos hx0 β, Real.rpow_pos_of_pos hx0 θ']

/-- The gap statement for the exponent `25/36` of the paper, applied to the counting function of
a single conjugacy class with positive density `δ_C` and main term `δ_C · c · x^β`. -/
theorem chebotarev_class_window_25_36 {piC : ℝ → ℝ} {d c β lam : ℝ}
    (hd : 0 < d) (hc : 0 < c) (hβ : 25 / 36 < β) (hlam : 1 < lam)
    (h : HasErrorExponent piC (fun x => (d * c) * x ^ β) (25 / 36)) :
    ∀ᶠ x in atTop, piC x < piC (lam * x) :=
  eventually_lt_of_window h (by positivity) (by linarith) hβ hlam

end ChebotarevGeodesic