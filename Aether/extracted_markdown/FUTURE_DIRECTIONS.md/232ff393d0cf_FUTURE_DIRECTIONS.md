# FUTURE_DIRECTIONS — Post-Quantum Lattice Cryptography (Regev / LWE)

## Synthesis

This cycle attacked the Regev LWE encryption scheme from two complementary
angles and, crucially, *closed the gap left open by the existing catalog file*
`Catalog/Cryptography/LWE/SearchDecisionCore.lean`. That file proves only
**real-valued, abstract interval bounds** — e.g. `regev_encryption_rounding_correctness`
shows the noisy encoding `μ·(q/2) + e` stays within `q/4` of the codeword — but
it never constructs an actual decryption *function* nor proves that such a
function returns the *exact* message bit. We supplied exactly that missing step.
In `RegevDecryption.lean` we define the centered nearest-codeword decoder
`regevDecode` over an even modulus `q = 2k` and prove `regevDecode_correct`:
exact recovery of `μ ∈ {0,1}` whenever `2·|e| < k`. The decisive structural
insight is that the *naive* "lower-half / upper-half" decoder is **wrong** for
negative noise, because reduction mod `q` wraps a small negative `e` up to a
representative near `q`; centering the acceptance window at `[q/4, 3q/4)` repairs
both signs uniformly. We then chained this into an end-to-end statement
(`regev_full_correct`, where the secret inner product cancels exactly over `ℤ`)
and a multi-sample version (`regev_multisample_correct`) that consumes the
catalog's `noise_accumulation_bound` directly — a genuine cross-file build-on.

The Critic contribution is `regevDecode_tight`: an explicit counterexample
(`k = 2, e = 1, μ = 0`, i.e. `|e| = q/4`) showing decoding fails *at* the
boundary. This proves the strict inequality `2·|e| < k` in `regevDecode_correct`
cannot be weakened to `≤` — the `q/4` noise tolerance is tight.

On the security side, `RegevSecurity.lean` isolates the information-theoretic
heart of Regev's IND-CPA argument. `regev_hiding` exhibits an explicit bijection
`σ = (· + (c₀ − c₁))` of `ℤ_q` with `u + c₀ = σ(u) + c₁`, so once the LWE
assumption replaces the mask `⟨a,s⟩ + e` by a uniform `u`, encryptions of
different messages are *identically distributed*. `regev_ciphertext_count`
restates this combinatorially: every target ciphertext has exactly one preimage
under each message, so the distinguishing advantage **given a uniform mask is
exactly 0**. The only remaining gap to full IND-CPA is the LWE pseudorandomness
hypothesis itself, which is computational, not a theorem. What failed/was
deliberately not attempted: a probabilistic (measure-theoretic) advantage
formalization — it is heavy and the bijection/counting proxy captures the same
content cleanly and honestly.

## Results Summary

- `regevDecode_correct`: **proved** — the centered integer decoder recovers the exact message bit whenever `2·|e| < k` (`|e| < q/4`); upgrades the catalog's interval bound to an exact decision procedure.
- `regevDecode_zero_error`: **proved** — noiseless correctness; encode/decode is a genuine retraction on bits.
- `regev_full_correct`: **proved** — end-to-end decryption: the secret inner product `⟨a,s⟩` cancels exactly over `ℤ`, reducing correctness to rounding.
- `regev_multisample_correct`: **proved** — correctness under accumulated subset-sum noise, built directly on the catalog's `noise_accumulation_bound`.
- `regevDecode_tight`: **proved (disproof of the boundary case)** — at `2·|e| = k` decoding fails, so the `q/4` tolerance is tight and the strict inequality is necessary.
- `regev_hiding`: **proved** — explicit translation bijection giving perfect message hiding once the mask is uniform (the `a = 1` specialization of the catalog's `ZMod.affine_bijective`).
- `regev_preimage_card`: **proved** — each ciphertext has a unique mask preimage `{t − c}`.
- `regev_ciphertext_count`: **proved** — equal preimage counts across messages, i.e. IND-CPA advantage `0` given a uniform mask.

## Research Directions

### Direction 1: Vector messages and full-modulus decoding
**Hypothesis**: The centered decoder generalizes to messages `μ ∈ {0,…,p−1}`
encoded as `μ·⌊q/p⌋` with exact recovery whenever `2·|e| < ⌊q/p⌋`, and to odd
moduli `q` using `⌊q/2⌋` in place of `k`.
**Test**: Define `regevDecodeBase p q v` and prove a `regevDecodeBase_correct`
analogue; disprove or sharpen the bound for odd `q` where `⌊q/2⌋ ≠ q/2`.
**Why now**: `regevDecode_correct` already isolates the exact arithmetic
(`Int.emod_eq_of_lt` plus `omega`); the proof skeleton transfers almost verbatim
with `k` replaced by `⌊q/p⌋`.
**If true**: Gives correctness for the *p*-ary message variant used in
high-rate LWE/Regev and a stepping stone to Kyber-style compression
(cf. `Catalog/Cryptography/KyberCompress.lean`).
**If false**: The failure modulus pinpoints exactly where rounding rate meets
the noise floor — a quantitative rate/robustness tradeoff.

### Direction 2: Decoding directly over `ZMod q`
**Hypothesis**: There is a decoder `ZMod (2*k) → ZMod 2` whose correctness is
equivalent to `regevDecode_correct`, removing the integer-lift bookkeeping.
**Test**: Use `ZMod.val` and prove `decode (μ • encode + e) = μ` for
`e` with `(e.val ⊔ (2*k − e.val)) ... < k`; relate to `regevDecode` via
`ZMod.intCast_zmod_eq_zero_iff` style lemmas.
**Why now**: `RegevSecurity.lean` already shows the additive structure of
`ZMod q` is the right home for the hiding argument; unifying correctness into
`ZMod q` would let correctness and security share one type.
**If true**: A single `ZMod q` development covers both correctness and IND-CPA.
**If false**: Confirms the integer lift is the natural setting for rounding and
that `ZMod` hides the metric needed for nearest-codeword decoding.

### Direction 3: Quantitative IND-CPA via a counting advantage functional
**Hypothesis**: Define `advantage(D) = |#{u : D(u+c₀)} − #{u : D(u+c₁)}| / q`
for a decision predicate `D`; then `advantage(D) = 0` for *every* `D` given a
uniform mask, and more generally `advantage ≤ statisticalDistance(mask, uniform)`.
**Test**: Prove the `= 0` statement from `regev_ciphertext_count` by summing the
per-target equalities over the support of `D`; then state the statistical-distance
bound as a `conjecture`.
**Why now**: `regev_ciphertext_count` is the per-target atom; summing it is a
finite reindexing that the additive bijection `regev_hiding` already supplies.
**If true**: A fully formal, assumption-free statement that the *only* source of
advantage is the LWE distinguishing gap — the exact shape of Regev's theorem.
**If false**: Reveals a hidden dependence on `D`'s structure, i.e. a place where
the reduction is not tight.

### Direction 4: Noise growth under homomorphic addition
**Hypothesis**: Adding `t` Regev ciphertexts yields a ciphertext decoding to the
XOR/sum of the bits provided `2·(t·B) < k`, linking `regev_multisample_correct`
to additive homomorphism.
**Test**: Prove `regevDecode k (∑ⱼ (μⱼ·k + eⱼ)) = (∑ⱼ μⱼ) mod 2` under the bound,
reusing `noise_accumulation_bound`; find the smallest `t` where it breaks.
**Why now**: `regev_multisample_correct` already routes accumulated noise through
the catalog bound; replacing a single `μ` by a sum of bits is a small step.
**If true**: A formal additively-homomorphic correctness budget — the entry point
to leveled FHE (cf. `Catalog/Cryptography/FHE`).
**If false**: The breaking `t` quantifies the additive depth of plain Regev,
motivating modulus switching (already stubbed in `SearchDecisionCore`).

### Direction 5: From worst-case to average-case — a Lean interface for the Regev reduction
**Hypothesis**: The GapSVP→LWE reduction can be stated in Lean as an abstract
*advantage-transfer* interface: given an LWE distinguisher with advantage `ε`,
there is a GapSVP solver succeeding with probability `≥ f(ε, n, q)`, where the
quantitative loss `f` reuses `search_to_decision_advantage_bound`.
**Test**: State the interface as a structure bundling oracles and an advantage
inequality (`conjecture`); discharge the *combinatorial* loss factor using the
catalog pigeonhole lemma, leaving the quantum/Gaussian step as an explicit
hypothesis field.
**Why now**: The catalog already has the per-coordinate pigeonhole
(`search_to_decision_advantage_bound`) and affine rerandomization
(`ZMod.affine_bijective`); the missing piece is packaging, not new analysis.
**If true**: A reusable formal scaffold for worst-case-hardness claims that
future cycles can instantiate with a Gaussian/quantum-step lemma.
**If false**: Identifies precisely which analytic ingredient (discrete Gaussian
smoothing) resists a purely algebraic Lean treatment, focusing the next cycle.
