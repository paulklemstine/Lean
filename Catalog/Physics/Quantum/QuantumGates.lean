import Mathlib

/-! # CatalogBuild.Physics.Quantum.QuantumGates

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 4
-/

/-- A phase gate in the real channel is just multiplication by ±1 -/
def phase_gate (s : Bool) (x : ℤ) : ℤ :=
  if s then -x else x

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumGates
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 4] -/
theorem phase_gate_involutive (s : Bool) (x : ℤ) :
    phase_gate s (phase_gate s x) = x := by
  -- By definition of phase gate, we have phase_gate s x = if s then -x else x.
  unfold phase_gate
  aesop

/-- The four units of ℤ[i] -/
def gaussian_units : List GaussianInt :=
  [⟨1, 0⟩, ⟨-1, 0⟩, ⟨0, 1⟩, ⟨0, -1⟩]

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumGates
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 4] -/
theorem gaussian_unit_norm (u : GaussianInt) (hu : u ∈ gaussian_units) :
    Zsqrtd.norm u = 1 := by
  unfold gaussian_units at hu; aesop;