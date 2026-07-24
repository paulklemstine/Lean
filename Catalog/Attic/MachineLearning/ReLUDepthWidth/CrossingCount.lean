import Mathlib
import MachineLearning.ReLUDepthWidth.Oscillation

/-!
# From One Crossing to an Exponential Width Lower Bound

This file upgrades the *single-interval* crossing obstruction
`MachineLearning.ReLUDepthWidth.Oscillation.tent_forces_crossings` into a
genuine, weight-magnitude-independent **width lower bound** for approximating
the depth-`k` tent network `tent^[k]`.

Where `Basic.lean` (`relu_depth_separation`) gives a *Lipschitz* obstruction
(one steep ramp) and `Oscillation.lean` (`tent_forces_crossings`,
`tent_iterate_dyadic`) localizes *one* crossing of the level `1/2` inside each
dyadic cell, this file:

* pins the crossings to the *open* cells (`tent_forces_crossing_Ioo`), by
  observing that an `ε`-approximant with `ε < 1/2` can never equal `1/2` at a
  dyadic node (`tent_node_value_ne_half`), so the crossing is strictly interior;
* assembles them into a **strictly increasing family of `2^k` distinct level-`1/2`
  crossings** indexed by `Fin (2^k)` (`tent_width_lower_bound`). A continuous
  piecewise-linear network of width `w` meets a horizontal level in at most `w`
  points, so matching `tent^[k]` to accuracy `ε < 1/2` forces `w ≥ 2^k` — an
  exponential width lower bound that depends on the *count* of oscillations,
  not on any weight magnitude;
* records the matching *discrete total-variation* identity
  (`tent_dyadic_total_variation`): the deep tent's variation across the dyadic
  grid is exactly `2^k`, the quantitative engine behind the crossing count.

## Catalog synthesis

We build directly on `ReLUDepthWidth.tent_iterate_dyadic` (the `0,1,0,1,…`
alternation on the dyadic grid) and `ReLUDepthWidth.tent_forces_crossings` (one
crossing per cell) from `Oscillation.lean`. The new ingredient is the *node
non-degeneracy* lemma, which turns "a crossing somewhere in the closed cell"
into "a crossing strictly inside the open cell", and hence into `2^k` *distinct*
crossings. This is the cardinality (counting) refinement of the analytic
separation in `Basic.lean`.

## Main results

* `tent_node_value_ne_half` — an `ε<1/2` approximant is never `1/2` at a dyadic node.
* `tent_dyadic_consecutive_diff` — adjacent dyadic nodes differ by exactly `1`.
* `tent_dyadic_total_variation` — discrete total variation of `tent^[k]` is `2^k`.
* `tent_forces_crossing_Ioo` — a crossing strictly inside each open dyadic cell.
* `tent_width_lower_bound` — a strictly increasing `Fin (2^k)`-family of crossings.

-- !-- Lab Notebook -- !--
Hypothesis: the "one crossing per cell" obstruction can be sharpened to "2^k
  *distinct* crossings", giving a counting (width) lower bound that is immune to
  weight magnitudes, strictly stronger than the Lipschitz bound of Basic.lean.
Result: confirmed. The decisive observation is that at a dyadic node the deep
  tent equals 0 or 1, so any ε<1/2 approximant is bounded strictly away from
  1/2 there; therefore the IVT crossing inside each closed cell cannot sit on a
  shared endpoint and lands in the *open* cell, yielding strict monotonicity of
  the assembled family.
Insight: depth manufactures *count*. The governing invariant is the number of
  sign changes of g - 1/2, which the discrete total variation 2^k lower-bounds
  cell-by-cell; magnitude (Lipschitz constant) is irrelevant to this argument.
Failure analysis: a direct attempt to make `tent_forces_crossings` return open
  intervals fails without node non-degeneracy — the closed-interval crossings
  can a priori coincide at the shared endpoint i/2^k, collapsing the count. The
  node lemma is exactly what forbids that collapse.
-- !-- -- !--
-/

noncomputable section

open Set

namespace ReLUDepthWidth

/-
!-- At a dyadic node the deep tent is 0 or 1; an ε<1/2 approximant is within ε of that
value, hence on one fixed side of 1/2 and never equal to it. -- !--

**Node non-degeneracy.** If `g` approximates `tent^[k]` to accuracy
`ε < 1/2` on `[0,1]`, then at every dyadic node `j/2^k` the value `g (j/2^k)`
is strictly away from `1/2`, since `tent^[k]` there is `0` or `1`.
-/
theorem tent_node_value_ne_half (k : ℕ) (g : ℝ → ℝ) (ε : ℝ)
    (hε : ε < 1 / 2)
    (happ : ∀ x ∈ Icc (0 : ℝ) 1, |tent^[k] x - g x| ≤ ε)
    (j : ℕ) (hj : j ≤ 2 ^ k) :
    g ((j : ℝ) / 2 ^ k) ≠ 1 / 2 := by
  have := tent_iterate_dyadic k j hj;
  cases Nat.mod_two_eq_zero_or_one j <;> simp_all +decide; all_goals linarith [ abs_le.mp ( happ ( j / 2 ^ k ) ( by positivity ) ( by rw [ div_le_iff₀ ( by positivity ) ] ; norm_cast; linarith ) ) ]

/-
!-- tent^[k](i/2^k)=i%2 and tent^[k]((i+1)/2^k)=(i+1)%2 by tent_iterate_dyadic; consecutive
naturals have opposite parity, so the values are 0 and 1 in some order, differing by 1. -- !--

**Adjacent dyadic nodes differ by exactly one.** Each elementary jump of the
deep tent across one dyadic cell has absolute size `1`.
-/
theorem tent_dyadic_consecutive_diff (k i : ℕ) (hi : i + 1 ≤ 2 ^ k) :
    |tent^[k] (((i : ℝ) + 1) / 2 ^ k) - tent^[k] ((i : ℝ) / 2 ^ k)| = 1 := by
  -- Apply the hypothesis `h_step` to get the values of `tent^[k]` at the ends of the interval.
  have h_values : tent^[k] ((i : ℝ) / 2 ^ k) = ((i % 2 : ℕ) : ℝ) ∧ tent^[k] (((i + 1) : ℝ) / 2 ^ k) = (((i + 1) % 2 : ℕ) : ℝ) := by
    exact ⟨ mod_cast tent_iterate_dyadic k i ( by linarith ), mod_cast tent_iterate_dyadic k ( i + 1 ) ( by linarith ) ⟩;
  cases Nat.mod_two_eq_zero_or_one i <;> simp_all +decide [ Nat.add_mod ]

/-
!-- Each summand is 1 by `tent_dyadic_consecutive_diff` (i < 2^k ⟹ i+1 ≤ 2^k); summing the
constant 1 over `range (2^k)` gives `2^k`. -- !--

**Discrete total variation of the deep tent is `2^k`.** Summing the
elementary jumps over the `2^k` dyadic cells of `[0,1]` yields exactly `2^k`:
the quantitative form of "the depth-`k` tent oscillates `2^k` times".
-/
theorem tent_dyadic_total_variation (k : ℕ) :
    ∑ i ∈ Finset.range (2 ^ k),
        |tent^[k] (((i : ℝ) + 1) / 2 ^ k) - tent^[k] ((i : ℝ) / 2 ^ k)| = 2 ^ k := by
  rw [ Finset.sum_congr rfl fun i hi => by rw [ tent_dyadic_consecutive_diff ] ; linarith [ Finset.mem_range.mp hi ] ] ; norm_num

/-
!-- `tent_forces_crossings` gives a crossing c in the closed cell; `tent_node_value_ne_half`
rules out c being either endpoint (where g ≠ 1/2), so c lies in the open cell. -- !--

**Strictly interior crossing.** Strengthening `tent_forces_crossings`: a
continuous `ε`-approximant with `ε < 1/2` attains the level `1/2` strictly
*inside* every open dyadic cell `(i/2^k, (i+1)/2^k)`.
-/
theorem tent_forces_crossing_Ioo (k : ℕ) (g : ℝ → ℝ) (ε : ℝ)
    (hε : ε < 1 / 2)
    (hg : ContinuousOn g (Icc (0 : ℝ) 1))
    (happ : ∀ x ∈ Icc (0 : ℝ) 1, |tent^[k] x - g x| ≤ ε)
    (i : ℕ) (hi : i + 1 ≤ 2 ^ k) :
    ∃ c ∈ Ioo ((i : ℝ) / 2 ^ k) (((i : ℝ) + 1) / 2 ^ k), g c = 1 / 2 := by
  have := ReLUDepthWidth.tent_forces_crossings k g ε hε hg happ i hi;
  obtain ⟨ c, hc₁, hc₂ ⟩ := this; refine' ⟨ c, ⟨ lt_of_le_of_ne hc₁.1 _, lt_of_le_of_ne hc₁.2 _ ⟩, hc₂ ⟩ <;> rintro rfl <;> norm_num at *;
  · have := ReLUDepthWidth.tent_node_value_ne_half k g ε hε ( fun x hx => happ x hx.1 hx.2 ) i ( by linarith ) ; aesop;
  · have := ReLUDepthWidth.tent_node_value_ne_half k g ε hε ( fun x hx => happ x hx.1 hx.2 ) ( i + 1 ) ( by linarith ) ; aesop;

/-
!-- Choose one interior crossing c_i ∈ (i/2^k,(i+1)/2^k) per cell via
`tent_forces_crossing_Ioo`. For i<j: c_i < (i+1)/2^k ≤ j/2^k < c_j gives StrictMono;
0 ≤ i/2^k < c_i and c_i < (i+1)/2^k ≤ 1 gives membership in Ioo 0 1. -- !--

**Exponential width lower bound (the counting separation).** Any continuous
function `g` approximating the depth-`k` tent network `tent^[k]` to accuracy
`ε < 1/2` on `[0,1]` meets the level `1/2` at a *strictly increasing* family of
`2^k` distinct interior points. Since a width-`w` continuous piecewise-linear
network meets a horizontal level in at most `w` points, matching `tent^[k]`
forces width `w ≥ 2^k`, regardless of weight magnitudes — a strict
strengthening of the Lipschitz separation `relu_depth_separation`.
-/
theorem tent_width_lower_bound (k : ℕ) (g : ℝ → ℝ) (ε : ℝ)
    (hε : ε < 1 / 2)
    (hg : ContinuousOn g (Icc (0 : ℝ) 1))
    (happ : ∀ x ∈ Icc (0 : ℝ) 1, |tent^[k] x - g x| ≤ ε) :
    ∃ c : Fin (2 ^ k) → ℝ,
      StrictMono c ∧ (∀ i, c i ∈ Ioo (0 : ℝ) 1) ∧ (∀ i, g (c i) = 1 / 2) := by
  have h_crossing : ∀ i : Fin (2 ^ k), ∃ c ∈ Set.Ioo ((i.val : ℝ) / 2 ^ k) (((i.val : ℝ) + 1) / 2 ^ k), g c = 1 / 2 := by
    exact fun i => ReLUDepthWidth.tent_forces_crossing_Ioo k g ε hε hg happ i.val ( by linarith [ Fin.is_lt i ] );
  choose c hc using h_crossing;
  refine' ⟨ c, _, _, _ ⟩;
  · intro i j hij; have := hc i; have := hc j; norm_num at *; ring_nf at *;
    nlinarith [ show ( i : ℝ ) + 1 ≤ j from mod_cast hij, show ( 2⁻¹ : ℝ ) ^ k > 0 by positivity ];
  · exact fun i => ⟨ lt_of_le_of_lt ( by positivity ) ( hc i |>.1 |>.1 ), lt_of_lt_of_le ( hc i |>.1 |>.2 ) ( by rw [ div_le_iff₀ ( by positivity ) ] ; norm_cast; linarith [ Fin.is_lt i ] ) ⟩;
  · exact fun i => hc i |>.2

end ReLUDepthWidth

end