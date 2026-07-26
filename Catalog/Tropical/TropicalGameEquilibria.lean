/-
# Tropical Rainfall: Nash Equilibria as Min-Plus Fixed Points

This file formalizes the connection between tropical (min-plus) algebra and
game-theoretic equilibrium concepts. We define the tropical Bellman/Shapley
operator, prove that its fixed points characterize tropical equilibria,
establish monotonicity, idempotence under min-plus matrix idempotence,
and prove a tropical minimax inequality with equality under saddle-point conditions.

## Main results

* `isTropFixedPoint_iff_coord` — Fixed point ↔ coordinatewise Bellman equations
* `tropBellman_monotone` — The Bellman operator is monotone
* `tropBellman_idempotent_of_matrix` — Min-plus idempotent matrix ⟹ idempotent operator
* `tropBellman_image_fixed` — Image points are fixed points under idempotence
* `trop_lowerValue_le_upperValue` — Tropical minimax inequality
* `trop_minimax_eq_of_saddle` — Saddle point ⟹ minimax equality
* `fixedPoints_eq_range_tropBellman` — Fixed-point set = image under idempotence
-/

import Mathlib

open Matrix Finset

variable {n : ℕ} [NeZero n]

/-! ## Core Definitions -/

/-- The tropical Bellman (Shapley) operator: `T_A(x)_i = min_j (A i j + x j)`. -/
noncomputable def tropBellman (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + x j)

/-- A vector `v` is a tropical fixed point of `A` when `T_A(v) = v`. -/
def IsTropFixedPoint (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) : Prop :=
  tropBellman A v = v

/-- A matrix is min-plus idempotent when `A ⊗ A = A` in the min-plus semiring:
    `min_j (A i j + A j k) = A i k` for all `i, k`. -/
def MinPlusIdempotent (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ i k, Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + A j k) = A i k

/-- A tropical saddle point: there exist `i₀, j₀` such that
    `A i₀ j₀ ≤ A i₀ j` for all `j` and `A i j₀ ≤ A i₀ j₀` for all `i`. -/
def HasTropSaddle (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ i0 j0, (∀ j, A i0 j0 ≤ A i0 j) ∧ (∀ i, A i j0 ≤ A i0 j0)

/-- Row minimum: `min_j A i j`. -/
noncomputable def rowMin (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty (fun j => A i j)

/-- Column maximum: `max_i A i j`. -/
noncomputable def colMax (A : Matrix (Fin n) (Fin n) ℝ) (j : Fin n) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => A i j)

/-- Tropical lower value (max-min): `max_i min_j A i j`. -/
noncomputable def tropLowerValue (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => rowMin A i)

/-- Tropical upper value (min-max): `min_j max_i A i j`. -/
noncomputable def tropUpperValue (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty (fun j => colMax A j)

/-! ## Theorem 1: Fixed point ↔ coordinatewise Bellman equations -/

/-
A vector is a tropical fixed point iff each coordinate satisfies the Bellman equation.
-/
theorem isTropFixedPoint_iff_coord (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) :
    IsTropFixedPoint A v ↔
      ∀ i, Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + v j) = v i := by
  exact ⟨ fun h i => congr_fun h i, fun h => funext h ⟩

/-! ## Theorem 2: Monotonicity of Bellman operator -/

/-
The tropical Bellman operator is monotone with respect to the pointwise order.
-/
theorem tropBellman_monotone (A : Matrix (Fin n) (Fin n) ℝ) :
    Monotone (tropBellman A) := by
  intro x y hxy i; unfold tropBellman; simp +decide;
  exact fun j => ⟨ j, by linarith [ hxy j ] ⟩

/-! ## Helper lemmas for idempotence -/

/-
Row minimum is bounded by any entry.
-/
theorem rowMin_le_entry (A : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    rowMin A i ≤ A i j := by
  exact Finset.inf'_le _ ( Finset.mem_univ _ )

/-
Any entry is bounded by the column maximum.
-/
theorem entry_le_colMax (A : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    A i j ≤ colMax A j := by
  exact Finset.le_sup' ( fun i => A i j ) ( Finset.mem_univ i )

/-! ## Theorem 3: Idempotent matrix ⟹ idempotent operator -/

/-
If the matrix `A` is min-plus idempotent, then the Bellman operator `T_A` is
    function-theoretically idempotent: `T_A ∘ T_A = T_A`.
-/
theorem tropBellman_idempotent_of_matrix
    (A : Matrix (Fin n) (Fin n) ℝ) (hA : MinPlusIdempotent A) :
    ∀ x, tropBellman A (tropBellman A x) = tropBellman A x := by
  intro x
  funext i
  apply le_antisymm;
  · simp +decide only [tropBellman];
    simp +decide only [le_inf'_iff, mem_univ, inf'_le_iff, true_and];
    intro j _;
    have := hA i j;
    obtain ⟨ l, hl ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty ( fun j_1 => A i j_1 + A j_1 j ) ; use l; simp_all +decide;
    linarith [ show univ.inf' ( Finset.univ_nonempty ) ( fun j_1 => A l j_1 + x j_1 ) ≤ A l j + x j from Finset.inf'_le _ ( Finset.mem_univ _ ) ];
  · simp +decide [ tropBellman ];
    intro j;
    -- By definition of infimum, there exists some $k$ such that $A j k + x k \leq \inf_{j_1} (A j j_1 + x j_1)$.
    obtain ⟨k, hk⟩ : ∃ k, A j k + x k ≤ Finset.univ.inf' Finset.univ_nonempty (fun j_1 => A j j_1 + x j_1) := by
      have := Finset.exists_min_image Finset.univ ( fun k => A j k + x k ) ⟨ j, Finset.mem_univ j ⟩ ; aesop;
    exact ⟨ k, by linarith [ hA i k |> fun h => h ▸ Finset.inf'_le _ ( Finset.mem_univ j ) ] ⟩

/-! ## Theorem 4: Image points are fixed under idempotence -/

/-- Under min-plus idempotence, every image point `T_A(x)` is a fixed point. -/
theorem tropBellman_image_fixed
    (A : Matrix (Fin n) (Fin n) ℝ) (hA : MinPlusIdempotent A) (x : Fin n → ℝ) :
    IsTropFixedPoint A (tropBellman A x) := by
  exact tropBellman_idempotent_of_matrix A hA x

/-! ## Theorem 5: Tropical minimax inequality -/

/-
The tropical minimax inequality: `max_i min_j A_{ij} ≤ min_j max_i A_{ij}`.
-/
theorem trop_lowerValue_le_upperValue (A : Matrix (Fin n) (Fin n) ℝ) :
    tropLowerValue A ≤ tropUpperValue A := by
  apply Finset.sup'_le;
  simp +zetaDelta at *;
  intro i;
  apply Finset.le_inf';
  exact fun j _ => le_trans ( rowMin_le_entry A i j ) ( entry_le_colMax A i j )

/-! ## Theorem 6: Saddle ⟹ minimax equality -/

/-
If `A` has a tropical saddle point, the minimax inequality is tight.
-/
theorem trop_minimax_eq_of_saddle (A : Matrix (Fin n) (Fin n) ℝ)
    (hS : HasTropSaddle A) :
    tropLowerValue A = tropUpperValue A := by
  obtain ⟨ i0, j0, h1, h2 ⟩ := hS;
  refine' le_antisymm _ _;
  · exact trop_lowerValue_le_upperValue A;
  · refine' le_trans _ ( Finset.le_sup' _ ( Finset.mem_univ i0 ) );
    refine' Finset.inf'_le _ ( Finset.mem_univ j0 ) |> le_trans <| _;
    exact Finset.sup'_le _ _ fun i _ => h2 i |> le_trans <| Finset.le_inf' _ _ fun j _ => h1 j

/-! ## Theorem 7: Fixed-point set = image under idempotence -/

/-
Under min-plus idempotence, the set of fixed points of `T_A` equals the range of `T_A`.
-/
theorem fixedPoints_eq_range_tropBellman
    (A : Matrix (Fin n) (Fin n) ℝ) (hA : MinPlusIdempotent A) :
    {v | IsTropFixedPoint A v} = Set.range (tropBellman A) := by
  ext v;
  constructor;
  · exact fun h => ⟨ v, h ⟩;
  · rintro ⟨ x, rfl ⟩ ; exact tropBellman_image_fixed A hA x;

/-! ## Saddle point value theorem -/

/-
At a tropical saddle point, the game value equals `A i₀ j₀`.
-/
theorem trop_saddle_value (A : Matrix (Fin n) (Fin n) ℝ)
    (i0 j0 : Fin n) (hrow : ∀ j, A i0 j0 ≤ A i0 j) (hcol : ∀ i, A i j0 ≤ A i0 j0) :
    tropLowerValue A = A i0 j0 ∧ tropUpperValue A = A i0 j0 := by
  constructor <;> refine' le_antisymm _ _ <;> norm_num [ tropLowerValue, tropUpperValue ];
  · exact fun i => le_trans ( rowMin_le_entry _ _ _ ) ( hcol _ );
  · exact ⟨ i0, Finset.le_inf' _ _ fun j _ => hrow j ⟩;
  · exact ⟨ j0, Finset.sup'_le _ _ fun i _ => hcol i ⟩;
  · exact fun j => le_trans ( hrow j ) ( Finset.le_sup' ( fun i => A i j ) ( Finset.mem_univ i0 ) )