import Mathlib

/-!
# Frobenius renormalization of the additive cellular automaton

This module was referenced by `Novelty.PadicFractalUncertainty` but was not present in the
repository.  It is reconstructed here with the one definition and the one theorem that file
uses.

The additive ("rule 90") cellular automaton over `𝔽_p` is the Laurent polynomial operator
`caOp p = T + T⁻¹` acting on configurations `𝔽_p^ℤ`.  In characteristic `p` the freshman's
dream gives the exact renormalization `caOp p ^ (p ^ k) = T^(p^k) + T^(-p^k)`: after `p ^ k`
steps the automaton consists of exactly two light rays travelling at speed one, which is the
self-similarity responsible for the Pascal-triangle fractals.
-/

open LaurentPolynomial

namespace AdditiveCA

/-- The additive (rule 90) cellular automaton operator `T + T⁻¹` over `𝔽_p`. -/
noncomputable def caOp (p : ℕ) [Fact p.Prime] : LaurentPolynomial (ZMod p) := T 1 + T (-1)

instance charP_laurentPolynomial (p : ℕ) [Fact p.Prime] :
    CharP (LaurentPolynomial (ZMod p)) p :=
  charP_of_injective_ringHom (LaurentPolynomial.C (R := ZMod p)).injective p

/-- **Exact renormalization.**  After `p ^ k` steps the additive cellular automaton over
`𝔽_p` is supported on exactly the two light rays `± p ^ k`. -/
theorem caOp_renorm (p k : ℕ) [Fact p.Prime] :
    caOp p ^ (p ^ k) = T ((p : ℤ) ^ k) + T (-((p : ℤ) ^ k)) := by
  rw [caOp, add_pow_char_pow, T_pow, T_pow]
  push_cast
  ring_nf

end AdditiveCA