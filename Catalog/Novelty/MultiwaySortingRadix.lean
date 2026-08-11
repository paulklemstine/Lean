import Physics.SortingThermodynamics.EntropyWork

/-!
# Multiway comparison sorting: radix, depth, and the reset ledger

This file advances the sorting-thermodynamics thread by settling two of its open
conjectures in a precise transcript model:

* **Multiway comparisons and optimal radix.** If every query has at most `q` outcomes,
  then any correct sorter of `n` items needs depth at least `⌈log_q (n!)⌉`
  (`Sorter.clog_le_depth`), the bound is achieved (`exists_sorter_clog_depth`), and the
  *physical* charge `depth · kT log q` is bounded below by `kT log (n!)` for **every**
  radix `q` (`radix_independent_work_lower_bound`), and exceeds it by less than one query
  for the optimal-depth sorter (`optimal_radix_work_sandwich`).  Changing the radix trades
  depth against information per query and does not move the reversible information balance.

* **Explicit reset registers.** The Landauer cost of resetting the transcript register is
  governed by the *entropy of the transcript given the output*, i.e. by the cardinality of
  the transcript image, not by the transcript length: `transcript_reset_work_eq_landauer`
  identifies it with the catalog's `landauerGap (sortingFunction n) kT`, and
  `resetWork_duplicate` shows that logically correlated (duplicated) registers are free.

## Model

A sorting algorithm using `d` queries of radix `q` assigns to every input ordering the
sequence of query answers it observes: its *transcript* `Fin d → Fin q`.  Since the sorted
output carries no information about the input ordering (all inputs produce the same sorted
list), a correct algorithm must be able to reconstruct the input permutation from the
transcript alone; equivalently, the transcript map is injective.  This is exactly the
information that a physical implementation must eventually reset.
-/

open Finset

namespace MultiwaySorting

/-- A transcript of `d` queries, each with `q` possible outcomes. -/
abbrev Transcript (q d : ℕ) := Fin d → Fin q

/-- A **correct radix-`q`, depth-`d` sorter** for `n` items: it records, for each input
ordering, the transcript of the `d` queries it performs, and the input ordering is
recoverable from the transcript (correctness, since the sorted output is constant). -/
structure Sorter (n q d : ℕ) where
  /-- The transcript produced on a given input ordering. -/
  transcript : Equiv.Perm (Fin n) → Transcript q d
  /-- Correctness: the transcript determines the input ordering. -/
  correct : Function.Injective transcript

/-- There are exactly `q ^ d` transcripts of depth `d` and radix `q`. -/
theorem card_transcript (q d : ℕ) : Fintype.card (Transcript q d) = q ^ d := by
  simp [Transcript]

/-- **Counting bound.** A correct radix-`q` sorter of depth `d` forces `n! ≤ q ^ d`. -/
theorem Sorter.factorial_le_pow {n q d : ℕ} (S : Sorter n q d) : n.factorial ≤ q ^ d := by
  have h := Fintype.card_le_of_injective _ S.correct
  rwa [perm_card, card_transcript] at h

/-- **Multiway depth lower bound.** Every correct sorter whose queries have at most `q ≥ 2`
outcomes performs at least `⌈log_q (n!)⌉` queries in the worst case. -/
theorem Sorter.clog_le_depth {n q d : ℕ} (hq : 1 < q) (S : Sorter n q d) :
    Nat.clog q n.factorial ≤ d :=
  (Nat.clog_le_iff_le_pow hq).2 S.factorial_le_pow

/-- **Tightness of the multiway bound.** For every radix `q ≥ 2` there is a correct sorter
of depth exactly `⌈log_q (n!)⌉`: the counting bound is achieved. -/
theorem exists_sorter_clog_depth (n : ℕ) {q : ℕ} (hq : 1 < q) :
    Nonempty (Sorter n q (Nat.clog q n.factorial)) := by
  have hcard : Fintype.card (Equiv.Perm (Fin n)) ≤ Fintype.card (Transcript q (Nat.clog q n.factorial)) := by
    rw [perm_card, card_transcript]
    exact Nat.le_pow_clog hq _
  obtain ⟨e⟩ := Function.Embedding.nonempty_of_card_le hcard
  exact ⟨⟨e, e.injective⟩⟩

/-- **Depth is antitone in the radix.**  A larger radix needs no more queries: the optimal
depth `⌈log_q (n!)⌉` decreases as `q` grows. -/
theorem optimal_depth_anti_radix {q q' : ℕ} (hq : 1 < q) (hqq : q ≤ q') (n : ℕ) :
    Nat.clog q' n.factorial ≤ Nat.clog q n.factorial :=
  Nat.clog_anti_left hq hqq

/-- Verified small-case table for `n = 5` (`5! = 120`): the optimal depths at radices
`2, 3, 4, 5, 10` are `7, 5, 4, 3, 3`.  Depth falls with the radix, while the work ledger
`d · log q` stays inside `[log 120, log 120 + log q)` — see `optimal_radix_work_sandwich`. -/
theorem optimal_depth_table_five :
    Nat.clog 2 (Nat.factorial 5) = 7 ∧ Nat.clog 3 (Nat.factorial 5) = 5 ∧
      Nat.clog 4 (Nat.factorial 5) = 4 ∧ Nat.clog 5 (Nat.factorial 5) = 3 ∧
      Nat.clog 10 (Nat.factorial 5) = 3 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> decide

/-! ## The physical work ledger -/

/-- A radix-`q` query register holds `log q` nats; a depth-`d` transcript therefore costs
`d · kT log q` if every query register is charged in full. -/
noncomputable def naiveTranscriptWork (kT : ℝ) (q d : ℕ) : ℝ := d * (kT * Real.log q)

/-- **Radix independence of the work lower bound.** For every radix `q ≥ 2`, charging
`kT log q` per fully erased query register gives a total at least `kT log (n!)`: the
information balance of sorting does not depend on the query radix. -/
theorem radix_independent_work_lower_bound {n q d : ℕ} (S : Sorter n q d)
    {kT : ℝ} (hkT : 0 ≤ kT) :
    kT * Real.log n.factorial ≤ naiveTranscriptWork kT q d := by
  have hcast : (n.factorial : ℝ) ≤ (q : ℝ) ^ d := by
    exact_mod_cast S.factorial_le_pow
  have hpos : (0 : ℝ) < n.factorial := by
    exact_mod_cast n.factorial_pos
  have hlog : Real.log n.factorial ≤ (d : ℝ) * Real.log q := by
    calc Real.log n.factorial ≤ Real.log ((q : ℝ) ^ d) := Real.log_le_log hpos hcast
      _ = (d : ℝ) * Real.log q := Real.log_pow _ _
  calc kT * Real.log n.factorial ≤ kT * ((d : ℝ) * Real.log q) :=
        mul_le_mul_of_nonneg_left hlog hkT
    _ = naiveTranscriptWork kT q d := by unfold naiveTranscriptWork; ring

/-- **Optimal-radix sandwich.** For the depth-optimal sorter, the naive per-register charge
exceeds the Landauer baseline `kT log (n!)` by strictly less than the cost `kT log q` of a
single query register — for every radix `q ≥ 2`.  Thus radix trades depth against
information per query without changing the ideal total work. -/
theorem optimal_radix_work_sandwich {n q : ℕ} (hq : 1 < q) (hn : 2 ≤ n) {kT : ℝ}
    (hkT : 0 < kT) :
    naiveTranscriptWork kT q (Nat.clog q n.factorial)
      < kT * Real.log n.factorial + kT * Real.log q := by
  have hfac : 1 < n.factorial := by
    calc 1 < 2 := by norm_num
      _ ≤ n := hn
      _ ≤ n.factorial := Nat.self_le_factorial n
  have hclog : 1 ≤ Nat.clog q n.factorial := Nat.clog_pos hq hfac
  have hlt : q ^ (Nat.clog q n.factorial - 1) < n.factorial := Nat.pow_pred_clog_lt_self hq hfac
  have hcast : ((q : ℝ)) ^ (Nat.clog q n.factorial - 1) < (n.factorial : ℝ) := by
    exact_mod_cast hlt
  have hqpos : (0 : ℝ) < q := by positivity
  have hlogq : 0 < Real.log q := Real.log_pos (by exact_mod_cast hq)
  have hstep : ((Nat.clog q n.factorial : ℝ) - 1) * Real.log q < Real.log n.factorial := by
    have hcastsub : ((Nat.clog q n.factorial - 1 : ℕ) : ℝ) = (Nat.clog q n.factorial : ℝ) - 1 := by
      have : (1 : ℕ) ≤ Nat.clog q n.factorial := hclog
      push_cast [Nat.cast_sub this]
      ring
    have := Real.log_lt_log (by positivity) hcast
    rwa [Real.log_pow, hcastsub] at this
  have : (Nat.clog q n.factorial : ℝ) * Real.log q < Real.log n.factorial + Real.log q := by
    nlinarith [hstep]
  unfold naiveTranscriptWork
  nlinarith [this, hkT]

/-! ## Reset registers: cost of erasure is image entropy, not transcript length -/

/-- The work needed to reset a register holding the value `T a`, in nats: `kT` times the
logarithm of the number of distinct values the register can hold on the given input set.
This is the conditional entropy of the transcript given the (constant) sorted output. -/
noncomputable def resetWork {α τ : Type*} [Fintype α] [DecidableEq τ] (kT : ℝ) (T : α → τ) : ℝ :=
  kT * Real.log ((Finset.univ.image T).card)

/-- **Duplicated (logically correlated) registers are free.** Writing the transcript twice
doubles the transcript length but does not change its reset cost. -/
theorem resetWork_duplicate {α τ : Type*} [Fintype α] [DecidableEq τ] (kT : ℝ) (T : α → τ) :
    resetWork kT (fun a => (T a, T a)) = resetWork kT T := by
  unfold resetWork
  congr 2
  have himg : (Finset.univ.image (fun a => (T a, T a)))
      = (Finset.univ.image T).image (fun t => (t, t)) := by
    rw [Finset.image_image]; rfl
  rw [himg, Finset.card_image_of_injective _ (fun x y h => (Prod.mk.injEq _ _ _ _ ▸ h).1)]

/-- Resetting a depth-`d` radix-`q` transcript costs at most the naive per-register total. -/
theorem resetWork_le_naive {n q d : ℕ} (T : Equiv.Perm (Fin n) → Transcript q d) {kT : ℝ}
    (hkT : 0 ≤ kT) :
    resetWork kT T ≤ naiveTranscriptWork kT q d := by
  have hcard : (Finset.univ.image T).card ≤ q ^ d := by
    calc (Finset.univ.image T).card ≤ Fintype.card (Transcript q d) := by
          simpa using Finset.card_le_univ (Finset.univ.image T)
      _ = q ^ d := card_transcript q d
  have hcast : (((Finset.univ.image T).card : ℝ)) ≤ (q : ℝ) ^ d := by exact_mod_cast hcard
  have hne : (Finset.univ.image T).Nonempty := Finset.image_nonempty.2 ⟨1, Finset.mem_univ _⟩
  have hpos : 0 < (Finset.univ.image T).card := Finset.card_pos.2 hne
  have hlog : Real.log ((Finset.univ.image T).card) ≤ (d : ℝ) * Real.log q := by
    calc Real.log ((Finset.univ.image T).card)
        ≤ Real.log ((q : ℝ) ^ d) := Real.log_le_log (by exact_mod_cast hpos) hcast
      _ = (d : ℝ) * Real.log q := Real.log_pow _ _
  calc resetWork kT T ≤ kT * ((d : ℝ) * Real.log q) :=
        mul_le_mul_of_nonneg_left hlog hkT
    _ = naiveTranscriptWork kT q d := by unfold naiveTranscriptWork; ring

/-- For a **correct** sorter the transcript image has exactly `n!` elements: the transcript
register carries precisely the erased permutation, no more and no less. -/
theorem Sorter.image_card {n q d : ℕ} (S : Sorter n q d) :
    (Finset.univ.image S.transcript).card = n.factorial := by
  rw [Finset.card_image_of_injective _ S.correct, Finset.card_univ, perm_card]

/-- **Reset cost is the conditional transcript entropy, not the transcript length.**
For every correct radix-`q`, depth-`d` sorter the work required to reset its transcript
register equals the catalog's Landauer gap of sorting, `kT log (n!)` — independent of the
depth `d` and of the radix `q`. -/
theorem transcript_reset_work_eq_landauer {n q d : ℕ} (S : Sorter n q d) (kT : ℝ) :
    resetWork kT S.transcript = landauerGap (sortingFunction n) kT := by
  rw [SortingEntropyWork.sorting_landauer_gap_exact, resetWork, S.image_card]

/-- **Synthesis for the reset-register conjecture.**  For a correct radix-`q`, depth-`d`
sorter and `kT > 0`:
1. the depth obeys the multiway entropy bound `⌈log_q (n!)⌉ ≤ d`;
2. the naive per-register charge is at least `kT log (n!)`;
3. the true reset cost equals `kT log (n!)` exactly, hence is independent of `d` and `q`;
4. duplicating the transcript register (logically correlated queries) changes nothing.
-/
theorem multiway_reset_synthesis {n q d : ℕ} (hq : 1 < q) (S : Sorter n q d) {kT : ℝ}
    (hkT : 0 < kT) :
    Nat.clog q n.factorial ≤ d ∧
    kT * Real.log n.factorial ≤ naiveTranscriptWork kT q d ∧
    resetWork kT S.transcript = kT * Real.log n.factorial ∧
    resetWork kT (fun σ => (S.transcript σ, S.transcript σ)) = resetWork kT S.transcript := by
  refine ⟨S.clog_le_depth hq, radix_independent_work_lower_bound S hkT.le, ?_,
    resetWork_duplicate kT S.transcript⟩
  rw [transcript_reset_work_eq_landauer S kT, SortingEntropyWork.sorting_landauer_gap_exact]

-- !-- Lab Notes -- !--
-- Hypothesis (Future Direction 5): with `q`-outcome queries, depth must be at least
-- `⌈log_q(n!)⌉` while the ideal total work stays `kT log(n!)`, independent of `q`.
-- Experiment: transcripts were modelled as elements of `Fin d → Fin q` and correctness as
-- injectivity of the transcript map (legitimate because the sorted output is constant).
-- Numerically, for `n = 5` (`n! = 120`): `⌈log_2 120⌉ = 7`, `⌈log_3 120⌉ = 5`,
-- `⌈log_4 120⌉ = 4`, `⌈log_10 120⌉ = 3`, and the products `d·log q` are
-- `4.85, 5.49, 5.55, 6.91` nats against `log 120 = 4.79`: always above, and below
-- `log 120 + log q` in each case, confirming the sandwich.
-- Analysis: the depth bound is pure counting (`n! ≤ q^d`); the radix independence is the
-- observation that the *charge per register* scales as `log q` exactly compensating the
-- decrease in depth, up to at most one query.  Achievability comes from `Nat.le_pow_clog`.
-- Critique: the naive charge is an upper model of the true reset cost; the reset theorem
-- shows the physically relevant quantity is `log |image transcript|`, which for a correct
-- sorter is exactly `n!` regardless of `d, q`, and is invariant under duplicating the
-- register — the precise sense in which redundant/correlated queries are thermodynamically
-- free.  A residual limitation: injectivity is a necessary correctness condition, not a
-- model of which comparisons are physically available at each step.
-- !-- end Lab Notes -- !--

end MultiwaySorting