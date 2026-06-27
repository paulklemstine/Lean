import Mathlib
import Bridges.CombinatorialBridge

/-!
# Girth–Expansion Bridge — Basic definitions

A *left-`d`-regular bipartite graph* is modeled by a neighbor function
`N : L → Finset R`, with every left vertex having exactly `d` right neighbors.

We define:
* `nbhd N X` — the neighborhood `⋃_{u ∈ X} N u` of a set of left vertices;
* `OptimalExpander N d s` — every set of `≤ s` left vertices has *exactly*
  `d·|X|` distinct neighbors (maximal small-set expansion);
* `HasCycle N k` — a combinatorial `2k`-cycle (k distinct left and k distinct
  right vertices arranged cyclically via `finRotate`);
* `GirthGe N s` — girth `≥ 2s+2`, i.e. no cycle of length in `{4, …, 2s}`;
* `AllPairsDisjoint N` — all neighborhoods pairwise disjoint.

These are the objects of the *Girth–Expansion Equivalence* bridge studied in
`Equivalence.lean`.
-/

-- !-- Lab Notes -- !--
-- HYPOTHESIS (Hypothesizer): encode girth faithfully as absence of short
--   cycles in a self-contained left-d-regular bipartite model, not via a
--   renamed Mathlib gadget, so `GirthGe` is genuinely the girth condition.
-- EXPERIMENT (Experimenter): cycles = injective Fin k-indexed left/right
--   vertices made cyclic by `finRotate k`; `cycle_shared_neighbor` extracts,
--   from any cycle of length >= 4, two distinct adjacent left vertices with a
--   common neighbor — the seed of every later argument.
-- ANALYSIS (Analyst): this extraction lemma is the structural pivot; it reduces
--   every "no short cycle" claim to disjointness of two neighborhoods,
--   decoupling the combinatorics from Fin/finRotate bookkeeping.
-- CRITIQUE (Critic): `nbhd_card_mono` genuinely consumes the catalog result
--   `CombinatorialBridge.subset_card_le`, anchoring the file to the catalog.
-- SYNTHESIS (PI): definitions + `cycle_shared_neighbor` + `nbhd_card_mono` form
--   the reusable substrate consumed by `Equivalence.lean`.

namespace GirthExpansion

open Finset

variable {L R : Type*} [DecidableEq L] [DecidableEq R]

/-- Neighborhood of a set of left vertices. -/
def nbhd (N : L → Finset R) (X : Finset L) : Finset R := X.biUnion N

/-- Left-regular: every left vertex has exactly `d` neighbors. -/
def LeftRegular (N : L → Finset R) (d : ℕ) : Prop := ∀ u, (N u).card = d

/-- `s`-optimal small-set expander: every set of `≤ s` left vertices has
exactly `d·|X|` distinct neighbors. -/
def OptimalExpander (N : L → Finset R) (d s : ℕ) : Prop :=
  ∀ X : Finset L, X.card ≤ s → (nbhd N X).card = d * X.card

/-- A combinatorial `2k`-cycle: `k` distinct left vertices and `k` distinct
right vertices, cyclically incident (`w i` joins `u i` and its successor
`u (finRotate k i)`). -/
def HasCycle (N : L → Finset R) (k : ℕ) : Prop :=
  ∃ (u : Fin k → L) (w : Fin k → R),
    Function.Injective u ∧ Function.Injective w ∧
    ∀ i, w i ∈ N (u i) ∧ w i ∈ N (u (finRotate k i))

/-- There is a cycle of length `≤ 2s` (girth `< 2s+2`). -/
def HasShortCycle (N : L → Finset R) (s : ℕ) : Prop :=
  ∃ k, 2 ≤ k ∧ k ≤ s ∧ HasCycle N k

/-- Girth `≥ 2s+2`: no cycle of length in `{4, …, 2s}`. -/
def GirthGe (N : L → Finset R) (s : ℕ) : Prop := ¬ HasShortCycle N s

/-- All neighborhoods are pairwise disjoint (a vertex-disjoint union of stars). -/
def AllPairsDisjoint (N : L → Finset R) : Prop :=
  ∀ u v : L, u ≠ v → Disjoint (N u) (N v)

omit [DecidableEq L] in
/-- Monotonicity of neighborhood cardinality, proven via the catalog's
`CombinatorialBridge.subset_card_le`. -/
theorem nbhd_card_mono (N : L → Finset R) {X Y : Finset L} (h : X ⊆ Y) :
    (nbhd N X).card ≤ (nbhd N Y).card :=
  CombinatorialBridge.subset_card_le (by
    simpa only [nbhd] using Finset.biUnion_subset_biUnion_of_subset_left N h)

/-
Every cycle of length `≥ 4` contains two distinct adjacent left vertices
that share a common neighbor.
-/
omit [DecidableEq L] in
theorem cycle_shared_neighbor (N : L → Finset R) {k : ℕ} (hk : 2 ≤ k)
    (h : HasCycle N k) : ∃ a b : L, a ≠ b ∧ (N a ∩ N b).Nonempty := by
  obtain ⟨ u, w, hu, hw, hcyc ⟩ := h;
  obtain ⟨ m, rfl ⟩ : ∃ m, k = m + 2 := ⟨ k - 2, by omega ⟩;
  refine' ⟨ u ⟨ 0, by linarith ⟩, u ⟨ 1, by linarith ⟩, _, _ ⟩;
  · exact hu.ne ( by simp +decide );
  · exact ⟨ w ⟨ 0, by linarith ⟩, Finset.mem_inter.2 ⟨ hcyc _ |>.1, hcyc _ |>.2 ⟩ ⟩

end GirthExpansion