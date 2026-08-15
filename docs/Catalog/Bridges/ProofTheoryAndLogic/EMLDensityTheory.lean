import Mathlib

/-!
# EML Density Theory: The Exp-Minus-Log Operation and its Algebraic Closure

## Overview

We study the **EML operation** `EMLd(a, b) = exp(a) - log(b)`, a simple binary operation
on the reals that unifies exponentiation and logarithm into a single algebraic primitive.
Despite its elementary definition, the EML operation possesses a rich algebraic structure:
it satisfies a log-splitting identity, recovers both `exp` and `log` as special cases,
and exhibits involutory behavior under composition.

## Main Results

1. **Algebraic identities**: The EML operation satisfies a variety of clean identities
   connecting it to `exp`, `log`, and basic arithmetic.

2. **Closure theory**: Starting from a seed set `S ⊆ ℝ`, iterated application of EML
   generates a closure `EMLClosure n S` that is monotonically increasing in depth.
   The full closure is closed under EML.

3. **Irrationality of e**: We give a self-contained proof that `e = exp(1)` is irrational,
   using the classical Fourier-style argument based on the Taylor series of `e`.

4. **Transcendence generation**: We show that starting from `{1}`, the EML closure at
   depth 1 already contains the transcendental number `e`, and at depth 2 contains
   values like `e - 1` and `e^e`.

## References

- The irrationality proof follows Fourier's classical argument (1815).
- The EML framework is motivated by connections between exponential and logarithmic
  functions in transcendental number theory and computability.
-/

noncomputable section

open Real Set

/-! ## Definition of the EML Operation -/

/-- The **EML (Exp Minus Log) operation**: `EMLd(a, b) = exp(a) - log(b)`.
This operation unifies exponentiation and logarithm into a single binary primitive. -/
def EMLd (a b : ℝ) : ℝ := exp a - log b

/-- EML closure at depth `n`: starting from seed set `S`, apply `EMLd` iteratively.
At each step, we adjoin all values `EMLd a b` where `a, b` are already in the closure. -/
def EMLClosure : ℕ → Set ℝ → Set ℝ
  | 0, S => S
  | n + 1, S => EMLClosure n S ∪ {z | ∃ a ∈ EMLClosure n S, ∃ b ∈ EMLClosure n S, z = EMLd a b}

/-- The **full EML closure**: the union of all finite-depth closures.
This is the smallest set containing `S` and closed under the EML operation. -/
def fullEMLClosure (S : Set ℝ) : Set ℝ := ⋃ n, EMLClosure n S

/-! ## Basic Properties of EML Closure -/

/-- The seed value 1 belongs to the EML closure at depth 0. -/
theorem one_in_closure : (1 : ℝ) ∈ EMLClosure 0 {1} := by
  simp [EMLClosure]

/-- EML closure is monotone in depth: increasing the depth by one only adds elements. -/
theorem EMLClosure_mono (S : Set ℝ) (n : ℕ) :
    EMLClosure n S ⊆ EMLClosure (n + 1) S := by
  intro x hx
  simp [EMLClosure]
  exact Or.inl hx

/-
EML closure is monotone: if `n ≤ m` then `EMLClosure n S ⊆ EMLClosure m S`.
-/
theorem EMLClosure_mono_le (S : Set ℝ) {n m : ℕ} (h : n ≤ m) :
    EMLClosure n S ⊆ EMLClosure m S := by
  exact monotone_nat_of_le_succ ( fun n => EMLClosure_mono S n ) h

/-- Any finite-depth closure is contained in the full closure. -/
theorem EMLClosure_subset_full (S : Set ℝ) (n : ℕ) :
    EMLClosure n S ⊆ fullEMLClosure S := by
  intro x hx
  exact mem_iUnion.mpr ⟨n, hx⟩

/-
The full EML closure is closed under the EML operation.
-/
theorem fullEMLClosure_closed (S : Set ℝ) (a b : ℝ)
    (ha : a ∈ fullEMLClosure S) (hb : b ∈ fullEMLClosure S) :
    EMLd a b ∈ fullEMLClosure S := by
  obtain ⟨ n, hn ⟩ := Set.mem_iUnion.mp ha;
  obtain ⟨ m, hm ⟩ := Set.mem_iUnion.mp hb;
  -- By definition of EML closure, we have that EMLd a b ∈ EMLClosure (max n m + 1) S.
  have h_emld : EMLd a b ∈ EMLClosure (max n m + 1) S := by
    exact Set.mem_union_right _ ⟨ a, EMLClosure_mono_le _ ( le_max_left _ _ ) hn, b, EMLClosure_mono_le _ ( le_max_right _ _ ) hm, rfl ⟩;
  exact Set.mem_iUnion.mpr ⟨ _, h_emld ⟩

/-! ## Algebraic Identities -/

/-- **Log-splitting**: `EML(x, y·z) = EML(x, y) - ln(z)` for `y, z > 0`.
This identity shows how EML interacts with multiplication in the second argument. -/
theorem EMLd_log_split (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    EMLd x (y * z) = EMLd x y - log z := by
  simp [EMLd, log_mul hy.ne' hz.ne']; ring

/-- **Exp recovery**: `EML(x, 1) = exp(x)`.
Setting the second argument to 1 recovers the exponential function. -/
theorem EMLd_exp (x : ℝ) : EMLd x 1 = exp x := by
  simp [EMLd, log_one]

/-- **Log recovery (negated)**: `EML(0, x) = 1 - ln(x)`.
Setting the first argument to 0 gives a "reflected logarithm". -/
theorem EMLd_one_minus_log (x : ℝ) : EMLd 0 x = 1 - log x := by
  simp [EMLd]

/-- **Interval mapping**: `EML(0, ·)` maps `(1, e)` into `(0, 1)`.
This shows the reflected logarithm contracts the interval `(1, e)` to `(0, 1)`. -/
theorem EMLd_maps_to_unit_interval (x : ℝ) (hx1 : 1 < x) (hxe : x < exp 1) :
    0 < EMLd 0 x ∧ EMLd 0 x < 1 := by
  constructor
  · simp [EMLd]
    have : log x < 1 := by
      rwa [← log_exp 1, log_lt_log_iff (by linarith) (exp_pos 1)]
    linarith
  · simp [EMLd]
    linarith [log_pos hx1]

/-- **Amplification**: `EML(x, 1) > 1` for all `x > 0`.
The exponential always exceeds 1 for positive inputs. -/
theorem EMLd_amplifies (x : ℝ) (hx : 0 < x) :
    EMLd x 1 > 1 := by
  simp [EMLd, log_one]
  linarith [add_one_le_exp x]

/-- **Scaled inversion**: `EML(EML(0, x), 1) = e/x` for `x > 0`.
Composing EML with itself in a specific pattern produces `e/x`. -/
theorem EMLd_inv_scaled (x : ℝ) (hx : 0 < x) :
    EMLd (EMLd 0 x) 1 = exp 1 / x := by
  simp [EMLd, log_one, exp_sub, exp_log hx]

/-- **Logarithm recovery**: `EML(0, exp(EML(0, x))) = ln(x)`.
The EML operation can recover the natural logarithm through composition. -/
theorem EMLd_recovers_ln (x : ℝ) :
    EMLd 0 (exp (EMLd 0 x)) = log x := by
  simp [EMLd, log_exp]

/-- **Double negation / involution**: `EML(0, exp(EML(0, exp(x)))) = x`.
Two applications of the `EML(0, exp(·))` pattern yield the identity. -/
theorem EMLd_double_neg (x : ℝ) :
    EMLd 0 (exp (EMLd 0 (exp x))) = x := by
  simp [EMLd, log_exp]

/-- **Shift identity**: `EML(x + c, 1) = exp(c) · exp(x)`.
Translation in the first argument corresponds to scaling in the output. -/
theorem EMLd_shift (x c : ℝ) :
    EMLd (x + c) 1 = exp c * exp x := by
  simp [EMLd, log_one, exp_add, mul_comm]

/-! ## Transcendence Generation

Starting from the seed set `{1}`, the EML closure quickly generates
transcendental numbers and interesting constants.
-/

/-
`e = exp(1)` is in the EML closure of `{1}` at depth 1.
This is because `EMLd(1, 1) = exp(1) - log(1) = e - 0 = e`.
-/
theorem e_in_closure : exp 1 ∈ EMLClosure 1 {1} := by
  exact Or.inr ⟨ 1, by tauto, 1, by tauto, by norm_num [ EMLd ] ⟩

/-
`e - 1` is in the EML closure of `{1}` at depth 2.
This follows from `EMLd(1, e) = exp(1) - log(e) = e - 1`.
-/
theorem e_minus_one_in_closure : exp 1 - 1 ∈ EMLClosure 2 {1} := by
  -- By definition of EMLClosure, we know that 1 and exp 1 are in EMLClosure 1 {1}.
  have h1 : 1 ∈ EMLClosure 1 {1} := by
    exact EMLClosure_mono _ _ one_in_closure
  have h2 : Real.exp 1 ∈ EMLClosure 1 {1} := by
    exact e_in_closure
  exact Or.inr ⟨ _, h1, _, h2, by norm_num [ EMLd ] ⟩

/-
`e^e` is in the EML closure of `{1}` at depth 2.
This follows from `EMLd(e, 1) = exp(e) - log(1) = e^e`.
-/
theorem exp_e_in_closure : exp (exp 1) ∈ EMLClosure 2 {1} := by
  refine' Set.mem_union_right _ _;
  use Real.exp 1, by
    exact e_in_closure, 1, by
    exact Set.mem_union_left _ ( Set.mem_singleton _ );
  unfold EMLd; norm_num

/-! ## Irrationality of e

We prove that `e = exp(1)` is irrational using Fourier's classical argument:
if `e = p/q` for positive integers `p, q`, then `q! · e` can be split into an integer
part plus a tail series that is strictly between 0 and 1, giving a contradiction.
-/

/-
**Irrationality of e**: The number `e = exp(1)` is irrational.

This is proved via the classical Fourier argument: assuming `e = p/q`, we show that
`q! · e` equals an integer plus a remainder strictly between 0 and 1, which is impossible.
-/
theorem e_irrational : Irrational (exp 1) := by
  by_contra h_contra;
  obtain ⟨q, hq⟩ : ∃ q : ℚ, Real.exp 1 = q := by
    simpa [ eq_comm ] using Classical.not_not.1 h_contra;
  -- Multiply both sides of the equation by $n!$ to get $n! \cdot e = \sum_{k=0}^{n} \frac{n!}{k!} + \sum_{k=n+1}^{\infty} \frac{n!}{k!}$.
  have h_mul : ∀ n : ℕ, (Nat.factorial n) * Real.exp 1 = ∑ k ∈ Finset.range (n + 1), (Nat.factorial n : ℝ) / (Nat.factorial k : ℝ) + ∑' k : ℕ, (Nat.factorial n : ℝ) / (Nat.factorial (n + 1 + k) : ℝ) := by
    have h_mul : ∀ n : ℕ, (Nat.factorial n) * Real.exp 1 = ∑ k ∈ Finset.range (n + 1), (Nat.factorial n : ℝ) / (Nat.factorial k : ℝ) + ∑' k : ℕ, (Nat.factorial n : ℝ) / (Nat.factorial (n + 1 + k) : ℝ) := by
      intro n
      have h_series : Real.exp 1 = ∑' k : ℕ, (1 : ℝ) / (Nat.factorial k : ℝ) := by
        simp +decide [ Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div ]
      rw [ h_series, ← Summable.sum_add_tsum_nat_add ];
      rw [ mul_add, Finset.mul_sum _ _ _, ← tsum_mul_left ];
      exacts [ by congr <;> ext k <;> ring, by simpa using Real.summable_pow_div_factorial 1 ];
    assumption;
  -- Choose $n$ such that $n! \cdot e$ is an integer.
  obtain ⟨n, hn⟩ : ∃ n : ℕ, (Nat.factorial n : ℝ) * q ∈ Set.range (fun m : ℤ => m : ℤ → ℝ) ∧ n ≥ q.den := by
    refine' ⟨ q.den, _, le_rfl ⟩;
    use q.num * Nat.factorial q.den / q.den;
    norm_num [ mul_comm, Rat.cast_def ];
    rw [ Int.cast_div ] <;> norm_num;
    · ring;
    · exact dvd_mul_of_dvd_right ( mod_cast Nat.dvd_factorial ( Nat.pos_of_ne_zero q.pos.ne' ) ( by linarith ) ) _;
  -- The second sum is strictly between 0 and 1.
  have h_second_sum : 0 < ∑' k : ℕ, (Nat.factorial n : ℝ) / (Nat.factorial (n + 1 + k) : ℝ) ∧ ∑' k : ℕ, (Nat.factorial n : ℝ) / (Nat.factorial (n + 1 + k) : ℝ) < 1 := by
    -- The series $\sum_{k=0}^{\infty} \frac{n!}{(n+1+k)!}$ is a geometric series with the first term $\frac{1}{n+1}$ and common ratio $\frac{1}{n+2}$.
    have h_geo_series : ∑' k : ℕ, (Nat.factorial n : ℝ) / (Nat.factorial (n + 1 + k) : ℝ) ≤ ∑' k : ℕ, (1 : ℝ) / (n + 1) * (1 / (n + 2)) ^ k := by
      refine' Summable.tsum_le_tsum _ _ _;
      · field_simp;
        intro i; rw [ mul_comm ] ; induction i <;> simp_all +decide [ Nat.factorial, pow_succ' ];
        field_simp at *;
        nlinarith [ ( by positivity : 0 < ( n + 1 : ℝ ) * n.factorial * ( n + 2 ) ^ ‹_› ) ];
      · exact Summable.mul_left _ <| by simpa using Summable.comp_injective ( Real.summable_pow_div_factorial 1 ) <| by intros a b; aesop;
      · exact Summable.mul_left _ <| summable_geometric_of_lt_one ( by positivity ) <| by rw [ div_lt_iff₀ ] <;> linarith;
    refine' ⟨ _, lt_of_le_of_lt h_geo_series _ ⟩;
    · refine' Summable.tsum_pos ..;
      any_goals intros; positivity;
      · exact Summable.mul_left _ <| by simpa using Summable.comp_injective ( Real.summable_pow_div_factorial 1 ) <| by intros a b; aesop;
      · exact n;
    · rw [ tsum_mul_left, tsum_geometric_of_lt_one ( by positivity ) ( by rw [ div_lt_iff₀ ] <;> linarith ) ];
      field_simp;
      rw [ div_lt_iff₀ ] <;> nlinarith only [ show ( n : ℝ ) ≥ 1 by norm_cast; linarith [ q.pos ] ];
  -- The first sum is an integer.
  have h_first_sum : ∃ m : ℤ, ∑ k ∈ Finset.range (n + 1), (Nat.factorial n : ℝ) / (Nat.factorial k : ℝ) = m := by
    use ∑ k ∈ Finset.range (n + 1), (Nat.factorial n : ℤ) / (Nat.factorial k : ℤ);
    push_cast;
    exact Finset.sum_congr rfl fun x hx => by rw [ Int.cast_div ( mod_cast Nat.factorial_dvd_factorial ( Finset.mem_range_succ_iff.mp hx ) ) ( by positivity ) ] ; push_cast; ring;
  obtain ⟨ m, hm ⟩ := h_first_sum; obtain ⟨ m', hm' ⟩ := hn.1; simp_all +decide ;
  exact False.elim <| by linarith [ show ( m' : ℝ ) ≤ m by exact_mod_cast Int.le_of_lt_add_one <| by { rw [ ← @Int.cast_lt ℝ ] ; push_cast; linarith } ] ;

/-
Since `e` is irrational and is generated by EML from `{1}`, the EML closure
of the rationals contains irrational numbers. This demonstrates the "transcendence
generating" power of the EML operation.
-/
theorem EML_generates_irrational :
    ∃ x ∈ EMLClosure 1 {(1 : ℝ)}, Irrational x := by
  exact ⟨ _, e_in_closure, e_irrational ⟩

end