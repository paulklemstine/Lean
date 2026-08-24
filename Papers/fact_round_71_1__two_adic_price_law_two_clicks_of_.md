# Computational Evidence — Price tree 2-adic visibility ("two clicks, then sealed")

All numbers below were produced by `scripts/price_two_adic_check.py`, which reimplements
exactly the catalog definitions of `Catalog/Cryptography/Price2Adic/Tree.lean`
(`Valid`, `letterOf`, `parent`, `oddLeg (m,n) = m² − n²`, root `(2,1)`), and enumerates
every valid Euclid pair with `m < 400` (**32 335 nodes**).  Positions are counted from the
leaf: position `t` is `letterOf (parent^[t] (m,n))`.

## 1. Run laws (the mechanism)

For each node, with `v₂` the 2-adic valuation:

| claim | tested on | exceptions |
|---|---|---|
| `n` even ⇒ leading block is exactly `v₂(n)` letters `A`, then a non-`A` | all 32 335 nodes | **0** |
| `n` odd ⇒ leading block is exactly `v₂(m)` non-`A` letters, then an `A` | all 32 335 nodes | **0** |

In the odd-pair coordinates `p = m − n`, `q = m + n` (so `N = p·q`, `U = p + q = 2m`,
`V = q − p = 2n`) this is exactly "non-`A` runs decrement `v₂(U)` by one, the first `A`
lands at position `u₀ − 1`".
Formalized: `first_A_of_odd_snd`, `first_A_position_eq_v2`, `first_A_at_v2_U_sub_one`,
`A_run_of_even_snd`, `A_run_length_eq_v2`, `leading_run_dichotomy`
(`Catalog/Probability/PriceTwoAdicFirstA.lean`), on top of `letterAt_even_iff` and
`letterAt_odd_run` (`Catalog/Probability/PriceTwoAdicMechanism.lean`).

## 2. The two visible clicks: the `mod 8` dictionary

| `N mod 8` | (position 0 is `A`, position 1 is `A`) |
|---|---|
| 1 | (true, true) |
| 5 | (true, false) |
| 3 | (false, true) |
| 7 | (false, false) |

Checked on every node of depth ≥ 3 with `m < 400`: **0 exceptions**.  All four cells are
non-empty (witnesses used in Lean: `(17,16)`, `(27,2)`, `(26,3)`, `(28,3)`).
Formalized: `pos01_bijection_mod8`, `two_clicks_visible`, `pos01_attained`.

## 3. Counterexample hunt for a *third* click

Search over all same-odd-leg pairs of nodes with `m < 400` and depth ≥ 3:

* **6 124** pairs `(P, Q)` with `oddLeg P = oddLeg Q` but opposite `A`-ness at position 2.
* Smallest such odd leg: `N = 33`, nodes `(7,4)` and `(17,16)`.

So no function of `N` — a fortiori no function of any residue `N mod 2^k` — can read
position 2.  The explicit infinite family used in Lean is
`twinX y = (3y+5, 3y+4)`, `twinY y = (y+3, y)`, both with odd leg `6y + 9`:
checked for **all 1 994** values `9 ≤ y < 3000` with `3 ∤ y` — always valid, always equal
odd legs, always opposite position-2 `A`-ness (**0 exceptions**).
Formalized: `twin_pos2_split`, `pos2_split_in_every_class`, `no_oddLeg_classifier_pos2`,
`no_residue_classifier_pos2`, `twoAdic_capacity_exactly_two`.

## 4. Sealing at every position `t ≥ 2`

Family `bigX s = (2^(s+2)·w+1, 2^(s+2)·w)` with `w = 10·2^s − 3`, and
`bigY s = (12·2^s − 1, 2^(s+3))`:

| `s` | `t = s+2` | common odd leg `N` | valid | agree at all `u < t` | split at `t` | depths |
|---|---|---|---|---|---|---|
| 0 | 2 | 57 | yes | yes | yes | 4, 4 |
| 1 | 3 | 273 | yes | yes | yes | 7, 6 |
| 2 | 4 | 1185 | yes | yes | yes | 9, 8 |
| 3 | 5 | 4929 | yes | yes | yes | 11, 10 |
| 4 | 6 | 20097 | yes | yes | yes | 13, 12 |
| 5 | 7 | 81153 | yes | yes | yes | 15, 14 |
| 6 | 8 | 326145 | yes | yes | yes | 17, 16 |
| 7 | 9 | 1307649 | yes | yes | yes | 19, 18 |
| 8 | 10 | 5236737 | yes | yes | yes | 21, 20 |
| 9 | 11 | 20959233 | yes | yes | yes | 23, 22 |

The odd legs are `N(s) = 80·4^s − 24·2^s + 1` (57, 273, 1185, 4929, 20097, …); this
sequence does not appear to be an OEIS entry in its own right (it is the explicit
polynomial `80x² − 24x + 1` at `x = 2^s`), so no OEIS ID is claimed.
Formalized: `bigX_bigY_agree`, `bigX_bigY_split`, `pos_sealed_at`,
`no_oddLeg_classifier_pos`, `no_residue_classifier_pos`
(`Catalog/Probability/PriceTwoAdicAllPositions.lean`).

## 5. Position-2 closed form (`pos2Pred`)

```
pos2Pred m n :=
  if n % 4 = 0 then n % 8 = 0
  else if n % 2 = 0 then (m - n/2) % 4 = 2
  else if m % 4 = 2 then (m/2) % 4 = n % 4
  else m % 8 = 4
```
Checked against the true position-2 letter for every valid pair with `m < 400`,
`m + n > 27`: **0 exceptions**.  Note this is a condition on `(m, n) mod 16` — on the node,
not on the odd leg — consistent with §3.
Formalized: `pos2_A_iff`.

## 6. `B` rarity / the size rule

Letter counts on all 32 335 nodes with `m < 400`: `A` 16 182, `B` 8 076, `C` 8 077 — the
`A` half is the congruence `N ≡ 1 mod 4`, and inside `N ≡ 3 mod 4` the `B`/`C` split is the
size comparison `q < 3p` (`2n < m`), which here is almost exactly balanced.
Formalized: `letterOf_eq_B_iff_size`.

## Reproduction

```
python3 scripts/price_two_adic_check.py
```

## 7. The two-parameter twin family (continuation cycle)

The sealing family of `Probability/PriceTwoAdicSealingDensity.lean`

```
K        = 2^(s+1)·(4v² + 12v + 5) + (2v + 3)          (odd, ≥ 13)
famX s v = (2^(s+2)·K + 1, 2^(s+2)·K)
famY s v = (2^(s+2)·(2v+3) + 1, 2^(s+3))
famN s v = 2^(s+3)·K + 1
```

was checked for `s = 0…7` (i.e. positions `t = 2…9`) and `v = 0…30` — 248 instances, **0
exceptions**: both members are valid Euclid pairs, `oddLeg famX = oddLeg famY = famN`, both
have depth `> t`, their addresses are all-`A` at every position `u < t` and split at `t`,
and `famN s v` is strictly increasing in `v`.  The odd legs at `t = 2` are
`105, 377, 777, 1305, 1961, 2745, …`.
Formalized: `pos_sealed_at_family`, `sealed_oddLegs_infinite`,
`no_eventual_oddLeg_classifier`.

Reproduction: `python3 scripts/price_two_adic_family_check.py`.

## 8. Equal-depth splitting pairs

Among all valid pairs with `m < 600`, grouped by odd leg, the number of same-odd-leg pairs
of depth `> t` that agree at all positions below `t` and split at `t` is

| `t` | splitting pairs | of which equal depth |
|-----|-----------------|----------------------|
| 2   | 15 025          | 2 526                |
| 3   | 6 090           | 1 126                |
| 4   | 2 609           | 465                  |
| 5   | 1 109           | 206                  |

so roughly one splitting pair in six has *equal depth*; the smallest instance is
`N = 105` with the nodes `(13,8)` (address `ABAAA`) and `(53,52)` (address `CACAA`), both of
depth `5`.  The smallest equal-depth splitting pairs at the next positions are

| `t` | odd leg | nodes                | addresses          | depth |
|-----|---------|----------------------|--------------------|-------|
| `2` | `105`   | `(13,8)`, `(53,52)`  | `ABAAA`, `CACAA`   | `5`   |
| `3` | `105`   | `(13,8)`, `(19,16)`  | `ABAAA`, `BAAAA`   | `5`   |
| `4` | `315`   | `(22,13)`, `(26,19)` | `AABAC`, `BABAC`   | `5`   |
| `5` | `1485`  | `(41,14)`, `(73,62)` | `ABBABA`, `BBBACA` | `6`   |

These are the witnesses behind `pos2_split_equal_depth` and
`no_oddLeg_depth_classifier_le_five`: even the depth — which is *not* a function of `N`,
as the counts above show (only about one splitting pair in six has equal depth) — does not
unlock positions `2` to `5`.

Reproduction: `python3 scripts/price_two_adic_equal_depth_check.py`.

## 9. The equal-depth family at every position (continuation cycle 2)

Section 8 lists ad-hoc equal-depth witnesses for `t = 2…5`.  Scanning *all* odd legs below
`6 · 10^4` and all their coprime factorisations, the smallest equal-depth splitting pair at
each position turns out to follow a visible pattern:

| `t` | odd leg | nodes                      | common depth |
|-----|---------|----------------------------|--------------|
| `2` | `57`    | `(29,28)`, `(11,8)`        | `4`          |
| `3` | `105`   | `(13,8)`, `(19,16)`        | `5`          |
| `4` | `833`   | `(33,16)`, `(417,416)`     | `8`          |
| `5` | `2697`  | `(61,32)`, `(451,448)`     | `9`          |
| `6` | `12545` | `(129,64)`, `(6273,6272)`  | `12`         |
| `7` | `47625` | `(253,128)`, `(7939,7936)` | `13`         |

The rows `t = 4, 6` are `(2^(t+1)+1, 2^t)` paired with `((N+1)/2, (N−1)/2)`; reading off
their addresses gives `A^(t−1) B A^t` and `C A^(t−3) C A^(t+1)`, both of length `2t`.  That
is the family

```
dsX s = (2^(s+4) + 1, 2^(s+3)),   dsY s = (dsM s + 1, dsM s),
dsM s = 2^(s+4) · (3·2^(s+1) + 1),   t = s + 3
```

verified for `s = 0…30` with **0 exceptions**: valid nodes, equal odd legs
`dsN s = 2·dsM s + 1`, addresses exactly `A^(s+2) B A^(s+3)` and `C A^s C A^(s+4)` (hence
equal depth `2s + 6`), all-`A` below position `t`, and `B` versus `A` at position `t`.
Formalized without any numerical input as `dsX_dsY_split_equal_depth`,
`equal_depth_split_pair` and `no_oddLeg_depth_classifier` — the last one closes the
depth-augmented sealing conjecture at *every* position `t ≥ 2`.

Counts of (ordered) equal-depth splitting pairs among odd legs below `6 · 10^4`:
`535` at `t = 3`, `118` at `t = 4`, `26` at `t = 5` (below `3 · 10^5`: `3 207`, `719`,
`174`).  The proved family supplies one pair per position; whether there are infinitely
many *equal-depth* pairs at a fixed position is the sharpened open problem recorded in
`FUTURE_DIRECTIONS.md`.

Reproduction: `python3 scripts/price_two_adic_depth_family_check.py [bound]`.

### 9b. A free parameter at position `2`

Enumerating all Price words of length `≤ 18` with at most three non-`A` letters and
grouping them by (odd leg, length) exhibits, at position `2`, a one-parameter family of
equal-length pairs:

| `j` | `C A^j C A^2` | `B A^(j+3)`  | odd leg | depth |
|-----|---------------|--------------|---------|-------|
| `0` | `(29,28)`     | `(11,8)`     | `57`    | `4`   |
| `1` | `(53,52)`     | `(19,16)`    | `105`   | `5`   |
| `2` | `(101,100)`   | `(35,32)`    | `201`   | `6`   |
| `3` | `(197,196)`   | `(67,64)`    | `393`   | `7`   |
| `4` | `(389,388)`   | `(131,128)`  | `777`   | `8`   |

with common odd leg `3·2^(j+4) + 9` and valuations exactly `2` and `j + 3`.  Formalized as
`edX_edY_split_equal_depth`, `equal_depth_sealed_oddLegs_pos2_infinite` and
`no_eventual_oddLeg_depth_classifier_pos2`.  The match works because the first shape
contributes the constant `2^(t+1) + 1` and the second the constant `9`, which agree exactly
at `t = 2`; for `t ≥ 3` the same enumeration finds only the rigid family of section 9 plus
irregular sporadic partners, which is why infinitude at `t ≥ 3` is left open.
