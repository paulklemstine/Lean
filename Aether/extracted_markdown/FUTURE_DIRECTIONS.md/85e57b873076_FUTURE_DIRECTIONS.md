# Future Directions: Algebraic Foundations of Secure Multi-Party Computation

## Synthesis

This cycle introduced `Cryptography/GMW.lean`, the first secret-sharing / GMW-compiler
foundation in the catalog. It reduces three classically "cryptographic" guarantees to
pure algebra over an arbitrary abelian group `G` of secrets shared among `n` parties — with
**no probability theory** anywhere:

* **Reconstruction is definitional.** A tuple `shares : Fin n → G` is a sharing of `s`
  precisely when `∑ i, shares i = s` (`IsSharingOf`). The canonical randomized dealer
  `dealerShares` puts free randomness on `n` parties and the unique correcting value on the
  last party; `gmw_share_correct` proves it sums to `s` *for every choice of randomness*.
* **Correctness of linear evaluation is one homomorphism law.** Applying a group hom
  `f : G →+ H` locally to every share of `s` yields a sharing of `f s` (`gmw_linear_gate`),
  which is just `map_sum`. Coordinatewise addition is free (`gmw_add_gate`), and the two
  combine, by induction over a `List (G →+ G)`, into `gmw_circuit_correct`: local evaluation
  of an entire linear circuit shares the circuit's plaintext output. This is exactly GMW's
  slogan that "linear gates are free."
* **Perfect privacy is a view-preserving bijection.** For any two secrets `s, s'` and any
  honest coordinate `hp ∉ corrupted`, the map `v ↦ bump hp (s' - s) v` is an `Equiv` between
  the sharings of `s` and the sharings of `s'` that fixes every corrupted coordinate
  (`gmw_perfect_privacy`). The adversary's view is therefore information-theoretically
  independent of the secret. The honest-majority hypothesis `2 · |corrupted| < n` enters
  only to *construct* an honest coordinate (`honest_majority_exists_honest`), giving
  `gmw_perfect_privacy_honest_majority`.

These results dovetail with the catalog's compositional-security calculus in
`Cryptography/Core.lean` (`InvSystem.finProd_universal`, `InvSystem.security_finProd_min`,
`additive_finProd_eq`): there, an invariant on a finite product is governed by its
components; here, correctness is governed by a homomorphism and privacy by a bijection. They
also sit beside the LWE security stack in `Cryptography/Security.lean`
(`hybrid_telescope_bound`, `endToEnd_security_composition`) and the coding-theoretic
distance results in `Cryptography/MinimumDistance.lean`.

## Results Summary

| Theorem | Statement | Axioms |
|---|---|---|
| `gmw_share_correct` | canonical randomized dealer outputs a valid sharing | `propext, Classical.choice, Quot.sound` |
| `gmw_linear_gate` | local application of `f : G →+ H` shares `f s` | standard |
| `gmw_add_gate` | coordinatewise addition shares the sum | standard |
| `gmw_circuit_correct` | local evaluation of a linear circuit shares its output | standard |
| `gmw_perfect_privacy` | view-preserving bijection between sharings of `s`, `s'` | standard |
| `gmw_perfect_privacy_honest_majority` | privacy from `2 · |corrupted| < n` | standard |

All main results are `sorry`-free and use only the standard Lean axioms
(`propext, Classical.choice, Quot.sound`).

## Research Directions

### 1. Threshold (Shamir) sharing and the `t`-private reconstruction theorem
Generalize from `n`-out-of-`n` additive sharing to `t`-out-of-`n` Shamir sharing over a
finite field `F`, where shares are evaluations `p(αᵢ)` of a random degree-`<t` polynomial
with `p(0) = s`. Conjecture: any `t` distinct shares reconstruct `s` by Lagrange
interpolation, and any `t-1` shares admit a view-preserving bijection across all secrets
(perfect `t`-privacy). **The key insight is** that Shamir privacy is the *same* bijection
argument as `bump`, but parameterized by a free coefficient of the masking polynomial:
fixing `t-1` evaluation points leaves exactly one degree of freedom, which is the
simulator's randomness, so `bumpEquiv` generalizes verbatim with `Function.update` replaced
by "perturb the top coefficient." **Why now?** Mathlib's `Lagrange.interpolate` and
`Polynomial.lagrange` are mature, so the interpolation half is essentially free; the
bijection half reuses `bumpEquiv`'s template, making this the cheapest high-value
generalization on the table.

### 2. The multiplication gate and Beaver triples
Formalize the one place GMW is *not* free: the AND / multiplication gate over a commutative
ring `R`. Given a Beaver triple `(a, b, c)` with `c = a · b` pre-shared, parties open
`d = x - a` and `e = y - b` and locally compute the recombination `c + e·a + d·b + d·e`.
Conjecture: `IsSharingOf` of `x` and `y` plus `c = a·b` implies the recombination is a
sharing of `x · y`. **The key insight is** that the multiplication gate becomes
*linear-after-opening*: once `d, e` are public constants, the recombination is an affine
function of existing shares, so it follows from `gmw_linear_gate`/`gmw_add_gate` plus the
ring identity `x·y = c + e·a + d·b + d·e` when `c = a·b`, `d = x-a`, `e = y-b`. **Why now?**
With the linear-gate calculus complete, the Beaver identity is the unique missing algebraic
lemma that upgrades "linear circuits" to "all arithmetic circuits," i.e. completeness of MPC.

### 3. Universal composition as a categorical product (bridge to `Core.lean`)
Model an MPC functionality as an `InvSystem` (from `Core.lean`) whose invariant measures the
corrupted parties' residual information, and show that running protocols in parallel realizes
the `finProd` of `Core.lean`, so that `security_finProd_min` yields a UC-style composition
theorem: the security of the composed protocol is at least the minimum component security.
**The key insight is** that GMW's "secure composition" and `Core.lean`'s "finite product of
invariant systems" are the *same universal property* — `finProd_universal` already proves the
mediating morphism is unique, which is exactly the simulator-uniqueness UC demands. **Why
now?** The product universal property is already proven in the catalog; only the encoding
"protocol = `InvSystem`" is missing, turning a deep crypto theorem into a definitional bridge.

### 4. Robust reconstruction against malicious shares (error-correcting secret sharing)
Extend reconstruction to tolerate corrupted shares: with Reed–Solomon / Shamir sharing and
error budget `e` satisfying `2e + 1 ≤ t`, reconstruction via error correction recovers `s`
even if up to `e` shares are adversarially altered. Conjecture: the honest-majority bound
`2 · |corrupted| < n` proved here is *exactly* the decoding radius that makes robust
reconstruction unique. **The key insight is** that `honest_majority_exists_honest` is the
combinatorial twin of the Singleton/decoding bound — "honest majority" and "uniquely
decodable" are the same `2k < n` statement viewed from two domains. **Why now?** The catalog
already contains `Cryptography/MinimumDistance.lean`, so the decoding-radius machinery is
partly in place and ready to be fused with the sharing layer built this cycle.

### 5. Privacy against any *unqualified* coalition: an access-structure theorem
Replace the threshold `2·|corrupted| < n` by an arbitrary monotone access structure `Γ`
(a downward-closed family of "non-qualified" subsets) and prove that `gmw_perfect_privacy`
holds for every `C ∉ Γ` iff `Γ` admits a complementary honest coordinate for each such `C`.
Conjecture: additive sharing realizes precisely the `(n-1)`-private (all-but-one) access
structure, and the bijection `bump` characterizes the boundary exactly. **The key insight is**
that the entire content of "which coalitions learn nothing" is captured by the predicate
`∃ hp, hp ∉ C`, so privacy becomes a statement about the *combinatorics of the access
structure* rather than about probabilities. **Why now?** The proof of `gmw_perfect_privacy`
is already parameterized by an arbitrary `corrupted : Finset (Fin n)` and a single honest
witness, so the general access-structure theorem is a direct quantifier rearrangement over
the lemma already proved.
