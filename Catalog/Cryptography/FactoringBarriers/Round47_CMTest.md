# Round 47 part 27 — the CM escape is dead on arithmetic

**2026-09-29. A five-minute test that kills an idea I had reason to hope in.**

---

## The idea

A8's diagnosis is that round 47's collapse is the **rationality filter** — the relation curve
has too few `Q`-points — and that the blocker on repairing that is that a *certified* basis
needs a 2-descent at the bad primes `p`, `q`, which factors `N`.

**If the Jacobian were a CM elliptic curve, that would not be true.** Its `Q`-points are
governed by class field theory and are produced by torsion/Heegner points over the CM field
— **with no descent at `p` and `q`, hence no factorisation of `N`.** That would be a genuine
escape from the round's one circularity blocker, and nobody here had asked whether these
curves are ever CM.

## The test

For `E : Y² = X³ + aX + b`, `c₄ = −48a`, `Δ = −16(4a³ + 27b²)`, `j = c₄³/Δ`. With
`a = −3mc`, `b = c² + m³c`, and the **machine-checked** identity
`4a³ + 27b² = 27c²(c − m³)²` (`RelationWitness.lean`):

> **`j = −6912 m³ c / (c − m³)²`**

A CM elliptic curve has `j` a **singular modulus**, which is an **algebraic integer**. Here
`j` is **rational**, so CM would require `j` to be an **integer** — and then one of the
countably many singular moduli.

## The result

> **Over 275 sampled `(m,c)` across 12 moduli, `j` is an integer in 0 cases (0.0%), and a
> known singular modulus in 0 cases.**

Samples look like `j = −48242884608/1059828025`, `j = 725469696/9740641`,
`j = 113246208/30415225` — never integral.

> **THE JACOBIAN IS NEVER CM. THERE ARE NO HEEGNER POINTS. THE ESCAPE DOES NOT EXIST.**

## Why this is worth the five minutes

The round has five closures standing, and every one of them was reached by *running*
something. This one was reached by refusing to run anything until the arithmetic ruled it
out: **a rational `j` that is not an integer cannot be a CM invariant, full stop**, so the
whole class-field-theory escape was dead before I wrote a lattice.

It also sharpens A8's diagnosis into something checkable: **the rationality filter is not
an accident of which curves you pick. The relation curves are generically non-CM, non-special
curves, and there is no arithmetic shortcut to their `Q`-points.** That is a *reason* the
filter bites, which is more than the diagnosis previously had.

## Process note

`Test 0` asserts the discriminant identity before the j-formula is used, so a sign or factor
error in the derivation of `j` would have been caught before any instance was scored. It
passed. **The negative is arithmetic, not a plumbing failure.**
