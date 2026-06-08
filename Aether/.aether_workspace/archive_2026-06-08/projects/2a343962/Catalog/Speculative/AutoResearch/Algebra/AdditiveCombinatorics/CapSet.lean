import Mathlib

/-!
# Cap Sets and the Polynomial Method in 𝔽₃ⁿ

This file formalizes the **dimension-theoretic heart** of the Ellenberg–Gijswijt cap-set
bound, bypassing tensors and slice-rank formalism entirely.

## Main Definitions

* `IsCapSet` — A subset A ⊆ 𝔽₃ⁿ contains no nontrivial three-term arithmetic progression
* `deltaIndicator` — The Kronecker delta polynomial ∏ᵢ(1 − xᵢ²) over 𝔽₃
* `numLowDegMonomials` — Count of reduced monomials with bounded total degree

## Main Results

* `zmod3_one_sub_sq` — Over 𝔽₃, 1 − x² is the indicator of zero
* `deltaIndicator_eq_ite` — The product ∏ᵢ(1 − vᵢ²) equals the Kronecker delta on 𝔽₃ⁿ
* `capset_sum_kernel_eq_ite` — On a cap set, the kernel sum ∑_{c∈A} Δ(a+b+c) = δ_{a,b}
* `capset_diagonal` — Cap sets have the diagonal property: x+y+z=0 in A implies x=y=z
* `degree_splitting` — If a+b+c ≤ 2n then min(a,b,c) ≤ ⌊2n/3⌋
* `capset_card_le_pow` — Trivial bound |A| ≤ 3ⁿ
* `card_reduced_monomials` — Number of reduced monomials equals 3ⁿ
* `numLowDegMonomials_le_pow` — D(d) ≤ 3ⁿ for any degree bound d

## Mathematical Significance

The polynomial method for cap sets (Croot–Lev–Pach 2016, Ellenberg–Gijswijt 2017) proves
that cap sets in 𝔽₃ⁿ have exponentially small density. The key idea:

1. Over 𝔽₃, the function Δ(v) = ∏ᵢ(1 − vᵢ²) is the indicator of the zero vector.
2. For a cap set A, the matrix M(a,b) = ∑_{c∈A} Δ(a+b+c) equals δ_{a,b} for a,b ∈ A.
3. M is an identity matrix of rank |A|.
4. Expanding Δ into monomials and using degree splitting bounds the rank by 3·D₀,
   where D₀ counts reduced monomials of total degree ≤ ⌊2n/3⌋.
5. Therefore |A| ≤ 3·D₀, giving the exponential cap-set bound.

This development formalizes steps 1–3 completely (the structural heart) and provides
the degree splitting engine (step 4's combinatorial core). The gap between these
verified foundations and the full bound is the polynomial expansion and rank
decomposition of the kernel matrix, which requires further infrastructure
for multivariate polynomial manipulation over finite fields.
-/

open Finset BigOperators

noncomputable section

/-! ## Core Definitions -/

/-- A subset A of 𝔽₃ⁿ is a **cap set** if it contains no nontrivial solution to x+y+z = 0,
    i.e., whenever x, y, z ∈ A satisfy x + y + z = 0, then x = y and y = z.
    This is equivalent to saying A contains no three-term arithmetic progression. -/
def IsCapSet {n : ℕ} (A : Finset (Fin n → ZMod 3)) : Prop :=
  ∀ x ∈ A, ∀ y ∈ A, ∀ z ∈ A, x + y + z = 0 → x = y ∧ y = z

/-- The number of reduced monomials of total degree ≤ d in n variables,
    where each exponent is in {0, 1, 2}. We represent monomials as
    functions `Fin n → Fin 3`, where the value at position i gives
    the exponent (0, 1, or 2) of the i-th variable. -/
def numLowDegMonomials (n d : ℕ) : ℕ :=
  Fintype.card {m : Fin n → Fin 3 // (∑ i, (m i : ℕ)) ≤ d}

/-! ## ZMod 3 Arithmetic Properties -/

/-- Over 𝔽₃, 1 − x² is the indicator of zero: it equals 1 when x = 0 and 0 otherwise.
    This is the one-variable building block of the Kronecker delta polynomial. -/
theorem zmod3_one_sub_sq : ∀ x : ZMod 3,
    (1 - x ^ 2 : ZMod 3) = if x = 0 then 1 else 0 := by
  decide

/-- Over 𝔽₃, x³ = x (Fermat's little theorem for p = 3). This identity means that
    every polynomial function on 𝔽₃ can be "reduced" to one with individual degrees ≤ 2. -/
theorem zmod3_cube_eq_self : ∀ x : ZMod 3, x ^ 3 = x := by decide

/-- Over 𝔽₃, x² ∈ {0, 1}. -/
theorem zmod3_sq_cases : ∀ x : ZMod 3, x ^ 2 = 0 ∨ x ^ 2 = 1 := by decide

/-- In 𝔽₃ⁿ, 3a = 0 (characteristic 3 identity). -/
theorem zmod3_vec_three_mul {n : ℕ} (a : Fin n → ZMod 3) :
    a + a + a = 0 := by
  funext i
  show a i + a i + a i = 0
  have : a i + a i + a i = 3 * a i := by ring
  rw [this]; simp [show (3 : ZMod 3) = 0 from by decide]

/-- In 𝔽₃, −2a = a (since −2 ≡ 1 mod 3). -/
theorem zmod3_neg_two_eq_one : (-2 : ZMod 3) = 1 := by decide

/-- In 𝔽₃ⁿ, -(a + a) = a (since -2a = a in characteristic 3). -/
theorem zmod3_vec_neg_two_mul {n : ℕ} (a : Fin n → ZMod 3) :
    -(a + a) = a := by
  funext i
  show -(a i + a i) = a i
  have : -(a i + a i) = (-2 : ZMod 3) * a i := by ring
  rw [this, zmod3_neg_two_eq_one, one_mul]

/-! ## Kronecker Delta Polynomial -/

/-- The **Kronecker delta polynomial** on 𝔽₃ⁿ: Δ(v) = ∏ᵢ (1 − vᵢ²).
    This equals 1 when v = 0 and 0 otherwise. It is the key building block
    of the Ellenberg–Gijswijt polynomial method: it detects whether a
    vector in 𝔽₃ⁿ is the zero vector. As a polynomial, it has total degree 2n
    and individual degree 2 in each variable. -/
def deltaIndicator {n : ℕ} (v : Fin n → ZMod 3) : ZMod 3 :=
  ∏ i : Fin n, (1 - v i ^ 2)

/-- The delta indicator equals 1 at the zero vector. -/
theorem deltaIndicator_zero (n : ℕ) : deltaIndicator (0 : Fin n → ZMod 3) = 1 := by
  simp [deltaIndicator]

/-
The delta indicator equals 0 at any nonzero vector.
    Since v ≠ 0, some coordinate vᵢ ≠ 0, so (1 − vᵢ²) = 0, making the product zero.
-/
theorem deltaIndicator_ne_zero {n : ℕ} {v : Fin n → ZMod 3} (hv : v ≠ 0) :
    deltaIndicator v = 0 := by
  exact Finset.prod_eq_zero ( Finset.mem_univ ( Classical.choose ( Function.ne_iff.mp hv ) ) ) ( by simpa using zmod3_one_sub_sq ( v ( Classical.choose ( Function.ne_iff.mp hv ) ) ) |> fun h => h.trans ( if_neg ( Classical.choose_spec ( Function.ne_iff.mp hv ) ) ) )

/-
The delta indicator is the Kronecker delta on 𝔽₃ⁿ: it equals 1 at 0 and 0 elsewhere.
    This formalizes the fact that ∏ᵢ(1 − vᵢ²) is the unique reduced polynomial
    of degree 2n that acts as the indicator function of {0} ⊂ 𝔽₃ⁿ.
-/
theorem deltaIndicator_eq_ite {n : ℕ} (v : Fin n → ZMod 3) :
    deltaIndicator v = if v = 0 then 1 else 0 := by
  split_ifs <;> simp_all +decide [ deltaIndicator ];
  exact deltaIndicator_ne_zero ‹_›

/-
For any a ∈ 𝔽₃ⁿ, Δ(x − a) is the indicator of {a}.
    This shows every point mass is realized by a polynomial of degree ≤ 2n.
-/
theorem deltaIndicator_sub_eq_ite {n : ℕ} (a x : Fin n → ZMod 3) :
    deltaIndicator (x - a) = if x = a then 1 else 0 := by
  convert deltaIndicator_eq_ite ( x - a ) using 1;
  simp +decide [ sub_eq_zero ]

/-! ## Cap Set Structural Properties -/

/-- The empty set is trivially a cap set. -/
theorem isCapSet_empty (n : ℕ) : IsCapSet (∅ : Finset (Fin n → ZMod 3)) := by
  intro x hx; simp at hx

/-- Any singleton is a cap set. -/
theorem isCapSet_singleton {n : ℕ} (a : Fin n → ZMod 3) :
    IsCapSet ({a} : Finset (Fin n → ZMod 3)) := by
  intro x hx y hy z hz _
  rw [Finset.mem_singleton] at hx hy hz
  exact ⟨hx.trans hy.symm, hy.trans hz.symm⟩

/-- **Cap set diagonal property**: On a cap set, x + y + z = 0 with x, y, z ∈ A
    forces x = y = z. This is the defining property that makes the polynomial
    method work: the kernel of the sum map restricted to A³ is the diagonal. -/
theorem capset_diagonal {n : ℕ} {A : Finset (Fin n → ZMod 3)} (hcap : IsCapSet A)
    {x y z : Fin n → ZMod 3} (hx : x ∈ A) (hy : y ∈ A) (hz : z ∈ A)
    (hsum : x + y + z = 0) : x = y ∧ y = z :=
  hcap x hx y hy z hz hsum

/-- On a cap set, if a ∈ A and b ∈ A and -(a+b) ∈ A, then a = b.
    This is the two-variable restatement of the cap set condition:
    the negated sum of two cap set elements is in A only on the diagonal. -/
theorem capset_neg_sum_mem {n : ℕ} {A : Finset (Fin n → ZMod 3)} (hcap : IsCapSet A)
    {a b : Fin n → ZMod 3} (ha : a ∈ A) (hb : b ∈ A)
    (hc : -(a + b) ∈ A) : a = b := by
  have h := hcap a ha b hb (-(a + b)) hc
  have hsum : a + b + -(a + b) = 0 := by abel
  exact (h hsum).1

/-! ## Cap Set Kernel Sum (The Structural Heart) -/

/-
**Cap set kernel theorem**: For a cap set A and elements a, b ∈ A,
    the sum ∑_{c ∈ A} Δ(a + b + c) equals the Kronecker delta δ_{a,b}.

    This is the **structural heart** of the Ellenberg–Gijswijt argument:
    the "kernel matrix" M(a,b) = ∑_c Δ(a+b+c) is the identity on A.

    **Proof sketch**: Since Δ(v) = 1 iff v = 0, the sum counts elements
    c ∈ A with a+b+c = 0, i.e., c = -(a+b).
    - If a = b: then c = -(2a) = a (since -2 ≡ 1 mod 3), so c = a ∈ A, giving sum = 1.
    - If a ≠ b: if c = -(a+b) ∈ A, the cap condition gives a = b, contradiction.
      So c ∉ A, giving sum = 0.
-/
theorem capset_sum_kernel_eq_ite {n : ℕ} {A : Finset (Fin n → ZMod 3)}
    (hcap : IsCapSet A) {a b : Fin n → ZMod 3} (ha : a ∈ A) (hb : b ∈ A) :
    (∑ c ∈ A, deltaIndicator (a + b + c)) = if a = b then 1 else 0 := by
  -- Use deltaIndicator_eq_ite to rewrite Δ(a+b+c) = if a+b+c = 0 then 1 else 0.
  have h_delta_indicator : ∀ c ∈ A, deltaIndicator (a + b + c) = if a + b + c = 0 then 1 else 0 := by
    exact?;
  split_ifs <;> simp_all +decide [ Finset.sum_ite ];
  · rw [ show { x ∈ A | b + b + x = 0 } = { b } from ?_ ] ; norm_num;
    ext x; simp [Finset.mem_filter];
    exact ⟨ fun hx => by have := hcap _ hb _ hb _ hx.1 ( by linear_combination' hx.2 ) ; tauto, fun hx => hx.symm ▸ ⟨ hb, by linear_combination' zmod3_vec_three_mul b ⟩ ⟩;
  · rw [ Finset.card_eq_zero.mpr ] <;> norm_num;
    exact fun c hc h => ‹¬a = b› <| capset_neg_sum_mem hcap ha hb <| by simpa [ eq_neg_of_add_eq_zero_right h ] using hc;

/-! ## Degree Splitting Lemma -/

/-
**Degree splitting lemma**: If three non-negative integers sum to at most 2n,
    then the minimum of the three is at most ⌊2n/3⌋.

    This is the combinatorial engine behind the EG rank bound: every monomial
    in the expansion of ∏ᵢ(1 − (xᵢ+yᵢ+zᵢ)²) has three groups of variables
    (x, y, z), and at least one group has total degree ≤ ⌊2n/3⌋.

    **Proof**: By contraposition. If min(a,b,c) > ⌊2n/3⌋, then each is
    ≥ ⌊2n/3⌋ + 1, so a+b+c ≥ 3(⌊2n/3⌋ + 1) > 2n.
-/
theorem degree_splitting (a b c n : ℕ) (h : a + b + c ≤ 2 * n) :
    min a (min b c) ≤ (2 * n) / 3 := by
  grind

/-! ## Monomial Counting -/

/-- The number of reduced monomials in n variables is exactly 3ⁿ.
    Each of n positions has 3 choices (exponent 0, 1, or 2). -/
theorem card_reduced_monomials (n : ℕ) :
    Fintype.card (Fin n → Fin 3) = 3 ^ n := by
  simp [Fintype.card_fin]

/-
The number of low-degree reduced monomials is at most 3ⁿ.
-/
theorem numLowDegMonomials_le_pow (n d : ℕ) :
    numLowDegMonomials n d ≤ 3 ^ n := by
  exact Fintype.card_subtype_le _ |> le_trans <| by simp +decide ;

/-! ## Cap Set Cardinality Bounds -/

/-
**Trivial upper bound**: Any subset A ⊆ 𝔽₃ⁿ has at most 3ⁿ elements.
-/
theorem capset_card_le_pow {n : ℕ} (A : Finset (Fin n → ZMod 3)) :
    A.card ≤ 3 ^ n := by
  convert Finset.card_le_univ A ; norm_num [ Fintype.card_pi ]

/-
**Cap set bound in dimension 0**: A cap set in 𝔽₃⁰ has size ≤ 1.
-/
theorem capset_dim0_bound (A : Finset (Fin 0 → ZMod 3)) (_hcap : IsCapSet A) :
    A.card ≤ 1 := by
  exact?

/-
**Cap set bound in dimension 1**: A cap set in 𝔽₃¹ has size ≤ 2.
    This is because {0, 1, 2} has 0 + 1 + 2 = 0 with not all elements equal,
    so the full set is not a cap set, and any subset of size ≤ 2 is.
-/
theorem capset_dim1_bound (A : Finset (Fin 1 → ZMod 3)) (hcap : IsCapSet A) :
    A.card ≤ 2 := by
  fin_cases A <;> simp +decide at hcap ⊢ hcap ⊢;
  simp +decide [ IsCapSet ] at hcap

/-! ## Main EG Bound Statement (Structural Foundation) -/

/-- **Ellenberg–Gijswijt cap set bound (structural form)**:
    Any cap set A ⊆ 𝔽₃ⁿ satisfies |A| ≤ 3 · D(⌊2n/3⌋), where D(d)
    is the number of reduced monomials of total degree ≤ d.

    The proof uses the polynomial method:
    1. The kernel matrix M(a,b) = ∑_c Δ(a+b+c) is the identity on A (capset_sum_kernel_eq_ite).
    2. Expanding Δ in monomials gives M as a sum of structured matrices.
    3. The degree splitting lemma bounds the number of terms.
    4. Therefore |A| = rank(M) ≤ 3·D(⌊2n/3⌋).

    **Note**: The version |A| ≤ D(⌊2n/3⌋) without the factor 3 is false for n=1
    (where D₀=1 but max cap size is 2). -/
theorem card_capset_le_three_mul_low_deg_monomials
    (n : ℕ)
    (A : Finset (Fin n → ZMod 3))
    (hcap : IsCapSet A) :
    A.card ≤ 3 * numLowDegMonomials n ((2 * n) / 3) := by
  sorry

end