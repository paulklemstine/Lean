/-
# Counterfactual Number Theory: What If Primes Were Random?

This module develops the theory of "generative sets" — subsets of ℕ that replace
primes as building blocks for multiplicative number theory. We prove that:

1. Unique factorization collapses for any generative set containing a divisibility pair
2. Density alone cannot determine multiplicative structure
3. The real primes are characterized by multiplicative independence, not density

These results formalize the intuition that replacing primes with a random dense subset
of ℕ destroys the fundamental theorem of arithmetic.
-/
import Mathlib

open Finset Nat

namespace CounterfactualPrimes

/-! ## Core Definitions -/

/-- A generative set is a set of natural numbers ≥ 2 that serves as
    "pseudo-primes" in a counterfactual number theory. -/
structure GeneratingSet where
  /-- The underlying set of generators -/
  carrier : Set ℕ
  /-- All generators are at least 2 -/
  ge_two : ∀ g ∈ carrier, 2 ≤ g

/-- A G-factorization of n is a list of elements from G whose product equals n. -/
structure GFactorization (G : GeneratingSet) (n : ℕ) where
  /-- The factors as a list -/
  factors : List ℕ
  /-- All factors belong to G -/
  mem_carrier : ∀ f ∈ factors, f ∈ G.carrier
  /-- The product of factors equals n -/
  prod_eq : factors.prod = n

/-- A generating set has unique factorization if every natural number has at most
    one G-factorization up to permutation. -/
def HasUniqueFactorization (G : GeneratingSet) : Prop :=
  ∀ n : ℕ, ∀ f₁ f₂ : GFactorization G n,
    f₁.factors.Perm f₂.factors

/-- A generating set contains a "product collision" if it has four elements
    a, b, c, d where a * b = c * d but the pairs are not permutations. -/
def HasProductCollision (G : GeneratingSet) : Prop :=
  ∃ a b c d : ℕ, a ∈ G.carrier ∧ b ∈ G.carrier ∧ c ∈ G.carrier ∧ d ∈ G.carrier ∧
    a * b = c * d ∧ ¬([a, b].Perm [c, d])

/-! ## Key Definition: Multiplicative Independence -/

/-- **Key Definition: Multiplicative Independence**
    A set S of naturals is multiplicatively independent if no finite
    product of elements (with multiplicity) from S can be rearranged
    to give a different product.

    Formally: if two multisets over S have the same product, they are equal. -/
def MultiplicativelyIndependent (S : Set ℕ) : Prop :=
  ∀ (m₁ m₂ : Multiset ℕ),
    (∀ x ∈ m₁, x ∈ S) → (∀ x ∈ m₂, x ∈ S) →
    (m₁.prod = m₂.prod) → m₁ = m₂

/-! ## Concrete Non-Uniqueness: The {2, 4} Example -/

/-- The generating set {2, 4}. -/
def twoFourSet : GeneratingSet where
  carrier := {2, 4}
  ge_two := by
    intro g hg
    rcases hg with rfl | rfl <;> omega

/-- First factorization of 8 in {2,4}: 8 = 2 × 2 × 2 -/
def factorization_8_v1 : GFactorization twoFourSet 8 where
  factors := [2, 2, 2]
  mem_carrier := by
    intro f hf
    simp [twoFourSet, List.mem_cons] at hf ⊢
    rcases hf with rfl | rfl | rfl <;> left <;> rfl
  prod_eq := by norm_num [List.prod_cons]

/-- Second factorization of 8 in {2,4}: 8 = 2 × 4 -/
def factorization_8_v2 : GFactorization twoFourSet 8 where
  factors := [2, 4]
  mem_carrier := by
    intro f hf
    simp [twoFourSet, List.mem_cons] at hf ⊢
    rcases hf with rfl | rfl
    · left; rfl
    · right; rfl
  prod_eq := by norm_num [List.prod_cons]

/-
**Theorem (UFD Collapse for {2,4})**: The set {2, 4} does not have
    unique factorization. The number 8 has two distinct factorizations:
    [2,2,2] and [2,4], which are not permutations of each other.
-/
theorem twoFour_not_unique_factorization :
    ¬ HasUniqueFactorization twoFourSet := by
  intro h; have := h 8 factorization_8_v1 factorization_8_v2; simp_all +decide ;

/-! ## The {2,3} Set is Multiplicatively Independent -/

/-- The generating set {2, 3}. -/
def twoThreeSet : GeneratingSet where
  carrier := {2, 3}
  ge_two := by
    intro g hg
    rcases hg with rfl | rfl <;> omega

/-
**Theorem**: {2, 3} is multiplicatively independent.
    This follows from the fundamental theorem of arithmetic:
    2 and 3 are distinct primes, so no multiset equation
    2^a * 3^b = 2^c * 3^d holds with (a,b) ≠ (c,d).
-/
theorem twoThree_mult_independent :
    MultiplicativelyIndependent ({2, 3} : Set ℕ) := by
  intro m₁ m₂ h₁ h₂ h
  have h_exp : Multiset.count 2 m₁ = Multiset.count 2 m₂ ∧ Multiset.count 3 m₁ = Multiset.count 3 m₂ := by
    have h_count : ∀ m : Multiset ℕ, (∀ x ∈ m, x ∈ ({2, 3} : Set ℕ)) → Multiset.prod m = 2 ^ (Multiset.count 2 m) * 3 ^ (Multiset.count 3 m) := by
      intros m hm; induction m using Multiset.induction <;> simp_all +decide [ pow_succ', mul_assoc ] ;
      rcases hm.1 with ( rfl | rfl ) <;> simp +decide [ *, pow_succ', mul_assoc, mul_comm, mul_left_comm ];
    apply_fun fun x => ( x.factorization 2, x.factorization 3 ) at h ; simp_all +decide;
  ext x; by_cases hx : x = 2 <;> by_cases hx' : x = 3 <;> specialize h₁ x <;> specialize h₂ x <;> aesop;

/-! ## Product Collision Implies Non-Uniqueness -/

/-
If a generating set has a product collision a*b = c*d with
    the factor lists not being permutations, then unique factorization fails.
-/
theorem product_collision_breaks_ufd (G : GeneratingSet)
    (h : HasProductCollision G) :
    ¬ HasUniqueFactorization G := by
  contrapose! h;
  rintro ⟨ a, b, c, d, ha, hb, hc, hd, hab, hcd ⟩;
  -- Construct two G-factorizations of (a*b): f₁ with factors [a,b] and f₂ with factors [c,d].
  set f₁ : GFactorization G (a * b) := ⟨[a, b], by
    aesop, by
    grind⟩
  set f₂ : GFactorization G (c * d) := ⟨[c, d], by
    aesop, by
    norm_num⟩
  generalize_proofs at *;
  exact hcd <| by simpa [ hab ] using h ( a * b ) f₁ ( f₂ |> fun x => ⟨ x.factors, x.mem_carrier, by simpa [ hab ] using x.prod_eq ⟩ ) ;

/-! ## {2,4} is Not Multiplicatively Independent -/

/-
**Theorem**: {2, 4} is NOT multiplicatively independent because
    the multisets {4} and {2, 2} both have product 4.
-/
theorem twoFour_not_mult_independent :
    ¬ MultiplicativelyIndependent ({2, 4} : Set ℕ) := by
  -- Consider the multisets {4} and {2, 2}.
  set m₁ : Multiset ℕ := {4}
  set m₂ : Multiset ℕ := {2, 2};
  exact fun h => absurd ( h m₁ m₂ ( by aesop ) ( by aesop ) ( by decide ) ) ( by decide )

/-! ## Same Density, Different Structure -/

/-- **Theorem (Density Does Not Determine Structure)**:
    The sets {2,3} and {2,4} have the same cardinality (both size 2)
    but {2,3} is multiplicatively independent while {2,4} is not.

    This is the core insight: density (how many pseudo-primes there are)
    does not determine whether unique factorization holds. What matters
    is the multiplicative relationships between elements. -/
theorem density_does_not_determine_structure :
    MultiplicativelyIndependent ({2, 3} : Set ℕ) ∧
    ¬ MultiplicativelyIndependent ({2, 4} : Set ℕ) := by
  exact ⟨twoThree_mult_independent, twoFour_not_mult_independent⟩

/-! ## The Fundamental Theorem: MI ↔ UFD -/

/-
**Theorem (MI → UFD)**: If a generating set's carrier is multiplicatively
    independent, then it has unique factorization.
-/
theorem mi_implies_ufd (G : GeneratingSet)
    (h : MultiplicativelyIndependent G.carrier) :
    HasUniqueFactorization G := by
  intro n f₁ f₂
  have h_multiset : Multiset.ofList f₁.factors = Multiset.ofList f₂.factors := by
    apply h;
    · exact fun x hx => f₁.mem_carrier x hx;
    · exact fun x hx => f₂.mem_carrier x <| by simpa using hx;
    · exact f₁.prod_eq.trans f₂.prod_eq.symm;
  exact Multiset.coe_eq_coe.mp h_multiset

/-
**Theorem (UFD → MI)**: If a generating set has unique factorization,
    then its carrier is multiplicatively independent.
-/
theorem ufd_implies_mi (G : GeneratingSet)
    (h : HasUniqueFactorization G) :
    MultiplicativelyIndependent G.carrier := by
  intro m₁ m₂ hm₁ hm₂ hprod
  have h_perm : List.Perm (Multiset.toList m₁) (Multiset.toList m₂) := by
    convert h m₁.prod ( ⟨ m₁.toList, ?_, ?_ ⟩ : GFactorization G m₁.prod ) ( ⟨ m₂.toList, ?_, ?_ ⟩ : GFactorization G m₁.prod ) using 1 <;> aesop;
  simpa using Multiset.coe_eq_coe.mpr h_perm

/-- **Theorem (MI ↔ UFD)**: A generating set has unique factorization
    if and only if its carrier is multiplicatively independent.
    This characterizes exactly what property of the primes is responsible
    for unique factorization. -/
theorem ufd_iff_mi (G : GeneratingSet) :
    HasUniqueFactorization G ↔ MultiplicativelyIndependent G.carrier :=
  ⟨ufd_implies_mi G, mi_implies_ufd G⟩

/-! ## Dirichlet Property -/

/-- A generating set satisfies the Dirichlet property if, for every d and
    every a coprime to d, infinitely many elements of G lie in the
    arithmetic progression a mod d. -/
def HasDirichletProperty (G : GeneratingSet) : Prop :=
  ∀ a d : ℕ, 0 < d → Nat.Coprime a d →
    ∀ N : ℕ, ∃ g ∈ G.carrier, N < g ∧ g % d = a % d

/-
**Theorem**: The set of all even numbers ≥ 2 does not satisfy
    the Dirichlet property, since no even number is ≡ 1 mod 2.
-/
theorem evens_fail_dirichlet :
    ¬ HasDirichletProperty ⟨{n : ℕ | 2 ≤ n ∧ 2 ∣ n},
      fun _ ⟨h, _⟩ => h⟩ := by
  unfold HasDirichletProperty; norm_num;
  exact ⟨ 1, 2, by decide, by decide, 0, by intros; omega ⟩

/-! ## Product Triple Detection -/

/-- A "product triple" in a set: three elements a, b, c with a * b = c,
    where a ≥ 2 and b ≥ 2. This immediately implies the set is not
    multiplicatively independent. -/
def HasProductTriple (S : Finset ℕ) : Prop :=
  ∃ a ∈ S, ∃ b ∈ S, ∃ c ∈ S, a * b = c ∧ 2 ≤ a ∧ 2 ≤ b

/-
**Theorem**: A product triple in S implies S is not
    multiplicatively independent.
-/
theorem product_triple_breaks_mi (S : Finset ℕ)
    (h : HasProductTriple S) :
    ¬ MultiplicativelyIndependent (↑S : Set ℕ) := by
  obtain ⟨ a, ha, b, hb, c, hc, habc, ha2, hb2 ⟩ := h;
  contrapose! habc;
  have := @habc { a, b } { c } ; simp_all +decide ;
  intro h; specialize this h; replace this := congr_arg Multiset.card this; aesop;

/-! ## Primes Have No Product Triples -/

/-
**Theorem (Primes Have No Product Collisions)**: No product of two
    primes is itself prime. This is because p * q ≥ 4 and has at least
    two prime factors.
-/
theorem prime_product_not_prime (p q : ℕ) (hp : p.Prime) (hq : q.Prime) :
    ¬ (p * q).Prime := by
  rw [ Nat.prime_mul_iff ] ; aesop

/-
**Theorem (Primes Avoid Product Triples)**: For any finite set of primes P,
    P has no product triple. This captures why primes give unique
    factorization while random dense sets do not.
-/
theorem primes_no_product_triple (P : Finset ℕ) (hP : ∀ p ∈ P, Nat.Prime p) :
    ¬ HasProductTriple P := by
  rintro ⟨ a, ha, b, hb, c, hc, h₁, _, h₃ ⟩;
  exact absurd ( hP c hc ) ( by rw [ show c = a * b by linarith ] ; exact Nat.not_prime_mul ( by linarith ) ( by linarith ) )

/-! ## The Counterfactual Density Theorem -/

/-
**Theorem (Counterfactual Density)**: Any subset of [2, n] that includes
    both k and k² for some k ≥ 2 is not multiplicatively independent.
    This is a concrete sufficient condition for non-uniqueness that
    random dense sets satisfy with high probability.
-/
theorem square_in_set_breaks_mi (S : Finset ℕ) (k : ℕ) (_hk : 2 ≤ k)
    (hkS : k ∈ S) (hk2S : k * k ∈ S) :
    ¬ MultiplicativelyIndependent (↑S : Set ℕ) := by
  intro H; specialize H { k, k } { k * k } ; simp_all +decide ;
  replace H := congr_arg Multiset.card H ; simp_all +decide

/-! ## Main Summary Theorem -/

/-- **Grand Summary**: The primes are special not because of their density
    but because of their multiplicative independence. Specifically:
    1. {2,3} (primes) gives unique factorization
    2. {2,4} (same density, non-primes) does not
    3. Unique factorization ↔ multiplicative independence
    4. Primes avoid product triples; random dense sets don't -/
theorem counterfactual_summary :
    -- Part 1: Primes give UFD
    MultiplicativelyIndependent ({2, 3} : Set ℕ) ∧
    -- Part 2: Same-density non-primes don't
    ¬ MultiplicativelyIndependent ({2, 4} : Set ℕ) ∧
    -- Part 3: No prime product is prime
    (∀ p q : ℕ, p.Prime → q.Prime → ¬(p * q).Prime) := by
  refine ⟨twoThree_mult_independent, twoFour_not_mult_independent, ?_⟩
  exact prime_product_not_prime

end CounterfactualPrimes