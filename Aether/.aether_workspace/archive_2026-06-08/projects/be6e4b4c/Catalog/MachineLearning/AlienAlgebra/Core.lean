import Mathlib

/-!
# Alien Algebra: Non-Archimedean Life Forms in Idempotent Semirings

This module formalizes the mathematical foundations of "self-replication in tropical media":
fixed points as organisms, monotone idempotent endomorphisms as replication laws, and
tropical sup-norm perturbation bounds as mutation control.

## Main Results

- `image_eq_fixedPoints_of_idempotent`: The image of an idempotent function equals its
  fixed-point set.
- `iterate_stabilizes_in_one_step`: Every orbit of an idempotent reaches a fixed point
  in one step.
- `bounded_tropical_orbit_reaches_fixedPoint`: Monotone inflationary maps on finite cubes
  stabilize in bounded time.
- `attractor_mutation_bound`: Lipschitz idempotent maps preserve mutation bounds and
  attractor structure.
- `comp_idempotent_of_commuting`: Commuting idempotent maps compose to an idempotent.
- `TropicalReplicator`: A structure capturing closure-operator replication dynamics.
- Tropical cellular automata monotonicity and attractor theorems.
-/

noncomputable section

open Function Set

/-- A function is idempotent if applying it twice equals applying it once. -/
def IsIdempotent (F : α → α) : Prop := ∀ x, F (F x) = F x

/-! ## Part A: Idempotent Attractor Theory -/

/-- Every orbit of an idempotent function reaches a fixed point in one step. -/
theorem iterate_stabilizes_in_one_step
    {n : ℕ}
    (F : (Fin n → ℕ) → (Fin n → ℕ))
    (hidem : IsIdempotent F)
    (x : Fin n → ℕ) :
    F (F x) = F x :=
  hidem x

/-
The image of an idempotent function is exactly the set of its fixed points.
This is the algebraic core of "self-replication as attractor formation."
-/
theorem image_eq_fixedPoints_of_idempotent
    {n : ℕ}
    (F : (Fin n → ℕ) → (Fin n → ℕ))
    (hidem : IsIdempotent F) :
    Set.range F = {x | F x = x} := by
  exact Set.ext fun x => ⟨by rintro ⟨y, rfl⟩; exact mem_setOf.mpr (hidem y),
    by rintro h; exact ⟨x, h⟩⟩

/-- General version: the image of any idempotent equals its fixed-point set. -/
theorem image_eq_fixedPoints_of_idempotent_general
    {α : Type*}
    (F : α → α)
    (hidem : IsIdempotent F) :
    Set.range F = {x | F x = x} := by
  exact Set.ext fun x => ⟨by rintro ⟨y, rfl⟩; exact mem_setOf.mpr (hidem y),
    by rintro h; exact ⟨x, h⟩⟩

/-! ## Part B: Finite Monotone Inflationary Dynamics -/

/-- On a finite type with a preorder, a monotone inflationary map has a universal
stabilization bound: there exists k such that every orbit has stabilized by step k. -/

/-
Note: requires PartialOrder (antisymmetry), not just Preorder. With only a Preorder,
the statement is false: consider {a,b} with a ≤ b, b ≤ a, a ≠ b and F swapping them.
-/
theorem exists_iterate_fixedPoint_of_finite_monotone_inflationary
    {α : Type*} [Finite α] [PartialOrder α]
    (F : α → α)
    (_hmono : Monotone F)
    (hinfl : ∀ x, x ≤ F x) :
    ∃ k : ℕ, ∀ x, F^[k] x = F^[k+1] x := by
  by_contra h_not_stabilize;
  -- Since the order is antisymmetric, the sequence $F^[k] x$ must stabilize for each $x$.
  have h_stabilize : ∀ x, ∃ k, F^[k] x = F^[k+1] x := by
    intro x
    have h_seq_finite : Set.Finite (Set.range (fun k => F^[k] x)) := by
      exact Set.toFinite _
    generalize_proofs at *; (
    by_contra h_not_stabilize_x
    push_neg at h_not_stabilize_x
    have h_seq_increasing : ∀ k, F^[k] x < F^[k+1] x := by
      exact fun k => lt_of_le_of_ne ( by simpa only [ Function.iterate_succ_apply' ] using hinfl _ ) ( h_not_stabilize_x k )
    generalize_proofs at *; (
    exact h_seq_finite.not_infinite <| Set.infinite_range_of_injective ( StrictMono.injective <| strictMono_nat_of_lt_succ h_seq_increasing )));
  choose k hk using h_stabilize;
  -- Since α is finite, the set of k(x) values is also finite. Let m be the maximum of these k(x) values.
  obtain ⟨m, hm⟩ : ∃ m, ∀ x, k x ≤ m := by
    cases nonempty_fintype α ; exact ⟨ Finset.univ.sup k, fun x => Finset.le_sup ( f := k ) ( Finset.mem_univ x ) ⟩;
  refine' h_not_stabilize ⟨ m, fun x => _ ⟩;
  -- Since $k(x) \leq m$, we have $F^[k(x)] x = F^[m] x$ by the monotonicity of $F$.
  have h_eq : ∀ n ≥ k x, F^[n] x = F^[k x] x := by
    intro n hn; induction hn <;> simp_all +singlePass [ Function.iterate_succ_apply' ] ;
  rw [ h_eq m ( hm x ), h_eq ( m + 1 ) ( Nat.le_succ_of_le ( hm x ) ), hk ]

/-
On the finite cube `Fin n → Fin (m+1)`, a monotone inflationary map reaches a
fixed point within `n * m + 1` steps. This is the "emergence theorem": seeds evolve
into stable organisms in bounded finite time.
-/
theorem bounded_tropical_orbit_reaches_fixedPoint
    {n m : ℕ}
    (F : (Fin n → Fin (m+1)) → (Fin n → Fin (m+1)))
    (_hmono : Monotone F)
    (hinfl : ∀ x, x ≤ F x) :
    ∀ x, ∃ k ≤ n * m + 1, F^[k] x = F^[k+1] x := by
  intro x
  by_contra h_contra
  push_neg at h_contra
  have h_seq : ∀ k ≤ n * m + 1, F^[k] x < F^[k+1] x := by
    exact fun k hk => lt_of_le_of_ne ( by simpa only [ Function.iterate_succ_apply' ] using hinfl _ ) ( h_contra k hk );
  -- Consider the "potential" function: sum over coordinates i of (F^[k] x i).val. This starts at some value and increases by at least 1 each time the state changes.
  have h_potential : ∀ k ≤ n * m + 1, ∑ i, (F^[k] x i).val < ∑ i, (F^[k+1] x i).val := by
    intro k hk; specialize h_seq k hk; simp_all +decide [ Pi.lt_def ] ;
    exact Finset.sum_lt_sum ( fun i _ => by exact_mod_cast h_seq.1 i ) ( by obtain ⟨ i, hi ⟩ := h_seq.2; exact ⟨ i, Finset.mem_univ _, hi ⟩ );
  -- The total "weight" sum can increase at most n*m times (from minimum 0 to maximum n*m).
  have h_sum_bound : ∀ k ≤ n * m + 1, ∑ i, (F^[k] x i).val ≥ k := by
    intro k hk; induction' k with k ih <;> norm_num [ Function.iterate_succ_apply' ] at *;
    grind +qlia;
  exact absurd ( h_sum_bound ( n * m + 1 ) le_rfl ) ( by have := Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => Fin.is_le ( F^[n * m + 1] x i ) ; norm_num at * ; nlinarith )

/-! ## Part C: Mutation Stability -/

/-- Coordinatewise distance bound between two states. -/
def coordwiseDistLE {n : ℕ} (ε : ℕ) (x y : Fin n → ℕ) : Prop :=
  ∀ i, Nat.dist (x i) (y i) ≤ ε

/-- A Lipschitz condition on F with respect to coordinatewise distance
directly implies mutation nonamplification. -/
theorem mutation_nonamplification
    {n : ℕ}
    (F : (Fin n → ℕ) → (Fin n → ℕ))
    (hLip : ∀ x y ε, coordwiseDistLE ε x y → coordwiseDistLE ε (F x) (F y)) :
    ∀ x y ε, coordwiseDistLE ε x y → coordwiseDistLE ε (F x) (F y) :=
  hLip

/-
Combined attractor-mutation bound: a Lipschitz idempotent map preserves
coordinatewise distance bounds AND guarantees fixed-point attractor structure.
-/
theorem attractor_mutation_bound
    {n : ℕ}
    (F : (Fin n → ℕ) → (Fin n → ℕ))
    (hidem : IsIdempotent F)
    (hLip : ∀ x y ε, coordwiseDistLE ε x y → coordwiseDistLE ε (F x) (F y)) :
    ∀ x y ε, coordwiseDistLE ε x y → coordwiseDistLE ε (F x) (F y) ∧
      F (F x) = F x ∧ F (F y) = F y := by
  exact fun x y ε h => ⟨ hLip x y ε h, hidem _, hidem _ ⟩

/-! ## Stretch Goal: Composition of Replicators -/

/-
The composition of two commuting idempotent maps is idempotent.
This means alien organisms can be modularly assembled from simpler replicators.
-/
theorem comp_idempotent_of_commuting
    {α : Type*}
    {F G : α → α}
    (hF : IsIdempotent F)
    (hG : IsIdempotent G)
    (hcomm : ∀ x, F (G x) = G (F x)) :
    IsIdempotent (F ∘ G) := by
  intro x
  show F (G (F (G x))) = F (G x)
  rw [hcomm (F (G x)), hF (G x), hcomm x, hG (F x)]

/-! ## TropicalReplicator Structure -/

/-- A closure-style replicator: a monotone, idempotent, inflationary endomorphism. -/
structure TropicalReplicator (α : Type*) [Preorder α] where
  step : α → α
  mono : Monotone step
  idem : IsIdempotent step
  infl : ∀ x, x ≤ step x

/-- For a tropical replicator, fixed points are exactly the range of the step function. -/
theorem TropicalReplicator.fixed_iff_in_range
    {α : Type*} [Preorder α]
    (R : TropicalReplicator α) :
    Set.range R.step = {x | R.step x = x} :=
  image_eq_fixedPoints_of_idempotent_general R.step R.idem

/-! ## Part D: Tropical Cellular Automata -/

/-- A local tropical CA rule: at each cell, take the minimum of the cell and its
neighbors (using wrapping/modular indexing on the torus). -/
def tropCA_local {N : ℕ} (x : Fin (N+1) → ℕ) (i : Fin (N+1)) : ℕ :=
  min (x i) (min (x ⟨(i.val + 1) % (N+1), Nat.mod_lt _ (Nat.succ_pos N)⟩)
                  (x ⟨(i.val + N) % (N+1), Nat.mod_lt _ (Nat.succ_pos N)⟩))

/-- The global tropical CA: apply the local rule at every cell. -/
def tropCA {N : ℕ} (x : Fin (N+1) → ℕ) : Fin (N+1) → ℕ :=
  fun i => tropCA_local x i

/-
The tropical min-CA is monotone: if x ≤ y pointwise, then tropCA x ≤ tropCA y.
-/
theorem tropCA_monotone {N : ℕ} : Monotone (@tropCA N) := by
  refine' fun x y h => fun i => _;
  exact min_le_min ( h _ ) ( min_le_min ( h _ ) ( h _ ) )

/-
tropCA is deflationary: tropCA x ≤ x pointwise.
-/
theorem tropCA_deflationary {N : ℕ} (x : Fin (N+1) → ℕ) : tropCA x ≤ x := by
  exact fun i => min_le_left _ _

/-
Iterated tropCA is weakly decreasing.
-/
theorem tropCA_iter_antitone {N : ℕ} (x : Fin (N+1) → ℕ) :
    ∀ k, tropCA^[k+1] x ≤ tropCA^[k] x := by
  exact fun k => Function.iterate_succ_apply' tropCA k x ▸ tropCA_deflationary _

/-
The total weight (sum of all coordinates) is non-increasing under tropCA.
-/
theorem tropCA_weight_nonincreasing {N : ℕ} (x : Fin (N+1) → ℕ) :
    ∑ i, tropCA x i ≤ ∑ i, x i := by
  exact Finset.sum_le_sum fun i _ => tropCA_deflationary x i

/-
The tropCA eventually stabilizes: there exists some k such that further
application doesn't change the state.
-/
theorem tropCA_eventually_stabilizes {N : ℕ} (x : Fin (N+1) → ℕ) :
    ∃ k, tropCA^[k] x = tropCA^[k+1] x := by
  -- By the properties of the tropCA function, the sequence of total weights is non-increasing and bounded below by zero.
  have h_noninc : Antitone (fun k => ∑ i, tropCA^[k] x i) := by
    refine' antitone_nat_of_succ_le _;
    exact fun n => by simpa only [ Function.iterate_succ_apply' ] using tropCA_weight_nonincreasing _;
  -- Since the sequence of total weights is non-increasing and bounded below by zero, it must eventually stabilize.
  obtain ⟨k, hk⟩ : ∃ k, ∀ j ≥ k, ∑ i, tropCA^[j] x i = ∑ i, tropCA^[k] x i := by
    -- Apply the fact that a non-increasing sequence of natural numbers that is bounded below must stabilize.
    have h_stabilize : Filter.Tendsto (fun k => ∑ i, tropCA^[k] x i) Filter.atTop (nhds (sInf {∑ i, tropCA^[k] x i | k : ℕ})) := by
      exact tendsto_atTop_ciInf h_noninc ⟨ 0, Set.forall_mem_range.mpr fun k => Nat.zero_le _ ⟩;
    norm_num +zetaDelta at *;
    exact ⟨ h_stabilize.choose, fun j hj => by rw [ h_stabilize.choose_spec j hj, h_stabilize.choose_spec _ le_rfl ] ⟩;
  use k;
  have h_eq : ∀ i, tropCA^[k+1] x i = tropCA^[k] x i := by
    intro i
    have h_eq : tropCA^[k+1] x i ≤ tropCA^[k] x i := by
      exact Function.iterate_succ_apply' tropCA k x ▸ tropCA_deflationary _ i;
    exact le_antisymm h_eq ( Nat.le_of_not_lt fun h => by have := hk ( k + 1 ) ( by linarith ) ; exact absurd this ( ne_of_lt ( Finset.sum_lt_sum ( fun a _ => by exact Nat.le_of_lt_succ ( by { have := hk ( k + 1 ) ( by linarith ) ; have := hk k ( by linarith ) ; exact Nat.lt_succ_of_le ( by { have := tropCA_iter_antitone x k a; aesop } ) } ) ) ⟨ i, Finset.mem_univ i, h ⟩ ) ) );
  exact funext fun i => h_eq i ▸ rfl

end