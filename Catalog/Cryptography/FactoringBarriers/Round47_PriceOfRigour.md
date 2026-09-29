# Round 47 part 15 — the synthesis: Conjecture 7.1 is the price of rigour, and rigour is 224 dex

> ## ⚠️ RETRACTED IN PART — read `Round47_Retractions4.md` first
>
> **The central thesis of this file is REFUTED.** "Conjecture 7.1 is the price of rigour,
> paid twice" fails on **both** payments:
>
> 1. **It is not paid in the L constant.** Lee–Venkatesan's *rigorous* constant
>    `(64/9)^{1/3} = 1.92299` is **identical** to the heuristic one. Their **Theorem 2.1
>    (p. 5) is unconditional**: the Randomised NFS runs in expected time
>    `L_n(1/3, ∛(64/9)+o(1))` and produces `x, y` with `x² = y² (mod n)`. **The `L[1/3]`
>    running time is already proven.** What needs Conjecture 7.1 is `x ≢ ±y` — the
>    *factoring*, not the running time.
> 2. **The 224.4 dex figure is arithmetically wrong** and is a *different axis*. The gap
>    `N^{1/5}` vs `L[1/3,1.92299]` is 11.58 / 35.53 / 61.36 / **88.12** / 143.19 / 199.49
>    dex at 512 / 1024 / 1536 / **2048** / 3072 / 4096 bits; 224.4 is reached at ≈4544 bits.
>    The 224 figure compares `N^{1/5}` to **GNFS**, saying nothing about Conjecture 7.1.
>
> **Fact A is also refuted in its corollary:** the ordinary NFS **does** pay a comparable
> cost — Bühler–Lenstra–Pomerance p. 15 list four obstructions between a linear dependency
> and a congruence of squares (class group 6.3, units 6.4, `Z[α] ≠ O` 6.5, irreducibles ≠
> primes 6.2) and write *"in general we cannot make any of these assumptions."*
>
> **What survives:** the dimensional count itself (requiring `h(α) = g²` costs `d−2`
> dimensions) as a description of **Lee–Venkatesan's formulation**. Its corollary about the
> ordinary NFS does not survive.


**2026-09-29. This connects the dimensional closure (`Round47_DimensionalClosure.md`) to the
record's own §1.3, and it is the closest thing round 47 produced to a conclusion about the
project as a whole.**

---

## The two facts

**Fact A — the price of rigour is paid in relations.**
`Round47_DimensionalClosure.md`: requiring `h(α) = g^2` costs `d−2` dimensions, leaving a
**curve** for every `d`. The ordinary NFS never pays this, because it gets a non-trivial
congruence of squares from **linear algebra over `GF(2)` on a combination of relations**
rather than from a codimension-`(d−2)` locus inside the relations. So:

> **The standard GNFS has no Conjecture 7.1. Lee–Venkatesan's framework has one precisely
> because it is a rigorous one.**

**Fact B — the price of rigour is paid again in exponent.** The record's §1.3, unchanged:
the deterministic `N^{1/5}` is **224.4 dex behind** the GNFS at 2048 bits, and a true `1/6`
**widens** the gap rather than closing it.

## Together

> **Conjecture 7.1 is the cost of upgrading a heuristic algorithm to a proof. That cost is
> paid twice: once in the relation space (dimension `d` → `1`, a curve of growing genus), and
> once in the running time (a factor `≈ 2·10⁵⁰` at 2048 bits).**

And the punchline the record already half-says in §1.3:

> **The open problem the whole campaign has organised itself around — proving `L_n[1/3]`
> rigorously — buys, on success, a bound that is 224 orders of magnitude worse than the
> heuristic bound we already have and use every day.**

## Why this reframes what a "method" would be

The campaign's stated goal is "a new classical factoring method". On this analysis:

| what one could deliver | what it is worth |
|---|---|
| a **faster heuristic** than GNFS | a genuine advance; believed impossible without a quantum computer, but not disproved |
| a **rigorous `L[1/3]`** (Conj 7.1) | a real theorem — **and 224 dex worse than the heuristic** |
| a **faster deterministic polynomial** (`1/5` → `1/6`) | a real theorem — **and it widens the same gap** |

So **every remaining "method" in this file is either believed impossible or dominated by
224 orders of magnitude.** That is not a gap in the record; it is what the record says, once
you read §1.3 and §7 together — and round 47 supplies the *reason*, which §7 did not have:
**rigour is not free, and in index calculus it is paid in dimensions of the relation space.**

## The honest statement of the frontier

1. **Beating the GNFS heuristic** — the only route to a genuinely better algorithm. Not
   disproved. (Agent on the linear-algebra constant; that is the one term that might move.)
2. **A rigorous `L[1/3]`** — a real open theorem, and the only thing Conj 7.1 buys. Closed
   by the Chebotarev-strength decorrelation nobody has done since 2018.
3. **Auxiliary-information factoring** (Coppersmith and after) — *methods exist* for a
   different problem, in the brief's scope, never systematically covered by this record.

Item 3 is the one place where the phrase "a method" is literally true, and it is the one axis
this project has not mined at all. Everything above it is either believed impossible or
dominated by a factor of `2·10⁵⁰`.
