import Mathlib

/-!
# The tropical Life automaton on a discrete torus

`Computation.TropicalAlgebra.Circuits` builds Boolean gate gadgets for the
"tropical Life" cellular automaton, but the module providing the underlying
definitions is missing from this snapshot.  This file restores them exactly as
described there:

* a configuration on the `n × m` torus assigns a natural number (`0` = dead,
  `1` = alive) to every cell;
* the neighbourhood of a cell is the eight cells obtained by shifting the two
  coordinates cyclically by `-1, 0, 1` (excluding the cell itself);
* **birth**: a dead cell becomes alive iff exactly `3` neighbours are alive;
* **survival**: a live cell stays alive iff `2` or `3` neighbours are alive.

The positivity hypotheses `0 < n`, `0 < m` are what makes the cyclic shifts
well defined.
-/

/-- A cell of the `n × m` torus. -/
abbrev Cell (n m : ℕ) := Fin n × Fin m

/-- A configuration of the automaton: `0` means dead, a positive value means
alive. -/
abbrev Config (n m : ℕ) := Cell n m → ℕ

namespace TropicalLife

/-- Cyclic shift of a coordinate by `d`. -/
def shift {n : ℕ} (hn : 0 < n) (i : Fin n) (d : ℕ) : Fin n :=
  ⟨(i.val + d) % n, Nat.mod_lt _ hn⟩

/-- The eight offsets defining the Moore neighbourhood, expressed as pairs of
cyclic shifts by `n - 1` (i.e. `-1`), `0` and `1`. -/
def offsets (n m : ℕ) : List (ℕ × ℕ) :=
  [(n - 1, m - 1), (n - 1, 0), (n - 1, 1),
   (0, m - 1), (0, 1),
   (1, m - 1), (1, 0), (1, 1)]

/-- The eight neighbours of a cell on the torus. -/
def neighbors {n m : ℕ} (hn : 0 < n) (hm : 0 < m) (c : Cell n m) : List (Cell n m) :=
  (offsets n m).map fun d => (shift hn c.1 d.1, shift hm c.2 d.2)

/-- The number of live neighbours of a cell. -/
def liveNeighbors {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (cfg : Config n m) (c : Cell n m) : ℕ :=
  ((neighbors hn hm c).filter fun x => 0 < cfg x).length

/-- One step of the tropical Life rule: birth on exactly three live
neighbours, survival on two or three. -/
def step {n m : ℕ} (hn : 0 < n) (hm : 0 < m) (cfg : Config n m) : Config n m :=
  fun c =>
    let k := liveNeighbors hn hm cfg c
    if 0 < cfg c then (if k = 2 ∨ k = 3 then 1 else 0)
    else (if k = 3 then 1 else 0)

end TropicalLife

/-- One step of the tropical Life automaton. -/
def tropicalLifeStep {n m : ℕ} (hn : 0 < n) (hm : 0 < m) (cfg : Config n m) :
    Config n m :=
  TropicalLife.step hn hm cfg

/-- A dead cell with exactly three live neighbours is born. -/
theorem tropicalLifeStep_birth {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (cfg : Config n m) (c : Cell n m) (hdead : cfg c = 0)
    (hk : TropicalLife.liveNeighbors hn hm cfg c = 3) :
    tropicalLifeStep hn hm cfg c = 1 := by
  simp [tropicalLifeStep, TropicalLife.step, hdead, hk]

/-- A live cell with two or three live neighbours survives. -/
theorem tropicalLifeStep_survival {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (cfg : Config n m) (c : Cell n m) (halive : 0 < cfg c)
    (hk : TropicalLife.liveNeighbors hn hm cfg c = 2 ∨
      TropicalLife.liveNeighbors hn hm cfg c = 3) :
    tropicalLifeStep hn hm cfg c = 1 := by
  simp [tropicalLifeStep, TropicalLife.step, halive, hk]

/-- Every cell of a stepped configuration is dead or alive. -/
theorem tropicalLifeStep_le_one {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (cfg : Config n m) (c : Cell n m) : tropicalLifeStep hn hm cfg c ≤ 1 := by
  unfold tropicalLifeStep TropicalLife.step
  dsimp only
  split <;> split <;> simp

/-- Each cell has exactly eight neighbours, so the live-neighbour count never
exceeds `8`. -/
theorem liveNeighbors_le_eight {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (cfg : Config n m) (c : Cell n m) :
    TropicalLife.liveNeighbors hn hm cfg c ≤ 8 := by
  have hlen : (TropicalLife.neighbors hn hm c).length = 8 := by
    simp [TropicalLife.neighbors, TropicalLife.offsets]
  calc TropicalLife.liveNeighbors hn hm cfg c
      ≤ (TropicalLife.neighbors hn hm c).length :=
        List.length_filter_le _ _
    _ = 8 := hlen