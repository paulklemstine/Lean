# Three Layers, and Why You Can't Buy a Fourth

## A counting problem hiding inside a hypercube

Take a set of $n$ objects — call them $1, 2, \dots, n$ — and consider all $2^n$ of its subsets. Order them by inclusion: $\{1,3\}$ sits below $\{1,3,7\}$, and neither is comparable to $\{2,5\}$. The resulting structure is the *Boolean lattice*, the most fundamental partially ordered set in mathematics. Picture it as a diamond-shaped tower of $n+1$ horizontal floors, or **layers**: layer $k$ holds the $\binom{n}{k}$ subsets of size exactly $k$. The floors near the middle are enormously wide — the widest, layer $\lfloor n/2 \rfloor$, holds $\binom{n}{\lfloor n/2\rfloor}$ sets, which is more than $2^n/(n+1)$ of everything there is.

Extremal set theory asks a simple-sounding question about this tower: *how large can a family of subsets be if it avoids a particular shape?* The shape we care about here is the **diamond**.

A $k$-diamond, written $D_k$, is the following pattern: a bottom set $A$, a top set $C$, and $k$ distinct sets $B_1, \dots, B_k$ squeezed strictly in between, so that
$$A \subsetneq B_i \subsetneq C \quad \text{for every } i.$$
A family $\mathcal{F}$ of subsets **weakly contains** $D_k$ if such a configuration exists entirely inside $\mathcal{F}$. The word *weak* means we impose no condition on how the middle sets relate to each other — they may be nested, disjoint, anything. They just have to be $k$ distinct sets strictly between the same two members of the family. If no such configuration exists, $\mathcal{F}$ is **weakly $D_k$-free**.

The question of this article: **how big can a weakly $D_6$-free family be?**

## The obvious construction, and a stubborn constant

There is an obvious guess, and it is very good. Take three consecutive layers:
$$\mathcal{T}_k = \text{layer } k \;\cup\; \text{layer } (k{+}1) \;\cup\; \text{layer }(k{+}2).$$
Why is this diamond-free? Because of a beautifully simple counting fact. If $A \subseteq C$ are two sets, the number of sets strictly between them — the **open interval** $(A,C)$ — is exactly
$$|(A,C)| = 2^{|C|-|A|} - 2,$$
since the sets strictly between $A$ and $C$ correspond precisely to the subsets of the difference $C \setminus A$ other than $\varnothing$ and $C\setminus A$ itself.

Now, if all your sets live in three consecutive layers, then any two comparable members differ in size by at most $2$, so the interval between them contains at most $2^2 - 2 = 2$ sets. Two! You cannot even find three sets in the middle, so the family is weakly $D_3$-free — and being $D_3$-free is stronger than being $D_6$-free, since a $D_6$ contains a $D_3$. Three layers around the middle give you a family of size
$$\binom{n}{k} + \binom{n}{k+1} + \binom{n}{k+2} \;\approx\; 3\binom{n}{\lfloor n/2\rfloor}.$$

So the answer to "how big?" is at least $3$ times the widest layer. The natural question — the one that has driven a great deal of work — is whether that constant $3$ can be beaten. Is there a family of size $c \cdot \binom{n}{\lfloor n/2\rfloor}$ with some fixed rational $c > 3$, for all large $n$?

This article is about a research program aimed at exactly that, and about what it found: a sharp, unexpectedly rigid *no-go* result for the most natural family of constructions, together with a hard ceiling from an entirely different direction that boxes any hypothetical improvement into a narrow corridor $3 < c \le 3.5$.

## The three-layer family is stuck

Before hunting for something bigger, it pays to ask whether three layers can simply be *extended*. The answer is a flat no, and in the strongest possible sense: **the three-layer family is saturated**. Add any single set $X$ from the layer immediately above (size $k+3$), and a weak $D_6$ appears instantly. Here is the whole argument. Choose any $A \subseteq X$ of size $k$. Then $A$ and $X$ both belong to the enlarged family, and the interval between them has height $3$, so it contains exactly $2^3 - 2 = 6$ sets — all of sizes $k+1$ and $k+2$, and therefore all already present in the three-layer family. Six sets strictly between two members: that is precisely a weak $D_6$. The same argument, run upside down, shows that you cannot add a set from the layer below either.

The corollary is stark: **four consecutive full layers are never weakly $D_6$-free** (as soon as $k+3 \le n$). So any construction living in a four-layer window must *delete* sets. And that reframes the whole problem into something very concrete.

## Freeness becomes a deterministic exclusion condition

Here is the pivotal structural insight. Confine your family to four consecutive layers $k, k{+}1, k{+}2, k{+}3$. Then:

> **Interval-Exclusion Criterion.** A family confined to four consecutive layers is weakly $D_6$-free **if and only if** for every pair $A \subseteq C$ of its members with $|C| = |A| + 3$, at least one of the six sets strictly between $A$ and $C$ is *missing* from the family.

The proof is a pleasure. In one direction, if such an interval were entirely present, its six interior sets would form a weak $D_6$ — done. In the other direction, suppose some weak $D_6$ exists: six distinct sets strictly between $A$ and $C$. Those six sets all live in the interval $(A,C)$, which has $2^{|C|-|A|}-2$ elements. Within a four-layer window the height $|C|-|A|$ is at most $3$, so the interval has at most $6$ elements — meaning the height is *exactly* $3$ and the six middle sets are *exactly* the whole interval. So an interval is completely filled, contradicting exclusion.

This is worth dwelling on. It says that the entire combinatorial content of $D_6$-freeness, in a four-layer window, is a **deterministic, local, checkable** condition: no height-$3$ interval with both endpoints kept may have all six of its middle rungs kept. There is nothing probabilistic, nothing asymptotic. The only place randomness could ever enter is in *counting* how many sets a proposed rule keeps.

That observation is the strategic heart of the program: **exclusion is deterministic; only the lower bound on the size is quantitative.** If we could find a deletion rule that satisfies exclusion while deleting very few sets, we would beat $3$.

## The natural rule: colour your sets by a sum

What is the most natural way to delete a thin slice of a layer while keeping strong algebraic control? Give each ground element $i \in \{1,\dots,n\}$ a **label** $v(i)$ taken from a finite abelian group $V$ (think of $V = \mathbb{F}_q^d$, a vector space over a finite field). Then colour each subset $S$ by its **sum label**
$$\sigma(S) = \sum_{i \in S} v(i) \in V.$$
Choose a **keep-set** $U \subseteq V$ of allowed colours, and build the family
$$\mathcal{F} = \text{layer } k \;\cup\; \text{layer }(k{+}1) \;\cup\; \{S \in \text{layer }(k{+}2) : \sigma(S) \in U\} \;\cup\; \text{layer }(k{+}3).$$
Three full layers, plus the $U$-coloured part of a fourth. If $U$ were, say, three quarters of $V$, this would be a family of size roughly $3.75\binom{n}{\lfloor n/2\rfloor}$ — a decisive win.

The magic of the sum label is that it interacts perfectly with the interval structure. If $A$ is a $k$-set with $\sigma(A) = g$ and $C = A \cup \{x,y,z\}$, then the three sets of size $k+2$ inside the interval $(A,C)$ are $A \cup \{x,y\}$, $A\cup\{x,z\}$, $A\cup\{y,z\}$, and their colours are
$$g + v(x) + v(y), \qquad g + v(x) + v(z), \qquad g + v(y) + v(z).$$
The three sets of size $k+1$ inside the interval are always kept (layer $k{+}1$ is full), so exclusion can only fail — or be rescued — at these three colours. Translating the Interval-Exclusion Criterion, the family is weakly $D_6$-free precisely when the labelling satisfies the following purely algebraic condition:

> **Safety.** There exist no shift $g \in V$ and no three distinct points $x,y,z \in \{1,\dots,n\}$ with
> $$g + v(x)+v(y) \in U, \quad g+v(x)+v(z) \in U, \quad g+v(y)+v(z) \in U .$$

(To be precise, freeness *forces* safety whenever the labelling is **sum-rich**: every group element is realised as $\sigma(A)$ for some $k$-set $A$ avoiding any three prescribed points. That is a mild spread condition, and it is exactly the "probabilistic rank estimate" that the whole program hoped to make explicit. Here it enters only as a clean hypothesis.)

So the entire construction now hinges on a question in additive combinatorics: **how large can a keep-set $U$ be, if the labelling is safe?**

## The answer: at most two colours

And here the dream collapses — spectacularly, and for two independent reasons.

**First obstruction: labels must be almost injective.** Suppose three distinct ground points $x, y, z$ carry the *same* label $a$. Pick any $u \in U$ and set $g = u - 2a$. Then all three pair-labels equal $g + a + a = u \in U$. Safety fails. Therefore, as long as the keep-set is nonempty at all, **every label class contains at most two points**. Instantly this forces $|V| \ge n/2$: the labelling group cannot be small. Whatever gain we hope to extract must be split among at least $n/2$ colours, which already smells fatal.

**Second obstruction — the closure obstruction: the keep-set collapses to two elements.** Suppose the labels used, $L = v(\{1,\dots,n\})$, occupy more than two thirds of $V$, i.e. $3|L| > 2|V|$, and suppose $|U| \ge 3$; pick three distinct $u_1, u_2, u_3 \in U$. Set $\alpha = u_1 - u_3$ and $\beta = u_1 - u_2$. A pigeonhole argument does the rest: the three sets $L$, $L - \alpha$, $L - \beta$ each have more than two thirds of $|V|$ elements, so they must share a common element $c$. That means there are ground points $z, x, y$ with
$$v(z) = c, \qquad v(x) = c + \alpha, \qquad v(y) = c + \beta,$$
and these three points are distinct because $\alpha, \beta$ and $\alpha - \beta$ are all nonzero. Now take the shift $g = u_2 + u_3 - u_1 - 2c$. A two-line computation gives
$$g + v(x)+v(y) = u_1, \qquad g + v(x)+v(z) = u_2, \qquad g+v(y)+v(z) = u_3,$$
all three in $U$. Safety fails again. Hence **$|U| \le 2$**.

And these two obstructions reinforce each other. Since every label class has at most two points, $|L| \ge n/2$; so if the labelling group is even modestly small — precisely, if $4|V| < 3n$ — then the labels automatically occupy more than two thirds of $V$, and $|U| \le 2$ follows with no extra hypothesis at all.

## What the gain is worth: $O(1/n)$, not a constant

Two surviving colours. How much is that? If $b$ bounds the number of $(k{+}2)$-sets of any single colour, then the thinned layer contributes at most $2b$ sets, and the whole family has at most
$$3\binom{n}{\lfloor n/2\rfloor} + 2b$$
members. Quantitatively: whenever $K \cdot b \le \binom{n}{\lfloor n/2 \rfloor}$, the family satisfies
$$|\mathcal{F}| \;\le\; \Big(3 + \tfrac{2}{K}\Big)\binom{n}{\lfloor n/2 \rfloor}.$$
Now recall that $|V| \ge n/2$. Under the (numerically extremely accurate) equidistribution of sum labels, $b \approx \binom{n}{k+2}/|V|$, so one may take $K \approx |V| \gtrsim n/2$ and conclude
$$c \;\le\; 3 + O(1/n).$$

**The gain is real, positive, and vanishing.** An abelian sum-labelling does beat three layers — by a handful of sets, an amount that shrinks like $1/n$ relative to the middle layer. No fixed rational $c > 3$ is reachable this way, for any $q$, any dimension, any $n_0$. The conjecture that motivated the program is false *for this mechanism*, and the reason is not a delicate estimate: it is a two-line pigeonhole in the group $V$.

## A ceiling from a completely different direction

Having closed one door, the program pushed a wall in from the other side — using extremal graph theory *inside* the Boolean lattice.

For a $k$-set $A$, define the **link graph** of a family $\mathcal{F}$ at $A$: its vertices are the ground points outside $A$, and $\{x,y\}$ is an edge whenever $A \cup \{x,y\}$ belongs to $\mathcal{F}$. Suppose $\mathcal{F}$ is weakly $D_6$-free and contains layers $k{+}1$ and $k{+}3$ in full. Then:

> **Link graphs are triangle-free.** If $\{x,y\}, \{x,z\}, \{y,z\}$ were all edges at $A$, then with $C = A \cup \{x,y,z\}$ — which is in the family, layer $k{+}3$ being full — the entire height-$3$ interval $(A,C)$ would be present: its three sets of size $k{+}1$ by fullness of that layer, and its three sets of size $k{+}2$ by the assumed triangle. That is a weak $D_6$.

Triangle-free graphs on $m$ vertices have at most $m^2/4$ edges — **Mantel's theorem**, the oldest result in extremal graph theory. So each link graph at a $k$-set has at most $(n-k)^2/4$ edges. Double-count the pairs (bottom $k$-set $A$, interior $(k{+}2)$-set $S$ with $A \subseteq S$): each $S$ has $\binom{k+2}{2}$ such bottoms, and each $A$ contributes at most $(n-k)^2/4$ such $S$'s. Therefore

> **Turán Ceiling.** If a weakly $D_6$-free family $\mathcal{F}$ contains layers $k$, $k{+}1$ and $k{+}3$ in full, then
> $$4\binom{k+2}{2}\,\bigl|\mathcal{F} \cap \text{layer }(k{+}2)\bigr| \;\le\; \binom{n}{k}(n-k)^2 .$$

Plug in the balanced choice $k \approx (n-3)/2$: the right side is about $\tfrac{n^2}{4}\binom{n}{k}$, while $4\binom{k+2}{2} \approx \tfrac{n^2}{2}$. So at most about **half** of the interior layer survives, and the whole four-layer construction is capped near
$$3.5\,\binom{n}{\lfloor n/2\rfloor}.$$

## The corridor

Put the two halves together, and the picture is unusually crisp.

- Three layers give $3$, and that family is *saturated* — nothing can be bolted on.
- Anything inside a four-layer window is a deletion problem governed by an exact, deterministic interval-exclusion condition.
- Any abelian sum-labelling rule for those deletions is capped at $3 + O(1/n)$: **no constant gain**.
- Any four-layer construction keeping three layers whole is capped at roughly $3.5$: **no more than half a layer of gain**.

So if a constant $c > 3$ exists at all in a four-layer window, it lives in the corridor $3 < c \le 3.5$, and it must be produced by a deletion rule that is *not* a sum-labelling into an abelian group — something genuinely nonlinear, or nonabelian, or nonlocal.

## The pattern behind the pattern

One last surprise: none of the above is special to the number six. Everything is the case $m=3$ of a clean hierarchy, driven entirely by the interval-size formula $2^m - 2$.

Consider a window of $m+1$ consecutive layers — that is, families whose members have sizes between $k$ and $k+m$. Then:

- **Automatic freeness.** Such a family is weakly $D_{2^m-1}$-free, always, for free: the largest interval it can host has height $m$, hence only $2^m - 2$ interior sets, one short of the $2^m-1$ needed. For $m=2$ this is exactly the statement that three layers are $D_3$-free.
- **The critical criterion.** At the threshold $j = 2^m - 2$, and for $m \ge 2$, weak $D_j$-freeness is *equivalent* to interval exclusion at height exactly $m$: every height-$m$ interval with both endpoints in the family must miss one of its $2^m - 2$ interior sets. For $m = 3$ this is the $D_6$ criterion above; for $m=2$ it is the classical diamond ($D_2$) criterion.
- **Saturation.** The $m$-layer window is always saturated: adding any set of the next layer up creates a weak $D_{2^m-2}$.

The number $6$ was never a coincidence. It is $2^3 - 2$, the size of a height-$3$ interval, and the entire theory — baseline, saturation, exclusion criterion — is a shadow of that one exponential.

## Why a negative result is good news

It is tempting to read all of this as failure: a conjecture sought a constant $c>3$, and the most natural mechanism turned out to deliver $3 + O(1/n)$. But that is not how extremal combinatorics progresses. The value of the analysis is that it converts a vague search into a map with walls.

The walls are these. The rule must delete from the *interior* layers, since the exterior ones are rigid. It must satisfy a condition that is local, deterministic, and completely explicit. It cannot be linear over an abelian group — pigeonhole kills that in two lines. And whatever it is, it cannot pass $3.5$ inside four layers, because triangle-free graphs are simply not dense enough.

That leaves a well-lit room with a small number of doors. Nonabelian labellings, where the pair-sum symmetry that powered the pigeonhole argument breaks; threshold rules depending on $|S \cap X|$ for a fixed reference set $X$, whose link graphs are complete bipartite and therefore triangle-free by design rather than by accident; and windows of height $m > 3$, where the ratio $(2^m-2)/m$ tilts the trade-off between how many layers you may use and how many sets each interval forces you to delete.

The interval formula $2^m - 2$ was the key to every result here — the baseline, the saturation, the exclusion criterion, the safety condition, and the Mantel bound. It will almost certainly be the key to whatever comes next.
