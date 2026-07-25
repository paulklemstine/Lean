import Mathlib

set_option autoImplicit false
set_option maxHeartbeats 800000

open Set TopologicalSpace Filter

/-! # Surreal Topology: Open Sets at Infinity

This file develops the topological theory of surreal-like ordered spaces,
focusing on properties distinguishing Conway's surreal numbers from the reals:
failure of first-countability due to uncountable cofinality, open set extension
from dense suborders, and compactness/metrizability obstructions.

Since the surreal numbers form a proper class, we axiomatize their key
properties and prove structural theorems applicable to any linearly ordered
space exhibiting surreal-like behavior.

## Main Definitions

* `HasUncountableCofinalityAbove` — the right cofinality at a point is uncountable.
* `HasUncountableCoinitialityBelow` — the left coinitiality at a point is uncountable.
* `SurrealLikeOrder` — ordered space with uncountable cofinality points.
* `openSetExtension` — extending open sets from a dense suborder.

## Main Results

* `uncountable_cofinality_above_no_countable_cofinal` — no countable cofinal
  sequence exists at uncountable cofinality points.
* `not_countablyGenerated_nhds_of_uncountable_cofinality` — uncountable cofinality
  implies the neighborhood filter is not countably generated.
* `not_firstCountable_of_uncountable_cofinality` — such spaces fail first-countability.
* `openSetExtension_isOpen` — extensions of open sets remain open.
* `not_compactSpace_of_noMaxOrder` — unbounded ordered spaces are non-compact.
* `not_metrizableSpace_of_uncountable_cofinality` — non-metrizability from cofinality.

## References

* J.H. Conway, *On Numbers and Games*, Academic Press, 1976.
* N.L. Alling, *Foundations of Analysis over Surreal Number Fields*, 1987.
-/

/-! ## Part I: Uncountable Cofinality Definitions -/

/-- A point `x` has **uncountable cofinality from above** if for every countable
sequence `f : ℕ → α` with `x < f n`, there exists `y` strictly between `x` and
all `f n`. This means no countable set is cofinal in the approach to `x` from
the right — the order-theoretic hallmark of surreal number gaps.

In the surreal numbers, the element ω = {0,1,2,... | } has this property:
any countable sequence ω + 1/n, ω + 1, ... above ω admits a surreal number
strictly between ω and all terms. -/
def HasUncountableCofinalityAbove {α : Type*} [Preorder α] (x : α) : Prop :=
  ∀ (f : ℕ → α), (∀ n, x < f n) → ∃ y, x < y ∧ ∀ n, y < f n

/-- A point `x` has **uncountable coinitiality from below** if for every countable
sequence approaching from below, a strict lower bound exists between `x` and all
terms of the sequence. -/
def HasUncountableCoinitialityBelow {α : Type*} [Preorder α] (x : α) : Prop :=
  ∀ (f : ℕ → α), (∀ n, f n < x) → ∃ y, y < x ∧ ∀ n, f n < y

/-! ## Part II: No Countable Cofinal Sequences -/

/-
At a point with uncountable cofinality from above, no countable sequence
`{f n}` with `x < f n` is cofinal in `Ioi x` — there always exists `y > x`
strictly below all `f n`.
-/
theorem uncountable_cofinality_above_no_countable_cofinal
    {α : Type*} [LinearOrder α] (x : α)
    (hcof : HasUncountableCofinalityAbove x) :
    ¬ ∃ (f : ℕ → α), (∀ n, x < f n) ∧ (∀ y, x < y → ∃ n, f n ≤ y) := by
  exact fun ⟨ f, hf1, hf2 ⟩ ↦ by obtain ⟨ y, hy1, hy2 ⟩ := hcof f ( by tauto ) ; obtain ⟨ n, hn ⟩ := hf2 y ( by tauto ) ; exact lt_irrefl _ ( lt_of_le_of_lt hn ( hy2 _ ) ) ;

/-! ## Part III: Failure of First-Countability -/

/-
**Key lemma**: If `nhds x` is countably generated in an order topology
and `x` has elements above it, then there exists a countable sequence
cofinal from the right. This is the contrapositive of the main theorem.
-/
theorem countablyGenerated_gives_cofinal_seq
    {α : Type*} [LinearOrder α] [TopologicalSpace α] [OrderTopology α]
    (x : α) (hcg : (nhds x).IsCountablyGenerated)
    (hright : ∃ z, x < z) :
    ∃ (f : ℕ → α), (∀ n, x < f n) ∧ (∀ y, x < y → ∃ n, f n ≤ y) := by
  obtain ⟨f, hf⟩ : ∃ f : ℕ → Set α, (∀ n, f n ∈ nhds x) ∧ ∀ U ∈ nhds x, ∃ n, f n ⊆ U := by
    have := hcg;
    obtain ⟨ f, hf ⟩ := this;
    have := hf.1.exists_eq_range;
    by_cases hf_empty : f.Nonempty;
    · obtain ⟨ g, rfl ⟩ := this hf_empty;
      refine' ⟨ fun n => ⋂ i ≤ n, g i, _, _ ⟩ <;> simp_all +decide [ Set.subset_def ];
      · intro n;
        refine' Filter.mem_of_superset ( Filter.biInter_mem ( Set.finite_le_nat n ) |>.2 fun i hi => Filter.mem_generate_of_mem ( Set.mem_range_self i ) ) _;
        simp +decide;
      · intro U hU;
        induction hU;
        · aesop;
        · exact ⟨ 0, fun _ _ => Set.mem_univ _ ⟩;
        · aesop;
        · case _ hs ht => obtain ⟨ n, hn ⟩ := hs; obtain ⟨ m, hm ⟩ := ht; exact ⟨ Max.max n m, fun x hx => ⟨ hn x fun i hi => hx i ( le_trans hi ( le_max_left _ _ ) ), hm x fun i hi => hx i ( le_trans hi ( le_max_right _ _ ) ) ⟩ ⟩ ;
    · simp_all +decide [ Set.not_nonempty_iff_eq_empty.mp hf_empty ];
      simp_all +decide [ Filter.generate_empty ];
      exact ⟨ fun _ => Set.univ, fun _ => rfl ⟩;
  -- For each $n$, since $f_n$ is a neighborhood of $x$, there exists $y_n > x$ such that $(x, y_n) \subseteq f_n$.
  obtain ⟨y, hy⟩ : ∃ y : ℕ → α, (∀ n, x < y n ∧ ∀ z, x < z ∧ z < y n → z ∈ f n) := by
    have hy : ∀ n, ∃ y, x < y ∧ ∀ z, x < z ∧ z < y → z ∈ f n := by
      intro n
      have h_nhds : f n ∈ nhds x := hf.left n
      rcases mem_nhds_iff.mp h_nhds with ⟨ U, hUo, hxU, hU ⟩;
      rcases exists_Ico_subset_of_mem_nhds ( hxU.mem_nhds hU ) hright with ⟨ y, hy₁, hy₂ ⟩;
      exact ⟨ y, hy₁, fun z hz => hUo ( hy₂ ⟨ hz.1.le, hz.2 ⟩ ) ⟩;
    exact ⟨ fun n => Classical.choose ( hy n ), fun n => Classical.choose_spec ( hy n ) ⟩;
  refine' ⟨ y, fun n => ( hy n ).1, fun z hz => _ ⟩;
  contrapose! hf;
  refine' fun h => ⟨ Set.Iio z, Iio_mem_nhds hz, fun n hn => _ ⟩;
  exact absurd ( hn ( hy n |>.2 ( z ) ⟨ hz, hf n ⟩ ) ) ( by simp +decide )

/-
**Main Theorem**: At a point with uncountable cofinality from above in a
linear order with order topology, the neighborhood filter is not countably
generated.
-/
theorem not_countablyGenerated_nhds_of_uncountable_cofinality
    {α : Type*} [LinearOrder α] [TopologicalSpace α] [OrderTopology α]
    (x : α) (hcof : HasUncountableCofinalityAbove x)
    (hright : ∃ z, x < z) :
    ¬ (nhds x).IsCountablyGenerated := by
  exact fun h => uncountable_cofinality_above_no_countable_cofinal x hcof ( countablyGenerated_gives_cofinal_seq x h hright )

/-
A linearly ordered topological space with a point of uncountable cofinality
from above is not first-countable.
-/
theorem not_firstCountable_of_uncountable_cofinality
    {α : Type*} [LinearOrder α] [TopologicalSpace α] [OrderTopology α]
    (x : α) (hcof : HasUncountableCofinalityAbove x)
    (hright : ∃ z, x < z) :
    ¬ FirstCountableTopology α := by
  exact fun h => not_countablyGenerated_nhds_of_uncountable_cofinality x hcof hright <| inferInstance

/-! ## Part IV: Surreal-Like Order -/

/-- A **surreal-like order** axiomatizes the key topological properties of
Conway's surreal number field: a linearly ordered space with order topology,
dense ordering, no endpoints, and at least one point with uncountable cofinality
from above.

The existence of such a point is what distinguishes surreal topology from
real analysis — it is the source of all pathological behavior. -/
class SurrealLikeOrder (α : Type*) extends LinearOrder α, TopologicalSpace α where
  orderTop : OrderTopology α
  denseOrd : DenselyOrdered α
  noMin : NoMinOrder α
  noMax : NoMaxOrder α
  exists_uncountable_cofinality : ∃ x : α, HasUncountableCofinalityAbove x

namespace SurrealLikeOrder
variable {α : Type*} [SurrealLikeOrder α]

instance : OrderTopology α := SurrealLikeOrder.orderTop
instance : DenselyOrdered α := SurrealLikeOrder.denseOrd
instance : NoMinOrder α := SurrealLikeOrder.noMin
instance : NoMaxOrder α := SurrealLikeOrder.noMax

/-
A surreal-like order is never first-countable.
-/
theorem not_firstCountableTopology : ¬ FirstCountableTopology α := by
  cases' ‹SurrealLikeOrder α› with α';
  rename_i h₁ h₂ h₃ h₄ h₅ h₆;
  exact not_firstCountable_of_uncountable_cofinality _ h₆.choose_spec ( h₅.exists_gt _ )

/-
A surreal-like order is non-compact.
-/
theorem not_compactSpace : ¬ CompactSpace α := by
  cases' ‹SurrealLikeOrder α› with _ _ _ _ h;
  obtain ⟨ x, hx ⟩ := ‹∃ x : α, HasUncountableCofinalityAbove x›;
  contrapose! hx;
  obtain ⟨ y, hy ⟩ := ‹CompactSpace α›.isCompact_univ.exists_isGreatest ( Set.nonempty_of_mem <| Set.mem_univ x );
  exact False.elim ( ‹NoMaxOrder α›.exists_gt y |> fun ⟨ z, hz ⟩ => hz.not_ge ( hy.2 trivial ) )

/-
A surreal-like order is not metrizable.
-/
theorem not_metrizableSpace : ¬ MetrizableSpace α := by
  by_contra m;
  obtain ⟨ x, hx ⟩ := ‹SurrealLikeOrder α›.exists_uncountable_cofinality;
  rename_i h;
  cases h;
  rename_i h₁ h₂ h₃ h₄ h₅ h₆;
  exact not_countablyGenerated_nhds_of_uncountable_cofinality x hx ( h₅.exists_gt x ) ( by infer_instance )

end SurrealLikeOrder

/-! ## Part V: Open Set Extension -/

/-- The **open set extension** of a set `U ⊆ α` through an order embedding
`ι : α ↪o β` is the union of all open intervals `(ι a, ι b)` in `β` where
the corresponding interval `(a, b)` in `α` is contained in `U`. This
construction extends real open sets to surreal-like ambient spaces. -/
def openSetExtension {α β : Type*} [LinearOrder α] [LinearOrder β]
    (ι : α ↪o β) (U : Set α) : Set β :=
  ⋃ (p : α × α) (_ : p.1 < p.2) (_ : Ioo p.1 p.2 ⊆ U), Ioo (ι p.1) (ι p.2)

/-
The open set extension is always open in the order topology on `β`.
-/
theorem openSetExtension_isOpen {α β : Type*} [LinearOrder α] [LinearOrder β]
    [TopologicalSpace β] [OrderTopology β]
    (ι : α ↪o β) (U : Set α) :
    IsOpen (openSetExtension ι U) := by
  refine isOpen_iUnion fun p => isOpen_iUnion fun hp => isOpen_iUnion fun hpU => ?_;
  exact isOpen_Ioo

/-
For an order embedding, the open set extension of the universal set
covers the interior of the range.
-/
theorem openSetExtension_univ_covers {α β : Type*} [LinearOrder α] [LinearOrder β]
    (ι : α ↪o β) (a b : α) (hab : a < b) (y : β)
    (hay : ι a < y) (hyb : y < ι b) :
    y ∈ openSetExtension ι (univ : Set α) := by
  exact Set.mem_iUnion₂.2 ⟨ ⟨ a, b ⟩, hab, by aesop ⟩

/-! ## Part VI: Non-Compactness -/

/-
An ordered space with no maximum element is non-compact: the open cover
`{Iio a | a : α}` has no finite subcover.
-/
theorem not_compactSpace_of_noMaxOrder
    (α : Type*) [LinearOrder α] [TopologicalSpace α] [OrderTopology α]
    [NoMaxOrder α] [Nonempty α] :
    ¬ CompactSpace α := by
  intro h_compact;
  convert h_compact.isCompact_univ.exists_isGreatest;
  simp +decide [ IsGreatest ]

/-! ## Part VII: Non-Metrizability -/

/-
**Non-metrizability**: A linearly ordered space with order topology and
a point of uncountable cofinality from above is not metrizable.

Every metrizable space is first-countable, but uncountable cofinality
prevents first-countability.
-/
theorem not_metrizableSpace_of_uncountable_cofinality
    {α : Type*} [LinearOrder α] [TopologicalSpace α] [OrderTopology α]
    (x : α) (hcof : HasUncountableCofinalityAbove x)
    (hright : ∃ z, x < z) :
    ¬ MetrizableSpace α := by
  intro h;
  convert not_firstCountable_of_uncountable_cofinality x hcof hright;
  constructor <;> intro <;> cases h <;> tauto

/-! ## Part VIII: Connectedness from Conditional Completeness -/

/-
A conditionally complete linear order with order topology, dense ordering,
and no endpoints is connected. Surreal-like spaces CAN be connected — their
pathology is about countability, not connectedness.
-/
theorem connectedSpace_of_conditionallyComplete_noEndpoints
    (α : Type*) [ConditionallyCompleteLinearOrder α] [TopologicalSpace α]
    [OrderTopology α] [DenselyOrdered α] [NoMinOrder α] [NoMaxOrder α]
    [Nonempty α] :
    ConnectedSpace α := by
  refine' connectedSpace_iff_univ.mpr _;
  refine' ⟨ Set.univ_nonempty, _ ⟩;
  exact isPreconnected_univ

/-! ## Part IX: Cofinality Duality -/

/-
**Duality**: Uncountable cofinality from above at `x` in `α` is equivalent
to uncountable coinitiality from below at `x` when viewed in the dual order.
-/
theorem uncountable_cofinality_dual {α : Type*} [Preorder α] (x : α) :
    @HasUncountableCofinalityAbove αᵒᵈ _ x ↔ HasUncountableCoinitialityBelow x := by
  constructor;
  · finiteness;
  · intro h f hf;
    convert h ( fun n => f n ) ( fun n => hf n ) using 1

/-! ## Part X: The Order Topology is T₂ -/

/-
In any linear order with order topology, the space is T₂ (Hausdorff).
-/
theorem t2Space_orderTopology
    (α : Type*) [LinearOrder α] [TopologicalSpace α] [OrderTopology α] :
    T2Space α := by
  refine' ⟨ fun { x y } hxy => _ ⟩;
  cases' lt_or_gt_of_ne hxy with h h;
  · by_cases hxy' : ∃ z, x < z ∧ z < y;
    · obtain ⟨ z, hxz, hzy ⟩ := hxy';
      refine' ⟨ Set.Iio z, Set.Ioi z, isOpen_Iio, isOpen_Ioi, hxz, hzy, _ ⟩;
      exact Set.disjoint_left.mpr fun x hx₁ hx₂ => lt_asymm hx₁.out hx₂.out;
    · refine' ⟨ Set.Iio y, Set.Ioi x, isOpen_Iio, isOpen_Ioi, _, _, _ ⟩ <;> simp_all +decide [ Set.disjoint_iff_inter_eq_empty, Set.Iio_inter_Ioi ];
      exact Set.eq_empty_of_forall_notMem fun z hz => not_lt_of_ge ( hxy' z hz.1 ) hz.2;
  · by_cases hxy' : ∃ z, y < z ∧ z < x;
    · obtain ⟨ z, hyz, hzx ⟩ := hxy';
      refine' ⟨ Set.Ioi z, Set.Iio z, isOpen_Ioi, isOpen_Iio, _, _, _ ⟩ <;> simp +decide [ * ];
    · refine' ⟨ Set.Ioi y, Set.Iio x, isOpen_Ioi, isOpen_Iio, _, _, _ ⟩ <;> simp_all +decide [ Set.disjoint_left ]

/-! ## Falsifiable Conjecture

**Conjecture (Surreal Paracompactness Obstruction):**
Any linearly ordered topological space with order topology containing a point
of uncountable cofinality from above is NOT paracompact.

**Testable prediction:** The long line `ω₁ × [0,1)` with lexicographic order
has uncountable cofinality at limit ordinal points and is not paracompact.

**Computational test:** For finite ordinal approximations `n × [0,1)`, measure
the minimum cardinality of locally finite refinements. If this grows super-linearly,
it suggests the infinite case diverges.
-/