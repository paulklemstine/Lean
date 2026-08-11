# Computational evidence

All numbers below are **formally verified in Lean** (no scratch scripts, no
`native_decide`); each entry names the theorem that establishes it.  `θ_n(p)`
denotes the horizontal crossing probability of the `n × n` grid,
`bernProb p (crossingEvent n hn)`.

## 1. Exact crossing polynomials for small grids

| `n` | `θ_n(p)` | `θ_n(1/2)` | `θ_n'(p)` | `θ_n'(1/2)` | theorem |
|-----|----------|------------|-----------|-------------|---------|
| 1 | `p` | `1/2` | `1` | `1` | `crossing_bernProb_one`, `crossing_deriv_one` |
| 2 | `2p² − p⁴` | `7/16` | `4p − 4p³` | `3/2` | `crossing_bernProb_two`, `crossing_deriv_two` |

These agree with the enumerated values quoted in Conjectures 1 and 2 of the
previous cycle (`θ_1(1/2) = 1/2`, `θ_2(1/2) = 7/16`, `θ_1'(1/2) = 1`,
`θ_2'(1/2) = 3/2`), which are thereby confirmed rather than merely enumerated.

Derived, also verified:

* `θ_2(1/2) = 7/16 < 1/2` — `crossing_two_half_lt_one_half`
  (the self-duality defect of Conjecture 2 at `n = 2`);
* `θ_2(1/2) < θ_1(1/2)` — `crossing_two_half_lt_crossing_one_half`
  (the first step of the conjectured decay);
* `θ_1'(1/2) = 1 < 3/2 = θ_2'(1/2) ≤ 2` — `crossing_deriv_one_half_lt_two`
  (the first instance of Conjecture 1, both halves);
* `θ_n'(1/2) ≤ n` for **every** `n ≥ 1` — `crossing_deriv_half_le`
  (the upper half of Conjecture 1 in full generality).

The `n = 2` polynomial is obtained structurally, not by enumeration: a grid walk
that raises its row index past `r` must use a vertical edge
(`gridWalk_vertical_pair`), so on the `2 × 2` grid a crossing exists exactly
when one of the two columns is fully open; inclusion–exclusion with the cylinder
formula `bernProb_allOpenEvent` (`P_p(all sites of S open) = p^{|S|}`) gives
`2p² − p⁴`.

## 2. Sharpness tests for the BK inequality

The BK inequality proved this cycle is `bernProb p (A □ B) ≤ P(A)·P(B)`.  Two
extreme cases were checked formally:

| test | value of `P(A □ B)` | value of `P(A)P(B)` | verdict | theorem |
|------|--------------------|---------------------|---------|---------|
| `A = univ`, `B` increasing | `P(B)` | `P(B)` | equality — bound attained | `bernProb_bk_eq_univ_left` |
| `A = B = {η \| η v = true}` | `0` | `p²` | strict — bound not attained | `bernProb_bk_strict_openSite` |
| `A = {η \| η u}`, `B = {η \| η v}`, `u ≠ v` | `p²` | `p²` | equality | `disjointOccur_openSite_of_ne`, `bernProb_two_openSites` |

The last line is a genuine consequence of BK *and* Harris together: Harris gives
`p² ≤ P(both open)` and BK gives `P(both open) = P(A □ B) ≤ p²`, so the two
matching bounds force `P(both sites open) = p²`.

## 3. Counterexample hunt for the bond–site domination (Conjecture 5)

No counterexample exists: the domination was found to hold *pointwise in the
configuration*, not merely in probability
(`bondConnected_of_siteConnected_lineGraphSym2`), which forbids any
counterexample on any graph.  The converse inclusion, however, fails:

| graph | configuration | line-graph site event | bond event | theorem |
|-------|---------------|-----------------------|-----------|---------|
| triangle `K₃` | `s(0,1)` closed, `s(0,2)`, `s(1,2)` open | false | true | `triangleGap_not_siteConnected`, `triangleGap_bondConnected` |

Hence the domination is strict already on `K₃` for every `p ∈ (0,1)`
(`bernProb_site_lineGraph_lt_bond_triangle`).

## 4. Pivotality test for the strict Harris conjecture (Conjecture 3)

For the strictness of `crossing_harris_open_site` the relevant quantity is the
pivotal probability of a site.  The witness configuration used is the *column
configuration* `columnConfig c` opening exactly the sites of one column; closing
the site `v = (i₀, c)` breaks it, because a walk confined to column `c` changes
its row index by exactly one at each step and so cannot jump over row `i₀`
(`gridWalk_column_row_invariant`).  Therefore every site of every `n × n` grid
is pivotal (`crossingEvent_pivotalSet_nonempty`), and the exact defect formula

`P(crossing ∩ {v open}) − p·θ_n(p) = p(1−p)·P(v pivotal)`

(`crossing_harris_open_site_defect`) makes the strictness immediate for all
`p ∈ (0,1)`.  The conjectured *corner-maximality* of the defect is **not**
resolved here; the defect formula reduces it to the statement that the pivotal
probability is maximal at a corner, which is recorded as a conjecture in
`FUTURE_DIRECTIONS.md`.

## 5. The BK row bound against the known crossing values

The sandwich `p^n ≤ θ_n(p) ≤ (1 − (1−p)^n)^n` (`crossing_bernProb_sandwich`) is
formally proved for all `n ≥ 1` and all `p ∈ [0,1]`.  At `p = 1/2` it reads
`2^{-n} ≤ θ_n(1/2) ≤ (1 − 2^{-n})^n` (`crossing_bernProb_half_sandwich`).
Evaluating both sides:

| `n` | lower bound `2^{-n}` | `θ_n(1/2)` | upper bound `(1 − 2^{-n})^n` |
|-----|----------------------|------------|------------------------------|
| 1 | `1/2` | `1/2` (proved) | `1/2` — **both bounds sharp** |
| 2 | `1/4` | `7/16 = 0.4375` (proved) | `9/16 = 0.5625` |
| 3 | `1/8` | `197/512 ≈ 0.385` (enumerated in the previous cycle; *not* verified here) | `343/512 ≈ 0.670` |
| 4 | `1/16` | — | `(15/16)^4 ≈ 0.773` |

So the bound is an equality at `n = 1` (`crossing_row_bound_sharp_one`) and
strict at `n = 2` for every `p ∈ (0,1)` (`crossing_row_bound_strict_two`,
the gap being exactly `2p²(1−p)²`).  The table also shows the limitation of the
row decomposition: the upper bound *increases* with `n`, so it proves
`θ_n(p) < 1` (`crossing_bernProb_lt_one`) but cannot prove the conjectured decay
of `θ_n(1/2)`; that requires a decomposition into disjoint *crossings* rather
than into rows, which is why Conjecture C of `FUTURE_DIRECTIONS.md` is stated
the way it is.

## 6. A refuted conjecture: the naive doubling bound

The tempting BK consequence `θ_{2n}(p) ≤ θ_n(p)²` is **false**, and the
refutation is a formally proved inequality rather than an enumeration:

| `n` | `θ_n(p)²` | `θ_{2n}(p)` | at `p = 1/2` | verdict | theorem |
|-----|-----------|-------------|--------------|---------|---------|
| 1 | `p²` | `2p² − p⁴` | `1/4 < 7/16` | refuted for every `p ∈ (0,1)` | `crossing_sq_one_lt_two`, `crossing_sq_one_half_lt_two_half` |

The diagnosis is structural: a top-to-bottom crossing of the `2n × 2n` grid does
split into two crossings on disjoint site sets, but of the two `2n × n` half
rectangles, which are wider — and therefore easier to cross — than the `n × n`
grid.  Conjecture C of `FUTURE_DIRECTIONS.md` has been restated accordingly in
terms of band crossings, and its multiplicative half is now a theorem:
`bernProb_bandEvent_le_prod` gives
`P(band [a,b] crossed) ≤ P(band [a,k] crossed) · P(band [k+1,b] crossed)` for
every interior cut, hence
`θ_n(p) ≤ P(low band) · P(high band)` for every horizontal cut of the grid.
Iterating the cut one row at a time (`bernProb_bandEvent_le_pow`) reproduces the
row bound of section 5 — a degenerate band is a single row, of probability
`1 - (1-p)^n` (`bernProb_bandEvent_single`) — and the `2 × 2` instance reads
`2p² - p⁴ ≤ (2p - p²)²` (`crossing_two_le_band_prod_explicit`), i.e.
`0.4375 ≤ 0.5625` at `p = 1/2`.
