import Mathlib

/-!
# Sums of Three Cubes — Core Definitions

This file establishes the fundamental definitions for the local-global
architecture of the Diophantine surface x³ + y³ + z³ = k.

## Main Definitions

* `SumThreeCubesRep k` — integral representability as a sum of three cubes
* `OnCubicSurface k x y z` — membership on the affine cubic surface X_k
* `ThreeCubeLocalAdmissible n a` — local admissibility modulo n
* `EverywhereLocallyAdmissible k` — everywhere local admissibility (proto-Hasse)
-/

/-- An integer `k` is representable as a sum of three cubes. -/
def SumThreeCubesRep (k : ℤ) : Prop :=
  ∃ x y z : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = k

/-- A triple `(x, y, z)` lies on the affine cubic surface X_k. -/
def OnCubicSurface (k x y z : ℤ) : Prop :=
  x ^ 3 + y ^ 3 + z ^ 3 = k

/-- A residue class `a` modulo `n` is locally admissible for sums of three cubes. -/
def ThreeCubeLocalAdmissible (n : ℕ) (a : ZMod n) : Prop :=
  ∃ x y z : ZMod n, x ^ 3 + y ^ 3 + z ^ 3 = a

/-- An integer `k` is everywhere locally admissible: for every positive modulus,
the residue class of `k` is representable as a sum of three cubes. This is
the arithmetic shadow of adelic solvability. -/
def EverywhereLocallyAdmissible (k : ℤ) : Prop :=
  ∀ n : ℕ, 0 < n → ThreeCubeLocalAdmissible n (k : ZMod n)

/-- `SumThreeCubesRep` and `OnCubicSurface` are equivalent characterizations. -/
theorem sumThreeCubesRep_iff_onCubicSurface (k : ℤ) :
    SumThreeCubesRep k ↔ ∃ x y z : ℤ, OnCubicSurface k x y z := by
  rfl