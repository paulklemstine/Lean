/-! # CatalogBuild.Pythagorean.FutureResearch.ParityObstructions

Auto-generated from theorem catalog database.
Domain: Pythagorean/FutureResearch
Declarations: 8
-/

import Mathlib

/-- For odd N, both N-x and N+x are even iff x is odd. -/
theorem parity_constraint_odd_N (N x : ℤ) (hN : ¬ 2 ∣ N) :
    (2 ∣ (N - x) ∧ 2 ∣ (N + x)) ↔ ¬ 2 ∣ x := by
  simp only [Int.dvd_iff_emod_eq_zero]
  omega



/-- When both d-x and d+x are even, their product is divisible by 4. -/
theorem even_peel_div_four (d x : ℤ)
    (h1 : 2 ∣ (d - x)) (h2 : 2 ∣ (d + x)) :
    4 ∣ (d - x) * (d + x) := by
  obtain ⟨a, ha⟩ := h1
  obtain ⟨b, hb⟩ := h2
  exact ⟨a * b, by rw [ha, hb]; ring⟩



/-- [Section: # CatalogBuild.Pythagorean.FutureResearch.ParityObstructions
Auto-generated from theorem catalog database.
Domain: Pythagorean/FutureResearch
Declarations: 8] -/
theorem three_mod_four_not_sum_two_sq (n : ℤ) (hn : n % 4 = 3) :
    ¬ ∃ a b : ℤ, a^2 + b^2 = n := by
  exact fun ⟨ a, b, h ⟩ => by have := congr_arg ( · % 4 ) h; norm_num [ sq, Int.mul_emod, Int.add_emod ] at this; have := Int.emod_nonneg a four_pos.ne'; have := Int.emod_nonneg b four_pos.ne'; have := Int.emod_lt_of_pos a four_pos; have := Int.emod_lt_of_pos b four_pos; interval_cases a % 4 <;> interval_cases b % 4 <;> simp_all +decide only ;



theorem seven_mod_eight_not_sum_three_sq (n : ℤ) (hn : n % 8 = 7) :
    ¬ ∃ a b c : ℤ, a^2 + b^2 + c^2 = n := by
  exact fun ⟨ a, b, c, h ⟩ => by rw [ ← h ] at hn; exact absurd ( congrArg ( · % 8 ) hn ) ( by norm_num [ sq, Int.add_emod, Int.mul_emod ] ; have := Int.emod_nonneg a ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg b ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg c ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos a ( by norm_num : ( 8 : ℤ ) > 0 ) ; have := Int.emod_lt_of_pos b ( by norm_num : ( 8 : ℤ ) > 0 ) ; have := Int.emod_lt_of_pos c ( by norm_num : ( 8 : ℤ ) > 0 ) ; interval_cases a % 8 <;> interval_cases b % 8 <;> interval_cases c % 8 <;> trivial ) ;



/-- For any semiprime N = p*q, a peel channel gives a divisor. -/
theorem semiprime_peel_compatible (p q xⱼ : ℤ) :
    ↑(Int.gcd (p * q - xⱼ) (p * q)) ∣ (p * q) :=
  Int.gcd_dvd_right _ _



/-- When N is odd and xⱼ is even, N - xⱼ is odd. -/
theorem even_leg_channel_works (N xⱼ : ℤ)
    (hN : ¬ 2 ∣ N) (hx : 2 ∣ xⱼ) :
    ¬ 2 ∣ (N - xⱼ) := by
  rw [Int.dvd_iff_emod_eq_zero] at hN hx ⊢; omega



/-- When N is odd and xⱼ is even, both N-xⱼ and N+xⱼ are odd.
This means peel factors are odd and can match odd prime factors. -/
theorem odd_peel_factor_is_odd (N xⱼ : ℤ)
    (hN : ¬ 2 ∣ N) (hx : 2 ∣ xⱼ) :
    ¬ 2 ∣ (N - xⱼ) ∧ ¬ 2 ∣ (N + xⱼ) := by
  constructor
  · exact even_leg_channel_works N xⱼ hN hx
  · rw [Int.dvd_iff_emod_eq_zero] at hN hx ⊢; omega



theorem triple_parity (a b c : ℤ) (h : a^2 + b^2 = c^2) (hc : ¬ 2 ∣ c) :
    (2 ∣ a ∧ ¬ 2 ∣ b) ∨ (¬ 2 ∣ a ∧ 2 ∣ b) := by
  -- Since $c$ is odd, $c^2 \equiv 1 \pmod{4}$. Therefore, $a^2 + b^2 \equiv 1 \pmod{4}$ by substituting $c^2$ with $1$.
  have h_mod : a ^ 2 + b ^ 2 ≡ 1 [ZMOD 4] := by
    exact h.symm ▸ Int.sq_mod_four_eq_one_of_odd ( by simpa [ ← even_iff_two_dvd ] using hc )
  generalize_proofs at *; (
  rcases Int.even_or_odd' a with ⟨ k, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ l, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.ModEq ] at *;)

