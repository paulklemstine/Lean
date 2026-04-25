/-! # CatalogBuild.Pythagorean.Quadruples.PythagoreanQuadruples

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 39
-/

import Mathlib

/-- A vector is null (lightlike) in (3+1) space iff Q₄ = 0 -/
def isNull4 (v : Fin 4 → ℤ) : Prop :=
  lorentzForm4 v = 0


/-- A vector is timelike iff Q₄ < 0 (massive particles) -/
def isTimelike4 (v : Fin 4 → ℤ) : Prop :=
  lorentzForm4 v < 0


/-- A vector is spacelike iff Q₄ > 0 (tachyonic / forbidden) -/
def isSpacelike4 (v : Fin 4 → ℤ) : Prop :=
  lorentzForm4 v > 0


/-- The Lorentz form as a matrix: diag(1, 1, 1, -1) -/
def Q_lor4 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, (-1)]


/-- A Pythagorean quadruple (a, b, c, d) satisfies a² + b² + c² = d² -/
structure PythQuad where
  a : ℤ
  b : ℤ
  c : ℤ
  d : ℤ
  pyth : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2


/-- The quadruple equation is equivalent to the null cone condition -/
theorem quad_iff_null (a b c d : ℤ) :
    a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 ↔ isNull4 ![a, b, c, d] := by
  unfold isNull4 lorentzForm4
  simp [cons_val_zero, cons_val_one]
  omega


/-- The quadruple (1, 2, 2, 3) is on the null cone -/
theorem quad_1_2_2_3_null : isNull4 ![1, 2, 2, 3] := by
  rw [← quad_iff_null]; norm_num


/-- The parametrization always produces a Pythagorean quadruple -/
theorem quadParam_is_pyth (m n p q : ℤ) :
    let (a, b, c, d) := quadParam m n p q
    a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 := by
  simp only [quadParam]
  ring


/-- The set of all Pythagorean quadruples -/
def PythQuadSet : Set (ℤ × ℤ × ℤ × ℤ) :=
  { v | v.1 ^ 2 + v.2.1 ^ 2 + v.2.2.1 ^ 2 = v.2.2.2 ^ 2 }


/-- A primitive quadruple has gcd(a,b,c,d) = 1 -/
def isPrimQuad (a b c d : ℤ) : Prop :=
  a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 ∧ Int.gcd (Int.gcd a b) (Int.gcd c d) = 1


/-- Embedding triples into quadruples via the zero third component -/
def tripleToQuad (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) : PythQuad where
  a := a
  b := b
  c := 0
  d := c
  pyth := by nlinarith [sq_nonneg (0 : ℤ)]


/-- The embedding preserves the Lorentz condition -/
theorem tripleToQuad_null (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    isNull4 ![a, b, 0, c] := by
  rw [← quad_iff_null]
  nlinarith [sq_nonneg (0 : ℤ)]


/-- Family 1: (k, 2k, 2k, 3k) — the "scaling" family from (1,2,2,3) -/
theorem scaling_family (k : ℤ) :
    k ^ 2 + (2*k) ^ 2 + (2*k) ^ 2 = (3*k) ^ 2 := by ring


/-- The (a, 0, 0, a) degenerate family -/
theorem degenerate_family (a : ℤ) :
    a ^ 2 + (0:ℤ) ^ 2 + (0:ℤ) ^ 2 = a ^ 2 := by ring


/-- Count quadruples with bounded hypotenuse -/
def countQuadruples (N : ℕ) : ℕ :=
  let candidates := do
    let d ← List.range (N + 1)
    let c ← List.range (d + 1)
    let b ← List.range (c + 1)
    let a ← List.range (b + 1)
    if a * a + b * b + c * c = d * d && d > 0 then
      return (a, b, c, d)
    else
      .nil
  candidates.length

#eval countQuadruples 20
#eval countQuadruples 50
#eval countQuadruples 100


/-- Generate all Pythagorean quadruples up to hypotenuse N -/
def allQuadruples (N : ℕ) : List (ℕ × ℕ × ℕ × ℕ) :=
  let candidates := do
    let d ← List.range (N + 1)
    let c ← List.range (d + 1)
    let b ← List.range (c + 1)
    let a ← List.range (b + 1)
    if a * a + b * b + c * c = d * d && d > 0 then
      return (a, b, c, d)
    else
      .nil
  candidates

#eval allQuadruples 10
#eval allQuadruples 25
#eval (allQuadruples 50).length


/-- The Minkowski inner product in (3+1) dimensions -/
def minkowski4 (v w : Fin 4 → ℤ) : ℤ :=
  v 0 * w 0 + v 1 * w 1 + v 2 * w 2 - v 3 * w 3


/-- The Lorentz form is the Minkowski self-product -/
theorem lorentz_is_self_product (v : Fin 4 → ℤ) :
    lorentzForm4 v = minkowski4 v v := by
  unfold lorentzForm4 minkowski4
  ring


/-- A matrix is in O(3,1;ℤ) if it preserves the Lorentz form -/
def isLorentz4 (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  Mᵀ * Q_lor4 * M = Q_lor4


/-- The identity is in O(3,1;ℤ) -/
theorem id_isLorentz4 : isLorentz4 1 := by
  unfold isLorentz4
  simp


/-- A spatial rotation (in the 12-plane) preserving the form -/
def rot12 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, (-1), 0, 0; 1, 0, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1]


/-- [Section: # CatalogBuild.Pythagorean.Quadruples.PythagoreanQuadruples
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 39] -/
theorem rot12_lorentz : isLorentz4 rot12 := by
  unfold isLorentz4 rot12 Q_lor4
  native_decide


/-- A spatial rotation (in the 13-plane) -/
def rot13 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, 0, (-1), 0; 0, 1, 0, 0; 1, 0, 0, 0; 0, 0, 0, 1]


/-- [Section: # CatalogBuild.Pythagorean.Quadruples.PythagoreanQuadruples
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 39] -/
theorem rot13_lorentz : isLorentz4 rot13 := by
  unfold isLorentz4 rot13 Q_lor4
  native_decide


/-- A spatial rotation (in the 23-plane) -/
def rot23 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 0, (-1), 0; 0, 1, 0, 0; 0, 0, 0, 1]


/-- [Section: # CatalogBuild.Pythagorean.Quadruples.PythagoreanQuadruples
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 39] -/
theorem rot23_lorentz : isLorentz4 rot23 := by
  unfold isLorentz4 rot23 Q_lor4
  native_decide


/-- The mass-squared of an arithmetic particle -/
def massSquared (a b c : ℤ) : ℤ :=
  c ^ 2 - a ^ 2 - b ^ 2


/-- A triple is "massive" if it has nonzero mass-squared -/
def isMassive (a b c : ℤ) : Prop :=
  massSquared a b c ≠ 0


/-- The triple (1,1,1) is spacelike (tachyonic): Q > 0, mass² < 0 -/
theorem triple_1_1_1_spacelike : massSquared 1 1 1 = -1 := by
  unfold massSquared; norm_num


/-- The triple (1,1,2) is timelike: Q < 0, mass² > 0 -/
theorem triple_1_1_2_timelike : massSquared 1 1 2 = 2 := by
  unfold massSquared; norm_num


/-- Classification of integer triples by causal type -/
inductive CausalType where
  | null      : CausalType   -- Pythagorean: photon
  | timelike  : CausalType   -- mass² > 0: massive particle
  | spacelike : CausalType   -- mass² < 0: tachyon
  deriving Repr, DecidableEq


/-- Classify a triple by its causal type -/
def classifyTriple (a b c : ℤ) : CausalType :=
  if c ^ 2 - a ^ 2 - b ^ 2 > 0 then .timelike
  else if c ^ 2 - a ^ 2 - b ^ 2 < 0 then .spacelike
  else .null


/-- Count triples of each causal type up to bound N -/
def causalCensus (N : ℕ) : ℕ × ℕ × ℕ :=  -- (null, timelike, spacelike)
  let triples := do
    let c ← List.range (N + 1)
    let b ← List.range (c + 1)
    let a ← List.range (b + 1)
    if a > 0 && b > 0 && c > 0 then return (a, b, c) else .nil
  let null_count := triples.filter (fun (a, b, c) => a*a + b*b == c*c) |>.length
  let timelike_count := triples.filter (fun (a, b, c) => a*a + b*b < c*c) |>.length
  let spacelike_count := triples.filter (fun (a, b, c) => a*a + b*b > c*c) |>.length
  (null_count, timelike_count, spacelike_count)

#eval causalCensus 20
#eval causalCensus 50
#eval causalCensus 100


/-- The mass shell: set of triples with fixed mass-squared -/
def massShell (m_sq : ℤ) : Set (ℤ × ℤ × ℤ) :=
  { v | v.2.2 ^ 2 - v.1 ^ 2 - v.2.1 ^ 2 = m_sq }


/-- (1,1,2) is on the mass shell m² = 2 -/
theorem on_mass_shell_1_1_2 : (1, 1, 2) ∈ massShell 2 := by
  show (2 : ℤ) ^ 2 - (1 : ℤ) ^ 2 - (1 : ℤ) ^ 2 = 2; norm_num


/-- (1,2,3) is on the mass shell m² = 4 -/
theorem on_mass_shell_1_2_3 : (1, 2, 3) ∈ massShell 4 := by
  show (3 : ℤ) ^ 2 - (1 : ℤ) ^ 2 - (2 : ℤ) ^ 2 = 4; norm_num


/-- The null cone is the mass shell m² = 0 -/
theorem null_cone_is_mass_zero (a b c : ℤ) :
    (a, b, c) ∈ massShell 0 ↔ a ^ 2 + b ^ 2 = c ^ 2 := by
  show c ^ 2 - a ^ 2 - b ^ 2 = 0 ↔ _; omega


/-- Project a quadruple to a triple by forgetting the third spatial component -/
def projectQuad12 (a b _c d : ℤ) : ℤ × ℤ × ℤ :=
  (a, b, d)  -- Warning: NOT necessarily Pythagorean!


/-- The projection deficit: how far the projection is from being Pythagorean -/
theorem projectionDeficit (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    a^2 + b^2 = d^2 - c^2 := by linarith


