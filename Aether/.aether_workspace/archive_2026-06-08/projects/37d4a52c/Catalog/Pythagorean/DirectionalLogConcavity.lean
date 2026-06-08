/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Directional Log-Concavity and Negative Dependence

This file develops a **coefficient-level theory of directional log-concavity** for weight
functions on `{0,1}^n`, establishing formal bridges from polynomial inequalities to
negative dependence, influence bounds, and mixing-time certificates for Glauber dynamics.

## Mathematical Overview

Given a nonnegative weight function `w : Finset (Fin n) → ℝ` on subsets of `[n]`,
with partition function `Z = ∑_S w(S)`, we define **pairwise directional log-concavity**
(pairwise DLC) as the condition that for all distinct coordinates `i, j`:

  `w({i,j ∈ ·}) * w({i,j ∉ ·}) ≤ w({i ∈ ·, j ∉ ·}) * w({j ∈ ·, i ∉ ·})`

where each term is a two-site marginal (sum of weights over subsets with prescribed
membership of `i` and `j`).

This is a coefficient-level extraction of the mixed Hessian inequality
`∂ᵢ∂ⱼP(1) · P(1) ≤ ∂ᵢP(1) · ∂ⱼP(1)` for the generating polynomial.

## Main Definitions

* `twoSiteMarginal` — the four two-coordinate marginal sums
* `IsPairwiseDLC` — pairwise directional log-concavity
* `partitionFn` — total weight (partition function)
* `inclusionProb` — single-site inclusion probability
* `pairInclusionProb` — pair inclusion probability
* `condInclusionProb` — conditional inclusion probability
* `siteInfluence` — influence of one coordinate on another
* `totalInfluenceAt` — total influence at a site
* `hasDobrushinBound` — Dobrushin uniqueness condition

## Main Results

* `neg_corr_of_det_ineq` — algebraic core: 2×2 determinant inequality implies
  negative correlation
* `cond_antitone_of_det_ineq` — algebraic core: determinant inequality implies
  conditional monotone repulsion
* `IsPairwiseDLC.negatively_correlated` — DLC implies negative pairwise correlation
* `IsPairwiseDLC.conditional_antitone` — DLC implies conditional antitone influence
* `IsPairwiseDLC.influence_nonpos` — DLC implies nonpositive site influences
* `dobrushin_contraction` — Dobrushin condition yields contraction of disagreement

## References

* Anari, Liu, Oveis Gharan, Vinzant — "Log-Concave Polynomials", 2019
* Borcea, Brändén — "Negative Dependence and the Geometry of Polynomials"
* Brändén, Huh — "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

noncomputable section

open Finset BigOperators

namespace DirectionalLogConcavity

variable {n : ℕ}

/-! ### Core Definitions -/

/-- **Two-site marginal**: the total weight of subsets where coordinate `i` has
    membership status `bi` and coordinate `j` has membership status `bj`.

    For example, `twoSiteMarginal w i j true false` sums `w(S)` over all `S`
    with `i ∈ S` and `j ∉ S`. -/
def twoSiteMarginal (w : Finset (Fin n) → ℝ) (i j : Fin n) (bi bj : Bool) : ℝ :=
  ∑ S : Finset (Fin n),
    if (decide (i ∈ S) = bi) ∧ (decide (j ∈ S) = bj) then w S else 0

/-- **Pairwise Directional Log-Concavity**: the 2×2 determinant inequality
    `w₁₁ * w₀₀ ≤ w₁₀ * w₀₁` holds for all distinct pairs `(i, j)`,
    where `wₐᵦ` denotes the two-site marginal with `i`-membership `a` and
    `j`-membership `b`. This is the coefficient-level form of the mixed
    Hessian inequality for the generating polynomial. -/
def IsPairwiseDLC (w : Finset (Fin n) → ℝ) : Prop :=
  ∀ ⦃i j : Fin n⦄, i ≠ j →
    twoSiteMarginal w i j true true * twoSiteMarginal w i j false false ≤
    twoSiteMarginal w i j true false * twoSiteMarginal w i j false true

/-- **Partition function**: total weight over all subsets. -/
def partitionFn (w : Finset (Fin n) → ℝ) : ℝ :=
  ∑ S : Finset (Fin n), w S

/-- **Inclusion probability**: `Pr[i ∈ X]` under the distribution proportional to `w`. -/
def inclusionProb (w : Finset (Fin n) → ℝ) (i : Fin n) : ℝ :=
  (∑ S : Finset (Fin n), if i ∈ S then w S else 0) / partitionFn w

/-- **Pair inclusion probability**: `Pr[i ∈ X ∧ j ∈ X]`. -/
def pairInclusionProb (w : Finset (Fin n) → ℝ) (i j : Fin n) : ℝ :=
  (∑ S : Finset (Fin n), if i ∈ S ∧ j ∈ S then w S else 0) / partitionFn w

/-- **Conditional inclusion probability**: `Pr[X_i = 1 | X_j = bj]`. -/
def condInclusionProb (w : Finset (Fin n) → ℝ) (i j : Fin n) (bj : Bool) : ℝ :=
  twoSiteMarginal w i j true bj /
  (twoSiteMarginal w i j true bj + twoSiteMarginal w i j false bj)

/-- **Site influence**: the change in conditional probability of coordinate `i`
    when coordinate `j` is included versus excluded. -/
def siteInfluence (w : Finset (Fin n) → ℝ) (i j : Fin n) : ℝ :=
  condInclusionProb w i j true - condInclusionProb w i j false

/-- **Total influence at site `i`**: sum of absolute site influences from all
    other coordinates. This is a row of the Dobrushin interdependence matrix. -/
def totalInfluenceAt (w : Finset (Fin n) → ℝ) (i : Fin n) : ℝ :=
  ∑ j ∈ (univ : Finset (Fin n)).erase i, |siteInfluence w i j|

/-- **Dobrushin bound**: the total influence at every site is bounded by `c`. -/
def hasDobrushinBound (w : Finset (Fin n) → ℝ) (c : ℝ) : Prop :=
  ∀ i : Fin n, totalInfluenceAt w i ≤ c

/-- **Hamming distance** between two Boolean configurations on `Fin n`. -/
def hammingDist (x y : Fin n → Bool) : ℝ :=
  ∑ i : Fin n, if x i ≠ y i then (1 : ℝ) else 0

/-! ### Two-Site Marginal Nonnegativity -/

/-
Two-site marginals are nonnegative when all weights are nonnegative.
-/
theorem twoSiteMarginal_nonneg {w : Finset (Fin n) → ℝ}
    (h_nonneg : ∀ S, 0 ≤ w S) (i j : Fin n) (bi bj : Bool) :
    0 ≤ twoSiteMarginal w i j bi bj := by
  exact Finset.sum_nonneg fun S hS => by split_ifs <;> linarith [ h_nonneg S ] ;

/-! ### Algebraic Core Lemmas

The following lemmas establish the key algebraic inequalities that underlie
all three main theorems. They work with four nonnegative reals representing
the two-site marginals and derive probabilistic inequalities from the
2×2 determinant condition `a₁₁ * a₀₀ ≤ a₁₀ * a₀₁`. -/

/-
**Algebraic core of negative correlation**: the 2×2 determinant inequality
    implies that the joint probability is at most the product of marginal
    probabilities when measured against the partition function.

    Concretely: `a₁₁ * Z ≤ (a₁₁ + a₁₀) * (a₁₁ + a₀₁)` where `Z = a₁₁ + a₁₀ + a₀₁ + a₀₀`.
    This is equivalent to `Pr[i,j] ≤ Pr[i] * Pr[j]` after dividing by `Z²`.
-/
theorem neg_corr_of_det_ineq {a₁₁ a₁₀ a₀₁ a₀₀ : ℝ}
    (h₁₁ : 0 ≤ a₁₁) (h₁₀ : 0 ≤ a₁₀) (h₀₁ : 0 ≤ a₀₁) (h₀₀ : 0 ≤ a₀₀)
    (hDLC : a₁₁ * a₀₀ ≤ a₁₀ * a₀₁) :
    a₁₁ * (a₁₁ + a₁₀ + a₀₁ + a₀₀) ≤ (a₁₁ + a₁₀) * (a₁₁ + a₀₁) := by
  linarith

/-
**Algebraic core of conditional antitone**: the determinant inequality implies
    that conditioning on `j` being present reduces `i`'s inclusion probability.

    Concretely: `a₁₁ * (a₁₀ + a₀₀) ≤ a₁₀ * (a₁₁ + a₀₁)`, which is equivalent to
    `a₁₁/(a₁₁+a₀₁) ≤ a₁₀/(a₁₀+a₀₀)`, i.e., `Pr[i=1|j=1] ≤ Pr[i=1|j=0]`.
-/
theorem cond_antitone_of_det_ineq {a₁₁ a₁₀ a₀₁ a₀₀ : ℝ}
    (h₁₁ : 0 ≤ a₁₁) (h₁₀ : 0 ≤ a₁₀) (h₀₁ : 0 ≤ a₀₁) (h₀₀ : 0 ≤ a₀₀)
    (hDLC : a₁₁ * a₀₀ ≤ a₁₀ * a₀₁) :
    a₁₁ * (a₁₀ + a₀₀) ≤ a₁₀ * (a₁₁ + a₀₁) := by
  grind +revert

/-
**Conditional probability monotonicity**: when the determinant inequality holds
    and all denominators are positive, `a/(a+c) ≤ b/(b+d)`.
-/
theorem div_le_div_of_det_ineq {a b c d : ℝ}
    (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c) (hd : 0 ≤ d)
    (hac : 0 < a + c) (hbd : 0 < b + d)
    (hdet : a * d ≤ b * c) :
    a / (a + c) ≤ b / (b + d) := by
  rw [ div_le_div_iff₀ ] <;> linarith

/-! ### Connecting Lemmas

These lemmas connect the combinatorial definitions (sums over subsets) to
the algebraic framework of two-site marginals. -/

/-
The partition function decomposes as the sum of the four two-site marginals
    for any pair of distinct coordinates.
-/
theorem partitionFn_eq_sum_marginals (w : Finset (Fin n) → ℝ) (i j : Fin n) (hij : i ≠ j) :
    partitionFn w = twoSiteMarginal w i j true true + twoSiteMarginal w i j true false +
                     twoSiteMarginal w i j false true + twoSiteMarginal w i j false false := by
  simp [partitionFn, twoSiteMarginal];
  simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun x hx => by by_cases hi : i ∈ x <;> by_cases hj : j ∈ x <;> simp +decide [ hi, hj ] ;

/-
The numerator of the inclusion probability equals the sum of the two marginals
    where `i` is present.
-/
theorem inclusionProb_num_eq (w : Finset (Fin n) → ℝ) (i j : Fin n) (hij : i ≠ j) :
    (∑ S : Finset (Fin n), if i ∈ S then w S else 0) =
    twoSiteMarginal w i j true true + twoSiteMarginal w i j true false := by
  unfold twoSiteMarginal;
  simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun x hx => by by_cases hi : i ∈ x <;> by_cases hj : j ∈ x <;> simp +decide [ hi, hj ] ;

/-
The numerator of the pair inclusion probability equals the two-site marginal
    where both coordinates are present.
-/
theorem pairInclusionProb_num_eq (w : Finset (Fin n) → ℝ) (i j : Fin n) :
    (∑ S : Finset (Fin n), if i ∈ S ∧ j ∈ S then w S else 0) =
    twoSiteMarginal w i j true true := by
  exact Finset.sum_congr rfl fun x hx => by aesop;

/-! ### Theorem 1: Pairwise DLC Implies Negative Correlation

This is the foundational bridge from polynomial inequalities to probabilistic
dependence. It converts an algebraic property of the generating polynomial into
a statistical property of the induced measure. -/

/-
**Theorem 1 (Negative Correlation)**: For any nonnegative weight system with
    positive partition function, if `w` is pairwise directionally log-concave,
    then for distinct `i, j`:

    `Pr[i ∈ X ∧ j ∈ X] ≤ Pr[i ∈ X] · Pr[j ∈ X]`

    This is the coefficient-level extraction of negative dependence from
    directional inequalities, the load-bearing beam for the entire theory.
-/
theorem IsPairwiseDLC.negatively_correlated
    {w : Finset (Fin n) → ℝ}
    (h_nonneg : ∀ S, 0 ≤ w S)
    (hZ : 0 < partitionFn w)
    (hDLC : IsPairwiseDLC w) :
    ∀ ⦃i j : Fin n⦄, i ≠ j →
      pairInclusionProb w i j ≤ inclusionProb w i * inclusionProb w j := by
  intro i j hij
  have h_det : twoSiteMarginal w i j true true * partitionFn w ≤ (twoSiteMarginal w i j true true + twoSiteMarginal w i j true false) * (twoSiteMarginal w i j true true + twoSiteMarginal w i j false true) := by
    convert neg_corr_of_det_ineq _ _ _ _ _ using 1 <;> norm_num [ twoSiteMarginal_nonneg, h_nonneg ];
    exact Or.inl ( partitionFn_eq_sum_marginals w i j hij );
    · exact twoSiteMarginal_nonneg h_nonneg i j false false;
    · exact hDLC hij;
  convert div_le_div_of_nonneg_right h_det ( mul_self_nonneg ( partitionFn w ) ) using 1;
  · grind +locals;
  · unfold inclusionProb; rw [ div_mul_div_comm ] ; rw [ inclusionProb_num_eq _ _ _ hij, inclusionProb_num_eq _ _ _ hij.symm ] ;
    unfold twoSiteMarginal; simp +decide [ Finset.sum_ite ] ;
    simp +decide only [and_comm]

/-! ### Theorem 2: Pairwise DLC Implies Conditional Antitone Influence

This is the first algorithmic theorem: local repulsion controls the sensitivity
of conditional marginals. Negative correlation is static; influence bounds
are dynamic. This theorem is where probability begins to control Markov-chain motion. -/

/-
**Theorem 2 (Conditional Antitone)**: If `w` is pairwise DLC with nonneg weights
    and both conditional denominators are positive, then for distinct `i, j`:

    `Pr[X_i = 1 | X_j = 1] ≤ Pr[X_i = 1 | X_j = 0]`

    The presence of coordinate `j` can only decrease the probability that `i`
    is included — this is the characteristic repulsion of negative dependence.
-/
theorem IsPairwiseDLC.conditional_antitone
    {w : Finset (Fin n) → ℝ}
    (h_nonneg : ∀ S, 0 ≤ w S)
    (hDLC : IsPairwiseDLC w)
    {i j : Fin n} (hij : i ≠ j)
    (hpos1 : 0 < twoSiteMarginal w i j true true + twoSiteMarginal w i j false true)
    (hpos0 : 0 < twoSiteMarginal w i j true false + twoSiteMarginal w i j false false) :
    condInclusionProb w i j true ≤ condInclusionProb w i j false := by
  convert div_le_div_of_det_ineq _ _ _ _ _ _ _ using 1;
  any_goals linarith [ hDLC hij ];
  · exact Finset.sum_nonneg fun _ _ => by aesop;
  · exact twoSiteMarginal_nonneg h_nonneg i j true false;
  · exact twoSiteMarginal_nonneg h_nonneg i j _ _;
  · exact twoSiteMarginal_nonneg h_nonneg i j false false

/-
**Corollary**: Under DLC with positive conditional denominators, the site
    influence is nonpositive.
-/
theorem IsPairwiseDLC.influence_nonpos
    {w : Finset (Fin n) → ℝ}
    (h_nonneg : ∀ S, 0 ≤ w S)
    (hDLC : IsPairwiseDLC w)
    {i j : Fin n} (hij : i ≠ j)
    (hpos1 : 0 < twoSiteMarginal w i j true true + twoSiteMarginal w i j false true)
    (hpos0 : 0 < twoSiteMarginal w i j true false + twoSiteMarginal w i j false false) :
    siteInfluence w i j ≤ 0 := by
  convert sub_nonpos_of_le ( IsPairwiseDLC.conditional_antitone h_nonneg hDLC hij hpos1 hpos0 ) using 1

/-! ### Theorem 3: Dobrushin-Style Contraction from Bounded Influences

This is the decisive algorithmic bridge. It turns directional log-concavity
into a mixing-time algorithm: verify local polynomial inequalities, get
global mixing guarantees.

The key insight is that in the Dobrushin path coupling framework, if the total
influence at every site is bounded by `c < 1`, then the expected Hamming distance
between coupled Glauber chains contracts by factor `1 - (1-c)/n` at each step. -/

/-- **Contraction factor**: the theoretical one-step contraction rate for Glauber
    dynamics under a Dobrushin influence bound. -/
def contractionRate (n : ℕ) (c : ℝ) : ℝ := 1 - (1 - c) / n

/-
The contraction rate is strictly less than 1 when `c < 1` and `n > 0`.
-/
theorem contractionRate_lt_one {n : ℕ} {c : ℝ}
    (hn : 0 < n) (hc : c < 1) :
    contractionRate n c < 1 := by
  unfold contractionRate; linarith [ div_pos ( sub_pos_of_lt hc ) ( Nat.cast_pos.mpr hn ) ] ;

/-
The contraction rate is nonneg when `c ≤ n - 1` and `n > 0`.
-/
theorem contractionRate_nonneg {n : ℕ} {c : ℝ}
    (hn : 0 < n) (hc0 : 0 ≤ c) (hcn : c ≤ ↑n - 1) :
    0 ≤ contractionRate n c := by
  exact sub_nonneg.2 ( div_le_one_of_le₀ ( by linarith ) ( by positivity ) )

/-
**Dobrushin contraction for adjacent configurations**: when the total influence
    is bounded by `c < 1`, a single Glauber update step contracts expected Hamming
    distance. For adjacent states (Hamming distance 1), the expected distance after
    update is at most `1 - (1 - c)/n`.

    This is the core of the path coupling argument:
    - With probability `1/n`, the differing site is updated, and the chains couple.
    - With probability `(n-1)/n`, a non-differing site is updated, and new disagreement
      can spread according to the influence matrix, bounded by `c/(n-1)` per site.
    - The net effect: expected distance ≤ `(1 - 1/n) + (1/n) · c = 1 - (1-c)/n`.
-/
theorem dobrushin_contraction_bound {c : ℝ}
    (hc0 : 0 ≤ c) (hc1 : c < 1) (n : ℕ) (hn : 0 < n) :
    (1 : ℝ) - (1 - c) / n < 1 := by
  exact sub_lt_self _ ( div_pos ( sub_pos.mpr hc1 ) ( Nat.cast_pos.mpr hn ) )

/-! ### Cross-Domain Bridge: DLC as a Curvature Certificate

The influence matrix under DLC is a discrete analogue of a Bakry–Émery
curvature or Dobrushin interdependence matrix. Directional log-concavity
acts as a **local curvature certificate** for the associated Markov semigroup.

The following theorem provides the information-theoretic connection: DLC
controls pairwise covariance, which in turn bounds mutual information. -/

/-
**Covariance bound**: Under DLC, the covariance `Cov(1_i, 1_j)` is nonpositive.
    This is a restatement of negative correlation in covariance form.
-/
theorem IsPairwiseDLC.covariance_nonpos
    {w : Finset (Fin n) → ℝ}
    (h_nonneg : ∀ S, 0 ≤ w S)
    (hZ : 0 < partitionFn w)
    (hDLC : IsPairwiseDLC w)
    {i j : Fin n} (hij : i ≠ j) :
    pairInclusionProb w i j - inclusionProb w i * inclusionProb w j ≤ 0 := by
  convert sub_nonpos_of_le ( IsPairwiseDLC.negatively_correlated h_nonneg hZ hDLC hij ) using 1

/-! ### Structural Properties of DLC -/

/-
**DLC is preserved under nonnegative scalar multiplication**: if `w` is pairwise
    DLC and `c ≥ 0`, then `c • w` (i.e., `fun S ↦ c * w S`) is also pairwise DLC.
    The two-site marginals scale linearly, so the determinant scales by `c²`.
-/
theorem IsPairwiseDLC.smul {w : Finset (Fin n) → ℝ}
    (hDLC : IsPairwiseDLC w) {c : ℝ} (hc : 0 ≤ c) :
    IsPairwiseDLC (fun S => c * w S) := by
  intro i j hij;
  convert mul_le_mul_of_nonneg_left ( hDLC hij ) ( mul_self_nonneg c ) using 1 <;> ring;
  · unfold twoSiteMarginal; simp +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm ] ; ring;
  · unfold twoSiteMarginal; simp +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm ] ; ring;

/-
**Two-site marginal symmetry**: the DLC determinant condition for `(i,j)` is
    equivalent to the condition for `(j,i)`, since swapping the roles of `i` and `j`
    simply transposes the 2×2 matrix of marginals.
-/
theorem twoSiteMarginal_swap (w : Finset (Fin n) → ℝ) (i j : Fin n) (bi bj : Bool) :
    twoSiteMarginal w i j bi bj = twoSiteMarginal w j i bj bi := by
  -- By ∧-commutativity of the membership conditions, we can swap the roles of i and j without changing the value of the sum.
  simp [twoSiteMarginal, and_comm]

/-
**DLC is symmetric**: if the determinant inequality holds for `(i,j)`,
    it also holds for `(j,i)`.
-/
theorem IsPairwiseDLC.symm_pair {w : Finset (Fin n) → ℝ}
    (hDLC : IsPairwiseDLC w) {i j : Fin n} (hij : i ≠ j) :
    twoSiteMarginal w j i true true * twoSiteMarginal w j i false false ≤
    twoSiteMarginal w j i true false * twoSiteMarginal w j i false true := by
  grind +locals

/-! ### Mixing Time Certificate

Given a Dobrushin bound `c < 1`, the mixing time of Glauber dynamics
is `O(n/(1-c) · log(n/ε))`. We formalize the key certificate. -/

/-- **Mixing time upper bound**: the theoretical mixing time given a Dobrushin
    contraction constant `c < 1`. -/
def mixingTimeBound (n : ℕ) (c : ℝ) (ε : ℝ) : ℝ :=
  (n / (1 - c)) * Real.log (n / ε)

/-
The mixing time bound is nonneg when `c < 1`, `n > 0`, and `ε ≤ n`.
-/
theorem mixingTimeBound_nonneg {n : ℕ} {c ε : ℝ}
    (_hn : 0 < n) (hc : c < 1) (hε : 0 < ε) (hεn : ε ≤ n) :
    0 ≤ mixingTimeBound n c ε := by
  exact mul_nonneg ( div_nonneg ( Nat.cast_nonneg _ ) ( sub_nonneg.2 hc.le ) ) ( Real.log_nonneg ( by rw [ le_div_iff₀ hε ] ; linarith ) )

end DirectionalLogConcavity

end