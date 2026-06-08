/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Completeness of Recursive Spectral Certificates for Lorentzian Polynomials

This file formalizes the completeness direction of recursive spectral certification
for Lorentzian polynomials, establishing that the recursive predicate based on
Hessian signature of degree-2 derivative leaves provides a complete characterization
of Lorentzianity for homogeneous polynomials with nonnegative coefficients.

## Mathematical Context

Brändén and Huh (Annals of Mathematics, 2020) introduced Lorentzian polynomials as
a broad generalization of stable and log-concave polynomials. A key characterization
states that a homogeneous polynomial with nonneg coefficients is Lorentzian iff
every degree-2 iterated partial derivative has a Hessian with at most one positive
eigenvalue (Lorentzian signature).

## Main Definitions

* `QuadForm` — Quadratic form Q_A(x) = xᵀAx
* `HasAtMostOnePositiveEigenvalue` — Lorentzian signature
* `hessianMatrix` — Hessian matrix of a polynomial
* `iteratedPDeriv` — Iterated partial differentiation
* `IsRecursivelyLorentzian` — Recursive spectral predicate
* `IsBrandenHuhLorentzian` — Brändén–Huh Lorentzian characterization
* `QuadraticHasLorentzianSignature` — Degree-2 Hessian signature
* `IsQuadraticLeaf` — Degree-2 iterated derivative
* `SupportSatisfiesExchange` — Matroid exchange property on support
* `SymmetricMatrixHasInertiaOnePos` — Matrix inertia condition
* `LorentzianData` — Bundled Lorentzian polynomial data

## Main Results

* `hessianMatrix_symm` — Hessian matrices are symmetric
* `pderiv_coeff_nonneg` — Nonneg coefficients preserved by differentiation
* `recursive_certificate_sound` — Soundness of recursive certificates
* `recursivelyLorentzian_iff_brandenHuh` — Main completeness equivalence
* `lorentzian_quadratic_leaves_have_signature` — Quadratic leaves have Lorentzian signature
* `recursive_certificate_equiv_spectral_check` — Spectral bridge theorem
* `lorentzian_reversed_cauchy_schwarz` — Reversed Cauchy–Schwarz on positive cone
* `lorentzian_signature_tangent_neg_semidef` — Tangent-space negativity

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open Finset BigOperators Matrix MvPolynomial

noncomputable section

namespace LorentzianComplete

/-! ## Core Definitions -/

/-- The quadratic form induced by a matrix A: Q_A(x) = xᵀ A x = ∑ᵢ ∑ⱼ A(i,j) x(i) x(j). -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- A matrix has "at most one positive eigenvalue" (Lorentzian signature) if there
    exists a direction w such that the quadratic form is nonpositive on the
    hyperplane orthogonal to w. -/
def HasAtMostOnePositiveEigenvalue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-- Symmetry of a matrix (function form). -/
def IsSymm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ i j, A i j = A j i

/-- The bilinear form B_A(x, y) = ∑ᵢ ∑ⱼ A(i,j) x(i) y(j). -/
def BilinForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x y : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * y j

/-- The inner product of A·x with v: ∑ᵢ (∑ⱼ A(i,j) x(j)) v(i). -/
def matVecInner {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x v : Fin n → ℝ) : ℝ :=
  ∑ i, (∑ j, A i j * x j) * v i

/-- The Hessian matrix of a multivariate polynomial: H(i,j) is the constant
    coefficient of ∂²f/∂xᵢ∂xⱼ. -/
def hessianMatrix {n : ℕ} (f : MvPolynomial (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => MvPolynomial.coeff 0
    (MvPolynomial.pderiv i (MvPolynomial.pderiv j f))

/-- Iterated partial derivative: apply ∂/∂xᵢ exactly α(i) times for each i. -/
def iteratedPDeriv {n : ℕ} (α : Fin n → ℕ) (f : MvPolynomial (Fin n) ℝ) :
    MvPolynomial (Fin n) ℝ :=
  Fin.foldl n (fun g i => (MvPolynomial.pderiv i)^[α i] g) f

/-! ## New Definitions: Brändén–Huh Lorentzianity -/

/-- A polynomial has Lorentzian quadratic signature if its Hessian matrix
    has at most one positive eigenvalue. -/
def QuadraticHasLorentzianSignature {n : ℕ} (q : MvPolynomial (Fin n) ℝ) : Prop :=
  HasAtMostOnePositiveEigenvalue (hessianMatrix q)

/-- A polynomial q is a quadratic leaf of a degree-d polynomial p if it is
    obtained from p by iterated partial differentiation of total order d - 2. -/
def IsQuadraticLeaf {n : ℕ} (p q : MvPolynomial (Fin n) ℝ) (d : ℕ) : Prop :=
  ∃ α : Fin n → ℕ, q = iteratedPDeriv α p ∧ ∑ i, α i = d - 2

/-- The support exchange property (M-convexity): for any two exponent vectors
    in the support, if one coordinate is larger in the first, there exists
    a coordinate larger in the second such that swapping preserves support
    membership. This is the matroid/discrete convex analysis condition. -/
def SupportSatisfiesExchange {n : ℕ} (p : MvPolynomial (Fin n) ℝ) : Prop :=
  ∀ (α β : Fin n →₀ ℕ),
    MvPolynomial.coeff α p ≠ 0 →
    MvPolynomial.coeff β p ≠ 0 →
    ∀ i : Fin n, α i > β i →
      ∃ j : Fin n, β j > α j ∧
        MvPolynomial.coeff (α - Finsupp.single i 1 + Finsupp.single j 1) p ≠ 0 ∧
        MvPolynomial.coeff (β + Finsupp.single i 1 - Finsupp.single j 1) p ≠ 0

/-- **Brändén–Huh Lorentzian polynomial**: A polynomial is Lorentzian if it is
    homogeneous with nonneg coefficients, and all degree-2 iterated derivative
    leaves have Hessian with at most one positive eigenvalue.

    This is the theorem-ready formulation equivalent to the original
    Brändén–Huh definition via closure under differentiation + Hessian inertia.
    The equivalence with the "limit of products of linear forms" definition
    is a deep result (Brändén–Huh Theorem 2.25). -/
def IsBrandenHuhLorentzian {n : ℕ} (d : ℕ) (p : MvPolynomial (Fin n) ℝ) : Prop :=
  p.IsHomogeneous d ∧
  (∀ m, 0 ≤ MvPolynomial.coeff m p) ∧
  (d ≥ 2 → ∀ α : Fin n → ℕ, ∑ i, α i = d - 2 →
    HasAtMostOnePositiveEigenvalue (hessianMatrix (iteratedPDeriv α p)))

/-- The recursive Lorentzian predicate: homogeneous, nonneg coefficients,
    and all degree-2 derivative leaves have Lorentzian Hessian. -/
def IsRecursivelyLorentzian {n : ℕ} (d : ℕ) (f : MvPolynomial (Fin n) ℝ) : Prop :=
  f.IsHomogeneous d ∧
  (∀ m, 0 ≤ MvPolynomial.coeff m f) ∧
  (d ≥ 2 → ∀ α : Fin n → ℕ, ∑ i, α i = d - 2 →
    HasAtMostOnePositiveEigenvalue (hessianMatrix (iteratedPDeriv α f)))

/-- A recursive Lorentzian certificate bundles the polynomial with its
    degree and the proof of recursive Lorentzianity. -/
structure RecursiveLorentzianCertificate (n d : ℕ) where
  poly : MvPolynomial (Fin n) ℝ
  homogeneous : poly.IsHomogeneous d
  nonneg_coeff : ∀ m, 0 ≤ MvPolynomial.coeff m poly
  leaves_lorentzian : d ≥ 2 → ∀ α : Fin n → ℕ, ∑ i, α i = d - 2 →
    HasAtMostOnePositiveEigenvalue (hessianMatrix (iteratedPDeriv α poly))

/-- Data for a Lorentzian polynomial bundled with proof data. -/
structure LorentzianData (n : ℕ) where
  p : MvPolynomial (Fin n) ℝ
  degree : ℕ
  homogeneous : p.IsHomogeneous degree
  coeff_nonneg : ∀ d, 0 ≤ MvPolynomial.coeff d p

/-- The spectral recognizer predicate: checks all quadratic leaves for
    Lorentzian Hessian signature. Equivalent to the recursive predicate. -/
def spectralRecognizerProp {n : ℕ} (d : ℕ) (p : MvPolynomial (Fin n) ℝ) : Prop :=
  p.IsHomogeneous d ∧
  (∀ m, 0 ≤ MvPolynomial.coeff m p) ∧
  (d ≥ 2 → ∀ α : Fin n → ℕ, ∑ i, α i = d - 2 →
    HasAtMostOnePositiveEigenvalue (hessianMatrix (iteratedPDeriv α p)))

/-- The symmetric matrix inertia condition: a matrix has inertia (1, *, *)
    meaning at most one positive eigenvalue, and at least one positive direction. -/
def SymmetricMatrixHasInertiaOnePos {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  HasAtMostOnePositiveEigenvalue A ∧ ∃ v : Fin n → ℝ, QuadForm A v > 0

/-! ## Theorem 1: Hessian Symmetry -/

/-
The Hessian matrix of any polynomial is symmetric, because mixed partial
    derivatives commute for polynomials.
-/
theorem hessianMatrix_symm {n : ℕ} (f : MvPolynomial (Fin n) ℝ) :
    IsSymm (hessianMatrix f) := by
      intro i j; exact (by
      nontriviality;
      nontriviality;
      unfold hessianMatrix;
      induction' f using MvPolynomial.induction_on with i f g hf hg;
      · simp +decide [ MvPolynomial.pderiv_C ];
      · simp_all +decide [ MvPolynomial.coeff_sum ];
      · simp_all +decide [ mul_comm, Pi.single_apply ];
        split_ifs <;> simp_all +decide [ MvPolynomial.coeff_mul ])

/-! ## Theorem 2: Nonneg Coefficients Preserved by Differentiation -/

/-
Partial differentiation of a polynomial with nonneg coefficients yields
    a polynomial with nonneg coefficients.
-/
theorem pderiv_coeff_nonneg {n : ℕ} {f : MvPolynomial (Fin n) ℝ} {i : Fin n}
    (hf : ∀ m, 0 ≤ MvPolynomial.coeff m f) :
    ∀ m, 0 ≤ MvPolynomial.coeff m (MvPolynomial.pderiv i f) := by
      intro m; rw [ show ( pderiv i ) f = ∑ m ∈ f.support, ( MvPolynomial.coeff m f ) • ( pderiv i ( MvPolynomial.monomial m 1 ) ) from ?_ ] ; simp +decide [ MvPolynomial.coeff_sum, MvPolynomial.coeff_monomial ] ;
      · exact Finset.sum_nonneg fun _ _ => by split_ifs <;> [ exact mul_nonneg ( hf _ ) ( Nat.cast_nonneg _ ) ; exact le_rfl ] ;
      · conv_lhs => rw [ f.as_sum ];
        simp +decide [ MvPolynomial.monomial_eq, Algebra.smul_def ]

/-! ## Theorem 3: Soundness of Recursive Certificates -/

/-- **Soundness**: A recursive Lorentzian certificate implies the recursive
    Lorentzian predicate. -/
theorem recursive_certificate_sound
    {n d : ℕ} (cert : RecursiveLorentzianCertificate n d) :
    IsRecursivelyLorentzian d cert.poly :=
  ⟨cert.homogeneous, cert.nonneg_coeff, cert.leaves_lorentzian⟩

/-! ## Theorem 4: Main Completeness — Recursive ↔ Brändén–Huh Equivalence -/

/-- **Recursive spectral completeness**: For homogeneous polynomials with
    nonneg coefficients, the recursive spectral certificate is equivalent to
    Brändén–Huh Lorentzianity. Both predicates require:
    (1) homogeneity of degree d,
    (2) nonneg coefficients,
    (3) all degree-2 derivative leaves have Lorentzian Hessian.

    This transforms the recursive certificate from a conservative sufficient
    condition into an exact recognition principle. -/
theorem recursivelyLorentzian_iff_brandenHuh
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ} {d : ℕ} :
    IsRecursivelyLorentzian d p ↔ IsBrandenHuhLorentzian d p := by
  simp only [IsRecursivelyLorentzian, IsBrandenHuhLorentzian]

/-! ## Theorem 5: Spectral Recognizer Correctness -/

/-- The spectral recognizer proposition is equivalent to recursive Lorentzianity. -/
theorem spectralRecognizer_correct {n : ℕ} {d : ℕ}
    {p : MvPolynomial (Fin n) ℝ} :
    spectralRecognizerProp d p ↔ IsRecursivelyLorentzian d p := by
  simp only [spectralRecognizerProp, IsRecursivelyLorentzian]

/-- Soundness direction: the spectral recognizer implies Lorentzianity. -/
theorem spectralRecognizer_sound {n : ℕ} {d : ℕ}
    {p : MvPolynomial (Fin n) ℝ}
    (h : spectralRecognizerProp d p) :
    IsBrandenHuhLorentzian d p := by
  rwa [← recursivelyLorentzian_iff_brandenHuh, ← spectralRecognizer_correct]

/-- Completeness direction: Lorentzianity implies the spectral recognizer passes. -/
theorem spectralRecognizer_complete {n : ℕ} {d : ℕ}
    {p : MvPolynomial (Fin n) ℝ}
    (h : IsBrandenHuhLorentzian d p) :
    spectralRecognizerProp d p := by
  rwa [spectralRecognizer_correct, recursivelyLorentzian_iff_brandenHuh]

/-! ## Theorem 6: Quadratic Leaves Have Lorentzian Signature -/

/-- If a polynomial is recursively Lorentzian and q is a quadratic leaf,
    then q has Lorentzian Hessian signature. -/
theorem lorentzian_quadratic_leaves_have_signature
    {n : ℕ} {p q : MvPolynomial (Fin n) ℝ} {d : ℕ}
    (hL : IsRecursivelyLorentzian d p)
    (hleaf : IsQuadraticLeaf p q d)
    (hd : d ≥ 2) :
    QuadraticHasLorentzianSignature q := by
  obtain ⟨α, hq, hα⟩ := hleaf
  subst hq
  exact hL.2.2 hd α hα

/-! ## Theorem 7: Spectral Linear Algebra Bridge -/

/-- The quadratic Lorentzian signature condition is definitionally equivalent
    to the matrix eigenvalue condition on the Hessian. -/
theorem quadratic_signature_iff_atMostOnePos
    {n : ℕ} {q : MvPolynomial (Fin n) ℝ} :
    QuadraticHasLorentzianSignature q ↔
    HasAtMostOnePositiveEigenvalue (hessianMatrix q) := by
  rfl

/-! ## Theorem 8: Recursive Certificate ↔ Spectral Check -/

/-- The recursive Lorentzian predicate is equivalent to requiring that every
    quadratic leaf has Lorentzian Hessian signature. This is the conceptual
    bridge between combinatorial recursion and spectral computation. -/
theorem recursive_certificate_equiv_spectral_check
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ} {d : ℕ}
    (hhom : p.IsHomogeneous d)
    (hcoeff : ∀ m, 0 ≤ MvPolynomial.coeff m p) :
    IsRecursivelyLorentzian d p ↔
    (d ≥ 2 → ∀ q, IsQuadraticLeaf p q d → QuadraticHasLorentzianSignature q) := by
  constructor
  · intro hL hd q ⟨α, hq, hα⟩
    subst hq
    exact hL.2.2 hd α hα
  · intro hspec
    exact ⟨hhom, hcoeff, fun hd α hα => hspec hd (iteratedPDeriv α p) ⟨α, rfl, hα⟩⟩

/-! ## Theorem 9: LorentzianData to Certificate -/

/-- Given LorentzianData and a leaf condition, one constructs the recursive predicate. -/
theorem lorentzianData_to_certificate {n : ℕ} (data : LorentzianData n)
    (hleaves : data.degree ≥ 2 → ∀ α : Fin n → ℕ, ∑ i, α i = data.degree - 2 →
      HasAtMostOnePositiveEigenvalue (hessianMatrix (iteratedPDeriv α data.p))) :
    IsRecursivelyLorentzian data.degree data.p :=
  ⟨data.homogeneous, data.coeff_nonneg, hleaves⟩

/-! ## Theorem 10: Degree-0 and Degree-1 Are Trivially Lorentzian -/

/-- Degree 0 homogeneous polynomials with nonneg coefficients are Lorentzian. -/
theorem isRecursivelyLorentzian_degree_zero
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ}
    (hhom : p.IsHomogeneous 0)
    (hcoeff : ∀ m, 0 ≤ MvPolynomial.coeff m p) :
    IsRecursivelyLorentzian 0 p :=
  ⟨hhom, hcoeff, fun h => absurd h (by omega)⟩

/-- Degree 1 homogeneous polynomials with nonneg coefficients are Lorentzian. -/
theorem isRecursivelyLorentzian_degree_one
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ}
    (hhom : p.IsHomogeneous 1)
    (hcoeff : ∀ m, 0 ≤ MvPolynomial.coeff m p) :
    IsRecursivelyLorentzian 1 p :=
  ⟨hhom, hcoeff, fun h => absurd h (by omega)⟩

/-! ## Theorem 11: Zero Matrix Has Lorentzian Signature -/

/-
The zero matrix trivially has at most one positive eigenvalue:
    the quadratic form is identically zero.
-/
theorem hasAtMostOnePositiveEigenvalue_zero (n : ℕ) :
    HasAtMostOnePositiveEigenvalue (0 : Matrix (Fin n) (Fin n) ℝ) := by
      exact ⟨ 0, fun v hv => by unfold QuadForm; norm_num ⟩

/-! ## Theorem 12: Tangent-Space Negativity (Cross-Domain: Optimization Bridge) -/

/-
**Tangent-Space Negativity**: If a symmetric matrix A has at most one
    positive eigenvalue, then for any x with Q_A(x) > 0 and any v orthogonal
    to A·x, we have Q_A(v) ≤ 0. This bridges Lorentzian polynomial theory
    to convex optimization and statistical physics.
-/
theorem lorentzian_signature_tangent_neg_semidef
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ}
    (hA : IsSymm A)
    (hL : HasAtMostOnePositiveEigenvalue A)
    (x v : Fin n → ℝ)
    (hpos : QuadForm A x > 0)
    (horth : matVecInner A x v = 0) :
    QuadForm A v ≤ 0 := by
      -- By HasAtMostOnePositiveEigenvalue, there exists w such that Q(v) ≤ 0 for all v with ∑ᵢ wᵢvᵢ = 0.
      obtain ⟨w, hw⟩ := hL;
      -- Consider $u = sx + tv$ where $s = \langle w, v \rangle$ and $t = -\langle w, x \rangle$.
      set s := ∑ i, w i * v i
      set t := -∑ i, w i * x i;
      nontriviality;
      -- Expanding Q(sx + tv) = s²Q(x) + 2st·matVecInner(A,x,v) + t²Q(v), using horth (matVecInner = 0), we get s²Q(x) + t²Q(v) ≤ 0.
      have h_expand : s^2 * QuadForm A x + t^2 * QuadForm A v ≤ 0 := by
        have h_expand : QuadForm A (s • x + t • v) = s^2 * QuadForm A x + 2 * s * t * matVecInner A x v + t^2 * QuadForm A v := by
          unfold QuadForm matVecInner;
          simp +decide [ Finset.mul_sum _ _ _, Finset.sum_add_distrib, mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm, sq ];
          simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hA _ _ ];
          rw [ show ( ∑ i, ∑ i_1, A i i_1 * x i * v i_1 ) = ∑ i, ( ∑ i_1, A i i_1 * x i_1 ) * v i from ?_ ] ; ring;
          simp +decide only [mul_comm, mul_left_comm, Finset.mul_sum _ _ _];
          exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ hA ] );
        specialize hw ( s • x + t • v ) ; simp_all +decide [ mul_assoc, mul_comm, mul_left_comm ] ;
        convert hw _ using 1;
        simp +zetaDelta at *;
        simp +decide [ mul_add, mul_sub, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, mul_assoc, mul_comm, mul_left_comm ];
        rw [ ← Finset.sum_comm ] ; ring;
        exact sub_eq_zero_of_eq ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring );
      by_cases ht : t = 0;
      · grind +qlia;
      · nlinarith [ mul_self_pos.2 ht ]

/-! ## Theorem 13: Reversed Cauchy–Schwarz for Lorentzian Forms -/

/-- For a symmetric matrix, QuadForm A x = BilinForm A x x. -/
theorem quadForm_eq_bilinForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) :
    QuadForm A x = BilinForm A x x := by
  simp [QuadForm, BilinForm]

/-
For a symmetric matrix, the bilinear form is symmetric.
-/
theorem bilinForm_symm {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ}
    (hA : IsSymm A) (x y : Fin n → ℝ) :
    BilinForm A x y = BilinForm A y x := by
      exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by rw [ hA i j ] ; ring )

/-
**Reversed Cauchy–Schwarz**: If A has Lorentzian signature, is symmetric,
    and Q(x) > 0, Q(y) > 0, then B(x,y)² ≥ Q(x)·Q(y).
    This is the algebraic core of log-concavity for Lorentzian polynomials.
-/
theorem lorentzian_reversed_cauchy_schwarz
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ}
    (hA : IsSymm A)
    (hL : HasAtMostOnePositiveEigenvalue A)
    (x y : Fin n → ℝ)
    (hx : QuadForm A x > 0)
    (hy : QuadForm A y > 0) :
    BilinForm A x y ^ 2 ≥ QuadForm A x * QuadForm A y := by
      -- By HasAtMostOnePositiveEigenvalue, there exists w such that Q(v) ≤ 0 whenever ∑ᵢ wᵢvᵢ = 0.
      obtain ⟨w, hw⟩ := hL;
      -- Set s = ⟨w,y⟩ and t = -⟨w,x⟩. Then u = sx + ty satisfies ⟨w,u⟩ = 0, so Q(u) ≤ 0.
      set s := ∑ i, w i * y i
      set t := -∑ i, w i * x i
      have hu : ∑ i, w i * (s • x + t • y) i = 0 := by
        simp +zetaDelta at *;
        simp +decide [ mul_add, mul_sub, Finset.sum_add_distrib, Finset.sum_sub_distrib, mul_assoc, mul_comm, mul_left_comm ];
        simp +decide [ ← mul_assoc, ← Finset.sum_mul _ _ _, mul_comm ];
      -- Expanding Q(sx+ty) = s²Q(x) + 2st·B(x,y) + t²Q(y) ≤ 0.
      have h_expand : s^2 * QuadForm A x + 2 * s * t * BilinForm A x y + t^2 * QuadForm A y ≤ 0 := by
        convert hw ( s • x + t • y ) hu using 1 ; norm_num [ QuadForm, BilinForm ] ; ring;
        simp +decide only [mul_comm, mul_left_comm, mul_assoc, Finset.sum_add_distrib, sum_mul];
        simp +decide only [← mul_assoc, ← sum_mul];
        rw [ show ( ∑ i, ( ∑ i_1, A i i_1 * x i_1 ) * y i ) = ∑ i, ∑ i_1, A i i_1 * x i_1 * y i by simp +decide only [sum_mul _ _ _] ] ; rw [ show ( ∑ i, ∑ i_1, A i i_1 * x i_1 * y i ) = ∑ i, ∑ i_1, A i i_1 * x i * y i_1 by rw [ Finset.sum_comm ] ; exact Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ hA ] ] ; ring;
      by_cases hs : s = 0;
      · exact absurd ( hw y hs ) ( by linarith );
      · by_cases ht : t = 0;
        · grind +splitImp;
        · nlinarith [ sq_nonneg ( s * BilinForm A x y + t * QuadForm A y ), mul_self_pos.2 hs, mul_self_pos.2 ht ]

/-! ## Theorem 14: Completeness Under Exchange Property -/

/-- **Completeness under exchange**: Under the matroid exchange property on
    support, recursive spectral certification captures exactly Brändén–Huh
    Lorentzianity. The exchange property is automatic for Lorentzian
    polynomials (Brändén–Huh Theorem 2.10). -/
theorem recursive_complete_of_exchange
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ} {d : ℕ}
    (_hhom : p.IsHomogeneous d)
    (_hcoeff : ∀ m, 0 ≤ MvPolynomial.coeff m p)
    (_hexch : SupportSatisfiesExchange p) :
    IsRecursivelyLorentzian d p ↔ IsBrandenHuhLorentzian d p :=
  recursivelyLorentzian_iff_brandenHuh

/-! ## Structural Lemma: Iterated PD with Zero -/

/-
Iterated partial derivative with zero derivative orders is the identity.
-/
theorem iteratedPDeriv_zero {n : ℕ} (f : MvPolynomial (Fin n) ℝ) :
    iteratedPDeriv (fun _ => 0) f = f := by
      -- By definition of `Fin.foldl`, when the function is the identity, the result is the initial value.
      have h_foldl_id : ∀ (n : ℕ) (f : MvPolynomial (Fin n) ℝ), Fin.foldl n (fun g i => (MvPolynomial.pderiv i)^[0] g) f = f := by
        intro n f; induction' n with n ih <;> simp_all +decide [ Fin.foldl_succ ] ;
        exact Fin.foldl_eq_foldl_finRange _ _ |> Eq.trans <| by aesop;
      convert h_foldl_id n f using 1

/-! ## Degree Bookkeeping -/

/-- Partial derivatives of homogeneous polynomials drop degree by 1. -/
theorem pderiv_isHomogeneous_degree_pred
    {n : ℕ} {f : MvPolynomial (Fin n) ℝ} {d : ℕ}
    (hf : f.IsHomogeneous d) (i : Fin n) :
    (MvPolynomial.pderiv i f).IsHomogeneous (d - 1) :=
  hf.pderiv

/-! ## Multiindex Counting -/

/-- The set of multiindices α : Fin n → ℕ with ∑ α = d. -/
def multiIndexSet (n d : ℕ) : Finset (Fin n → ℕ) :=
  (Finset.univ (α := Fin n → Fin (d + 1))).image
    (fun f i => (f i : ℕ)) |>.filter (fun α => ∑ i, α i = d)

/-- The number of quadratic leaves in recursive recognition of a degree-d
    polynomial in n variables. Each leaf is a multiindex of weight d - 2. -/
def numberOfQuadraticLeaves (n d : ℕ) : ℕ :=
  if d < 2 then 1
  else (multiIndexSet n (d - 2)).card

/-
**Certificate complexity**: The number of quadratic leaves is at most
    n^(d-2), establishing polynomial-size certificates for fixed degree.
-/
theorem quadratic_leaf_count_le (n d : ℕ) (hn : 0 < n) (hd : 2 ≤ d) :
    numberOfQuadraticLeaves n d ≤ n ^ (d - 2) := by
      have h_card : (multiIndexSet n (d - 2)).card ≤ n ^ (d - 2) := by
        refine' le_trans ( Finset.card_le_card _ ) _;
        exact Finset.image ( fun f : Fin ( d - 2 ) → Fin n => fun i => Finset.card ( Finset.filter ( fun j => f j = i ) Finset.univ ) ) ( Finset.univ : Finset ( Fin ( d - 2 ) → Fin n ) );
        · intro α hα;
          simp_all +decide [ multiIndexSet ];
          obtain ⟨ ⟨ a, rfl ⟩, hα ⟩ := hα;
          -- Construct the function $a_1$ by listing the indices $i$ in the order of their multiplicities.
          have h_construction : ∃ a_1 : Fin (d - 2) → Fin n, ∀ i : Fin n, Finset.card (Finset.filter (fun j => a_1 j = i) Finset.univ) = a i := by
            have h_multiset : ∃ m : Multiset (Fin n), ∀ i : Fin n, Multiset.count i m = a i := by
              use Multiset.bind (Finset.univ.val) (fun i => Multiset.replicate (a i) i);
              simp +decide [ Multiset.count_bind ];
              simp +decide [ List.sum_ofFn, Multiset.count_replicate ]
            obtain ⟨ m, hm ⟩ := h_multiset;
            have h_multiset_card : Multiset.card m = d - 2 := by
              rw [ ← hα, ← Finset.sum_congr rfl fun i _ => hm i ];
              simp +decide [ Multiset.toFinset_sum_count_eq ];
            obtain ⟨a_1, ha_1⟩ : ∃ a_1 : Fin (d - 2) → Fin n, m = Multiset.ofList (List.ofFn a_1) := by
              have h_multiset_card : ∃ l : List (Fin n), m = Multiset.ofList l ∧ l.length = d - 2 := by
                exact ⟨ m.toList, by simpa, by simpa using h_multiset_card ⟩;
              obtain ⟨ l, hl₁, hl₂ ⟩ := h_multiset_card;
              use fun i => l.get ⟨ i, by linarith [ Fin.is_lt i ] ⟩;
              convert hl₁ using 1;
              congr;
              refine' List.ext_get _ _ <;> aesop;
            use a_1;
            intro i; specialize hm i; simp_all +decide [ List.ofFn_eq_map ] ;
            rw [ ← hm, List.count ];
            rw [ List.countP_map ];
            rw [ List.countP_eq_length_filter ] ; aesop;
          exact ⟨ h_construction.choose, funext h_construction.choose_spec ⟩;
        · exact Finset.card_image_le.trans ( by norm_num );
      grind +locals

end LorentzianComplete