# Computational Evidence (round-72 #2/#3 formalization)

All numbers below were produced inside Lean 4 (`#eval`, exact integer arithmetic)
on the Berggren ternary tree rooted at `(3,4,5)` with the three standard
Barning–Hall matrices, using the same `step` maps that the Lean files formalize.

## 1. BFS starvation: level sizes and hypotenuse ceiling

`(number of nodes at depth d, max hypotenuse at depth d)`:

| d | nodes `3^d` | max hypotenuse |
|---|-------------|----------------|
| 0 | 1     | 5        |
| 1 | 3     | 29       |
| 2 | 9     | 169      |
| 3 | 27    | 985      |
| 4 | 81    | 5 741    |
| 5 | 243   | 33 461   |
| 6 | 729   | 195 025  |
| 7 | 2 187 | 1 136 689|

The observed per-level growth ratio of the maximum hypotenuse is exactly `5`
in this range (`985/169 = 5`, `5741/985 = 5`, …, integer division), comfortably
inside the proved ceiling `c' ≤ 7·c` (`TreeSieve.step_hyp_le`).  Since `7 ≤ 3²`,
the proved bound `V ≤ 5·n²` (`TreeSieve.bfs_starvation`) is consistent with the
data and is what makes the `50 000`-node BFS budget of `exp556` unable to reach
a cryptographic analysis window: `n = 5·10⁴` caps the hypotenuse at
`5n² = 1.25·10^10`.

## 2. Hypotenuse face: all prime factors are `1 mod 4`

Checked exhaustively for every node of depth `≤ 6` (1 093 nodes): every prime
factor of every hypotenuse satisfies `p % 4 = 1` — `true`.

Sample factorizations at depth 3:
`41 = 41`, `137 = 137`, `109 = 109`, `233 = 233`, `425 = 5·5·17`, `205 = 5·41`.

This is the exhaustively-checked instance of the proved theorem
`TreeSieveHyp.prime_dvd_hyp_one_mod_four`.

## 3. Zero winning tickets on `3 mod 4` moduli — and nonzero otherwise

* `N = 103 · 107` (both `≡ 3 mod 4`): for all `2 187` hypotenuses of depth `7`,
  `gcd(c, N) = 1` — `true`, i.e. **zero** tickets win.  Proved in general as
  `TreeSieveHyp.hypotenuse_face_blind_semiprime`.
* `N = 101 · 109` (both `≡ 1 mod 4`): `106` of the same `2 187` hypotenuses
  (4.8 %) share a factor with `N`.

The contrast shows the blindness result is a genuine arithmetic obstruction and
not an artefact of small samples.

## 4. Ascending-sweep first hit

For all `12` semiprimes `N = p·q` with `p ∈ {101, 103, 211, 307}`,
`q ∈ {311, 401, 503}`, the least `a ≥ 2` with `gcd(a, N) > 1` equals
`min(p, q)` in `12/12` cases (`some 101 = 101`, `some 103 = 103`,
`some 211 = 211`, `some 307 = 307`).  This is the `100 %` first-hit
concentration reported by `exp558`, and it is proved in general as
`MultiTarget.isLeast_hit_min`.

## 5. OEIS

The hypotenuse sequence along the "all-B" spine `5, 29, 169, 985, 5741, 33461,
195025, 1136689` is the NSW/Pell-related sequence of Pythagorean hypotenuses
(`a(n+1) = 6a(n) − a(n−1)`); the recurrence is visible in the table above and is
consistent with the growth bounds proved (`c < c' ≤ 7c`).  No new sequence is
claimed.

## 6. Norm-form blindness for `x² + 2y²` (new cycle)

Counterexample hunt for `NormFormBlindness.two_normForm_blind_semiprime`.  Over
all `2 203` coprime pairs `(a, b)` with `1 ≤ a, b ≤ 60` (Lean `#eval`):

| form | modulus `N` | prime classes | pairs with `gcd(value, N) > 1` |
|---|---|---|---|
| `a² + 2b²` | `65 = 5 · 13` | `5 % 8 = 5`, `13 % 8 = 5` (both inert) | **0** / 2203 |
| `a² + 2b²` | `33 = 3 · 11` | `3 % 8 = 3`, `11 % 8 = 3` (both split) | 1277 / 2203 |
| `a² + b²`  | `65 = 5 · 13` | `5 % 4 = 1`, `13 % 4 = 1` (both split) | 944 / 2203 |

Zero hits in the inert case, ~58 % and ~43 % hits in the split cases: the blind
set is a real arithmetic obstruction, and it moves when the form changes — `65`
is blind for `D = 2` yet richly hit for `D = 1`.  Both directions are proved:
`NormFormBlindness.two_normForm_blind_semiprime` and
`NormFormBlindness.blindness_classes_incomparable`.

## Blind moduli and the no-free-lunch prefix (evidence for `SearchOrderNoFreeLunch.lean`)

All counts below are Lean `#eval` computations over the stated finite ranges.

Hits of the form `x² + y²` against a semiprime, counted over all pairs
`1 ≤ a, b ≤ 80` with `gcd(a, b) = 1`, i.e. the number of pairs with
`gcd(a² + b², N) > 1`:

| `N` | factors | factor classes mod 4 | hits |
|-----|---------|----------------------|------|
| `77` | `7 · 11` | `3, 3` | **0** |
| `253` | `11 · 23` | `3, 3` | **0** |
| `65` | `5 · 13` | `1, 1` | 1686 |

The two zeros are the finite shadow of `SearchOrder.blindOne_semiprime`, and
`SearchOrder.infinite_blindOne_semiprimes` shows such moduli never run out.

No-free-lunch prefix: for the `N`-independent enumeration `f k = 2^k + 1`, the
first twelve probes are `[2, 3, 5, 9, 17, 33, 65, 129, 257, 513, 1025, 2049]`;
against `N = 101 · 103 = 10403` the number of probes with
`gcd(f k, N) > 1` is **0** — every probe misses, exactly as
`SearchOrder.enumeration_defeated` forces once both prime factors exceed the
prefix maximum.
