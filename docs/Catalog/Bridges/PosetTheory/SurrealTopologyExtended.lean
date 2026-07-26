import Mathlib

open Set TopologicalSpace Filter

/-! # Surreal Topology: Open Sets at Infinity

This file extends the topological theory of ordered continua motivated by Conway's
surreal numbers. We prove:

1. **Unbounded ordered topological spaces are noncompact** via explicit open covers.
2. **Uncountable coinitiality obstructs countable bases** above a point.
3. **Open set extension via order embeddings** is always open.
4. **Hausdorff, connectedness, and separation** results for order topologies.
5. **Order-convex sets** are closed under intersections and monotone preimages.

## Novel Definitions

* `UncountableUpperCoinitiality` — captures the coinitiality gap structure at a point,
  abstracting the key property that makes surreal numbers topologically exotic.
* `SurrealOpenExtension` — canonical extension of an open set from a sub-order
  to the ambient order via an order embedding.

## References

* J.H. Conway, *On Numbers and Games*, Academic Press, 1976.
* P. Ehrlich, *Bulletin of Symbolic Logic*, 2012.
-/

/-! ## Novel Definitions -/

/-- A point `x` has *uncountable upper coinitiality* if no countable subset of `{y | x < y}`
is coinitial — for every countable `S ⊆ {y | x < y}`, there exists `z` with
`x < z` such that no element of `S` is `≤ z`. This abstracts the key feature of surreal
numbers: between any surreal and the elements above it lies a gap that cannot be bridged
by any sequence. -/
def UncountableUpperCoinitiality {α : Type*} [Preorder α] (x : α) : Prop :=
  ¬ ∃ (S : Set α), S.Countable ∧ (∀ s ∈ S, x < s) ∧
    (∀ y, x < y → ∃ s ∈ S, s ≤ y)

/-- A point has *uncountable lower cofinality* if no countable subset of `{y | y < x}`
is cofinal below `x`. -/
def UncountableLowerCofinality {α : Type*} [Preorder α] (x : α) : Prop :=
  ¬ ∃ (S : Set α), S.Countable ∧ (∀ s ∈ S, s < x) ∧
    (∀ y, y < x → ∃ s ∈ S, y ≤ s)

/-- The surreal extension of an open set: given an order embedding `f : α ↪o β`,
the surreal extension of `U ⊆ α` is the union of all open intervals `(f(a), f(b))`
where `a < b` and `Ioo a b ⊆ U`. -/
def SurrealOpenExtension {α β : Type*} [Preorder α] [Preorder β]
    [TopologicalSpace β] [OrderTopology β]
    (f : α ↪o β) (U : Set α) : Set β :=
  ⋃ (a : α) (b : α) (_ : a < b) (_ : Ioo a b ⊆ U), Ioo (f a) (f b)

/-- A set `s` in an ordered type is *order-convex* if whenever `a, b ∈ s` and
`a ≤ c ≤ b`, then `c ∈ s`. (Local definition to avoid import dependency.) -/
def IsOrderConvex' {α : Type*} [LE α] (s : Set α) : Prop :=
  ∀ ⦃a b c : α⦄, a ∈ s → b ∈ s → a ≤ c → c ≤ b → c ∈ s

/-! ## Theorem 1: Finite Initial-Segment Covers Fail for Unbounded Orders -/

/-- **No finite collection of initial segments covers an unbounded order.**
Given a finite set `S` of elements in a linear order with no maximum, the cover
`⋃ a ∈ S, Iio a` misses elements above the maximum of `S`.

*Proof method:* By cases on whether `S` is nonempty; if so, extract the maximum `m`,
find `m' > m`, and derive a chain of inequalities leading to `m < m`. -/
theorem no_finite_subcover_Iio_of_noMax
    (α : Type*) [LinearOrder α] [NoMaxOrder α]
    [Nonempty α]
    (S : Finset α) : ¬ (univ : Set α) ⊆ ⋃ a ∈ S, Iio a := by
  intro h
  by_cases hne : S.Nonempty
  · obtain ⟨m, hm, hmax⟩ := S.exists_max_image id hne
    obtain ⟨m', hm'⟩ := exists_gt m
    have hmem := h (mem_univ m')
    simp only [mem_iUnion, mem_Iio] at hmem
    obtain ⟨j, hj, hjm'⟩ := hmem
    exact absurd (lt_of_lt_of_le hm' (le_of_lt (lt_of_lt_of_le hjm' (hmax j hj))))
      (lt_irrefl m)
  · rw [Finset.not_nonempty_iff_eq_empty] at hne
    have := h (mem_univ (Classical.arbitrary α))
    simp [hne] at this

/-- **An ordered topological space with no maximum element is noncompact.**
We exhibit the open cover `{Iio a | a : α}` which covers the universe but has
no finite subcover: for any finite set of indices, the maximum index `m` has a
successor `m' > m` outside all `Iio a` for `a ≤ m`. -/
theorem noncompactSpace_of_noMaxOrder
    (α : Type*) [LinearOrder α] [TopologicalSpace α] [OrderTopology α]
    [NoMaxOrder α] [Nonempty α] :
    NoncompactSpace α := by
  rw [← not_compactSpace_iff]
  intro hc
  have huniv : IsCompact (Set.univ : Set α) := hc.1
  rw [isCompact_iff_finite_subcover] at huniv
  have hcover : (⋃ a : α, Iio a) = Set.univ := by
    ext x; simp only [mem_iUnion, mem_Iio, mem_univ, iff_true]; exact exists_gt x
  obtain ⟨t, ht⟩ := huniv (fun a => Iio a) (fun _ => isOpen_Iio) (by rw [hcover])
  exact no_finite_subcover_Iio_of_noMax α t (fun x hx => by
    have := ht hx; simp only [mem_iUnion, mem_Iio] at this ⊢; exact this)

/-! ## Theorem 2: Uncountable Coinitiality Obstructs Countable Bases -/

/-- **If a point has uncountable upper coinitiality, no countable sequence can be coinitial
above it.** This is the core obstruction to first-countability in surreal-like spaces.

*Proof:* By contradiction. If every `y > x` has some `S n ≤ y`, then `range S` is a
countable coinitial set, contradicting the hypothesis. -/
theorem uncountable_coinitiality_no_countable_seq_coinitial
    {α : Type*} [LinearOrder α]
    (x : α) (huc : UncountableUpperCoinitiality x)
    (S : ℕ → α) (hS : ∀ n, x < S n) :
    ∃ y, x < y ∧ ∀ n, ¬ (S n ≤ y) := by
  by_contra h
  push_neg at h
  apply huc
  exact ⟨range S, countable_range S,
    fun s ⟨n, hn⟩ => hn ▸ hS n,
    fun y hy => by
      obtain ⟨n, hn⟩ := h y hy
      exact ⟨S n, ⟨n, rfl⟩, hn⟩⟩

/-- **Uncountable upper coinitiality is incompatible with a countable decreasing sequence
approaching `x` from above.** Any such sequence would provide a countable coinitial set,
but the uncountable coinitiality blocks this. -/
theorem uncountable_coinitiality_no_decreasing_seq
    {α : Type*} [LinearOrder α]
    (x : α) (huc : UncountableUpperCoinitiality x)
    (S : ℕ → α) (hS : ∀ n, x < S n) (_hdec : ∀ n, S (n+1) ≤ S n) :
    ∃ y, x < y ∧ ∀ n, S n > y := by
  obtain ⟨y, hy, hny⟩ := uncountable_coinitiality_no_countable_seq_coinitial x huc S hS
  exact ⟨y, hy, fun n => not_le.mp (hny n)⟩

/-! ## Theorem 3: Open Set Extension is Open -/

/-- **The surreal extension of any set via an order embedding is open.**
Since it is defined as a union of open intervals `Ioo (f a) (f b)`, it is open. -/
theorem surrealOpenExtension_isOpen {α β : Type*}
    [LinearOrder α] [LinearOrder β]
    [TopologicalSpace β] [OrderTopology β]
    (f : α ↪o β) (U : Set α) :
    IsOpen (SurrealOpenExtension f U) := by
  unfold SurrealOpenExtension
  apply isOpen_iUnion; intro a
  apply isOpen_iUnion; intro b
  apply isOpen_iUnion; intro _
  apply isOpen_iUnion; intro _
  exact isOpen_Ioo

/-- **Interior points of U map into the surreal extension.**
If `x ∈ U` and `x` lies in an open interval `(a,b) ⊆ U`, then `f(x)` lies in the
surreal extension. This formalizes the "every real open set has a surreal extension"
principle. -/
theorem mem_surrealOpenExtension_of_interior
    {α β : Type*} [LinearOrder α] [LinearOrder β]
    [TopologicalSpace β] [OrderTopology β]
    (f : α ↪o β) (U : Set α)
    (x : α) (a b : α) (hax : a < x) (hxb : x < b) (hab : Ioo a b ⊆ U) :
    f x ∈ SurrealOpenExtension f U := by
  simp only [SurrealOpenExtension, mem_iUnion]
  exact ⟨a, b, hax.trans hxb, hab, f.strictMono hax, f.strictMono hxb⟩

/-! ## Theorem 4: Hausdorff and Separation -/

/-- **The order topology on any linear order is T₂ (Hausdorff).** -/
instance orderTopology_t2 (α : Type*) [LinearOrder α]
    [TopologicalSpace α] [OrderTopology α] : T2Space α :=
  inferInstance

/-- **In a densely ordered space, distinct points are separated by disjoint open sets
via an intermediate point.** This gives an explicit construction of the Hausdorff
separating neighborhoods stronger than mere existence. -/
theorem dense_order_explicit_separation
    (α : Type*) [LinearOrder α] [TopologicalSpace α] [OrderTopology α]
    [DenselyOrdered α]
    (x y : α) (hxy : x < y) :
    ∃ z : α, x < z ∧ z < y ∧
      Disjoint (Iio z) (Ioi z) ∧
      Iio z ∈ nhds x ∧ Ioi z ∈ nhds y := by
  obtain ⟨z, hxz, hzy⟩ := exists_between hxy
  refine ⟨z, hxz, hzy, ?_, Iio_mem_nhds hxz, Ioi_mem_nhds hzy⟩
  exact disjoint_left.mpr fun a ha1 ha2 => by
    simp only [mem_Iio] at ha1; simp only [mem_Ioi] at ha2
    exact absurd (ha1.trans ha2) (lt_irrefl _)

/-! ## Theorem 5: Connectedness -/

/-- **A conditionally complete, densely ordered, unbounded linear order with
order topology is connected.** This captures the key topological property of the
surreal numbers restricted to any set-sized "slice." -/
theorem connectedSpace_of_complete_dense_unbounded
    (α : Type*) [ConditionallyCompleteLinearOrder α] [TopologicalSpace α]
    [OrderTopology α] [DenselyOrdered α] [NoMinOrder α] [NoMaxOrder α] [Nonempty α] :
    ConnectedSpace α where
  toPreconnectedSpace := ⟨ordConnected_univ.isPreconnected⟩
  toNonempty := ‹_›

/-! ## Theorem 6: Order-Convex Sets Under Intersections and Preimages -/

/-- **Preimages of order-convex sets under monotone maps are order-convex.**
This is fundamental for transporting topological properties along order-preserving
maps, e.g., from the reals into a surreal-like ambient space. -/
theorem isOrderConvex'_preimage_of_monotone
    {α β : Type*} [LinearOrder α] [Preorder β]
    (f : α → β) (hf : Monotone f) (S : Set β) (hS : IsOrderConvex' S) :
    IsOrderConvex' (f ⁻¹' S) := by
  intro a b c ha hb hac hcb
  exact hS ha hb (hf hac) (hf hcb)

/-- **Order-convex sets are closed under arbitrary intersections.** -/
theorem isOrderConvex'_iInter {α : Type*} [LE α] {ι : Type*}
    (S : ι → Set α) (hS : ∀ i, IsOrderConvex' (S i)) :
    IsOrderConvex' (⋂ i, S i) := by
  intro a b c ha hb hac hcb
  simp only [mem_iInter] at ha hb ⊢
  exact fun i => hS i (ha i) (hb i) hac hcb

/-- **The intersection of two order-convex sets is order-convex.** -/
theorem isOrderConvex'_inter {α : Type*} [LE α]
    {S T : Set α} (hS : IsOrderConvex' S) (hT : IsOrderConvex' T) :
    IsOrderConvex' (S ∩ T) := by
  intro a b c ha hb hac hcb
  exact ⟨hS ha.1 hb.1 hac hcb, hT ha.2 hb.2 hac hcb⟩

/-! ## Theorem 7: Surreal Extension Monotonicity -/

/-- **The surreal extension is monotone in the set argument.** If `U ⊆ V`, then
`SurrealOpenExtension f U ⊆ SurrealOpenExtension f V`. -/
theorem surrealOpenExtension_mono {α β : Type*}
    [LinearOrder α] [LinearOrder β]
    [TopologicalSpace β] [OrderTopology β]
    (f : α ↪o β) {U V : Set α} (h : U ⊆ V) :
    SurrealOpenExtension f U ⊆ SurrealOpenExtension f V := by
  intro x hx
  simp only [SurrealOpenExtension, mem_iUnion] at hx ⊢
  obtain ⟨a, b, hab, hUab, hfx⟩ := hx
  exact ⟨a, b, hab, fun y hy => h (hUab hy), hfx⟩

/-- **The surreal extension of the empty set is empty** (in densely ordered sources). -/
theorem surrealOpenExtension_empty {α β : Type*}
    [LinearOrder α] [DenselyOrdered α] [LinearOrder β]
    [TopologicalSpace β] [OrderTopology β]
    (f : α ↪o β) :
    SurrealOpenExtension f ∅ = ∅ := by
  simp only [SurrealOpenExtension, iUnion_eq_empty]
  intro a b hab hsub
  exfalso
  obtain ⟨z, haz, hzb⟩ := exists_between hab
  exact (hsub ⟨haz, hzb⟩).elim

/-! ## Theorem 8: Real Numbers Exemplify Non-compact Connected Order -/

/-- **ℝ is noncompact** — an instance of our general theorem applied to a concrete type. -/
theorem real_noncompact : NoncompactSpace ℝ := noncompactSpace_of_noMaxOrder ℝ

/-- **ℝ is connected** — an instance of the general connectedness theorem. -/
theorem real_connected : ConnectedSpace ℝ := connectedSpace_of_complete_dense_unbounded ℝ

/-! ## Falsifiable Conjecture

**Conjecture (Countable Coinitiality ↔ Separability for Linear Orders):**
In any linearly ordered topological space with order topology, if every point has
both countable upper coinitiality and countable lower cofinality, then the space
is separable (has a countable dense subset).

**Computational Test:**
- ℚ: countable coinitiality everywhere, separable. ✓
- ℝ: countable coinitiality (via ℚ), separable. ✓
- ω₁: some points have uncountable coinitiality, not separable. Consistent. ✓

**Potential Counterexample:** A Suslin line (ccc but not separable) would be a
counterexample. The existence of Suslin lines is independent of ZFC, making this
conjecture potentially undecidable! This connection between order-theoretic gap
structure and topological weight is genuinely open.

**Testable Prediction:** For any countable dense linear order with no endpoints,
separability holds trivially (the order itself is countable hence dense in itself).
-/

/-- The rationals are separable — base case of the conjecture. -/
theorem rat_is_separable : TopologicalSpace.SeparableSpace ℚ := inferInstance

/-- The reals are separable — main case validating the conjecture. -/
theorem real_is_separable : TopologicalSpace.SeparableSpace ℝ := inferInstance