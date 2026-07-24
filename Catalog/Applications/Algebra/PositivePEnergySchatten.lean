/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Positive p-Energy as Half the Schatten p-Energy of a Bipartite Spectrum

This file connects the *positive p-energy* `E_p^+ = ∑_{λ>0} λ^p` to the full **absolute
(Schatten) p-energy** `‖E‖_p^p = ∑_k |λ_k|^p` of a finite real spectrum.

The two basic facts are:

* `absEnergy_eq_pos_add_neg` — for any spectrum and any nonzero exponent `p`, the absolute
  p-energy splits as `E_p^+ + E_p^-`.  (The hypothesis `p ≠ 0` is genuinely needed: a spectrum
  with a zero eigenvalue contributes `0^0 = 1` to the absolute energy at `p = 0` but `0` to both
  signed energies, so the identity fails there.)
* `absEnergy_eq_two_posEnergy_of_antisymm` — for a **reflection-antisymmetric** (bipartite)
  spectrum, the absolute p-energy is exactly *twice* the positive p-energy.  Equivalently the
  positive p-energy is `½ ∑_k |λ_k|^p`: for bipartite graphs the positive p-energy is a genuine
  Schatten norm, up to the factor `½`.

Both reuse the abstract bipartite balance
`PositivePEnergy.posEnergy_eq_negEnergy_of_antisymm` from
`Catalog.Probability.PositivePEnergyBipartiteBalance`.

-- !-- Lab Notes -- !--
Cycle 3 Hypothesis (Hypothesizer): the positive p-energy of a bipartite spectrum is not an ad hoc
one-sided sum but literally half of a Schatten `p`-norm `(∑|λ|^p)^{1/p}` raised to the `p`.  If so,
positive-energy path-minimality is a Schatten-norm minimisation in disguise.
Experiment (Experimenter): split `∑|λ_k|^p` termwise by the sign of `λ_k`.  The identity
`E_p^+ + E_p^- = ∑|λ|^p` needs `p ≠ 0` because of the `0^0` anomaly at a zero eigenvalue (paths of
odd order have one).  With the balance `E_p^+ = E_p^-` the sum collapses to `2 E_p^+`.
Analysis (Analyst): the `p ≠ 0` hypothesis is load-bearing and was discovered only by the
zero-eigenvalue case; the antisymmetric-spectrum version is the reusable "positive = half Schatten"
bridge that makes the `p = 2` graph result (`∑λ² = 2|E|`, companion file) equal to `E_2^+ = |E|`
for bipartite graphs.
Critique (Critic): neither statement is vacuous — the split fails at `p = 0`, and the doubling
fails for non-antisymmetric spectra (e.g. `K_3` with `{2,-1,-1}` has `∑|λ|^p = 2^p + 2` while
`2 E_p^+ = 2·2^p`).  Proofs use `rcases`/`lt_trichotomy` sign case analysis, not `decide`.
Synthesis (PI): positive p-energy of a bipartite graph = ½ · Schatten p-energy; the extremal
question is a Schatten-norm minimisation over connected bipartite graphs.
-/
import Mathlib
import Catalog.Probability.PositivePEnergyBipartiteBalance

open Real Finset

namespace PositivePEnergy

/-- **Sign split of the absolute p-energy.**  For any finite real spectrum `f 0, …, f (n-1)`
and any nonzero exponent `p`, the absolute (Schatten) p-energy `∑_k |f k|^p` decomposes as the
sum of the positive p-energy `∑_{f k > 0} (f k)^p` and the negative p-energy
`∑_{f k < 0} (-f k)^p`. -/
theorem absEnergy_eq_pos_add_neg (n : ℕ) (p : ℝ) (f : ℕ → ℝ) (hp : p ≠ 0) :
    ∑ k ∈ range n, |f k| ^ p
      = (∑ k ∈ range n, if 0 < f k then f k ^ p else 0)
        + (∑ k ∈ range n, if f k < 0 then (- f k) ^ p else 0) := by
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro k _
  rcases lt_trichotomy (f k) 0 with h | h | h
  · rw [abs_of_neg h]; simp [not_lt.mpr h.le, h]
  · simp [h, Real.zero_rpow hp]
  · rw [abs_of_pos h]; simp [h, not_lt.mpr h.le]

/-- **Positive p-energy is half the Schatten p-energy of a bipartite spectrum.**  If a finite real
spectrum is antisymmetric under index reflection (`f (n-1-k) = - f k`, the spectral signature of
bipartiteness) and `p ≠ 0`, then its absolute p-energy `∑_k |f k|^p` equals twice its positive
p-energy. -/
theorem absEnergy_eq_two_posEnergy_of_antisymm (n : ℕ) (p : ℝ) (f : ℕ → ℝ) (hp : p ≠ 0)
    (hf : ∀ k, k < n → f (n - 1 - k) = - f k) :
    ∑ k ∈ range n, |f k| ^ p
      = 2 * (∑ k ∈ range n, if 0 < f k then f k ^ p else 0) := by
  rw [absEnergy_eq_pos_add_neg n p f hp]
  rw [← posEnergy_eq_negEnergy_of_antisymm n p f hf]
  ring

end PositivePEnergy