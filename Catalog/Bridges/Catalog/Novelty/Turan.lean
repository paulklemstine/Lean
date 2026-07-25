/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Turán's theorem in density form, and Mantel's theorem

This file packages the extremal upper bound of **Turán's theorem** in the
classical *density* shape requested by the research mission,

  `ex(n, K_r) ≤ (1 - 1/(r-1)) · n² / 2`,

and derives **Mantel's theorem** (`r = 3`) as a corollary:

  a triangle-free graph on `n` vertices has at most `⌊n²/4⌋` edges.

The arithmetic heart is `turan_arith`, which shows that the *integer* Turán
bound that Mathlib proves (`SimpleGraph.CliqueFree.card_edgeFinset_le`, the
edge count of the Turán graph `T(n, r-1)`, an expression involving `n % (r-1)`
and a binomial correction) never exceeds the clean real number
`(s-1)·n² / (2s)` with `s = r-1`.  The only inequality used there is
`t·(t-1) ≤ (s-1)·t² / s` for `t = n % s < s`, i.e. the residue correction is
always dominated by the smooth quadratic.
-/
import Mathlib

namespace Catalog.Combinatorics.ExtremalGraphTheory

open SimpleGraph Finset

/-
**Arithmetic core of Turán's theorem.**
The integer Turán bound `(n² - t²)·(s-1)/(2s) + C(t,2)` with `t = n % s`
(the exact edge count of the Turán graph `T(n,s)`, as in Mathlib's
`SimpleGraph.CliqueFree.card_edgeFinset_le`) is dominated by the smooth
density bound `(s-1)·n² / (2s)`.

The key step is the residue inequality `C(t,2) = t(t-1)/2 ≤ (s-1)·t²/(2s)`
which holds because `t < s`.
-/
theorem turan_arith (n s : ℕ) (hs : 1 ≤ s) :
    (((n ^ 2 - (n % s) ^ 2) * (s - 1) / (2 * s) : ℕ) : ℝ) + ((n % s).choose 2 : ℝ)
      ≤ ((s : ℝ) - 1) * (n : ℝ) ^ 2 / (2 * s) := by
  refine le_trans ( add_le_add ( Nat.cast_div_le .. ) le_rfl ) ?_;
  rcases s with ( _ | _ | s ) <;> simp_all +decide [ Nat.choose_two_right ];
  · grind;
  · rw [ Nat.cast_div ] <;> norm_num;
    · rcases k : n % ( s + 1 + 1 ) with ( _ | k ) <;> simp_all +decide [ pow_succ' ];
      · ring_nf; norm_num;
      · rw [ Nat.cast_sub ];
        · field_simp;
          have := Nat.mod_lt n ( by linarith : 0 < s + 1 + 1 ) ; simp_all +decide;
          nlinarith [ ( by norm_cast : ( ↑‹ℕ› : ℝ ) ≤ s ), sq ( s - ↑‹ℕ› : ℝ ) ];
        · nlinarith [ Nat.mod_le n ( s + 1 + 1 ) ];
    · exact even_iff_two_dvd.mp ( Nat.even_mul_pred_self _ )

/-- **Turán's theorem (density upper bound).**
A `K_r`-free graph on `n = card V` vertices (`r ≥ 2`) has at most
`(1 - 1/(r-1)) · n² / 2` edges.  This is the substantive (upper-bound) direction
of `ex(n, K_r) = (1 - 1/(r-1)) n²/2`. -/
theorem turan_density_bound {V : Type*} [Fintype V] {G : SimpleGraph V} [DecidableRel G.Adj]
    {r : ℕ} (hr : 2 ≤ r) (h : G.CliqueFree r) :
    (G.edgeFinset.card : ℝ) ≤ (1 - 1 / ((r : ℝ) - 1)) * (Fintype.card V) ^ 2 / 2 := by
  obtain ⟨s, rfl⟩ : ∃ s, r = s + 1 := ⟨r - 1, by omega⟩
  have hs : 1 ≤ s := by omega
  have hb := h.card_edgeFinset_le (r := s)
  set n := Fintype.card V with hn
  have hcast : (G.edgeFinset.card : ℝ) ≤
      (((n ^ 2 - (n % s) ^ 2) * (s - 1) / (2 * s) + (n % s).choose 2 : ℕ) : ℝ) := by
    exact_mod_cast hb
  refine le_trans hcast ?_
  have hmain := turan_arith n s hs
  have hs0 : (0 : ℝ) < s := by exact_mod_cast hs
  push_cast
  rw [show ((s : ℝ) + 1 - 1) = s by ring]
  rw [show (1 - 1 / (s : ℝ)) * (n : ℝ) ^ 2 / 2 = ((s : ℝ) - 1) * (n : ℝ) ^ 2 / (2 * s) by
    field_simp]
  exact hmain

/-- **Mantel's theorem.**
A triangle-free (i.e. `K₃`-free) graph on `n = card V` vertices has at most
`⌊n²/4⌋` edges.  This is the `r = 3` case of `turan_density_bound`, pushed back
into the natural numbers. -/
theorem mantel {V : Type*} [Fintype V] {G : SimpleGraph V} [DecidableRel G.Adj]
    (h : G.CliqueFree 3) :
    G.edgeFinset.card ≤ (Fintype.card V) ^ 2 / 4 := by
  have htb := turan_density_bound (by norm_num) h
  set n := Fintype.card V
  have h4 : (G.edgeFinset.card : ℝ) ≤ (n : ℝ) ^ 2 / 4 :=
    le_trans htb (le_of_eq (by ring))
  have hmul : G.edgeFinset.card * 4 ≤ n ^ 2 := by
    have : (G.edgeFinset.card : ℝ) * 4 ≤ (n : ℝ) ^ 2 := by linarith
    exact_mod_cast this
  omega

/-
-- !-- Lab Notes -- !--

HYPOTHESIS.
  Mathlib proves Turán only in the "integer Turán-graph" shape
  `#edges ≤ (n² - (n%r)²)(r-1)/(2r) + C(n%r, 2)`.  We hypothesised that this
  integer bound is *uniformly* dominated by the textbook density bound
  `(1 - 1/(r-1)) n²/2`, with no extra slack needed.

EXPERIMENT.
  Setting `s = r - 1` and `t = n % s`, the gap between the smooth bound and the
  main quadratic term equals `(s-1) t² / (2s)`, while the binomial correction is
  `C(t,2) = t(t-1)/2`.  The inequality reduces to `s(t-1) ≤ (s-1)t`, i.e.
  `t ≤ s`, which is automatic since `t = n % s < s`.  Nat-division only helps
  (`Nat.cast_div_le`), so the cast of the integer bound stays below the real one.

ANALYSIS.
  `turan_density_bound` is the genuine analytic content (the upper-bound
  direction of `ex(n, K_r) = (1-1/(r-1))n²/2`).  `mantel` follows by specialising
  `r = 3`, where the density bound is exactly `n²/4`, and transporting back to ℕ
  via `card * 4 ≤ n²` ⇒ `card ≤ n²/4` (`omega`).

CRITIQUE.
  We prove the upper bound (`≤`), which is the hard direction; the matching
  lower bound (tightness of the Turán graph / balanced complete multipartite
  graph) is a construction and is not formalised here.  No hypothesis is
  vacuous: `turan_density_bound` is applied to a real `CliqueFree 3` graph in
  `mantel`, and the residue inequality genuinely uses `t < s`.

SYNTHESIS.
  The smooth density bound is a faithful and clean repackaging of Mathlib's
  integer bound; the residue correction is always dominated.  This is the
  reusable extremal inequality on which Mantel and the `r`-partite picture rest.
-/

end Catalog.Combinatorics.ExtremalGraphTheory