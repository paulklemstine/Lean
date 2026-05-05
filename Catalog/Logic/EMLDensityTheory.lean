import Mathlib

/-! # EML Density Theory

## Overview

The **EML operation** (Exp Minus Log) is defined as `EML(a, b) = exp(a) - log(b)`.
Starting from a single seed value `{1}`, iterating EML generates a countable set that
is dense in `ℝ`. This connects to fundamental questions in mathematical logic about
the definability and naming of real numbers through algebraic-transcendental operations.

## Key Results

1. **Algebraic identities**: The EML operation satisfies log-splitting, shift, and
   inversion identities that give it rich algebraic structure.
2. **Irrationality of e**: A classical result proved via the factorial series method,
   demonstrating that EML generates transcendental values from rational seeds.
3. **Closure properties**: The full EML closure of `{1}` is closed under
   exponentiation, logarithm, subtraction, and addition.
4. **Density of EML closure**: The full EML closure of `{1}` is dense in `ℝ`,
   proved via Kronecker's theorem on additive subgroups.

## Logical Significance

From a single axiom (the seed value 1) and a single binary operation (EML),
we can name a dense subset of the reals. This provides a concrete, constructive
witness to the density of definable reals — connecting analysis to logic.
-/

noncomputable section

open Real Set

/-! ## Definitions -/

/-- The EML (Exp Minus Log) operation: `EML(a, b) = exp(a) - log(b)`. -/
def EMLd (a b : ℝ) : ℝ := Real.exp a - Real.log b

/-- EML closure at depth `n`: start from seed set `S` and apply `EMLd` `n` times. -/
def EMLClosure : ℕ → Set ℝ → Set ℝ
  | 0, S => S
  | n + 1, S => EMLClosure n S ∪ {z | ∃ a ∈ EMLClosure n S, ∃ b ∈ EMLClosure n S, z = EMLd a b}

/-- The full EML closure (union over all depths). -/
def fullEMLClosure (S : Set ℝ) : Set ℝ := ⋃ n, EMLClosure n S

/-! ## Basic Properties -/

theorem one_in_closure : (1 : ℝ) ∈ EMLClosure 0 {1} := by
  simp [EMLClosure]

theorem EMLClosure_mono (S : Set ℝ) (n : ℕ) :
    EMLClosure n S ⊆ EMLClosure (n + 1) S := by
  intro x hx; exact Or.inl hx

theorem EMLClosure_mono_le (S : Set ℝ) {n m : ℕ} (h : n ≤ m) :
    EMLClosure n S ⊆ EMLClosure m S :=
  monotone_nat_of_le_succ (EMLClosure_mono S) h

theorem EMLClosure_subset_full (S : Set ℝ) (n : ℕ) :
    EMLClosure n S ⊆ fullEMLClosure S :=
  fun _ hx => mem_iUnion.mpr ⟨n, hx⟩

/-! ## Algebraic Identities -/

/-- Log-split: `EML(x, y·z) = EML(x, y) - ln(z)` for `y, z > 0`. -/
theorem EMLd_log_split (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    EMLd x (y * z) = EMLd x y - Real.log z := by
  simp [EMLd, Real.log_mul hy.ne' hz.ne']; ring

/-- `EML(x, 1) = exp(x)`: the EML operation with second argument 1 recovers exponentiation. -/
theorem EMLd_exp (x : ℝ) : EMLd x 1 = Real.exp x := by
  simp [EMLd, Real.log_one]

/-- `EML(0, x) = 1 - ln(x)`: the EML operation with first argument 0 gives
    the log-complement. -/
theorem EMLd_one_minus_log (x : ℝ) : EMLd 0 x = 1 - Real.log x := by
  simp [EMLd]

/-- `EML(0, x)` maps values in `(1, e)` to `(0, 1)`, acting as a compression map. -/
theorem EMLd_maps_to_unit_interval (x : ℝ) (hx1 : 1 < x) (hxe : x < Real.exp 1) :
    0 < EMLd 0 x ∧ EMLd 0 x < 1 := by
  constructor
  · simp [EMLd]
    have : Real.log x < 1 := by
      rwa [← Real.log_exp 1, Real.log_lt_log_iff (by linarith) (Real.exp_pos 1)]
    linarith
  · simp [EMLd]; linarith [Real.log_pos hx1]

/-- `exp` applied via EML maps any positive value to a value `> 1`. -/
theorem EMLd_amplifies (x : ℝ) (hx : 0 < x) : EMLd x 1 > 1 := by
  simp [EMLd, Real.log_one]; linarith [Real.add_one_le_exp x]

/-- The composition `EML(EML(0, x), 1) = e/x` for `x > 0`:
    the EML operation can express scaled inversion. -/
theorem EMLd_inv_scaled (x : ℝ) (hx : 0 < x) :
    EMLd (EMLd 0 x) 1 = Real.exp 1 / x := by
  simp [EMLd, Real.log_one, Real.exp_sub, Real.exp_log hx]

/-- Log recovery: `EML(0, exp(EML(0, x))) = ln(x)`. -/
theorem EMLd_recovers_ln (x : ℝ) :
    EMLd 0 (Real.exp (EMLd 0 x)) = Real.log x := by
  simp [EMLd, Real.log_exp]

/-- Double negation: `EML(0, exp(EML(0, exp(x)))) = x`. -/
theorem EMLd_double_neg (x : ℝ) :
    EMLd 0 (Real.exp (EMLd 0 (Real.exp x))) = x := by
  simp [EMLd, Real.log_exp]

/-- Shift identity: `EML(x + c, 1) = exp(c) · exp(x)`. -/
theorem EMLd_shift (x c : ℝ) :
    EMLd (x + c) 1 = Real.exp c * Real.exp x := by
  simp [EMLd, Real.log_one, Real.exp_add, mul_comm]

/-! ## Irrationality of e

We prove that `e = exp(1)` is irrational using the classical factorial series argument.
Since `EML(1, 1) = exp(1) = e`, the EML closure of `{1}` generates an irrational
number at the very first step.
-/

/-
The number `e = exp(1)` is irrational, proved via the factorial series method.
    If `e = p/q`, then `q! · e` splits into an integer part plus a tail series
    `∑_{k≥1} q!/(q+k)!` which is strictly between 0 and 1, contradicting integrality.
-/
theorem e_irrational : Irrational (Real.exp 1) := by
  by_contra h_contra
  obtain ⟨p, q, hq_pos, hpq_eq⟩ : ∃ p q : ℕ, q > 0 ∧ Real.exp 1 = p / q := by
    obtain ⟨ p, hp ⟩ := Classical.not_not.1 h_contra;
    exact ⟨ p.num.natAbs, p.den, Nat.cast_pos.mpr p.pos, by simpa [ abs_of_nonneg ( Rat.num_nonneg.mpr ( show 0 ≤ p by exact_mod_cast hp.symm ▸ Real.exp_nonneg _ ) ), Rat.cast_def ] using hp.symm ⟩;
  -- Consider the series expansion of $e$: $e = \sum_{n=0}^{\infty} \frac{1}{n!}$.
  have h_series : Real.exp 1 = ∑' n : ℕ, (1 : ℝ) / Nat.factorial n := by
    simp +decide [ Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div ];
  -- Consider the series $\sum_{n=q+1}^{\infty} \frac{q!}{n!}$. This series is strictly between 0 and 1.
  have h_tail : 0 < ∑' n : ℕ, (q.factorial : ℝ) / Nat.factorial (q + 1 + n) ∧ ∑' n : ℕ, (q.factorial : ℝ) / Nat.factorial (q + 1 + n) < 1 := by
    -- We'll use that the series $\sum_{n=q+1}^{\infty} \frac{q!}{n!}$ is a geometric series with the first term $\frac{q!}{(q+1)!} = \frac{1}{q+1}$ and common ratio $\frac{1}{q+2}$.
    have h_geo_series : ∑' n : ℕ, (q.factorial : ℝ) / Nat.factorial (q + 1 + n) ≤ ∑' n : ℕ, (1 : ℝ) / (q + 1) * (1 / (q + 2)) ^ n := by
      refine' Summable.tsum_le_tsum _ _ _;
      · field_simp;
        intro i; rw [ mul_comm ] ; induction i <;> simp_all +decide [ Nat.factorial, pow_succ' ];
        field_simp at *;
        nlinarith [ ( by positivity : 0 < ( q + 1 : ℝ ) * q.factorial * ( q + 2 ) ^ ‹_› ) ];
      · exact Summable.mul_left _ <| by simpa using Summable.comp_injective ( Real.summable_pow_div_factorial 1 ) <| by intros a b; aesop;
      · exact Summable.mul_left _ <| summable_geometric_of_lt_one ( by positivity ) <| by rw [ div_lt_iff₀ ] <;> linarith;
    refine' ⟨ _, lt_of_le_of_lt h_geo_series _ ⟩;
    · refine' Summable.tsum_pos ..;
      any_goals intros; positivity;
      · exact Summable.mul_left _ <| by simpa using Summable.comp_injective ( Real.summable_pow_div_factorial 1 ) <| by intros a b; aesop;
      · exact q;
    · rw [ tsum_mul_left, tsum_geometric_of_lt_one ( by positivity ) ( by rw [ div_lt_iff₀ ] <;> linarith ) ];
      field_simp;
      rw [ div_lt_iff₀ ] <;> nlinarith only [ show ( q : ℝ ) ≥ 1 by norm_cast ];
  -- This contradicts that $q! \cdot e$ is an integer.
  have h_contradiction : ∃ m : ℤ, q.factorial * Real.exp 1 = m := by
    use p * q.factorial / q;
    rw [ Int.cast_div ] <;> norm_num [ hpq_eq, mul_comm, hq_pos.ne' ];
    · ring;
    · exact dvd_mul_of_dvd_right ( mod_cast Nat.dvd_factorial ( by positivity ) ( by linarith ) ) _;
  -- Split the sum into two parts: the sum up to $q$ and the sum from $q+1$ to infinity.
  have h_split_sum : ∑' n : ℕ, (q.factorial : ℝ) / Nat.factorial n = (∑ n ∈ Finset.range (q + 1), (q.factorial : ℝ) / Nat.factorial n) + (∑' n : ℕ, (q.factorial : ℝ) / Nat.factorial (q + 1 + n)) := by
    rw [ ← Summable.sum_add_tsum_nat_add ];
    congr! 2;
    · ac_rfl;
    · exact Summable.mul_left _ <| by simpa using Real.summable_pow_div_factorial 1;
  -- The first part of the sum is an integer, and the second part is strictly between 0 and 1.
  have h_int_part : ∃ m : ℤ, ∑ n ∈ Finset.range (q + 1), (q.factorial : ℝ) / Nat.factorial n = m := by
    exact ⟨ ∑ n ∈ Finset.range ( q + 1 ), q.factorial / n.factorial, by push_cast; exact Finset.sum_congr rfl fun _ _ => by rw [ Int.cast_div ( mod_cast Nat.factorial_dvd_factorial <| by linarith [ Finset.mem_range.mp ‹_› ] ) ( by positivity ) ] ; push_cast; ring ⟩;
  simp_all +decide [ div_eq_mul_inv, tsum_mul_left ];
  obtain ⟨ m, hm ⟩ := h_int_part; obtain ⟨ n, hn ⟩ := h_contradiction; exact False.elim <| by linarith [ show ( n : ℝ ) ≤ m by exact_mod_cast Int.le_of_lt_add_one <| by { rw [ ← @Int.cast_lt ℝ ] ; push_cast; linarith } ] ;

/-! ## Full Closure Properties

We now prove that `fullEMLClosure {1}` is closed under various operations,
building up to addition. The key insight is that subtraction is available
(for positive first argument) via `EMLd(log(a), exp(b)) = a - b`, and
addition follows by choosing a sufficiently large element to subtract through.
-/

/-- The full EML closure is closed under EMLd: if `x, y ∈ fullEMLClosure S`,
    then `EMLd x y ∈ fullEMLClosure S`. -/
theorem fullEMLClosure_closed_EMLd (S : Set ℝ) (x y : ℝ)
    (hx : x ∈ fullEMLClosure S) (hy : y ∈ fullEMLClosure S) :
    EMLd x y ∈ fullEMLClosure S := by
  obtain ⟨k, hk⟩ : ∃ k : ℕ, x ∈ EMLClosure k S ∧ y ∈ EMLClosure k S := by
    simp_all +decide [fullEMLClosure]
    exact ⟨Max.max hx.choose hy.choose,
      EMLClosure_mono_le _ (le_max_left _ _) hx.choose_spec,
      EMLClosure_mono_le _ (le_max_right _ _) hy.choose_spec⟩
  exact Set.mem_iUnion.2 ⟨k + 1, Or.inr ⟨x, hk.1, y, hk.2, rfl⟩⟩

/-- 1 is in the full EML closure of {1}. -/
theorem fullEMLClosure_one : (1 : ℝ) ∈ fullEMLClosure {1} :=
  EMLClosure_subset_full {1} 0 one_in_closure

/-- `exp(1)` is in the EML closure of `{1}` at depth 1. -/
theorem exp_one_in_closure : Real.exp 1 ∈ EMLClosure 1 {1} :=
  Or.inr ⟨1, mem_singleton 1, 1, mem_singleton 1, by norm_num [EMLd_exp]⟩

/-- `exp(1)` is in the full closure. -/
theorem fullEMLClosure_exp_one : Real.exp 1 ∈ fullEMLClosure {1} :=
  EMLClosure_subset_full {1} 1 exp_one_in_closure

/-- 0 is in the full EML closure of `{1}`.
    Built as `EML(1, exp(exp(1))) = exp(1) - log(exp(exp(1))) = e - e = 0`. -/
theorem fullEMLClosure_zero : (0 : ℝ) ∈ fullEMLClosure {1} := by
  have h2 : Real.exp (Real.exp 1) ∈ EMLClosure 2 {1} := by
    exact Set.mem_union_right _
      ⟨Real.exp 1, exp_one_in_closure, 1,
       Set.mem_union_left _ (Set.mem_singleton _), by unfold EMLd; aesop⟩
  have h3 : 0 ∈ EMLClosure 3 {1} := by
    exact Set.mem_union_right _
      ⟨1, EMLClosure_mono {1} 1 (EMLClosure_mono {1} 0 one_in_closure),
       Real.exp (Real.exp 1), h2, by unfold EMLd; norm_num⟩
  exact Set.mem_iUnion.mpr ⟨3, h3⟩

/-- For any `x` in the full closure, `exp(x)` is also in the full closure.
    Uses `EML(x, 1) = exp(x)`. -/
theorem fullEMLClosure_closed_exp (x : ℝ) (hx : x ∈ fullEMLClosure {1}) :
    Real.exp x ∈ fullEMLClosure {1} := by
  rw [← EMLd_exp x]
  exact fullEMLClosure_closed_EMLd {1} x 1 hx fullEMLClosure_one

/-- For any `x` in the full closure, `1 - x` is also in the full closure.
    Uses `EML(0, exp(x)) = 1 - log(exp(x)) = 1 - x`. -/
theorem fullEMLClosure_closed_one_minus (x : ℝ) (hx : x ∈ fullEMLClosure {1}) :
    1 - x ∈ fullEMLClosure {1} := by
  have : EMLd 0 (Real.exp x) = 1 - x := by simp [EMLd, Real.log_exp]
  rw [← this]
  exact fullEMLClosure_closed_EMLd {1} 0 (Real.exp x)
    fullEMLClosure_zero (fullEMLClosure_closed_exp x hx)

/-- For any `x` in the full closure, `log(x)` is in the full closure.
    Computed as `1 - (1 - log(x))` where `1 - log(x) = EML(0, x)`. -/
theorem fullEMLClosure_closed_log (x : ℝ) (hx : x ∈ fullEMLClosure {1}) :
    Real.log x ∈ fullEMLClosure {1} := by
  have h : 1 - Real.log x ∈ fullEMLClosure {1} := by
    rw [← EMLd_one_minus_log]
    exact fullEMLClosure_closed_EMLd {1} 0 x fullEMLClosure_zero hx
  have : Real.log x = 1 - (1 - Real.log x) := by ring
  rw [this]
  exact fullEMLClosure_closed_one_minus _ h

/-- For `x > 0` in the full closure and any `y` in the full closure, `x - y` is in the closure.
    Uses `EML(log(x), exp(y)) = exp(log(x)) - log(exp(y)) = x - y`. -/
theorem fullEMLClosure_closed_sub_pos (x y : ℝ) (hx_pos : 0 < x)
    (hx : x ∈ fullEMLClosure {1}) (hy : y ∈ fullEMLClosure {1}) :
    x - y ∈ fullEMLClosure {1} := by
  have : EMLd (Real.log x) (Real.exp y) = x - y := by
    simp [EMLd, Real.exp_log hx_pos, Real.log_exp]
  rw [← this]
  exact fullEMLClosure_closed_EMLd {1} _ _
    (fullEMLClosure_closed_log x hx) (fullEMLClosure_closed_exp y hy)

/-! ### Natural numbers and integers in the closure -/

/-- All natural numbers are in the full EML closure of `{1}`.
    The proof proceeds by induction, using the identity
    `n + 1 = exp(1) - (1 - (n - (exp(1) - 2)))` for `n ≥ 1`. -/
theorem fullEMLClosure_nat (n : ℕ) : (n : ℝ) ∈ fullEMLClosure {1} := by
  induction n with
  | zero => simpa using fullEMLClosure_zero
  | succ n ih =>
    by_cases hn : n ≥ 1
    · have h_e_minus_one : Real.exp 1 - 1 ∈ fullEMLClosure {1} :=
        fullEMLClosure_closed_sub_pos (Real.exp 1) 1 (by positivity)
          fullEMLClosure_exp_one fullEMLClosure_one
      have h_e_minus_two : Real.exp 1 - 2 ∈ fullEMLClosure {1} := by
        have : Real.exp 1 - 2 = (Real.exp 1 - 1) - 1 := by ring
        rw [this]
        exact fullEMLClosure_closed_sub_pos _ _ (by nlinarith [Real.add_one_le_exp (1 : ℝ)])
          h_e_minus_one fullEMLClosure_one
      have h_sub : (n : ℝ) - (Real.exp 1 - 2) ∈ fullEMLClosure {1} :=
        fullEMLClosure_closed_sub_pos n (Real.exp 1 - 2) (by positivity) ih h_e_minus_two
      have h_reflect : 1 - ((n : ℝ) - (Real.exp 1 - 2)) ∈ fullEMLClosure {1} :=
        fullEMLClosure_closed_one_minus _ h_sub
      convert fullEMLClosure_closed_sub_pos (Real.exp 1)
        (1 - ((n : ℝ) - (Real.exp 1 - 2))) (Real.exp_pos 1)
        fullEMLClosure_exp_one h_reflect using 1
      push_cast; ring
    · interval_cases n; norm_num; exact fullEMLClosure_one

/-- `exp(n)` is in the full closure for all natural numbers `n`. -/
theorem fullEMLClosure_exp_nat (n : ℕ) : Real.exp (n : ℝ) ∈ fullEMLClosure {1} :=
  fullEMLClosure_closed_exp n (fullEMLClosure_nat n)

/-- All integers are in the full EML closure of `{1}`.
    Negative integers are obtained via `-(n+1) = 1 - (n+2)`. -/
theorem fullEMLClosure_int (n : ℤ) : (n : ℝ) ∈ fullEMLClosure {1} := by
  cases n with
  | ofNat k => exact_mod_cast fullEMLClosure_nat k
  | negSucc k =>
    convert fullEMLClosure_closed_one_minus (↑(k + 1 + 1)) (fullEMLClosure_nat _) using 1
    norm_num

/-! ### Addition closure -/

/-- The full EML closure of `{1}` is closed under addition.
    For `a, b` in the closure, choose `N` large enough so `exp(N) > a` and `exp(N) > b`.
    Then `a + b = exp(N) - ((exp(N) - a) - b)`, using three subtractions from positive
    elements. -/
theorem fullEMLClosure_closed_add (x y : ℝ)
    (hx : x ∈ fullEMLClosure {1}) (hy : y ∈ fullEMLClosure {1}) :
    x + y ∈ fullEMLClosure {1} := by
  obtain ⟨N, hNx, hNy⟩ : ∃ N : ℕ, Real.exp N > x ∧ Real.exp N > y := by
    exact ⟨⌊x⌋₊ + ⌊y⌋₊ + 1,
      by push_cast; linarith [Nat.lt_floor_add_one x,
        Real.add_one_le_exp (⌊x⌋₊ + ⌊y⌋₊ + 1)],
      by push_cast; linarith [Nat.lt_floor_add_one y,
        Real.add_one_le_exp (⌊x⌋₊ + ⌊y⌋₊ + 1)]⟩
  have h_sum : x + y = Real.exp N - ((Real.exp N - x) - y) := by ring
  rw [h_sum]
  have hN_mem := fullEMLClosure_exp_nat N
  have h1 : Real.exp ↑N - x ∈ fullEMLClosure {1} :=
    fullEMLClosure_closed_sub_pos _ _ (by positivity) hN_mem hx
  have h2 : Real.exp ↑N - x - y ∈ fullEMLClosure {1} :=
    fullEMLClosure_closed_sub_pos _ _ (by linarith) h1 hy
  exact fullEMLClosure_closed_sub_pos _ _ (by positivity) hN_mem h2

/-! ### Irrationality and key membership -/

/-- `e - 2` is irrational (since `e` is irrational and 2 is rational). -/
theorem irrational_e_minus_two : Irrational (Real.exp 1 - 2) :=
  e_irrational.sub_ratCast 2

/-- `e - 2` is in the full EML closure. -/
theorem fullEMLClosure_e_minus_two : Real.exp 1 - 2 ∈ fullEMLClosure {1} :=
  fullEMLClosure_closed_sub_pos (Real.exp 1) 2 (Real.exp_pos 1)
    fullEMLClosure_exp_one (fullEMLClosure_nat 2)

/-! ## Density Theorem

The full EML closure of `{1}` is dense in `ℝ`. The closure contains the additive
subgroup generated by `{1, e-2}`. Since `e-2` is irrational, this subgroup is not
cyclic, and by Kronecker's theorem (`AddSubgroup.dense_or_cyclic`) it must be dense.
-/

/-- The additive subgroup generated by 1 and `e-2` is contained in the full EML closure:
    every integer linear combination `m + n(e-2)` belongs to `fullEMLClosure {1}`. -/
theorem fullEMLClosure_contains_subgroup :
    ∀ m n : ℤ, (m : ℝ) + n * (Real.exp 1 - 2) ∈ fullEMLClosure {1} := by
  have h_mul : ∀ n : ℤ, n * (Real.exp 1 - 2) ∈ fullEMLClosure {1} := by
    intro n
    induction n using Int.induction_on with
    | zero => simpa using fullEMLClosure_zero
    | succ k ih =>
      convert fullEMLClosure_closed_add _ _ ih fullEMLClosure_e_minus_two using 1
      push_cast; ring
    | pred k ih =>
      have h_neg : -(Real.exp 1 - 2) ∈ fullEMLClosure {1} := by
        convert fullEMLClosure_closed_one_minus _
          (fullEMLClosure_closed_add _ _ fullEMLClosure_e_minus_two fullEMLClosure_one) using 1
        ring
      convert fullEMLClosure_closed_add _ _ ih h_neg using 1
      push_cast; ring
  exact fun m n => fullEMLClosure_closed_add _ _ (fullEMLClosure_int m) (h_mul n)

/-- **Main Theorem**: The full EML closure of `{1}` is dense in `ℝ`.

From a single seed value and a single binary operation, the EML closure generates
a dense subset of the reals. The proof shows that the closure contains the additive
subgroup `{m + n(e-2) : m, n ∈ ℤ}`, which is dense by Kronecker's theorem (since
`e - 2` is irrational, the subgroup is non-cyclic, hence dense in `ℝ`). -/
theorem fullEMLClosure_dense : Dense (fullEMLClosure {(1 : ℝ)}) := by
  -- The set {m + n*(e-2) : m, n ∈ ℤ} is dense in ℝ because e-2 is irrational.
  have h_dense : Dense {x : ℝ | ∃ m n : ℤ, x = m + n * (Real.exp 1 - 2)} := by
    have h_sub_dense : Dense (AddSubgroup.closure {1, Real.exp 1 - 2} : Set ℝ) := by
      have h_not_cyclic : ¬∃ a : ℝ,
          AddSubgroup.closure {1, Real.exp 1 - 2} = AddSubgroup.closure {a} := by
        rintro ⟨a, ha⟩
        obtain ⟨k, hk⟩ : ∃ k : ℤ, 1 = k * a := by
          have := AddSubgroup.mem_closure_singleton.mp
            (ha ▸ AddSubgroup.subset_closure (Set.mem_insert _ _))
          grind +splitImp
        obtain ⟨m, hm⟩ : ∃ m : ℤ, Real.exp 1 - 2 = m * a := by
          have := AddSubgroup.mem_closure_singleton.mp
            (ha ▸ AddSubgroup.subset_closure (Set.mem_insert_of_mem _ (Set.mem_singleton _)))
          exact ⟨this.choose, by simpa [mul_comm] using this.choose_spec.symm⟩
        have : Real.exp 1 - 2 = m / k := by grind
        exact irrational_e_minus_two ⟨m / k, by push_cast; linarith⟩
      exact (AddSubgroup.dense_or_cyclic _).resolve_right h_not_cyclic
    exact h_sub_dense.mono fun x hx => by
      obtain ⟨m, n, h⟩ := AddSubgroup.mem_closure_pair.mp hx
      exact ⟨m, n, h ▸ by ring⟩
  exact h_dense.mono fun x hx => by
    obtain ⟨m, n, rfl⟩ := hx
    exact fullEMLClosure_contains_subgroup m n

end