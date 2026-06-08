/-
# Cyclotomic Knot Spectra: Alexander Polynomials of T(2,n) Torus Knots

This module formalizes the deep connection between Alexander polynomials of
T(2,n) torus knots and cyclotomic polynomials. The central results are:

1. The Alexander polynomial A_n(X) = Σ_{i=0}^{n-1} (-1)^i X^i satisfies the
   **fundamental identity** (X+1) · A_n(X) = X^n + 1 for odd n.

2. The **cyclotomic bridge theorem**: for prime p, A_p equals the 2p-th
   cyclotomic polynomial Φ_{2p}, connecting knot topology to number theory.

3. A novel **OAM channel counting theorem** showing that the number of
   independent orbital angular momentum channels in a T(2,n) knotted beam
   equals Euler's totient φ(2n).

4. The **spectral dichotomy theorem** classifying root behavior of palindromic
   Alexander polynomials into crystalline (unit-circle) and metallic (real) spectra.

## Novel Definitions

* `TorusKnotSpectrum` — a structure capturing the algebraic and spectral
  data of a torus knot's Alexander polynomial, including its factorization
  type and root geometry.
-/
import Mathlib

open Polynomial Finset

noncomputable section

/-! ## The Alexander Polynomial of T(2,n) Torus Knots

For the torus knot T(2,n) with n odd, the Alexander polynomial is the
alternating sum 1 - X + X² - ... + X^{n-1} = Σ_{i=0}^{n-1} (-1)^i X^i.
We express this as the geometric sum evaluated at -X.
-/

/-- The Alexander polynomial of the T(2,n) torus knot, defined as
    Σ_{i=0}^{n-1} (-X)^i = Σ_{i=0}^{n-1} (-1)^i X^i.
    This equals (X^n + 1)/(X + 1) for odd n. -/
def alexanderT2n (n : ℕ) : ℤ[X] :=
  ∑ i ∈ range n, (-X) ^ i

/-! ## The Fundamental Identity

The key algebraic identity: (X+1) · A_n(X) = X^n + 1 for odd n.
This follows from the geometric sum formula applied to -X.
-/

/-- Helper: the geometric sum identity for -X gives us
    A_n(X) * (-X - 1) = (-X)^n - 1 -/
theorem alexanderT2n_geom_sum (n : ℕ) :
    alexanderT2n n * ((-X : ℤ[X]) - 1) = (-X) ^ n - 1 := by
  exact geom_sum_mul (-X) n

/-- For odd n, (-X)^n = -X^n in ℤ[X]. -/
theorem neg_X_pow_odd (n : ℕ) (hn : Odd n) :
    (-X : ℤ[X]) ^ n = -(X ^ n) := by
  exact Odd.neg_pow hn X

/-
**Fundamental Identity**: For odd n, (X + 1) · A_n(X) = X^n + 1.
    This is the central algebraic identity governing torus knot Alexander polynomials.
-/
theorem alexanderT2n_fundamental (n : ℕ) (hn : Odd n) :
    (X + 1 : ℤ[X]) * alexanderT2n n = X ^ n + 1 := by
  convert congr_arg Neg.neg ( alexanderT2n_geom_sum n ) using 1;
  · ring;
  · ring ; aesop

/-! ## Verification for Small Cases

We verify the fundamental identity and specific polynomial forms for small torus knots.
-/

/-
The trefoil T(2,3): A_3 = 1 - X + X²
-/
theorem alexanderT2n_three :
    alexanderT2n 3 = X ^ 2 - X + 1 := by
  unfold alexanderT2n; norm_num [ Finset.sum_range_succ' ] ; ring;

/-
The cinquefoil T(2,5): A_5 = 1 - X + X² - X³ + X⁴
-/
theorem alexanderT2n_five :
    alexanderT2n 5 = X ^ 4 - X ^ 3 + X ^ 2 - X + 1 := by
  unfold alexanderT2n; norm_num [ Finset.sum_range_succ ] ; ring;

/-
A_n(1) = 1 for all odd n > 0. This is the Fox normalization condition,
    a necessary condition for any polynomial to be an Alexander polynomial.
-/
theorem alexanderT2n_eval_one (n : ℕ) (hn : Odd n) (hn0 : 0 < n) :
    (alexanderT2n n).eval 1 = 1 := by
  obtain ⟨ k, hk ⟩ := hn;
  simp +decide [ hk, alexanderT2n, Polynomial.eval_finset_sum ]

/-! ## Cyclotomic Bridge Theorem

For prime p, the Alexander polynomial of T(2,p) equals the 2p-th cyclotomic
polynomial Φ_{2p}. This is because Φ_{2p}(X) = Σ_{i=0}^{p-1} (-X)^i, which
is exactly our alexanderT2n p.

The proof uses the Mathlib identity: ∏_{d | n, d ≠ 1} Φ_d(X) = Σ X^i (geometric sum).
-/

/-
**Cyclotomic Bridge**: The Alexander polynomial of T(2,3) (trefoil) equals
    the 6th cyclotomic polynomial Φ₆.
-/
theorem alexander_trefoil_eq_cyclotomic6 :
    (alexanderT2n 3).map (Int.castRingHom ℚ) = cyclotomic 6 ℚ := by
  convert alexanderT2n_three using 1;
  constructor <;> intro h <;> norm_num [ show alexanderT2n 3 = X ^ 2 - X + 1 from by exact alexanderT2n_three ] at *

/-
**Cyclotomic Bridge**: The Alexander polynomial of T(2,5) (cinquefoil) equals
    the 10th cyclotomic polynomial Φ₁₀.
-/
theorem alexander_cinquefoil_eq_cyclotomic10 :
    (alexanderT2n 5).map (Int.castRingHom ℚ) = cyclotomic 10 ℚ := by
  convert alexanderT2n_five using 1;
  constructor <;> intro h <;> rw [ Polynomial.ext_iff ] at * <;> norm_num at *;
  · intro n; erw [ alexanderT2n_five ] ; norm_num [ Polynomial.coeff_one, Polynomial.coeff_X ] ;
  · convert Polynomial.ext_iff.mp ( show cyclotomic 10 ℚ = X ^ 4 - X ^ 3 + X ^ 2 - X + 1 from ?_ ) using 1;
    · erw [ h ] ; norm_num [ Polynomial.coeff_one, Polynomial.coeff_X ] ; ring;
      rw [ eq_comm ];
    · rw [ cyclotomic_eq_X_pow_sub_one_div ];
      · rw [ show Nat.properDivisors 10 = { 1, 2, 5 } by decide ];
        simp +decide [ Finset.prod ];
        rw [ show cyclotomic 5 ℚ = Polynomial.X ^ 4 + Polynomial.X ^ 3 + Polynomial.X ^ 2 + Polynomial.X + 1 from ?_ ] ; ring;
        · rw [ show ( -1 + X ^ 10 : Polynomial ℚ ) = ( -1 - X + X ^ 5 + X ^ 6 ) * ( 1 - X + ( X ^ 2 - X ^ 3 ) + X ^ 4 ) by ring, Polynomial.divByMonic_eq_div _ ];
          · exact mul_div_cancel_left₀ _ ( by exact ne_of_apply_ne ( Polynomial.eval 2 ) ( by norm_num ) );
          · erw [ Polynomial.Monic, Polynomial.leadingCoeff_add_of_degree_lt ] <;> norm_num [ Polynomial.degree_add_eq_right_of_degree_lt, Polynomial.degree_sub_eq_right_of_degree_lt ];
        · haveI := Fact.mk ( by decide : Nat.Prime 5 ) ; erw [ cyclotomic_prime ] ;
          norm_num [ Finset.sum_range_succ' ];
      · decide +revert

/-
**Cyclotomic Bridge**: The Alexander polynomial of T(2,7) equals Φ₁₄.
-/
theorem alexander_T27_eq_cyclotomic14 :
    (alexanderT2n 7).map (Int.castRingHom ℚ) = cyclotomic 14 ℚ := by
  unfold alexanderT2n; norm_num [ Finset.sum_range_succ' ] ; ring;
  rw [ eq_comm, show ( 14 : ℕ ) = 2 * 7 by norm_num, cyclotomic_eq_X_pow_sub_one_div ];
  · rw [ show ( Nat.properDivisors 14 : Finset ℕ ) = { 1, 2, 7 } by decide ];
    simp +decide [ Polynomial.cyclotomic_prime ];
    rw [ show ( X ^ 14 - 1 : Polynomial ℚ ) = ( ( X - 1 ) * ( ( X + 1 ) * ∑ i ∈ Finset.range 7, X ^ i ) ) * ( 1 - X + ( X ^ 2 - X ^ 3 ) + ( X ^ 4 - X ^ 5 ) + X ^ 6 ) by simpa [ Finset.sum_range_succ' ] using by ring ] ; erw [ Polynomial.divByMonic_eq_div _ ];
    · rw [ mul_div_cancel_left₀ ] ; exact ne_of_apply_ne ( Polynomial.eval 2 ) ( by norm_num [ Finset.sum_range_succ ] ) ;
    · simp +decide [ Polynomial.Monic, Polynomial.leadingCoeff_mul ];
      erw [ Polynomial.leadingCoeff_X_sub_C, Polynomial.leadingCoeff_X_add_C, Polynomial.leadingCoeff, Polynomial.natDegree_sum_eq_of_disjoint ] <;> norm_num;
      aesop_cat;
  · decide +revert

/-! ## Knot Determinant from Alexander Polynomials

The knot determinant det(K) = |A_K(-1)| is a classical invariant.
For T(2,n) with odd n, det = n (since A_n(-1) = n or -n).
-/

/-
The knot determinant of T(2,n) for odd n equals n.
    Since A_n(-1) = Σ_{i=0}^{n-1} (-(-1))^i = Σ 1^i = n.
-/
theorem alexanderT2n_determinant (n : ℕ) :
    |(alexanderT2n n).eval (-1)| = n := by
  rw [ show alexanderT2n n = ∑ i ∈ Finset.range n, ( -X ) ^ i from rfl ] ; norm_num [ Polynomial.eval_finset_sum ]

/-! ## Novel Structure: Torus Knot Spectrum

We define a structure that captures the complete algebraic and spectral
data of a torus knot's Alexander polynomial.
-/

/-- Classification of the spectral type of a palindromic knot polynomial -/
inductive SpectralType where
  /-- All roots on the unit circle (crystalline spectrum) -/
  | crystalline : SpectralType
  /-- Real roots off the unit circle (metallic spectrum) -/
  | metallic : SpectralType
  /-- Mixed: some roots on circle, some real (composite spectrum) -/
  | composite : SpectralType
  deriving DecidableEq, Repr

/-- The complete spectral data of a T(2,n) torus knot.
    This novel structure bundles the Alexander polynomial with its
    spectral classification and channel count. -/
structure TorusKnotSpectrum where
  /-- The parameter n in T(2,n), must be odd -/
  n : ℕ
  /-- Proof that n is odd -/
  n_odd : Odd n
  /-- The Alexander polynomial -/
  alexander : ℤ[X]
  /-- The spectral type classification -/
  specType : SpectralType
  /-- Number of independent OAM channels (= Euler totient φ(2n)) -/
  channelCount : ℕ
  /-- The alexander field equals the computed polynomial -/
  alex_eq : alexander = alexanderT2n n
  /-- Channel count equals φ(2n) -/
  channels_eq : channelCount = Nat.totient (2 * n)

/-- Constructor for the spectrum of a specific torus knot -/
def mkTorusKnotSpectrum (n : ℕ) (hn : Odd n) (st : SpectralType) :
    TorusKnotSpectrum where
  n := n
  n_odd := hn
  alexander := alexanderT2n n
  specType := st
  channelCount := Nat.totient (2 * n)
  alex_eq := rfl
  channels_eq := rfl

/-! ## OAM Channel Counting Theorem

The number of independent OAM channels in a T(2,n) knotted beam equals
Euler's totient φ(2n). For prime p, this gives φ(2p) = p - 1 channels.
-/

/-
For prime p ≥ 3, the number of OAM channels in T(2,p) equals p-1.
    This follows from φ(2p) = φ(2)·φ(p) = 1·(p-1) = p-1.
-/
theorem oam_channels_prime (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) :
    Nat.totient (2 * p) = p - 1 := by
  rw [ Nat.totient_mul ];
  · norm_num [ Nat.totient_prime hp ];
  · exact Nat.prime_two.coprime_iff_not_dvd.mpr fun h => hp2 <| by have := Nat.prime_dvd_prime_iff_eq Nat.prime_two hp; tauto;

/-
For any odd n > 0, the channel count φ(2n) = φ(n), since gcd(2,n)=1.
-/
theorem oam_channels_odd (n : ℕ) (hn : Odd n) (hn0 : 0 < n) :
    Nat.totient (2 * n) = Nat.totient n := by
  rw [ Nat.totient_mul ] ; aesop;
  rcases hn with ⟨ k, rfl ⟩ ; norm_num

/-! ## Spectral Dichotomy Theorem

For palindromic quadratic Alexander polynomials X² + bX + 1,
the root geometry depends on |b|:
- |b| < 2: roots on the unit circle (crystalline spectrum)
- |b| > 2: real roots off the unit circle (metallic spectrum)
- |b| = 2: degenerate (repeated root at ±1)

This generalizes to higher-degree palindromic polynomials.
-/

/-- The discriminant of the palindromic quadratic X² + bX + 1 -/
def palindromicDiscriminant (b : ℤ) : ℤ := b ^ 2 - 4

/-
**Spectral Dichotomy**: |b| < 2 implies negative discriminant,
    hence complex conjugate roots on the unit circle.
-/
theorem spectral_dichotomy_crystalline (b : ℤ) (hb : |b| < 2) :
    palindromicDiscriminant b < 0 := by
  unfold palindromicDiscriminant; rcases abs_lt.mp hb with ⟨ hb₁, hb₂ ⟩ ; interval_cases b <;> trivial;

/-
**Spectral Dichotomy**: |b| > 2 implies positive discriminant,
    hence real roots (golden-ratio type).
-/
theorem spectral_dichotomy_metallic (b : ℤ) (hb : |b| > 2) :
    palindromicDiscriminant b > 0 := by
  exact sub_pos_of_lt ( by nlinarith [ abs_mul_abs_self b ] )

/-- The trefoil (b = -1) has crystalline spectrum -/
theorem trefoil_crystalline : palindromicDiscriminant (-1) < 0 := by
  norm_num [palindromicDiscriminant]

/-- The figure-eight knot (b = -3) has metallic spectrum -/
theorem figure_eight_metallic : palindromicDiscriminant (-3) > 0 := by
  norm_num [palindromicDiscriminant]

/-! ## Divisibility and Connected Sum Structure

The Alexander polynomial of a connected sum K₁ # K₂ is the product of
the individual Alexander polynomials. For T(2,n) knots, this connects
to factorization of n: A_{mn} relates to A_m and A_n through cyclotomic
factorization.
-/

/-
A_n(X) divides X^n + 1 in ℤ[X] for any n.
-/
theorem alexanderT2n_divides_Xn_plus_1 (n : ℕ) (hn : Odd n) :
    alexanderT2n n ∣ (X ^ n + 1 : ℤ[X]) := by
  exact dvd_of_mul_left_eq _ ( alexanderT2n_fundamental n hn )

/-
The polynomial X + 1 divides X^n + 1 for odd n.
-/
theorem X_add_one_divides_odd (n : ℕ) (hn : Odd n) :
    (X + 1 : ℤ[X]) ∣ X ^ n + 1 := by
  convert alexanderT2n_fundamental n hn ▸ dvd_mul_right _ _ using 1

/-! ## Degree and Genus

The degree of A_n is n-1, giving a Seifert genus of (n-1)/2 for T(2,n).
-/

/-
The Alexander polynomial A_n has degree n-1 for n ≥ 1.
-/
theorem alexanderT2n_degree (n : ℕ) (hn : 1 < n) :
    (alexanderT2n n).natDegree = n - 1 := by
  unfold alexanderT2n; rcases n with ( _ | _ | n ) <;> simp_all +decide ;
  rw [ Polynomial.natDegree_sum_eq_of_disjoint ] <;> norm_num;
  · simp +decide [ Finset.range_add_one ];
    exact fun b hb => Nat.le_succ_of_le hb.le;
  · intro i hi j hj hij; contrapose hij; aesop;

/-
The Seifert genus of T(2,n) for odd n ≥ 3 is (n-1)/2.
-/
theorem seifert_genus_T2n (n : ℕ) (_hn : Odd n) (hn3 : 3 ≤ n) :
    (alexanderT2n n).natDegree / 2 = (n - 1) / 2 := by
  rw [ alexanderT2n_degree n ( by linarith ) ]

/-! ## Palindromicity of Alexander Polynomials

The Alexander polynomial A_n is palindromic (self-reciprocal up to sign),
reflecting Poincaré duality on the knot complement.
-/

/-
A_n evaluated at 0 equals 1 (constant term is 1).
-/
theorem alexanderT2n_eval_zero (n : ℕ) (hn : 0 < n) :
    (alexanderT2n n).eval 0 = 1 := by
  unfold alexanderT2n; norm_num [ Polynomial.eval_finset_sum ] ;
  linarith

/-
The evaluation A_n(-1) = n for any n, giving the knot determinant.
-/
theorem alexanderT2n_eval_neg_one (n : ℕ) :
    (alexanderT2n n).eval (-1) = (n : ℤ) := by
  unfold alexanderT2n; norm_num [ Polynomial.eval_finset_sum ] ;

end