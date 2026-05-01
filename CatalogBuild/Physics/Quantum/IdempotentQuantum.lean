/-! # CatalogBuild.Physics.Quantum.IdempotentQuantum

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 17
-/

import Mathlib

noncomputable section

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


/-- [Section: ## Section 2: Measurement as Tropical Projection
Quantum measurement projects the wave function onto an eigenstate.
In the tropical limit, this becomes selecting the minimum-action branch.] -/
theorem tropMeasure_achieved {n : ℕ} [NeZero n] (actions : Fin n → ℝ) :
    ∃ j, tropMeasure actions = actions j := by
  convert Finset.exists_min_image Finset.univ ( fun i => actions i ) ⟨ 0, Finset.mem_univ _ ⟩;
  norm_num [ tropMeasure ];
  exact ⟨ fun h x' => h ▸ Finset.inf'_le _ ( Finset.mem_univ _ ), fun h => le_antisymm ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ( Finset.le_inf' _ _ fun x' _ => h x' ) ⟩


/-- Soft measurement (with quantum coherence parameter ε) -/
noncomputable def softMeasure {n : ℕ} [NeZero n] (actions : Fin n → ℝ) (ε : ℝ) : ℝ :=
  -ε * Real.log (Finset.sum Finset.univ (fun j => Real.exp (-actions j / ε)))


/-- [Section: ## Section 3: Decoherence as Tropical Limit
Decoherence transforms quantum superposition into classical mixture.
In the tropical framework, this is the limit ε → 0 of the soft minimum.] -/
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


theorem softMeasure_ge_min_minus_log {n : ℕ} [NeZero n]
    (actions : Fin n → ℝ) (ε : ℝ) (hε : 0 < ε) :
    tropMeasure actions - ε * Real.log n ≤ softMeasure actions ε := by
  unfold tropMeasure softMeasure;
  -- Applying the inequality $e^{-a_j / \epsilon} \leq e^{-\inf_{k} a_k / \epsilon}$ to each term in the sum, we get:
  have h_sum_le : ∑ j, Real.exp (-actions j / ε) ≤ n * Real.exp (-Finset.univ.inf' Finset.univ_nonempty actions / ε) := by
    exact le_trans ( Finset.sum_le_sum fun _ _ => Real.exp_le_exp.mpr <| show -actions _ / ε ≤ -Finset.univ.inf' Finset.univ_nonempty actions / ε by gcongr ; aesop ) <| by norm_num;
  have := Real.log_le_log ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) h_sum_le;
  rw [ Real.log_mul ( by norm_cast; exact NeZero.ne n ) ( by positivity ), Real.log_exp ] at this ; nlinarith [ mul_div_cancel₀ ( -Finset.univ.inf' Finset.univ_nonempty actions ) hε.ne' ]


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


/-- Tropical density matrix element -/
noncomputable def tropDensity (actions : Fin n → ℝ) (i j : Fin n) : ℝ :=
  actions i + actions j


/-- Tropical density matrix is symmetric -/
theorem tropDensity_symm (actions : Fin n → ℝ) (i j : Fin n) :
    tropDensity actions i j = tropDensity actions j i := by
  unfold tropDensity; ring


/-- [Section: ## Section 5: Idempotent Density Matrix
In the tropical limit, the density matrix becomes an idempotent
min-plus matrix satisfying ρ ⊕ ρ = ρ.] -/
theorem tropTrace_eq {n : ℕ} [NeZero n] (actions : Fin n → ℝ) :
    tropTrace actions = 2 * tropMeasure actions := by
  unfold tropTrace tropMeasure;
  simp +decide [ two_mul, tropDensity ];
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
  · obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty ( fun i => actions i ) ; use i; aesop;
  · exact fun i => add_le_add ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ( Finset.inf'_le _ ( Finset.mem_univ _ ) )


/-- Classical probability from tropical action (Gibbs measure at temperature ε) -/
noncomputable def tropBornRule {n : ℕ} [NeZero n]
    (actions : Fin n → ℝ) (ε : ℝ) (k : Fin n) : ℝ :=
  Real.exp (-actions k / ε) /
  Finset.sum Finset.univ (fun j => Real.exp (-actions j / ε))


/-- [Section: ## Section 6: Born Rule in Tropical Limit
The Born rule P(k) = |⟨k|ψ⟩|² becomes the tropical projection:
in the ℏ→0 limit, P(k) → δ(k, k_min) where k_min minimizes the action.] -/
theorem tropBornRule_nonneg {n : ℕ} [NeZero n]
    (actions : Fin n → ℝ) (ε : ℝ) (hε : 0 < ε) (k : Fin n) :
    0 ≤ tropBornRule actions ε k := by
  exact div_nonneg ( Real.exp_nonneg _ ) ( Finset.sum_nonneg fun _ _ => Real.exp_nonneg _ )


theorem tropBornRule_sum_one {n : ℕ} [NeZero n]
    (actions : Fin n → ℝ) (ε : ℝ) (hε : 0 < ε) :
    Finset.sum Finset.univ (fun k => tropBornRule actions ε k) = 1 := by
  unfold tropBornRule;
  rw [ ← Finset.sum_div, div_self <| ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ]


end
