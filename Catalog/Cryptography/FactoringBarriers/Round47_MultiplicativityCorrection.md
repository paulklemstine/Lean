# Round 47 part 29 — CORRECTION to my multiplicativity result, and an untested lead

**2026-09-29. I found an over-claim in my own filed result. The correction is a matter of
logic and stands on its own; the experiment it suggests is UNTESTED and is recorded as
untested.**

---

## 1. What I filed, and what is wrong with it

`Round47_Multiplicativity.md` says:

> *"If every relation you can reach has `chi_P = +1`, then every **product** of them does
> too, and no amount of additional relation-finding within the same `f` can ever produce a
> `−1`."*

**The claim is true of *multiplication*, and I applied it to *the group law*.** Those are two
different operations, and the audit (D2) already separated them:

- `chi(l₁l₂) = chi(l₁)·chi(l₂)` holds — 69/69. That is **multiplication of relations**.
- `chi` is **not** a homomorphism on `E(Q)` — 39/1234 violations, 3 of 15 instances not
  homomorphisms. The Jacobian transports the **curve** law, not multiplication.

> **CORRECTED: two relations that are each `chi_P = +1` can ADD, on the curve, to a relation
> with `chi_P = −1`.** The `+1` locus is closed under *multiplication*, not under the *group
> law*. **My "no combination can escape a `+1` locus" was too strong and is struck.**

The surviving part is narrower and still useful: **finding more relations, and multiplying
them, cannot escape.** What I overreached on was *combining*.

## 2. Why this matters more than it looks

**The group law is the one part of the machinery that is descent-free.** I measured that
`PARI.ellinit` and `ellmul` are instantaneous even on a 3847-bit discriminant; it is
`ellrank` — the 2-descent — that needs the discriminant factored, and therefore `N`
(`Round47_Circularity.md`).

So if the group law can turn a `+1` base point into a `−1` relation, then:

> **the 27% of `(m,c)` where the 73% height-search found no witness would be reachable
> without any descent and without any factorisation** — because the group law reaches heights
> that a brute-force `(u,v)` search never will.

That is the most promising idea left in the round, and it came from auditing my own
over-claim rather than from a new idea.

## 3. ⚠️ STATUS: UNTESTED

I built the scan (`~/factor47/main/gltest.py`) and it did not complete.

- **Instance 1** (`N=1333`, `m=14`, `c=−78`, `P=0`): the base point has `chi_P = +1`, and
  `chi_P(nP) = 0` for **every** `n = 1…14`. That is **not** the predicted `−1`; it is the
  **third branch** — `C(t)y ≡ 0 (mod p)` or `(mod q)`, the branch the record's binary `±1`
  framing hides (`Round47_DegreeBarrier.md`, `Round47_Audit.md` D2). **A `0` on all fourteen
  is suspicious enough that I am not treating it as evidence either way** — it may be a bug
  in the quartic→Weierstrass inverse for general points, or a real feature. **Unresolved.**
- **Instance 2 crashed**: `PariError: incorrect type in checkell (t_VEC)`, so the Weierstrass
  model built for that `(m,P,Q)` is not a valid curve. The generalisation to `P ≠ 0` produces
  a model with a non-zero `x²` term and my shift is wrong somewhere. **Given how many times
  today a model built from memory has been wrong, I am not going to reason about the fix from
  memory** — it needs a machine-checked derivation or a source.

**So: the correction in §1 stands on logic and is filed. The experiment is not.**

## 4. What the next attempt needs

1. **Verify the quartic ↔ Weierstrass maps for GENERAL points**, not just the parametrised
   ones. I verified a round trip on 22/22 *parametrised* points; the group law produces
   arbitrary points, and the map may be wrong there. **The `0`-on-all-fourteen result is
   exactly what a broken inverse would produce.**
2. **Fix the `P ≠ 0` model.** Build it from a derivation that is machine-checked, the way
   `RelationAlgebra.lean` does the `P = 0` case, instead of from a shift formula recalled from
   memory.
3. **Then** re-run. Only then does the escape question have an answer.

## 5. The rule this earns — the fourth time today

> **An over-claim survives as long as nobody attacks it.** The multiplicativity result was
> correct as stated about multiplication, wrong as I applied it, and the error was invisible
> until I went looking for a way around it. **The way around it is often more valuable than
> the result** — here it is the only idea left in the round that could avoid the descent.
