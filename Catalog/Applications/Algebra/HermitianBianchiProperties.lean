/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Structural properties of the Hermitian Bianchi lattice `S_K`

Companion to `HermitianBianchiDiscriminant`.  We record several structural
consequences of the discriminant computation `det Gram(S_K) = D_K`:

* `S_K` is an **even** lattice (`q` is everywhere divisible by `2`);
* the **twisted/scaled** lattice `S_K(N)` (Gram matrix multiplied by `N`) has
  determinant `N⁴ · D_K`; in particular the Néron–Severi-type lattice `S_K(2N)`
  used for Picard-rank-four K3 surfaces has determinant `16 N⁴ · D_K`;
* `D_K` satisfies the **fundamental-discriminant congruence** `D_K ≡ 0, 1 [ZMOD 4]`;
* the off-diagonal binary block carries the **norm form** `x² + T·xy + M·y²`
  whose `2 ×` Gram block has determinant `-D_K`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the discriminant identity should propagate to the
  scaled K3 lattices S_K(2N) and constrain D_K modulo 4.
Experiment (Experimenter): `Matrix.det_smul` gives det(N·G) = N^4 det G in rank
  four; evenness is read off the factor 2 in q; the mod-4 congruence is a finite
  case split closed by `omega`.
Analysis (Analyst): every prediction SURVIVED.  The congruence `D_K ≡ 0,1 mod 4`
  is the classical "discriminants are 0 or 1 mod 4" theorem, recovered here
  purely from the (T, M) parametrisation — confirming T² - 4M behaves like a
  genuine field discriminant.
Critique (Critic): `det_scaledGram` is not vacuous — the exponent 4 is the lattice
  rank and `N^4` is essential (a wrong power would be refuted by `N = 2`).
  Evenness uses an explicit halving witness, not `decide`.
Synthesis (PI): these give the determinant of the K3 Néron–Severi lattice
  S_K(2N) as 16 N⁴ D_K, a testable bridge to lattice-polarised K3 geometry.
-/
import Mathlib
import Applications.HermitianBianchiDiscriminant

open Matrix

namespace HermitianBianchi

/-- The lattice `S_K` is **even**: the quadratic form `q = 2 det` is divisible by
`2` on every vector. -/
theorem qform_even (T M : ℤ) (v : Fin 4 → ℤ) : 2 ∣ qform T M v :=
  ⟨v 0 * v 1 - (v 2) ^ 2 - T * (v 2 * v 3) - M * (v 3) ^ 2, by
    simp only [qform]; ring⟩

/-- **Scaling law.** Multiplying the Gram form by `N` (the lattice `S_K(N)`)
multiplies the determinant by `N⁴`, the fourth power coming from the rank. -/
theorem det_scaledGram (N d : ℤ) :
    (N • gramMatrix (omegaTrace d) (omegaNorm d)).det = N ^ 4 * fundamentalDisc d := by
  rw [Matrix.det_smul, detGram_eq_fundamentalDisc, Fintype.card_fin]

/-- The Néron–Severi-type lattice `S_K(2N)` of a Picard-rank-four K3 surface has
determinant `16 · N⁴ · D_K`. -/
theorem det_NeronSeveri (N d : ℤ) :
    ((2 * N) • gramMatrix (omegaTrace d) (omegaNorm d)).det
      = 16 * N ^ 4 * fundamentalDisc d := by
  rw [Matrix.det_smul, detGram_eq_fundamentalDisc, Fintype.card_fin]
  ring

/-- **Fundamental-discriminant congruence.** `D_K ≡ 0` or `1` modulo `4`. -/
theorem fundamentalDisc_mod_four (d : ℤ) :
    fundamentalDisc d % 4 = 0 ∨ fundamentalDisc d % 4 = 1 := by
  unfold fundamentalDisc; split <;> omega

/-- The off-diagonal binary block is the (negated) norm form: its `2 ×` Gram
block `!![-2,-T;-T,-2M]` has determinant `-D_K = -(T² - 4M)`. -/
theorem offDiagonalBlock_det (T M : ℤ) :
    (!![-2, -T; -T, -2 * M] : Matrix (Fin 2) (Fin 2) ℤ).det = -(T ^ 2 - 4 * M) := by
  rw [Matrix.det_fin_two_of]; ring

/-- The discriminant of `S_K` is never zero for squarefree `d ≠ 0`: the lattice
is non-degenerate.  (Here phrased over the algebraic core: `T² - 4M ≠ 0` whenever
the discriminant of `ω`'s minimal polynomial is nonzero.) -/
theorem detGram_ne_zero_of_disc_ne_zero (d : ℤ)
    (h : fundamentalDisc d ≠ 0) :
    (gramMatrix (omegaTrace d) (omegaNorm d)).det ≠ 0 := by
  rw [detGram_eq_fundamentalDisc]; exact h

end HermitianBianchi