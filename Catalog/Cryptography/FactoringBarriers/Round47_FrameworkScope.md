# Round 47 part 13 — WHERE the genus-1 structure actually lives

**2026-09-29. A distinction I should have made on day one and did not, and which changes
what the round's closure is a closure *of*.**

---

## The distinction

Round 47's whole structure rests on `l(α) = g² over ℤ` — **each individual linear form is
required to be a square in `Z[α]`.** That is Lee–Venkatesan's framework, not the number field
sieve. The record confirms it: `P_S` is a set of *products of* such relations, its *atoms*
are the forms with `l(α) = g²`, and the worked witness has `l(alpha) = g^2` with
`N(g) = Res_X(g, X^3−2) = −22528`.

**In the standard GNFS there is no such per-factor condition.** A linear form `l = am+b` is
collected simply because `Norm(l(α))` is `B`-smooth. The *square* condition enters only on
the **product** — that is what the linear algebra over `GF(2)` on the parity vectors of the
norms computes, and it is a condition on a *combination* of relations, not on each one.

## What follows, and it cuts both ways

**1. It explains why nobody else found this.** The genus-1 structure is a property of the
*square-relation* framework. The literature on beating the GNFS constant is about sieving
smooth values of linear forms and about linear algebra — neither of which ever imposes
`l(α) = g²`. So the elliptic geometry of relations is a feature of a framework that exists
**almost exclusively to make the rigorous analysis work**, and the rigorous analysis is not
where the constant is won.

**2. It narrows the closure.** The genus-5 collapse at `d = 4` and the supply measurement
(`22/38` vs `1/38`) are statements about **square relations**, not about the GNFS sieve. A
reader must not take `Round47_DegreeBarrier.md` as a claim about standard NFS. It is not.

**3. It explains the shape of the failure.** Square relations are *rigid*: the cone
`g₁² + 2g₀g₂ − Pg₂² = 0` cuts the space of forms down to a thin locus, and at `d ≥ 4` to a
higher-genus curve. Unsieved relations are *not* rigid: the space of `B`-smooth norms is
thick, which is exactly why sieving works and square relations do not sieve. **Round 47
discovered, in the one place where it is mathematically forced, the very rigidity that
number field sieve theory avoids everywhere else.**

That is the round's most transferable result, and it is not a method. It is the reason
there is not one here: **the constraint that makes the obstruction characterisable — each
relation a square — is the constraint that makes relations unseeable.**

## Correction to my own framing

`Round47_MordellWeil.md` and `Round47_DegreeBarrier.md` describe "the relations of the
cubic NFS". That phrasing is too strong. The correct statement, everywhere:

> **the relations of Lee–Venkatesan's square-relation framework, for the cubic, are the
> rational points of an explicit genus-1 curve; at `d = 4` that curve has genus 5 and the
> supply collapses.**

The standard GNFS has no such structure, because it never asks a single relation to be a
square.
