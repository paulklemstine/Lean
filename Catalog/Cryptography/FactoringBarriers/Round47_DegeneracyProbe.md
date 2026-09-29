# Round 47 part 21 — a probe with a valid half and a mislabelled half

**2026-09-29. Recorded because of the second half, not the first. I nearly filed a
conclusion from a column whose name did not match what it computed.**

---

## 1. The valid result: degeneracy is NOT the mechanism

A8 found that over `F_q` the relation curve degenerates at only **18 good-prime loci** out
of 170 tested. That raised a sharp, cheap question on the integer side: **are the `(m,c)` with
no witness exactly the DEGENERATE ones?** If so, failure is diagnosable in advance and
"try another `f`" becomes "try a non-degenerate `f`".

**Twelve instances sampled across one modulus (`N = 1333`, `m = 14,16,19,20`, several `c`
each). `disc(A) = 0` on NONE of them, including the seven with no witness.**

> **The integer failures are not degeneracies.** The curves are smooth, the branch divisor
> is fine, and the rationality filter is doing something subtler than "the curve is
> malformed." So the diagnosis is not reducible to a computable arithmetic condition, and
> "pick a non-degenerate `f`" is **not** an improvement.

That is a genuine, clean negative and it sharpens A8's result rather than repeating it.

## 2. The mislabelled half — and why I am recording it

The second column is headed `witness?` and reads `False` on seven of twelve rows. **That
label is wrong.** The group-law loop in my script is a **no-op `pass`** — I stubbed it out.
So what the script computes is:

> **whether the FIRST rational point found by a height-≤50 search has `chi_P = +1`,**

not whether a `chi_P = −1` point exists in `E(Q)`. Those are different questions, and I
have measured the second one dozens of times today (73% at `H = 60`; the audit's 200
instances with no witness to depth 14). **The column does not measure the failure rate and
no rate should be read off it.**

The rows are also conspicuously structured — at `m = 14` two `c` fail and one succeeds; at
`m = 16` likewise; at `m = 19` and `m = 20` they interleave — which is exactly what "the
sign of one arbitrary point varies with `c`" looks like, and is *not* what "the group has no
`−1`" looks like. **Seeing that structure and saying so is the whole value of this entry.**

## 3. The rule this earns

> **A column's name is a claim. Check that the code computes what the name says.**
> `witness?` computed "the first point's sign". Nothing in the output would have flagged
> it — the numbers looked perfectly reasonable, and I was one sentence away from writing
> "degeneracy explains the failures" on the strength of a stubbed-out loop.

This is the **second** time today that a self-written verifier reported a clean result
while measuring something else: the first was the `L`-pricing function that returned the
exponent instead of the value. **Both times the bug was in a helper, and both times the
output looked entirely plausible.** That is the argument for reading the code, not the
table.
