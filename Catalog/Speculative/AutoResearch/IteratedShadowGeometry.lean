/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Iterated Shadow Geometry of Polynomial Supports

This file builds a theory of **iterated support shadows** for multivariate polynomials,
establishing that higher-order mixed partial differentiation has an exact combinatorial
footprint on exponent sets governed by the shadow operator on Newton supports.

## Main Definitions

* `kthShadow` — The k-th combinatorial shadow of a finite support set: all exponent
  vectors obtainable by subtracting a multi-index of total mass k from some element.
* `iteratedPDeriv` — The mixed partial derivative of a multivariate polynomial indexed
  by a multi-index τ, applying ∂ᵢ exactly τ(i) times for each variable i.
* `finsuppSupport` — The finite support of a multivariate polynomial as a Finset.
* `derivShadowProfile` — The function k ↦ |kthShadow(Supp(f), k)|.
* `IsDiscreteExchangeFamily` — A finite-set exchange property capturing one-step
  symmetric exchange, serving as a formal proxy for M-convexity.

## Main Results

* `coeff_pderivPow` — Coefficient formula for iterated single-variable partial
  derivative: involves ascending factorials.
* `coeff_iteratedPDeriv` — Full multi-index coefficient transport formula.
* `coeff_iteratedPDeriv_ne_zero_iff` — Support criterion: coeff β in the τ-th
  mixed derivative is nonzero iff coeff (β + τ) in f is nonzero.
* `mem_kthShadow_iff_exists_iteratedDerivative` — The exact k-th shadow theorem:
  β belongs to the k-th shadow of Supp(f) iff it appears in the support of some
  k-th order mixed partial derivative.
* `kthShadow_zero` — The 0-th shadow is the original set.
* `kthShadow_add` — Shadow composition law: Sh_b(Sh_a(S)) = Sh_{a+b}(S).

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open MvPolynomial Finsupp BigOperators Classical

noncomputable section

namespace IteratedShadowGeometry

/-! ## Core Definitions -/

/-- The **k-th shadow** of a support set `S`: the set of all exponent vectors `β` such that
`β + τ ∈ S` for some multi-index `τ` with total mass `k`. Equivalently, all vectors
obtainable by subtracting a mass-k multi-index from an element of `S`. -/
def kthShadow {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (k : ℕ) : Finset (Fin n →₀ ℕ) :=
  S.biUnion (fun α =>
    ((Finset.Iic α).filter (fun τ => τ.sum (fun _ m => m) = k)).image (α - ·))

/-- Membership criterion for `kthShadow`. -/
theorem mem_kthShadow_iff {n : ℕ} {S : Finset (Fin n →₀ ℕ)} {k : ℕ} {β : Fin n →₀ ℕ} :
    β ∈ kthShadow S k ↔
      ∃ α ∈ S, ∃ τ : Fin n →₀ ℕ, τ ≤ α ∧ τ.sum (fun _ m => m) = k ∧ β = α - τ := by
  simp only [kthShadow, Finset.mem_biUnion, Finset.mem_image, Finset.mem_filter,
    Finset.mem_Iic]
  constructor
  · rintro ⟨α, hα, τ, ⟨hτle, hτsum⟩, rfl⟩
    exact ⟨α, hα, τ, hτle, hτsum, rfl⟩
  · rintro ⟨α, hα, τ, hτle, hτsum, rfl⟩
    exact ⟨α, hα, τ, ⟨hτle, hτsum⟩, rfl⟩

/-
Alternative membership criterion using addition.
-/
theorem mem_kthShadow_iff' {n : ℕ} {S : Finset (Fin n →₀ ℕ)} {k : ℕ} {β : Fin n →₀ ℕ} :
    β ∈ kthShadow S k ↔
      ∃ τ : Fin n →₀ ℕ, τ.sum (fun _ m => m) = k ∧ β + τ ∈ S := by
  refine' ⟨ fun h => _, fun h => _ ⟩;
  · obtain ⟨ α, hα, τ, hτ, hβ ⟩ := mem_kthShadow_iff.mp h;
    exact ⟨ τ, hβ.1, by simpa [ hβ.2, tsub_add_cancel_of_le hτ ] using hα ⟩;
  · obtain ⟨ τ, hτ₁, hτ₂ ⟩ := h; use mem_kthShadow_iff.2 ⟨ β + τ, hτ₂, τ, by aesop ⟩ ;

/-- The support of a multivariate polynomial as a `Finset`. -/
def finsuppSupport {n : ℕ} {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R) : Finset (Fin n →₀ ℕ) :=
  f.support

theorem mem_finsuppSupport_iff {n : ℕ} {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R) (m : Fin n →₀ ℕ) :
    m ∈ finsuppSupport f ↔ MvPolynomial.coeff m f ≠ 0 :=
  MvPolynomial.mem_support_iff

/-- Apply `pderiv i` exactly `k` times. -/
def pderivPow {n : ℕ} {R : Type*} [CommSemiring R]
    (i : Fin n) (k : ℕ) (f : MvPolynomial (Fin n) R) : MvPolynomial (Fin n) R :=
  (⇑(MvPolynomial.pderiv i))^[k] f

/-- The **iterated mixed partial derivative** indexed by multi-index `τ`:
applies `pderiv i` exactly `τ i` times for each variable `i`. -/
def iteratedPDeriv {n : ℕ} {R : Type*} [CommSemiring R]
    (τ : Fin n →₀ ℕ) (f : MvPolynomial (Fin n) R) : MvPolynomial (Fin n) R :=
  (List.finRange n).foldr (fun i g => pderivPow i (τ i) g) f

/-- The **derivative shadow profile** of a polynomial: maps `k` to the cardinality
of the k-th shadow of its support. -/
def derivShadowProfile {n : ℕ} {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R) : ℕ → ℕ :=
  fun k => (kthShadow (finsuppSupport f) k).card

/-- A finite set satisfies the **discrete exchange property** if for any two elements
`α, β ∈ S` and any coordinate `i` where `α i > β i`, there exists a coordinate `j`
where `β j > α j` such that `α - eᵢ + eⱼ ∈ S`.

This is a formal proxy for M-convexity of the support, capturing the symmetric
exchange axiom from discrete convex analysis and matroid theory. -/
def IsDiscreteExchangeFamily {n : ℕ} (S : Finset (Fin n →₀ ℕ)) : Prop :=
  ∀ α ∈ S, ∀ β ∈ S, ∀ i : Fin n, α i > β i →
    ∃ j : Fin n, β j > α j ∧
      α - Finsupp.single i 1 + Finsupp.single j 1 ∈ S

/-! ## Basic Properties of pderivPow -/

@[simp]
theorem pderivPow_zero {R : Type*} [CommSemiring R] (i : Fin n) (f : MvPolynomial (Fin n) R) :
    pderivPow i 0 f = f := rfl

theorem pderivPow_succ {R : Type*} [CommSemiring R] (i : Fin n) (k : ℕ)
    (f : MvPolynomial (Fin n) R) :
    pderivPow i (k + 1) f = MvPolynomial.pderiv i (pderivPow i k f) := by
  unfold pderivPow
  rw [Function.iterate_succ']
  rfl

/-! ## Coefficient Formula for Single-Variable Iterated Derivative -/

/-
The coefficient of `β` in `pderiv i` applied once to `f` equals
`(β i + 1) * coeff (β + eᵢ) f`.
-/
theorem coeff_pderiv {R : Type*} [CommSemiring R]
    (i : Fin n) (f : MvPolynomial (Fin n) R) (β : Fin n →₀ ℕ) :
    MvPolynomial.coeff β (MvPolynomial.pderiv i f) =
      (↑(β i + 1) : R) * MvPolynomial.coeff (β + Finsupp.single i 1) f := by
  -- By definition of $f$, we can write it as a sum of monomials.
  have h_sum : f = ∑ s ∈ f.support, MvPolynomial.monomial s (MvPolynomial.coeff s f) := by
    conv_lhs => rw [ f.as_sum ] ;
  -- Apply the linearity of the derivative and the fact that the derivative of a monomial is a monomial.
  have h_deriv_sum : MvPolynomial.pderiv i f = ∑ s ∈ f.support, MvPolynomial.pderiv i (MvPolynomial.monomial s (MvPolynomial.coeff s f)) := by
    conv_lhs => rw [ h_sum ];
    convert map_sum _ _ _;
    infer_instance;
  rw [ h_deriv_sum, MvPolynomial.coeff_sum ];
  rw [ Finset.sum_eq_single ( β + Finsupp.single i 1 ) ] <;> simp +contextual [ MvPolynomial.pderiv_monomial ];
  · ring;
  · intro s hs hs' hs''; rw [ ← hs'' ] at hs'; simp +decide [ Finsupp.ext_iff ] at hs';
    obtain ⟨ j, hj ⟩ := hs';
    by_cases hi : i = j <;> simp +decide [ hi, Finsupp.single_apply ] at hj ⊢;
    rcases k : s j with ( _ | k ) <;> simp +decide [ k ] at hj ⊢

/-
The coefficient of `β` in `pderivPow i k f` equals
`ascFactorial (β i + 1) k * coeff (β + k • eᵢ) f`.
-/
theorem coeff_pderivPow {R : Type*} [CommSemiring R]
    (i : Fin n) (k : ℕ) (f : MvPolynomial (Fin n) R) (β : Fin n →₀ ℕ) :
    MvPolynomial.coeff β (pderivPow i k f) =
      (↑(Nat.ascFactorial (β i + 1) k) : R) * MvPolynomial.coeff (β + k • Finsupp.single i 1) f := by
  induction' k with k ih generalizing β;
  · simp +decide [ pderivPow ];
  · convert congr_arg ( fun x : R => ( β i + 1 : R ) * x ) ( ih ( β + ( fun₀ | i => 1 ) ) ) using 1;
    · convert coeff_pderiv i ( pderivPow i k f ) β using 1;
      · exact congr_arg ( fun x => MvPolynomial.coeff β x ) ( pderivPow_succ i k f );
      · norm_cast;
    · simp +decide [ Nat.ascFactorial_eq_prod_range, add_comm, add_left_comm, add_assoc ];
      have := Finset.prod_range_succ' ( fun x : ℕ => ( x : R ) + ( 1 + ( β i : R ) ) ) k; simp_all +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.prod_range_succ ] ;
      simp +decide only [add_assoc]

/-- The ascending factorial `ascFactorial (m + 1) k` is always positive. -/
theorem ascFactorial_succ_pos (m k : ℕ) : 0 < Nat.ascFactorial (m + 1) k :=
  Nat.ascFactorial_pos m k

/-
In characteristic zero with no zero divisors, `pderivPow i k f` has nonzero
coefficient at `β` iff `f` has nonzero coefficient at `β + k • eᵢ`.
-/
theorem coeff_pderivPow_ne_zero_iff
    {R : Type*} [CommSemiring R] [NoZeroDivisors R] [CharZero R]
    (i : Fin n) (k : ℕ) (f : MvPolynomial (Fin n) R) (β : Fin n →₀ ℕ) :
    MvPolynomial.coeff β (pderivPow i k f) ≠ 0 ↔
      MvPolynomial.coeff (β + k • Finsupp.single i 1) f ≠ 0 := by
  rw [ coeff_pderivPow ];
  simp +decide [ Nat.cast_ne_zero, ascFactorial_succ_pos ];
  exact fun _ => Nat.ne_of_gt ( ascFactorial_succ_pos _ _ )

/-! ## Coefficient Formula for Full Iterated Mixed Derivative -/

/-
Auxiliary: `iteratedPDeriv` applied with the zero multi-index is the identity.
-/
@[simp]
theorem iteratedPDeriv_zero {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R) :
    iteratedPDeriv 0 f = f := by
  -- By definition of `iteratedPDeriv`, we have:
  simp [iteratedPDeriv, pderivPow, Function.iterate_zero]

/-- Helper: the coefficient of `β` at coordinate `j ≠ i` is unchanged by adding `k • single i 1`. -/
theorem finsupp_add_smul_single_apply_ne {n : ℕ} (β : Fin n →₀ ℕ) (i j : Fin n) (k : ℕ)
    (hij : i ≠ j) :
    (β + k • Finsupp.single i 1 : Fin n →₀ ℕ) j = β j := by
  simp [hij]

/-
The Finsupp `τ` equals `∑ i : Fin n, τ i • Finsupp.single i 1`.
-/
theorem finsupp_eq_sum_single (τ : Fin n →₀ ℕ) :
    τ = ∑ i : Fin n, τ i • Finsupp.single i 1 := by
  simp +decide [ Finsupp.single_apply, Finset.sum_apply' ]

/-
Helper: coefficient formula for foldr over a list of distinct variables.
-/
theorem coeff_foldr_pderivPow {R : Type*} [CommSemiring R]
    (l : List (Fin n)) (hl : l.Nodup)
    (τ : Fin n →₀ ℕ) (f : MvPolynomial (Fin n) R) (β : Fin n →₀ ℕ) :
    MvPolynomial.coeff β (l.foldr (fun i g => pderivPow i (τ i) g) f) =
      (↑(∏ i ∈ l.toFinset, Nat.ascFactorial (β i + 1) (τ i)) : R) *
        MvPolynomial.coeff (β + ∑ i ∈ l.toFinset, τ i • Finsupp.single i 1) f := by
  induction' l with i l ih generalizing β;
  · simp +decide;
  · convert coeff_pderivPow i ( τ i ) ( List.foldr ( fun i g => pderivPow i ( τ i ) g ) f l ) β using 1;
    by_cases hi : i ∈ l <;> simp_all +decide [ Finset.prod_insert, Finset.sum_insert ];
    simp +decide [ add_assoc, Finsupp.single_apply, Finset.sum_apply', Finsupp.single_apply, Finset.prod_mul_distrib, mul_assoc, Finset.prod_ite, Finset.filter_ne', Finset.filter_eq', hi ];
    exact congr_arg _ ( congr_arg₂ _ ( Finset.prod_congr rfl fun x hx => by aesop ) rfl )

/-
The coefficient transport formula for the full iterated mixed derivative:
`coeff β (iteratedPDeriv τ f) = (∏ i, ascFactorial (β i + 1) (τ i)) * coeff (β + τ) f`.
-/
theorem coeff_iteratedPDeriv {R : Type*} [CommSemiring R]
    (τ : Fin n →₀ ℕ) (f : MvPolynomial (Fin n) R) (β : Fin n →₀ ℕ) :
    MvPolynomial.coeff β (iteratedPDeriv τ f) =
      (↑(∏ i : Fin n, Nat.ascFactorial (β i + 1) (τ i)) : R) *
        MvPolynomial.coeff (β + τ) f := by
  convert coeff_foldr_pderivPow ( List.finRange n ) ( List.nodup_finRange n ) τ f β using 1;
  simp +decide [ List.toFinset_finRange, Finsupp.ext_iff ]

/-
The product of ascending factorials is always positive.
-/
theorem prod_ascFactorial_pos (β τ : Fin n →₀ ℕ) :
    0 < ∏ i : Fin n, Nat.ascFactorial (β i + 1) (τ i) := by
  exact Finset.prod_pos fun i _ => Nat.ascFactorial_pos _ _

/-
**Support criterion for iterated mixed derivatives** (characteristic zero):
`coeff β (iteratedPDeriv τ f) ≠ 0 ↔ coeff (β + τ) f ≠ 0`.
-/
theorem coeff_iteratedPDeriv_ne_zero_iff
    {R : Type*} [CommSemiring R] [NoZeroDivisors R] [CharZero R]
    (τ : Fin n →₀ ℕ) (f : MvPolynomial (Fin n) R) (β : Fin n →₀ ℕ) :
    MvPolynomial.coeff β (iteratedPDeriv τ f) ≠ 0 ↔
      MvPolynomial.coeff (β + τ) f ≠ 0 := by
  by_cases h : MvPolynomial.coeff ( β+τ ) f = 0 <;> simp_all +decide [ ne_of_gt ];
  · exact coeff_iteratedPDeriv τ f β ▸ mul_eq_zero_of_right _ h;
  · rw [ coeff_iteratedPDeriv ];
    exact mul_ne_zero ( Nat.cast_ne_zero.mpr <| ne_of_gt <| prod_ascFactorial_pos β τ ) h

/-! ## The 0-th Shadow -/

/-
The 0-th shadow of `S` is `S` itself.
-/
theorem kthShadow_zero {n : ℕ} (S : Finset (Fin n →₀ ℕ)) :
    kthShadow S 0 = S := by
  convert Finset.ext fun x => ?_;
  convert mem_kthShadow_iff' ( S := S ) ( k := 0 ) ( β := x );
  constructor <;> intro h;
  · exact ⟨ 0, by norm_num, by simpa using h ⟩;
  · obtain ⟨ τ, hτ₁, hτ₂ ⟩ := h; convert hτ₂; ext i; simp_all +decide [ Finsupp.sum ] ;

/-! ## Shadow Monotonicity -/

/-
The shadow operator is monotone in the support set.
-/
theorem kthShadow_mono {n : ℕ} {S₁ S₂ : Finset (Fin n →₀ ℕ)} (h : S₁ ⊆ S₂) (k : ℕ) :
    kthShadow S₁ k ⊆ kthShadow S₂ k := by
  exact Finset.biUnion_subset_biUnion_of_subset_left _ h

/-! ## The Semigroup Law: Shadow Composition -/

/-
**Shadow composition law (pointwise version):**
`β ∈ kthShadow (kthShadow S a) b ↔ β ∈ kthShadow S (a + b)`.

This says the shadow operator forms a genuine discrete flow: composing
an a-step shadow with a b-step shadow yields an (a+b)-step shadow.
The proof decomposes a total-mass-(a+b) multi-index into mass-a and mass-b parts.
-/
theorem mem_kthShadow_add_iff {n : ℕ} {S : Finset (Fin n →₀ ℕ)} {a b : ℕ}
    {β : Fin n →₀ ℕ} :
    β ∈ kthShadow (kthShadow S a) b ↔ β ∈ kthShadow S (a + b) := by
  rw [ mem_kthShadow_iff', mem_kthShadow_iff' ];
  constructor <;> intro h;
  · obtain ⟨ τ, hτ₁, hτ₂ ⟩ := h; rw [ mem_kthShadow_iff' ] at hτ₂; obtain ⟨ τ', hτ'₁, hτ'₂ ⟩ := hτ₂; use τ + τ'; simp_all +decide [ add_assoc, Finsupp.sum_add_index' ] ;
    ring;
  · obtain ⟨ τ, hτ₁, hτ₂ ⟩ := h;
    -- We need to find a τ₁ ≤ τ with sum τ₁ = a. This can be done by choosing any τ₁ ≤ τ with sum τ₁ = a (and then τ₂ = τ - τ₁ has sum b).
    obtain ⟨τ₁, hτ₁_le, hτ₁_sum⟩ : ∃ τ₁ : Fin n →₀ ℕ, τ₁ ≤ τ ∧ τ₁.sum (fun _ m => m) = a := by
      -- We can construct such a τ₁ by iteratively subtracting 1 from the largest component of τ until the sum is reduced to a.
      have h_subtract : ∀ {τ : Fin n →₀ ℕ} {a : ℕ}, a ≤ τ.sum (fun _ m => m) → ∃ τ₁ : Fin n →₀ ℕ, τ₁ ≤ τ ∧ τ₁.sum (fun _ m => m) = a := by
        intros τ a ha;
        exact?;
      exact h_subtract ( by linarith );
    refine' ⟨ τ - τ₁, _, _ ⟩;
    · have h_sum_split : (τ.sum (fun _ m => m)) = (τ₁.sum (fun _ m => m)) + ((τ - τ₁).sum (fun _ m => m)) := by
        rw [ ← Finsupp.sum_add_index' ] <;> aesop;
      linarith;
    · refine' mem_kthShadow_iff'.mpr ⟨ τ₁, hτ₁_sum, _ ⟩;
      convert hτ₂ using 1;
      rw [ add_assoc, tsub_add_cancel_of_le hτ₁_le ]

/-- **Shadow composition law (set equality):**
`kthShadow (kthShadow S a) b = kthShadow S (a + b)`. -/
theorem kthShadow_add {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (a b : ℕ) :
    kthShadow (kthShadow S a) b = kthShadow S (a + b) := by
  ext β; exact mem_kthShadow_add_iff

/-! ## The Exact k-th Shadow Theorem -/

/-
**The exact k-th shadow theorem:**
`β` belongs to the k-th shadow of `Supp(f)` if and only if there exists
a multi-index `τ` of total mass `k` such that `β` appears in the support
of the `τ`-th mixed partial derivative of `f`.

This is the main result: iterated differentiation has an exact combinatorial
footprint on exponent sets, governed precisely by the shadow operator.
-/
theorem mem_kthShadow_iff_exists_iteratedDerivative
    {n : ℕ} {R : Type*} [CommSemiring R] [NoZeroDivisors R] [CharZero R]
    (f : MvPolynomial (Fin n) R) (k : ℕ) (β : Fin n →₀ ℕ) :
    β ∈ kthShadow (finsuppSupport f) k ↔
      ∃ τ : Fin n →₀ ℕ,
        τ.sum (fun _ m => m) = k ∧
        β ∈ finsuppSupport (iteratedPDeriv τ f) := by
  convert mem_kthShadow_iff' ( S := ( MvPolynomial.support f ) ) ( k := k ) ( β := β ) using 1;
  convert Iff.rfl using 3 ; simp +decide [ finsuppSupport, mem_finsuppSupport_iff, coeff_iteratedPDeriv_ne_zero_iff ]

/-- The derivative shadow profile equals the k-th shadow cardinality. -/
theorem derivShadowProfile_eq {n : ℕ} {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R) (k : ℕ) :
    derivShadowProfile f k = (kthShadow (finsuppSupport f) k).card := rfl

/-! ## Cross-Domain: Exchange Families and Shadow Geometry -/

/-
Any singleton set satisfies the exchange property vacuously.
-/
theorem isDiscreteExchangeFamily_singleton {n : ℕ} (α : Fin n →₀ ℕ) :
    IsDiscreteExchangeFamily {α} := by
  intro α' hα' β' hβ' i; aesop;

/-- The empty set satisfies the exchange property vacuously. -/
theorem isDiscreteExchangeFamily_empty {n : ℕ} :
    IsDiscreteExchangeFamily (∅ : Finset (Fin n →₀ ℕ)) := by
  intro α hα; simp at hα

/-- The 0-th shadow of an exchange family preserves the exchange property. -/
theorem isDiscreteExchangeFamily_kthShadow_zero {n : ℕ}
    {S : Finset (Fin n →₀ ℕ)} (hS : IsDiscreteExchangeFamily S) :
    IsDiscreteExchangeFamily (kthShadow S 0) := by
  rwa [kthShadow_zero]

/-! ## Shadow of Empty and Universal Sets -/

/-- The shadow of the empty set is empty. -/
@[simp]
theorem kthShadow_empty {n : ℕ} (k : ℕ) :
    kthShadow (∅ : Finset (Fin n →₀ ℕ)) k = ∅ := by
  simp [kthShadow]

/-
The 1-st shadow of a singleton.
-/
theorem kthShadow_one_singleton {n : ℕ} (α : Fin n →₀ ℕ) :
    kthShadow {α} 1 =
      ((Finset.Iic α).filter (fun τ => τ.sum (fun _ m => m) = 1)).image (α - ·) := by
  unfold kthShadow; aesop;

/-! ## Shadow of Unions -/

/-
The shadow distributes over unions of support sets.
-/
theorem kthShadow_union {n : ℕ} (S₁ S₂ : Finset (Fin n →₀ ℕ)) (k : ℕ) :
    kthShadow (S₁ ∪ S₂) k = kthShadow S₁ k ∪ kthShadow S₂ k := by
  unfold kthShadow; aesop;

/-- The iterated derivative of the zero polynomial is zero. -/
@[simp]
theorem iteratedPDeriv_zero_poly {R : Type*} [CommSemiring R]
    (τ : Fin n →₀ ℕ) : iteratedPDeriv τ (0 : MvPolynomial (Fin n) R) = 0 := by
  simp only [iteratedPDeriv]
  induction (List.finRange n) with
  | nil => rfl
  | cons i l ih =>
    simp only [List.foldr_cons]
    induction (τ i) with
    | zero => simpa [pderivPow] using ih
    | succ k ihk => rw [pderivPow_succ]; simp [ihk]

/-- Degree bound: every element of the k-th shadow arises from an ancestor
of degree ≥ k, and has degree reduced by exactly k from that ancestor. -/
theorem exists_ancestor_of_mem_kthShadow {n : ℕ} {S : Finset (Fin n →₀ ℕ)} {k : ℕ}
    {β : Fin n →₀ ℕ} (hβ : β ∈ kthShadow S k) :
    ∃ α ∈ S, ∃ τ : Fin n →₀ ℕ, τ ≤ α ∧ τ.sum (fun _ m => m) = k ∧ β = α - τ := by
  exact mem_kthShadow_iff.mp hβ

/-
The k-th shadow is empty when k exceeds the degree of every element in S.
-/
theorem kthShadow_eq_empty_of_lt_degree {n : ℕ} {S : Finset (Fin n →₀ ℕ)} {k : ℕ}
    (hk : ∀ α ∈ S, α.degree < k) :
    kthShadow S k = ∅ := by
  ext β;
  simp [mem_kthShadow_iff'];
  intro x hx; specialize hk ( β + x ) ; simp_all +decide [ degree ] ;
  contrapose! hk; simp_all +decide [ Finsupp.sum_add_index' ] ;
  rw [ ← hx, Finsupp.sum_of_support_subset ];
  exacts [ Finset.sum_le_sum fun i hi => Nat.le_add_left _ _, fun i hi => by simp_all +decide [ Finsupp.mem_support_iff ], fun _ _ => rfl ]

/-- The support of the zero polynomial has empty shadow. -/
theorem kthShadow_finsuppSupport_zero {n : ℕ} {R : Type*} [CommSemiring R] (k : ℕ) :
    kthShadow (finsuppSupport (0 : MvPolynomial (Fin n) R)) k = ∅ := by
  simp [finsuppSupport, kthShadow]

/-! ## Shadow Profile Monotonicity -/

/-- The shadow operator contracts: kthShadow S (k+1) ⊆ kthShadow S k when
every element of the (k+1)-shadow can also witness via a mass-k multi-index.
More precisely, this holds because kthShadow S (k+1) = kthShadow (kthShadow S 1) k
and kthShadow S 1 ⊆ S need not hold, but we can prove:
For any S, if β ∈ kthShadow S (k+1), then β ∈ kthShadow (kthShadow S 1) k. -/
theorem kthShadow_succ_eq {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (k : ℕ) :
    kthShadow S (k + 1) = kthShadow (kthShadow S 1) k := by
  rw [kthShadow_add, Nat.add_comm]

end IteratedShadowGeometry