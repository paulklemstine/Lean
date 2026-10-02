# Computational evidence — COMPOSITE-DIAL (paper 125)

All tables below are checked by `decide` in `Catalog/Tropical/CompositeDialLabNotes.lean`.
The computation works directly on natural numbers, with no CRT model: units `a mod N` are
listed explicitly, Legendre bits come from searching for square roots, and the label is the
parity of the number of prime factors `p | N` for which `a` is a non-residue mod `p`. That
label is the Jacobi symbol in additive notation.

## 1. Small cases

| modulus | observable | table of counts `#{a : obs(a) = r, label(a) = b}` | conclusion |
|---|---|---|---|
| `15 = 3·5` | `a mod 3` | `(1,0),(1,1),(2,0),(2,1)` → `2,2,2,2` | flat, so the component carries 0 bits |
| `15 = 3·5` | `a mod 5` | `r = 1..4`, `b = 0,1` → all `1` | flat, so 0 bits |
| `105 = 3·5·7` | `a mod 15` (a **pair** of components) | for all 15 classes, count(b=0) = count(b=1) ∈ {0,3} | flat, so 0 bits |
| `105` | label alone | `24 / 24` | fair bit: the whole carries exactly 1 bit |

Theorems `semiprime15_mod3_flat`, `semiprime15_mod5_flat`, `triprime105_pair_flat` and
`triprime105_label_fair` check these tables.

## 2. OEIS

The only sequence here is `#units = φ(N)` (A000010). No new sequence appears.

## 3. Counterexample hunt

- We found no counterexample to "each proper sub-family of prime residues is blind" for
  `N = 15` and `N = 105`. The general theorem `proper_statistic_blind` covers every
  squarefree product of odd primes.
- **Boundary found (and proved):** with a single prime (`k = 1`) the component *is* the
  whole and carries the full `log |A|` (`single_component_not_emergent`,
  `component_blind_iff`). So emergence needs at least two irreducible parts.
- **Boundary (hypothesis needed):** the prime 2 is excluded (`P i ≠ 2`). Modulo 2 every
  unit is a square, so the Legendre bit is constant and the label-swap construction fails.

## 4. On the measured 1.8170-bit read

We do not reproduce the empirical value 1.8170. For the Jacobi label the exact value we
proved is **1 bit** (`full_residue_bits`). For a sum label in a finite abelian group `A` it
is `log₂ |A|` (`whole_carries_log_card`). The capacity bound we proved
(`mutualInfo_le_log_card`) gives a hard consequence (`four_types_of_read`): any composite
label that carries ≥ 1.8170 bits must have **at least 4 types**, because `log₂ 3 < 1.6`.
