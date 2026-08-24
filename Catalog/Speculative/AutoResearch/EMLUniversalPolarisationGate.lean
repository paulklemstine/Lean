/-
# The universal polarisation constant for even-generator product gates

This file closes the first open conjecture of the previous cycle's
`FUTURE_DIRECTIONS.md` ("Universal Quartic Constant for Even Activation Gates").

`Catalog/Bridges/EMLPolarisationSharpConstant.lean` proved, for the EML gate
`prodGate h x y = (S_h(x+y) − S_h(x−y))/4`, that

`sup_{[0,1]²} |prodGate h x y − x y| = coshGap(2h)/(4h²)`,

attained at the corner `(1,1)`, for every `h > 0`.  Inspecting that proof shows
that *nothing* in it uses the exponential.  The only inputs are:

* the exact polarisation identity, which holds for any generator of the form
  `g(t) = t² + gap t`; and
* the fact that `gap` is **even** and **monotone on `[0,∞)`** (equivalently:
  monotone in `|t|`, which holds whenever `gap` has non-negative Taylor
  coefficients and no constant or quadratic term).

This file makes that abstraction precise.  An `EvenGen` is a bundled remainder
`gap` with those three properties (`gap (-t) = gap t`, `gap 0 = 0`, monotone on
`Ici 0`); the associated generator is `G.toFun t = t² + G.gap t` and the
associated width-`4` polarisation gate is

`polGate G h x y = (G.toFun (h(x+y)) − G.toFun (h(x−y)))/(4h²)`.

## Main results

* `polGate_sub_eq`, `polGate_sub_eq_abs` — the exact error identity
  `polGate G h x y − x y = (gap(h(x+y)) − gap(h|x−y|))/(4h²)`.
* `polGate_error_nonneg` — every such gate is a *one-sided* approximant on the
  positive quadrant.
* `polGate_isGreatest` — **the universal corner theorem**: for every `h > 0` the
  maximum of `|polGate G h x y − x y|` over `[0,1]²` is attained at `(1,1)` and
  equals `G.gap (2h)/(4h²) = (G.toFun (2h) − 4h²)/(4h²)`.
* `polGate_sSup_asymptotic` — **the universal quartic constant**: if
  `|gap t − c t⁴| ≤ C t⁶` for `|t| ≤ 1`, then the supremum is `4c·h² + O(h⁴)`,
  with explicit remainder `16C·h⁴`.  The leading constant of *any* even-generator
  product gate is four times the quartic Taylor coefficient of its remainder.
* `polGate_sSup_mono` — pointwise domination of remainders is inherited by the
  suprema, so minimising `gap` (hence `c`) really is the design criterion.
* `emlGen`, `polGate_emlGen`, `eml_sSup_isGreatest`, `eml_sSup_asymptotic` — the
  EML gate is the instance `gap = coshGap`, with `c = 1/12`, recovering
  `4c = 1/3` and (as a by-product of the abstract machinery) the slightly sharper
  remainder `h⁴/22`.
* `quarticGen`, `quartic_sSup_exact`, `quartic_sSup_isGreatest` — the pure
  quartic generator `g(t) = t² + c t⁴` gives an *exact* supremum `4c h²` with no
  remainder at all: the `O(h⁴)` in the EML statement is caused entirely by the
  sextic and higher coefficients of `2 cosh`.
* `exactGen_error_zero` — the degenerate generator `g(t) = t²` (`c = 0`) computes
  the product exactly, so the family interpolates down to zero error.
* `negQuartic_*` — a **critic's boundary check**: dropping monotonicity of `gap`
  breaks the closed form.  For `g(t) = t² − t⁴` the corner formula returns the
  negative number `−4h²`, while the true maximum of the error is `+4h²`.  So the
  monotonicity hypothesis in `polGate_isGreatest` is load-bearing, not cosmetic.

Everything is proved from `import Mathlib` plus the two catalog files; no `sorry`.
-/
import Mathlib
import Applications.EMLDepthWidthTradeoff
import Bridges.EMLPolarisationSharpConstant

namespace EML.UniversalGate

open Real Set EML.DepthWidth EML.Polarisation

noncomputable section

/-! ## 1. Even generators -/

/-- An **even generator remainder**: an even function vanishing at `0` and
monotone on the non-negative half-line.  Any power series `Σ_{k≥2} c_{2k} t^{2k}`
with `c_{2k} ≥ 0` is one. -/
structure EvenGen where
  /-- The remainder of the generator after its quadratic part. -/
  gap : ℝ → ℝ
  /-- The remainder is even. -/
  gap_neg : ∀ t, gap (-t) = gap t
  /-- The remainder vanishes at the origin. -/
  gap_zero : gap 0 = 0
  /-- The remainder is monotone on `[0,∞)`. -/
  gap_mono : MonotoneOn gap (Ici (0:ℝ))

namespace EvenGen

variable (G : EvenGen)

/-- The generator itself: `g(t) = t² + gap t`. -/
def toFun (t : ℝ) : ℝ := t ^ 2 + G.gap t

theorem gap_abs (t : ℝ) : G.gap |t| = G.gap t := by
  rcases abs_choice t with h | h
  · rw [h]
  · rw [h, G.gap_neg]

theorem gap_le_of_le {s t : ℝ} (hs : 0 ≤ s) (hst : s ≤ t) : G.gap s ≤ G.gap t :=
  G.gap_mono (mem_Ici.mpr hs) (mem_Ici.mpr (hs.trans hst)) hst

theorem gap_nonneg (t : ℝ) : 0 ≤ G.gap t := by
  rw [← G.gap_abs]
  have h := G.gap_le_of_le (le_refl (0:ℝ)) (abs_nonneg t)
  rwa [G.gap_zero] at h

end EvenGen

/-- The **polarisation product gate** attached to an even generator. -/
def polGate (G : EvenGen) (h x y : ℝ) : ℝ :=
  (G.toFun (h * (x + y)) - G.toFun (h * (x - y))) / (4 * h ^ 2)

/-! ## 2. The exact error identity -/

/-- **Exact error identity.**  The quadratic part of the generator produces `x y`
exactly; the whole error is the polarised difference of the remainder. -/
theorem polGate_sub_eq (G : EvenGen) (h x y : ℝ) (hh : h ≠ 0) :
    polGate G h x y - x * y
      = (G.gap (h * (x + y)) - G.gap (h * (x - y))) / (4 * h ^ 2) := by
  simp only [polGate, EvenGen.toFun]
  field_simp
  ring

/-- The two polarisation arguments, normalised to `0 ≤ h|x−y| ≤ h(x+y)`. -/
theorem polGate_sub_eq_abs (G : EvenGen) (h x y : ℝ) (hh : 0 < h) :
    polGate G h x y - x * y
      = (G.gap (h * (x + y)) - G.gap (h * |x - y|)) / (4 * h ^ 2) := by
  rw [polGate_sub_eq G h x y hh.ne']
  congr 2
  rw [← G.gap_abs (h * (x - y)), abs_mul, abs_of_pos hh]

/-- **One-sided approximation.**  On the positive quadrant every even-generator
gate over-estimates the product, for every `h > 0`. -/
theorem polGate_error_nonneg (G : EvenGen) (h x y : ℝ) (hh0 : 0 < h)
    (hx : 0 ≤ x) (hy : 0 ≤ y) : 0 ≤ polGate G h x y - x * y := by
  rw [polGate_sub_eq_abs G h x y hh0]
  have habs : |x - y| ≤ x + y := abs_sub_le_iff.mpr ⟨by linarith, by linarith⟩
  have hmono : G.gap (h * |x - y|) ≤ G.gap (h * (x + y)) :=
    G.gap_le_of_le (by positivity) (by nlinarith)
  have h4 : (0:ℝ) < 4 * h ^ 2 := by positivity
  exact div_nonneg (by linarith) h4.le

/-! ## 3. The universal corner theorem -/

/-- The set of errors of a bivariate approximant over the unit square. -/
def errSetOf (F : ℝ → ℝ → ℝ) : Set ℝ :=
  (fun p : ℝ × ℝ => |F p.1 p.2 - p.1 * p.2|) '' (Icc (0:ℝ) 1 ×ˢ Icc (0:ℝ) 1)

theorem errSetOf_nonempty (F : ℝ → ℝ → ℝ) : (errSetOf F).Nonempty :=
  ⟨_, ⟨(0, 0), ⟨⟨le_refl 0, zero_le_one⟩, ⟨le_refl 0, zero_le_one⟩⟩, rfl⟩⟩

/-- The corner error in closed form. -/
theorem polGate_corner_value (G : EvenGen) (h : ℝ) (hh0 : 0 < h) :
    polGate G h 1 1 - 1 * 1 = G.gap (2 * h) / (4 * h ^ 2) := by
  have h1 : h * ((1:ℝ) + 1) = 2 * h := by ring
  have h2 : h * |(1:ℝ) - 1| = 0 := by norm_num
  rw [polGate_sub_eq_abs G h 1 1 hh0, h1, h2, G.gap_zero, sub_zero]

/-- **The corner dominates.**  Monotonicity of the remainder alone forces the
error to be maximal where `x + y` is maximal and `|x − y|` minimal. -/
theorem polGate_error_le_corner (G : EvenGen) (h x y : ℝ) (hh0 : 0 < h)
    (hx : x ∈ Icc (0:ℝ) 1) (hy : y ∈ Icc (0:ℝ) 1) :
    |polGate G h x y - x * y| ≤ G.gap (2 * h) / (4 * h ^ 2) := by
  obtain ⟨hx0, hx1⟩ := hx
  obtain ⟨hy0, hy1⟩ := hy
  rw [abs_of_nonneg (polGate_error_nonneg G h x y hh0 hx0 hy0),
    polGate_sub_eq_abs G h x y hh0]
  have hbranch : G.gap (h * (x + y)) ≤ G.gap (2 * h) :=
    G.gap_le_of_le (by positivity) (by nlinarith)
  have hrest : 0 ≤ G.gap (h * |x - y|) := G.gap_nonneg _
  have hnum : G.gap (h * (x + y)) - G.gap (h * |x - y|) ≤ G.gap (2 * h) := by linarith
  gcongr

/-- **Universal corner theorem.**  For *every* even generator and *every* `h > 0`,
the maximum of `|polGate G h x y − x y|` over `[0,1]²` is attained at the corner
`(1,1)` and equals `G.gap (2h)/(4h²) = (G.toFun (2h) − 4h²)/(4h²)`. -/
theorem polGate_isGreatest (G : EvenGen) (h : ℝ) (hh0 : 0 < h) :
    IsGreatest (errSetOf (polGate G h)) (G.gap (2 * h) / (4 * h ^ 2)) := by
  constructor
  · refine ⟨(1, 1), ⟨⟨zero_le_one, le_refl 1⟩, ⟨zero_le_one, le_refl 1⟩⟩, ?_⟩
    simp only
    rw [abs_of_nonneg (polGate_error_nonneg G h 1 1 hh0 zero_le_one zero_le_one),
      polGate_corner_value G h hh0]
  · rintro _ ⟨⟨x, y⟩, ⟨hx, hy⟩, rfl⟩
    exact polGate_error_le_corner G h x y hh0 hx hy

/-- The supremum in terms of the generator itself. -/
theorem polGate_sSup_exact (G : EvenGen) (h : ℝ) (hh0 : 0 < h) :
    sSup (errSetOf (polGate G h)) = (G.toFun (2 * h) - 4 * h ^ 2) / (4 * h ^ 2) := by
  rw [(polGate_isGreatest G h hh0).csSup_eq]
  congr 1
  simp only [EvenGen.toFun]
  ring

/-- **Design criterion.**  A pointwise smaller remainder gives a uniformly better
gate, so minimising the quartic coefficient really does minimise the error. -/
theorem polGate_sSup_mono (G₁ G₂ : EvenGen) (h : ℝ) (hh0 : 0 < h)
    (hle : ∀ t, G₁.gap t ≤ G₂.gap t) :
    sSup (errSetOf (polGate G₁ h)) ≤ sSup (errSetOf (polGate G₂ h)) := by
  rw [(polGate_isGreatest G₁ h hh0).csSup_eq, (polGate_isGreatest G₂ h hh0).csSup_eq]
  have h4 : (0:ℝ) < 4 * h ^ 2 := by positivity
  exact div_le_div_of_nonneg_right (hle (2 * h)) h4.le

/-! ## 4. The universal quartic constant -/

/-- **The universal quartic constant.**  If the remainder is `c t⁴ + O(t⁶)` then
the supremum of the gate error over `[0,1]²` is `4c·h² + O(h⁴)`, with the explicit
remainder `16C·h⁴`.  For EML, `c = 1/12` and `4c = 1/3`. -/
theorem polGate_sSup_asymptotic (G : EvenGen) (c C h : ℝ) (hh0 : 0 < h)
    (hh : h ≤ 1 / 2) (hq : ∀ t : ℝ, |t| ≤ 1 → |G.gap t - c * t ^ 4| ≤ C * t ^ 6) :
    |sSup (errSetOf (polGate G h)) - 4 * c * h ^ 2| ≤ 16 * C * h ^ 4 := by
  have h4 : (0:ℝ) < 4 * h ^ 2 := by positivity
  have key : |G.gap (2 * h) - c * (2 * h) ^ 4| ≤ C * (2 * h) ^ 6 := by
    refine hq (2 * h) ?_
    rw [abs_of_pos (by linarith)]
    linarith
  rw [(polGate_isGreatest G h hh0).csSup_eq]
  have expand : G.gap (2 * h) / (4 * h ^ 2) - 4 * c * h ^ 2
      = (G.gap (2 * h) - c * (2 * h) ^ 4) / (4 * h ^ 2) := by
    field_simp
    ring
  rw [expand, abs_div, abs_of_pos h4, div_le_iff₀ h4]
  calc |G.gap (2 * h) - c * (2 * h) ^ 4| ≤ C * (2 * h) ^ 6 := key
    _ = 16 * C * h ^ 4 * (4 * h ^ 2) := by ring

/-! ## 5. Instance: the EML gate -/

/-- The EML generator: `gap = coshGap`, i.e. `g(t) = exp t + exp(−t) − 2`. -/
def emlGen : EvenGen where
  gap := coshGap
  gap_neg := coshGap_neg
  gap_zero := coshGap_zero
  gap_mono := coshGap_monotoneOn

theorem emlGen_toFun (t : ℝ) : emlGen.toFun t = Real.exp t + Real.exp (-t) - 2 := by
  simp only [emlGen, EvenGen.toFun, coshGap]
  ring

/-- The EML multiplication gate **is** the polarisation gate of `emlGen`. -/
theorem polGate_emlGen (h x y : ℝ) (hh : h ≠ 0) :
    polGate emlGen h x y = prodGate h x y := by
  rw [prodGate, sqLayer_eval h hh, sqLayer_eval h hh]
  simp only [polGate, emlGen, EvenGen.toFun, coshGap]
  field_simp
  ring

/-- The abstract corner theorem specialises to the EML gate, recovering
`prodGate_isGreatest` for every `h > 0`. -/
theorem eml_sSup_isGreatest (h : ℝ) (hh0 : 0 < h) :
    IsGreatest (errSet h) (coshGap (2 * h) / (4 * h ^ 2)) := by
  have hset : errSet h = errSetOf (polGate emlGen h) := by
    simp only [errSet, errSetOf]
    refine Set.image_congr ?_
    rintro ⟨x, y⟩ _
    rw [polGate_emlGen h x y hh0.ne']
  rw [hset]
  exact polGate_isGreatest emlGen h hh0

/-- The quartic coefficient of the EML remainder is `1/12`, with a sextic-order
error constant `1/352` on `[-1,1]`. -/
theorem emlGen_quartic_bracket (t : ℝ) (ht : |t| ≤ 1) :
    |emlGen.gap t - (1 / 12) * t ^ 4| ≤ (1 / 352) * t ^ 6 := by
  have hb := coshGap_taylor t ht
  rw [abs_le] at hb ⊢
  have ht2 : t ^ 2 ≤ 1 := by
    have := abs_le_one_iff_mul_self_le_one.mp ht
    nlinarith
  have h6 : (0:ℝ) ≤ t ^ 6 := by positivity
  have h8 : t ^ 8 ≤ t ^ 6 := by nlinarith [pow_nonneg (sq_nonneg t) 3, sq_nonneg (t ^ 3)]
  simp only [emlGen] at *
  constructor <;> nlinarith
/-- **The EML instance of the universal constant.**  `4c = 4/12 = 1/3`, and the
abstract machinery even improves the remainder from `h⁴/21` to `h⁴/22`. -/
theorem eml_sSup_asymptotic (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    |sSup (errSet h) - h ^ 2 / 3| ≤ h ^ 4 / 22 := by
  have hset : sSup (errSet h) = sSup (errSetOf (polGate emlGen h)) := by
    rw [(prodGate_isGreatest h hh0).csSup_eq, (polGate_isGreatest emlGen h hh0).csSup_eq]
    rfl
  have habs := polGate_sSup_asymptotic emlGen (1 / 12) (1 / 352) h hh0 hh
    emlGen_quartic_bracket
  rw [hset]
  have e1 : 4 * (1 / 12 : ℝ) * h ^ 2 = h ^ 2 / 3 := by ring
  have e2 : 16 * (1 / 352 : ℝ) * h ^ 4 = h ^ 4 / 22 := by ring
  rwa [e1, e2] at habs

/-! ## 6. Instance: pure quartic generators, where the `O(h⁴)` disappears -/

/-- The pure quartic generator `g(t) = t² + c t⁴`, `c ≥ 0`. -/
def quarticGen (c : ℝ) (hc : 0 ≤ c) : EvenGen where
  gap := fun t => c * t ^ 4
  gap_neg := by intro t; ring
  gap_zero := by norm_num
  gap_mono := by
    intro a ha b hb hab
    simp only
    have ha0 : (0:ℝ) ≤ a := ha
    gcongr

/-- **Exact supremum for a quartic generator**: `4 c h²`, with *no* remainder.
The `O(h⁴)` of the EML statement comes entirely from the sextic and higher Taylor
coefficients of `2 cosh`. -/
theorem quartic_sSup_exact (c : ℝ) (hc : 0 ≤ c) (h : ℝ) (hh0 : 0 < h) :
    sSup (errSetOf (polGate (quarticGen c hc) h)) = 4 * c * h ^ 2 := by
  rw [(polGate_isGreatest (quarticGen c hc) h hh0).csSup_eq]
  show c * (2 * h) ^ 4 / (4 * h ^ 2) = 4 * c * h ^ 2
  field_simp
  ring

theorem quartic_sSup_isGreatest (c : ℝ) (hc : 0 ≤ c) (h : ℝ) (hh0 : 0 < h) :
    IsGreatest (errSetOf (polGate (quarticGen c hc) h)) (4 * c * h ^ 2) := by
  have hg := polGate_isGreatest (quarticGen c hc) h hh0
  have hval : (quarticGen c hc).gap (2 * h) / (4 * h ^ 2) = 4 * c * h ^ 2 := by
    show c * (2 * h) ^ 4 / (4 * h ^ 2) = 4 * c * h ^ 2
    field_simp
    ring
  rwa [hval] at hg

/-- The family degenerates to *exact* multiplication at `c = 0`: the square
activation `g(t) = t²` polarises the product with no error at all. -/
theorem exactGen_error_zero (h x y : ℝ) (hh0 : 0 < h) :
    polGate (quarticGen 0 (le_refl 0)) h x y - x * y = 0 := by
  rw [polGate_sub_eq _ h x y hh0.ne']
  show (0 * (h * (x + y)) ^ 4 - 0 * (h * (x - y)) ^ 4) / (4 * h ^ 2) = 0
  ring

/-- The EML gate is at least as bad as the pure quartic gate with the same
leading coefficient: on the relevant range `coshGap` dominates `t⁴/12`, so the
exponential's higher Taylor coefficients only add error. -/
theorem eml_worse_than_quartic (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    sSup (errSetOf (polGate (quarticGen (1 / 12) (by norm_num)) h))
      ≤ sSup (errSetOf (polGate emlGen h)) := by
  rw [quartic_sSup_exact _ _ h hh0, (polGate_isGreatest emlGen h hh0).csSup_eq]
  have hlow : ((2 * h) ^ 4 - (0:ℝ) ^ 4) / 12 ≤ coshGap (2 * h) - coshGap 0 :=
    coshGap_gap_lower (le_refl 0) (by linarith) (by linarith)
  rw [coshGap_zero, sub_zero] at hlow
  have h4 : (0:ℝ) < 4 * h ^ 2 := by positivity
  rw [le_div_iff₀ h4]
  show 4 * (1 / 12 : ℝ) * h ^ 2 * (4 * h ^ 2) ≤ coshGap (2 * h)
  nlinarith [hlow]

/-! ## 7. Critic's boundary check: monotonicity of the remainder is load-bearing

If the remainder is *decreasing*, the closed form `(g(2h) − 4h²)/(4h²)` returns a
negative number and cannot be the supremum of an absolute value.  We check this
on `g(t) = t² − t⁴`, the mirror image of the smallest interesting instance. -/

/-- The gate of the non-monotone generator `g(t) = t² − t⁴`. -/
def negQuarticGate (h x y : ℝ) : ℝ :=
  (((h * (x + y)) ^ 2 - (h * (x + y)) ^ 4)
    - ((h * (x - y)) ^ 2 - (h * (x - y)) ^ 4)) / (4 * h ^ 2)

theorem negQuartic_error (h x y : ℝ) (hh : h ≠ 0) :
    negQuarticGate h x y - x * y = -(2 * h ^ 2 * (x * y * (x ^ 2 + y ^ 2))) := by
  simp only [negQuarticGate]
  field_simp
  ring

/-- The true maximum of the error of the non-monotone gate is `+4h²`, attained at
the corner. -/
theorem negQuartic_isGreatest (h : ℝ) (hh0 : 0 < h) :
    IsGreatest (errSetOf (negQuarticGate h)) (4 * h ^ 2) := by
  constructor
  · refine ⟨(1, 1), ⟨⟨zero_le_one, le_refl 1⟩, ⟨zero_le_one, le_refl 1⟩⟩, ?_⟩
    simp only
    rw [negQuartic_error h 1 1 hh0.ne']
    rw [abs_of_nonpos (by nlinarith [sq_nonneg h])]
    ring
  · rintro _ ⟨⟨x, y⟩, ⟨⟨hx0, hx1⟩, ⟨hy0, hy1⟩⟩, rfl⟩
    dsimp only at hx0 hx1 hy0 hy1 ⊢
    have hpos : (0:ℝ) ≤ 2 * h ^ 2 * (x * y * (x ^ 2 + y ^ 2)) :=
      mul_nonneg (by positivity) (mul_nonneg (mul_nonneg hx0 hy0) (by positivity))
    have hprod : x * y * (x ^ 2 + y ^ 2) ≤ 2 := by
      have h1 : x * y ≤ 1 := by nlinarith
      have h2 : x ^ 2 + y ^ 2 ≤ 2 := by nlinarith
      have := mul_le_mul h1 h2 (by positivity) zero_le_one
      linarith
    rw [negQuartic_error h x y hh0.ne', abs_of_nonpos (by linarith)]
    nlinarith [mul_le_mul_of_nonneg_left hprod (by positivity : (0:ℝ) ≤ 2 * h ^ 2)]

/-- **The hypothesis is load-bearing.**  For the non-monotone generator the
closed form of `polGate_isGreatest` evaluates to `−4h²`, which is not the maximum
of the error (that maximum is `+4h²`); indeed it is not even an upper bound-free
element of the error set, since every element is non-negative. -/
theorem negQuartic_formula_fails (h : ℝ) (hh0 : 0 < h) :
    ¬ IsGreatest (errSetOf (negQuarticGate h))
        ((((2 * h) ^ 2 - (2 * h) ^ 4) - 4 * h ^ 2) / (4 * h ^ 2)) := by
  rintro ⟨hmem, -⟩
  obtain ⟨⟨x, y⟩, -, hval⟩ := hmem
  have hneg : ((((2 * h) ^ 2 - (2 * h) ^ 4) - 4 * h ^ 2) / (4 * h ^ 2)) < 0 := by
    have hnum : ((2 * h) ^ 2 - (2 * h) ^ 4) - 4 * h ^ 2 = -(16 * h ^ 4) := by ring
    rw [hnum]
    have hpos : (0:ℝ) < 16 * h ^ 4 := by positivity
    have h4 : (0:ℝ) < 4 * h ^ 2 := by positivity
    exact div_neg_of_neg_of_pos (by linarith) h4
  have : (0:ℝ) ≤ ((((2 * h) ^ 2 - (2 * h) ^ 4) - 4 * h ^ 2) / (4 * h ^ 2)) := by
    rw [← hval]; exact abs_nonneg _
  linarith

/-! ## 8. Axiom audit -/

end

#print axioms polGate_isGreatest
#print axioms polGate_sSup_exact
#print axioms polGate_sSup_asymptotic
#print axioms polGate_sSup_mono
#print axioms eml_sSup_isGreatest
#print axioms eml_sSup_asymptotic
#print axioms quartic_sSup_exact
#print axioms eml_worse_than_quartic
#print axioms negQuartic_isGreatest
#print axioms negQuartic_formula_fails

end EML.UniversalGate