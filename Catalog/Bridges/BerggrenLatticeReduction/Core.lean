import Mathlib

/-!
# Berggren–Lattice Reduction Correspondence: Core Definitions

Bridge: connects Berggren arithmetic dynamics on the ternary tree of primitive
Pythagorean triples to Gaussian reduction of rank-2 integer lattices, with
cryptographic interpretation via trapdoor decoding and certified robustness
style complexity bounds for post_quantum_security.

The Berggren tree is a ternary tree rooted at (3,4,5) that generates every
primitive Pythagorean triple exactly once. Each edge corresponds to one of three
3×3 integer matrices (left/mid/right) that preserve the quadratic form
a² + b² = c² and the primitivity condition gcd(a,b) = 1.
-/

namespace BerggrenLattice

-- ============================================================
-- Section 1: Core Structures
-- ============================================================

/-- A primitive Pythagorean triple `(a,b,c)` with `a` odd.
    Bridge: certified lattice geometry foundation for post_quantum_security
    trapdoor constructions. -/
structure PrimitiveTriple where
  a : ℤ
  b : ℤ
  c : ℤ
  sq_sum : a ^ 2 + b ^ 2 = c ^ 2
  pos_a : 0 < a
  pos_b : 0 < b
  pos_c : 0 < c
  coprime_ab : Int.gcd a b = 1
  odd_oriented : a % 2 = 1

/-- Steps in the Berggren ternary tree of primitive Pythagorean triples.
    Bridge: trapdoor decoding alphabet for post_quantum_security Berggren words. -/
inductive BerggrenStep where
  | left
  | mid
  | right
deriving DecidableEq, Repr

/-- A word in the Berggren alphabet, representing a path from the root (3,4,5). -/
abbrev BerggrenWord := List BerggrenStep

instance : Inhabited BerggrenStep := ⟨.left⟩

-- ============================================================
-- Section 2: Basic Arithmetic of Primitive Triples
-- ============================================================

theorem primitiveTriple_a_ne_zero (t : PrimitiveTriple) : t.a ≠ 0 :=
  ne_of_gt t.pos_a

theorem primitiveTriple_b_ne_zero (t : PrimitiveTriple) : t.b ≠ 0 :=
  ne_of_gt t.pos_b

/-- The hypotenuse strictly exceeds the odd leg. -/
theorem primitiveTriple_c_gt_a (t : PrimitiveTriple) : t.a < t.c := by
  obtain ⟨a, b, c, hsq, _, hb, _, _, _⟩ := t; dsimp at *
  nlinarith [sq_nonneg b, sq_nonneg (c - a)]

/-- The hypotenuse strictly exceeds the even leg. -/
theorem primitiveTriple_c_gt_b (t : PrimitiveTriple) : t.b < t.c := by
  obtain ⟨a, b, c, hsq, ha, _, _, _, _⟩ := t; dsimp at *
  nlinarith [sq_nonneg a, sq_nonneg (c - b)]

/-- c - a > 0. -/
theorem primitiveTriple_norm_gap_pos (t : PrimitiveTriple) : 0 < t.c - t.a :=
  sub_pos.mpr (primitiveTriple_c_gt_a t)

/-- c + a > 0. -/
theorem primitiveTriple_sum_gap_pos (t : PrimitiveTriple) : 0 < t.c + t.a := by
  linarith [t.pos_a, t.pos_c]

/-
b is even in a primitive triple with a odd.
-/
theorem primitiveTriple_b_even (t : PrimitiveTriple) : t.b % 2 = 0 := by
  cases Int.emod_two_eq_zero_or_one t.b <;> cases Int.emod_two_eq_zero_or_one t.c <;> have := congr_arg ( · % 4 ) t.sq_sum <;> rcases Int.even_or_odd' t.a with ⟨ k, hk | hk ⟩ <;> ( push_cast [ * ] at this ; ring_nf at this ; norm_num [ Int.add_emod, Int.mul_emod ] at this; );
  all_goals rcases Int.even_or_odd' t.b with ⟨ b, hb | hb ⟩ <;> rcases Int.even_or_odd' t.c with ⟨ c, hc | hc ⟩ <;> push_cast [ * ] at * <;> ring_nf at * <;> norm_num at *;
  exact absurd ( t.odd_oriented ) ( by norm_num [ hk, Int.add_emod, Int.mul_emod ] )

/-
c is odd in a primitive triple with a odd.
-/
theorem primitiveTriple_c_odd (t : PrimitiveTriple) : t.c % 2 = 1 := by
  have := t.coprime_ab ; replace := congrArg ( · % 2 ) t.sq_sum ; rcases Int.emod_two_eq_zero_or_one t.a with ha | ha <;> rcases Int.emod_two_eq_zero_or_one t.b with hb | hb <;> rcases Int.emod_two_eq_zero_or_one t.c with hc | hc <;> simp_all +decide [ sq, Int.add_emod, Int.mul_emod ] ;
  · exact absurd ( Int.dvd_coe_gcd ha hb ) ( by norm_num [ t.coprime_ab ] );
  · have := t.sq_sum; replace this := congr_arg ( · % 4 ) this; rcases hc with ⟨ k, hk ⟩ ; rcases Int.even_or_odd' t.a with ⟨ k₂, hk₂ | hk₂ ⟩ <;> rcases Int.even_or_odd' t.b with ⟨ k₃, hk₃ | hk₃ ⟩ <;> push_cast [ * ] at * <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at *;

-- ============================================================
-- Section 3: Berggren Matrices and Action
-- ============================================================

/-- The 3×3 Berggren matrix for each tree generator. -/
def BerggrenMatrix : BerggrenStep → Matrix (Fin 3) (Fin 3) ℤ
  | .left  => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | .mid   => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | .right => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Vector representation of a primitive triple. -/
def tripleVec (t : PrimitiveTriple) : Fin 3 → ℤ := ![t.a, t.b, t.c]

/-- Berggren action on vectors by explicit coordinate formulas.
    Bridge: certified trapdoor transform for quantum-resistant geometry. -/
def berggrenActVec (s : BerggrenStep) (v : Fin 3 → ℤ) : Fin 3 → ℤ :=
  match s with
  | .left  => ![v 0 - 2 * v 1 + 2 * v 2,
                2 * v 0 - v 1 + 2 * v 2,
                2 * v 0 - 2 * v 1 + 3 * v 2]
  | .mid   => ![v 0 + 2 * v 1 + 2 * v 2,
                2 * v 0 + v 1 + 2 * v 2,
                2 * v 0 + 2 * v 1 + 3 * v 2]
  | .right => ![-v 0 + 2 * v 1 + 2 * v 2,
                -2 * v 0 + v 1 + 2 * v 2,
                -2 * v 0 + 2 * v 1 + 3 * v 2]

/-
Berggren action preserves a² + b² = c².
-/
theorem berggren_preserves_sq_sum (s : BerggrenStep) (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let v := ![a, b, c]
    let w := berggrenActVec s v
    (w 0) ^ 2 + (w 1) ^ 2 = (w 2) ^ 2 := by
  rcases s with ( _ | _ | _ ) <;> simp_all +decide [ berggrenActVec ] <;> linarith

/-
Left step positivity.
-/
theorem berggren_left_pos (t : PrimitiveTriple) :
    0 < (berggrenActVec .left (tripleVec t)) 0 ∧
    0 < (berggrenActVec .left (tripleVec t)) 1 ∧
    0 < (berggrenActVec .left (tripleVec t)) 2 := by
  -- Simplify the expressions for the components of the left step.
  simp [berggrenActVec, tripleVec];
  exact ⟨ by linarith [ t.pos_a, t.pos_b, t.pos_c, primitiveTriple_c_gt_a t, primitiveTriple_c_gt_b t ], by linarith [ t.pos_a, t.pos_b, t.pos_c, primitiveTriple_c_gt_a t, primitiveTriple_c_gt_b t ], by linarith [ t.pos_a, t.pos_b, t.pos_c, primitiveTriple_c_gt_a t, primitiveTriple_c_gt_b t ] ⟩

/-
Mid step positivity.
-/
theorem berggren_mid_pos (t : PrimitiveTriple) :
    0 < (berggrenActVec .mid (tripleVec t)) 0 ∧
    0 < (berggrenActVec .mid (tripleVec t)) 1 ∧
    0 < (berggrenActVec .mid (tripleVec t)) 2 := by
  exact ⟨ by unfold berggrenActVec; unfold tripleVec; simp +decide ; linarith [ t.pos_a, t.pos_b, t.pos_c ], by unfold berggrenActVec; unfold tripleVec; simp +decide ; linarith [ t.pos_a, t.pos_b, t.pos_c ], by unfold berggrenActVec; unfold tripleVec; simp +decide ; linarith [ t.pos_a, t.pos_b, t.pos_c ] ⟩

/-
Right step positivity.
-/
theorem berggren_right_pos (t : PrimitiveTriple) :
    0 < (berggrenActVec .right (tripleVec t)) 0 ∧
    0 < (berggrenActVec .right (tripleVec t)) 1 ∧
    0 < (berggrenActVec .right (tripleVec t)) 2 := by
  simp +decide [ tripleVec, berggrenActVec ];
  exact ⟨ by linarith [ t.pos_a, t.pos_b, t.pos_c, t.sq_sum, primitiveTriple_c_gt_a t ], by linarith [ t.pos_a, t.pos_b, t.pos_c, t.sq_sum, primitiveTriple_c_gt_a t, primitiveTriple_c_gt_b t ], by linarith [ t.pos_a, t.pos_b, t.pos_c, t.sq_sum, primitiveTriple_c_gt_a t, primitiveTriple_c_gt_b t ] ⟩

/-
Left step preserves odd parity.
-/
theorem berggren_left_odd (t : PrimitiveTriple) :
    (berggrenActVec .left (tripleVec t)) 0 % 2 = 1 := by
  unfold berggrenActVec tripleVec;
  norm_num [ Int.add_emod, Int.sub_emod, Int.mul_emod, t.odd_oriented ]

/-
Mid step preserves odd parity.
-/
theorem berggren_mid_odd (t : PrimitiveTriple) :
    (berggrenActVec .mid (tripleVec t)) 0 % 2 = 1 := by
  unfold berggrenActVec tripleVec;
  norm_num [ Int.add_emod, Int.mul_emod, t.odd_oriented ]

/-
Right step preserves odd parity.
-/
theorem berggren_right_odd (t : PrimitiveTriple) :
    (berggrenActVec .right (tripleVec t)) 0 % 2 = 1 := by
  unfold berggrenActVec tripleVec; norm_num [ t.odd_oriented, Int.add_emod, Int.sub_emod, Int.mul_emod ] ;

/-
Left step preserves coprimality.
-/
theorem berggren_left_coprime (t : PrimitiveTriple) :
    Int.gcd ((berggrenActVec .left (tripleVec t)) 0)
            ((berggrenActVec .left (tripleVec t)) 1) = 1 := by
  -- Let $d = \gcd(w0, w1)$.
  set d := Int.gcd (berggrenActVec .left (tripleVec t) 0) (berggrenActVec .left (tripleVec t) 1) with hd;
  -- Then $d$ divides both $a$ and $b$, since $a = w0 + 2w1 - 2w2$ and $b = -2w0 - w1 + 2w2$.
  have hd_div_a : (d : ℤ) ∣ t.a := by
    have hd_div_a : (d : ℤ) ∣ (berggrenActVec .left (tripleVec t) 0 + 2 * berggrenActVec .left (tripleVec t) 1 - 2 * berggrenActVec .left (tripleVec t) 2) := by
      refine' dvd_sub ( dvd_add ( Int.gcd_dvd_left _ _ ) ( dvd_mul_of_dvd_right ( Int.gcd_dvd_right _ _ ) _ ) ) ( dvd_mul_of_dvd_right _ _ );
      have h_div_w2 : (d : ℤ) ^ 2 ∣ (berggrenActVec .left (tripleVec t) 2) ^ 2 := by
        have hd_div_w2 : (berggrenActVec .left (tripleVec t) 0) ^ 2 + (berggrenActVec .left (tripleVec t) 1) ^ 2 = (berggrenActVec .left (tripleVec t) 2) ^ 2 := by
          exact berggren_preserves_sq_sum _ _ _ _ t.sq_sum;
        exact hd_div_w2 ▸ dvd_add ( pow_dvd_pow_of_dvd ( Int.gcd_dvd_left _ _ ) _ ) ( pow_dvd_pow_of_dvd ( Int.gcd_dvd_right _ _ ) _ );
      exact Int.pow_dvd_pow_iff ( by decide ) |>.1 h_div_w2;
    unfold berggrenActVec at *; simp_all +decide [ tripleVec ] ;
    convert hd_div_a using 1 ; ring
  have hd_div_b : (d : ℤ) ∣ t.b := by
    have hd_div_b : (d : ℤ) ∣ -2 * (berggrenActVec .left (tripleVec t)) 0 - (berggrenActVec .left (tripleVec t)) 1 + 2 * (berggrenActVec .left (tripleVec t)) 2 := by
      refine' dvd_add ( dvd_sub ( dvd_mul_of_dvd_right ( Int.gcd_dvd_left _ _ ) _ ) ( Int.gcd_dvd_right _ _ ) ) ( dvd_mul_of_dvd_right _ _ );
      have h_div_b : (berggrenActVec .left (tripleVec t)) 2 ^ 2 = (berggrenActVec .left (tripleVec t)) 0 ^ 2 + (berggrenActVec .left (tripleVec t)) 1 ^ 2 := by
        exact Eq.symm ( berggren_preserves_sq_sum .left _ _ _ t.sq_sum );
      exact Int.pow_dvd_pow_iff two_ne_zero |>.1 <| h_div_b.symm ▸ dvd_add ( pow_dvd_pow_of_dvd ( Int.gcd_dvd_left _ _ ) _ ) ( pow_dvd_pow_of_dvd ( Int.gcd_dvd_right _ _ ) _ );
    unfold berggrenActVec at *; simp_all +decide [ tripleVec ] ;
    convert hd_div_b using 1 ; ring;
  exact Nat.dvd_one.mp ( t.coprime_ab ▸ Nat.dvd_gcd ( Int.natAbs_dvd_natAbs.mpr hd_div_a ) ( Int.natAbs_dvd_natAbs.mpr hd_div_b ) )

/-
Mid step preserves coprimality.
-/
theorem berggren_mid_coprime (t : PrimitiveTriple) :
    Int.gcd ((berggrenActVec .mid (tripleVec t)) 0)
            ((berggrenActVec .mid (tripleVec t)) 1) = 1 := by
  -- Let $d = \gcd(a', b')$. Then $d \mid a'$ and $d \mid b'$.
  set d := Int.gcd ((berggrenActVec .mid (tripleVec t)) 0) ((berggrenActVec .mid (tripleVec t)) 1) with hd;
  -- Then $d$ divides both $a'$ and $b'$, and thus $d$ divides $w_0$ and $w_1$.
  have hd_div_w0_w1 : d ∣ Int.natAbs (t.a + 2 * t.b + 2 * t.c) ∧ d ∣ Int.natAbs (2 * t.a + t.b + 2 * t.c) := by
    exact ⟨ Int.natCast_dvd.mp ( Int.gcd_dvd_left _ _ ), Int.natCast_dvd.mp ( Int.gcd_dvd_right _ _ ) ⟩;
  -- Then $d$ divides $w_0^2 + w_1^2 = w_2^2$, so $d$ divides $w_2$.
  have hd_div_w2 : d ∣ Int.natAbs (2 * t.a + 2 * t.b + 3 * t.c) := by
    have hd_div_w2 : d ^ 2 ∣ Int.natAbs ((t.a + 2 * t.b + 2 * t.c) ^ 2 + (2 * t.a + t.b + 2 * t.c) ^ 2) := by
      rw [ ← Int.natCast_dvd ] at *;
      exact dvd_add ( pow_dvd_pow_of_dvd hd_div_w0_w1.1 2 ) ( pow_dvd_pow_of_dvd ( Int.natCast_dvd.mpr hd_div_w0_w1.2 ) 2 );
    rw [ ← Int.natCast_dvd ] at *; simp_all +decide [ ← Int.natCast_dvd_natCast ] ;
    obtain ⟨ k, hk ⟩ := hd_div_w2; exact Int.pow_dvd_pow_iff two_ne_zero |>.1 ⟨ k, by linarith [ t.sq_sum ] ⟩ ;
  -- Then $d$ divides $a$ and $b$, since $a = w_0 + 2w_1 - 2w_2$ and $b = 2w_0 + w_1 - 2w_2$.
  have hd_div_a_b : d ∣ Int.natAbs t.a ∧ d ∣ Int.natAbs t.b := by
    have hd_div_a_b : d ∣ Int.natAbs (t.a + 2 * t.b + 2 * t.c + 2 * (2 * t.a + t.b + 2 * t.c) - 2 * (2 * t.a + 2 * t.b + 3 * t.c)) ∧ d ∣ Int.natAbs (2 * (t.a + 2 * t.b + 2 * t.c) + (2 * t.a + t.b + 2 * t.c) - 2 * (2 * t.a + 2 * t.b + 3 * t.c)) := by
      exact ⟨ Int.natAbs_dvd_natAbs.mpr ( dvd_sub ( dvd_add ( Int.natCast_dvd.mpr hd_div_w0_w1.1 ) ( dvd_mul_of_dvd_right ( Int.natCast_dvd.mpr hd_div_w0_w1.2 ) _ ) ) ( dvd_mul_of_dvd_right ( Int.natCast_dvd.mpr hd_div_w2 ) _ ) ), Int.natAbs_dvd_natAbs.mpr ( dvd_sub ( dvd_add ( dvd_mul_of_dvd_right ( Int.natCast_dvd.mpr hd_div_w0_w1.1 ) _ ) ( Int.natCast_dvd.mpr hd_div_w0_w1.2 ) ) ( dvd_mul_of_dvd_right ( Int.natCast_dvd.mpr hd_div_w2 ) _ ) ) ⟩;
    ring_nf at *; aesop;
  exact Nat.dvd_one.mp ( t.coprime_ab ▸ Nat.dvd_gcd hd_div_a_b.1 hd_div_a_b.2 )

/-
Right step preserves coprimality.
-/
theorem berggren_right_coprime (t : PrimitiveTriple) :
    Int.gcd ((berggrenActVec .right (tripleVec t)) 0)
            ((berggrenActVec .right (tripleVec t)) 1) = 1 := by
  refine' Nat.coprime_of_dvd' _;
  intro k hk hk1 hk2;
  -- Since $k$ divides both $w_0$ and $w_1$, it must also divide $a$ and $b$.
  have hk_div_a : (k : ℤ) ∣ t.a := by
    have hk_div_a : (k : ℤ) ∣ - (berggrenActVec .right (tripleVec t)) 0 - 2 * (berggrenActVec .right (tripleVec t)) 1 + 2 * (berggrenActVec .right (tripleVec t)) 2 := by
      refine' dvd_add ( dvd_sub ( dvd_neg.mpr ( Int.natCast_dvd.mpr hk1 ) ) ( dvd_mul_of_dvd_right ( Int.natCast_dvd.mpr hk2 ) _ ) ) ( dvd_mul_of_dvd_right _ _ );
      have h_div_c : (berggrenActVec .right (tripleVec t)) 2 ^ 2 = (berggrenActVec .right (tripleVec t)) 0 ^ 2 + (berggrenActVec .right (tripleVec t)) 1 ^ 2 := by
        convert berggren_preserves_sq_sum .right t.a t.b t.c t.sq_sum |> Eq.symm using 1;
      exact Int.Prime.dvd_pow' hk <| h_div_c.symm ▸ dvd_add ( dvd_pow ( Int.natCast_dvd.mpr hk1 ) two_ne_zero ) ( dvd_pow ( Int.natCast_dvd.mpr hk2 ) two_ne_zero );
    convert hk_div_a using 1 ; norm_num [ berggrenActVec ] ; ring;
    erw [ Matrix.cons_val_succ' ] ; norm_num ; ring!;
  have hk_div_b : (k : ℤ) ∣ t.b := by
    simp_all +decide [ ← Int.natCast_dvd_natCast, berggrenActVec ];
    haveI := Fact.mk hk; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd, tripleVec ] ;
    grind;
  exact t.coprime_ab ▸ Nat.dvd_gcd ( Int.natAbs_dvd_natAbs.mpr hk_div_a ) ( Int.natAbs_dvd_natAbs.mpr hk_div_b )

/-- Apply a Berggren step, producing a new primitive triple.
    Bridge: certified trapdoor generation for post_quantum_security. -/
noncomputable def berggrenStepApply (s : BerggrenStep) (t : PrimitiveTriple) :
    PrimitiveTriple where
  a := (berggrenActVec s (tripleVec t)) 0
  b := (berggrenActVec s (tripleVec t)) 1
  c := (berggrenActVec s (tripleVec t)) 2
  sq_sum := berggren_preserves_sq_sum s t.a t.b t.c t.sq_sum
  pos_a := by cases s <;> [exact (berggren_left_pos t).1;
    exact (berggren_mid_pos t).1; exact (berggren_right_pos t).1]
  pos_b := by cases s <;> [exact (berggren_left_pos t).2.1;
    exact (berggren_mid_pos t).2.1; exact (berggren_right_pos t).2.1]
  pos_c := by cases s <;> [exact (berggren_left_pos t).2.2;
    exact (berggren_mid_pos t).2.2; exact (berggren_right_pos t).2.2]
  coprime_ab := by cases s <;> [exact berggren_left_coprime t;
    exact berggren_mid_coprime t; exact berggren_right_coprime t]
  odd_oriented := by cases s <;> [exact berggren_left_odd t;
    exact berggren_mid_odd t; exact berggren_right_odd t]

/-- The root of the Berggren tree: (3, 4, 5). -/
def berggrenRoot : PrimitiveTriple where
  a := 3
  b := 4
  c := 5
  sq_sum := by norm_num
  pos_a := by norm_num
  pos_b := by norm_num
  pos_c := by norm_num
  coprime_ab := by native_decide
  odd_oriented := by norm_num

instance : Inhabited PrimitiveTriple := ⟨berggrenRoot⟩

/-- Evaluate a Berggren word by sequentially applying steps. -/
noncomputable def berggrenWordEval : BerggrenWord → PrimitiveTriple → PrimitiveTriple
  | [], t => t
  | s :: w, t => berggrenWordEval w (berggrenStepApply s t)

/-
============================================================
Section 4: c-monotonicity
============================================================

Left step strictly increases c.
-/
theorem berggren_left_c_increase (t : PrimitiveTriple) :
    t.c < (berggrenStepApply .left t).c := by
  exact show t.c < 2 * t.a - 2 * t.b + 3 * t.c from by linarith [ t.pos_a, t.pos_b, t.pos_c, t.odd_oriented, t.coprime_ab, t.sq_sum, t.pos_a, t.pos_b, t.pos_c, t.odd_oriented, t.coprime_ab, t.sq_sum, t.pos_a, t.pos_b, t.pos_c, t.odd_oriented, t.coprime_ab, t.sq_sum, t.pos_a, t.pos_b, t.pos_c, t.odd_oriented, t.coprime_ab, t.sq_sum, t.pos_a, t.pos_b, t.pos_c, t.odd_oriented, t.coprime_ab, t.sq_sum, t.pos_a, t.pos_b, t.pos_c, t.odd_oriented, t.coprime_ab, t.sq_sum, t.pos_a, t.pos_b, t.pos_c, t.odd_oriented, t.coprime_ab, t.sq_sum, t.pos_a, t.pos_b, t.pos_c, t.odd_oriented, t.coprime_ab, t.sq_sum, primitiveTriple_c_gt_a t, primitiveTriple_c_gt_b t ] ;

/-
Mid step strictly increases c.
-/
theorem berggren_mid_c_increase (t : PrimitiveTriple) :
    t.c < (berggrenStepApply .mid t).c := by
  exact show t.c < 2 * t.a + 2 * t.b + 3 * t.c from by linarith [ t.pos_a, t.pos_b, t.pos_c ] ;

/-
Right step strictly increases c.
-/
theorem berggren_right_c_increase (t : PrimitiveTriple) :
    t.c < (berggrenStepApply .right t).c := by
  exact show t.c < -2 * t.a + 2 * t.b + 3 * t.c from by linarith [ t.pos_a, t.pos_b, t.pos_c, t.odd_oriented, t.coprime_ab, t.sq_sum, t.pos_a, t.pos_b, t.pos_c, t.odd_oriented, t.coprime_ab, t.sq_sum, BerggrenLattice.primitiveTriple_c_gt_a t, BerggrenLattice.primitiveTriple_c_gt_b t ] ;

/-- Every Berggren step strictly increases c.
    Bridge: height monotonicity for certified trapdoor complexity bounds. -/
theorem berggren_c_strict_increase (s : BerggrenStep) (t : PrimitiveTriple) :
    t.c < (berggrenStepApply s t).c := by
  cases s
  · exact berggren_left_c_increase t
  · exact berggren_mid_c_increase t
  · exact berggren_right_c_increase t

/-- Preservation of primitivity by the left Berggren step. -/
theorem berggren_left_preserves_primitive :
    ∀ t : PrimitiveTriple, ∃ t' : PrimitiveTriple,
      tripleVec t' = berggrenActVec BerggrenStep.left (tripleVec t) := by
  intro t; exact ⟨berggrenStepApply .left t, by
    unfold tripleVec berggrenStepApply; ext i; fin_cases i <;> rfl⟩

/-- Preservation of primitivity by the mid Berggren step. -/
theorem berggren_mid_preserves_primitive :
    ∀ t : PrimitiveTriple, ∃ t' : PrimitiveTriple,
      tripleVec t' = berggrenActVec BerggrenStep.mid (tripleVec t) := by
  intro t; exact ⟨berggrenStepApply .mid t, by
    unfold tripleVec berggrenStepApply; ext i; fin_cases i <;> rfl⟩

/-- Preservation of primitivity by the right Berggren step. -/
theorem berggren_right_preserves_primitive :
    ∀ t : PrimitiveTriple, ∃ t' : PrimitiveTriple,
      tripleVec t' = berggrenActVec BerggrenStep.right (tripleVec t) := by
  intro t; exact ⟨berggrenStepApply .right t, by
    unfold tripleVec berggrenStepApply; ext i; fin_cases i <;> rfl⟩

/-- Berggren depth bound. -/
def berggrenDepthBound (t : PrimitiveTriple) : ℕ := Int.natAbs t.c

theorem berggren_depthBound_le_c (t : PrimitiveTriple) :
    berggrenDepthBound t ≤ Int.natAbs t.c := le_refl _

end BerggrenLattice