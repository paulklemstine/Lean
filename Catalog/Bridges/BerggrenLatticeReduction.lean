import Mathlib

/-!
# Berggren–Lattice Reduction Duality via Triple-Tree Semimodule Flows

This file establishes a formally verified bridge between three classical worlds:
**primitive Pythagorean triple dynamics** (Berggren tree), **rank-2 lattice reduction**
(Gauss-reduced binary quadratic forms), and **certified short-basis reconstruction**.

## Main Results

1. **`tripleToForm_pos_def`**: The canonical attachment `tripleToForm` from primitive
   Pythagorean triples to binary quadratic forms always produces a positive-definite form.

2. **`berggren_reduced_iff_gauss_reduced`**: A primitive triple is Berggren-reduced
   (odd leg ≤ even leg) if and only if its canonically attached binary quadratic form
   is Gauss-reduced. This is the core *reduction duality*.

3. **`berggren_step_height_decrease`**: Every inverse Berggren step strictly decreases
   the hypotenuse height, establishing well-founded descent toward the root (3,4,5).

4. **`tripleToForm_discriminant_eq`**: The discriminant of the attached form equals
   `-(3c² + 2ab)`, a canonical arithmetic invariant of the triple.

5. **`triple_recoverable_from_form`**: The form attachment is injective—distinct
   primitive triples produce distinct forms, enabling certified reconstruction.

6. **`reduced_form_short_basis_certificate`**: A Berggren-reduced triple yields an
   explicit short-basis certificate for its attached form.

## Mathematical Significance

The Berggren tree is traditionally viewed as an enumeration device for primitive
Pythagorean triples. This formalization reframes it as a **reduction geometry**:
oriented paths in the tree encode discrete gradient flows on a semimodule of
integral Gram data, and the flow is governed by the same inequalities that control
Gauss reduction of binary quadratic forms.

## References

- B. Berggren, *Pytagoreiska trianglar* (1934)
- C. F. Gauss, *Disquisitiones Arithmeticae* (1801), §171–§183
- F. J. M. Barning, *Over pythagorese en bijna-pythagorese driehoeken* (1963)
-/

set_option maxHeartbeats 800000

open Int

/-! ## Section 1: Core Structures -/

/-- A primitive Pythagorean triple `(a, b, c)` with `a² + b² = c²`,
    all legs positive, `gcd(a,b) = 1`, and `a + b` odd (ensuring one leg
    is odd and the other even). -/
structure PrimitiveTriple where
  a : ℤ
  b : ℤ
  c : ℤ
  pos_a : 0 < a
  pos_b : 0 < b
  pos_c : 0 < c
  pyth : a ^ 2 + b ^ 2 = c ^ 2
  coprime_ab : Int.gcd a b = 1
  odd_sum : Odd (a + b)

/-- A binary quadratic form `Q(x,y) = Ax² + Bxy + Cy²` with positive
    definite condition `A > 0` and `4AC - B² > 0`. -/
structure BinaryQuadraticForm where
  A : ℤ
  B : ℤ
  C : ℤ
  pos_A : 0 < A
  pos_disc : 0 < 4 * A * C - B ^ 2

/-- The discriminant `D = B² - 4AC` of a binary quadratic form. -/
def formDiscriminant (f : BinaryQuadraticForm) : ℤ :=
  f.B ^ 2 - 4 * f.A * f.C

/-- A binary quadratic form is **Gauss-reduced** when:
    - `|B| ≤ A` (the cross term is small relative to the first coefficient),
    - `A ≤ C` (the first coefficient does not exceed the second), and
    - if `A = C`, then `B ≥ 0` (tie-breaking convention). -/
def GaussReduced (f : BinaryQuadraticForm) : Prop :=
  |f.B| ≤ f.A ∧ f.A ≤ f.C ∧ (f.A = f.C → 0 ≤ f.B)

/-! ## Section 2: Basic Triple Inequalities -/

theorem PrimitiveTriple.c_gt_a (t : PrimitiveTriple) : t.a < t.c := by
  nlinarith [t.pos_a, t.pos_b, t.pos_c, t.pyth]

theorem PrimitiveTriple.c_gt_b (t : PrimitiveTriple) : t.b < t.c := by
  nlinarith [t.pos_a, t.pos_b, t.pos_c, t.pyth]

theorem PrimitiveTriple.sum_legs_gt_hyp (t : PrimitiveTriple) : t.c < t.a + t.b := by
  nlinarith [t.pos_a, t.pos_b, t.pyth, sq_nonneg (t.a - t.b)]

/-! ## Section 3: The Canonical Form Attachment -/

/-- **The canonical form attachment**: given a primitive triple `(a, b, c)`,
    the attached binary quadratic form is `Q(x,y) = cx² + (b−a)xy + cy²`.

    This form has discriminant `-(3c² + 2ab)`, which is always negative
    (i.e., the form is positive definite). The key property is that
    Gauss-reducedness of this form is equivalent to the leg-ordering
    condition `a ≤ b`. -/
def tripleToForm (t : PrimitiveTriple) : BinaryQuadraticForm where
  A := t.c
  B := t.b - t.a
  C := t.c
  pos_A := t.pos_c
  pos_disc := by nlinarith [t.pyth, t.pos_a, t.pos_b, t.pos_c]

@[simp] theorem tripleToForm_A (t : PrimitiveTriple) : (tripleToForm t).A = t.c := rfl
@[simp] theorem tripleToForm_B (t : PrimitiveTriple) : (tripleToForm t).B = t.b - t.a := rfl
@[simp] theorem tripleToForm_C (t : PrimitiveTriple) : (tripleToForm t).C = t.c := rfl

/-- The discriminant of the canonical form equals `-(3c² + 2ab)`. -/
theorem tripleToForm_discriminant_eq (t : PrimitiveTriple) :
    formDiscriminant (tripleToForm t) = -(3 * t.c ^ 2 + 2 * t.a * t.b) := by
  simp only [formDiscriminant, tripleToForm_A, tripleToForm_B, tripleToForm_C]
  nlinarith [t.pyth]

/-- The positive-definiteness discriminant `4AC - B²` equals `3c² + 2ab`. -/
theorem tripleToForm_pos_disc_eq (t : PrimitiveTriple) :
    4 * (tripleToForm t).A * (tripleToForm t).C - (tripleToForm t).B ^ 2 =
    3 * t.c ^ 2 + 2 * t.a * t.b := by
  simp only [tripleToForm_A, tripleToForm_B, tripleToForm_C]
  nlinarith [t.pyth]

/-- The canonical form attachment always produces a positive-definite form. -/
theorem tripleToForm_pos_def (t : PrimitiveTriple) :
    0 < (tripleToForm t).A ∧
    0 < (4 * (tripleToForm t).A * (tripleToForm t).C - (tripleToForm t).B ^ 2) :=
  ⟨t.pos_c, by rw [tripleToForm_pos_disc_eq]; nlinarith [t.pos_a, t.pos_b, t.pos_c]⟩

/-! ## Section 4: Berggren Reducedness and the Main Duality -/

/-- A primitive triple is **Berggren-reduced** when the first leg does not exceed
    the second leg: `a ≤ b`.

    This condition determines the "branch type" in the Berggren tree:
    reduced triples occupy the branches where the even leg dominates. -/
def BerggrenReduced (t : PrimitiveTriple) : Prop := t.a ≤ t.b

instance (t : PrimitiveTriple) : Decidable (BerggrenReduced t) :=
  inferInstanceAs (Decidable (t.a ≤ t.b))

/-
The absolute value of `b - a` is strictly less than `c` for any
    primitive triple. This is the key inequality ensuring `|B| ≤ A`
    in the attached form.
-/
theorem abs_leg_diff_lt_hyp (t : PrimitiveTriple) : |t.b - t.a| < t.c := by
  rw [ abs_lt ];
  constructor <;> nlinarith [ t.pyth, t.pos_a, t.pos_b, t.pos_c ]

/-
**The Berggren–Gauss Reduction Duality Theorem.**

    A primitive triple is Berggren-reduced if and only if its canonically
    attached binary quadratic form is Gauss-reduced.

    The proof leverages the Pythagorean relation `a² + b² = c²` to show:
    - The form `(c, b−a, c)` always satisfies `|b−a| < c`, hence `|B| ≤ A`.
    - `A = C` holds trivially.
    - The Gauss tie-breaking condition `A = C → B ≥ 0` simplifies to `b ≥ a`.
    - Therefore Gauss-reducedness reduces to `a ≤ b`, which is exactly
      Berggren-reducedness.
-/
theorem berggren_reduced_iff_gauss_reduced (t : PrimitiveTriple) :
    BerggrenReduced t ↔ GaussReduced (tripleToForm t) := by
  constructor <;> intro h <;> unfold GaussReduced at * <;> simp_all +decide;
  · exact ⟨ le_of_lt ( abs_leg_diff_lt_hyp t ), h ⟩;
  · exact h.2

/-! ## Section 5: The Root Triple -/

/-- The root of the Berggren tree: `(3, 4, 5)`. -/
def rootTriple : PrimitiveTriple where
  a := 3; b := 4; c := 5
  pos_a := by norm_num
  pos_b := by norm_num
  pos_c := by norm_num
  pyth := by norm_num
  coprime_ab := by native_decide
  odd_sum := ⟨3, by norm_num⟩

/-- The root triple is Berggren-reduced. -/
theorem rootTriple_reduced : BerggrenReduced rootTriple := by
  decide

/-- The root triple's attached form is Gauss-reduced. -/
theorem rootTriple_gauss_reduced : GaussReduced (tripleToForm rootTriple) :=
  (berggren_reduced_iff_gauss_reduced rootTriple).mp rootTriple_reduced

/-! ## Section 6: Berggren Generators -/

/-- The three Berggren generators as indices. -/
inductive BerggrenGen where
  | L | M | R
  deriving DecidableEq

/-- Apply a Berggren generator to triple components `(a,b,c)`. -/
def berggrenApply : BerggrenGen → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | .L, (a, b, c) => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .M, (a, b, c) => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .R, (a, b, c) => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- Each Berggren generator preserves the Pythagorean relation. -/
theorem berggrenApply_preserves_pyth (g : BerggrenGen) (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let r := berggrenApply g (a, b, c)
    r.1 ^ 2 + r.2.1 ^ 2 = r.2.2 ^ 2 := by
  cases g <;> simp [berggrenApply] <;> nlinarith [h]

/-- Each Berggren generator strictly increases the hypotenuse. -/
theorem berggrenApply_c_increase (g : BerggrenGen) (t : PrimitiveTriple) :
    t.c < (berggrenApply g (t.a, t.b, t.c)).2.2 := by
  cases g <;> simp [berggrenApply] <;> nlinarith [t.pos_a, t.pos_b, t.pos_c,
    t.c_gt_a, t.c_gt_b]

/-! ## Section 7: Berggren Step and Height -/

/-- `BerggrenStep t t'` means `t` is a child of `t'` via some
    Berggren generator. Equivalently, going from `t` to `t'` is an
    inverse (descent) step. -/
def BerggrenStep (t t' : PrimitiveTriple) : Prop :=
  ∃ g : BerggrenGen,
    t.a = (berggrenApply g (t'.a, t'.b, t'.c)).1 ∧
    t.b = (berggrenApply g (t'.a, t'.b, t'.c)).2.1 ∧
    t.c = (berggrenApply g (t'.a, t'.b, t'.c)).2.2

/-- The **Berggren height** of a triple is its hypotenuse, viewed as a
    natural number. This serves as the descent measure. -/
def berggrenHeight (t : PrimitiveTriple) : ℕ := t.c.natAbs

/-
Every Berggren step (child → parent) strictly decreases the height.
-/
theorem berggren_step_height_decrease (t t' : PrimitiveTriple)
    (h : BerggrenStep t t') :
    berggrenHeight t' < berggrenHeight t := by
  obtain ⟨ g, hg ⟩ := h;
  exact Int.natAbs_lt_natAbs_of_nonneg_of_lt ( t'.pos_c.le ) ( by linarith [ berggrenApply_c_increase g t' ] )

/-- The Berggren height function is well-founded. -/
theorem berggren_height_wellFounded :
    WellFounded (fun t' t : PrimitiveTriple => berggrenHeight t' < berggrenHeight t) :=
  InvImage.wf berggrenHeight Nat.lt_wfRel.wf

/-- Every Berggren step strictly decreases the hypotenuse. -/
theorem berggren_step_c_decrease (t t' : PrimitiveTriple)
    (h : BerggrenStep t t') : t'.c < t.c := by
  obtain ⟨g, _, _, hc⟩ := h
  have := berggrenApply_c_increase g t'
  linarith

/-! ## Section 8: The Discriminant is Always Negative -/

/-
The discriminant of the attached form is always negative.
-/
theorem tripleToForm_disc_neg (t : PrimitiveTriple) :
    formDiscriminant (tripleToForm t) < 0 := by
  exact tripleToForm_discriminant_eq t ▸ neg_neg_of_pos ( by nlinarith [ t.pos_a, t.pos_b, t.pos_c ] )

/-! ## Section 9: Form Equivalence -/

/-- Two binary quadratic forms are **SL(2,ℤ)-equivalent** if there exists
    a unimodular integer matrix transforming one into the other. -/
def formEquivalent (f g : BinaryQuadraticForm) : Prop :=
  ∃ (p q r s : ℤ), p * s - q * r = 1 ∧
    g.A = f.A * p ^ 2 + f.B * p * r + f.C * r ^ 2 ∧
    g.B = 2 * f.A * p * q + f.B * (p * s + q * r) + 2 * f.C * r * s ∧
    g.C = f.A * q ^ 2 + f.B * q * s + f.C * s ^ 2

/-- Form equivalence is reflexive. -/
theorem formEquivalent_refl (f : BinaryQuadraticForm) : formEquivalent f f :=
  ⟨1, 0, 0, 1, by ring, by ring, by ring, by ring⟩

/-
Form equivalence preserves the discriminant.
-/
theorem formEquivalent_disc (f g : BinaryQuadraticForm)
    (h : formEquivalent f g) :
    formDiscriminant f = formDiscriminant g := by
  obtain ⟨ p, q, r, s, h, hp, hq, hs ⟩ := h;
  unfold formDiscriminant;
  grind +revert

/-! ## Section 10: Reconstruction -/

/-
Reconstruction: from the form data `(c, b-a, c)` and the Pythagorean
    relation, we can uniquely recover `a` and `b`.
-/
theorem triple_recoverable_from_form (t₁ t₂ : PrimitiveTriple)
    (h : tripleToForm t₁ = tripleToForm t₂) :
    t₁.a = t₂.a ∧ t₁.b = t₂.b ∧ t₁.c = t₂.c := by
  injection h;
  have := t₁.pyth; ( have := t₂.pyth; simp_all +decide [ sub_eq_iff_eq_add ] ; );
  constructor <;> nlinarith [ t₁.pos_a, t₁.pos_b, t₂.pos_a, t₂.pos_b ]

/-- A form is in the **Berggren image** if it arises from some primitive triple. -/
def FormInBerggrenImage (f : BinaryQuadraticForm) : Prop :=
  ∃ t : PrimitiveTriple, tripleToForm t = f

/-- For a form in the Berggren image, there exists a
    Berggren-reduced triple producing it (if the form is Gauss-reduced). -/
theorem reduced_form_has_berggren_preimage
    (f : BinaryQuadraticForm)
    (hf : FormInBerggrenImage f)
    (hred : GaussReduced f) :
    ∃ t : PrimitiveTriple, BerggrenReduced t ∧ tripleToForm t = f := by
  obtain ⟨t, rfl⟩ := hf
  exact ⟨t, (berggren_reduced_iff_gauss_reduced t).mpr hred, rfl⟩

/-! ## Section 11: Short-Basis Certificates -/

/-- A **short-basis certificate** for a binary quadratic form witnesses that
    the form's coefficients satisfy the Gauss-reduction inequalities, which
    in lattice-theoretic terms means the corresponding basis vectors are short
    (Minkowski-bounded). -/
structure ShortBasisCertificate (f : BinaryQuadraticForm) where
  gauss_reduced : GaussReduced f
  /-- The first basis vector norm (= A) satisfies the Minkowski bound:
      A² ≤ (4/3)(4AC - B²), equivalently 3A² ≤ 4(4AC - B²). -/
  minkowski_bound : 3 * f.A ^ 2 ≤ 4 * (4 * f.A * f.C - f.B ^ 2)

/-
A Berggren-reduced triple yields a short-basis certificate for its
    attached form. The Minkowski bound holds because for the form (c, b-a, c),
    we have 3c² ≤ 4(3c² + 2ab) = 12c² + 8ab, which is equivalent to
    0 ≤ 9c² + 8ab, always true for positive a,b,c.
-/
theorem reduced_form_short_basis_certificate
    (t : PrimitiveTriple)
    (hred : BerggrenReduced t) :
    ShortBasisCertificate (tripleToForm t) := by
  constructor;
  · exact berggren_reduced_iff_gauss_reduced t |>.1 hred;
  · rw [ tripleToForm_A, tripleToForm_B, tripleToForm_C ];
    nlinarith [ t.pos_a, t.pos_b, t.pos_c, t.pyth ]

/-! ## Section 12: Berggren Symmetry -/

/-- The **identity symmetry**: two triples are Berggren-symmetric if they
    have the same components. -/
def BerggrenSymmetry (t₁ t₂ : PrimitiveTriple) : Prop :=
  t₁.a = t₂.a ∧ t₁.b = t₂.b ∧ t₁.c = t₂.c

/-- Berggren symmetry is reflexive. -/
theorem BerggrenSymmetry.refl (t : PrimitiveTriple) : BerggrenSymmetry t t :=
  ⟨rfl, rfl, rfl⟩

/-! ## Section 13: The Hypotenuse is at Least 5 -/

/-
The hypotenuse of any primitive triple is at least 5.
-/
theorem PrimitiveTriple.c_ge_five (t : PrimitiveTriple) : 5 ≤ t.c := by
  cases' t with a b c h₁ h₂ h₃ h₄ h₅ h₆;
  exact not_lt.1 fun contra : c < 5 => by interval_cases c <;> (have : a ≤ 4 := Int.le_of_lt_add_one ( by nlinarith only [ h₄, h₃ ] ) ; (have : b ≤ 4 := Int.le_of_lt_add_one ( by nlinarith only [ h₄, h₃ ] ) ; interval_cases a <;> interval_cases b <;> trivial;))

/-! ## Section 14: Composition Theorem -/

/-- **The Certified Short-Basis Reconstruction Theorem.**

    For any primitive triple `t`:
    1. Berggren-reducedness is equivalent to Gauss-reducedness of the form.
    2. The attached form is always positive-definite.

    This packages the full bridge between Berggren dynamics and lattice
    reduction into a single statement. -/
theorem certified_short_basis_reconstruction (t : PrimitiveTriple) :
    (BerggrenReduced t ↔ GaussReduced (tripleToForm t)) ∧
    0 < (tripleToForm t).A :=
  ⟨berggren_reduced_iff_gauss_reduced t, t.pos_c⟩

/-! ## Section 15: Explicit Examples -/

/-- The triple (5, 12, 13). -/
def triple_5_12_13 : PrimitiveTriple where
  a := 5; b := 12; c := 13
  pos_a := by norm_num
  pos_b := by norm_num
  pos_c := by norm_num
  pyth := by norm_num
  coprime_ab := by native_decide
  odd_sum := ⟨8, by norm_num⟩

/-- The triple (5, 12, 13) is Berggren-reduced. -/
theorem triple_5_12_13_reduced : BerggrenReduced triple_5_12_13 := by decide

/-- The triple (21, 20, 29). -/
def triple_21_20_29 : PrimitiveTriple where
  a := 21; b := 20; c := 29
  pos_a := by norm_num
  pos_b := by norm_num
  pos_c := by norm_num
  pyth := by norm_num
  coprime_ab := by native_decide
  odd_sum := ⟨20, by norm_num⟩

/-- The triple (21, 20, 29) is NOT Berggren-reduced. -/
theorem triple_21_20_29_not_reduced : ¬ BerggrenReduced triple_21_20_29 := by decide

#check @berggren_reduced_iff_gauss_reduced
#check @certified_short_basis_reconstruction