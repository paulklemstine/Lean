# Future Directions: Structural Information-Theoretic Cryptography

## Synthesis of this cycle

The catalog already contained `InfoTheory.shannon_perfect_secrecy_keysize`
(in `Shared/EntropyLatticeCrypto.lean`), but that statement is a *trivial
monotonicity wrapper*: it assumes `key_bits ≥ msg_bits` and concludes
`2 ^ key_bits ≥ 2 ^ msg_bits`. It never touches the definition of perfect
secrecy. This cycle replaced the wrapper with the real theorem.

In `Shared/ShannonSecrecyBound.lean` we modelled an abstract symmetric cipher
`Cipher M K C` (encryption injective per key = decryptable), defined perfect
secrecy as *equality of ciphertext-fiber cardinalities across messages*, and
proved from that definition alone:

- `card_message_le_card_key` — the combinatorial injection bound;
- `reachable_of_perfectSecrecy` — secrecy transports fiber nonemptiness;
- `shannon_perfect_secrecy` — the headline `|M| ≤ |K|`;
- `otpCipher_perfectSecrecy` / `otp_meets_shannon_bound` — the one-time pad over
  a finite group is a *tightness witness*;
- `no_perfect_secrecy_if_small_key` — the impossibility corollary.

All results compile with `sorry = 0` and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Results summary

| Theorem | Content |
|---|---|
| `card_message_le_card_key` | Reachable ciphertext ⇒ `\|M\| ≤ \|K\|` |
| `shannon_perfect_secrecy` | Perfect secrecy ⇒ `\|M\| ≤ \|K\|` |
| `otpCipher_perfectSecrecy` | OTP over a group is perfectly secret |
| `no_perfect_secrecy_if_small_key` | `\|K\| < \|M\|` ⇒ no perfect secrecy |

## Research directions

### 1. The equality case is a Latin-square / sharply-transitive characterization
When `|K| = |M| = |C|`, perfect secrecy should force the encryption matrix
`(k, m) ↦ enc k m` to be a Latin square: every ciphertext appears exactly once
in each row and column, and there is *exactly one* key per (message, ciphertext)
pair. **The key insight is** that the injection `M ↪ K` from
`card_message_le_card_key` becomes a bijection precisely when every fiber has
size exactly `|K| / |M|`, which under equality collapses to singletons — the
defining property of a sharply transitive key action. **Why now?** We already
have the fiber-counting machinery (`PerfectSecrecy`, `Finset.card_eq_one`); the
remaining step is to upgrade `card_pos` reasoning to exact equality, which is a
finite double-counting argument the subagent handles well.

### 2. Quantitative leakage when the key is too small
Drop perfect secrecy and ask: if `|K| < |M|`, how much *must* leak? Conjecture:
for a uniform key the adversary's optimal distinguishing advantage is at least
`1 - |K| / |M|`. **The key insight is** that the injection argument fails by a
measurable deficit — at least `|M| - |K|` messages collide onto the same key
behaviour for any fixed ciphertext, and that deficit is exactly the
non-reachable mass. **Why now?** `no_perfect_secrecy_if_small_key` already proves
the *qualitative* impossibility; turning the cardinality gap into a real-valued
advantage bound reuses the catalog's `DistinguishingAdvantage` structure from
`EntropyLatticeCrypto.lean`.

### 3. Entropy form: `H(K) ≥ H(M)` over the binary-entropy API
Mathlib ships `Real.binaryEntropy` / `negMulLog`. Conjecture: the cardinality
bound `|M| ≤ |K|` lifts to `H(M) ≤ H(K)` for the induced distributions, recovering
Shannon's original entropy inequality. **The key insight is** that `log` is
monotone, so the cardinality bound is the "max-entropy" shadow of the genuine
entropy statement; the full version needs Jensen/concavity for the message
distribution. **Why now?** The cardinality skeleton is done, and the catalog's
`Speculative/AutoResearch/ShannonEntropy.lean` already develops `negMulLog`
additivity we can import rather than rebuild.

### 4. Composition / product ciphers preserve the bound
If two ciphers are each perfectly secret, their parallel product
`enc (k₁,k₂) (m₁,m₂) = (enc₁ k₁ m₁, enc₂ k₂ m₂)` should be perfectly secret with
`|K| = |K₁|·|K₂|`. **The key insight is** that fibers of a product map factor as
products of fibers, so the fiber-cardinality equality is multiplicative. **Why
now?** It is a direct functorial extension of `PerfectSecrecy` and would create a
genuine cross-domain bridge to the catalog's categorical-information-theory files
(`Bridges/CategoricalInfoTheory/Core.lean`).

### 5. Removing decryptability: secrecy alone forces near-injectivity
We assumed per-key injectivity (decryptability). Conjecture: perfect secrecy with
`|C| = |M|` *already implies* each key is injective, so decryptability is not an
independent axiom but a consequence. **The key insight is** that a non-injective
key would shrink the realized ciphertext set, violating the equal-fiber count
that secrecy demands. **Why now?** Testing whether a hypothesis can be *dropped*
is exactly the adversarial-ground-truth mandate, and the proof is a counting
contradiction reusing `card_message_le_card_key` with the roles of `M` and `C`
swapped.
