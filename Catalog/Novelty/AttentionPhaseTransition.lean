import Novelty.AttentionScaleThreshold

/-!
# The increment accelerates at 4096: a phase transition in the attention budget (NET-78)

NET-78 extends the 0.5B knee chain of NET-67 by one context octave.  Writing
`j` for the number of context doublings above the base context `512`
(so `j = 0,1,2,3` is `ctx = 512, 1024, 2048, 4096`), the measured knees are

| j        | 0  | 1  | 2  | 3  |
|----------|----|----|----|----|
| `k*`     | 16 | 20 | 24 | 40 |

with increments `+4, +4, +16`.  The verdict extracted from the run is
**THE-INCREMENT-ACCELERATES-AT-4096**: the affine law `16 + 4j` of cycle 1
(`Novelty.AttentionBudgetIncrement`) breaks at the fourth doubling.

This file is the formal audit of that verdict.  It has four layers.

**1. Discrete layer.**  `kneeSmall_refuted` and `no_affine_fits` prove the two
refutations exactly (`P1`: the `+4` law does not continue; `P2`: no saturation).
But the four data points are far from determining the continuation:
`kneeRamp`, `kneeCubic` and `kneeQuad` all reproduce `16, 20, 24, 40` and
predict `56`, `80`, `92` at `ctx = 8192` (`fits_underdetermined`).  What *is*
forced, under the (measured) discrete convexity of the chain, is a sharp lower
bound: `convex_growth` gives `f (m+3) ≥ 40 + 16m`, hence at least `56` keys at
`8192` and no finite universally safe budget (`no_uniform_budget`).

**2. Tropical layer.**  The minimal convex fit is a two-term max-plus
polynomial, `kneeRamp j = max (16 + 4j) (16j - 8)` (`kneeRamp_eq_max`), and its
tropical corner — the unique crossing of the two affine pieces — sits at
`j = 2`, i.e. at `ctx = 2048` (`transition_at_2048`).  So "budgets are stable
for the first ~2000 tokens, then sharply more expensive" is not a narrative
gloss: it is the location of the tropical root of the fitted budget law.

**3. Gate layer (barrier (c), confronted).**  The knee was read on the coarse
grid `{16,20,24,28,32,40}`, so the reported `40` is a grid point, not a
measurement.  `gate_bracket` recovers the gate `τ` from the table
(`0.979 < τ ≤ 0.984`), `true_knee_bracket` shows every profile consistent with
the table has its true knee in `[33, 40]`, and `bracket_sharp` exhibits two
explicit profiles realising both endpoints.  Consequently
`acceleration_bracketed`: the data force an increment in `[9, 16]`, i.e. an
acceleration factor in `[9/4, 4]`.  **The direction of the verdict is proved;
the advertised factor `4` is the top of a bracket whose bottom is `2.25`.**

**4. Continuous layer.**  Cycle 1 derived the `+4` law from a decay rate
degrading as `λ_j = λ₀/(j+1)`.  `lamAt_law_refuted` shows that family is now
strictly refuted: it is affine in `j`, and the chain is not.
`rate_collapse_accelerates` replaces it with a *model-free* consequence: for any
exponential-tail explanation of the chain, `λ_j = log(1/δ)/k_j`, so
`λ₃/λ₂ < λ₂/λ₁` — and `rate_collapse_accelerates_robust` proves this
**for every knee value in the grid bracket `[33,40]`**.  The phase transition
therefore survives the grid gap even though the factor `4` does not.  Finally
`calibration_phase` calibrates the crossover rate family `lamCross` against the
whole measured chain at the cycle-1 tail budget `δ = e⁻⁴`.

**Deployment.**  `cache24_fails_robust` proves the deployment corollary in its
grid-robust form: a 24-key cache fails at `ctx = 4096` for *every* profile
consistent with the table, and `provably_unsafe` / `certified_safe` delimit
exactly which budgets the measurement decides.
-/

namespace Catalog.Novelty.AttentionPhaseTransition

open Catalog.Novelty.AttentionBudgetIncrement Catalog.Novelty.AttentionRetentionKnee

/-! ### 1. The measured chain and the death of the affine law -/

/-- A budget law *fits the NET-78 chain* if it reproduces the four measured
knees `16, 20, 24, 40` at context doublings `j = 0,1,2,3`. -/
def Fits (f : ℕ → ℕ) : Prop := f 0 = 16 ∧ f 1 = 20 ∧ f 2 = 24 ∧ f 3 = 40

/-- **P1 refuted.**  The cycle-1 law `16 + 4j` predicts `28` at `ctx = 4096`,
so it does not fit the chain. -/
theorem kneeSmall_refuted : ¬ Fits kneeSmall := by
  rintro ⟨-, -, -, h⟩
  norm_num [kneeSmall] at h

/-- **P2 refuted.**  Every fit of the chain exceeds the `ctx = 2048` value: the
budget does not saturate. -/
theorem no_saturation {f : ℕ → ℕ} (hf : Fits f) : f 2 < f 3 := by
  rw [hf.2.2.1, hf.2.2.2]; norm_num

/-- **No affine law fits the chain.**  The increments `+4, +4, +16` are
incompatible with a constant increment. -/
theorem no_affine_fits : ¬ ∃ k₀ d : ℕ, Fits (fun j => k₀ + d * j) := by
  rintro ⟨k₀, d, h0, h1, h2, h3⟩
  simp only at h0 h1 h2 h3
  omega

/-! ### 2. Three continuations, all fitting the same four points -/

/-- **Ramp fit**: linear with a kink at `j = 2` (increment `+4` then `+16`). -/
def kneeRamp (j : ℕ) : ℕ := 16 + 4 * j + 12 * (j - 2)

/-- **Cubic fit**: the Newton interpolation polynomial through the four points,
`16 + 4·C(j,1) + 0·C(j,2) + 12·C(j,3)`. -/
def kneeCubic (j : ℕ) : ℕ := 16 + 4 * j + 12 * j.choose 3

/-- **Quartic-rate fit**: the increment itself multiplies by `4` at every
doubling past the transition. -/
def kneeQuad (j : ℕ) : ℕ := 16 + 4 * j + 4 * (4 ^ (j - 2) - 1)

theorem kneeRamp_fits : Fits kneeRamp := by
  refine ⟨rfl, rfl, rfl, rfl⟩

/-- The cycle-1 law is nevertheless correct on the three earlier octaves: it
agrees with the new fit below the transition, and the break happens exactly at
the fourth doubling. -/
theorem kneeSmall_correct_below : ∀ j ≤ 2, kneeSmall j = kneeRamp j := by
  intro j hj; simp only [kneeSmall, kneeRamp]; omega

theorem kneeCubic_fits : Fits kneeCubic := by
  refine ⟨rfl, rfl, ?_, ?_⟩ <;> decide

theorem kneeQuad_fits : Fits kneeQuad := by
  refine ⟨rfl, rfl, ?_, ?_⟩ <;> decide

/-- **The chain does not determine the next octave.**  Three laws agree on all
four measured points and predict `56`, `80` and `92` keys at `ctx = 8192`.
The `+16` increment is a measurement; its *continuation* is a choice. -/
theorem fits_underdetermined :
    Fits kneeRamp ∧ Fits kneeCubic ∧ Fits kneeQuad ∧
      (kneeRamp 4, kneeCubic 4, kneeQuad 4) = (56, 80, 92) := by
  refine ⟨kneeRamp_fits, kneeCubic_fits, kneeQuad_fits, ?_⟩
  decide

/-! ### 3. What convexity does force -/

/-- Discrete convexity: the per-doubling increments never decrease.  This is the
shape actually observed (`+4, +4, +16`) and the shape of every hinge law in
`Novelty.AttentionScaleThreshold`. -/
def ConvexLaw (f : ℕ → ℕ) : Prop := ∀ j, 2 * f (j + 1) ≤ f j + f (j + 2)

theorem kneeRamp_convex : ConvexLaw kneeRamp := by
  intro j; simp only [kneeRamp]; omega

theorem kneeQuad_convex : ConvexLaw kneeQuad := by
  intro j
  simp only [kneeQuad]
  rcases Nat.lt_or_ge j 2 with hj | hj
  · interval_cases j <;> norm_num
  · obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hj
    have e1 : 2 + m - 2 = m := by omega
    have e2 : 2 + m + 1 - 2 = m + 1 := by omega
    have e3 : 2 + m + 2 - 2 = m + 2 := by omega
    rw [e1, e2, e3]
    have hp : 1 ≤ 4 ^ m := Nat.one_le_pow _ _ (by norm_num)
    have h1 : (4 : ℕ) ^ (m + 1) = 4 * 4 ^ m := by ring
    have h2 : (4 : ℕ) ^ (m + 2) = 16 * 4 ^ m := by ring
    rw [h1, h2]; omega

/-- A convex law cannot lose an increment it has once achieved. -/
theorem convex_increment_persists {f : ℕ → ℕ} (hc : ConvexLaw f) {j c : ℕ}
    (h : f j + c ≤ f (j + 1)) : f (j + 1) + c ≤ f (j + 2) := by
  have := hc j; omega

/-- The `+16` increment measured at the transition propagates to every later
octave, for any convex fit. -/
theorem convex_step {f : ℕ → ℕ} (hc : ConvexLaw f) (hf : Fits f) :
    ∀ m, f (m + 2) + 16 ≤ f (m + 3) := by
  intro m
  induction m with
  | zero => rw [hf.2.2.1, hf.2.2.2]
  | succ n ih =>
      have h := convex_increment_persists (j := n + 2) hc ih
      have e1 : n + 2 + 1 = n + 1 + 2 := by omega
      have e2 : n + 2 + 2 = n + 1 + 3 := by omega
      rwa [e1, e2] at h

/-- **The forced lower bound.**  Every convex law fitting the chain needs at
least `40 + 16m` keys `m` octaves past `ctx = 4096`.  This is the part of the
verdict that the four data points really do imply. -/
theorem convex_growth {f : ℕ → ℕ} (hc : ConvexLaw f) (hf : Fits f) :
    ∀ m, 40 + 16 * m ≤ f (m + 3) := by
  intro m
  induction m with
  | zero => rw [hf.2.2.2]
  | succ n ih =>
      have h := convex_step hc hf (n + 1)
      have e1 : n + 1 + 2 = n + 3 := by omega
      have e2 : n + 1 + 3 = n + 1 + 3 := rfl
      rw [e1] at h
      omega

/-- At `ctx = 8192` a convex fit needs at least `56` keys, and the ramp fit
attains the bound: `56` is exactly the convex prediction. -/
theorem convex_prediction_8192 :
    (∀ f : ℕ → ℕ, ConvexLaw f → Fits f → 56 ≤ f 4) ∧ kneeRamp 4 = 56 := by
  refine ⟨fun f hc hf => ?_, rfl⟩
  have := convex_growth hc hf 1
  norm_num at this
  omega

/-- **No finite key budget survives unbounded context** once the transition has
happened: the requirement grows at least linearly with slope `16`. -/
theorem no_uniform_budget {f : ℕ → ℕ} (hc : ConvexLaw f) (hf : Fits f) (B : ℕ) :
    ∃ j, B < f j := by
  refine ⟨B + 3, ?_⟩
  have := convex_growth hc hf B
  omega

/-! ### 4. Tropical layer: the transition is a max-plus corner at ctx = 2048 -/

/-- **The minimal convex fit is a two-term tropical polynomial.**  The ramp law
is the max-plus sum of the pre-transition monomial `16 + 4j` and the
post-transition monomial `16j - 8`. -/
theorem kneeRamp_eq_max (j : ℕ) : kneeRamp j = max (16 + 4 * j) (16 * j - 8) := by
  simp only [kneeRamp]; omega

/-- **The tropical corner is at `j = 2`, i.e. at `ctx = 2048`.**  Over the reals
the two monomials of the fitted law cross at exactly one point, and that point
is the second context doubling — the informal "budgets are context-stable for
the first ~2000 tokens" is the location of the tropical root. -/
theorem transition_at_2048 :
    (∀ x : ℝ, 16 + 4 * x = 16 * x - 8 ↔ x = 2) ∧ (512 : ℕ) * 2 ^ 2 = 2048 := by
  refine ⟨fun x => ⟨fun h => by linarith, fun h => by rw [h]; norm_num⟩, by norm_num⟩

/-- Before the corner the first monomial dominates, after it the second: the two
regimes of the budget law are separated exactly at `j = 2`. -/
theorem tropical_regimes (j : ℕ) :
    (j ≤ 2 → kneeRamp j = 16 + 4 * j) ∧ (2 ≤ j → kneeRamp j = 16 * j - 8) := by
  constructor <;> intro hj <;> simp only [kneeRamp] <;> omega

/-! ### 5. Gate layer: the coarse grid and what it really proves -/

/-- The measured retention table at `ctx = 4096` (6 held-out windows, exact
gate), as a predicate on a profile: retention at the six grid points. -/
def MatchesTable (p : ℕ → ℝ) : Prop :=
  retained p 16 = 959 / 1000 ∧ retained p 20 = 969 / 1000 ∧
  retained p 24 = 975 / 1000 ∧ retained p 28 = 977 / 1000 ∧
  retained p 32 = 979 / 1000 ∧ retained p 40 = 984 / 1000

/-- **The gate is recovered from the table.**  If the knee is read as `40` on
the grid, the drift-assert threshold must satisfy `0.979 < τ ≤ 0.984`. -/
theorem gate_bracket {p : ℕ → ℝ} (ht : MatchesTable p) {tau : ℝ}
    (hex : ∃ k, tau ≤ retained p k) (hknee : knee p tau = 40) :
    979 / 1000 < tau ∧ tau ≤ 984 / 1000 := by
  constructor
  · have h := lt_knee (p := p) (tau := tau) (k := 32) (by omega)
    rw [ht.2.2.2.2.1] at h; exact h
  · have h := knee_spec hex
    rw [hknee, ht.2.2.2.2.2] at h; exact h

/-- **The true knee is bracketed, not measured.**  Any nonnegative profile
matching the table, with a gate in the bracket, has its true knee in `[33, 40]`:
the grid can certify `40` but cannot exclude `33`. -/
theorem true_knee_bracket {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) (ht : MatchesTable p)
    {tau : ℝ} (hlo : 979 / 1000 < tau) (hhi : tau ≤ 984 / 1000) :
    33 ≤ knee p tau ∧ knee p tau ≤ 40 := by
  have hex : ∃ k, tau ≤ retained p k := ⟨40, by rw [ht.2.2.2.2.2]; exact hhi⟩
  refine ⟨?_, knee_le (by rw [ht.2.2.2.2.2]; exact hhi)⟩
  by_contra hcon
  have hle : knee p tau ≤ 32 := by omega
  have h1 : tau ≤ retained p (knee p tau) := knee_spec hex
  have h2 : retained p (knee p tau) ≤ retained p 32 := retained_mono hp hle
  rw [ht.2.2.2.2.1] at h2
  linarith

/-- **The acceleration, honestly bracketed.**  The chain forces an increment in
`[9, 16]` at the fourth doubling — strictly more than twice the previous `+4`,
but the advertised `4×` is the top of the bracket. -/
theorem acceleration_bracketed {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) (ht : MatchesTable p)
    {tau : ℝ} (hlo : 979 / 1000 < tau) (hhi : tau ≤ 984 / 1000) :
    9 ≤ knee p tau - 24 ∧ knee p tau - 24 ≤ 16 ∧ 2 * 4 < knee p tau - 24 := by
  obtain ⟨h1, h2⟩ := true_knee_bracket hp ht hlo hhi
  refine ⟨by omega, by omega, by omega⟩

/-- An explicit profile reproducing the whole measured table whose true knee is
`33`: all its post-`32` mass arrives at index `32`. -/
noncomputable def pLow : ℕ → ℝ := fun i =>
  if i = 0 then 959 / 1000 else if i = 16 then 10 / 1000 else if i = 20 then 6 / 1000
  else if i = 24 then 2 / 1000 else if i = 28 then 2 / 1000 else if i = 32 then 5 / 1000
  else 0

/-- An explicit profile reproducing the whole measured table whose true knee is
`40`: the same mass arrives at index `39`. -/
noncomputable def pHigh : ℕ → ℝ := fun i =>
  if i = 0 then 959 / 1000 else if i = 16 then 10 / 1000 else if i = 20 then 6 / 1000
  else if i = 24 then 2 / 1000 else if i = 28 then 2 / 1000 else if i = 39 then 5 / 1000
  else 0

theorem pLow_nonneg (i : ℕ) : 0 ≤ pLow i := by
  unfold pLow
  split_ifs <;> norm_num

theorem pHigh_nonneg (i : ℕ) : 0 ≤ pHigh i := by
  unfold pHigh
  split_ifs <;> norm_num

theorem pLow_table : MatchesTable pLow := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    simp [retained, Finset.sum_range_succ, pLow] <;> norm_num

theorem pHigh_table : MatchesTable pHigh := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    simp [retained, Finset.sum_range_succ, pHigh] <;> norm_num

theorem retained_pLow_33 : retained pLow 33 = 984 / 1000 := by
  simp [retained, Finset.sum_range_succ, pLow]; norm_num

theorem retained_pHigh_39 : retained pHigh 39 = 979 / 1000 := by
  simp [retained, Finset.sum_range_succ, pHigh]; norm_num

/-- **The bracket is sharp.**  With the admissible gate `τ = 0.98` the two
profiles above match the entire measured table yet have true knees `33` and
`40`: the measurement determines the knee no better than `[33,40]`. -/
theorem bracket_sharp :
    MatchesTable pLow ∧ MatchesTable pHigh ∧
      knee pLow (98 / 100) = 33 ∧ knee pHigh (98 / 100) = 40 := by
  refine ⟨pLow_table, pHigh_table, ?_, ?_⟩
  · refine le_antisymm (knee_le (by rw [retained_pLow_33]; norm_num)) ?_
    by_contra hcon
    have hle : knee pLow (98 / 100) ≤ 32 := by omega
    have hex : ∃ k, (98 : ℝ) / 100 ≤ retained pLow k :=
      ⟨33, by rw [retained_pLow_33]; norm_num⟩
    have h1 := knee_spec hex
    have h2 : retained pLow (knee pLow (98 / 100)) ≤ retained pLow 32 :=
      retained_mono pLow_nonneg hle
    rw [pLow_table.2.2.2.2.1] at h2
    linarith
  · refine le_antisymm (knee_le (by rw [pHigh_table.2.2.2.2.2]; norm_num)) ?_
    by_contra hcon
    have hle : knee pHigh (98 / 100) ≤ 39 := by omega
    have hex : ∃ k, (98 : ℝ) / 100 ≤ retained pHigh k :=
      ⟨40, by rw [pHigh_table.2.2.2.2.2]; norm_num⟩
    have h1 := knee_spec hex
    have h2 : retained pHigh (knee pHigh (98 / 100)) ≤ retained pHigh 39 :=
      retained_mono pHigh_nonneg hle
    rw [retained_pHigh_39] at h2
    linarith

/-! ### 6. Deployment: which budgets the measurement decides -/

/-- **The deployment corollary, grid-robust.**  A 24-key cache fails at
`ctx = 4096` for *every* profile consistent with the table and *every* gate in
the bracket — this conclusion does not depend on the coarse grid. -/
theorem cache24_fails_robust {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) (ht : MatchesTable p)
    {tau : ℝ} (hlo : 979 / 1000 < tau) (hhi : tau ≤ 984 / 1000) :
    24 < knee p tau := by
  have := (true_knee_bracket hp ht hlo hhi).1
  omega

/-- Every budget of `40` keys or more is certified safe by the measurement. -/
theorem certified_safe {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) (ht : MatchesTable p)
    {tau : ℝ} (hhi : tau ≤ 984 / 1000) {B : ℕ} (hB : 40 ≤ B) :
    tau ≤ retained p B := by
  have h : retained p 40 ≤ retained p B := retained_mono hp hB
  rw [ht.2.2.2.2.2] at h
  linarith

/-- Every budget of `32` keys or fewer is provably unsafe. -/
theorem provably_unsafe {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) (ht : MatchesTable p)
    {tau : ℝ} (hlo : 979 / 1000 < tau) {B : ℕ} (hB : B ≤ 32) :
    retained p B < tau := by
  have h : retained p B ≤ retained p 32 := retained_mono hp hB
  rw [ht.2.2.2.2.1] at h
  linarith

/-- The undecided window is exactly `33 … 39`: `bracket_sharp` shows both a
consistent profile that already passes at `33` and one that fails until `40`. -/
theorem undecided_window :
    knee pLow (98 / 100) = 33 ∧ knee pHigh (98 / 100) = 40 ∧
      (∀ B, 33 ≤ B → B ≤ 39 →
        ((98 : ℝ) / 100 ≤ retained pLow B ∧ retained pHigh B < 98 / 100)) := by
  obtain ⟨-, -, hlow, hhigh⟩ := bracket_sharp
  refine ⟨hlow, hhigh, fun B h1 h2 => ⟨?_, ?_⟩⟩
  · have h : retained pLow 33 ≤ retained pLow B := retained_mono pLow_nonneg h1
    rw [retained_pLow_33] at h
    linarith
  · have h : retained pHigh B ≤ retained pHigh 39 := retained_mono pHigh_nonneg h2
    rw [retained_pHigh_39] at h
    linarith

/-! ### 7. Continuous layer: the rate law of cycle 1 is refuted -/

/-- **The `1/(j+1)` rate family is refuted.**  It produces a knee that is exactly
affine in the number of doublings, so no base rate and no tail budget can
reproduce `16, 20, 24, 40`. -/
theorem lamAt_law_refuted :
    ¬ ∃ lam0 delta : ℝ, lam0 ≠ 0 ∧
      kneeCts (lamAt lam0 0) delta = 16 ∧ kneeCts (lamAt lam0 1) delta = 20 ∧
      kneeCts (lamAt lam0 2) delta = 24 ∧ kneeCts (lamAt lam0 3) delta = 40 := by
  rintro ⟨lam0, delta, h0, e0, e1, e2, e3⟩
  have i1 := kneeCts_increment (delta := delta) h0 0
  have i3 := kneeCts_increment (delta := delta) h0 2
  norm_num at i1 i3
  rw [e0, e1] at i1
  rw [e2, e3] at i3
  linarith

/-- The knee and the decay rate are exact reciprocals: `k·λ = log(1/δ)`. -/
theorem knee_rate_reciprocal {lam delta : ℝ} (hlam : lam ≠ 0) :
    kneeCts lam delta * lam = Real.log (1 / delta) := by
  rw [kneeCts, div_mul_cancel₀ _ hlam]

/-- **Model-free rate collapse.**  For *any* family of exponential attention
tails explaining the chain, the decay rates are `λ_j = log(1/δ)/k_j`; hence the
measured chain forces `λ₃ = (3/5)·λ₂` where `λ₂ = (5/6)·λ₁`.  The relative
collapse of the rate itself accelerates at the fourth doubling. -/
theorem rate_collapse_accelerates {delta : ℝ}
    {lam : ℕ → ℝ} (hpos : ∀ j, 0 < lam j)
    (h1 : kneeCts (lam 1) delta = 20) (h2 : kneeCts (lam 2) delta = 24)
    (h3 : kneeCts (lam 3) delta = 40) :
    5 * lam 3 = 3 * lam 2 ∧ 6 * lam 2 = 5 * lam 1 ∧
      lam 3 / lam 2 < lam 2 / lam 1 := by
  have r1 := knee_rate_reciprocal (delta := delta) (hpos 1).ne'
  have r2 := knee_rate_reciprocal (delta := delta) (hpos 2).ne'
  have r3 := knee_rate_reciprocal (delta := delta) (hpos 3).ne'
  rw [h1] at r1; rw [h2] at r2; rw [h3] at r3
  have e1 : 5 * lam 3 = 3 * lam 2 := by linarith
  have e2 : 6 * lam 2 = 5 * lam 1 := by linarith
  refine ⟨e1, e2, ?_⟩
  rw [div_lt_div_iff₀ (hpos 2) (hpos 1)]
  nlinarith [hpos 1, hpos 2, hpos 3]

/-- **The collapse survives the grid gap.**  Even if the true knee at
`ctx = 4096` is anywhere at or above the certified lower end `33` of the grid
bracket `[33, 40]` — the upper end is not needed — the relative rate drop at the
fourth doubling is strictly larger than at the third.  The phase
transition is robust; only its magnitude is grid-limited. -/
theorem rate_collapse_accelerates_robust {delta : ℝ}
    {lam : ℕ → ℝ} (hpos : ∀ j, 0 < lam j) {k3 : ℝ} (hk3lo : 33 ≤ k3)
    (h1 : kneeCts (lam 1) delta = 20) (h2 : kneeCts (lam 2) delta = 24)
    (h3 : kneeCts (lam 3) delta = k3) :
    lam 3 / lam 2 < lam 2 / lam 1 := by
  have r1 := knee_rate_reciprocal (delta := delta) (hpos 1).ne'
  have r2 := knee_rate_reciprocal (delta := delta) (hpos 2).ne'
  have r3 := knee_rate_reciprocal (delta := delta) (hpos 3).ne'
  rw [h1] at r1; rw [h2] at r2; rw [h3] at r3
  rw [div_lt_div_iff₀ (hpos 2) (hpos 1)]
  nlinarith [hpos 1, hpos 2, hpos 3]

/-! ### 8. A crossover rate family that fits the whole chain -/

/-- Decay rate after `j` doublings in the **crossover** family: the inverse rate
grows like `4 + j` before the transition and picks up an extra `3` per doubling
after it. -/
noncomputable def lamCross (lam0 : ℝ) (j : ℕ) : ℝ :=
  lam0 / (4 + (j : ℝ) + 3 * max ((j : ℝ) - 2) 0)

theorem lamCross_pos {lam0 : ℝ} (h : 0 < lam0) (j : ℕ) : 0 < lamCross lam0 j := by
  have hj : (0 : ℝ) ≤ (j : ℝ) := Nat.cast_nonneg j
  have hm : (0 : ℝ) ≤ max ((j : ℝ) - 2) 0 := le_max_right _ _
  have hden : (0 : ℝ) < 4 + (j : ℝ) + 3 * max ((j : ℝ) - 2) 0 := by linarith
  exact div_pos h hden

theorem kneeCts_lamCross {lam0 delta : ℝ} (hlam0 : lam0 ≠ 0) (j : ℕ) :
    kneeCts (lamCross lam0 j) delta
      = (4 + (j : ℝ) + 3 * max ((j : ℝ) - 2) 0) * (Real.log (1 / delta) / lam0) := by
  have hj : (0 : ℝ) ≤ (j : ℝ) := Nat.cast_nonneg j
  have hm : (0 : ℝ) ≤ max ((j : ℝ) - 2) 0 := le_max_right _ _
  have hden : (4 : ℝ) + (j : ℝ) + 3 * max ((j : ℝ) - 2) 0 ≠ 0 := by positivity
  simp only [kneeCts, lamCross]
  field_simp

/-- The ramp fit is the cast of a max-plus expression over `ℝ`. -/
theorem kneeRamp_cast (j : ℕ) :
    ((kneeRamp j : ℕ) : ℝ) = 16 + 4 * (j : ℝ) + 12 * max ((j : ℝ) - 2) 0 := by
  rcases Nat.lt_or_ge j 2 with hj | hj
  · have h1 : j - 2 = 0 := by omega
    have h2 : ((j : ℝ)) - 2 ≤ 0 := by
      have : (j : ℝ) ≤ 2 := by exact_mod_cast hj.le
      linarith
    rw [max_eq_right h2]
    simp only [kneeRamp, h1]
    push_cast
    ring
  · have h2 : (0 : ℝ) ≤ (j : ℝ) - 2 := by
      have : (2 : ℝ) ≤ (j : ℝ) := by exact_mod_cast hj
      linarith
    rw [max_eq_left h2]
    simp only [kneeRamp]
    have : ((j - 2 : ℕ) : ℝ) = (j : ℝ) - 2 := by
      rw [Nat.cast_sub hj]; norm_num
    push_cast [this]
    ring

/-- **Calibration of the phase transition.**  At the cycle-1 tail budget
`δ = e⁻⁴` and base rate `λ₀ = 1`, the crossover family reproduces the ramp fit
of the whole measured chain, exactly — including the `+16` jump. -/
theorem calibration_phase (j : ℕ) :
    kneeCts (lamCross 1 j) (Real.exp (-4)) = ((kneeRamp j : ℕ) : ℝ) := by
  rw [kneeCts_lamCross (by norm_num), kneeRamp_cast, one_div, ← Real.exp_neg, Real.log_exp]
  ring

/-- The crossover family really does hit the four measured knees. -/
theorem calibration_phase_data :
    kneeCts (lamCross 1 0) (Real.exp (-4)) = 16 ∧
    kneeCts (lamCross 1 1) (Real.exp (-4)) = 20 ∧
    kneeCts (lamCross 1 2) (Real.exp (-4)) = 24 ∧
    kneeCts (lamCross 1 3) (Real.exp (-4)) = 40 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [calibration_phase] <;> norm_num [kneeRamp]

/-- **The rate profile of the transition.**  In the calibrated crossover family
the rate falls by the factor `5/6` at the third doubling but by `3/5` at the
fourth: the peakedness of attention collapses discontinuously past `ctx = 2048`.
-/
theorem lamCross_ratio_drop :
    lamCross 1 2 / lamCross 1 1 = 5 / 6 ∧ lamCross 1 3 / lamCross 1 2 = 3 / 5 ∧
      lamCross 1 3 / lamCross 1 2 < lamCross 1 2 / lamCross 1 1 := by
  have h1 : lamCross 1 1 = 1 / 5 := by norm_num [lamCross]
  have h2 : lamCross 1 2 = 1 / 6 := by norm_num [lamCross]
  have h3 : lamCross 1 3 = 1 / 10 := by norm_num [lamCross, max_eq_left]
  rw [h1, h2, h3]
  norm_num

end Catalog.Novelty.AttentionPhaseTransition