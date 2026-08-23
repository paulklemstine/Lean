# The Cards You Know, and the Cards You Don't

*Why uncertainty, priced honestly, is worth exactly nothing — and why it so often looks like it's worth something.*

---

## A deck, a memory, and a bet

Imagine a shuffled deck of $52$ cards laid face down in a row. You have been watching carefully, and you are certain about $d$ of them: you know exactly which card sits in each of those $d$ positions. The remaining $u = 52 - d$ are a blur. You will have to guess.

Someone offers you a game. For every card you name correctly you are paid; for every card you get wrong you pay. The odds on the uncertain cards are *fair* — set so that a blind guess is neither favoured nor punished. The question is old and simple: **what is this game worth?**

The answer is not "somewhere between $d$ and $52$, depending on how clever you are". The answer is

$$\text{expected payoff} \;=\; d.$$

Exactly $d$. Not $d$ plus a correction. Not $d$ plus something growing with $u$. Not $d$ plus an amount depending on whether you guess randomly, or systematically, or name the same card fifty-two times in a row. **The uncertain block is worth precisely zero, and no ingenuity applied to it changes that.**

This article is about that statement, and — more interestingly — about the ways it appears to fail. Because it does appear to fail, constantly: in card rooms, on trading floors, in machine-learning papers. Every apparent failure turns out to be one of exactly three things: a mispriced book, a misread variance, or a quiet purchase of genuine information.

---

## The splitting theorem

Suppose the world can be in any one of finitely many equally likely states. A *card* is a payoff: a rule $p$ assigning a rational number to each state. Call a card **resolved with value $c$** if $p$ returns the same $c$ in every state — you know it, and you collect $c$ regardless. Call it **fair** if its average payoff $\mathbb{E}[p]$ is zero.

> **Splitting Theorem.** Let $p_1,\dots,p_n$ be cards, and let $K$ be a set of indices such that $p_i$ is resolved with value $c_i$ for $i \in K$, and fair for $i \notin K$. Then
> $$\mathbb{E}\Big[\sum_{i=1}^n p_i\Big] \;=\; \sum_{i \in K} c_i .$$
> In particular, if each resolved card pays one unit, the expected total is exactly $|K|$.

The proof is three lines, and its brevity is the point: averaging is linear, resolved terms contribute their constants, fair terms contribute zero.

What matters is what the hypotheses *don't* say. Nothing about independence — in a shuffled deck the cards are violently correlated, since knowing where the ace of spades is tells you it is nowhere else. Nothing about the guessing rule, or how the fair cards were chosen, or with what cunning. Fairness of each card *individually* suffices.

A special case deserves its own name:

> **No Edge From Uncertainty Alone.** A portfolio built entirely of fair cards has expected payoff zero — regardless of correlations, regardless of strategy.

You cannot manufacture an edge by combining things that individually have none.

---

## Where the deck comes in

Model the unresolved block honestly: $u$ slots, $u$ cards, and a uniformly random bijection $\sigma$ from slots to cards. Your strategy is *any* function $g$ from slots to cards — "in slot $i$ I call card $g(i)$" — not necessarily injective. You are allowed to be foolish and call the seven of hearts everywhere.

Scoring pays $w$ on a hit and $\ell$ on a miss. Then:

> **Slot Formula.** For every slot $i$, every called card $a$, and every $u \ge 1$,
> $$\mathbb{E}[\text{score of slot } i] \;=\; \frac{w-\ell}{u} + \ell .$$

Independent of the slot, of the call, and hence of the entire strategy. The engine is a counting fact worth seeing. How many of the $u!$ arrangements put a prescribed card $a$ in a prescribed slot $i$? Rather than "fix it and permute the rest", note that composing an arrangement with the transposition swapping $a$ and $b$ is a bijection between the arrangements putting $a$ in slot $i$ and those putting $b$ there. All $u$ such classes have equal size and they partition everything, so
$$u \cdot \#\{\sigma : \sigma(i) = a\} = u! .$$
No factorials were harmed. The same trick one level down says that, given $\sigma(i)=a$, the card in a different slot $j$ is uniform over the remaining $u-1$: for $i \ne j$ and $a \ne b$,
$$(u-1)\cdot\#\{\sigma : \sigma(i)=a,\ \sigma(j)=b\} = \#\{\sigma : \sigma(i)=a\}.$$
These are the first two rungs of a ladder we return to at the end. Summing the slot formula over the block:

> **Block Value.** For every strategy $g$, the unresolved block is worth $(w-\ell) + \ell u$.

---

## Fair odds are not a convention — they are forced

Set the block value to zero: $(w - \ell) + \ell u = 0 \iff w = \ell(1-u)$.

> **Rigidity of Fair Odds.** The block of size $u$ has zero expected value for one strategy if and only if $w = \ell(1-u)$ — and then it has zero expected value for *every* strategy.

With the standard normalisation $\ell = -1$ this reads $w = u-1$: a hit must pay $u-1$ to one, exactly the honest quote among $u$ equally likely candidates. So "no edge" is not an artefact of lucky numbers; it *characterises* the honest quote. Any other pricing hands *every* strategy the identical nonzero edge — a property of the book, not of the player. Assembling:

> **Known versus Unresolved Cards.** With $d$ cards known with certainty, each paying one unit, plus an unresolved block of $u$ cards at fair odds $(u-1):1$, the expected payoff is exactly $d$, for every strategy.

---

## The counting anomaly: where the phantom edge lives

Score the block naively — $1$ for a hit, $0$ for a miss — and the block value becomes $(1-0) + 0\cdot u = 1$.

> **The Counting Anomaly.** Under naive unit scoring the expected number of correct calls is exactly $1$ — for every strategy and every block size. The full deck scores $d+1$, not $d$.

One card. Always one, whether $u$ is $3$ or $3{,}000$. (This is the classical fact that a random permutation has one fixed point on average, generalised to comparison against an arbitrary, possibly silly, guess.)

That $+1$ is where much confusion lives. It is real — you do get one extra correct call. But it is not an *edge*, because unit scoring is not a fair book: it pays for hits and never charges for misses. Whoever offers it is making you a gift of exactly one card, and the gift does not grow if you think harder or if the deck grows. Restore the honest $(u-1):1$ and the $+1$ evaporates.

---

## The second thing you can control: risk

If the mean is strategy-invariant, is every strategy the same? Emphatically not.

Take $u \ge 2$. Strategy A calls a different card in every slot; strategy B calls the same card everywhere. B's score is a deterministic $1$ — the seven of hearts is somewhere, exactly one slot holds it, you called it there. Zero variance. A's score genuinely fluctuates: its variance is exactly $1$.

Same mean, different risk — and the general statement interpolates beautifully. Define the **collision profile** of $g$ as the number of *ordered* slot pairs receiving different calls,
$$D(g) = \#\{(i,j) : g(i) \ne g(j)\},$$
which is $u(u-1)$ for an injective strategy and $0$ for a constant one.

> **Collision Formula.** For every strategy $g$ on a block of $u \ge 2$ cards,
> $$\operatorname{Var}[\text{hits}] \;=\; \frac{D(g)}{u(u-1)} .$$

The variance is exactly the *fraction* of slot pairs on which you hedged by naming distinct cards, running continuously from $0$ to $1$. The mean cannot see your strategy at all; the variance sees precisely its pattern of repeated calls, and nothing else.

This is the honest reply to "so it doesn't matter what I do". It doesn't matter for the mean. It matters completely for the distribution. Choosing a strategy in a fair game is choosing a risk profile — a real choice, just not a choice about expected value.

---

## What information is actually worth

Now let the player have **feedback**: after each call, the card is turned face up. The only state she needs is the set $S$ of cards still unseen, so a feedback strategy is a rule $g$ sending the live set $S$ to a call $g(S)$, and it is *admissible* when it never names a dead card, $g(S) \in S$.

> **The Value of Feedback.** Under naive unit scoring, an admissible feedback strategy on $u$ cards makes exactly
> $$H_u = 1 + \tfrac12 + \tfrac13 + \cdots + \tfrac1u$$
> correct calls in expectation — versus exactly $1$ for any blind strategy.

The proof is a one-line recursion: on a live set of size $m$ the next card is uniform, so an admissible call hits with probability $1/m$, and the game continues on $m-1$ cards. So $V(m) = 1/m + V(m-1)$, $V(0)=0$. Every admissible strategy achieves $H_u$ — clever or lazy makes no difference, provided you never re-call a seen card. And $H_u$ grows without bound, like $\log u$; Oresme's fourteenth-century argument that doubling the range adds at least $\tfrac12$ gives $1 + n/2 \le H_{2^n}$, so for any target $C$ there is a block on which feedback beats $C$ correct calls while blindness still scores exactly $1$. Already at $u=2$: $H_2 = 3/2 > 1$.

**And now the punchline.** Price the feedback game honestly stage by stage: with $m$ cards live, a hit pays $m-1$ and a miss costs $1$.

> **Fair Odds Are Information-Proof.** Under stagewise fair odds the feedback game has expected payoff exactly $0$, for every admissible strategy and every live set.

Zero — the same zero as the blind game. Information did not create value against a correctly priced book; it changed the price. This explains what feedback really bought under unit scoring: nothing at all against an honest counterparty. The $H_u - 1$ was never an edge over the game, but an edge over a book that had failed to update its odds. **Information is worth exactly as much as someone else's prices are stale.**

---

## The same theorem, wearing a lab coat

Change vocabulary and watch the identical theorem reappear. Fix a finite domain $X$; let the *target* $f$, labelling each point true or false, be uniformly random among all $2^{|X|}$ possibilities. A learner sees the labels on a training set $T$ and outputs a hypothesis $L(f)$ labelling all of $X$. It is *consistent* (it reproduces the training labels) and *blind off-sample* (it depends on $f$ only through the labels on $T$). Score $+1$ per correct prediction, $-1$ per error.

> **No Free Lunch.** The expected total score is exactly $|T|$, for every such learner.

The training points are the known cards; everything else is unresolved; and this is the Splitting Theorem again. The only thing to check is that an off-training point is genuinely *fair*, and the argument is as sharp as arguments get. Fix $x \notin T$ and flip the label of $f$ at $x$ alone. This is a fixed-point-free involution of target space; it leaves the training labels untouched, hence the hypothesis untouched, hence the *prediction* at $x$ untouched — while flipping the *truth* at $x$, negating the score there. Pair each target with its flip: the scores cancel exactly.

In accuracy terms, the expected number of correct predictions is
$$|T| + \frac{|X| - |T|}{2} = \frac{|T| + |X|}{2},$$
perfect on the training set and *exactly chance* everywhere else. Averaged over all targets, no algorithm generalises. The hypotheses are load-bearing, and sharply so: a "learner" allowed to peek at off-training labels and copy them scores the maximum $|X|$ with an empty training set. The result survives beyond binary labels — with $k$ labels, replace the flip by the free action of the cyclic group of order $k$ and price a card at fair odds $(k-1):1$; the orbits cancel and a consistent learner's expected score is exactly $(k-1)|T|$.

The moral is not that learning is impossible, but that every working algorithm's success is borrowed entirely from the fact that real targets are *not* uniformly random — from the prior, the structure, the inductive bias. The uniform average over all targets is the unresolved block, and it is worth zero.

---

## No system, ever

The oldest objection in the casino: maybe you can't beat a fair bet, but surely you can beat a fair *sequence* of bets by choosing how much to stake and when to walk away.

Let the gambler be maximally adaptive. She watches fair $\pm1$ coin tosses; before each she picks a stake — any rational, either sign (she may switch sides), any size, depending on the whole history. Staking $0$ means she has quit, so this includes every stopping rule.

> **No Betting System.** For every adaptive stake function, every finite horizon, and every history, the expected net gain is exactly $0$.

Induction on the horizon, in a sentence: the stake $s$ contributes $+s$ with probability one half and $-s$ with probability one half, and whatever happens the remaining game is worth zero.

And then the classic counterexample, which is not one. The **doubling system**: bet one; on a loss bet two, then four, doubling until you win, then stop. After $k$ losses you are down $1+2+\cdots+2^{k-1} = 2^k - 1$ and stake $2^k$, so a win nets $2^k - (2^k-1) = 1$. Over $n$ tosses it wins one unit unless *every* toss is tails — probability $2^{-n}$.

> **The Doubling Paradox, Resolved.** For every $\varepsilon > 0$ there is a horizon at which the doubling system wins with probability greater than $1-\varepsilon$, and its expected net gain is nevertheless exactly $0$.

The books balance because the catastrophe costs $2^n - 1$:
$$(1-2^{-n})\cdot 1 + 2^{-n}\cdot\big(-(2^n-1)\big) = 0 .$$
The improbable loss is exactly as large as the probable gain is likely. **A high win rate is not an edge** — any strategy winning small amounts almost always is paying with a rare disaster of precisely compensating size. That is a theorem, not a caution.

---

## What to take away

1. **Uncertainty priced honestly is worth zero.** The expected payoff is $d$, the number of cards you actually know; correlations, cleverness and block size are irrelevant.
2. **Honest pricing is unique.** The $(u-1):1$ quote is the *only* one making the unresolved block edge-free.
3. **The apparent edge of uncertainty is a scoring artefact of size exactly one.** Count hits without charging for misses and you see a spurious $+1$, forever.
4. **Strategy controls risk, not return.** The variance is the fraction $D(g)/(u(u-1))$ of slot pairs given distinct calls, while the mean never budges.
5. **Information changes the price, not the edge.** Feedback is worth $H_u - 1 \approx \log u$ against a stale book and nothing against a live one — and no adaptive system converts a fair sequence of bets into a favourable one.

Next time someone shows you a strategy that wins ninety-nine times in a hundred, or an algorithm that beats chance on every dataset they tried, the question is not whether they are lying — usually they are not. The question is which of the three it is: stale odds, low variance mistaken for high return, or information someone else forgot to price. There is no fourth option. That is the theorem.

---

## An open ladder

One thread is visibly unfinished. The two counting identities above are plainly the first two rungs of a ladder: the number of arrangements pinned on a $j$-element set of slots should be $u!/(u)_j$ with $(u)_j = u(u-1)\cdots(u-j+1)$. Climbing it should yield every moment of the score:

> **Conjecture.** For an injective strategy on a block of $u$ cards and every $k \le u$, the $k$-th moment of the number of hits is exactly the Bell number $B_k$, the number of partitions of a $k$-element set.

The mean $B_1 = 1$ and second moment $B_2 = 2$ are exactly the facts proved above. If the pattern holds, a blind injective strategy's score is *exactly* Poisson with parameter $1$ in all moments up to $u$, not merely asymptotically — and for non-injective strategies the moments drop, governed entirely by the set-partition statistics of the repeated calls, just as the variance is governed by the collision profile.
