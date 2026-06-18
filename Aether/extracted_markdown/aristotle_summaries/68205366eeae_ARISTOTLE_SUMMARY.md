# Summary of changes for run dbd9a386-a356-4d21-a580-3d571bb58fc3
Created `Catalog/Cryptography/OTPPerfectSecrecy.lean` formalizing perfect secrecy of the one-time pad over a finite group. The file contains a module docstring and EXACTLY the three requested theorems, each with a complete proof (zero sorries), and nothing from any unrelated domain:

1. `otp_unique_key` — for any message `m` and ciphertext `c` in a finite group `G`, there is a unique key `k` with `k * m = c` (namely `k = c * m⁻¹`).
2. `otp_key_cardinality` — exactly one key in `G` satisfies `k * m = c` (the filtered `Finset` has cardinality 1).
3. `otp_perfect_secrecy` — modeling the key as uniform over `G` (`PMF.uniformOfFintype`) and independent of the message, with ciphertext `C = K * M`, the conditional probability `P(M = m | C = c) = joint(m,c) / P(C = c)` equals the prior `P(M = m)`. The proof follows the Bayesian computation: the joint probability of `(x,c)` is `P(M=x)/|G|`, so the ciphertext marginal is `1/|G|`, and the ratio collapses to `messageDist m`.

Verification: the file compiles cleanly with `lake env lean`, contains no `sorry`, and `#print axioms` shows only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

Notes: the requested import `Mathlib.Algebra.Group.Fintype` does not exist in this Mathlib version, so it was omitted (the needed finite-group instances come from the other imports), and `Mathlib.Probability.Distributions.Uniform` was added to provide the uniform PMF; this is documented in the module docstring. The project's default `lake build` target was already failing before any change (a pre-existing library `srcDir` configuration issue affecting all libraries), independent of this file.