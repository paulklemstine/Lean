# The Wall That Wasn't

### How a single line in a bookkeeping ledger turned a guaranteed win into a recorded catastrophe

---

## A rumour about a cliff

Somewhere in the folklore of integer factorization there is a warning sign.

The elliptic curve method — ECM, the workhorse that pulls medium-sized prime factors out of large composite numbers — has a tuning knob called the *smoothness bound*, usually written $B_1$. Turn it up, and each attempt does more work but is more likely to succeed. Turn it down, and each attempt is cheap but usually fails. Everyone who has ever run ECM has fiddled with that knob.

The warning sign says: **don't turn it up too far.** In the version that concerns us, the claim was recorded like this: when $B_1$ grows to about $\min(p,q)$ — the smaller of the two prime factors of the number $N=pq$ you are trying to split — then *every* curve degenerates at once, the method destroys itself, and the expected number of curves you need becomes infinite. The sign even carried a fence line: only trust the method for $B_1 \lesssim \min(p,q)/2$.

It is a memorable claim, because it is a claim about a *cliff*. Most tuning knobs have a plateau: past a certain point, more effort just stops helping. A cliff is different. A cliff says that past a certain point, more effort actively *destroys* you.

This article is about what happened when someone walked up to the cliff edge and looked over.

There is no cliff. There is a summit — and the recorded catastrophe turns out to be a mislabelled photograph of standing on top of it.

---

## What ECM actually does, in one page

Fix a composite number $N = pq$ with $p$ and $q$ distinct primes that you do not know. Pick a random elliptic curve and a random point $P$ on it, both defined "modulo $N$". Now here is the sleight of hand at the heart of the method: because $N$ is composite, the arithmetic modulo $N$ is not really *one* world but two, glued together. Every computation you do modulo $N$ is secretly two computations running in lockstep: one modulo $p$, one modulo $q$.

Modulo $p$, your curve is a genuine elliptic curve over a field, and its points form a finite group of some size $m_p$. Modulo $q$, likewise, a group of size $m_q$. Hasse's theorem pins these sizes down tightly: $m_p$ lies within $2\sqrt{p}$ of $p+1$, so
$$p + 1 - 2\sqrt{p} \;\le\; m_p \;\le\; p + 1 + 2\sqrt{p}.$$
This narrow band is called the *Hasse window* of $p$.

Stage 1 of ECM chooses a smoothness bound $B$, forms the enormous integer
$$k(B) = \operatorname{lcm}(1,2,3,\dots,B),$$
and computes $[k(B)]P$ — the point $P$ added to itself $k(B)$ times — using a fast doubling ladder.

Here is the trick. Suppose the order of $P$ modulo $p$ divides $k(B)$. Then $[k(B)]P$ becomes the *identity* of the group modulo $p$: the point at infinity. But almost certainly it is not the identity modulo $q$. And a point that is "at infinity modulo $p$ but finite modulo $q$" cannot be written down in ordinary coordinates: the affine addition formula asks you to invert a denominator that is divisible by $p$ but not by $q$. The inversion fails — and the failure *is the answer*. You compute $\gcd(\text{denominator}, N)$ and out falls $p$.

So: **the method wins exactly when the arithmetic breaks, and only on one side.**

Call it *firing*: the mod-$p$ side fires when its order divides $k(B)$. Four things can happen in a single trial, and the whole story of this article is that you must keep them apart:

- **found $p$** — the $p$ side fires, the $q$ side does not. You get $p$. Victory.
- **found $q$** — the mirror image. Also victory.
- **dead** — *both* sides fire simultaneously. The denominator is divisible by $p$ and by $q$, so $\gcd = N$, which tells you nothing. This is the genuine failure mode, and the only one that deserves the word "destruction".
- **nothing** — neither side fires. No information, no harm; throw the curve away and pick another.

---

## The mechanism, and why it points the other way

Now turn the knob up. What happens when $B$ passes the top of $p$'s Hasse window, $B \ge p + 1 + 2\sqrt{p}$?

Every possible group order $m_p$ is then a positive integer *at most* $B$. And here is a fact so simple it is easy to walk straight past:

> **Size alone is enough.** If $1 \le n \le B$, then $n$ divides $\operatorname{lcm}(1,\dots,B)$.

Of course it does — $n$ is literally one of the numbers being lcm'd. Equivalently, every prime power $\ell^e$ exactly dividing $n$ satisfies $\ell^e \le n \le B$, so $n$ is $B$-powersmooth, so $n \mid k(B)$.

Chain it together. If $B \ge p+1+2\sqrt{p}$, then every order in the Hasse window of $p$ divides $k(B)$, so **every point on every curve** satisfies $[k(B)]P = \mathcal{O}$ modulo $p$. Every single curve degenerates modulo $p$. That is exactly the phenomenon the warning sign described.

But now ask the only question that matters: *does it also degenerate modulo $q$?*

If $q$ dwarfs $B$ — and it does, because you crossed the *smaller* prime's window — then almost never. Firing modulo $q$ would require the mod-$q$ order to have *all* its prime powers below $B$, and once $q$ is far above the bound that is overwhelmingly unlikely; when it fails, the only residue that fires modulo $q$ is the identity, a single point out of $m_q$. So the trial is not "both sides fire". It is "the $p$ side fires and the $q$ side does not".

That is **found $p$**. That is a win. And it is not a probabilistic win: it happens on *every* curve.

So the correct sentence about the regime $B \ge p+1+2\sqrt{p}$ is the exact opposite of the recorded one:

> **The Universal Success Theorem.** If the smoothness bound reaches the top of the Hasse window of $p$, then every point of every curve is annihilated modulo $p$; if additionally some prime factor of the mod-$q$ order exceeds $B$, the outcome of every trial is *found $p$*, and the revealed greatest common divisor is exactly the prime $p$. The per-curve success rate is $1$, and the expected number of curves needed is $1$ — not infinity.

The last clause deserves a moment. "Uncapped expected number of curves is infinite" is the most alarming part of the recorded wall. In the standard model where a random point is a uniformly random residue on each side, the fraction of points that fire modulo $p$ is exactly $\gcd(m_p, k(B))/m_p$, and the expected number of curves you must try is the reciprocal:
$$\mathbb{E}[T] \;=\; \frac{m_p}{\gcd\!\left(m_p,\,k(B)\right)}.$$
This quantity is *always at most $m_p$*. It is finite at every bound, for every group order. There is no regime — not at the wall, not anywhere — in which it is infinite. Moreover it only ever goes **down** as you raise $B$, because $k(B)$ divides $k(B')$ whenever $B \le B'$, so the gcd can only grow. At the wall it equals exactly $1$.

---

## So where *is* the real wall?

It would be too easy if the answer were "nowhere". There *is* a genuine self-destruction regime; it is just parked somewhere else entirely.

Death — the `dead` outcome, $\gcd = N$ — requires **both** sides to fire. That needs $B$ to cover the Hasse window of $p$ *and* the Hasse window of $q$. So the destruction threshold sits at $\max(p,q)$, not $\min(p,q)$.

And between the two thresholds there is a beautiful, clean dichotomy:

> **The Wall Dichotomy.** Suppose $B$ passes the top of $p$'s Hasse window while some prime factor of the mod-$q$ order still exceeds $B$; and suppose $B'$ passes the tops of *both* windows. Then every trial at bound $B$ records *found $p$*, and every trial at bound $B'$ records *dead*.

The recorded threshold $\min(p,q)$ is real, and it is a threshold — but it is the **success** threshold. The **destruction** threshold is $\max(p,q)$, exponentially far away in practice, and reaching it would in any case cost you more work than trial division. Nobody has ever accidentally wandered there.

To see that the real wall is not a figment, here is the smallest possible witness. Take both groups to have order $2$. At bound $B=1$ the scalar is $k(1)=1$, only the identity fires on each side, and of the four possible trials exactly two reveal a factor. At bound $B=2$ the scalar is $2$, *both* orders are covered, every trial is dead, and the reveal count is $0$. The count really does fall off a cliff, from $2$ to $0$ — at $\max$, once the bound has swallowed both orders.

---

## The mislabelled photograph

We can now say precisely what went wrong, and it is not a mathematical error. It is a bookkeeping error, of a kind that is embarrassingly easy to commit.

Think of a *ledger* as a rule that turns what actually happened — the pair of facts (did the $p$ side fire? did the $q$ side fire?) — into a recorded outcome. There are four possible firing patterns. The honest ledger sends them to four distinct labels: $(\text{yes},\text{no}) \mapsto$ found $p$, $(\text{no},\text{yes}) \mapsto$ found $q$, $(\text{yes},\text{yes}) \mapsto$ dead, $(\text{no},\text{no}) \mapsto$ nothing. Call a ledger **faithful** if distinct firing patterns get distinct labels. The honest ledger is faithful: it is an injection from four inputs onto four outputs.

Now consider the single most natural shortcut a tired implementer can take: *if the mod-$p$ arithmetic degenerated, record a degeneracy*. Formally, send $(\text{yes},\text{no})$ and $(\text{yes},\text{yes})$ both to "dead". This ledger is **not faithful** — two distinct realities collapse into one label — and on precisely the firing pattern generated at the wall, $(\text{yes},\text{no})$, it records **dead** where the truth is **found $p$**.

Feed the Universal Success Theorem through that one conflation and you get, word for word:

> "when $B_1 \gtrsim \min(p,q)$, every Hasse-window order divides $\operatorname{lcm}(1..B_1)$, all curves degenerate simultaneously, uncapped $\mathbb{E}[T]$ infinite."

Every clause is *true of the mathematics* except the labels. All curves *do* degenerate. The degeneracy *is* simultaneous, across curves. And if you file every degeneracy under "loss", your measured success rate is zero, so your estimate of the expected number of curves diverges. The wall is not a property of ECM. It is the image of a non-injective ledger.

---

## Walking to the edge

Theory is cheap; the regime was also walked directly. Six hundred trials on 26-bit composites $N = pq$ with $q \gg p$, sweeping $B_1/p \in \{0.125, 0.25, 0.5, 0.9, 1.05\}$ — that is, from an eighth of the way to the alleged cliff, right up over its lip — with all four outcomes recorded separately.

The result: **zero dead outcomes in the entire grid.** Success rate $1.000$ in every cell with $B_1/p \ge 0.25$, and in particular $1.000$ in all six cells at $B_1/p = 0.9$ and $B_1/p = 1.05$ — exactly the coordinates where the catastrophe was recorded. The only imperfect cells sat at $B_1/p = 0.125$, at rates $0.875$ and $0.95$, and every miss there was filed as **nothing** — no information — never as **dead**.

The theory accounts for this. When every prime factor of the mod-$q$ order exceeds $B$, the fraction of trials that go dead is exactly $1/m_q$ — around $10^{-8}$ at this scale, so across 600 trials the expected number of deaths is below $10^{-4}$. (The honest caveat: that inertness is itself a probabilistic event, and when $q$ is only a small multiple of the bound a few percent of trials can have a mod-$q$ order smooth enough to fire, producing genuine deaths. Whether the recorded grid was simply fortunate, or whether its death channel was under-counted, is exactly the sort of question a replication should settle. Either way it leaves the verdict untouched: no bound ever reduces the number of trials on which the $p$ side fires.)

Even the low-edge cells carry a lesson. At $B_1/p = 1/8$, a guarded affine implementation enjoys a free "collision" baseline: the ladder performs roughly $1.44\,B_1$ operations, each with about a $1/p$ chance of accidentally hitting a vanishing denominator, giving a success floor of about $1 - e^{-1.44 B_1/p}$. Since $1 - e^{-x} \le x$ always, that floor is at most $0.18$ at $B_1/p = 1/8$ — well below the roughly $68\%$ actually observed. So the low-edge successes are not collision luck; genuine order-divisibility is already doing most of the work far below the alleged fence line at $\min(p,q)/2$.

Indeed, that fence line was never in the right place either. Take $p = 13$: the arithmetic ceiling on its Hasse window is $22$, and the Hasse-window order $12$ already divides $\operatorname{lcm}(1,\dots,7) = 420$. A curve of order $12$ fires from bound $4$ onward — well under $p/2$.

---

## The one thing you must not do

There is a genuine subtlety here, and glossing over it would replace one sloppy sentence with another.

**Individual outcome channels are not monotone.** The *total* firing count is monotone in $B$, always. But the found-$p$ count on its own can crash. A concrete example: with group orders $m_p = 4$ and $m_q = 6$, raising the bound from $2$ to $3$ takes the found-$p$ count from $8$ down to $0$. Not one of those eight trials failed. They *migrated* — into the dead block, because the bound $3$ started firing the mod-$q$ side too.

That is the whole moral in miniature. If you watch one channel and call its decline a failure of the method, you will see walls everywhere. Channel separation is not fastidiousness; it is the difference between reading the ledger and hallucinating from it.

There is also a price for the certainty: the scalar $\operatorname{lcm}(1,\dots,B)$ contains at least $2^{\pi(B)}$, where $\pi(B)$ counts primes up to $B$. So the doubling ladder performs at least $\pi(B)$ doublings, which is why nobody runs ECM at $B_1 \approx p$ in practice. The wall regime is not dangerous. It is merely expensive — and if you could afford it, it would work every single time.

---

## The moral

The most seductive kind of scientific error is not a false theorem. It is a true theorem with the wrong label glued to it.

Here, everything about the mechanism was right. Every Hasse-window order really does divide $\operatorname{lcm}(1..B_1)$ once the bound clears the window. All curves really do degenerate at once. The mathematics was correct and the observation was correct. What failed was one arrow in a map from four states to four names — a map that quietly stopped being injective, and in doing so converted a theorem of guaranteed success into a recorded catastrophe.

The fix costs nothing: record four outcomes instead of two. Ask, every time a computation dies, *which side of the number it died on*. In factorization, that question is not pedantry. It is literally the answer you were looking for.
