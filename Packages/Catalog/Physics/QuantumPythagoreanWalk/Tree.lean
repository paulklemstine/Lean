import Mathlib

/-!
# Quantum-Pythagorean-Walk — I. The Berggren tree as a walk graph

This file sets up the state space of the "quantum Pythagorean walk": the Berggren
ternary tree of primitive Pythagorean triples (PPTs), rooted at `(3,4,5)`, whose three
branch operators are the classical Berggren matrices

```
A = [[1,-2,2],[2,-1,2],[2,-2,3]]   B = [[1,2,2],[2,1,2],[2,2,3]]   C = [[-1,2,2],[-2,1,2],[-2,2,3]]
```

We prove the structural facts that a walk needs:

* the branch operators preserve the property of being a *primitive* Pythagorean triple
  (`Node.IsPPT.branch`), including preservation of coprimality;
* every branch increases the hypotenuse by at least `8` (`hyp_add_eight_le_branch`) and by
  at most a factor `7` (`hyp_branch_le_seven_mul`);
* the slowest branch is exactly quadratic: `A^[n] (3,4,5) = (2n+3, 2n²+6n+4, 2n²+6n+5)`
  (`iterate_stepA_root`).

The two-sided growth estimate is what later produces both the *depth window* in which a
resonance can live and the exponential *search barrier* of `Barrier.lean`.

This extends the catalog files `Shared/BerggrenTrees/*`, which contained only the single
parent-hypotenuse estimate `parent_hyp_lt` and the matrix `B₃`.
-/

namespace QuantumPythagoreanWalk

/-- A node of the walk: an ordered triple of integers. -/
structure Node where
  a : ℤ
  b : ℤ
  c : ℤ
deriving DecidableEq, Repr

namespace Node

/-- A node is a *primitive Pythagorean triple*: positive entries, coprime legs,
and `a² + b² = c²`. -/
structure IsPPT (t : Node) : Prop where
  pyth : t.a ^ 2 + t.b ^ 2 = t.c ^ 2
  pos_a : 0 < t.a
  pos_b : 0 < t.b
  pos_c : 0 < t.c
  cop : IsCoprime t.a t.b

/-- The root of the Berggren tree. -/
def root : Node := ⟨3, 4, 5⟩

/-- Berggren branch `A`. -/
def stepA (t : Node) : Node := ⟨t.a - 2 * t.b + 2 * t.c, 2 * t.a - t.b + 2 * t.c,
  2 * t.a - 2 * t.b + 3 * t.c⟩

/-- Berggren branch `B`. -/
def stepB (t : Node) : Node := ⟨t.a + 2 * t.b + 2 * t.c, 2 * t.a + t.b + 2 * t.c,
  2 * t.a + 2 * t.b + 3 * t.c⟩

/-- Berggren branch `C`. -/
def stepC (t : Node) : Node := ⟨-t.a + 2 * t.b + 2 * t.c, -2 * t.a + t.b + 2 * t.c,
  -2 * t.a + 2 * t.b + 3 * t.c⟩

@[simp] lemma stepA_a (t : Node) : (stepA t).a = t.a - 2 * t.b + 2 * t.c := rfl
@[simp] lemma stepA_b (t : Node) : (stepA t).b = 2 * t.a - t.b + 2 * t.c := rfl
@[simp] lemma stepA_c (t : Node) : (stepA t).c = 2 * t.a - 2 * t.b + 3 * t.c := rfl
@[simp] lemma stepB_a (t : Node) : (stepB t).a = t.a + 2 * t.b + 2 * t.c := rfl
@[simp] lemma stepB_b (t : Node) : (stepB t).b = 2 * t.a + t.b + 2 * t.c := rfl
@[simp] lemma stepB_c (t : Node) : (stepB t).c = 2 * t.a + 2 * t.b + 3 * t.c := rfl
@[simp] lemma stepC_a (t : Node) : (stepC t).a = -t.a + 2 * t.b + 2 * t.c := rfl
@[simp] lemma stepC_b (t : Node) : (stepC t).b = -2 * t.a + t.b + 2 * t.c := rfl
@[simp] lemma stepC_c (t : Node) : (stepC t).c = -2 * t.a + 2 * t.b + 3 * t.c := rfl

/-- The three branch operators indexed by `Fin 3` (the "coin" of the walk). -/
def branch : Fin 3 → Node → Node
  | 0 => stepA
  | 1 => stepB
  | 2 => stepC

@[simp] lemma branch_zero (t : Node) : branch 0 t = stepA t := rfl
@[simp] lemma branch_one (t : Node) : branch 1 t = stepB t := rfl
@[simp] lemma branch_two (t : Node) : branch 2 t = stepC t := rfl

/-! ### Basic estimates for a PPT -/

theorem IsPPT.a_lt_c {t : Node} (h : t.IsPPT) : t.a < t.c := by
  nlinarith [h.pyth, h.pos_a, h.pos_b, h.pos_c]

theorem IsPPT.b_lt_c {t : Node} (h : t.IsPPT) : t.b < t.c := by
  nlinarith [h.pyth, h.pos_a, h.pos_b, h.pos_c]

/-- In a primitive triple no leg equals `1` or `2`: both legs are at least `3`. -/
theorem IsPPT.three_le_a {t : Node} (h : t.IsPPT) : 3 ≤ t.a := by
  by_contra hlt
  push_neg at hlt
  have hpy := h.pyth
  have ha := h.pos_a
  have hb := h.pos_b
  have hc := h.pos_c
  have hbc := h.b_lt_c
  have hcase : t.a = 1 ∨ t.a = 2 := by omega
  rcases hcase with h1 | h1 <;> rw [h1] at hpy
  · nlinarith
  · have hb1 : t.b = 1 := by nlinarith
    rw [hb1] at hpy
    rcases le_or_gt t.c 2 with h2 | h2 <;> nlinarith

theorem IsPPT.three_le_b {t : Node} (h : t.IsPPT) : 3 ≤ t.b := by
  by_contra hlt
  push_neg at hlt
  have hpy := h.pyth
  have ha := h.pos_a
  have hb := h.pos_b
  have hc := h.pos_c
  have hac := h.a_lt_c
  have hcase : t.b = 1 ∨ t.b = 2 := by omega
  rcases hcase with h1 | h1 <;> rw [h1] at hpy
  · nlinarith
  · have ha1 : t.a = 1 := by nlinarith
    rw [ha1] at hpy
    rcases le_or_gt t.c 2 with h2 | h2 <;> nlinarith

theorem IsPPT.five_le_c {t : Node} (h : t.IsPPT) : 5 ≤ t.c := by
  nlinarith [h.pyth, h.three_le_a, h.three_le_b, h.pos_c]

/-- The only primitive triple with first leg equal to `3` is `(3,4,5)`. -/
theorem IsPPT.eq_four_of_a_eq_three {t : Node} (h : t.IsPPT) (ha : t.a = 3) : t.b = 4 := by
  have hpy := h.pyth
  have hb3 := h.three_le_b
  have hbc := h.b_lt_c
  have hc := h.pos_c
  rw [ha] at hpy
  have hb4 : t.b ≤ 4 := by nlinarith
  have hcase : t.b = 3 ∨ t.b = 4 := by omega
  rcases hcase with h1 | h1
  · exfalso
    rw [h1] at hpy
    rcases le_or_gt t.c 4 with h2 | h2 <;> nlinarith
  · exact h1

theorem IsPPT.eq_four_of_b_eq_three {t : Node} (h : t.IsPPT) (hb : t.b = 3) : t.a = 4 := by
  have hpy := h.pyth
  have ha3 := h.three_le_a
  have hac := h.a_lt_c
  have hc := h.pos_c
  rw [hb] at hpy
  have ha4 : t.a ≤ 4 := by nlinarith
  have hcase : t.a = 3 ∨ t.a = 4 := by omega
  rcases hcase with h1 | h1
  · exfalso
    rw [h1] at hpy
    rcases le_or_gt t.c 4 with h2 | h2 <;> nlinarith
  · exact h1

/-- Key skewness estimate: `c + a - b ≥ 4` for every primitive triple. -/
theorem IsPPT.four_le_c_add_a_sub_b {t : Node} (h : t.IsPPT) : 4 ≤ t.c + t.a - t.b := by
  rcases le_or_gt t.b t.a with hba | hab
  · have := h.five_le_c; omega
  · rcases eq_or_lt_of_le h.three_le_a with ha3 | ha4
    · have hb : t.b = 4 := h.eq_four_of_a_eq_three ha3.symm
      have hpy := h.pyth
      have hc : t.c = 5 := by
        have hcpos := h.pos_c
        rw [← ha3, hb] at hpy
        nlinarith
      omega
    · have h4 : 4 ≤ t.a := ha4
      have hpos : 0 < t.b - t.a + 4 := by omega
      have key : (t.b - t.a + 4) ^ 2 ≤ t.c ^ 2 := by nlinarith [h.pyth, h.three_le_b]
      nlinarith [key, hpos, h.pos_c]

/-- Symmetric skewness estimate. -/
theorem IsPPT.four_le_c_add_b_sub_a {t : Node} (h : t.IsPPT) : 4 ≤ t.c + t.b - t.a := by
  rcases le_or_gt t.a t.b with hab | hba
  · have := h.five_le_c; omega
  · rcases eq_or_lt_of_le h.three_le_b with hb3 | hb4
    · have ha : t.a = 4 := h.eq_four_of_b_eq_three hb3.symm
      have hpy := h.pyth
      have hc : t.c = 5 := by
        have hcpos := h.pos_c
        rw [← hb3, ha] at hpy
        nlinarith
      omega
    · have h4 : 4 ≤ t.b := hb4
      have hpos : 0 < t.a - t.b + 4 := by omega
      have key : (t.a - t.b + 4) ^ 2 ≤ t.c ^ 2 := by nlinarith [h.pyth, h.three_le_a]
      nlinarith [key, hpos, h.pos_c]

/-! ### The branch operators preserve primitivity -/

/-- A common divisor of the two legs of a Pythagorean triple divides the hypotenuse. -/
theorem dvd_c_of_dvd_legs {a b c d : ℤ} (hpy : a ^ 2 + b ^ 2 = c ^ 2)
    (hda : d ∣ a) (hdb : d ∣ b) : d ∣ c := by
  have hd2 : d ^ 2 ∣ c ^ 2 := by
    rw [← hpy]
    exact dvd_add (pow_dvd_pow_of_dvd hda 2) (pow_dvd_pow_of_dvd hdb 2)
  exact (Int.pow_dvd_pow_iff (by norm_num)).mp hd2

/-- If the source legs are coprime and the source is recovered from the image by an
integral linear map (the Berggren matrices are unimodular), the image legs are coprime. -/
private theorem cop_of_inv (a b a' b' c' : ℤ) (hpy' : a' ^ 2 + b' ^ 2 = c' ^ 2)
    (hcop : IsCoprime a b) (α₁ α₂ α₃ β₁ β₂ β₃ : ℤ)
    (ha : a = α₁ * a' + α₂ * b' + α₃ * c') (hb : b = β₁ * a' + β₂ * b' + β₃ * c') :
    IsCoprime a' b' := by
  rw [Int.isCoprime_iff_gcd_eq_one] at hcop ⊢
  by_contra hne
  obtain ⟨p, hp, hpd⟩ := Nat.exists_prime_and_dvd hne
  have hpg : (p : ℤ) ∣ ((Int.gcd a' b' : ℕ) : ℤ) := Int.natCast_dvd_natCast.mpr hpd
  have hpa' : (p : ℤ) ∣ a' := hpg.trans (Int.gcd_dvd_left a' b')
  have hpb' : (p : ℤ) ∣ b' := hpg.trans (Int.gcd_dvd_right a' b')
  have hpc' : (p : ℤ) ∣ c' := dvd_c_of_dvd_legs hpy' hpa' hpb'
  have hpa : (p : ℤ) ∣ a := by
    rw [ha]
    exact dvd_add (dvd_add (Dvd.dvd.mul_left hpa' _) (Dvd.dvd.mul_left hpb' _))
      (Dvd.dvd.mul_left hpc' _)
  have hpb : (p : ℤ) ∣ b := by
    rw [hb]
    exact dvd_add (dvd_add (Dvd.dvd.mul_left hpa' _) (Dvd.dvd.mul_left hpb' _))
      (Dvd.dvd.mul_left hpc' _)
  have hdvd := Int.dvd_gcd hpa hpb
  rw [hcop] at hdvd
  have hp1 : p ∣ 1 := by exact_mod_cast hdvd
  exact hp.ne_one (Nat.dvd_one.mp hp1)

theorem IsPPT.stepA {t : Node} (h : t.IsPPT) : (Node.stepA t).IsPPT := by
  have hpy := h.pyth
  have hbc := h.b_lt_c
  have ha := h.pos_a
  have hb := h.pos_b
  refine ⟨by simp only [stepA_a, stepA_b, stepA_c]; linear_combination hpy, by simp; omega,
    by simp; omega, by simp; omega, ?_⟩
  refine cop_of_inv t.a t.b _ _ (Node.stepA t).c ?_ h.cop 1 2 (-2) (-2) (-1) 2 ?_ ?_
  · simp only [stepA_a, stepA_b, stepA_c]; linear_combination hpy
  · simp; ring
  · simp; ring

theorem IsPPT.stepB {t : Node} (h : t.IsPPT) : (Node.stepB t).IsPPT := by
  have hpy := h.pyth
  have hc := h.pos_c
  have ha := h.pos_a
  have hb := h.pos_b
  refine ⟨by simp only [stepB_a, stepB_b, stepB_c]; linear_combination hpy, by simp; omega,
    by simp; omega, by simp; omega, ?_⟩
  refine cop_of_inv t.a t.b _ _ (Node.stepB t).c ?_ h.cop 1 2 (-2) 2 1 (-2) ?_ ?_
  · simp only [stepB_a, stepB_b, stepB_c]; linear_combination hpy
  · simp; ring
  · simp; ring

theorem IsPPT.stepC {t : Node} (h : t.IsPPT) : (Node.stepC t).IsPPT := by
  have hpy := h.pyth
  have hac := h.a_lt_c
  have ha := h.pos_a
  have hb := h.pos_b
  refine ⟨by simp only [stepC_a, stepC_b, stepC_c]; linear_combination hpy, by simp; omega,
    by simp; omega, by simp; omega, ?_⟩
  refine cop_of_inv t.a t.b _ _ (Node.stepC t).c ?_ h.cop (-1) (-2) 2 2 1 (-2) ?_ ?_
  · simp only [stepC_a, stepC_b, stepC_c]; linear_combination hpy
  · simp; ring
  · simp; ring

/-- Every branch of the Berggren tree maps primitive Pythagorean triples to primitive
Pythagorean triples. -/
theorem IsPPT.branch {t : Node} (h : t.IsPPT) (i : Fin 3) : (Node.branch i t).IsPPT := by
  fin_cases i
  · exact h.stepA
  · exact h.stepB
  · exact h.stepC

theorem root_isPPT : root.IsPPT := by
  refine ⟨by norm_num [root], by norm_num [root], by norm_num [root], by norm_num [root], ?_⟩
  rw [Int.isCoprime_iff_gcd_eq_one]
  decide

/-! ### Two-sided growth of the hypotenuse -/

/-- Every Berggren branch increases the hypotenuse by at least `8`. -/
theorem hyp_add_eight_le_branch {t : Node} (h : t.IsPPT) (i : Fin 3) :
    t.c + 8 ≤ (Node.branch i t).c := by
  have h1 := h.four_le_c_add_a_sub_b
  have h2 := h.four_le_c_add_b_sub_a
  have h3 := h.pos_a
  have h4 := h.pos_b
  fin_cases i
  · show t.c + 8 ≤ (Node.stepA t).c
    simp only [stepA_c]; omega
  · show t.c + 8 ≤ (Node.stepB t).c
    simp only [stepB_c]; omega
  · show t.c + 8 ≤ (Node.stepC t).c
    simp only [stepC_c]; omega

theorem hyp_lt_branch {t : Node} (h : t.IsPPT) (i : Fin 3) : t.c < (Node.branch i t).c := by
  have := hyp_add_eight_le_branch h i; omega

/-- Every Berggren branch multiplies the hypotenuse by at most `7`. -/
theorem hyp_branch_le_seven_mul {t : Node} (h : t.IsPPT) (i : Fin 3) :
    (Node.branch i t).c ≤ 7 * t.c := by
  have h1 := h.a_lt_c
  have h2 := h.b_lt_c
  have h3 := h.pos_a
  have h4 := h.pos_b
  fin_cases i
  · show (Node.stepA t).c ≤ 7 * t.c
    simp only [stepA_c]; omega
  · show (Node.stepB t).c ≤ 7 * t.c
    simp only [stepB_c]; omega
  · show (Node.stepC t).c ≤ 7 * t.c
    simp only [stepC_c]; omega

/-! ### The slowest branch is quadratic -/

/-- Iterating the branch `A` from the root produces the quadratic family
`(2n+3, 2n²+6n+4, 2n²+6n+5)` (hypotenuses `5, 13, 25, 41, 61, 85, …`). -/
theorem iterate_stepA_root (n : ℕ) :
    Node.stepA^[n] root = ⟨2 * n + 3, 2 * n ^ 2 + 6 * n + 4, 2 * n ^ 2 + 6 * n + 5⟩ := by
  induction n with
  | zero => simp [root]
  | succ n ih =>
      rw [Function.iterate_succ_apply', ih]
      simp only [Node.stepA, Node.mk.injEq]
      push_cast
      refine ⟨by ring, by ring, by ring⟩

/-- Consequently the minimal hypotenuse at depth `n` is only quadratic in `n`: along the
slow branch, depth `O(√c)` suffices to reach hypotenuse `c`. -/
theorem hyp_iterate_stepA_root (n : ℕ) : (Node.stepA^[n] root).c = 2 * n ^ 2 + 6 * n + 5 := by
  rw [iterate_stepA_root]

end Node

end QuantumPythagoreanWalk