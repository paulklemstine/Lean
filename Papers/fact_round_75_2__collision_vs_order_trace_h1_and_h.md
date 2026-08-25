# Computational evidence — ECM stage-1 firing trace (exp 570 / paper 218)

All numbers below were produced by executable Lean/Lean-core code (`#eval`,
integer sieve; no floating point beyond the final display divisions, which are
exact integer per-mille quotients). They are *exploratory*; the claims that are
verified formally are exactly the theorems in `Catalog/Novelty/Ecm*.lean`.

## 1. Setting

Stage 1 of ECM multiplies the starting point by
`K(B1) = ∏_{p ≤ B1} p^{⌊log_p B1⌋}`, consuming schedule primes in increasing
order. `Catalog/Novelty/EcmStageOneTraceLaw.lean` proves the *trace law*: an
order `n` dividing `K(B1)` fires exactly when the schedule reaches `maxPF n`,
its largest prime factor. So the **normalized firing index** is

```
idx(n) = π(maxPF n) / π(B1).
```

## 2. Firing-index statistics (uniform order in `(0, N]`, `B1 = N`)

Sieved smallest-prime-factor table, prefix prime counts, all `n ≤ N`:

| N     | median idx | mean idx | mass in final 20% | mass in first 20% |
|-------|-----------:|---------:|------------------:|------------------:|
| 10³   | 0.083      | 0.175    | 3.4%              | 73.0%             |
| 10⁴   | 0.034      | 0.121    | 2.4%              | 81.8%             |
| 10⁵   | 0.020      | 0.090    | 1.9%              | 86.3%             |
| 10⁶   | 0.005      | 0.071    | 1.5%              | 89.0%             |

Observations.

* The medians `0.083 … 0.005` bracket the measured medians of exp 570
  (`0.09` and `0.102` at `B1/p = 0.9`). The measured "hits fire near step zero"
  is the generic behaviour of `π(maxPF n)/π(N)`, not a curve-specific effect.
* The final-20% mass is nowhere near the 20% that the pre-registered uniform
  hypothesis H1 demands; it is already `3.4%` at `N = 10³` and decays.
* The decay matches the Mertens heuristic `tail(τ) ≈ log(1/(1−τ)) / log N`:
  `0.223/log 10⁶ = 0.016` vs measured `0.015`;
  `0.223/log 10⁵ = 0.019` vs measured `0.019`;
  `0.223/log 10⁴ = 0.024` vs measured `0.024`.

## 3. Counterexample hunt for the proved density bound

`late_tail_density_lt_one_fifth` claims: at `B1 = 100`, `y = 67`, fewer than
`2M/25 = 0.08 M` of the orders in `(0, M]` are divisible by a prime in
`(67, 100]`. Direct count at `M = 10⁴`:

```
#{n ≤ 10⁴ : ∃ prime p ∈ (67,100], p ∣ n} = 722      density 0.0722 < 0.08 ✓
```

No counterexample; the bound is tight to within 10%. The reciprocal sum that
drives it is
`1/71+1/73+1/79+1/83+1/89+1/97 = 0.07404 < 0.08`.

In the short range `M ≤ y²` the union bound is in fact an *equality* (no integer
below `67² = 4489` has two distinct prime factors above 67), which
`EcmTraceLateTailDecay.lateOrders_card_eq` proves and
`late_tail_exact_hundred` instantiates:

```
#lateOrders(4489, 100, 67) = ⌊4489/71⌋+⌊4489/73⌋+⌊4489/79⌋+⌊4489/83⌋+⌊4489/89⌋+⌊4489/97⌋
                           = 63+61+56+54+50+46 = 330      density 0.0735
```

So the late tail is genuinely nonzero — about a third of the 20% that
uniformity demands (`late_tail_sandwich_hundred`: `1/20 < 0.0735 < 1/5`).

## 4. Divisor-model arithmetic (`B1 = 100`)

Exponents in `K(100)`: `2⁶·3⁴·5²·7²·(11·13·…·97)`, so

```
τ(K(100))  = 7·5·3·3·2²¹ = 660 602 880
τ(K_67)    = 7·5·3·3·2¹⁵ =  10 321 920
ratio      = 64
```

i.e. a *uniform divisor* of `K(100)` fires in the last six of the 25 schedule
steps with probability `63/64 ≈ 98%` — the opposite of the measured trace. This
arithmetic is proved in general form in `EcmTraceDivisorModel.lean`
(`card_divisors_stageProd_split`, `divisor_model_hundred`).

## 5. Collision baseline at the measured operating point

With `B1/p = 0.125` and honest op count `ops = 2.59·B1`, `k/p = 0.32375`, so the
Bernoulli ceiling `1 − (1 − 1/p)^k ≤ k/p` gives at most `32.4%` per curve at
*every* bit length, against measured `65.0%` (bitlen 26) and `62.5%`
(bitlen 32). Sanity check of the ceiling at `p = 2^26` (numerically):
`1 − (1 − 2^-26)^(0.32375·2^26) = 0.2765 ≤ 0.32375` ✓.

## 6. Binomial likelihood of the empty tail (`0/55`)

```
(4/5)^55  = 4.7·10⁻⁶     (uniform H1)
(23/25)^55 = 1.02·10⁻²    (structural cap 2/25)
ratio      ≈ 2.2·10³
```

Formalized exactly (as rational inequalities) in
`EcmTraceDivisorModel.empty_tail_likelihood_ratio`.

## 7. OEIS

The step-index sequence `π(maxPF n)` for `n = 1, 2, …` is
`0, 1, 2, 1, 3, 2, 4, 1, 2, 3, 5, 2, 6, 4, 3, …`; the underlying largest-prime-
factor sequence `maxPF n` is **A006530** (`1, 2, 3, 2, 5, 3, 7, 2, 3, 5, 11, …`,
with `maxPF 1 = 1` there and `0` in our Lean convention). No separate OEIS entry
was located for the composed sequence `π(A006530(n))`.
