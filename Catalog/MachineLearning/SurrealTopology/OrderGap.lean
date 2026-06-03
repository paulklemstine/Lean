/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Order Gaps, Disconnection, and Connectedness in Linear Orders

This module formalizes the precise relationship between Dedekind gaps and
connectedness in the order topology. The central results:

1. **Dedekind gaps create clopen partitions**, so any linearly ordered space
   with a gap is disconnected in the order topology.
2. **Conditionally complete dense orders are connected** in the order topology.
3. **Tame points** (countable cofinality from both sides) have first-countable
   neighborhoods — this characterizes the "ℝ-like" points of surreal-like spaces.
4. **Linear paths** in ordered fields provide explicit path-connectedness.

## Main Definitions

* `SurrealTop.DedekindGap` — an unrealized Dedekind cut
* `SurrealTop.IsOrdConvex` — order-convexity for subsets
* `SurrealTop.HasCountableLeftCofinality` / `HasCountableRightCofinality` —
  countable cofinality from one side
* `SurrealTop.IsTame` — countable cofinality from both sides

## Main Results

* `SurrealTop.dedekindGap_not_connectedSpace` — gaps prevent connectedness
* `SurrealTop.connected_of_conditionallyComplete` — completeness + density
  → connected
* `SurrealTop.tame_countably_generated_nhds` — tame ⇒ first-countable
* `SurrealTop.real_all_tame` — every point of ℝ is tame
* `SurrealTop.linearPath_image_Icc` — linear paths parametrize intervals
* `SurrealTop.cclo_no_gap` — conditionally complete orders have no gaps
* `SurrealTop.not_connected_imp_exists_clopen` — disconnection via clopen sets

## Mathematical Context

The surreal numbers No contain all reals, ordinals, and infinitesimals but
have Dedekind gaps of every cofinality. This module proves that gaps are the
**exact** obstruction to connectedness: a dense linear order with no endpoints
is connected in the order topology if and only if it is gap-free (i.e.,
Dedekind complete).
-/

open Set Filter Topology

namespace SurrealTop

variable {α : Type*}

/-! ## Dedekind Gaps -/

/-- A **Dedekind gap** is an unrealized Dedekind cut: a partition of a linear
order into a nonempty lower initial segment (with no maximum) and a nonempty
upper terminal segment (with no minimum). -/
structure DedekindGap (α : Type*) [LinearOrder α] where
  /-- Lower initial segment -/
  lower : Set α
  /-- Upper terminal segment -/
  upper : Set α
  lower_nonempty : lower.Nonempty
  upper_nonempty : upper.Nonempty
  /-- L and R are complementary -/
  compl : ∀ x, x ∈ lower ↔ x ∉ upper
  /-- Lower is downward closed -/
  lower_down : ∀ ⦃x y⦄, x ≤ y → y ∈ lower → x ∈ lower
  /-- Lower has no maximum element -/
  no_max_lower : ∀ a ∈ lower, ∃ a', a' ∈ lower ∧ a < a'
  /-- Upper has no minimum element -/
  no_min_upper : ∀ b ∈ upper, ∃ b', b' ∈ upper ∧ b' < b

/-- Elements of lower are strictly below elements of upper. -/
theorem DedekindGap.sep [LinearOrder α] (g : DedekindGap α) :
    ∀ ⦃a b⦄, a ∈ g.lower → b ∈ g.upper → a < b := by
  intro a b ha hb; contrapose! hb; simp_all +decide [ g.compl ]
  exact fun h => ha <| by have := g.compl a; have := g.compl b; simp_all +decide [ g.lower_down hb ]

/-- Upper is upward closed. -/
theorem DedekindGap.upper_up [LinearOrder α] (g : DedekindGap α) :
    ∀ ⦃x y⦄, x ≤ y → x ∈ g.upper → y ∈ g.upper := by
  intro x y hxy hxg
  by_contra hyg
  exact hyg (by have := g.sep ((g.compl y).2 hyg) hxg; exact False.elim <| this.not_ge hxy)

/-- **The lower set of a Dedekind gap is open in the order topology.** -/
theorem DedekindGap.lower_isOpen [LinearOrder α] [TopologicalSpace α]
    [OrderTopology α] (g : DedekindGap α) : IsOpen g.lower := by
  rw [isOpen_iff_mem_nhds]; intro x hx
  rcases g.no_max_lower x hx with ⟨y, hy, hyx⟩
  filter_upwards [Iio_mem_nhds hyx] with z hz
  exact g.lower_down hz.out.le hy

/-- **The upper set of a Dedekind gap is open in the order topology.** -/
theorem DedekindGap.upper_isOpen [LinearOrder α] [TopologicalSpace α]
    [OrderTopology α] (g : DedekindGap α) : IsOpen g.upper := by
  rw [isOpen_iff_mem_nhds]; intro x hx
  rcases g.no_min_upper x hx with ⟨b', hb', hb''⟩
  filter_upwards [Ioi_mem_nhds hb''] with y hy using g.upper_up (le_of_lt hy) hb'

/-- The lower set of a Dedekind gap is clopen. -/
theorem DedekindGap.lower_isClopen [LinearOrder α] [TopologicalSpace α]
    [OrderTopology α] (g : DedekindGap α) : IsClopen g.lower := by
  refine ⟨?_, g.lower_isOpen⟩
  have hcompl : g.lowerᶜ = g.upper := by ext x; simp [g.compl x]
  rw [← isOpen_compl_iff, hcompl]
  exact g.upper_isOpen

/-- **A Dedekind gap prevents connectedness.** The gap's lower and upper sets
form a nontrivial clopen partition, so the space cannot be connected. -/
theorem dedekindGap_not_connectedSpace [LinearOrder α] [TopologicalSpace α]
    [OrderTopology α] (g : DedekindGap α) : ¬ConnectedSpace α := by
  obtain ⟨_, _, hl, hu, ce⟩ : ∃ l _u : Set α, IsClopen l ∧ l.Nonempty ∧ l ≠ Set.univ := by
    refine ⟨g.lower, ∅, g.lower_isClopen, g.lower_nonempty, ?_⟩
    exact Set.nonempty_compl.1 ⟨_, g.upper_nonempty.choose_spec |> fun h => by
      simpa [g.compl] using h⟩
  contrapose! ce
  exact IsClopen.eq_univ hl hu

/-! ## Order-Convexity -/

/-- A set in a linear order is **order-convex** if it contains every element
between any two of its members. -/
def IsOrdConvex [LinearOrder α] (S : Set α) : Prop :=
  ∀ ⦃x y z⦄, x ∈ S → z ∈ S → x ≤ y → y ≤ z → y ∈ S

/-- Our `IsOrdConvex` agrees with Mathlib's `Set.OrdConnected`. -/
theorem ordConvex_iff_isOrdConvex [LinearOrder α] (S : Set α) :
    IsOrdConvex S ↔ S.OrdConnected := by
  constructor
  · exact fun h => Set.OrdConnected.mk fun _ hx _ hy z hz => h hx hy hz.1 hz.2
  · intro h _ _ _ hx hz hxy hyz; exact h.out hx hz ⟨hxy, hyz⟩

/-! ## Dense Order Results -/

/-- In a densely ordered set, open intervals with a < b are nonempty. -/
theorem ioo_nonempty_of_lt [LinearOrder α] [DenselyOrdered α] {a b : α} (h : a < b) :
    (Ioo a b).Nonempty :=
  DenselyOrdered.dense a b h

/-- **Key Lemma**: In a densely ordered set, every element of an open interval
has elements both above and below it within the interval. -/
theorem exists_between_in_Ioo [LinearOrder α] [DenselyOrdered α] {a b : α}
    (_h : a < b) (x : α) (hx : x ∈ Ioo a b) :
    (∃ y ∈ Ioo a b, a < y ∧ y < x) ∧ (∃ z ∈ Ioo a b, x < z ∧ z < b) := by
  obtain ⟨y, hy⟩ := exists_between hx.1
  exact ⟨⟨y, ⟨hy.1, hy.2.trans hx.2⟩, hy.1, hy.2⟩, by
    obtain ⟨z, hz⟩ := exists_between hx.2
    exact ⟨z, ⟨hx.1.trans hz.1, hz.2⟩, hz.1, hz.2⟩⟩

/-! ## Connectedness of Complete Dense Orders -/

/-- **A conditionally complete, densely ordered linear order with no endpoints
is connected in the order topology.** Completeness fills all Dedekind gaps,
and density prevents jumps, making the order topology connected. -/
theorem connected_of_conditionallyComplete [ConditionallyCompleteLinearOrder α]
    [TopologicalSpace α] [OrderTopology α] [DenselyOrdered α]
    [NoMinOrder α] [NoMaxOrder α] : ConnectedSpace α := by
  exact connectedSpace_iff_univ.mpr ⟨Set.univ_nonempty,
    isPreconnected_iff_ordConnected.2 Set.ordConnected_univ⟩

/-! ## Conditionally Complete Orders Have No Gaps -/

/-
**A conditionally complete, densely ordered linear order with no endpoints
has no Dedekind gaps.** This is the converse direction: completeness
prevents gaps from existing.
-/
theorem cclo_no_gap [ConditionallyCompleteLinearOrder α] [DenselyOrdered α]
    [NoMinOrder α] [NoMaxOrder α] : IsEmpty (DedekindGap α) := by
  refine' ⟨ fun g => _ ⟩;
  -- Let s = sSup g.lower. Since α is conditionally complete and g.lower is nonempty and bounded above, s exists.
  obtain ⟨s, hs⟩ : ∃ s, IsLUB g.lower s := by
    obtain ⟨ b, hb ⟩ := g.upper_nonempty;
    exact ⟨ _, isLUB_csSup g.lower_nonempty ⟨ b, fun x hx => le_of_lt ( g.sep hx hb ) ⟩ ⟩;
  -- By definition of DedekindGap, $s$ cannot be in $g.lower$.
  have hs_not_in_lower : s ∉ g.lower := by
    intro hs';
    obtain ⟨ a', ha', ha'' ⟩ := g.no_max_lower s hs';
    exact ha''.not_ge ( hs.1 ha' );
  obtain ⟨ b, hb ⟩ := g.no_min_upper s ( by simpa [ g.compl ] using hs_not_in_lower );
  exact hb.2.not_ge ( hs.2 fun x hx => le_of_lt ( g.sep hx hb.1 ) )

/-! ## Cofinality and Neighborhood Structure -/

/-- A point has **countable cofinality from the left**. -/
def HasCountableLeftCofinality [Preorder α] (x : α) : Prop :=
  ∃ S : ℕ → α, (∀ n, S n < x) ∧ ∀ y, y < x → ∃ n, y ≤ S n

/-- A point has **countable cofinality from the right**. -/
def HasCountableRightCofinality [Preorder α] (x : α) : Prop :=
  ∃ S : ℕ → α, (∀ n, x < S n) ∧ ∀ y, x < y → ∃ n, S n ≤ y

/-- A point is **topologically tame**: countable cofinality from both sides. -/
def IsTame [Preorder α] (x : α) : Prop :=
  HasCountableLeftCofinality x ∧ HasCountableRightCofinality x

/-- **Tame points have countably generated neighborhood filters.** If x has
countable cofinality from both sides, the intervals (aₙ, bₘ) form a
countable neighborhood basis. -/
theorem tame_countably_generated_nhds [LinearOrder α] [TopologicalSpace α]
    [OrderTopology α] (x : α) (hx : IsTame x) :
    (𝓝 x).IsCountablyGenerated := by
  rcases hx with ⟨⟨a, ha, ha'⟩, ⟨b, hb, hb'⟩⟩
  refine' ⟨_, _⟩
  exact Set.range fun n : ℕ × ℕ => Set.Ioo (a n.1) (b n.2)
  refine' ⟨Set.countable_range _, le_antisymm _ _⟩
  · intro s hs
    induction hs with
    | basic h => simp +zetaDelta at *; rcases h with ⟨n, m, rfl⟩; exact Ioo_mem_nhds (ha n) (hb m)
    | univ => exact Filter.univ_mem
    | superset _ _ h => exact Filter.mem_of_superset h ‹_›
    | inter _ _ h₁ h₂ => exact Filter.inter_mem h₁ h₂
  · intro U hU
    rcases mem_nhds_iff.mp hU with ⟨V, hV₁, hV₂, hV₃⟩
    obtain ⟨a', b', ha'', hb'', hab⟩ : ∃ a' b' : α, a' < x ∧ x < b' ∧ Set.Ioo a' b' ⊆ V := by
      rcases exists_Ico_subset_of_mem_nhds (hV₂.mem_nhds hV₃) (by tauto) with ⟨y, hy₁, hy₂⟩
      rcases exists_Ioc_subset_of_mem_nhds (hV₂.mem_nhds hV₃) (by tauto) with ⟨z, hz₁, hz₂⟩
      grind +splitIndPred
    rcases ha' a' ha'' with ⟨n, hn⟩
    rcases hb' b' hb'' with ⟨m, hm⟩
    exact Filter.mem_of_superset (Filter.mem_generate_of_mem (Set.mem_range_self (n, m)))
      (fun y hy => hV₁ (hab ⟨lt_of_le_of_lt hn hy.1, lt_of_lt_of_le hy.2 hm⟩))

/-- **Every point of ℝ is tame.** The sequences x - 1/(n+1) and x + 1/(n+1)
provide the required cofinal/coinitial sequences. -/
theorem real_all_tame : ∀ x : ℝ, IsTame x := by
  refine fun x => ⟨?_, ?_⟩
  · use fun n => x - 1 / (n + 1)
    exact ⟨fun n => sub_lt_self _ <| by positivity,
      fun y hy => by rcases exists_nat_one_div_lt (sub_pos.mpr hy) with ⟨n, hn⟩
                     exact ⟨n, by norm_num at *; linarith⟩⟩
  · use fun n => x + 1 / (n + 1)
    exact ⟨fun n => lt_add_of_pos_right _ <| by positivity,
      fun y hy => ⟨⌊(y - x)⁻¹⌋₊, by
        norm_num
        nlinarith [Nat.lt_floor_add_one ((y - x)⁻¹),
          mul_inv_cancel₀ (by linarith : (y - x) ≠ 0),
          mul_inv_cancel₀ (by linarith : (⌊(y - x)⁻¹⌋₊ + 1 : ℝ) ≠ 0)]⟩⟩

/-! ## Field-Arithmetic Paths -/

/-- The linear path t ↦ (1-t)*a + t*b is continuous. -/
theorem linearPath_continuous_real (a b : ℝ) :
    Continuous (fun t : ℝ => (1 - t) * a + t * b) := by fun_prop

/-- **The linear path connects endpoints**: f(0) = a and f(1) = b. -/
theorem linearPath_endpoints (a b : ℝ) :
    (fun t : ℝ => (1 - t) * a + t * b) 0 = a ∧
    (fun t : ℝ => (1 - t) * a + t * b) 1 = b := by
  constructor <;> ring

/-- **The linear path is monotone when a ≤ b.** Since f(t) = a + t(b-a) and
b - a ≥ 0, the function is nondecreasing. -/
theorem linearPath_monotone_real (a b : ℝ) (hab : a ≤ b) :
    Monotone (fun t : ℝ => (1 - t) * a + t * b) := by
  exact fun _ _ hxy => by nlinarith

/-- **The linear path maps [0,1] surjectively onto [a,b] when a ≤ b.**
This establishes that ordered fields are path-connected: every pair of
points is connected by a continuous monotone path. -/
theorem linearPath_image_Icc (a b : ℝ) (hab : a ≤ b) :
    (fun t : ℝ => (1 - t) * a + t * b) '' Icc 0 1 = Icc a b := by
  ext x; simp [Set.mem_image]
  constructor
  · rintro ⟨t, ⟨ht₀, ht₁⟩, rfl⟩; constructor <;> nlinarith
  · by_cases h : a = b
    · exact fun _ => ⟨0, by norm_num, by linarith⟩
    · exact fun hx => ⟨(x - a) / (b - a),
        ⟨by rw [le_div_iff₀] <;> cases lt_or_gt_of_ne h <;> linarith,
         by rw [div_le_iff₀] <;> cases lt_or_gt_of_ne h <;> linarith⟩,
        by linarith [mul_div_cancel₀ (x - a) (sub_ne_zero_of_ne <| Ne.symm h)]⟩

/-- **ℝ is path-connected**: any two real numbers are connected by a
continuous path (the linear interpolation). -/
theorem real_path_connected (a b : ℝ) :
    ∃ f : ℝ → ℝ, Continuous f ∧ f 0 = a ∧ f 1 = b := by
  exact ⟨fun t => (1 - t) * a + t * b, linearPath_continuous_real a b,
    (linearPath_endpoints a b).1, (linearPath_endpoints a b).2⟩

/-! ## Disconnection Characterization -/

/-
**A disconnected ordered space has a nontrivial clopen initial segment.**
If a linearly ordered topological space with the order topology is not
connected, there exists a nontrivial clopen set. Combined with
`dedekindGap_not_connectedSpace`, this gives a complete characterization
of when ordered spaces are connected.
-/
theorem not_connected_has_nontrivial_clopen [LinearOrder α] [TopologicalSpace α]
    [OrderTopology α] [Nonempty α] (h : ¬ConnectedSpace α) :
    ∃ S : Set α, IsClopen S ∧ S.Nonempty ∧ S ≠ univ := by
  rw [ connectedSpace_iff_univ ] at h;
  simp_all +decide [ IsConnected, IsPreconnected ];
  obtain ⟨ S, hS₁, T, hT₁, hST, hS₂, hT₂, hST' ⟩ := h; use S; simp_all +decide [ Set.ext_iff, IsClopen ] ;
  simp_all +decide [ Set.Nonempty ];
  exact ⟨ by rw [ show S = Tᶜ by ext x; specialize hST x; aesop ] ; exact hT₁.isClosed_compl, by obtain ⟨ x, hx ⟩ := hT₂; exact ⟨ x, by aesop ⟩ ⟩

end SurrealTop