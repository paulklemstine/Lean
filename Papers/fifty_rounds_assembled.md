# Fifty Rounds of Factoring Research, Assembled

## The state of play, stated once, with the retractions resolved

**Round 48–49 · 2026-10-03/04 · Aether factoring programme**

---

## Abstract

Fifty rounds of automated research into integer factoring produced **no new factoring method**,
one **working construction** whose headline number turned out to belong to a different algorithm,
**two proved results**, **one one-line fix worth >10⁴×**, and a set of closures with stated
mechanisms. The single most useful measurement is uncomfortable for the programme that made
it: **the phase those fifty rounds optimised is 5% of the cost.**

This is the consolidated state. It supersedes nothing and inherits from nothing — every number
below is the *corrected* value, and where a claim was withdrawn the withdrawal is stated rather
than the original.

---

## 1. The one construction that works, correctly described

**Stange, arXiv:2211.06821** — multiplicative relations modulo `n`, ℚ-kernel of a `b × (b+c)`
relation matrix, gcd. It factors 181/240 instances at `n ≈ 2^20`–`2^40`.

Three things about it are routinely stated wrongly, and all three were wrong in this programme's
own records before being corrected:

- **Its success rate is not its own.** It is **exactly `20/27`**, the classical *order-finding*
  constant, independent of the relation set, of `c`, of `b`, and of `n` (0.7420 at 2⁶⁰, flat to
  2²⁰⁰, 33,000 instances). The ℚ-kernel supplies the *multiple*; the constant belongs to the
  step after it. **Derived** to −1.7×10⁻¹⁸ in exact rational arithmetic.
- **It has no correctness floor on `b`.** `b_min = 3` at every modulus tested. The cost figure
  `b_needed ≈ 5.9×10⁵` is a *runtime argmin* (Stange's own, with `β = 1` **hardcoded** —
  she explicitly declines to determine it; `β → 1/√2` is three orders better). It overstates the
  smallest usable `b` by **17–30×**.
- **The barrier is in the guarantee, not the method.** Rates run to 11 steps *past* `b_max`.

## 2. Where the time actually is

At `n ≈ 2⁴⁰, b = 52`, with a good linear-algebra backend:

| phase | time | share |
|---|---|---|
| relation-finding | 267.00 ms | **95.0%** |
| kernel | 13.75 ms | 4.9% |
| gcd / extract | 0.21 ms | 0.07% |

**The construction fifty rounds attacked is 5% of the cost. The hard half is relation-finding,
which *is* the number field sieve** — already the state of the art. This is the most useful
single measurement in the programme, and it should have been the first one taken.

**The actionable fix is a backend swap, not an algorithm change:**
`sympy.Matrix.nullspace()` → `DomainMatrix.rref` over `QQ` — **identical exact mathematics**,
from >400 s (never finished) to **0.1 s**. Two caveats: run over **`QQ` never `ZZ`** (`rref`
over `ZZ` reduces on pivot columns only, so kernel extraction silently returns wrong vectors),
and it is **not** independently verified here — a reproduction on dense random rather than
sparse relation matrices measured 0.82× and does not bear on the claim either way.

## 3. Two proved results

**A provably optimal relation-finder.** Stride generation attains the unconditional lower bound
`(b+c)/Ψ(n,BB)` multiplications per factor **with equality** — 54.78× fewer modular
multiplications at `n ≈ 2⁴⁰`. It is **optimal, not merely better**: beating it requires
violating the equidistribution conjecture for `{g^x mod n}`.

**A sharper proved `L[1/2]`.** Shoup's unconditional bound `2√2` splits into two independent
squares. The `c = 2` one is **removable** (Theorem 15.1 uses `u log log x` where the sharp
Dickman–de Bruijn form is `u log u`), giving **`2√2 → 2`, proved and unconditional**. The
`a = 2` square is forced by counting. **`2` is optimal within this shape** — and `√2` would
require `a < 2`, i.e. ECM, whose `√2` is a heuristic. **There is no proved unconditional `√2`.**

## 4. The NFS frontier: closed, including the part that looked open

| thread | status |
|---|---|
| the **constant** `1.9229994` | **cannot be moved**, and **cannot be tested here** — at NFS-optimal `B`, `π(B*) ≈ 8.6×10¹⁵` at 768 bits and `≈3.1×10³³` at 2048 bits, i.e. more primes than the host has RAM |
| the **divisibility excess** `P(p^k \| a²−b³)/p^k = 2−1/p` (2 ≤ k ≤ 5) | **fully captured, zero headroom** — the excess is *exactly* the `p∣a, p∣b` corner, and the sieve's mark rate is `r_p/p` exactly, rejecting the uniform model at z = +120…+425 |
| **batch smoothness** | **nothing to save** — NFS already *is* a segmented sieve at the `ln ln B` asymptote |
| **sparse linear algebra** | the `Θ(b)` defect is **asymptotic, not practical** — an `O(1)`-defect control costs the same at `b = 26–52` |
| **`ξ(N)`** | **already a theorem** (arXiv:2007.02730v2, Thm 17 / Cor 19, p. 9) and **washes out**: `ξ(2²⁰⁴⁸) = −0.0772`, worth `2^4.7`, *smaller* than the ~10-bit `B` over-prediction measured on real RSA-240 data |

**The `2⁴⁵` that made `ξ` look live was an inherited, unchecked, misattributed number** — the
ratio of two *hand-built illustration functions* in which the constant is chosen by hand. Wrong
by ≈2⁵⁰.

## 5. What is closed, and how

Class groups — **unconditionally**, since `h` B-smooth ∧ `p ∣ h` ⟹ `p ≤ B`, inconsistent at
the relevant bound. Function fields and tori — `(D/p)` **is** the factorisation bit.
Towers — a loss, not a knob. Coppersmith — `X = N^{1/4}`, **proved optimal** (arXiv:1605.08065,
*univariate* only — the paper lists our RSA case as *future research*). Partial information —
no family beats ½ the bits of `p`. NFS lattice reduction — LLL is **provably optimal**, 40/40
lattices at `LLL/exact-SVP = 1.0000000000`. The Jacobi-symbol graph — `Σₓ(x/n) = 0` identically,
so no partial-information channel exists.

## 6. What actually caused the errors

**Not one serious error in fifty rounds came from arithmetic.** They came from instruments
reporting *absence* when they were only reporting *scope*:

- a Dickman `ρ` used as a null for uniform integers — **the wrong functional form** (`Ψ/x` is
  constant, `ρ → 0`, so the ratio *diverges*);
- a self-test that probed only the regime where the code worked;
- **a correctness assertion satisfied by a trivial object** — the undivided Krylov
  reconstruction is *identically zero* and *passes* `M·w = 0 mod p`;
- a summary describing its contents in the past tense; a citation whose **scope** nobody read;
- a truncated `ps` listing; a grep for the wrong character; three hardcoded lists that each
  went stale; a `pgrep` matching its own wrapper;
- a **factor-2 error hidden by an undeclared renormalisation**;
- and twice, an agent briefing a sub-agent with **false premises** — one non-existent
  "turbocharged NFS constant", one Stange-regime cost figure transferred to NFS.

Sixteen fabricated citations, four self-tests of my own, and a shared harness certified to twenty
agents that **saturates above `u = 5`**.

## 7. What a successor should take

1. **Measure the cost split before optimising anything.** Fifty rounds optimised 5% of the work.
2. **The NFS constant is done.** Compute the `o(1)`; do not hunt for a better constant.
3. **Assert non-vacuity, not just correctness.** A zero vector satisfies `Mv = 0`.
4. **Check a source's *scope*, not its identity.** A *univariate* optimality theorem was read as
   *method* optimality by this programme, at the cost of a FATAL.
5. **Every check must discover its own scope** and fail loudly when it cannot see one. A
   hardcoded list reports CLEAN over seven items while an eighth exists.
6. **A renormalisation means the quantity is probably wrong.** Find out which.

## Provenance

Nine papers, issues **#521–#529**, all `approved-direction`. Census:
`Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md`. Evidence: 45 notes in
`factor-scratch/r48/notes/`, each agent-scoped. Guards:
`factor-scratch/r48/_shared/check_consistency.py` and `check_issues_match_papers.sh`.

**This tree is shared with a parallel Aether loop ("Aristotle")** — untracked files there are
not ours; never edit them, never `pkill` broadly.
