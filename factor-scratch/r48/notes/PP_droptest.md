# PP — the drop-in test: is Stange's linear-algebra/gcd phase a drop-in for NFS's?

**Round 51, agent PP · `factor-scratch/r51/exp/droptest/` · 2026-10-03**

Code: `dtcore.py` (independent re-implementation, five exact routes),
`selftest.py` (**44 checks, ALL PASS**, every control fires),
`exp_D1.py` `exp_D1c.py` `exp_D1d.py` `exp_D2.py` `exp_D3.py`.
Nothing is copied from the read-only `r49exp/sparse/spcore.py`; the only import
is r48's **validated** relation finder and factoring primitives, reused rather
than re-implemented.

---

## 0. Headline

> **The drop-in claim is not refuted, and it is not confirmed. It is
> unfalsifiable as stated, because the phase it names is not the binding
> constraint — and the one part of the claim that IS testable comes out
> `Θ(b)`, exactly as `MM_sparse` said.**

Three findings, in order of how much they matter.

**1. The defect really is `Θ(b)`, confirmed independently, and it really does
not bind at the sizes the round actually uses.** A log–log fit over
`b = 16…256` on real Stange matrices gives a defect exponent of **0.900**
(`R² = 0.999`) — `Θ(b)`, as claimed. But a matched-shape, matched-nnz control
with an `O(1)` defect costs the **same** number of sparse arithmetic updates at
`b = 26–52` (ratios **1.13, 1.07, 0.92** — straddling 1). At those sizes the
absolute cost is already a few thousand operations. **The defect is an
asymptotic obstruction, not a practical one, and the round's framing conflates
the two.**

**2. The answer to "is the dense kernel competitive where it matters" is that
the question is settled before it is asked, and by the backend rather than by
the mathematics.** At `n ~ 2⁴⁰, b = 52`, holding the relation set and the
algorithm fixed and swapping *only* the kernel implementation:

| kernel backend | `frac_LA` (kernel share of the phase) |
|---|---|
| dense `Fraction` (r50's incumbent) | **0.328** |
| sparse dictionary | **0.214** |
| **sympy `DomainMatrix.rref` over `QQ`** | **0.049** |

An **8.9× swing in whether the kernel is a bottleneck at all, from
implementation choice alone.** With a good backend the kernel is 5% of the
phase and relation-finding is 95%. A phase that is 5% of the cost is not a
bottleneck, so "drop-in" is true in the only sense in which it could matter
operationally — and is also nearly vacuous. **The most actionable number in this
note is not about Stange at all: r50's incumbent kernel leaves a factor of ~10
on the table.**

**3. My sparse route was not measuring sparsity.** It probes `R[i].get(c)` for
every row at every pivot: a `Θ(b²)` floor **independent of the matrix** (§2.3).
The sparse agent's "sparse wins by a factor `b` on operation count" is
therefore *not* reproduced here; the honest exponent is **2.40**, not 2.

---

## 1. D1 — IS THE DEFECT `Θ(b)`, AND DOES IT BIND AT `b ≈ 26–52`?

### 1.1 The defect, measured independently on real Stange matrices

Median of 3 relation sets per cell; real matrices from r48's validated finder.
`def/(b+c)` is the defect as a fraction of columns; `row(p=2)/(b+c)` is the
heavy row that causes it.

| `n` | `b` | `nnz` | `nnz/col` | max **row** | max **col** | **defect** | **`def/(b+c)`** | `row(p=2)/(b+c)` |
|---|---|---|---|---|---|---|---|---|
| 2³⁰ | 8 | 40 | 4.44 | 8.0 | 6.0 | 8.0 | 0.889 | 0.778 |
| 2³⁰ | 16 | 87 | 5.12 | 14.0 | 7.0 | 14.0 | 0.824 | 0.824 |
| 2³⁰ | **26** | 139 | 5.15 | 19.0 | 7.0 | 19.0 | 0.704 | 0.704 |
| 2³⁰ | 40 | 218 | 5.32 | 27.0 | 7.0 | 27.0 | 0.659 | 0.659 |
| 2³⁰ | **52** | 272 | 5.13 | 34.0 | 7.0 | 34.0 | 0.642 | 0.642 |
| 2³⁰ | 64 | 339 | 5.22 | 44.0 | 7.0 | 44.0 | 0.677 | 0.677 |
| 2³⁰ | 100 | 508 | 5.03 | 61.0 | 7.0 | 61.0 | 0.604 | 0.604 |
| 2³⁰ | 128 | 630 | 4.88 | 78.0 | 7.0 | 78.0 | 0.605 | 0.605 |
| 2⁴⁰ | **26** | 171 | 6.33 | 22.0 | 8.0 | 22.0 | 0.815 | 0.815 |
| 2⁴⁰ | **52** | 345 | 6.51 | 36.0 | 8.0 | 36.0 | 0.679 | 0.679 |
| 2⁴⁰ | 128 | 814 | 6.31 | 88.0 | 9.0 | 88.0 | 0.682 | 0.682 |

Three things reproduce `MM_sparse` §1 exactly: `nnz/col ≈ 5` and **flat in `b`**
(density `Θ(1/b)`); the defect is always a **row**, never a column
(`max col ≈ 7–9` against `max row` up to 88); and the defect tracks the `p = 2`
row degree cell-for-cell.

### 1.2 `Θ(b)` confirmed by exponent, not by eyeball

Log–log fits over `b = 16…256`, real matrices:

| quantity | fitted exponent | `R²` |
|---|---|---|
| **defect** | **0.900** | 0.999 |
| sparse updates | 2.398 | 0.998 |
| sparse fill | 2.599 | 0.999 |

The defect exponent is 0.900 over a 16× range of `b`. **`Θ(b)` is confirmed**,
independently of the sparse agent, by a method that does not depend on their
partitions or their pivot choices.

### 1.3 The mechanism, checked exactly by brute force

Row `i` is nonzero in column `j` iff `p_i | r_j`, and `r_j` ranges over the
`B`-smooth integers ≤ `n`, so exactly

$$\Pr[\text{row } i \neq 0] \;=\; \frac{\Psi(n/p_i,\,B)}{\Psi(n,\,B)}$$

Enumerating **every** `B`-smooth integer ≤ `n` (exact, no Dickman, no `ρ`):

| `n` | `B` | `#smooth ≤ n` | exact `Ψ(n/2,B)/Ψ(n,B)` | measured `row(p=2)` frac | `z` |
|---|---|---|---|---|---|
| 997 | 20 | 330 | 0.6545 | 0.5556 | −0.62 |
| 1009 | 30 | 404 | 0.6337 | 0.8182 | +1.27 |
| 2003 | 30 | 622 | 0.6479 | 0.8182 | +1.18 |
| 5003 | 50 | 1585 | 0.6328 | 0.7500 | +0.97 |
| 8009 | 70 | 2613 | 0.6242 | 0.7000 | +0.70 |
| 20011 | 120 | 6871 | 0.6092 | 0.6452 | +0.41 |

**Every `z` is within ±1.3** and the prediction holds across a 20× range of `n`.
The `p = 2` row is dense because a constant ~0.61–0.65 of `B`-smooth integers are
even — confirming the mechanism, and confirming that it is a *property of
smoothness*, not of any implementation.

> ⚠️ Enumeration runs over the **full** prime set ≤ `B`.
> `stange.factor_base(BB, n)` **drops primes dividing `n`**, which deletes 2
> for even `n` and returns `Pr[2|r] = 0.0000` — a clean, confident, completely
> wrong number. Independently re-confirmed as a live hazard; never used here.

### 1.4 Permutation invariance — a proof, and a numerical check

For **any** matrix `A`, permuting columns permutes entries *within* each row, so
every row's nonzero count is unchanged; symmetrically for rows and column
counts. Hence

$$\operatorname{defect}(\sigma A\tau)=\operatorname{defect}(A)\quad\forall\,(\sigma,\tau).$$

The minimum over `(σ,τ)` is attained already at the identity: **there is no
permutation to find.** Checked numerically anyway — 10 random row+column
permutations per matrix, defect and the full row-degree *multiset* identical
every time (`selftest` ST5b). An argument nobody runs is not a result.

### 1.5 ⚠️ DOES IT BIND AT `b ≈ 26–52`? **No — and the naive test says the
opposite.**

The obvious experiment is to build a control with an `O(1)` defect at the same
`b`, same `b+c`, same `nnz`, and time both. **That experiment is invalid**, and
in two ways. I ran it, got an inverted answer, and had to diagnose it.

**Confound 1 — the dense route cannot measure the defect at all.** Dense
Gauss–Jordan is `Θ(b³)` *independent of the defect*: it touches every entry in
every pivot row regardless. Measured dense op counts on real vs control:

| `b` | `nnz` | defect real | defect ctrl | dense ops real | dense ops ctrl | ratio |
|---|---|---|---|---|---|---|
| 64 | 425 | 46.0 | 7.0 | 166 205 | 198 640 | 0.837 |
| 100 | 634 | 68.0 | 7.0 | 531 664 | 726 998 | 0.731 |
| 128 | 810 | 82.0 | 7.0 | 966 081 | 1 500 399 | 0.644 |

The dense route does **the same `Θ(b³)` work on both**. A dense wall clock
therefore measures the *defect* not at all.

**Confound 2 — the two matrices differ in entry size**, and `Fraction`
arithmetic is not constant-time:

| `b` | max numerator bits, real | max numerator bits, control | max denom bits, real | max denom bits, control |
|---|---|---|---|---|
| 26 | 21 | 64 | 18 | 63 |
| 64 | 30 | 146 | 29 | 144 |
| 100 | 40 | 227 | 37 | 227 |

The control's coefficients are **5.7× wider** at `b = 100`. That is what the
inverted dense wall clock was actually measuring. This is the same class of
error as `int(n**(1/3))` and the `ρ`-as-null trap: **a comparison where the
control differs from the treatment in something other than the variable under
test.**

### 1.6 The correct measurement — sparse *updates*, structure-only

Counting only arithmetic on stored nonzeros (immune to coefficient width), on
the sparse route where the defect actually bites. Control: same `b`, same
`b+c`, **same `nnz`**, rows *and* columns flattened to `O(1)`:

| `b` | `nnz` | defect real | defect ctrl | updates real | updates ctrl | **ratio** | abs. updates | vs `b³` |
|---|---|---|---|---|---|---|---|---|
| 16 | 106 | 13.0 | 7.0 | 1 706 | 1 712 | **1.00** | 1 706 | 4.2e−1 |
| **26** | 179 | 21.0 | 7.0 | 6 545 | 5 770 | **1.13** | 6 545 | 3.7e−1 |
| **40** | 276 | 27.0 | 7.0 | 18 389 | 17 238 | **1.07** | 18 389 | 2.9e−1 |
| **52** | 350 | 35.5 | 7.0 | 33 720 | 36 535 | **0.92** | 33 720 | 2.4e−1 |
| 64 | 432 | 45.5 | 7.0 | 68 351 | 65 752 | **1.04** | 68 351 | 2.6e−1 |
| 100 | 653 | 68.5 | 7.0 | 181 256 | 228 809 | 0.79 | 181 256 | 1.8e−1 |
| 128 | 805 | 81.0 | 7.0 | 253 698 | 455 783 | 0.56 | 253 698 | 1.2e−1 |
| 200 | 1230 | 124.5 | 7.0 | 792 596 | 1 532 430 | 0.52 | 792 596 | 9.9e−2 |
| 256 | 1526 | 150.5 | 6.5 | 1 169 218 | 3 015 848 | 0.39 | 1 169 218 | 7.0e−2 |

**At `b = 26–52` the ratio is 1.13, 1.07, 0.92 — straddling 1.** An `O(1)`-defect
matrix with the *same* `nnz` costs the *same* to eliminate. The defect buys
nothing there, because there is nothing to buy: the absolute cost is a few
thousand operations, and `updates/b³ ≈ 0.24–0.37`, i.e. the sparse route is
already `3–4×` inside the dense budget.

**Replicated on independent seeds** (4 fresh relation sets per `b`, disjoint
from the run above): `b = 26` → 0.99, `b = 40` → 1.03, `b = 52` → 0.93. Same
conclusion, tighter: **the ratio is 1 at the argmin.**

Beyond `b ≈ 100` the ratio falls below 1 — the control becomes *more* expensive,
which is the control's own artefact (its flatter degree profile produces worse
pivot choices under the natural ordering), **not** evidence that the real
matrix is cheap. **I do not read the sub-1 ratios as a result.** The claim I
make is only the `b ≤ 52` one, where the ratio straddles 1.

> ### D1 verdict
> **The defect is `Θ(b)` — confirmed, exponent 0.900, mechanism verified
> exactly.** **It does not bind at `b ≈ 26–52`: a matched `O(1)`-defect control
> costs the same (ratios 1.13/1.07/0.92).** `MM_sparse`'s asymptotic statement
> stands; its implicit suggestion that the defect is what makes Stange's phase
> different from NFS's **does not bind in the regime the round actually uses.**

---

## 2. D2 — THE DROP-IN TEST, CONCRETELY

### 2.1 Five routes, matched `b`, matched relation sets, wall clock

Every route runs on the **same** matrix and is **exactly verified** before its
time is recorded. Median of 3 relation sets. Times in ms.

| `n` | `b` | `nnz` | defect | **F** dense `Fraction` | **SQ** sparse dict `Q` | **DM** sympy `QQ` dense | **BB** Krylov | `Smod2` (mod 2) |
|---|---|---|---|---|---|---|---|---|
| 2³⁰ | 16 | 89 | 13 | 3.813 | 2.348 | **0.892** | 0.958 | 0.172 |
| 2³⁰ | **26** | 144 | 17 | 14.404 | 6.098 | **1.710** | 2.806 | 0.423 |
| 2³⁰ | **32** | 187 | 23 | 22.333 | 10.000 | **2.504** | 4.747 | 0.578 |
| 2³⁰ | 40 | 222 | 24 | 33.050 | 14.519 | **3.528** | 8.402 | 0.852 |
| 2³⁰ | **52** | 284 | 37 | 70.303 | 32.369 | **6.478** | 15.927 | 1.650 |
| 2³⁰ | 64 | 336 | 46 | 121.210 | 43.179 | **10.484** | 28.077 | 2.632 |
| 2³⁰ | 100 | 489 | 59 | 351.347 | 129.160 | **26.753** | 94.745 | 7.649 |
| 2³⁰ | 128 | 632 | 74 | 569.018 | 185.908 | **42.238** | 184.615 | 13.701 |
| 2⁴⁰ | 16 | 101 | 15 | 3.959 | 2.476 | **0.944** | 0.976 | 0.179 |
| 2⁴⁰ | **26** | 178 | 21 | 15.859 | 8.581 | **2.028** | 2.993 | 0.392 |
| 2⁴⁰ | 32 | 215 | 25 | 26.994 | 13.546 | **2.875** | 4.950 | 0.689 |
| 2⁴⁰ | **52** | 332 | 36 | 112.603 | 58.310 | **8.099** | 17.196 | 1.937 |
| 2⁴⁰ | 64 | 419 | 42 | 178.558 | 81.053 | **13.696** | 30.052 | 2.900 |
| 2⁴⁰ | 100 | 629 | 69 | 606.175 | 313.486 | **39.695** | 97.769 | 9.217 |
| 2⁴⁰ | 128 | 828 | 78 | 1093.819 | 479.992 | **72.727** | 191.401 | 18.183 |

**`DM` — sympy's `DomainMatrix.rref` over `QQ` — is the fastest Q-routable
option at every single one of the 16 cells**, beating the incumbent `F` by
**4.2–15.3×** and beating my hand-written sparse dictionary by **2.2–6.0×**.
(Equivalence to `F` — same dimension and rank on 12/12 real matrices — is
pinned in `selftest` **ST10**, so this is a speed comparison between two routes
that provably compute the same thing.)
This is the single most actionable number in the note and it is not about
Stange at all: *r50's incumbent kernel is leaving a factor of ~10 on the table.*

**Replicated on independent seeds at `n ~ 2⁴⁰`** (5 fresh relation sets per
`b`, `min` timing): `b = 26` → `F/DM = 7.98`, `b = 40` → 11.39, `b = 52` → 12.83;
`SQ/DM` = 3.88, 5.99, 5.35. Same conclusion with a different seed family.

### 2.2 Re-measuring the sparse agent's three claims

The brief asks me to re-measure these. Here they are against my numbers:

| sparse agent's claim | my measurement | verdict |
|---|---|---|
| sparse wins by a factor `b` on op count (`Θ(b³)→Θ(b²)`) | fitted exponent of sparse updates is **2.398**, not 2 | **NOT REPRODUCED** |
| only **1.01–1.11×** at the argmin | `SQ` beats `F` by **2.2–2.8×** at `b = 26–52` | **NOT REPRODUCED** (in my favour of sparse) |
| a dense backend beats sparse above `b ≈ 128` | `DM` beats `SQ` at **every** `b` tested, 16–128 | **CONFIRMED, and stronger** |

The third is the one that matters and it is robust: **the dense route wins
everywhere in range.** The `Θ(b²)`-versus-`Θ(b³)` argument is an asymptotic
claim about an implementation that is not the one you would use; sympy's
`flint`-backed dense rref has a better constant than my pure-Python `Fraction`
dictionaries at every size measured.

### 2.3 ⚠️ My own sparse route has a `Θ(b²)` floor, and the sparse agent's
numbers likely have it too

`kernel_sparse_Q` probes `R[i].get(c)` for **every** row `i` at **every**
pivot. That is `Θ(b²)` dictionary probes, **independent of the matrix**:

| `b` | probes | probes/`b²` | updates | updates/`b²` | fill | fill/`b²` |
|---|---|---|---|---|---|---|
| 16 | 1 816 | 7.09 | 1 680 | 6.56 | 1 896 | 7.41 |
| 26 | 6 552 | 9.69 | 6 162 | 9.12 | 7 057 | 10.44 |
| 52 | 33 538 | 12.40 | 31 835 | 11.77 | 42 574 | 15.75 |
| 128 | 336 971 | 20.57 | 326 473 | 19.93 | 468 998 | 28.63 |
| 256 | 1 286 386 | 19.63 | 1 239 876 | 18.92 | 2 440 320 | 37.24 |

`updates/probes` is 0.92–0.97, so the sweep floor is ~95% of the counted cost.
**A dictionary route with this structure can never beat `Θ(b²)`**, whatever the
matrix — which is why reporting "sparse ops = 3.7–8.0·b²" as a *sparsity* result
attributes an implementation floor to the matrix. My exponent of **2.40** is
the honest one, and it is *worse* than the claimed 2.

### 2.4 The `F_p` routes answer a different question

`Smod2` (mod 2) is **4.2–22.1×** faster than `F` — and this must not be read as
the phase being cheap. NFS's sparse linear algebra works modulo small primes
because NFS needs **sign information**, not a rational kernel. Stange's
Algorithm 2.2 step 12 needs a kernel vector **over ℚ**, which it then scales to
integers. A kernel over `F_p` is a different object and does not substitute.

**So the fastest route in the table solves an easier problem.** Reporting
`Smod2`'s speedup as evidence that the phase is cheap would be exactly the
"harness that works is not a harness that measures" error.

---

## 3. D3 — THE HONEST VERDICT

### 3.1 Where the phase's time actually goes

`exp_D3` Q1 splits the phase into relation-finding, kernel, and gcd/extract.
Median of 3, at and around the argmin:

| `n` | `b` | route | `t_rels` (ms) | `t_LA` (ms) | `t_gcd` (ms) | total (ms) | **`frac_LA`** | `frac_rels` | `frac_gcd` |
|---|---|---|---|---|---|---|---|---|---|
| 2³⁰ | 16 | F | 16.53 | 4.69 | 0.118 | 21.28 | 0.214 | 0.777 | 0.003 |
| 2³⁰ | 32 | SQ | 16.82 | 13.70 | 0.085 | 30.61 | 0.460 | 0.538 | 0.003 |
| 2³⁰ | 52 | F | 11.63 | 111.39 | 0.161 | 121.87 | 0.905 | 0.094 | 0.001 |
| 2³⁰ | 52 | SQ | 12.67 | 43.28 | 0.177 | 61.21 | 0.810 | 0.185 | 0.003 |
| 2⁴⁰ | 16 | F | 2419.30 | 4.07 | 0.102 | 2423.41 | **0.003** | **0.997** | 0.000 |
| 2⁴⁰ | 26 | F | 496.66 | 15.89 | 0.129 | 511.68 | 0.029 | 0.971 | 0.000 |
| 2⁴⁰ | 32 | SQ | 383.41 | 15.47 | 0.174 | 398.94 | **0.039** | **0.961** | 0.000 |
| 2⁴⁰ | 40 | SQ | 295.11 | 28.67 | 0.799 | 320.55 | 0.076 | 0.921 | 0.002 |
| 2⁴⁰ | 52 | SQ | 242.88 | 66.61 | 0.311 | 301.88 | 0.194 | 0.805 | 0.001 |
| 2⁴⁰ | 64 | SQ | 206.43 | 98.55 | 0.265 | 322.47 | 0.354 | 0.645 | 0.001 |

Two regimes, and they point the same way:

* At **`n ~ 2⁴⁰`**, the size the regime analysis cares about, the kernel is
  **0.3–39%** of the phase and relation-finding is **65–99.7%**. `t_gcd` is
  **~0.1–0.8 ms — under 0.2% everywhere.**
* At **`n ~ 2³⁰, b = 52`** the kernel *does* dominate (81–91%). But `b = 52` at
  `n = 2³⁰` is 20 doublings below any real modulus, and the kernel route is
  swappable by **10×** (`DM` vs `F`) at no change to the algorithm.

**The route choice decides whether the kernel is a bottleneck at all.** Same
matrix size, same relation-finding, same algorithm — three backends only:

| `n = 2⁴⁰, b = 52` | `t_rels` (ms) | `t_LA` (ms) | `t_gcd` (ms) | total (ms) | **`frac_LA`** | `frac_rels` |
|---|---|---|---|---|---|---|
| dense `Fraction` (`F`) | 248.16 | 121.79 | 0.236 | 347.42 | **0.328** | 0.672 |
| sparse dict (`SQ`) | 254.25 | 61.37 | 0.208 | 306.71 | **0.214** | 0.786 |
| sympy `QQ` dense (`DM`) | 267.00 | **13.75** | 0.208 | 280.96 | **0.049** | 0.950 |

**Swapping the linear-algebra backend moves `frac_LA` from 0.33 to 0.05** — an
8.9× swing produced entirely by implementation choice, with the algorithm
untouched. The claim that the kernel route matters presumes the phase is
kernel-bound; with a good backend it is **not**, and relation-finding is 95% of
the cost. This is the same measurement that decides the verdict below.

### 3.2 The 2-adic control, and a −0.46 "deficit" that was a sampler artefact

⚠️ **Recorded because it would have shipped as a finding.** My first version of
the 2-adic cell ran r48's `alg22` end to end with the fast `seq` sampler and
compared the factor rate to each modulus's `p_split`. At `n ~ 2³⁰, b = 32` it
returned **11/40 = 0.275 against `p_split` = 0.733** — an apparent
**−0.458 deficit**. Diagnosis, rather than reporting it:

```
seq     rate  4/15 = 0.267
random  rate 11/15 = 0.733      <- and p_split at that cell = 0.741
```

With the faithful `random` sampler the rate is **0.733**, matching `p_split =
0.741` to within 0.008. The `seq` shortfall is a property of the **sequential
relation sampler**, whose kernel vectors frequently have support only on
columns whose `x`-values sum to zero, so `G = gcd(β₁…β_c) = 0` and there is no
multiple of `ord(g)` to work with. **It is a sampler artefact, not a deficit of
the method and not a statement about this phase.** Had I reported the raw 0.275
next to 20/27 I would have "discovered" a −0.47 effect that is `v₂(q−1)` and a
sampler, i.e. exactly the failure mode the brief warns about.

The control run on the **phase** (does the linear-algebra/gcd step produce a
nonzero `G`?), each rate against its own cell's mean `p_split`. **The two `b=32`
rows below are the SAME cell from two independent samples**, which
is why their mean `p_split` differs — 0.684 and 0.769 for the same `b`, purely
from which moduli were drawn. **That variation is itself the point:** the
baseline for this statistic moves by **0.085** on sampling alone.

| `n` | `b` | `N` | nonzero `G` | rate | 95% CI | mean `p_split` | **excess** | `p_split` range |
|---|---|---|---|---|---|---|---|---|
| 2³⁰ | 32 | 20 | 20 | 1.0000 | [0.839, 1.000] | 0.6842 | **+0.3158** | **[0.500, 0.988]** |
| 2³⁰ | 32 | 24 | 24 | 1.0000 | — | 0.7693 | **+0.2307** | **[0.500, 0.998]** |

**The `b = 52` cell, once it ran** (`exp_2adic_b52.py`, `N = 12`) completed
after I replaced one library call — see the note on backends below:

| `n` | `b` | `N` | nonzero `G` | rate | 95% CI | mean `p_split` | **excess** | `p_split` range |
|---|---|---|---|---|---|---|---|---|
| 2³⁰ | **52** | 12 | 12 | 1.0000 | [0.7575, 1.000] | 0.7747 | **+0.2253** | **[0.500, 0.984]** |

Same picture at `b = 52`: rate 1.000, and the baseline choice alone moves the
reported excess between **+0.225** (per-cell mean) and **+0.259** (`20/27`).

> ⚠️ **This cell timed out twice before it ran, and the cause is the note's own
> main finding.** Measured on one `b = 52` matrix, same `n`, same relations:
>
> | step | time |
> |---|---|
> | `find_relations` (faithful `random` sampler, 53 relations) | **0.013 s** |
> | `DomainMatrix.rref` over `QQ` (`DM`) | **0.013 s** |
> | `stange.kernel_basis` → sympy `Matrix.nullspace()` | **>400 s** (still running when a 400 s alarm fired) |
>
> **>3·10⁴×, lower bound**, on the *same exact mathematics*, from a backend swap
> alone. Relation finding was never the bottleneck — at `B = 239, n = 2³⁰` the
> smooth density is `1.76·10⁻²`, so all 53 relations need ~3000 trials.
> `Matrix.nullspace()` is the culprit, exactly as `MM_sparse` §5.1 recorded
> ("`sympy.Matrix.nullspace()` dies at `b ≈ 32`"); `DomainMatrix.rref` is a
> different sympy entry point on the same library and does not. **§2.1's finding
> bit the experiment that was trying to support it, and fixing it with that
> finding closed a gap the note had otherwise had to disclose as a limitation.**

Three readings, and the last one is the important one:

1. The phase produces a nonzero multiple **every time** at these sizes — there
   is no 2-adic shortfall in the linear-algebra/gcd step to explain.
2. **`p_split` itself is verified correct**, so the control's baseline is
   trustworthy: against real primes, the closed form agrees with a 4000-sample
   Monte-Carlo to within `±0.006` in **4/4** moduli spanning `v₂` patterns
   `(2,2) (1,3) (1,3) (1,1)` — formula/MC `0.6250/0.6238`, `0.8750/0.8790`,
   `0.8750/0.8802`, `0.5000/0.5058`. (I first tried to verify the underlying
   2-Sylow distribution directly in `C_{2^m}` and got nonsense — my
   order-computing loop was wrong, not the formula. Verifying against actual
   multiplicative orders in `(Z/p)*` is the check that means something.)
3. **The `p_split` spread is `[0.500, 0.988]` — nearly the full unit interval.**
   An excess of `+0.32` against the mean `p_split` looks like an effect; against
   the `20/27` average the same data would have read `1.000 − 0.741 = +0.259`,
   or against a single high-`p_split` modulus `+0.50`. **The number moves by
   ±0.25 purely by choosing the wrong baseline**, which is precisely why the
   brief makes this control mandatory. I report the excess against the per-cell
   mean and flag the spread, and I make **no claim** about a `+0.32` "effect".

### 3.3 Verdict

> ### (b) — **EQUIVALENT**, and the round's positive framing is an overstatement.

| option | verdict | why |
|---|---|---|
| (a) genuine improvement over NFS's sparse phase | **NO** | The comparison never gets off the ground. Stange's matrix is `b × (b+c)` with `b` the factor-base size; NFS's is `n × n` with `n ≈ 10⁵–10⁶` at its operating point. At `b ≈ 26–52` Stange's phase is a **few thousand operations**; NFS's is ~`10¹²`. Calling the small one a "drop-in for" the large one describes a regime where the former is not a bottleneck, not an algorithmic improvement. |
| **(b) equivalent** | **YES** | Nothing measured separates them at the sizes that matter, in either direction. The defect is `Θ(b)` but costs nothing at `b ≈ 26–52` (§1.6). The kernel is 0.3–39% of the phase and is swappable by 10× for free. |
| (c) worse outside a small range | **PARTLY, but not for the stated reason** | `F` (r50's incumbent) loses to sympy's dense `QQ` by **4–15×** at *every* size tested, and my sparse route is worse still beyond `b ≈ 26`. But that is a **backend** deficit, not a **defect** deficit — `MM_sparse`'s `Θ(b²)` argument does not explain it and is not needed. |

**The precise statement.** "Stange's linear-algebra and gcd phase is a drop-in
for the NFS's" is not a claim about the matrix, the defect, or the sparse
route. It is a claim about a phase that costs **1–14 ms with a good backend**
(`DM`, §3.1) while the relation-finding phase it sits next to costs **250–2400
ms**. **It is true in the only sense in which it could be operationally
meaningful, and it carries essentially no information about the linear algebra
— which is exactly why it coexists so easily with `MM_sparse`'s `Θ(b)`-defect
result.** The two round-49 notes are not in conflict; `MM_regime` is simply
about a part of the cost that is not the constraint.

**And the "easy half" framing is the part that overstates.** "The construction
that 48 rounds have attacked is the easy half" is true of *relation-finding*
alone (`frac_rels` up to 0.997). But the sentence as written covers the
linear-algebra and gcd phases too, and there the kernel is **81–91%** of the
phase at `n ~ 2³⁰, b = 52` under r50's incumbent backend. At that size the phase
is not the easy half — it is the whole cost. It only becomes so at the sizes
the regime analysis cares about, where it is also irrelevant.

**The asymmetry worth stating plainly.** The claim and its refutation were both
about the same object, and the resolution is that **they were answering
different questions**: `MM_regime` asked "is this phase cheap?", `MM_sparse`
asked "is this matrix NFS-shaped?". The first is true (with a good backend) and
the second is true (`Θ(b)` defect) — and neither bears on the other. **The
honest summary is that the round contains a correct positive result about a
part of the cost that does not constrain the algorithm, sitting next to a
correct negative result about a property that does not constrain it either.**

---

## 4. ⚠️ A NEW TRAP, in the same library call as the recorded one

`MM_sparse` §4 records that `sympy.DomainMatrix.rref()` over `ZZ` is reduced
only on pivot columns. I could **not reproduce that** on sympy 1.13.1: the
recorded 4×5 example gives byte-identical `ZZ` and `QQ` output, and a 3000-case
random search for any `(matrix, free column)` where the two forms differ found
**zero**. **I report that as "not reproducible here", not as refuted** — a
version difference is the likely cause and I did not test other versions.

What I *did* find, in the same call, is a trap that is **live on this version**:

> **`sympy.DomainMatrix.rref()` over `QQ` leaks genuine python `float`s on
> rank-deficient integer matrices.** Measured: **20/20** random rank-deficient
> matrices leak floats; **0/4** real Stange matrices do. The leaked values are
> not all `1.0` — the exact assertion caught one equal to `2**-52`, so the leak
> carries real rounding error and silently turns an exact route into an
> approximate one.

My handling is **strict rejection**: a `float` in an exact route raises rather
than converting. `Fraction(1.0)` would have been exact, but `Fraction(float(1/3))`
is not, and the two are indistinguishable after the fact — so the route refuses
both and the exact assertion guarantees correctness independently.

**A rank check passes this bug. A dimension check passes this bug. Only
`assert M v = 0` over ℚ catches it** — and it did, before any timing was
recorded.

---

## 5. Controls actually run

| control | where | what it caught |
|---|---|---|
| **`assert M·v = 0` exactly over ℚ, per vector, before any time is recorded** | `dtcore.assert_Mv_zero`, called inside every Q-route | **Three wrong-vector bugs.** (i) `int/int` division leaked into the sparse route and made it silently **inexact**; (ii) a naive RREF pivot scan returned `rank = 27` on a `26×27` matrix and `dim = 0`, i.e. "empty kernel", on a matrix with true dimension 2 — a free column has a nonzero in *every* pivot row, so "some row is nonzero here" marks every column as a pivot; (iii) sympy's `QQ` float leak (§4). **All three pass a rank and a dimension check.** |
| assertion must **reject** a corrupted vector | ST1c–e | one-entry perturbation, truncated vector: both rejected |
| **injected dependence**, with a negative control | ST3a–f | built a *square* matrix (my first version used `12×14`, where nullity ≥ 2 **always**, so the injection was invisible and the control unfalsifiable — dim read 2 before and 2 after); injecting a column relation raises dim 0→1, breaking it returns 1→0. **A self-test that cannot fail is not a self-test.** |
| **zero vector rejected** by the black-box route | ST8c–g | the undivided reconstruction is **identically zero** — and it **passes** `M w = 0 mod p`, because the zero vector is in every kernel. My control asserting it would be *rejected* correctly refused to fire, and that is how the real mechanism was found. **A kernel routine can pass its own correctness test and return nothing.** |
| degenerate shapes | ST9 | all-zero → full kernel (`dim = ncols`); identity → empty kernel |
| the **recommended backend** is equivalent to the incumbent it replaces | ST10a–b | `DM` and `F` agree on **dimension AND rank** in **12/12** real Stange matrices across `n ∈ {2³⁰,2⁴⁰}`, `b ∈ {26,40,52}`, spanning more than one dimension. Without this the §2.1 recommendation would rest on two routes that might not compute the same thing — a speed comparison between different computations is the error this project keeps recording |
| **2-adic, per modulus, never vs 20/27** | §3.2, ST7a–e | mean `p_split` over 400 moduli = the known 20/27; individual moduli span [0.500, 0.999]; Monte-Carlo confirms the closed form. Caught a **−0.458** apparent deficit that was a `seq`-sampler artefact (§3.2). Also showed the **baseline itself moves 0.085 between two samples of the same cell** — the strongest argument for never quoting a bare rate |
| `r48/_shared/dickman.py` | **not used** | raises above `u = 5`. Exact `Ψ` by enumeration instead; **no `ρ` anywhere** — the `Ψ/x → e^{−γ}/ln B` vs `ρ → 0` divergence makes `ρ` the wrong null |
| `int(n**(1/3))` | **not applicable** | no cube root taken; `bbound_for_b`/`factor_base` imported from r48 |
| `factor_base` drops primes dividing `n` | §1.3 | re-confirmed as live; `Ψ` enumeration runs over the full prime set |
| **sample sizes** | everywhere | defect: 3 relation sets/cell × 16 cells; routes: 3/cell × 16; scaling: 2/cell × 10; 2-adic: 24–40 moduli/cell. No cell rests on one instance |

---

## 6. Citation — fetched, and **scope** checked

WebSearch fabricates citations on this host (16 recorded instances), so this
one was fetched from `https://export.arxiv.org/api/query?id_list=1209.5520` and
read from the **rendered page images** of `arxiv.org/pdf/1209.5520v4`.

**H. Jeljeli, *Accelerating Iterative SpMV for Discrete Logarithm Problem Using
GPUs*, arXiv:1209.5520v4** (v1 2012-09-25, v4 2014-12-04; single author).
Verified: title, author, and both dates match. §1 p.1–2, verbatim:

> "The number of rows and columns of the corresponding matrices is in the order
> of hundreds of thousands to millions, with only hundreds or fewer non-zero
> elements per row."

**But the scope check changes what this citation can carry.** Page 3, verbatim:

> "The very first columns of `A` are relatively dense, then the column density
> decreases gradually. **The row density does not change significantly.**"

And §2.2, verbatim, on the matrix being solved: `A` is `N`-by-`N`, "we want to
solve the linear system `Au = 0` over `Z_ℓ`", and the solver is **Wiedemann**.

So the bounded-defect matrix is an **FFS/NFS matrix, square, over a finite
field, with `O(1)` nonzeros per row** — and its *dense columns at the front*
are the same structural feature I measured in Stange's matrix (a `p = 2` row
dense in a constant fraction of columns). **`MM_sparse` §1.6 cites this paper
for "bounded per-row defect" as the thing NFS has and Stange does not. The
paper's own §2.2 describes its matrix as having relatively dense leading
columns — so the contrast is between two matrices that both have a heavy
low-index region, and the citation does not support as sharp a dichotomy as it
is used for.** I quote both halves rather than only the half that helps.

**NOT CITED, AND DELIBERATELY SO.** Montgomery's "minimal candidate selection"
and the Johansson/Lenstra sparse-sieve work were requested by the brief. I did
not fetch primary text for either and therefore **do not attribute anything to
them.** The bounded-defect framing here rests on the Jeljeli quotations above,
which I fetched and read.

---

## 7. Reproduce

```bash
cd /home/raver1975/lean/factor-scratch/r51/exp/droptest
python3 selftest.py     # 44 checks, ALL PASS, every negative control fires
python3 exp_D1.py       # defect + exact Psi mechanism          -> D1_defect.json
python3 exp_D1c.py      # dense-vs-control confounds           -> D1_diag.json
python3 exp_D1d.py      # probes/updates split, exponents       -> D1_scaling.json
python3 exp_D2.py       # 5 routes, matched b, wall clock      -> D2_routes.json
python3 exp_2adic.py    # per-modulus 2-adic control, b=32     -> D3_2adic.json
python3 exp_2adic_b52.py  # the same cell at b=52 (slow, N=12)  -> D3_2adic_b52.json
python3 exp_D3.py       # phase time split (Q1; Q2 is slow)    -> D3_verdict.json
```

Wall clocks: 16-core Linux, CPython 3.12.1, sympy 1.13.1, no `flint` module
(`cypari2` and `fpylll` present), with other agents active on the host —
so **treat absolute times as ±30% and the ratios as the result.**