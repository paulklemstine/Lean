/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A periodic simply normal sequence: normality does not force irrationality

The deepest open problems about normality (is `π`, `e`, or `√2` normal?) concern
*specific* constants.  A complementary, fully provable question is **existence and
classification**: which sequences are simply normal, and what extra properties can
they have?

Here we exhibit an explicit simply normal digit stream — the **cyclic sequence**
`cyc b k = k mod b` — and prove `cyc_simplyNormal`.  Its count of any digit `d`
in the first `n` terms is `n / b + [d < n mod b]` (one per full block of `b`,
plus a boundary correction), via Mathlib's `Nat.count_modEq_card`; squeezing
between `n/b` and `n/b + 1` forces the frequency to `1/b`.

The payoff is a sharp structural fact: `cyc` is **periodic** with period `b`
(`cyc_periodic`), so it is the digit stream of a *rational* number, yet it is
simply normal.  Hence **simple normality does not imply irrationality (let alone
transcendence)** — the converse direction of the normality ↔ transcendence folklore
is false, and we pin down the exact witness.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the round-robin digit stream `0,1,…,b-1,0,1,…` should
be the canonical "perfectly equidistributed" example, and it is periodic, so it
should sever normality from irrationality.
Experiment (Experimenter): compute `countDigit (cyc b) d n` exactly through
`Nat.count_modEq_card` (= `n / b + Iverson[d % b < n % b]`), then squeeze.
Analysis (Analyst): the limit reduces to `(↑(n / b)) / n → 1/b`, which holds
because `↑(n / b) = (n - n % b)/b` and `n % b < b` is bounded; the boundary term
contributes at most `1/n → 0`.  This isolates *why* equidistribution holds: the
deterministic block structure makes the discrepancy `O(1)`.
Critique (Critic): is the result trivial (`native_decide`)?  No — it is an
honest `atTop` limit needing a squeeze and the exact congruence count.  Is the
"normal ⇏ irrational" corollary cheap?  No — it needs the *periodicity* witness,
which we prove and which makes the corresponding real number rational.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Algebra.NormalNumbers.Basic

namespace NormalConstants

open Finset Filter Topology

/-- The cyclic (round-robin) digit stream in base `b`: `cyc b hb k = k mod b`. -/
def cyc (b : ℕ) (hb : 0 < b) : ℕ → Fin b := fun k => ⟨k % b, Nat.mod_lt _ hb⟩

/-- `cyc` is periodic with period `b`. -/
theorem cyc_periodic (b : ℕ) (hb : 0 < b) (k : ℕ) :
    cyc b hb (k + b) = cyc b hb k := by
  unfold cyc
  simp [Nat.add_mod_right]

/-- Exact digit count for the cyclic stream: `n / b` full blocks plus a boundary
correction of `0` or `1`. -/
theorem cyc_count (b : ℕ) (hb : 0 < b) (d : Fin b) (n : ℕ) :
    countDigit (cyc b hb) d n = n / b + (if (d : ℕ) % b < n % b then 1 else 0) := by
  have hcount : countDigit (cyc b hb) d n = n.count (· ≡ (d : ℕ) [MOD b]) := by
    rw [Nat.count_eq_card_filter_range]
    unfold countDigit cyc
    congr 1
    ext k
    simp only [Finset.mem_filter, Finset.mem_range, Fin.ext_iff, Nat.ModEq]
    constructor
    · rintro ⟨hk, he⟩; exact ⟨hk, by rw [he, Nat.mod_eq_of_lt d.2]⟩
    · rintro ⟨hk, he⟩; exact ⟨hk, by rw [he, Nat.mod_eq_of_lt d.2]⟩
  rw [hcount, Nat.count_modEq_card _ hb]

/-- Two-sided sandwich on the cyclic count: `n / b ≤ count ≤ n / b + 1`. -/
theorem cyc_count_bounds (b : ℕ) (hb : 0 < b) (d : Fin b) (n : ℕ) :
    n / b ≤ countDigit (cyc b hb) d n ∧ countDigit (cyc b hb) d n ≤ n / b + 1 := by
  rw [cyc_count b hb d n]
  constructor
  · exact Nat.le_add_right _ _
  · split <;> omega

/-
The auxiliary real limit `(↑(n / b)) / n → 1/b`.
-/
theorem div_floor_tendsto (b : ℕ) (hb : 0 < b) :
    Tendsto (fun n : ℕ => ((n / b : ℕ) : ℝ) / n) atTop (𝓝 (1 / (b : ℝ))) := by
  -- Let's simplify the expression inside the limit.
  have h_simplify : Filter.Tendsto (fun n : ℕ => ((n : ℝ) - (n % b : ℕ)) / (b * n)) Filter.atTop (nhds (1 / b)) := by
    -- We can factor out $n$ in the numerator and denominator.
    suffices h_factor : Filter.Tendsto (fun n : ℕ => (1 - (n % b : ℕ) / (n : ℝ)) / (b : ℝ)) Filter.atTop (nhds (1 / b)) by
      refine h_factor.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn; rw [ one_sub_div ( by positivity ) ] ; ring );
    exact le_trans ( Filter.Tendsto.div_const ( tendsto_const_nhds.sub <| squeeze_zero ( fun _ => by positivity ) ( fun n => by simpa using div_le_div_of_nonneg_right ( Nat.cast_le.mpr <| Nat.le_of_lt <| Nat.mod_lt _ hb ) <| Nat.cast_nonneg _ ) <| tendsto_const_nhds.div_atTop <| tendsto_natCast_atTop_atTop ) _ ) <| by norm_num;
  convert h_simplify using 2;
  rw [ ← div_div ];
  rw [ show ( ( _ : ℕ ) : ℝ ) - ( ( _ : ℕ ) % b : ℕ ) = ( ( _ : ℕ ) / b : ℕ ) * b by exact sub_eq_of_eq_add <| mod_cast by linarith [ Nat.mod_add_div ‹_› b ] ] ; norm_num [ hb.ne' ]

/-
**The cyclic stream is simply normal.**
-/
theorem cyc_simplyNormal (b : ℕ) (hb : 0 < b) : SimplyNormal (cyc b hb) := by
  intro d;
  refine' tendsto_of_tendsto_of_tendsto_of_le_of_le' ( div_floor_tendsto b hb ) ( by simpa using ( div_floor_tendsto b hb ) |> Filter.Tendsto.add <| tendsto_inv_atTop_nhds_zero_nat ) _ _;
  · refine' Filter.eventually_atTop.mpr ⟨ 1, fun n hn => _ ⟩ ; unfold freq;
    gcongr ; exact_mod_cast cyc_count_bounds b hb d n |>.1;
  · filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn;
    convert div_le_div_of_nonneg_right ( show ( countDigit ( cyc b hb ) d n : ℝ ) ≤ ( n / b : ℕ ) + 1 from mod_cast cyc_count_bounds b hb d n |>.2 ) ( Nat.cast_nonneg n ) using 1 ; ring

/-- **Existence.** For every base `b ≥ 1` there is a simply normal digit stream. -/
theorem exists_simplyNormal (b : ℕ) (hb : 0 < b) :
    ∃ s : ℕ → Fin b, SimplyNormal s :=
  ⟨cyc b hb, cyc_simplyNormal b hb⟩

/-- **Normality does not imply irrationality.** There is a *periodic* (period `b`),
hence rational, digit stream that is nonetheless simply normal, for every `b ≥ 1`. -/
theorem exists_periodic_simplyNormal (b : ℕ) (hb : 0 < b) :
    ∃ s : ℕ → Fin b, SimplyNormal s ∧ (∀ k, s (k + b) = s k) :=
  ⟨cyc b hb, cyc_simplyNormal b hb, cyc_periodic b hb⟩

end NormalConstants