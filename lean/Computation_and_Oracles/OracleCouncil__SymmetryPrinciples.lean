/-
# Oracle of Symmetry: Unifying Principles

The Oracle of Symmetry sees the deepest patterns — the meta-theorems
that explain WHY the other identities exist. Symmetry, duality, and
self-reference are the organizing principles of mathematics itself.

## Key Discoveries:
1. The AM-GM inequality for natural numbers
2. The Cauchy-Schwarz inequality (discrete version)
3. The Handshake Lemma — graphs and parity
4. The Pigeonhole Principle — existence from counting
-/

import Mathlib

open Finset BigOperators Nat

/-! ## Section 1: AM-GM for Two Numbers -/

/-
PROBLEM
AM-GM inequality for two natural numbers (squared version):
    (a + b)² ≥ 4ab, equivalently (a - b)² ≥ 0.

PROVIDED SOLUTION
(a+b)² - 4ab = a² + 2ab + b² - 4ab = a² - 2ab + b² = (a-b)² ≥ 0. Use nlinarith or nlinarith [sq_nonneg (a - b)].
-/
theorem am_gm_two_nat (a b : ℕ) : (a + b) ^ 2 ≥ 4 * (a * b) := by
  linarith [ sq_nonneg ( a - b : ℤ ) ]

/-! ## Section 2: Cauchy-Schwarz for Finite Sums -/

/-
PROBLEM
Discrete Cauchy-Schwarz inequality:
    (∑ aᵢbᵢ)² ≤ (∑ aᵢ²)(∑ bᵢ²)

PROVIDED SOLUTION
Use inner_mul_le_norm_mul_sq or Finset.inner_mul_le_norm_mul_sq. Or use the Lagrange identity: (∑a²)(∑b²) - (∑ab)² = ∑_{i<j} (aᵢbⱼ - aⱼbᵢ)² ≥ 0.
-/
theorem cauchy_schwarz_discrete (n : ℕ) (a b : ℕ → ℤ) :
    (∑ i ∈ range n, a i * b i) ^ 2 ≤
    (∑ i ∈ range n, a i ^ 2) * (∑ i ∈ range n, b i ^ 2) := by
      exact?

/-! ## Section 3: The QM-AM-GM-HM Chain for Two Numbers -/

/-
PROBLEM
For positive reals, AM ≥ GM: (a + b)/2 ≥ √(ab).
    Squared version avoids roots: (a + b)² ≥ 4ab.

PROVIDED SOLUTION
(a+b)² - 4ab = (a-b)² ≥ 0. Use nlinarith [sq_nonneg (a - b)].
-/
theorem am_ge_gm (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    (a + b) ^ 2 ≥ 4 * (a * b) := by
      linarith [ sq_nonneg ( a - b ) ]

/-! ## Section 4: Schur's Inequality -/

/-
PROBLEM
Schur's inequality (degree 1): For non-negative reals a, b, c,
    a(a-b)(a-c) + b(b-a)(b-c) + c(c-a)(c-b) ≥ 0

PROVIDED SOLUTION
WLOG assume a ≥ b ≥ c. Then a(a-b)(a-c) ≥ 0. Write b(b-a)(b-c) + c(c-a)(c-b) = (b-c)[(b)(b-a+c-b) ... ]. Actually, group: a(a-b)(a-c) + b(b-a)(b-c) + c(c-a)(c-b) = a(a-b)(a-c) - b(a-b)(b-c) + c(a-c)(b-c) = (a-b)[a(a-c) - b(b-c)] + c(a-c)(b-c). WLOG a≥b≥c: then (a-b)≥0, a(a-c) ≥ b(b-c) since a≥b and a-c≥b-c, so first term ≥ 0, and c(a-c)(b-c)≥0. Try nlinarith or polyrith with appropriate auxiliary terms.
-/
theorem schur_ineq (a b c : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c) :
    a * (a - b) * (a - c) + b * (b - a) * (b - c) + c * (c - a) * (c - b) ≥ 0 := by
      cases le_total a b <;> cases le_total a c <;> cases le_total b c <;> nlinarith [ sq_nonneg ( a - b ), sq_nonneg ( a - c ), sq_nonneg ( b - c ) ]

/-! ## Section 5: The Handshake Lemma -/

/-
PROBLEM
In any finite graph, the sum of degrees equals twice the number of edges.
    We prove the combinatorial version: in any symmetric relation on a finite set,
    the number of ordered pairs is even.

PROVIDED SOLUTION
The set of pairs {(i,j) : R i j} can be partitioned into pairs {(i,j), (j,i)} by symmetry. Each pair has 2 elements (since i≠j by irreflexivity). So the total count is even. Use Finset.card_dvd_of_equiv or construct an involution.
-/
theorem sum_degrees_even (n : ℕ) (R : Fin n → Fin n → Prop) [DecidableRel R]
    (hsymm : ∀ i j, R i j → R j i) (hirrefl : ∀ i, ¬R i i) :
    2 ∣ ((univ : Finset (Fin n × Fin n)).filter fun p => R p.1 p.2).card := by
      -- Consider the set of pairs (i, j) with i ≠ j such that R(i, j) holds. This set can be partitioned into pairs (i, j) and (j, i).
      set S := Finset.filter (fun p => R p.1 p.2 ∧ p.1 ≠ p.2) (Finset.univ : Finset (Fin n × Fin n))
      have hS_even : 2 ∣ Finset.card S := by
        have hS_even : ∃ T : Finset (Fin n × Fin n), S = T ∪ Finset.image (fun p => (p.2, p.1)) T ∧ Disjoint T (Finset.image (fun p => (p.2, p.1)) T) := by
          use Finset.filter (fun p => R p.1 p.2 ∧ p.1 < p.2) (Finset.univ : Finset (Fin n × Fin n));
          norm_num [ Finset.ext_iff, Finset.disjoint_right ];
          grind;
        obtain ⟨ T, hT₁, hT₂ ⟩ := hS_even; rw [ hT₁, Finset.card_union_of_disjoint hT₂ ] ; simp +arith +decide [ Finset.card_image_of_injective, Function.Injective ] ;
        exact ⟨ T.card, by ring ⟩;
      convert hS_even using 2 ; ext ; aesop

/-! ## Section 6: The Pigeonhole Principle — Existence from Counting -/

/-
PROBLEM
If n+1 items are placed in n bins, some bin has at least 2.
    This bridges counting (finite) to existence (logical).

PROVIDED SOLUTION
By Fintype.exists_ne_map_eq_of_card_lt since card (Fin (n+2)) = n+2 > n+1 = card (Fin (n+1)), f cannot be injective, so there exist i ≠ j with f i = f j.
-/
theorem pigeonhole_simple (n : ℕ) (f : Fin (n + 2) → Fin (n + 1)) :
    ∃ i j, i ≠ j ∧ f i = f j := by
      by_contra! h;
      exact absurd ( Fintype.card_le_of_injective f fun i j hij => not_imp_not.mp ( h i j ) hij ) ( by simp +arith +decide )