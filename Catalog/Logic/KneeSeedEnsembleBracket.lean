/-
# Seed ensembles: what a finite number of seeds can and cannot certify (NET-44, cycle 2)

`Logic.KneeFluctuationTwoSeed` formalised the NET-44 measurement itself: two seeds at the
cell `(d = 4, ctx = 1024)` report knees `128` and `96`, so the exact product law
`k* = d·ctx/32` is refuted as an *equality* while surviving as an *upper bound*.

This file is the second cycle of the loop.  It asks the general question the round
raises: **what is the exact epistemic content of an `n`-seed sweep?**  The answers are
purely order-theoretic and completely proved.

* `KneeEnsemble.exists_isKnee` : a knee exists as soon as one grid point passes, so the
  measurement is always well defined; combined with `IsKnee.unique` the knee is a genuine
  function of the sweep.
* `KneeEnsemble.ensemble_max_is_safe` : the deployable budget certified by an ensemble is
  `max_i k*_i` — at that budget *every* seed clears the bar.  This is the abstract form of
  "the product law remains a proven-safe upper bound".
* `KneeEnsemble.ensemble_max_is_least_safe` : and it is the *least* such budget on the
  grid, so the ensemble maximum is exactly the certified deployment point — no sharper
  guarantee can be extracted from the same data.
* `KneeEnsemble.certified_budget_mono` : adding seeds can only push the certified budget
  up.  Guarantees degrade monotonically with evidence; a "law" fitted at one seed is the
  most optimistic reading a sweep can ever produce.
* `KneeEnsemble.exactness_of_uniform_margins` : a positive certificate.  If one seed's
  curve stays at distance `> η` from the bar at every grid point and all seeds lie within
  `η` of it, then *all* seeds have the same knee.  Exactness of a knee law is therefore a
  margin statement, not a luck statement — when the margins are there.
* `KneeEnsemble.knee_disagreement_forces_small_margin` : conversely, any seed-to-seed
  knee disagreement forces a grid point where the reference curve is within the spread of
  the bar.  Applied to the round: `net44_disagreement_margin` shows the NET-37/NET-44
  disagreement is *predicted* by the seed-1 margin `0.003 < 0.010 = spread`.
* `KneeEnsemble.ensemble_underdetermines_knee` : the negative metatheorem.  If the
  reference curve misses the bar by at most the spread at some grid point below its knee,
  then *no* number of seeds with that spread can certify the knee: an admissible curve
  with a strictly smaller knee always exists.  `net44_no_seed_count_certifies_128` is the
  instance: `k* = 128` at `(d = 4, ctx = 1024)` is not certifiable at spread `0.010`,
  however many seeds are run.
* `KneeEnsemble.net44_guarantee_floor`, `net44_best_case_speedup`, `net44_waste_ratio` :
  the deployment reading — guarantee floor `8×`, best case `32/3 ≈ 10.7×`, and a
  worst-case over-provisioning factor of exactly `4/3` when the certified budget `128` is
  used on a seed whose knee is `96`.
-/

import Mathlib
import Logic.KneeFluctuationTwoSeed

namespace KneeEnsemble

open Finset KneeFluctuation

/-! ## 1.  The knee is a well-defined functional of a sweep -/

/-- **Existence.**  If any grid point clears the bar, the sweep has a knee. -/
theorem exists_isKnee {G : Finset ℕ} {bar : ℝ} {c : ℕ → ℝ} {j : ℕ}
    (hj : j ∈ G) (hpass : bar ≤ c j) : ∃ k, IsKnee G bar c k := by
  classical
  set S := G.filter (fun x => bar ≤ c x) with hS
  have hne : S.Nonempty := ⟨j, by simp [hS, hj, hpass]⟩
  refine ⟨S.min' hne, (Finset.mem_filter.mp (S.min'_mem hne)).1,
    (Finset.mem_filter.mp (S.min'_mem hne)).2, ?_⟩
  intro i hi hip
  exact S.min'_le i (by simp [hS, hi, hip])

/-- The knee is unique when it exists, so a sweep determines at most one knee value. -/
theorem knee_eq_of_isKnee {G : Finset ℕ} {bar : ℝ} {c : ℕ → ℝ} {k k' : ℕ}
    (h : IsKnee G bar c k) (h' : IsKnee G bar c k') : k = k' := h.unique h'

/-! ## 2.  What an ensemble of seeds certifies -/

section Ensemble

variable {ι : Type*} [Fintype ι] [Nonempty ι] {G : Finset ℕ} {bar : ℝ}

/-- The budget certified by an ensemble of seeds: the largest of the measured knees. -/
noncomputable def certifiedBudget (K : ι → ℕ) : ℕ :=
  (Finset.univ.image K).max' ⟨K (Classical.arbitrary ι), by simp⟩

theorem le_certifiedBudget (K : ι → ℕ) (i : ι) : K i ≤ certifiedBudget K :=
  Finset.le_max' _ _ (by simp)

theorem certifiedBudget_mem_range (K : ι → ℕ) : ∃ i, certifiedBudget K = K i := by
  have h := Finset.max'_mem (Finset.univ.image K) ⟨K (Classical.arbitrary ι), by simp⟩
  simpa [certifiedBudget, eq_comm] using h

/-- **The certified budget is safe.**  Every seed clears the bar at `max_i k*_i`
(retained accuracy is monotone in the budget). -/
theorem ensemble_max_is_safe {c : ι → ℕ → ℝ} {K : ι → ℕ}
    (hmono : ∀ i, Monotone (c i)) (hknee : ∀ i, IsKnee G bar (c i) (K i)) (i : ι) :
    bar ≤ c i (certifiedBudget K) :=
  (hknee i).2.1.trans (hmono i (le_certifiedBudget K i))

/-- **And it is the least safe budget on the grid.**  Any grid budget at which all seeds
clear the bar is at least `max_i k*_i`; so the ensemble maximum is exactly the certified
deployment point, and nothing sharper follows from the same sweep. -/
theorem ensemble_max_is_least_safe {c : ι → ℕ → ℝ} {K : ι → ℕ} {b : ℕ}
    (hknee : ∀ i, IsKnee G bar (c i) (K i)) (hb : b ∈ G) (hsafe : ∀ i, bar ≤ c i b) :
    certifiedBudget K ≤ b := by
  obtain ⟨i, hi⟩ := certifiedBudget_mem_range K
  rw [hi]
  exact (hknee i).le_of_passes hb (hsafe i)

/-- **Evidence degrades guarantees.**  Enlarging the ensemble can only raise the
certified budget: a knee law fitted at a single seed is the most optimistic reading any
sweep can produce. -/
theorem certified_budget_mono {ι' : Type*} [Fintype ι'] [Nonempty ι']
    (K : ι → ℕ) (K' : ι' → ℕ) (f : ι → ι') (hf : ∀ i, K i = K' (f i)) :
    certifiedBudget K ≤ certifiedBudget K' := by
  obtain ⟨i, hi⟩ := certifiedBudget_mem_range K
  rw [hi, hf i]
  exact le_certifiedBudget K' (f i)

/-! ## 3.  When exactness *is* certified, and when it cannot be -/

/-- **Positive certificate.**  If a reference curve avoids an `η`-collar around the bar at
every grid point, then every seed within `η` of it has the *same* passing set, hence the
same knee.  Exactness of a measured law is a margin phenomenon. -/
theorem exactness_of_uniform_margins {r c : ℕ → ℝ} {η : ℝ} {k k' : ℕ}
    (hmargin : ∀ j ∈ G, η < |r j - bar|) (hclose : ∀ j ∈ G, |c j - r j| ≤ η)
    (hr : IsKnee G bar r k) (hc : IsKnee G bar c k') : k = k' := by
  have key : ∀ j ∈ G, (bar ≤ r j ↔ bar ≤ c j) := by
    intro j hj
    have hm := hmargin j hj
    have hcl := abs_le.mp (hclose j hj)
    by_cases hpos : bar ≤ r j
    · have : η < r j - bar := by rwa [abs_of_nonneg (by linarith)] at hm
      exact iff_of_true hpos (by linarith [hcl.1])
    · have hneg : r j < bar := not_le.mp hpos
      have : η < bar - r j := by
        rw [abs_of_neg (by linarith : r j - bar < 0)] at hm; linarith
      exact iff_of_false (not_le.mpr hneg) (by push_neg; linarith [hcl.2])
  refine le_antisymm (hr.le_of_passes hc.1 ((key _ hc.1).2 hc.2.1))
    (hc.le_of_passes hr.1 ((key _ hr.1).1 hr.2.1))

/-- **Contrapositive: disagreement exposes a small margin.**  If two seeds within `η` of a
reference curve report different knees, the reference must sit within `η` of the bar at
some grid point — the knee moved because there was no margin to protect it. -/
theorem knee_disagreement_forces_small_margin {r c : ℕ → ℝ} {η : ℝ} {k k' : ℕ}
    (hclose : ∀ j ∈ G, |c j - r j| ≤ η) (hr : IsKnee G bar r k) (hc : IsKnee G bar c k')
    (hne : k ≠ k') : ∃ j ∈ G, |r j - bar| ≤ η := by
  by_contra hcon
  push_neg at hcon
  exact hne (exactness_of_uniform_margins (fun j hj => hcon j hj) hclose hr hc)

/-- **Negative metatheorem.**  If the reference curve misses the bar by at most the
spread `η` at some grid point `g` strictly below its knee, then an admissible curve with
knee at most `g` exists — so *no* number of seeds at spread `η` can certify the knee.
The construction is the uniform shift `r + η`. -/
theorem ensemble_underdetermines_knee {r : ℕ → ℝ} {η : ℝ} {k g : ℕ}
    (hr : Monotone r) (hη : 0 ≤ η) (hg : g ∈ G) (hdef : bar - r g ≤ η) (hgk : g < k) :
    (∃ c' : ℕ → ℝ, Monotone c' ∧ (∀ x, |c' x - r x| ≤ η) ∧
      ∃ k', IsKnee G bar c' k' ∧ k' ≤ g ∧ k' ≠ k) ∧ ¬ RobustKnee G bar r k η := by
  have hmono' : Monotone (fun x => r x + η) :=
    fun _ _ hxy => by simpa using add_le_add_right (hr hxy) η
  have hclose' : ∀ x, |(r x + η) - r x| ≤ η := fun x => by
    have hx : (r x + η) - r x = η := by ring
    rw [hx, abs_of_nonneg hη]
  have hpass : bar ≤ r g + η := by linarith
  obtain ⟨k', hk'⟩ := exists_isKnee (bar := bar) (c := fun x => r x + η) hg hpass
  have hle : k' ≤ g := hk'.le_of_passes hg hpass
  refine ⟨⟨fun x => r x + η, hmono', hclose', k', hk', hle, by omega⟩, ?_⟩
  intro hrob
  have := hrob _ hmono' (fun j _ => hclose' j)
  exact absurd (hk'.unique this) (by omega)

end Ensemble

/-! ## 4.  The NET-44 instance -/

/-- The seed-1 margin at `k = 96` is `0.003`, inside the observed spread `0.010`: the
NET-37/NET-44 disagreement was *predicted* by the seed-1 sweep itself. -/
theorem net44_disagreement_margin {c : ℕ → ℝ} (h : Seed1Data c) :
    96 ∈ gridS1 ∧ |c 96 - bar| ≤ spread := by
  refine ⟨by decide, ?_⟩
  rw [h.at96]
  rw [abs_of_nonpos (by norm_num [bar])]
  norm_num [bar, spread]

/-- **No seed count certifies `k* = 128` at this cell.**  At spread `0.010` there is
always an admissible curve whose knee is at most `96`, so the exact product law is not
merely unproved at `(d = 4, ctx = 1024)` — it is *uncertifiable* from sweeps of this
precision. -/
theorem net44_no_seed_count_certifies_128 {c : ℕ → ℝ} (h : Seed1Data c) :
    ∃ c' : ℕ → ℝ, Monotone c' ∧ (∀ x, |c' x - c x| ≤ spread) ∧
      ∃ k', IsKnee gridS1 bar c' k' ∧ k' ≤ 96 ∧ k' ≠ 128 := by
  refine (ensemble_underdetermines_knee (G := gridS1) (bar := bar) (k := 128) h.mono
    (by norm_num [spread]) (by decide) ?_ (by norm_num)).1
  rw [h.at96]
  norm_num [bar, spread]

/-- Deployment floor: at the certified budget `128` the speedup is `8×` at `ctx = 1024`,
and this guarantee holds at both seeds. -/
theorem net44_guarantee_floor : speedup 1024 128 = 8 := by norm_num [speedup]

/-- Best case actually observed: the seed-2 knee `96` gives `32/3 ≈ 10.67×`. -/
theorem net44_best_case_speedup : speedup 1024 96 = 32 / 3 := by norm_num [speedup]

/-- Deploying the certified budget `128` on a seed whose knee is `96` over-provisions by
exactly the factor `4/3`; equivalently the certified speedup is `3/4` of the achievable
one. -/
theorem net44_waste_ratio :
    (128 : ℝ) / 96 = 4 / 3 ∧ speedup 1024 128 / speedup 1024 96 = 3 / 4 := by
  constructor
  · norm_num
  · rw [net44_guarantee_floor, net44_best_case_speedup]
    norm_num

/-- The two-seed ensemble at this cell: knees `{128, 96}`, certified budget `128`. -/
theorem net44_certified_budget_eq :
    certifiedBudget (fun b : Bool => if b then 128 else 96) = 128 := by
  have hle : certifiedBudget (fun b : Bool => if b then (128 : ℕ) else 96) ≤ 128 := by
    obtain ⟨i, hi⟩ := certifiedBudget_mem_range (fun b : Bool => if b then (128 : ℕ) else 96)
    rw [hi]
    cases i <;> norm_num
  have hge : (128 : ℕ) ≤ certifiedBudget (fun b : Bool => if b then (128 : ℕ) else 96) := by
    simpa using le_certifiedBudget (fun b : Bool => if b then (128 : ℕ) else 96) true
  omega

end KneeEnsemble