# Summary of changes for run b6afa3e6-af63-48f7-a91a-2d4e2c078b1e
Added a new self-contained Lean file `Catalog/Cryptography/SquarefreeUnitsExponent.lean` formalizing and proving a reusable squarefree-units exponent criterion, designed as a core component for a later formalization of Korselt's criterion.

Main theorem (`Squarefree.forall_units_pow_eq_one_iff_forall_prime_sub_one_dvd`):
for `n : ℕ` with `Squarefree n`,
  `(∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1) ↔ (∀ p, p.Prime → p ∣ n → p - 1 ∣ n - 1)`.

Structure (each piece is a top-level, generally-stated, reusable lemma with a docstring, not buried in over-specialized local hypotheses):
- `prime_units_pow` — local prime step (backward): for prime `p`, `p - 1 ∣ k` implies every `u : (ZMod p)ˣ` has `u ^ k = 1`, via `#(ZMod p)ˣ = p - 1` and `pow_card_eq_one`.
- `prime_units_pow_iff` — full local prime criterion (both directions); the forward direction uses that `(ZMod p)ˣ` is cyclic of order `p - 1`.
- `forall_units_pow_eq_one_to_prime_sub_one_dvd` — the easy forward implication, isolated as a standalone lemma needing only `n ≠ 0`. It lifts a unit from `(ZMod p)ˣ` back to `(ZMod n)ˣ` using surjectivity of the reduction map (`ZMod.unitsMap_surjective`), so it is genuinely non-trivial rather than a restatement.
- `Squarefree.forall_prime_sub_one_dvd_to_forall_units_pow_eq_one` — the substantive reverse implication. It transports a unit `u : (ZMod n)ˣ` through the prime-divisor reductions `ZMod.unitsMap`, applies the local prime step in each factor, and recombines the per-prime vanishings via a CRT-style injectivity argument for squarefree moduli — not a tautological restatement.
- Supporting reusable lemmas: `Nat.dvd_of_squarefree_of_forall_prime_dvd` (primewise divisibility detection for squarefree `n`) and `ZMod.eq_zero_of_squarefree_of_forall_castHom_eq_zero` (residue-level CRT injectivity, then transferred to units, as the prompt permitted).

Edge cases are handled explicitly: `n = 0` is excluded by `Squarefree n` (`Squarefree.ne_zero`), and `n = 1` holds uniformly on both sides (trivial unit group; no prime divisors). These are documented in the module docstring.

Verification: the module builds within the project (`lake build Cryptography.SquarefreeUnitsExponent` succeeds), contains no `sorry`, and `#print axioms` on the main theorem reports only `propext`, `Classical.choice`, and `Quot.sound`. Comments throughout mark which lemmas are intended for reuse in a full Korselt's-criterion development.

Note: the overall project's full build is broken independently of this work (the lakefile globs reference a missing source file `Algebra/Jacobian/Defs.lean`); my module compiles cleanly on its own against the project's Mathlib.