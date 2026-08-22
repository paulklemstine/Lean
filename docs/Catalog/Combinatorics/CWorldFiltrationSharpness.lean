/-
# Sharpness of the Clock-and-Switch Representation

`Combinatorics.CWorldFiltration` proves that every finite rooted directed **partial
order** `P` is a surjective bounded morphic image of `CWorld (Fin 1) (Fin (card P))`,
and that antisymmetry cannot be dropped.  This file supplies the *quantitative* half:
how many clock ticks and switches a representation must spend.

## Main results

* `rank_lt_of_le` / `rank_strictMono` — the **rank** `clock + (number of switches on)`
  is a strictly monotone `ℕ`-valued grading of `CWorld (Fin n) (Fin m)` with values in
  `[0, n + m)`.  Hence every strictly increasing chain in a clock-and-switch world has
  at most `n + m` points.
* `exists_rank_ge` — **chain lifting.**  A surjective bounded morphism lifts a strictly
  increasing chain of the image to a chain of the source whose rank grows by at least
  one at every step.  (No dependent choice: the chain is lifted one step at a time
  inside an induction.)
* `chain_length_lt` — consequently a representable preorder containing a strictly
  increasing chain `c 0 < c 1 < … < c ℓ` forces `ℓ < n + m`: **the height of `P` is a
  lower bound for the resources.**
* `switches_ge_of_chain` and `cardChain_optimal` — specialising to the chain
  `Fin (ℓ+1)`: a one-tick clock needs at least `ℓ` switches, and the catalogued
  morphism `cardChain ℓ` attains exactly `ℓ`.  So `cardChain` is **optimal**, not
  merely an example.
* `representable_of_image` — representability is closed under surjective bounded
  morphic images, so the class of representable finite posets is the closure of the
  clock-and-switch worlds under images.

Together with `card_le_of_morphism` (`|P| ≤ n · 2 ^ m`) these give two independent
lower bounds — logarithmic from cardinality, linear from height — matching the
experimental minima recorded in the Lab Notes of `Combinatorics.CWorldFiltration`
(3-chain `m = 2`, 4-chain `m = 3`, 5-chain `m = 4`; diamond `m = 2`).
-/

import Combinatorics.CWorldFiltration

namespace CWorldFiltration

open Function

/-! ## Part A — The rank grading of a clock-and-switch world -/

/-- The **rank** of a clock-and-switch world: the clock reading plus the number of
switches that are on.  It is the natural grading of the product of a chain and a cube. -/
def rank {n m : ℕ} (w : CWorld (Fin n) (Fin m)) : ℕ :=
  (w.clock : ℕ) + (Finset.univ.filter fun b => w.switch b = true).card

theorem rank_lt {n m : ℕ} (w : CWorld (Fin n) (Fin m)) : rank w < n + m := by
  have h₁ : (w.clock : ℕ) < n := w.clock.isLt
  have h₂ := Finset.card_filter_le (Finset.univ : Finset (Fin m)) (fun b => w.switch b = true)
  simp only [Finset.card_univ, Fintype.card_fin] at h₂
  simp only [rank]
  omega

theorem rank_mono {n m : ℕ} {w v : CWorld (Fin n) (Fin m)} (h : w ≤ v) : rank w ≤ rank v := by
  have hc : (w.clock : ℕ) ≤ (v.clock : ℕ) := h.1
  have hs : (Finset.univ.filter fun b => w.switch b = true) ⊆
      (Finset.univ.filter fun b => v.switch b = true) := by
    intro b hb
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hb ⊢
    exact h.2 b hb
  have := Finset.card_le_card hs
  simp only [rank]
  omega

/-- The rank is a *strictly* monotone grading: a strict step in a clock-and-switch world
either advances the clock or switches something on. -/
theorem rank_strictMono {n m : ℕ} {w v : CWorld (Fin n) (Fin m)} (hle : w ≤ v) (hne : w ≠ v) :
    rank w < rank v := by
  rcases lt_or_eq_of_le (rank_mono hle) with h | h
  · exact h
  · exfalso
    -- equal rank forces equal clock and equal switch set, hence equal worlds
    have hc : (w.clock : ℕ) ≤ (v.clock : ℕ) := hle.1
    have hs : (Finset.univ.filter fun b => w.switch b = true) ⊆
        (Finset.univ.filter fun b => v.switch b = true) := by
      intro b hb
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hb ⊢
      exact hle.2 b hb
    have hcard := Finset.card_le_card hs
    have hclock : (w.clock : ℕ) = (v.clock : ℕ) := by
      simp only [rank] at h; omega
    have hcards : (Finset.univ.filter fun b => w.switch b = true).card =
        (Finset.univ.filter fun b => v.switch b = true).card := by
      simp only [rank] at h; omega
    have hsets : (Finset.univ.filter fun b => w.switch b = true) =
        (Finset.univ.filter fun b => v.switch b = true) := Finset.eq_of_subset_of_card_le hs
      (le_of_eq hcards.symm)
    apply hne
    obtain ⟨w1, w2⟩ := w
    obtain ⟨v1, v2⟩ := v
    have h1 : w1 = v1 := Fin.ext hclock
    subst h1
    have h2 : w2 = v2 := by
      funext b
      have hb : b ∈ (Finset.univ.filter fun b => w2 b = true) ↔
          b ∈ (Finset.univ.filter fun b => v2 b = true) := by rw [hsets]
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hb
      cases hw : w2 b <;> cases hv : v2 b
      · rfl
      · simp [hw, hv] at hb
      · simp [hw, hv] at hb
      · rfl
    simp [h2]

/-! ## Part B — Chain lifting along a bounded morphism -/

/-- **Chain lifting with rank growth.**  If `c 0 < c 1 < … ` is a strictly increasing
chain in a surjective bounded morphic image of a clock-and-switch world, then for every
`ℓ` there is a world of rank at least `ℓ` mapping onto `c ℓ`.  Each step uses the back
condition once, and strictness of the chain forces the lifted step to be strict. -/
theorem exists_rank_ge {Y : Type*} [Preorder Y] {n m : ℕ}
    (f : BddMorphism (CWorld (Fin n) (Fin m)) Y) (hf : Surjective f.toFun) (c : ℕ → Y) :
    ∀ ℓ : ℕ, (∀ i, i < ℓ → c i ≤ c (i + 1) ∧ ¬ c (i + 1) ≤ c i) →
      ∃ w : CWorld (Fin n) (Fin m), f.toFun w = c ℓ ∧ ℓ ≤ rank w := by
  intro ℓ
  induction ℓ with
  | zero =>
      intro _
      obtain ⟨w, hw⟩ := hf (c 0)
      exact ⟨w, hw, Nat.zero_le _⟩
  | succ ℓ ih =>
      intro hchain
      obtain ⟨w, hw, hrank⟩ := ih fun i hi => hchain i (by omega)
      obtain ⟨hstep, hnotback⟩ := hchain ℓ (by omega)
      obtain ⟨v, hwv, hv⟩ := f.back w (c (ℓ + 1)) (by rw [hw]; exact hstep)
      have hne : w ≠ v := by
        rintro rfl
        exact hnotback (by rw [← hv, hw])
      have := rank_strictMono hwv hne
      exact ⟨v, hv, by omega⟩

/-- **Height lower bound.**  A strictly increasing chain with `ℓ + 1` points in a
bounded morphic image of `CWorld (Fin n) (Fin m)` forces `ℓ < n + m`. -/
theorem chain_length_lt {Y : Type*} [Preorder Y] {n m : ℕ}
    (f : BddMorphism (CWorld (Fin n) (Fin m)) Y) (hf : Surjective f.toFun) (c : ℕ → Y)
    (ℓ : ℕ) (hchain : ∀ i, i < ℓ → c i ≤ c (i + 1) ∧ ¬ c (i + 1) ≤ c i) :
    ℓ < n + m := by
  obtain ⟨w, -, hrank⟩ := exists_rank_ge f hf c ℓ hchain
  exact lt_of_le_of_lt hrank (rank_lt w)

/-! ## Part C — Optimality of `cardChain` -/

/-- The tautological chain `0 ≤ 1 ≤ … ≤ ℓ` inside `Fin (ℓ+1)`. -/
def chainPoint (ℓ : ℕ) (i : ℕ) : Fin (ℓ + 1) := ⟨min i ℓ, by omega⟩

theorem chainPoint_strict (ℓ : ℕ) (i : ℕ) (hi : i < ℓ) :
    chainPoint ℓ i ≤ chainPoint ℓ (i + 1) ∧ ¬ chainPoint ℓ (i + 1) ≤ chainPoint ℓ i := by
  constructor
  · simp only [chainPoint, Fin.mk_le_mk]; omega
  · simp only [chainPoint, Fin.mk_le_mk]; omega

/-- **A one-tick clock needs at least `ℓ` switches for the `(ℓ+1)`-chain.** -/
theorem switches_ge_of_chain {m ℓ : ℕ} (f : BddMorphism (CWorld (Fin 1) (Fin m)) (Fin (ℓ + 1)))
    (hf : Surjective f.toFun) : ℓ ≤ m := by
  have := chain_length_lt f hf (chainPoint ℓ) ℓ (fun i hi => chainPoint_strict ℓ i hi)
  omega

/-- **`cardChain` is optimal.**  The least number of switches with which a one-tick
clock-and-switch world maps onto the `(ℓ+1)`-chain is exactly `ℓ`: the catalogued
morphism `cardChain ℓ` realises it, and no smaller cube can. -/
theorem cardChain_optimal (ℓ : ℕ) :
    (∃ f : BddMorphism (CWorld (Fin 1) (Fin ℓ)) (Fin (ℓ + 1)), Surjective f.toFun) ∧
      ∀ m : ℕ, (∃ f : BddMorphism (CWorld (Fin 1) (Fin m)) (Fin (ℓ + 1)), Surjective f.toFun) →
        ℓ ≤ m :=
  ⟨⟨cardChain ℓ, cardChain_surjective ℓ⟩, fun _ ⟨f, hf⟩ => switches_ge_of_chain f hf⟩

/-! ## Part D — Closure of the representable class under images -/

/-- Representability passes to surjective bounded morphic images. -/
theorem representable_of_image {P Q : Type*} [Preorder P] [Preorder Q] (hP : Representable P)
    (g : BddMorphism P Q) (hg : Surjective g.toFun) : Representable Q := by
  obtain ⟨n, m, f, hf⟩ := hP
  exact ⟨n, m, g.comp f, hg.comp hf⟩

/-- Two independent obstructions to representability, side by side: the cardinality bound
(logarithmic in `|P|`) and the height bound (linear in the length of a chain). -/
theorem representation_lower_bounds {P : Type*} [Preorder P] [Fintype P] {n m : ℕ}
    (f : BddMorphism (CWorld (Fin n) (Fin m)) P) (hf : Surjective f.toFun)
    (c : ℕ → P) (ℓ : ℕ) (hchain : ∀ i, i < ℓ → c i ≤ c (i + 1) ∧ ¬ c (i + 1) ≤ c i) :
    Fintype.card P ≤ n * 2 ^ m ∧ ℓ < n + m :=
  ⟨card_le_of_morphism f hf, chain_length_lt f hf c ℓ hchain⟩

end CWorldFiltration