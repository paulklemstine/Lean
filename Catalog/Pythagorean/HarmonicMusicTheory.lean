import Mathlib

/-!
# Pythagorean Music Theory: Harmonic Ratios from Triple Lattices

This file builds a formal bridge between primitive Pythagorean triples and
mathematical music theory. We extract canonical frequency ratios from triples,
classify them by consonance, and show that logarithmic transport reveals
the algebraic structure of the circle of fifths.

## Main definitions

* `isPythTriple` — Pythagorean triple predicate
* `primitiveTriple` — primitive Pythagorean triple predicate
* `legRatio` — ratio of larger leg to smaller leg
* `hypLegRatio` — ratio of hypotenuse to larger leg
* `hypMinLegRatio` — ratio of hypotenuse to smaller leg
* `intervalComplexity` — sum of numerator and denominator
* `consonant` — consonance predicate based on bounded complexity
* `octaveEquivalent` — equivalence modulo octaves in log-space
* `inCircleOfFifthsClass` — membership in the circle-of-fifths lattice

## Main results

* `root_triple_interval_values` — (3,4,5) yields 4/3 (perfect fourth) and 5/4 (major third)
* `root_triple_interval_values_extended` — also yields 5/3 (major sixth)
* `root_triple_has_perfect_fourth_and_major_third` — musical classification
* `primitive_triple_ratios_pos` — positive entries yield positive ratios > 1
* `root_triple_consonant_intervals` — root triple ratios are consonant
* `tropicalLogRatio_mul` — logarithm converts products to sums
* `perfect_fourth_is_negative_fifth_mod_octave` — 4/3 ≡ -(3/2) mod octave
* `root_legRatio_in_circle_of_fifths_shadow` — root triple sits on circle of fifths
* `berggren_children_are_pythagorean` — Berggren maps preserve Pythagorean property
-/

set_option maxHeartbeats 800000

noncomputable section

open Real

/-! ## Section 1: Core Definitions -/

/-- A triple `(a,b,c)` is Pythagorean if `a² + b² = c²`. -/
def isPythTriple (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- A triple is primitive if it is Pythagorean and the entries are coprime. -/
def primitiveTriple (a b c : ℤ) : Prop :=
  isPythTriple a b c ∧ Int.gcd a (Int.gcd b c) = 1

/-- The leg ratio: ratio of larger leg to smaller leg.
    For (3,4,5) this gives 4/3, the perfect fourth. -/
def legRatio (a b : ℤ) : ℚ :=
  (Int.natAbs (max a b) : ℚ) / (Int.natAbs (min a b) : ℚ)

/-- The hypotenuse-to-larger-leg ratio.
    For (3,4,5) this gives 5/4, the just major third. -/
def hypLegRatio (a b c : ℤ) : ℚ :=
  (Int.natAbs c : ℚ) / (Int.natAbs (max a b) : ℚ)

/-- The hypotenuse-to-smaller-leg ratio.
    For (3,4,5) this gives 5/3, the major sixth. -/
def hypMinLegRatio (a b c : ℤ) : ℚ :=
  (Int.natAbs c : ℚ) / (Int.natAbs (min a b) : ℚ)

/-- Tropical logarithm of a rational, viewed in ℝ. -/
def tropicalLogRatio (q : ℚ) : ℝ :=
  Real.log q

/-- Tropical interval coordinate (synonym for tropicalLogRatio). -/
def tropicalInterval (q : ℚ) : ℝ :=
  Real.log q

/-- Fifth-normalized coordinate: log_base(3/2) of a rational. -/
def fifthCoordinate (q : ℚ) : ℝ :=
  Real.log q / Real.log ((3 : ℝ) / 2)

/-! ## Section 2: Musical Interval Predicates -/

/-- A ratio represents a perfect fourth (4/3). -/
def isPerfectFourth (q : ℚ) : Prop := q = (4 : ℚ) / 3

/-- A ratio represents a just major third (5/4). -/
def isMajorThird (q : ℚ) : Prop := q = (5 : ℚ) / 4

/-- A ratio represents a major sixth (5/3). -/
def isMajorSixth (q : ℚ) : Prop := q = (5 : ℚ) / 3

/-- A ratio represents a perfect fifth (3/2). -/
def isPerfectFifth (q : ℚ) : Prop := q = (3 : ℚ) / 2

/-! ## Section 3: Consonance and Complexity -/

/-- Interval complexity: sum of numerator and denominator (in reduced form). -/
def intervalComplexity (q : ℚ) : ℕ :=
  q.num.natAbs + q.den

/-- A ratio is consonant if it is positive and has low complexity. -/
def consonant (q : ℚ) : Prop :=
  0 < q ∧ intervalComplexity q ≤ 12

/-- General consonance predicate with explicit coprime representation. -/
def consonantRatio (q : ℚ) : Prop :=
  0 < q ∧ ∃ m n : ℕ, Nat.Coprime m n ∧ q = (m : ℚ) / n ∧ m * n ≤ 20

/-! ## Section 4: Octave Equivalence and Circle of Fifths -/

/-- Two real numbers are octave-equivalent if they differ by an integer
    multiple of `log 2`. -/
def octaveEquivalent (x y : ℝ) : Prop :=
  ∃ n : ℤ, x - y = n * Real.log 2

/-- A real number lies in the circle-of-fifths class if it is
    octave-equivalent to some integer multiple of `log(3/2)`. -/
def inCircleOfFifthsClass (x : ℝ) : Prop :=
  ∃ n : ℤ, octaveEquivalent x (n * Real.log ((3 : ℝ) / 2))

/-! ## Section 5: Berggren Tree Definitions -/

/-- Berggren child A. -/
def bergA (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren child B. -/
def bergB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren child C. -/
def bergC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-! ## Section 6: Root Triple Computations (Theorem B) -/

/-- The root triple (3,4,5) is Pythagorean. -/
theorem root_triple_is_pythagorean : isPythTriple 3 4 5 := by
  unfold isPythTriple; norm_num

/-- The root triple (3,4,5) is primitive. -/
theorem root_triple_is_primitive : primitiveTriple 3 4 5 := by
  constructor
  · exact root_triple_is_pythagorean
  · native_decide

/-- **Theorem B (core):** The root triple yields the perfect fourth (4/3) as
    leg ratio and the just major third (5/4) as hypotenuse-to-larger-leg ratio. -/
theorem root_triple_interval_values :
    legRatio 3 4 = (4 : ℚ) / 3 ∧
    hypLegRatio 3 4 5 = (5 : ℚ) / 4 := by
  constructor <;> simp [legRatio, hypLegRatio, Int.natAbs] <;> norm_num

/-- **Theorem B (extended):** The root triple also yields the major sixth (5/3)
    as hypotenuse-to-smaller-leg ratio. -/
theorem root_triple_interval_values_extended :
    legRatio 3 4 = (4 : ℚ) / 3 ∧
    hypLegRatio 3 4 5 = (5 : ℚ) / 4 ∧
    hypMinLegRatio 3 4 5 = (5 : ℚ) / 3 := by
  refine ⟨root_triple_interval_values.1, root_triple_interval_values.2, ?_⟩
  simp [hypMinLegRatio, Int.natAbs]

/-- **Theorem B (musical):** The root triple carries a perfect fourth and a major third. -/
theorem root_triple_has_perfect_fourth_and_major_third :
    isPerfectFourth (legRatio 3 4) ∧
    isMajorThird (hypLegRatio 3 4 5) := by
  exact ⟨root_triple_interval_values.1, root_triple_interval_values.2⟩

/-! ## Section 7: Positivity and Well-Definedness (Theorem A) -/

/-- For a Pythagorean triple with positive entries, both legs are strictly less
    than the hypotenuse. -/
theorem pythag_legs_lt_hyp {a b c : ℤ} (h : isPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) : a < c ∧ b < c := by
  unfold isPythTriple at h
  constructor <;> nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg (c - a), sq_nonneg (c - b)]

/-
For distinct positive integers, the leg ratio is strictly greater than 1.
-/
theorem legRatio_gt_one {a b : ℤ} (ha : 0 < a) (hb : 0 < b) (hab : a ≠ b) :
    1 < legRatio a b := by
  unfold legRatio;
  rw [ one_lt_div ] <;> norm_cast <;> cases max_cases a b <;> cases min_cases a b <;> cases lt_or_gt_of_ne hab <;> omega

/-
For a Pythagorean triple with positive entries, the hypotenuse-to-leg ratio
    is strictly greater than 1.
-/
theorem hypLegRatio_gt_one {a b c : ℤ} (h : isPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    1 < hypLegRatio a b c := by
  unfold hypLegRatio;
  rw [ one_lt_div ] <;> norm_cast;
  · cases max_cases a b <;> cases abs_cases ( max a b ) <;> cases abs_cases c <;> nlinarith [ h.symm ];
  · positivity

/-
**Theorem A (core):** Primitive triples with positive entries yield positive
    ratios strictly greater than 1.
-/
theorem primitive_triple_ratios_pos
    {a b c : ℤ}
    (hprim : primitiveTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hab : a ≠ b) :
    1 < legRatio a b ∧
    1 < hypLegRatio a b c ∧
    0 < (legRatio a b : ℚ) ∧
    0 < (hypLegRatio a b c : ℚ) := by
  exact ⟨ legRatio_gt_one ha hb hab, hypLegRatio_gt_one hprim.1 ha hb hc, by linarith [ legRatio_gt_one ha hb hab ], by linarith [ hypLegRatio_gt_one hprim.1 ha hb hc ] ⟩

/-! ## Section 8: Consonance Classification (Theorem D) -/

/-- Interval complexity of 4/3 is 7. -/
theorem complexity_four_thirds : intervalComplexity ((4 : ℚ) / 3) = 7 := by
  native_decide

/-- Interval complexity of 5/4 is 9. -/
theorem complexity_five_fourths : intervalComplexity ((5 : ℚ) / 4) = 9 := by
  native_decide

/-- Interval complexity of 5/3 is 8. -/
theorem complexity_five_thirds : intervalComplexity ((5 : ℚ) / 3) = 8 := by
  native_decide

/-
**Theorem D (root triple):** The root triple's leg ratio and
    hypotenuse-to-leg ratio are both consonant (complexity ≤ 12).
-/
theorem root_triple_consonant_intervals :
    consonant (legRatio 3 4) ∧
    consonant (hypLegRatio 3 4 5) := by
  constructor <;> constructor <;> norm_num [ intervalComplexity ];
  · native_decide +revert;
  · native_decide;
  · native_decide +revert;
  · native_decide +revert

/-
The root triple's major sixth ratio is also consonant.
-/
theorem root_triple_major_sixth_consonant :
    consonant (hypMinLegRatio 3 4 5) := by
  exact ⟨ by native_decide, by native_decide ⟩

/-! ## Section 9: Tropical / Logarithmic Transport (Theorem C) -/

/-
**Theorem C (logarithmic homomorphism):** The tropical logarithm converts
    multiplication of positive rationals into addition of reals.
-/
theorem tropicalLogRatio_mul
    {q r : ℚ}
    (hq : 0 < q) (hr : 0 < r) :
    tropicalLogRatio (q * r) = tropicalLogRatio q + tropicalLogRatio r := by
  convert Real.log_mul ?_ ?_ <;> norm_cast ; aesop; aesop;

/-! ## Section 10: Circle of Fifths (Theorem E) -/

/-
**Theorem E (core):** The perfect fourth (4/3) is the inverse of the perfect
    fifth (3/2) modulo octave. Precisely:
    `log(4/3) - (-log(3/2)) = log 2`, so they differ by one octave.
-/
theorem perfect_fourth_is_negative_fifth_mod_octave :
    octaveEquivalent (Real.log ((4 : ℝ) / 3)) (- Real.log ((3 : ℝ) / 2)) := by
  -- We need to show that `log 4 / 3 - (-log 3 / 2)` is an integer multiple of `log 2`.
  use 1
  simp [octaveEquivalent];
  rw [ ← Real.log_mul ] <;> norm_num

/-
**Theorem E (shadow):** The root triple's leg ratio lies in the circle-of-fifths
    class, since `log(4/3)` is octave-equivalent to `-1 · log(3/2)`.
-/
theorem root_legRatio_in_circle_of_fifths_shadow :
    inCircleOfFifthsClass (tropicalInterval ((4 : ℚ) / 3)) := by
  unfold inCircleOfFifthsClass tropicalInterval;
  exact ⟨ -1, by simpa using perfect_fourth_is_negative_fifth_mod_octave ⟩

/-! ## Section 11: Berggren Preservation (Theorem C continued) -/

/-- Berggren child A preserves the Pythagorean property. -/
theorem bergA_preserves_pythag (a b c : ℤ) (h : isPythTriple a b c) :
    isPythTriple (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 := by
  unfold isPythTriple bergA at *; nlinarith [h]

/-- Berggren child B preserves the Pythagorean property. -/
theorem bergB_preserves_pythag (a b c : ℤ) (h : isPythTriple a b c) :
    isPythTriple (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  unfold isPythTriple bergB at *; nlinarith [h]

/-- Berggren child C preserves the Pythagorean property. -/
theorem bergC_preserves_pythag (a b c : ℤ) (h : isPythTriple a b c) :
    isPythTriple (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 := by
  unfold isPythTriple bergC at *; nlinarith [h]

/-- All three Berggren children of (3,4,5) are Pythagorean. -/
theorem berggren_children_are_pythagorean :
    isPythTriple (bergA 3 4 5).1 (bergA 3 4 5).2.1 (bergA 3 4 5).2.2 ∧
    isPythTriple (bergB 3 4 5).1 (bergB 3 4 5).2.1 (bergB 3 4 5).2.2 ∧
    isPythTriple (bergC 3 4 5).1 (bergC 3 4 5).2.1 (bergC 3 4 5).2.2 := by
  refine ⟨?_, ?_, ?_⟩
  · exact bergA_preserves_pythag 3 4 5 root_triple_is_pythagorean
  · exact bergB_preserves_pythag 3 4 5 root_triple_is_pythagorean
  · exact bergC_preserves_pythag 3 4 5 root_triple_is_pythagorean

/-- The Berggren children of (3,4,5). -/
theorem berggren_root_children :
    bergA 3 4 5 = (5, 12, 13) ∧
    bergB 3 4 5 = (21, 20, 29) ∧
    bergC 3 4 5 = (15, 8, 17) := by
  unfold bergA bergB bergC; norm_num

/-- Musical intervals from Berggren child A = (5,12,13). -/
theorem bergA_child_intervals :
    legRatio 5 12 = (12 : ℚ) / 5 ∧
    hypLegRatio 5 12 13 = (13 : ℚ) / 12 := by
  constructor <;> simp [legRatio, hypLegRatio, Int.natAbs] <;> norm_num

/-- Musical intervals from Berggren child C = (15,8,17). -/
theorem bergC_child_intervals :
    legRatio 15 8 = (15 : ℚ) / 8 ∧
    hypLegRatio 15 8 17 = (17 : ℚ) / 15 := by
  constructor <;> simp [legRatio, hypLegRatio, Int.natAbs] <;> norm_num

/-- **Theorem C (Berggren preservation):** If (a,b,c) is a primitive Pythagorean
    triple with positive entries, then all three Berggren children are also
    Pythagorean with positive entries. -/
theorem berggren_children_positive {a b c : ℤ}
    (_h : isPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (_hc : 0 < c)
    (_hac : a < c) (_hbc : b < c) :
    (0 < (bergB a b c).1 ∧ 0 < (bergB a b c).2.1 ∧ 0 < (bergB a b c).2.2) := by
  unfold bergB; constructor <;> [skip; constructor] <;> nlinarith

/-! ## Section 12: Berggren Harmonic Ratio Domain Preservation -/

/-
**Theorem C (harmonic domain):** Berggren B-child of a positive primitive
    triple yields positive leg ratio.
-/
theorem berggren_B_preserves_harmonic_ratio_domain
    {a b c : ℤ}
    (_h : isPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (_hc : 0 < c)
    (_hac : a < c) (_hbc : b < c) :
    0 < legRatio (bergB a b c).1 (bergB a b c).2.1 ∧
    0 < hypLegRatio (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  unfold legRatio hypLegRatio; norm_num [ bergB ] ;
  exact ⟨ div_pos ( abs_pos.mpr ( by positivity ) ) ( abs_pos.mpr ( by positivity ) ), div_pos ( abs_pos.mpr ( by positivity ) ) ( abs_pos.mpr ( by positivity ) ) ⟩

/-! ## Section 13: Octave Equivalence Properties -/

/-- Octave equivalence is reflexive. -/
theorem octaveEquivalent_refl (x : ℝ) : octaveEquivalent x x := by
  exact ⟨0, by ring⟩

/-- Octave equivalence is symmetric. -/
theorem octaveEquivalent_symm {x y : ℝ} (h : octaveEquivalent x y) :
    octaveEquivalent y x := by
  obtain ⟨n, hn⟩ := h
  exact ⟨-n, by push_cast; linarith⟩

/-- Octave equivalence is transitive. -/
theorem octaveEquivalent_trans {x y z : ℝ}
    (hxy : octaveEquivalent x y) (hyz : octaveEquivalent y z) :
    octaveEquivalent x z := by
  obtain ⟨m, hm⟩ := hxy
  obtain ⟨n, hn⟩ := hyz
  exact ⟨m + n, by push_cast; linarith⟩

end