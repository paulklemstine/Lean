/-
# Certified Bottleneck Upgrade Theorems

A cross-domain capacity improvement calculus: in finite systems whose global
performance equals the infimum of local capacities, a targeted upgrade on the
critical (argmin) set produces a provable, exact throughput gain.

Applications:
- **Infrastructure**: road/rail corridor throughput
- **Manufacturing**: serial production line cycle-time
- **Telecommunications**: end-to-end link capacity

The key insight is that upgrading every component at the minimum capacity by
one unit raises the system minimum by exactly one, provided all non-critical
components were already strictly above the old minimum.
-/

import Mathlib

open Finset

/-! ## Core definitions -/

/-- The bottleneck set: elements of `s` achieving the minimum capacity. -/
def bottleneckSet {α : Type*} [DecidableEq α]
    (s : Finset α) (c : α → ℕ) (hs : s.Nonempty) : Finset α :=
  s.filter (fun x => c x = s.inf' hs c)

/-- Raise the capacity function by `δ` on elements of `u`. -/
def raiseOn {α : Type*} [DecidableEq α]
    (u : Finset α) (δ : ℕ) (c : α → ℕ) : α → ℕ :=
  fun x => c x + if x ∈ u then δ else 0

/-- Unit upgrade on a set: add 1 to every element of `u`. -/
def unitUpgradeOn {α : Type*} [DecidableEq α]
    (u : Finset α) (c : α → ℕ) : α → ℕ :=
  fun x => c x + if x ∈ u then 1 else 0

/-! ## Helper lemmas -/

/-- Membership characterization for the bottleneck set. -/
theorem mem_bottleneckSet_iff
    {α : Type*} [DecidableEq α]
    (s : Finset α) (c : α → ℕ) (hs : s.Nonempty) (x : α) :
    x ∈ bottleneckSet s c hs ↔ x ∈ s ∧ c x = s.inf' hs c := by
  simp [bottleneckSet, Finset.mem_filter]

/-- The bottleneck set is a subset of the original set. -/
theorem bottleneckSet_subset {α : Type*} [DecidableEq α]
    (s : Finset α) (c : α → ℕ) (hs : s.Nonempty) :
    bottleneckSet s c hs ⊆ s := by
  intro x hx
  rw [mem_bottleneckSet_iff] at hx
  exact hx.1

/-- The bottleneck set is nonempty. -/
theorem bottleneckSet_nonempty {α : Type*} [DecidableEq α]
    (s : Finset α) (c : α → ℕ) (hs : s.Nonempty) :
    (bottleneckSet s c hs).Nonempty := by
  obtain ⟨x, hx⟩ := Finset.exists_mem_eq_inf' hs (fun x => c x)
  use x
  simp [bottleneckSet, hx]

/-- If every element of `s` has `f x ≥ m`, then `s.inf' hs f ≥ m`. -/
theorem inf'_le_of_all_ge {α : Type*} [DecidableEq α]
    (s : Finset α) (hs : s.Nonempty) (f : α → ℕ) (m : ℕ)
    (hbound : ∀ x ∈ s, m ≤ f x) :
    m ≤ s.inf' hs f := by
  exact Finset.le_inf' _ _ hbound

/-- If every element of `s` has `f x ≥ m` and some witness achieves `m`,
    then `s.inf' hs f = m`. -/
theorem inf'_eq_of_bounds_and_witness {α : Type*} [DecidableEq α]
    (s : Finset α) (hs : s.Nonempty) (f : α → ℕ) (m : ℕ)
    (hbound : ∀ x ∈ s, m ≤ f x)
    (hwitness : ∃ x ∈ s, f x = m) :
    s.inf' hs f = m := by
  apply le_antisymm
  · obtain ⟨x, hx, hfx⟩ := hwitness
    calc s.inf' hs f ≤ f x := Finset.inf'_le _ hx
    _ = m := hfx
  · exact Finset.le_inf' _ _ hbound

/-! ## Main theorem: exact one-step bottleneck improvement -/

/-
**Bottleneck Upgrade Theorem (Exact Form).**
If `critical` is exactly the argmin set of `c` over `s`, all non-critical elements
have capacity at least `min + 1`, and `c'` upgrades each critical element to exactly
`c x + 1` while keeping all others unchanged, then the new minimum equals
the old minimum plus 1.
-/
theorem bottleneck_upgrade_strict_improvement
    {α : Type*} [DecidableEq α]
    (s critical : Finset α)
    (c : α → ℕ)
    (hcrit_subset : critical ⊆ s)
    (hs_nonempty : s.Nonempty)
    (hcritical_nonempty : critical.Nonempty)
    (hcritical_exact :
      ∀ x, x ∈ s →
        (x ∈ critical ↔ c x = s.inf' hs_nonempty c))
    (c' : α → ℕ)
    (hupgrade_on : ∀ x, x ∈ critical → c' x = c x + 1)
    (hstable_off : ∀ x, x ∈ s → x ∉ critical → c' x = c x)
    (hgap :
      ∀ x, x ∈ s → x ∉ critical → c x ≥ s.inf' hs_nonempty c + 1) :
    s.inf' hs_nonempty c' = s.inf' hs_nonempty c + 1 := by
  refine' le_antisymm _ _;
  · exact Finset.inf'_le _ ( hcrit_subset hcritical_nonempty.choose_spec ) |> le_trans <| by simp +decide [ hupgrade_on _ hcritical_nonempty.choose_spec, hcritical_exact _ ( hcrit_subset hcritical_nonempty.choose_spec ) |>.1 hcritical_nonempty.choose_spec ] ;
  · exact Finset.le_inf' _ _ fun x hx => by by_cases hx' : x ∈ critical <;> aesop;

/-
**Bottleneck Upgrade Theorem (Inequality Form).**
Under the same conditions but with `c' x ≥ c x + 1` on the critical set,
we get a lower bound on the new minimum.
-/
theorem bottleneck_upgrade_ge
    {α : Type*} [DecidableEq α]
    (s critical : Finset α)
    (c : α → ℕ)
    (_hcrit_subset : critical ⊆ s)
    (hs_nonempty : s.Nonempty)
    (hcritical_exact :
      ∀ x, x ∈ s →
        (x ∈ critical ↔ c x = s.inf' hs_nonempty c))
    (c' : α → ℕ)
    (hupgrade_on : ∀ x, x ∈ critical → c' x ≥ c x + 1)
    (hstable_off : ∀ x, x ∈ s → x ∉ critical → c' x = c x)
    (hgap :
      ∀ x, x ∈ s → x ∉ critical → c x ≥ s.inf' hs_nonempty c + 1) :
    s.inf' hs_nonempty c' ≥ s.inf' hs_nonempty c + 1 := by
  apply Finset.le_inf'
  grind

/-! ## Canonical form using `raiseOn` and `bottleneckSet` -/

/-
**Canonical Bottleneck Raise Theorem.**
Raising the bottleneck set by 1 increases the system minimum by exactly 1,
provided all non-bottleneck elements are strictly above the current minimum.
-/
theorem bottleneck_raiseOn_one_step
    {α : Type*} [DecidableEq α]
    (s : Finset α) (c : α → ℕ) (hs : s.Nonempty)
    (hgap : ∀ x ∈ s, x ∉ bottleneckSet s c hs → s.inf' hs c + 1 ≤ c x) :
    s.inf' hs (raiseOn (bottleneckSet s c hs) 1 c) = s.inf' hs c + 1 := by
  -- Let's unfold the definition of `raiseOn`.
  unfold raiseOn;
  refine' le_antisymm _ _;
  · obtain ⟨ x, hx ⟩ := Finset.exists_mem_eq_inf' hs c;
    exact le_trans ( Finset.inf'_le _ hx.1 ) ( by aesop );
  · refine' Finset.le_inf' _ _ _;
    intro x hx; split_ifs <;> simp_all +decide [ bottleneckSet ] ;

/-! ## Optimality theorem: bottleneck upgrades are optimal -/

/-
**Budgeted Optimality Theorem.**
Among all unit upgrade plans of equal cardinality, upgrading the bottleneck set
maximizes (or ties for maximum of) the new system minimum.
-/
theorem bottleneck_set_is_optimal_for_one_step_throughput
    {α : Type*} [DecidableEq α]
    (s u : Finset α) (c : α → ℕ) (hs : s.Nonempty)
    (_hu : u ⊆ s)
    (hcard : u.card = (bottleneckSet s c hs).card) :
    s.inf' hs (unitUpgradeOn u c) ≤
      s.inf' hs (unitUpgradeOn (bottleneckSet s c hs) c) := by
  by_cases hB : bottleneckSet s c hs ⊆ u;
  · have := Finset.eq_of_subset_of_card_le hB ; aesop;
  · -- Since $B$ is not a subset of $u$, there exists an element $x \in B$ such that $x \notin u$.
    obtain ⟨x, hx_B, hx_not_u⟩ : ∃ x, x ∈ bottleneckSet s c hs ∧ x ∉ u := by
      grind;
    refine' le_trans ( Finset.inf'_le _ _ ) _;
    exact x;
    · exact Finset.mem_filter.mp hx_B |>.1;
    · unfold unitUpgradeOn; simp +decide [ hx_not_u ] ;
      intro y hy; split_ifs <;> simp_all +decide [ bottleneckSet ] ;
      exact ⟨ y, hy, le_rfl ⟩

/-! ## Domain-specific corollaries -/

/-- **Infrastructure Corollary: Corridor Throughput Upgrade.**
For a transport corridor with finitely many segments, upgrading all bottleneck
segments by one unit increases corridor throughput by exactly one. -/
theorem corridor_throughput_upgrade
    (n : ℕ) [NeZero n]
    (segmentCapacity : Fin n → ℕ)
    (hgap : ∀ i : Fin n,
      i ∉ bottleneckSet Finset.univ segmentCapacity Finset.univ_nonempty →
      Finset.univ.inf' Finset.univ_nonempty segmentCapacity + 1 ≤ segmentCapacity i) :
    Finset.univ.inf' Finset.univ_nonempty
      (raiseOn (bottleneckSet Finset.univ segmentCapacity Finset.univ_nonempty) 1 segmentCapacity) =
    Finset.univ.inf' Finset.univ_nonempty segmentCapacity + 1 := by
  apply bottleneck_raiseOn_one_step
  intro x _ hx
  exact hgap x hx

/-- **Manufacturing Corollary: Serial Line Throughput Upgrade.**
For a serial production line, upgrading all slowest stations by one unit
increases line throughput by exactly one (in the discrete capacity model). -/
theorem serial_line_throughput_upgrade
    (n : ℕ) [NeZero n]
    (stationCapacity : Fin n → ℕ)
    (hgap : ∀ i : Fin n,
      i ∉ bottleneckSet Finset.univ stationCapacity Finset.univ_nonempty →
      Finset.univ.inf' Finset.univ_nonempty stationCapacity + 1 ≤ stationCapacity i) :
    Finset.univ.inf' Finset.univ_nonempty
      (raiseOn (bottleneckSet Finset.univ stationCapacity Finset.univ_nonempty) 1 stationCapacity) =
    Finset.univ.inf' Finset.univ_nonempty stationCapacity + 1 := by
  apply bottleneck_raiseOn_one_step
  intro x _ hx
  exact hgap x hx

/-- **Telecommunications Corollary: Route Capacity Upgrade.**
For a fixed communication route, upgrading all bottleneck links by one unit
increases end-to-end throughput by exactly one. -/
theorem route_capacity_upgrade
    (n : ℕ) [NeZero n]
    (linkCapacity : Fin n → ℕ)
    (hgap : ∀ i : Fin n,
      i ∉ bottleneckSet Finset.univ linkCapacity Finset.univ_nonempty →
      Finset.univ.inf' Finset.univ_nonempty linkCapacity + 1 ≤ linkCapacity i) :
    Finset.univ.inf' Finset.univ_nonempty
      (raiseOn (bottleneckSet Finset.univ linkCapacity Finset.univ_nonempty) 1 linkCapacity) =
    Finset.univ.inf' Finset.univ_nonempty linkCapacity + 1 := by
  apply bottleneck_raiseOn_one_step
  intro x _ hx
  exact hgap x hx

/-! ## Verification: axiom check -/
#print axioms bottleneck_upgrade_strict_improvement
#print axioms bottleneck_raiseOn_one_step
#print axioms bottleneck_set_is_optimal_for_one_step_throughput