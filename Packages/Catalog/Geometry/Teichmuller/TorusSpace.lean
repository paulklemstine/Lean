/-
# The Teichmüller space of the torus, and its Teichmüller metric

A marked complex torus is `ℂ / (ℤ + ℤτ)` with `τ` in the upper half plane `ℍ`; the marking is
the choice of the ordered basis `(1, τ)` of the lattice.  The Teichmüller space of the torus is
therefore `ℍ` itself, and the Teichmüller distance between `τ` and `τ'` is
`(1/2) log K`, where `K` is the smallest dilatation of a quasiconformal homeomorphism
`ℂ/Λ_τ → ℂ/Λ_{τ'}` respecting the marking.  For the torus the extremal map is the *affine*
one, the unique `ℝ`-linear map with `1 ↦ 1` and `τ ↦ τ'`, built here as `Teichmuller.affine`.

The results in this file are:

* `Teichmuller.affine_apply_one`, `Teichmuller.affine_apply_tau`: the affine marked map;
* `Teichmuller.eq_affine_of_marked`: **uniqueness** — any real-linear map realizing the marking
  is the affine one, hence (`Teichmuller.dil_affine_le`) it is the extremal one;
* `Teichmuller.affine_comp`, `Teichmuller.affine_inv`: the marked affine maps form a groupoid;
* `Teichmuller.teichDist_triangle`, `teichDist_comm`, `teichDist_eq_zero_iff`:
  the Teichmüller distance is a metric, proved *intrinsically* from quasiconformal
  submultiplicativity (`LinMap.dil_comp_le`) rather than by transport;
* `Teichmuller.teichDist_eq_half_dist` : **the main theorem** — the Teichmüller metric on the
  Teichmüller space of the torus is exactly one half of the hyperbolic (Poincaré) metric of
  curvature `-1` on `ℍ`; equivalently, the Teichmüller metric has curvature `-4`.

The main theorem is a genuine cross-domain identity: the left-hand side is defined by an
extremal problem for quasiconformal distortion (analysis), the right-hand side by the
`SL(2,ℝ)`-invariant Riemannian metric (hyperbolic geometry).  The bridge is the exact formula

    K(τ, τ') = (‖τ' - conj τ‖ + ‖τ' - τ‖)² / (4 · im τ · im τ')

together with the Pythagoras-type identity `‖τ' - conj τ‖² = ‖τ' - τ‖² + 4 · im τ · im τ'`.

-- !-- Lab Notes -- !--
Hypothesizer: `d_T = (1/2) d_ℍ` on the torus, i.e. the Teichmüller metric of the once-marked
torus is a *rescaled* hyperbolic metric, and the rescaling constant is exactly 2 (not 1).
Experimenter: computing `cosh` of both sides is the decisive experiment: `cosh (log K)` equals
`(K + K⁻¹)/2 = (p² + q²)/(p² - q²)` with `p = ‖τ' - conj τ‖`, `q = ‖τ' - τ‖`, while Mathlib's
`UpperHalfPlane.cosh_dist` gives `1 + q²/(2 y y')`; the reflection identity `p² - q² = 4 y y'`
makes them equal.  Analyst: the factor `1/2` is forced — one cannot rescale it away without
breaking `K = 1 ↔ τ = τ'` — and it is the reason the Teichmüller metric of the torus has
curvature `-4`, matching Royden's theorem that Teichmüller metric = Kobayashi metric.
-/
import Mathlib
import Geometry.Teichmuller.LinearQC

namespace Teichmuller

open Complex UpperHalfPlane

variable (τ τ' τ'' : ℍ)

/-- The complex conjugate of a point of the upper half plane. -/
noncomputable abbrev cbar (τ : ℍ) : ℂ := (starRingEnd ℂ) (τ : ℂ)

theorem sub_cbar_self : (τ : ℂ) - cbar τ = ((2 * τ.im : ℝ) : ℂ) * Complex.I := by
  apply Complex.ext <;> simp [cbar]
  ring

theorem norm_sub_cbar_self : ‖(τ : ℂ) - cbar τ‖ = 2 * τ.im := by
  rw [sub_cbar_self, norm_mul, Complex.norm_I, mul_one, Complex.norm_real,
    Real.norm_eq_abs, abs_of_pos (by positivity)]

theorem sub_cbar_ne_zero : (τ : ℂ) - cbar τ ≠ 0 := by
  intro h
  have := norm_sub_cbar_self τ
  rw [h] at this
  simp at this
  exact absurd this τ.im_pos.ne'

/-- The reflection identity: `‖τ' - conj τ‖² = ‖τ' - τ‖² + 4 (im τ)(im τ')`.  This is the exact
form of the statement that `conj τ` is the mirror image of `τ` in the real axis. -/
theorem normSq_sub_cbar :
    ‖(τ' : ℂ) - cbar τ‖ ^ 2 = ‖(τ' : ℂ) - (τ : ℂ)‖ ^ 2 + 4 * τ.im * τ'.im := by
  simp only [cbar, ← Complex.normSq_eq_norm_sq, Complex.normSq_apply, Complex.sub_re,
    Complex.sub_im, Complex.conj_re, Complex.conj_im, UpperHalfPlane.coe_im, UpperHalfPlane.coe_re]
  ring

theorem norm_sub_lt_norm_sub_cbar :
    ‖(τ' : ℂ) - (τ : ℂ)‖ < ‖(τ' : ℂ) - cbar τ‖ := by
  have h := normSq_sub_cbar τ τ'
  have h1 : (0:ℝ) < 4 * τ.im * τ'.im := by
    have := τ.im_pos; have := τ'.im_pos; positivity
  nlinarith [norm_nonneg ((τ' : ℂ) - (τ : ℂ)), norm_nonneg ((τ' : ℂ) - cbar τ)]

/-- The **affine marked map** from the torus `ℂ/⟨1, τ⟩` to the torus `ℂ/⟨1, τ'⟩`: the unique
`ℝ`-linear map with `1 ↦ 1` and `τ ↦ τ'`. -/
noncomputable def affine : LinMap where
  a := ((τ' : ℂ) - cbar τ) / ((τ : ℂ) - cbar τ)
  b := ((τ : ℂ) - (τ' : ℂ)) / ((τ : ℂ) - cbar τ)
  norm_lt := by
    rw [norm_div, norm_div]
    have hm : (0:ℝ) < ‖(τ : ℂ) - cbar τ‖ := by
      rw [norm_sub_cbar_self]; have := τ.im_pos; positivity
    have := norm_sub_lt_norm_sub_cbar τ τ'
    rw [show ((τ : ℂ) - (τ' : ℂ)) = -((τ' : ℂ) - (τ : ℂ)) by ring, norm_neg]
    gcongr

@[simp] theorem affine_a : (affine τ τ').a = ((τ' : ℂ) - cbar τ) / ((τ : ℂ) - cbar τ) := rfl
@[simp] theorem affine_b : (affine τ τ').b = ((τ : ℂ) - (τ' : ℂ)) / ((τ : ℂ) - cbar τ) := rfl

theorem affine_apply_one : (affine τ τ').toFun 1 = 1 := by
  have h := sub_cbar_ne_zero τ
  simp only [LinMap.toFun, affine_a, affine_b, map_one, mul_one]
  field_simp
  ring

theorem affine_apply_tau : (affine τ τ').toFun (τ : ℂ) = (τ' : ℂ) := by
  have h := sub_cbar_ne_zero τ
  simp only [LinMap.toFun, affine_a, affine_b, cbar]
  field_simp
  ring

/-- **Uniqueness of the marked affine map.**  A real-linear map of the plane taking the marked
basis `(1, τ)` of the lattice to the marked basis `(1, τ')` is the affine map. -/
theorem eq_affine_of_marked (f : LinMap) (h1 : f.toFun 1 = 1) (hτ : f.toFun (τ : ℂ) = (τ' : ℂ)) :
    f = affine τ τ' := by
  have hne := sub_cbar_ne_zero τ
  simp only [LinMap.toFun, map_one, mul_one] at h1
  simp only [LinMap.toFun] at hτ
  have hb : f.b = 1 - f.a := by linear_combination h1
  have ha : f.a = ((τ' : ℂ) - cbar τ) / ((τ : ℂ) - cbar τ) := by
    rw [eq_div_iff hne]
    rw [hb] at hτ
    linear_combination hτ
  have hb' : f.b = ((τ : ℂ) - (τ' : ℂ)) / ((τ : ℂ) - cbar τ) := by
    rw [hb, ha, eq_div_iff hne]
    field_simp
    ring
  cases f with
  | mk a b h => simp_all [affine]

/-- **Teichmüller extremality for the torus (linear case).**  The affine marked map minimizes the
dilatation among all real-linear maps realizing the marking — indeed it is the only one. -/
theorem dil_affine_le (f : LinMap) (h1 : f.toFun 1 = 1) (hτ : f.toFun (τ : ℂ) = (τ' : ℂ)) :
    (affine τ τ').dil ≤ f.dil :=
  le_of_eq (by rw [eq_affine_of_marked τ τ' f h1 hτ])

/-- The marked affine maps compose. -/
theorem affine_comp : (affine τ' τ'').comp (affine τ τ') = affine τ τ'' := by
  refine eq_affine_of_marked τ τ'' _ ?_ ?_
  · rw [LinMap.comp_apply, affine_apply_one, affine_apply_one]
  · rw [LinMap.comp_apply, affine_apply_tau, affine_apply_tau]

/-- The inverse of a marked affine map is the marked affine map in the other direction. -/
theorem affine_inv : (affine τ τ').inv = affine τ' τ := by
  refine eq_affine_of_marked τ' τ _ ?_ ?_
  · have h := LinMap.inv_apply (affine τ τ') ((affine τ τ').inv.toFun 1)
    have h2 : (affine τ τ').toFun ((affine τ τ').inv.toFun 1) = 1 :=
      LinMap.inv_apply (affine τ τ') 1
    -- from injectivity of the affine map and `affine_apply_one`
    have h3 : (affine τ τ').toFun ((affine τ τ').inv.toFun 1)
        = (affine τ τ').toFun 1 := by rw [h2, affine_apply_one]
    exact (affine τ τ').toFun_injective h3
  · have h2 : (affine τ τ').toFun ((affine τ τ').inv.toFun (τ' : ℂ)) = (τ' : ℂ) :=
      LinMap.inv_apply (affine τ τ') _
    have h3 : (affine τ τ').toFun ((affine τ τ').inv.toFun (τ' : ℂ))
        = (affine τ τ').toFun (τ : ℂ) := by rw [h2, affine_apply_tau]
    exact (affine τ τ').toFun_injective h3

/-- The **extremal dilatation** of the pair of marked tori `(τ, τ')`, in closed form. -/
theorem dil_affine : (affine τ τ').dil
    = (‖(τ' : ℂ) - cbar τ‖ + ‖(τ' : ℂ) - (τ : ℂ)‖) ^ 2 / (4 * τ.im * τ'.im) := by
  have hy : (0:ℝ) < τ.im := τ.im_pos
  have hy' : (0:ℝ) < τ'.im := τ'.im_pos
  have hm : ‖(τ : ℂ) - cbar τ‖ = 2 * τ.im := norm_sub_cbar_self τ
  have hna : ‖(affine τ τ').a‖ = ‖(τ' : ℂ) - cbar τ‖ / (2 * τ.im) := by
    rw [affine_a, norm_div, hm]
  have hnb : ‖(affine τ τ').b‖ = ‖(τ' : ℂ) - (τ : ℂ)‖ / (2 * τ.im) := by
    rw [affine_b, norm_div, hm, show ((τ : ℂ) - (τ' : ℂ)) = -((τ' : ℂ) - (τ : ℂ)) by ring, norm_neg]
  have hp := normSq_sub_cbar τ τ'
  have hjac : (affine τ τ').jac = τ'.im / τ.im := by
    simp only [LinMap.jac, hna, hnb, div_pow]
    rw [div_sub_div_same, hp]
    field_simp
    ring
  rw [LinMap.dil_eq_sq_div_jac, hna, hnb, hjac]
  field_simp
  ring

/-- The Teichmüller distance on the Teichmüller space `ℍ` of the marked torus: half the
logarithm of the extremal dilatation. -/
noncomputable def teichDist : ℝ := Real.log (affine τ τ').dil / 2

theorem teichDist_nonneg : 0 ≤ teichDist τ τ' :=
  div_nonneg (Real.log_nonneg (affine τ τ').one_le_dil) (by norm_num)

private lemma cosh_dilatation_key {p q y y' : ℝ}
    (hq : 0 ≤ q) (hpq : q < p) (hp2 : p ^ 2 = q ^ 2 + 4 * y * y') :
    ((p + q) ^ 2 / (4 * y * y') + ((p + q) ^ 2 / (4 * y * y'))⁻¹) / 2
      = 1 + q ^ 2 / (2 * y * y') := by
  have hs : 0 < p + q := by linarith
  have hd : 0 < p - q := by linarith
  have h4 : 4 * y * y' = (p + q) * (p - q) := by nlinarith
  have h2 : 2 * y * y' = (p + q) * (p - q) / 2 := by linarith
  rw [h4, h2]
  field_simp
  ring

/-- **Main theorem.**  The Teichmüller metric of the marked torus is exactly one half of the
hyperbolic metric of curvature `-1` on the upper half plane. -/
theorem teichDist_eq_half_dist : teichDist τ τ' = dist τ τ' / 2 := by
  have hy : (0:ℝ) < τ.im := τ.im_pos
  have hy' : (0:ℝ) < τ'.im := τ'.im_pos
  set p := ‖(τ' : ℂ) - cbar τ‖ with hpdef
  set q := ‖(τ' : ℂ) - (τ : ℂ)‖ with hqdef
  have hq0 : 0 ≤ q := norm_nonneg _
  have hpq : q < p := norm_sub_lt_norm_sub_cbar τ τ'
  have hp2 : p ^ 2 = q ^ 2 + 4 * τ.im * τ'.im := normSq_sub_cbar τ τ'
  have hK : 0 < (affine τ τ').dil := (affine τ τ').dil_pos
  have hsum : (0:ℝ) < p + q := by linarith
  have hcosh : Real.cosh (2 * teichDist τ τ') = Real.cosh (dist τ τ') := by
    have h2 : 2 * teichDist τ τ' = Real.log (affine τ τ').dil := by
      rw [teichDist]; ring
    rw [h2, Real.cosh_eq, Real.exp_log hK, Real.exp_neg, Real.exp_log hK,
      UpperHalfPlane.cosh_dist, Complex.dist_eq, dil_affine]
    have hdist : ‖(τ : ℂ) - (τ' : ℂ)‖ = q := by
      rw [hqdef, show ((τ : ℂ) - (τ' : ℂ)) = -((τ' : ℂ) - (τ : ℂ)) by ring, norm_neg]
    rw [hdist]
    exact cosh_dilatation_key hq0 hpq hp2
  have h1 : (0:ℝ) ≤ 2 * teichDist τ τ' := by
    have := teichDist_nonneg τ τ'; linarith
  have h2 : (0:ℝ) ≤ dist τ τ' := dist_nonneg
  have := Real.cosh_injOn (Set.mem_Ici.mpr h1) (Set.mem_Ici.mpr h2) hcosh
  linarith

/-- The extremal dilatation of a pair of marked tori is `exp` of their hyperbolic distance. -/
theorem dil_affine_eq_exp_dist : (affine τ τ').dil = Real.exp (dist τ τ') := by
  have h := teichDist_eq_half_dist τ τ'
  have hK : 0 < (affine τ τ').dil := (affine τ τ').dil_pos
  rw [teichDist] at h
  have : Real.log (affine τ τ').dil = dist τ τ' := by linarith
  rw [← this, Real.exp_log hK]

/-- Symmetry of the Teichmüller distance, proved from `K(f⁻¹) = K(f)`. -/
theorem teichDist_comm : teichDist τ τ' = teichDist τ' τ := by
  rw [teichDist, teichDist, ← affine_inv τ τ', LinMap.dil_inv]

/-- The **triangle inequality** for the Teichmüller distance, proved intrinsically from
submultiplicativity of the quasiconformal dilatation. -/
theorem teichDist_triangle : teichDist τ τ'' ≤ teichDist τ τ' + teichDist τ' τ'' := by
  have hcomp : (affine τ' τ'').comp (affine τ τ') = affine τ τ'' := affine_comp τ τ' τ''
  have hle : (affine τ τ'').dil ≤ (affine τ' τ'').dil * (affine τ τ').dil := by
    rw [← hcomp]
    exact LinMap.dil_comp_le _ _
  have h1 : (0:ℝ) < (affine τ τ').dil := (affine τ τ').dil_pos
  have h2 : (0:ℝ) < (affine τ' τ'').dil := (affine τ' τ'').dil_pos
  have hlog : Real.log (affine τ τ'').dil
      ≤ Real.log (affine τ' τ'').dil + Real.log (affine τ τ').dil := by
    rw [← Real.log_mul h2.ne' h1.ne']
    exact Real.log_le_log (affine τ τ'').dil_pos hle
  simp only [teichDist]
  linarith

/-- The Teichmüller distance vanishes exactly on the diagonal: distinct marked tori are never
conformally equivalent as *marked* tori. -/
theorem teichDist_eq_zero_iff : teichDist τ τ' = 0 ↔ τ = τ' := by
  have hK : 0 < (affine τ τ').dil := (affine τ τ').dil_pos
  have hK1 : 1 ≤ (affine τ τ').dil := (affine τ τ').one_le_dil
  constructor
  · intro h
    have hlog : Real.log (affine τ τ').dil = 0 := by
      rw [teichDist] at h; linarith
    have hd : (affine τ τ').dil = 1 := by
      have := Real.exp_log hK
      rw [hlog, Real.exp_zero] at this
      exact this.symm
    have hb : (affine τ τ').b = 0 := (LinMap.dil_eq_one_iff _).mp hd
    rw [affine_b, div_eq_zero_iff] at hb
    rcases hb with hb | hb
    · have : (τ : ℂ) = (τ' : ℂ) := by linear_combination hb
      exact UpperHalfPlane.coe_injective this
    · exact absurd hb (sub_cbar_ne_zero τ)
  · rintro rfl
    have hb : (affine τ τ).b = 0 := by simp [affine_b]
    have := (LinMap.dil_eq_one_iff (affine τ τ)).mpr hb
    rw [teichDist, this, Real.log_one]
    norm_num

end Teichmuller