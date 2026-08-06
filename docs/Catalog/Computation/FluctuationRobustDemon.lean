import Mathlib
import Novelty.ThermodynamicsOfProof

/-!
# Fluctuation-Robust Demon Impossibility

This file resolves, in a finite discrete setting, the conjecture that a Maxwell-type
demon cannot beat the Landauer bound *robustly*: while individual trajectories may
consume less work than `k_B T ln 2` per erased bit, the probability of a **total** work
deficit over `n` independently erased bits decays **exponentially in `n`**, at a rate
that is completely uniform over the demon's control strategy.

The catalog already contains the expectation-level Landauer theory
(`ThermoProof.landauerCost`, `ThermoProof.erasedBits`, …) which classifies *which*
logical maps must dissipate.  What is added here is the *fluctuation* layer: a finite
Jarzynski/Crooks model, the expectation-level second law derived from it by Jensen's
inequality, and — the main result — a Chernoff-type large-deviation bound for repeated
erasure.

## Main definitions

* `FluctDemon.WorkSystem` — a finite-outcome control protocol: a probability vector on a
  finite outcome type together with the work expended on each outcome.
* `FluctDemon.expAvg` — the Jarzynski exponential average `⟨e^{-βW}⟩`.
* `FluctDemon.Jarzynski` — the Jarzynski equality `⟨e^{-βW}⟩ = e^{-βΔF}` at free-energy
  difference `ΔF`.
* `FluctDemon.CrooksPair` — a discrete Crooks-type fluctuation relation between a forward
  protocol and its time reverse.
* `FluctDemon.jointProb`, `FluctDemon.totalWork` — the product protocol describing `n`
  independent erasures.
* `FluctDemon.deficitProb` — the probability that the total work falls below `n · w`.

## Main results

* `FluctDemon.jarzynski_of_crooks` — a Crooks-type relation implies the Jarzynski equality.
* `FluctDemon.meanWork_ge_of_jarzynski` — **expectation-level second law**: `ΔF ≤ ⟨W⟩`.
* `FluctDemon.single_deficit_bound` — one-shot Chernoff bound `P(W ≤ w) ≤ e^{-β(ΔF - w)}`.
* `FluctDemon.jointProb_sum_one`, `FluctDemon.product_jarzynski` — the Jarzynski equality
  tensorises over independent subsystems.
* `FluctDemon.deficit_concentration` — **the main theorem**: for `n` independent erasures,
  each obeying Jarzynski at free-energy cost `ΔF`,
  `P( ∑ Wᵢ ≤ n·w ) ≤ exp (-n · β · (ΔF - w))`,
  uniformly over the individual protocols (hence over every control strategy whatsoever).
* `FluctDemon.landauer_deficit_concentration` — the same statement with the Landauer
  threshold `ΔF = k_B T log 2` supplied by the catalog's `ThermoProof.landauerCost`.
* `FluctDemon.deficit_tendsto_zero`, `FluctDemon.demon_reliability_bound` — the demon fails:
  the sub-Landauer probability tends to `0`, and any demon claiming success probability
  `≥ δ` can only handle boundedly many bits.
-/

open Finset Real

noncomputable section

namespace FluctDemon

/-! ## Finite work protocols -/

/-- A **finite work system**: a control protocol with finitely many outcomes, a probability
of each outcome and the thermodynamic work expended on it.  This is the finite-memory
demon of the conjecture, stripped to the data that a fluctuation theorem constrains. -/
structure WorkSystem (Ω : Type*) [Fintype Ω] where
  /-- Probability of each outcome. -/
  prob : Ω → ℝ
  /-- Work expended along each outcome trajectory. -/
  work : Ω → ℝ
  prob_nonneg : ∀ ω, 0 ≤ prob ω
  prob_sum : ∑ ω, prob ω = 1

variable {Ω : Type*} [Fintype Ω]

/-- The Jarzynski exponential average `⟨e^{-βW}⟩`. -/
def expAvg (β : ℝ) (S : WorkSystem Ω) : ℝ := ∑ ω, S.prob ω * Real.exp (-β * S.work ω)

/-- The mean work `⟨W⟩`. -/
def meanWork (S : WorkSystem Ω) : ℝ := ∑ ω, S.prob ω * S.work ω

/-- The **Jarzynski equality** at inverse temperature `β` and free-energy difference `ΔF`. -/
def Jarzynski (β ΔF : ℝ) (S : WorkSystem Ω) : Prop := expAvg β S = Real.exp (-β * ΔF)

/-! ## Crooks ⟹ Jarzynski -/

/-- A discrete **Crooks-type fluctuation relation**.  The reverse protocol lives on the same
outcome type, `rev` is the (involutive) time reversal, work is odd under reversal, and the
forward and reverse weights are related by the Crooks factor `e^{β(W - ΔF)}`. -/
structure CrooksPair (β ΔF : ℝ) (Ω : Type*) [Fintype Ω] where
  /-- The forward protocol. -/
  fwd : WorkSystem Ω
  /-- The reverse protocol. -/
  rev : WorkSystem Ω
  /-- Time reversal of trajectories. -/
  flip : Ω ≃ Ω
  /-- Work is odd under time reversal. -/
  work_odd : ∀ ω, rev.work (flip ω) = -fwd.work ω
  /-- The Crooks detailed fluctuation relation. -/
  crooks : ∀ ω, fwd.prob ω = Real.exp (β * (fwd.work ω - ΔF)) * rev.prob (flip ω)

/-- **A Crooks-type detailed fluctuation relation implies the Jarzynski equality.** -/
theorem jarzynski_of_crooks {β ΔF : ℝ} (C : CrooksPair β ΔF Ω) :
    Jarzynski β ΔF C.fwd := by
  unfold Jarzynski expAvg
  have step : ∀ ω : Ω,
      C.fwd.prob ω * Real.exp (-β * C.fwd.work ω)
        = Real.exp (-β * ΔF) * C.rev.prob (C.flip ω) := by
    intro ω
    rw [C.crooks ω]
    rw [mul_assoc, mul_comm (C.rev.prob (C.flip ω)), ← mul_assoc, ← Real.exp_add]
    ring_nf
  rw [Finset.sum_congr rfl (fun ω _ => step ω), ← Finset.mul_sum]
  have : ∑ ω : Ω, C.rev.prob (C.flip ω) = ∑ ω : Ω, C.rev.prob ω :=
    Fintype.sum_equiv C.flip _ _ (fun _ => rfl)
  rw [this, C.rev.prob_sum, mul_one]

/-! ## The expectation-level second law -/

/-- Jensen's inequality for the exponential average: `e^{-β⟨W⟩} ≤ ⟨e^{-βW}⟩`. -/
theorem exp_meanWork_le_expAvg (β : ℝ) (S : WorkSystem Ω) :
    Real.exp (-β * meanWork S) ≤ expAvg β S := by
  have key :=
    convexOn_exp.map_sum_le (t := (univ : Finset Ω)) (w := S.prob)
      (p := fun ω => -β * S.work ω)
      (fun ω _ => S.prob_nonneg ω) S.prob_sum (fun ω _ => Set.mem_univ _)
  simp only [smul_eq_mul] at key
  have hL : ∑ ω, S.prob ω * (-β * S.work ω) = -β * meanWork S := by
    unfold meanWork
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun ω _ => by ring
  rw [hL] at key
  exact key

/-- **Expectation-level second law / Landauer bound.**  Any protocol obeying the Jarzynski
equality expends at least `ΔF` work on average. -/
theorem meanWork_ge_of_jarzynski {β ΔF : ℝ} (hβ : 0 < β) {S : WorkSystem Ω}
    (hJ : Jarzynski β ΔF S) : ΔF ≤ meanWork S := by
  have h := exp_meanWork_le_expAvg β S
  rw [hJ] at h
  have h2 : -β * meanWork S ≤ -β * ΔF := Real.exp_le_exp.mp h
  nlinarith

/-! ## One-shot Chernoff bound -/

/-- The probability that the work of a single protocol is at most `w`. -/
def singleDeficitProb (w : ℝ) (S : WorkSystem Ω) : ℝ :=
  ∑ ω ∈ univ.filter (fun ω => S.work ω ≤ w), S.prob ω

/-- **One-shot fluctuation bound.**  The probability of a sub-`ΔF` work trajectory is at
most `e^{-β(ΔF - w)}`; already exponentially small in the size of the deficit. -/
theorem single_deficit_bound {β ΔF w : ℝ} (hβ : 0 < β) {S : WorkSystem Ω}
    (hJ : Jarzynski β ΔF S) :
    singleDeficitProb w S ≤ Real.exp (-β * (ΔF - w)) := by
  classical
  set A : Finset Ω := univ.filter (fun ω => S.work ω ≤ w) with hA
  have h1 : Real.exp (-β * w) * singleDeficitProb w S
      ≤ ∑ ω ∈ A, S.prob ω * Real.exp (-β * S.work ω) := by
    unfold singleDeficitProb
    rw [← hA, Finset.mul_sum]
    refine Finset.sum_le_sum fun ω hω => ?_
    have hw : S.work ω ≤ w := by
      have := Finset.mem_filter.mp (hA ▸ hω)
      exact this.2
    have : Real.exp (-β * w) ≤ Real.exp (-β * S.work ω) := by
      apply Real.exp_le_exp.mpr; nlinarith
    calc Real.exp (-β * w) * S.prob ω ≤ Real.exp (-β * S.work ω) * S.prob ω :=
          mul_le_mul_of_nonneg_right this (S.prob_nonneg ω)
      _ = S.prob ω * Real.exp (-β * S.work ω) := mul_comm _ _
  have h2 : ∑ ω ∈ A, S.prob ω * Real.exp (-β * S.work ω) ≤ expAvg β S := by
    unfold expAvg
    refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _) ?_
    intro ω _ _
    exact mul_nonneg (S.prob_nonneg ω) (Real.exp_nonneg _)
  rw [hJ] at h2
  have h3 : Real.exp (-β * w) * singleDeficitProb w S ≤ Real.exp (-β * ΔF) := le_trans h1 h2
  have hpos : (0:ℝ) < Real.exp (-β * w) := Real.exp_pos _
  rw [← le_div_iff₀' hpos, ← Real.exp_sub] at h3
  refine le_trans h3 (le_of_eq ?_)
  congr 1
  ring

/-! ## Independent repetition -/

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The joint probability of an outcome tuple for independent subsystems. -/
def jointProb {Ω : ι → Type*} [∀ i, Fintype (Ω i)] (S : ∀ i, WorkSystem (Ω i))
    (x : ∀ i, Ω i) : ℝ := ∏ i, (S i).prob (x i)

/-- The total work expended by all subsystems on an outcome tuple. -/
def totalWork {Ω : ι → Type*} [∀ i, Fintype (Ω i)] (S : ∀ i, WorkSystem (Ω i))
    (x : ∀ i, Ω i) : ℝ := ∑ i, (S i).work (x i)

omit [DecidableEq ι] in
lemma jointProb_nonneg {Ω : ι → Type*} [∀ i, Fintype (Ω i)] (S : ∀ i, WorkSystem (Ω i))
    (x : ∀ i, Ω i) : 0 ≤ jointProb S x :=
  Finset.prod_nonneg fun i _ => (S i).prob_nonneg _

/-- The product distribution is a probability distribution. -/
theorem jointProb_sum_one {Ω : ι → Type*} [∀ i, Fintype (Ω i)] (S : ∀ i, WorkSystem (Ω i)) :
    ∑ x ∈ Fintype.piFinset (fun i => (univ : Finset (Ω i))), jointProb S x = 1 := by
  classical
  unfold jointProb
  rw [← Finset.prod_univ_sum]
  simp [fun i => (S i).prob_sum]

/-- **Tensorisation of the Jarzynski equality.**  If each of finitely many independent
subsystems obeys Jarzynski at free-energy cost `ΔF`, the joint system obeys it at cost
`|ι| · ΔF`. -/
theorem product_jarzynski {Ω : ι → Type*} [∀ i, Fintype (Ω i)] (S : ∀ i, WorkSystem (Ω i))
    {β ΔF : ℝ} (hJ : ∀ i, Jarzynski β ΔF (S i)) :
    ∑ x ∈ Fintype.piFinset (fun i => (univ : Finset (Ω i))),
        jointProb S x * Real.exp (-β * totalWork S x)
      = Real.exp (-β * (Fintype.card ι * ΔF)) := by
  classical
  have hprod := Finset.prod_univ_sum (fun i => (univ : Finset (Ω i)))
      (fun i ω => (S i).prob ω * Real.exp (-β * (S i).work ω))
  have hleft : ∏ i, ∑ ω : Ω i, (S i).prob ω * Real.exp (-β * (S i).work ω)
      = Real.exp (-β * (Fintype.card ι * ΔF)) := by
    have : ∀ i : ι, ∑ ω : Ω i, (S i).prob ω * Real.exp (-β * (S i).work ω)
        = Real.exp (-β * ΔF) := fun i => hJ i
    rw [Finset.prod_congr rfl (fun i _ => this i), Finset.prod_const, ← Real.exp_nsmul]
    · rw [Finset.card_univ]
      congr 1
      ring
  rw [hleft] at hprod
  rw [hprod]
  refine Finset.sum_congr rfl fun x _ => ?_
  unfold jointProb totalWork
  rw [Finset.mul_sum, Real.exp_sum, ← Finset.prod_mul_distrib]

/-! ## The main concentration theorem -/

/-- The probability that the **total** work of `n` independent erasures is at most `n · w`. -/
def deficitProb {Ω : ι → Type*} [∀ i, Fintype (Ω i)] [∀ i, DecidableEq (Ω i)]
    (S : ∀ i, WorkSystem (Ω i)) (w : ℝ) : ℝ :=
  ∑ x ∈ (Fintype.piFinset (fun i => (univ : Finset (Ω i)))).filter
      (fun x => totalWork S x ≤ Fintype.card ι * w), jointProb S x

/-- **Fluctuation-robust demon impossibility.**

For any finite family of independent finite-memory protocols, each obeying a
Jarzynski/Crooks-type fluctuation relation with free-energy cost `ΔF`, the probability that
the *total* work falls below `n · w` is at most `exp (-n β (ΔF - w))`, where `n = |ι|` is the
number of erased bits.  When `w < ΔF` this decays exponentially in `n`.

The bound depends only on `β`, `ΔF`, `w` and `n` — not on the outcome spaces, the
probability vectors or the work functions.  Hence it holds *uniformly over every control
strategy*, in particular over every polynomial-time one. -/
theorem deficit_concentration {Ω : ι → Type*} [∀ i, Fintype (Ω i)] [∀ i, DecidableEq (Ω i)]
    (S : ∀ i, WorkSystem (Ω i)) {β ΔF w : ℝ} (hβ : 0 < β)
    (hJ : ∀ i, Jarzynski β ΔF (S i)) :
    deficitProb S w ≤ Real.exp (-(Fintype.card ι : ℝ) * β * (ΔF - w)) := by
  classical
  set n : ℝ := (Fintype.card ι : ℝ) with hn
  set U : Finset (∀ i, Ω i) := Fintype.piFinset (fun i => (univ : Finset (Ω i))) with hU
  set A : Finset (∀ i, Ω i) := U.filter (fun x => totalWork S x ≤ n * w) with hA
  have h1 : Real.exp (-β * (n * w)) * deficitProb S w
      ≤ ∑ x ∈ A, jointProb S x * Real.exp (-β * totalWork S x) := by
    unfold deficitProb
    rw [← hU, ← hn, ← hA, Finset.mul_sum]
    refine Finset.sum_le_sum fun x hx => ?_
    have hw : totalWork S x ≤ n * w := (Finset.mem_filter.mp hx).2
    have hexp : Real.exp (-β * (n * w)) ≤ Real.exp (-β * totalWork S x) := by
      apply Real.exp_le_exp.mpr; nlinarith
    calc Real.exp (-β * (n * w)) * jointProb S x
        ≤ Real.exp (-β * totalWork S x) * jointProb S x :=
          mul_le_mul_of_nonneg_right hexp (jointProb_nonneg S x)
      _ = jointProb S x * Real.exp (-β * totalWork S x) := mul_comm _ _
  have h2 : ∑ x ∈ A, jointProb S x * Real.exp (-β * totalWork S x)
      ≤ Real.exp (-β * (n * ΔF)) := by
    rw [← product_jarzynski S hJ]
    refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _) ?_
    intro x _ _
    exact mul_nonneg (jointProb_nonneg S x) (Real.exp_nonneg _)
  have h3 : Real.exp (-β * (n * w)) * deficitProb S w ≤ Real.exp (-β * (n * ΔF)) :=
    le_trans h1 h2
  have hpos : (0:ℝ) < Real.exp (-β * (n * w)) := Real.exp_pos _
  rw [← le_div_iff₀' hpos, ← Real.exp_sub] at h3
  refine le_trans h3 (le_of_eq ?_)
  congr 1
  ring

/-- **Landauer form.**  Specialising the free-energy cost to the Landauer value
`k_B T log 2` of erasing one bit (the catalog's `ThermoProof.landauerCost 1 kB T`),
the probability that `n` independent erasures spend less than `n · w` of work is at most
`exp (-n β (k_B T log 2 - w))`. -/
theorem landauer_deficit_concentration {Ω : ι → Type*} [∀ i, Fintype (Ω i)]
    [∀ i, DecidableEq (Ω i)] (S : ∀ i, WorkSystem (Ω i)) {β kB T w : ℝ} (hβ : 0 < β)
    (hJ : ∀ i, Jarzynski β (ThermoProof.landauerCost 1 kB T) (S i)) :
    deficitProb S w
      ≤ Real.exp (-(Fintype.card ι : ℝ) * β * (kB * T * Real.log 2 - w)) := by
  have h := deficit_concentration (w := w) S hβ hJ
  simpa [ThermoProof.landauerCost] using h

/-- Below the Landauer threshold the bound is a genuine exponential decay: the base is
`< 1`. -/
theorem deficit_bound_lt_one {Ω : ι → Type*} [∀ i, Fintype (Ω i)] [∀ i, DecidableEq (Ω i)]
    (S : ∀ i, WorkSystem (Ω i)) {β ΔF w : ℝ} (hβ : 0 < β) (hw : w < ΔF)
    (hcard : 0 < Fintype.card ι) (hJ : ∀ i, Jarzynski β ΔF (S i)) :
    deficitProb S w < 1 := by
  refine lt_of_le_of_lt (deficit_concentration S hβ hJ) ?_
  rw [Real.exp_lt_one_iff]
  have hn : (0:ℝ) < (Fintype.card ι : ℝ) := by exact_mod_cast hcard
  nlinarith [mul_pos (mul_pos hn hβ) (sub_pos.mpr hw)]

/-- **The demon fails in the long run.**  Along any sequence of independent sub-Landauer
attempts the success probability is squeezed to `0` at an exponential rate, uniformly in
the protocols used. -/
theorem deficit_tendsto_zero {β ΔF w : ℝ} (hβ : 0 < β) (hw : w < ΔF) (ε : ℝ) (hε : 0 < ε) :
    ∃ N : ℕ, ∀ (n : ℕ), N ≤ n →
      ∀ {Ω : Fin n → Type} [∀ i, Fintype (Ω i)] [∀ i, DecidableEq (Ω i)]
        (S : ∀ i, WorkSystem (Ω i)), (∀ i, Jarzynski β ΔF (S i)) →
        deficitProb S w < ε := by
  have hr : 0 < β * (ΔF - w) := by nlinarith
  obtain ⟨N, hN⟩ := exists_nat_gt (Real.log (1 / ε) / (β * (ΔF - w)))
  refine ⟨N + 1, ?_⟩
  intro n hn Ω _ _ S hJ
  have hcard : (Fintype.card (Fin n) : ℝ) = n := by simp
  have hbound := deficit_concentration (w := w) S hβ hJ
  rw [hcard] at hbound
  refine lt_of_le_of_lt hbound ?_
  have hnN : Real.log (1 / ε) / (β * (ΔF - w)) < (n : ℝ) := by
    have : (N : ℝ) < (n : ℝ) := by exact_mod_cast Nat.lt_of_lt_of_le (Nat.lt_succ_self N) hn
    linarith
  have hkey : Real.log (1 / ε) < (n : ℝ) * (β * (ΔF - w)) :=
    (div_lt_iff₀ hr).mp hnN
  have : Real.exp (-(n : ℝ) * β * (ΔF - w)) < Real.exp (-Real.log (1 / ε)) := by
    apply Real.exp_lt_exp.mpr
    nlinarith
  refine lt_of_lt_of_le this (le_of_eq ?_)
  rw [← Real.log_inv]
  simp [Real.exp_log hε]

/-- **Reliability bound for a finite-memory demon.**  If a demon claims to erase `n`
independent bits with total work below `n · w` (with `w` strictly below the free-energy
threshold) and succeeds with probability at least `δ > 0`, then `n` is bounded:
`n ≤ log (1/δ) / (β (ΔF - w))`.  No control strategy, however clever or however long it
runs, can push this further. -/
theorem demon_reliability_bound {n : ℕ} {Ω : Fin n → Type} [∀ i, Fintype (Ω i)]
    [∀ i, DecidableEq (Ω i)] (S : ∀ i, WorkSystem (Ω i)) {β ΔF w δ : ℝ}
    (hβ : 0 < β) (hw : w < ΔF) (hδ : 0 < δ)
    (hJ : ∀ i, Jarzynski β ΔF (S i)) (hsucc : δ ≤ deficitProb S w) :
    (n : ℝ) ≤ Real.log (1 / δ) / (β * (ΔF - w)) := by
  have hr : 0 < β * (ΔF - w) := by nlinarith
  have hcard : (Fintype.card (Fin n) : ℝ) = n := by simp
  have hbound := deficit_concentration (w := w) S hβ hJ
  rw [hcard] at hbound
  have hδle : δ ≤ Real.exp (-(n : ℝ) * β * (ΔF - w)) := le_trans hsucc hbound
  have hlog : Real.log δ ≤ -(n : ℝ) * β * (ΔF - w) := by
    have := Real.log_le_log hδ hδle
    rwa [Real.log_exp] at this
  rw [le_div_iff₀ hr]
  have : Real.log (1 / δ) = -Real.log δ := by
    rw [one_div, Real.log_inv]
  rw [this]
  nlinarith

/-! ## A genuine sub-threshold demon: the bounds are not vacuous -/

section Witness

variable {β ΔF : ℝ}

/-- An explicit two-outcome demon obeying the Jarzynski equality at free-energy cost `ΔF`,
which nevertheless spends **strictly less** work than `ΔF` half of the time.  This shows the
fluctuation framework is not vacuous: single-shot violations of the Landauer threshold do
occur with constant probability, and only the *repeated* bound of `deficit_concentration`
rules the demon out. -/
def coinDemon (β ΔF : ℝ) : WorkSystem Bool where
  prob := fun _ => 1 / 2
  work := fun b => cond b (ΔF + Real.log 2 / β) (ΔF - Real.log (3 / 2) / β)
  prob_nonneg := fun _ => by norm_num
  prob_sum := by norm_num

/-- The coin demon obeys the Jarzynski equality exactly. -/
theorem coinDemon_jarzynski (hβ : 0 < β) : Jarzynski β ΔF (coinDemon β ΔF) := by
  have hβ' : β ≠ 0 := ne_of_gt hβ
  unfold Jarzynski expAvg coinDemon
  rw [Fintype.sum_bool]
  have e1 : -β * (ΔF + Real.log 2 / β) = -β * ΔF + -Real.log 2 := by
    field_simp; ring
  have e2 : -β * (ΔF - Real.log (3 / 2) / β) = -β * ΔF + Real.log (3 / 2) := by
    field_simp; ring
  simp only [Bool.cond_true, Bool.cond_false, e1, e2, Real.exp_add]
  rw [Real.exp_log (by norm_num : (0:ℝ) < 3 / 2)]
  have hexp2 : Real.exp (-Real.log 2) = 1 / 2 := by
    rw [← Real.log_inv, Real.exp_log (by norm_num)]; norm_num
  rw [hexp2]
  ring

/-- The cheap outcome of the coin demon costs strictly less than the free-energy threshold. -/
theorem coinDemon_work_lt (hβ : 0 < β) : (coinDemon β ΔF).work false < ΔF := by
  have h32 : 0 < Real.log (3 / 2) := Real.log_pos (by norm_num)
  have : 0 < Real.log (3 / 2) / β := div_pos h32 hβ
  simp only [coinDemon, Bool.cond_false]
  linarith

/-- **Constant single-shot violation probability.**  At the sub-threshold level
`w = ΔF - log(3/2)/β` the coin demon appears to beat the Landauer bound with probability
at least `1/2`. -/
theorem coinDemon_singleDeficitProb_ge {w : ℝ}
    (hw : (coinDemon β ΔF).work false ≤ w) :
    1 / 2 ≤ singleDeficitProb w (coinDemon β ΔF) := by
  classical
  unfold singleDeficitProb
  have hmem : false ∈ (univ : Finset Bool).filter
      (fun ω => (coinDemon β ΔF).work ω ≤ w) := by
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    exact hw
  have := Finset.single_le_sum
    (f := fun ω => (coinDemon β ΔF).prob ω)
    (fun i _ => (coinDemon β ΔF).prob_nonneg i) hmem
  simpa [coinDemon] using this

/-- Yet the one-shot Chernoff bound is still respected, and for `n` independent copies the
apparent violation probability is squeezed below `(2/3)^n`: the demon's constant-probability
single-bit advantage does **not** survive repetition. -/
theorem coinDemon_repeated_bound {n : ℕ} (hβ : 0 < β) :
    deficitProb (fun _ : Fin n => coinDemon β ΔF) (ΔF - Real.log (3 / 2) / β)
      ≤ Real.exp (-(n : ℝ) * Real.log (3 / 2)) := by
  have hcard : (Fintype.card (Fin n) : ℝ) = n := by simp
  have h := deficit_concentration (ι := Fin n) (w := ΔF - Real.log (3 / 2) / β)
      (fun _ => coinDemon β ΔF) hβ (fun _ => coinDemon_jarzynski hβ)
  rw [hcard] at h
  refine le_trans h (le_of_eq ?_)
  congr 1
  field_simp
  ring

end Witness

end FluctDemon