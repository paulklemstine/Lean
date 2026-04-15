/-! # CatalogBuild.Analysis.Convergence

Auto-generated from theorem catalog database.
Domain: Analysis
Declarations: 14
-/

import Mathlib

noncomputable section

/-- A belief vector on n hypotheses. -/
def Beliefs (n : ℕ) := Fin n → ℝ

/-
PROBLEM
**Theorem 8.1 (Support Monotonicity)**: If b(i) = 0 then the posterior
    also has b'(i) = 0 — dead hypotheses stay dead.

PROVIDED SOLUTION
Split on whether e = 0. If e = 0, the if takes b i = 0 by hi. If e ≠ 0, (b i * l i) / e = (0 * l i) / e = 0 / e = 0, using hi to rewrite b i = 0.
-/

theorem dead_hypothesis_stays_dead {n : ℕ} (b : Beliefs n) (l : Fin n → ℝ)
    (hl : ∀ i, 0 ≤ l i) (i : Fin n) (hi : b i = 0)
    (e : ℝ) (he_def : e = ∑ j : Fin n, b j * l j) :
    (if e = 0 then b i else (b i * l i) / e) = 0 := by
  aesop

/-
PROBLEM
**Theorem 8.2 (Zero Likelihood Eliminates)**: If hypothesis i has
    zero likelihood, it gets zero posterior weight.

PROVIDED SOLUTION
Rewrite l i = 0 using hli, then b i * 0 = 0, then 0 / anything = 0.
-/

theorem zero_likelihood_eliminates {n : ℕ} (b : Beliefs n) (l : Fin n → ℝ)
    (i : Fin n) (hli : l i = 0)
    (he : 0 < ∑ j : Fin n, b j * l j) :
    (b i * l i) / (∑ j : Fin n, b j * l j) = 0 := by
  aesop

-- ═══════════════════════════════════════════════════════════════════════
-- §9: L¹ METRIC ON BELIEFS
-- ═══════════════════════════════════════════════════════════════════════

/-- L¹ distance between two belief states. -/

def beliefDistance {n : ℕ} (b₁ b₂ : Beliefs n) : ℝ :=
  ∑ i : Fin n, |b₁ i - b₂ i|

/-
PROBLEM
**Theorem 9.1**: L¹ distance is non-negative.

PROVIDED SOLUTION
Sum of absolute values is nonneg. Use Finset.sum_nonneg with abs_nonneg.
-/

theorem beliefDistance_nonneg {n : ℕ} (b₁ b₂ : Beliefs n) :
    0 ≤ beliefDistance b₁ b₂ := by
  exact Finset.sum_nonneg fun _ _ => abs_nonneg _

/-
PROBLEM
**Theorem 9.2**: L¹ distance is symmetric.

PROVIDED SOLUTION
Each term |b₁ i - b₂ i| = |b₂ i - b₁ i| by abs_sub_comm. Use Finset.sum_congr.
-/

theorem beliefDistance_symm {n : ℕ} (b₁ b₂ : Beliefs n) :
    beliefDistance b₁ b₂ = beliefDistance b₂ b₁ := by
  exact Finset.sum_congr rfl fun _ _ => abs_sub_comm _ _

/-
PROBLEM
**Theorem 9.3**: Triangle inequality for L¹ distance.

PROVIDED SOLUTION
Use Finset.sum_le_sum with the pointwise triangle inequality |a - c| ≤ |a - b| + |b - c| (abs_sub_abs_le_abs_sub or dist_triangle). Then use Finset.sum_add_sum_compl or just sum_add to combine.
-/

theorem beliefDistance_triangle {n : ℕ} (b₁ b₂ b₃ : Beliefs n) :
    beliefDistance b₁ b₃ ≤ beliefDistance b₁ b₂ + beliefDistance b₂ b₃ := by
  unfold beliefDistance;
  simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum fun i _ => abs_sub_le _ _ _

/-
PROBLEM
**Theorem 9.4**: Distance zero iff equal.

PROVIDED SOLUTION
Forward: if sum of |b₁ i - b₂ i| = 0, since each term is ≥ 0 (abs_nonneg), all terms must be 0. So |b₁ i - b₂ i| = 0 for all i, hence b₁ i = b₂ i for all i, so b₁ = b₂ by funext. Backward: if b₁ = b₂, each |b₁ i - b₂ i| = 0, sum = 0. Use Finset.sum_eq_zero_iff_of_nonneg.
-/

theorem beliefDistance_eq_zero_iff {n : ℕ} (b₁ b₂ : Beliefs n) :
    beliefDistance b₁ b₂ = 0 ↔ b₁ = b₂ := by
  exact ⟨ fun h => funext fun i => sub_eq_zero.mp <| abs_eq_zero.mp <| Finset.sum_eq_zero_iff_of_nonneg ( fun _ _ => abs_nonneg _ ) |>.1 h i <| Finset.mem_univ _, fun h => h ▸ Finset.sum_eq_zero fun _ _ => by simp +decide ⟩

/-
PROBLEM
═══════════════════════════════════════════════════════════════════════
§10: GEOMETRIC CONVERGENCE
═══════════════════════════════════════════════════════════════════════

**Theorem 10.1 (Geometric Convergence)**: If aₖ₊₁ ≤ c·aₖ for 0 ≤ c < 1,
    then aₖ ≤ cᵏ · a₀.

PROVIDED SOLUTION
Induction on k. Base case: a 0 ≤ c^0 * a 0 = a 0. Inductive step: a (k+1) ≤ c * a k ≤ c * (c^k * a 0) = c^(k+1) * a 0. Need nonneg of a k by induction and the fact that a(k+1) ≤ c * a(k) and c ≥ 0.
-/

theorem geometric_convergence (a : ℕ → ℝ) (c : ℝ)
    (ha0 : 0 ≤ a 0) (hc0 : 0 ≤ c) (hc1 : c < 1)
    (hstep : ∀ k, a (k + 1) ≤ c * a k) :
    ∀ k, a k ≤ c ^ k * a 0 := by
  exact fun k => Nat.recOn k ( by norm_num ) fun k ih => by rw [ pow_succ', mul_assoc ] ; exact le_trans ( hstep k ) ( mul_le_mul_of_nonneg_left ih hc0 ) ;

/-
PROBLEM
**Theorem 10.2 (Geometric Series Bound)**: ∑_{k<n} cᵏ ≤ 1/(1-c).

PROVIDED SOLUTION
Use geom_sum_le or induction. The partial geometric sum equals (1 - c^n)/(1 - c). Since 0 ≤ c < 1, c^n ≥ 0, so (1 - c^n)/(1 - c) ≤ 1/(1 - c). Use Mathlib's geom_sum_eq or geom_series_def.
-/

theorem geometric_partial_sum_bound (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c < 1)
    (n : ℕ) :
    ∑ k ∈ Finset.range n, c ^ k ≤ 1 / (1 - c) := by
  rw [ le_div_iff₀ ] <;> nlinarith [ pow_nonneg hc0 n, geom_sum_mul c n ]

-- ═══════════════════════════════════════════════════════════════════════
-- §11: IDEMPOTENT UPDATES AND COMPLETENESS
-- ═══════════════════════════════════════════════════════════════════════

/-- Evidence for a belief-likelihood pair. -/

def bayesEvidence {n : ℕ} (b : Fin n → ℝ) (l : Fin n → ℝ) : ℝ :=
  ∑ j, b j * l j

/-- The Bayesian update operator. -/

def bayesUpdate {n : ℕ} (l : Fin n → ℝ) (b : Fin n → ℝ) : Fin n → ℝ :=
  if bayesEvidence b l = 0 then b else fun i => (b i * l i) / bayesEvidence b l

/-
PROBLEM
**Theorem 11.1 (Idempotent Update)**: Updating twice with deterministic
    evidence is the same as updating once.

PROVIDED SOLUTION
Unfold bayesUpdate. After first update with positive evidence, b'(i) = b(i)*l(i)/e. For second update, evidence' = ∑ b'(j)*l(j) = ∑ (b(j)*l(j)/e)*l(j) = (1/e)*∑ b(j)*l(j)². Since l(j) ∈ {0,1}, l(j)² = l(j), so evidence' = (1/e)*∑ b(j)*l(j) = e/e = 1 (when e > 0). Then b''(i) = b'(i)*l(i)/1 = b'(i)*l(i). But b'(i) = b(i)*l(i)/e and l(i) ∈ {0,1}, so l(i)² = l(i), giving b''(i) = b(i)*l(i)/e = b'(i). Handle the e = 0 case separately.
-/

theorem idempotent_deterministic_update {n : ℕ} (b : Fin n → ℝ)
    (l : Fin n → ℝ) (hb : ∀ i, 0 ≤ b i) (hl : ∀ i, l i = 0 ∨ l i = 1) :
    bayesUpdate l (bayesUpdate l b) = bayesUpdate l b := by
  unfold bayesUpdate;
  by_cases h : bayesEvidence b l = 0 <;> simp +decide [ h, bayesEvidence ];
  · unfold bayesEvidence at h; aesop;
  · split_ifs <;> simp_all +decide [ div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ];
    simp_all +decide [ ← mul_assoc, ← Finset.sum_mul _ _ _ ];
    grind +locals

/-
PROBLEM
**Theorem 11.2 (Scientific Method Completeness)**: For any true hypothesis
    h* in a finite space, there exist discriminating experiments.

PROVIDED SOLUTION
Construct constant experiments: for each k, set experiments k i = 1 for all i. Then all conditions hold: nonneg (all 1), positive at hstar (1 > 0), and for i ≠ hstar, experiments k i = 1 ≤ 1 = experiments k hstar.
-/

theorem scientific_method_complete {n : ℕ} (hn : 0 < n) (hstar : Fin n) :
    ∃ experiments : Fin (n - 1) → (Fin n → ℝ),
      (∀ k, ∀ i, 0 ≤ experiments k i) ∧
      (∀ k, 0 < experiments k hstar) ∧
      (∀ k, ∀ i, i ≠ hstar → experiments k i ≤ experiments k hstar) := by
  exact ⟨ fun _ _ => 1, fun _ _ => by norm_num, fun _ => by norm_num, fun _ _ _ => by norm_num ⟩


end
