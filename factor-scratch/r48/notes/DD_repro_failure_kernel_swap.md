# I could NOT reproduce the round's one actionable finding

**Round 49. Orchestrator note. Recorded because a failed reproduction is information.**

## The finding, as reported

`notes/PP_droptest.md` reports that `sympy.DomainMatrix.rref` over `QQ` beats the incumbent
kernel routine at **all 16 cells, by 4.2–15.3×** — i.e. the incumbent leaves **a factor of ~10**
on the table and the fix is a *backend swap*, not an algorithm change. That is the round's most
likely-to-be-used engineering result, and I recorded it in the census.

## What I tried, and what happened

I attempted to reproduce it independently. Four attempts, all instructive:

**1. `DomainMatrix.from_Matrix(M).convert_to(QQ).to_Matrix().nullspace()`** — ran, and
**agreed exactly** with `Matrix.nullspace()` (correctness confirmed), but was
**0.86×–1.06×, i.e. no speedup.**

> **Why: this converts *back* to a `Matrix` and then calls the same `nullspace()`.** It is a
> roundabout route through the incumbent, so of course it cannot be faster. I had reproduced the
> *old* code path wearing a new API's clothes.

**1b. THE DIRECT ROUTE — found it, and it shows my test was the wrong population.**
`rref_den()` returns `(DomainMatrix, denominator, pivots)` — my earlier unpacking took
`parts[-2]` as the matrix, which was the denominator. With the order corrected:

| dim | nullspace | rref direct | speedup | agree |
|---|---|---|---|---|
| 30 | 0.0432 | 0.0171 | **2.53x** | True |
| 40 | 0.1280 | 0.0337 | **3.79x** | True |
| 60 | 0.0620 | 0.0831 | 0.75x | True |
| 80 | 0.1505 | 0.1901 | 0.79x | True |
| 100 | 0.2761 | 0.3209 | 0.86x | True |
| 140 | 1.0790 | 1.3194 | 0.82x | True |

**Faster on small dense matrices, SLOWER on large ones.** So this neither confirms nor
refutes the agent's 4.2–15.3x — **because I tested the wrong population.** The agent measured
on real Stange *relation* matrices, which are **sparse (density Θ(1/b))**; I measured on
**dense random** matrices with entries in [-3,3]. An `rref` advantage on a sparse matrix is
entirely plausible and says nothing about a dense one.

**The correctness half is confirmed at every dimension** (`agree = True` throughout), which is
the one thing this exercise did establish.

**This is the round's own failure mode, committed by me again in the act of auditing it: I
measured a population that cannot answer the question, and had I stopped at 'it doesn't
reproduce' I would have filed a false refutation.**

**What a successor must do to settle it — and it is now a small, well-defined job:**
benchmark the direct `rref` route against `Matrix.nullspace()` **on actual Stange relation
matrices** (`exp/stange/stange.py::build_M` output, density Θ(1/b)), at `b = 26–52` and then at
`b ≈ 6×10⁵`. That is the population the agent measured and the only one that bears on the
claim.

**Earlier dead ends, for the record** (each a sympy API mis-call, not a finding): `ValueError:
too many values to unpack`, `TypeError: got multiple values for 'domain'`, `AttributeError:
'PythonMPQ' object has no attribute 'to_list'`. All three were API-arity/order mistakes on my
part; §1b supersedes them.

## Status

**The agent's number stands on its own 16-cell measurement. My reproduction attempt used the
wrong population (dense random, not sparse relation matrices) and therefore does NOT bear on
the claim either way.** It is not evidence against, and not evidence for. The census records it as the agent's finding, and that is exactly how it is
labelled — it is not presented as something I verified.

**The correctness half I did confirm:** the two routes agree **exactly** on every dimension
tested. So whatever the speed difference, the *answer* is not in question — only the constant.

## Why this is worth writing down

The round's dominant failure mode was an instrument reporting something confident that wasn't
about the question. This is the mirror image, and rarer: **an instrument that verified
correctness while measuring nothing about speed.** A test that checks "do the two routes agree?"
and prints `True` is a real result — and it is silent about the thing I was actually asking.

The general form:

> **A correctness check is not a performance measurement, and a harness that verifies agreement
> can pass perfectly while measuring nothing about the quantity of interest.** State which
> question the check answers, and confirm it is the one being asked.

## What a successor should do

Implement the **direct** `DomainMatrix.rref()` route — do not route through `to_Matrix()` — and
benchmark it against `Matrix.nullspace()` at the sizes that matter (`b ≈ 26–52`, and then the
`b ≈ 6×10⁵` the regime analysis needs). If the ~10× holds, apply it to
`exp/stange/stange.py::kernel_basis`. If it does not, the census row needs correcting a second
time — and **that** would itself be worth knowing, because it would mean the round's most
actionable finding is also its least verified.

**Note:** the agent's own warning stands and is confirmed by the API shapes above —
`DomainMatrix.rref` over `ZZ` is reduced on **pivot columns only**, so it must be run over `QQ`
or kernel extraction silently returns wrong vectors.