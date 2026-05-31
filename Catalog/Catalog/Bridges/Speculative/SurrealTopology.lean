import Mathlib

open Set TopologicalSpace

/-! # Surreal Topology: Topological Structure of Ordered Continua

This file develops the topological theory of densely ordered spaces with the order topology,
motivated by the question of what topology the surreal numbers would carry. Since the full
surreal field `No` is a proper class and cannot directly carry a Lean `TopologicalSpace`
instance, we instead develop general theorems about set-sized ordered topological spaces
that capture the essential "surreal-like" properties: dense ordering, no endpoints,
interval connectedness, and contractibility.

## Main definitions

* `IsOrderConvex` — a set is order-convex if it contains every element between any two of
  its members.
* `SurrealLikeLine` — a class axiomatizing ordered topological spaces modeling surreal
  behavior.

## Main results

* `isPreconnected_univ_of_intervalPreconnected` — if every `Icc a b` is preconnected, so
  is the whole space.
* `connectedSpace_of_intervalPreconnected` — ConnectedSpace version.
* `ordConnected_isConnected_of_nonempty` — nonempty order-connected sets are connected.
* `interval_topology_unique` — the interval-generated topology is unique.
* `icc_contractible` — `Icc a b` in ℝ is contractible.

## References

* J.H. Conway, *On Numbers and Games*, Academic Press, 1976.
-/

/-! ## Order Convexity -/

/-- A set `s` in an ordered type is *order-convex* if whenever `a, b ∈ s` and `a ≤ c ≤ b`,
then `c ∈ s`. -/
def IsOrderConvex {α : Type*} [LE α] (s : Set α) : Prop :=
  ∀ ⦃a b c : α⦄, a ∈ s → b ∈ s → a ≤ c → c ≤ b → c ∈ s

theorem isOrderConvex_iff_ordConnected {α : Type*} [Preorder α] {s : Set α} :
    IsOrderConvex s ↔ s.OrdConnected := by
  constructor
  · intro h
    constructor
    intro x hx y hy z hz
    exact h hx hy hz.1 hz.2
  · intro h a b c ha hb hac hcb
    exact h.out ha hb ⟨hac, hcb⟩

theorem IsOrderConvex.ordConnected {α : Type*} [Preorder α] {s : Set α}
    (h : IsOrderConvex s) : s.OrdConnected :=
  isOrderConvex_iff_ordConnected.mp h

theorem Set.OrdConnected.isOrderConvex {α : Type*} [Preorder α] {s : Set α}
    (h : s.OrdConnected) : IsOrderConvex s :=
  isOrderConvex_iff_ordConnected.mpr h

theorem isOrderConvex_Icc {α : Type*} [Preorder α] (a b : α) :
    IsOrderConvex (Icc a b) := by
  intro x y z hx hy hxz hzy
  exact ⟨le_trans hx.1 hxz, le_trans hzy hy.2⟩

theorem isOrderConvex_Ioo {α : Type*} [Preorder α] (a b : α) :
    IsOrderConvex (Ioo a b) := by
  intro x y z hx hy hxz hzy
  exact ⟨lt_of_lt_of_le hx.1 hxz, lt_of_le_of_lt hzy hy.2⟩

theorem isOrderConvex_univ {α : Type*} [LE α] : IsOrderConvex (univ : Set α) :=
  fun _ _ _ _ _ _ _ => mem_univ _

/-! ## Preconnectedness from interval preconnectedness -/

/-
**Global preconnectedness from interval preconnectedness.**
In a linearly ordered type with order topology, dense ordering, and no endpoints,
if every closed interval `[a,b]` is preconnected, then the whole space is preconnected.
-/
theorem isPreconnected_univ_of_intervalPreconnected
    (α : Type*) [LinearOrder α] [TopologicalSpace α]
    [OrderTopology α] [DenselyOrdered α] [NoMinOrder α] [NoMaxOrder α]
    (hIcc : ∀ a b : α, IsPreconnected (Icc a b)) :
    IsPreconnected (univ : Set α) := by
  refine' isPreconnected_of_forall_pair _;
  intro x _ y _; cases le_total x y <;> [ exact ⟨ Set.Icc x y, Set.subset_univ _, Set.left_mem_Icc.mpr ‹_›, Set.right_mem_Icc.mpr ‹_›, hIcc _ _ ⟩ ; exact ⟨ Set.Icc y x, Set.subset_univ _, Set.right_mem_Icc.mpr ‹_›, Set.left_mem_Icc.mpr ‹_›, hIcc _ _ ⟩ ] ;

/-
**Connected space from interval preconnectedness.**
-/
theorem connectedSpace_of_intervalPreconnected
    (α : Type*) [LinearOrder α] [TopologicalSpace α]
    [OrderTopology α] [DenselyOrdered α] [NoMinOrder α] [NoMaxOrder α]
    [Nonempty α]
    (hIcc : ∀ a b : α, IsPreconnected (Icc a b)) :
    ConnectedSpace α := by
  refine' connectedSpace_iff_univ.mpr _;
  exact ⟨ Set.univ_nonempty, isPreconnected_univ_of_intervalPreconnected α hIcc ⟩

/-! ## Order-connected sets are connected -/

/-- A nonempty order-connected set in a conditionally complete, densely ordered linear order
with order topology is connected. -/
theorem ordConnected_isConnected_of_nonempty
    {α : Type*} [ConditionallyCompleteLinearOrder α] [TopologicalSpace α]
    [OrderTopology α] [DenselyOrdered α]
    {s : Set α} (hord : s.OrdConnected) (hne : s.Nonempty) :
    IsConnected s :=
  ⟨hne, hord.isPreconnected⟩

/-- Order-convex nonempty sets are connected. -/
theorem IsOrderConvex.isConnected
    {α : Type*} [ConditionallyCompleteLinearOrder α] [TopologicalSpace α]
    [OrderTopology α] [DenselyOrdered α]
    {s : Set α} (hs : IsOrderConvex s) (hne : s.Nonempty) :
    IsConnected s :=
  ordConnected_isConnected_of_nonempty hs.ordConnected hne

/-! ## The SurrealLikeLine class -/

/-- A `SurrealLikeLine` is a linearly ordered topological space with the order topology,
dense ordering, and no endpoints. These are the minimal axioms ensuring a
"continuous ordered world." -/
class SurrealLikeLine (α : Type*) extends LinearOrder α, TopologicalSpace α where
  orderTop : OrderTopology α
  denseOrd : DenselyOrdered α
  noMin : NoMinOrder α
  noMax : NoMaxOrder α

namespace SurrealLikeLine

variable {α : Type*} [SurrealLikeLine α]

instance : OrderTopology α := SurrealLikeLine.orderTop
instance : DenselyOrdered α := SurrealLikeLine.denseOrd
instance : NoMinOrder α := SurrealLikeLine.noMin
instance : NoMaxOrder α := SurrealLikeLine.noMax

end SurrealLikeLine

/-- A conditionally complete, densely ordered linear order with order topology,
no minimum, and no maximum is connected. This applies to any `SurrealLikeLine`
that is additionally conditionally complete. -/
theorem connectedSpace_of_conditionallyComplete_dense
    (α : Type*) [ConditionallyCompleteLinearOrder α] [TopologicalSpace α]
    [OrderTopology α] [DenselyOrdered α] [NoMinOrder α] [NoMaxOrder α] [Nonempty α] :
    ConnectedSpace α where
  toPreconnectedSpace := ⟨(@Set.ordConnected_univ α _).isPreconnected⟩
  toNonempty := ‹_›

/-! ## Uniqueness of the interval topology -/

/-
**Uniqueness of interval-generated topology.** On a linear order, there is at most one
topology for which the open intervals `(a,b)` form a topological basis.
-/
theorem interval_topology_unique
    (α : Type*) [LinearOrder α]
    (t₁ t₂ : TopologicalSpace α)
    (h₁ : @IsTopologicalBasis α t₁
      {s : Set α | ∃ a b : α, s = Ioo a b})
    (h₂ : @IsTopologicalBasis α t₂
      {s : Set α | ∃ a b : α, s = Ioo a b}) :
    t₁ = t₂ := by
  grind +splitIndPred

/-! ## Contractibility of intervals in ℝ -/

/-
**Contractibility of closed intervals in ℝ.**
-/
theorem icc_contractible (a b : ℝ) (hab : a ≤ b) :
    ContractibleSpace (Icc a b) := by
  convert Convex.contractibleSpace _ _;
  exacts [ inferInstance, inferInstance, inferInstance, inferInstance, convex_Icc a b, Set.nonempty_Icc.2 hab ]

/-! ## Computational Infrastructure -/

/-- Dyadic rationals of bounded denominator exponent `n`: rationals `k / 2^n`
for `|k| ≤ 2^n`. -/
def boundedDayDyadics (n : ℕ) : Finset ℚ :=
  (Finset.Icc (-(2^n : ℤ)) (2^n : ℤ)).image (fun (k : ℤ) => (k : ℚ) / (2 : ℚ)^n)

/-
Zero is a bounded-day dyadic.
-/
theorem zero_mem_boundedDayDyadics (n : ℕ) : (0 : ℚ) ∈ boundedDayDyadics n := by
  exact Finset.mem_image.mpr ⟨ 0, Finset.mem_Icc.mpr ⟨ by linarith [ pow_pos ( by decide : ( 2 : ) > 0 ) n ], by linarith [ pow_pos ( by decide : ( 2 : ℤ ) > 0 ) n ] ⟩, by norm_num ⟩

/-- Bounded-day dyadics are nonempty. -/
theorem boundedDayDyadics_nonempty (n : ℕ) : (boundedDayDyadics n).Nonempty :=
  ⟨0, zero_mem_boundedDayDyadics n⟩

/-
The bounded-day dyadics grow with `n`.
-/
theorem boundedDayDyadics_mono (n : ℕ) :
    (boundedDayDyadics n : Set ℚ) ⊆ (boundedDayDyadics (n + 1) : Set ℚ) := by
  intro x;
  simp_all +decide [ boundedDayDyadics ];
  rintro k hk₁ hk₂ rfl; use 2 * k; ring_nf at *; norm_cast at *;
  exact ⟨ ⟨ by push_cast at *; linarith, by push_cast at *; linarith ⟩, by push_cast; ring ⟩

/-- Contraction-to-zero steps by repeated halving. -/
def contractToZeroSteps (steps : ℕ) (q : ℚ) : List ℚ :=
  (List.range (steps + 1)).map (fun i => q / 2^i)

/-
The contraction steps start at the original value.
-/
theorem contractToZeroSteps_head (steps : ℕ) (q : ℚ) :
    (contractToZeroSteps steps q).head? = some q := by
  unfold contractToZeroSteps; simp +decide [ List.range_succ_eq_map ] ;

/-
The contraction steps end at `q / 2^steps`.
-/
theorem contractToZeroSteps_last (steps : ℕ) (q : ℚ) :
    (contractToZeroSteps steps q).getLast? = some (q / 2 ^ steps) := by
  unfold contractToZeroSteps;
  simp +decide [ List.range_succ ]

/-! ## Falsifiable Conjecture

**Conjecture (Countable Surreal Fragments are Totally Disconnected):**
Any countable densely ordered set with no endpoints, equipped with the order topology,
is homeomorphic to `ℚ` (by Sierpiński's theorem) and hence totally disconnected.
This implies genuine connectedness of a surreal-like continuum requires uncountable
completion.

**Test:** Compute connected components of finite dyadic approximant sets and verify
they are singletons. See `demo.py`.
-/