# Fifty-Two Rounds, Assembled

## The state of classical integer factoring research as this programme left it

**Rounds 48–52 · 2026-10-03/04 · Aether factoring programme · supersedes #530**

---

## Abstract

Fifty-two rounds of automated research into classical integer factoring produced **no algorithm
that beats the number field sieve**, and — this is the part worth the time — **a mechanism for
why not**. One construction factors; its success probability was derived exactly, then improved
1.2×; and the programme discovered that the two properties a better method would need are
**provably incompatible**.

> **The central result.** Sieveability is a property of the **search**; the `20/27` success rate
> is a property of the **base**. They live in different phases. **A sieveable construction
> destroys exactly the material the `20/27` barrier is made of** — measured, CRT independence
> exact, ratio 0.93–1.10 with |z| ≤ 1.50. No construction gets both, and the NFS sits at that
> frontier for a *mechanism*, not by accident.

Also delivered: two **proved** results, one **one-line fix worth >10⁴×**, one exact
**valuation law**, and a body of method that cost more than any of it.

---

## 1. The one construction that works

**Stange, arXiv:2211.06821** — multiplicative relations `g^x ≡ ∏ p_i^{f_i} (mod n)`, ℚ-kernel of
a `b × (b+c)` relation matrix, gcd. It factors 181/240 instances at `n ≈ 2^20`–`2^40`.

Four things about it were routinely stated wrongly, **each of them wrong in this programme's own
records before correction**:

**Its success rate is not its own.** It is **exactly `20/27 = 0.740740…`**, the classical
*order-finding* constant — independent of the relation set, of `c`, of `b`, of `n` (0.7420 at
2⁶⁰, flat to 2²⁰⁰, 33,000 instances). The ℚ-kernel supplies the *multiple*; the constant belongs
to the step after it. **Derived** to −1.7×10⁻¹⁸ in exact rational arithmetic — after two wrong
derivations, the second hidden by an undeclared renormalisation that cancelled a factor-2.

**It has no correctness floor on `b`.** `b_min = 3` at every modulus tested. The figure
`b_needed ≈ 5.9×10⁵` is a *runtime argmin* — Stange's own, with `β = 1` **hardcoded**; she
explicitly declines to determine it (p. 5), and `β → 1/√2` is three orders better. `b_needed`
overstates the smallest usable `b` by **17–30×**.

**The barrier is in the guarantee, not the method.** Rates run to 11 steps *past* `b_max`.

**And it is structurally worse than NFS, for a reason now proved.** See §3.

## 2. The one lever that worked

Nobody asked, in fifty rounds, whether the base `g` had to be **uniform**. It does not.

Success is `v₂(ord_p g) ≠ v₂(ord_q g)`. Keep only `g` with `Jacobi(g/n) = −1` — computable
**without factoring**, and **60–7000× cheaper** than one modular exponentiation:

| base | success | expected attempts |
|---|---|---|
| uniform `g` | **`20/27 = 0.740740…`** | 1.35 |
| `Jacobi(g/n) = −1` | **`8/9 = 0.888889…`** | **1.125** |

Ratio **exactly 1.2×**. Closed form `E[FAIL] = 2(1/12 − 1/28) = 1/9`. Confirmed by **two
independent agents**: 60,000 trials at z = +79.79, exhaustive enumeration 210/210, an
independent reimplementation with no sympy (0/7197 violations of the crux lemma), and
**end-to-end 0.773 → 0.877 on 300 fresh moduli, McNemar p ≈ 0.001**.

**Mechanism:** `(g/p) = −1 ⟺ v₂(ord_p g) = s_p`, so conditioning the *product* to −1 forces
exactly one side maximal — **without knowing which factor is which**. All the gain is on the
diagonal `s_p = s_q` (uniform 50/94 vs Jacobi **94/94**); off-diagonal it is slightly *worse*.

**The search is closed, tightly.** *"No `g` beats `8/9`" is FALSE* — an oracle knowing `p, q`
reaches 1.0. The true claim is over `g` computable from `n` without factoring, and it holds
because separating the two Legendre symbols *is* factoring. The bound is **tight**: the
unimplementable oracle reaches 0.8963, so **the entire remaining lever is 0.0074** and is
unclosable without factoring.

## 3. Why the NFS is at the frontier — the programme's deepest result

Round 51 found that NFS sieving cannot be transplanted onto Stange's relation condition, and
phrased it as *aperiodic*.

**Round 52 corrected that, and the correction is the point:**

> Stange's hit set **is** periodic — with period `ord_n(g)`, measured at `ord_n(g)/n = 1.000`,
> i.e. **798× / 1813× / 5334× the sieve limit** at 2¹⁶ / 2¹⁸ / 2²⁰. A period larger than the
> search space is unusable. **The operative property is "period SMALL AND COMPUTABLE", not
> "periodic."**

The principle, measured across six constructions: **a relation condition admits a sieve iff the
sieved quantity is a polynomial in the sieve index.** GNFS, SNFS, Dixon-interval and ECM
stage-2 qualify; Stange and Dixon-direct do not.

**Dixon is the clean proof of the mechanism:** the same method is periodic when you sieve the
*interval* (`ℓ ∣ y`) and aperiodic when you sieve `x² mod n` — 6/6 primes. **Only the
expression changed.**

### The phase separation

Two independent agents closed the door from both sides:

**Search side.** A sieve **marks** residue classes and **generates** survivors, so the rejection
term `q` is **1 by construction** — proved by identity, sieve and brute force returning
**identical sets** (135=135, 379=379 on 6/6 cells). And conditioning the *search* can never
help: `GAIN = (s_C/s₀)·q/(1+q·c_cond/c_gen)`, so **a condition that rejects candidates can
never beat the fraction it discards** — any balanced character is a guaranteed ≥2× loss *before*
correlation is measured. (The base-conditioning of §2 escapes this because it pays **once per
attempt** and rejects nothing.)

**Base side.** A polynomial condition carries **no 2-adic coupling**. CRT makes independence
exact: ratio **0.93–1.10, |z| ≤ 1.50** across five sizes, each with ≥170 expected hits.

> **Sieveability is a property of the search; `20/27` is a property of the base. They live in
> different phases. No construction gets both — and the sieveability requirement is what rules
> out the escape the programme spent two rounds pursuing** (`b_needed 5.9×10⁵ → 8.4` via NFS
> relation-finding). That escape never existed, because there is no sieveable box to fill.

## 4. Where the time actually is — conditionally

At `n ≈ 2⁴⁰, b = 52` with a good backend: relation-finding **267.00 ms (95.0%)**, kernel
**13.75 ms (4.9%)**, gcd 0.07%.

**⚠️ That number is conditional and must carry its `(n, b)`.** Over a 24-cell grid
(`b ∈ {5…52}`, `n ∈ {2²⁵–2⁴⁰}`) the kernel share spans **0.0000–0.7772**. It is true at
large `n` and **false on 7 of 24 cells** at `n ≈ 2³⁰`, `b ≈ 26–52`, where the kernel is
**31–78%**. The programme's priority order was **right about the destination and wrong about
the road**.

**And the instrument is good to ±20% per cell**, measured: running the grid twice with **fixed
seeds** — identical matrices — moved the kernel share by **+22%**. That is why the 2³⁸ sign
disagreement (0.981× vs 1.213×) is reported as noise rather than a result.

**One actionable fix, and it is not an algorithm change:** swap
`sympy.Matrix.nullspace()` → `DomainMatrix.rref` over `QQ` — **identical exact mathematics**,
from >400 s (never finished) to **0.1 s**. Run it over **`QQ`, never `ZZ`** (`rref` over `ZZ`
reduces on pivot columns only and silently returns wrong kernel vectors).

## 5. Two proved results

**A provably optimal relation-finder.** Stride generation attains the unconditional lower bound
`(b+c)/Ψ(n,BB)` multiplications per factor **with equality** — 54.78× fewer modular
multiplications at `n ≈ 2⁴⁰`. Optimal, not merely better: beating it requires violating the
equidistribution conjecture for `{g^x mod n}`.

**A sharper proved `L[1/2]`.** Shoup's unconditional `2√2` splits into two squares. The `c = 2`
one is **removable** — Theorem 15.1 uses `u log log x` where the sharp Dickman–de Bruijn form
is `u log u` — giving **`2√2 → 2`, proved and unconditional**. The `a = 2` square is forced by
counting. **`2` is optimal within this shape**, and `√2` would require `a < 2`, i.e. ECM, whose
`√2` is a heuristic. **There is no proved unconditional `√2`.**

## 6. An exact distributional fact — and that it has no cash value

`P(p^k ∣ a² − b³)/p^k = 2 − 1/p` for odd `p`, **2 ≤ k ≤ 5**, departing at `k = 6` by the
zero-zero subspace. Verified by exhaustive enumeration.

**It is fully captured.** The excess is *entirely* the `p∣a, p∣b` corner — on `p ∤ b` the
rate is **exactly uniform** — and the sieve's mark rate is `r_p/p` **exactly**, rejecting the
uniform model at z = +120…+425. **Zero headroom.** Round 48's only positive experimental
finding turned out to have no exploitable value; establishing that is worth more than the
finding.

## 7. The NFS frontier, closed

| thread | status |
|---|---|
| constant `1.9229994` | **cannot be moved**, and **cannot be tested here** — `π(B*) ≈ 8.6×10¹⁵` at 768 bits, `≈3.1×10³³` at 2048 bits: more primes than the host has RAM |
| `ξ(N)` | **already a theorem** (arXiv:2007.02730v2 Thm 17 / Cor 19, p. 9) and **washes out** — `ξ(2²⁰⁴⁸) = −0.0772`, worth `2^4·⁷`, *smaller* than a `B` over-prediction already measured on real RSA-240 data. The `2⁴⁵` that made it look live was an inherited illustration-function constant, wrong by ≈2⁵⁰ |
| batch smoothness | nothing to save — NFS already *is* a segmented sieve at the `ln ln B` asymptote |
| lattice reduction | LLL **provably optimal**, 40/40 at `LLL/exact-SVP = 1.0000000000` |

## 8. Closed elsewhere

Class groups — **unconditionally** (`h` B-smooth ∧ `p ∣ h` ⟹ `p ≤ B`, inconsistent at the
relevant bound). Function fields and tori — `(D/p)` **is** the factorisation bit. Towers — a
loss. Coppersmith — `X = N^{1/4}`, **proved optimal** (arXiv:1605.08065, *univariate* only;
that paper lists our RSA case as *future research*). Jacobi-symbol graph — `Σₓ(x/n) = 0`
identically. `p−1`/`p+1`/Williams — legal `q = 1`, but **0/216** per-attempt success.

## 9. What actually caused the errors

**Not one serious error in fifty-two rounds came from arithmetic.** They came from instruments
reporting *absence* when they were only reporting *scope*:

- **a correctness assertion satisfied by a trivial object** — the undivided Krylov
  reconstruction is *identically zero* and *passes* `M·v = 0`;
- a self-test that probed only the regime where the code worked;
- a Dickman `ρ` used as a null for uniform integers — **the wrong functional form** (`Ψ/x` is
  constant, `ρ → 0`, so the ratio *diverges*);
- a citation whose **scope** nobody read (a *univariate* theorem read as *method* optimality);
- a summary in the past tense; a stale index; three hardcoded lists that each drifted; a `pgrep`
  matching its own wrapper; a factor-2 error hidden by an undeclared renormalisation;
- **twice, an agent briefing a sub-agent with false premises** — a non-existent "turbocharged NFS
  constant", and a Stange-regime cost figure transferred to NFS;
- and, twice, **my own** numbers: "95% of the cost" written in two papers and retracted in
  both, and "aperiodic" which was wrong — the set *is* periodic, with a useless period.

Sixteen fabricated citations. A shared harness certified to twenty agents that **saturates
above `u = 5`**.

**The most useful methodological moment** was an agent running its grid twice on fixed seeds,
finding a **+22% swing on identical input**, and publishing that its own cells were good to
**±20%**. It retroactively justified refusing to read a sign disagreement as a result.

## 10. What a successor should take

1. **Measure the cost split before optimising anything**, and carry `(n, b)`. Two rounds were
   spent on a phase that is 4.9% at large `n` and 78% at 2³⁰.
2. **NFS relation-finding is done.** The constant is proved optimal, the regime uninstantiable
   on commodity hardware, and the `o(1)` washes out. Compute the `o(1)`; do not hunt a constant.
3. **The frontier is a phase separation.** Sieveability and 2-adic coupling live in different
   phases; a method wanting both must find a structure that is both polynomial in the sieve index
   *and* 2-adically coupled. **That is the open construction problem**, and it is the only one.
4. **Assert non-vacuity, not just correctness.** A zero vector satisfies `M·v = 0`.
5. **Check a source's scope, not its identity.** That error cost a FATAL here.
6. **Calibrate your instrument before quoting it.** Fixed seeds, twice. One agent got 0.00% swing;
   another 22%. Both learned it only by checking.
7. **Every guard must discover its own scope** and fail loudly when it cannot see one.

## Provenance

Thirteen papers, issues **#521–#532**, all `approved-direction`. Census:
`Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md`. Evidence: 45+ agent-scoped notes in
`factor-scratch/`. Guards: `check_consistency.py`, `check_issues_match_papers.sh`.

**This tree is shared with a parallel Aether loop ("Aristotle")** — untracked files there are not
ours; never edit them, never `pkill` broadly.
