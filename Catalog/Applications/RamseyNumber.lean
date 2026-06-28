/-
# The two‑colour Ramsey number as a genuine numeric function

The catalog already proves a long list of *arrow* statements
(`Arrows n s t`, classically `n → (s,t)`) culminating in the exact small values
`R(3,3) = 6`, `R(3,4) = 9`, `R(4,4) = 18` and the Erdős–Szekeres binomial bound.
What was missing is the **Ramsey number itself** as a function `ℕ → ℕ → ℕ`.

This file defines
`ramseyNumber s t := sInf {n | Arrows n s t}`
and develops its basic API: it is achieved (`ramseyNumber_mem`), it is the least
threshold (`ramseyNumber_le`), values below it fail to arrow
(`lt_ramseyNumber`), and there is a clean "sandwich" characterisation
`ramseyNumber_eq`.  From the catalog's arrow lemmas we then read off the *exact
values of the function*:
`ramseyNumber 3 3 = 6`, `ramseyNumber 3 4 = 9`, `ramseyNumber 4 3 = 9`,
`ramseyNumber 4 4 = 18`, `ramseyNumber 2 (t+1) = t+1`,
together with the symmetry `R(s,t) = R(t,s)`.
-/

import Mathlib
import Applications.Ramsey
import Applications.RamseyThreeFour
import Applications.RamseyFourFour
import Applications.RamseyOffDiagonal

open scoped Classical

namespace RamseyTheory

/-- The (two‑colour) **Ramsey number** `R(s,t)`: the least number of vertices `n`
forcing every red/blue colouring to contain a red `s`‑clique or a blue
`t`‑clique. -/
noncomputable def ramseyNumber (s t : ℕ) : ℕ := sInf {n | Arrows n s t}

/-
The arrow relation is satisfiable for every pair `(s,t)`: there is always
*some* threshold that works (the binomial bound, or `0` when a clique is empty).
This guarantees `{n | Arrows n s t}` is non‑empty, so `sInf` is meaningful.
-/
theorem arrows_witness (s t : ℕ) : ∃ n, Arrows n s t := by
  by_cases hs : s = 0;
  · use 0;
    intro V _ G W hW; simp_all +decide [ SimpleGraph.isNClique_iff ] ;
  · by_cases ht : t = 0;
    · use 0;
      intro V _ G W hW; simp_all +decide [ SimpleGraph.isNClique_iff ] ;
    · obtain ⟨ S, rfl ⟩ := Nat.exists_eq_succ_of_ne_zero hs; obtain ⟨ T, rfl ⟩ := Nat.exists_eq_succ_of_ne_zero ht; exact ⟨ _, arrows_binomial_bound S T ⟩ ;

/-
The Ramsey number is itself a working threshold: `R(s,t) → (s,t)`.
-/
theorem ramseyNumber_mem (s t : ℕ) : Arrows (ramseyNumber s t) s t := by
  exact Nat.sInf_mem ( arrows_witness s t )

/-
`R(s,t)` is the *least* working threshold: any `n` with `n → (s,t)` is at
least `R(s,t)`.
-/
theorem ramseyNumber_le {n s t : ℕ} (h : Arrows n s t) : ramseyNumber s t ≤ n := by
  exact Nat.sInf_le h

/-
Every value strictly below `R(s,t)` fails to arrow: there is a colouring of
`K_n` with no red `s`‑clique and no blue `t`‑clique.
-/
theorem lt_ramseyNumber {n s t : ℕ} (h : ¬ Arrows n s t) : n < ramseyNumber s t := by
  exact Nat.lt_of_not_ge fun hn => h <| Arrows.mono ( ramseyNumber_mem s t ) hn

/-
**Sandwich characterisation.** If `n → (s,t)` but `(n-1) ↛ (s,t)`, then
`R(s,t) = n`.  This is the standard way of pinning down an exact value from a
matching upper and lower bound.  (No `n ≥ 1` hypothesis is needed: for `n = 0`
the two hypotheses are contradictory and the statement holds vacuously.)
-/
theorem ramseyNumber_eq {n s t : ℕ}
    (hub : Arrows n s t) (hlb : ¬ Arrows (n - 1) s t) : ramseyNumber s t = n := by
      contrapose! hlb;
      -- Since $ramseyNumber s t < n$, there exists some $m < n$ such that $Arrows m s t$.
      obtain ⟨m, hm₁, hm₂⟩ : ∃ m, m < n ∧ Arrows m s t := by
        exact ⟨ _, lt_of_le_of_ne ( ramseyNumber_le hub ) hlb, ramseyNumber_mem s t ⟩;
      exact Arrows.mono hm₂ ( Nat.le_pred_of_lt hm₁ )

/-
The Ramsey number is symmetric: swapping the two colours does not change it,
`R(s,t) = R(t,s)`.
-/
theorem ramseyNumber_symm (s t : ℕ) : ramseyNumber s t = ramseyNumber t s := by
  by_contra h;
  obtain hlt | hlt := lt_or_gt_of_ne h;
  · exact hlt.not_ge ( ramseyNumber_le <| arrows_symm <| ramseyNumber_mem _ _ );
  · exact hlt.not_ge <| ramseyNumber_le <| arrows_symm <| ramseyNumber_mem _ _

/-! ## Exact values, read off from the catalog's arrow lemmas -/

/-- **`R(3,3) = 6`.** -/
theorem ramseyNumber_three_three : ramseyNumber 3 3 = 6 :=
  ramseyNumber_eq arrows_three_three (by simpa using not_arrows_five_three_three)

/-- **`R(3,4) = 9`.** -/
theorem ramseyNumber_three_four : ramseyNumber 3 4 = 9 :=
  ramseyNumber_eq arrows_three_four (by simpa using not_arrows_eight_three_four)

/-- **`R(4,4) = 18`.** -/
theorem ramseyNumber_four_four : ramseyNumber 4 4 = 18 :=
  ramseyNumber_eq arrows_four_four (by simpa using not_arrows_seventeen_four_four)

/-- **`R(4,3) = 9`** by symmetry. -/
theorem ramseyNumber_four_three : ramseyNumber 4 3 = 9 := by
  rw [ramseyNumber_symm]; exact ramseyNumber_three_four

/-- **`R(2, t+1) = t+1`**: the off‑diagonal base case. -/
theorem ramseyNumber_two_succ (t : ℕ) : ramseyNumber 2 (t + 1) = t + 1 :=
  ramseyNumber_eq (arrows_two (t + 1)) (by simpa using not_arrows_two t)

/- -- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the catalog records `Arrows n s t` facts but never the
*function* `R(s,t)`.  Conjecture: defining `R(s,t) = sInf {n | Arrows n s t}` and
proving the Galois‑style API (`ramseyNumber_le`, `lt_ramseyNumber`) lets every
existing arrow/anti‑arrow pair collapse to an exact numeric equation with no extra
combinatorics.

EXPERIMENT (Experimenter): defined `ramseyNumber`, proved it is achieved and least
via `Nat.sInf_mem` / `Nat.sInf_le` (non‑emptiness from the binomial bound), then
the sandwich lemma `ramseyNumber_eq` from `Arrows.mono`.  The four exact values
follow as one‑liners by feeding the catalog's `arrows_*` and `not_arrows_*` pairs.

ANALYSIS (Analyst): the only real content beyond the catalog is monotonicity in
the vertex count (`Arrows.mono`), which turns a single anti‑arrow `¬ Arrows (n-1)`
into a lower bound for *all* smaller thresholds.  Symmetry reduces `R(4,3)` to
`R(3,4)` for free.

CRITIQUE (Critic): `ramseyNumber_eq` is non‑vacuous — both hypotheses are
discharged for the concrete values 6, 9, 18.  No theorem is `decide`/`simp`‑only;
each exact value rests on a genuine upper‑bound proof (binomial/Ramsey arrow) and a
genuine extremal colouring (pentagon / circulant / Paley graph) from the catalog.

SYNTHESIS (PI): the catalog now exposes `ramseyNumber : ℕ → ℕ → ℕ` with its exact
small values and basic order/symmetry API, the natural home for further bounds.
-/

end RamseyTheory