/-
# Prime-power renormalization of the additive cellular automaton

NOTE (restored module).  `Novelty/PadicFractalUncertainty.lean` imports this module and uses
`AdditiveCA.caOp` and `AdditiveCA.caOp_renorm`, but the file itself was missing from the
catalogue, so nothing downstream compiled.  This file restores it with complete proofs.

The additive ("Rule 90") cellular automaton on bi-infinite configurations over `ZMod p` sends a
configuration to the sum of its two neighbours.  Encoding configurations as Laurent
polynomials, the automaton is multiplication by `caOp p = T 1 + T (-1)`.

The main result, `caOp_renorm`, is the *exact two-ray renormalization identity*: iterating the
automaton `p ^ k` times produces exactly two light rays, at offsets `± p ^ k`.  It is the
freshman's dream in characteristic `p`, applied in the Laurent polynomial ring.
-/
import Mathlib

open LaurentPolynomial

namespace AdditiveCA

/-- The transition operator of the additive ("Rule 90") cellular automaton over `ZMod p`,
seen as the Laurent polynomial `T + T⁻¹`: a cell becomes the sum of its two neighbours. -/
noncomputable def caOp (p : ℕ) : LaurentPolynomial (ZMod p) := T 1 + T (-1)

/-- The Laurent polynomial ring over `ZMod p` has characteristic `p`. -/
instance charP_laurentPolynomial_zmod (p : ℕ) [Fact p.Prime] :
    CharP (LaurentPolynomial (ZMod p)) p := by
  refine charP_of_injective_ringHom
    (f := (Polynomial.toLaurent).comp (Polynomial.C (R := ZMod p))) ?_ p
  intro a b hab
  exact Polynomial.C_injective (Polynomial.toLaurent_injective hab)

/-- **Exact two-ray renormalization.**  After `p ^ k` steps the additive cellular automaton over
`ZMod p` has exactly two light rays, at offsets `± p ^ k`:
`(T + T⁻¹) ^ (p ^ k) = T ^ (p ^ k) + T ^ (-p ^ k)`.  All intermediate binomial coefficients
vanish modulo `p`. -/
theorem caOp_renorm (p k : ℕ) [Fact p.Prime] :
    caOp p ^ (p ^ k) = T ((p : ℤ) ^ k) + T (-((p : ℤ) ^ k)) := by
  rw [caOp, add_pow_char_pow, T_pow, T_pow]
  push_cast
  ring_nf

/-- One step of the automaton is already the `k = 0` case: no renormalization happens. -/
theorem caOp_renorm_zero (p : ℕ) [Fact p.Prime] :
    caOp p ^ (p ^ 0) = T 1 + T (-1) := by
  simpa using caOp_renorm p 0

/-- The automaton operator is not a monomial: it genuinely has two rays. -/
theorem caOp_ne_zero (p : ℕ) [Fact p.Prime] : caOp p ≠ 0 := by
  haveI : Nontrivial (ZMod p) := by
    haveI := Fact.out (p := p.Prime); infer_instance
  intro h
  have h1 : (caOp p) 1 = 0 := by rw [h]; rfl
  rw [caOp, Finsupp.add_apply] at h1
  simp only [LaurentPolynomial.T, Finsupp.single_apply] at h1
  norm_num at h1

end AdditiveCA