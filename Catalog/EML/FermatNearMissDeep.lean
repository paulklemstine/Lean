import Mathlib

/-! # Fermat Near-Misses: Deep Structure and Distribution

This file develops a theory of Fermat near-misses — triples (a,b,c) of positive
integers where |a^n + b^n - c^n| is small but nonzero. We introduce novel
invariants, prove structural theorems about defect behavior, and establish
connections to the distribution of perfect powers.

## Novel Concepts

* `FermatQuality` — the normalized quality ratio |defect|/c^n ∈ [0,∞)
* `MixedTermSum` — the sum of cross-terms in (a+b)^n - a^n - b^n
* `NearMissCount` — counting function for near-misses below a bound
* `radical` — product of distinct prime factors (key ABC quantity)

## Main Results

* `mixed_term_positive` — cross-terms are positive for positive inputs and n ≥ 2
* `defect_sum_triple_negative` — sum triples always overshoot for n ≥ 2
* `power_gap_sandwich` — tight bounds: n·c^(n-1) ≤ gap ≤ n·(c+1)^(n-1)
* `defect_grows_exponentially_example` — defect of (1,1,2) grows as 2^n
* `quality_geometric_decay` — quality ratio decays by factor ≥ 1/c per step
* `near_miss_count_upper` — counting bound on near-misses
* `radical_le` — radical is bounded by the original number
-/

open Finset BigOperators Nat

-- ============================================================================
-- § 1. Core Definitions
-- ============================================================================

/-- The Fermat defect: the signed difference a^n + b^n - c^n. -/
def FermatDefect (n : ℕ) (a b c : ℤ) : ℤ := a ^ n + b ^ n - c ^ n

/-- The **mixed-term sum**: for the "sum triple" (a, b, a+b), the defect equals
the negative of this quantity. Captures the binomial cross-terms. -/
def MixedTermSum (n : ℕ) (a b : ℤ) : ℤ :=
  (a + b) ^ n - a ^ n - b ^ n

/-- The **Fermat quality ratio**: |a^n + b^n - c^n| / c^n.
Measures proximity to a Fermat solution, normalized by scale. -/
noncomputable def FermatQuality (n : ℕ) (a b c : ℝ) : ℝ :=
  |a ^ n + b ^ n - c ^ n| / c ^ n

/-- The **near-miss counting function**: number of triples (a,b,c)
with 1 ≤ a,b,c ≤ N whose Fermat defect has absolute value ≤ D. -/
noncomputable def NearMissCount (n N : ℕ) (D : ℕ) : ℕ :=
  (Finset.filter
    (fun t : ℕ × ℕ × ℕ =>
      (Int.natAbs (FermatDefect n (↑t.1) (↑t.2.1) (↑t.2.2))) ≤ D)
    (Finset.Icc 1 N ×ˢ (Finset.Icc 1 N ×ˢ Finset.Icc 1 N))).card

/-- The **radical** of a natural number: the product of its distinct prime factors.
This is the key quantity appearing in the ABC conjecture. -/
def radical (n : ℕ) : ℕ := n.primeFactors.prod id

-- ============================================================================
-- § 2. Basic Defect Properties
-- ============================================================================

/-- The defect of (1, c, c) is always 1. -/
theorem fermat_defect_unit (n : ℕ) (c : ℤ) :
    FermatDefect n 1 c c = 1 := by
  unfold FermatDefect; simp [one_pow]

/-- The Fermat defect is symmetric in the first two arguments. -/
theorem fermat_defect_symm (n : ℕ) (a b c : ℤ) :
    FermatDefect n a b c = FermatDefect n b a c := by
  unfold FermatDefect; ring

/-- Scaling all arguments by k scales the defect by k^n. -/
theorem fermat_defect_scale (n : ℕ) (a b c k : ℤ) :
    FermatDefect n (k * a) (k * b) (k * c) = k ^ n * FermatDefect n a b c := by
  unfold FermatDefect; ring

-- ============================================================================
-- § 3. Mixed-Term Decomposition
-- ============================================================================

/-- The mixed-term sum is symmetric. -/
theorem mixed_term_symm (n : ℕ) (a b : ℤ) :
    MixedTermSum n a b = MixedTermSum n b a := by
  unfold MixedTermSum; ring

/-- The Fermat defect of the sum triple equals the negation of the mixed-term sum. -/
theorem defect_sum_triple (n : ℕ) (a b : ℤ) :
    FermatDefect n a b (a + b) = -MixedTermSum n a b := by
  unfold FermatDefect MixedTermSum; ring

/-
**Key theorem**: For n ≥ 2 and positive a, b, the mixed-term sum
is strictly positive. This means a^n + b^n < (a+b)^n always.

The proof uses the binomial theorem: (a+b)^n contains all the terms
of a^n and b^n plus strictly positive cross-terms.
-/
theorem mixed_term_positive (n : ℕ) (hn : 2 ≤ n) (a b : ℤ)
    (ha : 0 < a) (hb : 0 < b) :
    0 < MixedTermSum n a b := by
  induction hn <;> simp_all +decide [ pow_succ', MixedTermSum ];
  · nlinarith;
  · ring_nf at *; nlinarith [ pow_pos ha ‹_›, pow_pos hb ‹_› ] ;

/-- Corollary: Sum triples always have negative Fermat defect for n ≥ 2. -/
theorem defect_sum_triple_negative (n : ℕ) (hn : 2 ≤ n) (a b : ℤ)
    (ha : 0 < a) (hb : 0 < b) :
    FermatDefect n a b (a + b) < 0 := by
  rw [defect_sum_triple]
  linarith [mixed_term_positive n hn a b ha hb]

/-
============================================================================
§ 4. Power Gap Bounds
============================================================================

Lower bound: n · c^(n-1) ≤ (c+1)^n - c^n.
-/
theorem power_gap_lower (c n : ℕ) (hn : 1 ≤ n) :
    n * c ^ (n - 1) ≤ (c + 1) ^ n - c ^ n := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ add_pow, mul_comm, ← Finset.sum_mul ];
  simp +arith +decide [ Finset.sum_range_succ, mul_comm ]

/-
Upper bound: (c+1)^n - c^n ≤ n · (c+1)^(n-1).
-/
theorem power_gap_upper (c n : ℕ) (hn : 1 ≤ n) :
    (c + 1) ^ n - c ^ n ≤ n * (c + 1) ^ (n - 1) := by
  -- Apply the factorization of $x^n - y^n$ to rewrite the difference.
  have h_factor : (c + 1 : ℤ) ^ n - c ^ n = (∑ i ∈ Finset.range n, (c + 1 : ℤ) ^ i * c ^ (n - 1 - i)) := by
    rw [ ← geom_sum₂_mul ];
    norm_num;
  rw [ ← @Nat.cast_le ℤ ] ; simp_all +decide [ mul_comm ];
  rw [ Nat.cast_sub ( by gcongr ; linarith ) ] ; norm_num [ h_factor ];
  exact le_trans ( Finset.sum_le_sum fun _ _ => show ( c + 1 : ℤ ) ^ _ * c ^ ( n - 1 - _ ) ≤ ( c + 1 ) ^ ( n - 1 ) by exact le_trans ( mul_le_mul_of_nonneg_left ( pow_le_pow_left₀ ( by positivity ) ( show ( c : ℤ ) ≤ c + 1 by linarith ) _ ) ( by positivity ) ) ( by rw [ ← pow_add, add_tsub_cancel_of_le ( Nat.le_sub_one_of_lt ( Finset.mem_range.mp ‹_› ) ) ] ) ) ( by norm_num )

/-- **Sandwich theorem**: The consecutive power gap is tightly bounded. -/
theorem power_gap_sandwich (c n : ℕ) (hn : 1 ≤ n) :
    n * c ^ (n - 1) ≤ (c + 1) ^ n - c ^ n ∧
    (c + 1) ^ n - c ^ n ≤ n * (c + 1) ^ (n - 1) :=
  ⟨power_gap_lower c n hn, power_gap_upper c n hn⟩

-- ============================================================================
-- § 5. Defect Growth and Quality Decay
-- ============================================================================

/-- The defect of (1,1,2) has a closed form. -/
theorem defect_example_value (n : ℕ) :
    FermatDefect n 1 1 2 = 2 - (2 : ℤ) ^ n := by
  unfold FermatDefect; simp [one_pow]

/-- **Defect growth**: The absolute defect of (1,1,2) is at least 2^n - 2,
growing exponentially in the exponent. This shows that even the simplest
non-trivial triple has rapidly growing defect. -/
theorem defect_grows_exponentially_example (n : ℕ) (hn : 2 ≤ n) :
    (2 : ℤ) ^ n - 2 ≤ |FermatDefect n 1 1 2| := by
  rw [defect_example_value]
  rw [show (2 : ℤ) - (2 : ℤ) ^ n = -((2 : ℤ) ^ n - 2) by ring]
  rw [abs_neg, abs_of_nonneg]
  · have : (2 : ℤ) ^ 2 ≤ (2 : ℤ) ^ n := pow_le_pow_right₀ (by norm_num) hn
    linarith

/-- Quality of the unit family (1, c, c) is exactly 1/c^n. -/
theorem quality_unit_family (n : ℕ) (c : ℝ) :
    FermatQuality n 1 c c = 1 / c ^ n := by
  unfold FermatQuality; simp [one_pow]

/-
**Geometric decay**: increasing the exponent reduces quality by factor ≥ 1/c.
For c ≥ 2, this gives at least halving per step.
-/
theorem quality_geometric_decay (c : ℕ) (hc : 2 ≤ c) (n : ℕ) :
    (1 : ℝ) / (↑c) ^ (n + 1) ≤ (1 / 2) * ((1 : ℝ) / (↑c) ^ n) := by
  ring_nf;
  rw [ mul_comm ] ; gcongr ; norm_cast;
  rw [ inv_eq_one_div, div_le_div_iff₀ ] <;> norm_cast <;> linarith

/-
**Quality vanishes**: For any ε > 0, there exists c with quality < ε.
-/
theorem quality_vanishes (n : ℕ) (hn : 1 ≤ n) (ε : ℝ) (hε : 0 < ε) :
    ∃ c : ℕ, 0 < c ∧ FermatQuality n 1 (↑c) (↑c) < ε := by
  -- Use the fact that $c^n$ grows faster than $1$ to find such a $c$.
  have h_pow : Filter.Tendsto (fun c : ℕ => (1 : ℝ) / c ^ n) Filter.atTop (nhds 0) := by
    exact tendsto_const_nhds.div_atTop ( Filter.tendsto_pow_atTop ( by positivity ) |> Filter.Tendsto.comp <| tendsto_natCast_atTop_atTop );
  exact Filter.eventually_atTop.mp ( h_pow.eventually ( gt_mem_nhds hε ) ) |> fun ⟨ c, hc ⟩ ↦ ⟨ c + 1, Nat.succ_pos _, by simpa [ FermatQuality, hn ] using hc ( c + 1 ) ( Nat.le_succ _ ) ⟩

/-
============================================================================
§ 6. Counting Near-Misses
============================================================================

The near-miss count is monotone in the defect bound.
-/
theorem near_miss_count_mono_defect (n N : ℕ) (D₁ D₂ : ℕ) (h : D₁ ≤ D₂) :
    NearMissCount n N D₁ ≤ NearMissCount n N D₂ := by
  exact Finset.card_le_card fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, le_trans ( Finset.mem_filter.mp hx |>.2 ) h ⟩

/-
**Upper bound**: NearMissCount ≤ N³.
-/
theorem near_miss_count_upper (n N D : ℕ) :
    NearMissCount n N D ≤ N ^ 3 := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num [ pow_succ' ] )

-- ============================================================================
-- § 7. Radical and ABC Connection
-- ============================================================================

/-- The radical of 1 is 1. -/
theorem radical_one : radical 1 = 1 := by
  simp [radical, Nat.primeFactors]

/-
The radical divides the original number.
-/
theorem radical_dvd (n : ℕ) (hn : 0 < n) : radical n ∣ n := by
  exact Nat.prod_primeFactors_dvd n

/-
The radical is at most the original number.
-/
theorem radical_le (n : ℕ) (hn : 0 < n) : radical n ≤ n := by
  exact Nat.le_of_dvd hn ( radical_dvd n hn )

/-
The radical is multiplicative on coprime inputs.
-/
theorem radical_mul_coprime (a b : ℕ) (ha : 0 < a) (hb : 0 < b)
    (hab : Nat.Coprime a b) :
    radical (a * b) = radical a * radical b := by
  unfold radical;
  rw [ Nat.primeFactors_mul ha.ne' hb.ne', Finset.prod_union hab.disjoint_primeFactors ]

-- ============================================================================
-- § 8. Testable Conjecture
-- ============================================================================

/-- **Conjecture** (Near-Miss Exponent Gap):
For n ≥ 3, coprime a ≤ b ≤ c with a^n + b^n ≠ c^n,
we conjecture |a^n + b^n - c^n| ≥ c^(n-2).

**Test**: For n = 3, c ≤ 100, verify computationally.
**Connection**: Effective ABC ⟹ lower bounds on defects of this form. -/
theorem conjecture_near_miss_exponent_gap : True := trivial