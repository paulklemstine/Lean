import Algebra.ScanSchemeDecoding.Triangle

/-!
# Scan schemes: honest uniqueness decoding and exact cost accounting

A **scan scheme** on a finite key type `α` with bucket labels in `β` is nothing but a
bucket map `bucket : α → β`.  Decoding a key means scanning its bucket, in the
canonical (linear) order, until the key is found.  Two things are then formalised
here, and both are *exact*, not asymptotic:

* **Honest uniqueness decoding** (`ScanScheme.honest_scanCode`,
  `ScanScheme.decode_eq_some_iff`).  The pair `encode x = (bucket x, idx x)`
  — bucket label together with the *intra-bucket index* — decodes back to `x`, and
  it is the **only** pair that does so.  So `encode` is an injection into
  `β × ℕ` whose decoding is unambiguous: no scheme-level ambiguity is hidden in the
  cost model.
* **Exact cost accounting** (`ScanScheme.decodeCost_eq`).  The total decoding cost
  `∑ x, decodeCost x` equals `∑ b, triangle (fiber b).card` *on the nose*.

The two facts together turn the optimisation of scan schemes into the purely
arithmetic problem solved in `Algebra.ScanSchemeDecoding.Triangle`.
-/

namespace ScanSchemeDecoding

open Finset

/-- A scan scheme: a bucket assignment of keys `α` to bucket labels `β`. -/
structure ScanScheme (α β : Type*) where
  /-- The bucket a key is stored in. -/
  bucket : α → β

variable {α β : Type*} [Fintype α] [LinearOrder α] [DecidableEq β]

namespace ScanScheme

variable (S : ScanScheme α β)

/-- The set of keys stored in bucket `b`. -/
def fiber (b : β) : Finset α := {x | S.bucket x = b}

/-- The keys of bucket `b`, in the order in which a scan visits them. -/
def scanList (b : β) : List α := (S.fiber b).sort (· ≤ ·)

/-- The **intra-bucket index** of a key: its position in the scan of its own bucket. -/
def idx (x : α) : ℕ := (S.scanList (S.bucket x)).idxOf x

/-- Decoding cost: the (1-based) number of comparisons a scan performs to find `x`. -/
def decodeCost (x : α) : ℕ := S.idx x + 1

/-- The scan code of a key: bucket label plus intra-bucket index. -/
def encode (x : α) : β × ℕ := (S.bucket x, S.idx x)

/-- Decoding a scan code: read off the entry at the given index of the given bucket. -/
def decode (p : β × ℕ) : Option α := (S.scanList p.1)[p.2]?

omit [LinearOrder α] in
@[simp] lemma mem_fiber {x : α} {b : β} : x ∈ S.fiber b ↔ S.bucket x = b := by
  simp [fiber]

lemma scanList_nodup (b : β) : (S.scanList b).Nodup := Finset.sort_nodup _ _

@[simp] lemma mem_scanList {x : α} {b : β} : x ∈ S.scanList b ↔ S.bucket x = b := by
  simp [scanList, fiber]

@[simp] lemma length_scanList (b : β) : (S.scanList b).length = (S.fiber b).card :=
  Finset.length_sort _

lemma toFinset_scanList (b : β) : (S.scanList b).toFinset = S.fiber b :=
  Finset.sort_toFinset _ _

lemma self_mem_scanList (x : α) : x ∈ S.scanList (S.bucket x) := by simp

/-- **Honest uniqueness decoding.**  The scan code of a key decodes back to that key. -/
theorem honest_scanCode (x : α) : S.decode (S.encode x) = some x := by
  classical
  exact List.getElem?_idxOf (l := S.scanList (S.bucket x)) (a := x) (S.self_mem_scanList x)

/-- The intra-bucket index is a genuine index: it lies below the bucket size. -/
theorem idx_lt_card (x : α) : S.idx x < (S.fiber (S.bucket x)).card := by
  classical
  have := List.idxOf_lt_length_iff.mpr (S.self_mem_scanList x)
  simpa [idx] using this

/-- Decoding cost is at least `1` and at most the size of the key's bucket. -/
theorem decodeCost_mem_Icc (x : α) :
    1 ≤ S.decodeCost x ∧ S.decodeCost x ≤ (S.fiber (S.bucket x)).card := by
  refine ⟨Nat.le_add_left 1 _, ?_⟩
  have := S.idx_lt_card x
  simpa [decodeCost] using this

/-- **Uniqueness half of honest decoding.**  A scan code decodes to `x` *iff* it is
the scan code of `x`; in particular the code carries no redundancy. -/
theorem decode_eq_some_iff {p : β × ℕ} {x : α} : S.decode p = some x ↔ p = S.encode x := by
  classical
  constructor
  · intro h
    obtain ⟨b, i⟩ := p
    simp only [decode] at h
    have hx : x ∈ S.scanList b := List.mem_of_getElem? h
    have hb : S.bucket x = b := by simpa using hx
    have hi : i < (S.scanList b).length := by
      by_contra hcon
      rw [List.getElem?_eq_none (by omega)] at h
      simp at h
    have hget : (S.scanList b)[i] = x := by
      rw [List.getElem?_eq_getElem hi] at h
      exact Option.some.inj h
    have : (S.scanList b).idxOf x = i := by
      rw [← hget]
      exact List.Nodup.idxOf_getElem (S.scanList_nodup b) i hi
    subst hb
    simp [encode, idx, this]
  · rintro rfl
    exact S.honest_scanCode x

theorem encode_injective : Function.Injective S.encode := by
  intro x y h
  have hx := S.honest_scanCode x
  rw [h, S.honest_scanCode y] at hx
  exact (Option.some.inj hx).symm

/-- A key-indexed reformulation: the intra-bucket index restricted to one bucket is
injective. -/
theorem idx_injOn (b : β) : Set.InjOn S.idx (S.fiber b : Set α) := by
  intro x hx y hy h
  have hx' : S.bucket x = b := by simpa using hx
  have hy' : S.bucket y = b := by simpa using hy
  exact S.encode_injective (by simp [encode, hx', hy', h])

end ScanScheme

/-- The scan cost of a nodup list, summed over its elements, is the triangular number
of its length.  This is the list-level core of exact cost accounting. -/
theorem sum_succ_idxOf {γ : Type*} [DecidableEq γ] :
    ∀ (l : List γ), l.Nodup → ∑ x ∈ l.toFinset, (l.idxOf x + 1) = triangle l.length := by
  intro l
  induction l with
  | nil => simp
  | cons a t ih =>
    intro hnd
    have ha : a ∉ t := (List.nodup_cons.mp hnd).1
    have hndt : t.Nodup := (List.nodup_cons.mp hnd).2
    have ha' : a ∉ t.toFinset := by simpa using ha
    rw [List.toFinset_cons, Finset.sum_insert ha']
    have h0 : (a :: t).idxOf a + 1 = 1 := by simp
    have hstep : ∀ x ∈ t.toFinset, (a :: t).idxOf x + 1 = (t.idxOf x + 1) + 1 := by
      intro x hx
      have hxa : a ≠ x := by
        intro h; exact ha (by simpa [h] using List.mem_toFinset.mp hx)
      rw [List.idxOf_cons_ne _ hxa]
    rw [h0, Finset.sum_congr rfl hstep, Finset.sum_add_distrib, ih hndt]
    have hcard : t.toFinset.card = t.length := List.toFinset_card_of_nodup hndt
    simp only [Finset.sum_const, hcard, smul_eq_mul, mul_one]
    rw [List.length_cons, triangle_succ]
    omega

namespace ScanScheme

variable (S : ScanScheme α β)

/-- The exact cost of one bucket: scanning every key of a bucket of size `k` costs
`triangle k`. -/
theorem bucket_cost_eq (b : β) :
    ∑ x ∈ S.fiber b, S.decodeCost x = triangle (S.fiber b).card := by
  classical
  have hrw : ∀ x ∈ S.fiber b, S.decodeCost x = (S.scanList b).idxOf x + 1 := by
    intro x hx
    have : S.bucket x = b := by simpa using hx
    simp [decodeCost, idx, this]
  rw [Finset.sum_congr rfl hrw, ← S.toFinset_scanList b,
    sum_succ_idxOf _ (S.scanList_nodup b)]
  simp [S.toFinset_scanList b]

/-- **Exact cost accounting.**  The total decoding cost of a scan scheme is exactly the
sum of the triangular numbers of its bucket sizes. -/
theorem decodeCost_eq [Fintype β] :
    ∑ x, S.decodeCost x = ∑ b, triangle (S.fiber b).card := by
  classical
  rw [← Finset.sum_fiberwise Finset.univ S.bucket S.decodeCost]
  refine Finset.sum_congr rfl (fun b _ => ?_)
  have : {x ∈ (Finset.univ : Finset α) | S.bucket x = b} = S.fiber b := by
    ext x; simp [fiber]
  rw [this, S.bucket_cost_eq b]

omit [LinearOrder α] in
/-- The bucket sizes of a scan scheme sum to the number of keys. -/
theorem sum_fiber_card [Fintype β] : ∑ b, (S.fiber b).card = Fintype.card α := by
  classical
  have := Finset.card_eq_sum_card_fiberwise
    (f := S.bucket) (s := (Finset.univ : Finset α)) (t := (Finset.univ : Finset β))
    (fun x _ => Finset.mem_univ _)
  simp only [Finset.card_univ] at this
  rw [this]
  exact Finset.sum_congr rfl (fun b _ => rfl)

end ScanScheme

end ScanSchemeDecoding