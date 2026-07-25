import Mathlib

/-!
# Berggren Dynamics: Arithmetic of Orbit Growth

This file develops the first genuinely dynamical arithmetic theory of the Berggren
semigroup action on primitive Pythagorean triples. The main results are:

1. **Closed-form formula** for the all-A branch: the triple at depth n is
   `(2n+3, 2n²+6n+4, 2n²+6n+5)`, giving hypotenuse `c(A^n) = 2n² + 6n + 5`.
2. **Sharp quadratic lower bound**: for any Berggren word `w` of length `n`,
   `cOfWord w ≥ 2n² + 6n + 5`.
3. **Exact depth-optimal minimality**: `A^n` yields the smallest hypotenuse at depth `n`.
4. **Modular preservation**: the Berggren action preserves the Pythagorean relation mod `m`.

## Mathematical Overview

The key insight for the lower bound is a two-component induction:
- Each Berggren generator increases `min(a, b)` by at least 2.
- The hypotenuse grows by at least `2 · min(a, b) + 2` under any generator.

Together, these give `c_n ≥ 5 + Σ_{k=0}^{n-1}(4k + 8) = 2n² + 6n + 5`,
which is exactly the hypotenuse of the all-A branch, proving A^n is optimal.
-/

set_option maxHeartbeats 800000

namespace BerggrenDynamics

/-! ## Core Definitions -/

/-- A Pythagorean triple satisfies a² + b² = c². -/
def IsPythTriple (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Berggren generator A. -/
def bergA (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren generator B. -/
def bergB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren generator C. -/
def bergC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The Berggren alphabet. -/
inductive Gen where | A | B | C
  deriving DecidableEq, Repr

/-- Apply a single generator to a triple. -/
def applyGen : Gen → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | .A, (a, b, c) => bergA a b c
  | .B, (a, b, c) => bergB a b c
  | .C, (a, b, c) => bergC a b c

/-- A Berggren word is a list of generators. -/
abbrev Word := List Gen

/-- Apply a word to a triple (first letter acts first, left-to-right). -/
def applyWord : Word → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | [], t => t
  | g :: w, t => applyWord w (applyGen g t)

/-- The root triple (3, 4, 5). -/
def root : ℤ × ℤ × ℤ := (3, 4, 5)

/-- The triple obtained by applying word `w` to the root. -/
def tripleOfWord (w : Word) : ℤ × ℤ × ℤ := applyWord w root

/-- The hypotenuse of the triple obtained from word `w`. -/
def cOfWord (w : Word) : ℤ := (tripleOfWord w).2.2

/-- The all-A word of length `n`. -/
def allA : ℕ → Word
  | 0 => []
  | n + 1 => Gen.A :: allA n

theorem applyWord_append (w₁ w₂ : Word) (t : ℤ × ℤ × ℤ) :
    applyWord (w₁ ++ w₂) t = applyWord w₂ (applyWord w₁ t) := by
  induction w₁ generalizing t with
  | nil => simp [applyWord]
  | cons g w ih => simp [applyWord, ih]

theorem applyWord_singleton (g : Gen) (t : ℤ × ℤ × ℤ) :
    applyWord [g] t = applyGen g t := by
  simp [applyWord]

/-! ## Basic Properties -/

theorem allA_length (n : ℕ) : (allA n).length = n := by
  induction n with
  | zero => rfl
  | succ n ih => simp [allA, ih]

theorem root_pyth : IsPythTriple root.1 root.2.1 root.2.2 := by
  unfold IsPythTriple root; norm_num

/-- For positive Pythagorean triples, each leg is strictly less than the hypotenuse. -/
theorem leg_lt_hyp {a b c : ℤ} (h : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) : a < c ∧ b < c := by
  unfold IsPythTriple at h
  constructor <;> nlinarith [sq_nonneg (c - a), sq_nonneg (c - b)]

/-! ## Pythagorean and Positivity Preservation -/

theorem bergA_pyth {a b c : ℤ} (h : IsPythTriple a b c) :
    IsPythTriple (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 := by
  unfold IsPythTriple bergA at *; nlinarith

theorem bergB_pyth {a b c : ℤ} (h : IsPythTriple a b c) :
    IsPythTriple (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  unfold IsPythTriple bergB at *; nlinarith

theorem bergC_pyth {a b c : ℤ} (h : IsPythTriple a b c) :
    IsPythTriple (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 := by
  unfold IsPythTriple bergC at *; nlinarith

theorem bergA_pos {a b c : ℤ} (h : IsPythTriple a b c) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < (bergA a b c).1 ∧ 0 < (bergA a b c).2.1 ∧ 0 < (bergA a b c).2.2 := by
  obtain ⟨hac, hbc⟩ := leg_lt_hyp h ha hb hc
  unfold bergA; refine ⟨?_, ?_, ?_⟩ <;> nlinarith

theorem bergB_pos {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < (bergB a b c).1 ∧ 0 < (bergB a b c).2.1 ∧ 0 < (bergB a b c).2.2 := by
  unfold bergB; refine ⟨?_, ?_, ?_⟩ <;> nlinarith

theorem bergC_pos {a b c : ℤ} (h : IsPythTriple a b c) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < (bergC a b c).1 ∧ 0 < (bergC a b c).2.1 ∧ 0 < (bergC a b c).2.2 := by
  obtain ⟨hac, hbc⟩ := leg_lt_hyp h ha hb hc
  unfold bergC; refine ⟨?_, ?_, ?_⟩ <;> nlinarith

theorem applyGen_pyth {t : ℤ × ℤ × ℤ}
    (h : IsPythTriple t.1 t.2.1 t.2.2) (g : Gen) :
    IsPythTriple (applyGen g t).1 (applyGen g t).2.1 (applyGen g t).2.2 := by
  rcases t with ⟨a, b, c⟩
  cases g
  · exact bergA_pyth h
  · exact bergB_pyth h
  · exact bergC_pyth h

theorem applyGen_pos {t : ℤ × ℤ × ℤ}
    (h : IsPythTriple t.1 t.2.1 t.2.2) (ha : 0 < t.1) (hb : 0 < t.2.1)
    (hc : 0 < t.2.2) (g : Gen) :
    0 < (applyGen g t).1 ∧ 0 < (applyGen g t).2.1 ∧ 0 < (applyGen g t).2.2 := by
  rcases t with ⟨a, b, c⟩
  cases g
  · exact bergA_pos h ha hb hc
  · exact bergB_pos ha hb hc
  · exact bergC_pos h ha hb hc

/-! ## Section: Closed Form for the All-A Branch -/

/-- Iterate bergA starting from a triple. -/
def iterBergA : ℕ → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | 0, t => t
  | n + 1, t => iterBergA n (bergA t.1 t.2.1 t.2.2)

/-- applyWord of allA is the same as iterating bergA. -/
theorem applyWord_allA (n : ℕ) (t : ℤ × ℤ × ℤ) :
    applyWord (allA n) t = iterBergA n t := by
  induction n generalizing t with
  | zero => rfl
  | succ n ih =>
    simp only [allA, applyWord]
    rw [ih]
    rcases t with ⟨a, b, c⟩
    rfl

/-- The exact triple for the all-A branch at depth n. -/
def allATriple (n : ℕ) : ℤ × ℤ × ℤ :=
  (2 * n + 3, 2 * (n : ℤ) ^ 2 + 6 * n + 4, 2 * (n : ℤ) ^ 2 + 6 * n + 5)

/-- bergA maps allATriple n to allATriple (n+1). -/
theorem bergA_allATriple (n : ℕ) :
    bergA (allATriple n).1 (allATriple n).2.1 (allATriple n).2.2 = allATriple (n + 1) := by
  simp only [allATriple, bergA]
  ext <;> simp <;> push_cast <;> ring

/-- Generalized: iterBergA n applied to allATriple k gives allATriple (k + n). -/
theorem iterBergA_allATriple (n k : ℕ) :
    iterBergA n (allATriple k) = allATriple (k + n) := by
  induction n generalizing k with
  | zero => simp [iterBergA, Nat.add_zero]
  | succ n ih =>
    simp only [iterBergA]
    rw [bergA_allATriple k]
    rw [ih (k + 1)]
    congr 1; omega

/-- **Closed-form for the all-A branch**: The triple at depth n is
    `(2n + 3, 2n² + 6n + 4, 2n² + 6n + 5)`. -/
theorem tripleOfAllA_eq (n : ℕ) :
    applyWord (allA n) root = allATriple n := by
  rw [applyWord_allA]
  have h0 : root = allATriple 0 := by simp [root, allATriple]
  rw [h0, iterBergA_allATriple n 0]
  simp

/-- **Exact closed form for the all-A hypotenuse**:
    `c(A^n) = 2n² + 6n + 5`. -/
theorem c_allA_closed_form (n : ℕ) :
    cOfWord (allA n) = 2 * (n : ℤ) ^ 2 + 6 * (n : ℤ) + 5 := by
  simp [cOfWord, tripleOfWord, tripleOfAllA_eq, allATriple]

/-! ## Section: Key Lemmas for the Lower Bound -/

/-
For positive Pythagorean (a,b,c), generator A gives min leg ≥ min(a,b) + 2.
-/
theorem bergA_minLeg {a b c : ℤ} (hpyth : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    min a b + 2 ≤ min (bergA a b c).1 (bergA a b c).2.1 := by
  unfold bergA;
  cases min_cases a b <;> cases min_cases ( a - 2 * b + 2 * c ) ( 2 * a - b + 2 * c ) <;> linarith [ hpyth.symm, leg_lt_hyp hpyth ha hb hc ]

/-
Generator B gives min leg ≥ min(a,b) + 2.
-/
theorem bergB_minLeg {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    min a b + 2 ≤ min (bergB a b c).1 (bergB a b c).2.1 := by
  unfold bergB; cases min_cases a b <;> cases min_cases ( a + 2 * b + 2 * c ) ( 2 * a + b + 2 * c ) <;> linarith;

/-
Generator C gives min leg ≥ min(a,b) + 2.
-/
theorem bergC_minLeg {a b c : ℤ} (hpyth : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    min a b + 2 ≤ min (bergC a b c).1 (bergC a b c).2.1 := by
  unfold bergC;
  cases min_cases a b <;> cases min_cases ( -a + 2 * b + 2 * c ) ( -2 * a + b + 2 * c ) <;> linarith [ leg_lt_hyp hpyth ha hb hc ]

/-
Every generator increases the hypotenuse by at least `2 · min(a,b) + 2`.
-/
theorem bergA_hyp_growth_lower {a b c : ℤ} (hpyth : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c + 2 * min a b + 2 ≤ (bergA a b c).2.2 := by
  unfold bergA;
  cases min_cases a b <;> nlinarith [ leg_lt_hyp hpyth ha hb hc ]

theorem bergB_hyp_growth_lower {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c + 2 * min a b + 2 ≤ (bergB a b c).2.2 := by
  grind +locals

theorem bergC_hyp_growth_lower {a b c : ℤ} (hpyth : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c + 2 * min a b + 2 ≤ (bergC a b c).2.2 := by
  unfold bergC;
  cases min_cases a b <;> nlinarith [ leg_lt_hyp hpyth ha hb hc ]

/-- applyWord preserves the Pythagorean and positivity properties. -/
theorem applyWord_pyth_pos (w : Word) {t : ℤ × ℤ × ℤ}
    (h : IsPythTriple t.1 t.2.1 t.2.2) (ha : 0 < t.1) (hb : 0 < t.2.1) (hc : 0 < t.2.2) :
    IsPythTriple (applyWord w t).1 (applyWord w t).2.1 (applyWord w t).2.2 ∧
    0 < (applyWord w t).1 ∧ 0 < (applyWord w t).2.1 ∧
    0 < (applyWord w t).2.2 := by
  induction w generalizing t with
  | nil => exact ⟨h, ha, hb, hc⟩
  | cons g w ih =>
    simp only [applyWord]
    exact ih (applyGen_pyth h g) (applyGen_pos h ha hb hc g).1
      (applyGen_pos h ha hb hc g).2.1 (applyGen_pos h ha hb hc g).2.2

/-- Combined induction using reverse induction on words. -/
theorem word_bounds (w : Word) :
    (2 : ℤ) * w.length + 3 ≤ min (applyWord w root).1 (applyWord w root).2.1 ∧
    2 * (w.length : ℤ) ^ 2 + 6 * w.length + 5 ≤ (applyWord w root).2.2 := by
  induction w using List.reverseRecOn with
  | nil =>
    simp [applyWord, root]
  | append_singleton w g ih =>
    rw [applyWord_append, applyWord_singleton]
    have hw_pp := applyWord_pyth_pos w root_pyth (by show (0 : ℤ) < 3; omega)
      (by show (0 : ℤ) < 4; omega) (by show (0 : ℤ) < 5; omega)
    obtain ⟨hpyth, hpa, hpb, hpc⟩ := hw_pp
    have ih_min := ih.1
    have ih_hyp := ih.2
    have hlen : (w ++ [g]).length = w.length + 1 := by simp
    rw [hlen]
    set s := applyWord w root
    constructor
    · -- min leg grows by at least 2
      have h1 : min s.1 s.2.1 + 2 ≤ min (applyGen g s).1 (applyGen g s).2.1 := by
        rcases s with ⟨a, b, c⟩
        cases g
        · exact bergA_minLeg hpyth hpa hpb hpc
        · exact bergB_minLeg hpa hpb hpc
        · exact bergC_minLeg hpyth hpa hpb hpc
      calc (2 : ℤ) * ↑(w.length + 1) + 3
          = (2 * ↑w.length + 3) + 2 := by push_cast; ring
        _ ≤ min s.1 s.2.1 + 2 := by omega
        _ ≤ min (applyGen g s).1 (applyGen g s).2.1 := h1
    · -- hypotenuse grows by at least 2·min + 2
      have h2 : s.2.2 + 2 * min s.1 s.2.1 + 2 ≤ (applyGen g s).2.2 := by
        rcases s with ⟨a, b, c⟩
        cases g
        · exact bergA_hyp_growth_lower hpyth hpa hpb hpc
        · exact bergB_hyp_growth_lower hpa hpb hpc
        · exact bergC_hyp_growth_lower hpyth hpa hpb hpc
      calc 2 * ↑(w.length + 1 : ℕ) ^ 2 + 6 * ↑(w.length + 1 : ℕ) + 5
          = (2 * (w.length : ℤ) ^ 2 + 6 * w.length + 5) +
            (4 * w.length + 8) := by push_cast; ring
        _ ≤ s.2.2 + (2 * (2 * (w.length : ℤ) + 3) + 2) := by omega
        _ ≤ s.2.2 + (2 * min s.1 s.2.1 + 2) := by omega
        _ = s.2.2 + 2 * min s.1 s.2.1 + 2 := by ring
        _ ≤ (applyGen g s).2.2 := h2

/-- **Sharp quadratic lower bound**: For any word `w` of length `n`,
    the hypotenuse satisfies `cOfWord w ≥ 2n² + 6n + 5`. -/
theorem c_quadratic_lower_bound (w : Word) :
    2 * (w.length : ℤ) ^ 2 + 6 * (w.length : ℤ) + 5 ≤ cOfWord w := by
  exact (word_bounds w).2

/-- **Depth-optimal minimality**: The all-A word minimizes the hypotenuse at every depth. -/
theorem c_minimal_at_depth (n : ℕ) (w : Word) (hw : w.length = n) :
    cOfWord (allA n) ≤ cOfWord w := by
  rw [c_allA_closed_form, ← hw]
  exact c_quadratic_lower_bound w

/-! ## Section: Modular Preservation -/

/-- Apply a generator to a triple in `(ℤ/mℤ)³`. -/
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

/-- Apply a word in `(ℤ/mℤ)³`. -/
def applyWordMod (m : ℕ) [NeZero m] : Word → ZMod m × ZMod m × ZMod m → ZMod m × ZMod m × ZMod m
  | [], t => t
  | g :: w, t => applyWordMod m w (applyGenMod m g t)

/-- The root triple modulo `m`. -/
def rootMod (m : ℕ) [NeZero m] : ZMod m × ZMod m × ZMod m := (3, 4, 5)

/-
Each Berggren generator preserves the Pythagorean relation modulo `m`.
-/
theorem berggren_preserves_pythagorean_mod (m : ℕ) [NeZero m]
    (g : Gen) (t : ZMod m × ZMod m × ZMod m)
    (h : t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2) :
    (applyGenMod m g t).1 ^ 2 + (applyGenMod m g t).2.1 ^ 2 =
    (applyGenMod m g t).2.2 ^ 2 := by
  rcases g with ( _ | _ | _ );
  · unfold applyGenMod; ring;
    linear_combination' h;
  · unfold applyGenMod;
    grind;
  · unfold applyGenMod;
    grind

/-- Words preserve the Pythagorean relation modulo `m`. -/
theorem berggren_word_preserves_pythagorean_mod (m : ℕ) [NeZero m]
    (w : Word) (t : ZMod m × ZMod m × ZMod m)
    (h : t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2) :
    (applyWordMod m w t).1 ^ 2 + (applyWordMod m w t).2.1 ^ 2 =
    (applyWordMod m w t).2.2 ^ 2 := by
  induction w generalizing t with
  | nil => exact h
  | cons g w ih =>
    simp only [applyWordMod]
    exact ih (applyGenMod m g t) (berggren_preserves_pythagorean_mod m g t h)

/-- The root satisfies the Pythagorean relation mod m. -/
theorem root_pythagorean_mod (m : ℕ) [NeZero m] :
    (rootMod m).1 ^ 2 + (rootMod m).2.1 ^ 2 = (rootMod m).2.2 ^ 2 := by
  simp [rootMod]; ring

/-- Every reachable triple from the root satisfies the modular Pythagorean relation. -/
theorem reachable_pythagorean_mod (m : ℕ) [NeZero m] (w : Word) :
    (applyWordMod m w (rootMod m)).1 ^ 2 + (applyWordMod m w (rootMod m)).2.1 ^ 2 =
    (applyWordMod m w (rootMod m)).2.2 ^ 2 :=
  berggren_word_preserves_pythagorean_mod m w (rootMod m) (root_pythagorean_mod m)

end BerggrenDynamics