import Mathlib

/-! # CatalogBuild.Pythagorean.Quadruples.Foundations

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 35
-/

/-- The Lorentz form Q₄(v) = v₀² + v₁² + v₂² - v₃² -/
def Q4 (v : Fin 4 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 - v 3 ^ 2

/-- A vector is on the null cone (lightlike) iff Q₄ = 0 -/
def IsNullQ4 (v : Fin 4 → ℤ) : Prop := Q4 v = 0

/-- Pythagorean quadruple equation ↔ null cone condition -/
theorem quad_eq_null (a b c d : ℤ) :
    a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 ↔ IsNullQ4 ![a, b, c, d] := by
  show _ ↔ (![a, b, c, d] 0) ^ 2 + (![a, b, c, d] 1) ^ 2 + (![a, b, c, d] 2) ^ 2 - (![a, b, c, d] 3) ^ 2 = 0
  change _ ↔ a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2 = 0
  omega

/-- The Minkowski metric η = diag(1,1,1,-1) -/
def eta4 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, -1]

/-- A matrix M is in O(3,1;ℤ) iff MᵀηM = η -/
def IsLorentz4 (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  M.transpose * eta4 * M = eta4

/-- The reflection through the spacelike vector (1,1,1,1).
R₁₁₁₁(a,b,c,d) = (d-b-c, d-a-c, d-a-b, 2d-a-b-c) -/
def R1111 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, -1, -1, 1; -1, 0, -1, 1; -1, -1, 0, 1; -1, -1, -1, 2]

/-- R₁₁₁₁ is an element of O(3,1;ℤ) -/
theorem R1111_isLorentz : IsLorentz4 R1111 := by
  unfold IsLorentz4 R1111 eta4; native_decide

/-- R₁₁₁₁ is an involution: R₁₁₁₁² = I -/
theorem R1111_involution : R1111 * R1111 = 1 := by native_decide

/-- Spatial permutation: swap coordinates 0 and 1 -/
def perm01 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, 1, 0, 0; 1, 0, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1]

/-- Spatial permutation: swap coordinates 1 and 2 -/
def perm12 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 0, 1, 0; 0, 1, 0, 0; 0, 0, 0, 1]

/-- Sign flip of coordinate 0 -/
def signFlip0 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![-1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1]

/-- perm01 is in O(3,1;ℤ) -/
theorem perm01_isLorentz : IsLorentz4 perm01 := by
  unfold IsLorentz4 perm01 eta4; native_decide

/-- perm12 is in O(3,1;ℤ) -/
theorem perm12_isLorentz : IsLorentz4 perm12 := by
  unfold IsLorentz4 perm12 eta4; native_decide

/-- signFlip0 is in O(3,1;ℤ) -/
theorem signFlip0_isLorentz : IsLorentz4 signFlip0 := by
  unfold IsLorentz4 signFlip0 eta4; native_decide

/-- [Section: # CatalogBuild.Pythagorean.Quadruples.Foundations
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 35] -/
theorem R1111_preserves_Q4 (a b c d : ℤ) :
    Q4 (R1111.mulVec ![a, b, c, d]) = Q4 ![a, b, c, d] := by
  unfold Q4; simp +decide [ Matrix.mulVec ] ; ring;
  unfold R1111; simp +decide [ vecHead, vecTail ] ; ring;

/-- [Section: # CatalogBuild.Pythagorean.Quadruples.Foundations
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 35] -/
theorem R1111_preserves_null (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    let w := R1111.mulVec ![a, b, c, d]
    w 0 ^ 2 + w 1 ^ 2 + w 2 ^ 2 = w 3 ^ 2 := by
  simp [R1111];
  grind +extAll

theorem sum_lt_twice_hyp (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c) (hd : 0 < d) :
    a + b + c < 2 * d := by
  nlinarith only [ ha, hb, hc, hd, sq_nonneg ( a - b ), sq_nonneg ( b - c ), sq_nonneg ( c - a ), h ]

/-- The descent map sends d to d' = 2d - (a+b+c), and we have 0 < d' < d -/
theorem descent_strict_decrease (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (ha : 0 ≤ a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d) :
    0 < 2 * d - (a + b + c) ∧ 2 * d - (a + b + c) < d := by
  constructor
  · linarith [sum_lt_twice_hyp a b c d h ha (le_of_lt hb) (le_of_lt hc) hd]
  · linarith [sum_gt_hyp a b c d h ha hb hc hd]

theorem R1111_action (a b c d : ℤ) :
    R1111.mulVec ![a, b, c, d] = ![d - b - c, d - a - c, d - a - b, 2*d - a - b - c] := by
  ext i; fin_cases i <;> simp [R1111] <;> ring!;

/-- (0, 0, 1, 1) is a valid null vector: 0² + 0² + 1² = 1² -/
theorem root_is_null : (0 : ℤ) ^ 2 + 0 ^ 2 + 1 ^ 2 = 1 ^ 2 := by norm_num

/-- R₁₁₁₁ fixes (0,0,1,1): the root is a fixed point of the descent -/
theorem root_fixed : R1111.mulVec ![(0:ℤ), 0, 1, 1] = ![0, 0, 1, 1] := by
  native_decide

/-- (1, 2, 2, 3) descends: R₁₁₁₁(1,2,2,3) = (-1, 0, 0, 1) -/
theorem descent_1_2_2_3 :
    R1111.mulVec ![(1:ℤ), 2, 2, 3] = ![-1, 0, 0, 1] := by
  native_decide

/-- (2, 3, 6, 7) descends: R₁₁₁₁(2,3,6,7) = (-2, -1, 2, 3) -/
theorem descent_2_3_6_7 :
    R1111.mulVec ![(2:ℤ), 3, 6, 7] = ![-2, -1, 2, 3] := by
  native_decide

/-- The Euler parametrization of Pythagorean quadruples:
(m² + n² - p² - q², 2(mq + np), 2(nq - mp), m² + n² + p² + q²) -/
def eulerParam (m n p q : ℤ) : Fin 4 → ℤ := fun i =>
  match i with
  | 0 => m ^ 2 + n ^ 2 - p ^ 2 - q ^ 2
  | 1 => 2 * (m * q + n * p)
  | 2 => 2 * (n * q - m * p)
  | 3 => m ^ 2 + n ^ 2 + p ^ 2 + q ^ 2

theorem eulerParam_null (m n p q : ℤ) : IsNullQ4 (eulerParam m n p q) := by
  unfold IsNullQ4 Q4 eulerParam; ring;

/-- Two quadruples are in the same orbit if related by O(3,1;ℤ) -/
def SameOrbit (v w : Fin 4 → ℤ) : Prop :=
  ∃ M : Matrix (Fin 4) (Fin 4) ℤ, IsLorentz4 M ∧ M.mulVec v = w

/-- Same-orbit is reflexive -/
theorem sameOrbit_refl (v : Fin 4 → ℤ) : SameOrbit v v := by
  refine ⟨1, ?_, ?_⟩
  · unfold IsLorentz4 eta4; native_decide
  · ext i; fin_cases i <;> simp [Matrix.mulVec, dotProduct, Matrix.one_apply]

theorem sameOrbit_trans {u v w : Fin 4 → ℤ}
    (huv : SameOrbit u v) (hvw : SameOrbit v w) : SameOrbit u w := by
  -- By definition of SameOrbit, there exist matrices M₁ and M₂ such that M₁v = u and M₂w = v.
  obtain ⟨M₁, hM₁⟩ := huv
  obtain ⟨M₂, hM₂⟩ := hvw;
  use M₂ * M₁, by
    unfold IsLorentz4 at *; simp_all +decide [ Matrix.mul_assoc ] ;
    simp_all +decide [ ← Matrix.mul_assoc ];
  simp +decide [ ← hM₁.2, ← hM₂.2, Matrix.mulVec_mulVec ]

theorem descent_identity (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - b - c) ^ 2 + (d - a - c) ^ 2 + (d - a - b) ^ 2 = (2*d - a - b - c) ^ 2 := by
  linarith

/-- The Berggren parent matrix for triples -/
def berggrenR111 : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- The Pythagorean triple Lorentz form -/
def Q3 (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

theorem berggrenR111_preserves_Q3 : ∀ v : Fin 3 → ℤ,
    Q3 (berggrenR111.mulVec v) = Q3 v := by
  intro v;
  unfold berggrenR111 Q3;
  simp +decide [ Matrix.vecHead, Matrix.vecTail ] ; ring

/-- Find the root of the descent -/
def descentRoot (a b c d : ℕ) : ℕ × ℕ × ℕ × ℕ :=
  let chain := descentChain a b c d 30
  chain.getLast!

/-- List all primitive quadruples with hypotenuse ≤ N -/
def listPrimQuads' (N : ℕ) : List (ℕ × ℕ × ℕ × ℕ) := do
  let d ← List.range (N + 1)
  let c ← List.range (d + 1)
  let b ← List.range (c + 1)
  let a ← List.range (b + 1)
  if b > 0 && c > 0 && d > 0 &&
     a * a + b * b + c * c == d * d &&
     Nat.gcd (Nat.gcd a b) (Nat.gcd c d) == 1
  then return (a, b, c, d)
  else .nil

-- Descent chains for small quadruples
#eval descentChain 1 2 2 3 10
#eval descentChain 2 3 6 7 10
#eval descentChain 4 4 7 9 10
#eval descentChain 1 4 8 9 10
#eval descentChain 3 4 12 13 10

-- Universal descent verification: ALL primitive quadruples with d ≤ 50
-- descend to the root (0, 0, 1, 1)
#eval (listPrimQuads' 50).all fun (a,b,c,d) =>
  descentRoot a b c d == (0, 0, 1, 1)

-- Count of primitive quadruples by hypotenuse bound
#eval (listPrimQuads' 10).length
#eval (listPrimQuads' 20).length
#eval (listPrimQuads' 30).length
#eval (listPrimQuads' 50).length

/-- Count the children of a quadruple at each descent level -/
def childrenOf (parent : ℕ × ℕ × ℕ × ℕ) (N : ℕ) : List (ℕ × ℕ × ℕ × ℕ) :=
  (listPrimQuads' N).filter fun q =>
    let chain := descentChain q.1 q.2.1 q.2.2.1 q.2.2.2 30
    chain.length > 1 ∧ chain[1]! == parent

-- Children of (0,0,1,1) = the "first generation"
#eval childrenOf (0, 0, 1, 1) 30

-- Children of (1,2,2,3) = the "second generation"
#eval childrenOf (1, 2, 2, 3) 30

