/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Iterated Shadow Geometry for Multivariate Polynomial Supports

This file develops the theory of **iterated support shadows** for multivariate
polynomials: the exact combinatorial footprint of higher-order differentiation
on exponent sets. The central result is that the support of all `k`-th order
mixed partial derivatives of a polynomial `f` is exactly the `k`-th shadow
of the Newton support of `f`.

## Main Definitions

* `mass` — total degree (sum of coordinates) of a multi-index
* `kthShadow` — the `k`-th downward shadow of a finset of multi-indices
* `iteratedPDeriv` — iterated mixed partial derivative indexed by a multi-index
* `derivShadowProfile` — cardinality of the `k`-th shadow as a function of `k`
* `IsDiscreteExchangeFamily` — finite-set symmetric exchange property

## Main Results

* `coeff_pderiv_single` — coefficient formula for a single partial derivative
* `coeff_pderiv_iterate` — coefficient formula for iterated single-variable derivative
* `coeff_iteratedPDeriv` — full multi-index coefficient transport formula
* `coeff_iteratedPDeriv_ne_zero_iff` — support criterion: nonvanishing iff ancestor nonvanishes
* `mem_kthShadow_iff_exists_iteratedDerivative` — **the k-th shadow theorem**
* `kthShadow_zero` — the 0-th shadow is the original set
* `kthShadow_mono` — shadow is monotone under set inclusion
* `mem_kthShadow_add_iff` — semigroup law: shadows compose additively

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open MvPolynomial Finsupp BigOperators Finset Classical

noncomputable section

namespace IteratedShadowGeometry

/-! ## Basic Definitions -/

/-- The **mass** (total degree) of a multi-index `τ : Fin n →₀ ℕ` is the sum
of all its coordinates. -/
def mass {n : ℕ} (τ : Fin n →₀ ℕ) : ℕ := τ.sum (fun _ m => m)

@[simp]
theorem mass_zero {n : ℕ} : mass (0 : Fin n →₀ ℕ) = 0 := by
  simp [mass]

theorem mass_single {n : ℕ} (i : Fin n) (k : ℕ) :
    mass (Finsupp.single i k) = k := by
  simp [mass, Finsupp.sum_single_index]

theorem mass_add {n : ℕ} (σ τ : Fin n →₀ ℕ) :
    mass (σ + τ) = mass σ + mass τ := by
  simp [mass, Finsupp.sum_add_index']

/-- The **k-th shadow** of a finset `S` of multi-indices: all exponent vectors
obtainable by subtracting a multi-index of total mass `k` from an element of `S`.
Formally, `β ∈ kthShadow S k` iff `∃ α ∈ S, ∃ τ ≤ α, mass τ = k ∧ β = α - τ`. -/
def kthShadow {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (k : ℕ) :
    Finset (Fin n →₀ ℕ) :=
  S.biUnion fun α =>
    ((Finset.Iic α).filter fun τ => mass τ = k).image fun τ => α - τ

/-- The **iterated partial derivative** of a multivariate polynomial indexed by
a multi-index `τ`. Applies `(∂/∂xᵢ)^(τ i)` for each coordinate `i` in order.
Since mixed partials commute for polynomials, the order does not matter. -/
def iteratedPDeriv {n : ℕ} {R : Type*} [CommSemiring R]
    (τ : Fin n →₀ ℕ) (f : MvPolynomial (Fin n) R) : MvPolynomial (Fin n) R :=
  (List.finRange n).foldl
    (fun p i => ((pderiv i : Derivation R _ _) : _ → _)^[τ i] p) f

/-- The **derivative shadow profile** of a polynomial: the cardinality of the
`k`-th shadow of its support. -/
def derivShadowProfile {n : ℕ} {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R) (k : ℕ) : ℕ :=
  (kthShadow f.support k).card

/-- A finset `S` of multi-indices satisfies the **discrete exchange property**
if for any two elements `α, β ∈ S` and any coordinate `i` with `α i > β i`,
there exists a coordinate `j` with `β j > α j` such that
`α - eᵢ + eⱼ ∈ S`. This is a finitary analogue of M-convexity from discrete
convex analysis. -/
def IsDiscreteExchangeFamily {n : ℕ} (S : Finset (Fin n →₀ ℕ)) : Prop :=
  ∀ α ∈ S, ∀ β ∈ S, ∀ i : Fin n,
    α i > β i →
    ∃ j : Fin n, β j > α j ∧
      α - Finsupp.single i 1 + Finsupp.single j 1 ∈ S

/-! ## Membership in kthShadow -/

theorem mem_kthShadow_iff {n : ℕ} {S : Finset (Fin n →₀ ℕ)} {k : ℕ}
    {β : Fin n →₀ ℕ} :
    β ∈ kthShadow S k ↔
      ∃ α ∈ S, ∃ τ : Fin n →₀ ℕ, τ ≤ α ∧ mass τ = k ∧ β = α - τ := by
  simp only [kthShadow, Finset.mem_biUnion, Finset.mem_image, Finset.mem_filter,
    Finset.mem_Iic]
  constructor
  · rintro ⟨α, hα, τ, ⟨hτα, hτk⟩, rfl⟩
    exact ⟨α, hα, τ, hτα, hτk, rfl⟩
  · rintro ⟨α, hα, τ, hτα, hτk, rfl⟩
    exact ⟨α, hα, τ, ⟨hτα, hτk⟩, rfl⟩

/-! ## kthShadow at k = 0 -/

theorem kthShadow_zero {n : ℕ} (S : Finset (Fin n →₀ ℕ)) :
    kthShadow S 0 = S := by
  unfold kthShadow;
  simp +decide [ Finset.ext_iff, mem_kthShadow_iff ];
  intro a; constructor <;> intro ha <;> simp_all +decide [ mass ] ;
  · obtain ⟨ b, hb, c, hc, rfl ⟩ := ha; simp_all +decide [ Finsupp.sum ] ;
    convert hb using 1 ; ext i ; simp +decide [ hc.2 ];
  · exact ⟨ a, ha, 0, ⟨ by norm_num, by norm_num ⟩, by norm_num ⟩

/-! ## Monotonicity of kthShadow -/

theorem kthShadow_mono {n : ℕ} {S₁ S₂ : Finset (Fin n →₀ ℕ)} (h : S₁ ⊆ S₂) (k : ℕ) :
    kthShadow S₁ k ⊆ kthShadow S₂ k := by
  exact Finset.biUnion_subset_biUnion_of_subset_left _ h

/-! ## Coefficient Formula: Single Variable Iterated Derivative -/

/-
Coefficient of `m` in the single partial derivative `∂ᵢf` equals
`(m i + 1) * coeff(m + eᵢ, f)`.
-/
theorem coeff_pderiv_single {n : ℕ} {R : Type*} [CommSemiring R]
    (i : Fin n) (f : MvPolynomial (Fin n) R) (m : Fin n →₀ ℕ) :
    MvPolynomial.coeff m (MvPolynomial.pderiv i f) =
      (↑(m i + 1) : R) * MvPolynomial.coeff (m + Finsupp.single i 1) f := by
  induction' f using MvPolynomial.induction_on' with n f g hf hg f g hf hg;
  · by_cases hi : n i = 0 <;> simp_all +decide [ MvPolynomial.coeff_monomial, pderiv_monomial ];
    · intro h; replace h := congr_arg ( fun x => x i ) h; simp_all +decide ;
    · split_ifs <;> simp_all +decide [ Finsupp.ext_iff, Finsupp.single_apply ];
      · ring;
      · grind;
  · simp +decide [ *, mul_add ]

/-
Coefficient of `m` in the `k`-fold iterated partial derivative
`(∂/∂xᵢ)^k f` equals the ascending factorial product times the
coefficient at the shifted multi-index.
-/
theorem coeff_pderiv_iterate {n : ℕ} {R : Type*} [CommSemiring R]
    (i : Fin n) (k : ℕ) (f : MvPolynomial (Fin n) R) (m : Fin n →₀ ℕ) :
    MvPolynomial.coeff m (((pderiv i : Derivation R _ _) : _ → _)^[k] f) =
      (∏ j ∈ Finset.range k, (↑(m i + j + 1) : R)) *
        MvPolynomial.coeff (m + Finsupp.single i k) f := by
  induction' k with k ih generalizing m <;> simp_all +decide [ Function.iterate_succ_apply', Finset.prod_range_succ' ];
  convert congr_arg ( fun x : R => ( m i + 1 : R ) * x ) ( ih ( m + Finsupp.single i 1 ) ) using 1 ; ring!;
  · convert coeff_pderiv_single i ( ( pderiv i ) ^[ k ] f ) m using 1 ; ring!;
    grind +splitImp;
  · simp +decide [ add_comm, add_left_comm, add_assoc, Finsupp.single_apply ] ; ring!;

/-! ## Full Multi-Index Coefficient Formula -/

/-
Helper: coefficient formula for foldl over a sublist of coordinates.
For a nodup list `l` of coordinates, the foldl applying `(∂ᵢ)^[τ i]` for each
`i ∈ l` satisfies the product coefficient formula over those coordinates.
-/
private theorem coeff_foldl_pderiv_list {n : ℕ} {R : Type*} [CommSemiring R]
    (τ : Fin n →₀ ℕ) (f : MvPolynomial (Fin n) R) (β : Fin n →₀ ℕ)
    (l : List (Fin n)) (hl : l.Nodup) :
    MvPolynomial.coeff β
      (l.foldl (fun p i => ((pderiv i : Derivation R _ _) : _ → _)^[τ i] p) f) =
      (∏ i ∈ l.toFinset, ∏ j ∈ Finset.range (τ i), ((β i + j + 1 : ℕ) : R)) *
        MvPolynomial.coeff (β + l.toFinset.sum (fun i => Finsupp.single i (τ i))) f := by
  induction' l using List.reverseRecOn with hd tl ih generalizing β <;> simp_all +decide [ Finset.prod_insert, Finset.sum_insert ];
  by_cases h : tl ∈ hd.toFinset <;> simp_all +decide [ List.nodup_append ];
  · exact False.elim ( hl.2 _ h rfl );
  · have := coeff_pderiv_iterate tl ( τ tl ) ( List.foldl ( fun p i => ( pderiv i ) ^[τ i] p ) f hd ) β; simp_all +decide [ add_comm, add_left_comm, add_assoc ] ;
    simp +decide [ mul_assoc, Finsupp.single_apply ];
    exact congr_arg _ ( congr_arg₂ _ ( Finset.prod_congr rfl fun x hx => Finset.prod_congr rfl fun y hy => by aesop ) rfl )

/-- **Multi-index coefficient transport formula.**
The coefficient of `β` in the iterated derivative `∂^τ f` equals the product
of ascending factorial factors times the coefficient of `β + τ` in `f`.

This is the engine that drives the entire shadow theory: each derivative
coordinate contributes an independent, nonzero scalar factor. -/
theorem coeff_iteratedPDeriv {n : ℕ} {R : Type*} [CommSemiring R]
    (τ : Fin n →₀ ℕ) (f : MvPolynomial (Fin n) R) (β : Fin n →₀ ℕ) :
    MvPolynomial.coeff β (iteratedPDeriv τ f) =
      (∏ i : Fin n, ∏ j ∈ Finset.range (τ i), (↑(β i + j + 1) : R)) *
        MvPolynomial.coeff (β + τ) f := by
  unfold iteratedPDeriv
  rw [coeff_foldl_pderiv_list τ f β (List.finRange n) (List.nodup_finRange n)]
  simp [List.toFinset_finRange, Finsupp.univ_sum_single]

/-! ## Ascending Factorial Positivity -/

/-
The product of ascending factorial factors is always positive as a natural number.
-/
theorem ascFactorial_prod_pos {n : ℕ} (β τ : Fin n →₀ ℕ) :
    0 < ∏ i : Fin n, ∏ j ∈ Finset.range (τ i), (β i + j + 1) := by
  exact Finset.prod_pos fun i hi => Finset.prod_pos fun j hj => Nat.succ_pos _

/-! ## Support Criterion -/

/-
**Support criterion for iterated derivatives.** In characteristic zero,
the coefficient of `β` in `∂^τ f` is nonzero if and only if the coefficient
of `β + τ` in `f` is nonzero. The scalar factor (a product of ascending
factorials) is always a positive natural number, hence nonzero in char zero.
-/
theorem coeff_iteratedPDeriv_ne_zero_iff {n : ℕ} {R : Type*}
    [CommSemiring R] [NoZeroSMulDivisors ℕ R] [CharZero R] [Nontrivial R]
    (τ : Fin n →₀ ℕ) (f : MvPolynomial (Fin n) R) (β : Fin n →₀ ℕ) :
    MvPolynomial.coeff β (iteratedPDeriv τ f) ≠ 0 ↔
      MvPolynomial.coeff (β + τ) f ≠ 0 := by
  rw [ coeff_iteratedPDeriv ];
  -- Since the product of positive integers is positive, we can conclude that the product is nonzero.
  have h_prod_pos : 0 < ∏ i : Fin n, (∏ j ∈ Finset.range (τ i), (β i + j + 1)) := by
    exact Finset.prod_pos fun i _ => Finset.prod_pos fun j _ => Nat.succ_pos _;
  norm_cast;
  grind +suggestions

/-! ## The k-th Shadow Theorem -/

/-
**The k-th Shadow Theorem (pointwise membership).**
For a polynomial `f` over a char-zero domain, a multi-index `β` belongs to
the `k`-th shadow of `Supp(f)` if and only if there exists a multi-index `τ`
of mass `k` such that `β` appears in the support of `∂^τ f`.

This is the fundamental equivalence: iterated differentiation has an exact
combinatorial footprint on exponent sets, governed entirely by the downward
shadow geometry of the Newton support.
-/
theorem mem_kthShadow_iff_exists_iteratedDerivative
    {n : ℕ} {R : Type*} [CommSemiring R] [NoZeroSMulDivisors ℕ R]
    [Nontrivial R] [CharZero R]
    (f : MvPolynomial (Fin n) R) (β : Fin n →₀ ℕ) (k : ℕ) :
    β ∈ kthShadow f.support k ↔
      ∃ τ : Fin n →₀ ℕ,
        mass τ = k ∧
        MvPolynomial.coeff β (iteratedPDeriv τ f) ≠ 0 := by
  constructor <;> intro h;
  · obtain ⟨ α, hα, τ, hτ, hβ ⟩ := mem_kthShadow_iff.mp h;
    refine' ⟨ τ, hβ.1, _ ⟩;
    convert coeff_iteratedPDeriv_ne_zero_iff τ f β |>.2 _;
    rw [ hβ.2, tsub_add_cancel_of_le hτ ] ; aesop;
  · obtain ⟨ τ, rfl, h ⟩ := h;
    -- By the support criterion, if `coeff β (iteratedPDeriv τ f) ≠ 0`, then `β + τ ∈ f.support`.
    have h_support : β + τ ∈ f.support := by
      convert MvPolynomial.mem_support_iff.mpr ( coeff_iteratedPDeriv_ne_zero_iff τ f β |>.1 h ) using 1;
    refine' mem_kthShadow_iff.mpr ⟨ β + τ, h_support, τ, _, _, _ ⟩ <;> simp +decide [ mass ]

/-! ## Semigroup Law for Shadows -/

/-
Helper: any multi-index of mass `a + b` can be decomposed as a sum of
multi-indices of mass `a` and `b` respectively.
-/
theorem exists_mass_decomposition {n : ℕ} (τ : Fin n →₀ ℕ) (a b : ℕ)
    (h : mass τ = a + b) :
    ∃ τ₁ τ₂ : Fin n →₀ ℕ, τ₁ + τ₂ = τ ∧ mass τ₁ = a ∧ mass τ₂ = b := by
  induction' a with a ih generalizing τ;
  · exact ⟨ 0, τ, by norm_num, by norm_num, by linarith ⟩;
  · -- Since mass τ = a + 1 + b ≥ 1, τ ≠ 0, so there exists some i with τ i ≥ 1.
    obtain ⟨i, hi⟩ : ∃ i : Fin n, τ i ≥ 1 := by
      contrapose! h; simp_all +decide [ mass ] ;
      simp +decide [ show τ = 0 from Finsupp.ext h ] ; linarith;
    -- Let τ' = τ - single i 1. Then mass τ' = mass τ - 1 = a + b.
    set τ' : Fin n →₀ ℕ := τ - Finsupp.single i 1
    have hτ' : mass τ' = a + b := by
      convert congr_arg ( fun x : ℕ => x - 1 ) h using 1;
      · unfold mass;
        rw [ Finsupp.sum_of_support_subset ];
        case s => exact τ.support;
        · simp +zetaDelta at *;
          rw [ Finsupp.sum ];
          rw [ Finset.sum_eq_add_sum_diff_singleton ( show i ∈ τ.support from by aesop ) ];
          rw [ Finset.sum_eq_add_sum_diff_singleton ( show i ∈ τ.support from by aesop ) ];
          rw [ Finset.sum_congr rfl fun x hx => by rw [ Finsupp.single_apply ] ] ; simp +decide [ Finset.sum_add_distrib, add_comm, add_left_comm, add_assoc, Nat.sub_add_comm hi ];
          rw [ add_comm, Finset.sum_congr rfl fun x hx => by aesop ];
        · intro j hj; contrapose! hj; aesop;
        · grind;
      · exact?;
    obtain ⟨ τ₁, τ₂, h₁, h₂, h₃ ⟩ := ih τ' hτ';
    refine' ⟨ τ₁ + Finsupp.single i 1, τ₂, _, _, _ ⟩ <;> simp_all +decide [ add_assoc, Finsupp.single_add ];
    · convert congr_arg ( fun x => x + Finsupp.single i 1 ) h₁ using 1;
      · abel1;
      · ext j; by_cases hj : j = i <;> aesop;
    · unfold mass at *;
      rw [ Finsupp.sum_add_index' ] <;> aesop

/-
**Semigroup law for shadows (pointwise membership).**
The `(a+b)`-th shadow equals the `b`-th shadow of the `a`-th shadow.
This says the shadow operator is a genuine discrete flow:
applying shadow-`a` then shadow-`b` is the same as applying shadow-`(a+b)`.
-/
theorem mem_kthShadow_add_iff {n : ℕ} {S : Finset (Fin n →₀ ℕ)}
    {a b : ℕ} {β : Fin n →₀ ℕ} :
    β ∈ kthShadow S (a + b) ↔ β ∈ kthShadow (kthShadow S a) b := by
  -- By definition of kthShadow, we can rewrite the membership conditions using the existence of certain multi-indices.
  simp [mem_kthShadow_iff];
  constructor;
  · rintro ⟨ α, hα, τ, hτ, hτ', rfl ⟩;
    obtain ⟨ τ₁, τ₂, h₁, h₂, h₃ ⟩ := exists_mass_decomposition τ a b hτ';
    refine' ⟨ α, τ₁, ⟨ hα, _, h₂ ⟩, τ₂, _, h₃, _ ⟩;
    · exact le_trans ( le_add_right le_rfl ) ( h₁.le.trans hτ );
    · refine' le_trans _ ( tsub_le_tsub_right hτ _ ); aesop;
    · rw [ ← h₁, tsub_add_eq_tsub_tsub ];
  · rintro ⟨ α, τ, ⟨ hα, hτ, rfl ⟩, τ', hτ', rfl, rfl ⟩;
    refine' ⟨ α, hα, τ + τ', _, _, _ ⟩ <;> simp_all +decide [ Finsupp.le_def ];
    · exact fun i => by linarith [ hτ i, hτ' i, Nat.sub_add_cancel ( hτ i ) ] ;
    · exact mass_add _ _;
    · ext i; simp +decide [ Nat.sub_sub ] ;

/-! ## Shadow Profile Properties -/

/-- The derivative shadow profile at `k = 0` equals the support size. -/
theorem derivShadowProfile_zero {n : ℕ} {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R) :
    derivShadowProfile f 0 = f.support.card := by
  simp [derivShadowProfile, kthShadow_zero]

/-- The shadow profile is monotone with respect to support inclusion. -/
theorem derivShadowProfile_mono {n : ℕ} {R : Type*} [CommSemiring R]
    {f g : MvPolynomial (Fin n) R} (h : f.support ⊆ g.support) (k : ℕ) :
    derivShadowProfile f k ≤ derivShadowProfile g k := by
  exact Finset.card_le_card (kthShadow_mono h k)

end IteratedShadowGeometry