# Round 53 — the coupling is real, and orthogonal to the search

**2026-10-04. NO new factoring algorithm. A clean negative, and the clean negative is the
informative one.** Round 50's free 1.2× base conditioning was transplanted verbatim onto the
**number-field base**, where the search *is* sieveable — the synthesis round 52's phase separation
pointed at and nobody ran.

**It works exactly, and it is worth nothing.** `20/27 → 8/9`, ratio **1.2000**, at **`q = 1`**,
zero cost. **`GAIN ∈ {0, 1}` for every `(k, rule)`, never `> 1`.**

Paper: **`Papers/the_coupling_is_real_and_orthogonal.md`**.
Code: `factor-scratch/r53exp/synth/` (selftest **29/29 PASS**, 5 experiments, **~35 s** total).

---

## 1. The mechanism, in one line

The number-field relation condition is `a² ≡ b^k (mod p)`. Write
`lam_p = v₂(p−1) − v₂(ord_p b)`. Then, **exhaustively verified on 23 004 (base, `k`, prime)
triples**:

```
b^k is a quadratic residue mod p   <=>   NOT( lam_p = 0 AND k odd )
```

**23 004/23 004 agreement.** This is the whole negative in one line: **the NFS search's
dependence on the base's 2-adic structure passes through the single bit `lam_p = 0` — the
quadratic character — and every higher 2-adic digit is invisible to it.**

## 2. The two arms

**`k` even — legal, free, and worth nothing.** Root count of `a² = b^k (mod n)` is **4.000 for
every base**, in 8/8 rows at 16/18/20/24 bits. `s_C/s₀ = 1`, **`GAIN = 1.000`**.

**`k` odd — annihilating.** `Jacobi(b/n) = −1` puts a non-residue on one side, so for odd `k` that
prime admits **no `a` at all**: `P(p) = P(q) = P(n) = 0` **exactly, in 40/40 moduli** at every
size. `s_C = 0`, **`GAIN = 0`**.

## 3. The apparent 1.32× win is noise, and a permutation test says so

The relation-yield rate produced a **1.318×** row at 18 bits — which would exceed Result A's
entire 1.2×. **Every such row is `power = NO`** (`E[hits] < 20`), and §1 says the effect must be
**exactly zero** for even `k`. Tested as a null: the arms share moduli *and* roots, only the label
moves, so the permutation test is exact.

```
replicates : 40     permutations : 240
REAL   ratio : median 1.231  [0.583, 2.000]
PERMUT ratio : median 1.062  [0.391, 2.167]   real inside band?  True
permutation p-value  P[perm >= real] = 0.354
```

**Positive control — the instrument can fire:** the same statistic on `k = 3` gives **0 roots in
120/120** moduli where `k = 2` gives 480.

## 4. ★ The phase separation is NOT an artefact

Round 52's objection was that the coupling had only been *looked for* on the base side. **It is
present on the number-field side too, large, and free:**

| rule | `P(v₂(ord_p b) ≠ v₂(ord_q b))`, N = 400, 24-bit |
|---|---|
| uniform | 0.7625 |
| **`jac_neg`** | **0.8850** |

**And Result C applies harder than measured:** CRT-exactness is a **bijection** here, verified by
**exhaustion** on **24/24 cells, 0 departures**.

> **So the coupling is real, large, free, and ORTHOGONAL to the search variable.**
> **The barrier round 50 removes is not present on the number-field side in the first place** —
> there is no per-attempt Bernoulli to lift, because the NFS relation rate is governed by
> **smoothness**, not by a 2-adic order statistic. **`s_C/s₀ = 1` is the absence of a target, not
> a failure of the trick.**

## 5. The open construction problem, precisely

> A construction with both properties must make its success event depend on a local
> order-statistic of the base that **(i)** is a quadratic character, so it is controllable from `n`
> alone at `q = 1`, **and (ii)** enters the relation condition through a quantity **not already
> determined by `b mod p`** — because every function of `b mod p` alone is CRT-separated from
> `b mod q`, and a search polynomial in its index can only ever see the joint residue.
>
> **The 2-adic advantage must live in the KERNEL of what the sieve index can see, not in the base
> it is sieved against** — a periodic sub-structure in the exponent. **No choice of `b`, and no
> choice of `f`, can do it.**

## 6. ⚠️ RETRACTION: round 52's `ord_n(g)/n = 1.000`

An inherited instrument (`r52exp/design/dcore.py::order_mod`) **returned its input on 496/496
pairs**. It strips prime factors of `m`, but `ord_m(a) | λ(m)` for `m = pq`, so the strip test
never fires. At the call site it runs on the **primes** and returns `p` and `q`, so
`lcm(p,q) = pq = n` **exactly**. Since `λ(n) < n` always, **`ord_n(g) = n` is arithmetically
impossible** — and every reported value was exactly `n`.

**Sharpest single correction:** at 16 bits the header's "630× the sieve limit" is **10×**; true
period 665, `λ(n)` = 3 990. **Overstated ~63×.**

**A second, independent defect:** the "verified 3/3 periodicity" was **vacuous** —
`all(hits[i]==hits[i+T] for i in range(0, W−T))` with `W = min(2T, 20000)` and `T ≫ W` gives an
**empty range**, so `all([])` was vacuously `True`. **The claim is nonetheless true when properly
tested: 15/15 periodic at the TRUE `ord_n(g)`, 0/15 with any period ≤ 64.** The mechanism is
real; the verification of it was empty.

**Blast radius: narrow** (one call site). **Unaffected:** the `20/27` barrier, sieveability, the
`q = 1` identity, CRT exactness, and every conclusion above. **Poisoned:** `ord_p_g`, `ord_q_g`,
`ord_n_g`, `ord_n_over_n`, and the printed sieve-limit multiple.

## 7. Two fabricated citations, one PROVEN false

**★ "Schnorr–Seysen–Bauer" is a PHANTOM.** zbMATH: 2 hits, both **single-author Martin Seysen**.
arXiv: **0 results**. What *is* real is Seysen's Math. Comp. **48** (1987) 757–780 — the
**binary quadratic-form / class-group** method, not a QS lattice paper.

**★★ "Coppersmith, *Two-dimensional lattice based cryptanalysis*, ANTS-I, LNCS 877, pp. 41–55"
does not exist — PROVEN, not merely unverifiable.** The complete ANTS-I TOC (Crossref by ISBN, 35
chapters) has **zero** Coppersmith chapters, and **pp. 41–55 are occupied by Dodson–Haines (41),
Paulus (42), Couveignes–Morain (43–58)**. *There is no room.* Corroborated against Coppersmith's
complete zbMATH bibliography (**137 records**, none in ANTS/LNCS 877). **`LNCS 877` IS ANTS-I
(1994)** — confirmed twice.

> **Provenance flag, recorded because it nearly propagated.** A verification sub-agent asserted
> **"LNCS 877 is ANTS-II (1996)"** — **wrong** (ANTS-II is ed. Cohen; Elkenbracht-Huizing is
> **LNCS 1172**). **Its conclusion was right and the volume claim was wrong**, which is this
> programme's signature failure: a correct conclusion laundered through a fabricated detail.
>
> **Both phantoms were supplied by me as candidate leads.** The failure mode is **bidirectional**:
> not only does the retriever invent — **the asker invents and the verifier launders the guess into
> a checked-looking verdict.** Host tally: **18**.

## 8. ★ The real mechanism has a standard name we were not using

The quadratic-character rows in NFS linear algebra are real, and rest on **five full texts read**,
not one. **The standard name is "quadratic character base", and it is Briggs's** (MSc thesis,
Virginia Tech 1998, §4.3) — *"Each binary vector e(a,b) is also augmented with information
relating a particular `a + bθ` to **the quadratic character base**."* Chain: Briggs (1998) →
**Buhler–Lenstra–Pomerance** §8/§12.7, **LNM 1554** (1993) → **Adleman, STOC 1991**.

**Four cautions, each load-bearing:**

1. **"Practically certain" is a heuristic, not a theorem** (Elkenbracht-Huizing's own wording).
   Calling it *proved* to be an index `2^r` **strengthens the source beyond what it says.**
2. **★ The character rows are NOT structurally necessary.** Briggs treats `m` as a cost knob, and
   Cavallar et al., *RSA-512* §3.3: **"In particular, all quadratic character rows are omitted."**
   **The 512-bit record factored without them.** Treating them as necessary, or quoting a constant
   gain, over-reads.
3. **★ "index `2^r`" and "2-adic" are NOT in this literature at all** — counts for Jacobi,
   Legendre, "2-adic", torsion, "index `2^r`" are **ZERO across all eight full texts.**
4. **★ SCOPE:** in the **quadratic sieve** there is **no such parity constraint** — a QS relation
   already forces `x² = y`. **The apparatus belongs to the NFS**, where `F_i(a,b)` is only *almost*
   a square. **Do not carry a QS/NFS claim across that boundary.**

**The failure mode is documented and has no name:** Cavallar et al. §3.4 — *"One job found the
factorization after 39.4 CPU-hours, **the other three jobs found the trivial factorization**."*
The literature's only name for it is **"the trivial factorization."**

## 9. Ten bugs the controls caught in my own code

Full list in the paper. The four that would have shipped as confident wrong numbers: the inherited
`order_mod`; **a vacuous exhaustive test that printed `[PASS]`** (0 cells tested); **a biased
pooled estimator** producing a spurious `z = +5.94`; and **sampling a congruence** instead of
enumerating it (`NO TRIALS` on 8/8 rows). Plus one in my own *fix*: the corrected assertion was
initially **symmetric**, so it would have **passed the very bug it was written to catch.**

## 10. Honest scope

**Classical factoring of RSA-scale integers. Not a cryptographic break.** No factoring on any
modulus of cryptographic interest; largest `n ≈ 2²⁸`, locally generated. **Nothing about the true
NFS regime** — `π(B*) ≈ 10¹⁵–10³³` is uninstantiable here and is not extrapolated into. The
16–20-bit relation-yield rows are `power = NO` and were used **only** to generate the noise
hypothesis that §3 refutes independently.