import Mathlib
import Applications.GraphTheory.EdgeSpectralSupersaturationGraphBridge

/-!
# Odd cycles under a core–periphery decomposition

The extremal construction for counting odd cycles with bounded circumference is a join of a
clique (the core) and an independent set (the periphery), with at most one exceptional
peripheral edge.  The results below isolate the structural mechanism behind its circumference:
on a cyclic ordering, every nonexceptional peripheral position must be followed by a core
position.  Rotation is injective, so this gives a charging map from peripheral positions into
core positions.

This incidence argument is independent of the size of the ambient graph and applies to every
simple cycle in the construction.  It yields the sharp length bounds `2a` without an exceptional
edge and `2a+1` with one exceptional peripheral position.  A final trace corollary connects the
absence of triangles to the cubic adjacency moment.
-/

namespace Catalog.Physics.BoundedCircumferenceOddCycles

open Finset SimpleGraph Matrix
open scoped BigOperators

/-- A cyclic core–periphery record.  `next` represents rotation by one position. -/
structure CyclicSplit (ι : Type*) [Fintype ι] [DecidableEq ι] where
  peripheral : Finset ι
  core : Finset ι
  cover : peripheral ∪ core = univ
  disjoint : Disjoint peripheral core
  next : ι → ι
  next_injective : Function.Injective next

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The core and periphery partition all cyclic positions, hence their cardinalities add to the
cycle length. -/
theorem peripheral_card_add_core_card (S : CyclicSplit ι) :
    S.peripheral.card + S.core.card = Fintype.card ι := by
  rw [← card_union_of_disjoint S.disjoint, S.cover, card_univ]

/-- If every peripheral position is followed by a core position, cyclic rotation charges the
periphery injectively into the core. -/
theorem peripheral_card_le_core_card (S : CyclicSplit ι)
    (hnext : ∀ i ∈ S.peripheral, S.next i ∈ S.core) :
    S.peripheral.card ≤ S.core.card := by
  apply Finset.card_le_card_of_injOn S.next
  · intro i hi
    exact hnext i hi
  · intro i hi j hj hij
    exact S.next_injective hij

/-- With one exceptional peripheral position, all remaining peripheral positions still inject
into the core.  This is the combinatorial signature of the single extra edge in the odd-`L`
extremal construction. -/
theorem peripheral_card_le_core_card_add_one (S : CyclicSplit ι) (exception : ι)
    (hnext : ∀ i ∈ S.peripheral, i ≠ exception → S.next i ∈ S.core) :
    S.peripheral.card ≤ S.core.card + 1 := by
  have hcharge : (S.peripheral.erase exception).card ≤ S.core.card := by
    apply Finset.card_le_card_of_injOn S.next
    · intro i hi
      have hip : i ∈ S.peripheral := (mem_erase.mp hi).2
      have hie : i ≠ exception := by
        exact (mem_erase.mp hi).1
      exact hnext i hip hie
    · intro i hi j hj hij
      exact S.next_injective hij
  by_cases he : exception ∈ S.peripheral
  · rw [← card_erase_add_one he]
    omega
  · rw [erase_eq_of_notMem he] at hcharge
    omega

/-- **Even circumference bound.**  If a cyclic object has at most `a` core positions and no two
peripheral positions can occur consecutively, its total length is at most `2a`. -/
theorem cycle_length_le_twice_core_budget (S : CyclicSplit ι) (a : ℕ)
    (hcore : S.core.card ≤ a)
    (hnext : ∀ i ∈ S.peripheral, S.next i ∈ S.core) :
    Fintype.card ι ≤ 2 * a := by
  have hp := peripheral_card_le_core_card S hnext
  have hpartition := peripheral_card_add_core_card S
  omega

/-- **Odd circumference bound.**  Allowing one exceptional peripheral transition increases the
maximum cyclic length by at most one, from `2a` to `2a+1`. -/
theorem cycle_length_le_twice_core_budget_add_one (S : CyclicSplit ι) (a : ℕ)
    (exception : ι) (hcore : S.core.card ≤ a)
    (hnext : ∀ i ∈ S.peripheral, i ≠ exception → S.next i ∈ S.core) :
    Fintype.card ι ≤ 2 * a + 1 := by
  have hp := peripheral_card_le_core_card_add_one S exception hnext
  have hpartition := peripheral_card_add_core_card S
  omega

/-- A parity-uniform form of the circumference calculation.  For `a = ⌊L/2⌋`, the ordinary
join has circumference at most `L` when `L` is even, while one exceptional transition gives the
same bound when `L` is odd. -/
theorem floor_half_cycle_budget (L : ℕ) (S : CyclicSplit ι)
    (hcore : S.core.card ≤ L / 2)
    (hbound : if Even L then
        ∀ i ∈ S.peripheral, S.next i ∈ S.core
      else
        ∃ exception, ∀ i ∈ S.peripheral, i ≠ exception → S.next i ∈ S.core) :
    Fintype.card ι ≤ L := by
  by_cases hL : Even L
  · have hlen := cycle_length_le_twice_core_budget S (L / 2) hcore (by simpa [hL] using hbound)
    have hmod : L % 2 = 0 := Nat.even_iff.mp hL
    omega
  · obtain ⟨exception, he⟩ := by simpa [hL] using hbound
    have hlen := cycle_length_le_twice_core_budget_add_one S (L / 2) exception hcore he
    have hodd : L % 2 = 1 := Nat.odd_iff.mp (Nat.not_even_iff_odd.mp hL)
    omega

/-- A spectral consequence anchored in the trace–subgraph bridge: when a finite graph has no
triangles, its third adjacency moment vanishes. -/
theorem triangle_free_trace_cube {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (htri : (G.cliqueFinset 3).card = 0) :
    (G.adjMatrix ℝ ^ 3).trace = 0 := by
  rw [Catalog.Novelty.EdgeSpectralSupersaturationGraphBridge.trace_cube_adjMatrix_eq_six_mul_triangles]
  simp [htri]

-- !-- Lab Notes -- !--
-- Hypothesis: the bounded circumference of the clique–independent-set join is controlled by an
-- injective charging map on positions of each cycle, rather than by ambient vertex counting.
-- Experiment: encode cyclic rotation abstractly and charge each peripheral position to its
-- successor.  Permit deletion of one exceptional position to model the extra peripheral edge.
-- Analysis: injectivity is the decisive invariant.  It gives `p ≤ c` in the even case and
-- `p ≤ c+1` in the odd case; the partition identity then gives `2a` and `2a+1`.
-- Critique: these statements establish the sharp circumference mechanism, but do not claim the
-- paper's asymptotic extremal enumeration, which requires substantial stability and counting
-- theory beyond this local charging argument.  Empty cycles and zero core budget are covered.
-- Synthesis: `floor_half_cycle_budget` packages both parity cases, while
-- `triangle_free_trace_cube` links forbidden short odd cycles to adjacency spectral moments.
-- !-- End Lab Notes -- !--

end Catalog.Physics.BoundedCircumferenceOddCycles