/-
# The Euler Brick Tree, VII: an infinite branch on which the space diagonal fails

`Tropical.EulerBrickTree.Obstruction` produces infinitely many *scattered* tree
nodes whose bricks are provably not perfect cuboids.  Here we get a much more
structured statement: an explicit infinite **branch** of the tree — a single
path `t, B t, B² t, …` — every node of which is obstructed.

The mechanism is a congruence that the second Berggren generator preserves
exactly: if `u ≡ v (mod 7)` then the `bergB`-child again satisfies
`u₁ ≡ v₁ (mod 7)`, because `u₁ - v₁ = v - u`; and the nonvanishing `7 ∤ u`
propagates because `u₁ ≡ 3u + 2w` and `w² ≡ 2u² (mod 7)`.  Since the mod-7
obstruction of `brick_not_perfect_of_mod7` applies at every node of the branch,
the space-diagonal condition fails along the whole branch, in the formally
provable pattern asked for by the structural-obstruction program.
-/
import Mathlib
import Tropical.EulerBrickTree.Core
import Tropical.EulerBrickTree.Descent
import Tropical.EulerBrickTree.Obstruction

namespace EulerBrickTree

/-- The nonvanishing of the first entry propagates along `bergB` modulo `7`. -/
private theorem mod7_step_aux : ∀ U W : ZMod 7, U ≠ 0 → U ^ 2 + U ^ 2 = W ^ 2 →
    3 * U + 2 * W ≠ 0 := by decide

/-- The mod-7 obstruction hypothesis is preserved by the second generator. -/
theorem mod7_branch_step {u v w : ℤ} (h : IsPT u v w) (hdvd : (7:ℤ) ∣ u - v)
    (hu : ¬ (7:ℤ) ∣ u) :
    (7:ℤ) ∣ ((bergB u v w).1 - (bergB u v w).2.1) ∧ ¬ (7:ℤ) ∣ (bergB u v w).1 := by
  constructor
  · obtain ⟨k, hk⟩ := hdvd
    exact ⟨-k, by simp only [bergB]; linarith⟩
  · intro hcon
    -- work modulo 7
    have hUV : ((u : ℤ) : ZMod 7) = ((v : ℤ) : ZMod 7) := by
      have hz := (ZMod.intCast_zmod_eq_zero_iff_dvd (u - v) 7).mpr hdvd
      push_cast at hz
      linear_combination hz
    have hU : ((u : ℤ) : ZMod 7) ≠ 0 := fun hh =>
      hu ((ZMod.intCast_zmod_eq_zero_iff_dvd u 7).mp hh)
    have hpt7 : ((u : ℤ) : ZMod 7) ^ 2 + ((u : ℤ) : ZMod 7) ^ 2 = ((w : ℤ) : ZMod 7) ^ 2 := by
      have hc := congrArg (fun t : ℤ => (t : ZMod 7)) h
      push_cast at hc
      rw [← hUV] at hc
      exact hc
    have hzero : ((((bergB u v w).1 : ℤ)) : ZMod 7) = 0 :=
      (ZMod.intCast_zmod_eq_zero_iff_dvd _ 7).mpr hcon
    have hval : 3 * ((u : ℤ) : ZMod 7) + 2 * ((w : ℤ) : ZMod 7) = 0 := by
      simp only [bergB] at hzero
      push_cast at hzero
      rw [← hUV] at hzero
      linear_combination hzero
    exact mod7_step_aux _ _ hU hpt7 hval

/-- Iterating the second Berggren generator: the `n`-th node of the branch. -/
def bIter : ℕ → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | 0, t => t
  | n + 1, t => bergB (bIter n t).1 (bIter n t).2.1 (bIter n t).2.2

theorem bIter_reach {t : ℤ × ℤ × ℤ} (h : TreeReach t.1 t.2.1 t.2.2) (n : ℕ) :
    TreeReach (bIter n t).1 (bIter n t).2.1 (bIter n t).2.2 := by
  induction n with
  | zero => exact h
  | succ k ih => exact TreeReach.stepB ih

theorem bIter_ppt {t : ℤ × ℤ × ℤ} (h : IsPPT t.1 t.2.1 t.2.2) (n : ℕ) :
    IsPPT (bIter n t).1 (bIter n t).2.1 (bIter n t).2.2 := by
  induction n with
  | zero => exact h
  | succ k ih => exact bergB_ppt ih

/-- The mod-7 obstruction survives every step of the branch. -/
theorem bIter_mod7 {t : ℤ × ℤ × ℤ} (h : IsPPT t.1 t.2.1 t.2.2)
    (hdvd : (7:ℤ) ∣ (t.1 - t.2.1)) (hu : ¬ (7:ℤ) ∣ t.1) (n : ℕ) :
    (7:ℤ) ∣ ((bIter n t).1 - (bIter n t).2.1) ∧ ¬ (7:ℤ) ∣ (bIter n t).1 := by
  induction n with
  | zero => exact ⟨hdvd, hu⟩
  | succ k ih =>
    obtain ⟨h1, h2⟩ := ih
    exact mod7_branch_step (bIter_ppt h k).isPT h1 h2

/-- The hypotenuse grows by at least one at each step of the branch. -/
theorem bIter_hyp_ge {t : ℤ × ℤ × ℤ} (h : IsPPT t.1 t.2.1 t.2.2) (n : ℕ) :
    t.2.2 + (n : ℤ) ≤ (bIter n t).2.2 := by
  induction n with
  | zero => simp [bIter]
  | succ k ih =>
    have hstep := (hyp_increase (bIter_ppt h k)).2.1
    simp only [bIter] at hstep ⊢
    push_cast
    omega

/-- **An infinite obstructed branch.**  Starting from any tree node satisfying
the mod-7 congruence, every node of the branch obtained by iterating the second
Berggren generator carries a genuine Euler brick which is *not* a perfect
cuboid, and the branch marches off to infinity. -/
theorem obstructed_branch {t : ℤ × ℤ × ℤ} (h : TreeReach t.1 t.2.1 t.2.2)
    (hdvd : (7:ℤ) ∣ (t.1 - t.2.1)) (hu : ¬ (7:ℤ) ∣ t.1) (n : ℕ) :
    TreeReach (bIter n t).1 (bIter n t).2.1 (bIter n t).2.2 ∧
      IsBrick (brick (bIter n t).1 (bIter n t).2.1 (bIter n t).2.2).1
        (brick (bIter n t).1 (bIter n t).2.1 (bIter n t).2.2).2.1
        (brick (bIter n t).1 (bIter n t).2.1 (bIter n t).2.2).2.2 ∧
      ¬ IsPerfectCuboid (brick (bIter n t).1 (bIter n t).2.1 (bIter n t).2.2).1
        (brick (bIter n t).1 (bIter n t).2.1 (bIter n t).2.2).2.1
        (brick (bIter n t).1 (bIter n t).2.1 (bIter n t).2.2).2.2 ∧
      t.2.2 + (n : ℤ) ≤ (bIter n t).2.2 := by
  have hppt := treeReach_ppt h
  obtain ⟨h1, h2⟩ := bIter_mod7 hppt hdvd hu n
  obtain ⟨-, -, hc, hpt, -, -⟩ := bIter_ppt hppt n
  exact ⟨bIter_reach h n, brick_isBrick hpt,
    brick_not_perfect_of_mod7 hpt (by omega) h1 h2, bIter_hyp_ge hppt n⟩

/-- The branch through the node `(15, 8, 17)` — the third child of the Berggren
seed — is obstructed at every one of its nodes. -/
theorem obstructed_branch_from_15_8_17 (n : ℕ) :
    TreeReach (bIter n (15, 8, 17)).1 (bIter n (15, 8, 17)).2.1 (bIter n (15, 8, 17)).2.2 ∧
      ¬ IsPerfectCuboid
        (brick (bIter n (15, 8, 17)).1 (bIter n (15, 8, 17)).2.1 (bIter n (15, 8, 17)).2.2).1
        (brick (bIter n (15, 8, 17)).1 (bIter n (15, 8, 17)).2.1 (bIter n (15, 8, 17)).2.2).2.1
        (brick (bIter n (15, 8, 17)).1 (bIter n (15, 8, 17)).2.1
          (bIter n (15, 8, 17)).2.2).2.2 ∧
      17 + (n : ℤ) ≤ (bIter n (15, 8, 17)).2.2 := by
  have hroot : TreeReach 15 8 17 := by
    have h := TreeReach.stepC TreeReach.root
    simpa [bergC] using h
  obtain ⟨hr, -, hnp, hgrow⟩ :=
    obstructed_branch (t := (15, 8, 17)) hroot (by decide) (by decide) n
  exact ⟨hr, hnp, hgrow⟩

end EulerBrickTree