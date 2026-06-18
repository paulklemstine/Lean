# Future Directions: Zero-Knowledge Proofs and Verifiable Computation in Lean

This cycle delivered two self-contained, fully proved Lean files (no `sorry` on any
result):

* `ThreeColoring.lean` — the GMW zero-knowledge proof system for graph 3-colorability,
  with perfect completeness (`permuted_isProper`), a 2-query PCP soundness gap
  (`pcp_soundness`, `pcp_detection_prob`), and the honest-verifier zero-knowledge
  simulator core (`hvzk_view_card_one`, `hvzk_view_witness_independent`,
  `hvzk_view_monochromatic_impossible`).
* `SnarkSoundness.lean` — the univariate Schwartz–Zippel soundness of a simplified
  zk-SNARK polynomial check (`agreement_card_le_degree`, `snark_soundness_prob`),
  perfect completeness (`snark_perfect_completeness`), and soundness amplification over
  `k` independent challenges (`snark_soundness_amplification`).

These extend the catalog's algebraic Σ-protocol layer (`ZeroKnowledge/Basic.lean`'s
Schnorr/`SigmaProtocol`/`commitment_binding`) and the tropical HVZK
(`TropicalZeroKnowledge.lean`) into the combinatorial and polynomial-IOP regimes. The
following directions each state a concrete, falsifiable Lean target.

## 1. Exact uniformity of the GMW view as a measure-preserving bijection

The current `hvzk_view_witness_independent` shows the verifier's view has a
witness-independent *count* (every distinct color pair has exactly one preimage
permutation). The natural strengthening is to package the map
`σ ↦ (σ (c u), σ (c v))` as an honest-to-goodness `Equiv` between `Equiv.Perm (Fin 3)`
and the subtype `{p : Fin 3 × Fin 3 // p.1 ≠ p.2}`, and prove the pushforward of the
uniform `PMF` on permutations equals the uniform `PMF` on distinct pairs — a literal
statement of perfect HVZK in Mathlib's probability layer.

The key insight is that on `Fin 3` a permutation is *determined and freely chosen* by
its action on any two distinct points, so the view map is a bijection onto distinct
pairs of *constant fiber size one* — exactly the condition for pushforward-uniformity.
Why now? Mathlib's `PMF`/`Pmf.map` and `uniformOfFintype` are mature enough to express
"the simulator's output distribution equals the real view distribution" as a provable
equality of `PMF`s, turning an informal cryptographic claim into a closed Lean theorem.

## 2. Generalize the simulator to k-colorings and `(k-2)!`-fiber counting

`hvzk_view_card_one` is special to `Fin 3` (fiber size exactly `1`). For a proper
`k`-coloring the GMW edge-opening reveals an ordered distinct pair, and the number of
color permutations realizing a fixed distinct view `(a,b)` is exactly `(k-2)!`. The
target is `hvzk_view_card_factorial : x ≠ y → a ≠ b →
(univ.filter (fun σ : Equiv.Perm (Fin k) => σ x = a ∧ σ y = b)).card = (k-2)!`.

The key insight is that fixing the images of two points reduces the symmetry group to
`Sym(k-2)` acting on the complementary colors, so the fiber is a coset of that subgroup
and the count is its order. Why now? The `Fin 3` brute-force `decide` proof does not
scale, forcing the genuinely structural orbit-stabilizer argument; Mathlib's
`Equiv.Perm` subgroup and `Fintype.card` of stabilizers make `(k-2)!` directly
reachable, and the result immediately yields HVZK for *every* NP language via the GMW
reduction rather than just the 3-color instance.

## 3. From the per-edge gap to a full PCP soundness-amplification theorem

`pcp_detection_prob` gives a single-edge rejection probability `≥ 1/|E|` for any
improper coloring. The frontier target is the amplified statement: for a coloring that
violates a `δ`-fraction of edges, querying `t` independent random edges rejects with
probability `≥ 1 - (1-δ)^t`, mirroring `snark_soundness_amplification` but on the
combinatorial side. Stated in Lean over the product `Fin t → (Fin n × Fin n)`.

The key insight is that independent repetitions turn an additive soundness gap into a
multiplicative one, so constant per-query soundness plus `O(log(1/ε))` queries yields
constant error — precisely the constant-query/constant-soundness profile of the PCP
theorem `NP ⊆ PCP(poly, O(1))`. Why now? The amplification lemma already proved on the
SNARK side (`snark_soundness_amplification` via `Fintype.piFinset` cardinality) supplies
a reusable template; transplanting it from field-challenges to edge-challenges is a
direct, falsifiable next step that bridges `Cryptography` and the `Computation` domain.

## 4. Multivariate Schwartz–Zippel for true QAP/PLONK soundness

`agreement_card_le_degree` is the univariate root bound. Real zk-SNARKs commit to
*multivariate* low-degree polynomials, so the target is the `MvPolynomial`
Schwartz–Zippel bound: a nonzero `p : MvPolynomial (Fin m) F` of total degree `d`
vanishes on at most a `d/|F|` fraction of `(Fin m → F)`, i.e.
`(univ.filter (fun v => MvPolynomial.eval v p = 0)).card * |F| ≤ d * |F|^m`.

The key insight is the standard induction on the number of variables: fixing all but
one variable yields a univariate polynomial whose leading coefficient is itself a
lower-degree multivariate polynomial, so the univariate bound composes with the
inductive hypothesis. Why now? Mathlib has `MvPolynomial.totalDegree` and the univariate
`card_roots'` base case is exactly what this cycle proved; the only missing piece is the
inductive `finSuccEquiv`/coefficient-extraction step, making this the highest-leverage
extension toward formally sound succinct arguments.

## 5. Fiat–Shamir: from interactive HVZK to non-interactive zero-knowledge

Both proved systems are interactive (or public-coin). The Fiat–Shamir transform replaces
the verifier's random challenge by a hash of the transcript, yielding a non-interactive
proof. The target is a Lean model of a random-oracle `H : Transcript → Challenge` and a
theorem that soundness error transfers: if the interactive system has per-challenge
soundness `≤ ε`, the Fiat–Shamir-collapsed system has soundness `≤ Q·ε` against a prover
making `Q` oracle queries.

The key insight is that against a random oracle the hashed challenge is, conditioned on
the commitment, uniform and independent — so the single-round soundness bound applies to
each of the prover's `Q` guesses and a union bound gives `Q·ε`. Why now? With the
single-round bounds `snark_soundness_prob` and `pcp_detection_prob` already formal, the
random-oracle/union-bound layer is the cleanest remaining gap between this catalog's
interactive proofs and deployed non-interactive zk-SNARKs, and Mathlib's `PMF` plus
finite union-bound lemmas make the `Q·ε` accounting fully formalizable.
