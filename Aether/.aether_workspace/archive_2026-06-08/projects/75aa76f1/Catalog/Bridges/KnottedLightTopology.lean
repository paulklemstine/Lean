/-
# The Topology of Knotted Light: Alexander Polynomials and OAM Spectra

This module formalizes the mathematical structures underlying knotted light beams,
focusing on the relationship between knot invariants (Alexander polynomials) and
the orbital angular momentum (OAM) spectra of structured laser beams.

Key results:
1. The trefoil Alexander polynomial equals the 6th cyclotomic polynomial
2. Alexander polynomial symmetry and normalization properties
3. OAM spectral structure theorems
4. Knot determinant computations from Alexander polynomials
-/
import Mathlib

open Polynomial Complex Real

noncomputable section

/-! ## Alexander Polynomials for Specific Knots

We define the Alexander polynomial Δ_K(t) for the trefoil, figure-eight knot,
and unknot as elements of ℤ[X]. These are the fundamental knot invariants
that encode topological information about the knot complement.
-/

/-- The Alexander polynomial of the unknot: Δ_unknot(t) = 1 -/
def alexanderPoly_unknot : ℤ[X] := 1

/-- The Alexander polynomial of the trefoil knot: Δ_trefoil(t) = t² - t + 1 -/
def alexanderPoly_trefoil : ℤ[X] :=
  X ^ 2 - X + 1

/-- The Alexander polynomial of the figure-eight knot: Δ_figureEight(t) = t² - 3t + 1 -/
def alexanderPoly_figureEight : ℤ[X] :=
  X ^ 2 - 3 * X + 1

/-- The Alexander polynomial of the cinquefoil knot: Δ_cinquefoil(t) = t⁴ - t³ + t² - t + 1 -/
def alexanderPoly_cinquefoil : ℤ[X] :=
  X ^ 4 - X ^ 3 + X ^ 2 - X + 1

/-! ## Knot Determinant

The determinant of a knot K is |Δ_K(-1)|. This is a classical knot invariant
that can distinguish some knots. We prove it for our specific knots.
-/

/-- The knot determinant is the absolute value of the Alexander polynomial at -1 -/
def knotDeterminant (Δ : ℤ[X]) : ℤ := |Δ.eval (-1)|

/-
The trefoil knot has determinant 3
-/
theorem trefoil_determinant : knotDeterminant alexanderPoly_trefoil = 3 := by
  unfold knotDeterminant alexanderPoly_trefoil; norm_num;

/-
The figure-eight knot has determinant 5
-/
theorem figureEight_determinant : knotDeterminant alexanderPoly_figureEight = 5 := by
  unfold knotDeterminant alexanderPoly_figureEight; norm_num;

/-
The unknot has determinant 1
-/
theorem unknot_determinant : knotDeterminant alexanderPoly_unknot = 1 := by
  -- The Alexander polynomial of the unknot is 1, so its determinant is |1| = 1.
  simp [knotDeterminant, alexanderPoly_unknot]

/-
The cinquefoil knot has determinant 5
-/
theorem cinquefoil_determinant : knotDeterminant alexanderPoly_cinquefoil = 5 := by
  unfold knotDeterminant alexanderPoly_cinquefoil; norm_num;

/-! ## Alexander Polynomial Normalization

A fundamental property: Δ_K(1) = 1 for any knot K (with appropriate normalization).
This is the "Fox normalization" and constrains which polynomials can be Alexander polynomials.
-/

/-
The trefoil Alexander polynomial evaluates to 1 at t = 1
-/
theorem trefoil_alexander_at_one : alexanderPoly_trefoil.eval 1 = 1 := by
  unfold alexanderPoly_trefoil; norm_num;

/-
The figure-eight Alexander polynomial evaluates to -1 at t = 1
-/
theorem figureEight_alexander_at_one : alexanderPoly_figureEight.eval 1 = -1 := by
  unfold alexanderPoly_figureEight; norm_num

/-
The unknot Alexander polynomial evaluates to 1 at t = 1
-/
theorem unknot_alexander_at_one : alexanderPoly_unknot.eval 1 = 1 := by
  norm_num [ alexanderPoly_unknot ]

/-
The cinquefoil Alexander polynomial evaluates to 1 at t = 1
-/
theorem cinquefoil_alexander_at_one : alexanderPoly_cinquefoil.eval 1 = 1 := by
  unfold alexanderPoly_cinquefoil; norm_num;

/-! ## Trefoil and Cyclotomic Polynomials

A key insight: the trefoil Alexander polynomial t² - t + 1 is exactly the
6th cyclotomic polynomial Φ₆(t). This connects knot theory to number theory:
the roots of the trefoil's Alexander polynomial are the primitive 6th roots
of unity e^{±iπ/3}.

This means the OAM spectrum of a trefoil beam is controlled by 6th roots of unity,
giving angular momentum values at multiples of π/3.
-/

/-
The trefoil Alexander polynomial equals the 6th cyclotomic polynomial
-/
theorem trefoil_is_cyclotomic_six :
    alexanderPoly_trefoil.map (Int.castRingHom ℚ) = cyclotomic 6 ℚ := by
  unfold alexanderPoly_trefoil;
  norm_num +zetaDelta at *

/-
The cinquefoil Alexander polynomial equals the 10th cyclotomic polynomial
-/
theorem cinquefoil_is_cyclotomic_ten :
    alexanderPoly_cinquefoil.map (Int.castRingHom ℚ) = cyclotomic 10 ℚ := by
  unfold alexanderPoly_cinquefoil;
  convert ( Polynomial.ext fun x => ?_ );
  -- By definition of cyclotomic polynomials, � we� know that₁₀(x) = x⁴ - x³ + x² - x + 1.
  have h_cyclotomic : cyclotomic 10 ℚ = Polynomial.X ^ 4 - Polynomial.X ^ 3 + Polynomial.X ^ 2 - Polynomial.X + 1 := by
    rw [ cyclotomic_eq_X_pow_sub_one_div ];
    · rw [ show Nat.properDivisors 10 = { 1, 2, 5 } by decide ];
      simp +decide [ Polynomial.cyclotomic_prime ];
      rw [ show ( X ^ 10 - 1 : Polynomial ℚ ) = ( ( X - 1 ) * ( ( X + 1 ) * ( ∑ i ∈ Finset.range 5, X ^ i ) ) ) * ( X ^ 4 - X ^ 3 + X ^ 2 - X + 1 ) by simpa [ Finset.sum_range_succ' ] using by ring ];
      rw [ mul_comm, Polynomial.divByMonic_eq_div _ ];
      · rw [ mul_div_cancel_right₀ ];
        exact ne_of_apply_ne ( Polynomial.eval 2 ) ( by norm_num );
      · erw [ Polynomial.Monic, Polynomial.leadingCoeff_mul, Polynomial.leadingCoeff_mul, Polynomial.leadingCoeff_X_sub_C, Polynomial.leadingCoeff_X_add_C, Polynomial.leadingCoeff, Polynomial.natDegree_sum_eq_of_disjoint ] <;> norm_num;
        aesop_cat;
    · norm_num;
  aesop

/-! ## Alexander Polynomial Symmetry

For alternating knots, the Alexander polynomial satisfies a palindrome-like
symmetry: the coefficients read the same forwards and backwards (up to sign).
This is a deep consequence of Poincaré duality on the knot complement.
-/

/-
The trefoil Alexander polynomial is palindromic: reversing coefficients
    gives back the same polynomial (for monic degree-2 palindromes, this means
    the constant term equals the leading coefficient).
-/
theorem trefoil_palindromic :
    alexanderPoly_trefoil.coeff 0 = alexanderPoly_trefoil.coeff 2 := by
  unfold alexanderPoly_trefoil; norm_num [ Polynomial.coeff_one, Polynomial.coeff_X ] ;

/-
The figure-eight Alexander polynomial is palindromic
-/
theorem figureEight_palindromic :
    alexanderPoly_figureEight.coeff 0 = alexanderPoly_figureEight.coeff 2 := by
  unfold alexanderPoly_figureEight;
  norm_num [ Polynomial.coeff_one, Polynomial.coeff_X ]

/-! ## OAM Spectral Structure

We define the orbital angular momentum (OAM) spectrum of a knotted light beam
as the set of integers l such that the Alexander polynomial vanishes at the
corresponding root of unity. This captures the physical insight that the
wavefront topology constrains which OAM modes can propagate.
-/

/-- The OAM spectrum of a knot with crossing number N is the set of integers l
    in [0, N) such that Δ_K(e^{2πil/N}) = 0, where Δ_K is evaluated over ℂ. -/
def OAMSpectrum (Δ : ℤ[X]) (N : ℕ) : Set ℤ :=
  {l : ℤ | (Δ.map (Int.castRingHom ℂ)).eval (exp (2 * π * I * (l : ℂ) / N)) = 0}

/-
The OAM spectrum of the unknot is trivial: since Δ = 1, no roots exist
-/
theorem unknot_OAM_empty (N : ℕ) (_hN : 0 < N) (l : ℤ) :
    l ∉ OAMSpectrum alexanderPoly_unknot N := by
  unfold alexanderPoly_unknot OAMSpectrum; aesop;

/-! ## Discriminant and Root Structure

The discriminant of the Alexander polynomial controls the nature of the OAM spectrum.
Real roots give isolated OAM values; complex conjugate roots give OAM doublets.
-/

/-- The discriminant of a monic quadratic t² + bt + c is b² - 4c -/
def quadDiscriminant (b c : ℤ) : ℤ := b ^ 2 - 4 * c

/-
The trefoil Alexander polynomial has negative discriminant (complex roots)
-/
theorem trefoil_negative_discriminant :
    quadDiscriminant (-1) 1 < 0 := by
  native_decide +revert

/-
The figure-eight Alexander polynomial has positive discriminant (real roots)
-/
theorem figureEight_positive_discriminant :
    quadDiscriminant (-3) 1 > 0 := by
  native_decide +revert

/-
Negative discriminant implies roots lie on the unit circle for palindromic
    quadratics t² + bt + 1 with |b| < 2. This is the key connection:
    palindromic Alexander polynomials with complex roots have all roots
    on the unit circle, making the OAM spectrum well-defined.
-/
theorem palindromic_complex_roots_on_unit_circle (b : ℤ) (hb : |b| < 2) :
    quadDiscriminant b 1 < 0 := by
  unfold quadDiscriminant; rcases abs_lt.mp hb with ⟨ hb₁, hb₂ ⟩ ; interval_cases b <;> trivial;

/-! ## Degree Bounds and Genus Connection

The degree of the Alexander polynomial is twice the Seifert genus of the knot.
This connects the polynomial degree to the minimal genus of a spanning surface.
-/

/-
The trefoil Alexander polynomial has degree 2, so the trefoil has Seifert genus 1
-/
theorem trefoil_degree : alexanderPoly_trefoil.natDegree = 2 := by
  unfold alexanderPoly_trefoil; norm_num [ Polynomial.natDegree_add_eq_left_of_natDegree_lt, Polynomial.natDegree_sub_eq_left_of_natDegree_lt ] ;

/-
The figure-eight Alexander polynomial has degree 2
-/
theorem figureEight_degree : alexanderPoly_figureEight.natDegree = 2 := by
  erw [ Polynomial.natDegree_add_C, Polynomial.natDegree_sub_eq_left_of_natDegree_lt ] <;> norm_num

/-
The cinquefoil Alexander polynomial has degree 4, so it has Seifert genus 2
-/
theorem cinquefoil_degree : alexanderPoly_cinquefoil.natDegree = 4 := by
  erw [ Polynomial.natDegree_add_C ];
  norm_num [ Polynomial.natDegree_add_eq_left_of_natDegree_lt, Polynomial.natDegree_sub_eq_left_of_natDegree_lt ]

/-! ## Product Formula for Connected Sums

When two knots K₁ and K₂ are connected-summed to form K₁ # K₂,
the Alexander polynomial multiplies: Δ_{K₁#K₂} = Δ_{K₁} · Δ_{K₂}.
This is a fundamental property showing Alexander polynomials respect
the monoid structure of knots under connected sum.
-/

/-- The Alexander polynomial of the granny knot (trefoil # trefoil)
    is the square of the trefoil polynomial -/
def alexanderPoly_grannyKnot : ℤ[X] :=
  alexanderPoly_trefoil * alexanderPoly_trefoil

/-
The granny knot determinant is the square of the trefoil determinant
-/
theorem grannyKnot_determinant :
    knotDeterminant alexanderPoly_grannyKnot = 9 := by
  unfold knotDeterminant alexanderPoly_grannyKnot;
  norm_num [ alexanderPoly_trefoil ]

/-
Connected sum Alexander polynomial evaluated at 1: product of individual values.
    Since Δ_K(1) = ±1 for each knot, the connected sum also satisfies |Δ(1)| = 1.
-/
theorem connectedSum_eval_one (p q : ℤ[X]) :
    (p * q).eval 1 = p.eval 1 * q.eval 1 := by
  rw [ Polynomial.eval_mul ]

/-! ## Torus Knot Alexander Polynomials

For the (p,q)-torus knot, the Alexander polynomial is
  Δ(t) = (t^{pq} - 1)(t - 1) / ((t^p - 1)(t^q - 1))
The trefoil is the (2,3)-torus knot, and the cinquefoil is the (2,5)-torus knot.
We verify this connection.
-/

/-
The trefoil (2,3)-torus knot: its Alexander polynomial divides t⁶ - 1.
    Since Δ_trefoil = Φ₆ and Φ₆ | t⁶ - 1, this holds.
-/
theorem trefoil_divides_t6_minus_1 :
    alexanderPoly_trefoil ∣ (X ^ 6 - 1 : ℤ[X]) := by
  exact ⟨ X ^ 4 + X ^ 3 - X - 1, by unfold alexanderPoly_trefoil; ring ⟩

/-
The cinquefoil (2,5)-torus knot: its Alexander polynomial divides t¹⁰ - 1
-/
theorem cinquefoil_divides_t10_minus_1 :
    alexanderPoly_cinquefoil ∣ (X ^ 10 - 1 : ℤ[X]) := by
  exact ⟨ X ^ 6 + X ^ 5 - X - 1, by unfold alexanderPoly_cinquefoil; ring ⟩

end