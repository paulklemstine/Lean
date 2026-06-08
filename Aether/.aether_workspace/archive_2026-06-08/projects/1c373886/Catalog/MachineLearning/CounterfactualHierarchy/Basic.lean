/-
  # Counterfactual Number Theory: The Multiplicative Independence Hierarchy

  This module develops the theory of multiplicative independence depth for
  subsets of ℕ, establishing that the k-product-free hierarchy is strict
  and characterizing when product-freeness implies unique factorization.

  ## Main Results

  1. **Strict Hierarchy (Theorems A₃, A₄)**: For k=3 and k=4, there exist
     finite sets that are (k-1)-product-free but not k-product-free.

  2. **Counterexample to naive UFD (Theorem B)**: Even all-k-product-freeness
     does NOT imply unique factorization. Witness: {4, 8} is k-product-free
     for all k ≥ 2, but 64 = 4·4·4 = 8·8.

  3. **S-Irreducibility (Theorem C)**: k-product-freeness for all k ≥ 2
     DOES imply that elements of S are S-irreducible.

  4. **Prime Completeness (Theorem D)**: Primes are k-product-free for all k ≥ 2.

  5. **Product Shadow Disjointness (Theorem E)**: For product-free sets,
     the product shadow is disjoint from the set itself.
-/
import Mathlib

open Finset Nat

/-! ## Core Definitions -/

/-- A set S ⊆ ℕ is product-free if no product of two elements of S
    (each ≥ 2) lies in S. -/
def IsProductFree (S : Set ℕ) : Prop :=
  ∀ a b, a ∈ S → b ∈ S → a ≥ 2 → b ≥ 2 → a * b ∉ S

/-- A set S is k-product-free if no multiset of exactly k elements
    (each ≥ 2 and in S) has product in S. -/
def IsKProductFree (S : Set ℕ) (k : ℕ) : Prop :=
  ∀ (m : Multiset ℕ), (∀ x ∈ m, x ∈ S ∧ x ≥ 2) → m.card = k → m.prod ∉ S

/-- An S-factorization of n. -/
def IsFactorization (S : Set ℕ) (n : ℕ) (factors : Multiset ℕ) : Prop :=
  (∀ x ∈ factors, x ∈ S ∧ x ≥ 2) ∧ factors.prod = n

/-- Unique factorization over S. -/
def HasUniqueFactorization (S : Set ℕ) : Prop :=
  ∀ n : ℕ, ∀ f₁ f₂ : Multiset ℕ,
    IsFactorization S n f₁ → IsFactorization S n f₂ → f₁ = f₂

/-! ## Novel Definition: S-Irreducibility -/

/-- An element n is **S-irreducible** if it belongs to S and cannot be
    expressed as a product of two or more elements from S (each ≥ 2). -/
def IsIrreducibleOver (S : Set ℕ) (n : ℕ) : Prop :=
  n ∈ S ∧ ∀ (f : Multiset ℕ), IsFactorization S n f → f.card ≤ 1

/-- A set S has the **irreducibility property** if every element of S
    is S-irreducible. -/
def HasIrreducibilityProperty (S : Set ℕ) : Prop :=
  ∀ n ∈ S, IsIrreducibleOver S n

/-! ## Novel Definition: Multiplicative Independence Spectrum -/

/-- The **multiplicative independence spectrum** of S: k ↦ IsKProductFree S k.
    Primes have constant True spectrum for all k ≥ 2.
    Cramér random models typically fail at k = 2. -/
def MultIndepSpectrum (S : Set ℕ) (k : ℕ) : Prop := IsKProductFree S k

/-! ## Theorem A: The k-Product-Free Hierarchy is Strict -/

/-- {2, 3, 12} is 2-product-free. -/
theorem set_2_3_12_two_product_free :
    IsKProductFree ({2, 3, 12} : Set ℕ) 2 := by
  intro m hm hcard
  rw [Multiset.card_eq_two] at hcard
  rcases hcard with ⟨x, y, rfl⟩
  rcases hm x (by simp +decide) with ⟨hx₁, hx₂⟩
  rcases hm y (by simp +decide) with ⟨hy₁, hy₂⟩
  rcases hx₁ with (rfl | rfl | rfl) <;> rcases hy₁ with (rfl | rfl | rfl) <;>
    simp +decide at hx₂ hy₂ ⊢

/-- {2, 3, 12} is NOT 3-product-free: {2, 2, 3} has product 12 ∈ S. -/
theorem set_2_3_12_not_three_product_free :
    ¬IsKProductFree ({2, 3, 12} : Set ℕ) 3 := by
  unfold IsKProductFree
  simp [Set.mem_insert_iff, Set.mem_singleton_iff] at *
  exists {2, 2, 3}

/-- **Theorem A₃**: The hierarchy is strict at level 3. -/
theorem hierarchy_strict_at_three :
    ∃ S : Set ℕ, IsKProductFree S 2 ∧ ¬IsKProductFree S 3 :=
  ⟨{2, 3, 12}, set_2_3_12_two_product_free, set_2_3_12_not_three_product_free⟩

/-- {2, 3, 24} is 2-product-free. -/
theorem set_2_3_24_two_product_free :
    IsKProductFree ({2, 3, 24} : Set ℕ) 2 := by
  intro m hm
  rw [Multiset.card_eq_two]; aesop

/-
{2, 3, 24} is 3-product-free.
-/
theorem set_2_3_24_three_product_free :
    IsKProductFree ({2, 3, 24} : Set ℕ) 3 := by
  intro s hs hs'; have := hs' ▸ Multiset.card_map ( fun x => x ) s; simp_all +decide ;
  rcases s with ⟨ ⟨ a, ha ⟩, ⟨ b, hb ⟩, ⟨ c, hc ⟩ ⟩ <;> simp_all +decide;
  rw [ List.length_eq_two ] at hs' ; aesop

/-- {2, 3, 24} is NOT 4-product-free: {2, 2, 2, 3} has product 24 ∈ S. -/
theorem set_2_3_24_not_four_product_free :
    ¬IsKProductFree ({2, 3, 24} : Set ℕ) 4 := by
  intro h
  specialize h {2, 2, 2, 3}
  norm_num at h

/-- **Theorem A₄**: The hierarchy is strict at level 4. -/
theorem hierarchy_strict_at_four :
    ∃ S : Set ℕ, IsKProductFree S 2 ∧ IsKProductFree S 3 ∧ ¬IsKProductFree S 4 :=
  ⟨{2, 3, 24}, set_2_3_24_two_product_free, set_2_3_24_three_product_free,
    set_2_3_24_not_four_product_free⟩

/-! ## Theorem B: All-k-Product-Free Does NOT Imply UFD -/

/-
**Surprising discovery**: Even being k-product-free for ALL k ≥ 2 does not
  guarantee unique factorization. The set {4, 8} is the minimal counterexample.

  Verification that {4, 8} is k-product-free for all k ≥ 2:
  Products of k elements from {4, 8} have the form 2^(2a + 3b) where a + b = k.
  The exponent 2a + 3b = 2a + 3(k-a) = 3k - a ranges over [2k, 3k].
  For k ≥ 2, the minimum exponent is 2k ≥ 4 > 3, so the product is never
  4 (= 2²) or 8 (= 2³). Hence {4, 8} is k-product-free for all k ≥ 2.

  But 64 = 4·4·4 = 8·8 gives two distinct factorizations!
  This shows that the gap between primes and random models is even deeper
  than the infinite k-product-free hierarchy captures.

{4, 8} is k-product-free for all k ≥ 2.
-/
theorem set_4_8_all_k_product_free :
    ∀ k, k ≥ 2 → IsKProductFree ({4, 8} : Set ℕ) k := by
  intros k hk; intro f; contrapose! hk; simp_all +decide [ IsKProductFree ] ;
  rcases f with ⟨ ⟨ l ⟩ ⟩ <;> simp_all +decide [ List.prod_eq_zero_iff ];
  rename_i x y; rcases y with ( _ | ⟨ a, _ | ⟨ b, _ | y ⟩ ⟩ ) <;> simp_all +decide [ List.prod_cons ] ;
  · linarith;
  · rcases hk with ⟨ ⟨ ⟨ rfl | rfl, hx ⟩, ⟨ rfl | rfl, ha ⟩ ⟩, rfl, h ⟩ <;> contradiction;
  · rcases hk with ⟨ ⟨ ⟨ rfl | rfl, _ ⟩, ⟨ rfl | rfl, _ ⟩, ⟨ rfl | rfl, _ ⟩ ⟩, rfl, h ⟩ <;> norm_num at h;
  · grind

/-
64 has two distinct {4,8}-factorizations: {4,4,4} and {8,8}.
-/
theorem set_4_8_ufd_fails :
    ¬HasUniqueFactorization ({4, 8} : Set ℕ) := by
  intro h
  have := h 64 {4, 4, 4} {8, 8} ?_ ?_ <;> simp_all +decide [ IsFactorization ]

/-- **Theorem B**: All-k-product-freeness does NOT imply unique factorization.
    This reveals that the multiplicative independence hierarchy, while necessary,
    is not sufficient to characterize the full structural depth of primes. -/
theorem all_k_product_free_not_implies_ufd :
    ∃ S : Set ℕ, (∀ k, k ≥ 2 → IsKProductFree S k) ∧ ¬HasUniqueFactorization S :=
  ⟨{4, 8}, set_4_8_all_k_product_free, set_4_8_ufd_fails⟩

/-! ## Theorem C: Primes Have Full Multiplicative Independence -/

/-- A product of k ≥ 2 primes is not prime. -/
theorem product_of_primes_not_prime (m : Multiset ℕ) (hm : ∀ x ∈ m, Nat.Prime x)
    (hcard : m.card ≥ 2) : ¬Nat.Prime m.prod := by
  induction m using Multiset.induction <;> simp_all +decide [Nat.prime_mul_iff]
  rename_i n s hn
  rcases s with ⟨⟨_ | _ | p⟩⟩ <;> simp_all +decide [Nat.prime_mul_iff]
  aesop

/-- **Theorem C**: Primes are k-product-free for every k ≥ 2. -/
theorem primes_all_k_product_free :
    ∀ k, k ≥ 2 → IsKProductFree {n : ℕ | n.Prime} k := by
  intro k hk
  exact fun m hm hm' =>
    product_of_primes_not_prime m (fun x hx => by have := hm x hx; exact this.1) (by linarith)

/-- Primes have the irreducibility property. -/
theorem primes_have_irreducibility :
    HasIrreducibilityProperty {n : ℕ | n.Prime} := by
  intro n hn
  refine ⟨hn, fun f hf => ?_⟩
  by_contra h
  push_neg at h
  have hk : f.card ≥ 2 := by omega
  exact primes_all_k_product_free f.card hk f hf.1 rfl (hf.2 ▸ hn)

/-! ## Theorem D: k-Product-Free Implies Irreducibility -/

/-- **Theorem D**: If S is k-product-free for all k ≥ 2, then every element
    of S is S-irreducible. Elements of S cannot be decomposed within S. -/
theorem all_k_product_free_has_irreducibility (S : Set ℕ)
    (hkpf : ∀ k, k ≥ 2 → IsKProductFree S k) :
    HasIrreducibilityProperty S := by
  intro n hn
  refine ⟨hn, fun f hf => ?_⟩
  contrapose! hkpf
  exact ⟨f.card, hkpf, fun h => h f (fun x hx => hf.1 x hx) rfl (by simpa [hf.2] using hn)⟩

/-! ## Theorem E: Product Shadow Separation -/

/-- The **product shadow** of a finite set: all pairwise products. -/
def productShadow (S : Finset ℕ) : Finset ℕ :=
  S.biUnion (fun a => S.image (fun b => a * b))

/-- **Theorem E**: For product-free sets, the product shadow is disjoint from S. -/
theorem product_shadow_disjoint
    (S : Finset ℕ) (hS : ∀ x ∈ S, x ≥ 2)
    (hpf : IsProductFree (↑S : Set ℕ)) :
    Disjoint S (productShadow S) := by
  rw [Finset.disjoint_left]; unfold productShadow; aesop

/-! ## Conjecture: The General Strict Hierarchy -/

/-- **Conjecture**: For every k ≥ 2, the witness S_k = {2, 3, 2^(k-1)·3}
    is j-product-free for all 2 ≤ j < k, but not k-product-free.

    **Testable prediction**: For k = 5, S₅ = {2, 3, 48}. Verify:
    - All products of ≤ 4 elements from {2,3,48} miss the set.
    - 2⁴·3 = 48 witnesses failure at k = 5. -/
def strictHierarchyConjecture : Prop :=
  ∀ k : ℕ, k ≥ 2 →
    ∃ S : Set ℕ, (∀ j, 2 ≤ j → j < k → IsKProductFree S j) ∧ ¬IsKProductFree S k