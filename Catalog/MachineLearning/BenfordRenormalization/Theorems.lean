/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Speculative.BenfordRenormalization.Defs

/-!
# Benford Renormalization: Main Theorems

This module contains the core theorems of the Benford renormalization theory:

1. **Power-of-base non-Benford theorem**: Sequences that are perfect powers
   of the base always have leading digit 1 and are not Benford (for base ≥ 3).

2. **Constant-frequency obstruction**: If the leading digit is eventually
   constant, the sequence cannot be Benford (for base ≥ 3).

3. **Benford from irrational rotation model**: If the fractional logarithm
   follows an irrational rotation, the sequence is Benford (conditioned
   on equidistribution).

4. **Stability under eventual equality**: Benford behavior is invariant
   under finite modifications of the sequence.

5. **Geometric sequence log decomposition**: The fractional logarithm of
   a geometric sequence decomposes as an affine rotation.

Note: Base 2 is degenerate — every positive sequence is trivially Benford
in base 2 since the only possible leading digit is 1.
-/

namespace BenfordRenormalization

open Real Finset Filter

/-! ## Theorem 1: Powers of base are not Benford (b ≥ 3)

If `u(k) = b^(f(k))` for all `k`, then the leading digit is always 1.
Since the Benford frequency for digit 1 in base `b ≥ 3` is
`log_b(2) < 1`, the empirical frequency 1 ≠ log_b(2).
-/

/-
If `u(k) = b^(f(k))` for all `k` and `b ≥ 3`, the sequence is not Benford.
The leading digit is always 1, giving frequency 1, but the Benford
prediction is `log_b(2) < 1`. This is a concrete rational eigen-obstruction.
-/
theorem not_benford_of_pow_base (b : ℕ) (f : ℕ → ℕ) (hb : 3 ≤ b) :
    ¬ IsBenford b (fun k => b ^ f k) := by
  intro h; have := h 1 le_rfl ( by linarith ) ; norm_num [ IsBenford ] at this;
  convert absurd ( tendsto_nhds_unique this <| tendsto_const_nhds.congr' _ ) _;
  exact 1;
  · filter_upwards [ Filter.eventually_gt_atTop 0 ] with N hN;
    rw [ eq_comm, benfordFreqUpTo_eq_one_of_all ];
    · linarith;
    · exact fun k hk => leadingDigitBase_pow b _ ( by linarith );
  · exact ne_of_lt ( benfordTheoretical_one_lt_one_of_base_ge_three b hb )

/-! ## Theorem 2: Eventually constant leading digit obstructs Benford (b ≥ 3)

If the leading digit stabilizes to some value `d` and `b ≥ 3`, then
`benfordFreqUpTo b d u N → 1` but `benfordTheoretical b d < 1`,
giving a contradiction.
-/

/-
If the leading digit of `u(k)` is eventually equal to `d` where
`1 ≤ d` and `d + 1 < b`, then the sequence is not Benford in base `b`.
The `d + 1 < b` condition excludes the degenerate base-2 case.
-/
theorem not_benford_of_eventually_constant_digit
    (b d : ℕ) (u : ℕ → ℕ) (hb : 2 ≤ b) (hd : 1 ≤ d) (hdb : d + 1 < b)
    (hev : ∀ᶠ k in atTop, leadingDigitBase b (u k) = d) :
    ¬ IsBenford b u := by
  intro hBenford
  have h_lim : Filter.Tendsto (fun N => benfordFreqUpTo b d u N) atTop (nhds 1) := by
    -- By definition of $benfordFreq �Up�To$, if the leading digit is eventually $d$, then for large enough $N$, the frequency of $d$ is at least $(N-K)/N$, which tends to $1$.
    have h_freq_ge : ∀ᶠ N in Filter.atTop, benfordFreqUpTo b d u N ≥ (N - (Classical.choose (Filter.eventually_atTop.mp hev))) / (N : ℝ) := by
      filter_upwards [ Filter.eventually_gt_atTop ( Classical.choose ( Filter.eventually_atTop.mp hev ) ) ] with N hN
      have h_filter_card : ((Finset.range N).filter (fun k => leadingDigitBase b (u k) = d)).card ≥ N - (Classical.choose (Filter.eventually_atTop.mp hev)) := by
        have h_filter_card : ((Finset.range N).filter (fun k => leadingDigitBase b (u k) = d)).card ≥ Finset.card (Finset.Ico (Classical.choose (Filter.eventually_atTop.mp hev)) N) := by
          exact Finset.card_le_card fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_range.mpr ( by linarith [ Finset.mem_Ico.mp hx ] ), Classical.choose_spec ( Filter.eventually_atTop.mp hev ) x ( by linarith [ Finset.mem_Ico.mp hx ] ) ⟩ ;
        aesop
      simp_all +decide [ benfordFreqUpTo ];
      rw [ if_neg ( by linarith ) ] ; rw [ div_le_div_iff_of_pos_right ( by norm_cast; linarith ) ] ; linarith [ ( by norm_cast : ( N : ℝ ) ≤ # ( Finset.filter ( fun k => leadingDigitBase b ( u k ) = d ) ( Finset.range N ) ) + Classical.choose ( Filter.eventually_atTop.mp hev ) ) ] ;
    -- Since $(N - K) / N$ tends to $1$ as $N$ tends to infinity, we can conclude that the frequency tends to $1$.
    have h_freq_lim : Filter.Tendsto (fun N : ℕ => (N - (Classical.choose (Filter.eventually_atTop.mp hev))) / (N : ℝ)) Filter.atTop (nhds 1) := by
      ring_nf;
      exact le_trans ( Filter.Tendsto.sub ( tendsto_const_nhds.congr' ( by filter_upwards [ Filter.eventually_ne_atTop 0 ] with N hN; aesop ) ) ( tendsto_const_nhds.mul tendsto_inv_atTop_nhds_zero_nat ) ) ( by norm_num );
    refine' tendsto_of_tendsto_of_tendsto_of_le_of_le' h_freq_lim tendsto_const_nhds _ _;
    · exact h_freq_ge;
    · exact Filter.Eventually.of_forall fun N => benfordFreqUpTo_le_one b d u N
  have h_theor : benfordTheoretical b d < 1 := by
    rw [ benfordTheoretical, div_lt_one ] <;> norm_num [ Real.log_pos, hb ];
    · exact Real.log_lt_log ( by positivity ) ( by nlinarith [ inv_mul_cancel₀ ( by positivity : ( d : ℝ ) ≠ 0 ), ( by norm_cast : ( 1 :ℝ ) ≤ d ), ( by norm_cast : ( d :ℝ ) + 1 < b ) ] );
    · exact Real.log_pos <| Nat.one_lt_cast.mpr hb
  exact absurd ( tendsto_nhds_unique h_lim ( hBenford d hd ( by linarith ) ) ) ( by linarith )

/-! ## Theorem 3: Benford from irrational rotation model

If the fractional logarithm follows an irrational rotation
`x₀ + k·α mod 1`, and we assume equidistribution (Weyl's theorem),
then the Benford frequency converges correctly. This bridges
ergodic rotation theory to digit-law universality.
-/

/-- Equidistribution of an irrational rotation in an interval:
the proportion of `k < N` with `fract(x₀ + k·α) ∈ [a, b)` converges to `b - a`. -/
def WeylEquidistribution (α x₀ a' b' : ℝ) : Prop :=
  Tendsto
    (fun N : ℕ =>
      let s := (range N).filter (fun k : ℕ =>
        a' ≤ Int.fract (x₀ + (k : ℝ) * α) ∧ Int.fract (x₀ + (k : ℝ) * α) < b')
      (s.card : ℝ) / (N : ℝ))
    atTop
    (nhds (b' - a'))

/-
**Benford from rotation model.** If the fractional logarithm of `u`
equals an irrational rotation `fract(x₀ + k·α)` for all `k`, and the
rotation is equidistributed on the Benford interval `[log_b(d), log_b(d+1))`,
then `benfordFreqUpTo b d u` converges to the Benford frequency.

This is the conceptual hinge between arithmetic dynamics and ergodic
rotation theory: first-digit laws become a spectral rigidity phenomenon.
-/
theorem benford_freq_of_rotation_model
    (b d : ℕ) (u : ℕ → ℕ) (α x₀ : ℝ)
    (hb : 2 ≤ b) (hd : 1 ≤ d) (hdb : d < b)
    (hpos : ∀ k, 1 ≤ u k)
    (hirr : Irrational α)
    (hmodel : ∀ k, Int.fract (Real.log (u k : ℝ) / Real.log (b : ℝ)) =
                    Int.fract (x₀ + (k : ℝ) * α))
    (hweyl : WeylEquidistribution α x₀
      (Real.log (d : ℝ) / Real.log (b : ℝ))
      (Real.log ((d + 1 : ℕ) : ℝ) / Real.log (b : ℝ))) :
    Tendsto (benfordFreqUpTo b d u) atTop
      (nhds (benfordTheoretical b d)) := by
  unfold WeylEquidistribution at hweyl;
  convert hweyl using 2;
  · -- By definition of `leadingDigitBase`, we know that `leadingDigitBase b (u k) = d` if and only if `log_b(d) ≤ log_b(u k) < log_b(d+1)`.
    have h_leading_digit : ∀ k, leadingDigitBase b (u k) = d ↔ (d : ℝ) ≤ u k / b ^ (Nat.log b (u k)) ∧ u k / b ^ (Nat.log b (u k)) < (d + 1 : ℝ) := by
      intro k
      have h_leading_digit : leadingDigitBase b (u k) = d ↔ (d : ℕ) ≤ u k / b ^ (Nat.log b (u k)) ∧ u k / b ^ (Nat.log b (u k)) < (d + 1 : ℕ) := by
        have h_leading_digit : ∀ n, 1 ≤ n → leadingDigitBase b n = n / b ^ (Nat.log b n) := by
          intro n hn; induction' n using Nat.strong_induction_on with n ih; rcases lt_or_ge n b with hn' | hn' <;> simp_all +decide [ Nat.log_of_lt ] ;
          · unfold leadingDigitBase; aesop;
          · rw [ leadingDigitBase_div ];
            · convert ih ( n / b ) ( Nat.div_lt_self hn ( by linarith ) ) ( Nat.div_pos hn' ( by linarith ) ) using 1;
              rw [ Nat.div_div_eq_div_mul, ← pow_succ', Nat.log_div_base ];
              rw [ Nat.sub_add_cancel ( Nat.log_pos ( by linarith ) ( by linarith ) ) ];
            · linarith;
            · linarith;
        grind;
      rw [ le_div_iff₀, div_lt_iff₀ ] <;> norm_cast <;> try positivity;
      rw [ h_leading_digit, Nat.le_div_iff_mul_le ( pow_pos ( by linarith ) _ ), Nat.div_lt_iff_lt_mul ( pow_pos ( by linarith ) _ ) ];
    have h_log_bounds : ∀ k, (d : ℝ) ≤ u k / b ^ (Nat.log b (u k)) ∧ u k / b ^ (Nat.log b (u k)) < (d + 1 : ℝ) ↔ Real.log d ≤ Real.log (u k) - Nat.log b (u k) * Real.log b ∧ Real.log (u k) - Nat.log b (u k) * Real.log b < Real.log (d + 1) := by
      intro k; rw [ ← Real.log_rpow, ← Real.log_div ] <;> norm_cast <;> norm_num [ ne_of_gt ( zero_lt_two.trans_le hb ) ] ;
      · rw [ Real.log_le_log_iff, Real.log_lt_log_iff ] <;> norm_cast <;> norm_num; all_goals exact div_pos ( Nat.cast_pos.mpr ( hpos k ) ) ( pow_pos ( Nat.cast_pos.mpr ( by linarith ) ) _ );
      · linarith [ hpos k ];
      · linarith;
    have h_log_bounds : ∀ k, Real.log d ≤ Real.log (u k) - Nat.log b (u k) * Real.log b ∧ Real.log (u k) - Nat.log b (u k) * Real.log b < Real.log (d + 1) ↔ Real.log d / Real.log b ≤ Int.fract (Real.log (u k) / Real.log b) ∧ Int.fract (Real.log (u k) / Real.log b) < Real.log (d + 1) / Real.log b := by
      intro k
      have h_log_bounds : Int.fract (Real.log (u k) / Real.log b) = Real.log (u k) / Real.log b - Nat.log b (u k) := by
        rw [ Int.fract_eq_iff ];
        rw [ le_sub_iff_add_le, sub_lt_iff_lt_add' ];
        exact ⟨ by rw [ zero_add, le_div_iff₀ ( Real.log_pos ( by norm_cast ) ) ] ; nth_rw 1 [ ← Real.log_pow ] ; exact Real.log_le_log ( by positivity ) ( mod_cast Nat.pow_log_le_self _ ( by linarith [ hpos k ] ) ), by rw [ div_lt_iff₀ ( Real.log_pos ( by norm_cast ) ) ] ; nth_rw 1 [ ← Real.log_rpow ( by positivity ) ] ; exact Real.log_lt_log ( by norm_cast; linarith [ hpos k ] ) ( mod_cast Nat.lt_pow_succ_log_self hb _ ), _, sub_sub_cancel _ _ ⟩;
      rw [ h_log_bounds, div_le_iff₀ ( Real.log_pos <| by norm_cast ), lt_div_iff₀ ( Real.log_pos <| by norm_cast ) ];
      rw [ sub_mul, div_mul_cancel₀ _ ( ne_of_gt ( Real.log_pos ( by norm_cast ) ) ) ];
    unfold benfordFreqUpTo; aesop;
  · unfold benfordTheoretical;
    field_simp;
    rw [ Real.log_div ( by positivity ) ( by positivity ), Nat.cast_add_one ]

/-! ## Theorem 4: Geometric sequence fractional log decomposition

For `u(k) = a · r^k` with `a ≥ 1` and `r ≥ 2`, the fractional
logarithm decomposes as `fract(log_b(a) + k · log_b(r))`, an affine
rotation. This connects geometric sequences to the rotation model. -/

/-
The fractional part of `log_b(a · r^k)` equals
`fract(log_b(a) + k · log_b(r))`.
-/
theorem fract_log_geometric (b a r k : ℕ)
    (hb : 2 ≤ b) (ha : 1 ≤ a) (hr : 2 ≤ r) :
    Int.fract (Real.log ((a * r ^ k : ℕ) : ℝ) / Real.log (b : ℝ)) =
    Int.fract (Real.log (a : ℝ) / Real.log (b : ℝ) +
      (k : ℝ) * (Real.log (r : ℝ) / Real.log (b : ℝ))) := by
  rw [ Nat.cast_mul, Nat.cast_pow, Real.log_mul ( by positivity ) ( by positivity ), Real.log_pow ] ; ring

/-! ## Theorem 5: Stability under eventual equality

Benford behavior is invariant under finite modifications. If two
sequences agree from some point onward, they have the same Benford
status. This is the simplest manifestation of the renormalization
principle: the asymptotic cocycle determines everything. -/

/-
If `benfordFreqUpTo b d v` converges to the Benford frequency and
`u(k) = v(k)` for all sufficiently large `k`, then
`benfordFreqUpTo b d u` also converges to the Benford frequency.
-/
theorem benford_stable_of_eventually_eq
    (b d : ℕ) (u v : ℕ → ℕ) (hb : 2 ≤ b) (hd : 1 ≤ d) (hdb : d < b)
    (hev : ∀ᶠ k in atTop, u k = v k)
    (hv : Tendsto (benfordFreqUpTo b d v) atTop
            (nhds (benfordTheoretical b d))) :
    Tendsto (benfordFreqUpTo b d u) atTop
      (nhds (benfordTheoretical b d)) := by
  -- Since `u k = v k` for all sufficiently large `k`, the difference in their Benford frequencies is bounded by `K/N` for some constant `K`.
  have h_diff_bound : ∃ K : ℕ, ∀ N > K, |(benfordFreqUpTo b d u N) - (benfordFreqUpTo b d v N)| ≤ K / (N : ℝ) := by
    -- Since `u k = v k` for � all� sufficiently large `k`, the cardinality of the set of indices where `u k` and `v k` differ is bounded by the number of indices where they differ.
    obtain ⟨K, hK⟩ : ∃ K : ℕ, ∀ N > K, ((range N).filter (fun k => leadingDigitBase b (u k) = d)).card ≤ ((range N).filter (fun k => leadingDigitBase b (v k) = d)).card + K ∧ ((range N).filter (fun k => leadingDigitBase b (v k) = d)).card ≤ ((range N).filter (fun k => leadingDigitBase b (u k) = d)).card + K := by
      -- Let $K$ be the number of � indices� where $u k$ and $v k$ differ.
      obtain ⟨K, hK⟩ : ∃ K : ℕ, ∀ N > K, ((range N).filter (fun k => leadingDigitBase b (u k) ≠ leadingDigitBase b (v k))).card ≤ K := by
        obtain ⟨ K, hK ⟩ := Filter.eventually_atTop.mp hev;
        use K + 1;
        intro N hN; exact le_trans ( Finset.card_le_card ( show Finset.filter ( fun k => ¬leadingDigitBase b ( u k ) = leadingDigitBase b ( v k ) ) ( Finset.range N ) ⊆ Finset.range ( K + 1 ) from fun x hx => Finset.mem_range.mpr <| Nat.lt_succ_of_le <| le_of_not_gt fun hx' => by have := hK x ( by linarith ) ; aesop ) ) ( by simp +arith +decide ) ;
      refine' ⟨ K, fun N hN => ⟨ _, _ ⟩ ⟩;
      · refine' le_trans _ ( Nat.add_le_add_left ( hK N hN ) _ );
        rw [ ← Finset.card_union_add_card_inter ];
        exact le_add_right ( Finset.card_mono fun x hx => by by_cases h : leadingDigitBase b ( u x ) = leadingDigitBase b ( v x ) <;> aesop );
      · refine' le_trans _ ( Nat.add_le_add_left ( hK N hN ) _ );
        rw [ ← Finset.card_union_add_card_inter ];
        exact le_add_right ( Finset.card_mono fun x hx => by by_cases hx' : leadingDigitBase b ( u x ) = d <;> aesop );
    use K; intro N hN; by_cases hN' : N = 0 <;> simp_all +decide [ benfordFreqUpTo ];
    rw [ abs_le ] ; constructor <;> nlinarith [ show ( N : ℝ ) > 0 by positivity, show ( # ( { k ∈ range N | leadingDigitBase b ( u k ) = d } ) : ℝ ) ≤ # ( { k ∈ range N | leadingDigitBase b ( v k ) = d } ) + K by exact_mod_cast hK N hN |>.1, show ( # ( { k ∈ range N | leadingDigitBase b ( v k ) = d } : Finset ℕ ) : ℝ ) ≤ # ( { k ∈ range N | leadingDigitBase b ( u k ) = d } : Finset ℕ ) + K by exact_mod_cast hK N hN |>.2, div_mul_cancel₀ ( # ( { k ∈ range N | leadingDigitBase b ( u k ) = d } : Finset ℕ ) : ℝ ) ( by positivity : ( N : ℝ ) ≠ 0 ), div_mul_cancel₀ ( # ( { k ∈ range N | leadingDigitBase b ( v k ) = d } : Finset ℕ ) : ℝ ) ( by positivity : ( N : ℝ ) ≠ 0 ), div_mul_cancel₀ ( K : ℝ ) ( by positivity : ( N : ℝ ) ≠ 0 ) ] ;
  -- Since $K/N \to  �0�$ as $N \to \infty$, we can apply the squeeze theorem.
  have h_squeeze : Filter.Tendsto (fun N : ℕ => (h_diff_bound.choose : ℝ) / (N : ℝ)) Filter.atTop (nhds 0) := by
    exact tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop;
  simpa using hv.add ( squeeze_zero_norm' ( Filter.eventually_atTop.mpr ⟨ h_diff_bound.choose + 1, fun N hN => h_diff_bound.choose_spec N ( by linarith ) ⟩ ) h_squeeze )

end BenfordRenormalization