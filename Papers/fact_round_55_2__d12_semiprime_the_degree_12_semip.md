# Computational evidence — degree-12 semiprime splitting-type channel

All numbers below were produced by direct enumeration (exact rational / IEEE
double arithmetic) *before* the Lean formalisation, and every claim that the
formal files make has since been proved in Lean 4 with no `sorry` and no
`native_decide`.  The Lean statements are the authoritative versions; this file
records the exploratory pass that suggested them.

Setting: for a prime `f` the Galois group of `Q(ζ_f)/Q` is cyclic of order
`n = f − 1`.  Writing an unramified prime as `g^a`, its splitting type is
`T = ordType n a = n / gcd(a, n)`.  A semiprime `N = p q` is modelled by an
exponent pair `(a, b) ∈ (Z/n)²`; the read-outs are the unordered type pair
`{T(p), T(q)}`, its split count, and the residue `N mod f` (i.e. `a + b mod n`).
`n = 12` is the degree-12 arm (`f = 13`).

## 1. The exact enumeration law for type pairs

Enumerating the `144` exponent pairs at `n = 12` and grouping by unordered type
pair gives the multiplicities

| `{d,e}` | 1,1 | 1,2 | 1,3 | 1,4 | 1,6 | 1,12 | 2,2 | 2,3 | 2,4 | 2,6 | 2,12 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| count | 1 | 2 | 4 | 4 | 4 | 8 | 1 | 4 | 4 | 4 | 8 |

| `{d,e}` | 3,3 | 3,4 | 3,6 | 3,12 | 4,4 | 4,6 | 4,12 | 6,6 | 6,12 | 12,12 |
|---|---|---|---|---|---|---|---|---|---|---|
| count | 4 | 8 | 8 | 16 | 4 | 8 | 16 | 4 | 16 | 16 |

Every entry equals `φ(d)φ(e)` when `d = e` and `2φ(d)φ(e)` when `d ≠ e`; the
counts sum to `144 = 12²`.  This is exactly `CyclicTypeChannel.pairCount`, and
the identity is now the theorem `card_typePair` (all `n`).

Consequently `∑ c log₂ c = 450` and

  `H(Π) = log₂ 144 − 450/144 = 7/8 + 2 log₂ 3 ≈ 2.8750`,

reproducing the independently enumerated `pairEntropy_val_12`.  The same
computation at `n = 6` gives `∑ c log₂ c = 74` and `H(Π) = −1/18 + 2 log₂ 3`,
again matching.

## 2. The symmetrization-defect law

For `n = 2 … 20` we computed `H(T)`, `H(Π)`, `S(n) = ∑_{d ∣ n} φ(d)²` and
`#asym(n) = n² − S(n)`, and tested `H(Π) = 2H(T) − #asym(n)/n²`:

```
 n      H(T)      H(Pi)   sum phi^2   #asym   law residual
 2  1.000000  1.500000        2          2     0.0e+00
 3  0.918296  1.392147        5          4     0.0e+00
 4  1.500000  2.375000        6         10     0.0e+00
 5  0.721928  1.123856       17          8     0.0e+00
 6  1.918296  3.114369       10         26     0.0e+00
 7  0.591673  0.938448       37         12     0.0e+00
 8  1.750000  2.843750       22         42     0.0e+00
 9  1.224394  1.954962       41         40     0.0e+00
10  1.721928  2.783856       34         66     0.0e+00
11  0.439497  0.713705      101         20     0.0e+00
12  2.418296  4.044925       30        114     0.0e+00
13  0.391244  0.640475      145         24     0.0e+00
14  1.591673  2.560897       74        122     0.0e+00
15  1.640224  2.658226       85        140     0.0e+00
16  1.875000  3.085938       86        170     0.0e+00
17  0.322757  0.534787      257         32     0.0e+00
18  2.224394  3.701875       82        242     0.0e+00
19  0.297472  0.495222      325         36     0.0e+00
20  2.221928  3.698856      102        298     0.0e+00
```

(residual = `2H(T) − #asym/n² − H(Π)`, rounded to 12 decimals; all zero).

This is the conjecture that became `pairEntropy_symmetrization_law`, now proved
for **all** `n > 0`.  The degree-12 instance is
`7/8 + 2log₂3 = 2(5/6 + log₂3) − 114/144`, defect `19/24`.

The sequence `S(n) = ∑_{d ∣ n} φ(d)²` begins
`1, 2, 5, 6, 17, 10, 37, 22, 41, 34, 101, 30, …`.  We did not attempt an OEIS
lookup (no network access during this run), so no OEIS identifier is claimed.

## 3. The which-factor wall

Grouping the `114` asymmetric exponent pairs at `n = 12` by the read-out
`(unordered type pair, N mod 13)`, every fibre is closed under swapping the two
exponents and every fibre splits evenly between the two values of the
which-factor bit.  Measured mutual information: `0.0000` bits (the reported
`0.0002` is sampling noise).  The formal statement proves the value is exactly
`0`, for every `n ≥ 2` and every symmetric read-out, while the label itself
carries exactly `1` bit.

## 4. The split-count channel

Split-count profiles at `n = 12` (fibres of `N mod 13`, in exponent
coordinates):

* residue `0`: profile `(1, 11)`;
* residues `1 … 11`: profile `(2, 10)` — identical for all eleven classes.

Global profile: `(121, 22, 1)` for split counts `s = 0, 1, 2`.  Hence

  `I_split(12) = 199/72 + log₂3 + (55/72)log₂5 − (253/144)log₂11 = 0.0445173…`

Numerically enumerated: `0.044517`.  Comparison across orders:

| n | 4 | 6 | 10 | 12 | 16 |
|---|---|---|---|---|---|
| `I_split(n)` | 0.294737 | 0.148683 | 0.061356 | 0.044517 | 0.026720 |
| `I_pair(n)`  | 1.25 | 1.4739 | 1.2027 | 1.7239 | 1.3281 |

So the split count keeps only `2.6 %` of the degree-12 pair-channel
information; the formal file proves the weaker but rigorous bounds
`0 < I_split(12) < 1/8` and `I_split(12) < I_pair(12)/10`.

## 5. Counterexample hunt

* `H(Π) = 2H(T) − #asym/n²` was tested for `2 ≤ n ≤ 20`: no counterexample.
* `I_split(n) < I_pair(n)` was tested for `n ∈ {4,6,10,12,16}`: no
  counterexample.
* The which-factor mutual information was tested for `2 ≤ n ≤ 16` with the
  read-out `(typePair, prodRes)`: always `0` to machine precision.
* `I_split(n) > 0` holds on the tested range, but `I_split` decreases quickly;
  we found no `n ≤ 16` with `I_split(n) = 0`, and the general question is left
  open in `FUTURE_DIRECTIONS.md`.
