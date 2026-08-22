/-
# One Switch per Non-Root Point Suffices — and for Chains That Is Optimal

`Combinatorics.CWorldFiltration` represents a finite rooted directed poset `P` using
`card P` switches, one per point.  The switch attached to the root is a no-op: the
greedy climb starts at the root, so the root's jump can never move it.  This file
removes that switch, proving the sharp bound

    switches needed  ≤  card P - 1,

and combines it with the height lower bound of `Combinatorics.CWorldFiltrationSharpness`
to show that the bound is **attained** on chains: the `(ℓ+1)`-chain needs exactly `ℓ`
switches, no more and no fewer.

The proof reuses the greedy climb `walk` verbatim; only the bookkeeping changes.  The
enumeration is shifted so that switch `i` carries the `(i+1)`-st point of a linear
extension (`enum_zero_eq_root` shows the root always comes first), and the back
condition acquires one extra case: the root itself is reached with no switches at all,
because it is below everything and the order is antisymmetric.
-/

import Combinatorics.CWorldFiltration
import Combinatorics.CWorldFiltrationSharpness

namespace CWorldFiltration

open Function

/-- Forgetting the last `b` switches is a surjective bounded morphism: spare switches are
harmless. -/
def dropSwitches (a b : ℕ) :
    BddMorphism (CWorld (Fin 1) (Fin (a + b))) (CWorld (Fin 1) (Fin a)) where
  toFun w := ⟨0, fun i => w.switch (Fin.castAdd b i)⟩
  forth _ _ h := ⟨le_rfl, fun i hi => h.2 _ hi⟩
  back w v h := by
    refine ⟨⟨w.clock, fun j => if hj : (j : ℕ) < a then v.switch ⟨j, hj⟩ else w.switch j⟩,
      ⟨le_rfl, ?_⟩, ?_⟩
    · intro j hj
      by_cases hja : (j : ℕ) < a
      · simp only [dif_pos hja]
        refine h.2 ⟨j, hja⟩ ?_
        show w.switch (Fin.castAdd b ⟨(j : ℕ), hja⟩) = true
        rwa [show Fin.castAdd b (⟨(j : ℕ), hja⟩ : Fin a) = j from Fin.ext rfl]
      · simpa [dif_neg hja] using hj
    · obtain ⟨v1, v2⟩ := v
      show (⟨0, _⟩ : CWorld (Fin 1) (Fin a)) = ⟨v1, v2⟩
      simp only [CWorld.mk.injEq]
      exact ⟨Subsingleton.elim _ _, by funext i; simp⟩

theorem dropSwitches_surjective (a b : ℕ) : Surjective (dropSwitches a b).toFun := by
  intro v
  refine ⟨⟨0, fun j => if hj : (j : ℕ) < a then v.switch ⟨j, hj⟩ else false⟩, ?_⟩
  obtain ⟨v1, v2⟩ := v
  show (⟨0, _⟩ : CWorld (Fin 1) (Fin a)) = ⟨v1, v2⟩
  simp only [CWorld.mk.injEq]
  exact ⟨Subsingleton.elim _ _, by funext i; simp⟩

/-- In a linear extension of a rooted order the root comes first. -/
theorem enum_zero_eq_root {P : Type*} [PartialOrder P] {k : ℕ} {t : ℕ → P} {r : P}
    (hr : ∀ p, r ≤ p) (hsurj : ∀ p : P, ∃ j, j < k ∧ t j = p)
    (hlin : ∀ i j, i < k → j < k → t i ≤ t j → i ≤ j) (hk : 0 < k) : t 0 = r := by
  obtain ⟨j, hjk, hj⟩ := hsurj r
  have hle : t j ≤ t 0 := by rw [hj]; exact hr _
  have := hlin j 0 hjk hk hle
  have hj0 : j = 0 := by omega
  rw [← hj, hj0]

/-- **Sharp representation theorem.**  A finite rooted directed partial order needs only
one switch per *non-root* point. -/
theorem representable_card_sub_one (P : Type*) [PartialOrder P] [Fintype P]
    (hroot : ∃ r : P, ∀ p, r ≤ p) (hdir : ∀ x y : P, ∃ z, x ≤ z ∧ y ≤ z) :
    ∃ f : BddMorphism (CWorld (Fin 1) (Fin (Fintype.card P - 1))) P, Surjective f.toFun := by
  classical
  obtain ⟨r, hr⟩ := hroot
  haveI : Nonempty P := ⟨r⟩
  obtain ⟨tp, htp⟩ := exists_top_of_directed hdir
  obtain ⟨k, t, hsurj, hlin, hk⟩ := exists_linear_enumeration P
  have hkpos : 0 < k := by
    obtain ⟨j, hj, -⟩ := hsurj r
    omega
  have hroot0 : t 0 = r := enum_zero_eq_root hr hsurj hlin hkpos
  rw [← hk]
  -- the shifted enumeration: switch `i` carries the point `t (i+1)`
  set t' : ℕ → P := fun i => t (i + 1) with ht'
  have hlin' : ∀ i j, i < k - 1 → j < k - 1 → t' i ≤ t' j → i ≤ j := by
    intro i j hi hj hij
    have := hlin (i + 1) (j + 1) (by omega) (by omega) hij
    omega
  have hsurj' : ∀ q : P, q ≠ r → ∃ j, j < k - 1 ∧ t' j = q := by
    intro q hq
    obtain ⟨j, hjk, hj⟩ := hsurj q
    rcases Nat.eq_zero_or_pos j with rfl | hjpos
    · exact absurd (hj.symm.trans hroot0) hq
    · exact ⟨j - 1, by omega, by rw [ht']; simpa [Nat.sub_add_cancel hjpos] using hj⟩
  set ext : (Fin (k - 1) → Bool) → (ℕ → Bool) :=
    fun s l => if h : l < k - 1 then s ⟨l, h⟩ else false with hext
  have hext_lt : ∀ (s : Fin (k - 1) → Bool) (b : Fin (k - 1)), ext s b.1 = s b := by
    intro s b
    simp [hext, b.isLt]
  have hforth : ∀ ⦃w v : CWorld (Fin 1) (Fin (k - 1))⦄, w ≤ v →
      walk t' r tp (ext w.switch) (k - 1) ≤ walk t' r tp (ext v.switch) (k - 1) := by
    intro w v h
    refine walk.mono htp ?_ (k - 1)
    intro l hl
    simp only [hext] at hl ⊢
    by_cases hlk : l < k - 1
    · rw [dif_pos hlk] at hl ⊢
      exact h.2 _ hl
    · rw [dif_neg hlk] at hl
      exact absurd hl (by simp)
  have hback : ∀ (w : CWorld (Fin 1) (Fin (k - 1))) (q : P),
      walk t' r tp (ext w.switch) (k - 1) ≤ q →
      ∃ v, w ≤ v ∧ walk t' r tp (ext v.switch) (k - 1) = q := by
    intro w q hq
    by_cases hqr : q = r
    · subst hqr
      exact ⟨w, le_rfl, le_antisymm hq (hr _)⟩
    · obtain ⟨j, hjk, rfl⟩ := hsurj' q hqr
      obtain ⟨s', h1, -, h3⟩ :=
        walk.open_step htp hlin' (k - 1) le_rfl (ext w.switch) j hjk hq
      refine ⟨⟨w.clock, fun b => s' b.1⟩, ⟨le_rfl, ?_⟩, ?_⟩
      · intro b hb
        exact h1 b.1 (by rw [hext_lt]; exact hb)
      · show walk t' r tp (ext fun b : Fin (k - 1) => s' b.1) (k - 1) = t' j
        rw [walk.congr_of_eq (s' := s') (fun l hl => by simp [hext, hl]), h3]
  refine ⟨⟨fun w => walk t' r tp (ext w.switch) (k - 1), hforth, hback⟩, ?_⟩
  intro q
  have hbot : walk t' r tp (ext fun _ => false) (k - 1) = r := by
    rw [walk.congr_of_eq (s' := fun _ => false) (fun l _ => by simp [hext])]
    exact walk.all_false (k - 1)
  obtain ⟨v, -, hv⟩ := hback ⟨0, fun _ => false⟩ q (by
    show walk t' r tp (ext fun _ => false) (k - 1) ≤ q
    rw [hbot]; exact hr q)
  exact ⟨v, hv⟩

/-- The sharp representation theorem, with the switch count supplied as a parameter. -/
theorem representable_card_sub_one' (P : Type*) [PartialOrder P] [Fintype P]
    (hroot : ∃ r : P, ∀ p, r ≤ p) (hdir : ∀ x y : P, ∃ z, x ≤ z ∧ y ≤ z) {m : ℕ}
    (hm : Fintype.card P - 1 = m) :
    ∃ f : BddMorphism (CWorld (Fin 1) (Fin m)) P, Surjective f.toFun := by
  subst hm
  exact representable_card_sub_one P hroot hdir

/-- **Exact switch count for chains.**  The `(ℓ+1)`-element chain is a bounded morphic
image of the one-tick clock-and-switch world with `m` switches **iff** `ℓ ≤ m`; the
sharp representation theorem supplies the morphism for `m = ℓ = card - 1`, and the
height bound of `Combinatorics.CWorldFiltrationSharpness` forbids anything smaller. -/
theorem chain_switch_count_iff (ℓ m : ℕ) :
    (∃ f : BddMorphism (CWorld (Fin 1) (Fin m)) (Fin (ℓ + 1)), Surjective f.toFun) ↔ ℓ ≤ m := by
  constructor
  · rintro ⟨f, hf⟩
    exact switches_ge_of_chain f hf
  · intro hm
    obtain ⟨f, hf⟩ := representable_card_sub_one' (Fin (ℓ + 1))
      ⟨0, fun p => Fin.zero_le p⟩ (fun x y => ⟨max x y, le_max_left _ _, le_max_right _ _⟩)
      (m := ℓ) (by simp)
    -- extra switches are harmless
    obtain ⟨u, hu⟩ : ∃ u, m = ℓ + u := ⟨m - ℓ, by omega⟩
    subst hu
    exact ⟨f.comp (dropSwitches ℓ u), hf.comp (dropSwitches_surjective ℓ u)⟩

end CWorldFiltration