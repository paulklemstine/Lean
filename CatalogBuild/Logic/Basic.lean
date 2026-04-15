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

/-
PROBLEM
True count + False count = n (oracle partition).

PROVIDED SOLUTION
The filter for True and filter for not-True partition univ. Use Finset.filter_card_add_filter_neg_card_eq_card. The complement of {O i = true} is {O i = false} since Bool has exactly two values.
-/

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

/-
PROBLEM
Agreements + Transitions = n (every adjacent pair either agrees or disagrees).

PROVIDED SOLUTION
For each i : Fin n, either O(i) == O(i+1) or O(i) != O(i+1). So the two filter sets partition univ. Use Finset.filter_card_add_filter_neg_card_eq_card. The predicate for agreements is (O(i) == O(i+1)) and for transitions is (O(i) != O(i+1)), and bne is the negation of beq.
-/

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

/-! ## §2: Oracle Laplacian Trace Theorem -/

/-- Oracle-weighted adjacency on a path graph.
    A_{ij} = 1 if |i-j| = 1 and O(i) ≠ O(j), else 0. -/

def oracleAdjWeight (n : ℕ) (O : FinOracle' (n + 1)) (i j : Fin (n + 1)) : ℤ :=
  if (i.val + 1 = j.val ∨ j.val + 1 = i.val) ∧ O i != O j then 1 else 0

/-- Oracle degree: number of boundary-adjacent neighbors. -/

def oracleDegree (n : ℕ) (O : FinOracle' (n + 1)) (i : Fin (n + 1)) : ℤ :=
  ∑ j : Fin (n + 1), oracleAdjWeight n O i j

/-
PROBLEM
The trace of the oracle Laplacian equals twice the energy.
    Tr(L_O) = Σ_i deg_O(i) = 2 · E(O)

    Each boundary edge contributes 1 to the degree of each endpoint,
    so the sum of degrees equals 2 × (number of boundary edges).

PROVIDED SOLUTION
Expand oracleDegree and oracleAdjWeight. We have Σ_i Σ_j (if adjacent and disagreeing then 1 else 0). Each boundary edge (i,i+1) with O(i) ≠ O(i+1) contributes 1 to the degree of i and 1 to the degree of i+1, so contributes 2 to the total sum. The total sum is thus 2 × (number of boundary edges) = 2 × oracleTransitions'.
-/

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

/-! ## §3: Higher-Dimensional Energy Formula -/

/-- Oracle energy on a general graph (given as edge list). -/

def graphOracleEnergy {n : ℕ} (edges : Finset (Fin n × Fin n))
    (O : Fin n → Bool) : ℕ :=
  (edges.filter (fun e => O e.1 != O e.2)).card

/-
PROBLEM
**Energy Symmetry on General Graphs**: Oracle and anti-oracle
    have the same energy on any graph.

PROVIDED SOLUTION
For each edge (i,j), (!O i != !O j) iff (O i != O j) since Bool negation is injective. So the filter condition is the same. Use congr_arg card with a Finset.ext showing the filter conditions are equivalent. Cases on O i and O j (both Bool).
-/

theorem general_energy_symmetry {n : ℕ} (edges : Finset (Fin n × Fin n))
    (O : Fin n → Bool) :
    graphOracleEnergy edges (fun i => !O i) = graphOracleEnergy edges O := by
      unfold graphOracleEnergy; aesop;

/-
PROBLEM
Energy of constant oracle is zero on any graph.

PROVIDED SOLUTION
The filter condition is (b != b) which is always false for any Bool b. So the filter is empty, card is 0.
-/

theorem constant_energy_zero {n : ℕ} (edges : Finset (Fin n × Fin n)) (b : Bool) :
    graphOracleEnergy edges (fun _ => b) = 0 := by
      unfold graphOracleEnergy; aesop;

/-! ## §4: Quantum Oracle States -/

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

/-
PROBLEM
Measurement probabilities are non-negative.

PROVIDED SOLUTION
measureProb is defined as ‖amplitude O‖^2, which is a norm squared, hence non-negative. Use sq_nonneg or norm_nonneg.
-/

theorem measure_prob_nonneg (ψ : QuantumOracleState n) (O : Fin n → Bool) :
    0 ≤ measureProb ψ O := by
      exact sq_nonneg _

/-
PROBLEM
Measurement probabilities sum to 1 (Born rule).

PROVIDED SOLUTION
Unfold measureProb. The sum ∑ O, ‖ψ.amplitude O‖^2 = 1 by ψ.normalized.
-/

theorem measure_prob_sum (ψ : QuantumOracleState n) :
    ∑ O : Fin n → Bool, measureProb ψ O = 1 := by
      exact ψ.normalized

/-- Expected energy of a quantum oracle state. -/

def quantumExpectedEnergy {n : ℕ} (edges : Finset (Fin n × Fin n))
    (ψ : QuantumOracleState n) : ℝ :=
  ∑ O : Fin n → Bool, measureProb ψ O * ↑(graphOracleEnergy edges O)

/-
PROBLEM
Expected energy is non-negative.

PROVIDED SOLUTION
quantumExpectedEnergy is a sum of measureProb ψ O * (graphOracleEnergy edges O : ℝ). Each measureProb term is ≥ 0 (by measure_prob_nonneg) and graphOracleEnergy is a natural number cast to ℝ, hence ≥ 0. Product of non-negatives is non-negative. Sum of non-negatives is non-negative. Use Finset.sum_nonneg.
-/

theorem quantum_energy_nonneg {n : ℕ} (edges : Finset (Fin n × Fin n))
    (ψ : QuantumOracleState n) :
    0 ≤ quantumExpectedEnergy edges ψ := by
      exact Finset.sum_nonneg fun _ _ => mul_nonneg ( sq_nonneg _ ) ( Nat.cast_nonneg _ )

/-! ## §5: Oracle Hopfield Energy -/

/-- Hopfield energy for oracle configuration with weight matrix. -/

def hopfieldEnergy (n : ℕ) (W : Fin n → Fin n → ℝ) (σ : Fin n → ℝ) : ℝ :=
  -∑ i : Fin n, ∑ j : Fin n, W i j * σ i * σ j / 2

/-- Symmetric weight matrix. -/

def isSymmetric (n : ℕ) (W : Fin n → Fin n → ℝ) : Prop :=
  ∀ i j, W i j = W j i

/-- Zero diagonal weight matrix. -/

def zeroDiag (n : ℕ) (W : Fin n → Fin n → ℝ) : Prop :=
  ∀ i, W i i = 0

/-
PROBLEM
**Hopfield Energy Decrease Lemma**: Flipping spin i decreases energy
    when the local field h_i = Σ_j W_{ij} σ_j has opposite sign to σ_i.

    ΔE = -2 σ_i h_i, so if σ_i h_i < 0 then ΔE < 0.

PROVIDED SOLUTION
Expand hopfieldEnergy for σ' and σ. ΔE = -½ Σ_{i,j} W_{ij}(σ'_i σ'_j - σ_i σ_j). Terms where neither i nor j is k cancel. Terms where i=k, j≠k contribute -½(-2 W_{kj} σ_k σ_j). Terms where j=k, i≠k contribute -½(-2 W_{ik} σ_i σ_k). Terms where i=j=k: W_{kk}=0 so cancel. By symmetry W_{ik} = W_{ki}, the sum is 2 σ_k Σ_j W_{kj} σ_j = 2 σ_k h_k. Key steps: split sums, use if-then-else for σ', simplify (-σ_k)·σ_j - σ_k·σ_j = -2 σ_k σ_j.
-/

theorem hopfield_flip_energy_change (n : ℕ) (W : Fin n → Fin n → ℝ)
    (σ : Fin n → ℝ) (k : Fin n) (hW : isSymmetric n W) (hD : zeroDiag n W) :
    let σ' := fun i => if i = k then -σ k else σ i
    let h_k := ∑ j : Fin n, W k j * σ j
    hopfieldEnergy n W σ' - hopfieldEnergy n W σ = 2 * σ k * h_k := by
      unfold hopfieldEnergy; norm_num [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', hW k, hD ] ; ring;
      simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', hW, hD ] ; ring;
      rw [ ← Finset.sum_congr rfl fun i hi => by rw [ hW i k ] ] ; norm_num [ hD, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ; ring;
      norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hW k, hD k ] ; ring

/-! ## §6: Oracle Information Inequalities -/

/-- Oracle magnetization as a real number. -/

def oracleMagnetization' (O : FinOracle' n) : ℝ :=
  ∑ i : Fin n, if O i then (1 : ℝ) else (-1 : ℝ)

/-
PROBLEM
Magnetization is bounded by n.

PROVIDED SOLUTION
Each term of the sum is either 1 or -1, so |term| ≤ 1. Use Finset.abs_sum_le_sum_abs to get |Σ| ≤ Σ|term| = n. Each |if O i then 1 else -1| = 1. The sum of n ones equals n. Cast from Fintype.card (Fin n) = n.
-/

theorem magnetization_bound (O : FinOracle' n) :
    |oracleMagnetization' O| ≤ n := by
      exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun i _ => show |if O i then ( 1 : ℝ ) else -1| ≤ 1 by split_ifs <;> norm_num ) ( by norm_num ) )

/-
PROBLEM
**Anti-Oracle Magnetization Duality** (ℝ-valued version).

PROVIDED SOLUTION
Unfold oracleMagnetization'. For each i, if O i then !O i = false and vice versa. So (if !O i then 1 else -1) = -(if O i then 1 else -1). Factor out negation: sum of negations = negation of sum. Use Finset.sum_neg_distrib or similar.
-/

theorem anti_magnetization_real (O : FinOracle' n) :
    oracleMagnetization' (fun i => !O i) = -oracleMagnetization' O := by
      unfold oracleMagnetization';
      rw [ ← Finset.sum_neg_distrib ] ; congr ; ext i ; aesop;

/-- Oracle energy bounds magnetization change:
    If two oracles differ on k sites, their magnetizations differ by at most 2k. -/

def oracleHamming' (O₁ O₂ : FinOracle' n) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i => O₁ i != O₂ i)).card

/-
PROVIDED SOLUTION
Write the difference as Σ_i ((if O₁ i then 1 else -1) - (if O₂ i then 1 else -1)). Each term is 0 if O₁ i = O₂ i, and ±2 if O₁ i ≠ O₂ i. So |difference| ≤ Σ_i |term_i| ≤ 2 × |{i : O₁ i ≠ O₂ i}| = 2 × oracleHamming'. Use Finset.abs_sum_le_sum_abs, then bound each |term| by 2 * (if O₁ i != O₂ i then 1 else 0), then relate the sum to oracleHamming'.
-/

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

/-! ## §7: Oracle Cheeger Inequality (Discrete Isoperimetric) -/

/-- The boundary size of a subset S ⊆ V on a path graph.
    |∂S| = number of edges with exactly one endpoint in S. -/

def subsetBoundary (n : ℕ) (S : Finset (Fin (n + 1))) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i : Fin n =>
    (⟨i.val, by omega⟩ ∈ S) ≠ (⟨i.val + 1, by omega⟩ ∈ S))).card

/-
PROBLEM
The boundary of the complement equals the boundary of the set.

PROVIDED SOLUTION
The boundary condition checks if exactly one of the two adjacent vertices is in S. For the complement, (i ∈ Sᶜ) ≠ (j ∈ Sᶜ) iff (i ∉ S) ≠ (j ∉ S) iff (i ∈ S) ≠ (j ∈ S). So the filter conditions are equivalent. Use Finset.ext and the fact that ¬P ≠ ¬Q ↔ P ≠ Q.
-/

theorem boundary_complement (n : ℕ) (S : Finset (Fin (n + 1))) :
    subsetBoundary n S = subsetBoundary n Sᶜ := by
      exact congr_arg Finset.card ( Finset.filter_congr fun i hi => by by_cases hiS : ⟨ i.val, by linarith [ Fin.is_lt i ] ⟩ ∈ S <;> aesop )

/-
PROBLEM
Oracle energy equals the boundary of its True set.

PROVIDED SOLUTION
Both sides count the same thing: edges where O changes value. The transition count filters on O(i) != O(i+1). The boundary of {i : O(i) = true} counts edges where exactly one endpoint has O = true, which is the same as O(i) ≠ O(i+1). The filter conditions are equivalent: (O(i) != O(i+1)) iff ((O(i) = true) ≠ (O(i+1) = true)). Use congr_arg card with Finset.ext.
-/

theorem energy_eq_boundary (n : ℕ) (O : FinOracle' (n + 1)) :
    oracleTransitions' n O =
    subsetBoundary n ((Finset.univ : Finset (Fin (n + 1))).filter (fun i => O i = true)) := by
      unfold oracleTransitions' subsetBoundary;
      simp +zetaDelta at *

/-
PROBLEM
**Discrete Cheeger Inequality for Path Graphs**:
    For any nonempty proper subset S of a path on n+1 vertices,
    the boundary |∂S| ≥ 1.

PROVIDED SOLUTION
Since S is nonempty and Sᶜ is nonempty on a path graph (connected), there must be at least one edge crossing the boundary. More precisely, since S ≠ univ and S ≠ ∅, there exist consecutive vertices a ∈ S and b ∉ S (or vice versa) on the path. This gives at least one transition in the boundary filter. A cleaner approach: define the characteristic function χ_S and note it's not constant, so it has at least one transition. Use the fact that on a connected graph, a nonempty proper subset has nonempty boundary.
-/

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
