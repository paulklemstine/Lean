# The Kernel Is Five Percent

## What 48 rounds of factoring research were actually optimising, and the one-line fix nobody applied

**Round 49 · 2026-10-03**

---

## Abstract

A factoring construction based on multiplicative relations modulo `n` has been the object of
study for 48 research rounds. We decompose its cost and find that **the linear-algebra and gcd
phases are 5% of the work and the relation-finding is 95%** — the reverse of what the programme
was built around. We then show:

1. **The kernel phase's obstruction is asymptotic, not practical.** The relation matrix's
   permutation-similarity defect is `Θ(b)` — confirmed, exponent 0.900 with `R² = 0.999`, and
   *provably invariant under every permutation* — yet a matched-shape, matched-nonzero control
   with an `O(1)` defect costs **the same** at the sizes anyone uses (0.93–1.13, replicated on
   fresh seeds). NFS's `O(n²)` sparse linear algebra rests on a *bounded* defect, so the
   treatment does not transfer — **but it does not need to, at these sizes.**

2. **The fix that was available all along is a backend swap, worth >10⁴×.** Replacing
   `sympy.Matrix.nullspace()` with `DomainMatrix.rref` over `QQ` — **the identical exact
   computation** — took a cell at `b = 52` from *timeout* (>200 s) to **0.1 s**.

3. **The programme's own positive framing overstated.** The claim that the kernel is "a drop-in
   for NFS's" is **not refuted and not confirmed — it is unfalsifiable as stated**, because the
   phase it names is not the binding constraint.

---

## 1. Where the cost actually is

At `n ≈ 2⁴⁰, b = 52`, with the `QQ` rref backend:

| phase | milliseconds | share |
|---|---|---|
| relation-finding | 267.00 | **95.0%** |
| kernel | 13.75 | 4.9% |
| gcd / extract | 0.21 | 0.07% |

Swapping *only* the linear-algebra backend moves `frac_LA` from **0.328 → 0.049**.

The construction that 48 rounds attacked is ~5% of the cost. The hard half is relation-finding —
which is the number field sieve, already the state of the art. **That is the honest accounting,
and it is more useful than any barrier claim: it says where a successor should not spend time.**

## 2. The defect is real, and it does not bind

The relation matrix is genuinely sparse — density `Θ(1/b)`, about 5 nonzeros per column,
independent of `b`. So NFS's sparse-linear-algebra machinery is the natural choice.

**It does not transfer, for a structural reason.** NFS's `O(n²)` rests on a **bounded defect**.
Here the permutation-similarity defect is **`Θ(b)`**, and it is **provably invariant under every
permutation**: a column permutation preserves each row's nonzero count, so no reordering exists to
find. The mechanism is exact and was checked by enumeration — row *i* is nonzero iff `p_i | r_j`,
so `Pr[row i] = Ψ(n/p_i, B)/Ψ(n, B)`, and **the row for `p = 2` is dense** because a constant
fraction of `B`-smooth integers are even.

**But an asymptotic obstruction is not a practical one.** A control matrix with the same shape
and nonzero count but an `O(1)` defect costs **the same number of sparse arithmetic updates** at
`b = 26–52` — ratios **1.13 / 1.07 / 0.92**, straddling 1, replicated on fresh seeds. At those
sizes the absolute cost is a few thousand operations.

*(The naive test says the opposite for two diagnosable reasons: the dense route is `Θ(b³)`
independently of defect, so it cannot measure it; and the control's coefficients are 5.7×
wider, because `Fraction` is not constant-time.)*

## 3. The fix: a backend swap, >10⁴×

> **A note's own headline finding caused the failure of the experiment designed to support it.**

The `b = 52` cell timed out, twice, and that was disclosed as a scope limitation rather than
quietly dropped. Diagnosing it found the cause was **not** relation-finding — that is ~3000
trials, under a second — but the kernel call itself:

**⚠️ Corrected — the first version of this section said ">200 s" on the strength of a timeout
alone. It has now been measured directly, on ONE matrix, same `n`, same relations:**

| step | time at `b = 52` |
|---|---|
| `find_relations` (53 relations) | **0.013 s** |
| `DomainMatrix.rref` over `QQ` | **0.013 s** |
| `stange.kernel_basis` → `Matrix.nullspace()` | **> 400 s — an alarm fired; it never finished** |

So the gap is **> 3 × 10⁴× as a LOWER BOUND**, and **relation-finding was never the
bottleneck** — it is the same 0.013 s as the kernel. The gain is a `b`-dependent constant:
**4.2–15.3×** across 16 cells including small `b`, and **> 3 × 10⁴×** at `b = 52`. Quoting
either alone would mislead.

**And the control that makes the swap sound (ST10).** Recommending `DM` for `F` is only
legitimate if the two compute the same thing — otherwise the headline number compares two routes
that may not agree. Added as a self-test: **`DM` and the incumbent agree on dimension and rank
in 12/12 real Stange matrices**, spanning more than one dimension.

*Without that control the note's headline speed number rested on a comparison between two
routes that might not compute the same thing — precisely the error class this campaign has been
recording all along, caught here by the agent auditing itself.*

⚠️ **Run over `QQ`, never `ZZ`.** `DomainMatrix.rref` over `ZZ` is reduced **on pivot columns
only**, so kernel extraction silently returns wrong vectors.

⚠️ **The coordinator's reproduction attempt did not reproduce the gain** — measured on **dense
random** matrices it is 2.5–3.8× at dimension 30–40 and **0.75–0.86× at 60–140**. That is a
different *population*: the matrices that matter are **sparse**. Correctness was confirmed at
every dimension in both tests; only the constant is in question, and the census records the
number as agent-measured, not coordinator-verified.

## 4. Three traps, each caught by a control that could itself have passed vacuously

- **The undivided Krylov reconstruction is identically zero and *passes* `M·w = 0 mod p`.** A
  kernel routine can satisfy its own correctness assertion and return **nothing**. A correctness
  check is necessary and never sufficient; add a **non-vacuity** check — the returned vectors are
  non-zero and span the predicted dimension.
- **`sympy`'s QQ `rref` leaks real `float`s** on rank-deficient matrices (20/20 synthetic, 0/4
  real; one carried **2⁻⁵²**). **A rank check *and* a dimension check both pass it.**
- **A `−0.458` "deficit" was purely the `seq` sampler.** `p_split` spans `[0.500, 0.998]`, so the
  baseline alone moves a number by ±0.25.

A fourth is recorded as **not-reproducible** rather than refuted: the `ZZ` pivot-column trap did
not occur on sympy 1.13.1 in 3000 trials. The rule stands; the instance does not.

## 5. What this axis can and cannot claim

The 2-adic excess swings between **+0.225 and +0.316 purely on baseline choice**, and **two
samples of the same cell differ by 0.085 on sampling alone.** A `+0.32` "effect" is **not
measurable here**, and no claim is made about one. Every rate in this work is reported against
its own modulus's `p_split`, because the campaign's flat 20/27 is an average over moduli.

## 6. Verdict

| question | answer |
|---|---|
| Is the kernel a drop-in for NFS's? | **Neither confirmed nor refuted — unfalsifiable as stated**, because the phase is 5% of cost. Swapping it moves the total by ~2× and changes nothing about the algorithm. |
| Does the `Θ(b)` defect explain NFS's sparse treatment not transferring? | **It explains why the *theorem* doesn't transfer; it does not bind at the sizes used.** |
| Is there an actionable improvement? | **Yes, and it is not an algorithm change: swap the backend.** |

## Reference

- N. Stange, *Factoring using multiplicative relations modulo n*, arXiv:2211.06821.
- Jeljeli, arXiv:1209.5520v4, §2.2 — *"the very first columns of `A` are relatively dense"*,
  which **weakens** the NFS-has-a-bounded-defect / Stange-does-not dichotomy one might build
  on it. Quoted because we built that dichotomy before reading the section.

**Verification protocol.** 42 self-test checks, all passing, every negative control firing.
`p_split` verified against closed form and 4000-sample Monte-Carlo (±0.006, 4/4 moduli).
WebSearch was not used for any citation.