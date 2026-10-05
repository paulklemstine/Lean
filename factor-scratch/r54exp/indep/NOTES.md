# Round 54 (in progress) — is round 97g's "genuine bivariate model" in the class the decidable test analyses?

Orchestrator note, 2026-10-05. Work in `factor-scratch/r54exp/indep/`.
**No commit, no issue, no paper yet.** Two other agents are running in parallel
(`../weights/`, `../umw_t/`); this note is independent of both.

## 0. VERDICT SO FAR

> **The corpus's multivariate thread does not say whether it is attacking
> "bivariate over ℤ" or "bivariate mod `p`". Those are different problems, and
> the mod-`p` one is DEGENERATE: for fixed `x`, all `p` values of `y` satisfy
> it.** Which means the decidable test round 48 built — and round 53 recommended
> carrying into this work — **speaks to a formulation that could never have
> worked for anyone**, while the construction 97g actually built is over ℤ and
> is not degenerate.

Round 48 built the decidable algebraic-independence instrument
(`factor-scratch/r49exp/pkinfo/capacity.py`, selftest passes) and recorded its
verdict on *2-sample HNP instances*. Round 53's catalog mine found that rounds
97g and 99 **never invoked it**, and diagnosed their own failure as a *search*
problem (bad shift basis) rather than a *structural* one — and recommended
carrying the instrument forward. This note asks whether the test could have
applied at all.

**It could not**, and checking that **corrects my own round-53 paper**, which
recommended the transfer without confirming the target instantiated the
instrument. See §4.

## 1. THE CLAIM, STATED BEFORE MEASURING

Round 97g's model (`Round97g_BivariateProbe.md:31-33`):

```
p = a + x,   q = b + y,   (a + x)(b + y) = N,    x, y small
```

Chinburg et al.'s Problem 1.3 is a **linear** congruence in two variables **mod
the prime**:

```
x + t·y + a ≡ 0  (mod p),     |x| ≤ X,   |y| ≤ Y
```

Reduce 97g's equation mod `p`. Since `(a+x) ≡ 0` is already a factor,

```
(a + x)(b + y) ≡ 0  (mod p)
```

and **`p` is prime**, so this is a **disjunction**:

```
a + x ≡ 0   OR   b + y ≡ 0        (mod p)
```

The first branch is satisfied by `x = −a` **for every `y`**. So for fixed `x`:

> **the 97g equation admits ALL `p` values of `y`; the 2111.14180 form admits
> exactly ONE.**

The two unknowns are not coupled mod `p` at all. The coupling 97g relies on
lives **over ℤ** — in the fact that the product equals `N` *exactly*, which is a
condition on integer sizes, not a congruence condition.

## 2. MEASUREMENT (exhaustive, no sampling)

`model_check.py`, seeded `20261005`, **two consecutive runs byte-identical**.

**P1 — the degeneracy is exact.** Counting `{(x,y) ∈ F_p² : (a+x)(b+y) = 0}` by
exhaustive enumeration (so no sampling error can hide behind a clean number):

| `p` | counted | predicted `2p − 1` | |
|---|---|---|---|
| 773 | 1545 | 1545 | OK |
| 3821 | 7641 | 7641 | OK |
| 14461 | 28921 | 28921 | OK |

Two lines through the origin, meeting only at `(0,0)` — `2p − 1` exactly.

**P2/P3 — and the controls that make it mean something.** For a **fixed** `x`,
how many `y ∈ F_p` satisfy the congruence?

| `p` | **97g equation (positive control)** | **2111.14180 linear form (negative control)** |
|---|---|---|
| 947 | **947 / 947** | **1 / 947** |
| 3121 | **3121 / 3121** | **1 / 3121** |
| 16103 | **16103 / 16103** | **1 / 16103** |

Positive control **3/3**, negative control **3/3**. **This is the whole point:**
if the two columns looked alike, the distinction would not be measured. They do
not — one is total, the other is unique.

## 3. ⚠️ TWO INSTRUMENT FAILURES, both caught, both mine

Recorded because the controls are the only reason they were caught.

**(i) Wrong regime, twice.** My first two versions drew the "known part" `a`
from `[1, 10⁶]` while `p ≈ 2¹²`, so `x = p − a` was hugely negative and **every
instance was vacuous — 0/400 everywhere**. The second version fixed the range
but drew `a ∈ [1, p−kmax)`, which is backwards: for `x = p − a` to be *small*,
`a` must be **near** `p`. The tell was the same both times — **the positive
control returned 0/3 and I read it as "my claim is false" before checking the
regime.** A test whose positive control fails is a broken instrument, not a
refutation. This is the exact failure mode of `a-harness-that-works-is-not-a-
harness-that-measures`, and it is the reason both controls are mandatory here.

**(ii) The first "confirmation" measured nothing.** My initial framing counted
integer solutions in a box and found `2, 0, 0` — which reads like a result and
is not one, because at `n = 24, 28` the true point `(x₀, y₀)` was **outside the
box entirely** (printed explicitly: `True` only at `n=20`). A zero from an empty
box is not a zero from the phenomenon.

## 4. WHAT THIS DOES AND DOES NOT SETTLE

### ⚠️ FIRST, A CORRECTION TO MY OWN §1 HEADING

I wrote above that "round 97g's bivariate model is NOT an instance of the
problem class 2111.14180 analyses." **That is true, but the reason is not the
one that reads as an indictment of 97g, and I should be exact.**

Checking 97g's actual construction (`Round97g_BivariateProbe.md:61-62`): its shift
polynomials are built from

```
g(x,y) = (a + x)(b + y) − N
```

— an **exact integer equation over ℤ, not a congruence mod `p`.** Over ℤ the two
unknowns **are** genuinely coupled, and the degeneracy I measured does **not**
apply to 97g's lattice. **97g's construction is not degenerate, and its
diagnosis is not obviously over-stated.**

What my measurement actually establishes is narrower and about the **mod-`p`
reading** of the model:

> **If you formulate 97g's model as a two-variable problem mod `p` — the
> natural thing to do, and the formulation 2111.14180 addresses — it
> degenerates.** For fixed `x`, all `p` values of `y` satisfy it, versus exactly
> `1` for the linear form. **So that formulation carries no two-variable
> information to recover.**

### Settles

**Round 53's recommendation #5 was mis-scoped, and this is the concrete reason.**
Carrying the 2111.14180 decidable test into "the multivariate work" would have
produced a clean, confident, **irrelevant** verdict: the instrument answers a
question about mod-`p` two-variable instances, and the one construction actually
built (97g) is over ℤ. The corpus's round-48 instrument was not neglected
through carelessness — **it was pointed at a different problem.**

This is worth stating plainly because it *corrects my own round-53 paper*, which
recommended the transfer without checking that the target instantiated the
instrument.

### Sharpens

There is a real and **unrecorded** distinction here: **"bivariate over ℤ" and
"bivariate mod `p`" are different problems, and the corpus's multivariate thread
does not say which one it is attacking.** Round 53 called 97g/99's diagnosis
over-stated; this note says something more precise — **the diagnosis may be
correct for the ℤ-construction, while the mod-`p` reading that the decidable
test speaks to is degenerate and could never have worked for anyone.** Both can
hold at once.

### Does NOT settle

- Whether the ℤ-coupling is exploitable. The `OVER Z` counts here (`2, 0, 0` in a
  `[1,256]²` box) are **too small and too regime-specific to mean anything**,
  and are recorded only to show the coupling is not vacuous over ℤ either.
- Whether 97g's H-G basis is genuinely suboptimal. **I have not shown that, and
  round 53's claim that it is over-diagnosed is not established by this note** —
  it is *unresolved*, and this note moves it from "probably over-diagnosed" to
  "the two threads may be about different problems, so the comparison was never
  apples-to-apples."
- **Not a closure of the multivariate question.** It closes one *diagnostic
  instrument's applicability*, nothing about Coppersmith multivariate methods.

## 5. REPRODUCE

```
cd factor-scratch/r54exp/indep
python3 model_check.py     # ~1 min; exit 0; two runs byte-identical
```

No dependencies beyond the standard library (`random` is seeded at the top of
the file). Exhaustive over `F_p²` — the `p` values used are 773/3821/14461, small
enough that the double loop is exhaustive, so **there is no sampling anywhere in
P1–P3**.

## 6. STATUS

Provisional. Not committed, no issue, no paper. Two parallel agents are working
on the two untouched integers named by round 53 (`Σw > 3/2` and the rank-2 UMW
gap bound `t`). **If either returns a result, this note is not yet a round-53-
successor paper** — it becomes one only if it is combined with a second result,
or it stands as a short methodological note. Decide when the agents land.