/-
# Half-canonical Brill–Noether numerics for regular graphs

For a connected `k`-regular graph on `n` vertices, the genus is
`g = (k-2)n/2 + 1`.  Consequently the Brill–Noether number at
`(r,d) = (k-1,g-1)` simplifies to

`ρ = g - k(g-d+k-1) = d + 1 - k²`.

This file isolates that numerical reduction and gives an explicit sufficient
threshold.  It also records the exact Riemann–Roch reduction at degree `g-1`:
a divisor at the half-canonical degree has the same rank as its residual
canonical divisor.  The latter is the structural bridge from graph arithmetic
to chip-firing divisor theory.

-- !-- Lab Notes -- !--
Hypothesis: six falsifiable possibilities organize the investigation, ranked by
potential impact: (1) every sufficiently large `k`-regular graph carries a
rank-`k-1` divisor of degree `g-1`; (2) the threshold can be chosen quadratic
in `k`; (3) a random effective divisor of degree `g-1` has rank at least `k-1`
with probability tending to one uniformly over regular graphs; (4) expansion
alone yields a linear threshold; (5) residual duality pairs all extremal
witnesses at degree `g-1`; and (6) numerical non-negativity of `ρ` begins at an
exact parity-adjusted threshold.  The first four are deliberately stronger
structural or probabilistic claims; the last two isolate testable mechanisms.
Experiment: the arithmetic and residual-duality consequences are separated
from the unresolved construction problem.

Hypothesis: regularity should collapse the Brill–Noether number at the
half-canonical degree to one linear expression.  Experiment: substitute
`g=d+1` and `r=k-1` before applying any asymptotic estimate.  Analysis: the
exact expression is `d+1-k²`; thus the numerical obstruction disappears once
`d≥k²-1`, and the explicit bound `n≥2k²` is sufficient for every `k≥5`.
Critique: non-negativity of `ρ` is only the numerical side of the existence
problem; it does not by itself manufacture a divisor.  The existence assertion
is therefore not stated as a consequence of arithmetic.  Synthesis: the final
theorems separate the unconditional regular-graph genus and threshold results
from a precisely stated Riemann–Roch residual-rank transfer.
-- !--
-/

import Tropical.RiemannRoch.Rank

open Finset BigOperators

namespace BakerNorine

/-- The Brill–Noether number `ρ(g,r,d) = g-(r+1)(g-d+r)`. -/
def brillNoetherNumber (g r d : ℤ) : ℤ :=
  g - (r + 1) * (g - d + r)

/-- The half-canonical degree of a `k`-regular graph on `n` vertices. -/
def halfCanonicalDegree (k n : ℕ) : ℕ :=
  (k - 2) * n / 2

/-- Regularity in the adjacency-multiplicity model used by divisor theory. -/
def IsRegularOfDegree (G : FinGraph) (k : ℕ) : Prop :=
  ∀ v : G.V, vertexDeg G v = (k : ℤ)

/-
The total vertex degree of a regular graph is `k n`.
-/
theorem totalEdges_eq_of_regular {G : FinGraph} {k : ℕ}
    (hreg : IsRegularOfDegree G k) :
    totalEdges G = (k : ℤ) * Fintype.card G.V := by
  convert Finset.sum_congr rfl fun v _ => hreg v using 1 ; simp +decide [ mul_comm ]

/-
In a regular graph the product of the degree and number of vertices is even.
-/
theorem even_degree_mul_card_of_regular {G : FinGraph} {k : ℕ}
    (hreg : IsRegularOfDegree G k) :
    Even (k * Fintype.card G.V) := by
  have h_even : Even (totalEdges G) := even_totalEdges
  obtain ⟨ m, hm ⟩ := h_even;
  exact even_iff_two_dvd.mpr ⟨ m.natAbs, by cases abs_cases m <;> nlinarith [ totalEdges_eq_of_regular hreg ] ⟩

/-
The genus of a regular graph has the expected closed form.
-/
theorem genus_eq_halfCanonicalDegree_add_one_of_regular {G : FinGraph} {k : ℕ}
    (hreg : IsRegularOfDegree G k) (hk : 2 ≤ k) :
    genus G = (halfCanonicalDegree k (Fintype.card G.V) : ℤ) + 1 := by
  unfold genus halfCanonicalDegree;
  rw [ Int.natCast_div ];
  simp_all +decide;
  rw [ totalEdges_eq_of_regular hreg ];
  grind

/-
At `g=d+1` and `r=k-1`, the Brill–Noether number is exactly `d+1-k²`.
-/
theorem brillNoether_halfCanonical_formula {k d : ℕ} :
    brillNoetherNumber ((d : ℤ) + 1) ((k : ℤ) - 1) d =
      (d : ℤ) + 1 - (k : ℤ)^2 := by
  unfold brillNoetherNumber; ring;

/-
The explicit threshold `2k²` forces the half-canonical degree to be at
least `k²`; this deliberately leaves one unit of slack in the sharp numerical
condition `d≥k²-1`.
-/
theorem halfCanonicalDegree_ge_sq {k n : ℕ} (hk : 5 ≤ k)
    (hn : 2 * k^2 ≤ n) :
    k^2 ≤ halfCanonicalDegree k n := by
  rw [ halfCanonicalDegree ];
  rw [ Nat.le_div_iff_mul_le ] <;> nlinarith [ Nat.sub_add_cancel ( by linarith : 2 ≤ k ) ]

/-
Above the explicit threshold, the half-canonical Brill–Noether number is
non-negative.
-/
theorem brillNoether_halfCanonical_nonneg {k n : ℕ} (hk : 5 ≤ k)
    (hn : 2 * k^2 ≤ n) :
    0 ≤ brillNoetherNumber
      ((halfCanonicalDegree k n : ℤ) + 1) ((k : ℤ) - 1)
      (halfCanonicalDegree k n) := by
  unfold brillNoetherNumber;
  nlinarith [ show ( halfCanonicalDegree k n : ℤ ) ≥ k ^ 2 by exact_mod_cast halfCanonicalDegree_ge_sq hk hn ]

/-
Cross-domain form: regular graph arithmetic supplies the genus entering the
non-negative Brill–Noether calculation.
-/
theorem regularGraph_brillNoether_nonneg {G : FinGraph} {k : ℕ}
    (hreg : IsRegularOfDegree G k) (hk : 5 ≤ k)
    (hn : 2 * k^2 ≤ Fintype.card G.V) :
    0 ≤ brillNoetherNumber (genus G) ((k : ℤ) - 1)
      (halfCanonicalDegree k (Fintype.card G.V)) := by
  have := @genus_eq_halfCanonicalDegree_add_one_of_regular G k hreg ( by linarith );
  exact this.symm ▸ brillNoether_halfCanonical_nonneg hk hn

/-
A Riemann–Roch identity forces equal ranks for a divisor of degree `g-1`
and its canonical residual.  This is the half-canonical symmetry needed by an
existence argument, stated without assuming the still-missing global theorem.
-/
theorem residual_rank_eq_at_halfCanonical {G : FinGraph} (D : Divisor G)
    (hdeg : deg D = genus G - 1)
    (hRR : rank D - rank (subDiv (canonical G) D) =
      deg D - genus G + 1) :
    rank (subDiv (canonical G) D) = rank D := by
  grind

/-
Consequently any rank lower bound at degree `g-1` transfers unchanged to
the residual divisor.
-/
theorem residual_rank_ge_at_halfCanonical {G : FinGraph} (D : Divisor G) (r : ℤ)
    (hdeg : deg D = genus G - 1)
    (hRR : rank D - rank (subDiv (canonical G) D) =
      deg D - genus G + 1)
    (hrank : r ≤ rank D) :
    r ≤ rank (subDiv (canonical G) D) := by
  grind

-- !-- Lab Notes -- !--
-- Hypothesis: a second cycle tests whether arithmetic non-negativity can be
-- upgraded directly to existence.
-- Experiment: the attempted upgrade was rejected because no implication from
-- `ρ ≥ 0` to a chip-firing witness follows from the definitions.
-- Analysis: regularity completely determines the genus and numerical
-- obstruction, but not the divisor class group or reduced-divisor geometry.
-- Critique: connectedness and simplicity are unnecessary for the proved
-- arithmetic statements, while they may be essential for a future existence
-- construction; omitting them here strengthens only the verified numerics.
-- Synthesis: an eventual existence proof should construct one divisor of
-- degree `g-1`; Riemann–Roch then controls its residual simultaneously.
-- Experiment: retain the Riemann–Roch identity as an explicit hypothesis and
-- eliminate the degree term using `deg D=g-1`.
-- Analysis: the two ranks become equal, so every lower bound is automatically
-- paired under `D ↦ K-D`.
-- Critique: this symmetry does not prove existence and cannot replace the
-- missing chip-firing construction; claiming otherwise would conflate the
-- numerical and geometric parts of Brill–Noether theory.
-- Synthesis: the arithmetic obstruction is discharged above an explicit
-- threshold, while the unresolved task is cleanly localized to constructing a
-- rank-`k-1` divisor of degree `g-1`.
-- !--

end BakerNorine