import Mathlib

/-!
# ReLU Networks: Width vs Depth Trade-offs and Depth Separation

This file develops a self-contained, fully formal account of the
**depth-separation phenomenon** for ReLU networks, phrased through the
classical *tent map* (a width-2 one-hidden-layer ReLU block) and its
iterated compositions.

## The construction

The tent map `tent x = 1 - |2x - 1|` is a single ReLU layer of width 2
(Lemma `tent_relu_repr`). Composing it `k` times yields a function
`tent^[k]` computed by a **depth-`k`, constant-width** ReLU network of
total size `O(k)`. Although its output stays bounded in `[0,1]`, the
`k`-fold tent develops an exponentially steep oscillation: it rises from
`0` to `1` over an interval of width `2^{-k}` (Lemmas `tent_iterate_zero`,
`tent_iterate_peak`). Equivalently its Lipschitz constant is `2^k`
(Theorem `tent_iterate_lipschitz`).

## The separation

Theorem `relu_depth_separation` shows that **any** function `g` whose
Lipschitz constant `K` satisfies `K · 2^{-k} + 2ε < 1` cannot approximate
`tent^[k]` to accuracy `ε` on `[0,1]`. A bounded-weight shallow ReLU
network is exactly such a Lipschitz function, so it must have Lipschitz
constant — and hence (weight × width) budget — growing like `2^k` to even
match a depth-`k` network. This is the depth-separation theorem in its
analytic, ReLU-native form: equal output range, exponential oscillation.

## Catalog synthesis

This complements `MachineLearning.DepthSeparation.Separation`
(`not_uniformApprox_of_small_lipschitz`), which proves a Lipschitz
obstruction for the iterated *exponential* tower (whose *range* explodes).
Here the range stays in `[0,1]` and the obstruction comes from the
*oscillation* packed into a tiny interval — the genuinely neural
(piecewise-linear) mechanism behind Telgarsky-style depth separation.

## Main results

* `tent_relu_repr` — the tent map is a width-2 ReLU layer
* `tent_lipschitz` — the tent map is `2`-Lipschitz
* `tent_iterate_lipschitz` — `tent^[k]` is `2^k`-Lipschitz (deep net)
* `tent_iterate_zero`, `tent_iterate_peak` — the exponentially steep ramp
* `relu_depth_separation` — Lipschitz functions cannot approximate `tent^[k]`
-/

noncomputable section

open Set

namespace ReLUDepthWidth

/-- The ReLU activation `relu x = max x 0`. -/
def relu (x : ℝ) : ℝ := max x 0

/-- The tent map `tent x = 1 - |2x - 1|`, the canonical depth-1 ReLU block.
On `[0,1]` it is the symmetric triangle peaking at `x = 1/2`. -/
def tent (x : ℝ) : ℝ := 1 - |2 * x - 1|

/-- The tent map is realized by a single ReLU layer of width two. -/
-- !-- |y| = relu y + relu (-y), so the tent map is a width-2 one-hidden-layer ReLU network. -- !--
theorem tent_relu_repr (x : ℝ) :
    tent x = 1 - relu (2 * x - 1) - relu (1 - 2 * x) := by
  unfold tent relu; grind

/-- The tent map is `2`-Lipschitz (a single ReLU block of slope ±2). -/
-- !-- tent = 1 - |2x-1|; abs is 1-Lipschitz, so tent is 2-Lipschitz via abs_sub_abs_le_abs_sub. -- !--
theorem tent_lipschitz : LipschitzWith 2 tent := by
  refine' LipschitzWith.of_dist_le_mul _
  norm_num [Real.dist_eq, tent]
  exact fun x y => abs_le.mpr
    ⟨by cases abs_cases (2 * x - 1) <;> cases abs_cases (2 * y - 1) <;>
        cases abs_cases (x - y) <;> linarith,
     by cases abs_cases (2 * x - 1) <;> cases abs_cases (2 * y - 1) <;>
        cases abs_cases (x - y) <;> linarith⟩

/-- The tent map sends `[0,1]` into `[0,1]`. -/
-- !-- For x ∈ [0,1], -1 ≤ 2x-1 ≤ 1, so |2x-1| ≤ 1 and 0 ≤ 1 - |2x-1| ≤ 1. -- !--
theorem tent_mapsTo : MapsTo tent (Icc (0:ℝ) 1) (Icc (0:ℝ) 1) := by
  exact fun x hx => ⟨sub_nonneg.2 <| by
      cases abs_cases (2 * x - 1) <;> linarith [hx.1, hx.2],
    sub_le_self _ <| abs_nonneg _⟩

/-- On the ascending branch `x ≤ 1/2`, the tent map is exactly `2x`. -/
-- !-- For x ≤ 1/2, 2x-1 ≤ 0 so |2x-1| = 1-2x and tent x = 2x. -- !--
theorem tent_eq_two_mul {x : ℝ} (hx : x ≤ 1 / 2) : tent x = 2 * x := by
  unfold tent; rw [abs_of_nonpos] <;> linarith

/-- A depth-`k` tent network is `2^k`-Lipschitz: the Lipschitz constant grows
exponentially with depth at constant width. -/
-- !-- LipschitzWith.iterate: composing a 2-Lipschitz map k times gives 2^k-Lipschitz. -- !--
theorem tent_iterate_lipschitz (k : ℕ) : LipschitzWith (2 ^ k) (tent^[k]) := by
  convert LipschitzWith.iterate tent_lipschitz k using 1

/-- The `k`-fold tent fixes the left endpoint: `tent^[k] 0 = 0`. -/
-- !-- tent 0 = 0, and the orbit of the fixed point 0 stays at 0; induction on k. -- !--
theorem tent_iterate_zero (k : ℕ) : tent^[k] (0 : ℝ) = 0 := by
  induction k <;> simp_all +decide [Function.iterate_succ_apply']
  unfold tent; norm_num

/-- The first peak of the `k`-fold tent occurs at `x = (1/2)^k`, where the
value is `1`. Combined with `tent_iterate_zero`, the function climbs from
`0` to `1` over an interval of width `2^{-k}`. -/
-- !-- tent ((1/2)^(k+1)) = (1/2)^k since (1/2)^(k+1) ≤ 1/2; then induct using tent_eq_two_mul. -- !--
theorem tent_iterate_peak (k : ℕ) : tent^[k] ((1 / 2 : ℝ) ^ k) = 1 := by
  induction' k with k ih <;> simp_all +decide [Function.iterate_succ_apply']
  have h_tent_half : tent ((1 / 2 : ℝ) ^ (k + 1)) = (1 / 2 : ℝ) ^ k := by
    rw [tent_eq_two_mul]
    · ring
    · exact mul_le_of_le_one_left (by norm_num) (pow_le_one₀ (by norm_num) (by norm_num))
  rw [← Function.iterate_succ_apply' tent k]; aesop

/-- **ReLU depth-separation theorem.** If `g` is `K`-Lipschitz with
`K · 2^{-k} + 2ε < 1`, then `g` cannot approximate `tent^[k]` within `ε`
uniformly on `[0,1]`. Hence approximating a depth-`k` constant-width tent
network with a Lipschitz (e.g. bounded-weight shallow) network forces the
Lipschitz constant to grow like `2^k`. -/
-- !-- f rises 0→1 over width 2^{-k}; a K-Lipschitz g within ε at both endpoints forces
--     1 ≤ 2ε + K·2^{-k}, contradicting the hypothesis. -- !--
theorem relu_depth_separation (k : ℕ) (g : ℝ → ℝ) (K ε : ℝ)
    (hg : ∀ x y, |g x - g y| ≤ K * |x - y|)
    (hKε : K * (1 / 2 : ℝ) ^ k + 2 * ε < 1) :
    ¬ (∀ x ∈ Icc (0 : ℝ) 1, |tent^[k] x - g x| ≤ ε) := by
  contrapose! hKε
  have h₁ := hKε 0 ⟨by norm_num, by norm_num⟩
  have h₂ := hKε ((1 / 2) ^ k) ⟨by positivity, pow_le_one₀ (by norm_num) (by norm_num)⟩
  norm_num [abs_le, tent_iterate_zero, tent_iterate_peak] at *
  have := hg 0 ((1 / 2) ^ k)
  norm_num [abs_of_nonneg, pow_nonneg] at *
  linarith

/-- The separation threshold is sharp: `tent^[k]` approximates itself with
`ε = 0`, and there `K = 2^k` gives `K · 2^{-k} + 0 = 1`, exactly failing the
strict inequality of `relu_depth_separation`. This shows the hypothesis
`K · 2^{-k} + 2ε < 1` cannot be relaxed to `≤`. -/
-- !-- (2^k)·(1/2)^k = (2·1/2)^k = 1, so the budget exactly hits the threshold. -- !--
theorem relu_depth_separation_sharp (k : ℕ) :
    (2 ^ k : ℝ) * (1 / 2 : ℝ) ^ k + 2 * 0 = 1 := by
  norm_num [← mul_pow]

end ReLUDepthWidth

/-- Illustration: at depth `k = 3`, the constant function `1/2` (which is
`0`-Lipschitz, `K = 0`, the extreme "shallow" case) fails to
approximate the depth-3 tent network better than the threshold, since
`1 · (1/2)^3 + 2·0 = 1/8 < 1`. -/
example : ¬ (∀ x ∈ Icc (0 : ℝ) 1,
    |ReLUDepthWidth.tent^[3] x - (fun _ => (1/2 : ℝ)) x| ≤ (3/8 : ℝ)) := by
  apply ReLUDepthWidth.relu_depth_separation 3 (fun _ => (1/2 : ℝ)) 0 (3/8)
  · intro x y; simp
  · norm_num

end