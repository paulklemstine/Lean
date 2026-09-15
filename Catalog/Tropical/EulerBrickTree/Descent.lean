/-
# The Euler Brick Tree, II: Berggren descent and single-seed generation

This file proves the *structure theorem* for the tree underlying the brick
generator of `Tropical.EulerBrickTree.Core`:

* the three Berggren generators `bergA, bergB, bergC` act on primitive
  Pythagorean triples with odd first leg (`IsPPT`) and strictly increase the
  hypotenuse;
* conversely every such triple has a positive Berggren parent with strictly
  smaller hypotenuse, so **descent terminates at the single seed `(3,4,5)`**;
* consequently `IsPPT a b c ↔ TreeReach a b c`: the tree is *exactly* the set of
  primitive triples with odd first leg, generated from one seed;
* transporting through the Saunderson generator, every brick of the family
  descends in finitely many steps to the classical minimal brick
  `(117, 44, 240)` — the brick analogue of `(3,4,5)`;
* the three children of a node are pairwise distinct, so the brick tree is a
  genuinely ternary tree.

The Berggren matrices, their inverses and the local parent lemmas come from the
catalog (`Bridges.BerggrenTrees.BerggrenPythagoreanCore`,
`Tropical.BerggrenTrees.Parent_hyp_lt`).
-/
import Mathlib
import Tropical.EulerBrickTree.Core
import Bridges.BerggrenTrees.BerggrenPythagoreanCore

namespace EulerBrickTree

/-! ## Primitive triples with odd first leg -/

/-- A primitive Pythagorean triple with positive entries and odd first leg:
the nodes of the Berggren tree. -/
def IsPPT (a b c : ℤ) : Prop :=
  0 < a ∧ 0 < b ∧ 0 < c ∧ IsPT a b c ∧ Int.gcd a b = 1 ∧ a % 2 = 1

theorem IsPPT.isPT {a b c : ℤ} (h : IsPPT a b c) : IsPT a b c := h.2.2.2.1

/-- In a positive Pythagorean triple each leg is smaller than the hypotenuse. -/
theorem leg_lt_hyp {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (h : IsPT a b c) :
    a < c ∧ b < c := by
  unfold IsPT at h
  constructor <;> nlinarith

/-- Coprimality transfer: if every common divisor of a triple `(a',b',c')`
divides `a` and `b`, and `a, b` are coprime, then `a', b'` are coprime. -/
theorem parent_coprime {a b a' b' c' : ℤ} (heq : a' ^ 2 + b' ^ 2 = c' ^ 2)
    (hab : Int.gcd a b = 1)
    (hA : ∀ d : ℤ, d ∣ a' → d ∣ b' → d ∣ c' → d ∣ a)
    (hB : ∀ d : ℤ, d ∣ a' → d ∣ b' → d ∣ c' → d ∣ b) :
    Int.gcd a' b' = 1 := by
  set g : ℤ := (Int.gcd a' b' : ℤ) with hg
  have hga : g ∣ a' := Int.gcd_dvd_left a' b'
  have hgb : g ∣ b' := Int.gcd_dvd_right a' b'
  have hgc : g ∣ c' := by
    have h2 : g ^ 2 ∣ c' ^ 2 := by
      rw [← heq]
      exact dvd_add (pow_dvd_pow_of_dvd hga 2) (pow_dvd_pow_of_dvd hgb 2)
    exact (Int.pow_dvd_pow_iff (by norm_num)).mp h2
  obtain ⟨s, t, hst⟩ : IsCoprime a b := Int.isCoprime_iff_gcd_eq_one.mpr hab
  have hdvd1 : g ∣ (1 : ℤ) := by
    rw [← hst]
    exact dvd_add ((hA g hga hgb hgc).mul_left s) ((hB g hga hgb hgc).mul_left t)
  have hnn : (0:ℤ) ≤ g := by simp [hg]
  have hg1 : g = 1 := Int.eq_one_of_dvd_one hnn hdvd1
  rw [hg] at hg1
  exact_mod_cast hg1

/-! ## The tree -/

/-- Reachability from the Berggren seed `(3,4,5)` under the three generators. -/
inductive TreeReach : ℤ → ℤ → ℤ → Prop
  | root : TreeReach 3 4 5
  | stepA {a b c : ℤ} : TreeReach a b c →
      TreeReach (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2
  | stepB {a b c : ℤ} : TreeReach a b c →
      TreeReach (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2
  | stepC {a b c : ℤ} : TreeReach a b c →
      TreeReach (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2

/-! ## Forward step: the generators preserve primitivity -/

theorem bergA_ppt {a b c : ℤ} (h : IsPPT a b c) :
    IsPPT (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 := by
  obtain ⟨ha, hb, hc, hpt, hgcd, hodd⟩ := h
  obtain ⟨hac, hbc⟩ := leg_lt_hyp ha hb hc hpt
  unfold IsPT at hpt
  simp only [bergA]
  refine ⟨by omega, by omega, by omega, by unfold IsPT; linear_combination hpt, ?_, by omega⟩
  refine parent_coprime (c' := 2 * a - 2 * b + 3 * c) (by linear_combination hpt) hgcd ?_ ?_
  · intro d h1 h2 h3
    have : a = (a - 2 * b + 2 * c) + 2 * (2 * a - b + 2 * c) - 2 * (2 * a - 2 * b + 3 * c) := by
      ring
    rw [this]
    exact dvd_sub (dvd_add h1 (h2.mul_left 2)) (h3.mul_left 2)
  · intro d h1 h2 h3
    have : b = -2 * (a - 2 * b + 2 * c) - (2 * a - b + 2 * c) + 2 * (2 * a - 2 * b + 3 * c) := by
      ring
    rw [this]
    exact dvd_add (dvd_sub (h1.mul_left (-2)) h2) (h3.mul_left 2)

theorem bergB_ppt {a b c : ℤ} (h : IsPPT a b c) :
    IsPPT (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  obtain ⟨ha, hb, hc, hpt, hgcd, hodd⟩ := h
  obtain ⟨hac, hbc⟩ := leg_lt_hyp ha hb hc hpt
  unfold IsPT at hpt
  simp only [bergB]
  refine ⟨by omega, by omega, by omega, by unfold IsPT; linear_combination hpt, ?_, by omega⟩
  refine parent_coprime (c' := 2 * a + 2 * b + 3 * c) (by linear_combination hpt) hgcd ?_ ?_
  · intro d h1 h2 h3
    have : a = (a + 2 * b + 2 * c) + 2 * (2 * a + b + 2 * c) - 2 * (2 * a + 2 * b + 3 * c) := by
      ring
    rw [this]
    exact dvd_sub (dvd_add h1 (h2.mul_left 2)) (h3.mul_left 2)
  · intro d h1 h2 h3
    have : b = 2 * (a + 2 * b + 2 * c) + (2 * a + b + 2 * c) - 2 * (2 * a + 2 * b + 3 * c) := by
      ring
    rw [this]
    exact dvd_sub (dvd_add (h1.mul_left 2) h2) (h3.mul_left 2)

theorem bergC_ppt {a b c : ℤ} (h : IsPPT a b c) :
    IsPPT (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 := by
  obtain ⟨ha, hb, hc, hpt, hgcd, hodd⟩ := h
  obtain ⟨hac, hbc⟩ := leg_lt_hyp ha hb hc hpt
  unfold IsPT at hpt
  simp only [bergC]
  refine ⟨by omega, by omega, by omega, by unfold IsPT; linear_combination hpt, ?_, by omega⟩
  refine parent_coprime (c' := -2 * a + 2 * b + 3 * c) (by linear_combination hpt) hgcd ?_ ?_
  · intro d h1 h2 h3
    have : a = -(-a + 2 * b + 2 * c) - 2 * (-2 * a + b + 2 * c) + 2 * (-2 * a + 2 * b + 3 * c) := by
      ring
    rw [this]
    exact dvd_add (dvd_sub (dvd_neg.mpr h1) (h2.mul_left 2)) (h3.mul_left 2)
  · intro d h1 h2 h3
    have : b = 2 * (-a + 2 * b + 2 * c) + (-2 * a + b + 2 * c) - 2 * (-2 * a + 2 * b + 3 * c) := by
      ring
    rw [this]
    exact dvd_sub (dvd_add (h1.mul_left 2) h2) (h3.mul_left 2)

/-- The generators strictly increase the hypotenuse. -/
theorem hyp_increase {a b c : ℤ} (h : IsPPT a b c) :
    c < (bergA a b c).2.2 ∧ c < (bergB a b c).2.2 ∧ c < (bergC a b c).2.2 := by
  obtain ⟨ha, hb, hc, hpt, -, -⟩ := h
  obtain ⟨hac, hbc⟩ := leg_lt_hyp ha hb hc hpt
  unfold IsPT at hpt
  refine ⟨?_, ?_, ?_⟩ <;> simp only [bergA, bergB, bergC] <;> nlinarith

/-- The three children of a node are pairwise distinct: the tree is ternary. -/
theorem children_distinct {a b c : ℤ} (h : IsPPT a b c) :
    bergA a b c ≠ bergB a b c ∧ bergA a b c ≠ bergC a b c ∧ bergB a b c ≠ bergC a b c := by
  obtain ⟨ha, hb, hc, hpt, -, hodd⟩ := h
  refine ⟨?_, ?_, ?_⟩ <;> simp only [bergA, bergB, bergC, ne_eq, Prod.mk.injEq, not_and] <;>
    intro h1 <;> omega

/-! ## Descent: every node has a smaller parent -/

theorem invB1_eq_invA : invB1 = invA := rfl
theorem invB2_eq_invB : invB2 = invB := rfl
theorem invB3_eq_invC : invB3 = invC := rfl

/-- The `invB1`-parent of a node is again a node, once it is positive. -/
theorem invB1_ppt {a b c : ℤ} (h : IsPPT a b c)
    (h1 : 0 < (invB1 a b c).1) (h2 : 0 < (invB1 a b c).2.1) (h3 : 0 < (invB1 a b c).2.2) :
    IsPPT (invB1 a b c).1 (invB1 a b c).2.1 (invB1 a b c).2.2 := by
  obtain ⟨ha, hb, hc, hpt, hgcd, hodd⟩ := h
  unfold IsPT at hpt
  simp only [invB1] at h1 h2 h3 ⊢
  refine ⟨h1, h2, h3, by unfold IsPT; linear_combination hpt, ?_, by omega⟩
  refine parent_coprime (c' := -2 * a - 2 * b + 3 * c) (by linear_combination hpt) hgcd ?_ ?_
  · intro d k1 k2 k3
    have : a = (a + 2 * b - 2 * c) - 2 * (-2 * a - b + 2 * c) + 2 * (-2 * a - 2 * b + 3 * c) := by
      ring
    rw [this]
    exact dvd_add (dvd_sub k1 (k2.mul_left 2)) (k3.mul_left 2)
  · intro d k1 k2 k3
    have : b = 2 * (a + 2 * b - 2 * c) - (-2 * a - b + 2 * c) + 2 * (-2 * a - 2 * b + 3 * c) := by
      ring
    rw [this]
    exact dvd_add (dvd_sub (k1.mul_left 2) k2) (k3.mul_left 2)

theorem invB2_ppt {a b c : ℤ} (h : IsPPT a b c)
    (h1 : 0 < (invB2 a b c).1) (h2 : 0 < (invB2 a b c).2.1) (h3 : 0 < (invB2 a b c).2.2) :
    IsPPT (invB2 a b c).1 (invB2 a b c).2.1 (invB2 a b c).2.2 := by
  obtain ⟨ha, hb, hc, hpt, hgcd, hodd⟩ := h
  unfold IsPT at hpt
  simp only [invB2] at h1 h2 h3 ⊢
  refine ⟨h1, h2, h3, by unfold IsPT; linear_combination hpt, ?_, by omega⟩
  refine parent_coprime (c' := -2 * a - 2 * b + 3 * c) (by linear_combination hpt) hgcd ?_ ?_
  · intro d k1 k2 k3
    have : a = (a + 2 * b - 2 * c) + 2 * (2 * a + b - 2 * c) + 2 * (-2 * a - 2 * b + 3 * c) := by
      ring
    rw [this]
    exact dvd_add (dvd_add k1 (k2.mul_left 2)) (k3.mul_left 2)
  · intro d k1 k2 k3
    have : b = 2 * (a + 2 * b - 2 * c) + (2 * a + b - 2 * c) + 2 * (-2 * a - 2 * b + 3 * c) := by
      ring
    rw [this]
    exact dvd_add (dvd_add (k1.mul_left 2) k2) (k3.mul_left 2)

theorem invB3_ppt {a b c : ℤ} (h : IsPPT a b c)
    (h1 : 0 < (invB3 a b c).1) (h2 : 0 < (invB3 a b c).2.1) (h3 : 0 < (invB3 a b c).2.2) :
    IsPPT (invB3 a b c).1 (invB3 a b c).2.1 (invB3 a b c).2.2 := by
  obtain ⟨ha, hb, hc, hpt, hgcd, hodd⟩ := h
  unfold IsPT at hpt
  simp only [invB3] at h1 h2 h3 ⊢
  refine ⟨h1, h2, h3, by unfold IsPT; linear_combination hpt, ?_, by omega⟩
  refine parent_coprime (c' := -2 * a - 2 * b + 3 * c) (by linear_combination hpt) hgcd ?_ ?_
  · intro d k1 k2 k3
    have : a = -(-a - 2 * b + 2 * c) + 2 * (2 * a + b - 2 * c) + 2 * (-2 * a - 2 * b + 3 * c) := by
      ring
    rw [this]
    exact dvd_add (dvd_add (dvd_neg.mpr k1) (k2.mul_left 2)) (k3.mul_left 2)
  · intro d k1 k2 k3
    have : b = -2 * (-a - 2 * b + 2 * c) + (2 * a + b - 2 * c) + 2 * (-2 * a - 2 * b + 3 * c) := by
      ring
    rw [this]
    exact dvd_add (dvd_add (k1.mul_left (-2)) k2) (k3.mul_left 2)

/-- The only node with hypotenuse at most `5` is the seed `(3,4,5)`. -/
theorem small_ppt {a b c : ℤ} (h : IsPPT a b c) (hc5 : c ≤ 5) : a = 3 ∧ b = 4 ∧ c = 5 := by
  obtain ⟨ha, hb, hc, hpt, hgcd, hodd⟩ := h
  obtain ⟨hac, hbc⟩ := leg_lt_hyp ha hb hc hpt
  unfold IsPT at hpt
  interval_cases c <;> interval_cases a <;> interval_cases b <;> omega

/-- **Berggren descent.**  Every primitive Pythagorean triple with positive
entries and odd first leg is reachable from the single seed `(3,4,5)`. -/
theorem ppt_treeReach {a b c : ℤ} (h : IsPPT a b c) : TreeReach a b c := by
  generalize hn : c.toNat = n
  induction n using Nat.strong_induction_on generalizing a b c with
  | _ n ih =>
    obtain ⟨ha, hb, hc, hpt, hgcd, hodd⟩ := h
    by_cases hc5 : c ≤ 5
    · obtain ⟨rfl, rfl, rfl⟩ := small_ppt ⟨ha, hb, hc, hpt, hgcd, hodd⟩ hc5
      exact TreeReach.root
    · push_neg at hc5
      have hlt : -2 * a - 2 * b + 3 * c < c := parent_hyp_lt a b c ha hb hpt
      have hpos : 0 < -2 * a - 2 * b + 3 * c := parent_hyp_pos a b c ha hb hc hpt
      rcases parent_exists a b c ha hb hc hpt hc5 hgcd with hA | hB | hC
      · obtain ⟨k1, k2, k3⟩ := hA
        have hp := invB1_ppt ⟨ha, hb, hc, hpt, hgcd, hodd⟩ k1 k2 k3
        have hsmall : (invB1 a b c).2.2.toNat < n := by
          simp only [invB1] at k3 ⊢
          omega
        have hreach := ih _ hsmall hp rfl
        rw [invB1_eq_invA] at hreach
        have h5 := TreeReach.stepA hreach
        rw [inv_fwd_A a b c] at h5
        simpa using h5
      · obtain ⟨k1, k2, k3⟩ := hB
        have hp := invB2_ppt ⟨ha, hb, hc, hpt, hgcd, hodd⟩ k1 k2 k3
        have hsmall : (invB2 a b c).2.2.toNat < n := by
          simp only [invB2] at k3 ⊢
          omega
        have hreach := ih _ hsmall hp rfl
        rw [invB2_eq_invB] at hreach
        have h5 := TreeReach.stepB hreach
        rw [inv_fwd_B a b c] at h5
        simpa using h5
      · obtain ⟨k1, k2, k3⟩ := hC
        have hp := invB3_ppt ⟨ha, hb, hc, hpt, hgcd, hodd⟩ k1 k2 k3
        have hsmall : (invB3 a b c).2.2.toNat < n := by
          simp only [invB3] at k3 ⊢
          omega
        have hreach := ih _ hsmall hp rfl
        rw [invB3_eq_invC] at hreach
        have h5 := TreeReach.stepC hreach
        rw [inv_fwd_C a b c] at h5
        simpa using h5

/-- Conversely, everything reachable in the tree is such a triple. -/
theorem treeReach_ppt {a b c : ℤ} (h : TreeReach a b c) : IsPPT a b c := by
  induction h with
  | root => exact ⟨by norm_num, by norm_num, by norm_num, by norm_num [IsPT], by decide, by decide⟩
  | stepA _ ih => exact bergA_ppt ih
  | stepB _ ih => exact bergB_ppt ih
  | stepC _ ih => exact bergC_ppt ih

/-- **Structure theorem for the Berggren tree.**  The tree generated from the
single seed `(3,4,5)` by the three generators is *exactly* the set of primitive
Pythagorean triples with positive entries and odd first leg. -/
theorem treeReach_iff_ppt {a b c : ℤ} : TreeReach a b c ↔ IsPPT a b c :=
  ⟨treeReach_ppt, ppt_treeReach⟩

/-! ## The brick tree -/

/-- The bricks sitting over the tree: images of tree nodes under the Saunderson
generator. -/
def TreeBrick (X : ℤ × ℤ × ℤ) : Prop := ∃ a b c : ℤ, TreeReach a b c ∧ X = brick a b c

/-- The root of the brick tree is the classical minimal Euler brick. -/
theorem treeBrick_root : TreeBrick (117, 44, 240) :=
  ⟨3, 4, 5, TreeReach.root, brick_root.symm⟩

/-- Every brick in the tree really is an Euler brick. -/
theorem treeBrick_isBrick {X : ℤ × ℤ × ℤ} (h : TreeBrick X) : IsBrick X.1 X.2.1 X.2.2 := by
  obtain ⟨a, b, c, hr, rfl⟩ := h
  exact brick_isBrick (treeReach_ppt hr).isPT

/-- Every brick in the tree is nondegenerate (all three edges nonzero). -/
theorem treeBrick_nondegenerate {X : ℤ × ℤ × ℤ} (h : TreeBrick X) :
    Nondegenerate X.1 X.2.1 X.2.2 := by
  obtain ⟨a, b, c, hr, rfl⟩ := h
  obtain ⟨ha, hb, hc, hpt, hgcd, -⟩ := treeReach_ppt hr
  exact brick_nondegenerate hpt ha hb hc hgcd

/-- **Single-seed generation of the brick family.**  A brick of the Saunderson
family over *any* primitive triple with odd first leg is obtained from the root
brick `(117,44,240)` by finitely many generator steps; equivalently, every such
brick descends to the root. -/
theorem brick_family_eq_treeBrick {X : ℤ × ℤ × ℤ} :
    (∃ a b c : ℤ, IsPPT a b c ∧ X = brick a b c) ↔ TreeBrick X := by
  constructor
  · rintro ⟨a, b, c, h, rfl⟩
    exact ⟨a, b, c, ppt_treeReach h, rfl⟩
  · rintro ⟨a, b, c, h, rfl⟩
    exact ⟨a, b, c, treeReach_ppt h, rfl⟩

/-- Growth: the tree contains nodes of arbitrarily large hypotenuse, hence the
brick tree contains arbitrarily large bricks. -/
theorem tree_unbounded (N : ℤ) : ∃ a b c : ℤ, TreeReach a b c ∧ N < c := by
  -- iterate `bergA` from the seed; the hypotenuse strictly increases each time.
  have key : ∀ n : ℕ, ∃ a b c : ℤ, TreeReach a b c ∧ (n : ℤ) + 5 ≤ c := by
    intro n
    induction n with
    | zero => exact ⟨3, 4, 5, TreeReach.root, by norm_num⟩
    | succ k ihk =>
      obtain ⟨a, b, c, hr, hk⟩ := ihk
      refine ⟨(bergA a b c).1, (bergA a b c).2.1, (bergA a b c).2.2, TreeReach.stepA hr, ?_⟩
      have := (hyp_increase (treeReach_ppt hr)).1
      push_cast
      omega
  obtain ⟨a, b, c, hr, hle⟩ := key (N.toNat + 1)
  exact ⟨a, b, c, hr, by omega⟩

end EulerBrickTree