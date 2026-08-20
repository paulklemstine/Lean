/-
# How robust is the tail bit itself?  (Cycle 2 of the low-tail experiment)

`Physics.LowTailDiagnostic` showed that the pending fourth seed is diagnostic for the
*tail* and carries no information about the *centre*.  The obvious adversarial follow-up —
raised by the Critic in cycle 2 — is that the tail bit may be diagnostic but worthless if it
is itself fragile.  This file measures exactly that.

The object is the **tail verdict** `m ≤ #{i | K i ≤ τ}`: "at least `m` of the seeds have
their knee in the tail region `k ≤ τ`".  It is a monotone Boolean threshold function of the
sample, and its finite-sample breakdown number — the least number of seeds an adversary must
re-run to flip the verdict — turns out to be the *slack* of the observed count against the
quota, in whichever direction the verdict currently points.

## Main results

* `verdict_stable_of_small_corruption`, `verdict_false_stable_of_small_corruption` — the two
  stability halves: a true verdict survives `countLE K τ - m` corruptions, a false one
  survives `m - countLE K τ - 1`.
* `verdict_flip_of_true`, `verdict_flip_of_false` — the matching attacks, both realised by
  moving seeds across the bar `τ` and no further.
* `verdictBreakdown_of_true`, `verdictBreakdown_of_false` — **the exact verdict breakdown
  number**: `count - m + 1` when the verdict holds, `m - count` when it fails.  Unlike the
  order-statistic breakdown number this depends on the *data*, not only on the design.
* `tail_verdict_four_breakdown` — **the sting.**  If the pending seed confirms the low tail
  (`160 ≤ x ≤ 192`), the resulting tail verdict has breakdown number `1`: a single re-run
  seed overturns it.  With `breakdown_four` this gives
  `tail_bit_is_more_fragile_than_centre`: the bit the experiment *can* measure is strictly
  less robust than the bit it cannot.
* `fifth_seed_lifts_both` — the fifth seed lifts the centre breakdown `2 → 3` and, if it
  lands in the tail, the tail-verdict breakdown `1 → 2`.  Both deficiencies identified in
  cycle 1 and cycle 2 are cured by the same additional run.
-/
import Physics.LowTailDiagnostic

namespace Catalog.Physics.LowTail

open Finset

section General

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## 1.  The tail verdict -/

/-- The **tail verdict**: at least `m` sample points lie at or below the bar `τ`. -/
def TailVerdict (K : ι → ℤ) (τ : ℤ) (m : ℕ) : Prop := m ≤ countLE K τ

/-- A true verdict survives any corruption smaller than its slack. -/
theorem verdict_stable_of_small_corruption {K K' : ι → ℤ} {S : Finset ι} {τ : ℤ} {m : ℕ}
    (hagree : ∀ i ∉ S, K i = K' i) (hS : S.card + m ≤ countLE K τ) :
    TailVerdict K' τ m := by
  have := countLE_le_perturb (K := K) (K' := K') (S := S) hagree τ
  rw [TailVerdict]
  omega

/-- A false verdict survives any corruption smaller than its deficit. -/
theorem verdict_false_stable_of_small_corruption {K K' : ι → ℤ} {S : Finset ι} {τ : ℤ} {m : ℕ}
    (hagree : ∀ i ∉ S, K i = K' i) (hS : countLE K τ + S.card < m) : ¬ TailVerdict K' τ m := by
  have := countLE_le_perturb (K := K') (K' := K) (S := S) (fun i hi => (hagree i hi).symm) τ
  rw [TailVerdict]
  omega

/-! ## 2.  The attacks -/

/-- **Flipping a true verdict.**  Re-running the `count - m + 1` cheapest seeds — moving each
just across the bar — destroys the verdict. -/
theorem verdict_flip_of_true {K : ι → ℤ} {τ : ℤ} {m : ℕ} (hm : 1 ≤ m)
    (hV : TailVerdict K τ m) :
    ∃ (K' : ι → ℤ) (S : Finset ι), S.card = countLE K τ - m + 1 ∧ (∀ i ∉ S, K i = K' i) ∧
      ¬ TailVerdict K' τ m := by
  classical
  rw [TailVerdict] at hV
  obtain ⟨S, hSsub, hScard⟩ := exists_subset_card_eq
    (s := univ.filter (fun i => K i ≤ τ)) (n := countLE K τ - m + 1) (by rw [← countLE]; omega)
  refine ⟨fun i => if i ∈ S then τ + 1 else K i, S, hScard, fun i hi => by simp [hi], ?_⟩
  have hfilter : univ.filter (fun i => (if i ∈ S then τ + 1 else K i) ≤ τ) =
      (univ.filter (fun i => K i ≤ τ)) \ S := by
    ext i
    simp only [mem_filter, mem_univ, true_and, mem_sdiff]
    by_cases h : i ∈ S <;> simp [h]
  have hcard : countLE (fun i => if i ∈ S then τ + 1 else K i) τ = countLE K τ - S.card := by
    rw [countLE, hfilter, card_sdiff_of_subset hSsub, ← countLE]
  rw [TailVerdict, hcard, hScard]
  omega

/-- **Flipping a false verdict.**  Re-running `m - count` seeds that currently miss the bar —
moving each just onto it — creates the verdict. -/
theorem verdict_flip_of_false {K : ι → ℤ} {τ : ℤ} {m : ℕ} (hm : m ≤ Fintype.card ι)
    (hV : ¬ TailVerdict K τ m) :
    ∃ (K' : ι → ℤ) (S : Finset ι), S.card = m - countLE K τ ∧ (∀ i ∉ S, K i = K' i) ∧
      TailVerdict K' τ m := by
  classical
  rw [TailVerdict] at hV
  push_neg at hV
  have hcompl : (univ \ univ.filter (fun i => K i ≤ τ)).card = Fintype.card ι - countLE K τ := by
    rw [card_sdiff_of_subset (filter_subset _ _), card_univ, ← countLE]
  obtain ⟨S, hSsub, hScard⟩ := exists_subset_card_eq
    (s := univ \ univ.filter (fun i => K i ≤ τ)) (n := m - countLE K τ) (by rw [hcompl]; omega)
  refine ⟨fun i => if i ∈ S then τ else K i, S, hScard, fun i hi => by simp [hi], ?_⟩
  have hdisj : Disjoint (univ.filter (fun i => K i ≤ τ)) S := by
    refine disjoint_left.2 fun i hi hiS => ?_
    have := hSsub hiS
    simp only [mem_sdiff, mem_univ, true_and] at this
    exact this hi
  have hfilter : univ.filter (fun i => (if i ∈ S then τ else K i) ≤ τ) =
      (univ.filter (fun i => K i ≤ τ)) ∪ S := by
    ext i
    simp only [mem_filter, mem_univ, true_and, mem_union]
    by_cases h : i ∈ S <;> simp [h]
  have hcard : countLE (fun i => if i ∈ S then τ else K i) τ = countLE K τ + S.card := by
    rw [countLE, hfilter, card_union_of_disjoint hdisj, ← countLE]
  rw [TailVerdict, hcard, hScard]
  omega

/-! ## 3.  The verdict breakdown number -/

/-- The least number of seeds an adversary must re-run in order to flip the tail verdict. -/
noncomputable def verdictBreakdown (K : ι → ℤ) (τ : ℤ) (m : ℕ) : ℕ :=
  sInf {c | ∃ (K' : ι → ℤ) (S : Finset ι), S.card ≤ c ∧ (∀ i ∉ S, K i = K' i) ∧
    ¬ (TailVerdict K' τ m ↔ TailVerdict K τ m)}

/-- **Exact verdict breakdown number, true case.**  A verdict that holds with slack
`count - m` is overturned by exactly `count - m + 1` re-runs. -/
theorem verdictBreakdown_of_true {K : ι → ℤ} {τ : ℤ} {m : ℕ} (hm : 1 ≤ m)
    (hV : TailVerdict K τ m) : verdictBreakdown K τ m = countLE K τ - m + 1 := by
  have hmem : ∃ (K' : ι → ℤ) (S : Finset ι), S.card ≤ countLE K τ - m + 1 ∧
      (∀ i ∉ S, K i = K' i) ∧ ¬ (TailVerdict K' τ m ↔ TailVerdict K τ m) := by
    obtain ⟨K', S, hScard, hagree, hflip⟩ := verdict_flip_of_true hm hV
    exact ⟨K', S, by omega, hagree, fun h => hflip (h.2 hV)⟩
  refine le_antisymm (Nat.sInf_le hmem) (le_csInf ⟨_, hmem⟩ ?_)
  rintro c ⟨K', S, hScard, hagree, hflip⟩
  by_contra hcon
  push_neg at hcon
  have hV' : TailVerdict K' τ m := by
    refine verdict_stable_of_small_corruption hagree ?_
    rw [TailVerdict] at hV
    omega
  exact hflip ⟨fun _ => hV, fun _ => hV'⟩

/-- **Exact verdict breakdown number, false case.**  A verdict that fails by a deficit of
`m - count` is created by exactly `m - count` re-runs. -/
theorem verdictBreakdown_of_false {K : ι → ℤ} {τ : ℤ} {m : ℕ} (hm : m ≤ Fintype.card ι)
    (hV : ¬ TailVerdict K τ m) : verdictBreakdown K τ m = m - countLE K τ := by
  have hlt : countLE K τ < m := by
    rw [TailVerdict] at hV; omega
  have hmem : ∃ (K' : ι → ℤ) (S : Finset ι), S.card ≤ m - countLE K τ ∧
      (∀ i ∉ S, K i = K' i) ∧ ¬ (TailVerdict K' τ m ↔ TailVerdict K τ m) := by
    obtain ⟨K', S, hScard, hagree, hflip⟩ := verdict_flip_of_false hm hV
    exact ⟨K', S, by omega, hagree, fun h => hV (h.1 hflip)⟩
  refine le_antisymm (Nat.sInf_le hmem) (le_csInf ⟨_, hmem⟩ ?_)
  rintro c ⟨K', S, hScard, hagree, hflip⟩
  by_contra hcon
  push_neg at hcon
  have hV' : ¬ TailVerdict K' τ m :=
    verdict_false_stable_of_small_corruption hagree (by omega)
  exact hflip ⟨fun h => absurd h hV', fun h => absurd h hV⟩

end General

/-! ## 4.  The NET-48 tail verdict -/

theorem countLE_fin4 (K : Fin 4 → ℤ) (w : ℤ) :
    countLE K w = (if K 0 ≤ w then 1 else 0) + (if K 1 ≤ w then 1 else 0) +
      (if K 2 ≤ w then 1 else 0) + (if K 3 ≤ w then 1 else 0) := by
  rw [countLE, card_filter, Fin.sum_univ_four]

theorem countLE_fin5 (K : Fin 5 → ℤ) (w : ℤ) :
    countLE K w = (if K 0 ≤ w then 1 else 0) + (if K 1 ≤ w then 1 else 0) +
      (if K 2 ≤ w then 1 else 0) + (if K 3 ≤ w then 1 else 0) + (if K 4 ≤ w then 1 else 0) := by
  rw [countLE, card_filter, Fin.sum_univ_five]

/-- The tail count of the four-seed ensemble, over `ℤ`: two seeds in the tail exactly when
the fourth seed clears the bar `192 = (3/4) P`. -/
theorem countLE_knees4 {x : ℤ} (hx : x ≤ 192) : countLE (knees4 x) 192 = 2 := by
  rw [countLE_fin4]
  simp only [knees4, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
  norm_num [hx]

/-- The tail count of the five-seed ensemble `{256, 224, 160, 192, 160}`: three seeds in the
tail. -/
theorem countLE_knees5 : countLE (knees5 192 160) 192 = 3 := by
  rw [countLE_fin5]
  simp only [knees5, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.cons_val_three, Matrix.cons_val_four, Matrix.tail_cons]
  norm_num

/-- **The tail bit rests on a single seed.**  If the pending fourth seed confirms the low
tail, the resulting "two of four seeds in the tail" verdict is overturned by re-running one
seed.  The experiment answers the tail question, but with the smallest possible margin. -/
theorem tail_verdict_four_breakdown {x : ℤ} (hx : x ≤ 192) :
    verdictBreakdown (knees4 x) 192 2 = 1 := by
  have hcount := countLE_knees4 hx
  have hV : TailVerdict (knees4 x) 192 2 := by rw [TailVerdict, hcount]
  rw [verdictBreakdown_of_true (by omega) hV, hcount]

/-- **The tail bit is strictly more fragile than the centre.**  One re-run seed overturns the
tail verdict; two are needed to move the centre out of the measured range.  The fourth seed
is diagnostic for the tail (`tail_not_a_function_of_fermatWeber_centre`) precisely where the
design is weakest. -/
theorem tail_bit_is_more_fragile_than_centre {x : ℤ} (hx : x ≤ 192) :
    verdictBreakdown (knees4 x) 192 2 < breakdownNumber (knees4 x) 2 := by
  rw [tail_verdict_four_breakdown hx, breakdown_four]
  omega

/-- **The fifth seed cures both deficits at once.**  If a fifth seed also lands in the tail,
the tail verdict acquires slack `1` (breakdown `2`) and the centre acquires breakdown `3`;
both strictly exceed the corresponding four-seed values, which are `1` and `2` for every
possible fourth seed. -/
theorem fifth_seed_lifts_both :
    verdictBreakdown (knees5 192 160) 192 2 = 2 ∧ breakdownNumber (knees5 192 160) 3 = 3 ∧
      ∀ x : ℤ, x ≤ 192 →
        verdictBreakdown (knees4 x) 192 2 < verdictBreakdown (knees5 192 160) 192 2 ∧
        breakdownNumber (knees4 x) 2 < breakdownNumber (knees5 192 160) 3 := by
  have hV : TailVerdict (knees5 192 160) 192 2 := by
    rw [TailVerdict, countLE_knees5]; omega
  have h5 : verdictBreakdown (knees5 192 160) 192 2 = 2 := by
    rw [verdictBreakdown_of_true (by omega) hV, countLE_knees5]
  refine ⟨h5, breakdown_five 192 160, fun x hx => ⟨?_, ?_⟩⟩
  · rw [tail_verdict_four_breakdown hx, h5]; omega
  · rw [breakdown_four, breakdown_five]; omega

/-- **A seed-specific outcome is equally marginal in the other direction.**  If the fourth
seed lands above the bar, the tail verdict fails by a deficit of one, so a single re-run
would create it.  Four seeds cannot separate the two hypotheses by more than one seed either
way — the formal reason the plan calls the fourth seed *diagnostic* rather than *decisive*. -/
theorem tail_verdict_four_breakdown_false {x : ℤ} (hx : 192 < x) :
    verdictBreakdown (knees4 x) 192 2 = 1 := by
  have hcount : countLE (knees4 x) 192 = 1 := by
    rw [countLE_fin4]
    simp only [knees4, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
      Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
    have hnx : ¬ (x ≤ 192) := by omega
    norm_num [hnx]
  have hV : ¬ TailVerdict (knees4 x) 192 2 := by
    rw [TailVerdict, hcount]; omega
  rw [verdictBreakdown_of_false (by simp) hV, hcount]

end Catalog.Physics.LowTail