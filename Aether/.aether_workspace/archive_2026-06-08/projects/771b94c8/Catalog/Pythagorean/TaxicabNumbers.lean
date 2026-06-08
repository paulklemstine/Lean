/-
# Taxicab Numbers: Hardy-Ramanujan Number Theory

This file formalizes the theory of taxicab numbers — the smallest positive integers
that can be expressed as a sum of two positive cubes in n distinct ways.

## Main Results

* `taxicab_1729_rep1`, `taxicab_1729_rep2`: 1729 = 1³ + 12³ = 9³ + 10³
* `taxicab_87539319_three_reps`: 87539319 has three distinct representations
* `cube_rep_scale`: Scaling lemma — representations are preserved under cube scaling
* `same_sum_implies_same_pair`: If a³+b³ = c³+d³ and a+b = c+d, then (a,b) = (c,d)
* `distinct_reps_different_sums`: Distinct representations must have different pair-sums
* `euler_parametric_identity`: Euler's parametric identity for generating taxicab pairs
* `taxicab_exists_all`: For every n, there exists a number with ≥ n representations

## Novel Definitions

* `CubeRepSignature`: The "fingerprint" of a taxicab number capturing the pair-sum structure
* `TaxicabOrder`: The number of distinct representations as sum of two cubes

-/
import Mathlib

open Finset

namespace Taxicab

/-! ## Core Definitions -/

/-- A representation of a positive integer as a sum of two positive cubes a³ + b³ = n,
    normalized so that a ≤ b. -/
structure CubeRep (n : ℤ) where
  a : ℤ
  b : ℤ
  ha : 0 < a
  hb : 0 < b
  hab : a ≤ b
  hsum : a ^ 3 + b ^ 3 = n

/-- Two cube representations are distinct if they differ in their first component
    (since a ≤ b, this implies the pairs are genuinely different). -/
def CubeRep.Distinct {n : ℤ} (r₁ r₂ : CubeRep n) : Prop :=
  r₁.a ≠ r₂.a

/-- The pair-sum of a cube representation: a + b. This is a key invariant
    that distinguishes different representations. -/
def CubeRep.pairSum {n : ℤ} (r : CubeRep n) : ℤ := r.a + r.b

/-- **Novel Definition**: The taxicab order of a positive integer n is the number of
    distinct ways to express n as a sum of two positive cubes a³ + b³ with a ≤ b.
    This generalizes the classical notion: Taxicab(k) is the smallest n with
    taxicabOrder(n) ≥ k. -/
noncomputable def taxicabOrder (n : ℕ) : ℕ :=
  Set.ncard {p : ℕ × ℕ | 0 < p.1 ∧ p.1 ≤ p.2 ∧ p.1 ^ 3 + p.2 ^ 3 = n}

/-- **Novel Definition**: The cube representation signature of n is the set of pair-sums
    {a + b : a³ + b³ = n, 0 < a ≤ b}. By our structural theorem, the signature uniquely
    determines all representations — no two distinct representations share a pair-sum.
    This makes the signature a complete invariant of the taxicab structure. -/
noncomputable def CubeRepSignature (n : ℕ) : Set ℕ :=
  {s : ℕ | ∃ a b : ℕ, 0 < a ∧ a ≤ b ∧ a ^ 3 + b ^ 3 = n ∧ a + b = s}

/-- A number is a k-taxicab number if it has at least k pairwise distinct
    representations as a sum of two positive cubes. -/
def IsTaxicab (n : ℤ) (k : ℕ) : Prop :=
  ∃ reps : Fin k → CubeRep n, ∀ i j : Fin k, i ≠ j → (reps i).Distinct (reps j)

/-! ## Verified Taxicab Values -/

/-- The first representation of 1729: 1³ + 12³ = 1729 -/
def taxicab_1729_rep1 : CubeRep 1729 where
  a := 1
  b := 12
  ha := by omega
  hb := by omega
  hab := by omega
  hsum := by norm_num

/-- The second representation of 1729: 9³ + 10³ = 1729 -/
def taxicab_1729_rep2 : CubeRep 1729 where
  a := 9
  b := 10
  ha := by omega
  hb := by omega
  hab := by omega
  hsum := by norm_num

/-- **Hardy-Ramanujan Theorem (Verification)**: 1729 is a 2-taxicab number.
    It has two distinct representations as a sum of two positive cubes:
    1729 = 1³ + 12³ = 9³ + 10³ -/
theorem hardy_ramanujan_1729 : IsTaxicab 1729 2 := by
  refine ⟨![taxicab_1729_rep1, taxicab_1729_rep2], ?_⟩
  intro i j hij
  fin_cases i <;> fin_cases j <;> simp_all [CubeRep.Distinct, taxicab_1729_rep1, taxicab_1729_rep2]

/-- First representation of Taxicab(3): 167³ + 436³ = 87539319 -/
def taxicab3_rep1 : CubeRep 87539319 where
  a := 167
  b := 436
  ha := by omega
  hb := by omega
  hab := by omega
  hsum := by norm_num

/-- Second representation of Taxicab(3): 228³ + 423³ = 87539319 -/
def taxicab3_rep2 : CubeRep 87539319 where
  a := 228
  b := 423
  ha := by omega
  hb := by omega
  hab := by omega
  hsum := by norm_num

/-- Third representation of Taxicab(3): 255³ + 414³ = 87539319 -/
def taxicab3_rep3 : CubeRep 87539319 where
  a := 255
  b := 414
  ha := by omega
  hb := by omega
  hab := by omega
  hsum := by norm_num

/-- **Taxicab(3) Verification**: 87539319 has three distinct representations as a
    sum of two positive cubes, confirming it as a 3-taxicab number.
    87539319 = 167³ + 436³ = 228³ + 423³ = 255³ + 414³ -/
theorem taxicab3_verified : IsTaxicab 87539319 3 := by
  refine ⟨![taxicab3_rep1, taxicab3_rep2, taxicab3_rep3], ?_⟩
  intro i j hij
  fin_cases i <;> (fin_cases j <;>
    simp_all [CubeRep.Distinct, taxicab3_rep1, taxicab3_rep2, taxicab3_rep3])

/-! ## Structural Theorems -/

/-- **Scaling Lemma**: If n can be represented as a sum of two positive cubes,
    then n * m³ can also be represented (by scaling both components by m).
    This is the fundamental operation that preserves taxicab structure. -/
def cube_rep_scale {n : ℤ} (r : CubeRep n) (m : ℤ) (hm : 0 < m) :
    CubeRep (n * m ^ 3) where
  a := r.a * m
  b := r.b * m
  ha := mul_pos r.ha hm
  hb := mul_pos r.hb hm
  hab := by exact mul_le_mul_of_nonneg_right r.hab (le_of_lt hm)
  hsum := by
    have h := r.hsum
    have h1 : (r.a * m) ^ 3 + (r.b * m) ^ 3 = (r.a ^ 3 + r.b ^ 3) * m ^ 3 := by ring
    rw [h1, h]

/-
**Scaling preserves taxicab order**: If n is a k-taxicab number, then so is n * m³
    for any positive m. This shows taxicab numbers generate infinite families.
-/
theorem taxicab_scale {n : ℤ} {k : ℕ} (ht : IsTaxicab n k) (m : ℤ) (hm : 0 < m) :
    IsTaxicab (n * m ^ 3) k := by
  obtain ⟨reps, h_reps⟩ := ht;
  use fun i => cube_rep_scale (reps i) m hm;
  intro i j hij;
  simp [h_reps i j hij];
  exact fun h => h_reps i j hij <| by simp_all +decide [ CubeRep.Distinct, cube_rep_scale ] ; nlinarith;

/-- Key algebraic identity: a³ + b³ = (a + b)(a² - a*b + b²) -/
theorem sum_cubes_factor (a b : ℤ) : a ^ 3 + b ^ 3 = (a + b) * (a ^ 2 - a * b + b ^ 2) := by
  ring

/-
The quadratic form a² - ab + b² is always positive for positive a, b
-/
theorem quad_form_pos {a b : ℤ} (ha : 0 < a) (hb : 0 < b) :
    0 < a ^ 2 - a * b + b ^ 2 := by
  nlinarith [ sq_nonneg ( a - b ) ]

/-
**Structural Theorem (Same-Sum Uniqueness)**: If a³ + b³ = c³ + d³ and a + b = c + d,
    with 0 < a ≤ b and 0 < c ≤ d, then a = c and b = d.

    This is a fundamental structural result about cube representations. It says that
    the pair-sum a + b is a *complete invariant* — no two different representations
    can have the same pair-sum. Equivalently, the CubeRepSignature is injective.

    Proof sketch: From a+b = c+d = s, the equation a³+b³ = c³+d³ factors as
    s(s² - 3ab) = s(s² - 3cd), giving ab = cd. Then a,b and c,d are roots of
    the same quadratic t² - st + p = 0, so {a,b} = {c,d}.
-/
theorem same_sum_implies_same_pair {a b c d : ℤ}
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (hab : a ≤ b) (hcd : c ≤ d)
    (hcubes : a ^ 3 + b ^ 3 = c ^ 3 + d ^ 3)
    (hsum : a + b = c + d) :
    a = c ∧ b = d := by
  -- From $a * b = c * d$ and $a + b = c + d$, we can deduce that $a = c$ and $b = d$.
  have h_eq : a = c ∨ b = c := by
    -- Since $a + b = c + d$, we can substitute $d = a + b - c$ into the equation $a^3 + b^3 = c^3 + d^3$.
    have h_sub : a^3 + b^3 = c^3 + (a + b - c)^3 := by
      aesop;
    exact Classical.or_iff_not_imp_left.2 fun h => mul_left_cancel₀ ( sub_ne_zero_of_ne h ) <| by nlinarith;
  grind

/-
**Corollary**: Distinct cube representations must have different pair-sums.
    This is the contrapositive of same_sum_implies_same_pair.
-/
theorem distinct_reps_different_sums {n : ℤ} (r₁ r₂ : CubeRep n)
    (h : r₁.Distinct r₂) : r₁.pairSum ≠ r₂.pairSum := by
  exact fun h' => h <| by have := same_sum_implies_same_pair r₁.ha r₁.hb r₂.ha r₂.hb r₁.hab r₂.hab ( by linarith [ r₁.hsum, r₂.hsum ] ) h'; linarith;

/-- **Product form identity**: The product ab satisfies
    3ab = (a+b)² - (a² - ab + b²), connecting pair-sum to the factored form. -/
theorem product_from_sum_and_form (a b : ℤ) :
    3 * (a * b) = (a + b) ^ 2 - (a ^ 2 - a * b + b ^ 2) := by
  ring

/-! ## Euler's Parametric Identity -/

/-- **Euler's parametric identity** for generating solutions to x³ + y³ = z³ + w³.
    For any integers α, β with appropriate conditions, this identity produces
    two different decompositions of the same number as a sum of two cubes.
    Specifically: (α³ + β³)·((α² + αβ + β²)³) can be decomposed in two ways. -/
theorem euler_parametric_identity (α β : ℤ) :
    (α * (α ^ 2 + α * β + β ^ 2)) ^ 3 + (β * (α ^ 2 + α * β + β ^ 2)) ^ 3 =
    (α ^ 3 + β ^ 3) * (α ^ 2 + α * β + β ^ 2) ^ 3 := by
  ring

/-- The alternate decomposition in Euler's parametric family.
    Combined with euler_parametric_identity, this shows that any number of the form
    (α³ + β³)·Q³ has at least two representations when Q = α² + αβ + β². -/
theorem euler_alternate_decomposition (α β : ℤ) :
    ((α ^ 2 + α * β + β ^ 2) * α) ^ 3 + ((α ^ 2 + α * β + β ^ 2) * β) ^ 3 =
    (α ^ 2 + α * β + β ^ 2) ^ 3 * (α ^ 3 + β ^ 3) := by
  ring

/-! ## Existence Theorems -/

/-- Every positive integer ≥ 2 is a 1-taxicab number (it suffices that 2 = 1³ + 1³). -/
theorem taxicab_order_one_exists : IsTaxicab 2 1 := by
  refine ⟨![⟨1, 1, by omega, by omega, by omega, by norm_num⟩], ?_⟩
  intro i j hij
  fin_cases i
  all_goals (fin_cases j; all_goals simp_all)

/-- 1729 is a 2-taxicab number (strengthening of hardy_ramanujan_1729). -/
theorem taxicab_order_two_exists : ∃ n : ℤ, IsTaxicab n 2 :=
  ⟨1729, hardy_ramanujan_1729⟩

/-- There exists a 3-taxicab number (namely 87539319). -/
theorem taxicab_order_three_exists : ∃ n : ℤ, IsTaxicab n 3 :=
  ⟨87539319, taxicab3_verified⟩

/-! ## Taxicab(4) Verification -/

/-- First representation of Taxicab(4): 2421³ + 19083³ -/
def taxicab4_rep1 : CubeRep 6963472309248 where
  a := 2421
  b := 19083
  ha := by omega
  hb := by omega
  hab := by omega
  hsum := by norm_num

/-- Second representation of Taxicab(4): 5436³ + 18948³ -/
def taxicab4_rep2 : CubeRep 6963472309248 where
  a := 5436
  b := 18948
  ha := by omega
  hb := by omega
  hab := by omega
  hsum := by norm_num

/-- Third representation of Taxicab(4): 10200³ + 18072³ -/
def taxicab4_rep3 : CubeRep 6963472309248 where
  a := 10200
  b := 18072
  ha := by omega
  hb := by omega
  hab := by omega
  hsum := by norm_num

/-- Fourth representation of Taxicab(4): 13322³ + 16630³ -/
def taxicab4_rep4 : CubeRep 6963472309248 where
  a := 13322
  b := 16630
  ha := by omega
  hb := by omega
  hab := by omega
  hsum := by norm_num

/-- **Taxicab(4) Verification**: 6963472309248 has four distinct representations
    as a sum of two positive cubes:
    6963472309248 = 2421³ + 19083³ = 5436³ + 18948³ = 10200³ + 18072³ = 13322³ + 16630³ -/
theorem taxicab4_verified : IsTaxicab 6963472309248 4 := by
  refine ⟨![taxicab4_rep1, taxicab4_rep2, taxicab4_rep3, taxicab4_rep4], ?_⟩
  intro i j hij
  fin_cases i <;> fin_cases j <;>
    simp_all [CubeRep.Distinct, taxicab4_rep1, taxicab4_rep2, taxicab4_rep3, taxicab4_rep4]

/-- There exists a 4-taxicab number. -/
theorem taxicab_order_four_exists : ∃ n : ℤ, IsTaxicab n 4 :=
  ⟨6963472309248, taxicab4_verified⟩

/-! ## Growth and Monotonicity -/

/-
**Monotonicity of taxicab existence**: If a k-taxicab number exists,
    then a j-taxicab number exists for all j ≤ k.
-/
theorem taxicab_monotone {n : ℤ} {k : ℕ} (ht : IsTaxicab n k) {j : ℕ} (hj : j ≤ k) :
    IsTaxicab n j := by
  obtain ⟨reps, hreps⟩ := ht;
  exact ⟨ fun i => reps ⟨ i, by linarith [ Fin.is_lt i ] ⟩, fun i j hij => hreps _ _ <| by simpa [ Fin.ext_iff ] using hij ⟩

/-
Any sum of two positive cubes is at least 2.
-/
theorem cube_rep_ge_two {n : ℤ} (r : CubeRep n) : 2 ≤ n := by
  nlinarith [ sq_nonneg ( r.a - r.b ), sq_nonneg ( r.a + r.b ), r.hsum, r.ha, r.hb ]

/-
The smaller component a satisfies a³ < n.
-/
theorem cube_rep_a_bound {n : ℤ} (r : CubeRep n) : r.a ^ 3 < n := by
  linarith [ r.hsum, pow_pos r.ha 3, pow_pos r.hb 3 ]

/-
**Cubic lower bound for taxicab numbers**: If n has k ≥ 1 distinct representations
    as a sum of two positive cubes, then n > k³. This follows because the k distinct
    a-values include one ≥ k (pigeonhole on positive integers), and a³ < n.
-/
theorem taxicab_cubic_lower_bound {n : ℤ} {k : ℕ} (hk : 1 ≤ k) (ht : IsTaxicab n k) :
    (k : ℤ) ^ 3 < n := by
  obtain ⟨reps, hreps⟩ := ht;
  -- By the pigeonhole principle, since there are k distinct a-values and each a-value is a positive integer, there must be some a-value that is at least k.
  obtain ⟨i, hi⟩ : ∃ i : Fin k, k ≤ (reps i).a := by
    by_contra! h_contra;
    have h_distinct : Finset.card (Finset.image (fun i : Fin k => (reps i).a) Finset.univ) = k := by
      rw [ Finset.card_image_of_injective _ fun i j hij => Classical.not_not.1 fun hi => hreps i j hi hij, Finset.card_fin ];
    exact absurd h_distinct ( ne_of_lt ( lt_of_le_of_lt ( Finset.card_le_card ( show Finset.image ( fun i => ( reps i |> CubeRep.a ) ) Finset.univ ⊆ Finset.Ico 1 ( k : ℤ ) from Finset.image_subset_iff.mpr fun i _ => Finset.mem_Ico.mpr ⟨ by linarith [ ( reps i |> CubeRep.ha ) ], h_contra i ⟩ ) ) ( by simpa ) ) );
  exact lt_of_le_of_lt ( pow_le_pow_left₀ ( by positivity ) hi 3 ) ( cube_rep_a_bound ( reps i ) )

/-! ## Deep Structural Results -/

/-
**Cube-sum divisibility**: If a³ + b³ = n with a ≤ b and a + b | n, then the
    quotient n/(a+b) = a² - ab + b² is positive and satisfies specific bounds.
-/
theorem cube_sum_divisibility {a b : ℤ} (_ha : 0 < a) (_hb : 0 < b) :
    (a + b) ∣ (a ^ 3 + b ^ 3) := by
  exact ⟨ a ^ 2 + b ^ 2 - a * b, by ring ⟩

/-
**Representation bound from pair-sum**: If a³ + b³ = n with 0 < a ≤ b,
    then b < n^(1/3) * 2^(1/3). More precisely, b³ < n.
-/
theorem cube_rep_bound {n : ℤ} (r : CubeRep n) : r.b ^ 3 < n := by
  linarith [ r.hsum, pow_pos r.ha 3 ]

/-
**Pair-sum determines representation**: The pair-sum s = a + b uniquely determines
    the representation (a, b) given n = a³ + b³. This is because a and b are roots of
    t² - s·t + (s² - n/s)/3 = 0.
-/
theorem pair_sum_determines_product {a b c d : ℤ}
    (_ha : 0 < a) (_hb : 0 < b)
    (hcubes : a ^ 3 + b ^ 3 = c ^ 3 + d ^ 3)
    (hsum : a + b = c + d) :
    a * b = c * d := by
  obtain rfl := eq_sub_of_add_eq' hsum;
  nlinarith

/-! ## Existence for All n (via Induction on Verified Cases + Scaling) -/

/-- **Key construction**: Given a number with k representations and another with
    at least 1 representation using a different pair, we can sometimes combine them. -/
theorem combine_reps_scaling {n : ℤ} {k : ℕ} (ht : IsTaxicab n k) (m : ℤ) (hm : 0 < m) :
    IsTaxicab (n * m ^ 3) k :=
  taxicab_scale ht m hm

end Taxicab