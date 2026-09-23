import Catalog.NumberTheory.SixKeystoneOrbitDeficit

/-!
# Cycle V: rebatching invariance characterises iterated dynamics

Cycle I proved one half of the audit's "zero drift" keystone: a seeded congruential
pipeline gives the same final state for any two batch schedules of the same total length
(`zero_drift`).  Direction 3 of `FUTURE_DIRECTIONS.md` asked for the *converse*: is batch
invariance evidence that the pipeline is the iterate of a single visible step, so that
batch **sensitivity** certifies hidden state?  This file answers yes, for an arbitrary
state type.

## Setup

A *schedule-executing pipeline* on a state type `S` is a map `F : List ℕ → S → S` such
that the empty schedule does nothing (`hnil`) and running a schedule `n :: L` means running
the batch `n` and then the rest (`hcons`).  Both properties hold for `runBatches` by
definition.

## Main results

* `batchInvariant_iff_iterate` — `F` is batch invariant (depends only on the total step
  count) **iff** `F L = (F [1])^[L.sum]`, i.e. iff `F` is the iterate of its unit step.
* `not_iterate_of_batch_sensitive` — contrapositive form: two schedules of equal total
  length with different outcomes certify that the pipeline is not an iterated visible
  step, i.e. that it carries hidden state.
* `runBatches_eq_iterate`, `zero_drift_of_iterate` — the congruential pipeline of cycle I
  is such an iterate, recovering `zero_drift` from the general criterion.
-/

namespace SixKeystoneZeroDrift

section

variable {S : Type*} (F : List ℕ → S → S)

/-- Running a schedule of `n` unit batches is iterating the unit step `n` times. -/
lemma exec_replicate_one (hnil : ∀ s, F [] s = s)
    (hcons : ∀ n L s, F (n :: L) s = F L (F [n] s)) (n : ℕ) (s : S) :
    F (List.replicate n 1) s = (F [1])^[n] s := by
  induction n generalizing s with
  | zero => simpa using hnil s
  | succ n ih =>
      rw [List.replicate_succ, hcons, ih, Function.iterate_succ_apply]

/-- **Rebatching invariance is exactly iterated dynamics.**  A schedule-executing pipeline
produces an outcome depending only on the total number of steps precisely when it is the
iterate of its unit step. -/
theorem batchInvariant_iff_iterate (hnil : ∀ s, F [] s = s)
    (hcons : ∀ n L s, F (n :: L) s = F L (F [n] s)) :
    (∀ L L' : List ℕ, ∀ s : S, L.sum = L'.sum → F L s = F L' s) ↔
      (∀ (L : List ℕ) (s : S), F L s = (F [1])^[L.sum] s) := by
  constructor
  · intro hinv L s
    have hsum : (List.replicate L.sum 1).sum = L.sum := by
      simp
    rw [hinv L (List.replicate L.sum 1) s hsum.symm, exec_replicate_one F hnil hcons]
  · intro hiter L L' s h
    rw [hiter L s, hiter L' s, h]

/-- **Batch sensitivity certifies hidden state.**  If two schedules with the same total
number of steps disagree, the pipeline is not the iterate of any visible unit step. -/
theorem not_iterate_of_batch_sensitive (hnil : ∀ s, F [] s = s)
    (hcons : ∀ n L s, F (n :: L) s = F L (F [n] s))
    (L L' : List ℕ) (s : S) (hsum : L.sum = L'.sum) (hne : F L s ≠ F L' s) :
    ¬ ∀ (M : List ℕ) (t : S), F M t = (F [1])^[M.sum] t := by
  intro hiter
  exact hne ((batchInvariant_iff_iterate F hnil hcons).2 hiter L L' s hsum)

/-! ## The congruential pipeline satisfies the criterion -/

lemma runBatches_nil (a c m : ℕ) (s : ℕ) : runBatches a c m [] s = s := rfl

lemma runBatches_cons (a c m : ℕ) (n : ℕ) (L : List ℕ) (s : ℕ) :
    runBatches a c m (n :: L) s = runBatches a c m L (runBatches a c m [n] s) := by
  simp [runBatches]

/-- The audited pipeline is literally the iterate of a single step, so its batch
invariance is an instance of the general criterion. -/
theorem runBatches_eq_iterate (a c m : ℕ) (L : List ℕ) (s : ℕ) :
    runBatches a c m L s = (step a c m)^[L.sum] s := by
  rw [runBatches_eq_run, run_eq_iterate]

/-- `zero_drift` recovered from `batchInvariant_iff_iterate`. -/
theorem zero_drift_of_iterate (a c m : ℕ) (L L' : List ℕ) (s : ℕ) (h : L.sum = L'.sum) :
    runBatches a c m L s = runBatches a c m L' s := by
  refine (batchInvariant_iff_iterate (runBatches a c m) (runBatches_nil a c m)
    (runBatches_cons a c m)).2 (fun M t => ?_) L L' s h
  rw [runBatches_eq_iterate]
  have h1 : runBatches a c m [1] = step a c m := by
    funext x
    simp [runBatches, run_succ]
  rw [h1]

end

end SixKeystoneZeroDrift