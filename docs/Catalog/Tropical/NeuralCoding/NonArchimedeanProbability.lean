/-
  Non-Archimedean Probability: Algebraic Foundations

  This module establishes rigorous algebraic foundations for probability theory
  in non-Archimedean ordered fields. The central results are:

  1. Exact characterization of non-Archimedean fields via infinitesimal existence.
  2. Equivalence of faithfulness and strict monotonicity for finitely additive measures.
  3. Conditional probability on singletons resolving the Borel-Kolmogorov paradox.
  4. Sub-probability bounds for infinitesimal uniform measures.
-/
import Mathlib

open Finset BigOperators

/-! ## Section 1: Non-Archimedean Characterization via Infinitesimals -/

/-- An element ε of an ordered field is *infinitesimal* if it is positive
    and n • ε < 1 for every natural number n. This captures the notion of a
    "probability infinitesimal" — a positive weight too small to ever sum to 1
    over any finite number of copies. -/
def IsInfinitesimal {F : Type*} [Semiring F] [PartialOrder F] (ε : F) : Prop :=
  0 < ε ∧ ∀ n : ℕ, n • ε < 1

/-
**Theorem 1 (Non-Archimedean ⟺ Infinitesimal Existence).**
    A linearly ordered field admits an infinitesimal element if and only if
    it is non-Archimedean.
-/
theorem non_archimedean_iff_infinitesimal_exists
    {F : Type*} [Field F] [LinearOrder F] [IsStrictOrderedRing F] :
    ¬ Archimedean F ↔ ∃ ε : F, IsInfinitesimal ε := by
  constructor <;> intro h;
  · -- By definition of non-Archimedean, there exist $x > 0$ and $y > 0$ such that for all $n \in \mathbb{N}$, $n \cdot y < x$.
    obtain ⟨x, y, hx_pos, hy_pos, hxy⟩ : ∃ x y : F, 0 < x ∧ 0 < y ∧ ∀ n : ℕ, n • y < x := by
      contrapose! h;
      refine' ⟨ fun x y hy => _ ⟩;
      exact Exists.elim ( h ( Max.max x 1 ) y ( by positivity ) hy ) fun n hn => ⟨ n, le_trans ( le_max_left _ _ ) hn ⟩;
    refine' ⟨ y / x, _, _ ⟩ <;> simp_all +decide [ div_lt_iff₀ ];
    exact fun n => by rw [ mul_div, div_lt_one hx_pos ] ; exact hxy n;
  · obtain ⟨ ε, hε ⟩ := h;
    rintro ⟨ h ⟩;
    contrapose! h;
    exact ⟨ 1, ε, hε.1, hε.2 ⟩

/-
Example: ℝ is Archimedean, so no infinitesimal exists
-/
example : ¬ ∃ ε : ℝ, IsInfinitesimal ε := by
  norm_num [ IsInfinitesimal ];
  exact fun x hx => ⟨ ⌈x⁻¹⌉₊, by nlinarith [ Nat.le_ceil ( x⁻¹ ), mul_inv_cancel₀ hx.ne' ] ⟩

/-
Boundary: In an Archimedean field, every positive ε eventually exceeds 1
-/
theorem archimedean_no_infinitesimal
    {F : Type*} [Field F] [LinearOrder F] [IsStrictOrderedRing F]
    [Archimedean F] (ε : F) (hε : 0 < ε) :
    ∃ n : ℕ, 1 ≤ n • ε := by
  have := @Archimedean.arch F;
  convert this 1 hε

-- Generalization: replace "< 1" with "< M" for arbitrary bound
def IsInfinitesimalWrt {F : Type*} [Semiring F] [PartialOrder F] (ε M : F) : Prop :=
  0 < ε ∧ ∀ n : ℕ, n • ε < M

theorem non_archimedean_iff_infinitesimal_wrt_exists
    {F : Type*} [Field F] [LinearOrder F] [IsStrictOrderedRing F] :
    ¬ Archimedean F ↔ ∀ M : F, 0 < M → ∃ ε : F, IsInfinitesimalWrt ε M := by
  refine' ⟨ fun h M hM => _, _ ⟩;
  · obtain ⟨ε₀, hε₀⟩ : ∃ ε₀ : F, IsInfinitesimal ε₀ := by
      exact non_archimedean_iff_infinitesimal_exists.mp h;
    refine' ⟨ ε₀ * M, _, _ ⟩;
    · exact mul_pos hε₀.1 hM;
    · exact fun n => by simpa [ mul_assoc, mul_comm, mul_left_comm, nsmul_eq_mul ] using mul_lt_mul_of_pos_right ( hε₀.2 n ) hM;
  · exact fun h => non_archimedean_iff_infinitesimal_exists.mpr ( h 1 zero_lt_one )

/-! ## Section 2: Field-Valued Finitely Additive Measures on Finite Types -/

/-- A field-valued finitely additive measure on a finite type is simply
    a weight function `w : α → F`. The measure of a finset S is `∑ x ∈ S, w x`. -/
def finmeasure {α F : Type*} [AddCommMonoid F] [DecidableEq α]
    (w : α → F) (S : Finset α) : F :=
  ∑ x ∈ S, w x

/-
Disjoint additivity: μ(S ∪ T) = μ(S) + μ(T) when S and T are disjoint.
-/
theorem finmeasure_disjoint_additive {α F : Type*}
    [AddCommMonoid F] [DecidableEq α]
    (w : α → F) (S T : Finset α) (hd : Disjoint S T) :
    finmeasure w (S ∪ T) = finmeasure w S + finmeasure w T := by
  unfold finmeasure; rw [ Finset.sum_union hd ] ;

/-
The measure of the empty set is zero.
-/
theorem finmeasure_empty {α F : Type*}
    [AddCommMonoid F] [DecidableEq α] (w : α → F) :
    finmeasure w (∅ : Finset α) = 0 := by
  exact Finset.sum_empty

/-
The measure of a singleton is the weight of that element.
-/
theorem finmeasure_singleton {α F : Type*}
    [AddCommMonoid F] [DecidableEq α] (w : α → F) (x : α) :
    finmeasure w ({x} : Finset α) = w x := by
  exact Finset.sum_singleton _ _

/-! ## Section 3: Faithful Measures and Strict Monotonicity -/

/-- A weight function is *faithful* if all weights are strictly positive. -/
def IsFaithful {α F : Type*} [Preorder F] [Zero F]
    (w : α → F) : Prop :=
  ∀ x : α, 0 < w x

/-
**Theorem 2 (Faithful ⟹ Strict Monotonicity).**
    If all weights are positive, the measure is strictly monotone:
    S ⊂ T implies μ(S) < μ(T).
-/
theorem faithful_measure_strict_mono {α F : Type*}
    [Field F] [LinearOrder F] [IsStrictOrderedRing F] [DecidableEq α]
    (w : α → F) (hw : IsFaithful w)
    (S T : Finset α) (hST : S ⊂ T) :
    finmeasure w S < finmeasure w T := by
  -- Since S is a proper subset of T, there exists an element x in T that is not in S.
  obtain ⟨x, hxT, hxS⟩ : ∃ x ∈ T, x ∉ S := by
    exact Finset.exists_of_ssubset hST;
  apply Finset.sum_lt_sum_of_subset hST.subset;
  exacts [ hxT, hxS, hw x, fun j hj hjS => le_of_lt ( hw j ) ]

/-
Example: constant weight 1 on Fin 3, {0} ⊂ {0,1} gives strict inequality
-/
example : finmeasure (fun _ : Fin 3 => (1 : ℚ)) ({0} : Finset (Fin 3)) <
    finmeasure (fun _ : Fin 3 => (1 : ℚ)) ({0, 1} : Finset (Fin 3)) := by
  native_decide

/-
Boundary: With a zero weight, strict monotonicity can fail
-/
example : ¬ (finmeasure (fun i : Fin 2 => if i = 0 then (1 : ℚ) else 0)
    ({0} : Finset (Fin 2)) <
    finmeasure (fun i : Fin 2 => if i = 0 then (1 : ℚ) else 0)
    ({0, 1} : Finset (Fin 2))) := by
  decide +kernel

/-
**Theorem 3 (Strict Monotonicity ⟹ Faithful).**
    If the measure is strictly monotone for all proper subset pairs,
    then all weights must be positive.
-/
theorem strict_mono_implies_faithful {α F : Type*}
    [Field F] [LinearOrder F] [IsStrictOrderedRing F] [DecidableEq α]
    (w : α → F)
    (hmono : ∀ S T : Finset α, S ⊂ T → finmeasure w S < finmeasure w T) :
    IsFaithful w := by
  intro x;
  convert hmono ∅ { x } ?_ <;> simp +decide [ finmeasure ]

-- Example: constant weight 1 is faithful
example : IsFaithful (fun _ : Fin 3 => (1 : ℚ)) := by
  intro x; positivity

/-
Generalization: the full iff characterization
-/
theorem strict_mono_iff_faithful {α F : Type*}
    [Field F] [LinearOrder F] [IsStrictOrderedRing F] [DecidableEq α]
    (w : α → F) :
    (∀ S T : Finset α, S ⊂ T → finmeasure w S < finmeasure w T) ↔
    IsFaithful w := by
  refine' ⟨ _, fun h => faithful_measure_strict_mono w h ⟩;
  exact strict_mono_implies_faithful w

/-! ## Section 4: Conditional Probability and the Borel-Kolmogorov Resolution -/

/-- Conditional probability of A given B, defined as μ(A ∩ B) / μ(B)
    in a field F. Well-defined whenever μ(B) ≠ 0. -/
noncomputable def condProb {α F : Type*} [Field F] [DecidableEq α]
    (w : α → F) (A B : Finset α) : F :=
  finmeasure w (A ∩ B) / finmeasure w B

/-
**Theorem 4a (Conditional Probability — member case).**
    P(A | {x}) = 1 when x ∈ A and weights are faithful.
-/
theorem conditional_point_mem {α F : Type*}
    [Field F] [LinearOrder F] [IsStrictOrderedRing F] [DecidableEq α]
    (w : α → F) (hw : IsFaithful w)
    (A : Finset α) (x : α) (hx : x ∈ A) :
    condProb w A {x} = 1 := by
  unfold condProb;
  rw [ Finset.inter_eq_right.mpr ( by simp +decide [ hx ] ), finmeasure_singleton, div_self ];
  exact ne_of_gt ( hw x )

/-
**Theorem 4b (Conditional Probability — non-member case).**
    P(A | {x}) = 0 when x ∉ A.
-/
theorem conditional_point_not_mem {α F : Type*}
    [Field F] [LinearOrder F] [IsStrictOrderedRing F] [DecidableEq α]
    (w : α → F)
    (A : Finset α) (x : α) (hx : x ∉ A) :
    condProb w A {x} = 0 := by
  unfold condProb; aesop;

/-
Example: P({0,1} | {0}) = 1 with uniform weights on Fin 3
-/
example : condProb (fun _ : Fin 3 => (1 : ℚ)) ({0, 1} : Finset (Fin 3))
    ({(0 : Fin 3)} : Finset (Fin 3)) = 1 := by
  convert conditional_point_mem _ _ _ _ _ <;> norm_num;
  exacts [ inferInstance, inferInstance, fun _ => by norm_num ]

/-
Generalization: P(B | B) = 1 for nonempty B with faithful weights
-/
theorem condProb_self {α F : Type*}
    [Field F] [LinearOrder F] [IsStrictOrderedRing F] [DecidableEq α]
    (w : α → F) (hw : IsFaithful w)
    (B : Finset α) (hB : B.Nonempty) :
    condProb w B B = 1 := by
  unfold condProb; simp +decide [ *, Finset.inter_self ] ;
  exact ne_of_gt ( Finset.sum_pos ( fun x hx => hw x ) hB )

/-
Boundary: condProb gives 0 when μ(B) = 0 (junk value from div by zero)
-/
theorem condProb_zero_denom {α F : Type*}
    [Field F] [DecidableEq α]
    (w : α → F) (A B : Finset α) (h : finmeasure w B = 0) :
    condProb w A B = 0 := by
  unfold condProb; aesop;

/-! ## Section 5: Sub-Probability Bound for Infinitesimal Uniform Measures -/

/-- For a uniform weight ε on a type of size n, the total measure is n • ε.
    If ε is infinitesimal, this is strictly less than 1. -/
theorem infinitesimal_sub_probability {F : Type*}
    [Semiring F] [PartialOrder F]
    {n : ℕ} (ε : F) (hε : IsInfinitesimal ε) :
    n • ε < 1 :=
  hε.2 n

/-
The total measure of a uniform weight ε on Fin n equals n • ε.
-/
theorem uniform_finmeasure_total {F : Type*}
    [Field F] [LinearOrder F] [IsStrictOrderedRing F]
    (n : ℕ) (ε : F) :
    finmeasure (fun _ : Fin n => ε) Finset.univ = n • ε := by
  unfold finmeasure; aesop;

/-
Example: uniform weight 1/4 on Fin 3 gives total 3/4
-/
example : finmeasure (fun _ : Fin 3 => (1/4 : ℚ)) Finset.univ = 3/4 := by
  convert uniform_finmeasure_total 3 ( 1 / 4 : ℚ ) using 1 ; norm_num

/-
Generalization: sub-probability can be completed to a full probability
-/
theorem sub_probability_completion {F : Type*}
    [Field F] [LinearOrder F] [IsStrictOrderedRing F]
    (n : ℕ) (ε : F) (hlt : n • ε < 1) :
    ∃ δ : F, 0 < δ ∧ finmeasure (fun i : Fin (n + 1) =>
      if (i : ℕ) < n then ε else δ) Finset.univ = 1 := by
  refine' ⟨ 1 - n • ε, _, _ ⟩;
  · exact sub_pos_of_lt hlt;
  · unfold finmeasure; simp +decide [ Fin.sum_univ_castSucc ] ;