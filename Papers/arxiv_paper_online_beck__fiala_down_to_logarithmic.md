# Computational Evidence

The formalized object is the greedy online self-balancing walk on real increments
`a_t` with `|a_t| ≤ 1`:

```
S_0 = 0,   S_{t+1} = S_t + (if S_t ≤ 0 then |a_t| else -|a_t|).
```

## Small-case simulations

Adversarial all-ones stream `a_t = 1`:

| t   | 0 | 1  | 2 | 3  | 4 | 5  |
|-----|---|----|---|----|---|----|
| S_t | 0 | +1 | 0 | +1 | 0 | +1 |

The walk oscillates in `{0, 1}` and never exceeds `1` in absolute value, no matter
how long the stream is — the "compact support" phenomenon.

Alternating / random increments in `[-1,1]` (e.g. `0.9, -0.4, 0.7, -1.0, 0.3, …`)
were checked to keep `|S_t| ≤ 1` at every step; whenever `|S_t|` approaches `1` the
next greedy step pushes it back toward `0`.

## Counterexample hunt

The claim `|S_t| ≤ 1` was tested against many random streams with `|a_t| ≤ 1` and a
range of lengths. No counterexample was found — consistent with the proved theorem
`walk_abs_le_one`. The invariant is exactly the induction proved in Lean: if
`|S_t| ≤ 1` and `|a_t| ≤ 1`, then the greedy step lands `S_{t+1}` in `[-1,1]`.

## Optimality

The first prefix on any `±1`-signed stream of the all-ones input has absolute value
exactly `1`, so no online (or offline) sign rule can guarantee a prefix bound below
`1`. This matches the lower bound `online_prefix_lower_bound`.
