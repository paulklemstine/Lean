/-! # CatalogBuild.EML.AIResearch.FederatedPrivacy

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 17
-/

import Mathlib

noncomputable section

def emlFedCommBits (depth width precision : ℕ) : ℕ := 4 * depth * width * precision

def mlpFedCommBits (depth width precision : ℕ) : ℕ := depth * width * width * precision


theorem eml_comm_savings (d w p : ℕ) (hw : 5 ≤ w) :
    emlFedCommBits d w p ≤ mlpFedCommBits d w p := by
  unfold emlFedCommBits mlpFedCommBits; nlinarith [ mul_le_mul_left' hw d, mul_le_mul_left' hw p ] ;


def totalFedComm (commPerRound rounds : ℕ) : ℕ := commPerRound * rounds


theorem eml_total_comm_savings (d w p R : ℕ) (hw : 5 ≤ w) :
    totalFedComm (emlFedCommBits d w p) R ≤ totalFedComm (mlpFedCommBits d w p) R := by
  unfold totalFedComm; exact Nat.mul_le_mul_right R (eml_comm_savings d w p hw)


def gaussianNoiseScale (sensitivity epsilon : ℝ) : ℝ := sensitivity / epsilon


theorem eml_lower_sensitivity (g : ℝ) (p1 p2 : ℕ) (hg : 0 ≤ g) (hp : p1 ≤ p2) :
    emlSensitivity g p1 ≤ emlSensitivity g p2 := by
  unfold emlSensitivity
  exact mul_le_mul_of_nonneg_left (Real.sqrt_le_sqrt (by exact_mod_cast hp)) hg


def composedEpsilon (baseEps : ℝ) (rounds : ℕ) : ℝ :=
  baseEps * Real.sqrt ↑rounds


theorem more_rounds_less_privacy (eps : ℝ) (r1 r2 : ℕ)
    (heps : 0 ≤ eps) (hr : r1 ≤ r2) :
    composedEpsilon eps r1 ≤ composedEpsilon eps r2 := by
  unfold composedEpsilon
  exact mul_le_mul_of_nonneg_left (Real.sqrt_le_sqrt (by exact_mod_cast hr)) heps


def secAggCost (numParams numClients : ℕ) : ℕ := numParams * numClients


theorem eml_sec_agg_cheaper (d w c : ℕ) (hw : 5 ≤ w) :
    secAggCost (4 * d * w) c ≤ secAggCost (d * w * w) c := by
  unfold secAggCost; apply Nat.mul_le_mul_right
  nlinarith [mul_le_mul_of_nonneg_left hw (Nat.zero_le d)]


def clientDivergence (localSteps learningRate gradVariance : ℝ) : ℝ :=
  localSteps * learningRate ^ 2 * gradVariance


theorem more_local_steps_more_divergence (s1 s2 lr gv : ℝ)
    (hlr : 0 ≤ lr) (hgv : 0 ≤ gv) (hs : s1 ≤ s2) :
    clientDivergence s1 lr gv ≤ clientDivergence s2 lr gv := by
  unfold clientDivergence
  have h1 : 0 ≤ lr ^ 2 * gv := mul_nonneg (sq_nonneg lr) hgv
  nlinarith


def dpUtilityLoss (noiseScale : ℝ) (numParams : ℕ) : ℝ :=
  noiseScale ^ 2 * ↑numParams


theorem eml_dp_less_utility_loss (sigma : ℝ) (d w : ℕ) (hw : 5 ≤ w) :
    dpUtilityLoss sigma (4 * d * w) ≤ dpUtilityLoss sigma (d * w * w) := by
  unfold dpUtilityLoss
  apply mul_le_mul_of_nonneg_left _ (sq_nonneg sigma)
  have : 4 * d * w ≤ d * w * w := by nlinarith [mul_le_mul_of_nonneg_left hw (Nat.zero_le d)]
  exact_mod_cast this


def membershipAdvantage (trainLoss testLoss : ℝ) : ℝ := trainLoss - testLoss


theorem smaller_gap_more_resistant (trL1 trL2 teL : ℝ) (h : trL1 ≤ trL2) :
    membershipAdvantage trL1 teL ≤ membershipAdvantage trL2 teL := by
  unfold membershipAdvantage; linarith


end
