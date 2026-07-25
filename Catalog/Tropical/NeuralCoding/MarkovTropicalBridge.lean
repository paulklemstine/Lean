import Mathlib

/-!
# Markov–Tropical Bridge: From Mixing Bounds to Cycle Energy Barriers

This file establishes a formal bridge theorem connecting finite-state Markov
chain mixing bounds to tropical (min-plus) cycle geometry.

## Main Result

For a positive row-stochastic matrix `P` on `Fin (n+1)` states, if all
`m`-step transition probabilities satisfy `(P^m)(i,j) ≤ α`, then the
minimum triangle cycle mean of the tropical cost matrix `-log P` satisfies:

  `triangleCyc(-log P) ≥ -log α / m`

This formalizes the principle: **probabilistic mixing decay tropicalizes
into cycle-mean energy lower bounds.**

## Proof Architecture

The proof uses a "three rotating paths" argument:
1. For any triangle `(a,b,c)`, construct cycling paths that traverse the
   triangle `⌊m/3⌋` times from each starting vertex.
2. Each path product is a single summand of the corresponding `P^m` entry,
   hence bounded by `α`.
3. By cycling from each of the three vertices, the remainder edges
   distribute evenly across three logarithmic inequalities.
4. Adding the three inequalities yields `m · S ≥ 3·(-log α)`,
   where `S = W(a,b) + W(b,c) + W(c,a)` is the triangle weight sum.

## Cross-domain significance

The `-log` transform converts:
- **Markov transition probabilities** → **tropical edge weights** (information costs)
- **Uniform mixing decay `P^m(i,j) ≤ α`** → **energy barrier `-log α / m`**
- **Convergence to stationarity** → **tropical cycle geometry**

## References

Builds on:
- `SpectralTropicalBridge` in `Probability/SpectralTropicalBridge.lean`
- `TropicalMixing` in `MixingTheory.lean`
-/

noncomputable section

open Finset BigOperators Real Matrix

namespace MarkovTropicalBridge

variable {n : ℕ}

/-! ## Definitions -/

/-- A matrix is row-stochastic: all entries nonneg and each row sums to 1. -/
def RowStochastic (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) : Prop :=
  (∀ i j, 0 ≤ P i j) ∧ (∀ i, ∑ j, P i j = 1)

/-- A matrix has strictly positive entries. -/
def PositiveMatrix (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) : Prop :=
  ∀ i j, 0 < P i j

/-- The tropical cost matrix: `W i j = -log(P i j)`.
    Converts multiplicative transition probabilities into additive
    tropical edge weights (information costs). -/
def tropicalCost (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    Matrix (Fin (n+1)) (Fin (n+1)) ℝ :=
  fun i j => -Real.log (P i j)

/-- Mean weight of a triangle cycle `i → j → k → i`. -/
def triangleMean (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (i j k : Fin (n+1)) : ℝ :=
  (W i j + W j k + W k i) / 3

/-- Minimum triangle cycle mean over all triples `(i,j,k)`.
    A computationally tractable surrogate for the full tropical
    cycle mean (minimum over all cycle lengths and vertex choices). -/
def triangleCyc (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) : ℝ :=
  Finset.inf' Finset.univ ⟨0, Finset.mem_univ 0⟩
    (fun i => Finset.inf' Finset.univ ⟨0, Finset.mem_univ 0⟩
      (fun j => Finset.inf' Finset.univ ⟨0, Finset.mem_univ 0⟩
        (fun k => triangleMean W i j k)))

/-! ## Basic Entry Properties -/

/-- Positive entries are non-negative. -/
lemma nonneg_of_positive {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hpos : PositiveMatrix P) : ∀ i j, 0 ≤ P i j :=
  fun i j => le_of_lt (hpos i j)

/-
Row-stochastic matrices have entries at most 1.
-/
lemma entry_le_one {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hrow : RowStochastic P) (i j : Fin (n+1)) : P i j ≤ 1 := by
  exact hrow.2 i ▸ Finset.single_le_sum ( fun a _ => hrow.1 i a ) ( Finset.mem_univ j )

/-
The tropical cost of a positive row-stochastic matrix is non-negative.
-/
lemma tropicalCost_nonneg {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hrow : RowStochastic P) (hpos : PositiveMatrix P) (i j : Fin (n+1)) :
    0 ≤ tropicalCost P i j := by
  exact neg_nonneg_of_nonpos ( Real.log_nonpos ( le_of_lt ( hpos i j ) ) ( entry_le_one hrow i j ) )

/-! ## Non-negativity of Matrix Powers -/

/-
Powers of non-negative matrices have non-negative entries.
-/
lemma pow_entry_nonneg {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hnn : ∀ i j, 0 ≤ P i j) (m : ℕ) (i j : Fin (n+1)) :
    0 ≤ (P ^ m) i j := by
  exact?

/-! ## Path Product Bounds

These lemmas establish that specific path products through the matrix
are bounded above by the corresponding matrix power entries. The key
idea is that each path product appears as a single non-negative summand
in the sum defining the matrix power entry.
-/

/-
A two-step path product is bounded by the P² entry.
-/
lemma two_step_path_le {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hnn : ∀ i j, 0 ≤ P i j) (a k b : Fin (n+1)) :
    P a k * P k b ≤ (P * P) a b := by
  exact Finset.single_le_sum ( fun j _ => mul_nonneg ( hnn a j ) ( hnn j b ) ) ( Finset.mem_univ k ) |> le_trans ( by simpa [ mul_comm ] )

/-
A three-step triangle path product is bounded by the P³ diagonal entry.
-/
lemma triangle_path_le {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hnn : ∀ i j, 0 ≤ P i j) (a b c : Fin (n+1)) :
    P a b * P b c * P c a ≤ (P ^ 3) a a := by
  have h1 : (P^3) a a = ∑ k, (P^2) a k * P k a := by
    simp +decide only [pow_succ, mul_apply];
  exact h1.symm ▸ le_trans ( by simpa [ sq, Matrix.mul_apply, mul_assoc ] using mul_le_mul_of_nonneg_right ( Finset.single_le_sum ( fun x _ => mul_nonneg ( hnn a x ) ( hnn x c ) ) ( Finset.mem_univ b ) ) ( hnn c a ) ) ( Finset.single_le_sum ( fun x _ => mul_nonneg ( pow_entry_nonneg hnn 2 a x ) ( hnn x a ) ) ( Finset.mem_univ c ) )

/-
Diagonal power bound: `P(i,i)^m ≤ (P^m)(i,i)` for non-negative P.
    The self-loop product is one summand of the matrix power diagonal entry.
-/
lemma diag_pow_le {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hnn : ∀ i j, 0 ≤ P i j) (i : Fin (n+1)) (m : ℕ) :
    P i i ^ m ≤ (P ^ m) i i := by
  induction' m with m ih generalizing i <;> simp_all +decide [ pow_succ, Matrix.mul_apply ];
  exact le_trans ( mul_le_mul_of_nonneg_right ( ih i ) ( hnn i i ) ) ( Finset.single_le_sum ( fun j _ => mul_nonneg ( pow_entry_nonneg hnn m i j ) ( hnn j i ) ) ( Finset.mem_univ i ) )

/-
Cycle power bound: `(P(a,b)·P(b,c)·P(c,a))^q ≤ (P^{3q})(a,a)`.
    Repeating the triangle cycle `q` times stays bounded by the matrix power.
-/
lemma cycle_pow_le {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hnn : ∀ i j, 0 ≤ P i j) (a b c : Fin (n+1)) (q : ℕ) :
    (P a b * P b c * P c a) ^ q ≤ (P ^ (3 * q)) a a := by
  -- Let cyc = P a b * P b c * P c a. From triangle_path_le: cyc ≤ (P^3)(a,a).
  have h_cyc : P a b * P b c * P c a ≤ (P ^ 3) a a := by
    exact?;
  -- Then cyc^q ≤ ((P^3)(a,a))^q (by pow_le_pow_left with cyc ≥ 0 since product of non-negatives).
  have h_cyc_pow : (P a b * P b c * P c a) ^ q ≤ ((P ^ 3) a a) ^ q := by
    exact pow_le_pow_left₀ ( mul_nonneg ( mul_nonneg ( hnn _ _ ) ( hnn _ _ ) ) ( hnn _ _ ) ) h_cyc _;
  convert h_cyc_pow.trans _ using 1;
  convert diag_pow_le ( fun i j => pow_entry_nonneg hnn 3 i j ) a q using 1 ; rw [ pow_mul ]

/-
Extended cycle bound (remainder 1):
    `(cycle)^q · P(a,b) ≤ (P^{3q+1})(a,b)`.
-/
lemma cycle_pow_extend1 {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hnn : ∀ i j, 0 ≤ P i j) (a b c : Fin (n+1)) (q : ℕ) :
    (P a b * P b c * P c a) ^ q * P a b ≤ (P ^ (3 * q + 1)) a b := by
  -- By the properties of matrix multiplication and powers, we can rewrite the right-hand side.
  have h_rhs : (P ^ (3 * q + 1)) a b = (∑ k, (P ^ (3 * q)) a k * P k b) := by
    rw [ pow_succ, Matrix.mul_apply ];
  -- By the properties of matrix multiplication and powers, we can rewrite the left-hand side.
  have h_lhs : (P a b * P b c * P c a) ^ q * P a b ≤ (P ^ (3 * q)) a a * P a b := by
    exact mul_le_mul_of_nonneg_right ( cycle_pow_le hnn a b c q ) ( hnn a b );
  exact h_lhs.trans ( h_rhs.symm ▸ Finset.single_le_sum ( fun k _ => mul_nonneg ( pow_entry_nonneg hnn ( 3 * q ) a k ) ( hnn k b ) ) ( Finset.mem_univ a ) )

/-
Extended cycle bound (remainder 2):
    `(cycle)^q · P(a,b) · P(b,c) ≤ (P^{3q+2})(a,c)`.
-/
lemma cycle_pow_extend2 {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hnn : ∀ i j, 0 ≤ P i j) (a b c : Fin (n+1)) (q : ℕ) :
    (P a b * P b c * P c a) ^ q * (P a b * P b c) ≤ (P ^ (3 * q + 2)) a c := by
  have h_cycle_extend2 : (P a b * P b c * P c a) ^ q * (P a b * P b c) ≤ (P ^ (3 * q)) a a * (P ^ 2) a c := by
    refine' mul_le_mul _ _ _ _;
    · exact?;
    · simpa [ sq, Matrix.mul_apply ] using Finset.single_le_sum ( fun j _ => mul_nonneg ( hnn a j ) ( hnn j c ) ) ( Finset.mem_univ b );
    · exact mul_nonneg ( hnn _ _ ) ( hnn _ _ );
    · exact?;
  refine le_trans h_cycle_extend2 ?_;
  rw [ pow_add, Matrix.mul_apply ];
  exact le_trans ( by norm_num ) ( Finset.single_le_sum ( fun i _ => mul_nonneg ( pow_entry_nonneg hnn _ _ _ ) ( pow_entry_nonneg hnn _ _ _ ) ) ( Finset.mem_univ a ) )

/-! ## Logarithmic Lemmas -/

/-
`-log` is antitone on positive reals.
-/
lemma neg_log_le_of_le {x y : ℝ} (hx : 0 < x) (hxy : x ≤ y) :
    -Real.log y ≤ -Real.log x := by
  exact neg_le_neg ( Real.log_le_log hx hxy )

/-
`-log` distributes over products (with sign flip).
-/
lemma neg_log_mul_eq {x y : ℝ} (hx : 0 < x) (hy : 0 < y) :
    -Real.log (x * y) = -Real.log x + (-Real.log y) := by
  rw [ Real.log_mul hx.ne' hy.ne', neg_add ]

/-
`-log` of a power.
-/
lemma neg_log_pow_eq {x : ℝ} (hx : 0 < x) (m : ℕ) :
    -Real.log (x ^ m) = ↑m * (-Real.log x) := by
  rw [ Real.log_pow, mul_neg ]

/-! ## Triangle Mean Lower Bound

The heart of the proof: for any triple `(a,b,c)` and `m ≥ 1`,
the triangle mean of the tropical cost matrix is at least `-log α / m`.
-/

/-
**Triangle mean bound for `m ≡ 0 (mod 3)`.**
    Uses a single cycling path: `(a→b→c→a)^q` of length `3q`.
-/
lemma triangleMean_lb_mod0
    {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    {α : ℝ} (_hα : 0 < α) {q : ℕ} (hq : 1 ≤ q)
    (hpow : ∀ i j, (P ^ (3 * q)) i j ≤ α)
    (a b c : Fin (n+1)) :
    -Real.log α / (3 * q : ℝ) ≤ triangleMean (tropicalCost P) a b c := by
  -- By the cycle_pow_le lemma, we have (P a b * P b c * P c a) ^ q ≤ (P ^ (3 * q)) a a.
  have h_cycle_pow : (P a b * P b c * P c a) ^ q ≤ (P ^ (3 * q)) a a := by
    convert cycle_pow_le ( fun i j => hrow.1 i j ) a b c q using 1;
  -- Taking the logarithm of both sides of the inequality (P a b * P b c * P c a) ^ q ≤ α, we get q * (W(a,b) + W(b,c) + W(c,a)) ≥ -log α.
  have h_log : q * (tropicalCost P a b + tropicalCost P b c + tropicalCost P c a) ≥ -Real.log α := by
    have h_log : -Real.log ((P a b * P b c * P c a) ^ q) ≥ -Real.log α := by
      exact neg_le_neg ( Real.log_le_log ( pow_pos ( mul_pos ( mul_pos ( hpos a b ) ( hpos b c ) ) ( hpos c a ) ) _ ) ( h_cycle_pow.trans ( hpow a a ) ) );
    convert h_log using 1 ; norm_num [ Real.log_mul, ne_of_gt ( hpos _ _ ) ] ; ring;
    unfold tropicalCost; ring;
  unfold triangleMean; rw [ div_le_iff₀ ] <;> first | positivity | linarith;

/-
**Triangle mean bound for `m ≡ 1 (mod 3)`.**
    Uses three rotating cycling paths that distribute the single
    remainder edge across three inequalities.
-/
lemma triangleMean_lb_mod1
    {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    {α : ℝ} (_hα : 0 < α) {q : ℕ}
    (hpow : ∀ i j, (P ^ (3 * q + 1)) i j ≤ α)
    (a b c : Fin (n+1)) :
    -Real.log α / (3 * q + 1 : ℝ) ≤ triangleMean (tropicalCost P) a b c := by
  -- Applying the cycle_pow_extend1 lemma to the paths starting at a, b, and c.
  have h1 : (P a b * P b c * P c a) ^ q * P a b ≤ α := by
    refine' le_trans _ ( hpow a b );
    convert cycle_pow_extend1 ( fun i j => le_of_lt ( hpos i j ) ) a b c q using 1
  have h2 : (P a b * P b c * P c a) ^ q * P b c ≤ α := by
    have := cycle_pow_extend1 ( fun i j => hrow.1 i j ) b c a q;
    convert this.trans ( hpow b c ) using 1 ; ring
  have h3 : (P a b * P b c * P c a) ^ q * P c a ≤ α := by
    have := cycle_pow_extend1 ( fun i j => hrow.1 i j ) c a b q;
    exact le_trans ( by ring_nf; norm_num ) ( this.trans ( hpow _ _ ) );
  -- Taking the logarithm of each inequality:
  have hlog1 : q * (-Real.log (P a b * P b c * P c a)) + (-Real.log (P a b)) ≥ -Real.log α := by
    have hlog1 : -Real.log ((P a b * P b c * P c a) ^ q * P a b) ≥ -Real.log α := by
      exact neg_le_neg ( Real.log_le_log ( mul_pos ( pow_pos ( mul_pos ( mul_pos ( hpos a b ) ( hpos b c ) ) ( hpos c a ) ) _ ) ( hpos a b ) ) h1 );
    rw [ Real.log_mul ( by exact pow_ne_zero _ <| mul_ne_zero ( mul_ne_zero ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ) ( ne_of_gt <| hpos _ _ ) ) ( by exact ne_of_gt <| hpos _ _ ), Real.log_pow ] at hlog1 ; linarith
  have hlog2 : q * (-Real.log (P a b * P b c * P c a)) + (-Real.log (P b c)) ≥ -Real.log α := by
    have hlog2 : -Real.log ((P a b * P b c * P c a) ^ q * P b c) ≥ -Real.log α := by
      exact neg_le_neg ( Real.log_le_log ( mul_pos ( pow_pos ( mul_pos ( mul_pos ( hpos _ _ ) ( hpos _ _ ) ) ( hpos _ _ ) ) _ ) ( hpos _ _ ) ) h2 );
    convert hlog2 using 1 ; rw [ Real.log_mul ( pow_ne_zero _ <| mul_ne_zero ( mul_ne_zero ( ne_of_gt <| hpos _ _ ) <| ne_of_gt <| hpos _ _ ) <| ne_of_gt <| hpos _ _ ) <| ne_of_gt <| hpos _ _ ] ; rw [ Real.log_pow ] ; ring
  have hlog3 : q * (-Real.log (P a b * P b c * P c a)) + (-Real.log (P c a)) ≥ -Real.log α := by
    have := Real.log_le_log ( mul_pos ( pow_pos ( mul_pos ( mul_pos ( hpos a b ) ( hpos b c ) ) ( hpos c a ) ) q ) ( hpos c a ) ) h3;
    rw [ Real.log_mul ( pow_ne_zero _ <| mul_ne_zero ( mul_ne_zero ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ) ( ne_of_gt <| hpos _ _ ) ) ( ne_of_gt <| hpos _ _ ), Real.log_pow ] at this ; linarith;
  rw [ div_le_iff₀ ] <;> first | positivity | norm_num [ triangleMean, tropicalCost ] ;
  rw [ Real.log_mul ( mul_ne_zero ( ne_of_gt ( hpos _ _ ) ) ( ne_of_gt ( hpos _ _ ) ) ) ( ne_of_gt ( hpos _ _ ) ), Real.log_mul ( ne_of_gt ( hpos _ _ ) ) ( ne_of_gt ( hpos _ _ ) ) ] at * ; linarith

/-
**Triangle mean bound for `m ≡ 2 (mod 3)`.**
    Uses three rotating cycling paths that distribute the two
    remainder edges across three inequalities.
-/
lemma triangleMean_lb_mod2
    {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    {α : ℝ} (_hα : 0 < α) {q : ℕ}
    (hpow : ∀ i j, (P ^ (3 * q + 2)) i j ≤ α)
    (a b c : Fin (n+1)) :
    -Real.log α / (3 * q + 2 : ℝ) ≤ triangleMean (tropicalCost P) a b c := by
  -- Applying the cycle_pow_extend2 lemma to the paths starting at a, b, and c.
  have h1 : (P a b * P b c * P c a) ^ q * (P a b * P b c) ≤ (P ^ (3 * q + 2)) a c := by
    apply cycle_pow_extend2;
    exact fun i j => le_of_lt ( hpos i j )
  have h2 : (P b c * P c a * P a b) ^ q * (P b c * P c a) ≤ (P ^ (3 * q + 2)) b a := by
    convert cycle_pow_extend2 ( fun i j => hrow.1 i j ) b c a q using 1
  have h3 : (P c a * P a b * P b c) ^ q * (P c a * P a b) ≤ (P ^ (3 * q + 2)) c b := by
    convert cycle_pow_extend2 ( show ∀ i j, 0 ≤ P i j from fun i j => le_of_lt ( hpos i j ) ) c a b q using 1;
  -- Taking the logarithm of both sides of the inequalities h1, h2, and h3.
  have hlog1 : (q : ℝ) * (-Real.log (P a b * P b c * P c a)) + (-Real.log (P a b * P b c)) ≥ -Real.log α := by
    have hlog1 : Real.log ((P a b * P b c * P c a) ^ q * (P a b * P b c)) ≤ Real.log α := by
      exact Real.log_le_log ( mul_pos ( pow_pos ( mul_pos ( mul_pos ( hpos _ _ ) ( hpos _ _ ) ) ( hpos _ _ ) ) _ ) ( mul_pos ( hpos _ _ ) ( hpos _ _ ) ) ) ( h1.trans ( hpow _ _ ) );
    rw [ Real.log_mul ( pow_ne_zero _ <| mul_ne_zero ( mul_ne_zero ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ) ( ne_of_gt <| hpos _ _ ) ) ( mul_ne_zero ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ), Real.log_pow ] at hlog1 ; linarith
  have hlog2 : (q : ℝ) * (-Real.log (P b c * P c a * P a b)) + (-Real.log (P b c * P c a)) ≥ -Real.log α := by
    have hlog2 : -Real.log ((P b c * P c a * P a b) ^ q * (P b c * P c a)) ≥ -Real.log α := by
      exact neg_le_neg ( Real.log_le_log ( mul_pos ( pow_pos ( mul_pos ( mul_pos ( hpos _ _ ) ( hpos _ _ ) ) ( hpos _ _ ) ) _ ) ( mul_pos ( hpos _ _ ) ( hpos _ _ ) ) ) ( h2.trans ( hpow _ _ ) ) );
    convert hlog2 using 1;
    rw [ Real.log_mul ( pow_ne_zero _ ( mul_ne_zero ( mul_ne_zero ( ne_of_gt ( hpos _ _ ) ) ( ne_of_gt ( hpos _ _ ) ) ) ( ne_of_gt ( hpos _ _ ) ) ) ) ( mul_ne_zero ( ne_of_gt ( hpos _ _ ) ) ( ne_of_gt ( hpos _ _ ) ) ), Real.log_pow ] ; ring
  have hlog3 : (q : ℝ) * (-Real.log (P c a * P a b * P b c)) + (-Real.log (P c a * P a b)) ≥ -Real.log α := by
    have hlog3 : -Real.log ((P c a * P a b * P b c) ^ q * (P c a * P a b)) ≥ -Real.log α := by
      exact neg_le_neg ( Real.log_le_log ( mul_pos ( pow_pos ( mul_pos ( mul_pos ( hpos _ _ ) ( hpos _ _ ) ) ( hpos _ _ ) ) _ ) ( mul_pos ( hpos _ _ ) ( hpos _ _ ) ) ) ( h3.trans ( hpow _ _ ) ) );
    rw [ Real.log_mul ( pow_ne_zero _ <| mul_ne_zero ( mul_ne_zero ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ) ( ne_of_gt <| hpos _ _ ) ) ( mul_ne_zero ( ne_of_gt <| hpos _ _ ) ( ne_of_gt <| hpos _ _ ) ), Real.log_pow ] at hlog3 ; linarith;
  norm_num [ Real.log_mul, ne_of_gt ( hpos _ _ ) ] at *;
  unfold triangleMean tropicalCost; rw [ div_le_iff₀ ] <;> nlinarith;

/-
**Triangle mean lower bound (all cases).**
    For any triple `(a,b,c)` and `m ≥ 1`, if all `m`-step
    transition probabilities are at most `α`, then the triangle
    mean of `-log P` at `(a,b,c)` is at least `-log α / m`.
-/
lemma triangleMean_lower_bound
    {P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ}
    {m : ℕ} (hm : 1 ≤ m)
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    {α : ℝ} (hα : 0 < α)
    (hpow : ∀ i j, (P ^ m) i j ≤ α)
    (a b c : Fin (n+1)) :
    -Real.log α / (m : ℝ) ≤ triangleMean (tropicalCost P) a b c := by
  -- Rewrite `m` using the division algorithm: `m = 3 * q + r` where `r = m % 3` is in `{0,1,2}`.
  obtain ⟨q, r, hr⟩ : ∃ q r : ℕ, m = 3 * q + r ∧ r < 3 := Nat.div_add_mod m 3 ▸ ⟨m / 3, m % 3, rfl, Nat.mod_lt m (by norm_num)⟩;
  rcases hr with ⟨ rfl, hr ⟩ ; interval_cases r <;> simp_all +decide;
  · convert triangleMean_lb_mod0 hrow hpos hα ( by linarith : 1 ≤ q ) hpow a b c using 1;
  · convert triangleMean_lb_mod1 hrow hpos hα hpow a b c using 1;
  · convert triangleMean_lb_mod2 hrow hpos hα hpow a b c using 1

/-
The `triangleCyc` is bounded below by any quantity that bounds
    all triangle means from below.
-/
lemma le_triangleCyc_of_le_triangleMean
    {W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ} {c : ℝ}
    (h : ∀ i j k : Fin (n+1), c ≤ triangleMean W i j k) :
    c ≤ triangleCyc W := by
  unfold triangleCyc;
  simp +decide [ Finset.le_inf'_iff, h ]

/-! ## Main Theorems -/

/-- **The Multi-Step Tropical Gap Theorem.**

For a positive row-stochastic matrix `P` on `Fin(n+1)`, if all `m`-step
transition probabilities satisfy `(P^m)(i,j) ≤ α` with `0 < α < 1`,
then the minimum triangle cycle mean of the tropical cost matrix
`-log P` satisfies:

    `triangleCyc(-log P) ≥ -log α / m`

This formalizes the principle that **probabilistic mixing decay
tropicalizes into cycle-mean energy lower bounds**.

The proof uses a "three rotating paths" technique:
for each triangle `(a,b,c)`, three cycling paths starting from
`a`, `b`, `c` respectively traverse the triangle `⌊m/3⌋` times.
Their remainder edges distribute evenly, so summing the three
log-path-weight inequalities yields `m · S ≥ 3(-log α)`. -/
theorem multi_step_tropical_gap
    {m : ℕ} (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    (α : ℝ) (hα : 0 < α) (_hα1 : α < 1)
    (hm : 1 ≤ m)
    (hpow : ∀ i j, (P ^ m) i j ≤ α) :
    -Real.log α / (m : ℝ) ≤ triangleCyc (tropicalCost P) :=
  le_triangleCyc_of_le_triangleMean
    (fun i j k => triangleMean_lower_bound hm hrow hpos hα hpow i j k)

/-
**One-Step Tropical Gap (m=1 special case).**

When `m = 1`, the bound simplifies to `-log α ≤ triangleCyc(-log P)`:
if all single-step transition probabilities are at most `α`, then
every triangle cycle mean is at least `-log α`.

This is the direct tropicalization of entry bounds.
-/
theorem one_step_tropical_gap
    (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    (α : ℝ) (hα : 0 < α) (hα1 : α < 1)
    (hpow : ∀ i j, P i j ≤ α) :
    -Real.log α ≤ triangleCyc (tropicalCost P) := by
  -- Apply the multi_step_tropical_gap theorem with m=1.
  have := multi_step_tropical_gap P hrow hpos α hα hα1 (le_refl 1) (by simpa using hpow);
  convert this using 1 ; norm_num

/-
**Multiplicative form of the multi-step gap.**

Equivalent to `multi_step_tropical_gap` but stated as
`-log α ≤ m · triangleCyc(-log P)`.
-/
theorem multi_step_tropical_gap_mul
    {m : ℕ} (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    (α : ℝ) (hα : 0 < α) (hα1 : α < 1)
    (hm : 1 ≤ m)
    (hpow : ∀ i j, (P ^ m) i j ≤ α) :
    -Real.log α ≤ (m : ℝ) * triangleCyc (tropicalCost P) := by
  have := multi_step_tropical_gap P hrow hpos α hα hα1 hm hpow;
  rwa [ div_le_iff₀' ( by positivity ) ] at this

end MarkovTropicalBridge

end