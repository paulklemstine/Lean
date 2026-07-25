import Mathlib
import Pythagorean.OrbitComputation.BerggrenCA

/-!
# Emergent Computation in Pythagorean Orbit Lattices

This file establishes that the Berggren orbit lattice of primitive Pythagorean triples
supports universal computation with controlled geometric resources. The main results
strengthen the existing universality theorems by factoring them through:

1. **Locality**: the cellular automaton update rule depends only on a bounded neighborhood
2. **Polynomial support growth**: the number of active cells grows at most polynomially
3. **Support cardinality bound**: explicit cardinality estimates for active regions
4. **Orbit connectivity**: every address is reachable from the root

## Main Theorems

* `berggren_simulation_support_polynomial` — polynomial (in fact constant) support growth
* `berggren_finite_branching` — each node has exactly 3 children
* `berggren_universality_via_locality_and_growth` — the flagship factored theorem
* `support_card_le_three` — the support of any simulation step has at most 3 elements

## Significance

This recasts primitive Pythagorean triples from a classical number-theoretic classification
object into an intrinsic medium for distributed symbolic computation, where:
- the state space is arithmetically natural,
- locality is inherited from the canonical Diophantine orbit structure,
- computational resources are controlled by geometric growth.
-/

set_option maxHeartbeats 800000

open Classical
noncomputable section

open BDir

/-! ## Support Cardinality Bound -/

/-- The set of active cells is always a subset of {aRay 0, aRay 1, aRay 2}. -/
theorem configSupport_subset_aRays (prog : TCProgram) (s : TCState) (t : ℕ) :
    configSupport ((tcSimulator prog)^[t] (encodeTCState s)) ⊆
    {aRay 0, aRay 1, aRay 2} := by
  intro w hw
  simp only [configSupport, Set.mem_setOf_eq] at hw
  simp only [Set.mem_insert_iff, Set.mem_singleton_iff]
  by_contra hall
  push_neg at hall
  exact hw (tcSimulator_iterate_quiescent prog s w hall.1 hall.2.1 hall.2.2 t)

/-- The finite support is contained in a 3-element finset. -/
theorem support_toFinset_subset (prog : TCProgram) (s : TCState) (t : ℕ) :
    (tcSimulator_iterate_support_finite prog s t).toFinset ⊆
    {aRay 0, aRay 1, aRay 2} := by
  intro w hw
  rw [Set.Finite.mem_toFinset] at hw
  simp only [Finset.mem_insert, Finset.mem_singleton]
  have := configSupport_subset_aRays prog s t hw
  simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at this
  exact this

/-- The support of the simulation has at most 3 elements at every step. -/
theorem support_card_le_three (prog : TCProgram) (s : TCState) (t : ℕ) :
    (tcSimulator_iterate_support_finite prog s t).toFinset.card ≤ 3 := by
  calc (tcSimulator_iterate_support_finite prog s t).toFinset.card
      ≤ ({aRay 0, aRay 1, aRay 2} : Finset OrbitAddr).card :=
        Finset.card_le_card (support_toFinset_subset prog s t)
    _ ≤ 3 := by decide

/-- **Polynomial support growth**: The cardinality of the active region
    grows at most polynomially (in fact, stays constant ≤ 3) in the
    time step and input size. -/
theorem berggren_simulation_support_polynomial
    (prog : TCProgram) (n₁ n₂ : ℕ) :
    ∃ k C : ℕ, 0 < C ∧ ∀ t : ℕ,
      (tcSimulator_iterate_support_finite prog (TCState.init n₁ n₂) t).toFinset.card
        ≤ C * (t + n₁ + n₂ + 1) ^ k := by
  refine ⟨0, 3, by omega, fun t => ?_⟩
  simp only [pow_zero, mul_one]
  exact support_card_le_three prog (TCState.init n₁ n₂) t

/-! ## Finite Branching -/

/-- The set of Berggren children of a triple. -/
def berggrenChildren (t : ℤ × ℤ × ℤ) : Finset (ℤ × ℤ × ℤ) :=
  {berggrenStep .A t, berggrenStep .B t, berggrenStep .C t}

/-
Each positive Pythagorean triple has exactly 3 distinct Berggren children.
-/
theorem berggren_exact_branching (a b c : ℤ) (hpos : TriplePos a b c) :
    (berggrenChildren (a, b, c)).card = 3 := by
  unfold berggrenChildren
  have hAB := berggrenStep_distinct_AB a b c hpos
  have hAC := berggrenStep_distinct_AC a b c hpos
  have hBC := berggrenStep_distinct_BC a b c hpos
  grind +locals

/-! ## Locality and Growth Factored Universality -/

/-- The Berggren CA is a universal simulator. -/
theorem berggren_ca_is_universal (prog : TCProgram) :
    ∀ (n₁ n₂ : ℕ),
      SimulatesTC (berggrenCA prog).step
        (encodeTCState (TCState.init n₁ n₂)) prog n₁ n₂ :=
  fun n₁ n₂ => berggren_ca_simulates prog n₁ n₂

/-- **Flagship theorem**: The Berggren orbit lattice supports universal computation
    via a local cellular automaton rule with polynomial (constant) geometric overhead.

    This factors universality into three independent properties:
    1. Locality (radius 4 in tree distance)
    2. Simulation correctness (faithful tracking of two-counter machine states)
    3. Polynomial support growth (≤ 3 active cells at all times) -/
theorem berggren_universality_via_locality_and_growth :
    ∃ (mkCA : TCProgram → BerggrenCA),
      -- (1) Each CA is local with radius 4
      (∀ prog, (mkCA prog).radius = 4) ∧
      -- (2) Each CA correctly simulates the corresponding program
      (∀ prog n₁ n₂,
        SimulatesTC (mkCA prog).step
          (encodeTCState (TCState.init n₁ n₂)) prog n₁ n₂) ∧
      -- (3) Support grows at most polynomially (constant bound 3)
      (∀ prog n₁ n₂ t,
        (tcSimulator_iterate_support_finite prog (TCState.init n₁ n₂) t).toFinset.card ≤ 3) := by
  exact ⟨berggrenCA,
    fun _ => rfl,
    fun prog n₁ n₂ => berggren_ca_simulates prog n₁ n₂,
    fun prog n₁ n₂ t => support_card_le_three prog (TCState.init n₁ n₂) t⟩

/-! ## Hypotenuse Bound at Active Cells -/

/-- All active cells during simulation correspond to Pythagorean triples
    with hypotenuse bounded by 245. This makes the arithmetic footprint
    of computation bounded. -/
theorem simulation_arithmetic_footprint_bounded
    (prog : TCProgram) (n₁ n₂ t : ℕ) :
    ∀ w ∈ configSupport ((tcSimulator prog)^[t] (encodeTCState (TCState.init n₁ n₂))),
      (addrTriple w).2.2 ≤ 245 ∧
      (addrTriple w).1 ≤ 245 ∧
      (addrTriple w).2.1 ≤ 245 := by
  intro w hw
  have hdepth := tcSimulator_depth_constant prog (TCState.init n₁ n₂) t w hw
  have hbound := hyp_exp_upper_bound w
  have hpow : (7 : ℤ) ^ w.length ≤ 7 ^ 2 := pow_le_pow_right₀ (by norm_num) hdepth
  have hentry := orbit_bitsize_linear_in_depth w
  exact ⟨by linarith, by linarith [hentry.1], by linarith [hentry.2.1]⟩

/-! ## Berggren Generators as a Groupoid -/

/-- The Berggren generators form an invertible system:
    each generator has a well-defined inverse. -/
theorem berggren_generator_invertible (d : BDir) :
    Function.Bijective (berggrenStep d) := by
  exact ⟨berggrenStep_injective d, fun y => ⟨invBerggren d y, inv_fwd_id d y⟩⟩

/-- The Berggren orbit is a tree: distinct directions from the same positive
    Pythagorean parent yield distinct children. -/
theorem berggren_orbit_is_tree_depth1 (d₁ d₂ : BDir) (h : d₁ ≠ d₂)
    (a b c : ℤ) (hpos : TriplePos a b c) :
    berggrenStep d₁ (a, b, c) ≠ berggrenStep d₂ (a, b, c) := by
  rcases d₁ with _ | _ | _ <;> rcases d₂ with _ | _ | _ <;> simp_all <;>
  first
  | exact berggrenStep_distinct_AB a b c hpos
  | exact berggrenStep_distinct_AC a b c hpos
  | exact berggrenStep_distinct_BC a b c hpos
  | exact (berggrenStep_distinct_AB a b c hpos).symm
  | exact (berggrenStep_distinct_AC a b c hpos).symm
  | exact (berggrenStep_distinct_BC a b c hpos).symm

/-! ## Summary: The Arithmetic Computation Substrate -/

/-- **Summary theorem**: The Berggren orbit lattice of Pythagorean triples is an
    arithmetic computation substrate with the following properties:

    1. **Universality**: Any two-counter machine program can be simulated
    2. **Locality**: Updates depend only on radius-4 neighborhoods
    3. **Constant support**: At most 3 cells are ever active
    4. **Bounded arithmetic footprint**: All active triples have entries ≤ 245
    5. **Tree structure**: The orbit has branching factor exactly 3

    Two-counter machines are Turing-complete (Minsky 1967), making this
    a universal computational medium on a number-theoretic substrate. -/
theorem berggren_arithmetic_computation_substrate :
    ∃ (mkCA : TCProgram → BerggrenCA),
      -- Universality: simulates any program on any input
      (∀ prog n₁ n₂,
        SimulatesTC (mkCA prog).step
          (encodeTCState (TCState.init n₁ n₂)) prog n₁ n₂) ∧
      -- Constant support bound
      (∀ prog s t,
        (tcSimulator_iterate_support_finite prog s t).toFinset.card ≤ 3) ∧
      -- Bounded arithmetic footprint
      (∀ prog n₁ n₂ t w,
        w ∈ configSupport ((tcSimulator prog)^[t] (encodeTCState (TCState.init n₁ n₂))) →
        (addrTriple w).2.2 ≤ 245) := by
  exact ⟨berggrenCA,
    fun prog n₁ n₂ => berggren_ca_simulates prog n₁ n₂,
    fun prog s t => support_card_le_three prog s t,
    fun prog n₁ n₂ t w hw => berggren_ca_triple_entry_bound prog n₁ n₂ t w hw⟩

end