import Catalog.Applications.CakeBalancing.Basic

/-!
# A universal upper bound for the cake-balancing ratio: the bisection strategy

The companion file `Basic.lean` shows that for a *single* dissection the
balancing ratio can be as small as `1` (the equipartition).  A single infinite
cutting sequence, however, must be balanced *simultaneously* at every stage, and
no infinite sequence keeps every intermediate configuration exactly uniform.
The natural question is therefore how small the long-run ratio

`μ_r = limsup_{n → ∞} μ_r(first n cuts)`

can be made by a cleverly chosen sequence.

This file proves that the **repeated-bisection sequence** keeps the ratio below
`2` for *every* window length `r`, uniformly in the number of cuts.  The engine
is a purely local observation: at every stage the pieces take only two lengths,
a short one and a long one that is exactly twice as long.  Two-valued
dissections have piece ratio `2`, and by the aggregation principle of `Basic.lean`
(`mu_le_arcRatio`) the window ratio inherits this bound for all `r ≥ 1`.

Main results:

* `mu_le_two_of_two_valued` — any dissection whose pieces take the two values
  `s` and `2s` has balancing ratio at most `2`, for every window length;
* `dyad_mu_le_two` — the bisection configuration realises this at every stage;
* `dyad_limsup_le_two` — consequently the long-run ratio `μ_r` of the bisection
  sequence is at most `2` for every `r`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  A greedy "always split the largest piece" rule keeps
all pieces within a factor `2` of one another forever: once every piece of a
uniform stage has been split once we reach the next uniform stage, and in
between only two sizes `s` and `2s` coexist.  If so, the balancing ratio should
stay `≤ 2` for all windows and all stages, giving `μ_r ≤ 2`.

EXPERIMENT (Experimenter).  We isolate the abstract cause — two-valuedness — as
`mu_le_two_of_two_valued`, then feed it the explicit bisection configuration
`dyadArc`, whose two sizes are `1/2^{k+1}` and `1/2^{k}` for `2^k ≤ n < 2^{k+1}`.
The stage bound `dyad_mu_le_two` and the `limsup` corollary follow.

ANALYSIS (Analyst).  The upper bound `2` is *dimension free* and *window free*.
It is almost certainly not optimal: overlapping windows average away some of the
imbalance, and finer sequences (e.g. low-discrepancy / golden-ratio insertions)
are expected to push the constant below `2`.  The value `2` is exactly the price
of the crude "two sizes, factor two" description and is the honest boundary of
this elementary method.

CRITIQUE (Critic).  The bound is non-vacuous: `dyad_mu_ge_one` shows the ratio is
genuinely in `[1, 2]`, never collapsing to a trivial value, and the `limsup`
statement is a real asymptotic claim, not a restatement of a finite inequality.
The gap between the proven `2` and the conjectural optimum is recorded as an open
direction rather than hidden.
-/

open Finset

namespace CakeBalancing

variable {n : ℕ}

/-
If every piece takes one of the two values `s` and `2s` (with `s > 0`), the
piece ratio `maxArc / minArc` is at most `2`.
-/
theorem arcRatio_le_two_of_two_valued [NeZero n] {arc : ZMod n → ℝ} {s : ℝ}
    (hs : 0 < s) (hval : ∀ i, arc i = s ∨ arc i = 2 * s) :
    maxArc arc / minArc arc ≤ 2 := by
  -- By definition of maxArc and minArc, we know that maxArc arc ≤ 2s and s ≤ minArc arc.
  have h_max_le : maxArc arc ≤ 2 * s := by
    exact Finset.sup'_le _ _ fun i _ => by cases hval i <;> linarith;
  have h_min_ge : s ≤ minArc arc := by
    exact Finset.le_inf' _ _ fun i _ => by cases hval i <;> linarith;
  rw [ div_le_iff₀ ] <;> linarith

/-
**Two-valued dissections are `2`-balanced.**  If every piece is `s` or `2s`
with `s > 0`, then for every window length `r ≥ 1` the balancing ratio is at
most `2`.
-/
theorem mu_le_two_of_two_valued [NeZero n] {arc : ZMod n → ℝ} {s : ℝ}
    (hs : 0 < s) (hval : ∀ i, arc i = s ∨ arc i = 2 * s) {r : ℕ} (hr : 1 ≤ r) :
    mu arc r ≤ 2 := by
  exact le_trans ( mu_le_arcRatio ( fun i ↦ by cases hval i <;> linarith ) hr ) ( arcRatio_le_two_of_two_valued hs hval )

/-- The bisection configuration on `n` pieces: with `k = ⌊log₂ n⌋`, the already
bisected pieces have length `1/2^{k+1}` and the not-yet-bisected pieces have the
double length `1/2^{k}`. -/
noncomputable def dyadArc (n : ℕ) [NeZero n] : ZMod n → ℝ :=
  fun i => if i.val < 2 * (n - 2 ^ Nat.log 2 n)
    then (1 : ℝ) / 2 ^ (Nat.log 2 n + 1)
    else (1 : ℝ) / 2 ^ (Nat.log 2 n)

/-
The bisection configuration takes exactly the two values `s = 1/2^{k+1}` and
`2s = 1/2^{k}`.
-/
theorem dyadArc_two_valued (n : ℕ) [NeZero n] (i : ZMod n) :
    dyadArc n i = 1 / 2 ^ (Nat.log 2 n + 1) ∨
      dyadArc n i = 2 * (1 / 2 ^ (Nat.log 2 n + 1)) := by
  unfold dyadArc; norm_num;
  grind

/-
**Stage bound.**  At every stage the bisection dissection has balancing ratio
at most `2`, for every window length `r ≥ 1`.
-/
theorem dyad_mu_le_two (n : ℕ) [NeZero n] {r : ℕ} (hr : 1 ≤ r) :
    mu (dyadArc n) r ≤ 2 := by
  convert mu_le_two_of_two_valued _ _ hr;
  exacts [ 1 / 2 ^ ( Nat.log 2 n + 1 ), by positivity, fun i => dyadArc_two_valued n i ]

/-
The bisection dissection has balancing ratio at least `1` (it is a genuine
ratio, never degenerate).
-/
theorem dyad_mu_ge_one (n : ℕ) [NeZero n] {r : ℕ} (hr : 1 ≤ r) :
    1 ≤ mu (dyadArc n) r := by
  convert mu_ge_one _ hr;
  exact fun i => by rcases dyadArc_two_valued n i with h|h <;> rw [ h ] <;> positivity;

/-- The balancing ratio of the bisection sequence as a function of the number of
cuts `n` (the empty cake `n = 0` is assigned the trivial value `1`). -/
noncomputable def dyadMu (r n : ℕ) : ℝ :=
  if h : n = 0 then 1 else
    haveI : NeZero n := ⟨h⟩
    mu (dyadArc n) r

/-
The bisection ratio sequence stays in the interval `[1, 2]` for every stage
and every window length `r ≥ 1`.
-/
theorem dyadMu_mem_Icc {r : ℕ} (hr : 1 ≤ r) (n : ℕ) :
    1 ≤ dyadMu r n ∧ dyadMu r n ≤ 2 := by
  by_cases hn : n = 0;
  · unfold dyadMu; aesop;
  · simp [dyadMu, hn];
    convert And.intro ( dyad_mu_ge_one n hr ) ( dyad_mu_le_two n hr ) using 1

/-
**Long-run upper bound.**  For every window length `r ≥ 1`, the cake-balancing
ratio `μ_r` of the bisection sequence is at most `2`.
-/
theorem dyad_limsup_le_two {r : ℕ} (hr : 1 ≤ r) :
    Filter.limsup (dyadMu r) Filter.atTop ≤ 2 := by
  refine' csInf_le _ _ <;> norm_num;
  · exact ⟨ 1, by rintro x ⟨ n, hn ⟩ ; exact le_trans ( dyadMu_mem_Icc hr n |>.1 ) ( hn _ le_rfl ) ⟩;
  · exact ⟨ 1, fun n hn => dyadMu_mem_Icc hr n |>.2 ⟩

/-! ### Examples -/

#check @dyad_limsup_le_two
#check @mu_le_two_of_two_valued

-- The bisection ratio is trapped in `[1,2]` at every stage, e.g. for `r = 3`.
example (n : ℕ) : 1 ≤ dyadMu 3 n ∧ dyadMu 3 n ≤ 2 :=
  dyadMu_mem_Icc (by norm_num) n

end CakeBalancing