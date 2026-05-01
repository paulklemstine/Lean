import Mathlib

/-! # CatalogBuild.Algebra.Convergence

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 14
-/


noncomputable section

/-- A belief vector on n hypotheses. -/
def Beliefs (n : ℕ) := Fin n → ℝ




/-- [Section: # CatalogBuild.Algebra.Convergence
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 14] -/
theorem dead_hypothesis_stays_dead {n : ℕ} (b : Beliefs n) (l : Fin n → ℝ)
    (hl : ∀ i, 0 ≤ l i) (i : Fin n) (hi : b i = 0)
    (e : ℝ) (he_def : e = ∑ j : Fin n, b j * l j) :
    (if e = 0 then b i else (b i * l i) / e) = 0 := by
  aesop




/-- [Section: # CatalogBuild.Algebra.Convergence
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 14] -/
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




theorem beliefDistance_nonneg {n : ℕ} (b₁ b₂ : Beliefs n) :
    0 ≤ beliefDistance b₁ b₂ := by
  exact Finset.sum_nonneg fun _ _ => abs_nonneg _




theorem beliefDistance_symm {n : ℕ} (b₁ b₂ : Beliefs n) :
    beliefDistance b₁ b₂ = beliefDistance b₂ b₁ := by
  exact Finset.sum_congr rfl fun _ _ => abs_sub_comm _ _




theorem beliefDistance_triangle {n : ℕ} (b₁ b₂ b₃ : Beliefs n) :
    beliefDistance b₁ b₃ ≤ beliefDistance b₁ b₂ + beliefDistance b₂ b₃ := by
  unfold beliefDistance;
  simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum fun i _ => abs_sub_le _ _ _




theorem beliefDistance_eq_zero_iff {n : ℕ} (b₁ b₂ : Beliefs n) :
    beliefDistance b₁ b₂ = 0 ↔ b₁ = b₂ := by
  exact ⟨ fun h => funext fun i => sub_eq_zero.mp <| abs_eq_zero.mp <| Finset.sum_eq_zero_iff_of_nonneg ( fun _ _ => abs_nonneg _ ) |>.1 h i <| Finset.mem_univ _, fun h => h ▸ Finset.sum_eq_zero fun _ _ => by simp +decide ⟩




theorem geometric_convergence (a : ℕ → ℝ) (c : ℝ)
    (ha0 : 0 ≤ a 0) (hc0 : 0 ≤ c) (hc1 : c < 1)
    (hstep : ∀ k, a (k + 1) ≤ c * a k) :
    ∀ k, a k ≤ c ^ k * a 0 := by
  exact fun k => Nat.recOn k ( by norm_num ) fun k ih => by rw [ pow_succ', mul_assoc ] ; exact le_trans ( hstep k ) ( mul_le_mul_of_nonneg_left ih hc0 ) ;




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




theorem idempotent_deterministic_update {n : ℕ} (b : Fin n → ℝ)
    (l : Fin n → ℝ) (hb : ∀ i, 0 ≤ b i) (hl : ∀ i, l i = 0 ∨ l i = 1) :
    bayesUpdate l (bayesUpdate l b) = bayesUpdate l b := by
  unfold bayesUpdate;
  by_cases h : bayesEvidence b l = 0 <;> simp +decide [ h, bayesEvidence ];
  · unfold bayesEvidence at h; aesop;
  · split_ifs <;> simp_all +decide [ div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ];
    simp_all +decide [ ← mul_assoc, ← Finset.sum_mul _ _ _ ];
    grind +locals




theorem scientific_method_complete {n : ℕ} (hn : 0 < n) (hstar : Fin n) :
    ∃ experiments : Fin (n - 1) → (Fin n → ℝ),
      (∀ k, ∀ i, 0 ≤ experiments k i) ∧
      (∀ k, 0 < experiments k hstar) ∧
      (∀ k, ∀ i, i ≠ hstar → experiments k i ≤ experiments k hstar) := by
  exact ⟨ fun _ _ => 1, fun _ _ => by norm_num, fun _ => by norm_num, fun _ _ _ => by norm_num ⟩




end