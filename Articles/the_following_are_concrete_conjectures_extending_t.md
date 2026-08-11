# How Long Can You Live? A Mathematician's Guide to Buying Time

## A game with Death

Here is an old thought experiment dressed in new clothes. You are Mortal. Your opponent is the Reaper. Before the game begins you must hand the Reaper a **schedule**: a list of the moments of your life, laid out in order. Round after round, the Reaper advances one step down your schedule. You survive exactly as long as your schedule has moments left. When it runs out, so do you.

If your schedule is finite — a hundred years of days, say — you die at the end of it, and there is nothing to discuss. So make it infinite: let your moments be $0, 1, 2, 3, \dots$, one for each natural number. Now something strange happens. You survive round $17$, round $10^{100}$, round $n$ for every finite $n$. There is no last moment. And yet the schedule as a whole has a definite *length*, and it is not "infinity" in any vague sense. It has an **order type**, the ordinal $\omega$ — the first infinite ordinal, the length of the sequence of counting numbers.

This is the setup we will study. A **survival game** is nothing more than a set of moments arranged in a well-order: an ordering in which every non-empty collection of moments has a first one, so that there is no infinite regress and the Reaper's march is always well defined. The **survival value** of the game is the order type of that arrangement — the ordinal it is a copy of. We will write $\mathrm{val}(G)$. Mortal *can force survival to round $\alpha$* exactly when $\alpha \le \mathrm{val}(G)$: this is the whole content of the game, and it means the ordinal is not a proxy for the strategic situation, it *is* the strategic situation.

So: how do you buy more time?

## The refinement trick

Here is the move that generates everything that follows. Take your schedule and, between consecutive moments, insert an entire copy of $\omega$. Where you used to have a single moment, you now have a whole endless sequence of finer moments — you have subdivided your life.

Concretely: a **refinement** of a schedule $G$ has as its moments the pairs $(x, n)$ where $x$ is one of the old moments and $n$ is a natural number, ordered so that the old coordinate dominates: $(x,n)$ comes before $(y,m)$ if $x$ came before $y$, and if $x = y$ then according to $n$. This is the lexicographic order — dictionary order, big coordinate first.

What has this bought you? The answer is the **Refinement Law**:

$$\mathrm{val}(\text{refinement of } G) \;=\; \omega \cdot \mathrm{val}(G).$$

Ordinal multiplication, note, with the new factor on the *left*. Read it as "$\mathrm{val}(G)$ copies of $\omega$, laid end to end". So refining the plain $\omega$-schedule gives $\omega \cdot \omega = \omega^2$: instead of a single infinite run of moments, Mortal now has infinitely many infinite runs, one after the other.

Do it again and you get $\omega^3$. Iterating $k$ times:

> **The Hierarchy Theorem.** Refining the natural-number schedule $k$ times produces a survival value of exactly $\omega^{k+1}$. And the hierarchy is *strict*: whenever $j < k$, a Mortal armed with the $j$-times-refined schedule cannot force survival to the round at which the $k$-times-refined Mortal dies.

Strictness is worth pausing on, because it is the reason ordinals are the right currency. There is no sense in which $\omega^3$ is "more moments" than $\omega^2$ — both schedules have exactly countably many moments; you can match them up one-to-one. What distinguishes them is not size, it is **structure**. The $\omega^3$-schedule contains a copy of $\omega^2$ with room to spare; the $\omega^2$-schedule contains no copy of $\omega^3$ at all. Cardinality is blind here. Order type sees everything.

## What a clock can measure

The refined schedules have a beautifully concrete description. The $k$-times-refined single moment is just $\mathbb{N}^k$ — $k$-tuples of natural numbers — in dictionary order. Call this the **$k$-fold clock**. Its readings are exactly the ordinals below $\omega^k$, and the dictionary reads off, digit by digit, the Cantor normal form:

$$(n_1, n_2, \dots, n_k) \;\longmapsto\; \omega^{k-1} n_1 + \omega^{k-2} n_2 + \cdots + \omega\, n_{k-1} + n_k.$$

It is base-$\omega$ positional notation, with $k$ digits. And the sharpest way to say what such a clock can and cannot do is this:

> **The Clock Theorem.** A survival game can be timed by the $k$-fold clock — that is, its moments can be embedded, order-faithfully, into $\mathbb{N}^k$ in dictionary order — if and only if its survival value is at most $\omega^k$.

Both directions matter. The forward direction is a **hard ceiling**: if your life fits inside a $k$-digit base-$\omega$ odometer, you cannot outlive $\omega^k$, no matter how cleverly you play. The converse says the ceiling is exactly attained: any schedule short enough *is* realisable on that odometer. There is no slack, no hidden cleverness, no gap between what the clock permits and what a Mortal can achieve. And in full generality the same statement holds with $\omega^k$ replaced by any ordinal at all: a game embeds in the canonical well-order of $o$ precisely when its value is at most $o$.

## Climbing past all the finite depths

Every finite refinement depth gets you to $\omega^{k+1}$. What if you use them all?

Concatenate. Play the $0$-fold clock, then the $1$-fold clock, then the $2$-fold clock, and so on forever — a schedule whose moments are pairs $\langle k, a\rangle$ with $a$ a reading of the $k$-fold clock, ordered by depth first and reading second. Call this the **limit clock**.

> **The Limit Theorem.** The limit clock has survival value exactly $\omega^\omega$, and this strictly exceeds every finite refinement depth.

The upper bound is the pretty part of the argument, and it is done with a single explicit formula, a **key** that assigns to each moment of the limit clock a specific ordinal:

$$\mathrm{key}\langle k, a\rangle \;=\; \omega^k + (\text{the reading of } a).$$

Three things about this key do all the work at once. It is strictly increasing (a later moment always gets a larger ordinal), which certifies that the tangled dictionary order on a dependent sum of infinitely many different clocks really is a well-order — no infinite descending chains hide inside it. Second, since the reading of $a$ is below $\omega^k$, the key of any depth-$k$ moment is below $\omega^k + \omega^k = \omega^k \cdot 2 < \omega^{k+1} < \omega^\omega$: every key lands strictly below $\omega^\omega$. So the whole limit clock embeds in the ordinals below $\omega^\omega$, and its value is at most $\omega^\omega$. Third, the individual depths sit inside the limit clock, so its value is at least every $\omega^k$, hence at least $\omega^\omega$. The two bounds meet.

This is not a coincidence of the particular clocks chosen. Behind it is a general principle about stringing lives together:

> **The Concatenation Limit Theorem.** Play the lives $A_0, A_1, A_2, \dots$ one after another. If $o$ is *additively principal* — meaning no two ordinals below $o$ add up to $o$ or beyond, which is exactly the ordinals of the form $\omega^a$ — and if every $\mathrm{val}(A_k)$ is below $o$ while the values are cofinal in $o$ (they approach it arbitrarily closely), then the concatenated life has value exactly $o$.

Additive principality is the hypothesis that keeps the bookkeeping honest. As you concatenate, you track *landmarks*: the time at which each successive life begins, namely the sum of all the earlier values. Additive principality is precisely the guarantee that these running totals never escape $o$ — that the family cannot overshoot its own supremum. Drop it and the theorem is false.

## The surprise: more refinement, no more life

Now for the result that ought to change your intuition. Refinement always seemed like free money: subdivide, and get an $\omega$-fold multiplier. Surely, then, refining a nontrivial schedule always strictly increases survival?

No.

> **The Fixed-Point Theorem.** Refining the limit clock buys Mortal nothing at all: $\omega \cdot \omega^\omega = \omega^\omega$. Consequently, it is false in general that refining a game by a clock of length greater than $1$ strictly increases the survival value.

The formal culprit is that ordinal multiplication is not strictly monotone in its *left* factor. The intuitive culprit is more interesting: when your schedule already contains, cofinally, blocks of every finite base-$\omega$ depth, inserting one more layer of subdivision merely reshuffles blocks you already had. Subdividing an already infinitely-subdivided life is a null operation. The $\omega$-fold multiplier is real at every finite depth and evaporates in the limit.

Where exactly does it evaporate? There is a clean answer. Call a survival value **refinement-stable** when a further refinement gains nothing, i.e. when $\omega \cdot o = o$.

> **The Stability Criterion.** Within the scale of pure powers, $\omega^a$ is refinement-stable exactly when $a$ is already infinite, $\omega \le a$. So every finite depth $\omega^{k+1}$ is unstable — refinement genuinely helps there — while the limit $\omega^\omega$ is stable.

The reason is a one-line piece of arithmetic with a lot of content: multiplying by $\omega$ shifts an exponent $a$ to $1 + a$, and $1 + a = a$ holds exactly when $a$ is infinite. Stability is not about being *big*; it is about the exponent already having absorbed a unit on the left.

That last phenomenon, absorption, is worth its own remark, because it is the source of most of the counterintuitive behaviour here. Concatenating lives adds their values, and ordinal addition is not commutative: an extra moment appended *after* an endless life is a genuine gain, $\omega + 1 > \omega$, but the same moment prefixed *before* it is completely invisible, $1 + \omega = \omega$. When you can act matters more than how much you get.

## Value is the whole story

One might worry that the survival value throws information away — that two games could share a value while being strategically different. They cannot.

> **Completeness of the Survival Value.** Every survival game is order-isomorphic to the canonical clock of its own value; hence two games have the same value if and only if their schedules are order-isomorphic. And every ordinal is realised as the value of some game.

So the map "game $\mapsto$ ordinal" is a complete invariant and a surjection: the theory of survival games *is* the theory of ordinals, faithfully and without loss. That is the licence for everything above — every fact about who outlives whom is a fact of ordinal arithmetic, and vice versa.

## Machines that run past infinity

All of this sounds like a fable, but it has a concrete computational face. Imagine a machine with a cell for each moment of the $\omega^2$-clock. It runs not just for finitely many steps but through the transfinite: at each successor time it applies one transition rule, and at each limit time it takes the union of everything that has happened before. Its rule is as simple as can be: **a cell switches on once all strictly earlier cells are on.**

This is the abstract skeleton of an *infinite time* machine, the model in which computations are allowed to continue past the first infinite stage. The question one always asks of such a system is its **closure ordinal**: the first time at which nothing new ever happens again.

> **The Closure Theorem.** For this machine, a cell is on at time $\alpha$ precisely when its own arrival time — its position in the $\omega^2$-clock — is at most $\alpha$. Consequently no stage before $\omega^2$ is terminal, stage $\omega^2$ is terminal, and the closure ordinal is *exactly* $\omega^2$. Moreover the machine is faithful: its well-order of reachable times is order-isomorphic to the moments of the game it realises, so the closure ordinal coincides exactly with that game's survival value.

Two ideas meet here. The abstract question "how long can Mortal survive?" and the concrete question "how long does this machine run before it stalls?" turn out to be the same question, with the same ordinal as the answer. The clock a system carries is the clock it can be run against. That correspondence — the ordinal as simultaneously a length of life, an order type, a positional notation, and a closure ordinal — is the reason ordinals show up everywhere from proof theory (measuring the strength of axiom systems) to program termination (measuring how loops wind down) to descriptive set theory (measuring the complexity of definitions).

## What the game teaches

Strip away the Reaper and the moral is this. When you want to compare infinite processes, counting fails and ordering succeeds. Two schedules of the same countable size can be radically different in their capacity to survive; the difference is entirely a matter of how the moments are arranged. Refinement — subdividing a process into a hierarchy of finer processes — is a genuine and quantifiable gain, worth an exact factor of $\omega$, and can be iterated to climb a strict hierarchy $\omega, \omega^2, \omega^3, \dots$, whose limit is $\omega^\omega$. But refinement's gains have a horizon: at $\omega^\omega$ the operation becomes idempotent, and the exact criterion for that collapse is that the exponent has already gone infinite.

There is even a lesson in it. Buying time by making finer distinctions works — brilliantly, and forever, one level at a time. It stops working the moment your distinctions are already infinitely fine. After that, no amount of subdivision will keep the Reaper waiting; the only way up is to concatenate something genuinely new.
