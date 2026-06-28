import Mathlib

/-!
# Frankl's Union-Closed Sets Conjecture: core formalization and partial results

A finite family of finite sets `F` is **union-closed** when `A ∪ B ∈ F` whenever
`A, B ∈ F`.  **Frankl's conjecture** asserts that every union-closed family
containing a nonempty set has an *abundant* element: some `x` lying in at least
half of the members of `F`.

This file develops the core definitions and proves several genuine partial
results, the centerpiece being:

* `frankl_singleton` — if a union-closed family contains a **singleton** `{a}`,
  then `a` is abundant.  This is the classical injection argument: `A ↦ A ∪ {a}`
  injects the sets avoiding `a` into the sets containing `a`.

We also prove the lattice/order infrastructure (`sup_mem` — a nonempty
union-closed family contains its top element) and assemble the existence form of
the conjecture in the singleton case.

-- !-- Lab Notes -- !--
Hypothesis (H1): The singleton case of Frankl is provable by an explicit
injection `A ↦ insert a A`.  Surprising sub-claim (H2): the *existence* of a top
element (union of all members) holds for any nonempty union-closed family with no
extra hypotheses — it is a pure semilattice fact.
Experiment: formalized both; H1 via `Finset.card_le_card_of_injOn`, H2 via
`Finset.induction`.
-/

namespace Catalog.Novelty.Frankl

open Finset

variable {α : Type*} [DecidableEq α]

/-- A family of finite sets is *union-closed* if it is closed under binary unions. -/
def IsUnionClosed (F : Finset (Finset α)) : Prop :=
  ∀ A ∈ F, ∀ B ∈ F, A ∪ B ∈ F

/-- The sub-family of members of `F` that contain `x`. -/
def containing (F : Finset (Finset α)) (x : α) : Finset (Finset α) :=
  F.filter (fun A => x ∈ A)

/-- `x` is *abundant* in `F` when it belongs to at least half of the members. -/
def Abundant (F : Finset (Finset α)) (x : α) : Prop :=
  F.card ≤ 2 * (containing F x).card

/-- Frankl's conjecture, stated for a single family `F`: there is an element of
some member that is abundant. -/
def FranklProperty (F : Finset (Finset α)) : Prop :=
  ∃ x, (∃ A ∈ F, x ∈ A) ∧ Abundant F x

/-
Counting split: the members of `F` are partitioned by whether they contain `x`.
-/
lemma card_split (F : Finset (Finset α)) (x : α) :
    F.card = (containing F x).card + (F.filter (fun A => x ∉ A)).card := by
  erw [ Finset.card_filter, Finset.card_filter ];
  simpa only [ ← Finset.sum_add_distrib ] using Finset.card_eq_sum_ones F ▸ by congr; ext; aesop;

/-
**Centerpiece.**  If a union-closed family contains the singleton `{a}`, then
`a` is abundant.  Proof: `A ↦ insert a A` injects `{A ∈ F : a ∉ A}` into
`{A ∈ F : a ∈ A}` (it stays in `F` by union-closure with `{a}`), so the latter is
at least as large as the former, giving `|F| ≤ 2·|containing F a|`.
-/
theorem frankl_singleton (F : Finset (Finset α)) (hF : IsUnionClosed F)
    (a : α) (ha : ({a} : Finset α) ∈ F) : Abundant F a := by
  -- Let S = F.filter (fun A => a ∉ A) (sets avoiding a) and T = containing F a = F.filter (fun A => a ∈ A) (sets containing a).
  set S := F.filter (fun A => a ∉ A)
  set T := containing F a;
  -- Step 1: Show that S and T are disjoint and their union is F.
  have h_disjoint : Disjoint S T := by
    exact Finset.disjoint_filter.2 fun _ _ _ _ => by tauto;
  have h_union : S ∪ T = F := by
    grind +locals;
  -- Step 2: Show that the function $f: S \to T$ defined by $f(A) = A \cup \{a\}$ is injective.
  have h_inj : (S.image (fun A => A ∪ {a})) ⊆ T := by
    grind +locals
  have h_card : S.card ≤ T.card := by
    convert Finset.card_le_card h_inj using 1;
    rw [ Finset.card_image_of_injOn ] ; intro A hA B hB hAB ; simp_all +decide [ Finset.ext_iff ];
    grind +ring
  generalize_proofs at *; (
  exact le_trans ( by rw [ ← h_union, Finset.card_union_of_disjoint h_disjoint ] ) ( by linarith ) ;);

/-- If `F` is nonempty and `x` is abundant, then `x` already witnesses
`FranklProperty`: abundance forces `containing F x` to be nonempty, so some member
of `F` contains `x`. -/
lemma franklProperty_of_abundant (F : Finset (Finset α)) (hne : F.Nonempty)
    (x : α) (hx : Abundant F x) : FranklProperty F := by
  have hcard : 1 ≤ (containing F x).card := by
    rcases Nat.eq_zero_or_pos (containing F x).card with h | h
    · have : F.card ≤ 0 := by simpa [Abundant, h] using hx
      exact absurd (hne.card_pos) (by omega)
    · exact h
  obtain ⟨A, hA⟩ := Finset.card_pos.1 hcard
  rw [containing, Finset.mem_filter] at hA
  exact ⟨x, ⟨A, hA.1, hA.2⟩, hx⟩

/-- Existence form of Frankl's conjecture in the singleton case. -/
theorem franklProperty_of_singleton_mem (F : Finset (Finset α))
    (hF : IsUnionClosed F) (a : α) (ha : ({a} : Finset α) ∈ F) :
    FranklProperty F := by
  refine ⟨a, ⟨{a}, ha, mem_singleton_self a⟩, frankl_singleton F hF a ha⟩

/-
A nonempty union-closed family contains its **top element** `F.sup id`, the
union of all its members.  This is the order-theoretic content: `(F, ⊆)` is a
finite join-semilattice with a greatest element lying in `F`.
-/
theorem sup_mem (F : Finset (Finset α)) (hF : IsUnionClosed F) (hne : F.Nonempty) :
    F.sup id ∈ F := by
  obtain ⟨ x, hx ⟩ := hne;
  have h_sup_mem : ∀ (s : Finset (Finset α)), s.Nonempty → s ⊆ F → s.sup id ∈ F := by
    intro s hs ss; induction hs using Finset.Nonempty.cons_induction <;> simp_all +decide [ Finset.sup_insert ] ;
    exact hF _ ( ss ( Finset.mem_insert_self _ _ ) ) _ ( by apply_assumption; exact Finset.Subset.trans ( Finset.subset_insert _ _ ) ss );
  exact h_sup_mem F ⟨ x, hx ⟩ Finset.Subset.rfl

end Catalog.Novelty.Frankl