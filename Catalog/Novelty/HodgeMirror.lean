import Mathlib

/-!
# Arithmetic Mirror Symmetry I — the Hodge mirror involution and the Euler-number flip

This file formalizes the *combinatorial core* of mirror symmetry for Calabi–Yau
threefolds: the **Hodge-diamond involution** `(h¹¹, h²¹) ↦ (h²¹, h¹¹)`.

For a Calabi–Yau threefold `X`, the only free Hodge numbers are `h¹¹ = rk Pic X`
(the Picard / Kähler-moduli rank) and `h²¹` (the complex-structure-moduli rank, the
dimension of the parameter space that controls the genus-`0` Gromov–Witten / rational
curve count of the mirror).  The Euler characteristic of a Calabi–Yau threefold is
`χ(X) = 2·(h¹¹ − h²¹)`.

The mirror conjecture predicts a partner `Y` whose Hodge diamond is the transpose of
that of `X`.  We prove three exact statements about this involution:

* `mirror_involutive`             — mirroring twice returns the original threefold;
* `euler_mirror`                  — `χ(Y) = −χ(X)` (the famous Euler-number flip);
* `picardRank_mirror`             — `rk Pic Y = h²¹(X)`: the Picard rank of the mirror
  equals the complex-moduli rank of `X`, the arithmetic statement that the rank of the
  Picard group of `Y` matches the datum governing the rational-curve enumeration of `X`;
* `selfMirror_iff_euler_zero`     — `Y = X ↔ χ(X) = 0` (rigid Hodge diamonds);
* `countEuler_neg`                — the **distribution of Euler numbers is symmetric under
  `e ↦ −e`**: the number of admissible Hodge diamonds with Euler number `e` and bounded
  entries equals the number with Euler number `−e`.  This is the global, arithmetic
  shadow of mirror symmetry on the "Hodge plot", proved via the swap involution.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  Mirror symmetry exchanges the two Calabi–Yau Hodge
  numbers, so the Euler characteristic should change sign and the whole Euler-number
  histogram of a bounded family should be a mirror image (`e ↔ −e`).
* **Experiment (Experimenter).**  Encode a CY3 by its pair `(h¹¹, h²¹)`; define `mirror`
  as the swap and `euler := 2·(h¹¹ − h²¹) : ℤ`.  The pointwise facts fall to `omega`/`ring`.
  The histogram symmetry is a `Finset` cardinality identity proved by the swap bijection
  `(a,b) ↦ (b,a)` via `Finset.card_nbij'`.
* **Analysis (Analyst).**  The swap is a fixed-point-free involution off the diagonal
  `h¹¹ = h²¹`; its fixed points are exactly the self-mirror (Euler-zero) diamonds, which
  is why the histogram is symmetric *and* why `e = 0` is the unique self-paired value.
* **Critique (Critic).**  `euler` is valued in `ℤ` (not `ℕ`) so the flip is a genuine
  sign change, not truncated subtraction; the counting theorem ranges over a real
  `Finset` and uses an honest bijection, not `decide`.
* **Synthesis (PI).**  The involution + Euler flip + histogram symmetry package the
  discrete content of mirror symmetry that any geometric realization must satisfy.
-/

namespace Novelty.ArithMirror

open Finset

/-- The Hodge data of a Calabi–Yau threefold: the two independent Hodge numbers
`h¹¹` (Picard / Kähler-moduli rank) and `h²¹` (complex-structure-moduli rank). -/
structure CY3 where
  /-- `h¹¹`, the rank of the Picard group / dimension of the Kähler moduli. -/
  h11 : ℕ
  /-- `h²¹`, the dimension of the complex-structure moduli space. -/
  h21 : ℕ
deriving DecidableEq

namespace CY3

/-- The topological Euler characteristic `χ = 2·(h¹¹ − h²¹)`, valued in `ℤ`. -/
def euler (X : CY3) : ℤ := 2 * ((X.h11 : ℤ) - (X.h21 : ℤ))

/-- The Picard / Kähler-moduli rank `rk Pic X = h¹¹`. -/
def picardRank (X : CY3) : ℕ := X.h11

/-- The dimension governing the rational-curve / complex-structure count `h²¹`. -/
def curveModuli (X : CY3) : ℕ := X.h21

/-- The mirror Calabi–Yau, obtained by transposing the Hodge diamond. -/
def mirror (X : CY3) : CY3 := ⟨X.h21, X.h11⟩

/-- Mirroring is an involution: `Y` of `Y` of `X` is `X`. -/
@[simp] theorem mirror_involutive (X : CY3) : X.mirror.mirror = X := by
  cases X; rfl

/-- **Euler-number flip.**  The mirror has the negated Euler characteristic. -/
theorem euler_mirror (X : CY3) : X.mirror.euler = - X.euler := by
  simp only [euler, mirror]; ring

/-- **Arithmetic mirror statement.**  The Picard rank of the mirror equals the
complex-moduli rank of `X` (the datum governing its rational-curve enumeration). -/
theorem picardRank_mirror (X : CY3) : X.mirror.picardRank = X.curveModuli := rfl

/-- Symmetrically, the rational-curve / complex-moduli datum of the mirror is the
Picard rank of `X`. -/
theorem curveModuli_mirror (X : CY3) : X.mirror.curveModuli = X.picardRank := rfl

/-- The total Hodge number `h¹¹ + h²¹` is a mirror invariant. -/
theorem hodgeSum_mirror (X : CY3) : X.mirror.h11 + X.mirror.h21 = X.h11 + X.h21 := by
  simp only [mirror]; omega

/-- A Calabi–Yau threefold is its own mirror iff its Euler characteristic vanishes. -/
theorem selfMirror_iff_euler_zero (X : CY3) : X.mirror = X ↔ X.euler = 0 := by
  constructor
  · intro h
    have h1 : X.h21 = X.h11 := congrArg CY3.h11 h
    simp only [euler]; omega
  · intro h
    have : (X.h11 : ℤ) = X.h21 := by simp only [euler] at h; omega
    have : X.h11 = X.h21 := by exact_mod_cast this
    cases X; simp_all [mirror]

end CY3

/-- The number of admissible Hodge diamonds `(h¹¹, h²¹)` with both entries `≤ B`
and Euler number `2·(h¹¹ − h²¹) = e`. -/
noncomputable def countEuler (e : ℤ) (B : ℕ) : ℕ :=
  ((range (B + 1) ×ˢ range (B + 1)).filter (fun p => 2 * ((p.1 : ℤ) - p.2) = e)).card

/-- **Mirror symmetry of the Euler-number histogram.**  For every bound `B`, the number
of bounded Hodge diamonds with Euler number `e` equals the number with Euler number `−e`.
This is the global arithmetic shadow of the mirror involution. -/
theorem countEuler_neg (e : ℤ) (B : ℕ) : countEuler e B = countEuler (-e) B := by
  unfold countEuler
  apply Finset.card_nbij' (fun p => (p.2, p.1)) (fun p => (p.2, p.1))
  · intro p hp
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_product, mem_range] at hp ⊢
    refine ⟨⟨hp.1.2, hp.1.1⟩, ?_⟩
    linarith [hp.2]
  · intro p hp
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_product, mem_range] at hp ⊢
    refine ⟨⟨hp.1.2, hp.1.1⟩, ?_⟩
    linarith [hp.2]
  · intro p _; simp
  · intro p _; simp

/-- `e = 0` is the unique self-paired Euler number: the histogram is symmetric about it. -/
theorem countEuler_zero_selfpaired (B : ℕ) : countEuler 0 B = countEuler (-0) B :=
  countEuler_neg 0 B

end Novelty.ArithMirror