/-! # CatalogBuild.Computation.Factoring.IOFCore

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 13
-/

import Mathlib

/-- The odd leg at step k of the IOF descent. -/
def a (N : ℤ) (k : ℕ) : ℤ := N - 2 * k


/-- The even leg at step k of the IOF descent. -/
def b (N : ℤ) (k : ℕ) : ℤ := ((N - 2 * k) ^ 2 - 1) / 2


/-- The hypotenuse at step k of the IOF descent. -/
def c (N : ℤ) (k : ℕ) : ℤ := ((N - 2 * k) ^ 2 + 1) / 2


/-- The energy function for the IOF descent. -/
def energy (N : ℤ) (k : ℕ) : ℤ := (N - 2 * k) ^ 2


/-- [Section: ## Pythagorean Invariant] -/
theorem pythagorean_invariant (N : ℤ) (k : ℕ) (hN : N % 2 = 1) :
    (a N k) ^ 2 + (b N k) ^ 2 = (c N k) ^ 2 := by
      unfold a b c;
      nlinarith [ Int.ediv_mul_cancel ( show 2 ∣ ( N - 2 * k ) ^ 2 + 1 from even_iff_two_dvd.mp ( by simpa [ parity_simps ] using Int.odd_iff.mpr hN ) ), Int.ediv_mul_cancel ( show 2 ∣ ( N - 2 * k ) ^ 2 - 1 from even_iff_two_dvd.mp ( by simpa [ parity_simps ] using Int.odd_iff.mpr hN ) ) ]


/-- [Section: ## Energy Theorems] -/
theorem energy_nonneg (N : ℤ) (k : ℕ) : 0 ≤ energy N k := by
  exact sq_nonneg _


theorem energy_strict_decrease (N : ℤ) (k : ℕ) (h : 1 < a N k) :
    energy N (k + 1) < energy N k := by
      unfold a at *; rw [ show energy N k = ( N - 2 * k ) ^ 2 by rfl, show energy N ( k + 1 ) = ( N - 2 * ( k + 1 ) ) ^ 2 by rfl ] ; nlinarith;


/-- [Section: ## Factor Revelation] -/
theorem a_at_factor_step (p q : ℕ) (hp : Odd p) (hq : Odd q)
    (hN : p * q > 0) :
    a (↑(p * q)) ((p - 1) / 2) = ↑(p * q) - ↑p + 1 := by
      unfold a; cases' hp with k hk; cases' hq with l hl; norm_num [ hk, hl ] ; ring;


theorem b_divisible_at_factor_step (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hle : p ≤ q) :
    (↑p : ℤ) ∣ b (↑(p * q)) ((p - 1) / 2) := by
      -- Substitute a_k = N - p + 1 into the expression for b_k.
      have hb_factor : b (p * q) ((p - 1) / 2) = (p * q - p) * (p * q - p + 2) / 2 := by
        unfold b;
        cases Nat.Prime.odd_of_ne_two hp hp2 ; cases Nat.Prime.odd_of_ne_two hq hq2 ; norm_num at * ; ring;
        rw [ Int.ediv_eq_of_eq_mul_left ] <;> cases Nat.even_or_odd' p ; aesop ; ring;
        rw [ Int.ediv_mul_cancel ] <;> norm_num [ *, parity_simps ] ; ring;
        norm_num [ ← even_iff_two_dvd, parity_simps ];
      norm_num +zetaDelta at *;
      exact hb_factor.symm ▸ Int.dvd_div_of_mul_dvd ( by exact ⟨ ( q - 1 ) * ( p * q - p + 2 ) / 2, by nlinarith [ Int.ediv_mul_cancel ( show 2 ∣ ( q - 1 : ℤ ) * ( p * q - p + 2 ) from even_iff_two_dvd.mp ( by simp +decide [ mul_sub, parity_simps ] ; have := Nat.Prime.odd_of_ne_two hp hp2; have := Nat.Prime.odd_of_ne_two hq hq2; simp_all +decide [ parity_simps ] ) ) ] ⟩ )


/-- [Section: ## Initial Triple] -/
theorem initial_a (N : ℤ) : a N 0 = N := by
  unfold a; ring;


theorem initial_b (N : ℤ) : b N 0 = (N ^ 2 - 1) / 2 := by
  unfold b; norm_num;


theorem initial_c (N : ℤ) : c N 0 = (N ^ 2 + 1) / 2 := by
  -- By definition of $c$, we have $c N 0 = ((N - 2 * 0) ^ 2 + 1) / 2$.
  simp [c]


/-- [Section: ## Lyapunov Termination] -/
theorem lyapunov_termination (N : ℕ) (hN : 1 < N) (hOdd : Odd N) :
    ∀ k : ℕ, k < (N - 1) / 2 → energy (↑N) (k + 1) < energy (↑N) k := by
      intro k hk; convert energy_strict_decrease ( N : ℤ ) k _ using 1 ;
      unfold a; omega;

