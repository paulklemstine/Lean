# Future Directions: Post-Quantum Lattice Cryptography

## Synthesis

This cycle attacked the LWE concept from the two ends that catalog work had left
abstract: the *protocol* end (forward secrecy of ephemeral key exchange) and the
*numerical* end (concrete 128-bit parameter certificates), and tied both back to
the existing algebraic core in `Cryptography.LWE.SearchDecisionCore`.

The unifying thread is small but sharp: **a bijection of `ZMod q` pushes the
uniform distribution to the uniform distribution.** SearchDecisionCore uses the
*general affine* form (`ZMod.affine_bijective`, `ZMod.sum_affine_eq`) to make
"wrong guesses" look uniform in the search-to-decision hybrid. `ForwardSecrecy`
uses its *additive* special case (translation by an ephemeral mask) to show that
each session key is uniform *independently of the long-term secret* — which is
forward secrecy, stated as the invariance of a preimage count under changing the
long-term key. `ConcreteSecurity` then takes the abstract `α·q ≥ 2·√n` floor
(`modulus_noise_tradeoff` in the catalog) and discharges it with a real
NewHope/Kyber-scale witness `(n,q,α) = (512, 12289, 1/256)`, then certifies that
the same parameters beat both classical (`0.292·β`) and quantum (`0.265·β`)
Core-SVP attacks at the 128-bit level.

## Results Summary

`ForwardSecrecy.lean` (5 theorems, standard axioms only):
- `masking_card_one` — one-time-pad masking over `ZMod q` (singleton preimage).
- `session_key_uniform` — the session key is uniform.
- `forward_secrecy_independence` — session-key distribution is independent of the
  long-term secret (forward secrecy).
- `session_independence` / `session_independence_factors` — distinct sessions are
  mutually independent; joint count factorizes.

`ConcreteSecurity.lean` (5 theorems, standard axioms only):
- `bkzCost_monotone` — Core-SVP cost is monotone in block size.
- `bkzCost_classical_128bit` — `β ≥ 439 ⇒ cost ≥ 2^128` (classical).
- `bkzCost_quantum_128bit` — `β ≥ 484 ⇒ cost ≥ 2^128` (quantum/Grover).
- `regev_reduction_feasible_512` — `(512, 12289, 1/256)` satisfies `2√n ≤ α·q`.
- `secure_parameter_set_512` — full certificate: GapSVP-backed + 128-bit classical
  + 128-bit quantum, in one statement.

## Bold, Falsifiable Research Directions

### 1. A formal probability-mass theory of forward secrecy via PMF/uniform measure

We measured distributions by preimage *counts*. The bold step is to replace
counting with Mathlib's `PMF` and prove `forward_secrecy_independence` as an
honest equality of probability measures: `PMF.map (fun m => shared + m) uniform =
uniform` for every `shared`, hence the conditional law of the session key given
the long-term key is constant.

- **Conjecture (falsifiable):** For finite abelian `G` and uniform `μ` on `G`,
  the pushforward `PMF.map (· + g) (PMF.uniformOfFintype G)` equals
  `PMF.uniformOfFintype G` for *every* `g`, and this is *the* characterization of
  groups admitting perfect one-time-pad forward secrecy — it fails exactly when
  the masking operation is not a bijection (non-group magmas).
- **The key insight is** that forward secrecy is not a cryptographic accident but
  a purely measure-theoretic invariance: it is the statement that translation is
  measure-preserving, so it should hold verbatim for *any* finite group used as
  the key space, and provably fail for non-invertible "masks."
- **Why now?** Mathlib's `PMF`, `PMF.map`, and `PMF.uniformOfFintype` are now
  mature, and our count-based proofs already isolate the singleton-preimage fact
  that is the only nontrivial input; lifting from counts to `PMF` is mechanical
  but upgrades the result from a combinatorial proxy to a genuine distributional
  statement.

### 2. Quantitative IND-CPA: a fully bundled advantage inequality for Regev

The catalog has correctness (`regev_rounding_bit1`) and an *abstract* reduction
(`dualRegev_cpa_security_of_lwe` takes the reduction as a hypothesis). The bold
step is to *construct* the reduction: define explicit `Encrypt`/`Decrypt` maps
and an explicit distinguisher transformation, and prove
`Adv_CPA(A) ≤ Adv_LWE(B) + δ_corr` with `B` and `δ_corr` exhibited, not assumed.

- **Conjecture (falsifiable):** For Regev encryption with our certified
  parameters, the explicit hybrid (replace the public matrix, then the
  ciphertext, by uniform) yields `δ_corr ≤ 2^-128` and a *two-step* hybrid
  suffices — no `n`-fold coordinate loss is needed for IND-CPA (the `n`-loss is
  particular to search-to-decision, not to CPA).
- **The key insight is** that IND-CPA only needs *one* application of decisional
  LWE to make the whole ciphertext uniform, so the advantage bound is tight with
  constant (not `n`) loss — sharply distinguishing CPA security from the
  search-to-decision reduction that the catalog already formalizes.
- **Why now?** With forward secrecy's masking lemma in hand, the "ciphertext
  becomes uniform" step is already proved in additive form; the remaining work is
  assembling the two hybrids, for which `hybrid_telescope_bound` (catalog) is the
  exact tool.

### 3. The classical/quantum security gap as a provable constant ratio

We proved `β ≥ 439` (classical) and `β ≥ 484` (quantum) thresholds separately.
The bold conjecture unifies them into a *law*.

- **Conjecture (falsifiable):** For every security level `λ`, the ratio of the
  minimal quantum-secure block size to the minimal classical-secure block size is
  *exactly* `0.292 / 0.265` (≈ 1.102), independent of `λ`; i.e.
  `β_quantum(λ) / β_classical(λ) = c_classical / c_quantum`. This predicts a
  constant ~10.2% block-size inflation for quantum resistance at *all* levels,
  and is falsified if any standardized parameter set deviates from this ratio
  beyond rounding.
- **The key insight is** that within the Core-SVP model the quantum penalty is a
  pure rescaling of the exponent, so it must appear as a *level-independent*
  multiplicative constant on the block size — turning a folklore "~10% more"
  heuristic into an exact, checkable identity.
- **Why now?** Our `bkzCost`/`bkzCost_*_128bit` lemmas already isolate the single
  inequality `λ ≤ c·β`; generalizing `128` to a variable `λ` and dividing gives
  the ratio law in a few lines of `field_simp`/`nlinarith`.

### 4. Module-LWE forward secrecy and the rank–noise frontier

Lift forward secrecy from `ZMod q` to the module setting `(ZMod q)^k` or
`R_q^k` (Ring/Module-LWE), matching `Cryptography.ModuleLWE.Compression`.

- **Conjecture (falsifiable):** Forward secrecy of Module-LWE key exchange is
  *exactly* as strong as the additive masking over the free module `R_q^k`:
  the joint preimage count is `1` for every transcript iff masking acts
  coordinatewise by a unit, and Kyber's compression (rounding) degrades forward
  secrecy by a *bounded, computable* additive term `≤ k·2^(d_v - log q)` — zero
  in the uncompressed limit.
- **The key insight is** that compression is the *only* place module-level
  forward secrecy can leak, because outside compression every step is a module
  automorphism; so the entire forward-secrecy loss budget localizes to the
  rounding map already studied in the catalog's compression file.
- **Why now?** `ModuleLWE.Compression` already formalizes the rounding maps and
  their error bounds; combining them with `session_independence_factors`
  (which factorizes cleanly over products, hence over module coordinates) makes
  the coordinatewise lift immediate.

### 5. A worst-case GapSVP "feasibility region" theorem

We certified one point `(512, 12289, 1/256)`. The bold step is to prove the
*shape of the whole feasible region* `{(n,q,α) : 2√n ≤ α·q}` and its intersection
with the 128-bit cost surface, yielding a Pareto frontier.

- **Conjecture (falsifiable):** The set of GapSVP-backed, 128-bit-secure
  parameter triples is exactly the region cut out by the two smooth inequalities
  `2√n ≤ α·q` and `128 ≤ c·β(n,q,α)`, and along its boundary the modulus `q` and
  dimension `n` trade off as `q ∝ √n / α` — so *halving* the noise rate forces
  *doubling* the modulus to stay reduction-feasible at fixed `n`. Any
  standardized scheme sitting strictly inside this region is provably
  over-conservative (could shrink `q`).
- **The key insight is** that the GapSVP constraint and the attack-cost
  constraint are *both* monotone in the same variables, so their feasible region
  is a single connected, convex-boundary set whose extreme points are the
  optimal parameter choices — converting parameter selection from heuristic
  search into a verifiable optimization.
- **Why now?** `regev_reduction_feasible_512` and `bkzCost_monotone` already give
  the two monotone inequalities as Lean objects; proving the region is
  connected/convex-bounded is a `Convex`/`monotone` argument Mathlib supports
  directly, and the payoff is a *reusable* parameter-certification lemma for
  every future scheme in the catalog.
