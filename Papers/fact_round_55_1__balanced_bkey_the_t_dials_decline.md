# Computational evidence — BKEY-MIXED-ZONE (round-55 #1, exp 523 addendum)

All numbers below were produced with `#eval` inside this Lean project (exact rational
arithmetic, printed as `Float` where convenient), against the definitions of
`Catalog/Combinatorics/BKeyMixedZoneGridLaw.lean` and the round-54 catalog file
`Catalog/Cryptography/BalancedBKeyDialRobustness.lean`.  Everything that is *claimed* in the
`.lean` files is proved there; this note only records the exploratory computations that
guided the statements.

## 1. The tie-ceiling surface on the recorded 4 × 3 grid

`ceilingGrid b u = capFactor u * bitFactor b` is the exact Spearman ceiling
`ρ²(b,u) = (6/7)(1 − 8^{−u})(1 + 1/(4^b − 1))` of the capped statistic `T_u`.

| b \ u | 8 | 16 | 32 |
|---|---|---|---|
| 32 | 0.857143 | 0.857143 | 0.857143 |
| 44 | 0.857143 | 0.857143 | 0.857143 |
| 54 | 0.857143 | 0.857143 | 0.857143 |
| 64 | 0.857143 | 0.857143 | 0.857143 |

To six decimals every cell equals `6/7 = 0.857142…`.  Exactly:

* spread of the twelve cells
  `= 146407203246789033292638179993365540389 / 2865689484962554741575852613169182391473799168 ≈ 5.1·10⁻⁸`;
* one cap notch at `(b,u) = (54,8)`:
  `|colStep| = 4835703278458516698824704 / 108172851219475575594385340192085 ≈ 4.5·10⁻⁸`;
* one bitlen notch at `(b,u) = (32,16)`: `|rowStep| < 10⁻¹⁸`.

**Reading.**  The ceiling surface is flat to `~10⁻⁷` across the whole recorded envelope,
while the recorded `sp(T)` moves by `0.26`.  This is the computation behind
`ceiling_envelope_variation` (proved with the safe bound `10⁻⁵`).

## 2. Implied attenuation at the two recorded corners

With `sp = 0.79` at the top cell and `sp = 0.53` at the bottom cell, the attenuation
`a = sp² / ρ²` evaluates to

* `a(top)  = 0.79² / ceilingGrid 32 8  ≈ 0.728117`
* `a(bot)  = 0.53² / ceilingGrid 64 32 ≈ 0.327717`
* drop `≈ 0.400400`.

This is why `attenuation_drop_lower_bound` is stated with the (provable, slightly weaker)
threshold `2/5`.

## 3. A smooth separable model of the recorded grid

Geometric separable model `gm i j = 0.79 · 0.915^i · 0.935^j` on the `4 × 3` index grid
(`i` = bitlen index, `j` = cap index):

* corners: `gm 0 0 = 0.790000`, `gm 3 2 = 0.529071` (recorded: `0.79`, `0.53`);
* the five staircase notches: `[0.067150, 0.061442, 0.056220, 0.039337, 0.036780]`,
  summing to `0.260929` (recorded range `0.26`);
* largest notch `0.0672 < 0.09` (the recorded per-notch bound), and
  `max notch / mean notch = 0.0672 / 0.0522 ≈ 1.29`;
* every `2 × 2` minor vanishes exactly, e.g.
  `gm 0 0 * gm 3 2 − gm 0 2 * gm 3 0 = 0`.

**Reading.**  A monotone, gradual, rank-one grid reproduces the recorded envelope with all
notches comfortably inside the reported bound, and no notch carries more than ~26 % of the
total decline.  A cliff grid (one notch carrying the whole `0.26`) is excluded by the same
bound — see `cliffExample` and `cliffExample_violates_notch_bound`.

## 4. Counterexample hunt

* *Is the "no cliff" statement vacuous?*  No: `cliffExample b u = if b + u = 0 then 0.79
  else 0.53` is monotone in both dials, has exactly the recorded corners, and its first
  notch carries the entire `0.26` (`cliff_example_has_cliff`).  It fails the recorded
  per-notch bound `0.09`, which is precisely the discriminating datum.
* *Is the balance hypothesis needed for the ceiling floor?*  Yes — the round-54 catalog
  already exhibits the majority profile `[15,1]` with `ρ² = 3/17 < 0.53²`.
* *Could a convention choice fake the decline?*  A one-key move between tie classes changes
  `12·tieCorr` by exactly `3(m'² + m') − 3(m² + m)`; on a balanced profile of `N = 2^b` keys
  this moves `ρ²` by less than `4/N ≤ 4/2^32 < 10⁻⁹`.  No.

## 5. OEIS

The only integer sequence appearing is the block census `2^{b−1}, 2^{b−2}, …, 2^{b−u},
2^{b−u}` of the capped 2-adic valuation, i.e. powers of two (A000079); no new sequence is
produced, so no OEIS lookup is warranted.
