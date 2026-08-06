import Mathlib
import Computation.AdaptiveFluctuationDemon

/-!
# Unbounded-horizon (stopping-time) demons and a Wald identity for Landauer cost

`Catalog/Computation/FluctuationRobustDemon.lean` proved the Chernoff-type bound

```
P( ∑_{i<n} W_i ≤ n·w )  ≤  exp ( -n·β·(ΔF - w) )
```

for `n` **independent** finite work systems, and
`Catalog/Computation/AdaptiveFluctuationDemon.lean` removed the independence hypothesis by
replacing the product by a fixed-depth decision tree (`FluctDemon.AdaptiveDemon`).  Both
results describe a demon that erases a *prescribed* number of bits.

A real control strategy stops when it likes: it inspects the outcomes it has seen and
decides whether to run another erasure.  The number of stages `N` is then a random variable
— a stopping time — and neither previous theorem applies, because "total work over `n`
stages" is not even defined.  This file closes that gap, which was Conjecture 2 of the
previous cycle's `FUTURE_DIRECTIONS.md`.

A **stopping demon** (`FluctDemon.StoppingDemon`) is a decision tree in which *every* node
may either halt or run one more work system; the depth parameter is only an a priori bound
on how long the demon may run, and it never appears in any of the bounds below.  The two
main results are:

* a **large-deviation bound at a random horizon**
  (`FluctDemon.stopping_rate_deficit_bound`):

  ```
  P( total work ≤ w·N  and  N ≥ m )  ≤  exp ( -m·β·(ΔF - w) )      (w ≤ ΔF)
  ```

  so a demon that wants to average below `w` per erased bit must, with overwhelming
  probability, stop early — the number of bits it can process at a fixed success
  probability is bounded by `log(1/δ)/(β(ΔF-w))` no matter how it chooses to stop
  (`FluctDemon.stopping_reliability_bound`);

* a **Wald identity for Landauer cost** (`FluctDemon.stopping_wald`):

  ```
  ΔF · E[N]  ≤  E[total work],
  ```

  the expectation-level second law with a random number of erasures.

Both are proved by structural induction on the tree, i.e. by the finite avatar of optional
stopping for the supermartingale `M_k = exp(-β ∑_{i≤k} W_i + k·β·ΔF)`.  Only the one-sided
hypothesis `⟨e^{-βW}⟩ ≤ e^{-βΔF}` (`FluctDemon.StoppingDemon.Dissipative`) is used, so
Jarzynski compliance is a special case.

## Main definitions

* `FluctDemon.StoppingDemon` — an adaptive strategy that may halt at any node.
* `FluctDemon.StoppingDemon.Dissipative`, `.Compliant` — per-node fluctuation hypotheses.
* `FluctDemon.StoppingDemon.deepProb` — `P(N ≥ m)`.
* `FluctDemon.StoppingDemon.deepDeficitProb` — `P(total work ≤ t and N ≥ m)`.
* `FluctDemon.StoppingDemon.rateDeficitProb` — `P(total work ≤ w·N + c and N ≥ m)`.
* `FluctDemon.StoppingDemon.meanStages`, `.meanTotalWork` — `E[N]` and `E[total work]`.

## Main results

* `FluctDemon.stopping_deficit_bound` — `P(total work ≤ t, N ≥ m) ≤ exp(-β(m·ΔF - t))`.
* `FluctDemon.stopping_rate_deficit_bound` — the random-horizon form above.
* `FluctDemon.stopping_wald` — `ΔF · E[N] ≤ E[total work]`.
* `FluctDemon.stopping_reliability_bound`, `FluctDemon.stopping_deficit_tendsto_zero`.
* `FluctDemon.coinStop_*` — an explicit demon with a genuinely random `N` (`E[N] = 3/2`),
  exact sub-threshold probability `1/4` against the bound `4/9`, and strict Wald slack.
-/

open Finset Real

noncomputable section

namespace FluctDemon

variable {Ω : Type*} [Fintype Ω]

/-! ## Shifting the work scale -/

/-- Subtract a constant `w` from the work of every outcome.  Used to turn the random
threshold `w·N` into a fixed one. -/
def WorkSystem.shiftWork (w : ℝ) (S : WorkSystem Ω) : WorkSystem Ω where
  prob := S.prob
  work := fun ω => S.work ω - w
  prob_nonneg := S.prob_nonneg
  prob_sum := S.prob_sum

@[simp] lemma WorkSystem.shiftWork_prob (w : ℝ) (S : WorkSystem Ω) (ω : Ω) :
    (S.shiftWork w).prob ω = S.prob ω := rfl

@[simp] lemma WorkSystem.shiftWork_work (w : ℝ) (S : WorkSystem Ω) (ω : Ω) :
    (S.shiftWork w).work ω = S.work ω - w := rfl

/-- Shifting the work scale rescales the Jarzynski exponential average. -/
lemma expAvg_shiftWork (β w : ℝ) (S : WorkSystem Ω) :
    expAvg β (S.shiftWork w) = Real.exp (β * w) * expAvg β S := by
  unfold expAvg
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun ω _ => ?_
  simp only [WorkSystem.shiftWork_prob, WorkSystem.shiftWork_work]
  rw [show -β * (S.work ω - w) = β * w + -β * S.work ω by ring, Real.exp_add]
  ring

/-- The one-sided (Jarzynski inequality) form of the second law, which is all the
concentration argument needs. -/
theorem meanWork_ge_of_dissipative {β ΔF : ℝ} (hβ : 0 < β) {S : WorkSystem Ω}
    (hS : expAvg β S ≤ Real.exp (-β * ΔF)) : ΔF ≤ meanWork S := by
  have h := le_trans (exp_meanWork_le_expAvg β S) hS
  have h2 : -β * meanWork S ≤ -β * ΔF := Real.exp_le_exp.mp h
  nlinarith

/-! ## Stopping demons -/

/-- A **stopping demon**: an adaptive control strategy which, at every node of its decision
tree, may either halt or run one more finite work system and continue as a function of the
observed outcome.  The index `n` is only an a priori bound on the depth; the actual number
of stages `N` is a random variable determined by the outcomes, i.e. a stopping time. -/
inductive StoppingDemon (Ω : Type*) [Fintype Ω] : ℕ → Type _
  /-- Stop now. -/
  | halt {n : ℕ} : StoppingDemon Ω n
  /-- Run `S`, then continue with `next ω` after observing outcome `ω`. -/
  | step {n : ℕ} (S : WorkSystem Ω) (next : Ω → StoppingDemon Ω n) : StoppingDemon Ω (n + 1)

namespace StoppingDemon

/-- Every stage the demon may run obeys the Jarzynski equality at `(β, ΔF)`. -/
def Compliant (β ΔF : ℝ) : ∀ {n : ℕ}, StoppingDemon Ω n → Prop
  | _, .halt => True
  | _, .step S next => Jarzynski β ΔF S ∧ ∀ ω, Compliant β ΔF (next ω)

/-- Every stage the demon may run **dissipates at least** `ΔF`, in the one-sided sense
`⟨e^{-βW}⟩ ≤ e^{-βΔF}`. -/
def Dissipative (β ΔF : ℝ) : ∀ {n : ℕ}, StoppingDemon Ω n → Prop
  | _, .halt => True
  | _, .step S next => expAvg β S ≤ Real.exp (-β * ΔF) ∧ ∀ ω, Dissipative β ΔF (next ω)

/-- The probability that the demon runs at least `m` stages, `P(N ≥ m)`. -/
def deepProb : ∀ {n : ℕ}, StoppingDemon Ω n → ℕ → ℝ
  | _, .halt, m => if m = 0 then 1 else 0
  | _, .step S next, m => ∑ ω, S.prob ω * deepProb (next ω) (m - 1)

/-- The probability that the demon runs at least `m` stages **and** spends total work at
most `t`, `P(total work ≤ t and N ≥ m)`.  Computed by conditioning on the first outcome:
the threshold for the remaining stages drops by the work just spent. -/
def deepDeficitProb : ∀ {n : ℕ}, StoppingDemon Ω n → ℕ → ℝ → ℝ
  | _, .halt, m, t => if m = 0 ∧ 0 ≤ t then 1 else 0
  | _, .step S next, m, t => ∑ ω, S.prob ω * deepDeficitProb (next ω) (m - 1) (t - S.work ω)

/-- The probability that the demon runs at least `m` stages and spends total work at most
`w·N + c`, where `N` is the *random* number of stages actually run. -/
def rateDeficitProb (w : ℝ) : ∀ {n : ℕ}, StoppingDemon Ω n → ℕ → ℝ → ℝ
  | _, .halt, m, c => if m = 0 ∧ 0 ≤ c then 1 else 0
  | _, .step S next, m, c =>
      ∑ ω, S.prob ω * rateDeficitProb w (next ω) (m - 1) (c + w - S.work ω)

/-- The expected number of stages `E[N]`. -/
def meanStages : ∀ {n : ℕ}, StoppingDemon Ω n → ℝ
  | _, .halt => 0
  | _, .step S next => 1 + ∑ ω, S.prob ω * meanStages (next ω)

/-- The expected total work `E[total work]`. -/
def meanTotalWork : ∀ {n : ℕ}, StoppingDemon Ω n → ℝ
  | _, .halt => 0
  | _, .step S next => ∑ ω, S.prob ω * (S.work ω + meanTotalWork (next ω))

@[simp] lemma deepProb_halt {n : ℕ} (m : ℕ) :
    (StoppingDemon.halt (Ω := Ω) (n := n)).deepProb m = if m = 0 then 1 else 0 := rfl

@[simp] lemma deepProb_step {n : ℕ} (S : WorkSystem Ω) (next : Ω → StoppingDemon Ω n) (m : ℕ) :
    (StoppingDemon.step S next).deepProb m = ∑ ω, S.prob ω * (next ω).deepProb (m - 1) := rfl

@[simp] lemma deepDeficitProb_halt {n : ℕ} (m : ℕ) (t : ℝ) :
    (StoppingDemon.halt (Ω := Ω) (n := n)).deepDeficitProb m t =
      if m = 0 ∧ 0 ≤ t then 1 else 0 := rfl

@[simp] lemma deepDeficitProb_step {n : ℕ} (S : WorkSystem Ω) (next : Ω → StoppingDemon Ω n)
    (m : ℕ) (t : ℝ) :
    (StoppingDemon.step S next).deepDeficitProb m t
      = ∑ ω, S.prob ω * (next ω).deepDeficitProb (m - 1) (t - S.work ω) := rfl

@[simp] lemma rateDeficitProb_halt {n : ℕ} (w : ℝ) (m : ℕ) (c : ℝ) :
    rateDeficitProb w (StoppingDemon.halt (Ω := Ω) (n := n)) m c =
      if m = 0 ∧ 0 ≤ c then 1 else 0 := rfl

@[simp] lemma rateDeficitProb_step {n : ℕ} (w : ℝ) (S : WorkSystem Ω)
    (next : Ω → StoppingDemon Ω n) (m : ℕ) (c : ℝ) :
    rateDeficitProb w (StoppingDemon.step S next) m c
      = ∑ ω, S.prob ω * rateDeficitProb w (next ω) (m - 1) (c + w - S.work ω) := rfl

@[simp] lemma meanStages_halt {n : ℕ} : (StoppingDemon.halt (Ω := Ω) (n := n)).meanStages = 0 :=
  rfl

@[simp] lemma meanStages_step {n : ℕ} (S : WorkSystem Ω) (next : Ω → StoppingDemon Ω n) :
    (StoppingDemon.step S next).meanStages = 1 + ∑ ω, S.prob ω * (next ω).meanStages := rfl

@[simp] lemma meanTotalWork_halt {n : ℕ} :
    (StoppingDemon.halt (Ω := Ω) (n := n)).meanTotalWork = 0 := rfl

@[simp] lemma meanTotalWork_step {n : ℕ} (S : WorkSystem Ω) (next : Ω → StoppingDemon Ω n) :
    (StoppingDemon.step S next).meanTotalWork
      = ∑ ω, S.prob ω * (S.work ω + (next ω).meanTotalWork) := rfl

/-- Jarzynski compliance implies the one-sided dissipativity hypothesis. -/
theorem Compliant.dissipative {β ΔF : ℝ} :
    ∀ {n : ℕ} {D : StoppingDemon Ω n}, D.Compliant β ΔF → D.Dissipative β ΔF := by
  intro n D
  induction D with
  | halt => intro _; exact trivial
  | step S next ih =>
      rintro ⟨hS, hnext⟩
      exact ⟨le_of_eq hS, fun ω => ih ω (hnext ω)⟩

/-! ### The model quantities are genuine probabilities -/

theorem deepProb_nonneg : ∀ {n : ℕ} (D : StoppingDemon Ω n) (m : ℕ), 0 ≤ D.deepProb m := by
  intro n D
  induction D with
  | halt => intro m; simp only [deepProb_halt]; split <;> norm_num
  | step S next ih =>
      intro m
      simp only [deepProb_step]
      exact Finset.sum_nonneg fun ω _ => mul_nonneg (S.prob_nonneg ω) (ih ω _)

theorem deepDeficitProb_nonneg :
    ∀ {n : ℕ} (D : StoppingDemon Ω n) (m : ℕ) (t : ℝ), 0 ≤ D.deepDeficitProb m t := by
  intro n D
  induction D with
  | halt => intro m t; simp only [deepDeficitProb_halt]; split <;> norm_num
  | step S next ih =>
      intro m t
      simp only [deepDeficitProb_step]
      exact Finset.sum_nonneg fun ω _ => mul_nonneg (S.prob_nonneg ω) (ih ω _ _)

theorem deepProb_le_one : ∀ {n : ℕ} (D : StoppingDemon Ω n) (m : ℕ), D.deepProb m ≤ 1 := by
  intro n D
  induction D with
  | halt => intro m; simp only [deepProb_halt]; split <;> norm_num
  | step S next ih =>
      intro m
      simp only [deepProb_step]
      calc ∑ ω, S.prob ω * (next ω).deepProb (m - 1)
          ≤ ∑ ω, S.prob ω * 1 :=
            Finset.sum_le_sum fun ω _ => mul_le_mul_of_nonneg_left (ih ω _) (S.prob_nonneg ω)
        _ = 1 := by simpa using S.prob_sum

/-- The demon always runs at least `0` stages: `P(N ≥ 0) = 1`.  A consistency check that
`deepProb` really is the tail distribution of the stopping time. -/
theorem deepProb_zero : ∀ {n : ℕ} (D : StoppingDemon Ω n), D.deepProb 0 = 1 := by
  intro n D
  induction D with
  | halt => simp
  | step S next ih =>
      simp only [deepProb_step, Nat.zero_sub]
      rw [Finset.sum_congr rfl fun ω _ => by rw [ih ω]]
      simpa using S.prob_sum

/-- The deficit event is contained in `{N ≥ m}`: another consistency check on the
recursive definitions. -/
theorem deepDeficitProb_le_deepProb :
    ∀ {n : ℕ} (D : StoppingDemon Ω n) (m : ℕ) (t : ℝ), D.deepDeficitProb m t ≤ D.deepProb m := by
  intro n D
  induction D with
  | halt =>
      intro m t
      simp only [deepDeficitProb_halt, deepProb_halt]
      by_cases h : m = 0
      · simp only [h, true_and]
        split <;> norm_num
      · rw [if_neg (by tauto), if_neg h]
  | step S next ih =>
      intro m t
      simp only [deepDeficitProb_step, deepProb_step]
      exact Finset.sum_le_sum fun ω _ =>
        mul_le_mul_of_nonneg_left (ih ω _ _) (S.prob_nonneg ω)

theorem deepDeficitProb_le_one {n : ℕ} (D : StoppingDemon Ω n) (m : ℕ) (t : ℝ) :
    D.deepDeficitProb m t ≤ 1 :=
  le_trans (deepDeficitProb_le_deepProb D m t) (deepProb_le_one D m)

theorem meanStages_nonneg : ∀ {n : ℕ} (D : StoppingDemon Ω n), 0 ≤ D.meanStages := by
  intro n D
  induction D with
  | halt => simp
  | step S next ih =>
      simp only [meanStages_step]
      have : 0 ≤ ∑ ω, S.prob ω * (next ω).meanStages :=
        Finset.sum_nonneg fun ω _ => mul_nonneg (S.prob_nonneg ω) (ih ω)
      linarith

/-! ### Shifting a whole strategy -/

/-- Subtract `w` from the work of every outcome of every stage. -/
def shift (w : ℝ) : ∀ {n : ℕ}, StoppingDemon Ω n → StoppingDemon Ω n
  | _, .halt => .halt
  | _, .step S next => .step (S.shiftWork w) (fun ω => shift w (next ω))

@[simp] lemma shift_halt {n : ℕ} (w : ℝ) :
    shift w (StoppingDemon.halt (Ω := Ω) (n := n)) = StoppingDemon.halt := rfl

@[simp] lemma shift_step {n : ℕ} (w : ℝ) (S : WorkSystem Ω) (next : Ω → StoppingDemon Ω n) :
    shift w (StoppingDemon.step S next)
      = StoppingDemon.step (S.shiftWork w) (fun ω => shift w (next ω)) := rfl

/-- A demon dissipating at least `ΔF` per stage, seen on the shifted work scale,
dissipates at least `ΔF - w` per stage. -/
theorem Dissipative.shift {β ΔF w : ℝ} :
    ∀ {n : ℕ} {D : StoppingDemon Ω n}, D.Dissipative β ΔF →
      (StoppingDemon.shift w D).Dissipative β (ΔF - w) := by
  intro n D
  induction D with
  | halt => intro _; exact trivial
  | step S next ih =>
      rintro ⟨hS, hnext⟩
      refine ⟨?_, fun ω => ih ω (hnext ω)⟩
      rw [expAvg_shiftWork]
      calc Real.exp (β * w) * expAvg β S
          ≤ Real.exp (β * w) * Real.exp (-β * ΔF) :=
            mul_le_mul_of_nonneg_left hS (le_of_lt (Real.exp_pos _))
        _ = Real.exp (-β * (ΔF - w)) := by rw [← Real.exp_add]; congr 1; ring

/-- The random-horizon deficit probability is the fixed-threshold one on the shifted work
scale: `total work ≤ w·N + c` is `∑ (Wᵢ - w) ≤ c`. -/
theorem rateDeficitProb_eq_shift (w : ℝ) :
    ∀ {n : ℕ} (D : StoppingDemon Ω n) (m : ℕ) (c : ℝ),
      rateDeficitProb w D m c = (StoppingDemon.shift w D).deepDeficitProb m c := by
  intro n D
  induction D with
  | halt => intro m c; rfl
  | step S next ih =>
      intro m c
      simp only [rateDeficitProb_step, shift_step, deepDeficitProb_step,
        WorkSystem.shiftWork_prob, WorkSystem.shiftWork_work]
      refine Finset.sum_congr rfl fun ω _ => ?_
      rw [ih ω]
      congr 2
      ring

end StoppingDemon

/-! ## The stopping-time concentration theorem -/

/-- **Fluctuation-robust demon impossibility at a random horizon.**

For *every* adaptive strategy that may stop whenever it likes, if each stage it might run
dissipates at least `ΔF` in the one-sided sense `⟨e^{-βW}⟩ ≤ e^{-βΔF}`, then

```
P( total work ≤ t  and  N ≥ m )  ≤  exp( -β·(m·ΔF - t) ).
```

The bound depends only on `β, ΔF, t` and the *required* number of stages `m`; the depth
bound `n` of the tree does not appear, so it is uniform over strategies of every horizon.
The hypothesis `0 ≤ ΔF` is only needed to handle the degenerate requirement `m = 0`. -/
theorem stopping_deficit_bound {β ΔF : ℝ} (hβ : 0 < β) (hΔF : 0 ≤ ΔF) :
    ∀ {n : ℕ} (D : StoppingDemon Ω n), D.Dissipative β ΔF → ∀ (m : ℕ) (t : ℝ),
      D.deepDeficitProb m t ≤ Real.exp (-β * ((m : ℝ) * ΔF - t)) := by
  intro n D
  induction D with
  | halt =>
      intro _ m t
      simp only [StoppingDemon.deepDeficitProb_halt]
      by_cases h : m = 0 ∧ 0 ≤ t
      · rw [if_pos h]
        obtain ⟨hm, ht⟩ := h
        subst hm
        rw [show (1 : ℝ) = Real.exp 0 by simp]
        exact Real.exp_le_exp.mpr (by push_cast; nlinarith)
      · rw [if_neg h]
        exact le_of_lt (Real.exp_pos _)
  | step S next ih =>
      rintro ⟨hS, hnext⟩ m t
      simp only [StoppingDemon.deepDeficitProb_step]
      -- the bound available for the subtrees, at the reduced requirement `m - 1`
      have key : ∀ ω : Ω,
          S.prob ω * (next ω).deepDeficitProb (m - 1) (t - S.work ω)
            ≤ S.prob ω *
              (Real.exp (-β * (((m : ℝ) - 1) * ΔF - t)) * Real.exp (-β * S.work ω)) := by
        intro ω
        refine mul_le_mul_of_nonneg_left ?_ (S.prob_nonneg ω)
        refine le_trans (ih ω (hnext ω) (m - 1) (t - S.work ω)) ?_
        rw [← Real.exp_add]
        refine Real.exp_le_exp.mpr ?_
        rcases Nat.eq_zero_or_pos m with hm | hm
        · subst hm
          simp only [Nat.zero_sub, Nat.cast_zero, zero_mul, zero_sub]
          nlinarith
        · have hcast : ((m - 1 : ℕ) : ℝ) = (m : ℝ) - 1 := by
            rw [Nat.cast_sub hm, Nat.cast_one]
          exact le_of_eq (by rw [hcast]; ring)
      calc ∑ ω, S.prob ω * (next ω).deepDeficitProb (m - 1) (t - S.work ω)
          ≤ ∑ ω, S.prob ω *
              (Real.exp (-β * (((m : ℝ) - 1) * ΔF - t)) * Real.exp (-β * S.work ω)) :=
            Finset.sum_le_sum fun ω _ => key ω
        _ = Real.exp (-β * (((m : ℝ) - 1) * ΔF - t)) *
              ∑ ω, S.prob ω * Real.exp (-β * S.work ω) := by
            rw [Finset.mul_sum]
            exact Finset.sum_congr rfl fun ω _ => by ring
        _ ≤ Real.exp (-β * (((m : ℝ) - 1) * ΔF - t)) * Real.exp (-β * ΔF) := by
            rw [show ∑ ω, S.prob ω * Real.exp (-β * S.work ω) = expAvg β S from rfl]
            exact mul_le_mul_of_nonneg_left hS (le_of_lt (Real.exp_pos _))
        _ = Real.exp (-β * ((m : ℝ) * ΔF - t)) := by
            rw [← Real.exp_add]; congr 1; ring

/-- **Wald identity for Landauer cost.**  A demon that stops according to any rule
whatsoever, each of whose stages dissipates at least `ΔF`, spends at least `ΔF · E[N]` work
on average, where `N` is the random number of stages it runs. -/
theorem stopping_wald {β ΔF : ℝ} (hβ : 0 < β) :
    ∀ {n : ℕ} (D : StoppingDemon Ω n), D.Dissipative β ΔF →
      ΔF * D.meanStages ≤ D.meanTotalWork := by
  intro n D
  induction D with
  | halt => intro _; simp
  | step S next ih =>
      rintro ⟨hS, hnext⟩
      simp only [StoppingDemon.meanStages_step, StoppingDemon.meanTotalWork_step]
      have hhead : ΔF ≤ meanWork S := meanWork_ge_of_dissipative hβ hS
      have htail : ∑ ω, S.prob ω * (ΔF * (next ω).meanStages)
          ≤ ∑ ω, S.prob ω * (next ω).meanTotalWork :=
        Finset.sum_le_sum fun ω _ =>
          mul_le_mul_of_nonneg_left (ih ω (hnext ω)) (S.prob_nonneg ω)
      have hdist : ΔF * (1 + ∑ ω, S.prob ω * (next ω).meanStages)
          = ΔF + ∑ ω, S.prob ω * (ΔF * (next ω).meanStages) := by
        rw [mul_add, mul_one, Finset.mul_sum]
        congr 1
        exact Finset.sum_congr rfl fun ω _ => by ring
      have hsplit : ∑ ω, S.prob ω * (S.work ω + (next ω).meanTotalWork)
          = meanWork S + ∑ ω, S.prob ω * (next ω).meanTotalWork := by
        rw [show meanWork S = ∑ ω, S.prob ω * S.work ω from rfl, ← Finset.sum_add_distrib]
        exact Finset.sum_congr rfl fun ω _ => by ring
      rw [hdist, hsplit]
      linarith

/-- **The random-horizon rate bound**, exactly as conjectured: the probability that a
stopping demon averages below `w` per erased bit *and* manages to erase at least `m` bits
is at most `exp(-m·β·(ΔF - w))`. -/
theorem stopping_rate_deficit_bound {β ΔF w : ℝ} (hβ : 0 < β) (hw : w ≤ ΔF) :
    ∀ {n : ℕ} (D : StoppingDemon Ω n), D.Dissipative β ΔF → ∀ m : ℕ,
      StoppingDemon.rateDeficitProb w D m 0 ≤ Real.exp (-(m : ℝ) * β * (ΔF - w)) := by
  intro n D hD m
  rw [StoppingDemon.rateDeficitProb_eq_shift]
  refine le_trans
    (stopping_deficit_bound hβ (by linarith) (StoppingDemon.shift w D) hD.shift m 0)
    (le_of_eq ?_)
  congr 1
  ring

/-- The Jarzynski-equality form of the random-horizon rate bound. -/
theorem stopping_rate_deficit_bound_of_compliant {β ΔF w : ℝ} (hβ : 0 < β) (hw : w ≤ ΔF)
    {n : ℕ} (D : StoppingDemon Ω n) (hD : D.Compliant β ΔF) (m : ℕ) :
    StoppingDemon.rateDeficitProb w D m 0 ≤ Real.exp (-(m : ℝ) * β * (ΔF - w)) :=
  stopping_rate_deficit_bound hβ hw D hD.dissipative m

/-- **Reliability bound for a stopping demon.**  If a demon claims to erase at least `m`
bits at an average cost below `w < ΔF` per bit and succeeds with probability at least
`δ > 0`, then `m ≤ log(1/δ)/(β(ΔF-w))`.  Choosing *when to stop* buys the demon nothing. -/
theorem stopping_reliability_bound {β ΔF w δ : ℝ} (hβ : 0 < β) (hw : w < ΔF) (hδ : 0 < δ)
    {n : ℕ} (D : StoppingDemon Ω n) (hD : D.Dissipative β ΔF) {m : ℕ}
    (hsucc : δ ≤ StoppingDemon.rateDeficitProb w D m 0) :
    (m : ℝ) ≤ Real.log (1 / δ) / (β * (ΔF - w)) := by
  have hr : 0 < β * (ΔF - w) := by nlinarith
  have hδle : δ ≤ Real.exp (-(m : ℝ) * β * (ΔF - w)) :=
    le_trans hsucc (stopping_rate_deficit_bound hβ (le_of_lt hw) D hD m)
  have hlog : Real.log δ ≤ -(m : ℝ) * β * (ΔF - w) := by
    have := Real.log_le_log hδ hδle
    rwa [Real.log_exp] at this
  rw [le_div_iff₀ hr]
  have hinv : Real.log (1 / δ) = -Real.log δ := by rw [one_div, Real.log_inv]
  rw [hinv]
  nlinarith

/-- **A stopping demon cannot run long and cheap.**  For every accuracy `ε > 0` there is an
`M` such that every stopping demon, of every horizon, has probability below `ε` of both
running `m ≥ M` stages and averaging below `w < ΔF` per stage. -/
theorem stopping_deficit_tendsto_zero {β ΔF w : ℝ} (hβ : 0 < β) (hw : w < ΔF) {ε : ℝ}
    (hε : 0 < ε) :
    ∃ M : ℕ, ∀ m : ℕ, M ≤ m → ∀ (Ω : Type) [Fintype Ω] {n : ℕ} (D : StoppingDemon Ω n),
      D.Dissipative β ΔF → StoppingDemon.rateDeficitProb w D m 0 < ε := by
  have hr : 0 < β * (ΔF - w) := by nlinarith
  obtain ⟨M, hM⟩ := exists_nat_gt (Real.log (1 / ε) / (β * (ΔF - w)))
  refine ⟨M + 1, ?_⟩
  intro m hm Ω _ n D hD
  refine lt_of_le_of_lt (stopping_rate_deficit_bound hβ (le_of_lt hw) D hD m) ?_
  have hmM : Real.log (1 / ε) / (β * (ΔF - w)) < (m : ℝ) := by
    have : (M : ℝ) < (m : ℝ) := by
      exact_mod_cast Nat.lt_of_lt_of_le (Nat.lt_succ_self M) hm
    linarith
  have hkey : Real.log (1 / ε) < (m : ℝ) * (β * (ΔF - w)) := (div_lt_iff₀ hr).mp hmM
  have hlt : Real.exp (-(m : ℝ) * β * (ΔF - w)) < Real.exp (-Real.log (1 / ε)) := by
    apply Real.exp_lt_exp.mpr
    nlinarith
  refine lt_of_lt_of_le hlt (le_of_eq ?_)
  rw [← Real.log_inv]
  simp [Real.exp_log hε]

/-! ## An explicit demon with a genuinely random stopping time -/

section Witness

variable {β ΔF : ℝ}

/-- A stopping demon whose horizon is genuinely random: it runs the catalog's `coinDemon`,
**halts** if the expensive outcome occurs, and otherwise tries the coin once more.  So
`N = 1` with probability `1/2` and `N = 2` with probability `1/2`. -/
def coinStop (β ΔF : ℝ) : StoppingDemon Bool 2 :=
  .step (coinDemon β ΔF)
    (fun b => cond b .halt (.step (coinDemon β ΔF) (fun _ => .halt)))

theorem coinStop_compliant (hβ : 0 < β) : (coinStop β ΔF).Compliant β ΔF := by
  refine ⟨coinDemon_jarzynski hβ, ?_⟩
  intro b
  cases b
  · exact ⟨coinDemon_jarzynski hβ, fun _ => trivial⟩
  · exact trivial

theorem coinStop_dissipative (hβ : 0 < β) : (coinStop β ΔF).Dissipative β ΔF :=
  (coinStop_compliant hβ).dissipative

/-- The stopping time is genuinely random: `E[N] = 3/2`. -/
theorem coinStop_meanStages : (coinStop β ΔF).meanStages = 3 / 2 := by
  simp only [coinStop, StoppingDemon.meanStages_step, StoppingDemon.meanStages_halt,
    Fintype.sum_bool, coinDemon, Bool.cond_true, Bool.cond_false]
  norm_num

/-- `P(N ≥ 2) = 1/2`: the demon reaches a second erasure exactly when the first is cheap. -/
theorem coinStop_deepProb_two : (coinStop β ΔF).deepProb 2 = 1 / 2 := by
  simp only [coinStop, StoppingDemon.deepProb_step, StoppingDemon.deepProb_halt,
    Fintype.sum_bool, coinDemon, Bool.cond_true, Bool.cond_false]
  norm_num

/-- The exact expected total work of the stopping demon.  Compare `coinStop_meanStages`:
the Wald bound `ΔF · E[N] = (3/2)·ΔF` holds with **strict** slack `(3/4)·log(4/3)/β`. -/
theorem coinStop_meanTotalWork (hβ : 0 < β) :
    (coinStop β ΔF).meanTotalWork
      = 3 / 2 * ΔF + 3 / 4 * (Real.log 2 - Real.log (3 / 2)) / β := by
  have hβ' : β ≠ 0 := ne_of_gt hβ
  simp only [coinStop, StoppingDemon.meanTotalWork_step, StoppingDemon.meanTotalWork_halt,
    Fintype.sum_bool, coinDemon, Bool.cond_true, Bool.cond_false]
  field_simp
  ring

/-- The Wald inequality is strict for the coin stopping demon. -/
theorem coinStop_wald_strict (hβ : 0 < β) :
    ΔF * (coinStop β ΔF).meanStages < (coinStop β ΔF).meanTotalWork := by
  have hlog : Real.log (3 / 2) < Real.log 2 :=
    Real.log_lt_log (by norm_num) (by norm_num)
  rw [coinStop_meanStages, coinStop_meanTotalWork hβ]
  have hpos : 0 < 3 / 4 * (Real.log 2 - Real.log (3 / 2)) / β :=
    div_pos (by linarith) hβ
  linarith

/-- **Non-vacuity of the random-horizon bound.**  The exact probability that the coin
stopping demon both survives to a second erasure and averages below the sub-threshold rate
`w = ΔF - log(3/2)/β` is `1/4`, comfortably under the theorem's bound `(2/3)² = 4/9`. -/
theorem coinStop_rateDeficitProb (hβ : 0 < β) :
    StoppingDemon.rateDeficitProb (ΔF - Real.log (3 / 2) / β) (coinStop β ΔF) 2 0 = 1 / 4 := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hlog32 : 0 < Real.log (3 / 2) := Real.log_pos (by norm_num)
  have h1 : 0 < Real.log 2 / β := div_pos hlog2 hβ
  have h2 : 0 < Real.log (3 / 2) / β := div_pos hlog32 hβ
  simp only [coinStop, StoppingDemon.rateDeficitProb_step, StoppingDemon.rateDeficitProb_halt,
    Fintype.sum_bool, coinDemon, Bool.cond_true, Bool.cond_false]
  split_ifs <;> simp_all <;> linarith [div_pos hlog2 hβ, div_pos hlog32 hβ]

/-- …and the theorem's bound for it is `exp(-2 log(3/2)) = 4/9`. -/
theorem coinStop_rate_bound (hβ : 0 < β) :
    StoppingDemon.rateDeficitProb (ΔF - Real.log (3 / 2) / β) (coinStop β ΔF) 2 0
      ≤ Real.exp (-(2 : ℝ) * Real.log (3 / 2)) := by
  have hle : ΔF - Real.log (3 / 2) / β ≤ ΔF := by
    have : 0 < Real.log (3 / 2) / β := div_pos (Real.log_pos (by norm_num)) hβ
    linarith
  have h := stopping_rate_deficit_bound_of_compliant (β := β) (ΔF := ΔF)
      (w := ΔF - Real.log (3 / 2) / β) hβ hle (coinStop β ΔF) (coinStop_compliant hβ) 2
  refine le_trans h (le_of_eq ?_)
  congr 1
  field_simp
  ring

/-- An **unbounded-horizon** family: at every stage the demon runs the coin protocol and
continues only while the cheap outcome keeps occurring, halting as soon as it does not.
Its horizon `n` is arbitrary, so no fixed-depth theorem covers the whole family. -/
def geoStop (β ΔF : ℝ) : ∀ n : ℕ, StoppingDemon Bool n
  | 0 => .halt
  | n + 1 => .step (coinDemon β ΔF) (fun b => cond b .halt (geoStop β ΔF n))

theorem geoStop_compliant (hβ : 0 < β) : ∀ n : ℕ, (geoStop β ΔF n).Compliant β ΔF := by
  intro n
  induction n with
  | zero => exact trivial
  | succ n ih =>
      refine ⟨coinDemon_jarzynski hβ, ?_⟩
      intro b
      cases b
      · exact ih
      · exact trivial

/-- The exact sub-threshold probability of the unbounded-horizon family at horizon `n` is
`(1/2)^n`: the demon must draw the cheap outcome `n` times in a row. -/
theorem geoStop_rateDeficitProb (hβ : 0 < β) : ∀ n : ℕ,
    StoppingDemon.rateDeficitProb (ΔF - Real.log (3 / 2) / β) (geoStop β ΔF n) n 0
      = (1 / 2) ^ n := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hlog32 : 0 < Real.log (3 / 2) := Real.log_pos (by norm_num)
  have h1 : 0 < Real.log 2 / β := div_pos hlog2 hβ
  have h2 : 0 < Real.log (3 / 2) / β := div_pos hlog32 hβ
  intro n
  induction n with
  | zero => simp [geoStop]
  | succ n ih =>
      simp only [geoStop, StoppingDemon.rateDeficitProb_step,
        StoppingDemon.rateDeficitProb_halt, Fintype.sum_bool, coinDemon,
        Bool.cond_true, Bool.cond_false, Nat.add_sub_cancel]
      have hexp : (if n = 0 ∧
          (0 : ℝ) ≤ 0 + (ΔF - Real.log (3 / 2) / β) - (ΔF + Real.log 2 / β) then (1 : ℝ)
            else 0) = 0 := by
        rw [if_neg]
        rintro ⟨-, hle⟩
        linarith
      have hcheap : (0 : ℝ) + (ΔF - Real.log (3 / 2) / β) - (ΔF - Real.log (3 / 2) / β)
          = 0 := by ring
      rw [hexp, hcheap, ih]
      ring

/-- At every horizon the proved bound `(2/3)^n` really does dominate the exact value
`(1/2)^n`, so the theorem has content for arbitrarily long runs. -/
theorem geoStop_bound (hβ : 0 < β) (n : ℕ) :
    StoppingDemon.rateDeficitProb (ΔF - Real.log (3 / 2) / β) (geoStop β ΔF n) n 0
      ≤ Real.exp (-(n : ℝ) * Real.log (3 / 2)) := by
  have hle : ΔF - Real.log (3 / 2) / β ≤ ΔF := by
    have : 0 < Real.log (3 / 2) / β := div_pos (Real.log_pos (by norm_num)) hβ
    linarith
  have h := stopping_rate_deficit_bound_of_compliant (β := β) (ΔF := ΔF)
      (w := ΔF - Real.log (3 / 2) / β) hβ hle (geoStop β ΔF n) (geoStop_compliant hβ n) n
  refine le_trans h (le_of_eq ?_)
  congr 1
  field_simp
  ring

end Witness

end FluctDemon