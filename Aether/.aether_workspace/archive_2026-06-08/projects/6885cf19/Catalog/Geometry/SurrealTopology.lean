/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Foundational Topological Theory of Surreal-Like Ordered Spaces

This module develops the theory of **cofinality spectra** for linearly ordered
topological spaces, establishing that uncountable cofinality is the precise
order-theoretic obstruction to first-countability in the order topology.

## Main Definitions

* `SurrealTopology.HasCountableLeftCof` — a point x has countable left
  cofinality if there is a sequence cofinal below x
* `SurrealTopology.HasCountableRightCof` — dual notion for right cofinality
* `SurrealTopology.OrderGap` — a Dedekind cut (L, R) with no realizing element
* `SurrealTopology.CofinalityClass` — classification of points as tame or wild

## Main Results

* `SurrealTopology.orderGap_clopen_lower` — the lower set of an order gap is clopen
* `SurrealTopology.orderGap_not_preconnected` — order gaps obstruct connectedness
* `SurrealTopology.first_countable_implies_tame` — first-countability forces
  countable cofinality from both sides
* `SurrealTopology.tame_implies_countably_generated_nhds` — countable cofinality
  from both sides yields countably generated neighborhood filter

## Mathematical Context

In surreal-like ordered spaces, many points have uncountable cofinality: no
countable sequence converges to them from below. This module shows this single
order-theoretic property is responsible for all topological pathology.
The **cofinality spectrum** partitions any linearly ordered space into "tame"
(behaving like ℝ) and "wild" (exhibiting surreal pathology) points.
-/

open Set Filter Topology

namespace SurrealTopology

variable {α : Type*}

/-! ## Cofinality Definitions -/

/-- A point `x` has **countable left cofinality** if there exists a sequence
`S : ℕ → α` cofinal in `Iio x`. The hypothesis guard ensures this is
only a nontrivial condition when `Iio x` is nonempty. -/
def HasCountableLeftCof [Preorder α] (x : α) : Prop :=
  (∃ a, a < x) →
  ∃ S : ℕ → α, (∀ n, S n < x) ∧ ∀ y, y < x → ∃ n, y ≤ S n

/-- A point `x` has **countable right cofinality** if there exists a sequence
coinitial in `Ioi x`. -/
def HasCountableRightCof [Preorder α] (x : α) : Prop :=
  (∃ b, x < b) →
  ∃ S : ℕ → α, (∀ n, x < S n) ∧ ∀ y, x < y → ∃ n, S n ≤ y

/-- A point is **tame** if it has countable cofinality from both sides. -/
def IsTame [Preorder α] (x : α) : Prop :=
  HasCountableLeftCof x ∧ HasCountableRightCof x

/-- A point is **wild** if it lacks countable cofinality from at least one side. -/
def IsWild [Preorder α] (x : α) : Prop := ¬IsTame x

/-! ## Order Gaps -/

/-- An **order gap** is an initial segment with no maximum whose complement
has no minimum — a "hole" in the order, like a Dedekind cut with no fill. -/
structure OrderGap (α : Type*) [LinearOrder α] where
  lower : Set α
  lower_nonempty : lower.Nonempty
  upper_nonempty : lowerᶜ.Nonempty
  lower_initial : ∀ x y, x ∈ lower → y ≤ x → y ∈ lower
  lower_lt_upper : ∀ x ∈ lower, ∀ y ∈ lowerᶜ, x < y
  no_max : ∀ x ∈ lower, ∃ y ∈ lower, x < y
  no_min : ∀ x ∈ lowerᶜ, ∃ y ∈ lowerᶜ, y < x

/-! ## Cofinality Spectrum Classification -/

/-- Classification of a point by its cofinality type. -/
inductive CofinalityClass where
  | tame      -- countable cofinality from both sides
  | wildLeft  -- uncountable from below
  | wildRight -- uncountable from above
  | wildBoth  -- uncountable from both sides
  deriving DecidableEq, Repr

/-- The tame locus of a linear order: all points with countable cofinality. -/
def tameLocus [Preorder α] : Set α := {x | IsTame x}

/-- The wild locus: complement of tame locus. -/
def wildLocus [Preorder α] : Set α := {x | IsWild x}

/-! ## Basic Cofinality Properties -/

section BasicCof

variable [LinearOrder α]

/-- A minimum element trivially has countable left cofinality. -/
theorem hasCountableLeftCof_of_isBot {x : α} (hx : IsBot x) :
    HasCountableLeftCof x := by
  intro ⟨a, ha⟩
  exact absurd ha (not_lt.mpr (hx a))

/-- A maximum element trivially has countable right cofinality. -/
theorem hasCountableRightCof_of_isTop {x : α} (hx : IsTop x) :
    HasCountableRightCof x := by
  intro ⟨b, hb⟩
  exact absurd hb (not_lt.mpr (hx b))

/-
If there is a predecessor element covering x, then x has countable left cofinality.
-/
theorem hasCountableLeftCof_of_pred {x y : α} (hyx : y < x)
    (hcov : ∀ z, y < z → x ≤ z) : HasCountableLeftCof x := by
  refine' fun ⟨ z, hz ⟩ => ⟨ fun _ => y, fun n => by aesop, fun w hw => by contrapose! hw; aesop ⟩

end BasicCof

/-! ## Order Gap Topology -/

section GapTopology

variable [LinearOrder α] [TopologicalSpace α] [OrderTopology α]

/-
The lower set of an order gap is open: since it has no maximum,
every point has room above it within the lower set.
-/
theorem orderGap_lower_isOpen (G : OrderGap α) : IsOpen G.lower := by
  rw [ isOpen_iff_mem_nhds ] ; intro x hx ; exact (by
  obtain ⟨ y, hy₁, hy₂ ⟩ := G.no_max x hx;
  filter_upwards [ Iio_mem_nhds hy₂ ] with z hz using G.lower_initial _ _ hy₁ hz.out.le);

/-
The upper set (complement of lower) of an order gap is open:
since it has no minimum, every point has room below it within the upper set.
-/
theorem orderGap_upper_isOpen (G : OrderGap α) : IsOpen G.lowerᶜ := by
  refine' isOpen_iff_forall_mem_open.mpr _;
  intro x hx; cases' G.no_min x hx with y hy; use Set.Ioi y; simp_all +decide [ Set.subset_def ] ;
  exact ⟨ fun z hz hz' => hy.1 <| G.lower_lt_upper _ hz' _ hy.1 |> fun h => by exact absurd h ( not_lt_of_gt hz ), isOpen_Ioi ⟩

/-- **The lower set of an order gap is clopen.** -/
theorem orderGap_clopen_lower (G : OrderGap α) : IsClopen G.lower :=
  ⟨isOpen_compl_iff.mp (orderGap_upper_isOpen G), orderGap_lower_isOpen G⟩

/-
**Order Gap Disconnection Theorem**: A linearly ordered topological space
with an order gap cannot be preconnected. The gap provides a nontrivial
clopen partition, which is the topological signature of disconnectedness.

This result establishes that order-completeness (Dedekind completeness)
is necessary for connectedness in ordered spaces.
-/
theorem orderGap_not_preconnected (G : OrderGap α) :
    ¬IsPreconnected (univ : Set α) := by
  simp +decide [ IsPreconnected ];
  refine' ⟨ G.lower, orderGap_lower_isOpen G, G.lowerᶜ, orderGap_upper_isOpen G, _, _, _, _ ⟩;
  · exact Set.union_compl_self _;
  · exact G.lower_nonempty;
  · exact G.upper_nonempty;
  · simp +decide [ Set.Nonempty ]

/-
A connected ordered space has no gaps.
-/
theorem no_gap_of_connected [ConnectedSpace α] : IsEmpty (OrderGap α) := by
  exact ⟨ fun G => orderGap_not_preconnected G <| isPreconnected_univ ⟩

end GapTopology

/-! ## Wild Points and Countable Intersections -/

section WildPoints

variable [LinearOrder α] [TopologicalSpace α] [OrderTopology α]

/-
**Key Lemma**: In the order topology, any open neighborhood of a non-minimal
point `x` contains an open interval reaching below `x`.
-/
theorem exists_Ioo_subset_of_mem_nhds {x : α} {U : Set α}
    (hU : U ∈ nhds x) (hne : ∃ a, a < x) :
    ∃ b, b < x ∧ Ioo b x ⊆ U := by
  obtain ⟨l, hl⟩ : ∃ l < x, Set.Ioc l x ⊆ U := by
    exact exists_Ioc_subset_of_mem_nhds hU hne
  use l, hl.left, by
    exact Set.Subset.trans ( Set.Ioo_subset_Ioc_self ) hl.2

/-
**Countable Intersection for Uncountable Left Cofinality**: If `x` has
uncountable left cofinality, any countable family of neighborhoods shares
a common left-interval. This is the P-filter property from the left.

The proof: each neighborhood contains an interval (aₙ, x). Since `{aₙ}`
is countable and not cofinal below x, all aₙ are bounded by some b < x.
Then (b, x) lies in every neighborhood.
-/
theorem wild_left_countable_inter_nhds
    {x : α} (hx : ¬HasCountableLeftCof x)
    {U : ℕ → Set α} (hU : ∀ n, U n ∈ nhds x) :
    ∃ b, b < x ∧ ∀ z, b < z → z < x → ∀ n, z ∈ U n := by
  obtain ⟨a, ha⟩ : ∃ a, a < x := by
    contrapose! hx;
    exact hasCountableLeftCof_of_isBot hx;
  -- For each n, use exists_Ioo_subset_of_mem_nhds to get bₙ < x with Ioo bₙ x ⊆ U n.
  obtain ⟨b, hb⟩ : ∃ b : ℕ → α, (∀ n, b n < x) ∧ (∀ n, Ioo (b n) x ⊆ U n) := by
    exact ⟨ fun n => Classical.choose ( exists_Ioo_subset_of_mem_nhds ( hU n ) ⟨ a, ha ⟩ ), fun n => Classical.choose_spec ( exists_Ioo_subset_of_mem_nhds ( hU n ) ⟨ a, ha ⟩ ) |>.1, fun n => Classical.choose_spec ( exists_Ioo_subset_of_mem_nhds ( hU n ) ⟨ a, ha ⟩ ) |>.2 ⟩;
  -- Since {b n} is not cofinal, there exists y < x such that ∀ n, b n < y.
  obtain ⟨y, hy₁, hy₂⟩ : ∃ y < x, ∀ n, b n < y := by
    contrapose! hx;
    exact fun _ => ⟨ b, hb.1, hx ⟩;
  exact ⟨ y, hy₁, fun z hz₁ hz₂ n => hb.2 n ⟨ hy₂ n |> lt_of_lt_of_le <| le_of_lt hz₁, hz₂ ⟩ ⟩

/-
**First-countability forces countable left cofinality.** In the order
topology, if nhds x is countably generated, then x must have countable
left cofinality.
-/
theorem countablyGenerated_nhds_left
    {x : α} (hcg : (nhds x).IsCountablyGenerated) :
    HasCountableLeftCof x := by
  intro h;
  obtain ⟨S, hS⟩ : ∃ S : ℕ → Set α, (∀ n, S n ∈ nhds x) ∧ ∀ U ∈ nhds x, ∃ n, S n ⊆ U := by
    rw [ Filter.isCountablyGenerated_iff_exists_antitone_basis ] at hcg;
    obtain ⟨ S, hS ⟩ := hcg;
    exact ⟨ S, fun n => hS.mem n, fun U hU => by rcases hS.mem_iff.mp hU with ⟨ n, hn ⟩ ; exact ⟨ n, hn ⟩ ⟩;
  -- For each n, Bₙ ∈ nhds x, so by exists_Ioc_subset_of_mem_nhds (or exists_Ioo_subset_of_mem_nhds proved above), there exists cₙ < x with Ioo cₙ x ⊆ Bₙ.
  obtain ⟨c, hc⟩ : ∃ c : ℕ → α, (∀ n, c n < x) ∧ ∀ n, Ioo (c n) x ⊆ S n := by
    exact ⟨ fun n => Classical.choose ( exists_Ioo_subset_of_mem_nhds ( hS.1 n ) h ), fun n => Classical.choose_spec ( exists_Ioo_subset_of_mem_nhds ( hS.1 n ) h ) |>.1, fun n => Classical.choose_spec ( exists_Ioo_subset_of_mem_nhds ( hS.1 n ) h ) |>.2 ⟩;
  refine' ⟨ c, hc.1, fun y hy => _ ⟩;
  contrapose! hS;
  refine' fun h => ⟨ Set.Ioi y, Ioi_mem_nhds hy, fun n => _ ⟩;
  simp_all +decide [ Set.not_subset ];
  exact ⟨ y, hc.2 n ⟨ hS n, hy ⟩, le_rfl ⟩

/-
First-countability forces countable right cofinality (dual).
-/
theorem countablyGenerated_nhds_right
    {x : α} (hcg : (nhds x).IsCountablyGenerated) :
    HasCountableRightCof x := by
  obtain ⟨ℬ, hℬ⟩ : ∃ ℬ : Set (Set α), ℬ.Countable ∧ Filter.HasBasis (𝓝 x) (fun s => s ∈ ℬ) (fun s => s) := by
    obtain ⟨ℬ, hℬ⟩ : ∃ ℬ : Set (Set α), ℬ.Countable ∧ Filter.HasBasis (𝓝 x) (fun s => s ∈ ℬ) (fun s => s) := by
      have := hcg
      rw [ Filter.isCountablyGenerated_iff_exists_antitone_basis ] at this;
      obtain ⟨ℬ, hℬ⟩ := this;
      refine' ⟨ Set.range ℬ, Set.countable_range ℬ, _ ⟩;
      convert hℬ.toHasBasis using 1;
      constructor <;> intro h <;> rw [ Filter.hasBasis_iff ] at * <;> aesop;
    use ℬ;
  intro hx
  obtain ⟨d, hd⟩ : ∃ d : ℬ → α, (∀ s : ℬ, x < d s) ∧ (∀ s : ℬ, Set.Ioo x (d s) ⊆ s.val) := by
    have h_basis : ∀ s ∈ ℬ, ∃ d : α, x < d ∧ Set.Ioo x d ⊆ s := by
      intro s hs
      have h_nhds : s ∈ nhds x := by
        exact hℬ.2.mem_of_mem hs;
      rcases exists_Ico_subset_of_mem_nhds h_nhds hx with ⟨ d, hd₁, hd₂ ⟩ ; exact ⟨ d, hd₁, fun y hy => hd₂ ⟨ hy.1.le, hy.2 ⟩ ⟩ ;
    exact ⟨ fun s => Classical.choose ( h_basis s s.2 ), fun s => Classical.choose_spec ( h_basis s s.2 ) |>.1, fun s => Classical.choose_spec ( h_basis s s.2 ) |>.2 ⟩;
  -- Define S n = dₙ. Each x < S n. For coinitiality: for any y > x, Iio y ∈ nhds x (by Iio_mem_nhds), so ∃ n, Bₙ ⊆ Iio y. Then dₙ ≤ y: if y < dₙ, then y ∈ Ioo x dₙ ⊆ Bₙ ⊆ Iio y means y < y, contradiction. So S n = dₙ ≤ y.
  obtain ⟨f, hf⟩ : ∃ f : ℕ → ℬ, ∀ s : ℬ, ∃ n, f n = s := by
    have := hℬ.1.exists_surjective;
    rcases ℬ.eq_empty_or_nonempty with ( rfl | hℬ' ) <;> simp_all +decide [ Function.Surjective ];
    have := hℬ.mem_iff.mp ( Filter.univ_mem ) ; aesop;
  refine' ⟨ fun n => d ( f n ), fun n => hd.1 _, fun y hy => _ ⟩;
  obtain ⟨ s, hs ⟩ := hℬ.2.mem_iff.mp ( Iio_mem_nhds hy );
  obtain ⟨ n, hn ⟩ := hf ⟨ s, hs.1 ⟩ ; use n; simp_all +decide [ Set.subset_def ] ;
  grind +locals

/-- **First-countable implies tame**: combining both directions. -/
theorem first_countable_implies_tame
    {x : α} (hcg : (nhds x).IsCountablyGenerated) : IsTame x :=
  ⟨countablyGenerated_nhds_left hcg, countablyGenerated_nhds_right hcg⟩

end WildPoints

/-! ## Tame Points Have Countable Neighborhood Bases -/

section TameNhds

variable [LinearOrder α] [TopologicalSpace α] [OrderTopology α]

/-
**Tame implies countably generated nhds**: If x has countable left and
right cofinality (given explicitly as sequences), the open intervals
between approximants form a countable sub-basis for nhds x.
-/
theorem tame_implies_countably_generated_nhds
    {x : α}
    (hL : ∃ S : ℕ → α, (∀ n, S n < x) ∧ ∀ y, y < x → ∃ n, y ≤ S n)
    (hR : ∃ S : ℕ → α, (∀ n, x < S n) ∧ ∀ y, x < y → ∃ n, S n ≤ y) :
    (nhds x).IsCountablyGenerated := by
  obtain ⟨S, hS⟩ := hL
  obtain ⟨T, hT⟩ := hR
  have h_basis : ∀ U ∈ nhds x, ∃ p : ℕ × ℕ, Ioo (S p.1) (T p.2) ⊆ U := by
    intro U hU
    obtain ⟨a, ha⟩ : ∃ a, a < x ∧ Ioc a x ⊆ U := by
      have := exists_Ioc_subset_of_mem_nhds hU ( show ∃ l, l < x from ⟨ S 0, hS.1 0 ⟩ ) ; aesop;
    obtain ⟨b, hb⟩ : ∃ b, x < b ∧ Ico x b ⊆ U := by
      rcases exists_Ico_subset_of_mem_nhds hU ( show ∃ u, x < u from ⟨ T 0, hT.1 0 ⟩ ) with ⟨ b, hb₁, hb₂ ⟩ ; exact ⟨ b, hb₁, hb₂ ⟩ ;
    obtain ⟨ n, hn ⟩ := hS.2 a ha.1
    obtain ⟨ m, hm ⟩ := hT.2 b hb.1
    use (n, m);
    grind +qlia;
  refine' ⟨ _, _ ⟩;
  exact Set.range fun p : ℕ × ℕ => Ioo ( S p.1 ) ( T p.2 );
  refine' ⟨ Set.countable_range _, le_antisymm _ _ ⟩;
  · rw [ le_generate_iff ];
    rintro _ ⟨ p, rfl ⟩ ; exact Ioo_mem_nhds ( hS.1 p.1 ) ( hT.1 p.2 ) ;
  · simp +decide [ Filter.le_def, Filter.mem_generate_iff ];
    exact fun U hU => by rcases h_basis U hU with ⟨ p, hp ⟩ ; exact ⟨ { p }, by simp +decide, by simpa using hp ⟩ ;

end TameNhds

/-! ## Surreal-Like Spaces -/

section SurrealLike

/-- A **surreal-like space** is a linearly ordered topological space where
every non-extremal point is wild (has uncountable cofinality from at
least one side). This captures the essential character of the surreal numbers. -/
class SurrealLikeSpace (α : Type*) [LinearOrder α] [TopologicalSpace α]
    [OrderTopology α] : Prop where
  everywhere_wild : ∀ x : α, (∃ a, a < x) → (∃ b, x < b) → IsWild x

variable [LinearOrder α] [TopologicalSpace α] [OrderTopology α]

/-- In a surreal-like space, no non-extremal point is first-countable. -/
theorem SurrealLikeSpace.not_countablyGenerated_nhds [SurrealLikeSpace α]
    {x : α} (hbot : ∃ a, a < x) (htop : ∃ b, x < b) :
    ¬(nhds x).IsCountablyGenerated := by
  intro h
  exact SurrealLikeSpace.everywhere_wild x hbot htop (first_countable_implies_tame h)

end SurrealLike

/-! ## Partition Theorem -/

section Partition

variable [LinearOrder α]

/-- The tame and wild loci partition the entire space. -/
theorem tame_union_wild : (tameLocus : Set α) ∪ wildLocus = univ := by
  ext x
  simp only [mem_union, mem_univ, iff_true]
  exact Classical.em (IsTame x)

/-- The tame and wild loci are disjoint. -/
theorem tame_inter_wild_empty : (tameLocus : Set α) ∩ wildLocus = ∅ := by
  ext x
  simp [tameLocus, wildLocus, IsTame, IsWild]

end Partition

/-! ## Falsifiable Conjecture

**Conjecture (Tame Locus Openness)**: In a linearly ordered topological space
with the order topology, the tame locus is open.

**Computational test**: In ω₁ + 1, the tame locus is [0, ω₁) which is open.
In ω₁ · 2, points of countable cofinality form ω₁ ∪ [ω₁, ω₁·2), also open.
A counterexample would need a tame point every neighborhood of which
contains a wild point. -/

end SurrealTopology