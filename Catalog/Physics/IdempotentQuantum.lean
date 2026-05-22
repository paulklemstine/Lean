/-
  IdempotentQuantum.lean

  Future Direction 6.5: Idempotent Quantum Computing

  Wave collapse (Lemma 3.3 of Lohmiller-Slotine) as tropical projection
  suggests an idempotent quantum computing paradigm where measurement is
  modeled as the tropical limit of quantum superposition. This connects
  quantum decoherence to idempotent analysis.
-/
import Mathlib

open Real

namespace IdempotentQuantum

/-! ## Section 1: Idempotent Semiring Structure

The tropical semiring (ℝ ∪ {+∞}, min, +) is idempotent: min(a,a) = a.
This models wave collapse: measuring a state projects it idempotently. -/

/-- Tropical addition (min) -/
noncomputable def tropAdd (a b : ℝ) : ℝ := min a b

/-- Tropical multiplication (ordinary addition) -/
def tropMul (a b : ℝ) : ℝ := a + b

/-- Tropical addition is idempotent -/
theorem tropAdd_idem (a : ℝ) : tropAdd a a = a := by
  simp [tropAdd]

/-- Tropical addition is commutative -/
theorem tropAdd_comm (a b : ℝ) : tropAdd a b = tropAdd b a := by
  simp [tropAdd, min_comm]

/-- Tropical addition is associative -/
theorem tropAdd_assoc (a b c : ℝ) :
    tropAdd (tropAdd a b) c = tropAdd a (tropAdd b c) := by
  simp [tropAdd, min_assoc]

/-- Tropical multiplication is commutative -/
theorem tropMul_comm (a b : ℝ) : tropMul a b = tropMul b a := by
  unfold tropMul; ring

/-- Tropical multiplication is associative -/
theorem tropMul_assoc (a b c : ℝ) :
    tropMul (tropMul a b) c = tropMul a (tropMul b c) := by
  unfold tropMul; ring

/-- Tropical multiplication distributes over tropical addition -/
theorem tropMul_distrib_left (a b c : ℝ) :
    tropMul a (tropAdd b c) = tropAdd (tropMul a b) (tropMul a c) := by
  simp [tropMul, tropAdd, min_add_add_left]

/-- Identity for tropical multiplication -/
theorem tropMul_zero (a : ℝ) : tropMul a 0 = a := by
  unfold tropMul; ring

/-! ## Section 2: Measurement as Tropical Projection

Quantum measurement projects the wave function onto an eigenstate.
In the tropical limit, this becomes selecting the minimum-action branch. -/

/-- Tropical projection operator -/
noncomputable def tropProject {n : ℕ} [NeZero n] (actions : Fin n → ℝ) : Fin n → ℝ :=
  fun j => if actions j = Finset.inf' Finset.univ Finset.univ_nonempty actions
            then actions j else 0  -- projects onto minimum-action branch

/-- Tropical measurement selects minimum action -/
noncomputable def tropMeasure {n : ℕ} [NeZero n] (actions : Fin n → ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty actions

/-- Measurement is idempotent -/
theorem tropMeasure_idem {n : ℕ} [NeZero n] (actions : Fin n → ℝ) :
    tropMeasure (fun (_ : Fin 1) => tropMeasure actions) = tropMeasure actions := by
  simp [tropMeasure]

/-
Measurement selects a value from the original set
-/
theorem tropMeasure_achieved {n : ℕ} [NeZero n] (actions : Fin n → ℝ) :
    ∃ j, tropMeasure actions = actions j := by
  convert Finset.exists_min_image Finset.univ ( fun i => actions i ) ⟨ 0, Finset.mem_univ _ ⟩;
  norm_num [ tropMeasure ];
  exact ⟨ fun h x' => h ▸ Finset.inf'_le _ ( Finset.mem_univ _ ), fun h => le_antisymm ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ( Finset.le_inf' _ _ fun x' _ => h x' ) ⟩

/-! ## Section 3: Decoherence as Tropical Limit

Decoherence transforms quantum superposition into classical mixture.
In the tropical framework, this is the limit ε → 0 of the soft minimum. -/

/-- Soft measurement (with quantum coherence parameter ε) -/
noncomputable def softMeasure {n : ℕ} [NeZero n] (actions : Fin n → ℝ) (ε : ℝ) : ℝ :=
  -ε * Real.log (Finset.sum Finset.univ (fun j => Real.exp (-actions j / ε)))

/-
Soft measurement lower bound
-/
theorem softMeasure_le_min {n : ℕ} [NeZero n]
    (actions : Fin n → ℝ) (ε : ℝ) (hε : 0 < ε) :
    softMeasure actions ε ≤ tropMeasure actions := by
  unfold softMeasure tropMeasure;
  -- Rewrite the inequality in terms of the exponential function.
  suffices h_exp : Real.exp (-Finset.univ.inf' (by
  exact ⟨ ⟨ 0, NeZero.pos n ⟩, Finset.mem_univ _ ⟩) actions / ε) ≤ ∑ j, Real.exp (-actions j / ε) by
    all_goals generalize_proofs at *;
    nlinarith [ Real.log_exp ( -Finset.univ.inf' ‹_› actions / ε ), Real.log_le_log ( by positivity ) h_exp, mul_div_cancel₀ ( -Finset.univ.inf' ‹_› actions ) hε.ne' ]
  generalize_proofs at *;
  obtain ⟨ j, hj ⟩ := Finset.exists_min_image Finset.univ ( fun j => actions j ) ( Finset.univ_nonempty ) ; exact le_trans ( by gcongr ; aesop ) ( Finset.single_le_sum ( fun i _ => Real.exp_nonneg ( -actions i / ε ) ) ( Finset.mem_univ j ) ) ;

/-
Soft measurement upper bound
-/
theorem softMeasure_ge_min_minus_log {n : ℕ} [NeZero n]
    (actions : Fin n → ℝ) (ε : ℝ) (hε : 0 < ε) :
    tropMeasure actions - ε * Real.log n ≤ softMeasure actions ε := by
  unfold tropMeasure softMeasure;
  -- Applying the inequality $e^{-a_j / \epsilon} \leq e^{-\inf_{k} a_k / \epsilon}$ to each term in the sum, we get:
  have h_sum_le : ∑ j, Real.exp (-actions j / ε) ≤ n * Real.exp (-Finset.univ.inf' Finset.univ_nonempty actions / ε) := by
    exact le_trans ( Finset.sum_le_sum fun _ _ => Real.exp_le_exp.mpr <| show -actions _ / ε ≤ -Finset.univ.inf' Finset.univ_nonempty actions / ε by gcongr ; aesop ) <| by norm_num;
  have := Real.log_le_log ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) h_sum_le;
  rw [ Real.log_mul ( by norm_cast; exact NeZero.ne n ) ( by positivity ), Real.log_exp ] at this ; nlinarith [ mul_div_cancel₀ ( -Finset.univ.inf' Finset.univ_nonempty actions ) hε.ne' ]

/-! ## Section 4: Idempotent Quantum Gates

Quantum gates in the tropical limit become min-plus linear maps.
A tropical gate T acts on action vectors by: (Tv)_i = min_j (T_ij + v_j). -/

/-- Tropical gate action on a single qubit -/
noncomputable def tropGate (T₀₀ T₀₁ T₁₀ T₁₁ : ℝ) (v₀ v₁ : ℝ) : ℝ × ℝ :=
  (min (T₀₀ + v₀) (T₀₁ + v₁), min (T₁₀ + v₀) (T₁₁ + v₁))

/-- Tropical identity gate uses 0 on diagonal and +∞ (large M) off-diagonal.
    For any M > |v₀| + |v₁|, tropGate 0 M M 0 v₀ v₁ = (v₀, v₁). -/
theorem trop_identity_gate (v₀ v₁ M : ℝ)
    (hM0 : v₀ ≤ M + v₁) (hM1 : v₁ ≤ M + v₀) :
    tropGate 0 M M 0 v₀ v₁ = (v₀, v₁) := by
  unfold tropGate
  simp only [zero_add, Prod.mk.injEq]
  exact ⟨min_eq_left (by linarith), min_eq_right (by linarith)⟩

/-- Tropical NOT gate (swap) -/
noncomputable def tropNOT (v₀ v₁ : ℝ) : ℝ × ℝ := (v₁, v₀)

/-- Tropical NOT is an involution -/
theorem tropNOT_involution (v₀ v₁ : ℝ) :
    tropNOT (tropNOT v₀ v₁).1 (tropNOT v₀ v₁).2 = (v₀, v₁) := by
  simp [tropNOT]

/-! ## Section 5: Idempotent Density Matrix

In the tropical limit, the density matrix becomes an idempotent
min-plus matrix satisfying ρ ⊕ ρ = ρ. -/

/-- Tropical density matrix element -/
noncomputable def tropDensity (actions : Fin n → ℝ) (i j : Fin n) : ℝ :=
  actions i + actions j

/-- Tropical density matrix is symmetric -/
theorem tropDensity_symm (actions : Fin n → ℝ) (i j : Fin n) :
    tropDensity actions i j = tropDensity actions j i := by
  unfold tropDensity; ring

/-- Tropical trace (minimum diagonal element) -/
noncomputable def tropTrace {n : ℕ} [NeZero n] (actions : Fin n → ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty (fun i => tropDensity actions i i)

/-
Tropical trace equals twice the minimum action
-/
theorem tropTrace_eq {n : ℕ} [NeZero n] (actions : Fin n → ℝ) :
    tropTrace actions = 2 * tropMeasure actions := by
  unfold tropTrace tropMeasure;
  simp +decide [ two_mul, tropDensity ];
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
  · obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty ( fun i => actions i ) ; use i; aesop;
  · exact fun i => add_le_add ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ( Finset.inf'_le _ ( Finset.mem_univ _ ) )

/-! ## Section 6: Born Rule in Tropical Limit

The Born rule P(k) = |⟨k|ψ⟩|² becomes the tropical projection:
in the ℏ→0 limit, P(k) → δ(k, k_min) where k_min minimizes the action. -/

/-- Classical probability from tropical action (Gibbs measure at temperature ε) -/
noncomputable def tropBornRule {n : ℕ} [NeZero n]
    (actions : Fin n → ℝ) (ε : ℝ) (k : Fin n) : ℝ :=
  Real.exp (-actions k / ε) /
  Finset.sum Finset.univ (fun j => Real.exp (-actions j / ε))

/-
Tropical Born rule gives non-negative probabilities
-/
theorem tropBornRule_nonneg {n : ℕ} [NeZero n]
    (actions : Fin n → ℝ) (ε : ℝ) (hε : 0 < ε) (k : Fin n) :
    0 ≤ tropBornRule actions ε k := by
  exact div_nonneg ( Real.exp_nonneg _ ) ( Finset.sum_nonneg fun _ _ => Real.exp_nonneg _ )

/-
Tropical Born rule probabilities sum to 1
-/
theorem tropBornRule_sum_one {n : ℕ} [NeZero n]
    (actions : Fin n → ℝ) (ε : ℝ) (hε : 0 < ε) :
    Finset.sum Finset.univ (fun k => tropBornRule actions ε k) = 1 := by
  unfold tropBornRule;
  rw [ ← Finset.sum_div, div_self <| ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ]

end IdempotentQuantum