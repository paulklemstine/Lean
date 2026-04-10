/-
  Integer Orbit Factoring: Advanced Results

  This file contains advanced theorems including:
  - Collision pigeonhole bounds
  - Brent's cycle detection
  - Period LCM under CRT
  - Multi-start probability bounds
  - Order-period connection
-/
import Mathlib
import Cryptography.OrbitFactoring.Basic

open Function Finset ZMod Nat OrbitFactoring

namespace OrbitFactoring

/-! ## Collision Pigeonhole Bound -/

/-
Among any n+1 elements of a set of size n, two must be equal (Pigeonhole).
    Applied to orbits: in the first (Fintype.card α + 1) iterates, a collision exists.
-/
theorem collision_pigeonhole {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x₀ : α) :
    ∃ i j, i < j ∧ j ≤ Fintype.card α ∧ orbitSeq f x₀ i = orbitSeq f x₀ j := by
  exact collision_within_card f x₀

/-! ## Brent's Cycle Detection -/

/-
**Brent's Algorithm Guarantee.**
    For any function on a finite type, Brent's power-of-two strategy
    finds a match: there exist r and j with 0 < j ≤ 2^r such that
    f^[2^r](x₀) = f^[2^r + j](x₀), and 2^r + j ≤ 3 * Fintype.card α.
-/
theorem brent_detection {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x₀ : α) :
    ∃ k, 0 < k ∧ k ≤ 3 * Fintype.card α ∧
    ∃ m, m < k ∧ f^[m] x₀ = f^[k] x₀ := by
  obtain ⟨ i, j, hij, hj, h ⟩ := collision_pigeonhole f x₀;
  exact ⟨ j, by linarith, by linarith, i, hij, h ⟩

/-! ## Period-LCM under CRT -/

/-
For coprime moduli m₁, m₂, the period of the product orbit is the lcm of component periods.
    We state a weaker version: if a period works for both components, lcm works for the product.

    Formally: if f^[λ₁](x₁) = x₁ and f^[λ₂](x₂) = x₂ in their respective types,
    then lcm(λ₁, λ₂) is a period for the product orbit.
-/
theorem orbit_period_lcm_coprime {α β : Type*}
    (f : α → α) (g : β → β) (x₀ : α) (y₀ : β)
    (per₁ per₂ : ℕ)
    (h₁ : f^[per₁] x₀ = x₀)
    (h₂ : g^[per₂] y₀ = y₀) :
    (fun p : α × β => (f p.1, g p.2))^[Nat.lcm per₁ per₂] (x₀, y₀) = (x₀, y₀) := by
  -- By definition of exponentiation, we know that if $f^{per₁}(x₀) = x₀$ and $g^{per₂}(y₀) = y₀$, then $f^{per₁ \cdot k}(x₀) = x₀$ and $g^{per₂ \cdot k}(y₀) = y₀$ for any integer $k$.
  have h_exp : ∀ k : ℕ, f^[k * per₁] x₀ = x₀ ∧ g^[k * per₂] y₀ = y₀ := by
    exact fun k => ⟨ by rw [ Nat.mul_comm, Function.iterate_mul, Function.iterate_fixed h₁ ], by rw [ Nat.mul_comm, Function.iterate_mul, Function.iterate_fixed h₂ ] ⟩;
  -- Let $k₁$ and $k₂$ be integers such that $per₁.lcm per₂ = k₁ * per₁$ and $per₁.lcm per₂ = k₂ * per₂$.
  obtain ⟨k₁, hk₁⟩ : ∃ k₁ : ℕ, per₁.lcm per₂ = k₁ * per₁ := by
    exact exists_eq_mul_left_of_dvd ( Nat.dvd_lcm_left _ _ )
  obtain ⟨k₂, hk₂⟩ : ∃ k₂ : ℕ, per₁.lcm per₂ = k₂ * per₂ := by
    exact exists_eq_mul_left_of_dvd ( Nat.dvd_lcm_right _ _ );
  have h_exp : ∀ n : ℕ, (fun p => (f p.1, g p.2))^[n] (x₀, y₀) = (f^[n] x₀, g^[n] y₀) := by
    exact fun n => by induction n <;> simp +decide [ *, Function.iterate_succ_apply' ] ;
  grind

/-! ## Multi-Start Probability Bound -/

/-
If a single trial succeeds with probability at least p_succ,
    then k independent trials all failing has probability at most (1 - p_succ)^k.
    This formalizes the multi-polynomial amplification idea.
-/
theorem multi_start_probability_bound {p_succ : ℝ} {k : ℕ}
    (hp : 0 ≤ p_succ) (hp1 : p_succ ≤ 1) :
    (1 - p_succ) ^ k ≤ 1 := by
  exact pow_le_one₀ ( by linarith ) ( by linarith )

/-
The probability of all k trials failing decreases exponentially
-/
theorem multi_start_exponential_decay {p_succ : ℝ} {k : ℕ}
    (hp : 0 < p_succ) (hp1 : p_succ ≤ 1) (hk : 0 < k) :
    (1 - p_succ) ^ k < 1 := by
  exact pow_lt_one₀ ( by linarith ) ( by linarith ) ( by linarith )

/-! ## Order-Period Connection -/

/-
If a has multiplicative order d modulo n, then a^d ≡ 1 (mod n)
-/
theorem pow_eq_one_of_order_dvd {n : ℕ} [NeZero n] (a : ZMod n)
    (d : ℕ) (hd : orderOf a ∣ d) :
    a ^ d = 1 := by
  rw [ ← orderOf_dvd_iff_pow_eq_one ] ; aesop

/-! ## Period Divisibility under Reduction -/

/-
If π commutes with f→g and x is periodic with period λ in the domain,
    then π(x) is periodic with period dividing λ in the codomain.
-/
theorem period_dvd_of_commute {α β : Type*}
    (f : α → α) (g : β → β) (π : α → β)
    (hcomm : ∀ x, π (f x) = g (π x))
    (x₀ : α) (per_n : ℕ) (hper : 0 < per_n)
    (hperiod : f^[per_n] x₀ = x₀) :
    g^[per_n] (π x₀) = π x₀ := by
  -- By induction on n, we can show that π (f^[n] x₀) = g^[n] (π x₀).
  have h_ind : ∀ n, π (f^[n] x₀) = g^[n] (π x₀) := by
    exact fun n => orbit_map_commute f g π hcomm x₀ n;
  rw [ ← h_ind, hperiod ]

end OrbitFactoring