/-
# The density statement: geodesics with Frobenius in a prescribed set of classes

Third research cycle on top of `Shared.ChebotarevGeodesic`.

The *density* form of the Chebotarev geodesic theorem asserts that the proportion of primitive
closed geodesics whose Frobenius class lies in a prescribed union `S` of conjugacy classes
tends to `∑_{C ∈ S} |C|/|G|`.  This file derives that statement from the *asymptotic* form
proved (in the paper, analytically; here, axiom-free from the framework) for each class,
under the only extra hypotheses that the main term `li` really grows like a positive power
`x^β` with `β` exceeding the error exponent — which is the case in the geodesic setting, where
`li(x) ≍ x/log x` and `θ = 25/36 < 1`.

Main results:

* `tendsto_ratio_one_of_hasErrorExponent` — an error exponent below the growth exponent of the
  main term forces `π/M → 1`;
* `chebotarev_subset` — the asymptotic for a union of classes;
* `chebotarev_natural_density` — the density statement:
  `π_S(x)/π(x) → ∑_{C ∈ S} |C|/|G|`.
-/

import Mathlib
import Catalog.Shared.ChebotarevGeodesic

open Finset Filter
open scoped Topology

namespace ChebotarevGeodesic

/-! ## Ratio asymptotics -/

/-- If `π = M + O(x^{θ+ε})` and `M` grows at least like `c x^β` with `β > θ`, then
`π/M → 1`. -/
theorem tendsto_ratio_one_of_hasErrorExponent {π M : ℝ → ℝ} {θ β c : ℝ}
    (h : HasErrorExponent π M θ) (hc : 0 < c) (hθβ : θ < β)
    (hM : ∀ᶠ x in atTop, c * x ^ β ≤ M x) :
    Tendsto (fun x => π x / M x) atTop (𝓝 1) := by
  set ε := (β - θ) / 2 with hεdef
  have hε : 0 < ε := by rw [hεdef]; linarith
  obtain ⟨C, hC, X, hX, hb⟩ := h ε hε
  have hneg : 0 < β - (θ + ε) := by rw [hεdef]; linarith
  have hg : Tendsto (fun x : ℝ => (C / c) * x ^ (-(β - (θ + ε)))) atTop (𝓝 0) := by
    have h0 : Tendsto (fun x : ℝ => x ^ (-(β - (θ + ε)))) atTop (𝓝 0) :=
      tendsto_rpow_neg_atTop hneg
    simpa using h0.const_mul (C / c)
  have key : Tendsto (fun x => π x / M x - 1) atTop (𝓝 0) := by
    refine squeeze_zero_norm' ?_ hg
    filter_upwards [hM, eventually_ge_atTop X, eventually_gt_atTop (0:ℝ)]
      with x hMx hxX hx0
    have hxβ : (0 : ℝ) < x ^ β := Real.rpow_pos_of_pos hx0 β
    have hMpos : 0 < M x := lt_of_lt_of_le (by positivity) hMx
    have hb' : |π x - M x| ≤ C * x ^ (θ + ε) := hb x hxX
    have hnorm : ‖π x / M x - 1‖ = |π x - M x| / M x := by
      rw [Real.norm_eq_abs, div_sub_one (ne_of_gt hMpos), abs_div, abs_of_pos hMpos]
    rw [hnorm, div_le_iff₀ hMpos]
    have hstep : |π x - M x| ≤ C * x ^ (θ + ε) := hb'
    have hcx : C / c * x ^ (-(β - (θ + ε))) * (c * x ^ β) = C * x ^ (θ + ε) := by
      rw [show C / c * x ^ (-(β - (θ + ε))) * (c * x ^ β)
            = (C / c * c) * (x ^ (-(β - (θ + ε))) * x ^ β) by ring,
        ← Real.rpow_add hx0]
      rw [div_mul_cancel₀ C (ne_of_gt hc)]
      ring_nf
    have hmono : C / c * x ^ (-(β - (θ + ε))) * (c * x ^ β)
        ≤ C / c * x ^ (-(β - (θ + ε))) * M x := by
      refine mul_le_mul_of_nonneg_left hMx (by positivity)
    rw [hcx] at hmono
    linarith
  have := key.add_const 1
  simpa using this

/-! ## The density statement -/

section Density

variable (G : Type*) [Group G] [Fintype G] [DecidableEq G] [Fintype (ConjClasses G)]

open scoped Classical in
/-- Asymptotics for the geodesics whose Frobenius class lies in a prescribed set `S` of
conjugacy classes. -/
theorem chebotarev_subset (S : Finset (ConjClasses G)) (piC : ConjClasses G → ℝ → ℝ)
    (li : ℝ → ℝ) (θ : ℝ)
    (h : ∀ C, HasErrorExponent (piC C) (fun x => classDensity G C * li x) θ) :
    HasErrorExponent (fun x => ∑ C ∈ S, piC C x)
      (fun x => (∑ C ∈ S, classDensity G C) * li x) θ := by
  have hsum := HasErrorExponent.sum S piC (fun C x => classDensity G C * li x) θ
    (fun C _ => h C)
  have e : (fun x => ∑ C ∈ S, classDensity G C * li x)
      = fun x => (∑ C ∈ S, classDensity G C) * li x := by
    funext x
    rw [Finset.sum_mul]
  rwa [e] at hsum

open scoped Classical in
/-- **Chebotarev density theorem for geodesics.**  Under the class-wise asymptotics with
exponent `θ`, and assuming the main term grows like a power `x^β` with `β > θ` (true in the
geodesic setting, where `li(x) ≍ x/log x` and `θ = 25/36`), the proportion of geodesics with
Frobenius class in `S` tends to `∑_{C ∈ S} |C|/|G|`. -/
theorem chebotarev_natural_density (S : Finset (ConjClasses G)) (piC : ConjClasses G → ℝ → ℝ)
    (li : ℝ → ℝ) (θ β c : ℝ) (hc : 0 < c) (hθβ : θ < β)
    (hli : ∀ᶠ x in atTop, c * x ^ β ≤ li x)
    (hd : 0 < ∑ C ∈ S, classDensity G C)
    (h : ∀ C, HasErrorExponent (piC C) (fun x => classDensity G C * li x) θ) :
    Tendsto (fun x => (∑ C ∈ S, piC C x) / (∑ C : ConjClasses G, piC C x)) atTop
      (𝓝 (∑ C ∈ S, classDensity G C)) := by
  set d : ℝ := ∑ C ∈ S, classDensity G C with hddef
  -- numerator against `d * li`
  have hnum : Tendsto (fun x => (∑ C ∈ S, piC C x) / (d * li x)) atTop (𝓝 1) := by
    refine tendsto_ratio_one_of_hasErrorExponent (chebotarev_subset G S piC li θ h)
      (c := d * c) (by positivity) hθβ ?_
    filter_upwards [hli] with x hx
    have : d * (c * x ^ β) ≤ d * li x := mul_le_mul_of_nonneg_left hx hd.le
    calc d * c * x ^ β = d * (c * x ^ β) := by ring
      _ ≤ d * li x := this
  -- denominator against `li`
  have hden : Tendsto (fun x => (∑ C : ConjClasses G, piC C x) / li x) atTop (𝓝 1) :=
    tendsto_ratio_one_of_hasErrorExponent (prime_geodesic_of_chebotarev G piC li θ h) hc hθβ hli
  have hratio : Tendsto
      (fun x => d * ((∑ C ∈ S, piC C x) / (d * li x)) /
        ((∑ C : ConjClasses G, piC C x) / li x)) atTop (𝓝 (d * 1 / 1)) :=
    ((hnum.const_mul d).div hden one_ne_zero)
  have heq : ∀ᶠ x in atTop,
      d * ((∑ C ∈ S, piC C x) / (d * li x)) / ((∑ C : ConjClasses G, piC C x) / li x)
        = (∑ C ∈ S, piC C x) / (∑ C : ConjClasses G, piC C x) := by
    filter_upwards [hli, eventually_gt_atTop (0:ℝ)] with x hlix hx0
    have hxβ : (0 : ℝ) < x ^ β := Real.rpow_pos_of_pos hx0 β
    have hli0 : 0 < li x := lt_of_lt_of_le (by positivity) hlix
    field_simp
  have : Tendsto (fun x => (∑ C ∈ S, piC C x) / (∑ C : ConjClasses G, piC C x)) atTop
      (𝓝 (d * 1 / 1)) := hratio.congr' heq
  simpa using this

end Density

end ChebotarevGeodesic