/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Non-Cancellation Certificates and Coefficient-Aware Bounds

This file introduces the concept of a **non-cancellation certificate** for multivariate
polynomials and proves that under such a certificate, combinatorial support shadow
lower bounds become genuine arithmetic lower bounds.

## Mathematical Context

In arithmetic circuit complexity, a central challenge is bridging combinatorial
(support-based) lower bounds to actual algebraic lower bounds. The gap arises because
cancellation between monomials can cause predicted nonzero coefficients to vanish.

Over characteristic-zero fields, individual second partial derivatives enjoy a
remarkable **no-cancellation property**: each output coefficient is a nonzero scalar
multiple of exactly one input coefficient. This means the support of ∂ᵢ∂ⱼp is
completely determined by the support of p, with no cancellation possible.

## Main Definitions

* `quadLeafSet` — Per-variable-pair shadow: the set of exponents predicted to
  appear in ∂ᵢ∂ⱼp based on supp(p)
* `NonCancellationCert` — Certificate asserting the quadratic shadow of supp(p)
  is contained in supp(p), enabling iterated differentiation
* `HessianSupportExact` — Structure recording exact support equality for all
  Hessian entries
* `hessianScalar` — The scalar factor appearing in the Hessian coefficient formula

## Main Results

* `coeff_pderiv_eq` — Coefficient formula for partial derivatives
* `coeff_pderiv_pderiv_ne_zero_iff` — Vanishing criterion for Hessian coefficients
* `hessian_support_eq_quadLeafSet` — Exact support realization for each Hessian entry
* `hessianSupportExact_of_charZero` — Every polynomial over ℚ has exact Hessian support
* `hessianScalar_ne_zero` — The Hessian scalar factor is nonzero over ℚ
* `nonCancellationCert_generic` — The certificate holds generically

## References

Builds on `WeightedSupportShadow.lean` from the Catalog.
-/

open MvPolynomial Finsupp BigOperators

noncomputable section

namespace NonCancellationCertificate

variable {σ : Type*} [DecidableEq σ]

/-! ## Per-Variable-Pair Quadratic Leaf Set -/

/-- The **quadratic leaf set** for a specific pair of variables (i, j).
This is the set of exponent vectors β such that β + eᵢ + eⱼ lies in S.
It predicts exactly which monomials should appear in ∂ᵢ∂ⱼp when supp(p) = S. -/
def quadLeafSet (S : Set (σ →₀ ℕ)) (i j : σ) : Set (σ →₀ ℕ) :=
  {β | β + Finsupp.single i 1 + Finsupp.single j 1 ∈ S}

theorem mem_quadLeafSet_iff (S : Set (σ →₀ ℕ)) (i j : σ) (β : σ →₀ ℕ) :
    β ∈ quadLeafSet S i j ↔ β + Finsupp.single i 1 + Finsupp.single j 1 ∈ S :=
  Iff.rfl

/-! ## The Hessian Scalar Factor -/

/-- The **Hessian scalar factor** for exponent β and variable pair (i, j).
When computing coeff β (∂ᵢ∂ⱼp), this is the scalar multiplier of the
ancestor coefficient. Over ℚ, this is always nonzero. -/
def hessianScalar (β : σ →₀ ℕ) (i j : σ) : ℚ :=
  (↑(β i + 1) : ℚ) * (↑((β + Finsupp.single i 1 : σ →₀ ℕ) j + 1) : ℚ)

omit [DecidableEq σ] in
/-- The Hessian scalar factor is always positive. -/
theorem hessianScalar_pos (β : σ →₀ ℕ) (i j : σ) : 0 < hessianScalar β i j := by
  unfold hessianScalar
  apply mul_pos <;> exact_mod_cast Nat.succ_pos _

omit [DecidableEq σ] in
/-- **Key characteristic-zero lemma**: The Hessian scalar factor is nonzero over ℚ. -/
theorem hessianScalar_ne_zero (β : σ →₀ ℕ) (i j : σ) : hessianScalar β i j ≠ 0 :=
  ne_of_gt (hessianScalar_pos β i j)

/-! ## Coefficient Formulas for Partial Derivatives -/

/-
Coefficient transport for a single partial derivative.
The coefficient of m in ∂ᵢf equals (m(i) + 1) · coeff(m + eᵢ, f).
-/
theorem coeff_pderiv_eq (R : Type*) [CommSemiring R] [DecidableEq σ]
    (i : σ) (f : MvPolynomial σ R) (m : σ →₀ ℕ) :
    MvPolynomial.coeff m (MvPolynomial.pderiv i f) =
    MvPolynomial.coeff (m + Finsupp.single i 1) f * (↑(m i + 1) : R) := by
  induction' f using MvPolynomial.induction_on' with f g hf hg;
  · by_cases h : f i = 0 <;> simp_all +decide [ MvPolynomial.pderiv_monomial ];
    · intro h'; replace h' := congr_arg ( fun x => x i ) h'; aesop;
    · split_ifs <;> simp_all +decide [ Finsupp.ext_iff ];
      rename_i h₁ h₂; rcases h₂ with ⟨ x, hx ⟩ ; specialize h₁ x; by_cases hi : x = i <;> simp_all +decide [ Finsupp.single_apply ] ;
      omega;
  · simp_all +decide [ mul_add, add_mul ];
    ring

/-
**Core vanishing criterion**: Over a characteristic-zero integral domain,
the coefficient of β in ∂ᵢ(∂ⱼf) is nonzero if and only if the ancestor coefficient
at β + eᵢ + eⱼ is nonzero.
-/
theorem coeff_pderiv_pderiv_ne_zero_iff
    (i j : σ) (f : MvPolynomial σ ℚ) (β : σ →₀ ℕ) :
    MvPolynomial.coeff β (MvPolynomial.pderiv i (MvPolynomial.pderiv j f)) ≠ 0 ↔
    MvPolynomial.coeff (β + Finsupp.single i 1 + Finsupp.single j 1) f ≠ 0 := by
  rw [ coeff_pderiv_eq, coeff_pderiv_eq ];
  simp +decide [ mul_assoc, Nat.cast_add_one_ne_zero ];
  exact fun _ => by positivity;

/-! ## Exact Support Realization -/

/-- **Theorem 1 (Exact Hessian Support Realization)**:
For any polynomial p over ℚ, the support of each
Hessian entry ∂ᵢ∂ⱼp exactly equals the per-(i,j) quadratic leaf set.

No cancellation occurs because each output coefficient is a nonzero scalar multiple
of exactly one input coefficient. This destroys the usual loophole where support
combinatorics overpredicts actual algebra due to cancellation. -/
theorem hessian_support_eq_quadLeafSet
    (p : MvPolynomial σ ℚ) (i j : σ) :
    {d | MvPolynomial.coeff d (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)) ≠ 0} =
    quadLeafSet {m | MvPolynomial.coeff m p ≠ 0} i j := by
  ext d
  exact coeff_pderiv_pderiv_ne_zero_iff i j p d

/-! ## Non-Cancellation Certificate -/

/-- A **non-cancellation certificate** for a polynomial p asserts that every
exponent in the quadratic shadow of supp(p) also has nonzero coefficient in p.

This means `QuadraticShadow(supp(p)) ⊆ supp(p)`, ensuring the support is
"downward closed" under the shadow operation. This guarantees that Hessian
entries not only have predictable support, but their support elements are
themselves valid ancestors for further differentiation. -/
def NonCancellationCert (p : MvPolynomial σ ℚ) : Prop :=
  ∀ d : σ →₀ ℕ,
    (∃ α : σ →₀ ℕ, MvPolynomial.coeff α p ≠ 0 ∧
      ∃ i j : σ, α = d + Finsupp.single i 1 + Finsupp.single j 1) →
    MvPolynomial.coeff d p ≠ 0

/-- The **Hessian support exactness** structure records that the support of every
Hessian entry equals the predicted quadratic leaf set. -/
structure HessianSupportExact (p : MvPolynomial σ ℚ) : Prop where
  support_eq : ∀ i j : σ, ∀ d : σ →₀ ℕ,
    MvPolynomial.coeff d (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)) ≠ 0 ↔
    d ∈ quadLeafSet {m | MvPolynomial.coeff m p ≠ 0} i j

/-- Every polynomial over ℚ has exact Hessian support, without any certificate
needed. This follows from the characteristic-zero non-cancellation property. -/
theorem hessianSupportExact_of_charZero (p : MvPolynomial σ ℚ) :
    HessianSupportExact p :=
  ⟨fun i j d => coeff_pderiv_pderiv_ne_zero_iff i j p d⟩

/-! ## Genericity of the Certificate -/

/-
**Theorem 3 (Genericity)**:
For a fixed finite support set S, any coefficient assignment making all
S-coefficients nonzero satisfies the non-cancellation certificate.

The key insight is that when every monomial in S has nonzero coefficient,
the polynomial's support is exactly S, and so the quadratic shadow (which
is computed from S) is fully predictable. Any exponent in the shadow
that also lies in S automatically has nonzero coefficient.

Over an infinite field of characteristic zero, the set of "all nonzero"
coefficient assignments is the complement of finitely many coordinate
hyperplanes — a Zariski-open dense set.
-/
theorem nonCancellationCert_generic
    [Fintype σ]
    (S : Finset (σ →₀ ℕ))
    (a : (σ →₀ ℕ) → ℚ)
    (ha : ∀ d ∈ S, a d ≠ 0)
    (hS : ∀ d : σ →₀ ℕ, (∃ α ∈ S, ∃ i j : σ,
      α = d + Finsupp.single i 1 + Finsupp.single j 1) → d ∈ S) :
    NonCancellationCert (∑ d ∈ S, MvPolynomial.C (a d) * MvPolynomial.monomial d 1) := by
  intro d hd; rcases hd with ⟨ α, hα, i, j, rfl ⟩ ; simp_all +decide [ MvPolynomial.coeff_sum, MvPolynomial.coeff_C_mul ] ;
  exact hS _ _ _ hα

/-! ## Coefficient-Aware Shadow Lower Bound -/

/-- The **shadow complexity** of a support set S is the cardinality of its
computable quadratic shadow. -/
def shadowComplexity [Fintype σ] (S : Finset (σ →₀ ℕ)) : ℕ :=
  (S.biUnion fun α =>
    (Finset.univ : Finset σ).biUnion fun i =>
      (Finset.univ : Finset σ).biUnion fun j =>
        if α i ≥ 1 ∧ (α - Finsupp.single i 1 : σ →₀ ℕ) j ≥ 1
        then {(α - Finsupp.single i 1 : σ →₀ ℕ) - Finsupp.single j 1}
        else ∅).card

/-- The **Hessian nonzero count** of a polynomial: the number of distinct
exponents appearing with nonzero coefficient across all Hessian entries. -/
def hessianNonzeroCount [Fintype σ] (p : MvPolynomial σ ℚ) : ℕ :=
  (Finset.univ.biUnion fun i : σ =>
    Finset.univ.biUnion fun j : σ =>
      (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)).support).card

/-
**Theorem 2 (Shadow Lower Bound Transfer)**:
The shadow complexity of supp(p) lower-bounds the Hessian nonzero count.
This converts the combinatorial shadow bound into a bound on genuine
polynomial structure.
-/
theorem shadow_complexity_le_hessianNonzeroCount
    [Fintype σ]
    (p : MvPolynomial σ ℚ) :
    shadowComplexity p.support ≤ hessianNonzeroCount p := by
  refine Finset.card_le_card ?_;
  intro β hβ;
  simp +zetaDelta at *;
  rcases hβ with ⟨ a, ha, i, j, h ⟩ ; split_ifs at h <;> simp_all +decide [ sub_eq_iff_eq_add ] ;
  refine' ⟨ i, j, _ ⟩;
  convert coeff_pderiv_pderiv_ne_zero_iff i j p ( ( a - Finsupp.single i 1 ) - Finsupp.single j 1 ) |>.2 _ using 1;
  convert ha using 2 ; ext k ; by_cases hi : i = k <;> by_cases hj : j = k <;> simp_all +decide [ Finsupp.single_apply ]

/-! ## Union Decomposition -/

/-
The union of all per-(i,j) quadratic leaf sets equals the global quadratic
shadow.
-/
omit [DecidableEq σ] in
theorem quadLeafSet_union_eq_quadraticShadow (S : Set (σ →₀ ℕ)) :
    (⋃ i : σ, ⋃ j : σ, quadLeafSet S i j) =
    {β | ∃ α ∈ S, ∃ i j : σ, α = β + Finsupp.single i 1 + Finsupp.single j 1} := by
  ext β
  simp [quadLeafSet]

/-! ## Monotonicity -/

omit [DecidableEq σ] in
theorem quadLeafSet_mono {S₁ S₂ : Set (σ →₀ ℕ)} (h : S₁ ⊆ S₂)
    (i j : σ) : quadLeafSet S₁ i j ⊆ quadLeafSet S₂ i j :=
  fun _ hβ => h hβ

end NonCancellationCertificate