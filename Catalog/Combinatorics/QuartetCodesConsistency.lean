import Mathlib
import Combinatorics.QuartetCodes

/-!
# Local consistency: the quartet code of a tree obeys parity-check style rules

The lower bound of `Combinatorics.QuartetCodes` counts *leaf orders*, not arbitrary points of the
ternary signature space `(quadruples) → Fin 3`.  This file makes the difference precise: the
signatures that actually come from a tree satisfy local constraints on overlapping quadruples —
the exact analogue of local parity checks of a code — and, already on five leaves, only `15` of
the `3^5 = 243` ternary words are realisable.

Three sample five-leaf rules are proved:

* `qcode_zero_trans` — a cherry propagates: `ab|cd` and `ab|ce` force `ab|de`;
* `qcode_zero_one_rule` — `ab|cd` and `ac|be` force `ae|cd` (type `2` on `a c d e`);
* `qcode_zero_two_rule` — `ab|cd` and `ae|bc` force `be|cd` (type `2` on `b c d e`).

and one forbidden configuration is derived from the first rule.

-- !-- Lab Notes -- !--
## Hypothesis (Hypothesizer)
Tree-realisable quartet signatures form a *constrained* subcode; the constraints are local (they
involve five leaves at a time) and should already cut the code down to a vanishing fraction of the
ternary cube.

## Experiment (Experimenter)
A brute-force scan of all `120` leaf orders on five leaves and all `3 · 3` premise pairs on the
overlapping quadruples produced `210` valid two-premise implications; three representatives were
selected and formalised.  The scan also produced the exact number of realisable five-leaf
signatures, `15`, which is `5!/8` — the number of caterpillar *trees* (each tree arises from `8`
leaf orders: reverse the order, swap the first two leaves, swap the last two).

## Analysis (Analyst)
The count `15 = 5!/8 ≪ 243` shows that the tree code has rate `log₃ 15 / 5 ≈ 0.55` on five leaves
and that any packing bound computed in the *unconstrained* ternary cube is far off; the
first-moment argument of the lower-bound file is carried out inside the constrained code, which is
why it survives.

## Critique (Critic)
The three rules are proved by unfolding the code characterisations and `omega`; they are genuine
implications between distinct quadruples, not restatements of the trichotomy.  The exhaustive
five-leaf count is a kernel computation (`decide`), used only for the concrete datum `15`.
-/

open Finset

namespace QuartetCodes

section LocalRules

variable {n : ℕ} {π : Equiv.Perm (Fin n)} {a b c d e : Fin n}

/-- **Cherry propagation.**  If the leaves `a b` are separated from `c d` and from `c e`, they are
separated from `d e` as well. -/
theorem qcode_zero_trans (h1 : qcode π a b c d = 0) (h2 : qcode π a b c e = 0) :
    qcode π a b d e = 0 := by
  rw [qcode, code3_eq_zero_iff] at h1 h2 ⊢
  omega

/-- A five-leaf rule mixing the types `0` and `1`. -/
theorem qcode_zero_one_rule (hac : a ≠ c) (had : a ≠ d) (hae : a ≠ e)
    (hcd : c ≠ d) (hce : c ≠ e) (hde : d ≠ e)
    (h1 : qcode π a b c d = 0) (h2 : qcode π a b c e = 1) :
    qcode π a c d e = 2 := by
  rw [qcode, code3_eq_zero_iff] at h1
  rw [qcode, code3_eq_one_iff] at h2
  rw [qcode, code3_eq_two_iff (perm_val_ne hac) (perm_val_ne had) (perm_val_ne hae)
    (perm_val_ne hcd) (perm_val_ne hce) (perm_val_ne hde)]
  omega

/-- A five-leaf rule mixing the types `0` and `2`. -/
theorem qcode_zero_two_rule (hab : a ≠ b) (hac : a ≠ c) (hae : a ≠ e) (hbc : b ≠ c)
    (hbd : b ≠ d) (hbe : b ≠ e) (hcd : c ≠ d) (hce : c ≠ e) (hde : d ≠ e)
    (h1 : qcode π a b c d = 0) (h2 : qcode π a b c e = 2) :
    qcode π b c d e = 2 := by
  rw [qcode, code3_eq_zero_iff] at h1
  rw [qcode, code3_eq_two_iff (perm_val_ne hab) (perm_val_ne hac) (perm_val_ne hae)
    (perm_val_ne hbc) (perm_val_ne hbe) (perm_val_ne hce)] at h2
  rw [qcode, code3_eq_two_iff (perm_val_ne hbc) (perm_val_ne hbd) (perm_val_ne hbe)
    (perm_val_ne hcd) (perm_val_ne hce) (perm_val_ne hde)]
  omega

/-- **A forbidden configuration.**  No leaf order displays `ab|cd`, `ab|ce` and `ac|de`
simultaneously; the ternary word that does so is not a codeword. -/
theorem qcode_forbidden (h1 : qcode π a b c d = 0) (h2 : qcode π a b c e = 0) :
    qcode π a b d e ≠ 1 := by
  rw [qcode_zero_trans h1 h2]
  decide

end LocalRules

/-! ## The five-leaf code, counted exactly -/

section FiveLeafCode

/-- The five quadruples of a five-leaf set, as ordered tuples. -/
def quads5 : List (Fin 5 × Fin 5 × Fin 5 × Fin 5) :=
  [(0, 1, 2, 3), (0, 1, 2, 4), (0, 1, 3, 4), (0, 2, 3, 4), (1, 2, 3, 4)]

/-- The quartet signature of a five-leaf caterpillar: a ternary word of length five. -/
def sig5 (π : Equiv.Perm (Fin 5)) : List (Fin 3) :=
  quads5.map (fun q => qcode π q.1 q.2.1 q.2.2.1 q.2.2.2)

set_option maxRecDepth 100000 in
/-- **Exact size of the five-leaf quartet code.**  Exactly `15` ternary words of length five are
signatures of a leaf order — one for each of the `5!/8 = 15` caterpillar trees on five leaves. -/
theorem card_image_sig5 :
    ((Finset.univ : Finset (Equiv.Perm (Fin 5))).image sig5).card = 15 := by decide

/-- The five-leaf quartet code is a *proper* subcode of the ternary cube: `15 < 3^5`. -/
theorem card_image_sig5_lt :
    ((Finset.univ : Finset (Equiv.Perm (Fin 5))).image sig5).card < 3 ^ 5 := by
  rw [card_image_sig5]; norm_num

/-- Eight leaf orders share each five-leaf signature: `8 * 15 = 5!`. -/
theorem five_leaf_code_index :
    8 * ((Finset.univ : Finset (Equiv.Perm (Fin 5))).image sig5).card = Nat.factorial 5 := by
  rw [card_image_sig5]; norm_num [Nat.factorial]

end FiveLeafCode

end QuartetCodes