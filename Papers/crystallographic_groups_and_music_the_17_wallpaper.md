# Computational Evidence — Symmetry groups of periodic rhythms

All computations below were run in Lean 4 / Mathlib (`#eval`), so the numbers are
reproducible from the same code that the theorems are stated in.

## 1. Symmetry types of a period-`p` rhythm = number of positive divisors `τ(p)`

The theorem `symGroup_eq_divisor_lattice` together with `symGroup_divRhythm`
shows that the translation-symmetry groups achievable by a period-`p` rhythm are
*exactly* the divisor lattices `zmultiples d`, `d ∣ p`.  Hence the count of
symmetry types is `τ(p)`, the number of positive divisors.

```
p :  1  2  3  4  5  6  7  8  9 10 11 12 13
τ :  1  2  2  3  2  4  2  4  3  4  2  6  2
```

This is OEIS **A000005** (the divisor-counting function `d(n) = τ(n)`), first
terms `1, 2, 2, 3, 2, 4, 2, 4, 3, 4, 2, 6, ...`.

**Consequence for the conjecture.**  The mission's headline slogan — "there are
exactly 17 types of rhythm" — is *not* literally true for 1-D (monophonic)
rhythms: the number of translation-symmetry types of a period-`p` rhythm is
`τ(p)`, which is unbounded (e.g. `τ(2^k) = k+1`).  The genuine "17" is a fact
about the *2-dimensional* wallpaper groups (subgroups of the full isometry group
of the plane up to affine conjugacy), a much deeper classification that our 2-D
file (`DrumPattern2D.lean`) only begins (the translation lattice) rather than
completes.  We therefore prove the honest, fully-formal statements and record the
gap in `FUTURE_DIRECTIONS.md`.

## 2. A concrete rhythm and its symmetry group

Take `divRhythm 2` (an onset on every even beat), viewed over one period of 6:

```
n            : 0 1 2 3 4 5
onset f n    : ● · ● · ● ·        (true false true false true false)
```

Shifts `t ∈ {0,…,5}` that fix the pattern (checked over `n ∈ 0..11`):

```
{0, 2, 4}
```

These are exactly the multiples of `2` modulo `6`, i.e. `zmultiples 2` reduced
mod `6` — matching `symGroup_divRhythm 2 = zmultiples 2` and the fundamental
period `2 ∣ 6`.

## 3. Sanity checks behind the 2-D theorems

* **Canon** `g (a,b) = F (a-b)`: the anti-diagonal `(s,s)` always fixes `g`
  because `a-b` is unchanged by `(a,b) ↦ (a+s, b+s)`; formalised as
  `canon_diagonal_mem`.  A general shift `(s,t)` fixes `g` iff `s-t` is a period
  of `F` (`mem_canon_iff`), so the symmetry lattice is the *sheared* lattice
  `{(s,t) : (s-t) ∈ periods F}` — an oblique/centred cell, exactly the lattice
  shape associated with glide/`cm` wallpaper symmetry.
* **Point reflection** `v ↦ -v` squares to the identity (`pointRefl_involutive`),
  the 2-fold rotation of the `p2` "call-and-response" case.

## 4. Counterexample hunt

The universal claims we prove (subgroup axioms, `mem_canon_iff`, realisability)
were tested on random small rhythms before formalisation and no counterexample
was found; each is now a theorem with `#print axioms` reporting only
`propext, Classical.choice, Quot.sound`.  The *false* reading of the conjecture
("exactly 17 for all rhythms") is refuted by the table in §1 (`τ(12)=6`,
`τ(2^k)=k+1`), which is why the formal statements are the divisor-lattice ones.
