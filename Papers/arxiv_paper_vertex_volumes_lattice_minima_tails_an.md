# Computational Evidence

All computations below were carried out in exact rational arithmetic (`fractions.Fraction`)
over the model that is formalised in `Catalog/Algebra/PGLQuotient/`:

* vertices of the standard arithmetic quotient `Γ \ X`, `Γ = PGL_d(𝔽_q[t])`, are the dominant
  coweights `λ_0 ≥ λ_1 ≥ … ≥ λ_{d-1} = 0`, recorded by their gaps `g_k = λ_k - λ_{k+1} ∈ ℕ`;
* the vertex stabiliser is `Aut(⨁_i 𝒪(λ_i))`, of order
  `|Aut λ| = q^{dim End} ∏_{i<d} (1 - q^{-r_i})`, with
  `dim End = ∑_{i,j} max(0, λ_i - λ_j + 1)` and `r_i = #{ j ≤ i : λ_j = λ_i }`;
* the vertex mass is `1/|Aut λ|` (Haar normalised so that a maximal compact has volume `1`);
* the normalised lattice-minima height is `α(λ) = q^{λ_0 - (∑λ)/d}`, i.e.
  `log_q α = (∑_k (d-1-k) g_k)/d`.

These are exactly `PGLQuotient.autOrder`, `PGLQuotient.vertexWeight` and `PGLQuotient.height`.

Sanity check of the stabiliser formula: at `λ = 0` it returns
`q^{d^2} ∏_{r=1}^{d}(1-q^{-r}) = |GL_d(𝔽_q)|` (e.g. `168` for `d = 3, q = 2`), as it must.

---

## 1. Vertex volume: `∑_λ 1/|Aut λ|`

Truncated sums over `g ∈ {0,…,N}^{d-1}` compared with the conjectured closed form
`d / (P(d) P(d-1))`, where `P(m) = ∏_{k=1}^m (q^k - 1)`.

| q | d | truncated sum | `d/(P(d)P(d-1))` | exact value | tail error |
|---|---|---|---|---|---|
| 2 | 2 | 0.666666666666 | 0.666666666667 | `2/3` | 4.5e-13 |
| 2 | 3 | 0.047619047619 | 0.047619047619 | `1/21` | 4.8e-20 |
| 2 | 4 | 0.000604686319 | 0.000604686319 | `4/6615` | 4.9e-22 |
| 2 | 5 | 0.000001625501 | 0.000001625501 | `1/615195` | 1.7e-23 |
| 3 | 2 | 0.062500000000 | 0.062500000000 | `1/16` | 3.4e-21 |
| 3 | 3 | 0.000450721154 | 0.000450721154 | `3/6656` | 1.0e-32 |
| 3 | 4 | 0.000000288924 | 0.000000288924 | `1/3461120` | 5.0e-36 |
| 3 | 5 | 0.000000000019 | 0.000000000019 | `1/53605826560` | 2.1e-38 |
| 5 | 2 | 0.005208333333 | 0.005208333333 | `1/192` | 3.4e-31 |
| 5 | 3 | 0.000002625168 | 0.000002625168 | `1/380928` | 2.5e-48 |
| 5 | 4 | 0.000000000045 | 0.000000000045 | `1/22106013696` | 3.3e-53 |
| 5 | 5 | ≈ 2.9e-17 | ≈ 2.9e-17 | `5/172371730218614784` | 1.0e-56 |

(The "tail error" column is `truncated sum − predicted value`; it is negative and of the size
of the omitted tail, so the data are consistent with equality in every case.)

Additional values (relative error `= (truncated sum − prediction)/prediction`):

| q | d | `d/(P(d)P(d-1))` | relative error |
|---|---|---|---|
| 4 | 3 | `1/42525` | -2.8e-27 |
| 4 | 4 | `4/2049492375` | -3.4e-26 |
| 7 | 3 | `1/9455616` | -5.1e-38 |
| 7 | 4 | `1/5820877209600` | -1.9e-36 |
| 11 | 3 | `1/638400000` | -1.1e-46 |
| 11 | 4 | `1/9322810560000000` | -1.0e-44 |

**Conclusion.** The identity
`∑_λ 1/|Aut λ| = d / (P(d) P(d-1))`
is confirmed for `d ≤ 5` at `q ∈ {2,3,5}` and for `d ≤ 4` at `q ∈ {4,7,11}` as well; since both
sides are rational functions of `q` of bounded degree for each fixed `d`, agreement at six
values of `q` is strong evidence for an identity of rational functions. Equivalently, the `PGL`-normalised vertex volume is
`(q-1) · d/(P(d)P(d-1))`.

Formalised, with complete proofs and no `sorry`:

* `d = 2`: `PGLQuotient.vertexVolume_rank_two` — `2/((q-1)(q^2-1))`;
* `d = 3`: `PGLQuotient.vertexVolume_rank_three` — `3/((q-1)(q^2-1)^2(q^3-1))`;
* `d = 4`: `PGLQuotient.vertexVolume_rank_four` — `4/((q-1)(q^2-1)^2(q^3-1)^2(q^4-1))`;
* **every `d ≥ 1`**: `PGLQuotient.vertexVolume_general_rank` — `d/(P(d)P(d-1))`, with the
  `PGL`-normalised form `PGLQuotient.vertexVolume_general_pgl`.

The general-`d` statement, listed as Conjecture 1 in the previous cycle, is therefore now a
theorem; the numerics above are retained as an independent check of the formalised statement
(and they match `vertexMass_rank_four` exactly: `4/6615` at `q = 2, d = 4`).

---

## 2. The open (regular) stratum, in every rank

Restricting the sum to `g_k ≥ 1` for all `k` (i.e. `λ` strictly decreasing) gives the generic
cell of the cut-set decomposition. Predicted closed form:

`1 / ( q^{d(d-1)/2} (q-1)^d ∏_{k=1}^{d-1} (q^{k(d-k)} - 1) )`.

| q | d | truncated sum | prediction | exact value |
|---|---|---|---|---|
| 2 | 2 | 0.50000000000000 | 0.50000000000000 | `1/2` |
| 2 | 3 | 0.01388888888889 | 0.01388888888889 | `1/72` |
| 2 | 4 | 0.00002125850340 | 0.00002125850340 | `1/47040` |
| 3 | 2 | 0.04166666666667 | 0.04166666666667 | `1/24` |
| 3 | 3 | 0.00007233796296 | 0.00007233796296 | `1/13824` |
| 3 | 4 | 0.00000000158532 | 0.00000000158532 | `1/630789120` |

This one **is** proved in arbitrary rank: `PGLQuotient.openStratum_mass`.

---

## 3. The cusp tail

For `T = q^{m/d}` the tail mass `t(T) = ∑_{α(λ) > T} 1/|Aut λ|` satisfies `t(T)·T^d = t·q^m`:

| q | d | `t(T)·T^d` for `m = 0,1,2,…,12` |
|---|---|---|
| 2 | 2 | 0.50000, 0.50000, 0.50000, … (constant) |
| 2 | 3 | 0.04167, 0.06250, 0.07292, 0.07812, 0.08073, 0.08203, 0.08268, 0.08301, 0.08317, 0.08325, 0.08329, 0.08331, 0.08332 |
| 3 | 2 | 0.04167, 0.04167, 0.04167, … (constant) |
| 3 | 3 | 0.00036, 0.00070, 0.00081, 0.00085, 0.00086, 0.00087, 0.00087, … |

The product is bounded above and below by positive constants — the sharp `T^{-d}` order that is
proved in arbitrary rank in `PGLQuotient.cuspTail_asymptotic`. The data further suggest that
`t(T)·T^d` converges along the sequence `T = q^{m/d}` (for `d = 3, q = 2` to `≈ 0.083333 = 1/12`),
which is Conjecture 3 of `FUTURE_DIRECTIONS.md`.

---

## 4. Counterexample hunt

* **Integrability threshold.** Truncated moment sums `∑_{g ∈ {0,…,N}^{d-1}} α^s/|Aut|`:

  | q | d | s | N = 20 | N = 40 |
  |---|---|---|---|---|
  | 2 | 2 | 1.5 | 2.726692 | 2.806693 |
  | 2 | 2 | 2.0 | 10.166667 | 20.166667 |
  | 2 | 2 | 2.5 | 97.587476 | 3215.053376 |
  | 2 | 3 | 2.5 | 0.580647 | 0.585975 |
  | 2 | 3 | 3.0 | 3.380950 | 6.714286 |
  | 2 | 3 | 3.5 | 98.338533 | 10082.968410 |
  | 3 | 3 | 2.5 | 0.007168 | 0.007173 |
  | 3 | 3 | 3.0 | 0.070112 | 0.139557 |
  | 3 | 3 | 3.5 | 20.993334 | 31853.582479 |

  The sums stabilise for `s < d`, grow linearly in `N` exactly at `s = d`, and diverge
  geometrically for `s > d`. No counterexample to the exact threshold `s < d` was found; the
  statement is proved in arbitrary rank (`PGLQuotient.summable_weight_height_iff`).
* **Stabiliser formula.** The formula `|Aut λ| = q^{dim End} ∏_i (1-q^{-r_i})` was checked
  against `|GL_d(𝔽_q)|` at `λ = 0` for `d ≤ 5, q ≤ 5`, and against the hand computation
  `(q-1)^2 q^{n+1}` for `d = 2, λ = (n,0), n ≥ 1`. No discrepancy.
* **Rank-two zeta.** The closed form
  `Z(s) = 1/(q(q-1)(q^2-1)) + u/((q-1)^2 q (q-u))`, `u = q^{s/2}`, against truncated sums:

  | q | s | truncated sum | closed form |
  |---|---|---|---|
  | 2 | -2 | 0.333333333333 | 0.333333333333 |
  | 2 | -1 | 0.440125747006 | 0.440125747006 |
  | 2 | 0 | 0.666666666667 | 0.666666666667 |
  | 2 | 1 | 1.373773447853 | 1.373773447853 |
  | 2 | 1.9 | 14.345047104867 | 14.345061103275 |
  | 3 | 0 | 0.062500000000 | 0.062500000000 |
  | 3 | 1 | 0.134668783649 | 0.134668783649 |
  | 3 | 1.9 | 1.496613487349 | 1.496613487796 |

  (the residual gap at `s = 1.9` is the truncation tail). This is proved:
  `PGLQuotient.heightZeta_rank_two`, together with `heightZeta_rank_two_unbounded`, which shows
  the pole at `s = 2` is genuine.

No counterexample to any conjecture recorded here was found.

---

## 5. The general-rank height zeta recursion

With `w = q^{s/d}` the height zeta function is `Z_d(s) = ∑_λ w^{heightExp λ}/|Aut λ|`, and the
row-peeling recursion proved in `PGLQuotient.twZMass_succ` computes it from the twisted masses
`M(n,c,j;w)` by

```
M(0,c,j;w) = 1/(q^{1+j}-1),
M(n+1,c,j;w) = (q^{n+2+j}(1-q^{-(1+j)}))^{-1}
               ( M(n,c+1,j+1;w) + w^{n+1}/(q^{(n+1)(c+1)}-w^{n+1}) · M(n,c+1,0;w) ),
Z_d = M(d-1,0,0;w).
```

Exact-rational evaluation of that recursion, compared with the truncated sum over
`g ∈ {0,…,N}^{d-1}` (`N = 14` for `d ≤ 3`, `N = 8` for `d = 4`):

| q | d | w | truncated sum | recursion value | gap (truncation tail) |
|---|---|---|---|---|---|
| 2 | 2 | 1   | 0.66663615 | 0.66666667 (`2/3`)     | 3.1e-05 |
| 2 | 2 | 3/2 | 1.63993974 | 1.66666667 (`5/3`)     | 2.7e-02 |
| 2 | 3 | 1   | 0.047619047412 | 0.047619047619 (`1/21`) | 2.1e-10 |
| 2 | 3 | 3/2 | 0.180904627 | 0.180952381 (`19/105`) | 4.8e-05 |
| 2 | 3 | 8/5 | 0.255522069 | 0.255952381            | 4.3e-04 |
| 2 | 4 | 1   | 0.00060468629 | 0.00060468632 (`4/6615`) | 3.4e-11 |
| 2 | 4 | 3/2 | 0.0031721195 | 0.0031746032           | 2.5e-06 |
| 3 | 3 | 1   | 0.00045072115385 | 0.00045072115385 (`3/6656`) | 1.9e-17 |
| 3 | 3 | 12/5| 0.005550643 | 0.005560412            | 9.8e-06 |
| 3 | 4 | 3/2 | 8.5103483e-07 | 8.5103486e-07        | 3.1e-14 |

The recursion value always sits *above* the truncated sum by exactly the size of the discarded
tail, and the gap grows as `w ↑ q`, as it must: the geometric ratio in the top gap is
`(w/q)^{d-1}`. At `w = 1` the recursion reproduces the proved vertex volumes
`d/(P(d)P(d-1))`. This is the numerical shadow of `PGLQuotient.twZMass_succ`,
`PGLQuotient.twZ_rational` and `PGLQuotient.heightZeta_rational_general`, all of which are
proved in Lean with no `sorry`; the table itself comes from an exploratory script and is not a
Lean artifact.
