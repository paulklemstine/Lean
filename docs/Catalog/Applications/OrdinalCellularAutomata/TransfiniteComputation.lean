import Mathlib

/-!
# Cellular Automata at the Ordinals: Transfinite Computation

## A bridge between cellular-automaton dynamics and ordinal (transfinite) computation

This file formalizes a concrete connector between two *a priori* unrelated areas:

* **Cellular automata** — discrete dynamical systems defined by a *local* update rule
  applied uniformly to every cell of a lattice; and
* **Ordinal / transfinite computation** — the theory of computation that proceeds past
  the finite stages `0, 1, 2, …` into transfinite stages `ω, ω+1, …`, as in
  *Infinite Time Turing Machines* (ITTMs) and ordinal recursion.

The dictionary connecting them is the theory of **monotone operators and their
least fixed points computed by transfinite iteration**
(`OrdinalApprox.lfpApprox`, Echenique's constructive proof of Tarski's theorem):

| Cellular automaton                     | Ordinal computation                              |
| :------------------------------------- | :----------------------------------------------- |
| configuration space (`Set ℕ`)          | a complete lattice                               |
| local monotone update rule `spread`    | a monotone operator `f : α →o α`                 |
| one CA step                            | successor stage `lfpApprox f ⊥ (a+1) = f (…)`    |
| limit-of-time (ITTM `liminf`) rule     | limit stage `lfpApprox f ⊥ (limit) = ⨆ …`        |
| the completed computation              | the least fixed point `f.lfp`                    |

### The concrete automaton

We study the one–dimensional **spreading automaton** on cells `ℕ`.  A configuration is
the set of "on" cells.  The local rule is

> cell `n` is on at the next step  ⇔  `n = 0`  (there is a permanent source at the origin)
> or  cell `n-1` was on  (activity spreads one cell to the right per step).

This is a genuine, radius-`1`, monotone cellular automaton (see `mem_spread`).

### The transfinite phenomenon (`transfinite_computation`)

Running the automaton in ordinary (finite) time never turns on *all* cells: after `k`
steps exactly the cells `{0, 1, …, k-1}` are on (`spread_iterate`), so for every finite
`k` the configuration is a *proper* subset of the fully-on configuration
(`finite_stage_not_univ`).

Running it in **transfinite time**, however, the automaton *does* complete: at the very
first limit stage `ω` — where the ITTM/ordinal limit rule takes the union
(`lim inf`) of all earlier configurations — every cell is on
(`spread_reaches_univ_at_omega`).  Moreover `Set.univ` is exactly the least fixed
point of the rule (`spread_lfp`).

Hence the *closure ordinal* of this cellular automaton is exactly `ω`: the computation
is genuinely transfinite, provably impossible to complete in any finite number of
steps yet completed at the first infinite ordinal.  This is the sense in which
cellular automata "run at the ordinals" strictly exceed their finite-time counterparts,
mirroring how ITTMs exceed ordinary Turing machines.

The final theorem `ca_fixed_point_is_transfinitely_computable` records the general
bridge: *any* monotone cellular-automaton rule on *any* complete-lattice configuration
space has its global fixed point reached by transfinite ordinal iteration.
-/

open OrdinalApprox Ordinal Set

namespace OrdinalCA

/-! ## The spreading cellular automaton -/

/-- The spreading cellular automaton on cells `ℕ`, as a monotone operator on the
configuration lattice `Set ℕ`.  A cell is on next iff it is the source `0` or its left
neighbour was on. -/
def spread : Set ℕ →o Set ℕ where
  toFun S := insert 0 (Nat.succ '' S)
  monotone' := fun _ _ h => insert_subset_insert (Set.image_mono h)

/-- **Locality of the rule.**  Membership after one step is determined by the source
cell `0` and the single left neighbour `n-1`, exhibiting `spread` as a radius-`1`
cellular automaton. -/
theorem mem_spread (S : Set ℕ) (n : ℕ) :
    n ∈ spread S ↔ n = 0 ∨ (0 < n ∧ n - 1 ∈ S) := by
  simp only [spread, OrderHom.coe_mk, mem_insert_iff, mem_image]
  constructor
  · rintro (rfl | ⟨m, hm, rfl⟩)
    · exact Or.inl rfl
    · exact Or.inr ⟨Nat.succ_pos m, by simpa using hm⟩
  · rintro (rfl | ⟨hpos, hmem⟩)
    · exact Or.inl rfl
    · exact Or.inr ⟨n - 1, hmem, by omega⟩

/-! ## Finite (ordinary) time: the computation never completes -/

/-- After `k` ordinary steps from the empty configuration, exactly the cells
`{0, 1, …, k-1}` are on. -/
theorem spread_iterate (k : ℕ) : spread^[k] ∅ = Set.Iio k := by
  induction k with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply', ih]; ext x
    simp only [spread, OrderHom.coe_mk, mem_insert_iff, mem_image, mem_Iio]
    constructor
    · rintro (rfl | ⟨m, hm, rfl⟩)
      · omega
      · omega
    · intro hx
      rcases Nat.eq_zero_or_pos x with h | h
      · exact Or.inl h
      · exact Or.inr ⟨x - 1, by omega, by omega⟩

/-- **No finite stage completes the computation:** for every finite time `k`, the cell
`k` is still off, so the configuration is a proper subset of the fully-on
configuration `Set.univ`. -/
theorem finite_stage_not_univ (k : ℕ) : spread^[k] ∅ ≠ Set.univ := by
  intro h
  have : k ∈ Set.Iio k := by rw [← spread_iterate k, h]; trivial
  simp at this

/-! ## The least fixed point (the intended output) -/

/-- The least fixed point of the rule is the *all cells on* configuration.  Being a
fixed point forces every cell to be on, by induction along the spreading direction. -/
theorem spread_lfp : spread.lfp = Set.univ := by
  have hfix : spread spread.lfp = spread.lfp := spread.map_lfp
  have key : ∀ n : ℕ, n ∈ spread.lfp := by
    intro n
    induction n with
    | zero =>
      have h0 : (0 : ℕ) ∈ spread spread.lfp := by
        simp only [spread, OrderHom.coe_mk, mem_insert_iff, true_or]
      rwa [hfix] at h0
    | succ m ih =>
      have hs : (m + 1) ∈ spread spread.lfp := by
        simp only [spread, OrderHom.coe_mk, mem_insert_iff, mem_image]
        exact Or.inr ⟨m, ih, rfl⟩
      rwa [hfix] at hs
  exact le_antisymm le_top (fun n _ => key n)

/-! ## Transfinite time: the ordinal-indexed evolution -/

/-- The ordinal-indexed transfinite evolution agrees with ordinary iteration at every
finite (natural-number) stage: `lfpApprox spread ⊥ n = spread^[n] ⊥`. -/
theorem lfpApprox_nat (n : ℕ) :
    lfpApprox spread ⊥ (n : Ordinal) = spread^[n] (⊥ : Set ℕ) := by
  induction n with
  | zero =>
    simp only [Nat.cast_zero, Function.iterate_zero, id_eq]
    apply le_antisymm _ (le_lfpApprox spread ⊥)
    rw [lfpApprox]; apply sSup_le
    rintro s (⟨b, hb, rfl⟩ | rfl)
    · exact absurd hb (not_lt_of_ge bot_le)
    · exact le_refl _
  | succ m ih =>
    rw [Nat.cast_succ, lfpApprox_add_one spread ⊥ bot_le, ih, Function.iterate_succ_apply']

/-- **The limit (ITTM / ordinal) rule is the union of all finite stages.**  At the
limit ordinal `ω` the transfinite evolution takes the supremum — for a monotone run
this is the `lim inf`/union of all previous configurations, exactly the limit rule of
Infinite Time Turing Machines. -/
theorem lfpApprox_omega_eq_iUnion :
    lfpApprox spread ⊥ ω = ⋃ n : ℕ, spread^[n] (⊥ : Set ℕ) := by
  apply le_antisymm
  · rw [lfpApprox]; apply sSup_le
    rintro s (⟨b, hb, rfl⟩ | rfl)
    · obtain ⟨n, rfl⟩ := lt_omega0.1 hb
      rw [show spread (lfpApprox spread ⊥ (n : Ordinal))
            = lfpApprox spread ⊥ ((n : Ordinal) + 1) from
          (lfpApprox_add_one spread ⊥ bot_le n).symm, ← Nat.cast_succ, lfpApprox_nat]
      exact le_iSup (fun n => spread^[n] (⊥ : Set ℕ)) (n + 1)
    · exact bot_le
  · apply iSup_le; intro n
    rw [← lfpApprox_nat n]
    exact lfpApprox_monotone spread ⊥ (le_of_lt (nat_lt_omega0 n))

/-- **The computation completes at the transfinite stage `ω`:** at the first limit
ordinal every cell is on. -/
theorem spread_reaches_univ_at_omega : lfpApprox spread ⊥ ω = Set.univ := by
  rw [lfpApprox_omega_eq_iUnion]
  apply le_antisymm le_top
  intro n _
  simp only [mem_iUnion]
  exact ⟨n + 1, by rw [Set.bot_eq_empty, spread_iterate]; simp⟩

/-! ## The connector theorems -/

/-- **Connector theorem (concrete).**  The spreading cellular automaton is a genuinely
*transfinite* computation:

* at no finite time `k` is the computation complete (`spread^[k] ∅ ≠ Set.univ`), yet
* at the first transfinite stage `ω` it *is* complete (`lfpApprox spread ⊥ ω = Set.univ`).

Thus its closure ordinal is exactly `ω`: super-finite computational power obtained by
running a cellular automaton at the ordinals. -/
theorem transfinite_computation :
    (∀ k : ℕ, spread^[k] ∅ ≠ Set.univ) ∧ lfpApprox spread ⊥ ω = Set.univ :=
  ⟨finite_stage_not_univ, spread_reaches_univ_at_omega⟩

/-- The transfinite limit stage `ω` reaches precisely the least fixed point of the
rule (the intended output of the computation). -/
theorem omega_stage_eq_lfp : lfpApprox spread ⊥ ω = spread.lfp := by
  rw [spread_reaches_univ_at_omega, spread_lfp]

/-- **Connector theorem (general bridge).**  For *any* cellular-automaton rule `f`
given as a monotone operator on *any* complete-lattice configuration space `α`, the
global fixed point `f.lfp` is *transfinitely computable*: it is a value of the
ordinal-indexed evolution `lfpApprox f ⊥`.  This is the abstract statement of the
bridge — ordinal (transfinite) iteration computes the fixed points of cellular
automata — instantiated concretely above by `spread` with closure ordinal `ω`. -/
theorem ca_fixed_point_is_transfinitely_computable
    {α : Type*} [CompleteLattice α] (f : α →o α) :
    f.lfp ∈ Set.range (lfpApprox f ⊥) :=
  lfp_mem_range_lfpApprox f

end OrdinalCA