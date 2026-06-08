import Mathlib
import Speculative.BerggrenDynamics.Defs

/-!
# Berggren Tree: Quadratic Hypotenuse Growth

We prove that the minimum hypotenuse in the Berggren tree at depth d grows
**quadratically** — not exponentially. The all-A branch gives an exact formula
`c = 2d² + 6d + 5`, and we prove matching quadratic lower bounds, establishing
`c_min(d) = Θ(d²)`.
-/

set_option maxHeartbeats 1600000

namespace BerggrenDynamics

/-! ## All-A branch: exact formula -/

def iterateA : ℕ → ℤ × ℤ × ℤ
  | 0 => root
  | n + 1 => childA (iterateA n)

@[simp] theorem childA_coords (a b c : ℤ) :
    childA (a, b, c) = (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c) := by
  simp [childA, berggrenChild]

@[simp] theorem childB_coords (a b c : ℤ) :
    childB (a, b, c) = (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c) := by
  simp [childB, berggrenChild]

@[simp] theorem childC_coords (a b c : ℤ) :
    childC (a, b, c) = (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c) := by
  simp [childC, berggrenChild]

theorem allA_branch_formula (n : ℕ) :
    iterateA n = allA_triple n := by
  induction n with
  | zero => simp [iterateA, root, allA_triple]
  | succ n ih =>
    simp only [iterateA, ih, allA_triple, childA_coords]
    ext <;> push_cast <;> ring

theorem allA_hyp (n : ℕ) : hyp (iterateA n) = 2 * (n : ℤ) ^ 2 + 6 * n + 5 := by
  simp [allA_branch_formula, allA_triple, hyp]

theorem allA_is_pythagorean (n : ℕ) :
    (iterateA n).1 ^ 2 + (iterateA n).2.1 ^ 2 = (iterateA n).2.2 ^ 2 := by
  rw [allA_branch_formula]; simp [allA_triple]; ring

/-! ## Core per-generator bounds -/

theorem child_bounds {a b c : ℤ}
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (g : BerggrenGen) :
    min a b + 2 ≤ (berggrenChild g (a, b, c)).1 ∧
    min a b + 2 ≤ (berggrenChild g (a, b, c)).2.1 ∧
    c + 2 * min a b ≤ (berggrenChild g (a, b, c)).2.2 ∧
    0 < (berggrenChild g (a, b, c)).1 ∧
    0 < (berggrenChild g (a, b, c)).2.1 ∧
    0 < (berggrenChild g (a, b, c)).2.2 ∧
    (berggrenChild g (a, b, c)).1 ^ 2 + (berggrenChild g (a, b, c)).2.1 ^ 2 =
      (berggrenChild g (a, b, c)).2.2 ^ 2 := by
  rcases g with ⟨ _ | _ | _ | g, hg ⟩ <;> norm_num [ berggrenChild ] <;> ring_nf at * <;> norm_num at *;
  · refine' ⟨ _, _, _, _, _, _, _ ⟩ <;> try nlinarith [ sq_nonneg ( a - b ) ];
    · cases min_cases a b <;> nlinarith [ show c > b by nlinarith ];
    · cases min_cases a b <;> nlinarith [ sq_nonneg ( a - b ) ];
    · cases min_cases a b <;> nlinarith [ sq_nonneg ( a - b ) ];
  · grind;
  · refine' ⟨ _, _, _, _, _, _, _ ⟩ <;> try nlinarith [ min_le_left a b, min_le_right a b ];
    cases min_cases a b <;> nlinarith [ show c > a by nlinarith ]

/-! ## Inductive word-level bounds -/

theorem word_bounds {a b c : ℤ}
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (w : List BerggrenGen) :
    let t := w.foldl (fun t g => berggrenChild g t) (a, b, c)
    min a b + 2 * (w.length : ℤ) ≤ min t.1 t.2.1 ∧
    c + 2 * min a b * (w.length : ℤ) + 2 * (w.length : ℤ) * ((w.length : ℤ) - 1) ≤ t.2.2 ∧
    0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2 ∧
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  induction w generalizing a b c with
  | nil =>
    simp only [List.foldl_nil, List.length_nil, Nat.cast_zero, mul_zero, add_zero]
    exact ⟨le_rfl, by linarith, ha, hb, hc, hpyth⟩
  | cons g gs ih =>
    simp only [List.foldl_cons, List.length_cons]
    have hbd := child_bounds hpyth ha hb hc g
    set a' := (berggrenChild g (a, b, c)).1
    set b' := (berggrenChild g (a, b, c)).2.1
    set c' := (berggrenChild g (a, b, c)).2.2
    change
      let t := gs.foldl (fun t g => berggrenChild g t) (a', b', c')
      min a b + 2 * ↑(gs.length + 1) ≤ min t.1 t.2.1 ∧
      c + 2 * min a b * ↑(gs.length + 1) + 2 * ↑(gs.length + 1) * (↑(gs.length + 1) - 1) ≤ t.2.2 ∧
      0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2 ∧ t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2
    have ih' := ih hbd.2.2.2.2.2.2 hbd.2.2.2.1 hbd.2.2.2.2.1 hbd.2.2.2.2.2.1
    set t := gs.foldl (fun t g => berggrenChild g t) (a', b', c')
    have hmin_step : min a b + 2 ≤ min a' b' := le_min hbd.1 hbd.2.1
    -- For the min-leg bound: min a b + 2(|gs|+1) ≤ min t.1 t.2.1
    -- ih'.1: min a' b' + 2|gs| ≤ min t.1 t.2.1
    -- hmin_step: min a b + 2 ≤ min a' b'
    have hleg : min a b + 2 * ((gs.length : ℤ) + 1) ≤ min t.1 t.2.1 := by
      linarith [ih'.1]
    -- For hyp bound: c + 2m(|gs|+1) + 2(|gs|+1)|gs| ≤ t.2.2
    -- ih'.2.1: c' + 2·(min a' b')·|gs| + 2|gs|(|gs|-1) ≤ t.2.2
    -- hbd.2.2.1: c + 2m ≤ c'
    -- hmin_step: m + 2 ≤ min a' b'
    -- Need: 2·(min a' b')·|gs| ≥ 2·(m+2)·|gs|
    have hgs_nn : (0 : ℤ) ≤ gs.length := Nat.cast_nonneg _
    have hmul : 2 * (min a b + 2) * gs.length ≤ 2 * min a' b' * gs.length := by
      have := mul_le_mul_of_nonneg_right hmin_step hgs_nn
      linarith
    have hhyp : c + 2 * min a b * ((gs.length : ℤ) + 1) +
      2 * ((gs.length : ℤ) + 1) * ((gs.length : ℤ) + 1 - 1) ≤ t.2.2 := by
      push_cast at *
      nlinarith [ih'.2.1, hbd.2.2.1, hmul]
    exact ⟨hleg, hhyp, ih'.2.2.1, ih'.2.2.2.1, ih'.2.2.2.2.1, ih'.2.2.2.2.2⟩

/-- **Quadratic lower bound.** For any word of length d from root (3,4,5),
    hypotenuse ≥ 2d² + 4d + 5. -/
theorem root_word_hyp_lower (w : List BerggrenGen) :
    (2 * (w.length : ℤ) ^ 2 + 4 * w.length + 5 : ℤ) ≤ hyp (evalWord w) := by
  have h := @word_bounds 3 4 5 (by norm_num) (by norm_num) (by norm_num) (by norm_num) w
  simp only [evalWord, root, hyp] at h ⊢
  have : min (3 : ℤ) 4 = 3 := by norm_num
  nlinarith [h.2.1, this]

/-- From root (3,4,5), min leg ≥ 2d+3 at depth d. -/
theorem root_word_min_leg (w : List BerggrenGen) :
    (2 * (w.length : ℤ) + 3 : ℤ) ≤ min (evalWord w).1 (evalWord w).2.1 := by
  have h := @word_bounds 3 4 5 (by norm_num) (by norm_num) (by norm_num) (by norm_num) w
  simp only [evalWord, root] at h ⊢
  linarith [h.1, show min (3:ℤ) 4 = 3 from by norm_num]

/-
**Quadratic upper bound from all-A branch.**
-/
theorem allA_hyp_upper (d : ℕ) :
    ∃ w : List BerggrenGen, w.length = d ∧ hyp (evalWord w) ≤ 2 * (d : ℤ) ^ 2 + 6 * d + 5 := by
  -- Consider the word consisting of d copies of the generator 0 (the all-A word).
  use List.replicate d (0 : Fin 3);
  -- By induction on $d$, we can show that the evalWord of the list of zeros length $d$ is equal to iterateA $d$.
  have h_eval_eq_iterate : ∀ d : ℕ, evalWord (List.replicate d 0) = iterateA d := by
    intro x; induction x <;> simp_all +decide [ List.replicate_succ', evalWord, iterateA ] ;
    rfl;
  exact ⟨ by simp +decide, by rw [ h_eval_eq_iterate, allA_hyp ] ⟩

end BerggrenDynamics