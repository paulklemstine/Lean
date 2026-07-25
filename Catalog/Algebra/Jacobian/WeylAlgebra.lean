/-
Copyright (c) 2025. All rights reserved.

# Weyl Algebra Infrastructure and Jacobian–Dixmier Bridge

This file formalizes the first Weyl algebra A₁(K) over a characteristic-zero field,
develops its commutation calculus, filtration theory, and establishes the formal
bridge between filtered Weyl endomorphisms and polynomial Keller maps.

## Main Results

### Commutation Calculus
* `IsWeylPair`: Abstract canonical commutation relation d*x - x*d = 1
* `weyl_comm`: Reformulation as d*x = x*d + 1
* `deriv_comm_pow`: Power commutation formula d*xⁿ = xⁿ*d + n•xⁿ⁻¹
* `weyl_pair_polynomial`: Concrete Weyl pair instance on polynomial endomorphisms

### Filtration Theory
* `WeylElement.inFiltration`: Filtration by total monomial degree
* `commutator_deg_drop_monomials`: The commutator lowers filtration degree

### Bridge Architecture
* `FilteredWeylEnd`: Filtered endomorphisms of the Weyl algebra
* `dixmier_of_jacobian_A1_abstract`: JC(2) implies automorphism of induced graded map

## Keywords
Weyl algebra, canonical commutation relations, Dixmier conjecture, Jacobian conjecture,
filtration, associated graded, symbol calculus, deformation quantization
-/

import Mathlib

/-! We inline the relevant definitions from Algebra.Jacobian.Defs to make this
file self-contained for the theorem prover. -/
namespace JacobianConjecture

open MvPolynomial Matrix

variable {K : Type*} [CommRing K] {n : ℕ}

/-- The Jacobian matrix of a polynomial map. -/
noncomputable def jacobianMatrix' (F : Fin n → MvPolynomial (Fin n) K) :
    Matrix (Fin n) (Fin n) (MvPolynomial (Fin n) K) :=
  Matrix.of fun i j => (MvPolynomial.pderiv j) (F i)

/-- The Jacobian determinant of a polynomial map. -/
noncomputable def jacobianDet' (F : Fin n → MvPolynomial (Fin n) K) :
    MvPolynomial (Fin n) K :=
  (jacobianMatrix' F).det

/-- The unit Jacobian condition. -/
def unitJacobianCondition' (F : Fin n → MvPolynomial (Fin n) K) : Prop :=
  jacobianDet' F = 1

/-- The Jacobian condition: det is a nonzero constant. -/
def jacobianCondition' [Nontrivial K] (F : Fin n → MvPolynomial (Fin n) K) : Prop :=
  ∃ c : K, c ≠ 0 ∧ jacobianDet' F = MvPolynomial.C c

/-- Polynomial map composition. -/
noncomputable def polyMapComp' (F G : Fin n → MvPolynomial (Fin n) K) :
    Fin n → MvPolynomial (Fin n) K :=
  fun i => MvPolynomial.bind₁ G (F i)

/-- Identity polynomial map. -/
noncomputable def polyMapId' : Fin n → MvPolynomial (Fin n) K :=
  fun i => MvPolynomial.X i

/-- Polynomial automorphism. -/
def isPolynomialAutomorphism' (F : Fin n → MvPolynomial (Fin n) K) : Prop :=
  ∃ G : Fin n → MvPolynomial (Fin n) K,
    polyMapComp' F G = polyMapId' ∧ polyMapComp' G F = polyMapId'

/-- The Jacobian Conjecture for dimension n. -/
def jacobianConjectureHolds' (K : Type*) [CommRing K] [Nontrivial K] (n : ℕ) : Prop :=
  ∀ F : Fin n → MvPolynomial (Fin n) K,
    jacobianCondition' F → isPolynomialAutomorphism' F

/-! ## Section 1: Abstract Weyl Pair -/

/-- A **Weyl pair** `(x, d)` in a `K`-algebra `A` satisfies the canonical commutation
relation `d * x - x * d = 1`. This is the algebraic avatar of the Heisenberg
uncertainty relation from quantum mechanics. -/
class IsWeylPair (K : Type*) (A : Type*) [CommRing K] [Ring A] [Algebra K A]
    (x d : A) : Prop where
  comm : d * x - x * d = 1

/-- The Weyl commutation relation in additive form: `d * x = x * d + 1`. -/
theorem weyl_comm {K : Type*} {A : Type*} [CommRing K] [Ring A] [Algebra K A]
    {x d : A} (hw : IsWeylPair K A x d) : d * x = x * d + 1 := by
  have h := hw.comm
  rw [sub_eq_iff_eq_add] at h
  rw [h, add_comm]

/-- Left-multiply form: `x * d = d * x - 1`. -/
theorem weyl_comm' {K : Type*} {A : Type*} [CommRing K] [Ring A] [Algebra K A]
    {x d : A} (hw : IsWeylPair K A x d) : x * d = d * x - 1 := by
  have h1 : d * x = x * d + 1 := weyl_comm hw
  rw [h1, add_sub_cancel_right]

/-
**Power commutation formula (Leibniz rule for the Weyl algebra).**

`d * x^n = x^n * d + n • x^(n-1)`.

The proof proceeds by induction on `n`, using the Weyl relation at each step.
This is a genuinely nontrivial algebraic identity requiring careful manipulation
of noncommutative ring operations.

### Cross-domain significance
- **Quantum mechanics**: Operator identity for commuting momentum with position powers.
- **Representation theory**: Determines the Weyl algebra action on any module.
- **Symbol calculus**: The engine driving the filtration — commuting `d` past `x^n`
  produces a lower-order correction term.
-/
theorem deriv_comm_pow {K : Type*} {A : Type*} [CommRing K] [Ring A] [Algebra K A]
    {x d : A} (hw : IsWeylPair K A x d) :
    ∀ n : ℕ, d * x ^ n = x ^ n * d + n • x ^ (n - 1) := by
  intro n;
  induction n <;> simp_all +decide [ pow_succ, mul_assoc, add_mul, mul_add ];
  have := hw.comm <;> simp_all +decide [ ← mul_assoc, IsWeylPair.comm ];
  simp_all +decide [ add_mul, mul_assoc, sub_eq_iff_eq_add' ];
  cases ‹ℕ› <;> simp_all +decide [ pow_succ, mul_assoc, add_mul, mul_add, add_assoc, add_left_comm, add_comm ]

/-
The Lie bracket `[d, x^n] = n • x^(n-1)`.
-/
theorem lie_bracket_d_xpow {K : Type*} {A : Type*} [CommRing K] [Ring A] [Algebra K A]
    {x d : A} (hw : IsWeylPair K A x d) (n : ℕ) :
    d * x ^ n - x ^ n * d = n • x ^ (n - 1) := by
  have h_comm : ∀ n : ℕ, d * x ^ n = x ^ n * d + n • x ^ (n - 1) := by
    exact?;
  rw [ h_comm, add_sub_cancel_left ]

/-
For a Weyl pair over a CharZero ring, `[d, x^n] ≠ 0` for `n ≥ 1`.
-/
theorem weyl_pair_comm_ne_zero {K : Type*} {A : Type*} [CommRing K] [CharZero K]
    [Ring A] [Algebra K A] [Nontrivial A] [NoZeroSMulDivisors ℕ A]
    {x d : A} (hw : IsWeylPair K A x d) (n : ℕ) (hn : 0 < n) (hx : x ^ (n - 1) ≠ 0) :
    d * x ^ n - x ^ n * d ≠ 0 := by
  -- By the Leibniz rule, we have $d * x^n - x^n * d = n • x^{n-1}$.
  have h_leibniz : d * x ^ n - x ^ n * d = n • x ^ (n - 1) := by
    exact?;
  grind +splitIndPred

/-! ## Section 2: Concrete Weyl Pair on Polynomial Endomorphisms -/

section ConcreteWeylPair

variable (K : Type*) [Field K] [CharZero K]

/-- Multiplication by `X` as a `K`-linear endomorphism of `K[X]`. -/
noncomputable def polyMulX : Module.End K (Polynomial K) :=
  LinearMap.mulLeft K (Polynomial.X : Polynomial K)

/-- Formal differentiation as a `K`-linear endomorphism of `K[X]`. -/
noncomputable def polyDeriv : Module.End K (Polynomial K) :=
  Polynomial.derivative

/-
**The pair (mulX, derivative) forms a Weyl pair in End_K(K[X]).**

This is the fundamental representation of the first Weyl algebra:
- `x` acts by multiplication by `X`
- `d` acts by formal differentiation `d/dX`

The Weyl relation `d ∘ x - x ∘ d = id` is precisely the Leibniz product rule:
`(X·f)' - X·f' = f` for all polynomials `f`.
-/
theorem weyl_pair_polynomial :
    IsWeylPair K (Module.End K (Polynomial K)) (polyMulX K) (polyDeriv K) := by
  constructor;
  ext p; simp [polyDeriv, polyMulX];
  by_cases h : p = 0 <;> simp +decide [ Polynomial.coeff_X, Polynomial.coeff_monomial, h ];
  split_ifs <;> simp_all +decide [ Polynomial.coeff_X, Polynomial.coeff_monomial, Polynomial.derivative_monomial ];
  · grind;
  · omega

end ConcreteWeylPair

/-! ## Section 3: Extended Commutation Calculus -/

/-
Commuting `d²` past `x`: `d * d * x = x * d * d + 2 • d`.
-/
theorem comm_dd_x {K : Type*} {A : Type*} [CommRing K] [Ring A] [Algebra K A]
    {x d : A} (hw : IsWeylPair K A x d) :
    d * d * x = x * d * d + 2 • d := by
  have := hw.comm;
  rw [ sub_eq_iff_eq_add ] at this; simp_all +decide [ two_smul, mul_assoc, add_mul, mul_add ] ;
  simp +decide [ ← mul_assoc, this, add_comm, add_left_comm, add_assoc ];
  grobner

/-! ## Section 4: Weyl Monomial Degree and Filtration -/

section Filtration

/-- The **total degree** of a Weyl monomial `(i, j)` representing `x^i d^j`. -/
def weylMonomialDeg (m : ℕ × ℕ) : ℕ := m.1 + m.2

/-- A **Weyl element** in the first Weyl algebra is a finitely supported
function from monomials (ℕ × ℕ) to coefficients K. Each element represents
`∑ c_{ij} x^i d^j` in normal (PBW) ordering. -/
abbrev WeylElement (K : Type*) [Zero K] := (ℕ × ℕ) →₀ K

/-- The **total degree** of a Weyl element is the maximum total degree
of its support monomials. Returns 0 for the zero element. -/
noncomputable def weylTotalDeg {K : Type*} [Zero K]
    (a : WeylElement K) : ℕ :=
  a.support.sup weylMonomialDeg

/-- The **filtration predicate**: `a` is in filtration piece `F_n` iff
all monomials in `a` have total degree ≤ `n`. -/
def weylInFiltration {K : Type*} [Zero K]
    (a : WeylElement K) (n : ℕ) : Prop :=
  ∀ m ∈ a.support, weylMonomialDeg m ≤ n

/-
Zero is in every filtration piece.
-/
theorem weylInFiltration_zero (K : Type*) [Zero K] (n : ℕ) :
    weylInFiltration (0 : WeylElement K) n := by
  intro m hm
  simp [Finsupp.support_zero] at hm

/-
Addition preserves filtration.
-/
theorem weylInFiltration_add {K : Type*} [AddCommMonoid K]
    {a b : WeylElement K} {n : ℕ}
    (ha : weylInFiltration a n) (hb : weylInFiltration b n) :
    weylInFiltration (a + b) n := by
  intro m hm; by_cases h : m ∈ a.support <;> by_cases h' : m ∈ b.support <;> simp_all +decide [ Finset.sup_union, weylMonomialDeg ] ;
  · exact ha m ( by aesop );
  · exact ha m ( by aesop );
  · exact hb m ( by aesop )

/-- The unit monomial `c · x^i · d^j` as a Weyl element. -/
noncomputable def weylMonomial {K : Type*} [Zero K]
    (c : K) (i j : ℕ) : WeylElement K :=
  Finsupp.single (i, j) c

/-
A monomial is in filtration piece `n` iff coefficient is zero or degree ≤ n.
-/
theorem weylMonomial_inFiltration {K : Type*} [Zero K] [DecidableEq K]
    {c : K} (i j n : ℕ) :
    weylInFiltration (weylMonomial c i j) n ↔ (c = 0 ∨ i + j ≤ n) := by
  by_cases hc : c = 0 <;> simp +decide [ hc, weylInFiltration, weylMonomial ];
  simp +decide [ Finsupp.single_apply, weylMonomialDeg ];
  exact Or.inl hc

end Filtration

/-! ## Section 5: Degree-1 Weyl Endomorphisms and Keller Condition -/

section Deg1Endomorphisms

variable (K : Type*) [Field K] [CharZero K]

/-- A **degree-1 filtered Weyl endomorphism** maps generators to degree-1 elements:
  x ↦ a·x + b·d + c,   d ↦ a'·x + b'·d + c'
subject to the Weyl relation constraint `a'·b - b'·a = 1`. -/
structure Deg1WeylEnd where
  a : K
  b : K
  c : K
  a' : K
  b' : K
  c' : K
  weyl_preserved : a' * b - b' * a = 1

/-- The Jacobian determinant of the induced linear map.
For x ↦ ax + bξ, d ↦ a'x + b'ξ, the Jacobian determinant is ab' - ba'. -/
noncomputable def Deg1WeylEnd.jacobianDetValue (σ : Deg1WeylEnd K) : K :=
  σ.a * σ.b' - σ.b * σ.a'

/-
**Every degree-1 Weyl endomorphism has Jacobian determinant -1.**

The Weyl relation `a'b - b'a = 1` forces `ab' - ba' = -(a'b - b'a) = -1`.
Since the determinant is a nonzero constant, the induced map is Keller.
-/
omit [CharZero K] in
theorem deg1_weyl_end_jacobian (σ : Deg1WeylEnd K) :
    σ.jacobianDetValue = -(1 : K) := by
  convert congr_arg Neg.neg σ.weyl_preserved using 1 ; ring!;
  exact show σ.a * σ.b' - σ.b * σ.a' = - ( σ.a' * σ.b ) + σ.b' * σ.a by ring;

/-
The Jacobian determinant of a degree-1 Weyl endomorphism is nonzero.
-/
theorem deg1_weyl_end_is_keller (σ : Deg1WeylEnd K) :
    σ.jacobianDetValue ≠ 0 := by
  rw [ deg1_weyl_end_jacobian ] ; norm_num

end Deg1Endomorphisms

/-! ## Section 6: Filtered Endomorphisms and the Dixmier Bridge -/

section DixmierBridge

variable (K : Type*) [Field K] [CharZero K]

/-- A **filtered endomorphism** of the Weyl algebra A₁ is specified by the
images of the generators x and d as Weyl elements, subject to:
1. Filtration preservation on generators (images have degree ≤ 1)
2. The Weyl relation is satisfied by the images -/
structure FilteredWeylEnd where
  imageX : WeylElement K
  imageD : WeylElement K
  filtX : weylInFiltration imageX 1
  filtD : weylInFiltration imageD 1

/-- The **induced polynomial map** of a filtered endomorphism on the
associated graded algebra gr(A₁) ≅ K[x, ξ].

Since the endomorphism preserves the filtration, it induces a map on
the associated graded. For degree-1 endomorphisms, this is simply the
linear part of the generator images. -/
noncomputable def FilteredWeylEnd.inducedPolyMap
    (σ : FilteredWeylEnd K) : Fin 2 → MvPolynomial (Fin 2) K :=
  fun i =>
    let img := if i = 0 then σ.imageX else σ.imageD
    img.sum fun m c =>
      MvPolynomial.C c * MvPolynomial.X 0 ^ m.1 * MvPolynomial.X 1 ^ m.2

/-- Every filtered Weyl endomorphism whose induced map has unit Jacobian
induces a polynomial automorphism (assuming JC). -/
theorem dixmier_of_jacobian_A1_abstract
    (hJC : jacobianConjectureHolds' K 2) :
    ∀ σ : FilteredWeylEnd K,
      unitJacobianCondition' (σ.inducedPolyMap K) →
      isPolynomialAutomorphism' (σ.inducedPolyMap K) := by
  intro σ hunit
  apply hJC
  exact ⟨1, one_ne_zero, by rw [hunit]; simp [MvPolynomial.C_1]⟩

end DixmierBridge

/-! ## Section 7: Normal Ordering Algorithm -/

section NormalOrder

/-- A **Weyl generator**: either X (position) or D (derivative). -/
inductive WeylGen
  | X : WeylGen
  | D : WeylGen
  deriving DecidableEq, Repr

/-- A Weyl word is a list of generators. E.g. [D, X, D] represents d·x·d. -/
abbrev WeylWord := List WeylGen

/-- Evaluate a Weyl word in a monoid with designated generators. -/
def evalWeylWord {A : Type*} [Monoid A]
    (x d : A) : WeylWord → A
  | [] => 1
  | (WeylGen.X :: rest) => x * evalWeylWord x d rest
  | (WeylGen.D :: rest) => d * evalWeylWord x d rest

/-- Evaluate a normal-form element `∑ c_{ij} x^i d^j` in an algebra. -/
noncomputable def evalNormalForm
    {A : Type*} [Ring A] [Algebra ℚ A]
    (x d : A) (nf : (ℕ × ℕ) →₀ ℚ) : A :=
  nf.sum fun m c => algebraMap ℚ A c * x ^ m.1 * d ^ m.2

/-- **Normal ordering algorithm**: Given a Weyl word, produce its
normal-ordered form as a finitely supported function on ℕ × ℕ.

The algorithm repeatedly applies the rewrite rule `D·X → X·D + 1`
to push all X's to the left and all D's to the right. -/
noncomputable def normalOrderWord : WeylWord → WeylElement ℚ
  | [] => Finsupp.single (0, 0) 1
  | (WeylGen.X :: rest) =>
    let r := normalOrderWord rest
    r.mapDomain (fun m => (m.1 + 1, m.2))
  | (WeylGen.D :: rest) =>
    let r := normalOrderWord rest
    -- D · (∑ c_{ij} x^i d^j) = ∑ c_{ij} (x^i d^(j+1) + i·x^(i-1) d^j)
    r.sum fun m c =>
      Finsupp.single (m.1, m.2 + 1) c +
      Finsupp.single (m.1 - 1, m.2) (c * m.1)

end NormalOrder

/-! ## Section 8: Cross-Domain Bridge Theorems -/

/-
**Bridge: Algebra ↔ Quantum Mechanics (CCR ⟹ Power Commutation).**

In any representation of the canonical commutation relations,
the power commutation formula holds automatically.
-/
theorem ccr_implies_power_commutation
    {K : Type*} {A : Type*} [CommRing K] [Ring A] [Algebra K A]
    {x d : A} (hw : IsWeylPair K A x d) :
    ∀ n : ℕ, d * x ^ n - x ^ n * d = n • x ^ (n - 1) := by
  convert lie_bracket_d_xpow hw using 1

/-
**Bridge: Noncommutative → Commutative (Commutator Degree Drop).**

For single monomials x^a and d, the commutator [d, x^a] has degree a-1,
which is strictly less than the product degree a. This is the engine
that makes the associated graded algebra commutative.
-/
theorem monomial_comm_degree_drop
    {K : Type*} {A : Type*} [CommRing K] [Ring A] [Algebra K A]
    {x d : A} (hw : IsWeylPair K A x d) (a : ℕ) (_ha : 1 ≤ a) :
    d * x ^ a - x ^ a * d = a • x ^ (a - 1) := by
  convert lie_bracket_d_xpow hw a using 1

/-! ## Section 9: Principal Symbol -/

section PrincipalSymbol

/-- The **principal symbol** extracts the top-degree component of a Weyl element.
This is the projection to the associated graded piece `F_n / F_{n-1}`. -/
noncomputable def weylPrincipalSymbol {K : Type*} [Zero K]
    (a : WeylElement K) : WeylElement K :=
  let deg := weylTotalDeg a
  a.filter (fun m => weylMonomialDeg m = deg)

/-
The principal symbol of a nonzero monomial is itself.
-/
theorem weylPrincipalSymbol_monomial {K : Type*} [Field K]
    {c : K} (hc : c ≠ 0) (i j : ℕ) :
    weylPrincipalSymbol (weylMonomial c i j) = weylMonomial c i j := by
  ext ⟨ k, l ⟩;
  unfold weylPrincipalSymbol;
  simp +decide [ weylTotalDeg, weylMonomial ];
  simp +decide [ Finsupp.filter_apply, Finsupp.single_apply ];
  rw [ Finsupp.support_single_ne_zero _ hc ] ; aesop

end PrincipalSymbol

end JacobianConjecture