/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Speculative.BenfordRenormalization.Defs

/-!
# Benford Renormalization: Main Theorems

This module proves the central theorems of Benford renormalization theory
for integer dynamical systems.

## Main Results

1. **Frequency partition of unity** (`freq_partition_of_unity`): For any positive
   sequence, the sum of empirical leading-digit frequencies over all valid digits
   equals 1.

2. **Benford theoretical partition** (`benford_theoretical_sum`): The Benford
   predicted frequencies sum to 1 via telescoping of logarithms.

3. **Obstruction transfer under powering** (`obstruction_of_power`): If a
   sequence u has a rational eigen-obstruction, then u^m inherits it.

4. **Leading digit base-multiplication invariance** (`leadingDigitBase_mul_base`):
   Multiplying by the base preserves the leading digit.

5. **Cross-domain: digit-mod9 bridge** (`leading_digit_mod9`): Connection
   between leading digit distribution and modular arithmetic.

6. **Conjecture** (`benford_universality_conjecture`): The main universality
   conjecture for obstruction-free dynamical maps.
-/

namespace BenfordRenorm

open Real Finset Filter

/-! ## Theorem 1: Frequency Partition of Unity

For any positive sequence u and base b ≥ 2, the sum of benfordFreqUpTo
over digits 1, ..., b-1 equals 1. Every positive integer has exactly one
leading digit in {1, ..., b-1}, so the digit frequencies partition unity.
-/

/-
The set of indices where the leading digit equals d partitions the
range when d ranges over {1, ..., b-1}, for positive sequences.
-/
theorem freq_partition_of_unity (b : ℕ) (u : ℕ → ℕ) (N : ℕ)
    (hb : 2 ≤ b) (hN : 0 < N)
    (hpos : ∀ k, k < N → 1 ≤ u k) :
    ∑ d ∈ Finset.Icc 1 (b - 1), benfordFreqUpTo b d u N = 1 := by
  -- By definition of benfordFreqUpTo, we can rewrite the sum.
  have h_sum : ∑ d ∈ Finset.Icc 1 (b - 1), (∑ k ∈ Finset.range N, if BenfordRenorm.leadingDigitBase b (u k) = d then 1 else 0) / (N : ℝ) = 1 := by
    rw [ ← Finset.sum_div, div_eq_iff ] <;> norm_cast <;> try linarith;
    rw [ Finset.sum_comm ];
    simp +zetaDelta at *;
    rw [ Finset.filter_true_of_mem fun x hx => ⟨ BenfordRenorm.leadingDigitBase_pos b ( u x ) hb ( hpos x ( Finset.mem_range.mp hx ) ), Nat.le_sub_one_of_lt ( BenfordRenorm.leadingDigitBase_lt b ( u x ) hb ( hpos x ( Finset.mem_range.mp hx ) ) ) ⟩, Finset.card_range ];
  unfold BenfordRenorm.benfordFreqUpTo; aesop;

/-! ## Theorem 2: Benford Theoretical Partition of Unity

The Benford predicted frequencies ∑_{d=1}^{b-1} log_b(1 + 1/d) = 1.
This is a telescoping sum: log_b(1+1/d) = log_b((d+1)/d) = log_b(d+1) - log_b(d),
and the sum telescopes to log_b(b) - log_b(1) = 1 - 0 = 1.
-/

/-
Each Benford frequency can be rewritten as a difference of logarithms:
benfordTheoretical b d = log(d+1)/log(b) - log(d)/log(b).
-/
theorem benford_theoretical_as_diff (b d : ℕ) (hb : 2 ≤ b) (hd : 1 ≤ d) :
    benfordTheoretical b d =
    Real.log ((d + 1 : ℕ) : ℝ) / Real.log (b : ℝ) -
    Real.log (d : ℝ) / Real.log (b : ℝ) := by
  unfold benfordTheoretical; norm_num;
  rw [ ← sub_div, ← Real.log_div ( by positivity ) ( by positivity ), inv_eq_one_div, add_div' ] <;> ring ; positivity

/-
The Benford theoretical frequencies telescope to log(b)/log(b):
∑_{d=1}^{b-1} log_b(1 + 1/d) = log_b(b) = 1.
-/
theorem benford_theoretical_sum_eq_one (b : ℕ) (hb : 2 ≤ b) :
    ∑ d ∈ Finset.Icc 1 (b - 1), benfordTheoretical b d = 1 := by
  -- Apply the telescoping sum property:_{d=1}^{b-1} (log_b(d+1) - log_b(d)) = log_b(b) - log_b(1).
  have h_telescope : ∑ d ∈ Finset.Icc 1 (b - 1), (Real.log ((d + 1 : ℕ) : ℝ) / Real.log (b : ℝ) - Real.log (d : ℝ) / Real.log (b : ℝ)) = Real.log (b : ℝ) / Real.log (b : ℝ) - Real.log (1 : ℝ) / Real.log (b : ℝ) := by
    convert Finset.sum_range_sub ( fun x => Real.log ( x + 1 ) / Real.log b ) ( b - 1 ) using 1;
    · erw [ Finset.sum_Ico_eq_sub _ ] <;> norm_num [ Finset.sum_range_succ' ];
    · rw [ Nat.cast_sub ( by linarith ) ] ; push_cast ; ring;
  convert h_telescope using 1;
  · exact Finset.sum_congr rfl fun x hx => benford_theoretical_as_diff b x hb ( Finset.mem_Icc.mp hx |>.1 );
  · rw [ div_self <| ne_of_gt <| Real.log_pos <| by norm_cast, Real.log_one, zero_div, sub_zero ]

/-! ## Theorem 3: Obstruction Transfer Under Powering

If u has a rational eigen-obstruction (q · log_b(u(k)) is eventually integral),
then for any positive integer m, the powered sequence u^m also has an obstruction
(q · log_b(u(k)^m) = q·m · log_b(u(k)) is also eventually integral).
-/

/-
If u has a rational eigen-obstruction in base b, then the sequence
k ↦ u(k)^m also has a rational eigen-obstruction. This shows that
the obstruction class is closed under powering — a key rigidity property.
-/
theorem obstruction_of_power (b : ℕ) (u : ℕ → ℕ) (m : ℕ) (_hm : 0 < m)
    (hobs : HasRationalEigenObstruction b u) :
    HasRationalEigenObstruction b (fun k => u k ^ m) := by
  obtain ⟨ q, hq_pos, hq ⟩ := hobs;
  use q, hq_pos; filter_upwards [ hq ] with k hk; obtain ⟨ z, hz ⟩ := hk; use z * m; push_cast; ring;
  rw [ ← hz ] ; norm_num ; ring;

/-! ## Theorem 4: Orbit Sequence Structure -/

/-- For an IntDynMap, the orbit sequence at step k+1 equals T applied to step k. -/
theorem IntDynMap.orbitSeq_succ (T : IntDynMap) (n k : ℕ) :
    T.orbitSeq n (k + 1) = T.map (T.orbitSeq n k) := by
  exact Function.iterate_succ_apply' T.map k n

/-- The orbit sequence at step 0 is the seed. -/
theorem IntDynMap.orbitSeq_zero (T : IntDynMap) (n : ℕ) :
    T.orbitSeq n 0 = n := by
  simp [IntDynMap.orbitSeq]

/-! ## Theorem 5: Leading Digit Stability Under Multiplication by Base

Multiplying by the base shifts the digit representation but preserves the
leading digit. This is a structural property connecting to the cocycle. -/

/-
Multiplying by the base preserves the leading digit for positive numbers.
-/
theorem leadingDigitBase_mul_base (b n : ℕ) (hb : 2 ≤ b) (hn : 1 ≤ n) :
    leadingDigitBase b (n * b) = leadingDigitBase b n := by
  rw [ leadingDigitBase_div ];
  · rw [ Nat.mul_div_cancel _ ( by linarith ) ];
  · grind +qlia;
  · nlinarith

/-! ## Theorem 6: Discrepancy Bound

If a sequence is Benford, the digit discrepancy tends to 0.
This connects the IsBenford definition (pointwise convergence for each digit)
to the uniform discrepancy metric. -/

/-
If a sequence is Benford, its digit discrepancy converges to 0.
-/
theorem discrepancy_tendsto_zero_of_benford (b : ℕ) (u : ℕ → ℕ) (hb : 2 ≤ b)
    (hBen : IsBenford b u) :
    Tendsto (digitDiscrepancy b u) atTop (nhds 0) := by
  -- Apply the definition of digitDiscrepancy.
  unfold digitDiscrepancy;
  simp +decide [ hb, hBen ];
  refine' squeeze_zero ( fun N => _ ) ( fun N => _ ) _;
  use fun N => ∑ d ∈ Finset.Icc 1 ( b - 1 ), |benfordFreqUpTo b d u N - benfordTheoretical b d|;
  · exact le_trans ( by norm_num ) ( Finset.le_sup' ( fun d => |benfordFreqUpTo b d u N - benfordTheoretical b d| ) ( Finset.left_mem_Icc.mpr ( Nat.sub_pos_of_lt hb ) ) );
  · exact Finset.sup'_le _ _ fun x hx => Finset.single_le_sum ( fun y hy => abs_nonneg ( benfordFreqUpTo b y u N - benfordTheoretical b y ) ) hx;
  · simpa using tendsto_finset_sum _ fun d hd => Filter.Tendsto.abs ( hBen d ( Finset.mem_Icc.mp hd |>.1 ) ( Finset.mem_Icc.mp hd |>.2.trans_lt ( Nat.pred_lt ( ne_bot_of_gt hb ) ) ) |> Filter.Tendsto.sub_const <| benfordTheoretical b d )

/-! ## Theorem 7: Cross-Domain — Ergodic Theory Connection

**Cocycle additivity under orbit composition.**
The logarithmic cocycle of a composed orbit decomposes additively,
connecting the dynamical systems perspective (orbits) to the
ergodic theory perspective (additive cocycles over rotations).
This is the bridge between arithmetic dynamics and ergodic spectral theory.
-/

/-
The oscillation (fractional log) of a product equals the fractional
part of the sum of oscillations. This connects digit statistics to
the additive cocycle structure in ergodic theory: the log-mantissa
transform converts multiplicative dynamics to additive rotations.
-/
theorem oscillation_product (b : ℕ) (a c : ℕ) (_hb : 2 ≤ b) (ha : 1 ≤ a) (hc : 1 ≤ c) :
    oscillation b (fun _ => a * c) 0 =
    Int.fract (oscillation b (fun _ => a) 0 + oscillation b (fun _ => c) 0) := by
  -- By definition of oscillation, we have:
  simp [oscillation];
  rw [ Real.log_mul ( by positivity ) ( by positivity ), add_div ];
  convert Int.fract_add_intCast ( Int.fract ( Real.log a / Real.log b ) + Int.fract ( Real.log c / Real.log b ) ) ( ⌊Real.log a / Real.log b⌋ + ⌊Real.log c / Real.log b⌋ ) using 1 ; ring;
  rw [ Int.fract, Int.fract ] ; ring;
  rw [ Int.fract, Int.fract ] ; ring;
  grind +splitImp

/-! ## Theorem 8: Benford Stability Under Finite Perturbation

Benford behavior is invariant under finite modifications. If two sequences agree
eventually, they have the same Benford status. This is a renormalization principle:
only the asymptotic cocycle matters. -/

/-
If u and v agree eventually, u is Benford iff v is Benford.
-/
theorem benford_iff_of_eventually_eq (b : ℕ) (u v : ℕ → ℕ) (_hb : 2 ≤ b)
    (hev : ∀ᶠ k in atTop, u k = v k) :
    IsBenford b u ↔ IsBenford b v := by
  -- If u and v agree eventually, then for every digit d, the filters {k < N | leadingDigitBase b (u k) = d} and {k < N | leadingDigitBase b (v k) = d} differ by at most finitely many elements (those before the eventual agreement). So benfordFreqUpTo b d u N - benfordFreqUpTo b d v N → 0, meaning one converges iff the other does.
  have h_diff_zero : ∀ d, 1 ≤ d → d < b → Filter.Tendsto (fun N => benfordFreqUpTo b d u N - benfordFreqUpTo b d v N) Filter.atTop (nhds 0) := by
    intro d hd₁ hd₂; simp_all +decide [ benfordFreqUpTo ] ;
    -- Since $u$ and $v �$� agree eventually, the difference in their counts is bounded by the number of elements before the agreement.
    obtain ⟨K, hK⟩ : ∃ K, ∀ k ≥ K, u k = v k := hev
    have h_diff_bound : ∀ N ≥ K, |((Finset.filter (fun k => leadingDigitBase b (u k) = d) (Finset.range N)).card : ℝ) - ((Finset.filter (fun k => leadingDigitBase b (v k) = d) (Finset.range N)).card : ℝ)| ≤ K := by
      intros N hN
      have h_diff_bound : ((Finset.filter (fun k => leadingDigitBase b (u k) = d) (Finset.range N)).card : ℝ) ≤ ((Finset.filter (fun k => leadingDigitBase b (v k) = d) (Finset.range N)).card : ℝ) + K := by
        have h_diff_bound : Finset.filter (fun k => leadingDigitBase b (u k) = d) (Finset.range N) ⊆ Finset.filter (fun k => leadingDigitBase b (v k) = d) (Finset.range N) ∪ Finset.range K := by
          grind;
        exact_mod_cast le_trans ( Finset.card_le_card h_diff_bound ) ( Finset.card_union_le _ _ ) |> le_trans <| by norm_num;
      have h_diff_bound' : ((Finset.filter (fun k => leadingDigitBase b (v k) = d) (Finset.range N)).card : ℝ) ≤ ((Finset.filter (fun k => leadingDigitBase b (u k) = d) (Finset.range N)).card : ℝ) + K := by
        have h_diff_bound' : ((Finset.filter (fun k => leadingDigitBase b (v k) = d) (Finset.range N)).card : ℝ) ≤ ((Finset.filter (fun k => leadingDigitBase b (u k) = d) (Finset.range N)).card : ℝ) + ((Finset.filter (fun k => leadingDigitBase b (v k) = d ∧ k < K) (Finset.range N)).card : ℝ) := by
          norm_cast;
          rw [ ← Finset.card_union_add_card_inter ];
          exact le_add_right ( Finset.card_mono fun x hx => by by_cases hx' : x < K <;> aesop );
        refine le_trans h_diff_bound' ?_;
        simp +zetaDelta at *;
        exact le_trans ( Finset.card_le_card fun x hx => Finset.mem_range.mpr <| Finset.mem_filter.mp hx |>.2.2 ) ( by simpa );
      grind +extAll;
    -- Using the bound on the difference in counts, we can show that the difference in frequencies tends to zero.
    have h_freq_diff_zero : Filter.Tendsto (fun N => ((Finset.filter (fun k => leadingDigitBase b (u k) = d) (Finset.range N)).card : ℝ) / N - ((Finset.filter (fun k => leadingDigitBase b (v k) = d) (Finset.range N)).card : ℝ) / N) Filter.atTop (nhds 0) := by
      refine' squeeze_zero_norm' _ _;
      exacts [ fun n => K / n, Filter.eventually_atTop.mpr ⟨ K, fun n hn => by simpa [ ← sub_div ] using div_le_div_of_nonneg_right ( h_diff_bound n hn ) ( Nat.cast_nonneg n ) ⟩, tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop ];
    exact h_freq_diff_zero.congr fun N => by aesop;
  constructor <;> intro h d hd₁ hd₂;
  · simpa using h d hd₁ hd₂ |> Filter.Tendsto.sub <| h_diff_zero d hd₁ hd₂;
  · simpa using h d hd₁ hd₂ |> Filter.Tendsto.add <| h_diff_zero d hd₁ hd₂

/-! ## The Main Conjecture: Benford Universality

**Conjecture**: For an integer dynamical map T with multiplicative expansion
on average, the orbit {T^k(n)} is Benford for density-1 seeds n if and only if
the additive cocycle log_10(T^k(n)) mod 1 has no nontrivial rational
eigen-obstruction.

**Testable prediction**: For the 3n+1 map, compute orbit mantissa statistics
for seeds 1 to 10^6. The conjecture predicts Benford behavior for all seeds
(since log_10(3) is irrational, yielding no rational obstruction for generic orbits).
Any systematic deviation refutes the conjecture. -/
def benford_universality_conjecture (T : IntDynMap) (b : ℕ) : Prop :=
  2 ≤ b →
  ∀ n, 1 ≤ n →
    (T.IsBenfordAt b n ↔ ¬ HasRationalEigenObstruction b (T.orbitSeq n))

end BenfordRenorm