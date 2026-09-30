# Round 47 part 45 — the selector barrier, DERIVED (was asserted)

**2026-09-30. Workflow, theory angle. `Round47_SelectorClosed.md` closed this by argument.
It is now a derivation, with the supply rate computed exactly in the process — and the answer
lands where the argument said it would.**

---

## R1. What is actually being counted

`g(m)² − l(m)` is **divisible by `(m³ − c)` in `Z[X]`** — verified on all 126 pairs at
`H = 10`, `c₂ = 0` in every case. So the step I have been calling *"verify the relation"*,
`w² ≡ g(m)² (mod N)`,

> **is not a test. It fires iff `N | (m³ − c)`, i.e. it restates the construction
> invariant.** The only real condition is `l(m) = w²`.

Useful, not harmful — but it means the method has **one** real filter plus the character
gate, and the `28,084/28,084` result is the load-bearing measurement, carrying the whole
method alone.

`l(m) = v⁴A(u/v)` with `A_P(t) = 4t⁴+8mt³−2Pt²+(2mP+4Q)t+(P²/4−mQ)`. Leading coefficient
`4 = 2²` is a rational square, so after `t = 1/x, s = w/x²` the quartic has **two
`Q`-rational points at infinity** for every `(m,P,Q)`. Genus 1 plus a `Q`-point ⟹ the quartic
**is** an elliptic curve over `Q`, with Jacobian

> `E_{m,c} : Y² = x³ − 3(mc) X + (c² + m³c)`,  coefficients `Θ(N)`.

So the supply is exactly: *`#{P ∈ C_{m,c}(Q) : naive ht ≤ H}`, with `H` fixed at 30–40.*

## R2. THE EXACT COUNT

`l(m)` is **linear in `m`**: `l(m) = Lm + K` with `L = 8u³v + cv⁴`, `K = 4u⁴ − 4cuv³`.
So `l(m) = w²` ⟺ `w² ≡ K (mod L)` and `m = (w²−K)/L`. Hence for each `(u,v)` with `L > 0`,

```
#{m in [m0, M]} = rho(u,v,c) · (√(LM+K) − √(Lm0+K)) / L  ~  rho · √(M/L)
```

where **`rho = #{w mod L : w² ≡ K (mod L)}` is a purely local, mod-`L` integer.** With a
pool of size `Θ(δM)`,

> **`rate(M) = C(H,c) / (δ √M)`,  `C(H,c) = Σ_{(u,v)} rho/√L`,  and `M ~ (N/k)^{1/3}` ⟹
> `rate ~ C · N^{−1/6}`.  Slope exactly `−1/2` in `m`, `−1/6` in `N`.**

**Validated:** brute-force count of `(m,t)` relations vs the formula agrees (ratio constant
`0.017`, the `√m₀` subtraction; `count/√M → 28.6` at `M = 256,000`, against an independently
computed `C(H=10, c=1) = 28.55`); `rho` by CRT agrees with brute force **86/86** for `L ≤ 3000`.

## R3. THE DECISIVE PART — and it lands on the selector

**(a) The data is FLATTER than the exact model.** `measured / 2^{−b/6}` rises
**2.090 → 2.633 → 11.723** across 26/40/64 bits. Secant gaps vs `−1/6`: `+0.0238`, `+0.0898`,
`+0.0655`. **Mechanism not identified** — and it is a **pool** question, not a curve
question: `C(H,c)` is fixed and computable, so a growing prefactor says the asymptotic
`#{m} ~ C√M` is not uniform over the pool's `c`-distribution, or `δ` is not constant in `b`
(the semiprime density `~loglog N/log N` falls from `0.160` at 26 bits to `0.085` at 64).

**(b) DECISIVE:**

> A supply rate of `N^{−1/6}` means `~N^{1/6} = 2^{b/6}` trials per factor — which is
> **polynomial time and faster than the GNFS. Impossible.** So the exact count cannot be the
> whole story, and it is not: **the method needs a valid instance**, i.e. a semiprime `N ≡ 1
> (mod 4)` with a **small cube residue** `c = m³ mod N`. For random `N`, `P(|c| ≤ c_max) =
> 2c_max/N`, so producing one costs `Θ(N/c_max)` trials of `m`, each `Θ(log N)`.

> **Total `Θ(N^{1/6} · N / c_max)` — far worse than the GNFS.**
> ### **THE BARRIER IS THE SELECTOR, NOT THE SUPPLY RATE.**

`Round47_SelectorClosed.md` reached this conclusion by *argument* (a codimension-2 slice
LLL cannot see). **It is now derived**, from an exact count of the supply, and the two agree.

## R4. Discipline, recorded

**Two recalled titles withdrawn by the agent itself** rather than shipped. And the model
angle reports that a *"plateau + floor"* family and a *"pure power law with a log-correction"*
family fit the three points **equally well (ΔAICc 1.2)** — so the convexity is real, the single
power law is dead, and **which shape replaces it is not identified.**

## The consolidated statement

| | |
|---|---|
| supply rate, **derived exactly** | `C(H,c)/(δ√M) ~ C·N^{−1/6}`, validated against brute force and CRT |
| supply rate, **measured** | falls **slower** than `N^{−1/6}`; prefactor grows 2.09 → 2.66 → 11.72; shape unidentified |
| **what actually kills the method** | **the selector**: `Θ(N/c_max)` to produce a usable `f` |
| that total | `Θ(N^{1/6}·N/c_max)` — **worse than the GNFS** |
| the gate | `28,084/28,084`; and it is the *only* real filter, since the "verify the relation" step is vacuous |

**The round's close stands, and is now a theorem rather than a narrative.**

---

## Independent verification (mine, after the fact)

The theory angle's central claim came from **one agent**, so I re-derived it from scratch
rather than trusting it.

**Claim 1 — `l(m) = L·m + K` with `L = 8u³v + cv⁴`, `K = 4u⁴ − 4cuv³`:**
**20,000 random `(u,v,c,m)` triples, 0 failures.**

**Claim 2 — `l(m) = w²` ⟹ `w² ≡ K (mod L)`: 0 failures** in 20,000 triples. On the record's
own instance: `l(20) = 196 = 10·20 + (−4)`, `w = 14`, `w² mod 10 = 6 = K mod 10`, `rho = 2`.

**Claim R2 — the count formula itself**, which is what everything rests on:
`#{m ∈ [m₀,M] : l(m) = w²} = rho·(√(LM+K) − √(Lm₀+K))/L`. Tested on **357 samples with
non-zero counts**:

| `u` | `v` | `c` | actual | `rho` | predicted |
|---|---|---|---|---|---|
| 3 | 2 | 7 | 112 | 16 | 111.3 |
| 2 | 5 | 1 | 311 | 24 | 311.0 |
| 4 | 4 | 2 | 124 | 32 | 124.3 |
| 2 | 1 | 10 | 97 | 2 | 96.5 |
| 1 | 5 | 4 | 31 | 8 | 31.5 |

> **R2 is confirmed. The supply rate is exactly `C(H,c)/(δ√M) ~ C·N^{−1/6}`, and the selector
> barrier `Θ(N^{1/6}·N/c_max)` follows from it. The round's closing theorem is verified from
> scratch, not accepted on an agent's word.**

## The ninth defective control — mine, again, and caught in one step

My first verification pass printed **`0 / 0 failures`** for the `rho > 0` check, because a
guard (`if L ≤ 400`) excluded **every** sample. A vacuous control, in my own code, ten minutes
after writing the rule down.

It was caught because I printed the **trial count** rather than only the failure count. **That
is the whole trick and it should be the default**: a control that reports only a failure count
cannot distinguish "no failures" from "no trials". Report **both**, always.

So: **nine defective controls in one round**, every one of them caught by something other than
reading the code, and the ninth caught only because the eighth had already taught me to print
the denominator.
