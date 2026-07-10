# Hilbert's Hotel for Primes: The Guests Who Barely Move

## An infinite hotel with an unusual clientele

Imagine a hotel with infinitely many rooms, numbered $1, 2, 3, \dots$, and a curious rule for who stays where: room $n$ is reserved for the $n$-th prime number. Room $1$ houses the number $2$, room $2$ houses $3$, room $3$ houses $5$, then $7$, $11$, $13$, and so on forever. Because there are infinitely many primes — a fact known since Euclid — every room is occupied, and the manager never runs out of guests.

This is a twist on the famous thought experiment of David Hilbert, who used an infinite hotel to illustrate the strange arithmetic of infinity. In Hilbert's original story, the manager can always make room for newcomers by shuffling guests down the corridor. Our version asks a different and, it turns out, deeper question. Suppose the prime guests decide they want to *rearrange themselves*. Each prime picks a new room, and no two primes end up in the same room — a perfect reshuffle. After the dust settles, room $n$ now holds some prime $q_n$, generally not the one it started with.

The question is simple to state: **after the reshuffle, how far did the guests really move?**

## Measuring the disruption

To make "how far did they move" precise, we compare the prime now in room $n$ with the prime that was there originally. Let $p_n$ denote the $n$-th prime, so $p_1 = 2$, $p_2 = 3$, $p_3 = 5$, and so on. A rearrangement is a permutation $\sigma$ of the room numbers: the guest that started in room $\sigma(n)$ moves into room $n$. So room $n$, which used to hold $p_n$, now holds $p_{\sigma(n)}$.

The natural yardstick is the **displacement ratio**
$$
R_\sigma(n) = \frac{p_{\sigma(n)}}{p_n}.
$$
If this ratio is close to $1$, then the prime now in room $n$ is *numerically* about the same size as the prime that used to be there — even if it is a completely different number. We call a rearrangement **well behaved** if the displacement ratios settle down to $1$ as we walk further and further down the corridor:
$$
R_\sigma(n) \longrightarrow 1 \quad \text{as } n \to \infty.
$$
Intuitively, a well-behaved rearrangement may cause chaos among the first few rooms, but far out along the hallway the guests barely change size. The room labels get scrambled, yet the *magnitudes* stay almost fixed.

Which reshuffles are well behaved? The answer reveals a beautiful tension between flexibility and rigidity.

## The easy reshuffles: move only finitely many guests

Start with the mildest kind of rearrangement: one that disturbs only finitely many guests and leaves everyone else exactly where they were. Perhaps you swap the occupants of rooms $4$ and $9$, and shift a handful of others, but from some room $N$ onward nobody moves at all.

For such a rearrangement, the displacement ratio is not just *close* to $1$ far down the hall — it is *exactly* $1$. Once you pass the last disturbed room, $\sigma(n) = n$, so $R_\sigma(n) = p_n / p_n = 1$. A sequence that is eventually constant at $1$ certainly converges to $1$. So:

> **Every rearrangement that moves only finitely many guests is well behaved.**

This is reassuring but not surprising. The interesting question is what happens when *infinitely* many guests move.

## The main event: almost any reshuffle can be well behaved

Here is the first genuinely striking result. Fix *any* rearrangement you like — no matter how wild, no matter how many guests it displaces, no matter how far it flings them. Now fix any finite stretch of the hotel, say the first million rooms. Then there is a **well-behaved** rearrangement that agrees with your wild one on all of those first million rooms.

In other words, no finite amount of observation can distinguish a well-behaved rearrangement from an arbitrary one. Whatever pattern of shuffling you can specify on a finite front desk ledger, a well-behaved reshuffle can reproduce it exactly, and then quietly settle down to near-identity out of sight.

> **Density Theorem.** For every permutation $\sigma$ of the rooms and every $N$, there exists a well-behaved permutation $\tau$ with $\tau(i) = \sigma(i)$ for all $i < N$.

The proof is a small marvel of bookkeeping. Given a target rearrangement $\sigma$ and a horizon $N$, we build a finite-support permutation $\tau$ that copies $\sigma$ on the first $N$ rooms. We do it one room at a time. To make $\tau$ agree with $\sigma$ at room $N$ while preserving everything already arranged, we compose with a single swap — a transposition that exchanges two rooms and fixes all others — chosen so it doesn't disturb any of the rooms $0, 1, \dots, N-1$ we already handled. After $N$ such swaps we have a permutation that moves only finitely many guests and matches $\sigma$ exactly on the target segment. Since finite-support permutations are well behaved, we are done.

In the language of topology, this says the well-behaved rearrangements are **dense** in the space of all rearrangements, under the notion of closeness where two reshuffles are "near" when they agree on a long initial segment. The primes, it seems, are extraordinarily forgiving: you can approximate any shuffling scheme whatsoever with one that barely changes the room magnitudes in the long run.

## The catch: not every reshuffle is well behaved

Density might tempt you to guess that *every* rearrangement is well behaved. It is not. And the counterexample is the whole point — it shows the phenomenon has teeth.

Consider a reshuffle that reverses the order of the guests. If, near room $n$, we send the prime from a room far *ahead* back to room $n$, then $p_{\sigma(n)}$ is enormous compared to $p_n$, and the ratio blows up. Reversal is the extreme case, but we can build a cleaner, surgical counterexample that pins down exactly why things go wrong.

Because the primes grow without bound, for any index $m$ we can always find a later index $b > m$ whose prime is at least twice as large: $p_b \ge 2\, p_m$. Chaining this, we produce a rapidly growing sequence of "landmark" rooms
$$
j_0 < j_1 < j_2 < \cdots, \qquad p_{j_{k+1}} \ge 2\, p_{j_k}.
$$
Each landmark's prime is at least double the previous landmark's. Now define a rearrangement that leaves every non-landmark room untouched, and among the landmarks performs long-range swaps: it exchanges the guests of landmarks $j_0 \leftrightarrow j_1$, then $j_2 \leftrightarrow j_3$, then $j_4 \leftrightarrow j_5$, and so on in consecutive pairs. This is an **involution** — doing it twice returns everyone home — so it is a genuine, invertible rearrangement.

At the smaller landmark of each swapped pair, the guest arriving is the prime from the *larger* landmark, at least twice as big. So the displacement ratio there is at least $2$. This happens at infinitely many rooms. A sequence that keeps jumping up to $2$ or beyond cannot possibly converge to $1$.

> **Not universal.** There exists a rearrangement whose displacement ratio is $\ge 2$ for infinitely many rooms; it is not well behaved.

So the well-behaved rearrangements are dense — arbitrarily close to anything — yet they are a genuine, proper part of all rearrangements. Robustness and fragility coexist.

## Why this is more than a curiosity

What makes the story satisfying is that all of these facts about the primes — the easy positive result, the surprising density, and the explicit failure — required almost nothing arithmetic-specific. The only property of the primes we used is that they form a strictly increasing sequence marching off to infinity. Everything else is pure combinatorics of infinite permutations.

That has a moral. The "well-behaved" phenomenon is not really about primes at all; it is about any sequence of room labels that grows steadily without bound. Replace the primes by the squares, the factorials, or any strictly increasing unbounded sequence, and the same three theorems hold verbatim. In this sense the asymptotic size of the guests is a **structural invariant of the shuffling** — robust to any finite meddling, approximable to any precision, and yet not immune to cleverly engineered long-range chaos.

The primes do enter when we push further. A famous consequence of the Prime Number Theorem is that consecutive primes are asymptotically equal — $p_{n+1}/p_n \to 1$ — which means even the reshuffle that swaps each even room with its neighboring odd room is well behaved, despite moving *every* guest. And the theorem $p_n \sim n \log n$ suggests a clean conjecture: a rearrangement is well behaved precisely when it distorts room indices by an asymptotically negligible factor, $\sigma(n)/n \to 1$. That would make "well-behaved" a sharp asymptotic signature, converting a statement about primes into a statement about the geometry of the infinite symmetric group.

## The picture that remains

Picture the infinite corridor one last time. A reshuffle sweeps through, tossing prime guests from room to room. If it disturbs only a finite front section, the far corridor is untouched and calm. If it is engineered with escalating long-range swaps, pockets of disruption recur forever, with newcomers twice the size of the departed. And in between lies the remarkable middle ground: for any conceivable pattern of disturbance on any finite stretch, there is a reshuffle that mimics it perfectly up front and then, out past the horizon, lets the magnitudes glide gently back toward where they began.

The primes, robust and generous, absorb almost any rearrangement without changing their asymptotic character — but only *almost* any. That "almost" is where the mathematics lives.
