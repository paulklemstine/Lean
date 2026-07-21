import Catalog.Novelty.DaisyCubes.PartialCube

/-!
# Meet structure and geodesic geometry of daisy cubes

This file records the order/metric features of daisy cubes that drive the forbidden-pc-minor
analysis:

* a daisy cube is closed under coordinatewise **meet** (`IsDaisy.inter_mem`): if `A, B` are vertices
  then so is `A ∩ B`;
* the meet `A ∩ B` lies on a **geodesic** between `A` and `B`
  (`meet_on_geodesic`: `hdist A B = hdist A (A ∩ B) + hdist (A ∩ B) B`), so descending to the meet
  and then ascending is a shortest path — this is the geometric reason the construction in
  `daisy_geodesic` is optimal;
* daisy cubes are **not** closed under **join** in general (`not_join_closed`): there is an explicit
  daisy cube containing `{0}` and `{1}` but not `{0,1}`.  This meet/join asymmetry is precisely what
  separates daisy cubes from arbitrary subcubes.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Daisy cubes form a meet-subsemilattice of the Boolean lattice on which
the meet realizes geodesics, but they are not join-closed.

Experiment (Experimenter): `A ∩ B ⊆ A` gives meet closure from down-closure directly.  The geodesic
identity reduces to `|A ∆ B| = |A \ B| + |B \ A|` after rewriting the two distances to the meet as
`|A \ B|` and `|B \ A|`.  For the join failure, exhibit the explicit down-set
`{∅, {0}, {1}}` in `Q₂`.

Analysis (Analyst): Meet closure + geodesic optimality is the structural core that makes daisy cubes
partial cubes with a canonical gate (the meet).  Join failure shows the class is strictly smaller
than the class of subcubes, which is why nontrivial forbidden minors exist at all.

Critique (Critic): `meet_on_geodesic` is a real cardinality identity (not `rfl`), and
`not_join_closed` is a genuine existential counterexample, not a vacuous statement.

Synthesis (PI): The meet-gate viewpoint is the lever for attacking the full forbidden-minor
characterization; see `FUTURE_DIRECTIONS.md`.
-/

open scoped symmDiff
open Finset

namespace DaisyCube

variable {n : ℕ}

/-- A daisy cube is closed under coordinatewise meet (intersection of vertices). -/
lemma IsDaisy.inter_mem {D : Finset (Fin n) → Prop} (hD : IsDaisy D) {A B : Finset (Fin n)}
    (hA : D A) (_hB : D B) : D (A ∩ B) :=
  hD hA (Finset.inter_subset_left)

/-
The meet `A ∩ B` lies on a geodesic between `A` and `B`: descending from `A` to `A ∩ B` and then
ascending to `B` is a shortest path in the hypercube.
-/
lemma meet_on_geodesic (A B : Finset (Fin n)) :
    hdist A B = hdist A (A ∩ B) + hdist (A ∩ B) B := by
  have h1 : A ∆ (A ∩ B) = A \ B := by
    ext x; simp only [Finset.mem_symmDiff, Finset.mem_sdiff, Finset.mem_inter]; tauto
  have h2 : (A ∩ B) ∆ B = B \ A := by
    ext x; simp only [Finset.mem_symmDiff, Finset.mem_sdiff, Finset.mem_inter]; tauto
  have h3 : A ∆ B = (A \ B) ∪ (B \ A) := by
    ext x; simp only [Finset.mem_symmDiff, Finset.mem_sdiff, Finset.mem_union]
  unfold hdist
  rw [h1, h2, h3, Finset.card_union_of_disjoint (disjoint_sdiff_sdiff)]

/-- Daisy cubes are **not** closed under join: there is a daisy cube in `Q₂` containing the vertices
`{0}` and `{1}` but not their join `{0, 1}`. -/
lemma not_join_closed :
    ∃ (D : Finset (Fin 2) → Prop) (A B : Finset (Fin 2)),
      IsDaisy D ∧ D A ∧ D B ∧ ¬ D (A ∪ B) := by
  -- Define the daisy cube in terms of the down-set condition.
  use fun X => X ⊆ (Finset.univ.filter (fun x => x = ⟨0, by norm_num⟩)) ∨ X ⊆ (Finset.univ.filter (fun x => x = ⟨1, by norm_num⟩));
  simp +decide [ IsDaisy ]

end DaisyCube