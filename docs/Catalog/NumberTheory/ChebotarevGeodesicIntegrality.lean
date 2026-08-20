/-
# Integrality forces a non-negative optimal exponent

Continuation of `Shared.ChebotarevGeodesic`, `Shared.ChebotarevGeodesicOptimal` and
`Shared.ChebotarevGeodesicTorus`.

A geodesic counting function is *integer valued*, whereas the main terms occurring in the
prime geodesic and Chebotarev geodesic theorems (`li x`, `c·x^β`, `log x / (2 log ε)`, …) are
*continuous* and *unbounded*.  This file shows that this clash alone already forbids any
negative error exponent:

* `not_hasErrorExponent_of_intValued` : if `π` takes only integer values and `M` is continuous
  on `[1, ∞)` and tends to `+∞`, then `HasErrorExponent π M θ` fails for every `θ < 0`.
  The proof is an intermediate-value argument: choose `u` beyond which the error is `< 1/4`,
  use continuity of `M` to find `v ≥ u` with `M v = M u + 1/2`, and observe that
  `(π v - π u) - 1/2` is at distance `≥ 1/2` from `0` because `π v - π u ∈ ℤ`, while the two
  error bounds force it to be `< 1/2`.
* `optimalExponent_eq_zero_of_intValued` : consequently, an integer valued counting function
  with a bounded error has optimal exponent exactly `0`.
* `optimalExponent_torusFamily` : **conjecture C2 of `FUTURE_DIRECTIONS.md`.**  Every finite
  superposition of single-torus Chebotarev counting functions has optimal error exponent
  exactly `0`.  Hence the positive exponent `25/36` of the paper cannot be produced by any
  *finite* family of tori: it is a genuinely infinite (class-number) phenomenon.
* `le_optimalExponent_of_intValued` : for any integer valued counting function with continuous
  unbounded main term, `0 ≤ optimalExponent π M`; in particular no future improvement of the
  prime geodesic exponent can go below `0`.
-/

import Mathlib
import Catalog.Shared.ChebotarevGeodesic
import Catalog.Shared.ChebotarevGeodesicOptimal
import Catalog.Shared.ChebotarevGeodesicTorus

open Filter Set
open scoped Topology

namespace ChebotarevGeodesic

/-! ## The integrality obstruction -/

/-- **Integrality obstruction.**  An integer valued counting function cannot approximate a
continuous, unbounded main term with a *negative* error exponent. -/
theorem not_hasErrorExponent_of_intValued {pi M : ℝ → ℝ} {θ : ℝ} (hθ : θ < 0)
    (hint : ∀ x, ∃ k : ℤ, pi x = (k : ℝ))
    (hcont : ContinuousOn M (Set.Ici (1 : ℝ)))
    (hlim : Tendsto M atTop atTop) :
    ¬ HasErrorExponent pi M θ := by
  intro h
  obtain ⟨C, hC, X, hX, hb⟩ := h (-θ / 2) (by linarith)
  have hexp : θ + -θ / 2 = θ / 2 := by ring
  have htend : Tendsto (fun x : ℝ => C * x ^ (θ / 2)) atTop (𝓝 0) := by
    have h0 : Tendsto (fun x : ℝ => x ^ (θ / 2)) atTop (𝓝 0) := by
      have he : θ / 2 = -(-(θ / 2)) := by ring
      rw [he]
      exact tendsto_rpow_neg_atTop (by linarith)
    simpa using h0.const_mul C
  have hev : ∀ᶠ x : ℝ in atTop, C * x ^ (θ / 2) < 1 / 4 :=
    htend.eventually (gt_mem_nhds (by norm_num))
  obtain ⟨U, hU⟩ := eventually_atTop.mp
    (hev.and ((eventually_ge_atTop X).and (eventually_ge_atTop (1 : ℝ))))
  set u : ℝ := max U 1 with hudef
  have huU : U ≤ u := le_max_left _ _
  have hu1 : (1 : ℝ) ≤ u := le_max_right _ _
  -- a point where the main term has grown by exactly `1/2`
  obtain ⟨w, hw1, hw2⟩ := ((hlim.eventually_ge_atTop (M u + 1 / 2)).and
    (eventually_ge_atTop u)).exists
  have hcontuw : ContinuousOn M (Set.Icc u w) :=
    hcont.mono (fun z hz => le_trans hu1 hz.1)
  have hsub := intermediate_value_Icc hw2 hcontuw
  have hmem : M u + 1 / 2 ∈ Set.Icc (M u) (M w) := ⟨by linarith, hw1⟩
  obtain ⟨v, hvmem, hv⟩ := hsub hmem
  have hbu : |pi u - M u| < 1 / 4 := by
    obtain ⟨h1, h2, h3⟩ := hU u huU
    have hbb := hb u h2
    rw [hexp] at hbb
    linarith
  have hbv : |pi v - M v| < 1 / 4 := by
    obtain ⟨h1, h2, h3⟩ := hU v (le_trans huU hvmem.1)
    have hbb := hb v h2
    rw [hexp] at hbb
    linarith
  obtain ⟨k1, hk1⟩ := hint u
  obtain ⟨k2, hk2⟩ := hint v
  -- `(π v - π u) - 1/2` is both `< 1/2` and `≥ 1/2` in absolute value
  have hkey : |((k2 - k1 : ℤ) : ℝ) - 1 / 2| < 1 / 2 := by
    have h1 := abs_lt.mp hbu
    have h2 := abs_lt.mp hbv
    rw [hk1] at h1
    rw [hk2] at h2
    rw [abs_lt]
    push_cast
    constructor <;> linarith [h1.1, h1.2, h2.1, h2.2]
  have hfar : (1 : ℝ) / 2 ≤ |((k2 - k1 : ℤ) : ℝ) - 1 / 2| := by
    rcases le_or_gt (k2 - k1) 0 with hk | hk
    · have hle : ((k2 - k1 : ℤ) : ℝ) ≤ 0 := by exact_mod_cast hk
      rw [abs_of_nonpos (by linarith)]
      linarith
    · have hge : (1 : ℝ) ≤ ((k2 - k1 : ℤ) : ℝ) := by exact_mod_cast hk
      rw [abs_of_nonneg (by linarith)]
      linarith
  linarith

/-- The optimal exponent of an integer valued counting function with continuous unbounded main
term is `≥ 0`. -/
theorem le_optimalExponent_of_intValued {pi M : ℝ → ℝ}
    (hint : ∀ x, ∃ k : ℤ, pi x = (k : ℝ))
    (hcont : ContinuousOn M (Set.Ici (1 : ℝ)))
    (hlim : Tendsto M atTop atTop)
    (hne : (exponentSet pi M).Nonempty) :
    0 ≤ optimalExponent pi M := by
  refine le_csInf hne fun θ hθ => ?_
  by_contra hlt
  exact not_hasErrorExponent_of_intValued (lt_of_not_ge hlt) hint hcont hlim hθ

/-- **The exponent `0` is optimal for every integer valued counting function with a bounded
error.** -/
theorem optimalExponent_eq_zero_of_intValued {pi M : ℝ → ℝ}
    (hint : ∀ x, ∃ k : ℤ, pi x = (k : ℝ))
    (hcont : ContinuousOn M (Set.Ici (1 : ℝ)))
    (hlim : Tendsto M atTop atTop)
    (h0 : HasErrorExponent pi M 0) :
    optimalExponent pi M = 0 := by
  have hmem : (0 : ℝ) ∈ exponentSet pi M := h0
  have hbdd : BddBelow (exponentSet pi M) := by
    refine ⟨0, fun θ hθ => ?_⟩
    by_contra hlt
    exact not_hasErrorExponent_of_intValued (lt_of_not_ge hlt) hint hcont hlim hθ
  exact le_antisymm (csInf_le hbdd hmem)
    (le_optimalExponent_of_intValued hint hcont hlim ⟨0, hmem⟩)

/-! ## Application: finite families of non-split tori -/

/-- The main term of a finite family of tori is a positive multiple of `log`. -/
theorem torusFamily_main_eq {ι : Type*} (s : Finset ι) (e : ι → ℝ) {m : ℕ} (x : ℝ) :
    ∑ i ∈ s, (1 / (m : ℝ)) * (Real.log x / (2 * Real.log (e i)))
      = (∑ i ∈ s, (1 / (m : ℝ)) * (1 / (2 * Real.log (e i)))) * Real.log x := by
  rw [Finset.sum_mul]
  refine Finset.sum_congr rfl fun i _ => ?_
  ring

/-- The coefficient of `log x` in the main term of a non-empty family of tori is positive. -/
theorem torusFamily_coeff_pos {ι : Type*} {s : Finset ι} {e : ι → ℝ} {m : ℕ}
    (hs : s.Nonempty) (he : ∀ i ∈ s, 1 < e i) (hm : 0 < m) :
    0 < ∑ i ∈ s, (1 / (m : ℝ)) * (1 / (2 * Real.log (e i))) := by
  have hm0 : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  refine Finset.sum_pos (fun i hi => ?_) hs
  have hlog : 0 < Real.log (e i) := Real.log_pos (he i hi)
  positivity

/-- **Conjecture C2, proved.**  A finite superposition of single-torus Chebotarev counting
functions has optimal error exponent exactly `0`: the positive exponents appearing in the
literature (`25/36`, …) are created by the *infinitude* of the family of tori, never by any
finite subfamily. -/
theorem optimalExponent_torusFamily {ι : Type*} {s : Finset ι} {e : ι → ℝ} {m : ℕ} (a : ι → ℕ)
    (hs : s.Nonempty) (he : ∀ i ∈ s, 1 < e i) (hm : 0 < m) :
    optimalExponent (fun x => ∑ i ∈ s, (torusClassCount (e i) m (a i) x : ℝ))
      (fun x => ∑ i ∈ s, (1 / (m : ℝ)) * (Real.log x / (2 * Real.log (e i)))) = 0 := by
  set c : ℝ := ∑ i ∈ s, (1 / (m : ℝ)) * (1 / (2 * Real.log (e i))) with hcdef
  have hc : 0 < c := torusFamily_coeff_pos hs he hm
  have hMeq : (fun x => ∑ i ∈ s, (1 / (m : ℝ)) * (Real.log x / (2 * Real.log (e i))))
      = fun x => c * Real.log x := by
    funext x
    rw [hcdef]
    exact torusFamily_main_eq s e x
  refine optimalExponent_eq_zero_of_intValued ?_ ?_ ?_ ?_
  · intro x
    exact ⟨∑ i ∈ s, (torusClassCount (e i) m (a i) x : ℤ), by push_cast; ring⟩
  · rw [hMeq]
    refine continuousOn_const.mul (Real.continuousOn_log.mono fun z hz => ?_)
    have : (1 : ℝ) ≤ z := hz
    simp only [Set.mem_compl_iff, Set.mem_singleton_iff]
    intro hz0
    rw [hz0] at this
    linarith
  · rw [hMeq]
    exact Real.tendsto_log_atTop.const_mul_atTop hc
  · exact hasErrorExponent_torusFamily s e a he hm

/-- The same statement for a single torus: it recovers `optimalExponent_torusCount` from a
structural principle rather than from an explicit test sequence. -/
theorem optimalExponent_torusCount_of_intValued {e : ℝ} (he : 1 < e) :
    optimalExponent (fun x => (torusCount e x : ℝ))
      (fun x => Real.log x / (2 * Real.log e)) = 0 := by
  have hlog : 0 < Real.log e := Real.log_pos he
  have hMeq : (fun x => Real.log x / (2 * Real.log e))
      = fun x => (1 / (2 * Real.log e)) * Real.log x := by
    funext x; ring
  refine optimalExponent_eq_zero_of_intValued ?_ ?_ ?_ (hasErrorExponent_torusCount he)
  · intro x
    exact ⟨(torusCount e x : ℤ), by push_cast; ring⟩
  · rw [hMeq]
    refine continuousOn_const.mul (Real.continuousOn_log.mono fun z hz => ?_)
    have hz1 : (1 : ℝ) ≤ z := hz
    simp only [Set.mem_compl_iff, Set.mem_singleton_iff]
    intro hz0
    rw [hz0] at hz1
    linarith
  · rw [hMeq]
    exact Real.tendsto_log_atTop.const_mul_atTop (by positivity)

end ChebotarevGeodesic