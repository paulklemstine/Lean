import Mathlib

/-!
# Conway's Game of Life: local semantics and finite simulation cones

This file gives a self-contained formalization of Conway's rule on `ℤ × ℤ` and a
constructive chain of results about exact local simulation. The final results prove
that the value of a cell after `t` generations is determined by an explicitly finite
set of initial cells, identify that recursive dependency cone with the radius-`t`
Chebyshev ball, and compute its exact cardinality as `(2t+1)²`.

This is foundational infrastructure toward a direct universality proof; it does not
claim the still-missing construction of wires, clocks, and a universal machine.
-/

namespace GameOfLife

abbrev Cell := ℤ × ℤ
abbrev Config := Cell → Bool

/-- The eight cells in the Moore neighborhood. -/
def neighbors (p : Cell) : Finset Cell :=
  { (p.1 - 1, p.2 - 1), (p.1 - 1, p.2), (p.1 - 1, p.2 + 1),
    (p.1, p.2 - 1),                     (p.1, p.2 + 1),
    (p.1 + 1, p.2 - 1), (p.1 + 1, p.2), (p.1 + 1, p.2 + 1) }

/-- The closed Moore neighborhood, including the cell itself. -/
def closedNeighbors (p : Cell) : Finset Cell := insert p (neighbors p)

/-- Number of live Moore neighbors. -/
def liveNeighborCount (c : Config) (p : Cell) : ℕ :=
  ∑ q ∈ neighbors p, (c q).toNat

/-- Conway's B3/S23 local rule. -/
def lifeRule (currentlyAlive : Bool) (n : ℕ) : Bool :=
  decide (n = 3 ∨ (currentlyAlive = true ∧ n = 2))

/-- One synchronous generation of Conway's Game of Life. -/
def step (c : Config) : Config := fun p => lifeRule (c p) (liveNeighborCount c p)

/-- Evolution for exactly `t` generations. -/
def evolve (t : ℕ) (c : Config) : Config := step^[t] c

/-- The Moore neighborhood really has eight distinct cells. -/
theorem neighbors_card (p : Cell) : (neighbors p).card = 8 := by
  rw [neighbors, Finset.card_insert_of_notMem, Finset.card_insert_of_notMem, 
      Finset.card_insert_of_notMem, Finset.card_insert_of_notMem,
      Finset.card_insert_of_notMem, Finset.card_insert_of_notMem,
      Finset.card_insert_of_notMem, Finset.card_singleton]
  all_goals simp [Finset.mem_insert, Finset.mem_singleton, Prod.ext_iff, eq_comm]; all_goals omega

/-- Consequently, no cell can have more than eight live neighbors. -/
theorem liveNeighborCount_le_eight (c : Config) (p : Cell) :
    liveNeighborCount c p ≤ 8 := by
  simp [liveNeighborCount]
  calc ∑ q ∈ neighbors p, (c q).toNat
      ≤ ∑ _q ∈ neighbors p, (1 : ℕ) := by
        apply Finset.sum_le_sum
        intro q _
        cases c q <;> simp
    _   = (neighbors p).card := by simp
    _   = 8 := neighbors_card p

/-- A dead cell with no live neighbors remains dead. -/
theorem lifeRule_dead_zero : lifeRule false 0 = false := by
  decide

/-- The all-dead configuration is stable for one generation. -/
theorem step_allDead : step (fun _ => false) = fun _ => false := by
  funext p
  simp [step, lifeRule, liveNeighborCount]

/-- The all-dead configuration is stable for every finite number of generations. -/
theorem evolve_allDead (t : ℕ) : evolve t (fun _ => false) = fun _ => false := by
  induction t with
  | zero => rfl
  | succ t ih => rw [evolve, Function.iterate_succ_apply, step_allDead]; exact ih

/-- Agreement on the closed neighborhood suffices to determine the next state. -/
theorem step_eq_of_eq_on_closedNeighbors {c d : Config} {p : Cell}
    (h : ∀ q ∈ closedNeighbors p, c q = d q) : step c p = step d p := by
  unfold step
  have hp : c p = d p := h p (Finset.mem_insert_self p (neighbors p))
  have hneighbors : ∀ q ∈ neighbors p, c q = d q := fun q hq => h q (Finset.mem_insert_of_mem hq)
  have hcount : liveNeighborCount c p = liveNeighborCount d p := by
    unfold liveNeighborCount
    apply Finset.sum_congr rfl
    intro q hq
    simp [hneighbors q hq]
  rw [hp, hcount]

/-- The explicit finite set of initial cells inspected by the recursive simulator. -/
def dependencyCone : ℕ → Cell → Finset Cell
  | 0, p => {p}
  | t + 1, p => (dependencyCone t p).biUnion closedNeighbors

/-- The initial cell belongs to its time-zero dependency cone. -/
theorem mem_dependencyCone_zero (p : Cell) : p ∈ dependencyCone 0 p := by
  simp [dependencyCone]

/-- Each successive dependency cone is the union of closed neighborhoods of the
previous cone. -/
theorem dependencyCone_succ (t : ℕ) (p : Cell) :
    dependencyCone (t + 1) p = (dependencyCone t p).biUnion closedNeighbors := by
  simp only [dependencyCone]

/-- Constructive finite-cone simulation theorem: agreement on the explicit dependency
cone guarantees equal output after `t` generations. -/
theorem evolve_eq_of_eq_on_dependencyCone (t : ℕ) {c d : Config} {p : Cell}
    (h : ∀ q ∈ dependencyCone t p, c q = d q) : evolve t c p = evolve t d p := by
  -- Helper: dependency cone subset
  have hsub : ∀ t' r q, q ∈ closedNeighbors r → dependencyCone t' q ⊆ dependencyCone (t' + 1) r := by
    refine fun t' => Nat.rec ?_ ?_ t'
    · intro r q hq; simp [dependencyCone]; exact hq
    · intro t'' ht'' r q hq
      rw [dependencyCone_succ, dependencyCone_succ]
      apply Finset.biUnion_subset.mpr
      intro s hs
      apply Finset.subset_biUnion_of_mem
      exact ht'' r q hq hs
  -- Generalize to all cells at once
  have hgen : ∀ t, ∀ r, (∀ q ∈ dependencyCone t r, c q = d q) → evolve t c r = evolve t d r := by
    refine fun t => Nat.rec ?_ ?_ t
    · intro r hr; simp [dependencyCone] at hr; simpa [evolve] using hr
    · intro t' ih r hr
      simp only [evolve, Function.iterate_succ_apply']
      apply step_eq_of_eq_on_closedNeighbors
      intro q hq
      apply ih
      intro s hs
      exact hr s (hsub t' r q hq hs)
  exact hgen t p h

/-- A closed Moore neighborhood has exactly nine cells. -/
theorem closedNeighbors_card (p : Cell) : (closedNeighbors p).card = 9 := by
  rw [closedNeighbors, Finset.card_insert_of_notMem]
  · rw [neighbors_card]
  · unfold neighbors
    simp [Finset.mem_insert, Finset.mem_singleton, Prod.ext_iff]
    all_goals omega

/-- The explicit dependency cone has at most `9^t` cells.  Thus direct recursive
simulation of one output cell has a certified finite overhead bound. -/
theorem dependencyCone_card_le (t : ℕ) (p : Cell) :
    (dependencyCone t p).card ≤ 9 ^ t := by
  induction t with
  | zero => simp [dependencyCone]
  | succ t ih =>
    rw [dependencyCone_succ, pow_succ]
    calc ((dependencyCone t p).biUnion closedNeighbors).card
        ≤ ∑ q ∈ dependencyCone t p, (closedNeighbors q).card := Finset.card_biUnion_le
      _ = ∑ _q ∈ dependencyCone t p, 9 := by simp [closedNeighbors_card]
      _ = 9 * (dependencyCone t p).card := by rw [Finset.sum_const, smul_eq_mul, mul_comm]
      _ ≤ 9 * 9 ^ t := by gcongr
      _ = 9 ^ t * 9 := by ring

/-- Combined correctness-and-overhead statement for the finite simulator. -/
theorem finite_simulation_certificate (t : ℕ) (c : Config) (p : Cell) :
    (dependencyCone t p).card ≤ 9 ^ t ∧
    ∀ d : Config, (∀ q ∈ dependencyCone t p, c q = d q) → evolve t c p = evolve t d p := by
  exact ⟨dependencyCone_card_le t p, fun d h => evolve_eq_of_eq_on_dependencyCone t h⟩

/-- The finite square of cells at Chebyshev distance at most `t` from `p`. -/
def chebyshevBall (t : ℕ) (p : Cell) : Finset Cell :=
  (Finset.Icc (p.1 - (t : ℤ)) (p.1 + (t : ℤ))).product
    (Finset.Icc (p.2 - (t : ℤ)) (p.2 + (t : ℤ)))

/-- Membership in a Chebyshev ball is equivalent to four coordinate inequalities. -/
theorem mem_chebyshevBall_iff (t : ℕ) (p q : Cell) :
    q ∈ chebyshevBall t p ↔
      p.1 - (t : ℤ) ≤ q.1 ∧ q.1 ≤ p.1 + (t : ℤ) ∧
      p.2 - (t : ℤ) ≤ q.2 ∧ q.2 ≤ p.2 + (t : ℤ) := by
  unfold chebyshevBall
  simp [Finset.mem_product, Finset.mem_Icc]
  tauto

/-- Conway's closed Moore neighborhood is exactly the radius-one Chebyshev ball. -/
theorem closedNeighbors_eq_chebyshevBall_one (p : Cell) :
    closedNeighbors p = chebyshevBall 1 p := by
  ext q
  rw [mem_chebyshevBall_iff]
  unfold closedNeighbors neighbors
  simp only [Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro (rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl) <;> omega
  · intro h
    rcases q with ⟨x, y⟩
    dsimp at h ⊢
    have hx : x = p.1 - 1 ∨ x = p.1 ∨ x = p.1 + 1 := by omega
    have hy : y = p.2 - 1 ∨ y = p.2 ∨ y = p.2 + 1 := by omega
    rcases hx with hx | hx | hx <;> rcases hy with hy | hy | hy <;>
      simp [Prod.ext_iff, hx, hy]

/-- Finite propagation speed: every initial cell capable of influencing `p` after
`t` generations lies at Chebyshev distance at most `t` from `p`. -/
theorem dependencyCone_subset_chebyshevBall (t : ℕ) (p : Cell) :
    dependencyCone t p ⊆ chebyshevBall t p := by
  induction t with
  | zero =>
    simp [dependencyCone, chebyshevBall]
  | succ t ih =>
    rw [dependencyCone_succ]
    exact (Finset.biUnion_subset).mpr fun q hq => by
      rw [closedNeighbors_eq_chebyshevBall_one]
      have hq_mem := ih hq
      rw [mem_chebyshevBall_iff] at hq_mem
      intro r hr
      rw [mem_chebyshevBall_iff] at hr ⊢
      exact ⟨by omega, by omega, by omega, by omega⟩

/-- A radius-`t` Chebyshev ball in the Life grid has exactly `(2t+1)²` cells. -/
theorem chebyshevBall_card (t : ℕ) (p : Cell) :
    (chebyshevBall t p).card = (2 * t + 1) ^ 2 := by
  unfold chebyshevBall
  simp [Finset.card_product]
  ring_nf
  norm_cast
  ring

/-- Expanding a radius-`t` Chebyshev ball by one closed Moore neighborhood
produces exactly the radius-`t+1` Chebyshev ball. -/
theorem biUnion_chebyshevBall_closedNeighbors (t : ℕ) (p : Cell) :
    (chebyshevBall t p).biUnion closedNeighbors = chebyshevBall (t + 1) p := by
  ext r
  rw [mem_chebyshevBall_iff]
  simp [mem_chebyshevBall_iff, closedNeighbors_eq_chebyshevBall_one]
  constructor
  · intro ⟨a, b, ⟨ha1, ha2, hb1, hb2⟩, hab1, hab2, hab3, hab4⟩
    omega
  · intro ⟨hr1, hr2, hr3, hr4⟩
    use max (p.1 - t) (r.1 - 1), max (p.2 - t) (r.2 - 1)
    omega

/-- The recursively defined dependency cone is exactly the corresponding
Chebyshev ball, not merely a subset of it. -/
theorem dependencyCone_eq_chebyshevBall (t : ℕ) (p : Cell) :
    dependencyCone t p = chebyshevBall t p := by
  induction t with
  | zero => simp [dependencyCone, chebyshevBall]
  | succ t ih =>
    rw [dependencyCone_succ, ih, biUnion_chebyshevBall_closedNeighbors]

/-- The dependency cone therefore has exactly `(2t+1)²` cells. -/
theorem dependencyCone_card_exact (t : ℕ) (p : Cell) :
    (dependencyCone t p).card = (2 * t + 1) ^ 2 := by
  rw [dependencyCone_eq_chebyshevBall, chebyshevBall_card]

/-- The exponential `9^t` dependency bound improves to the geometrically sharp
quadratic ambient bound `(2t+1)²`. -/
theorem dependencyCone_card_le_quadratic (t : ℕ) (p : Cell) :
    (dependencyCone t p).card ≤ (2 * t + 1) ^ 2 := by
  rw [← chebyshevBall_card t p]
  exact Finset.card_le_card (dependencyCone_subset_chebyshevBall t p)

/-- Local simulation certificate with quadratic rather than exponential input size. -/
theorem quadratic_finite_simulation_certificate (t : ℕ) (c : Config) (p : Cell) :
    (dependencyCone t p).card ≤ (2 * t + 1) ^ 2 ∧
    ∀ d : Config, (∀ q ∈ dependencyCone t p, c q = d q) → evolve t c p = evolve t d p := by
  exact ⟨dependencyCone_card_le_quadratic t p,
    fun d h => evolve_eq_of_eq_on_dependencyCone t h⟩

/-- Exact local-simulation certificate: the recursively inspected input region has
precisely `(2t+1)²` cells, and agreement there determines the output cell. -/
theorem exact_finite_simulation_certificate (t : ℕ) (c : Config) (p : Cell) :
    (dependencyCone t p).card = (2 * t + 1) ^ 2 ∧
    ∀ d : Config, (∀ q ∈ dependencyCone t p, c q = d q) → evolve t c p = evolve t d p := by
  exact ⟨dependencyCone_card_exact t p,
    fun d h => evolve_eq_of_eq_on_dependencyCone t h⟩

end GameOfLife