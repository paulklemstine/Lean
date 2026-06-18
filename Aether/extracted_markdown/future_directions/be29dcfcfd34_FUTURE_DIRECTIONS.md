# Future Directions: Algebraic Foundations of Secure Multi-Party Computation

## Synthesis

This cycle introduced `Cryptography/GMW.lean`, the first secret-sharing / GMW-compiler
foundation in the catalog. It reduces three classically "cryptographic" guarantees to
pure algebra over an arbitrary abelian group `G` of secrets shared among `n` parties:

* **Reconstruction** is the *definition* of a sharing (`IsSharingOf shares s := ∑ shares = s`),
  with a concrete dealer (`dealerShares`, `gmw_share_correct`).
* **Correctness of linear evaluation** is the single homomorphism law
  `gmw_linear_gate : (f : G →+ H) → IsSharingOf shares s → IsSharingOf (f ∘ shares) (f s)`,
  lifted to whole circuits by `gmw_circuit_correct`. This is exactly GMW's
  "linear gates are free" *and* its universal composition property for linear protocols.
* **Perfect privacy** is a *view-preserving bijection*
  (`gmw_perfect_privacy` / `gmw_perfect_privacy_honest_majority`): for any two secrets there
  is an `Equiv` on the share space that fixes every corrupted coordinate, so the corrupted
  view is information-theoretically independent of the secret. No probability theory is used.

These results dovetail with the catalog's compositional-security calculus in
`Cryptography/Core.lean` (`InvSystem.finProd_universal`, `InvSystem.security_finProd_min`,
`additive_finProd_eq`): there, an invariant on a finite product is governed by its
components; here, correctness is governed by a homomorphism and privacy by a bijection.
They also sit naturally beside the LWE security stack in `Cryptography/Security.lean`
(`hybrid_telescope_bound`, `endToEnd_security_composition`), which already speaks the
language of reductions and advantage composition.

## Results Summary

| Theorem | Statement | Axioms |
|---|---|---|
| `gmw_share_correct` | canonical dealer outputs a valid sharing | `propext, Classical.choice, Quot.sound` |
| `gmw_linear_gate` | local application of `f : G →+ H` shares `f s` | standard |
| `gmw_circuit_correct` | local circuit evaluation shares the circuit output | standard |
| `gmw_perfect_privacy` | view-preserving bijection between sharings of `s`, `s'` | standard |
| `gmw_perfect_privacy_honest_majority` | privacy from `2·|corrupted| < n` | standard |

All main results are `sorry`-free and use only the standard Lean axioms.

## Research Directions

### 1. Threshold (Shamir) sharing and the `t`-private reconstruction theorem
Generalize from `n`-out-of-`n` additive sharing to `t`-out-of-`n` Shamir sharing over a
finite field `F`, where shares are evaluations `p(αᵢ)` of a random degree-`<t` polynomial
with `p(0) = s`. Conjecture: any `t` shares reconstruct `s` by Lagrange interpolation, and
any `t-1` shares admit a view-preserving bijection across all secrets (perfect `t`-privacy).
**The key insight is** that Shamir privacy is the *same* bijection argument as `bump`, but
parameterized by a free coefficient of the masking polynomial: fixing `t-1` evaluation
points leaves exactly one degree of freedom, which is the simulator's randomness. **Why now?**
Mathlib's `Polynomial.lagrange` and `Lagrange.interpolate` already exist and are mature,
so the interpolation half is essentially free; the bijection half reuses `bumpEquiv`'s
template verbatim, making this the cheapest high-value generalization on the table.

### 2. The multiplication gate and Beaver triples (the honest-but-curious bottleneck)
Formalize the one place GMW is *not* free: the AND/multiplication gate. Using a Beaver
triple `(a, b, c)` with `c = a·b` shared in advance, parties open `d = x - a` and
`e = y - b` and locally compute `c + e·a + d·b + d·e` to obtain a sharing of `x·y`.
Conjecture: this local recombination is a valid sharing of `x·y` whenever `c = a·b`.
**The key insight is** that the multiplication gate becomes *linear-after-opening*: once the
two masked values `d, e` are public constants, the recombination is an affine function of
the existing shares, so it is provable by the very `gmw_linear_gate` / `gmw_add_gate`
machinery already in hand. **Why now?** With the linear-gate calculus complete, the Beaver
identity is the unique missing algebraic lemma that upgrades "linear circuits" to "all
arithmetic circuits," i.e. completeness of MPC for any polynomial-time function.

### 3. Malicious security adds only polynomial overhead, made precise as a counting bound
State the GMW "compile semi-honest → malicious" overhead as a concrete polynomial in the
catalog's advantage language. Conjecture: if each gate's commit-and-prove wrapper multiplies
work by a fixed constant `κ` and a circuit has `g` gates, the malicious protocol's cost is
`≤ κ·g·(semi-honest cost)`, a polynomial blow-up, with soundness error bounded by a
telescoped sum à la `hybrid_telescope_bound`. **The key insight is** that "polynomial
overhead" is a *finite-sum/`Finset.sum` monotonicity statement*, not an asymptotic one, so
it is fully formalizable with the existing `Cryptography/Security.lean` hybrid-sum lemmas.
**Why now?** `hybrid_telescope_bound` and `endToEnd_security_composition` already give the
exact summation skeleton; wiring the per-gate constant through them is a direct extension.

### 4. Universal composition as a categorical product (bridge to `Core.lean`)
Model an MPC functionality as an `InvSystem` whose invariant is the corrupted parties'
residual information, and show that running protocols in parallel is the `finProd` of
`Core.lean`, so that `security_finProd_min` yields a UC-style composition theorem:
the security of the composed protocol is at least the minimum component security.
**The key insight is** that GMW's "secure composition" and `Core.lean`'s "finite product
of invariant systems" are the *same universal property* — `finProd_universal` already
proves the mediating morphism is unique, which is precisely the simulator-uniqueness that
UC demands. **Why now?** The product universal property is already proven in the catalog;
only the encoding of "protocol = `InvSystem`" is missing, turning a deep crypto theorem into
a definitional bridge.

### 5. Robust reconstruction against malicious shares (error-correcting secret sharing)
Extend reconstruction to tolerate corrupted shares: with Reed–Solomon / Shamir sharing and
`2e + 1 ≤ t`, reconstruction via error correction recovers `s` even if up to `e` shares are
adversarially altered. Conjecture: the honest-majority bound `2·|corrupted| < n` is exactly
the decoding radius that makes robust reconstruction unique. **The key insight is** that the
honest-majority inequality already proved here (`honest_majority_exists_honest`) is the
*combinatorial twin* of the Singleton/decoding bound: "honest majority" and "uniquely
decodable" are the same `2k < n` statement viewed from two domains. **Why now?** The catalog
contains `Cryptography/MinimumDistance.lean` (coding-theoretic minimum distance), so the
decoding-radius machinery is partly in place and ready to be fused with the sharing layer.
