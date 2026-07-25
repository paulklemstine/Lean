/-
  # Poincaré Threshold for Data: Theorems

  Main results on Rips filtrations and manifold detection thresholds.

  ## Key Theorems:
  1. **Filtration monotonicity**: RipsPath is monotone in ε
  2. **Rips connectivity monotonicity**: Once connected, stays connected
  3. **Simplex properties**: subset closure, monotonicity, pair characterization
  4. **Sphere Betti signature**: uniqueness and structural properties
  5. **Connectivity threshold**: characterization and bounds
  6. **Euler characteristic**: sign pattern
-/
import Mathlib
import Pythagorean.PoincareThresholdDefs

open Finset

/-! ## 1. Path Concatenation (Transitivity) -/

/-- Rips paths can be concatenated (transitivity). -/
theorem ripsPath_trans {α : Type*} {d : α → α → ℝ} {ε : ℝ} {x y z : α}
    (h1 : RipsPath d ε x y) (h2 : RipsPath d ε y z) : RipsPath d ε x z := by
  induction h1 with
  | refl _ => exact h2
  | step a b c hab _ ih => exact RipsPath.step a b z hab (ih h2)

/-! ## 2. Filtration Monotonicity -/

/-- If x and y are ε-adjacent and ε ≤ ε', then they are ε'-adjacent. -/
theorem ripsAdj_mono {α : Type*} {d : α → α → ℝ} {ε ε' : ℝ} {x y : α}
    (h : RipsAdj d ε x y) (hle : ε ≤ ε') : RipsAdj d ε' x y :=
  ⟨h.1, le_trans h.2 hle⟩

/-- If there is a Rips path at scale ε and ε ≤ ε', there is a Rips path at scale ε'.
    This is the fundamental monotonicity of the Rips filtration. -/
theorem ripsPath_mono {α : Type*} {d : α → α → ℝ} {ε ε' : ℝ} {x y : α}
    (h : RipsPath d ε x y) (hle : ε ≤ ε') : RipsPath d ε' x y := by
  induction h with
  | refl a => exact RipsPath.refl a
  | step a b c hab _ ih => exact RipsPath.step a b c (ripsAdj_mono hab hle) (ih)

/-- If the Rips graph is connected at scale ε and ε ≤ ε', it is connected at ε'. -/
theorem ripsConnected_mono {α : Type*} {d : α → α → ℝ} {ε ε' : ℝ}
    (h : RipsConnected d ε) (hle : ε ≤ ε') : RipsConnected d ε' :=
  fun x y => ripsPath_mono (h x y) hle

/-! ## 3. Symmetry of Rips Paths -/

/-- RipsAdj is symmetric if the metric is symmetric. -/
theorem ripsAdj_symm {α : Type*} {d : α → α → ℝ} {ε : ℝ} {x y : α}
    (hm : IsFiniteMetric d) (h : RipsAdj d ε x y) : RipsAdj d ε y x :=
  ⟨h.1.symm, hm.sym x y ▸ h.2⟩

/-- RipsPath is symmetric if the metric is symmetric. -/
theorem ripsPath_symm {α : Type*} {d : α → α → ℝ} {ε : ℝ} {x y : α}
    (hm : IsFiniteMetric d) (h : RipsPath d ε x y) : RipsPath d ε y x := by
  induction h with
  | refl a => exact RipsPath.refl a
  | step a b c hab _ ih =>
    exact ripsPath_trans ih (RipsPath.step b a a (ripsAdj_symm hm hab) (RipsPath.refl a))

/-! ## 4. Rips Simplex Properties -/

/-- Every subset of a Rips simplex is also a Rips simplex at the same scale. -/
theorem isRipsSimplex_subset {α : Type*} [DecidableEq α] {d : α → α → ℝ} {ε : ℝ}
    {σ τ : Finset α} (h : IsRipsSimplex d ε σ) (hsub : τ ⊆ σ) :
    IsRipsSimplex d ε τ :=
  fun x hx y hy hne => h x (hsub hx) y (hsub hy) hne

/-- A singleton is always a Rips simplex (a 0-simplex). -/
theorem isRipsSimplex_singleton {α : Type*} [DecidableEq α] {d : α → α → ℝ} {ε : ℝ}
    (x : α) : IsRipsSimplex d ε {x} := by
  intro a ha b hb hne
  simp only [Finset.mem_singleton] at ha hb
  subst ha; subst hb
  exact absurd rfl hne

/-- A pair {x, y} is a Rips simplex iff d(x,y) ≤ ε (given x ≠ y and symmetric metric). -/
theorem isRipsSimplex_pair {α : Type*} [DecidableEq α] {d : α → α → ℝ} {ε : ℝ}
    {x y : α} (hm : IsFiniteMetric d) (hne : x ≠ y) :
    IsRipsSimplex d ε {x, y} ↔ d x y ≤ ε := by
  constructor
  · intro h
    exact h x (mem_insert_self x {y}) y (mem_insert_of_mem (mem_singleton_self y)) hne
  · intro h a ha b hb hab
    simp at ha hb
    rcases ha with rfl | rfl <;> rcases hb with rfl | rfl
    · exact absurd rfl hab
    · exact h
    · rw [hm.sym]; exact h
    · exact absurd rfl hab

/-- Rips simplices are monotone in ε. -/
theorem isRipsSimplex_mono {α : Type*} {d : α → α → ℝ} {ε ε' : ℝ}
    {σ : Finset α} (h : IsRipsSimplex d ε σ) (hle : ε ≤ ε') :
    IsRipsSimplex d ε' σ :=
  fun x hx y hy hne => le_trans (h x hx y hy hne) hle

/-- The empty set is a Rips simplex at any scale. -/
theorem isRipsSimplex_empty {α : Type*} [DecidableEq α] {d : α → α → ℝ} {ε : ℝ} :
    IsRipsSimplex d ε (∅ : Finset α) := by
  intro x hx; simp at hx

/-! ## 5. Sphere Betti Signature Properties -/

/-- The 0-th Betti number of S^d is always 1 (connected). -/
theorem sphereBetti_zero (dim : ℕ) : sphereBetti dim 0 = 1 := by
  simp [sphereBetti]

/-- The d-th Betti number of S^d is 1 (for d ≥ 1). -/
theorem sphereBetti_dim (dim : ℕ) (hd : 0 < dim) : sphereBetti dim dim = 1 := by
  simp [sphereBetti, Nat.pos_iff_ne_zero.mp hd]

/-- For 0 < k < d, the k-th Betti number of S^d is 0 (no intermediate homology). -/
theorem sphereBetti_middle (dim k : ℕ) (hk0 : 0 < k) (hkd : k < dim) :
    sphereBetti dim k = 0 := by
  simp [sphereBetti, Nat.pos_iff_ne_zero.mp hk0, Nat.ne_of_lt hkd]

/-
The sphere Betti signature determines the dimension uniquely (for dim ≥ 1):
    if sphereBetti d₁ = sphereBetti d₂ and both d₁, d₂ ≥ 1, then d₁ = d₂.
-/
theorem sphereBetti_injective {d₁ d₂ : ℕ} (hd1 : 0 < d₁) (_hd2 : 0 < d₂)
    (h : sphereBetti d₁ = sphereBetti d₂) : d₁ = d₂ := by
  unfold sphereBetti at h; have := congr_fun h d₁; aesop

/-! ## 6. Connectivity Threshold -/

/-- If the metric space has at most one point, the Rips graph is connected for all ε. -/
theorem ripsConnected_of_subsingleton {α : Type*} [Subsingleton α]
    {d : α → α → ℝ} {ε : ℝ} : RipsConnected d ε := by
  intro x y
  have := Subsingleton.elim x y
  subst this
  exact RipsPath.refl x

/-- Any two points with d(x,y) ≤ ε and x ≠ y are connected by a Rips path of length 1. -/
theorem ripsPath_of_le {α : Type*} {d : α → α → ℝ} {ε : ℝ} {x y : α}
    (hne : x ≠ y) (h : d x y ≤ ε) : RipsPath d ε x y :=
  RipsPath.step x y y ⟨hne, h⟩ (RipsPath.refl y)

/-! ## 7. Euler Characteristic Properties -/

/-- The Euler characteristic of a point is 1. -/
theorem euler_of_point : eulerContrib 0 1 = 1 := by
  simp [eulerContrib]

/-
The alternating sign pattern: even dimensions contribute positively,
    odd dimensions contribute negatively.
-/
theorem eulerContrib_sign (k n : ℕ) :
    eulerContrib k n = if Even k then (n : ℤ) else -(n : ℤ) := by
  split_ifs <;> simp_all +decide [ eulerContrib ]

/-
Euler characteristic of the d-sphere equals 1 + (-1)^d.
    This is the classical result: χ(S^d) = 1 + (-1)^d.
-/
theorem euler_sphere (d : ℕ) :
    (1 : ℤ) + (-1 : ℤ) ^ d = if Even d then 2 else 0 := by
  split_ifs <;> simp_all +decide

/-! ## 8. The Poincaré Threshold Bound -/

/-
If the Betti computation is monotone in that β₀ = 1 implies connectivity,
    then the Poincaré threshold is at least the connectivity threshold.
-/
theorem poincareThreshold_ge_connectivityThreshold
    {α : Type*} (d : α → α → ℝ) (bettiOfRips : ℝ → BettiSignature)
    (dim : ℕ) (_hd : 0 < dim)
    (hbetti_conn : ∀ ε, bettiOfRips ε = sphereBetti dim → RipsConnected d ε)
    (hne : ∃ ε, 0 ≤ ε ∧ bettiOfRips ε = sphereBetti dim) :
    connectivityThreshold d ≤ poincareThreshold bettiOfRips dim := by
  refine' le_csInf _ _;
  · exact hne;
  · exact fun ε hε => csInf_le ⟨ 0, fun ε hε => hε.1 ⟩ ⟨ hε.1, hbetti_conn ε hε.2 ⟩

/-! ## 9. Rips Complex at Scale 0 -/

/-
At scale 0, no two distinct points are adjacent (in a metric space).
-/
theorem ripsAdj_zero_false {α : Type*} {d : α → α → ℝ} {x y : α}
    (hm : IsFiniteMetric d) (hne : x ≠ y) : ¬ RipsAdj d 0 x y := by
  exact fun h => hne ( hm.eq_zero_iff _ _ |>.1 ( le_antisymm h.2 ( hm.nonneg _ _ ) ) )

/-
At scale 0, the only Rips simplices are singletons (in a metric space).
-/
theorem isRipsSimplex_zero_iff_card_le_one {α : Type*} [DecidableEq α]
    {d : α → α → ℝ} {σ : Finset α} (hm : IsFiniteMetric d) :
    IsRipsSimplex d 0 σ ↔ σ.card ≤ 1 := by
  constructor;
  · intro hσ;
    contrapose! hσ;
    obtain ⟨ x, hx, y, hy, hxy ⟩ := Finset.one_lt_card.mp hσ;
    exact fun h => hxy ( hm.eq_zero_iff x y |>.1 ( le_antisymm ( h x hx y hy hxy ) ( hm.nonneg x y ) ) );
  · intro hσ
    intro x hx y hy hxy
    have h_card : σ.card ≤ 1 := hσ
    exact (by
    exact False.elim ( hxy ( Finset.card_le_one.1 h_card x hx y hy ) ))

/-! ## 10. Diameter and the Critical Connectivity Scale -/

/-
In a finite metric space on Fin n, the Rips graph at scale equal to the maximum
    pairwise distance is always connected.
-/
theorem ripsConnected_at_diam {n : ℕ} (_hn : 0 < n)
    (d : Fin n → Fin n → ℝ) (_hm : IsFiniteMetric d)
    (D : ℝ) (hD : ∀ i j : Fin n, d i j ≤ D) :
    RipsConnected d D := by
  exact fun i j => if hij : i = j then hij ▸ RipsPath.refl i else ripsPath_of_le hij ( hD i j )