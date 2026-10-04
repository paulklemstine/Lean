# Round 97g — the bivariate probe: ill-posed for bits-of-p, and an honest isolation failure for bits-of-both

**2026-10-04. NO new factoring algorithm and NO exponent improvement.** This round
attacks the multivariate sub-`N^{1/4}` gap now that the univariate lattice is
validated (97f). It lands three findings: (1) the "multivariate beats `n/4`"
question is **ill-posed** for the standard bits-of-`p` threat model (only one
small unknown exists), (2) the genuine bivariate model is bits-of-**both** `p`
and `q`, and (3) an honest, twice-caught **negative** on a from-scratch bivariate
lattice.

---

## 1. Well-posedness: the standard threat model is UNIVARIATE

For the standard model — adversary knows the top `k` MSBs of `p` only:

$$ p = a + x,\quad a = p_{\text{hi}}X\ (\text{known}),\quad 0\le x < X. $$

There is **exactly one small unknown, `x`**; the divisor `p = a+x` is "known up
to `x`". This is a one-variable small-root problem `f(x)=x+a ≡ 0 (mod p)` —
precisely what the validated univariate lattice of 97f solves, and precisely
what CHHS bounded degree-free. **There is no second variable for a multivariate
method to exploit.**

> **So "can multivariate beat `n/4`?" is ill-posed for the bits-of-`p` model.**
> The CHHS "multivariate/bivariate-integer" open remark concerns *different*
> threat models — bits of **both** `p` and `q`, or bits of the CRT exponents —
> which genuinely have two small unknowns.

(97b's `p/q` coupling was about *low* bits, and is consistent: high bits of `q`
are *independent* information, i.e. a different, stronger model.)

## 2. The genuine bivariate model: bits of both `p` and `q`

With `p = a+x`, `q = b+y`, both `x,y < X`, and `(a+x)(b+y)=N` — a **bivariate**
equation in two small unknowns. This is the real multivariate-Coppersmith setting.

## 3. The honest negative (and two caught false positives)

I built a bivariate shift-polynomial lattice (monomials `x^i y^j`, exact
integers, LLL) and tested it with **structural** recovery (reading integer roots
off the recovered polynomial) — never by scanning `X`.

* **False positive #1 (caught).** A first version "recovered" factors at
  `kx=ky=6` (below `n/4=8`). But it found roots by **scanning all `X` values** —
  at `X=1024` that is trivial brute force. Discarded.
* **False positive #2 (caught).** A structural version returned empty at the
  same scale, confirming #1 was brute force.
* **The genuine result.** With structural recovery and brute force infeasible
  (`n≥40`), the bivariate lattice recovers **nothing**: no integer roots, no
  factor, at `kx=ky = n/4` and above.

**Resultant-based recovery (added).** Every reduced vector vanishes at `(x₀,y₀)`,
so `Res_y(H₁,H₂)` vanishes at `x₀` — a fully structural route (no scanning).
Tried pairs of reduced vectors from a richer shift set (`cmax,umax` up to 3,4):
**no integer root** even at `k=n/4`, where the **validated univariate solver
succeeds**. This localises the failure precisely to multivariate **isolation**:
the ad-hoc shift basis never produces the two independent short vectors the
Howgrave-Graham bound requires, so no resultant isolates `x₀`.

**Precise diagnosis.** Every bivariate shift polynomial `x^u y^v · g(x,y)^c`
(with `g(x,y)=(a+x)(b+y)−N`) vanishes at the true root `(x₀,y₀)` — *verified*.
The lattice therefore **contains** the root, but LLL does not produce a vector
short enough to **isolate** it: my ad-hoc shift basis does not meet the
multivariate Howgrave-Graham short-vector condition. Choosing a basis and
parameters that satisfy that bound is the substantial multivariate step — not a
quick fix.

## 4. Honest scope

* **No new factoring algorithm. No complexity beaten.**
* New: the **well-posedness clarification** (§1) — the multivariate-`n/4`
  question does not apply to bits-of-`p`, which redirects the open problem to
  the (genuinely bivariate) bits-of-both model; and an honest, **diagnosed**
  negative on a from-scratch bivariate lattice (§3), with the isolation gap
  pinned down.
* **Not claimed:** that no bivariate method exists (literature has working
  multivariate Coppersmith — my basis choice is simply not yet H-G-optimal);
  only that *this* construction fails its own structural test, with the reason
  identified (isolation, via direct and resultant recovery).
* The **univariate** solver of 97f is re-confirmed working on fresh instances,
  so the negative is specific to the multivariate construction, not a broken
  tool.

**Next attack.** Build the bivariate lattice from a **reference** multivariate
Coppersmith (May's *Solving Problems with Small Roots mod a Divisor* /
Jochemsz–May ASIACRYPT 2006) with its shift-polynomial basis and H-G parameter
selection, and validate it structurally as 97f validated the univariate one.
Then measure the bits-of-both threshold against `n/4`. Either a threshold below
`n/4` (a genuine bivariate gain) or a confirmation at `n/4` (CHHS extends to
this model) is a real contribution to the open question.