/-
# Union-Closed Families as Positive-Correlation Systems

This module formalizes the bridge between union-closed set systems and
monotone probability/correlation phenomena. Key results:

- **Theorem A**: Double-counting identity (sum of member counts = sum of set cardinalities)
- **Theorem B**: Majority-from-average principle (average density ≥ 1/2 forces a popular element)
- **Bridge**: Every upset is union-closed
- **Theorem C**: Total occupancy is monotone under union closure
- **Theorem D**: Nonneg correlation on full powerset (FKG base case)
- **Inclusion-exclusion** for member/joint counts

## Cross-Domain Interpretation

- `memberCount a F / F.card` = marginal occupancy of site `a`
- `jointCount a b F / F.card` = two-point correlation function
- `∑ s.card` = total particle number over all configurations
- `unionClosure` = coarse-graining / closure dynamics
- majority element theorem = emergence of a nonzero order parameter
- powerset correlation = finite FKG base case
-/

import Mathlib

open Finset BigOperators

/-! ## Core Definitions -/

variable {α : Type*} [DecidableEq α]

/-- A family F of finite subsets is union-closed if for every pair of members,
    their union is also a member. This models a constrained configuration space
    closed under binary joins — a monotone lattice gas. -/
def UnionClosedFamily (F : Finset (Finset α)) : Prop :=
  ∀ ⦃s t⦄, s ∈ F → t ∈ F → s ∪ t ∈ F

/-- A family F is an upper set family (upset) in the powerset inclusion order:
    if s ∈ F and s ⊆ t, then t ∈ F. For Fintype α, this is an order filter
    in the Boolean lattice. -/
def IsUpperSetFamily (F : Finset (Finset α)) : Prop :=
  ∀ ⦃s t : Finset α⦄, s ∈ F → s ⊆ t → t ∈ F

/-- The membership count: how many sets in F contain element a.
    Equals |F| times the marginal occupancy probability of site a
    under the uniform measure on F. -/
def memberCount (a : α) (F : Finset (Finset α)) : ℕ :=
  (F.filter fun s => a ∈ s).card

/-- The joint count: how many sets in F contain both elements a and b.
    Equals |F| times the two-point correlation function. -/
def jointCount (a b : α) (F : Finset (Finset α)) : ℕ :=
  (F.filter fun s => a ∈ s ∧ b ∈ s).card

/-- The union count: how many sets in F contain at least one of a or b. -/
def unionCount (a b : α) (F : Finset (Finset α)) : ℕ :=
  (F.filter fun s => a ∈ s ∨ b ∈ s).card

/-! ## Theorem A: Double-counting identity

  ∑_{a ∈ α} #{s ∈ F : a ∈ s} = ∑_{s ∈ F} |s|
-/

theorem sum_memberCount_eq_sum_card
    {α : Type*} [Fintype α] [DecidableEq α]
    (F : Finset (Finset α)) :
    (∑ a : α, memberCount a F) = ∑ s ∈ F, s.card := by
  unfold memberCount
  simp +decide only [card_filter]
  rw [Finset.sum_comm, Finset.sum_congr rfl]; aesop

/-! ## Theorem B: Majority-from-average principle

If the average set size is at least half the ground size,
some element belongs to at least half the sets.
-/

theorem exists_frequent_element_of_avg_card_ge_half
    {α : Type*} [Fintype α] [DecidableEq α] [Nonempty α]
    (F : Finset (Finset α))
    (_hFne : F.Nonempty)
    (havg : 2 * (∑ s ∈ F, s.card) ≥ F.card * Fintype.card α) :
    ∃ a : α, 2 * memberCount a F ≥ F.card := by
  contrapose! havg
  rw [← sum_memberCount_eq_sum_card]
  simpa [mul_comm, Finset.mul_sum _ _ _] using
    Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty fun a _ => havg a

/-! ## Bridge: Every upset is union-closed

This connects the order-theoretic notion (upper set) to the
algebraic notion (closure under ∪). In physical terms:
every filter in the configuration lattice is a valid
monotone lattice gas. -/

theorem upset_unionClosed (F : Finset (Finset α))
    (hup : IsUpperSetFamily F) : UnionClosedFamily F := by
  exact fun s t hs ht => hup hs ( Finset.subset_union_left )

/-! ## Inclusion-exclusion for two-element events

  |{s ∈ F : a ∈ s ∨ b ∈ s}| = memberCount a F + memberCount b F - jointCount a b F

This is the finite probability inclusion-exclusion principle
for the two-point correlation structure. -/

theorem unionCount_eq
    (a b : α) (F : Finset (Finset α)) :
    (unionCount a b F : ℤ) = memberCount a F + memberCount b F - jointCount a b F := by
  unfold unionCount memberCount jointCount;
  simp +decide only [filter_or, filter_and];
  rw [ ← Nat.cast_add, ← Finset.card_union_add_card_inter ] ; ring;
  rw [ Nat.cast_add, add_sub_cancel_right ]

/-! ## Union Closure

The union closure of F is the least union-closed family containing F.
We define it as the set of all elements obtainable as suprema (unions)
of nonempty subfamilies of F. -/

section UnionClosure

variable [Fintype α]

/-- The union closure of F: all sets obtainable as unions of
    nonempty subfamilies of F. This is the coarse-graining operator
    in the thermodynamic interpretation. -/
noncomputable def unionClosure (F : Finset (Finset α)) : Finset (Finset α) :=
  Finset.univ.filter fun s =>
    ∃ G : Finset (Finset α), G ⊆ F ∧ G.Nonempty ∧ G.sup id = s

/-
F is contained in its union closure (extensiveness).
-/
theorem subset_unionClosure (F : Finset (Finset α)) :
    F ⊆ unionClosure F := by
  intro s hs;
  exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, ⟨ { s }, by aesop ⟩ ⟩

/-
The union closure is union-closed (closure property).
-/
theorem unionClosure_unionClosed (F : Finset (Finset α)) :
    UnionClosedFamily (unionClosure F) := by
  intro s t hs ht;
  unfold unionClosure at *;
  simp +zetaDelta at *;
  obtain ⟨ G₁, hG₁₁, hG₁₂, rfl ⟩ := hs; obtain ⟨ G₂, hG₂₁, hG₂₂, rfl ⟩ := ht; use G₁ ∪ G₂; simp_all +decide [ Finset.sup_union ] ;
  exact Finset.union_subset hG₁₁ hG₂₁

/-! ## Theorem C: Monotonicity of total occupancy under closure

  ∑_{s ∈ F} |s| ≤ ∑_{s ∈ unionClosure F} |s|

Closure cannot decrease total occupancy — the discrete analog of
entropy monotonicity under coarse-graining. -/

theorem sum_card_monotone_under_unionClosure
    (F : Finset (Finset α)) :
    (∑ s ∈ F, s.card) ≤ ∑ s ∈ unionClosure F, s.card := by
  exact Finset.sum_le_sum_of_subset ( subset_unionClosure F )

end UnionClosure

/-! ## Theorem D: Nonneg correlation on full powerset (FKG base case)

For the full powerset under uniform measure, coordinate indicators
have nonnegative correlation. This is the base case for the FKG inequality:

  |2^α| · jointCount(a,b,2^α) ≥ memberCount(a,2^α) · memberCount(b,2^α)

For a ≠ b this is equality (independence); for a = b this is strict.
-/

theorem powerset_nonneg_correlation
    [Fintype α]
    (a b : α) :
    Fintype.card (Finset α) * jointCount a b (Finset.univ : Finset (Finset α)) ≥
    memberCount a (Finset.univ : Finset (Finset α)) *
    memberCount b (Finset.univ : Finset (Finset α)) := by
  by_cases hab : a = b <;> simp_all +decide [ memberCount, jointCount ];
  · exact Nat.mul_le_mul_right _ ( le_trans ( Finset.card_le_univ _ ) ( by simp +decide ) );
  · -- Let's count the number of subsets containing $a$ and $b$.
    have h_count : Finset.card (Finset.filter (fun s => a ∈ s) (Finset.univ : Finset (Finset α))) = 2 ^ (Fintype.card α - 1) ∧ Finset.card (Finset.filter (fun s => b ∈ s) (Finset.univ : Finset (Finset α))) = 2 ^ (Fintype.card α - 1) ∧ Finset.card (Finset.filter (fun s => a ∈ s ∧ b ∈ s) (Finset.univ : Finset (Finset α))) = 2 ^ (Fintype.card α - 2) := by
      have h_count : ∀ (s : Finset α), Finset.card (Finset.filter (fun t => s ⊆ t) (Finset.univ : Finset (Finset α))) = 2 ^ (Fintype.card α - s.card) := by
        intro s
        have h_count : Finset.card (Finset.filter (fun t => s ⊆ t) (Finset.univ : Finset (Finset α))) = Finset.card (Finset.image (fun t => s ∪ t) (Finset.powerset (Finset.univ \ s))) := by
          congr with t ; simp +decide [ Finset.subset_iff ];
          exact ⟨ fun h => ⟨ t \ s, fun x hx => by aesop, by aesop ⟩, by rintro ⟨ u, hu, rfl ⟩ x hx; aesop ⟩;
        rw [ h_count, Finset.card_image_of_injOn, Finset.card_powerset, Finset.card_sdiff ] ; aesop;
        intro t ht t' ht' h; simp_all +decide [ Finset.ext_iff ] ;
        intro x; specialize h x; replace ht := @ht x; replace ht' := @ht' x; aesop;
      have := h_count { a } ; have := h_count { b } ; have := h_count { a, b } ; simp_all +decide [ Finset.subset_iff ] ;
    rcases n : Fintype.card α with ( _ | _ | n ) <;> simp_all +decide [ pow_succ' ];
    grind

/-! ## Monotonicity of memberCount under family inclusion

If F ⊆ G, then memberCount a F ≤ memberCount a G.
In physical terms: enlarging the configuration space
cannot decrease the marginal occupancy count. -/

theorem memberCount_mono {F G : Finset (Finset α)}
    (h : F ⊆ G) (a : α) : memberCount a F ≤ memberCount a G := by
  exact Finset.card_mono fun x hx => Finset.mem_filter.mpr ⟨ h ( Finset.mem_filter.mp hx |>.1 ), Finset.mem_filter.mp hx |>.2 ⟩

/-! ## Union-closed families are closed under arbitrary finite unions of members

If F is union-closed, then the union of any nonempty finite subfamily
of F is also in F. This extends binary closure to n-ary closure by induction. -/

theorem unionClosed_sup_mem
    (F : Finset (Finset α))
    (hF : UnionClosedFamily F)
    (G : Finset (Finset α))
    (hG : G ⊆ F)
    (hne : G.Nonempty) :
    G.sup id ∈ F := by
  induction' hne using Finset.Nonempty.cons_induction with t G hG ih;
  · aesop;
  · simp_all +decide;
    exact hF ( hG ( Finset.mem_insert_self _ _ ) ) ( ‹ ( _ : Finset ( Finset α ) ) ⊆ F → _› ( Finset.Subset.trans ( Finset.subset_insert _ _ ) hG ) )