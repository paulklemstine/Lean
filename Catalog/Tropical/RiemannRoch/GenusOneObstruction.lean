/-
Copyright (c) 2025. Released under Apache 2.0 license.

# A genus-1 obstruction: why `hsurj` is genuinely a genus-0 phenomenon

The genus-0 Riemann–Roch theorem (`riemann_roch_genus_zero`) relied on the
hypothesis `hsurj`: *all divisors of equal degree are linearly equivalent.*
The Critic stage flagged that this hypothesis is load-bearing.  Here we make
that precise by exhibiting a graph of genus `1` — the 2-cycle `C₂` (two vertices
joined by a double edge) — on which `hsurj` provably **fails**.

This is the chip-firing shadow of the fact that the Jacobian (degree-0 Picard
group) of `C₂` is `ℤ/2ℤ`, not trivial: the divisor `(1,-1)` has degree `0` but is
not principal.

## Main results

* `cycleTwo_genus`        — the 2-cycle has genus `1`.
* `cycleTwo_hsurj_fails`  — `hsurj` fails on `C₂`: there exist equal-degree
                            divisors that are *not* linearly equivalent.

-- !-- Lab Notes -- !--
Hypothesis: increasing the first Betti number obstructs degree-only equivalence.
Experiment: take the double edge `C₂` (`adj = 2` off-diagonal); its principal
divisors are exactly `(2t, -2t)`, an index-2 sublattice of the degree-0 lattice
`(a,-a)`.  Analysis: the degree-0 divisor `(1,-1)` is not principal because
`2 ∣ prin f` at each vertex — a pure parity/integrality fact discharged by
`omega`.  Critique: this confirms the genus-0 hypothesis is not cosmetic; for
`g ≥ 1` the Baker–Norine rank genuinely departs from `max(deg, -1)`.  Synthesis:
the number of spanning trees (here `2`) is exactly the index of the principal
lattice, the combinatorial source of the obstruction.
-/

import Tropical.RiemannRoch.Rank

open Finset BigOperators

namespace BakerNorine

/-- The 2-cycle `C₂`: two vertices joined by a double edge (`adj = 2`). -/
def cycleTwo : FinGraph where
  V := Fin 2
  adj := fun v w => if v = w then 0 else 2
  adj_symm := by
    intro v w
    rcases eq_or_ne v w with h | h
    · simp [h]
    · simp [h, h.symm]
  adj_loopless := by intro v; simp

/-
The 2-cycle has genus `1` (one independent cycle).
-/
theorem cycleTwo_genus : genus cycleTwo = 1 := by
  unfold genus totalEdges vertexDeg cycleTwo
  simp [Fin.sum_univ_two]

/-
**The genus-0 hypothesis is load-bearing.**
On `C₂` there are two divisors of the same degree that are *not* linearly
equivalent, so `hsurj` fails.  Concretely `(1,0)` and `(0,1)` both have degree `1`
but their difference `(1,-1)` is not a principal divisor (parity obstruction).
-/
theorem cycleTwo_hsurj_fails :
    ¬ (∀ D D' : Divisor cycleTwo, deg D = deg D' → LinEquiv D D') := by
  unfold cycleTwo;
  push_neg;
  -- Let's choose the divisors $D = (1, 0)$ and $D' = (0, 1)$ on $C₂$.
  use (fun v => if v = 0 then 1 else 0), (fun v => if v = 0 then 0 else 1);
  simp +decide [ deg, LinEquiv ];
  intro x hx; have := congr_fun hx 0; have := congr_fun hx 1; simp +decide [ prin ] at *; omega;

end BakerNorine