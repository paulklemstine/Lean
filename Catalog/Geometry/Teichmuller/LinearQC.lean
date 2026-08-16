/-
# Quasiconformal dilatation of real-linear maps of the plane

This file develops, from scratch, the *infinitesimal* layer of Teichmüller theory: the
quasiconformal dilatation of an orientation-preserving, nonsingular `ℝ`-linear map of `ℂ`.

Every `ℝ`-linear map `f : ℂ → ℂ` has the unique normal form

    f z = a * z + b * conj z ,          a b : ℂ,

with Jacobian determinant `‖a‖² - ‖b‖²`; the map is orientation preserving and invertible
exactly when `‖b‖ < ‖a‖`.  Its *Beltrami coefficient* is `μ = b / a` and its *dilatation* is

    K f = (‖a‖ + ‖b‖) / (‖a‖ - ‖b‖) = (1 + ‖μ‖) / (1 - ‖μ‖),

the ratio of the major to the minor axis of the ellipse `f '' (unit circle)`.

The mathematical core of the file is the exact **determinant identity**

    ‖A‖² - ‖B‖² = (‖a‖² - ‖b‖²) * (‖c‖² - ‖d‖²)

for the composite `(A, B)` of `(a, b)` and `(c, d)` (`LinMap.normSq_sub_normSq_comp`), which
combined with the crude triangle bound `‖A‖ + ‖B‖ ≤ (‖a‖ + ‖b‖)(‖c‖ + ‖d‖)` yields
**submultiplicativity of the dilatation** `K (f ∘ g) ≤ K f * K g` through the identity
`K = (‖a‖ + ‖b‖)² / (‖a‖² - ‖b‖²)`.  This is the statement that makes `log K` a metric
downstream (`Geometry.Teichmuller.TorusSpace`).

Main results:

* `LinMap.one_le_dil` : dilatation is at least `1`;
* `LinMap.dil_eq_one_iff` : dilatation `1` ⇔ the map is conformal (`ℂ`-linear);
* `LinMap.comp_apply` : the composition formula is correct as maps of `ℂ`;
* `LinMap.dil_comp_le` : `K (f ∘ g) ≤ K f * K g`;
* `LinMap.dil_inv` : `K (f⁻¹) = K f`, and `LinMap.inv_apply` verifies the inverse formula;
* `LinMap.dil_eq_beltrami` : `K = (1 + ‖μ‖) / (1 - ‖μ‖)`.

-- !-- Lab Notes -- !--
Hypothesizer: the submultiplicativity `K(f∘g) ≤ K(f)K(g)` — the axiom that makes the
Teichmüller metric a metric — should be a purely algebraic identity, not an analytic estimate.
Experimenter: the naive bound `‖A‖ - ‖B‖ ≥ (‖a‖-‖b‖)(‖c‖-‖d‖)` is FALSE termwise (the triangle
inequality loses `2‖b‖‖d‖`); the repair is to bound the *product* `(‖A‖-‖B‖)(‖A‖+‖B‖)` exactly:
the cross terms `2Re(a c conj b conj d)` in `‖A‖²` and `‖B‖²` cancel identically, giving the
determinant identity.  Analyst: the lost factor is exactly the multiplicativity of the Jacobian;
the correct formulation of `K` for the estimate is `K = (‖a‖+‖b‖)²/(‖a‖²-‖b‖²)`, i.e. "square of
an operator norm over a determinant", which is the shape that composes.
-/
import Mathlib

namespace Teichmuller

open Complex

/-- An orientation-preserving, nonsingular `ℝ`-linear self-map of `ℂ`, in the normal form
`z ↦ a * z + b * conj z`.  Nonsingularity and orientation-preservation are encoded by
`‖b‖ < ‖a‖`, i.e. positivity of the Jacobian `‖a‖² - ‖b‖²`. -/
structure LinMap where
  a : ℂ
  b : ℂ
  norm_lt : ‖b‖ < ‖a‖

namespace LinMap

variable (f g : LinMap)

/-- The underlying map `ℂ → ℂ`. -/
def toFun (z : ℂ) : ℂ := f.a * z + f.b * (starRingEnd ℂ) z

theorem norm_a_pos : 0 < ‖f.a‖ := (norm_nonneg _).trans_lt f.norm_lt

theorem a_ne_zero : f.a ≠ 0 := by
  simpa using norm_pos_iff.mp f.norm_a_pos

/-- The Jacobian determinant `‖a‖² - ‖b‖²`, positive by assumption. -/
noncomputable def jac : ℝ := ‖f.a‖ ^ 2 - ‖f.b‖ ^ 2

theorem jac_pos : 0 < f.jac := by
  have h := f.norm_lt
  have := norm_nonneg f.b
  simp only [jac]
  nlinarith

/-- The dilatation `K = (‖a‖ + ‖b‖)/(‖a‖ - ‖b‖)`: the eccentricity of the image of the unit
circle. -/
noncomputable def dil : ℝ := (‖f.a‖ + ‖f.b‖) / (‖f.a‖ - ‖f.b‖)

/-- The Beltrami coefficient `μ = b / a`. -/
noncomputable def beltrami : ℂ := f.b / f.a

theorem sub_pos' : 0 < ‖f.a‖ - ‖f.b‖ := sub_pos.mpr f.norm_lt

theorem add_pos' : 0 < ‖f.a‖ + ‖f.b‖ := by
  have := f.norm_a_pos; have := norm_nonneg f.b; linarith

theorem one_le_dil : 1 ≤ f.dil := by
  rw [dil, le_div_iff₀ f.sub_pos']
  have := norm_nonneg f.b
  linarith

theorem dil_pos : 0 < f.dil := lt_of_lt_of_le one_pos f.one_le_dil

/-- The dilatation is `1` exactly for conformal (i.e. `ℂ`-linear) maps. -/
theorem dil_eq_one_iff : f.dil = 1 ↔ f.b = 0 := by
  rw [dil, div_eq_one_iff_eq f.sub_pos'.ne']
  constructor
  · intro h
    have : ‖f.b‖ = 0 := by linarith
    simpa using this
  · intro h; simp [h]

/-- Dilatation one implies the map is `ℂ`-linear, i.e. conformal. -/
theorem toFun_eq_smul_of_dil_eq_one (h : f.dil = 1) (z : ℂ) : f.toFun z = f.a * z := by
  simp [toFun, (dil_eq_one_iff f).mp h]

/-- The "determinant form" of the dilatation: `K = (‖a‖+‖b‖)² / jac`. -/
theorem dil_eq_sq_div_jac : f.dil = (‖f.a‖ + ‖f.b‖) ^ 2 / f.jac := by
  have h2 : f.jac = (‖f.a‖ + ‖f.b‖) * (‖f.a‖ - ‖f.b‖) := by simp only [jac]; ring
  rw [dil, h2]
  have h1 : (0:ℝ) < ‖f.a‖ - ‖f.b‖ := f.sub_pos'
  have h3 : (0:ℝ) < ‖f.a‖ + ‖f.b‖ := f.add_pos'
  field_simp

/-- Composition of two real-linear maps, in normal form. -/
noncomputable def comp : LinMap where
  a := f.a * g.a + f.b * (starRingEnd ℂ) g.b
  b := f.a * g.b + f.b * (starRingEnd ℂ) g.a
  norm_lt := by
    set A := f.a * g.a + f.b * (starRingEnd ℂ) g.b with hA
    set B := f.a * g.b + f.b * (starRingEnd ℂ) g.a with hB
    have key : ‖A‖ ^ 2 - ‖B‖ ^ 2 = (‖f.a‖ ^ 2 - ‖f.b‖ ^ 2) * (‖g.a‖ ^ 2 - ‖g.b‖ ^ 2) := by
      simp only [hA, hB, ← Complex.normSq_eq_norm_sq, Complex.normSq_apply,
        Complex.add_re, Complex.add_im, Complex.mul_re, Complex.mul_im, Complex.conj_re,
        Complex.conj_im]
      ring
    have hf := f.jac_pos
    have hg := g.jac_pos
    simp only [jac] at hf hg
    have hpos : 0 < ‖A‖ ^ 2 - ‖B‖ ^ 2 := by rw [key]; positivity
    nlinarith [norm_nonneg A, norm_nonneg B]

@[simp] theorem comp_a : (f.comp g).a = f.a * g.a + f.b * (starRingEnd ℂ) g.b := rfl
@[simp] theorem comp_b : (f.comp g).b = f.a * g.b + f.b * (starRingEnd ℂ) g.a := rfl

/-- The composition formula is correct: it computes the composite map. -/
theorem comp_apply (z : ℂ) : (f.comp g).toFun z = f.toFun (g.toFun z) := by
  simp only [toFun, comp_a, comp_b, map_add, map_mul, Complex.conj_conj]
  ring

/-- **Multiplicativity of the Jacobian**: the exact identity behind submultiplicativity of the
dilatation.  The cross terms `2 Re (a c conj b conj d)` cancel. -/
theorem normSq_sub_normSq_comp :
    ‖(f.comp g).a‖ ^ 2 - ‖(f.comp g).b‖ ^ 2 = f.jac * g.jac := by
  simp only [comp_a, comp_b, jac, ← Complex.normSq_eq_norm_sq, Complex.normSq_apply,
    Complex.add_re, Complex.add_im, Complex.mul_re, Complex.mul_im, Complex.conj_re,
    Complex.conj_im]
  ring

theorem jac_comp : (f.comp g).jac = f.jac * g.jac := f.normSq_sub_normSq_comp g

/-- **Submultiplicativity of the dilatation** `K (f ∘ g) ≤ K f * K g`. -/
theorem dil_comp_le : (f.comp g).dil ≤ f.dil * g.dil := by
  have hjac : (f.comp g).jac = f.jac * g.jac := f.jac_comp g
  have hsum : ‖(f.comp g).a‖ + ‖(f.comp g).b‖ ≤ (‖f.a‖ + ‖f.b‖) * (‖g.a‖ + ‖g.b‖) := by
    have h1 : ‖f.a * g.a + f.b * (starRingEnd ℂ) g.b‖ ≤ ‖f.a‖ * ‖g.a‖ + ‖f.b‖ * ‖g.b‖ := by
      refine (norm_add_le _ _).trans ?_
      simp
    have h2 : ‖f.a * g.b + f.b * (starRingEnd ℂ) g.a‖ ≤ ‖f.a‖ * ‖g.b‖ + ‖f.b‖ * ‖g.a‖ := by
      refine (norm_add_le _ _).trans ?_
      simp
    simp only [comp_a, comp_b]
    nlinarith [h1, h2]
  rw [dil_eq_sq_div_jac, dil_eq_sq_div_jac, dil_eq_sq_div_jac, hjac, div_mul_div_comm,
    div_le_div_iff_of_pos_right (mul_pos f.jac_pos g.jac_pos)]
  have hnn : 0 ≤ ‖(f.comp g).a‖ + ‖(f.comp g).b‖ := by positivity
  nlinarith [hsum, hnn]

/-- The inverse map, again in normal form. -/
noncomputable def inv : LinMap where
  a := (starRingEnd ℂ) f.a / (f.jac : ℂ)
  b := -f.b / (f.jac : ℂ)
  norm_lt := by
    have hj : (0:ℝ) < f.jac := f.jac_pos
    have h : ‖((f.jac : ℝ) : ℂ)‖ = f.jac := by
      simp [Complex.norm_real, abs_of_pos hj]
    simp only [norm_div, norm_neg, RCLike.norm_conj, h]
    have := f.norm_lt
    gcongr

@[simp] theorem inv_a : f.inv.a = (starRingEnd ℂ) f.a / (f.jac : ℂ) := rfl
@[simp] theorem inv_b : f.inv.b = -f.b / (f.jac : ℂ) := rfl

/-- The inverse formula is correct. -/
theorem inv_apply (z : ℂ) : f.toFun (f.inv.toFun z) = z := by
  have hj : ((f.jac : ℝ) : ℂ) ≠ 0 := by exact_mod_cast f.jac_pos.ne'
  have hjr : ((f.jac : ℝ) : ℂ) = f.a * (starRingEnd ℂ) f.a - f.b * (starRingEnd ℂ) f.b := by
    have ha : ((‖f.a‖ ^ 2 : ℝ) : ℂ) = f.a * (starRingEnd ℂ) f.a := by
      rw [← Complex.normSq_eq_norm_sq]
      simp [Complex.normSq_eq_conj_mul_self, mul_comm]
    have hb : ((‖f.b‖ ^ 2 : ℝ) : ℂ) = f.b * (starRingEnd ℂ) f.b := by
      rw [← Complex.normSq_eq_norm_sq]
      simp [Complex.normSq_eq_conj_mul_self, mul_comm]
    simp only [jac, Complex.ofReal_sub]
    rw [ha, hb]
  have h1 : f.inv.toFun z
      = ((starRingEnd ℂ) f.a * z - f.b * (starRingEnd ℂ) z) / ((f.jac : ℝ) : ℂ) := by
    simp only [toFun, inv_a, inv_b]
    ring
  rw [toFun, h1, map_div₀, map_sub, map_mul, map_mul, Complex.conj_conj, Complex.conj_ofReal]
  field_simp
  simp only [Complex.conj_conj]
  linear_combination (-z) * hjr

theorem toFun_sub (x y : ℂ) : f.toFun (x - y) = f.toFun x - f.toFun y := by
  simp only [toFun, map_sub]
  ring

/-- A nonsingular real-linear map is injective. -/
theorem toFun_injective : Function.Injective f.toFun := by
  intro x y hxy
  have h0 : f.toFun (x - y) = 0 := by rw [toFun_sub, hxy, sub_self]
  have hw : f.a * (x - y) = -(f.b * (starRingEnd ℂ) (x - y)) := by
    simp only [toFun] at h0
    linear_combination h0
  have hnorm : ‖f.a‖ * ‖x - y‖ = ‖f.b‖ * ‖x - y‖ := by
    have h := congrArg norm hw
    rw [norm_mul, norm_neg, norm_mul, RCLike.norm_conj] at h
    exact h
  have hz : ‖x - y‖ = 0 := by
    rcases eq_or_lt_of_le (norm_nonneg (x - y)) with h | h
    · exact h.symm
    · nlinarith [f.norm_lt]
  exact sub_eq_zero.mp (norm_eq_zero.mp hz)

/-- The dilatation of the inverse equals the dilatation. -/
theorem dil_inv : f.inv.dil = f.dil := by
  have hj : (0:ℝ) < f.jac := f.jac_pos
  have h : ‖((f.jac : ℝ) : ℂ)‖ = f.jac := by simp [Complex.norm_real, abs_of_pos hj]
  have hsum : ‖f.a‖ / f.jac + ‖f.b‖ / f.jac = (‖f.a‖ + ‖f.b‖) / f.jac := by ring
  have hsub : ‖f.a‖ / f.jac - ‖f.b‖ / f.jac = (‖f.a‖ - ‖f.b‖) / f.jac := by ring
  have hs : (0:ℝ) < ‖f.a‖ - ‖f.b‖ := f.sub_pos'
  simp only [dil, inv_a, inv_b, norm_div, norm_neg, RCLike.norm_conj, h, hsum, hsub]
  field_simp

/-- The Beltrami coefficient has norm `< 1`. -/
theorem norm_beltrami_lt_one : ‖f.beltrami‖ < 1 := by
  rw [beltrami, norm_div, div_lt_one f.norm_a_pos]
  exact f.norm_lt

/-- The classical formula `K = (1 + ‖μ‖)/(1 - ‖μ‖)` for the dilatation in terms of the Beltrami
coefficient. -/
theorem dil_eq_beltrami : f.dil = (1 + ‖f.beltrami‖) / (1 - ‖f.beltrami‖) := by
  have ha : (0:ℝ) < ‖f.a‖ := f.norm_a_pos
  have hmu : ‖f.beltrami‖ < 1 := f.norm_beltrami_lt_one
  rw [beltrami, norm_div] at hmu ⊢
  rw [dil, div_eq_div_iff f.sub_pos'.ne' (by linarith)]
  field_simp

end LinMap

end Teichmuller