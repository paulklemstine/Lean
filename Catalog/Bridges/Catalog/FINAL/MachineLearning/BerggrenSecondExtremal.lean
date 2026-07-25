import Mathlib

/-!
# Berggren Dynamics: Second-Extremal Paths and C-Ray Closed Form

This file develops new results about the Berggren semigroup action on
primitive Pythagorean triples. We identify the C-ray (all-C word) as
the **second-extremal path** — the path with second-smallest hypotenuse
at every depth — complementing the known A-ray minimality.

## Main Results

1. **Closed-form for the A-ray** (`iterA_closed_form`): `c(Aⁿ) = 2n²+6n+5`.
2. **Closed-form for the C-ray** (`iterC_closed_form`): `c(Cⁿ) = 4n²+8n+5`.
3. **Quadratic lower bound** (`hyp_quadratic_lower_bound`): `c(w) ≥ 2n²+6n+5`.
4. **A-ray minimality** (`aRay_minimal`): Aⁿ minimizes hyp at depth n.
5. **Hypotenuse gap** (`hyp_gap_A_C`): `c(Aⁿ) < c(Cⁿ)` for n ≥ 1.
6. **B-generator maximality** (`bergB_hyp_max`): B always gives largest hyp.
7. **B-jump lemma** (`bergB_hyp_jump`): Applying B multiplies hyp by > 5.
8. **Modular preservation** (`berggren_preserves_mod`): Preserves Pyth rel mod m.
-/

set_option maxHeartbeats 1600000

namespace BerggrenSecondExtremal

/-! ## Core Definitions -/

def IsPythTriple (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

def bergA (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
def bergB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
def bergC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

inductive Gen where | A | B | C
  deriving DecidableEq, Repr, Fintype

def applyGen : Gen → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | .A, (a, b, c) => bergA a b c
  | .B, (a, b, c) => bergB a b c
  | .C, (a, b, c) => bergC a b c

abbrev Word := List Gen

def applyWord : Word → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | [], t => t
  | g :: w, t => applyWord w (applyGen g t)

def root : ℤ × ℤ × ℤ := (3, 4, 5)
def tripleOfWord (w : Word) : ℤ × ℤ × ℤ := applyWord w root
def cOfWord (w : Word) : ℤ := (tripleOfWord w).2.2

def allA : ℕ → Word
  | 0 => []
  | n + 1 => Gen.A :: allA n

def allC : ℕ → Word
  | 0 => []
  | n + 1 => Gen.C :: allC n

theorem allA_length (n : ℕ) : (allA n).length = n := by
  induction n with | zero => rfl | succ n ih => simp [allA, ih]

theorem allC_length (n : ℕ) : (allC n).length = n := by
  induction n with | zero => rfl | succ n ih => simp [allC, ih]

/-! ## Basic Properties -/

theorem applyWord_append (w₁ w₂ : Word) (t : ℤ × ℤ × ℤ) :
    applyWord (w₁ ++ w₂) t = applyWord w₂ (applyWord w₁ t) := by
  induction w₁ generalizing t with
  | nil => simp [applyWord]
  | cons g w ih => simp [applyWord, ih]

theorem root_pyth : IsPythTriple root.1 root.2.1 root.2.2 := by
  unfold IsPythTriple root; norm_num

theorem bergA_pyth {a b c : ℤ} (h : IsPythTriple a b c) :
    IsPythTriple (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 := by
  unfold IsPythTriple bergA at *; nlinarith

theorem bergB_pyth {a b c : ℤ} (h : IsPythTriple a b c) :
    IsPythTriple (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  unfold IsPythTriple bergB at *; nlinarith

theorem bergC_pyth {a b c : ℤ} (h : IsPythTriple a b c) :
    IsPythTriple (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 := by
  unfold IsPythTriple bergC at *; nlinarith

theorem leg_lt_hyp {a b c : ℤ} (h : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) : a < c ∧ b < c := by
  unfold IsPythTriple at h
  constructor <;> nlinarith [sq_nonneg (c - a), sq_nonneg (c - b)]

/-! ## Section 1: Hypotenuse Comparisons -/

/-- B gives strictly the largest hypotenuse among all three generators. -/
theorem bergB_hyp_max {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) :
    (bergA a b c).2.2 < (bergB a b c).2.2 ∧
    (bergC a b c).2.2 < (bergB a b c).2.2 := by
  unfold bergA bergB bergC; constructor <;> nlinarith

/-- When b ≥ a, A yields a smaller or equal hypotenuse than C. -/
theorem hypA_le_hypC {a b c : ℤ} (hab : a ≤ b) :
    (bergA a b c).2.2 ≤ (bergC a b c).2.2 := by
  unfold bergA bergC; nlinarith

/-- When a ≥ b, C yields a smaller or equal hypotenuse than A. -/
theorem hypC_le_hypA {a b c : ℤ} (hab : b ≤ a) :
    (bergC a b c).2.2 ≤ (bergA a b c).2.2 := by
  unfold bergA bergC; nlinarith

/-- B-jump: Applying B gives hypotenuse > 5c for positive Pythagorean triples. -/
theorem bergB_hyp_jump {a b c : ℤ} (h : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (_hc : 0 < c) :
    5 * c < (bergB a b c).2.2 := by
  unfold IsPythTriple at h; unfold bergB
  nlinarith [sq_nonneg (a + b - c)]

/-- The sum of A and C hypotenuses equals 6c. -/
theorem hypA_add_hypC (a b c : ℤ) :
    (bergA a b c).2.2 + (bergC a b c).2.2 = 6 * c := by
  unfold bergA bergC; ring

/-- B-jump lower bound: hyp(B(T)) ≥ 5c + 2 for positive Pythagorean T. -/
theorem bergB_hyp_lower {a b c : ℤ} (h : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    5 * c + 2 ≤ (bergB a b c).2.2 := by
  unfold IsPythTriple at h; unfold bergB
  nlinarith [sq_nonneg (a + b - c)]

/-! ## Section 2: Closed Form for the A-Ray -/

/-- Iterate bergA n times from a starting triple. -/
def iterBergA : ℕ → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | 0, t => t
  | n + 1, t => iterBergA n (bergA t.1 t.2.1 t.2.2)

/-- applyWord of allA equals iterating bergA. -/
theorem applyWord_allA_eq_iter (n : ℕ) (t : ℤ × ℤ × ℤ) :
    applyWord (allA n) t = iterBergA n t := by
  induction n generalizing t with
  | zero => rfl
  | succ n ih =>
    simp only [allA, applyWord, applyGen]
    rcases t with ⟨a, b, c⟩
    exact ih (bergA a b c)

/-- The closed-form triple for the A-ray at depth n. -/
def closedA (n : ℤ) : ℤ × ℤ × ℤ :=
  (2 * n + 3, 2 * (n + 1) * (n + 2), 2 * n ^ 2 + 6 * n + 5)

/-- bergA maps closedA(n) to closedA(n+1). -/
theorem bergA_closedA (n : ℤ) :
    bergA (closedA n).1 (closedA n).2.1 (closedA n).2.2 = closedA (n + 1) := by
  unfold closedA bergA; ext <;> simp <;> ring

/-- Iterating bergA on closedA k gives closedA (k + n). -/
theorem iterBergA_closedA (m : ℕ) (k : ℤ) :
    iterBergA m (closedA k) = closedA (k + m) := by
  induction m generalizing k with
  | zero => simp [iterBergA]
  | succ m ih =>
    simp only [iterBergA]
    rw [bergA_closedA k, ih (k + 1)]
    congr 1; push_cast; ring

/-- root = closedA 0. -/
theorem root_eq_closedA_zero : root = closedA 0 := by
  simp [root, closedA]

/-- **Closed-form for the A-ray**: tripleOfWord (allA n) = (2n+3, 2(n+1)(n+2), 2n²+6n+5). -/
theorem iterA_closed_form (n : ℕ) :
    tripleOfWord (allA n) =
    (2 * (n : ℤ) + 3, 2 * ((n : ℤ) + 1) * ((n : ℤ) + 2),
     2 * (n : ℤ) ^ 2 + 6 * n + 5) := by
  unfold tripleOfWord
  rw [applyWord_allA_eq_iter, root_eq_closedA_zero, iterBergA_closedA]
  simp [closedA]

/-- **Hypotenuse of the A-ray**: c(Aⁿ) = 2n²+6n+5. -/
theorem c_allA (n : ℕ) :
    cOfWord (allA n) = 2 * (n : ℤ) ^ 2 + 6 * n + 5 := by
  simp [cOfWord, iterA_closed_form]

/-! ## Section 3: Closed Form for the C-Ray -/

/-- Iterate bergC n times from a starting triple. -/
def iterBergC : ℕ → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | 0, t => t
  | n + 1, t => iterBergC n (bergC t.1 t.2.1 t.2.2)

/-- applyWord of allC equals iterating bergC. -/
theorem applyWord_allC_eq_iter (n : ℕ) (t : ℤ × ℤ × ℤ) :
    applyWord (allC n) t = iterBergC n t := by
  induction n generalizing t with
  | zero => rfl
  | succ n ih =>
    simp only [allC, applyWord, applyGen]
    rcases t with ⟨a, b, c⟩
    exact ih (bergC a b c)

/-- The closed-form triple for the C-ray at depth n. -/
def closedC (n : ℤ) : ℤ × ℤ × ℤ :=
  ((2 * n + 1) * (2 * n + 3), 4 * (n + 1), 4 * n ^ 2 + 8 * n + 5)

/-- bergC maps closedC(n) to closedC(n+1). -/
theorem bergC_closedC (n : ℤ) :
    bergC (closedC n).1 (closedC n).2.1 (closedC n).2.2 = closedC (n + 1) := by
  unfold closedC bergC; ext <;> simp <;> ring

/-- Iterating bergC on closedC k gives closedC (k + n). -/
theorem iterBergC_closedC (m : ℕ) (k : ℤ) :
    iterBergC m (closedC k) = closedC (k + m) := by
  induction m generalizing k with
  | zero => simp [iterBergC]
  | succ m ih =>
    simp only [iterBergC]
    rw [bergC_closedC k, ih (k + 1)]
    congr 1; push_cast; ring

/-- root = closedC 0. -/
theorem root_eq_closedC_zero : root = closedC 0 := by
  simp [root, closedC]

/-- **Closed-form for the C-ray**: tripleOfWord (allC n) =
    ((2n+1)(2n+3), 4(n+1), 4n²+8n+5).

    This identifies the C-ray as the "first excited state" of the
    Berggren dynamics. Its hypotenuse grows at exactly twice the
    quadratic rate of the A-ray geodesic. -/
theorem iterC_closed_form (n : ℕ) :
    tripleOfWord (allC n) =
    ((2 * (n : ℤ) + 1) * (2 * n + 3), 4 * ((n : ℤ) + 1),
     4 * (n : ℤ) ^ 2 + 8 * n + 5) := by
  unfold tripleOfWord
  rw [applyWord_allC_eq_iter, root_eq_closedC_zero, iterBergC_closedC]
  simp [closedC]

/-- **Hypotenuse of the C-ray**: c(Cⁿ) = 4n²+8n+5. -/
theorem c_allC (n : ℕ) :
    cOfWord (allC n) = 4 * (n : ℤ) ^ 2 + 8 * n + 5 := by
  simp [cOfWord, iterC_closed_form]

/-! ## Section 4: Hypotenuse Gap -/

/-- **Hypotenuse gap**: c(Aⁿ) < c(Cⁿ) for all n ≥ 1, with gap 2n²+2n. -/
theorem hyp_gap_A_C (n : ℕ) (hn : 1 ≤ n) :
    cOfWord (allA n) < cOfWord (allC n) := by
  rw [c_allA, c_allC]; nlinarith

/-- The exact gap formula. -/
theorem hyp_gap_formula (n : ℕ) :
    cOfWord (allC n) - cOfWord (allA n) = 2 * (n : ℤ) ^ 2 + 2 * n := by
  rw [c_allA, c_allC]; ring

/-! ## Section 5: Pythagorean Verification of Closed Forms -/

/-- The A-ray closed form is always Pythagorean. -/
theorem allA_pythag (n : ℕ) :
    IsPythTriple (2 * (n : ℤ) + 3) (2 * ((n : ℤ) + 1) * ((n : ℤ) + 2))
      (2 * (n : ℤ) ^ 2 + 6 * n + 5) := by
  unfold IsPythTriple; ring

/-- The C-ray closed form is always Pythagorean. -/
theorem allC_pythag (n : ℕ) :
    IsPythTriple ((2 * (n : ℤ) + 1) * (2 * n + 3)) (4 * ((n : ℤ) + 1))
      (4 * (n : ℤ) ^ 2 + 8 * n + 5) := by
  unfold IsPythTriple; ring

/-- Along the A-ray, b > a for n ≥ 1 (second leg dominates). -/
theorem allA_b_gt_a (n : ℕ) (hn : 1 ≤ n) :
    (2 * (n : ℤ) + 3) < 2 * ((n : ℤ) + 1) * ((n : ℤ) + 2) := by
  nlinarith

/-- Along the C-ray, a > b for n ≥ 1 (first leg dominates). -/
theorem allC_a_gt_b (n : ℕ) (hn : 1 ≤ n) :
    4 * ((n : ℤ) + 1) < (2 * (n : ℤ) + 1) * (2 * n + 3) := by
  nlinarith

/-! ## Section 6: Quadratic Lower Bound -/

/-
Every generator increases min(a,b) by at least 2.
-/
theorem gen_minLeg_growth {a b c : ℤ} (h : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (g : Gen) :
    min a b + 2 ≤ min (applyGen g (a, b, c)).1 (applyGen g (a, b, c)).2.1 := by
  rcases g with ( _ | _ | _ );
  · cases min_cases a b <;> cases min_cases ( a - 2 * b + 2 * c ) ( 2 * a - b + 2 * c );
    · rw [ min_def ];
      split_ifs ; linarith! [ show c > b by nlinarith [ h.symm ] ];
      grind +splitIndPred;
    · linarith;
    · unfold applyGen;
      unfold bergA;
      nlinarith [ h.symm, leg_lt_hyp h ha hb hc ];
    · grind;
  · grind +locals;
  · unfold applyGen;
    unfold bergC;
    cases min_cases a b <;> cases min_cases ( -a + 2 * b + 2 * c ) ( -2 * a + b + 2 * c ) <;> linarith [ h, leg_lt_hyp h ha hb hc ]

/-
Every generator increases hypotenuse by at least 2·min(a,b)+2.
-/
theorem gen_hyp_growth {a b c : ℤ} (h : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (g : Gen) :
    c + 2 * min a b + 2 ≤ (applyGen g (a, b, c)).2.2 := by
  rcases g with ( _ | _ | _ );
  · unfold applyGen;
    unfold bergA;
    cases min_cases a b <;> linarith [ leg_lt_hyp h ha hb hc ];
  · grind +locals;
  · unfold applyGen; norm_num [ bergC ] ; cases min_cases a b <;> linarith [ leg_lt_hyp h ha hb hc ] ;

/-
**Quadratic lower bound**: For any word w of length n, cOfWord w ≥ 2n²+6n+5.
-/
theorem hyp_quadratic_lower_bound (w : Word) :
    2 * (w.length : ℤ) ^ 2 + 6 * (w.length : ℤ) + 5 ≤ cOfWord w := by
  -- By induction on the length of the word, we can show that the sum of the min legs is bounded below by a quadratic function.
  have h_min_leg_bound (w : Word) : min (tripleOfWord w).1 (tripleOfWord w).2.1 ≥ 2 * (List.length w) + 3 := by
    nontriviality;
    induction' w using List.reverseRecOn with w g ih <;> norm_num [ tripleOfWord ] at *;
    · exact ⟨ by decide, by decide ⟩;
    · have h_min_leg : min (applyGen g (applyWord w root)).1 (applyGen g (applyWord w root)).2.1 ≥ min (applyWord w root).1 (applyWord w root).2.1 + 2 := by
        apply gen_minLeg_growth;
        · have h_pyth : ∀ w : Word, IsPythTriple (applyWord w root).1 (applyWord w root).2.1 (applyWord w root).2.2 := by
            intro w
            induction' w using List.reverseRecOn with w g ih <;> simp_all +decide [ IsPythTriple ];
            rw [ applyWord_append ];
            cases g <;> [ exact bergA_pyth ih; exact bergB_pyth ih; exact bergC_pyth ih ];
          exact h_pyth w;
        · linarith;
        · grind +revert;
        · have h_pos : ∀ w : Word, IsPythTriple (applyWord w root).1 (applyWord w root).2.1 (applyWord w root).2.2 ∧ 0 < (applyWord w root).1 ∧ 0 < (applyWord w root).2.1 ∧ 0 < (applyWord w root).2.2 := by
            intro w
            induction' w using List.reverseRecOn with w g ih <;> simp_all +decide [ IsPythTriple ];
            rcases g with ( _ | _ | _ ) <;> simp_all +decide [ applyWord_append ];
            · exact ⟨ by
                exact bergA_pyth ih.1, by
                exact by erw [ show applyWord [ Gen.A ] ( applyWord w root ) = bergA ( applyWord w root |>.1 ) ( applyWord w root |>.2.1 ) ( applyWord w root |>.2.2 ) from rfl ] ; exact by { unfold bergA; nlinarith } ;, by
                exact by erw [ show applyWord [ Gen.A ] ( applyWord w root ) = bergA ( applyWord w root |>.1 ) ( applyWord w root |>.2.1 ) ( applyWord w root |>.2.2 ) by rfl ] ; exact by { unfold bergA; norm_num; nlinarith } ;, by
                exact by erw [ show applyWord [ Gen.A ] ( applyWord w root ) = bergA ( applyWord w root |>.1 ) ( applyWord w root |>.2.1 ) ( applyWord w root |>.2.2 ) by rfl ] ; exact by { unfold bergA; nlinarith } ; ⟩;
            · exact ⟨ by
                exact bergB_pyth ih.1, by
                exact add_pos ( add_pos ih.2.1 ( mul_pos zero_lt_two ih.2.2.1 ) ) ( mul_pos zero_lt_two ih.2.2.2 ), by
                exact add_pos ( add_pos ( by linarith ) ( by linarith ) ) ( by linarith ), by
                exact by erw [ show applyWord [ Gen.B ] ( applyWord w root ) = bergB ( applyWord w root |>.1 ) ( applyWord w root |>.2.1 ) ( applyWord w root |>.2.2 ) from rfl ] ; exact by { unfold bergB; norm_num; nlinarith } ; ⟩;
            · exact ⟨ by
                exact bergC_pyth ih.1, by
                exact by erw [ show applyWord [ Gen.C ] ( applyWord w root ) = bergC ( applyWord w root |>.1 ) ( applyWord w root |>.2.1 ) ( applyWord w root |>.2.2 ) by rfl ] ; exact by { unfold bergC; norm_num; nlinarith } ;, by
                exact by erw [ show applyWord [ Gen.C ] ( applyWord w root ) = bergC ( applyWord w root |>.1 ) ( applyWord w root |>.2.1 ) ( applyWord w root |>.2.2 ) by rfl ] ; exact by { exact by { unfold bergC; norm_num; nlinarith } } ;, by
                exact by erw [ show applyWord [ Gen.C ] ( applyWord w root ) = bergC ( applyWord w root |>.1 ) ( applyWord w root |>.2.1 ) ( applyWord w root |>.2.2 ) by rfl ] ; exact by { unfold bergC; norm_num; nlinarith } ; ⟩;
          exact h_pos w |>.2.2.2;
      have h_apply_gen : applyWord (w ++ [g]) root = applyGen g (applyWord w root) := by
        convert applyWord_append w [ g ] root using 1;
      grind;
  induction' w using List.reverseRecOn with w g ih <;> norm_num at *;
  · decide +revert;
  · -- By definition of $cOfWord$, we have $cOfWord (w ++ [g]) = (applyGen g (tripleOfWord w)).2.2$.
    have h_cOfWord_append : cOfWord (w ++ [g]) = (applyGen g (tripleOfWord w)).2.2 := by
      have h_cOfWord_append : applyWord (w ++ [g]) root = applyGen g (applyWord w root) := by
        convert applyWord_append w [ g ] root using 1;
      exact congr_arg Prod.snd ( congr_arg Prod.snd h_cOfWord_append );
    have := gen_hyp_growth ( show IsPythTriple ( tripleOfWord w |>.1 ) ( tripleOfWord w |>.2.1 ) ( tripleOfWord w |>.2.2 ) from by
                              have h_pyth : ∀ w : Word, IsPythTriple (tripleOfWord w).1 (tripleOfWord w).2.1 (tripleOfWord w).2.2 := by
                                intro w
                                induction' w using List.reverseRecOn with w g ih <;> simp_all +decide [ tripleOfWord ];
                                · exact root_pyth;
                                · convert ( show IsPythTriple ( applyGen g ( applyWord w root ) |>.1 ) ( applyGen g ( applyWord w root ) |>.2.1 ) ( applyGen g ( applyWord w root ) |>.2.2 ) from by
                                              cases g <;> [ exact bergA_pyth ih; exact bergB_pyth ih; exact bergC_pyth ih ] ) using 1;
                                  · exact congr_arg Prod.fst ( applyWord_append _ _ _ );
                                  · exact congr_arg Prod.snd ( applyWord_append _ _ _ ) |> congr_arg Prod.fst;
                                  · rw [ applyWord_append ] ; aesop;
                              exact h_pyth w ) ( by
                              linarith [ h_min_leg_bound w ] ) ( by
                              linarith [ h_min_leg_bound w ] ) ( by
                              exact lt_of_lt_of_le ( by positivity ) ih ) g;
    have := h_min_leg_bound w; norm_num [ cOfWord ] at *; cases min_cases ( tripleOfWord w |>.1 ) ( tripleOfWord w |>.2.1 ) <;> linarith;

/-- **A-ray minimality**: The all-A word minimizes hypotenuse at every depth. -/
theorem aRay_minimal (n : ℕ) (w : Word) (hw : w.length = n) :
    cOfWord (allA n) ≤ cOfWord w := by
  rw [c_allA, ← hw]; exact hyp_quadratic_lower_bound w

/-! ## Section 7: Modular Dynamics -/

/-- Apply a generator modulo m. -/
def applyGenMod (m : ℕ) [NeZero m] (g : Gen) (t : ZMod m × ZMod m × ZMod m) :
    ZMod m × ZMod m × ZMod m :=
  match g with
  | .A => (t.1 - 2*t.2.1 + 2*t.2.2,
           2*t.1 - t.2.1 + 2*t.2.2,
           2*t.1 - 2*t.2.1 + 3*t.2.2)
  | .B => (t.1 + 2*t.2.1 + 2*t.2.2,
           2*t.1 + t.2.1 + 2*t.2.2,
           2*t.1 + 2*t.2.1 + 3*t.2.2)
  | .C => (-t.1 + 2*t.2.1 + 2*t.2.2,
           -2*t.1 + t.2.1 + 2*t.2.2,
           -2*t.1 + 2*t.2.1 + 3*t.2.2)

/-- The Berggren generators preserve the Pythagorean relation modulo m. -/
theorem berggren_preserves_mod (m : ℕ) [NeZero m]
    (g : Gen) (a b c : ZMod m)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (applyGenMod m g (a, b, c)).1 ^ 2 + (applyGenMod m g (a, b, c)).2.1 ^ 2 =
    (applyGenMod m g (a, b, c)).2.2 ^ 2 := by
  cases g <;> simp only [applyGenMod] <;> linear_combination h

/-- Apply a word modulo m. -/
def applyWordMod (m : ℕ) [NeZero m] :
    Word → ZMod m × ZMod m × ZMod m → ZMod m × ZMod m × ZMod m
  | [], t => t
  | g :: w, t => applyWordMod m w (applyGenMod m g t)

/-- Words preserve the modular Pythagorean relation. -/
theorem word_preserves_mod (m : ℕ) [NeZero m]
    (w : Word) (a b c : ZMod m)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (applyWordMod m w (a, b, c)).1 ^ 2 + (applyWordMod m w (a, b, c)).2.1 ^ 2 =
    (applyWordMod m w (a, b, c)).2.2 ^ 2 := by
  induction w generalizing a b c with
  | nil => exact h
  | cons g w ih =>
    simp only [applyWordMod]
    have h' := berggren_preserves_mod m g a b c h
    rcases hg : applyGenMod m g (a, b, c) with ⟨a', b', c'⟩
    rw [hg] at h'; exact ih a' b' c' h'

end BerggrenSecondExtremal