/-
Copyright (c) 2025. Released under Apache 2.0 license.

# The Baker–Norine / tropical Riemann–Roch theorem in genus 0

This file proves the Baker–Norine Riemann–Roch theorem
`rank D - rank (K - D) = deg D - g + 1`
in the genus-0 ("tree") situation, where linear equivalence collapses to degree.

It then verifies the hypotheses *concretely* for the path graph `P₂` (two
vertices joined by one edge), giving a fully unconditional instance of the
tropical Riemann–Roch theorem.

## Main results

* `riemann_roch_genus_zero` — abstract genus-0 Riemann–Roch: under the hypotheses
  `hsurj` (all equal-degree divisors are linearly equivalent) and `genus G = 0`,
  the Riemann–Roch identity holds for every divisor.
* `pathTwo_hsurj`, `pathTwo_genus` — the path graph `P₂` satisfies both hypotheses.
* `riemann_roch_pathTwo` — the **unconditional** Riemann–Roch theorem on `P₂`.

-- !-- Lab Notes -- !--
Hypothesis: Riemann–Roch `r(D) - r(K-D) = deg D - g + 1` holds for trees with `g=0`.
Experiment: combine the rank formula `rank X = max(deg X, -1)` (from
`rank_of_complete_equiv`) with `deg K = 2g - 2`.  Analysis: a case split on the
two `if` conditions reduces the identity to linear integer arithmetic (`omega`).
A *crucial* discovery (Critique stage): the identity is FALSE under `hsurj` alone
for `g ≠ 0` — when both ranks are positive one gets `2·deg D - (2g-2)`, which
equals `deg D - g + 1` only when `g = 0`.  Hence `genus G = 0` is a genuine,
load-bearing hypothesis, not decoration; we therefore verify it explicitly for
`P₂`.  Synthesis: `riemann_roch_pathTwo` is hypothesis-free.
-/

import Tropical.RiemannRoch.Rank

open Finset BigOperators

namespace BakerNorine

variable {G : FinGraph}

/-
**Abstract genus-0 Riemann–Roch.**
If all divisors of equal degree are linearly equivalent and the genus is `0`,
then `rank D - rank (K - D) = deg D - g + 1` for every divisor `D`.
-/
theorem riemann_roch_genus_zero [Nonempty G.V]
    (hsurj : ∀ D D' : Divisor G, deg D = deg D' → LinEquiv D D')
    (hg : genus G = 0) (D : Divisor G) :
    rank D - rank (subDiv (canonical G) D) = deg D - genus G + 1 := by
  -- Apply the fact that the degree of the canonical divisor is $2g - 2$.
  have hK : deg (canonical G) = -2 := by
    rw [ deg_canonical, hg ] ; ring;
  rw [ rank_of_complete_equiv, rank_of_complete_equiv ];
  · unfold subDiv; simp +decide [ deg ] at *; split_ifs at * <;> omega;
  · assumption;
  · assumption

/-! ### The path graph `P₂` -/

/-- The path graph on two vertices: one edge between `0` and `1`. -/
def pathTwo : FinGraph where
  V := Fin 2
  adj := fun v w => if v = w then 0 else 1
  adj_symm := by
    intro v w
    rcases eq_or_ne v w with h | h
    · simp [h]
    · simp [h, h.symm]
  adj_loopless := by intro v; simp

/-
On `P₂`, any two divisors of equal degree are linearly equivalent.
-/
theorem pathTwo_hsurj (D D' : Divisor pathTwo)
    (h : deg D = deg D') : LinEquiv D D' := by
  unfold deg at h;
  unfold LinEquiv;
  unfold prin;
  unfold pathTwo at *; simp_all +decide [ Fin.sum_univ_two ] ;
  exact ⟨ fun w => if w = 0 then D' 0 - D 0 else 0, by ext w; fin_cases w <;> simp +decide ; linarith! ⟩

/-
The genus of `P₂` is `0`.
-/
theorem pathTwo_genus : genus pathTwo = 0 := by
  unfold genus totalEdges vertexDeg pathTwo; simp +decide [ Fin.sum_univ_two ] ;

instance : Nonempty pathTwo.V := inferInstanceAs (Nonempty (Fin 2))

/-- **Tropical Riemann–Roch on the path graph `P₂` (unconditional).** -/
theorem riemann_roch_pathTwo (D : Divisor pathTwo) :
    rank D - rank (subDiv (canonical pathTwo) D) = deg D - genus pathTwo + 1 :=
  riemann_roch_genus_zero pathTwo_hsurj pathTwo_genus D

end BakerNorine