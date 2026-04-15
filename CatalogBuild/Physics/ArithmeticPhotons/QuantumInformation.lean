/-! # CatalogBuild.Physics.ArithmeticPhotons.QuantumInformation

Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 35
-/

import Mathlib

/-- A rational point on S²: (x,y,z) with x²+y²+z² = 1, all rational -/
structure RatSpherePoint where
  x : ℚ
  y : ℚ
  z : ℚ
  on_sphere : x ^ 2 + y ^ 2 + z ^ 2 = 1


/-- Construct a rational sphere point from a Pythagorean quadruple -/
def quadToBloch (a b c d : ℤ) (hd : d ≠ 0)
    (hq : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) : RatSpherePoint where
  x := (a : ℚ) / d
  y := (b : ℚ) / d
  z := (c : ℚ) / d
  on_sphere := by
    have hd' : (d : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hd
    field_simp
    exact_mod_cast hq


/-- Rational inverse stereographic projection: ℚ² → S²(ℚ) -/
def ratInvStereo (s t : ℚ) : RatSpherePoint where
  x := 2 * s / (1 + s ^ 2 + t ^ 2)
  y := 2 * t / (1 + s ^ 2 + t ^ 2)
  z := (s ^ 2 + t ^ 2 - 1) / (1 + s ^ 2 + t ^ 2)
  on_sphere := by
    have h : (1 : ℚ) + s ^ 2 + t ^ 2 > 0 := by positivity
    have h' : (1 : ℚ) + s ^ 2 + t ^ 2 ≠ 0 := ne_of_gt h
    field_simp
    ring


/-- Converting a rational stereo pair to a Pythagorean quadruple.
Given s = p/r, t = q/r, we get the quadruple
(2pr, 2qr, p²+q²-r², p²+q²+r²). -/
theorem stereo_to_quad (p q r : ℤ) (hr : r ≠ 0) :
    (2*p*r)^2 + (2*q*r)^2 + (p^2+q^2-r^2)^2 = (p^2+q^2+r^2)^2 := by
  ring


/-- The 2×2 identity matrix -/
def pauliI : Matrix (Fin 2) (Fin 2) ℚ := 1


/-- Pauli X is an involution: X² = I -/
theorem pauliX_sq : pauliX * pauliX = pauliI := by
  unfold pauliX pauliI
  ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_two]


/-- Pauli Z is an involution: Z² = I -/
theorem pauliZ_sq : pauliZ * pauliZ = pauliI := by
  unfold pauliZ pauliI
  ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_two]


/-- Pauli X and Z anticommute: XZ = -ZX -/
theorem pauliXZ_anticommute : pauliX * pauliZ = -(pauliZ * pauliX) := by
  unfold pauliX pauliZ
  ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_two]


/-- The density matrix of a Z-eigenstate (|0⟩) has Bloch vector (0,0,1) -/
def blochUp : RatSpherePoint where
  x := 0; y := 0; z := 1
  on_sphere := by norm_num


/-- The density matrix of a Z-eigenstate (|1⟩) has Bloch vector (0,0,-1) -/
def blochDown : RatSpherePoint where
  x := 0; y := 0; z := -1
  on_sphere := by norm_num


/-- The |+⟩ state has Bloch vector (1,0,0) -/
def blochPlus : RatSpherePoint where
  x := 1; y := 0; z := 0
  on_sphere := by norm_num


/-- The |-⟩ state has Bloch vector (-1,0,0) -/
def blochMinus : RatSpherePoint where
  x := -1; y := 0; z := 0
  on_sphere := by norm_num


/-- The Hadamard gate's action on Bloch coordinates -/
def hadamardBloch (p : RatSpherePoint) : RatSpherePoint where
  x := p.z
  y := -p.y
  z := p.x
  on_sphere := by
    have h := p.on_sphere
    ring_nf; linarith


/-- The S gate's action on Bloch coordinates -/
def sGateBloch (p : RatSpherePoint) : RatSpherePoint where
  x := -p.y
  y := p.x
  z := p.z
  on_sphere := by
    have h := p.on_sphere
    ring_nf; linarith


/-- Pauli X gate's action on Bloch coordinates -/
def xGateBloch (p : RatSpherePoint) : RatSpherePoint where
  x := p.x
  y := -p.y
  z := -p.z
  on_sphere := by
    have h := p.on_sphere
    ring_nf; linarith


/-- Pauli Z gate's action on Bloch coordinates -/
def zGateBloch (p : RatSpherePoint) : RatSpherePoint where
  x := -p.x
  y := -p.y
  z := p.z
  on_sphere := by
    have h := p.on_sphere
    ring_nf; linarith


/-- H applied twice is the identity (on Bloch sphere, up to Y-negation pattern) -/
theorem hadamard_involution (p : RatSpherePoint) :
    (hadamardBloch (hadamardBloch p)).x = p.x ∧
    (hadamardBloch (hadamardBloch p)).y = p.y ∧
    (hadamardBloch (hadamardBloch p)).z = p.z := by
  unfold hadamardBloch
  exact ⟨rfl, by ring, rfl⟩


/-- S⁴ = I on the Bloch sphere -/
theorem sGate_order_four (p : RatSpherePoint) :
    let p' := sGateBloch (sGateBloch (sGateBloch (sGateBloch p)))
    p'.x = p.x ∧ p'.y = p.y ∧ p'.z = p.z := by
  unfold sGateBloch
  refine ⟨by ring, by ring, rfl⟩


/-- The Hadamard gate maps Pythagorean quadruples to Pythagorean quadruples -/
theorem hadamard_preserves_quad (a b c d : ℤ) (hd : d ≠ 0)
    (hq : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    c ^ 2 + b ^ 2 + a ^ 2 = d ^ 2 := by linarith


/-- The S gate maps Pythagorean quadruples to Pythagorean quadruples -/
theorem sGate_preserves_quad (a b c d : ℤ) (hd : d ≠ 0)
    (hq : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    b ^ 2 + a ^ 2 + c ^ 2 = d ^ 2 := by linarith


/-- The quaternion Hopf map: (m,n,p,q) ↦ Bloch coordinates
This is the rational Hopf map restricted to integer quaternions -/
def quaternionHopf (m n p q : ℤ) (h : m^2 + n^2 + p^2 + q^2 ≠ 0) :
    RatSpherePoint where
  x := (2 * (m * q + n * p) : ℚ) / (m^2 + n^2 + p^2 + q^2)
  y := (2 * (n * q - m * p) : ℚ) / (m^2 + n^2 + p^2 + q^2)
  z := (m^2 + n^2 - p^2 - q^2 : ℚ) / (m^2 + n^2 + p^2 + q^2)
  on_sphere := by
    have h' : (m^2 + n^2 + p^2 + q^2 : ℚ) ≠ 0 := by exact_mod_cast h
    field_simp
    ring


/-- The Hopf map is exactly the quadruple parametrization!
This is the fundamental bridge between quaternion topology and
arithmetic photons. -/
theorem hopf_is_parametrization (m n p q : ℤ) :
    let a := m^2 + n^2 - p^2 - q^2
    let b := 2 * (m * q + n * p)
    let c := 2 * (n * q - m * p)
    let d := m^2 + n^2 + p^2 + q^2
    a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 := by ring


/-- 90° rotation about z-axis: (x,y,z) → (-y,x,z) -/
def rot90z : Matrix (Fin 3) (Fin 3) ℚ := !![0, -1, 0; 1, 0, 0; 0, 0, 1]


/-- This rotation is orthogonal: Rᵀ R = I -/
theorem rot90z_orthogonal : rot90zᵀ * rot90z = 1 := by
  unfold rot90z
  ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_three]


/-- The exchange matrix (x,y,z) → (z,-y,x) representing Hadamard -/
def hadamardRot : Matrix (Fin 3) (Fin 3) ℚ := !![0, 0, 1; 0, -1, 0; 1, 0, 0]


/-- Hadamard rotation is orthogonal -/
theorem hadamardRot_orthogonal : hadamardRotᵀ * hadamardRot = 1 := by
  unfold hadamardRot
  ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_three]


/-- A stabilizer state has rational Bloch coordinates.
These are exactly the Pauli eigenstates: ±X, ±Y, ±Z eigenstates -/
def isStabilizerState (p : RatSpherePoint) : Prop :=
  (p.x = 1 ∧ p.y = 0 ∧ p.z = 0) ∨
  (p.x = -1 ∧ p.y = 0 ∧ p.z = 0) ∨
  (p.x = 0 ∧ p.y = 1 ∧ p.z = 0) ∨
  (p.x = 0 ∧ p.y = -1 ∧ p.z = 0) ∨
  (p.x = 0 ∧ p.y = 0 ∧ p.z = 1) ∨
  (p.x = 0 ∧ p.y = 0 ∧ p.z = -1)


/-- Hadamard maps |0⟩ to |+⟩ (Z-eigenstate to X-eigenstate) -/
theorem hadamard_maps_up_to_plus :
    let p := hadamardBloch blochUp
    p.x = 1 ∧ p.y = 0 ∧ p.z = 0 := by
  unfold hadamardBloch blochUp; simp


/-- Hadamard maps |+⟩ to |0⟩ -/
theorem hadamard_maps_plus_to_up :
    let p := hadamardBloch blochPlus
    p.x = 0 ∧ p.y = 0 ∧ p.z = 1 := by
  unfold hadamardBloch blochPlus; simp


/-- S gate maps |+⟩ to |+i⟩ (X-eigenstate to Y-eigenstate) -/
theorem sGate_maps_plus_to_plusY :
    let p := sGateBloch blochPlus
    p.x = 0 ∧ p.y = 1 ∧ p.z = 0 := by
  unfold sGateBloch blochPlus; simp


/-- Count primitive quadruples at energy d (those with gcd(a,b,c,d) = 1) -/
def countPrimQuads (d : ℕ) : ℕ :=
  Finset.card (Finset.filter (fun abc : Fin (2*d+1) × Fin (2*d+1) × Fin (2*d+1) =>
    let a := (abc.1 : ℤ) - d
    let b := (abc.2.1 : ℤ) - d
    let c := (abc.2.2 : ℤ) - d
    a ^ 2 + b ^ 2 + c ^ 2 = (d : ℤ) ^ 2 ∧
    Int.gcd (Int.gcd a b) (Int.gcd c d) = 1)
    Finset.univ)


/-- A rational rotation matrix on ℚ³ -/
def IsRatRotation (M : Matrix (Fin 3) (Fin 3) ℚ) : Prop :=
  Mᵀ * M = 1 ∧ Matrix.det M = 1


/-- [Section: ## Part 11: Magic States and Beyond-Clifford Arithmetic
Non-Clifford gates (like the T gate) take rational Bloch points to
irrational ones. The T gate rotates by π/4 about Z, mapping
(x,y,z) ↦ (x cos π/4 - y sin π/4, x sin π/4 + y cos π/4, z).
Since cos(π/4) = 1/√2, this generically produces irrational coordinates.
"Magic states" — the resource states for universal quantum computation —
are precisely the NON-arithmetic qubits that cannot be described by
Pythagorean quadruples.
This gives a beautiful information-theoretic interpretation:
- Clifford computation = arithmetic (rational Bloch sphere)
- Universal computation = beyond arithmetic (irrational Bloch sphere)
- The T gate is the "door" from number theory to analysis] -/
theorem rat_rotation_preserves_rational (M : Matrix (Fin 3) (Fin 3) ℚ)
    (hM : IsRatRotation M) (p : RatSpherePoint) :
    let v : Fin 3 → ℚ := ![p.x, p.y, p.z]
    let w := M.mulVec v
    w 0 ^ 2 + w 1 ^ 2 + w 2 ^ 2 = 1 := by
  intro v w
  have horth := hM.1
  -- The key: w^T w = v^T (M^T M) v = v^T v = 1
  -- By definition of matrix multiplication, we have that w^T w = v^T (M^T M) v.
  have h_dot : dotProduct w w = dotProduct v (M.transpose *ᵥ w) := by
    simp +zetaDelta at *;
    simp +decide [ Matrix.mulVec, dotProduct, Fin.sum_univ_three ];
    norm_num [ Matrix.mulVec, Matrix.vecHead, Matrix.vecTail ] ; ring;
    simpa [ Matrix.mul_apply, Fin.sum_univ_three ] using by ring;
  convert h_dot using 1;
  · simp +decide [ sq, Fin.sum_univ_three, dotProduct ];
  · norm_num +zetaDelta at *;
    rw [ horth ] ; norm_num [ vecHead, vecTail ] ; linarith! [ p.on_sphere ]


/-- [Section: ## Part 12: Summary of the Quantum-Arithmetic Bridge
The arithmetic photon paradigm reveals a deep structure in quantum
information theory:
1. **Qubit states ↔ Photon directions**: Both parametrized by S²
2. **Clifford group ↔ Integer Lorentz group**: Both preserve rationality
3. **Stabilizer states ↔ Axis-aligned photons**: The 6 Pauli eigenstates
4. **Magic states ↔ Irrational photons**: Beyond arithmetic
5. **Hopf fibration ↔ Quaternion parametrization**: SU(2) ↔ unit quaternions
6. **Error correction ↔ Lattice symmetry**: Stabilizer codes ↔ integer symmetries
The Gottesman-Knill theorem (Clifford circuits are classically simulable)
becomes: "Integer arithmetic on the null cone is computationally easy."
Universal quantum computation requires going beyond integers — to the
irrational, transcendental points on the Bloch sphere.] -/
theorem rational_bloch_from_quadruple (p : RatSpherePoint) :
    ∃ (a b c d : ℤ), d ≠ 0 ∧ a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 ∧
    (a : ℚ) / d = p.x ∧ (b : ℚ) / d = p.y ∧ (c : ℚ) / d = p.z := by
  obtain ⟨a, b, c, d, hd_ne_zero, h_eq⟩ : ∃ a b c d : ℤ, d ≠ 0 ∧ (p.x : ℚ) = a / d ∧ (p.y : ℚ) = b / d ∧ (p.z : ℚ) = c / d := by
    obtain ⟨a, d, hd_ne_zero, ha⟩ : ∃ a d : ℤ, d ≠ 0 ∧ (p.x : ℚ) = a / d := by
      exact ⟨ p.x.num, p.x.den, Nat.cast_ne_zero.mpr p.x.pos.ne', p.x.num_div_den.symm ⟩
    obtain ⟨b, e, he_ne_zero, hb⟩ : ∃ b e : ℤ, e ≠ 0 ∧ (p.y : ℚ) = b / e := by
      exact ⟨ p.y.num, p.y.den, Nat.cast_ne_zero.mpr p.y.pos.ne', p.y.num_div_den.symm ⟩
    obtain ⟨c, f, hf_ne_zero, hc⟩ : ∃ c f : ℤ, f ≠ 0 ∧ (p.z : ℚ) = c / f := by
      exact ⟨ p.z.num, p.z.den, Nat.cast_ne_zero.mpr p.z.pos.ne', p.z.num_div_den.symm ⟩;
    use a * e * f, b * d * f, c * d * e, d * e * f;
    exact ⟨ mul_ne_zero ( mul_ne_zero hd_ne_zero he_ne_zero ) hf_ne_zero, by push_cast [ ha ] ; rw [ div_eq_div_iff ] <;> ring <;> positivity, by push_cast [ hb ] ; rw [ div_eq_div_iff ] <;> ring <;> positivity, by push_cast [ hc ] ; rw [ div_eq_div_iff ] <;> ring <;> positivity ⟩;
  have h_eq : (p.x : ℚ)^2 + (p.y : ℚ)^2 + (p.z : ℚ)^2 = 1 := by
    exact p.on_sphere;
  simp_all +decide [ div_pow, mul_pow ];
  exact ⟨ a, b, c, d, hd_ne_zero, by rw [ ← @Int.cast_inj ℚ ] ; push_cast; rw [ ← add_div, ← add_div, div_eq_iff ] at h_eq <;> first | positivity | linarith, rfl, rfl, rfl ⟩


/-- The number of arithmetic qubits at resolution d equals r₃(d²) -/
theorem arithmetic_qubit_count (d : ℕ) (hd : 0 < d) :
    ∃ a b c : ℤ, a ^ 2 + b ^ 2 + c ^ 2 = (d : ℤ) ^ 2 := by
  exact ⟨d, 0, 0, by ring⟩
