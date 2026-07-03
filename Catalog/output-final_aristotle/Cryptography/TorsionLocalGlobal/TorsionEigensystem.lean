/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Catalog.NumberTheory.Langlands.HeckeFactorization

/-!
# From torsion Hecke eigensystems to `ℓ`-adic eigensystems (the inverse-limit step)

Torsion local–global compatibility begins with a torsion Hecke eigenclass in the cohomology of the
arithmetic manifold for `GL_n / F` with coefficients in `ℤ/ℓ^m`.  The eigenclass records a system
of Hecke eigenvalues in `ℤ/ℓ^m`.  A *compatible* system of such torsion eigensystems (one for each
`m`, agreeing under the reduction maps `ℤ/ℓ^{m+1} ↠ ℤ/ℓ^m`) is exactly the input needed to produce a
Galois representation valued in `ℤ_ℓ = lim_m ℤ/ℓ^m`.

This file formalizes the algebraic heart of that assembly step: the universal property that a
compatible system of ring homomorphisms into the finite quotients `ℤ/ℓ^k` glues to a **unique**
homomorphism into `ℤ_ℓ` reducing to each of them.  Read `f k` as "the Hecke eigenvalue system read
modulo `ℓ^k`", and the conclusion as "the eigenvalues assemble into a unique `ℓ`-adic eigenvalue
system".  This is the honest, characteristic-`ℓ`-to-`ℤ_ℓ` lifting that the conjecture presupposes.

We also connect to the `GL(1)` incarnation via the catalog file
`Catalog.NumberTheory.Langlands.HeckeFactorization`: a torsion Hecke eigensystem for `GL(1)` of
level `n` is a Dirichlet character mod `n`, and in the prime-power (`ℓ^k`) torsion setting the number
of such eigensystems is `φ(ℓ^k) = ℓ^{k-1}(ℓ-1)`.

Main results:

* `TorsionLG.torsion_eigensystem_lift` — **existence & uniqueness of the `ℓ`-adic assembly**: a
  compatible system `f : (k : ℕ) → R →+* ℤ/p^k` of torsion eigensystems lifts to a unique ring hom
  `F : R →+* ℤ_p` with `(toZModPow k) ∘ F = f k` for all `k`.
* `TorsionLG.torsion_eigensystem_lift_reduces` — the assembled `ℓ`-adic eigenvalue `F r` reduces
  modulo `p^k` to the given torsion eigenvalue `f k r`.
* `TorsionLG.card_torsion_eigensystem_primePow` — in the `GL(1)` prime-power torsion setting the
  number of torsion Hecke eigensystems of level `p^k` is `p^{k-1}(p-1)`, using the catalog result
  `HeckeFactorization.card_dirichlet_eq_totient`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the passage "torsion eigenclass mod ℓ^m ⇒ ℤ_ℓ Galois representation"
must, stripped of representation theory, be the inverse-limit universal property `ℤ_ℓ = lim ℤ/ℓ^k`
applied to the eigenvalue system.  Uniqueness (not just existence) is the load-bearing part: it is
what makes the ℓ-adic representation canonically attached to the torsion class.

Experiment (Experimenter): tested the statement against `PadicInt.lift`/`lift_spec` and the
extensionality `PadicInt.ext_of_toZModPow`.  For the GL(1) count, checked `p=3,k=2`: `φ(9)=6=3·2`.

Analysis (Analyst): existence is `PadicInt.lift`; uniqueness is genuine and needs
`ext_of_toZModPow` to compare two lifts level by level.  The GL(1) corollary reuses the catalog's
`card_dirichlet_eq_totient` and Mathlib's `Nat.totient_prime_pow`; without the prime-power structure
the count would not factor so cleanly, which is exactly why the torsion coefficients are `ℤ/ℓ^m`.

Critique (Critic): is `torsion_eigensystem_lift` a trivial wrapper of `PadicInt.lift`?  No — the
`∃!` packages existence with a real uniqueness proof, and the reduction corollary is an
element-level consequence.  Corner cases: `p` must be prime (`Fact p.Prime`); the GL(1) count needs
`0 < k` so that `NeZero (p^k)` holds.

Synthesis (PI): the "torsion ⇒ ℤ_ℓ" arrow of the conjecture is, at the level of eigenvalues, the
inverse-limit universal property; its uniqueness is what pins down the associated `ℓ`-adic system.
-/

open PadicInt

namespace TorsionLG

/-- **Assembly of a compatible torsion eigensystem into a unique `ℓ`-adic eigensystem.**
A compatible family of ring homomorphisms `f k : R →+* ℤ/p^k` (the Hecke eigensystem read modulo
`p^k`) lifts to a unique `F : R →+* ℤ_p` reducing to each `f k`. -/
theorem torsion_eigensystem_lift {R : Type*} [CommRing R] {p : ℕ} [Fact p.Prime]
    (f : (k : ℕ) → R →+* ZMod (p ^ k))
    (hf : ∀ k1 k2 (hk : k1 ≤ k2),
      (ZMod.castHom (pow_dvd_pow p hk) (ZMod (p ^ k1))).comp (f k2) = f k1) :
    ∃! F : R →+* ℤ_[p], ∀ k, (toZModPow k).comp F = f k := by
  refine ⟨PadicInt.lift hf, PadicInt.lift_spec hf, ?_⟩
  intro G hG
  ext r
  rw [← PadicInt.ext_of_toZModPow]
  intro n
  have h1 : (toZModPow n).comp G = f n := hG n
  have h2 : (toZModPow n).comp (PadicInt.lift hf) = f n := PadicInt.lift_spec hf n
  exact RingHom.congr_fun (h1.trans h2.symm) r

/-- The `ℓ`-adic eigenvalue `F r` assembled from a compatible torsion eigensystem reduces modulo
`p^k` to the prescribed torsion eigenvalue `f k r`. -/
theorem torsion_eigensystem_lift_reduces {R : Type*} [CommRing R] {p : ℕ} [Fact p.Prime]
    (f : (k : ℕ) → R →+* ZMod (p ^ k))
    (hf : ∀ k1 k2 (hk : k1 ≤ k2),
      (ZMod.castHom (pow_dvd_pow p hk) (ZMod (p ^ k1))).comp (f k2) = f k1)
    (r : R) (k : ℕ) :
    toZModPow k (PadicInt.lift hf r) = f k r :=
  RingHom.congr_fun (PadicInt.lift_spec hf k) r

/-- **GL(1) torsion eigensystem count at prime-power level.** A torsion Hecke eigensystem for
`GL(1)` of level `n` is a Dirichlet character mod `n`.  At the prime-power level `p^k` (the shape of
the `ℤ/ℓ^m` torsion coefficients), the number of such eigensystems is `p^{k-1}(p-1) = φ(p^k)`.
Uses the catalog result `HeckeFactorization.card_dirichlet_eq_totient`. -/
theorem card_torsion_eigensystem_primePow (p k : ℕ) (hp : p.Prime) (hk : 0 < k) :
    Nat.card (DirichletCharacter ℂ (p ^ k)) = p ^ (k - 1) * (p - 1) := by
  haveI : NeZero (p ^ k) := ⟨pow_ne_zero k hp.pos.ne'⟩
  rw [HeckeFactorization.card_dirichlet_eq_totient, Nat.totient_prime_pow hp hk]

end TorsionLG