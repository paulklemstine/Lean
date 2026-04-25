/-! # CatalogBuild.Cryptography.Factoring.Advanced

Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 7
-/

import CatalogBuild.Cryptography.Factoring.Basic
import Mathlib

/-- [Section: # CatalogBuild.Cryptography.Factoring.Advanced
Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 7] -/
theorem collision_pigeonhole {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x₀ : α) :
    ∃ i j, i < j ∧ j ≤ Fintype.card α ∧ orbitSeq f x₀ i = orbitSeq f x₀ j := by
  exact collision_within_card f x₀


/-- [Section: # CatalogBuild.Cryptography.Factoring.Advanced
Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 7] -/
theorem brent_detection {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x₀ : α) :
    ∃ k, 0 < k ∧ k ≤ 3 * Fintype.card α ∧
    ∃ m, m < k ∧ f^[m] x₀ = f^[k] x₀ := by
  obtain ⟨ i, j, hij, hj, h ⟩ := collision_pigeonhole f x₀;
  exact ⟨ j, by linarith, by linarith, i, hij, h ⟩


/-- [Section: # CatalogBuild.Cryptography.Factoring.Advanced
Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 7] -/
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


theorem multi_start_probability_bound {p_succ : ℝ} {k : ℕ}
    (hp : 0 ≤ p_succ) (hp1 : p_succ ≤ 1) :
    (1 - p_succ) ^ k ≤ 1 := by
  exact pow_le_one₀ ( by linarith ) ( by linarith )


theorem multi_start_exponential_decay {p_succ : ℝ} {k : ℕ}
    (hp : 0 < p_succ) (hp1 : p_succ ≤ 1) (hk : 0 < k) :
    (1 - p_succ) ^ k < 1 := by
  exact pow_lt_one₀ ( by linarith ) ( by linarith ) ( by linarith )


theorem pow_eq_one_of_order_dvd {n : ℕ} [NeZero n] (a : ZMod n)
    (d : ℕ) (hd : orderOf a ∣ d) :
    a ^ d = 1 := by
  rw [ ← orderOf_dvd_iff_pow_eq_one ] ; aesop


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


