# Computational Evidence — Degree-normalized adhesion sequences

We model the adhesion-size sequence `a n = |F_{e_n}|` read off the root-to-`α`
ray of a tree-cut decomposition that displays a graph end `ω`.  The edge-degree
of `ω` equals the `liminf` of `a`; degree-normalization predicts *eventual exact
stabilization* (finite degree) or *divergence* (infinite degree).

## 1. Small-case behaviour of the dichotomy

Eventually-monotone integer sequences and their fate:

| sequence `a n`             | eventual shape    | liminf / edge-degree | conjecture clause |
|----------------------------|-------------------|----------------------|-------------------|
| `5, 4, 3, 3, 3, 3, …`      | antitone → const  | `3` (finite)         | (i): `a n = 3` ✓  |
| `2, 4, 4, 4, 4, …`         | non-decr, bounded | `4` (finite)         | (i): `a n = 4` ✓  |
| `1, 2, 3, 4, 5, …`         | non-decr, unbnd   | `∞`                  | (ii): `a n → ∞` ✓ |
| `0, 2, 1, 3, 2, 4, …`      | non-monotone unbd | `∞`                  | (ii): `a n → ∞` ✓ |

All eventually-monotone cases land in exactly one of the two clauses — this is
`TreeCutDecomp.evMonotone_dichotomy`.

## 2. Counterexample hunt (necessity of linkedness)

We tested whether the *bare* `liminf = d` hypothesis already forces
stabilization.  It does **not**:

* `a n = d + (n mod 2)` gives `liminf = d` (edge-degree `d`) but oscillates
  between `d` and `d+1` forever, so it is never eventually equal to `d`.
* More generally any `a n = d + (n mod p)` with `p ≥ 2` has edge-degree `d` and
  never stabilizes.

Hence eventual monotonicity — the structural gift of **linkedness +
componental** — is load-bearing.  This is the formal theorem
`TreeCutDecomp.exists_finite_degree_not_normalized`.

## 3. OEIS

No new integer sequence is introduced; the objects are the families above
(constant tails, `n mod p` oscillations, the identity `a n = n`), none of which
require an OEIS identifier.

## 4. Takeaway

The computational survey confirms the precise content formalized in
`AdhesionSequence.lean`: under eventual monotonicity the adhesion sequence
stabilizes at a finite edge-degree or diverges, and without monotonicity finite
edge-degree alone never forces stabilization.
