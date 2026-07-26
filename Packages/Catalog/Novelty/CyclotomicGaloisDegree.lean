/-
# Degree and cyclic structure of cyclotomic Galois groups

This file continues the *explicit GL(1) class field theory* program begun in
`Catalog.Novelty.CyclotomicGL1Langlands`.  There the Artin reciprocity isomorphism
`CyclotomicGL1.frobeniusIso : (ZMod n)ˣ ≃* Gal(ℚ(ζₙ)/ℚ)` was constructed unconditionally
for every modulus `n`.  Here we harvest the arithmetic consequences of that isomorphism:

* `CyclotomicGaloisDegree.card_galois_eq_totient` — the degree `[ℚ(ζₙ) : ℚ]` computed at the
  level of the automorphism group: `#Gal(ℚ(ζₙ)/ℚ) = φ(n)`.
* `CyclotomicGaloisDegree.isCyclic_galois_prime` — for a prime `p`, `Gal(ℚ(ζₚ)/ℚ)` is
  **cyclic**, transported from the cyclicity of the unit group of the finite field `𝔽ₚ`.
* `CyclotomicGaloisDegree.card_galois_prime` — hence for a prime `p`,
  `#Gal(ℚ(ζₚ)/ℚ) = p - 1`.

These are the numerical fingerprints of the abelian (GL(1)) Langlands correspondence: the
reciprocity map does not merely match the two sides set-theoretically, it forces their orders
and cyclic type to agree with the arithmetic of `(ZMod n)ˣ`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The reciprocity isomorphism of the catalog file should pin down
the *entire* group-theoretic invariants of the cyclotomic Galois group, not just abelianness.
In particular the degree is Euler's totient and, in the prime-modulus case, the group is
cyclic — the sharpest possible structural statement.

Experiment (Experimenter): Transport `ZMod.card_units_eq_totient` and the finite-field
cyclicity instance `instIsCyclicUnitsOfFinite` across `CyclotomicGL1.frobeniusIso` using
`Nat.card_congr` and `MulEquiv.isCyclic`.  Both went through directly.

Analysis (Analyst): "True and structural." The order computation is unconditional (`NeZero n`
suffices); the cyclicity statement is genuinely restricted to prime moduli, because
`(ZMod n)ˣ` is *not* cyclic for e.g. `n = 8` (`{±1, ±3}` ≅ `C₂ × C₂`).  So the prime
hypothesis is load-bearing, not decorative.

Critique (Critic): The proofs are not `native_decide` shortcuts — they route through the
reciprocity `MulEquiv` and genuine Mathlib structure theory (`instIsCyclicUnitsOfFinite`,
`ZMod.card_units_eq_totient`).  Guarded the cyclic result to prime `p` to avoid the false
general claim.

Synthesis (PI): Degree `= φ(n)` and prime-case cyclicity are the arithmetic shadow of Artin
reciprocity; they are recorded here as reusable lemmas for downstream conductor/ramification
work.
-- !-- Lab Notes -- !--
-/
import Mathlib
import Catalog.Novelty.CyclotomicGL1Langlands

open Polynomial CyclotomicGL1

namespace CyclotomicGaloisDegree

variable (n : ℕ) [NeZero n]

/-- The absolute Galois automorphism group of the `n`-th cyclotomic field over `ℚ`. -/
abbrev Gal := CyclotomicField n ℚ ≃ₐ[ℚ] CyclotomicField n ℚ

/-- **Degree of the cyclotomic extension, at the level of automorphisms.**
`#Gal(ℚ(ζₙ)/ℚ) = φ(n)`.  Transported from `#(ZMod n)ˣ = φ(n)` across the reciprocity
isomorphism `frobeniusIso`. -/
theorem card_galois_eq_totient : Nat.card (Gal n) = Nat.totient n := by
  have e := (frobeniusIso n).toEquiv
  rw [← Nat.card_congr e, Nat.card_eq_fintype_card, ZMod.card_units_eq_totient]

/-- **Prime cyclotomic Galois groups are cyclic.**  For a prime `p`, `Gal(ℚ(ζₚ)/ℚ)` is cyclic,
transported across `frobeniusIso` from the cyclicity of `(ZMod p)ˣ = 𝔽ₚˣ`. -/
theorem isCyclic_galois_prime (p : ℕ) [Fact p.Prime] : IsCyclic (Gal p) := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  exact (MulEquiv.isCyclic (frobeniusIso p)).mp inferInstance

/-- **Order of a prime cyclotomic Galois group.**  For a prime `p`,
`#Gal(ℚ(ζₚ)/ℚ) = p - 1`. -/
theorem card_galois_prime (p : ℕ) [Fact p.Prime] : Nat.card (Gal p) = p - 1 := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  rw [card_galois_eq_totient, Nat.totient_prime (Fact.out)]

end CyclotomicGaloisDegree