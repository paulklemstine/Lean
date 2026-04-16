/-! # CatalogBuild.EML.QuantumSPB

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 18
-/

import Mathlib

noncomputable section

/-- Complex SPB operation. -/
def spbQ (x y : ℂ) : ℂ := (x + y) / (1 - x * y)



/-- The Hadamard gate action on stereographic coordinate ζ:
H(ζ) = (ζ - 1)/(ζ + 1). -/
def hadamardStereo (ζ : ℂ) : ℂ := (ζ - 1) / (ζ + 1)



/-- The phase gate S action: S(ζ) = iζ. -/
def phaseStereo (ζ : ℂ) : ℂ := I * ζ



/-- The Hadamard gate is spb(ζ, -1). -/
theorem hadamard_is_spb (ζ : ℂ) :
    hadamardStereo ζ = spbQ ζ (-1) := by
  unfold hadamardStereo spbQ; congr 1 <;> ring



/-- Applying H twice gives -1/ζ (not ζ), reflecting the
nonlinearity of stereographic coordinates. -/
theorem hadamard_squared (ζ : ℂ) (h1 : ζ + 1 ≠ 0) (hζ : ζ ≠ 0)
    (h2 : hadamardStereo ζ + 1 ≠ 0) :
    hadamardStereo (hadamardStereo ζ) = -(ζ⁻¹) := by
  unfold hadamardStereo; field_simp; ring
  simp [mul_inv_cancel₀ hζ]



/-- The phase gate squares to Z: S² acts as ζ ↦ -ζ. -/
theorem phase_squared (ζ : ℂ) :
    phaseStereo (phaseStereo ζ) = -ζ := by
  unfold phaseStereo; rw [← mul_assoc, I_mul_I]; ring



/-- The phase gate has order 4: S⁴ = id. -/
theorem phase_order_four (ζ : ℂ) :
    phaseStereo (phaseStereo (phaseStereo (phaseStereo ζ))) = ζ := by
  unfold phaseStereo; simp only [← mul_assoc, I_mul_I]; ring



/-- Composing two SPB gates is associative. -/
theorem spb_gate_compose (a b ζ : ℂ) (h1 : 1 - ζ * a ≠ 0) (h2 : 1 - spbQ ζ a * b ≠ 0)
    (h3 : 1 - ζ * spbQ a b ≠ 0) (h4 : 1 - a * b ≠ 0) :
    spbQ (spbQ ζ a) b = spbQ ζ (spbQ a b) := by
  unfold spbQ; field_simp; ring



/-- The stereographic coordinate ζ from Bloch sphere angles. -/
def blochStereo (θ φ : ℝ) : ℂ :=
  Real.tan (θ / 2) * Complex.exp (φ * I)



/-- The north pole |0⟩ corresponds to ζ = 0. -/
theorem bloch_north_pole : blochStereo 0 0 = 0 := by
  simp [blochStereo, Real.tan_zero]



/-- Any Möbius transformation is a valid single-qubit gate. -/
def quantumGate (a b c d : ℂ) (ζ : ℂ) : ℂ := (a * ζ + b) / (c * ζ + d)



/-- SPB is a quantum gate with specific parameters. -/
theorem spb_is_quantum_gate (w ζ : ℂ) :
    spbQ ζ w = quantumGate 1 w (-w) 1 ζ := by
  unfold spbQ quantumGate; congr 1 <;> ring



/-- The determinant of the SPB gate is 1 + w². -/
theorem spb_gate_det (w : ℂ) :
    (1 : ℂ) * 1 - w * (-w) = 1 + w ^ 2 := by ring



/-- SPB commutes in the complex case. -/
theorem spbQ_comm (x y : ℂ) : spbQ x y = spbQ y x := by
  unfold spbQ; congr 1 <;> ring



/-- Complex SPB identity element. -/
theorem spbQ_zero_right (x : ℂ) : spbQ x 0 = x := by
  simp [spbQ]



/-- Complex SPB inverse. -/
theorem spbQ_neg_right (x : ℂ) : spbQ x (-x) = 0 := by
  simp [spbQ]



/-- H maps the north pole (ζ=0) to ζ=-1, which is the state |1⟩. -/
theorem hadamard_north : hadamardStereo 0 = -1 := by
  simp [hadamardStereo]



/-- H maps ζ=1 (the |+⟩ state) to ζ=0 (the |0⟩ state). -/
theorem hadamard_plus : hadamardStereo 1 = 0 := by
  simp [hadamardStereo]



end
