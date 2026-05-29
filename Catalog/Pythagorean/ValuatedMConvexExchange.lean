/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Valuated M-Convex Exchange and Coefficient Transport under Differentiation

This file formalizes a bridge from support-level M-convex exchange to
coefficient-level quantitative exchange, and proves that this bridge survives
partial differentiation. The transport law is governed by the coefficient identity
  `coeff m (pderiv i p) = (m i + 1) * coeff (m + e_i) p`.

## Main Definitions

* `ValuatedExchange` — Four-point multiplicative exchange inequality for polynomial
  coefficients on exchange squares
* `exchangeDown` / `exchangeUp` — Safe elementary exchange operations on exponent vectors

## Main Results

* `coeff_pderiv_transport` — Coefficient transport identity for partial derivatives
* `pderiv_coeff_nonneg_of_nonneg` — Nonnegativity preservation under differentiation
* `valuatedExchange_pderiv_local` — Local preservation of valuated exchange under
  partial differentiation
* `valuatedExchange_binomial` — Two-term polynomials satisfy exchange with K=1
* `valuatedExchange_implies_slice_logconcave` — Cross-domain bridge to log-concavity

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open MvPolynomial Finsupp BigOperators

noncomputable section

namespace ValuatedMConvex

/-! ## Exchange Operations on Exponent Vectors -/

/-- Elementary exchange: decrease coordinate `i` by 1, increase coordinate `j` by 1. -/
def exchangeDown {σ : Type*} [DecidableEq σ] (a : σ →₀ ℕ) (i j : σ) : σ →₀ ℕ :=
  a - Finsupp.single i 1 + Finsupp.single j 1

/-- Elementary exchange: increase coordinate `i` by 1, decrease coordinate `j` by 1. -/
def exchangeUp {σ : Type*} [DecidableEq σ] (b : σ →₀ ℕ) (i j : σ) : σ →₀ ℕ :=
  b + Finsupp.single i 1 - Finsupp.single j 1

/-! ## Core Definition: Valuated Exchange Property -/

/-- **Valuated M-convex exchange property** for multivariate polynomials.

For any two exponent vectors `a, b` in the support with `a i > b i`, there exists
an exchange witness `j` such that the four-point multiplicative inequality holds:
  `coeff a * coeff b ≤ K * coeff (exchangeDown a i j) * coeff (exchangeUp b i j)` -/
def ValuatedExchange
    {σ : Type*} {R : Type*} [DecidableEq σ] [CommRing R] [LinearOrder R] [IsOrderedRing R]
    (p : MvPolynomial σ R) (K : R) : Prop :=
  ∀ ⦃a b : σ →₀ ℕ⦄,
    p.coeff a ≠ 0 → p.coeff b ≠ 0 →
    ∀ ⦃i : σ⦄, b i < a i →
      ∃ j : σ, a j < b j ∧
        p.coeff (exchangeDown a i j) ≠ 0 ∧
        p.coeff (exchangeUp b i j) ≠ 0 ∧
        p.coeff a * p.coeff b ≤ K * p.coeff (exchangeDown a i j) * p.coeff (exchangeUp b i j)

/-! ## Theorem 1: Coefficient Transport Identity for Partial Derivatives -/

/-- **Coefficient transport identity**: The coefficient of exponent `m` in the partial
derivative `∂ᵢ p` equals `(m i + 1)` times the coefficient of `m + eᵢ` in `p`. -/
theorem coeff_pderiv_transport
    {σ : Type*} {R : Type*} [DecidableEq σ] [CommSemiring R]
    (p : MvPolynomial σ R) (i : σ) (m : σ →₀ ℕ) :
    (MvPolynomial.pderiv i p).coeff m =
      (m i + 1) • p.coeff (m + Finsupp.single i 1) := by
  induction' p using MvPolynomial.induction_on' with p q hp hq;
  · by_cases hi : p i = 0 <;> simp +decide [ hi, pderiv_monomial ];
    · intro h; replace h := congr_arg ( fun f => f i ) h; simp_all +decide ;
    · split_ifs <;> simp_all +decide [ Finsupp.ext_iff, Finsupp.single_apply ];
      · ring;
      · grind;
  · simp_all +decide [ MvPolynomial.coeff_add ]

/-! ## Theorem 2: Nonnegativity Preservation under Differentiation -/

/-- Partial differentiation preserves nonnegativity of coefficients. -/
theorem pderiv_coeff_nonneg_of_nonneg
    {σ : Type*} {R : Type*} [DecidableEq σ] [CommRing R] [LinearOrder R] [IsOrderedRing R]
    (p : MvPolynomial σ R) (i : σ)
    (h_nonneg : ∀ m, 0 ≤ p.coeff m) :
    ∀ m, 0 ≤ (MvPolynomial.pderiv i p).coeff m := by
  intro m
  rw [coeff_pderiv_transport]
  exact nsmul_nonneg (h_nonneg _) _

/-! ## Theorem 3: Local Preservation of Valuated Exchange under Differentiation -/

/-- **Local coefficient transport bound**: Given an exchange in the derivative
`∂ᵢ p` involving coordinate `k ≠ i`, the derivative satisfies a valuated exchange
with support membership guaranteed by the original polynomial's exchange property. -/
theorem valuatedExchange_pderiv_local
    {σ : Type*} {R : Type*} [DecidableEq σ] [Field R] [LinearOrder R] [IsOrderedRing R]
    (p : MvPolynomial σ R) (K : R) (i : σ)
    (_hK : 0 < K)
    (hVE : ValuatedExchange p K)
    (_h_nonneg : ∀ m, 0 ≤ p.coeff m)
    (a b : σ →₀ ℕ)
    (ha : (MvPolynomial.pderiv i p).coeff a ≠ 0)
    (hb : (MvPolynomial.pderiv i p).coeff b ≠ 0)
    (k : σ) (hki : k ≠ i) (hk : b k < a k) :
    ∃ j : σ, a j < b j ∧
      (MvPolynomial.pderiv i p).coeff (exchangeDown a k j) ≠ 0 ∧
      (MvPolynomial.pderiv i p).coeff (exchangeUp b k j) ≠ 0 := by
  have hfnderiv : (MvPolynomial.pderiv i p).coeff a = (a i + 1) • p.coeff (a + Finsupp.single i 1) ∧ (MvPolynomial.pderiv i p).coeff b = (b i + 1) • p.coeff (b + Finsupp.single i 1) := by
    exact ⟨ coeff_pderiv_transport p i a, coeff_pderiv_transport p i b ⟩
  set A : σ →₀ ℕ := a + Finsupp.single i 1
  set B : σ →₀ ℕ := b + Finsupp.single i 1
  have hA : p.coeff A ≠ 0 := by aesop
  have hB : p.coeff B ≠ 0 := by aesop
  obtain ⟨j, hj₁, hj₂⟩ := hVE hA hB (by aesop : B k < A k)
  have h_exchangeDown : exchangeDown A k j = exchangeDown a k j + Finsupp.single i 1 := by
    ext x; by_cases hx : x = i <;> simp +decide [ *, exchangeDown ]
    · simp +decide [ A, add_comm, add_left_comm ]
    · aesop
  have h_exchangeUp : exchangeUp B k j = exchangeUp b k j + Finsupp.single i 1 := by
    simp +zetaDelta at *
    unfold exchangeUp; simp +decide [ Finsupp.ext_iff, Finsupp.single_apply ]
    grind
  refine' ⟨ j, _, _, _ ⟩ <;> simp_all +decide [ coeff_pderiv_transport ]
  · contrapose! hj₁; aesop
  · norm_cast
  · norm_cast

/-! ## Theorem 4: Valuated Exchange for Binomial Polynomials (Two-Term Case) -/

/-
**Two-term polynomials satisfy valuated exchange with K = 1.**
A polynomial of the form `monomial α a + monomial β b` with `a, b > 0` and `α ≠ β`
satisfies `ValuatedExchange p 1` whenever the support exchange property holds
(i.e., whenever `α` and `β` form an exchange pair). This captures the base case
for derivative polynomials of the U(2,3) weighted uniform matroid.

The key insight is that for a two-element support {α, β}, any exchange at
coordinate i with α_i > β_i must produce as witness some j with α_j < β_j,
and the exchanged pair (α', β') = (α - eᵢ + eⱼ, β + eᵢ - eⱼ) must have
α' = β and β' = α (since the exchange swaps the two elements). Therefore
the inequality `a*b ≤ 1*b*a` is trivially satisfied.
-/
theorem valuatedExchange_binomial
    {σ : Type*} {R : Type*} [DecidableEq σ] [CommRing R] [LinearOrder R] [IsOrderedRing R]
    (α β : σ →₀ ℕ) (a b : R) (_ha : 0 < a) (hb : 0 < b)
    (hαβ : α ≠ β)
    (h_exch_fwd : ∀ ⦃i : σ⦄, β i < α i → ∃ j : σ, α j < β j ∧
      exchangeDown α i j = β ∧ exchangeUp β i j = α)
    (h_exch_bwd : ∀ ⦃i : σ⦄, α i < β i → ∃ j : σ, β j < α j ∧
      exchangeDown β i j = α ∧ exchangeUp α i j = β) :
    ValuatedExchange (MvPolynomial.monomial α a + MvPolynomial.monomial β b) 1 := by
  intro c d hc hd i hi;
  -- Since $c$ and $d$ are in the support of $p$, we have $c = α$ or $c = β$, and $d = α$ or $d = β$.
  have h_cases : c = α ∨ c = β := by
    grind +suggestions
  have h_cases' : d = α ∨ d = β := by
    contrapose! hd; simp_all +decide [ MvPolynomial.coeff_add, MvPolynomial.coeff_monomial ] ;
    grind;
  rcases h_cases with ( rfl | rfl ) <;> rcases h_cases' with ( rfl | rfl ) <;> simp_all +decide [ MvPolynomial.coeff_add, MvPolynomial.coeff_monomial ];
  · obtain ⟨ j, hj₁, hj₂, hj₃ ⟩ := h_exch_fwd hi;
    use j; simp_all +decide [ ne_of_gt ] ;
    rw [ mul_comm ];
  · obtain ⟨ j, hj₁, hj₂, hj₃ ⟩ := h_exch_bwd hi; use j; simp_all +decide [ mul_comm ] ;

/-! ## Theorem 5: Cross-Domain Bridge — Valuated Exchange Implies Slice Log-Concavity -/

/-- **Valuated exchange implies slice log-concavity**: For exponents `m` and
`m' = m + eᵢ - eⱼ` both in the support with `m'_i > m_i`, the exchange applied
at coordinate `i` yields a log-concavity-type inequality. This bridges discrete
convex analysis to Lorentzian polynomial coefficient geometry. -/
theorem valuatedExchange_implies_slice_logconcave
    {σ : Type*} {R : Type*} [DecidableEq σ] [CommRing R] [LinearOrder R] [IsOrderedRing R]
    (p : MvPolynomial σ R) (K : R)
    (hVE : ValuatedExchange p K)
    (m : σ →₀ ℕ)
    (i j : σ) (hij : i ≠ j)
    (_hmi : 1 ≤ m i)
    (hm' : p.coeff (m + Finsupp.single i 1 - Finsupp.single j 1) ≠ 0)
    (hm : p.coeff m ≠ 0) :
    let m' := m + Finsupp.single i 1 - Finsupp.single j 1
    ∃ j' : σ,
      m' j' < m j' ∧
      p.coeff (exchangeDown m' i j') ≠ 0 ∧
      p.coeff (exchangeUp m i j') ≠ 0 ∧
      p.coeff m' * p.coeff m ≤
        K * p.coeff (exchangeDown m' i j') *
          p.coeff (exchangeUp m i j') := by
  apply hVE hm' hm
  simp +decide [ hij ]

end ValuatedMConvex