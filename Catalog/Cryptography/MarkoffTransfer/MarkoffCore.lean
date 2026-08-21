import Mathlib

/-!
# The Markoff Tree: Vieta Involutions, Descent, and the Tree Theorem

This file formalizes the Markoff surface `x² + y² + z² = 3xyz` over `ℤ`, the Vieta
involutions acting on it, and proves the **Markoff tree theorem**: every triple of
positive integers on the Markoff surface is obtained from the root `(1,1,1)` by a
finite sequence of Vieta involutions and coordinate transpositions.

This is the Markoff-side counterpart of the Berggren machinery in
`Cryptography/BerggrenTrees/BerggrenFreeMonoid.lean` (a free monoid of rank 3 acting on
the Pythagorean null cone).  The comparison of the two structures is carried out in
`Cryptography/MarkoffTransfer/BerggrenMarkoffTransfer.lean`.

## Main results

* `markoff_vieta` — the Vieta move `z ↦ 3xy - z` preserves the Markoff surface.
* `vieta_involutive` — it is an involution.
* `markoff_vieta_pos` — it preserves positivity.
* `markoff_eq_one_of_top_eq_mid` — the only positive Markoff triple with `x ≤ y = z`
  is `(1,1,1)`; hence every other ordered triple has a strict top.
* `markoff_descent_le` — for an ordered positive triple with `y < z`, the Vieta
  descendant `3xy - z` lies in `[1, y]`, so descent strictly decreases the sum.
* `markoff_reach` — **Markoff tree theorem**: every positive integer solution is
  reachable from `(1,1,1)`.
-/

namespace MarkoffTransfer

/-! ## The Markoff form and the Vieta involutions -/

/-- The Markoff cubic form `x² + y² + z² - 3xyz`. -/
def markoffForm (x y z : ℤ) : ℤ := x ^ 2 + y ^ 2 + z ^ 2 - 3 * x * y * z

/-- A triple lies on the Markoff surface. -/
def IsMarkoff (x y z : ℤ) : Prop := markoffForm x y z = 0

theorem isMarkoff_iff {x y z : ℤ} : IsMarkoff x y z ↔ x ^ 2 + y ^ 2 + z ^ 2 = 3 * x * y * z := by
  unfold IsMarkoff markoffForm; constructor <;> intro h <;> linarith

/-- The Markoff form is symmetric: swapping the first two coordinates. -/
theorem markoffForm_swap₁₂ (x y z : ℤ) : markoffForm x y z = markoffForm y x z := by
  unfold markoffForm; ring

/-- The Markoff form is symmetric: swapping the last two coordinates. -/
theorem markoffForm_swap₂₃ (x y z : ℤ) : markoffForm x y z = markoffForm x z y := by
  unfold markoffForm; ring

theorem IsMarkoff.swap₁₂ {x y z : ℤ} (h : IsMarkoff x y z) : IsMarkoff y x z := by
  unfold IsMarkoff at *; rw [← markoffForm_swap₁₂]; exact h

theorem IsMarkoff.swap₂₃ {x y z : ℤ} (h : IsMarkoff x y z) : IsMarkoff x z y := by
  unfold IsMarkoff at *; rw [← markoffForm_swap₂₃]; exact h

theorem IsMarkoff.swap₁₃ {x y z : ℤ} (h : IsMarkoff x y z) : IsMarkoff z y x :=
  ((h.swap₁₂).swap₂₃).swap₁₂

/-- The Vieta involution in the last coordinate. -/
def vieta (x y z : ℤ) : ℤ := 3 * x * y - z

@[simp] theorem vieta_involutive (x y z : ℤ) : vieta x y (vieta x y z) = z := by
  unfold vieta; ring

/-- The Vieta move preserves the Markoff surface (it exchanges the two roots of the
quadratic in the last variable). -/
theorem markoff_vieta {x y z : ℤ} (h : IsMarkoff x y z) : IsMarkoff x y (vieta x y z) := by
  unfold IsMarkoff markoffForm vieta at *; nlinarith [h]

/-- Vieta's product relation: the two roots multiply to `x² + y²`. -/
theorem vieta_mul {x y z : ℤ} (h : IsMarkoff x y z) : z * vieta x y z = x ^ 2 + y ^ 2 := by
  unfold IsMarkoff markoffForm vieta at *; nlinarith [h]

/-! ## Positivity -/

/-- The Vieta move preserves positivity. -/
theorem markoff_vieta_pos {x y z : ℤ} (h : IsMarkoff x y z) (hx : 0 < x) (hz : 0 < z) :
    0 < vieta x y z := by
  have hm := vieta_mul h
  nlinarith [sq_nonneg y, hx, hz]

/-! ## Rigidity of the top of an ordered triple -/

/-- The only positive Markoff triple whose two largest entries agree is `(1,1,1)`. -/
theorem markoff_eq_one_of_top_eq_mid {x y : ℤ} (h : IsMarkoff x y y) (hx : 0 < x) (hxy : x ≤ y) :
    x = 1 ∧ y = 1 := by
  rw [isMarkoff_iff] at h
  have hy : 0 < y := lt_of_lt_of_le hx hxy
  have key : x ^ 2 = y ^ 2 * (3 * x - 2) := by linarith
  have hx1 : x = 1 := by nlinarith [sq_nonneg (y - x), sq_nonneg y]
  subst hx1
  exact ⟨rfl, by nlinarith [key]⟩

/-- Every ordered positive Markoff triple other than `(1,1,1)` has a strictly largest entry. -/
theorem markoff_mid_lt_top {x y z : ℤ} (h : IsMarkoff x y z) (hx : 0 < x) (hxy : x ≤ y)
    (hyz : y ≤ z) (hne : ¬(x = 1 ∧ y = 1 ∧ z = 1)) : y < z := by
  rcases lt_or_eq_of_le hyz with h' | h'
  · exact h'
  · subst h'
    obtain ⟨h1, h2⟩ := markoff_eq_one_of_top_eq_mid h hx hxy
    exact absurd ⟨h1, h2, h2⟩ hne

/-! ## Descent -/

/-- **Descent bound.**  For an ordered positive Markoff triple with a strict top, the Vieta
descendant of the top is at most the middle entry. -/
theorem markoff_descent_le {x y z : ℤ} (h : IsMarkoff x y z) (hx : 0 < x) (hxy : x ≤ y)
    (hyz : y < z) : vieta x y z ≤ y := by
  rw [isMarkoff_iff] at h
  have key : (y - z) * (y - vieta x y z) = x ^ 2 + 2 * y ^ 2 - 3 * x * y ^ 2 := by
    unfold vieta; nlinarith [h]
  have hy : 0 < y := lt_of_lt_of_le hx hxy
  have hneg : x ^ 2 + 2 * y ^ 2 - 3 * x * y ^ 2 ≤ 0 := by nlinarith [hx, hxy, hy]
  nlinarith [key, hneg]

/-- The descent step strictly decreases the top entry. -/
theorem markoff_descent_lt {x y z : ℤ} (h : IsMarkoff x y z) (hx : 0 < x) (hxy : x ≤ y)
    (hyz : y < z) : vieta x y z < z :=
  lt_of_le_of_lt (markoff_descent_le h hx hxy hyz) hyz

/-! ## The Markoff tree -/

/-- Reachability from the root `(1,1,1)` under Vieta involutions and transpositions. -/
inductive MReach : ℤ → ℤ → ℤ → Prop
  | root : MReach 1 1 1
  | vieta {x y z : ℤ} : MReach x y z → MReach x y (vieta x y z)
  | swap₁₂ {x y z : ℤ} : MReach x y z → MReach y x z
  | swap₂₃ {x y z : ℤ} : MReach x y z → MReach x z y

theorem MReach.swap₁₃ {x y z : ℤ} (h : MReach x y z) : MReach z y x :=
  ((h.swap₁₂).swap₂₃).swap₁₂

/-- Every element of the tree lies on the Markoff surface. -/
theorem MReach.isMarkoff {x y z : ℤ} (h : MReach x y z) : IsMarkoff x y z := by
  induction h with
  | root => rw [isMarkoff_iff]; norm_num
  | vieta _ ih => exact markoff_vieta ih
  | swap₁₂ _ ih => exact ih.swap₁₂
  | swap₂₃ _ ih => exact ih.swap₂₃

/-- Every element of the tree is positive. -/
theorem MReach.pos {x y z : ℤ} (h : MReach x y z) : 0 < x ∧ 0 < y ∧ 0 < z := by
  induction h with
  | root => norm_num
  | @vieta x y z hxyz ih =>
      obtain ⟨hx, hy, hz⟩ := ih
      exact ⟨hx, hy, markoff_vieta_pos hxyz.isMarkoff hx hz⟩
  | swap₁₂ _ ih => exact ⟨ih.2.1, ih.1, ih.2.2⟩
  | swap₂₃ _ ih => exact ⟨ih.1, ih.2.2, ih.2.1⟩

/-- Reachability for **ordered** triples, by strong induction on a bound for the sum. -/
theorem markoff_reach_ordered :
    ∀ N : ℕ, ∀ x y z : ℤ, x + y + z ≤ (N : ℤ) → 0 < x → x ≤ y → y ≤ z → IsMarkoff x y z →
      MReach x y z := by
  intro N
  induction N using Nat.strong_induction_on with
  | _ N ih =>
    intro x y z hsum hx hxy hyz hM
    by_cases hroot : x = 1 ∧ y = 1 ∧ z = 1
    · obtain ⟨h1, h2, h3⟩ := hroot; subst h1; subst h2; subst h3; exact MReach.root
    · have hylt : y < z := markoff_mid_lt_top hM hx hxy hyz hroot
      have hy : 0 < y := lt_of_lt_of_le hx hxy
      have hz : 0 < z := lt_trans hy hylt
      set w := vieta x y z with hw
      have hwy : w ≤ y := markoff_descent_le hM hx hxy hylt
      have hwpos : 0 < w := markoff_vieta_pos hM hx hz
      have hMw : IsMarkoff x y w := markoff_vieta hM
      have hNpos : 1 ≤ N := by
        have h1 : (1 : ℤ) ≤ (N : ℤ) := by omega
        exact_mod_cast h1
      have hbound : x + y + w ≤ ((N - 1 : ℕ) : ℤ) := by omega
      have hrec : MReach x y w := by
        rcases le_total w x with hcase | hcase
        · have hR : MReach w x y :=
            ih (N - 1) (by omega) w x y (by omega) hwpos hcase hxy ((hMw.swap₂₃).swap₁₂)
          exact (hR.swap₁₂).swap₂₃
        · have hR : MReach x w y :=
            ih (N - 1) (by omega) x w y (by omega) hx hcase hwy (hMw.swap₂₃)
          exact hR.swap₂₃
      have hfin := hrec.vieta
      rwa [hw, vieta_involutive] at hfin

/-- **Markoff tree theorem.**  Every positive integer point of the Markoff surface is
reachable from the root `(1,1,1)` by Vieta involutions and permutations. -/
theorem markoff_reach {x y z : ℤ} (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hM : IsMarkoff x y z) : MReach x y z := by
  have key : ∀ a b c : ℤ, 0 < a → a ≤ b → b ≤ c → IsMarkoff a b c → MReach a b c := by
    intro a b c ha hab hbc hMabc
    exact markoff_reach_ordered (a + b + c).toNat a b c (by omega) ha hab hbc hMabc
  rcases le_total x y with h₁ | h₁ <;> rcases le_total y z with h₂ | h₂ <;>
      rcases le_total x z with h₃ | h₃
  · exact key x y z hx h₁ h₂ hM
  · exact key x y z hx h₁ h₂ hM
  · exact (key x z y hx h₃ h₂ hM.swap₂₃).swap₂₃
  · exact ((key z x y hz h₃ h₁ ((hM.swap₁₃).swap₂₃)).swap₂₃).swap₁₃
  · exact (key y x z hy h₁ h₃ hM.swap₁₂).swap₁₂
  · exact ((key y z x hy h₂ h₃ ((hM.swap₁₂).swap₂₃)).swap₂₃).swap₁₂
  · exact (key y x z hy h₁ h₃ hM.swap₁₂).swap₁₂
  · exact (key z y x hz h₂ h₁ hM.swap₁₃).swap₁₃

end MarkoffTransfer