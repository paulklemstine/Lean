/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Falsifiability of the spectral condition through explicit construction

The Fisher / Hegedűs bound `m ≤ n` of `EquiangularFisher.lean` requires the strict
inequality `λ < k`, which is precisely what makes the constant-pattern Gram matrix
*positive definite* (all eigenvalues positive).  This file makes the boundary of
the theorem **falsifiable through an explicit construction**:

* When `λ = k` the hypothesis fails, and the constant family `A i = univ` provides
  `m = n + 1 > n` sets satisfying all the *remaining* hypotheses — so the conclusion
  `m ≤ n` is genuinely false without the eigenvalue gap.
* For that degenerate family the Gram matrix is **not positive definite**: the
  incidence vectors coincide, so they are linearly dependent and the eigenvalue
  condition (positivity) breaks.  This is the spectral signature of the failure.

Together these show the spectral/eigenvalue constraint is not cosmetic: it is the
exact dividing line of the bound.
-/
import Mathlib
import Novelty.HegedusSpectral.SpectralBound
import Novelty.HegedusSpectral.EquiangularFisher

open Matrix

namespace HegedusSpectral

variable {n : ℕ}

/-- **Necessity of `λ < k` (explicit counterexample).**  For every nonempty ground
set there is a uniform family with `m = n + 1 > n` members, each of size `n`, all
pairwise intersections of size `n` (i.e. `λ = k = n`, violating `λ < k`), for which
the bound `m ≤ n` fails.  Hence the eigenvalue gap cannot be dropped. -/
theorem fisher_lam_lt_k_necessary (n : ℕ) :
    ∃ (m : ℕ) (A : Fin m → Finset (Fin n)),
      (∀ i, (A i).card = n) ∧
      (∀ i j, i ≠ j → (A i ∩ A j).card = n) ∧ n < m := by
  refine ⟨n + 1, fun _ => Finset.univ, ?_, ?_, ?_⟩
  · intro i; simp
  · intro i j _; simp
  · exact Nat.lt_succ_self n

/-- **Spectral signature of the failure.**  For `2 ≤ m` the Gram matrix of `m`
identical incidence vectors (here the indicator of `univ`) is *not* positive
definite: the vectors are linearly dependent, so the eigenvalue condition fails. -/
theorem degenerate_gram_not_posDef {m : ℕ} (hm : 2 ≤ m) :
    ¬ (Matrix.gram ℝ (fun _ : Fin m => incidence (Finset.univ : Finset (Fin n)))).PosDef := by
  intro hpd
  have hli : LinearIndependent ℝ (fun _ : Fin m => incidence (Finset.univ : Finset (Fin n))) :=
    (Matrix.posDef_gram_iff_linearIndependent).1 hpd
  -- two distinct indices map to the same vector, contradicting injectivity
  have hinj := hli.injective
  have h01 : (⟨0, by omega⟩ : Fin m) ≠ ⟨1, by omega⟩ := by
    simp [Fin.ext_iff]
  exact h01 (hinj rfl)

end HegedusSpectral

/-
-- !-- Lab Notes -- !--

Category (Menu Balance v19a): CROSS-DOMAIN BRIDGE (boundary / falsifiability).

Hypothesis (Hypothesizer):
  H1. The strict gap `λ < k` (equivalently: positive definiteness, all Gram
      eigenvalues > 0) is necessary, not cosmetic.
  H2 (bold). Dropping it must allow arbitrarily many sets, and the spectral
      witness of the failure is a vanishing eigenvalue (singular Gram matrix).

Experiment (Experimenter):
  * `fisher_lam_lt_k_necessary` : the constant family `A i = univ` gives
    `m = n+1 > n` with `k = λ = n`, refuting `m ≤ n` once the gap is removed.
  * `degenerate_gram_not_posDef` : for `2 ≤ m` the identical incidence vectors
    are linearly dependent, so by `posDef_gram_iff_linearIndependent` the Gram
    matrix is NOT positive definite — the eigenvalue condition fails exactly
    when the bound fails.

Analysis (Analyst):
  - True-but-boundary: the theorem is sharp precisely at `λ = k`.  The algebraic
    cause (dependent incidence vectors) and the spectral cause (lost positive
    definiteness) coincide, validating the spectral framing.

Critique (Critic):
  - These are honest counterexamples (existence with explicit construction and a
    `by_contra`-style refutation of PosDef), not trivialities.
  - Corner case `n = 0`: `degenerate_gram_not_posDef` still holds (all vectors
    are the zero vector of the trivial space, hence dependent).

Synthesis (PI):
  The eigenvalue gap is the exact dividing line of the Fisher/Hegedűs bound;
  removing it breaks both the combinatorial conclusion and the spectral
  hypothesis simultaneously.
-/