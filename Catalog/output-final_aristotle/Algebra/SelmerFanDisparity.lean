/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Selmer Fan: the disparity (parity) mechanism

This file isolates the *parity rigidity* that produces the disparity phenomenon
of Klagsbrun–Mazur–Rubin (`KMR14`).

## Mathematical context

As one climbs a `p`-cyclic tower (or adds ramified primes to a twist, as in the
Swinnerton-Dyer families `SDtwists`), the `p`-Selmer rank changes by exactly `±1`
at each step.  Consequently the parity of the Selmer rank after `n` steps is
completely determined by the starting rank and by `n` — it cannot fluctuate.
This rigidity is the source of the *disparity* between even and odd Selmer ranks
observed in `KMR14`.

We model this by a **Selmer walk**: an integer sequence `w : ℕ → ℤ` whose
consecutive differences are `±1`.  The main theorem states the parity invariant,
and a corollary records that a *closed* walk (one returning to its start) must
have even length — a genuine parity obstruction.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): if the Selmer rank moves by `±1` at each step, its
parity after `n` steps equals the starting parity shifted by `n`; hence a walk
returning to its starting rank must take an even number of steps.
Experiment (Experimenter): checked by hand on the four walks of length 2
(`0→1→0`, `0→1→2`, `0→-1→0`, `0→-1→-2`): all end at a value `≡ 0 (mod 2)`.
Analysis (Analyst): the invariant is `w n ≡ w 0 + n (mod 2)`; the induction
step uses `-1 ≡ 1 (mod 2)`, so both `+1` and `-1` advance the parity identically.
Critique (Critic): the statement is not vacuous — the hypothesis is satisfiable
(e.g. `w = fun i => (i : ℤ)`), and the proof genuinely uses `Int.ModEq` and case
analysis on the `±1` step, not `decide`.
Synthesis: parity rigidity of `±1` walks is exactly the combinatorial heart of
Selmer-rank disparity.
-- !-- Lab Notes -- !--
-/
import Mathlib

namespace SelmerFan

/-- A **Selmer walk**: consecutive `p`-Selmer ranks along a tower differ by `±1`. -/
def IsSelmerWalk (w : ℕ → ℤ) : Prop :=
  ∀ i, w (i + 1) = w i + 1 ∨ w (i + 1) = w i - 1

/-
**Parity rigidity / disparity mechanism.**  Along a Selmer walk the parity of
the rank after `n` steps is forced: `w n ≡ w 0 + n (mod 2)`.
-/
theorem selmerWalk_parity {w : ℕ → ℤ} (hw : IsSelmerWalk w) (n : ℕ) :
    w n ≡ w 0 + n [ZMOD 2] := by
  induction n <;> simp_all +decide [ Int.ModEq, ← add_assoc ];
  cases hw ‹_› <;> omega

/-
A closed Selmer walk (one that returns to its starting rank) has even length:
a parity obstruction to short "loops" in the tower.
-/
theorem selmerWalk_closed_even {w : ℕ → ℤ} (hw : IsSelmerWalk w) {n : ℕ}
    (hclosed : w n = w 0) : Even n := by
  have := selmerWalk_parity hw n; simp_all +decide [ Int.modEq_iff_dvd ] ;
  exact even_iff_two_dvd.mpr ( Int.natCast_dvd_natCast.mp this )

end SelmerFan