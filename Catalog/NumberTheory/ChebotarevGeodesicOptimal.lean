/-
# The optimal exponent in the prime geodesic / Chebotarev geodesic theorem

Second research cycle on top of `Shared.ChebotarevGeodesic` and
`Shared.ChebotarevGeodesicSharpness`.

Papers on the prime geodesic theorem are a history of successive numerical exponents
(`3/4`, `35/48`, `7/10`, `71/102`, `25/36`, …).  This file makes the notion of "the exponent
of a counting function" a *bona fide* real number and proves that it behaves as one expects:

* `exponentSet π M` — the set of admissible exponents — is an **upper set** and is **closed
  from below**: `hasErrorExponent_of_forall_gt` shows that if every `θ' > θ` works, then `θ`
  itself works.  This is the (slightly surprising) reason the `ε` in "`25/36 + ε`" can never
  be removed by a limiting argument alone, yet the *exponent* `25/36` is attained.
* Consequently `exponentSet π M = Ici (optimalExponent π M)` whenever it is non-empty and
  bounded below (`exponentSet_eq_Ici`), so there is a genuine **optimal exponent**, and it is
  attained (`hasErrorExponent_optimalExponent`).
* The record chain becomes a chain of inequalities for one real number:
  `optimalExponent ≤ 25/36` (`optimalExponent_le_of_hasErrorExponent`).
* A logarithmic form of the estimate (`log_abs_error_le`), which is the shape in which the
  exponent is usually extracted numerically, and a lower bound for the optimal exponent
  coming from genuine oscillation of the error term (`le_optimalExponent_of_growth`).
-/

import Mathlib
import Catalog.Shared.ChebotarevGeodesic
import Catalog.Shared.ChebotarevGeodesicSharpness

open Filter Set
open scoped Topology

namespace ChebotarevGeodesic

variable {π M : ℝ → ℝ} {θ : ℝ}

/-! ## Closure of the exponent set from below -/

/-- **The exponent set is closed from below.**  If every exponent strictly larger than `θ`
is admissible, then `θ` itself is admissible.  (The point is that the definition already
carries an `ε`; a diagonal argument in `ε` does the rest.) -/
theorem hasErrorExponent_of_forall_gt (h : ∀ θ' > θ, HasErrorExponent π M θ') :
    HasErrorExponent π M θ := by
  intro ε hε
  obtain ⟨C, hC, X, hX, hb⟩ := h (θ + ε / 2) (by linarith) (ε / 2) (by linarith)
  refine ⟨C, hC, X, hX, fun x hx => ?_⟩
  have := hb x hx
  have heq : θ + ε / 2 + ε / 2 = θ + ε := by ring
  rwa [heq] at this

/-- The set of admissible error exponents of the pair `(π, M)`. -/
def exponentSet (π M : ℝ → ℝ) : Set ℝ := {θ | HasErrorExponent π M θ}

theorem mem_exponentSet_iff : θ ∈ exponentSet π M ↔ HasErrorExponent π M θ := Iff.rfl

/-- The exponent set is an upper set. -/
theorem isUpperSet_exponentSet : IsUpperSet (exponentSet π M) := fun _ _ hle h => h.mono hle

/-! ## The optimal exponent -/

/-- The optimal (infimal, and by `hasErrorExponent_optimalExponent` attained) exponent. -/
noncomputable def optimalExponent (π M : ℝ → ℝ) : ℝ := sInf (exponentSet π M)

variable (π M)

/-- If some exponent works and the exponent set is bounded below, then the optimal exponent
is itself admissible: the infimum is attained. -/
theorem hasErrorExponent_optimalExponent (hne : (exponentSet π M).Nonempty) :
    HasErrorExponent π M (optimalExponent π M) := by
  refine hasErrorExponent_of_forall_gt fun θ' hθ' => ?_
  obtain ⟨θ'', hmem, hlt⟩ := Real.lt_sInf_add_pos hne
    (show 0 < θ' - optimalExponent π M by
      simpa [optimalExponent] using sub_pos.mpr hθ')
  have : θ'' < θ' := by
    have : θ'' < sInf (exponentSet π M) + (θ' - optimalExponent π M) := hlt
    simpa [optimalExponent] using this
  exact (hmem : HasErrorExponent π M θ'').mono this.le

/-- **Structure of the exponent set.**  It is exactly the closed half-line above the optimal
exponent. -/
theorem exponentSet_eq_Ici (hne : (exponentSet π M).Nonempty)
    (hbd : BddBelow (exponentSet π M)) :
    exponentSet π M = Ici (optimalExponent π M) := by
  ext θ
  constructor
  · intro hθ
    exact csInf_le hbd hθ
  · intro hθ
    exact (hasErrorExponent_optimalExponent π M hne).mono hθ

variable {π M}

/-- Any admissible exponent bounds the optimal one; in particular the theorem of the paper
gives `optimalExponent ≤ 25/36`. -/
theorem optimalExponent_le_of_hasErrorExponent (hbd : BddBelow (exponentSet π M))
    (h : HasErrorExponent π M θ) : optimalExponent π M ≤ θ :=
  csInf_le hbd h

/-- The formal counterpart of "the prime geodesic theorem holds with exponent `25/36 + ε`":
the optimal exponent is at most `25/36`, hence also at most every earlier record. -/
theorem optimalExponent_le_25_36 (hbd : BddBelow (exponentSet π M))
    (h : HasErrorExponent π M (25 / 36)) :
    optimalExponent π M ≤ 25 / 36 ∧ optimalExponent π M ≤ 71 / 102 ∧
      optimalExponent π M ≤ 7 / 10 ∧ optimalExponent π M ≤ 3 / 4 := by
  have h0 := optimalExponent_le_of_hasErrorExponent hbd h
  refine ⟨h0, ?_, ?_, ?_⟩ <;> linarith [h0, (by norm_num : (25:ℝ)/36 < 71/102),
    (by norm_num : (25:ℝ)/36 < 7/10), (by norm_num : (25:ℝ)/36 < 3/4)]

/-! ## Logarithmic form -/

/-- Logarithmic form of an error estimate: for every `θ' > θ` one eventually has
`log |π x − M x| ≤ θ' · log x`.  This is how an exponent is read off numerically. -/
theorem log_abs_error_le (h : HasErrorExponent π M θ) (hθ : 0 ≤ θ) {θ' : ℝ} (hθ' : θ < θ') :
    ∀ᶠ x in atTop, Real.log |π x - M x| ≤ θ' * Real.log x := by
  set ε := (θ' - θ) / 2 with hεdef
  have hε : 0 < ε := by rw [hεdef]; linarith
  obtain ⟨C, hC, X, hX, hb⟩ := h ε hε
  have hCsmall : ∀ᶠ x in atTop, Real.log C ≤ ((θ' - θ - ε)) * Real.log x := by
    have hpos : 0 < θ' - θ - ε := by rw [hεdef]; linarith
    have hlog : Tendsto (fun x : ℝ => (θ' - θ - ε) * Real.log x) atTop atTop :=
      Filter.Tendsto.const_mul_atTop hpos Real.tendsto_log_atTop
    exact hlog.eventually_ge_atTop (Real.log C)
  filter_upwards [eventually_ge_atTop X, eventually_ge_atTop (1:ℝ), hCsmall]
    with x hxX hx1 hxC
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx1
  have hbound := hb x hxX
  have hlogx : 0 ≤ Real.log x := Real.log_nonneg hx1
  rcases eq_or_lt_of_le (abs_nonneg (π x - M x)) with hz | hz
  · rw [← hz]
    simpa using mul_nonneg (by linarith : (0:ℝ) ≤ θ') hlogx
  · have h1 : Real.log |π x - M x| ≤ Real.log (C * x ^ (θ + ε)) :=
      Real.log_le_log hz hbound
    have h2 : Real.log (C * x ^ (θ + ε)) = Real.log C + (θ + ε) * Real.log x := by
      rw [Real.log_mul (ne_of_gt hC) (ne_of_gt (Real.rpow_pos_of_pos hx0 _)),
        Real.log_rpow hx0]
    rw [h2] at h1
    calc Real.log |π x - M x| ≤ Real.log C + (θ + ε) * Real.log x := h1
      _ ≤ (θ' - θ - ε) * Real.log x + (θ + ε) * Real.log x := by linarith
      _ = θ' * Real.log x := by ring

/-! ## Lower bounds for the optimal exponent -/

/-- Genuine oscillation of size `x^β` forces the optimal exponent to be at least `β`:
no analytic improvement below `β` is possible.  Combined with
`optimalExponent_le_of_hasErrorExponent` this brackets the true exponent. -/
theorem le_optimalExponent_of_growth {β c : ℝ} (hc : 0 < c)
    (hne : (exponentSet π M).Nonempty)
    (hgrow : ∀ x ≥ (1 : ℝ), c * x ^ β ≤ |π x - M x|) :
    β ≤ optimalExponent π M := by
  by_contra hlt
  push_neg at hlt
  exact not_hasErrorExponent_of_growth hc hlt hgrow
    (hasErrorExponent_optimalExponent π M hne)

/-- **Bracketing the exponent.**  If the error term is genuinely of size `x^β` and also
`O(x^{β+ε})` for all `ε > 0`, then the optimal exponent equals `β`. -/
theorem optimalExponent_eq_of_growth {β c : ℝ} (hc : 0 < c)
    (hbd : BddBelow (exponentSet π M))
    (hgrow : ∀ x ≥ (1 : ℝ), c * x ^ β ≤ |π x - M x|)
    (hupper : HasErrorExponent π M β) :
    optimalExponent π M = β := by
  have hne : (exponentSet π M).Nonempty := ⟨β, hupper⟩
  exact le_antisymm (optimalExponent_le_of_hasErrorExponent hbd hupper)
    (le_optimalExponent_of_growth hc hne hgrow)

/-! ## A computed optimal exponent -/

/-- For the pure power error term `x^β` the machinery computes the optimal exponent exactly:
it is `β`.  In particular the framework is non-vacuous and the numeral `25/36` is realized as
an actual optimal exponent (see `optimalExponent_25_36_realized`). -/
theorem optimalExponent_rpow (β : ℝ) :
    optimalExponent (fun x => x ^ β) (fun _ => 0) = β := by
  have hgrow : ∀ x ≥ (1 : ℝ), 1 * x ^ β ≤ |x ^ β - 0| := by
    intro x hx
    have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx
    have : (0 : ℝ) ≤ x ^ β := (Real.rpow_pos_of_pos hx0 β).le
    simp [abs_of_nonneg this]
  have hupper : HasErrorExponent (fun x => x ^ β) (fun _ => 0) β := by
    intro ε hε
    refine ⟨1, one_pos, 1, le_rfl, fun x hx => ?_⟩
    have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx
    have hle : x ^ β ≤ x ^ (β + ε) :=
      Real.rpow_le_rpow_of_exponent_le hx (by linarith)
    have hpos : (0 : ℝ) ≤ x ^ β := (Real.rpow_pos_of_pos hx0 β).le
    simpa [abs_of_nonneg hpos] using hle
  have hbd : BddBelow (exponentSet (fun x => x ^ β) (fun _ => 0)) := by
    refine ⟨β, fun θ hθ => ?_⟩
    by_contra hlt
    push_neg at hlt
    exact not_hasErrorExponent_of_growth one_pos hlt hgrow hθ
  exact optimalExponent_eq_of_growth one_pos hbd hgrow hupper

/-- The record exponent of the paper is realized as a genuine optimal exponent. -/
theorem optimalExponent_25_36_realized :
    optimalExponent (fun x : ℝ => x ^ ((25 : ℝ) / 36)) (fun _ => 0) = 25 / 36 :=
  optimalExponent_rpow _

end ChebotarevGeodesic