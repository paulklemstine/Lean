/-
  Proof Thermodynamics Core: Formula Energy, Proof Trees, and Conservation Laws

  Bridge: Proof Theory ↔ Statistical Mechanics ↔ Information Theory

  This file establishes the foundational definitions and structural theorems for
  proof thermodynamics: a rigorous correspondence between sequent calculus proof
  normalization and thermodynamic processes.
-/
import Mathlib

namespace ProofThermodynamics

/-- A propositional formula with de Bruijn-style atom indices.
    Bridge: connects proof theory to Hamiltonian mechanics. -/
inductive Formula where
  | atom : ℕ → Formula
  | bot : Formula
  | conj : Formula → Formula → Formula
  | disj : Formula → Formula → Formula
  | impl : Formula → Formula → Formula
  deriving DecidableEq, Repr

namespace Formula

/-- Structural energy: the Hamiltonian of a formula. -/
def hamiltonian : Formula → ℕ
  | atom _ => 1
  | bot => 1
  | conj φ ψ => hamiltonian φ + hamiltonian ψ + 1
  | disj φ ψ => hamiltonian φ + hamiltonian ψ + 1
  | impl φ ψ => hamiltonian φ + hamiltonian ψ + 1

/-- Connective count: the "potential energy" of the formula. -/
def connective_energy : Formula → ℕ
  | atom _ => 0
  | bot => 1
  | conj φ ψ => connective_energy φ + connective_energy ψ + 1
  | disj φ ψ => connective_energy φ + connective_energy ψ + 1
  | impl φ ψ => connective_energy φ + connective_energy ψ + 1

/-- Formula depth: the maximum nesting depth. -/
def depth : Formula → ℕ
  | atom _ => 0
  | bot => 0
  | conj φ ψ => max (depth φ) (depth ψ) + 1
  | disj φ ψ => max (depth φ) (depth ψ) + 1
  | impl φ ψ => max (depth φ) (depth ψ) + 1

/-- Atom count: the "kinetic energy" of the formula. -/
def atom_count : Formula → ℕ
  | atom _ => 1
  | bot => 0
  | conj φ ψ => atom_count φ + atom_count ψ
  | disj φ ψ => atom_count φ + atom_count ψ
  | impl φ ψ => atom_count φ + atom_count ψ

/-- The subformula relation. -/
inductive IsProperSubformula : Formula → Formula → Prop where
  | conj_left (φ ψ : Formula) : IsProperSubformula φ (conj φ ψ)
  | conj_right (φ ψ : Formula) : IsProperSubformula ψ (conj φ ψ)
  | disj_left (φ ψ : Formula) : IsProperSubformula φ (disj φ ψ)
  | disj_right (φ ψ : Formula) : IsProperSubformula ψ (disj φ ψ)
  | impl_left (φ ψ : Formula) : IsProperSubformula φ (impl φ ψ)
  | impl_right (φ ψ : Formula) : IsProperSubformula ψ (impl φ ψ)
  | trans {φ ψ χ : Formula} : IsProperSubformula φ ψ → IsProperSubformula ψ χ →
      IsProperSubformula φ χ

/-- Every formula has positive energy. -/
theorem hamiltonian_pos (φ : Formula) : 0 < hamiltonian φ := by
  cases φ <;> simp [hamiltonian]

/-- depth ≤ hamiltonian. -/
theorem hamiltonian_ge_depth (φ : Formula) : depth φ ≤ hamiltonian φ := by
  induction φ <;> simp [hamiltonian, depth] <;> omega

/-- H = atom_count + connective_energy. -/
theorem hamiltonian_decomposition (φ : Formula) :
    hamiltonian φ = atom_count φ + connective_energy φ := by
  induction φ <;> simp [hamiltonian, atom_count, connective_energy, *] <;> ring

/-- connective_energy ≤ hamiltonian. -/
theorem connective_energy_le_hamiltonian (φ : Formula) :
    connective_energy φ ≤ hamiltonian φ := by
  rw [hamiltonian_decomposition]; omega

/-- atom_count ≤ hamiltonian. -/
theorem atom_count_le_hamiltonian (φ : Formula) :
    atom_count φ ≤ hamiltonian φ := by
  rw [hamiltonian_decomposition]; omega

/-- Proper subformulas have strictly less energy.
    Bridge: Gentzen's subformula property ↔ thermodynamic dissipation. -/
theorem subformula_energy_decrease {φ ψ : Formula} (h : IsProperSubformula φ ψ) :
    hamiltonian φ < hamiltonian ψ := by
  induction h with
  | conj_left a b =>
    have := hamiltonian_pos b; simp only [hamiltonian]; omega
  | conj_right a b =>
    have := hamiltonian_pos a; simp only [hamiltonian]; omega
  | disj_left a b =>
    have := hamiltonian_pos b; simp only [hamiltonian]; omega
  | disj_right a b =>
    have := hamiltonian_pos a; simp only [hamiltonian]; omega
  | impl_left a b =>
    have := hamiltonian_pos b; simp only [hamiltonian]; omega
  | impl_right a b =>
    have := hamiltonian_pos a; simp only [hamiltonian]; omega
  | trans _ _ ih1 ih2 => omega

/-- Proper subformulas have strictly less depth. -/
theorem subformula_depth_decrease {φ ψ : Formula} (h : IsProperSubformula φ ψ) :
    depth φ < depth ψ := by
  induction h with
  | conj_left a b => simp only [depth]; omega
  | conj_right a b => simp only [depth]; omega
  | disj_left a b => simp only [depth]; omega
  | disj_right a b => simp only [depth]; omega
  | impl_left a b => simp only [depth]; omega
  | impl_right a b => simp only [depth]; omega
  | trans _ _ ih1 ih2 => omega

/-- depth ≤ connective_energy. -/
theorem connective_energy_ge_depth (φ : Formula) :
    depth φ ≤ connective_energy φ := by
  induction φ <;> simp [depth, connective_energy] <;> omega

/-- H(conj φ ψ) = H(φ) + H(ψ) + 1. Binding energy = 1. -/
theorem hamiltonian_conj_eq (φ ψ : Formula) :
    hamiltonian (conj φ ψ) = hamiltonian φ + hamiltonian ψ + 1 := rfl

theorem hamiltonian_disj_eq (φ ψ : Formula) :
    hamiltonian (disj φ ψ) = hamiltonian φ + hamiltonian ψ + 1 := rfl

theorem hamiltonian_impl_eq (φ ψ : Formula) :
    hamiltonian (impl φ ψ) = hamiltonian φ + hamiltonian ψ + 1 := rfl

/-- Compound formulas have strictly more energy than components. -/
theorem hamiltonian_conj_gt_left (φ ψ : Formula) :
    hamiltonian φ < hamiltonian (conj φ ψ) := by
  have := hamiltonian_pos ψ; simp only [hamiltonian]; omega

theorem hamiltonian_conj_gt_right (φ ψ : Formula) :
    hamiltonian ψ < hamiltonian (conj φ ψ) := by
  have := hamiltonian_pos φ; simp only [hamiltonian]; omega

end Formula

/-! ## Proof Trees -/

/-- Sequent calculus proof trees.
    Bridge: logical inference ↔ energy exchanges in thermodynamics. -/
inductive ProofTree where
  | ax : Formula → ProofTree
  | cut : ProofTree → ProofTree → Formula → ProofTree
  | conjL : ProofTree → ProofTree → ProofTree
  | conjR : Formula → ProofTree → ProofTree
  | disjL : Formula → Formula → ProofTree → ProofTree
  | disjR : ProofTree → ProofTree → ProofTree
  | implL : ProofTree → ProofTree → ProofTree
  | implR : Formula → ProofTree → ProofTree
  | weakL : ProofTree → ProofTree
  | weakR : ProofTree → ProofTree
  | contrL : ProofTree → ProofTree
  | contrR : ProofTree → ProofTree
  deriving Repr

namespace ProofTree

/-- Total proof energy: thermodynamic internal energy U(π). -/
def proof_energy : ProofTree → ℕ
  | ax φ => 2 * Formula.hamiltonian φ
  | cut π₁ π₂ φ => proof_energy π₁ + proof_energy π₂ + 3 * Formula.hamiltonian φ
  | conjL π₁ π₂ => proof_energy π₁ + proof_energy π₂
  | conjR φ π => proof_energy π + Formula.hamiltonian φ
  | disjL φ₁ φ₂ π => proof_energy π + Formula.hamiltonian φ₁ + Formula.hamiltonian φ₂
  | disjR π₁ π₂ => proof_energy π₁ + proof_energy π₂
  | implL π₁ π₂ => proof_energy π₁ + proof_energy π₂
  | implR φ π => proof_energy π + Formula.hamiltonian φ
  | weakL π => proof_energy π
  | weakR π => proof_energy π
  | contrL π => proof_energy π
  | contrR π => proof_energy π

/-- Number of inference steps. -/
def step_count : ProofTree → ℕ
  | ax _ => 1
  | cut π₁ π₂ _ => step_count π₁ + step_count π₂ + 1
  | conjL π₁ π₂ => step_count π₁ + step_count π₂ + 1
  | conjR _ π => step_count π + 1
  | disjL _ _ π => step_count π + 1
  | disjR π₁ π₂ => step_count π₁ + step_count π₂ + 1
  | implL π₁ π₂ => step_count π₁ + step_count π₂ + 1
  | implR _ π => step_count π + 1
  | weakL π => step_count π + 1
  | weakR π => step_count π + 1
  | contrL π => step_count π + 1
  | contrR π => step_count π + 1

/-- Number of cuts. -/
def cut_count : ProofTree → ℕ
  | ax _ => 0
  | cut π₁ π₂ _ => cut_count π₁ + cut_count π₂ + 1
  | conjL π₁ π₂ => cut_count π₁ + cut_count π₂
  | conjR _ π => cut_count π
  | disjL _ _ π => cut_count π
  | disjR π₁ π₂ => cut_count π₁ + cut_count π₂
  | implL π₁ π₂ => cut_count π₁ + cut_count π₂
  | implR _ π => cut_count π
  | weakL π => cut_count π
  | weakR π => cut_count π
  | contrL π => cut_count π
  | contrR π => cut_count π

/-- A proof is normal (cut-free): the thermodynamic ground state. -/
def is_normal (π : ProofTree) : Prop := cut_count π = 0

/-- Max formula hamiltonian in a proof tree. -/
def max_formula_energy : ProofTree → ℕ
  | ax φ => Formula.hamiltonian φ
  | cut π₁ π₂ φ =>
      max (max (max_formula_energy π₁) (max_formula_energy π₂)) (Formula.hamiltonian φ)
  | conjL π₁ π₂ => max (max_formula_energy π₁) (max_formula_energy π₂)
  | conjR φ π => max (Formula.hamiltonian φ) (max_formula_energy π)
  | disjL φ₁ φ₂ π =>
      max (max (Formula.hamiltonian φ₁) (Formula.hamiltonian φ₂)) (max_formula_energy π)
  | disjR π₁ π₂ => max (max_formula_energy π₁) (max_formula_energy π₂)
  | implL π₁ π₂ => max (max_formula_energy π₁) (max_formula_energy π₂)
  | implR φ π => max (Formula.hamiltonian φ) (max_formula_energy π)
  | weakL π => max_formula_energy π
  | weakR π => max_formula_energy π
  | contrL π => max_formula_energy π
  | contrR π => max_formula_energy π

/-- Tree height. -/
def height : ProofTree → ℕ
  | ax _ => 0
  | cut π₁ π₂ _ => max (height π₁) (height π₂) + 1
  | conjL π₁ π₂ => max (height π₁) (height π₂) + 1
  | conjR _ π => height π + 1
  | disjL _ _ π => height π + 1
  | disjR π₁ π₂ => max (height π₁) (height π₂) + 1
  | implL π₁ π₂ => max (height π₁) (height π₂) + 1
  | implR _ π => height π + 1
  | weakL π => height π + 1
  | weakR π => height π + 1
  | contrL π => height π + 1
  | contrR π => height π + 1

/-! ### First Law: Energy Conservation -/

/-- Cut costs exactly 3·H(φ). -/
theorem cut_energy_eq (π₁ π₂ : ProofTree) (φ : Formula) :
    proof_energy (cut π₁ π₂ φ) =
    proof_energy π₁ + proof_energy π₂ + 3 * Formula.hamiltonian φ := rfl

/-- Structural rules are isothermal (preserve energy). -/
theorem weakL_energy_isothermal (π : ProofTree) :
    proof_energy (weakL π) = proof_energy π := rfl

theorem weakR_energy_isothermal (π : ProofTree) :
    proof_energy (weakR π) = proof_energy π := rfl

theorem contrL_energy_isothermal (π : ProofTree) :
    proof_energy (contrL π) = proof_energy π := rfl

theorem contrR_energy_isothermal (π : ProofTree) :
    proof_energy (contrR π) = proof_energy π := rfl

/-! ### Structural Properties -/

/-- Step count is always positive. -/
theorem step_count_pos (π : ProofTree) : 0 < step_count π := by
  cases π <;> simp [step_count]

/-- cut_count ≤ step_count. -/
theorem cut_count_le_step_count (π : ProofTree) : cut_count π ≤ step_count π := by
  induction π <;> simp [cut_count, step_count] <;> omega

/-- Axiom is normal (ground state). -/
theorem ax_is_normal (φ : Formula) : is_normal (ax φ) := rfl

/-- Cut is not normal (excited state). -/
theorem cut_not_normal (π₁ π₂ : ProofTree) (φ : Formula) :
    ¬ is_normal (cut π₁ π₂ φ) := by
  intro h; simp [is_normal, cut_count] at h

/-- Structural rules preserve normality. -/
theorem weakL_preserves_normal {π : ProofTree} (h : is_normal π) :
    is_normal (weakL π) := h

theorem weakR_preserves_normal {π : ProofTree} (h : is_normal π) :
    is_normal (weakR π) := h

theorem contrL_preserves_normal {π : ProofTree} (h : is_normal π) :
    is_normal (contrL π) := h

theorem contrR_preserves_normal {π : ProofTree} (h : is_normal π) :
    is_normal (contrR π) := h

/-- Logical rules preserve normality for normal subproofs. -/
theorem conjL_preserves_normal {π₁ π₂ : ProofTree}
    (h1 : is_normal π₁) (h2 : is_normal π₂) :
    is_normal (conjL π₁ π₂) := by
  simp [is_normal, cut_count] at *; omega

theorem disjR_preserves_normal {π₁ π₂ : ProofTree}
    (h1 : is_normal π₁) (h2 : is_normal π₂) :
    is_normal (disjR π₁ π₂) := by
  simp [is_normal, cut_count] at *; omega

theorem implL_preserves_normal {π₁ π₂ : ProofTree}
    (h1 : is_normal π₁) (h2 : is_normal π₂) :
    is_normal (implL π₁ π₂) := by
  simp [is_normal, cut_count] at *; omega

theorem conjR_preserves_normal {φ : Formula} {π : ProofTree}
    (h : is_normal π) : is_normal (conjR φ π) := h

theorem disjL_preserves_normal {φ₁ φ₂ : Formula} {π : ProofTree}
    (h : is_normal π) : is_normal (disjL φ₁ φ₂ π) := h

theorem implR_preserves_normal {φ : Formula} {π : ProofTree}
    (h : is_normal π) : is_normal (implR φ π) := h

/-- Every proof has positive energy. -/
theorem proof_energy_pos (π : ProofTree) : 0 < proof_energy π := by
  induction π with
  | ax φ =>
    show 0 < 2 * Formula.hamiltonian φ
    have := Formula.hamiltonian_pos φ; omega
  | cut _ _ φ ih1 ih2 =>
    show 0 < _ + _ + 3 * Formula.hamiltonian φ
    have := Formula.hamiltonian_pos φ; omega
  | conjL _ _ ih1 ih2 => show 0 < _ + _; omega
  | conjR φ _ ih =>
    show 0 < _ + Formula.hamiltonian φ
    have := Formula.hamiltonian_pos φ; omega
  | disjL φ₁ φ₂ _ ih =>
    show 0 < _ + Formula.hamiltonian φ₁ + Formula.hamiltonian φ₂
    have := Formula.hamiltonian_pos φ₁; have := Formula.hamiltonian_pos φ₂; omega
  | disjR _ _ ih1 ih2 => show 0 < _ + _; omega
  | implL _ _ ih1 ih2 => show 0 < _ + _; omega
  | implR φ _ ih =>
    show 0 < _ + Formula.hamiltonian φ
    have := Formula.hamiltonian_pos φ; omega
  | weakL _ ih => exact ih
  | weakR _ ih => exact ih
  | contrL _ ih => exact ih
  | contrR _ ih => exact ih

/-- Max formula energy is positive. -/
theorem max_formula_energy_pos (π : ProofTree) : 0 < max_formula_energy π := by
  induction π with
  | ax φ => exact Formula.hamiltonian_pos φ
  | cut _ _ φ _ _ =>
    show 0 < max (max _ _) (Formula.hamiltonian φ)
    have := Formula.hamiltonian_pos φ; omega
  | conjL _ _ ih1 _ => show 0 < max _ _; omega
  | conjR φ _ _ =>
    show 0 < max (Formula.hamiltonian φ) _
    have := Formula.hamiltonian_pos φ; omega
  | disjL φ₁ _ _ _ =>
    show 0 < max (max (Formula.hamiltonian φ₁) _) _
    have := Formula.hamiltonian_pos φ₁; omega
  | disjR _ _ ih1 _ => show 0 < max _ _; omega
  | implL _ _ ih1 _ => show 0 < max _ _; omega
  | implR φ _ _ =>
    show 0 < max (Formula.hamiltonian φ) _
    have := Formula.hamiltonian_pos φ; omega
  | weakL _ ih => exact ih
  | weakR _ ih => exact ih
  | contrL _ ih => exact ih
  | contrR _ ih => exact ih

/-- height < step_count. -/
theorem height_lt_step_count (π : ProofTree) : height π < step_count π := by
  induction π <;> simp [height, step_count] <;> omega

/-- ∀ π, ∃ φ, 2·H(φ) ≤ E(π). -/
theorem proof_energy_ge_two_hamiltonian (π : ProofTree) :
    ∃ (φ : Formula), 2 * Formula.hamiltonian φ ≤ proof_energy π := by
  induction π with
  | ax φ => exact ⟨φ, le_refl _⟩
  | cut π₁ _ _ ih1 _ =>
    obtain ⟨ψ, hψ⟩ := ih1
    refine ⟨ψ, ?_⟩
    show _ ≤ _ + _ + _; omega
  | conjL π₁ _ ih1 _ =>
    obtain ⟨ψ, hψ⟩ := ih1
    refine ⟨ψ, ?_⟩
    show _ ≤ _ + _; omega
  | conjR _ π ih =>
    obtain ⟨ψ, hψ⟩ := ih
    refine ⟨ψ, ?_⟩
    show _ ≤ _ + _; omega
  | disjL _ _ π ih =>
    obtain ⟨ψ, hψ⟩ := ih
    refine ⟨ψ, ?_⟩
    show _ ≤ _ + _ + _; omega
  | disjR π₁ _ ih1 _ =>
    obtain ⟨ψ, hψ⟩ := ih1
    refine ⟨ψ, ?_⟩
    show _ ≤ _ + _; omega
  | implL π₁ _ ih1 _ =>
    obtain ⟨ψ, hψ⟩ := ih1
    refine ⟨ψ, ?_⟩
    show _ ≤ _ + _; omega
  | implR _ π ih =>
    obtain ⟨ψ, hψ⟩ := ih
    refine ⟨ψ, ?_⟩
    show _ ≤ _ + _; omega
  | weakL _ ih => exact ih
  | weakR _ ih => exact ih
  | contrL _ ih => exact ih
  | contrR _ ih => exact ih

/-- Cut energy exceeds each subproof. -/
theorem cut_energy_dominates_left (π₁ π₂ : ProofTree) (φ : Formula) :
    proof_energy π₁ < proof_energy (cut π₁ π₂ φ) := by
  show _ < _ + _ + _
  have := proof_energy_pos π₂; have := Formula.hamiltonian_pos φ; omega

theorem cut_energy_dominates_right (π₁ π₂ : ProofTree) (φ : Formula) :
    proof_energy π₂ < proof_energy (cut π₁ π₂ φ) := by
  show _ < _ + _ + _
  have := proof_energy_pos π₁; have := Formula.hamiltonian_pos φ; omega

/-- cut_count is additive. -/
theorem cut_count_conjL (π₁ π₂ : ProofTree) :
    cut_count (conjL π₁ π₂) = cut_count π₁ + cut_count π₂ := rfl

theorem cut_count_disjR (π₁ π₂ : ProofTree) :
    cut_count (disjR π₁ π₂) = cut_count π₁ + cut_count π₂ := rfl

/-- Cut formula energy ≤ proof energy. -/
theorem cut_formula_energy_le_proof_energy (π₁ π₂ : ProofTree) (φ : Formula) :
    Formula.hamiltonian φ ≤ proof_energy (cut π₁ π₂ φ) := by
  show _ ≤ _ + _ + _
  have := proof_energy_pos π₁; have := proof_energy_pos π₂; omega

/-- 3 · cut_count ≤ proof_energy.
    Bridge: defect-energy coupling ↔ Peierls bound. -/
theorem energy_defect_coupling (π : ProofTree) :
    3 * cut_count π ≤ proof_energy π := by
  induction π with
  | ax _ => simp [cut_count, proof_energy]
  | cut π₁ π₂ φ ih1 ih2 =>
    show 3 * (_ + _ + 1) ≤ _ + _ + 3 * _
    have := Formula.hamiltonian_pos φ; omega
  | conjL _ _ ih1 ih2 =>
    show 3 * (_ + _) ≤ _ + _; omega
  | conjR φ _ ih =>
    simp only [cut_count, proof_energy]
    have := Formula.hamiltonian_pos φ; omega
  | disjL φ1 φ2 _ ih =>
    simp only [cut_count, proof_energy]
    have := Formula.hamiltonian_pos φ1
    have := Formula.hamiltonian_pos φ2; omega
  | disjR _ _ ih1 ih2 =>
    show 3 * (_ + _) ≤ _ + _; omega
  | implL _ _ ih1 ih2 =>
    show 3 * (_ + _) ≤ _ + _; omega
  | implR φ _ ih =>
    simp only [cut_count, proof_energy]
    have := Formula.hamiltonian_pos φ; omega
  | weakL _ ih => exact ih
  | weakR _ ih => exact ih
  | contrL _ ih => exact ih
  | contrR _ ih => exact ih

/-- Proof complexity hierarchy. -/
theorem proof_complexity_hierarchy (π : ProofTree) :
    cut_count π ≤ step_count π ∧ height π < step_count π :=
  ⟨cut_count_le_step_count π, height_lt_step_count π⟩

end ProofTree

/-! ## Boltzmann Weights and Partition Functions -/

section FreeEnergy

/-- Boltzmann weight: exp(-β · E). -/
noncomputable def boltzmann_weight (β : ℝ) (E : ℕ) : ℝ :=
  Real.exp (-β * E)

/-- Boltzmann weights are positive. -/
theorem boltzmann_weight_pos (β : ℝ) (E : ℕ) : 0 < boltzmann_weight β E :=
  Real.exp_pos _

/-- Higher energy → smaller weight (for β > 0). -/
theorem boltzmann_weight_anti {β : ℝ} (hβ : 0 < β) {E₁ E₂ : ℕ} (hE : E₁ ≤ E₂) :
    boltzmann_weight β E₂ ≤ boltzmann_weight β E₁ := by
  unfold boltzmann_weight
  apply Real.exp_le_exp.mpr
  have : (E₁ : ℝ) ≤ (E₂ : ℝ) := Nat.cast_le.mpr hE
  nlinarith

/-- Ground state dominance: min-energy weight ≤ partition sum. -/
theorem ground_state_dominance {β : ℝ} {N : ℕ} (_hN : 0 < N)
    (energies : Fin N → ℕ) (E_min : ℕ)
    (h_exists : ∃ i, energies i = E_min) :
    boltzmann_weight β E_min ≤
    ∑ i : Fin N, boltzmann_weight β (energies i) := by
  obtain ⟨j, hj⟩ := h_exists
  calc boltzmann_weight β E_min
      = boltzmann_weight β (energies j) := by rw [hj]
    _ ≤ ∑ i : Fin N, boltzmann_weight β (energies i) :=
        Finset.single_le_sum (fun i _ => le_of_lt (boltzmann_weight_pos β (energies i)))
          (Finset.mem_univ j)

/-- Partition function is positive when N > 0. -/
theorem partition_function_pos {N : ℕ} (hN : 0 < N) (β : ℝ) (energies : Fin N → ℕ) :
    0 < ∑ i : Fin N, boltzmann_weight β (energies i) := by
  have : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
  apply Finset.sum_pos
  · intro i _; exact boltzmann_weight_pos β (energies i)
  · exact Finset.univ_nonempty

/-- Z ≤ N · exp(-β · E_min). -/
theorem partition_function_upper_bound {β : ℝ} (hβ : 0 < β) {N : ℕ} (_hN : 0 < N)
    (energies : Fin N → ℕ) (E_min : ℕ) (h_min : ∀ i, E_min ≤ energies i) :
    ∑ i : Fin N, boltzmann_weight β (energies i) ≤
    N * boltzmann_weight β E_min := by
  calc ∑ i : Fin N, boltzmann_weight β (energies i)
      ≤ ∑ _i : Fin N, boltzmann_weight β E_min := by
        apply Finset.sum_le_sum
        intro i _
        exact boltzmann_weight_anti hβ (h_min i)
    _ = N * boltzmann_weight β E_min := by
        simp [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]

/-- For x ∈ [0,1], -x·log(x) ≥ 0.
    Bridge: entropy non-negativity ↔ second law. -/
theorem neg_mul_log_nonneg {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    0 ≤ -(x * Real.log x) := by
  by_cases hx : x = 0
  · simp [hx]
  · have hx_pos : 0 < x := lt_of_le_of_ne hx0 (Ne.symm hx)
    have hlog : Real.log x ≤ 0 := Real.log_nonpos hx0 hx1
    have : x * Real.log x ≤ 0 := mul_nonpos_of_nonneg_of_nonpos (le_of_lt hx_pos) hlog
    linarith

end FreeEnergy

end ProofThermodynamics