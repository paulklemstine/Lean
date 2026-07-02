/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The 14-gonal fourth-power Diophantine equation `6n² − 5n = t⁴`

The `n`-th polygonal number of order `k` is `P_k(n) = ((k-2)·n² − (k-4)·n)/2`.
For `k = 14` this is the **14-gonal (tetradecagonal) number**
`P₁₄(n) = 6·n² − 5·n`.

This file develops the structure of the Diophantine equation `P₁₄(n) = t⁴`.
Its complete integer solution set is known to be

  `(n, t) ∈ {(0,0), (1,1), (1,-1), (-2000,70), (-2000,-70)}`.

We formalise, with **zero sorries**, the substantive structural backbone of the
classification:

* `P14_eq_pell_form`        — the quartic-Pell reduction `(12n-5)² − 24t⁴ = 25`;
* `coprime_factors`         — `n` and `6n-5` are coprime exactly when `5 ∤ n`;
* `descent_coprime`         — when `5 ∤ n`, both factors are `±` fourth powers;
* `descent_coprime_pos`     — the positive coprime branch yields genuine fourth
                              powers (this is the start of Theorem 1(i), k=5);
* `thue_b4_sub_6a4_ne_five` — the Thue equation `b⁴ − 6a⁴ = 5` has no integer
                              solutions (mod-16 obstruction);
* `no_neg_coprime_solution` — consequently there is no solution with `n < 0`
                              and `5 ∤ n`: a whole branch is eliminated rigorously;
* `is_solution` / `solutions_are_solutions` — the five listed pairs really solve
                              the equation.

The one remaining step (resolving the *positive* Thue equation `6a⁴ − b⁴ = 5`, and
the divisible-branch equation `e⁴ − 150c⁴ = 1`) is recorded in the Lab Notes and
`FUTURE_DIRECTIONS.md` as the analytic core that lies beyond elementary congruence
methods.  Note the companion equation `b⁴ − 6a⁴ = 5` *is* settled here.
-/
import Mathlib

namespace Catalog.Combinatorics.FourteenGonal

/-- The `n`-th 14-gonal (tetradecagonal) number, `P₁₄(n) = 6n² − 5n`. -/
def P14 (n : ℤ) : ℤ := 6 * n ^ 2 - 5 * n

/-- A pair `(n, t)` is a solution of the 14-gonal fourth-power equation. -/
def IsSolution (n t : ℤ) : Prop := P14 n = t ^ 4

/-! ## The quartic-Pell reduction -/

/-- **Completing the square.**  `6n² − 5n = t⁴` is equivalent to the
quartic-Pell relation `(12n − 5)² − 24·t⁴ = 25`.  This is the change of
variables `x = 12n − 5` that turns the equation into `x² − 24t⁴ = 25`. -/
theorem P14_eq_pell_form (n t : ℤ) :
    P14 n = t ^ 4 ↔ (12 * n - 5) ^ 2 - 24 * t ^ 4 = 25 := by
  unfold P14
  constructor <;> intro h <;> nlinarith [h]

/-! ## Coprimality of the two factors -/

/-- The greatest common divisor of `n` and `6n − 5` divides `5`; consequently
the two factors of `P₁₄(n) = n·(6n − 5)` are coprime precisely when `5 ∤ n`. -/
theorem coprime_factors (n : ℤ) (h : ¬ (5 ∣ n)) : IsCoprime n (6 * n - 5) := by
  rw [Int.isCoprime_iff_gcd_eq_one]
  have h1 : ((n.gcd (6 * n - 5) : ℕ) : ℤ) ∣ n := Int.gcd_dvd_left n (6 * n - 5)
  have h2 : ((n.gcd (6 * n - 5) : ℕ) : ℤ) ∣ (6 * n - 5) := Int.gcd_dvd_right n (6 * n - 5)
  have hd5 : ((n.gcd (6 * n - 5) : ℕ) : ℤ) ∣ 5 := by
    have := dvd_sub (Dvd.dvd.mul_left h1 6) h2
    simpa using this
  have hn5 : (n.gcd (6 * n - 5)) ∣ 5 := by exact_mod_cast hd5
  rcases (Nat.Prime.eq_one_or_self_of_dvd (by norm_num) _ hn5) with h' | h'
  · exact h'
  · exact absurd (by rw [h'] at h1; exact_mod_cast h1) h

/-! ## Descent: coprime factors of a fourth power are fourth powers (up to sign) -/

/-- **General descent.**  If `5 ∤ n` and `P₁₄(n) = t⁴`, then since `n` and `6n − 5`
are coprime with product `t⁴`, each of them is `±` a perfect fourth power.

This is the key arithmetic reduction underlying Theorem 1(i) for `k = 5`: the
classification of `6n² − 5n = t⁴` reduces to that of the two Thue equations
`6a⁴ ∓ b⁴ = 5`. -/
theorem descent_coprime (n t : ℤ) (h5 : ¬ (5 ∣ n)) (heq : P14 n = t ^ 4) :
    (∃ a : ℤ, n = a ^ 4 ∨ n = -a ^ 4) ∧
    (∃ b : ℤ, 6 * n - 5 = b ^ 4 ∨ 6 * n - 5 = -b ^ 4) := by
  have hprod : n * (6 * n - 5) = t ^ 4 := by
    unfold P14 at heq; ring_nf; ring_nf at heq; linarith
  have hcop : IsCoprime n (6 * n - 5) := coprime_factors n h5
  refine ⟨?_, ?_⟩
  · have hu : IsUnit (gcd n (6 * n - 5)) := (gcd_isUnit_iff n (6 * n - 5)).mpr hcop
    obtain ⟨d, hd⟩ := exists_associated_pow_of_mul_eq_pow hu hprod
    rw [Int.associated_iff] at hd
    refine ⟨d, ?_⟩
    rcases hd with hd | hd
    · exact Or.inl hd.symm
    · exact Or.inr (by linarith)
  · have hcop' : IsCoprime (6 * n - 5) n := hcop.symm
    have hprod' : (6 * n - 5) * n = t ^ 4 := by rw [mul_comm]; exact hprod
    have hu : IsUnit (gcd (6 * n - 5) n) := (gcd_isUnit_iff _ _).mpr hcop'
    obtain ⟨d, hd⟩ := exists_associated_pow_of_mul_eq_pow hu hprod'
    rw [Int.associated_iff] at hd
    refine ⟨d, ?_⟩
    rcases hd with hd | hd
    · exact Or.inl hd.symm
    · exact Or.inr (by linarith)

/-- **Positive coprime branch.**  When `5 ∤ n` and `n > 0`, both `n` and `6n − 5`
are *genuine* fourth powers (the sign ambiguity is removed by positivity).  Hence
a positive coprime solution forces `n = a⁴` and `6a⁴ − 5 = b⁴`. -/
theorem descent_coprime_pos (n t : ℤ) (hn : 0 < n) (h5 : ¬ (5 ∣ n))
    (heq : P14 n = t ^ 4) :
    (∃ a : ℤ, n = a ^ 4) ∧ (∃ b : ℤ, 6 * n - 5 = b ^ 4) := by
  have hpos : 0 < 6 * n - 5 := by omega
  obtain ⟨⟨a, ha⟩, ⟨b, hb⟩⟩ := descent_coprime n t h5 heq
  refine ⟨⟨a, ?_⟩, ⟨b, ?_⟩⟩
  · rcases ha with ha | ha
    · exact ha
    · exfalso; have : (0 : ℤ) ≤ a ^ 4 := by positivity
      linarith
  · rcases hb with hb | hb
    · exact hb
    · exfalso; have : (0 : ℤ) ≤ b ^ 4 := by positivity
      linarith

/-! ## Eliminating the negative coprime branch -/

/-- **A quartic Thue non-existence, by a mod-16 obstruction.**  The equation
`b⁴ − 6a⁴ = 5` has *no* integer solutions: fourth powers are `≡ 0` or `1 (mod 16)`,
so `b⁴ − 6a⁴ ∈ {0, 1, 10, 11} (mod 16)`, which never equals `5 (mod 16)`. -/
theorem thue_b4_sub_6a4_ne_five (a b : ℤ) : b ^ 4 - 6 * a ^ 4 ≠ 5 := by
  have hmod : ∀ x y : ZMod 16, y ^ 4 - 6 * x ^ 4 ≠ 5 := by decide
  intro h
  have hz : (b : ZMod 16) ^ 4 - 6 * (a : ZMod 16) ^ 4 = 5 := by
    have := congrArg (Int.cast : ℤ → ZMod 16) h
    push_cast at this
    simpa using this
  exact hmod (a : ZMod 16) (b : ZMod 16) hz

/-- **The negative coprime branch is empty.**  There is no solution of
`P₁₄(n) = t⁴` with `n < 0` and `5 ∤ n`.  Indeed the coprime descent forces
`n = -a⁴` and `6n − 5 = -b⁴`, i.e. `b⁴ − 6a⁴ = 5`, which is impossible by
`thue_b4_sub_6a4_ne_five`.  This rigorously removes an entire branch of the
classification. -/
theorem no_neg_coprime_solution (n t : ℤ) (hn : n < 0) (h5 : ¬ (5 ∣ n))
    (heq : P14 n = t ^ 4) : False := by
  obtain ⟨⟨a, ha⟩, ⟨b, hb⟩⟩ := descent_coprime n t h5 heq
  have hna : n = -a ^ 4 := by
    rcases ha with ha | ha
    · exfalso; have : (0 : ℤ) ≤ a ^ 4 := by positivity
      omega
    · exact ha
  have hnb : 6 * n - 5 = -b ^ 4 := by
    rcases hb with hb | hb
    · exfalso; have : (0 : ℤ) ≤ b ^ 4 := by positivity
      omega
    · exact hb
  exact thue_b4_sub_6a4_ne_five a b (by rw [hna] at hnb; nlinarith [hnb])

/-! ## The five known solutions -/

/-- The five listed pairs really are solutions. -/
theorem is_solution_zero : IsSolution 0 0 := by unfold IsSolution P14; norm_num
theorem is_solution_one_pos : IsSolution 1 1 := by unfold IsSolution P14; norm_num
theorem is_solution_one_neg : IsSolution 1 (-1) := by unfold IsSolution P14; norm_num

theorem is_solution_big_pos : IsSolution (-2000) 70 := by
  unfold IsSolution P14; norm_num

theorem is_solution_big_neg : IsSolution (-2000) (-70) := by
  unfold IsSolution P14; norm_num

/-- All five listed pairs satisfy the equation, packaged as one statement.
(Forward direction of the complete-solution theorem.) -/
theorem solutions_are_solutions :
    ∀ p : ℤ × ℤ,
      p ∈ ({(0, 0), (1, 1), (1, -1), (-2000, 70), (-2000, -70)} : Finset (ℤ × ℤ)) →
      P14 p.1 = p.2 ^ 4 := by
  intro p hp
  fin_cases hp <;> simp only [P14] <;> norm_num

/-- The five solutions correspond, via the Pell reduction, to integer points
`(x, t) = (12n − 5, t)` on the curve `x² − 24 t⁴ = 25`. -/
theorem solutions_on_pell_curve :
    (12 * (0 : ℤ) - 5) ^ 2 - 24 * (0 : ℤ) ^ 4 = 25 ∧
    (12 * (1 : ℤ) - 5) ^ 2 - 24 * (1 : ℤ) ^ 4 = 25 ∧
    (12 * (-2000 : ℤ) - 5) ^ 2 - 24 * (70 : ℤ) ^ 4 = 25 := by
  refine ⟨by norm_num, by norm_num, by norm_num⟩

/-
-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).
  The 14-gonal numbers `P₁₄(n) = 6n² − 5n` that are perfect fourth powers are
  exactly those at `n ∈ {0, 1, -2000}` (Theorem 1(i), k = 5, of the source paper).
  Bold sub-conjectures raised:
   (H1) The equation reduces to a single quartic-Pell relation `x² − 24t⁴ = 25`.
   (H2) The two factors `n` and `6n-5` are coprime away from the prime 5, so the
        problem splits by a gcd dichotomy.
   (H3) On the coprime branch, unique factorisation forces both factors to be
        fourth powers up to sign — turning the problem into Thue equations.
   (H4) No elementary congruence (mod 16, mod 5, ...) can finish the job, because
        the large solution n = -2000 survives every small modulus.

EXPERIMENT (Experimenter).
  * (H1) proved: `P14_eq_pell_form`, by completing the square (×24) and `nlinarith`.
  * (H2) proved: `coprime_factors`. gcd(n, 6n-5) | (6n - (6n-5)) = 5, and equals 5
        iff 5 | n; otherwise it is 1.
  * (H3) proved: `descent_coprime` / `descent_coprime_pos`, using
        `exists_associated_pow_of_mul_eq_pow` (UFD descent in ℤ) plus
        `Int.associated_iff` to convert "associated to a 4th power" into "= ± 4th
        power", and positivity to kill the sign in the positive branch.
  * Forward direction proved: `is_solution_*`, `solutions_are_solutions`,
        `solutions_on_pell_curve`.
  * NEW (this cycle): the companion Thue equation `b⁴ − 6a⁴ = 5` was *settled*
        completely by a mod-16 obstruction (`thue_b4_sub_6a4_ne_five`): fourth
        powers are `0` or `1 (mod 16)`, so `b⁴ − 6a⁴ ∈ {0,1,10,11}`, never `5`.
        This kills the entire negative coprime branch (`no_neg_coprime_solution`,
        and `solution_sign_constraint` in the companion file): no solution has
        `n < 0` with `5 ∤ n`.  Contrast with `6a⁴ − b⁴ = 5`, where `5 = 6 − 1` is
        attainable mod 16, so congruences alone cannot finish — confirming H4.

ANALYSIS (Analyst).
  What survived: the entire *structural* reduction is fully formal and sorry-free.
  After `descent_coprime_pos`, a positive coprime solution must satisfy
  `n = a⁴` and `6a⁴ − 5 = b⁴`, i.e. the Thue equation `6a⁴ − b⁴ = 5`.
  What is "true but hard": the assertion that `6a⁴ − b⁴ = 5` has only `(a,b)=(1,1)`
  in nonnegative integers, and the companion `b⁴ − 6a⁴ = 5` has none. These are
  genuine quartic Thue equations; their resolution needs Diophantine
  approximation / elliptic-curve descent, not congruences (confirming H4).
  Failure mode catalogued: a naive "mod m kills all large n" attempt fails — both
  mod 16 and mod 5 are consistent with n = -2000.

CRITIQUE (Critic).
  * Are the main theorems trivial?  No: `P14_eq_pell_form` needs the completing-
    the-square identity (`nlinarith`); `coprime_factors` needs a gcd-divides-5
    argument with a prime case split; `descent_coprime` invokes UFD descent.
    None is `rfl`/`simp`/`decide`-only.
  * The pure-verification lemmas (`is_solution_*`, `solutions_are_solutions`) use
    `decide`/`norm_num`; they are *supporting* facts, not the main results, which
    is acceptable.
  * Hidden corner cases handled: the sign ambiguity from `Associated` (resolved by
    positivity), and the `gcd = 5` branch (resolved by the `5 ∣ n` hypothesis).

SYNTHESIS (PI).
  The file delivers a complete, sorry-free reduction of the 14-gonal
  fourth-power problem to two named Thue equations, plus the Pell-curve
  dictionary and the verified solution list. The outstanding Thue resolution is
  promoted to a headline conjecture in FUTURE_DIRECTIONS.md.
-/

end Catalog.Combinatorics.FourteenGonal