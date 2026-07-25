/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Abstract Bipartite Balance of Positive p-Energies

The path result `PositivePEnergy.path_posEnergy_eq_negEnergy` (from
`Catalog.Probability.PositivePEnergyPathMinimal`) is a special case of a purely combinatorial
phenomenon: whenever a finite real spectrum `f 0, …, f (n-1)` is *antisymmetric under index
reflection* — meaning `f (n-1-k) = - f k` — its positive and negative p-energies coincide, for
every real exponent `p`.

This is exactly the spectral fingerprint of a **bipartite** adjacency matrix: bipartiteness makes
the spectrum symmetric about `0`, and index reflection realises the pairing `λ ↔ -λ`.  We isolate
this as a reusable statement and then recover the path graph corollary through the reflection
identity `PositivePEnergy.pathEig_reflect` proved in the companion file.

## Main statement
* `posEnergy_eq_negEnergy_of_antisymm` — abstract bipartite balance for any reflection-antisymmetric
  spectrum.
* `path_posEnergy_eq_negEnergy_via_abstract` — the path graph balance re-derived as a corollary,
  demonstrating that the abstraction subsumes the concrete companion result.

-- !-- Lab Notes -- !--
Cycle 2 Hypothesis (Hypothesizer): the "positive = negative p-energy" identity for the path is not
about cosines at all; it is a shadow of a general involution symmetry. Conjecture: any real spectrum
carrying a fixed-point-free-up-to-sign reflection has balanced positive/negative p-energy.
Experiment (Experimenter): abstract the argument away from `pathEig`, replacing the reflection lemma
by a hypothesis `f (n-1-k) = -f k`; the proof reduces to `Finset.sum_range_reflect` plus a termwise
sign case split, with no trigonometry.
Analysis (Analyst): the abstraction is strictly more general and immediately reproves the path case;
the novelty is recognising bipartite spectral symmetry as an order-reversing involution on indices.
Critique (Critic): the hypothesis is genuinely load-bearing (a spectrum without the symmetry, e.g.
a triangle `K_3` with spectrum `{2,-1,-1}`, has `E_p^+ ≠ E_p^-`), so the theorem is not vacuous.
Synthesis: bipartite balance is an involution theorem; the path is one instance among many.
-/
import Mathlib
import Catalog.Probability.PositivePEnergyPathMinimal

open Real Finset

namespace PositivePEnergy

/-
**Abstract bipartite balance.** If a finite real spectrum `f 0, …, f (n-1)` is antisymmetric
under index reflection (`f (n-1-k) = - f k` for `k < n`), then its positive and negative
`p`-energies coincide, for every real exponent `p`.
-/
theorem posEnergy_eq_negEnergy_of_antisymm (n : ℕ) (p : ℝ) (f : ℕ → ℝ)
    (hf : ∀ k, k < n → f (n - 1 - k) = - f k) :
    (∑ k ∈ Finset.range n, (if 0 < f k then f k ^ p else 0))
      = (∑ k ∈ Finset.range n, (if f k < 0 then (- f k) ^ p else 0)) := by
  rw [ ← Finset.sum_range_reflect ];
  exact Finset.sum_congr rfl fun x hx => by specialize hf x ( Finset.mem_range.mp hx ) ; split_ifs <;> aesop;

/-
The path graph bipartite balance, recovered as a corollary of the abstract theorem via the
reflection identity `pathEig_reflect`.
-/
theorem path_posEnergy_eq_negEnergy_via_abstract (n : ℕ) (p : ℝ) :
    posEnergyPath n p = negEnergyPath n p := by
  rw [posEnergyPath, negEnergyPath]
  exact posEnergy_eq_negEnergy_of_antisymm n p (pathEig n) (fun k hk => pathEig_reflect n k hk)

end PositivePEnergy