# Future Directions: The Anti-Fibonacci Parabola

## Synthesis

The Fibonacci recurrence `F(n+1) = F(n) + F(n-1)` is the prototype of *additive*
dynamics: geometric growth, and a successive ratio locked onto the golden ratio
`φ`. In `Catalog/Geometry/AntiFibonacci.lean` we pinned down the natural
*anti-additive* counterpoint suggested by the catalogued integer string
`1, 1, 2, 4, 7, 11, 16, 22, …`. The string is generated exactly by

```
A(0) = 1,    A(k+1) = A(k) + k,
```

and from this single fact a complete asymptotic picture falls out:

- **Closed form** `2·A(n) = n(n−1) + 2`, hence `A(n) = (n² − n + 2)/2`
  (`antiFib_closed_form`, `antiFib_closed_form_real`).
- **The golden ratio dies:** `A(n+1)/A(n) → 1` (`antiFib_ratio_tendsto_one`).
  Where Fibonacci spirals at rate `φ ≈ 1.618`, the anti-Fibonacci ratio
  collapses to unity.
- **The orbit becomes a parabola:** `A(n)/n² → 1/2`
  (`antiFib_growth_tendsto_half`). The points `(n, A(n))` asymptotically lie on
  `y = x²/2`.
- **Eventual sub-additivity (avoidance law):** for `m ≥ 4`,
  `A(m+2) < A(m+1) + A(m)` (`antiFib_eventually_subadditive`): the sequence
  permanently outruns its own additive shadow.
- **Monotonicity** `antiFib_monotone`.

### Results summary

Six theorems, zero `sorry`, standard axioms only. The headline geometric
statement is the migration of the orbit from the logarithmic spiral of
Fibonacci/`φ` onto the parabola `y = x²/2` — a clean, fully formalized
counterpoint that also *corrects* the originating informal note (which guessed
`A(n)/n² → 1/4` and an oscillating ratio; the explicit terms force the limit
`1/2` and a ratio converging monotonically to `1`).

These results connect to the catalog's `Geometry/Convergence.lean` machinery
(discrete sequences, `Filter.Tendsto`, harmonic-style corrections `1/n → 0`) and
to the Fibonacci/golden-ratio material implicit across the number-theory entries;
the cross-domain bridge here is *asymptotic geometry of integer recurrences*.

---

## Direction 1 — A "spectral gap" classification of difference-driven recurrences

Generalize from the increment `+k` to an arbitrary polynomial increment
`A(k+1) = A(k) + p(k)` with `deg p = d ≥ 0`. Conjecture: `A(n) ∼ c·n^{d+1}` with
`c = (leading coeff of p)/(d+1)`, and the successive ratio `A(n+1)/A(n) → 1` for
every such `p`, while the *normalized* second difference encodes `p` exactly.

**The key insight is** that a converging successive ratio of `1` is the precise
analytic signature of *sub-exponential* (here polynomial) growth: any recurrence
whose increment is `o(A(n))` must have ratio `→ 1`, so "avoiding `φ`" is not
special to `+k` but is a structural law of all polynomially-driven sequences.

**Why now?** The closed-form-by-induction template (`antiFib_closed_form_real`)
plus `Tendsto.congr'` against an explicit rational function generalizes
mechanically to any fixed `p`; the proof we already have is the `d = 1` instance,
so the `d`-parameter family is within immediate formalization reach.

## Direction 2 — Density zero of the additive shadow

Define the *Fibonacci shadow* `S = { A(n+1) : A(n+1) = A(n) + A(n-1) }`, the set
of indices where the anti-Fibonacci accidentally obeys the additive law.
Conjecture: `S` is finite (in fact `S` corresponds only to the small indices
`n ≤ 3`), hence has natural density `0` inside `ℕ`.

**The key insight is** that `antiFib_eventually_subadditive` already proves
`A(m+2) < A(m+1) + A(m)` for all `m ≥ 4`, which is a strict inequality — so
equality can occur only finitely often, turning a soft "density 0" claim into a
hard *finiteness* theorem.

**Why now?** We have the strict inequality in hand for `m ≥ 4`; finishing
requires only checking the finite window `m ≤ 3` by `decide`, making this a
short, high-certainty follow-up that upgrades the informal "complement has
density 0" conjecture into a precise finiteness result.

## Direction 3 — The parabola is an attractor, with an explicit error bound

Strengthen `A(n)/n² → 1/2` to a quantitative envelope:
`|A(n) − n²/2| ≤ n/2 + 1` for all `n`, i.e. `A(n) = ⌊n²/2⌋ + O(1)` with an
*explicit, optimal* constant rather than an asymptotic `O`.

**The key insight is** that the closed form `A(n) = (n² − n + 2)/2` makes the
error term `A(n) − n²/2 = (2 − n)/2` *exactly computable*, so the `O(1)` in the
informal conjecture is in truth a linear-in-`n` but tightly controlled deviation
— the right normalization is `A(n) − n²/2 + n/2 ≡ 1`.

**Why now?** This converts the limit theorem into an identity-level bound using
only the already-proven closed form and `Nat.floor`/`Int` casting lemmas; it is
the natural "make the `O` explicit" sharpening expected of a finished asymptotic.

## Direction 4 — A two-dimensional curvature bridge to discrete Gauss–Bonnet

Interpret `(n, A(n))` as a discrete plane curve and compute its discrete
curvature `κ(n)` (turning angle of successive edge vectors). Conjecture:
`κ(n) → 0` and `Σ κ(n)` converges, with the total turning equal to the angle
swept from the initial near-vertical Fibonacci-like segment to the asymptotic
parabolic direction.

**The key insight is** that a sequence with constant second difference `1` is a
*discrete parabola*, and discrete parabolas have summable curvature — linking the
anti-Fibonacci directly to the catalog's `Geometry/DiscreteGaussBonnet.lean`
circle of ideas (total curvature of discrete curves).

**Why now?** The exact second difference `A(k+2) − 2A(k+1) + A(k) = 1` is a
one-line corollary of our closed form, and it is precisely the input a discrete
curvature/Gauss–Bonnet computation needs; this is the most promising
*cross-domain* extension, joining integer recurrences to discrete differential
geometry already present in the catalog.

## Direction 5 — Anti-Fibonacci over arbitrary seeds: a universality theorem

Replace the seed `(1,1)` by `(a,b)` and the increment law by the same `+k`.
Conjecture: for *every* seed, `A(n)/n² → 1/2` and `A(n+1)/A(n) → 1`; the seed
only perturbs `A(n)` by an additive constant `b − 1` (after index shift), never
the leading asymptotics. Thus the parabola `y = x²/2` is a *universal attractor*
independent of initial conditions — the exact opposite of Fibonacci, where the
seed can change which Lucas-type sequence (and which scalar multiple of `φⁿ`)
you land on.

**The key insight is** that quadratic growth *erases* initial conditions in the
leading order, whereas exponential growth *amplifies* them: the seed-independence
of the limit is the deepest structural difference between additive and
difference-driven recurrences.

**Why now?** Our induction already isolates the increment's contribution from the
seed; re-running it with symbolic `(a,b)` yields `A(n) = (n² − n)/2 + b` for
`n ≥ 1`, after which the two limit theorems transfer verbatim by `Tendsto.congr'`
— a clean universality statement built entirely from machinery we have validated.
