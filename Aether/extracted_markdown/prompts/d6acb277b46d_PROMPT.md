Formalize a complete Lean 4 file developing a minimal classical integrated-information surrogate for finite bit chains, but keep the scope deliberately narrow so every declaration is fully implemented and checked.

Target file: `Catalog/Computation/IIT/ClassicalBitChain.lean`

Mathematical setup:
- Fix `n : ℕ` and represent an `n`-bit configuration as `Fin n → Bool`.
- A distribution is `p : (Fin n → Bool) → ℝ`.
- Define `IsProbDist p` to mean:
  1. `0 ≤ p x` for all `x`
  2. `∑ x, p x = 1`

Cuts and recombination:
- For `k ≤ n`, define a recombination map from `(Fin k → Bool) × (Fin (n-k) → Bool)` to `(Fin n → Bool)` using `Fin.append` / `Fin.appendEquiv` or a comparable existing equivalence from Mathlib.
- Package the equivalence as `cutEquiv` if convenient.
- Prove a finite-sum decomposition theorem stating that summing `p` over all `Fin n → Bool` equals summing over all pairs of left/right blocks via recombination.

Marginals:
- Define `leftMarginal p hk : (Fin k → Bool) → ℝ` by summing over right blocks.
- Define `rightMarginal p hk : (Fin (n-k) → Bool) → ℝ` by summing over left blocks.
- Prove that if `p` is an `IsProbDist`, then each marginal is nonnegative and has total mass `1`.

Independence and product distributions:
- Define `CutIndependent p hk` to mean:
  `p (recombine hk (a,b)) = leftMarginal p hk a * rightMarginal p hk b` for all `a b`.
- Define a constructor `productDist pl pr` on paired blocks, or directly on `Fin n → Bool` through recombination, from left/right distributions.
- Prove that if `pl` and `pr` are valid probability distributions, then the induced product distribution on the full bit chain is a valid probability distribution.
- Prove that this product distribution is cut-independent.

Concrete 2-bit example:
- Define the uniform distribution on `Fin 2 → Bool` assigning probability `1/4` to each state.
- Prove it is a probability distribution.
- For the cut `k = 1`, compute or prove its left and right marginals are uniform on one bit.
- Prove the cut is independent.

Optional surrogate score, only if it can be completed cleanly:
- Define `cutScore p hk : ℝ := if CutIndependent p hk then 0 else 1`.
- Define `PhiMin p` for `n = 2` only, or for general `n` only if the finite search over cuts is implemented cleanly without introducing unfinished obligations.
- Prove for the 2-bit uniform distribution that the minimum score is `0`.

Important constraints:
- Do not include theorem statements without bodies.
- Do not attempt broad theorems like `cutIndependent_of_factorsAcross` unless you can provide the full proof in this file.
- Prefer explicit, robust proofs over abstraction.
- Use only Mathlib material that is already stable and easy to reference.
- The final file must compile with no `sorry` and no omitted definitions.

Deliverable expectations:
- A short but complete file is better than a broader incomplete one.
- Include docstrings/comments explaining the definitions and theorems.
- Ensure the concrete 2-bit example is fully formalized and proved end-to-end.