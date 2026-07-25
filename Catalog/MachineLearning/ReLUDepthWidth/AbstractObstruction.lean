import Mathlib

/-!
# A Unified Two-Point Obstruction for Lipschitz Approximation

This file isolates the *single inequality* behind two superficially different
depth-separation theorems in the catalog:

* `MachineLearning.ReLUDepthWidth.relu_depth_separation` — the **tent map**
  `tent^[k]` keeps a bounded range `[0,1]` but explodes in **local slope**
  (`2^k`), and no `K`-Lipschitz function with `K·2^{-k} + 2ε < 1` can
  approximate it.
* `Pythagorean.RankBoundedEML.iterExp` — the iterated **exponential tower**
  `iterExp k` keeps moderate slope but explodes in **range**.

Both are instances of one fact: *if `f` takes values `f a` and `f b` at two
points `a, b`, then any `K`-Lipschitz `ε`-approximant `g` satisfies*
`|f a - f b| ≤ K·|a - b| + 2ε`. Range-blowup and slope-blowup are the two
ways to violate this bound.

The tent foundation (`tent`, `tent_iterate_zero`, `tent_iterate_peak`) and the
iterated exponential (`iterExp`, `iterExp_strictMono`) are re-stated here
(self-contained) so the unifying lemma can be back-applied to both with no
external dependency.

## Main results

* `twoPoint_gap_le` — the abstract triangle inequality (the unifying lemma).
* `no_lipschitz_approx_of_gap` — its contrapositive obstruction form.
* `tent_depth_separation_via_gap` — re-derives the tent separation as an instance.
* `iterExp_endpoint_gap_pos` — the exponential tower has a positive endpoint gap.
* `iterExp_depth_separation` — the exponential-tower separation as an instance
  of the *same* abstract lemma (the cross-domain bridge).
* `tent_adversarial` — a robustness reading: a sub-`2^k`-Lipschitz classifier
  has a `2^{-k}`-separated input pair whose true labels differ maximally.

-- !-- Lab Notebook -- !--
Hypothesis: the tent (slope-blowup) and exponential-tower (range-blowup)
  separations are two instances of one inequality `|f a - f b| ≤ K|a-b| + 2ε`.
Result: confirmed. `twoPoint_gap_le` is a three-term triangle inequality; both
  `tent_depth_separation_via_gap` and `iterExp_depth_separation` fall out by
  choosing the witnessing pair `(a,b)` and reading off `|f a - f b|`.
Insight: the governing quantity is the *witnessed gap-to-distance ratio*
  `|f a - f b| / |a - b|`; a deep network maximizes it either by a large
  numerator (tower) or a small denominator (tent). Lipschitz budget `K` is the
  single currency both must pay.
Failure analysis: trying to unify via *derivatives* (as in
  `DepthHierarchy.Separation`) needs differentiability and the MVT, which the
  tent map lacks at its kink. Working with the raw Lipschitz bound and two
  sample points sidesteps smoothness entirely and covers both cases.
-- !-- -- !--
-/

noncomputable section

open Set Real

namespace ReLUDepthWidth

/-! ## Tent foundation (self-contained re-statement of `Basic.lean`) -/

/-- The tent map `tent x = 1 - |2x - 1|`, the canonical depth-1 ReLU block. -/
def tent (x : ℝ) : ℝ := 1 - |2 * x - 1|

/-- On the ascending branch `x ≤ 1/2`, the tent map is exactly `2x`. -/
theorem tent_eq_two_mul {x : ℝ} (hx : x ≤ 1 / 2) : tent x = 2 * x := by
  unfold tent; rw [abs_of_nonpos] <;> linarith

/-- The `k`-fold tent fixes the left endpoint: `tent^[k] 0 = 0`. -/
theorem tent_iterate_zero (k : ℕ) : tent^[k] (0 : ℝ) = 0 := by
  induction k <;> simp_all +decide [Function.iterate_succ_apply']
  unfold tent; norm_num

/-- The first peak of the `k`-fold tent: `tent^[k] ((1/2)^k) = 1`. -/
theorem tent_iterate_peak (k : ℕ) : tent^[k] ((1 / 2 : ℝ) ^ k) = 1 := by
  induction' k with k ih <;> simp_all +decide [Function.iterate_succ_apply']
  have h_tent_half : tent ((1 / 2 : ℝ) ^ (k + 1)) = (1 / 2 : ℝ) ^ k := by
    rw [tent_eq_two_mul]
    · ring
    · exact mul_le_of_le_one_left (by norm_num) (pow_le_one₀ (by norm_num) (by norm_num))
  rw [← Function.iterate_succ_apply' tent k]; aesop

/-! ## Iterated exponential (self-contained re-statement of `RankBoundedEML.lean`) -/

/-- The iterated exponential: `iterExp 0 x = x`, `iterExp (n+1) x = exp(iterExp n x)`. -/
def iterExp : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => Real.exp (iterExp n x)

/-- `iterExp k` is strictly monotone for every `k`. -/
theorem iterExp_strictMono (k : ℕ) : StrictMono (iterExp k) := by
  induction k with
  | zero => exact strictMono_id
  | succ k ih => exact fun _ _ h => Real.exp_strictMono (ih h)

/-! ## The unifying obstruction -/

-- !-- Triangle inequality: |fa-fb| ≤ |fa-ga| + |ga-gb| + |gb-fb| ≤ ε + K|a-b| + ε. -- !--
/-- **The unifying two-point obstruction.** If `g` is `K`-Lipschitz (in the
pointwise form `|g x - g y| ≤ K|x-y|`) and approximates `f` to within `ε` at
two points `a` and `b`, then the gap `|f a - f b|` is controlled by the budget
`K·|a-b| + 2ε`. Every depth-separation result below is a contrapositive of this
single inequality. -/
theorem twoPoint_gap_le (f g : ℝ → ℝ) (a b K ε : ℝ)
    (hg : ∀ x y, |g x - g y| ≤ K * |x - y|)
    (hfa : |f a - g a| ≤ ε) (hfb : |f b - g b| ≤ ε) :
    |f a - f b| ≤ K * |a - b| + 2 * ε := by
  cases abs_cases ( f a - f b ) <;> cases abs_cases ( f a - g a ) <;>
    cases abs_cases ( f b - g b ) <;> cases abs_cases ( g a - g b ) <;> linarith [ hg a b ]

-- !-- Direct contrapositive of `twoPoint_gap_le`. -- !--
/-- **Contrapositive obstruction.** If the witnessed gap exceeds the Lipschitz
budget, `K·|a-b| + 2ε < |f a - f b|`, then no `K`-Lipschitz `g` can be within
`ε` of `f` at both sample points. -/
theorem no_lipschitz_approx_of_gap (f g : ℝ → ℝ) (a b K ε : ℝ)
    (hg : ∀ x y, |g x - g y| ≤ K * |x - y|)
    (hgap : K * |a - b| + 2 * ε < |f a - f b|) :
    ¬ (|f a - g a| ≤ ε ∧ |f b - g b| ≤ ε) := by
  exact fun h => hgap.not_ge <| twoPoint_gap_le f g a b K ε hg h.1 h.2

-- !-- Apply `no_lipschitz_approx_of_gap` with a=0, b=(1/2)^k; here |f a - f b| = 1,
--     |a-b| = (1/2)^k, using tent_iterate_zero and tent_iterate_peak. -- !--
/-- **Tent separation as an instance of the abstract lemma.** Re-derivation of
`relu_depth_separation` (slope-blowup face): the witnessing pair is
`a = 0`, `b = (1/2)^k`, where `tent^[k]` jumps from `0` to `1`. -/
theorem tent_depth_separation_via_gap (k : ℕ) (g : ℝ → ℝ) (K ε : ℝ)
    (hg : ∀ x y, |g x - g y| ≤ K * |x - y|)
    (hKε : K * (1 / 2 : ℝ) ^ k + 2 * ε < 1) :
    ¬ (∀ x ∈ Icc (0 : ℝ) 1, |tent^[k] x - g x| ≤ ε) := by
  contrapose! hKε
  convert twoPoint_gap_le ( tent^[k] ) g 0 ( ( 1 / 2 ) ^ k ) K ε hg
      ( hKε 0 ⟨ by norm_num, by norm_num ⟩ )
      ( hKε ( ( 1 / 2 ) ^ k ) ⟨ by positivity, by exact pow_le_one₀ ( by norm_num ) ( by norm_num ) ⟩ )
      using 1 ; norm_num [ tent_iterate_zero, tent_iterate_peak ]
  norm_num [ abs_of_nonpos ]

-- !-- `iterExp_strictMono` applied to `0 < 1`. -- !--
/-- The exponential tower has a strictly positive endpoint gap on `[0,1]`:
`iterExp k 0 < iterExp k 1`. This is the *range-blowup* witness. -/
theorem iterExp_endpoint_gap_pos (k : ℕ) :
    iterExp k 0 < iterExp k 1 := by
  exact iterExp_strictMono k ( by norm_num )

-- !-- Apply `no_lipschitz_approx_of_gap` with a=0, b=1; |a-b| = 1 and
--     |iterExp k 0 - iterExp k 1| = G by `iterExp_endpoint_gap_pos`. -- !--
/-- **Exponential-tower separation as an instance of the same abstract lemma.**
(range-blowup face): the witnessing pair is `a = 0`, `b = 1`, where `iterExp k`
spans its full endpoint gap `G = iterExp k 1 - iterExp k 0`. Any `K`-Lipschitz
`g` with `K + 2ε < G` fails to approximate `iterExp k` on `[0,1]`. -/
theorem iterExp_depth_separation (k : ℕ) (g : ℝ → ℝ) (K ε : ℝ)
    (hg : ∀ x y, |g x - g y| ≤ K * |x - y|)
    (hKε : K + 2 * ε < iterExp k 1 - iterExp k 0) :
    ¬ (∀ x ∈ Icc (0 : ℝ) 1, |iterExp k x - g x| ≤ ε) := by
  contrapose! hKε
  have := twoPoint_gap_le ( fun x => iterExp k x ) g 0 1 K ε hg
      ( by simpa using hKε 0 ⟨ by norm_num, by norm_num ⟩ )
      ( by simpa using hKε 1 ⟨ by norm_num, by norm_num ⟩ ) ; simp_all +decide [ abs_sub_comm ]
  linarith [ abs_le.mp this ]

-- !-- K·(1/2)^k < 2^k·(1/2)^k = 1 bounds the Lipschitz gap of g strictly below the
--     true label gap 1 (= |tent^[k] 0 - tent^[k] (2^{-k})|). -- !--
/-- **Adversarial / robustness reading of the slope blow-up.** Any classifier
`g` whose Lipschitz constant `K` is strictly below `2^k` admits a
`2^{-k}`-separated *adversarial pair* `0` and `(1/2)^k` on which the deep tent's
true outputs differ maximally (`tent^[k] 0 = 0`, `tent^[k] (2^{-k}) = 1`) while
`g` cannot separate them by `1`: `|g 0 - g (2^{-k})| < 1`. Thus the very slope
that defeats shallow approximation also certifies depth-induced fragility. -/
theorem tent_adversarial (k : ℕ) (g : ℝ → ℝ) (K : ℝ)
    (hg : ∀ x y, |g x - g y| ≤ K * |x - y|)
    (hK : K < 2 ^ k) :
    |g 0 - g ((1 / 2 : ℝ) ^ k)| < |tent^[k] 0 - tent^[k] ((1 / 2 : ℝ) ^ k)| := by
  refine' lt_of_le_of_lt ( hg 0 _ ) _
  norm_num [ abs_of_pos, tent_iterate_zero, tent_iterate_peak ]
  have hp : (0 : ℝ) < (1 / 2) ^ k := by positivity
  have hone : (2 : ℝ) ^ k * (1 / 2) ^ k = 1 := by rw [← mul_pow]; norm_num
  nlinarith [ mul_lt_mul_of_pos_right hK hp ]

end ReLUDepthWidth

end