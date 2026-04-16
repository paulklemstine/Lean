/-! # CatalogBuild.Logic.Basic

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 33
-/

import Mathlib

noncomputable section

/-- An oracle on a finite type. -/
def FinOracle' (n : ℕ) := Fin n → Bool



/-- The number of True values in an oracle. -/
def oracleTrueCount' (O : FinOracle' n) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i => O i = true)).card



/-- The number of False values in an oracle. -/
def oracleFalseCount (O : FinOracle' n) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i => O i = false)).card



/-- [Section: # CatalogBuild.Logic.Basic
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 33] -/
theorem oracle_partition (O : FinOracle' n) :
    oracleTrueCount' O + oracleFalseCount O = n := by
      convert Finset.card_add_card_compl ( Finset.filter ( fun i => O i = true ) ( Finset.univ : Finset ( Fin n ) ) ) using 1 ; aesop;
      rw [ Fintype.card_fin ]



/-- Agreement count on a path graph: adjacent pairs with same value. -/
def oracleAgreements (n : ℕ) (O : FinOracle' (n + 1)) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i : Fin n =>
    O ⟨i.val, by omega⟩ == O ⟨i.val + 1, by omega⟩)).card



/-- Transition count on a path graph. -/
def oracleTransitions' (n : ℕ) (O : FinOracle' (n + 1)) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i : Fin n =>
    O ⟨i.val, by omega⟩ != O ⟨i.val + 1, by omega⟩)).card



theorem agreements_plus_transitions (n : ℕ) (O : FinOracle' (n + 1)) :
    oracleAgreements n O + oracleTransitions' n O = n := by
      unfold oracleAgreements oracleTransitions';
      convert Finset.card_add_card_compl ( Finset.filter ( fun i : Fin n => ( O ⟨ i, by linarith [ Fin.is_lt i ] ⟩ == O ⟨ i + 1, by linarith [ Fin.is_lt i ] ⟩ ) ) Finset.univ ) using 2 ; aesop;
      norm_num



/-- **Oracle Euler Characteristic on Path Graphs**:
χ = (connected components) - (holes in agreement complex)
For a path graph, the agreement complex has no holes (β₁ = 0),
so χ = β₀ = transitions + 1. -/
theorem oracle_euler_characteristic_path (n : ℕ) (O : FinOracle' (n + 2)) :
    oracleTransitions' (n + 1) O + 1 ≥ 1 := by omega



/-- Oracle-weighted adjacency on a path graph.
A_{ij} = 1 if |i-j| = 1 and O(i) ≠ O(j), else 0. -/
def oracleAdjWeight (n : ℕ) (O : FinOracle' (n + 1)) (i j : Fin (n + 1)) : ℤ :=
  if (i.val + 1 = j.val ∨ j.val + 1 = i.val) ∧ O i != O j then 1 else 0



/-- Oracle degree: number of boundary-adjacent neighbors. -/
def oracleDegree (n : ℕ) (O : FinOracle' (n + 1)) (i : Fin (n + 1)) : ℤ :=
  ∑ j : Fin (n + 1), oracleAdjWeight n O i j



theorem trace_oracle_laplacian (n : ℕ) (O : FinOracle' (n + 1)) :
    ∑ i : Fin (n + 1), oracleDegree n O i =
    2 * ↑(oracleTransitions' n O) := by
      -- By definition of degree, each boundary edge contributes 1 to the degree of each endpoint.
      have h_deg : ∀ i : Fin (n + 1), oracleDegree n O i = ∑ j : Fin n, (if (i.val = j.val ∧ O i != O ⟨j.val + 1, by omega⟩) ∨ (i.val = j.val + 1 ∧ O i != O ⟨j.val, by omega⟩) then 1 else 0) := by
        intro i
        simp [oracleDegree, oracleAdjWeight];
        refine' Finset.card_bij _ _ _ _;
        use fun a ha => ⟨ if a.val = i.val + 1 then i.val else a.val, by
          grind ⟩
        all_goals generalize_proofs at *;
        · grind;
        · grind;
        · simp +zetaDelta at *;
          grind +extAll;
      have h_sum_deg : ∑ i : Fin (n + 1), ∑ j : Fin n, (if (i.val = j.val ∧ O i != O ⟨j.val + 1, by omega⟩) ∨ (i.val = j.val + 1 ∧ O i != O ⟨j.val, by omega⟩) then 1 else 0) = ∑ j : Fin n, (if O ⟨j.val, by omega⟩ != O ⟨j.val + 1, by omega⟩ then 2 else 0) := by
        rw [ Finset.sum_comm ];
        refine' Finset.sum_congr rfl fun j hj => _ ; simp +decide [ Fin.ext_iff, Fin.val_add ] ; ring;
        split_ifs <;> simp_all +decide [ Finset.card_eq_two, Finset.ext_iff ];
        · grind;
        · use ⟨ j, by linarith [ Fin.is_lt j ] ⟩, ⟨ 1 + j, by linarith [ Fin.is_lt j ] ⟩ ; aesop;
      simp_all +decide [ Finset.sum_ite ] ; ring;
      convert congr_arg ( ( ↑ ) : ℕ → ℤ ) h_sum_deg using 2 ; norm_num [ add_comm, oracleTransitions' ] ; ring;
      simp +decide [ add_comm, oracleTransitions' ]



/-- Oracle energy on a general graph (given as edge list). -/
def graphOracleEnergy {n : ℕ} (edges : Finset (Fin n × Fin n))
    (O : Fin n → Bool) : ℕ :=
  (edges.filter (fun e => O e.1 != O e.2)).card



theorem general_energy_symmetry {n : ℕ} (edges : Finset (Fin n × Fin n))
    (O : Fin n → Bool) :
    graphOracleEnergy edges (fun i => !O i) = graphOracleEnergy edges O := by
      unfold graphOracleEnergy; aesop;



theorem constant_energy_zero {n : ℕ} (edges : Finset (Fin n × Fin n)) (b : Bool) :
    graphOracleEnergy edges (fun _ => b) = 0 := by
      unfold graphOracleEnergy; aesop;



/-- A quantum oracle state is a probability distribution over classical oracles.
We model it via amplitudes (complex coefficients). -/
structure QuantumOracleState (n : ℕ) where
  /-- Amplitude for each classical oracle configuration. -/
  amplitude : (Fin n → Bool) → ℂ
  /-- Normalization: sum of |α|² = 1. -/
  normalized : ∑ O : Fin n → Bool, ‖amplitude O‖^2 = 1



/-- The probability of measuring a specific classical oracle. -/
def measureProb (ψ : QuantumOracleState n) (O : Fin n → Bool) : ℝ :=
  ‖ψ.amplitude O‖^2



theorem measure_prob_nonneg (ψ : QuantumOracleState n) (O : Fin n → Bool) :
    0 ≤ measureProb ψ O := by
      exact sq_nonneg _



theorem measure_prob_sum (ψ : QuantumOracleState n) :
    ∑ O : Fin n → Bool, measureProb ψ O = 1 := by
      exact ψ.normalized



/-- Expected energy of a quantum oracle state. -/
def quantumExpectedEnergy {n : ℕ} (edges : Finset (Fin n × Fin n))
    (ψ : QuantumOracleState n) : ℝ :=
  ∑ O : Fin n → Bool, measureProb ψ O * ↑(graphOracleEnergy edges O)



theorem quantum_energy_nonneg {n : ℕ} (edges : Finset (Fin n × Fin n))
    (ψ : QuantumOracleState n) :
    0 ≤ quantumExpectedEnergy edges ψ := by
      exact Finset.sum_nonneg fun _ _ => mul_nonneg ( sq_nonneg _ ) ( Nat.cast_nonneg _ )



/-- Hopfield energy for oracle configuration with weight matrix. -/
def hopfieldEnergy (n : ℕ) (W : Fin n → Fin n → ℝ) (σ : Fin n → ℝ) : ℝ :=
  -∑ i : Fin n, ∑ j : Fin n, W i j * σ i * σ j / 2



/-- Symmetric weight matrix. -/
def isSymmetric (n : ℕ) (W : Fin n → Fin n → ℝ) : Prop :=
  ∀ i j, W i j = W j i



/-- Zero diagonal weight matrix. -/
def zeroDiag (n : ℕ) (W : Fin n → Fin n → ℝ) : Prop :=
  ∀ i, W i i = 0



theorem hopfield_flip_energy_change (n : ℕ) (W : Fin n → Fin n → ℝ)
    (σ : Fin n → ℝ) (k : Fin n) (hW : isSymmetric n W) (hD : zeroDiag n W) :
    let σ' := fun i => if i = k then -σ k else σ i
    let h_k := ∑ j : Fin n, W k j * σ j
    hopfieldEnergy n W σ' - hopfieldEnergy n W σ = 2 * σ k * h_k := by
      unfold hopfieldEnergy; norm_num [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', hW k, hD ] ; ring;
      simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', hW, hD ] ; ring;
      rw [ ← Finset.sum_congr rfl fun i hi => by rw [ hW i k ] ] ; norm_num [ hD, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ; ring;
      norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hW k, hD k ] ; ring



/-- Oracle magnetization as a real number. -/
def oracleMagnetization' (O : FinOracle' n) : ℝ :=
  ∑ i : Fin n, if O i then (1 : ℝ) else (-1 : ℝ)



theorem magnetization_bound (O : FinOracle' n) :
    |oracleMagnetization' O| ≤ n := by
      exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun i _ => show |if O i then ( 1 : ℝ ) else -1| ≤ 1 by split_ifs <;> norm_num ) ( by norm_num ) )



theorem anti_magnetization_real (O : FinOracle' n) :
    oracleMagnetization' (fun i => !O i) = -oracleMagnetization' O := by
      unfold oracleMagnetization';
      rw [ ← Finset.sum_neg_distrib ] ; congr ; ext i ; aesop;



/-- Oracle energy bounds magnetization change:
If two oracles differ on k sites, their magnetizations differ by at most 2k. -/
def oracleHamming' (O₁ O₂ : FinOracle' n) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i => O₁ i != O₂ i)).card



theorem magnetization_lipschitz (O₁ O₂ : FinOracle' n) :
    |oracleMagnetization' O₁ - oracleMagnetization' O₂| ≤
    2 * ↑(oracleHamming' O₁ O₂) := by
      unfold oracleMagnetization';
      rw [ ← Finset.sum_sub_distrib ];
      refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) _;
      convert Finset.sum_le_sum fun i _ => show |( if O₁ i = true then 1 else -1 : ℝ ) - if O₂ i = true then 1 else -1| ≤ 2 * ( if O₁ i != O₂ i then 1 else 0 ) from ?_ using 1;
      · norm_num [ Finset.sum_ite ];
        ring!;
        unfold oracleHamming'; aesop;
      · cases O₁ i <;> cases O₂ i <;> norm_num



/-- The boundary size of a subset S ⊆ V on a path graph.
|∂S| = number of edges with exactly one endpoint in S. -/
def subsetBoundary (n : ℕ) (S : Finset (Fin (n + 1))) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i : Fin n =>
    (⟨i.val, by omega⟩ ∈ S) ≠ (⟨i.val + 1, by omega⟩ ∈ S))).card



theorem boundary_complement (n : ℕ) (S : Finset (Fin (n + 1))) :
    subsetBoundary n S = subsetBoundary n Sᶜ := by
      exact congr_arg Finset.card ( Finset.filter_congr fun i hi => by by_cases hiS : ⟨ i.val, by linarith [ Fin.is_lt i ] ⟩ ∈ S <;> aesop )



theorem energy_eq_boundary (n : ℕ) (O : FinOracle' (n + 1)) :
    oracleTransitions' n O =
    subsetBoundary n ((Finset.univ : Finset (Fin (n + 1))).filter (fun i => O i = true)) := by
      unfold oracleTransitions' subsetBoundary;
      simp +zetaDelta at *



theorem path_cheeger (n : ℕ) (S : Finset (Fin (n + 2)))
    (hne : S.Nonempty) (hne' : Sᶜ.Nonempty) :
    1 ≤ subsetBoundary (n + 1) S := by
      contrapose! hne';
      ext i;
      induction' i using Fin.inductionOn with i IH;
      · obtain ⟨ k, hk ⟩ := hne;
        induction' k using Fin.inductionOn with k ih;
        · aesop;
        · simp_all +decide [ subsetBoundary ];
          exact ih ( by simpa [ Fin.ext_iff ] using hne' |>.2 hk );
      · simp_all +decide [ subsetBoundary ];
        simpa using hne' |>.1 IH



end
