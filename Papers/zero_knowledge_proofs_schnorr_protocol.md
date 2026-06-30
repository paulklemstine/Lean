# Computational Evidence — Chaum–Pedersen DLEQ and message-bound Schnorr signatures

All claims in this cycle are **exact algebraic identities over the prime field `ZMod p`**,
so the relevant computational evidence is checking the defining equations on small concrete
fields. We summarise the spot checks that motivated the formal statements.

## 1. Chaum–Pedersen completeness (small case)

Work in `ZMod 7` with generators `g = 3`, `h = 5`, secret `x = 4`, randomness `r = 2`,
challenge `c = 6`.

* `Y₁ = x·g = 4·3 = 12 = 5`, `Y₂ = x·h = 4·5 = 20 = 6`.
* Commitments `t₁ = r·g = 2·3 = 6`, `t₂ = r·h = 2·5 = 10 = 3`.
* Response `s = r + c·x = 2 + 6·4 = 26 = 5`.
* Check 1: `s·g = 5·3 = 15 = 1`; `t₁ + c·Y₁ = 6 + 6·5 = 6 + 30 = 36 = 1`. ✓
* Check 2: `s·h = 5·5 = 25 = 4`; `t₂ + c·Y₂ = 3 + 6·6 = 3 + 36 = 39 = 4`. ✓

## 2. Chaum–Pedersen special soundness / DLEQ extraction

Same field, two transcripts sharing `(t₁, t₂)` with challenges `c₁ = 6, c₂ = 1` and
honest responses `s₁ = r + c₁·x = 5`, `s₂ = r + c₂·x = 2 + 1·4 = 6`.

* Extractor: `x* = (c₁ - c₂)⁻¹·(s₁ - s₂) = (6-1)⁻¹·(5-6) = 5⁻¹·(-1)`.
  In `ZMod 7`, `5⁻¹ = 3` (since `5·3 = 15 = 1`), `-1 = 6`, so `x* = 3·6 = 18 = 4 = x`. ✓
* The same `x*` reproduces **both** `Y₁` and `Y₂`, which is exactly why the protocol proves
  *equality* of the two discrete logs rather than two independent logs.

## 3. Message binding of Schnorr signatures

In `ZMod 11`, `g = 2`, `x = 3`, `Y = x·g = 6`. Sign message-tag value `H(t,m) = c`.
A signature `(t,s)` valid for `m₁` with `H(t,m₁) = c₁` and also valid for `m₂` with
`H(t,m₂) = c₂` would force `c₁·Y = c₂·Y`, i.e. `c₁·6 = c₂·6`; since `6 ≠ 0` and `11` is
prime, `c₁ = c₂`. So cross-message reuse is impossible unless the oracle collides at the two
message-tagged points — confirming `sig_cross_message_forces_collision`.

## 4. Counterexample hunt

* **Without** the shared response in Chaum–Pedersen (two independent responses `s₁ ≠ s₂`
  for the two bases), the protocol does NOT prove equality of discrete logs: any pair
  `(Y₁, Y₂)` admits accepting transcripts. This negative check is what fixes the protocol
  design (single response `s`) and is recorded in the Lab Notes failure analysis.
* The `Y ≠ 0` hypothesis in the message-binding lemma is necessary: at `Y = 0` every
  message tag is trivially accepted with `s·g = t`, so no collision is forced.

No counterexample to any *formalized* statement was found; all are proved in Lean with
0 sorries over `propext, Classical.choice, Quot.sound` only.
