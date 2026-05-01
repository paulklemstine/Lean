/-! # CatalogBuild.Tropical.ThetaCorrespondence.lean

Auto-generated from theorem catalog database.
Domain: Tropical
Declarations: 25
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Tropical.Langlands.ThetaCorrespondence
Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 25] -/
def tropicalQuadraticForm (n : ℕ) (x : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, x i ^ 2


/-- [Section: # CatalogBuild.Tropical.Langlands.ThetaCorrespondence
Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 25] -/
def tropicalSymplecticForm (n : ℕ) (x y : Fin n → ℝ × ℝ) : ℝ :=
  ∑ i : Fin n, ((x i).1 * (y i).2 - (x i).2 * (y i).1)


/-- [Section: # CatalogBuild.Tropical.Langlands.ThetaCorrespondence
Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 25] -/
theorem symplecticForm_antisymm (n : ℕ) (x y : Fin n → ℝ × ℝ) :
    tropicalSymplecticForm n x y = -tropicalSymplecticForm n y x := by
  simp only [tropicalSymplecticForm, ← Finset.sum_neg_distrib]
  congr 1; ext i; ring


theorem symplecticForm_self (n : ℕ) (x : Fin n → ℝ × ℝ) :
    tropicalSymplecticForm n x x = 0 := by
  simp only [tropicalSymplecticForm]
  apply Finset.sum_eq_zero; intro i _; ring


theorem quadraticForm_nonneg (n : ℕ) (x : Fin n → ℝ) :
    tropicalQuadraticForm n x ≥ 0 := by
  exact Finset.sum_nonneg fun _ _ => sq_nonneg _


theorem quadraticForm_eq_zero_iff (n : ℕ) (x : Fin n → ℝ) :
    tropicalQuadraticForm n x = 0 ↔ x = 0 := by
  unfold tropicalQuadraticForm;
  norm_num [ funext_iff, Finset.sum_eq_zero_iff_of_nonneg, sq_nonneg ]


def tropicalThetaKernel (m n : ℕ) (a : Fin m → ℝ) (b : Fin n → ℝ) : ℝ :=
  ∑ i : Fin m, ∑ j : Fin n, a i * b j


theorem thetaKernel_product (m n : ℕ) (a : Fin m → ℝ) (b : Fin n → ℝ) :
    tropicalThetaKernel m n a b = (∑ i : Fin m, a i) * (∑ j : Fin n, b j) := by
  unfold tropicalThetaKernel; simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] ;


theorem thetaKernel_add_left (m n : ℕ) (a1 a2 : Fin m → ℝ) (b : Fin n → ℝ) :
    tropicalThetaKernel m n (a1 + a2) b =
    tropicalThetaKernel m n a1 b + tropicalThetaKernel m n a2 b := by
  simp [tropicalThetaKernel, Pi.add_apply, add_mul, Finset.sum_add_distrib]


theorem thetaKernel_add_right (m n : ℕ) (a : Fin m → ℝ) (b1 b2 : Fin n → ℝ) :
    tropicalThetaKernel m n a (b1 + b2) =
    tropicalThetaKernel m n a b1 + tropicalThetaKernel m n a b2 := by
  simp [tropicalThetaKernel, Pi.add_apply, mul_add, Finset.sum_add_distrib]


theorem thetaKernel_comm (m n : ℕ) (a : Fin m → ℝ) (b : Fin n → ℝ) :
    tropicalThetaKernel m n a b = tropicalThetaKernel n m b a := by
  exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => mul_comm _ _ )


def tropicalThetaLift (m n : ℕ) (f : (Fin m → ℝ) → ℝ)
    (b : Fin n → ℝ) (a : Fin m → ℝ) : ℝ :=
  f a + tropicalThetaKernel m n a b


structure LParam (n : ℕ) where
  values : Fin n → ℝ
  sorted : ∀ i j : Fin n, i ≤ j → values i ≥ values j


def tropicalLValue (n : ℕ) (p : LParam n) (s : ℝ) : ℝ :=
  ∑ i : Fin n, p.values i * s


theorem tropicalLValue_zero (n : ℕ) (p : LParam n) :
    tropicalLValue n p 0 = 0 := by
  simp [tropicalLValue]


structure TropicalDualPair where
  m : ℕ
  n : ℕ


def TropicalDualPair.swap (P : TropicalDualPair) : TropicalDualPair :=
  { m := P.n, n := P.m }


theorem dualPair_swap_involution (P : TropicalDualPair) :
    P.swap.swap = P := by
  simp [TropicalDualPair.swap]


def TropicalDualPair.size (P : TropicalDualPair) : ℕ := P.m * P.n


theorem dualPair_size_swap (P : TropicalDualPair) :
    P.swap.size = P.size := by
  simp [TropicalDualPair.swap, TropicalDualPair.size, Nat.mul_comm]


def tropicalWeilAction (n : ℕ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => -x i


theorem weilAction_involution (n : ℕ) (x : Fin n → ℝ) :
    tropicalWeilAction n (tropicalWeilAction n x) = x := by
  ext i; simp [tropicalWeilAction]


theorem weilAction_preserves_quadratic (n : ℕ) (x : Fin n → ℝ) :
    tropicalQuadraticForm n (tropicalWeilAction n x) = tropicalQuadraticForm n x := by
  simp only [tropicalQuadraticForm, tropicalWeilAction]
  congr 1; ext i; ring


structure SeeSaw where
  pair1 : TropicalDualPair
  pair2 : TropicalDualPair
  compatible : pair1.m = pair2.n


theorem seeSaw_size_relation (S : SeeSaw) :
    S.pair1.m * S.pair1.n = S.pair2.n * S.pair1.n := by
  rw [S.compatible]


end
