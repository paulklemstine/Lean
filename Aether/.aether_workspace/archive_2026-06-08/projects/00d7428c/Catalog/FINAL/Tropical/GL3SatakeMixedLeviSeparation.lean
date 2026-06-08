/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# GL₃ Tropical Satake Mixed Levi Separation

This file investigates finite-test injectivity theorems for the GL₃ tropical Satake
package. We study when finitely supported coefficient functions on the dominant
chamber (modeled as ℕ × ℕ) can be recovered from a mixed family of test functionals:

1. **Rank-1 edge probes** (prefix row/column sums) along two simple-coroot directions
2. **Rank-2 Levi profile moments** (anti-diagonal sums) for the two maximal parabolics

## Main results

- `levi12_eq_levi23`: The two Levi profile families are equal by reindexing, so
  `levi23` provides no additional information beyond `levi12`.

- `mixed_tests_zero_implies_zero_le_one`: For N ≤ 1, the mixed test family
  (edge₁, edge₂, levi₁₂, levi₂₃) separates functions supported in [0,N]².
  This is the maximal range for which the original test family suffices.

- `counterex_N2_*`: An explicit counterexample showing the separation theorem
  fails for N = 2. The function h = δ(0,2) − δ(1,2) − δ(2,0) + δ(2,1) is
  nonzero, supported in [0,2]², and satisfies all edge and Levi test conditions.

- `prefixSum_vanishing`: The 1D analog (GL₂ case) of prefix-sum separation
  works for all N by triangular reconstruction.

- `prefixRectSum_separation`: A corrected 2D separation theorem using
  2D cumulative rectangle sums, which works for all N via Möbius inversion.

## Mathematical context

The key obstruction to the original theorem for N ≥ 2 is information-theoretic:
the test family provides O(N) independent linear constraints, but a function
on [0,N]² has (N+1)² = O(N²) degrees of freedom. No collection of O(N)
linear functionals can separate O(N²) dimensions.
-/

import Mathlib

open Finset Finsupp

/-! ## Definitions -/

/-- The rectangular dominant truncation in the GL₃ dominant chamber. -/
def DomRect (N : ℕ) : Finset (ℕ × ℕ) :=
  (Finset.range (N + 1)).product (Finset.range (N + 1))

/-- A function is supported in the rectangle [0,N]². -/
def SupportedInRectFinsupp (N : ℕ) (f : (ℕ × ℕ) →₀ ℤ) : Prop :=
  ∀ p ∈ f.support, p.1 ≤ N ∧ p.2 ≤ N

/-- Rank-1 edge probe along the first simple-coroot direction.
    This is a "prefix row sum": for row i, sum f(i, b) for b = 0, ..., i. -/
def edge1 (f : (ℕ × ℕ) →₀ ℤ) (i : ℕ) : ℤ :=
  ∑ b ∈ Finset.range (i + 1), f (i, b)

/-- Rank-1 edge probe along the second simple-coroot direction.
    This is a "prefix column sum": for column j, sum f(a, j) for a = 0, ..., j. -/
def edge2 (f : (ℕ × ℕ) →₀ ℤ) (j : ℕ) : ℤ :=
  ∑ a ∈ Finset.range (j + 1), f (a, j)

/-- Rank-2 Levi profile moment for the first maximal parabolic (GL₂ × GL₁).
    Anti-diagonal sum: ∑ f(x, s-x) for x = 0, ..., s. -/
def levi12 (f : (ℕ × ℕ) →₀ ℤ) (s : ℕ) : ℤ :=
  ∑ x ∈ Finset.range (s + 1), f (x, s - x)

/-- Rank-2 Levi profile moment for the second maximal parabolic (GL₁ × GL₂).
    Anti-diagonal sum with reversed parametrization. -/
def levi23 (f : (ℕ × ℕ) →₀ ℤ) (t : ℕ) : ℤ :=
  ∑ x ∈ Finset.range (t + 1), f (t - x, x)

/-! ## Basic properties -/

/-- Support boundedness implies vanishing outside the rectangle. -/
lemma supportedInRect_apply_eq_zero
    {N : ℕ} {f : (ℕ × ℕ) →₀ ℤ}
    (hf : SupportedInRectFinsupp N f) {a b : ℕ}
    (hab : N < a ∨ N < b) :
    f (a, b) = 0 := by
  by_contra h
  have hmem : (a, b) ∈ f.support := Finsupp.mem_support_iff.mpr h
  obtain ⟨ha, hb⟩ := hf _ hmem
  rcases hab with ha' | hb' <;> omega

/-
The difference of rectangle-supported functions is rectangle-supported.
-/
lemma SupportedInRectFinsupp.sub
    {N : ℕ} {f g : (ℕ × ℕ) →₀ ℤ}
    (hf : SupportedInRectFinsupp N f)
    (hg : SupportedInRectFinsupp N g) :
    SupportedInRectFinsupp N (f - g) := by
  intro p hp; have := hf p; have := hg p; simp_all +decide [ sub_eq_zero ] ;
  grind

/-- The edge1 functional is linear. -/
lemma edge1_sub (f g : (ℕ × ℕ) →₀ ℤ) (i : ℕ) :
    edge1 (f - g) i = edge1 f i - edge1 g i := by
  simp only [edge1, Finsupp.sub_apply]
  rw [← Finset.sum_sub_distrib]

/-- The edge2 functional is linear. -/
lemma edge2_sub (f g : (ℕ × ℕ) →₀ ℤ) (j : ℕ) :
    edge2 (f - g) j = edge2 f j - edge2 g j := by
  simp only [edge2, Finsupp.sub_apply]
  rw [← Finset.sum_sub_distrib]

/-- The levi12 functional is linear. -/
lemma levi12_sub (f g : (ℕ × ℕ) →₀ ℤ) (s : ℕ) :
    levi12 (f - g) s = levi12 f s - levi12 g s := by
  simp only [levi12, Finsupp.sub_apply]
  rw [← Finset.sum_sub_distrib]

/-- The levi23 functional is linear. -/
lemma levi23_sub (f g : (ℕ × ℕ) →₀ ℤ) (t : ℕ) :
    levi23 (f - g) t = levi23 f t - levi23 g t := by
  simp only [levi23, Finsupp.sub_apply]
  rw [← Finset.sum_sub_distrib]

/-! ## levi12 equals levi23

The two Levi profile families are equal. This is because both sum the same
set of values {f(a, s-a) : 0 ≤ a ≤ s} on each anti-diagonal, just in
reversed order. -/

/-
The two Levi profile moments coincide: `levi12 f s = levi23 f s`.
-/
theorem levi12_eq_levi23 (f : (ℕ × ℕ) →₀ ℤ) (s : ℕ) :
    levi12 f s = levi23 f s := by
  unfold levi12 levi23;
  rw [ ← Finset.sum_flip ];
  exact Finset.sum_congr rfl fun x hx => by rw [ Nat.sub_sub_self ( Finset.mem_range_succ_iff.mp hx ) ] ;

/-! ## Separation theorem for N ≤ 1

For N ≤ 1, the mixed test family determines functions on [0,N]² uniquely.
The proof is by direct case analysis: the test equations form a
determined system for 1 or 4 unknowns. -/

/-
For N = 0: edge1 at 0 determines the single coefficient.
-/
lemma mixed_tests_zero_implies_zero_N0
    (h : (ℕ × ℕ) →₀ ℤ)
    (hh : SupportedInRectFinsupp 0 h)
    (hedge1 : ∀ i ≤ 0, edge1 h i = 0) :
    h = 0 := by
  ext ⟨a, b⟩
  by_cases ha : a = 0;
  · by_cases hb : b = 0 <;> simp_all +decide [ edge1 ];
    exact supportedInRect_apply_eq_zero hh ( Or.inr ( Nat.pos_of_ne_zero hb ) );
  · exact supportedInRect_apply_eq_zero hh ( Or.inl ( Nat.pos_of_ne_zero ha ) )

/-
For N = 1: the system of edge and Levi equations determines all 4 coefficients.
-/
lemma mixed_tests_zero_implies_zero_N1
    (h : (ℕ × ℕ) →₀ ℤ)
    (hh : SupportedInRectFinsupp 1 h)
    (hedge1 : ∀ i ≤ 1, edge1 h i = 0)
    (hedge2 : ∀ j ≤ 1, edge2 h j = 0)
    (hlevi12 : ∀ s ≤ 2, levi12 h s = 0) :
    h = 0 := by
  -- By definition of $edge1$, $edge2$, and $levi12$, we have:
  have h_edge1_0 : h (0,0) = 0 := by
    simpa [ edge1 ] using hedge1 0 bot_le
  have h_edge1_1 : h (1,0) + h (1,1) = 0 := by
    simpa [ Finset.sum_range_succ, edge1 ] using hedge1 1 le_rfl
  have h_edge2_0 : h (0,0) = 0 := by
    exact h_edge1_0
  have h_edge2_1 : h (0,1) + h (1,1) = 0 := by
    convert hedge2 1 le_rfl using 1 ; unfold edge2 ; norm_num [ Finset.sum_range_succ ]
  have h_levi12_2 : h (0,2) + h (1,1) + h (2,0) = 0 := by
    convert hlevi12 2 ( by norm_num ) using 1 ; simp +decide [ Finset.sum_range_succ, levi12 ];
  grind +suggestions

/-- **Main separation theorem for N ≤ 1.**
For functions supported in [0,N]² with N ≤ 1, the mixed test family
(edge₁, edge₂, levi₁₂, levi₂₃) separates: if all tests vanish, the function is zero. -/
theorem mixed_tests_zero_implies_zero_le_one
    (N : ℕ) (hN : N ≤ 1)
    (h : (ℕ × ℕ) →₀ ℤ)
    (hh : SupportedInRectFinsupp N h)
    (hedge1 : ∀ i ≤ N, edge1 h i = 0)
    (hedge2 : ∀ j ≤ N, edge2 h j = 0)
    (hlevi12 : ∀ s ≤ 2 * N, levi12 h s = 0)
    (hlevi23 : ∀ s ≤ 2 * N, levi23 h s = 0) :
    h = 0 := by
  interval_cases N
  · exact mixed_tests_zero_implies_zero_N0 h hh hedge1
  · exact mixed_tests_zero_implies_zero_N1 h hh hedge1 hedge2 hlevi12

/-- Injectivity form of the separation theorem for N ≤ 1. -/
theorem mixed_test_injective_rect_le_one
    (N : ℕ) (hN : N ≤ 1)
    (f g : (ℕ × ℕ) →₀ ℤ)
    (hf : SupportedInRectFinsupp N f)
    (hg : SupportedInRectFinsupp N g)
    (hedge1 : ∀ i ≤ N, edge1 f i = edge1 g i)
    (hedge2 : ∀ j ≤ N, edge2 f j = edge2 g j)
    (hlevi12 : ∀ s ≤ 2 * N, levi12 f s = levi12 g s)
    (hlevi23 : ∀ s ≤ 2 * N, levi23 f s = levi23 g s) :
    f = g := by
  have hsub : SupportedInRectFinsupp N (f - g) := hf.sub hg
  have key := mixed_tests_zero_implies_zero_le_one N hN (f - g) hsub
    (fun i hi => by rw [edge1_sub]; linarith [hedge1 i hi])
    (fun j hj => by rw [edge2_sub]; linarith [hedge2 j hj])
    (fun s hs => by rw [levi12_sub]; linarith [hlevi12 s hs])
    (fun s hs => by rw [levi23_sub]; linarith [hlevi23 s hs])
  exact sub_eq_zero.mp key

/-! ## Counterexample for N = 2

We construct a nonzero function h supported in [0,2]² that satisfies all
edge and Levi test conditions. This demonstrates that the mixed test family
is insufficient for separation when N ≥ 2.

The counterexample is:
  h(0,2) = 1, h(1,2) = -1, h(2,0) = -1, h(2,1) = 1

Geometrically, this is a "circulation" on the boundary of the rectangle that
cancels along every prefix row/column sum and every anti-diagonal sum. -/

/-- The counterexample function for N = 2. -/
noncomputable def counterex_N2 : (ℕ × ℕ) →₀ ℤ :=
  Finsupp.single (0, 2) 1 + Finsupp.single (1, 2) (-1) +
  Finsupp.single (2, 0) (-1) + Finsupp.single (2, 1) 1

/-
The counterexample is nonzero.
-/
theorem counterex_N2_ne_zero : counterex_N2 ≠ 0 := by
  unfold counterex_N2;
  exact ne_of_apply_ne ( fun x => x ( 0, 2 ) ) ( by simp +decide )

/-
The counterexample is supported in [0,2]².
-/
theorem counterex_N2_supported : SupportedInRectFinsupp 2 counterex_N2 := by
  intro p;
  unfold counterex_N2;
  rw [ Finsupp.mem_support_iff ] ; norm_num;
  grind

/-
All edge1 tests vanish on the counterexample.
-/
theorem counterex_N2_edge1 : ∀ i ≤ 2, edge1 counterex_N2 i = 0 := by
  intro i hi
  unfold edge1
  simp [counterex_N2];
  interval_cases i <;> simp +decide [ Finsupp.single_apply ]

/-
All edge2 tests vanish on the counterexample.
-/
theorem counterex_N2_edge2 : ∀ j ≤ 2, edge2 counterex_N2 j = 0 := by
  intro j hj; interval_cases j <;> unfold edge2 <;> simp +decide [*] ;
  · unfold counterex_N2; simp +decide ;
  · unfold counterex_N2; simp +decide [ Finset.sum ] ;
  · unfold counterex_N2; simp +decide [ Finset.sum ] ;

/-
All levi12 tests vanish on the counterexample.
-/
theorem counterex_N2_levi12 : ∀ s ≤ 4, levi12 counterex_N2 s = 0 := by
  intros s hs
  unfold levi12
  unfold counterex_N2;
  interval_cases s <;> simp +decide [ Finsupp.single_apply ]

/-
All levi23 tests vanish on the counterexample.
-/
theorem counterex_N2_levi23 : ∀ s ≤ 4, levi23 counterex_N2 s = 0 := by
  exact fun s hs => levi12_eq_levi23 counterex_N2 s ▸ counterex_N2_levi12 s hs

/-- **The separation theorem fails for N ≥ 2.**
There exist nonzero functions supported in [0,2]² on which all
mixed test functionals vanish. -/
theorem separation_fails_N2 :
    ∃ h : (ℕ × ℕ) →₀ ℤ,
      SupportedInRectFinsupp 2 h ∧
      (∀ i ≤ 2, edge1 h i = 0) ∧
      (∀ j ≤ 2, edge2 h j = 0) ∧
      (∀ s ≤ 4, levi12 h s = 0) ∧
      (∀ s ≤ 4, levi23 h s = 0) ∧
      h ≠ 0 :=
  ⟨counterex_N2, counterex_N2_supported, counterex_N2_edge1, counterex_N2_edge2,
   counterex_N2_levi12, counterex_N2_levi23, counterex_N2_ne_zero⟩

/-! ## GL₂ Analog: 1D Prefix Sum Separation

The correct 1D analog works for all N. Prefix sums form a lower-triangular
system that can be inverted by "differencing" (discrete derivative). -/

/-- Prefix sum for 1D Finsupp functions. -/
def prefixSum (f : ℕ →₀ ℤ) (i : ℕ) : ℤ :=
  ∑ a ∈ Finset.range (i + 1), f a

/-- Support predicate for 1D functions. -/
def SupportedIn1D (N : ℕ) (f : ℕ →₀ ℤ) : Prop :=
  ∀ a ∈ f.support, a ≤ N

/-- Vanishing outside support for 1D. -/
lemma supportedIn1D_apply_eq_zero
    {N : ℕ} {f : ℕ →₀ ℤ}
    (hf : SupportedIn1D N f) {a : ℕ}
    (ha : N < a) : f a = 0 := by
  by_contra h
  exact absurd (hf a (Finsupp.mem_support_iff.mpr h)) (by omega)

/-- Prefix sum is linear in the function argument. -/
lemma prefixSum_sub (f g : ℕ →₀ ℤ) (i : ℕ) :
    prefixSum (f - g) i = prefixSum f i - prefixSum g i := by
  simp only [prefixSum, Finsupp.sub_apply]
  rw [← Finset.sum_sub_distrib]

/-- Key recursion: prefixSum at i+1 = prefixSum at i + f(i+1). -/
lemma prefixSum_succ (f : ℕ →₀ ℤ) (i : ℕ) :
    prefixSum f (i + 1) = prefixSum f i + f (i + 1) := by
  simp only [prefixSum]
  rw [Finset.sum_range_succ]

/-
**GL₂ Prefix Sum Vanishing Theorem.**
For f : ℕ →₀ ℤ supported in [0,N], if all prefix sums vanish, then f = 0.
This is the 1D triangular reconstruction principle.
-/
theorem prefixSum_vanishing
    (N : ℕ) (f : ℕ →₀ ℤ)
    (hf : SupportedIn1D N f)
    (hpre : ∀ i ≤ N, prefixSum f i = 0) :
    f = 0 := by
  ext k;
  by_cases hk : k ≤ N;
  · induction' k with k ih;
    · simpa [ prefixSum ] using hpre 0 hk;
    · have := hpre ( k + 1 ) hk; have := hpre k ( Nat.le_of_succ_le hk ) ; simp_all +decide [ prefixSum_succ ] ;
  · exact supportedIn1D_apply_eq_zero hf ( not_le.mp hk )

/-
**GL₂ Prefix Sum Injectivity.**
Two functions with the same prefix sums on [0,N] are equal.
-/
theorem prefixSum_injective
    (N : ℕ) (f g : ℕ →₀ ℤ)
    (hf : SupportedIn1D N f) (hg : SupportedIn1D N g)
    (hpre : ∀ i ≤ N, prefixSum f i = prefixSum g i) :
    f = g := by
  rw [ ← sub_eq_zero ];
  apply prefixSum_vanishing;
  any_goals assumption;
  · intro a ha; simp_all +decide [ Finsupp.mem_support_iff ] ;
    exact Classical.not_not.1 fun h => ha <| by rw [ show f a = 0 by exact Finsupp.notMem_support_iff.1 fun h' => h <| hf a h', show g a = 0 by exact Finsupp.notMem_support_iff.1 fun h' => h <| hg a h' ] ; ring;
  · exact fun i hi => by rw [ prefixSum_sub, hpre i hi, sub_self ] ;

/-! ## Corrected 2D Separation: Prefix Rectangle Sums

For a correct 2D separation theorem valid for all N, we use a richer
test family: 2D cumulative rectangle sums. This provides (N+1)² independent
tests for (N+1)² unknowns, forming an invertible triangular system. -/

/-- 2D cumulative rectangle sum: ∑_{i ≤ a, j ≤ b} f(i,j). -/
def prefixRectSum (f : (ℕ × ℕ) →₀ ℤ) (a b : ℕ) : ℤ :=
  ∑ i ∈ Finset.range (a + 1), ∑ j ∈ Finset.range (b + 1), f (i, j)

/-- Prefix rectangle sum is linear. -/
lemma prefixRectSum_sub (f g : (ℕ × ℕ) →₀ ℤ) (a b : ℕ) :
    prefixRectSum (f - g) a b = prefixRectSum f a b - prefixRectSum g a b := by
  simp only [prefixRectSum, Finsupp.sub_apply]
  simp [Finset.sum_sub_distrib]

/-
**Corrected 2D Separation Theorem.**
For functions supported in [0,N]², agreement on all prefix rectangle sums
implies equality. This is the 2D Möbius inversion principle.
-/
theorem prefixRectSum_separation
    (N : ℕ) (f g : (ℕ × ℕ) →₀ ℤ)
    (hf : SupportedInRectFinsupp N f)
    (hg : SupportedInRectFinsupp N g)
    (hpre : ∀ a ≤ N, ∀ b ≤ N, prefixRectSum f a b = prefixRectSum g a b) :
    f = g := by
  unfold prefixRectSum at hpre;
  ext ⟨ a, b ⟩;
  by_cases ha : a ≤ N <;> by_cases hb : b ≤ N;
  · induction' a using Nat.strong_induction_on with a ih generalizing b; induction' b using Nat.strong_induction_on with b ih';
    nontriviality;
    rcases a with ( _ | a ) <;> rcases b with ( _ | b );
    · simpa using hpre 0 bot_le 0 bot_le;
    · have := hpre 0 ( by linarith ) ( b + 1 ) ( by linarith ) ; have := hpre 0 ( by linarith ) b ( by linarith ) ; simp_all +decide [ Finset.sum_range_succ ] ;
    · have := hpre ( a + 1 ) ha 0 hb; have := hpre a ( by linarith ) 0 hb; simp_all +decide [ Finset.sum_range_succ ] ;
    · have := hpre ( a + 1 ) ha ( b + 1 ) hb; have := hpre a ( by linarith ) ( b + 1 ) hb; have := hpre ( a + 1 ) ha b ( by linarith ) ; have := hpre a ( by linarith ) b ( by linarith ) ; simp_all +decide [ Finset.sum_range_succ ] ;
  · rw [ supportedInRect_apply_eq_zero hf ( Or.inr <| by linarith ), supportedInRect_apply_eq_zero hg ( Or.inr <| by linarith ) ];
  · rw [ supportedInRect_apply_eq_zero hf ( Or.inl ( not_le.mp ha ) ), supportedInRect_apply_eq_zero hg ( Or.inl ( not_le.mp ha ) ) ];
  · rw [ supportedInRect_apply_eq_zero hf ( Or.inl <| by linarith ), supportedInRect_apply_eq_zero hg ( Or.inl <| by linarith ) ]