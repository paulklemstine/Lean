# Computational Evidence — Uniform Extremality for Siblings of the Coupon Collector

Model. Coupons of `N` types are drawn i.i.d. from `p = (p_1,…,p_N)`. The main
collector stops at the completion time `T` (all types seen at least once). In
sibling `j`'s album (`j ≥ 2`) type `i` is *empty* unless it has been drawn at
least `j` times. `U_j^N = #{ i : N_i(T) < j }`, and we study
`E_p[U_j^N]`.

## 1. Small-case calculations

### Two types (`N = 2`), first-type probability `a`

By analysing the two-type completion configuration (a run of one type of length
`k ≥ 1`, then the completing draw), the leading-run length has pmf
`w_k = a^k(1-a) + (1-a)^k a` and, telescoping the finite defect sum,

```
E_p[U_j^2] = 2 - a^j - (1-a)^j.
```

Cross-checked (exact rational arithmetic) against the general inclusion–exclusion
formula (Section 2) for `j = 2,…,7` at `a = 3/10`: perfect agreement.

Values of `E_p[U_3^2]` on a grid of `a` (exact rationals):

| a    | 1/10  | 3/10  | 1/2  | 7/10  | 9/10  |
|------|-------|-------|------|-------|-------|
| E    | 127/100 | 163/100 | 7/4 | 163/100 | 127/100 |

Symmetric about `a = 1/2`, strict interior maximum at `a = 1/2`. The value at the
uniform point is `2 - 2^{1-j}`: `3/2, 7/4, 15/8, 31/16, …` for `j = 2,3,4,5`.

### Three types (`N = 3`), `j = 3`

Using the inclusion–exclusion closed form
`E_p[U_j^N] = ∑_i ∑_{S⊆[N]∖{i}} (-1)^{|S|} (p_i/(p_i+q_S))^j`:

| p                | E_p[U_3^3] |
|------------------|------------|
| (1/3, 1/3, 1/3)  | 85/36 ≈ 2.3611 |
| (1/2, 1/4, 1/4)  | 215/96 ≈ 2.2396 |
| (3/5, 1/5, 1/5)  | 2107/1000 = 2.1070 |
| (4/5, 1/10,1/10) | 6266/3375 ≈ 1.8566 |

Uniform is strictly the largest, and the value strictly decreases as `p` is pushed
towards the boundary — consistent with Schur-concavity.

## 2. The inclusion–exclusion formula (used for the checks)

```
E_p[U_j^N] = ∑_{i=1}^N ∑_{S ⊆ [N]∖{i}} (-1)^{|S|} ( p_i / (p_i + ∑_{s∈S} p_s) )^j.
```

Derivation: `{N_i(T) < j}` says every competitor appears before the `j`-th copy of
`i`; inclusion–exclusion over the still-missing set `S`, and restricting to draws
of types in `{i}∪S`, gives the probability `(p_i/(p_i+q_S))^j` that the first `j`
such draws are all `i`. At the uniform point every ratio collapses to
`1/(1+|S|)`, yielding
`E_uniform[U_j^N] = N · ∑_{s=0}^{N-1} (-1)^s \binom{N-1}{s} / (1+s)^j`.

## 3. OEIS notes

* `N = 2` uniform values `2 - 2^{1-j}` have numerators `3, 7, 15, 31, 63, …`
  (`2^j - 1`, OEIS A000225, Mersenne numbers) over denominators `2^{j-1}`.
* The uniform alternating sum `∑_{s} (-1)^s \binom{N-1}{s}/(1+s)^j` is a finite
  difference of the reciprocal-power sequence and is closely related to Beta
  integrals `∫_0^1 (1-x)^{N-1} · (…) dx`. (The inclusion–exclusion closed form is
  valid for the model's regime `j ≥ 2`; the naive `j = 1` substitution lies
  outside that regime, since at completion every type is already seen, so
  `U_1^N = 0` identically.)

## 4. Counterexample hunt

Universal claim tested: "uniform maximises `E_p[U_j^N]`, strictly, and the value
decreases along rays from uniform."

* `N = 2`: swept `a ∈ {k/50 : 1 ≤ k ≤ 49}` for `j = 2,…,8`; the maximum is at
  `a = 1/2` in every case, values strictly decreasing in `|a - 1/2|`.
* `N = 3`: sampled ~200 rational points of the simplex for `j = 2,3,4`; no point
  exceeded the uniform value; every tested ray from `(1/3,1/3,1/3)` was strictly
  decreasing.
* `N = 4,5`: coarse random rational sampling for `j = 2,3`; no counterexample.

No counterexample was found. The `N = 2` case (all `j`) is proved in full; the
general-`N` closed form, its permutation symmetry, and its uniform value are
proved, with global Schur-concavity recorded as the leading conjecture.
