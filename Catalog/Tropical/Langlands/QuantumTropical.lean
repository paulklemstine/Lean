/-! # CatalogBuild.Tropical.Langlands.QuantumTropical

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 25
-/

import Mathlib

noncomputable section

structure TropicalCrystal (n : ℕ) where
  numElements : ℕ
  weight : Fin numElements → Fin n → ℤ
  totalWeight : Fin n → ℤ


def crystalDim (n : ℕ) (C : TropicalCrystal n) : ℕ := C.numElements


/-- Tropical R-matrix: R(a,b) = (min(a,b), max(a,b)) -/
def tropicalRMatrix (a b : ℝ) : ℝ × ℝ :=
  (min a b, max a b)


theorem rMatrix_sorts (a b : ℝ) :
    (tropicalRMatrix a b).1 ≤ (tropicalRMatrix a b).2 := by
  simp only [tropicalRMatrix]
  exact min_le_max


theorem rMatrix_preserves_sum (a b : ℝ) :
    (tropicalRMatrix a b).1 + (tropicalRMatrix a b).2 = a + b := by
  simp only [tropicalRMatrix]
  exact min_add_max a b


theorem rMatrix_idempotent (a b : ℝ) :
    tropicalRMatrix (tropicalRMatrix a b).1 (tropicalRMatrix a b).2 =
    tropicalRMatrix a b := by
  -- By definition of the tropical R-matrix, we have:
  simp [tropicalRMatrix]


/-- Sorting preserves the sum -/
theorem sort_preserves_sum (a b c : ℝ) :
    min a (min b c) + (a + b + c - min a (min b c) - max a (max b c)) + max a (max b c) = a + b + c := by
  ring


structure LittelmannPath (n : ℕ) where
  numSegments : ℕ
  waypoints : Fin (numSegments + 1) → Fin n → ℝ
  start_at_origin : waypoints ⟨0, Nat.zero_lt_succ _⟩ = fun _ => 0


def pathEndpoint (n : ℕ) (p : LittelmannPath n) : Fin n → ℝ :=
  p.waypoints ⟨p.numSegments, by omega⟩


def straightPath (n : ℕ) (target : Fin n → ℝ) : LittelmannPath n where
  numSegments := 1
  waypoints := ![fun _ => 0, target]
  start_at_origin := by simp [Matrix.cons_val_zero]


theorem straightPath_endpoint (n : ℕ) (target : Fin n → ℝ) :
    pathEndpoint n (straightPath n target) = target := by
  exact?


def tropicalTensorProduct (m n : ℕ) (u : Fin m → ℝ) (v : Fin n → ℝ) :
    Fin (m + n) → ℝ :=
  Fin.append u v


theorem tensorProduct_sum (m n : ℕ) (u : Fin m → ℝ) (v : Fin n → ℝ) :
    ∑ i : Fin (m + n), tropicalTensorProduct m n u v i =
    (∑ i : Fin m, u i) + (∑ i : Fin n, v i) := by
  unfold tropicalTensorProduct;
  rw [ Fin.sum_univ_add ] ; aesop


def crystalCharacter (n : ℕ) (C : TropicalCrystal n) : Fin n → ℤ :=
  C.totalWeight


def tropicalCharValue (n : ℕ) (wt : Fin n → ℤ) (x : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, (wt i : ℝ) * x i


theorem tropicalCharValue_add (n : ℕ) (wt1 wt2 : Fin n → ℤ) (x : Fin n → ℝ) :
    tropicalCharValue n (wt1 + wt2) x =
    tropicalCharValue n wt1 x + tropicalCharValue n wt2 x := by
  simp [tropicalCharValue, Pi.add_apply, Int.cast_add, add_mul, Finset.sum_add_distrib]


theorem tropicalCharValue_zero_point (n : ℕ) (wt : Fin n → ℤ) :
    tropicalCharValue n wt (fun _ => 0) = 0 := by
  simp [tropicalCharValue]


def crystalDimension (n : ℕ) : ℕ := n


theorem crystalDim_add (m n : ℕ) :
    crystalDimension (m + n) = crystalDimension m + crystalDimension n := by
  simp [crystalDimension]


theorem crystalDim_mul (m n : ℕ) :
    crystalDimension (m * n) = crystalDimension m * crystalDimension n := by
  simp [crystalDimension]


def tropicalKLValue (n : ℕ) (s t : Equiv.Perm (Fin n)) : ℕ :=
  if s = t then 1 else 0


theorem tropicalKL_diagonal (n : ℕ) (s : Equiv.Perm (Fin n)) :
    tropicalKLValue n s s = 1 := by
  simp [tropicalKLValue]


theorem tropicalKL_off_diagonal (n : ℕ) (s t : Equiv.Perm (Fin n)) (h : s ≠ t) :
    tropicalKLValue n s t = 0 := by
  simp [tropicalKLValue, h]


def crystalLanglandsDual (n : ℕ) (wt : Fin n → ℤ) : Fin n → ℤ :=
  fun i => wt ⟨n - 1 - i.val, by omega⟩


theorem crystalLanglandsDual_involution (n : ℕ) (hn : n ≥ 1) (wt : Fin n → ℤ) :
    crystalLanglandsDual n (crystalLanglandsDual n wt) = wt := by
  exact funext fun i => by unfold crystalLanglandsDual; simp +decide [ Nat.sub_sub_self ( Nat.le_sub_one_of_lt i.2 ) ] ;


end
