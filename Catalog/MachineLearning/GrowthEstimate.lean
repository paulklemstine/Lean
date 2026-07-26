import Mathlib

/-!
# Growth Estimates for Quadratic Dynamical Orbits

This file proves deterministic growth estimates for the quadratic map
`T_c(x) = x² + c` iterated from prime seeds. These estimates form the
core "renormalization" step: they show that `log |T_c^[n](p)|` is well
approximated by `2^n * log p`, with an error that decays relative to
the dominant term.

## Main Results

- `quad_map_growth_lower`: For large `x`, `|x² + c| ≥ x²/2`.
- `quad_orbit_escape`: Orbits from large prime seeds grow without bound.
- `quad_orbit_positive`: Orbit values stay positive for large prime seeds.
- `log_quad_one_step`: One-step logarithmic estimate for `T_c`.
- `log_iterate_quad_close`: The iterated logarithmic renormalization estimate.
-/

open Real Nat

noncomputable section

/-
For any integer `c` and sufficiently large `x`, we have `x² + c ≥ x²/2`.
    More precisely, for `|x| ≥ 2|c|`, we have `|x² + c| ≥ x²/2`.
-/
theorem quad_map_growth_lower (c : ℤ) :
    ∀ x : ℤ, (2 * |c| + 2 : ℤ) ≤ |x| → |x| ^ 2 / 2 ≤ |x ^ 2 + c| := by
  -- We have |x² + c| ≥ |x|² - |c| by triangle inequality.
  intros x hx
  have h1 : abs (x ^ 2 + c) ≥ abs x ^ 2 - abs c := by
    cases abs_cases ( x ^ 2 + c ) <;> cases abs_cases c <;> cases abs_cases x <;> push_cast [ * ] at * <;> nlinarith;
  exact Int.ediv_le_of_le_mul ( by norm_num ) ( by nlinarith [ abs_nonneg c ] )

/-
For sufficiently large primes `p`, the orbit of `p` under `T_c`
    is strictly increasing: `T_c^[n+1](p) > T_c^[n](p)` for all `n`.
-/
theorem quad_orbit_escape (c : ℤ) :
    ∃ P : ℕ, ∀ p : ℕ, Nat.Prime p → P ≤ p →
      ∀ n : ℕ, (p : ℤ) ≤ ((fun z : ℤ => z ^ 2 + c)^[n]) (p : ℤ) := by
  use Int.natAbs c + 2;
  intro p hp h2p n;
  induction' n with n ih <;> norm_num [ Function.iterate_succ_apply' ];
  cases abs_cases c <;> nlinarith

/-
Orbit values remain positive for large prime seeds.
-/
theorem quad_orbit_positive (c : ℤ) :
    ∃ P : ℕ, ∀ p : ℕ, Nat.Prime p → P ≤ p →
      ∀ n : ℕ, 0 < ((fun z : ℤ => z ^ 2 + c)^[n]) (p : ℤ) := by
  -- By quad_orbit_escape, we can choose P such that for all primes p ≥ P, we have (p : ℤ) ≤ T_c^[n](p) for all n.
  obtain ⟨P, hP⟩ := quad_orbit_escape c
  use P + 2;
  grind

/-
One-step logarithmic estimate: for large `x > 0`,
    `|log(x² + c) - 2 * log(x)| ≤ 2|c|/x²`.
    This captures the key fact that `T_c` acts on logarithms as
    approximate doubling.
-/
theorem log_quad_one_step_bound (c : ℤ) :
    ∃ C : ℝ, 0 < C ∧ ∃ X₀ : ℝ, 0 < X₀ ∧
      ∀ x : ℝ, X₀ ≤ x →
        |Real.log (x ^ 2 + (c : ℝ)) - 2 * Real.log x| ≤ C / x := by
  refine' ⟨ 2 * |↑c| + 1, by positivity, 2 * |↑c| + 2, by positivity, fun x hx => _ ⟩;
  nontriviality;
  rw [ show x ^ 2 + ( c : ℝ ) = x ^ 2 * ( 1 + ( c : ℝ ) / x ^ 2 ) by rw [ mul_add, mul_div_cancel₀ _ ( pow_ne_zero 2 ( by linarith [ abs_nonneg ( c : ℝ ) ] ) ) ] ; ring, Real.log_mul, Real.log_pow ] <;> norm_num;
  · -- For $x$ large enough, $|c/x^2| \leq 1/2$, so we can apply the inequality $|\log(1 + t)| \leq 2|t|$.
    have h_log_ineq : |Real.log (1 + (c : ℝ) / x ^ 2)| ≤ 2 * |(c : ℝ) / x ^ 2| := by
      have h_log_ineq : ∀ t : ℝ, |t| ≤ 1 / 2 → |Real.log (1 + t)| ≤ 2 * |t| := by
        intro t ht; rw [ abs_le ] at *; constructor <;> cases abs_cases t <;> nlinarith [ Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 + t ), Real.log_inv ( 1 + t ), Real.log_le_sub_one_of_pos ( inv_pos.mpr ( by linarith : 0 < 1 + t ) ), mul_inv_cancel₀ ( by linarith : ( 1 + t ) ≠ 0 ) ] ;
      exact h_log_ineq _ ( by rw [ abs_div, abs_sq ] ; rw [ div_le_iff₀ ] <;> nlinarith [ abs_nonneg ( c : ℝ ) ] );
    refine le_trans h_log_ineq ?_;
    rw [ abs_div, abs_sq ];
    rw [ mul_div, div_le_div_iff₀ ] <;> nlinarith [ abs_nonneg ( c : ℝ ), mul_le_mul_of_nonneg_left ( show x ≥ 2 by linarith [ abs_nonneg ( c : ℝ ) ] ) ( abs_nonneg ( c : ℝ ) ) ];
  · linarith [ abs_nonneg ( c : ℝ ) ];
  · rw [ add_div', div_eq_iff ] <;> cases abs_cases ( c : ℝ ) <;> nlinarith

/-
**Main growth-renormalization theorem for quadratic maps.**

    For `T_c(x) = x² + c` with fixed integer `c`, there exist constants
    `C > 0` and `P > 0` such that for every prime `p ≥ P` and every `n ≥ 0`:
    `|log |T_c^[n](p)| - 2^n * log p| ≤ C * 2^n / p`.

    This reduces the Benford question for quadratic prime orbits to the
    equidistribution of `2^n * log_b(p) mod 1`.
-/
theorem log_iterate_quad_close (c : ℤ) :
    ∃ C P : ℝ, 0 < C ∧ 0 < P ∧
      ∀ p : ℕ, Nat.Prime p → P ≤ (p : ℝ) →
        ∀ n : ℕ,
          |Real.log (|(((fun z : ℤ => z ^ 2 + c)^[n]) (p : ℤ) : ℝ)|) -
            (2 ^ n : ℝ) * Real.log (p : ℝ)| ≤ C * (2 ^ n : ℝ) / (p : ℝ) := by
  -- Use the results from log_quad_one_step_bound and quad_orbit_escape.
  obtain ⟨C, hC_pos, X₀, hX₀_pos, hC_bound⟩ : ∃ C : ℝ, 0 < C ∧ ∃ X₀ : ℝ, 0 < X₀ ∧ ∀ x : ℝ, X₀ ≤ x → |Real.log (x ^ 2 + (c : ℝ)) - 2 * Real.log x| ≤ C / x := by
    exact?
  obtain ⟨P₀, hP₀⟩ : ∃ P₀ : ℕ, ∀ p : ℕ, Nat.Prime p → P₀ ≤ p → ∀ n : ℕ, (p : ℤ) ≤ ((fun z : ℤ => z ^ 2 + c)^[n]) (p : ℤ) := by
    exact?;
  refine' ⟨ C, Max.max ( P₀ + 1 ) ( ⌈X₀⌉₊ + 1 ), _, _, _ ⟩ <;> norm_num;
  · grobner;
  · exact Or.inl <| Nat.cast_add_one_pos _;
  · -- By induction on $n$, we can show that the bound holds.
    have h_ind : ∀ p : ℕ, Nat.Prime p → P₀ + 1 ≤ p → ⌈X₀⌉₊ + 1 ≤ p → ∀ n : ℕ, |Real.log ((fun z : ℤ => z ^ 2 + c)^[n] (p : ℤ)) - 2 ^ n * Real.log p| ≤ ∑ k ∈ Finset.range n, 2 ^ (n - 1 - k) * (C / ((fun z : ℤ => z ^ 2 + c)^[k] (p : ℤ))) := by
      intro p hp hp₀ hp₁ n; induction' n with n ih <;> simp_all +decide [ Function.iterate_succ_apply', pow_succ', mul_assoc, mul_comm, mul_left_comm, Finset.sum_range_succ ] ;
      have h_step : |Real.log ((fun z : ℤ => z ^ 2 + c)^[n + 1] (p : ℤ)) - 2 * Real.log ((fun z : ℤ => z ^ 2 + c)^[n] (p : ℤ))| ≤ C / ((fun z : ℤ => z ^ 2 + c)^[n] (p : ℤ)) := by
        convert hC_bound _ _ using 2;
        · norm_num [ Function.iterate_succ_apply' ];
        · exact le_trans ( Nat.le_ceil _ ) ( mod_cast by linarith [ hP₀ p hp ( by linarith ) n ] );
      simp_all +decide [ Function.iterate_succ_apply', pow_succ', mul_assoc, mul_comm, mul_left_comm, Finset.sum_range_succ' ];
      convert le_trans ( abs_sub_le _ _ _ ) ( add_le_add ( show |Real.log ( ( ( fun z : ℤ => z ^ 2 + c ) ^[ n ] p : ℤ ) ^ 2 + c ) - 2 * Real.log ( ( fun z : ℤ => z ^ 2 + c ) ^[ n ] p )| ≤ C / ( ( fun z : ℤ => z ^ 2 + c ) ^[ n ] p : ℤ ) from h_step ) ( show |2 * Real.log ( ( fun z : ℤ => z ^ 2 + c ) ^[ n ] p ) - 2 ^ ( n + 1 ) * Real.log p| ≤ ∑ k ∈ Finset.range n, 2 ^ ( n - k ) * ( C / ( ( fun z : ℤ => z ^ 2 + c ) ^[ k ] p : ℤ ) ) from ?_ ) ) using 1;
      · ring;
      · convert mul_le_mul_of_nonneg_left ih zero_le_two using 1 <;> ring;
        · rw [ show ( fun z : ℤ => c + z ^ 2 ) = fun z : ℤ => z ^ 2 + c by ext; ring ] ; rw [ ← abs_of_nonneg ( by positivity : ( 0 : ℝ ) ≤ 2 ) ] ; rw [ ← abs_mul ] ; ring;
          grind +suggestions;
        · rw [ Finset.sum_mul _ _ _ ] ; refine' Finset.sum_congr rfl fun x hx => _ ; rw [ show n - x = n - 1 - x + 1 from tsub_eq_of_eq_add <| by linarith [ Nat.sub_add_cancel <| show 1 ≤ n from Nat.pos_of_ne_zero <| by aesop_cat, Nat.sub_add_cancel <| show x ≤ n - 1 from Nat.le_sub_one_of_lt <| Finset.mem_range.mp hx ] ] ; ring;
          ac_rfl;
    -- Since $|x_k| \geq p$ for all $k$, we have $\frac{C}{|x_k|} \leq \frac{C}{p}$.
    have h_bound : ∀ p : ℕ, Nat.Prime p → P₀ + 1 ≤ p → ⌈X₀⌉₊ + 1 ≤ p → ∀ n : ℕ, ∑ k ∈ Finset.range n, 2 ^ (n - 1 - k) * (C / ((fun z : ℤ => z ^ 2 + c)^[k] (p : ℤ))) ≤ ∑ k ∈ Finset.range n, 2 ^ (n - 1 - k) * (C / p) := by
      intros p hp hp₀ hp₁ n;
      gcongr;
      · exact Nat.cast_pos.mpr hp.pos;
      · exact_mod_cast hP₀ p hp ( by linarith ) _;
    -- The sum $\sum_{k=0}^{n-1} 2^{n-1-k}$ is a geometric series with sum $2^n - 1$.
    have h_geo_series : ∀ n : ℕ, ∑ k ∈ Finset.range n, (2 : ℝ) ^ (n - 1 - k) = 2 ^ n - 1 := by
      intro n; rw [ ← Finset.sum_range_reflect ] ;
      rw [ Finset.sum_congr rfl fun x hx => by rw [ tsub_tsub_cancel_of_le ( Nat.le_sub_one_of_lt ( Finset.mem_range.mp hx ) ) ] ] ; norm_num [ ← geom_sum_mul ];
    simp_all +decide [ ← Finset.sum_mul _ _ _ ];
    intro p hp hp' hp'' n; refine' le_trans ( h_ind p hp ( mod_cast hp' ) ( mod_cast hp'' ) n ) ( le_trans ( h_bound p hp ( mod_cast hp' ) ( mod_cast hp'' ) n ) _ ) ; ring_nf; norm_num;
    positivity

end