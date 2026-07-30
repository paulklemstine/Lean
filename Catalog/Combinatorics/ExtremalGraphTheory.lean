/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-! # Turán's theorem

This file records the exact finite extremal number and the usual smooth density
bound.  The often-written expression `(1 - 1/(r-1)) n²/2` is exactly attained
when `r - 1` divides `n`; for general `n`, the exact answer contains the usual
balanced-part residue correction.
-/

namespace Catalog.Combinatorics.ExtremalGraphTheory

open SimpleGraph

/-- **Turán's theorem, exact extremal-number form.**  The maximum number of
edges in an `n`-vertex graph containing no copy of `K_r` is the number of edges
of the balanced complete `(r-1)`-partite graph, expanded here as an integer
formula. -/
theorem turan_extremalNumber_exact (n r : ℕ) (hr : 2 ≤ r) :
    extremalNumber n (⊤ : SimpleGraph (Fin r)) =
      (n ^ 2 - (n % (r - 1)) ^ 2) * ((r - 1) - 1) / (2 * (r - 1)) +
        (n % (r - 1)).choose 2 := by
  letI : Nontrivial (Fin r) := Fin.nontrivial_iff_two_le.mpr hr
  rw [extremalNumber_top, Fintype.card_fin, card_edgeFinset_turanGraph]

/-- **Turán's density bound.**  Every `K_r`-free graph has at most
`(1 - 1/(r-1)) n²/2` edges.  This is an upper bound over the reals; the exact
integer answer is `turan_extremalNumber_exact`. -/
theorem turan_density_bound {V : Type*} [Fintype V] {G : SimpleGraph V}
    [DecidableRel G.Adj] {r : ℕ} (hr : 2 ≤ r) (hG : G.CliqueFree r) :
    (G.edgeFinset.card : ℝ) ≤
      (1 - 1 / ((r : ℝ) - 1)) * (Fintype.card V : ℝ) ^ 2 / 2 := by
  let s := r - 1
  have hs : 0 < s := by omega
  have hcf : G.CliqueFree (s + 1) := by
    simpa [s, Nat.sub_add_cancel (show 1 ≤ r by omega)] using hG
  have hedge := hcf.card_edgeFinset_le (r := s)
  have hsmooth := SimpleGraph.mul_card_edgeFinset_turanGraph_le (n := Fintype.card V) (r := s)
  rw [card_edgeFinset_turanGraph] at hsmooth
  have hnat : 2 * s * G.edgeFinset.card ≤ (s - 1) * Fintype.card V ^ 2 :=
    le_trans (Nat.mul_le_mul_left (2 * s) hedge) hsmooth
  have hsone : 1 ≤ s := hs
  have hreal : ((2 * s * G.edgeFinset.card : ℕ) : ℝ) ≤
      (((s - 1) * Fintype.card V ^ 2 : ℕ) : ℝ) := by
    exact_mod_cast hnat
  norm_num [Nat.cast_sub hsone] at hreal
  have hsreal : (0 : ℝ) < s := by exact_mod_cast hs
  have hrs : r = s + 1 := by dsimp [s]; omega
  rw [hrs]
  push_cast
  rw [show ((s : ℝ) + 1 - 1) = s by ring]
  calc
    (G.edgeFinset.card : ℝ) ≤
        ((s : ℝ) - 1) * (Fintype.card V : ℝ) ^ 2 / (2 * s) := by
      rw [le_div_iff₀ (by positivity : (0 : ℝ) < 2 * s)]
      simpa only [mul_assoc, mul_comm, mul_left_comm] using hreal
    _ = (1 - 1 / (s : ℝ)) * (Fintype.card V : ℝ) ^ 2 / 2 := by
      field_simp

end Catalog.Combinatorics.ExtremalGraphTheory