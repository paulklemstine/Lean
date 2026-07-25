import Mathlib
import Computation.NeuralCoding.LandauerLowerBound

/-!
# Cross-Reality Entropy for Finite Branch Ensembles

A multibranch ensemble is represented by a finite branch type. Each branch carries a
fixed statistical weight, a probability distribution on microscopic states, and an
environmental entropy. The ensemble entropy is the Shannon entropy of the branch
weights plus the weighted sum of conditional microscopic and environmental entropies.

The central result is a strict finite-ensemble second law. If every branch exports at
least as much entropy to its environment as its microscopic entropy loses, and one
positive-weight branch exports strictly more, then total ensemble entropy strictly
increases. This remains true when a specified branch undergoes a local microscopic
entropy decrease. A deterministic-update specialization connects the statement to the
data-processing inequality and Landauer compensation.
-/

noncomputable section

open Finset BigOperators
open LandauerLowerBound

namespace CrossRealityEntropy

variable {ι α β : Type*} [Fintype ι] [Fintype α] [Fintype β]

/-- Entropy of a branch-weight distribution. -/
def branchEntropy (w : ι → ℝ) : ℝ := shannonEntropy w

/-- Total entropy of a finite branch ensemble with fixed branch weights. -/
def totalEntropy (w : ι → ℝ) (p : ι → α → ℝ) (environment : ι → ℝ) : ℝ :=
  branchEntropy w + ∑ i, w i * (shannonEntropy (p i) + environment i)

/-- The entropy exported by one branch between two times. -/
def exportedEntropy (environment₀ environment₁ : ι → ℝ) (i : ι) : ℝ :=
  environment₁ i - environment₀ i

/-- The microscopic entropy lost by one branch between two times. -/
def microscopicLoss (p₀ p₁ : ι → α → ℝ) (i : ι) : ℝ :=
  shannonEntropy (p₀ i) - shannonEntropy (p₁ i)

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): Seven falsifiable claims were ranked by impact. (1) A
-- branchwise compensation law implies a global weak second law. (2) One strict
-- compensation event on a positive-weight branch implies strict global growth.
-- (3) Strict global growth remains compatible with a local microscopic decrease.
-- (4) Deterministic coarse-graining supplies a canonical nonnegative microscopic loss
-- by data processing. (5) Time-dependent branch weights obey an analogous law with an
-- additional mixing-entropy term. (6) Countably infinite ensembles inherit the result
-- under summability and uniform-integrability hypotheses. (7) Quantum branches obey a
-- corresponding statement with von Neumann entropy and completely positive maps.
-- Claims (2), (5), (6), and (7) have the greatest prospective reach.
-- Experiment (Experimenter): Finite weighted sums isolate the exact obstruction. A
-- negative local microscopic change is harmless precisely when environmental export
-- compensates it. Zero-weight branches cannot witness strict global growth. For a
-- deterministic update, the data-processing inequality makes microscopic loss
-- nonnegative, while a strict environmental excess creates the required witness.
-- Analysis (Analyst): Claims (1)--(4) survive in the finite classical model. Claim (5)
-- needs a transport rule relating old and new branch labels; without it, changing
-- weights can arbitrarily alter mixing entropy. Claims (6) and (7) are plausible but
-- require analytic convergence and operator-algebraic machinery absent from the finite
-- model. The unifying pattern is a local-to-global principle for weighted entropy
-- production, with strictness detected only on positive statistical support.
-- Critique (Critic): Strict growth is not unconditional. It requires a strict local
-- surplus and positive branch weight; branchwise exact compensation yields equality.
-- The branch distribution is fixed, all types are finite, and environmental entropy is
-- an explicit state variable rather than an inferred heat bath. Local decrease means
-- microscopic Shannon entropy decrease, not decrease of the branch's combined entropy.
-- Synthesis (Principal Investigator): The finite theory separates three layers:
-- deterministic dynamics creates a microscopic entropy deficit, Landauer compensation
-- transfers that deficit to an environment, and weighted aggregation turns one strict
-- positive-support surplus into a strict multibranch second law.
-- !-- end Lab Notes -- !--

/-- The change in total entropy is the weighted sum of branchwise net productions. -/
theorem totalEntropy_change_identity
    (w : ι → ℝ) (p₀ p₁ : ι → α → ℝ) (environment₀ environment₁ : ι → ℝ) :
    totalEntropy w p₁ environment₁ - totalEntropy w p₀ environment₀ =
      ∑ i, w i * (exportedEntropy environment₀ environment₁ i -
        microscopicLoss p₀ p₁ i) := by
  simp only [totalEntropy, exportedEntropy, microscopicLoss]
  simp_rw [mul_add, mul_sub, Finset.sum_add_distrib, Finset.sum_sub_distrib]
  ring

/-- Branchwise Landauer compensation implies the weak second law for the ensemble. -/
theorem totalEntropy_monotone
    (w : ι → ℝ) (p₀ p₁ : ι → α → ℝ) (environment₀ environment₁ : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hcomp : ∀ i, microscopicLoss p₀ p₁ i ≤ exportedEntropy environment₀ environment₁ i) :
    totalEntropy w p₀ environment₀ ≤ totalEntropy w p₁ environment₁ := by
  rw [← sub_nonneg]
  rw [totalEntropy_change_identity]
  apply Finset.sum_nonneg
  intro i _
  exact mul_nonneg (hw i) (sub_nonneg.mpr (hcomp i))

/-- A strict compensation surplus on one positive-weight branch forces strict growth
of total entropy across the whole ensemble. -/
theorem totalEntropy_strictly_increases
    [Nonempty ι]
    (w : ι → ℝ) (p₀ p₁ : ι → α → ℝ) (environment₀ environment₁ : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hcomp : ∀ i, microscopicLoss p₀ p₁ i ≤ exportedEntropy environment₀ environment₁ i)
    (witness : ι) (hwitness : 0 < w witness)
    (hstrict : microscopicLoss p₀ p₁ witness < exportedEntropy environment₀ environment₁ witness) :
    totalEntropy w p₀ environment₀ < totalEntropy w p₁ environment₁ := by
  rw [← sub_pos]
  rw [totalEntropy_change_identity]
  apply Finset.sum_pos'
  · intro i _
    exact mul_nonneg (hw i) (sub_nonneg.mpr (hcomp i))
  · refine ⟨witness, Finset.mem_univ witness, ?_⟩
    exact mul_pos hwitness (sub_pos.mpr hstrict)

/-- Strict total growth is compatible with a designated branch experiencing a local
microscopic entropy decrease. -/
theorem strict_total_growth_despite_local_decrease
    [Nonempty ι]
    (w : ι → ℝ) (p₀ p₁ : ι → α → ℝ) (environment₀ environment₁ : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hcomp : ∀ i, microscopicLoss p₀ p₁ i ≤ exportedEntropy environment₀ environment₁ i)
    (witness localBranch : ι) (hwitness : 0 < w witness)
    (hstrict : microscopicLoss p₀ p₁ witness < exportedEntropy environment₀ environment₁ witness)
    (hlocal : shannonEntropy (p₁ localBranch) < shannonEntropy (p₀ localBranch)) :
    totalEntropy w p₀ environment₀ < totalEntropy w p₁ environment₁ ∧
      shannonEntropy (p₁ localBranch) < shannonEntropy (p₀ localBranch) := by
  constructor
  · exact totalEntropy_strictly_increases w p₀ p₁ environment₀ environment₁ hw hcomp
      witness hwitness hstrict
  · exact hlocal

omit [Fintype ι] in
/-- Deterministic branch dynamics cannot increase microscopic Shannon entropy. -/
lemma deterministic_branch_microscopic_loss_nonnegative [DecidableEq β]
    (p : ι → α → ℝ) (f : ι → α → β)
    (hp : ∀ i, IsDistribution (p i)) (i : ι) :
    0 ≤ shannonEntropy (p i) - shannonEntropy (pushforwardFun (f i) (p i)) := by
  exact sub_nonneg.mpr (shannonEntropy_pushforward_le (f i) (p i) (hp i).1)

/-- **Deterministic multibranch second law.** For branchwise deterministic updates,
environmental export at least equal to the data-processing entropy loss on every branch,
with strict excess on one positive-weight branch, forces strict total entropy growth. -/
theorem deterministic_multibranch_second_law
    [Nonempty ι] [DecidableEq α]
    (w : ι → ℝ) (p : ι → α → ℝ) (f : ι → α → α)
    (environment₀ environment₁ : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hcomp : ∀ i,
      shannonEntropy (p i) - shannonEntropy (pushforwardFun (f i) (p i)) ≤
        exportedEntropy environment₀ environment₁ i)
    (witness : ι) (hwitness : 0 < w witness)
    (hstrict :
      shannonEntropy (p witness) - shannonEntropy (pushforwardFun (f witness) (p witness)) <
        exportedEntropy environment₀ environment₁ witness) :
    totalEntropy w p environment₀ <
      totalEntropy w (fun i => pushforwardFun (f i) (p i)) environment₁ := by
  apply totalEntropy_strictly_increases
    (w := w) (p₀ := p) (p₁ := fun i => pushforwardFun (f i) (p i))
    (environment₀ := environment₀) (environment₁ := environment₁)
    (hw := hw) (hcomp := hcomp) (witness := witness) hwitness hstrict

end CrossRealityEntropy