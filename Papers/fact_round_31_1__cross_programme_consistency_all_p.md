# Computational evidence — paper 107 (CROSS-PROGRAMME-CONSISTENCY)

Status of each item: **[Lean]** = checked by a sorry-free Lean proof in
`Catalog/Probability/CrossProgrammeConsistency.lean`; **[script]** = exploratory
Python only, *not* formally verified.

## 1. Small cases
* XOR battery on `Bool × Bool`, label `L = x₁ xor x₂` **[Lean, `xor_synergy_sharp`]**:
  `I(L;x₁) = I(L;x₂) = 0`, `I(L;x₁,x₂) = log 2` (1 bit), synergy = 1 bit =
  `min(H(x₁|L), H(x₂|L))` — the synergy sandwich upper bound is attained.

## 2. Arithmetic of the recorded table (bits) [Lean, `recorded_table_passes_necessary_checks`]
| check | values | holds |
|---|---|---|
| marginal ≤ joint (S₃a×S₃b) | 1.0012 ≤ 2.1314 | yes |
| marginals ≤ joint (A₄×D₄) | 0.4733, 1.4342 ≤ 1.9125 | yes |
| 2-field joints ≤ 4-field capacity | 2.1314, 1.9125 ≤ 8.2246 | yes |
| capacity ≤ label-entropy ceiling (paper 92) | 8.2246 ≤ 9.5276 | yes |
| max spread | 0.0040 | yes |

Derived: S₃a×S₃b synergy = 2.1314 − 2.0024 = 0.1290 bits; A₄×D₄ synergy (with
D₄ = 1.4342) = 0.0050 bits; four-field synergy = 8.2246 − 3.9099 = 4.3147 bits.
Note: 3.9099 = 1.0012 + 1.0012 + 0.4733 + 1.4342 (uses the *second* D₄ recording).

## 3. Counterexample hunt [script]
20 000 random populations (size 1–12, alphabets 2–4) for `(L, f, g)`:
0 violations of `-min(I(L;f),I(L;g)) ≤ Syn ≤ min(H(f|L),H(g|L))`,
0 violations of `H(f,g) ≤ H(f)+H(g)`; max synergy observed 1.0817 bits.
(Consistent with the Lean theorems, which prove both statements in general.)

## 4. Critic finding [Lean, `joint_column_is_not_entropy`]
2.1314 > 1.0012 + 1.0012, so the joint column cannot consist of joint *entropies*;
it must be trace *information* (where super-additivity is allowed).

No OEIS sequence is involved.
