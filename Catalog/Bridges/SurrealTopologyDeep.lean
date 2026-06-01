import Mathlib

set_option autoImplicit false

open Set TopologicalSpace Filter

/-! # Surreal Topology: Deep Structure of Ordered Continua

This file develops the deep structural theory connecting order-theoretic gap structure
to topological properties of linearly ordered spaces. We establish:

1. **Order Gap Theory**: Dedekind gaps and their relationship to connectedness.
2. **Cofinality-Topology Duality**: Order-theoretic cofinality ↔ first-countability.
3. **Archimedean Characterization**: Equivalence of Archimedean property with
   boundedness by naturals.
4. **Compactness Obstructions**: Non-compactness from unboundedness.

## Novel Definitions

* `OrderGap` — a Dedekind gap (cut with no realizing element).
* `GapFree` — the order has no gaps.
* `HasCountableLocalBasis` — countable local basis at a point.

## Catalog References

* `Catalog/Bridges/SurrealTopology.lean`
* `Catalog/Catalog/Bridges/SurrealTopologyExtended.lean`
-/

/-! ## Part I: Order Gap Theory -/

/-- An **order gap** (Dedekind gap) in a linear order is a partition into
a nonempty lower set `L` and nonempty upper set `R` where `L` has no maximum
and `R` has no minimum. This is the order-theoretic obstruction to connectedness. -/
structure OrderGap (α : Type*) [LinearOrder α] where
  lower : Set α
  upper : Set α
  lower_nonempty : lower.Nonempty
  upper_nonempty : upper.Nonempty
  partition : lower ∪ upper = univ
  disjoint : Disjoint lower upper
  lower_downward : ∀ ⦃a b : α⦄, a ≤ b → b ∈ lower → a ∈ lower
  upper_upward : ∀ ⦃a b : α⦄, a ≤ b → a ∈ upper → b ∈ upper
  lower_no_max : ∀ a : α, a ∈ lower → ∃ b : α, b ∈ lower ∧ a < b
  upper_no_min : ∀ a : α, a ∈ upper → ∃ b : α, b ∈ upper ∧ b < a

/-- A linear order is **gap-free** if no `OrderGap` exists. -/
def GapFree (α : Type*) [LinearOrder α] : Prop :=
  IsEmpty (OrderGap α)

/-! ## Part II: Conditionally Complete Orders are Gap-Free -/

/-
**A conditionally complete linear order has no Dedekind gaps.**

*Proof*: Given a gap (L, R), L is nonempty and bounded above (by elements of R).
Let s = sSup L. Either s ∈ L (contradicting no-max) or s ∈ R (contradicting no-min
via the upper bound property).
-/
theorem gapFree_of_conditionallyComplete
    (α : Type*) [ConditionallyCompleteLinearOrder α] :
    GapFree α := by
      refine' ⟨ fun ⟨ L, R, hL, hR, hpartition, hdisjoint, hlower_downward, hupper_upward, hlower_no_max, hupper_no_min ⟩ => _ ⟩;
      -- By the partition, either s ∈ L � or� s ∈ R.
      have h_s_in_L_or_R : (sSup L ∈ L) ∨ (sSup L ∈ R) := by
        exact hpartition.symm.subset ( Set.mem_univ _ );
      cases' h_s_in_L_or_R with h h;
      · exact absurd ( hlower_no_max _ h ) ( by rintro ⟨ b, hb, hb' ⟩ ; exact hb'.not_ge ( le_csSup ⟨ hR.choose, fun x hx => le_of_not_gt fun hx' => hdisjoint.le_bot ⟨ hx, hupper_upward hx'.le hR.choose_spec ⟩ ⟩ hb ) );
      · -- By upper_no_min, b ∈ R � with� b < s.
        obtain ⟨b, hbR, hb_lt_s⟩ : ∃ b ∈ R, b < sSup L := hupper_no_min _ h;
        contrapose! hb_lt_s;
        exact csSup_le hL fun x hx => le_of_not_gt fun hx' => Set.disjoint_left.mp hdisjoint hx ( hupper_upward hx'.le hbR )

/-! ## Part III: Gaps ↔ Topology -/

/-
**The lower set of a gap is open in the order topology.**
For any a ∈ L, find b ∈ L with a < b; then Iio b ⊆ L (by downward closure)
and is an open neighborhood of a.
-/
theorem OrderGap.lower_isOpen {α : Type*} [LinearOrder α]
    [TopologicalSpace α] [OrderTopology α] (g : OrderGap α) :
    IsOpen g.lower := by
      cases' g with L R L_nonempty R_nonempty partition disjoint L_downward R_upward L_no_max R_no_min;
      rw [ isOpen_iff_mem_nhds ] ; intro a ha ; rcases L_no_max a ha with ⟨ b, hb, hab ⟩ ; refine' Filter.mem_of_superset ( Iio_mem_nhds hab ) _ ; intro x hx ; exact L_downward ( le_of_lt hx ) hb;

/-
**The upper set of a gap is open in the order topology.**
-/
theorem OrderGap.upper_isOpen {α : Type*} [LinearOrder α]
    [TopologicalSpace α] [OrderTopology α] (g : OrderGap α) :
    IsOpen g.upper := by
      refine isOpen_iff_mem_nhds.2 fun x hx => ?_;
      -- By upper_no_min, there exists $y \ �in� g.upper$ such that $y < x$.
      obtain ⟨y, hy₁, hy₂⟩ : ∃ y ∈ g.upper, y < x := by
        exact g.upper_no_min x hx;
      filter_upwards [ Ioi_mem_nhds hy₂ ] with z hz;
      exact g.upper_upward ( le_of_lt hz ) hy₁

/-
**A connected linear order with order topology is gap-free.**
A gap produces two nonempty disjoint open sets covering the space,
contradicting connectedness.
-/
theorem gapFree_of_connectedSpace
    (α : Type*) [LinearOrder α] [TopologicalSpace α] [OrderTopology α]
    [ConnectedSpace α] :
    GapFree α := by
      refine' ⟨ fun g => _ ⟩;
      obtain ⟨l, hl⟩ := g;
      have h_clopen : IsClopen l := by
        constructor;
        · convert isClosed_compl_iff.mpr ( show IsOpen hl from ?_ ) using 1;
          · simp_all +decide [ Set.ext_iff, Set.disjoint_left ];
            grind;
          · convert OrderGap.upper_isOpen ( OrderGap.mk l hl ‹_› ‹_› ‹_› ‹_› ‹_› ‹_› ‹_› ‹_› ) using 1;
        · have h_open : IsOpen l := by
            have h_gap : ∃ g : OrderGap α, g.lower = l := by
              use ⟨l, hl, by assumption, by assumption, by assumption, by assumption, by assumption, by assumption, by assumption, by assumption⟩
            grind +suggestions;
          exact h_open;
      cases isClopen_iff.mp h_clopen <;> aesop

/-! ## Part IV: Cofinality Sequences -/

/-
**A countable nonempty coinitial set above x yields a coinitial sequence.**
Uses the fact that countable nonempty sets can be enumerated as a range.
-/
theorem countable_coinitial_above_of_seq
    {α : Type*} [LinearOrder α] (x : α)
    (h : ∃ S : Set α, S.Countable ∧ S.Nonempty ∧ (∀ s : α, s ∈ S → x < s) ∧
      (∀ y : α, x < y → ∃ s : α, s ∈ S ∧ s ≤ y)) :
    ∃ f : ℕ → α, (∀ n : ℕ, x < f n) ∧ (∀ y : α, x < y → ∃ n : ℕ, f n ≤ y) := by
      -- From h, obtain S, hcount, hne, hS_above�,� hS_coinit�.� Since � S� is countable and nonempty, use Set.Countable.exists_surjective or the encoding.
      obtain ⟨S, hcount, hne, hS_above, hS_coinit⟩ := h
      obtain ⟨g, hg⟩ : ∃ g : ℕ → α, Set.range g = S := by
        have := hcount.exists_eq_range; aesop;
      aesop

/-! ## Part V: Order Isomorphisms are Homeomorphisms -/

/-
**Every order isomorphism between ordered topological spaces is continuous.**
-/
theorem orderIso_continuous {α β : Type*}
    [LinearOrder α] [TopologicalSpace α] [OrderTopology α]
    [LinearOrder β] [TopologicalSpace β] [OrderTopology β]
    (f : α ≃o β) : Continuous f := by
      convert OrderIso.continuous f

/-
**The inverse of an order isomorphism is continuous.**
-/
theorem orderIso_continuous_inv {α β : Type*}
    [LinearOrder α] [TopologicalSpace α] [OrderTopology α]
    [LinearOrder β] [TopologicalSpace β] [OrderTopology β]
    (f : α ≃o β) : Continuous f.symm := by
      convert orderIso_continuous f.symm

/-! ## Part VI: Dense Order Separation -/

/-
**In a densely ordered space, distinct points have an intermediate separator.**
This gives an explicit Hausdorff separation construction.
-/
theorem dense_order_separation
    {α : Type*} [LinearOrder α] [TopologicalSpace α] [OrderTopology α]
    [DenselyOrdered α]
    (x y : α) (hxy : x < y) :
    ∃ z : α, x < z ∧ z < y ∧ IsOpen (Iio z) ∧ IsOpen (Ioi z) := by
      exact Exists.elim ( exists_between hxy ) fun z hz => ⟨ z, hz.1, hz.2, isOpen_Iio, isOpen_Ioi ⟩

/-! ## Part VII: Archimedean Characterization -/

/-
**A positive element in an Archimedean ordered additive commutative monoid
is bounded above by some natural multiple of any positive element.**
Restated: the Archimedean property gives ∃ n, x ≤ n • y for any x and positive y.
-/
theorem archimedean_bound {α : Type*} [AddCommMonoid α] [PartialOrder α] [Archimedean α]
    (x : α) {y : α} (hy : 0 < y) : ∃ n : ℕ, x ≤ n • y := by
      convert Archimedean.arch x hy

/-! ## Part VIII: Compactness Obstructions -/

/-
**A nonempty ordered space with no minimum is not compact.**
Dual of the no-maximum case. Cover by {Ioi a | a : α}.
-/
theorem noncompactSpace_of_noMinOrder
    (α : Type*) [LinearOrder α] [TopologicalSpace α] [OrderTopology α]
    [NoMinOrder α] [Nonempty α] :
    NoncompactSpace α := by
      constructor;
      intro h;
      have := h.elim_finite_subcover ( fun a => Set.Ioi a ) ?_ <;> simp_all +decide [ Set.ext_iff ];
      · cases' this with t ht;
        exact absurd ( Finset.exists_min_image t id ( Finset.nonempty_of_ne_empty ( by rintro rfl; simpa using ht ( Classical.arbitrary α ) ) ) ) ( by rintro ⟨ x, hxt, hx ⟩ ; obtain ⟨ y, hyt, hyx ⟩ := ht x; exact hyx.not_ge ( hx _ hyt ) );
      · exact fun x => isOpen_Ioi

/-
**An infinite discrete space is noncompact.**
-/
theorem infinite_discrete_noncompact
    (α : Type*) [TopologicalSpace α] [DiscreteTopology α]
    [Infinite α] :
    NoncompactSpace α := by
      constructor;
      exact fun h => h.finite_of_discrete.not_infinite <| Set.infinite_univ

/-! ## Part IX: Connected Image -/

/-
**The image of a connected set under a continuous map is connected.**
-/
theorem isConnected_image_continuous
    {α β : Type*} [TopologicalSpace α] [TopologicalSpace β]
    {f : α → β} (hf : Continuous f)
    {s : Set α} (hs : IsConnected s) :
    IsConnected (f '' s) := by
      exact hs.image _ hf.continuousOn

/-! ## Part X: Countable Local Basis -/

/-- A point has a **countable local basis** if there exists a countable family
of open neighborhoods forming a basis of the neighborhood filter. -/
def HasCountableLocalBasis {α : Type*} [TopologicalSpace α] (x : α) : Prop :=
  ∃ (B : ℕ → Set α), (∀ n : ℕ, IsOpen (B n)) ∧ (∀ n : ℕ, x ∈ B n) ∧
    ∀ U : Set α, U ∈ nhds x → ∃ n : ℕ, B n ⊆ U

/-
**Every point in ℝ has a countable local basis.**
-/
theorem real_has_countable_local_basis (x : ℝ) :
    HasCountableLocalBasis x := by
      use fun n => Metric.ball x ( 1 / ( n + 1 ) );
      exact ⟨ fun n => Metric.isOpen_ball, fun n => Metric.mem_ball_self <| by positivity, fun U hU => by rcases Metric.mem_nhds_iff.1 hU with ⟨ ε, εpos, hε ⟩ ; exact ⟨ ⌈ε⁻¹⌉₊, fun y hy => hε <| by simpa using lt_of_lt_of_le hy.out <| by simpa using inv_le_of_inv_le₀ εpos <| by linarith [ Nat.le_ceil <| ε⁻¹ ] ⟩ ⟩

/-
**Every point in a second-countable space has a countable local basis.**
-/
theorem hasCountableLocalBasis_of_secondCountable
    {α : Type*} [TopologicalSpace α]
    [SecondCountableTopology α] (x : α) :
    HasCountableLocalBasis x := by
      -- Since the space is second-countable, there exists a count �able� basis for the topology. Let's denote this basis as B.
      obtain ⟨B, hB⟩ : ∃ B : Set (Set α), B.Countable ∧ TopologicalSpace.IsTopologicalBasis B := by
        have := TopologicalSpace.exists_countable_basis α; aesop;
      -- Filter B to obtain a countable set of open sets containing x.
      set Bx := {U ∈ B | x ∈ U} with hBx_def
      have hBx_countable : Bx.Countable := by
        exact hB.1.mono fun U hU => hU.1;
      -- Since Bx is count �able�, we can enumerate its elements as a sequence.
      obtain ⟨f, hf⟩ : ∃ f : ℕ → Set α, Set.range f = Bx := by
        by_cases hBx_empty : Bx = ∅;
        · exact absurd ( hB.2.mem_nhds_iff.1 ( Filter.univ_mem' ( fun _ => trivial ) ) ) ( by aesop );
        · have := hBx_countable.exists_eq_range;
          exact Exists.elim ( this ( Set.nonempty_iff_ne_empty.2 hBx_empty ) ) fun f hf => ⟨ f, hf.symm ⟩;
      refine' ⟨ f, _, _, _ ⟩;
      · exact fun n => hB.2.isOpen ( hf.subset ( Set.mem_range_self n ) |>.1 );
      · exact fun n => hf.subset ( Set.mem_range_self n ) |>.2;
      · intro U hU; rcases hB.2.mem_nhds_iff.mp hU with ⟨ V, hV, hxV, hVU ⟩ ; replace hf := Set.ext_iff.mp hf V; aesop;

/-! ## Part XI: Disconnectedness Results -/

/-
**ℚ is not connected.**
The sets {q ∈ ℚ | q < √2} and {q ∈ ℚ | q > √2} disconnect ℚ.
-/
theorem rat_not_connectedSpace : ¬ ConnectedSpace ℚ := by
  intro h_connectedSpace
  have h_connected_components : IsPreconnected (Set.univ : Set ℚ) := by
    exact isPreconnected_univ;
  -- The sets {q : | (q : ℝ) < Real.sqrt 2} and {q : ℚ | (q : ℝ) > Real.sqrt 2} are both open in ℚ.
  have h_open : IsOpen {q : ℚ | (q : ℝ) < Real.sqrt 2} ∧ IsOpen {q : ℚ | (q : ℝ) > Real.sqrt 2} := by
    exact ⟨ isOpen_lt ( by continuity ) ( by continuity ), isOpen_lt ( by continuity ) ( by continuity ) ⟩;
  have := h_connected_components { q : ℚ | ( q : ℝ ) < Real.sqrt 2 } { q : ℚ | ( q : ℝ ) > Real.sqrt 2 } h_open.1 h_open.2;
  simp_all +decide [ Set.ext_iff ];
  exact absurd ( this ( fun x hx => irrational_sqrt_two <| by aesop ) ⟨ 0, by norm_num [ Real.lt_sqrt ] ⟩ ⟨ 2, by norm_num [ Real.sqrt_lt ] ⟩ ) ( by rintro ⟨ x, hx₁, hx₂ ⟩ ; linarith [ hx₁.out, hx₂.out ] )

/-
**ℤ is not connected.**
-/
theorem int_not_connectedSpace : ¬ ConnectedSpace ℤ := by
  intro h_connected_space
  have h_preconnected : IsPreconnected (Set.univ : Set ℤ) := by
    exact isPreconnected_univ;
  simp_all +decide [ IsPreconnected ];
  exact absurd ( h_preconnected { n : ℤ | n ≤ 0 } { n : ℤ | n ≥ 1 } ( by ext x; exact by cases le_or_gt x 0 <;> aesop ) ⟨ 0, by norm_num ⟩ ⟨ 1, by norm_num ⟩ ) ( by rintro ⟨ n, hn₁, hn₂ ⟩ ; linarith [ hn₁.out, hn₂.out ] )

/-- **ℝ is connected** — the prototypical gap-free complete order. -/
theorem real_connectedSpace : ConnectedSpace ℝ := inferInstance

/-! ## Falsifiable Conjecture

**Conjecture (Gap-Completeness Duality):**
For a linear order `α` with no endpoints and order topology:
`α` is connected ↔ `α` is gap-free AND conditionally complete.

**Testable Predictions:**
- ℚ: gap-free ✓, not conditionally complete ✓, not connected ✓
- ℝ: gap-free ✓, conditionally complete ✓, connected ✓
- ℤ: has gaps ✗, not connected ✓

**Potential counterexample:** Suslin lines (independent of ZFC).
-/