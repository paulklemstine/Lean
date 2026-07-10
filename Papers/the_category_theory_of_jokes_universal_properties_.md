# Computational Evidence: The Surprise Invariant

We model a setup as a finite nonempty configuration of resolutions `S ⊆ ℝ` and define
its surprise as `humor S = max' S - min' S`.

## 1. Small-case calculations

| Setup `S`            | `min' S` | `max' S` | `humor S` | interpretation        |
|----------------------|----------|----------|-----------|-----------------------|
| `{3}`                | 3        | 3        | 0         | pun (no subversion)   |
| `{2, 2, 2}`          | 2        | 2        | 0         | pun (constant)        |
| `{0, 1}`             | 0        | 1        | 1         | mild twist            |
| `{0, 1, 5}`          | 0        | 5        | 5         | absurdist             |
| `{-4, 0, 3}`         | -4       | 3        | 7         | absurdist             |

These match the proven laws: `humor_singleton` (row 1), `humor_eq_zero_iff` (rows 1–2),
and `humor_mono` (`{0,1} ⊆ {0,1,5}` gives `1 ≤ 5`).

## 2. Diameter identity check

For `S = {-4, 0, 3}`, the pairwise distances are
`|(-4)-0| = 4`, `|(-4)-3| = 7`, `|0-3| = 3`. The greatest is `7 = humor S`, confirming
`humor_is_diameter`: surprise equals the largest pairwise distance and is attained by the
extreme pair `(-4, 3)`.

## 3. Counterexample hunt

- *Nonnegativity*: no configuration produced a negative surprise (proven:
  `humor_nonneg`).
- *Monotonicity*: across random nested pairs `S ⊆ T`, surprise never decreased (proven:
  `humor_mono`).
- *Vanishing*: the only configurations with surprise `0` were the constant ones (proven:
  `humor_eq_zero_iff`). No non-constant zero-surprise configuration exists.

No counterexamples to any stated law were found; each law is a theorem in
`JokeHumorMetric.lean`.

## 4. Universal-object side

For the categorical pillar, the concrete witness `PUnit` is a universal (terminal)
resolution among sets: from any set there is exactly one map to it, matching
`universal_from_unique_existence`. Two singletons are canonically isomorphic with a
coherent round trip, matching `universal_iso_coherent`.

The sequence of surprises for the "growing setup" `{0}, {0,1}, {0,1,2}, ...` is
`0, 1, 2, 3, ...` (the range of an interval of integers), i.e. the identity sequence
`a(n) = n`; no dedicated OEIS lookup is needed.
