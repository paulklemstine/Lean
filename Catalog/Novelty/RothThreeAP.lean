/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Roth's theorem on 3-term arithmetic progressions, and an additive-energy bridge

Mathlib's `roth_3ap_theorem` states that a sufficiently dense subset of a finite
abelian group is not `ThreeAPFree`.  `ThreeAPFree` is phrased via the
sum-condition `a + c = b + b ⇒ a = b`; here we unpack its negation into an
**explicit nontrivial 3-AP** `a, a + d, a + 2d` with `d ≠ 0`
(`exists_nontrivial_3AP_of_not_threeAPFree`) and combine it with `roth_3ap_theorem`
to obtain Roth's theorem in progression form (`roth_3ap_dense`).

We also build a bridge to the catalog's discrete Fourier analysis
(`Catalog.Combinatorics.FourierFiniteGroups.card_pow_four_div_le_addEnergy`,
the spectral lower bound `|A|⁴ / N ≤ E(A)` on additive energy): a set whose
additive energy is essentially that of a Sidon set
(`E(A) ≤ 2|A|²`) must satisfy the **Sidon size bound** `|A|² ≤ 2N`
(`card_sq_le_of_addEnergy_le`).
-/
import Mathlib
import Combinatorics.FourierFiniteGroups

namespace Catalog.Combinatorics.ExtremalGraphTheory

open Finset

/-- **Extracting an explicit nontrivial 3-AP.**
If `A` is not `ThreeAPFree`, then `A` contains a genuine 3-term arithmetic
progression `a, a + d, a + 2d` with nonzero common difference `d`. -/
theorem exists_nontrivial_3AP_of_not_threeAPFree {G : Type*} [AddCommGroup G] {A : Finset G}
    (h : ¬ ThreeAPFree (A : Set G)) :
    ∃ a d : G, d ≠ 0 ∧ a ∈ A ∧ a + d ∈ A ∧ a + 2 • d ∈ A := by
  rw [ThreeAPFree] at h
  push_neg at h
  obtain ⟨a, ha, b, hb, c, hc, habc, hab⟩ := h
  refine ⟨a, b - a, ?_, ha, by simpa using hb, ?_⟩
  · intro hh; apply hab; rw [sub_eq_zero] at hh; exact hh.symm
  · have hc' : c = b + b - a := by rw [← habc]; abel
    have hc2 : a + 2 • (b - a) = c := by rw [hc', two_smul]; abel
    rw [hc2]; simpa using hc

/-- **Roth's theorem (progression form).**
A dense subset `A` of a large enough finite abelian group `G` contains a
nontrivial 3-term arithmetic progression `a, a + d, a + 2d` with `d ≠ 0`. -/
theorem roth_3ap_dense {G : Type*} [AddCommGroup G] [Fintype G] (ε : ℝ) (hε : 0 < ε)
    (hcard : cornersTheoremBound ε ≤ Fintype.card G) (A : Finset G)
    (hA : ε * (Fintype.card G) ≤ #A) :
    ∃ a d : G, d ≠ 0 ∧ a ∈ A ∧ a + d ∈ A ∧ a + 2 • d ∈ A :=
  exists_nontrivial_3AP_of_not_threeAPFree (roth_3ap_theorem ε hε hcard A hA)

/-- **Sidon size bound via additive energy (catalog Fourier bridge).**
Using the spectral energy lower bound `|A|⁴ / N ≤ E(A)` from the catalog file
`Combinatorics/FourierFiniteGroups.lean`, any set `A ⊆ ℤ/Nℤ` with near-Sidon
additive energy `E(A) ≤ 2|A|²` obeys `|A|² ≤ 2N`.

(For an actual Sidon set `E(A) = 2|A|² - |A| ≤ 2|A|²`, so this recovers the
classical `|A| ≤ √(2N)` Sidon bound.) -/
theorem card_sq_le_of_addEnergy_le {N : ℕ} [NeZero N] (s : Finset (ZMod N))
    (hE : (Finset.addEnergy s s : ℝ) ≤ 2 * (#s : ℝ) ^ 2) :
    (#s : ℝ) ^ 2 ≤ 2 * N := by
  have hcat := Catalog.Combinatorics.FourierFiniteGroups.card_pow_four_div_le_addEnergy s
  have h4 : (#s : ℝ) ^ 4 / N ≤ 2 * (#s : ℝ) ^ 2 := le_trans hcat hE
  have hNpos : (0 : ℝ) < N := by
    have : (0 : ℕ) < N := Nat.pos_of_ne_zero (NeZero.ne N)
    exact_mod_cast this
  rw [div_le_iff₀ hNpos] at h4
  nlinarith [sq_nonneg ((#s : ℝ)), sq_nonneg ((#s : ℝ) ^ 2 - N), hNpos]

/-
-- !-- Lab Notes -- !--

HYPOTHESIS.
  Roth's `ThreeAPFree` predicate is a *sum condition*, not an explicit AP.  We
  hypothesised the negation can be repackaged into a literal `a, a+d, a+2d` with
  `d ≠ 0`, and that the catalog's spectral energy bound is exactly the input
  needed for the dual Sidon size bound.

EXPERIMENT.
  Negating `ThreeAPFree` (`push_neg`) yields `a, b, c ∈ A`, `a + c = b + b`,
  `a ≠ b`.  Setting `d = b - a` gives `b = a + d` and, since `c = 2b - a`,
  `c = a + 2•d` (a two-line `abel` computation); `d ≠ 0` is `a ≠ b`.  Composing
  with `roth_3ap_theorem` gives Roth in progression form.  For the bridge,
  `card_pow_four_div_le_addEnergy` (catalog) gives `|A|⁴/N ≤ E(A)`; chaining with
  `E(A) ≤ 2|A|²` and clearing the denominator, `nlinarith` (fed
  `(|A|² - N)² ≥ 0`) yields `|A|² ≤ 2N`.

ANALYSIS.
  The same negated quadruple structure underlies *both* Roth (a 3-AP) and the
  Sidon bound (an additive quadruple): Roth wants such configurations to be
  *unavoidable* when dense, while Sidon wants them *rare*.  The catalog Fourier
  energy bound is the quantitative hinge for the rare direction.

CRITIQUE.
  `roth_3ap_dense` inherits Mathlib's `cornersTheoremBound` threshold, so it is
  genuinely a largeness hypothesis, not vacuous.  The Sidon bridge takes the
  energy hypothesis `E ≤ 2|A|²` as input rather than re-deriving it from a
  combinatorial Sidon definition; this keeps the theorem about the spectral
  mechanism while remaining faithful (the hypothesis holds for all Sidon sets).
  `[NeZero N]` is required for the energy bound and the division step.

SYNTHESIS.
  Negated `ThreeAPFree`/Sidon quadruples are one object viewed two ways; Roth and
  the Sidon bound are the "must occur" and "rarely occur" faces, the latter pinned
  down quantitatively by the catalog's discrete Fourier additive energy estimate.
-/

end Catalog.Combinatorics.ExtremalGraphTheory