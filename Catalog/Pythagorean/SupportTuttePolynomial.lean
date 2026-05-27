/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# The Universal Support-Tutte Polynomial: Construction and Factorization

We construct a polynomial-valued invariant `supportTuttePoly` for M-convex supports
satisfying a deletion–contraction recurrence, and prove the **Universal Factorization
Theorem**: any deletion–contraction invariant with loop weight `a` in a commutative
semiring `R` factors through `supportTuttePoly` via polynomial evaluation (`aeval`).

## Overview

The classical Tutte polynomial is the universal deletion–contraction invariant for
matroids. We establish the analogous result for M-convex support sets, which are
finite subsets of `ℕ^n` satisfying the symmetric exchange property.

Unlike matroids, supports carry **multiplicity information** (coordinate values can
exceed 1), making their invariant theory strictly richer. The support-Tutte polynomial
`T(S) ∈ ℕ[X]` is defined by:
- `T(∅) = 1`, `T({0}) = 1`
- `T(S) = T(S \ i) + T(S / i)` for ordinary coordinates i
- `T(S) = X · T(S / i)` for loop coordinates i

The **Universal Factorization Theorem** (Theorem C) shows that for any commutative
semiring R, any element `a ∈ R`, and any function `f : Support → R` satisfying the
same recurrence with loop weight `a`, we have `f(S) = T(S)|_{X=a}` for all supports S.

## Main Definitions

* `supportTuttePoly` — The universal support-Tutte polynomial in `ℕ[X]`
* `SupportExch` — Symmetric exchange property (M-convexity)
* `sDelete` — Support deletion at a coordinate
* `sContract` — Support Tutte-contraction at a coordinate
* `IsSLoop` — Loop coordinate predicate
* `IsOrdCoord` — Ordinary coordinate predicate

## Main Results

* `supportTutte_factorization` — **Universal Factorization Theorem** (Theorem C)
* `supportTuttePoly_eval_one_eq_card` — Cardinality specialization at `X=1` (Theorem D)
* `sContract_card_eq_filter` — Contraction preserves cardinality (Theorem A)
* `delete_contract_partition` — Deletion–contraction partition of support (Theorem B)

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Brylawski–Oxley, "The Tutte polynomial and its applications", 1992
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finset Polynomial BigOperators Finsupp

attribute [local instance] Classical.propDecidable

namespace SupportTuttePolynomial

variable {ι : Type*} [DecidableEq ι]

/-! ## Section 1: Core Definitions

We define the support operations needed for the deletion–contraction
recurrence. These mirror the definitions in `SupportMinorTheory` but
are self-contained. -/

/-- The **symmetric exchange property** for support sets (M-convexity). -/
def SupportExch (S : Finset (ι →₀ ℕ)) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, ∀ a : ι,
    x a > y a →
    ∃ b : ι, y b > x b ∧
      x - Finsupp.single a 1 + Finsupp.single b 1 ∈ S ∧
      y + Finsupp.single a 1 - Finsupp.single b 1 ∈ S

/-- **Support deletion** at coordinate i: retain elements with `m(i) = 0`. -/
def sDelete (S : Finset (ι →₀ ℕ)) (i : ι) : Finset (ι →₀ ℕ) :=
  S.filter (fun m => m i = 0)

/-- **Tutte-style contraction** at coordinate i: retain elements with
    `m(i) > 0`, then subtract 1 from coordinate i. -/
noncomputable def sContract (S : Finset (ι →₀ ℕ)) (i : ι) : Finset (ι →₀ ℕ) :=
  (S.filter (fun m => 0 < m i)).image (fun m => m - Finsupp.single i 1)

/-- Coordinate i is a **support loop** if every element has `m(i) > 0`. -/
def IsSLoop (S : Finset (ι →₀ ℕ)) (i : ι) : Prop :=
  ∀ m ∈ S, m i > 0

/-- Coordinate i is **ordinary** if some elements have `m(i) = 0` and
    some have `m(i) > 0`. -/
def IsOrdCoord (S : Finset (ι →₀ ℕ)) (i : ι) : Prop :=
  (∃ m ∈ S, m i = 0) ∧ (∃ m ∈ S, 0 < m i)

/-- Total degree of a support: sum of all coordinate values across all elements. -/
noncomputable def sTotalDeg (S : Finset (ι →₀ ℕ)) : ℕ :=
  S.sum (fun m => m.sum (fun _ v => v))

/-- **Support measure** for well-founded recursion: `totalDeg + cardinality`. -/
noncomputable def sMeasure (S : Finset (ι →₀ ℕ)) : ℕ :=
  sTotalDeg S + S.card

/-! ## Section 2: Basic Properties -/

theorem sDelete_subset (S : Finset (ι →₀ ℕ)) (i : ι) :
    sDelete S i ⊆ S :=
  filter_subset _ _

theorem mem_sDelete_iff {S : Finset (ι →₀ ℕ)} {i : ι} {m : ι →₀ ℕ} :
    m ∈ sDelete S i ↔ m ∈ S ∧ m i = 0 :=
  Finset.mem_filter

/-- Deletion at a coordinate with positive elements strictly reduces cardinality. -/
theorem sDelete_card_lt {S : Finset (ι →₀ ℕ)} {i : ι}
    (h : ∃ m ∈ S, 0 < m i) :
    (sDelete S i).card < S.card := by
  apply Finset.card_lt_card
  constructor
  · exact sDelete_subset S i
  · intro h_eq
    obtain ⟨m, hm, hmi⟩ := h
    have := h_eq hm
    rw [mem_sDelete_iff] at this
    omega

/-- Tutte contraction does not increase cardinality. -/
theorem sContract_card_le (S : Finset (ι →₀ ℕ)) (i : ι) :
    (sContract S i).card ≤ S.card :=
  le_trans Finset.card_image_le (Finset.card_filter_le _ _)

/-- Contraction at an ordinary coordinate strictly reduces cardinality:
    some elements are filtered out (those with `m(i) = 0`), and the
    image doesn't increase cardinality. -/
theorem sContract_card_lt_of_ordinary {S : Finset (ι →₀ ℕ)} {i : ι}
    (hzero : ∃ m ∈ S, m i = 0) (hpos : ∃ m ∈ S, 0 < m i) :
    (sContract S i).card < S.card := by
  calc (sContract S i).card
      ≤ (S.filter (fun m => 0 < m i)).card := Finset.card_image_le
    _ < S.card := by
        apply Finset.card_lt_card
        exact ⟨Finset.filter_subset _ _, fun h =>
          by obtain ⟨m, hm, hmi⟩ := hzero; exact absurd (h hm) (by simp; omega)⟩

/-! ## Section 3: Support Classification -/

/-- **Support classification.** Every support is empty, trivial ({0}),
    or admits an ordinary or loop coordinate. -/
theorem support_classification (S : Finset (ι →₀ ℕ)) :
    S = ∅ ∨ S = {(0 : ι →₀ ℕ)} ∨
    (∃ i, IsOrdCoord S i) ∨ (∃ i, IsSLoop S i) := by
  by_cases hempty : S = ∅
  · exact Or.inl hempty
  · by_cases hall_zero : ∀ m ∈ S, m = 0
    · exact Or.inr (Or.inl (Finset.eq_singleton_iff_nonempty_unique_mem.mpr
        ⟨Finset.nonempty_iff_ne_empty.mpr hempty, hall_zero⟩))
    · push_neg at hall_zero
      obtain ⟨m, hm, hm_ne⟩ := hall_zero
      obtain ⟨i, hi⟩ := Finsupp.ne_iff.mp hm_ne
      by_cases hzero : ∃ m' ∈ S, m' i = 0
      · exact Or.inr (Or.inr (Or.inl ⟨i, hzero, m, hm, Nat.pos_of_ne_zero hi⟩))
      · push_neg at hzero
        exact Or.inr (Or.inr (Or.inr ⟨i, fun m' hm' =>
          Nat.pos_of_ne_zero (hzero m' hm')⟩))

/-! ## Section 4: Measure Descent Lemmas -/

omit [DecidableEq ι] in
/-- Total degree is monotone under subset inclusion. -/
theorem sTotalDeg_mono {S T : Finset (ι →₀ ℕ)} (h : S ⊆ T) :
    sTotalDeg S ≤ sTotalDeg T :=
  Finset.sum_le_sum_of_subset h

/-- Deletion at a coordinate with positive elements strictly decreases
    the support measure. -/
theorem sMeasure_delete_lt {S : Finset (ι →₀ ℕ)} {i : ι}
    (h : ∃ m ∈ S, 0 < m i) :
    sMeasure (sDelete S i) < sMeasure S := by
  unfold sMeasure
  have h1 := sTotalDeg_mono (sDelete_subset S i)
  have h2 := sDelete_card_lt h
  omega

/-
Total degree of Tutte contraction does not exceed the original.
-/
theorem sTotalDeg_sContract_le (S : Finset (ι →₀ ℕ)) (i : ι) :
    sTotalDeg (sContract S i) ≤ sTotalDeg S := by
  -- Apply the definition of `sTotalDeg` to expand the sums.
  have h_expand : (∑ m ∈ (S.filter (fun m => 0 < m i)).image (fun m => m - Finsupp.single i 1), m.sum (fun _ v => v)) ≤ (∑ m ∈ S.filter (fun m => 0 < m i), (m - Finsupp.single i 1).sum (fun _ v => v)) := by
    rw [ Finset.sum_image ];
    intro m hm m' hm' h; simp_all +decide [ Finsupp.ext_iff ] ;
    intro a; specialize h a; by_cases ha : a = i <;> simp_all +decide [ Finsupp.single_apply ] ;
    omega;
  refine' le_trans h_expand ( le_trans ( Finset.sum_le_sum_of_subset _ ) _ );
  exact S;
  · grind;
  · refine' Finset.sum_le_sum fun m hm => _;
    rw [ Finsupp.sum_of_support_subset ];
    any_goals exact m.support;
    · exact Finset.sum_le_sum fun x hx => Nat.sub_le _ _;
    · intro j hj; contrapose! hj; aesop;
    · exact fun _ _ => rfl

/-- Tutte contraction at an ordinary coordinate strictly decreases
    the support measure. -/
theorem sMeasure_contract_lt_of_ordinary {S : Finset (ι →₀ ℕ)} {i : ι}
    (hord : IsOrdCoord S i) :
    sMeasure (sContract S i) < sMeasure S := by
  unfold sMeasure
  have h1 := sTotalDeg_sContract_le S i
  have h2 := sContract_card_lt_of_ordinary hord.1 hord.2
  omega

/-
For a loop coordinate, Tutte contraction strictly reduces the measure.
    The key insight: every element has `m(i) > 0`, so the contraction
    reduces the total degree by at least `|S|`.
-/
theorem sMeasure_contract_lt_of_loop {S : Finset (ι →₀ ℕ)} {i : ι}
    (hloop : IsSLoop S i) (hne : S.Nonempty) :
    sMeasure (sContract S i) < sMeasure S := by
  -- Since $S$ is nonempty and $i$ is a loop, we have $\sum_{m \in S} m_i \geq |S|$.
  have h_sum_ge_card : ∑ m ∈ S, m i ≥ S.card := by
    exact le_trans ( by norm_num ) ( Finset.sum_le_sum fun x hx => Nat.succ_le_of_lt ( hloop x hx ) );
  -- Since $S$ is nonempty and $i$ is a loop, we have $\sum_{m \in S} \sum_{j} m_j \geq \sum_{m \in S} m_i$.
  have h_sum_ge_sum_i : ∑ m ∈ S, m.sum (fun _ v => v) ≥ ∑ m ∈ S, m i := by
    exact Finset.sum_le_sum fun m hm => by simpa using Finset.single_le_sum ( fun a _ => Nat.zero_le ( m a ) ) ( Finsupp.mem_support_iff.mpr ( ne_of_gt ( hloop m hm ) ) ) ;
  -- Since $S$ is nonempty and $i$ is a loop, we have $\sum_{m \in S} \sum_{j} (m_j - \delta_{ij}) \leq \sum_{m \in S} \sum_{j} m_j - |S|$.
  have h_sum_contract_le_sum : ∑ m ∈ sContract S i, m.sum (fun _ v => v) ≤ ∑ m ∈ S, m.sum (fun _ v => v) - S.card := by
    have h_sum_contract_le_sum : ∑ m ∈ sContract S i, m.sum (fun _ v => v) ≤ ∑ m ∈ S, (m.sum (fun _ v => v) - 1) := by
      have h_sum_contract_le_sum : ∑ m ∈ sContract S i, m.sum (fun _ v => v) ≤ ∑ m ∈ S.filter (fun m => 0 < m i), (m.sum (fun _ v => v) - 1) := by
        rw [ show sContract S i = ( S.filter ( fun m => 0 < m i ) ).image ( fun m => m - Finsupp.single i 1 ) from rfl, Finset.sum_image ];
        · refine' Finset.sum_le_sum fun m hm => _;
          rw [ Finsupp.sum_of_support_subset ];
          case s => exact m.support;
          · refine' Nat.le_sub_one_of_lt ( Finset.sum_lt_sum _ _ );
            · aesop;
            · exact ⟨ i, by aesop ⟩;
          · intro j hj; contrapose! hj; aesop;
          · exact fun _ _ => rfl;
        · intro m hm m' hm' h_eq; simp_all +decide [ Finsupp.ext_iff ] ;
          grind +revert;
      exact h_sum_contract_le_sum.trans ( Finset.sum_le_sum_of_subset ( Finset.filter_subset _ _ ) );
    refine' le_trans h_sum_contract_le_sum _;
    rw [ Nat.sub_eq_of_eq_add ];
    zify;
    rw [ Finset.sum_congr rfl fun x hx => Nat.cast_sub <| ?_ ] <;> norm_num;
    exact le_trans ( hloop x hx ) ( Finset.single_le_sum ( fun a _ => Nat.zero_le ( x a ) ) ( Finsupp.mem_support_iff.mpr ( ne_of_gt ( hloop x hx ) ) ) );
  unfold sMeasure;
  unfold sTotalDeg;
  refine' lt_of_le_of_lt ( add_le_add h_sum_contract_le_sum ( Finset.card_le_card _ ) ) _;
  exact S.image fun m => m - Finsupp.single i 1;
  · exact Finset.image_subset_iff.mpr fun m hm => Finset.mem_image.mpr ⟨ m, Finset.mem_filter.mp hm |>.1, rfl ⟩;
  · grind

/-! ## Section 5: The Universal Support-Tutte Polynomial -/

/-- The **Universal Support-Tutte Polynomial** `T(S) ∈ ℕ[X]`.

Defined by well-founded recursion on `sMeasure`:
- `T(∅) = 1`, `T({0}) = 1`
- `T(S) = T(del S i) + T(con S i)` for a chosen ordinary coordinate i
- `T(S) = X · T(con S i)` for a chosen loop coordinate i

The factorization theorem shows this polynomial is universal:
every DC invariant is a specialization. -/
noncomputable def supportTuttePoly (S : Finset (ι →₀ ℕ)) : Polynomial ℕ :=
  if _h₁ : S = ∅ then 1
  else if _h₂ : S = {0} then 1
  else if h₃ : ∃ i, IsOrdCoord S i then
    have : sMeasure (sDelete S h₃.choose) < sMeasure S :=
      sMeasure_delete_lt h₃.choose_spec.2
    have : sMeasure (sContract S h₃.choose) < sMeasure S :=
      sMeasure_contract_lt_of_ordinary h₃.choose_spec
    supportTuttePoly (sDelete S h₃.choose) +
      supportTuttePoly (sContract S h₃.choose)
  else if h₄ : ∃ i, IsSLoop S i then
    have hne : S.Nonempty := Finset.nonempty_iff_ne_empty.mpr _h₁
    have : sMeasure (sContract S h₄.choose) < sMeasure S :=
      sMeasure_contract_lt_of_loop h₄.choose_spec hne
    Polynomial.X * supportTuttePoly (sContract S h₄.choose)
  else 1
termination_by sMeasure S

/-! ## Section 6: Universal Factorization Theorem -/

/-
**Theorem C (Universal Factorization).**

For any commutative semiring `R`, element `a : R`, and function
`f : Finset (ι →₀ ℕ) → R` satisfying:
1. `f(∅) = 1`, `f({0}) = 1`,
2. `f(S) = f(S \ i) + f(S / i)` for all ordinary coordinates i,
3. `f(S) = a · f(S / i)` for all loop coordinates i (with S nonempty),

we have `f(S) = aeval a (supportTuttePoly S)`.

This shows every DC invariant is a specialization of the universal
support-Tutte polynomial, establishing `supportTuttePoly` as the
universal object in the category of support DC invariants.
-/
theorem supportTutte_factorization
    {R : Type*} [CommSemiring R] (a : R)
    (f : Finset (ι →₀ ℕ) → R)
    (hf_empty : f ∅ = 1)
    (hf_zero : f {(0 : ι →₀ ℕ)} = 1)
    (hf_ord : ∀ S i, IsOrdCoord S i →
      f S = f (sDelete S i) + f (sContract S i))
    (hf_loop : ∀ S i, IsSLoop S i → S.Nonempty →
      f S = a * f (sContract S i))
    (S : Finset (ι →₀ ℕ)) :
    f S = Polynomial.aeval a (supportTuttePoly S) := by
  induction' n : sMeasure S using Nat.strong_induction_on with n ih generalizing S;
  unfold supportTuttePoly;
  split_ifs with h₁ h₂ h₃ h₄;
  · aesop;
  · aesop;
  · rw [ hf_ord S _ h₃.choose_spec, map_add ];
    rw [ ih _ _ _ rfl, ih _ _ _ rfl ];
    · exact n ▸ sMeasure_contract_lt_of_ordinary h₃.choose_spec;
    · exact n ▸ sMeasure_delete_lt h₃.choose_spec.2;
  · convert hf_loop S h₄.choose h₄.choose_spec ( Finset.nonempty_iff_ne_empty.mpr h₁ ) using 1;
    simp +decide [ Polynomial.aeval_mul, Polynomial.aeval_X ];
    rw [ ih _ _ _ rfl ];
    exact n ▸ sMeasure_contract_lt_of_loop h₄.choose_spec ( Finset.nonempty_iff_ne_empty.mpr h₁ );
  · have := support_classification S; aesop;

/-! ## Section 7: Contraction Injectivity and Partition -/

/-
The contraction map `m ↦ m - single i 1` is injective on elements
    with positive i-coordinate.
-/
theorem sContractMap_injOn (i : ι) :
    Set.InjOn (fun m : ι →₀ ℕ => m - Finsupp.single i 1)
      {m : ι →₀ ℕ | 0 < m i} := by
  intro m hm n hn hmn;
  ext j;
  replace hmn := congr_arg ( fun f => f j ) hmn ; by_cases hj : j = i <;> simp_all +decide [ Finsupp.single_apply ];
  omega

/-
**Theorem A (Contraction cardinality).**
    `|con S i| = |{m ∈ S : m(i) > 0}|` because the contraction
    map is injective.
-/
theorem sContract_card_eq_filter (S : Finset (ι →₀ ℕ)) (i : ι) :
    (sContract S i).card = (S.filter (fun m => 0 < m i)).card := by
  convert Finset.card_image_of_injOn _;
  exact sContractMap_injOn i |> Set.InjOn.mono ( by aesop_cat )

/-
**Theorem B (Deletion–contraction partition).**
    `|del S i| + |con S i| = |S|`: every element contributes to
    exactly one branch of the recursion.
-/
theorem delete_contract_partition (S : Finset (ι →₀ ℕ)) (i : ι) :
    (sDelete S i).card + (sContract S i).card = S.card := by
  rw [ sContract_card_eq_filter ];
  rw [ ← Finset.card_union_of_disjoint ];
  · congr with m ; by_cases hi : m i = 0 <;> simp +decide [ hi, sDelete ];
    exact fun _ => Nat.pos_of_ne_zero hi;
  · exact Finset.disjoint_filter.2 fun _ _ _ _ => by linarith;

/-! ## Section 8: Cardinality Specialization -/

/-
For loops, contraction preserves cardinality: every element passes
    the filter and the map is injective.
-/
theorem sContract_card_eq_of_loop {S : Finset (ι →₀ ℕ)} {i : ι}
    (hloop : IsSLoop S i) :
    (sContract S i).card = S.card := by
  rw [ sContract_card_eq_filter ];
  exact congr_arg Finset.card ( Finset.filter_eq_self.mpr fun m hm => hloop m hm )

/-
**Theorem D (Cardinality specialization).**
    Evaluating the support-Tutte polynomial at `X = 1` recovers the
    support cardinality for nonempty supports:
    `T_S(1) = |S|`.

    This is the support-theoretic analogue of the classical result that
    `T_M(1, 1)` counts the number of bases of a matroid. The proof uses
    the factorization theorem with the cardinality function as the DC
    invariant with loop weight 1.
-/
theorem supportTuttePoly_eval_one_eq_card
    (S : Finset (ι →₀ ℕ)) (hne : S.Nonempty) :
    Polynomial.aeval (1 : ℕ) (supportTuttePoly S) = S.card := by
  have h_card_specialization : (aeval 1 : Polynomial ℕ → ℕ) (supportTuttePoly S) = (if S = ∅ then 1 else S.card) := by
    rw [ ← supportTutte_factorization ];
    · simp +decide;
    · simp +decide;
    · intro S i hi;
      split_ifs <;> simp_all +decide [ Finset.ext_iff ];
      all_goals simp_all +decide [ IsOrdCoord, sDelete, sContract ];
      · tauto;
      · grind;
      · grind;
      · convert delete_contract_partition S i |> Eq.symm using 1;
    · intro S i hi hne; split_ifs <;> simp_all +decide [ sContract_card_eq_of_loop ] ;
      simp_all +decide [ sContract ];
      exact absurd ( ‹∀ x ∈ S, x i = 0› _ hne.choose_spec ) ( ne_of_gt ( hi _ hne.choose_spec ) );
  grind

end SupportTuttePolynomial