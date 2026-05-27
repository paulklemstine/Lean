/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Universal Support-Tutte Polynomial

This file establishes a universal deletion–contraction invariant for M-convex supports,
building on the minor-closure infrastructure of support minor theory. We define a
Tutte-style contraction operation, prove that deletion and contraction at ordinary
coordinates strictly reduce support size, and establish the **universality theorem**:
any deletion–contraction invariant satisfying loop and ordinary recurrence rules is
uniquely determined by its parameters.

## Main Definitions

* `SupportExchange` — Symmetric exchange property (M-convexity)
* `supportDelete` — Deletion at coordinate i (retain elements with m(i) = 0)
* `tutteContract` — Tutte-style contraction (retain m(i) > 0, subtract 1)
* `IsSupportLoop` — All elements have positive i-value
* `IsOrdinaryCoord` — Some elements have m(i) = 0, some have m(i) > 0
* `GoodSupport` — Bundle of finite support set with exchange property
* `SupportActivityData` — Activity counts in deletion-contraction decomposition
* `supportMeasure` — Well-founded termination measure (totalDeg + card)

## Main Results

* `supportDelete_card_lt` — Deletion at relevant coordinate strictly reduces cardinality
* `tutteContract_card_lt_of_ordinary` — Contraction at ordinary coordinate strictly reduces
    cardinality
* `supportMeasure_contract_lt_of_loop` — Contraction at loop coordinate strictly reduces measure
* `support_classification` — Every support is empty, trivial ({0}), or has an ordinary/loop
    coordinate
* `dc_invariant_unique` — **Universality**: any two DC invariants with same parameters agree
* `matroid_indicator_ordinary_iff` — Bridge: ordinary coordinates in {0,1}-supports correspond
    to matroid-theoretic ordinary elements

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Brylawski–Oxley, "The Tutte polynomial and its applications", 1992
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finset BigOperators Finsupp

namespace UniversalSupportTutte

variable {ι : Type*} [DecidableEq ι]

/-! ## Section 1: Core Definitions -/

/-- The **symmetric exchange property** for support sets (M-convexity). -/
def SupportExchange (S : Finset (ι →₀ ℕ)) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, ∀ a : ι,
    x a > y a →
    ∃ b : ι, y b > x b ∧
      x - Finsupp.single a 1 + Finsupp.single b 1 ∈ S ∧
      y + Finsupp.single a 1 - Finsupp.single b 1 ∈ S

/-- **Support deletion** at coordinate i: retain only elements with m(i) = 0. -/
def supportDelete (S : Finset (ι →₀ ℕ)) (i : ι) : Finset (ι →₀ ℕ) :=
  S.filter (fun m => m i = 0)

/-- **Tutte-style contraction** at coordinate i: retain elements with m(i) > 0,
    then subtract 1 from coordinate i. -/
noncomputable def tutteContract (S : Finset (ι →₀ ℕ)) (i : ι) : Finset (ι →₀ ℕ) :=
  (S.filter (fun m => 0 < m i)).image (fun m => m - Finsupp.single i 1)

/-- Coordinate i is a **support loop** if every element has positive i-value. -/
def IsSupportLoop (S : Finset (ι →₀ ℕ)) (i : ι) : Prop :=
  ∀ m ∈ S, m i > 0

/-- Coordinate i is a **support coloop** if all elements share the same i-value. -/
def IsSupportColoop (S : Finset (ι →₀ ℕ)) (i : ι) : Prop :=
  ∃ v, ∀ m ∈ S, m i = v

/-- Coordinate i is **ordinary** if some elements have m(i) = 0 and some have m(i) > 0. -/
def IsOrdinaryCoord (S : Finset (ι →₀ ℕ)) (i : ι) : Prop :=
  (∃ m ∈ S, m i = 0) ∧ (∃ m ∈ S, 0 < m i)

/-! ## Section 2: New Structures -/

/-- A **GoodSupport** bundles a finite support set with the exchange property. -/
structure GoodSupport (ι : Type*) [DecidableEq ι] where
  support : Finset (ι →₀ ℕ)
  exchange : SupportExchange support

/-- **Activity data** recording the counts of loops, coloops, and ordinary
    coordinates encountered during a deletion–contraction decomposition. -/
structure SupportActivityData where
  loops : ℕ
  coloops : ℕ
  ordinary : ℕ
  deriving Repr, DecidableEq

/-- Total degree of a support: sum of all coordinate values across all elements. -/
noncomputable def supportTotalDeg (S : Finset (ι →₀ ℕ)) : ℕ :=
  S.sum (fun m => m.sum (fun _ v => v))

/-- **Support measure** for well-founded recursion. -/
noncomputable def supportMeasure (S : Finset (ι →₀ ℕ)) : ℕ :=
  supportTotalDeg S + S.card

/-! ## Section 3: Basic Properties -/

theorem supportDelete_subset (S : Finset (ι →₀ ℕ)) (i : ι) :
    supportDelete S i ⊆ S :=
  filter_subset _ _

theorem supportDelete_card_le (S : Finset (ι →₀ ℕ)) (i : ι) :
    (supportDelete S i).card ≤ S.card :=
  card_filter_le S _

theorem mem_supportDelete_iff {S : Finset (ι →₀ ℕ)} {i : ι} {m : ι →₀ ℕ} :
    m ∈ supportDelete S i ↔ m ∈ S ∧ m i = 0 :=
  Finset.mem_filter

/-- Exchange is trivially satisfied by the empty set. -/
theorem exchange_empty : SupportExchange (∅ : Finset (ι →₀ ℕ)) := by
  intro x hx; simp at hx

/-- Exchange is trivially satisfied by singletons. -/
theorem exchange_singleton (m : ι →₀ ℕ) : SupportExchange ({m} : Finset (ι →₀ ℕ)) := by
  intro x hx y hy a ha
  rw [mem_singleton] at hx hy
  subst hx; subst hy
  exact absurd ha (lt_irrefl _)

/-! ## Section 4: Cardinality Descent Lemmas -/

/-
**Deletion at a relevant coordinate strictly reduces cardinality.**
-/
theorem supportDelete_card_lt {S : Finset (ι →₀ ℕ)} {i : ι}
    (h : ∃ m ∈ S, 0 < m i) :
    (supportDelete S i).card < S.card := by
  refine' Finset.card_lt_card _;
  exact ⟨ fun x hx => Finset.mem_filter.mp hx |>.1, fun hx => by obtain ⟨ m, hm₁, hm₂ ⟩ := h; exact absurd ( hx hm₁ ) ( by simp +decide [ hm₂.ne', supportDelete ] ) ⟩

/-
**Tutte contraction does not increase cardinality.**
-/
theorem tutteContract_card_le (S : Finset (ι →₀ ℕ)) (i : ι) :
    (tutteContract S i).card ≤ S.card := by
  exact Finset.card_image_le.trans ( Finset.card_filter_le _ _ ) |> le_trans <| by simp +decide ;

/-
**Tutte contraction at ordinary coordinate strictly reduces cardinality.**
-/
theorem tutteContract_card_lt_of_ordinary {S : Finset (ι →₀ ℕ)} {i : ι}
    (h : ∃ m ∈ S, m i = 0) (hpos : ∃ m ∈ S, 0 < m i) :
    (tutteContract S i).card < S.card := by
  refine' lt_of_le_of_lt ( Finset.card_image_le ) _;
  exact Finset.card_lt_card ( Finset.filter_ssubset.mpr ⟨ h.choose, h.choose_spec.1, by simp +decide [ h.choose_spec.2 ] ⟩ )

/-! ## Section 5: Measure Descent for Loops -/

/-
For a loop coordinate, Tutte contraction strictly reduces the support measure.
-/
theorem supportMeasure_contract_lt_of_loop {S : Finset (ι →₀ ℕ)} {i : ι}
    (hloop : IsSupportLoop S i) (hne : S.Nonempty) :
    supportMeasure (tutteContract S i) < supportMeasure S := by
  -- Since $i$ is a loop, the total degree of the contracted set is strictly less than the total degree of $S$.
  have h_total_deg : (tutteContract S i).sum (fun m => m.sum (fun _ v => v)) ≤ S.sum (fun m => m.sum (fun _ v => v)) - S.card := by
    have h_total_deg : (tutteContract S i).sum (fun m => m.sum (fun _ v => v)) ≤ (S.filter (fun m => 0 < m i)).sum (fun m => (m - Finsupp.single i 1).sum (fun _ v => v)) := by
      have h_total_deg : (tutteContract S i).sum (fun m => m.sum (fun _ v => v)) ≤ (Finset.image (fun m => m - Finsupp.single i 1) (S.filter (fun m => 0 < m i))).sum (fun m => m.sum (fun _ v => v)) := by
        rfl;
      refine' le_trans h_total_deg _;
      rw [ Finset.sum_image ];
      intro m hm m' hm' h_eq; simp_all +decide [ Finsupp.ext_iff ] ;
      grind;
    have h_total_deg : (S.filter (fun m => 0 < m i)).sum (fun m => (m - Finsupp.single i 1).sum (fun _ v => v)) ≤ (S.filter (fun m => 0 < m i)).sum (fun m => m.sum (fun _ v => v) - 1) := by
      refine' Finset.sum_le_sum fun m hm => _;
      rw [ Finsupp.sum_of_support_subset ];
      case s => exact m.support;
      · refine' Nat.le_sub_one_of_lt ( Finset.sum_lt_sum _ _ );
        · exact fun x hx => Nat.sub_le _ _;
        · exact ⟨ i, by aesop ⟩;
      · intro j hj; contrapose! hj; aesop;
      · exact fun _ _ => rfl;
    have h_total_deg : (S.filter (fun m => 0 < m i)).sum (fun m => m.sum (fun _ v => v) - 1) ≤ (S.filter (fun m => 0 < m i)).sum (fun m => m.sum (fun _ v => v)) - (S.filter (fun m => 0 < m i)).card := by
      rw [ Nat.sub_eq_of_eq_add ];
      rw [ Finset.card_eq_sum_ones, ← Finset.sum_add_distrib ];
      exact Finset.sum_congr rfl fun x hx => by rw [ Nat.sub_add_cancel ( show 1 ≤ x.sum fun x v => v from Finset.sum_pos ( fun y hy => Nat.pos_of_ne_zero ( by aesop ) ) ( by contrapose! hx; aesop ) ) ] ;
    rw [ show ( Finset.filter ( fun m => 0 < m i ) S ) = S from Finset.filter_true_of_mem fun m hm => hloop m hm ] at * ; omega;
  -- Since $i$ is a loop, the cardinality of the contracted set is less than or equal to the cardinality of $S$.
  have h_card : (tutteContract S i).card ≤ S.card := by
    grind +locals;
  refine' lt_of_le_of_lt ( add_le_add h_total_deg h_card ) _;
  rw [ tsub_add_cancel_of_le ];
  · exact lt_add_of_pos_right _ ( Finset.card_pos.mpr hne );
  · refine' le_trans _ ( Finset.sum_le_sum fun m hm => show m.sum ( fun x v => v ) ≥ 1 from _ );
    · simp +decide;
    · exact le_trans ( Nat.succ_le_of_lt ( hloop m hm ) ) ( Finset.single_le_sum ( fun x _ => Nat.zero_le ( m x ) ) ( Finsupp.mem_support_iff.mpr ( ne_of_gt ( hloop m hm ) ) ) )

/-! ## Section 6: Classification of Supports -/

/-
If all elements of a nonempty finset are zero, the finset is {0}.
-/
theorem eq_singleton_zero_of_forall_eq_zero {S : Finset (ι →₀ ℕ)}
    (hne : S.Nonempty) (h : ∀ m ∈ S, m = 0) :
    S = {0} := by
  exact Finset.eq_singleton_iff_nonempty_unique_mem.mpr ⟨ hne, h ⟩

/-
**Support classification theorem.** Every finite support is empty, trivial,
    or admits an ordinary or loop coordinate.
-/
theorem support_classification (S : Finset (ι →₀ ℕ)) :
    S = ∅ ∨ S = {(0 : ι →₀ ℕ)} ∨
    (∃ i, IsOrdinaryCoord S i) ∨ (∃ i, IsSupportLoop S i) := by
  by_cases h : ∀ m ∈ S, m = 0 <;> simp_all +decide [ IsOrdinaryCoord, IsSupportLoop ];
  · grind;
  · obtain ⟨ m, hm₁, hm₂ ⟩ := h; obtain ⟨ i, hi ⟩ := Finsupp.ne_iff.mp hm₂; by_cases hi' : ∃ m' ∈ S, m' i = 0 <;> simp_all +decide [ IsOrdinaryCoord, IsSupportLoop ] ;
    · exact Or.inr <| Or.inr <| Or.inl ⟨ i, hi', m, hm₁, Nat.pos_of_ne_zero hi ⟩;
    · exact Or.inr <| Or.inr <| Or.inr <| ⟨ i, fun m hm => Nat.pos_of_ne_zero <| hi' m hm ⟩

/-! ## Section 7: Well-Founded Recursion -/

/-- The support measure yields a well-founded relation. -/
theorem supportMeasure_wf :
    WellFounded (fun S T : Finset (ι →₀ ℕ) => supportMeasure S < supportMeasure T) :=
  InvImage.wf supportMeasure Nat.lt_wfRel.wf

/-! ## Section 8: Universality (Uniqueness of DC Invariants) -/

/-
**Universal Support-Tutte Theorem (Uniqueness).**
    Any two functions `f, g : Finset (ι →₀ ℕ) → R` satisfying:
    1. `f ∅ = g ∅ = 1`,
    2. `f {0} = g {0} = 1`,
    3. The ordinary deletion–contraction recurrence,
    4. The loop contraction rule with a common loop weight `a`,
    agree on all finite support sets.

    Proved by well-founded induction on `supportMeasure`.
-/
theorem dc_invariant_unique
    {R : Type*} [CommSemiring R] (a : R)
    (f g : Finset (ι →₀ ℕ) → R)
    (hf_empty : f ∅ = 1) (hg_empty : g ∅ = 1)
    (hf_zero : f {(0 : ι →₀ ℕ)} = 1) (hg_zero : g {(0 : ι →₀ ℕ)} = 1)
    (hf_ord : ∀ S i, IsOrdinaryCoord S i →
      f S = f (supportDelete S i) + f (tutteContract S i))
    (hg_ord : ∀ S i, IsOrdinaryCoord S i →
      g S = g (supportDelete S i) + g (tutteContract S i))
    (hf_loop : ∀ S i, IsSupportLoop S i → S.Nonempty →
      f S = a * f (tutteContract S i))
    (hg_loop : ∀ S i, IsSupportLoop S i → S.Nonempty →
      g S = a * g (tutteContract S i))
    (S : Finset (ι →₀ ℕ)) : f S = g S := by
  -- By definition of supportMeasure, we know that if S is nonempty, then supportMeasure S is strictly decreasing.
  have h_measure_decreasing : ∀ S : Finset (ι →₀ ℕ), S.Nonempty → ∀ i, IsOrdinaryCoord S i → supportMeasure (supportDelete S i) < supportMeasure S ∧ supportMeasure (tutteContract S i) < supportMeasure S := by
    intro S hS i hi
    have h_measure_delete : supportMeasure (supportDelete S i) < supportMeasure S := by
      refine' add_lt_add_of_le_of_lt _ _;
      · exact Finset.sum_le_sum_of_subset ( supportDelete_subset S i );
      · exact supportDelete_card_lt hi.2
    have h_measure_contract : supportMeasure (tutteContract S i) < supportMeasure S := by
      -- Since $i$ is ordinary, the total degree of the contracted support is less than or equal to the total degree of the original support.
      have h_totalDegree_contract : supportTotalDeg (tutteContract S i) ≤ supportTotalDeg S := by
        have h_totalDegree_contract : ∀ m ∈ S.filter (fun m => 0 < m i), (m - Finsupp.single i 1).sum (fun _ v => v) ≤ m.sum (fun _ v => v) := by
          simp +decide [ Finsupp.sum ];
          intro m hm hmi; refine' le_trans ( Finset.sum_le_sum_of_subset _ ) _;
          exact m.support;
          · intro j hj; contrapose! hj; simp_all +decide [ Finsupp.single_apply ] ;
          · exact Finset.sum_le_sum fun x hx => Nat.sub_le _ _;
        have h_totalDegree_contract : (Finset.image (fun m => m - Finsupp.single i 1) (S.filter (fun m => 0 < m i))).sum (fun m => m.sum (fun _ v => v)) ≤ (S.filter (fun m => 0 < m i)).sum (fun m => m.sum (fun _ v => v)) := by
          rw [ Finset.sum_image ];
          · exact Finset.sum_le_sum h_totalDegree_contract;
          · intro m hm m' hm' h_eq; simp_all +decide [ Finsupp.ext_iff ] ;
            grind;
        exact h_totalDegree_contract.trans ( Finset.sum_le_sum_of_subset ( Finset.filter_subset _ _ ) );
      exact add_lt_add_of_le_of_lt h_totalDegree_contract ( tutteContract_card_lt_of_ordinary hi.1 hi.2 )
    exact ⟨h_measure_delete, h_measure_contract⟩;
  induction' n : supportMeasure S using Nat.strong_induction_on with n ih generalizing S;
  by_cases hS : S = ∅ ∨ S = {0} ∨ ∃ i, IsOrdinaryCoord S i ∨ IsSupportLoop S i;
  · grind +suggestions;
  · have := support_classification S; aesop;

/-! ## Section 9: Partition Properties -/

/-
The filter for positive values and the filter for zero values partition S.
-/
theorem delete_positive_disjoint (S : Finset (ι →₀ ℕ)) (i : ι) :
    Disjoint (supportDelete S i) (S.filter (fun m => 0 < m i)) := by
  exact Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith;

/-
The union of the two filters recovers S.
-/
theorem delete_positive_union (S : Finset (ι →₀ ℕ)) (i : ι) :
    supportDelete S i ∪ S.filter (fun m => 0 < m i) = S := by
  grind +locals

/-
**Delete-contract partition bound.**
-/
theorem delete_contract_card_bound (S : Finset (ι →₀ ℕ)) (i : ι) :
    (supportDelete S i).card + (S.filter (fun m => 0 < m i)).card = S.card := by
  rw [ ← Finset.card_union_of_disjoint ( delete_positive_disjoint S i ), delete_positive_union ]

/-! ## Section 10: Bridge to Matroid Theory -/

/-- A support is **{0,1}-valued** (matroidal) if every coordinate value is 0 or 1. -/
def IsBinarySupport (S : Finset (ι →₀ ℕ)) : Prop :=
  ∀ m ∈ S, ∀ i : ι, m i = 0 ∨ m i = 1

/-
For binary supports, an ordinary coordinate corresponds to a matroid-theoretic
    ordinary element: one present in some but not all support members.
-/
omit [DecidableEq ι] in
theorem matroid_indicator_ordinary_iff {S : Finset (ι →₀ ℕ)} {i : ι}
    (hbin : IsBinarySupport S) (_hne : S.Nonempty) :
    IsOrdinaryCoord S i ↔
      (∃ m ∈ S, m i = 0) ∧ (∃ m ∈ S, m i = 1) := by
  constructor <;> intro h;
  · exact ⟨ h.1, by obtain ⟨ m, hm₁, hm₂ ⟩ := h.2; exact ⟨ m, hm₁, Or.resolve_left ( hbin m hm₁ i ) ( ne_of_gt hm₂ ) ⟩ ⟩;
  · exact ⟨ h.1, by obtain ⟨ m, hm₁, hm₂ ⟩ := h.2; exact ⟨ m, hm₁, hm₂.symm ▸ by decide ⟩ ⟩

/-
For binary supports, Tutte contraction at coordinate i keeps elements
    with m(i) = 1 and reduces their i-value to 0.
-/
theorem binary_tutteContract_filter {S : Finset (ι →₀ ℕ)} {i : ι}
    (hbin : IsBinarySupport S) :
    tutteContract S i =
      (S.filter (fun m => m i = 1)).image (fun m => m - Finsupp.single i 1) := by
  ext m;
  simp [tutteContract];
  grind +locals

/-
**Binary support deletion produces binary support.**
-/
theorem isBinarySupport_supportDelete {S : Finset (ι →₀ ℕ)} {i : ι}
    (hbin : IsBinarySupport S) :
    IsBinarySupport (supportDelete S i) := by
  exact fun m hm => hbin m ( mem_supportDelete_iff.mp hm |>.1 )

/-
**Binary support contraction produces binary support.**
-/
theorem isBinarySupport_tutteContract {S : Finset (ι →₀ ℕ)} {i : ι}
    (hbin : IsBinarySupport S) :
    IsBinarySupport (tutteContract S i) := by
  intro x hx
  obtain ⟨m, hm⟩ := Finset.mem_image.mp hx;
  intro j; by_cases hj : j = i <;> simp_all +decide [ Finsupp.single_apply ] ;
  · cases hbin m hm.1.1 i <;> aesop;
  · rw [ ← hm.2, Finsupp.tsub_apply ] ; aesop

/-! ## Section 11: Activity Counting -/

/-- Count loop coordinates within a ground set. -/
noncomputable def loopCount (S : Finset (ι →₀ ℕ)) (ground : Finset ι) : ℕ :=
  (ground.filter (fun i => ∀ m ∈ S, 0 < m i)).card

/-- Count ordinary coordinates within a ground set. -/
noncomputable def ordinaryCount (S : Finset (ι →₀ ℕ)) (ground : Finset ι) : ℕ :=
  (ground.filter (fun i => (∃ m ∈ S, m i = 0) ∧ (∃ m ∈ S, 0 < m i))).card

/-- Count trivial coordinates (all zero) within a ground set. -/
noncomputable def trivialCount (S : Finset (ι →₀ ℕ)) (ground : Finset ι) : ℕ :=
  (ground.filter (fun i => ∀ m ∈ S, m i = 0)).card

/-
**Activity partition.** Coordinates in any ground set partition into
    loops, ordinary, and trivial.
-/
theorem activity_partition (S : Finset (ι →₀ ℕ)) (ground : Finset ι) (hne : S.Nonempty) :
    loopCount S ground + ordinaryCount S ground + trivialCount S ground = ground.card := by
  unfold loopCount ordinaryCount trivialCount;
  rw [ ← Finset.card_union_of_disjoint, ← Finset.card_union_of_disjoint ] <;> congr <;> simp +contextual [ Finset.disjoint_left ];
  · grind +ring;
  · grind;
  · exact fun i hi hi' x hx hx' y hy => by linarith [ hi' x hx ] ;

end UniversalSupportTutte