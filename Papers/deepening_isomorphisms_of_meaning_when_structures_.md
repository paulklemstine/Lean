# Computational Evidence — Isomorphisms of Meaning: When Structures Collide

## 1. Group-theoretic collision on three points

We compare the two transpositions `f = (0 1)` and `g = (1 2)` in the symmetric
group on `{0,1,2}`.

| quantity                     | `f = (0 1)` | `g = (1 2)` | agree? |
|------------------------------|-------------|-------------|--------|
| cycle type                   | `{2}`       | `{2}`       | yes    |
| order                        | `2`         | `2`         | yes    |
| sign                         | `-1`        | `-1`        | yes    |
| support (points moved)       | `{0,1}`     | `{1,2}`     | **no** |

Every relabeling-invariant quantity coincides, yet the two symmetries disturb
different points. This is the minimal witness that structural invariants cannot
recover an object's "meaning" (its concrete action). The three-point set is the
smallest arena where two distinct transpositions exist, so this is minimal.

## 2. Transport of invariants under relabeling

For an equivalence `e : α ≃ β` the map `permCongr e` relabels the support:
`support (permCongr e f) = e '' support f`. Checked on small cases, e.g. with `e`
the cyclic shift on `{0,1,2}` and `f = (0 1)`:
- `support f = {0,1}`, `permCongr e f = (1 2)`, `support = {1,2} = e '' {0,1}`.
The cardinality (`2`) is invariant; the elements move. Order and sign are likewise
unchanged, confirming they are genuine truths of the abstract group.

## 3. Colliding meaning-morphisms of the divisibility monoid

Fibonacci `F(n)` and Mersenne `M(n) = 2ⁿ − 1` both satisfy the strong-divisibility
law `u(gcd m n) = gcd(u m)(u n)`, so both are structure-preserving maps of the
divisibility monoid. Their values differ:

| n            | 0 | 1 | 2 | 3 | 4 |  5 |  6 |
|--------------|---|---|---|---|---|----|----|
| `F(n)`       | 0 | 1 | 1 | 2 | 3 |  5 |  8 |
| `M(n)=2ⁿ−1`  | 0 | 1 | 3 | 7 |15 | 31 | 63 |

They already differ at `n = 2` (`1 ≠ 3`) and at `n = 3` (`2 ≠ 7`). Both,
nevertheless, obey the identical divisibility implication `m ∣ n ⇒ u m ∣ u n`,
e.g. `2 ∣ 4` gives `F(2)=1 ∣ 3=F(4)` and `M(2)=3 ∣ 15=M(4)`. Identical structure,
different meaning. (`F(n)` is OEIS A000045; `2ⁿ−1` is OEIS A000225.)

All numerical claims above are established as theorems in
`StructuresCollide.lean`; the table serves only as orientation.
