# Round 47 part 18 — the auxiliary-information axis, mined for the first time in 47 rounds

**2026-09-29. The brief's scope includes "the adjacent partial-key literature" and the
record cites ZERO papers in it. That is now fixed, and the axis is closed — with a sharper
result than "nothing there".**

---

## 1. The threshold, and what it is actually a fraction *of*

**Herrmann–May, ASIACRYPT 2008, p. 3, verbatim from a page image:**

> *"our analysis for arbitrary `n` yields a bound `ΠᵢXᵢ ≤ N^γ` that holds no matter how the
> size of the unknowns are distributed among the `Xᵢ`… **a fraction of `ln(2) ≈ 70%` of `p` is
> always sufficient to recover `p`**. Unfortunately, the running time… **the dimension of the
> lattice basis that we have to `L³`-reduce grows exponentially in `n`**. Thus, our algorithm
> is polynomial time only if `n = O(log log N)`."*

**And the `1/4` that the record and I both had wrong.** Herrmann–May, same page: *"Coppersmith
showed that this can be done in polynomial time given **50% of the bits of `p`**."* Confirmed
independently in Bernstein–Blekherman–Jenkings–Shor–Trop (ASIACRYPT 2013) §5.2.

> **`1/4` is a fraction of `log N` — i.e. of the SIZE OF THE INTERVAL CONTAINING `p` — which is
> HALF THE BITS OF `p`.** Not a quarter of the bits. **Coppersmith CRYPTO '97 is not the source
> of the `1/4`; the `1/4` is the interval bound, and the bit count is `1/2`.**

## 2. MY PREMISE WAS WRONG AND THE AGENT REFUTED IT

I asked whether the bound for a **random, non-contiguous** subset of `p`'s bits is much weaker.
**It is not.** The `ΠᵢXᵢ ≤ N^γ` bound holds *"no matter how the size of the unknowns are
distributed among the `Xᵢ`"* — **positions are irrelevant; only the count matters.** The
threshold for random bits is the same `ln 2 ≈ 0.6931` of the bits of `p`.

## 3. The derivation, from the determinant rather than quoted

`det(L) = ΠXᵢ^{s_{xᵢ}} N^{s_N}` with `s_{xᵢ} = C(m+n, m−1) = dm/(n+1)`, `d = C(m+n,n)`;
LLL + Howgrave-Graham condition
`2^{d(d−1)/(4(d−n+1))}·det(L)^{1/(d−n+1)} < d^{−1/2} N^{βτm}`, optimal `τ = 1−(1−β)^{1/n}`.

- `n = 1`: `1 − 3(1−β)² = 1/4` — the classical Coppersmith interval bound.
- `n → ∞`: `β + (1−β)ln(1−β)`, i.e. **`1 − ln 2 = 0.3069` of the interval unknown.**

The assumptions are **uniform coefficients mod `N`** (uniqueness by counting, p. 2) and
**Assumption 1, algebraic independence** (p. 5) — **not contiguity, and not a uniformity
condition on the leaked bits.** Bernstein et al. report Assumption 1 *"did not hold in
general"* experimentally. **So the multivariate extension is contingent on an assumption that
is known to fail in experiment.**

## 4. The real barrier is running time, not threshold

| | threshold |
|---|---|
| contiguous, polynomial time | **half the bits of `p`** |
| arbitrary/random positions, **any** running time | **`ln 2 ≈ 0.6931`** of the bits of `p` |
| arbitrary/random positions, **polynomial time** | **unknown — nothing below `0.6931` for `p` alone** |

For a random subset `n = Θ(log N)`, and HM's own words: the lattice dimension *"grows
exponentially in `n`"*, giving `(e/ε)^{Θ(log N)}` — `2^{372}` for 1024-bit `N`, computed and
checked. **Their algorithm is polynomial only for `n = O(log log N)`.**

**So the frontier is a running-time barrier, not a threshold barrier.** Anyone who tells you
"random bit leakage is a much weaker case" is wrong about the threshold and right about the
cost.

## 5. Heninger–Shacham and the honest open list

CRYPTO 2009, p. 2: `δ = 0.27` (leaking `p, q, d, d_p, d_q`), `0.42` (`p, q, d`), **`0.57`
(leaking `p` and `q` JOINTLY)** — and, verbatim, ***"this threshold applies only to our
particular approach."***

**Open:** the `ln 2` bound with a polynomial-in-`log N` lattice for `n = Θ(log N)` (blocked on
exactly the determinant above); Assumption 1; the HS thresholds themselves. CHHS (ASIACRYPT
2016) prove the **univariate** `N^{1/d}` is optimal — **the multivariate half has no such
theorem.**

## 6. Two source corrections

- **Bonas–Heninger–Kachisauskas–Nguyen is NOT VERIFIED**; that title belongs to
  **Takayasu–Kunihiro (ISPEC '13 / IEICE '14)**. Another phantom, in a paper I wrote.
- **Howgrave-Graham–Seifert** was not read (CT-RSA '02, not in the free archive). **Do not cite
  it from this file.**

## 7. The verdict

**This axis yields no factoring method, and that is the deliverable.**

The threshold structure is now completely clear and mostly *better* than the record assumed
(random positions cost nothing at the threshold; the binding `ln 2` is *higher* than the
classical `1/2`-of-bits). The barrier is the lattice dimension, and it is exponential in the
number of unknown bits. **That is a clean, structural reason why auxiliary-information
factoring has not become a general factoring method in thirty years of trying** — and it is a
better answer than the record's silence on the subject.

**The one concrete next experiment, and it is one determinant:** implement Herrmann–May's basis
and swap the simplex for a random monomial set, then check
`det(L)^{1/(d−n+1)} < d^{−1/2} N^{βτm}` at the same `Σγᵢ`. **One determinant, one `if`.**
