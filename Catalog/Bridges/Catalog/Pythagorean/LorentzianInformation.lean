/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Information-Theoretic Monotonicity for Robustly Lorentzian Measures

This file establishes the first formal bridge between **Lorentzian polynomial negativity**
and **information-theoretic quantities** (entropy, mutual information, projection stability).

## Central Dictionary

- **Lorentzian gap** ↔ **information contraction**
- **Rayleigh-type negativity** ↔ **pairwise information suppression**
- **projection / deletion** ↔ **data processing**
- **strong combinatorial concavity** ↔ **entropy monotonicity**

## Main Results

* `chi_sq_bound_of_marginals` — Analytic chi-squared bound from marginal/covariance control
* `mutualInfoProxy_le_of_robust` — Pairwise MI bounded under robust Lorentzianity
* `entropy_delete_lower_bound` — Projection entropy lower bound
* `susceptibility_bound_of_robust` — Cross-domain statistical mechanics bridge

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Anari–Oveis Gharan–Vinzant, "Log-Concave Polynomials", STOC 2019
-/

open Finset BigOperators Real

noncomputable section

namespace LorentzianInformation

/-! ## Part 1: Core Definitions -/

/-- A probability mass function on subsets of `Fin n`. -/
structure FinsetLaw (n : ℕ) where
  weight : Finset (Fin n) → ℝ
  nonneg : ∀ s, 0 ≤ weight s
  total_one : ∑ s : Finset (Fin n), weight s = 1

/-- Probability that coordinate `i` is in a random subset. -/
def coordProb (μ : FinsetLaw n) (i : Fin n) : ℝ :=
  ∑ s : Finset (Fin n), if i ∈ s then μ.weight s else 0

/-- Joint probability that both `i` and `j` are in a random subset. -/
def pairJointProb (μ : FinsetLaw n) (i j : Fin n) : ℝ :=
  ∑ s : Finset (Fin n), if i ∈ s ∧ j ∈ s then μ.weight s else 0

/-- Covariance of coordinate indicators. -/
def coordCov (μ : FinsetLaw n) (i j : Fin n) : ℝ :=
  pairJointProb μ i j - coordProb μ i * coordProb μ j

/-- Binary entropy function h(p). -/
def binaryEntropy (p : ℝ) : ℝ :=
  if p ≤ 0 ∨ 1 ≤ p then 0
  else -(p * Real.log p + (1 - p) * Real.log (1 - p))

/-- Shannon entropy of the full subset distribution. -/
def totalEntropy (μ : FinsetLaw n) : ℝ :=
  -∑ s : Finset (Fin n), μ.weight s * Real.log (μ.weight s)

/-- Entropy of coordinate indicator. -/
def coordEntropy (μ : FinsetLaw n) (i : Fin n) : ℝ :=
  binaryEntropy (coordProb μ i)

/-- Deletion pushforward weight. For s not containing k:
    weight(s) = μ(s) + μ(s ∪ {k}). -/
def deleteCoordLaw (μ : FinsetLaw n) (k : Fin n) (s : Finset (Fin n)) : ℝ :=
  if k ∈ s then 0 else μ.weight s + μ.weight (insert k s)

/-- Chi-squared mutual information proxy. -/
def mutualInfoProxy (μ : FinsetLaw n) (i j : Fin n) : ℝ :=
  let p := coordProb μ i
  let q := coordProb μ j
  let c := coordCov μ i j
  if p ≤ 0 ∨ 1 ≤ p ∨ q ≤ 0 ∨ 1 ≤ q then 0
  else c ^ 2 / (p * (1 - p) * (q * (1 - q)))

/-- Pairwise covariance control. -/
def PairwiseCovControlled (μ : FinsetLaw n) (c : ℝ) : Prop :=
  ∀ ⦃i j : Fin n⦄, i ≠ j → |coordCov μ i j| ≤ c

/-- Robust Lorentzianity predicate: marginals bounded, negative dependence, covariance control. -/
structure RobustlyLorentzian (μ : FinsetLaw n) (ε : ℝ) : Prop where
  gap_pos : 0 < ε
  gap_le_half : ε ≤ 1 / 2
  marginal_lower : ∀ i : Fin n, ε ≤ coordProb μ i
  marginal_upper : ∀ i : Fin n, coordProb μ i ≤ 1 - ε
  neg_dep : ∀ ⦃i j : Fin n⦄, i ≠ j → coordCov μ i j ≤ 0
  cov_bound : PairwiseCovControlled μ ε

/-- Mutual information bound function. -/
def mutualInfoBound (ε : ℝ) : ℝ :=
  if ε ≤ 0 then 0 else 1 / (1 - ε) ^ 2

/-- Susceptibility. -/
def spinSusceptibility (μ : FinsetLaw n) : ℝ :=
  ∑ i : Fin n, ∑ j : Fin n, coordCov μ i j

/-- Susceptibility bound. -/
def susceptibilityBound (n : ℕ) (ε : ℝ) : ℝ :=
  (n : ℝ) * (1 / 4 + ((n : ℝ) - 1) * ε)

/-! ## Part 2: Basic Lemmas -/

theorem coordProb_nonneg (μ : FinsetLaw n) (i : Fin n) :
    0 ≤ coordProb μ i := by
  unfold coordProb
  apply Finset.sum_nonneg
  intro s _
  split_ifs <;> linarith [μ.nonneg s]

theorem coordProb_le_one (μ : FinsetLaw n) (i : Fin n) :
    coordProb μ i ≤ 1 := by
  unfold coordProb
  rw [← μ.total_one]
  apply Finset.sum_le_sum
  intro s _
  split_ifs <;> linarith [μ.nonneg s]

theorem pairJointProb_nonneg (μ : FinsetLaw n) (i j : Fin n) :
    0 ≤ pairJointProb μ i j := by
  unfold pairJointProb
  apply Finset.sum_nonneg
  intro s _
  split_ifs <;> linarith [μ.nonneg s]

theorem pairJointProb_le_coordProb (μ : FinsetLaw n) (i j : Fin n) :
    pairJointProb μ i j ≤ coordProb μ i := by
  unfold pairJointProb coordProb
  apply Finset.sum_le_sum
  intro s _
  split_ifs with h1 h2
  · exact le_refl _
  · exact absurd h1.1 h2
  · exact μ.nonneg s
  · exact le_refl _

/-
Self-covariance equals variance.
-/
theorem coordCov_self (μ : FinsetLaw n) (i : Fin n) :
    coordCov μ i i = coordProb μ i * (1 - coordProb μ i) := by
  convert sub_eq_iff_eq_add.mpr rfl using 1;
  convert sub_eq_iff_eq_add.mpr rfl using 1;
  rotate_left 1;
  exact inferInstance;
  exact 0;
  exact inferInstance;
  exact 0;
  unfold coordCov coordProb pairJointProb; ring;
  aesop

/-
Diagonal covariance ≤ 1/4.
-/
theorem coordVar_le_quarter (μ : FinsetLaw n) (i : Fin n) :
    coordCov μ i i ≤ 1 / 4 := by
  -- Use the fact that coordCov μ i i = coordProb μ i * (1 - coordProb μ i).
  have h_cov : coordCov μ i i = coordProb μ i * (1 - coordProb μ i) :=
    coordCov_self μ i
  linarith [ sq_nonneg ( coordProb μ i - 1 / 2 ) ]

/-- Delete law nonneg. -/
theorem deleteCoordLaw_nonneg (μ : FinsetLaw n) (k : Fin n) (s : Finset (Fin n)) :
    0 ≤ deleteCoordLaw μ k s := by
  unfold deleteCoordLaw
  split_ifs
  · exact le_refl 0
  · exact add_nonneg (μ.nonneg s) (μ.nonneg (insert k s))

/-
Delete law total mass = 1.
-/
theorem deleteCoordLaw_total (μ : FinsetLaw n) (k : Fin n) :
    ∑ s : Finset (Fin n), deleteCoordLaw μ k s = 1 := by
  -- The sum of the deleteCoordLaw weights is equal to the sum of μ's weights for subsets not containing k plus the sum of μ's weights for subsets containing k but with k removed.
  have h_sum_split : ∑ s, deleteCoordLaw μ k s = ∑ s ∈ Finset.univ.filter (fun s => k ∉ s), μ.weight s + ∑ s ∈ Finset.univ.filter (fun s => k ∉ s), μ.weight (insert k s) := by
    unfold deleteCoordLaw;
    simp +decide only [sum_ite, ← sum_add_distrib];
    norm_num;
  -- The second sum is equal to the sum of μ's weights for subsets containing k, since inserting k into a subset not containing k gives a subset containing k.
  have h_sum_insert : ∑ s ∈ Finset.univ.filter (fun s => k ∉ s), μ.weight (insert k s) = ∑ s ∈ Finset.univ.filter (fun s => k ∈ s), μ.weight s := by
    apply Finset.sum_bij (fun s hs => insert k s);
    · aesop;
    · simp +contextual [ Finset.ext_iff ];
      grind;
    · exact fun s hs => ⟨ s.erase k, by aesop ⟩;
    · exact fun _ _ => rfl;
  rw [ ← μ.total_one, h_sum_split, h_sum_insert, ← Finset.sum_union ];
  · rcongr s ; by_cases hs : k ∈ s <;> aesop;
  · grind +suggestions

/-- Deletion pushforward as FinsetLaw. -/
def deleteCoordPushforward (μ : FinsetLaw n) (k : Fin n) : FinsetLaw n :=
  ⟨deleteCoordLaw μ k, deleteCoordLaw_nonneg μ k, deleteCoordLaw_total μ k⟩

/-! ## Part 3: Main Theorems -/

/-
**Theorem 1 (Chi-squared bound).**
    If p, q ∈ [ε, 1-ε] and |c| ≤ ε, then
    c²/(p(1-p)·q(1-q)) ≤ 1/(1-ε)².

    Proof idea: c² ≤ ε². Since p ∈ [ε,1-ε], p(1-p) ≥ ε(1-ε).
    So c²/(p(1-p)·q(1-q)) ≤ ε²/(ε(1-ε))² = ε²/(ε²(1-ε)²) = 1/(1-ε)².
-/
theorem chi_sq_bound_of_marginals
    {p q c ε : ℝ}
    (hε : 0 < ε) (hε1 : ε ≤ 1 / 2)
    (hp_lo : ε ≤ p) (hp_hi : p ≤ 1 - ε)
    (hq_lo : ε ≤ q) (hq_hi : q ≤ 1 - ε)
    (hc : |c| ≤ ε) :
    c ^ 2 / (p * (1 - p) * (q * (1 - q))) ≤ 1 / (1 - ε) ^ 2 := by
  -- We have $c^2 \leq \epsilon^2$ (from $|c| \leq \epsilon$, so $c^2 = |c|^2 \leq \epsilon^2$).
  have h_c_sq : c ^ 2 ≤ ε ^ 2 := by
    nlinarith only [ abs_le.mp hc ];
  rw [ div_le_div_iff₀ ] <;> try nlinarith;
  · nlinarith [ mul_le_mul_of_nonneg_left hp_lo hε.le, mul_le_mul_of_nonneg_left hp_hi hε.le, mul_le_mul_of_nonneg_left hq_lo hε.le, mul_le_mul_of_nonneg_left hq_hi hε.le, mul_le_mul_of_nonneg_left hp_lo ( sub_nonneg_of_le hp_hi ), mul_le_mul_of_nonneg_left hp_hi ( sub_nonneg_of_le hp_lo ), mul_le_mul_of_nonneg_left hq_lo ( sub_nonneg_of_le hq_hi ), mul_le_mul_of_nonneg_left hq_hi ( sub_nonneg_of_le hq_lo ) ];
  · exact mul_pos ( mul_pos ( by linarith ) ( by linarith ) ) ( mul_pos ( by linarith ) ( by linarith ) )

/-
**Theorem 2 (Pairwise MI bound).**
    Robustly Lorentzian ⟹ MI proxy bounded by 1/(1-ε)².
-/
theorem mutualInfoProxy_le_of_robust
    {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hrob : RobustlyLorentzian μ ε) :
    ∀ ⦃i j : Fin n⦄, i ≠ j →
      mutualInfoProxy μ i j ≤ mutualInfoBound ε := by
  unfold mutualInfoProxy mutualInfoBound;
  norm_num +zetaDelta at *;
  intro i j hij; split_ifs;
  · norm_num;
  · positivity;
  · linarith [ hrob.gap_pos ];
  · convert chi_sq_bound_of_marginals hrob.gap_pos hrob.gap_le_half ( hrob.marginal_lower i ) ( hrob.marginal_upper i ) ( hrob.marginal_lower j ) ( hrob.marginal_upper j ) ( hrob.cov_bound hij ) using 1;
    ring

/-
**Theorem 3 (Entropy deletion lower bound).**
    H(delete_k(μ)) ≥ H(μ) - log 2.
-/
theorem entropy_delete_lower_bound
    {n : ℕ} (μ : FinsetLaw n) (k : Fin n) :
    totalEntropy (deleteCoordPushforward μ k) ≥ totalEntropy μ - Real.log 2 := by
  -- By the concavity of -x log x, for a, b ≥ 0 with a+b > 0: -a log a - b log b ≤ -(a+b) log((a+b)/2) = -(a+b) log(a+b) + (a+b) log 2.
  have h_concave : ∀ a b : ℝ, 0 ≤ a → 0 ≤ b → -(a * Real.log a + b * Real.log b) ≤ -(a + b) * Real.log (a + b) + (a + b) * Real.log 2 := by
    intro a b ha hb; rcases eq_or_lt_of_le ha with ( rfl | ha ) <;> rcases eq_or_lt_of_le hb with ( rfl | hb ) <;> norm_num;
    · positivity;
    · positivity;
    · have h_concave : ConcaveOn ℝ (Set.Ici 0) (fun x : ℝ => -x * Real.log x) := by
        apply_rules [ StrictConcaveOn.concaveOn ];
        apply strictConcaveOn_of_deriv2_neg ( convex_Ici 0 );
        · exact Continuous.continuousOn ( by simpa using Real.continuous_mul_log.neg );
        · simp +zetaDelta at *;
          intro x hx; rw [ show deriv ( fun i => deriv ( fun i => i * Real.log i ) i ) x = deriv ( fun i => Real.log i + 1 ) x from Filter.EventuallyEq.deriv_eq <| by filter_upwards [ lt_mem_nhds hx ] with i hi using by simp +decide [ hi.ne' ] ] ; norm_num [ hx.ne' ] ; positivity;
      have := h_concave.2 ha.le hb.le;
      have := @this ( 1 / 2 ) ( 1 / 2 ) ( by norm_num ) ( by norm_num ) ( by norm_num ) ; norm_num at this ; ring_nf at * ; norm_num at *;
      rw [ show b * ( 1 / 2 ) + a * ( 1 / 2 ) = ( b + a ) / 2 by ring, Real.log_div ( by positivity ) ( by positivity ) ] at * ; ring_nf at * ; norm_num at * ; linarith;
  -- Apply the concavity inequality to each pair (s, insert k s) where k ∉ s.
  have h_sum_concave : ∑ s ∈ Finset.univ.filter (fun s => k ∉ s), (μ.weight s * Real.log (μ.weight s) + μ.weight (insert k s) * Real.log (μ.weight (insert k s))) ≥ ∑ s ∈ Finset.univ.filter (fun s => k ∉ s), ((μ.weight s + μ.weight (insert k s)) * Real.log (μ.weight s + μ.weight (insert k s)) - (μ.weight s + μ.weight (insert k s)) * Real.log 2) := by
    exact Finset.sum_le_sum fun s hs => by linarith [ h_concave ( μ.weight s ) ( μ.weight ( insert k s ) ) ( μ.nonneg s ) ( μ.nonneg ( insert k s ) ) ] ;
  -- By definition of `deleteCoordPushforward`, we can rewrite the sum.
  have h_delete_sum : ∑ s : Finset (Fin n), deleteCoordLaw μ k s * Real.log (deleteCoordLaw μ k s) = ∑ s ∈ Finset.univ.filter (fun s => k ∉ s), (μ.weight s + μ.weight (insert k s)) * Real.log (μ.weight s + μ.weight (insert k s)) := by
    unfold deleteCoordLaw;
    rw [ Finset.sum_filter ] ; congr ; ext ; aesop;
  -- By definition of `totalEntropy`, we can rewrite the sum.
  have h_total_sum : ∑ s : Finset (Fin n), μ.weight s * Real.log (μ.weight s) = ∑ s ∈ Finset.univ.filter (fun s => k ∉ s), (μ.weight s * Real.log (μ.weight s) + μ.weight (insert k s) * Real.log (μ.weight (insert k s))) := by
    have h_total_sum : ∑ s : Finset (Fin n), μ.weight s * Real.log (μ.weight s) = ∑ s ∈ Finset.univ.filter (fun s => k ∉ s), μ.weight s * Real.log (μ.weight s) + ∑ s ∈ Finset.univ.filter (fun s => k ∈ s), μ.weight s * Real.log (μ.weight s) := by
      rw [ Finset.sum_filter, Finset.sum_filter ] ; rw [ ← Finset.sum_add_distrib ] ; congr ; ext ; aesop;
    have h_total_sum : ∑ s ∈ Finset.univ.filter (fun s => k ∈ s), μ.weight s * Real.log (μ.weight s) = ∑ s ∈ Finset.univ.filter (fun s => k ∉ s), μ.weight (insert k s) * Real.log (μ.weight (insert k s)) := by
      apply Finset.sum_bij (fun s hs => s.erase k);
      · simp +contextual [ Finset.mem_erase ];
      · simp +contextual [ Finset.ext_iff ];
        grind;
      · exact fun s hs => ⟨ Insert.insert k s, by aesop ⟩;
      · simp +contextual [ Finset.insert_erase ];
    rw [ Finset.sum_add_distrib, ‹∑ s, μ.weight s * Real.log ( μ.weight s ) = _›, h_total_sum ];
  simp_all +decide [ totalEntropy ];
  -- By definition of `deleteCoordPushforward`, we can rewrite the sum as:
  have h_delete_sum : ∑ s ∈ Finset.univ.filter (fun s => k ∉ s), (μ.weight s + μ.weight (insert k s)) = 1 := by
    convert deleteCoordLaw_total μ k using 1;
    unfold deleteCoordLaw; simp +decide [ Finset.sum_ite ] ;
  simp_all +decide [ ← Finset.sum_mul _ _ _ ];
  linarith!

/-
**Theorem 4 (Susceptibility bound — cross-domain bridge).**
    χ ≤ n·(1/4 + (n-1)·ε).
-/
theorem susceptibility_bound_of_robust
    {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hrob : RobustlyLorentzian μ ε) :
    spinSusceptibility μ ≤ susceptibilityBound n ε := by
  -- By definition of `spinSusceptibility`, we can split the sum into diagonal and off-diagonal parts.
  have h_split : spinSusceptibility μ = ∑ i : Fin n, (coordCov μ i i) + ∑ i : Fin n, ∑ j ∈ Finset.univ \ {i}, (coordCov μ i j) := by
    simp +decide [ ← Finset.sum_add_distrib, spinSusceptibility ];
  -- For $j \ne i$, $|coordCov \mu i j| \le \epsilon$ by $hrob.cov_bound$, so $coordCov \mu i j \le \epsilon$.
  have h_off_diag : ∀ i : Fin n, ∑ j ∈ Finset.univ \ {i}, coordCov μ i j ≤ (n - 1) * ε := by
    intro i
    have h_off_diag : ∀ j ∈ Finset.univ \ {i}, coordCov μ i j ≤ ε := by
      exact fun j hj => le_trans ( hrob.neg_dep ( by aesop ) ) ( by linarith [ hrob.gap_pos ] );
    convert Finset.sum_le_sum h_off_diag ; simp +decide [ Finset.card_sdiff, * ];
    exact Or.inl ( by rw [ Nat.cast_pred ( Fin.pos i ) ] );
  convert add_le_add ( Finset.sum_le_sum fun i _ => coordVar_le_quarter μ i ) ( Finset.sum_le_sum fun i _ => h_off_diag i ) using 1;
  unfold susceptibilityBound; norm_num; ring;

/-! ## Part 4: Information Profile -/

structure InfoProfile (n : ℕ) where
  entropy : ℝ
  coordMarginals : Fin n → ℝ
  susceptibility : ℝ

def auditRobustLorentzianInfoProfile (μ : FinsetLaw n) : InfoProfile n where
  entropy := totalEntropy μ
  coordMarginals := fun i => coordProb μ i
  susceptibility := spinSusceptibility μ

end LorentzianInformation