/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Weighted Support Shadow for Homogeneous Polynomials

This file extends support compression from the multiaffine world to general
homogeneous polynomials with repeated exponents, proving that second-derivative
structure is controlled by the **quadratic shadow** of the Newton support.

## Main Definitions

* `QuadraticShadow` — The set of exponent vectors reachable by subtracting two
  unit vectors from some support element
* `NonzeroQuadLeafSet` — The set of exponent vectors appearing with nonzero
  coefficient in some second partial derivative ∂ᵢ∂ⱼf
* `computeQuadShadow` — A verified algorithm computing the quadratic shadow
  from finite support data

## Main Results

* `coeff_pderiv_single` — Coefficient formula for a single partial derivative
* `coeff_pderiv_pderiv` — Coefficient formula for iterated partial derivatives
* `nonzeroQuadLeafSet_eq_shadow` — The nonzero quadratic leaf set equals the
  quadratic shadow (set equality) — the fundamental theorem
* `mem_computeQuadShadow_iff` — Correctness of the shadow computation algorithm
* `quadShadow_mono` — Monotonicity of shadow under support inclusion

## Relationship to Catalog Results

This extends `SupportCompression.nonzeroDerivativeLeafSet_eq_indep` from the
multiaffine/matroid setting to general homogeneous polynomials. The key discovery
is that for individual second partial derivatives, cancellation never occurs:
each output coefficient is a nonzero scalar multiple of exactly one ancestor.
-/

open MvPolynomial Finsupp BigOperators Classical

noncomputable section

namespace WeightedSupportShadow

variable {σ : Type*} [DecidableEq σ] {R : Type*} [CommSemiring R]

/-! ## Newton Support -/

/-- The Newton support of a polynomial as a finset. -/
def NewtonSupportFinset (f : MvPolynomial σ R) : Finset (σ →₀ ℕ) :=
  f.support

/-- The Newton support as a set. -/
def NewtonSupport (f : MvPolynomial σ R) : Set (σ →₀ ℕ) :=
  {m | MvPolynomial.coeff m f ≠ 0}

theorem mem_newtonSupport_iff (f : MvPolynomial σ R) (m : σ →₀ ℕ) :
    m ∈ NewtonSupport f ↔ MvPolynomial.coeff m f ≠ 0 := Iff.rfl

theorem mem_newtonSupportFinset_iff (f : MvPolynomial σ R) (m : σ →₀ ℕ) :
    m ∈ NewtonSupportFinset f ↔ MvPolynomial.coeff m f ≠ 0 := by
  simp [NewtonSupportFinset, MvPolynomial.mem_support_iff]

theorem newtonSupport_eq_coe (f : MvPolynomial σ R) :
    NewtonSupport f = ↑(NewtonSupportFinset f) := by
  ext m; simp [NewtonSupport, NewtonSupportFinset, MvPolynomial.mem_support_iff]

/-! ## Quadratic Shadow -/

/-- The **quadratic shadow** of a set of exponent vectors: all vectors obtainable
by subtracting two unit basis vectors eᵢ, eⱼ from some element of S.
Formally, β ∈ Sh₂(S) iff ∃ α ∈ S, ∃ i j, α = β + eᵢ + eⱼ. -/
def QuadraticShadow (S : Set (σ →₀ ℕ)) : Set (σ →₀ ℕ) :=
  {β | ∃ α ∈ S, ∃ i j : σ, α = β + Finsupp.single i 1 + Finsupp.single j 1}

theorem mem_quadraticShadow_iff (S : Set (σ →₀ ℕ)) (β : σ →₀ ℕ) :
    β ∈ QuadraticShadow S ↔
    ∃ α ∈ S, ∃ i j : σ, α = β + Finsupp.single i 1 + Finsupp.single j 1 :=
  Iff.rfl

/-! ## Computable Quadratic Shadow on Finsets -/

/-- Computable quadratic shadow from a finset of support vectors.
For each α ∈ S and each pair (i, j) of variables from the universe,
compute α - eᵢ - eⱼ when the subtraction is valid (i.e., α(i) ≥ 1 and
(α - eᵢ)(j) ≥ 1). -/
def computeQuadShadow [Fintype σ] (S : Finset (σ →₀ ℕ)) : Finset (σ →₀ ℕ) :=
  S.biUnion fun α =>
    (Finset.univ : Finset σ).biUnion fun i =>
      (Finset.univ : Finset σ).biUnion fun j =>
        let α' : σ →₀ ℕ := α - Finsupp.single i 1
        if α i ≥ 1 ∧ α' j ≥ 1
        then {α' - Finsupp.single j 1}
        else ∅

/-! ## Nonzero Quadratic Leaf Set -/

/-- The set of exponent vectors β that appear with nonzero coefficient in some
second partial derivative ∂ᵢ∂ⱼf. -/
def NonzeroQuadLeafSet (f : MvPolynomial σ R) : Set (σ →₀ ℕ) :=
  {β | ∃ i j : σ, MvPolynomial.coeff β (MvPolynomial.pderiv i (MvPolynomial.pderiv j f)) ≠ 0}

/-! ## Coefficient Formulas for Partial Derivatives -/

/-
**Coefficient transport for a single derivative.**
The coefficient of m in ∂ᵢf equals (m(i) + 1) times the coefficient
of m + eᵢ in f.
-/
theorem coeff_pderiv_single (i : σ) (f : MvPolynomial σ R) (m : σ →₀ ℕ) :
    MvPolynomial.coeff m (MvPolynomial.pderiv i f) =
    MvPolynomial.coeff (m + Finsupp.single i 1) f * (↑(m i + 1) : R) := by
  convert MvPolynomial.coeff_map ( f := ( algebraMap R ( R ) ) ) ( m := m ) _ using 1;
  convert MvPolynomial.coeff_map ( f := ( algebraMap R R ) ) ( m := m ) _ using 1;
  any_goals exact ∑ s ∈ f.support, MvPolynomial.monomial ( s - Finsupp.single i 1 ) ( f.coeff s * s i );
  · convert MvPolynomial.coeff_map ( f := ( algebraMap R R ) ) ( m := m ) _ using 1;
    simp +decide [ MvPolynomial.pderiv_def, MvPolynomial.eval₂_sum ];
    simp +decide [ mkDerivation, Finsupp.prod ];
    simp +decide [ mkDerivationₗ, Finsupp.prod ];
    simp +decide [ lsum, Finsupp.sum ];
    simp +decide [ Pi.single_apply, mul_comm ];
    exact congr_arg _ ( Finset.sum_congr rfl fun x hx => by aesop );
  · simp +decide [ MvPolynomial.coeff_sum, MvPolynomial.coeff_monomial ];
    rw [ Finset.sum_eq_single ( m + Finsupp.single i 1 ) ] <;> simp +contextual [ Finsupp.ext_iff ];
    intro b hb x hx h; specialize h x; simp_all +decide [ Finsupp.single_apply ] ;
    split_ifs at * <;> simp_all +decide [ Nat.sub_eq_iff_eq_add ];
    cases n : b x <;> simp_all +decide [ Nat.sub_eq_iff_eq_add ];
    simp +decide [ ← h ]

/-
**Coefficient transport for double derivative.**
coeff β (∂ⱼ(∂ᵢf)) = coeff(β + eⱼ + eᵢ, f) · ((β + eⱼ)(i) + 1) · (β(j) + 1)
-/
theorem coeff_pderiv_pderiv (i j : σ) (f : MvPolynomial σ R) (β : σ →₀ ℕ) :
    MvPolynomial.coeff β (MvPolynomial.pderiv j (MvPolynomial.pderiv i f)) =
    MvPolynomial.coeff (β + Finsupp.single j 1 + Finsupp.single i 1) f *
      (↑((β + Finsupp.single j 1 : σ →₀ ℕ) i + 1) : R) * (↑(β j + 1) : R) := by
  convert coeff_pderiv_single j ( MvPolynomial.pderiv i f ) β using 1 ; ring!;
  rw [ coeff_pderiv_single ] ; ring!;

/-! ## The Fundamental Equivalence -/

/-
**Key vanishing criterion.** In a domain of characteristic zero,
the coefficient of β in ∂ⱼ(∂ᵢf) is nonzero iff the ancestor coefficient
at β + eⱼ + eᵢ is nonzero.
-/
theorem coeff_pderiv_pderiv_ne_zero_iff [NoZeroDivisors R] [CharZero R]
    (i j : σ) (f : MvPolynomial σ R) (β : σ →₀ ℕ) :
    MvPolynomial.coeff β (MvPolynomial.pderiv j (MvPolynomial.pderiv i f)) ≠ 0 ↔
    MvPolynomial.coeff (β + Finsupp.single j 1 + Finsupp.single i 1) f ≠ 0 := by
  rw [ coeff_pderiv_pderiv, mul_comm ];
  by_cases h : coeff ( ( β + Finsupp.single j 1 ) + Finsupp.single i 1 ) f = 0 <;> simp_all +decide;
  norm_cast

/-! ## Main Theorems -/

/-
**Theorem 1: Quadratic shadow containment.**
Every nonzero quadratic derivative leaf lies in the quadratic shadow.
-/
theorem nonzeroQuadLeafSet_subset_shadow [NoZeroDivisors R] [CharZero R]
    (f : MvPolynomial σ R) :
    NonzeroQuadLeafSet f ⊆ QuadraticShadow (NewtonSupport f) := by
  -- By definition of quadratic shadow, if β is in the quadratic shadow, then there exists an α in the support of f such that β = α - e_i - e_j for some i and j.
  intro β hβ
  obtain ⟨i, j, h_coeff⟩ := hβ;
  refine' ⟨ β + Finsupp.single i 1 + Finsupp.single j 1, _, _ ⟩ <;> simp_all +decide [ NewtonSupport ]
  · exact (coeff_pderiv_pderiv_ne_zero_iff j i f β).mp h_coeff
  · exact ⟨ i, j, rfl ⟩

/-
**Theorem 1': Reverse containment.**
Every point in the quadratic shadow is a nonzero quadratic derivative leaf.
-/
theorem shadow_subset_nonzeroQuadLeafSet [NoZeroDivisors R] [CharZero R]
    (f : MvPolynomial σ R) :
    QuadraticShadow (NewtonSupport f) ⊆ NonzeroQuadLeafSet f := by
  rintro β ⟨ α, hα, i, j, rfl ⟩;
  refine' ⟨ i, j, _ ⟩;
  convert coeff_pderiv_pderiv_ne_zero_iff j i f β |>.2 hα using 1

/-- **Theorem 2: The fundamental equality.**
The nonzero quadratic leaf set equals the quadratic shadow of the Newton support.
Cancellation never occurs for individual ∂ᵢ∂ⱼ because each output coefficient
is a nonzero scalar multiple of exactly one input coefficient. -/
theorem nonzeroQuadLeafSet_eq_shadow [NoZeroDivisors R] [CharZero R]
    (f : MvPolynomial σ R) :
    NonzeroQuadLeafSet f = QuadraticShadow (NewtonSupport f) :=
  Set.Subset.antisymm (nonzeroQuadLeafSet_subset_shadow f)
    (shadow_subset_nonzeroQuadLeafSet f)

/-! ## Algorithm Correctness -/

/-
**Theorem 3: Membership characterization of the computed shadow.**
-/
theorem mem_computeQuadShadow_iff [Fintype σ]
    (S : Finset (σ →₀ ℕ)) (β : σ →₀ ℕ) :
    β ∈ computeQuadShadow S ↔
    ∃ α ∈ S, ∃ i j : σ,
      α i ≥ 1 ∧ (α - Finsupp.single i 1 : σ →₀ ℕ) j ≥ 1 ∧
      β = (α - Finsupp.single i 1 : σ →₀ ℕ) - Finsupp.single j 1 := by
  simp +decide only [computeQuadShadow, Finset.mem_biUnion];
  grind

/-! ## Monotonicity -/

/-
The quadratic shadow is monotone under set inclusion.
-/
omit [DecidableEq σ] in
theorem quadShadow_mono {S₁ S₂ : Set (σ →₀ ℕ)} (h : S₁ ⊆ S₂) :
    QuadraticShadow S₁ ⊆ QuadraticShadow S₂ := by
  exact fun x hx => by obtain ⟨ y, hyS₁, hy ⟩ := hx; exact ⟨ y, h hyS₁, hy ⟩ ;

/-
The computable quadratic shadow is monotone under finset inclusion.
-/
theorem computeQuadShadow_mono [Fintype σ] {S₁ S₂ : Finset (σ →₀ ℕ)}
    (h : S₁ ⊆ S₂) :
    computeQuadShadow S₁ ⊆ computeQuadShadow S₂ := by
  grind +locals

/-! ## Positive Coefficients Corollary -/

/-- For polynomials over a linearly ordered semiring with positive coefficients,
the quadratic leaf set equals the shadow. This is a corollary of the stronger
`nonzeroQuadLeafSet_eq_shadow`, stated separately to highlight the connection
to the Lorentzian/positive-coefficient world. -/
theorem nonzeroQuadLeafSet_eq_shadow_of_posCoeffs
    [NoZeroDivisors R] [CharZero R]
    (f : MvPolynomial σ R) :
    NonzeroQuadLeafSet f = QuadraticShadow (NewtonSupport f) :=
  nonzeroQuadLeafSet_eq_shadow f

end WeightedSupportShadow