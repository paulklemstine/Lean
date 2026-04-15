/-! # CatalogBuild.Logic.AdvancedTheorems

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 26
-/

import Mathlib

noncomputable section

/-- Belief state on n hypotheses. -/
def BState (n : ℕ) := Fin n → ℝ


/-- Validity of a belief state: non-negative and sums to 1. -/
def BState.Valid {n : ℕ} (b : BState n) : Prop :=
  (∀ i, 0 ≤ b i) ∧ ∑ i : Fin n, b i = 1


/-- L¹ distance between belief states. -/
def bDist {n : ℕ} (b₁ b₂ : BState n) : ℝ :=
  ∑ i : Fin n, |b₁ i - b₂ i|


/-- Evidence (marginal likelihood). -/
def bEvidence {n : ℕ} (b : BState n) (l : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, b i * l i


/-- Bayesian update operator. -/
def bUpdate {n : ℕ} (b : BState n) (l : Fin n → ℝ) : BState n :=
  if bEvidence b l = 0 then b
  else fun i => (b i * l i) / bEvidence b l


/-- A pure belief state concentrates all mass on hypothesis i. -/
def bPure {n : ℕ} (i : Fin n) : BState n :=
  fun j => if j = i then 1 else 0


/-- Shannon entropy (using natural log). -/
def bEntropy {n : ℕ} (b : BState n) : ℝ :=
  -∑ i : Fin n, if b i = 0 then 0 else b i * Real.log (b i)


/-- [Section: ═══════════════════════════════════════════════════════════════════════
§12: BELIEF SIMPLEX CONTRACTION
"Each experiment shrinks the space of viable hypotheses"
═══════════════════════════════════════════════════════════════════════] -/
theorem uniform_likelihood_identity {n : ℕ} (hn : 0 < n) (b : BState n)
    (hb : BState.Valid b) (c : ℝ) (hc : 0 < c) :
    bUpdate b (fun _ => c) = b := by
      unfold bUpdate bEvidence;
      simp_all +decide [ ← Finset.sum_mul _ _ _, hb.2 ]


theorem support_preservation {n : ℕ} (b : BState n) (l : Fin n → ℝ)
    (i : Fin n) (hi : b i = 0) :
    bUpdate b l i = 0 := by
      unfold bUpdate; aesop;


theorem evidence_pos_of_support {n : ℕ} (b : BState n) (l : Fin n → ℝ)
    (hb : BState.Valid b) (hl : ∀ i, 0 ≤ l i)
    (hsupp : ∃ i, 0 < b i ∧ 0 < l i) :
    0 < bEvidence b l := by
      obtain ⟨ i, hi ⟩ := hsupp; exact lt_of_lt_of_le ( mul_pos hi.1 hi.2 ) ( Finset.single_le_sum ( fun j _ => mul_nonneg ( hb.1 j ) ( hl j ) ) ( Finset.mem_univ i ) ) ;


theorem pure_fixed_point {n : ℕ} (i : Fin n) (l : Fin n → ℝ)
    (hl : ∀ j, 0 ≤ l j) (hli : 0 < l i) :
    bUpdate (bPure i) l = bPure i := by
      unfold bUpdate bPure;
      unfold bEvidence;
      exact funext fun j => by by_cases hj : j = i <;> simp +decide [ hj, hli.ne' ] ;


theorem dominant_weight_nondecreasing {n : ℕ} (b : BState n) (l : Fin n → ℝ)
    (i : Fin n)
    (hb : BState.Valid b) (hl : ∀ j, 0 ≤ l j)
    (hli : 0 < l i)
    (he : 0 < bEvidence b l)
    (hdom : ∀ j, l j ≤ l i) :
    b i ≤ bUpdate b l i := by
      unfold bUpdate bEvidence at *;
      split_ifs <;> simp_all +decide [ ne_of_gt, le_div_iff₀ ];
      exact mul_le_mul_of_nonneg_left ( le_trans ( Finset.sum_le_sum fun _ _ => mul_le_mul_of_nonneg_left ( hdom _ ) ( hb.1 _ ) ) ( by simp +decide [ ← Finset.sum_mul _ _ _, hb.2 ] ) ) ( hb.1 _ )


theorem entropy_pure_zero {n : ℕ} (hn : 1 ≤ n) (i : Fin n) :
    bEntropy (bPure i) = 0 := by
      unfold bEntropy bPure; aesop;


theorem entropy_nonneg' {n : ℕ} (b : BState n) (hb : BState.Valid b) :
    0 ≤ bEntropy b := by
      apply neg_nonneg.mpr;
      exact Finset.sum_nonpos fun i _ => by split_ifs <;> [ norm_num; exact mul_nonpos_of_nonneg_of_nonpos ( hb.1 i ) ( Real.log_nonpos ( hb.1 i ) ( hb.2 ▸ Finset.single_le_sum ( fun a _ => hb.1 a ) ( Finset.mem_univ i ) ) ) ] ;


theorem geometric_implies_finite {n : ℕ} (d : ℕ → ℝ)
    (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c < 1)
    (hd0 : 0 ≤ d 0)
    (hstep : ∀ k, d (k + 1) ≤ c * d k) :
    ∀ k, d k ≤ c ^ k * d 0 := by
      exact fun k => Nat.recOn k ( by norm_num ) fun k ih => by rw [ pow_succ', mul_assoc ] ; exact le_trans ( hstep k ) ( mul_le_mul_of_nonneg_left ih hc0 ) ;


theorem log_experiment_count (c d₀ ε : ℝ)
    (hc0 : 0 < c) (hc1 : c < 1) (hd : 0 < d₀) (hε : 0 < ε) (hεd : ε ≤ d₀)
    (k : ℕ) (hk : c ^ k ≤ ε / d₀) :
    c ^ k * d₀ ≤ ε := by
      rwa [ le_div_iff₀ hd ] at hk


structure SciTheory (n : ℕ) where
  belief : BState n
  valid : BState.Valid belief
  experiment_count : ℕ


def SciTheory.refine {n : ℕ} (T : SciTheory n) (l : Fin n → ℝ)
    (hl_nn : ∀ i, 0 ≤ l i) (hl_pos : ∃ i, 0 < l i)
    (he : 0 < bEvidence T.belief l)
    (hvalid : BState.Valid (bUpdate T.belief l)) : SciTheory n where
  belief := bUpdate T.belief l
  valid := hvalid
  experiment_count := T.experiment_count + 1


theorem refinement_monotone {n : ℕ} (T : SciTheory n) (l : Fin n → ℝ)
    (hl_nn : ∀ i, 0 ≤ l i) (hl_pos : ∃ i, 0 < l i)
    (he : 0 < bEvidence T.belief l)
    (hvalid : BState.Valid (bUpdate T.belief l)) :
    T.experiment_count < (T.refine l hl_nn hl_pos he hvalid).experiment_count := by
      exact Nat.lt_succ_self _


theorem sequential_evidence {n : ℕ} (b : BState n) (l₁ l₂ : Fin n → ℝ)
    (hb : BState.Valid b) (hl₁ : ∀ i, 0 ≤ l₁ i) (hl₂ : ∀ i, 0 ≤ l₂ i)
    (he₁ : bEvidence b l₁ ≠ 0) :
    bEvidence (bUpdate b l₁) l₂ = (∑ i : Fin n, b i * l₁ i * l₂ i) / bEvidence b l₁ := by
      unfold bEvidence bUpdate; simp_all +decide [ Finset.sum_div _ _ _, mul_div_assoc ] ; ring;
      exact Finset.sum_congr rfl fun _ _ => by ring!;


structure OracleQuery (n : ℕ) where
  response : Fin n → Bool


theorem oracle_completeness {n : ℕ} (f : Fin n → Bool) :
    ∃ l : Fin n → ℝ, (∀ i, l i = 0 ∨ l i = 1) ∧
    (∀ i, f i = true ↔ l i = 1) := by
      exact ⟨ fun i => if f i then 1 else 0, fun i => by by_cases hi : f i <;> simp +decide [ hi ], fun i => by by_cases hi : f i <;> simp +decide [ hi ] ⟩


theorem deterministic_idempotent {n : ℕ} (b : BState n) (l : Fin n → ℝ)
    (hb : BState.Valid b) (hl01 : ∀ i, l i = 0 ∨ l i = 1)
    (he : bEvidence b l ≠ 0) :
    bUpdate (bUpdate b l) l = bUpdate b l := by
      unfold bUpdate bEvidence at *;
      split_ifs <;> simp_all +decide [ div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
      simp_all +decide [ ← mul_assoc, ← Finset.sum_mul ];
      exact funext fun i => by rw [ show ( ∑ i, b i * l i * l i ) = ( ∑ i, b i * l i ) by exact Finset.sum_congr rfl fun _ _ => by cases hl01 ‹_› <;> simp +decide [ * ] ] ; cases hl01 i <;> simp +decide [ * ] ;


theorem evidence_upper_bound {n : ℕ} (b : BState n) (l : Fin n → ℝ)
    (M : ℝ) (hb : BState.Valid b) (hM : ∀ i, l i ≤ M) (hl : ∀ i, 0 ≤ l i) :
    bEvidence b l ≤ M := by
      have h_evidence_le_M : bEvidence b l = ∑ i, b i * l i := by
        rfl;
      exact h_evidence_le_M ▸ le_trans ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( hM i ) ( hb.1 i ) ) ( by simp +decide [ ← Finset.sum_mul, hb.2 ] )


theorem posterior_strict_dominance {n : ℕ} (hn : 1 < n) (b : BState n)
    (l : Fin n → ℝ) (hstar : Fin n)
    (hb : BState.Valid b) (hl : ∀ i, 0 ≤ l i)
    (hpos : 0 < b hstar) (hnotpure : b hstar < 1)
    (he : 0 < bEvidence b l)
    (hdom : ∀ i, i ≠ hstar → l i < l hstar) :
    b hstar < bUpdate b l hstar := by
      -- By definition of $bUpdate$, we have $bUpdate b l hstar = (b hstar * l hstar) / bEvidence b l$.
      have h_bUpdate : bUpdate b l hstar = (b hstar * l hstar) / bEvidence b l := by
        unfold bUpdate; aesop;
      -- Since $l(i) < l(hstar)$ for all $i \neq hstar$, we have $\sum_{i \neq hstar} b(i) * l(i) < \sum_{i \neq hstar} b(i) * l(hstar)$.
      have h_sum_lt : ∑ i ∈ Finset.univ.erase hstar, b i * l i < ∑ i ∈ Finset.univ.erase hstar, b i * l hstar := by
        apply Finset.sum_lt_sum
        intro i hi
        by_cases hi_eq : i = hstar
        aesop
        generalize_proofs at *; (
        exact mul_le_mul_of_nonneg_left ( le_of_lt ( hdom i hi_eq ) ) ( hb.1 i ));
        -- Since $b$ is a valid belief state, there must be at least one $i \neq hstar$ such that $b i > 0$.
        obtain ⟨i, hi⟩ : ∃ i ≠ hstar, 0 < b i := by
          contrapose! hnotpure;
          have := hb.2; rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ hstar ) ] at this; exact le_of_not_gt fun h => by linarith [ show ∑ i ∈ Finset.univ \ { hstar }, b i ≤ 0 from Finset.sum_nonpos fun i hi => hnotpure i <| by aesop ] ;
        exact ⟨ i, Finset.mem_erase_of_ne_of_mem hi.1 ( Finset.mem_univ _ ), mul_lt_mul_of_pos_left ( hdom i hi.1 ) hi.2 ⟩;
      simp_all +decide [ Finset.sum_mul _ _ _ ];
      rw [ lt_div_iff₀ he ] ; simp_all +decide [ ← Finset.sum_mul _ _ _, bEvidence ] ; nlinarith [ hb.2 ] ;


theorem geom_series_formula (c : ℝ) (hc : c ≠ 1) (n : ℕ) :
    ∑ k ∈ Finset.range n, c ^ k = (1 - c ^ n) / (1 - c) := by
      rw [ ← neg_div_neg_eq, geom_sum_eq ] ; aesop;
      assumption


end
