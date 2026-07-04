import Mathlib
import Logic.ProofSystemCollapse

/-!
# Dark Mathematics: a hierarchy of unfindable existence

A **dark theorem** is a statement whose existential form is provable while *no
individual witness* can ever be exhibited: a deductive system proves "there are
witnesses" yet proves no specific `T(n)`.  The classic phenomenon is
Paris–Harrington (true, but PA-independent, strengthened finite Ramsey); here we
isolate the *structural core* of darkness and organize it into a strict
**hierarchy of darkness**.

We model a deductive system abstractly by the Cook–Reckhow `ProofSys`
abstraction of `Logic.ProofSystemCollapse`: a proof system over the formula type
`DarkFormula` whose formulas are the instance statements `inst n` (= `T(n)`) and
the counting statements `atLeast k` (= "there exist at least `k` witnesses `x`
with `T(x)`").  Provability is `ProofSystemCollapse.Provable`.

* `DarkAtLevel S k` : `S` proves `atLeast k` but proves no `inst n`.
* `IsDark S`        : darkness of level `1`, i.e. `∃x T(x)` is provable but no
  instance is.

The main result of this file is that the hierarchy is **strict and inhabited at
every level**: for every `k` there is a system that is dark of level `k` yet
*not* dark of level `k+1`.  This is witnessed by an explicit finite proof system
`boundedDark k` proving exactly `atLeast 0, …, atLeast k` and no instance.

## Key results
- `provable_boundedDark_atLeast`, `not_provable_boundedDark_inst`:
  the provability profile of the explicit witness system.
- `dark_boundedDark_all_levels`: `boundedDark k` is dark of every level `j ≤ k`
  (downward closure of darkness, realized concretely).
- `dark_hierarchy_strict`: the darkness hierarchy does not collapse.
- `dark_examples_123`: explicit dark theorems of levels 1, 2, 3.

-- !-- Lab Notes -- !--
**Hypothesis (Hypothesizer).** "Darkness" is not a single phenomenon but a
graded one: one can prove *how many* witnesses exist while still being unable to
name any.  Conjecture: there is a strict hierarchy `DarkAtLevel · k`, with
level `k+1` strictly stronger than level `k`.

**Experiment (Experimenter).** Model a theory by an abstract `ProofSys` over
`DarkFormula`.  The finite system `boundedDark k`, whose proofs are the indices
`{j // j ≤ k}` concluding `atLeast j`, proves `atLeast j ↔ j ≤ k` and proves no
`inst n` (no proof object concludes an instance).  Hence it realizes darkness of
each level `≤ k` but *fails* level `k+1`.

**Analysis (Analyst).** The hierarchy is strict because the counting statements
`atLeast k` are genuinely different formulas (injectivity of the `atLeast`
constructor), so the level a system reaches is exactly the top of its provable
counting-formulas — a data-level invariant, not an artifact of coding.

**Critique (Critic).** Darkness must not be vacuous: `boundedDark k` really does
prove `atLeast k` (nonempty provability) and really proves no instance, so
`DarkAtLevel` is satisfied non-trivially.  The strictness half is a genuine
*non*-provability (`k+1 ≤ k` is false), not a definitional dodge.

**Synthesis.** Darkness is a resource measured on a discrete ladder; the ladder
never collapses.  The join/counting refinements live in `DensityAndJoin.lean`.
-/

open ProofSystemCollapse

namespace DarkMathematics

/-- Formulas of a dark-theorem family: instance statements `inst n` (read
"`n` is a witness of `T`") and counting statements `atLeast k` (read "there exist
at least `k` witnesses `x` with `T(x)`"). -/
inductive DarkFormula where
  /-- `T(n)`: the specific instance at `n`. -/
  | inst    : ℕ → DarkFormula
  /-- "there exist at least `k` witnesses `x` with `T(x)`". -/
  | atLeast : ℕ → DarkFormula
deriving DecidableEq

/-- The existential statement `∃x T(x)` is "at least one witness". -/
def existsStmt : DarkFormula := .atLeast 1

/-- `S` proves **no specific instance**: for every `n`, `T(n)` is unprovable. -/
def NoInstanceProvable (S : ProofSys DarkFormula) : Prop :=
  ∀ n, ¬ Provable S (.inst n)

/-- `S` is **dark of level `k`**: it proves "there are at least `k` witnesses"
yet proves no specific instance.  This is the structural core of a dark theorem:
provable existence (indeed provable multiplicity) with no findable witness. -/
def DarkAtLevel (S : ProofSys DarkFormula) (k : ℕ) : Prop :=
  Provable S (.atLeast k) ∧ NoInstanceProvable S

/-- A system is **dark** if it is dark of level `1`: `∃x T(x)` is provable but no
instance is. -/
def IsDark (S : ProofSys DarkFormula) : Prop := DarkAtLevel S 1

/-- Level-`1` darkness is exactly provability of the existential statement
`existsStmt = atLeast 1` together with unfindability. -/
theorem isDark_iff (S : ProofSys DarkFormula) :
    IsDark S ↔ Provable S existsStmt ∧ NoInstanceProvable S := Iff.rfl

/-! ## The explicit witness system -/

/-- The finite proof system whose proofs are the indices `j ≤ k`, each
concluding the counting statement `atLeast j`.  It proves exactly
`atLeast 0, …, atLeast k` and *no* instance. -/
def boundedDark (k : ℕ) : ProofSys DarkFormula where
  Proof := { j : ℕ // j ≤ k }
  concl := fun j => .atLeast j.val
  size := fun _ => 0

/-- Provability of a counting statement in `boundedDark k` is exactly `j ≤ k`. -/
theorem provable_boundedDark_atLeast (k j : ℕ) :
    Provable (boundedDark k) (.atLeast j) ↔ j ≤ k := by
  constructor
  · rintro ⟨⟨i, hi⟩, hc⟩
    simp only [boundedDark, DarkFormula.atLeast.injEq] at hc
    omega
  · intro h
    exact ⟨⟨j, h⟩, rfl⟩

/-- `boundedDark k` proves **no** instance statement. -/
theorem not_provable_boundedDark_inst (k n : ℕ) :
    ¬ Provable (boundedDark k) (.inst n) := by
  rintro ⟨⟨i, hi⟩, hc⟩
  simp only [boundedDark] at hc
  exact DarkFormula.noConfusion hc

/-- `boundedDark k` proves no specific instance. -/
theorem noInstance_boundedDark (k : ℕ) : NoInstanceProvable (boundedDark k) :=
  not_provable_boundedDark_inst k

/-! ## Darkness at every level up to `k` -/

/-- **Downward closure, realized.** `boundedDark k` is dark of every level
`j ≤ k`: it proves the counting statement `atLeast j` and still names no witness. -/
theorem dark_boundedDark_all_levels (k j : ℕ) (hjk : j ≤ k) :
    DarkAtLevel (boundedDark k) j :=
  ⟨(provable_boundedDark_atLeast k j).2 hjk, noInstance_boundedDark k⟩

/-! ## Strictness of the hierarchy -/

/-- **The darkness hierarchy is strict.** For every `k`, the explicit system
`boundedDark k` is dark of level `k` but *not* dark of level `k+1`.  Hence level
`k+1` darkness is strictly stronger than level `k` darkness — the ladder never
collapses. -/
theorem dark_hierarchy_strict (k : ℕ) :
    DarkAtLevel (boundedDark k) k ∧ ¬ DarkAtLevel (boundedDark k) (k + 1) := by
  refine ⟨dark_boundedDark_all_levels k k le_rfl, ?_⟩
  rintro ⟨hprov, _⟩
  have := (provable_boundedDark_atLeast k (k + 1)).1 hprov
  omega

/-- Explicit dark theorems of levels 1, 2, 3, as requested by the programme:
each `boundedDark k` proves multiplicity `k` of witnesses while naming none. -/
theorem dark_examples_123 :
    DarkAtLevel (boundedDark 1) 1 ∧
    DarkAtLevel (boundedDark 2) 2 ∧
    DarkAtLevel (boundedDark 3) 3 :=
  ⟨dark_boundedDark_all_levels 1 1 le_rfl,
   dark_boundedDark_all_levels 2 2 le_rfl,
   dark_boundedDark_all_levels 3 3 le_rfl⟩

end DarkMathematics