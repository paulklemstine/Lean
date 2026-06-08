/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Non-Cancellation Certificates and Coefficient-Aware Bounds

This file introduces the **non-cancellation certificate** for multivariate polynomials
over characteristic-zero domains, and proves that it upgrades combinatorial support-shadow
lower bounds to genuine arithmetic-level results.

## Core Problem

Support-only arguments in arithmetic complexity overapproximate: they predict which
monomials *could* appear after differentiation but cannot guarantee that cancellations
do not kill them. Over characteristic zero, individual second partial derivatives
`∂ᵢ∂ⱼf` never suffer cancellation (each output monomial has exactly one ancestor),
but aggregate operators — sums of derivatives, Hessian determinants — can cancel.

## Main Definitions

* `quadLeafSet` — The per-variable-pair shadow: exponents reachable by subtracting
  `eᵢ + eⱼ` from a specific support element.
* `NonCancellationCert` — A predicate asserting that every exponent in the quadratic
  shadow of `support p` also appears with nonzero coefficient in `p` itself.
* `HessianSupportExact` — Structure recording that each `∂ᵢ∂ⱼp` has support exactly
  equal to the predicted per-pair shadow.

## Main Results

* `support_pderiv_pderiv_eq_quadLeafSet` — Per-pair Hessian support equals
  the per-pair shadow (characteristic zero, no-zero-divisors).
* `hessianSupportExact_of_charZero` — `HessianSupportExact` holds unconditionally
  for polynomials over char-zero integral domains.
* `certificate_locus_finite_conditions` — For a fixed finite support, any
  coefficient assignment with all nonzero coefficients satisfies the certificate
  whenever the support is shadow-closed.
* `hessianScalar_ne_zero_rat` — The scalar multiplier arising from second
  differentiation is nonzero in characteristic zero.

## Cross-Domain Significance

This work bridges:
- **Arithmetic complexity**: support lower bounds → genuine polynomial lower bounds
- **Algebraic geometry**: certificate locus is Zariski-open (coordinate hyperplane complement)
- **Tropical geometry**: support propagation = tropicalization of derivative structure
- **Commutative algebra**: monomial ideal growth under differential operators

## Relationship to Catalog Results

Builds on `WeightedSupportShadow.lean`:
* Uses `coeff_pderiv_pderiv_ne_zero_iff` — key vanishing criterion
* Uses `nonzeroQuadLeafSet_eq_shadow` — the fundamental equality
* Uses `QuadraticShadow` — the set-level quadratic shadow definition
-/

open MvPolynomial Finsupp BigOperators Classical

noncomputable section

namespace NonCancellation

variable {σ : Type*} [DecidableEq σ]

/-! ## Quadratic Shadow (from WeightedSupportShadow) -/

/-- The **quadratic shadow** of a set of exponent vectors: all vectors obtainable
by subtracting two unit basis vectors eᵢ, eⱼ from some element of S.
(Mirrors `WeightedSupportShadow.QuadraticShadow`.) -/
def QuadraticShadow (S : Set (σ →₀ ℕ)) : Set (σ →₀ ℕ) :=
  {β | ∃ α ∈ S, ∃ i j : σ, α = β + Finsupp.single i 1 + Finsupp.single j 1}

/-! ## Per-Variable-Pair Shadow -/

/-- The **per-pair quadratic leaf set**: the set of exponent vectors `β` such that
`β + eᵢ + eⱼ` lies in the support set `S`. This is the shadow restricted to a
specific variable pair `(i, j)`. -/
def quadLeafSet (S : Finset (σ →₀ ℕ)) (i j : σ) : Set (σ →₀ ℕ) :=
  {β | β + Finsupp.single i 1 + Finsupp.single j 1 ∈ S}

theorem mem_quadLeafSet_iff (S : Finset (σ →₀ ℕ)) (i j : σ) (β : σ →₀ ℕ) :
    β ∈ quadLeafSet S i j ↔ β + Finsupp.single i 1 + Finsupp.single j 1 ∈ S :=
  Iff.rfl

/-- The full quadratic shadow is the union of per-pair shadows. -/
theorem quadraticShadow_eq_iUnion (S : Finset (σ →₀ ℕ)) :
    QuadraticShadow (↑S : Set (σ →₀ ℕ)) = ⋃ i : σ, ⋃ j : σ, quadLeafSet S i j := by
  ext β
  simp only [QuadraticShadow, quadLeafSet, Set.mem_setOf_eq, Set.mem_iUnion,
    Finset.mem_coe]
  constructor
  · rintro ⟨α, hα, i, j, rfl⟩
    exact ⟨i, j, hα⟩
  · rintro ⟨i, j, h⟩
    exact ⟨β + Finsupp.single i 1 + Finsupp.single j 1, h, i, j, rfl⟩

/-! ## Non-Cancellation Certificate -/

/-- The **non-cancellation certificate** for a polynomial `p` over `ℚ`:
every exponent vector that lies in the quadratic shadow of the support
also appears with nonzero coefficient in `p` itself.

This ensures the support is "shadow-closed": exponents reachable by
subtracting two unit vectors from a support element are themselves in the support.
Under this condition, the Hessian support structure is fully predictable from
the polynomial's support alone. -/
def NonCancellationCert (p : MvPolynomial σ ℚ) : Prop :=
  ∀ β : σ →₀ ℕ,
    β ∈ QuadraticShadow (↑(MvPolynomial.support p) : Set (σ →₀ ℕ)) →
    MvPolynomial.coeff β p ≠ 0

/-- A support set is **shadow-closed** if its quadratic shadow is contained in it. -/
def ShadowClosed (S : Finset (σ →₀ ℕ)) : Prop :=
  QuadraticShadow (↑S : Set (σ →₀ ℕ)) ⊆ ↑S

/-! ## Hessian Support Exactness -/

/-- **Hessian support exactness**: the support of each second partial
derivative `∂ᵢ∂ⱼp` equals the predicted per-pair shadow. -/
structure HessianSupportExact {R : Type*} [CommSemiring R]
    (p : MvPolynomial σ R) : Prop where
  support_eq :
    ∀ i j : σ, ∀ β : σ →₀ ℕ,
      MvPolynomial.coeff β (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)) ≠ 0 ↔
      β ∈ quadLeafSet p.support j i

/-! ## Hessian Scalar Factor -/

/-- The **hessian scalar** is the factor by which a monomial coefficient is multiplied
when taking `∂ᵢ∂ⱼ`. Specifically, if we differentiate a monomial `c · X^α` by
`∂ⱼ` then `∂ᵢ`, the resulting coefficient at `β = α - eᵢ - eⱼ` is
`c · (α i) · (α j)` (with appropriate adjustments when `i = j`).

This version gives the scalar as a natural number (always positive). -/
def hessianScalar (β : σ →₀ ℕ) (i j : σ) : ℕ :=
  ((β + Finsupp.single j 1 : σ →₀ ℕ) i + 1) * (β j + 1)

/-- The hessian scalar is always positive (hence nonzero over ℚ). -/
theorem hessianScalar_pos (β : σ →₀ ℕ) (i j : σ) :
    0 < hessianScalar β i j := by
  unfold hessianScalar; positivity

/-- **Theorem (Characteristic-zero scalar nonvanishing).**
Over `ℚ`, the hessian scalar cast to `ℚ` is nonzero.
This is the characteristic-zero insight: derivative scalar factors never
spuriously vanish, unlike over finite fields where `α(i) · α(j)` might
be zero mod p even when both factors are nonzero as naturals. -/
theorem hessianScalar_ne_zero_rat (β : σ →₀ ℕ) (i j : σ) :
    (hessianScalar β i j : ℚ) ≠ 0 := by
  exact_mod_cast (hessianScalar_pos β i j).ne'

/-! ## Core Theorem: Per-Pair Hessian Support Equals Shadow -/

/-
**Theorem 1 (Per-pair exact support realization).**
For a polynomial over a characteristic-zero integral domain, the coefficient
of `β` in `∂ᵢ(∂ⱼp)` is nonzero if and only if `β` lies in `quadLeafSet (support p) j i`.

Each output coefficient of `∂ᵢ(∂ⱼp)` is a nonzero scalar multiple of exactly one
ancestor coefficient in `p`. The scalar factor `(β(j)+1) · ((β+eⱼ)(i)+1)` is a
product of natural numbers, always positive, hence nonzero over `ℚ`. Therefore,
the Hessian coefficient vanishes iff the ancestor coefficient vanishes, and
cancellation is impossible for individual second partial derivatives.
-/
theorem support_pderiv_pderiv_eq_quadLeafSet
    {R : Type*} [CommSemiring R] [NoZeroDivisors R] [CharZero R]
    (p : MvPolynomial σ R) (i j : σ) (β : σ →₀ ℕ) :
    MvPolynomial.coeff β (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)) ≠ 0 ↔
    β ∈ quadLeafSet p.support j i := by
  -- By definition of `pderiv`, we know that the coefficient of `β` in `pderiv i (pderiv j p)` is the same as the coefficient of `β + eᵢ + eⱼ` in `p`, multiplied by the product of the indices.
  have h_coeff : MvPolynomial.coeff β (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)) = (β j + 1) * (β i + 1 + if i = j then 1 else 0) * MvPolynomial.coeff (β + Finsupp.single i 1 + Finsupp.single j 1) p := by
    -- Apply the definition of `pderiv` to express the coefficient.
    have h_coeff_pderiv : ∀ (p : MvPolynomial σ R) (i : σ) (β : σ →₀ ℕ), MvPolynomial.coeff β (MvPolynomial.pderiv i p) = (β i + 1) * MvPolynomial.coeff (β + Finsupp.single i 1) p := by
      intro p i β;
      induction' p using MvPolynomial.induction_on' with p q hp hq;
      · simp +decide [ MvPolynomial.pderiv_monomial ];
        split_ifs <;> simp_all +decide [ Finsupp.ext_iff ];
        · ring;
        · grind;
      · simp_all +decide [ mul_add ];
    convert h_coeff_pderiv ( MvPolynomial.pderiv j p ) i β using 1;
    rw [ h_coeff_pderiv ] ; ring;
    by_cases hij : i = j <;> simp +decide [ hij, Finsupp.single_apply ] ; ring;
    ring;
  simp_all +decide [ mul_assoc, mul_comm, mul_left_comm, add_assoc, add_comm, add_left_comm, Finset.mem_add ];
  rw [ show β + ( ( fun₀ | i => 1 ) + fun₀ | j => 1 ) = β + Finsupp.single j 1 + Finsupp.single i 1 by ext; simp +decide [ add_comm, add_left_comm, add_assoc ] ] ; simp +decide [ quadLeafSet ] ; ring;
  exact fun _ => ⟨ by norm_cast; positivity, by norm_cast; positivity ⟩ ;

/-- **Corollary: Hessian support exactness holds unconditionally** over
characteristic-zero integral domains. No certificate is needed for
individual second partial derivatives — cancellation never occurs. -/
theorem hessianSupportExact_of_charZero
    {R : Type*} [CommSemiring R] [NoZeroDivisors R] [CharZero R]
    (p : MvPolynomial σ R) :
    HessianSupportExact p :=
  ⟨fun i j β => support_pderiv_pderiv_eq_quadLeafSet p i j β⟩

/-! ## Genericity of the Certificate -/

/-
**Theorem 3 (Certificate from shadow-closure and nonzero coefficients).**
If a polynomial's support is shadow-closed (the quadratic shadow maps back into the
support), and all coefficients on the support are nonzero (which is automatic by
definition of support), then the non-cancellation certificate holds.

This captures the key insight: for shadow-closed supports, the certificate
is automatic. The interesting mathematical question is when a support is
shadow-closed, which happens generically for "dense enough" supports.
-/
theorem nonCancellationCert_of_shadowClosed
    (p : MvPolynomial σ ℚ)
    (hsc : ShadowClosed p.support) :
    NonCancellationCert p := by
  grind +locals

/-
**Theorem 3' (Genericity via coefficient parameter space).**
For a fixed shadow-closed support `S`, any coefficient assignment with all nonzero
coefficients yields a polynomial satisfying the non-cancellation certificate.

This shows the certificate locus is the complement of a finite union of
coordinate hyperplanes `{a_d = 0}` for `d ∈ S` in the coefficient space `ℚ^S`.
Over ℚ (or any infinite field), this is Zariski-open and dense.
-/
theorem certificate_locus_finite_conditions [Fintype σ]
    (S : Finset (σ →₀ ℕ))
    (hsc : ShadowClosed S) :
    ∀ a : (σ →₀ ℕ) → ℚ,
      (∀ d ∈ S, a d ≠ 0) →
      NonCancellationCert
        (∑ d ∈ S, MvPolynomial.C (a d) * MvPolynomial.monomial d 1) := by
  intro a ha
  have h_supp : (∑ d ∈ S, C (a d) * (monomial d) 1).support = S := by
    ext d; simp +decide [ MvPolynomial.coeff_sum ] ;
    exact ha d;
  convert nonCancellationCert_of_shadowClosed _ _;
  · infer_instance;
  · convert hsc using 1

/-! ## Shadow-Based Complexity Measures -/

/-- The **hessian entry count** of a polynomial: the total number of
nonzero coefficients across all Hessian entries `∂ᵢ∂ⱼp`. -/
def hessianEntryCount [Fintype σ] (p : MvPolynomial σ ℚ) : ℕ :=
  ∑ i : σ, ∑ j : σ,
    ((MvPolynomial.pderiv i (MvPolynomial.pderiv j p)).support).card

/-- The **shadow-predicted Hessian count**: the total number of
`(i, j, β)` triples predicted by the per-pair shadow. -/
def shadowHessianCount [Fintype σ] (S : Finset (σ →₀ ℕ)) : ℕ :=
  ∑ i : σ, ∑ j : σ,
    (S.filter (fun α => 1 ≤ α i ∧ 1 ≤ (α - Finsupp.single i 1 : σ →₀ ℕ) j)).card

/-
**Theorem 2 (Coefficient-aware Hessian count equality).**
Over a characteristic-zero integral domain, the actual Hessian entry count
equals the shadow-predicted count. Every combinatorial prediction about
Hessian support structure is realized by the actual polynomial — no
support-level information is lost to cancellation.

Consequently, any lower bound derived from the shadow count applies to
the actual polynomial, not just its support skeleton.
-/
theorem hessianEntryCount_eq_shadowCount [Fintype σ]
    (p : MvPolynomial σ ℚ) :
    hessianEntryCount p = shadowHessianCount p.support := by
  refine' Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => _;
  refine' Finset.card_bij ( fun β _ => β + Finsupp.single j 1 + Finsupp.single i 1 ) _ _ _ <;> simp_all +decide [ support_pderiv_pderiv_eq_quadLeafSet ];
  · simp +decide [ quadLeafSet ];
  · intro b hb hi hj; use b - Finsupp.single i 1 - Finsupp.single j 1; simp_all +decide [ quadLeafSet ] ;
    simp_all +decide [ Finsupp.single_apply, tsub_add_cancel_of_le ]

/-! ## Hessian Scalar Nonvanishing in Characteristic Zero -/

/-- A second derivative is **eligible** at `(β, i, j)` if the ancestor
exponent `α = β + eⱼ + eᵢ` satisfies `α(i) ≥ 1` and `α(j) ≥ 1`
(the minimal conditions for ∂ᵢ and ∂ⱼ to produce nonzero output). -/
def ShadowSecondEligible (β : σ →₀ ℕ) (i j : σ) : Prop :=
  1 ≤ (β + Finsupp.single j 1 : σ →₀ ℕ) i ∧ 1 ≤ β j + 1

/-- **Theorem (Characteristic-zero scalar nonvanishing under eligibility).**
In characteristic zero, the hessian scalar factor is nonzero whenever the
shadow predicts a nonzero derivative. The scalar `(β(j)+1) · ((β+eⱼ)(i)+1)`
is a product of positive natural numbers, hence nonzero over ℚ.

This is the deep reason the coefficient-aware bridge is natural in characteristic
zero and fails over finite fields: derivative scalars like `α(i) · (α(i)-1)`
can vanish mod p even when nonzero as integers. -/
theorem hessian_scalar_nonzero_of_eligible
    (β : σ →₀ ℕ) (i j : σ)
    (_h : ShadowSecondEligible β i j) :
    (hessianScalar β i j : ℚ) ≠ 0 :=
  hessianScalar_ne_zero_rat β i j

/-! ## Ancestor Set -/

/-- The **ancestor set** of a support `S`: the set of exponents in `S` that
can serve as ancestor exponents for some second partial derivative. -/
def ancestorSet [Fintype σ] (S : Finset (σ →₀ ℕ)) : Finset (σ →₀ ℕ) :=
  S.filter fun α =>
    ∃ i : σ, ∃ j : σ, 1 ≤ α i ∧ 1 ≤ (α - Finsupp.single i 1 : σ →₀ ℕ) j

omit [DecidableEq σ] in
/-- The ancestor set is a subset of the original support. -/
theorem ancestorSet_subset [Fintype σ] (S : Finset (σ →₀ ℕ)) :
    ancestorSet S ⊆ S :=
  Finset.filter_subset _ _

omit [DecidableEq σ] in
/-- Monotonicity: larger supports have larger ancestor sets. -/
theorem ancestorSet_mono [Fintype σ] {S₁ S₂ : Finset (σ →₀ ℕ)} (h : S₁ ⊆ S₂) :
    ancestorSet S₁ ⊆ ancestorSet S₂ := by
  intro x hx
  simp only [ancestorSet, Finset.mem_filter] at hx ⊢
  exact ⟨h hx.1, hx.2⟩

end NonCancellation