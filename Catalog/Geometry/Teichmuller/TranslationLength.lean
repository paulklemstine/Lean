/-
# Displacement of Möbius transformations and Teichmüller translation lengths

This file proves an exact **displacement identity** for the action of `SL(2, R)` (`R` any
commutative ring mapping to `ℝ`; in practice `ℝ` or `ℤ`) on the upper half plane: for
`g = !![a, b; c, d]` of determinant `1` and `z = x + i y ∈ ℍ`,

    cosh (dist z (g • z)) = ((a + d)² - 2)/2 + (c (x² + y²) - (a - d) x - b)² / (2 y²) .

The identity is sharp: the second term is a square divided by a positive number, so the
displacement of `g` is minimized exactly on the *axis* `c(x²+y²) - (a-d)x - b = 0`, which is a
nonempty subset of `ℍ` precisely when `g` is hyperbolic (`|tr g| > 2`).  This gives the
**translation length**

    inf_z dist (z, g z) = arcosh (((tr g)² - 2)/2) = 2 log λ(g),
    λ(g) = (|tr g| + √((tr g)² - 4)) / 2 ,

attained on the axis.  Translated through `Teichmuller.teichDist_eq_half_dist`, this is the
torus case of the classical theorem of Bers: **the minimal Teichmüller displacement of an
Anosov mapping class equals the logarithm of its stretch factor**,

    min_τ d_T (τ, g · τ) = log λ(g) ,

where `λ(g)` is the larger eigenvalue of `g`, i.e. the dilatation of the associated Anosov
diffeomorphism of the torus.

Main results:

* `Teichmuller.cosh_dist_smul` : the displacement identity;
* `Teichmuller.exists_axis_point` : the axis is nonempty for hyperbolic `g`;
* `Teichmuller.isLeast_dist_smul` : the hyperbolic translation length is attained and equals
  `arcosh (((tr g)² - 2)/2)`;
* `Teichmuller.isLeast_teichDist_smul` : the Teichmüller translation length of an Anosov
  mapping class of the torus equals `log λ(g)`.

-- !-- Lab Notes -- !--
Hypothesizer: the displacement function `z ↦ dist (z, g z)` of a Möbius transformation should
be *exactly* a perfect square over `2y²` plus a constant determined only by the trace — a purely
algebraic statement of the classification elliptic/parabolic/hyperbolic.
Experimenter: writing `P(z) = c z² - (a-d) z - b` (the numerator of `g z - z`), the experiment
`|P(z)|² - y² ((tr g)² - 4) = (c(x²+y²) - (a-d)x - b)²` is a polynomial identity modulo
`ad - bc = 1`, verified by `linear_combination (-4 y²) (det - 1)`.  Analyst: the "constant"
`((tr g)² - 2)/2` is `cosh` of the translation length, so the trace alone determines the
translation length — the cross-domain payoff is that the *arithmetic* of the trace of an
integer matrix computes a *metric* invariant of the moduli space of tori.
-/
import Mathlib
import Geometry.Teichmuller.TorusSpace

namespace Teichmuller

open Complex UpperHalfPlane Matrix MatrixGroups

private lemma div_div_two_mul_aux (Q N y : ℝ) (hN : N ≠ 0) (hy : y ≠ 0) :
    Q / N / (2 * y * (y / N)) = Q / (2 * y ^ 2) := by
  field_simp

section Displacement

variable {R : Type*} [CommRing R] [Algebra R ℝ]

/-- The `(i, j)` entry of an element of `SL(2, R)`, viewed as a real number. -/
noncomputable def entry (g : SL(2, R)) (i j : Fin 2) : ℝ := algebraMap R ℝ (g i j)

/-- The trace of an element of `SL(2, R)`, as a real number. -/
noncomputable def tr (g : SL(2, R)) : ℝ := entry g 0 0 + entry g 1 1

theorem entry_det (g : SL(2, R)) :
    entry g 0 0 * entry g 1 1 - entry g 0 1 * entry g 1 0 = 1 := by
  have h : (g : Matrix (Fin 2) (Fin 2) R) 0 0 * (g : Matrix (Fin 2) (Fin 2) R) 1 1
      - (g : Matrix (Fin 2) (Fin 2) R) 0 1 * (g : Matrix (Fin 2) (Fin 2) R) 1 0 = 1 := by
    have := g.2
    rw [Matrix.det_fin_two] at this
    exact this
  have := congrArg (algebraMap R ℝ) h
  simpa [entry, map_sub, map_mul] using this

/-- **The displacement identity.**  `cosh` of the hyperbolic displacement of `z` under a Möbius
transformation is a constant depending only on the trace, plus a perfect square supported on the
complement of the axis. -/
theorem cosh_dist_smul (g : SL(2, R)) (z : ℍ) :
    Real.cosh (dist z (g • z)) = (tr g ^ 2 - 2) / 2 +
      (entry g 1 0 * (z.re ^ 2 + z.im ^ 2) - (entry g 0 0 - entry g 1 1) * z.re
        - entry g 0 1) ^ 2 / (2 * z.im ^ 2) := by
  set a := entry g 0 0 with ha
  set b := entry g 0 1 with hb
  set c := entry g 1 0 with hc
  set d := entry g 1 1 with hd
  have hdet : a * d - b * c = 1 := entry_det g
  set x := z.re with hx
  set y := z.im with hy
  have hypos : 0 < y := z.im_pos
  have hzre : (z : ℂ).re = x := rfl
  have hzim : (z : ℂ).im = y := rfl
  have hcoe : ((g • z : ℍ) : ℂ) = ((a : ℂ) * z + (b : ℂ)) / ((c : ℂ) * z + (d : ℂ)) := by
    rw [UpperHalfPlane.coe_specialLinearGroup_apply, ha, hb, hc, hd]
    simp [entry]
  have hden : ((c : ℂ) * z + (d : ℂ)) ≠ 0 := by
    intro h
    have h1 : c * y = 0 := by
      have h2 := congrArg Complex.im h
      simpa [Complex.add_im, Complex.mul_im] using h2
    have hc0 : c = 0 := by
      rcases mul_eq_zero.mp h1 with h2 | h2
      · exact h2
      · exact absurd h2 hypos.ne'
    have hd0 : d = 0 := by
      have h2 := congrArg Complex.re h
      simp [hc0] at h2
      exact h2
    rw [hc0, hd0] at hdet
    simp at hdet
  have hNpos : (0:ℝ) < (c * x + d) ^ 2 + (c * y) ^ 2 := by
    rcases eq_or_ne c 0 with h | h
    · have hd0 : d ≠ 0 := by
        intro hd0; rw [h, hd0] at hdet; simp at hdet
      simp [h]
      positivity
    · positivity
  have hNne : ((c * x + d) ^ 2 + (c * y) ^ 2) ≠ 0 := hNpos.ne'
  have hyne : y ≠ 0 := hypos.ne'
  have hN : Complex.normSq ((c : ℂ) * z + (d : ℂ)) = (c * x + d) ^ 2 + (c * y) ^ 2 := by
    simp [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re, Complex.mul_im]
    ring
  have hsub : (z : ℂ) - ((g • z : ℍ) : ℂ)
      = ((c : ℂ) * z * z + ((d : ℂ) - (a : ℂ)) * z - (b : ℂ)) / ((c : ℂ) * z + (d : ℂ)) := by
    rw [hcoe, eq_div_iff hden, sub_mul, div_mul_cancel₀ _ hden]
    ring
  have hP : Complex.normSq ((c : ℂ) * z * z + ((d : ℂ) - (a : ℂ)) * z - (b : ℂ))
      = (c * (x ^ 2 - y ^ 2) + (d - a) * x - b) ^ 2 + (2 * c * x * y + (d - a) * y) ^ 2 := by
    simp [Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.add_re, Complex.add_im,
      Complex.mul_re, Complex.mul_im]
    ring
  have hd2 : dist (z : ℂ) ((g • z : ℍ) : ℂ) ^ 2
      = ((c * (x ^ 2 - y ^ 2) + (d - a) * x - b) ^ 2 + (2 * c * x * y + (d - a) * y) ^ 2)
        / ((c * x + d) ^ 2 + (c * y) ^ 2) := by
    rw [Complex.dist_eq, ← Complex.normSq_eq_norm_sq, hsub, Complex.normSq_div, hN, hP]
  have hnum : (((a : ℂ) * z + b) * (starRingEnd ℂ) ((c : ℂ) * z + d)).im = y := by
    simp only [Complex.mul_im, Complex.add_re, Complex.add_im, Complex.mul_re, Complex.mul_im,
      Complex.conj_re, Complex.conj_im, Complex.ofReal_re, Complex.ofReal_im, hzre, hzim]
    linear_combination y * hdet
  have him : (g • z).im = y / ((c * x + d) ^ 2 + (c * y) ^ 2) := by
    have key : ((a : ℂ) * z + b) / ((c : ℂ) * z + d)
        = (((a : ℂ) * z + b) * (starRingEnd ℂ) ((c : ℂ) * z + d))
            * ((Complex.normSq ((c : ℂ) * z + d))⁻¹ : ℝ) := by
      rw [division_def, Complex.inv_def]
      push_cast
      ring
    rw [← UpperHalfPlane.coe_im, hcoe, key, Complex.mul_im, Complex.ofReal_im, Complex.ofReal_re,
      hnum, hN, mul_zero, zero_add, div_eq_mul_inv]
  rw [UpperHalfPlane.cosh_dist, hd2, him,
    div_div_two_mul_aux _ _ _ hNne hyne]
  have htr : tr g = a + d := rfl
  rw [htr]
  field_simp
  linear_combination (-4 * y ^ 2) * hdet

/-- The displacement of `g` is bounded below by a quantity depending only on the trace. -/
theorem cosh_dist_smul_ge (g : SL(2, R)) (z : ℍ) :
    (tr g ^ 2 - 2) / 2 ≤ Real.cosh (dist z (g • z)) := by
  rw [cosh_dist_smul]
  have hy : (0:ℝ) < 2 * z.im ^ 2 := by have := z.im_pos; positivity
  have : (0:ℝ) ≤ (entry g 1 0 * (z.re ^ 2 + z.im ^ 2) - (entry g 0 0 - entry g 1 1) * z.re
      - entry g 0 1) ^ 2 / (2 * z.im ^ 2) := by positivity
  linarith

/-- For a hyperbolic element the axis is nonempty: there is a point of `ℍ` where the displacement
attains the trace bound. -/
theorem exists_axis_point (g : SL(2, R)) (ht : 2 < |tr g|) :
    ∃ z : ℍ, Real.cosh (dist z (g • z)) = (tr g ^ 2 - 2) / 2 := by
  set a := entry g 0 0 with ha
  set b := entry g 0 1 with hb
  set c := entry g 1 0 with hc
  set d := entry g 1 1 with hd
  have hdet : a * d - b * c = 1 := entry_det g
  have htr : tr g = a + d := rfl
  have ht4 : 4 < (a + d) ^ 2 := by
    rw [htr] at ht
    nlinarith [abs_nonneg (a + d), sq_abs (a + d), le_abs_self (a + d), neg_abs_le (a + d)]
  have hdisc : (a - d) ^ 2 + 4 * (b * c) = (a + d) ^ 2 - 4 := by linarith [hdet]
  rcases eq_or_ne c 0 with hc0 | hc0
  · -- upper triangular case: the axis is a vertical line
    have hadd : (a - d) ^ 2 = (a + d) ^ 2 - 4 := by rw [← hdisc, hc0]; ring
    have hne : a - d ≠ 0 := by
      intro h
      rw [h] at hadd
      nlinarith
    refine ⟨⟨⟨-b / (a - d), 1⟩, by norm_num⟩, ?_⟩
    rw [cosh_dist_smul, htr]
    have hre : (⟨(⟨-b / (a - d), 1⟩ : ℂ), by norm_num⟩ : ℍ).re = -b / (a - d) := rfl
    have him : (⟨(⟨-b / (a - d), 1⟩ : ℂ), by norm_num⟩ : ℍ).im = 1 := rfl
    rw [hre, him, ← hc, hc0, ← ha, ← hb, ← hd]
    field_simp
    ring
  · -- generic case: the axis is a semicircle
    have hpos : (0:ℝ) < ((a + d) ^ 2 - 4) / (4 * c ^ 2) := by
      have : (0:ℝ) < 4 * c ^ 2 := by positivity
      have h4 : (0:ℝ) < (a + d) ^ 2 - 4 := by linarith
      positivity
    set y0 := Real.sqrt (((a + d) ^ 2 - 4) / (4 * c ^ 2)) with hy0
    have hy0pos : 0 < y0 := Real.sqrt_pos.mpr hpos
    have hy0sq : y0 ^ 2 = ((a + d) ^ 2 - 4) / (4 * c ^ 2) := Real.sq_sqrt hpos.le
    refine ⟨⟨⟨(a - d) / (2 * c), y0⟩, hy0pos⟩, ?_⟩
    rw [cosh_dist_smul, htr]
    have hre : (⟨(⟨(a - d) / (2 * c), y0⟩ : ℂ), hy0pos⟩ : ℍ).re = (a - d) / (2 * c) := rfl
    have him : (⟨(⟨(a - d) / (2 * c), y0⟩ : ℂ), hy0pos⟩ : ℍ).im = y0 := rfl
    rw [hre, him, ← hc, hy0sq]
    have hEzero : c * (((a - d) / (2 * c)) ^ 2 + ((a + d) ^ 2 - 4) / (4 * c ^ 2))
        - (a - d) * ((a - d) / (2 * c)) - b = 0 := by
      field_simp
      linarith [hdisc]
    have hy0ne : y0 ≠ 0 := hy0pos.ne'
    rw [hEzero]
    simp

/-- The **stretch factor** (larger eigenvalue) of a hyperbolic element. -/
noncomputable def stretch (g : SL(2, R)) : ℝ := (|tr g| + Real.sqrt (tr g ^ 2 - 4)) / 2

variable {g : SL(2, R)}

theorem sq_sqrt_disc (ht : 2 < |tr g|) : Real.sqrt (tr g ^ 2 - 4) ^ 2 = tr g ^ 2 - 4 := by
  refine Real.sq_sqrt ?_
  nlinarith [sq_abs (tr g), abs_nonneg (tr g)]

theorem one_lt_stretch (ht : 2 < |tr g|) : 1 < stretch g := by
  have h : 0 ≤ Real.sqrt (tr g ^ 2 - 4) := Real.sqrt_nonneg _
  rw [stretch]
  linarith

theorem stretch_pos (ht : 2 < |tr g|) : 0 < stretch g :=
  lt_trans one_pos (one_lt_stretch ht)

/-- `λ + λ⁻¹ = |tr g|`: the stretch factor is the larger root of `X² - |tr| X + 1`. -/
theorem stretch_add_inv (ht : 2 < |tr g|) : stretch g + (stretch g)⁻¹ = |tr g| := by
  have hs : stretch g * ((|tr g| - Real.sqrt (tr g ^ 2 - 4)) / 2) = 1 := by
    rw [stretch]
    have h := sq_sqrt_disc ht
    have habs : |tr g| ^ 2 = tr g ^ 2 := sq_abs _
    nlinarith [h, habs]
  have hinv : (stretch g)⁻¹ = (|tr g| - Real.sqrt (tr g ^ 2 - 4)) / 2 :=
    inv_eq_of_mul_eq_one_right hs
  rw [hinv, stretch]
  ring

/-- `cosh` of twice the logarithm of the stretch factor is the trace invariant. -/
theorem cosh_two_log_stretch (ht : 2 < |tr g|) :
    Real.cosh (2 * Real.log (stretch g)) = (tr g ^ 2 - 2) / 2 := by
  have hpos : 0 < stretch g := stretch_pos ht
  have hexp : Real.exp (2 * Real.log (stretch g)) = stretch g ^ 2 := by
    rw [two_mul, Real.exp_add, Real.exp_log hpos, sq]
  have hsum := stretch_add_inv ht
  have habs : |tr g| ^ 2 = tr g ^ 2 := sq_abs _
  have hne : stretch g ≠ 0 := hpos.ne'
  have hkey : stretch g ^ 2 + 1 = |tr g| * stretch g := by
    field_simp at hsum
    linarith
  rw [Real.cosh_eq, hexp, Real.exp_neg, hexp]
  field_simp
  linear_combination (stretch g ^ 2 + 1 + |tr g| * stretch g) * hkey + (stretch g ^ 2) * habs

theorem arcosh_eq_two_log_stretch (ht : 2 < |tr g|) :
    Real.arcosh ((tr g ^ 2 - 2) / 2) = 2 * Real.log (stretch g) := by
  have hlog : 0 ≤ Real.log (stretch g) := Real.log_nonneg (one_lt_stretch ht).le
  rw [← cosh_two_log_stretch ht, Real.arcosh_cosh (by linarith)]

/-- **The hyperbolic translation length is attained**, and equals `arcosh (((tr g)² - 2)/2)`. -/
theorem isLeast_dist_smul (ht : 2 < |tr g|) :
    IsLeast {r : ℝ | ∃ z : ℍ, r = dist z (g • z)} (Real.arcosh ((tr g ^ 2 - 2) / 2)) := by
  have hone : 1 ≤ (tr g ^ 2 - 2) / 2 := by
    nlinarith [sq_abs (tr g), abs_nonneg (tr g)]
  constructor
  · obtain ⟨z₀, hz₀⟩ := exists_axis_point g ht
    exact ⟨z₀, by rw [← hz₀, Real.arcosh_cosh dist_nonneg]⟩
  · rintro r ⟨z, rfl⟩
    have hge : (tr g ^ 2 - 2) / 2 ≤ Real.cosh (dist z (g • z)) := cosh_dist_smul_ge g z
    have h1 : (0:ℝ) < (tr g ^ 2 - 2) / 2 := by linarith
    have h2 : (0:ℝ) < Real.cosh (dist z (g • z)) := Real.cosh_pos _
    have := (Real.arcosh_le_arcosh h1 h2).mpr hge
    rwa [Real.arcosh_cosh dist_nonneg] at this

/-- **Teichmüller translation length of an Anosov class.**  For a hyperbolic `g`, the minimum
of the Teichmüller displacement `τ ↦ d_T (τ, g · τ)` over the Teichmüller space of the torus is
attained and equals `log λ(g)`, the logarithm of the stretch factor of `g`. -/
theorem isLeast_teichDist_smul (ht : 2 < |tr g|) :
    IsLeast {r : ℝ | ∃ τ : ℍ, r = teichDist τ (g • τ)} (Real.log (stretch g)) := by
  obtain ⟨⟨z₀, hz₀⟩, hlb⟩ := isLeast_dist_smul ht
  constructor
  · refine ⟨z₀, ?_⟩
    rw [teichDist_eq_half_dist, ← hz₀, arcosh_eq_two_log_stretch ht]
    ring
  · rintro r ⟨τ, rfl⟩
    have hd : Real.arcosh ((tr g ^ 2 - 2) / 2) ≤ dist τ (g • τ) := hlb ⟨τ, rfl⟩
    rw [arcosh_eq_two_log_stretch ht] at hd
    rw [teichDist_eq_half_dist]
    linarith

end Displacement

section CatMap

/-- Arnold's cat map `!![2, 1; 1, 1]`, an Anosov mapping class of the torus. -/
def catMap : SL(2, ℤ) := ⟨!![2, 1; 1, 1], by simp [Matrix.det_fin_two_of]⟩

@[simp] theorem tr_catMap : tr catMap = 3 := by
  simp [tr, entry, catMap]
  norm_num

theorem stretch_catMap : stretch catMap = (3 + Real.sqrt 5) / 2 := by
  rw [stretch, tr_catMap]
  norm_num

/-- **The Teichmüller translation length of Arnold's cat map is `log ((3 + √5)/2)`**, the
logarithm of its Anosov stretch factor (the square of the golden ratio). -/
theorem isLeast_teichDist_catMap :
    IsLeast {r : ℝ | ∃ τ : ℍ, r = teichDist τ (catMap • τ)}
      (Real.log ((3 + Real.sqrt 5) / 2)) := by
  have ht : 2 < |tr catMap| := by rw [tr_catMap]; norm_num
  have := isLeast_teichDist_smul ht
  rwa [stretch_catMap] at this

/-- An integer trace of absolute value `> 2` has absolute value at least `3`. -/
theorem three_le_abs_tr (g : SL(2, ℤ)) (ht : 2 < |tr g|) : 3 ≤ |tr g| := by
  set n : ℤ := (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0 + (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 with hn
  have htr : tr g = (n : ℝ) := by
    simp [tr, entry, hn]
  have habs : |tr g| = ((|n| : ℤ) : ℝ) := by
    rw [htr, Int.cast_abs]
  rw [habs] at ht ⊢
  have h2 : (2 : ℤ) < |n| := by exact_mod_cast ht
  have h3 : (3 : ℤ) ≤ |n| := by omega
  exact_mod_cast h3

/-- **A spectral gap for the moduli space of tori.**  Every Anosov mapping class of the torus has
stretch factor at least `(3 + √5)/2`, the square of the golden ratio, which is the stretch factor
of Arnold's cat map.  Equivalently, the Teichmüller translation length of any Anosov class is at
least `log ((3 + √5)/2)`: the systole of the moduli space of tori in the Teichmüller metric. -/
theorem goldenRatio_sq_le_stretch (g : SL(2, ℤ)) (ht : 2 < |tr g|) :
    (3 + Real.sqrt 5) / 2 ≤ stretch g := by
  have h3 : 3 ≤ |tr g| := three_le_abs_tr g ht
  have habs : |tr g| ^ 2 = tr g ^ 2 := sq_abs _
  have hdisc : 5 ≤ tr g ^ 2 - 4 := by nlinarith [h3, habs, abs_nonneg (tr g)]
  have hsqrt : Real.sqrt 5 ≤ Real.sqrt (tr g ^ 2 - 4) := Real.sqrt_le_sqrt hdisc
  rw [stretch]
  linarith

/-- The Teichmüller displacement of any Anosov mapping class of the torus is at least
`log ((3 + √5)/2)`, with equality attained by Arnold's cat map. -/
theorem log_goldenRatio_sq_le_teichDist (g : SL(2, ℤ)) (ht : 2 < |tr g|) (τ : ℍ) :
    Real.log ((3 + Real.sqrt 5) / 2) ≤ teichDist τ (g • τ) := by
  have hgap : (3 + Real.sqrt 5) / 2 ≤ stretch g := goldenRatio_sq_le_stretch g ht
  have hpos : (0:ℝ) < (3 + Real.sqrt 5) / 2 := by positivity
  have hlog : Real.log ((3 + Real.sqrt 5) / 2) ≤ Real.log (stretch g) :=
    Real.log_le_log hpos hgap
  have hle : Real.log (stretch g) ≤ teichDist τ (g • τ) :=
    (isLeast_teichDist_smul ht).2 ⟨τ, rfl⟩
  linarith

/-- The stretch factor of the cat map is the square of the golden ratio. -/
theorem stretch_catMap_eq_goldenRatio_sq :
    stretch catMap = ((1 + Real.sqrt 5) / 2) ^ 2 := by
  rw [stretch_catMap]
  have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)
  field_simp
  nlinarith [h5]

end CatMap

end Teichmuller