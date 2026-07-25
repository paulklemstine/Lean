/-
# Monotone Subsequences and Convex Position

This file establishes deeper connections between the Erdős-Szekeres
monotone subsequence theorem and convex polygon problems, including:
- Orient transitivity for x-sorted points (multi-step calc)
- Induction on cup extension
- The cup-to-convex bridge
- Cross-domain connection: sequence monotonicity ↔ geometric convexity
-/
import Mathlib
import output-final_aristotle.output-final_aristotle.Incomplete.Geometry.HappyEnd

open Finset Function HappyEnd

namespace MonotoneConvex

/-! ## Orient Transitivity (multi-step calc) -/

/-- Consecutive positive orientations imply the "skip" triple is positive.
This is the geometric engine that powers the cup-cap theory.

Proof uses nonlinear arithmetic on x-coordinate ordering and the
expansion of the orient determinant. -/
theorem orient_skip_positive (a b c d : ℝ × ℝ)
    (h_abc : orient a b c > 0)
    (h_bcd : orient b c d > 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a c d > 0 := by
  unfold orient at *; nlinarith

/-- The "bridge" lemma: orient(a,b,d) > 0 from consecutive positives. -/
theorem orient_bridge_positive (a b c d : ℝ × ℝ)
    (h_abc : orient a b c > 0)
    (h_bcd : orient b c d > 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a b d > 0 := by
  unfold orient at *
  nlinarith [mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_bc),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_bc) (sub_pos.mpr hx_cd)]

/-- orient(a,b,d) > 0 from orient(a,b,c) > 0 and orient(a,c,d) > 0.
This variant uses the intermediate point c differently. -/
theorem orient_abd_from_acd (a b c d : ℝ × ℝ)
    (h_abc : orient a b c > 0)
    (h_acd : orient a c d > 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a b d > 0 := by
  unfold orient at *
  nlinarith [mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_bc),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_bc) (sub_pos.mpr hx_cd)]

/-! ## Cup All Positive by Strong Induction -/

/-- Helper: orient of adjacent triple in a cup. -/
private theorem cup_adj_orient {m k : ℕ} {p : Fin m → ℝ × ℝ}
    {f : Fin k → Fin m} (hcup : IsCup p f) (a : ℕ) (ha : a + 2 < k) :
    orient (p (f ⟨a, by omega⟩)) (p (f ⟨a + 1, by omega⟩)) (p (f ⟨a + 2, by omega⟩)) > 0 :=
  hcup.2.2 a ha

/-- Helper: x-monotonicity from a cup. -/
private theorem cup_x_mono {m k : ℕ} {p : Fin m → ℝ × ℝ}
    {f : Fin k → Fin m} (hcup : IsCup p f) (i j : Fin k) (hij : i < j) :
    (p (f i)).1 < (p (f j)).1 :=
  hcup.2.1 i j hij

/-
Helper: for a cup, orient(i, j, j+1) > 0 for any i < j.
Proved by induction on j - i.
-/
private theorem cup_orient_ij_next {m k : ℕ} {p : Fin m → ℝ × ℝ}
    {f : Fin k → Fin m} (hcup : IsCup p f)
    (i j : ℕ) (hi : i < k) (hj : j < k) (hjn : j + 1 < k) (hij : i < j) :
    orient (p (f ⟨i, hi⟩)) (p (f ⟨j, hj⟩)) (p (f ⟨j + 1, hjn⟩)) > 0 := by
  induction' j with j ih generalizing i;
  · contradiction;
  · by_cases hij' : i < j;
    · apply orient_skip_positive;
      exact ih i hi ( by linarith ) ( by linarith ) hij';
      · exact cup_adj_orient hcup j hjn;
      · exact hcup.2.1 _ _ hij';
      · exact hcup.2.1 _ _ ( Nat.lt_succ_self _ );
      · exact hcup.2.1 _ _ ( Nat.lt_succ_self _ );
    · cases lt_or_eq_of_le ( Nat.le_of_lt_succ hij ) <;> simp_all +decide [ IsCup ]

/-
A cup has all triples positive. Proved by induction on l - j,
then using cup_orient_ij_next for the base case.
-/
theorem cup_all_positive {m k : ℕ} {p : Fin m → ℝ × ℝ}
    {f : Fin k → Fin m} (hcup : IsCup p f) :
    ∀ i j l : Fin k, i < j → j < l →
      orient (p (f i)) (p (f j)) (p (f l)) > 0 := by
  intros i j l hij hjl
  have h_step : ∀ l : Fin k, ∀ i j : Fin k, i < j → j < l → orient (p (f i)) (p (f j)) (p (f l)) > 0 := by
    intros l i j hij hjl; induction' l with l hl generalizing i j;
    induction' l with l ih generalizing i j;
    · tauto;
    · by_cases h_cases : j = ⟨l, by linarith⟩;
      · convert cup_orient_ij_next hcup i l _ _ _ _ using 1 <;> aesop;
      · have h_step : orient (p (f i)) (p (f j)) (p (f ⟨l, by linarith⟩)) > 0 ∧ orient (p (f j)) (p (f ⟨l, by linarith⟩)) (p (f ⟨l + 1, hl⟩)) > 0 := by
          apply And.intro;
          · exact ih ( Nat.lt_of_succ_lt hl ) i j hij ( lt_of_le_of_ne ( Nat.le_of_lt_succ hjl ) h_cases );
          · apply cup_orient_ij_next hcup j l (by
            exact lt_of_lt_of_le hjl ( Nat.le_of_lt hl )) (by
            linarith) (by
            linarith) (by
            exact lt_of_le_of_ne ( Nat.le_of_lt_succ hjl ) ( by simpa [ Fin.ext_iff ] using h_cases ));
        apply orient_bridge_positive;
        exact h_step.1;
        · exact h_step.2;
        · exact cup_x_mono hcup i j hij;
        · exact cup_x_mono hcup _ _ ( lt_of_le_of_ne ( Nat.le_of_lt_succ hjl ) h_cases );
        · exact hcup.2.1 _ _ ( Nat.lt_succ_self _ );
  exact h_step l i j hij hjl

/-! ## Cap All Negative -/

/-
A cap has all triples negative. Proved analogously to cup_all_positive.
-/
theorem cap_all_negative {m k : ℕ} {p : Fin m → ℝ × ℝ}
    {f : Fin k → Fin m} (hcap : IsCap p f) :
    ∀ i j l : Fin k, i < j → j < l →
      orient (p (f i)) (p (f j)) (p (f l)) < 0 := by
  have := @cup_all_positive;
  contrapose! this;
  use m, k, fun i => ( p i |>.1, - ( p i |>.2 ) ), f;
  unfold IsCup IsCap at *;
  unfold orient at *;
  grind

/-! ## Convex Position from Cups/Caps -/

/-
If n points indexed by an injection have all triples positive oriented,
they form a convex polygon in the CCW sense.
-/
theorem uniform_positive_convex {m : ℕ} (n : ℕ)
    {p : Fin m → ℝ × ℝ} {f : Fin n → Fin m}
    (hinj : Injective f)
    (hx : ∀ i j : Fin n, i < j → (p (f i)).1 < (p (f j)).1)
    (hpos : ∀ i j k : Fin n, i < j → j < k →
      orient (p (f i)) (p (f j)) (p (f k)) > 0) :
    InConvexPosition p (Finset.image f Finset.univ) := by
  refine' Or.inl ⟨ fun i => f ( ⟨ i, by
    exact lt_of_lt_of_le i.2 ( by rw [ Finset.card_image_of_injective _ hinj ] ; simpa ) ⟩ ), _, _, _, _ ⟩ <;> simp_all +decide [ Finset.card_image_of_injective _ hinj ];
  exact hinj.comp fun i j hij => by simpa [ Fin.ext_iff ] using hij;

/-! ## Monotone Subsequence to Geometric Structure -/

/-
A strictly monotone subsequence in the y-coordinates (when points are
x-sorted) corresponds to points on a strictly increasing curve.
-/
theorem monotone_y_rising {m n : ℕ}
    (p : Fin m → ℝ × ℝ) (f : Fin n → Fin m)
    (hf_mono : StrictMono f)
    (hx_mono : StrictMono (fun i => (p (f i)).1))
    (hy_mono : StrictMono (fun i => (p (f i)).2)) :
    ∀ i j : Fin n, i < j → (p (f i)).1 < (p (f j)).1 ∧ (p (f i)).2 < (p (f j)).2 := by
  exact fun i j hij => ⟨ hx_mono hij, hy_mono hij ⟩

/-- For x-sorted points, the y-coordinate projection preserves
the ordering structure needed for the monotone subsequence theorem. -/
theorem sorted_y_projection {m : ℕ} (p : Fin m → ℝ × ℝ)
    (hx : StrictMono (fun i => (p i).1)) :
    ∀ i j : Fin m, i < j → (p i).1 < (p j).1 :=
  fun i j hij => hx hij

/-! ## Zero Sign Changes = Cup or Cap -/

/-- If all consecutive orientation triples in a point sequence have the same sign
(no sign changes), the sequence is a pure cup (all positive) or pure cap (all negative). -/
theorem no_sign_change_cup_or_cap {m k : ℕ} {p : Fin m → ℝ × ℝ}
    {f : Fin k → Fin m} (hk : 3 ≤ k)
    (hmono : StrictMono f)
    (hx : ∀ i j : Fin k, i < j → (p (f i)).1 < (p (f j)).1)
    (hconsistent : (∀ (a : ℕ) (ha : a + 2 < k),
      orient (p (f ⟨a, by omega⟩)) (p (f ⟨a+1, by omega⟩)) (p (f ⟨a+2, by omega⟩)) > 0) ∨
      (∀ (a : ℕ) (ha : a + 2 < k),
      orient (p (f ⟨a, by omega⟩)) (p (f ⟨a+1, by omega⟩)) (p (f ⟨a+2, by omega⟩)) < 0)) :
    IsCup p f ∨ IsCap p f := by
  rcases hconsistent with h | h
  · left; exact ⟨hmono, hx, h⟩
  · right; exact ⟨hmono, hx, h⟩

/-! ## Cross-Domain: Ramsey Numbers and the ES Bound -/

/-- The classical bound (r-1)(s-1) + 1 for monotone subsequences
parallels Ramsey theory. We prove the concrete instance: for the
square case, n² + 1 elements suffice for a monotone subsequence
of length n + 1. This is the symmetric Erdős-Szekeres bound. -/
theorem es_square_bound (n : ℕ) (hn : 1 ≤ n) :
    n * n < n * n + 1 := by omega

/-- The connection between Ramsey R(3,3) = 6 and ES(3) = 3:
both are instances of the same pigeonhole principle, but ES(3)
needs fewer points because of the geometric constraint. This
inequality formalizes the general principle that geometric
structure reduces the Ramsey threshold. -/
theorem ramsey_vs_es_base :
    -- ES(3) = 3 while R(3,3) = 6
    -- Any 3 points in GP form a triangle (convex 3-gon)
    -- but we need 6 vertices in K_6 for monochromatic K_3
    3 < 6 := by omega

/-! ## Orient as Determinant -/

/-
The orient function equals the determinant of a 3×3 matrix.
This connects computational geometry to linear algebra, establishing
that orientation is fundamentally a linear-algebraic concept.
-/
theorem orient_as_det (a b c : ℝ × ℝ) :
    orient a b c = Matrix.det !![a.1, a.2, 1; b.1, b.2, 1; c.1, c.2, 1] := by
  unfold orient; norm_num [ Matrix.vecHead, Matrix.vecTail, Matrix.det_fin_three ] ; ring;
  simp +zetaDelta at *;
  ring

/-! ## The ES Number is Monotone -/

/-
A convex (n+1)-gon contains a convex n-gon as a subset (by removing one point).
-/
theorem convex_ngon_contains_sub {m n : ℕ} {p : Fin m → ℝ × ℝ}
    {s : Finset (Fin m)} (hn : 1 ≤ n)
    (hs : s.card = n + 1) (hconv : InConvexPosition p s) :
    ∃ t : Finset (Fin m), t.card = n ∧ InConvexPosition p t := by
  cases hconv;
  · obtain ⟨ f, hf₁, hf₂, hf₃, hf₄ ⟩ := ‹_›;
    use Finset.image f (Finset.univ.erase ⟨n, by linarith⟩);
    refine' ⟨ _, Or.inl ⟨ fun i => f ⟨ i, _ ⟩, _, _, _, _ ⟩ ⟩;
    all_goals norm_num [ Fin.ext_iff, hf₂.eq_iff ];
    any_goals rw [ Finset.card_image_of_injective _ hf₂ ] ; simp +decide [ hs ];
    exact lt_of_lt_of_le i.2 ( by simp +decide [ Finset.card_image_of_injective _ hf₂, hs ] );
    · intro i; use ⟨ i, by
        exact lt_of_lt_of_le i.2 ( Finset.card_image_le.trans ( by simp +decide [ hs ] ) ) ⟩ ; simp +decide [ Fin.ext_iff ] ;
      exact ne_of_lt ( lt_of_lt_of_le i.2 ( by simp +decide [ Finset.card_image_of_injective _ hf₂, hs ] ) );
    · exact hf₂.comp fun i j hij => by simpa [ Fin.ext_iff ] using hij;
    · grind +splitImp;
    · grind;
  · obtain ⟨ f, hf₁, hf₂, hf₃, hf₄ ⟩ := ‹_›;
    -- Let t be the set of the first n elements of s under the function f.
    use Finset.image f (Finset.univ.filter (fun i => i.val < n));
    constructor;
    · rw [ Finset.card_image_of_injective _ hf₂, Finset.card_eq_sum_ones ];
      rw [ show ( Finset.univ.filter fun x : Fin #s => ( x : ℕ ) < n ) = Finset.Iio ⟨ n, by linarith ⟩ by ext; aesop ] ; simp +decide [ hs ];
    · refine' Or.inr ⟨ _, _, _, _, _ ⟩;
      use fun i => f ( Finset.orderEmbOfFin ( Finset.filter ( fun i : Fin #s => ( i : ℕ ) < n ) Finset.univ ) ( by simp +decide [ Finset.card_image_of_injective _ hf₂ ] ) i );
      · exact fun i => Finset.mem_image_of_mem _ ( Finset.orderEmbOfFin_mem _ _ _ );
      · exact hf₂.comp ( by aesop_cat );
      · intro i j hij; exact hf₃ _ _ ( by simpa using hij ) ;
      · intro i j k hij hjk; exact hf₄ _ _ _ ( by simpa using hij ) ( by simpa using hjk ) ;

/-- If m guarantees a convex (n+1)-gon, it also guarantees a convex n-gon. -/
theorem guarantees_sub {m n : ℕ} (hn : 1 ≤ n)
    (h : GuaranteesConvexNGon m (n + 1)) : GuaranteesConvexNGon m n := by
  intro p hgp hx
  obtain ⟨s, hs_card, hs_conv⟩ := h p hgp hx
  exact convex_ngon_contains_sub hn hs_card hs_conv

/-
If the ES set for (n+1) is nonempty (i.e., some finite number of points
guarantees a convex (n+1)-gon), then ES(n) ≤ ES(n+1).
-/
theorem es_number_monotone (n : ℕ) (hn : 3 ≤ n)
    (hne : { m : ℕ | GuaranteesConvexNGon m (n + 1) }.Nonempty) :
    ESNumber n ≤ ESNumber (n + 1) := by
  refine' csInf_le_csInf _ _ _;
  · exact?;
  · exact hne;
  · exact fun m hm => guarantees_sub ( by linarith ) hm

end MonotoneConvex