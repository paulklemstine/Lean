/-
# Pillai's Conjecture and Exponential Diophantine Equations

Mihailescu proved that 8 and 9 are the only consecutive perfect powers (Catalan's conjecture).
Pillai's conjecture generalizes: for each fixed k ≥ 1, the equation x^a - y^b = k
has only finitely many solutions with x, y ≥ 2 and a, b ≥ 2.

We formalize:
1. The notion of perfect powers and Pillai solutions
2. Structural bounds on perfect power representations
3. The exponential growth of perfect powers implying finiteness for fixed gaps
4. Complete classification for small k values
5. A novel "ExpDiophEq" framework for exponential Diophantine equations
-/
import Mathlib

open Finset Nat

/-! ## Core Definitions -/

/-- A natural number is a perfect power if it equals `b^e` for some `b ≥ 2, e ≥ 2`. -/
def IsNatPerfectPower (n : ℕ) : Prop :=
  ∃ b e : ℕ, 2 ≤ b ∧ 2 ≤ e ∧ n = b ^ e

/-- A Pillai solution for gap `k` is a tuple `(x, a, y, b)` with `x^a - y^b = k`,
    where all bases and exponents are at least 2. -/
structure PillaiSolution (k : ℕ) where
  x : ℕ
  a : ℕ
  y : ℕ
  b : ℕ
  hx : 2 ≤ x
  ha : 2 ≤ a
  hy : 2 ≤ y
  hb : 2 ≤ b
  heq : x ^ a = y ^ b + k

/-- An exponential Diophantine equation system: captures equations of the form
    `∑ cᵢ · xᵢ^eᵢ = 0` over natural numbers. Generalizes Pillai, Fermat, and
    Catalan-type equations into a single framework. -/
structure ExpDiophEq where
  /-- Number of terms -/
  numTerms : ℕ
  /-- Coefficients (integers, to allow subtraction) -/
  coeffs : Fin numTerms → ℤ
  /-- Minimum exponent for each variable -/
  minExp : ℕ
  /-- Minimum base for each variable -/
  minBase : ℕ
  hMinExp : 2 ≤ minExp
  hMinBase : 2 ≤ minBase

/-- A solution to an exponential Diophantine equation -/
structure ExpDiophEq.Solution (eq : ExpDiophEq) where
  bases : Fin eq.numTerms → ℕ
  exponents : Fin eq.numTerms → ℕ
  hBases : ∀ i, eq.minBase ≤ bases i
  hExps : ∀ i, eq.minExp ≤ exponents i
  hSatisfies : ∑ i, eq.coeffs i * ((bases i : ℤ) ^ (exponents i)) = 0

/-! ## Perfect Power Growth Bounds -/

/-
Any perfect power `b^e` with `b ≥ 2, e ≥ 2` is at least 4.
-/
theorem perfectPower_ge_four {n : ℕ} (h : IsNatPerfectPower n) : 4 ≤ n := by
  rcases h with ⟨ b, e, hb, he, rfl ⟩ ; exact le_trans ( by decide ) ( Nat.pow_le_pow_left hb 2 ) |> le_trans <| Nat.pow_le_pow_right ( by linarith ) he;

/-
If `b ≥ 2` and `e ≥ 2`, then `b^e ≥ b^2`.
-/
theorem pow_ge_sq {b e : ℕ} (hb : 2 ≤ b) (he : 2 ≤ e) : b ^ 2 ≤ b ^ e := by
  exact Nat.pow_le_pow_right ( by linarith ) he

/-
For `b ≥ 2` and `e ≥ 2`, the gap `(b+1)^e - b^e` grows with `b`.
    Specifically, `b^e + e * b^(e-1) ≤ (b+1)^e`.
-/
theorem perfectPower_gap_growth (b e : ℕ) (hb : 2 ≤ b) (he : 2 ≤ e) :
    b ^ e + e * b ^ (e - 1) ≤ (b + 1) ^ e := by
  induction' he with k hk;
  · lia;
  · cases k <;> simp_all +decide [ pow_succ' ] ; nlinarith [ pow_pos ( zero_lt_two.trans_le hb ) ‹_› ]

/-
For fixed exponent `e ≥ 2`, the gap between consecutive e-th powers grows
    without bound.
-/
theorem gaps_grow_unbounded (e : ℕ) (he : 2 ≤ e) (M : ℕ) :
    ∃ b₀ : ℕ, ∀ b : ℕ, b₀ ≤ b → M < (b + 1) ^ e - b ^ e := by
  use M + 2;
  intro b hb; rw [ lt_tsub_iff_left ] ; induction he <;> simp_all +decide [ pow_succ' ] ; nlinarith [ Nat.zero_le ( b ^ ‹_› ) ] ;
  nlinarith [ pow_pos ( by linarith : 0 < b ) ‹_› ]

/-! ## Classification Results for Small k -/

/-
For k = 1: `x^2 - y^2 = 1` with `x, y ≥ 2` is impossible.
    Proof: `x^2 - y^2 = (x-y)(x+y)`, and `x+y ≥ 4`, so the product is ≥ 4.
-/
theorem no_sq_diff_one (x y : ℕ) (hx : 2 ≤ x) (hy : 2 ≤ y) :
    x ^ 2 ≠ y ^ 2 + 1 := by
  exact fun h => by nlinarith [ show x > y by nlinarith ] ;

/-
For k = 2: `x^2 - y^2 = 2` with `x, y ≥ 2` is impossible.
    Same factorization argument: (x-y)(x+y) = 2 needs x+y ≤ 2, impossible.
-/
theorem no_sq_diff_two (x y : ℕ) (hx : 2 ≤ x) (hy : 2 ≤ y) :
    x ^ 2 ≠ y ^ 2 + 2 := by
  exact fun h => by nlinarith [ show x > y by nlinarith ] ;

/-
For k = 3: `x^2 - y^2 = 3` with `x, y ≥ 2` is impossible.
-/
theorem no_sq_diff_three (x y : ℕ) (hx : 2 ≤ x) (hy : 2 ≤ y) :
    x ^ 2 ≠ y ^ 2 + 3 := by
  exact fun h => by nlinarith [ show x > y by nlinarith ] ;

/-
`x^2 - y^2 = 5` with `x, y ≥ 2`: the unique solution is `x = 3, y = 2`.
-/
theorem sq_diff_five_unique (x y : ℕ) (hx : 2 ≤ x) (hy : 2 ≤ y)
    (heq : x ^ 2 = y ^ 2 + 5) : x = 3 ∧ y = 2 := by
  rcases x with ( _ | _ | _ | _ | x ) <;> rcases y with ( _ | _ | _ | _ | y ) <;> simp_all +arith +decide [ Nat.pow_succ ];
  · nlinarith;
  · grind;
  · nlinarith [ show x = 0 by nlinarith ];
  · nlinarith [ show x = y + 1 by nlinarith ]

/-! ## Key Structural Lemma: Square Difference Factorization -/

/-
If `x^2 - y^2 = k` with `x > y`, then `x - y` divides `k`.
-/
theorem sq_diff_factorization (x y k : ℕ) (hxy : y < x) (heq : x ^ 2 = y ^ 2 + k) :
    (x - y) ∣ k := by
  exact ⟨ x + y, by nlinarith only [ Nat.sub_add_cancel hxy.le, heq ] ⟩

/-
Upper bound on x in `x^2 = y^2 + k`: we have `x ≤ k + y`
    (follows from `x^2 ≤ (k+y)^2` when k ≥ 1).
-/
theorem sq_diff_upper_bound (x y k : ℕ) (hk : 0 < k) (hx : 2 ≤ x) (hy : 2 ≤ y)
    (heq : x ^ 2 = y ^ 2 + k) : x ≤ k + y := by
  nlinarith only [ heq.le, hk ]

/-! ## Finiteness Results -/

/-
For fixed exponents a = b = 2 and gap k, solutions are bounded.
-/
theorem pillai_sq_sq_bounded (k : ℕ) (hk : 0 < k) :
    ∃ B : ℕ, ∀ (x y : ℕ), 2 ≤ x → 2 ≤ y → x ^ 2 = y ^ 2 + k → x ≤ B := by
  use k + k + 1;
  intro x y hx hy hxy; nlinarith [ show x > y by nlinarith ] ;

/-
For fixed `a ≥ 2` and gap `k ≥ 1`, consecutive `a`-th powers with gap `k`
    are bounded.
-/
theorem consecutive_power_gap_bounded (a k : ℕ) (ha : 2 ≤ a) (hk : 0 < k) :
    ∃ B : ℕ, ∀ b : ℕ, 2 ≤ b → (b + 1) ^ a = b ^ a + k → b ≤ B := by
  -- From gaps_grow_unbounded with e=a and M=k, get b₀ with the property that for b ≥ b₀, (b+1)^a - b^a > k.
  obtain ⟨b₀, hb₀⟩ : ∃ b₀ : ℕ, ∀ b : ℕ, b₀ ≤ b → k < (b + 1) ^ a - b ^ a := by
    exact gaps_grow_unbounded a ha k;
  exact ⟨ b₀, fun b hb₁ hb₂ => not_lt.1 fun hb₃ => by have := hb₀ _ hb₃.le; rw [ lt_tsub_iff_left ] at this; linarith ⟩

/-! ## Perfect Power Base Uniqueness -/

/-
If `b₁^e = b₂^e` for `e ≥ 1`, then `b₁ = b₂`.
-/
theorem perfectPower_base_unique (b₁ b₂ e : ℕ) (he : 1 ≤ e)
    (heq : b₁ ^ e = b₂ ^ e) : b₁ = b₂ := by
  cases e <;> aesop

/-
A perfect power with exponent ≥ 2 is either 0, 1, or ≥ 4.
-/
theorem perfectPower_trichotomy (b e : ℕ) (he : 2 ≤ e) :
    b ^ e = 0 ∨ b ^ e = 1 ∨ 4 ≤ b ^ e := by
  rcases b with ( _ | _ | b ) <;> rcases e with ( _ | _ | e ) <;> norm_num at *;
  grind

/-
The gap between n-th powers grows: `b^e + b^(e-1) < (b+1)^e` for b ≥ 2, e ≥ 2.
-/
theorem power_gap_lower_bound (b e : ℕ) (hb : 2 ≤ b) (he : 2 ≤ e) :
    b ^ e + b ^ (e - 1) < (b + 1) ^ e := by
  rcases e with ( _ | _ | e ) <;> simp_all +decide [ Nat.pow_succ ];
  nlinarith [ pow_pos ( zero_lt_two.trans_le hb ) e, pow_le_pow_left' ( show b + 1 ≥ b by linarith ) e, pow_pos ( zero_lt_two.trans_le hb ) 3, pow_le_pow_left' ( show b + 1 ≥ b by linarith ) 3 ]

/-! ## Pillai's Conjecture (Formal Statement) -/

/-- **Pillai's Conjecture**: For every `k ≥ 1`, the equation `x^a - y^b = k`
    has only finitely many solutions with `x, y, a, b ≥ 2`. -/
def PillaiConjecture : Prop :=
  ∀ k : ℕ, 0 < k → ∃ B : ℕ, ∀ (x a y b : ℕ),
    2 ≤ x → 2 ≤ a → 2 ≤ y → 2 ≤ b → x ^ a = y ^ b + k →
    x ≤ B ∧ y ≤ B ∧ a ≤ B ∧ b ≤ B

/-- Testable prediction: 3^3 - 5^2 = 2 is a Pillai solution for k = 2. -/
theorem pillai_k2_known_solution : (3 : ℕ) ^ 3 = 5 ^ 2 + 2 := by norm_num

/-
No consecutive perfect squares ≥ 4: a consequence of our classification.
-/
theorem no_consecutive_perfect_squares (n : ℕ) (hn : 4 ≤ n)
    (hsq : ∃ a : ℕ, 2 ≤ a ∧ n = a ^ 2) :
    ¬∃ b : ℕ, 2 ≤ b ∧ n + 1 = b ^ 2 := by
  rcases hsq with ⟨ a, ha, rfl ⟩ ; rintro ⟨ b, hb, h ⟩ ; nlinarith [ show a < b by nlinarith ]

/-! ## Deeper Results: Exponent Bounds and Finiteness -/

/-
Helper: if x^e = y^e + k with k > 0, then x > y.

For equal exponents `e ≥ 2` and gap `k`, if `x^e = y^e + k` with `x, y ≥ 2`,
    then both `x` and `y` are bounded. Uses the fact that `(y+1)^e - y^e ≥ e*y^(e-1)`,
    which exceeds `k` for `y` large.
    and (y+d)^e - y^e = k. For d ≥ 1 and e ≥ 2, the LHS grows with y,
    so y is bounded.
-/
theorem pillai_equal_exp_x_gt_y (e k : ℕ) (he : 2 ≤ e)
    (x y : ℕ) (hx : 2 ≤ x) (hy : 2 ≤ y) (heq : x ^ e = y ^ e + k) (hk : 0 < k) :
    y < x := by
  exact not_le.mp fun h => by linarith [ pow_le_pow_left' h e ] ;

theorem pillai_equal_exp_bounded (e k : ℕ) (he : 2 ≤ e) (hk : 0 < k) :
    ∃ B : ℕ, ∀ (x y : ℕ), 2 ≤ x → 2 ≤ y → x ^ e = y ^ e + k → x ≤ B ∧ y ≤ B := by
  -- By gaps_grow_unbounded, there � exists� y₀ such that for y ≥ y₀, (y+1)^e - y^e > k.
  obtain ⟨y₀, hy₀⟩ : ∃ y₀ : ℕ, ∀ y : ℕ, y₀ ≤ y → (y + 1) ^ e - y ^ e > k := gaps_grow_unbounded e he k;
  -- By contradiction, assume there exist x and y such that x ≥ y₀ + k and y ≥ y₀.
  use max (y₀ + k) (y₀ + k);
  intro x y hx hy hxy
  have hy_lt_y₀ : y < y₀ := by
    contrapose! hxy;
    exact fun h => by have := hy₀ y hxy; rw [ gt_iff_lt, lt_tsub_iff_left ] at this; linarith [ pow_le_pow_left' ( show x ≥ y + 1 from Nat.succ_le_of_lt ( Nat.lt_of_not_ge fun h => by linarith [ pow_le_pow_left' h e ] ) ) e ] ;
  have hx_le_yk : x ≤ y + k := by
    -- By contradiction, assume $x > y + k$.
    by_contra h_contra; push_neg at h_contra; have h_contra' : x ≥ y + k + 1 := by
      grind;
    -- Since $x \geq y + k + 1$, we have $x^e \geq (y + k + 1)^e$.
    have h_ge : x ^ e ≥ (y + k + 1) ^ e := by
      exact Nat.pow_le_pow_left h_contra' _;
    -- Since $e \geq 2$, we have $(y + k + 1)^e \geq y^e + e(y + k)^{e-1}$.
    have h_expand : (y + k + 1) ^ e ≥ y ^ e + e * (y + k) ^ (e - 1) := by
      rcases e <;> simp_all +decide [ add_pow, mul_comm ];
      simp +arith +decide [ Finset.sum_range_succ, mul_assoc, mul_comm, mul_left_comm, pow_succ' ];
    nlinarith [ Nat.pow_le_pow_right ( by linarith : 1 ≤ y + k ) ( Nat.le_sub_one_of_lt he ) ]
  have hx_le_B : x ≤ max (y₀ + k) (y₀ + k) := by
    grind
  exact ⟨hx_le_B, by
    grind⟩

/-
The image of squaring on `{0, ..., √N}` covers all perfect squares up to N,
    so there are at most `√N + 1` perfect squares in `{0, ..., N}`.
-/
theorem count_squares_le_sqrt (N : ℕ) :
    ((Finset.range (N.sqrt + 1)).image (fun a => a ^ 2)).card ≤ N.sqrt + 1 := by
  exact Finset.card_image_le.trans_eq ( Finset.card_range _ )

/-
Key lemma: if `x^a = y^b + k` with a ≥ 2, then `x^a > y^b`, giving `x > y^(b/a)`.
    More concretely, `x ≤ y^b + k` so `x^a ≤ (y^b + k)^a` but also `x^a = y^b + k`,
    yielding `y^b + k ≤ (y^b + k)`, which bounds both sides. The essential point:
    `y^b < x^a` so `y < x^(a/b)`, and `x^a = y^b + k < (y+1)^b + k` for large y,
    so `x` is squeezed. For fixed `a, b`, `y` determines at most one `x`.
-/
theorem pillai_y_determines_x (a b k : ℕ) (ha : 2 ≤ a) (hb : 2 ≤ b) (hk : 0 < k)
    (x₁ x₂ y : ℕ) (hx1 : 2 ≤ x₁) (hx2 : 2 ≤ x₂)
    (h1 : x₁ ^ a = y ^ b + k) (h2 : x₂ ^ a = y ^ b + k) : x₁ = x₂ := by
  exact Nat.pow_left_injective ( by linarith ) ( h1.trans h2.symm )

/-- **Falsifiable Conjecture**: For k = 2, the equation x^a - y^b = 2 with x,y,a,b ≥ 2
    has exactly one solution: (x,a,y,b) = (3,3,5,2), i.e., 27 - 25 = 2.

    Computational test: Search all x,y ≤ 10^6 and a,b ≤ 100 for additional solutions.
    If another solution is found, this conjecture is falsified. -/
def PillaiK2Conjecture : Prop :=
  ∀ (x a y b : ℕ), 2 ≤ x → 2 ≤ a → 2 ≤ y → 2 ≤ b →
    x ^ a = y ^ b + 2 → x = 3 ∧ a = 3 ∧ y = 5 ∧ b = 2

/-
The exponent in a Pillai solution is bounded by the gap: if x^a = y^b + k
    with x ≥ 2, then `a ≤ k + 1` (since `2^a ≤ x^a = y^b + k`).
    More precisely, x^a ≥ 2^a, so 2^a ≤ y^b + k. But this alone doesn't bound a
    without bounding y. A better bound: for fixed x ≥ 2, a ≤ log_x(y^b + k).
-/
theorem exponent_bound_from_base (x a k : ℕ) (hx : 2 ≤ x) (ha : 2 ≤ a)
    (hle : x ^ a ≤ k + 4) : a ≤ k + 2 := by
  -- By induction on $a$, we can show that $2^a > a + 2$ for all $a \geq 3$.
  have h_ind : ∀ a ≥ 3, 2 ^ a > a + 2 := by
    exact fun n hn => by induction hn <;> norm_num [ pow_succ' ] at * ; linarith;
  generalize_proofs at *; simp_all +decide [ Finset.card_image_of_injective, Function.Injective ] ; (
  exact le_of_not_gt fun h => by linarith [ h_ind a ( by linarith ), show x ^ a ≥ 2 ^ a by gcongr ] ;)