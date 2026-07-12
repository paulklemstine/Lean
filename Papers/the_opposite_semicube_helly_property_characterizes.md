# Computational Evidence — Opposite-semicube Helly property of Cartesian products

We test the claim that a Cartesian product of two partial cubes satisfies the
opposite-semicube Helly property (equivalently: is harmonic-even) **iff both
factors are harmonic-even**, on small partial cubes modelled as sign-vector sets
`V ⊆ {0,1}^α`.

Recall a coordinate `i` is *balanced* when its two opposite semicubes
`W_i^+ = {v ∈ V : v i = 1}` and `W_i^- = {v ∈ V : v i = 0}` have equal size, and
`V` is *harmonic-even* when every coordinate is balanced. The opposite-semicube
Helly property (a matching of each opposite pair exists) is equivalent to
harmonic-evenness, since a bijection between two finite sets exists iff they are
equinumerous.

## Small-case calculations

Two building blocks over a single coordinate:

* `P2 = {∅, {0}}` — the 2-vertex path `K2` (an edge). Semicube sizes at
  coordinate `0`: `(|W^+|, |W^-|) = (1, 1)`. **Balanced ⇒ harmonic-even.**
* `K1 = {∅}` — a single vertex. Semicube sizes at coordinate `0`:
  `(|W^+|, |W^-|) = (0, 1)`. **Not balanced ⇒ not harmonic-even.**

Products (coordinates split as `α ⊕ β`; `inl` = first factor, `inr` = second):

| product        | vertices | `inl 0` sizes | `inr 0` sizes | harmonic-even? |
|----------------|----------|---------------|---------------|----------------|
| `P2 □ K1`      | 2        | `(1, 1)`      | `(0, 2)`      | **no**         |
| `P2 □ P2`      | 4        | `(2, 2)`      | `(2, 2)`      | **yes**        |

`P2 □ K1` fails balance exactly on the `inr`-coordinate coming from the
unbalanced factor `K1`, while `P2 □ P2` (the 4-cycle `C4`, the square) is balanced
on every coordinate. This is precisely the predicted behaviour: the product is
harmonic-even iff *both* factors are.

The multiplicative fingerprint is visible in the numbers: each product semicube
size is a factor semicube size times the cardinality of the other factor
(`|W^+_{inl 0}| = 1·|P2| = ... `), so balance of a coordinate survives the product
exactly when the corresponding factor coordinate is balanced (the positive factor
`|other|` cancels).

## Counterexample hunt

No counterexample to the equivalence was found. The single-vertex factor `K1`
provides the sharp boundary case showing the *nonemptiness* hypotheses on the
factors are necessary: with an empty factor the product would be empty and
vacuously balanced regardless of the other factor.

## Conclusion

The finite experiments are fully consistent with, and sharpen, the main theorem:
harmonic-evenness (equivalently the opposite-semicube Helly property) of a
Cartesian product is governed coordinate-by-coordinate and factors as the
conjunction over the two factors.
