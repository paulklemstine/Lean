# The Uncanny Valley of Mathematics: When Almost-Perfect Is Worse Than Imperfect

## A curve that captures a feeling

There is a strange dip in how we react to things that are *almost* like us. A cartoon robot with big friendly eyes charms us. A slightly more realistic android charms us a little more. But push the resemblance just past a certain point — a face that is *nearly* human, yet subtly wrong — and something recoils in us. The charm collapses into discomfort. Only when the imitation becomes flawless, indistinguishable from a real person, does the warmth return.

The roboticist Masahiro Mori named this dip the **uncanny valley** in 1970. It is usually drawn as a curve: acceptance climbing steadily with human-likeness, cresting at a first peak, plunging into a trough, and then climbing back out. It is one of those ideas that everyone recognizes but few can pin down. Can a phenomenon this psychological, this slippery, be captured by a clean mathematical object?

It can. And remarkably, the simplest cubic you could write down does the job perfectly.

## The star of the show

Consider the function
$$
U(x) = x^3 - 3x,
$$
where $x$ measures how human-like an artifact is, and $U(x)$ measures how much we accept it. This is about as humble as functions get — a cubic with a single, symmetric shape. Yet it contains, exactly, the entire arc of Mori's story.

To see why, we only need two small algebraic miracles. The first is
$$
U(x) - 2 = (x-2)(x+1)^2,
$$
and the second is
$$
U(x) + 2 = (x-1)^2(x+2).
$$
These two factorizations are the engine of everything below. They are easy to verify by expanding, and once you have them, every quantitative claim about the uncanny valley falls out almost for free.

## Three landmarks

Plug in a few values and the landscape appears:

- At $x = -1$, we find $U(-1) = (-1)^3 - 3(-1) = -1 + 3 = 2$. This is the **near-human peak** — the first crest of acceptance.
- At $x = 1$, we find $U(1) = 1 - 3 = -2$. This is the **bottom of the valley** — the trough of discomfort.
- At $x = 2$, we find $U(2) = 8 - 6 = 2$. Here acceptance has climbed back to exactly the height of the earlier peak. This is the **recovery point**.

So the curve rises to a height of $2$, drops all the way down to $-2$, and then recovers back to $2$. The valley is real, and it is deep.

## Why it rises, falls, and rises again

The genuinely satisfying part is proving that the curve actually *moves* the way the landmarks suggest — not just that it hits those three heights, but that it is monotonically climbing, then monotonically falling, then climbing once more. For this there is a single unifying identity. For any two inputs $a$ and $b$,
$$
U(b) - U(a) = (b-a)\,\bigl(a^2 + ab + b^2 - 3\bigr).
$$
This is the whole story in one line. The sign of the change in acceptance, $U(b) - U(a)$, is the product of two factors: the direction of travel $(b - a)$, and a symmetric quadratic $Q(a,b) = a^2 + ab + b^2 - 3$. Everything hinges on the sign of $Q$.

**The ascent.** Suppose we are still far from human, in the region $x \le -1$, and we move rightward from $a$ to $b$ with $a < b \le -1$. Then both numbers are large in magnitude, and $a^2 + ab + b^2$ exceeds $3$, so $Q(a,b) > 0$. Since $b - a > 0$ as well, the product is positive: $U(a) < U(b)$. Acceptance strictly increases. The closer to human, the more we like it.

**The uncanny descent.** Now enter the danger zone $-1 \le a < b \le 1$. Here a short computation — using that $a + 1 \ge 0$ and $1 - b \ge 0$ — shows $Q(a,b) < 3 - 3 = 0$; concretely $a^2+ab+b^2 < 3$. The quadratic factor has flipped sign. Now $b - a > 0$ but $Q(a,b) < 0$, so $U(b) < U(a)$: acceptance strictly *decreases*. This is the uncanny valley itself, expressed as pure algebra. The more human the artifact becomes across this band, the *less* we accept it.

**The recovery.** Finally, for $1 \le a < b$, both numbers are again large enough that $a^2 + ab + b^2 > 3$, so $Q(a,b) > 0$ and acceptance strictly increases once more. We are climbing out of the valley.

Three regimes, one identity, three sign patterns. That is the uncanny valley.

## The drop, made precise

Chaining these together gives the two headline facts.

**There is a genuine drop.** Because acceptance strictly decreases across $[-1, 1]$, the valley bottom sits strictly below the near-human peak:
$$
U(1) < U(-1), \qquad \text{that is,} \qquad -2 < 2.
$$
More than that: acceptance is already below the peak the *instant* we pass it. For any $x$ with $-1 < x \le 1$, we have $U(x) < U(-1)$. There is no plateau, no grace period; stepping past the near-human peak immediately costs us.

**The valley bottom is a true minimum.** Using the factorization $U(x) + 2 = (x-1)^2(x+2)$, we see that for every $x \ge -2$ the right-hand side is a square times a nonnegative number, hence nonnegative. Therefore $U(x) \ge -2 = U(1)$ throughout $[-2, \infty)$. The trough at $x = 1$ is not a local accident — it is the lowest acceptance can go across the entire meaningful range.

## Full recovery: perfection beats near-perfection

The most poetic consequence concerns what happens *after* recovery. Once the resemblance is pushed beyond the recovery point — for any $x > 2$ — the factorization $U(x) - 2 = (x-2)(x+1)^2$ has a positive first factor and a nonnegative square, so
$$
U(x) - 2 > 0, \qquad \text{i.e.} \qquad U(-1) < U(x).
$$
A fully realized, beyond-threshold artifact is accepted *more* than the almost-human one that charmed us before the fall. Perfection does not merely undo the damage of the valley; it surpasses the earlier high-water mark. The reward for crossing the valley is greater than the comfort we felt before we ever knew the valley was there.

## The whole shape in one statement

All of these threads braid into a single capstone. There exist three landmarks $x_0 = -1 < x_1 = 1 < x_2 = 3$ such that the acceptance curve $U$:

1. **rises** on the approach to the near-human peak $x_0$ (for $a < b \le x_0$, $U(a) < U(b)$);
2. **drops** strictly from the peak into the valley (for $x_0 \le a < b \le x_1$, $U(b) < U(a)$);
3. **recovers**, rising again from the valley onward (for $x_1 \le a < b$, $U(a) < U(b)$);
4. plunges to a valley bottom strictly below the peak ($U(x_1) < U(x_0)$);
5. and eventually surpasses the peak at the fully-human point ($U(x_0) < U(x_2)$).

This is Mori's psychological curve, rendered as a theorem about a cubic polynomial. Ascent, peak, drop, valley, recovery, and overtaking — all five acts of the drama, certified.

## Why this matters beyond robots

It is tempting to dismiss all this as a cute coincidence: of course *some* function wiggles the right way. But the point is sharper than that. The uncanny valley is often treated as an ineffable quirk of human psychology, resistant to formalization. What the cubic $U(x) = x^3 - 3x$ shows is that the *shape* — non-monotonic acceptance with a single deep trough between two rising arms — is not mysterious at all. It is the generic behavior of any smooth quantity with exactly two turning points. The valley is what happens whenever a system has a local maximum followed by a local minimum before resuming its climb.

That reframing is liberating. It suggests the uncanny valley is not special to faces or robots but is a template that recurs wherever "almost right" is genuinely worse than "clearly wrong." Think of the discomfort of a translation that is fluent enough to lull you and then jarringly off; a synthesized voice that is warm until a single flat vowel breaks the spell; a near-miss in music, design, or animation. Each is a descent into some valley, governed by the same sign-change logic: a quantity that was helping you now works against you, right up until you cross to the other side.

And there is a hopeful corollary baked into the mathematics. Full recovery does not just return you to where you were — it takes you higher. In the model, the beyond-threshold point at $x > 2$ strictly exceeds the near-human peak. The message for anyone building the almost-human — animators, engineers, designers, writers — is that the valley is survivable, and the far rim is worth reaching. The discomfort of "almost" is not a dead end but a passage, and the reward on the other side is greater than the comfort you left behind.

## A last word on simplicity

Perhaps the most beautiful thing here is the economy of it. No calculus is strictly necessary; two factorizations and one difference identity carry the entire argument. A phenomenon that feels irreducibly human — the shiver at a not-quite-right face — turns out to be encoded in a polynomial a child could graph. That is the quiet power of mathematics: to take a feeling we can barely articulate and hand it back to us as a curve, exact and provable, with every dip and every rise exactly where it should be.
