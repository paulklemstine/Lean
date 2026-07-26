import Mathlib

/-!
# The Constraint-Satisfaction Threshold of Sudoku: A Sharp Phase Transition

Sudoku is the archetypal *constraint-satisfaction problem* (CSP).  Every row,
column and box imposes a single combinatorial demand — an **AllDifferent**
constraint: a block of `m` cells must receive pairwise distinct symbols drawn
from an alphabet of size `k`.  This file isolates the AllDifferent atom, proves
that its satisfiability undergoes a **sharp phase transition** as the number of
cells crosses the alphabet size, and threads that transition through three
distinct mathematical languages:

* **order theory** — the satisfiable region is exactly the down-set `[0, k]`, so
  the transition is a single jump at the critical cell count `k + 1`, never a
  gradual slope (`alldiff_sat_iff_le`, `sat_set_eq_Iic`, `critCells_unique`);
* **enumerative combinatorics / statistical mechanics** — the "partition
  function" counting proper assignments is the falling factorial
  `k^{\underline m}`; it is strictly positive in the satisfiable phase and
  collapses to `0` exactly at criticality (`numProper_pos_iff_sat`,
  `numProper_crit`, `numProper_over`);
* **graph theory** — an AllDifferent block is a complete graph, so the CSP is a
  proper colouring problem and satisfiability equals `k`-colourability of `Kₘ`
  (`complete_colorable_iff`, `complete_colorable_iff_le`).

For an order-`n` Sudoku the grid is `n² × n²` and *every* line contains exactly
`n²` cells drawn from `n²` symbols: the puzzle sits precisely **at criticality**
(`sudoku_row_sat`, `sudoku_row_over_unsat`), which is the structural reason
Sudoku is a hard, critically-constrained problem.  Finally we exhibit an
*explicit* simultaneous solution of the row-and-column CSP — the cyclic Latin
square `L(i,j) = i + j` over `ℤ/Nℤ` — turning the abstract existence statement
into a group-theoretic construction (`exists_latin_square`).

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  Sudoku's difficulty is not accidental: the
  AllDifferent atom that generates every constraint should exhibit a *sharp*
  satisfiability threshold, and the `n² × n²` grid should sit exactly on it.  A
  bolder cross-domain claim: the same threshold is visible simultaneously as an
  order-theoretic down-set, a vanishing enumerative partition function, and a
  graph-colourability boundary.
* **Experiment (Experimenter).**  Modelled the AllDifferent atom by
  `AllDiffSAT m k := ∃ f : Fin m → Fin k, Injective f` and proved the pigeonhole
  equivalence `AllDiffSAT m k ↔ m ≤ k`.  From this single equivalence we derived
  the down-set description, the sharp critical value `k + 1`, its uniqueness, the
  partition-function collapse via `Nat.descFactorial`, and the graph-colouring
  bridge through `SimpleGraph.Coloring`.  The Latin-square witness came from
  bijectivity of translation in the finite group `ℤ/Nℤ`.
* **Analysis (Analyst).**  "True and structural."  Every result funnels through
  one pigeonhole equivalence, which is why the three languages agree: they are
  three faces of `m ≤ k`.  The critical case `m = k` lands on the *satisfiable*
  side (the boundary is closed below), matching the fact that a full Sudoku
  solution exists; the very next cell (`m = k + 1`) is unconditionally
  infeasible.
* **Critique (Critic).**  Corner cases: `m = 0` is vacuously satisfiable for
  every alphabet, and `k = 0` forces immediate infeasibility for any nonempty
  block — both are genuine (degenerate) instances of the transition, not false
  claims.  The density statement is guarded by `0 < k` to avoid division by
  zero.  The Latin square solves rows and columns but *not* boxes, so it is
  honestly labelled a solution of the CSP *relaxation*, not of full Sudoku.
* **Synthesis (PI).**  The satisfiability of a constraint-satisfaction puzzle is
  governed by a single sharp threshold in the balance between demands and
  resources; Sudoku is engineered to sit exactly at that threshold, and the
  threshold is simultaneously an order-theoretic, enumerative, and
  chromatic phenomenon.
-/

open Function SimpleGraph

namespace SudokuCSP

/-! ## 1. The AllDifferent atom and its pigeonhole equivalence -/

/-- **Satisfiability of the AllDifferent atom.**  A block of `m` cells can be
filled with pairwise distinct symbols from an alphabet of size `k` exactly when
there is an injective assignment `Fin m → Fin k`. -/
def AllDiffSAT (m k : ℕ) : Prop := ∃ f : Fin m → Fin k, Injective f

/-- **The pigeonhole equivalence.**  An AllDifferent block of `m` cells is
satisfiable over `k` symbols iff `m ≤ k`.  This single equivalence is the engine
behind every later result. -/
theorem alldiff_sat_iff_le (m k : ℕ) : AllDiffSAT m k ↔ m ≤ k := by
  constructor
  · rintro ⟨f, hf⟩
    simpa using Fintype.card_le_of_injective f hf
  · intro h
    exact ⟨fun i => ⟨i, lt_of_lt_of_le i.2 h⟩,
      fun a b hab => by simpa [Fin.ext_iff] using hab⟩

/-- Unsatisfiability side of the equivalence: strictly more cells than symbols. -/
theorem alldiff_unsat_iff_gt (m k : ℕ) : ¬ AllDiffSAT m k ↔ k < m := by
  rw [alldiff_sat_iff_le]; omega

/-- Satisfiability is **antitone in the number of cells**: removing constraints
(cells) cannot destroy satisfiability. -/
theorem alldiff_sat_antitone {m m' k : ℕ} (hmm : m' ≤ m) (h : AllDiffSAT m k) :
    AllDiffSAT m' k := by
  rw [alldiff_sat_iff_le] at *; omega

/-- Satisfiability is **monotone in the alphabet size**: adding symbols
(resources) cannot destroy satisfiability. -/
theorem alldiff_sat_mono_symbols {m k k' : ℕ} (hkk : k ≤ k') (h : AllDiffSAT m k) :
    AllDiffSAT m k' := by
  rw [alldiff_sat_iff_le] at *; omega

/-! ## 2. The sharp phase transition -/

/-- The **critical cell count**: the first block size at which satisfiability
fails, given `k` symbols. -/
def critCells (k : ℕ) : ℕ := k + 1

/-- **Subcritical phase.**  Below the critical count every block is satisfiable. -/
theorem subcritical_sat {m k : ℕ} (hm : m < critCells k) : AllDiffSAT m k := by
  rw [alldiff_sat_iff_le]; unfold critCells at hm; omega

/-- **Supercritical phase.**  At and above the critical count every block is
unsatisfiable. -/
theorem supercritical_unsat {m k : ℕ} (hm : critCells k ≤ m) : ¬ AllDiffSAT m k := by
  rw [alldiff_unsat_iff_gt]; unfold critCells at hm; omega

/-- **Sharpness / uniqueness.**  Any value that separates a uniformly satisfiable
phase from an unsatisfiable point must be the critical count: the transition
happens at a single, well-defined location. -/
theorem critCells_unique {k t : ℕ}
    (hbelow : ∀ m < t, AllDiffSAT m k) (hat : ¬ AllDiffSAT t k) :
    t = critCells k := by
  rw [alldiff_unsat_iff_gt] at hat
  unfold critCells
  rcases Nat.lt_or_ge (k + 1) t with h | h
  · have := hbelow (k + 1) h
    rw [alldiff_sat_iff_le] at this; omega
  · omega

/-- **The satisfiable region is a down-set.**  The set of block sizes that are
satisfiable over `k` symbols is exactly the interval `[0, k]`, so the transition
is a single jump rather than a gradual slope. -/
theorem sat_set_eq_Iic (k : ℕ) : {m | AllDiffSAT m k} = Set.Iic k := by
  ext m
  simp [alldiff_sat_iff_le, Set.mem_Iic]

/-! ## 3. The partition function (enumerative / statistical-mechanics view) -/

/-- The **partition function** of the AllDifferent atom: the number of proper
(injective) assignments of `m` cells into `k` symbols, i.e. the falling
factorial `k^{\underline m}`. -/
def numProper (m k : ℕ) : ℕ := k.descFactorial m

/-- The partition function is strictly positive iff `m ≤ k`. -/
theorem numProper_pos_iff (m k : ℕ) : 0 < numProper m k ↔ m ≤ k :=
  Nat.descFactorial_pos

/-- **The partition function detects the phase.**  It is strictly positive
exactly in the satisfiable phase: counting and existence coincide. -/
theorem numProper_pos_iff_sat (m k : ℕ) : 0 < numProper m k ↔ AllDiffSAT m k := by
  rw [numProper_pos_iff, alldiff_sat_iff_le]

/-- **Collapse of the partition function.**  Above the alphabet size the number
of proper assignments is exactly `0` — the unsatisfiable phase has no states. -/
theorem numProper_eq_zero_iff (m k : ℕ) : numProper m k = 0 ↔ k < m := by
  constructor
  · intro h; by_contra hc; push_neg at hc
    have := (numProper_pos_iff m k).2 hc; omega
  · intro h; by_contra hc
    have : 0 < numProper m k := Nat.pos_of_ne_zero hc
    rw [numProper_pos_iff] at this; omega

/-- At criticality (`m = k`) the partition function equals `k!`: a fully packed
block has exactly `k!` completions. -/
theorem numProper_crit (k : ℕ) : numProper k k = Nat.factorial k :=
  Nat.descFactorial_self k

/-- One cell past criticality the partition function vanishes. -/
theorem numProper_over (k : ℕ) : numProper (k + 1) k = 0 := by
  simp [numProper]

/-! ## 4. Density and the critical density `1` -/

/-- The **constraint density** of a block: cells per symbol. -/
noncomputable def density (m k : ℕ) : ℚ := (m : ℚ) / (k : ℚ)

/-- **The critical density is `1`.**  With a positive alphabet, a block is
satisfiable iff its density does not exceed `1`. -/
theorem sat_iff_density_le_one {m k : ℕ} (hk : 0 < k) :
    AllDiffSAT m k ↔ density m k ≤ 1 := by
  rw [alldiff_sat_iff_le]
  unfold density
  rw [div_le_one (by exact_mod_cast hk)]
  exact_mod_cast Iff.rfl

/-! ## 5. Specialisation to Sudoku: the grid sits at criticality -/

/-- **An order-`n` Sudoku line is critically constrained and satisfiable.**  Each
row, column, or box of an `n² × n²` grid holds `n²` cells over `n²` symbols, so
it lands exactly on the boundary of the satisfiable region. -/
theorem sudoku_row_sat (n : ℕ) : AllDiffSAT (n ^ 2) (n ^ 2) :=
  (alldiff_sat_iff_le _ _).2 (le_refl _)

/-- One forced clue too many (a repeated symbol, modelled as an extra distinct
cell) tips a Sudoku line into unsatisfiability: the grid is one step from the
cliff. -/
theorem sudoku_row_over_unsat (n : ℕ) : ¬ AllDiffSAT (n ^ 2 + 1) (n ^ 2) := by
  rw [alldiff_sat_iff_le]; omega

/-- **Forced collision (pigeonhole certificate).**  Once a block has more cells
than symbols, *every* assignment repeats a symbol — an explicit witness of
infeasibility. -/
theorem forced_collision {m k : ℕ} (h : k < m) (f : Fin m → Fin k) :
    ∃ i j, i ≠ j ∧ f i = f j := by
  have hcard : Fintype.card (Fin k) < Fintype.card (Fin m) := by simpa using h
  obtain ⟨i, j, hij, hfe⟩ := Fintype.exists_ne_map_eq_of_card_lt f hcard
  exact ⟨i, j, hij, hfe⟩

/-! ## 6. Graph-theoretic bridge: AllDifferent = colouring a complete graph -/

/-- **CSP ↔ colouring.**  An AllDifferent block of `m` cells is the complete
graph `Kₘ`, and satisfiability over `k` symbols is exactly `k`-colourability. -/
theorem complete_colorable_iff (m k : ℕ) :
    (⊤ : SimpleGraph (Fin m)).Colorable k ↔ AllDiffSAT m k := by
  constructor
  · rintro ⟨C⟩
    refine ⟨C, ?_⟩
    intro a b hab
    by_contra hne
    have : (⊤ : SimpleGraph (Fin m)).Adj a b := by
      simpa [SimpleGraph.top_adj] using hne
    exact (C.valid this) hab
  · rintro ⟨f, hf⟩
    exact ⟨SimpleGraph.Coloring.mk f
      (by intro a b hab; simp only [SimpleGraph.top_adj] at hab; exact fun h => hab (hf h))⟩

/-- The chromatic threshold of the complete graph is the same `m ≤ k`: the graph
picture reproduces the pigeonhole threshold exactly. -/
theorem complete_colorable_iff_le (m k : ℕ) :
    (⊤ : SimpleGraph (Fin m)).Colorable k ↔ m ≤ k := by
  rw [complete_colorable_iff, alldiff_sat_iff_le]

/-! ## 7. An explicit simultaneous solution: the cyclic Latin square -/

/-- The **cyclic Latin square** over `ℤ/Nℤ`: `L(i, j) = i + j`. -/
def cyclicLatin (N : ℕ) (i j : ZMod N) : ZMod N := i + j

/-- **Simultaneous row-and-column satisfaction.**  For every positive order `N`
there is a filling of the `N × N` grid in which *every* row and *every* column is
a bijection — an explicit solution of Sudoku's row/column CSP relaxation, built
from translation in the finite group `ℤ/Nℤ`. -/
theorem exists_latin_square (N : ℕ) [NeZero N] :
    ∃ L : ZMod N → ZMod N → ZMod N,
      (∀ i, Bijective (L i)) ∧ (∀ j, Bijective (fun i => L i j)) := by
  refine ⟨cyclicLatin N, ?_, ?_⟩
  · intro i
    have : Function.Injective (cyclicLatin N i) := by
      intro a b hab; simpa [cyclicLatin, add_right_inj] using hab
    exact (Finite.injective_iff_bijective).1 this
  · intro j
    have : Function.Injective (fun i : ZMod N => cyclicLatin N i j) := by
      intro a b hab; simpa [cyclicLatin, add_left_inj] using hab
    exact (Finite.injective_iff_bijective).1 this

/-! ## 8. Worked instances (PEGB: examples, boundary, generalization checks) -/

-- The classic `9 × 9` Sudoku is critically constrained (order `n = 3`).
example : AllDiffSAT 9 9 := sudoku_row_sat 3
example : ¬ AllDiffSAT 10 9 := by rw [alldiff_unsat_iff_gt]; norm_num

-- The number of ways to fill one full `9`-cell line is `9! = 362880`.
example : numProper 9 9 = 362880 := by decide

#check @alldiff_sat_iff_le
#check @complete_colorable_iff_le
#check @exists_latin_square
#eval numProper 9 9          -- 362880
#eval numProper 10 9         -- 0  (supercritical collapse)
#eval numProper 4 4          -- 24 = 4!  (order-2 Sudoku line)

end SudokuCSP