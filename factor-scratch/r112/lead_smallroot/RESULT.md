# Lead: is the α ≥ 0.15 GIFP wall a construction failure or problem-infeasibility?

**Status: INCONCLUSIVE — my probe was wrong twice. Not a result. Do not cite.**

## The question

r111c found the GIFP attack fails at every feasible γ, m for α ≥ 0.15, and that
`t=ceil` does not rescue it. Two very different explanations:

- **(A)** the construction is sound but the *lattice* fails to find the short
  vector, or
- **(B)** the true solution is not actually a small root at α ≥ 0.15 — the
  *instance* is outside the regime the bound describes.

(B) is decidable without any lattice, so it was worth a direct probe.

## Attempt 1 — evaluate each shift at the true root (WRONG)

`root_validity.sage`: for each shift polynomial `g`, compute `|g(x0,y0,z0,w0)|`
and compare its bit-length to the modulus `M^m·N1^t`.

Result at α=0.05, γ=0.50, m=4: modulus 639 bits, worst shift 1780 bits, margin
**−1142**. Reported verdict: "INFEASIBLE (root not small)" — at *every* α,
including α=0.05 where the attack demonstrably succeeds.

**This is self-refuting**: a probe that declares the working case infeasible is
measuring the wrong invariant. Discarded.

## Attempt 2 — scaled coefficient norm (ALSO WRONG)

`scaled_feasibility.sage`: `create_lattice` sets
`L[row,col] = g.monomial_coefficient(m) * monomial(X,Y,Z,W)`, so I computed the
Euclidean norm of each *scaled* shift row and asked whether the shortest is
under the modulus.

Result: ratio ≈ 197% at α=0.05, ≈ 173% at α=0.15 — again "root not short"
everywhere, including where the attack works. Still self-refuting.

**Why it's still wrong**: the target vector is not any single shift row. LLL
succeeds when a short *integer combination* of the rows is short — the solution
lies in the row space, not in one row. Per-row norms are the wrong object; the
correct quantity is the LLL-reduced basis norm, i.e. what the attack itself
computes.

## What this does and does not establish

- **Does**: a naive "is the root small?" feasibility probe is useless here and
  produces confident, self-contradictory negatives. Any future claim of the form
  "the instance is infeasible" must be validated against a parameter point where
  the attack is *known* to succeed, or it is worthless.
- **Does not**: say anything about the α ≥ 0.15 wall. The wall stands as an
  empirical observation from r111c; its *explanation* remains open and is being
  pursued by the `gifp_wall` subagent with the full pipeline (including varying
  β and m), which is the right instrument.
- **Does not**: refute or support r111c.

## Lesson (added to the campaign's discipline)

This is a third instance, after `threshold_test.py` (13/40 → 12/40) and the
"PARI ellcard on composite" hazard, of a harness producing confident wrong
numbers. The general rule, now explicit:

> **A negative measurement must be validated at a point where the phenomenon is
> known to be present.** If the probe says "absent" everywhere including a
> positive control, the probe is broken — and reporting its output as a finding
> is the error, not the absence.

The scripts are kept (`root_validity.sage`, `scaled_feasibility.sage`) as a
worked example of this failure mode, not as evidence.