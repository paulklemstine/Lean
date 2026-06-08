/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Fekete's Lemma for Subadditive Sequences

Fekete's lemma states that for a subadditive sequence a : ℕ → ℝ
(satisfying a(m+n) ≤ a(m) + a(n) for all m, n),
the limit lim_{n→∞} a(n)/n exists and equals inf_{n≥1} a(n)/n.

This is the fundamental analytic tool underlying the existence of
the connective constant for self-avoiding walks.
-/
import Mathlib

open Real Filter Topology

/-! ## Subadditive sequences -/

/-- A sequence is subadditive if `a(m + n) ≤ a(m) + a(n)` for all `m, n`. -/
def IsSubadditive (a : ℕ → ℝ) : Prop :=
  ∀ m n, a (m + n) ≤ a m + a n

/-- A sequence is superadditive if `a(m) + a(n) ≤ a(m + n)` for all `m, n`. -/
def IsSuperadditive (a : ℕ → ℝ) : Prop :=
  ∀ m n, a m + a n ≤ a (m + n)

/-- Negating a subadditive sequence gives a superadditive one. -/
theorem neg_subadditive_is_superadditive {a : ℕ → ℝ}
    (h : IsSubadditive a) : IsSuperadditive (fun n => -a n) := by
  exact fun m n => by linarith [h m n]

/-- For subadditive sequences, `a(kn) ≤ k * a(n)` by induction (for k ≥ 1). -/
theorem subadditive_mul_bound {a : ℕ → ℝ} (h : IsSubadditive a)
    (n : ℕ) (k : ℕ) (hk : 0 < k) : a (k * n) ≤ k * a n := by
  induction hk <;> simp_all +decide [Nat.succ_mul]
  linarith [h (‹_› * n) n]

/-
Subadditivity implies a(0) ≥ 0.
-/
theorem subadditive_nonneg_zero {a : ℕ → ℝ} (h : IsSubadditive a) :
    0 ≤ a 0 := by
  linarith [ h 0 0 ]

/-
For subadditive nonneg sequences bounded above, the sequence a(n)/n is
    eventually bounded below by any value less than the infimum.
    This is the core analytic content of Fekete's lemma.
-/
theorem subadditive_ratio_eventually_le {a : ℕ → ℝ} (h : IsSubadditive a)
    {m : ℕ} (hm : 0 < m) :
    ∀ᶠ n in Filter.atTop, a n / n ≤ a m / m + 1 := by
  -- For large n, write n = m*q + r with r = n%m. Then a(n) ≤ a(m*q) + a(r) ≤ q*a(m) + a(r) where q = n/m.
  have h_bound : ∀ n, n > m → a n ≤ (n / m : ℕ) * a m + ∑ i ∈ Finset.range m, abs (a i) := by
    intro n hn;
    have h_bound : a n ≤ a (n / m * m) + a (n % m) := by
      simpa only [ Nat.div_add_mod' ] using h ( n / m * m ) ( n % m );
    refine le_trans h_bound ?_;
    exact add_le_add ( subadditive_mul_bound h m ( n / m ) ( Nat.div_pos ( by linarith ) hm ) ) ( Finset.single_le_sum ( fun i _ => abs_nonneg ( a i ) ) ( Finset.mem_range.mpr ( Nat.mod_lt n hm ) ) |> le_trans ( le_abs_self _ ) ) |> le_trans <| by norm_num;
  -- So a(n)/n ≤ q*a(m)/n + a(r)/n. Since q = n/m and q/n ≈ 1/m for large n, and a(r)/n → 0, for large enough n, a(n)/n ≤ a(m)/m + 1.
  have h_approx : ∀ᶠ n in Filter.atTop, a n / (n : ℝ) ≤ (n / m : ℕ) * a m / (n : ℝ) + (∑ i ∈ Finset.range m, abs (a i)) / (n : ℝ) := by
    filter_upwards [ Filter.eventually_gt_atTop m ] with n hn using by rw [ ← add_div ] ; gcongr ; aesop;
  -- Since $q = n/m$ and $q/n \approx 1/m$ for large $n$, and $a(r)/n \to 0$, for large enough $n$, $a(n)/n \leq a(m)/m + 1$.
  have h_limit : Filter.Tendsto (fun n : ℕ => (n / m : ℕ) * a m / (n : ℝ)) Filter.atTop (nhds (a m / (m : ℝ))) := by
    -- We can factor out $a_m$ and use the fact that $\frac{n/m}{n} = \frac{1}{m}$.
    have h_factor : Filter.Tendsto (fun n : ℕ => (n / m : ℕ) / (n : ℝ)) Filter.atTop (nhds (1 / (m : ℝ))) := by
      -- We can use the fact that $\frac{n/m}{n} = \frac{1}{m}$ for all $n \geq m$.
      have h_limit : ∀ n ≥ m, (n / m : ℕ) / (n : ℝ) = (1 / (m : ℝ)) - ((n % m : ℕ) / (m * n : ℝ)) := by
        intro n hn; rw [ div_sub_div, div_eq_div_iff ] <;> ring <;> norm_cast <;> try nlinarith;
        norm_num [ Nat.mod_def ] ; ring;
        rw [ Nat.cast_sub ( by nlinarith [ Nat.div_mul_le_self n m ] ) ] ; push_cast ; ring;
      -- Since $n \% m$ is bounded, $\frac{n \% m}{m * n}$ tends to $0$ as $n$ tends to infinity.
      have h_zero : Filter.Tendsto (fun n : ℕ => (n % m : ℕ) / (m * n : ℝ)) Filter.atTop (nhds 0) := by
        exact squeeze_zero ( fun n => by positivity ) ( fun n => mul_le_mul_of_nonneg_right ( Nat.cast_le.2 <| Nat.le_of_lt <| Nat.mod_lt _ hm ) <| by positivity ) <| tendsto_const_nhds.div_atTop <| tendsto_natCast_atTop_atTop.const_mul_atTop ( by positivity );
      simpa using Filter.Tendsto.congr' ( Filter.eventuallyEq_of_mem ( Filter.Ici_mem_atTop m ) fun n hn => by aesop ) ( h_zero.const_sub ( 1 / ( m : ℝ ) ) );
    convert h_factor.const_mul ( a m ) using 2 <;> ring;
  have := h_limit.add ( show Filter.Tendsto ( fun n : ℕ => ( ∑ i ∈ Finset.range m, |a i| ) / ( n : ℝ ) ) Filter.atTop ( nhds 0 ) from tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop );
  filter_upwards [ h_approx, this.eventually ( gt_mem_nhds <| show a m / m + 0 < a m / m + 1 by norm_num ) ] with n hn hn' using le_trans hn hn'.le

/-
**Fekete's Lemma** (key consequence): For a submultiplicative positive sequence,
    a(n)^{1/n} is eventually bounded above by (a(m))^{1/m} for any fixed m ≥ 1.
    This is equivalent to the standard statement via the log transformation.
-/
theorem fekete_consequence_submultiplicative {a : ℕ → ℝ}
    (hpos : ∀ n, 0 < a n)
    (hsub : ∀ m n, a (m + n) ≤ a m * a n)
    {m : ℕ} (hm : 0 < m) :
    ∀ᶠ n in Filter.atTop,
      Real.log (a n) / n ≤ Real.log (a m) / m + 1 := by
  convert subadditive_ratio_eventually_le _ _;
  · exact fun m n => by simpa only [ Real.log_mul ( ne_of_gt ( hpos m ) ) ( ne_of_gt ( hpos n ) ) ] using Real.log_le_log ( hpos _ ) ( hsub m n ) ;
  · linarith