# A control that refused to let me ship a vacuous measurement

**Orchestrator note, 2026-10-03.** Recorded because the failure mode generalizes to every
round, and because I would very likely have made it again.

## What I tried

I wanted to test H1 — the preregistered claim that the class-group walk on `D = kN`
degenerates to a group of order exactly `p`, giving a `sqrt(p) = N^(1/4)` birthday cost
rather than `L[1/2]`.

Instead of building a full SQUOF implementation, I used a shortcut: the classical result that
if `p | N` then the continued fraction of `sqrt(N)` has `i < j < 2p` with `m_i ≡ m_j (mod p)`.
So I measured the first modular repeat and planned to check it lands near `sqrt(p)`.

The first three self-tests passed. The measurement was about to run.

## What the negative control found

I added a control that was supposed to be routine — "a prime N has no small factor, so no
collision should appear early." It fired immediately:

```
  [FAIL] collision found at k=6 for prime modulus (should be rare)
```

**`k = 6`.** For `N = 1000003`, prime, the detector reported a modular collision after six
terms. And it should have: `m_i ≡ m_j (mod p)` is the **pigeonhole principle**. With `p`
residues and `p+1` terms, a collision is *guaranteed* by step `p` — and empirically appears
at roughly `sqrt(p)` for **any** modulus, divisible or not.

## Why the planned measurement was worthless

My detector never tested whether `p` divides `N`. It tested only "have two `m` values become
congruent," which is a statement about the pigeonhole principle, not about factoring.

So the measurement I was about to report — *"first repeat at `k = 0.282·sqrt(p)`, close to the
birthday constant `sqrt(pi/8) = 0.354`, confirming the `sqrt(p)` ceiling and killing the
E-thread"* — **would have been produced entirely by combinatorics.** It would have agreed with
H1 for reasons having nothing to do with H1, and the agreement would have been reported as a
measurement of a factoring cost.

This is the most dangerous class of bug in an empirical program, because the number is
plausible, the theory it "confirms" is real, and the two agree to within a factor of 1.26.
Nothing in the output looks wrong.

## The rule this forces

**A measurement must have a detector whose failure mode is DISCRIMINATIVE.** The test is not
"does the harness run" but "does the harness return the null answer on an input where the null
answer is correct." Here the correct answer for a prime modulus is *no early collision*, and
the harness could not produce it.

Concretely, when measuring anything about factoring, the harness must be shown to distinguish:
- an `N` **with** a known factor `p`, from
- an `N` **without** it,

**on the statistic being reported.** If both return the same value, the statistic does not
carry information about factoring and no amount of agreeing-with-theory rescues it.

## Status of H1 — what I am and am not claiming

**Not claimed:** any measured confirmation of the `sqrt(p)` ceiling. I have not measured it.

**Claimed:** that establishing it requires either a correct SQUOF/continued-fraction
implementation whose extraction step is driven by divisibility, or the algebraic argument
about the order of the form group. Both remain open in this note. H1 stands or falls on the
agent's algebraic derivation (`notes/00_HYPOTHESIS.md`) plus the classical literature on
Shanks' square-forms factorisation, whose worst case for balanced semiprimes is the textbook
`O(N^(1/4))`.

**Note the asymmetry this creates for the E-thread retraction.** The *statistical* refutation —
E-7 is a coin flip, E-6b's baseline is a Dickman self-reference, no code was committed — is
**established and verified** (`notes/M_forensics.md`). The *structural* refutation is
**algebraic and pending**. The retraction of the program's frontier claim stands on the
statistical side alone, which is enough. I am not going to bolt an unmeasured "and also
structurally dead" onto it.

## The three self-tests that passed were not wasted

`SELFTEST 1` (convergent reconstruction, exact to 0.0e+00 on four inputs) and `SELFTEST 3`
(detector fires on a known factor) both passed and are correct. They verified the harness
*works*. They said nothing about whether the harness *discriminates*, which is the only
question that mattered, and which is exactly what the fourth test asked.

**A harness that works is not a harness that measures.** The rule this program already has —
"a control that only runs at the parameter you derived it at is not a control" — needs its
sibling: *a self-test that only shows your code running is not a self-test.*