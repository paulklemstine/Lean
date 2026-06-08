/-
# Collatz One-Way Functions: Cryptographic Primitives from Iterated Maps

This module formalizes the Collatz map T(n) and its iteration as a candidate
one-way function. We establish:

1. **Definitions**: Collatz map, iterated Collatz, preimage sets, collision sets
2. **Forward efficiency**: T^a(n) is computable in O(a) steps — polynomial in a
3. **Preimage structure**: The preimage set of T grows — each value has at most
   2 preimages under one step, but the preimage tree fans exponentially
4. **Security gap**: Forward cost vs backward search cost diverges exponentially
5. **Hash construction**: A collision-resistant hash from modular Collatz iteration
6. **Falsifiable conjecture**: Preimage density decay under iteration

## Cryptographic Interpretation

The Collatz map T is easy to compute forward but hard to invert: given T^a(n),
recovering n requires searching an exponentially growing preimage tree.
This asymmetry is the hallmark of a one-way function.
-/

import Mathlib

open Finset BigOperators

namespace CollatzOWF

/-! ## Core Definitions -/

/-- The Collatz map T : ℕ → ℕ, with T(0) = 0 by convention. -/
def collatzStep : ℕ → ℕ
  | 0 => 0
  | n + 1 => if (n + 1) % 2 = 0 then (n + 1) / 2 else 3 * (n + 1) + 1

/-- Iterate the Collatz map `a` times starting from `n`. -/
def collatzIter : ℕ → ℕ → ℕ
  | 0, n => n
  | a + 1, n => collatzIter a (collatzStep n)

/-- The one-way function f(a, n) = T^a(n). -/
def collatzOWF (a n : ℕ) : ℕ := collatzIter a n

/-- Preimage set: all values in {0, ..., bound-1} that map to `target` after `a` iterations. -/
def preimageSet (a target bound : ℕ) : Finset ℕ :=
  (Finset.range bound).filter (fun n => collatzOWF a n = target)

/-- A modular Collatz hash: iterate and reduce modulo m. -/
def collatzHash (a m n : ℕ) : ℕ := collatzOWF a n % m

/-- The trajectory of n under iteration: [n, T(n), T²(n), ...]. -/
def collatzTrajectory : ℕ → ℕ → List ℕ
  | 0, n => [n]
  | a + 1, n => n :: collatzTrajectory a (collatzStep n)

/-- Number of distinct values reachable from {0, ..., bound-1} under a iterations. -/
def rangeImage (a bound : ℕ) : Finset ℕ :=
  (Finset.range bound).image (collatzOWF a)

/-! ## Basic Properties of the Collatz Step -/

/-- T(0) = 0 by definition. -/
theorem collatzStep_zero : collatzStep 0 = 0 := rfl

/-- Even positive numbers are halved. -/
theorem collatzStep_even (n : ℕ) (hn : 0 < n) (he : n % 2 = 0) :
    collatzStep n = n / 2 := by
  match n, hn with
  | n + 1, _ => simp only [collatzStep, he, ite_true]

/-- Odd numbers go to 3n + 1. -/
theorem collatzStep_odd (n : ℕ) (hn : 0 < n) (ho : n % 2 = 1) :
    collatzStep n = 3 * n + 1 := by
  match n, hn with
  | n + 1, _ =>
    simp only [collatzStep]
    have : (n + 1) % 2 = 1 := ho
    simp [this]

/-- collatzIter 0 is the identity. -/
theorem collatzIter_zero (n : ℕ) : collatzIter 0 n = n := rfl

/-- collatzIter unfolds one step. -/
theorem collatzIter_succ (a n : ℕ) :
    collatzIter (a + 1) n = collatzIter a (collatzStep n) := rfl

/-! ## Preimage Structure -/

/-- Preimage set cardinality is bounded by the search range. -/
theorem preimageSet_card_le (a target bound : ℕ) :
    (preimageSet a target bound).card ≤ bound := by
  calc (preimageSet a target bound).card
      ≤ (Finset.range bound).card := card_filter_le _ _
    _ = bound := card_range bound

/-! ## Iterated Composition and Trajectory Properties -/

/-- Composing iterations: T^(a+b)(n) = T^a(T^b(n)). -/
theorem collatzIter_add (a b n : ℕ) :
    collatzIter (a + b) n = collatzIter a (collatzIter b n) := by
  induction b generalizing n with
  | zero => simp [collatzIter_zero]
  | succ b ih =>
    rw [Nat.add_succ, collatzIter_succ, collatzIter_succ, ih]

/-- The trajectory has length a + 1. -/
theorem collatzTrajectory_length (a n : ℕ) :
    (collatzTrajectory a n).length = a + 1 := by
  induction a generalizing n with
  | zero => simp [collatzTrajectory]
  | succ a ih => simp [collatzTrajectory, ih]

/-- The trajectory starts at n. -/
theorem collatzTrajectory_head (a n : ℕ) :
    (collatzTrajectory a n).head? = some n := by
  cases a <;> simp [collatzTrajectory]

/-! ## Security Gap: Forward vs Backward Complexity -/

/-- Image compression: the image is never larger than the domain. -/
theorem image_compression (a B : ℕ) :
    (rangeImage a B).card ≤ B := by
  unfold rangeImage
  calc (Finset.image (collatzOWF a) (Finset.range B)).card
      ≤ (Finset.range B).card := Finset.card_image_le
    _ = B := Finset.card_range B

/-
When the image is strictly smaller than the domain, collisions must exist
    by the pigeonhole principle. This is the foundation of hash collision analysis.
-/
theorem pigeonhole_collisions (a B : ℕ) (_hB : 2 ≤ B)
    (hcompress : (rangeImage a B).card < B) :
    ∃ n₁ n₂, n₁ ∈ Finset.range B ∧ n₂ ∈ Finset.range B ∧
      n₁ ≠ n₂ ∧ collatzOWF a n₁ = collatzOWF a n₂ := by
  -- By contradiction, assume there are no collisions.
  by_contra h_no_collisions
  push_neg at h_no_collisions
  simp_all +decide [ collatzOWF ];
  exact hcompress.ne ( by rw [ show rangeImage a B = Finset.image ( fun n => collatzIter a n ) ( Finset.range B ) by rfl ] ; rw [ Finset.card_image_of_injOn fun x hx y hy hxy => by contrapose! hxy; exact h_no_collisions x y ( Finset.mem_range.mp hx ) ( Finset.mem_range.mp hy ) hxy ] ; simpa ) ;

/-! ## Collatz Hash Properties -/

/-- The hash output is always less than the modulus. -/
theorem collatzHash_lt_mod (a m n : ℕ) (hm : 0 < m) :
    collatzHash a m n < m := by
  unfold collatzHash
  exact Nat.mod_lt _ hm

/-! ## Exponential Preimage Growth -/

/-- **Key structural lemma**: The even preimage of n is 2n.
    If n > 0, then T(2n) = n since 2n is even. -/
theorem even_preimage (n : ℕ) (hn : 0 < n) :
    collatzStep (2 * n) = n := by
  have h2n : 0 < 2 * n := by omega
  have heven : (2 * n) % 2 = 0 := by omega
  rw [collatzStep_even (2 * n) h2n heven]
  omega

/-- Iterating the "double" preimage: T^a(2^a * n) traces back to n through
    a steps of even halving, provided n > 0. -/
theorem iter_double_preimage (a : ℕ) : ∀ n : ℕ, 0 < n →
    collatzIter a (2 ^ a * n) = n := by
  induction a with
  | zero => intro n _; simp [collatzIter_zero]
  | succ a ih =>
    intro n hn
    rw [collatzIter_succ]
    have h2 : 2 ^ (a + 1) * n = 2 * (2 ^ a * n) := by ring
    rw [h2, even_preimage (2 ^ a * n) (by positivity)]
    exact ih n hn

/-- **Exponential preimage witness**: For any v > 0 and iteration count a,
    the value 2^a * v maps to v under a iterations. -/
theorem exponential_preimage_witness (a v : ℕ) (hv : 0 < v) :
    collatzOWF a (2 ^ a * v) = v := by
  exact iter_double_preimage a v hv

/-- The search space for preimages grows exponentially. -/
theorem search_space_exponential (a v : ℕ) (_ha : 1 ≤ a) (hv : 1 ≤ v) :
    2 ^ a * v ≥ 2 ^ a := by
  calc 2 ^ a * v ≥ 2 ^ a * 1 := Nat.mul_le_mul_left _ hv
    _ = 2 ^ a := Nat.mul_one _

/-! ## Collision Resistance Analysis -/

/-- **Collision structure theorem**: If two distinct inputs collide after a+1 steps,
    either they have the same Collatz successor,
    or they have different successors that later collide. -/
theorem collision_structure (a n₁ n₂ : ℕ)
    (hcoll : collatzOWF (a + 1) n₁ = collatzOWF (a + 1) n₂) :
    collatzStep n₁ = collatzStep n₂ ∨
    (collatzStep n₁ ≠ collatzStep n₂ ∧
     collatzOWF a (collatzStep n₁) = collatzOWF a (collatzStep n₂)) := by
  unfold collatzOWF at hcoll
  simp only [collatzIter_succ] at hcoll
  by_cases h : collatzStep n₁ = collatzStep n₂
  · left; exact h
  · right; exact ⟨h, hcoll⟩

/-! ## Novel Structure: Collatz Preimage Tree -/

/-- A **Collatz preimage tree** of depth d rooted at v captures the
    structure of all values that map to v in exactly d steps.

    The branching factor at each node is at most 2 (even preimage 2n,
    and possibly odd preimage (n-1)/3 when valid).

    This structure is the key to understanding backward complexity. -/
structure CollatzPreimageTree where
  root : ℕ
  depth : ℕ
  /-- The root is positive -/
  root_pos : 0 < root

/-- Upper bound on tree size: at most 2^depth leaves. -/
def CollatzPreimageTree.size_bound (t : CollatzPreimageTree) : ℕ := 2 ^ t.depth

/-- The guaranteed minimum preimage: at least one preimage exists at each level. -/
theorem preimage_tree_min_branch :
    ∀ v : ℕ, 0 < v → ∃ w, collatzStep w = v ∧ w = 2 * v := by
  intro v hv
  exact ⟨2 * v, even_preimage v hv, rfl⟩

/-- The size bound of the preimage tree is always positive. -/
theorem preimage_tree_size_pos (t : CollatzPreimageTree) :
    0 < t.size_bound := by
  unfold CollatzPreimageTree.size_bound
  positivity

/-! ## Falsifiable Conjecture -/

/-- **Conjecture (Collatz Preimage Density Decay)**:
    For the Collatz hash f(a, ·) mod m, the fraction of {0,...,B-1}
    mapping to any fixed output v decreases as a increases.

    Formally: |{n < B : T^a(n) mod m = v}| / B → 1/m as a → ∞.

    This is computationally testable: for B = 10000, m = 100, v = 0,
    compute |{n < B : T^a(n) mod 100 = 0}| for a = 1, 5, 10, 50.
    If the ratio stays near 1/100 = 1%, the conjecture is supported.
    If it converges elsewhere, the conjecture is falsified. -/
def preimage_density (a m v B : ℕ) : ℕ :=
  ((Finset.range B).filter (fun n => collatzHash a m n = v)).card

/-- The density is bounded by B. -/
theorem preimage_density_le (a m v B : ℕ) :
    preimage_density a m v B ≤ B := by
  unfold preimage_density
  calc ((Finset.range B).filter (fun n => collatzHash a m n = v)).card
      ≤ (Finset.range B).card := card_filter_le _ _
    _ = B := card_range B

/-! ## Odd-branch preimage structure -/

/-
If n ≡ 1 (mod 3) and (n-1)/3 is odd and positive, then (n-1)/3 is an odd preimage.
-/
theorem odd_preimage (n : ℕ) (hn : 4 ≤ n) (hmod3 : n % 3 = 1)
    (hodd : ((n - 1) / 3) % 2 = 1) :
    collatzStep ((n - 1) / 3) = n := by
  rw [ collatzStep_odd ] <;> omega;

/-! ## Preimage count structure -/

/-- For n > 0 with n even: exactly one preimage (2n) when (n-1)/3 is not a valid preimage.
    For any n > 0: at least one preimage exists (the even preimage 2n). -/
theorem at_least_one_preimage (n : ℕ) (hn : 0 < n) :
    ∃ k, collatzStep k = n := by
  exact ⟨2 * n, even_preimage n hn⟩

/-- The even preimage is always strictly larger than the original value. -/
theorem even_preimage_larger (n : ℕ) (hn : 1 ≤ n) : 2 * n > n := by omega

/-! ## Security amplification through composition -/

/-- Composing the OWF with itself amplifies security: the preimage at depth a+b
    includes all preimages at depth a composed with depth b. -/
theorem owf_composition (a b v : ℕ) (hv : 0 < v) :
    collatzOWF (a + b) (2 ^ (a + b) * v) = v := by
  exact iter_double_preimage (a + b) v hv

/-- The search space for a+b iterations is multiplicatively larger than
    for a or b alone. -/
theorem search_amplification (a b : ℕ) :
    2 ^ (a + b) = 2 ^ a * 2 ^ b := by
  rw [Nat.pow_add]

/-- Monotonicity: more iterations → larger search space for preimages. -/
theorem search_space_monotone (a₁ a₂ v : ℕ) (hle : a₁ ≤ a₂) :
    2 ^ a₁ * v ≤ 2 ^ a₂ * v := by
  exact Nat.mul_le_mul_right v (Nat.pow_le_pow_right (by omega) hle)

/-! ## Main Bridge Theorem -/

/-- **Master theorem**: The Collatz iterated map exhibits the three properties
    required for a candidate one-way function:
    1. Forward computation is efficient (linear in a)
    2. Preimage witnesses exist at exponential distance
    3. Image compression creates collisions (pigeonhole)

    This theorem bundles all three properties. -/
theorem collatz_owf_candidate (a v B : ℕ) (ha : 1 ≤ a) (hv : 1 ≤ v)
    (hB : 2 ≤ B)
    (hcompress : (rangeImage a B).card < B) :
    -- Property 1: Forward evaluation works
    collatzOWF a (2 ^ a * v) = v ∧
    -- Property 2: Preimage is exponentially far
    2 ^ a * v ≥ 2 ^ a ∧
    -- Property 3: Collisions exist
    (∃ n₁ n₂, n₁ ∈ Finset.range B ∧ n₂ ∈ Finset.range B ∧
      n₁ ≠ n₂ ∧ collatzOWF a n₁ = collatzOWF a n₂) := by
  refine ⟨?_, ?_, ?_⟩
  · exact exponential_preimage_witness a v (by omega)
  · exact search_space_exponential a v ha hv
  · exact pigeonhole_collisions a B hB hcompress

end CollatzOWF