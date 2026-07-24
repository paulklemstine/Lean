# Computational Evidence: Tropical Phase-Transition Order Parameter

We model a phase transition in mathematical coherence by the **tropical
(max-plus) binomial**

```
order κ c x = max(κ·(x − c), 0)
```

with coupling `κ ≥ 0`, critical connectivity `c`, and control parameter `x`
(number/density of cross-field connections). This is the evaluation of a tropical
polynomial with two monomials: `κ·(x−c)` and the tropical zero `0`.

## 1. Small-case calculations (κ = 1, c = 3)

| x   | κ·(x−c) | order(x) = max(·, 0) |
|-----|---------|----------------------|
| 0   | −3      | 0                    |
| 1   | −2      | 0                    |
| 2   | −1      | 0                    |
| 3   | 0       | 0   (critical point) |
| 4   | 1       | 1                    |
| 5   | 2       | 2                    |
| 6   | 3       | 3                    |

Observations matching the proved theorems:

* Below `c = 3` the parameter is identically `0` (`order_eq_zero_of_le`).
* At `c = 3` it is exactly `0` (`order_at_critical`).
* Above `c` it equals `κ·(x−c)` and is strictly increasing
  (`order_eq_of_ge`, `order_strictMonoOn_above`).

## 2. Convexity / kink (second-order transition)

Slopes of `order` (κ = 1, c = 3):

```
left of c:  slope 0
right of c: slope 1
```

The slope jumps from `0` to `κ` at `x = c`: the graph is continuous but has a
**kink**, the hallmark of a continuous (second-order) transition. Being the max
of two affine functions, `order` is convex on all of ℝ (`order_convexOn`). The
kink locus `{x = c}` is exactly the tropical hypersurface of the binomial.

## 3. Lipschitz sanity check (κ = 2, c = 0)

`order(x) = max(2x, 0)`. Sample `|order(x) − order(y)|` vs `|κ||x − y|`:

| x  | y  | \|order(x)−order(y)\| | \|κ\|·\|x−y\| |
|----|----|-----------------------|---------------|
| 3  | 1  | 4                     | 4             |
| 1  | −1 | 2                     | 4             |
| −1 | −3 | 0                     | 4             |

Always `≤`, with equality when both points lie in the active region — consistent
with `order_lipschitz`.

## 4. Counterexample hunt

* Dropping `κ ≥ 0` breaks `order_eq_zero_of_le`: with `κ = −1, c = 0, x = −1` we
  get `order = max(1, 0) = 1 ≠ 0`. Hence the nonnegativity hypothesis on `κ` is
  necessary, and it is retained.
* Convexity (`order_convexOn`) and the Lipschitz bound (`order_lipschitz`) were
  tested with negative `κ` too and hold there — indeed both are stated without
  sign hypotheses on `κ`, matching the tests.

## 5. Sequence note

The integer samples of `order` with `κ = c = 1` starting at `x = 0` give
`0, 0, 1, 2, 3, 4, …` — the ReLU/positive-part sequence, OEIS
[A004526]-adjacent shifted ramps; nothing surprising, it is simply the discrete
ramp function. No deeper sequence structure is claimed.

All qualitative observations above are what the Lean theorems in
`TropicalPhaseTransition.lean` prove rigorously (with axioms limited to
`propext`, `Classical.choice`, `Quot.sound`).
