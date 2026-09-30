# Round 47 part 35 — the independent audit of the method: PARTLY CONFIRMED, and it breaks my headline

**2026-09-29. Agent A15, re-deriving and re-implementing from scratch, with no round-47
code. Issue #515 has been amended in place. This is the most valuable document the round
produced after the method itself.**

---

## Confirmed — the parts that matter

1. **The derivation agrees with the Lean, exactly.** `c0 = g0²−2Qg1g2`,
   `c1 = 2g0g1−2Pg1g2−Qg2²`, cone `g1²+2g0g2−Pg2² = 0`, parametrisation
   `g = (Pv²−4u², −4uv, 2v²)`, `l(m) = v⁴A(t)` with `A` a quartic. At `P = 0` this is
   `4u⁴+8mu³v−4cuv³+mcv⁴`, which is `RelationAlgebra.A` verbatim. **All 12 Lean cross-checks
   pass**: `l₁ = 640`, `l₀ = −256`, `l(20) = 112²`, `g(20) = 2864`, gcd → 43 and 31,
   `Norm(g) = −22528 = −2¹¹·11`.
2. **Reproduction exact**: 12 moduli, `H = 200` → **149 trials, 68 hits, 68 correct**.
3. **Break-it, over 319 relations:** the gcd **fails to divide `N` in 0/319**; **non-prime
   factors in 0/136**; no proper divisor other than `p`, `q` in **0**.
4. **The gate is exactly what makes the output non-degenerate:**
   **`P(split | χ_P = −1) = 136/136 = 100%`**, while **`P(split | χ_P = +1) = 0/182`**.
   The output `gcd(w − g(m), N)` **does** return `N` — 140 times out of 182 `+1` cases — **but
   never at `χ_P = −1`.** That is the real content of the method, and it is a perfect
   predictor.
5. **`N` is never factored — proven, not assumed.** AST audit: `trial()` binds no `p`, `q`.
   **Tripwire**: the author's own `trial()` runs to completion with `p`, `q`,
   `sympy.isprime` and `sympy.factorint` wired to raise — **none fired**. 13/26 hits,
   matching the auditor's own.

## Refuted — two of my claims

1. **The scaling table is an artifact of a frozen polynomial selector.** `find_m_c` restarts
   at `m0 = icbrt(N)+1` on **every call**, so **50 calls yield ONE distinct `f`**. Therefore
   `706/706` is *one relation counted 706 times*, and `772 trials / 0 hits` is *one frozen `f`
   counted 772 times*. **The only reproduced number is `68/68` on 12 moduli at `H = 200` — and
   the ~46% rate is the 12–14-BIT rate only.**

2. **"Roughly half the moduli are dead" is REFUTED.** Varying `f`:
   **21 bits 17/60 = 28% · 25 bits 9/60 = 15% · 33 bits 3/60 = 5% · 37 bits 2/60 = 3%.**
   Over **30 moduli × 120 distinct `f`: 0/30 dead.** No modulus is dead. The *per-`f`* rate
   simply decays with size — and **I had misread my own frozen selector as a property of
   the moduli.**

## The corrected state — worse for the method, better for its honesty

| | |
|---|---|
| the algorithm | **real**, and the `χ_P = −1` gate is a **perfect** split predictor, 136/136 |
| descent / factorisation of `N` | **none** — proven by AST audit and a live tripwire |
| per-`f` success rate | 14 bits 0.27–0.34 · 21 bits 0.28 · 25 bits 0.15 · 33 bits 0.05 · 37 bits 0.03 |
| moduli with no successful `f` | **0 / 30** |
| cost crossover, brute `f`-scan | **≈ 24 bits** |
| cost of a **lattice** `f`-scan | **unknown — the decisive quantity** |
| supply at large `N` | **unmeasured — the second decisive quantity** |

**A real method with a perfect gate and a rapidly-decaying supply. Not a competitor.**

## The decisive experiment, now well-posed

> Run the `H = 2000` census on a **26-bit** modulus over **≥200 distinct `f`**, and see
> whether the per-`f` rate **plateaus or keeps falling**.

That single number decides whether this is a method above ~64 bits or a curiosity below 30.

## The methodological lesson, which is the round's real lesson

**A frozen selector looked exactly like a structural boundary.** `find_m_c` restarting at
`m0` every call is indistinguishable, in the output, from "these moduli are dead" — and I
read it that way, wrote it into three documents, and posted it as an issue headline.

> **Before believing a negative, check that the thing you varied actually varied.** I
> believed a boundary in the *moduli* and it was a constant in the *selector*.

The auditor's own bugs, for the same reason: `T5b` had inverted logic, and `find_factors`
had a stray `pow(d,1,1)` — equal to `d mod 1 = 0` — that silently made the first
reproduction report **0 trials**.
