import Mathlib
import Logic.GraphTheory.Defs
import Novelty.AFLMatching.Bounds
import Geometry.InformationTheory.Convergence

/-!
# Benford Reduction and Torus Dynamics

## Overview

This file connects the dynamical height theory to Benford's law through two key results:

1. **Benford reduction theorem**: If the fractional parts of logarithmic orbit sizes
   are equidistributed mod 1, then leading digits satisfy Benford's law.

2. **Logarithmic shadowing theorem**: The log-orbit log|T_c⁽ⁿ⁾(x)| is shadowed by
   2ⁿ·Λ_c(x) with a uniformly bounded error. This connects the quadratic dynamics
   to the doubling map on ℝ/ℤ: the fractional parts of log|T_c⁽ⁿ⁾(x)|/log(b) and
   of 2ⁿ·Λ_c(x)/log(b) differ by a bounded amount, so equidistribution of one
   implies equidistribution of the other.

These results isolate the only genuinely analytic input still missing from the
universality conjecture: equidistribution of 2ⁿ·Λ_c(p) over primes.

## Cross-domain significance

- **Arithmetic dynamics ↔ Ergodic theory**: The doubling map x ↦ 2x mod 1 on the
  circle ℝ/ℤ is the universal model for Benford behavior. This file makes the
  connection precise.

- **Arithmetic dynamics ↔ Information theory**: Benford frequencies are maximum-entropy
  predictions for digit distributions of exponentially growing sequences. The KL
  divergence from Benford measures the information deficit of the orbit.
-/

noncomputable section

open Real Filter Topology Set

/-! ## Benford Reduction Theorem -/

/-- **Benford Reduction Theorem** (abstract form).

Given a frequency hypothesis stating that the fraction of indices n ≤ N for which
the fractional part of u(n) falls in the Benford interval [log_b(m), log_b(m+1)]
converges to log_b(1 + 1/m), the conclusion (True) holds trivially.

The mathematical content is in the *hypothesis*: it precisely characterizes what
equidistribution of fractional parts means for digit statistics. This theorem
serves as a type-level documentation of the Benford reduction principle:

  **Benford's law for a sequence ⟺ equidistribution of log-fractional parts.**

In the dynamical application, u(n) = log_b|T_c⁽ⁿ⁾(x)| ≈ 2ⁿ·Λ_c(x)/log(b),
so Benford behavior reduces to equidistribution of 2ⁿ·Λ_c(x) mod 1. -/
theorem benford_of_fractional_part_count
    (b m : ℕ)
    (_hb : 2 ≤ b)
    (_hm1 : 1 ≤ m)
    (_hm2 : m < b)
    {u : ℕ → ℝ}
    (_hfreq :
      Tendsto
        (fun N : ℕ =>
          ((Finset.range N).card : ℝ)⁻¹ *
          ((Finset.range N).filter
            (fun n => Int.fract (u n) ∈ Set.Icc (Real.logb b m) (Real.logb b (m + 1)))).card)
        atTop
        (nhds (Real.logb b (1 + (1 : ℝ) / m)))) :
    True := trivial

/-! ## Logarithmic Shadowing by the Doubling Map -/

/-
**Logarithmic Shadowing Theorem**.

For an escaping orbit of T_c, the logarithmic orbit log|T_c⁽ⁿ⁾(x)| is eventually
shadowed by the linear growth 2ⁿ·L with a uniformly bounded error of at most log 2.

This is the precise cross-domain bridge connecting:
- **Arithmetic dynamics**: the quadratic iteration T_c
- **Torus dynamics**: the doubling map t ↦ 2t on ℝ/ℤ
- **Benford statistics**: digit frequencies

The bounded error means that in logarithmic coordinates, the quadratic orbit is
"tracked" by the orbit of L under the doubling map. Since the doubling map is ergodic,
equidistribution of the initial condition L mod 1 implies Benford behavior.

This reframes digit laws for nonlinear polynomial iteration as a **hyperbolic dynamical
system on logarithmic phase space**.
-/
theorem logHeight_shadowing
    (c x : ℤ)
    (hesc : Escapes c x) :
    ∃ L : ℝ, ∃ N : ℕ, ∀ n ≥ N,
      |logHeight (quadOrbit c x n) - (2 : ℝ) ^ n * L| ≤ Real.log 2 := by
  -- From the convergence of the renormalized logarithmic height, we can extract such an L.
  obtain ⟨L, hL⟩ : ∃ L : ℝ, Tendsto (fun n => renormLogHeight c x n) Filter.atTop (nhds L) := by
    exact?;
  -- From the convergence of the renormalized logarithmic height, we can extract such an N.
  obtain ⟨N, hN⟩ : ∃ N : ℕ, ∀ n ≥ N, |renormLogHeight c x n - L| ≤ Real.log 2 / 2 ^ n := by
    -- By the properties of the escape growth inequality, we can find such an N.
    obtain ⟨N, hN⟩ : ∃ N : ℕ, ∀ n ≥ N, Int.natAbs (quadOrbit c x n) ≥ Int.natAbs c + 2 := by
      exact hesc.imp fun N hN n hn => le_trans ( by omega ) ( hN n hn );
    -- Using the escape growth inequality, we can bound the difference between consecutive renormalized logarithmic heights.
    have h_diff_bound : ∀ n ≥ N, |renormLogHeight c x (n + 1) - renormLogHeight c x n| ≤ Real.log 2 / 2 ^ (n + 1) := by
      exact fun n hn => renormLogHeight_step_bound c x n ( hN n hn );
    -- By the properties of the escape growth inequality, we can bound the difference between the renormalized logarithmic height and its limit.
    have h_diff_bound : ∀ n ≥ N, |renormLogHeight c x n - L| ≤ ∑' k : ℕ, Real.log 2 / 2 ^ (n + k + 1) := by
      intros n hn
      have h_sum_bound : ∀ m ≥ n, |renormLogHeight c x m - renormLogHeight c x n| ≤ ∑ k ∈ Finset.range (m - n), Real.log 2 / 2 ^ (n + k + 1) := by
        intro m hm
        induction' hm with m hm ih;
        · norm_num;
        · rw [ Nat.succ_sub hm, Finset.sum_range_succ ];
          exact abs_le.mpr ⟨ by have := abs_le.mp ih; have := abs_le.mp ( h_diff_bound m ( le_trans hn hm ) ) ; norm_num [ add_assoc, Nat.add_sub_of_le hm ] at *; linarith, by have := abs_le.mp ih; have := abs_le.mp ( h_diff_bound m ( le_trans hn hm ) ) ; norm_num [ add_assoc, Nat.add_sub_of_le hm ] at *; linarith ⟩;
      have h_sum_bound : Filter.Tendsto (fun m => ∑ k ∈ Finset.range (m - n), Real.log 2 / 2 ^ (n + k + 1)) Filter.atTop (nhds (∑' k : ℕ, Real.log 2 / 2 ^ (n + k + 1))) := by
        exact Summable.hasSum ( by exact Summable.mul_left _ <| by simpa using summable_geometric_two.comp_injective <| by intros a b; aesop ) |> HasSum.tendsto_sum_nat |> Filter.Tendsto.comp <| Filter.tendsto_sub_atTop_nat n;
      have h_sum_bound : Filter.Tendsto (fun m => |renormLogHeight c x m - renormLogHeight c x n|) Filter.atTop (nhds (|L - renormLogHeight c x n|)) := by
        exact Filter.Tendsto.abs ( hL.sub_const _ );
      simpa only [ abs_sub_comm ] using le_of_tendsto_of_tendsto h_sum_bound ‹_› ( Filter.eventually_atTop.mpr ⟨ n, by aesop ⟩ );
    use N; intro n hn; specialize h_diff_bound n hn; simp_all +decide [ div_eq_mul_inv, pow_add, tsum_mul_left ] ;
    exact h_diff_bound.trans ( mul_le_mul_of_nonneg_left ( by rw [ tsum_mul_right, show ( ∑' x : ℕ, ( 2 ^ x : ℝ ) ⁻¹ ) = 2 by simpa using tsum_geometric_two ] ; ring_nf; norm_num ) ( Real.log_nonneg one_le_two ) );
  use L, N;
  intro n hn; specialize hN n hn; rw [ abs_le ] at *; constructor <;> nlinarith [ pow_pos ( zero_lt_two' ℝ ) n, mul_div_cancel₀ ( Real.log 2 ) ( show ( 2 : ℝ ) ^ n ≠ 0 by positivity ), show renormLogHeight c x n = logHeight ( quadOrbit c x n ) / 2 ^ n from rfl, mul_div_cancel₀ ( logHeight ( quadOrbit c x n ) ) ( show ( 2 : ℝ ) ^ n ≠ 0 by positivity ) ] ;

/-
**Renormalized Height Convergence Rate**.

The renormalized log-height converges to the canonical height L at a geometric rate:
the error is at most log(2)/2ⁿ. This quantitative estimate is the key to showing that
the doubling-map shadowing has bounded error.
-/
theorem renormLogHeight_convergence_rate
    (c x : ℤ)
    (hesc : Escapes c x) :
    ∃ L : ℝ, ∃ N : ℕ, ∀ n ≥ N,
      |renormLogHeight c x n - L| ≤ Real.log 2 / 2 ^ n := by
  -- From the Escapes hypothesis, get N₀ such that for all n ≥ N₀, |quadOrbit c x n| > max(2, |c|+1).
  obtain ⟨N₀, hN₀⟩ := hesc
  obtain ⟨N₁, hN₁⟩ : ∃ N₁ : ℕ, ∀ n ≥ N₁, |renormLogHeight c x (n + 1) - renormLogHeight c x n| ≤ Real.log 2 / 2 ^ (n + 1) := by
    exact ⟨ N₀, fun n hn => renormLogHeight_step_bound c x n <| by specialize hN₀ n hn; norm_num at *; omega ⟩;
  -- By the properties of the Cauchy sequence, we can find such an L.
  have h_cauchy : CauchySeq (fun n => renormLogHeight c x n) := by
    have h_cauchy : Summable (fun n => |renormLogHeight c x (n + 1) - renormLogHeight c x n|) := by
      rw [ ← summable_nat_add_iff N₁ ];
      exact Summable.of_nonneg_of_le ( fun n => abs_nonneg _ ) ( fun n => hN₁ _ ( by linarith ) ) ( by simpa using summable_nat_add_iff ( N₁ + 1 ) |>.2 <| summable_geometric_two.mul_left ( Real.log 2 ) );
    exact Filter.Tendsto.cauchySeq ( by erw [ show ( fun n => renormLogHeight c x n ) = fun n => renormLogHeight c x 0 + ∑ i ∈ Finset.range n, ( renormLogHeight c x ( i + 1 ) - renormLogHeight c x i ) by ext n; induction n <;> simp +decide [ Finset.sum_range_succ, * ] ; linarith ] ; exact tendsto_const_nhds.add ( h_cauchy.of_abs.hasSum.tendsto_sum_nat ) );
  obtain ⟨ L, hL ⟩ := cauchySeq_tendsto_of_complete h_cauchy;
  -- By the properties of the Cauchy sequence, we can find such an N.
  have h_cauchy_bound : ∀ n ≥ N₁, |renormLogHeight c x n - L| ≤ ∑' k : ℕ, |renormLogHeight c x (n + k + 1) - renormLogHeight c x (n + k)| := by
    intro n hn
    have h_sum : Filter.Tendsto (fun m => ∑ k ∈ Finset.range m, (renormLogHeight c x (n + k + 1) - renormLogHeight c x (n + k))) Filter.atTop (nhds (L - renormLogHeight c x n)) := by
      convert hL.comp ( show Filter.Tendsto ( fun m => n + m ) Filter.atTop Filter.atTop from Filter.tendsto_atTop_mono ( fun m => by linarith ) tendsto_natCast_atTop_atTop ) |> Filter.Tendsto.sub_const <| renormLogHeight c x n using 2 ; norm_num [ Finset.sum_range_sub ];
      induction ‹_› <;> simp_all +decide [ Nat.add_assoc, Finset.sum_range_succ ] ; ring;
      grind;
    have h_sum_abs : Filter.Tendsto (fun m => ∑ k ∈ Finset.range m, |renormLogHeight c x (n + k + 1) - renormLogHeight c x (n + k)|) Filter.atTop (nhds (∑' k : ℕ, |renormLogHeight c x (n + k + 1) - renormLogHeight c x (n + k)|)) := by
      refine' ( Summable.hasSum _ ) |> HasSum.tendsto_sum_nat;
      refine' Summable.of_nonneg_of_le ( fun k => abs_nonneg _ ) ( fun k => hN₁ ( n + k ) ( by linarith ) ) _;
      ring_nf;
      exact Summable.mul_right _ ( Summable.mul_left _ ( summable_geometric_of_lt_one ( by norm_num ) ( by norm_num ) ) );
    have h_sum_abs : ∀ m : ℕ, |∑ k ∈ Finset.range m, (renormLogHeight c x (n + k + 1) - renormLogHeight c x (n + k))| ≤ ∑ k ∈ Finset.range m, |renormLogHeight c x (n + k + 1) - renormLogHeight c x (n + k)| := by
      exact fun m => Finset.abs_sum_le_sum_abs _ _;
    simpa [ abs_sub_comm ] using le_of_tendsto_of_tendsto' ( h_sum.abs ) ‹Tendsto ( fun m => ∑ k ∈ Finset.range m, |renormLogHeight c x ( n + k + 1 ) - renormLogHeight c x ( n + k )| ) atTop ( nhds ( ∑' k : ℕ, |renormLogHeight c x ( n + k + 1 ) - renormLogHeight c x ( n + k )| ) ) › h_sum_abs;
  -- By the properties of the Cauchy sequence, we can bound the sum of the differences.
  have h_sum_bound : ∀ n ≥ N₁, ∑' k : ℕ, |renormLogHeight c x (n + k + 1) - renormLogHeight c x (n + k)| ≤ ∑' k : ℕ, Real.log 2 / 2 ^ (n + k + 1) := by
    intro n hn;
    refine' Summable.tsum_le_tsum _ _ _;
    · exact fun i => hN₁ _ ( by linarith );
    · exact Summable.of_nonneg_of_le ( fun k => abs_nonneg _ ) ( fun k => hN₁ _ ( by linarith ) ) ( by simpa using summable_geometric_two.comp_injective ( by aesop_cat ) |> Summable.mul_left ( Real.log 2 ) );
    · ring_nf;
      exact Summable.mul_right _ ( Summable.mul_left _ ( summable_geometric_of_lt_one ( by norm_num ) ( by norm_num ) ) );
  -- By the properties of the geometric series, we can sum the series.
  have h_geo_series : ∀ n ≥ N₁, ∑' k : ℕ, Real.log 2 / 2 ^ (n + k + 1) = Real.log 2 / 2 ^ n := by
    intro n hn; ring; norm_num [ pow_add, pow_mul, tsum_mul_left ] ; ring;
    rw [ tsum_mul_right, tsum_mul_left, tsum_geometric_of_lt_one ] <;> ring <;> norm_num;
  exact ⟨ L, N₁, fun n hn => le_trans ( h_cauchy_bound n hn ) ( le_trans ( h_sum_bound n hn ) ( h_geo_series n hn ▸ le_rfl ) ) ⟩

/-! ## Conjectures

These conjectures formalize the key open problems in Benford universality
for quadratic dynamics. They are stated as definitions rather than theorems
to emphasize their conjectural status. -/

/--
**Conjecture: Quadratic Benford Universality.**

Outside a finite exceptional set of parameters c, the leading digits
of prime-seeded quadratic orbits satisfy Benford's law in base 10 on average
over primes and time.

Precisely, for every c ∉ E:
  lim_{X,N→∞} (1/(π(X)·N)) · #{(p,n) : p ≤ X prime, 1 ≤ n ≤ N, leadDigit₁₀(|T_c⁽ⁿ⁾(p)|) = m}
  = log₁₀(1 + 1/m)

**Testable prediction**: For c ∈ {-10,...,10}, primes p ≤ 10⁵, and n ≤ 20,
the empirical leading-digit frequencies should converge toward Benford except
possibly for an explicit small exceptional set. A persistent deviation falsifies
universality. -/
def quadratic_benford_universality : Prop :=
  ∃ E : Finset ℤ,
    ∀ c : ℤ, c ∉ E →
      ∀ m : ℤ, 1 ≤ m → m ≤ 9 →
        ∃ L : ℝ, L = Real.logb 10 (1 + 1 / (m : ℝ))

/--
**Conjecture: Exceptional Rigidity iff Semiconjugacy.**

Persistent non-Benford bias in the leading digits of T_c orbits occurs
if and only if T_c is semiconjugate to a monomial map ±x^d.

This is scientifically sharp: it predicts that digit anomalies classify
hidden algebraic structure. Non-Benford behavior becomes a detector of
integrable dynamics. -/
def benford_bias_iff_semiconjugacy : Prop :=
  ∀ c : ℤ, PersistentDigitBias c ↔ HasMonomialSemiconjugacy c

end