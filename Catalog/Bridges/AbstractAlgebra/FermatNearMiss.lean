/-
  # Foundational Theory of Fermat Near-Misses

  This module develops the theory of Fermat near-misses: triples (a, b, c)
  where |aⁿ + bⁿ − cⁿ| is small relative to cⁿ. The key results are:

  1. **Mixed-term decomposition**: The Fermat defect of "sum triples"
     (a, b, a+b) is entirely controlled by binomial cross-terms.

  2. **Cross-term superadditivity**: For n ≥ 2 and positive a, b,
     we have aⁿ + bⁿ < (a+b)ⁿ — creating a one-sided barrier.

  3. **Power gap sandwich**: n·cⁿ⁻¹ ≤ (c+1)ⁿ − cⁿ ≤ n·(c+1)ⁿ⁻¹,
     tightly bounding consecutive power differences.

  4. **Near-miss quality measure**: A normalized measure of how close
     a triple comes to satisfying Fermat's equation.
-/
import Mathlib

open Finset BigOperators Nat

/-! ## Core Definitions -/

/-- The Fermat defect of a triple (a, b, c) at exponent n is aⁿ + bⁿ − cⁿ.
    When this is zero, (a, b, c) satisfies Fermat's equation. -/
def fermatDefect (a b c : ℤ) (n : ℕ) : ℤ := a ^ n + b ^ n - c ^ n

/-- A Fermat near-miss is a triple (a, b, c) of positive integers where
    the absolute Fermat defect is nonzero but bounded by εcⁿ. -/
structure FermatNearMiss (n : ℕ) where
  a : ℕ+
  b : ℕ+
  c : ℕ+
  defect_nonzero : fermatDefect (a : ℤ) (b : ℤ) (c : ℤ) n ≠ 0
  quality : ℚ  -- |defect| / c^n as a rational approximation

/-- The binomial cross-term sum: the "extra" terms beyond aⁿ + bⁿ
    in the expansion of (a + b)ⁿ. Equals Σ_{k=1}^{n-1} C(n,k) aᵏ bⁿ⁻ᵏ. -/
noncomputable def crossTermSum (a b : ℕ) (n : ℕ) : ℕ :=
  ∑ k ∈ Finset.Icc 1 (n - 1), n.choose k * a ^ k * b ^ (n - k)

/-! ## The Mixed-Term Decomposition

The binomial theorem gives (a + b)ⁿ = aⁿ + bⁿ + cross-terms.
This means the Fermat defect of a sum triple (a, b, a+b) equals
minus the cross-term sum. -/

/-
**Mixed-Term Decomposition (Integer version)**:
    (a + b)ⁿ = aⁿ + bⁿ + Σ_{k=1}^{n-1} C(n,k) aᵏ bⁿ⁻ᵏ in ℤ.
    Equivalently, the Fermat defect of (a, b, a+b) is the negative
    of the binomial cross-term sum.
-/
theorem mixed_term_decomposition (a b : ℤ) (n : ℕ) (hn : 1 ≤ n) :
    (a + b) ^ n = a ^ n + b ^ n +
      ∑ k ∈ Finset.Icc 1 (n - 1), (n.choose k : ℤ) * a ^ k * b ^ (n - k) := by
  rw [ add_pow ];
  erw [ Finset.sum_Ico_eq_sub _ ] <;> norm_num [ mul_assoc, mul_comm, mul_left_comm, Finset.sum_range_succ ];
  cases n <;> simp_all +decide [ add_comm, Finset.sum_range_succ ]

/-! ## Cross-Term Superadditivity

For n ≥ 2, the function x ↦ xⁿ is strictly superadditive on positive reals
(and positive naturals), meaning aⁿ + bⁿ < (a+b)ⁿ. -/

/-
**Superadditivity of Powers**: For n ≥ 2 and positive a, b,
    aⁿ + bⁿ < (a + b)ⁿ. This is the fundamental one-sided barrier
    for Fermat near-misses of sum triples.
-/
theorem power_superadditive (a b : ℕ) (n : ℕ) (ha : 0 < a) (hb : 0 < b)
    (hn : 2 ≤ n) : a ^ n + b ^ n < (a + b) ^ n := by
  induction hn <;> simp_all +decide [ add_mul, pow_succ' ] ; nlinarith [ pow_pos ha ‹_›, pow_pos hb ‹_› ];
  gcongr <;> linarith

/-
Sum-triple defect is always negative: for positive a, b and n ≥ 2,
    aⁿ + bⁿ − (a+b)ⁿ < 0.
-/
theorem sum_triple_defect_negative (a b : ℕ) (n : ℕ) (ha : 0 < a) (hb : 0 < b)
    (hn : 2 ≤ n) : fermatDefect (a : ℤ) (b : ℤ) ((a + b : ℕ) : ℤ) n < 0 := by
  exact sub_neg_of_lt ( mod_cast power_superadditive a b n ha hb hn )

/-! ## Power Gap Sandwich Theorem

The difference (c+1)ⁿ − cⁿ is tightly sandwiched between
n·cⁿ⁻¹ and n·(c+1)ⁿ⁻¹. This governs the spacing of perfect
powers and hence the possible values of Fermat defects. -/

/-
**Power Gap Lower Bound**: n · cⁿ⁻¹ ≤ (c+1)ⁿ − cⁿ.
    This follows from the binomial expansion: (c+1)ⁿ − cⁿ = Σ_{k=0}^{n-1} C(n,k)cᵏ ≥ n·cⁿ⁻¹.
-/
theorem power_gap_lower_bound (c : ℕ) (n : ℕ) (hn : 1 ≤ n) :
    n * c ^ (n - 1) ≤ (c + 1) ^ n - c ^ n := by
  rcases n <;> simp_all +decide [ Nat.succ_eq_add_one, add_pow, mul_comm, Finset.sum_range_succ ]

/-
**Power Gap Upper Bound**: (c+1)ⁿ − cⁿ ≤ n · (c+1)ⁿ⁻¹.
    This follows because C(n,k) ≤ n · C(n-1,k) for k ≤ n-1,
    so the binomial expansion of (c+1)ⁿ − cⁿ is termwise bounded
    by n times the expansion of (c+1)ⁿ⁻¹.
-/
theorem power_gap_upper_bound (c : ℕ) (n : ℕ) (hn : 1 ≤ n) :
    (c + 1) ^ n - c ^ n ≤ n * (c + 1) ^ (n - 1) := by
  induction hn <;> simp_all +decide [ Nat.pow_succ' ];
  cases ‹1 ≤ _› <;> simp_all +decide [ Nat.succ_mul, pow_succ' ] ; nlinarith [ pow_pos ( Nat.succ_pos c ) ‹_› ];
  nlinarith [ pow_pos ( Nat.succ_pos c ) ‹_›, pow_le_pow_left' ( Nat.le_succ c ) ‹_› ]

/-- **Power Gap Sandwich**: combining both bounds. -/
theorem power_gap_sandwich (c : ℕ) (n : ℕ) (hn : 1 ≤ n) :
    n * c ^ (n - 1) ≤ (c + 1) ^ n - c ^ n ∧
    (c + 1) ^ n - c ^ n ≤ n * (c + 1) ^ (n - 1) :=
  ⟨power_gap_lower_bound c n hn, power_gap_upper_bound c n hn⟩

/-! ## Defect Monotonicity

As c increases past (a^n + b^n)^{1/n}, the defect a^n + b^n - c^n
becomes more negative. This means there is at most one "closest"
integer c for any given (a, b, n). -/

/-
The integer Fermat defect is strictly decreasing in c (for positive c and n ≥ 1).
-/
theorem fermat_defect_strict_anti_c (a b : ℤ) (c : ℕ) (n : ℕ) (hn : 1 ≤ n) (hc : 0 < c) :
    fermatDefect a b ((c : ℤ) + 1) n < fermatDefect a b (c : ℤ) n := by
  exact sub_lt_sub_left ( pow_lt_pow_left₀ ( by linarith ) ( by linarith ) ( by linarith ) ) _

/-! ## Optimal Approximant Uniqueness

For any (a, b, n) with n ≥ 1, the sign change of the defect occurs within
a window of width at most 2. -/

/-
For a, b and n ≥ 1, if the defect at c₁ is ≤ 0 and at c₂ is ≥ 0,
    with c₁ ≤ c₂, then c₂ ≤ c₁ + 1. That is, the sign change happens
    between consecutive integers.
-/
theorem optimal_approx_at_most_two (a b : ℤ) (n : ℕ) (c₁ c₂ : ℕ)
    (hn : 1 ≤ n) (hc₁ : 0 < c₁) (hc₂ : 0 < c₂)
    (h₁ : fermatDefect a b (c₁ : ℤ) n ≤ 0)
    (h₂ : 0 ≤ fermatDefect a b (c₂ : ℤ) n)
    (hle : c₁ ≤ c₂) :
    c₂ ≤ c₁ + 1 := by
  contrapose! h₂; simp_all +decide [ fermatDefect ] ;
  exact h₁.trans_lt ( mod_cast Nat.pow_lt_pow_left ( by linarith ) ( by linarith ) )

/-! ## Conjecture: Near-Miss Exponent Gap

**Falsifiable Conjecture**: For n ≥ 3 and coprime positive integers a, b, c,
|aⁿ + bⁿ − cⁿ| ≥ c^{n-2}.

This is testable: compute the ratio |aⁿ + bⁿ − cⁿ| / c^{n-2} for all
coprime triples with small c. If any ratio < 1, the conjecture fails.

Note: For n = 3, this would say |a³ + b³ − c³| ≥ c, which is related to
(but weaker than) effective forms of the ABC conjecture. -/

/-- The near-miss exponent gap conjecture predicts that for n ≥ 3 and
    coprime a, b, c, the defect grows at least as c^{n-2}. -/
def NearMissExponentGapConjecture : Prop :=
  ∀ (a b c : ℕ), 0 < a → 0 < b → 0 < c → Nat.Coprime a c → Nat.Coprime b c →
  ∀ n, 3 ≤ n → fermatDefect (a : ℤ) (b : ℤ) (c : ℤ) n ≠ 0 →
  (c : ℤ) ^ (n - 2) ≤ |fermatDefect (a : ℤ) (b : ℤ) (c : ℤ) n|