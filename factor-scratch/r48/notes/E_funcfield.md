# R48 — Factoring via function fields / tori / Jacobians

**Axis.** Replace the ring Z/mZ that ECM walks in by an algebraic structure whose
arithmetic we control — a norm-one torus, a Jacobian, a Picard curve, a tower —
so that the group order is something we choose rather than something we must
search for.

**Bottom line.** The axis is dead, and the number that kills it is
**reach_p = L[1/2]** for the one family that works mechanically. Every other
family cannot even be *sampled* without a square root mod n, which is the
factoring problem itself. One family — the norm-one torus — genuinely factors
(measured: **12/12 splits of an 81-bit N, with no square root and no knowledge
of p**), and that is the most interesting positive result of the round. It buys
a **constant 1.5× over GMP-ECM's x-only ladder and nothing else**.

---

## 0. Self-test first (EARNED RULE #1)

`exp/00_selftest.py` — **ALL PASS**. It caught three real bugs before any number
was believed:

| # | check | result |
|---|---|---|
| A1 | `P + (−P) = O` in E(F_p), p ≡ 3 mod 4, all p in 5..400 | ok |
| A2 | `P + (−P) = O` in **E(Z/nZ), n composite** | ok |
| A3 | `[k]P` double-and-add ≡ k naive adds, k = 1..39 | ok |
| A4 | closure + `f·f⁻¹ = id` in T_D(Z/nZ), 16 values of D | ok |
| A5 | `|T_D(F_p)| = p − (D/p)` **exactly**, 214 (D,p) pairs enumerated | ok |
| A6 | torus walk does find smoothness-separating elements | ok |

Bugs the self-test caught (recorded because they are the reason the rule exists):

1. **add-2007-bl**: `S1` must be `Y₁·Z₂·Z2Z2 = Y₁Z₂³`; and `I = (2H)² = 4H²`
   so `J = 4H³`. My first version had `I = 4H³`, hence `J = 4H⁴`.
2. **Torus inverse**: `(a,b)⁻¹ = (a, −b)`, **not** `(−a, −b)`; A4 failed on
   16/16 D values before the fix.
3. **Scalar mult**: left-to-right must seed with the top bit, not with `None`.

`exp/ell.py` group-law costs are *measured* (mult counts returned by each
routine), not quoted from a library — `cypari2` was dropped because
`ellinit` returns an empty vector at p=23 (`"incorrect type in checkell"`).

---

## 1. THE CRITICAL SUB-PROBLEM — cost to reach p

Everything must be done over Z/nZ with n = p·q, p unknown. `exp/04_sqrt_wall.py`:

| mechanism | can we SAMPLE an element without p? | why |
|---|---|---|
| elliptic, full point | **NO** | need `y² = x³−x (mod n)` — a square root mod a composite |
| elliptic, x-only (ECM) | **YES** | Montgomery ladder never forms y; `b₂ = x³+ax+b` costs 4 mults |
| norm-one torus | **NO** (needs √(1+Db²) mod n) | unless `D = u²−1` — see below |
| genus-2 Jacobian (Mumford) | **NO** | need `u \| (x⁵−x−v²) mod n`: polynomial factorization mod n |

The Jacobian row is **my own lemma with a proof sketch** — Cantor/Mumford
composition needs only that the leading coefficients be units mod n. It is *not*
attributed to any paper; see §9, where an invented citation of mine is retracted
and the **real** prior art (Dryło–Pomykała) is given instead. That work does
Jacobian arithmetic over ℤₙ and derives factoring reductions from an **order
oracle** — the opposite regime from ECM's walk-and-gcd, which is itself part of
this round's finding.

Measured on n = 2.4·10¹² (p,q 41 bits): `f(x)` is a QR mod n for 118/400 = 29.5%
of random x (theory 1/4) and `1+Db²` for 85/400 = 21% — **but combining the two
roots requires choosing the CRT sign, i.e. knowing p.** Explicitly:
`gcd(y₁+y₂, n) = 1208925819660808663073173 = n` and the mixed root
`gcd(r−2, n) = 1009` for r = 1011. A square root mod a composite *is* the
factorization.

**The escape hatch, and it is real.** Choose `D = u² − 1`. Then `f = (u, 1)`
satisfies `a² − Db² = u² − (u²−1) = 1` **as an integer**, so `f ∈ T_D(Z/nZ)` is
built with **one subtraction** — no square root, no knowledge of p.

Then `f^M = (A_M, B_M)` and `f^M = id mod p ⟺ B_M ≡ 0 (mod p)`, so

```
gcd(B_M, n)
```

is a factor whenever `ord_p(f) | M` and `ord_q(f) ∤ M`. This is *exactly* ECM's
structure. **Measured (`exp/05_torus_factors.py`): 12/12 splits of
n = 1208925819660808663073173**, with B = 2¹⁶, log₂M = 204924.

> This is the round's most interesting positive result: a genuine factoring
> method that needs neither a square root mod n nor any knowledge of p.

---

## 2. H1 — is the smoothness rate better than ECM's? **NO. REFUTED.**

**Prediction before measuring:** no. The order of a random element of a cyclic
group of order M is distributed as a random *divisor* of M; M is p±1 for the
torus, p+1+O(√p) for ECM, p^g+O(p^{g-1/2}) for a genus-g Jacobian. Smoothness is
a property of **M**, not of the algebraic structure.

**Measurement with the MATCHED-TWIN control** (`exp/11_h1_matched_twin.py`),
60 primes p ≈ 10⁶ × 250 samples = **15 000 orders per arm**:

| B | function field | TWIN | ratio | σ |
|---|---|---|---|---|
| 64 | 0.1185 | 0.1199 | 0.988 | −0.37 |
| 256 | 0.2838 | 0.2835 | 1.001 | 0.05 |
| 1024 | 0.5168 | 0.5167 | 1.000 | 0.01 |
| 4096 | 0.6333 | 0.6334 | 1.000 | −0.01 |
| 16384 | 0.7500 | 0.7500 | 1.000 | 0.00 |
| 65536 | 0.8667 | 0.8667 | 1.000 | 0.00 |
| 262144 | 0.9667 | 0.9667 | 1.000 | 0.00 |

**|σ| ≤ 0.37 everywhere; ratios 0.988–1.001. H1 REFUTED.**

*Degeneracy found and corrected — three times, and this is the method note that
matters.* A single p pins the rate at **0 or 1**, because p has one large prime
factor in p±1 that every order inherits. Two earlier versions of this script
were therefore vacuous: v1 used p=1000003 where p+1 is entirely smooth below
B=1024 (both arms 1.0); v2 sampled `(u,1)` with D pinned, which is a torus
element only when u² = D+1 (both arms 0.0 garbage); v3 used one 41-bit p (all
arms 0.0). **A control that cannot discriminate is not a control.** The cure,
and the tightest possible test, is to average over many p.

**Jacobian half (`exp/10_jacobian_p2.py`).** Measured #J(F_p) for y²=x⁵−x via
PARI `hyperellcharpoly` — `1 + a + p²`:

| p | #J(F_p) | p² | ratio | (p+1)² |
|---|---|---|---|---|
| 7 | 64 | 49 | 1.31 | 64 |
| 11 | 136 | 121 | 1.12 | 144 |
| 19 | 328 | 361 | 0.91 | 400 |
| 23 | 576 | 529 | 1.09 | 576 |
| 59 | 3400 | 3481 | 0.98 | 3600 |

My initial claim #J = (p+1)² was **wrong** (fails at p=11,19,59); the scale
p²+O(p) is what matters. Hence **u_J = 2·u_E exactly** (2.4914 vs 1.2457 at
B=2¹⁶): the Jacobian is g× worse on smoothness *and* ~5× more expensive per
step. **A function field is strictly worse than ECM at every genus g ≥ 1,
because g = 1 already IS the elliptic curve.**

---

## 3. H2 — can we CHOOSE the order? **The choice is real; we cannot see it.**

First, a correction to my own pre-registered prediction. I predicted the
smoothness rate would be *flat* in the choice parameter. **It is not** —
`exp/06_h2_chooseable.py` and `exp/07_h2_refined.py`:

At fixed unknown p, varying D is bimodal, and the discriminator is **exactly
the Legendre symbol (D/p)**:
- `(D/p) = −1` ⟹ `|T_D(F_p)| = p+1` ⟹ `ord_p(f) | p+1`
- `(D/p) = +1` ⟹ `|T_D(F_p)| = p−1` ⟹ `ord_p(f) | p−1`

Measured at p = 1099511627791: `p+1 = 2⁴·17·241·433·38737` is 2¹⁶-smooth;
`p−1` carries a 3.7·10¹⁰ prime factor. Rates at B = 2¹⁶: **1.000 vs 0.000.**
So **H2 is true in the weak sense** — the choice parameter genuinely matters.

**But the branch cannot be identified from Z/nZ.** `(D/n) = (D/p)(D/q)` *is*
computable in poly(log n) with no factorization (verified 200/200), and it is a
**product**. Measured: among D with Jacobi symbol +1, we find 102 with
`(D/p) = +1` and 105 with `(D/p) = −1` — **(D/n) carries ZERO bits about
(D/p)**. The one bit that would exploit the function field *is the
factorization bit*.

**⇒ reach_p = L[1/2] = the cost of factoring N itself.** Since L[1/2] is the
entire budget, every mechanism needing that bit is dead.

**Towers (`exp/09_tower.py`) — refuted separately.** Raising the level multiplies
the Dickman parameter by k:

| level k | u_k | ln ρ(u_k) | cost vs k=1 |
|---|---|---|---|
| 1 | 7.35 | −12.4 | 1.00× |
| 2 | 14.70 | −39.4 | 3.18× |
| 3 | 22.06 | −71.1 | 5.74× |
| 4 | 29.41 | −105.9 | 8.54× |

A tower is a **loss**, not a tuning knob — and its degree is a function of the
unknown p, so it cannot be selected either.

---

## 4. The cost table (`exp/08_Lhalf_costs.py`), N = 2²⁰⁴⁸, p ≈ 2¹⁰²⁴

**Correction to my own first pass (caught by the literature agent, and it
matters).** I had written `B₁ = exp(√(2 ln p ln ln p))`. That is the **total**,
not B₁ — it double-counts. Brent gives `α ≈ √(2 ln p / ln ln p)` and then
*"Since m = p^{1/α}"*, where m is the smoothness bound. So

```
B1_opt = exp(√( ln p · ln ln p / 2 )) = L_p[1/2, 1/√2]
```

— a factor **2× smaller** than I had. The absolute ln(cost) shifted by ~20; the
**ratio between mechanisms is unaffected**, because it is a constant. Recorded
because the number was wrong, not because the conclusion moved.

α = ln p / ln B₁ = 14.7049, ln ρ = −39.366, ln M = e⁴⁷·¹.

| mechanism | mults/step | ln(cost) | vs ECM x-only |
|---|---|---|---|
| ECM, Montgomery x-only | 6 | 88.24 | 1.00× |
| ECM, full Jacobian coords (measured) | 16 | 89.22 | 2.67× |
| **Torus (sqrt-free, 4 mults exactly)** | **4** | **87.83** | **0.67×** |

The torus wins **1.5×** — a *constant* in the exponent, not an exponent
improvement. And the "good branch" gain is bounded by the ratio of Dickman
values with `ln p` replaced by `ln(p+1)`, a relative change of **1.4·10⁻³** —
noise.

**Caveat that must travel with this table.** The L[1/2] does **not** follow
from the order bound alone; it needs the separate *heuristic* that the group
order behaves like a random integer near p. Brent states it as an accepted
hypothesis ("Lenstra's heuristic hypothesis ... we shall accept Lenstra's
hypothesis as we have no other way to predict the performance"); Wikipedia says
"there is no proof that a smooth group order will be found in the
Hasse-interval". This is the load-bearing unproven step in **every** row, ours
included.

---

## 5. H3 — the genericity obstruction: **confirmed, and sharpened**

The obstruction is real and has a precise name: **the required condition is a
property of the unknown p, not of our choice.** We choose the curve, the
discriminant D, the tower — and the quantity that must be B-smooth,
`#G(F_p)`, is a function of p. So the condition is in generic position
(probability 1 that it fails, density 0 among useful choices), and it is not
tunable by any parameter we control.

This is the same obstruction that killed the multivariate-moduli directions
earlier in this program, with one difference worth recording: **here it is
provable, not merely observed.** The Weil bound forces `#J(F_p) = p^g(1+O(p^{-1/2}))`
and the torus order is `p±1` exactly, so the achievable range of the order is a
two-point set. There is nothing to tune. That is a result, not a null result.

**What is verified here and what is not — and who owns the synthesis.** The
curve side of the asymmetry is solid and quoted below. **No source states the
number-field-vs-function-field asymmetry explicitly** (~60 queries across arXiv
metadata, HAL full text, and a dozen full papers and theses; HAL full-text
search returns zero for every phrasing of the claim). So:

- The **function-field half** is measured here (Weil bound, p±1 two-point
  range, the (D/p) indistinguishability of §3) and quoted below.
- The **number-field half** rests on Lenstra–Pomerance 1992, **which I have not
  read** (AMS PDF 404s).
- **The synthesis is mine.** It should be quoted as this round's argument, never
  as something a source says.

**Two quotes cut against me; recorded so I do not get blindsided.** Joux,
"Technical history of discrete logarithms in small characteristic finite fields"
(HAL hal-01243676), §4: *"The key idea compared to the Hellman-Reyneri
algorithm is to use the freedom we have when representing F_{q^k} and to choose
a representation that helps the construction of multiplicative relations."*
And Detrey, "FFS Factory" (HAL hal-01002419), §1: *"What we propose here is to
leverage the fact that the polynomial selection is far less constrained in the
FFS setting…"*. Both assert that FFS **has** tuning freedom. The answer:
representation/polynomial freedom is a **different axis** from
field-or-group-order freedom, and neither lets you compute the group order
without knowing p. But note both are about *discrete logarithms*, not factoring
— a different problem, so they are adjacent rather than squarely counter-.

**The curve side, verified.** Barbulescu, Bos, Bouvier, Kleinjung, Montgomery,
"Finding ECM-friendly curves through a study of Galois properties"
(HAL hal-00671948v1), §1 p.1 — verbatim, from the PDF I downloaded and read:

> "The success of ECM depends on the smoothness of the cardinality of the curve
> considered modulo the unknown prime divisor p of N. This usually means
> constructing curves with large torsion group over Q or finding curves such
> that the order of the elliptic curve, when considered modulo a family of
> primes, is always divisible by an additional factor."

The second sentence *is* this round's argument: the order is controllable only
through a **family** of primes (torsion over Q), never directly at the unknown p.

**The structural bridge.** Xiong–Zaharescu, arXiv:1007.4621, verbatim from the
LaTeX source (which I extracted and read):

> "The main purpose of this paper is to study #J_C, the size of the Jacobian over
> F. This quantity is also the class number of the function field F(C)"

That clause is the whole asymmetry in one sentence: in the function field the
"class group order" **is** #J(F_q), a function of q; in the number field it is
h(D), a function of your chosen D.

**The second half of the asymmetry, and the fact that function-field parameters
are pinned by a hard constraint.** Barbulescu, Gaudry, Kleinjung, Thomé,
"Selecting polynomials for the Function Field Sieve", arXiv:1303.1998, §1 —
verbatim from the LaTeX source (I extracted and read it):

> "as a preliminary stage of the algorithm. It takes a small amount of time but
> it can greatly influence the sieving stage by slightly changing the
> probabilities of smoothness. In order to solve the discrete logarithm in
> F_{q^n}, the main required property of f,g ∈ F_q[t][x] is that their resultant
> Res_x(f,g) has an irreducible factor φ(t) of degree n."

Note what this concedes and what it concedes *not*. It concedes that FFS
parameter choice **influences** smoothness probabilities — the analogous
freedom to my torus's D. It denies that this freedom reaches the group order:
`f,g` are pinned by the resultant constraint, exactly as my `(D/p)` is pinned by
the unknown p. And it is about **discrete logarithms**, not factoring.

---

## 6. A distinction I should have drawn earlier: GROUP ORDER vs POINT ORDER

*Provenance.* The flag was raised by the literature agent in its **first**
message — correctly, and it did not land because it sat in a caveat rather than
in the sections I was working in. The error was mine (not drawing it in my own
draft), not the flag's absence. Recorded so the next round does not re-learn it.

The literature habitually says ECM succeeds when "the order of the group" is
smooth (HAC above; Wikipedia: "we can expect to try L[√2/2, √2] curves before
getting a smooth group order"). **That is not the operative condition.** ECM
computes `[M]P` and factors when it lands on O mod p but not mod q, which
happens iff

```
ord_P(p)  |  M     and     ord_P(q)  ∤  M
```

i.e. iff the **order of the point** — a *divisor* of #E(F_p) — is B-smooth.
Since smoothness of the group order does **not** imply smoothness of an
arbitrary divisor, the two are genuinely different conditions.

This matters for my own write-up, so I checked which one I measured: **the point
order**, throughout. `ord_torus(f, D, p)` returns the order of the element `f`
in T_D(F_p), and the matched twin is `ord_cyclic` on Z/(p+1)Z — also a
divisor. So the H1 measurement of §2 compares the right quantity against the
right twin. Had I compared `|T_D(F_p)| = p±1` instead, I would have been
measuring something ECM does not actually key on.

It also sharpens the §3 result. The *group order* p±1 is what the choice of D
moves between two values (and I showed that choice is unusable). The *point
order* is a divisor of p±1, so it has further structure to exploit — and my
measurements show it is **not** smoother than a random divisor of the same
number (§2, σ ≤ 0.37). The divisor structure is where any residual hope lived,
and it is measurably flat.

---

## 7. Verdict

**No family survives the reach_p test.**

| family | reach_p | survives? |
|---|---|---|
| elliptic (ECM) | **0** (x-only) | — this is the baseline |
| norm-one torus, D = u²−1 | **L[1/2]** (needs (D/p)) | no — 1.5× constant only |
| norm-one torus, D arbitrary | L[1/2] + sampling impossible | no |
| genus-g Jacobian | L[1/2] + no sampler + order p^g | no — strictly worse |
| Weil restriction / F_{p²} | no model over Z/nZ without p | no |
| CMD / additive lifting | requires p outright | no |

**THE SINGLE NUMBER: reach_p = L[1/2]**, because the one exploitable bit,
`(D/p)`, is exactly the factorization bit, and `(D/n)` — the only symbol
computable without factoring — determines it not at all.

**The positive result worth keeping:** a norm-one torus with `D = u²−1` is a
genuine factoring method requiring neither a square root mod n nor any knowledge
of p (12/12 splits measured), at 4 modular multiplications per step. It is
1.5× cheaper than GMP-ECM's ladder. It is not faster than ECM.

---

## Files

| file | contents |
|---|---|
| `exp/00_selftest.py` | f·f⁻¹ = identity, both structures, tightest cases — **all pass** |
| `exp/ell.py` | Jacobian-projective EC over Z/nZ with modular-mult counting |
| `exp/jlib2.py` | torus arithmetic; exact integer sampler and O(1) sqrt sampler |
| `exp/04_sqrt_wall.py` | the sqrt-mod-composite wall, measured |
| `exp/05_torus_factors.py` | the mechanism works: 12/12 splits |
| `exp/06,07_h2_*` | the D-choice is real; we cannot compute (D/p) |
| `exp/08_Lhalf_costs.py` | cost table at N = 2²⁰⁴⁸ |
| `exp/09_tower.py` | towers multiply u by k — a loss |
| `exp/10_jacobian_p2.py` | #J(F_p) measured; u_J = 2 u_E |
| `exp/11_h1_matched_twin.py` | H1 refuted, 15 000 orders/arm, live control |

**Retractions made this round (recorded):** (i) #J(F_p) = (p+1)² — **wrong**;
(ii) "smoothness is flat in the choice parameter" — **wrong**, it is bimodal in
(D/p); (iii) two versions of the H1 control were degenerate — a control that
cannot discriminate is not a control; (iv) B₁ = exp(√(2 ln p ln ln p)) —
**wrong**, that is the total; (v) Lenstra 1987 is *Ann. of Math.* (2) **126**
(1987) 649–673, **not** Math. Comp. 48 (1987) 237–266 — that page range spans
three different papers and the citation was conflated. Correct DOI is
`10.2307/1971363` (verified by me against the Crossref API; the
`10.2307/1971384` first proposed does not resolve); (vi) Enge's "1/g!" is **not**
a smoothness rate for ECM-style bounds — see the warning in §9; (vii) I had not
drawn the **group order vs point order** distinction — see §6. The literature
habit says "smooth group order"; ECM actually keys on `ord_P(p)`, a divisor,
and smoothness of the group order does not imply smoothness of the divisor.
(Re-checked: my measurements use the point order throughout, so no number
moved.) (viii) **A CITATION I INVENTED.** "Couveignes & Lercier, *Fast
group-like point addition on Jacobians of hyperelliptic curves*, ANTS VII,
LNCS 4076, pp. 567–577" **does not exist** — no such chapter in ANTS VII, and
those pages are arithmetically impossible (they straddle two other papers).
Verified against the complete LNCS 4076 table of contents and against zbMATH's
full Couveignes list. The companion title I supplied was fabricated too. This is
the **16th fake citation in this program**; I introduced it. The real prior art
is Dryło–Pomykała (FI 169 (2019) 275–283 and Colloq. Math. 179 (2025) 123–146),
both verified — see §9. The standing tool that would have caught this in one
call: `api.crossref.org/works?filter=isbn:<ISBN>`.

---

## 8. Independent corroboration — the closest existing work

**Romain Cosset, "Factorization with genus 2 curves", arXiv:0905.2325; Math.
Comp. 79 (2010) 1191–1208** — a direct genus-2-Jacobian-vs-ECM comparison.
Verbatim, from the introduction:

> "At first sight the "hyperelliptic curve method" (HECM) seems slower that ECM
> because of two reasons: first the arithmetic of hyperelliptic curves is slower
> compared to the arithmetic of elliptic curves, and secondly its probability of
> success is smaller than that of ECM. Indeed this probability depends on the
> probability of the cardinality of the Jacobian of the curve modulo a prime
> factor p of n being smooth. But the probability of a number being smooth
> decreases with its size. By Weil's theorem, the cardinality of a Jacobian of a
> genus 2 curve on F_p is around p² whereas the cardinality of an elliptic curve
> over the same field is around p."

This is **exactly the u_J = 2·u_E argument of §2**, stated in the literature.
Cosset's escape is the same escape this round identified independently — use
*decomposable* genus-2 curves whose Jacobians are isogenous to E × E, so HECM
≡ "two simultaneous runs of ECM":

> "One run of HECM with this kind of curves is equivalent to two simultaneous
> runs of ECM, thus the probability of success of HECM with decomposable
> hyperelliptic curves is comparable to that of two ECM."

and his measured result:

> "For very large n the speed up of GMP-HECM compared to GMP-ECM is around 11%."

**So the prior art's realized gain from an entire genus-2 Jacobian is ~11%,
against my torus's 1.5× — both constants, neither an exponent.** The axis's
promise has been tested by someone else at g=2 and did not deliver.

## 9. Literature actually verified (URL + verbatim quote)

**Hasse–Weil / #J ~ p^g.** Enge, "Discrete logarithms in curves over finite
fields", Fq8, pp. 119–139 (HAL inria-00201090), eq (3), verbatim from the PDF
I read myself:

> "By Weil's theorem [70], the order of the Jacobian of a curve C of genus g
> defined over Fq satisfies (√q − 1)^{2g} ⩽ |J(C)| ⩽ (√q + 1)^{2g}."

and the scale, verbatim:

> "As by (3) the Jacobian group has a size of q^g + O(q^{g−1/2})"

— matching my measured #J/p² ∈ [0.91, 1.31].

> **⚠ DO NOT MISCITE ENGE'S "1/g!" AS A SMOOTHNESS RATE.** I nearly did. In
> context it is *not* an ECM-style smoothness probability. The passage sets the
> smoothness bound to **B = 1** — "the factor base is composed of divisors
> containing only one point" — so the "smooth" divisors are just multisets of
> g points, and 1/g! is the asymptotic probability that a random element of a
> group of size q^g is a multiset of g points. It is a **deliberately trivial
> bound** used to analyse a *relation-collection* algorithm, not a factoring
> success probability. It says nothing about ECM-style B-smoothness and must
> not be cited as if it did. (pdftotext mangles this passage: "the
> smoothness probability ... is, asymptot1 . So filling the matrix requires
> g!n = O(q) trials, ically for q → ∞, given by g!" — the radical glyphs and the
> 1/g! fraction are detached from their sentences. I read the surrounding text
> to reconstruct the argument.)

Also verified: Xiong–Zaharescu, arXiv:1007.4621, §1, verbatim from the LaTeX
source:

> "It is known that # J_C = P_C(1) (see [Corollary VIII.6.3]{lor}). From this we
> immediately derive that \[(q^{1/2}-1)^{2g} ≤ \# J_C ≤ (q^{1/2}+1)^{2g},\]"

and "the quantity log # J_C - g log q is essentially bounded by O(log log g)",
i.e. **#J(F_q) = q^g(1+o(1))**. Corroborated by Hase–Liu–Triantafillou,
arXiv:1709.02442, eq (1.1). *(Their pdftotext drops the radicals entirely and
shows "(p−1)^{2g} ≤ #J ≤ (p+1)^{2g}" — a live example of the flattening
hazard.)*

**ECM cost / the Hasse-interval heuristic.** Menezes–Oorschot–Vanstone,
*Handbook of Applied Cryptography* §3.2.4 p.90 (https://cacr.uwaterloo.ca/hac/about/chap3.pdf),
verbatim:

> "The order of such a group is roughly uniformly distributed in the interval
> [p+1−2√p, p+1+2√p]. If the order of the group chosen is smooth with respect
> to some pre-selected bound, the elliptic curve algorithm will, with high
> probability, find a non-trivial factor of n. The elliptic curve algorithm has
> an expected running time of L_p[1/2, √2]"

**The primary reference for §5's asymmetry, and the honest limit of this
round.** H. W. Lenstra Jr. and C. Pomerance, "A rigorous time bound for
factoring integers", *J. Amer. Math. Soc.* **5** (1992), no. 3, 483–516, DOI
`10.1090/s0894-0347-1992-1137100-0` (DOI and pagination verified by me directly
against the Crossref API). This is the rigorous L[1/2] result on the
class-group side that §5's number-field-vs-function-field asymmetry rests on.
**I have not read it** — the AMS PDF path 404s. It is a to-fetch, and §5's
framing should be treated as resting on it without my having verified the
text.

**Dickman asymptotic** (the form used in §4). Brent, arXiv:1004.3366, eqs
(3.1)–(3.2), verbatim:

> "ln ρ(α) = −α(ln α + ln ln α − 1) + o(α)  (3.1)
> ρ(α − 1)/ρ(α) = α(ln α + O(ln ln α))    (3.2)"

**RETRACTED — A CITATION I INVENTED. This is the 16th fake citation in this
program's history and I introduced it.**

I put "Couveignes & Lercier, *Fast group-like point addition on Jacobians of
hyperelliptic curves*, ANTS VII, LNCS 4076, pp. 567–577" into the literature
brief. **It does not exist.** Verified two independent ways:

*Crossref, complete ANTS VII table of contents* (`filter=isbn:9783540360759`,
42 records) ends:

```
525-542  Zimmermann, Dodson        "20 Years of ECM"
543-557  Diem                     "An Index Calculus Algorithm for Plane Curves..."
558-572  Huang, Raskind           "Signature Calculus and Discrete Logarithm Problems"
573-581  Miller, Venkatesan       "Spectral Analysis of Pollard Rho Collisions"
582-598  Mironov, Mityagin, Nissim
```

**No Couveignes chapter and no Lercier chapter anywhere in the volume**, and
**pp. 567–577 is arithmetically impossible** — it straddles the 558–572 /
573–581 boundary.

*zbMATH*, `au:Couveignes`, 41 records enumerated: no ANTS VII paper, no
"composite characteristic" paper, nothing matching. The real Couveignes–Lercier
Picard-group paper is "Linearizing torsion classes in the Picard group of
algebraic curves over finite fields" (arXiv:0706.0272) — a different title, a
different venue, and over F_q.

My companion title, "The group of the Jacobians of hyperelliptic curves over
Z/nZ", **is also not real** — no record in zbMATH, Crossref or arXiv.

I had this in a brief as a *hypothesis to check*, and the agent correctly
refused to quote it — but the failure mode was mine, and the honest reading is
that I recalled the authors and topic, then filled in the venue and pages.
**Tool discipline that would have caught it in one call, not forty:**
`api.crossref.org/works?filter=isbn:<ISBN>` returns a complete Springer LNCS
table of contents with page ranges in one request. That should be standing
toolset next to `q.sh`, and it is for any future round.

**The real prior art, which is better than the thing I made up.** Two
Dryło–Pomykała papers do exactly this. Both DOIs and titles verified by me
against Crossref:

1. **Dryło & Pomykała, "Jacobians of hyperelliptic curves over ℤₙ and
   factorization of n", Fundamenta Informaticae 169 (2019) 275–283, DOI
   `10.3233/FI-2019-1847`.** zbMATH review summary, verbatim (a reviewer's
   words, not the authors'):

   > "In this paper we describe the analogous reduction for computing the orders
   > of Jacobians over Z_n of hyperelliptic curves over Z_n using the Mumford
   > representation of divisor classes and Cantor's algorithm for addition.
   > These reductions are based on the group structure of the Jacobian."

2. **Dryło & Pomykała, "Hyperelliptic curves and integer factorization",
   Colloquium Mathematicum 179 (2025) 123–146, DOI `10.4064/cm9490-8-2025`**,
   verbatim abstract:

   > "If one assumes that there exists an oracle which for D in the Picard group
   > Pic^0_{Z_n}(C) returns a non-zero multiple of the order ord(D), then we show
   > that outputs of the oracle can be used to efficiently factorize n. To show
   > this we transfer to Z_n some methods of representation and addition of
   > divisor classes in the Picard group of a hyperelliptic curve with the
   > ramified or split model over a field."

**Their direction is the ORACLE direction — "given an oracle returning a
multiple of ord(D), we factor" — which is the opposite of what ECM does**
(ECM computes `[M]P` and gcds; it never asks anyone for the order). That is the
sharpest citable statement of this round's asymmetry: **in the Zₙ Jacobian
literature the group order is treated as an expensive black box**, exactly as
#J(F_p) is uncontrollable here when p is unknown. They are working in the
oracle regime; the axis asks for the ECM regime, and nobody has shown the
transition.

**Still NO QUOTE for:** (i) the unit-leading-coefficient hypothesis specifically,
(ii) any statement that the group order mod an unknown p divides #J(F_p),
(iii) any L[1/2] complexity claim from this line of work. The bodies are
paywalled. So §1's Jacobian row still carries my own proof sketch for the
sampler claim — but it now has **real, citable** prior art for the setting.

**Stable URL for Cosset:** https://eprint.iacr.org/2009/258.pdf (HTTP 200), in
addition to arXiv:0905.2325.

**Correction to the agent's own record, recorded for completeness:** it had
reported the Couveignes–Lercier citation as "unretrievable," which was wrong in
kind — unfetchable and nonexistent are different failures, and only the second
one licenses a retraction. It also reported "the HAL full-text route is
exhausted" for item 6, which was overstated (`fulltext_t:` is not a real
full-text index and is not evidence of absence), and HAL PDF availability is
*unreliable* rather than uniformly dead.

**Nobody has published a measurement of the distribution of orders of random
points in J(F_p) for genus g ≥ 2 compared against elliptic-curve point
orders.** Two supports for that gap. (i) Xiong–Zaharescu arXiv:1007.4621 is
about the distribution of #J and never mentions ECM. (ii) The relevant
rigorous theory is still being built, and only just, at **genus 1**:
Landesman & Levy, "The Cohen–Lenstra moments over function fields via the stable
homology of non-splitting Hurwitz spaces", arXiv:2410.22210, abstract verbatim:

> "We compute the average number of surjections from class groups of quadratic
> function fields over F_q(t) onto finite odd order groups H, once q is
> sufficiently large. These yield the first known moments of these class groups,
> as predicted by the Cohen-Lenstra heuristics, apart from the case H = Z/3Z."

— quadratic function fields over F_q(t) is **genus 1**, not a genus ≥ 2 Jacobian
order distribution, and it never mentions ECM. Pair with Cosset's Remark 2.6 (a
stated assumption plus a 4-torsion-only experiment) and the gap is precise. So
§2's 15 000-order measurement appears to be new — with the §6(iii) caveat about
how easily this particular comparison degenerates.

**Dead routes (do not retry):** cr.yp.to/ecm.html (404), GMP-ECM manual
(marix.it dead, gmplib 404s), ar5iv.org (times out; use arxiv.org/e-print/<id>),
kimi.umass.edu, math.mit.edu/~poonen/notes/curves.pdf (404). WebSearch
fabricates on this host. The on-disk `q6/lenstra87.pdf` is a working-draft scan
with catastrophic OCR — do not cite it.

---

## 10. NOT SETTLED — carry these into any future round

1. **Lenstra–Pomerance 1992 is unread.** *J. Amer. Math. Soc.* **5** (1992)
   483–516, DOI `10.1090/s0894-0347-1992-1137100-0` (I verified the DOI and
   pagination against Crossref; I did **not** read the paper — the AMS PDF
   404s). §3 and §5's number-field half rest on it. If anyone picks this axis
   up, read that introduction before trusting §3's framing.
2. **The Cantor/Mumford-over-Zₙ sampler condition still has no quote.** §1's
   lemma that composition needs only leading coefficients coprime to n is my
   own, with a proof sketch. Dryło–Pomykała establish the *setting* (Mumford +
   Cantor over Zₙ, and a factoring reduction) but their bodies are paywalled, so
   the unit-leading-coefficient hypothesis specifically remains unquoted. §1's
   Jacobian row may need rewriting if those bodies surface — though H1's
   conclusion is independent of it, since H1 never depended on the sampler.
   **And do not reintroduce the invented Couveignes–Lercier ANTS VII citation
   (§9); it is retracted and the pages do not exist.**
3. **The smoothness heuristic itself is untested here.** Every cost number in
   this round rests on "the group order is essentially a random integer near p".
   I measured that this rate is *constant across algebraic structures*; I did
   not test that it is correct. A falsification of the heuristic would change
   the baseline, not just the function field.