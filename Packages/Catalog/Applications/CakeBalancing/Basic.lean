import Mathlib

/-!
# The cake-balancing ratio functional

Consider a circular cake whose boundary carries finitely many cut points.  When
`n` cuts are present they divide the circle into `n` arcs (the *pieces*).  Fix a
window length `r ≥ 1`.  For each starting position `i` the sum of the `r`
consecutive pieces `i, i+1, …, i+r-1` (indices read cyclically) is a *window
weight*.  The **balancing ratio**

`μ_r = (largest window weight) / (smallest window weight)`

measures how far the current dissection is from perfectly balancing every block
of `r` consecutive pieces.  A dissection is perfectly balanced for windows of
length `r` exactly when `μ_r = 1`.

This file develops the exact, dimension-free algebra of this functional for a
single dissection.  A circular dissection into `n` pieces is modelled by a
positive weight function `arc : ZMod n → ℝ`, the cyclic group `ZMod n`
supplying the wrap-around index arithmetic for free.

The headline structural results are:

* `mu_ge_one` — the ratio is always at least `1`;
* `mu_le_arcRatio` / `mu_le_mu_one` — **aggregation never increases imbalance**:
  the window ratio for any `r ≥ 1` is bounded by the ratio of the single largest
  to the single smallest piece;
* `mu_smul` — the ratio is scale invariant, so the circumference is irrelevant;
* `mu_equipartition` — an equipartition realises the optimal value `1`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Grouping consecutive pieces should *average out*
local fluctuations, so the imbalance seen through a window of length `r` can
never exceed the raw piece-to-piece imbalance `μ_1 = maxArc / minArc`.  We
conjectured the sharp comparison `μ_r ≤ μ_1` for every `r ≥ 1`, together with
scale invariance and attainment of `1` at the equipartition.

EXPERIMENT (Experimenter).  Each window weight is a sum of `r` pieces, hence
sandwiched between `r · minArc` and `r · maxArc`.  Passing to the extremal
windows and cancelling the common factor `r` yields `μ_r ≤ maxArc / minArc`, and
`μ_1 = maxArc / minArc` because a length-one window is a single piece.

ANALYSIS (Analyst).  The factor `r` cancels *exactly*; the comparison is not an
asymptotic estimate but an identity-driven inequality valid for every finite
dissection.  Positivity of the pieces is the only hypothesis that does real
work (it keeps the denominator away from `0`).

CRITIQUE (Critic).  The results are non-vacuous: the equipartition witnesses
equality in `mu_ge_one`, and two-valued dissections (see the companion file)
witness strict inequality, so neither bound is degenerate.  The boundary case
`r = 0` (empty window) is excluded exactly as the informal statement demands
`r ≥ 1`.
-/

open Finset

namespace CakeBalancing

variable {n : ℕ}

/-- The weight of the window of `r` consecutive pieces starting at cut `i`,
indices read cyclically. -/
noncomputable def windowSum [NeZero n] (arc : ZMod n → ℝ) (r : ℕ) (i : ZMod n) : ℝ :=
  ∑ j ∈ Finset.range r, arc (i + (j : ZMod n))

/-- The largest window weight. -/
noncomputable def maxWindow [NeZero n] (arc : ZMod n → ℝ) (r : ℕ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (windowSum arc r)

/-- The smallest window weight. -/
noncomputable def minWindow [NeZero n] (arc : ZMod n → ℝ) (r : ℕ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty (windowSum arc r)

/-- The largest single piece. -/
noncomputable def maxArc [NeZero n] (arc : ZMod n → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty arc

/-- The smallest single piece. -/
noncomputable def minArc [NeZero n] (arc : ZMod n → ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty arc

/-- The cake-balancing ratio for windows of length `r`. -/
noncomputable def mu [NeZero n] (arc : ZMod n → ℝ) (r : ℕ) : ℝ :=
  maxWindow arc r / minWindow arc r

/--
A length-one window is a single piece.
-/
theorem windowSum_one [NeZero n] (arc : ZMod n → ℝ) (i : ZMod n) :
    windowSum arc 1 i = arc i := by
  unfold windowSum; norm_num;

/--
Every window weight is positive when all pieces are positive and `r ≥ 1`.
-/
theorem windowSum_pos [NeZero n] {arc : ZMod n → ℝ} (hpos : ∀ i, 0 < arc i)
    {r : ℕ} (hr : 1 ≤ r) (i : ZMod n) : 0 < windowSum arc r i := by
  exact Finset.sum_pos ( fun _ _ => hpos _ ) ( by aesop )

/--
The smallest piece is positive when all pieces are.
-/
theorem minArc_pos [NeZero n] {arc : ZMod n → ℝ} (hpos : ∀ i, 0 < arc i) :
    0 < minArc arc := by
  unfold minArc;
  simp +zetaDelta at *;
  assumption

/--
The smallest window weight is positive.
-/
theorem minWindow_pos [NeZero n] {arc : ZMod n → ℝ} (hpos : ∀ i, 0 < arc i)
    {r : ℕ} (hr : 1 ≤ r) : 0 < minWindow arc r := by
  -- Apply the definition of `minWindow` and use the fact that every windowSum is positive.
  unfold minWindow
  have h_pos : ∀ i : ZMod n, 0 < windowSum arc r i := fun i => windowSum_pos hpos hr i
  simp [h_pos]

/--
The smallest window weight never exceeds the largest.
-/
theorem minWindow_le_maxWindow [NeZero n] (arc : ZMod n → ℝ) (r : ℕ) :
    minWindow arc r ≤ maxWindow arc r := by
  exact Finset.inf'_le _ ( Finset.mem_univ 0 ) |> le_trans <| Finset.le_sup' _ ( Finset.mem_univ 0 )

/--
Upper bound: the largest window weight is at most `r` times the largest piece.
-/
theorem maxWindow_le [NeZero n] (arc : ZMod n → ℝ) (r : ℕ) :
    maxWindow arc r ≤ r * maxArc arc := by
  refine' Finset.sup'_le _ _ _;
  exact fun i _ => le_trans ( Finset.sum_le_sum fun _ _ => show arc _ ≤ maxArc arc from Finset.le_sup' _ <| Finset.mem_univ _ ) <| by simp +decide [ mul_comm ] ;

/--
Lower bound: the smallest window weight is at least `r` times the smallest piece.
-/
theorem minWindow_ge [NeZero n] (arc : ZMod n → ℝ) (r : ℕ) :
    (r : ℝ) * minArc arc ≤ minWindow arc r := by
  -- By the properties of window sums and infimums, we have:
  have h_inf_le : minWindow arc r ≥ Finset.inf' (Finset.univ : Finset (ZMod n)) (Finset.univ_nonempty) (fun i => ∑ j ∈ Finset.range r, arc (i + j)) := by
    rfl;
  refine' le_trans _ h_inf_le;
  simp +decide;
  exact fun i => le_trans ( by simp +decide [ mul_comm ] ) ( Finset.sum_le_sum fun _ _ => show arc _ ≥ minArc arc from Finset.inf'_le _ <| Finset.mem_univ _ )

/--
The balancing ratio is always at least `1`.
-/
theorem mu_ge_one [NeZero n] {arc : ZMod n → ℝ} (hpos : ∀ i, 0 < arc i)
    {r : ℕ} (hr : 1 ≤ r) : 1 ≤ mu arc r := by
  exact one_le_div ( minWindow_pos hpos hr ) |>.2 ( minWindow_le_maxWindow arc r )

/--
**Aggregation never increases imbalance**: the window ratio is bounded by the
ratio of the largest to the smallest single piece.
-/
theorem mu_le_arcRatio [NeZero n] {arc : ZMod n → ℝ} (hpos : ∀ i, 0 < arc i)
    {r : ℕ} (hr : 1 ≤ r) : mu arc r ≤ maxArc arc / minArc arc := by
  refine' ( div_le_div_iff₀ _ _ ).mpr _;
  · exact minWindow_pos hpos hr;
  · exact minArc_pos hpos;
  · refine' le_trans _ ( mul_le_mul_of_nonneg_left ( minWindow_ge arc r ) ( show 0 ≤ maxArc arc from Finset.le_sup' ( f := arc ) ( Finset.mem_univ 0 ) |> le_trans ( le_of_lt ( hpos 0 ) ) ) );
    convert mul_le_mul_of_nonneg_right ( maxWindow_le arc r ) ( show 0 ≤ minArc arc from Finset.le_inf' _ _ fun x _ => le_of_lt ( hpos x ) ) using 1 ; ring

/--
The length-one ratio is exactly the piece-to-piece ratio.
-/
theorem mu_one_eq_arcRatio [NeZero n] (arc : ZMod n → ℝ) :
    mu arc 1 = maxArc arc / minArc arc := by
  unfold mu maxArc minArc;
  congr! 1;
  · unfold maxWindow;
    unfold windowSum; aesop;
  · unfold minWindow;
    unfold windowSum; aesop;

/--
**Monotone comparison to single pieces**: for every window length `r ≥ 1`,
the balancing ratio is at most the length-one ratio.
-/
theorem mu_le_mu_one [NeZero n] {arc : ZMod n → ℝ} (hpos : ∀ i, 0 < arc i)
    {r : ℕ} (hr : 1 ≤ r) : mu arc r ≤ mu arc 1 := by
  convert mu_le_arcRatio hpos hr using 1;
  exact mu_one_eq_arcRatio arc

/--
**Scale invariance**: rescaling every piece by a positive constant (e.g.
changing the circumference) leaves the balancing ratio unchanged.
-/
theorem mu_smul [NeZero n] (arc : ZMod n → ℝ) {c : ℝ} (hc : 0 < c) (r : ℕ) :
    mu (fun i => c * arc i) r = mu arc r := by
  unfold mu;
  unfold maxWindow minWindow;
  unfold windowSum;
  simp only [← Finset.mul_sum] ;
  rw [ show ( Finset.univ.sup' _ fun x => c * ∑ i ∈ Finset.range r, arc ( x + i ) ) = c * ( Finset.univ.sup' _ fun x => ∑ i ∈ Finset.range r, arc ( x + i ) ) from ?_, show ( Finset.univ.inf' _ fun x => c * ∑ i ∈ Finset.range r, arc ( x + i ) ) = c * ( Finset.univ.inf' _ fun x => ∑ i ∈ Finset.range r, arc ( x + i ) ) from ?_ ];
  any_goals exact Finset.univ_nonempty;
  · rw [ mul_div_mul_left _ _ hc.ne' ];
  · refine' le_antisymm _ _ <;> simp +decide;
    · have := Finset.exists_min_image Finset.univ ( fun x => ∑ i ∈ Finset.range r, arc ( x + i ) ) ⟨ 0, Finset.mem_univ 0 ⟩ ; aesop;
    · exact fun x => mul_le_mul_of_nonneg_left ( Finset.inf'_le _ <| Finset.mem_univ _ ) hc.le;
  · refine' le_antisymm _ _ <;> simp +decide [ Finset.sup'_le_iff, Finset.le_sup'_iff ];
    · exact fun x => mul_le_mul_of_nonneg_left ( Finset.le_sup' ( fun x => ∑ i ∈ Finset.range r, arc ( x + i ) ) ( Finset.mem_univ x ) ) hc.le;
    · have := Finset.exists_max_image Finset.univ ( fun x => ∑ i ∈ Finset.range r, arc ( x + i ) ) ⟨ 0, Finset.mem_univ 0 ⟩ ; aesop;

/--
**Equipartition is optimal**: a constant dissection achieves the minimal
possible ratio `1`.
-/
theorem mu_equipartition [NeZero n] {c : ℝ} (hc : 0 < c) {r : ℕ} (hr : 1 ≤ r) :
    mu (fun _ : ZMod n => c) r = 1 := by
  unfold mu; norm_num [ maxWindow, minWindow, windowSum ] ;
  aesop

/-! ### Examples -/

-- The functionals are well defined for every window length.
#check @mu
#check @mu_le_mu_one

-- A concrete `4`-piece equipartition of a circumference-`1` cake has ratio `1`.
example : mu (fun _ : ZMod 4 => (1 : ℝ) / 4) 2 = 1 :=
  mu_equipartition (by norm_num) (by norm_num)

end CakeBalancing