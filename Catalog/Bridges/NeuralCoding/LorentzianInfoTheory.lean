/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Lorentzian Information Theory: Entropy and Mutual Information Bounds

This file establishes the formal bridge between **robust Lorentzian negativity**
and **quantitative information-theoretic bounds** for probability measures on
finite subsets.

Building on `robust_quadform_negativity` from the catalog, we prove that the
algebraic negativity mechanisms controlling pairwise dependence also force
monotonicity and rigidity of entropy-like quantities under projection and
conditioning.

## Central Dictionary

- **Lorentzian gap** ↔ **information contraction rate**
- **Rayleigh-type negativity** ↔ **pairwise MI suppression**
- **Coordinate deletion** ↔ **data processing inequality**
- **Susceptibility** ↔ **spin response bound (statistical mechanics)**

## Main Results

* `susceptibility_le_of_robust` — χ ≤ ε·(∑pᵢ)² (statistical physics bridge)
* `chiSq_le_of_robust` — χ²(i,j) ≤ ε²·pq/((1-p)(1-q)) (MI bridge)
* `entropy_delete_le` — H(π_k μ) ≤ H(μ) (data processing inequality)
* `entropy_delete_ge` — H(π_k μ) ≥ H(μ) - log 2 (deletion lower bound)
* `shearer_avg_bound` — covering inequality for average deleted entropy

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Anari–Oveis Gharan–Vinzant, "Log-Concave Polynomials", STOC 2019
-/

open Finset BigOperators

noncomputable section

namespace LorentzianInfoTheory

/-! ## Section 1: Core Definitions -/

/-- A probability law on subsets of `Fin n`. -/
structure FinsetLaw (n : ℕ) where
  weight : Finset (Fin n) → ℝ
  nonneg : ∀ s, 0 ≤ weight s
  total_one : ∑ s : Finset (Fin n), weight s = 1

/-- Marginal probability that coordinate `i` appears in a random subset. -/
def coordProb {n : ℕ} (μ : FinsetLaw n) (i : Fin n) : ℝ :=
  ∑ s : Finset (Fin n), if i ∈ s then μ.weight s else 0

/-- Joint probability that both `i` and `j` appear. -/
def pairJointProb {n : ℕ} (μ : FinsetLaw n) (i j : Fin n) : ℝ :=
  ∑ s : Finset (Fin n), if i ∈ s ∧ j ∈ s then μ.weight s else 0

/-- Covariance of indicators `𝟙_{i ∈ S}` and `𝟙_{j ∈ S}`. -/
def coordCov {n : ℕ} (μ : FinsetLaw n) (i j : Fin n) : ℝ :=
  pairJointProb μ i j - coordProb μ i * coordProb μ j

/-- Shannon entropy. Uses `Real.log 0 = 0` so `0 · log 0 = 0`. -/
def totalEntropy {n : ℕ} (μ : FinsetLaw n) : ℝ :=
  - ∑ s : Finset (Fin n), μ.weight s * Real.log (μ.weight s)

/-! ## Section 2: Robustness Predicate -/

/-- **Robustly Lorentzian with gap `ε`.**
    Encodes consequences of `robust_quadform_negativity` in the probabilistic setting. -/
structure RobustlyLorentzian {n : ℕ} (μ : FinsetLaw n) (ε : ℝ) : Prop where
  gap_pos : 0 < ε
  neg_cov : ∀ i j : Fin n, i ≠ j → coordCov μ i j ≤ 0
  cov_bound : ∀ i j : Fin n, i ≠ j →
    |coordCov μ i j| ≤ ε * coordProb μ i * coordProb μ j
  marginal_pos : ∀ i : Fin n, 0 < coordProb μ i
  marginal_lt_one : ∀ i : Fin n, coordProb μ i < 1

/-- Pairwise covariance control (weaker than full robustness). -/
def PairwiseCovControlled {n : ℕ} (μ : FinsetLaw n) (bound : ℝ) : Prop :=
  ∀ ⦃i j : Fin n⦄, i ≠ j → |coordCov μ i j| ≤ bound

/-! ## Section 3: Information Quantities -/

/-- Spin susceptibility: total off-diagonal |covariance|.
    Statistical mechanics interpretation: system response to perturbation. -/
def spinSusceptibility {n : ℕ} (μ : FinsetLaw n) : ℝ :=
  ∑ i : Fin n, ∑ j : Fin n, if i = j then 0 else |coordCov μ i j|

/-- Chi-squared divergence for a binary pair. -/
def chiSqBinaryPair (p q c : ℝ) : ℝ :=
  c ^ 2 / (p * (1 - p) * (q * (1 - q)))

/-- Explicit MI bound from gap ε and marginals p, q. -/
def mutualInfoBound (ε p q : ℝ) : ℝ :=
  ε ^ 2 * p * q / ((1 - p) * (1 - q))

/-- Two-coordinate protocol information cost (communication complexity). -/
def protocolInfoCost {n : ℕ} (μ : FinsetLaw n) (i j : Fin n) : ℝ :=
  chiSqBinaryPair (coordProb μ i) (coordProb μ j) (coordCov μ i j)

/-! ## Section 4: Deletion Pushforward -/

/-- Weight in marginal after deleting coordinate `k`. -/
def deleteCoordWeight {n : ℕ} (μ : FinsetLaw n) (k : Fin n) (T : Finset (Fin n)) : ℝ :=
  if k ∈ T then 0 else μ.weight T + μ.weight (insert k T)

/-- Entropy of the deletion marginal. -/
def deleteCoordEntropy {n : ℕ} (μ : FinsetLaw n) (k : Fin n) : ℝ :=
  - ∑ T : Finset (Fin n), deleteCoordWeight μ k T * Real.log (deleteCoordWeight μ k T)

/-! ## Section 5: Basic Properties -/

theorem coordProb_nonneg {n : ℕ} (μ : FinsetLaw n) (i : Fin n) :
    0 ≤ coordProb μ i :=
  Finset.sum_nonneg fun _ _ => by split_ifs <;> [exact μ.nonneg _; exact le_refl 0]

theorem coordProb_le_one {n : ℕ} (μ : FinsetLaw n) (i : Fin n) :
    coordProb μ i ≤ 1 := by
  calc coordProb μ i
      ≤ ∑ s : Finset (Fin n), μ.weight s :=
        Finset.sum_le_sum fun s _ => by split_ifs <;> linarith [μ.nonneg s]
    _ = 1 := μ.total_one

theorem deleteCoordWeight_nonneg {n : ℕ} (μ : FinsetLaw n) (k : Fin n)
    (T : Finset (Fin n)) : 0 ≤ deleteCoordWeight μ k T := by
  unfold deleteCoordWeight; split_ifs <;> linarith [μ.nonneg T, μ.nonneg (insert k T)]

/-
Deletion marginal weights sum to 1.
-/
theorem deleteCoordWeight_total {n : ℕ} (μ : FinsetLaw n) (k : Fin n) :
    ∑ T : Finset (Fin n), deleteCoordWeight μ k T = 1 := by
  have h_split : ∑ T : Finset (Fin n), deleteCoordWeight μ k T = ∑ T ∈ Finset.univ.filter (fun T => k ∉ T), (μ.weight T + μ.weight (insert k T)) := by
    rw [ Finset.sum_filter ] ; congr ; ext ; aesop;
  have h_bij : Finset.sum (Finset.univ.filter (fun T => k ∉ T)) (fun T => μ.weight T) + Finset.sum (Finset.univ.filter (fun T => k ∈ T)) (fun T => μ.weight T) = 1 := by
    convert μ.total_one using 1;
    rw [ Finset.sum_filter, Finset.sum_filter ] ; rw [ ← Finset.sum_add_distrib ] ; congr ; ext ; aesop;
  have h_bij : Finset.sum (Finset.univ.filter (fun T => k ∉ T)) (fun T => μ.weight (insert k T)) = Finset.sum (Finset.univ.filter (fun T => k ∈ T)) (fun T => μ.weight T) := by
    apply Finset.sum_bij (fun T hT => insert k T);
    · aesop;
    · simp +contextual [ Finset.ext_iff ];
      grind;
    · exact fun T hT => ⟨ T.erase k, by aesop ⟩;
    · aesop;
  simp_all +decide [ Finset.sum_add_distrib ]

/-
Shannon entropy is nonneg.
-/
theorem entropy_nonneg {n : ℕ} (μ : FinsetLaw n) : 0 ≤ totalEntropy μ := by
  exact neg_nonneg_of_nonpos ( Finset.sum_nonpos fun s _ => mul_nonpos_of_nonneg_of_nonpos ( μ.nonneg s ) ( Real.log_nonpos ( μ.nonneg s ) ( by linarith [ show ∑ t, μ.weight t = 1 from μ.total_one, ( Finset.single_le_sum ( fun t _ => μ.nonneg t ) ( Finset.mem_univ s ) ) ] ) ) )

/-- Covariance bound from robustness. -/
theorem cov_bound_of_robust {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hrob : RobustlyLorentzian μ ε) (i j : Fin n) (hij : i ≠ j) :
    |coordCov μ i j| ≤ ε * coordProb μ i * coordProb μ j :=
  hrob.cov_bound i j hij

/-! ## Section 6: Key Technical Lemma — Superadditivity of x·log(x)

For `a, b ≥ 0`: `(a+b)·log(a+b) ≥ a·log a + b·log b`.
Proof: decompose `a·log a = a·log(a/(a+b)) + a·log(a+b)`,
then note `log(a/(a+b)) ≤ 0`. -/

/-
x·log x superadditivity.
-/
theorem xlogx_superadditive (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    a * Real.log a + b * Real.log b ≤ (a + b) * Real.log (a + b) := by
  rcases eq_or_lt_of_le ha with ( rfl | ha ) <;> rcases eq_or_lt_of_le hb with ( rfl | hb ) <;> norm_num;
  nlinarith [ Real.log_le_log ( by positivity ) ( by linarith : a ≤ a + b ), Real.log_le_log ( by positivity ) ( by linarith : b ≤ a + b ) ]

/-
Merge penalty bounded by `(a+b)·log 2`.
-/
theorem xlogx_merge_le_log2 (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) (hab : a + b ≤ 1) :
    (a + b) * Real.log (a + b) - (a * Real.log a + b * Real.log b) ≤
      (a + b) * Real.log 2 := by
  by_cases hb' : b = 0 <;> by_cases ha' : a = 0 <;> simp_all +decide;
  · positivity;
  · positivity;
  · -- Let $p = \frac{a}{a+b}$ and $q = \frac{b}{a+b}$. Then $p + q = 1$.
    set p : ℝ := a / (a + b)
    set q : ℝ := b / (a + b)
    have hpq : p + q = 1 := by
      rw [ ← add_div, div_self ( by positivity ) ];
    -- We need to show that $-p \log p - q \log q \leq \log 2$.
    have h_ineq : -p * Real.log p - q * Real.log q ≤ Real.log 2 := by
      -- We'll use the fact that $p \log p + q \log q \geq (p + q) \log \frac{p + q}{2}$ for $p, q \geq 0$ and $p + q = 1$.
      have h_ineq : p * Real.log p + q * Real.log q ≥ (p + q) * Real.log ((p + q) / 2) := by
        -- We'll use the fact that $f(x) = x \log x$ is convex on $(0, \infty)$.
        have h_convex : ConvexOn ℝ (Set.Ioi 0) (fun x : ℝ => x * Real.log x) := by
          exact ( Real.convexOn_mul_log.subset Set.Ioi_subset_Ici_self <| convex_Ioi _ );
        have := h_convex.2 ( show 0 < p by positivity ) ( show 0 < q by positivity );
        have := @this ( 1 / 2 ) ( 1 / 2 ) ( by norm_num ) ( by norm_num ) ( by norm_num ) ; norm_num at * ; ring_nf at * ; linarith;
      norm_num [ hpq ] at h_ineq;
      rw [ Real.log_div ] at h_ineq <;> norm_num at * ; linarith;
    simp +zetaDelta at *;
    rw [ Real.log_div, Real.log_div ] at h_ineq <;> try positivity;
    field_simp at h_ineq;
    linarith

/-! ## Section 7: Main Theorems -/

/-
**Theorem 1 (Susceptibility Bound — Statistical Physics Bridge).**

    For robustly Lorentzian `μ` with gap `ε`:
    `χ = ∑_{i≠j} |Cov(Xᵢ,Xⱼ)| ≤ ε · (∑ pᵢ)²`

    The Lorentzian gap acts as repulsive curvature limiting spin-spin response.
-/
theorem susceptibility_le_of_robust {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hrob : RobustlyLorentzian μ ε) :
    spinSusceptibility μ ≤ ε * (∑ i : Fin n, coordProb μ i) ^ 2 := by
  convert Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => ?_ using 1;
  case convert_10 => exact fun i j => ε * coordProb μ i * coordProb μ j;
  · simp +decide only [pow_two, Finset.mul_sum _ _ _, sum_mul, mul_assoc];
    exact Finset.sum_comm;
  · infer_instance;
  · split_ifs <;> [ simp +decide [ * ] ; exact hrob.cov_bound i j ‹_› ];
    exact mul_nonneg ( mul_nonneg hrob.gap_pos.le ( coordProb_nonneg μ j ) ) ( coordProb_nonneg μ j );
  · exact fun _ _ => inferInstance

/-
**Theorem 2 (Chi-Squared Bound — Information-Theoretic Bridge).**

    `χ²(Xᵢ,Xⱼ) ≤ ε² · pᵢ·pⱼ / ((1-pᵢ)(1-pⱼ))`

    Central result: **Lorentzian gap → information contraction**.
-/
theorem chiSq_le_of_robust {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hrob : RobustlyLorentzian μ ε) (i j : Fin n) (hij : i ≠ j) :
    protocolInfoCost μ i j ≤ mutualInfoBound ε (coordProb μ i) (coordProb μ j) := by
  unfold protocolInfoCost mutualInfoBound chiSqBinaryPair;
  rw [ div_le_div_iff₀ ];
  · convert mul_le_mul_of_nonneg_right ( pow_le_pow_left₀ ( abs_nonneg _ ) ( hrob.cov_bound i j hij ) 2 ) ( mul_nonneg ( sub_nonneg.mpr ( hrob.marginal_lt_one i |> le_of_lt ) ) ( sub_nonneg.mpr ( hrob.marginal_lt_one j |> le_of_lt ) ) ) using 1 ; ring;
    · norm_num ; ring;
    · ring;
  · exact mul_pos ( mul_pos ( hrob.marginal_pos i ) ( sub_pos.mpr ( hrob.marginal_lt_one i ) ) ) ( mul_pos ( hrob.marginal_pos j ) ( sub_pos.mpr ( hrob.marginal_lt_one j ) ) );
  · exact mul_pos ( sub_pos.mpr ( hrob.marginal_lt_one i ) ) ( sub_pos.mpr ( hrob.marginal_lt_one j ) )

/-
**Theorem 3 (Entropy Data Processing — Deletion Monotonicity).**

    `H(π_k(μ)) ≤ H(μ)`: entropy does not increase under coordinate deletion.
-/
theorem entropy_delete_le {n : ℕ} (μ : FinsetLaw n) (k : Fin n) :
    deleteCoordEntropy μ k ≤ totalEntropy μ := by
  -- By the superadditivity property of the function $x \log x$, we have for each pair $(a, b)$:
  have h_superadditivity : ∀ T : Finset (Fin n), k ∉ T → μ.weight T * Real.log (μ.weight T) + μ.weight (insert k T) * Real.log (μ.weight (insert k T)) ≤ (μ.weight T + μ.weight (insert k T)) * Real.log (μ.weight T + μ.weight (insert k T)) := by
    exact fun T hT => xlogx_superadditive _ _ ( μ.nonneg _ ) ( μ.nonneg _ );
  unfold deleteCoordEntropy totalEntropy;
  -- By partitioning the sum over all subsets T into those that include k and those that do not, we can apply � the� superadditivity property to each pair.
  have h_partition : ∑ T : Finset (Fin n), μ.weight T * Real.log (μ.weight T) = ∑ T ∈ Finset.filter (fun T => k ∉ T) Finset.univ, (μ.weight T * Real.log (μ.weight T) + μ.weight (insert k T) * Real.log (μ.weight (insert k T))) := by
    rw [ ← Finset.sum_subset ( Finset.subset_univ ( Finset.filter ( fun T => k ∉ T ) Finset.univ ∪ Finset.image ( fun T => insert k T ) ( Finset.filter ( fun T => k ∉ T ) Finset.univ ) ) ) ];
    · rw [ Finset.sum_union, Finset.sum_image ];
      · rw [ Finset.sum_add_distrib ];
      · intro T hT T' hT' h_eq; simp_all +decide [ Finset.ext_iff ] ;
        grind;
      · simp +contextual [ Finset.disjoint_right ];
    · simp +contextual [ Finset.mem_union, Finset.mem_image ];
      exact fun T hk₁ hk₂ => False.elim <| hk₂ ( Finset.erase T k ) ( by aesop ) <| by aesop;
  simp_all +decide [ Finset.sum_ite ];
  convert Finset.sum_le_sum fun T hT => h_superadditivity T <| Finset.mem_filter.mp hT |>.2 using 1;
  unfold deleteCoordWeight;
  rw [ Finset.sum_filter ] ; congr ; ext ; aesop

/-
**Theorem 4 (Entropy Deletion Lower Bound).**

    `H(π_k(μ)) ≥ H(μ) - log 2`: deleting one coordinate loses at most log 2.
-/
theorem entropy_delete_ge {n : ℕ} (μ : FinsetLaw n) (k : Fin n) :
    totalEntropy μ - Real.log 2 ≤ deleteCoordEntropy μ k := by
  -- By the properties of the logarithm and the definition of `deleteCoordWeight`, we can show that the difference in entropies is bounded by log 2.
  have h_diff : ∑ T ∈ Finset.univ.filter (fun T => k ∉ T), (μ.weight T + μ.weight (insert k T)) * Real.log (μ.weight T + μ.weight (insert k T)) - ∑ T ∈ Finset.univ.filter (fun T => k ∉ T), (μ.weight T * Real.log (μ.weight T) + μ.weight (insert k T) * Real.log (μ.weight (insert k T))) ≤ Real.log 2 := by
    have h_diff : ∀ T ∈ Finset.univ.filter (fun T => k ∉ T), (μ.weight T + μ.weight (insert k T)) * Real.log (μ.weight T + μ.weight (insert k T)) - (μ.weight T * Real.log (μ.weight T) + μ.weight (insert k T) * Real.log (μ.weight (insert k T))) ≤ (μ.weight T + μ.weight (insert k T)) * Real.log 2 := by
      intro T hT; have := xlogx_merge_le_log2 ( μ.weight T ) ( μ.weight ( insert k T ) ) ( μ.nonneg T ) ( μ.nonneg ( insert k T ) ) ?_ ; aesop;
      have := μ.total_one;
      rw [ ← this, ← Finset.sum_pair ];
      · exact Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_univ _ ) fun _ _ _ => μ.nonneg _;
      · grind;
    convert Finset.sum_le_sum h_diff using 1;
    · rw [ Finset.sum_sub_distrib ];
    · rw [ ← Finset.sum_mul _ _ _, eq_comm ];
      convert congr_arg ( · * Real.log 2 ) ( deleteCoordWeight_total μ k ) using 1 ; ring!;
      · unfold deleteCoordWeight; simp +decide [ mul_comm, Finset.sum_ite ] ;
      · ring;
  unfold totalEntropy deleteCoordEntropy deleteCoordWeight;
  simp_all +decide [ Finset.sum_ite ];
  convert h_diff using 1;
  rw [ ← Finset.sum_subset ( show Finset.filter ( fun T => k ∉ T ) Finset.univ ∪ Finset.filter ( fun T => k ∈ T ) Finset.univ ⊆ Finset.univ from Finset.subset_univ _ ) ] <;> norm_num [ Finset.sum_union ] ; ring;
  rw [ Finset.sum_union ] <;> norm_num [ Finset.sum_add_distrib ];
  · refine' Finset.sum_bij ( fun x hx => x.erase k ) _ _ _ _ <;> simp_all +decide [ Finset.mem_erase, Finset.mem_filter ];
    · intro a₁ ha₁ a₂ ha₂ h; rw [ ← Finset.insert_erase ha₁, ← Finset.insert_erase ha₂, h ] ;
    · exact fun b hb => ⟨ Insert.insert k b, Finset.mem_insert_self _ _, by rw [ Finset.erase_insert hb ] ⟩;
  · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by tauto;

/-- **Theorem 5 (Protocol Information Cost — Communication Complexity Bridge).**

    Two-coordinate protocol info cost bounded by MI bound. -/
theorem protocol_info_cost_le {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hrob : RobustlyLorentzian μ ε) (i j : Fin n) (hij : i ≠ j) :
    protocolInfoCost μ i j ≤ mutualInfoBound ε (coordProb μ i) (coordProb μ j) :=
  chiSq_le_of_robust μ hrob i j hij

/-
**Theorem 6 (Shearer-Type Covering Bound).**

    `H(μ) ≤ (1/n) · ∑_k H(π_k μ) + log 2`

    Covering inequality: total entropy bounded by average deletion entropy.
-/
theorem shearer_avg_bound {n : ℕ} (hn : 0 < n) (μ : FinsetLaw n) :
    totalEntropy μ ≤
      (1 / (n : ℝ)) * ∑ k : Fin n, deleteCoordEntropy μ k + Real.log 2 := by
  field_simp;
  convert add_le_add_right ( Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => entropy_delete_ge μ i ) ( n * Real.log 2 ) using 1 ; norm_num ; ring;
  ring

/-! ## Section 8: Derived Results -/

/-- Marginal variance positivity under robustness. -/
theorem marginal_variance_pos {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hrob : RobustlyLorentzian μ ε) (i : Fin n) :
    0 < coordProb μ i * (1 - coordProb μ i) :=
  mul_pos (hrob.marginal_pos i) (sub_pos.mpr (hrob.marginal_lt_one i))

/-- Negative covariance under robustness. -/
theorem neg_cov_of_robust {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hrob : RobustlyLorentzian μ ε) (i j : Fin n) (hij : i ≠ j) :
    coordCov μ i j ≤ 0 :=
  hrob.neg_cov i j hij

/-
Average deletion entropy ≤ total entropy (from DPI).
-/
theorem avg_delete_le {n : ℕ} (hn : 0 < n) (μ : FinsetLaw n) :
    (1 / (n : ℝ)) * ∑ k : Fin n, deleteCoordEntropy μ k ≤ totalEntropy μ := by
  rw [ div_mul_eq_mul_div, div_le_iff₀ ] <;> norm_cast;
  simpa [ mul_comm ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => entropy_delete_le μ i

/-
Total pairwise MI bound under robustness.
-/
theorem total_pairwise_MI_bound {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hrob : RobustlyLorentzian μ ε) :
    ∑ i : Fin n, ∑ j : Fin n,
      (if i = j then (0 : ℝ) else protocolInfoCost μ i j) ≤
    ∑ i : Fin n, ∑ j : Fin n,
      (if i = j then (0 : ℝ) else mutualInfoBound ε (coordProb μ i) (coordProb μ j)) := by
  refine' Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => _;
  split_ifs <;> [ simp +decide ; exact chiSq_le_of_robust μ hrob i j ‹_› ]

end LorentzianInfoTheory