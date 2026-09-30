# Round 47 part 34 — the crossover: 24 bits as written, and the lattice version is the whole game

**2026-09-29. The decisive number for the method, and it is arithmetic I can do without
new tools. Two DIFFERENT crossovers exist and they must not be confused.**

---

## (A) The COST crossover — computable now, and it is bad

The method's cost has two parts: **the trial** (`O(H²) = 4·10⁴` isqrt calls, ~20 ms, and
~2.2 expected trials at the measured 46% per-trial rate) and **choosing `f`**, which as
written is a brute-force scan of `N/cmax` probes for `m` with `m³ ≡ c (mod N)`, `|c| ≤ cmax`.

| bits `N` | probes `N/cmax` | GNFS `L[1/3,1.923]` | ratio |
|---|---|---|---|
| 14 | 1.6·10¹ | 1.2·10³ | 0.013 |
| 18 | 2.6·10² | 3.9·10³ | 0.067 |
| 22 | 4.2·10³ | 1.1·10⁴ | 0.38 |
| **24** | — | — | **≈ 1.0** |
| 26 | 6.7·10⁴ | 2.8·10⁴ | 2.4 |
| 30 | 1.1·10⁶ | 6.5·10⁴ | **16.5** |
| 50 | 1.1·10¹² | 2.1·10⁶ | 5.3·10⁵ |
| 100 | 1.3·10²⁷ | 9.7·10⁸ | 1.3·10¹⁸ |

> ### **The method AS WRITTEN is overtaken by GNFS at `bits(N) ≈ 24.1` — i.e. `N ≈ 10⁷`.**
> Beyond that it is worse, and catastrophically so: **10⁵ times worse at 50 bits, 10¹⁸ at
> 100 bits.**

This is why my scaling table looked bimodal and then fell off a cliff. The cliff is **not**
the relation supply — it is **the polynomial search**.

## (B) The SUPPLY crossover — **not computed, and not assumed**

The other question is whether a **non-empty relation curve** exists at a findable height as
`N` grows. Measured only at `ln N ≈ 7–25`, where `0–13` relations appear at `H ≤ 200`, and
**where roughly half of all `f` give a completely empty curve** (`Round47_EmptyCurve.md`).

**I have not measured this at `ln N = 50` or beyond, and I am not going to infer it.** It is a
separate crossover and it could be the binding one.

## The one question that decides it

> **How expensive is lattice-based polynomial selection, compared to `N/cmax`?**

- **If it is `poly(log N)`** — as the NFS's own structure suggests it should be — then the
  method's cost collapses to *the trial alone*, ~20 ms, and the whole cost picture inverts.
  It would then be limited **only** by the supply, i.e. by (B).
- **If it is not**, the 24-bit crossover stands and the method is a curiosity with a clean
  explanation.

**This is a single, well-posed, decidable question, and it is the only thing standing between
"a curiosity" and "a competitor".** It has not been answered here: the record's
`Round47_HMBarrier.md` already documents that reconstructing a lattice from memory failed
once, and the construction was never sourced.

## The honest summary of the method, with the numbers attached

| | |
|---|---|
| **works** | verified 68/68, 910/910, 16,411/16,411, 706/706 — every success a true factor |
| **cost of the trial** | ~20 ms; 2.2 expected trials |
| **cost of choosing `f`, as written** | `N/cmax` — **crossover with GNFS at 24 bits** |
| **cost of choosing `f`, by lattice** | **UNKNOWN — the decisive quantity** |
| **supply at large `N`** | **UNMEASURED — the second decisive quantity** |
| **descent / factorisation of `N`** | **none, anywhere** — that part of the claim is structural, not a measurement |

**Two quantities stand between this and a competitor, and both are single well-posed
questions.** That is a better position than round 47 was in an hour ago, when I had a method
with no numbers attached to its cost.
