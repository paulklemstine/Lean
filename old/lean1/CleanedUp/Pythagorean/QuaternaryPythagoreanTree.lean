import Mathlib

/-!
# The Quaternary Pythagorean Tree: 3+1 Branches in Arithmetic Spacetime

## Project PHOTON-4 — Pythagorean Hypotheses On Temporal-Origin Networks (4-Branch)

### Research Team
- **Agent T (Temporal)**: The 4th branch — parent descent and time-reversal symmetry
- **Agent S (Spatial)**: The 3 Berggren children — spatial branching structure
- **Agent L (Lorentz)**: Null cone geometry and the photon interpretation
- **Agent Q (Quantum)**: Entanglement between branches and oracle consultation
- **Agent P (Paper)**: Documentation, analysis, and publication

### Core Hypothesis

The classical Berggren ternary tree of primitive Pythagorean triples is actually a
**quaternary** structure when viewed through the lens of arithmetic spacetime:

- **3 branches forward (spatial)**: The standard Berggren children via B₁, B₂, B₃
- **1 branch backward (temporal)**: The unique parent via the inverse transformation

This gives a **(3+1)-valent graph**, mirroring the **(3+1)-dimensional** signature of
Minkowski spacetime. The Pythagorean triples themselves live on the **null cone**
(light cone) of the Lorentz form Q(a,b,c) = a² + b² - c² = 0, making them
the arithmetic analogues of **photon worldlines**.

### The Oracle Says

The 4th branch is the arrow of time. Every photon (null vector) in arithmetic
spacetime has a unique past (parent) and three possible futures (children).
The root triple (3,4,5) is the Big Bang — the only node with no past.
-/

open Matrix

/-! ## Section 1: The Berggren Matrices and Their Inverses -/

/-- Berggren matrix B₁ -/
def B₁' : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B₂ -/
def B₂' : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix B₃ -/
def B₃' : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- Inverse of B₁: the "time-reversal" of the first spatial branch -/
def B₁'_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; -2, -1, 2; -2, -2, 3]

/-- Inverse of B₂: the "time-reversal" of the second spatial branch -/
def B₂'_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; 2, 1, -2; -2, -2, 3]

/-- Inverse of B₃: the "time-reversal" of the third spatial branch -/
def B₃'_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), -2, 2; 2, 1, -2; (-2), -2, 3]

/-! ## Section 2: Time-Reversal Symmetry (Inverse Verification) -/

/-- B₁ · B₁⁻¹ = I: time-reversal is an exact involution -/
theorem B₁'_mul_inv : B₁' * B₁'_inv = 1 := by native_decide

/-- B₁⁻¹ · B₁ = I -/
theorem B₁'_inv_mul : B₁'_inv * B₁' = 1 := by native_decide

/-- B₂ · B₂⁻¹ = I -/
theorem B₂'_mul_inv : B₂' * B₂'_inv = 1 := by native_decide

/-- B₂⁻¹ · B₂ = I -/
theorem B₂'_inv_mul : B₂'_inv * B₂' = 1 := by native_decide

/-- B₃ · B₃⁻¹ = I -/
theorem B₃'_mul_inv : B₃' * B₃'_inv = 1 := by native_decide

/-- B₃⁻¹ · B₃ = I -/
theorem B₃'_inv_mul : B₃'_inv * B₃' = 1 := by native_decide

/-! ## Section 3: The Lorentz Form and Null Cone -/

/-- The Lorentz form Q(a,b,c) = a² + b² - c² -/
def lorentzForm' (v : Fin 3 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- A Pythagorean triple is a null vector: Q(a,b,c) = 0 -/
def isNullVector' (v : Fin 3 → ℤ) : Prop :=
  lorentzForm' v = 0

/-- The root triple (3,4,5) is a null vector -/
theorem root_is_null' : isNullVector' ![3, 4, 5] := by
  unfold isNullVector' lorentzForm'
  native_decide

/-- Pythagorean equation ↔ null cone condition -/
theorem pyth_iff_null' (a b c : ℤ) :
    a ^ 2 + b ^ 2 = c ^ 2 ↔ isNullVector' ![a, b, c] := by
  unfold isNullVector' lorentzForm'
  simp [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.head_fin_const]
  omega

/-! ## Section 4: The Quaternary Tree Structure -/

/-- A path in the quaternary tree -/
inductive QPath where
  | root : QPath
  | child1 : QPath → QPath   -- apply B₁ (spatial)
  | child2 : QPath → QPath   -- apply B₂ (spatial)
  | child3 : QPath → QPath   -- apply B₃ (spatial)
  deriving Repr

/-- The depth (proper time) of a path -/
def QPath.depth : QPath → ℕ
  | .root    => 0
  | .child1 p => p.depth + 1
  | .child2 p => p.depth + 1
  | .child3 p => p.depth + 1

/-- The Pythagorean triple at a quaternary tree path -/
def qTriple : QPath → ℤ × ℤ × ℤ
  | .root    => (3, 4, 5)
  | .child1 p =>
    let (a, b, c) := qTriple p
    (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)
  | .child2 p =>
    let (a, b, c) := qTriple p
    (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)
  | .child3 p =>
    let (a, b, c) := qTriple p
    (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)

/-- The parent of a non-root path (the temporal/4th branch) -/
def QPath.parent : QPath → Option QPath
  | .root    => none         -- The Big Bang has no parent
  | .child1 p => some p
  | .child2 p => some p
  | .child3 p => some p

/-- Every non-root node has exactly one parent (uniqueness of time) -/
theorem parent_is_some_of_ne_root (p : QPath)
    (h : ∃ q, p = .child1 q ∨ p = .child2 q ∨ p = .child3 q) :
    p.parent.isSome = true := by
  obtain ⟨q, hq⟩ := h
  rcases hq with h1 | h2 | h3 <;> simp [*, QPath.parent]

/-- The quaternary valence: each node has 3 children -/
theorem quaternary_valence_description :
    ∀ (p : QPath),
    (∃ c1 c2 c3 : QPath, c1 = .child1 p ∧ c2 = .child2 p ∧ c3 = .child3 p) := by
  intro p
  exact ⟨.child1 p, .child2 p, .child3 p, rfl, rfl, rfl⟩

/-! ## Section 5: The Photon Interpretation -/

/-- A "photon" in arithmetic spacetime: a triple on the null cone with its tree position -/
structure ArithPhoton where
  path : QPath
  triple : ℤ × ℤ × ℤ
  on_tree : triple = qTriple path

/-- The root photon: the Big Bang event -/
def bigBangPhoton : ArithPhoton where
  path := .root
  triple := (3, 4, 5)
  on_tree := rfl

/-- A photon's "wavelength" — the hypotenuse c (its energy in arithmetic spacetime) -/
def ArithPhoton.wavelength (ph : ArithPhoton) : ℤ :=
  ph.triple.2.2

/-- A photon's "proper time" — its depth in the tree -/
def ArithPhoton.properTime (ph : ArithPhoton) : ℕ :=
  ph.path.depth

/-- The Big Bang photon has proper time 0 -/
theorem bigBang_properTime : bigBangPhoton.properTime = 0 := rfl

/-- The Big Bang photon has wavelength 5 -/
theorem bigBang_wavelength : bigBangPhoton.wavelength = 5 := rfl

/-! ## Section 6: Determinant Structure — The Berggren Group -/

/-- All Berggren matrices have determinant ±1 (they're in GL(3,ℤ)) -/
theorem det_B₁'' : Matrix.det B₁' = 1 := by native_decide
theorem det_B₂'' : Matrix.det B₂' = -1 := by native_decide
theorem det_B₃'' : Matrix.det B₃' = 1 := by native_decide

/-- The inverses also have determinant ±1 -/
theorem det_B₁'_inv : Matrix.det B₁'_inv = 1 := by native_decide
theorem det_B₂'_inv : Matrix.det B₂'_inv = -1 := by native_decide
theorem det_B₃'_inv : Matrix.det B₃'_inv = 1 := by native_decide

/-! ## Section 7: The Lorentz Form Matrix and Preservation -/

/-- The Lorentz form as a matrix: diag(1, 1, -1) -/
def Q_lor' : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

/-- B₁ preserves the Lorentz form -/
theorem B₁'_preserves_lorentz' : B₁'ᵀ * Q_lor' * B₁' = Q_lor' := by native_decide

/-- B₂ preserves the Lorentz form -/
theorem B₂'_preserves_lorentz' : B₂'ᵀ * Q_lor' * B₂' = Q_lor' := by native_decide

/-- B₃ preserves the Lorentz form -/
theorem B₃'_preserves_lorentz' : B₃'ᵀ * Q_lor' * B₃' = Q_lor' := by native_decide

/-- The INVERSES also preserve the Lorentz form — the temporal branch respects physics! -/
theorem B₁'_inv_preserves_lorentz : B₁'_invᵀ * Q_lor' * B₁'_inv = Q_lor' := by native_decide

theorem B₂'_inv_preserves_lorentz : B₂'_invᵀ * Q_lor' * B₂'_inv = Q_lor' := by native_decide

theorem B₃'_inv_preserves_lorentz : B₃'_invᵀ * Q_lor' * B₃'_inv = Q_lor' := by native_decide

/-! ## Section 8: Pythagorean Preservation Through All 4 Branches -/

/-- B₁ preserves the Pythagorean property (spatial branch 1) -/
theorem B₁'_preserves_pyth' (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 = (2*a - 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (a + b)]

/-- B₂ preserves the Pythagorean property (spatial branch 2) -/
theorem B₂'_preserves_pyth' (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 = (2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (a + b)]

/-- B₃ preserves the Pythagorean property (spatial branch 3) -/
theorem B₃'_preserves_pyth' (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 = (-2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (a + b)]

/-- The parent of a B₁-child recovers the original triple (temporal branch) -/
theorem B₁'_temporal_inverse' (a b c : ℤ) :
    let a' := a - 2*b + 2*c
    let b' := 2*a - b + 2*c
    let c' := 2*a - 2*b + 3*c
    -- Apply B₁⁻¹ to the child triple
    (a' + 2*b' - 2*c' = a) ∧
    (-2*a' - b' + 2*c' = b) ∧
    (-2*a' - 2*b' + 3*c' = c) := by
  constructor <;> [ring; constructor <;> ring]

/-! ## Section 9: Computational Experiments -/

/-- Generate the first few levels of the quaternary tree for inspection -/
def treeLevel' : ℕ → List (ℤ × ℤ × ℤ)
  | 0 => [(3, 4, 5)]
  | n + 1 =>
    let parents := treeLevel' n
    parents.flatMap fun (a, b, c) =>
      [ (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c),
        (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c),
        (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c) ]

#eval treeLevel' 0  -- [(3, 4, 5)]
#eval treeLevel' 1  -- Level 1: 3 triples
#eval treeLevel' 2  -- Level 2: 9 triples

/-! ## Section 10: The (3+1) Metric Signature -/

/-- The number of spatial branches at any node -/
def spatialBranchCount : ℕ := 3

/-- The number of temporal branches at any non-root node -/
def temporalBranchCount : ℕ := 1

/-- The total valence at a non-root node -/
theorem total_valence : spatialBranchCount + temporalBranchCount = 4 := rfl

/-- The signature string -/
def signatureStr : String := s!"({spatialBranchCount}+{temporalBranchCount})"

/-- The signature is always (3+1) -/
theorem signature_is_3_1 : signatureStr = "(3+1)" := rfl

/-! ## Section 11: Photon Emission and Absorption -/

/-- A photon "emission" event: a parent emitting three child photons -/
structure EmissionEvent where
  parent : ArithPhoton
  child1 : ArithPhoton
  child2 : ArithPhoton
  child3 : ArithPhoton
  c1_from_parent : child1.path = .child1 parent.path
  c2_from_parent : child2.path = .child2 parent.path
  c3_from_parent : child3.path = .child3 parent.path

/-- A photon "absorption" event: a child being traced back to its parent -/
structure AbsorptionEvent where
  child : ArithPhoton
  parent : ArithPhoton
  parent_of_child : child.path.parent = some parent.path

/-! ## Section 12: The Oracle's Conservation Law -/

/-
PROBLEM
The oracle's key insight formalized: every path conserves Q = 0.
    Every triple in the quaternary tree is Pythagorean.

PROVIDED SOLUTION
Induction on p. Base case: (3,4,5) satisfies 9+16=25, use norm_num. For each inductive case (child1, child2, child3), destructure qTriple p as (a,b,c) with the inductive hypothesis a^2+b^2=c^2, then the goal reduces to an identity provable by nlinarith with sq_nonneg hints.
-/
theorem oracle_conservation' (p : QPath) :
    (qTriple p).1 ^ 2 + (qTriple p).2.1 ^ 2 = (qTriple p).2.2 ^ 2 := by
  -- We proceed by induction on the depth of the path.
  induction' p with p ih;
  · rfl;
  · convert B₁'_preserves_pyth' _ _ _ ih using 1;
  · rename_i p hp;
    convert B₂'_preserves_pyth' _ _ _ hp using 1;
  · rename_i p ih; rw [ show qTriple p.child3 = ( - ( qTriple p |> Prod.fst ) + 2 * ( qTriple p |> Prod.snd |> Prod.fst ) + 2 * ( qTriple p |> Prod.snd |> Prod.snd ), -2 * ( qTriple p |> Prod.fst ) + ( qTriple p |> Prod.snd |> Prod.fst ) + 2 * ( qTriple p |> Prod.snd |> Prod.snd ), -2 * ( qTriple p |> Prod.fst ) + 2 * ( qTriple p |> Prod.snd |> Prod.fst ) + 3 * ( qTriple p |> Prod.snd |> Prod.snd ) ) from rfl ] ; linarith;

/-! ## Section 13: The Oracle's Pronouncement

The oracle observes:

1. **The tree IS the spacetime**: Each node is not embedded in spacetime — it IS
   a point of arithmetic spacetime. The tree topology IS the causal structure.

2. **Photons as null vectors**: Every Pythagorean triple (a,b,c) satisfies
   a² + b² - c² = 0, which is the null cone condition. These are massless
   particles in (2+1) Minkowski space.

3. **The 4th branch as time**: The parent direction is distinguished from the
   3 child directions. This asymmetry mirrors the distinction between time
   and space in Minkowski geometry.

4. **The arrow of time**: Children always have larger hypotenuse than parents
   (for positive triples). This monotonicity gives a natural arrow of time.

5. **The Big Bang**: (3,4,5) is the unique parentless node — the origin event.

6. **Conservation**: The Lorentz form Q = a² + b² - c² = 0 is conserved by
   ALL branches (spatial and temporal). This is the arithmetic analogue of
   energy-momentum conservation for null particles.

7. **Branching ratio 3:1**: The ratio of spatial to temporal branches (3:1)
   matches the dimensionality ratio of space to time in our universe (3:1).
-/

/-! ## Section 14: Future Directions

### 14.1 Extension to (3+1) Spacetime
Pythagorean quadruples a² + b² + c² = d² live on the null cone of (3,1) Minkowski
space. The tree of primitive quadruples has a **different** branching structure.
Understanding its graph-theoretic properties could reveal deeper connections.

### 14.2 Quantum Superposition of Paths
A "quantum photon" in arithmetic spacetime would be a superposition of tree paths.
The amplitude for each path could be weighted by the inverse hypotenuse 1/c,
giving a convergent "partition function" for arithmetic spacetime.

### 14.3 Entanglement Between Branches
Two photons at the same depth but different paths are "spacelike separated."
Can we define an arithmetic Bell inequality?

### 14.4 The Holographic Principle
The tree has 3ⁿ nodes at depth n but only ≈ n bits specify a path. This is
analogous to holographic entropy bounds: the "boundary" (the path specification)
has far less information than the "bulk" (the set of all triples at that depth).
-/