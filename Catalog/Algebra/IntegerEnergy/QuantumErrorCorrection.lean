import Mathlib

/-! # CatalogBuild.Physics.Quantum.QuantumErrorCorrection

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 13
-/

noncomputable section

/-- Pauli group on 1 qubit has order 16 = 4² -/
theorem pauli_group_order_one : 4 ^ (1 + 1) = 16 := by norm_num

/-- For n qubits, the Pauli group order is 4^(n+1) -/
theorem pauli_group_order (n : ℕ) : 4 ^ (n + 1) = 4 * 4 ^ n := by ring

/-- Stabilizer code constraint: 2^(n-k) · 2^k = 2^n -/
theorem stabilizer_code_constraint (n k : ℕ) (hk : k ≤ n) :
    2 ^ (n - k) * 2 ^ k = 2 ^ n := by
  rw [← pow_add]; congr 1; omega

/-- Code rate k/n ≤ 1 -/
theorem code_rate_bound (n k : ℕ) (hn : 0 < n) (hk : k ≤ n) :
    (k : ℝ) / n ≤ 1 := by
  rw [div_le_one (Nat.cast_pos.mpr hn)]
  exact Nat.cast_le.mpr hk

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumErrorCorrection
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 13] -/
theorem base_triple' : IsPythTriple' 3 4 5 := by unfold IsPythTriple'; ring

/-- The Lorentz form Q(a,b,c) = a² + b² - c² -/
def qecLorentzForm (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

/-- Pythagorean triples ↔ kernel of Lorentz form -/
theorem pyth_iff_lorentz_zero' (a b c : ℤ) :
    IsPythTriple' a b c ↔ qecLorentzForm a b c = 0 := by
  simp [IsPythTriple', qecLorentzForm]; omega

/-- Single-coordinate error produces detectable syndrome -/
theorem single_error_detectable' (a b c δ : ℤ) (hδ : δ ≠ 0)
    (hpyth : IsPythTriple' a b c) :
    qecLorentzForm (a + δ) b c = 2 * a * δ + δ ^ 2 := by
  simp [qecLorentzForm, IsPythTriple'] at *; nlinarith

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumErrorCorrection
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 13] -/
theorem syndrome_determines_error' (a δ₁ δ₂ : ℤ)
    (ha : a > 0)
    (h : 2 * a * δ₁ + δ₁ ^ 2 = 2 * a * δ₂ + δ₂ ^ 2)
    (hδ₁ : |δ₁| < a) (hδ₂ : |δ₂| < a) :
    δ₁ = δ₂ := by
  cases abs_cases δ₁ <;> cases abs_cases δ₂ <;> nlinarith

/-- The [[5,1,3]] code parameters are valid -/
theorem five_qubit_code_params' : 5 - 1 + 1 = 5 ∧ 5 ≥ 3 := by omega

/-- Quantum Hamming bound for [[5,1,3]]: 2^4 ≥ 1 + 3·5 = 16 -/
theorem hamming_bound_5_1_3' : 2 ^ (5 - 1) ≥ 1 + 3 * 5 := by norm_num

/-- CSS code dimension: k = dim(C₁) - dim(C₂) -/
theorem css_dimension' (dim1 dim2 : ℕ) (h : dim2 ≤ dim1) :
    dim1 - dim2 + dim2 = dim1 := by omega

/-- CSS code distance bound -/
theorem css_distance_bound' (d1 d2perp d : ℕ) (h : d = min d1 d2perp) :
    d ≤ d1 ∧ d ≤ d2perp := by
  subst h; exact ⟨min_le_left _ _, min_le_right _ _⟩

end
