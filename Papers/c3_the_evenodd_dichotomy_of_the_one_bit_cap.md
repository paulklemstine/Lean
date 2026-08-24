# Computational evidence for C3 (even/odd dichotomy of the one-bit cap)

All numbers below come from a brute-force evaluation of the *type-pair channel*

```
Ipair n = I( {T(p),T(q)} ; N mod f ),   T(a) = ordType n a = n / gcd(a,n),
```

over the full box `range n ×ˢ range n` (script: `evidence.py`, exact counting +
double-precision logs).

## 1. Small cases

| n | Ipair n | n | Ipair n |
|---|---------|---|---------|
| 2 | 1.00000000 | 14 | 1.11410529 |
| 3 | 0.47385139 | 15 | 0.67656148 |
| 4 | 1.25000000 | 16 | 1.32812500 |
| 5 | 0.20271010 | 17 | 0.02398098 |
| 6 | 1.47385139 | 18 | 1.52650154 |
| 7 | 0.11410529 | 19 | 0.01965488 |
| 8 | 1.31250000 | 20 | 1.45271010 |
| 9 | 0.52650154 | 21 | 0.58795667 |
| 10 | 1.20271010 | 22 | 1.05189732 |
| 11 | 0.05189732 | 23 | 0.01394635 |
| 12 | 1.72385139 | 24 | 1.78635139 |

Every even `n` in the range is `≥ 1` (with equality exactly at `n = 2`) and every
odd `n ≤ 24` is `< 1`.  This is the evidence base for C3.

## 2. The discovered prime-power law

Brute force forced the following exact law, which then became
`Ipair_prime_power_closed_form`-style content of this cycle:

```
Ipair (q^k) = Ipair q · (1 + q^{-2} + q^{-4} + … + q^{-2(k-1)})
            = Ipair q · (1 - q^{-2k}) / (1 - q^{-2}).
```

| q | k | brute force | law |
|---|---|-------------|-----|
| 2 | 1..4 | 1, 1.25, 1.3125, 1.328125 | 1, 5/4, 21/16, 85/64 |
| 3 | 1..3 | 0.47385139, 0.52650154, 0.53235156 | identical to 8 d.p. |
| 5 | 1,2 | 0.20271010, 0.21081850 | identical |

In particular `Ipair (2^k) = (4/3)(1 - 4^{-k})`, matching the catalogue values
`Ipair 2 = 1`, `Ipair 4 = 5/4`, `Ipair 16 = 85/64`, `Ipair 32 = 341/256`.

## 3. The two-sided envelope actually proved

The formal work proves the sandwich (`D` = upper, `LB` = lower)

```
LB(q,k) = (1-q^{-2k}) ((2q-1) log₂ q - 2(q-1) log₂(q-1)) / (q²-1)
        ≤ Ipair (q^k) ≤
D(q,k)  = (1-q^{-2k}) ( q² log₂ q/(q²-1) - log₂(q-1) )
```

| q | k | LB | Ipair | D |
|---|---|----|-------|---|
| 2 | 1 | 0.750000 | 1.000000 | 1.000000 |
| 2 | 4 | 0.996094 | 1.328125 | 1.328125 |
| 3 | 1 | 0.436090 | 0.473851 | 0.696074 |
| 3 | 3 | 0.489929 | 0.532352 | 0.782009 |
| 5 | 1 | 0.195894 | 0.202710 | 0.401928 |
| 7 | 1 | 0.111756 | 0.114105 | 0.275147 |

`D` is *exactly tight for q = 2* (the two-state fork saturates the fibre bound),
which is what makes the even side of the dichotomy sharp; `sup_k D(q,k) < 0.79`
for every odd `q`, which is the odd side.

## 4. Counterexample hunt for the *global* C3 statement

C3 asserts `Ipair n > 1 ⟺ n even`.  The `⟸` direction is true (and proved here).
The `⟹` direction is **false**.  Because of CRT additivity
(`Ipair_mul_of_coprime`) the channel is a sum over primary components, and the
sup of the odd primary contributions is

```
Σ_{q odd prime} sup_k Ipair(q^k) = Σ_{q odd} Ipair(q)·q²/(q²-1) ≈ 1.0655…
```

Partial sums (odd primes in increasing order):

| q | G(q) = sup_k Ipair(q^k) | partial sum |
|---|--------------------------|-------------|
| 3 | 0.533083 | 0.533083 |
| 5 | 0.211156 | 0.744239 |
| 7 | 0.116482 | 0.860722 |
| 11 | 0.052330 | 0.913051 |
| 13 | 0.038872 | 0.951924 |
| 17 | 0.024064 | 0.975988 |
| 19 | 0.019709 | 0.995697 |
| 23 | 0.013973 | **1.009670** |

So the partial sum first exceeds `1` at the **eighth** odd prime.  Hence:

* every odd `n` with at most 7 distinct prime factors satisfies `Ipair n < 1`;
* odd `n` above the cap exist, and the smallest number of distinct prime factors
  for such an `n` is exactly 8.

The catalogue already contains one explicit odd witness
(`CyclicTypeChannelOdd.one_lt_Ipair_odd_order`, `n = 300840735195 = 3²·5·7·11·13·17·19·23·29·31`).
This is a genuine refutation of C3 as literally stated, and the present cycle
replaces C3 by its correct primary-component form.

## 5. CRT cross-check

`Ipair (mn) = Ipair m + Ipair n` for coprime `m, n` was re-verified numerically
for `(m,n) ∈ {(3,4),(3,5),(4,9),(5,7),(2,9)}` — agreement to 8 d.p., consistent
with `CyclicTypeChannelCRTLaw.Ipair_mul_of_coprime`.
