import Mathlib

/-!
# The attention-budget increment law (NET-67, discrete layer)

NET-67 measures, for two transformers of different parameter scale, the *knee*
of the top-`k` attention-retention curve: the smallest number `k` of retained
keys at which a drift-assert on the generated continuation still passes.
The measured grid (contexts `512, 1024, 2048`, i.e. `j = 0, 1, 2` doublings
above the base context) is

| model    | j = 0 | j = 1 | j = 2 |
|----------|-------|-------|-------|
| 0.5B     | 16    | 20    | 24    |
| 1.5B     | 16    | 16    | 18    |

and the verdict extracted from it is **SCALE-HALVES-THE-CONTEXT-INCREMENT**:
both curves start at `16`, the small model gains `+4` keys per context doubling,
the large model `+2`.

This file is the *discrete* layer of the formalisation.  It fixes the two
closed forms

* `kneeSmall j = 16 + 4 * j`  (exactly affine),
* `kneeLarge j = max 16 (14 + 2 * j)`  (a hinge: flat, then slope `2`),

proves that they reproduce the measured grid, and then audits the verdict.
Three of the results are *corrections* of the informal claim:

* `kneeLarge_not_affine` — the large-model curve is **not** of the form
  `k₀ + d * j` on the measured window at all: its increments are `0` then `+2`.
  So "slope 2" can only mean the *terminal* increment, never a global slope.
* `halving_is_terminal_not_average` — for the terminal increment the halving
  `4 ↦ 2` is correct, but the *average* increment over the measured window is
  `4 ↦ 1`: a quartering.  The two readings of the verdict genuinely disagree.
* `twenty_key_budget_does_not_cover_both` and `least_budget_at_2048` — the
  deployment corollary "a 20-key budget covers both models to 2048" is false;
  the least uniform budget at 2048 is `24`.

Finally the two laws are shown to *diverge* (`gap_unbounded`) with budget ratio
tending to `2` (`ratio_tendsto_two`): no fixed key budget survives unbounded
context, and asymptotically the small model needs exactly twice the keys.
-/

namespace Catalog.Novelty.AttentionBudgetIncrement

open Filter Topology

/-! ### 1. The two measured laws -/

/-- Attention-budget knee of the small (0.5B) model after `j` context doublings
above the base context `512`.  Measured: `16, 20, 24`. -/
def kneeSmall (j : ℕ) : ℕ := 16 + 4 * j

/-- Attention-budget knee of the large (1.5B) model after `j` context doublings.
Measured: `16, 16, 18` — a hinge, flat at the base level and then rising with
slope `2`. -/
def kneeLarge (j : ℕ) : ℕ := max 16 (14 + 2 * j)

@[simp] theorem kneeSmall_zero : kneeSmall 0 = 16 := rfl
@[simp] theorem kneeLarge_zero : kneeLarge 0 = 16 := rfl

/-- The small-model curve reproduces the measured triple `{16, 20, 24}`. -/
theorem kneeSmall_data : (kneeSmall 0, kneeSmall 1, kneeSmall 2) = (16, 20, 24) := by
  decide

/-- The large-model curve reproduces the measured triple `{16, 16, 18}`
(the NET-67 addendum: `k = 14` fails, `k = 18` passes at `ctx = 2048`). -/
theorem kneeLarge_data : (kneeLarge 0, kneeLarge 1, kneeLarge 2) = (16, 16, 18) := by
  decide

/-! ### 2. Increments -/

/-- The small model gains exactly `4` keys per context doubling, everywhere. -/
theorem kneeSmall_increment (j : ℕ) : kneeSmall (j + 1) = kneeSmall j + 4 := by
  simp only [kneeSmall]; ring

/-- Past the hinge the large model gains exactly `2` keys per doubling. -/
theorem kneeLarge_increment (j : ℕ) (hj : 1 ≤ j) : kneeLarge (j + 1) = kneeLarge j + 2 := by
  simp only [kneeLarge]; omega

/-- At the hinge the large model gains nothing: the first measured increment is `0`. -/
theorem kneeLarge_first_increment : kneeLarge 1 = kneeLarge 0 := by decide

/-- **Rigidity of an affine law.**  A budget law with constant increment is
determined by its value at `0` and its increment, and conversely two agreeing
values at `0` and `1` force agreement everywhere. -/
theorem affine_rigidity {f : ℕ → ℕ} {d : ℕ} (hd : ∀ j, f (j + 1) = f j + d) (j : ℕ) :
    f j = f 0 + d * j := by
  induction j with
  | zero => simp
  | succ n ih => rw [hd n, ih]; ring

/-- **The large-model curve is not affine on the measured window.**  No
`k₀ + d * j` reproduces `16, 16, 18`; the increment `0` at the hinge and the
increment `2` afterwards are incompatible.  Hence "slope `2`" is a statement
about the terminal increment only. -/
theorem kneeLarge_not_affine : ¬ ∃ k₀ d : ℕ, ∀ j ≤ 2, kneeLarge j = k₀ + d * j := by
  rintro ⟨k₀, d, h⟩
  have h0 := h 0 (by norm_num)
  have h1 := h 1 (by norm_num)
  have h2 := h 2 (by norm_num)
  simp only [kneeLarge] at h0 h1 h2
  omega

/-- The small-model curve, by contrast, *is* affine, with the measured
increment `4`. -/
theorem kneeSmall_affine : ∀ j, kneeSmall j = kneeSmall 0 + 4 * j :=
  affine_rigidity kneeSmall_increment

/-- **Discrete convexity of the large-model curve.**  Its increments are
non-decreasing, which is what makes the hinge (rather than a straight line) the
right shape for the measured triple. -/
theorem kneeLarge_convex (j : ℕ) : 2 * kneeLarge (j + 1) ≤ kneeLarge j + kneeLarge (j + 2) := by
  simp only [kneeLarge]; omega

/-- **The halving is terminal, not average.**  Reading the verdict off the last
measured increment gives the advertised halving `4 ↦ 2`; reading it off the
average increment over the whole measured window gives `4 ↦ 1`, a quartering.
Both facts are proved here, together with their disagreement. -/
theorem halving_is_terminal_not_average :
    -- terminal increments: 4 and 2, exactly a halving
    (kneeSmall 2 - kneeSmall 1 = 4 ∧ kneeLarge 2 - kneeLarge 1 = 2) ∧
    -- window-average increments (times 2, to stay in ℕ): 4 and 1, a quartering
    (kneeSmall 2 - kneeSmall 0 = 2 * 4 ∧ kneeLarge 2 - kneeLarge 0 = 2 * 1) ∧
    -- and the two readings really differ
    2 * (kneeLarge 2 - kneeLarge 1) ≠ kneeLarge 2 - kneeLarge 0 := by
  refine ⟨⟨by decide, by decide⟩, ⟨by decide, by decide⟩, by decide⟩

/-! ### 3. Deployment: uniform key budgets -/

/-- A budget `B` is *safe at horizon* `j` if it covers the knee of both models
after `j` context doublings. -/
def SafeAt (B j : ℕ) : Prop := kneeSmall j ≤ B ∧ kneeLarge j ≤ B

/-- The `20`-key budget covers the large model at `2048` with margin `2` … -/
theorem twenty_covers_large : kneeLarge 2 + 2 ≤ 20 := by decide

/-- … but **not** the small model: the NET-67 deployment corollary is false as
stated. -/
theorem twenty_key_budget_does_not_cover_both : ¬ SafeAt 20 2 := by
  rintro ⟨h, -⟩
  simp only [kneeSmall] at h
  omega

/-- **The corrected deployment constant at 2048.**  `24` is the least budget
that covers both models at `ctx = 2048`. -/
theorem least_budget_at_2048 : IsLeast {B | SafeAt B 2} 24 := by
  constructor
  · exact ⟨by decide, by decide⟩
  · rintro B ⟨h, -⟩
    simpa [kneeSmall] using h

/-- **The corrected deployment constant at any horizon.**  For every horizon
`J`, the least budget safe at all context doublings `j ≤ J` is `16 + 4 * J`,
i.e. it is dictated entirely by the *small* model. -/
theorem least_budget_horizon (J : ℕ) :
    IsLeast {B | ∀ j ≤ J, SafeAt B j} (16 + 4 * J) := by
  constructor
  · intro j hj
    constructor
    · simp only [kneeSmall]; omega
    · simp only [kneeLarge]; omega
  · intro B hB
    have := (hB J le_rfl).1
    simpa [kneeSmall] using this

/-! ### 4. Divergence of the two laws -/

/-- Past the hinge the large-model law is the affine function `14 + 2 * j`. -/
theorem kneeLarge_eq (j : ℕ) (hj : 1 ≤ j) : kneeLarge j = 14 + 2 * j := by
  simp only [kneeLarge]; omega

/-- Past the hinge the gap between the two budgets is exactly `2 * j + 2`. -/
theorem gap_eq (j : ℕ) (hj : 1 ≤ j) : kneeSmall j - kneeLarge j = 2 * j + 2 := by
  rw [kneeLarge_eq j hj]; simp only [kneeSmall]; omega

/-- **No finite budget is universally safe.**  Because the increments differ,
the key gap between the models grows without bound. -/
theorem gap_unbounded (B : ℕ) : ∃ j, B < kneeSmall j - kneeLarge j := by
  refine ⟨B + 2, ?_⟩
  rw [kneeLarge_eq _ (by omega)]
  simp only [kneeSmall]; omega

/-- **Asymptotic budget ratio.**  The small model's budget is asymptotically
exactly twice the large model's: the halving of the increment shows up in the
limit as a factor `2`, even though at the measured horizon `j = 2` the ratio is
only `24/18 = 4/3`. -/
theorem ratio_tendsto_two :
    Tendsto (fun j : ℕ => (kneeSmall j : ℝ) / (kneeLarge j : ℝ)) atTop (𝓝 2) := by
  have hev : (fun j : ℕ => (kneeSmall j : ℝ) / (kneeLarge j : ℝ))
      =ᶠ[atTop] (fun j : ℕ => 2 - 12 / (14 + 2 * (j : ℝ))) := by
    filter_upwards [eventually_ge_atTop 1] with j hj
    have hj0 : (0 : ℝ) ≤ (j : ℝ) := Nat.cast_nonneg j
    have hden : (14 : ℝ) + 2 * (j : ℝ) ≠ 0 := by positivity
    rw [kneeLarge_eq j hj]
    simp only [kneeSmall, Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat]
    field_simp
    ring
  refine Tendsto.congr' hev.symm ?_
  have hbig : Tendsto (fun j : ℕ => (14 : ℝ) + 2 * (j : ℝ)) atTop atTop := by
    apply Filter.tendsto_atTop_add_const_left
    exact tendsto_natCast_atTop_atTop.const_mul_atTop (by norm_num)
  have h0 : Tendsto (fun j : ℕ => (12 : ℝ) / (14 + 2 * (j : ℝ))) atTop (𝓝 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds hbig
  simpa using (tendsto_const_nhds (x := (2 : ℝ))).sub h0

end Catalog.Novelty.AttentionBudgetIncrement