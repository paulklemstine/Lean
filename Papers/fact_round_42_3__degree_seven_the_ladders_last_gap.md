# Computational evidence — degree-7 rung of the abelian splitting-type ladder

All numbers below were produced by exact rational/float enumeration over the
finite models that the Lean file `Catalog/Physics/AbelianLadderDegreeSeven.lean`
formalises.  Every quantity that is asserted as a *result* is additionally
certified in Lean by a closed form plus an integer-witness bracket; the tables
here are the exploratory stage that fixed the statements.

## 1. The field and its Frobenius classes

`Gal(Q(ζ₂₉)/Q) ≅ (Z/29)ˣ ≅ C₂₈`.  The unique cyclic degree-7 subfield is the
fixed field of the order-4 subgroup, i.e. of the group of **seventh powers**.

Seventh powers mod 29 (equivalently the fourth roots of unity):

| set | elements | size | density |
|---|---|---|---|
| `((Z/29)ˣ)⁷ = {u : u⁴ = 1}` | `1, 12, 17, 28` | 4 | `4/28 = 1/7` |
| complement (residue degree 7) | the other 24 classes | 24 | `6/7` |

Sanity checks: `12² = 144 = 5·29 − 1 ≡ −1`, so `12⁴ ≡ 1`; `17 = −12`;
`2⁴ = 16 ≢ 1`, so `2` is inert of degree 7; `41 ≡ 12 (mod 29)` splits.
Both facts are formalised (`powDeg_29_two`, `powDeg_29_fortyone`).

## 2. Entropies (bits, base 2)

Uniform model on the 28 Frobenius classes, read-out `T = ` residue degree.

| quantity | closed form | value |
|---|---|---|
| `H(T)` | `log₂7 − (6/7)log₂6` | `0.5916727786` |
| `H(T ∣ coset class)` | — | `0` (full pinning) |
| `I(class ; T)` | `= H(T)` | `0.5916727786` |
| `I(quartic character ; T)` | `0` | `0` |

The report's `H(T) = 0.5917` (empirical `0.5914`) agrees with the exact value.

## 3. Semiprime split count: `Bin(2, 1/7)`

Enumerating the `49` exponent pairs `(a,b) ∈ (Z/7)²` (`a = dlog p mod 7`):

| split count `s` | count | law `Bin(2,1/7)·49` |
|---|---|---|
| 0 | 36 | `6² = 36` |
| 1 | 12 | `2·6 = 12` |
| 2 | 1 | `1` |

## 4. The three channels at degree 7 (side channel = `N mod 29`)

Read-outs, from finest to coarsest: the unordered type pair, its split count
`s ∈ {0,1,2}`, and the OR bit `1{s ≥ 1}`.

| channel | `H(read-out)` | `H(· ∣ N)` | mutual information |
|---|---|---|---|
| type pair `Ipair 7` | 0.9384475980 | 0.8243423129 | **0.1141052851** |
| split count `Isplit 7` | 0.9384475980 | 0.8243423129 | **0.1141052851** |
| OR bit `IOR 7 = G(7)` | 0.8346482852 | 0.8243423129 | **0.0103059723** |

Observations that became theorems:

* `Ipair 7 = Isplit 7` exactly — and the same holds at every prime degree
  (`Ipair_eq_Isplit_prime`): the split count is a sufficient statistic.
* The conditional entropies of the split count and of the OR bit coincide
  (`condEnt_or_eq_condEnt_split_prime`), so the two channels differ *only* by
  their unconditional entropies.
* `G(7) = 0.010306` reproduces the ledger anchor `0.0103` to `3·10⁻⁵`.
* `Is(7) = 0.114105` does **not** reproduce the reported `0.1161`; the gap is
  `0.00199`, two orders of magnitude larger than the rounding of the report.

For comparison, at the previously formalised degree-11 rung the same code gives
`Isplit 11 = 0.0518973` and `IOR 11 = 0.0039626`, consistent with the catalog's
`Isplit_eleven_bracket`.

## 5. Counterexample hunt / robustness

* Restricting the exponent model to *unordered* pairs changes the numbers
  (`Isplit = 0.1479`, `IOR = 0`), so the ordered-pair reading used by the
  catalog is the only one compatible with the reported `G(7) = 0.0103`.
* Replacing the `C₇`-exponent model by the full `(Z/29)ˣ`-model multiplies every
  fibre count by 4 and leaves all entropies unchanged (scale invariance,
  `binEnt_scale`), so no discrepancy can come from that choice.
* No prime degree gives `Isplit q = 0.1161`: the values are
  `Isplit 2 = 1.0000`, `Isplit 3 = 0.4739`, `Isplit 5 = 0.2027`,
  `Isplit 7 = 0.1141`, `Isplit 11 = 0.0519`, `Isplit 13 = 0.0386`
  (with `IOR` respectively `0.3113, 0.0728, 0.0215, 0.0103, 0.0040, 0.0028`).
  The sequence is strictly decreasing, and `0.1161` falls strictly between the
  degree-5 and degree-7 rungs.

## 6. Beyond degree 7: composite degrees and CRT additivity

Exact evaluation of the two channels for small `n` (`ordType n a = n / gcd(a,n)`):

| `n` | `Ipair n` | `Isplit n` | gap |
|---|---|---|---|
| 2 | 1.000000 | 1.000000 | 0 |
| 3 | 0.473851 | 0.473851 | 0 |
| 4 | 1.250000 | 0.294737 | 0.955263 |
| 5 | 0.202710 | 0.202710 | 0 |
| 6 | 1.473851 | 0.148683 | 1.325168 |
| 7 | 0.114105 | 0.114105 | 0 |
| 8 | 1.312500 | 0.090565 | 1.221935 |
| 9 | 0.526502 | 0.073775 | 0.452726 |
| 10 | 1.202710 | 0.061356 | 1.141354 |
| 11 | 0.051897 | 0.051897 | 0 |
| 12 | 1.723851 | 0.044517 | 1.679334 |

The gap vanishes exactly at the prime rungs.  The degree-4 row is certified in
Lean: `Ipair 4 = 5/4` and `Isplit 4 = 19/8 − (21/16) log₂ 3`.

Coprime factorisations (unordered type-pair channel only):

| `(m, n)` | `Ipair (mn)` | `Ipair m + Ipair n` |
|---|---|---|
| (2,3) | 1.473851 | 1.473851 |
| (3,4) | 1.723851 | 1.723851 |
| (3,5) | 0.676561 | 0.676561 |
| (4,5) | 1.452710 | 1.452710 |
| (2,9) | 1.526502 | 1.526502 |
| (5,7) | 0.316815 | 0.316815 |
| (7,8) | 1.426605 | 1.426605 |

Additivity holds in every tested case (Direction 3 of `FUTURE_DIRECTIONS.md`);
the split-count channel is visibly **not** additive (`Isplit 6 = 0.1487` versus
`Isplit 2 + Isplit 3 = 1.4739`).

## 7. Asymptotics of the two channels

| `q` | `q² Isplit q − log₂ q` | `q² G(q)` |
|---|---|---|
| 7 | 2.7838 | 0.5050 |
| 101 | 2.8782 | 0.4463 |
| 1009 | 2.8847 | 0.4431 |
| 10007 | 2.8853 | 0.4427 |
| 100003 | 2.8854 | 0.4427 |

The limits `2 log₂ e = 2.885390…` and `log₂ e − 1 = 0.442695…` are Direction 1.

## 8. Integer witnesses used by the Lean brackets

| bracket | witness inequalities |
|---|---|
| `0.5916 < H(T) < 0.5918` | `2⁸²⁸³·6¹²⁰⁰⁰ < 7¹⁴⁰⁰⁰ < 2⁸²⁸⁴·6¹²⁰⁰⁰` |
| `0.1140 < Is(7) < 0.1142` | `2¹⁶⁷¹⁸·3¹⁵⁶⁰⁰ < 7⁹⁸⁰⁰·5⁶⁰⁰⁰ < 2¹⁶⁷¹⁹·3¹⁵⁶⁰⁰` |
| `0.01027 < G(7) < 0.01035` | `2¹⁶³⁵¹·3¹⁹⁸⁰⁰·13³⁹⁰⁰ < 7¹⁴⁷⁰⁰·5⁹⁰⁰⁰ < 2¹⁶³⁵²·3¹⁹⁸⁰⁰·13³⁹⁰⁰` |

All three pairs were verified as exact integer comparisons before being handed
to `norm_num` inside the Lean proofs.
