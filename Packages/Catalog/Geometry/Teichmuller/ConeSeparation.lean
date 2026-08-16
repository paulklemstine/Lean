/-
# The systolic functional separates points of the moduli space

`Geometry.Teichmuller.ModuliSpace` shows that the square torus `i` and the hexagonal torus `ρ`
carry stabilisers of order two and three in `PSL(2, ℤ)` and lie in different `SL(2, ℤ)`-orbits
(`Teichmuller.smul_rho_ne_I`).  Lying in different orbits is a *set-theoretic* statement; it
does not by itself say that the two points are far apart, because the moduli distance is only
defined as an infimum over the infinite group `SL(2, ℤ)` and is not known a priori to be
attained.  This file upgrades the separation to a *metric* one.

The mechanism is the systolic functional of `Geometry.Teichmuller.Systole`.  For a fixed
nonzero integer vector `(m, n)` the quantity `Q_{m,n}(z) = |m + n z|² / Im z` satisfies the
sharp two-point inequality `cosh d(z, w) ≥ (Q(z)/Q(w) + Q(w)/Q(z))/2`, so `log Q` is
`1`-Lipschitz for the hyperbolic metric (`Teichmuller.log_le_dist_of_ratio`); and the family
`{Q_{m,n}}` is permuted by the mapping class group (`Teichmuller.normSq_ratio_smul`), so its
pointwise minimum — the systolic ratio — is a function on the *moduli space*.

Main results:

* `Teichmuller.normSq_ratio_smul` : mapping-class-group equivariance of the family `Q_{m,n}`;
* `Teichmuller.log_le_dist_of_ratio` : `log Q_{m,n}` is `1`-Lipschitz;
* `Teichmuller.moduliDist_pos_of_systole_gap` : **if every lattice vector of `z` is longer than
  `r · Im z` while some lattice vector of `w` is shorter than `s · Im w`, then
  `moduliDist z w ≥ (1/2) log (r/s)`** — a lower bound for an infimum over an infinite group,
  obtained with no compactness or properness input;
* `Teichmuller.moduliDist_rho_I_pos` : consequently `moduliDist ρ i ≥ (1/2) log (2/√3) > 0`:
  the two orbifold points of the moduli space of tori are genuinely far apart.

-- !-- Lab Notes -- !--
Hypothesizer: `moduliDist` was only proved to be a pseudometric; is it *ever* provably
nonzero?  Any two distinct orbits should be at positive distance, but that seems to need
properness of the action.  Experimenter: rather than properness, use an invariant.
Numerically `S(τ) = min_{(m,n)≠0} |m+nτ|²/Im τ` takes the value `1` on the whole orbit of `i`
and `2/√3 ≈ 1.154701` at `ρ`; if `log S` is `1`-Lipschitz then `d(ρ, g·i) ≥ log(2/√3) ≈
0.143841` for every `g`, so `moduliDist ρ i ≥ 0.0719 > 0`.  Analyst: the Lipschitz property is
not an estimate but an identity in disguise — writing `ζ = (m+nz)(m+nw)·conj(z-w)` one has
`Im ζ = |m+nz|² Im w - |m+nw|² Im z`, so the required inequality is exactly `(Im ζ)² ≤ |ζ|²`.
Critic: the argument never uses coprimality of `(m,n)`, never needs the minimum defining `S`
to be attained, and never needs compactness — it produces one explicit witness per group
element, via the equivariance `Q_{m,n}(g·τ) = Q_{(m,n)·g}(τ)`, whose index change is the
integral matrix `!![d,b;c,a]` of determinant `1`.  The constant `(1/2)log(2/√3)` is certainly
not optimal (the true distance is that between the two corners of the fundamental domain), but
it is unconditional.
-/
import Mathlib
import Geometry.Teichmuller.Systole

namespace Teichmuller

open Complex UpperHalfPlane Matrix MatrixGroups

/-- A nonzero integer vector gives a nonzero lattice point of a marked torus. -/
theorem normSq_lattice_ne_zero (tau : ℍ) (m n : ℤ) (h : m ≠ 0 ∨ n ≠ 0) :
    Complex.normSq ((m : ℂ) + (n : ℂ) * tau) ≠ 0 := by
  intro hz
  have h0 : ((m : ℂ) + (n : ℂ) * tau) = 0 := Complex.normSq_eq_zero.mp hz
  have him := congrArg Complex.im h0
  simp [Complex.add_im, Complex.mul_im] at him
  rcases him with hn | him
  · have hn0 : n = 0 := by exact_mod_cast hn
    have hre := congrArg Complex.re h0
    rw [hn0] at hre
    simp at hre
    rcases h with h | h
    · exact h (by exact_mod_cast hre)
    · exact h hn0
  · exact absurd him (ne_of_gt tau.im_pos)

/-- The algebraic heart of the Lipschitz estimate: with `u = m + n z`, `v = m + n w` and
`ζ = u v conj(z - w)`, the left-hand side is `(Im ζ)²` and the right-hand side is `|ζ|²`. -/
theorem normSq_im_sub_sq_le (z w : ℍ) (m n : ℝ) :
    (Complex.normSq ((m : ℂ) + n * z) * w.im - Complex.normSq ((m : ℂ) + n * w) * z.im) ^ 2
      ≤ Complex.normSq ((z : ℂ) - w) * (Complex.normSq ((m : ℂ) + n * z) *
        Complex.normSq ((m : ℂ) + n * w)) := by
  set u : ℂ := (m : ℂ) + n * z with hu
  set v : ℂ := (m : ℂ) + n * w with hv
  set zeta : ℂ := u * v * (starRingEnd ℂ) ((z : ℂ) - w) with hzeta
  have h1 : zeta.im = Complex.normSq u * w.im - Complex.normSq v * z.im := by
    simp [hzeta, hu, hv, Complex.normSq_apply, Complex.mul_im, Complex.mul_re,
      UpperHalfPlane.coe_re, UpperHalfPlane.coe_im]
    ring
  have h3 : Complex.normSq zeta
      = Complex.normSq u * Complex.normSq v * Complex.normSq ((z : ℂ) - w) := by
    rw [hzeta, map_mul, map_mul, Complex.normSq_conj]
  have h2 : zeta.im ^ 2 ≤ Complex.normSq zeta := by
    rw [Complex.normSq_apply]
    nlinarith [sq_nonneg zeta.re, sq_nonneg zeta.im]
  rw [h1, h3] at h2
  nlinarith [h2]

/-- **`log Q_{m,n}` is `1`-Lipschitz for the hyperbolic metric.**  If the value of
`Q_{m,n}(z) = |m + n z|² / Im z` at `z` exceeds its value at `w` by a factor `r ≥ 1`, then the
hyperbolic distance from `z` to `w` is at least `log r`. -/
theorem log_le_dist_of_ratio (z w : ℍ) (m n : ℝ) {r : ℝ} (hr : 1 ≤ r)
    (hB : Complex.normSq ((m : ℂ) + n * w) ≠ 0)
    (hle : r * (Complex.normSq ((m : ℂ) + n * w) / w.im)
      ≤ Complex.normSq ((m : ℂ) + n * z) / z.im) :
    Real.log r ≤ dist z w := by
  have hy1 : 0 < z.im := z.im_pos
  have hy2 : 0 < w.im := w.im_pos
  set A := Complex.normSq ((m : ℂ) + n * z) with hA
  set B := Complex.normSq ((m : ℂ) + n * w) with hBd
  have hBpos : 0 < B := lt_of_le_of_ne (Complex.normSq_nonneg _) (Ne.symm hB)
  have hrpos : 0 < r := lt_of_lt_of_le one_pos hr
  have hApos : 0 < A := by
    have h1 : 0 < r * (B / w.im) := by positivity
    have h2 : 0 < A / z.im := lt_of_lt_of_le h1 hle
    have h3 : A = A / z.im * z.im := by field_simp
    rw [h3]; positivity
  set P := A * w.im with hP
  set Q := B * z.im with hQ
  have hPpos : 0 < P := by positivity
  have hQpos : 0 < Q := by positivity
  have hPQ : r * Q ≤ P := by
    have hmul := mul_le_mul_of_nonneg_right hle (le_of_lt (mul_pos hy1 hy2))
    have e1 : r * (B / w.im) * (z.im * w.im) = r * (B * z.im) := by field_simp
    have e2 : A / z.im * (z.im * w.im) = A * w.im := by field_simp
    rw [e1, e2] at hmul
    simpa [hP, hQ] using hmul
  have hkey := normSq_im_sub_sq_le z w m n
  have hcosh : Real.cosh (dist z w)
      = 1 + Complex.normSq ((z : ℂ) - w) / (2 * z.im * w.im) := by
    rw [UpperHalfPlane.cosh_dist, Complex.dist_eq, Complex.sq_norm]
  have hcd : 2 * A * B * z.im * w.im * Real.cosh (dist z w)
      = 2 * A * B * z.im * w.im + Complex.normSq ((z : ℂ) - w) * (A * B) := by
    rw [hcosh]; field_simp
  have hstep : P ^ 2 + Q ^ 2 ≤ 2 * P * Q * Real.cosh (dist z w) := by
    have h2 : 2 * P * Q * Real.cosh (dist z w)
        = 2 * A * B * z.im * w.im * Real.cosh (dist z w) := by simp only [hP, hQ]; ring
    rw [h2, hcd]
    simp only [hP, hQ, hA, hBd]
    nlinarith [hkey]
  have h7 : r ^ 2 + 1 ≤ 2 * r * Real.cosh (dist z w) := by
    have f1 : 0 ≤ P - r * Q := by linarith
    have f2 : 0 ≤ r * P - Q := by nlinarith
    have hprod : (r ^ 2 + 1) * (P * Q) ≤ r * (P ^ 2 + Q ^ 2) := by
      nlinarith [mul_nonneg f1 f2]
    nlinarith [mul_pos hPpos hQpos, hstep, hrpos]
  have h8 : Real.cosh (Real.log r) ≤ Real.cosh (dist z w) := by
    rw [Real.cosh_log hrpos]
    have hrr : (r + r⁻¹) * r = r ^ 2 + 1 := by field_simp
    nlinarith [h7, hrpos]
  have hlog : 0 ≤ Real.log r := Real.log_nonneg hr
  have hfin := Real.cosh_le_cosh.mp h8
  rwa [abs_of_nonneg hlog, abs_of_nonneg dist_nonneg] at hfin

/-- **Equivariance of the systolic family.**  The mapping class group permutes the functions
`Q_{m,n}`: changing the marking by `g = !![a,b;c,d]` replaces the index `(m, n)` by
`(m d + n b, m c + n a)`. -/
theorem normSq_ratio_smul (g : SL(2, ℤ)) (tau : ℍ) (m n : ℤ) :
    Complex.normSq ((m : ℂ) + (n : ℂ) * ((g • tau : ℍ) : ℂ)) / (g • tau : ℍ).im
      = Complex.normSq (((m * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1
            + n * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 1 : ℤ) : ℂ)
          + ((m * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0
            + n * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0 : ℤ) : ℂ) * tau) / tau.im := by
  set a := (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0 with ha
  set b := (g : Matrix (Fin 2) (Fin 2) ℤ) 0 1 with hb
  set c := (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0 with hc
  set d := (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 with hd
  have hden : ((c : ℂ) * tau + d) ≠ 0 := by
    intro h0
    have hd0 := UpperHalfPlane.denom_ne_zero (g : GL (Fin 2) ℝ) tau
    apply hd0
    rw [ModularGroup.denom_apply]
    convert h0 using 2
  have hden' : ((tau : ℂ) * c + d) ≠ 0 := by rw [mul_comm]; exact hden
  have hw : ((g • tau : ℍ) : ℂ) = ((a : ℂ) * tau + b) / ((c : ℂ) * tau + d) := by
    rw [UpperHalfPlane.coe_specialLinearGroup_apply]
    simp
    rfl
  have him : (g • tau : ℍ).im = tau.im / Complex.normSq ((c : ℂ) * tau + d) := by
    rw [ModularGroup.im_smul_eq_div_normSq g tau, ModularGroup.denom_apply]
  have hnum : ((m : ℂ) + (n : ℂ) * ((g • tau : ℍ) : ℂ))
      = (((m * d + n * b : ℤ) : ℂ) + ((m * c + n * a : ℤ) : ℂ) * tau) / ((c : ℂ) * tau + d) := by
    rw [hw]
    field_simp
    push_cast
    ring
  have hns : 0 < Complex.normSq ((c : ℂ) * tau + d) := by
    rcases lt_or_eq_of_le (Complex.normSq_nonneg ((c : ℂ) * tau + d)) with h | h
    · exact h
    · exact absurd (Complex.normSq_eq_zero.mp h.symm) hden
  have hns' : Complex.normSq ((tau : ℂ) * c + d) ≠ 0 := by
    rw [mul_comm]; exact ne_of_gt hns
  have htau : tau.im ≠ 0 := ne_of_gt tau.im_pos
  rw [hnum, him, Complex.normSq_div]
  field_simp

/-- The index change of `normSq_ratio_smul` preserves nonzero vectors: it is given by an
integral matrix of determinant one. -/
theorem index_ne_zero_smul (g : SL(2, ℤ)) (m n : ℤ) (h : m ≠ 0 ∨ n ≠ 0) :
    (m * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 + n * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 1 ≠ 0)
      ∨ (m * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0
          + n * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0 ≠ 0) := by
  set a := (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0 with ha
  set b := (g : Matrix (Fin 2) (Fin 2) ℤ) 0 1 with hb
  set c := (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0 with hc
  set d := (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 with hd
  have hdet : a * d - b * c = 1 := by
    have := g.property; rwa [Matrix.det_fin_two] at this
  by_contra hcon
  push_neg at hcon
  obtain ⟨h1, h2⟩ := hcon
  have hm : m = 0 := by linear_combination a * h1 - b * h2 - m * hdet
  have hn : n = 0 := by linear_combination d * h2 - c * h1 - n * hdet
  rcases h with h | h
  · exact h hm
  · exact h hn

/-- **The systolic ratio separates points of the moduli space.**  If every nonzero lattice
vector of the marked torus `z` has squared length at least `r · Im z`, while *some* nonzero
lattice vector of `w` has squared length at most `s · Im w` (with `0 < s ≤ r`), then the two
tori are at moduli distance at least `(1/2) log (r/s)`.

The bound is uniform over the whole mapping class group orbit of `w`, so it bounds the
infimum defining `moduliDist` from below without any compactness or properness argument. -/
theorem moduliDist_pos_of_systole_gap (z w : ℍ) {r s : ℝ} (hs : 0 < s) (hsr : s ≤ r)
    (hz : ∀ m n : ℤ, (m ≠ 0 ∨ n ≠ 0) → r * z.im ≤ Complex.normSq ((m : ℂ) + (n : ℂ) * z))
    (hw : ∃ m n : ℤ, (m ≠ 0 ∨ n ≠ 0) ∧
      Complex.normSq ((m : ℂ) + (n : ℂ) * w) ≤ s * w.im) :
    Real.log (r / s) / 2 ≤ moduliDist z w := by
  obtain ⟨p, q, hpq, hpqle⟩ := hw
  have hrs : 1 ≤ r / s := (one_le_div hs).mpr hsr
  refine le_ciInf fun g => ?_
  rw [teichDist_eq_half_dist]
  -- transport the short vector of `w` to the translated torus `g • w`
  set gi := g⁻¹ with hgi
  set p' := p * (gi : Matrix (Fin 2) (Fin 2) ℤ) 1 1
      + q * (gi : Matrix (Fin 2) (Fin 2) ℤ) 0 1 with hp'
  set q' := p * (gi : Matrix (Fin 2) (Fin 2) ℤ) 1 0
      + q * (gi : Matrix (Fin 2) (Fin 2) ℤ) 0 0 with hq'
  have hne' : p' ≠ 0 ∨ q' ≠ 0 := index_ne_zero_smul gi p q hpq
  have hinv : (gi • (g • w : ℍ) : ℍ) = w := by rw [hgi, inv_smul_smul]
  have hkey := normSq_ratio_smul gi (g • w : ℍ) p q
  rw [hinv, ← hp', ← hq'] at hkey
  -- so `Q_{p',q'}(g • w) = Q_{p,q}(w) ≤ s`
  have hQw : Complex.normSq ((p' : ℂ) + (q' : ℂ) * ((g • w : ℍ) : ℂ)) / (g • w : ℍ).im ≤ s := by
    rw [← hkey, div_le_iff₀ w.im_pos]
    exact hpqle
  have hQz : r ≤ Complex.normSq ((p' : ℂ) + (q' : ℂ) * (z : ℂ)) / z.im := by
    rw [le_div_iff₀ z.im_pos]
    exact hz p' q' hne'
  have hBne : Complex.normSq (((p' : ℝ) : ℂ) + ((q' : ℝ) : ℂ) * ((g • w : ℍ) : ℂ)) ≠ 0 := by
    have := normSq_lattice_ne_zero (g • w : ℍ) p' q' hne'
    convert this using 3
  have hmain : Real.log (r / s) ≤ dist z (g • w : ℍ) := by
    refine log_le_dist_of_ratio z (g • w : ℍ) ((p' : ℝ)) ((q' : ℝ)) hrs hBne ?_
    have e1 : Complex.normSq (((p' : ℝ) : ℂ) + ((q' : ℝ) : ℂ) * ((g • w : ℍ) : ℂ))
        = Complex.normSq ((p' : ℂ) + (q' : ℂ) * ((g • w : ℍ) : ℂ)) := by
      congr 2
    have e2 : Complex.normSq (((p' : ℝ) : ℂ) + ((q' : ℝ) : ℂ) * (z : ℂ))
        = Complex.normSq ((p' : ℂ) + (q' : ℂ) * (z : ℂ)) := by
      congr 2
    rw [e1, e2]
    have hrsnn : 0 ≤ r / s := le_trans zero_le_one hrs
    calc r / s * (Complex.normSq ((p' : ℂ) + (q' : ℂ) * ((g • w : ℍ) : ℂ)) / (g • w : ℍ).im)
        ≤ r / s * s := by exact mul_le_mul_of_nonneg_left hQw hrsnn
      _ = r := by field_simp
      _ ≤ _ := hQz
  linarith

/-- **The two orbifold points of the moduli space of tori are at positive distance.**
The moduli distance between the hexagonal torus `ρ` and the square torus `i` is at least
`(1/2) log (2/√3) > 0`.  In particular the moduli pseudometric genuinely separates the two
cone points: `smul_rho_ne_I` says their orbits are distinct, and this says they are distinct
*in the metric sense* as well. -/
theorem moduliDist_rho_I_pos : 0 < moduliDist rho UpperHalfPlane.I := by
  have hpos : 0 < Real.sqrt 3 := Real.sqrt_pos.mpr (by norm_num)
  have h3 : Real.sqrt 3 < 2 := by
    nlinarith [Real.sq_sqrt (show (0 : ℝ) ≤ 3 by norm_num), Real.sqrt_nonneg 3]
  have hone : (1 : ℝ) ≤ 2 / Real.sqrt 3 := by rw [le_div_iff₀ hpos]; linarith
  have hgap : 0 < Real.log (2 / Real.sqrt 3 / 1) := by
    rw [div_one]
    exact Real.log_pos (by rw [lt_div_iff₀ hpos]; linarith)
  have hwitness : ∃ m n : ℤ, (m ≠ 0 ∨ n ≠ 0) ∧
      Complex.normSq ((m : ℂ) + (n : ℂ) * UpperHalfPlane.I) ≤ 1 * UpperHalfPlane.I.im := by
    refine ⟨1, 0, Or.inl one_ne_zero, ?_⟩
    simp [UpperHalfPlane.I]
  have hbound := moduliDist_pos_of_systole_gap rho UpperHalfPlane.I one_pos hone
    (fun m n h => le_normSq_rho m n h) hwitness
  linarith

end Teichmuller