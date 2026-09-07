/-
Copyright (c) 2026 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Algebra.StandardPartPVMFunctional

/-!
# Observed entropy and coarse-graining

Fifth instalment of the standard-part PVM programme (see `Algebra.StandardPartPVM`,
`Algebra.StandardPartPVMFunctional`, `Algebra.StandardPartPVMLifting`,
`Algebra.StandardPartPVMRigidity`).

Merging measurement channels of a hyperreal approximate PVM cannot increase the Shannon entropy
of the observed Born distribution.  This settles the inequality half of the conjecture "Observed
Entropy Monotonicity Under Coarse-Graining" recorded in `FUTURE_DIRECTIONS.md`, and pins down both
sides of the equality boundary: equality holds when each fibre of the merging map carries at most
one nonzero weight, and the inequality is *strict* as soon as one fibre carries two; together these
give the full equality criterion conjectured in the previous cycle.

## Main results

* `StandardPartPVM.negMulLog_sum_le_sum_negMulLog` — the scalar engine: for nonnegative weights,
  `negMulLog (∑ p) ≤ ∑ negMulLog p`.
* `StandardPartPVM.negMulLog_sum_lt_sum_negMulLog` — strict version when two weights are positive.
* `StandardPartPVM.observedEntropy_coarse_le` — **entropy monotonicity**: for a real PVM with
  symmetric members (so that the Born weights are genuine probabilities) and any merging map
  `f : ι → κ`, `observedEntropy (coarse Q f) v ≤ observedEntropy Q v`.
* `StandardPartPVM.observedEntropy_coarse_lt` — strictness on a fibre with two positive weights.
* `StandardPartPVM.observedEntropy_coarse_eq_of_fiber_subsingleton` — equality when every fibre
  carries at most one nonzero weight.
* `StandardPartPVM.observedEntropy_coarse_eq_iff` — the two combine into a sharp criterion:
  equality holds **iff** no two distinct channels of nonzero weight are merged.
* `StandardPartPVM.observedEntropy_stMat_coarse_le` — the statement for the *observation* of a
  hyperreal approximate PVM, via the descent theorem.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the observed Born weights of a hyperreal approximate PVM form an honest
probability distribution (`bornMeasure_sum_eq_one`, `bornMeasure_nonneg`), and coarse-graining
pushes it forward (`bornWeight_coarse`).  Shannon entropy should therefore be monotone under
merging of channels, with a sharp equality boundary.

Experiment (Experimenter): the two-channel test `p = (t, 1 - t)` merged into one channel gives
`H_coarse = negMulLog 1 = 0` while `H_fine = negMulLog t + negMulLog (1 - t) > 0` for
`0 < t < 1`, and `H_fine = 0` at `t ∈ {0, 1}` — exactly the predicted boundary.  This drove the
formal statements: a non-strict inequality in general, strict as soon as two weights in one fibre
are positive, and equality when each fibre has at most one nonzero weight.

Analysis (Analyst): the whole content is the pointwise estimate `p log p ≤ p log S` for
`0 ≤ p ≤ S`, i.e. monotonicity of `log`, summed over a fibre; no concavity machinery is needed,
and the argument never leaves the reals — the hyperreal input enters only through the descent
theorem, which guarantees that `stMat ∘ P` is a PVM in the first place.

Critique (Critic): the inequality is vacuous without nonnegativity of the weights, which is why
symmetry of the projections is assumed (`bornMeasure_nonneg` fails for non-symmetric idempotents);
the hypothesis is therefore load-bearing, not decorative.  The strict and the equality statements
together show the bound is attained exactly on the predicted set, so no stronger inequality of
this shape is available.
-- !-- Lab Notes -- !--
-/

open Matrix Finset Real

namespace StandardPartPVM

variable {n ι κ : Type*}

/-! ## The scalar engine -/

/-- For nonnegative weights, the entropy contribution of a merged block is at most the sum of the
contributions of its parts: `negMulLog (∑ p) ≤ ∑ negMulLog p`. -/
theorem negMulLog_sum_le_sum_negMulLog {α : Type*} (s : Finset α) (p : α → ℝ)
    (hp : ∀ i ∈ s, 0 ≤ p i) :
    negMulLog (∑ i ∈ s, p i) ≤ ∑ i ∈ s, negMulLog (p i) := by
  set S := ∑ i ∈ s, p i with hS
  have hSnn : 0 ≤ S := Finset.sum_nonneg hp
  rcases eq_or_lt_of_le hSnn with hzero | hpos
  · -- all weights vanish
    have hall : ∀ i ∈ s, p i = 0 := (Finset.sum_eq_zero_iff_of_nonneg hp).1 hzero.symm
    rw [show S = (0 : ℝ) from hzero.symm, negMulLog_zero]
    exact Finset.sum_nonneg fun i hi => by rw [hall i hi, negMulLog_zero]
  · have key : ∀ i ∈ s, -p i * log S ≤ negMulLog (p i) := by
      intro i hi
      rcases eq_or_lt_of_le (hp i hi) with h0 | hi0
      · simp [negMulLog, ← h0]
      · have hle : p i ≤ S := Finset.single_le_sum hp hi
        have hlog : log (p i) ≤ log S := Real.log_le_log hi0 hle
        have := mul_le_mul_of_nonneg_left hlog hi0.le
        simpa [negMulLog, neg_mul] using neg_le_neg this
    calc negMulLog S = ∑ i ∈ s, -p i * log S := by
          rw [negMulLog, ← Finset.sum_neg_distrib, ← Finset.sum_mul, hS]
      _ ≤ ∑ i ∈ s, negMulLog (p i) := Finset.sum_le_sum key

/-- Strict version: if two distinct members of the block carry positive weight, merging strictly
decreases the entropy contribution. -/
theorem negMulLog_sum_lt_sum_negMulLog {α : Type*} (s : Finset α) (p : α → ℝ)
    (hp : ∀ i ∈ s, 0 ≤ p i) {a b : α} (ha : a ∈ s) (hb : b ∈ s) (hab : a ≠ b)
    (hpa : 0 < p a) (hpb : 0 < p b) :
    negMulLog (∑ i ∈ s, p i) < ∑ i ∈ s, negMulLog (p i) := by
  classical
  set S := ∑ i ∈ s, p i with hS
  have hlt : p a < S := by
    have hb' : b ∈ s.erase a := Finset.mem_erase.2 ⟨hab.symm, hb⟩
    have h1 : p b ≤ ∑ i ∈ s.erase a, p i :=
      Finset.single_le_sum (fun i hi => hp i (Finset.mem_of_mem_erase hi)) hb'
    have h2 : p a + ∑ i ∈ s.erase a, p i = S := (Finset.add_sum_erase s p ha).trans hS.symm
    linarith
  have key : ∀ i ∈ s, -p i * log S ≤ negMulLog (p i) := by
    intro i hi
    rcases eq_or_lt_of_le (hp i hi) with h0 | hi0
    · simp [negMulLog, ← h0]
    · have hle : p i ≤ S := Finset.single_le_sum hp hi
      have hlog : log (p i) ≤ log S := Real.log_le_log hi0 hle
      have := mul_le_mul_of_nonneg_left hlog hi0.le
      simpa [negMulLog, neg_mul] using neg_le_neg this
  have keya : -p a * log S < negMulLog (p a) := by
    have hlog : log (p a) < log S := Real.log_lt_log hpa hlt
    have := (mul_lt_mul_of_pos_left hlog hpa)
    simpa [negMulLog, neg_mul] using neg_lt_neg this
  calc negMulLog S = ∑ i ∈ s, -p i * log S := by
        rw [negMulLog, ← Finset.sum_neg_distrib, ← Finset.sum_mul, hS]
    _ < ∑ i ∈ s, negMulLog (p i) :=
        Finset.sum_lt_sum key ⟨a, ha, keya⟩

/-! ## Observed entropy -/

section Entropy

variable [Fintype n] [DecidableEq n] [Fintype ι] [Fintype κ] [DecidableEq κ]

/-- The Shannon entropy of the observed Born distribution of a real PVM in the state `v`. -/
noncomputable def observedEntropy (Q : ι → Matrix n n ℝ) (v : n → ℝ) : ℝ :=
  ∑ a, negMulLog (bornWeight Q v a)

/-- **Entropy monotonicity under coarse-graining.**  Merging the channels of a projection-valued
measure whose members are symmetric never increases the entropy of the observed Born
distribution. -/
theorem observedEntropy_coarse_le {Q : ι → Matrix n n ℝ} (h : IsPVM Q)
    (hsymm : ∀ a, (Q a)ᵀ = Q a) (v : n → ℝ) (f : ι → κ) :
    observedEntropy (coarse Q f) v ≤ observedEntropy Q v := by
  classical
  have hfine : observedEntropy Q v
      = ∑ k, ∑ a ∈ Finset.univ.filter (fun a => f a = k), negMulLog (bornWeight Q v a) :=
    (Finset.sum_fiberwise Finset.univ f fun a => negMulLog (bornWeight Q v a)).symm
  rw [observedEntropy, hfine]
  refine Finset.sum_le_sum fun k _ => ?_
  rw [bornWeight_coarse]
  exact negMulLog_sum_le_sum_negMulLog _ _ fun a _ => bornMeasure_nonneg h hsymm v a

/-- **Strict entropy loss.**  If two distinct channels with positive observed weight are merged,
the entropy strictly decreases. -/
theorem observedEntropy_coarse_lt {Q : ι → Matrix n n ℝ} (h : IsPVM Q)
    (hsymm : ∀ a, (Q a)ᵀ = Q a) (v : n → ℝ) (f : ι → κ) {a b : ι} (hab : a ≠ b)
    (hfab : f a = f b) (hpa : 0 < bornWeight Q v a) (hpb : 0 < bornWeight Q v b) :
    observedEntropy (coarse Q f) v < observedEntropy Q v := by
  classical
  have hfine : observedEntropy Q v
      = ∑ k, ∑ a ∈ Finset.univ.filter (fun a => f a = k), negMulLog (bornWeight Q v a) :=
    (Finset.sum_fiberwise Finset.univ f fun a => negMulLog (bornWeight Q v a)).symm
  rw [observedEntropy, hfine]
  refine Finset.sum_lt_sum (fun k _ => ?_) ⟨f a, Finset.mem_univ _, ?_⟩
  · rw [bornWeight_coarse]
    exact negMulLog_sum_le_sum_negMulLog _ _ fun c _ => bornMeasure_nonneg h hsymm v c
  · rw [bornWeight_coarse]
    refine negMulLog_sum_lt_sum_negMulLog _ _
      (fun c _ => bornMeasure_nonneg h hsymm v c)
      (Finset.mem_filter.2 ⟨Finset.mem_univ _, rfl⟩)
      (Finset.mem_filter.2 ⟨Finset.mem_univ _, hfab.symm⟩) hab hpa hpb

omit [DecidableEq n] in
/-- **The equality boundary.**  If every fibre of the merging map carries at most one channel of
nonzero observed weight, coarse-graining costs no entropy. -/
theorem observedEntropy_coarse_eq_of_fiber_subsingleton {Q : ι → Matrix n n ℝ} (v : n → ℝ)
    (f : ι → κ)
    (hfib : ∀ a b, f a = f b → bornWeight Q v a ≠ 0 → bornWeight Q v b ≠ 0 → a = b) :
    observedEntropy (coarse Q f) v = observedEntropy Q v := by
  classical
  have hfine : observedEntropy Q v
      = ∑ k, ∑ a ∈ Finset.univ.filter (fun a => f a = k), negMulLog (bornWeight Q v a) :=
    (Finset.sum_fiberwise Finset.univ f fun a => negMulLog (bornWeight Q v a)).symm
  rw [observedEntropy, hfine]
  refine Finset.sum_congr rfl fun k _ => ?_
  rw [bornWeight_coarse]
  set s := Finset.univ.filter (fun a => f a = k) with hs
  by_cases hzero : ∀ a ∈ s, bornWeight Q v a = 0
  · rw [Finset.sum_eq_zero hzero, negMulLog_zero,
      Finset.sum_eq_zero fun a ha => by rw [hzero a ha, negMulLog_zero]]
  · push_neg at hzero
    obtain ⟨a, has, hane⟩ := hzero
    have hsingle : ∀ b ∈ s, b ≠ a → bornWeight Q v b = 0 := by
      intro b hbs hba
      by_contra hbne
      exact hba (hfib b a (((Finset.mem_filter.1 hbs).2).trans ((Finset.mem_filter.1 has).2).symm)
        hbne hane)
    rw [Finset.sum_eq_single a (fun b hb hba => hsingle b hb hba) (fun hn => absurd has hn),
      Finset.sum_eq_single a (fun b hb hba => by rw [hsingle b hb hba, negMulLog_zero])
        (fun hn => absurd has hn)]

/-- **Sharp equality criterion.**  Coarse-graining preserves the observed entropy exactly when no
two distinct channels of nonzero weight are merged. -/
theorem observedEntropy_coarse_eq_iff {Q : ι → Matrix n n ℝ} (h : IsPVM Q)
    (hsymm : ∀ a, (Q a)ᵀ = Q a) (v : n → ℝ) (f : ι → κ) :
    observedEntropy (coarse Q f) v = observedEntropy Q v ↔
      ∀ a b, f a = f b → bornWeight Q v a ≠ 0 → bornWeight Q v b ≠ 0 → a = b := by
  refine ⟨fun heq a b hfab hane hbne => ?_,
    observedEntropy_coarse_eq_of_fiber_subsingleton v f⟩
  by_contra hab
  have hpa : 0 < bornWeight Q v a := lt_of_le_of_ne (bornMeasure_nonneg h hsymm v a) (Ne.symm hane)
  have hpb : 0 < bornWeight Q v b := lt_of_le_of_ne (bornMeasure_nonneg h hsymm v b) (Ne.symm hbne)
  exact absurd heq (observedEntropy_coarse_lt h hsymm v f hab hfab hpa hpb).ne

/-- The hyperreal statement: the observation of an approximate PVM whose observed projections are
symmetric loses entropy under any merging of channels. -/
theorem observedEntropy_stMat_coarse_le {P : ι → Matrix n n ℝ*} (h : IsApproxPVM P)
    (hsymm : ∀ a, (stMat (P a))ᵀ = stMat (P a)) (v : n → ℝ) (f : ι → κ) :
    observedEntropy (coarse (fun a => stMat (P a)) f) v
      ≤ observedEntropy (fun a => stMat (P a)) v :=
  observedEntropy_coarse_le h.isPVM_stMat hsymm v f

end Entropy

end StandardPartPVM