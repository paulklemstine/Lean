import Mathlib
import Novelty.EREPRQuantumBridge
import Novelty.EREPRThroatCapacity
import Novelty.EREPRUltrametricSpacetime
import Novelty.EREPRWedgeMonogamy

/-!
# The emergent metric of `n` Bell pairs

`Novelty.EREPRQuantumBridge` builds the bulk geometry `matchingModel` of `n`
independent Bell pairs: `2n` boundary cells joined in pairs by throats of area
`w i`.  Here we compute its **emergent metric geometry**, using the machinery of
`Novelty.EREPRUltrametricSpacetime`.

* `matching_cap_partner` : the throat capacity of a partner pair is exactly the
  Bell weight, `cap((i,b),(i,¬b)) = w i`;
* `matching_cap_cross` : cells of different pairs have zero capacity;
* `matching_bridgeDist_partner`, `matching_bridgeDist_cross` : hence the emergent
  distance is `exp(-w i)` inside a pair and maximal (`= 1`) across pairs;
* `matching_clusters_are_pairs` : at any scale `r` finer than `1` but coarser
  than all `exp(-w i)`, the clusters of the emergent ultrametric are **exactly
  the Bell pairs** — `n` microscopic Einstein–Rosen bridges and nothing else.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  A state of `n` disjoint Bell pairs should produce a
*disconnected* emergent space with exactly `n` two-point pieces, the pieces
shrinking as the pairs become more entangled.

EXPERIMENT (Experimenter).  `cap` is computed in two moves: the upper bound comes
from the surface around a single cell (`cutWeight_single` evaluated by
`Finset.sum_eq_single_of_mem`, only the partner edge is nonzero), and the lower
bound is free — it is exactly the `I ≤ 2 · throat` inequality applied to
`matching_partner_mutualInfo`.  The cross capacities vanish because no bulk path
leaves a pair (`matching_path_fst`) and `throat_pos_iff_bulkPath`.

ANALYSIS (Analyst).  This is the sharpest possible instance of the sandwich
`I/2 ≤ throat ≤ min(S,S)`: all three quantities coincide with `w i`.  Clusters at
scale `r` are the pairs precisely on the window `max_i exp(-w i) ≤ r < 1`; below
it the space shatters into points, above it everything merges.

CRITIQUE (Critic).  The clustering statement needs both inequalities on `r`:
without `r < 1` distinct pairs would be merged, and without
`exp(-w i) ≤ r` a pair with a thin throat would already be split.  Both are
recorded as hypotheses.
-/

noncomputable section

namespace EmergentGeometry

open Finset

variable {n : ℕ}

/-- Inside the matching geometry, the surface around a single cell has area
equal to the weight of its Bell pair. -/
theorem matching_cutWeight_single (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) (i : Fin n) (b : Bool) :
    cutWeight (matchingModel w hw).toBulkGraph (single (i, b)) = w i := by
  rw [cutWeight_single]
  refine Finset.sum_eq_single_of_mem (i, !b) ?_ ?_ |>.trans ?_
  · refine mem_erase.2 ⟨?_, mem_univ _⟩
    simp
  · intro y _ hy
    show (if (i, b).1 = y.1 ∧ (i, b).2 ≠ y.2 then w (i, b).1 else 0) = 0
    refine if_neg fun hcon => ?_
    apply hy
    obtain ⟨h1, h2⟩ := hcon
    have : y.2 = !b := by cases hb : b <;> cases hy2 : y.2 <;> simp_all
    exact Prod.ext h1.symm this
  · show (if (i, b).1 = ((i, !b) : Fin n × Bool).1 ∧ (i, b).2 ≠ ((i, !b) : Fin n × Bool).2
      then w (i, b).1 else 0) = w i
    simp

/-- **The throat capacity of a Bell pair is its weight.** -/
theorem matching_cap_partner (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) (i : Fin n) (b : Bool) :
    cap (matchingModel w hw).toBulkGraph (i, b) (i, !b) = w i := by
  have hne : ((i, b) : Fin n × Bool) ≠ (i, !b) := by simp
  refine le_antisymm ?_ ?_
  · have hsep : Separates (single ((i, b) : Fin n × Bool)) (single (i, !b))
        (single (i, b)) := by
      refine ⟨fun _ hv => hv, fun x hx => ?_⟩
      have hx' : x = (i, !b) := by simpa [single] using hx
      subst hx'
      simp [single]
    have := throat_le_of_separates (G := (matchingModel w hw).toBulkGraph) hsep
    rwa [matching_cutWeight_single w hw i b] at this
  · have hI := matching_partner_mutualInfo w hw i
    have hbound := mutualInfo_le_two_throat (matchingModel w hw) (single_disj hne)
    -- the two orientations of the pair are related by relabelling `b`
    cases b with
    | false =>
        simp only [Bool.not_false] at hbound ⊢
        rw [hI] at hbound
        simp only [cap]
        linarith
    | true =>
        simp only [Bool.not_true] at hbound ⊢
        have hcomm := mutualInfo_comm (matchingModel w hw)
          (single ((i, true) : Fin n × Bool)) (single (i, false))
        rw [hcomm, hI] at hbound
        simp only [cap]
        linarith

/-- Cells belonging to different Bell pairs have zero throat capacity: no bridge
joins them. -/
theorem matching_cap_cross (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) {i j : Fin n} (hij : i ≠ j)
    (b c : Bool) :
    cap (matchingModel w hw).toBulkGraph (i, b) (j, c) = 0 := by
  have hne : ((i, b) : Fin n × Bool) ≠ (j, c) := fun h => hij (congrArg Prod.fst h)
  rcases lt_or_eq_of_le (cap_nonneg (matchingModel w hw).toBulkGraph (i, b) (j, c)) with h | h
  · exfalso
    have hpath := (cap_pos_iff (matchingModel w hw).toBulkGraph hne).1 h
    exact hij (matching_path_fst hpath)
  · exact h.symm

/-- Inside a Bell pair the emergent distance is `exp(-w i)`. -/
theorem matching_bridgeDist_partner (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) (i : Fin n) (b : Bool) :
    bridgeDist (matchingModel w hw).toBulkGraph (i, b) (i, !b) = Real.exp (-(w i)) := by
  have hne : ((i, b) : Fin n × Bool) ≠ (i, !b) := by simp
  rw [bridgeDist_of_ne hne, matching_cap_partner]

/-- Across Bell pairs the emergent distance is maximal. -/
theorem matching_bridgeDist_cross (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) {i j : Fin n}
    (hij : i ≠ j) (b c : Bool) :
    bridgeDist (matchingModel w hw).toBulkGraph (i, b) (j, c) = 1 := by
  have hne : ((i, b) : Fin n × Bool) ≠ (j, c) := fun h => hij (congrArg Prod.fst h)
  rw [bridgeDist_of_ne hne, matching_cap_cross w hw hij b c]
  simp

/-- **The emergent space of `n` Bell pairs consists of exactly `n` wormholes.**
At any scale `r` lying below `1` and above every `exp(-w i)`, two cells are in the
same cluster of the emergent ultrametric precisely when they belong to the same
Bell pair. -/
theorem matching_clusters_are_pairs (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) {r : ℝ}
    (hr : 0 ≤ r) (hr1 : r < 1) (hrw : ∀ i, Real.exp (-(w i)) ≤ r) (p q : Fin n × Bool) :
    (entanglementSetoid (matchingModel w hw).toBulkGraph hr).r p q ↔ p.1 = q.1 := by
  constructor
  · intro h
    by_contra hne
    have hd : bridgeDist (matchingModel w hw).toBulkGraph p q ≤ r := h
    rw [show p = (p.1, p.2) from rfl, show q = (q.1, q.2) from rfl,
      matching_bridgeDist_cross w hw hne p.2 q.2] at hd
    linarith
  · intro h
    show bridgeDist (matchingModel w hw).toBulkGraph p q ≤ r
    rcases eq_or_ne p q with rfl | hpq
    · simpa using hr
    · have hb : q.2 = !p.2 := by
        cases hp : p.2 <;> cases hq : q.2 <;> simp_all
        · exact hpq (Prod.ext h (by rw [hp, hq]))
        · exact hpq (Prod.ext h (by rw [hp, hq]))
      have hqe : q = (p.1, !p.2) := Prod.ext h.symm hb
      rw [show p = (p.1, p.2) from rfl, hqe, matching_bridgeDist_partner w hw p.1 p.2]
      exact hrw p.1

/-- **ER = EPR for `n` pairs, metric form.**  A Bell pair of positive weight is
a genuine short-cut of the emergent geometry, while cells of different pairs sit
at maximal distance: entanglement, and only entanglement, creates proximity. -/
theorem matching_ER_EPR_metric (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) (i : Fin n) (b : Bool) :
    (0 < w i ↔ bridgeDist (matchingModel w hw).toBulkGraph (i, b) (i, !b) < 1) ∧
      ∀ j : Fin n, i ≠ j → ∀ c : Bool,
        bridgeDist (matchingModel w hw).toBulkGraph (i, b) (j, c) = 1 := by
  refine ⟨?_, fun j hij c => matching_bridgeDist_cross w hw hij b c⟩
  rw [matching_bridgeDist_partner w hw i b]
  constructor
  · intro hpos
    exact Real.exp_lt_one_iff.2 (by linarith)
  · intro hlt
    by_contra hnp
    have : w i = 0 := le_antisymm (not_lt.1 hnp) (hw i)
    rw [this] at hlt
    simp at hlt

end EmergentGeometry