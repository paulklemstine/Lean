# Round 47 part 14 — the dimensional closure: the relation space is a curve for EVERY `d`

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


**2026-09-29. This subsumes `Round47_DegreeBarrier.md` and states the obstruction in a form
that needs no case analysis.**

---

## The count

Let `h = c_0 + c_1α + ⋯ + c_{d−1}α^{d−1}` be a relation.

**Without the square condition** (what the ordinary NFS asks for): the only requirement is
`h(m) = u^2`. That is `d+1` integer variables and **one** equation, so the relation space has

> **dimension `d`.**

**With `h(α) = g^2`** (what the Lee–Venkatesan framework requires, because that is what turns
a relation into a congruence of squares): write `g = g_0 + ⋯ + g_{d−1}α^{d−1}`. The
components `α^2, …, α^{d−1}` of `g^2` must vanish, and each is a **quadric** in the `g_i`.
That is `d−2` equations in `d` variables, leaving a 2-parameter family; then `h` is
**determined** by `g`, and `h(m) = u^2` is one more equation. So

> **dimension `2 − 1 = 1` — a curve, for every `d`.**

| `d` | no square condition | with `h(α) = g^2` |
|---|---|---|
| 3 | 3 | **1** |
| 4 | 4 | **1** |
| 5 | 5 | **1** |
| 6 | 6 | **1** |

## What follows

1. **The curve structure is not a coincidence of `d = 3`.** I spent round 47 treating the
   genus-1 quartic as a special case; it is the *only* case there is, and it persists at
   every degree.

2. **And the curve gets worse, exponentially.** `Round47_DegreeBarrier.md` establishes
   `g(Ŷ_d) = 1 + (d−3)·2^{d−2}`: genus 1 at `d=3`, **5 at `d=4`**, 17 at `d=5`, 49 at `d=6`.
   So the framework's relation space is **a curve of exponentially growing genus** at every
   degree. There is no degree at which it is a surface you can sieve.

3. **The constraint cannot be dropped.** `h(α) = g^2` is *precisely* what turns a relation
   into a congruence of squares — the output the whole framework exists to produce. So:

> **The constraint that makes the relation space analysable is the constraint that makes it
> thin. You cannot have one without the other.**

4. **This is why the ordinary NFS is not affected.** It never imposes `h(α) = g^2` on a
   relation. It asks for a *combination* of relations to have square norms, and handles that
   by **linear algebra over `GF(2)`** in a `d`-dimensional space — not by a
   codimension-`(d−2)` locus inside the relations themselves. Rigidity moved from the
   relations to the *combination step*, where it costs a factor of `2` and nothing else.

## The closing sentence

Round 47 spent a day discovering, in the one place where the number field sieve theory
requires it algebraically, the exact trade that number field sieve theory elsewhere
declines to make:

> **Characterise your relations ⇒ you have `d` dimensions, and no character.
> Characterise your characters ⇒ you have one dimension, and too few relations.**

Neither half of round 47's work — the genus-1 reduction with its explicit Jacobian and
explicit character, or the genus-5 collapse with its measured supply — escapes this. The
first is the `d=3` instance of a family that is always a curve; the second is the first time
that curve becomes too thin to sieve. **Both are the same fact.**
