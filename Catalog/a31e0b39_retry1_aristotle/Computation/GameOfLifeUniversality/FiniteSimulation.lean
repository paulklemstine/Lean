import Mathlib

/-!
# Conway Life: certified finite simulation and overhead bounds

This file formalizes the B3/S23 rule on finite-support patterns over `ℤ × ℤ`.
It proves, in a dependency chain, that the finite candidate-set algorithm agrees
with the global rule and that after `t` generations it stores at most
`9^t` times as many cells as the initial pattern.

This is foundational infrastructure for a future constructive embedding of a
universal machine. It does not claim the full universality theorem.
-/

open Finset Function

namespace GameOfLifeUniversality

abbrev Cell := ℤ × ℤ
abbrev Pattern := Finset Cell

/-- The eight displacements in the Moore neighborhood. -/
def offsets : Finset Cell :=
  {(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)}

/-- The Moore neighbors of a cell. -/
def neighbors (c : Cell) : Finset Cell :=
  offsets.image fun d => (c.1 + d.1, c.2 + d.2)

/-- Number of live neighbors. -/
def liveNeighborCount (s : Pattern) (c : Cell) : ℕ :=
  ((neighbors c).filter (· ∈ s)).card

/-- Conway's B3/S23 rule, stated globally for an arbitrary cell. -/
def globalNext (s : Pattern) (c : Cell) : Prop :=
  (c ∈ s ∧ (liveNeighborCount s c = 2 ∨ liveNeighborCount s c = 3)) ∨
  (c ∉ s ∧ liveNeighborCount s c = 3)

instance (s : Pattern) (c : Cell) : Decidable (globalNext s c) := by
  unfold globalNext
  infer_instance

/-- All cells that a finite simulator must inspect. -/
def mooreExpansion (s : Pattern) : Pattern := s ∪ s.biUnion neighbors

/-- A computable finite-support implementation of one Life generation. -/
def nextPattern (s : Pattern) : Pattern :=
  (mooreExpansion s).filter (globalNext s)

/-- The Moore displacement set has exactly eight elements. -/
theorem offsets_card : offsets.card = 8 := by
  decide

/-- Every cell has at most eight represented neighbors. -/
theorem neighbors_card_le_eight (c : Cell) : (neighbors c).card ≤ 8 := by
  calc
    (neighbors c).card ≤ offsets.card := Finset.card_image_le
    _ = 8 := offsets_card

/-- The union of all neighbor sets has size at most eight times the live population. -/
theorem neighborUnion_card_le (s : Pattern) :
    (s.biUnion neighbors).card ≤ s.card * 8 := by
  exact Finset.card_biUnion_le_card_mul s neighbors 8
    (fun c _ => neighbors_card_le_eight c)

/-- One candidate expansion has at most nine cells per currently live cell. -/
theorem mooreExpansion_card_le (s : Pattern) :
    (mooreExpansion s).card ≤ 9 * s.card := by
  calc
    (mooreExpansion s).card ≤ s.card + (s.biUnion neighbors).card := by
      simpa [mooreExpansion] using Finset.card_union_le s (s.biUnion neighbors)
    _ ≤ s.card + s.card * 8 := Nat.add_le_add_left (neighborUnion_card_le s) _
    _ = 9 * s.card := by omega

/-- Filtering candidates according to B3/S23 cannot increase their count. -/
theorem nextPattern_card_le_expansion (s : Pattern) :
    (nextPattern s).card ≤ (mooreExpansion s).card := by
  exact Finset.card_filter_le _ _

/-- One simulated generation has at most nine times the previous population. -/
theorem nextPattern_card_le (s : Pattern) :
    (nextPattern s).card ≤ 9 * s.card := by
  exact (nextPattern_card_le_expansion s).trans (mooreExpansion_card_le s)

/-- After `t` generations, the finite simulator has at most `9^t` times the
initial population. This is an explicit exponential storage/work-region bound. -/
theorem iterate_nextPattern_card_le (t : ℕ) (s : Pattern) :
    ((nextPattern^[t]) s).card ≤ 9 ^ t * s.card := by
  induction t generalizing s with
  | zero => simp
  | succ t ih =>
      rw [Function.iterate_succ_apply]
      calc
        ((nextPattern^[t]) (nextPattern s)).card ≤ 9 ^ t * (nextPattern s).card := ih _
        _ ≤ 9 ^ t * (9 * s.card) := Nat.mul_le_mul_left _ (nextPattern_card_le s)
        _ = 9 ^ (t + 1) * s.card := by ring

/-- Negating a Moore displacement yields another Moore displacement. -/
theorem neg_mem_offsets {d : Cell} (hd : d ∈ offsets) : (-d.1, -d.2) ∈ offsets := by
  fin_cases hd <;> decide

/-- Moore adjacency is symmetric. -/
theorem mem_neighbors_comm (c d : Cell) : c ∈ neighbors d ↔ d ∈ neighbors c := by
  constructor <;> intro h
  · rw [neighbors, Finset.mem_image] at h
    obtain ⟨o, ho, heq⟩ := h
    rw [neighbors, Finset.mem_image]
    refine ⟨(-o.1, -o.2), neg_mem_offsets ho, ?_⟩
    have h1 := congrArg Prod.fst heq
    have h2 := congrArg Prod.snd heq
    simp only at h1 h2
    ext <;> simp <;> omega
  · rw [neighbors, Finset.mem_image] at h
    obtain ⟨o, ho, heq⟩ := h
    rw [neighbors, Finset.mem_image]
    refine ⟨(-o.1, -o.2), neg_mem_offsets ho, ?_⟩
    have h1 := congrArg Prod.fst heq
    have h2 := congrArg Prod.snd heq
    simp only at h1 h2
    ext <;> simp <;> omega

/-- Every globally live successor cell occurs in the finite candidate expansion. -/
theorem globalNext_mem_expansion (s : Pattern) (c : Cell)
    (h : globalNext s c) : c ∈ mooreExpansion s := by
  rw [mooreExpansion, Finset.mem_union]
  rcases h with ⟨hc, _⟩ | ⟨_, hcount⟩
  · exact Or.inl hc
  · refine Or.inr ?_
    have hne : ((neighbors c).filter (· ∈ s)).Nonempty := by
      rw [← Finset.card_pos, ← liveNeighborCount, hcount]
      norm_num
    obtain ⟨d, hd⟩ := hne
    rw [Finset.mem_filter] at hd
    obtain ⟨hd_nb, hd_s⟩ := hd
    rw [Finset.mem_biUnion]
    exact ⟨d, hd_s, (mem_neighbors_comm c d).2 hd_nb⟩

/-- The finite simulator computes exactly the global Conway rule. -/
theorem mem_nextPattern_iff_globalNext (s : Pattern) (c : Cell) :
    c ∈ nextPattern s ↔ globalNext s c := by
  rw [nextPattern, Finset.mem_filter]
  constructor
  · exact fun h => h.2
  · exact fun h => ⟨globalNext_mem_expansion s c h, h⟩

/-- Correctness persists through any number of finite simulation steps: the
membership predicate at time `t+1` is exactly the global rule applied at time `t`. -/
theorem iterate_membership_successor (t : ℕ) (s : Pattern) (c : Cell) :
    c ∈ (nextPattern^[t + 1]) s ↔ globalNext ((nextPattern^[t]) s) c := by
  rw [show t + 1 = Nat.succ t by omega, Function.iterate_succ_apply']
  exact mem_nextPattern_iff_globalNext _ _

/-- Capstone finite-simulation theorem: at every time, the next represented
configuration agrees cellwise with the global B3/S23 rule, while the represented
population is bounded explicitly by `9^(t+1)` times its initial size. -/
theorem finite_simulation_correct_and_bounded (t : ℕ) (s : Pattern) :
    (∀ c : Cell,
      c ∈ (nextPattern^[t + 1]) s ↔ globalNext ((nextPattern^[t]) s) c) ∧
    ((nextPattern^[t + 1]) s).card ≤ 9 ^ (t + 1) * s.card := by
  constructor
  · exact fun c => iterate_membership_successor t s c
  · exact iterate_nextPattern_card_le (t + 1) s

end GameOfLifeUniversality