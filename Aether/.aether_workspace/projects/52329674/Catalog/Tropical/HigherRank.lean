import Mathlib

/-! # CatalogBuild.Tropical.Langlands.HigherRank

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 13
-/

noncomputable section

/-- The positive roots with respect to a height function -/
def positiveRoots (n : ℕ) (Φ : TropicalRootSystem n) (height : (Fin n → ℝ) → ℝ) :
    Finset (Fin n → ℝ) :=
  Φ.roots.filter (fun α => height α > 0)

/-- The dominant weight for type A: decreasingly sorted coordinates -/
def isDominantTypeA (n : ℕ) (x : Fin n → ℝ) : Prop :=
  ∀ i j : Fin n, i ≤ j → x i ≥ x j

/-- A tropical double coset K\G/K for GL_n -/
structure TropicalDoubleCoset (n : ℕ) where
  factors : Fin n → ℝ
  sorted : ∀ i j : Fin n, i ≤ j → factors i ≥ factors j

/-- Sum of invariant factors equals the tropical determinant for diagonal matrices -/
theorem invariant_factors_sum_eq_tropDet (n : ℕ) (d : Fin n → ℝ) :
    ∑ i : Fin n, d i =
    ∑ i : Fin n, (fun i j : Fin n => if i = j then d i else 0) i i := by
  congr 1; ext i; simp

/-- A W-invariant function on the apartment -/
structure TropicalHeckeElement (n : ℕ) where
  toFun : (Fin n → ℝ) → ℝ
  weyl_invariant : ∀ σ : Equiv.Perm (Fin n), ∀ x,
    toFun (fun i => x (σ i)) = toFun x

/-- Every W-invariant function is determined on sorted inputs -/
theorem hecke_factors_through_sorted (n : ℕ) (h : TropicalHeckeElement n)
    (x y : Fin n → ℝ)
    (hperm : ∃ σ : Equiv.Perm (Fin n), ∀ i, x i = y (σ i)) :
    h.toFun x = h.toFun y := by
  obtain ⟨σ, hσ⟩ := hperm
  have : x = fun i => y (σ i) := funext hσ
  rw [this, h.weyl_invariant]

/-- The tropical Satake parameter space -/
def TropicalSatakeSpace (n : ℕ) :=
  { x : Fin n → ℝ // ∀ i j : Fin n, i ≤ j → x i ≤ x j }

/-- For type A_n, the Langlands dual is also type A_n -/
def tropLanglandsDualTypeA (n : ℕ) : (Fin n → ℝ) → (Fin n → ℝ) := id

/-- The Langlands dual map for type A is an involution -/
theorem tropLanglandsDual_involution (n : ℕ) (x : Fin n → ℝ) :
    tropLanglandsDualTypeA n (tropLanglandsDualTypeA n x) = x := by
  simp [tropLanglandsDualTypeA]

/-- For type B_n / C_n duality: SO_{2n+1} ↔ Sp_{2n} -/
def tropLanglandsDualTypeBC (n : ℕ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => 2 * x i

/-- B/C duality scaling property -/
theorem tropLanglandsDual_BC_scaling (n : ℕ) (x : Fin n → ℝ) (c : ℝ) :
    tropLanglandsDualTypeBC n (fun i => c * x i) = fun i => 2 * c * x i := by
  ext i; simp [tropLanglandsDualTypeBC]; ring

/-- Tropical parabolic induction: concatenate Satake parameters -/
def tropParabolicInduction (n₁ n₂ : ℕ)
    (params1 : Fin n₁ → ℝ) (params2 : Fin n₂ → ℝ) : Fin (n₁ + n₂) → ℝ :=
  Fin.addCases params1 params2

/-- [Section: # CatalogBuild.Tropical.Langlands.HigherRank
Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 13] -/
theorem tropL_parabolic_additive (n₁ n₂ : ℕ)
    (params1 : Fin n₁ → ℝ) (params2 : Fin n₂ → ℝ) (s : ℝ) :
    ∑ i : Fin (n₁ + n₂), (s - tropParabolicInduction n₁ n₂ params1 params2 i) =
    (∑ i : Fin n₁, (s - params1 i)) + (∑ i : Fin n₂, (s - params2 i)) := by
  have h_split : ∑ i : Fin (n₁ + n₂), (s - tropParabolicInduction n₁ n₂ params1 params2 i) = (∑ i : Fin n₁, (s - tropParabolicInduction n₁ n₂ params1 params2 (Fin.castAdd n₂ i))) + (∑ i : Fin n₂, (s - tropParabolicInduction n₁ n₂ params1 params2 (Fin.natAdd n₁ i))) := by
    exact?;
  unfold tropParabolicInduction at * ; aesop

end