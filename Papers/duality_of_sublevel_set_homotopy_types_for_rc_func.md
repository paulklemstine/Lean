# Computational Evidence — RC Sublevel-Set Duality

This note records the small-case checks that motivated the formal development in
`Homogeneous.lean`, `Duality.lean`, and `Examples.lean`.

## 1. The worked plane example

Take on `ℝ²`:

* `p(x,y) = |x|`,        `q(x,y) = |x| + |y|`        ⇒  `f  = |x| / (|x|+|y|)`
* `p°(x,y) = |y|`,       `q°(x,y) = |x| + |y|`       ⇒  `f° = |y| / (|x|+|y|)`

Polarity map = coordinate swap `L(x,y) = (y,x)`.

### Degree-0 homogeneity (sublevel sets are cones)

| `(x,y)`     | `t` | `f(t·(x,y))`          | `f(x,y)` |
|-------------|-----|-----------------------|----------|
| `(1,1)`     | `5` | `5/(5+5)=0.5`         | `0.5`    |
| `(3,1)`     | `2` | `6/(6+2)=0.75`        | `0.75`   |
| `(1,4)`     | `9` | `9/(9+36)=0.2`        | `0.2`    |

Confirmed: `f` is constant along rays — every sublevel set `{f ≤ c}` is a cone.
(Formalized: `ratio_smul_pos`, `coneSub_smul_mem`.)

### Intertwining `f° ∘ L = f`

| `(x,y)`   | `f(x,y)`            | `L(x,y)` | `f°(L(x,y))`         |
|-----------|---------------------|----------|----------------------|
| `(3,1)`   | `3/4 = 0.75`        | `(1,3)`  | `3/4 = 0.75`         |
| `(1,4)`   | `1/5 = 0.2`         | `(4,1)`  | `1/5 = 0.2`          |
| `(2,2)`   | `2/4 = 0.5`         | `(2,2)`  | `2/4 = 0.5`          |

Confirmed for every sample (and proved in general by `add_comm`): the only
non-trivial content is the *linearity* of the swap.
(Formalized: `ratio_intertwine`, `cone_intertwine`.)

### The two sublevel sets are genuinely different

For `c = 1/4`:

* `{f ≤ 1/4}` = `{(x,y) | |x| ≤ (|x|+|y|)/4}` = wedge hugging the **y-axis**
  (it contains `(0,1)` but not `(1,0)`).
* `{f° ≤ 1/4}` = wedge hugging the **x-axis** (contains `(1,0)`, not `(0,1)`).

They are reflections of each other across the diagonal — visibly distinct subsets
of the plane, yet homeomorphic via `L` (`exampleHomeo`, `exampleConeHomeo`). This
rules out the "vacuously equal sets" failure mode.

## 2. Counterexample hunt

* **Does the homeomorphism need convexity of `p,q`?**  No counterexample found,
  and the proof confirms it: only linearity of `L` and the intertwining identity
  are used.  Convexity is what *guarantees the polarity map is linear* in the
  source theory; once `L` is given linear, the topology is automatic.
* **Is the unrestricted sublevel set `{f ≤ c}` (allowing `q = 0`) the honest
  object?**  Sampling shows `q(x,y) = 0` only at the origin here, but in general
  `f = p/q` evaluates to `0 ≤ c` wherever `q = 0`, polluting the sublevel set.
  This is why `coneSub` carries the explicit `0 < q x` guard, and why both the
  ratio version (`sublevelHomeo`) and the guarded cone version (`coneSubHomeo`)
  are provided.

## 3. No OEIS sequence

The objects here are continuous (homotopy types of cones), not integer
sequences, so no OEIS lookup applies.

## Conclusion

Every sampled instance is consistent with the conjecture, and the samples
pinpointed the two design decisions (the `0 < q` domain guard, and packaging the
polarity map as a `ContinuousLinearEquiv`) that make the formal proofs go through.
