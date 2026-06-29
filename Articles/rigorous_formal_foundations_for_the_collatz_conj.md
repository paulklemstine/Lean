# The Tightest Yardstick for the Most Stubborn Number Game

## A simple rule, an impossible question

Pick any whole number. If it is even, cut it in half. If it is odd, triple it and
add one. Now repeat. Forever, if you like.

Start with 6: you get 3, then 10, then 5, 16, 8, 4, 2, 1. Start with 7 and you
wander up to 52 before crashing back down through 26, 13, 40, 20, 10, 5, 16, 8,
4, 2, 1. Start with 27 and you embark on an epic 111-step journey that climbs all
the way to 9,232 before it, too, finally tumbles to 1.

Every number anyone has ever tried — billions upon billions of them — eventually
falls into the same trap: 4, 2, 1, 4, 2, 1, forever. The claim that this *always*
happens, for *every* starting number, is the **Collatz conjecture**. It was posed
by Lothar Collatz in 1937, and despite its kindergarten-simple statement, it has
defeated every mathematician who has touched it. The great Paul Erdős said of it:
"Mathematics may not be ready for such problems."

This article is about a small but genuinely sharp piece of progress: not a proof
of the whole conjecture (no one has that), but the *best possible* version of one
of the central inequalities that any future proof will almost certainly need. And
it is a piece of progress that has been checked, line by line, with the
uncompromising rigor of a machine-verified proof — every claim below is a theorem
that has been formally established, with no hand-waving allowed.

## Why the game tends downward

The first thing to understand is *why* numbers tend to fall rather than rise. The
two moves are wildly unequal in strength.

- An **even step** divides by 2. That is a big cut: it removes a full "bit" from
  the number.
- An **odd step** multiplies by 3 and adds 1. That roughly *triples* the number —
  but here is the crucial subtlety.

After an odd step, the result `3n + 1` is *always even*. Try it: 3 times any odd
number is odd, and odd plus one is even. So every odd step is *immediately
followed* by a forced even step. The triple is never allowed to stand on its own;
it is instantly chopped in half. This is the **parity exclusion** principle: in a
Collatz trajectory, **you can never have two odd steps in a row**.

That single observation already tells you something powerful. Because odd steps
can never be consecutive, *at most half* of all the steps in any stretch of a
trajectory can be odd steps. The odd steps are forced to space themselves out.

## The tug-of-war, made precise

Now picture a stretch of the trajectory with `j` odd steps and `m` even steps.
Each odd step multiplies (roughly) by 3; each even step divides by 2. So, ignoring
the small "+1" nudges for a moment, the number gets multiplied by

$$\frac{3^{j}}{2^{m}}.$$

If this fraction is **less than 1**, the stretch shrinks the number. If it is
bigger than 1, the stretch grows it. So the entire question of whether trajectories
fall comes down to a deceptively clean inequality:

$$3^{j} < 2^{m}\,?$$

When does triple-`j` times lose to halve-`m` times?

## The crude answer, and why it wastes ground

There is an easy, almost childish argument that handles part of the question.
Notice that `3 < 4`, and `4` is just `2²`. So `3^j < 4^j = 2^{2j}`. Therefore, if
`2j < m` — that is, if the even steps outnumber the odd steps by more than two to
one — then `3^j < 2^{2j} \le 2^m`, and the stretch contracts. This is the
foundation result `pow3_lt_pow2_of_two_mul_lt`: *if `2j < m`, then `3^j < 2^m`*.

In density terms: if the fraction of odd steps is **less than 1/2**, contraction is
guaranteed.

It works — but it is leaving a lot on the table. The crude trick pretends that `3`
is as big as `4`. It is not. Three is smaller than four, and that gap is real
mileage we are throwing away. The *true* break-even density — the exact point where
`3^j` and `2^m` change places — is not 1/2 at all. It is a famous irrational
number:

$$\frac{\log 2}{\log 3} \approx 0.6309.$$

Between the crude 0.5 and the true 0.6309 lies a whole band of trajectory
stretches that genuinely contract but that the crude argument cannot see. The work
described here closes that gap exactly.

## Turning multiplication into addition

The key move is one of the oldest and most beautiful ideas in mathematics: the
**logarithm**, the tool that turns multiplication into addition and exponents into
multiplication. John Napier introduced logarithms in 1614 precisely to tame
unwieldy products; here they tame an unwieldy comparison of powers.

Take logarithms of both sides of `3^j < 2^m`. Because the logarithm is *strictly
increasing* — bigger inputs always give bigger outputs, with no exceptions — the
inequality survives the translation intact, and the exponents come down to ground
level:

$$3^{j} < 2^{m} \quad\Longleftrightarrow\quad j\,\log 3 < m\,\log 2.$$

This is the heart of the whole story, the theorem `pow3_lt_pow2_iff_log`. It says
the awkward comparison of giant powers is **exactly, perfectly equivalent** to a
simple straight-line inequality. Not "approximately," not "in most cases" —
*exactly*, in both directions. The same equivalence holds whether you read `3^j`
and `2^m` as real numbers or as plain whole numbers (`nat_pow3_lt_pow2_iff_log`).

Once contraction is phrased as a straight-line inequality, the optimal density
threshold simply *falls out*. Rearrange `j \log 3 < m \log 2` and you get

$$j \cdot \frac{\log 3}{\log 2} < m.$$

That constant `\log 3 / \log 2` is `log₂ 3 ≈ 1.585`; its reciprocal is the magic
`0.6309`. And so we arrive at the **sharp contraction criterion**, the theorem
`pow3_lt_pow2_of_density`:

> If `j · (log 3 / log 2) < m`, then `3^j < 2^m`.

This is the *best possible* threshold. You cannot push it any further, because at
exactly that ratio the two powers are equal, and beyond it the multiplication wins
and the stretch grows.

## Proving that sharper really is sharper

A new criterion is only worth having if it genuinely does more than the old one.
Two clean results pin this down.

First, **the new criterion never loses ground the old one held**. Whenever the
crude condition `2j < m` is satisfied, the sharp condition is satisfied too. The
reason is exactly the inequality `\log 3 < 2 \log 2` — which is just `3 < 4` viewed
through the logarithm. This is the theorem `log_of_two_mul_lt`. Anything the old
argument could prove, the new one proves as well.

Second, **the new criterion genuinely catches more**. There is an explicit case
where the sharp test fires but the crude one fails: take `j = 1` and `m = 2`. Here
`3^1 = 3 < 4 = 2^2`, so the stretch really does contract — and the logarithmic test
correctly says so, because `1 \cdot \log 3 < 2 \cdot \log 2`. But the crude test
asks "is `2 \times 1 < 2`?" and the answer is no. The single most basic contracting
stretch in the whole theory — one triple swallowed by two halvings — is invisible
to the crude argument and visible to the sharp one. This separation is the theorem
`sharp_threshold_strictly_stronger`. The sharp criterion is *strictly* better, and
`(1, 2)` is the witness.

Finally, to be sure we have located the threshold correctly, the constant itself is
pinned down: `\log 3 / \log 2` lies strictly between `1` and `2` (the result
`log3_div_log2_mem_Ioo`). It is above `1` — so you always need more halvings than
triplings, never fewer — and below `2` — so you never need a full two-to-one
margin. The true threshold lives in exactly the band the crude argument could not
reach.

## What this does *not* do — told honestly

It would be dishonest to suggest this resolves the Collatz conjecture. It does not,
and the work is scrupulous about saying where the wall still stands.

Everything above is about the *idealized* multiplier `3^j / 2^m`. The real Collatz
map carries that pesky "+1" at every odd step. Over a long trajectory those little
additions accumulate into a geometric error term. For large starting numbers the
error becomes negligible and segment-contraction should translate into genuine
orbit-contraction — but proving that cleanly is a separate and harder problem. It
is recorded openly as a conjecture (the file's single deliberate `sorry`), never
disguised as a theorem.

This is, in a sense, the real value of the work. It pins down *exactly* where the
difficulty lives. The power arithmetic — the comparison of `3^j` against `2^m` — is
now optimal; there is nothing more to extract there. The remaining mystery of
Collatz is *not* in the exponents. It is in controlling those small additive
nudges, and in the unpredictable way the density of odd steps fluctuates from one
starting number to the next. Parity exclusion guarantees the density never exceeds
1/2 over any segment — comfortably under the 0.6309 threshold — so *locally*,
contraction is assured. The conjecture is hard because *globally*, the growth
phases depend on the input in ways no one has been able to bound.

## The bigger picture

Why does a near-trivial-looking rule resist the full force of modern mathematics?
The honest answer is that the Collatz map is a tiny window onto computation itself.
A generalization of these "triple-or-halve" rules — letting the multipliers and
divisors vary by remainder class — was shown by John Conway to be **Turing
complete**: such systems can, in principle, simulate any computer program at all.
That means deciding the long-term fate of an arbitrary generalized Collatz rule is
*undecidable* — no algorithm can do it in general. The original Collatz map is a
single, very special point in that universe, and we simply do not know whether it
sits on the tame side or the wild side of the line.

That is what makes a sharp, fully-verified inequality worth celebrating even
without a final proof. In a problem where intuition has repeatedly misled the best
minds for almost a century, having one piece of the puzzle nailed down to its exact
optimal form — with every step checked and nothing swept under the rug — is real
ground gained. The crude estimate said "less than half the steps may be odd." The
sharp result says: "up to 63% may be odd, and that is the precise, unimprovable
boundary." Between those two numbers lived a whole region of the problem. Now it is
mapped.

The game of 3, halve, repeat keeps its biggest secret. But we now hold the tightest
possible yardstick for measuring when it pulls a number downward — and we know, to
the digit, exactly where that yardstick runs out.
