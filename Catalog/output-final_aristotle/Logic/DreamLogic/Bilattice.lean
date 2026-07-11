import Mathlib

/-!
# Dream Logic IV — The Interlaced Bilattice `FOUR`

This file deepens the algebraic side of *dream logic* by exhibiting the full
**bilattice** structure on the four Belnap–Dunn truth values.  Where the earlier
development (`FourValued.lean`) treated the truth order and its meet/join together
with a De Morgan negation, this file adds the *knowledge* (information) order as a
first-class lattice and proves the four **interlacing** conditions that make the
two lattices cohere.  The result is Ginsberg–Fitting's smallest nontrivial
interlaced bilattice `FOUR`, the canonical semantics for reasoning in which
contradictions coexist and beliefs are revisable.

The carrier is again

* `tt`      — true only,
* `ff`      — false only,
* `both`    — a *glut* (true and false at once — an impossible object),
* `neither` — a *gap* (undetermined).

Two orders live on it:

* the **truth order** `tle` with bottom `ff`, top `tt`, and `both`, `neither`
  incomparable in the middle; its meet/join are `tmeet` (conjunction) and `tjoin`
  (disjunction);
* the **knowledge order** `kle` with bottom `neither`, top `both`, and `tt`, `ff`
  incomparable in the middle; its meet/join are `kmeet` (*consensus* `⊗`) and
  `kjoin` (*gullibility* `⊕`).

## Main results

* `tle` / `kle` are partial orders (`*_refl`, `*_trans`, `*_antisymm`).
* `tmeet` / `tjoin` are the glb / lub for `tle`; `kmeet` / `kjoin` are the glb / lub
  for `kle` (`*_le_left`, `*_le_right`, `le_*`, `*_le`).
* Bounded: `ff`/`tt` bound `tle`; `neither`/`both` bound `kle`.
* Lattice identities (`*_comm`, `*_assoc`, `*_idem`, `absorb_*`) derived from the
  glb/lub characterizations.
* **Interlacing** (`interlace_tmeet`, `interlace_tjoin`, `interlace_kmeet`,
  `interlace_kjoin`): each of the four operations is monotone in the *other* order.
  These are the axioms defining an interlaced bilattice.
* Negation `neg` is a truth-order *anti*-automorphism and a knowledge-order
  automorphism (`neg_tle_iff`, `neg_kle_iff`, `neg_tmeet`, `neg_tjoin`,
  `neg_kmeet`, `neg_kjoin`), the De Morgan / bilattice-negation laws.
* Conflation `conf` (swapping `both`/`neither`, fixing `tt`/`ff`) is dual: a
  knowledge-order anti-automorphism and truth-order automorphism.
* `FOUR_paraconsistent`: the interlacing structure yields a designated glut whose
  contradiction does not entail an arbitrary proposition.
-/

namespace DreamLogic.Bilattice

/-- The four truth values of dream logic. -/
inductive FV
  | tt
  | ff
  | both
  | neither
deriving DecidableEq, Repr

open FV

/-! ### Operations -/

/-- Paraconsistent negation: swaps the pure values, fixes the glut and the gap.
Order-reversing for truth, order-preserving for knowledge. -/
def neg : FV → FV
  | tt => ff | ff => tt | both => both | neither => neither

/-- Conflation: swaps the glut and the gap, fixes the pure values.
Order-reversing for knowledge, order-preserving for truth. -/
def conf : FV → FV
  | tt => tt | ff => ff | both => neither | neither => both

/-- Truth meet = conjunction. -/
def tmeet : FV → FV → FV
  | tt, x => x | ff, _ => ff
  | both, tt => both | both, ff => ff | both, both => both | both, neither => ff
  | neither, tt => neither | neither, ff => ff | neither, both => ff | neither, neither => neither

/-- Truth join = disjunction. -/
def tjoin : FV → FV → FV
  | ff, x => x | tt, _ => tt
  | both, tt => tt | both, ff => both | both, both => both | both, neither => tt
  | neither, tt => tt | neither, ff => neither | neither, both => tt | neither, neither => neither

/-- Knowledge meet = *consensus* `⊗`: retains only information both agree on. -/
def kmeet : FV → FV → FV
  | both, x => x | neither, _ => neither
  | tt, tt => tt | tt, ff => neither | tt, both => tt | tt, neither => neither
  | ff, tt => neither | ff, ff => ff | ff, both => ff | ff, neither => neither

/-- Knowledge join = *gullibility* `⊕`: accepts information from either side. -/
def kjoin : FV → FV → FV
  | neither, x => x | both, _ => both
  | tt, tt => tt | tt, ff => both | tt, both => both | tt, neither => tt
  | ff, tt => both | ff, ff => ff | ff, both => both | ff, neither => ff

/-- A value is *designated* (accepted as at-least-true) exactly when it is `tt` or `both`. -/
def designated : FV → Prop
  | tt => True | both => True | ff => False | neither => False

instance : DecidablePred designated := by
  intro a; cases a <;> simp only [designated] <;> infer_instance

/-! ### The two orders -/

/-- Truth order: bottom `ff`, top `tt`, with `both`, `neither` incomparable. -/
def tle (a b : FV) : Prop := a = ff ∨ b = tt ∨ a = b

/-- Knowledge order: bottom `neither`, top `both`, with `tt`, `ff` incomparable. -/
def kle (a b : FV) : Prop := a = neither ∨ b = both ∨ a = b

instance : DecidableRel tle := fun a b => by unfold tle; infer_instance
instance : DecidableRel kle := fun a b => by unfold kle; infer_instance

theorem tle_refl (a : FV) : tle a a := by simp [tle]
theorem kle_refl (a : FV) : kle a a := by simp [kle]

theorem tle_trans {a b c : FV} : tle a b → tle b c → tle a c := by
  cases a <;> cases b <;> cases c <;> simp [tle]
theorem kle_trans {a b c : FV} : kle a b → kle b c → kle a c := by
  cases a <;> cases b <;> cases c <;> simp [kle]

theorem tle_antisymm {a b : FV} : tle a b → tle b a → a = b := by
  cases a <;> cases b <;> simp [tle]
theorem kle_antisymm {a b : FV} : kle a b → kle b a → a = b := by
  cases a <;> cases b <;> simp [kle]

/-! ### Bounds -/

theorem ff_tle (a : FV) : tle ff a := by simp [tle]
theorem tle_tt (a : FV) : tle a tt := by simp [tle]
theorem neither_kle (a : FV) : kle neither a := by simp [kle]
theorem kle_both (a : FV) : kle a both := by simp [kle]

/-! ### `tmeet`/`tjoin` are glb/lub for the truth order -/

theorem tmeet_le_left (a b : FV) : tle (tmeet a b) a := by cases a <;> cases b <;> simp [tle, tmeet]
theorem tmeet_le_right (a b : FV) : tle (tmeet a b) b := by cases a <;> cases b <;> simp [tle, tmeet]
theorem le_tmeet {a b c : FV} : tle c a → tle c b → tle c (tmeet a b) := by
  cases a <;> cases b <;> cases c <;> simp [tle, tmeet]

theorem left_le_tjoin (a b : FV) : tle a (tjoin a b) := by cases a <;> cases b <;> simp [tle, tjoin]
theorem right_le_tjoin (a b : FV) : tle b (tjoin a b) := by cases a <;> cases b <;> simp [tle, tjoin]
theorem tjoin_le {a b c : FV} : tle a c → tle b c → tle (tjoin a b) c := by
  cases a <;> cases b <;> cases c <;> simp [tle, tjoin]

/-! ### `kmeet`/`kjoin` are glb/lub for the knowledge order -/

theorem kmeet_le_left (a b : FV) : kle (kmeet a b) a := by cases a <;> cases b <;> simp [kle, kmeet]
theorem kmeet_le_right (a b : FV) : kle (kmeet a b) b := by cases a <;> cases b <;> simp [kle, kmeet]
theorem le_kmeet {a b c : FV} : kle c a → kle c b → kle c (kmeet a b) := by
  cases a <;> cases b <;> cases c <;> simp [kle, kmeet]

theorem left_le_kjoin (a b : FV) : kle a (kjoin a b) := by cases a <;> cases b <;> simp [kle, kjoin]
theorem right_le_kjoin (a b : FV) : kle b (kjoin a b) := by cases a <;> cases b <;> simp [kle, kjoin]
theorem kjoin_le {a b c : FV} : kle a c → kle b c → kle (kjoin a b) c := by
  cases a <;> cases b <;> cases c <;> simp [kle, kjoin]

/-! ### Lattice identities, derived from the glb/lub characterizations -/

theorem tmeet_comm (a b : FV) : tmeet a b = tmeet b a :=
  tle_antisymm (le_tmeet (tmeet_le_right a b) (tmeet_le_left a b))
               (le_tmeet (tmeet_le_right b a) (tmeet_le_left b a))
theorem tjoin_comm (a b : FV) : tjoin a b = tjoin b a :=
  tle_antisymm (tjoin_le (right_le_tjoin b a) (left_le_tjoin b a))
               (tjoin_le (right_le_tjoin a b) (left_le_tjoin a b))
theorem kmeet_comm (a b : FV) : kmeet a b = kmeet b a :=
  kle_antisymm (le_kmeet (kmeet_le_right a b) (kmeet_le_left a b))
               (le_kmeet (kmeet_le_right b a) (kmeet_le_left b a))
theorem kjoin_comm (a b : FV) : kjoin a b = kjoin b a :=
  kle_antisymm (kjoin_le (right_le_kjoin b a) (left_le_kjoin b a))
               (kjoin_le (right_le_kjoin a b) (left_le_kjoin a b))

theorem tmeet_idem (a : FV) : tmeet a a = a :=
  tle_antisymm (tmeet_le_left a a) (le_tmeet (tle_refl a) (tle_refl a))
theorem tjoin_idem (a : FV) : tjoin a a = a :=
  tle_antisymm (tjoin_le (tle_refl a) (tle_refl a)) (left_le_tjoin a a)
theorem kmeet_idem (a : FV) : kmeet a a = a :=
  kle_antisymm (kmeet_le_left a a) (le_kmeet (kle_refl a) (kle_refl a))
theorem kjoin_idem (a : FV) : kjoin a a = a :=
  kle_antisymm (kjoin_le (kle_refl a) (kle_refl a)) (left_le_kjoin a a)

theorem tmeet_assoc (a b c : FV) : tmeet (tmeet a b) c = tmeet a (tmeet b c) := by
  cases a <;> cases b <;> cases c <;> rfl
theorem tjoin_assoc (a b c : FV) : tjoin (tjoin a b) c = tjoin a (tjoin b c) := by
  cases a <;> cases b <;> cases c <;> rfl
theorem kmeet_assoc (a b c : FV) : kmeet (kmeet a b) c = kmeet a (kmeet b c) := by
  cases a <;> cases b <;> cases c <;> rfl
theorem kjoin_assoc (a b c : FV) : kjoin (kjoin a b) c = kjoin a (kjoin b c) := by
  cases a <;> cases b <;> cases c <;> rfl

theorem absorb_tmeet_tjoin (a b : FV) : tmeet a (tjoin a b) = a :=
  tle_antisymm (tmeet_le_left a (tjoin a b)) (le_tmeet (tle_refl a) (left_le_tjoin a b))
theorem absorb_tjoin_tmeet (a b : FV) : tjoin a (tmeet a b) = a :=
  tle_antisymm (tjoin_le (tle_refl a) (tmeet_le_left a b)) (left_le_tjoin a (tmeet a b))
theorem absorb_kmeet_kjoin (a b : FV) : kmeet a (kjoin a b) = a :=
  kle_antisymm (kmeet_le_left a (kjoin a b)) (le_kmeet (kle_refl a) (left_le_kjoin a b))
theorem absorb_kjoin_kmeet (a b : FV) : kjoin a (kmeet a b) = a :=
  kle_antisymm (kjoin_le (kle_refl a) (kmeet_le_left a b)) (left_le_kjoin a (kmeet a b))

/-! ### Interlacing: each operation is monotone in the *other* order.

These four conditions are exactly the axioms of an *interlaced bilattice*. -/

/-- The truth meet is monotone in the knowledge order. -/
theorem interlace_tmeet {a b c d : FV} (hab : kle a b) (hcd : kle c d) :
    kle (tmeet a c) (tmeet b d) := by
  cases a <;> cases b <;> cases c <;> cases d <;> simp_all [kle, tmeet]

/-- The truth join is monotone in the knowledge order. -/
theorem interlace_tjoin {a b c d : FV} (hab : kle a b) (hcd : kle c d) :
    kle (tjoin a c) (tjoin b d) := by
  cases a <;> cases b <;> cases c <;> cases d <;> simp_all [kle, tjoin]

/-- The knowledge meet is monotone in the truth order. -/
theorem interlace_kmeet {a b c d : FV} (hab : tle a b) (hcd : tle c d) :
    tle (kmeet a c) (kmeet b d) := by
  cases a <;> cases b <;> cases c <;> cases d <;> simp_all [tle, kmeet]

/-- The knowledge join is monotone in the truth order. -/
theorem interlace_kjoin {a b c d : FV} (hab : tle a b) (hcd : tle c d) :
    tle (kjoin a c) (kjoin b d) := by
  cases a <;> cases b <;> cases c <;> cases d <;> simp_all [tle, kjoin]

/-! ### Negation: truth anti-automorphism, knowledge automorphism -/

theorem neg_neg (a : FV) : neg (neg a) = a := by cases a <;> rfl

/-- Negation reverses the truth order. -/
theorem neg_tle_iff (a b : FV) : tle a b ↔ tle (neg b) (neg a) := by
  cases a <;> cases b <;> simp [tle, neg]

/-- Negation preserves the knowledge order. -/
theorem neg_kle_iff (a b : FV) : kle a b ↔ kle (neg a) (neg b) := by
  cases a <;> cases b <;> simp [kle, neg]

/-- De Morgan for the truth lattice. -/
theorem neg_tmeet (a b : FV) : neg (tmeet a b) = tjoin (neg a) (neg b) := by
  cases a <;> cases b <;> rfl
theorem neg_tjoin (a b : FV) : neg (tjoin a b) = tmeet (neg a) (neg b) := by
  cases a <;> cases b <;> rfl

/-- Negation is a *homomorphism* of the knowledge lattice (it commutes with `⊗`, `⊕`). -/
theorem neg_kmeet (a b : FV) : neg (kmeet a b) = kmeet (neg a) (neg b) := by
  cases a <;> cases b <;> rfl
theorem neg_kjoin (a b : FV) : neg (kjoin a b) = kjoin (neg a) (neg b) := by
  cases a <;> cases b <;> rfl

/-! ### Conflation: knowledge anti-automorphism, truth automorphism -/

theorem conf_conf (a : FV) : conf (conf a) = a := by cases a <;> rfl

/-- Conflation reverses the knowledge order. -/
theorem conf_kle_iff (a b : FV) : kle a b ↔ kle (conf b) (conf a) := by
  cases a <;> cases b <;> simp [kle, conf]

/-- Conflation preserves the truth order. -/
theorem conf_tle_iff (a b : FV) : tle a b ↔ tle (conf a) (conf b) := by
  cases a <;> cases b <;> simp [tle, conf]

/-- Conflation is a homomorphism of the truth lattice. -/
theorem conf_tmeet (a b : FV) : conf (tmeet a b) = tmeet (conf a) (conf b) := by
  cases a <;> cases b <;> rfl
theorem conf_tjoin (a b : FV) : conf (tjoin a b) = tjoin (conf a) (conf b) := by
  cases a <;> cases b <;> rfl

/-- De Morgan for the knowledge lattice under conflation. -/
theorem conf_kmeet (a b : FV) : conf (kmeet a b) = kjoin (conf a) (conf b) := by
  cases a <;> cases b <;> rfl
theorem conf_kjoin (a b : FV) : conf (kjoin a b) = kmeet (conf a) (conf b) := by
  cases a <;> cases b <;> rfl

/-- Negation and conflation commute; their composite is the double-swap involution. -/
theorem neg_conf_comm (a : FV) : neg (conf a) = conf (neg a) := by cases a <;> rfl

/-! ### Paraconsistency, now grounded in the interlacing structure -/

/-- `both` is the knowledge-top and is `neg`-fixed: it is the canonical glut. -/
theorem both_is_neg_fixed_ktop : neg both = both ∧ ∀ a, kle a both :=
  ⟨rfl, kle_both⟩

/-- **Paraconsistency of `FOUR`.** The glut `both` makes a contradiction designated,
yet the contradiction does not entail an arbitrary proposition in the truth order,
and there remains a non-designated value: explosion fails. -/
theorem FOUR_paraconsistent :
    ∃ a : FV, designated (tmeet a (neg a)) ∧
      (∃ b : FV, ¬ tle (tmeet a (neg a)) b) ∧
      (∃ c : FV, ¬ designated c) := by
  refine ⟨both, trivial, ⟨ff, ?_⟩, ⟨ff, id⟩⟩
  simp [tle, tmeet, neg]

/-- **Excluded middle fails** on the gap: `tjoin neither (neg neither)` is not designated. -/
theorem FOUR_paracomplete : ∃ a : FV, ¬ designated (tjoin a (neg a)) := ⟨neither, id⟩

/-- The designated set `{tt, both}` is a *filter* of the truth lattice: it contains the
top, is upward closed, and is closed under truth meet. -/
theorem designated_filter :
    designated tt ∧
    (∀ a b, tle a b → designated a → designated b) ∧
    (∀ a b, designated a → designated b → designated (tmeet a b)) := by
  refine ⟨trivial, ?_, ?_⟩
  · intro a b hab ha; cases a <;> cases b <;> simp_all [tle, designated]
  · intro a b ha hb; cases a <;> cases b <;> simp_all [tmeet, designated]

end DreamLogic.Bilattice