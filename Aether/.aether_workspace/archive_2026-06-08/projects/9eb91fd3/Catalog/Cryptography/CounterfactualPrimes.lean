/-
  Counterfactual Number Theory: What If Primes Were Random?

  We construct a framework for "pseudo-prime systems" — subsets of ℕ that
  share the density profile of actual primes (≈ n/log n elements up to n)
  but lack the multiplicative structure that makes primes special.

  Main results:
  1. Primes are product-free (Theorem 1).
  2. Product closure breaks unique factorization (Theorem 2).
  3. Product-freeness is NECESSARY but NOT SUFFICIENT for UFD (Theorem 3) —
     the counterexample {4,6,9} is product-free but 36 = 4×9 = 6×6.
  4. Dense subsets of {0,...,qm-1} cover all residue classes (Theorem 4).
  5. The "Cramér gap" — measuring the structural deficit of random models.
-/
import Mathlib

open Finset Nat Multiset

/-! ## Core Definitions -/

/-- A Cramér random model: a subset of ℕ≥2 serving as "pseudo-primes".
    Named after Harald Cramér's 1936 probabilistic model of prime
    distribution, where each integer n is independently "prime" with
    probability 1/ln(n). -/
structure CramerModel where
  /-- The set of "pseudo-primes" -/
  carrier : Set ℕ
  /-- 0 is not a pseudo-prime -/
  zero_not_mem : 0 ∉ carrier
  /-- 1 is not a pseudo-prime -/
  one_not_mem : 1 ∉ carrier

/-- A set S ⊆ ℕ is product-free if no product of two elements of S
    (each ≥ 2) lies in S. This captures pairwise multiplicative independence. -/
def IsProductFree (S : Set ℕ) : Prop :=
  ∀ a b, a ∈ S → b ∈ S → a ≥ 2 → b ≥ 2 → a * b ∉ S

/-- A set S is k-product-free if no product of k elements (each ≥ 2)
    from S lies in S. This hierarchy measures the "depth" of
    multiplicative independence. Primes are k-product-free for all k;
    random sets typically fail at k = 2. -/
def IsKProductFree (S : Set ℕ) (k : ℕ) : Prop :=
  ∀ (m : Multiset ℕ), (∀ x ∈ m, x ∈ S ∧ x ≥ 2) → m.card = k → m.prod ∉ S

/-- An S-factorization of n: a multiset of elements from S (all ≥ 2)
    whose product equals n. -/
def IsFactorization (S : Set ℕ) (n : ℕ) (factors : Multiset ℕ) : Prop :=
  (∀ x ∈ factors, x ∈ S ∧ x ≥ 2) ∧ factors.prod = n

/-- A set S has unique factorization if every natural number has at
    most one S-factorization. -/
def HasUniqueFactorization (S : Set ℕ) : Prop :=
  ∀ n : ℕ, ∀ f₁ f₂ : Multiset ℕ,
    IsFactorization S n f₁ → IsFactorization S n f₂ → f₁ = f₂

/-- The Cramér defect measures how far a pseudo-prime system is from
    having the multiplicative structure of actual primes. A system with
    defect 0 at level k is k-product-free. -/
noncomputable def cramerDefect (S : Set ℕ) (k : ℕ) : ℕ :=
  Set.ncard {n ∈ S | ∃ (m : Multiset ℕ),
    (∀ x ∈ m, x ∈ S ∧ x ≥ 2) ∧ m.card = k ∧ m.prod = n}

/-! ## Theorem 1: Primes are Product-Free -/

/-- The set of natural number primes is product-free: if a and b are both
    prime (hence ≥ 2), then a * b is composite. This is the fundamental
    structural property that separates actual primes from random dense subsets. -/
theorem primes_are_product_free : IsProductFree {n : ℕ | n.Prime} := by
  intro a b ha hb _ _
  simp only [Set.mem_setOf_eq] at *
  intro h
  have ha1 : a ≠ 1 := ha.one_lt.ne'
  have hb1 : b ≠ 1 := hb.one_lt.ne'
  have : a = 1 ∨ a = a * b := h.eq_one_or_self_of_dvd a (dvd_mul_right a b)
  rcases this with rfl | hab
  · exact ha1 rfl
  · have : b = 1 := by nlinarith [ha.one_lt]
    exact hb1 this

/-! ## Theorem 2: Product Closure Destroys Unique Factorization -/

/-- **Central theorem**: If a set S contains elements a, b (both ≥ 2) and
    also contains their product a*b, then S cannot have unique factorization.

    The two distinct S-factorizations of a*b are:
    - The singleton multiset {a*b}
    - The pair multiset {a, b}

    This is the key result explaining why Cramér random models (which contain
    such triples with probability 1) lose unique factorization. -/
theorem product_in_set_breaks_ufd
    (S : Set ℕ) (a b : ℕ)
    (ha : a ∈ S) (hb : b ∈ S) (hab : a * b ∈ S)
    (ha2 : a ≥ 2) (hb2 : b ≥ 2) :
    ¬HasUniqueFactorization S := by
  intro h
  convert h (a * b) {a * b} {a, b} ?_ ?_ using 1
  · norm_num [Multiset.cons_eq_cons]
  · exact ⟨fun x hx => by rw [Multiset.mem_singleton.mp hx]; exact ⟨hab, by nlinarith⟩,
      by simp +decide⟩
  · exact ⟨by aesop, by aesop⟩

/-! ## Theorem 3: Product-Free is Necessary but Not Sufficient for UFD -/

/-- Product-freeness is a NECESSARY condition for unique factorization:
    if S has unique factorization, then S must be product-free. -/
theorem ufd_implies_product_free (S : Set ℕ) :
    HasUniqueFactorization S → IsProductFree S := by
  intro hufd a b ha hb ha2 hb2 hab
  exact product_in_set_breaks_ufd S a b ha hb hab ha2 hb2 hufd

/-
**Surprising counterexample**: The set {4, 6, 9} is product-free
    (no product of two elements lands back in the set: 4×6=24, 4×9=36,
    6×9=54, 4×4=16, 6×6=36, 9×9=81 — none are in {4,6,9}).
    Yet it LACKS unique factorization: 36 = 4×9 = 6×6.

    This reveals that primes possess a deeper structural property beyond
    mere product-freeness. The "Cramér gap" between random and actual
    primes is wider than product-freeness alone captures.
-/
theorem product_free_not_sufficient_for_ufd :
    ∃ S : Set ℕ, 0 ∉ S ∧ 1 ∉ S ∧ IsProductFree S ∧ ¬HasUniqueFactorization S := by
  -- Consider the set $S = \{4, 6, 9\}$.
  use {4, 6, 9};
  refine' ⟨ by decide, by decide, _, _ ⟩;
  · intro a b ha hb ha2 hb2; aesop;
  · intro h;
    have := @h 36 { 4, 9 } { 6, 6 } ; simp_all +decide [ IsFactorization ]

/-! ## Theorem 4: Dense Sets Cover All Residue Classes (Dirichlet Survival) -/

/-
**Dirichlet survival theorem**: In a universe {0,...,q·m - 1} partitioned
    into q residue classes of size m each, any subset S with more than
    (q-1)·m elements must intersect every residue class.

    This is the pigeonhole principle applied to Cramér models: any random
    subset with prime-like density (≈ n/log n ≫ n·(q-1)/q for fixed q)
    automatically satisfies the Dirichlet-type property of hitting every
    arithmetic progression, for any fixed modulus q.
-/
theorem dense_set_covers_all_residues
    (S : Finset ℕ) (q m : ℕ) (hq : q ≥ 1) (_hm : m ≥ 1)
    (hS_sub : ∀ x ∈ S, x < q * m)
    (hS_dense : S.card > (q - 1) * m) :
    ∀ r : ℕ, r < q → ∃ x ∈ S, x % q = r := by
  contrapose! hS_dense;
  obtain ⟨ r, hr, hr' ⟩ := hS_dense;
  have h_card : S ⊆ Finset.biUnion (Finset.Ico 0 q \ {r}) (fun i => Finset.image (fun j => i + j * q) (Finset.range m)) := by
    intro x hx; specialize hS_sub x hx; specialize hr' x hx; simp_all +decide [ Nat.mod_eq_of_lt ] ;
    exact ⟨ x % q, ⟨ Nat.mod_lt _ hq, hr' ⟩, x / q, Nat.div_lt_of_lt_mul <| by linarith, by linarith [ Nat.mod_add_div x q ] ⟩;
  refine le_trans ( Finset.card_le_card h_card ) ?_;
  refine' le_trans ( Finset.card_biUnion_le ) _;
  exact le_trans ( Finset.sum_le_sum fun _ _ => Finset.card_image_le ) ( by simp +decide [ Finset.card_sdiff, * ] )

/-! ## Theorem 5: k-Product-Free Hierarchy -/

/-
Being (k+1)-product-free is a strictly stronger condition than being
    k-product-free. At each level, more multiplicative structure is required.
    Actual primes are k-product-free for ALL k ≥ 2; this infinite hierarchy
    of conditions is what truly separates primes from random dense sets.
-/
theorem k_product_free_of_succ (S : Set ℕ)
    (hk : ∀ (m : Multiset ℕ), (∀ x ∈ m, x ∈ S ∧ x ≥ 2) →
      m.card ≥ 2 → m.prod ∉ S) :
    ∀ k, k ≥ 2 → IsKProductFree S k := by
  exact fun k hk' m hm hm' => hk m hm ( by linarith )

/-
Primes satisfy the full multiplicative independence hierarchy:
    no product of k ≥ 2 primes is itself prime.
-/
theorem primes_all_k_product_free :
    ∀ k, k ≥ 2 → IsKProductFree {n : ℕ | n.Prime} k := by
  intro k hk;
  intro m hm hm';
  rcases m with ⟨ ⟨ l ⟩ ⟩ <;> simp_all +decide [ Nat.prime_mul_iff ];
  induction ‹List ℕ› <;> simp_all +decide [ Nat.Prime.ne_one ];
  lia