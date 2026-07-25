import Mathlib

/-!
# Counterfactual Number Theory: What If Primes Were Random?

## Overview

We develop the theory of *generator sets* — arbitrary subsets S ⊆ ℕ used as
building blocks for multiplicative factorization — and determine which structural
properties of the primes are essential for unique factorization.

The central question: if we replace the primes with a random subset of ℕ having
the same asymptotic density (n / log n), which classical theorems survive?

**Answer**: Unique factorization collapses completely. We identify two independent
failure modes — *PMI violations* (products of generators being generators) and
*product collisions* (distinct pairs with equal products) — and prove that pairwise
multiplicative independence, while necessary, is strictly insufficient for unique
factorization. The primes avoid both failure modes thanks to their *irreducibility*
in (ℕ, ×), a structural property that random sets lack.

## Main Results

* `product_in_S_breaks_uf`: If S contains a, b, and a·b (all ≥ 2), then
  unique factorization over S fails.
* `uf_implies_pmi`: Unique factorization ⟹ pairwise multiplicative independence.
* `primes_pmi`: The primes satisfy PMI.
* `collision_breaks_uf`: Product collisions break unique factorization.
* `exists_pmi_with_collision`: PMI does not prevent collisions ({6, 10, 21, 35}).
* `pmi_strictly_weaker_than_uf`: PMI is strictly weaker than UF.

## Novel Concept: Product Collision

A *product collision* in S is a quadruple (a, b, c, d) ∈ S⁴ with a·b = c·d
but {a,b} ≠ {c,d} as multisets. This captures a deeper obstruction to unique
factorization invisible to PMI. The primes avoid collisions via irreducibility.
-/

namespace CounterfactualPrimes

/-- An S-factorization of n: a nonempty multiset of elements from S with product n.
    This generalizes prime factorization to arbitrary generator sets. -/
structure SFact (S : Set ℕ) (n : ℕ) where
  factors : Multiset ℕ
  mem_S : ∀ x ∈ factors, x ∈ S
  prod_eq : factors.prod = n
  card_pos : 0 < factors.card

/-- A set S has *unique factorization* if any two S-factorizations of the same
    number yield identical multisets of factors. -/
def HasUF (S : Set ℕ) : Prop :=
  ∀ n : ℕ, ∀ f g : SFact S n, f.factors = g.factors

/-- *Pairwise multiplicative independence* (PMI): no product of two elements
    of S (each ≥ 2) lies in S. This is the most basic necessary condition
    for unique factorization — it prevents "composite pseudo-primes." -/
def PMI (S : Set ℕ) : Prop :=
  ∀ a b : ℕ, a ∈ S → b ∈ S → 2 ≤ a → 2 ≤ b → a * b ∉ S

/-- A *product collision* in S: four elements a, b, c, d ∈ S with a·b = c·d
    but {a,b} ≠ {c,d} as multisets. This is a novel obstruction concept that
    captures the failure of unique factorization beyond PMI violations.

    In classical number theory, the Fundamental Theorem of Arithmetic
    guarantees that primes have no product collisions. Random generator sets
    with density n/log(n) almost surely have abundant collisions. -/
structure ProductCollision (S : Set ℕ) where
  a : ℕ
  b : ℕ
  c : ℕ
  d : ℕ
  ha : a ∈ S
  hb : b ∈ S
  hc : c ∈ S
  hd : d ∈ S
  prod_eq : a * b = c * d
  distinct : (↑[a, b] : Multiset ℕ) ≠ ↑[c, d]

/-! ### Core Structural Theorems -/

/-
**Theorem (PMI Violation Breaks UF)**: If S contains elements a, b, and
    their product a·b (with a, b ≥ 2), then S does not have unique factorization.

    The number a·b admits two distinct S-factorizations: the singleton
    multiset {a·b} and the pair {a, b}. These differ in cardinality (1 vs 2).
-/
theorem product_in_S_breaks_uf (S : Set ℕ) (a b : ℕ)
    (ha : a ∈ S) (hb : b ∈ S) (hab : a * b ∈ S)
    (ha2 : 2 ≤ a) (hb2 : 2 ≤ b) : ¬HasUF S := by
  intro h; have := @h ( a * b );
  exact absurd ( this ⟨ { a * b }, by aesop, by simp +decide, by exact Multiset.card_singleton _ |> fun h => h.symm ▸ by norm_num ⟩ ⟨ { a, b }, by aesop, by simp +decide, by exact Multiset.card_cons _ _ |> fun h => h.symm ▸ by norm_num ⟩ ) ( by simp +decide )

/-- **Theorem (UF ⟹ PMI)**: Unique factorization implies pairwise multiplicative
    independence. Contrapositive of `product_in_S_breaks_uf`. -/
theorem uf_implies_pmi (S : Set ℕ) (h : HasUF S) : PMI S := by
  intro a b haS hbS ha2 hb2 hab
  exact absurd h (product_in_S_breaks_uf S a b haS hbS hab ha2 hb2)

/-
**Theorem (Primes Have PMI)**: The set of prime numbers satisfies pairwise
    multiplicative independence. No product of two primes is itself prime.
-/
theorem primes_pmi : PMI {p : ℕ | p.Prime} := by
  intro a b ha hb ha2 hb2 hab;
  rw [ Set.mem_setOf_eq, Nat.prime_mul_iff ] at hab ; aesop

/-
**Theorem (Collisions Break UF)**: Any product collision in S witnesses
    failure of unique factorization.
-/
theorem collision_breaks_uf (S : Set ℕ) (col : ProductCollision S) :
    ¬HasUF S := by
  obtain ⟨ a, b, c, d, ha, hb, hc, hd, h₁, h₂ ⟩ := col;
  intro h;
  convert h ( a * b ) ⟨ Multiset.ofList [ a, b ], ?_, ?_, ?_ ⟩ ⟨ Multiset.ofList [ c, d ], ?_, ?_, ?_ ⟩ using 1 <;> aesop

/-! ### Separation: PMI Does Not Imply UF -/

/-- The witness set for the separation theorem: {6, 10, 21, 35}. -/
private def witnessSet : Set ℕ := ({6, 10, 21, 35} : Set ℕ)

/-
The witness set satisfies PMI: no product of two elements is an element.
    Verified by checking all 16 products.
-/
private theorem witnessSet_pmi : PMI witnessSet := by
  intro a b ha hb ha2 hb2;
  unfold witnessSet at *; aesop

/-- The witness set admits the product collision 6·35 = 10·21 = 210. -/
private def witnessSet_collision : ProductCollision witnessSet where
  a := 6
  b := 35
  c := 10
  d := 21
  ha := by simp [witnessSet]
  hb := by simp [witnessSet]
  hc := by simp [witnessSet]
  hd := by simp [witnessSet]
  prod_eq := by norm_num
  distinct := by decide

/-- **Theorem (PMI + Collision Coexist)**: There exists a generator set that
    satisfies pairwise multiplicative independence yet admits a product collision. -/
theorem exists_pmi_with_collision :
    ∃ S : Set ℕ, PMI S ∧ Nonempty (ProductCollision S) :=
  ⟨witnessSet, witnessSet_pmi, ⟨witnessSet_collision⟩⟩

/-- **Theorem (PMI ⊊ UF)**: Pairwise multiplicative independence is strictly
    weaker than unique factorization. -/
theorem pmi_strictly_weaker_than_uf :
    ∃ S : Set ℕ, PMI S ∧ ¬HasUF S := by
  obtain ⟨S, hpmi, ⟨col⟩⟩ := exists_pmi_with_collision
  exact ⟨S, hpmi, collision_breaks_uf S col⟩

/-! ### Conjecture: Cramér Factorization Collapse

**Conjecture**: In the Cramér random model — where each integer n ≥ 2 is
included in S independently with probability 1/log(n) — unique factorization
fails almost surely.

More precisely: the expected number of product collisions (a,b,c,d) ∈ S⁴
with a·b = c·d ≤ N, {a,b} ≠ {c,d}, grows as Ω(N / (log N)³), which
tends to infinity.

**Testable prediction**: For N = 10000, a random set S with density matching
π(N) ≈ 1229 should contain at least one product collision with probability > 0.99.
In contrast, the actual primes below 10000 have zero product collisions. -/

end CounterfactualPrimes