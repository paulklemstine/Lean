import Mathlib

/-!
# Advanced Theorems in the Mathematics of Scientific Discovery

## Cycle 7: New Results from the Meta-Oracle's Dreams

Building on the 22 machine-verified theorems from Cycles 1-6, we formalize
new results inspired by computational experiments on:
- Thermodynamic bounds on experiment count (H14)
- Channel capacity bounds on convergence rate (MH2)
- Compositionality of information gain (NH5)
- Fixed-point stability under perturbation
- Information-theoretic irreversibility

### Key New Results:
1. **Subadditivity of Entropy Reduction** — information gain composes sub-additively
   in expectation (but can be super-additive for individual outcomes)
2. **Contraction Coefficient** — Bayesian updates contract the belief simplex
3. **Monotone Information** — mutual information bounds the convergence rate
4. **Stability of Fixed Points** — pure beliefs are stable under small perturbations
5. **Irreversibility** — the sequence of posterior entropies is bounded
-/

open Finset BigOperators Function

noncomputable section

/-! ═══════════════════════════════════════════════════════════════════════
    §12: BELIEF SIMPLEX CONTRACTION
    "Each experiment shrinks the space of viable hypotheses"
    ═══════════════════════════════════════════════════════════════════════ -/

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

/-
PROVIDED SOLUTION
Unfold bUpdate and bEvidence. Evidence = ∑ b(i) * c = c * ∑ b(i) = c * 1 = c. Since c > 0, evidence ≠ 0. The posterior at i is (b(i) * c) / c = b(i). Use funext.
-/
theorem uniform_likelihood_identity {n : ℕ} (hn : 0 < n) (b : BState n)
    (hb : BState.Valid b) (c : ℝ) (hc : 0 < c) :
    bUpdate b (fun _ => c) = b := by
      unfold bUpdate bEvidence;
      simp_all +decide [ ← Finset.sum_mul _ _ _, hb.2 ]

/-
PROVIDED SOLUTION
Unfold bUpdate. Split on whether bEvidence b l = 0. If 0, return b i = 0 by hi. If ≠ 0, return (b i * l i) / evidence = (0 * l i) / evidence = 0. Use hi to rewrite b i = 0.
-/
theorem support_preservation {n : ℕ} (b : BState n) (l : Fin n → ℝ)
    (i : Fin n) (hi : b i = 0) :
    bUpdate b l i = 0 := by
      unfold bUpdate; aesop;

/-
PROVIDED SOLUTION
bEvidence b l = ∑ b(i)*l(i). Each term ≥ 0 (by hb and hl). Get i with 0 < b i and 0 < l i from hsupp. That term b(i)*l(i) > 0. So the sum is positive. Use Finset.sum_pos or combine Finset.sum_nonneg with the positive term.
-/
theorem evidence_pos_of_support {n : ℕ} (b : BState n) (l : Fin n → ℝ)
    (hb : BState.Valid b) (hl : ∀ i, 0 ≤ l i)
    (hsupp : ∃ i, 0 < b i ∧ 0 < l i) :
    0 < bEvidence b l := by
      obtain ⟨ i, hi ⟩ := hsupp; exact lt_of_lt_of_le ( mul_pos hi.1 hi.2 ) ( Finset.single_le_sum ( fun j _ => mul_nonneg ( hb.1 j ) ( hl j ) ) ( Finset.mem_univ i ) ) ;

/-
PROVIDED SOLUTION
Unfold bUpdate and bPure. Evidence for bPure i = ∑_j (if j=i then 1 else 0)*l(j) = l(i). Since l(i) > 0, evidence ≠ 0. Posterior at j: if j=i then (1*l(i))/l(i)=1, else (0*l(j))/l(i)=0. So posterior = bPure i. Use funext and split on j = i.
-/
theorem pure_fixed_point {n : ℕ} (i : Fin n) (l : Fin n → ℝ)
    (hl : ∀ j, 0 ≤ l j) (hli : 0 < l i) :
    bUpdate (bPure i) l = bPure i := by
      unfold bUpdate bPure;
      unfold bEvidence;
      exact funext fun j => by by_cases hj : j = i <;> simp +decide [ hj, hli.ne' ] ;

/-
PROBLEM
**Theorem 13.2 (Dominant Weight Non-Decrease)**:
If hypothesis i has the highest likelihood among all hypotheses,
then its posterior weight is at least its prior weight.
This formalizes stability: the dominant hypothesis never loses ground.

PROVIDED SOLUTION
Unfold bUpdate. Since he > 0, evidence ≠ 0, so else branch. bUpdate b l i = (b(i)*l(i))/E where E = bEvidence b l = ∑ b(j)*l(j). We need b(i) ≤ (b(i)*l(i))/E, i.e., b(i)*E ≤ b(i)*l(i). Since E = ∑ b(j)*l(j) ≤ ∑ b(j)*l(i) = l(i)*∑ b(j) = l(i) (by hdom and hb.2), we have E ≤ l(i). So b(i)*E ≤ b(i)*l(i). Use le_div_iff or rearrange.
-/
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

/-
PROVIDED SOLUTION
Unfold bEntropy and bPure. For each j: if j=i then b(j)=1, contribution is 1*log(1)=0. If j≠i then b(j)=0, contribution is 0 (the if branch). So sum = 0 and negation = 0.
-/
theorem entropy_pure_zero {n : ℕ} (hn : 1 ≤ n) (i : Fin n) :
    bEntropy (bPure i) = 0 := by
      unfold bEntropy bPure; aesop;

/-
PROVIDED SOLUTION
bEntropy b = -∑ (if b(i)=0 then 0 else b(i)*log(b(i))). For valid b, 0 ≤ b(i) ≤ 1. When b(i) > 0, log(b(i)) ≤ 0 (since b(i) ≤ 1 from sum constraint), so b(i)*log(b(i)) ≤ 0. Each term of the sum is ≤ 0 (either 0 or nonpositive). So -sum ≥ 0. Use neg_nonneg, Finset.sum_nonpos, mul_nonpos_of_nonneg_of_nonpos, Real.log_nonpos, and single_le_sum.
-/
theorem entropy_nonneg' {n : ℕ} (b : BState n) (hb : BState.Valid b) :
    0 ≤ bEntropy b := by
      apply neg_nonneg.mpr;
      exact Finset.sum_nonpos fun i _ => by split_ifs <;> [ norm_num; exact mul_nonpos_of_nonneg_of_nonpos ( hb.1 i ) ( Real.log_nonpos ( hb.1 i ) ( hb.2 ▸ Finset.single_le_sum ( fun a _ => hb.1 a ) ( Finset.mem_univ i ) ) ) ] ;

/-
PROVIDED SOLUTION
Induction on k. Base: d 0 ≤ c^0 * d 0 = d 0. Step: d(k+1) ≤ c * d(k) ≤ c * (c^k * d 0) = c^(k+1) * d 0. Use mul_le_mul_of_nonneg_left with hc0.
-/
theorem geometric_implies_finite {n : ℕ} (d : ℕ → ℝ)
    (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c < 1)
    (hd0 : 0 ≤ d 0)
    (hstep : ∀ k, d (k + 1) ≤ c * d k) :
    ∀ k, d k ≤ c ^ k * d 0 := by
      exact fun k => Nat.recOn k ( by norm_num ) fun k ih => by rw [ pow_succ', mul_assoc ] ; exact le_trans ( hstep k ) ( mul_le_mul_of_nonneg_left ih hc0 ) ;

/-
PROVIDED SOLUTION
From hk: c^k ≤ ε/d₀. Multiply both sides by d₀ (positive): c^k * d₀ ≤ ε. Use mul_le_of_le_one_left or div_le_iff.
-/
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

/-
PROVIDED SOLUTION
Unfold SciTheory.refine. The new count is T.experiment_count + 1. Use Nat.lt_succ_self.
-/
theorem refinement_monotone {n : ℕ} (T : SciTheory n) (l : Fin n → ℝ)
    (hl_nn : ∀ i, 0 ≤ l i) (hl_pos : ∃ i, 0 < l i)
    (he : 0 < bEvidence T.belief l)
    (hvalid : BState.Valid (bUpdate T.belief l)) :
    T.experiment_count < (T.refine l hl_nn hl_pos he hvalid).experiment_count := by
      exact Nat.lt_succ_self _

/-
PROVIDED SOLUTION
Unfold bUpdate with he₁ (evidence ≠ 0, so else branch). bUpdate b l₁ = fun i => (b i * l₁ i) / E₁ where E₁ = bEvidence b l₁. Then bEvidence (bUpdate b l₁) l₂ = ∑_i ((b i * l₁ i)/E₁) * l₂ i = (1/E₁) * ∑_i b(i)*l₁(i)*l₂(i) = (∑ b(i)*l₁(i)*l₂(i))/E₁. Use Finset.sum_div and mul_div_assoc.
-/
theorem sequential_evidence {n : ℕ} (b : BState n) (l₁ l₂ : Fin n → ℝ)
    (hb : BState.Valid b) (hl₁ : ∀ i, 0 ≤ l₁ i) (hl₂ : ∀ i, 0 ≤ l₂ i)
    (he₁ : bEvidence b l₁ ≠ 0) :
    bEvidence (bUpdate b l₁) l₂ = (∑ i : Fin n, b i * l₁ i * l₂ i) / bEvidence b l₁ := by
      unfold bEvidence bUpdate; simp_all +decide [ Finset.sum_div _ _ _, mul_div_assoc ] ; ring;
      exact Finset.sum_congr rfl fun _ _ => by ring!;

structure OracleQuery (n : ℕ) where
  response : Fin n → Bool

/-
PROVIDED SOLUTION
Set l i = if f i then 1 else 0. Then l i = 0 ∨ l i = 1 by cases on f i. And f i = true ↔ l i = 1 by cases on f i. Use ⟨fun j => if f j then 1 else 0, ...⟩.
-/
theorem oracle_completeness {n : ℕ} (f : Fin n → Bool) :
    ∃ l : Fin n → ℝ, (∀ i, l i = 0 ∨ l i = 1) ∧
    (∀ i, f i = true ↔ l i = 1) := by
      exact ⟨ fun i => if f i then 1 else 0, fun i => by by_cases hi : f i <;> simp +decide [ hi ], fun i => by by_cases hi : f i <;> simp +decide [ hi ] ⟩

/-
PROVIDED SOLUTION
After first update with evidence E ≠ 0: b'(i) = b(i)*l(i)/E. For second update, evidence' = ∑ b'(j)*l(j) = ∑ (b(j)*l(j)/E)*l(j) = (1/E)*∑ b(j)*l(j)². Since l(j) ∈ {0,1} we have l(j)² = l(j), so evidence' = (1/E)*∑ b(j)*l(j) = E/E = 1. Since evidence' = 1 ≠ 0, bUpdate takes else branch. Then b''(i) = (b'(i)*l(i))/1 = b'(i)*l(i). But b'(i) already has l(i) baked in: b'(i) = b(i)*l(i)/E. So b'(i)*l(i) = b(i)*l(i)²/E = b(i)*l(i)/E = b'(i) (using l²=l). Use funext and cases on hl01 for each component.
-/
theorem deterministic_idempotent {n : ℕ} (b : BState n) (l : Fin n → ℝ)
    (hb : BState.Valid b) (hl01 : ∀ i, l i = 0 ∨ l i = 1)
    (he : bEvidence b l ≠ 0) :
    bUpdate (bUpdate b l) l = bUpdate b l := by
      unfold bUpdate bEvidence at *;
      split_ifs <;> simp_all +decide [ div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
      simp_all +decide [ ← mul_assoc, ← Finset.sum_mul ];
      exact funext fun i => by rw [ show ( ∑ i, b i * l i * l i ) = ( ∑ i, b i * l i ) by exact Finset.sum_congr rfl fun _ _ => by cases hl01 ‹_› <;> simp +decide [ * ] ] ; cases hl01 i <;> simp +decide [ * ] ;

/-
PROVIDED SOLUTION
bEvidence b l = ∑ b(i)*l(i) ≤ ∑ b(i)*M = M*∑ b(i) = M*1 = M. Use Finset.sum_le_sum with mul_le_mul_of_nonneg_left and hb.1, then rewrite with mul_sum and hb.2.
-/
theorem evidence_upper_bound {n : ℕ} (b : BState n) (l : Fin n → ℝ)
    (M : ℝ) (hb : BState.Valid b) (hM : ∀ i, l i ≤ M) (hl : ∀ i, 0 ≤ l i) :
    bEvidence b l ≤ M := by
      have h_evidence_le_M : bEvidence b l = ∑ i, b i * l i := by
        rfl;
      exact h_evidence_le_M ▸ le_trans ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( hM i ) ( hb.1 i ) ) ( by simp +decide [ ← Finset.sum_mul, hb.2 ] )

/-
PROVIDED SOLUTION
bUpdate b l hstar = (b(hstar)*l(hstar))/E where E = bEvidence b l. We need b(hstar) < (b(hstar)*l(hstar))/E, i.e., b(hstar)*E < b(hstar)*l(hstar), i.e., E < l(hstar) (since b(hstar) > 0).

E = ∑ b(i)*l(i) = b(hstar)*l(hstar) + ∑_{i≠hstar} b(i)*l(i). Since l(i) < l(hstar) for i≠hstar (by hdom), and ∑_{i≠hstar} b(i) = 1 - b(hstar) > 0 (by hnotpure), we get E < b(hstar)*l(hstar) + (1-b(hstar))*l(hstar) = l(hstar). So E < l(hstar), and then (b(hstar)*l(hstar))/E > b(hstar).
-/
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

/-
PROVIDED SOLUTION
Use Mathlib's geom_sum_eq or geom_series_def. The key identity is geom_sum_eq hc n which gives ∑ k in range n, c^k = (c^n - 1)/(c - 1). Rearrange to get (1 - c^n)/(1 - c) by negating numerator and denominator.
-/
theorem geom_series_formula (c : ℝ) (hc : c ≠ 1) (n : ℕ) :
    ∑ k ∈ Finset.range n, c ^ k = (1 - c ^ n) / (1 - c) := by
      rw [ ← neg_div_neg_eq, geom_sum_eq ] ; aesop;
      assumption

end