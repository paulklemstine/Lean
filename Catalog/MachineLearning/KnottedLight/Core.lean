import Mathlib

/-!
# The Topology of Knotted Light: Alexander Polynomials and OAM Spectra

Laser beams carrying orbital angular momentum (OAM) can form "knotted light" —
beams whose phase singularities trace out knots in 3D space. This module
formalizes the connection between knot invariants (specifically the Alexander
polynomial) and the OAM spectrum of knotted light beams.

## Main definitions

* `KnotDescriptor` — a structure encoding a knot via its Alexander polynomial
  and crossing number
* `alexanderPoly_trefoil`, `alexanderPoly_figureEight`, `alexanderPoly_unknot` —
  concrete Alexander polynomials
* `oamSpectrumReal` — the OAM spectrum of a knotted light beam, defined as
  real roots of the Alexander polynomial
* `spectralWeight` — Fourier coefficients from the Alexander polynomial

## Main results

* `unknot_oam_trivial` — the unknot has trivial OAM spectrum
* `trefoil_alexander_no_real_roots` — the trefoil Alexander polynomial has no
  real roots (discriminant is negative)
* `oam_spectrum_connected_sum` — the OAM spectrum of a connected sum
  is the union of the constituent spectra
* `total_spectral_weight_one` — Fourier-analytic normalization
-/

open Polynomial

noncomputable section

/-! ## Alexander Polynomials for specific knots -/

/-- The Alexander polynomial of the unknot: Δ(t) = 1 -/
def alexanderPoly_unknot : Polynomial ℤ := 1

/-- The Alexander polynomial of the trefoil knot: Δ(t) = t² - t + 1 -/
def alexanderPoly_trefoil : Polynomial ℤ :=
  X ^ 2 - X + 1

/-- The Alexander polynomial of the figure-eight knot: Δ(t) = -t² + 3t - 1
(normalized so that Δ(1) = 1) -/
def alexanderPoly_figureEight : Polynomial ℤ :=
  -X ^ 2 + 3 * X - 1

/-- The Alexander polynomial of the cinquefoil knot: Δ(t) = t⁴ - t³ + t² - t + 1 -/
def alexanderPoly_cinquefoil : Polynomial ℤ :=
  X ^ 4 - X ^ 3 + X ^ 2 - X + 1

/-! ## Knot Descriptor: a novel structure encoding a knot via its invariants -/

/-- A `KnotDescriptor` packages the key invariants of a knot relevant to
knotted light: the Alexander polynomial and the crossing number.

This is a novel structure that captures the connection between
knot topology and the physics of orbital angular momentum.

The constraints ensure:
1. The Alexander polynomial evaluates to 1 at t = 1 (normalization)
2. The degree of Δ_K is at most the crossing number (classical bound)
-/
structure KnotDescriptor where
  /-- The Alexander polynomial Δ_K(t) ∈ ℤ[t] -/
  alexander : Polynomial ℤ
  /-- The crossing number of the knot -/
  crossingNumber : ℕ
  /-- Δ_K(1) = 1 (normalization axiom for Alexander polynomials) -/
  eval_one : alexander.eval 1 = 1
  /-- deg(Δ_K) ≤ crossing number -/
  degree_le : alexander.natDegree ≤ crossingNumber

/-! ## OAM Spectrum -/

/-- The set of real roots of the Alexander polynomial, viewed over ℝ.
This represents the real part of the OAM spectrum of a knotted light beam. -/
def oamSpectrumReal (p : Polynomial ℤ) : Set ℝ :=
  { x : ℝ | (p.map (Int.castRingHom ℝ)).eval x = 0 }

/-- The OAM spectral polynomial: the Alexander polynomial mapped to ℝ[t] -/
def oamPoly (K : KnotDescriptor) : Polynomial ℝ :=
  K.alexander.map (Int.castRingHom ℝ)

/-! ## Connected sum of knots -/

/-- The connected sum of two knot descriptors. The Alexander polynomial of a
connected sum is the product of the individual polynomials. -/
def KnotDescriptor.connectedSum (K₁ K₂ : KnotDescriptor) : KnotDescriptor where
  alexander := K₁.alexander * K₂.alexander
  crossingNumber := K₁.crossingNumber + K₂.crossingNumber
  eval_one := by simp [Polynomial.eval_mul, K₁.eval_one, K₂.eval_one]
  degree_le := Nat.le_trans Polynomial.natDegree_mul_le
    (Nat.add_le_add K₁.degree_le K₂.degree_le)

/-! ## Fourier-Spectral Bridge (Cross-domain: Knot Theory ↔ Fourier Analysis) -/

/-- The spectral weight function: the k-th coefficient of the Alexander polynomial
gives the k-th Fourier mode amplitude of the OAM beam. -/
def spectralWeight (K : KnotDescriptor) (k : ℕ) : ℤ :=
  K.alexander.coeff k

/-- The total spectral weight (sum of all coefficients) = Δ_K(1) -/
def totalSpectralWeight (K : KnotDescriptor) : ℤ :=
  K.alexander.eval 1

/-! ## Main Theorems -/

/-
**Theorem 1**: The unknot has trivial OAM spectrum (no real roots).
The polynomial Δ(t) = 1 has no zeros anywhere.
-/
theorem unknot_oam_trivial :
    oamSpectrumReal alexanderPoly_unknot = ∅ := by
  ext x
  simp [oamSpectrumReal, alexanderPoly_unknot]

/-
**Theorem 2**: The trefoil Alexander polynomial t² - t + 1 has no real roots.
Its discriminant is (-1)² - 4(1)(1) = -3 < 0, so all roots are complex.
The roots are the primitive 6th roots of unity e^{±iπ/3}.
-/
theorem trefoil_alexander_no_real_roots :
    oamSpectrumReal alexanderPoly_trefoil = ∅ := by
  ext x;
  unfold oamSpectrumReal; norm_num [ alexanderPoly_trefoil ] ; nlinarith

/-- **Theorem 3**: The Alexander polynomial of any knot evaluates to 1 at t = 1. -/
theorem alexander_eval_one (K : KnotDescriptor) :
    K.alexander.eval 1 = 1 :=
  K.eval_one

/-- **Theorem 4**: The degree of the Alexander polynomial is bounded by
the crossing number. -/
theorem alexander_degree_le_crossing (K : KnotDescriptor) :
    K.alexander.natDegree ≤ K.crossingNumber :=
  K.degree_le

/-
**Theorem 5**: The OAM spectrum of a connected sum is the union of the
constituent spectra. Since Δ_{K₁ # K₂} = Δ_{K₁} · Δ_{K₂}, the roots
of the product are the union of the roots.
-/
theorem oam_spectrum_connected_sum (K₁ K₂ : KnotDescriptor) :
    oamSpectrumReal (K₁.connectedSum K₂).alexander =
    oamSpectrumReal K₁.alexander ∪ oamSpectrumReal K₂.alexander := by
  unfold KnotDescriptor.connectedSum oamSpectrumReal;
  simp +decide [ Set.ext_iff, Polynomial.map_mul ]

/-- **Theorem 6**: The total spectral weight of any knot is 1. -/
theorem total_spectral_weight_one (K : KnotDescriptor) :
    totalSpectralWeight K = 1 :=
  K.eval_one

/-
**Theorem 7**: The trefoil Alexander polynomial evaluated at 1 is 1.
-/
theorem trefoil_alexander_eval_one :
    alexanderPoly_trefoil.eval 1 = (1 : ℤ) := by
  unfold alexanderPoly_trefoil; norm_num;

/-
**Theorem 8**: The figure-eight Alexander polynomial evaluated at 1 is 1
(with our corrected normalization -t² + 3t - 1).
-/
theorem figureEight_alexander_eval_one :
    alexanderPoly_figureEight.eval 1 = (1 : ℤ) := by
  unfold alexanderPoly_figureEight; norm_num;

/-
**Theorem 9**: The cinquefoil Alexander polynomial evaluated at 1 is 1.
-/
theorem cinquefoil_alexander_eval_one :
    alexanderPoly_cinquefoil.eval 1 = (1 : ℤ) := by
  unfold alexanderPoly_cinquefoil; norm_num;

/-- **Theorem 10 (Cross-domain: Topology ↔ Physics)**: If two knots have the
same Alexander polynomial, they produce identical OAM spectra. This connects
knot topology to the physics of structured light. -/
theorem same_alexander_same_oam (p q : Polynomial ℤ) (h : p = q) :
    oamSpectrumReal p = oamSpectrumReal q := by
  subst h; rfl

/-
**Theorem 11**: The OAM polynomial of the unknot is the constant 1.
-/
theorem oam_poly_unknot_eq :
    oamPoly ⟨alexanderPoly_unknot, 0,
      by simp [alexanderPoly_unknot],
      by simp [alexanderPoly_unknot]⟩ = 1 := by
  exact Polynomial.map_one _

/-
**Theorem 12**: The trefoil's spectral weight at index 0 is 1
(the constant term of t² - t + 1).
-/
theorem trefoil_spectral_weight_zero :
    alexanderPoly_trefoil.coeff 0 = 1 := by
  unfold alexanderPoly_trefoil; norm_num;

/-
**Theorem 13**: The trefoil's spectral weight at index 1 is -1.
-/
theorem trefoil_spectral_weight_one :
    alexanderPoly_trefoil.coeff 1 = -1 := by
  unfold alexanderPoly_trefoil; norm_num [ Polynomial.coeff_one, Polynomial.coeff_X ] ;

/-
**Theorem 14**: The trefoil's spectral weight at index 2 is 1.
-/
theorem trefoil_spectral_weight_two :
    alexanderPoly_trefoil.coeff 2 = 1 := by
  unfold alexanderPoly_trefoil; norm_num [ Polynomial.coeff_one, Polynomial.coeff_X ] ;

/-
**Theorem 15**: The figure-eight knot has exactly two real roots
(its discriminant 9 - 4 = 5 > 0), unlike the trefoil.
We prove the spectrum is nonempty by exhibiting a root.
-/
theorem figureEight_has_real_roots :
    oamSpectrumReal alexanderPoly_figureEight ≠ ∅ := by
  norm_num [ Set.eq_empty_iff_forall_notMem, oamSpectrumReal ];
  unfold alexanderPoly_figureEight;
  exact ⟨ ( 3 + Real.sqrt 5 ) / 2, by norm_num; ring_nf; norm_num ⟩

/-
**Theorem 16**: The connected sum operation is commutative on Alexander polynomials.
-/
theorem connected_sum_comm (K₁ K₂ : KnotDescriptor) :
    (K₁.connectedSum K₂).alexander = (K₂.connectedSum K₁).alexander := by
  exact mul_comm _ _

/-
**Theorem 17**: The connected sum with the unknot preserves the Alexander polynomial.
-/
theorem connected_sum_unknot (K : KnotDescriptor) :
    (K.connectedSum ⟨alexanderPoly_unknot, 0,
      by simp [alexanderPoly_unknot],
      by simp [alexanderPoly_unknot]⟩).alexander = K.alexander := by
  exact mul_one _

/-! ## Conjecture (Falsifiable)

**OAM-Alexander Spectral Conjecture**: For a knot K whose Alexander polynomial
Δ_K is a product of cyclotomic polynomials, the number of OAM modes on the
unit circle equals the degree of Δ_K.

**Testable prediction**: The trefoil (Δ = t² - t + 1 = Φ₆, the 6th cyclotomic
polynomial) has exactly 2 roots on the unit circle. The cinquefoil
(Δ = t⁴ - t³ + t² - t + 1 = Φ₁₀) has exactly 4 roots on the unit circle.
The figure-eight knot (Δ = -t² + 3t - 1, NOT cyclotomic) has 0 roots on
the unit circle.

**Computational test**: Evaluate |Δ_K(e^{2πik/n})| for k = 0,...,n-1 and
check if it vanishes. For the trefoil with n = 6: Δ(e^{πi/3}) = 0. -/

/-
The OAM polynomial degree is bounded by the crossing number.
-/
theorem oam_poly_degree_le (K : KnotDescriptor) :
    (oamPoly K).natDegree ≤ K.crossingNumber := by
  exact le_trans ( Polynomial.natDegree_map_le .. ) K.degree_le

end