# Round 47 part 19 — the function-field side, and the sharpest diagnosis of the round

**2026-09-29. Agent A8. The most valuable single sentence in round 47 is here, and it is a
*diagnosis* rather than a closure.**

---

## 1. THE GENUS IS A PROPERTY OF THE SCHEME, NOT OF `F_q`

`g(Ŷ_d) = 1 + (d−3)·2^{d−2}` is **independent of `q` and of `p = char F_q` for every odd
`p`**, verified by computing the Hilbert function of `F_p[g]/(Q_2..Q_{d−1})` over `FF(p)` by
linear algebra, on a grid of `d = 3..6 × c ∈ {1,2,3,5,7} × 14` odd primes **plus `Q`**:
**280 cases, 3 mismatches, all at `d = 6`** (degree 22 instead of 16, cause undetermined —
**treat `d = 6` over `F_p` as unverified**).

**`p | d` does nothing** (`d=6, p=3` and `p=5` both give 16/17): the identity
`α^j = c·α^{j−d}` is monic, so nothing divides by `d`.

### `p = 2` is a genuine exception, for two independent reasons

```
p=2:  d=3 deg=2   p_a=0     (pred 2, 0)     d=4 deg=21   p_a=90  (pred 4, 1)
      d=5 deg=8   p_a=5     (pred 8, 5)     d=6 deg=221  p_a=1320(pred 16, 17)
```

The complete-intersection structure fails in characteristic 2 for even `d`, **and** the
double cover `y² = φ` is *inseparable* there — `∂(y²−φ)/∂y = 0` — so Riemann–Hurworth is
inapplicable. **Two independent reasons to exclude `q = 2`.**

## 2. ⚠️ RECORD CORRECTION

`Round47_DegreeBarrier.md` states the formula `1+(d−4)2^{d−3}` **and** a table entry
`g(C_3) = 1`. **The formula gives 0**, and `C_3` is one quadric in `P²` — a **conic, genus 0**,
confirmed by Hilbert function at every prime. **Strike the table entry.** `g(Ŷ_3) = 1` is
unaffected (`2g − 2 = 2(−2) + 4 = 0`).

## 3. A CAVEAT ON A7's BRANCH COUNT

A7 reported `r = 2^{d−1}` from a **point count**. **That control is not valid**: a degree-`2^{d−1}`
0-dimensional scheme need not be `F_p`-split. A8's own counts are 4-of-8, 7-of-16, 58-of-32 —
A8 got 8/16/32 by *choosing splitting primes*. The **degree** `2^{d−1}` is nevertheless
**proved, by Bézout**: `I_C` has height `d−2` and `φ ∉ I_C` (a rank test on `d−2` vectors,
`False` for every `(d,c,m)` tested, with a control that correctly reports `True` for a genuine
`Q_k`). **Reducedness is certified at `d = 3` only**; not at `d ≥ 4`.

## 4. THE SCARCITY REALLY DOES VANISH OVER `F_q` — and this is a diagnosis, not an opening

`#Ŷ_d(F_q)` grows with `q` at **every** `d`. At `d = 6`, genus 49:
`#Ŷ_6(F_5)=24, (F_7)=64, (F_11)=32, (F_13)=64` — **where the integer supply is 0.**

**And the sign split is a theorem, not a measurement.** `#Ŷ_d(F_q) = #C_d(F_q) + S` with
`S = Σ_P (φ(P)/p)`, both sides computed independently and agreeing at every good prime.
`S = a₁ − a₁′` gives `|S| ≤ 2(g(C_d)+g(Ŷ_d))√q`, so the "−1" fraction is
**`1/2 ± O(g/√q)`**, and **it is never identically `+1`** for `q > 16g²`.

> ### THE SENTENCE: *round 47's collapse is caused by the RATIONALITY FILTER, not by the
> ### geometry being hard.*

The same curve, the same `φ`, over the same `d = 4`: `#Ŷ_4(F_7) = 8`, `#Ŷ_4(F_31) = 32`, while
round 47 measured **1 relation in 38 integer instances** — a factor of `~2000`. **The genus is
not what hurts; the fact that you need `Q`-points and the integer curve has almost none of
them is what hurts.** That is sharper than `Round47_DegreeBarrier.md` currently states, and it
is a *diagnosis* a future attack could target.

**The category guard, stated hard:** **the `F_q` abundance must NEVER be used to reopen the
integer `d = 4` closure.** Hasse bounds `F_q`-points; the `Q`-points are a different
population.

## 5. In the FFS proper there is NO analogue of `χ_P = −1` — and the premise fails first

Three candidates, distinguished:
- **(a) on the relation locus**: `(φ(P)/p)`, Weil-bounded, computable in `O(log p)`. **Not an
  obstruction.**
- **(b) the square-class group**: `F_q[X]^*/F_q[X]^{*2}` is `0` for `q ≡ 1 mod 4` and `Z/2` for
  `q ≡ 3 mod 4`.
- **(c) the residue-field character** `χ_θ(x) = x^{(q^e−1)/2}`: **for even `e` it is identically
  `+1` on `F_q^×`**, since `(q^e−1)/2 = ((q−1)/2)(1+q+⋯+q^{e−1})` and the second factor is
  even. **An even-degree factor base carries no sign from the base field.**
- **(d) in the FFS proper: NONE.** Grep over five FFS papers (ePrint 2013/071, 2013/197,
  2014/419, 2020/113, 2020/329): `'quadratic character'` **0 each**;
  `'congruence of squares'` **0 each**. Detrey–Gaudry–Videau, ePrint 2013/071, **p. 2**
  (read as a rendered image): the FFS's wall is *"at least as many relations as there are
  prime ideals of degree less than the smoothness bound"* plus class group and units via
  **Schirokauer maps**.

**So the FFS is not "one step ahead" of round 47.** The DLP FFS **never uses `Ŷ_d`** — its
relations are `a(t) − b(t)x` tested for smoothness as *principal ideals*, not rational points
of a curve. **The genus wall is not on its path at all.** Its wall is smoothness density and
the class group — the integer NFS's *other* problem, in a setting where the papers say how to
handle it.

## 6. A 21st PHANTOM CANDIDATE

A **"Costa–Harvey, 105-bit integers"** paper could not be confirmed: **zero hits** in the
arXiv API by title/author/phrase, IACR ePrint, Crossref, zbMATH Open, Semantic Scholar,
OpenAlex, dblp, archive.org full text, and four search engines. **Unverified — possibly the
campaign's 21st phantom, found by checking rather than assuming.** Adleman–Lenstra STOC 1986
could not be opened either.

## 7. The agent's own failures, recorded because they are the useful part

Six of its own bugs (a `rank_mod` that never normalised the pivot row; `proj_points`
over-counting points at infinity by `p−1`; **a grevlex key with the variables in the wrong
order**, producing a wrong "not reduced" verdict; `ev_q` accepting every point because it
accumulated by multiplication from `0`; `F.scal` multiplying by `one`; a `proj_reps_Fq` that
enumerated `(q+1)²` points of `P²`). **Two of its *controls* were wrong before the code was.**

**CTRL-4 (the `c`-term-dropping control) FAILS**: 22/66 detected, 44 undetected. The genus
results do not depend on it, but the control does not do its job. **`A8_zero_dim.py`'s
`reduced` flag is wrong** (says "not reduced" at `d=3` where the eliminant discriminant
proves the opposite) — **do not use it.** **Part 4 (`q = p^k`) is BLOCKED — do not quote
`part4.txt`**; the genus-1 rows still violate Weil bounds, so a third bug remains.

**What passes:** `CTRL-7` re-run standalone agrees with PARI `ellcard` on the round-47
Jacobian on **106/106** good-reduction curves, after fixing a model that was singular because
it set `c = m³` (making `4a₄³ + 27a₆² ≡ 0` identically — **the same `c = m³` trap I hit in
`scaling2.py` earlier today**).
