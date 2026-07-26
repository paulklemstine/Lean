import Mathlib

/-!
# Reflection duality for d-balanced partitions

Fix integers `d, e > 1`.  A Young diagram `μ` is *d-balanced* with respect to `e`
if every hook whose length is divisible by `e` has arm divisible by `d`.  Dually,
`μ` is *leg-d-balanced* if every `e`-divisible hook has leg divisible by `d`.

Transposition swaps arm and leg, so being d-balanced after transposition equals
being leg-d-balanced before.  This is the content of
`isDBalanced_transpose_iff_isLegBalanced`.
-/

namespace DBalanced

open YoungDiagram

/-- Number of cells strictly to the right of `(i, j)` in row `i`. -/
def arm (μ : YoungDiagram) (i j : ℕ) : ℕ := μ.rowLen i - (j + 1)

/-- Number of cells in column `j`, defined via the transpose to avoid API gaps. -/
def colLen (μ : YoungDiagram) (j : ℕ) : ℕ := μ.transpose.rowLen j

/-- Number of cells strictly below `(i, j)` in column `j`. -/
def leg (μ : YoungDiagram) (i j : ℕ) : ℕ := colLen μ j - (i + 1)

/-- The hook length of the cell `(i, j)`. -/
def hookLength (μ : YoungDiagram) (i j : ℕ) : ℕ := arm μ i j + leg μ i j + 1

/-- `μ` is d-balanced w.r.t. `e`: every `e`-divisible hook has `d`-divisible arm. -/
def IsDBalanced (d e : ℕ) (μ : YoungDiagram) : Prop :=
  ∀ i j, (i, j) ∈ μ → e ∣ hookLength μ i j → d ∣ arm μ i j

/-- `μ` is leg-d-balanced w.r.t. `e`: every `e`-divisible hook has `d`-divisible leg. -/
def IsLegBalanced (d e : ℕ) (μ : YoungDiagram) : Prop :=
  ∀ i j, (i, j) ∈ μ → e ∣ hookLength μ i j → d ∣ leg μ i j

/-- The arm of `(j, i)` in the transpose equals the leg of `(i, j)`. -/
lemma arm_of_transpose (μ : YoungDiagram) (i j : ℕ) :
    arm μ.transpose j i = leg μ i j := by
  rfl

/-- The leg of `(j, i)` in the transpose equals the arm of `(i, j)`. -/
lemma leg_of_transpose (μ : YoungDiagram) (i j : ℕ) :
    leg μ.transpose j i = arm μ i j := by
  unfold leg colLen arm
  rw [transpose_transpose]

/-- Hook length is invariant under transposition (with swapped coordinates). -/
lemma hookLength_of_transpose (μ : YoungDiagram) (i j : ℕ) :
    hookLength μ.transpose j i = hookLength μ i j := by
  unfold hookLength
  rw [arm_of_transpose, leg_of_transpose]
  ring

/-- Membership in the transpose swaps coordinates. -/
lemma mem_transpose_iff (μ : YoungDiagram) (i j : ℕ) :
    (j, i) ∈ μ.transpose ↔ (i, j) ∈ μ := by
  rw [mem_transpose]
  rfl

/-- **Reflection duality**: `μ.transpose` is d-balanced iff `μ` is leg-d-balanced. -/
theorem isDBalanced_transpose_iff_isLegBalanced (d e : ℕ) (μ : YoungDiagram) :
    IsDBalanced d e μ.transpose ↔ IsLegBalanced d e μ := by
  constructor
  · intro h i j hmem hdiv
    have hmem' : (j, i) ∈ μ.transpose := (mem_transpose_iff μ i j).2 hmem
    have hdiv' : e ∣ hookLength μ.transpose j i := by
      rw [hookLength_of_transpose]; exact hdiv
    have := h j i hmem' hdiv'
    rwa [arm_of_transpose] at this
  · intro h j i hmem hdiv
    have hmem' : (i, j) ∈ μ := (mem_transpose_iff μ i j).1 hmem
    have hdiv' : e ∣ hookLength μ i j := by
      rw [← hookLength_of_transpose]; exact hdiv
    have := h i j hmem' hdiv'
    rw [← arm_of_transpose] at this
    exact this

end DBalanced