# Computational Evidence — Paper 131 (posterior filter = sham)

All numbers below come from an ad-hoc Python script (seed 20260821) and are **exploratory,
not formally verified**; the formally verified statements are the Lean theorems in
`Catalog/Cryptography/PosteriorFilter/`.

## 1. Flatness of the smaller-factor posterior on real semiprimes

200 000 random semiprimes `N = p q` with `30 < p < q ≤ 20000`, residue modulus `m`.
Statistic: `max_{c,r} |P(p ≡ r | N ≡ c) − 1/φ(m)|`.

| m  | φ(m) | max deviation |
|----|------|---------------|
| 5  | 4    | 0.0069        |
| 7  | 6    | 0.0087        |
| 12 | 4    | 0.0088        |

Deviations are at sampling-noise level (cell sizes ≈ 10⁴, SD ≈ 0.004–0.006), consistent
with `posterior_flat` (barrier 2) — the exact statement holds in the uniform residue model.

## 2. Keep-rate law in the exact group model `(ZMod m)ˣ × (ZMod m)ˣ`

Keep size `k = φ(m) − 1`; "real" = fixed ranked keep-set, "sham" = random keep-set per public residue.

| m  | n=φ(m) | hits real | hits sham | n·k | failure rate | 1/n    |
|----|--------|-----------|-----------|-----|--------------|--------|
| 5  | 4      | 12        | 12        | 12  | 0.25         | 0.25   |
| 7  | 6      | 30        | 30        | 30  | 0.1667       | 0.1667 |
| 8  | 4      | 12        | 12        | 12  | 0.25         | 0.25   |
| 12 | 4      | 12        | 12        | 12  | 0.25         | 0.25   |

Exactly as proved in `hitCount_eq_sum_card`, `real_filter_eq_sham`, `noFallback_failure_eq`.

## 3. Counterexample hunt

* Ordered target (smaller factor): no keep-policy found that deviates from `∑_c |K c|` — none can (theorem).
* Unordered target ("either factor kept"): deviation found immediately, e.g. on the cyclic
  group of order 3 the policies `c ↦ {1}` and `c ↦ {c²}` score 5 vs 3 — formalized as
  `symHit_real_ne_sham`. This is the boundary of the sham law.

No OEIS sequence is relevant (the quantities are closed-form: `n·k`, `n²(n+1)/2`).
