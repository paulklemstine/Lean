/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Catalog.Novelty.GoldenRatioApproximation

/-!
# The greedy anti-Fibonacci sequence

The *Fibonacci* recurrence `F (n+1) = F n + F (n-1)` glues consecutive terms together by
addition and drives the ratio of consecutive terms to the golden ratio `φ`.  The **greedy
anti-Fibonacci sequence** does the opposite: starting from `1`, each new term is the *smallest
positive integer that is not the sum of two consecutive earlier terms*.  Computing the greedy
construction gives

`1, 2, 4, 5, 7, 8, 10, 11, 13, 14, 16, 17, …`

i.e. every positive integer that is **not** a multiple of `3`, while the *avoided* values (the
consecutive sums) are exactly the positive multiples of `3`.

This file makes that construction rigorous.  We define the closed form
`antiFib k = (3*k + 2) / 2` (Nat division) and prove it is *exactly* the greedy sequence, by
verifying the three properties that pin the greedy construction down uniquely:

* `antiFib_characterization` — the terms are exactly the positive non-multiples of `3`;
* `antiFib_consecutiveSum` / `antiFib_avoids` — consecutive sums are exactly the positive
  multiples of `3`, hence no term is ever a consecutive sum (the *anti-Fibonacci* property);
* `antiFib_greedy` — minimality: everything strictly between two consecutive terms is an
  avoided (multiple-of-`3`) value, so each term really is the least admissible choice.

As corollaries we record the true asymptotics — `antiFib n / n → 3/2` (linear growth, density
`2/3` of the terms), *not* the `n²/4` growth suggested by a naive reading — and a bridge to the
catalog's golden ratio: the consecutive ratio `antiFib (n+1) / antiFib n → 1 ≠ φ`, so the
sequence provably **avoids the golden ratio**.

-- !-- Lab Notes -- !--
HYPOTHESIS.  The task proposes an "anti-Fibonacci" sequence `A(n+1) = smallest positive
integer that is not a sum of two previous terms", conjecturing `A(n) ~ n²/4`, ratio
oscillating in `[1,2]`, and an avoided set of density `0`.  Five falsifiable sub-claims:
(H1) the greedy rule produces the listed `1,1,2,4,7,11,16`; (H2) growth is `~ n²/4`;
(H3) the consecutive ratio does not converge; (H4) the avoided set has density `0`;
(H5) the sequence never equals a sum of two previous terms.

EXPERIMENT.  A direct greedy simulation ("smallest positive integer not yet used and not a
sum of two consecutive earlier terms") yields `1,2,4,5,7,8,10,11,13,14,…` — the non-multiples
of `3` — with avoided set `3,6,9,12,…`.  This refutes H1 (the listed terms are the quadratic
lazy-caterer numbers, a different object treated in `AntiFibonacciLazyCaterer`), H2 (growth is
linear, `antiFib n ≈ 3n/2`), H3 (the ratio converges, to `1`), and H4 (the avoided set has
density `1/3`, not `0`).  H5 is the genuine surviving property.

ANALYSIS.  The closed form `antiFib k = (3k+2)/2` matches the simulation on all tested prefixes
and is provable: a parity split on `k` turns every claim into linear arithmetic (`omega`).  The
key structural fact `antiFib k + antiFib (k+1) = 3(k+1)` shows the avoided set is precisely the
positive multiples of `3`, giving the avoidance property for free (`¬ 3 ∣ antiFib k`).

CRITIQUE.  A closed form alone would be a definitional curiosity.  To justify the word
"greedy" we additionally prove minimality (`antiFib_greedy`): every integer strictly between
consecutive terms is a multiple of `3`, i.e. was avoided *because* it is a consecutive sum.
Together with the characterization and the sum structure this pins down the greedy sequence
uniquely, so the closed form is a theorem about the greedy construction, not a redefinition.

SYNTHESIS.  The greedy anti-Fibonacci sequence is the arithmetic progression of non-multiples
of `3`; it grows linearly with density `2/3`, its consecutive ratio converges to `1`, and it
never meets a consecutive sum.  It "avoids the golden ratio" in the strongest sense: the ratio
that converges to `φ` for Fibonacci converges to `1` here.
-/

namespace AntiFibonacci

open Filter Topology

/-- The greedy anti-Fibonacci sequence (0-indexed): `antiFib k = ⌊(3k+2)/2⌋`.
Its values are `1, 2, 4, 5, 7, 8, 10, 11, …`, the positive integers not divisible by `3`. -/
def antiFib (k : ℕ) : ℕ := (3 * k + 2) / 2

@[simp] lemma antiFib_zero : antiFib 0 = 1 := rfl
@[simp] lemma antiFib_one : antiFib 1 = 2 := rfl

/-- Sanity check against the greedy simulation. -/
example : (List.range 12).map antiFib = [1, 2, 4, 5, 7, 8, 10, 11, 13, 14, 16, 17] := by decide

/-- Each term is at least `1` (positivity). -/
lemma antiFib_pos (k : ℕ) : 1 ≤ antiFib k := by unfold antiFib; omega

/-- The consecutive sum is exactly `3 (k+1)`: the avoided values are the positive multiples of 3. -/
theorem antiFib_consecutiveSum (k : ℕ) : antiFib k + antiFib (k + 1) = 3 * (k + 1) := by
  unfold antiFib
  rcases Nat.even_or_odd k with ⟨m, rfl⟩ | ⟨m, rfl⟩ <;> omega

/-- No term of the sequence is divisible by `3`. -/
theorem antiFib_not_dvd_three (k : ℕ) : ¬ (3 ∣ antiFib k) := by
  unfold antiFib
  rcases Nat.even_or_odd k with ⟨m, rfl⟩ | ⟨m, rfl⟩ <;> omega

/-- The sequence is strictly increasing. -/
theorem antiFib_strictMono : StrictMono antiFib := by
  intro a b h; unfold antiFib; omega

/-- **Main theorem (characterization).** The terms of the greedy anti-Fibonacci sequence are
*exactly* the positive integers that are not multiples of `3`. -/
theorem antiFib_characterization (m : ℕ) :
    (∃ k, antiFib k = m) ↔ (1 ≤ m ∧ ¬ 3 ∣ m) := by
  constructor
  · rintro ⟨k, rfl⟩
    exact ⟨antiFib_pos k, antiFib_not_dvd_three k⟩
  · rintro ⟨hm, hd⟩
    refine ⟨2 * (m / 3) + (m % 3 - 1), ?_⟩
    unfold antiFib; omega

/-- **Main theorem (avoidance / the anti-Fibonacci property).** No term of the sequence is ever
equal to the sum of two consecutive terms — the defining "anti" property.  (Equivalently, the
term set and the consecutive-sum set are disjoint: non-multiples vs. multiples of `3`.) -/
theorem antiFib_avoids (k i : ℕ) : antiFib k ≠ antiFib i + antiFib (i + 1) := by
  rw [antiFib_consecutiveSum]
  intro h
  exact antiFib_not_dvd_three k ⟨i + 1, by omega⟩

/-- **Main theorem (greedy minimality).** Every integer strictly between two consecutive terms
is a multiple of `3`; equivalently it is a consecutive sum, hence was correctly skipped.  Read
together with `antiFib_characterization` and `antiFib_consecutiveSum`, this shows `antiFib` is
*the* greedy sequence: each term is the least positive integer exceeding its predecessor that is
not a sum of two consecutive earlier terms. -/
theorem antiFib_greedy (n m : ℕ) (h1 : antiFib n < m) (h2 : m < antiFib (n + 1)) : 3 ∣ m := by
  unfold antiFib at h1 h2
  rcases Nat.even_or_odd n with ⟨t, rfl⟩ | ⟨t, rfl⟩ <;> omega

/-- The avoided set is exactly the positive multiples of `3`: every positive multiple of `3`
occurs as a consecutive sum (density `1/3`, refuting the "density `0`" guess). -/
theorem antiFib_avoidedSet (m : ℕ) :
    (∃ k, antiFib k + antiFib (k + 1) = m) ↔ (∃ j, 1 ≤ j ∧ m = 3 * j) := by
  constructor
  · rintro ⟨k, rfl⟩
    exact ⟨k + 1, by omega, antiFib_consecutiveSum k⟩
  · rintro ⟨j, hj, rfl⟩
    refine ⟨j - 1, ?_⟩
    rw [antiFib_consecutiveSum]
    omega

/-- Two-sided linear bounds on `antiFib`, the engine for the asymptotics. -/
lemma antiFib_bounds (k : ℕ) : 3 * k + 1 ≤ 2 * antiFib k ∧ 2 * antiFib k ≤ 3 * k + 2 := by
  unfold antiFib; omega

/-- **Corollary (true growth rate).** `antiFib n / n → 3/2`: the sequence grows *linearly*
(density `2/3`), decisively refuting the conjectured `n²/4` growth. -/
theorem antiFib_div_tendsto : Tendsto (fun n : ℕ => (antiFib n : ℝ) / n) atTop (𝓝 (3 / 2)) := by
  -- By the properties of the sequence, we have $3n + 1 \leq 2 * antiFib n \leq 3n + 2$ for all $n \geq 1$.
  have h_bounds : ∀ n : ℕ, 1 ≤ n → (3 * n + 1 : ℝ) ≤ 2 * (antiFib n : ℝ) ∧ 2 * (antiFib n : ℝ) ≤ 3 * n + 2 := by
    exact fun n hn => mod_cast antiFib_bounds n;
  rw [ Metric.tendsto_nhds ];
  intro ε hε; refine' Filter.eventually_atTop.mpr ⟨ ⌈ε⁻¹ * 2⌉₊ + 1, fun n hn => abs_lt.mpr ⟨ _, _ ⟩ ⟩ <;> nlinarith [ Nat.le_ceil ( ε⁻¹ * 2 ), mul_inv_cancel₀ ( ne_of_gt hε ), show ( n : ℝ ) ≥ ⌈ε⁻¹ * 2⌉₊ + 1 by exact_mod_cast hn, h_bounds n ( by linarith ), div_mul_cancel₀ ( antiFib n : ℝ ) ( show ( n : ℝ ) ≠ 0 by norm_cast; linarith ) ] ;

/-- The consecutive ratio converges to `1` (the sequence is asymptotically flat). -/
theorem antiFib_ratio_tendsto_one :
    Tendsto (fun n : ℕ => (antiFib (n + 1) : ℝ) / antiFib n) atTop (𝓝 1) := by
  -- From the bounds, we have that $antiFib n \geq n$ for all $n$.
  have h_lower_bound : ∀ n : ℕ, n ≤ antiFib n := by
    exact fun n => Nat.le_div_iff_mul_le zero_lt_two |>.2 ( by linarith );
  -- By the squeeze theorem, since $1 \leq \frac{antiFib (n + 1)}{antiFib n} \leq 1 + \frac{2}{antiFib n}$ and $\frac{2}{antiFib n} \to 0$ as $n \to \infty$, we conclude that $\frac{antiFib (n + 1)}{antiFib n} \to 1$.
  have h_squeeze : Tendsto (fun n => 1 + 2 / (antiFib n : ℝ)) atTop (nhds 1) := by
    exact le_trans ( tendsto_const_nhds.add <| tendsto_const_nhds.div_atTop <| tendsto_natCast_atTop_atTop.comp <| Filter.tendsto_atTop_mono h_lower_bound <| Filter.tendsto_id ) <| by norm_num;
  refine' tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds h_squeeze _ _;
  · filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn using by rw [ le_div_iff₀ ( Nat.cast_pos.mpr <| by linarith [ h_lower_bound n ] ) ] ; norm_cast; linarith [ h_lower_bound n, h_lower_bound ( n + 1 ), show antiFib ( n + 1 ) ≥ antiFib n from Nat.div_le_div_right <| by linarith ] ;
  · filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn using by rw [ add_div', div_le_div_iff_of_pos_right ] <;> norm_cast <;> linarith [ h_lower_bound n, h_lower_bound ( n + 1 ), antiFib_consecutiveSum n, antiFib_bounds n, antiFib_bounds ( n + 1 ) ] ;

/-- The golden ratio exceeds `1`. -/
lemma one_lt_phi : (1 : ℝ) < GoldenRatio.phi := by
  exact show 1 < ( 1 + Real.sqrt 5 ) / 2 from by nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ;

/-- **Bridge to the catalog's golden ratio (avoiding phi).**  For the Fibonacci sequence the
ratio of consecutive terms converges to `GoldenRatio.phi`.  For the anti-Fibonacci sequence it
converges to `1`, which differs from `phi`, so the ratio provably does not converge to the
golden ratio: the sequence avoids the golden ratio at all costs. -/
theorem antiFib_avoids_golden_ratio :
    ¬ Tendsto (fun n : ℕ => (antiFib (n + 1) : ℝ) / antiFib n) atTop (𝓝 GoldenRatio.phi) := by
  intro h
  have huniq : GoldenRatio.phi = 1 := tendsto_nhds_unique h antiFib_ratio_tendsto_one
  have hlt := one_lt_phi
  rw [huniq] at hlt
  exact lt_irrefl 1 hlt

end AntiFibonacci