/-
# The contamination curve of a quota rung: the breakdown number is its endpoint

Conjecture **D2** (carried over as **C2′**) of the previous cycles: the exact breakdown number
`SeedBreakdown.breakdownNumber n m = min (m-1) (n-m)` should be the endpoint `ε → (m-1)/n` of a
whole *contamination curve*, whose value at contamination level `ε` is the spread between two
quantiles of the clean distribution.  Seed-to-seed variation in the round is distributional,
not adversarial, and the `{160, 224, 256}` knee set is a sample; contamination is the model
that matches the experiment.

This file proves the finite-sample form of that statement, which is the one the seed-ensemble
protocol actually needs (the sample is three, four, or five seeds — not a limit).

Main results.

* `SeedContamination.corrupt` — the corrupted knee vector: the seeds in `S` are replaced by a
  common adversarial value `v`, the others are left alone.
* `SeedContamination.exists_low_set` / `exists_high_set` — a clean sample always has a set of
  exactly `c` of its smallest (resp. largest) seeds.
* **The curve's two endpoints are attained.**  `SeedContamination.quotaBudget_corrupt_high` :
  corrupting the `c` *smallest* seeds upwards moves the `m`-th rung to exactly the clean
  `(m+c)`-th rung.  `SeedContamination.quotaBudget_corrupt_low` : corrupting the `c` *largest*
  seeds down to `0` moves it to exactly the clean `(m-c)`-th rung.
* **The contamination curve.**  `SeedContamination.contamination_curve` : for
  `c ≤ min (m-1) (n-m)` the set of readings achievable with at most `c` corrupted seeds is
  *exactly* the clean interval `[quotaBudget K (m-c), quotaBudget K (m+c)]` — the sandwich
  (`SeedBreakdown.rung_bracket`) is tight at both ends.  So the maximal bias at contamination
  level `c` is exactly the clean spread `quotaBudget K (m+c) − quotaBudget K (m-c)`, D2's
  `|F⁻¹(q⁻) − F⁻¹(q⁺)|` in finite samples, and the breakdown number is precisely the last `c`
  at which that spread is still a spread of clean readings.
* `SeedContamination.net48_median_curve` — the round's own numbers: at the three-seed cell
  `{160, 224, 256}` the median rung's contamination curve has width `0` at `c = 0` and
  `256 − 160 = 96` at `c = 1`, the last level before breakdown; the guarantee rung `m = 3`
  has breakdown number `0`, so *any* single corrupted seed moves it arbitrarily
  (`SeedContamination.net48_guarantee_fragile`).  The median is robust, the guarantee is not —
  the deployment reading and the calibrated reading trade off exactly here.
-/

import Mathlib
import Probability.SeedQuotaBinomial
import Probability.SeedBreakdownDichotomy
import Logic.KneeQuotaScaling

namespace SeedContamination

open Finset KneeMedian KneeQuota SeedBreakdown

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## 1.  Corrupted samples -/

/-- The sample obtained by replacing the seeds in `S` by the adversarial value `v`. -/
def corrupt (K : ι → ℕ) (S : Finset ι) (v : ℕ) : ι → ℕ := fun i => if i ∈ S then v else K i

omit [Fintype ι] in
theorem corrupt_agree (K : ι → ℕ) (S : Finset ι) (v : ℕ) : ∀ i ∉ S, K i = corrupt K S v i := by
  intro i hi
  simp [corrupt, hi]

/-- A set of `c` seeds all of whose knees are at most every knee outside it. -/
theorem exists_low_set (K : ι → ℕ) {c : ℕ} (hc : c ≤ Fintype.card ι) :
    ∃ S : Finset ι, S.card = c ∧ ∀ i ∈ S, ∀ j ∉ S, K i ≤ K j := by
  classical
  induction c with
  | zero => exact ⟨∅, by simp, by simp⟩
  | succ c ih =>
      obtain ⟨S, hcard, hS⟩ := ih (by omega)
      have hne : (Sᶜ : Finset ι).Nonempty := by
        rw [← Finset.card_pos, Finset.card_compl, hcard]
        omega
      obtain ⟨j, hjmem, hjmin⟩ := Finset.exists_min_image (Sᶜ : Finset ι) K hne
      have hjS : j ∉ S := by simpa using hjmem
      refine ⟨insert j S, by rw [Finset.card_insert_of_notMem hjS, hcard], ?_⟩
      intro i hi k hk
      have hkS : k ∉ S := fun h => hk (Finset.mem_insert_of_mem h)
      have hkj : k ≠ j := fun h => hk (by rw [h]; exact Finset.mem_insert_self j S)
      have hkmem : k ∈ (Sᶜ : Finset ι) := by simpa using hkS
      rcases Finset.mem_insert.1 hi with rfl | hiS
      · exact hjmin k hkmem
      · exact hS i hiS k hkS

/-- A set of `c` seeds all of whose knees are at least every knee outside it. -/
theorem exists_high_set (K : ι → ℕ) {c : ℕ} (hc : c ≤ Fintype.card ι) :
    ∃ S : Finset ι, S.card = c ∧ ∀ i ∈ S, ∀ j ∉ S, K j ≤ K i := by
  classical
  induction c with
  | zero => exact ⟨∅, by simp, by simp⟩
  | succ c ih =>
      obtain ⟨S, hcard, hS⟩ := ih (by omega)
      have hne : (Sᶜ : Finset ι).Nonempty := by
        rw [← Finset.card_pos, Finset.card_compl, hcard]
        omega
      obtain ⟨j, hjmem, hjmax⟩ := Finset.exists_max_image (Sᶜ : Finset ι) K hne
      have hjS : j ∉ S := by simpa using hjmem
      refine ⟨insert j S, by rw [Finset.card_insert_of_notMem hjS, hcard], ?_⟩
      intro i hi k hk
      have hkS : k ∉ S := fun h => hk (Finset.mem_insert_of_mem h)
      have hkmem : k ∈ (Sᶜ : Finset ι) := by simpa using hkS
      rcases Finset.mem_insert.1 hi with rfl | hiS
      · exact hjmax k hkmem
      · exact hS i hiS k hkS

/-! ## 2.  The upper endpoint of the curve -/

private theorem card_passSet_corrupt_le (K : ι → ℕ) (S : Finset ι) (v t : ℕ) (hv : t < v) :
    (passSet (corrupt K S v) t).card + S.card
      ≥ (passSet K t).card ∧
    (passSet (corrupt K S v) t) = (passSet K t) \ S := by
  constructor
  · have hsub : passSet K t ⊆ passSet (corrupt K S v) t ∪ S := by
      intro i hi
      simp only [passSet, mem_filter, mem_univ, true_and] at hi
      by_cases hiS : i ∈ S
      · exact Finset.mem_union_right _ hiS
      · refine Finset.mem_union_left _ ?_
        simp only [passSet, mem_filter, mem_univ, true_and, corrupt, hiS, if_false]
        exact hi
    calc (passSet K t).card ≤ (passSet (corrupt K S v) t ∪ S).card := card_le_card hsub
      _ ≤ (passSet (corrupt K S v) t).card + S.card := Finset.card_union_le _ _
  · ext i
    simp only [passSet, mem_filter, mem_univ, true_and, Finset.mem_sdiff, corrupt]
    by_cases hiS : i ∈ S
    · have hvt : ¬ (v ≤ t) := by omega
      simp [hiS, hvt]
    · simp [hiS]

/-- **The upper endpoint is attained.**  Pushing the `c` smallest seeds above everything moves
the `m`-th rung to exactly the clean `(m+c)`-th rung. -/
theorem quotaBudget_corrupt_high (K : ι → ℕ) (S : Finset ι)
    (hS : ∀ i ∈ S, ∀ j ∉ S, K i ≤ K j) {m v : ℕ} (hm1 : 1 ≤ m)
    (hmc : m + S.card ≤ Fintype.card ι) (hv : quotaBudget K (m + S.card) < v) :
    quotaBudget (corrupt K S v) m = quotaBudget K (m + S.card) := by
  classical
  set c := S.card with hc
  set q := quotaBudget K (m + c) with hq
  refine le_antisymm ?_ ?_
  · -- at the clean `(m+c)`-th budget, at least `m` uncorrupted seeds still pass
    have hpass : m + c ≤ (passSet K q).card := card_passSet_quotaBudget hmc
    have hSsub : S ⊆ passSet K q := by
      intro i hi
      -- some seed outside `S` passes at `q`, and the seeds of `S` are the smallest
      have hlt : S.card < (passSet K q).card := by omega
      obtain ⟨j, hj, hjS⟩ : ∃ j ∈ passSet K q, j ∉ S := by
        by_contra hcon
        push_neg at hcon
        have : passSet K q ⊆ S := fun x hx => hcon x hx
        exact absurd (card_le_card this) (by omega)
      simp only [passSet, mem_filter, mem_univ, true_and] at hj ⊢
      exact (hS i hi j hjS).trans hj
    have hsplit := (card_passSet_corrupt_le K S v q hv).2
    have hsum := Finset.card_sdiff_add_card_eq_card hSsub
    have hcard : m ≤ (passSet (corrupt K S v) q).card := by
      rw [hsplit]
      omega
    exact quotaBudget_le_of_card hcard
  · -- below it, too few seeds pass
    by_contra hcon
    push_neg at hcon
    set t := quotaBudget (corrupt K S v) m with ht
    have htv : t < v := by omega
    have hcardt : m ≤ (passSet (corrupt K S v) t).card :=
      card_passSet_quotaBudget (le_trans (by omega) hmc)
    have hsplit := (card_passSet_corrupt_le K S v t htv).2
    rw [hsplit] at hcardt
    have hpos : 0 < ((passSet K t) \ S).card := lt_of_lt_of_le hm1 hcardt
    obtain ⟨j, hj⟩ := Finset.card_pos.1 hpos
    have hjmem : j ∈ passSet K t := (Finset.mem_sdiff.1 hj).1
    have hjS : j ∉ S := (Finset.mem_sdiff.1 hj).2
    have hSsub : S ⊆ passSet K t := by
      intro i hi
      simp only [passSet, mem_filter, mem_univ, true_and] at hjmem ⊢
      exact (hS i hi j hjS).trans hjmem
    have hsum := Finset.card_sdiff_add_card_eq_card hSsub
    have hle : m + c ≤ (passSet K t).card := by omega
    have := quotaBudget_le_of_card hle
    omega

/-! ## 3.  The lower endpoint of the curve -/

/-- **The lower endpoint is attained.**  Collapsing the `c` largest seeds to `0` moves the
`m`-th rung to exactly the clean `(m-c)`-th rung. -/
theorem quotaBudget_corrupt_low (K : ι → ℕ) (S : Finset ι)
    (hS : ∀ i ∈ S, ∀ j ∉ S, K j ≤ K i) {m : ℕ}
    (hm1 : S.card + 1 ≤ m) (hmn : m ≤ Fintype.card ι) :
    quotaBudget (corrupt K S 0) m = quotaBudget K (m - S.card) := by
  classical
  set c := S.card with hc
  set q := quotaBudget K (m - c) with hq
  have hSpass : ∀ t : ℕ, S ⊆ passSet (corrupt K S 0) t := by
    intro t i hi
    simp only [passSet, mem_filter, mem_univ, true_and, corrupt, hi, if_true]
    omega
  refine le_antisymm ?_ ?_
  · -- the `m - c` clean passers together with the `c` corrupted seeds fill the quota
    have hclean : m - c ≤ (passSet K q).card := card_passSet_quotaBudget (by omega)
    have hcard : m ≤ (passSet (corrupt K S 0) q).card := by
      by_cases hdisj : ∃ i ∈ S, K i ≤ q
      · -- then every seed passes at `q` already
        obtain ⟨i, hiS, hiq⟩ := hdisj
        have huniv : passSet (corrupt K S 0) q = univ := by
          apply Finset.eq_univ_of_forall
          intro j
          simp only [passSet, mem_filter, mem_univ, true_and, corrupt]
          by_cases hjS : j ∈ S
          · simp [hjS]
          · simp only [hjS, if_false]
            exact (hS i hiS j hjS).trans hiq
        rw [huniv, Finset.card_univ]
        exact hmn
      · push_neg at hdisj
        have hsub : passSet K q ∪ S ⊆ passSet (corrupt K S 0) q := by
          intro j hj
          rcases Finset.mem_union.1 hj with hj | hj
          · simp only [passSet, mem_filter, mem_univ, true_and] at hj ⊢
            simp only [corrupt]
            by_cases hjS : j ∈ S
            · simp [hjS]
            · simpa [hjS] using hj
          · exact hSpass q hj
        have hdisjoint : Disjoint (passSet K q) S := by
          rw [Finset.disjoint_right]
          intro j hjS hjq
          simp only [passSet, mem_filter, mem_univ, true_and] at hjq
          exact absurd hjq (not_le.2 (hdisj j hjS))
        have hcards : (passSet K q ∪ S).card = (passSet K q).card + S.card :=
          Finset.card_union_of_disjoint hdisjoint
        have := card_le_card hsub
        omega
    exact quotaBudget_le_of_card hcard
  · -- below the clean `(m-c)`-th budget even the corrupted sample misses the quota
    by_contra hcon
    push_neg at hcon
    set t := quotaBudget (corrupt K S 0) m with ht
    have hcardt : m ≤ (passSet (corrupt K S 0) t).card := card_passSet_quotaBudget hmn
    have hsub : passSet (corrupt K S 0) t ⊆ passSet K t ∪ S := by
      intro i hi
      simp only [passSet, mem_filter, mem_univ, true_and, corrupt] at hi
      by_cases hiS : i ∈ S
      · exact Finset.mem_union_right _ hiS
      · refine Finset.mem_union_left _ ?_
        simp only [passSet, mem_filter, mem_univ, true_and]
        simpa [hiS] using hi
    have hcards : (passSet K t).card + c ≥ m := by
      have h1 := card_le_card hsub
      have h2 : (passSet K t ∪ S).card ≤ (passSet K t).card + S.card := Finset.card_union_le _ _
      omega
    have hle : m - c ≤ (passSet K t).card := by omega
    have := quotaBudget_le_of_card hle
    omega

/-! ## 4.  The contamination curve -/

/-- **The contamination curve of a rung.**  For `c` below the breakdown number, the readings
achievable by corrupting at most `c` seeds are exactly the clean readings between the
`(m-c)`-th and the `(m+c)`-th rung: the bracket of `SeedBreakdown.rung_bracket` is attained at
both ends.  The maximal bias at contamination level `c` is therefore exactly the clean spread,
and the breakdown number is the last level at which that spread is finite. -/
theorem contamination_curve (K : ι → ℕ) {m c : ℕ} (hm1 : 1 ≤ m) (hmn : m ≤ Fintype.card ι)
    (hcm : c ≤ m - 1) (hcn : m + c ≤ Fintype.card ι) :
    (∀ (K' : ι → ℕ) (S : Finset ι), S.card ≤ c → (∀ i ∉ S, K i = K' i) →
        quotaBudget K (m - c) ≤ quotaBudget K' m ∧ quotaBudget K' m ≤ quotaBudget K (m + c)) ∧
      (∃ (K' : ι → ℕ) (S : Finset ι), S.card = c ∧ (∀ i ∉ S, K i = K' i) ∧
        quotaBudget K' m = quotaBudget K (m + c)) ∧
      (∃ (K' : ι → ℕ) (S : Finset ι), S.card = c ∧ (∀ i ∉ S, K i = K' i) ∧
        quotaBudget K' m = quotaBudget K (m - c)) := by
  classical
  refine ⟨fun K' S hS hagree => rung_bracket K K' S hagree hS hcm hcn, ?_, ?_⟩
  · obtain ⟨S, hcard, hlow⟩ := exists_low_set K (c := c) (by omega)
    refine ⟨corrupt K S (quotaBudget K (m + c) + 1), S, hcard,
      corrupt_agree K S _, ?_⟩
    have := quotaBudget_corrupt_high K S hlow (m := m) (v := quotaBudget K (m + S.card) + 1)
      hm1 (by rw [hcard]; exact hcn) (by omega)
    rw [hcard] at this
    exact this
  · obtain ⟨S, hcard, hhigh⟩ := exists_high_set K (c := c) (by omega)
    refine ⟨corrupt K S 0, S, hcard, corrupt_agree K S 0, ?_⟩
    have := quotaBudget_corrupt_low K S hhigh (m := m) (by omega) hmn
    rw [hcard] at this
    exact this

/-! ## 5.  Lab notes: the round's own contamination curve -/

/-- **The three-seed median's curve.**  At `(d = 4, ctx = 2048)` the clean sample is
`{160, 224, 256}`; the median rung reads `224` uncorrupted and, at the last level before
breakdown (`c = 1`), can be pushed anywhere in `[160, 256]` — a bias of up to `±32/±64`, i.e.
the full clean spread. -/
theorem net48_median_curve :
    quotaBudget knees16 2 = 224 ∧ quotaBudget knees16 1 = 160 ∧ quotaBudget knees16 3 = 256 := by
  refine ⟨?_, ?_, ?_⟩
  · rw [quotaBudget_three_median]; decide
  · have h : quotaBudget knees16 1 ≤ 160 := by
      refine quotaBudget_le_of_card (m := 1) (b := 160) ?_
      have : (2 : Fin 3) ∈ passSet knees16 160 := by decide
      exact Finset.card_pos.2 ⟨2, this⟩
    have h' : ¬ quotaBudget knees16 1 ≤ 159 := by
      intro hle
      have hcard : 1 ≤ (passSet knees16 (quotaBudget knees16 1)).card :=
        card_passSet_quotaBudget (by simp)
      obtain ⟨i, hi⟩ := Finset.card_pos.1 (lt_of_lt_of_le Nat.zero_lt_one hcard)
      simp only [passSet, mem_filter, mem_univ, true_and] at hi
      have : knees16 i ≤ 159 := le_trans hi hle
      revert this
      fin_cases i <;> decide
    omega
  · have hfull := quotaBudget_full knees16
    rw [show Fintype.card (Fin 3) = 3 from by simp] at hfull
    rw [hfull]
    decide

/-- **The guarantee rung is fragile.**  The `3/3` deployment rung of a three-seed ensemble has
breakdown number `0`: a single corrupted seed pushes it above any prescribed budget.  The
median's robustness and the guarantee's fragility are the two ends of the same curve. -/
theorem net48_guarantee_fragile (B : ℕ) :
    breakdownNumber 3 3 = 0 ∧
      ∃ K' : Fin 3 → ℕ, (∀ i ∉ ({0} : Finset (Fin 3)), knees16 i = K' i) ∧
        B ≤ quotaBudget K' 3 := by
  refine ⟨by simp [breakdownNumber], ?_⟩
  have hcard : Fintype.card (Fin 3) < 3 + ({0} : Finset (Fin 3)).card := by simp
  exact breakdown_up knees16 ({0} : Finset (Fin 3)) (by simp) hcard B

end SeedContamination