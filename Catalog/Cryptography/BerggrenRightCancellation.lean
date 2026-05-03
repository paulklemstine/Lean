import Mathlib
import Cryptography.Freeness

/-!
# Berggren Semigroup Right-Cancellation and Right-Ideal Structure

## Overview

We develop the right-cancellation theory and principal right-ideal structure
for the Berggren free semigroup on three generators `A, B, C`, building on
the freeness / unique-normal-form theorem in `Cryptography.Freeness`.

The key insight is that freeness of the Berggren semigroup (injectivity of
`evalTriple`) upgrades to a complete right-divisibility theory: right
cancellation holds, and common right multiples exist if and only if the
normal forms of the two elements are prefix-comparable.

## Main Results

* `evalWord_right_cancel_iff` — word-level right cancellation (iff form)
* `prefixComparable_of_append_eq_append` — list-level prefix overlap lemma
* `exists_common_right_multiple_iff` — common right multiples ↔ prefix comparability
* `wordRightIdeal_inter_nonempty_iff` — right ideal intersection characterization
* `wordRightIdeal_inter_eq_of_prefix` — exact description of right ideal intersections
* `semigroup_right_cancel'` — semigroup-level right cancellation
* `tripleRightIdeal_inter_nonempty_iff` — triple-level right ideal intersection

## Proof Strategy

All results are reduced to word-level combinatorics via the `evalTriple` injection.
The decisive bridge is that `evalTriple` is injective (the freeness theorem), so
list-level cancellation and prefix structure transfer to the semigroup level.

## Cryptographic Significance

For SPB-based key exchange, right cancellation gives **collision rigidity**:
appending a common secret suffix cannot create or hide collisions among public
semigroup elements. The right-ideal intersection theorem reduces shared-secret
existence to a syntactic prefix test on normal forms.
-/

open List

/-! ## Prefix Comparability -/

/-- Two lists are *prefix comparable* if one is a prefix of the other.
This is the key combinatorial condition characterizing when two Berggren
semigroup elements share a common right multiple. -/
def PrefixComparable {α : Type*} (u v : List α) : Prop :=
  u <+: v ∨ v <+: u

@[symm]
theorem PrefixComparable.symm {α : Type*} {u v : List α}
    (h : PrefixComparable u v) : PrefixComparable v u :=
  Or.symm h

theorem PrefixComparable.rfl {α : Type*} {u : List α} :
    PrefixComparable u u :=
  Or.inl (prefix_refl u)

theorem prefixComparable_comm {α : Type*} {u v : List α} :
    PrefixComparable u v ↔ PrefixComparable v u :=
  Or.comm

/-! ## Core List Combinatorics -/

/-- **Prefix overlap lemma**: If `a ++ b = c ++ d`, then `a` and `c` are
prefix comparable. This is the fundamental combinatorial fact underlying
the common-right-multiple characterization. -/
theorem prefixComparable_of_append_eq_append
    {α : Type*} {a b c d : List α}
    (h : a ++ b = c ++ d) :
    PrefixComparable a c := by
  have h1 : a <+: a ++ b := prefix_append a b
  have h2 : c <+: c ++ d := prefix_append c d
  rw [h] at h1
  exact prefix_or_prefix_of_prefix h1 h2

/-! ## Right Cancellation at Word Level -/

/-- **Right cancellation (iff form)** at the word level:
`evalTriple (v ++ u) = evalTriple (w ++ u)` if and only if `v = w`. -/
theorem evalWord_right_cancel_iff
    {u v w : BergWord} :
    evalTriple (v ++ u) = evalTriple (w ++ u) ↔ v = w :=
  ⟨fun h => berggren_right_cancel h, fun h => by rw [h]⟩

/-- **Left cancellation (iff form)** at the word level. -/
theorem evalWord_left_cancel_iff
    {u v w : BergWord} :
    evalTriple (u ++ v) = evalTriple (u ++ w) ↔ v = w :=
  ⟨fun h => berggren_left_cancel h, fun h => by rw [h]⟩

/-! ## The normalForm Map -/

open Classical in
/-- The normal form of a Berggren semigroup element: the unique word that evaluates
to the given triple. For triples outside the semigroup, returns `[]` (the root). -/
noncomputable def normalForm (t : ℤ × ℤ × ℤ) : BergWord :=
  if h : t ∈ BergSemigroup then h.choose else []


/-- The normal form of an element in the semigroup evaluates back to that element. -/
theorem eval_normalForm {t : ℤ × ℤ × ℤ} (ht : t ∈ BergSemigroup) :
    evalTriple (normalForm t) = t := by
  unfold normalForm; rw [dif_pos ht]; exact ht.choose_spec

/-- Every word is the normal form of its evaluation. -/
theorem normalForm_eval (w : BergWord) :
    normalForm (evalTriple w) = w := by
  have hmem : evalTriple w ∈ BergSemigroup := ⟨w, rfl⟩
  exact berggren_eval_injective (eval_normalForm hmem)

/-- Equal normal forms imply equal triples (within the semigroup). -/
theorem eq_of_normalForm_eq {t₁ t₂ : ℤ × ℤ × ℤ}
    (ht₁ : t₁ ∈ BergSemigroup) (ht₂ : t₂ ∈ BergSemigroup)
    (h : normalForm t₁ = normalForm t₂) : t₁ = t₂ := by
  calc t₁ = evalTriple (normalForm t₁) := (eval_normalForm ht₁).symm
    _ = evalTriple (normalForm t₂) := by rw [h]
    _ = t₂ := eval_normalForm ht₂

/-! ## Semigroup-Level Right Cancellation -/

/-- **Semigroup-level right cancellation**: if two products with a common
right factor are equal, then the left factors are equal.
Here we express products via word concatenation and `evalTriple`. -/
theorem semigroup_right_cancel'
    {t₁ t₂ t₃ : ℤ × ℤ × ℤ}
    (ht₁ : t₁ ∈ BergSemigroup) (ht₂ : t₂ ∈ BergSemigroup)
    (_ht₃ : t₃ ∈ BergSemigroup)
    (h : evalTriple (normalForm t₁ ++ normalForm t₃) =
         evalTriple (normalForm t₂ ++ normalForm t₃)) :
    t₁ = t₂ :=
  eq_of_normalForm_eq ht₁ ht₂ (berggren_right_cancel h)

/-! ## Principal Right Ideals -/

/-- The principal right ideal of a word `w`: all words of the form `w ++ z`. -/
def wordRightIdeal (w : BergWord) : Set BergWord :=
  {v | ∃ z : BergWord, v = w ++ z}

theorem mem_wordRightIdeal_self (w : BergWord) : w ∈ wordRightIdeal w :=
  ⟨[], by simp⟩

theorem mem_wordRightIdeal_append (w z : BergWord) :
    w ++ z ∈ wordRightIdeal w :=
  ⟨z, rfl⟩

/-! ## Common Right Multiples and Prefix Comparability -/

/-- **Forward direction**: If two words share a common right multiple, then they
are prefix comparable. -/
theorem prefixComparable_of_common_right_multiple
    {u v : BergWord}
    (h : ∃ z₁ z₂ : BergWord, evalTriple (u ++ z₁) = evalTriple (v ++ z₂)) :
    PrefixComparable u v := by
  obtain ⟨z₁, z₂, heq⟩ := h
  exact prefixComparable_of_append_eq_append (berggren_eval_injective heq)

/-- **Backward direction**: If two words are prefix comparable, they share a
common right multiple. -/
theorem common_right_multiple_of_prefixComparable
    {u v : BergWord}
    (h : PrefixComparable u v) :
    ∃ z₁ z₂ : BergWord, u ++ z₁ = v ++ z₂ := by
  rcases h with ⟨t, ht⟩ | ⟨t, ht⟩
  · exact ⟨t, [], by simp [ht]⟩
  · exact ⟨[], t, by simp [ht]⟩

/-- **Common right multiple characterization (iff)**: Two words share a common
right multiple in the free semigroup iff they are prefix comparable. -/
theorem exists_common_right_multiple_iff
    (u v : BergWord) :
    (∃ z₁ z₂ : BergWord, evalTriple (u ++ z₁) = evalTriple (v ++ z₂)) ↔
      PrefixComparable u v :=
  ⟨prefixComparable_of_common_right_multiple,
   fun h => let ⟨z₁, z₂, heq⟩ := common_right_multiple_of_prefixComparable h
            ⟨z₁, z₂, by rw [heq]⟩⟩

/-! ## Right Ideal Subset and Intersection (Word Level) -/

/-- If `u` is a prefix of `v`, then the right ideal of `v` is contained in
the right ideal of `u`. -/
theorem wordRightIdeal_subset_of_prefix
    {u v : BergWord}
    (h : u <+: v) :
    wordRightIdeal v ⊆ wordRightIdeal u := by
  obtain ⟨t, ht⟩ := h
  intro w ⟨z, hz⟩
  exact ⟨t ++ z, by rw [hz, ← ht, append_assoc]⟩

/-- If `u` is a prefix of `v`, the right ideal intersection equals the right
ideal of the longer word `v`. -/
theorem wordRightIdeal_inter_eq_of_prefix
    {u v : BergWord}
    (h : u <+: v) :
    wordRightIdeal u ∩ wordRightIdeal v = wordRightIdeal v :=
  Set.inter_eq_right.mpr (wordRightIdeal_subset_of_prefix h)

/-- Symmetric version: if `v` is a prefix of `u`. -/
theorem wordRightIdeal_inter_eq_of_prefix'
    {u v : BergWord}
    (h : v <+: u) :
    wordRightIdeal u ∩ wordRightIdeal v = wordRightIdeal u := by
  rw [Set.inter_comm, wordRightIdeal_inter_eq_of_prefix h]

/-- The right ideal intersection is nonempty iff the words are prefix comparable. -/
theorem wordRightIdeal_inter_nonempty_iff
    (u v : BergWord) :
    (wordRightIdeal u ∩ wordRightIdeal v).Nonempty ↔
      PrefixComparable u v := by
  constructor
  · rintro ⟨w, ⟨z₁, hz₁⟩, z₂, hz₂⟩
    have : u ++ z₁ = v ++ z₂ := by rw [← hz₁, hz₂]
    exact prefixComparable_of_append_eq_append this
  · intro h
    rcases h with ⟨t, ht⟩ | ⟨t, ht⟩
    · exact ⟨v, wordRightIdeal_subset_of_prefix ⟨t, ht⟩ (mem_wordRightIdeal_self v),
             mem_wordRightIdeal_self v⟩
    · exact ⟨u, mem_wordRightIdeal_self u,
             wordRightIdeal_subset_of_prefix ⟨t, ht⟩ (mem_wordRightIdeal_self u)⟩

/-! ## Canonical Intersection Theorem -/

/-- **Canonical intersection theorem**: When two words are prefix comparable,
their right ideal intersection is the principal right ideal of the longer word. -/
theorem wordRightIdeal_inter_principal
    {u v : BergWord}
    (h : PrefixComparable u v) :
    ∃ z : BergWord,
      wordRightIdeal u ∩ wordRightIdeal v = wordRightIdeal z ∧
      (u <+: z ∧ v <+: z) := by
  rcases h with hp | hp
  · exact ⟨v, wordRightIdeal_inter_eq_of_prefix hp, hp, prefix_refl v⟩
  · exact ⟨u, wordRightIdeal_inter_eq_of_prefix' hp, prefix_refl u, hp⟩

/-! ## Triple-Level Definitions -/

/-- The right ideal of a Berggren semigroup element (triple-level): all triples
obtainable by extending the normal-form word. -/
noncomputable def tripleRightIdeal (t : ℤ × ℤ × ℤ) : Set (ℤ × ℤ × ℤ) :=
  evalTriple '' wordRightIdeal (normalForm t)

/-- Every element is in its own right ideal. -/
theorem mem_tripleRightIdeal_self {t : ℤ × ℤ × ℤ} (ht : t ∈ BergSemigroup) :
    t ∈ tripleRightIdeal t := by
  refine ⟨normalForm t, mem_wordRightIdeal_self _, ?_⟩
  exact eval_normalForm ht

/-- The triple-level right ideal intersection is nonempty iff the normal
forms are prefix comparable. -/
theorem tripleRightIdeal_inter_nonempty_iff
    (t₁ t₂ : ℤ × ℤ × ℤ) :
    (tripleRightIdeal t₁ ∩ tripleRightIdeal t₂).Nonempty ↔
      PrefixComparable (normalForm t₁) (normalForm t₂) := by
  simp only [tripleRightIdeal]
  constructor
  · rintro ⟨s, ⟨w₁, hw₁m, hw₁e⟩, w₂, hw₂m, hw₂e⟩
    obtain ⟨z₁, rfl⟩ := hw₁m
    obtain ⟨z₂, rfl⟩ := hw₂m
    have heq : normalForm t₁ ++ z₁ = normalForm t₂ ++ z₂ :=
      berggren_eval_injective (hw₁e.trans hw₂e.symm)
    exact prefixComparable_of_append_eq_append heq
  · intro h
    have hne := (wordRightIdeal_inter_nonempty_iff _ _).mpr h
    obtain ⟨w, hw₁, hw₂⟩ := hne
    exact ⟨evalTriple w, ⟨w, hw₁, rfl⟩, w, hw₂, rfl⟩

/-! ## Summary of Cryptographic Implications

### Collision Rigidity (`berggren_right_cancel`, `semigroup_right_cancel'`)
In SPB Diffie-Hellman, the public key is derived by applying a sequence of
Berggren generators (encoded as a `BergWord`) to the root triple.
Right cancellation ensures that if two parties share a common suffix
(secret key portion), their public prefixes uniquely determine their
identity. No collision can be created or hidden by appending a common suffix.

### Prefix-Based Intersection (`wordRightIdeal_inter_nonempty_iff`)
The set of words reachable from a given element (its "right ideal")
intersects another element's right ideal if and only if one element's
word is a prefix of the other's. This gives a complete, efficiently
testable criterion for when two elements share a common descendant
in the Berggren tree.

### Intersection Structure (`wordRightIdeal_inter_eq_of_prefix`)
When the right ideals do intersect, the intersection is precisely the
right ideal of the longer element. This means the overlap structure is
as simple as possible: it's always a principal ideal.
-/