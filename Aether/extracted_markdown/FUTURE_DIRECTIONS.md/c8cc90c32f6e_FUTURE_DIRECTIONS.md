# Future Directions — Thermodynamic Proof Erasure (Landauer's Principle for Mathematics)

## Synthesis

This cycle repaired and extended the catalog's Landauer development. The pre-existing
`Computation/LandauerLowerBound.lean` depended on a module
(`Computation.ReversibleTropicalThermodynamics`) that did not exist, so the entire
`Computation` build target was broken. We supplied that foundation from scratch and then
pushed the physics into proof theory.

Two files now form a small, self-contained theory:

* **`Computation/ReversibleTropicalThermodynamics.lean`** — finite-distribution entropy,
  the exact entropy of erasure (`uniform → Dirac` drops by `log n`), the Landauer cost
  `k·T·log n`, the per-bit law `k·T·b·log 2` for `2^b` microstates, and the equality case
  (reversible relabelling preserves entropy, `shannonEntropy_comp_equiv`).
* **`Computation/LandauerProofErasure.lean`** — the application: a proof is a bitstring
  record `Proof n := Fin n → Bool`. Proof normalisation erases `n` bits and dissipates
  exactly `k·T·n·log 2`; lossless compression obeys `2^n ≤ m`; there is **no** universal
  proof compressor (the strictly-shorter proofs number only `2^n − 1`); reversible
  derivations are free while every deterministic derivation has nonnegative cost (the
  data-processing inequality of `LandauerLowerBound` specialised to proof space).

## Results Summary

| Theorem | Content |
|---|---|
| `shannonEntropy_uniform`, `shannonEntropy_dirac` | entropy of `n` states is `log n`; deterministic states carry `0` |
| `landauer_cost_per_bit` | erasing `2^b` states costs exactly `k·T·b·log 2` |
| `shannonEntropy_comp_equiv` | reversible relabelling preserves entropy (free) |
| `proof_erasure_landauer_cost` | normalising `2^n` proofs to one form costs `k·T·n·log 2` |
| `lossless_proof_compression_card` | lossless encoder of `2^n` proofs needs `2^n ≤ m` codewords |
| `no_universal_proof_compressor` | no injection of length-`n` proofs into all shorter proofs |
| `reversible_proof_transform_free` / `proof_compression_nonneg_heat` | reversible = 0 heat; deterministic ≥ 0 heat |

All main results are `sorry`-free and use only `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. A strict data-processing inequality: lossy derivation *strictly* dissipates
Currently `proof_compression_nonneg_heat` gives `H(p) ≥ H(f∗p)`, but lossy proof
compression should dissipate a *strictly* positive amount. Conjecture: if `f` identifies
two proofs both carrying positive weight, then `shannonEntropy p > shannonEntropy (f∗p)`,
with the gap bounded below by `p(x)·log 2` whenever a fiber has at least two such points.
**The key insight is** that the entropy gap telescopes to `∑ₓ p x · (log f∗p(f x) − log p x)`,
and a non-singleton fiber makes at least one summand strictly positive, so strictness is a
local fact about a single collapsed pair, not a global concavity argument.
**Why now?** The non-strict gap is already proved in `LandauerLowerBound`; upgrading the
pointwise `Real.log_le_log` step to its strict sibling `Real.log_lt_log` on one fiber is a
small, self-contained increment that immediately yields a quantitative "lossy ⇒ heat" law.

### 2. Kraft–McMillan inequality as the sharp compressibility frontier
The incompressibility theorem (`no_universal_proof_compressor`) is the `equal-length` shadow
of a sharper statement: a prefix-free proof encoding with codeword lengths `ℓ(x)` exists iff
`∑ₓ 2^(−ℓ(x)) ≤ 1`. Conjecture: the optimal expected proof length under distribution `p` is
within one bit of `H(p)/log 2`, i.e. Shannon's source coding theorem holds for proofs.
**The key insight is** that the catalog's pushforward/fiber machinery already models the
many-to-one collapse a code performs, so Kraft is the same `∑ 2^k = 2^n − 1` counting made
weight-sensitive. **Why now?** We have the exact integer counting (`Nat.geomSum_eq`) and the
entropy of the uniform law in hand; the missing piece is purely the real-valued Kraft sum,
which Mathlib supports directly through `Finset.sum` over `2^(−ℓ x)`.

### 3. Landauer cost of cut-elimination / normalisation blow-up
Real proof normalisation (cut-elimination, β-reduction) can *increase* proof size before it
canonicalises. Conjecture: model a normaliser as a map `Proof n → Proof (g n)` and show its
*net* Landauer cost over a full reduction sequence is still `≥ 0` and equals `k·T·(H(start) −
H(normal form))`, independent of intermediate blow-up. **The key insight is** that heat is a
state function of the entropy endpoints, so transient size growth (reversible bookkeeping) is
thermodynamically free and only the final erasure is charged. **Why now?** The composition
law for pushforwards (`f∗(g∗p) = (f∘g)∗p`) is one lemma away from what
`LandauerLowerBound.pushforwardFun` already provides, turning a multi-step normaliser into a
single endpoint computation.

### 4. Bennett reversibility: zero-cost computation via history tapes
Bennett (1973) showed any computation can be made reversible by keeping a history. Conjecture:
for every (possibly lossy) `f : Proof n → Proof m` there is an injective lift
`f̃ : Proof n → Proof m × Proof n` with `shannonEntropy (f̃∗p) = shannonEntropy p`, so the
*only* irreversibility is the final erasure of the history register. **The key insight is**
that `x ↦ (f x, x)` is always injective, so `shannonEntropy_comp_equiv` makes the lifted
computation exactly free, isolating all dissipation into one explicit erasure step.
**Why now?** `shannonEntropy_comp_equiv` (this cycle) is precisely the "reversible = free"
lemma needed; the history construction is a one-line `Function.Injective` proof.

### 5. Cross-domain bridge: tropical (max-plus) entropy and zero-temperature erasure
The companion module is named *Tropical* thermodynamics for a reason: as `T → 0` the
Boltzmann weights `e^{−E/T}` concentrate on minimisers, and Shannon entropy degenerates to
the tropical (max-plus) "entropy" counting the number of optimal proofs. Conjecture: the
zero-temperature Landauer cost of erasure equals `k·T·log(#optimal proofs)`, linking the
catalog's tropical files to this thermodynamic one. **The key insight is** that the `log`-of-a-
cardinality structure of `shannonEntropy_uniform` is already the tropical limit, so the bridge
is the statement that uniform-on-the-argmin is the `T → 0` limit of the Gibbs distribution.
**Why now?** Both the tropical semiring API and the exact uniform-entropy lemma now coexist in
the catalog, making the limit a concrete `Filter.Tendsto` goal rather than a definitional one.
