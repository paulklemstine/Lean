import Mathlib
import Computation.FluctuationRobustDemon

/-!
# Adaptive Fluctuation-Robust Demon Impossibility

`Catalog/Computation/FluctuationRobustDemon.lean` proved a Chernoff-type large-deviation
bound

```
P( ∑_{i<n} W_i ≤ n·w )  ≤  exp ( -n·β·(ΔF - w) )
```

for `n` **independent** finite-outcome protocols each obeying the Jarzynski equality at
free-energy cost `ΔF`.  Its proof tensorised the Jarzynski equality
(`FluctDemon.product_jarzynski`), so it says nothing about a demon that *adapts*: one that
inspects the outcome of the first erasure before choosing how to perform the second.
Adaptivity is exactly what a computational control strategy has, so closing this gap is
what turns the bound into a statement about algorithms.

This file removes the independence hypothesis, which was Conjecture 2 of the previous
cycle's `FUTURE_DIRECTIONS.md`.  An adaptive demon is modelled by a finite decision tree
(`FluctDemon.AdaptiveDemon`): at each of `n` stages it runs a finite work system whose
choice may depend on the entire history of observed outcomes.  The main theorem
`FluctDemon.adaptive_deficit_bound` shows that the *same* exponential bound holds — indeed
in the sharper, threshold-free form

```
P( total work ≤ t )  ≤  exp ( -β·(n·ΔF - t) ),
```

with no independence and no product structure anywhere.  The proof replaces tensorisation
by an induction on the tree, which is the finite avatar of the optional-stopping argument
for the supermartingale `exp(-β ∑_{i≤k} W_i + kβΔF)`.

## Main definitions

* `FluctDemon.AdaptiveDemon` — an `n`-stage history-dependent control strategy.
* `FluctDemon.AdaptiveDemon.Compliant` — every node obeys the Jarzynski equality at `(β, ΔF)`.
* `FluctDemon.AdaptiveDemon.deficitProb` — the probability that the total work over all `n`
  stages is at most `t`.
* `FluctDemon.AdaptiveDemon.meanTotalWork` — the expected total work.
* `FluctDemon.AdaptiveDemon.expWorkAvg` — the tree-level Jarzynski average
  `⟨e^{-β·(total work)}⟩`.

## Main results

* `FluctDemon.AdaptiveDemon.expWorkAvg_eq` — **adaptive tensorisation**: a compliant
  `n`-stage strategy satisfies the Jarzynski equality at cost `n·ΔF` *exactly*, adaptivity
  notwithstanding.
* `FluctDemon.adaptive_deficit_bound_of_dissipative`, `FluctDemon.adaptive_deficit_bound` —
  **main theorem**: `P(total work ≤ t) ≤ exp(-β(n·ΔF - t))` for every adaptive strategy each
  of whose stages dissipates at least `ΔF` (in particular for every Jarzynski-compliant one).
* `FluctDemon.adaptive_deficit_concentration` — the `t = n·w` form, matching (and
  strictly generalising) `FluctDemon.deficit_concentration`.
* `FluctDemon.adaptive_meanWork_ge` — expectation-level second law for adaptive strategies.
* `FluctDemon.adaptive_reliability_bound`, `FluctDemon.adaptive_deficit_tendsto_zero` — an
  adaptive demon succeeding with probability `≥ δ` can only handle `n ≤ log(1/δ)/(β(ΔF-w))`
  bits, and its success probability tends to `0`.
* `FluctDemon.coinStage_deficitProb`, `FluctDemon.trueAdaptiveCoin_deficitProb` — an
  explicitly *history-dependent* witness: its one-stage sub-threshold probability is exactly
  `1/2` and its two-stage one exactly `1/4`, against the bound `(2/3)² = 4/9`.  So the
  theorem is not vacuous and the bound is not attained trivially.
-/

open Finset Real

noncomputable section

namespace FluctDemon

variable {Ω : Type*} [Fintype Ω]

/-! ## Adaptive strategies as finite decision trees -/

/-- An **adaptive demon** with `n` remaining stages: at each stage it runs a finite work
system, observes the outcome, and chooses the strategy for the remaining stages as a
function of that outcome.  Unfolding the recursion, the protocol used at stage `k` depends
on the whole history `ω₁,…,ω_{k-1}`, so this is the fully general finite-memory adaptive
control strategy. -/
inductive AdaptiveDemon (Ω : Type*) [Fintype Ω] : ℕ → Type _
  /-- The empty strategy: no stages left. -/
  | done : AdaptiveDemon Ω 0
  /-- Run `S`, then continue with `next ω` after observing outcome `ω`. -/
  | step {n : ℕ} (S : WorkSystem Ω) (next : Ω → AdaptiveDemon Ω n) : AdaptiveDemon Ω (n + 1)

namespace AdaptiveDemon

/-- Every stage of the strategy — for every history — obeys the Jarzynski equality at
inverse temperature `β` and free-energy cost `ΔF`. -/
def Compliant (β ΔF : ℝ) : ∀ {n : ℕ}, AdaptiveDemon Ω n → Prop
  | _, .done => True
  | _, .step S next => Jarzynski β ΔF S ∧ ∀ ω, Compliant β ΔF (next ω)

/-- A weaker, one-sided compliance: every stage merely **dissipates at least** `ΔF`, in the
sense of the Jarzynski *inequality* `⟨e^{-βW}⟩ ≤ e^{-βΔF}`.  Genuine Jarzynski compliance is
the special case of equality. -/
def Dissipative (β ΔF : ℝ) : ∀ {n : ℕ}, AdaptiveDemon Ω n → Prop
  | _, .done => True
  | _, .step S next => expAvg β S ≤ Real.exp (-β * ΔF) ∧ ∀ ω, Dissipative β ΔF (next ω)

/-- Jarzynski compliance implies the one-sided dissipativity condition. -/
theorem Compliant.dissipative {β ΔF : ℝ} :
    ∀ {n : ℕ} {D : AdaptiveDemon Ω n}, D.Compliant β ΔF → D.Dissipative β ΔF := by
  intro n
  induction n with
  | zero => intro D _; cases D; exact trivial
  | succ n ih =>
      intro D hD
      cases D with
      | step S next =>
          obtain ⟨hS, hnext⟩ := hD
          exact ⟨le_of_eq hS, fun ω => ih (hnext ω)⟩

/-- The probability that the **total** work accumulated over all remaining stages is at
most `t`.  Computed by conditioning on the first outcome: the threshold for the remaining
stages is lowered by the work just spent. -/
def deficitProb : ∀ {n : ℕ}, AdaptiveDemon Ω n → ℝ → ℝ
  | _, .done, t => if 0 ≤ t then 1 else 0
  | _, .step S next, t => ∑ ω, S.prob ω * deficitProb (next ω) (t - S.work ω)

/-- The Jarzynski exponential average `⟨e^{-β·(total work)}⟩` of an adaptive strategy. -/
def expWorkAvg (β : ℝ) : ∀ {n : ℕ}, AdaptiveDemon Ω n → ℝ
  | _, .done => 1
  | _, .step S next =>
      ∑ ω, S.prob ω * (Real.exp (-β * S.work ω) * expWorkAvg β (next ω))

/-- The expected total work of an adaptive strategy. -/
def meanTotalWork : ∀ {n : ℕ}, AdaptiveDemon Ω n → ℝ
  | _, .done => 0
  | _, .step S next => ∑ ω, S.prob ω * (S.work ω + meanTotalWork (next ω))

@[simp] lemma deficitProb_done (t : ℝ) :
    (AdaptiveDemon.done (Ω := Ω)).deficitProb t = if 0 ≤ t then 1 else 0 := rfl

@[simp] lemma deficitProb_step {n : ℕ} (S : WorkSystem Ω) (next : Ω → AdaptiveDemon Ω n)
    (t : ℝ) :
    (AdaptiveDemon.step S next).deficitProb t
      = ∑ ω, S.prob ω * (next ω).deficitProb (t - S.work ω) := rfl

@[simp] lemma expWorkAvg_done (β : ℝ) : expWorkAvg β (AdaptiveDemon.done (Ω := Ω)) = 1 := rfl

@[simp] lemma expWorkAvg_step (β : ℝ) {n : ℕ} (S : WorkSystem Ω)
    (next : Ω → AdaptiveDemon Ω n) :
    expWorkAvg β (AdaptiveDemon.step S next)
      = ∑ ω, S.prob ω * (Real.exp (-β * S.work ω) * expWorkAvg β (next ω)) := rfl

@[simp] lemma meanTotalWork_done : meanTotalWork (AdaptiveDemon.done (Ω := Ω)) = 0 := rfl

@[simp] lemma meanTotalWork_step {n : ℕ} (S : WorkSystem Ω) (next : Ω → AdaptiveDemon Ω n) :
    meanTotalWork (AdaptiveDemon.step S next)
      = ∑ ω, S.prob ω * (S.work ω + meanTotalWork (next ω)) := rfl

/-- Deficit probabilities are genuine probabilities: nonnegative. -/
theorem deficitProb_nonneg : ∀ {n : ℕ} (D : AdaptiveDemon Ω n) (t : ℝ), 0 ≤ D.deficitProb t := by
  intro n
  induction n with
  | zero =>
      intro D t
      cases D
      simp only [deficitProb_done]
      split <;> norm_num
  | succ n ih =>
      intro D t
      cases D with
      | step S next =>
          simp only [deficitProb_step]
          exact Finset.sum_nonneg fun ω _ => mul_nonneg (S.prob_nonneg ω) (ih (next ω) _)

/-- Deficit probabilities are genuine probabilities: at most `1`. -/
theorem deficitProb_le_one : ∀ {n : ℕ} (D : AdaptiveDemon Ω n) (t : ℝ), D.deficitProb t ≤ 1 := by
  intro n
  induction n with
  | zero =>
      intro D t
      cases D
      simp only [deficitProb_done]
      split <;> norm_num
  | succ n ih =>
      intro D t
      cases D with
      | step S next =>
          simp only [deficitProb_step]
          calc ∑ ω, S.prob ω * (next ω).deficitProb (t - S.work ω)
              ≤ ∑ ω, S.prob ω * 1 :=
                Finset.sum_le_sum fun ω _ =>
                  mul_le_mul_of_nonneg_left (ih (next ω) _) (S.prob_nonneg ω)
            _ = 1 := by simpa using S.prob_sum

/-- **Adaptive tensorisation of the Jarzynski equality.**  If every node of an `n`-stage
adaptive strategy obeys the Jarzynski equality at cost `ΔF`, then the total work of the
whole strategy obeys it at cost `n · ΔF` — *exactly*, and with no independence assumption
whatsoever.  This is the finite decision-tree form of the statement that
`exp(-β ∑_{i ≤ k} W_i + kβΔF)` is a martingale. -/
theorem expWorkAvg_eq {β ΔF : ℝ} :
    ∀ {n : ℕ} (D : AdaptiveDemon Ω n), D.Compliant β ΔF →
      expWorkAvg β D = Real.exp (-β * ((n : ℝ) * ΔF)) := by
  intro n
  induction n with
  | zero =>
      intro D _
      cases D
      simp
  | succ n ih =>
      intro D hD
      cases D with
      | step S next =>
          obtain ⟨hS, hnext⟩ := hD
          simp only [expWorkAvg_step]
          have hsub : ∀ ω : Ω, expWorkAvg β (next ω) = Real.exp (-β * ((n : ℝ) * ΔF)) :=
            fun ω => ih (next ω) (hnext ω)
          calc ∑ ω, S.prob ω * (Real.exp (-β * S.work ω) * expWorkAvg β (next ω))
              = Real.exp (-β * ((n : ℝ) * ΔF)) *
                  ∑ ω, S.prob ω * Real.exp (-β * S.work ω) := by
                rw [Finset.mul_sum]
                exact Finset.sum_congr rfl fun ω _ => by rw [hsub ω]; ring
            _ = Real.exp (-β * ((n : ℝ) * ΔF)) * Real.exp (-β * ΔF) := by
                rw [show ∑ ω, S.prob ω * Real.exp (-β * S.work ω) = expAvg β S from rfl, hS]
            _ = Real.exp (-β * (((n : ℝ) + 1) * ΔF)) := by
                rw [← Real.exp_add]; congr 1; ring
            _ = Real.exp (-β * (((n + 1 : ℕ) : ℝ) * ΔF)) := by push_cast; ring_nf

end AdaptiveDemon

/-! ## The adaptive concentration theorem -/

/-- **Fluctuation-robust demon impossibility, adaptive version.**

For *every* adaptive finite-memory control strategy whose every stage obeys a
Jarzynski/Crooks-type fluctuation relation at free-energy cost `ΔF`, the probability that
the total work over `n` stages falls below `t` is at most `exp(-β·(n·ΔF - t))`.

No independence is assumed: the protocol used at each stage may depend arbitrarily on all
previously observed outcomes.  The bound involves only `β, ΔF, t, n`, so it is uniform
over all strategies, in particular over all polynomial-time ones.

This version assumes only the one-sided condition `Dissipative` (`⟨e^{-βW}⟩ ≤ e^{-βΔF}` at
every stage); `adaptive_deficit_bound` is the Jarzynski-equality corollary. -/
theorem adaptive_deficit_bound_of_dissipative {β ΔF : ℝ} (hβ : 0 < β) :
    ∀ {n : ℕ} (D : AdaptiveDemon Ω n), D.Dissipative β ΔF → ∀ t : ℝ,
      D.deficitProb t ≤ Real.exp (-β * ((n : ℝ) * ΔF - t)) := by
  intro n
  induction n with
  | zero =>
      intro D _ t
      cases D
      simp only [AdaptiveDemon.deficitProb_done, Nat.cast_zero, zero_mul, zero_sub]
      by_cases h : 0 ≤ t
      · rw [if_pos h]
        have h1 : (1 : ℝ) = Real.exp 0 := by simp
        rw [h1]
        exact Real.exp_le_exp.mpr (by nlinarith)
      · rw [if_neg h]
        exact le_of_lt (Real.exp_pos _)
  | succ n ih =>
      intro D hD t
      cases D with
      | step S next =>
          obtain ⟨hS, hnext⟩ := hD
          simp only [AdaptiveDemon.deficitProb_step]
          have hterm : ∀ ω : Ω,
              S.prob ω * (next ω).deficitProb (t - S.work ω)
                ≤ S.prob ω *
                  (Real.exp (-β * ((n : ℝ) * ΔF - t)) * Real.exp (-β * S.work ω)) := by
            intro ω
            refine mul_le_mul_of_nonneg_left ?_ (S.prob_nonneg ω)
            refine le_trans (ih (next ω) (hnext ω) (t - S.work ω)) (le_of_eq ?_)
            rw [← Real.exp_add]; congr 1; ring
          calc ∑ ω, S.prob ω * (next ω).deficitProb (t - S.work ω)
              ≤ ∑ ω, S.prob ω *
                  (Real.exp (-β * ((n : ℝ) * ΔF - t)) * Real.exp (-β * S.work ω)) :=
                Finset.sum_le_sum fun ω _ => hterm ω
            _ = Real.exp (-β * ((n : ℝ) * ΔF - t)) *
                  ∑ ω, S.prob ω * Real.exp (-β * S.work ω) := by
                rw [Finset.mul_sum]
                exact Finset.sum_congr rfl fun ω _ => by ring
            _ ≤ Real.exp (-β * ((n : ℝ) * ΔF - t)) * Real.exp (-β * ΔF) := by
                rw [show ∑ ω, S.prob ω * Real.exp (-β * S.work ω) = expAvg β S from rfl]
                exact mul_le_mul_of_nonneg_left hS (le_of_lt (Real.exp_pos _))
            _ = Real.exp (-β * (((n + 1 : ℕ) : ℝ) * ΔF - t)) := by
                rw [← Real.exp_add]; push_cast; congr 1; ring

/-- **Fluctuation-robust demon impossibility, adaptive version.**  The Jarzynski-compliant
special case of `adaptive_deficit_bound_of_dissipative`. -/
theorem adaptive_deficit_bound {β ΔF : ℝ} (hβ : 0 < β) {n : ℕ} (D : AdaptiveDemon Ω n)
    (hD : D.Compliant β ΔF) (t : ℝ) :
    D.deficitProb t ≤ Real.exp (-β * ((n : ℝ) * ΔF - t)) :=
  adaptive_deficit_bound_of_dissipative hβ D hD.dissipative t

/-- **Adaptive concentration at a per-bit threshold.**  Taking `t = n · w`, an adaptive
demon spends less than `w` per erased bit with probability at most `exp(-n β (ΔF - w))`:
exactly the bound of `FluctDemon.deficit_concentration`, now without independence. -/
theorem adaptive_deficit_concentration {β ΔF w : ℝ} (hβ : 0 < β) {n : ℕ}
    (D : AdaptiveDemon Ω n) (hD : D.Compliant β ΔF) :
    D.deficitProb ((n : ℝ) * w) ≤ Real.exp (-(n : ℝ) * β * (ΔF - w)) := by
  refine le_trans (adaptive_deficit_bound hβ D hD ((n : ℝ) * w)) (le_of_eq ?_)
  congr 1
  ring

/-- **Expectation-level second law for adaptive strategies.**  A compliant `n`-stage
adaptive demon spends at least `n · ΔF` work on average. -/
theorem adaptive_meanWork_ge {β ΔF : ℝ} (hβ : 0 < β) :
    ∀ {n : ℕ} (D : AdaptiveDemon Ω n), D.Compliant β ΔF →
      (n : ℝ) * ΔF ≤ D.meanTotalWork := by
  intro n
  induction n with
  | zero =>
      intro D _
      cases D
      simp
  | succ n ih =>
      intro D hD
      cases D with
      | step S next =>
          obtain ⟨hS, hnext⟩ := hD
          simp only [AdaptiveDemon.meanTotalWork_step]
          have hsplit : ∑ ω, S.prob ω * (S.work ω + (next ω).meanTotalWork)
              = meanWork S + ∑ ω, S.prob ω * (next ω).meanTotalWork := by
            rw [show meanWork S = ∑ ω, S.prob ω * S.work ω from rfl, ← Finset.sum_add_distrib]
            exact Finset.sum_congr rfl fun ω _ => by ring
          have htail : (n : ℝ) * ΔF ≤ ∑ ω, S.prob ω * (next ω).meanTotalWork := by
            have hle : ∀ ω : Ω, S.prob ω * ((n : ℝ) * ΔF)
                ≤ S.prob ω * (next ω).meanTotalWork := fun ω =>
              mul_le_mul_of_nonneg_left (ih (next ω) (hnext ω)) (S.prob_nonneg ω)
            have hconst : ∑ ω, S.prob ω * ((n : ℝ) * ΔF) = (n : ℝ) * ΔF := by
              rw [← Finset.sum_mul, S.prob_sum, one_mul]
            calc (n : ℝ) * ΔF = ∑ ω, S.prob ω * ((n : ℝ) * ΔF) := hconst.symm
              _ ≤ ∑ ω, S.prob ω * (next ω).meanTotalWork :=
                  Finset.sum_le_sum fun ω _ => hle ω
          have hhead : ΔF ≤ meanWork S := meanWork_ge_of_jarzynski hβ hS
          rw [hsplit]
          push_cast
          linarith

/-- **Reliability bound for an adaptive demon.**  If an adaptive strategy erases `n` bits
with total work below `n · w` (with `w < ΔF`) and succeeds with probability at least
`δ > 0`, then `n ≤ log(1/δ) / (β (ΔF - w))`.  Adaptivity buys the demon nothing. -/
theorem adaptive_reliability_bound {β ΔF w δ : ℝ} (hβ : 0 < β) (hw : w < ΔF) (hδ : 0 < δ)
    {n : ℕ} (D : AdaptiveDemon Ω n) (hD : D.Compliant β ΔF)
    (hsucc : δ ≤ D.deficitProb ((n : ℝ) * w)) :
    (n : ℝ) ≤ Real.log (1 / δ) / (β * (ΔF - w)) := by
  have hr : 0 < β * (ΔF - w) := by nlinarith
  have hδle : δ ≤ Real.exp (-(n : ℝ) * β * (ΔF - w)) :=
    le_trans hsucc (adaptive_deficit_concentration hβ D hD)
  have hlog : Real.log δ ≤ -(n : ℝ) * β * (ΔF - w) := by
    have := Real.log_le_log hδ hδle
    rwa [Real.log_exp] at this
  rw [le_div_iff₀ hr]
  have hinv : Real.log (1 / δ) = -Real.log δ := by rw [one_div, Real.log_inv]
  rw [hinv]
  nlinarith

/-- **The adaptive demon fails in the long run.**  For any target accuracy `ε > 0` there is
an `N` beyond which *every* adaptive strategy on `n ≥ N` bits has sub-threshold probability
below `ε`. -/
theorem adaptive_deficit_tendsto_zero {β ΔF w : ℝ} (hβ : 0 < β) (hw : w < ΔF) {ε : ℝ}
    (hε : 0 < ε) :
    ∃ N : ℕ, ∀ (n : ℕ), N ≤ n → ∀ (Ω : Type) [Fintype Ω] (D : AdaptiveDemon Ω n),
      D.Compliant β ΔF → D.deficitProb ((n : ℝ) * w) < ε := by
  have hr : 0 < β * (ΔF - w) := by nlinarith
  obtain ⟨N, hN⟩ := exists_nat_gt (Real.log (1 / ε) / (β * (ΔF - w)))
  refine ⟨N + 1, ?_⟩
  intro n hn Ω _ D hD
  refine lt_of_le_of_lt (adaptive_deficit_concentration hβ D hD) ?_
  have hnN : Real.log (1 / ε) / (β * (ΔF - w)) < (n : ℝ) := by
    have : (N : ℝ) < (n : ℝ) := by
      exact_mod_cast Nat.lt_of_lt_of_le (Nat.lt_succ_self N) hn
    linarith
  have hkey : Real.log (1 / ε) < (n : ℝ) * (β * (ΔF - w)) := (div_lt_iff₀ hr).mp hnN
  have hlt : Real.exp (-(n : ℝ) * β * (ΔF - w)) < Real.exp (-Real.log (1 / ε)) := by
    apply Real.exp_lt_exp.mpr
    nlinarith
  refine lt_of_lt_of_le hlt (le_of_eq ?_)
  rw [← Real.log_inv]
  simp [Real.exp_log hε]

/-! ## A genuinely history-dependent witness -/

section Witness

variable {β ΔF : ℝ}

/-- The one-stage strategy running the catalog's `coinDemon`. -/
def coinStage (β ΔF : ℝ) : AdaptiveDemon Bool 1 :=
  .step (coinDemon β ΔF) (fun _ => .done)

/-- A **genuinely adaptive** two-stage demon: after the cheap outcome it retries the coin
protocol, after the expensive one it runs a deterministic protocol that pays exactly the
free-energy cost.  The two stages therefore use *different* work systems depending on the
observed history, so this strategy is outside the scope of the independent-product theorem
`FluctDemon.deficit_concentration`. -/
def surePay (ΔF : ℝ) : WorkSystem Bool where
  prob := fun b => cond b 0 1
  work := fun _ => ΔF
  prob_nonneg := fun b => by cases b <;> norm_num
  prob_sum := by simp

/-- `surePay` obeys the Jarzynski equality: it always pays exactly `ΔF`. -/
theorem surePay_jarzynski : Jarzynski β ΔF (surePay ΔF) := by
  unfold Jarzynski expAvg surePay
  rw [Fintype.sum_bool]
  simp

/-- The genuinely adaptive two-stage demon. -/
def trueAdaptiveCoin (β ΔF : ℝ) : AdaptiveDemon Bool 2 :=
  .step (coinDemon β ΔF)
    (fun b => cond b (.step (surePay ΔF) (fun _ => .done))
                     (.step (coinDemon β ΔF) (fun _ => .done)))

theorem coinStage_compliant (hβ : 0 < β) : (coinStage β ΔF).Compliant β ΔF :=
  ⟨coinDemon_jarzynski hβ, fun _ => trivial⟩

theorem trueAdaptiveCoin_compliant (hβ : 0 < β) :
    (trueAdaptiveCoin β ΔF).Compliant β ΔF := by
  refine ⟨coinDemon_jarzynski hβ, ?_⟩
  intro b
  cases b
  · exact ⟨coinDemon_jarzynski hβ, fun _ => trivial⟩
  · exact ⟨surePay_jarzynski, fun _ => trivial⟩

/-- **Non-vacuity.**  On a single stage the coin demon really does appear to beat the
free-energy threshold, with probability exactly `1/2`. -/
theorem coinStage_deficitProb (hβ : 0 < β) :
    (coinStage β ΔF).deficitProb (ΔF - Real.log (3 / 2) / β) = 1 / 2 := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hlog32 : 0 < Real.log (3 / 2) := Real.log_pos (by norm_num)
  have h1 : 0 < Real.log 2 / β := div_pos hlog2 hβ
  have h2 : 0 < Real.log (3 / 2) / β := div_pos hlog32 hβ
  simp only [coinStage, AdaptiveDemon.deficitProb_step, AdaptiveDemon.deficitProb_done,
    Fintype.sum_bool, coinDemon]
  simp only [Bool.cond_true, Bool.cond_false]
  split_ifs
  all_goals first
    | (exfalso; linarith)
    | norm_num

/-- The exact two-stage sub-threshold probability of the genuinely adaptive demon is `1/4`:
after the expensive first outcome the strategy can no longer recover, and after the cheap
one it succeeds only if the coin is cheap again. -/
theorem trueAdaptiveCoin_deficitProb (hβ : 0 < β) :
    (trueAdaptiveCoin β ΔF).deficitProb ((2 : ℝ) * (ΔF - Real.log (3 / 2) / β)) = 1 / 4 := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hlog32 : 0 < Real.log (3 / 2) := Real.log_pos (by norm_num)
  have h1 : 0 < Real.log 2 / β := div_pos hlog2 hβ
  have h2 : 0 < Real.log (3 / 2) / β := div_pos hlog32 hβ
  simp only [trueAdaptiveCoin, AdaptiveDemon.deficitProb_step, AdaptiveDemon.deficitProb_done,
    Fintype.sum_bool, coinDemon, surePay, Bool.cond_true, Bool.cond_false]
  split_ifs
  all_goals first
    | (exfalso; linarith)
    | norm_num

/-- Yet the adaptive bound already squeezes the two-stage genuinely adaptive demon: its
probability of averaging below `ΔF - log(3/2)/β` per bit is at most `(2/3)²`. -/
theorem trueAdaptiveCoin_bound (hβ : 0 < β) :
    (trueAdaptiveCoin β ΔF).deficitProb ((2 : ℝ) * (ΔF - Real.log (3 / 2) / β))
      ≤ Real.exp (-(2 : ℝ) * Real.log (3 / 2)) := by
  have h := adaptive_deficit_concentration (β := β) (ΔF := ΔF)
      (w := ΔF - Real.log (3 / 2) / β) hβ (trueAdaptiveCoin β ΔF)
      (trueAdaptiveCoin_compliant hβ)
  have hcast : ((2 : ℕ) : ℝ) = (2 : ℝ) := by norm_num
  rw [hcast] at h
  refine le_trans h (le_of_eq ?_)
  congr 1
  field_simp
  ring

end Witness

end FluctDemon