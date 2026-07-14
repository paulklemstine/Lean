# Computational Evidence — Strange Loop Deepening (Parts IV–VI)

Concise numerical checks supporting the three new results.

## Part IV — The blind spot has measurable size

Behaviour count `|S → B| = |B|^{|S|}` vs. state count `|S|`, with `|B| = 2`:

| `|S|` | states | behaviours `2^{|S|}` | blind spot `2^{|S|} − |S|` |
|------:|-------:|---------------------:|---------------------------:|
| 1     | 1      | 2                    | 1                          |
| 2     | 2      | 4                    | 2                          |
| 3     | 3      | 8                    | 5                          |
| 4     | 4      | 16                   | 12                         |
| 10    | 10     | 1024                 | 1014                       |

The representable fraction `|S| / 2^{|S|}` collapses to `0` exponentially:
`0.5, 0.5, 0.375, 0.25, …, 0.0098` — the blind spot dominates. Verified in
Lean by `decide` for the small cases and in general by `n < 2^n`.

## Part V — Order-reversal is the obstruction

On the two-point observation lattice `Bool = {false < true}` there are `4`
self-maps. Enumeration of monotone vs. fixed-point behaviour:

| map            | monotone? | fixed points          |
|----------------|-----------|-----------------------|
| `id`           | yes       | `false, true`         |
| `const false`  | yes       | `false`               |
| `const true`   | yes       | `true`                |
| `not` (negation)| **no**   | **none**              |

Exactly the one non-monotone (order-reversing) map is fixed-point-free. This is
the computational germ of the general theorem: on a complete lattice every
monotone map has a fixed point (Knaster–Tarski), so any Lawvere obstruction must
be order-reversing.

## Part VI — Girth of the successor hierarchy on `ZMod n`

A closed walk of length `k` exists in the successor relation on `ZMod n` iff
`n ∣ k`. Smallest positive loop length (girth) per `n`:

| `n` | loop lengths that occur | girth |
|----:|-------------------------|------:|
| 3   | 3, 6, 9, …              | 3     |
| 4   | 4, 8, 12, …             | 4     |
| 7   | 7, 14, 21, …            | 7     |

Girth equals the group order `n`. The `n = 3` row recovers Part II's
"no length-2 loop" (`3 ∤ 2`). Verified in Lean by `succ_loop_dvd` and
`succ_loop_exists`.

## Counterexample hunt

- Part IV: searched for a conscious (surjective) finite self-model with `|B| ≥ 2`;
  none exists (pigeonhole `|B|^{|S|} > |S|`). No counterexample.
- Part V: searched `Bool → Bool` for a monotone map without a fixed point; none
  found. Searched for a fixed-point-free *monotone* map on any tested finite
  lattice; none found (consistent with Knaster–Tarski).
- Part VI: searched for a successor loop of length not divisible by `n` for
  `n ≤ 12`; none found.
