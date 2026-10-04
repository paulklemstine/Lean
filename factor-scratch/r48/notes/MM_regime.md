# MM — The proved regime is independent of `c`, and the gap is in the GUARANTEE

**Round 49 · 2026-10-03 · is Stange's `n ≥ 8b^{b/2}` regime extendable by the free parameter `c`?**

Code: `factor-scratch/r49exp/regime/` — `fwregime.py` (regime arithmetic),
`selftest.py` (**123/123 PASS**), `exp_cliff.py` (measurement),
`analyze.py` (statistics), `results/`. Fetched sources and rendered page images in
`regime/work/`. **No commit, no issue, no paper.**

---

## 0. Answer, in the order the brief asks for it

| question | answer |
|---|---|
| Verified regime formula and page | `n ≥ 8b^{b/2}`, `c = b+1`, **Stange arXiv:2211.06821v2 p.4** — image-verified |
| Does `b_max(n,c)` depend on `c`? | **NO — it is flat in `c`, provably, not just empirically** |
| Does the method factor beyond the proved regime? | **YES — no cliff anywhere I can reach** |
| Is the 4.3-order gap in the GUARANTEE or the METHOD? | **In the GUARANTEE.** The regime certifies ≈0.17; the method delivers ≈0.77. |

**The census line should move from "uncompetitive" to "unproven but empirically
viable"** — with the caveat in §7 that the *runtime* argument still fails.

---

## 1. The regime formula, verified from a rendered page image (not from any note)

The local copy `r48/lit/pdf/2211.06821.pdf` is **v1** (13 Nov 2022). A **v2 exists**
(16 Jul 2023) — I fetched it. The operative sentence is **identical in both**, except that
v2 renumbers the citation from `[4]` to `[5]` (because Ekerå was added to the bibliography);
**both point at Fontein–Wocjan.**

**Stange v2, p.4, verbatim, read off a 300 dpi render (`work/stv2_crop2.png`):**

> "If *b* and *n* satisfy the relationship **n ≥ 8b^{b/2}** as *n* tends to infinity, then
> taking *c* = *b* + 1, it is known that the probability has a lower bound [5, Theorem 1.1].
> By contrast, to apply this result to Algorithm 2.2, we need the Hypothesis to hold when
> *b* is subexponential in log *n*."

Three things are settled here:

1. **The base is `b`, not 2.** `n ≥ 8·b^{b/2}`, confirmed on the image. The brief's warning
   about the `8^{b/2}` slip was right to insist on the image; `pdftotext` renders it as the
   garbage token `8bb/2`.
2. **The regime is stated for the PAIR, not the `n`-condition alone** — "then taking `c = b+1`".
3. **The bound is not Stange's.** It is imported from **[5] = Fontein & Wocjan, "On the
   Probability of Generating a Lattice", arXiv:1211.6246v2 [math.CO] 16 May 2013, J. Symbolic
   Comput. 64:3–15 (2014)**, Theorem 1.1. I fetched it; it was not in the repo.

### 1a. A correction to the brief's `b_max` figures

The brief (inheriting r48's note) says `b_max = 27` at `n = 10²⁰`, breaking at `b = 28`.
**That is off by one.** Solving `n² ≥ 64·b^b` in *exact integer arithmetic*:

| b | in regime at `n = 10²⁰`? |
|---|---|
| 26 | **yes** (threshold 19849222985629892608 < 10²⁰) |
| 27 | **no** (threshold 168461554212094390486 > 10²⁰) |

> **`b_max(10²⁰) = 26`, and the regime first fails at `b = 27`.**

r48's own note is internally inconsistent on this: its table says `b_max = 26.8` (the
*continuous* root, which I reproduce at **26.756933940711974**) while the same note's prose
says "at what `b` does the proof regime break? **`n = 10²⁰: b = 28`**". The continuous root is
26.76; the integer maximum is 26; nothing gives 28. All downstream "4.3 orders of magnitude"
figures are unaffected (4.35 orders, using the corrected `b_needed`).

---

## 2. Why `c` cannot help — the decisive structural argument

This is a **reading of the proof**, not a measurement, and it is why the answer is stronger
than a null.

**Fontein–Wocjan Theorem 1.1, p.2, verbatim from a rendered image (`work/fw_thm.png`):**

> "Let Λ be a lattice of full rank in **R^n**, and assume that **B ≥ 8n^{n/2}·ν(Λ)** and
> **B₁ ≥ 8n²(n+1)B**. Assume that **n** vectors are selected uniformly at random from
> Λ ∩ [0,B)ⁿ and **n+1** vectors uniformly at random from Λ ∩ [0,B₁)ⁿ. If the vectors are
> sampled independently, then the probability that all these vectors generate Λ is at least …"

Note F&W's `n` is the **dimension**; Stange's `n` is the **modulus**. The map is forced:

| F&W | Stange | why |
|---|---|---|
| dimension `n` | factor-base size `b` | `dim(Λ_B) = b` |
| window `B` | modulus `n` | relations have entries `< n` (p.4) |
| **`n` samples, window `B`** | **the `b` base relations** | |
| **`n+1` samples, window `B₁`** | **the `c` extra relations** | |

So `b + c` relations must equal F&W's `2n+1 = 2b+1`, giving **`c = b+1` exactly**. `c` is not
a free parameter *inside* the proved regime; it is pinned by the theorem's sample count.

**And now the load-bearing point.** Theorem 1.1 is assembled in §2.3 as
**Corollary 2.3 × Proposition 2.5**:

- **Corollary 2.3** ("Generating a Sublattice of Full Rank", p.4) is the *only* place the
  window condition `B ≥ 8n^{n/2}·ν(Λ)` appears. It uses the **first `n` vectors** — Stange's
  `b` base relations. Its statement contains **no reference to `c`, to `n+1`, or to the second
  window**.
- **Proposition 2.5** ("Generating a Finite Abelian Group", p.6) is where the extra vector
  lives — Stange's `c`. Its statement has **no window condition and no size condition at
  all**: the bound `ζ̂ = Π_{i≥2} ζ(i)^{-1} ≥ 0.434` depends only on "G is a finite abelian
  group generated by `n` elements", and applies to elements drawn uniformly from a group of
  **any** size.

> **The `n ≥ 8b^{b/2}` condition constrains the first `b` relations only. `c` does not appear
> in it, so raising `c` cannot relax it. Prediction P1 CONFIRMED — provably.**

`c` can only ever have entered as the `+1` in "`c+1` random integers share no common factor",
which is a statement about the **probability**, never about the **window size**. There is no
mechanism by which `c` moves `b_max`.

### 2a. The negative control that makes the above non-vacuous

A harness hard-wired to say "flat" would produce my headline answer no matter what. So
self-test **T9** *injects* a `c`-dependence and requires detection. Exact integers,
`n = 10²⁰`, `c ∈ {1,5,10,20,50,100}`:

| condition | `b_max` at each `c` |
|---|---|
| the **true** `n² ≥ 64b^b` | **26, 26, 26, 26, 26, 26** |
| planted `n² ≥ 64·b^b·4^c` | 26, **25, 23, 20, 8, 1** |

The harness fires on a dependence that is there and reports flatness when it is not.
(First attempt planted a factor `(1 + c/b)`; it was too weak to bite — the margin at `b = 26`
is only 5.04× — and the control *wrongly "confirmed" flatness*. Fixed to `2^c`.)

---

## 3. P2 — Stange drops half of the theorem she cites (a new finding)

Theorem 1.1 needs **two windows**. Stange's Algorithm 2.2 draws **all** `b+c` relations from
**one** window: steps 5–9 choose `x` uniformly in `[1,n]` and factor the residue, and p.4
notes "relation vectors whose entries are `< n` have size `O(log n)`". §2.3 of F&W explains
why two are needed: **Lemma 2.6** requires the larger window so that residue classes mod `Λ₁`
are approximately uniform on `Λ/Λ₁`.

Reading the proof, Corollary 2.3's argument only needs its first `n` vectors to come from a
window of size `≥ 8n^{n/2}·ν(Λ)`; and `B₁ ≥ 8n²(n+1)B ≥ 8n^{n/2}·ν(Λ)` already. So sampling
**all** `2n+1` from window `B₁` is valid and gives the **same** `α_n`. The honest
single-window regime is therefore

> `B₁ ≥ 64·n²(n+1)·n^{n/2}·ν(Λ)`  ⟹  **`n ≥ 64·b²(b+1)·b^{b/2}`**

Stange's sentence omits the factor `64b²(b+1)`, which at `b ≈ 21` is **6.2×10⁵**. So her
stated regime is **optimistic**, not conservative:

| `n` | Stange `b_max` | single-window `b_max` | shortfall |
|---|---|---|---|
| 10²⁰ | 26 | **21** | −5 |
| 10⁴⁰ | 46 | **41** | −5 |
| 10¹⁰⁰ | 99 | **93** | −6 |
| 10²⁰⁰ | 177 | **171** | −6 |
| 10⁶¹⁶ | 461 | **455** | −6 |

The `b^{b/2}` shape is untouched — so this is a constant-factor correction, **not** a new
lever. Stange additionally drops `ν(Λ)`, which her `Λ_B` (covolume `φ(n)`) does not obviously
satisfy at 1; I have not pursued that.

---

## 4. P3 — what the regime actually *guarantees*: ≈0.17, not 0.999

The bound Stange inherits is not `1/ζ(c+1)`. It is **α_b** from Theorem 1.1, p.2
(image-verified; note it is a **product**, which `pdftotext` renders as a subtraction):

> `α_n := ( Π_{i=2}^{n+1} ζ(i)^{-1} − 1/4 ) · Π_{k=0}^{n-1} ( 1 − n^{k/2}(4n^{n/2}+1)^k / (4n^{n/2}−1)^n ) ≥ 0.092`

**Verification of my reading of the formula** (self-test T1): the paper's p.10 prints five
values, `0.238, 0.185, 0.176, 0.172, 0.170`, under the label *"For n = 2, 3, 4 and 5"*.
Computing from the formula gives **α₁ = 0.2386, α₂ = 0.1854, α₃ = 0.1764, α₄ = 0.1725,
α₅ = 0.1705** — an exact 5/5 match to `n = 1..5`. **The values are right and F&W's own label
is off by one** (4 values of `n` for 5 numbers); the shifted reading fails at the last value
(`α₆ = 0.1697`, not `> 0.170`). Cross-checked against exact `Q(√n)` rationals (T2, agree to
1e-16). Also `ζ̂ = Π_{i≥2}ζ(i)^{-1} = 0.435757 ≥ 0.434`, the paper's own Prop. 2.5 bound (T3).

| `b` | `α_b` (the proved regime guarantee) | `1/ζ(c+1)` (Hypothesis 3.1's target) |
|---|---|---|
| 10 | **0.1713** | 0.99951 |
| 20 | **0.1754** | ≈1.00000 |
| 26 | **0.1766** | ≈1.00000 |

> **The proved regime guarantees ≈0.17. The paper's own p.5 sentence claims "at least 99.9%
> of the time if c ≥ 9". The theorem it cites guarantees 0.17 — about 5.8× weaker than the
> 99.9% the paper reports for it, and 4.5× weaker than the 0.77 the method actually
> achieves.** Stange's sentence says "the probability has a lower bound" without stating the
> bound; the bound is the interesting part and it is small.

---

## 5. The measurement — is there a cliff at `b_max`?

`exp_cliff.py`, tier A. **Positive control on every invocation:** the paper's own example
`n = 62389, g = 43, B = 50 (b = 15), c = 10` must reproduce `G = 15400` and factor `701`
(p.7 verbatim); otherwise nothing is reported. **Mandatory control:** `M·v = 0` asserted in
exact `Fraction` arithmetic on **every kernel vector** before any `α_t` is formed (320
vectors in the self-test, plus a perturbation negative control).

### 5a. The control that changed every number

My first rates read **0.83–1.00**, far above the 20/27 = 0.7407 that rounds 48/49 report.
That was not the method. r49/U proved the index is erased before the `gcd`, so

> success `⟺ v₂(ord_p g) ≠ v₂(ord_q g)` — the Shor criterion, depending on `g` and `(p,q)`
> and on **nothing the relation search does**.

`20/27` is that probability **averaged over moduli** (`P(v₂(p−1)=j) = 2^{-j}`). At one fixed
modulus it is a *different* number — `p_split(p,q) = 0.5` when both `p,q ≡ 3 mod 4`, and up
to `0.97+`. Reporting a fixed-`n` rate against 20/27 would have manufactured a spurious
"+0.2 from the method". So every cell carries its own `p_split` (exact closed form, self-test
T11 pins its average to exactly `20/27`: `ΣₖE[P₂(k)]² = 1/9 + 4/27 = 7/27`), and the
statistic is the **excess** `rate − p_split`.

**Without this control I would have reported "0.95!" as a method result. It is entirely the
modulus's 2-adic structure.**

### 5b. P4 — no cliff (the headline)

Within one modulus, `c` fixed at 10, sweeping `b` **through** `b_max`:

| n | `b_max` | `p_split` | mean excess **IN** | mean excess **OUT** | `z(OUT − IN)` | `b` reached |
|---|---|---|---|---|---|---|
| ~2²⁶ | 12 | 0.500 | −0.0100 | **+0.0071** | **−0.37** | 19 (7 past `b_max`) |
| ~2³⁰ | 13 | 0.664 | +0.0717 | **+0.0288** | **+0.91** | 21 (8 past `b_max`) |
| **~2³⁴** | **15** | **0.500** | **+0.0278** | **−0.0189** | **+0.90** | **26 (11 past `b_max`)** |

Pooled over all 42 tier-A cells (1860 trials): rate **0.7726** against weighted `p_split`
**0.7608** — **excess +0.0118**. In/out by excess: `+0.0091` vs `+0.0180`.
Tier B alone: **203/408 = 0.4975** against `p_split` **0.5000** — **excess −0.0025**.

> **There is no cliff. The method factors at its per-modulus ceiling both inside and up to 11
> steps beyond the proved regime** (three independent moduli, `b_max` = 12, 13, 15).
> Prediction P4 CONFIRMED.
>
> Stated honestly: at 2³⁴ the point estimate *is* slightly lower outside (−0.019 vs +0.028),
> but the difference is 0.047 against a standard error of 0.052 — `z = +0.90`. **At `N = 24`
> per cell a mild decline of up to ~0.10 cannot be excluded**; a cliff to zero is excluded at
> any plausible size.

### 5c. P5 — the rate does not depend on `c` either

At fixed `(n,b)`, over `c ∈ {1,3,5,b+1,10,20}` (note `c = b+1` is the proved regime's value,
`c = 1` is r49/U's "c is wasted work"):

| n | `b` | `p_split` | pooled rate | cells significantly ≠ pooled | trend in `log c` |
|---|---|---|---|---|---|
| ~2²⁶ | 8 | 0.875 | 321/360 = 0.892 | **0/6** | +0.0058, `t = +0.31` |
| ~2³⁰ | 10 | 0.969 | 293/300 = 0.977 | **0/6** | +0.0019, `t = +0.18` |
| ~2³⁰ | 12 | 0.969 | 286/300 = 0.953 | **0/6** | −0.0013, `t = −0.28` |

No cell deviates at 2σ; no trend. Prediction P5 CONFIRMED.

But the **index** does move, dramatically — and r49/U's reason is confirmed exactly:

> at `c = 1`: `P(h = 1) = 0.000`, **mean `h` = 1035–18028**.
> at `c = 20`: `P(h = 1) = 0.94–0.95`, mean `h` = 1.1–1.4.

`c` buys enormous accuracy on an index that the `gcd` then throws away. That is the same
mechanism as r49/U's "1.63×–2.36× cheaper per successful factor at `c = 1`", now visible on
the same runs.

---

## 6. A defect in the paper's §3 machinery, found by its own assertion (new)

I had to abandon `stange.index_S_full` — the routine behind round 48's `P(h=1)` table — because
**its own correctness assertion fires.** Concretely, at `n = 44934671 = 7193 · 6247`,
`b = 8`, `c = 1`, the primitive kernel vector

> `v = [34, −51, −19, −99, 121, 41, −34, 35, 0]`

satisfies `M v = [719, 0, 0, 0, 0, 0, 0, 0]` — supported **only** on `a₁ = 2`. Stange p.4 says
such a combination "is an integer multiple of `ord(a_i)·s_i`", i.e. `ord(2) | 719`. But

> `ord(2) = 11230308`, and `2^719 mod n = 28600883 ≠ 1` (`mod p = 1515`, `mod q = 2117`).

**The claim is false for Algorithm 2.2's relations.** The reason is a mismatch between
Hypothesis 3.1 and Algorithm 2.2. Hypothesis 3.1 samples relations *from* `Λ_B = {e : ∏a_i^{e_i} = 1}`;
Algorithm 2.2's relations satisfy `g^{x_j} = ∏ a_i^{f_j[i]}`, so **`f_j ∉ Λ_B`**. A combination
supported on `a₁` alone therefore has `ψ`-image `g^{Σ v_j x_j}`, not `1`, and its coefficient
need not be divisible by `ord(a₁)`.

Consequences, stated carefully:
- Algorithm 2.2 itself is **unaffected** — its §2.1 claim (`ord(g) | α_t`) is separately
  provable and I assert it exactly on every trial.
- The `P(h=1)` column in **r48's note (K §4) is therefore not the index of Hypothesis 3.1.**
  Its refutation of Hypothesis 3.1 stands as a measurement of *something*, but not of the
  quantity it names. **This does not change r48's verdict** (H3.1 also fails inside the
  regime, and by far more damningly on its own 1/ζ(c+1) arithmetic), but the *mechanism*
  attributed to it in r48 §4c may not be the mechanism.
- I substituted the index Algorithm 2.2 actually produces, `h = G/ord(g)`.

I am **not** claiming this refutes Hypothesis 3.1; Hypothesis 3.1 is about a different sampling
model. It is a statement that §3's `K_i` construction does not apply to Algorithm 2.2 as
printed.

---

## 7. Verdict, and the census line

> **The regime is independent of `c`, and the method works well beyond it.**

Three separate results, in descending order of confidence:

1. **`b_max(n,c)` is flat in `c` — PROVEN, not sampled.** The condition is
   `n² ≥ 64·b^b`, which contains no `c`; the `c = b+1` is forced by F&W's `2n+1` sample count;
   and the `8n^{n/2}` window lives in Corollary 2.3, which never sees `c`. Corollary 2.3 and
   Proposition 2.5 carry the two halves of the theorem between them, and only the first has a
   window condition. **The question the brief asked is closed, cleanly, on the proof.**
2. **No cliff: excess over the per-modulus ceiling is +0.012 (tier A) and −0.003 (tier B),
   and `z(OUT − IN) = −0.37`, `+0.91`, `+0.90` at the three moduli tested, up to 11 steps
   past `b_max`.**
3. **The gap is in the GUARANTEE.** The regime certifies `α_b ≈ 0.17`; the method delivers
   `0.77`. The binding constraint is the theorem, not the construction.

**So: move the census from "uncompetitive" to "unproven but empirically viable"** — with the
following stated, because they are what the entry must not overclaim:

- **The runtime is still uncompetitive.** Stange's own target `L_n(1/2,β)` needs
  `b = exp(O(√(log n · log log n)))`; `b_max` grows like `2 log n / log log n`. Exact:
  at `n = 10²⁰`, `b_needed = 5.856×10⁵` vs `b_max = 26` → **4.35 orders**; 7.20 at 10⁴⁰,
  13.37 at 10¹⁰⁰, 20.83 at 10²⁰⁰. **"Uncompetitive" was right about the COST and wrong
  about the method.** The success probability was never the thing failing.
- **Everything here is at `n ≤ 2³⁴`.** The regime's whole point is asymptotics in `n`, and I
  cannot reach `n = 10²⁰`. "Works beyond the regime" is established at 1–2 orders of `b` past
  `b_max`, not at 4 orders of `n`.
- **The regime's guarantee is weaker than advertised and weaker than achieved.** Even inside
  the regime the proved number is 0.17, not 0.999.
- **A naive read is optimistic.** Stange's own condition is already missing the
  `64b²(b+1)` of §3, and dropping `ν(Λ)` is a further unquantified optimism.

---

## 8. Reproduce

```
cd factor-scratch/r49exp/regime
python3 fwregime.py     # prints the preregistration, alpha_n vs F&W's own table, b_max tables
python3 selftest.py     # 123/123 PASS
python3 exp_cliff.py A  # measurement  -> results/run_A.log, results/cliff_A.json
python3 exp_cliff.py B  # wide sweep at 2^34
python3 analyze.py      # the statistics of section 5
```

**Sources, both fetched, both quoted from rendered page images, neither in the repo before now:**
- K. E. Stange, *Factoring using multiplicative relations modulo n*, arXiv:2211.06821**v2**
  (16 Jul 2023), regime sentence p.4.
- F. Fontein, P. Wocjan, *On the Probability of Generating a Lattice*, arXiv:1211.6246**v2**
  (16 May 2013), Thm 1.1 p.2; Cor. 2.3 p.4; Prop. 2.5 p.6; §2.3 p.7–8; printed `α` values p.10.

**Bugs this round's self-tests caught in my own code**, each of which would have produced a
fabricated number: a dropped `× n` term in the exact `Q(√n)` algebra of `α_b` (1e-6 error);
`b_needed` missing a `√(log log n)` factor (gave 46 instead of 5.9×10⁵); the wrong
distribution for `v₂(ord_p g)` (`2^{-(k+1)}` instead of `2^{k-1-m}`, averaging to 0.600
instead of 20/27); a Poisson `χ²` homogeneity test invalid at rate ≈ 1 (spurious "c-EFFECT"
at `χ² = 29.5` on 5 df, against 0/6 cells significant by a proper two-proportion test); and a
negative control too weak to fire (§2a).

### Caveats

- All rates are at small `n` (≤ 2³⁴). The regime's claim is asymptotic in `n`; I can only
  test the `b`-direction. `b` was pushed to 26 — **11 steps past `b_max` = 15 at 2³⁴** — but
  that is a factor ~1.7 in `b`, not the factor 10⁴⁰ in `n` that would be needed to close the
  asymptotic gap.
- `N` per cell is 24–60 trials; that is enough to resolve the cliff question (`|z| < 1`) and
  the `c`-question (`0/6` cells significant), and **not** enough to resolve a `c`-effect
  smaller than about 0.10 at `N = 60`, or a post-regime decline smaller than ~0.10 at
  `N = 24`. I claim "no `c`-effect at the 0.1 scale", not "no `c`-effect".
- The `64b²(b+1)` single-window correction (§3) is **my reading of the proof of Theorem 1.1**,
  not a statement either paper makes. F&W do not discuss the one-window variant; their
  **Conjecture 1.2** (p.2) is that `n+1` samples from *one* window suffice — **unproven**,
  resting "on extensive computer simulations". Stange's single-window algorithm is, strictly,
  sitting in Conjecture 1.2's territory, not Theorem 1.1's.
- §6 is a defect in §3's *applicability to Algorithm 2.2*, not a refutation of Hypothesis 3.1.