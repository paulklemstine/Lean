# Computational Evidence

Target: the descendant limit law `|D_n| / n^{1/d} ⟶ Gamma(d, 1)` for random recursive
`d`-DAGs (Janson 2023). The formalization proves the exact facts that underlie this law:
the moments of the Gamma`(d,1)` target and the `n^{1/d}` growth of the mean-growth product
`P_n(a) = ∏_{k=1}^n (1 + a/k)` with `a = 1/d`.

## 1. Moments of Gamma(d, 1)

The `k`-th moment of the limit law is `m_k = Γ(d+k)/Γ(d) = ∏_{i=0}^{k-1}(d+i)` (rising
factorial). Small cases:

| k | m_k = Γ(d+k)/Γ(d) | value at d=2 | value at d=3 |
|---|-------------------|--------------|--------------|
| 0 | 1                 | 1            | 1            |
| 1 | d                 | 2            | 3            |
| 2 | d(d+1)            | 6            | 12           |
| 3 | d(d+1)(d+2)       | 24           | 60           |
| 4 | d(d+1)(d+2)(d+3)  | 120          | 360          |

Mean `= m_1 = d`; variance `= m_2 - m_1^2 = d(d+1) - d^2 = d`. Both are formalized
(`gammaMoment_one`, `gamma_variance`). For integer `d` the moments are the ratios of
factorials `(d+k-1)!/(d-1)!`, e.g. at `d=2` the sequence `1, 2, 6, 24, 120, …` is
`(k+1)!` (OEIS A000142 shifted); at `d=3` it is `1, 3, 12, 60, 360, …` = `(k+2)!/2`.

The moment recurrence `m_{k+1} = (d+k) m_k` (formalized as `gammaMoment_succ`) is the
identity a method-of-moments proof of the limit law relies on.

## 2. The mean-growth product and n^{1/d} scaling

`P_n(a) = ∏_{k=1}^n (1 + a/k)`. Since `log P_n(a) = Σ_{k=1}^n log(1 + a/k) ≈ a·Σ 1/k ≈
a·log n`, we expect `P_n(a) ≈ C · n^a`. Numerically, with `a = 1/2` (i.e. `d = 2`):

| n     | P_n(1/2)  | n^{1/2}  | P_n(1/2)/n^{1/2} |
|-------|-----------|----------|------------------|
| 1     | 1.5000    | 1.0000   | 1.50000          |
| 10    | 3.7001    | 3.1623   | 1.17009          |
| 100   | 11.326    | 10.000   | 1.13260          |
| 1000  | 35.696    | 31.623   | 1.12880          |
| 10^4  | 112.84    | 100.00   | 1.12842          |

The ratio converges to `1/Γ(1 + 1/2) = 1/Γ(3/2) = 2/√π ≈ 1.12838`. (The slow approach is
the expected `O(1/n)` correction.) This limit is proved exactly as
`descProduct_div_rpow_tendsto` / `ddag_descProduct_scaling`, and the exact closed form
`P_n(a) = Γ(n+1+a)/(Γ(1+a)·n!)` is `descProduct_gamma_closed_form`.

## 3. Counterexample hunt

- The moment recurrence `m_{k+1} = (d+k) m_k` was checked against the direct product
  formula for `d ∈ {2,3}`, `k ≤ 5`: consistent.
- The closed form `P_n(a) = Γ(n+1+a)/(Γ(1+a)·n!)` was checked at `a = 1/2`, `n ≤ 10`
  against the direct product: agreement to floating-point precision.
- The scaling constant `1/Γ(1+a)` was checked at `a ∈ {1/2, 1/3}`: the ratios above
  approach `2/√π` and `1/Γ(4/3) ≈ 1.1198` respectively.

No counterexamples found; all formalized statements are consistent with the numerics.
