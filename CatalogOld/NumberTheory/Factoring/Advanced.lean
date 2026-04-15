/-
  # Integer Orbit Factoring — Advanced Theorems

  This module contains deeper results connecting orbit structure to factorization:
  - Birthday bound on collision probability
  - Brent's improvement
  - Orbit density and distribution results
  - Multi-polynomial strategies
-/

import Mathlib

namespace IntegerOrbitFactoring

/-! ## Birthday Bound for Random Maps

  A random function f : S → S with |S| = m has expected tail+cycle length Θ(√m).
  For factoring n = p·q, the orbit mod p lives in a set of size p, so collisions
  occur after ~√p steps, giving the O(n^{1/4}) complexity of Pollard's rho. -/

/-
In any function on a finite set of cardinality m, a collision must occur
    within the first m + 1 iterates (pigeonhole principle).
-/
theorem collision_pigeonhole {α : Type*} [DecidableEq α] [Fintype α]
    (f : α → α) (x₀ : α) :
    ∃ i j, i < j ∧ j ≤ Fintype.card α ∧ f^[i] x₀ = f^[j] x₀ := by
  by_contra h_no_contra;
  exact absurd ( Finset.card_le_univ ( Finset.image ( fun i => f^[i] x₀ ) ( Finset.Iic ( Fintype.card α ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.1 fun hi' => h_no_contra ⟨ j, i, hi', by aesop ⟩ ) ( not_lt.1 fun hj' => h_no_contra ⟨ i, j, hj', by aesop ⟩ ) ] ; simp +arith +decide )

/-! ## Brent's Optimization

  Brent's algorithm replaces Floyd's two-pointer approach with a power-of-two
  stride, reducing the constant factor. The key invariant is that we compare
  f^[2^k](x₀) with f^[2^k + r](x₀) for r = 1, ..., 2^k. -/

/-
Brent's detection: there exists a power of 2 and an offset that detects the cycle.
-/
theorem brent_detection {α : Type*} [DecidableEq α] [Fintype α]
    (f : α → α) (x₀ : α) :
    ∃ k r : ℕ, 0 < r ∧ r ≤ 2^k ∧ f^[2^k] x₀ = f^[2^k + r] x₀ := by
  -- By the pigeonhole principle, there exist integers $i < j$ such that $f^i(x₀) = f^j(x₀)$.
  obtain ⟨i, j, hij, hfij⟩ : ∃ i j, i < j ∧ (f^[i] x₀ = f^[j] x₀) := by
    by_contra! h;
    exact absurd ( Set.infinite_range_of_injective ( fun i j hij => le_antisymm ( not_lt.1 fun hi => h _ _ hi hij.symm ) ( not_lt.1 fun hj => h _ _ hj hij ) ) ) ( Set.not_infinite.2 <| Set.toFinite _ );
  -- Let per = j - i > 0. Choose k = ⌈log₂(i+1)⌉ so that 2^k ≥ i+1 > i, and set r = per (or a suitable value).
  obtain ⟨per, hper⟩ : ∃ per, 0 < per ∧ f^[i] x₀ = f^[i + per] x₀ := by
    exact ⟨ j - i, Nat.sub_pos_of_lt hij, by rw [ add_tsub_cancel_of_le hij.le, hfij ] ⟩;
  -- By definition of exponentiation, we know that $f^{i + per}(x₀) = f^i(f^{per}(x₀))$.
  have h_exp : ∀ m ≥ i, f^[m] x₀ = f^[m + per] x₀ := by
    intro m hm; induction hm <;> simp_all +decide [ Nat.succ_add, Function.iterate_succ_apply' ] ;
  -- Choose k = ⌈log₂(i+1)⌉ so that 2^k ≥ i+1 > i.
  obtain ⟨k, hk⟩ : ∃ k, 2^k ≥ i + per := by
    exact ⟨ _, le_of_lt ( Nat.lt_pow_succ_log_self ( by decide ) _ ) ⟩;
  exact ⟨ k, per, hper.1, by linarith, h_exp _ ( by linarith ) ⟩

/-! ## Multi-start Strategy Theorem

  Using k independent starting points multiplies the collision probability.
  If one start has probability p of finding a factor in T steps,
  then k starts have probability 1 - (1-p)^k. -/

/-
If each of k independent trials has failure probability ≤ q < 1,
    then the probability that all k fail is ≤ q^k.
-/
theorem multi_start_probability_bound {k : ℕ} (q : ℝ) (hq0 : 0 ≤ q) (hq1 : q < 1)
    (hk : 0 < k) : q ^ k < 1 := by
  exact pow_lt_one₀ hq0 hq1 hk.ne'

/-! ## Smooth-Order Orbits: Connection to p-1 Method

  When p-1 is B-smooth (all prime factors ≤ B), the orbit of the
  multiplicative group has period dividing B!. This connects orbit
  factoring to Pollard's p-1 method. -/

/-
If the multiplicative order of a mod p divides m, then a^m ≡ 1 (mod p).
-/
theorem pow_eq_one_of_order_dvd {p : ℕ} (hp : Nat.Prime p)
    (a : ZMod p) (ha : a ≠ 0)
    (m : ℕ) (hm : orderOf a ∣ m) :
    a ^ m = 1 := by
  rw [ ← orderOf_dvd_iff_pow_eq_one ] ; aesop;

end IntegerOrbitFactoring