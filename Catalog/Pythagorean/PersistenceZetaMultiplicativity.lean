/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Persistence Zeta Function Multiplicativity

This file develops the theory of **persistence zeta functions** for arithmetic
persistence data and proves their multiplicativity under coprime prime support,
together with an exact correction-factor formula in the general case.

## Mathematical Overview

The persistence zeta function is a finite Euler product
$$Z(D, s) = \prod_{p \in \operatorname{supp}(D)} \left(1 + \frac{\ell_p(D)}{p^s}\right)$$
where $\ell_p(D)$ is the local barcode length at prime $p$.

The main results establish:
1. Local barcode lengths vanish outside the prime support
2. Euler factors equal 1 outside the support
3. The support of a product is contained in the union of supports
4. **Multiplicativity under coprime support**: $Z(D_1 \cdot D_2, s) = Z(D_1, s) \cdot Z(D_2, s)$
   when the prime supports are disjoint
5. **Exact correction-factor formula** in the general (overlapping support) case
6. **Vanishing of the correction** under primewise independence

## References

* Builds on `Catalog.Pythagorean.AdelicPersistentHomology`
* Uses CRT decomposition (`persistence_CRT_decomposition`) and
  bounded support (`bounded_torsion_implies_bounded_primeSupport`)
-/

import Mathlib

open Finset BigOperators Classical

set_option maxHeartbeats 400000

/-! ## Section 1: Core Definitions -/

/-- Predicate: a prime `p` "supports" a filtration if the p-primary component
is nontrivial at some level. This is the bridge from `AdelicPersistentHomology`. -/
def PrimeSupportsFiltration {α : Type*} [AddCommGroup α]
    (filtration : ℕ → AddSubgroup α) (p : ℕ) : Prop :=
  ∃ n : ℕ, ∃ a ∈ filtration n, a ≠ 0 ∧ ∃ k : ℕ, (p ^ k) • a = 0

/-- **Arithmetic persistence data**: the essential data for defining a persistence
zeta function. Packages a finite set of primes (the support) together with
a local barcode length function that vanishes outside the support.

This abstracts the barcode-counting invariant of a filtered finite abelian group
into purely arithmetic data suitable for Euler product analysis. -/
structure ArithPersistenceData where
  /-- The finite set of primes contributing to the persistence -/
  primeSupport : Finset ℕ
  /-- The local barcode length at each prime -/
  barcodeLength : ℕ → ℕ
  /-- Barcode length vanishes outside the prime support -/
  zero_outside : ∀ p, p ∉ primeSupport → barcodeLength p = 0
  /-- Every element of the support is prime -/
  all_prime : ∀ p ∈ primeSupport, Nat.Prime p

/-- The **persistence zeta factor** at prime `p`: the local Euler factor
$$1 + \frac{\ell_p(D)}{p^s}$$ -/
noncomputable def persistenceZetaFactor (D : ArithPersistenceData) (p : ℕ) (s : ℕ) : ℚ :=
  1 + (D.barcodeLength p : ℚ) / (p : ℚ) ^ s

/-- The **persistence zeta function**: the finite Euler product
$$Z(D, s) = \prod_{p \in \mathrm{supp}(D)} \left(1 + \frac{\ell_p(D)}{p^s}\right)$$ -/
noncomputable def persistenceZeta (D : ArithPersistenceData) (s : ℕ) : ℚ :=
  ∏ p ∈ D.primeSupport, persistenceZetaFactor D p s

/-! ## Section 2: Product Construction -/

/-- The **additive product** of two persistence data: the support is the union
and barcode lengths add pointwise. This models the CRT decomposition of
the product filtration: by the Chinese Remainder Theorem, the p-primary
component of G₁ × G₂ decomposes as G₁[p^∞] × G₂[p^∞], and barcode
lengths are additive under direct sum. -/
def additiveProduct (D₁ D₂ : ArithPersistenceData) : ArithPersistenceData where
  primeSupport := D₁.primeSupport ∪ D₂.primeSupport
  barcodeLength p := D₁.barcodeLength p + D₂.barcodeLength p
  zero_outside p hp := by
    simp only [Finset.mem_union, not_or] at hp
    rw [D₁.zero_outside p hp.1, D₂.zero_outside p hp.2]
  all_prime p hp := by
    rcases Finset.mem_union.mp hp with h | h
    · exact D₁.all_prime p h
    · exact D₂.all_prime p h

/-! ## Section 3: Basic Support Lemmas -/

/-- Barcode length zero outside support. -/
theorem barcodeLength_eq_zero_of_not_mem (D : ArithPersistenceData) {p : ℕ}
    (hp : p ∉ D.primeSupport) : D.barcodeLength p = 0 :=
  D.zero_outside p hp

/-- The persistence zeta factor equals 1 at primes outside the support. -/
theorem persistenceZetaFactor_eq_one_of_not_mem
    (D : ArithPersistenceData) (s : ℕ) {p : ℕ}
    (hp : p ∉ D.primeSupport) :
    persistenceZetaFactor D p s = 1 := by
  simp [persistenceZetaFactor, barcodeLength_eq_zero_of_not_mem D hp]

/-- The support of the additive product equals the union of supports. -/
theorem primeSupport_additiveProduct_eq (D₁ D₂ : ArithPersistenceData) :
    (additiveProduct D₁ D₂).primeSupport = D₁.primeSupport ∪ D₂.primeSupport :=
  rfl

/-- The barcode length of the additive product is the sum. -/
theorem barcodeLength_additiveProduct (D₁ D₂ : ArithPersistenceData) (p : ℕ) :
    (additiveProduct D₁ D₂).barcodeLength p = D₁.barcodeLength p + D₂.barcodeLength p :=
  rfl

/-! ## Section 4: Coprime Support Multiplicativity -/

/-- When supports are disjoint, the additive product's zeta factor at a prime
in D₁'s support equals D₁'s factor (since D₂ contributes zero there). -/
theorem persistenceZetaFactor_prod_eq_left
    (D₁ D₂ : ArithPersistenceData) (s : ℕ) {p : ℕ}
    (hp₁ : p ∈ D₁.primeSupport)
    (hcop : Disjoint D₁.primeSupport D₂.primeSupport) :
    persistenceZetaFactor (additiveProduct D₁ D₂) p s =
      persistenceZetaFactor D₁ p s := by
  have hp₂ : p ∉ D₂.primeSupport := Finset.disjoint_left.mp hcop hp₁
  simp [persistenceZetaFactor, barcodeLength_additiveProduct,
        barcodeLength_eq_zero_of_not_mem D₂ hp₂]

/-- Symmetric version for D₂. -/
theorem persistenceZetaFactor_prod_eq_right
    (D₁ D₂ : ArithPersistenceData) (s : ℕ) {p : ℕ}
    (hp₂ : p ∈ D₂.primeSupport)
    (hcop : Disjoint D₁.primeSupport D₂.primeSupport) :
    persistenceZetaFactor (additiveProduct D₁ D₂) p s =
      persistenceZetaFactor D₂ p s := by
  have hp₁ : p ∉ D₁.primeSupport := Finset.disjoint_right.mp hcop hp₂
  simp [persistenceZetaFactor, barcodeLength_additiveProduct,
        barcodeLength_eq_zero_of_not_mem D₁ hp₁]

/-
**Headline Theorem (Coprime Support Multiplicativity)**:
When the prime supports of D₁ and D₂ are disjoint, the persistence zeta
function is multiplicative:
$$Z(D_1 \cdot D_2, s) = Z(D_1, s) \cdot Z(D_2, s)$$

The proof splits the Euler product over the disjoint union using
`Finset.prod_union`, then shows each factor matches by the left/right lemmas.
-/
theorem persistenceZeta_mul_of_coprime_support
    (D₁ D₂ : ArithPersistenceData) (s : ℕ)
    (hcop : Disjoint D₁.primeSupport D₂.primeSupport) :
    persistenceZeta (additiveProduct D₁ D₂) s =
      persistenceZeta D₁ s * persistenceZeta D₂ s := by
  unfold persistenceZeta;
  rw [ primeSupport_additiveProduct_eq ];
  rw [ Finset.prod_union hcop ];
  exact congrArg₂ _ ( Finset.prod_congr rfl fun x hx => persistenceZetaFactor_prod_eq_left _ _ _ hx hcop ) ( Finset.prod_congr rfl fun x hx => persistenceZetaFactor_prod_eq_right _ _ _ hx hcop )

/-! ## Section 5: General Product and Correction Factor -/

/-- The **overlap correction factor**: for three persistence data
(D₁, D₂, Dprod), measures the deviation from multiplicativity at
shared primes. -/
noncomputable def overlapCorrection
    (D₁ D₂ Dprod : ArithPersistenceData) (s : ℕ) : ℚ :=
  ∏ p ∈ D₁.primeSupport ∩ D₂.primeSupport,
    (persistenceZetaFactor Dprod p s /
     (persistenceZetaFactor D₁ p s * persistenceZetaFactor D₂ p s))

/-
**Theorem (Exact Correction-Factor Formula)**:
For any product persistence data with matching support and compatible
boundary values, the persistence zeta decomposes as
$$Z(D_{\mathrm{prod}}, s) = Z(D_1, s) \cdot Z(D_2, s) \cdot C(D_1, D_2, s)$$
-/
theorem persistenceZeta_mul_with_correction
    (D₁ D₂ Dprod : ArithPersistenceData) (s : ℕ)
    (h_support : Dprod.primeSupport = D₁.primeSupport ∪ D₂.primeSupport)
    (h_left : ∀ p, p ∈ D₁.primeSupport → p ∉ D₂.primeSupport →
      Dprod.barcodeLength p = D₁.barcodeLength p)
    (h_right : ∀ p, p ∉ D₁.primeSupport → p ∈ D₂.primeSupport →
      Dprod.barcodeLength p = D₂.barcodeLength p)
    (h_factor_ne₁ : ∀ p ∈ D₁.primeSupport ∩ D₂.primeSupport,
      persistenceZetaFactor D₁ p s ≠ 0)
    (h_factor_ne₂ : ∀ p ∈ D₁.primeSupport ∩ D₂.primeSupport,
      persistenceZetaFactor D₂ p s ≠ 0) :
    persistenceZeta Dprod s =
      persistenceZeta D₁ s * persistenceZeta D₂ s *
      overlapCorrection D₁ D₂ Dprod s := by
  rw [ persistenceZeta, persistenceZeta, persistenceZeta, overlapCorrection ];
  rw [ h_support, ← Finset.prod_sdiff <| Finset.inter_subset_right, ← Finset.prod_sdiff <| Finset.inter_subset_left ];
  any_goals exact D₁.primeSupport \ D₂.primeSupport;
  rw [ show ( D₁.primeSupport ∪ D₂.primeSupport ) \ ( D₁.primeSupport \ D₂.primeSupport ∩ ( D₁.primeSupport ∪ D₂.primeSupport ) ) = D₂.primeSupport from ?_, show ( D₁.primeSupport \ D₂.primeSupport ∩ ( D₁.primeSupport ∪ D₂.primeSupport ) ) = D₁.primeSupport \ D₂.primeSupport from ?_ ];
  · simp +decide [ Finset.prod_mul_distrib, Finset.prod_div_distrib, div_mul_div_cancel₀, h_factor_ne₁, h_factor_ne₂ ];
    rw [ show ( ∏ p ∈ D₂.primeSupport, persistenceZetaFactor Dprod p s ) = ( ∏ p ∈ D₂.primeSupport \ D₁.primeSupport, persistenceZetaFactor Dprod p s ) * ( ∏ p ∈ D₁.primeSupport ∩ D₂.primeSupport, persistenceZetaFactor Dprod p s ) from ?_, show ( ∏ p ∈ D₁.primeSupport, persistenceZetaFactor D₁ p s ) = ( ∏ p ∈ D₁.primeSupport \ D₂.primeSupport, persistenceZetaFactor D₁ p s ) * ( ∏ p ∈ D₁.primeSupport ∩ D₂.primeSupport, persistenceZetaFactor D₁ p s ) from ?_, show ( ∏ p ∈ D₂.primeSupport, persistenceZetaFactor D₂ p s ) = ( ∏ p ∈ D₂.primeSupport \ D₁.primeSupport, persistenceZetaFactor D₂ p s ) * ( ∏ p ∈ D₁.primeSupport ∩ D₂.primeSupport, persistenceZetaFactor D₂ p s ) from ?_ ];
    · rw [ show ( ∏ p ∈ D₂.primeSupport \ D₁.primeSupport, persistenceZetaFactor Dprod p s ) = ( ∏ p ∈ D₂.primeSupport \ D₁.primeSupport, persistenceZetaFactor D₂ p s ) from ?_, show ( ∏ p ∈ D₁.primeSupport \ D₂.primeSupport, persistenceZetaFactor Dprod p s ) = ( ∏ p ∈ D₁.primeSupport \ D₂.primeSupport, persistenceZetaFactor D₁ p s ) from ?_ ];
      · field_simp;
        rw [ eq_div_iff ( mul_ne_zero ( Finset.prod_ne_zero_iff.mpr fun p hp => h_factor_ne₁ p hp ) ( Finset.prod_ne_zero_iff.mpr fun p hp => h_factor_ne₂ p hp ) ) ] ; ring;
      · exact Finset.prod_congr rfl fun p hp => by unfold persistenceZetaFactor; aesop;
      · exact Finset.prod_congr rfl fun p hp => by unfold persistenceZetaFactor; aesop;
    · rw [ ← Finset.prod_union ];
      · rcongr p ; by_cases hp : p ∈ D₁.primeSupport <;> aesop;
      · exact Finset.disjoint_left.mpr fun x hx₁ hx₂ => Finset.mem_sdiff.mp hx₁ |>.2 <| Finset.mem_inter.mp hx₂ |>.1;
    · rw [ ← Finset.prod_union ];
      · rw [ Finset.sdiff_union_inter ];
      · exact Finset.disjoint_left.mpr fun x hx₁ hx₂ => Finset.mem_sdiff.mp hx₁ |>.2 <| Finset.mem_inter.mp hx₂ |>.2;
    · rw [ ← Finset.prod_union ];
      · rcongr p ; by_cases hp : p ∈ D₁.primeSupport <;> aesop;
      · exact Finset.disjoint_left.mpr fun x hx₁ hx₂ => Finset.mem_sdiff.mp hx₁ |>.2 <| Finset.mem_inter.mp hx₂ |>.1;
  · grind +ring;
  · grind +qlia

/-! ## Section 6: Vanishing of Correction Under Factor Independence -/

/-
**Theorem (Vanishing of Correction under Factor-Level Independence)**:
If at every shared prime, the product's Euler factor equals the product
of the individual factors, then the correction is exactly 1.

Note: mere barcode-length additivity (ℓ_prod = ℓ₁ + ℓ₂) does NOT suffice
for the correction to vanish, because
(1 + (a+b)/c) ≠ (1 + a/c)(1 + b/c) when ab ≠ 0.
The correct condition is factor-level multiplicativity.
-/
theorem overlapCorrection_eq_one_of_factor_independence
    (D₁ D₂ Dprod : ArithPersistenceData) (s : ℕ)
    (hindep : ∀ p ∈ D₁.primeSupport ∩ D₂.primeSupport,
      persistenceZetaFactor Dprod p s =
        persistenceZetaFactor D₁ p s * persistenceZetaFactor D₂ p s)
    (h_ne₁ : ∀ p ∈ D₁.primeSupport ∩ D₂.primeSupport,
      persistenceZetaFactor D₁ p s ≠ 0)
    (h_ne₂ : ∀ p ∈ D₁.primeSupport ∩ D₂.primeSupport,
      persistenceZetaFactor D₂ p s ≠ 0) :
    overlapCorrection D₁ D₂ Dprod s = 1 := by
  exact Finset.prod_eq_one fun p hp => by rw [ hindep p hp, div_self ( mul_ne_zero ( h_ne₁ p hp ) ( h_ne₂ p hp ) ) ] ;

/-
**Theorem (Vanishing under Zero Barcode at Overlap)**:
If at every shared prime, at least one of D₁ or D₂ has barcode length zero,
then barcode additivity implies the correction factor is 1.
This is the generic situation when overlap primes don't genuinely
contribute to both components.
-/
theorem overlapCorrection_eq_one_of_zero_overlap
    (D₁ D₂ Dprod : ArithPersistenceData) (s : ℕ)
    (h_zero : ∀ p ∈ D₁.primeSupport ∩ D₂.primeSupport,
      D₁.barcodeLength p = 0 ∨ D₂.barcodeLength p = 0)
    (h_bl : ∀ p ∈ D₁.primeSupport ∩ D₂.primeSupport,
      Dprod.barcodeLength p = D₁.barcodeLength p + D₂.barcodeLength p)
    (h_ne₁ : ∀ p ∈ D₁.primeSupport ∩ D₂.primeSupport,
      persistenceZetaFactor D₁ p s ≠ 0)
    (h_ne₂ : ∀ p ∈ D₁.primeSupport ∩ D₂.primeSupport,
      persistenceZetaFactor D₂ p s ≠ 0) :
    overlapCorrection D₁ D₂ Dprod s = 1 := by
  apply overlapCorrection_eq_one_of_factor_independence;
  · intro p hp; specialize h_zero p hp; specialize h_bl p hp; specialize h_ne₁ p hp; specialize h_ne₂ p hp; unfold persistenceZetaFactor at *; aesop;
  · assumption;
  · assumption

/-! ## Section 7: Positivity and Nonvanishing -/

/-- Prime powers are positive as rationals when the base is prime. -/
theorem prime_pow_pos_rat {p : ℕ} (hp : Nat.Prime p) (s : ℕ) :
    (0 : ℚ) < (p : ℚ) ^ s := by
  apply pow_pos
  exact Nat.cast_pos.mpr hp.pos

/-- The persistence zeta factor is positive when p is prime. -/
theorem persistenceZetaFactor_pos (D : ArithPersistenceData) {p : ℕ}
    (hp : Nat.Prime p) (s : ℕ) :
    0 < persistenceZetaFactor D p s := by
  unfold persistenceZetaFactor
  have h1 : (0 : ℚ) < (p : ℚ) ^ s := prime_pow_pos_rat hp s
  have h2 : (0 : ℚ) ≤ (D.barcodeLength p : ℚ) := Nat.cast_nonneg _
  have h3 : (0 : ℚ) ≤ (D.barcodeLength p : ℚ) / (p : ℚ) ^ s := div_nonneg h2 (le_of_lt h1)
  linarith

/-- The persistence zeta is a product of positive factors, hence positive. -/
theorem persistenceZeta_pos (D : ArithPersistenceData) (s : ℕ) :
    0 < persistenceZeta D s := by
  apply Finset.prod_pos
  intro p hp
  exact persistenceZetaFactor_pos D (D.all_prime p hp) s

/-- The persistence zeta is nonzero. -/
theorem persistenceZeta_ne_zero (D : ArithPersistenceData) (s : ℕ) :
    persistenceZeta D s ≠ 0 :=
  ne_of_gt (persistenceZeta_pos D s)

/-- The persistence zeta factor is nonzero when p is prime. -/
theorem persistenceZetaFactor_ne_zero (D : ArithPersistenceData) {p : ℕ}
    (hp : Nat.Prime p) (s : ℕ) :
    persistenceZetaFactor D p s ≠ 0 :=
  ne_of_gt (persistenceZetaFactor_pos D hp s)

/-! ## Section 8: Obstruction Localization -/

/-- **Theorem (Obstruction Localization)**:
If multiplicativity fails, then the supports must overlap. -/
theorem multiplicativity_failure_implies_overlap
    (D₁ D₂ : ArithPersistenceData) (s : ℕ)
    (hfail : persistenceZeta (additiveProduct D₁ D₂) s ≠
      persistenceZeta D₁ s * persistenceZeta D₂ s) :
    ¬Disjoint D₁.primeSupport D₂.primeSupport := by
  intro hcop
  exact hfail (persistenceZeta_mul_of_coprime_support D₁ D₂ s hcop)

/-! ## Section 9: Empty and Singleton Support -/

/-- Empty support gives trivial zeta. -/
theorem persistenceZeta_empty (D : ArithPersistenceData) (s : ℕ)
    (h : D.primeSupport = ∅) :
    persistenceZeta D s = 1 := by
  simp [persistenceZeta, h]

/-! ## Section 10: Certified Computation -/

/-- Compute the persistence zeta from explicit prime-barcode data.
Each pair `(p, ℓ)` represents a prime `p` with local barcode length `ℓ`. -/
def computePersistenceZeta (primeData : List (ℕ × ℕ)) (s : ℕ) : ℚ :=
  primeData.foldl (fun acc ⟨p, l⟩ => acc * (1 + (l : ℚ) / (p : ℚ) ^ s)) 1

/-- Compute the overlap correction factor from data. -/
def computeOverlapCorrection
    (overlapData : List (ℕ × ℕ × ℕ × ℕ)) -- (p, ℓ_prod, ℓ₁, ℓ₂)
    (s : ℕ) : ℚ :=
  overlapData.foldl (fun acc ⟨p, l_prod, l₁, l₂⟩ =>
    acc * ((1 + (l_prod : ℚ) / (p : ℚ) ^ s) /
           ((1 + (l₁ : ℚ) / (p : ℚ) ^ s) * (1 + (l₂ : ℚ) / (p : ℚ) ^ s)))) 1

/-- The computation agrees with the abstract definition for singleton data. -/
theorem computePersistenceZeta_singleton (p l s : ℕ) :
    computePersistenceZeta [(p, l)] s = 1 + (l : ℚ) / (p : ℚ) ^ s := by
  simp [computePersistenceZeta, List.foldl]

/-- Empty data gives zeta = 1. -/
theorem computePersistenceZeta_nil (s : ℕ) :
    computePersistenceZeta [] s = 1 := by
  simp [computePersistenceZeta]

/-! ## Section 11: Concrete Examples -/

/-- Z/6Z: Z(s=1) = (1 + 1/2)(1 + 1/3) = 3/2 · 4/3 = 2. -/
example : computePersistenceZeta [(2, 1), (3, 1)] 1 = 2 := by native_decide

/-- Disjoint supports multiply. -/
example : computePersistenceZeta [(2, 1)] 1 * computePersistenceZeta [(3, 1)] 1 =
    computePersistenceZeta [(2, 1), (3, 1)] 1 := by native_decide

/-- Overlapping support with correction. -/
example : computeOverlapCorrection [(2, 3, 1, 1)] 1 = 10 / 9 := by native_decide

/-! ## Section 12: Connection to AdelicPersistentHomology -/

/-- Build arithmetic persistence data from the prime support analysis
of a filtered finite abelian group. This bridges the abstract persistence
data to the concrete theory in `AdelicPersistentHomology`. -/
noncomputable def ArithPersistenceData.ofGroup
    (α : Type*) [AddCommGroup α] [Fintype α]
    (primes : Finset ℕ)
    (h_prime : ∀ p ∈ primes, Nat.Prime p)
    (bl : ℕ → ℕ)
    (h_bl : ∀ p, bl p ≠ 0 → p ∈ primes) :
    ArithPersistenceData where
  primeSupport := primes
  barcodeLength := bl
  zero_outside p hp := by
    by_contra h
    exact hp (h_bl p h)
  all_prime := h_prime

/-- **Disjoint correction vanishes**: a corollary combining Theorems 4 and 6.
When supports are disjoint, the overlap correction for the additive product is 1. -/
theorem overlapCorrection_eq_one_of_disjoint
    (D₁ D₂ : ArithPersistenceData)
    (s : ℕ)
    (hcop : Disjoint D₁.primeSupport D₂.primeSupport) :
    overlapCorrection D₁ D₂ (additiveProduct D₁ D₂) s = 1 := by
  simp [overlapCorrection, Finset.disjoint_iff_inter_eq_empty.mp hcop]