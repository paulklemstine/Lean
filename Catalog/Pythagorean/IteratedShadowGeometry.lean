/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Iterated Shadow Geometry for Multivariate Polynomial Supports

This file develops a theory of **iterated support shadows** for multivariate
polynomials, establishing that higher-order mixed partial differentiation has an
exact combinatorial footprint on exponent sets.

## Main Definitions

* `kthShadow` — The `k`-th downward shadow of a finset of exponent vectors:
  all vectors obtainable by subtracting a multi-index of total mass `k`.
* `iteratedPDeriv` — The mixed partial derivative `D^τ f` for a multi-index `τ`,
  defined by its exact action on coefficients.
* `derivShadowProfile` — The shadow profile `k ↦ |Shadow_k(Supp(f))|`.
* `IsDiscreteExchangeFamily` — A finite-set symmetric exchange property
  capturing M-convex / matroid-like structure on support sets.

## Main Results

* `coeff_iteratedPDeriv` — Exact coefficient formula for mixed derivatives.
* `coeff_iteratedPDeriv_ne_zero_iff` — Support criterion: in characteristic zero,
  `coeff β (D^τ f) ≠ 0 ↔ coeff (β + τ) f ≠ 0`.
* `mem_kthShadow_iff_exists_iteratedDerivative` — The exact k-th shadow theorem.
* `kthShadow_zero` — The 0-th shadow is the identity.
* `kthShadow_add` — Shadows satisfy a semigroup/flow law.
* `iteratedPDeriv_single_eq_pderiv` — Validates agreement with `MvPolynomial.pderiv`.
-/

open MvPolynomial Finsupp BigOperators Finset

noncomputable section

namespace IteratedShadowGeometry

variable {n : ℕ}

/-! ## Total mass of a multi-index -/

/-- The total mass (sum of all entries) of a multi-index. -/
abbrev totalMass (τ : Fin n →₀ ℕ) : ℕ := τ.sum (fun _ m => m)

@[simp]
theorem totalMass_zero : totalMass (0 : Fin n →₀ ℕ) = 0 := by
  simp [totalMass, Finsupp.sum]

@[simp]
theorem totalMass_single (i : Fin n) (k : ℕ) :
    totalMass (Finsupp.single i k) = k := by
  simp [totalMass, Finsupp.sum_single_index]

theorem totalMass_add (τ₁ τ₂ : Fin n →₀ ℕ) :
    totalMass (τ₁ + τ₂) = totalMass τ₁ + totalMass τ₂ := by
  simp only [totalMass]
  rw [Finsupp.sum_add_index] <;> simp

theorem totalMass_eq_zero_iff (τ : Fin n →₀ ℕ) :
    totalMass τ = 0 ↔ τ = 0 := by
  constructor
  · intro h
    ext i
    simp only [Finsupp.coe_zero, Pi.zero_apply]
    by_contra hi
    have : i ∈ τ.support := Finsupp.mem_support_iff.mpr (by omega)
    have hpos := Finset.sum_pos_iff_of_nonneg (fun j _ => Nat.zero_le (τ j)) |>.mpr ⟨i, this, by omega⟩
    simp only [totalMass, Finsupp.sum] at h
    omega
  · intro h; simp [h]

/-! ## k-th Shadow Definition -/

/-- The **k-th shadow** of a finite set `S` of exponent vectors.
`β ∈ kthShadow S k` iff there exists `α ∈ S` with `β ≤ α` and the total
mass of `α - β` equals `k`. -/
def kthShadow (S : Finset (Fin n →₀ ℕ)) (k : ℕ) : Finset (Fin n →₀ ℕ) :=
  S.biUnion (fun α => (Finset.Iic α).filter (fun β => totalMass (α - β) = k))

theorem mem_kthShadow_iff {S : Finset (Fin n →₀ ℕ)} {k : ℕ} {β : Fin n →₀ ℕ} :
    β ∈ kthShadow S k ↔ ∃ α ∈ S, β ≤ α ∧ totalMass (α - β) = k := by
  simp [kthShadow, Finset.mem_biUnion, Finset.mem_filter, Finset.mem_Iic]

/-! ## Basic Shadow Properties -/

/-
The 0-th shadow of `S` is `S` itself.
-/
theorem kthShadow_zero (S : Finset (Fin n →₀ ℕ)) :
    kthShadow S 0 = S := by
  ext β; simp [kthShadow];
  constructor <;> intro h <;> simp_all +decide [ totalMass_eq_zero_iff ] ;
  · obtain ⟨ a, ha₁, ha₂, ha₃ ⟩ := h; rw [ tsub_eq_zero_iff_le ] at ha₃; simp_all +decide [ le_antisymm ha₃ ha₂ ] ;
  · exact ⟨ β, h, le_rfl, tsub_self β ⟩

/-- The shadow is monotone in the support set. -/
theorem kthShadow_mono {S₁ S₂ : Finset (Fin n →₀ ℕ)} (h : S₁ ⊆ S₂) (k : ℕ) :
    kthShadow S₁ k ⊆ kthShadow S₂ k := by
  intro β hβ
  rw [mem_kthShadow_iff] at hβ ⊢
  obtain ⟨α, hα, hle, hmass⟩ := hβ
  exact ⟨α, h hα, hle, hmass⟩

/-- The kth shadow of the empty set is empty. -/
@[simp]
theorem kthShadow_empty (k : ℕ) :
    kthShadow (∅ : Finset (Fin n →₀ ℕ)) k = ∅ := by
  simp [kthShadow]

/-! ## Iterated Mixed Partial Derivative -/

/-- The **iterated mixed partial derivative** `D^τ f` of a multivariate polynomial,
for a multi-index `τ : Fin n →₀ ℕ`.

Defined by its exact action on monomials:
`D^τ (c · X^α) = (∏ᵢ descFactorial(α(i), τ(i))) · c · X^(α-τ)` when `τ ≤ α`,
and `0` otherwise. -/
def iteratedPDeriv {R : Type*} [CommSemiring R] (τ : Fin n →₀ ℕ)
    (f : MvPolynomial (Fin n) R) : MvPolynomial (Fin n) R :=
  f.sum (fun (m : Fin n →₀ ℕ) (c : R) =>
    if τ ≤ m then
      MvPolynomial.monomial (m - τ)
        ((↑(∏ i : Fin n, Nat.descFactorial (m i) (τ i)) : R) * c)
    else 0)

/-! ## Coefficient Formula -/

/-
**Coefficient transport formula for mixed derivatives.**
The coefficient of `β` in `D^τ f` equals a descending factorial product
times the coefficient of `β + τ` in `f`.
-/
theorem coeff_iteratedPDeriv {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R) (β τ : Fin n →₀ ℕ) :
    MvPolynomial.coeff β (iteratedPDeriv τ f) =
      (↑(∏ i : Fin n, Nat.descFactorial ((β + τ) i) (τ i)) : R) *
        MvPolynomial.coeff (β + τ) f := by
  unfold iteratedPDeriv;
  rw [ MvPolynomial.sum_def ] ; simp_all +decide [ MvPolynomial.coeff_sum ];
  rw [ Finset.sum_eq_single ( β + τ ) ];
  · simp +decide [ MvPolynomial.coeff_monomial ];
  · intro b hb hne; split_ifs <;> simp_all +decide [ MvPolynomial.coeff_monomial ] ;
    exact fun h => False.elim <| hne <| by rw [ ← h, tsub_add_cancel_of_le ‹_› ] ;
  · aesop

/-
The descending factorial product is always positive.
-/
theorem descFactorial_prod_pos (β τ : Fin n →₀ ℕ) :
    0 < ∏ i : Fin n, Nat.descFactorial ((β + τ) i) (τ i) := by
  exact Finset.prod_pos fun i _ => Nat.descFactorial_pos.mpr ( by simp +decide )

/-
**Support criterion for mixed derivatives.**
-/
theorem coeff_iteratedPDeriv_ne_zero_iff {R : Type*} [CommRing R] [NoZeroDivisors R]
    [CharZero R] (f : MvPolynomial (Fin n) R) (β τ : Fin n →₀ ℕ) :
    MvPolynomial.coeff β (iteratedPDeriv τ f) ≠ 0 ↔
      MvPolynomial.coeff (β + τ) f ≠ 0 := by
  rw [coeff_iteratedPDeriv];
  simp +zetaDelta at *;
  exact fun h => mod_cast descFactorial_prod_pos β τ |> ne_of_gt

/-! ## Validation -/

/-
Our `iteratedPDeriv` for `τ = single i 1` agrees with `MvPolynomial.pderiv i`.
-/
theorem iteratedPDeriv_single_eq_pderiv {R : Type*} [CommSemiring R]
    (i : Fin n) (f : MvPolynomial (Fin n) R) :
    iteratedPDeriv (Finsupp.single i 1) f = MvPolynomial.pderiv i f := by
  refine' Finset.sum_congr rfl fun x hx => _ ; by_cases hi : 1 ≤ x i <;> simp +decide [ hi, Pi.single_apply ] ; ring;
  · simp +decide [ Finset.prod_eq_mul_prod_diff_singleton ( Finset.mem_univ i ), Nat.descFactorial_succ, mul_comm, mul_assoc, mul_left_comm, smul_monomial ];
    rw [ if_neg ( by linarith ) ] ; simp +decide [ Nat.descFactorial_one, Finset.prod_eq_one, Finsupp.single_apply ] ; ring;
    rw [ Finset.prod_eq_one ] <;> aesop;
  · aesop

/-
`iteratedPDeriv` for `τ = 0` is the identity.
-/
theorem iteratedPDeriv_zero {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R) :
    iteratedPDeriv (0 : Fin n →₀ ℕ) f = f := by
  unfold iteratedPDeriv;
  simp +decide [ MvPolynomial.sum_def ]

/-! ## The Exact k-th Shadow Theorem -/

/-
**The exact k-th shadow theorem.**
`β` lies in the k-th shadow of `Supp(f)` if and only if there exists a
multi-index `τ` of total mass `k` such that `β` is in the support of `D^τ f`.
-/
theorem mem_kthShadow_iff_exists_iteratedDerivative
    {R : Type*} [CommRing R] [NoZeroDivisors R] [CharZero R]
    (f : MvPolynomial (Fin n) R) (β : Fin n →₀ ℕ) (k : ℕ) :
    β ∈ kthShadow f.support k ↔
      ∃ τ : Fin n →₀ ℕ,
        totalMass τ = k ∧
        β ∈ (iteratedPDeriv τ f).support := by
  constructor <;> intro h;
  · obtain ⟨ α, hα, hβα, hαβ ⟩ := mem_kthShadow_iff.mp h;
    refine' ⟨ α - β, hαβ, _ ⟩;
    simp_all +decide [ MvPolynomial.mem_support_iff ];
    convert coeff_iteratedPDeriv_ne_zero_iff f β ( α - β ) |>.2 _;
    rwa [ add_tsub_cancel_of_le hβα ];
  · obtain ⟨ τ, rfl, hτ ⟩ := h;
    refine' Finset.mem_biUnion.mpr ⟨ β + τ, _, _ ⟩ <;> simp_all +decide [ mem_kthShadow_iff ];
    exact fun h => hτ <| by rw [ coeff_iteratedPDeriv ] ; simp +decide [ h ] ;

/-! ## Splitting Lemma -/

/-
**Splitting lemma**: any multi-index of total mass `a + b` can be decomposed
into the sum of two multi-indices of masses `a` and `b` respectively.
-/
theorem finsupp_totalMass_split (τ : Fin n →₀ ℕ) (a b : ℕ)
    (h : totalMass τ = a + b) :
    ∃ τ₁ τ₂ : Fin n →₀ ℕ,
      τ₁ + τ₂ = τ ∧ totalMass τ₁ = a ∧ totalMass τ₂ = b := by
  induction' a with a ih generalizing τ;
  · exact ⟨ 0, τ, by norm_num, by norm_num, by linarith ⟩;
  · -- Since $a + 1 + b > 0$, there exists some $i$ such that $\tau(i) > 0$.
    obtain ⟨i, hi⟩ : ∃ i : Fin n, τ i > 0 := by
      contrapose! h;
      simp_all +decide [ show τ = 0 from Finsupp.ext fun i => le_antisymm ( h i ) ( Nat.zero_le _ ) ];
      linarith;
    -- Let $\tau' = \tau - \text{single } i 1$. Then $\tau'.\text{sum } = a + b$.
    set τ' : Fin n →₀ ℕ := τ - Finsupp.single i 1
    have hτ'_sum : totalMass τ' = a + b := by
      simp +zetaDelta at *;
      grind +suggestions;
    obtain ⟨ τ₁, τ₂, h₁, h₂, h₃ ⟩ := ih τ' hτ'_sum; use τ₁ + Finsupp.single i 1, τ₂; simp_all +decide [ totalMass_add ] ;
    convert congr_arg ( fun x => x + Finsupp.single i 1 ) h₁ using 1;
    · abel1;
    · rw [ tsub_add_cancel_of_le ] ; aesop;

/-! ## Semigroup Law for Shadows -/

/-
Subtraction decomposes for ordered Finsupp elements.
-/
theorem finsupp_tsub_add_of_le {α γ β : Fin n →₀ ℕ}
    (h1 : β ≤ γ) (h2 : γ ≤ α) :
    α - β = (α - γ) + (γ - β) := by
  ext i; simp +decide [ h1, h2 ] ;
  rw [ tsub_add_tsub_cancel ( h2 i ) ( h1 i ) ]

/-
Total mass decomposes under ordered subtraction.
-/
theorem totalMass_tsub_add {α γ β : Fin n →₀ ℕ}
    (h1 : β ≤ γ) (h2 : γ ≤ α) :
    totalMass (α - β) = totalMass (α - γ) + totalMass (γ - β) := by
  rw [ ← totalMass_add, finsupp_tsub_add_of_le h1 h2 ]

/-
**Semigroup law for shadows.**
`Shadow_b(Shadow_a(S)) = Shadow_{a+b}(S)`.
-/
theorem kthShadow_add (S : Finset (Fin n →₀ ℕ)) (a b : ℕ) :
    kthShadow (kthShadow S a) b = kthShadow S (a + b) := by
  ext β
  simp [mem_kthShadow_iff];
  constructor <;> intro h;
  · obtain ⟨ α, ⟨ γ, hγ, hαγ, hα ⟩, hβα, hβ ⟩ := h;
    refine' ⟨ γ, hγ, hβα.trans hαγ, _ ⟩;
    rw [ ← hα, ← hβ, totalMass_tsub_add ] <;> aesop;
  · obtain ⟨ α, hα₁, hα₂, hα₃ ⟩ := h
    obtain ⟨ τ₁, τ₂, hτ₁, hτ₂, hτ ⟩ := finsupp_totalMass_split (α - β) a b hα₃; use β + τ₂; simp_all +decide [ add_comm, add_left_comm, add_assoc ] ;
    refine' ⟨ α, hα₁, _, _ ⟩ <;> simp_all +decide [ add_comm, add_left_comm, add_assoc, Finsupp.le_def ];
    · intro i; replace hτ₁ := congr_arg ( fun x => x i ) hτ₁; simp_all +decide [ add_comm, add_left_comm, add_assoc ] ;
      linarith [ Nat.sub_add_cancel ( hα₂ i ) ];
    · convert hτ₂ using 2 ; ext i ; replace hτ₁ := congr_arg ( fun x => x i ) hτ₁ ; simp_all +decide [ add_comm, add_left_comm, add_assoc ] ; omega;

/-! ## Shadow Profile -/

/-- The **derivative shadow profile**: cardinality of the k-th shadow. -/
def derivShadowProfile {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R) (k : ℕ) : ℕ :=
  (kthShadow f.support k).card

/-- Shadow profile at 0 equals the number of monomials. -/
theorem derivShadowProfile_zero {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R) :
    derivShadowProfile f 0 = f.support.card := by
  simp [derivShadowProfile, kthShadow_zero]

/-! ## Discrete Exchange Family -/

/-- **Discrete exchange family (M-convexity proxy).**
A finite set `S` of exponent vectors satisfies the symmetric exchange property. -/
def IsDiscreteExchangeFamily (S : Finset (Fin n →₀ ℕ)) : Prop :=
  ∀ α ∈ S, ∀ β ∈ S, ∀ i : Fin n,
    β i < α i →
    ∃ j : Fin n, α j < β j ∧
      α - Finsupp.single i 1 + Finsupp.single j 1 ∈ S

/-
Any singleton is trivially an exchange family.
-/
theorem isDiscreteExchangeFamily_singleton (α : Fin n →₀ ℕ) :
    IsDiscreteExchangeFamily {α} := by
  intro α' hα' β' hβ' i hi; aesop;

/-! ## Additional Properties -/

/-
If `k` exceeds every element's mass, the shadow is empty.
-/
theorem kthShadow_eq_empty_of_large {S : Finset (Fin n →₀ ℕ)} {k : ℕ}
    (hk : ∀ α ∈ S, totalMass α < k) :
    kthShadow S k = ∅ := by
  ext β;
  simp +zetaDelta at *;
  intro hβ; rw [ mem_kthShadow_iff ] at hβ; obtain ⟨ α, hαS, hαβ, hαβk ⟩ := hβ; have := hk α hαS; simp_all +decide [ Finsupp.sum_fintype ] ;
  exact absurd hαβk ( ne_of_lt ( lt_of_le_of_lt ( Finset.sum_le_sum fun _ _ => Nat.sub_le _ _ ) ( hk α hαS ) ) )

/-
Membership in the 1-shadow.
-/
theorem kthShadow_one_mem_iff {S : Finset (Fin n →₀ ℕ)} {β : Fin n →₀ ℕ} :
    β ∈ kthShadow S 1 ↔
    ∃ α ∈ S, ∃ i : Fin n, 0 < α i ∧ β = α - Finsupp.single i 1 := by
  refine' ⟨ fun h => _, fun h => _ ⟩;
  · obtain ⟨α, hαS, hαβ⟩ : ∃ α ∈ S, β ≤ α ∧ totalMass (α - β) = 1 := by
      grind +suggestions;
    -- Since `totalMass (α - β) = 1`, there exists exactly one index `i` such that `(α - β) i = 1` and `(α - β) j = 0` for all `j ≠ i`.
    obtain ⟨i, hi⟩ : ∃ i : Fin n, (α - β) i = 1 ∧ ∀ j : Fin n, j ≠ i → (α - β) j = 0 := by
      have h_unique : ∃ i : Fin n, (α - β) i > 0 ∧ ∀ j : Fin n, j ≠ i → (α - β) j = 0 := by
        have h_sum : ∑ i : Fin n, (α - β) i = 1 := by
          convert hαβ.2 using 1;
          simp +decide [ totalMass, Finsupp.sum_fintype ]
        obtain ⟨i, hi⟩ : ∃ i : Fin n, (α - β) i > 0 := by
          contrapose! h_sum; aesop;
        exact ⟨ i, hi, fun j hj => by rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ i ) ] at h_sum; exact Nat.eq_zero_of_not_pos fun hj' => by linarith [ Finset.single_le_sum ( fun a _ => Nat.zero_le ( ( α - β ) a ) ) ( Finset.mem_sdiff.mpr ⟨ Finset.mem_univ j, by aesop ⟩ : j ∈ Finset.univ \ { i } ) ] ⟩;
      obtain ⟨ i, hi₁, hi₂ ⟩ := h_unique; use i; simp_all +decide [ Finsupp.sum_fintype ] ;
      rw [ Finset.sum_eq_single i ] at hαβ <;> aesop;
    refine' ⟨ α, hαS, i, _, _ ⟩;
    · contrapose! hi; aesop;
    · ext j; by_cases hj : j = i <;> simp_all +decide [ Finsupp.single_apply ] ;
      · grind;
      · exact Eq.symm ( Nat.sub_eq_zero_iff_le.mp ( hi.2 j hj ) |> le_antisymm <| hαβ.1 j );
  · rcases h with ⟨ α, hα, i, hi, rfl ⟩;
    refine' Finset.mem_biUnion.mpr ⟨ α, hα, _ ⟩;
    simp +decide [ totalMass ];
    rw [ show α - ( α - Finsupp.single i 1 ) = Finsupp.single i 1 from ?_ ];
    · rw [ Finsupp.sum_single_index ] ; norm_num;
    · ext j; by_cases hj : j = i <;> simp +decide [ hj ] ;
      grind

end IteratedShadowGeometry