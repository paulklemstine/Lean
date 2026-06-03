import Mathlib

/-!
# Tropical Lyapunov Theory: Gradient Descent on Finite Structures

This file develops a Lyapunov-theoretic framework for discrete dynamical systems
on finite types, motivated by tropical renormalization group flows. The key insight
is that on finite types, any function that is strictly decreasing along non-fixed
orbits serves as a "tropical Lyapunov function," and the pigeonhole principle
forces convergence — but the *structure* of the convergence (basin decomposition,
orbit cardinality bounds, depth stratification) reveals rich mathematical content.

## Novel Definitions

* `LyapunovDDS` — A discrete dynamical system on a finite type with a real-valued
  potential (Lyapunov) function that is non-increasing under the dynamics
* `LyapunovDDS.StrictlyDecreasing` — The potential strictly decreases on non-fixed points
* `dds_basin` — The basin of attraction of a fixed point

## Main Results

* `dds_orbit_enters_fixed` — Every orbit reaches a fixed point (pigeonhole + Lyapunov)
* `dds_basin_covers` — The basins of attraction cover the entire type
* `dds_distinct_potentials` — Potential values are distinct along non-stabilized orbits
* `dds_convergence_rate` — Orbit length ≤ V(x)/δ for minimum gap δ
* `dds_sublevel_invariant` — Sub-level sets are forward-invariant
* `dds_level_forces_fixed` — Returning to the same potential level implies fixed
* `dds_morphism_preserves_fixed` — DDS morphisms preserve fixed points
* `dds_morphism_merges_basins` — Morphisms merge basins (tropical merging principle)

## Mathematical Significance

This framework abstracts the "depth flow" structure from tropical renormalization
theory into a general Lyapunov framework. The quantitative convergence bound
`V(x₀) / δ` is the discrete analogue of the continuous-time gradient descent
convergence estimate. The basin decomposition theorem is the discrete analogue
of the Morse decomposition in dynamical systems.
-/

open Finset Function

noncomputable section

/-! ## Core Structure -/

/-- A discrete dynamical system on a finite type with a Lyapunov potential.
    The potential is non-increasing under the dynamics; when it is strictly
    decreasing on non-fixed points, we get strong convergence guarantees. -/
structure LyapunovDDS (α : Type*) [Fintype α] [DecidableEq α] where
  /-- The dynamics: a self-map on α -/
  step : α → α
  /-- The Lyapunov potential function -/
  potential : α → ℝ
  /-- The potential is non-negative -/
  potential_nonneg : ∀ x, 0 ≤ potential x
  /-- The potential is non-increasing under the dynamics -/
  potential_step_le : ∀ x, potential (step x) ≤ potential x

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Iterate the dynamics n times -/
def dds_iter (S : LyapunovDDS α) : ℕ → α → α
  | 0, x => x
  | n + 1, x => S.step (dds_iter S n x)

/-- A point is fixed under the dynamics -/
def dds_fixed (S : LyapunovDDS α) (x : α) : Prop := S.step x = x

/-- The system is strictly decreasing: every non-fixed point has strictly decreasing potential -/
def dds_strict (S : LyapunovDDS α) : Prop :=
  ∀ x, ¬dds_fixed S x → S.potential (S.step x) < S.potential x

/-! ## Potential monotonicity along orbits -/

/-
The potential is non-increasing along orbits
-/
theorem dds_potential_iter_le (S : LyapunovDDS α) (n : ℕ) (x : α) :
    S.potential (dds_iter S n x) ≤ S.potential x := by
  induction' n with n ih;
  · rfl;
  · exact le_trans ( S.potential_step_le _ ) ih

/-! ## Orbit convergence via pigeonhole -/

/-
**Orbit Convergence Theorem**: In a strictly decreasing system on a finite type,
    every orbit reaches a fixed point within at most |α| steps. The proof uses the
    pigeonhole principle: if no fixed point is reached in |α| steps, the orbit visits
    |α|+1 distinct states (since potential strictly decreases), contradicting finiteness.
-/
theorem dds_orbit_enters_fixed (S : LyapunovDDS α) (hS : dds_strict S) (x : α) :
    ∃ N : ℕ, N ≤ Fintype.card α ∧ dds_fixed S (dds_iter S N x) := by
  by_contra! h_contra;
  -- By definition of `dds_iter`, the sequence `dds_iter S n x` is strictly decreasing in potential.
  have h_seq_decreasing : ∀ n < Fintype.card α, (S.potential (dds_iter S (n + 1) x)) < (S.potential (dds_iter S n x)) := by
    intro n hn; specialize h_contra n ( Nat.le_of_lt hn ) ; simp_all +decide [ dds_iter ] ;
    exact hS _ h_contra;
  -- Since the potential is strictly decreasing along the orbit, the sequence `dds_iter S n x` must be injective.
  have h_seq_injective : Function.Injective (fun n : Fin (Fintype.card α + 1) => dds_iter S n x) := by
    have h_seq_injective : StrictAnti (fun n : Fin (Fintype.card α + 1) => S.potential (dds_iter S n x)) := by
      intro i j hij; induction' j using Fin.inductionOn with j ih ih; aesop;
      grind;
    exact fun a b hab => h_seq_injective.injective <| by simp +decide [ hab ] ;
  exact absurd ( Fintype.card_le_of_injective _ h_seq_injective ) ( by simp +decide )

/-
Once a fixed point is reached, all subsequent iterates equal it
-/
theorem dds_iterate_stable (S : LyapunovDDS α) (x : α) (N : ℕ)
    (hN : dds_fixed S (dds_iter S N x)) (n : ℕ) (hn : N ≤ n) :
    dds_iter S n x = dds_iter S N x := by
  induction' n using Nat.strong_induction_on with n ih generalizing N;
  cases hn;
  · rfl;
  · rw [ show dds_iter S ( Nat.succ _ ) x = S.step ( dds_iter S _ x ) from rfl, ih _ ( Nat.lt_succ_self _ ) _ hN ‹_›, hN ]

/-! ## The Distinct Potentials Theorem -/

/-
**Distinct Potentials Theorem**: In a strictly decreasing system, potential values
    along a non-stabilized prefix of an orbit are strictly monotone decreasing.
    If no iterate in {0, ..., j-1} is fixed, then V(iter j x) < V(iter i x) for i < j.
    This is the key structural lemma: it shows that the orbit injects into the reals
    via the potential function until stabilization.
-/
theorem dds_distinct_potentials (S : LyapunovDDS α) (hS : dds_strict S) (x : α)
    (i j : ℕ) (hij : i < j)
    (hnf : ∀ k, k < j → ¬dds_fixed S (dds_iter S k x)) :
    S.potential (dds_iter S j x) < S.potential (dds_iter S i x) := by
  induction' hij with k hk;
  · exact hS _ ( hnf _ ( Nat.lt_succ_self _ ) );
  · refine' lt_trans _ ( ‹ ( ∀ k_1 < k, ¬dds_fixed S ( dds_iter S k_1 x ) ) → S.potential ( dds_iter S k x ) < S.potential ( dds_iter S i x ) › fun n hn => hnf n ( Nat.lt_succ_of_lt hn ) );
    exact hS _ ( hnf _ ( Nat.lt_succ_self _ ) )

/-! ## Basin of attraction -/

/-- The basin of attraction of a fixed point y -/
def dds_basin (S : LyapunovDDS α) (y : α) : Set α :=
  {x | ∃ N : ℕ, dds_iter S N x = y}

/-- Every fixed point is in its own basin -/
theorem dds_basin_self (S : LyapunovDDS α) (y : α) (_hy : dds_fixed S y) :
    y ∈ dds_basin S y := ⟨0, rfl⟩

/-
**Basin Covering Theorem**: Under strict decrease, every point belongs to
    some fixed-point basin. The type decomposes into basins of attraction.
-/
theorem dds_basin_covers (S : LyapunovDDS α) (hS : dds_strict S) (x : α) :
    ∃ y : α, dds_fixed S y ∧ x ∈ dds_basin S y := by
  obtain ⟨ N, hN₁, hN₂ ⟩ := dds_orbit_enters_fixed S hS x;
  exact ⟨ _, hN₂, N, rfl ⟩

/-! ## Potential stratification -/

/-- Sub-level sets are forward-invariant under the dynamics -/
theorem dds_sublevel_invariant (S : LyapunovDDS α) (v : ℝ) (x : α)
    (hx : S.potential x ≤ v) : S.potential (S.step x) ≤ v :=
  le_trans (S.potential_step_le x) hx

/-
**Level Set Rigidity**: Under strict decrease, if an orbit returns to the same
    potential level after k > 0 steps, the starting point must be fixed.
    This captures the "no return" principle of Lyapunov theory.
-/
theorem dds_level_forces_fixed (S : LyapunovDDS α) (hS : dds_strict S)
    (x : α) (k : ℕ) (hk : 0 < k)
    (hlev : S.potential (dds_iter S k x) = S.potential x) :
    dds_fixed S x := by
  contrapose! hlev;
  refine' ne_of_lt ( _ );
  induction' hk with k hk ih;
  · exact hS x hlev;
  · exact lt_of_le_of_lt ( S.potential_step_le _ ) ih

/-! ## Quantitative Convergence Rate -/

/-
**Fundamental Convergence Rate**: For a strictly decreasing system where every
    non-fixed point has potential drop at least δ > 0, the orbit length is bounded
    by V(x)/δ. This is the discrete analogue of the O(1/ε) convergence rate for
    gradient descent. The proof telescopes the potential drops: each of the N steps
    before reaching a fixed point drops the potential by at least δ, so N·δ ≤ V(x).
-/
theorem dds_convergence_rate (S : LyapunovDDS α) (hS : dds_strict S)
    (δ : ℝ) (_hδ : 0 < δ)
    (hgap : ∀ x, ¬dds_fixed S x → δ ≤ S.potential x - S.potential (S.step x))
    (x : α) :
    ∃ N : ℕ, (N : ℝ) * δ ≤ S.potential x ∧ dds_fixed S (dds_iter S N x) := by
  by_contra h_contra;
  -- By dds_orbit_enters_fixed, there exists an N such that N ≤ card α and dds_fixed S (dds_iter S N x).
  obtain ⟨N, hN₁, hN₂⟩ : ∃ N : ℕ, N ≤ Fintype.card α ∧ dds_fixed S (dds_iter S N x) := dds_orbit_enters_fixed S hS x;
  refine' h_contra ⟨ N, _, hN₂ ⟩;
  have h_telescope : ∀ k ≤ N, S.potential x - S.potential (dds_iter S k x) ≥ k * δ := by
    intro k hk;
    induction' k with k ih;
    · simp +decide [ dds_iter ];
    · by_cases h : dds_fixed S ( dds_iter S k x ) <;> simp_all +decide [ dds_iter ];
      · exact False.elim ( h_contra k ( by linarith [ ih hk.le, S.potential_nonneg ( dds_iter S k x ) ] ) h );
      · linarith [ ih hk.le, hgap ( dds_iter S k x ) h ];
  exact le_trans ( h_telescope N le_rfl ) ( sub_le_self _ ( S.potential_nonneg _ ) )

/-! ## Morphism Theory -/

/-- A morphism between Lyapunov DDS: a surjective map commuting with dynamics -/
structure DDSMorphism (S : LyapunovDDS α) {β : Type*} [Fintype β] [DecidableEq β]
    (T : LyapunovDDS β) where
  toFun : α → β
  map_step : ∀ x, toFun (S.step x) = T.step (toFun x)
  surj : Function.Surjective toFun

variable {β : Type*} [Fintype β] [DecidableEq β]

/-
Morphisms commute with iteration
-/
theorem dds_morphism_iter_comm (S : LyapunovDDS α) (T : LyapunovDDS β)
    (φ : DDSMorphism S T) (n : ℕ) (x : α) :
    φ.toFun (dds_iter S n x) = dds_iter T n (φ.toFun x) := by
  induction' n with n ih generalizing x <;> simp_all +decide [ dds_iter ];
  rw [ ← ih, φ.map_step ]

/-
**Morphisms preserve fixed points**: if x is fixed in S, then φ(x) is fixed in T
-/
theorem dds_morphism_preserves_fixed (S : LyapunovDDS α) (T : LyapunovDDS β)
    (φ : DDSMorphism S T) (x : α) (hx : dds_fixed S x) :
    dds_fixed T (φ.toFun x) := by
  unfold dds_fixed at *;
  rw [ ← φ.map_step, hx ]

/-
**The Merging Principle for DDS**: If two points converge to the same fixed point
    in S, their images converge to the same fixed point in T. Morphisms can only
    merge universality classes, never split them. This is the categorical formulation
    of Kadanoff's block-spin renormalization principle.
-/
theorem dds_morphism_merges_basins (S : LyapunovDDS α) (T : LyapunovDDS β)
    (φ : DDSMorphism S T)
    (x y : α) (z : α) (hz : dds_fixed S z)
    (hx : x ∈ dds_basin S z) (hy : y ∈ dds_basin S z) :
    ∃ Nx Ny : ℕ, dds_iter T Nx (φ.toFun x) = dds_iter T Ny (φ.toFun y) := by
  obtain ⟨ Nx, hNx ⟩ := hx
  obtain ⟨ Ny, hNy ⟩ := hy;
  have := dds_morphism_iter_comm S T φ Nx x; have := dds_morphism_iter_comm S T φ Ny y; aesop;

/-! ## Tropical Entropy -/

/-- The tropical entropy of a function on a finite type: the natural log of the
    number of distinct values in its image. Measures the "information content"
    of the potential landscape. -/
def tropicalEntropy (f : α → ℝ) : ℝ :=
  Real.log (Finset.univ.image f).card

/-
Tropical entropy is non-negative when the type is nonempty
-/
omit [DecidableEq α] in
theorem tropicalEntropy_nonneg [Nonempty α] (f : α → ℝ) :
    0 ≤ tropicalEntropy f := by
  exact Real.log_nonneg ( mod_cast Finset.card_pos.mpr ⟨ f ( Classical.arbitrary α ), Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ⟩ )

end