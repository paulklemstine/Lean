/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Deepening: the square of the Eulerian triangle

The *Eulerian number* `A(n, k)` counts permutations of `{1, …, n}` with `k` descents.
Squaring the (lower-triangular) Eulerian array produces a new triangle with entries

  `C(n, k) = ∑_j A(n, j) · A(j, k)`,

and row generating polynomial `B_n(x) = ∑_k C(n, k) x^k`.

A previous cycle proved that `B_n` is **real-rooted** (splits into real linear factors)
for every `n ≤ 7`, and identified the row `n = 8` as the boundary of the
*consecutive-integer bracket* technique: `B_8` has two roots in `(-1, 0)`, so integer
sign changes no longer separate all roots.

This file **deepens** that work in three independent ways, all fully self-contained
(only `import Mathlib`):

1. **A structural identity** (`sqPoly_eq_sum_eulPoly`).  The squared-triangle row
   polynomial is the `A(n, ·)`-weighted sum of *Eulerian polynomials*:
   `B_n(x) = ∑_j A(n, j) · A_j(x)`, where `A_j(x) = ∑_k A(j, k) x^k`.
   This exhibits `B_n` as a nonnegative combination of the (classically real-rooted)
   Eulerian polynomials and reduces the general conjecture to their *compatibility*.

2. **A general negativity theorem** (`sqPoly_root_neg`, valid for *all* `n`).  Because
   every coefficient of `B_n` is a nonnegative integer with positive constant term,
   `B_n(x) > 0` for all `x ≥ 0`; hence *every* real root of `B_n` is strictly negative.
   This holds unconditionally, with no bound on `n`.

3. **Breaking the stated boundary** (`realRooted8`, `realRooted9`, `realRooted10`).
   Using finer *rational* brackets we prove real-rootedness for `n = 8, 9, 10`, past the
   integer-bracket obstruction, and package everything into
   `eulerianSquare_realRooted` for all `n ≤ 10`, together with the strengthened
   `eulerianSquare_realRooted_neg`: for `n ≤ 10` the polynomial splits *and* all its
   roots are real and strictly negative.

## Main results

* `sqCoeff`, `sqPoly`, `eulPoly` — the squared-triangle entries, their row polynomial,
  and the Eulerian polynomials.
* `sqPoly_eq_sum_eulPoly` — `B_n = ∑_j A(n,j) · A_j`.
* `sqPoly_root_neg` — every real root of `B_n` is negative (all `n`).
* `eulerianSquare_realRooted` — `B_n` is real-rooted for every `n ≤ 10`.
* `eulerianSquare_realRooted_neg` — `B_n` splits with all roots real and negative
  (`n ≤ 10`).
-/

namespace Catalog.EulerianSquareDeepening

open Polynomial Finset

/-! ### Eulerian numbers (self-contained) -/

/-- The Eulerian numbers, defined by the triangular recurrence
`A(n+1,k+1) = (k+2)·A(n,k+1) + (n-k)·A(n,k)`. -/
def eul : ℕ → ℕ → ℕ
  | 0, 0 => 1
  | 0, (_ + 1) => 0
  | (_ + 1), 0 => 1
  | (n + 1), (k + 1) => (k + 2) * eul n (k + 1) + (n - k) * eul n k

@[simp] lemma eul_zero_zero : eul 0 0 = 1 := rfl
@[simp] lemma eul_zero_succ (k : ℕ) : eul 0 (k + 1) = 0 := rfl
@[simp] lemma eul_succ_zero (n : ℕ) : eul (n + 1) 0 = 1 := rfl

lemma eul_succ_succ (n k : ℕ) :
    eul (n + 1) (k + 1) = (k + 2) * eul n (k + 1) + (n - k) * eul n k := rfl

/-- `eul n 0 = 1` for every `n`. -/
@[simp] lemma eul_zero (n : ℕ) : eul n 0 = 1 := by cases n <;> rfl

/-- Above the diagonal the Eulerian numbers vanish. -/
lemma eul_eq_zero_of_lt : ∀ n k, n < k → eul n k = 0 := by
  intro n k; induction' n with n ih generalizing k; induction' k with k ih <;>
    simp_all +arith +decide
  rcases k with ( _ | _ | k ) <;> simp_all +arith +decide [ eul_succ_succ ]
  grind

/-! ### The squared triangle and its row polynomials -/

/-- The `n`-th **Eulerian polynomial** `A_n(x) = ∑_k A(n, k) x^k`. -/
noncomputable def eulPoly (n : ℕ) : ℝ[X] := ∑ k ∈ Finset.range (n + 1), C ((eul n k : ℝ)) * X ^ k

/-- The `(n, k)` entry of the **square of the Eulerian triangle**:
`C(n, k) = ∑_j A(n, j) · A(j, k)`. -/
def sqCoeff (n k : ℕ) : ℕ := ∑ j ∈ Finset.range (n + 1), eul n j * eul j k

/-- The `n`-th **row generating polynomial** of the squared Eulerian triangle,
`B_n(x) = ∑_k C(n, k) x^k`, over the reals. -/
noncomputable def sqPoly (n : ℕ) : ℝ[X] :=
  ∑ k ∈ Finset.range (n + 1), C ((sqCoeff n k : ℝ)) * X ^ k

/-- A real polynomial is **real-rooted** when it splits into linear factors over `ℝ`. -/
def RealRooted (p : ℝ[X]) : Prop := p.Splits

/-! ### General engines -/

/-- **Quadratic real-rootedness.**  A monic real quadratic with nonnegative discriminant
splits into two real linear factors. -/
theorem quadratic_splits (b c : ℝ) (h : b ^ 2 - 4 * c ≥ 0) :
    (X ^ 2 + C b * X + C c).Splits := by
  set s : ℝ := Real.sqrt (b ^ 2 - 4 * c) with hs
  have hs2 : s ^ 2 = b ^ 2 - 4 * c := Real.sq_sqrt h
  have hfac : (X ^ 2 + C b * X + C c)
      = (X - C ((-b + s) / 2)) * (X - C ((-b - s) / 2)) := by
    have e1 : ((-b + s) / 2) * ((-b - s) / 2) = c := by nlinarith [hs2]
    have e2 : (X - C ((-b + s) / 2)) * (X - C ((-b - s) / 2))
        = X ^ 2 - C (((-b + s) / 2) + ((-b - s) / 2)) * X
          + C (((-b + s) / 2) * ((-b - s) / 2)) := by
      rw [C_add, C_mul]; ring
    rw [e2, e1]
    congr 2
    · rw [show ((-b + s) / 2) + ((-b - s) / 2) = -b by ring, C_neg]; ring
  rw [hfac]
  exact (Polynomial.Splits.X_sub_C _).mul (Polynomial.Splits.X_sub_C _)

/-- **Distinct roots force a split.**  A nonzero real polynomial of degree `m` with `m`
distinct real roots splits into linear factors over `ℝ`. -/
theorem splits_of_distinct_roots (p : ℝ[X]) (hp0 : p ≠ 0) (S : Finset ℝ)
    (hcard : S.card = p.natDegree) (hroots : ∀ x ∈ S, p.eval x = 0) : p.Splits := by
  rw [Polynomial.splits_iff_card_roots]
  have hsub : S ⊆ p.roots.toFinset := by
    intro x hx
    rw [Multiset.mem_toFinset, Polynomial.mem_roots hp0]
    exact hroots x hx
  have h1 : S.card ≤ p.roots.toFinset.card := Finset.card_le_card hsub
  have h2 : p.roots.toFinset.card ≤ p.roots.card := Multiset.toFinset_card_le _
  have h3 : p.roots.card ≤ p.natDegree := Polynomial.card_roots' p
  omega

/-- **Sign-change root existence.**  A continuous function with opposite signs at the ends
of an interval has an interior zero.  This is direction-agnostic: only the sign of the
*product* `g a · g b` is needed. -/
theorem root_between {g : ℝ → ℝ} (hg : Continuous g) {a b : ℝ} (hab : a ≤ b)
    (hs : g a * g b < 0) : ∃ x, a < x ∧ x < b ∧ g x = 0 := by
  rcases lt_or_gt_of_ne (show g a ≠ 0 by intro h; rw [h] at hs; simp at hs) with ha | ha
  · have hb : 0 < g b := by nlinarith
    obtain ⟨x, hx, hxe⟩ := (intermediate_value_Ioo hab hg.continuousOn) ⟨ha, hb⟩
    exact ⟨x, hx.1, hx.2, hxe⟩
  · have hb : g b < 0 := by nlinarith
    obtain ⟨x, hx, hxe⟩ := (intermediate_value_Ioo' hab hg.continuousOn) ⟨hb, ha⟩
    exact ⟨x, hx.1, hx.2, hxe⟩

/-! ### Structural identity: `B_n = ∑_j A(n,j)·A_j` -/

/-
For `j ≤ n`, the truncated sum `∑_{k<n+1} A(j,k) x^k` is exactly the Eulerian
polynomial `A_j`, because `A(j, k) = 0` whenever `k > j`.
-/
theorem eulPoly_extend (j n : ℕ) (h : j ≤ n) :
    ∑ k ∈ Finset.range (n + 1), C ((eul j k : ℝ)) * X ^ k = eulPoly j := by
  unfold eulPoly;
  rw [ Finset.sum_subset ( Finset.range_mono ( by linarith : j + 1 ≤ n + 1 ) ) ];
  exact fun x hx₁ hx₂ => by rw [ eul_eq_zero_of_lt j x ( by linarith [ Finset.mem_range.mp hx₁, Finset.mem_range.not.mp hx₂ ] ) ] ; norm_num;

/-
**Structural identity.**  The row polynomial of the squared Eulerian triangle is the
`A(n, ·)`-weighted sum of Eulerian polynomials:
`B_n(x) = ∑_j A(n, j) · A_j(x)`.  This realizes `B_n` as a nonnegative combination of the
Eulerian polynomials.
-/
theorem sqPoly_eq_sum_eulPoly (n : ℕ) :
    sqPoly n = ∑ j ∈ Finset.range (n + 1), C ((eul n j : ℝ)) * eulPoly j := by
  unfold sqPoly eulPoly;
  simp +decide [ sqCoeff, Finset.mul_sum _ _ _ ];
  simp +decide only [Finset.sum_mul, mul_assoc];
  rw [ Finset.sum_comm ];
  refine' Finset.sum_congr rfl fun i hi => _;
  rw [ ← Finset.sum_subset ( Finset.range_mono ( Nat.succ_le_succ ( Finset.mem_range_succ_iff.mp hi ) ) ) ];
  simp +zetaDelta at *;
  exact fun x hx hx' => Or.inr <| eul_eq_zero_of_lt _ _ hx'

/-! ### General negativity of the roots (all `n`) -/

/-
The leading column of the squared triangle is positive: `1 ≤ C(n, 0)`.
-/
theorem sqCoeff_zero_pos (n : ℕ) : 1 ≤ sqCoeff n 0 := by
  exact Finset.single_le_sum ( fun j _ => Nat.zero_le ( eul n j * eul j 0 ) ) ( Finset.mem_range.mpr ( Nat.succ_pos _ ) ) |> le_trans ( by simp +decide [ eul_zero ] )

/-
**Positivity on the nonnegative axis.**  For every `n` and every `x ≥ 0`,
`B_n(x) > 0`.  (All coefficients are nonnegative and the constant term is positive.)
-/
theorem sqPoly_eval_pos_of_nonneg (n : ℕ) {x : ℝ} (hx : 0 ≤ x) :
    0 < (sqPoly n).eval x := by
  -- Both `sqPoly n` and `eulPoly n` have nonnegative coefficients (encoded as `RealRooted`).
  have h_sqPoly_nonneg_coeff (n k : ℕ) : 0 ≤ (sqCoeff n k : ℝ) := by
    positivity;
  rw [ sqPoly ];
  norm_num [ Polynomial.eval_finset_sum ];
  exact lt_of_lt_of_le ( by exact mul_pos ( mod_cast sqCoeff_zero_pos n ) ( pow_pos ( show 0 < x + 1 by linarith ) 0 ) ) ( Finset.single_le_sum ( fun i _ => mul_nonneg ( h_sqPoly_nonneg_coeff n i ) ( pow_nonneg hx i ) ) ( Finset.mem_range.mpr ( Nat.succ_pos _ ) ) )

/-- **General negativity of roots.**  Every real root of `B_n` is strictly negative, for
every `n`.  This is unconditional — no bound on `n`, and no real-rootedness needed. -/
theorem sqPoly_root_neg (n : ℕ) {x : ℝ} (hxe : (sqPoly n).eval x = 0) : x < 0 := by
  by_contra hxn
  push_neg at hxn
  have := sqPoly_eval_pos_of_nonneg n hxn
  rw [hxe] at this
  exact lt_irrefl 0 this

/-! ### Explicit row polynomials -/

theorem sqPoly0 : sqPoly 0 = C 1 := by
  simp only [sqPoly, Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num [show sqCoeff 0 0 = 1 from by decide]

theorem sqPoly1 : sqPoly 1 = C 1 := by
  simp only [sqPoly, Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num [show sqCoeff 1 0 = 1 from by decide, show sqCoeff 1 1 = 0 from by decide]

theorem sqPoly2 : sqPoly 2 = C 2 := by
  simp only [sqPoly, Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num [show sqCoeff 2 0 = 2 from by decide, show sqCoeff 2 1 = 0 from by decide,
    show sqCoeff 2 2 = 0 from by decide]

theorem sqPoly3 : sqPoly 3 = X + C 6 := by
  simp only [sqPoly, Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num [show sqCoeff 3 0 = 6 from by decide, show sqCoeff 3 1 = 1 from by decide,
    show sqCoeff 3 2 = 0 from by decide, show sqCoeff 3 3 = 0 from by decide]
  ring

theorem sqPoly4 : sqPoly 4 = X ^ 2 + C 15 * X + C 24 := by
  simp only [sqPoly, Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num [show sqCoeff 4 0 = 24 from by decide, show sqCoeff 4 1 = 15 from by decide,
    show sqCoeff 4 2 = 1 from by decide, show sqCoeff 4 3 = 0 from by decide,
    show sqCoeff 4 4 = 0 from by decide]
  ring

theorem sqPoly5 : sqPoly 5 = X ^ 3 + C 37 * X ^ 2 + C 181 * X + C 120 := by
  simp only [sqPoly, Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num [show sqCoeff 5 0 = 120 from by decide, show sqCoeff 5 1 = 181 from by decide,
    show sqCoeff 5 2 = 37 from by decide, show sqCoeff 5 3 = 1 from by decide,
    show sqCoeff 5 4 = 0 from by decide, show sqCoeff 5 5 = 0 from by decide]
  ring

theorem sqPoly6 :
    sqPoly 6 = X ^ 4 + C 83 * X ^ 3 + C 995 * X ^ 2 + C 2163 * X + C 720 := by
  simp only [sqPoly, Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num [show sqCoeff 6 0 = 720 from by decide, show sqCoeff 6 1 = 2163 from by decide,
    show sqCoeff 6 2 = 995 from by decide, show sqCoeff 6 3 = 83 from by decide,
    show sqCoeff 6 4 = 1 from by decide, show sqCoeff 6 5 = 0 from by decide,
    show sqCoeff 6 6 = 0 from by decide]
  ring

theorem sqPoly7 : sqPoly 7 =
    X ^ 5 + C 177 * X ^ 4 + C 4613 * X ^ 3 + C 23739 * X ^ 2 + C 27133 * X + C 5040 := by
  simp only [sqPoly, Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num [show sqCoeff 7 0 = 5040 from by decide, show sqCoeff 7 1 = 27133 from by decide,
    show sqCoeff 7 2 = 23739 from by decide, show sqCoeff 7 3 = 4613 from by decide,
    show sqCoeff 7 4 = 177 from by decide, show sqCoeff 7 5 = 1 from by decide,
    show sqCoeff 7 6 = 0 from by decide, show sqCoeff 7 7 = 0 from by decide]
  ring

theorem sqPoly8 : sqPoly 8 =
    X ^ 6 + C 367 * X ^ 5 + C 19563 * X ^ 4 + C 204247 * X ^ 3 + C 546551 * X ^ 2
      + C 364395 * X + C 40320 := by
  simp only [sqPoly, Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num [show sqCoeff 8 0 = 40320 from by decide, show sqCoeff 8 1 = 364395 from by decide,
    show sqCoeff 8 2 = 546551 from by decide, show sqCoeff 8 3 = 204247 from by decide,
    show sqCoeff 8 4 = 19563 from by decide, show sqCoeff 8 5 = 367 from by decide,
    show sqCoeff 8 6 = 1 from by decide, show sqCoeff 8 7 = 0 from by decide,
    show sqCoeff 8 8 = 0 from by decide]
  ring

theorem sqPoly9 : sqPoly 9 =
    X ^ 7 + C 749 * X ^ 6 + C 79141 * X ^ 5 + C 1534391 * X ^ 4 + C 8090341 * X ^ 3
      + C 12643559 * X ^ 2 + C 5272861 * X + C 362880 := by
  simp only [sqPoly, Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num [show sqCoeff 9 0 = 362880 from by decide, show sqCoeff 9 1 = 5272861 from by decide,
    show sqCoeff 9 2 = 12643559 from by decide, show sqCoeff 9 3 = 8090341 from by decide,
    show sqCoeff 9 4 = 1534391 from by decide, show sqCoeff 9 5 = 79141 from by decide,
    show sqCoeff 9 6 = 749 from by decide, show sqCoeff 9 7 = 1 from by decide,
    show sqCoeff 9 8 = 0 from by decide, show sqCoeff 9 9 = 0 from by decide]
  ring

theorem sqPoly10 : sqPoly 10 =
    X ^ 8 + C 1515 * X ^ 7 + C 312659 * X ^ 6 + C 10633035 * X ^ 5 + C 100211975 * X ^ 4
      + C 304339263 * X ^ 3 + C 300161291 * X ^ 2 + C 82289163 * X + C 3628800 := by
  simp only [sqPoly, Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num [show sqCoeff 10 0 = 3628800 from by decide, show sqCoeff 10 1 = 82289163 from by decide,
    show sqCoeff 10 2 = 300161291 from by decide, show sqCoeff 10 3 = 304339263 from by decide,
    show sqCoeff 10 4 = 100211975 from by decide, show sqCoeff 10 5 = 10633035 from by decide,
    show sqCoeff 10 6 = 312659 from by decide, show sqCoeff 10 7 = 1515 from by decide,
    show sqCoeff 10 8 = 1 from by decide, show sqCoeff 10 9 = 0 from by decide,
    show sqCoeff 10 10 = 0 from by decide]
  ring

/-! ### Real-rootedness row by row -/

theorem realRooted0 : RealRooted (sqPoly 0) := by
  rw [RealRooted, sqPoly0]
  exact Polynomial.Splits.of_natDegree_le_one (by compute_degree!)

theorem realRooted1 : RealRooted (sqPoly 1) := by
  rw [RealRooted, sqPoly1]
  exact Polynomial.Splits.of_natDegree_le_one (by compute_degree!)

theorem realRooted2 : RealRooted (sqPoly 2) := by
  rw [RealRooted, sqPoly2]
  exact Polynomial.Splits.of_natDegree_le_one (by compute_degree!)

theorem realRooted3 : RealRooted (sqPoly 3) := by
  rw [RealRooted, sqPoly3]
  exact Polynomial.Splits.of_natDegree_le_one (by compute_degree!)

theorem realRooted4 : RealRooted (sqPoly 4) := by
  rw [RealRooted, sqPoly4]
  exact quadratic_splits 15 24 (by norm_num)

theorem realRooted5 : RealRooted (sqPoly 5) := by
  rw [RealRooted, sqPoly5]
  set p : ℝ[X] := X ^ 3 + C 37 * X ^ 2 + C 181 * X + C 120 with hp
  set f : ℝ → ℝ := fun x => p.eval x with hf
  have hcont : Continuous f := by fun_prop
  obtain ⟨r1, hr1a, hr1b, hr1e⟩ := root_between hcont (show (-40 : ℝ) ≤ -5 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r2, hr2a, hr2b, hr2e⟩ := root_between hcont (show (-5 : ℝ) ≤ -1 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r3, hr3a, hr3b, hr3e⟩ := root_between hcont (show (-1 : ℝ) ≤ 0 by norm_num)
    (by norm_num [hf, hp])
  have hdeg : p.natDegree = 3 := by rw [hp]; compute_degree!
  have hp0 : p ≠ 0 := by
    intro h; rw [h, natDegree_zero] at hdeg; exact absurd hdeg (by norm_num)
  refine splits_of_distinct_roots p hp0 {r1, r2, r3} ?_ ?_
  · rw [hdeg]
    rw [Finset.card_insert_of_notMem, Finset.card_insert_of_notMem, Finset.card_singleton]
    · simp only [Finset.mem_singleton]; linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg; constructor <;> linarith
  · intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with h | h | h <;> subst h <;> assumption

theorem realRooted6 : RealRooted (sqPoly 6) := by
  rw [RealRooted, sqPoly6]
  set p : ℝ[X] := X ^ 4 + C 83 * X ^ 3 + C 995 * X ^ 2 + C 2163 * X + C 720 with hp
  set f : ℝ → ℝ := fun x => p.eval x with hf
  have hcont : Continuous f := by fun_prop
  obtain ⟨r1, hr1a, hr1b, hr1e⟩ := root_between hcont (show (-70 : ℝ) ≤ -69 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r2, hr2a, hr2b, hr2e⟩ := root_between hcont (show (-12 : ℝ) ≤ -11 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r3, hr3a, hr3b, hr3e⟩ := root_between hcont (show (-3 : ℝ) ≤ -2 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r4, hr4a, hr4b, hr4e⟩ := root_between hcont (show (-1 : ℝ) ≤ 0 by norm_num)
    (by norm_num [hf, hp])
  have hdeg : p.natDegree = 4 := by rw [hp]; compute_degree!
  have hp0 : p ≠ 0 := by
    intro h; rw [h, natDegree_zero] at hdeg; exact absurd hdeg (by norm_num)
  refine splits_of_distinct_roots p hp0 {r1, r2, r3, r4} ?_ ?_
  · rw [hdeg]
    rw [Finset.card_insert_of_notMem, Finset.card_insert_of_notMem,
        Finset.card_insert_of_notMem, Finset.card_singleton]
    · simp only [Finset.mem_singleton]; linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg; constructor <;> linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg; refine ⟨?_, ?_, ?_⟩ <;> linarith
  · intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with h | h | h | h <;> subst h <;> assumption

theorem realRooted7 : RealRooted (sqPoly 7) := by
  rw [RealRooted, sqPoly7]
  set p : ℝ[X] :=
    X ^ 5 + C 177 * X ^ 4 + C 4613 * X ^ 3 + C 23739 * X ^ 2 + C 27133 * X + C 5040 with hp
  set f : ℝ → ℝ := fun x => p.eval x with hf
  have hcont : Continuous f := by fun_prop
  obtain ⟨r1, hr1a, hr1b, hr1e⟩ := root_between hcont (show (-147 : ℝ) ≤ -146 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r2, hr2a, hr2b, hr2e⟩ := root_between hcont (show (-24 : ℝ) ≤ -23 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r3, hr3a, hr3b, hr3e⟩ := root_between hcont (show (-5 : ℝ) ≤ -4 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r4, hr4a, hr4b, hr4e⟩ := root_between hcont (show (-2 : ℝ) ≤ -1 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r5, hr5a, hr5b, hr5e⟩ := root_between hcont (show (-1 : ℝ) ≤ 0 by norm_num)
    (by norm_num [hf, hp])
  have hdeg : p.natDegree = 5 := by rw [hp]; compute_degree!
  have hp0 : p ≠ 0 := by
    intro h; rw [h, natDegree_zero] at hdeg; exact absurd hdeg (by norm_num)
  refine splits_of_distinct_roots p hp0 {r1, r2, r3, r4, r5} ?_ ?_
  · rw [hdeg]
    rw [Finset.card_insert_of_notMem, Finset.card_insert_of_notMem,
        Finset.card_insert_of_notMem, Finset.card_insert_of_notMem, Finset.card_singleton]
    · simp only [Finset.mem_singleton]; linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg; constructor <;> linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg; refine ⟨?_, ?_, ?_⟩ <;> linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg
      refine ⟨?_, ?_, ?_, ?_⟩ <;> linarith
  · intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with h | h | h | h | h <;> subst h <;> assumption

/-- **Breaking the integer-bracket boundary (`n = 8`).**  `B_8` has two roots in `(-1, 0)`,
so consecutive integers fail to separate them; finer rational brackets `(-1, -1/2)` and
`(-1/2, 0)` do. -/
theorem realRooted8 : RealRooted (sqPoly 8) := by
  rw [RealRooted, sqPoly8]
  set p : ℝ[X] := X ^ 6 + C 367 * X ^ 5 + C 19563 * X ^ 4 + C 204247 * X ^ 3
    + C 546551 * X ^ 2 + C 364395 * X + C 40320 with hp
  set f : ℝ → ℝ := fun x => p.eval x with hf
  have hcont : Continuous f := by fun_prop
  obtain ⟨r1, hr1a, hr1b, hr1e⟩ := root_between hcont (show (-306 : ℝ) ≤ -305 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r2, hr2a, hr2b, hr2e⟩ := root_between hcont (show (-50 : ℝ) ≤ -49 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r3, hr3a, hr3b, hr3e⟩ := root_between hcont (show (-10 : ℝ) ≤ -9 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r4, hr4a, hr4b, hr4e⟩ := root_between hcont (show (-3 : ℝ) ≤ -2 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r5, hr5a, hr5b, hr5e⟩ := root_between hcont (show (-1 : ℝ) ≤ -1/2 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r6, hr6a, hr6b, hr6e⟩ := root_between hcont (show (-1/2 : ℝ) ≤ 0 by norm_num)
    (by norm_num [hf, hp])
  have hdeg : p.natDegree = 6 := by rw [hp]; compute_degree!
  have hp0 : p ≠ 0 := by
    intro h; rw [h, natDegree_zero] at hdeg; exact absurd hdeg (by norm_num)
  refine splits_of_distinct_roots p hp0 {r1, r2, r3, r4, r5, r6} ?_ ?_
  · rw [hdeg]
    rw [Finset.card_insert_of_notMem, Finset.card_insert_of_notMem,
        Finset.card_insert_of_notMem, Finset.card_insert_of_notMem,
        Finset.card_insert_of_notMem, Finset.card_singleton]
    · simp only [Finset.mem_singleton]; linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg; constructor <;> linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg; refine ⟨?_, ?_, ?_⟩ <;> linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg; refine ⟨?_, ?_, ?_, ?_⟩ <;> linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg
      refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> linarith
  · intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with h | h | h | h | h | h <;> subst h <;> assumption

/-- Real-rootedness at `n = 9` (seven distinct real roots, rational brackets near `0`). -/
theorem realRooted9 : RealRooted (sqPoly 9) := by
  rw [RealRooted, sqPoly9]
  set p : ℝ[X] := X ^ 7 + C 749 * X ^ 6 + C 79141 * X ^ 5 + C 1534391 * X ^ 4
    + C 8090341 * X ^ 3 + C 12643559 * X ^ 2 + C 5272861 * X + C 362880 with hp
  set f : ℝ → ℝ := fun x => p.eval x with hf
  have hcont : Continuous f := by fun_prop
  obtain ⟨r1, hr1a, hr1b, hr1e⟩ := root_between hcont (show (-627 : ℝ) ≤ -626 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r2, hr2a, hr2b, hr2e⟩ := root_between hcont (show (-100 : ℝ) ≤ -99 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r3, hr3a, hr3b, hr3e⟩ := root_between hcont (show (-16 : ℝ) ≤ -15 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r4, hr4a, hr4b, hr4e⟩ := root_between hcont (show (-5 : ℝ) ≤ -4 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r5, hr5a, hr5b, hr5e⟩ := root_between hcont (show (-2 : ℝ) ≤ -1 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r6, hr6a, hr6b, hr6e⟩ := root_between hcont (show (-1 : ℝ) ≤ -1/2 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r7, hr7a, hr7b, hr7e⟩ := root_between hcont (show (-1/2 : ℝ) ≤ 0 by norm_num)
    (by norm_num [hf, hp])
  have hdeg : p.natDegree = 7 := by rw [hp]; compute_degree!
  have hp0 : p ≠ 0 := by
    intro h; rw [h, natDegree_zero] at hdeg; exact absurd hdeg (by norm_num)
  refine splits_of_distinct_roots p hp0 {r1, r2, r3, r4, r5, r6, r7} ?_ ?_
  · rw [hdeg]
    rw [Finset.card_insert_of_notMem, Finset.card_insert_of_notMem,
        Finset.card_insert_of_notMem, Finset.card_insert_of_notMem,
        Finset.card_insert_of_notMem, Finset.card_insert_of_notMem, Finset.card_singleton]
    · simp only [Finset.mem_singleton]; linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg; constructor <;> linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg; refine ⟨?_, ?_, ?_⟩ <;> linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg; refine ⟨?_, ?_, ?_, ?_⟩ <;> linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg
      refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg
      refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> linarith
  · intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with h | h | h | h | h | h | h <;> subst h <;> assumption

/-- Real-rootedness at `n = 10` (eight distinct real roots, rational brackets near `0`). -/
theorem realRooted10 : RealRooted (sqPoly 10) := by
  rw [RealRooted, sqPoly10]
  set p : ℝ[X] := X ^ 8 + C 1515 * X ^ 7 + C 312659 * X ^ 6 + C 10633035 * X ^ 5
    + C 100211975 * X ^ 4 + C 304339263 * X ^ 3 + C 300161291 * X ^ 2 + C 82289163 * X
    + C 3628800 with hp
  set f : ℝ → ℝ := fun x => p.eval x with hf
  have hcont : Continuous f := by fun_prop
  obtain ⟨r1, hr1a, hr1b, hr1e⟩ := root_between hcont (show (-1277 : ℝ) ≤ -1276 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r2, hr2a, hr2b, hr2e⟩ := root_between hcont (show (-199 : ℝ) ≤ -198 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r3, hr3a, hr3b, hr3e⟩ := root_between hcont (show (-27 : ℝ) ≤ -26 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r4, hr4a, hr4b, hr4e⟩ := root_between hcont (show (-9 : ℝ) ≤ -8 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r5, hr5a, hr5b, hr5e⟩ := root_between hcont (show (-4 : ℝ) ≤ -3 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r6, hr6a, hr6b, hr6e⟩ := root_between hcont (show (-2 : ℝ) ≤ -1 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r7, hr7a, hr7b, hr7e⟩ := root_between hcont (show (-1/2 : ℝ) ≤ -1/4 by norm_num)
    (by norm_num [hf, hp])
  obtain ⟨r8, hr8a, hr8b, hr8e⟩ := root_between hcont (show (-1/4 : ℝ) ≤ 0 by norm_num)
    (by norm_num [hf, hp])
  have hdeg : p.natDegree = 8 := by rw [hp]; compute_degree!
  have hp0 : p ≠ 0 := by
    intro h; rw [h, natDegree_zero] at hdeg; exact absurd hdeg (by norm_num)
  refine splits_of_distinct_roots p hp0 {r1, r2, r3, r4, r5, r6, r7, r8} ?_ ?_
  · rw [hdeg]
    rw [Finset.card_insert_of_notMem, Finset.card_insert_of_notMem,
        Finset.card_insert_of_notMem, Finset.card_insert_of_notMem,
        Finset.card_insert_of_notMem, Finset.card_insert_of_notMem,
        Finset.card_insert_of_notMem, Finset.card_singleton]
    · simp only [Finset.mem_singleton]; linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg; constructor <;> linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg; refine ⟨?_, ?_, ?_⟩ <;> linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg; refine ⟨?_, ?_, ?_, ?_⟩ <;> linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg
      refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg
      refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> linarith
    · simp only [Finset.mem_insert, Finset.mem_singleton]; push_neg
      refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> linarith
  · intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with h | h | h | h | h | h | h | h <;> subst h <;> assumption

/-! ### Capstone theorems -/

/-- **Extended main theorem.**  The row polynomial `B_n` of the square of the Eulerian
triangle is real-rooted for every `n ≤ 10`, extending the previous bound `n ≤ 7` past the
integer-bracket obstruction at `n = 8`. -/
theorem eulerianSquare_realRooted (n : ℕ) (hn : n ≤ 10) : RealRooted (sqPoly n) := by
  interval_cases n
  · exact realRooted0
  · exact realRooted1
  · exact realRooted2
  · exact realRooted3
  · exact realRooted4
  · exact realRooted5
  · exact realRooted6
  · exact realRooted7
  · exact realRooted8
  · exact realRooted9
  · exact realRooted10

/-- **Strengthened main theorem.**  For every `n ≤ 10`, `B_n` splits into real linear
factors *and* every one of its roots is strictly negative. -/
theorem eulerianSquare_realRooted_neg (n : ℕ) (hn : n ≤ 10) :
    RealRooted (sqPoly n) ∧ ∀ x : ℝ, (sqPoly n).eval x = 0 → x < 0 :=
  ⟨eulerianSquare_realRooted n hn, fun _ hx => sqPoly_root_neg n hx⟩

end Catalog.EulerianSquareDeepening