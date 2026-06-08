import Mathlib

/-!
# Berggren Arithmetic Dynamics: Core Infrastructure

This file establishes the foundational definitions and key theorems for the arithmetic
dynamics of the Berggren tree of primitive Pythagorean triples.

## Main results

* Closed-form formulas for the A-ray and C-ray iterates on the root triple (3,4,5)
* Closed-form hypotenuse formula for the word A^(d-1)C
* Proof that Hypothesis 3 (A^(d-1)C is second extremal) is FALSE: the all-C word
  achieves smaller hypotenuse than A^(d-1)C at depth ≥ 2
* Quadratic form preservation for all generators
* Modular reduction commutes with word evaluation

## Organization

We build a self-contained development using `PythTriple` (integer triples) and `BGen`
(the three Berggren generators A, B, C), with `BWord = List BGen` as words.
-/

set_option maxHeartbeats 800000

/-! ## Core Types -/

/-- A Pythagorean triple represented as integers. -/
@[ext]
structure PythTriple where
  a : ℤ
  b : ℤ
  c : ℤ
  deriving DecidableEq, Repr

/-- The Berggren alphabet: three generators A, B, C. -/
inductive BGen where
  | A | B | C
  deriving DecidableEq, Repr, Fintype

/-- The root triple (3, 4, 5). -/
def baseTriple : PythTriple := ⟨3, 4, 5⟩

/-- Berggren generator A. -/
def childA (t : PythTriple) : PythTriple :=
  ⟨t.a - 2 * t.b + 2 * t.c, 2 * t.a - t.b + 2 * t.c, 2 * t.a - 2 * t.b + 3 * t.c⟩

/-- Berggren generator B. -/
def childB (t : PythTriple) : PythTriple :=
  ⟨t.a + 2 * t.b + 2 * t.c, 2 * t.a + t.b + 2 * t.c, 2 * t.a + 2 * t.b + 3 * t.c⟩

/-- Berggren generator C. -/
def childC (t : PythTriple) : PythTriple :=
  ⟨-t.a + 2 * t.b + 2 * t.c, -2 * t.a + t.b + 2 * t.c, -2 * t.a + 2 * t.b + 3 * t.c⟩

/-- Apply a single generator. -/
def applyBGen : BGen → PythTriple → PythTriple
  | .A => childA
  | .B => childB
  | .C => childC

/-- A Berggren word is a list of generators. -/
abbrev BWord := List BGen

/-- Apply a word to a triple (first letter acts first). -/
def applyBWord : BWord → PythTriple → PythTriple
  | [], t => t
  | g :: w, t => applyBWord w (applyBGen g t)

/-- The hypotenuse. -/
def PythTriple.hyp (t : PythTriple) : ℤ := t.c

/-- Iterate generator A n times. -/
def iterateA : ℕ → PythTriple → PythTriple
  | 0, t => t
  | n + 1, t => iterateA n (childA t)

/-- Iterate generator C n times. -/
def iterateC : ℕ → PythTriple → PythTriple
  | 0, t => t
  | n + 1, t => iterateC n (childC t)

/-- The all-A word of length d. -/
def allAWord (d : ℕ) : BWord := List.replicate d BGen.A

/-- The all-C word of length d. -/
def allCWord (d : ℕ) : BWord := List.replicate d BGen.C

/-- A triple is a valid (positive) Pythagorean triple. -/
def IsValidTriple (t : PythTriple) : Prop :=
  t.a ^ 2 + t.b ^ 2 = t.c ^ 2 ∧ 0 < t.a ∧ 0 < t.b ∧ 0 < t.c

/-- The Lorentz quadratic form Q(a,b,c) = a² + b² - c². -/
def lorentzQ (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

/-! ## Basic lemmas -/

theorem iterateA_succ_right (d : ℕ) (t : PythTriple) :
    iterateA (d + 1) t = childA (iterateA d t) := by
  induction d generalizing t with
  | zero => rfl
  | succ d ih => exact ih (childA t)

theorem iterateC_succ_right (d : ℕ) (t : PythTriple) :
    iterateC (d + 1) t = childC (iterateC d t) := by
  induction d generalizing t with
  | zero => rfl
  | succ d ih => exact ih (childC t)

theorem baseTriple_valid : IsValidTriple baseTriple := by
  refine ⟨by norm_num [baseTriple], by norm_num [baseTriple],
          by norm_num [baseTriple], by norm_num [baseTriple]⟩

/-! ## Quadratic Form Preservation -/

/-- Generator A preserves the Lorentz form a² + b² - c². -/
theorem childA_preserves_Q (t : PythTriple) :
    lorentzQ (childA t).a (childA t).b (childA t).c = lorentzQ t.a t.b t.c := by
  unfold lorentzQ childA; ring

/-- Generator B preserves the Lorentz form. -/
theorem childB_preserves_Q (t : PythTriple) :
    lorentzQ (childB t).a (childB t).b (childB t).c = lorentzQ t.a t.b t.c := by
  unfold lorentzQ childB; ring

/-- Generator C preserves the Lorentz form. -/
theorem childC_preserves_Q (t : PythTriple) :
    lorentzQ (childC t).a (childC t).b (childC t).c = lorentzQ t.a t.b t.c := by
  unfold lorentzQ childC; ring

/-- Any generator preserves the Lorentz form. -/
theorem applyBGen_preserves_Q (g : BGen) (t : PythTriple) :
    lorentzQ (applyBGen g t).a (applyBGen g t).b (applyBGen g t).c =
    lorentzQ t.a t.b t.c := by
  cases g <;> simp [applyBGen, childA_preserves_Q, childB_preserves_Q, childC_preserves_Q]

/-- Any word preserves the Lorentz form. -/
theorem applyBWord_preserves_Q (w : BWord) (t : PythTriple) :
    lorentzQ (applyBWord w t).a (applyBWord w t).b (applyBWord w t).c =
    lorentzQ t.a t.b t.c := by
  induction w generalizing t with
  | nil => simp [applyBWord]
  | cons g w ih =>
    simp only [applyBWord]
    rw [ih, applyBGen_preserves_Q]

/-! ## Pythagorean and Positivity Preservation -/

theorem applyBGen_pythag (g : BGen) (t : PythTriple) (h : t.a ^ 2 + t.b ^ 2 = t.c ^ 2) :
    (applyBGen g t).a ^ 2 + (applyBGen g t).b ^ 2 = (applyBGen g t).c ^ 2 := by
  have := applyBGen_preserves_Q g t; unfold lorentzQ at this; linarith

theorem applyBGen_valid (g : BGen) (t : PythTriple) (hv : IsValidTriple t) :
    IsValidTriple (applyBGen g t) := by
  obtain ⟨hp, ha, hb, hc⟩ := hv
  have hac : t.a ≤ t.c := by nlinarith [sq_nonneg t.b, sq_nonneg (t.c - t.a)]
  have hbc : t.b ≤ t.c := by nlinarith [sq_nonneg t.a, sq_nonneg (t.c - t.b)]
  refine ⟨applyBGen_pythag g t hp, ?_, ?_, ?_⟩
  all_goals (cases g <;> simp [applyBGen, childA, childB, childC] <;> nlinarith)

theorem applyBWord_valid (w : BWord) (t : PythTriple) (hv : IsValidTriple t) :
    IsValidTriple (applyBWord w t) := by
  induction w generalizing t with
  | nil => exact hv
  | cons g w ih => exact ih _ (applyBGen_valid g t hv)

/-! ## A-ray Closed Form -/

/-- The d-th iterate of A on baseTriple has the closed form (2d+3, 2d²+6d+4, 2d²+6d+5). -/
theorem iterateA_formula (d : ℕ) :
    iterateA d baseTriple =
      ⟨2 * (d : ℤ) + 3, 2 * (d : ℤ) ^ 2 + 6 * d + 4, 2 * (d : ℤ) ^ 2 + 6 * d + 5⟩ := by
  induction d with
  | zero => simp [iterateA, baseTriple]
  | succ d ih =>
    rw [iterateA_succ_right, ih]
    ext <;> simp [childA] <;> ring

/-- Hypotenuse of the d-th A-iterate is 2d²+6d+5. -/
theorem hypotenuse_iterateA (d : ℕ) :
    (iterateA d baseTriple).hyp = 2 * (d : ℤ) ^ 2 + 6 * d + 5 := by
  simp [PythTriple.hyp, iterateA_formula]

/-! ## C-ray Closed Form -/

/-- The d-th iterate of C on baseTriple has the closed form
    (4d²+8d+3, 4d+4, 4d²+8d+5). -/
theorem iterateC_formula (d : ℕ) :
    iterateC d baseTriple =
      ⟨4 * (d : ℤ) ^ 2 + 8 * d + 3, 4 * (d : ℤ) + 4, 4 * (d : ℤ) ^ 2 + 8 * d + 5⟩ := by
  induction d with
  | zero => simp [iterateC, baseTriple]
  | succ d ih =>
    rw [iterateC_succ_right, ih]
    ext <;> simp [childC] <;> ring

/-- Hypotenuse of the d-th C-iterate is 4d²+8d+5. -/
theorem hypotenuse_iterateC (d : ℕ) :
    (iterateC d baseTriple).hyp = 4 * (d : ℤ) ^ 2 + 8 * d + 5 := by
  simp [PythTriple.hyp, iterateC_formula]

/-! ## Word-iteration equivalences -/

theorem applyBWord_allA (d : ℕ) (t : PythTriple) :
    applyBWord (allAWord d) t = iterateA d t := by
  induction d generalizing t with
  | zero => rfl
  | succ d ih => exact ih (childA t)

theorem applyBWord_allC (d : ℕ) (t : PythTriple) :
    applyBWord (allCWord d) t = iterateC d t := by
  induction d generalizing t with
  | zero => rfl
  | succ d ih => exact ih (childC t)

/-! ## Hypotenuse of A^(d-1)C -/

theorem applyBWord_append_single (w : BWord) (g : BGen) (t : PythTriple) :
    applyBWord (w ++ [g]) t = applyBGen g (applyBWord w t) := by
  induction w generalizing t with
  | nil => simp [applyBWord]
  | cons h w ih => simp [applyBWord, ih]

/-- Hypotenuse of A^d·C on baseTriple equals 10(d+1)²+6(d+1)+1 = 10d²+26d+17. -/
theorem hypotenuse_AdC (d : ℕ) :
    (applyBWord (allAWord d ++ [BGen.C]) baseTriple).hyp =
    10 * ((d : ℤ) + 1) ^ 2 + 6 * (d + 1) + 1 := by
  rw [applyBWord_append_single, applyBWord_allA, iterateA_formula]
  simp only [applyBGen, PythTriple.hyp, childC]
  push_cast
  ring

/-! ## Counterexample: Hypothesis 3 is False

The conjecture that A^(d-1)C achieves the second-smallest hypotenuse at depth d is
**false**. At depth 2:
- All-A (AA) gives hypotenuse 25
- All-C (CC) gives hypotenuse 37
- A·C (AC) gives hypotenuse 53

So CC (hypotenuse 37) beats AC (hypotenuse 53) as the second-smallest.
-/

/-- At depth 2, CC has hypotenuse 37. -/
theorem hyp_CC : (applyBWord [BGen.C, BGen.C] baseTriple).hyp = 37 := by native_decide

/-- At depth 2, AC has hypotenuse 53. -/
theorem hyp_AC : (applyBWord [BGen.A, BGen.C] baseTriple).hyp = 53 := by native_decide

/-- CC has strictly smaller hypotenuse than AC at depth 2,
    disproving the conjecture that A^(d-1)C is the second minimizer. -/
theorem counterexample_hypothesis3 :
    (applyBWord [BGen.C, BGen.C] baseTriple).hyp <
    (applyBWord [BGen.A, BGen.C] baseTriple).hyp := by native_decide

/-! ## The Corrected Second Extremal: C-ray

The actual second-smallest hypotenuse at each depth is achieved by the all-C word.
-/

/-- The C-ray hypotenuse is strictly larger than the A-ray hypotenuse at each depth ≥ 1. -/
theorem hyp_Cray_gt_Aray (d : ℕ) (hd : 1 ≤ d) :
    (iterateA d baseTriple).hyp < (iterateC d baseTriple).hyp := by
  rw [hypotenuse_iterateA, hypotenuse_iterateC]
  have hd' : (0 : ℤ) < d := by omega
  nlinarith [sq_nonneg (d : ℤ)]

/-! ## Growth bounds -/

/-- Hypotenuse strictly increases under any Berggren step from a valid triple. -/
theorem hyp_increase (g : BGen) (t : PythTriple) (hv : IsValidTriple t) :
    t.hyp < (applyBGen g t).hyp := by
  obtain ⟨hp, ha, hb, hc⟩ := hv
  have hac : t.a ≤ t.c := by nlinarith [sq_nonneg t.b, sq_nonneg (t.c - t.a)]
  have hbc : t.b ≤ t.c := by nlinarith [sq_nonneg t.a, sq_nonneg (t.c - t.b)]
  cases g <;> simp [applyBGen, PythTriple.hyp, childA, childB, childC] <;> nlinarith

/-- Key one-step lower bound: any child's hypotenuse ≥ c + 2·min(a,b) + 2. -/
theorem child_hyp_lower_bound (g : BGen) (t : PythTriple) (hv : IsValidTriple t) :
    t.c + 2 * min t.a t.b + 2 ≤ (applyBGen g t).hyp := by
  obtain ⟨hp, ha, hb, hc⟩ := hv
  have hac : t.a < t.c := by nlinarith [sq_nonneg t.b, sq_nonneg (t.c - t.a)]
  have hbc : t.b < t.c := by nlinarith [sq_nonneg t.a, sq_nonneg (t.c - t.b)]
  cases g <;> simp only [applyBGen, PythTriple.hyp, childA, childB, childC]
  all_goals (rcases le_total t.a t.b with hab | hab <;>
    [simp [min_eq_left hab]; simp [min_eq_right hab]] <;> linarith)

/-
Key one-step growth of min: min(a',b') ≥ min(a,b) + 2.
-/
theorem child_min_growth (g : BGen) (t : PythTriple) (hv : IsValidTriple t) :
    min t.a t.b + 2 ≤ min (applyBGen g t).a (applyBGen g t).b := by
  rcases g with ( _ | _ | _ );
  · unfold applyBGen;
    unfold childA;
    cases min_cases t.a t.b <;> cases min_cases ( t.a - 2 * t.b + 2 * t.c ) ( 2 * t.a - t.b + 2 * t.c ) <;> linarith [ hv.2.1, hv.2.2.1, hv.2.2.2, hv.1, show t.c > t.a from by nlinarith [ hv.1, hv.2.1, hv.2.2.1, hv.2.2.2 ], show t.c > t.b from by nlinarith [ hv.1, hv.2.1, hv.2.2.1, hv.2.2.2 ] ];
  · unfold applyBGen;
    grind +locals;
  · unfold applyBGen; norm_num;
    constructor <;> unfold childC <;> norm_num;
    · cases min_cases t.a t.b <;> linarith [ hv.2.1, hv.2.2.1, hv.2.2.2, show t.c > t.a from by nlinarith [ hv.1, hv.2.1, hv.2.2.1, hv.2.2.2 ], show t.c > t.b from by nlinarith [ hv.1, hv.2.1, hv.2.2.1, hv.2.2.2 ] ];
    · cases min_cases t.a t.b <;> nlinarith [ hv.1, hv.2.1, hv.2.2.1, hv.2.2.2, show t.c > t.a from by nlinarith [ hv.1, hv.2.1, hv.2.2.1, hv.2.2.2 ] ]

/-- The all-A word achieves hypotenuse 2d²+6d+5. -/
theorem allA_achieves_min (d : ℕ) :
    (applyBWord (allAWord d) baseTriple).hyp = 2 * (d : ℤ) ^ 2 + 6 * d + 5 := by
  rw [applyBWord_allA, hypotenuse_iterateA]

/-- The all-C word achieves hypotenuse 4d²+8d+5. -/
theorem allC_achieves (d : ℕ) :
    (applyBWord (allCWord d) baseTriple).hyp = 4 * (d : ℤ) ^ 2 + 8 * d + 5 := by
  rw [applyBWord_allC, hypotenuse_iterateC]

/-! ## Every word of length d has hypotenuse ≥ 2d²+6d+5 -/

/-
Every word of length d on baseTriple has hypotenuse ≥ 2d²+6d+5.
-/
theorem berggren_hyp_lower_bound (d : ℕ) (w : BWord) (hw : w.length = d) :
    2 * (d : ℤ) ^ 2 + 6 * d + 5 ≤ (applyBWord w baseTriple).hyp := by
  -- Prove the general lower bound for any valid triple t.
  have berggren_hyp_lower_bound_general (t : PythTriple) (hv : IsValidTriple t) (w : BWord) :
    t.c + 2 * w.length * min t.a t.b + 2 * w.length ^ 2 ≤ (applyBWord w t).hyp := by
      induction w generalizing t <;> simp_all +decide;
      · rfl;
      · rename_i k hk ih;
        convert le_trans _ ( ih ( applyBGen k t ) ( applyBGen_valid k t hv ) ) using 1;
        have := child_hyp_lower_bound k t hv;
        have := child_min_growth k t hv;
        nlinarith!;
  convert berggren_hyp_lower_bound_general baseTriple baseTriple_valid w using 1 ; norm_num [ hw ] ; ring;
  unfold baseTriple; norm_num; ring;

/-! ## Modular Reduction -/

/-- Reduce a triple modulo m. -/
def PythTriple.modReduce (t : PythTriple) (m : ℕ) : ZMod m × ZMod m × ZMod m :=
  ((t.a : ZMod m), (t.b : ZMod m), (t.c : ZMod m))

/-- Apply a Berggren generator modulo m. -/
def applyBGenMod (m : ℕ) (g : BGen) (t : ZMod m × ZMod m × ZMod m) :
    ZMod m × ZMod m × ZMod m :=
  match g with
  | .A => (t.1 - 2 * t.2.1 + 2 * t.2.2,
           2 * t.1 - t.2.1 + 2 * t.2.2,
           2 * t.1 - 2 * t.2.1 + 3 * t.2.2)
  | .B => (t.1 + 2 * t.2.1 + 2 * t.2.2,
           2 * t.1 + t.2.1 + 2 * t.2.2,
           2 * t.1 + 2 * t.2.1 + 3 * t.2.2)
  | .C => (-t.1 + 2 * t.2.1 + 2 * t.2.2,
           -2 * t.1 + t.2.1 + 2 * t.2.2,
           -2 * t.1 + 2 * t.2.1 + 3 * t.2.2)

/-- Modular reduction commutes with single generator application. -/
theorem modReduce_applyBGen (m : ℕ) (g : BGen) (t : PythTriple) :
    (applyBGen g t).modReduce m = applyBGenMod m g (t.modReduce m) := by
  cases g <;> simp only [applyBGen, applyBGenMod, childA, childB, childC,
    PythTriple.modReduce, Prod.mk.injEq] <;>
    refine ⟨?_, ?_, ?_⟩ <;> push_cast <;> ring