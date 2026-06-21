import Mathlib

/-!
# A finite-support Game of Life step algorithm

This file develops Conway's Game of Life over the infinite integer grid `ℤ × ℤ`,
but represents a configuration by the **finite** set of its live cells
(`Pattern := Finset (ℤ × ℤ)`).  The point of interest is that, although the rule
is naturally phrased as a predicate over *all* cells of the (infinite) grid, a
single generation can be computed by examining only finitely many candidate
cells.

## Main definitions

* `offsets`        — the eight Moore-neighbourhood displacement vectors.
* `neighbors`      — the eight Moore neighbours of a cell.
* `liveNeighborCount` — the number of live Moore neighbours of a cell.
* `globalNext`     — the standard B3/S23 rule as a predicate on a single cell.
  This is the "true" mathematical successor relation; it is defined for *every*
  cell of the grid, independently of any finite bounding box.
* `mooreExpansion` — the finite set of candidate cells (live cells together with
  all their neighbours).  Every cell that *could* be live next generation lies
  here.
* `nextPattern`    — the finite step algorithm: filter the candidate set by the
  rule.

## Main results

* `mem_mooreExpansion_of_globalNext` — the candidate set really does capture
  every newly-live cell.  This is the key non-circular ingredient: it is proved
  directly from the symmetry of the Moore neighbourhood (a finite case analysis
  over `offsets`), *without* referring to `nextPattern`.
* `mem_nextPattern_iff_globalNext` — the finite algorithm computes exactly the
  global rule.  The non-trivial (backward) direction uses the capture lemma
  above, so the proof is not circular.
* `nextPattern_block` — the 2×2 block is a still life.
* `blinker_period_two` — the blinker oscillates with period two.
-/

open Finset

-- The two worked examples (`nextPattern_block`, `blinker_period_two`) discharge
-- finite `Finset (ℤ × ℤ)` computations by `decide`, which needs a raised limit.
set_option maxHeartbeats 2000000

namespace FiniteLife

/-- A finite-support Life pattern: the finite set of live cells on the integer grid. -/
abbrev Pattern := Finset (ℤ × ℤ)

/-- The eight Moore-neighbourhood displacement vectors. -/
def offsets : Finset (ℤ × ℤ) :=
  {(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)}

/-- The eight Moore neighbours of a cell. -/
def neighbors (c : ℤ × ℤ) : Finset (ℤ × ℤ) :=
  offsets.image (fun d => (c.1 + d.1, c.2 + d.2))

/-- The number of live Moore neighbours of `c` in the pattern `s`. -/
def liveNeighborCount (s : Pattern) (c : ℤ × ℤ) : ℕ :=
  ((neighbors c).filter (· ∈ s)).card

/-- The B3/S23 successor rule as a predicate on a single cell.

A cell is live in the next generation iff either
* it is currently live and has two or three live neighbours (survival), or
* it is currently dead and has exactly three live neighbours (birth).

This predicate is defined for *every* cell of the grid, independently of any
finite bounding box; it is the reference against which the finite algorithm is
verified. -/
def globalNext (s : Pattern) (c : ℤ × ℤ) : Prop :=
  (c ∈ s ∧ (liveNeighborCount s c = 2 ∨ liveNeighborCount s c = 3)) ∨
  (c ∉ s ∧ liveNeighborCount s c = 3)

instance (s : Pattern) (c : ℤ × ℤ) : Decidable (globalNext s c) := by
  unfold globalNext; infer_instance

/-- The candidate cells for the next generation: every live cell together with
all of its neighbours.  Every cell that can possibly be live next generation
lies in this finite set. -/
def mooreExpansion (s : Pattern) : Pattern :=
  s ∪ s.biUnion neighbors

/-- The finite step algorithm: restrict attention to the finite candidate set
`mooreExpansion s` and keep those cells satisfying the rule. -/
def nextPattern (s : Pattern) : Pattern :=
  (mooreExpansion s).filter (fun c => globalNext s c)

/-! ## Basic neighbourhood lemmas -/

/-- Membership in `neighbors` unfolded through the displacement vectors. -/
theorem mem_neighbors_iff (c x : ℤ × ℤ) :
    x ∈ neighbors c ↔ ∃ d ∈ offsets, (c.1 + d.1, c.2 + d.2) = x := by
  simp [neighbors]

/-- The negation of a Moore offset is again a Moore offset.  A finite check over
the eight offsets. -/
theorem neg_mem_offsets {d : ℤ × ℤ} (hd : d ∈ offsets) : (-d.1, -d.2) ∈ offsets := by
  fin_cases hd <;> decide

/-- The Moore-neighbour relation is symmetric: `c` is a neighbour of `d` iff `d`
is a neighbour of `c`. -/
theorem mem_neighbors_comm (c d : ℤ × ℤ) : c ∈ neighbors d ↔ d ∈ neighbors c := by
  constructor <;>
  · intro h
    rw [mem_neighbors_iff] at h
    obtain ⟨o, ho, heq⟩ := h
    rw [mem_neighbors_iff]
    refine ⟨(-o.1, -o.2), neg_mem_offsets ho, ?_⟩
    have h1 := congrArg Prod.fst heq
    have h2 := congrArg Prod.snd heq
    simp only at h1 h2
    ext <;> simp <;> omega

/-! ## The capture lemma (non-circular) -/

/-- **Capture lemma.**  Every cell that the global rule makes live next
generation lies in the finite candidate set `mooreExpansion s`.

This is proved *directly*, without reference to `nextPattern`, so the
equivalence `mem_nextPattern_iff_globalNext` is not circular.  A surviving cell
is itself live, hence in the expansion; a newly born cell has a live neighbour,
and by symmetry of the Moore neighbourhood that live neighbour has the new cell
as one of *its* neighbours, placing the new cell in the expansion. -/
theorem mem_mooreExpansion_of_globalNext (s : Pattern) (c : ℤ × ℤ)
    (h : globalNext s c) : c ∈ mooreExpansion s := by
  rw [mooreExpansion, Finset.mem_union]
  rcases h with ⟨hc, _⟩ | ⟨_, hcount⟩
  · exact Or.inl hc
  · -- `liveNeighborCount s c = 3 > 0`, so `c` has a live neighbour `d`.
    refine Or.inr ?_
    have hne : ((neighbors c).filter (· ∈ s)).Nonempty := by
      rw [← Finset.card_pos, ← liveNeighborCount, hcount]; norm_num
    obtain ⟨d, hd⟩ := hne
    rw [Finset.mem_filter] at hd
    obtain ⟨hd_nb, hd_s⟩ := hd
    rw [Finset.mem_biUnion]
    exact ⟨d, hd_s, (mem_neighbors_comm c d).2 hd_nb⟩

/-! ## Correctness of the finite algorithm -/

/-- **Correctness.**  The finite step algorithm `nextPattern` computes exactly
the global B3/S23 rule `globalNext`.

The forward direction is immediate from the definition of `nextPattern` as a
filter.  The backward direction is the substantive one: it uses the capture
lemma `mem_mooreExpansion_of_globalNext` to show that any cell satisfying the
rule is among the finitely many candidates that the algorithm inspects.  No
appeal is made to `nextPattern` in establishing the candidacy, so the argument
is non-circular. -/
theorem mem_nextPattern_iff_globalNext (s : Pattern) (c : ℤ × ℤ) :
    c ∈ nextPattern s ↔ globalNext s c := by
  rw [nextPattern, Finset.mem_filter]
  constructor
  · exact fun h => h.2
  · exact fun h => ⟨mem_mooreExpansion_of_globalNext s c h, h⟩

/-! ## Worked examples -/

/-- The 2×2 block: a still life. -/
def block : Pattern := {(0, 0), (0, 1), (1, 0), (1, 1)}

/-- The horizontal blinker: three live cells in a row. -/
def blinker : Pattern := {(0, -1), (0, 0), (0, 1)}

/-- The 2×2 block is a still life: one step of the algorithm reproduces it.

Each of the four block cells has exactly three live neighbours (the other three
block cells), so each survives; every cell outside the block adjacent to it has
at most two live neighbours, so none is born. -/
theorem nextPattern_block : nextPattern block = block := by decide

/-- **Blinker period two.**  Two steps of the algorithm return the blinker to its
initial state: it is a period-two oscillator. -/
theorem blinker_period_two : nextPattern (nextPattern blinker) = blinker := by decide

end FiniteLife