import Mathlib

/-!
# Self-Modifying Research: an Order–Topology Connector

A research cycle is modeled by a type `Cycle`.  The type of admissible evidence
for the next revision is dependent: `Outcome c` depends on the current cycle
`c`.  A run therefore carries, at each time, an outcome whose type is selected
by the preceding state.

The main theorem connects three areas:

* **dependent type theory:** outcomes live in the varying family `Outcome c`;
* **order theory:** every revision raises a natural-valued quality rank, bounded
  by a finite research budget;
* **topology:** the resulting trajectory converges in every discrete topology.

The substantive hypothesis `plateau_fixed` says that reflection has exhausted
itself when a revision fails to raise rank: such a revision must leave the whole
cycle unchanged.  Bounded monotone ranks eventually plateau, so dependent
self-modification eventually reaches a fixed cycle and hence converges.
-/

open Filter Topology

namespace SelfModifyingResearch

/-- A reflective research system whose next-outcome type depends on its current
cycle.  `qualityBound` is a finite capacity bound, while `plateau_fixed`
expresses extensional reflective stability. -/
structure System where
  Cycle : Type
  Outcome : Cycle → Type
  revise : (c : Cycle) → Outcome c → Cycle
  quality : Cycle → ℕ
  capacity : ℕ
  improves : ∀ c o, quality c ≤ quality (revise c o)
  qualityBound : ∀ c, quality c ≤ capacity
  plateau_fixed : ∀ c o, quality (revise c o) = quality c → revise c o = c

/-- A dependent trajectory: at time `n`, the evidence used by the next cycle
has type `S.Outcome (cycle n)`, which is determined by the current cycle. -/
structure Run (S : System) where
  cycle : ℕ → S.Cycle
  outcome : (n : ℕ) → S.Outcome (cycle n)
  evolves : ∀ n, cycle (n + 1) = S.revise (cycle n) (outcome n)

/-- Quality along any dependent run is monotone. -/
theorem Run.quality_monotone (S : System) (R : Run S) :
    Monotone (fun n => S.quality (R.cycle n)) := by
  intro a b hab
  induction hab with
  | refl => rfl
  | step _ ih =>
    simp only at ih ⊢
    rw [R.evolves]
    exact le_trans ih (S.improves _ _)

/-- Once the quality rank has plateaued, every later dependent revision is the
identity. -/
theorem Run.step_fixed_of_quality_eq (S : System) (R : Run S) (n : ℕ)
    (h : S.quality (R.cycle (n + 1)) = S.quality (R.cycle n)) :
    R.cycle (n + 1) = R.cycle n := by
  rw [R.evolves n] at h ⊢
  exact S.plateau_fixed _ _ h

/-- **Order–topology connector for reflective self-improvement.**

A bounded rank converts the dependent self-modifying run into a bounded
monotone chain in `ℕ`.  The ascending-chain condition makes its rank eventually
constant; reflective plateau stability then makes the actual cycles eventually
constant.  In a discrete topology this is exactly topological convergence.
-/
theorem bounded_reflection_eventually_fixed_and_converges
    (S : System) (R : Run S)
    [TopologicalSpace S.Cycle] [DiscreteTopology S.Cycle] :
    ∃ N : ℕ,
      (∀ n, N ≤ n → R.cycle n = R.cycle N) ∧
      Tendsto R.cycle atTop (𝓝 (R.cycle N)) := by
  -- The quality sequence is monotone and bounded, so eventually constant
  have hmono : Monotone (fun n => S.quality (R.cycle n)) := R.quality_monotone S
  have hbdd : BddAbove (Set.range (fun n => S.quality (R.cycle n))) := by
    use S.capacity
    intro q hq
    obtain ⟨n, rfl⟩ := hq
    exact S.qualityBound _
  -- Get the limit value
  set L := sSup (Set.range (fun n => S.quality (R.cycle n))) with hL
  -- The range is finite (bounded subset of ℕ)
  have hfin : (Set.range (fun n => S.quality (R.cycle n))).Finite := by
    apply Set.Finite.subset (Set.finite_Iic S.capacity)
    exact Set.range_subset_iff.mpr fun n => S.qualityBound (R.cycle n)
  -- A finite nonempty set has a max in the set
  have hne : (Set.range (fun n => S.quality (R.cycle n))).Nonempty := Set.range_nonempty _
  have hL_mem : L ∈ Set.range (fun n => S.quality (R.cycle n)) := by
    have hne' : hfin.toFinset.Nonempty := by
      rw [Finset.nonempty_iff_ne_empty, Ne, ← Finset.coe_eq_empty]
      simp [hfin.coe_toFinset]
    obtain ⟨x, hx_mem, hx_max⟩ := Finset.exists_max_image hfin.toFinset id hne'
    -- x is the supremum
    have hx_in_range : x ∈ Set.range (fun n => S.quality (R.cycle n)) := hfin.mem_toFinset.mp hx_mem
    have hx_eq_L : x = L := by
      apply le_antisymm
      · obtain ⟨i, rfl⟩ := hx_in_range; exact le_ciSup hbdd i
      · exact ciSup_le fun n => hx_max _ (hfin.mem_toFinset.mpr (Set.mem_range_self n))
    rw [← hx_eq_L]; exact hx_in_range
  -- Get N where quality first reaches L
  obtain ⟨N, hN⟩ := hL_mem
  -- Quality is L for all n ≥ N (since monotone and bounded above by L)
  have hquality_fixed : ∀ n, N ≤ n → S.quality (R.cycle n) = L := by
    intro n hn
    have hle : S.quality (R.cycle n) ≤ L := le_ciSup hbdd n
    have hge : L ≤ S.quality (R.cycle n) := by rw [← hN]; exact hmono hn
    exact le_antisymm hle hge
  -- At N and N+1, qualities are equal, so cycle is fixed
  have hcycle_fixed_at_N : R.cycle (N + 1) = R.cycle N := by
    apply R.step_fixed_of_quality_eq S N
    rw [hquality_fixed (N + 1) (Nat.le_succ N), hquality_fixed N (le_refl N)]
  -- By induction, all cycles from N onwards equal R.cycle N
  have hcycle_eventually_const : ∀ n, N ≤ n → R.cycle n = R.cycle N := by
    have : ∀ m, R.cycle (N + m) = R.cycle N := by
      intro m
      induction m with
      | zero => rfl
      | succ k ih =>
        have h1 := hquality_fixed (N + k) (by omega)
        have h2 := hquality_fixed (N + k + 1) (by omega)
        have heq := R.step_fixed_of_quality_eq S (N + k) (h2.trans h1.symm)
        simp only [Nat.add_succ]
        rw [heq, ih]
    intro n hn
    obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hn
    exact this m
  exact ⟨N, hcycle_eventually_const, tendsto_nhds_of_eventually_eq (Filter.eventually_atTop.mpr ⟨N, hcycle_eventually_const⟩)⟩

/-- The limiting cycle is a fixed point for every outcome actually selected by
this run after stabilization. -/
theorem eventual_selected_outcomes_are_fixed
    (S : System) (R : Run S) :
    ∃ N : ℕ, ∀ n, N ≤ n →
      S.revise (R.cycle n) (R.outcome n) = R.cycle n := by
  -- The quality sequence is monotone and bounded, so eventually constant
  have hmono : Monotone (fun n => S.quality (R.cycle n)) := R.quality_monotone S
  have hbdd : BddAbove (Set.range (fun n => S.quality (R.cycle n))) := by
    use S.capacity
    intro q hq
    obtain ⟨n, rfl⟩ := hq
    exact S.qualityBound _
  -- Get the limit value
  set L := sSup (Set.range (fun n => S.quality (R.cycle n))) with hL
  -- The range is finite (bounded subset of ℕ)
  have hfin : (Set.range (fun n => S.quality (R.cycle n))).Finite := by
    apply Set.Finite.subset (Set.finite_Iic S.capacity)
    exact Set.range_subset_iff.mpr fun n => S.qualityBound (R.cycle n)
  -- A finite nonempty set has a max in the set
  have hne : (Set.range (fun n => S.quality (R.cycle n))).Nonempty := Set.range_nonempty _
  have hL_mem : L ∈ Set.range (fun n => S.quality (R.cycle n)) := by
    have hne' : hfin.toFinset.Nonempty := by
      rw [Finset.nonempty_iff_ne_empty, Ne, ← Finset.coe_eq_empty]
      simp [hfin.coe_toFinset]
    obtain ⟨x, hx_mem, hx_max⟩ := Finset.exists_max_image hfin.toFinset id hne'
    -- x is the supremum
    have hx_in_range : x ∈ Set.range (fun n => S.quality (R.cycle n)) := hfin.mem_toFinset.mp hx_mem
    have hx_eq_L : x = L := by
      apply le_antisymm
      · obtain ⟨i, rfl⟩ := hx_in_range; exact le_ciSup hbdd i
      · exact ciSup_le fun n => hx_max _ (hfin.mem_toFinset.mpr (Set.mem_range_self n))
    rw [← hx_eq_L]; exact hx_in_range
  -- Get N where quality first reaches L
  obtain ⟨N, hN⟩ := hL_mem
  -- Quality is L for all n ≥ N (since monotone and bounded above by L)
  have hquality_fixed : ∀ n, N ≤ n → S.quality (R.cycle n) = L := by
    intro n hn
    have hle : S.quality (R.cycle n) ≤ L := le_ciSup hbdd n
    have hge : L ≤ S.quality (R.cycle n) := by rw [← hN]; exact hmono hn
    exact le_antisymm hle hge
  -- At N and N+1, qualities are equal, so cycle is fixed
  have hcycle_fixed_at_N : R.cycle (N + 1) = R.cycle N := by
    apply R.step_fixed_of_quality_eq S N
    rw [hquality_fixed (N + 1) (Nat.le_succ N), hquality_fixed N (le_refl N)]
  -- By induction, all cycles from N onwards equal R.cycle N
  have hcycle_eventually_const : ∀ n, N ≤ n → R.cycle n = R.cycle N := by
    have : ∀ m, R.cycle (N + m) = R.cycle N := by
      intro m
      induction m with
      | zero => rfl
      | succ k ih =>
        have h1 := hquality_fixed (N + k) (by omega)
        have h2 := hquality_fixed (N + k + 1) (by omega)
        have heq := R.step_fixed_of_quality_eq S (N + k) (h2.trans h1.symm)
        simp only [Nat.add_succ]
        rw [heq, ih]
    intro n hn
    obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hn
    exact this m
  -- Now for n ≥ N, since R.cycle (n+1) = R.cycle n, we have revision = cycle
  use N
  intro n hn
  have heq : R.cycle (n + 1) = R.cycle n := by
    rw [hcycle_eventually_const (n + 1) (Nat.le_succ_of_le hn), hcycle_eventually_const n hn]
  rw [R.evolves n] at heq
  exact heq

end SelfModifyingResearch