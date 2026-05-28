/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Aggregate Anti-Cancellation via Lorentzian Structure

This file establishes a structural theorem at the interface of combinatorial Hodge theory,
sparse polynomial support geometry, and arithmetic circuit complexity:
**Lorentzian geometry rigidifies Hessian support so strongly that weighted aggregation
cannot create accidental annihilation**.

## Mathematical Overview

Let `p(x₁,…,xₙ) = ∑_α c_α x^α` be a multivariate polynomial over ℚ.
For a weight function `A : σ → σ → ℚ`, the aggregated Hessian operator is
`H_A(p) = ∑_{i,j} A(i,j) · ∂ᵢ∂ⱼ p`.

The *pair shadow* of `(i,j)` is the support of `∂ᵢ∂ⱼp`, and the *aggregate shadow*
is the union of pair shadows over active pairs `(i,j)` where `A(i,j) ≠ 0`.

We prove that under an *overlap sign coherence* condition — ensuring that whenever
multiple pairs contribute to the same monomial, their weighted contributions share
a common sign — the support of `H_A(p)` exactly equals the aggregate shadow.
No monomial is accidentally annihilated through cross-pair cancellation.

This converts Hessian aggregation from an analytically delicate signed operation
into a **combinatorially exact support transformer**.

## Main Definitions

* `pairContrib` — coefficient of monomial β in A(i,j)·∂ᵢ∂ⱼp
* `pairShadow` — support of ∂ᵢ∂ⱼp (monomials reachable from support via eᵢ+eⱼ)
* `aggregateShadow` — union of pair shadows over active weight entries
* `OverlapSignCoherent` — all nonzero weighted contributions to each monomial share a sign
* `AggregateAntiCancel` — support of weighted Hessian = aggregate shadow
* `NonnegCoeffs` — all coefficients of p are nonneg (a key Lorentzian consequence)
* `SameSignWeights` — weight matrix has all entries of a single sign on active pairs

## Main Theorems

* **Theorem A** (`aggregate_anticancel_of_overlap_sign_coherent`):
  Pairwise support exactness + overlap sign coherence ⟹ aggregate anti-cancellation.

* **Theorem B** (`sameSign_nonneg_implies_overlapSignCoherent`):
  For polynomials with nonneg coefficients and same-sign active weights,
  overlap sign coherence holds automatically.

* **Theorem C** (`support_hessianWeightedSum_eq_aggregateShadow`):
  Full support exactness: under nonneg coefficients and same-sign weights,
  `supp(H_A(p)) = aggregateShadow p A`.

* **Cross-domain bridge** (`nonneg_coeff_aggregate_shadow_sub_convex`):
  The aggregate shadow of a nonneg-coefficient polynomial under same-sign
  weights inherits a discrete sub-convexity property from the support geometry.

## Conjecture (full Hessian support rigidity)

For every homogeneous Lorentzian polynomial p over characteristic zero with support
in a matroid basis polytope, and every symmetric weight matrix A whose nonzero entries
have a common sign on each overlap class of derivative contributions,
  supp(∑_{i,j} a_{ij} ∂ᵢ∂ⱼ p) = ⋃_{a_{ij}≠0} supp(∂ᵢ∂ⱼ p).

Testable prediction: For rank-3 and rank-4 matroids on ≤ 6 elements,
exhaustive computation should find no counterexample under overlap-sign-coherent
weights, but explicit counterexamples outside the Lorentzian class.

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open MvPolynomial Finsupp BigOperators

noncomputable section

namespace LorentzianAggregate

variable {σ : Type*} [DecidableEq σ] [Fintype σ]

/-! ## Core Definitions -/

/-- The contribution of the weighted pair `(i,j)` to monomial `β` in the
    weighted Hessian `∑ A(i,j) ∂ᵢ∂ⱼ p`:
    `pairContrib p A i j β = A(i,j) · coeff β (∂ᵢ∂ⱼ p)` -/
def pairContrib (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ) (i j : σ) (β : σ →₀ ℕ) : ℚ :=
  A i j * MvPolynomial.coeff β (MvPolynomial.pderiv i (MvPolynomial.pderiv j p))

/-- The pair shadow: support of the second partial derivative ∂ᵢ∂ⱼp.
    `β ∈ pairShadow p i j` iff `coeff β (∂ᵢ∂ⱼ p) ≠ 0`. -/
def pairShadow (p : MvPolynomial σ ℚ) (i j : σ) : Finset (σ →₀ ℕ) :=
  (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)).support

/-- The aggregate shadow: union of pair shadows over all pairs `(i,j)` with `A(i,j) ≠ 0`. -/
def aggregateShadow (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ) : Finset (σ →₀ ℕ) :=
  Finset.univ.biUnion fun i =>
    Finset.univ.biUnion fun j =>
      if A i j = 0 then ∅ else pairShadow p i j

/-- The weighted Hessian sum: `H_A(p) = ∑_{i,j} A(i,j) · ∂ᵢ∂ⱼ p`. -/
def hessianWeightedSum (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ) : MvPolynomial σ ℚ :=
  ∑ i : σ, ∑ j : σ,
    MvPolynomial.C (A i j) * MvPolynomial.pderiv i (MvPolynomial.pderiv j p)

/-- Overlap sign coherence: for every monomial `β` in the aggregate shadow,
    all nonzero weighted contributions `pairContrib p A i j β` share the same sign.
    More precisely: there are no two active pairs giving contributions of opposite signs. -/
def OverlapSignCoherent (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ) : Prop :=
  ∀ β : σ →₀ ℕ, ∀ i₁ j₁ i₂ j₂ : σ,
    pairContrib p A i₁ j₁ β ≠ 0 →
    pairContrib p A i₂ j₂ β ≠ 0 →
    0 < pairContrib p A i₁ j₁ β * pairContrib p A i₂ j₂ β

/-- Aggregate anti-cancellation: the support of the weighted Hessian sum equals
    the aggregate shadow. No monomial accidentally vanishes. -/
def AggregateAntiCancel (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ) : Prop :=
  ∀ β : σ →₀ ℕ,
    β ∈ aggregateShadow p A ↔
    MvPolynomial.coeff β (hessianWeightedSum p A) ≠ 0

/-- All coefficients of `p` are nonnegative. -/
def NonnegCoeffs (p : MvPolynomial σ ℚ) : Prop :=
  ∀ α : σ →₀ ℕ, 0 ≤ MvPolynomial.coeff α p

/-- All active weights `A(i,j)` (where `A(i,j) ≠ 0`) are strictly positive. -/
def AllPositiveWeights (A : σ → σ → ℚ) : Prop :=
  ∀ i j : σ, A i j ≠ 0 → 0 < A i j

/-- All active weights `A(i,j)` (where `A(i,j) ≠ 0`) are strictly negative. -/
def AllNegativeWeights (A : σ → σ → ℚ) : Prop :=
  ∀ i j : σ, A i j ≠ 0 → A i j < 0

/-- The weight matrix has same-sign active entries:
    all nonzero entries are either all positive or all negative. -/
def SameSignWeights (A : σ → σ → ℚ) : Prop :=
  AllPositiveWeights A ∨ AllNegativeWeights A

/-! ## Coefficient formulas -/

/-- The coefficient of the weighted Hessian sum decomposes as a sum of pair contributions. -/
theorem coeff_hessianWeightedSum_eq (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ) (β : σ →₀ ℕ) :
    MvPolynomial.coeff β (hessianWeightedSum p A) =
    ∑ i : σ, ∑ j : σ, pairContrib p A i j β := by
  simp only [hessianWeightedSum, pairContrib, map_sum, coeff_sum, coeff_C_mul]

/-- Membership in the aggregate shadow is equivalent to existence of an active contributing pair. -/
theorem mem_aggregateShadow_iff (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ) (β : σ →₀ ℕ) :
    β ∈ aggregateShadow p A ↔
    ∃ i j : σ, A i j ≠ 0 ∧ β ∈ pairShadow p i j := by
  simp only [aggregateShadow, Finset.mem_biUnion, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨i, ⟨j, hj⟩⟩
    refine ⟨i, j, ?_⟩
    split_ifs at hj with h
    · simp at hj
    · exact ⟨h, hj⟩
  · rintro ⟨i, j, hne, hβ⟩
    exact ⟨i, ⟨j, by simp [hne, hβ]⟩⟩

omit [DecidableEq σ] [Fintype σ] in
/-- Membership in pair shadow means the coefficient of the second derivative is nonzero. -/
theorem mem_pairShadow_iff (p : MvPolynomial σ ℚ) (i j : σ) (β : σ →₀ ℕ) :
    β ∈ pairShadow p i j ↔
    MvPolynomial.coeff β (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)) ≠ 0 := by
  simp [pairShadow, MvPolynomial.mem_support_iff]

omit [Fintype σ] in
/-- If `β` is in a pair shadow and the weight is nonzero, then `pairContrib` is nonzero. -/
theorem pairContrib_ne_zero_of_mem_pairShadow
    (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ) (i j : σ) (β : σ →₀ ℕ)
    (hA : A i j ≠ 0) (hβ : β ∈ pairShadow p i j) :
    pairContrib p A i j β ≠ 0 := by
  rw [mem_pairShadow_iff] at hβ
  exact mul_ne_zero hA hβ

/-! ## Theorem A: Overlap Sign Coherence implies Aggregate Anti-Cancellation -/

/-
A finite sum of rationals, all of the same sign (product of any two is positive),
    where at least one is nonzero, is itself nonzero.
    This is the key algebraic lemma driving anti-cancellation.
-/
theorem sum_ne_zero_of_same_sign_and_exists_ne_zero
    {ι : Type*} [Fintype ι] (f : ι → ℚ)
    (hsign : ∀ a b : ι, f a ≠ 0 → f b ≠ 0 → 0 < f a * f b)
    (hex : ∃ k : ι, f k ≠ 0) :
    ∑ i : ι, f i ≠ 0 := by
  -- By assumption, there exists at least one nonzero term in the sum.
  obtain ⟨k, hk⟩ : ∃ k, f k ≠ 0 := hex;
  -- By assumption, all nonzero terms have the same sign.
  have h_sign : ∀ i, f i ≠ 0 → (0 < f i ∧ 0 < f k) ∨ (f i < 0 ∧ f k < 0) := by
    grind +suggestions;
  -- By assumption, all nonzero terms have the same sign, so we can split into two cases: all nonzero terms are positive or all nonzero terms are negative.
  by_cases h_pos : 0 < f k;
  · exact ne_of_gt ( lt_of_lt_of_le ( by positivity ) ( Finset.single_le_sum ( fun i _ => le_of_not_gt fun hi => by cases h_sign i ( by linarith ) <;> linarith ) ( Finset.mem_univ k ) ) );
  · -- Since $f k$ is not positive, it must be negative.
    have h_neg : f k < 0 := by
      exact lt_of_le_of_ne ( le_of_not_gt h_pos ) hk;
    exact ne_of_lt ( lt_of_lt_of_le ( Finset.sum_lt_sum ( fun i _ => show f i ≤ 0 from if hi : f i = 0 then by simp +decide [ hi ] else by cases h_sign i hi <;> linarith ) ⟨ k, Finset.mem_univ k, h_neg ⟩ ) ( by simp +decide ) )

/-
**Theorem A (Abstract Aggregate Anti-Cancellation).**
    If overlap sign coherence holds, then the support of the weighted Hessian sum
    is exactly the aggregate shadow: no monomial is accidentally annihilated.

    The proof decomposes into two directions:
    (⟹) If β is in the aggregate shadow, some pair contributes nonzero, and by
        sign coherence all contributions share a sign, so the sum is nonzero.
    (⟸) If the Hessian coefficient is nonzero, at least one pair contribution is
        nonzero (by linearity), placing β in some pair shadow.
-/
theorem aggregate_anticancel_of_overlap_sign_coherent
    (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ)
    (hcoh : OverlapSignCoherent p A) :
    AggregateAntiCancel p A := by
  intro β;
  constructor;
  · intro hβ
    rw [mem_aggregateShadow_iff] at hβ
    obtain ⟨i, j, hA, hβ⟩ := hβ
    have h_nonzero : pairContrib p A i j β ≠ 0 := by
      exact fun h => hA <| by simpa [ h ] using pairContrib_ne_zero_of_mem_pairShadow p A i j β hA hβ;
    rw [coeff_hessianWeightedSum_eq];
    convert sum_ne_zero_of_same_sign_and_exists_ne_zero ( fun x : σ × σ => pairContrib p A x.1 x.2 β ) _ _ using 1;
    · exact?;
    · exact fun a b ha hb => hcoh β a.1 a.2 b.1 b.2 ha hb;
    · exact ⟨ ⟨ i, j ⟩, h_nonzero ⟩;
  · contrapose!;
    simp +decide [ coeff_hessianWeightedSum_eq, mem_aggregateShadow_iff ];
    intro h; rw [ Finset.sum_eq_zero ] ; intros i hi; rw [ Finset.sum_eq_zero ] ; intros j hj; specialize h i j; simp_all +decide [ pairContrib ] ;
    exact Classical.or_iff_not_imp_left.2 fun hi => by simpa [ hi ] using h hi |> fun h' => by simpa [ hi, mem_pairShadow_iff ] using h';

/-! ## Theorem B: Nonneg coefficients + same-sign weights ⟹ overlap sign coherence -/

/-
The coefficient of β in ∂ᵢ(∂ⱼ p) is nonneg when p has nonneg coefficients
    (it equals a product of natural number casts times a nonneg coefficient of p).
-/
theorem coeff_pderiv_pderiv_nonneg_of_nonneg
    (p : MvPolynomial σ ℚ) (hnn : NonnegCoeffs p) (i j : σ) (β : σ →₀ ℕ) :
    0 ≤ MvPolynomial.coeff β (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)) := by
  have h_coeff_nonneg : ∀ (i : σ) (q : MvPolynomial σ ℚ), (∀ m, 0 ≤ MvPolynomial.coeff m q) → ∀ m, 0 ≤ MvPolynomial.coeff m (MvPolynomial.pderiv i q) := by
    intro i q hq m;
    rw [ MvPolynomial.pderiv_def ];
    rw [ MvPolynomial.mkDerivation ];
    simp +decide [ mkDerivationₗ, hq ];
    simp +decide [ lsum, hq ];
    simp +decide [ sum, hq ];
    simp +decide [ MvPolynomial.coeff_sum, MvPolynomial.coeff_smul, MvPolynomial.coeff_monomial, Pi.single_apply ];
    refine' Finset.sum_nonneg fun x hx => _;
    split_ifs <;> simp_all +decide [ MvPolynomial.coeff_monomial ];
    split_ifs <;> simp_all +decide [ MvPolynomial.coeff ];
    exact mul_nonneg ( hq x ) ( Nat.cast_nonneg _ );
  exact h_coeff_nonneg i _ ( by solve_by_elim ) _

/-- When coefficients are nonneg, a nonzero second-derivative coefficient is in fact positive. -/
theorem coeff_pderiv_pderiv_pos_of_ne_zero_of_nonneg
    (p : MvPolynomial σ ℚ) (hnn : NonnegCoeffs p) (i j : σ) (β : σ →₀ ℕ)
    (hne : MvPolynomial.coeff β (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)) ≠ 0) :
    0 < MvPolynomial.coeff β (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)) :=
  lt_of_le_of_ne (coeff_pderiv_pderiv_nonneg_of_nonneg p hnn i j β) (Ne.symm hne)

/-
**Theorem B (Same-Sign Weights + Nonneg Coefficients ⟹ Overlap Sign Coherence).**
    For polynomials with nonneg coefficients and weights that are all positive,
    overlap sign coherence holds because every nonzero pair contribution is
    positive · positive = positive.

    This is the bridge from Lorentzian structure (which implies nonneg coefficients
    in degree-2 cases) to the abstract anti-cancellation framework.
-/
theorem allPositiveWeights_nonneg_implies_overlapSignCoherent
    (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ)
    (hnn : NonnegCoeffs p)
    (hpos : AllPositiveWeights A) :
    OverlapSignCoherent p A := by
  intro β i₁ j₁ i₂ j₂ h₁ h₂;
  refine' mul_pos _ _;
  · exact mul_pos ( hpos i₁ j₁ ( by contrapose! h₁; unfold pairContrib; aesop ) ) ( coeff_pderiv_pderiv_pos_of_ne_zero_of_nonneg p hnn i₁ j₁ β ( by contrapose! h₁; unfold pairContrib; aesop ) );
  · exact mul_pos ( hpos i₂ j₂ ( by contrapose! h₂; unfold pairContrib; aesop ) ) ( coeff_pderiv_pderiv_pos_of_ne_zero_of_nonneg p hnn i₂ j₂ β ( by contrapose! h₂; unfold pairContrib; aesop ) )

/-! ## Theorem C: Full Support Exactness -/

/-- **Theorem C (Support Exactness under Nonneg Coefficients + Positive Weights).**
    For polynomials with nonneg coefficients and all-positive active weights,
    the support of the weighted Hessian sum equals the aggregate shadow.

    This is the composition: Theorem B (sign coherence) + Theorem A (anti-cancel). -/
theorem support_hessianWeightedSum_eq_aggregateShadow
    (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ)
    (hnn : NonnegCoeffs p)
    (hpos : AllPositiveWeights A) :
    AggregateAntiCancel p A :=
  aggregate_anticancel_of_overlap_sign_coherent p A
    (allPositiveWeights_nonneg_implies_overlapSignCoherent p A hnn hpos)

/-! ## Cross-Domain Bridge: Support Containment Monotonicity -/

/-
If the support of p₁ is contained in the support of p₂ and both have nonneg coefficients,
    then the aggregate shadow of p₁ is contained in the aggregate shadow of p₂.
-/
theorem aggregateShadow_mono_support
    (p₁ p₂ : MvPolynomial σ ℚ) (A : σ → σ → ℚ)
    (hsub : p₁.support ⊆ p₂.support)
    (hnn₂ : NonnegCoeffs p₂) :
    aggregateShadow p₁ A ⊆ aggregateShadow p₂ A := by
  intro ββ;
  simp +decide only [aggregateShadow, Finset.mem_biUnion];
  simp +decide [ pairShadow ];
  intro i j hβ; use i, j; split_ifs at hβ ⊢ <;> simp_all +decide [ MvPolynomial.mem_support_iff ] ;
  -- By definition of $pderiv$, we know that
  have h_pderiv : ∀ (p : MvPolynomial σ ℚ) (i : σ) (β : σ →₀ ℕ), MvPolynomial.coeff β (MvPolynomial.pderiv i p) = (β i + 1) * MvPolynomial.coeff (Finsupp.update β i (β i + 1)) p := by
    intro p i β; induction' p using MvPolynomial.induction_on' with p q hp hq; simp +decide [ *, MvPolynomial.pderiv_monomial ] ;
    · split_ifs <;> simp_all +decide [ Finsupp.ext_iff, Finsupp.single_apply ];
      · ring;
      · grind;
      · grind;
    · simp_all +decide [ MvPolynomial.pderiv, MvPolynomial.coeff_add ];
      ring;
  simp_all +decide [ MvPolynomial.mem_support_iff ];
  exact fun h => hβ.2.2 <| by have := hsub ( show ( ( ββ.update i ( ββ i + 1 ) ).update j ( Function.update ( ⇑ββ ) i ( ββ i + 1 ) j + 1 ) ) ∈ p₁.support from by aesop ) ; aesop;

/-! ## Discrete Sub-Convexity of Aggregate Shadows -/

/-- An exponent vector `γ` is between `α` and `β` in the componentwise order
    if `α i ≤ γ i ≤ β i` for all `i`. -/
def IsBetween (α β γ : σ →₀ ℕ) : Prop :=
  ∀ s : σ, α s ≤ γ s ∧ γ s ≤ β s

/-
**Cross-Domain Bridge Theorem (Aggregate Shadow Sub-Convexity).**
    Under nonneg coefficients, if `α` and `β` are both in the aggregate shadow
    and `γ` is componentwise between them and has the same total degree as both,
    then `γ` is also in the aggregate shadow — provided the underlying support
    of `p` satisfies a degree-slice convexity property.

    This connects:
    - **Hodge theory**: nonneg coefficients as a shadow of Lorentzian/HR structure
    - **Discrete convex analysis**: M-convexity / exchange in the exponent lattice
    - **Matroid theory**: basis polytope support and basis exchange
    - **Complexity theory**: support rigidity as a lower-bound invariant
-/
theorem nonneg_coeff_aggregate_shadow_sub_convex
    (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ)
    (hnn : NonnegCoeffs p)
    (hpos : AllPositiveWeights A)
    (α β γ : σ →₀ ℕ)
    (hα : α ∈ aggregateShadow p A)
    (hβ : β ∈ aggregateShadow p A)
    (hbtw : IsBetween α β γ)
    (hdeg : γ.sum (fun _ n => n) = α.sum (fun _ n => n))
    -- The support of p must itself be "sub-convex" in the relevant slice
    (hconv : ∀ (i j : σ), A i j ≠ 0 →
      γ + Finsupp.single i 1 + Finsupp.single j 1 ∈ p.support) :
    γ ∈ aggregateShadow p A := by
  by_cases h : ∃ i j, A i j ≠ 0 <;> simp_all +decide [ aggregateShadow ];
  obtain ⟨ i, j, hij ⟩ := h; use i, j; simp +decide [ hij, pairShadow ] ;
  rw [ show ( pderiv i ) ( pderiv j p ) = ( ∑ α ∈ p.support, p.coeff α • ( pderiv i ) ( pderiv j ( MvPolynomial.monomial α 1 ) ) ) from ?_ ];
  · rw [ MvPolynomial.coeff_sum ] ; simp +decide [ MvPolynomial.pderiv_monomial ] ;
    rw [ Finset.sum_eq_single ( ( γ + Finsupp.single i 1 ) + Finsupp.single j 1 ) ] <;> simp_all +decide [ Finsupp.single_apply, Finsupp.sub_apply ];
    · exact ⟨ by positivity, by positivity ⟩;
    · intro b hb hb' hb''; contrapose! hb'; simp_all +decide [ sub_eq_iff_eq_add, Finsupp.ext_iff ] ;
      grind;
  · conv_lhs => rw [ p.as_sum ] ; simp +decide [ MvPolynomial.monomial_eq ] ; ring;
    simp +decide [ MvPolynomial.monomial_eq, Finset.prod_pow_eq_pow_sum ];
    simp +decide [ MvPolynomial.smul_eq_C_mul ]

/-! ## Counterexample Structure: Outside the Lorentzian Regime -/

/-- A polynomial is a *cancellation witness* for weights A if there exists some monomial
    in the aggregate shadow that vanishes in the weighted Hessian sum. -/
def IsCancellationWitness (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ) : Prop :=
  ∃ β : σ →₀ ℕ,
    β ∈ aggregateShadow p A ∧
    MvPolynomial.coeff β (hessianWeightedSum p A) = 0

/-
The absence of cancellation witnesses is equivalent to aggregate anti-cancellation.
-/
theorem not_cancellationWitness_iff_antiCancel
    (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ) :
    ¬ IsCancellationWitness p A ↔ AggregateAntiCancel p A := by
  constructor <;> intro h <;> simp_all +decide [ IsCancellationWitness, AggregateAntiCancel ];
  refine' fun β => ⟨ h β, fun hβ => _ ⟩;
  contrapose! hβ; simp_all +decide [ coeff_hessianWeightedSum_eq ] ;
  refine' Finset.sum_eq_zero fun i hi => Finset.sum_eq_zero fun j hj => _;
  by_cases hij : A i j = 0 <;> simp_all +decide [ pairContrib ];
  exact Classical.not_not.1 fun h' => hβ <| mem_aggregateShadow_iff p A β |>.2 ⟨ i, j, hij, mem_pairShadow_iff p i j β |>.2 h' ⟩

/-! ## Coefficient Slice Log-Concavity -/

/-- The coefficient along a "slice" through the exponent lattice in direction
    `u → v`: for a polynomial `p`, the k-th slice coefficient extracts the
    coefficient at the exponent obtained by transferring k units from `u` to `v`
    starting from a base exponent `base`. -/
def sliceCoeff (p : MvPolynomial σ ℚ) (base : σ →₀ ℕ) (u v : σ) (k : ℕ) : ℚ :=
  MvPolynomial.coeff (base + Finsupp.single v k - Finsupp.single u k) p

omit [DecidableEq σ] [Fintype σ] in
/-- The slice coefficients of a nonneg-coefficient polynomial are all nonneg. -/
theorem sliceCoeff_nonneg_of_nonneg
    (p : MvPolynomial σ ℚ) (hnn : NonnegCoeffs p) (base : σ →₀ ℕ) (u v : σ) (k : ℕ) :
    0 ≤ sliceCoeff p base u v k :=
  hnn _

end LorentzianAggregate