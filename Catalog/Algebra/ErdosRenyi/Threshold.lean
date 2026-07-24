/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Asymptotic threshold phenomena for `G(n, p)`

This file turns the *exact* first–moment expectations proved in
`Catalog.Algebra.ErdosRenyi.Concrete` into genuine **asymptotic** statements
about the Erdős–Rényi model, isolating the threshold scalings.

The triangle threshold lives at `p = 1/n`.  We prove:

* `ErdosRenyiThreshold.tendsto_expected_triangles` — the **critical window**: at
  `p = c/n` the expected number of triangles tends to `c³/6`.  This is the exact
  Poisson-mean constant that governs the phase transition at `p = 1/n`.
* `ErdosRenyiThreshold.subcritical_triangles_vanish` — the **subcritical / below
  threshold** half: whenever `n · pₙ → 0` the expected triangle count tends to
  `0`, so (by the first moment method `firstMoment`) `G(n, pₙ)` is triangle-free
  with high probability.
* `ErdosRenyiThreshold.supercritical_triangles_blowup` — the **supercritical /
  above threshold** half: whenever `n · pₙ → ∞` (with `pₙ ≤ 1`) the expected
  triangle count tends to `∞`.

For connectivity (threshold `ln n / n`) we use the exact isolated–vertex
expectation `n · (1−p)^{n−1}`:

* `ErdosRenyiThreshold.isolated_blowup_below_connectivity` — at the *giant-component*
  scale `p = c/n` the expected number of isolated vertices tends to `∞`, i.e. the
  giant-component scale `1/n` is strictly below the connectivity scale `ln n / n`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the exact expectations from `Concrete.lean`
  (`C(n,3) p³` for triangles, `n (1−p)^{n−1}` for isolated vertices) already
  *contain* the thresholds; extracting them is a pure limit computation, with the
  triangle threshold at `p = 1/n` (because `C(n,3) (c/n)³ → c³/6`) and the
  connectivity threshold strictly higher at `ln n / n`.
Experiment (Stage 2): write `C(n,3) = n(n−1)(n−2)/6`; then
  `C(n,3)(c/n)³ = c³/6 · (1)(1−1/n)(1−2/n) → c³/6`.  Subcritical vanishing is a
  squeeze `0 ≤ C(n,3) pₙ³ ≤ (n pₙ)³/6 → 0`.  Supercritical blow-up compares
  `C(n,3) pₙ³ ≥ (n pₙ)³/216` for large `n` (since `C(n,3) ≥ n³/216` once
  `n ≥ 3`).  Isolated-vertex blow-up at `p = c/n` uses `(1−c/n)^{n−1} → e^{-c} > 0`
  and `n → ∞`, so the product diverges.
Analysis (Stage 3): the triangle results are clean rational-function limits; the
  isolated-vertex divergence needs the classical `(1 + x/n)^n → eˣ` limit and a
  positive-times-`atTop` argument.  The constant `c³/6` is exactly the Poisson
  mean of the number of triangles in the critical window, confirming `p = 1/n` as
  the triangle/giant-component scale.
Critique (Stage 4): these are honest `Filter.Tendsto` statements (no `decide`),
  built on the separately verified exact expectations; the subcritical half is
  paired with `firstMoment` to give an actual "triangle-free whp" conclusion.
  Sharp two-sided connectivity is still out of reach and recorded in
  `FUTURE_DIRECTIONS.md`.
Synthesis (Stage 5): together with `Model.lean` (first moment) and
  `SecondMoment.lean` (second moment) this completes the moment-method picture of
  the thresholds at `1/n` (subgraphs) and `ln n / n` (connectivity).
-/
import Mathlib
import Catalog.Algebra.ErdosRenyi.Model
import Catalog.Algebra.ErdosRenyi.Concrete

open Finset BigOperators Filter Topology ErdosRenyi ErdosRenyiConcrete

namespace ErdosRenyiThreshold

/-- **Critical window for triangles.** At density `p = c/n` the expected number of
triangles in `G(n,p)`, namely `C(n,3) · (c/n)³`, converges to `c³/6`.  This is the
Poisson mean that controls the phase transition at the scale `p = 1/n`.
-/
theorem tendsto_expected_triangles (c : ℝ) :
    Tendsto (fun n : ℕ => (n.choose 3 : ℝ) * (c / n) ^ 3) atTop (𝓝 (c ^ 3 / 6)) := by
  -- For n ≥ 3, (n.choose 3 : ℝ) = (n:ℝ)*(n-1)*(n-2)/6.
  have h_choose : ∀ n : ℕ, 3 ≤ n → (Nat.choose n 3 : ℝ) = (n * (n - 1) * (n - 2)) / 6 := by
    intro n hn; rw [ Nat.cast_choose ] <;> try linarith;
    rcases n with ( _ | _ | _ | n ) <;> norm_num [ Nat.factorial ] at *;
    rw [ div_eq_div_iff ] <;> first | positivity | ring!;
  -- For n ≥ 3, (n.choose 3 : ℝ) * (c / n)^3 = (c^3 / 6) * (1 - 1/n) * (1 - 2/n).
  have h_rewrite : ∀ n : ℕ, 3 ≤ n → (Nat.choose n 3 : ℝ) * (c / n)^3 = (c^3 / 6) * (1 - 1 / (n : ℝ)) * (1 - 2 / (n : ℝ)) := by
    intro n hn; rw [ h_choose n hn ]; field_simp
  rw [ Filter.tendsto_congr' ( Filter.eventuallyEq_of_mem ( Filter.Ici_mem_atTop 3 ) h_rewrite ) ] ; exact le_trans ( Filter.Tendsto.mul ( Filter.Tendsto.mul tendsto_const_nhds <| tendsto_const_nhds.sub <| tendsto_one_div_atTop_nhds_zero_nat ) <| tendsto_const_nhds.sub <| tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop ) ( by norm_num ) ;

/-- **Subcritical triangles (below threshold).** If `n · pₙ → 0` then the expected
number of triangles `C(n,3) · pₙ³` tends to `0`.  Combined with `firstMoment`, this
shows `G(n, pₙ)` is triangle-free with high probability below the `1/n` scale.
-/
theorem subcritical_triangles_vanish (p : ℕ → ℝ) (hp0 : ∀ n, 0 ≤ p n)
    (h : Tendsto (fun n : ℕ => (n : ℝ) * p n) atTop (𝓝 0)) :
    Tendsto (fun n => (n.choose 3 : ℝ) * (p n) ^ 3) atTop (𝓝 0) := by
  -- By the properties of binomial coefficients, we know that $\binom{n}{3} \leq \frac{n^3}{6}$ for all $n$.
  have h_binom : ∀ n : ℕ, (n.choose 3 : ℝ) ≤ (n^3 : ℝ) / 6 := by
    intro n; rw [ le_div_iff₀ ] <;> norm_cast;
    rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ Nat.choose_eq_factorial_div_factorial ];
    norm_num [ Nat.factorial_succ ];
    norm_num [ ← mul_assoc, Nat.mul_div_mul_right _ _ ( Nat.factorial_pos _ ) ];
    exact le_trans ( Nat.mul_div_le _ _ ) ( by nlinarith [ sq n ] );
  refine' squeeze_zero ( fun n => mul_nonneg ( Nat.cast_nonneg _ ) ( pow_nonneg ( hp0 n ) _ ) ) ( fun n => mul_le_mul_of_nonneg_right ( h_binom n ) ( pow_nonneg ( hp0 n ) _ ) ) _;
  convert h.pow 3 |> Filter.Tendsto.div_const <| 6 using 2 <;> ring

/-- **Supercritical triangles (above threshold).** If `n · pₙ → ∞` (with
`pₙ ≥ 0`) then the expected number of triangles `C(n,3) · pₙ³` tends to `∞`.
-/
theorem supercritical_triangles_blowup (p : ℕ → ℝ) (hp0 : ∀ n, 0 ≤ p n)
    (h : Tendsto (fun n : ℕ => (n : ℝ) * p n) atTop atTop) :
    Tendsto (fun n => (n.choose 3 : ℝ) * (p n) ^ 3) atTop atTop := by
  -- We use the fact that for large $n$, $n.choose 3 \geq \frac{n^3}{162}$.
  have h_lower_bound : ∃ N, ∀ n ≥ N, (Nat.choose n 3 : ℝ) ≥ (n : ℝ) ^ 3 / 162 := by
    use 6; intro n hn; induction hn <;> norm_num [ Nat.choose ] at *;
    rw [ Nat.choose_two_right ];
    rw [ Nat.cast_div ] <;> norm_num;
    · rw [ Nat.cast_sub ] <;> push_cast <;> nlinarith [ ( by norm_cast : ( 6 : ℝ ) ≤ ↑‹ℕ› ) ];
    · exact even_iff_two_dvd.mp ( Nat.even_mul_pred_self _ );
  -- Using the lower bound, we can show that for large $n$, $(n.choose 3 : ℝ) * (p n)^3 \geq ((n:ℝ)*p n)^3 / 162$.
  have h_lower_bound_mul : ∃ N, ∀ n ≥ N, (Nat.choose n 3 : ℝ) * (p n) ^ 3 ≥ ((n : ℝ) * p n) ^ 3 / 162 := by
    exact ⟨ h_lower_bound.choose, fun n hn => by nlinarith [ h_lower_bound.choose_spec n hn, pow_nonneg ( hp0 n ) 3 ] ⟩;
  exact Filter.tendsto_atTop_mono' Filter.atTop ( Filter.eventually_atTop.mpr h_lower_bound_mul ) ( by exact Filter.Tendsto.atTop_div_const ( by norm_num ) ( Filter.Tendsto.comp ( Filter.tendsto_pow_atTop ( by norm_num ) ) h ) )

/-- **Isolated vertices at the giant-component scale.** At density `p = c/n`
the expected number of isolated vertices `n · (1 − c/n)^{n−1}` tends to `∞`
(for every real `c`).  Hence the giant-component scale `1/n` lies strictly below
the connectivity threshold `ln n / n`: at `p = c/n` the graph still has many
isolated vertices. -/
theorem isolated_blowup_below_connectivity (c : ℝ) :
    Tendsto (fun n : ℕ => (n : ℝ) * (1 - c / n) ^ (n - 1)) atTop atTop := by
  -- We'll use the fact that $(1 - \frac{c}{n})^{n-1}$ converges to $e^{-c}$ as $n \to \infty$.
  have h_exp : Filter.Tendsto (fun n : ℕ => (1 - c / (n : ℝ)) ^ (n - 1)) Filter.atTop (nhds (Real.exp (-c))) := by
    have h_exp : Filter.Tendsto (fun n : ℕ => (1 - c / (n : ℝ)) ^ n) Filter.atTop (nhds (Real.exp (-c))) := by
      convert Real.tendsto_one_add_div_pow_exp _ using 2 ; ring;
    have h_exp : Filter.Tendsto (fun n : ℕ => ((1 - c / (n : ℝ)) ^ n) / (1 - c / (n : ℝ))) Filter.atTop (nhds (Real.exp (-c))) := by
      convert h_exp.div ( tendsto_const_nhds.sub ( tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop ) ) _ using 1 <;> norm_num;
    refine h_exp.congr' ( by filter_upwards [ Filter.eventually_gt_atTop ⌈c⌉₊ ] with n hn; rw [ div_eq_iff ( ne_of_gt <| sub_pos.mpr <| by rw [ div_lt_iff₀ ] <;> nlinarith [ Nat.le_ceil c, show ( n : ℝ ) ≥ ⌈c⌉₊ + 1 by exact_mod_cast hn ] ) ] ; rw [ ← pow_succ, Nat.sub_add_cancel <| by linarith [ Nat.le_ceil c, show ( n : ℕ ) ≥ ⌈c⌉₊ + 1 by exact_mod_cast hn ] ] );
  apply_rules [ Filter.Tendsto.atTop_mul_pos, tendsto_natCast_atTop_atTop ];
  positivity

/-- **Triangle count in the genuine `G(n,p)` model, critical window.** Phrased
directly in terms of the Erdős–Rényi expectation from `Concrete.lean`: at density
`p = c/n` the expected number of triangles in `G(n, c/n)` tends to `c³/6`.
This is `tendsto_expected_triangles` transported across `expected_triangles`. -/
theorem tendsto_ER_expected_triangles (c : ℝ) :
    Tendsto (fun n : ℕ =>
        expectation (c / n)
          (fun g : Edge n → Bool =>
            (((Finset.univ.powersetCard 3).filter
              (fun T => g ∈ allPresent (triEdges T))).card : ℝ)))
      atTop (𝓝 (c ^ 3 / 6)) := by
  have hfun : (fun n : ℕ =>
        expectation (c / n)
          (fun g : Edge n → Bool =>
            (((Finset.univ.powersetCard 3).filter
              (fun T => g ∈ allPresent (triEdges T))).card : ℝ)))
      = (fun n : ℕ => (n.choose 3 : ℝ) * (c / n) ^ 3) := by
    funext n; exact ErdosRenyiConcrete.expected_triangles (c / n)
  rw [hfun]; exact tendsto_expected_triangles c

/-- **Isolated vertices in the genuine `G(n,p)` model, giant-component scale.**
Phrased directly in terms of the Erdős–Rényi expectation from `Concrete.lean`: at
density `p = c/n` the expected number of isolated vertices in `G(n, c/n)` tends to
`∞`.  This is `isolated_blowup_below_connectivity` transported across
`expected_isolated`. -/
theorem tendsto_ER_expected_isolated (c : ℝ) :
    Tendsto (fun n : ℕ =>
        expectation (c / n)
          (fun g : Edge n → Bool =>
            ((Finset.univ.filter
              (fun v : Fin n => g ∈ allAbsent (incident v))).card : ℝ)))
      atTop atTop := by
  have hfun : (fun n : ℕ =>
        expectation (c / n)
          (fun g : Edge n → Bool =>
            ((Finset.univ.filter
              (fun v : Fin n => g ∈ allAbsent (incident v))).card : ℝ)))
      = (fun n : ℕ => (n : ℝ) * (1 - c / n) ^ (n - 1)) := by
    funext n; exact ErdosRenyiConcrete.expected_isolated (c / n)
  rw [hfun]; exact isolated_blowup_below_connectivity c

end ErdosRenyiThreshold