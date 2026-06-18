# FUTURE_DIRECTIONS — Post-Quantum Lattice Cryptography (Regev / LWE)

This cycle delivered two self-contained Lean 4 files that upgrade the abstract,
real-valued interval bounds of `Cryptography/LWE/SearchDecisionCore.lean` into an
*exact, computable* decryption procedure and isolate the assumption-free
combinatorial core of Regev's IND-CPA argument.

## What was proved (all `sorry`-free)

**`RegevDecryption.lean`** — a centered nearest-codeword decoder `regevDecode`
over the even modulus `q = 2k`:

- `regevDecode_correct` — exact recovery of `μ ∈ {0,1}` whenever `2·|e| < k`
  (i.e. `|e| < q/4`). This is the exact-decision strengthening of the catalog's
  `regev_encryption_rounding_correctness`, which only bounded an interval.
- `regevDecode_zero_error` — noiseless correctness: encode/decode is a genuine
  retraction on bits.
- `regev_full_correct` — end-to-end correctness: the secret inner product
  `⟨a,s⟩` cancels exactly over `ℤ`, reducing decryption to rounding.
- `regev_multisample_correct` — correctness under accumulated subset-sum noise,
  routed through the (locally mirrored) catalog bound
  `noise_accumulation_subset_bound`.
- `regevDecode_tight` — an explicit boundary counterexample (`k=2, e=1, μ=0`,
  i.e. `|e| = q/4`) showing the strict inequality `2·|e| < k` cannot be relaxed
  to `≤`; the `q/4` tolerance is tight.

**`RegevSecurity.lean`** — the information-theoretic heart of IND-CPA:

- `regev_hiding` — an explicit translation bijection `σ = (· + (c₀ − c₁))` of
  `ℤ_q` with `u + c₀ = σ(u) + c₁` (the additive specialization of the catalog's
  `ZMod.affine_bijective`).
- `regev_preimage_card` — each ciphertext has a unique mask preimage `{t − c}`.
- `regev_ciphertext_count` — equal preimage counts across messages, i.e. the
  per-target IND-CPA advantage *given a uniform mask* is exactly `0`.

The decisive structural insight of this cycle: the naive "lower-half / upper-half"
decoder is **wrong** for negative noise, because reduction mod `q` wraps a small
negative `e` up to a representative near `q`; centering the acceptance window at
`[q/4, 3q/4)` repairs both signs uniformly.

---

## Research Directions

### Direction 1 — Vector messages and full-modulus decoding
**Hypothesis.** The centered decoder generalizes to messages `μ ∈ {0,…,p−1}`
encoded as `μ·⌊q/p⌋`, with exact recovery whenever `2·|e| < ⌊q/p⌋`, and to *odd*
moduli `q` using `⌊q/2⌋` in place of `k`.
**The key insight is** that `regevDecode_correct` already isolates the exact
arithmetic of the representative `r = v mod q` (`Int.emod_eq_of_lt` plus `omega`),
so replacing the half-codeword `k` by the general step `⌊q/p⌋` changes only the
two window constants `k ≤ 2r < 3k`.
**Test.** Define `regevDecodeBase p q v` and prove a `regevDecodeBase_correct`
analogue; then probe whether the bound sharpens or breaks for odd `q`, where
`⌊q/2⌋ ≠ q/2` introduces a one-unit asymmetry in the window.
**Why now?** The proof skeleton transfers almost verbatim — the only genuinely new
content is the floor arithmetic — so the marginal cost is low while the payoff
(p-ary, high-rate Regev/LWE) is large.
**If true:** correctness for the p-ary message variant and a stepping stone to
Kyber-style compression (cf. `Cryptography/KyberCompress.lean`).
**If false:** the failure modulus pinpoints exactly where rounding rate meets the
noise floor — a quantitative rate/robustness tradeoff.

### Direction 2 — Decoding directly over `ZMod q`
**Hypothesis.** There is a decoder `ZMod (2k) → ZMod 2` whose correctness is
*equivalent* to `regevDecode_correct`, eliminating the integer-lift bookkeeping.
**The key insight is** that `RegevSecurity.lean` already shows the additive group
structure of `ZMod q` is the natural home for the hiding argument, so unifying
correctness into the same type would let correctness and security share one
carrier.
**Test.** Use `ZMod.val` to express the centered window, prove
`decode (μ • encode + e) = μ` under a `ZMod`-phrased noise bound
(`(e.val) ⊓ (2k − e.val) < k/2`), and relate it to `regevDecode` via
`ZMod.intCast_zmod_eq_zero_iff`-style lemmas.
**Why now?** The security side is already in `ZMod q`; closing the type gap is
packaging, not new analysis.
**If true:** a single `ZMod q` development covers both correctness and IND-CPA.
**If false:** confirms the integer lift is the natural setting for nearest-codeword
decoding, because `ZMod` hides the metric the decoder needs.

### Direction 3 — Quantitative IND-CPA via a counting advantage functional
**Hypothesis.** For a decision predicate `D : ZMod q → Bool`, define
`advantage(D) = |#{u : D(u+c₀)} − #{u : D(u+c₁)}| / q`. Then `advantage(D) = 0`
for *every* `D` given a uniform mask, and more generally
`advantage(D) ≤ statisticalDistance(mask, uniform)`.
**The key insight is** that `regev_ciphertext_count` is exactly the per-target
atom: summing those per-target cardinality equalities over the support of `D`
collapses the difference to `0`, with the additive bijection `regev_hiding`
supplying the reindexing.
**Test.** Prove the `= 0` statement by `Finset.sum` over `D`'s accept set from
`regev_ciphertext_count`; then state the statistical-distance bound as a
`conjecture` and attempt the triangle-inequality step.
**Why now?** Both ingredients — the per-target count and the translation
bijection — are already proved this cycle; only the finite summation remains.
**If true:** a fully formal, assumption-free statement that the *only* source of
advantage is the LWE distinguishing gap — the exact shape of Regev's theorem.
**If false:** reveals a hidden dependence on `D`'s structure, i.e. a place where
the reduction is not tight.

### Direction 4 — Noise growth under homomorphic addition
**Hypothesis.** Adding `t` Regev ciphertexts yields a ciphertext decoding to the
sum/XOR of the bits provided `2·(t·B) < k`, linking `regev_multisample_correct`
to additive homomorphism.
**The key insight is** that `regev_multisample_correct` already routes accumulated
subset-sum noise through the catalog accumulation bound, so replacing a single `μ`
by a sum of bits `∑ⱼ μⱼ` is a small structural step, not a new analytic one.
**Test.** Prove `regevDecode k (∑ⱼ (μⱼ·k + eⱼ)) = (∑ⱼ μⱼ) mod 2` under the
budget `2·(t·B) < k`, reusing the accumulation bound; then find the smallest `t`
at which the budget — and hence correctness — breaks.
**Why now?** The single-message accumulation machinery is already in place; the
generalization reuses it directly.
**If true:** a formal additively-homomorphic correctness budget — the entry point
to leveled FHE (cf. `Cryptography/` FHE-adjacent files).
**If false:** the breaking `t` quantifies the additive depth of plain Regev,
motivating modulus switching (already stubbed in `SearchDecisionCore`).

### Direction 5 — A Lean interface for the worst-case→average-case reduction
**Hypothesis.** The GapSVP→LWE reduction can be stated as an abstract
*advantage-transfer* interface: given an LWE distinguisher of advantage `ε`, there
is a GapSVP solver succeeding with probability `≥ f(ε, n, q)`, where the
quantitative loss `f` reuses `search_to_decision_advantage_bound`.
**The key insight is** that the catalog already supplies both load-bearing
algebraic facts — the per-coordinate pigeonhole
(`search_to_decision_advantage_bound`) and the affine rerandomization
(`ZMod.affine_bijective`) — so the missing piece is *packaging* the oracles and
the advantage inequality, not new mathematics.
**Test.** Define a `structure` bundling the oracles and an advantage inequality
field; discharge the combinatorial loss factor with the pigeonhole lemma, leaving
the quantum/Gaussian step as an explicit hypothesis field, and state the end-to-end
claim as a `conjecture`.
**Why now?** Every algebraic ingredient is proved; only the interface design and
the abstract advantage bookkeeping remain.
**If true:** a reusable formal scaffold for worst-case-hardness claims that future
cycles can instantiate with a Gaussian/quantum-step lemma.
**If false:** identifies precisely which analytic ingredient (discrete Gaussian
smoothing) resists a purely algebraic Lean treatment, focusing the next cycle.
