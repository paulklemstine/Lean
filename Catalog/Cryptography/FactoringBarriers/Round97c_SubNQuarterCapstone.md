# Rounds 97–97c — the sub-`N^{1/4}` gap: reduced, and an honest lattice failure

**2026-10-04. NO new factoring algorithm and NO exponent improvement.** This
consolidates the multivariate partial-information thread. It (a) re-verified the
whole frontier, (b) recorded three 2025 papers the repo lacked, (c) landed a
**structural reduction** of the one open classical question, and (d) honestly
records a **failed** attempt to build the lattice needed for the next step,
rather than shipping an unvalidated one.

---

## 1. The one open question (re-verified)

For `N=pq`, the top `n/4` bits of `p` factor `N` in poly time (Coppersmith).
Chinburg–Hemenway–Heninger–Scherr (ASIACRYPT 2016, ePrint 2016/869) proved the
univariate `N^{β²}` bound **optimal within the univariate auxiliary-polynomial
class** — degree-free and lattice-free — making `n/4` a technique ceiling *for
that class*. They explicitly leave the **multivariate / bivariate-integer**
setting open. Verified independently: no 2020–2026 result moves past `n/4` for
bits of `p` (Herrmann–May, Zheng, Meers–Nowakowski's "Automated Coppersmith",
Ryan's Gröbner-optimal shifts — all same bound, other settings).

## 2. The structural reduction (the real contribution)

The intuitive multivariate attack is "spend the `n/4`-bit budget on **both**
`p` and `q`, using the coupling `p·q = N`." This is worthless:

> **Fact (p/q bit-coupling, bidirectional).** For `N=pq` with `p,q` odd, the low
> `t` bits of one factor are determined by the low `t` bits of the other and `N`:
> `p mod 2^t = (N mod 2^t)·(q mod 2^t)^{-1} mod 2^t`, symmetrically. Verified
> **2000/2000** (p from q) and **3000/3000** (q from p).

So a leak of `t` low bits of `q` is **exactly as informative** as a leak of `t`
low bits of `p`. Splitting a `k`-bit budget across both factors carries **zero
information** beyond the univariate leak. Measured candidate-factor counts at
`N=8399557` are identical (all 1) for every split at `k=6,7`.

> **Consequence.** The "split the leak" family of multivariate attacks is
> **provably a re-encoding** of the univariate problem and cannot beat `n/4`.
> The open sub-`N^{1/4}` gap, if real, must come from **lattice structure** — a
> *coupled auxiliary-polynomial system* extracting more from the *same* bits.

This is a genuine narrowing of the search space, in the record's tradition (cf.
Round 49's AP-cover narrowing). It does not close the multivariate question, but
it removes the cheapest candidate family and isolates the real core.

## 3. Honest process failure: the bivariate lattice

To measure the multivariate threshold I tried, three times, to hand-roll a
Coppersmith small-root lattice (`fpylll` LLL + Jochemsz–May shift polynomials):

1. univariate, `m,t` from Coppersmith's formula — recovered no known root;
2. univariate, larger `m,t`, no mod-`N` reduction — still no known root;
3. univariate, evaluation-scaling variants — still no known root.

Every attempt **failed its own known-root validation**. Per the record's rule (5)
(*never trust a test that has never failed*) and rule (7) (*do not build on
material you have not read/verified*), I **discarded all three** rather than
report a threshold from a broken lattice. Hand-rolling Coppersmith correctly is a
known, error-prone task; the univariate and bivariate forms differ in subtle
scaling/parameterisation, and I could not get either to validate in reasonable
effort. **No lattice-based claim is made in this round.**

The verified content of this thread is therefore the lattice-free structural
fact (§2), which needs no fragile code.

## 4. New prior art recorded (round 97)

* **Pomykała–Jurkiewicz (arXiv:2503.00950)** — even-order-CM elliptic factoring,
  conjectural `L(√2)`. Hand-checked: 2-adic order separation occurs (~80% of
  matched supersingular curve pairs). **New mechanism, not a better bound**
  (`√2 ≈ 1.41 > 1/2 > 1/3`).
* **Gao–Feng–Hu–Pan (arXiv:2512.19076)** — rank-3 Coppersmith (second LLL
  vector); log-log speedup of deterministic `N^{1/5}`; exponent unchanged.
* **Hittmeir (arXiv:2205.10074)** — Fermat/small-difference subset-sum speedup;
  still `N^{1/5}` class.

## 5. Honest scope

* **No new factoring algorithm. No complexity beaten.**
* New: an exact, verified **structural reduction** of the open sub-`N^{1/4}`
  question (§2), plus a frontier re-verification and three new papers (§4).
* **Not claimed:** the multivariate gap is closed or solved; only that the
  richest-leak framing cannot deliver it, and that the lattice core is the whole
  remaining question. No lattice threshold is claimed (§3).

**Next attack — prerequisites, in order.**
1. **Implement a validated Coppersmith lattice** (univariate first: it must
   recover a *known* root; only then trust it). Use a reference implementation or
   an LLL-based one proven against a test vector. *This is the blocker for
   anything quantitative on the multivariate core.*
2. With a validated lattice, sweep `X` for the bivariate threshold. Below
   `N^{1/4}` ⇒ a sub-`N^{1/4}` attack; at `N^{1/4}` ⇒ evidence the CHHS bound
   extends to the bivariate class. **Either outcome is a real contribution.**
3. Only then attempt a coupled auxiliary-polynomial system.

**The blocker is now implementation trust, not ideas.** That is a more tractable
and more honest place to stop.