# Future Directions: Combinatorial Shannon Secrecy and the Latin-Square Characterization

## Synthesis

This cycle replaced the catalog's *trivial* arithmetic restatement of Shannon's theorem
(`shannon_perfect_secrecy_keysize`, which only proves `key_bits ≥ msg_bits → 2^{key} ≥ 2^{msg}`)
with a genuine combinatorial formalization in `Cryptography/ShannonPerfectSecrecy.lean`. We
model an encryption scheme as an honest function `enc : K → M → C` over finite types, define
*perfect secrecy* as message-independence of the uniform-key ciphertext fiber sizes
(`PerfectSecrecy`), and *decryptability* as injectivity of each `enc k` (`Decryptable`).
The headline result `shannon_key_lower_bound` derives `|M| ≤ |K|` by an explicit injection
`M → K`: perfect secrecy turns one nonempty key fiber into *all* fibers nonempty, and
decryptability makes the chosen-key map injective. This is the real content of Shannon's
bound, not a tautology about exponentials.

The structural insight that emerged is that perfect secrecy is fundamentally about *fiber
counting*, and the tight case `|K| = |M| = |C|` is rigid. `perfectSecrecy_singleton_of_card_eq`
shows that at the tight case every fiber `{k | enc k m = c}` is a *singleton*: a double-count
over a fixed ciphertext (using bijectivity of each `enc k` to partition the key space via the
decryption map) forces `|K| = |M| · N` with all fibers of common size `N`, so `N = 1`. This is
precisely the Latin-square / sharply-transitive structure realized by the one-time pad, which
we verify directly in `otp_perfectSecrecy` over an arbitrary finite group (each fiber is the
singleton `{c·m⁻¹}`). The cycle thus unifies the lower bound, its tight optimum, and the OTP
optimizer into one coherent picture, with the impossibility corollary `no_perfectSecrecy_of_small_key`
as a free contrapositive.

What did not (yet) happen: we deliberately stayed combinatorial (uniform key, fiber cardinalities)
rather than measure-theoretic, because a full probabilistic `PMF`-based definition of perfect
secrecy and an entropy-chain-rule proof would have been a much larger build. The singleton
characterization is the *core* of the Latin-square ↔ group correspondence, but the full
isomorphism-to-a-group statement (Direction 1) remains open. These are the natural next steps.

## Results Summary

- `keyFiber` / `PerfectSecrecy` / `Decryptable`: definitions — honest finite-type encryption scheme, combinatorial perfect secrecy, and correctness; the vocabulary the rest builds on.
- `exists_key_of_perfectSecrecy`: proved — perfect secrecy propagates nonemptiness of one ciphertext fiber to every message.
- `shannon_key_lower_bound`: proved — genuine combinatorial Shannon bound `|M| ≤ |K|` for any decryptable perfectly-secret scheme.
- `otp_fiber_card`: proved — every one-time-pad fiber `{k | k·m = c}` is the singleton `{c·m⁻¹}`.
- `otp_perfectSecrecy`: proved — the one-time pad over any finite group is perfectly secret, attaining `|K| = |M| = |C|`.
- `otp_decryptable`: proved — the one-time pad is decryptable (left multiplication is injective).
- `enc_bijective_of_card`: proved — with `|M| = |C|`, decryptability upgrades each `enc k` to a bijection.
- `perfectSecrecy_singleton_of_card_eq`: proved — at the tight case `|K| = |M| = |C|`, perfect secrecy forces every key fiber to be a singleton (Latin-square structure).
- `no_perfectSecrecy_of_small_key`: proved — a decryptable scheme with `|K| < |M|` cannot be perfectly secret (impossibility corollary).

## Research Directions

### Direction 1: From singleton fibers to a group isomorphism
**Hypothesis**: Any decryptable perfectly-secret scheme with `|K| = |M| = |C|` is isomorphic to
the one-time pad over some group: there exist bijections `K ≃ G`, `M ≃ G`, `C ≃ G` and a group
structure on `G` for which `enc` becomes `(k, m) ↦ k · m`.
**Test**: Build the candidate binary operation from the singleton map `(m, c) ↦ the unique k`
given by `perfectSecrecy_singleton_of_card_eq`, prove it forms a quasigroup (Latin square), then
exhibit the group law where one exists, or produce a Latin square that is provably non-associative
as a counterexample to the *group* (as opposed to quasigroup) claim.
**Why now**: `perfectSecrecy_singleton_of_card_eq` already establishes the Latin-square skeleton;
only the algebraic packaging (`Equiv`, `Mul`, associativity audit) remains.
**If true**: A complete converse to `otp_perfectSecrecy`, closing Shannon's characterization.
**If false**: The natural counterexample (a non-associative Latin square giving perfect secrecy)
would show perfect secrecy is strictly a *quasigroup* phenomenon, sharpening the folklore.

### Direction 2: Probabilistic perfect secrecy and the uniform-key forcing theorem
**Hypothesis**: Define perfect secrecy via `PMF` over arbitrary (not necessarily uniform) key
distributions: `∀ m₁ m₂ c, Pr[enc(k,m₁)=c] = Pr[enc(k,m₂)=c]`. Then at `|K| = |M|` perfect
secrecy forces the key distribution to be *uniform*.
**Test**: Formalize the `PMF` pushforward `enc(·, m)`, define perfect secrecy as equality of
pushforwards, and prove uniformity via the singleton structure of Direction-1 fibers (each
ciphertext is hit by exactly one key, so equal probabilities force equal key weights).
**Why now**: Our cardinality argument is exactly the uniform-key special case; lifting `keyFiber`
to a `PMF` mass is a thin layer over what we proved.
**If true**: Recovers the strong textbook conclusion (key must be uniform), strictly stronger
than the cardinality bound.
**If false**: Would reveal a non-uniform perfectly-secret key distribution at the tight case — a
genuinely surprising object worth isolating.

### Direction 3: An entropy proof of `shannon_key_lower_bound`
**Hypothesis**: With a finite-`Fintype` Shannon entropy `H` and the chain-rule inequality
`H(K) ≥ H(K|C) ≥ H(M|C) = H(M)` under perfect secrecy, one obtains `log|K| ≥ log|M|`, hence
`|M| ≤ |K|`, agreeing with `shannon_key_lower_bound`.
**Test**: Build discrete Shannon entropy over `Fintype` (or specialize `MeasureTheory.Measure`),
prove `H(X) ≤ log (Fintype.card)` with equality iff uniform, and the conditioning monotonicity;
then re-derive the bound and compare the hypotheses needed against the combinatorial proof.
**Why now**: The combinatorial proof pins down *exactly* which structural facts (reachability,
injectivity) the entropy proof must reproduce, giving a precise target spec for the entropy API.
**If true**: A second, independent proof plus reusable entropy infrastructure (data-processing,
Fano) for the catalog.
**If false** (i.e. the entropy route needs strictly more hypotheses): Quantifies the price of the
"clean" information-theoretic argument versus the elementary counting one.

### Direction 4: Imperfect secrecy and a quantitative deficiency bound
**Hypothesis**: Define `ε`-secrecy as `∀ m₁ m₂ c, ||fiber(m₁,c)| - |fiber(m₂,c)|| ≤ ε·|K|`.
Then a decryptable `ε`-secret scheme satisfies `|M| ≤ |K| / (1 - (|M|-1)·ε)` (degrading to the
exact bound as `ε → 0`).
**Test**: Re-run the injection/double-count arguments tracking the additive slack `ε·|K|` instead
of exact equality, and find the largest `ε` for which a nontrivial bound survives; disprove any
bound that fails a small explicit scheme.
**Why now**: Our proofs isolate the two places equality is used (fiber nonemptiness, fiber-size
equality), so each can be relaxed to an inequality in a controlled way.
**If true**: A robust, "approximate Shannon" theorem bridging information-theoretic and
computational/statistical security notions.
**If false**: The breakdown point identifies the exact threshold where approximate secrecy stops
constraining key size — a sharp boundary case.

### Direction 5: Counting-method circuit lower bound, glued to the secrecy fiber count
**Hypothesis**: The same fiber-counting infrastructure (`Finset.card_eq_sum_card_fiberwise`,
partition by a chosen map) that proves `perfectSecrecy_singleton_of_card_eq` can bound the number
of size-`s` Boolean circuits on `n` inputs by `|B|^s · (n+s)^{2s}`, yielding `< 2^{2^n}` for
`s = o(2^n/n)` and hence a Shannon–Lupanov-style "most functions need large circuits" theorem.
**Test**: Define circuits as labeled DAGs over a `Fintype` basis, bound the description count by
induction on gate index using the fiberwise-counting lemmas, and contrast with `2^{2^n}` total
functions.
**Why now**: This cycle exercised exactly the finite-counting / fiber-partition toolkit the circuit
bound needs, so the reusable lemmas are now battle-tested.
**If true**: The first machine-verified circuit complexity lower bound in the catalog, sharing a
counting core with the cryptographic results.
**If false**: A miscount in the circuit enumeration would pinpoint where the naive Shannon–Lupanov
counting is too lossy, motivating a tighter encoding.
