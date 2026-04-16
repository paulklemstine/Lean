/-! # CatalogBuild.Pythagorean.Core.ParentFactoringExperiments

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 6
-/

import Mathlib

/-- Compute the trivial Pythagorean triple for odd N: (N, (N²-1)/2, (N²+1)/2). -/
def trivialTriple' (N : ℕ) : ℤ × ℤ × ℤ :=
  (N, ((N : ℤ) ^ 2 - 1) / 2, ((N : ℤ) ^ 2 + 1) / 2)



/-- The universal parent transform: unique parent in the Berggren tree.
Returns the parent triple (choosing the branch that gives positive components). -/
def universalParent' (a b c : ℤ) : ℤ × ℤ × ℤ :=
  let c' := -2 * a - 2 * b + 3 * c
  -- B₁⁻¹: (a + 2b - 2c, -2a - b + 2c, c')
  -- B₂⁻¹: (a + 2b - 2c, 2a + b - 2c, c')
  -- B₃⁻¹: (-a - 2b + 2c, 2a + b - 2c, c')
  let a1 := a + 2*b - 2*c
  let b1_opt1 := -2*a - b + 2*c  -- B₁
  let b1_opt2 := 2*a + b - 2*c   -- B₂
  let a_opt3 := -a - 2*b + 2*c   -- B₃
  if a1 > 0 && b1_opt2 > 0 then (a1, b1_opt2, c')       -- B₂⁻¹
  else if a1 > 0 && b1_opt1 > 0 then (a1, b1_opt1, c')   -- B₁⁻¹
  else if a_opt3 > 0 && b1_opt2 > 0 then (a_opt3, b1_opt2, c')  -- B₃⁻¹
  else (a, b, c)  -- at root



/-- Try to extract a factor of N from a triple's legs. -/
def tryFactor' (N : ℕ) (a b : ℤ) : Option ℕ :=
  let candidates := [a.natAbs, b.natAbs, (a - b).natAbs, (a + b).natAbs]
  candidates.findSome? fun v =>
    let g := Nat.gcd v N
    if 1 < g && g < N then some g else none



/-- Factor N via parent descent. -/
def factorByParentDescent' (N : ℕ) (maxSteps : ℕ) : Option ℕ :=
  if N % 2 == 0 || N < 9 then none
  else
    let t := trivialTriple' N
    go N t.1 t.2.1 t.2.2 maxSteps
where
  go (N : ℕ) : ℤ → ℤ → ℤ → ℕ → Option ℕ
    | _, _, _, 0 => none
    | a, b, c, fuel + 1 =>
      match tryFactor' N a b with
      | some f => some f
      | none =>
        if a == 3 && b == 4 && c == 5 then none
        else
          let (pa, pb, pc) := universalParent' a b c
          go N pa pb pc fuel



/-- Count steps to find a factor. -/
def stepsToFactor' (N : ℕ) (maxSteps : ℕ) : Option ℕ :=
  if N % 2 == 0 || N < 9 then none
  else
    let t := trivialTriple' N
    go N t.1 t.2.1 t.2.2 maxSteps 0
where
  go (N : ℕ) : ℤ → ℤ → ℤ → ℕ → ℕ → Option ℕ
    | _, _, _, 0, _ => none
    | a, b, c, fuel + 1, step =>
      match tryFactor' N a b with
      | some _ => some step
      | none =>
        if a == 3 && b == 4 && c == 5 then none
        else
          let (pa, pb, pc) := universalParent' a b c
          go N pa pb pc fuel (step + 1)

#eval stepsToFactor' 15 200     -- quick
#eval stepsToFactor' 77 200     -- 7 × 11
#eval stepsToFactor' 143 200    -- 11 × 13
#eval stepsToFactor' 323 200    -- 17 × 19



/-- Compute the Euclid parameters (m, n) from a PPT (a, b, c). -/
def euclidParams' (a b c : ℤ) : ℤ × ℤ :=
  let n_sq := (c - a) / 2
  let n := Int.sqrt n_sq.toNat
  let m := if n > 0 then b / (2 * n) else 0
  (m, n)

#eval euclidParams' 3 4 5       -- (2, 1)
#eval euclidParams' 5 12 13     -- (3, 2)
#eval euclidParams' 7 24 25     -- (4, 3)
#eval euclidParams' 21 20 29    -- (5, 2)
#eval euclidParams' 15 8 17     -- (4, 1)


