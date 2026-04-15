/-! # CatalogBuild.Speculative.Consciousness.TropicalConsciousness

Auto-generated from theorem catalog database.
Domain: Speculative/Consciousness
Declarations: 15
-/

import Mathlib

noncomputable section

def tropZero : WithBot ℝ := ⊥

def tropOne : WithBot ℝ := (0 : ℝ)


theorem tropAdd_zero (a : WithBot ℝ) : tropAdd a tropZero = a :=
  sup_bot_eq a


theorem tropMul_one (a : WithBot ℝ) : tropMul a tropOne = a := by
  match a with
  | ⊥ => rfl
  | (x : ℝ) => simp [tropMul, tropOne]


/-- [Section: ## §2: Tropical Consciousness Matrix] -/
def TropicalMatrix (n : ℕ) := Fin n → Fin n → WithBot ℝ


def tropMatVecMul {n : ℕ} (M : TropicalMatrix n) (v : Fin n → WithBot ℝ) :
    Fin n → WithBot ℝ :=
  fun i => Finset.univ.sup (fun j => tropMul (M i j) (v j))


def isTropicalEigenvalue {n : ℕ} (M : TropicalMatrix n) (lam : ℝ)
    (v : Fin n → WithBot ℝ) : Prop :=
  ∀ i, tropMatVecMul M v i = tropMul (↑lam) (v i)


/-- [Section: ## §3: Tropical Fixed Points] -/
structure TropicalReflector (n : ℕ) where
  matrix : TropicalMatrix n
  self_aware : ∀ i : Fin n, matrix i i ≠ ⊥


def tropicalIterate {n : ℕ} (R : TropicalReflector n)
    (v : Fin n → WithBot ℝ) : ℕ → Fin n → WithBot ℝ
  | 0 => v
  | k + 1 => tropMatVecMul R.matrix (tropicalIterate R v k)


/-- [Section: ## §4: Tropical Convexity] -/
def isTropConvex (n : ℕ) (S : Set (Fin n → ℝ)) : Prop :=
  ∀ x y : Fin n → ℝ, x ∈ S → y ∈ S →
    ∀ t : ℝ, 0 ≤ t → t ≤ 1 →
      (fun i => max (t + x i) ((1 - t) + y i)) ∈ S


def tropConvexHull (n : ℕ) (S : Set (Fin n → ℝ)) : Set (Fin n → ℝ) :=
  sInter { T | S ⊆ T ∧ isTropConvex n T }


theorem subset_tropConvexHull (n : ℕ) (S : Set (Fin n → ℝ)) :
    S ⊆ tropConvexHull n S := by
  intro x hx T ⟨hST, _⟩
  exact hST hx


/-- [Section: ## §5: Tropical Consciousness Metric] -/
def tropicalDist {n : ℕ} (x y : Fin (n + 1) → ℝ) : ℝ :=
  Finset.univ.sup' ⟨⟨0, Nat.zero_lt_succ n⟩, Finset.mem_univ _⟩ (fun i => |x i - y i|)


theorem tropicalDist_symm {n : ℕ} (x y : Fin (n + 1) → ℝ) :
    tropicalDist x y = tropicalDist y x := by
  simp [tropicalDist, abs_sub_comm]


theorem tropicalDist_self {n : ℕ} (x : Fin (n + 1) → ℝ) :
    tropicalDist x x = 0 := by
  simp [tropicalDist]


end
