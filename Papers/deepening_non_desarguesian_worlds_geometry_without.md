# Computational Evidence: The Dickson Nearfield of Order 9

All computations below were carried out by exhaustive evaluation over the nine elements
of `GF(9) = GF(3) × GF(3)`, with `α² = -1` (so `GF(9) = GF(3)[α]`). The Dickson product
is `a ∘ b = a·b` when `b` is a square, and `a ∘ b = σ(a)·b` when `b` is a non-square,
where `σ` is the Frobenius map `σ(x + yα) = x - yα`.

## 1. Squares and non-squares of GF(9)*

- Squares (including 0): `(0,0), (0,1), (0,2), (1,0), (2,0)` — i.e. `0` and the 4 nonzero
  squares.
- Non-squares: `(1,1), (1,2), (2,1), (2,2)` — the 4 elements of the non-trivial coset.

This 4+4 split is the index-2 subgroup structure of the cyclic group `GF(9)*` of order 8.

## 2. Axiom verification (all `9³ = 729` triples checked)

| property                                   | result |
|--------------------------------------------|--------|
| associativity `(a∘b)∘c = a∘(b∘c)`          | holds  |
| right distributivity `(a+b)∘c = a∘c + b∘c` | holds  |
| two-sided identity `(1,0)`                  | holds  |
| left multiplication injective (loop)       | holds  |
| right multiplication injective (loop)      | holds  |
| no zero divisors                           | holds  |
| two-sided inverses for nonzero elements    | holds  |
| planarity `m ↦ m∘p − m∘q` bijective (p≠q)  | holds  |
| **left distributivity**                    | **FAILS** |
| **commutativity**                          | **FAILS** |

Explicit left-distributivity counterexample: with `a = (0,1)`, `b = (1,0)`, `c = (1,1)`,
`a∘(b+c) ≠ a∘b + a∘c`.

## 3. Order structure of the multiplicative group

Computed multiplicative orders of the 8 nonzero elements:

```
(0,1) → 4    (0,2) → 4    (1,0) → 1    (1,1) → 4
(1,2) → 4    (2,0) → 2    (2,1) → 4    (2,2) → 4
```

- Exactly **one** element of order 2, namely `(2,0) = -1`.
- Six elements of order 4; the identity `(1,0)`.

A nonabelian group of order 8 with a unique involution is the **quaternion group `Q₈`**.
(The dihedral group `D₄`, the only other nonabelian group of order 8, has five
involutions.) The equation `x∘x = 1` therefore has exactly two solutions, `±1`.

## 4. Contrast with the underlying field and with the Hall system

- The field product on `GF(9)` *is* left distributive; the Frobenius twist is exactly
  what destroys the law.
- The Hall product studied in the companion development is non-associative with a proper
  3-element nucleus; the nearfield product is associative with full nucleus. The two
  order-9 non-Desarguesian constructions thus fail Desargues' theorem for independent
  algebraic reasons.

## 5. OEIS note

The count of finite non-Desarguesian projective planes of order `n` begins
`0, 0, 0, 0, 0, 0, 3, ...` (first nonzero at `n = 9`), consistent with the four planes of
order 9 (one Desarguesian, three non-Desarguesian: Hall, dual Hall, and nearfield).
