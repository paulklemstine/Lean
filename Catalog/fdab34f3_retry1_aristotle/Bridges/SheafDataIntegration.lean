import Mathlib

/-!
# Sheaf-Theoretic Data Integration: When Databases Form a Sheaf

A database with missing entries is modelled as a *partial section* of the
sheaf of `V`-valued functions on a set `α` of coordinates (think: columns,
or (column, row) cells). A *local section over* `U ⊆ α` is a function
`U → V` (the values that are observed on the sub-database indexed by `U`).

The **sheaf condition (gluing)** is the assertion that a family of local
sections that is *pairwise compatible* on overlaps comes from a unique
global section. This file proves that the sheaf condition holds for the
function sheaf (`sheaf_condition`), that compatibility is *necessary*
(`incompatible_not_gluable`), and packages the existence half as the
concrete imputation operator (`glue`).

The relevance to data integration: "consistent imputation" of a database
with missing entries is exactly the search for a global section restricting
to the observed partial sections, and the sheaf condition tells us
*precisely* when this is possible and that the answer is unique.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** "If two sub-databases agree on the columns
  they share, they can be merged into one consistent database, and the merge
  is unique." Formally: pairwise-compatible local sections of the function
  sheaf glue uniquely.
* **Experiment (Experimenter).** Formalised local sections as `(U i) → V`
  and proved existence + uniqueness of the glued global section on
  `⋃ i, U i` using a choice function to select, for each coordinate, a chart
  containing it; compatibility makes the choice irrelevant.
* **Analysis (Analyst).** The theorem is *true and constructive up to choice*.
  Crucially the function sheaf needs only **pairwise** compatibility — no
  higher cocycle conditions — because its sections are honest functions.
  This is the mathematical reason mean/KNN imputation "ignore constraints":
  they never check the overlap-agreement equalizer at all.
* **Critique (Critic).** Is compatibility a vacuous hypothesis? No:
  `incompatible_not_gluable` exhibits that a single overlap disagreement
  destroys *all* global sections, so the hypothesis is load-bearing and the
  theorem is not vacuously true.
* **Synthesis (PI).** The sheaf condition is a genuine equalizer constraint
  on databases; gluing is the unique consistent imputation when it exists.
-/

open Classical

namespace SheafDataIntegration

variable {α V : Type*} {ι : Type*}

/-- The predicate that a candidate global section `g` on `⋃ i, U i`
restricts to each local section `s i`. -/
def IsGlobalSection (U : ι → Set α) (s : (i : ι) → (U i) → V)
    (g : (⋃ i, U i) → V) : Prop :=
  ∀ (i : ι) (x : α) (hx : x ∈ U i),
    g ⟨x, Set.mem_iUnion.2 ⟨i, hx⟩⟩ = s i ⟨x, hx⟩

/-- **The sheaf condition (gluing) for the database sheaf.**
A pairwise-compatible family of local sections glues to a *unique* global
section. This is the precise statement of "consistent imputation exists and
is unique when local views agree on overlaps." -/
theorem sheaf_condition (U : ι → Set α) (s : (i : ι) → (U i) → V)
    (hcompat : ∀ i j, ∀ (x : α) (hi : x ∈ U i) (hj : x ∈ U j),
      s i ⟨x, hi⟩ = s j ⟨x, hj⟩) :
    ∃! g : (⋃ i, U i) → V, IsGlobalSection U s g := by
  refine' ⟨ fun x => s ( Classical.choose ( Set.mem_iUnion.1 x.2 ) ) ⟨ x.1, Classical.choose_spec ( Set.mem_iUnion.1 x.2 ) ⟩, _, _ ⟩;
  · intro i x hx;
    grind +qlia;
  · intro y hy; ext ⟨ x, hx ⟩ ; exact hy ( Classical.choose ( Set.mem_iUnion.1 hx ) ) x ( Classical.choose_spec ( Set.mem_iUnion.1 hx ) ) ;

/-- **Compatibility is necessary.** If two local sections disagree at a shared
coordinate, then *no* global section can restrict to both — so the sheaf
condition's hypothesis is load-bearing, not vacuous. -/
theorem incompatible_not_gluable
    (U : ι → Set α) (s : (i : ι) → (U i) → V)
    (i j : ι) (x : α) (hi : x ∈ U i) (hj : x ∈ U j)
    (hne : s i ⟨x, hi⟩ ≠ s j ⟨x, hj⟩) :
    ¬ ∃ g : (⋃ i, U i) → V, IsGlobalSection U s g := by
  grind +locals

/-- The **sheaf imputation operator**: the unique glued global section
produced from a pairwise-compatible family. -/
noncomputable def glue (U : ι → Set α) (s : (i : ι) → (U i) → V)
    (hcompat : ∀ i j, ∀ (x : α) (hi : x ∈ U i) (hj : x ∈ U j),
      s i ⟨x, hi⟩ = s j ⟨x, hj⟩) : (⋃ i, U i) → V :=
  (sheaf_condition U s hcompat).choose

/-- The glued section indeed restricts to each local section. -/
theorem glue_isGlobalSection (U : ι → Set α) (s : (i : ι) → (U i) → V)
    (hcompat : ∀ i j, ∀ (x : α) (hi : x ∈ U i) (hj : x ∈ U j),
      s i ⟨x, hi⟩ = s j ⟨x, hj⟩) :
    IsGlobalSection U s (glue U s hcompat) :=
  (sheaf_condition U s hcompat).choose_spec.1

end SheafDataIntegration