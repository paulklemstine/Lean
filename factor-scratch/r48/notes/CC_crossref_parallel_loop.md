# A cross-reference, deliberately NOT filed as corroboration

**Round 49. Orchestrator note.**

## What I noticed

The parallel **Aether** loop ("Aristotle") — which shares this working tree and which I have
left untouched all round (see `lean-repo-is-shared-with-aether-loop`) — has been working an
**adjacent** problem: how much information a partial leak is actually worth. Its recent titles
include *"The Hint Value Has No Size Law"*, *"Ramified Primes Are Information-Theoretically
Negligible: Sharp `O(log N / N)` Bounds"*, and *"The Dihedral Dial of `x⁵ + 20x + 32` Carries
Exactly Half a Bit of Hint"*.

That is the same territory as this campaign's precise residue — recorded in `OO_bneed.md` as:

> *"is `X = N^{1/4}` optimal for partial-information factoring, and does the known-multiplier case
> have its own optimal bound?"*

**This campaign's answer to the first half is: `X = N^{1/4}` is measured to the bit (31 unknown
bits works, 32 fails), and arXiv:1605.08065 proves Coppersmith's univariate bound is optimal.**
The parallel loop's answer is a different question — mutual information between a prime's residue
class and its split type, bounded by `O(log N / N)`.

## Why this is NOT filed as corroboration

The two results are **adjacent, not identical**:

| | this campaign | parallel loop |
|---|---|---|
| object | the Coppersmith threshold `X = N^{1/4}` on **known bits of `p`** | mutual information between a prime's **residue class** and its split type |
| claim | a lattice-based bound is optimal **for that method** | a channel leaks `O(log N / N)` |

They have **compatible signs** — both say a partial leak buys less than one might hope — and
that is worth *knowing*. It is **not** mutual verification.

Claiming it as corroboration would be precisely the failure this round spent its day undoing: a
neighbouring result upgraded into support for a claim it does not test. I have already retracted
one such upgrade today (arXiv:1605.08065's *univariate* optimality read as *method* optimality),
and an adversary caught me making a second (building a dichotomy on Jeljeli that its own §2.2
undercuts).

**Two adjacent results with the same sign are a coincidence until someone connects them
deliberately.** If a future round wants to treat them as related, the job is to state *which*
channel and *which* threshold, and to show the connection — not to cite both and let the reader
assume it.

## The one thing worth recording

The parallel loop's `O(log N / N)` bound is **sharp** — an explicit configuration attains at
least `(r/N)·log₂N`. That is a good methodological pattern worth copying regardless of subject
matter: **an upper bound with a matching construction is a different kind of result from an
upper bound alone**, and it is the kind that stops a bound from being mistaken for an estimate.

Nothing in this note changes any census row, and nothing here should be cited by a future round
as support for `X = N^{1/4}`.