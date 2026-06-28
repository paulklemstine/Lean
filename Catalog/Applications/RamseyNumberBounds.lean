/-
# Quantitative bounds on the Ramsey number function

Building on `Applications.RamseyNumber`, which introduced
`ramseyNumber s t = sInf {n | Arrows n s t}`, this file proves the standard
*quantitative* properties of the function, turning the catalog's `Arrows` lemmas
into honest numeric inequalities on `R`:

* positivity `0 < R(s,t)` for `s,t ≥ 1`;
* monotonicity in each argument;
* the **Erdős–Szekeres binomial bound** in the textbook form
  `R(s,t) ≤ C(s+t-2, s-1)`;
* the **Erdős–Szekeres recursion** `R(s,t) ≤ R(s-1,t) + R(s,t-1)`
  (here in the shifted, non‑degenerate form on `s+2, t+2`);
* the diagonal **sandwich** `2^m < R(2m,2m) ≤ 4^(2m-1)`, bracketing the diagonal
  Ramsey number between the probabilistic lower bound and the recursive upper
  bound.
-/

import Mathlib
import Applications.RamseyNumber
import Applications.RamseyDiagonalBound
import Applications.RamseyProbabilisticLowerBound

open scoped Classical

namespace RamseyTheory

/-
With no vertices there is no nonempty clique, so `0 ↛ (s,t)` whenever
`s ≥ 1` and `t ≥ 1`.
-/
theorem not_arrows_zero {s t : ℕ} (hs : 1 ≤ s) (ht : 1 ≤ t) : ¬ Arrows 0 s t := by
  intro h
  specialize h (⊥ : SimpleGraph (Fin 0)) ∅
  simp at h;
  omega

/-- **Positivity.** `R(s,t) ≥ 1` for `s,t ≥ 1`: a single vertex is never enough,
so the threshold is positive. -/
theorem ramseyNumber_pos {s t : ℕ} (hs : 1 ≤ s) (ht : 1 ≤ t) : 0 < ramseyNumber s t :=
  lt_ramseyNumber (not_arrows_zero hs ht)

/-
**Monotonicity in the red clique size.** Larger required cliques need at
least as many vertices: `s ≤ s' → R(s,t) ≤ R(s',t)`.
-/
theorem ramseyNumber_mono_left {s s' t : ℕ} (h : s ≤ s') :
    ramseyNumber s t ≤ ramseyNumber s' t := by
      exact ramseyNumber_le ( arrows_mono_red ( ramseyNumber_mem s' t ) h )

/-
**Monotonicity in the blue clique size.** `t ≤ t' → R(s,t) ≤ R(s,t')`.
-/
theorem ramseyNumber_mono_right {s t t' : ℕ} (h : t ≤ t') :
    ramseyNumber s t ≤ ramseyNumber s t' := by
      by_contra h_contra;
      obtain ⟨n, hn⟩ : ∃ n, n = ramseyNumber s t' ∧ Arrows n s t' := by
        exact ⟨ _, rfl, ramseyNumber_mem _ _ ⟩;
      exact h_contra <| hn.1.symm ▸ ramseyNumber_le ( arrows_mono_blue hn.2 h )

/-
**Erdős–Szekeres binomial bound (textbook form).**
`R(s,t) ≤ C(s+t-2, s-1)` for `s,t ≥ 1`.
-/
theorem ramseyNumber_le_choose {s t : ℕ} (hs : 1 ≤ s) (ht : 1 ≤ t) :
    ramseyNumber s t ≤ (s + t - 2).choose (s - 1) := by
  obtain ⟨S, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : s ≠ 0)
  obtain ⟨T, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : t ≠ 0)
  have harg : S + 1 + (T + 1) - 2 = S + T := by omega
  have harg2 : S + 1 - 1 = S := by omega
  rw [harg, harg2]
  exact ramseyNumber_le (arrows_binomial_bound S T)

/-
**Erdős–Szekeres recursion.** `R(s,t) ≤ R(s-1,t) + R(s,t-1)`, stated in the
shifted non‑degenerate form: `R(s+2,t+2) ≤ R(s+1,t+2) + R(s+2,t+1)`.
-/
theorem ramseyNumber_recursion (s t : ℕ) :
    ramseyNumber (s + 2) (t + 2) ≤ ramseyNumber (s + 1) (t + 2) + ramseyNumber (s + 2) (t + 1) := by
  convert ramseyNumber_le _;
  apply arrows_recursion_general;
  · exact ramseyNumber_pos ( Nat.succ_pos _ ) ( Nat.succ_pos _ );
  · exact ramseyNumber_pos ( by linarith ) ( by linarith );
  · exact RamseyTheory.ramseyNumber_mem _ _;
  · exact ramseyNumber_mem _ _

/-- **Diagonal upper bound.** `R(k+1,k+1) ≤ 4^k`, from `arrows_diagonal_pow`. -/
theorem ramseyNumber_diagonal_le (k : ℕ) : ramseyNumber (k + 1) (k + 1) ≤ 4 ^ k :=
  ramseyNumber_le (arrows_diagonal_pow k)

/-- **Diagonal lower bound.** `2^m < R(2m,2m)` for `m ≥ 2`, the first‑moment
probabilistic bound expressed on the Ramsey number itself. -/
theorem lt_ramseyNumber_diagonal {m : ℕ} (hm : 2 ≤ m) :
    2 ^ m < ramseyNumber (2 * m) (2 * m) :=
  lt_ramseyNumber (ramsey_diagonal_lower m hm)

/-
**Diagonal sandwich.** For `m ≥ 2`, the diagonal Ramsey number is bracketed
`2^m < R(2m,2m) ≤ 4^(2m-1)`, the classical Erdős–Szekeres window.
-/
theorem ramseyNumber_diagonal_sandwich {m : ℕ} (hm : 2 ≤ m) :
    2 ^ m < ramseyNumber (2 * m) (2 * m) ∧ ramseyNumber (2 * m) (2 * m) ≤ 4 ^ (2 * m - 1) := by
  have := lt_ramseyNumber_diagonal hm;
  exact ⟨ this, by convert ramseyNumber_diagonal_le ( 2 * m - 1 ) using 1; rw [ Nat.sub_add_cancel ( by linarith ) ] ⟩

/- -- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): once `ramseyNumber` exists, every `Arrows`/`¬Arrows`
fact in the catalog should upgrade to a *numeric* inequality on `R` with no new
combinatorics — including the two-sided Erdős–Szekeres window on the diagonal.

EXPERIMENT (Experimenter): proved positivity from an empty-graph witness, both
monotonicities from `arrows_mono_red`/`arrows_mono_blue` fed through
`ramseyNumber_le ∘ ramseyNumber_mem`, the binomial bound `R(s,t) ≤ C(s+t-2,s-1)`
from `arrows_binomial_bound` after the `s = S+1, t = T+1` normalisation, and the
recursion from `arrows_recursion_general` applied to the two achieved sub-thresholds
(`ramseyNumber_mem`), each positive by `ramseyNumber_pos`.

ANALYSIS (Analyst): the recursion is the load-bearing structural result — it is the
*inductive engine* behind the binomial bound, but stated directly on `R` it also
shows `R` is subadditive along the Pascal triangle.  The diagonal sandwich pairs
the probabilistic `2^m` lower bound (a counting/union-bound witness) with the
recursive `4^k` upper bound (Pascal's rule), demonstrating that the two halves of
the catalog interlock around the single function `R`.

CRITIQUE (Critic): none of these are `decide`-only; `ramseyNumber_recursion` needs
genuine positivity side conditions (`ramseyNumber_pos`), and `not_arrows_zero`
exhibits an explicit (empty) extremal configuration.  The sandwich is non-vacuous:
for `m ≥ 2` both `2^m` and `4^(2m-1)` are concrete and `2^m < 4^(2m-1)`.

SYNTHESIS (PI): the catalog's Ramsey block is now organised around one function
`R : ℕ → ℕ → ℕ` carrying its exact small values, order structure, the Erdős–Szekeres
recursion and binomial bound, and a proven diagonal sandwich.
-/

end RamseyTheory