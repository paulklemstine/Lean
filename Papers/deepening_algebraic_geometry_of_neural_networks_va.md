# Computational Evidence: ReLU decision boundaries and their algebraic varieties

We collect small-case checks supporting the two headline results before the
formal development.

## 1. `max a b = a + ReLU(b − a)` (basis of the converse direction)

| a | b | a + max(b−a, 0) | max(a,b) |
|---|---|-----------------|----------|
| 1 | 3 | 1 + max(2,0)=3  | 3        |
| 5 | 2 | 5 + max(−3,0)=5 | 5        |
| −2| −2| −2 + 0 = −2     | −2       |

The identity holds in every case, confirming that a finite max of affine pieces
is realizable by rectifier units, hence every tropical polynomial is
ReLU-computable.

## 2. `ReLU(p − q) = max(p, q) − q` (basis of ReLU closure)

| p | q | max(p−q,0) | max(p,q) − q |
|---|---|-----------|--------------|
| 4 | 1 | 3         | 4 − 1 = 3    |
| 1 | 4 | 0         | 4 − 4 = 0    |
| 2 | 2 | 0         | 2 − 2 = 0    |

Confirms that the rectifier of a tropical rational function is again tropical
rational.

## 3. Boundary polynomial of a one-dimensional example

Take `n = 1`, `p(x) = max(0, x)` with pieces `{0, x}` (i.e. affine forms `0` and
`x`), and `q(x) = max(−x, 1)` with pieces `{−x, 1}`. The classifier
`f = p − q` vanishes where `p(x) = q(x)`.

- For `x ≥ 0`: `p = x`, and `q = 1` when `x ≤ 1`. Boundary at `x = 1`.
- For `x < 0`: `p = 0`, `q = −x > 0`; equality `0 = −x` only at `x = 0`, but there
  `q = max(0,1) = 1 ≠ 0`, so no boundary point there.

The boundary is the point `{1}`. The boundary polynomial is the product over the
four piece pairs of the affine differences:

```
Φ(x) = (0 − (−x)) · (0 − 1) · (x − (−x)) · (x − 1)
     = (x) · (−1) · (2x) · (x − 1)
     = −2x²(x − 1).
```

Its real zero set is `{0, 1}`, which indeed **contains** the decision boundary
`{1}`. The extra root `x = 0` is a *non-attained* crossing of pieces, confirming
that the containment is strict in general (the Critic's boundary case) and cannot
be upgraded to equality.

## 4. Counterexample hunt for the equivalence

We probed whether any of the network operations (affine, `+`, scalar `·`, `ReLU`)
could leave the tropical rational class: for random affine forms and reweightings
in dimension `n ≤ 3`, every generated function admitted a difference-of-maxima
representation, and no operation produced a function outside the class. No
counterexample to the forward direction was found, consistent with the proved
closure lemmas.

## Conclusion

The small cases uniformly support: (i) the two algebraic identities underlying the
depth-free equivalence, and (ii) the one-directional containment of the decision
boundary in an explicit linear-factor algebraic hypersurface, with the strictness
of the containment visible already in one dimension.
