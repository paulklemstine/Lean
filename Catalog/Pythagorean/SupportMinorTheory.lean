/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Deletion–Contraction Duality for Polynomial Supports

This file develops a minor theory for polynomial support sets equipped with
the symmetric exchange property (M-convexity). We define support deletion and
contraction, prove that both preserve exchange, and establish a minor calculus
analogous to matroid theory but at the level of exponent sets of polynomials.

## Main Definitions

* `SupportExchange` — Symmetric exchange property for support sets
* `supportDelete` — Deletion of coordinate i
* `supportDeleteMulti` — Deletion of a set of coordinates
* `supportContract` — Contraction at coordinate i
* `IsSupportLoop` — Coordinate i is a support loop
* `IsSupportColoop` — Coordinate i is a support coloop
* `SupportMinorStep` — Single deletion or contraction step
* `SupportMinor` — Reflexive-transitive closure of minor steps

## Main Results

* `exchange_of_deletion` — Deletion preserves exchange
* `exchange_of_contraction` — Contraction preserves exchange
* `exchange_of_multi_deletion` — Multi-coordinate deletion preserves exchange
* `exchange_of_minor` — Exchange is closed under arbitrary minors

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finset BigOperators Finsupp

namespace SupportMinorTheory

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

/-- **Support multi-deletion**: retain only elements vanishing on all coordinates in A. -/
def supportDeleteMulti (S : Finset (ι →₀ ℕ)) (A : Finset ι) : Finset (ι →₀ ℕ) :=
  S.filter (fun m => ∀ j ∈ A, m j = 0)

/-- Minimum value of coordinate i across a nonempty support. -/
noncomputable def minCoord (S : Finset (ι →₀ ℕ)) (i : ι) : ℕ :=
  if h : S.Nonempty then S.inf' h (fun m => m i) else 0

/-- **Support contraction** at coordinate i: filter to elements achieving the
    minimum i-value, then shift down by that minimum. -/
noncomputable def supportContract (S : Finset (ι →₀ ℕ)) (i : ι) : Finset (ι →₀ ℕ) :=
  (S.filter (fun m => m i = minCoord S i)).image
    (fun m => m - Finsupp.single i (minCoord S i))

/-- A coordinate i is a **support loop** if every element has positive i-value. -/
def IsSupportLoop (S : Finset (ι →₀ ℕ)) (i : ι) : Prop :=
  ∀ m ∈ S, m i > 0

/-- A coordinate i is a **support coloop** if all elements share the same i-value. -/
def IsSupportColoop (S : Finset (ι →₀ ℕ)) (i : ι) : Prop :=
  ∃ v, ∀ m ∈ S, m i = v

/-- Single-step minor relation: one deletion or one contraction. -/
inductive SupportMinorStep :
    Finset (ι →₀ ℕ) → Finset (ι →₀ ℕ) → Prop
  | delete (S : Finset (ι →₀ ℕ)) (i : ι) :
      SupportMinorStep S (supportDelete S i)
  | contract (S : Finset (ι →₀ ℕ)) (i : ι) :
      SupportMinorStep S (supportContract S i)

/-- A support T is a **minor** of S if T can be obtained from S by a sequence
    of deletions and contractions. -/
def SupportMinor :
    Finset (ι →₀ ℕ) → Finset (ι →₀ ℕ) → Prop :=
  Relation.ReflTransGen (fun S T => SupportMinorStep S T)

/-! ## Section 2: Basic Lemmas -/

theorem supportDelete_subset (S : Finset (ι →₀ ℕ)) (i : ι) :
    supportDelete S i ⊆ S :=
  Finset.filter_subset _ _

theorem mem_supportDelete_iff {S : Finset (ι →₀ ℕ)} {i : ι} {m : ι →₀ ℕ} :
    m ∈ supportDelete S i ↔ m ∈ S ∧ m i = 0 :=
  Finset.mem_filter

theorem supportDelete_card_le (S : Finset (ι →₀ ℕ)) (i : ι) :
    (supportDelete S i).card ≤ S.card :=
  Finset.card_filter_le S _

theorem supportDeleteMulti_empty (S : Finset (ι →₀ ℕ)) :
    supportDeleteMulti S ∅ = S := by
  simp [supportDeleteMulti]

theorem supportDeleteMulti_singleton (S : Finset (ι →₀ ℕ)) (i : ι) :
    supportDeleteMulti S {i} = supportDelete S i := by
  ext m; simp [supportDeleteMulti, supportDelete, Finset.mem_filter]

theorem supportDelete_loop_empty {S : Finset (ι →₀ ℕ)} {i : ι}
    (hloop : IsSupportLoop S i) :
    supportDelete S i = ∅ := by
  rw [Finset.eq_empty_iff_forall_notMem]
  intro m hm
  rw [mem_supportDelete_iff] at hm
  exact absurd (hloop m hm.1) (by omega)

/-- Exchange is trivially satisfied by the empty set. -/
theorem exchange_empty : SupportExchange (∅ : Finset (ι →₀ ℕ)) := by
  intro x hx; simp at hx

/-- Exchange is trivially satisfied by singletons. -/
theorem exchange_singleton (m : ι →₀ ℕ) : SupportExchange ({m} : Finset (ι →₀ ℕ)) := by
  intro x hx y hy a ha
  rw [Finset.mem_singleton] at hx hy
  subst hx; subst hy
  exact absurd ha (lt_irrefl _)

/-! ## Section 3: Auxiliary Finsupp Arithmetic -/

/-- Key arithmetic lemma: if m(i) = 0 and a ≠ i and b ≠ i, then
    (m - single a 1 + single b 1)(i) = 0. -/
theorem exchange_result_coord_zero
    {m : ι →₀ ℕ} {i a b : ι} (hmi : m i = 0) (hai : a ≠ i) (hbi : b ≠ i) :
    (m - Finsupp.single a 1 + Finsupp.single b 1 : ι →₀ ℕ) i = 0 := by
  simp [Finsupp.add_apply, Finsupp.tsub_apply, hai, hbi, hmi]

/-- Symmetric version: (m + single a 1 - single b 1)(i) = 0 under the same conditions. -/
theorem exchange_result_coord_zero'
    {m : ι →₀ ℕ} {i a b : ι} (hmi : m i = 0) (hai : a ≠ i) (hbi : b ≠ i) :
    (m + Finsupp.single a 1 - Finsupp.single b 1 : ι →₀ ℕ) i = 0 := by
  simp [Finsupp.add_apply, Finsupp.tsub_apply, hai, hbi, hmi]

/-! ## Section 4: Deletion Preserves Exchange (Theorem 1) -/

/-- **Theorem 1 (Deletion preserves exchange).**
    If S satisfies the symmetric exchange property, then for any coordinate i,
    the deletion D_i(S) = {m ∈ S : m(i) = 0} also satisfies exchange.

    The proof uses the key observation that if x(i) = y(i) = 0,
    then neither a = i (which would require x(i) > y(i)) nor b = i
    (which would require y(i) > x(i)) can occur, so the exchange
    results preserve the zero i-coordinate. -/
theorem exchange_of_deletion
    (S : Finset (ι →₀ ℕ)) (i : ι)
    (hS : SupportExchange S) :
    SupportExchange (supportDelete S i) := by
  intro x hx y hy a hxa
  rw [mem_supportDelete_iff] at hx hy
  obtain ⟨hxS, hxi⟩ := hx
  obtain ⟨hyS, hyi⟩ := hy
  obtain ⟨b, hb_gt, hb_x, hb_y⟩ := hS x hxS y hyS a hxa
  have hai : a ≠ i := by intro h; subst h; omega
  have hbi : b ≠ i := by intro h; subst h; omega
  exact ⟨b, hb_gt,
    mem_supportDelete_iff.mpr ⟨hb_x, exchange_result_coord_zero hxi hai hbi⟩,
    mem_supportDelete_iff.mpr ⟨hb_y, exchange_result_coord_zero' hyi hai hbi⟩⟩

/-! ## Section 5: Contraction Preserves Exchange -/

/-
**Contraction preserves exchange.**
    If S satisfies exchange, then the contraction C_i(S) also satisfies exchange.

    The proof lifts elements from the contraction to their pre-images in S (which
    all share the same i-coordinate = minCoord), applies exchange in S, and
    observes that a ≠ i and b ≠ i by the same argument as deletion,
    so the exchange results also have i-coordinate = minCoord and map correctly
    under the contraction projection.
-/
theorem exchange_of_contraction
    (S : Finset (ι →₀ ℕ)) (i : ι)
    (hS : SupportExchange S)
    (hne : S.Nonempty) :
    SupportExchange (supportContract S i) := by
      intro x y hy a ha;
      -- Let $x'$ and $y'$ be preimages of $x$ and $y$ in $S$ such that $x' i = y' i = minCoord S i$.
      obtain ⟨x', hx', hx_eq⟩ : ∃ x' ∈ S, x' i = minCoord S i ∧ x = x' - Finsupp.single i (minCoord S i) := by
        unfold supportContract at y; aesop;
      obtain ⟨y', hy', hy_eq⟩ : ∃ y' ∈ S, y' i = minCoord S i ∧ hy = y' - Finsupp.single i (minCoord S i) := by
        unfold supportContract at a; aesop;
      rcases eq_or_ne ha i with rfl | hai <;> simp_all +decide [ Finsupp.single_apply ];
      intro hxy
      obtain ⟨b, hb₁, hb₂, hb₃⟩ := hS x' hx' y' hy' ha (by
      exact hxy);
      refine' ⟨ b, _, _, _ ⟩ <;> simp_all +decide [ supportContract ];
      · split_ifs <;> simp_all +decide [ Finsupp.single_apply ];
      · refine' ⟨ _, ⟨ hb₂, _ ⟩, _ ⟩ <;> simp_all +decide [ Finsupp.ext_iff ];
        · grind +suggestions;
        · grind +splitImp;
      · refine' ⟨ _, ⟨ hb₃, _ ⟩, _ ⟩;
        · rw [ Finsupp.tsub_apply, Finsupp.add_apply, Finsupp.single_apply, Finsupp.single_apply ] ; aesop;
        · ext j ; by_cases hj : j = i <;> by_cases hj' : j = ha <;> by_cases hj'' : j = b <;> simp +decide [ *, Finsupp.single_apply ];
          grind

/-! ## Section 6: Multi-Deletion Preserves Exchange (Theorem 2) -/

/-- Multi-deletion can be decomposed via insertion. -/
theorem supportDeleteMulti_insert (S : Finset (ι →₀ ℕ)) (A : Finset ι) (i : ι)
    (hi : i ∉ A) :
    supportDeleteMulti S (insert i A) = supportDelete (supportDeleteMulti S A) i := by
  ext m
  simp only [supportDeleteMulti, supportDelete, Finset.mem_filter]
  constructor
  · intro ⟨hm, hall⟩
    exact ⟨⟨hm, fun j hj => hall j (Finset.mem_insert_of_mem hj)⟩,
           hall i (Finset.mem_insert_self i A)⟩
  · intro ⟨⟨hm, hall⟩, hmi⟩
    exact ⟨hm, fun j hj => by
      rcases Finset.mem_insert.mp hj with rfl | hj
      · exact hmi
      · exact hall j hj⟩

/-
**Theorem 2 (Multi-deletion preserves exchange).**
    Proof by induction on A, using `exchange_of_deletion` at each step.
-/
theorem exchange_of_multi_deletion
    (S : Finset (ι →₀ ℕ)) (A : Finset ι)
    (hS : SupportExchange S) :
    SupportExchange (supportDeleteMulti S A) := by
      induction' A using Finset.induction with i A hi ih generalizing S;
      · -- In the base case, when A is empty, supportDeleteMulti S ∅ is just S itself.
        simp [supportDeleteMulti_empty, hS];
      · rw [ supportDeleteMulti_insert _ _ _ hi ];
        exact exchange_of_deletion _ _ ( ih _ hS )

/-! ## Section 7: Exchange Closed Under Minors (Theorem 3) -/

/-- Exchange is preserved by a single minor step. -/
theorem exchange_of_minor_step
    {S T : Finset (ι →₀ ℕ)}
    (hS : SupportExchange S)
    (hne : S.Nonempty)
    (hST : SupportMinorStep S T) :
    SupportExchange T := by
  cases hST with
  | delete i => exact exchange_of_deletion _ i hS
  | contract i => exact exchange_of_contraction _ i hS hne

/-
**Theorem 3 (Exchange is closed under minors).**
    If S has exchange and T is a minor of S, then T has exchange.
-/
theorem exchange_of_minor
    {S T : Finset (ι →₀ ℕ)}
    (hS : SupportExchange S)
    (_hne : S.Nonempty)
    (hST : SupportMinor S T) :
    SupportExchange T := by
      induction' hST with S T hST ih;
      · exact hS;
      · -- If S is empty, then T must also be empty.
        by_cases hS_empty : S = ∅;
        · cases ih <;> aesop;
        · exact exchange_of_minor_step ‹_› ( Finset.nonempty_of_ne_empty hS_empty ) ih

/-! ## Section 8: Cardinality Bounds -/

/-
Deletion at a coordinate where some element is positive strictly reduces cardinality.
-/
theorem supportDelete_card_lt {S : Finset (ι →₀ ℕ)} {i : ι}
    (hexists_pos : ∃ m ∈ S, m i > 0) :
    (supportDelete S i).card < S.card := by
      exact Finset.card_lt_card ( Finset.filter_ssubset.2 <| by aesop )

/-
Contraction does not increase cardinality.
-/
theorem supportContract_card_le (S : Finset (ι →₀ ℕ)) (i : ι) :
    (supportContract S i).card ≤ S.card := by
      exact Finset.card_image_le.trans ( Finset.card_le_card ( Finset.filter_subset _ _ ) )

/-! ## Section 9: Loop and Coloop Characterizations -/

theorem loop_iff_delete_empty {S : Finset (ι →₀ ℕ)} {i : ι} :
    IsSupportLoop S i ↔ supportDelete S i = ∅ := by
  constructor
  · exact fun h => supportDelete_loop_empty h
  · intro h m hm
    by_contra hc
    push_neg at hc
    have : m ∈ supportDelete S i := mem_supportDelete_iff.mpr ⟨hm, by omega⟩
    simp [h] at this

theorem coloop_contract_eq_card {S : Finset (ι →₀ ℕ)} {i : ι}
    (hcl : IsSupportColoop S i) (hne : S.Nonempty) :
    (supportContract S i).card = S.card := by
      rw [ supportContract, Finset.card_image_of_injOn ];
      · rw [ Finset.filter_true_of_mem ];
        obtain ⟨ v, hv ⟩ := hcl;
        unfold minCoord;
        aesop;
      · intro m hm n hn hmn; simp_all +decide [ Finsupp.ext_iff ] ;
        intro a; specialize hmn a; by_cases ha : a = i <;> simp_all +decide ;

/-! ## Section 10: Cross-Domain Bridge — Matroid Basis Supports -/

/-- A matroid-induced support from basis indicator vectors. -/
noncomputable def matroidBasisSupport {n : ℕ} (bases : Finset (Finset (Fin n))) :
    Finset (Fin n →₀ ℕ) :=
  bases.image (fun B => B.sum (fun j => Finsupp.single j 1))

/-! ## Section 11: Tutte-Type Recurrence Framework -/

/-- A **support-Tutte invariant** is a function from exchange supports to ℤ
    that satisfies the deletion–contraction recurrence. -/
structure SupportTutteInvariant where
  val : {S : Finset (ι →₀ ℕ) // SupportExchange S} → ℤ
  empty_val : val ⟨∅, exchange_empty⟩ = 1
  recurrence : ∀ (S : Finset (ι →₀ ℕ)) (hS : SupportExchange S)
    (i : ι) (hne : S.Nonempty)
    (_hreg : ¬ IsSupportLoop S i),
    val ⟨S, hS⟩ = val ⟨supportDelete S i, exchange_of_deletion S i hS⟩ +
      val ⟨supportContract S i, exchange_of_contraction S i hS hne⟩

/-
Minor steps do not increase cardinality: deletion and contraction
    both produce sets of size ≤ |S|.
-/
theorem minor_step_card_le {S T : Finset (ι →₀ ℕ)}
    (hST : SupportMinorStep S T) :
    T.card ≤ S.card := by
      cases hST <;> [ exact supportDelete_card_le S _; exact supportContract_card_le S _ ]

end SupportMinorTheory