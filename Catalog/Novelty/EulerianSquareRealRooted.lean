/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import NumberTheory.EulerianNumbers

/-!
# Real-rootedness of the square of the Eulerian triangle

The *Eulerian number* `A(n, k)` counts the permutations of `{1, …, n}` with exactly `k`
descents.  Arranging them in a lower-triangular array gives the **Eulerian triangle**.
Squaring this triangle as an (infinite, lower-triangular) matrix produces a new triangle
whose `(n, k)` entry is

  `C(n, k) = ∑_j A(n, j) · A(j, k)`.

The associated **row generating polynomial** is

  `B_n(x) = ∑_k C(n, k) · x^k`.

A classical theme in enumerative combinatorics asks which combinatorial triangles have
*real-rooted* row polynomials, and whether real-rootedness is preserved under natural
matrix operations such as squaring.  For the Pascal, Stirling and Narayana triangles the
square is known to preserve real-rootedness; the Eulerian case is subtler because the
Eulerian polynomials themselves are real-rooted but their nonnegative combinations need
not be.

This file develops the object `B_n` from the catalog's Eulerian numbers
(`NumberTheory.EulerianNumbers`) and proves, with fully explicit root separation, that
`B_n` is real-rooted (splits into linear factors over `ℝ`) for every `n ≤ 7`.  The engine
is a reusable "distinct real roots force a split" lemma combined with the intermediate
value theorem applied at explicit integer brackets, plus a self-contained quadratic
splitting lemma driven by the discriminant.

## Main results

* `sqCoeff`, `sqPoly` — the squared-triangle entries and their row polynomial.
* `RealRooted` — the predicate "splits into linear factors over `ℝ`", i.e. all roots real.
* `quadratic_splits` — every real quadratic with nonnegative discriminant is real-rooted.
* `splits_of_distinct_roots` — a degree-`m` polynomial with `m` distinct real roots splits.
* `eulerianSquare_realRooted` — `B_n` is real-rooted for every `n ≤ 7`.

-- !-- Lab Notes -- !--

**Hypothesis.**  For every `n`, the row polynomial `B_n` of the squared Eulerian triangle
is real-rooted.  This is the Eulerian analogue of the (known) real-rootedness of the
squares of the Pascal, Stirling and Narayana triangles.

**Experiment.**  Computing the first rows gives
`B_0 = 1`, `B_1 = 1`, `B_2 = 2`, `B_3 = x + 6`, `B_4 = x² + 15x + 24`,
`B_5 = x³ + 37x² + 181x + 120`, `B_6 = x⁴ + 83x³ + 995x² + 2163x + 720`,
`B_7 = x⁵ + 177x⁴ + 4613x³ + 23739x² + 27133x + 5040`.
Numerically every root is real, negative and simple.  We prove real-rootedness for each of
these rows: the constant/linear rows by degree, `B_4` by the discriminant, and `B_5..B_7`
by exhibiting the required number of distinct real roots via the intermediate value theorem
at explicit integer brackets, which then forces a split by a root-counting bound.

**Analysis.**  The decisive structural fact is `splits_of_distinct_roots`: for a nonzero
polynomial, a set of `natDegree`-many distinct roots already saturates the root-count bound
`#roots ≤ natDegree`, hence the polynomial splits.  This reduces real-rootedness to a
*finite root-separation* problem, discharged by sign changes.  The rows are monic with
constant term `n!` and all roots negative — consistent with the conjectural real-rootedness
for all `n`.

**Critique.**  The results are not vacuous: each `B_n` for `n ≥ 4` has genuinely irrational
roots, so the split is not witnessed by rational factors and the discriminant/IVT arguments
are doing real work.  The boundary of the method is `n = 8`: there `B_8` has two roots in
`(-1, 0)`, so consecutive-integer brackets no longer separate all roots — finer (rational)
brackets are needed, which is exactly the obstruction that makes the fully general statement
open.

**Synthesis.**  Real-rootedness of the squared Eulerian triangle holds for all tested rows
and reduces, uniformly, to explicit real root separation.  The general statement remains a
bold open conjecture; see `FUTURE_DIRECTIONS.md`.
-/

namespace Catalog.EulerianSquareRealRooted

open Polynomial Finset Catalog.EulerianNumbers

/-- The `(n, k)` entry of the **square of the Eulerian triangle**:
`C(n, k) = ∑_j A(n, j) · A(j, k)`, using the catalog's Eulerian numbers `eul`. -/
def sqCoeff (n k : ℕ) : ℕ := ∑ j ∈ Finset.range (n + 1), eul n j * eul j k

/-- The `n`-th **row generating polynomial** of the squared Eulerian triangle,
`B_n(x) = ∑_k C(n, k) · x^k`, viewed over the reals. -/
noncomputable def sqPoly (n : ℕ) : ℝ[X] :=
  ∑ k ∈ Finset.range (n + 1), C ((sqCoeff n k : ℝ)) * X ^ k

/-- A real polynomial is **real-rooted** when it splits into linear factors over `ℝ`,
equivalently all of its complex roots are real. -/
def RealRooted (p : ℝ[X]) : Prop := p.Splits

/-! ### Concrete examples (PEGB: examples) -/

-- The first eight entries of the leading column are the factorials `n!`.
example : sqCoeff 0 0 = 1 := by decide
example : sqCoeff 4 0 = 24 := by decide
example : sqCoeff 5 0 = 120 := by decide

#check @sqPoly
#check @RealRooted

/-! ### General real-rootedness engines -/

/-- **Quadratic real-rootedness.**  A monic real quadratic with nonnegative discriminant
splits into two real linear factors, given explicitly through the square root of the
discriminant. -/
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

/-- **Distinct roots force a split.**  If a nonzero real polynomial of degree `m` has a set
of `m` distinct real roots, then it splits into linear factors over `ℝ`.  This is the
finite-separation reduction of real-rootedness. -/
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

/-- Intermediate value theorem, ascending form: a continuous real function that is negative
at `a` and positive at `b` has a zero strictly between them. -/
theorem root_pos {g : ℝ → ℝ} (hg : Continuous g) {a b : ℝ} (hab : a ≤ b)
    (ha : g a < 0) (hb : 0 < g b) : ∃ x, a < x ∧ x < b ∧ g x = 0 := by
  obtain ⟨x, hx, hxe⟩ := (intermediate_value_Ioo hab hg.continuousOn) ⟨ha, hb⟩
  exact ⟨x, hx.1, hx.2, hxe⟩

/-- Intermediate value theorem, descending form: a continuous real function that is positive
at `a` and negative at `b` has a zero strictly between them. -/
theorem root_neg {g : ℝ → ℝ} (hg : Continuous g) {a b : ℝ} (hab : a ≤ b)
    (ha : 0 < g a) (hb : g b < 0) : ∃ x, a < x ∧ x < b ∧ g x = 0 := by
  obtain ⟨x, hx, hxe⟩ := (intermediate_value_Ioo' hab hg.continuousOn) ⟨hb, ha⟩
  exact ⟨x, hx.1, hx.2, hxe⟩

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
  obtain ⟨r1, hr1a, hr1b, hr1e⟩ := root_pos hcont (show (-40 : ℝ) ≤ -5 by norm_num)
    (by norm_num [hf, hp]) (by norm_num [hf, hp])
  obtain ⟨r2, hr2a, hr2b, hr2e⟩ := root_neg hcont (show (-5 : ℝ) ≤ -1 by norm_num)
    (by norm_num [hf, hp]) (by norm_num [hf, hp])
  obtain ⟨r3, hr3a, hr3b, hr3e⟩ := root_pos hcont (show (-1 : ℝ) ≤ 0 by norm_num)
    (by norm_num [hf, hp]) (by norm_num [hf, hp])
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
  obtain ⟨r1, hr1a, hr1b, hr1e⟩ := root_neg hcont (show (-70 : ℝ) ≤ -69 by norm_num)
    (by norm_num [hf, hp]) (by norm_num [hf, hp])
  obtain ⟨r2, hr2a, hr2b, hr2e⟩ := root_pos hcont (show (-12 : ℝ) ≤ -11 by norm_num)
    (by norm_num [hf, hp]) (by norm_num [hf, hp])
  obtain ⟨r3, hr3a, hr3b, hr3e⟩ := root_neg hcont (show (-3 : ℝ) ≤ -2 by norm_num)
    (by norm_num [hf, hp]) (by norm_num [hf, hp])
  obtain ⟨r4, hr4a, hr4b, hr4e⟩ := root_pos hcont (show (-1 : ℝ) ≤ 0 by norm_num)
    (by norm_num [hf, hp]) (by norm_num [hf, hp])
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
  obtain ⟨r1, hr1a, hr1b, hr1e⟩ := root_pos hcont (show (-147 : ℝ) ≤ -146 by norm_num)
    (by norm_num [hf, hp]) (by norm_num [hf, hp])
  obtain ⟨r2, hr2a, hr2b, hr2e⟩ := root_neg hcont (show (-24 : ℝ) ≤ -23 by norm_num)
    (by norm_num [hf, hp]) (by norm_num [hf, hp])
  obtain ⟨r3, hr3a, hr3b, hr3e⟩ := root_pos hcont (show (-5 : ℝ) ≤ -4 by norm_num)
    (by norm_num [hf, hp]) (by norm_num [hf, hp])
  obtain ⟨r4, hr4a, hr4b, hr4e⟩ := root_neg hcont (show (-2 : ℝ) ≤ -1 by norm_num)
    (by norm_num [hf, hp]) (by norm_num [hf, hp])
  obtain ⟨r5, hr5a, hr5b, hr5e⟩ := root_pos hcont (show (-1 : ℝ) ≤ 0 by norm_num)
    (by norm_num [hf, hp]) (by norm_num [hf, hp])
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

/-- **Main theorem.**  The row generating polynomial `B_n` of the square of the Eulerian
triangle is real-rooted for every `n ≤ 7`: it splits into linear factors over `ℝ`, i.e.
all of its roots are real.  This is the Eulerian instance of the phenomenon that squaring a
combinatorial triangle preserves real-rootedness. -/
theorem eulerianSquare_realRooted (n : ℕ) (hn : n ≤ 7) : RealRooted (sqPoly n) := by
  interval_cases n
  · exact realRooted0
  · exact realRooted1
  · exact realRooted2
  · exact realRooted3
  · exact realRooted4
  · exact realRooted5
  · exact realRooted6
  · exact realRooted7

/-! ### Boundary discussion (PEGB: boundaries / generalization)

The method above is a *finite root-separation* argument: `splits_of_distinct_roots`
reduces real-rootedness to producing `natDegree`-many distinct real roots, and the
intermediate value theorem supplies them from integer sign changes.  The natural
**generalization** is the conjecture that `RealRooted (sqPoly n)` holds for *every* `n`
(and, more broadly, for every power of the Eulerian triangle).

The **boundary** of the integer-bracket technique is already visible at `n = 8`: the row
`B_8 = x⁶ + 367x⁵ + 19563x⁴ + 204247x³ + 546551x² + 364395x + 40320` has two distinct roots
inside `(-1, 0)`, so consecutive integers cannot separate all six roots.  A proof there
requires finer (rational) brackets, and no single uniform bracket family is known to work
for all `n` — which is precisely why the all-`n` statement is open. -/

end Catalog.EulerianSquareRealRooted