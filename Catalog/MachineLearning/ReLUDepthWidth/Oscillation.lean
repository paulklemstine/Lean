import Mathlib

/-!
# Tent-Map Oscillation: a Dyadic Counting Lower Bound

This file sharpens the *single steep ramp* of
`MachineLearning.ReLUDepthWidth.Basic` (`relu_depth_separation`) into a
**Telgarsky-style oscillation count**.

The depth-`k`, constant-width tent network `tent^[k]` is shown to take the
value `0` at every *even* dyadic node `j / 2^k` and the value `1` at every
*odd* dyadic node (`tent_iterate_dyadic`). It therefore oscillates between
`0` and `1` exactly `2^k` times on `[0,1]`.

As a consequence, **any** continuous function `g` that approximates
`tent^[k]` to accuracy `ε < 1/2` is *forced* to cross the level `1/2` inside
each of the `2^k` dyadic subintervals `[i/2^k, (i+1)/2^k]`
(`tent_forces_crossings`). This is the crossing-number obstruction that
underlies exponential width lower bounds: a shallow piecewise-linear network
with `w` pieces can cross a level at most `w` times, so matching the deep tent
forces `w ≥ 2^k` regardless of weight magnitudes — a strictly stronger
statement than the Lipschitz separation.

## Catalog synthesis

The tent map `tent` and its ascending-branch identity `tent_eq_two_mul` are
the engine of `MachineLearning.ReLUDepthWidth.Basic`; they are re-stated here
(self-contained) so that the dyadic counting argument is independent. The
oscillation count strengthens `relu_depth_separation` from "one ramp" to
"`2^k` ramps".

-- !-- Lab Notebook -- !--
Hypothesis: the iterated tent restricted to the dyadic grid of order `k`
  realizes the pure alternation `0,1,0,1,…`, i.e. `tent^[k](j/2^k) = j mod 2`.
Result: proven (`tent_iterate_dyadic`) by induction on `k` using the folding
  identity `tent(j/2^{k+1}) = j/2^k` (left half) and `= (2^{k+1}-j)/2^k`
  (right half), together with `Function.iterate_succ_apply`.
Insight: the obstruction is *count*, not *magnitude*. The same endpoints that
  power the Lipschitz separation of `Basic.lean` here give `2^k` independent
  sign changes of `g - 1/2`, upgrading "one steep ramp" to "exponentially many
  ramps" — the weight-magnitude-independent form of depth separation.
Failure analysis: a naive induction on `k` keeping `j` fixed fails because the
  base value `tent^[0](j) = j` is not `0/1`; the fix is to carry the bound
  `j ≤ 2^k` and fold via the two affine branches of `tent`.
-- !-- -- !--
-/

noncomputable section

open Set

namespace ReLUDepthWidth

/-- The tent map `tent x = 1 - |2x - 1|`, the canonical depth-1 ReLU block. -/
def tent (x : ℝ) : ℝ := 1 - |2 * x - 1|

/-- On the ascending branch `x ≤ 1/2`, the tent map is exactly `2x`. -/
theorem tent_eq_two_mul {x : ℝ} (hx : x ≤ 1 / 2) : tent x = 2 * x := by
  unfold tent; rw [abs_of_nonpos] <;> linarith

-- !-- For x ≥ 1/2, 2x-1 ≥ 0 so |2x-1| = 2x-1 and tent x = 1-(2x-1) = 2-2x. -- !--
/-- On the descending branch `1/2 ≤ x`, the tent map is `2 - 2x`. -/
theorem tent_eq_two_sub {x : ℝ} (hx : 1 / 2 ≤ x) : tent x = 2 - 2 * x := by
  unfold tent; rw [abs_of_nonneg] <;> linarith

-- !-- Induction on k via tent^[k+1](x) = tent^[k](tent x); fold j/2^{k+1} to j/2^k
--     (j ≤ 2^k) or to (2^{k+1}-j)/2^k (j ≥ 2^k), then apply IH; parity is preserved
--     since 2^{k+1} is even. -- !--
/-- **Dyadic alternation of the iterated tent.** On the dyadic grid of order
`k`, the depth-`k` tent network realizes the pure two-cycle: it vanishes at
even nodes and equals `1` at odd nodes. Hence `tent^[k]` oscillates `2^k`
times between `0` and `1` across `[0,1]`. -/
theorem tent_iterate_dyadic (k : ℕ) :
    ∀ j : ℕ, j ≤ 2 ^ k → tent^[k] ((j : ℝ) / 2 ^ k) = ((j % 2 : ℕ) : ℝ) := by
  induction' k with k ih <;> simp_all +decide [ Function.iterate_succ_apply' ]
  intro j hj; by_cases hj' : j ≤ 2 ^ k <;> simp_all +decide [ pow_succ' ]
  · convert ih j hj' using 1 ; ring
    rw [ ← Function.iterate_succ_apply' tent k ] ; norm_num [ mul_assoc, mul_comm, mul_left_comm ] ; ring
    rw [ tent_eq_two_mul ] <;> ring ; norm_num [ hj' ]
    exact le_trans ( mul_le_mul_of_nonneg_right ( Nat.cast_le.mpr hj' ) ( by positivity ) ) ( by norm_num [ mul_assoc, ← mul_pow ] )
  · -- On the descending branch tent x = 2 - 2x, folding j to 2^{k+1} - j.
    have h_tent_ge_half : tent (j / (2 * 2 ^ k)) = (2 ^ (k + 1) - j) / 2 ^ k := by
      rw [ tent_eq_two_sub ]
      · field_simp
        ring
      · rw [ div_le_div_iff₀ ] <;> norm_cast <;> linarith [ pow_pos ( zero_lt_two' ℕ ) k ]
    convert ih ( 2 ^ ( k + 1 ) - j ) _ using 1
    · rw [ Nat.cast_sub ( by linarith [ pow_succ' 2 k ] ) ] ; simp_all +decide
      erw [ ← h_tent_ge_half, Function.iterate_succ_apply' ]
    · norm_cast ; simp +decide [ Nat.pow_succ' ]
      omega
    · grind

/-- The even dyadic nodes are zeros of the deep tent network. -/
theorem tent_iterate_even_node (k : ℕ) (j : ℕ) (hj : 2 * j ≤ 2 ^ k) :
    tent^[k] ((2 * j : ℝ) / 2 ^ k) = 0 := by
  convert tent_iterate_dyadic k ( 2 * j ) ( mod_cast hj ) using 1 ; norm_num
  norm_num [ Nat.mul_mod ]

/-- The odd dyadic nodes are ones of the deep tent network. -/
theorem tent_iterate_odd_node (k : ℕ) (j : ℕ) (hj : 2 * j + 1 ≤ 2 ^ k) :
    tent^[k] ((2 * j + 1 : ℝ) / 2 ^ k) = 1 := by
  convert tent_iterate_dyadic k ( 2 * j + 1 ) ( by exact_mod_cast hj ) using 1 ; norm_num [ Nat.add_mod ]
  norm_num [ Nat.add_mod ]

-- !-- Consecutive dyadic nodes i, i+1 carry tent-values 0 and 1 (in some order); with
--     ε<1/2 the approximant g sits on opposite sides of 1/2 at the endpoints, so
--     the intermediate value theorem yields an interior point where g = 1/2. -- !--
/-- **Crossing lower bound (oscillation obstruction).** If `g` is continuous
on `[0,1]` and approximates the depth-`k` tent network `tent^[k]` to accuracy
`ε < 1/2`, then `g` is forced to attain the value `1/2` inside *every* one of
the `2^k` dyadic subintervals `[i/2^k, (i+1)/2^k]`. Since these intervals are
essentially disjoint, `g` crosses the level `1/2` at least `2^k` times; a
piecewise-linear shallow network of width `w` crosses any level at most `w`
times, forcing `w ≥ 2^k` independently of weight magnitudes. -/
theorem tent_forces_crossings (k : ℕ) (g : ℝ → ℝ) (ε : ℝ)
    (hε : ε < 1 / 2)
    (hg : ContinuousOn g (Icc (0 : ℝ) 1))
    (happ : ∀ x ∈ Icc (0 : ℝ) 1, |tent^[k] x - g x| ≤ ε)
    (i : ℕ) (hi : i + 1 ≤ 2 ^ k) :
    ∃ c ∈ Icc ((i : ℝ) / 2 ^ k) (((i : ℝ) + 1) / 2 ^ k), g c = 1 / 2 := by
  -- The two consecutive dyadic nodes carry tent-values 0 and 1, in some order.
  have h_values : (tent^[k] ((i : ℝ) / (2^k))) = (i % 2 : ℕ) ∧
      (tent^[k] (((i + 1) : ℝ) / (2^k))) = ((i + 1) % 2 : ℕ) := by
    exact ⟨ mod_cast tent_iterate_dyadic k i ( by linarith ),
            mod_cast tent_iterate_dyadic k ( i + 1 ) ( by linarith ) ⟩
  cases' Nat.mod_two_eq_zero_or_one i with h h <;> simp_all +decide [ Nat.add_mod ] <;> norm_num at *
  · apply_rules [ intermediate_value_Icc ]
    · bound
    · exact hg.mono ( Set.Icc_subset_Icc ( by positivity ) ( by rw [ div_le_iff₀ ( by positivity ) ] ; norm_cast; linarith ) )
    · constructor <;> linarith [ abs_le.mp ( happ ( i / 2 ^ k ) ( by positivity ) ( by rw [ div_le_iff₀ ( by positivity ) ] ; norm_cast; linarith ) ), abs_le.mp ( happ ( ( i + 1 ) / 2 ^ k ) ( by positivity ) ( by rw [ div_le_iff₀ ( by positivity ) ] ; norm_cast; linarith ) ) ]
  · apply_rules [ intermediate_value_Icc' ] <;> norm_num [ h_values ]
    · bound
    · exact hg.mono ( Set.Icc_subset_Icc ( by positivity ) ( by rw [ div_le_iff₀ ( by positivity ) ] ; norm_cast; linarith ) )
    · constructor <;> linarith [ abs_le.mp ( happ ( ( i : ℝ ) / 2 ^ k ) ( by positivity ) ( by rw [ div_le_iff₀ ( by positivity ) ] ; norm_cast; linarith ) ), abs_le.mp ( happ ( ( i + 1 : ℝ ) / 2 ^ k ) ( by positivity ) ( by rw [ div_le_iff₀ ( by positivity ) ] ; norm_cast; linarith ) ) ]

end ReLUDepthWidth

end