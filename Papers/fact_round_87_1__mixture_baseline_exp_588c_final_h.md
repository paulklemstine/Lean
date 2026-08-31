# Computational evidence — divisibility cells of `v = j² − N` as a rate dial

All statements marked **[proved]** are Lean theorems in `Catalog/Shared/MixtureRateDial*.lean`
(compiling, no `sorry`).  Statements marked **[exploratory]** are numerical
observations only; they motivated the theorems but are not themselves verified
artifacts.

## 1. Small-case cell populations (Lean `#eval`, `N = 8051 = 83 · 97`)

Cells are the divisibility patterns `(2|v, 3|v, 5|v, 7|v)` of `v = j² − N`,
counted over a window of `210 = 2·3·5·7` consecutive `j`.

| cell `(2,3,5,7)` | count, window at `a = 0` | at `a = 1234` | at `a = −77777` |
|---|---|---|---|
| (F,F,F,F) | 45 | 45 | 45 |
| (F,F,F,T) | 18 | 18 | 18 |
| (F,F,T,F) | 30 | 30 | 30 |
| (F,F,T,T) | 12 | 12 | 12 |
| (T,F,F,F) | 45 | 45 | 45 |
| (T,F,F,T) | 18 | 18 | 18 |
| (T,F,T,F) | 30 | 30 | 30 |
| (T,F,T,T) | 12 | 12 | 12 |
| all cells with `3 ∣ v` | 0 | 0 | 0 |

Total `= 210`.  Composition is *identical* at every window position.
**[proved]** `RateDial.windowCount_const` — exactly this, for every `N`, every
window position, every cell.

Two structural facts are visible in the table and both are theorems:

* the `2|v` bit splits the window exactly in half (`105 : 105`), because for odd
  `N` we have `2 ∣ j² − N ↔ j` odd — **[proved]** `RateDial.two_dvd_iff_odd`;
* the `3|v` cells are *empty* for `N = 8051` because `8051 ≡ 2 (mod 3)` is a
  quadratic non-residue: the rate dial is genuinely turned (rate `0` instead of
  the generic `1/3`) — **[proved]** `RateDial.sqCount_three`, `..._five`,
  `..._seven`.

A second modulus check, `N = 1000003 ≡ 1 (mod 3)`: now the `3|v` cells carry
`50 + 20 = 70` of the `210` (rate `2/3` of a third), and the `5|v` cells are
empty (`1000003 ≡ 3 mod 5`, a non-residue).  Same phenomenon, different dial
setting — and again identical at every window position.

## 2. Counterexample hunt: does composition ever drift with position?

**[exploratory]** For `N = 8051` and window starts `a ∈ [0, 400)`:

| window length `L` | `L mod 210` | max cell-count spread over `a` |
|---|---|---|
| 210 | 0 | **0** |
| 1000 | 160 | 3 |
| 4096 | 106 | 3 |

No drift at all when `210 ∣ L`; a bounded remainder effect otherwise.  Relative
spread per cell at `L = 4096`: `0.34 %` – `0.85 %`, the same order as the
`0.269 %` maximal cell drift reported by the experiment.

**[proved]** `RateDial.count_drift_le_mod`: for any `m`-periodic classifier the
populations of two windows of length `L` differ by at most `L % m < m`, i.e. a
relative drift below `m / L`.  So the hunt for a drifting divisibility cell is
provably futile: the drift is a truncation artefact of the window, of size
`O(m/L)`, and it shrinks as the window grows.

## 3. Parity spot check

`#eval` over `j ∈ [0, 40)` with `N = 8051`: every `j` with `2 ∣ j² − N` is odd
(`j % 2 = 1` in all 20 cases).  **[proved]** `RateDial.two_dvd_iff_odd`.

## 4. What the numbers cannot decide, and the theorem that does

No finite table can rule out a divisibility mixture absorbing the excess at some
unexamined position.  The Lean development replaces the search:

* the cell label is `210`-periodic **[proved]** (`cell_periodic`);
* therefore composition is exactly position-independent **[proved]**
  (`windowCount_const`);
* therefore the whole 16-parameter mixture family collapses to the ray `{K · B}`
  **[proved]** (`mixture_family_eq_ray`);
* therefore the residual's relative mid-window excess is *unchanged* — removal is
  exactly `0 %` **[proved]** (`divisibility_mixture_excess_survives`,
  `removal_eq_zero`);
* and, allowing the measured `0.269 %` drift, the excess `0.1774` can be reduced
  to at worst `0.1710`, still far above the registered bar `2·SE = 0.0864`
  **[proved]** (`H0_excess_survives_measured`, `H0_excess_beats_bar`).

## 5. OEIS

The cell-population vector `(45, 18, 30, 12, …)` for a fixed `N` is a
CRT product of per-prime root counts (`1` or `2` roots mod `p`, `0` for
non-residues) and is not an interesting standalone integer sequence; no OEIS
match was sought or is claimed.
