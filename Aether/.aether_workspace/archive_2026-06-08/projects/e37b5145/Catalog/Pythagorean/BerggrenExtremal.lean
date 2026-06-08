import Mathlib

/-!
# Berggren Tree Extremal Geodesic Theory

This file proves that the all-A branch of the Berggren tree is the unique global
minimizer of hypotenuse growth at every depth, establishes the exact formula
`c_min(d) = 2d² + 6d + 5`, and derives the exact search-depth law for
enumerating primitive Pythagorean triples up to a hypotenuse bound.

## Main Results

* `iterateA_formula`: Closed form for the d-th iterate of generator A on (3,4,5).
* `hypotenuse_iterateA`: Hypotenuse of the d-th A-iterate is 2d²+6d+5.
* `child_hyp_lower_bound`: Any child's hypotenuse grows by ≥ 2·min(a,b) + 2.
* `child_min_comp_growth`: Any child's min(a,b) grows by ≥ 2.
* `berggren_hyp_lower_bound`: Every word of length d produces hypotenuse ≥ 2d²+6d+5.
* `min_hypotenuse_at_depth_eq`: The minimum hypotenuse at depth d equals 2d²+6d+5.
* `unique_minimizer_is_allA`: The all-A word is the unique minimizer at each depth.
* `exists_depth_d_triple_with_hyp_le_iff`: Exact enumeration depth characterization.

## Proof Strategy

The proof uses two key lemmas about one-step growth:
1. For any Pythagorean triple (a,b,c) with a,b > 0 and any Berggren generator g,
   `hyp(g(t)) ≥ c + 2·min(a,b) + 2`.
2. Under the same conditions, `min(a',b') ≥ min(a,b) + 2` for the child.

Since baseTriple = (3,4,5) has min(a,b) = 3, after d steps min(a,b) ≥ 3 + 2d,
and the total hypotenuse is ≥ 5 + Σ_{k=0}^{d-1} (2(3+2k)+2) = 2d²+6d+5.
The all-A branch achieves this bound exactly.
-/

set_option maxHeartbeats 1600000

/-! ## Core Definitions -/

/-- A Pythagorean triple represented as integers. -/
structure PythTriple where
  a : ℤ
  b : ℤ
  c : ℤ
  deriving DecidableEq, Repr

/-- The hypotenuse of a triple. -/
def PythTriple.hyp (t : PythTriple) : ℤ := t.c

/-- The root triple (3,4,5). -/
def baseTriple : PythTriple := ⟨3, 4, 5⟩

/-- Berggren generator A applied to a triple. -/
def childA (t : PythTriple) : PythTriple :=
  ⟨t.a - 2 * t.b + 2 * t.c, 2 * t.a - t.b + 2 * t.c, 2 * t.a - 2 * t.b + 3 * t.c⟩

/-- Berggren generator B applied to a triple. -/
def childB (t : PythTriple) : PythTriple :=
  ⟨t.a + 2 * t.b + 2 * t.c, 2 * t.a + t.b + 2 * t.c, 2 * t.a + 2 * t.b + 3 * t.c⟩

/-- Berggren generator C applied to a triple. -/
def childC (t : PythTriple) : PythTriple :=
  ⟨-t.a + 2 * t.b + 2 * t.c, -2 * t.a + t.b + 2 * t.c, -2 * t.a + 2 * t.b + 3 * t.c⟩

/-- Iterate generator A n times starting from a triple. -/
def iterateA : ℕ → PythTriple → PythTriple
  | 0, t => t
  | n + 1, t => iterateA n (childA t)

/-- The Berggren alphabet. -/
inductive BGen | A | B | C
  deriving DecidableEq, Repr

/-- Apply a single generator. -/
def applyBGen : BGen → PythTriple → PythTriple
  | .A => childA
  | .B => childB
  | .C => childC

/-- A Berggren word is a list of generators. -/
abbrev BWord := List BGen

/-- Apply a word to a triple (first letter acts first, then next, etc.). -/
def applyBWord : BWord → PythTriple → PythTriple
  | [], t => t
  | g :: w, t => applyBWord w (applyBGen g t)

/-- The all-A word of length d. -/
def allAWord (d : ℕ) : BWord := List.replicate d BGen.A

/-! ## Section 1: Basic Properties of iterateA -/

/-
iterateA commutes: iterateA (d+1) t = childA (iterateA d t).
-/
theorem iterateA_succ (d : ℕ) (t : PythTriple) :
    iterateA (d + 1) t = childA (iterateA d t) := by
  induction d generalizing t <;> simp_all +decide [ iterateA ]

/-
The d-th iterate of A on baseTriple equals (2d+3, 2d²+6d+4, 2d²+6d+5).
-/
theorem iterateA_formula (d : ℕ) :
    iterateA d baseTriple =
      ⟨2 * (d : ℤ) + 3, 2 * (d : ℤ) ^ 2 + 6 * d + 4, 2 * (d : ℤ) ^ 2 + 6 * d + 5⟩ := by
  induction d <;> simp_all +decide [ iterateA_succ ];
  -- Expand the childA function and simplify each component.
  simp [childA]
  ring;
  norm_num

/-- The hypotenuse of the d-th A-iterate is 2d²+6d+5. -/
theorem hypotenuse_iterateA (d : ℕ) :
    (iterateA d baseTriple).hyp = 2 * (d : ℤ) ^ 2 + 6 * d + 5 := by
  have := iterateA_formula d
  simp [PythTriple.hyp, this]

/-
Applying the all-A word equals iterating A.
-/
theorem applyBWord_allA (d : ℕ) :
    applyBWord (allAWord d) baseTriple = iterateA d baseTriple := by
  -- First, prove the more general statement: for all t : PythTriple, applyBWord (List.replicate d BGen.A) t = iterateA d t.
  have general_case : ∀ (t : PythTriple) (d : ℕ), applyBWord (List.replicate d BGen.A) t = iterateA d t := by
    intro t d;
    induction' d with d ih generalizing t;
    · rfl;
    · exact ih _;
  exact general_case _ _

/-! ## Section 2: Hypotenuse Formulas -/

theorem hyp_childA (t : PythTriple) :
    (childA t).hyp = 2 * t.a - 2 * t.b + 3 * t.c := by
  simp [childA, PythTriple.hyp]

theorem hyp_childB (t : PythTriple) :
    (childB t).hyp = 2 * t.a + 2 * t.b + 3 * t.c := by
  simp [childB, PythTriple.hyp]

theorem hyp_childC (t : PythTriple) :
    (childC t).hyp = -2 * t.a + 2 * t.b + 3 * t.c := by
  simp [childC, PythTriple.hyp]

/-! ## Section 3: Validity Preservation -/

/-- A triple is valid if it's a positive Pythagorean triple. -/
def IsValidTriple (t : PythTriple) : Prop :=
  t.a ^ 2 + t.b ^ 2 = t.c ^ 2 ∧ 0 < t.a ∧ 0 < t.b ∧ 0 < t.c

theorem baseTriple_valid : IsValidTriple baseTriple := by
  constructor <;> simp [baseTriple] <;> norm_num

/-
For a valid triple, a < c.
-/
theorem valid_a_lt_c {t : PythTriple} (hv : IsValidTriple t) : t.a < t.c := by
  nlinarith [ hv.1, hv.2.1, hv.2.2.1, hv.2.2.2 ]

/-
For a valid triple, b < c.
-/
theorem valid_b_lt_c {t : PythTriple} (hv : IsValidTriple t) : t.b < t.c := by
  nlinarith [ hv.1, hv.2.1, hv.2.2.1, hv.2.2.2 ]

/-
For a valid triple with integer components, c - b ≥ 1.
-/
theorem valid_c_sub_b_pos {t : PythTriple} (hv : IsValidTriple t) : 1 ≤ t.c - t.b := by
  linarith [ hv.2.2.2, valid_b_lt_c hv ]

/-
For a valid triple with integer components, c - a ≥ 1.
-/
theorem valid_c_sub_a_pos {t : PythTriple} (hv : IsValidTriple t) : 1 ≤ t.c - t.a := by
  linarith [ valid_a_lt_c hv, valid_b_lt_c hv ]

/-
childA preserves validity.
-/
theorem childA_valid {t : PythTriple} (hv : IsValidTriple t) :
    IsValidTriple (childA t) := by
  constructor <;> norm_num [ childA ] at * ; nlinarith [ hv.1.symm ] ;
  exact ⟨ by linarith [ hv.2.1, hv.2.2.1, hv.2.2.2, valid_a_lt_c hv, valid_b_lt_c hv ], by linarith [ hv.2.1, hv.2.2.1, hv.2.2.2, valid_a_lt_c hv, valid_b_lt_c hv ], by linarith [ hv.2.1, hv.2.2.1, hv.2.2.2, valid_a_lt_c hv, valid_b_lt_c hv ] ⟩

/-
childB preserves validity.
-/
theorem childB_valid {t : PythTriple} (hv : IsValidTriple t) :
    IsValidTriple (childB t) := by
  grind +locals

/-
childC preserves validity.
-/
theorem childC_valid {t : PythTriple} (hv : IsValidTriple t) :
    IsValidTriple (childC t) := by
  -- We need to show that the childC triple is valid.
  unfold IsValidTriple at *;
  exact ⟨ by simpa [ childC ] using by nlinarith, by simpa [ childC ] using by nlinarith [ hv.1.symm, valid_c_sub_a_pos hv ], by simpa [ childC ] using by nlinarith [ hv.1.symm, valid_c_sub_a_pos hv ], by simpa [ childC ] using by nlinarith [ hv.1.symm, valid_c_sub_a_pos hv ] ⟩

/-- Any generator preserves validity. -/
theorem applyBGen_valid {t : PythTriple} (hv : IsValidTriple t) (g : BGen) :
    IsValidTriple (applyBGen g t) := by
  cases g <;> simp [applyBGen]
  · exact childA_valid hv
  · exact childB_valid hv
  · exact childC_valid hv

/-- Any word preserves validity. -/
theorem applyBWord_valid {t : PythTriple} (hv : IsValidTriple t) (w : BWord) :
    IsValidTriple (applyBWord w t) := by
  induction w generalizing t with
  | nil => exact hv
  | cons g w ih => exact ih (applyBGen_valid hv g)

/-! ## Section 4: The Key Growth Lemmas -/

/-- Key algebraic identity: a² = (c-b)(c+b) for Pythagorean triples. -/
theorem pyth_a_sq {t : PythTriple} (hpyth : t.a ^ 2 + t.b ^ 2 = t.c ^ 2) :
    t.a ^ 2 = (t.c - t.b) * (t.c + t.b) := by
  nlinarith [sq_nonneg t.a, sq_nonneg t.b, sq_nonneg t.c]

/-- Key algebraic identity: b² = (c-a)(c+a) for Pythagorean triples. -/
theorem pyth_b_sq {t : PythTriple} (hpyth : t.a ^ 2 + t.b ^ 2 = t.c ^ 2) :
    t.b ^ 2 = (t.c - t.a) * (t.c + t.a) := by
  nlinarith [sq_nonneg t.a, sq_nonneg t.b, sq_nonneg t.c]

/-
For a valid triple, a² ≥ c + b (since (c-b) ≥ 1 and a² = (c-b)(c+b)).
-/
theorem valid_a_sq_ge {t : PythTriple} (hv : IsValidTriple t) :
    t.c + t.b ≤ t.a ^ 2 := by
  nlinarith [ hv.1, valid_c_sub_b_pos hv ]

/-
For a valid triple, b² ≥ c + a.
-/
theorem valid_b_sq_ge {t : PythTriple} (hv : IsValidTriple t) :
    t.c + t.a ≤ t.b ^ 2 := by
  nlinarith [ hv.1, hv.2.2.1, valid_c_sub_a_pos hv ]

/-
**Key Lemma**: The hypotenuse of any child is ≥ c + 2·min(a,b) + 2.
    This is the main one-step growth bound.
-/
theorem child_hyp_lower_bound {t : PythTriple} (hv : IsValidTriple t) (g : BGen) :
    t.c + 2 * min t.a t.b + 2 ≤ (applyBGen g t).hyp := by
  -- We'll use the fact that for any valid triple, $c > a$ and $c > b$.
  have h_c_gt_a : t.c > t.a := by
    exact?
  have h_c_gt_b : t.c > t.b := by
    exact?;
  cases g <;> simp [applyBGen, hyp_childA, hyp_childB, hyp_childC];
  · cases min_cases t.a t.b <;> linarith [ hv.2.1, hv.2.2.1 ];
  · cases min_cases t.a t.b <;> linarith [ hv.2.1, hv.2.2.1 ];
  · grind +revert

/-
**Key Lemma**: For any child, min(a',b') ≥ min(a,b) + 2.
-/
theorem child_min_comp_growth {t : PythTriple} (hv : IsValidTriple t) (g : BGen) :
    min t.a t.b + 2 ≤ min (applyBGen g t).a (applyBGen g t).b := by
  -- We'll use that $a' \geq a + 2$ and $b' \geq b + 2$ for each generator $g$.
  have h_min_ge : ∀ g : BGen, (applyBGen g t).a ≥ t.a + 2 ∧ (applyBGen g t).b ≥ t.b + 2 ∨ (applyBGen g t).a ≥ t.b + 2 ∧ (applyBGen g t).b ≥ t.a + 2 := by
    intro g
    cases g <;> simp [childA, childB, childC];
    · unfold applyBGen; simp +decide [ childA ] ;
      cases le_total t.a t.b <;> first | left; constructor <;> linarith [ hv.2.1, hv.2.2.1, hv.2.2.2, valid_c_sub_b_pos hv, valid_c_sub_a_pos hv ] | right; constructor <;> linarith [ hv.2.1, hv.2.2.1, hv.2.2.2, valid_c_sub_b_pos hv, valid_c_sub_a_pos hv ] ;
    · unfold applyBGen; simp +decide [ childB ] ;
      exact Or.inl ⟨ by linarith [ hv.2.1, hv.2.2.1, hv.2.2.2 ], by linarith [ hv.2.1, hv.2.2.1, hv.2.2.2 ] ⟩;
    · unfold applyBGen; simp +decide [ childC ] ;
      cases le_total t.a t.b <;> first | left; constructor <;> linarith [ hv.2.1, hv.2.2.1, hv.2.2.2, valid_c_sub_a_pos hv, valid_c_sub_b_pos hv ] | right; constructor <;> linarith [ hv.2.1, hv.2.2.1, hv.2.2.2, valid_c_sub_a_pos hv, valid_c_sub_b_pos hv ] ;
  cases h_min_ge g <;> cases min_cases t.a t.b <;> cases min_cases ( applyBGen g t ).a ( applyBGen g t ).b <;> linarith

/-! ## Section 5: The Inductive Lower Bound -/

/-
After applying any word of length d to a valid triple t,
    the min(a,b) of the result is ≥ min(t.a, t.b) + 2d.
-/
theorem word_min_growth (d : ℕ) (w : BWord) (hw : w.length = d)
    {t : PythTriple} (hv : IsValidTriple t) :
    min t.a t.b + 2 * (d : ℤ) ≤ min (applyBWord w t).a (applyBWord w t).b := by
  subst hw;
  induction' w with g w ih generalizing t;
  · norm_num;
    exact ⟨ Or.inl le_rfl, Or.inr le_rfl ⟩;
  · convert le_trans _ ( ih ( applyBGen_valid hv g ) ) using 1;
    convert add_le_add_right ( child_min_comp_growth hv g ) ( 2 * w.length ) using 1 ; ring;
    · simpa using by ring;
    · ring

/-
**Main Lower Bound**: For any valid triple t with min(a,b) = m,
    any word of length d produces hypotenuse ≥ c + 2md + 2d².
    This follows from: growth at each step ≥ 2*(min+2k)+2 for step k,
    and sum = 2*d*m + 2*d².
-/
theorem berggren_hyp_lower_bound_general (d : ℕ) (w : BWord) (hw : w.length = d)
    {t : PythTriple} (hv : IsValidTriple t) :
    t.c + 2 * (d : ℤ) * min t.a t.b + 2 * d ^ 2 ≤ (applyBWord w t).hyp := by
  revert t;
  induction' w with g w ih generalizing d;
  · subst hw; norm_num [ PythTriple.hyp, applyBWord ] ;
  · intro t ht; specialize ih _ rfl ( applyBGen_valid ht g ) ; simp_all +decide [ applyBWord ] ;
    have h_step : (applyBGen g t).c ≥ t.c + 2 * min t.a t.b + 2 ∧ min (applyBGen g t).a (applyBGen g t).b ≥ min t.a t.b + 2 := by
      exact ⟨ child_hyp_lower_bound ht g, child_min_comp_growth ht g ⟩;
    rw [ show d = w.length + 1 by linarith ] ; push_cast ; nlinarith

/-- **Theorem A1**: Every word of length d on baseTriple has hypotenuse ≥ 2d²+6d+5. -/
theorem berggren_hyp_lower_bound (d : ℕ) (w : BWord) (hw : w.length = d) :
    2 * (d : ℤ) ^ 2 + 6 * d + 5 ≤ (applyBWord w baseTriple).hyp := by
  have hv := baseTriple_valid
  have h := berggren_hyp_lower_bound_general d w hw hv
  unfold PythTriple.hyp at h ⊢
  unfold baseTriple at h ⊢
  have hmin : min (3 : ℤ) 4 = 3 := by norm_num
  simp only [hmin] at h
  linarith

/-- The minimum hypotenuse at depth d is exactly 2d²+6d+5. -/
theorem min_hypotenuse_at_depth_eq (d : ℕ) :
    IsLeast
      {c : ℤ | ∃ w : BWord, w.length = d ∧ (applyBWord w baseTriple).hyp = c}
      (2 * (d : ℤ) ^ 2 + 6 * d + 5) := by
  constructor
  · -- The all-A word achieves this value
    simp only [Set.mem_setOf_eq]
    exact ⟨allAWord d, by simp [allAWord, List.length_replicate], by
      rw [applyBWord_allA, hypotenuse_iterateA]⟩
  · -- Every word of length d has hypotenuse ≥ this value
    intro c hc
    obtain ⟨w, hw, hweq⟩ := hc
    rw [← hweq]
    exact berggren_hyp_lower_bound d w hw

/-! ## Section 6: Uniqueness of the Minimizer -/

/-
Strict lower bound: if any letter in the word is not A,
    the hypotenuse is strictly greater than 2d²+6d+5.
-/
theorem berggren_hyp_strict_for_nonA (d : ℕ) (w : BWord) (hw : w.length = d)
    (hne : w ≠ allAWord d) :
    2 * (d : ℤ) ^ 2 + 6 * d + 5 < (applyBWord w baseTriple).hyp := by
  revert hw hne;
  induction' w using List.reverseRecOn with w g ih generalizing d <;> simp_all +decide [ allAWord ];
  -- By the induction hypothesis, if w is not all A's, then the hypotenuse of w is greater than 2*(w.length)^2 + 6*(w.length) + 5.
  by_cases hw : w = List.replicate w.length BGen.A;
  · rcases g with ( _ | _ | _ ) <;> simp +decide [ List.replicate_add ] at *;
    · grind +extAll;
    · intro hd hne
      have h_hyp : (applyBWord (w ++ [BGen.B]) baseTriple).hyp = (childB (applyBWord w baseTriple)).hyp := by
        have h_hyp : ∀ (w : BWord) (t : PythTriple), (applyBWord (w ++ [BGen.B]) t).hyp = (childB (applyBWord w t)).hyp := by
          intros w t; induction' w with w g ih generalizing t <;> simp +decide [ List.replicate_add ] at *;
          · rfl;
          · convert ih ( applyBGen w t ) using 1;
        apply h_hyp;
      have h_hyp : (childB (applyBWord w baseTriple)).hyp > (childA (applyBWord w baseTriple)).hyp := by
        have h_hyp : (applyBWord w baseTriple).b > 0 := by
          have h_hyp : ∀ w : BWord, IsValidTriple (applyBWord w baseTriple) := by
            exact fun w => applyBWord_valid baseTriple_valid w;
          exact h_hyp w |>.2.2.1;
        exact show ( 2 * ( applyBWord w baseTriple ).a + 2 * ( applyBWord w baseTriple ).b + 3 * ( applyBWord w baseTriple ).c ) > ( 2 * ( applyBWord w baseTriple ).a - 2 * ( applyBWord w baseTriple ).b + 3 * ( applyBWord w baseTriple ).c ) from by linarith;
      have h_hyp : (childA (applyBWord w baseTriple)).hyp = 2 * (w.length + 1) ^ 2 + 6 * (w.length + 1) + 5 := by
        have h_hyp : (applyBWord w baseTriple) = iterateA w.length baseTriple := by
          rw [ hw ];
          convert applyBWord_allA w.length using 1;
          norm_num;
        rw [ h_hyp, iterateA_formula ] ; ring;
        exact show ( 2 * ( 3 + w.length * 2 ) - 2 * ( 4 + w.length * 6 + w.length ^ 2 * 2 ) + 3 * ( 5 + w.length * 6 + w.length ^ 2 * 2 ) : ℤ ) = 13 + w.length * 10 + w.length ^ 2 * 2 by ring;
      grind;
    · intro hd hne
      rw [hw] at *;
      -- By definition of `applyBWord`, we have:
      have h_apply : applyBWord (List.replicate w.length BGen.A ++ [BGen.C]) baseTriple = applyBGen BGen.C (applyBWord (List.replicate w.length BGen.A) baseTriple) := by
        have h_apply : ∀ (w : BWord) (t : PythTriple), applyBWord (w ++ [BGen.C]) t = applyBGen BGen.C (applyBWord w t) := by
          intros w t; induction' w with w ih generalizing t <;> simp +decide [ *, applyBWord ] ;
        apply h_apply;
      -- By definition of `applyBWord`, we have that `applyBWord (List.replicate w.length BGen.A) baseTriple` is the `w.length`-th iterate of `childA` on `baseTriple`.
      have h_iter : applyBWord (List.replicate w.length BGen.A) baseTriple = iterateA w.length baseTriple := by
        convert applyBWord_allA w.length using 1;
      rw [ h_apply, h_iter, iterateA_formula ];
      rw [ ← hd ] ; norm_num [ applyBGen ] ; ring_nf ;
      exact show ( 13 + w.length * 10 + w.length ^ 2 * 2 : ℤ ) < -2 * ( 3 + w.length * 2 ) + 2 * ( 4 + w.length * 6 + w.length ^ 2 * 2 ) + 3 * ( 5 + w.length * 6 + w.length ^ 2 * 2 ) by nlinarith only;
  · have h_hyp_lower_bound : ∀ t : PythTriple, IsValidTriple t → t.hyp > 2 * (w.length : ℤ) ^ 2 + 6 * w.length + 5 → ∀ g : BGen, (applyBGen g t).hyp > 2 * (w.length + 1 : ℤ) ^ 2 + 6 * (w.length + 1) + 5 := by
      intros t ht ht_hyp g
      have h_min : min t.a t.b ≥ 2 * w.length + 3 := by
        have h_min : t.a ^ 2 + t.b ^ 2 = t.c ^ 2 ∧ 0 < t.a ∧ 0 < t.b ∧ 0 < t.c := by
          exact ht;
        cases min_cases t.a t.b <;> nlinarith! [ valid_c_sub_a_pos ht, valid_c_sub_b_pos ht ];
      have := child_hyp_lower_bound ht g;
      linarith!;
    have h_applyBWord : applyBWord (w ++ [g]) baseTriple = applyBGen g (applyBWord w baseTriple) := by
      have h_applyBWord : ∀ (w : BWord) (t : PythTriple), applyBWord (w ++ [g]) t = applyBGen g (applyBWord w t) := by
        intros w t; induction' w with w g ih generalizing t <;> simp_all +decide [ applyBWord ] ;
      apply h_applyBWord;
    have h_applyBWord_valid : IsValidTriple (applyBWord w baseTriple) := by
      exact applyBWord_valid baseTriple_valid w;
    grind

/-- **Theorem B1**: The all-A word is the unique minimizer at each depth. -/
theorem unique_minimizer_is_allA (d : ℕ) (w : BWord)
    (hw : w.length = d)
    (hmin : (applyBWord w baseTriple).hyp = 2 * (d : ℤ) ^ 2 + 6 * d + 5) :
    w = allAWord d := by
  by_contra hne
  have := berggren_hyp_strict_for_nonA d w hw hne
  linarith

/-! ## Section 7: Exact Enumeration Depth -/

/-- **Theorem C1**: There exists a triple at depth d with hypotenuse ≤ N
    iff 2d²+6d+5 ≤ N. -/
theorem exists_depth_d_triple_with_hyp_le_iff (N : ℤ) (d : ℕ) :
    (∃ w : BWord, w.length = d ∧ (applyBWord w baseTriple).hyp ≤ N) ↔
    2 * (d : ℤ) ^ 2 + 6 * d + 5 ≤ N := by
  constructor
  · rintro ⟨w, hw, hle⟩
    exact le_trans (berggren_hyp_lower_bound d w hw) hle
  · intro hle
    exact ⟨allAWord d, by simp [allAWord, List.length_replicate],
      by rw [applyBWord_allA, hypotenuse_iterateA]; exact hle⟩

/-! ## Section 8: Strict Child Comparisons on the A-Branch -/

/-
On the all-A branch, the A-child has strictly smaller hypotenuse than B-child.
-/
theorem hyp_childA_lt_childB (d : ℕ) :
    (childA (iterateA d baseTriple)).hyp < (childB (iterateA d baseTriple)).hyp := by
  rw [ iterateA_formula d ];
  exact Int.lt_of_sub_pos ( by rw [ hyp_childA, hyp_childB ] ; ring_nf; positivity )

/-
On the all-A branch, the A-child has strictly smaller hypotenuse than C-child.
-/
theorem hyp_childA_lt_childC (d : ℕ) :
    (childA (iterateA d baseTriple)).hyp < (childC (iterateA d baseTriple)).hyp := by
  -- By definition of $iterateA$, we have $iterateA d baseTriple = ⟨2 * (d : ℤ) + 3, 2 * (d : ℤ) ^ 2 + 6 * d + 4, 2 * (d : ℤ) ^ 2 + 6 * d + 5⟩$.
  have h_iterate : iterateA d baseTriple = ⟨2 * (d : ℤ) + 3, 2 * (d : ℤ) ^ 2 + 6 * d + 4, 2 * (d : ℤ) ^ 2 + 6 * d + 5⟩ := by
    exact?;
  simp +decide only [h_iterate, hyp_childA, hyp_childC];
  grind +splitIndPred

#check @iterateA_formula
#check @min_hypotenuse_at_depth_eq
#check @unique_minimizer_is_allA
#check @exists_depth_d_triple_with_hyp_le_iff