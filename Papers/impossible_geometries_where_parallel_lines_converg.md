# Computational Evidence: Split Geometry

Metric: `ds² = dx²/cosh²(y) + cosh²(x)·dy²`.
Split curvature field studied: `K(x,y) = sech²(x) − sech²(y) = 1/cosh²(x) − 1/cosh²(y)`.

## 1. Sample values of K(x,y)

| (x, y)      | cosh x | cosh y | K = sech²x − sech²y | sign | region       |
|-------------|--------|--------|---------------------|------|--------------|
| (0, 0)      | 1.000  | 1.000  | 0.000               | 0    | boundary     |
| (1, 1)      | 1.543  | 1.543  | 0.000               | 0    | boundary     |
| (2, −2)     | 3.762  | 3.762  | 0.000               | 0    | boundary     |
| (0, 1)      | 1.000  | 1.543  | +0.580              | +    | elliptic     |
| (0.5, 2.0)  | 1.128  | 3.762  | +0.715              | +    | elliptic     |
| (1, 0)      | 1.543  | 1.000  | −0.580              | −    | hyperbolic   |
| (2.0, 0.5)  | 3.762  | 1.128  | −0.715              | −    | hyperbolic   |
| (3, 1)      | 10.07  | 1.543  | −0.410              | −    | hyperbolic   |

Observed rule (confirmed on the sample and then proved):
`K > 0 ⇔ |x| < |y|`, `K = 0 ⇔ |x| = |y|`, `K < 0 ⇔ |y| < |x|`.

Note: this is the *opposite* elliptic/hyperbolic labelling to the initial
conjecture, which is corrected in the Lab Notes.

## 2. Phase boundary

`K(x,y) = 0` forces `cosh x = cosh y`, hence `|x| = |y|`, i.e. the two diagonals
`y = x` and `y = −x`. Every sampled boundary point above lies on one of these
lines; every off-diagonal sample is strictly signed.

## 3. Area element

`√(det g) = √(sech²y · cosh²x) = cosh x / cosh y`. Spot check at (2, 0.5):
`3.762 / 1.128 ≈ 3.335 > 0`, matching `sqrt_det_eq` and positivity of the metric.

## 4. Geodesic-transversality proxy (line crossings)

A coordinate line `t ↦ (p₁ + t d₁, p₂ + t d₂)` meets the boundary where
`|x(t)| = |y(t)|`, i.e. where `x(t) = y(t)` or `x(t) = −y(t)`. Each is one linear
equation in `t`; with `d₁ ≠ d₂` and `d₁ + d₂ ≠ 0` each has a unique root, so at
most two crossings. Example: `p = (0,1)`, `d = (1,0)`: crossings at `t = 1`
(`x=y`) and `t = −1` (`x=−y`) — exactly two, as predicted.

No counterexample to the sign trichotomy or the two-crossing bound was found in
the sample.
