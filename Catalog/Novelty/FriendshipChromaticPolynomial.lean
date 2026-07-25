/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Chromatic Polynomial of the Friendship (Windmill) Graph

This file computes, in closed form, the *chromatic counting function* of the **friendship graph**
`F_n` (also called the windmill graph, or Dutch windmill).  The friendship graph consists of a
single central person who is friends with everyone, together with `n` disjoint pairs of people, each
pair being mutual friends: geometrically, `n` triangles all sharing one common vertex.

In the "emotions" reading of graph coloring (assign each person one of `q` emotions so that no two
friends share the same emotion), `chromVal n q` counts the number of consistent emotion assignments
of `F_n` with a palette of `q` emotions.  This is the value `P(F_n, q)` of the chromatic polynomial.

## Main result

* `chromVal_friendship` :  `P(F_n, q) = q · ((q-1)(q-2))^n`.

  The central person picks any of `q` emotions; then, independently for each of the `n` triangles,
  the two outer people must both differ from the centre and from each other, giving `(q-1)(q-2)`
  admissible pairs per triangle.

## Consequences

* `friendship_chromVal_six`     :  with the six basic emotions, `P(F_n, 6) = 6 · 20^n` — this is the
                                   original "graph coloring with emotions" conjecture, now proved.
* `chromVal_pos_iff_colorable`  :  the counting function detects colorability.
* `friendship_colorable_three`  :  three emotions always suffice.
* `friendship_colorable_six`    :  the six basic emotions always suffice.
* `friendship_not_colorable_two`:  for `n ≥ 1`, two emotions never suffice (each triangle is a
                                   clique of size three).
* `friendship_chromaticNumber`  :  for `n ≥ 1`, the chromatic number of `F_n` is exactly `3`; hence,
                                   restricted to the emotional regime `k ≥ 3`, its emotional
                                   chromatic number is `3` and lies in the six-emotion window `[3,6]`.

The proof of the closed form is a genuine bijective count: proper colorings of `F_n` are put in
explicit bijection with a choice of centre colour together with, per triangle, an ordered pair of
colours avoiding the centre and each other (`frEquiv`), whose count is `(q-1)(q-2)` (`pairColors_card`).

The file is self-contained: it imports only Mathlib and redevelops the small amount of
chromatic-counting API it needs.
-/

import Mathlib

namespace Catalog.Novelty.FriendshipChromaticPolynomial

open SimpleGraph Finset

/-! ## The friendship graph -/

/-- Adjacency of the friendship graph `F_n` on vertex set `Option (Fin n × Bool)`.
The centre is `none`; the two outer vertices of triangle `i` are `some (i, false)` and
`some (i, true)`.  The centre is adjacent to every outer vertex, and the two outer vertices of a
common triangle are adjacent to each other; there are no other edges. -/
def frAdj (n : ℕ) (x y : Option (Fin n × Bool)) : Prop :=
  match x, y with
  | none, none => False
  | none, some _ => True
  | some _, none => True
  | some p, some q => p.1 = q.1 ∧ p.2 ≠ q.2

instance frAdjDec (n : ℕ) : DecidableRel (frAdj n) :=
  fun x y => by cases x <;> cases y <;> unfold frAdj <;> infer_instance

/-- The **friendship (windmill) graph** `F_n`: `n` triangles glued at a common central vertex. -/
def friendship (n : ℕ) : SimpleGraph (Option (Fin n × Bool)) where
  Adj := frAdj n
  symm := by intro x y h; cases x <;> cases y <;> simp_all [frAdj]; tauto
  loopless := ⟨by rintro x h; cases x <;> simp_all [frAdj]⟩

instance (n : ℕ) : DecidableRel (friendship n).Adj := frAdjDec n

/-- The chromatic counting function `P(F_n, q)`: the number of proper colorings `V → Fin q` of the
friendship graph, i.e. the number of consistent assignments of `q` emotions. -/
def chromVal (n q : ℕ) : ℕ :=
  (Finset.univ.filter
    (fun c : Option (Fin n × Bool) → Fin q => ∀ x y, (friendship n).Adj x y → c x ≠ c y)).card

/-! ## Counting the colourings of one triangle -/

/-- For fixed centre colour `z` and one already-chosen outer colour `a ≠ z`, the remaining outer
colour has exactly `q - 2` choices (it must avoid both `z` and `a`). -/
theorem fiber_card (q : ℕ) (z a : Fin q) (h : a ≠ z) :
    Fintype.card {b : Fin q // b ≠ z ∧ b ≠ a} = q - 2 := by
  rw [Fintype.card_subtype]
  have heq : (univ.filter (fun b : Fin q => b ≠ z ∧ b ≠ a)) = ({z, a} : Finset (Fin q))ᶜ := by
    ext b; simp
  rw [heq, Finset.card_compl, Fintype.card_fin, Finset.card_pair h.symm]

/-- **Count for a single triangle.** Given the centre colour `z`, the ordered pairs of colours for
the two outer vertices of one triangle — both different from `z` and from each other — number
exactly `(q-1)(q-2)`. -/
theorem pairColors_card (q : ℕ) (z : Fin q) :
    Fintype.card {p : Fin q × Fin q // p.1 ≠ z ∧ p.2 ≠ z ∧ p.1 ≠ p.2} = (q - 1) * (q - 2) := by
  have e : {p : Fin q × Fin q // p.1 ≠ z ∧ p.2 ≠ z ∧ p.1 ≠ p.2}
      ≃ Σ a : {a : Fin q // a ≠ z}, {b : Fin q // b ≠ z ∧ b ≠ a.1} :=
    { toFun := fun p => ⟨⟨p.1.1, p.2.1⟩, ⟨p.1.2, p.2.2.1, fun hh => p.2.2.2 hh.symm⟩⟩
      invFun := fun s => ⟨(s.1.1, s.2.1), s.1.2, s.2.2.1, fun hh => s.2.2.2 hh.symm⟩
      left_inv := by rintro ⟨⟨a, b⟩, -⟩; rfl
      right_inv := by rintro ⟨⟨a, ha⟩, ⟨b, hb⟩⟩; rfl }
  rw [Fintype.card_congr e, Fintype.card_sigma]
  rw [Finset.sum_congr rfl (fun a _ => fiber_card q z a.1 a.2)]
  rw [Finset.sum_const, Finset.card_univ, smul_eq_mul]
  have hz : Fintype.card {a : Fin q // a ≠ z} = q - 1 := by
    rw [Fintype.card_subtype]
    have : (univ.filter (fun a : Fin q => a ≠ z)) = ({z} : Finset (Fin q))ᶜ := by ext a; simp
    rw [this, Finset.card_compl, Fintype.card_fin, Finset.card_singleton]
  rw [hz]

/-! ## The colouring bijection -/

/-- **The structural bijection.** A proper colouring of `F_n` is exactly a choice of centre colour
`z : Fin q` together with, for each triangle `i`, an ordered pair of outer colours both avoiding `z`
and each other.  The forward map reads off the centre and each triangle's outer colours; the inverse
paints the centre with `z` and triangle `i`'s outer vertices with the recorded pair. -/
def frEquiv (n q : ℕ) :
    {c : Option (Fin n × Bool) → Fin q // ∀ x y, (friendship n).Adj x y → c x ≠ c y}
      ≃ Σ z : Fin q, (Fin n → {p : Fin q × Fin q // p.1 ≠ z ∧ p.2 ≠ z ∧ p.1 ≠ p.2}) where
  toFun := fun c =>
    ⟨c.1 none, fun i =>
      ⟨(c.1 (some (i, false)), c.1 (some (i, true))),
        c.2 (some (i, false)) none trivial,
        c.2 (some (i, true)) none trivial,
        c.2 (some (i, false)) (some (i, true)) ⟨rfl, Bool.false_ne_true⟩⟩⟩
  invFun := fun s =>
    ⟨fun v => match v with
      | none => s.1
      | some (i, b) => bif b then (s.2 i).1.2 else (s.2 i).1.1,
      by
        rintro x y h
        cases x with
        | none => cases y with
          | none => exact absurd h (by simp [friendship])
          | some p =>
            obtain ⟨i, b⟩ := p; have := (s.2 i).2; cases b <;> simp_all <;> tauto
        | some p =>
          obtain ⟨i, a⟩ := p
          cases y with
          | none => have := (s.2 i).2; cases a <;> simp_all
          | some p2 =>
            obtain ⟨j, b⟩ := p2
            obtain ⟨hij, hab⟩ : i = j ∧ a ≠ b := h
            subst hij
            have := (s.2 i).2.2.2
            cases a <;> cases b <;> simp_all [eq_comm]⟩
  left_inv := by
    rintro ⟨c, hc⟩; ext v
    cases v with
    | none => rfl
    | some p => obtain ⟨i, b⟩ := p; cases b <;> rfl
  right_inv := by rintro ⟨z, f⟩; congr 1

/-! ## The chromatic polynomial of the friendship graph -/

/-- **Main theorem.** The chromatic polynomial of the friendship graph `F_n` evaluated at `q` is
`q · ((q-1)(q-2))^n`: pick any of `q` emotions for the central person, then independently choose,
for each of the `n` triangles, an ordered pair of outer emotions both different from the centre and
from each other — `(q-1)(q-2)` choices per triangle. -/
theorem chromVal_friendship (n q : ℕ) :
    chromVal n q = q * ((q - 1) * (q - 2)) ^ n := by
  unfold chromVal
  rw [← Fintype.card_subtype, Fintype.card_congr (frEquiv n q), Fintype.card_sigma]
  have hcard : ∀ z : Fin q,
      Fintype.card (Fin n → {p : Fin q × Fin q // p.1 ≠ z ∧ p.2 ≠ z ∧ p.1 ≠ p.2})
        = ((q - 1) * (q - 2)) ^ n := by
    intro z; rw [Fintype.card_fun, pairColors_card, Fintype.card_fin]
  rw [Finset.sum_congr rfl (fun z _ => hcard z), Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, smul_eq_mul]

/-! ## Consequences -/

/-- **The six basic emotions.**  With a palette of the six basic emotions (happiness, sadness, anger,
fear, disgust, surprise), the friendship graph `F_n` has exactly `6 · 20^n` consistent emotion
assignments.  This is the closed form asserted by the "graph coloring with emotions" conjecture. -/
theorem friendship_chromVal_six (n : ℕ) : chromVal n 6 = 6 * 20 ^ n := by
  rw [chromVal_friendship]

/-- **The counting function is a colorability oracle.**  There is at least one consistent emotion
assignment with `q` emotions iff `P(F_n, q) > 0`. -/
theorem chromVal_pos_iff_colorable (n q : ℕ) :
    0 < chromVal n q ↔ (friendship n).Colorable q := by
  constructor
  · intro h
    obtain ⟨c, hc⟩ := Finset.card_pos.mp h
    exact ⟨SimpleGraph.Coloring.mk c (fun {x y} hxy => (Finset.mem_filter.mp hc).2 x y hxy)⟩
  · rintro ⟨c⟩
    exact Finset.card_pos.mpr
      ⟨c.toFun, Finset.mem_filter.mpr ⟨Finset.mem_univ _, fun x y hxy => c.valid hxy⟩⟩

/-- Three emotions always suffice for a friendship graph (`P(F_n, 3) = 3 · 2^n > 0`). -/
theorem friendship_colorable_three (n : ℕ) : (friendship n).Colorable 3 := by
  rw [← chromVal_pos_iff_colorable, chromVal_friendship]; norm_num

/-- The six basic emotions always suffice for a friendship graph. -/
theorem friendship_colorable_six (n : ℕ) : (friendship n).Colorable 6 :=
  (friendship_colorable_three n).mono (by norm_num)

/-- For `n ≥ 1`, two emotions never suffice: each triangle is a clique of three mutual friends, so
`P(F_n, 2) = 2 · 0^n = 0`. -/
theorem friendship_not_colorable_two {n : ℕ} (hn : 1 ≤ n) : ¬ (friendship n).Colorable 2 := by
  rw [← chromVal_pos_iff_colorable, chromVal_friendship]
  simp [zero_pow (show n ≠ 0 by omega)]

/-- **Chromatic number of the friendship graph.**  For `n ≥ 1`, `χ(F_n) = 3`: three emotions are
necessary (each triangle forces it) and sufficient.  Restricted to the emotional regime `k ≥ 3`,
this pins the emotional chromatic number of every nonempty friendship network to `3`, safely inside
the six-emotion window `[3, 6]`. -/
theorem friendship_chromaticNumber {n : ℕ} (hn : 1 ≤ n) :
    (friendship n).chromaticNumber = 3 := by
  apply le_antisymm
  · exact chromaticNumber_le_iff_colorable.mpr (friendship_colorable_three n)
  · by_contra h
    rw [not_le] at h
    have hle : (friendship n).chromaticNumber ≤ 2 := Order.le_of_lt_succ h
    exact friendship_not_colorable_two hn (chromaticNumber_le_iff_colorable.mp hle)

end Catalog.Novelty.FriendshipChromaticPolynomial