/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Why the smoke-leg bootstrap degenerated, and what that forces about the event count

Context (experiment 569, paper 216).  The run's ledger records a `NaN` verdict field on the
smoke leg and attributes it to a "starved-regime bootstrap": fewer than `100` of the
`NB = 2000` cluster resamples were non-degenerate, so the percentile bounds were `NaN` and
`excludes_1` was trivially `True`.  This file turns that anecdote into a theorem about the
resampling scheme itself.

A cluster bootstrap over `m` clusters draws a resample uniformly from the `m ^ m` functions
`Fin m → Fin m`.  Call a cluster an *event cluster* if it carries at least one smooth hit;
a resample is *degenerate* exactly when it selects no event cluster, since then both the
candidate and the control tallies vanish and the ratio is `0/0`.

Main results:

* `U9Drift.card_event_free_resamples` — exactly `(m - h) ^ m` of the `m ^ m` resamples avoid a
  fixed set of `h` event clusters (an exact count, proved by identifying the filtered set with
  a `Fintype.piFinset`).
* `U9Drift.degenerateFrac_eq` — hence the degenerate fraction is exactly `(1 - h/m) ^ m`.
* `U9Drift.degenerateFrac_le_exp` — the sharp exponential bound `(1 - h/m) ^ m ≤ exp (-h)`,
  uniform in the cluster count `m`.
* `U9Drift.nondegenerate_fraction_ge` — consequently a *single* event cluster already forces
  at least a `0.632` fraction of non-degenerate resamples, whatever `m` is.
* `U9Drift.starved_nan_requires_event_free_population` — therefore the observed smoke-leg
  behaviour (fewer than `100` of `2000` expected non-degenerate resamples) is impossible with
  even one event cluster: the `NaN` is not resampling bad luck but reports a population with
  no smooth hit at all.  This is exactly why the ledger's "non-canonical, full-run verdict
  governs" ruling is the correct one — the smoke-leg interval carries no information about
  the ratio, rather than carrying a wide one.
-/

namespace U9Drift

open Finset

/-- Exact count of cluster-bootstrap resamples avoiding a fixed set `H` of clusters.  A
resample is a function `Fin m → Fin m` (draw `m` cluster indices with replacement), so the
resamples missing `H` are exactly the functions into the complement of `H`. -/
theorem card_event_free_resamples {m : ℕ} (H : Finset (Fin m)) :
    (univ.filter fun f : Fin m → Fin m => ∀ i, f i ∉ H).card = (m - H.card) ^ m := by
  have hset : (univ.filter fun f : Fin m → Fin m => ∀ i, f i ∉ H)
      = Fintype.piFinset (fun _ : Fin m => Hᶜ) := by
    ext f
    simp [Fintype.mem_piFinset]
  rw [hset, Fintype.card_piFinset]
  simp [Finset.card_compl]

/-- The fraction of degenerate (event-free) resamples in a cluster bootstrap over `m`
clusters of which `h` carry an event. -/
noncomputable def degenerateFrac (m h : ℕ) : ℝ := ((m - h : ℕ) : ℝ) ^ m / (m : ℝ) ^ m

/-- The degenerate fraction is exactly `(1 - h/m) ^ m`. -/
theorem degenerateFrac_eq {m h : ℕ} (hm : 0 < m) (hh : h ≤ m) :
    degenerateFrac m h = (1 - (h : ℝ) / m) ^ m := by
  have hm0 : (m : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hm.ne'
  have hcast : ((m - h : ℕ) : ℝ) = (m : ℝ) - h := Nat.cast_sub hh
  rw [degenerateFrac, hcast, ← div_pow]
  congr 1
  field_simp

/-- The uniform exponential bound: whatever the number of clusters, the degenerate fraction
is at most `exp (-h)` in the event-cluster count `h`. -/
theorem degenerateFrac_le_exp {m h : ℕ} (hm : 0 < m) (hh : h ≤ m) :
    degenerateFrac m h ≤ Real.exp (-(h : ℝ)) := by
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  have hle : (h : ℝ) / m ≤ 1 := by
    rw [div_le_one hm0]; exact_mod_cast hh
  have hnonneg : (0 : ℝ) ≤ 1 - (h : ℝ) / m := by linarith
  have hstep : 1 - (h : ℝ) / m ≤ Real.exp (-((h : ℝ) / m)) := by
    have := Real.add_one_le_exp (-((h : ℝ) / m))
    linarith
  calc degenerateFrac m h = (1 - (h : ℝ) / m) ^ m := degenerateFrac_eq hm hh
    _ ≤ (Real.exp (-((h : ℝ) / m))) ^ m := by
        exact pow_le_pow_left₀ hnonneg hstep m
    _ = Real.exp (-(h : ℝ)) := by
        rw [← Real.exp_nat_mul]
        congr 1
        field_simp

/-- A single event cluster already guarantees that more than a `0.632` fraction of the
resamples are non-degenerate, uniformly in the number of clusters. -/
theorem nondegenerate_fraction_ge {m h : ℕ} (hm : 0 < m) (hh : h ≤ m) (hpos : 1 ≤ h) :
    (0.632 : ℝ) ≤ 1 - degenerateFrac m h := by
  have hexp : Real.exp (-(h : ℝ)) ≤ Real.exp (-(1 : ℝ)) := by
    apply Real.exp_le_exp.mpr
    have : (1 : ℝ) ≤ (h : ℝ) := by exact_mod_cast hpos
    linarith
  have he1 : Real.exp (-(1 : ℝ)) ≤ 0.368 := by
    rw [Real.exp_neg, inv_le_comm₀ (Real.exp_pos 1) (by norm_num)]
    have h1 := Real.exp_one_gt_d9
    have h2 : ((0.368 : ℝ))⁻¹ ≤ 2.7182818283 := by norm_num
    linarith
  have := degenerateFrac_le_exp hm hh
  linarith

/-- The smoke-leg `NaN` is not resampling bad luck.  With `NB = 2000` resamples, fewer than
`100` expected non-degenerate resamples is incompatible with the presence of even one event
cluster; it forces `h = 0`, i.e. a population with no smooth hit at all. -/
theorem starved_nan_requires_event_free_population {m h : ℕ} (hm : 0 < m) (hh : h ≤ m)
    (hstarved : 2000 * (1 - degenerateFrac m h) < 100) : h = 0 := by
  by_contra hne
  have hpos : 1 ≤ h := Nat.one_le_iff_ne_zero.mpr hne
  have := nondegenerate_fraction_ge hm hh hpos
  linarith

/-- Conversely, in the event-free regime every resample is degenerate: the bootstrap
distribution is a point mass on the undefined ratio, so no percentile bound exists. -/
theorem degenerateFrac_of_no_event (m : ℕ) : degenerateFrac m 0 = 1 := by
  simp [degenerateFrac]

end U9Drift