Create a complete, standalone Lean 4 file formalizing a precise combinatorial result about the additive cellular automaton Rule 90, with no truncated declarations, no mixed-in unrelated material, and no placeholders.

Target file: `Catalog/Cryptography/AdditiveCAComplexityThreshold.lean`

Mathematical objective:
Define the Rule 90 row complexity by
`complexity t = #{ k in Finset.range (t+1) : Nat.Odd (Nat.choose t k) }`.
Then prove the exact closed form
`complexity t = 2 ^ popcount t`,
where `popcount t` is the number of `1` bits in the binary expansion of `t`.
You may define `popcount` using whichever Mathlib-compatible notion is easiest to prove with (for example via binary digits sum, bit decomposition, or a finite-set-of-bits count).

Required final theorems:
1. A precise definition of `complexity`.
2. A precise definition of `popcount`.
3. `complexity_eq_two_pow_popcount : complexity t = 2 ^ popcount t`.
4. `complexity_pow_two : complexity (2^k) = 2` for `k ≥ 0` (or with the necessary small-case handling).
5. `complexity_mersenne : complexity (2^k - 1) = 2^k`.
6. A normalized density statement in a precise form that avoids analysis overhead if needed, for example:
   - `complexity (2^k) * (2^k + 1)⁻¹` is not needed;
   instead prove arithmetic equivalents such as
   `complexity (2^k) = 2` and `complexity (2^k - 1) = (2^k - 1) + 1`,
   and then state a simple corollary that these give infinitely many sparse and full rows, so no monotone threshold behavior can hold in any naive sense.

Proof strategy to follow:
- Keep the project narrowly focused on the exact counting theorem.
- Use Lucas parity if available in Mathlib, or prove the equivalent oddness criterion for binomial coefficients in base 2: `Nat.choose t k` is odd iff every binary 1-bit of `k` is also a 1-bit of `t`.
- Then count such `k` by showing they correspond exactly to subsets of the support of the 1-bits of `t`, yielding `2 ^ popcount t`.
- Derive the power-of-two and Mersenne special cases from the binary form of those integers.

Implementation requirements:
- The file must compile cleanly with complete theorem statements and proofs.
- Do not include any unrelated declarations or imports beyond what is needed.
- Prefer a direct combinatorial formalization over speculative cryptographic interpretation.
- If a theorem about limits or liminf becomes too heavy, replace it by explicit infinite families of exact values, since those already refute any simplistic monotone-threshold formulation.
- Add a module docstring explaining the CA interpretation, but ensure every informal sentence is backed by a precise theorem in the file.

Deliverable standard:
A single clean Lean file whose core contribution is the exact formula `complexity t = 2 ^ popcount t` and its two canonical corollaries at powers of two and Mersenne times. This is a formalization task, not an exploratory sketch.