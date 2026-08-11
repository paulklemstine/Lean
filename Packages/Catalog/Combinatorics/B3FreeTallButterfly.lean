/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tall butterflies: one obstruction unifying the layer freeness theorems

`Catalog/Combinatorics/B3FreeButterfly.lean` proves that two consecutive layers of the cube
are weak `P`-free as soon as `P` contains a *butterfly* (two distinct elements below two
distinct elements).  `Catalog/Bridges/B3FreeFamilies.lean` proves separately that `d`
consecutive layers are weak `B_d`-free.  This file shows that both are instances of a
single **rank-rigidity** principle.

Say `P` has a **tall butterfly of height `m`** if it contains two distinct elements
`p₁, p₂`, each of them at the top of a chain of `m + 1` elements of `P`, and two distinct
elements `q₁, q₂` lying strictly above both `p₁` and `p₂`.  The main theorem
`layers_weakFree_of_hasTallButterfly` says that `m + 2` consecutive layers of `2^[n]` are
then weak `P`-free.

The mechanism: inside `m + 2` consecutive layers, a chain of `m + 2` sets has its sizes
*pinned* (`card_eq_of_chain_in_layers`), so `ι p₁` and `ι p₂` both have size `a + m` and
`ι q₁`, `ι q₂` both have size `a + m + 1`; since `ι q_j ⊇ ι p₁ ∪ ι p₂` and the union of two
distinct sets of size `a + m` already has size `a + m + 1`, both `ι q_j` are equal to that
union — contradicting injectivity.

## Main results

* `card_eq_of_chain_in_layers` — rank rigidity: a chain of `L` sets inside `L` consecutive
  layers occupies each layer exactly once, in order.
* `HasTallButterfly`, `layers_weakFree_of_hasTallButterfly` — the obstruction and the
  `m + 2`-layer freeness theorem.
* `hasTallButterfly_zero_iff_hasButterfly`, `layers_weakFree_of_hasButterfly'` — the case
  `m = 0` is exactly the butterfly theorem of `B3FreeButterfly.lean`.
* `hasTallButterfly_boolLat3`, `layers_weakFree_boolLat3_of_tallButterfly` — the case
  `m = 1` re-derives the catalog theorem that three consecutive layers are weak `B_3`-free,
  from the general principle.
* `window_le_La_of_hasTallButterfly` — the resulting lower bound
  `∑` of the `m + 2` largest binomial coefficients `≤ La(n, P)`.
-/

import Mathlib
import Bridges.B3FreeFamilies
import Bridges.B3FreeFamiliesBounds
import Bridges.B3FreeFamiliesLevels
import Combinatorics.B3FreeAntichainMonotone
import Combinatorics.B3FreeKSperner
import Combinatorics.B3FreePosetBracket
import Combinatorics.B3FreeButterfly

namespace B3Free

open Finset

variable {α : Type*} [DecidableEq α] [Fintype α]

/-! ## Rank rigidity inside a window of layers -/

/-- A strictly monotone `ℕ`-valued function on `Fin L` bounded below by `a` grows at least
one step at a time. -/
private theorem add_le_of_strictMono {L a : ℕ} {f : Fin L → ℕ} (hf : StrictMono f)
    (h0 : ∀ i, a ≤ f i) : ∀ (i : ℕ) (hi : i < L), a + i ≤ f ⟨i, hi⟩ := by
  intro i
  induction i with
  | zero => intro hi; simpa using h0 ⟨0, hi⟩
  | succ j ih =>
    intro hi
    have hj : j < L := by omega
    have h1 := ih hj
    have h2 : f ⟨j, hj⟩ < f ⟨j + 1, hi⟩ := hf (by simp [Fin.lt_def])
    omega

omit [DecidableEq α] [Fintype α] in
/-- **Rank rigidity.**  A chain of `L` sets all of whose members lie in the `L` consecutive
layers starting at `a` must meet each of those layers exactly once, in increasing order:
the `i`-th set of the chain has size exactly `a + i`. -/
theorem card_eq_of_chain_in_layers {a L : ℕ} {c : Fin L → Finset α} (hc : StrictMono c)
    (hmem : ∀ i, a ≤ (c i).card ∧ (c i).card < a + L) (i : Fin L) :
    (c i).card = a + (i : ℕ) := by
  classical
  have hf : StrictMono (fun i => (c i).card) := fun i j hij =>
    Finset.card_lt_card (Finset.lt_iff_ssubset.1 (hc hij))
  have hlow := add_le_of_strictMono (f := fun i => (c i).card) hf (fun i => (hmem i).1)
      (i : ℕ) i.isLt
  -- the same bound applied to the reversed chain gives the upper bound
  have hg : StrictMono (fun j : Fin L => (2 * a + L - 1) - (c j.rev).card) := by
    intro j₁ j₂ hj
    have hrev : j₂.rev < j₁.rev := Fin.rev_lt_rev.2 hj
    have hlt : (c j₂.rev).card < (c j₁.rev).card := hf hrev
    have h1 := (hmem j₁.rev).1
    have h2 := (hmem j₁.rev).2
    have h3 := (hmem j₂.rev).1
    have h4 := (hmem j₂.rev).2
    simp only []
    omega
  have hg0 : ∀ j : Fin L, a ≤ (2 * a + L - 1) - (c j.rev).card := by
    intro j
    have h1 := (hmem j.rev).1
    have h2 := (hmem j.rev).2
    omega
  have hrevbound := add_le_of_strictMono hg hg0 (i.rev : ℕ) i.rev.isLt
  have hrev_eta : (⟨(i.rev : ℕ), i.rev.isLt⟩ : Fin L) = i.rev := rfl
  rw [hrev_eta] at hrevbound
  simp only [Fin.rev_rev] at hrevbound
  have hval : (i.rev : ℕ) = L - (i + 1) := Fin.val_rev i
  have hi := i.isLt
  have hub := (hmem i).2
  have hlb := (hmem i).1
  have hlow' : a + (i : ℕ) ≤ (c i).card := hlow
  have hrev' : a + (i.rev : ℕ) ≤ 2 * a + L - 1 - (c i).card := hrevbound
  omega
/-! ## Tall butterflies -/

/-- `P` has a **tall butterfly of height `m`**: two distinct elements `p₁, p₂`, each at the
top of a chain of `m + 1` elements, lie strictly below two distinct elements `q₁, q₂`. -/
def HasTallButterfly (P : Type*) [Preorder P] (m : ℕ) : Prop :=
  ∃ (p₁ p₂ q₁ q₂ : P) (c₁ c₂ : Fin (m + 1) → P),
    StrictMono c₁ ∧ StrictMono c₂ ∧ c₁ (Fin.last m) = p₁ ∧ c₂ (Fin.last m) = p₂ ∧
      p₁ ≠ p₂ ∧ q₁ ≠ q₂ ∧ p₁ < q₁ ∧ p₁ < q₂ ∧ p₂ < q₁ ∧ p₂ < q₂

section Aux

variable {P : Type*} [Preorder P]

/-- Appending a strictly larger element on top of a chain gives a chain. -/
theorem strictMono_snoc {m : ℕ} {c : Fin (m + 1) → P} (hc : StrictMono c) {q : P}
    (hq : c (Fin.last m) < q) : StrictMono (Fin.snoc c q : Fin (m + 2) → P) := by
  intro i j hij
  rcases Fin.eq_castSucc_or_eq_last j with ⟨j', rfl⟩ | rfl
  · rcases Fin.eq_castSucc_or_eq_last i with ⟨i', rfl⟩ | rfl
    · simp only [Fin.snoc_castSucc]
      exact hc (Fin.castSucc_lt_castSucc_iff.1 hij)
    · exfalso
      have h1 : ((Fin.last (m + 1)) : ℕ) < (j'.castSucc : ℕ) := hij
      have h2 := j'.isLt
      simp only [Fin.val_last, Fin.val_castSucc] at h1
      omega
  · rcases Fin.eq_castSucc_or_eq_last i with ⟨i', rfl⟩ | rfl
    · simp only [Fin.snoc_castSucc, Fin.snoc_last]
      exact lt_of_le_of_lt (hc.monotone (Fin.le_last i')) hq
    · exact absurd hij (lt_irrefl _)

end Aux

/-- **The tall butterfly obstruction.**  If `P` has a tall butterfly of height `m`, then
`m + 2` consecutive layers of the cube are weak `P`-free. -/
theorem layers_weakFree_of_hasTallButterfly {P : Type*} [Preorder P] {m : ℕ}
    (hP : HasTallButterfly P m) (a : ℕ) : WeakFree (layers α a (m + 2)) P := by
  classical
  obtain ⟨p₁, p₂, q₁, q₂, c₁, c₂, hc₁, hc₂, hp₁, hp₂, hpne, hqne, h11, h12, h21, h22⟩ := hP
  rintro ⟨ι, ⟨hinj, hmono⟩, hmem⟩
  have hsize : ∀ x : P, a ≤ (ι x).card ∧ (ι x).card < a + (m + 2) := fun x =>
    mem_layers.1 (hmem x)
  -- the size of `ι p` and of `ι q` are pinned down by rank rigidity
  have hpin : ∀ (c : Fin (m + 1) → P), StrictMono c → ∀ q : P, c (Fin.last m) < q →
      (ι (c (Fin.last m))).card = a + m ∧ (ι q).card = a + m + 1 := by
    intro c hc q hq
    have hsnoc : StrictMono (Fin.snoc c q : Fin (m + 2) → P) := strictMono_snoc hc hq
    have hchain : StrictMono (fun i : Fin (m + 2) => ι ((Fin.snoc c q : Fin (m + 2) → P) i)) := by
      intro i j hij
      exact Finset.lt_iff_ssubset.2 (hmono _ _ (hsnoc hij))
    have hmem' : ∀ i : Fin (m + 2),
        a ≤ (ι ((Fin.snoc c q : Fin (m + 2) → P) i)).card ∧
          (ι ((Fin.snoc c q : Fin (m + 2) → P) i)).card < a + (m + 2) := fun i => hsize _
    have hlast := card_eq_of_chain_in_layers (α := α) hchain hmem' (Fin.last (m + 1))
    have hprev := card_eq_of_chain_in_layers (α := α) hchain hmem'
      ((Fin.last m).castSucc)
    simp only [Fin.snoc_last, Fin.snoc_castSucc, Fin.val_last, Fin.val_castSucc] at hlast hprev
    exact ⟨hprev, by omega⟩
  obtain ⟨hcp₁, hcq₁⟩ := hpin c₁ hc₁ q₁ (by rw [hp₁]; exact h11)
  obtain ⟨hcp₂, hcq₂⟩ := hpin c₂ hc₂ q₁ (by rw [hp₂]; exact h21)
  obtain ⟨-, hcq₂'⟩ := hpin c₁ hc₁ q₂ (by rw [hp₁]; exact h12)
  rw [hp₁] at hcp₁
  rw [hp₂] at hcp₂
  -- the two lower sets are distinct, so their union already fills the upper layer
  have hne : ι p₁ ≠ ι p₂ := fun hEq => hpne (hinj hEq)
  have hunion_lt : a + m < (ι p₁ ∪ ι p₂).card := by
    have := card_lt_card_union_of_ne (α := α) hne (by omega)
    omega
  have hforced : ∀ j : P, p₁ < j → p₂ < j → (ι j).card = a + m + 1 → ι j = ι p₁ ∪ ι p₂ := by
    intro j hj1 hj2 hjcard
    have hsub : ι p₁ ∪ ι p₂ ⊆ ι j :=
      Finset.union_subset (hmono p₁ j hj1).subset (hmono p₂ j hj2).subset
    exact (Finset.eq_of_subset_of_card_le hsub (by omega)).symm
  exact hqne (hinj ((hforced q₁ h11 h21 hcq₁).trans (hforced q₂ h12 h22 hcq₂').symm))

/-- **The layer lower bound from a tall butterfly.**  `La(n, P)` is at least the sum of the
`m + 2` largest binomial coefficients. -/
theorem window_le_La_of_hasTallButterfly {P : Type*} [Preorder P] {m : ℕ}
    (hP : HasTallButterfly P m) :
    (layers α (centralStart (Fintype.card α) (m + 2)) (m + 2)).card ≤ La α P :=
  card_le_La (layers_weakFree_of_hasTallButterfly hP _)

/-! ## The two special cases -/

/-- Height `0` tall butterflies are exactly butterflies. -/
theorem hasTallButterfly_zero_iff_hasButterfly {P : Type*} [Preorder P] :
    HasTallButterfly P 0 ↔ HasButterfly P := by
  constructor
  · rintro ⟨p₁, p₂, q₁, q₂, -, -, -, -, -, -, hpne, hqne, h11, h12, h21, h22⟩
    exact ⟨p₁, p₂, q₁, q₂, hpne, hqne, h11, h12, h21, h22⟩
  · rintro ⟨p₁, p₂, q₁, q₂, hpne, hqne, h11, h12, h21, h22⟩
    exact ⟨p₁, p₂, q₁, q₂, fun _ => p₁, fun _ => p₂,
      (fun i j hij => by
        exfalso
        have h1 : (i : ℕ) < 1 := i.isLt
        have h2 : (j : ℕ) < 1 := j.isLt
        have h3 : (i : ℕ) < (j : ℕ) := hij
        omega),
      (fun i j hij => by
        exfalso
        have h1 : (i : ℕ) < 1 := i.isLt
        have h2 : (j : ℕ) < 1 := j.isLt
        have h3 : (i : ℕ) < (j : ℕ) := hij
        omega),
      rfl, rfl, hpne, hqne, h11, h12, h21, h22⟩

/-- The butterfly theorem of `B3FreeButterfly.lean`, re-derived from rank rigidity. -/
theorem layers_weakFree_of_hasButterfly' {P : Type*} [Preorder P] (hP : HasButterfly P)
    (a : ℕ) : WeakFree (layers α a 2) P :=
  layers_weakFree_of_hasTallButterfly (hasTallButterfly_zero_iff_hasButterfly.2 hP) a

/-- The Boolean lattice `B_3` has a tall butterfly of height `1`: the chains
`∅ ⊂ {0}` and `∅ ⊂ {1}` sit below the two distinct sets `{0,1}` and `{0,1,2}`. -/
theorem hasTallButterfly_boolLat3 : HasTallButterfly (BoolLat 3) 1 := by
  classical
  refine ⟨{0}, {1}, {0, 1}, {0, 1, 2},
    (fun i => if (i : ℕ) = 0 then ∅ else {0}), (fun i => if (i : ℕ) = 0 then ∅ else {1}),
    ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all
  · intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all
  · rfl
  · rfl
  · decide
  · decide
  · decide
  · decide
  · decide
  · decide

/-- **Three consecutive layers are weak `B_3`-free**, re-derived from the tall butterfly
principle (compare `layers_weakFree` of `Catalog/Bridges/B3FreeFamilies.lean`, proved there
by a completely different, `B_d`-specific argument). -/
theorem layers_weakFree_boolLat3_of_tallButterfly (a : ℕ) :
    WeakFree (layers α a 3) (BoolLat 3) :=
  layers_weakFree_of_hasTallButterfly hasTallButterfly_boolLat3 a

end B3Free