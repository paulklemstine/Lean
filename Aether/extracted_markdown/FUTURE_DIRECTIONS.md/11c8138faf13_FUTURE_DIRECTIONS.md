# Future Directions — Berggren Lattice Orbit Classification

This cycle established the **modular orbit classification** of the Berggren tree of
primitive Pythagorean triples (file `Catalog/Cryptography/BerggrenOrbit.lean`). Reducing
the orbit of the root `(3,4,5)` under the three Berggren steps modulo `n` yields a finite,
step-closed residue set `O(n)`, from which the classical Pythagorean congruence
obstructions (`2 ∣` orientation, `3 ∣ leg`, `4 ∣ leg`, `5 ∣ side`, `60 ∣ abc`) were
re-derived intrinsically and fully verified in Lean.

The conjectures below are precise and computationally testable. Sizes quoted were measured
by BFS closure: `|O(2)|=1, |O(3)|=4, |O(4)|=2, |O(5)|=12, |O(7)|=24, |O(8)|=4, |O(9)|=36,
|O(11)|=60, |O(13)|=84, |O(16)|=16, |O(25)|=300, |O(60)|=96`.

## Conjecture 1 — CRT multiplicativity of the orbit size
For coprime `m, n`, the Berggren orbit size is multiplicative:
`|O(m·n)| = |O(m)| · |O(n)|`.
Evidence: `|O(6)| = 4 = 1·4`, `|O(12)| = 8 = 2·4`, `|O(60)| = 96 = 2·4·12`.
A proof should follow from the ring isomorphism `ZMod (m·n) ≃ ZMod m × ZMod n` carrying
the (componentwise) step maps to the product of the two systems.

## Conjecture 2 — Odd-prime orbit-size formula
For every odd prime `p`, `|O(p)| = (p² − 1)/2`.
Evidence: `p = 3,5,7,11,13 ↦ 4,12,24,60,84`, all exactly `(p²−1)/2`.
This identifies the mod-`p` orbit with an index-2 subset of the projective light cone
`{a² + b² = c²}` over `𝔽_p` (whose projective point count is `p+1` lines, `p²−1` nonzero
cone points). The factor `1/2` should reflect the orientation grading (the `det = −1`
generator `B`).

## Conjecture 3 — Odd-prime-power tower
For every odd prime `p` and `k ≥ 1`, `|O(p^k)| = p^{2(k−1)} · (p² − 1)/2`.
Evidence: `|O(9)| = 36 = 3²·4`, `|O(25)| = 300 = 5²·12`. Combined with Conjecture 1 this
gives a closed multiplicative formula for `|O(n)|` at all odd `n`.

## Conjecture 4 — Anomalous 2-adic tower
The 2-adic orbit sizes `|O(2^k)|` do **not** follow the odd-prime-power law. Measured:
`|O(2)|=1, |O(4)|=2, |O(8)|=4, |O(16)|=16`. Conjecture: `|O(2^k)|` is governed by a
separate recurrence reflecting the strengthening congruences `2 ∣` (orientation),
`4 ∣ b`, `c ≡ 1 (mod 4)` already proved in this cycle; determine whether the even leg's
2-adic valuation is unbounded across the orbit (i.e. for every `k` some reachable triple
has `2^k ∣ b`), which would make the `2`-adic image genuinely infinite-depth.

## Conjecture 5 — Exact orbit = reduced primitive cone (sparsity for key exchange)
For every `n`, the Berggren orbit residue set `O(n)` equals the reduction modulo `n` of
the set of **all** primitive Pythagorean triples taken in standard orientation
(odd leg first). Consequently the orbit is sparse: `|O(n)| / n³ → 0`, with density
`∏_{p ∣ n, p odd} ((p²−1)/(2p³)) · (2-adic factor)`. For the cryptographic key-space
interpretation, this quantifies how strongly the modular invariants thin out the candidate
space of public triples, and bounds the advantage of a congruence-sieving distinguisher
against any Berggren-orbit-based key-agreement scheme.
