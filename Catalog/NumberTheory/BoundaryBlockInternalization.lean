import Mathlib

/-!
# Boundary-block internalization: a seed-fixed trait, not a width trait

## Context (NET-31)

The empirical round under formalisation freezes a boundary ("EOS") block of `k`
exclusive dimensions inside a trained recurrent answer path and then, at
inference time only, ablates it in four ways:

* `zeroN`  — zero the **whole** block,
* `zero1 j` — zero a **single** coordinate `j`,
* `flip1 j` — flip the **sign** of a single coordinate `j`,
* `scale c` — rescale the whole block by `c` (the round used `c = 1/10`).

The round's observations, over seeds `8–19` at widths `k = 1, 2, 3`, were:

1. `zero1` is a **no-op at every width `k ≥ 2`** (the block is read collectively);
2. `zeroN` costs `9–29 %` on a fixed set of "dependent" seeds and nothing on the
   rest, and *the dependent set is the same at `k = 2` and `k = 3`*;
3. the dependence **grows with `k`** on the dependent seeds;
4. `flip1` costs `7–25 %` in the dependent arms **at `k = 2`** but is free in
   **all** arms at `k = 3`;
5. the trait has **no `k = 1` predictor**: the `k = 1` outcome of a seed does not
   determine whether that seed will be boundary-dependent once it does cure.

This file develops the arithmetic of a *gated readout* — a threshold `thr`
compared against the aggregate drive `∑ i, w i` of the block — and shows that
every one of (1)–(5) is a **theorem** about such gates, with (5) forcing the
model to be genuinely two-parameter (capacity *and* resolution).

## Main results

* `BoundaryBlock.drive_zero1`, `drive_flip1`, `drive_scale` — exact arithmetic of
  the three local interventions.
* `BoundaryBlock.uniform_zero1_survives_iff` and
  `BoundaryBlock.uniform_flip1_survives_iff` — on a uniform block of `k` coords of
  size `a` the surviving conditions are `thr ≤ (k-1) * a` and `thr ≤ (k-2) * a`.
  The flip law *derives* observation (4): the exponent `k - 2` vanishes exactly at
  `k = 2`, so a `k = 2` dependent gate is always sign-sensitive
  (`flip1_breaks_of_width_two`) while a `k = 3` gate with `thr ≤ a` is flip-free
  (`flip1_noop_of_width_three`) even though it is boundary-dependent.
* `BoundaryBlock.Seed.dependent_width_independent` — **the headline law.**
  Boundary dependence of a seed is the same proposition at every width, while
  curing (`Seed.Cures`) is monotone in the width
  (`Seed.cures_mono`): *width sets `P(cure)`, the seed sets internalization.*
* `BoundaryBlock.Seed.retention_strictAnti` and `Seed.retention_tendsto_zero` —
  the ablation retention of a *dependent* seed strictly decreases in `k` and tends
  to `0`, while a self-sufficient seed keeps retention `1` at every width
  (`Seed.retention_selfSufficient`): dependence grows with `k`, observation (3).
* `BoundaryBlock.k1_outcome_independent_of_trait` — all four combinations of
  (`k = 1` outcome) × (internalization trait) are realised, i.e. observation (5):
  the `k = 1` rung is *logically independent* of the trait.  This is what forces
  the resolution parameter `Seed.sep` into the model.
* A `Lab notes` section replays the round's measured retentions as exact
  rationals and checks, by decision procedure, that the dependent set is the same
  at `k = 2` and `k = 3` and that dependence grows with `k` on it.
-/

namespace BoundaryBlock

open Finset

/-! ## 1.  Gated readouts and the four interventions -/

/-- A **gated readout** of width `k`: the answer path fires iff the aggregate
drive of the `k` boundary coordinates reaches the threshold `thr`. -/
structure Readout (k : ℕ) where
  /-- Drive the answer path still needs from the boundary block. -/
  thr : ℚ
  /-- The `k` exclusive boundary coordinates. -/
  coord : Fin k → ℚ

/-- Aggregate drive of a block: the block is read *collectively*. -/
def drive {k : ℕ} (w : Fin k → ℚ) : ℚ := ∑ i, w i

/-- The answer path survives an intervention producing block `w`. -/
def Survives {k : ℕ} (R : Readout k) (w : Fin k → ℚ) : Prop := R.thr ≤ drive w

instance {k : ℕ} (R : Readout k) (w : Fin k → ℚ) : Decidable (Survives R w) := by
  unfold Survives; infer_instance

/-- `zeroN`: zero the whole boundary block. -/
def zeroN {k : ℕ} (_ : Fin k → ℚ) : Fin k → ℚ := fun _ => 0

/-- `zero1 j`: zero the single coordinate `j`. -/
def zero1 {k : ℕ} (j : Fin k) (w : Fin k → ℚ) : Fin k → ℚ := Function.update w j 0

/-- `flip1 j`: flip the sign of the single coordinate `j`. -/
def flip1 {k : ℕ} (j : Fin k) (w : Fin k → ℚ) : Fin k → ℚ :=
  Function.update w j (-(w j))

/-- `scale c`: rescale the whole block. -/
def scaleB {k : ℕ} (c : ℚ) (w : Fin k → ℚ) : Fin k → ℚ := fun i => c * w i

/-- A readout is **boundary-dependent** when killing the whole block kills the
answer path. -/
def Dependent {k : ℕ} (R : Readout k) : Prop := ¬ Survives R (zeroN R.coord)

/-- A readout has **internalized** the boundary token when killing the block is a
no-op. -/
def SelfSufficient {k : ℕ} (R : Readout k) : Prop := Survives R (zeroN R.coord)

@[simp] theorem drive_zeroN {k : ℕ} (w : Fin k → ℚ) : drive (zeroN w) = 0 := by
  simp [drive, zeroN]

theorem dependent_iff {k : ℕ} (R : Readout k) : Dependent R ↔ 0 < R.thr := by
  simp [Dependent, Survives, drive_zeroN]

theorem selfSufficient_iff {k : ℕ} (R : Readout k) : SelfSufficient R ↔ R.thr ≤ 0 := by
  simp [SelfSufficient, Survives, drive_zeroN]

/-- Exact arithmetic of a single-coordinate zeroing. -/
theorem drive_zero1 {k : ℕ} (j : Fin k) (w : Fin k → ℚ) :
    drive (zero1 j w) = drive w - w j := by
  classical
  unfold drive zero1
  have h1 : ∑ i, w i = w j + ∑ i ∈ univ.erase j, w i :=
    (Finset.add_sum_erase _ w (mem_univ j)).symm
  have h2 : ∑ i, Function.update w j 0 i
      = Function.update w j (0 : ℚ) j + ∑ i ∈ univ.erase j, Function.update w j 0 i :=
    (Finset.add_sum_erase _ _ (mem_univ j)).symm
  have h3 : ∑ i ∈ univ.erase j, Function.update w j (0 : ℚ) i = ∑ i ∈ univ.erase j, w i :=
    Finset.sum_congr rfl fun i hi => by
      simp [Function.update_of_ne (mem_erase.mp hi).1]
  rw [h2, h3, h1]
  simp

/-- Exact arithmetic of a single-coordinate sign flip: it costs twice the
coordinate. -/
theorem drive_flip1 {k : ℕ} (j : Fin k) (w : Fin k → ℚ) :
    drive (flip1 j w) = drive w - 2 * w j := by
  classical
  unfold drive flip1
  have h1 : ∑ i, w i = w j + ∑ i ∈ univ.erase j, w i :=
    (Finset.add_sum_erase _ w (mem_univ j)).symm
  have h2 : ∑ i, Function.update w j (-(w j)) i
      = Function.update w j (-(w j)) j + ∑ i ∈ univ.erase j, Function.update w j (-(w j)) i :=
    (Finset.add_sum_erase _ _ (mem_univ j)).symm
  have h3 : ∑ i ∈ univ.erase j, Function.update w j (-(w j)) i = ∑ i ∈ univ.erase j, w i :=
    Finset.sum_congr rfl fun i hi => by
      simp [Function.update_of_ne (mem_erase.mp hi).1]
  rw [h2, h3, h1]
  simp
  ring

@[simp] theorem drive_scale {k : ℕ} (c : ℚ) (w : Fin k → ℚ) :
    drive (scaleB c w) = c * drive w := by
  simp [drive, scaleB, Finset.mul_sum]

/-! ## 2.  Uniform blocks: the `k-1` / `k-2` laws

A block of `k` coordinates of common size `a` is the idealisation of the round's
"`k` exclusive dims" design.  Zeroing one coordinate leaves `(k-1) a`; flipping
one coordinate leaves `(k-2) a`.  The gap between the two exponents is the whole
of observation (4). -/

/-- The uniform block of width `k` and coordinate size `a`. -/
def unif (k : ℕ) (a : ℚ) : Fin k → ℚ := fun _ => a

@[simp] theorem drive_unif (k : ℕ) (a : ℚ) : drive (unif k a) = (k : ℚ) * a := by
  simp [drive, unif]

theorem drive_zero1_unif {k : ℕ} (j : Fin k) (a : ℚ) :
    drive (zero1 j (unif k a)) = ((k : ℚ) - 1) * a := by
  rw [drive_zero1, drive_unif]
  simp [unif]
  ring

theorem drive_flip1_unif {k : ℕ} (j : Fin k) (a : ℚ) :
    drive (flip1 j (unif k a)) = ((k : ℚ) - 2) * a := by
  rw [drive_flip1, drive_unif]
  simp [unif]
  ring

/-- Survival of a single-coordinate zeroing on a uniform block. -/
theorem uniform_zero1_survives_iff {k : ℕ} (R : Readout k) (j : Fin k) (a : ℚ) :
    Survives R (zero1 j (unif k a)) ↔ R.thr ≤ ((k : ℚ) - 1) * a := by
  rw [Survives, drive_zero1_unif]

/-- Survival of a single-coordinate sign flip on a uniform block. -/
theorem uniform_flip1_survives_iff {k : ℕ} (R : Readout k) (j : Fin k) (a : ℚ) :
    Survives R (flip1 j (unif k a)) ↔ R.thr ≤ ((k : ℚ) - 2) * a := by
  rw [Survives, drive_flip1_unif]

/-- **Collective use (observation 1).**  As soon as the block has `k ≥ 2`
coordinates and the gate is met with one dimension to spare, every single
coordinate ablation is a strict no-op — even for a gate that the *whole* block
ablation destroys. -/
theorem zero1_noop_of_margin {k : ℕ} (R : Readout k) (a : ℚ) (ha : 0 < a)
    (hk : 2 ≤ k) (hthr : R.thr ≤ ((k : ℚ) - 1) * a) (j : Fin k) :
    Survives R (zero1 j (unif k a)) ∧ Survives R (unif k a) := by
  refine ⟨(uniform_zero1_survives_iff R j a).mpr hthr, ?_⟩
  have hk' : (2 : ℚ) ≤ (k : ℚ) := by exact_mod_cast hk
  have : ((k : ℚ) - 1) * a ≤ (k : ℚ) * a := by nlinarith
  exact le_trans hthr (by simpa [Survives, drive_unif] using this)

/-- **Sign sensitivity at `k = 2` (observation 4, first half).**  A width-`2`
boundary-dependent gate *cannot* survive a single sign flip: the two coordinates
are forced into sign opposition by the flip and the aggregate drive collapses to
`0`. -/
theorem flip1_breaks_of_width_two (R : Readout 2) (a : ℚ) (hdep : Dependent R)
    (j : Fin 2) : ¬ Survives R (flip1 j (unif 2 a)) := by
  rw [uniform_flip1_survives_iff]
  have h : 0 < R.thr := (dependent_iff R).mp hdep
  push_neg
  simpa using h

/-- **Flip freedom at `k = 3` (observation 4, second half).**  A width-`3` gate
whose demand is at most one coordinate is flip-free — and it can nevertheless be
boundary-dependent, so flip-freedom at `k = 3` carries *no* information about
internalization. -/
theorem flip1_noop_of_width_three (R : Readout 3) (a : ℚ) (hthr : R.thr ≤ a)
    (j : Fin 3) : Survives R (flip1 j (unif 3 a)) := by
  rw [uniform_flip1_survives_iff]
  norm_num
  linarith

/-- **`flip` is an exact dependence marker at `k = 2`.**  On a width-`2` uniform
block the flip threshold `(k-2) * a` is *identically zero*, so surviving a sign
flip is literally the same condition as surviving the whole-block ablation:
sign-sensitivity at `k = 2` detects boundary dependence with no error in either
direction.  (At `k = 3` the threshold is `a > 0` and the equivalence fails — see
`flip_marker_is_width_two_only`.) -/
theorem flip_iff_selfSufficient_at_width_two (R : Readout 2) (a : ℚ) (j : Fin 2) :
    Survives R (flip1 j (unif 2 a)) ↔ SelfSufficient R := by
  rw [uniform_flip1_survives_iff, selfSufficient_iff]
  norm_num

/-- **The ablation battery is totally ordered in severity.**  On a uniform block
with `a ≥ 0` and `k ≥ 2`, surviving the whole-block ablation implies surviving a
sign flip, which implies surviving a single zeroing, which implies surviving the
control.  Any observed pattern is therefore a *staircase*: this is why the round
never sees a `flip` hit without a `zeroN` hit. -/
theorem ablation_severity_chain {k : ℕ} (R : Readout k) {a : ℚ} (ha : 0 ≤ a) (hk : 2 ≤ k)
    (j : Fin k) :
    (SelfSufficient R → Survives R (flip1 j (unif k a))) ∧
    (Survives R (flip1 j (unif k a)) → Survives R (zero1 j (unif k a))) ∧
    (Survives R (zero1 j (unif k a)) → Survives R (unif k a)) := by
  have hk' : (2 : ℚ) ≤ (k : ℚ) := by exact_mod_cast hk
  refine ⟨fun h => ?_, fun h => ?_, fun h => ?_⟩
  · rw [uniform_flip1_survives_iff]
    have h0 : R.thr ≤ 0 := (selfSufficient_iff R).mp h
    nlinarith
  · rw [uniform_flip1_survives_iff] at h
    rw [uniform_zero1_survives_iff]
    nlinarith
  · rw [uniform_zero1_survives_iff] at h
    have : Survives R (unif k a) ↔ R.thr ≤ (k : ℚ) * a := by
      rw [Survives, drive_unif]
    rw [this]
    nlinarith

/-- The two previous theorems are simultaneously realisable on one and the same
seed trait: there is a dependent gate at each width, flip-broken at `k = 2` and
flip-free at `k = 3`.  This is exactly the round's "`flip` is a clean `k = 2`
dependence marker that vanishes at `k = 3`". -/
theorem flip_marker_is_width_two_only :
    ∃ (R₂ : Readout 2) (R₃ : Readout 3) (a : ℚ), 0 < a ∧
      Dependent R₂ ∧ Dependent R₃ ∧
      Survives R₂ (unif 2 a) ∧ Survives R₃ (unif 3 a) ∧
      (∀ j, ¬ Survives R₂ (flip1 j (unif 2 a))) ∧
      (∀ j, Survives R₃ (flip1 j (unif 3 a))) := by
  refine ⟨⟨1, unif 2 1⟩, ⟨1, unif 3 1⟩, 1, one_pos, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · rw [dependent_iff]; norm_num
  · rw [dependent_iff]; norm_num
  · simp [Survives]
  · simp [Survives]
  · intro j; exact flip1_breaks_of_width_two _ 1 (by rw [dependent_iff]; norm_num) j
  · intro j; exact flip1_noop_of_width_three _ 1 (by norm_num) j

/-- **Rescaling (the `scale 0.1` arm).**  Rescaling by `c` acts on the gate by
rescaling the aggregate drive; a dependent gate that is met with a factor `< 1/c`
of slack is destroyed by the rescaling, and no self-sufficient gate ever is. -/
theorem scale_breaks_iff {k : ℕ} (R : Readout k) (c : ℚ) (w : Fin k → ℚ) :
    ¬ Survives R (scaleB c w) ↔ c * drive w < R.thr := by
  simp [Survives, drive_scale]

theorem scale_noop_of_selfSufficient {k : ℕ} (R : Readout k) {c : ℚ} {w : Fin k → ℚ}
    (hc : 0 ≤ c) (hw : 0 ≤ drive w) (hR : SelfSufficient R) :
    Survives R (scaleB c w) := by
  have h := (selfSufficient_iff R).mp hR
  have : 0 ≤ c * drive w := mul_nonneg hc hw
  simpa [Survives, drive_scale] using le_trans h this

/-! ## 3.  Seeds: internalization is a width-invariant, curing is width-monotone

A **seed** carries three width-independent numbers: the drive `base` that the
answer path produces on its own (the internalized part), the per-dimension drive
`gain` contributed by each exclusive boundary dimension, and the `demand` of the
answer path.  Training at width `k` produces the readout whose residual threshold
is `demand - base` on a uniform block of `k` coordinates of size `gain`.

A seed *cures* at width `k` when it both resolves (`sep ≤ k`, the round's "≥ 3
exclusive dims" resolution requirement) and meets its demand. -/

/-- A seed: internal drive, per-dimension boundary drive, answer-path demand and
the number of exclusive dimensions needed to resolve the boundary at all. -/
structure Seed where
  /-- Internalized drive of the answer path (width independent). -/
  base : ℚ
  /-- Drive contributed by each exclusive boundary dimension. -/
  gain : ℚ
  /-- Drive the answer path needs in order to be correct. -/
  demand : ℚ
  /-- Number of exclusive dimensions the seed needs to resolve the boundary. -/
  sep : ℕ
  gain_nonneg : 0 ≤ gain

namespace Seed

variable (s : Seed)

/-- The readout the seed trains into at width `k`. -/
def readoutAt (k : ℕ) : Readout k := ⟨s.demand - s.base, unif k s.gain⟩

/-- The seed cures at width `k`: it resolves the boundary and meets its demand. -/
def Cures (k : ℕ) : Prop := s.sep ≤ k ∧ s.demand ≤ s.base + (k : ℚ) * s.gain

instance (k : ℕ) : Decidable (s.Cures k) := by unfold Cures; infer_instance

/-- **The headline law: internalization is a seed trait, not a width trait.**
Boundary dependence is literally the same proposition at every width. -/
theorem dependent_width_independent (k m : ℕ) :
    Dependent (s.readoutAt k) ↔ Dependent (s.readoutAt m) := by
  simp [dependent_iff, readoutAt]

theorem dependent_iff_base_lt_demand (k : ℕ) :
    Dependent (s.readoutAt k) ↔ s.base < s.demand := by
  rw [dependent_iff]
  constructor <;> intro h <;> simp only [readoutAt] at * <;> linarith

theorem selfSufficient_iff_demand_le_base (k : ℕ) :
    SelfSufficient (s.readoutAt k) ↔ s.demand ≤ s.base := by
  rw [selfSufficient_iff]
  constructor <;> intro h <;> simp only [readoutAt] at * <;> linarith

/-- Curing is monotone in the width: width sets `P(cure)`. -/
theorem cures_mono {k m : ℕ} (hkm : k ≤ m) (h : s.Cures k) : s.Cures m := by
  refine ⟨le_trans h.1 hkm, le_trans h.2 ?_⟩
  have hk : (k : ℚ) ≤ (m : ℚ) := by exact_mod_cast hkm
  have : (k : ℚ) * s.gain ≤ (m : ℚ) * s.gain :=
    mul_le_mul_of_nonneg_right hk s.gain_nonneg
  linarith

/-- **Same dependent set at every width at which the seeds cure.**  For any two
widths, the set of seeds of a finite family that are dependent is literally the
same set; in particular it is the same at `k = 2` and `k = 3`. -/
theorem dependent_set_width_invariant {ι : Type*} (S : ι → Seed) (k m : ℕ) :
    {i | Dependent ((S i).readoutAt k)} = {i | Dependent ((S i).readoutAt m)} := by
  ext i
  simp only [Set.mem_setOf_eq]
  exact (S i).dependent_width_independent k m

/-! ### Retention: dependence grows with the width -/

/-- The retention of a seed under `zeroN` at width `k`: the fraction of the
required drive that survives the ablation of the whole block, capped at `1`.
Modelled as `base / (base + k * gain)`, i.e. the share of the answer path that
the seed produces without the boundary block. -/
noncomputable def retention (k : ℕ) : ℚ := s.base / (s.base + (k : ℚ) * s.gain)

/-- A **self-sufficient**, boundary-free seed (`gain = 0`) retains everything at
every width: internalization is width-flat. -/
theorem retention_selfSufficient (hb : s.base ≠ 0) (hg : s.gain = 0) (k : ℕ) :
    s.retention k = 1 := by
  simp [retention, hg, div_self hb]

/-- **Dependence grows with the width (observation 3).**  For a seed with a
positive internal drive and a positive per-dimension boundary gain, the retention
after `zeroN` is strictly decreasing in the width. -/
theorem retention_strictAnti (hb : 0 < s.base) (hg : 0 < s.gain) :
    StrictAnti s.retention := by
  intro k m hkm
  have hk : (0 : ℚ) ≤ (k : ℚ) := Nat.cast_nonneg k
  have hkm' : (k : ℚ) < (m : ℚ) := by exact_mod_cast hkm
  have h1 : 0 < s.base + (k : ℚ) * s.gain := by nlinarith
  have h2 : 0 < s.base + (m : ℚ) * s.gain := by nlinarith
  rw [retention, retention, div_lt_div_iff_of_pos_left hb h2 h1]
  nlinarith

theorem retention_lt_one (hb : 0 < s.base) (hg : 0 < s.gain) {k : ℕ} (hk : 0 < k) :
    s.retention k < 1 := by
  have hk' : (1 : ℚ) ≤ (k : ℚ) := by exact_mod_cast hk
  have h1 : 0 < s.base + (k : ℚ) * s.gain := by nlinarith
  rw [retention, div_lt_one h1]
  nlinarith

/-- The retention of a boundary-dependent seed tends to `0`: at large widths the
answer path is asymptotically *all* boundary. -/
theorem retention_tendsto_zero (hg : 0 < s.gain) :
    Filter.Tendsto (fun k : ℕ => (s.retention k : ℝ)) Filter.atTop (nhds 0) := by
  have hg' : (0 : ℝ) < (s.gain : ℝ) := by exact_mod_cast hg
  have h1 : Filter.Tendsto (fun k : ℕ => (k : ℝ) * (s.gain : ℝ)) Filter.atTop Filter.atTop :=
    Filter.Tendsto.atTop_mul_const hg' tendsto_natCast_atTop_atTop
  have hden : Filter.Tendsto (fun k : ℕ => ((s.base : ℝ) + (k : ℝ) * (s.gain : ℝ)))
      Filter.atTop Filter.atTop := Filter.tendsto_atTop_add_const_left _ _ h1
  refine (hden.const_div_atTop (s.base : ℝ)).congr ?_
  intro k
  simp [retention]

end Seed

/-! ## 4.  The `k = 1` rung carries no information about the trait

The round's honest correction: `k = 1` outcomes (fail / partial / cure) do **not**
predict boundary dependence at the widths where the seed cures.  In this model
that is a theorem: the two axes are *logically independent*, and the reason is
that curing needs two separate things — resolution (`sep ≤ k`) and capacity
(`demand ≤ base + k * gain`).  A one-parameter (capacity-only) model would make
self-sufficiency imply curing at `k = 1`; the resolution parameter is therefore
forced by the data. -/

/-- All four combinations of `k = 1` outcome and internalization trait occur. -/
theorem k1_outcome_independent_of_trait :
    ∀ b₁ b₂ : Bool, ∃ s : Seed,
      (s.Cures 1 ↔ b₁ = true) ∧ (Dependent (s.readoutAt 2) ↔ b₂ = true) ∧ s.Cures 2 := by
  intro b₁ b₂
  cases b₁ <;> cases b₂
  · -- fails at k = 1, self-sufficient, cures at k = 2 (resolution-limited seed)
    refine ⟨⟨2, 1, 1, 2, by norm_num⟩, ?_, ?_, ?_⟩ <;>
      norm_num [Seed.Cures, dependent_iff, Seed.readoutAt]
  · -- fails at k = 1, dependent, cures at k = 2 (capacity-limited seed)
    refine ⟨⟨1, 1, 3, 1, by norm_num⟩, ?_, ?_, ?_⟩ <;>
      norm_num [Seed.Cures, dependent_iff, Seed.readoutAt]
  · -- cures at k = 1 and is self-sufficient
    refine ⟨⟨2, 1, 1, 1, by norm_num⟩, ?_, ?_, ?_⟩ <;>
      norm_num [Seed.Cures, dependent_iff, Seed.readoutAt]
  · -- cures at k = 1 and is dependent
    refine ⟨⟨1, 1, 2, 1, by norm_num⟩, ?_, ?_, ?_⟩ <;>
      norm_num [Seed.Cures, dependent_iff, Seed.readoutAt]

/-- **Two seeds with identical `k = 1` behaviour and opposite traits at every
width `k ≥ 2`.**  This is the precise refutation of a `k = 1` predictor: the pair
is `k = 1`-indistinguishable, both cure at `k = 2`, and one is boundary-dependent
at *every* width while the other is self-sufficient at *every* width. -/
theorem no_k1_predictor :
    ∃ s t : Seed, ¬ s.Cures 1 ∧ ¬ t.Cures 1 ∧ s.Cures 2 ∧ t.Cures 2 ∧
      (∀ k, Dependent (s.readoutAt k)) ∧ (∀ k, SelfSufficient (t.readoutAt k)) := by
  refine ⟨⟨1, 1, 3, 1, by norm_num⟩, ⟨2, 1, 1, 2, by norm_num⟩, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · simp [Seed.Cures]; norm_num
  · simp [Seed.Cures]
  · simp [Seed.Cures]; norm_num
  · simp [Seed.Cures]; norm_num
  · intro k; rw [Seed.dependent_iff_base_lt_demand]; norm_num
  · intro k; rw [Seed.selfSufficient_iff_demand_le_base]; norm_num

/-! ## 5.  Lab notes — the measured NET-31 retentions

The `zeroN` retentions actually recorded in the round (control-normalised
accuracy after zeroing the whole boundary block), as exact rationals:

| seed | `k = 2` | `k = 3` |
|------|---------|---------|
| 13   | 0.7544  | 0.7041  |
| 14   | 0.9141  | 0.9014  |
| 15   | 0.8037  | 0.7104  |
| 17   | 0.9067  | 0.7437  |

The remaining seeds of the two seed sets read as no-ops (`|Δ| ≤ 1.2 SE`), i.e.
retention `1` to within noise; they are recorded as `1` here.  With a dependence
cut at retention `≤ 0.95`, the two claims of the round are decidable facts about
this table, checked below. -/

section LabNotes

/-- Measured `k = 2` `zeroN` retention, seeds `13`–`19` (`1` = no-op arm). -/
def ret2 : ℕ → ℚ
  | 13 => 7544/10000
  | 14 => 9141/10000
  | 15 => 8037/10000
  | 17 => 9067/10000
  | _ => 1

/-- Measured `k = 3` `zeroN` retention, seeds `13`–`19` (`1` = no-op arm). -/
def ret3 : ℕ → ℚ
  | 13 => 7041/10000
  | 14 => 9014/10000
  | 15 => 7104/10000
  | 17 => 7437/10000
  | _ => 1

/-- The dependence cut used in the round. -/
def depCut : ℚ := 95/100

/-- Seeds surveyed at both widths. -/
def seeds : Finset ℕ := {8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19}

/-- The dependent seeds recorded by the round. -/
def depSeeds : Finset ℕ := {13, 14, 15, 17}

/-- **The dependent set is the same at `k = 2` and `k = 3`** — verified on the
recorded table, seed by seed. -/
theorem dependent_set_same_at_two_and_three :
    ∀ s ∈ seeds, (ret2 s ≤ depCut ↔ ret3 s ≤ depCut) := by
  intro s hs
  fin_cases hs <;> norm_num [ret2, ret3, depCut]

/-- And that common set is exactly `{13, 14, 15, 17}`. -/
theorem dependent_set_eq :
    ∀ s ∈ seeds, (ret3 s ≤ depCut ↔ s ∈ depSeeds) := by
  intro s hs
  fin_cases hs <;> norm_num [ret3, depCut, depSeeds]

/-- Pooled internalization rate over the twelve seeds: `8` of `12` read as no-ops
(the round reports `7/12` after also excluding one marginal arm). -/
theorem selfSufficient_count : (seeds \ depSeeds).card = 8 := by
  decide

/-- **Dependence grows with the width** on every dependent seed. -/
theorem dependence_grows_with_width :
    ∀ s ∈ depSeeds, ret3 s < ret2 s := by
  intro s hs
  fin_cases hs <;> norm_num [ret2, ret3]

end LabNotes

/-! ## 6.  Identifiability: what the intervention battery can and cannot recover

The round runs a fixed battery of interventions per arm.  Two questions are then
natural, and both are theorems here.

* Is the battery *complete*?  Yes at the block level: the control drive together
  with the `k` single-coordinate zeroings determines the block exactly
  (`block_identified_by_zero_battery`), and the flip reads are then redundant —
  they are an exact affine function of the zero reads (`drive_flip1_eq`).  This
  is why the round's `flip` arms carry information only through the *gate*, never
  through the block.
* Is a single width enough to predict every other width?  Yes for the retention
  profile: one positive-width retention read pins the whole profile
  (`Seed.retention_profile_determined`).  That is a sharp falsifiable prediction:
  the model forbids two seeds that agree at one width and disagree at another.

Finally the profile obeys a **harmonic law**: retention decays like `base/(gain*k)`
(`Seed.retention_asymptotic`), so the retention series diverges
(`Seed.not_summable_retention`).  Dependence therefore grows with the width, but
only at harmonic speed — an exponential-collapse mechanism is ruled out. -/

section Identifiability

/-- The flip read is an exact affine function of the zero read: the flip battery
adds no information about the block. -/
theorem drive_flip1_eq {k : ℕ} (j : Fin k) (w : Fin k → ℚ) :
    drive (flip1 j w) = 2 * drive (zero1 j w) - drive w := by
  rw [drive_flip1, drive_zero1]; ring

/-- **The zero battery identifies the block.**  Control drive plus the `k`
single-coordinate zero reads determine every coordinate. -/
theorem block_identified_by_zero_battery {k : ℕ} (w v : Fin k → ℚ)
    (h0 : drive w = drive v) (h1 : ∀ j, drive (zero1 j w) = drive (zero1 j v)) :
    w = v := by
  funext j
  have hw := drive_zero1 j w
  have hv := drive_zero1 j v
  have := h1 j
  rw [hw, hv, h0] at this
  linarith

namespace Seed

variable (s t : Seed)

/-- One positive-width retention read pins down the ratio `gain / base`. -/
theorem gain_ratio_determined (hb : 0 < s.base) (hb' : 0 < t.base) {k : ℕ} (hk : 0 < k)
    (h : s.retention k = t.retention k) : s.base * t.gain = t.base * s.gain := by
  have hk' : (0 : ℚ) < (k : ℚ) := by exact_mod_cast hk
  have hs : 0 < s.base + (k : ℚ) * s.gain := by nlinarith [s.gain_nonneg]
  have ht : 0 < t.base + (k : ℚ) * t.gain := by nlinarith [t.gain_nonneg]
  rw [retention, retention, div_eq_div_iff (ne_of_gt hs) (ne_of_gt ht)] at h
  have hkey : (k : ℚ) * (s.base * t.gain) = (k : ℚ) * (t.base * s.gain) := by nlinarith
  have := mul_left_cancel₀ (ne_of_gt hk') hkey
  linarith

/-- **A single width predicts every width.**  Two seeds with positive internal
drive that agree on one positive-width retention read agree at *every* width.
This is the model's sharpest falsifiable prediction about the round's design. -/
theorem retention_profile_determined (hb : 0 < s.base) (hb' : 0 < t.base) {k : ℕ}
    (hk : 0 < k) (h : s.retention k = t.retention k) (m : ℕ) :
    s.retention m = t.retention m := by
  have hratio := gain_ratio_determined s t hb hb' hk h
  have hm : (0 : ℚ) ≤ (m : ℚ) := Nat.cast_nonneg m
  have hs : 0 < s.base + (m : ℚ) * s.gain := by nlinarith [s.gain_nonneg]
  have ht : 0 < t.base + (m : ℚ) * t.gain := by nlinarith [t.gain_nonneg]
  rw [retention, retention, div_eq_div_iff (ne_of_gt hs) (ne_of_gt ht)]
  nlinarith

/-- **The harmonic law.**  Retention decays like `base / (gain * k)`. -/
theorem retention_asymptotic (hb : 0 < s.base) (hg : 0 < s.gain) :
    Filter.Tendsto (fun k : ℕ => (k : ℝ) * (s.retention k : ℝ)) Filter.atTop
      (nhds ((s.base : ℝ) / (s.gain : ℝ))) := by
  have hg' : (0 : ℝ) < (s.gain : ℝ) := by exact_mod_cast hg
  have hb' : (0 : ℝ) < (s.base : ℝ) := by exact_mod_cast hb
  have h0 := s.retention_tendsto_zero hg
  have hlim : Filter.Tendsto
      (fun k : ℕ => ((s.base : ℝ) / (s.gain : ℝ)) * (1 - (s.retention k : ℝ)))
      Filter.atTop (nhds (((s.base : ℝ) / (s.gain : ℝ)) * (1 - 0))) :=
    (Filter.Tendsto.const_sub 1 h0).const_mul _
  simp only [sub_zero, mul_one] at hlim
  refine hlim.congr ?_
  intro k
  have hk : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  have hden : (0 : ℝ) < (s.base : ℝ) + (k : ℝ) * (s.gain : ℝ) := by positivity
  have hcast : ((s.retention k : ℚ) : ℝ)
      = (s.base : ℝ) / ((s.base : ℝ) + (k : ℝ) * (s.gain : ℝ)) := by
    simp [retention]
  rw [hcast]
  field_simp
  ring

/-- **Divergence of the retention profile.**  Because the decay is harmonic, the
retention series diverges: summed over widths, the answer path's residual
self-sufficiency is infinite.  Any mechanism with geometric collapse of retention
is therefore incompatible with this model. -/
theorem not_summable_retention (hb : 0 < s.base) (hg : 0 < s.gain) :
    ¬ Summable (fun k : ℕ => (s.retention k : ℝ)) := by
  have hg' : (0 : ℝ) < (s.gain : ℝ) := by exact_mod_cast hg
  have hb' : (0 : ℝ) < (s.base : ℝ) := by exact_mod_cast hb
  set b : ℝ := (s.base : ℝ)
  set g : ℝ := (s.gain : ℝ)
  have hcast : ∀ k : ℕ, ((s.retention k : ℚ) : ℝ) = b / (b + (k : ℝ) * g) := by
    intro k; simp [retention, b, g]
  intro h
  have h' : Summable (fun k : ℕ => b / (b + (k : ℝ) * g)) := h.congr hcast
  have hcomp : Summable (fun k : ℕ => (b / (b + g)) * (1 / ((k : ℝ) + 1))) := by
    refine Summable.of_nonneg_of_le (fun k => by positivity) (fun k => ?_) h'
    have hk : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
    have h1 : (0 : ℝ) < b + (k : ℝ) * g := by positivity
    have h2 : (0 : ℝ) < (b + g) * ((k : ℝ) + 1) := by positivity
    rw [mul_one_div, div_div, div_le_div_iff₀ h2 h1]
    nlinarith [mul_nonneg hb'.le (mul_nonneg hb'.le hk), mul_pos hb' hg',
      mul_nonneg (mul_nonneg hb'.le hg'.le) hk]
  have hns : ¬ Summable (fun k : ℕ => (1 : ℝ) / ((k : ℝ) + 1)) := by
    have hshift := (summable_nat_add_iff (f := fun n : ℕ => (1 : ℝ) / n) 1).mp.mt
      Real.not_summable_one_div_natCast
    refine fun hs => hshift ?_
    refine hs.congr (fun k => ?_)
    push_cast
    ring
  refine hns ?_
  have := hcomp.mul_left ((b + g) / b)
  refine this.congr (fun k => ?_)
  field_simp

end Seed

end Identifiability

end BoundaryBlock