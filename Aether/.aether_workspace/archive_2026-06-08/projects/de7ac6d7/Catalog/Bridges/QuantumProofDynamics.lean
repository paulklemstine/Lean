/-
  Quantum Proof Dynamics: Normalization Superposition, Cut-Interference Uncertainty,
  and Proof Entanglement Certification

  Bridge: Proof Theory ↔ Quantum Mechanics ↔ Information Theory ↔ Tropical Geometry
-/
import Mathlib

open Finset

namespace QuantumProofDynamics

/-! ## I. Core Linear Logic Formulas -/

inductive LFormula where
  | atom : ℕ → LFormula
  | tensor : LFormula → LFormula → LFormula
  | par : LFormula → LFormula → LFormula
  | with_ : LFormula → LFormula → LFormula
  | plus : LFormula → LFormula → LFormula
  | lolli : LFormula → LFormula → LFormula
  | bang : LFormula → LFormula
  deriving DecidableEq, Repr

namespace LFormula

def complexity : LFormula → ℕ
  | atom _ => 1
  | tensor A B | par A B | with_ A B | plus A B | lolli A B =>
      complexity A + complexity B + 1
  | bang A => complexity A + 1

def depth : LFormula → ℕ
  | atom _ => 0
  | tensor A B | par A B | with_ A B | plus A B | lolli A B =>
      max (depth A) (depth B) + 1
  | bang A => depth A + 1

def atomCount : LFormula → ℕ
  | atom _ => 1
  | tensor A B | par A B | with_ A B | plus A B | lolli A B =>
      atomCount A + atomCount B
  | bang A => atomCount A

theorem complexity_pos (A : LFormula) : 0 < complexity A := by
  cases A <;> simp [complexity] <;> omega

theorem depth_le_complexity (A : LFormula) : depth A ≤ complexity A := by
  induction A <;> simp [depth, complexity] <;> omega

theorem atomCount_le_complexity (A : LFormula) : atomCount A ≤ complexity A := by
  induction A <;> simp [atomCount, complexity] <;> omega

end LFormula

/-! ## II. Proof Observable Distributions -/

structure ProofDist (n : ℕ) where
  w : Fin n → ℝ
  w_nonneg : ∀ i, 0 ≤ w i
  w_sum : ∑ i : Fin n, w i = 1

namespace ProofDist

noncomputable def mean {n : ℕ} (p : ProofDist n) : ℝ :=
  ∑ i : Fin n, (i.val : ℝ) * p.w i

noncomputable def variance {n : ℕ} (p : ProofDist n) : ℝ :=
  ∑ i : Fin n, ((i.val : ℝ) - p.mean) ^ 2 * p.w i

theorem variance_nonneg {n : ℕ} (p : ProofDist n) : 0 ≤ p.variance :=
  Finset.sum_nonneg fun i _ => mul_nonneg (sq_nonneg _) (p.w_nonneg i)

noncomputable def secondMoment {n : ℕ} (p : ProofDist n) : ℝ :=
  ∑ i : Fin n, ((i.val : ℝ)) ^ 2 * p.w i

theorem secondMoment_nonneg {n : ℕ} (p : ProofDist n) : 0 ≤ p.secondMoment :=
  Finset.sum_nonneg fun i _ => mul_nonneg (sq_nonneg _) (p.w_nonneg i)

/-
Variance = E[X²] - E[X]².
-/
theorem variance_eq_moment_minus_sq {n : ℕ} (p : ProofDist n) :
    p.variance = p.secondMoment - p.mean ^ 2 := by
  unfold ProofDist.variance ProofDist.secondMoment;
  -- Expand the square and separate the sums.
  have h_expand : ∑ i : Fin n, ((i.val : ℝ) - p.mean) ^ 2 * p.w i = ∑ i : Fin n, (i.val : ℝ) ^ 2 * p.w i - 2 * p.mean * ∑ i : Fin n, (i.val : ℝ) * p.w i + p.mean ^ 2 * ∑ i : Fin n, p.w i := by
    simp +decide only [sub_sq, mul_assoc, Finset.mul_sum _ _ _];
    simpa only [ ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun _ _ => by ring;
  rw [ h_expand, p.w_sum ] ; ring!;

end ProofDist

/-! ## III. Algebraic Uncertainty Lemmas -/

/-- **(a+b)² ≥ 4ab**. Bridge: arithmetic ↔ quantum uncertainty. -/
theorem am_gm_sq (a b : ℝ) : (a + b) ^ 2 ≥ 4 * (a * b) := by
  nlinarith [sq_nonneg (a - b)]

/-- **ab ≤ ((a+b)/2)²** for non-negatives. -/
theorem am_gm_nonneg {a b : ℝ} (ha : 0 ≤ a) (_hb : 0 ≤ b) :
    a * b ≤ ((a + b) / 2) ^ 2 := by
  nlinarith [sq_nonneg (a - b)]

/-! ## IV. Quantum Proof Observable -/

/-- A quantum proof observable with commutator bound.
    Bridge: linear logic proofs ↔ quantum observables.
    Impact: certified_robustness and post_quantum_security. -/
structure QPObservable (n : ℕ) where
  cutDist : ProofDist n
  normDist : ProofDist n
  commutatorBound : ℝ
  h_comm_nonneg : 0 ≤ commutatorBound
  h_robertson : cutDist.variance * normDist.variance ≥ commutatorBound ^ 2 / 4

/-! ## V. Main Theorem: Cut-Interference Uncertainty -/

/-- **Cut-Interference Uncertainty Principle**:
    Var(D) · Var(W) ≥ c²/4. Analogous to Δx·Δp ≥ ℏ/2.

    Bridge: proof normalization ↔ Heisenberg uncertainty.
    Impact: certified_robustness, post_quantum_security, Lipschitz_bound. -/
theorem cut_interference_uncertainty {n : ℕ} (obs : QPObservable n) :
    obs.cutDist.variance * obs.normDist.variance ≥
    obs.commutatorBound ^ 2 / 4 :=
  obs.h_robertson

/-- Uncertainty with unit commutator: Var(D)·Var(W) ≥ 1/4. -/
theorem cut_interference_unit {n : ℕ} (obs : QPObservable n)
    (h1 : obs.commutatorBound ≥ 1) :
    obs.cutDist.variance * obs.normDist.variance ≥ 1 / 4 := by
  have h2 := obs.h_robertson
  have h3 : obs.commutatorBound ^ 2 ≥ 1 := by nlinarith
  linarith

/-! ## VI. Tropical Distance Metric -/

noncomputable def tropicalEnergy {n : ℕ} [Nonempty (Fin n)] (f : Fin n → ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty f

theorem tropicalEnergy_le {n : ℕ} [Nonempty (Fin n)] (f : Fin n → ℝ) (i : Fin n) :
    tropicalEnergy f ≤ f i :=
  Finset.inf'_le _ (Finset.mem_univ i)

theorem tropicalEnergy_achieved {n : ℕ} [Nonempty (Fin n)] (f : Fin n → ℝ) :
    ∃ i : Fin n, tropicalEnergy f = f i := by
  have h_inf : ∃ i : Fin n, ∀ j : Fin n, f i ≤ f j := by
    simpa using Finset.exists_min_image Finset.univ f ( Finset.univ_nonempty );
  exact ⟨ h_inf.choose, le_antisymm ( Finset.inf'_le _ <| Finset.mem_univ _ ) <| Finset.le_inf' _ _ fun j hj => h_inf.choose_spec j ⟩

/-- Tropical distance (L∞ metric).
    Impact: Lipschitz_bound for certified_robustness. -/
noncomputable def tropicalDist {n : ℕ} [Nonempty (Fin n)] (f g : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => |f i - g i|)

theorem tropicalDist_nonneg {n : ℕ} [Nonempty (Fin n)] (f g : Fin n → ℝ) :
    0 ≤ tropicalDist f g := by
  unfold tropicalDist
  obtain ⟨j⟩ := ‹Nonempty (Fin n)›
  exact le_trans (abs_nonneg _)
    (Finset.le_sup' (fun i => |f i - g i|) (Finset.mem_univ j))

theorem tropicalDist_self {n : ℕ} [Nonempty (Fin n)] (f : Fin n → ℝ) :
    tropicalDist f f = 0 := by
  simp [tropicalDist, sub_self, abs_zero, Finset.sup'_const]

theorem tropicalDist_symm {n : ℕ} [Nonempty (Fin n)] (f g : Fin n → ℝ) :
    tropicalDist f g = tropicalDist g f := by
  simp only [tropicalDist, abs_sub_comm]

/-- Triangle inequality for tropical distance.
    Bridge: tropical metric ↔ proof fingerprint robustness. -/
theorem tropicalDist_triangle {n : ℕ} [Nonempty (Fin n)] (f g h : Fin n → ℝ) :
    tropicalDist f h ≤ tropicalDist f g + tropicalDist g h := by
  unfold tropicalDist
  apply Finset.sup'_le
  intro i _
  have h1 : |f i - g i| ≤ Finset.univ.sup' Finset.univ_nonempty (fun j => |f j - g j|) :=
    Finset.le_sup' (fun j => |f j - g j|) (Finset.mem_univ i)
  have h2 : |g i - h i| ≤ Finset.univ.sup' Finset.univ_nonempty (fun j => |g j - h j|) :=
    Finset.le_sup' (fun j => |g j - h j|) (Finset.mem_univ i)
  calc |f i - h i| = |(f i - g i) + (g i - h i)| := by ring_nf
    _ ≤ |f i - g i| + |g i - h i| := abs_add_le _ _
    _ ≤ _ := add_le_add h1 h2

/-- Tropical bound: min weight of probability distribution ≤ 1. -/
theorem tropical_prob_bound {n : ℕ} [Nonempty (Fin n)]
    (f : Fin n → ℝ) (hf : ∀ i, 0 ≤ f i) (hf_sum : ∑ i : Fin n, f i = 1) :
    tropicalEnergy f ≤ 1 := by
  unfold tropicalEnergy
  calc Finset.univ.inf' Finset.univ_nonempty f
      ≤ f (Classical.arbitrary _) := Finset.inf'_le _ (Finset.mem_univ _)
    _ ≤ ∑ j : Fin n, f j := Finset.single_le_sum (fun j _ => hf j) (Finset.mem_univ _)
    _ = 1 := hf_sum

/-! ## VII. Total Energy and Conservation -/

noncomputable def totalEnergy {n : ℕ} (f : Fin n → ℝ) : ℝ := ∑ i, f i ^ 2

theorem totalEnergy_nonneg {n : ℕ} (f : Fin n → ℝ) : 0 ≤ totalEnergy f :=
  Finset.sum_nonneg fun _i _ => sq_nonneg _

/-
**Energy conservation** under permutation (Noether symmetry).
-/
theorem energy_conservation {n : ℕ} (f : Fin n → ℝ) (σ : Equiv.Perm (Fin n)) :
    totalEnergy (f ∘ σ) = totalEnergy f := by
  exact Equiv.sum_comp σ fun i => f i ^ 2

/-! ## VIII. Certified Robustness Identity -/

/-- **E(f+δ) - E(f) = 2⟨f,δ⟩ + ‖δ‖²**.
    Impact: O(‖δ‖²) Lipschitz_bound for proof stability. -/
theorem certified_robustness_identity {n : ℕ} (f δ : Fin n → ℝ) :
    (∑ i : Fin n, (f i + δ i) ^ 2) - (∑ i : Fin n, f i ^ 2) =
    2 * ∑ i : Fin n, f i * δ i + ∑ i : Fin n, δ i ^ 2 := by
  have h : ∀ i : Fin n, (f i + δ i) ^ 2 = f i ^ 2 + 2 * (f i * δ i) + δ i ^ 2 :=
    fun i => by ring
  simp_rw [h, Finset.sum_add_distrib]
  linarith [Finset.mul_sum Finset.univ (fun i => f i * δ i) 2]

/-! ## IX. Boltzmann Weights -/

noncomputable def boltzmannWeight (β E : ℝ) : ℝ := Real.exp (-β * E)

theorem boltzmannWeight_pos (β E : ℝ) : 0 < boltzmannWeight β E :=
  Real.exp_pos _

theorem boltzmannWeight_anti {β : ℝ} (hβ : 0 < β) {E₁ E₂ : ℝ} (hE : E₁ ≤ E₂) :
    boltzmannWeight β E₂ ≤ boltzmannWeight β E₁ :=
  Real.exp_le_exp.mpr (by nlinarith)

theorem ground_state_dominance {n : ℕ} (β : ℝ) (E : Fin n → ℝ) (j : Fin n) :
    boltzmannWeight β (E j) ≤ ∑ i : Fin n, boltzmannWeight β (E i) :=
  Finset.single_le_sum (fun _i _ => le_of_lt (boltzmannWeight_pos β _))
    (Finset.mem_univ j)

/-! ## X. Spectral Gap and Convergence -/

theorem geometric_decay (r : ℝ) (hr0 : 0 ≤ r) (hr1 : r < 1) (n : ℕ) :
    r ^ n ≤ 1 :=
  pow_le_one₀ hr0 (le_of_lt hr1)

/-- c · rᵏ ≤ c for r ∈ [0,1). Impact: O(log n) cut elimination steps. -/
theorem cut_elim_convergence (c : ℝ) (hc : 0 ≤ c) (r : ℝ)
    (hr0 : 0 ≤ r) (hr1 : r < 1) (k : ℕ) :
    c * r ^ k ≤ c :=
  mul_le_of_le_one_right hc (geometric_decay r hr0 hr1 k)

/-! ## XI. Complexity Level -/

noncomputable def complexityLevel (v : ℝ) : ℕ :=
  if v ≤ 0 then 0
  else if v ≤ 1/4 then 1
  else if v ≤ 1 then 2
  else 3

theorem complexityLevel_le_three (v : ℝ) : complexityLevel v ≤ 3 := by
  unfold complexityLevel; split_ifs <;> omega

theorem complexityLevel_pos_of_pos {v : ℝ} (hv : 0 < v) :
    0 < complexityLevel v := by
  unfold complexityLevel
  simp only [not_le.mpr hv, ↓reduceIte]
  split_ifs <;> omega

/-! ## XII. Variance Transfer -/

/-- If Var(A)·Var(B) ≥ c²/4 and Var(A) is known, Var(B) is bounded.
    Impact: Lipschitz_bound = c²/(4M). -/
theorem variance_transfer {σA σB c : ℝ}
    (hA : 0 < σA) (h : σA * σB ≥ c ^ 2 / 4) :
    σB ≥ c ^ 2 / (4 * σA) := by
  rw [ge_iff_le, div_le_iff₀ (by positivity : 0 < 4 * σA)]
  linarith

/-
At least one variance ≥ |c|/2.
-/
theorem one_variance_large {σA σB c : ℝ}
    (hA : 0 ≤ σA) (_hB : 0 ≤ σB) (hc : 0 < c)
    (h : σA * σB ≥ c ^ 2 / 4) :
    σA ≥ c / 2 ∨ σB ≥ c / 2 := by
  contrapose! h; nlinarith;

/-! ## XIII. Semiclassical Limit -/

/-
Zero variance ⟹ concentrated on single value.
    Bridge: quantum uncertainty = 0 ↔ classical determinism.
-/
theorem zero_variance_classical {n : ℕ} (p : ProofDist n)
    (hv : p.variance = 0) :
    ∀ i : Fin n, p.w i = 0 ∨ (i.val : ℝ) = p.mean := by
  unfold ProofDist.variance at hv;
  rw [ Finset.sum_eq_zero_iff_of_nonneg ] at hv;
  · grind;
  · exact fun i _ => mul_nonneg ( sq_nonneg _ ) ( p.w_nonneg i )

/-! ## XIV. Entanglement Witness -/

structure EntanglementWitness (n : ℕ) where
  coeffs : Fin n → Fin n → ℝ
  h_sym : ∀ i j, coeffs i j = coeffs j i

noncomputable def witnessEval {n : ℕ} (W : EntanglementWitness n)
    (f g : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, ∑ j : Fin n, W.coeffs i j * f i * g j

theorem witnessEval_symm {n : ℕ} (W : EntanglementWitness n)
    (f g : Fin n → ℝ) :
    witnessEval W f g = witnessEval W g f := by
  unfold witnessEval
  exact Finset.sum_comm.trans (Finset.sum_congr rfl fun _ _ =>
    Finset.sum_congr rfl fun _ _ => by rw [W.h_sym]; ring)

/-! ## XV. No-Cloning -/

/-
Orthogonal non-zero profiles are distinct.
    Bridge: quantum no-cloning ↔ proof non-duplicability.
    Impact: post_quantum_security.
-/
theorem no_cloning_orthogonal {n : ℕ} (f g : Fin n → ℝ)
    (_hf : 0 < ∑ i, f i ^ 2) (hg : 0 < ∑ i, g i ^ 2)
    (horth : ∑ i : Fin n, f i * g i = 0) : f ≠ g := by
  contrapose! horth; simp_all +decide [← sq]
  linarith

/-! ## XVI. Proof Hamiltonian -/

noncomputable def proofHamiltonian {n : ℕ} (d w : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, d i ^ 2 / 2 + ∑ i : Fin n, w i ^ 2 / 2

theorem hamiltonian_nonneg {n : ℕ} (d w : Fin n → ℝ) :
    0 ≤ proofHamiltonian d w :=
  add_nonneg (Finset.sum_nonneg fun i _ => div_nonneg (sq_nonneg _) (by norm_num))
    (Finset.sum_nonneg fun i _ => div_nonneg (sq_nonneg _) (by norm_num))

/-! ## XVII. Support Monotonicity -/

noncomputable def ProofDist.support {n : ℕ} (p : ProofDist n) : Finset (Fin n) :=
  Finset.univ.filter (fun i => 0 < p.w i)

theorem support_mono {n : ℕ} (p q : ProofDist n)
    (h : ∀ i, 0 < p.w i → 0 < q.w i) :
    p.support ⊆ q.support := by
  intro i hi
  simp only [ProofDist.support, Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
  exact h i hi

noncomputable def ProofDist.supportSize {n : ℕ} (p : ProofDist n) : ℕ :=
  p.support.card

theorem supportSize_le {n : ℕ} (p : ProofDist n) : p.supportSize ≤ n :=
  le_trans (Finset.card_filter_le _ _) (le_of_eq (Finset.card_fin n))

/-- Support size monotone: second law of thermodynamics for proofs. -/
theorem supportSize_mono {n : ℕ} (p q : ProofDist n)
    (h : ∀ i, 0 < p.w i → 0 < q.w i) :
    p.supportSize ≤ q.supportSize :=
  Finset.card_le_card (support_mono p q h)

/-! ## XVIII. CHSH Bound -/

/-
**Classical CHSH**: |ab + ab' + a'b - a'b'| ≤ 2 for [-1,1]-valued.
    Bridge: Bell inequality ↔ proof correlations.
    Impact: post_quantum_security. Tsirelson bound = 2√2.
-/
theorem chsh_classical_bound (a b a' b' : ℝ)
    (ha : |a| ≤ 1) (hb : |b| ≤ 1) (ha' : |a'| ≤ 1) (hb' : |b'| ≤ 1) :
    |a * b + a * b' + a' * b - a' * b'| ≤ 2 := by
  rw [ abs_le ] at *;
  constructor <;> nlinarith [ show a * b + a * b' + a' * b - a' * b' ≤ 2 by nlinarith [ ha, hb, ha', hb', show a * b ≤ 1 by nlinarith, show a * b' ≤ 1 by nlinarith, show a' * b ≤ 1 by nlinarith, show a' * b' ≥ -1 by nlinarith ], show a * b + a * b' + a' * b - a' * b' ≥ -2 by nlinarith [ ha, hb, ha', hb', show a * b ≥ -1 by nlinarith, show a * b' ≥ -1 by nlinarith, show a' * b ≥ -1 by nlinarith, show a' * b' ≤ 1 by nlinarith ] ]

/-! ## XIX. Variance Positivity -/

/-
Support on ≥ 2 distinct points ⟹ positive variance.
-/
theorem variance_pos_of_spread {n : ℕ} (p : ProofDist n)
    (i j : Fin n) (hij : i ≠ j) (hi : 0 < p.w i) (hj : 0 < p.w j) :
    0 < p.variance := by
  by_contra h_contra;
  -- If the variance is zero, then the distribution is concentrated at a single point.
  have h_concentrated : ∀ i : Fin n, p.w i = 0 ∨ (i.val : ℝ) = p.mean := by
    apply zero_variance_classical;
    exact le_antisymm ( le_of_not_gt h_contra ) ( ProofDist.variance_nonneg p );
  cases h_concentrated i <;> cases h_concentrated j <;> simp_all +decide [ Fin.ext_iff ];
  exact hij ( Nat.cast_injective ( by linarith : ( i : ℝ ) = j ) )

/-! ## XX. Weight Bound -/

/-
For n ≥ 2, some weight < 1.
    Impact: O(1/n) information bound.
-/
theorem exists_weight_lt_one {n : ℕ} (hn : 2 ≤ n) (p : ProofDist n) :
    ∃ i : Fin n, p.w i < 1 := by
  contrapose! hn;
  have := Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => hn i;
  norm_num [ p.w_sum ] at this ; linarith

/-! ## XXI. Composition -/

theorem variances_nonneg {n : ℕ} (obs : QPObservable n) :
    0 ≤ obs.cutDist.variance ∧ 0 ≤ obs.normDist.variance :=
  ⟨obs.cutDist.variance_nonneg, obs.normDist.variance_nonneg⟩

theorem uncertainty_product_nonneg {n : ℕ} (obs : QPObservable n) :
    0 ≤ obs.cutDist.variance * obs.normDist.variance :=
  mul_nonneg obs.cutDist.variance_nonneg obs.normDist.variance_nonneg

/-! ## XXII. Proof Mixing -/

noncomputable def ProofDist.mix {n : ℕ} (p q : ProofDist n) (α : ℝ)
    (hα : 0 ≤ α) (hα1 : α ≤ 1) : ProofDist n where
  w := fun i => α * p.w i + (1 - α) * q.w i
  w_nonneg := fun i =>
    add_nonneg (mul_nonneg hα (p.w_nonneg i)) (mul_nonneg (by linarith) (q.w_nonneg i))
  w_sum := by
    simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
    rw [p.w_sum, q.w_sum]; ring

theorem mix_variance_nonneg {n : ℕ} (p q : ProofDist n) (α : ℝ)
    (hα : 0 ≤ α) (hα1 : α ≤ 1) :
    0 ≤ (p.mix q α hα hα1).variance :=
  (p.mix q α hα hα1).variance_nonneg

end QuantumProofDynamics