/-
# Cups, Caps, and Convex Position

This file proves the relationship between cups/caps (convex/concave chains)
and convex position in the plane. Key results include:

- Orientation additivity (Grassmann–Plücker relation)
- Orientation transitivity for x-sorted points
- Cups have all-positive orientation triples (non-consecutive too)
- Three points in general position with distinct x are in convex position
-/
import Mathlib
import Logic.GraphTheory.Defs
import Geometry.Orient
namespace ErdosSzekeres

/-! ## Basic Cup/Cap Properties -/

/-- Any pair of points forms a cup of size 2 (vacuous orient condition). -/
theorem isCup_pair {m : ℕ} {p : Fin m → ℝ × ℝ} {i j : Fin m}
    (hij : i < j) (hx : (p i).1 < (p j).1) :
    IsCup p (![i, j]) := by
  refine ⟨?_, ?_, ?_⟩
  · intro a b hab
    fin_cases a <;> fin_cases b <;>
      simp_all [Matrix.cons_val_zero, Matrix.cons_val_one]
  · intro a b hab
    fin_cases a <;> fin_cases b <;>
      simp_all [Matrix.cons_val_zero, Matrix.cons_val_one]
  · intro a ha; omega

/-- Any pair of points forms a cap of size 2 (vacuous orient condition). -/
theorem isCap_pair {m : ℕ} {p : Fin m → ℝ × ℝ} {i j : Fin m}
    (hij : i < j) (hx : (p i).1 < (p j).1) :
    IsCap p (![i, j]) := by
  refine ⟨?_, ?_, ?_⟩
  · intro a b hab
    fin_cases a <;> fin_cases b <;>
      simp_all [Matrix.cons_val_zero, Matrix.cons_val_one]
  · intro a b hab
    fin_cases a <;> fin_cases b <;>
      simp_all [Matrix.cons_val_zero, Matrix.cons_val_one]
  · intro a ha; omega

/-- Any single point forms a cup of size 1. -/
theorem hasCup_one {m : ℕ} (p : Fin m → ℝ × ℝ) (hm : 0 < m) :
    HasCup p 1 := by
  exact ⟨![⟨0, hm⟩],
    fun a b hab => by fin_cases a; fin_cases b; simp_all,
    fun a b hab => by fin_cases a; fin_cases b; simp_all,
    fun a ha => by omega⟩

/-- Any single point forms a cap of size 1. -/
theorem hasCap_one {m : ℕ} (p : Fin m → ℝ × ℝ) (hm : 0 < m) :
    HasCap p 1 := by
  exact ⟨![⟨0, hm⟩],
    fun a b hab => by fin_cases a; fin_cases b; simp_all,
    fun a b hab => by fin_cases a; fin_cases b; simp_all,
    fun a ha => by omega⟩

/-! ## Orientation Identities -/

/-- The orient function satisfies the Grassmann–Plücker relation. -/
theorem orient_grassmann_plucker (a b c d : ℝ × ℝ) :
    orient a b d = orient a b c + orient a c d + orient c b d := by
  unfold orient; ring

/-- Consecutive positive orientations imply the "skip" triple is positive. -/
theorem orient_transitivity (a b c d : ℝ × ℝ)
    (h_abc : orient a b c > 0)
    (h_bcd : orient b c d > 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a c d > 0 := by
  unfold orient at *; nlinarith

/-- orient(a,b,d) > 0 from consecutive positive orientations. -/
theorem orient_abd_of_cup (a b c d : ℝ × ℝ)
    (h_abc : orient a b c > 0)
    (h_bcd : orient b c d > 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a b d > 0 := by
  unfold orient at *
  nlinarith [mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_bc),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_bc) (sub_pos.mpr hx_cd)]

/-- orient(a,b,d) > 0 from orient(a,b,c) > 0 and orient(a,c,d) > 0. -/
theorem orient_abd_of_acd (a b c d : ℝ × ℝ)
    (h_abc : orient a b c > 0)
    (h_acd : orient a c d > 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a b d > 0 := by
  unfold orient at *
  nlinarith [mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_bc),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_bc) (sub_pos.mpr hx_cd)]

/-! ## Cup Orientation: All Triples Positive -/

/-
In a cup, orient is positive for triples (i, j, j+1).
-/
theorem cup_orient_adj_last {m k : ℕ} {p : Fin m → ℝ × ℝ}
    {f : Fin k → Fin m} (hcup : IsCup p f)
    (i j : Fin k) (hij : i < j) (hjl : j.val + 1 < k) :
    orient (p (f i)) (p (f j)) (p (f ⟨j.val + 1, by omega⟩)) > 0 := by
  obtain ⟨ h_mono, h_x_monotone, h_pos ⟩ := hcup;
  induction' j with j ih generalizing i;
  induction' j with j ih generalizing i;
  · tauto;
  · rcases eq_or_lt_of_le ( show i ≤ ⟨ j, by linarith ⟩ from Nat.le_of_lt_succ hij ) with rfl | hi <;> simp_all +decide [ Nat.succ_eq_add_one ];
    convert orient_transitivity _ _ _ _ _ _ _ _ _ using 1;
    exact p ( f ⟨ j, by linarith ⟩ );
    · exact ih ( by linarith ) i hi;
    · exact h_pos _ hjl;
    · exact h_x_monotone _ _ hi;
    · exact h_x_monotone _ _ ( Nat.lt_succ_self _ );
    · exact h_x_monotone _ _ ( Nat.lt_succ_self _ )

/-
**All triples in a cup have positive orientation.**
This is the central geometric theorem connecting local cup property to global convexity.
-/
theorem cup_all_triples_positive {m k : ℕ} {p : Fin m → ℝ × ℝ}
    {f : Fin k → Fin m} (hcup : IsCup p f) :
    ∀ i j l : Fin k, i < j → j < l →
      orient (p (f i)) (p (f j)) (p (f l)) > 0 := by
  intro i j l hij hjl;
  induction' l with l hl generalizing i j;
  induction' l using Nat.strong_induction_on with l ih generalizing i j;
  by_cases h_cases : l = j.val + 1;
  · convert cup_orient_adj_last hcup i j hij ( by linarith [ Fin.is_lt j ] ) using 1;
    exact h_cases ▸ rfl;
  · have h_ind : orient (p (f i)) (p (f j)) (p (f ⟨l - 1, by
      exact lt_of_le_of_lt ( Nat.pred_le _ ) hl⟩)) > 0 := by
      grind
    generalize_proofs at *;
    have h_ind : orient (p (f j)) (p (f ⟨l - 1, by
      assumption⟩)) (p (f ⟨l, hl⟩)) > 0 := by
      convert cup_orient_adj_last hcup j ⟨ l - 1, by omega ⟩ _ _ using 1;
      all_goals norm_num [ Nat.sub_add_cancel ( show 1 ≤ l from Nat.succ_le_of_lt ( Nat.pos_of_ne_zero ( by rintro rfl; exact absurd hjl ( by simp +decide [ Fin.lt_def ] ) ) ) ) ];
      · exact Nat.lt_pred_iff.mpr ( lt_of_le_of_ne hjl ( Ne.symm h_cases ) );
      · linarith
    generalize_proofs at *;
    have h_ind : orient (p (f i)) (p (f j)) (p (f ⟨l, hl⟩)) > 0 := by
      have h_x_order : (p (f i)).1 < (p (f j)).1 ∧ (p (f j)).1 < (p (f ⟨l - 1, by
        assumption⟩)).1 ∧ (p (f ⟨l - 1, by
        assumption⟩)).1 < (p (f ⟨l, hl⟩)).1 := by
        exact ⟨ hcup.2.1 i j hij, hcup.2.1 j ⟨ l - 1, by omega ⟩ ( Nat.lt_pred_iff.mpr ( lt_of_le_of_ne hjl ( Ne.symm h_cases ) ) ), hcup.2.1 ⟨ l - 1, by omega ⟩ ⟨ l, hl ⟩ ( Nat.pred_lt ( ne_bot_of_gt hjl ) ) ⟩
      apply orient_abd_of_cup;
      all_goals tauto
    generalize_proofs at *;
    exact h_ind

/-- Negative orientation transitivity for caps. -/
theorem orient_neg_transitivity (a b c d : ℝ × ℝ)
    (h_abc : orient a b c < 0)
    (h_bcd : orient b c d < 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a c d < 0 := by
  unfold orient at *; nlinarith

/-- orient(a,b,d) < 0 from consecutive negative orientations. -/
theorem orient_abd_neg (a b c d : ℝ × ℝ)
    (h_abc : orient a b c < 0)
    (h_bcd : orient b c d < 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a b d < 0 := by
  unfold orient at *
  nlinarith [mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_bc),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_bc) (sub_pos.mpr hx_cd)]

/-
In a cap, orient is negative for triples (i, j, j+1).
-/
theorem cap_orient_adj_last {m k : ℕ} {p : Fin m → ℝ × ℝ}
    {f : Fin k → Fin m} (hcap : IsCap p f)
    (i j : Fin k) (hij : i < j) (hjl : j.val + 1 < k) :
    orient (p (f i)) (p (f j)) (p (f ⟨j.val + 1, by omega⟩)) < 0 := by
  rcases j with ⟨ j, hj ⟩;
  induction' j with j ih generalizing i;
  · tauto;
  · rcases eq_or_lt_of_le ( show i ≤ ⟨ j, by linarith ⟩ from Nat.le_of_lt_succ hij ) with rfl | hi <;> simp_all +decide [ Nat.succ_eq_add_one ];
    · exact hcap.2.2 _ hjl;
    · convert orient_neg_transitivity _ _ _ _ _ _ _ _ _ using 1;
      exact p ( f ⟨ j, by linarith ⟩ );
      · exact ih i ( by linarith ) hi;
      · exact hcap.2.2 _ hjl;
      · exact hcap.2.1 _ _ hi;
      · exact hcap.2.1 _ _ ( Nat.lt_succ_self _ );
      · exact hcap.2.1 _ _ ( Nat.lt_succ_self _ )

/-
**All triples in a cap have negative orientation.**
-/
theorem cap_all_triples_negative {m k : ℕ} {p : Fin m → ℝ × ℝ}
    {f : Fin k → Fin m} (hcap : IsCap p f) :
    ∀ i j l : Fin k, i < j → j < l →
      orient (p (f i)) (p (f j)) (p (f l)) < 0 := by
  -- Apply induction on the length of the cap sequence to prove the statement.
  intros i j l hij hjl
  induction' l with l ih generalizing i j;
  induction' l using Nat.strong_induction_on with l ih generalizing i j;
  rcases l with ( _ | l ) <;> simp_all +decide;
  · tauto;
  · by_cases h_cases : j.val = l;
    · convert cap_orient_adj_last hcap i j hij ( by linarith ) using 1;
      aesop;
    · -- Since $j < l + 1$ and $j \neq l$, we have $j < l$.
      have hjl' : j < ⟨l, by
        linarith⟩ := by
        exact lt_of_le_of_ne ( Nat.le_of_lt_succ hjl ) ( by simpa [ Fin.ext_iff ] using h_cases )
      generalize_proofs at *;
      have := ih l le_rfl ‹_› i j hij hjl';
      have := cap_orient_adj_last hcap j ⟨ l, by linarith ⟩ hjl' ( by linarith );
      apply orient_abd_neg;
      any_goals exact p ( f ⟨ l, by linarith ⟩ );
      · assumption;
      · exact this;
      · exact hcap.2.1 _ _ hij;
      · exact hcap.2.1 _ _ hjl';
      · exact hcap.2.1 _ _ ( Nat.lt_succ_self _ )

/-! ## Three Points in General Position -/

/-
Three non-collinear points with distinct x-coordinates are in convex position.
This is the base case ES(3) = 3.
-/
theorem three_points_convex {p : Fin 3 → ℝ × ℝ}
    (hgp : GeneralPosition p)
    (hx : ∀ i j : Fin 3, i ≠ j → (p i).1 ≠ (p j).1) :
    ∃ s : Finset (Fin 3), s.card = 3 ∧ InConvexPosition p s := by
  -- Use lt_or_gt_of_ne on all 3 pairs of x-coordinates to determine sorting.
  obtain ⟨σ, hσ⟩ : ∃ σ : Fin 3 ≃ Fin 3, (p (σ 0)).1 < (p (σ 1)).1 ∧ (p (σ 1)).1 < (p (σ 2)).1 := by
    cases' lt_or_gt_of_ne ( hx 0 1 ( by decide ) ) with h₀₁ h₁₀ <;> cases' lt_or_gt_of_ne ( hx 1 2 ( by decide ) ) with h₁₂ h₂₁ <;> cases' lt_or_gt_of_ne ( hx 0 2 ( by decide ) ) with h₀₂ h₂₀;
    all_goals try { exact ⟨ Equiv.refl _, by linarith !, by linarith ! ⟩ };
    · exact ⟨ Equiv.swap 1 2, by linarith !, by linarith ! ⟩;
    · exact ⟨ Equiv.swap 0 2 * Equiv.swap 1 2, by linarith !, by linarith ! ⟩;
    · exact ⟨ Equiv.swap 0 1, by linarith !, by linarith ! ⟩;
    · exact ⟨ Equiv.swap 0 1 * Equiv.swap 1 2, by linarith !, by linarith ! ⟩;
    · exact ⟨ Equiv.swap 0 2, by linarith !, by linarith ! ⟩;
  -- Check orient sign via hgp (it's nonzero).
  have h_orient_sign : orient (p (σ 0)) (p (σ 1)) (p (σ 2)) > 0 ∨ orient (p (σ 0)) (p (σ 1)) (p (σ 2)) < 0 := by
    exact hgp ( σ 0 ) ( σ 1 ) ( σ 2 ) ( by simp +decide [ Fin.ext_iff ] ) ( by simp +decide [ Fin.ext_iff ] ) ( by simp +decide [ Fin.ext_iff ] ) |> fun h => by contrapose! h; linarith;
  cases' h_orient_sign with h h;
  · refine' ⟨ Finset.univ.image σ, _, _ ⟩ <;> simp_all +decide [ Finset.card_image_of_injective, Function.Injective ];
    refine' Or.inl ⟨ fun i => σ i, _, _, _, _ ⟩ <;> simp_all +decide [ Fin.forall_fin_succ ];
    · exact σ.injective;
    · grind +splitImp;
    · lia;
  · refine' ⟨ Finset.univ.image σ, _, _ ⟩ <;> simp_all +decide [ Finset.card_image_of_injective _ σ.injective ];
    refine' Or.inr ⟨ fun i => σ i, _, _, _, _ ⟩ <;> simp_all +decide [ Fin.forall_fin_succ ];
    · exact σ.injective;
    · grind +splitImp;
    · grind

end ErdosSzekeres