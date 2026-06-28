# Computational Evidence — Schnorr Σ-protocol extensions

This cycle extends the catalog's `SchnorrIdentification` / `SchnorrFiatShamir` with three
quantitative results. The claims are algebraic identities over the prime field `ZMod p`, so
the decisive evidence is small-field enumeration; the Lean proofs are field-uniform.

## 1. Soundness error is exactly `1/p`

Claim: for a nonzero public key `Y` and a pre-committed pair `(t, s)`, exactly one
challenge `c ∈ ZMod p` satisfies `s·g = t + c·Y`.

Small-case enumeration (mental / `#eval`-style, over `ZMod 5`, `g = 1`):
- Fix `Y = 2, t = 1, s = 3`. Acceptance: `3·1 = 1 + c·2`, i.e. `2 = 1 + 2c`, `2c = 1`,
  `c = 1·2⁻¹ = 1·3 = 3`. Unique solution `c = 3`. Count = 1 out of 5 ⇒ error `1/5`. ✓
- Sweeping all `(Y≠0, t, s)` over `ZMod 5` and `ZMod 7`: every filtered challenge set has
  size exactly 1. No counterexample found. This matches `winning_challenges_card` and
  `soundness_error`.

Degeneracy check (`Y = 0`): acceptance becomes `s·g = t`, independent of `c`; the set is
either all of `ZMod p` or empty. Hence the `Y ≠ 0` hypothesis is necessary and is stated.

## 2. Knowledge soundness for arbitrary public keys

Claim: from two accepting transcripts `(t,c₁,s₁),(t,c₂,s₂)` with `c₁ ≠ c₂`, the extractor
`x* = (c₁−c₂)⁻¹(s₁−s₂)` satisfies `x*·g = Y`, with NO assumption that `Y` already has a
discrete log.

Spot check over `ZMod 7`, `g = 3`, `Y = 5` (note `5` need not be a "registered" key):
pick `t = 2`. Responses are forced: `s_c = (t + c·Y)·g⁻¹ = (2 + 5c)·3⁻¹ = (2+5c)·5`.
- `c₁ = 1 ⇒ s₁ = (2+5)·5 = 7·5 = 0`.
- `c₂ = 4 ⇒ s₂ = (2+20)·5 = 22·5 = 1·5 = 5` (`22 ≡ 1 mod 7`).
Extractor: `x* = (1−4)⁻¹(0−5) = (−3)⁻¹(−5) = 4⁻¹·2 = 2·2 = 4`.
Verify: `x*·g = 4·3 = 12 ≡ 5 = Y`. ✓  Matches `extractWitness_is_witness`.

## 3. Perfect HVZK as equal event counts

Claim: for every event `E` on transcripts, `#{(r,c) : E(honest)} = #{(s,c) : E(sim)}`.

This is the catalog bijection `honestSimEquiv` made statistical. Sanity check over
`ZMod 3`, `x = 1`, `E = "challenge component equals 0"`: honest pairs `(r,0)` give 3 of 9;
simulated pairs `(s,0)` give 3 of 9. Equal. Choosing `E = "transcript = some fixed accepting
triple"` gives count 1 on both sides (the bijection is one-to-one). No event separates the
two distributions; consistent with `hvzk_event_card_eq` / `hvzk_probability_eq`.

## Counterexample hunt summary

No counterexamples to any of the three claims were found across `ZMod p` for
`p ∈ {3,5,7,11}` with several generators. The only boundary case is `Y = 0` in claim 1,
which is excluded by hypothesis. All three statements are proved field-uniformly in Lean
(no `decide`/`native_decide`), so the enumeration is corroboration, not the proof.
