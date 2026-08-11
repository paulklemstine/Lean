import Mathlib

/-!
# The tropical Life automaton on a torus

`Computation/TropicalAlgebra/Circuits.lean` builds Boolean gate gadgets for the "tropical
Life" cellular automaton, but the module defining the automaton itself was missing from the
repository, so that file could not be compiled.  This file supplies the missing base theory,
exactly in the form the gadget file uses it:

* `Cell n m` — a cell of the `n × m` torus;
* `Config n m` — a configuration, giving each cell a tropical multiplicity (`0` = dead,
  nonzero = alive);
* `aliveAt` — the Boolean indicator of a cell being alive;
* `liveNeighbours` — the number of live cells among the eight torus-neighbours; in the
  min-plus reading this is the tropical product of the neighbourhood, i.e. the *sum* of the
  neighbouring indicators;
* `tropicalLifeStep` — one step of the Life rule stated in the gadget file's own
  documentation: a dead cell is **born** iff it has exactly three live neighbours, and a live
  cell **survives** iff it has two or three.

Two structural facts are proved here, so that the theory is not merely a definition:
`tropicalLifeStep_zero_or_one` — the automaton takes only the values `0` and `1`, hence the
space of Boolean configurations is invariant — and `liveNeighbours_le_eight`, the sharp
bound on the neighbour count that makes the birth threshold `3` and the survival window
`{2, 3}` genuine constraints.
-/

/-- A cell of the `n × m` discrete torus. -/
abbrev Cell (n m : ℕ) : Type := Fin n × Fin m

/-- A configuration of the automaton: a tropical multiplicity at each cell, with `0` read as
"dead" and any nonzero value as "alive". -/
abbrev Config (n m : ℕ) : Type := Cell n m → ℕ

variable {n m : ℕ}

/-- The indicator of "the cell `y` is alive in the configuration `c`". -/
def aliveAt (c : Config n m) (y : Cell n m) : ℕ := if c y = 0 then 0 else 1

theorem aliveAt_le_one (c : Config n m) (y : Cell n m) : aliveAt c y ≤ 1 := by
  unfold aliveAt; split <;> omega

/-- Number of live cells among the eight torus-neighbours: in the min-plus reading, the
tropical product of the neighbourhood.  The neighbours are taken with the cyclic (`Fin`)
arithmetic of the torus. -/
def liveNeighbours (hn : 0 < n) (hm : 0 < m) (c : Config n m) (x : Cell n m) : ℕ :=
  haveI : NeZero n := ⟨by omega⟩
  haveI : NeZero m := ⟨by omega⟩
  let i := x.1
  let j := x.2
  aliveAt c (i - 1, j - 1) + aliveAt c (i - 1, j) + aliveAt c (i - 1, j + 1)
    + aliveAt c (i, j - 1) + aliveAt c (i, j + 1)
    + aliveAt c (i + 1, j - 1) + aliveAt c (i + 1, j) + aliveAt c (i + 1, j + 1)

/-- One step of the tropical Life rule: birth on exactly three live neighbours, survival on
two or three. -/
def tropicalLifeStep (hn : 0 < n) (hm : 0 < m) (c : Config n m) : Config n m :=
  fun x =>
    let k := liveNeighbours hn hm c x
    if c x = 0 then (if k = 3 then 1 else 0)
    else (if k = 2 ∨ k = 3 then 1 else 0)

/-- The automaton is Boolean-valued: every cell of the next configuration is `0` or `1`. -/
theorem tropicalLifeStep_zero_or_one (hn : 0 < n) (hm : 0 < m) (c : Config n m)
    (x : Cell n m) :
    tropicalLifeStep hn hm c x = 0 ∨ tropicalLifeStep hn hm c x = 1 := by
  unfold tropicalLifeStep
  dsimp only
  split
  · split
    · exact Or.inr rfl
    · exact Or.inl rfl
  · split
    · exact Or.inr rfl
    · exact Or.inl rfl

/-- A cell has at most eight live neighbours. -/
theorem liveNeighbours_le_eight (hn : 0 < n) (hm : 0 < m) (c : Config n m) (x : Cell n m) :
    liveNeighbours hn hm c x ≤ 8 := by
  haveI : NeZero n := ⟨by omega⟩
  haveI : NeZero m := ⟨by omega⟩
  unfold liveNeighbours
  dsimp only
  have h1 := aliveAt_le_one c ((x.1 - 1, x.2 - 1) : Cell n m)
  have h2 := aliveAt_le_one c ((x.1 - 1, x.2) : Cell n m)
  have h3 := aliveAt_le_one c ((x.1 - 1, x.2 + 1) : Cell n m)
  have h4 := aliveAt_le_one c ((x.1, x.2 - 1) : Cell n m)
  have h5 := aliveAt_le_one c ((x.1, x.2 + 1) : Cell n m)
  have h6 := aliveAt_le_one c ((x.1 + 1, x.2 - 1) : Cell n m)
  have h7 := aliveAt_le_one c ((x.1 + 1, x.2) : Cell n m)
  have h8 := aliveAt_le_one c ((x.1 + 1, x.2 + 1) : Cell n m)
  omega