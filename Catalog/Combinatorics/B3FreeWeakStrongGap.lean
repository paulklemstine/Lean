/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The weak/strong gap: `La(n, P)` and `La*(n, P)` can be arbitrarily far apart

The catalog file `Catalog/Bridges/B3FreeFamilies.lean` proves `La(n, P) ≤ La*(n, P)`
(`La_le_LaStar`) and shows that the two invariants *coincide* in the tight regime
`La(d, B_d) = La*(d, B_d) = 2^d - 1` (`La_eq_LaStar_of_card_eq`).  It is therefore
natural to ask whether the weak and the strong extremal functions are ever genuinely
different.  This file settles that question in the strongest possible form: their
*difference* is unbounded, already for a two-element poset.

The witness is the **two-element antichain** `AntiPoset 2` (the discrete order on
`Fin 2`).  A *weak* copy of an antichain imposes no inclusion at all — it is merely an
injection — so a weak `AntiPoset (m+1)`-free family is just a family of at most `m`
sets.  A *strong* copy, in contrast, must be an **induced** copy: two sets that are
incomparable.  Hence a strong `AntiPoset 2`-free family is exactly a chain, and the
longest chain in `2^[n]` has `n + 1` members.

## Main results

* `weakFree_antiPoset_iff` — `F` is weak `AntiPoset m`-free iff `F.card < m`;
* `La_antiPoset` — `La(n, AntiPoset (m+1)) = m` whenever `m ≤ 2 ^ n`;
* `strongFree_antiPoset_two_iff` — `F` is strong `AntiPoset 2`-free iff `F` is a chain
  for inclusion;
* `LaStar_antiPoset_two` — `La*(n, AntiPoset 2) = n + 1`, via an explicit maximal chain
  of initial segments (`initialSeg_strictMono`);
* `La_lt_LaStar_antiPoset_two`, `LaStar_sub_La_antiPoset_two` — the strict separation
  `La(n, AntiPoset 2) < La*(n, AntiPoset 2)` for `n ≥ 1`, with the *exact* gap `n`.
  In particular the inequality `La_le_LaStar` of the catalog is never an equality
  in general, and no bound of the shape `La* ≤ c · La` can hold uniformly in `n`.
-/

import Mathlib
import Bridges.B3FreeFamilies

namespace B3Free

open Finset

/-! ## The discrete (antichain) poset -/

/-- `AntiPoset m` is the `m`-element **antichain**: `Fin m` with the discrete order,
in which `a ≤ b` holds only for `a = b`. -/
def AntiPoset (m : ℕ) : Type := Fin m

instance (m : ℕ) : DecidableEq (AntiPoset m) := inferInstanceAs (DecidableEq (Fin m))

instance (m : ℕ) : Fintype (AntiPoset m) := inferInstanceAs (Fintype (Fin m))

instance (m : ℕ) : PartialOrder (AntiPoset m) where
  le a b := a = b
  le_refl _ := rfl
  le_trans _ _ _ h₁ h₂ := h₁.trans h₂
  le_antisymm _ _ h _ := h

theorem AntiPoset.le_iff {m : ℕ} {a b : AntiPoset m} : a ≤ b ↔ a = b := Iff.rfl

/-- No two elements of an antichain are strictly comparable. -/
theorem AntiPoset.not_lt {m : ℕ} (a b : AntiPoset m) : ¬ a < b := by
  intro h
  exact h.2 (AntiPoset.le_iff.2 (AntiPoset.le_iff.1 h.1).symm)

theorem AntiPoset.card (m : ℕ) : Fintype.card (AntiPoset m) = m := Fintype.card_fin m

variable {α : Type*} [DecidableEq α] [Fintype α]

/-! ## Weak antichain-freeness is a cardinality condition -/

omit [DecidableEq α] [Fintype α] in
/-- A weak copy of an antichain is nothing but an injection: `F` is weak
`AntiPoset m`-free precisely when `F` has fewer than `m` members. -/
theorem weakFree_antiPoset_iff {m : ℕ} {F : Finset (Finset α)} :
    WeakFree F (AntiPoset m) ↔ F.card < m := by
  constructor
  · intro h
    by_contra hcard
    push_neg at hcard
    -- `m ≤ F.card` produces an injection `Fin m ↪ F`
    have hle : Fintype.card (AntiPoset m) ≤ Fintype.card {A : Finset α // A ∈ F} := by
      simpa [AntiPoset.card, Fintype.card_coe] using hcard
    obtain ⟨g⟩ := Function.Embedding.nonempty_of_card_le hle
    refine h ⟨fun p => (g p : Finset α), ⟨?_, ?_⟩, fun p => (g p).2⟩
    · intro p q hpq
      exact g.injective (Subtype.ext hpq)
    · intro p q hpq
      exact absurd hpq (AntiPoset.not_lt p q)
  · rintro hcard ⟨ι, ⟨hinj, -⟩, hmem⟩
    have : m ≤ F.card := by
      have : (Finset.univ : Finset (AntiPoset m)).card ≤ F.card :=
        Finset.card_le_card_of_injOn ι (fun p _ => hmem p) (fun p _ q _ hpq => hinj hpq)
      simpa [AntiPoset.card] using this
    omega

/-- The weak extremal number of an antichain: `La(n, AntiPoset (m+1)) = m`, as soon as
there are at least `m` subsets available. -/
theorem La_antiPoset {m : ℕ} (hm : m ≤ 2 ^ Fintype.card α) :
    La α (AntiPoset (m + 1)) = m := by
  classical
  refine le_antisymm (Finset.sup_le fun F hF => ?_) ?_
  · rw [Finset.mem_filter] at hF
    have := weakFree_antiPoset_iff.1 hF.2
    omega
  · -- an arbitrary family of exactly `m` sets is weak `AntiPoset (m+1)`-free
    have hcard : m ≤ (Finset.univ : Finset (Finset α)).card := by
      simpa [Finset.card_univ, Fintype.card_finset] using hm
    obtain ⟨F, -, hF⟩ := Finset.exists_subset_card_eq hcard
    have : F.card ≤ La α (AntiPoset (m + 1)) :=
      card_le_La (weakFree_antiPoset_iff.2 (by omega))
    omega

/-! ## Strong antichain-freeness means being a chain -/

/-- The first element of the two-element antichain. -/
def z0 : AntiPoset 2 := (0 : Fin 2)

/-- The second element of the two-element antichain. -/
def z1 : AntiPoset 2 := (1 : Fin 2)

theorem z0_ne_z1 : z0 ≠ z1 := by decide

theorem AntiPoset.two_cases (p : AntiPoset 2) : p = z0 ∨ p = z1 := by
  revert p
  decide

omit [Fintype α] in
/-- A strong copy of the two-element antichain is a pair of incomparable sets, so
strong `AntiPoset 2`-freeness says exactly that `F` is a chain for inclusion. -/
theorem strongFree_antiPoset_two_iff {F : Finset (Finset α)} :
    StrongFree F (AntiPoset 2) ↔ ∀ A ∈ F, ∀ B ∈ F, A ⊆ B ∨ B ⊆ A := by
  constructor
  · intro h A hA B hB
    by_contra hcon
    push_neg at hcon
    have hAB : A ≠ B := fun hEq => hcon.1 (hEq ▸ Finset.Subset.refl A)
    set f : AntiPoset 2 → Finset α := fun p => if p = z0 then A else B with hfdef
    have hf0 : f z0 = A := by simp [hfdef]
    have hf1 : f z1 = B := by simp [hfdef, Ne.symm z0_ne_z1]
    refine h ⟨f, ⟨?_, ?_⟩, ?_⟩
    · intro p q hpq
      rcases AntiPoset.two_cases p with rfl | rfl <;> rcases AntiPoset.two_cases q with rfl | rfl
      · rfl
      · rw [hf0, hf1] at hpq; exact absurd hpq hAB
      · rw [hf0, hf1] at hpq; exact absurd hpq.symm hAB
      · rfl
    · intro p q
      refine iff_of_false ?_ (AntiPoset.not_lt p q)
      rcases AntiPoset.two_cases p with rfl | rfl <;> rcases AntiPoset.two_cases q with rfl | rfl
      · rw [hf0]; exact fun hss => absurd rfl hss.ne
      · rw [hf0, hf1]; exact fun hss => hcon.1 hss.subset
      · rw [hf0, hf1]; exact fun hss => hcon.2 hss.subset
      · rw [hf1]; exact fun hss => absurd rfl hss.ne
    · intro p
      rcases AntiPoset.two_cases p with rfl | rfl
      · rw [hf0]; exact hA
      · rw [hf1]; exact hB
  · rintro hchain ⟨ι, ⟨hinj, hstr⟩, hmem⟩
    have h01 : ι z0 ≠ ι z1 := fun hEq => z0_ne_z1 (hinj hEq)
    rcases hchain _ (hmem z0) _ (hmem z1) with hsub | hsub
    · exact AntiPoset.not_lt z0 z1
        ((hstr z0 z1).1 (Finset.ssubset_iff_subset_ne.2 ⟨hsub, h01⟩))
    · exact AntiPoset.not_lt z1 z0
        ((hstr z1 z0).1 (Finset.ssubset_iff_subset_ne.2 ⟨hsub, h01.symm⟩))

/-! ## The maximal chain of initial segments -/

/-- The `i`-th initial segment of `α` with respect to a fixed enumeration. -/
noncomputable def initialSeg (α : Type*) [DecidableEq α] [Fintype α] (i : ℕ) : Finset α :=
  Finset.univ.filter fun a => ((Fintype.equivFin α) a : ℕ) < i

theorem initialSeg_subset {i j : ℕ} (h : i ≤ j) : initialSeg α i ⊆ initialSeg α j := by
  intro a ha
  simp only [initialSeg, Finset.mem_filter, Finset.mem_univ, true_and] at ha ⊢
  omega

/-- The initial segments form a strictly increasing chain of length `n + 1`. -/
theorem initialSeg_strictMono {i j : ℕ} (hij : i < j) (hj : j ≤ Fintype.card α) :
    initialSeg α i ⊂ initialSeg α j := by
  refine Finset.ssubset_iff_of_subset (initialSeg_subset hij.le) |>.2 ?_
  have hi : i < Fintype.card α := lt_of_lt_of_le hij hj
  refine ⟨(Fintype.equivFin α).symm ⟨i, hi⟩, ?_, ?_⟩
  · simp only [initialSeg, Finset.mem_filter, Finset.mem_univ, true_and,
      Equiv.apply_symm_apply]
    exact hij
  · simp only [initialSeg, Finset.mem_filter, Finset.mem_univ, true_and,
      Equiv.apply_symm_apply, not_lt]
    exact le_refl i

/-- The family of all initial segments. -/
noncomputable def initialSegFamily (α : Type*) [DecidableEq α] [Fintype α] : Finset (Finset α) :=
  (Finset.range (Fintype.card α + 1)).image (initialSeg α)

theorem card_initialSegFamily :
    (initialSegFamily α).card = Fintype.card α + 1 := by
  rw [initialSegFamily, Finset.card_image_of_injOn, Finset.card_range]
  intro i hi j hj hij
  simp only [Finset.coe_range, Set.mem_Iio] at hi hj
  by_contra hne
  rcases lt_or_gt_of_ne hne with h | h
  · exact (initialSeg_strictMono (α := α) h (by omega)).ne hij
  · exact (initialSeg_strictMono (α := α) h (by omega)).ne hij.symm

theorem initialSegFamily_strongFree : StrongFree (initialSegFamily α) (AntiPoset 2) := by
  refine strongFree_antiPoset_two_iff.2 ?_
  intro A hA B hB
  simp only [initialSegFamily, Finset.mem_image, Finset.mem_range] at hA hB
  obtain ⟨i, -, rfl⟩ := hA
  obtain ⟨j, -, rfl⟩ := hB
  rcases le_total i j with h | h
  · exact Or.inl (initialSeg_subset h)
  · exact Or.inr (initialSeg_subset h)

/-! ## The exact strong extremal number, and the gap -/

/-- **The strong extremal number of the two-element antichain**: `La*(n, AntiPoset 2)`
is exactly `n + 1`, the length of a maximal chain in `2^[n]`. -/
theorem LaStar_antiPoset_two : LaStar α (AntiPoset 2) = Fintype.card α + 1 := by
  classical
  refine le_antisymm (Finset.sup_le fun F hF => ?_) ?_
  · rw [Finset.mem_filter] at hF
    have hchain := strongFree_antiPoset_two_iff.1 hF.2
    -- distinct members of a chain have distinct cardinalities
    have : F.card ≤ (Finset.range (Fintype.card α + 1)).card := by
      refine Finset.card_le_card_of_injOn Finset.card (fun A hA => ?_) ?_
      · exact Finset.mem_range.2 (Nat.lt_succ_of_le (Finset.card_le_univ A))
      · intro A hA B hB hcard
        rcases hchain _ hA _ hB with hsub | hsub
        · exact Finset.eq_of_subset_of_card_le hsub (le_of_eq hcard.symm)
        · exact (Finset.eq_of_subset_of_card_le hsub (le_of_eq hcard)).symm
    rwa [Finset.card_range] at this
  · have := card_le_LaStar (initialSegFamily_strongFree (α := α))
    rwa [card_initialSegFamily] at this

/-- The weak extremal number of the two-element antichain is `1`. -/
theorem La_antiPoset_two : La α (AntiPoset 2) = 1 :=
  La_antiPoset (m := 1) (Nat.one_le_two_pow)

/-- **Strict separation of the weak and strong extremal functions.**  For every
nonempty ground set, `La(n, AntiPoset 2) < La*(n, AntiPoset 2)`: the catalog inequality
`La_le_LaStar` is strict already for a two-element poset. -/
theorem La_lt_LaStar_antiPoset_two (hn : 1 ≤ Fintype.card α) :
    La α (AntiPoset 2) < LaStar α (AntiPoset 2) := by
  rw [La_antiPoset_two, LaStar_antiPoset_two]
  omega

/-- **The gap is unbounded**: `La*(n, P) - La(n, P) = n` for the two-element antichain,
so no inequality of the form `La* ≤ c · La` can hold with a constant `c` independent
of `n`. -/
theorem LaStar_sub_La_antiPoset_two :
    LaStar α (AntiPoset 2) - La α (AntiPoset 2) = Fintype.card α := by
  rw [La_antiPoset_two, LaStar_antiPoset_two]
  omega

/-- Quantitative form of the previous statement: the ratio `La*/La` is exactly `n + 1`. -/
theorem LaStar_eq_succ_card_mul_La_antiPoset_two :
    LaStar α (AntiPoset 2) = (Fintype.card α + 1) * La α (AntiPoset 2) := by
  rw [La_antiPoset_two, LaStar_antiPoset_two, mul_one]

end B3Free