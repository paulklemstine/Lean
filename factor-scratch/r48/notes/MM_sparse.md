# MM — the linear-algebra bottleneck of Stange's method: is it removable?

**Round 49, agent MM · `factor-scratch/r49exp/sparse/` · 2026-10-03**

Code: `spcore.py` (sparsity/defect + four exact linear-algebra routes),
`sptest.py` (self-test, **ALL PASS**, with negative controls),
`exp_T1.py` `exp_T2.py` `exp_T3.py` `exp_T4.py`.
Everything additive; the validated relation finder and factoring primitives are
**imported** from the read-only `r48/exp/stange/stange.py`, never re-implemented.

---

## 0. Headline

**The axis is negative, and the negative is provable in one line rather than
merely measured.**

> The Stange relation matrix is genuinely sparse — density `Θ(1/b)`, `Θ(b)`
> nonzeros in a `b × b` matrix — but its **permutation-similarity defect is
> `Θ(b)` and is provably invariant under every permutation**. NFS's `O(n²)`
> sparse linear algebra rests on a *bounded defect*, and this matrix does not
> have one, for a structural reason no reordering touches: **the row for `p = 2`
> is dense, because a constant fraction of all `B`-smooth integers are even.**
> So the NFS treatment does not transfer.

Sparsity is nevertheless *not* free here, and this is the one positive result:

| | dense route | sparse (dictionary) route |
|---|---|---|
| exact arithmetic ops, measured at `n≈2³⁰` | `0.1–0.6 · b³` | **`3.7–8.0 · b²`** |
| asymptotics | `Θ(b³)` | **`Θ(b²)`** |

So the sparse route is a genuine **factor-`b`** improvement, and the black-box
(matrix-product) route is the **same `Θ(b²)`**. But `Θ(b²)` is still hopeless at
the `b ≈ 6·10⁵` the regime analysis needs: at that `b` the sparse route is a
`≈10¹¹`-operation job and the black-box route a `≈10¹²`-operation job.

**Bottom line: the linear-algebra bottleneck is NOT removable by sparsity.** It
is reducible by a factor of `b`, and the argmin moves only slightly (§5).

---

## 1. T1 — SPARSITY AND DEFECT: the measured numbers

Real relation matrices, `c = 1`, produced by r48's own (validated) relation
finder; 2–4 independent `n` per cell.

### 1.1 Density falls like `1/b` — the premise of the axis is TRUE

`n ≈ 2³⁰`, mean of 3 relation sets per `b`:

| `b` | 8 | 16 | 26 | 40 | 64 | 100 | 128 |
|---|---|---|---|---|---|---|---|
| density `nnz/(b·(b+c))` | 0.548 | 0.305 | 0.194 | 0.129 | 0.080 | 0.050 | 0.038 |
| `nnz` per column | 4.33 | 4.88 | 5.04 | 5.17 | 5.14 | 4.97 | 5.01 |

`density × b ≈ 4.4, 4.9, 5.0, 5.2, 5.1, 5.0, 5.0` — flat. So
**`nnz(M) = 5·(b+c) = Θ(b)`**, and each **column** has only `≈5` nonzeros,
independent of `b`. At `n ≈ 2⁴⁰` the column weight rises only to `≈6.5`.

The matrix is sparse. That part of the hypothesis holds.

### 1.2 The defect is `Θ(b)` — and it does not fall

| `n ≈ 2³⁰`, `b` | 8 | 16 | 26 | 40 | 64 | 100 | 128 |
|---|---|---|---|---|---|---|---|
| max row degree | 7 | 13 | 19 | 27 | 41 | 65 | 89 |
| **defect / (b+c)** | 0.78 | 0.65 | 0.70 | 0.66 | 0.63 | 0.61 | 0.61 |
| max **column** degree | 5 | 5 | 5 | 5 | 5 | 5 | 5 |

The defect is a constant fraction `≈0.6` of the number of columns at every `b`.
Column degree (5) never competes; the defect is always a **row**.

### 1.3 Why: the mechanism is exactly predictable, and the prediction is exact

Row `i` is nonzero in column `j` iff `p_i | r_j`, and relations are drawn with
`x` uniform in `[1,n)`, so `r_j` is uniform over the `B`-smooth integers in
`[1,n]`. Therefore **exactly**

$$\Pr[\text{row } i \neq 0] \;=\; \frac{\Psi(n/p_i,\,B)}{\Psi(n,\,B)} \qquad (*)$$

because `r` is `B`-smooth and `p_i | r ⟺ r = p_i·s` with `s` `B`-smooth and
`s ≤ n/p_i`.

`(*)` is not an estimate and I checked it against brute-force enumeration of
*every* `B`-smooth integer up to `n` (`fix_psi.py`, `psi_powered.py`):

| `n` | `B` | `#B-smooth ≤ n` | **exact `Ψ(n/2,B)/Ψ(n,B)`** | **measured `rowdeg(p=2)/(b+c)`** | `z` |
|---|---|---|---|---|---|
| 997 | 20 | 330 | 0.6545 | 0.7222 | +0.60 |
| 1009 | 30 | 404 | 0.6337 | 0.7000 | +0.62 |
| 2003 | 30 | 622 | 0.6479 | 0.7500 | +0.96 |
| 5003 | 50 | 1585 | 0.6328 | 0.7600 | +1.32 |

So `≈0.63–0.65` of all `B`-smooth integers are even, at every size tested, and
the measured heavy-row density matches it. **This is what makes the defect
`Θ(b)`: it is one dense row that no reordering can remove.**

### 1.4 ⚠️ Two bugs this section's controls caught

1. **`factor_base(B, n)` drops primes dividing `n`.** My first exact check
   enumerated with `factor_base`, took even `n` (600, 900, …), which removes 2
   from the base, and returned **`Pr[2 | r] = 0.0000`** — a confident, clean,
   completely wrong number. This is the *same* trap r48's own self-test T3
   documents ("167 mismatches at `n=10⁶` that were entirely my test's fault").
   Fixed: enumerate against the **full** prime set `≤ B`, and use odd `n`
   (`gen_semiprime` always produces odd `n`, so 2 *is* in the real factor base).
2. **An unexplained deviation, recorded, not explained away.** The same exact
   computation for the row `p = 3` gives `Ψ(n/3,B)/Ψ(n,B) ≈ 0.48–0.50`, but the
   measured `p = 3` row degree is `0.17, 0.45, 0.40, 0.28` — below prediction
   in **4/4** cells (`z = −2.85, −0.23, −0.88, −1.99`). Under-powered (`ncols`
   = 18–25) and unexplained; it does not affect the defect conclusion, which is
   set by `p = 2`. **Flagged, not claimed.**

### 1.5 The permutation-similarity defect is *trivially invariant* — a proof, not a search

For **any** matrix `A`, permuting columns permutes the entries *within* each
row, so each row's nonzero count — hence the multiset of row degrees and its
maximum — is unchanged; symmetrically for rows and column degrees. Therefore

$$\operatorname{defect}(\sigma A\tau) \;=\; \operatorname{defect}(A)
=\max\Big(\max_i \mathrm{rowdeg}_i,\ \max_j \mathrm{coldeg}_j\Big)
\qquad \forall\ \sigma,\tau .$$

The minimum over `(σ,τ)` is attained already at the identity. **There is no
permutation to find**, so no amount of reordering heuristic can reduce the
defect here. `defect_is_permutation_invariant()` verifies this numerically on
real Stange matrices anyway (10 random row+column permutations per matrix, all
defects identical) — an argument nobody ran is not a result.

### 1.6 What this kills, against the NFS precedent

Fetched and quoted (see §7): Jeljeli, *Accelerating Iterative SpMV for Discrete
Logarithm Problem Using GPUs*, arXiv:1209.5520v4, §1 p.2 —

> "The number of rows and columns of the corresponding matrices is in the order
> of hundreds of thousands to millions, with only hundreds or fewer non-zero
> elements per row."

That bounded per-row defect — hundreds out of `10⁵–10⁶` — is precisely what
licenses NFS's sparse route. Stange's is `0.6 × (b+c)`: **a constant fraction,
six to seven orders of magnitude worse.** Same arXiv:1209.5520v4 §1 p.2 —

> "To solve such systems, ordinary Gaussian elimination is inefficient. While
> some elimination strategies aiming at keeping the matrix as sparse as possible
> can be used to reduce the input system somewhat, actual solving calls for the
> use of other techniques (Lanczos algorithm [13], Wiedemann algorithm [27])
> that take advantage of the sparsity of the matrix [18]. For the Lanczos
> algorithm, the Wiedemann algorithm and their block variants, the iterative
> sparse-matrix–vector product is the most time-consuming operation."

Both halves of that advice are implemented and measured below. The sparse
`Θ(b²)` route *is* the "elimination strategy aiming at keeping the matrix sparse"
and it does not get to `Θ(b)`; the Wiedemann route *is* the SpMV-iterating
alternative and it costs the same `Θ(b²)`.

---

## 2. T2 — FOUR ROUTES, MATCHED `b`, SAME RELATION SETS, WALL CLOCK

Routes, all exact, all checked by `assert M·v = 0` before their time is recorded:

* **DENSE-F** — exact Fraction Gauss–Jordan on the dense `b×(b+c)` list (what
  `r50/exp/bsweep/fastnull.py` uses).
* **DENSE-DM** — sympy `DomainMatrix` rref over `QQ` (see the trap in §4).
* **SPARSE** — exact Fraction Gauss–Jordan on a **dictionary** representation;
  touches only stored nonzeros, and records the **fill-in** directly.
* **BLACKBOX** — matrix-product (Krylov/Wiedemann-family): only sparse matvecs.

`2³⁰`, `c = 1`, one relation set per row:

| `b` | nnz | DENSE-F (s) | SPARSE (s) | speed-up | BLACKBOX (s) | dense ops | sparse ops | fill/nnz |
|---|---|---|---|---|---|---|---|---|
| 8 | 39 | 0.0005 | 0.0004 | 1.29 | 0.0003 | 329 | 236 | 1.23 |
| 16 | 89 | 0.0024 | 0.0026 | 0.90 | 0.0012 | 1 908 | 1 465 | 1.88 |
| 26 | 146 | 0.0073 | 0.0056 | 1.31 | 0.0037 | 6 328 | 4 119 | 2.42 |
| 40 | 218 | 0.0212 | 0.0191 | 1.11 | 0.0099 | 17 790 | 12 816 | 3.24 |
| 64 | 322 | 0.0676 | 0.0455 | 1.49 | 0.0308 | 56 623 | 31 879 | 4.24 |
| 100 | 509 | 0.2207 | 0.1010 | 2.19 | 0.1105 | 148 643 | 69 910 | 5.63 |

### 2.1 The asymptotic win is real and it is a factor `b`

Normalising the counted exact operations:

| `b` | 8 | 16 | 26 | 40 | 64 | 100 |
|---|---|---|---|---|---|---|
| dense ops / `b³` | 0.64 | 0.47 | 0.36 | 0.28 | 0.22 | 0.15 |
| **sparse ops / `b²`** | 3.69 | 5.72 | 6.09 | 8.01 | 7.78 | 6.99 |

**`Θ(b³)` versus `Θ(b²)`.** The wall-clock speed-up is only 1.1–2.2× at these
sizes purely because CPython `Fraction` overhead dominates at small `b`; the
counted-operation ratio is `2.1` at `b = 100` and grows linearly in `b`
(`≈2.1` at `b=100` → `≈21` at `b=1000`).

### 2.2 Why sparse is `Θ(b²)` and not `Θ(b)`

`fill/nnz` grows **linearly in `b`** — 1.23 at `b=8` to 5.63 at `b=100` — so
`fill = Θ(b·nnz) = Θ(b²)`, and `fill/(b·(b+c))` settles near `0.28`. This is
the §1 defect showing up again as fill-in: eliminating a column that touches the
`p=2` row propagates into every other column that also touches it, and that row
is nonzero in `≈0.63` of all columns. **The dense row is what converts the
sparsity into quadratic fill.** A matrix with `O(log n)` nonzeros per row would
give `O(b)` fill; this one cannot.

### 2.3 The black-box route costs the same `Θ(b²)`, and it wins the wall clock

BLACKBOX needs `b+1` sparse double-matvecs of `Θ(nnz)` each, i.e.
`Θ(b·nnz) = Θ(b²)` modular operations — the same order as the sparse route's
fill — and it is verified to return a correct kernel vector on **28/28**
instances. Across all 28 measured points it is **faster than dense every time**
(ratio `0.37–0.76`, i.e. 1.3–2.7×), and **faster than the sparse dictionary
route from `b = 12` through `b = 64`** (ratio `0.40–0.85`), tying it at
`b = 100` (1.10, 1.14). It wins because its operations are small-integer modular
rather than `Fraction`, so the `Θ(b²)` counts buy much cheaper steps.

| `b` (`n≈2³⁰`) | 8 | 16 | 26 | 40 | 64 | 100 |
|---|---|---|---|---|---|---|
| black-box ÷ dense-F | 0.70 | 0.50 | 0.50 | 0.47 | 0.46 | 0.50 |
| black-box ÷ sparse | 0.94 | 0.47 | 0.66 | 0.52 | 0.68 | 1.10 |

**Crossovers.** Sparse dictionary vs dense: crosses at **`b ≈ 20`** (0.90× at
`b=16`, 1.31× at `b=26`, 2.19× at `b=100`). Black-box vs dense: crosses at
**`b ≈ 8`**, the smallest size measured. Black-box vs sparse: crosses at
**`b ≈ 100`**. All three wins are *constant-or-linear* in `b`, not the `b²` the
`Θ(b³)→Θ(b²)` change would suggest, because CPython overhead dominates at every
size I can measure. The *asymptotic* statement is the operation counts, and the
honest wall-clock statement is that these are 1.3–2.7× wins, not `10⁶×`.

---

## 3. ⚠️ The black-box route took four attempts, three structurally wrong

Recorded because each is a standard trap and because the version that works is
far simpler than the ones that failed.

1. **`C = [[0, M],[0,0]]`** (size `2b+c`). 0/6. `C(u;v) = (M v; 0)`, so
   `C² = 0`: `C` is **nilpotent of index 2**, minimal polynomial `x²`, and no
   Berlekamp–Massey run can ever reach degree `2b+c`. Self-test **ST8c** now
   pins this property (with a *precondition* check that `C ≠ 0` on the data, so
   the test is not vacuous).
2. **Berlekamp–Massey on `s_k = uᵀTᵏv`.** BM itself is correct — unit-tested
   against Fibonacci (exact) and `3^k` (exact). But BM returns the minimal
   polynomial of the **sequence**, and the operator identity that would license
   reading a kernel vector off it does not hold for a non-cyclic matrix.
   Measured: `deg 12` against matrix size `21`, both candidate shifts gave
   `T·w ≠ 0`.
3. **Incremental sparse elimination for the first Krylov dependence.** Reported
   "no dependence" among 13 Krylov vectors in an 11-dimensional space, where one
   must exist — a bug in *my* elimination, not in the mathematics.
4. **What works:** drop BM and the bookkeeping. Build the Krylov matrix
   `K = [Tv, T²v, …, T^{b+1}v]` over `T = S Sᵀ` (never formed; one application
   is two sparse matvecs) and run ordinary mod-`p` Gaussian elimination on it.
   Same `O(b²)`, obviously correct. The Krylov vectors must **start at `Tv`**:
   starting at `v` yields a relation with a free constant term, and dividing out
   that power of `T` is exactly the step attempt 2 got wrong. Every candidate is
   verified entry-by-entry as `M·w = 0 mod p` before it is returned, so the
   function cannot return a wrong vector — at worst `None`.

---

## 4. ⚠️ A trap that would have shipped: `sympy.DomainMatrix.rref()` over `ZZ` is not reduced

While building the *dense baseline* I got a kernel vector with `M·v = 0` false.
The mandatory exact assertion caught it. Cause, on a `4×5` example:

```
DomainMatrix.rref() over ZZ:        Matrix.rref() over QQ:
[[1,0,0,0,0],                       [[1,0,0,0,-59/66],
 [0,1,0,0,1],                        [0,1,0,0, 35/33],
 [0,0,1,0,1],                        [0,0,1,0, 97/66],
 [0,0,0,1,0]]                        [0,0,0,1,-23/66]]
```

Over `ZZ` the form is reduced on the **pivot** columns only — the free columns
are left uncleared, because clearing them requires a division by the determinant.
Back-substituting from it gives **the right rank, the right dimension, and wrong
vectors** — *exactly* the round-48 failure mode, in a library call rather than in
hand-written code. `rref()` must be run over `QQ`.

(Separately: the returned `pivots` tuple was not aligned row-by-row with the
returned matrix in my usage; I derive pivots by scanning the RREF instead. Both
bugs produced wrong vectors and both were caught only by `assert M·v = 0`. A
rank check passes all of them.)

---

## 5. T3/T4 — see below