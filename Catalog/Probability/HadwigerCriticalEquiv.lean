/-
  # Hadwiger's conjecture is equivalent to its vertex-critical fragment

  This file settles the vertex-critical form of Conjecture 4 of
  `FUTURE_DIRECTIONS.md`: Hadwiger's conjecture for a parameter `k` need only be
  checked on *vertex-critical* graphs, i.e. graphs that are not `k`-colourable
  but become `k`-colourable after the deletion of any single vertex.

      `HadwigerProperty k ↔ HadwigerCriticalProperty k`   (`hadwigerProperty_iff_critical`)

  The `←` direction is the substantial one: a minimal non-`k`-colourable vertex
  subset (`exists_critical_subset`, from `HadwigerCritical.lean`) induces a
  vertex-critical subgraph, and a `K_{k+1}` minor of an induced subgraph is a
  `K_{k+1}` minor of the ambient graph (`isMinor_of_isMinor_induce`).

  The bridge between the ambient-colouring predicate `ColorableOn` and
  colourability of the induced subgraph is `colorableOn_iff_induce`, valid as
  soon as one colour is available; the degenerate parameter `k = 0` is covered by
  the already-proved `hadwiger_zero`.

  -- !-- Lab Notes -- !--
  * No graph isomorphism is needed to see that deleting a vertex from an induced
    subgraph is again an induced subgraph: a colouring of `G.induce ↑(S.erase x)`
    can be *restricted* along the two coercions, which is what
    `colorable_induce_compl_of_colorableOn_erase` does.
  * The equivalence makes "minimal counterexample" arguments available inside the
    formal development: any counterexample to `HadwigerProperty k` yields a
    vertex-critical one.
-/
import Mathlib
import Probability.HadwigerCritical

namespace Hadwiger

open SimpleGraph Finset

variable {V : Type*} {G : SimpleGraph V} {k : ℕ}

/-- Colourability of a vertex subset is colourability of the induced subgraph
(as soon as at least one colour is available). -/
theorem colorableOn_iff_induce [Fintype V] [DecidableEq V] {S : Finset V} (hk : 0 < k) :
    ColorableOn G S k ↔ (G.induce (↑S : Set V)).Colorable k := by
  classical
  constructor
  · rintro ⟨c, hc⟩
    refine ⟨Coloring.mk (fun x => c x.1) ?_⟩
    rintro ⟨x, hx⟩ ⟨y, hy⟩ hxy
    exact hc x (by simpa using hx) y (by simpa using hy) hxy
  · rintro ⟨C⟩
    refine ⟨fun x => if hx : x ∈ S then C ⟨x, by simpa using hx⟩ else ⟨0, hk⟩, ?_⟩
    intro x hx y hy hxy
    dsimp only
    rw [dif_pos hx, dif_pos hy]
    exact C.valid hxy

/-- Deleting a vertex from an induced subgraph: a colouring of the subset with
that vertex erased colours the corresponding induced subgraph. -/
theorem colorable_induce_compl_of_colorableOn_erase [Fintype V] [DecidableEq V]
    {S : Finset V} {x : (↑S : Set V)} (h : ColorableOn G (S.erase x.1) k) :
    (((G.induce (↑S : Set V)).induce ({x}ᶜ : Set (↑S : Set V)))).Colorable k := by
  obtain ⟨c, hc⟩ := h
  refine ⟨Coloring.mk (fun y => c y.1.1) ?_⟩
  rintro ⟨⟨y, hyS⟩, hy⟩ ⟨⟨z, hzS⟩, hz⟩ hyz
  have hyx : y ≠ x.1 := fun hcon => hy (by
    simp only [Set.mem_singleton_iff]
    exact Subtype.ext hcon)
  have hzx : z ≠ x.1 := fun hcon => hz (by
    simp only [Set.mem_singleton_iff]
    exact Subtype.ext hcon)
  exact hc y (Finset.mem_erase.mpr ⟨hyx, by simpa using hyS⟩)
    z (Finset.mem_erase.mpr ⟨hzx, by simpa using hzS⟩) hyz

/-- **Hadwiger's conjecture restricted to vertex-critical graphs**: graphs that
are not `k`-colourable but in which the deletion of any single vertex restores
`k`-colourability. -/
def HadwigerCriticalProperty (k : ℕ) : Prop :=
  ∀ (V : Type) [Finite V] (G : SimpleGraph V), ¬ G.Colorable k →
    (∀ v : V, (G.induce ({v}ᶜ : Set V)).Colorable k) → CompleteMinor (k + 1) G

/-- **The vertex-critical reduction.**  Hadwiger's conjecture for `k` holds if
and only if it holds for all vertex-critical graphs. -/
theorem hadwigerProperty_iff_critical (k : ℕ) :
    HadwigerProperty k ↔ HadwigerCriticalProperty k := by
  classical
  constructor
  · intro h V _ G hcol _
    exact h V G hcol
  · intro h
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · exact hadwiger_zero
    intro V _ G hcol
    have : Fintype V := Fintype.ofFinite V
    have : DecidableRel G.Adj := Classical.decRel _
    obtain ⟨S, hS, hmin⟩ := exists_critical_subset hcol
    have hne : S.Nonempty := by
      rcases S.eq_empty_or_nonempty with rfl | hne
      · exact absurd (colorableOn_empty hk) hS
      · exact hne
    -- the induced subgraph on `S` is vertex-critical
    have hnotcol : ¬ (G.induce (↑S : Set V)).Colorable k := fun hcon =>
      hS ((colorableOn_iff_induce hk).mpr hcon)
    have hcrit : ∀ x : (↑S : Set V),
        (((G.induce (↑S : Set V)).induce ({x}ᶜ : Set (↑S : Set V)))).Colorable k := by
      intro x
      refine colorable_induce_compl_of_colorableOn_erase ?_
      by_contra hcon
      have hle := hmin _ hcon
      have hxS : x.1 ∈ S := Finset.mem_coe.mp x.2
      rw [Finset.card_erase_of_mem hxS] at hle
      have hpos : 0 < S.card := Finset.card_pos.mpr hne
      omega
    exact isMinor_of_isMinor_induce (h _ _ hnotcol hcrit)

/-! ## The minimum-degree fragment -/

/-- **Hadwiger's conjecture restricted to graphs of minimum degree at least `k`.**
Unlike the hypothesis of `hadwigerProperty_of_minDegree_forces`, the graph is
here also assumed not to be `k`-colourable, which makes the restriction
*equivalent* to the full conjecture rather than strictly stronger. -/
def HadwigerMinDegreeProperty (k : ℕ) : Prop :=
  ∀ (V : Type) [Finite V] (G : SimpleGraph V), ¬ G.Colorable k →
    (∀ v : V, k ≤ Nat.card (G.neighborSet v)) → CompleteMinor (k + 1) G

/-- **The minimum-degree reduction is an equivalence.**  Hadwiger's conjecture
for `k` holds if and only if it holds for non-`k`-colourable graphs of minimum
degree at least `k`. -/
theorem hadwigerProperty_iff_minDegree (k : ℕ) :
    HadwigerProperty k ↔ HadwigerMinDegreeProperty k := by
  classical
  constructor
  · intro h V _ G hcol _
    exact h V G hcol
  · intro h
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · exact hadwiger_zero
    intro V _ G hcol
    have : Fintype V := Fintype.ofFinite V
    have : DecidableRel G.Adj := Classical.decRel _
    obtain ⟨S, hne, hSnc, hdeg⟩ := exists_subset_minDegree_of_not_colorable hcol
    have hnotcol : ¬ (G.induce (↑S : Set V)).Colorable k := fun hcon =>
      hSnc ((colorableOn_iff_induce hk).mpr hcon)
    have hdeg' : ∀ w : (↑S : Set V), k ≤ Nat.card ((G.induce (↑S : Set V)).neighborSet w) := by
      rintro ⟨v, hv⟩
      have hvS : v ∈ S := Finset.mem_coe.mp hv
      rw [card_neighborSet_induce hvS]
      exact hdeg v hvS
    exact isMinor_of_isMinor_induce (h _ _ hnotcol hdeg')


end Hadwiger

#print axioms Hadwiger.colorableOn_iff_induce
#print axioms Hadwiger.hadwigerProperty_iff_critical
#print axioms Hadwiger.hadwigerProperty_iff_minDegree