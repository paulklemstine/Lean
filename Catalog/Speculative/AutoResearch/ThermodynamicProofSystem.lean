import Mathlib
import Speculative.AutoResearch.ShannonEntropy

/-!
# The Thermodynamic Proof System (TPS)

This file develops a *thermodynamic* model of proof and computation, unifying three
classically separate worlds:

* **Information theory** — Shannon entropy of a finite distribution
  (built on the catalog module `Speculative.AutoResearch.ShannonEntropy`, in
  particular `ShannonEntropy.entropy`, `ShannonEntropy.entropy_uniform` and the
  maximum-entropy theorem `ShannonEntropy.entropy_le_log_card`).
* **Thermodynamics** — Landauer's principle (erasing information dissipates energy)
  and Bennett's principle (logically reversible computation is thermodynamically
  free).
* **Proof complexity** — a *proof* is modelled as an epistemic process that drives a
  finite state space of "possible worlds" from a prior distribution of uncertainty
  toward a determined (proven) state.

## The model

The truth value / answer lives in a finite type `α` of *epistemic microstates*.
A *belief state* is a probability distribution `p : α → ℝ` (an
`ShannonEntropy.IsProbDist`).  A **proof** is a transition `p ⇝ q` that reduces
uncertainty.  Its **thermodynamic cost** at temperature `T` is

  `landauerCost T p q = T · (H(p) − H(q))`,

the energy that must be dissipated to collapse the uncertainty from `p` to `q`
(Landauer: `kT ln 2` per erased bit, with `k = 1` and entropy measured in nats).

## Main results

* `entropy_pointMass` — a fully *determined* (proven) state has zero entropy.
* `pointMass_isProbDist` — a determined state is a genuine probability distribution.
* `reversible_entropy_invariant` / `reversible_free` — **Bennett's principle**:
  relabelling microstates by any permutation (a logically reversible step) leaves
  entropy unchanged, hence costs no energy.
* `landauerCost_nonneg` — a proof that genuinely reduces uncertainty never returns
  energy (second-law flavour).
* `tps_landauer_bound` — **the fundamental Landauer bound**: the cost of proving any
  proposition over an `n`-state world is at most `T · log n`; the state space has a
  finite "information capacity".
* `tps_landauer_tight` — the bound is *attained* starting from maximal ignorance
  (the uniform prior), so `T · log n` is the exact cost of resolving complete
  uncertainty.
* `tps_landauer_bits` — the same capacity expressed in bits is `log₂ n`.

-- !-- Lab Notebook -- !--
Hypothesis:  The catalog's Shannon-entropy layer (`entropy`, `entropy_uniform`,
             `entropy_le_log_card`) is exactly the substrate needed to state and
             prove Landauer's and Bennett's principles as theorems of pure finite
             information theory, with "temperature" entering only as a non-negative
             scalar multiplier.
Result:      Eight theorems, `sorry = 0`.  Determinism ⇒ zero entropy
             (`entropy_pointMass`); reversibility ⇒ entropy invariance
             (`reversible_entropy_invariant`, via `Equiv.sum_comp`); the Landauer
             capacity bound and its tightness are corollaries of the max-entropy
             theorem and `entropy_uniform` respectively.
Insight:     "Proving a proposition" and "erasing a bit" are the *same* operation
             viewed from information theory: both drive entropy down, and the
             max-entropy theorem `H(p) ≤ log n` is simultaneously (a) the bound on
             how much a proof can learn and (b) the Landauer bound on the energy a
             computation must dissipate.  Reversible (bijective) steps sit exactly on
             the boundary `ΔH = 0`.
Failure analysis: A first `bits` statement scaled the cost by `T = log 2`, which
             double-counts the conversion factor (cost became `(log 2)·log n`, not
             `log n`); the team's Critic caught this via an automated counterexample
             at `card = 2`.  Fixed by taking `T = 1`: the cost is `log n` nats, equal
             to `log 2 · log₂ n`.  Point masses force `DecidableEq` and the
             `0·log 0 = 0` convention, both absorbed by routing through
             `Real.negMulLog`.
-/

open scoped BigOperators
open ShannonEntropy

namespace ThermodynamicProofSystem

variable {α β : Type*}

/-- A fully *determined* belief state: the point mass concentrated on `a`,
representing a proposition that has been resolved (proven) to value `a`. -/
noncomputable def pointMass [DecidableEq α] (a : α) : α → ℝ :=
  fun x => if x = a then 1 else 0

/-- The energy that must be dissipated to drive the belief state from `p` to `q`
at temperature `T`: `T · (H(p) − H(q))` (Landauer cost, `k = 1`, entropy in nats). -/
noncomputable def landauerCost [Fintype α] (T : ℝ) (p q : α → ℝ) : ℝ :=
  T * (entropy p - entropy q)

/-! ## Determined states -/

-- !-- A determined state is a probability distribution: its single non-zero weight
-- is `1`, all others `0`, and they sum to `1`. -- !--
/-- A determined (point-mass) state is a genuine probability distribution. -/
theorem pointMass_isProbDist [Fintype α] [DecidableEq α] (a : α) :
    IsProbDist (pointMass a) := by
  constructor
  · exact fun x => by unfold pointMass; split_ifs <;> norm_num
  · unfold pointMass; aesop

-- !-- `entropy (pointMass a) = ∑ negMulLog (if x = a then 1 else 0)`; every summand
-- is `negMulLog 1 = 0` or `negMulLog 0 = 0`, so the entropy is `0`. -- !--
/-- **A proven proposition carries no uncertainty**: a determined state has zero
entropy.  This is the endpoint of every proof. -/
theorem entropy_pointMass [Fintype α] [DecidableEq α] (a : α) :
    entropy (pointMass a) = 0 := by
  exact Finset.sum_eq_zero fun x _ => by unfold pointMass; aesop

/-! ## Bennett's principle: reversible computation is free -/

-- !-- Relabelling microstates by `σ` reindexes the entropy sum; `Equiv.sum_comp`
-- shows `∑_b negMulLog (p (σ.symm b)) = ∑_a negMulLog (p a)`. -- !--
/-- **Bennett's principle (entropy form).** A logically reversible step — relabelling
the microstates by any bijection `σ` — leaves the entropy unchanged. -/
theorem reversible_entropy_invariant [Fintype α] [Fintype β] (σ : α ≃ β) (p : α → ℝ) :
    entropy (fun b => p (σ.symm b)) = entropy p := by
  exact Equiv.sum_comp σ.symm fun x => -p x * Real.log (p x)

-- !-- The two states have equal entropy by `reversible_entropy_invariant`, so the
-- cost `T · (H − H) = 0`. -- !--
/-- **Bennett's principle (energy form).** A reversible step (here a permutation of
the microstates) dissipates no energy, at any temperature. -/
theorem reversible_free [Fintype α] (T : ℝ) (σ : Equiv.Perm α) (p : α → ℝ) :
    landauerCost T p (fun x => p (σ.symm x)) = 0 := by
  unfold landauerCost
  rw [reversible_entropy_invariant]; norm_num

/-! ## The second law: proofs cost energy -/

-- !-- `H(p) ≥ H(q)` (the proof reduces uncertainty) and `0 ≤ T` give
-- `T · (H(p) − H(q)) ≥ 0`. -- !--
/-- **Second-law flavour.** If a proof genuinely reduces uncertainty
(`H(q) ≤ H(p)`) then at non-negative temperature it never returns energy. -/
theorem landauerCost_nonneg [Fintype α] {T : ℝ} (hT : 0 ≤ T) {p q : α → ℝ}
    (h : entropy q ≤ entropy p) : 0 ≤ landauerCost T p q := by
  exact mul_nonneg hT (sub_nonneg_of_le h)

/-! ## The fundamental Landauer bound -/

-- !-- The cost to reach a determined state is `T · (H(p) − 0) = T · H(p)`, and
-- `H(p) ≤ log n` by the max-entropy theorem `entropy_le_log_card`. -- !--
/-- **The fundamental Landauer bound for proofs.** Over an `n`-state epistemic world,
the energy cost of resolving *any* prior `p` to a determined (proven) conclusion is
at most `T · log n`: the state space has a finite information capacity. -/
theorem tps_landauer_bound [Fintype α] [Nonempty α] [DecidableEq α]
    {T : ℝ} (hT : 0 ≤ T) {p : α → ℝ} (hp : IsProbDist p) (a : α) :
    landauerCost T p (pointMass a) ≤ T * Real.log (Fintype.card α) := by
  unfold landauerCost
  gcongr
  rw [entropy_pointMass]; linarith [entropy_le_log_card hp]

-- !-- Starting from the uniform prior `H = log n` (`entropy_uniform`) and ending at
-- a determined state `H = 0`, the cost is exactly `T · (log n − 0) = T · log n`. -- !--
/-- **Tightness of the Landauer bound.** Beginning from maximal ignorance (the
uniform prior) and ending at a proven conclusion, the cost is *exactly* `T · log n`.
Combined with `tps_landauer_bound`, the capacity `T · log n` is sharp. -/
theorem tps_landauer_tight [Fintype α] [Nonempty α] [DecidableEq α]
    (T : ℝ) (a : α) :
    landauerCost T (fun _ => (1 / Fintype.card α : ℝ)) (pointMass a)
      = T * Real.log (Fintype.card α) := by
  unfold landauerCost
  rw [entropy_uniform, entropy_pointMass]; ring

-- !-- At unit temperature the tight cost is `H = log n` nats (`tps_landauer_tight`),
-- and `log n = (log 2) · log₂ n` (`Real.log` vs `Real.logb`), exhibiting the
-- `log₂ n`-*bit* content explicitly. -- !--
/-- **Landauer bound in bits.** At unit temperature the cost of resolving the uniform
prior over `n` worlds is `log n` nats, which equals `log 2 · log₂ n`: exactly `log₂ n`
*bits*, the information-theoretic content of the conclusion. (Working in physical units
where a bit costs `kT ln 2`, this is the canonical Landauer count.) -/
theorem tps_landauer_bits [Fintype α] [Nonempty α] [DecidableEq α] (a : α) :
    landauerCost 1 (fun _ => (1 / Fintype.card α : ℝ)) (pointMass a)
      = Real.log 2 * Real.logb 2 (Fintype.card α) := by
  convert tps_landauer_tight 1 a using 1; norm_num [Real.logb, mul_div]

end ThermodynamicProofSystem