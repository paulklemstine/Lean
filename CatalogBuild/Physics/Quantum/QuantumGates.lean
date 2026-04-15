/-! # CatalogBuild.Physics.Quantum.QuantumGates

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 4
-/

import Mathlib

/-- A phase gate in the real channel is just multiplication by ±1 -/
def phase_gate (s : Bool) (x : ℤ) : ℤ :=
  if s then -x else x

/-
PROVIDED SOLUTION
Cases on the boolean s. If true, -(-x)=x. If false, x=x.
-/

theorem phase_gate_involutive (s : Bool) (x : ℤ) :
    phase_gate s (phase_gate s x) = x := by
  -- By definition of phase gate, we have phase_gate s x = if s then -x else x.
  unfold phase_gate
  aesop

/-! ## Beam Splitter (Complex Channel, n=2)

A beam splitter acts on a pair of modes (a, b) by a 2×2 unitary matrix.
In the Gaussian integer model, this is multiplication by a unit in ℤ[i].
The units of ℤ[i] are {1, -1, i, -i}, giving exactly 4 gates. -/

/-- The four units of ℤ[i] -/

def gaussian_units : List GaussianInt :=
  [⟨1, 0⟩, ⟨-1, 0⟩, ⟨0, 1⟩, ⟨0, -1⟩]

/-
PROBLEM
Each Gaussian unit has norm 1

PROVIDED SOLUTION
Expand the list membership, case split on each unit, compute norm by simp/decide.
-/

theorem gaussian_unit_norm (u : GaussianInt) (hu : u ∈ gaussian_units) :
    Zsqrtd.norm u = 1 := by
  unfold gaussian_units at hu; aesop;

/-! ## Polarization Rotation (Quaternionic Channel, n=4)

The group of unit quaternions SU(2) acts on ℝ³ by conjugation,
giving all spatial rotations SO(3). This is the double cover:
  1 → ℤ/2 → SU(2) → SO(3) → 1

For photons, this encodes polarization: the Poincaré sphere
of polarization states IS the quaternionic projective line.
-/

/-
PROBLEM
Quaternion norm is multiplicative

PROVIDED SOLUTION
Use map_mul since normSq is a MonoidWithZeroHom.
-/
