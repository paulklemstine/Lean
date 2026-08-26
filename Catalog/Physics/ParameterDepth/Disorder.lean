import Physics.ParameterDepth.Universality

/-!
# Parameter-derived depth, VII: quenched disorder in the branching schedule

Real foams do not branch uniformly.  Let a **schedule** `r : ℕ → ℕ` prescribe the
branching number used at each level, so that a level-`k` cell family has

`schedWeight r k = r 0 · r 1 ⋯ r (k-1)`

members and a cascade of depth `d` costs `schedCells r d = ∑_{k ≤ d} schedWeight r k`.

**Main theorem** (`disorderedDepth_bounds`).  If the schedule is *quenched* between two
branching numbers, `Bmin ≤ r k ≤ Bmax` with `2 ≤ Bmin`, then for every budget `T` the
maximal supported depth obeys

`Nat.log Bmax T - (Nat.log Bmax 2 + 1) ≤ maxDepth (schedCells r) T ≤ Nat.log Bmin T`.

Disorder therefore cannot destroy the logarithmic depth law: it can only move the depth
inside the window between the two extreme logarithms, uniformly in `T`.  Specialising
`Bmin = Bmax = B` returns the homogeneous result of `Universality`
(`disorderedDepth_homogeneous`).

A concrete disordered instance is computed exactly: the alternating schedule
`2, 3, 2, 3, …` with a budget of `100` cells supports depth exactly `4`
(`alternatingDepth_hundred`), with maximality proved from the frontier, not asserted.
-/

namespace Physics.ParameterDepth

open Finset

/-- Size of a level-`k` cell family under the branching schedule `r`. -/
def schedWeight (r : ℕ → ℕ) (k : ℕ) : ℕ := ∏ j ∈ range k, r j

/-- Total cost of a disordered cascade of depth `d`. -/
def schedCells (r : ℕ → ℕ) (d : ℕ) : ℕ := ∑ k ∈ range (d + 1), schedWeight r k

@[simp] theorem schedWeight_zero (r : ℕ → ℕ) : schedWeight r 0 = 1 := by simp [schedWeight]

theorem schedCells_succ (r : ℕ → ℕ) (d : ℕ) :
    schedCells r (d + 1) = schedCells r d + schedWeight r (d + 1) := by
  simp [schedCells, Finset.sum_range_succ]

theorem schedWeight_pos {r : ℕ → ℕ} (hr : ∀ k, 1 ≤ r k) (k : ℕ) : 0 < schedWeight r k :=
  Finset.prod_pos fun j _ => hr j

/-- Under a schedule bounded below by `Bmin`, level `k` has at least `Bmin^k` cells. -/
theorem pow_le_schedWeight {r : ℕ → ℕ} {Bmin : ℕ} (hr : ∀ k, Bmin ≤ r k) (k : ℕ) :
    Bmin ^ k ≤ schedWeight r k := by
  have : ∏ _j ∈ range k, Bmin ≤ ∏ j ∈ range k, r j :=
    Finset.prod_le_prod' fun j _ => hr j
  simpa [schedWeight] using this

/-- …and at most `Bmax^k` if the schedule is bounded above by `Bmax`. -/
theorem schedWeight_le_pow {r : ℕ → ℕ} {Bmax : ℕ} (hr : ∀ k, r k ≤ Bmax) (k : ℕ) :
    schedWeight r k ≤ Bmax ^ k := by
  have : ∏ j ∈ range k, r j ≤ ∏ _j ∈ range k, Bmax :=
    Finset.prod_le_prod' fun j _ => hr j
  simpa [schedWeight] using this

theorem pow_le_schedCells {r : ℕ → ℕ} {Bmin : ℕ} (hr : ∀ k, Bmin ≤ r k) (d : ℕ) :
    Bmin ^ d ≤ schedCells r d := by
  refine le_trans (pow_le_schedWeight hr d) ?_
  refine Finset.single_le_sum (f := fun k => schedWeight r k) (fun _ _ => Nat.zero_le _) ?_
  simp

theorem schedCells_le_foamCells {r : ℕ → ℕ} {Bmax : ℕ} (hr : ∀ k, r k ≤ Bmax) (d : ℕ) :
    schedCells r d ≤ foamCells Bmax d :=
  Finset.sum_le_sum fun k _ => schedWeight_le_pow hr k

theorem schedCells_strictMono {r : ℕ → ℕ} (hr : ∀ k, 1 ≤ r k) : StrictMono (schedCells r) := by
  refine strictMono_nat_of_lt_succ fun d => ?_
  have := schedWeight_pos hr (d + 1)
  rw [schedCells_succ]
  omega

/-- **Disorder cannot break the logarithmic depth law.**  A branching schedule quenched
between `Bmin` and `Bmax` has maximal supported depth trapped between the two
corresponding logarithms of the budget, with an additive constant independent of `T`. -/
theorem disorderedDepth_bounds {r : ℕ → ℕ} {Bmin Bmax T : ℕ} (hmin : 2 ≤ Bmin)
    (hlo : ∀ k, Bmin ≤ r k) (hhi : ∀ k, r k ≤ Bmax) (hT : 1 ≤ T) :
    Nat.log Bmax T - (Nat.log Bmax 2 + 1) ≤ maxDepth (schedCells r) T ∧
      maxDepth (schedCells r) T ≤ Nat.log Bmin T := by
  have hr1 : ∀ k, 1 ≤ r k := fun k => le_trans (by omega) (hlo k)
  have hmax : 2 ≤ Bmax := le_trans hmin (le_trans (hlo 0) (hhi 0))
  have h0 : Supported (schedCells r) T 0 := by
    simpa [Supported, schedCells] using hT
  constructor
  · refine log_sub_le_maxDepth (B := Bmax) (K := 2) hmax (schedCells_strictMono hr1) ?_ hT
    intro d
    exact le_trans (schedCells_le_foamCells hhi d) (foamCells_le_two_mul_pow hmax d)
  · exact maxDepth_le_log hmin hT (pow_le_schedCells hlo) h0

/-- Homogeneous specialisation: with `r ≡ B` the window closes to the constant
`Nat.log B 2 + 1 ≤ 2` of the ordered theory. -/
theorem disorderedDepth_homogeneous {B T : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T) :
    Nat.log B T - (Nat.log B 2 + 1) ≤ maxDepth (schedCells fun _ => B) T ∧
      maxDepth (schedCells fun _ => B) T ≤ Nat.log B T :=
  disorderedDepth_bounds (r := fun _ => B) (Bmin := B) (Bmax := B) hB
    (fun _ => le_rfl) (fun _ => le_rfl) hT

/-- The homogeneous schedule really does reproduce the tree count of `TreeDepth`. -/
theorem schedCells_const (B d : ℕ) : schedCells (fun _ => B) d = foamCells B d := by
  simp [schedCells, foamCells, schedWeight]

/-! ### A computed disordered instance -/

/-- The alternating branching schedule `2, 3, 2, 3, …`. -/
def altSchedule : ℕ → ℕ := fun k => if k % 2 = 0 then 2 else 3

theorem altSchedule_bounds (k : ℕ) : 2 ≤ altSchedule k ∧ altSchedule k ≤ 3 := by
  unfold altSchedule
  split <;> omega

/-- Cell counts of the alternating cascade: `1, 3, 9, 21, 57, 129, …`. -/
theorem altSchedule_cells_four : schedCells altSchedule 4 = 57 := by
  simp [schedCells, schedWeight, Finset.sum_range_succ, Finset.prod_range_succ, altSchedule]

theorem altSchedule_cells_five : schedCells altSchedule 5 = 129 := by
  simp [schedCells, schedWeight, Finset.sum_range_succ, Finset.prod_range_succ, altSchedule]

/-- **Concrete disordered depth.**  Under the alternating `2,3` schedule a budget of `100`
cells supports depth exactly `4` — and no more. -/
theorem alternatingDepth_hundred : maxDepth (schedCells altSchedule) 100 = 4 := by
  have hr1 : ∀ k, 1 ≤ altSchedule k := fun k => le_trans (by omega) (altSchedule_bounds k).1
  refine maxDepth_eq_of_frontier (schedCells_strictMono hr1) ?_ ?_
  · simp [Supported, altSchedule_cells_four]
  · simp [Supported, altSchedule_cells_five]

/-- The computed disordered depth sits inside the window predicted by
`disorderedDepth_bounds`: `Nat.log 3 100 - (Nat.log 3 2 + 1) = 3 ≤ 4 ≤ 6 = Nat.log 2 100`. -/
theorem alternatingDepth_hundred_in_window :
    Nat.log 3 100 - (Nat.log 3 2 + 1) ≤ maxDepth (schedCells altSchedule) 100 ∧
      maxDepth (schedCells altSchedule) 100 ≤ Nat.log 2 100 :=
  disorderedDepth_bounds (r := altSchedule) (Bmin := 2) (Bmax := 3) (by norm_num)
    (fun k => (altSchedule_bounds k).1) (fun k => (altSchedule_bounds k).2) (by norm_num)

end Physics.ParameterDepth