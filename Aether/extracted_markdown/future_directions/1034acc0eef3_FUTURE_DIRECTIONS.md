# Future Directions — Pairing-Based Cryptography (Weil Pairing & BLS)

## Synthesis

This cycle tested the hypothesis that the *protocol layer* of pairing-based
cryptography — BLS signatures, signature aggregation, and key-binding — depends
only on the **algebraic interface** of a pairing (biadditivity into a
multiplicative group), and not at all on the heavy analytic construction of the
Weil or Tate pairing on an elliptic curve. The hypothesis survived: a structure
`Pairing G T` carrying exactly two axioms (`add_left`, `add_right`) was enough to
derive the entire ladder of scalar laws (`e (n•p) q = (e p q)^n` over `ℕ` and
`ℤ`, full bilinearity `e (a•p) (b•q) = (e p q)^(a*b)`), the sum→product law, BLS
completeness, and aggregate completeness. Nondegeneracy — a *single* extra
hypothesis, not needed anywhere for completeness — was isolated as the precise
ingredient that makes the pairing *bind*: `pairing_left_injective` shows a
nondegenerate pairing separates points, which is the algebraic reason a verifier
cannot be fooled by a substituted key.

The key structural insight is that **aggregation is the sum→product law in
disguise**: `pairing_sum_left` collapses a `Finset`-indexed sum of group elements
into a single pairing evaluation on the left, and the *same* `Finset.induction`
skeleton (`empty ↦ map_one_left`, `insert ↦ add_left`) that proves it will prove
every multi-signature / threshold variant. The one genuine subtlety was that the
target group `T` must be a *group*, not merely a monoid: `e 0 q = e 0 q · e 0 q`
forces `e 0 q = 1` only via cancellation, mirroring the fact that real pairing
targets are groups of roots of unity.

What this cycle did **not** attempt: a game-based proof of existential
unforgeability under CDH. That requires a probabilistic/adversary model
(oracles, negligible functions, reductions) absent from the present purely
algebraic development, and is the natural next frontier (Direction 1 below).
The catalog already contains `Cryptography.ScalarMul` (verified `n • P`) and
`Cryptography.ShorECDSA`; the present file is the missing bridge that turns scalar
multiplication into a *publicly checkable, aggregatable* verification relation.

## Results Summary

- `Pairing.map_one_left` / `Pairing.map_one_right`: proved — the pairing of the
  identity is the unit, the first consequence of biadditivity in a group target.
- `Pairing.map_neg_left`: proved — `e (-p) q = (e p q)⁻¹`, contravariance under
  negation, the group-level upgrade of `map_one_left`.
- `Pairing.pairing_nsmul_left` / `Pairing.pairing_nsmul_right`: proved — scalar
  multiplication in either slot becomes exponentiation in the target.
- `Pairing.pairing_zsmul_left`: proved — the `ℤ`-graded scalar law, valid when the
  source is a full group (the elliptic-curve point group).
- `Pairing.pairing_bilinear_nsmul`: proved — joint bilinearity
  `e (a•p) (b•q) = (e p q)^(a·b)`, the equation behind the Diffie–Hellman tuple
  check.
- `Pairing.pairing_sum_left`: proved — the sum→product law; the algebraic engine
  of short aggregate signatures.
- `Pairing.bls_verify_correct`: proved — completeness of single BLS verification.
- `Pairing.bls_aggregate_correct`: proved — a single aggregate group element
  verifies against the product of per-signer pairings (short aggregation).
- `Pairing.pairing_left_injective`: proved — nondegeneracy ⇒ point separation,
  the binding/soundness property of pairing-based verification.

## Research Directions

### Direction 1: Game-based existential unforgeability under co-CDH
**Hypothesis**: In a model with a random oracle `H : Msg → G` and a computational
co-Diffie–Hellman adversary, BLS is existentially unforgeable: any forger making
`q` hash/sign queries can be transformed into a co-CDH solver with the same
success probability up to a `1/q`-style loss.
**Test**: Introduce a `Pairing`-based `SignatureScheme` record plus an `Adversary`
type returning a forgery; formalize the reduction that programs the random oracle
to embed a co-CDH challenge and prove a probability inequality
`Adv_forge ≤ q · Adv_coCDH` (or the tight `Adv_forge ≤ Adv_coCDH` in the
algebraic group model).
**Why now**: The completeness and binding lemmas (`bls_verify_correct`,
`pairing_left_injective`) already pin down the exact equation a forgery must
satisfy; what remains is purely the probabilistic wrapper.
**If true**: First end-to-end machine-checked BLS security proof built on a
reusable abstract-pairing interface.
**If false**: The failure would localize precisely which oracle-programming step
leaks, sharpening the known tightness gap between the ROM and AGM proofs.

### Direction 2: Rogue-key attacks and the necessity of proof-of-possession
**Hypothesis**: Naive aggregate BLS (summing public keys) is *insecure*: there is
an explicit "rogue" public key `X* = Y - ∑_{i<n} X_i` letting one signer forge an
aggregate over honest signers, and this attack vanishes under a
proof-of-possession or message-distinct (`Hm i ≠ Hm j`) restriction.
**Test**: Construct the rogue key as an explicit group element and *prove* the
aggregate verification equation holds for a message never signed by the honest
parties — a disproof of "plain aggregation is binding". Then prove the patched
variant binds via `pairing_left_injective`.
**Why now**: `bls_aggregate_correct` exposes the aggregate as a single linear
combination in `G`; linearity is exactly what the rogue-key attack exploits, so
the counterexample is constructible inside the current algebraic model.
**If true (attack exists)**: A formally verified counterexample documenting why
deployed BLS (e.g. Ethereum) mandates proof-of-possession.
**If false**: Plain aggregation would be safe, contradicting folklore — a
surprising and publishable correction.

### Direction 3: Nondegeneracy from a generator, and the embedding degree
**Hypothesis**: If `G` is cyclic of prime order `r` generated by `g` and
`e g g ≠ 1`, then the pairing is *automatically* nondegenerate, so the
hypothesis of `pairing_left_injective` reduces to a single non-triviality check.
**Test**: Prove `(∀ q, e a q = 1) ↔ a = 0` from `[IsCyclic G]`, `Nat.Prime r`,
`orderOf g = r`, and `e g g ≠ 1`, using `pairing_zsmul_left` to reduce any `e a q`
to a power of `e g g`.
**Why now**: `pairing_zsmul_left` already expresses every pairing value as a power
of `e g g`; cyclicity turns the universally-quantified nondegeneracy hypothesis
into one inequality.
**If true**: Nondegeneracy becomes a checkable side-condition, making the binding
theorem self-contained from generator data.
**If false**: It would reveal a pairing where `e g g = 1` yet `e` is nontrivial,
exposing a gap between the symmetric (Type-1) and asymmetric (Type-3) pairing
settings — motivating splitting `Pairing` into two source groups `G₁, G₂`.

### Direction 4: Asymmetric (Type-3) pairings and the SXDH assumption
**Hypothesis**: Generalizing `Pairing G T` to `Pairing G₁ G₂ T` with independent
source groups admits *no* efficiently computable isomorphism `G₁ → G₂`, which is
what makes the Symmetric eXternal Diffie–Hellman (SXDH) assumption — DDH hard in
both `G₁` and `G₂` — plausible, unlike the symmetric case where the pairing
itself breaks DDH.
**Test**: Define `Pairing₂ G₁ G₂ T`, re-derive all bilinearity lemmas, and prove
that in the *symmetric* specialization `G₁ = G₂` the pairing yields a DDH
distinguisher (given `(g, a•g, b•g, c•g)` decide `c = ab` via
`e (a•g) (b•g) = e g (c•g)`), formalizing why symmetric pairings cannot support
SXDH.
**Why now**: `pairing_bilinear_nsmul` is *exactly* the DDH-distinguishing
equation; promoting it to a `Decidable`-style statement is a short step.
**If true**: A clean formal account of why modern deployments use Type-3 pairings.
**If false**: An unexpected obstruction in the abstract model worth diagnosing.

### Direction 5: Concrete instantiation by the Weil pairing on `E[r]`
**Hypothesis**: Mathlib's elliptic-curve and `n`-torsion machinery, together with
the catalog's `Cryptography.ScalarMul`, can produce an *actual* term of type
`Pairing E[r] μ_r` whose biadditivity axioms are theorems, discharging the
abstraction used here.
**Test**: Build the Weil pairing on the `r`-torsion `E[r]` (via Miller's
algorithm / the function-field definition) and supply `add_left`, `add_right`
as proofs, then specialize `bls_verify_correct` to it.
**Why now**: This file fixes the *target interface* precisely, so the analytic
construction now has a concrete, minimal specification to hit — no guessing which
properties downstream code needs.
**If true**: Closes the loop from the abstract protocol guarantees to a genuine
elliptic-curve pairing, fully grounding BLS in Mathlib.
**If false**: The specific missing Mathlib lemma (e.g. nondegeneracy of the Weil
pairing, or the Weil reciprocity step) becomes a sharply-scoped target for a
dedicated cycle.
