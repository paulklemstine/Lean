import Mathlib
import Combinatorics.KneeInvariance

/-!
# NET-64: the grid artifact, the replication law, and the accuracy/knee decoupling

This file formalises the mathematics behind the NET-64 verdict
**THE-CORPUS-B-DISAGREEMENT-WAS-A-GRID-ARTIFACT**.

Empirical situation (limited-memory / top-`k` key-retention sweep, `ctx = 2048`,
gate `0.98`).  The *fine* sweep on corpus B reads

| k        | 20     | 24     | 28     | 32     |
|----------|--------|--------|--------|--------|
| retained | 0.9790 | 0.9832 | 0.9853 | 0.9862 |

so the fine grid reports `k* = 24`, matching corpus A, while an earlier *coarse*
sweep on corpus B (grid `{8, 16, 32, 64}`) had reported `32`.  The claim under
test is that the `24` vs `32` disagreement was never a property of the corpora:
it is an artifact of reading two different grids.

The abstraction is a monotone **retention curve** `A : ℕ → ℚ` (retained quality
as a function of the key budget) together with the `knee`
`knee A g = sInf {k | g ≤ A k}` of `Combinatorics.KneeInvariance`, and its
observable shadow, the **grid knee** `gridKnee G A g`, the least *grid point*
meeting the gate — the only thing a sweep can ever report.

Main results.

* `gridKnee_eq_gridCeil` — **the factorisation theorem**: for a monotone curve,
  `gridKnee G A g` is the least element of `G` above `knee A g`.  A sweep never
  measures the curve; it measures the ceiling of the true knee in the grid.
  Consequence (`gridKnee_eq_iff_mem`): the reported knee is exact **iff** the
  true knee happens to lie on the grid.  This is the exact form of the NET-64
  verdict: a grid disagreement is a statement about the grids, not the corpora.
* `knee_le_gridKnee`, `gridKnee_antitone_refine` — a grid can only over-report,
  and refining a grid can only lower the reading.
* `gridKnee_dyadic_lt_two_mul` — a **quantitative artifact bound** for the
  doubling grids used in practice: the coarse reading is always `< 2 k*`.  The
  measured `24 → 32` inflation is inside this bound, and cannot exceed it.
* `grid_reading_underdetermines_knee` — the artifact is not removable by
  inference: two curves that agree at every coarse grid point (hence give the
  same coarse reading at every gate) can have any two true knees inside the same
  grid cell.
* `net64_two_readings_of_one_knee` — the concrete NET-64 statement, from the
  measured corpus-B row: one curve, true knee `24`, fine reading `24`, coarse
  reading `32`.  No two corpora are needed to manufacture the disagreement.
* `knee_eq_of_uniform_close` and `knees_agree_of_close` — the **replication
  law**: if two corpora's curves are uniformly `ε`-close and the fine table
  clears the gate with margin `> ε` above and below, the knees are *equal*.
  Instantiated at the measured corpus-B margins in `net64_replication_margin`.
* `margin_hypothesis_is_necessary` — and the margin hypothesis cannot be
  dropped: for every `ε > 0` and every `N` there are `ε`-close monotone curves
  whose knees are `1` and `N`.  Replication is a margin phenomenon.
* `knee_retention_scale_invariant`, `net64_baseline_shift_fixes_knee` — the
  **accuracy/knee decoupling**: the knee of a *retention ratio* curve is
  invariant under rescaling the raw accuracy, so corpus B's easier text
  (`0.4946` vs `0.4760`) cannot move the knee.  Accuracy level and knee position
  are independent coordinates.

Only the corpus-B row above is measured data; every other numerical object in
the file is either derived from it or an explicitly synthetic witness.
-/

namespace Catalog.Probability.NET64GridArtifact

open Finset Combinatorics.KneeInvariance

/-! ## 1. Grid knees: what a sweep can actually report -/

/-- The **grid knee**: the least *grid point* whose retained quality reaches the
gate.  A budget sweep evaluates the model only at the points of `G`, so this —
and not `knee A g` — is the number the experiment prints. -/
noncomputable def gridKnee (G : Set ℕ) (A : ℕ → ℚ) (g : ℚ) : ℕ :=
  sInf {k | k ∈ G ∧ g ≤ A k}

variable {G H : Set ℕ} {A B : ℕ → ℚ} {g : ℚ}

/-- The reading is a grid point that clears the gate, provided some grid point does. -/
theorem gridKnee_mem (h : ∃ k ∈ G, g ≤ A k) :
    gridKnee G A g ∈ G ∧ g ≤ A (gridKnee G A g) := by
  obtain ⟨k, hk, hk'⟩ := h
  have hne : {k | k ∈ G ∧ g ≤ A k}.Nonempty := ⟨k, hk, hk'⟩
  exact Nat.sInf_mem hne

theorem gridKnee_le {k : ℕ} (hk : k ∈ G) (h : g ≤ A k) : gridKnee G A g ≤ k :=
  Nat.sInf_le ⟨hk, h⟩

/-- **A grid can only over-report.**  The reading is never below the true knee. -/
theorem knee_le_gridKnee (h : ∃ k ∈ G, g ≤ A k) : knee A g ≤ gridKnee G A g :=
  Combinatorics.KneeInvariance.knee_le (gridKnee_mem h).2

/-- **Refining a grid can only lower the reading.** -/
theorem gridKnee_antitone_refine (hGH : G ⊆ H) (h : ∃ k ∈ G, g ≤ A k) :
    gridKnee H A g ≤ gridKnee G A g :=
  gridKnee_le (hGH (gridKnee_mem h).1) (gridKnee_mem h).2

/-- **The factorisation theorem.**  For a monotone curve the grid reading depends
on the curve *only through its true knee*: it is the least grid point at or above
`knee A g`.  Everything else about the curve — its values, its corpus, its
accuracy level — is invisible to the sweep. -/
theorem gridKnee_eq_gridCeil (hA : Monotone A) (h : ∃ k ∈ G, g ≤ A k) :
    gridKnee G A g = sInf {k | k ∈ G ∧ knee A g ≤ k} := by
  have hne : ∃ m, g ≤ A m := by obtain ⟨k, _, hk⟩ := h; exact ⟨k, hk⟩
  unfold gridKnee
  congr 1
  ext k
  simp [Combinatorics.KneeInvariance.knee_le_iff hA hne]

/-- **The artifact criterion.**  A sweep reports the true knee **iff** the true
knee happens to be one of the sampled budgets.  Off-grid knees are reported
inflated — this is precisely the NET-64 verdict. -/
theorem gridKnee_eq_iff_mem (h : ∃ k ∈ G, g ≤ A k) :
    gridKnee G A g = knee A g ↔ knee A g ∈ G := by
  have hne : ∃ m, g ≤ A m := by obtain ⟨k, _, hk⟩ := h; exact ⟨k, hk⟩
  constructor
  · intro he; exact he ▸ (gridKnee_mem h).1
  · intro hmem
    exact le_antisymm (gridKnee_le hmem (Combinatorics.KneeInvariance.knee_mem hne))
      (knee_le_gridKnee h)

/-- A sweep brackets the knee: a failing budget below and a passing budget above
pin the true knee to the half-open cell between them. -/
theorem knee_mem_cell (hA : Monotone A) {a b : ℕ} (ha : A a < g) (hb : g ≤ A b) :
    a < knee A g ∧ knee A g ≤ b := by
  refine ⟨?_, Combinatorics.KneeInvariance.knee_le hb⟩
  by_contra hc
  exact absurd (Combinatorics.KneeInvariance.knee_mem ⟨b, hb⟩)
    (not_le.mpr (lt_of_le_of_lt (hA (not_lt.mp hc)) ha))

/-! ## 2. How large can the artifact be?  The doubling grid -/

/-- The doubling grid `{1, 2, 4, 8, …}` — the coarse grid of a first sweep. -/
def dyadicGrid : Set ℕ := Set.range fun j : ℕ => 2 ^ j

/-- **Quantitative artifact bound.**  On a doubling grid the reported knee is
always strictly less than twice the true knee: a coarse sweep inflates, but by a
bounded factor.  (`24 ↦ 32` is inside the bound `< 48`.) -/
theorem gridKnee_dyadic_lt_two_mul (hA : Monotone A) (hne : ∃ m, g ≤ A m)
    (hpos : 0 < knee A g) : gridKnee dyadicGrid A g < 2 * knee A g := by
  set k := knee A g with hk
  have hcov : k ≤ 2 ^ Nat.clog 2 k := Nat.le_pow_clog (by norm_num) k
  have hgrid : (2 : ℕ) ^ Nat.clog 2 k ∈ dyadicGrid := ⟨Nat.clog 2 k, rfl⟩
  have hval : g ≤ A (2 ^ Nat.clog 2 k) :=
    le_trans (Combinatorics.KneeInvariance.knee_mem hne) (hA hcov)
  have hle : gridKnee dyadicGrid A g ≤ 2 ^ Nat.clog 2 k := gridKnee_le hgrid hval
  have hlt : (2 : ℕ) ^ Nat.clog 2 k < 2 * k := by
    have hk1 : 1 ≤ k := hpos
    rcases eq_or_lt_of_le hk1 with h1 | h1
    · rw [← h1, Nat.clog_one_right]; norm_num
    · have hc : 0 < Nat.clog 2 k := Nat.clog_pos (by norm_num) h1
      have hstep : (2 : ℕ) ^ (Nat.clog 2 k - 1) < k :=
        Nat.pow_pred_clog_lt_self (b := 2) (x := k) (by norm_num) h1
      have hsplit : (2 : ℕ) ^ Nat.clog 2 k = 2 * 2 ^ (Nat.clog 2 k - 1) := by
        rw [← pow_succ']
        congr 1
        omega
      omega
  exact lt_of_le_of_lt hle hlt

/-! ## 3. Curves built from nonnegative budget gains -/

/-- A retention curve assembled from per-key gains: `curveOf w k = ∑_{i<k} w i`.
Nonnegative gains make the curve monotone by construction, so every witness
below is automatically a legitimate retention curve. -/
def curveOf (w : ℕ → ℚ) (k : ℕ) : ℚ := ∑ i ∈ range k, w i

theorem monotone_curveOf {w : ℕ → ℚ} (hw : ∀ i, 0 ≤ w i) : Monotone (curveOf w) := by
  intro a b hab
  exact Finset.sum_le_sum_of_subset_of_nonneg (by simpa using hab) fun i _ _ => hw i

/-- The measured corpus-B row at `ctx = 2048`: all retention gain is realised at
the sampled budgets `20, 24, 28, 32`, giving `0.9790, 0.9832, 0.9853, 0.9862`. -/
def corpusBGain : ℕ → ℚ := fun i =>
  if i = 19 then 9790 / 10000
  else if i = 23 then 42 / 10000
  else if i = 27 then 21 / 10000
  else if i = 31 then 9 / 10000
  else 0

/-- The corpus-B retention curve at `ctx = 2048`. -/
def corpusB : ℕ → ℚ := curveOf corpusBGain

/-- The retention gate used throughout NET-64. -/
def gate : ℚ := 98 / 100

/-- The fine grid of the NET-64 sweep. -/
def fineGrid : Set ℕ := {16, 20, 24, 28, 32}

/-- The coarse (doubling) grid of the earlier corpus-B sweep. -/
def coarseGrid : Set ℕ := {8, 16, 32, 64}

theorem corpusBGain_nonneg : ∀ i, 0 ≤ corpusBGain i := by
  intro i
  unfold corpusBGain
  split_ifs <;> norm_num

theorem monotone_corpusB : Monotone corpusB := monotone_curveOf corpusBGain_nonneg

/-- The measured table: retention at the four fine budgets. -/
theorem corpusB_table :
    corpusB 20 = 9790 / 10000 ∧ corpusB 24 = 9832 / 10000 ∧
      corpusB 28 = 9853 / 10000 ∧ corpusB 32 = 9862 / 10000 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    norm_num [corpusB, curveOf, corpusBGain, Finset.sum_range_succ]

/-- No gain accrues between budgets `20` and `23`. -/
theorem corpusB_23 : corpusB 23 = 9790 / 10000 := by
  norm_num [corpusB, curveOf, corpusBGain, Finset.sum_range_succ]

theorem corpusB_lt_gate_of_le (k : ℕ) (hk : k ≤ 23) : corpusB k < gate := by
  have hmono : corpusB k ≤ corpusB 23 := monotone_corpusB hk
  rw [corpusB_23] at hmono
  unfold gate
  linarith

/-- **The true knee of the measured corpus-B curve is 24.** -/
theorem knee_corpusB : knee corpusB gate = 24 := by
  refine Combinatorics.KneeInvariance.knee_eq_of ?_ ?_
  · rw [corpusB_table.2.1]; unfold gate; norm_num
  · intro j hj
    exact corpusB_lt_gate_of_le j (by omega)

/-- The fine sweep reports `24`. -/
theorem fine_reading_corpusB : gridKnee fineGrid corpusB gate = 24 := by
  have hpass : gate ≤ corpusB 24 := by rw [corpusB_table.2.1]; unfold gate; norm_num
  have hex : ∃ k ∈ fineGrid, gate ≤ corpusB k := ⟨24, by simp [fineGrid], hpass⟩
  refine le_antisymm (gridKnee_le (by simp [fineGrid]) hpass) ?_
  have h1 : knee corpusB gate ≤ gridKnee fineGrid corpusB gate := knee_le_gridKnee hex
  rwa [knee_corpusB] at h1

/-- The earlier coarse sweep reports `32` **on the very same curve**. -/
theorem coarse_reading_corpusB : gridKnee coarseGrid corpusB gate = 32 := by
  have hpass : gate ≤ corpusB 32 := by rw [corpusB_table.2.2.2]; unfold gate; norm_num
  refine le_antisymm (gridKnee_le (by simp [coarseGrid]) hpass) ?_
  have hex : ∃ k ∈ coarseGrid, gate ≤ corpusB k := ⟨32, by simp [coarseGrid], hpass⟩
  obtain ⟨hmem, -⟩ := gridKnee_mem hex
  have hk24 : 24 ≤ gridKnee coarseGrid corpusB gate := by
    have := knee_le_gridKnee hex
    rwa [knee_corpusB] at this
  have hcase : gridKnee coarseGrid corpusB gate = 8 ∨ gridKnee coarseGrid corpusB gate = 16 ∨
      gridKnee coarseGrid corpusB gate = 32 ∨ gridKnee coarseGrid corpusB gate = 64 := by
    simpa [coarseGrid] using hmem
  rcases hcase with h | h | h | h <;> omega

/-- **THE-CORPUS-B-DISAGREEMENT-WAS-A-GRID-ARTIFACT (concrete form).**
The measured corpus-B curve at `ctx = 2048` has true knee `24`; a fine sweep
reports `24` and a doubling sweep reports `32`.  The `24` vs `32` disagreement is
produced by *one* corpus read on two grids — no shard-level difference is needed
to explain it, and the reported gap obeys the general doubling bound. -/
theorem net64_two_readings_of_one_knee :
    knee corpusB gate = 24 ∧ gridKnee fineGrid corpusB gate = 24 ∧
      gridKnee coarseGrid corpusB gate = 32 ∧
      gridKnee coarseGrid corpusB gate < 2 * knee corpusB gate :=
  ⟨knee_corpusB, fine_reading_corpusB, coarse_reading_corpusB, by
    rw [knee_corpusB, coarse_reading_corpusB]; norm_num⟩

/-- A curve that jumps from `0` to `1` exactly at budget `c`: the extreme
"all-or-nothing" retention profile. -/
def stepCurve (c : ℕ) : ℕ → ℚ := fun k => if c ≤ k then 1 else 0

theorem monotone_stepCurve (c : ℕ) : Monotone (stepCurve c) := by
  intro x y hxy
  unfold stepCurve
  by_cases h1 : c ≤ x
  · rw [if_pos h1, if_pos (h1.trans hxy)]
  · rw [if_neg h1]
    split_ifs <;> norm_num

theorem stepCurve_of_le {c k : ℕ} (h : c ≤ k) : stepCurve c k = 1 := if_pos h

theorem stepCurve_of_lt {c k : ℕ} (h : k < c) : stepCurve c k = 0 := if_neg (by omega)

theorem knee_stepCurve (c : ℕ) : knee (stepCurve c) gate = c := by
  refine Combinatorics.KneeInvariance.knee_eq_of ?_ ?_
  · rw [stepCurve_of_le (le_refl c)]; unfold gate; norm_num
  · intro j hj
    rw [stepCurve_of_lt hj]; unfold gate; norm_num

theorem coarse_reading_stepCurve {c : ℕ} (hc : 16 < c) (hc' : c ≤ 32) :
    gridKnee coarseGrid (stepCurve c) gate = 32 := by
  have hpass : gate ≤ stepCurve c 32 := by
    rw [stepCurve_of_le (by omega : c ≤ 32)]; unfold gate; norm_num
  refine le_antisymm (gridKnee_le (by simp [coarseGrid]) hpass) ?_
  have hex : ∃ k ∈ coarseGrid, gate ≤ stepCurve c k := ⟨32, by simp [coarseGrid], hpass⟩
  obtain ⟨hmem, -⟩ := gridKnee_mem hex
  have hge : c ≤ gridKnee coarseGrid (stepCurve c) gate := by
    have := knee_le_gridKnee hex
    rwa [knee_stepCurve c] at this
  have hcase : gridKnee coarseGrid (stepCurve c) gate = 8 ∨
      gridKnee coarseGrid (stepCurve c) gate = 16 ∨
      gridKnee coarseGrid (stepCurve c) gate = 32 ∨
      gridKnee coarseGrid (stepCurve c) gate = 64 := by
    simpa [coarseGrid] using hmem
  rcases hcase with h | h | h | h <;> omega

/-- **The artifact is not removable by inference.**  Two curves agreeing at every
point of the coarse grid — hence giving identical readings for *every* gate — can
have any prescribed pair of true knees inside the same grid cell.  So a coarse
reading of `32` is compatible with any true knee in `(16, 32]`, and comparing a
coarse reading on one corpus with a fine reading on another can never be evidence
of a corpus-level difference. -/
theorem grid_reading_underdetermines_knee {a b : ℕ} (ha : 16 < a) (ha' : a ≤ 32)
    (hb : 16 < b) (hb' : b ≤ 32) :
    ∃ A B : ℕ → ℚ, Monotone A ∧ Monotone B ∧
      (∀ k ∈ coarseGrid, A k = B k) ∧
      knee A gate = a ∧ knee B gate = b ∧
      gridKnee coarseGrid A gate = 32 ∧ gridKnee coarseGrid B gate = 32 := by
  refine ⟨stepCurve a, stepCurve b, monotone_stepCurve a, monotone_stepCurve b, ?_,
    knee_stepCurve a, knee_stepCurve b,
    coarse_reading_stepCurve ha ha', coarse_reading_stepCurve hb hb'⟩
  intro k hk
  have hcase : k = 8 ∨ k = 16 ∨ k = 32 ∨ k = 64 := by simpa [coarseGrid] using hk
  rcases hcase with h | h | h | h <;> subst h
  · rw [stepCurve_of_lt (by omega), stepCurve_of_lt (by omega)]
  · rw [stepCurve_of_lt (by omega), stepCurve_of_lt (by omega)]
  · rw [stepCurve_of_le (by omega), stepCurve_of_le (by omega)]
  · rw [stepCurve_of_le (by omega), stepCurve_of_le (by omega)]

/-! ## 4. The replication law and its sharpness -/

/-- **Replication law.**  If a second corpus's curve is uniformly `ε`-close to the
first and the first clears the gate at `k` with margin `> ε`, while missing it by
margin `> ε` at every smaller budget, then the second corpus has *exactly* the
same knee.  Identical knees across corpora are therefore forced by margins, not
a coincidence. -/
theorem knee_eq_of_uniform_close {eps : ℚ} {k : ℕ}
    (hclose : ∀ j, |A j - B j| ≤ eps)
    (hup : g + eps ≤ A k) (hdown : ∀ j < k, A j + eps < g) :
    knee B g = k := by
  refine Combinatorics.KneeInvariance.knee_eq_of ?_ ?_
  · have h := abs_le.mp (hclose k)
    linarith [h.1]
  · intro j hj
    have h := abs_le.mp (hclose j)
    have := hdown j hj
    linarith [h.2]

/-- Both corpora then report the same knee. -/
theorem knees_agree_of_close {eps : ℚ} {k : ℕ}
    (hclose : ∀ j, |A j - B j| ≤ eps)
    (hup : g + eps ≤ A k) (hdown : ∀ j < k, A j + eps < g) :
    knee A g = knee B g ∧ knee A g = k := by
  have heps0 : (0 : ℚ) ≤ eps := le_trans (abs_nonneg _) (hclose k)
  have hA : knee A g = k := by
    refine knee_eq_of_uniform_close (B := A) (fun j => by simpa using heps0) ?_ hdown
    linarith
  exact ⟨by rw [hA, knee_eq_of_uniform_close hclose hup hdown], hA⟩

/-- The measured corpus-B margins at `ctx = 2048`: the gate is cleared at `24` by
`0.0032` and missed at `20` by `0.0010`.  Hence **any** corpus whose retention
curve is uniformly within `ε = 0.0009` of corpus B's has knee exactly `24`:
the replication observed across the two wikitext shards is a theorem about the
measured margins. -/
theorem net64_replication_margin (C : ℕ → ℚ)
    (hclose : ∀ j, |corpusB j - C j| ≤ 9 / 10000) :
    knee C gate = 24 := by
  refine knee_eq_of_uniform_close hclose ?_ ?_
  · rw [corpusB_table.2.1]; unfold gate; norm_num
  · intro j hj
    have hle : corpusB j ≤ 9790 / 10000 := by
      have := monotone_corpusB (show j ≤ 23 by omega)
      rwa [corpusB_23] at this
    unfold gate
    linarith

/-- **The margin hypothesis cannot be dropped.**  For every tolerance `ε ∈ (0,1]`
and every target `N ≥ 1` there are two monotone curves within `ε` of each other
whose knees are `1` and `N`.  Uniform closeness alone says nothing about knees;
only a margin exceeding the noise level forces replication. -/
theorem margin_hypothesis_is_necessary (eps : ℚ) (heps : 0 < eps) (heps1 : eps ≤ 1)
    (N : ℕ) (hN : 1 ≤ N) :
    ∃ A B : ℕ → ℚ, Monotone A ∧ Monotone B ∧ (∀ k, |A k - B k| ≤ eps) ∧
      knee A 1 = 1 ∧ knee B 1 = N := by
  have hN0 : N ≠ 0 := by omega
  refine ⟨fun k => if k = 0 then 0 else 1,
          fun k => if k = 0 then 0 else if k < N then 1 - eps else 1, ?_, ?_, ?_, ?_, ?_⟩
  · intro x y hxy
    dsimp only
    by_cases hx : x = 0
    · rw [if_pos hx]
      split_ifs <;> norm_num
    · rw [if_neg hx, if_neg (by omega : ¬ y = 0)]
  · intro x y hxy
    dsimp only
    by_cases hx : x = 0
    · rw [if_pos hx]
      split_ifs <;> linarith
    · rw [if_neg hx, if_neg (by omega : ¬ y = 0)]
      split_ifs <;> linarith
  · intro k
    dsimp only
    by_cases hk : k = 0
    · rw [if_pos hk, if_pos hk]
      simpa using heps.le
    · rw [if_neg hk, if_neg hk]
      split_ifs
      · rw [show (1 : ℚ) - (1 - eps) = eps by ring, abs_of_nonneg heps.le]
      · simpa using heps.le
  · refine Combinatorics.KneeInvariance.knee_eq_of (by norm_num) ?_
    intro j hj
    have hj0 : j = 0 := by omega
    subst hj0
    norm_num
  · refine Combinatorics.KneeInvariance.knee_eq_of ?_ ?_
    · rw [if_neg hN0, if_neg (lt_irrefl N)]
    · intro j hj
      dsimp only
      split_ifs <;> linarith

/-! ## 5. Accuracy level and knee position are independent -/

/-- The **retention curve** derived from a raw accuracy sweep: quality at budget
`k` relative to the full-context model. -/
def retention (raw : ℕ → ℚ) (ctx : ℕ) (k : ℕ) : ℚ := raw k / raw ctx

/-- **Scale invariance of the knee.**  Multiplying the whole accuracy sweep by a
positive constant — an easier or harder corpus — leaves the retention curve, and
hence the knee, untouched. -/
theorem knee_retention_scale_invariant {raw : ℕ → ℚ} {c : ℚ} (hc : c ≠ 0) (ctx : ℕ)
    (g : ℚ) :
    knee (retention (fun k => c * raw k) ctx) g = knee (retention raw ctx) g := by
  have hfun : retention (fun k => c * raw k) ctx = retention raw ctx := by
    funext k
    simp [retention, mul_div_mul_left _ _ hc]
  rw [hfun]

/-- **The NET-64 baseline note, as a theorem.**  Corpus B's full-context accuracy
`0.4946` exceeds corpus A's `0.4760`; if the sweeps differ by exactly this
difficulty factor, the two knees are equal at every gate.  Accuracy level and
knee position are independent coordinates. -/
theorem net64_baseline_shift_fixes_knee (rawA : ℕ → ℚ) (ctx : ℕ) (g : ℚ) :
    knee (retention (fun k => (4946 / 4760 : ℚ) * rawA k) ctx) g
      = knee (retention rawA ctx) g :=
  knee_retention_scale_invariant (by norm_num) ctx g

end Catalog.Probability.NET64GridArtifact