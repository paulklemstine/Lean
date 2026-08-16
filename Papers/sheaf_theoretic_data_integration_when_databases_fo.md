# Computational Evidence — Sheaf-Theoretic Data Integration

## 1. The model

`n` columns, `k` rows, values in an alphabet of size `q`. Each cell is independently
missing with probability `r` (MCAR mask), and every *present* cell carries an
independent uniform value from the alphabet. A database is a **partial section of
the constant data sheaf** on the row cover; it satisfies the **sheaf (gluing)
condition** iff all observed entries in each column agree, i.e. iff there is a
global row `g : columns → values` restricting to every row.

## 2. Exact law obtained by hand, then checked

Conditioning on the mask, column `c` is observed by `m_c` rows and the observed
values agree with probability `q^{1-m_c}` (`1` if `m_c = 0`). Columns are
independent, `m_c ~ Bin(k, 1-r)`, so

```
P(sheaf) = base(n,k,q,r)^n ,     base = q^{1-k} (1 + (q-1) r)^k − (q−1) r^k .
```

Sanity values: `r = 0 → base = q^{1-k}` (all k rows must coincide);
`r = 1 → base = 1` (empty database always glues); `q = 1 → base = 1`; `k = 1 → base = 1`.

## 3. Monte-Carlo check (60 000 trials per row)

| n | k | q | r   | simulated | formula |
|---|---|---|-----|-----------|---------|
| 2 | 3 | 2 | 0.3 | 0.2741    | 0.2727  |
| 3 | 2 | 3 | 0.5 | 0.5799    | 0.5787  |
| 1 | 4 | 2 | 0.7 | 0.8061    | 0.8039  |
| 4 | 2 | 2 | 0.0 | 0.0607    | 0.0625  |
| 2 | 2 | 5 | 0.9 | 0.9837    | 0.9841  |

All within Monte-Carlo error. The formula is the one formalised in
`Catalog/Computation/DatabaseSheafProbability.lean` (there the model is *defined*
as the exact finite sum over masks, and the closed form is *proved*, so the table
above is only orientation, not the verification).

## 4. Counterexample hunt against the assignment's conjecture

Conjecture: `P(sheaf) = (1−r)^{C(n,k)}`.

* At `r = 0` the conjecture gives `1` for every `C`, while the true value is
  `q^{n(1−k)} < 1` as soon as `q ≥ 2, k ≥ 2, n ≥ 1` (e.g. `n=k=q=2`: true value
  `1/4`). So **no exponent whatsoever** can rescue the stated form.
* Direction of monotonicity is opposite: the true `P(sheaf)` is *non-decreasing*
  in the missing rate `r` (more missing data ⇒ fewer constraints ⇒ easier to
  glue), whereas `(1−r)^{C}` is decreasing. Exact law at `n=2,k=3,q=2`:
  `r=0 → 0.0625`, `r=0.3 → 0.2727`, `r=0.7 → 0.7837`, `r=1 → 1` (the value at
  `r=0.3` was also confirmed by simulation, 0.2741).
* Decay is exponential in the number of columns `n`, with rate `−log base`, and
  is *not* governed by any binomial coefficient `C(n,k)`.

## 5. Counterexample hunt against the "sheaf beats mean imputation" conjecture

If the database really is a partial section of the constant sheaf (the hypothesis
under which "sheaf imputation" is defined), then in each column all observed
entries are equal, so the **column mean of the observed entries equals the unique
sheaf-imputed value**. Mean imputation and sheaf imputation coincide exactly, for
every `n, k, r`. Hence the claimed strict advantage for `r < 0.5, n > 10` is false
in this model; any advantage must come from a *non-constant* sheaf (nontrivial
restriction maps), which is exactly the boundary made precise in the Lean files.

## 6. Small-case table of the exact law (`q = 2`)

| k \ r | 0     | 1/4    | 1/2   | 3/4    | 1 |
|-------|-------|--------|-------|--------|---|
| 1     | 1     | 1      | 1      | 1      | 1 |
| 2     | 0.5   | 0.7188 | 0.8750 | 0.9688 | 1 |
| 3     | 0.25  | 0.4727 | 0.7188 | 0.9180 | 1 |
| 4     | 0.125 | 0.3013 | 0.5703 | 0.8560 | 1 |

(values of `base`; `P = base^n`). Row `k = 1` constant `1`; each row increasing in
`r`; each column decreasing in `k`. No OEIS sequence is involved: the law is a
two-parameter polynomial family, `base = 2^{1-k}(1+r)^k − r^k` at `q = 2`.


## 7. Second cycle: numerical checks of the new results

**(a) Second moment.** With `u = q·A^k`, `A = r + (1−r)/q`, `v = (q−1)·r^k`, the
three verified quantities per column are `E[N] = u`, `P(sheaf) = u − v`,
`E[N²] = u + q·v`.  Values at `q = 2` (per column):

| k | r | u = E[N] | P = u − v | E[N²] = u + qv | E[N]²/E[N²] |
|---|---|---------|-----------|----------------|-------------|
| 2 | 0.0 | 0.5000 | 0.5000 | 0.5000 | 0.5000 |
| 2 | 0.5 | 1.1250 | 0.8750 | 1.6250 | 0.7788 |
| 3 | 0.5 | 0.8438 | 0.7188 | 1.0938 | 0.6509 |
| 4 | 0.9 | 1.6290 | 0.9729 | 2.9412 | 0.9022 |
| 3 | 1.0 | 2.0000 | 1.0000 | 4.0000 | 1.0000 |

The bound `E[N]²/E[N²] ≤ P` holds in every row, with equality exactly at `r = 0`
and `r = 1`, matching `second_moment_tight_at_zero`, `second_moment_tight_at_one`
and `second_moment_strict`.

**(b) Pair union bound.** Failure probability `1 − base(k,q,r)` against the pair
bound `C(k,2)(1−1/q)(1−r)²`:

| (k, q, r) | 1 − base | C(k,2)(1−1/q)(1−r)² |
|-----------|----------|----------------------|
| (2, 2, 0)   | 0.5000 | 0.5000 |
| (2, 3, 0.5) | 0.1667 | 0.1667 |
| (3, 2, 0.5) | 0.2813 | 0.3750 |
| (4, 2, 0.9) | 0.0271 | 0.0300 |
| (5, 3, 0.8) | 0.1885 | 0.2667 |
| (10, 2, 0.95)| 0.0461 | 0.0563 |

The bound holds everywhere, is an identity for `k = 2`, and becomes tight as
`r → 1`, exactly as proved in `DatabasePairBound.lean`.

**(c) Nerve Betti numbers.** `dim H¹` computed from
`dim H¹ = |overlaps| − |sources| + #components`: cycle on `m` sources
(`m − m + 1 = 1`), star on `m + 1` sources (`m − (m+1) + 1 = 0`), theta (two
sources, three overlaps: `3 − 2 + 1 = 2`), two disjoint triangles
(`6 − 6 + 2 = 2`).  The first three are proved in Lean
(`finrank_H1_cycleEdges`, `finrank_H1_star`, `finrank_H1_theta`); all follow from
the general formula `finrank_H1_nerve`.

---

## Cycle 3 evidence (binomial tail and triple overlaps)

**(d) The tail sandwich.** For every `(k, q, r)` in
`k ∈ {2,3,5,10} × q ∈ {2,3,5} × r ∈ {0, 0.25, 0.5, 0.75, 0.9}` (60 cases) the
inequalities `(1 − 1/q)·tail(k,r) ≤ 1 − base(k,q,r) ≤ tail(k,r)` were checked
numerically, with `tail(k,r) = 1 − r^k − k(1−r)r^{k−1}`; all 60 hold.  Sample:

| (k, q, r) | 1 − base | tail | ratio | 1 − 1/q |
|-----------|----------|------|-------|---------|
| (2, 2, 0.5)  | 0.1250 | 0.2500 | 0.500 | 0.500 |
| (2, 5, 0.25) | 0.4500 | 0.5625 | 0.800 | 0.800 |
| (3, 2, 0.25) | 0.5273 | 0.8438 | 0.625 | 0.500 |
| (3, 2, 0.9)  | 0.0143 | 0.0280 | 0.509 | 0.500 |

The ratio is exactly `1 − 1/q` for `k = 2` (the lower bound is then an identity)
and tends to `1 − 1/q` as `r → 1` for every `k`, while staying below `1`: the two
proved bounds bracket the truth within the factor `1 − 1/q`.  This is the content
of `one_sub_base_le_tail` and `one_sub_base_ge_tail` in
`Catalog/Computation/DatabaseBinomialTail.lean`.

**(e) Triple overlaps.** Betti bookkeeping for three sources compared pairwise
`0—1`, `1—2`, `0—2`: without the triple overlap `dim H¹ = 3 − 3 + 1 = 1`; adding
the single triangle relation `t₀ + t₁ − t₂ = 0`, whose coboundary has rank `1`,
gives `dim H¹ = 3 + 1 − 3 − 1 = 0`.  Both computations are proved in Lean in
`Catalog/Computation/DatabaseNerveTriple.lean`
(`triple_overlap_kills_obstruction`).
