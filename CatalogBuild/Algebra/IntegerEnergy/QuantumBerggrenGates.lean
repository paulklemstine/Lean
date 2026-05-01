/-! # CatalogBuild.Algebra.IntegerEnergy.QuantumBerggrenGates

Auto-generated from theorem catalog database.
Domain: Algebra/IntegerEnergy
Declarations: 48
-/

import Mathlib

/-- The determinant of a Pythagorean rotation matrix is a² + b². -/
theorem det_pythRotation (a b : ℤ) :
    Matrix.det (pythRotation a b) = a ^ 2 + b ^ 2 := by
  simp [pythRotation, Matrix.det_fin_two]; ring


/-- When a² + b² = c², det = c². -/
theorem det_pythRotation_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    Matrix.det (pythRotation a b) = c ^ 2 := by
  rw [det_pythRotation]; exact h


/-- The transpose of a Pythagorean rotation matrix. -/
theorem pythRotation_transpose (a b : ℤ) :
    (pythRotation a b)ᵀ = pythRotation a (-b) := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [pythRotation, Matrix.transpose_apply]


/-- Multiplication of Pythagorean rotation matrices = Gaussian integer multiplication. -/
theorem pythRotation_mul (a b c d : ℤ) :
    pythRotation a b * pythRotation c d = pythRotation (a*c - b*d) (a*d + b*c) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [pythRotation, Matrix.mul_apply, Fin.sum_univ_two]; ring


/-- Products of Pythagorean rotations preserve the Pythagorean property. -/
theorem pythRotation_product_pyth (a b c d r s : ℤ)
    (h1 : a^2 + b^2 = r^2) (h2 : c^2 + d^2 = s^2) :
    (a*c - b*d)^2 + (a*d + b*c)^2 = (r*s)^2 := by
  have := brahmagupta_fibonacci a b c d
  nlinarith [sq_nonneg r, sq_nonneg s]


/-- The identity rotation is pythRotation 1 0. -/
theorem pythRotation_one : pythRotation 1 0 = (1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [pythRotation]


/-- The inverse rotation: R(a,b)·R(a,-b) = (a²+b²)·I. -/
theorem pythRotation_inv (a b : ℤ) :
    pythRotation a b * pythRotation a (-b) = (a^2 + b^2) • (1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  rw [pythRotation_mul]
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [pythRotation, Matrix.smul_apply, Matrix.one_apply]; ring


/-- A Berggren gate is specified by a primitive Pythagorean triple. -/
structure BerggrenGate where
  a : ℤ
  b : ℤ
  c : ℤ
  pyth : a ^ 2 + b ^ 2 = c ^ 2
  c_pos : 0 < c


/-- The integer-scaled matrix representation. -/
def BerggrenGate.toMatrix (g : BerggrenGate) : Matrix (Fin 2) (Fin 2) ℤ :=
  pythRotation g.a g.b


/-- The determinant equals c². -/
theorem BerggrenGate.det_eq (g : BerggrenGate) :
    Matrix.det g.toMatrix = g.c ^ 2 := by
  simp [BerggrenGate.toMatrix, det_pythRotation, g.pyth]


/-- The root gate from (3,4,5). -/
def rootGate : BerggrenGate := ⟨3, 4, 5, by norm_num, by norm_num⟩


/-- Gate from (5,12,13). -/
def gate_5_12_13 : BerggrenGate := ⟨5, 12, 13, by norm_num, by norm_num⟩


/-- Gate from (8,15,17). -/
def gate_8_15_17 : BerggrenGate := ⟨8, 15, 17, by norm_num, by norm_num⟩


/-- Gate from (7,24,25). -/
def gate_7_24_25 : BerggrenGate := ⟨7, 24, 25, by norm_num, by norm_num⟩


/-- [Section: # CatalogBuild.Physics.Quantum.QuantumBerggrenGates
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 49] -/
def R_345 : Matrix (Fin 2) (Fin 2) ℤ := pythRotation 3 4


/-- R(3,4)² = R(-7, 24). The triple (7, 24, 25). -/
theorem R345_squared :
    pythRotation 3 4 * pythRotation 3 4 = pythRotation (-7) 24 := by
  rw [pythRotation_mul]; norm_num


/-- (-7)² + 24² = 625 = 25² -/
theorem R345_squared_pyth : (-7 : ℤ)^2 + 24^2 = 25^2 := by norm_num


/-- R(3,4)³ = R(-117, 44). -/
theorem R345_cubed :
    pythRotation 3 4 * pythRotation 3 4 * pythRotation 3 4 = pythRotation (-117) 44 := by
  rw [pythRotation_mul, pythRotation_mul]; norm_num


/-- 117² + 44² = 15625 = 125² -/
theorem R345_cubed_norm : (117 : ℤ)^2 + 44^2 = 125^2 := by norm_num


/-- Composing R(3,4)·R(5,12) = R(-33, 56). -/
theorem compose_345_51213 :
    pythRotation 3 4 * pythRotation 5 12 = pythRotation (-33) 56 := by
  rw [pythRotation_mul]; norm_num


/-- (-33)² + 56² = 4225 = 65² = (5·13)² -/
theorem compose_345_51213_pyth : (-33 : ℤ)^2 + 56^2 = 65^2 := by norm_num


/-- A triple (a,b,c) lies on the Pythagorean "light cone" a²+b²-c²=0. -/
def onLightCone (a b c : ℤ) : Prop := a^2 + b^2 - c^2 = 0


/-- The root triple (3,4,5) is on the light cone. -/
theorem root_on_light_cone : onLightCone 3 4 5 := by
  simp [onLightCone]; norm_num


/-- Berggren M₁ preserves the light cone. -/
theorem berggren_M1_preserves_cone (a b c : ℤ) (h : onLightCone a b c) :
    onLightCone (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) := by
  simp only [onLightCone] at *; nlinarith


/-- Berggren M₂ preserves the light cone. -/
theorem berggren_M2_preserves_cone (a b c : ℤ) (h : onLightCone a b c) :
    onLightCone (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) := by
  simp only [onLightCone] at *; nlinarith


/-- Berggren M₃ preserves the light cone. -/
theorem berggren_M3_preserves_cone (a b c : ℤ) (h : onLightCone a b c) :
    onLightCone (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) := by
  simp only [onLightCone] at *; nlinarith


/-- Pauli X matrix. -/
def pauli_X' : Matrix (Fin 2) (Fin 2) ℤ := !![0, 1; 1, 0]


/-- Pauli Z matrix. -/
def pauli_Z' : Matrix (Fin 2) (Fin 2) ℤ := !![1, 0; 0, -1]


/-- X conjugation inverts rotation: X · R(a,b) · X = R(a,-b). -/
theorem pauliX_conjugate_pythRot (a b : ℤ) :
    pauli_X' * pythRotation a b * pauli_X' = pythRotation a (-b) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [pauli_X', pythRotation, Matrix.mul_apply, Fin.sum_univ_two]; ring


/-- Z conjugation inverts rotation: Z · R(a,b) · Z = R(a,-b). -/
theorem pauliZ_conjugate_pythRot (a b : ℤ) :
    pauli_Z' * pythRotation a b * pauli_Z' = pythRotation a (-b) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [pauli_Z', pythRotation, Matrix.mul_apply, Fin.sum_univ_two]; ring


/-- Both Pauli gates conjugate R(a,b) to R(a,-b) — the inverse rotation! -/
theorem pauli_conjugation_inverts (a b : ℤ) :
    pauli_X' * pythRotation a b * pauli_X' =
    pauli_Z' * pythRotation a b * pauli_Z' := by
  rw [pauliX_conjugate_pythRot, pauliZ_conjugate_pythRot]


/-- The trace of a Pythagorean rotation is 2a. -/
theorem trace_pythRotation (a b : ℤ) :
    Matrix.trace (pythRotation a b) = 2 * a := by
  simp [pythRotation, Matrix.trace, Fin.sum_univ_two]; ring


/-- Trace of a composition. -/
theorem trace_composition (a₁ b₁ a₂ b₂ : ℤ) :
    Matrix.trace (pythRotation a₁ b₁ * pythRotation a₂ b₂) =
    2 * (a₁ * a₂ - b₁ * b₂) := by
  rw [pythRotation_mul, trace_pythRotation]


/-- The norm squared of a Gaussian integer pair. -/
def gaussNormSq (a b : ℤ) : ℤ := a^2 + b^2


/-- Norm is multiplicative under rotation composition. -/
theorem gaussNormSq_mul (a₁ b₁ a₂ b₂ : ℤ) :
    gaussNormSq (a₁*a₂ - b₁*b₂) (a₁*b₂ + b₁*a₂) =
    gaussNormSq a₁ b₁ * gaussNormSq a₂ b₂ := by
  simp [gaussNormSq]; ring


/-- Evaluate a single-qubit Berggren circuit. -/
def evalBerggrenCircuit1 : List BerggrenGate → Matrix (Fin 2) (Fin 2) ℤ
  | [] => 1
  | g :: gs => g.toMatrix * evalBerggrenCircuit1 gs


/-- The determinant of a Berggren circuit is the product of c² values. -/
theorem det_evalBerggrenCircuit1 (gs : List BerggrenGate) :
    Matrix.det (evalBerggrenCircuit1 gs) = (gs.map fun g => g.c ^ 2).prod := by
  induction gs with
  | nil => simp [evalBerggrenCircuit1, det_one]
  | cons g gs ih =>
    simp [evalBerggrenCircuit1, det_mul, BerggrenGate.det_eq, ih, List.map_cons, List.prod_cons]


/-- Circuit composition = Gaussian integer product. -/
theorem circuit_composition_formula (g₁ g₂ : BerggrenGate) :
    evalBerggrenCircuit1 [g₁, g₂] =
    pythRotation (g₁.a * g₂.a - g₁.b * g₂.b) (g₁.a * g₂.b + g₁.b * g₂.a) := by
  simp [evalBerggrenCircuit1, BerggrenGate.toMatrix, pythRotation_mul]


/-- The controlled Berggren gate (scaled by c). -/
def controlledBerggrenGate (g : BerggrenGate) : Matrix (Fin 4) (Fin 4) ℤ :=
  !![g.c, 0,   0,    0;
     0,   g.c, 0,    0;
     0,   0,   g.a, -g.b;
     0,   0,   g.b,  g.a]


/-- det of controlled Berggren gate = c⁴. -/
theorem det_controlledBerggrenGate (g : BerggrenGate) :
    Matrix.det (controlledBerggrenGate g) = g.c ^ 4 := by
  have h := g.pyth
  unfold controlledBerggrenGate
  norm_num [Matrix.det_succ_row_zero]
  ring_nf
  simp +decide [Fin.sum_univ_succ, Fin.succAbove]
  ring_nf
  nlinarith [h]


/-- A Pythagorean rotation over 𝔽_p = ZMod p. -/
def pythRotation_mod (a b : ℤ) (p : ℕ) : Matrix (Fin 2) (Fin 2) (ZMod p) :=
  !![((a : ℤ) : ZMod p), ((-b : ℤ) : ZMod p);
     ((b : ℤ) : ZMod p), ((a : ℤ) : ZMod p)]


/-- Berggren M₁ transformation on rotation parameters. -/
def berggren_rot_M1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)


/-- Berggren M₂ transformation. -/
def berggren_rot_M2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)


/-- Berggren M₃ transformation. -/
def berggren_rot_M3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


/-- Compute multiple levels of Berggren tree rotations. -/
def berggrenRotations : List (ℤ × ℤ × ℤ) :=
  let root := (3, 4, 5)
  let level1 := [berggren_rot_M1 3 4 5, berggren_rot_M2 3 4 5, berggren_rot_M3 3 4 5]
  root :: level1

#eval berggrenRotations


/-- Compute the first N powers of a rotation matrix, returning (a, b) components. -/
def rotationPowers (a₀ b₀ : ℤ) (N : ℕ) : List (ℤ × ℤ) :=
  let rec go (n : ℕ) (a b : ℤ) (acc : List (ℤ × ℤ)) : List (ℤ × ℤ) :=
    match n with
    | 0 => acc.reverse
    | n + 1 =>
      let a' := a₀ * a - b₀ * b
      let b' := a₀ * b + b₀ * a
      go n a' b' ((a', b') :: acc)
  go N a₀ b₀ [(a₀, b₀)]

#eval rotationPowers 3 4 6
-- (3+4i)^n: shows irrational angle fills out circle


/-- The "Cayley parameter" of a Pythagorean rotation:
τ = (a + bi)/c maps to the unit circle. -/
def cayleyParam (a b c : ℤ) : ℚ × ℚ :=
  ((a : ℚ) / (c : ℚ), (b : ℚ) / (c : ℚ))

#eval berggrenRotations.map fun (a, b, c) => cayleyParam a b c


/-- Compute the order of a matrix mod p (brute force, small p). -/
def matrixOrder (M : Matrix (Fin 2) (Fin 2) ℤ) (p : ℕ) (maxIter : ℕ := 200) : ℕ :=
  let M_mod := M.map (fun x => (x : ZMod p))
  let rec go (n : ℕ) (current : Matrix (Fin 2) (Fin 2) (ZMod p)) : ℕ :=
    match n with
    | 0 => maxIter
    | n + 1 =>
      if current = 1 then maxIter - n
      else go n (M_mod * current)
  go maxIter M_mod


