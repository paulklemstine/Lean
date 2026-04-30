import Mathlib

/-! # CatalogBuild.Pythagorean.TreeFactoring.QuaternaryPythagoreanTree

Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 50
-/

/-- Inverse of B₁: the "time-reversal" of the first spatial branch -/
def B₁'_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; -2, -1, 2; -2, -2, 3]

/-- Inverse of B₂: the "time-reversal" of the second spatial branch -/
def B₂'_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; 2, 1, -2; -2, -2, 3]

/-- Inverse of B₃: the "time-reversal" of the third spatial branch -/
def B₃'_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), -2, 2; 2, 1, -2; (-2), -2, 3]

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

/-- All Berggren matrices have determinant ±1 (they're in GL(3,ℤ)) -/
theorem det_B₁'' : Matrix.det B₁' = 1 := by native_decide

/-- [Section: # CatalogBuild.Pythagorean.TreeFactoring.QuaternaryPythagoreanTree
Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 50] -/
theorem det_B₂'' : Matrix.det B₂' = -1 := by native_decide

/-- [Section: # CatalogBuild.Pythagorean.TreeFactoring.QuaternaryPythagoreanTree
Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 50] -/
theorem det_B₃'' : Matrix.det B₃' = 1 := by native_decide

/-- The inverses also have determinant ±1 -/
theorem det_B₁'_inv : Matrix.det B₁'_inv = 1 := by native_decide

theorem det_B₂'_inv : Matrix.det B₂'_inv = -1 := by native_decide

theorem det_B₃'_inv : Matrix.det B₃'_inv = 1 := by native_decide

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

/-- The number of spatial branches at any node -/
def spatialBranchCount : ℕ := 3

/-- The number of temporal branches at any non-root node -/
def temporalBranchCount : ℕ := 1

/-- The total valence at a non-root node -/
theorem total_valence : spatialBranchCount + temporalBranchCount = 4 := rfl

/-- The signature is always (3+1) -/
theorem signature_is_3_1 : signatureStr = "(3+1)" := rfl

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

theorem oracle_conservation' (p : QPath) :
    (qTriple p).1 ^ 2 + (qTriple p).2.1 ^ 2 = (qTriple p).2.2 ^ 2 := by
  -- We proceed by induction on the depth of the path.
  induction' p with p ih;
  · rfl;
  · convert B₁'_preserves_pyth' _ _ _ ih using 1;
  · rename_i p hp;
    convert B₂'_preserves_pyth' _ _ _ hp using 1;
  · rename_i p ih; rw [ show qTriple p.child3 = ( - ( qTriple p |> Prod.fst ) + 2 * ( qTriple p |> Prod.snd |> Prod.fst ) + 2 * ( qTriple p |> Prod.snd |> Prod.snd ), -2 * ( qTriple p |> Prod.fst ) + ( qTriple p |> Prod.snd |> Prod.fst ) + 2 * ( qTriple p |> Prod.snd |> Prod.snd ), -2 * ( qTriple p |> Prod.fst ) + 2 * ( qTriple p |> Prod.snd |> Prod.fst ) + 3 * ( qTriple p |> Prod.snd |> Prod.snd ) ) from rfl ] ; linarith;

