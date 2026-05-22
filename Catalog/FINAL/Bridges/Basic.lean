import Mathlib

/-!
# Berggren Tree: Foundations for Isogeny Realization Duality

This file establishes the foundational structures for the Berggren tree of
primitive Pythagorean triples and proves key preservation/growth properties.

## Main Definitions

* `BerggrenIsogeny.childA`, `childB`, `childC` — the three Berggren children
* `BerggrenIsogeny.BerggrenGen` — the three generator labels {A, B, C}
* `BerggrenIsogeny.applyGen` — apply a generator to a triple
* `BerggrenIsogeny.applyWord` — apply a word (sequence of generators) to a triple

## Main Results

* `BerggrenIsogeny.childA_pyth` — Child A preserves the Pythagorean property
* `BerggrenIsogeny.childB_pyth` — Child B preserves the Pythagorean property
* `BerggrenIsogeny.childC_pyth` — Child C preserves the Pythagorean property
* `BerggrenIsogeny.childA_hyp_gt` — Child A strictly increases the hypotenuse
* `BerggrenIsogeny.childB_hyp_gt` — Child B strictly increases the hypotenuse
* `BerggrenIsogeny.childC_hyp_gt` — Child C strictly increases the hypotenuse
* `BerggrenIsogeny.applyGen_pyth` — Any generator preserves the Pythagorean property
* `BerggrenIsogeny.applyWord_pyth` — Any word preserves the Pythagorean property
-/

set_option maxHeartbeats 800000

namespace BerggrenIsogeny

/-! ## Section 1: Berggren Children -/

/-- Berggren child A: the first generator of the Berggren tree.
    Corresponds to the matrix [[1,-2,2],[2,-1,2],[2,-2,3]]. -/
def childA (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren child B: the second generator of the Berggren tree.
    Corresponds to the matrix [[1,2,2],[2,1,2],[2,2,3]]. -/
def childB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren child C: the third generator of the Berggren tree.
    Corresponds to the matrix [[-1,2,2],[-2,1,2],[-2,2,3]]. -/
def childC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The Pythagorean property: a² + b² = c². -/
def IsPythag (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-! ## Section 2: Preservation Theorems -/

/-- Child A preserves the Pythagorean equation a² + b² = c². -/
theorem childA_pyth {a b c : ℤ} (h : IsPythag a b c) :
    IsPythag (childA a b c).1 (childA a b c).2.1 (childA a b c).2.2 := by
  unfold IsPythag childA at *; nlinarith [h]

/-- Child B preserves the Pythagorean equation a² + b² = c². -/
theorem childB_pyth {a b c : ℤ} (h : IsPythag a b c) :
    IsPythag (childB a b c).1 (childB a b c).2.1 (childB a b c).2.2 := by
  unfold IsPythag childB at *; nlinarith [h]

/-- Child C preserves the Pythagorean equation a² + b² = c². -/
theorem childC_pyth {a b c : ℤ} (h : IsPythag a b c) :
    IsPythag (childC a b c).1 (childC a b c).2.1 (childC a b c).2.2 := by
  unfold IsPythag childC at *; nlinarith [h]

/-! ## Section 3: Hypotenuse Growth -/

/-- Child A strictly increases the hypotenuse for positive Pythagorean triples.
    Since c² = a² + b², we have c ≥ 1, and the child hypotenuse is 2a - 2b + 3c > c. -/
theorem childA_hyp_gt {a b c : ℤ} (ha : 0 < a) (_hb : 0 < b) (hc : 0 < c)
    (h : IsPythag a b c) :
    c < (childA a b c).2.2 := by
  unfold childA IsPythag at *; nlinarith [sq_nonneg (a - b), sq_nonneg a, sq_nonneg b]

/-- Child B strictly increases the hypotenuse for positive Pythagorean triples. -/
theorem childB_hyp_gt {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (_hc : 0 < c)
    (_h : IsPythag a b c) :
    c < (childB a b c).2.2 := by
  unfold childB; nlinarith [sq_nonneg a, sq_nonneg b]

/-- Child C strictly increases the hypotenuse for positive Pythagorean triples. -/
theorem childC_hyp_gt {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : IsPythag a b c) :
    c < (childC a b c).2.2 := by
  unfold childC IsPythag at *; nlinarith [sq_nonneg (a - b), sq_nonneg a, sq_nonneg b]

/-! ## Section 4: Generator Algebra -/

/-- The three Berggren generators labeling tree branches. -/
inductive BerggrenGen : Type where
  | A : BerggrenGen
  | B : BerggrenGen
  | C : BerggrenGen
  deriving DecidableEq, Repr, Fintype

/-- Apply a single Berggren generator to an integer triple. -/
def applyGen (g : BerggrenGen) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match g with
  | .A => childA t.1 t.2.1 t.2.2
  | .B => childB t.1 t.2.1 t.2.2
  | .C => childC t.1 t.2.1 t.2.2

/-- Apply a word (sequence of generators) to an integer triple via left fold. -/
def applyWord (w : List BerggrenGen) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  w.foldl (fun acc g => applyGen g acc) t

/-- Any single generator preserves the Pythagorean property. -/
theorem applyGen_pyth {a b c : ℤ} (g : BerggrenGen) (h : IsPythag a b c) :
    IsPythag (applyGen g (a, b, c)).1
             (applyGen g (a, b, c)).2.1
             (applyGen g (a, b, c)).2.2 := by
  cases g <;> simp only [applyGen]
  · exact childA_pyth h
  · exact childB_pyth h
  · exact childC_pyth h

/-- The root of the Berggren tree: the fundamental triple (3, 4, 5). -/
def rootTriple : ℤ × ℤ × ℤ := (3, 4, 5)

/-- The root triple (3,4,5) is Pythagorean. -/
theorem root_pyth : IsPythag rootTriple.1 rootTriple.2.1 rootTriple.2.2 := by
  unfold IsPythag rootTriple; norm_num

/-- foldl with applyGen preserves Pythagorean property. -/
theorem foldl_applyGen_pyth (w : List BerggrenGen) (t : ℤ × ℤ × ℤ)
    (h : IsPythag t.1 t.2.1 t.2.2) :
    IsPythag (w.foldl (fun acc g => applyGen g acc) t).1
             (w.foldl (fun acc g => applyGen g acc) t).2.1
             (w.foldl (fun acc g => applyGen g acc) t).2.2 := by
  induction w generalizing t with
  | nil => exact h
  | cons g gs ih => exact ih _ (applyGen_pyth g h)

/-- Any word applied to the root produces a Pythagorean triple. -/
theorem applyWord_pyth (w : List BerggrenGen) :
    IsPythag (applyWord w rootTriple).1
             (applyWord w rootTriple).2.1
             (applyWord w rootTriple).2.2 :=
  foldl_applyGen_pyth w rootTriple root_pyth

/-! ## Section 5: Lorentz Form Invariance -/

/-- The Lorentzian quadratic form Q(a,b,c) = a² + b² - c².
    Pythagorean triples lie on the light cone Q = 0. -/
def lorentzQ (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

/-- Child A preserves the Lorentz form. -/
theorem childA_preserves_Q (a b c : ℤ) :
    lorentzQ (childA a b c).1 (childA a b c).2.1 (childA a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ childA; ring

/-- Child B preserves the Lorentz form. -/
theorem childB_preserves_Q (a b c : ℤ) :
    lorentzQ (childB a b c).1 (childB a b c).2.1 (childB a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ childB; ring

/-- Child C preserves the Lorentz form. -/
theorem childC_preserves_Q (a b c : ℤ) :
    lorentzQ (childC a b c).1 (childC a b c).2.1 (childC a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ childC; ring

/-- Any generator preserves the Lorentz form. -/
theorem applyGen_preserves_Q (g : BerggrenGen) (a b c : ℤ) :
    lorentzQ (applyGen g (a, b, c)).1
             (applyGen g (a, b, c)).2.1
             (applyGen g (a, b, c)).2.2 = lorentzQ a b c := by
  cases g <;> simp only [applyGen]
  · exact childA_preserves_Q a b c
  · exact childB_preserves_Q a b c
  · exact childC_preserves_Q a b c

end BerggrenIsogeny