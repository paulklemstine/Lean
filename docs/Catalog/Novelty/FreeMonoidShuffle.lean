/-
# Shuffle products on a free monoid

This file develops, from scratch, the combinatorial core of the shuffle product on the
free monoid `List X = X*` over an alphabet `X`, in the multiset ("with multiplicities")
formulation.  This is the basic layer underlying the bialgebras of representative
functions on free monoids: the shuffle product `⧢`, the unshuffle (deconcatenation-dual)
coproduct, and their duality.

Main results:

* `shuf` : the multiset of shuffles of two words, defined by the classical recursion.
* `shuf_comm`, `shuf_assoc`, `shuf_nil_left/right` : `(Multiset (List X), shuf)` is a
  commutative monoid-like structure (associativity is stated through `bindShuf`, the
  bilinear extension of `shuf`).
* `shuf_card` : `|u ⧢ v| = C(|u|+|v|, |u|)`.
* `shuf_length_mem` : shuffles are length graded.
-/
import Mathlib

namespace FreeMonoidShuffle

variable {X : Type*}

/-! ## The shuffle product of two words -/

/-- The multiset of all shuffles (interleavings, with multiplicity) of two words. -/
def shuf : List X → List X → Multiset (List X)
  | [], v => {v}
  | u, [] => {u}
  | a :: u, b :: v =>
      ((shuf u (b :: v)).map (a :: ·)) + ((shuf (a :: u) v).map (b :: ·))
  termination_by u v => u.length + v.length

@[simp] lemma shuf_nil_left (v : List X) : shuf ([] : List X) v = {v} := by rw [shuf]

@[simp] lemma shuf_nil_right (u : List X) : shuf u ([] : List X) = {u} := by
  cases u with
  | nil => rw [shuf]
  | cons a u => rw [shuf]; simp

lemma shuf_cons_cons (a b : X) (u v : List X) :
    shuf (a :: u) (b :: v) =
      ((shuf u (b :: v)).map (a :: ·)) + ((shuf (a :: u) v).map (b :: ·)) := by
  rw [shuf]

/-- The shuffle product is commutative. -/
theorem shuf_comm (u v : List X) : shuf u v = shuf v u := by
  induction u generalizing v with
  | nil => simp
  | cons a u ih =>
    induction v with
    | nil => simp
    | cons b v ihv => rw [shuf_cons_cons, shuf_cons_cons, ih (b :: v), ihv]; exact add_comm _ _

/-- Every shuffle of `u` and `v` is a word of length `|u| + |v|`. -/
theorem shuf_length_mem {u v z : List X} (hz : z ∈ shuf u v) :
    z.length = u.length + v.length := by
  induction hn : u.length + v.length using Nat.strong_induction_on generalizing u v z with
  | _ n ih =>
  match u, v with
  | [], v =>
    subst hn; rw [shuf_nil_left] at hz; simp only [Multiset.mem_singleton] at hz; simp [hz]
  | u, [] =>
    subst hn; rw [shuf_nil_right] at hz; simp only [Multiset.mem_singleton] at hz; simp [hz]
  | a :: u, b :: v =>
    subst hn
    rw [shuf_cons_cons] at hz
    rcases Multiset.mem_add.1 hz with h | h
    · obtain ⟨y, hy, rfl⟩ := Multiset.mem_map.1 h
      have := ih (u.length + (b :: v).length) (by simp) hy rfl
      simp [this]; omega
    · obtain ⟨y, hy, rfl⟩ := Multiset.mem_map.1 h
      have := ih ((a :: u).length + v.length) (by simp) hy rfl
      simp [this]; omega

/-- The number of shuffles of `u` and `v`, with multiplicity, is a binomial coefficient. -/
theorem shuf_card (u v : List X) :
    (shuf u v).card = (u.length + v.length).choose u.length := by
  induction u generalizing v with
  | nil => simp
  | cons a u ih =>
    induction v with
    | nil => simp
    | cons b v ihv =>
      rw [shuf_cons_cons]
      simp only [Multiset.card_add, Multiset.card_map, ih, ihv, List.length_cons]
      have h1 : u.length + (v.length + 1) = u.length + v.length + 1 := by omega
      have h2 : u.length + 1 + v.length = u.length + v.length + 1 := by omega
      have h3 : u.length + 1 + (v.length + 1) = (u.length + v.length + 1) + 1 := by omega
      rw [h1, h2, h3, Nat.choose_succ_succ' (u.length + v.length + 1) u.length]

/-! ## The bilinear extension of the shuffle product -/

/-- Shuffling a whole multiset of words with a fixed word. -/
def bindShuf (s : Multiset (List X)) (w : List X) : Multiset (List X) :=
  s.bind (fun z => shuf z w)

@[simp] lemma bindShuf_singleton (u w : List X) : bindShuf {u} w = shuf u w := by simp [bindShuf]

@[simp] lemma bindShuf_add (s t : Multiset (List X)) (w : List X) :
    bindShuf (s + t) w = bindShuf s w + bindShuf t w := by simp [bindShuf, Multiset.add_bind]

@[simp] lemma bindShuf_zero (w : List X) : bindShuf (0 : Multiset (List X)) w = 0 := by
  simp [bindShuf]

@[simp] lemma bindShuf_nil (s : Multiset (List X)) : bindShuf s [] = s := by
  simp only [bindShuf, shuf_nil_right]
  induction s using Multiset.induction with
  | empty => simp
  | cons a s ih => simp [ih]

lemma bindShuf_map_cons (a c : X) (t : Multiset (List X)) (w : List X) :
    bindShuf (t.map (a :: ·)) (c :: w) =
      (bindShuf t (c :: w)).map (a :: ·) + (bindShuf (t.map (a :: ·)) w).map (c :: ·) := by
  simp only [bindShuf, Multiset.bind_map, Multiset.map_bind]
  rw [← Multiset.bind_add]
  exact Multiset.bind_congr (fun z _ => shuf_cons_cons a c z w)

lemma bindShuf_comm (s : Multiset (List X)) (u : List X) :
    s.bind (fun z => shuf u z) = bindShuf s u :=
  Multiset.bind_congr (fun z _ => shuf_comm u z)

/-- **Associativity of the shuffle product**: `(u ⧢ v) ⧢ w = u ⧢ (v ⧢ w)`. -/
theorem shuf_assoc (u v w : List X) : bindShuf (shuf u v) w = bindShuf (shuf v w) u := by
  induction hn : u.length + v.length + w.length using Nat.strong_induction_on
    generalizing u v w with
  | _ n ih =>
  match u, v, w with
  | [], v, w => simp
  | u, [], w => simp [shuf_comm]
  | u, v, [] => simp [shuf_comm]
  | a :: u, b :: v, c :: w =>
    subst hn
    rw [shuf_cons_cons a b u v, shuf_cons_cons b c v w]
    rw [bindShuf_add, bindShuf_add, bindShuf_map_cons, bindShuf_map_cons,
        bindShuf_map_cons, bindShuf_map_cons]
    have e1 : bindShuf (shuf u (b :: v)) (c :: w) = bindShuf (shuf (b :: v) (c :: w)) u :=
      ih _ (by simp) u (b :: v) (c :: w) rfl
    have e2 : bindShuf (shuf (a :: u) v) (c :: w) = bindShuf (shuf v (c :: w)) (a :: u) :=
      ih _ (by simp) (a :: u) v (c :: w) rfl
    have e3 : bindShuf (shuf (a :: u) (b :: v)) w = bindShuf (shuf (b :: v) w) (a :: u) :=
      ih _ (by simp) (a :: u) (b :: v) w rfl
    have hA : (bindShuf (shuf (b :: v) (c :: w)) u).map (a :: ·) =
        (bindShuf ((shuf v (c :: w)).map (b :: ·)) u).map (a :: ·) +
        (bindShuf ((shuf (b :: v) w).map (c :: ·)) u).map (a :: ·) := by
      rw [shuf_cons_cons b c v w, bindShuf_add, Multiset.map_add]
    have hC : (bindShuf (shuf (b :: v) w) (a :: u)).map (c :: ·) =
        (bindShuf ((shuf u (b :: v)).map (a :: ·)) w).map (c :: ·) +
        (bindShuf ((shuf (a :: u) v).map (b :: ·)) w).map (c :: ·) := by
      rw [← e3, shuf_cons_cons a b u v, bindShuf_add, Multiset.map_add]
    rw [e1, e2, hA, hC]
    abel

end FreeMonoidShuffle