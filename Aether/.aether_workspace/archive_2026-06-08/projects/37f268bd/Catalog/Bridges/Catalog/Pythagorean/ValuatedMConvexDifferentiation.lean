/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Valuated M-Convexity and Coefficient Transport under Differentiation

This file builds the first bridge from **support-level M-convex exchange** to
**coefficient-level quantitative exchange**, and proves that core structural
properties survive partial differentiation via the coefficient transport identity.

## Mathematical Context

The support exchange theorem (Murota, 2003) captures **where** monomials live:
for any `a, b` in an M-convex support with `a i > b i`, there exists `j` with
`a j < b j` such that `a - eᵢ + eⱼ` is also in the support.

We introduce a **valuated** (quantitative) exchange property that additionally
captures **how** the coefficients are allowed to move: the four-point inequality
`coeff(a) · coeff(b) ≤ K · coeff(a') · coeff(b')` on exchange squares.

## Key Definitions

* `ValuatedExchange` — Multiplicative four-point exchange inequality on coefficients
* `exchDown` / `exchUp` — Elementary exchange operations on exponent vectors

## Main Results

1. `coeff_pderiv_transport` — The coefficient identity
   `(∂ᵢ p).coeff m = (m i + 1) • p.coeff(m + eᵢ)`.

2. `coeff_pderiv_nonneg` — Nonnegativity of coefficients preserved by `pderiv`.

3. `valuatedExchange_logConcave_on_ray` — Cross-domain bridge: valuated exchange
   implies a local log-concavity inequality along exchange directions, connecting
   discrete convex analysis to Lorentzian polynomial geometry.

4. `pderiv_coeff_product_eq` — The derivative coefficient product factorization.

5. `valuatedExchange_of_linear_nonneg` — Valuated exchange for linear polynomials
   with nonneg coefficients, applicable to derivatives of the U(2,3) case.

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open MvPolynomial Finsupp BigOperators

noncomputable section

namespace ValuatedMConvex

variable {σ : Type*} [DecidableEq σ]

/-! ## Section 1: Exchange Operations -/

/-- Elementary down-exchange on exponent vectors: decrease coordinate `i`, increase `j`. -/
def exchDown (a : σ →₀ ℕ) (i j : σ) : σ →₀ ℕ :=
  a - Finsupp.single i 1 + Finsupp.single j 1

/-- Elementary up-exchange on exponent vectors: increase coordinate `i`, decrease `j`. -/
def exchUp (b : σ →₀ ℕ) (i j : σ) : σ →₀ ℕ :=
  b + Finsupp.single i 1 - Finsupp.single j 1

/-! ## Section 2: Core Definition -/

/-- **Valuated Exchange Property.** A polynomial `p` satisfies valuated exchange
with constant `K` if for every pair of support exponents `a, b` with `b i < a i`,
there exists a witness `j` such that:
- `a j < b j` (exchange direction),
- the exchanged exponents `a - eᵢ + eⱼ` and `b + eᵢ - eⱼ` are in the support,
- the four-point coefficient inequality holds:
  `coeff(a) · coeff(b) ≤ K · coeff(a - eᵢ + eⱼ) · coeff(b + eᵢ - eⱼ)`. -/
def ValuatedExchange
    {R : Type*} [CommRing R] [LinearOrder R] [IsStrictOrderedRing R]
    (p : MvPolynomial σ R) (K : R) : Prop :=
  ∀ ⦃a b : σ →₀ ℕ⦄, a ∈ p.support →
    b ∈ p.support →
    ∀ ⦃i : σ⦄, b i < a i →
    ∃ j : σ,
      a j < b j ∧
      exchDown a i j ∈ p.support ∧
      exchUp b i j ∈ p.support ∧
      p.coeff a * p.coeff b ≤
        K * (p.coeff (exchDown a i j) * p.coeff (exchUp b i j))

/-! ## Theorem 1: Coefficient Transport Identity -/

/-
**Coefficient transport identity.** The coefficient of exponent `m` in the
partial derivative `∂ᵢ p` equals `(m i + 1)` times the coefficient of `m + eᵢ`
in `p`. This is the fundamental building block for transporting exchange
inequalities through differentiation.
-/
theorem coeff_pderiv_transport
    {R : Type*} [CommSemiring R]
    (p : MvPolynomial σ R) (i : σ) (m : σ →₀ ℕ) :
    (pderiv i p).coeff m = (m i + 1) • p.coeff (m + Finsupp.single i 1) := by
  have h_coeff_sum : (MvPolynomial.pderiv i p).coeff m = ∑ s ∈ p.support, (MvPolynomial.pderiv i (MvPolynomial.monomial s (p.coeff s))).coeff m := by
    have h_coeff_sum : (MvPolynomial.pderiv i p) = ∑ s ∈ p.support, MvPolynomial.pderiv i (MvPolynomial.monomial s (p.coeff s)) := by
      conv_lhs => rw [ MvPolynomial.as_sum p ];
      rw [ map_sum ];
    rw [ h_coeff_sum, MvPolynomial.coeff_sum ];
  simp_all +decide [ MvPolynomial.pderiv_monomial, MvPolynomial.coeff_monomial ];
  rw [ Finset.sum_eq_single ( m + Finsupp.single i 1 ) ];
  · simp +decide [ mul_comm, Finsupp.single_apply ];
  · intro b hb hne; contrapose! hne; simp_all +decide [ sub_eq_iff_eq_add ] ;
    rw [ ← hne.1, tsub_add_cancel_of_le ];
    intro j; by_cases hj : j = i <;> simp_all +decide [ Finsupp.single_apply ] ;
    exact Nat.pos_of_ne_zero fun h => hne.2 <| by simp +decide [ h ] ;
  · aesop

/-! ## Theorem 2: Nonnegativity Preservation -/

/-
**Nonnegativity preservation under differentiation.** If every coefficient of `p`
is nonnegative, then every coefficient of `∂ᵢ p` is nonnegative. This follows from
the transport identity: `(∂ᵢ p).coeff m = (m i + 1) · p.coeff(m + eᵢ)` is a
nonneg scalar multiple of a nonneg coefficient.
-/
theorem coeff_pderiv_nonneg
    {R : Type*} [CommRing R] [LinearOrder R] [IsStrictOrderedRing R]
    (p : MvPolynomial σ R) (i : σ)
    (h_nonneg : ∀ m, 0 ≤ p.coeff m)
    (m : σ →₀ ℕ) :
    0 ≤ (pderiv i p).coeff m := by
  rw [ coeff_pderiv_transport ];
  convert nsmul_nonneg ( h_nonneg _ ) _

/-! ## Theorem 3: Derivative Coefficient Product Factorization -/

/-
**Derivative coefficient product identity.** For any polynomial `p` and
variable `v`, the product of two derivative coefficients factors through the
transport identity:
  `(∂ᵥ p).coeff a · (∂ᵥ p).coeff b =
    (a v + 1)(b v + 1) • (p.coeff(a+eᵥ) · p.coeff(b+eᵥ))`.

This factorization is the engine that converts an exchange inequality for `p`
into an exchange inequality for `∂ᵥ p` with explicit rescaling.
-/
theorem pderiv_coeff_product_eq
    {R : Type*} [CommSemiring R]
    (p : MvPolynomial σ R) (v : σ) (a b : σ →₀ ℕ) :
    (pderiv v p).coeff a * (pderiv v p).coeff b =
      ((a v + 1) * (b v + 1)) • (p.coeff (a + Finsupp.single v 1) *
                                   p.coeff (b + Finsupp.single v 1)) := by
  convert congr_arg₂ ( · * · ) ( coeff_pderiv_transport p v a ) ( coeff_pderiv_transport p v b ) using 1 ; ring

/-! ## Theorem 4: Cross-Domain Bridge — Log-Concavity from Exchange

The valuated exchange property implies local log-concavity along exchange rays.

Consider the two endpoints `a := m + eᵢ - eⱼ` and `b := m - eᵢ + eⱼ` of a
two-step exchange ray through `m`. If both are in the support with `a i > b i`,
and the exchange axiom produces witness `j` such that `exchDown a i j = m` and
`exchUp b i j = m`, then:

  `coeff(m + eᵢ - eⱼ) · coeff(m - eᵢ + eⱼ) ≤ K · coeff(m)²`

This is the log-concavity condition at interior point `m` along direction `eᵢ - eⱼ`.
It connects the M-convex exchange axiom from discrete convex analysis to the
coefficient log-concavity central to Lorentzian polynomial theory (Brändén–Huh). -/

theorem valuatedExchange_logConcave_on_ray
    {R : Type*} [CommRing R] [LinearOrder R] [IsStrictOrderedRing R]
    (p : MvPolynomial σ R) (K : R)
    (hVE : ValuatedExchange p K)
    (a b : σ →₀ ℕ) (i j : σ) (hij : i ≠ j)
    (ha_supp : a ∈ p.support)
    (hb_supp : b ∈ p.support)
    -- Coordinate conditions: b i < a i
    (h_ai_gt_bi : b i < a i)
    -- The exchange witness j satisfies a j < b j
    (h_aj_lt_bj : a j < b j)
    -- Exchanging gives back a common center point c = exchDown a i j = exchUp b i j
    (c : σ →₀ ℕ)
    (h_exchDown_eq : exchDown a i j = c)
    (h_exchUp_eq : exchUp b i j = c)
    :
    p.coeff a * p.coeff b ≤ K * (p.coeff c * p.coeff c) := by
  unfold exchDown exchUp at *;
  convert hVE ha_supp hb_supp h_ai_gt_bi using 1;
  constructor <;> intro h;
  · exact hVE ha_supp hb_supp h_ai_gt_bi;
  · obtain ⟨ j', hj₁, hj₂, hj₃, hj₄ ⟩ := h;
    by_cases hj'_eq_j : j' = j;
    · unfold exchDown exchUp at * ; aesop;
    · replace h_exchDown_eq := congr_arg ( fun x => x j' ) h_exchDown_eq ; replace h_exchUp_eq := congr_arg ( fun x => x j' ) h_exchUp_eq ; simp_all +decide [ Finsupp.single_apply ];
      split_ifs at * <;> omega

/-! ## Theorem 5: Valuated Exchange for Linear Polynomials

For the U(2,3) resolution: partial derivatives of degree-2 homogeneous
polynomials are linear (degree ≤ 1). We prove that any polynomial whose
support consists entirely of standard basis vectors (degree-1 monomials)
and has nonneg coefficients satisfies `ValuatedExchange p 1`.

The key observation: for `a = eₖ₁` and `b = eₖ₂` with `b i < a i`,
we must have `a = eᵢ` (since `a i ≥ 1` and `a` is a unit vector).
The exchange witness is `j = k₂`, and:
- `exchDown(eᵢ, i, k₂) = eₖ₂`
- `exchUp(eₖ₂, i, k₂) = eᵢ`
- The inequality becomes `coeff(eᵢ)·coeff(eₖ₂) ≤ 1·coeff(eₖ₂)·coeff(eᵢ)`. -/

theorem valuatedExchange_of_linear_nonneg
    {R : Type*} [CommRing R] [LinearOrder R] [IsStrictOrderedRing R]
    (p : MvPolynomial σ R)
    (h_nonneg : ∀ m, 0 ≤ p.coeff m)
    (h_linear : ∀ m ∈ p.support, ∃ k : σ, m = Finsupp.single k 1)
    : ValuatedExchange p 1 := by
  intro a b ha hb i hi;
  obtain ⟨ k₁, rfl ⟩ := h_linear a ha; obtain ⟨ k₂, rfl ⟩ := h_linear b hb; simp_all +decide [ Finsupp.single_apply, exchDown, exchUp ] ;
  refine' ⟨ k₂, _, _, _, _ ⟩ <;> split_ifs at hi ⊢ <;> simp_all +decide [ Finsupp.single_apply, Finsupp.sub_apply, Finsupp.add_apply ];
  rw [ mul_comm ]

end ValuatedMConvex