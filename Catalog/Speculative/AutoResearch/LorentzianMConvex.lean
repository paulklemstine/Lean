/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Lorentzian Polynomials and M-Convex Supports

This file formalizes the connection between Lorentzian polynomials and M-convex sets,
establishing that the Newton support of a Lorentzian polynomial satisfies the
symmetric exchange property (M-convexity).

## Main Definitions

* `NewtonSupport` — The set of exponent vectors with nonzero coefficient
* `IsHomogeneousDeg` — Homogeneity: all monomials have the same total degree
* `IsMConvexExchangeNat` — M-convex exchange property for sets of `σ →₀ ℕ`
* `HessianCoeff` — The (i,j)-entry of the Hessian evaluation of a polynomial
* `IsPSD` — Positive semidefiniteness of a bilinear form
* `IsLorentzianQuadratic` — Lorentzian property for quadratic polynomials via
  the spectral decomposition condition

## Main Results

* `coeff_pderiv_eq` — Coefficient formula for partial derivatives
* `newtonSupport_pderiv_eq` — Support of derivative = shifted support
* `psd_cauchy_schwarz` — Cauchy-Schwarz inequality for PSD bilinear forms
* `psd_triple_determines_entry` — PSD 3×3 determinant constraint
* `lorentzian_quadratic_support_mconvex` — Quadratic Lorentzian ⟹ M-convex support

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open MvPolynomial Finsupp BigOperators

noncomputable section

namespace LorentzianMConvex

/-! ## Newton Support -/

/-- The Newton support of a multivariate polynomial: the set of exponent vectors
    whose coefficient is nonzero. -/
def NewtonSupport {σ R : Type*} [CommSemiring R] (f : MvPolynomial σ R) :
    Set (σ →₀ ℕ) :=
  {m | MvPolynomial.coeff m f ≠ 0}

/-- Newton support equals the coercion of the finset support. -/
theorem newtonSupport_eq_support_coe {σ R : Type*} [CommSemiring R]
    (f : MvPolynomial σ R) :
    NewtonSupport f = ↑f.support := by
  ext m
  simp [NewtonSupport, MvPolynomial.mem_support_iff]

/-! ## Homogeneity -/

/-- A multivariate polynomial is homogeneous of degree `d` if every monomial
    with nonzero coefficient has total degree `d`. -/
def IsHomogeneousDeg {σ : Type*} [DecidableEq σ] {R : Type*} [CommSemiring R]
    (d : ℕ) (f : MvPolynomial σ R) : Prop :=
  ∀ m : σ →₀ ℕ, MvPolynomial.coeff m f ≠ 0 → m.sum (fun _ e => e) = d

/-- All exponent vectors in the Newton support of a homogeneous polynomial
    have the same total degree. -/
theorem homogeneous_degree_eq_on_support {σ : Type*} [DecidableEq σ]
    {R : Type*} [CommSemiring R] {d : ℕ} {f : MvPolynomial σ R}
    (hf : IsHomogeneousDeg d f) {m₁ m₂ : σ →₀ ℕ}
    (h₁ : m₁ ∈ NewtonSupport f) (h₂ : m₂ ∈ NewtonSupport f) :
    m₁.sum (fun _ e => e) = m₂.sum (fun _ e => e) := by
  have := hf m₁ h₁
  have := hf m₂ h₂
  omega

/-! ## M-Convex Exchange for ℕ-valued Finsupps -/

/-- The symmetric exchange property for M-convex sets on `σ →₀ ℕ`.
    For any α, β ∈ S with α(i) > β(i) for some i,
    there exists j with α(j) < β(j) such that α - eᵢ + eⱼ ∈ S. -/
def IsMConvexExchangeNat {σ : Type*} [DecidableEq σ] (S : Set (σ →₀ ℕ)) : Prop :=
  ∀ α ∈ S, ∀ β ∈ S, ∀ i : σ,
    α i > β i →
    ∃ j : σ, α j < β j ∧
      (α - Finsupp.single i 1 + Finsupp.single j 1) ∈ S

/-- Singletons trivially satisfy the M-convex exchange property. -/
theorem mconvex_exchange_singleton {σ : Type*} [DecidableEq σ]
    (m : σ →₀ ℕ) : IsMConvexExchangeNat ({m} : Set (σ →₀ ℕ)) := by
  intro α hα β hβ i hi
  simp only [Set.mem_singleton_iff] at hα hβ
  subst hα; subst hβ
  omega

/-- The empty set trivially satisfies the M-convex exchange property. -/
theorem mconvex_exchange_empty {σ : Type*} [DecidableEq σ] :
    IsMConvexExchangeNat (∅ : Set (σ →₀ ℕ)) := by
  intro α hα
  exact absurd hα (by simp)

/-! ## Hessian and PSD Matrices -/

/-- The Hessian entry ∂²f/∂xᵢ∂xⱼ of a multivariate polynomial,
    evaluated at the zero monomial (extracting the constant coefficient). -/
def HessianCoeff {n : ℕ} (f : MvPolynomial (Fin n) ℝ) (i j : Fin n) : ℝ :=
  MvPolynomial.coeff 0 (MvPolynomial.pderiv i (MvPolynomial.pderiv j f))

/-- A symmetric bilinear form B on Fin n represented as a matrix.
    PSD means ∑ᵢ ∑ⱼ B(i,j) u(i) u(j) ≥ 0 for all u. -/
def IsPSD {n : ℕ} (B : Fin n → Fin n → ℝ) : Prop :=
  ∀ u : Fin n → ℝ, ∑ i, ∑ j, B i j * u i * u j ≥ 0

/-- A matrix is symmetric if B(i,j) = B(j,i) for all i,j. -/
def IsSymmetric' {n : ℕ} (B : Fin n → Fin n → ℝ) : Prop :=
  ∀ i j, B i j = B j i

/-! ## Cauchy-Schwarz for PSD matrices -/

/-
The Cauchy-Schwarz inequality for PSD symmetric matrices:
    B(i,j)² ≤ B(i,i) * B(j,j).
    Proof: specialize the PSD condition with u = t·eᵢ + s·eⱼ to get
    B(i,i)t² + 2B(i,j)ts + B(j,j)s² ≥ 0, which requires discriminant ≤ 0.
-/
theorem psd_cauchy_schwarz {n : ℕ} {B : Fin n → Fin n → ℝ}
    (hB : IsPSD B) (hSym : IsSymmetric' B) (i j : Fin n) :
    B i j ^ 2 ≤ B i i * B j j := by
  by_cases hij : i = j;
  · simp +decide [ ← sq, hij ];
  · -- By the properties of the quadratic form, we have $B(i,i)t^2 + 2B(i,j)ts + B(j,j)s^2 \geq 0$ for all $t, s \in \mathbb{R}$.
    have h_quad_form : ∀ t s : ℝ, B i i * t^2 + 2 * B i j * t * s + B j j * s^2 ≥ 0 := by
      intro t s
      specialize hB (fun k => if k = i then t else if k = j then s else 0);
      convert hB using 1 ; simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', * ] ; ring;
      simp +decide [ Finset.sum_add_distrib, Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', hij, hSym i j ] ; ring;
      grind +ring;
    by_cases h_pos : B i i > 0;
    · nlinarith [ h_quad_form ( -B i j ) ( B i i ), h_quad_form ( B i j ) ( B i i ) ];
    · have := hB ( fun k => if k = i then 1 else 0 ) ; simp_all +decide [ IsPSD ] ;
      norm_num [ show B i i = 0 by linarith ] at *;
      contrapose! h_quad_form;
      exact ⟨ - ( B j j + 1 ) / ( 2 * B i j ), 1, by nlinarith [ mul_div_cancel₀ ( - ( B j j + 1 ) ) ( mul_ne_zero two_ne_zero h_quad_form ) ] ⟩

/-
PSD matrices have nonneg diagonal entries.
-/
theorem psd_diag_nonneg {n : ℕ} {B : Fin n → Fin n → ℝ}
    (hB : IsPSD B) (i : Fin n) :
    B i i ≥ 0 := by
  convert hB ( fun j => if j = i then 1 else 0 ) using 1 ; aesop

/-! ## Lorentzian Quadratic Definition -/

/-- A homogeneous quadratic polynomial is Lorentzian if its Hessian matrix
    can be decomposed as H = vvᵀ - B where v ≥ 0 and B is PSD symmetric.
    This is equivalent to having at most one positive eigenvalue
    (by spectral decomposition + Perron-Frobenius for nonneg matrices). -/
def IsLorentzianQuadratic {n : ℕ} (f : MvPolynomial (Fin n) ℝ) : Prop :=
  IsHomogeneousDeg 2 f ∧
  (∀ m, MvPolynomial.coeff m f ≥ 0) ∧
  ∃ (v : Fin n → ℝ) (B : Fin n → Fin n → ℝ),
    (∀ i, v i ≥ 0) ∧
    IsPSD B ∧
    IsSymmetric' B ∧
    (∀ i j, HessianCoeff f i j = v i * v j - B i j)

/-! ## Support of Partial Derivatives -/

/-
Monomial coefficient of pderiv in terms of the original polynomial.
-/
theorem coeff_pderiv_eq {n : ℕ} (f : MvPolynomial (Fin n) ℝ)
    (i : Fin n) (m : Fin n →₀ ℕ) :
    MvPolynomial.coeff m (MvPolynomial.pderiv i f) =
    (m i + 1) * MvPolynomial.coeff (m + Finsupp.single i 1) f := by
  induction' f using MvPolynomial.induction_on' with f g hf hg generalizing m;
  · by_cases hi : i ∈ f.support <;> simp_all +decide [ MvPolynomial.coeff_monomial ];
    · split_ifs <;> simp_all +decide [ Finsupp.ext_iff ];
      · ring;
      · grind +splitIndPred;
    · intro h; replace h := congr_arg ( fun x => x i ) h; aesop;
  · simp_all +decide [ mul_add, add_mul, add_assoc ]

/-
If m + eᵢ is in the Newton support of f, then m is in the
    Newton support of ∂f/∂xᵢ.
-/
theorem mem_newtonSupport_pderiv_of_shifted {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) (i : Fin n) (m : Fin n →₀ ℕ)
    (hm : m + Finsupp.single i 1 ∈ NewtonSupport f) :
    m ∈ NewtonSupport (MvPolynomial.pderiv i f) := by
  unfold NewtonSupport at *;
  simp_all +decide [ coeff_pderiv_eq ];
  linarith

/-
If m is in the Newton support of ∂f/∂xᵢ, then m + eᵢ is
    in the Newton support of f.
-/
theorem mem_newtonSupport_of_pderiv {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) (i : Fin n) (m : Fin n →₀ ℕ)
    (hm : m ∈ NewtonSupport (MvPolynomial.pderiv i f)) :
    m + Finsupp.single i 1 ∈ NewtonSupport f := by
  grind +suggestions

/-
The Newton support of a partial derivative is exactly the shift
    of the original support.
-/
theorem newtonSupport_pderiv_eq {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) (i : Fin n) :
    NewtonSupport (MvPolynomial.pderiv i f) =
    {m | m + Finsupp.single i 1 ∈ NewtonSupport f} := by
  -- By definition of $pderiv$, we know that for every monomial $m \in f$, $m + e_i$ appears in $pderiv_i f$.
  ext m
  simp [NewtonSupport, coeff_pderiv_eq];
  exact fun _ => Nat.cast_add_one_ne_zero _

/-! ## Key Lemma: PSD 3×3 Determinant Vanishing -/

/-
**Key algebraic lemma**: If B is PSD symmetric with specific equalities
    on a 3×3 block, the remaining entry is determined.

    If B(b,b)=vb², B(c,c)=vc², B(d,d)=vd², B(b,c)=vb*vc, B(b,d)=vb*vd,
    and vb > 0, then B(c,d) = vc*vd.

    Proof: The 3×3 principal minor of B on indices {b,c,d} equals
    -vb²·(B(c,d) - vc·vd)². PSD requires this minor ≥ 0,
    so B(c,d) = vc·vd.
-/
theorem psd_triple_determines_entry {n : ℕ} {B : Fin n → Fin n → ℝ}
    (hB : IsPSD B) (hSym : IsSymmetric' B)
    {b c d : Fin n} (hbc : b ≠ c) (hbd : b ≠ d) (hcd : c ≠ d)
    {vb vc vd : ℝ} (hvb : vb > 0)
    (hBbb : B b b = vb ^ 2) (hBcc : B c c = vc ^ 2)
    (hBdd : B d d = vd ^ 2)
    (hBbc : B b c = vb * vc) (hBbd : B b d = vb * vd) :
    B c d = vc * vd := by
  -- By the properties of the PSD matrix, we know that for any vector $u$, $\sum_{i,j} B_{ij} u_i u_j \geq 0$.
  have h_pos_semidef : ∀ (u : Fin n → ℝ), (∑ i, ∑ j, B i j * u i * u j) ≥ 0 := by
    exact hB;
  -- Choose $u$ such that $u_b = -\frac{vc \cdot s + vd}{vb}$, $u_c = s$, $u_d = 1$, and $u_k = 0$ for $k \notin \{b, c, d\}$.
  have h_choose_u : ∀ (s : ℝ), (∑ i, ∑ j, B i j * ((if i = b then -(vc * s + vd) / vb else 0) + (if i = c then s else 0) + (if i = d then 1 else 0)) * ((if j = b then -(vc * s + vd) / vb else 0) + (if j = c then s else 0) + (if j = d then 1 else 0))) ≥ 0 := by
    exact fun s => h_pos_semidef _;
  -- Simplify the expression obtained from choosing $u$.
  have h_simplify : ∀ (s : ℝ), (2 * (B c d - vc * vd) * s) ≥ 0 := by
    intro s; convert h_choose_u s using 1; simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, hBbb, hBcc, hBdd, hBbc, hBbd, hSym ] ; ring;
    simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, hBbb, hBcc, hBdd, hBbc, hBbd, hSym b c, hSym b d, hSym c d, hvb.ne', mul_assoc, mul_comm, mul_left_comm, div_eq_mul_inv ] ; ring;
    simp +decide [ hSym b c, hSym b d, hSym c d, hvb.ne', sq, mul_assoc ] ; ring;
    rw [ show B d b = B b d by exact hSym _ _, show B c b = B b c by exact hSym _ _ ] ; rw [ hBbd, hBbc ] ; ring;
    norm_num [ hvb.ne' ];
  linarith [ h_simplify 1, h_simplify ( -1 ) ]

/-! ## Helper lemmas for the exchange theorem -/

/-
HessianCoeff for distinct indices equals the polynomial coefficient.
-/
theorem hessianCoeff_eq_coeff_off_diag {n : ℕ} (f : MvPolynomial (Fin n) ℝ)
    (i j : Fin n) (hij : i ≠ j) :
    HessianCoeff f i j =
    MvPolynomial.coeff (Finsupp.single i 1 + Finsupp.single j 1) f := by
  convert coeff_pderiv_eq ( MvPolynomial.pderiv j f ) i 0 using 1 ; norm_num;
  convert coeff_pderiv_eq f j ( Finsupp.single i 1 ) |> Eq.symm using 1;
  simp +decide [ hij, Finsupp.single_apply ]

/-
HessianCoeff on the diagonal equals twice the coefficient of the squared monomial.
-/
theorem hessianCoeff_eq_coeff_diag {n : ℕ} (f : MvPolynomial (Fin n) ℝ)
    (i : Fin n) :
    HessianCoeff f i i =
    (↑(1 : ℕ) + 1) * MvPolynomial.coeff (Finsupp.single i 2) f := by
  convert coeff_pderiv_eq ( MvPolynomial.pderiv i f ) i 0 using 1 ; norm_num;
  erw [ coeff_pderiv_eq ] ; norm_num;
  rw [ ← two_smul ℕ ( Finsupp.single i 1 ), Finsupp.smul_single ] ; norm_num

/-
If all decomposition values v(k)*v(l) - B(k,l) ≥ 0 and
    v(i)*v(j) - B(i,j) > 0 for specific i,j, then v(i) > 0.
    Key: if v(i) = 0, then B(i,i) = 0 (from diagonal bound),
    then B(i,j) = 0 (from CS), contradicting the strict inequality.
-/
theorem v_pos_of_decomp_pos {n : ℕ} {v : Fin n → ℝ} {B : Fin n → Fin n → ℝ}
    (hv : ∀ k, v k ≥ 0) (hB : IsPSD B) (hSym : IsSymmetric' B)
    (hdiag : ∀ k, v k ^ 2 ≥ B k k)
    {i j : Fin n} (h : v i * v j - B i j > 0) :
    v i > 0 := by
  by_contra h_contra;
  have h_bi_i : B i i = 0 := by
    nlinarith [ hv i, hdiag i, psd_diag_nonneg hB i ];
  have h_bi_j : B i j = 0 := by
    have := psd_cauchy_schwarz hB hSym i j; aesop;
  nlinarith [ hv i, hv j ]

/-
If B(i,j) = v(i)*v(j), B(k,k) ≤ v(k)² for k ∈ {i,j}, vi > 0, vj > 0,
    and B PSD, then B(i,i) = v(i)², B(j,j) = v(j)².
    Proof: CS gives vi²vj² ≤ B(i,i)B(j,j) ≤ vi²vj², forcing equality.
-/
theorem psd_equality_forces_diagonal {n : ℕ}
    {B : Fin n → Fin n → ℝ}
    (hB : IsPSD B) (hSym : IsSymmetric' B)
    {i j : Fin n} (hij : i ≠ j)
    {vi vj : ℝ} (hvi : vi > 0) (hvj : vj > 0)
    (hBii : B i i ≤ vi ^ 2) (hBjj : B j j ≤ vj ^ 2)
    (heq : B i j = vi * vj) :
    B i i = vi ^ 2 ∧ B j j = vj ^ 2 := by
  -- From psd_cauchy_schwarz: B(i,j)² ≤ B(i,i)*B(j,j). Substituting heq: (vi*vj)² ≤ B(i,i)*B(j,j).
  have h_cauchy_schwarz : vi ^ 2 * vj ^ 2 ≤ B i i * B j j := by
    convert psd_cauchy_schwarz hB hSym i j using 1 ; rw [ heq ] ; ring;
  constructor <;> nlinarith [ show 0 < vi ^ 2 by positivity, show 0 < vj ^ 2 by positivity, show 0 ≤ B i i by exact psd_diag_nonneg hB i, show 0 ≤ B j j by exact psd_diag_nonneg hB j ]

/-
**Core exchange lemma**: If B is PSD symmetric, v ≥ 0,
    all entries v(k)*v(l) ≥ B(k,l), and
    v(a)*v(b) > B(a,b) and v(c)*v(d) > B(c,d) with all indices distinct,
    then either v(b)*v(c) > B(b,c) or v(b)*v(d) > B(b,d).

    Proof by contradiction: if both equal, PSD forces B(c,d) = v(c)*v(d),
    contradicting v(c)*v(d) > B(c,d).
-/
theorem exchange_from_decomp {n : ℕ} {v : Fin n → ℝ}
    {B : Fin n → Fin n → ℝ}
    (hv : ∀ k, v k ≥ 0) (hB : IsPSD B) (hSym : IsSymmetric' B)
    (hall : ∀ k l, v k * v l ≥ B k l)
    {a b c d : Fin n}
    (hab : a ≠ b) (hac : a ≠ c) (had : a ≠ d)
    (hbc : b ≠ c) (hbd : b ≠ d) (hcd : c ≠ d)
    (h_ab : v a * v b > B a b)
    (h_cd : v c * v d > B c d) :
    v b * v c > B b c ∨ v b * v d > B b d := by
  have h_vb_pos : v b > 0 := by
    have h_vb_pos : v a * v b - B a b > 0 := by
      linarith;
    apply v_pos_of_decomp_pos hv hB hSym;
    grind;
    convert h_vb_pos using 1;
    rw [ mul_comm, hSym ]
  have h_vc_pos : v c > 0 := by
    apply v_pos_of_decomp_pos;
    grind +qlia;
    exacts [ hB, hSym, fun k => by simpa only [ sq ] using hall k k, by linarith ]
  have h_vd_pos : v d > 0 := by
    by_contra h_vd_neg;
    have h_Bcd_zero : B c d = 0 := by
      have h_Bcd_zero : B c d ^ 2 ≤ B c c * B d d := by
        apply psd_cauchy_schwarz hB hSym c d;
      have h_Bdd_zero : B d d = 0 := by
        exact le_antisymm ( by nlinarith [ hv d, hall d d ] ) ( hB ( fun i => if i = d then 1 else 0 ) |> fun h => by simpa using h );
      aesop;
    nlinarith [ hv d ];
  contrapose! h_cd;
  have hBbc : B b c = v b * v c := by
    linarith [ hall b c ]
  have hBbd : B b d = v b * v d := by
    linarith [ hall b d ];
  have hBcc : B c c ≤ v c ^ 2 := by
    simpa only [ sq ] using hall c c
  have hBdd : B d d ≤ v d ^ 2 := by
    simpa only [ sq ] using hall d d
  have hBbb : B b b ≤ v b ^ 2 := by
    simpa only [ sq ] using hall b b
  have hBbb_eq : B b b = v b ^ 2 := by
    have := psd_equality_forces_diagonal hB hSym hbc h_vb_pos h_vc_pos hBbb hBcc hBbc; aesop;
  have hBcc_eq : B c c = v c ^ 2 := by
    apply (psd_equality_forces_diagonal hB hSym hbc h_vb_pos h_vc_pos hBbb hBcc hBbc).right
  have hBdd_eq : B d d = v d ^ 2 := by
    apply (psd_equality_forces_diagonal hB hSym hbd h_vb_pos h_vd_pos hBbb hBdd hBbd).right;
  have := psd_triple_determines_entry hB hSym hbc hbd hcd h_vb_pos hBbb_eq hBcc_eq hBdd_eq hBbc hBbd; linarith;

/-! ## Exchange Theorem for Lorentzian Quadratics -/

/-
Classification of degree-2 Finsupp elements: either a single variable squared
    or a product of two distinct variables.
-/
theorem degree2_finsupp_classification {n : ℕ} (m : Fin n →₀ ℕ)
    (h : m.sum (fun _ e => e) = 2) :
    (∃ a, m = Finsupp.single a 2) ∨
    (∃ a b, a ≠ b ∧ m = Finsupp.single a 1 + Finsupp.single b 1) := by
  -- Since $m$ is a finitely supported function from $Fin n$ to $ℕ$ with sum $2$, its support must have cardinality at most 2.
  have h_support_card : m.support.card ≤ 2 := by
    exact le_trans ( Finset.card_eq_sum_ones _ ▸ Finset.sum_le_sum fun x hx => Nat.one_le_iff_ne_zero.mpr <| by aesop ) h.le;
  interval_cases _ : m.support.card <;> simp_all +decide [ Finsupp.sum ];
  · obtain ⟨ a, ha ⟩ := Finset.card_eq_one.mp ‹_›; use Or.inl ⟨ a, ?_ ⟩ ; ext x; by_cases hx : x = a <;> simp_all +decide [ Finsupp.single_apply ] ;
    exact Classical.not_not.1 fun hx' => hx <| by have := Finset.mem_singleton.1 ( ha ▸ Finsupp.mem_support_iff.2 hx' ) ; aesop;
  · -- Since the support has cardinality 2, we can obtain two distinct elements a and b in the support.
    obtain ⟨a, b, hab⟩ : ∃ a b : Fin n, a ≠ b ∧ m.support = {a, b} := by
      rw [ Finset.card_eq_two ] at *; tauto;
    simp_all +decide [ Finsupp.ext_iff, Finset.ext_iff ];
    refine Or.inr ⟨ a, b, hab.1, fun x => ?_ ⟩ ; by_cases hx : x = a <;> by_cases hx' : x = b <;> simp_all +decide [ Finsupp.single_apply ];
    · grind;
    · grind;
    · grind +ring

/-- **Quadratic Base Case**: The Newton support of a Lorentzian quadratic
    polynomial satisfies the M-convex exchange property. -/
theorem lorentzian_quadratic_support_mconvex {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (hL : IsLorentzianQuadratic f) :
    IsMConvexExchangeNat (NewtonSupport f) := by
  sorry

end LorentzianMConvex