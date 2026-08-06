import Novelty.ConsistencyTransferSharpness

/-!
# The exact height spectrum of independence and of provable consistency transfer

`Novelty.ConsistencyTransferSharpness` introduced the tag-sensitive Kripke semantics
`satC c` (tag `i` sees `n` from `m` iff `n < m` and `m ≤ c i`) and the family of
finite-height GL theories

  `capC c N := ` all formulas valid at the worlds `0, 1, …, N`.

The accompanying conjecture list (`FUTURE_DIRECTIONS.md`, item 3) proposed a
**height spectrum**: that for `capC c N`

* `Con i` is independent exactly when `1 ≤ c i ≤ N`, and
* `Con i → Con j` is provable exactly when `c i ≤ c j` or `c i = 0`.

This file settles the question completely, and both halves of the conjecture turn
out to be **wrong** — each in the same direction: they forget that the theory only
inspects the worlds `≤ N`, so a height is only ever felt through `min N (c i)`.
The exact answers are

* `capC_Con_independent_iff` :  `Independent (capC c N) (Con i) ↔ 1 ≤ c i ∧ 1 ≤ N`;
* `capC_transfer_iff` :  `Provable (capC c N) (imp (Con i) (Con j)) ↔ min N (c i) ≤ c j`.

The conjectured descriptions are refuted by explicit witnesses
(`height_spectrum_conjecture_false`, `transfer_spectrum_conjecture_false`): with
`N = 1` and a tag of height `2` the sentence `Con i` is independent although
`c i > N`, and `Con i → Con j` is provable for `c i = 2 > 1 = c j`.

Two structural corollaries fall out of the exact description:

* `capC_mutual_transfer_iff` — mutual transfer holds exactly when the two truncated
  heights agree, `min N (c i) = min N (c j)`;
* `capC_mutual_transfer_forces_simultaneous_independence` — an explicit, non-vacuous
  instance of `independence_transfer` inside this family;
* `capC_transfer_not_transitive_free` — provable transfer is *not* determined by the
  raw order of the heights, which is precisely what the failed conjecture assumed.

Finally §5 shows that the truncated height is a **complete invariant**: two height
functions with `min N ∘ c = min N ∘ c'` give literally the same theory
(`provable_capC_congr_of_min_eq`, via the formula induction `satC_eq_of_min_eq`), and
the provable-transfer relation of `capC c N` is always a total preorder
(`capC_transfer_total_preorder`) — namely the pullback of the order on `{0, …, N}`
along `i ↦ min N (c i)`.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form

/-! ## §1. Evaluating the consistency sentences in the tag-sensitive semantics -/

/-- Falsum is false at every world. -/
@[simp] theorem satC_bot (c : ℕ → ℕ) (m : ℕ) : satC c m bot = false := rfl

/-- **Boxed falsum at a world.**  `□ᵢ ⊥` holds at `m` iff `m` has no `⟶ᵢ`-successor,
i.e. iff `m` is the root or `m` lies above the tag's height. -/
theorem satC_box_bot_iff (c : ℕ → ℕ) (m i : ℕ) :
    satC c m (box i bot) = true ↔ (m = 0 ∨ c i < m) := by
  rw [satC_box]
  constructor
  · intro h
    by_cases hle : m ≤ c i
    · left
      by_contra hm
      have h0 := h hle 0 (by omega)
      simp at h0
    · right; omega
  · rintro (rfl | hlt) hle n hn
    · omega
    · omega

/-- **The consistency sentence at a world.**  `Con i` holds at `m` iff `m` is a
non-root world within the tag's height. -/
theorem satC_Con_iff (c : ℕ → ℕ) (m i : ℕ) :
    satC c m (Con i) = true ↔ (1 ≤ m ∧ m ≤ c i) := by
  rw [Con, neg, satC_imp]
  have hb := satC_box_bot_iff c m i
  constructor
  · intro h
    have hnot : ¬ (m = 0 ∨ c i < m) := by
      intro hx
      have := h (hb.2 hx)
      simp at this
    omega
  · rintro ⟨h1, h2⟩ hbox
    exact absurd (hb.1 hbox) (by omega)

/-- The negated consistency sentence at a world. -/
theorem satC_neg_Con_iff (c : ℕ → ℕ) (m i : ℕ) :
    satC c m (neg (Con i)) = true ↔ ¬ (1 ≤ m ∧ m ≤ c i) := by
  rw [neg, satC_imp]
  constructor
  · intro h hm
    have := h ((satC_Con_iff c m i).2 hm)
    simp at this
  · intro h hcon
    exact absurd ((satC_Con_iff c m i).1 hcon) h

/-! ## §2. The exact independence spectrum -/

/-- **No consistency sentence is ever provable** in a truncated tag-sensitive theory:
`Con i` already fails at the root world `0`.  (This is the semantic shadow of Gödel's
second incompleteness theorem, cf. `goedel_second_incompleteness`.) -/
theorem capC_not_provable_Con (c : ℕ → ℕ) (N i : ℕ) :
    ¬ Provable (capC c N) (Con i) := by
  rw [provable_capC]
  intro h
  have h0 := (satC_Con_iff c 0 i).1 (h 0 (Nat.zero_le N))
  omega

/-- **Exactly when a consistency sentence is refuted**: `¬Con i` is provable iff the
tag has height `0` (it sees nothing anywhere) or the theory is the one-world theory
`capC c 0`, in which the only world is the root. -/
theorem capC_provable_neg_Con_iff (c : ℕ → ℕ) (N i : ℕ) :
    Provable (capC c N) (neg (Con i)) ↔ (c i = 0 ∨ N = 0) := by
  rw [provable_capC]
  constructor
  · intro h
    by_contra hx
    push_neg at hx
    have h1 := (satC_neg_Con_iff c 1 i).1 (h 1 (by omega))
    omega
  · intro hx m hm
    rw [satC_neg_Con_iff]
    omega

/-- **The exact height spectrum of independence.**  For the truncated tag-sensitive
theory `capC c N`, the consistency sentence `Con i` is independent precisely when the
tag has positive height *and* the theory has at least two worlds.  In particular the
conjectured upper constraint `c i ≤ N` is spurious. -/
theorem capC_Con_independent_iff (c : ℕ → ℕ) (N i : ℕ) :
    Independent (capC c N) (Con i) ↔ (1 ≤ c i ∧ 1 ≤ N) := by
  constructor
  · rintro ⟨-, hneg⟩
    have := (capC_provable_neg_Con_iff c N i).not.1 hneg
    push_neg at this
    omega
  · rintro ⟨h1, h2⟩
    refine ⟨capC_not_provable_Con c N i, ?_⟩
    rw [capC_provable_neg_Con_iff]
    omega

/-- **The conjectured spectrum is false.**  With `N = 1` and every tag of height `2`,
`Con 0` is independent of `capC c 1` even though `c 0 = 2 > 1 = N`.  So independence
is not confined to the range `1 ≤ c i ≤ N`. -/
theorem height_spectrum_conjecture_false :
    ∃ (c : ℕ → ℕ) (N i : ℕ), Independent (capC c N) (Con i) ∧ ¬ (c i ≤ N) :=
  ⟨fun _ => 2, 1, 0, (capC_Con_independent_iff _ _ _).2 ⟨by norm_num, le_rfl⟩,
    by norm_num⟩

/-! ## §3. The exact transfer spectrum -/

/-- **The exact spectrum of provable consistency transfer.**  `capC c N` proves
`Con i → Con j` precisely when the *truncated* height of `i` is at most the height of
`j`.  Only `min N (c i)` matters, because the theory never inspects a world above
`N`. -/
theorem capC_transfer_iff (c : ℕ → ℕ) (N i j : ℕ) :
    Provable (capC c N) (imp (Con i) (Con j)) ↔ min N (c i) ≤ c j := by
  rw [provable_capC]
  constructor
  · intro h
    by_cases hz : min N (c i) = 0
    · omega
    · have hm := h (min N (c i)) (by omega)
      rw [satC_imp] at hm
      have := (satC_Con_iff c (min N (c i)) j).1
        (hm ((satC_Con_iff c (min N (c i)) i).2 (by omega)))
      omega
  · intro hmin m hm
    rw [satC_imp]
    intro hcon
    have := (satC_Con_iff c m i).1 hcon
    exact (satC_Con_iff c m j).2 (by omega)

/-- **The conjectured transfer description is false.**  Take `N = 1`, `c 0 = 2` and
`c 1 = 1`.  Then `capC c 1` proves `Con 0 → Con 1` although `c 0 = 2` is neither `0`
nor `≤ c 1 = 1`. -/
theorem transfer_spectrum_conjecture_false :
    ∃ (c : ℕ → ℕ) (N i j : ℕ),
      Provable (capC c N) (imp (Con i) (Con j)) ∧ c i ≠ 0 ∧ ¬ (c i ≤ c j) := by
  refine ⟨fun k => if k = 0 then 2 else 1, 1, 0, 1, ?_, by norm_num, by norm_num⟩
  rw [capC_transfer_iff]
  norm_num

/-- Provable transfer is **not** a function of the raw order of the heights: there are
two configurations with the same comparison `c j < c i` and the same nonzero `c i`,
one of which proves the transfer implication and one of which does not.  Hence any
description of the transfer spectrum must mention the truncation bound `N`. -/
theorem capC_transfer_not_transitive_free :
    ∃ (c : ℕ → ℕ) (N N' i j : ℕ), c j < c i ∧ c i ≠ 0 ∧
      Provable (capC c N) (imp (Con i) (Con j)) ∧
      ¬ Provable (capC c N') (imp (Con i) (Con j)) := by
  refine ⟨fun k => if k = 0 then 2 else 1, 1, 2, 0, 1, by norm_num, by norm_num, ?_, ?_⟩
  · rw [capC_transfer_iff]; norm_num
  · rw [capC_transfer_iff]; norm_num

/-! ## §4. Mutual transfer and simultaneous independence -/

/-- **Mutual transfer is truncated-height equality.**  `capC c N` proves both
`Con i → Con j` and `Con j → Con i` iff `min N (c i) = min N (c j)`. -/
theorem capC_mutual_transfer_iff (c : ℕ → ℕ) (N i j : ℕ) :
    (Provable (capC c N) (imp (Con i) (Con j)) ∧
        Provable (capC c N) (imp (Con j) (Con i))) ↔
      min N (c i) = min N (c j) := by
  rw [capC_transfer_iff, capC_transfer_iff]
  omega

/-- **A non-vacuous instance of `independence_transfer`.**  Whenever the two truncated
heights agree, the two consistency sentences are independent simultaneously — as the
abstract transfer theorem predicts, here verified directly from the exact spectrum. -/
theorem capC_mutual_transfer_forces_simultaneous_independence
    (c : ℕ → ℕ) (N i j : ℕ) (h : min N (c i) = min N (c j)) :
    (Independent (capC c N) (Con i) ↔ Independent (capC c N) (Con j)) := by
  rw [capC_Con_independent_iff, capC_Con_independent_iff]
  omega

/-- **Every tag of positive height is independent in every multi-world theory**, and
in the one-world theory `capC c 0` no consistency sentence is independent at all: the
number of worlds alone decides whether independence is possible. -/
theorem capC_zero_world_no_independence (c : ℕ → ℕ) (i : ℕ) :
    ¬ Independent (capC c 0) (Con i) := by
  rw [capC_Con_independent_iff]
  omega

/-! ## §5. Truncated height is a complete invariant -/

/-- **Only the truncated heights are visible below the bound.**  If two height
functions have the same truncation `min N ∘ c`, then they satisfy exactly the same
formulas at every world `m ≤ N`.  (The proof is a formula induction; in the box case
`m ≤ c i ↔ m ≤ min N (c i)` because `m ≤ N`.) -/
theorem satC_eq_of_min_eq {c c' : ℕ → ℕ} {N : ℕ}
    (h : ∀ i, min N (c i) = min N (c' i)) :
    ∀ (a : Form) (m : ℕ), m ≤ N → satC c m a = satC c' m a := by
  intro a
  induction a with
  | bot => intro m _; rfl
  | atom _ => intro m _; rfl
  | imp a b iha ihb =>
      intro m hm; simp only [satC, iha m hm, ihb m hm]
  | box i a ih =>
      intro m hm
      have hci := h i
      rw [Bool.eq_iff_iff, satC_box, satC_box]
      constructor
      · intro hb hle n hn
        rw [← ih n (by omega)]
        exact hb (by omega) n hn
      · intro hb hle n hn
        rw [ih n (by omega)]
        exact hb (by omega) n hn

/-- **The truncated height is a complete invariant of a tag.**  Two height functions
with the same truncation `min N ∘ c` generate literally the same theory `capC c N`:
no formula whatsoever can distinguish them.  In particular the exact spectra of §2–§3
really do capture everything the theory knows about a tag. -/
theorem provable_capC_congr_of_min_eq {c c' : ℕ → ℕ} {N : ℕ}
    (h : ∀ i, min N (c i) = min N (c' i)) (a : Form) :
    Provable (capC c N) a ↔ Provable (capC c' N) a := by
  rw [provable_capC, provable_capC]
  constructor <;> intro hp m hm
  · rw [← satC_eq_of_min_eq h a m hm]; exact hp m hm
  · rw [satC_eq_of_min_eq h a m hm]; exact hp m hm

/-- **The provable-transfer relation is a total preorder.**  Writing `i ≼ j` for
`Provable (capC c N) (imp (Con i) (Con j))`, the relation is reflexive, transitive and
total — it is the pullback along `i ↦ min N (c i)` of the order on `{0, …, N}`. -/
theorem capC_transfer_total_preorder (c : ℕ → ℕ) (N : ℕ) :
    (∀ i, Provable (capC c N) (imp (Con i) (Con i))) ∧
      (∀ i j k, Provable (capC c N) (imp (Con i) (Con j)) →
        Provable (capC c N) (imp (Con j) (Con k)) →
        Provable (capC c N) (imp (Con i) (Con k))) ∧
      (∀ i j, Provable (capC c N) (imp (Con i) (Con j)) ∨
        Provable (capC c N) (imp (Con j) (Con i))) := by
  refine ⟨fun i => ?_, fun i j k hij hjk => ?_, fun i j => ?_⟩
  · rw [capC_transfer_iff]; omega
  · rw [capC_transfer_iff] at hij hjk ⊢; omega
  · rw [capC_transfer_iff, capC_transfer_iff]; omega

/-- **Summary: the corrected height spectrum.**  Both halves of the conjecture are
replaced by exact biconditionals, and both original formulations are refuted. -/
theorem corrected_height_spectrum :
    (∀ (c : ℕ → ℕ) (N i : ℕ),
        Independent (capC c N) (Con i) ↔ (1 ≤ c i ∧ 1 ≤ N)) ∧
      (∀ (c : ℕ → ℕ) (N i j : ℕ),
        Provable (capC c N) (imp (Con i) (Con j)) ↔ min N (c i) ≤ c j) ∧
      (∃ (c : ℕ → ℕ) (N i : ℕ), Independent (capC c N) (Con i) ∧ ¬ (c i ≤ N)) ∧
      (∃ (c : ℕ → ℕ) (N i j : ℕ),
        Provable (capC c N) (imp (Con i) (Con j)) ∧ c i ≠ 0 ∧ ¬ (c i ≤ c j)) :=
  ⟨capC_Con_independent_iff, capC_transfer_iff, height_spectrum_conjecture_false,
    transfer_spectrum_conjecture_false⟩

end PhysicsConsistency