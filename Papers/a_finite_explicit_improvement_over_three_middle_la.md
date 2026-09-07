# Three Layers, and Why You Can't Buy a Fourth

*A guided tour of weakly $D_6$-free families in the Boolean lattice — from a one-line counting identity to a no-go theorem and a hard ceiling.*

---

## 0 · The question in one paragraph

Take all $2^n$ subsets of $\{1,\dots,n\}$, ordered by inclusion. Stack them into $n+1$ **layers**, layer $k$ holding the $\binom{n}{k}$ sets of size $k$. Now forbid a shape. The **$j$-diamond** $D_j$ is a bottom set $A$, a top set $C$, and $j$ distinct sets squeezed strictly between them. A family that contains no such configuration is called **weakly $D_j$-free**.

Three consecutive layers near the middle form a weakly $D_6$-free family of size about $3\binom{n}{\lfloor n/2\rfloor}$. **Can you do better than $3$?** That is the question this page is about, and by the end you will have discovered the answer with your own hands.

> **The punchline, stated up front.** Inside a four-layer window, diamond-freeness is *exactly* a deterministic local condition — no probability required. The most natural way to satisfy it, colouring sets by an algebraic sum and keeping a few colours, beats three layers by only $3 + O(1/n)$: a vanishing gain. And an argument from extremal graph theory caps every four-layer construction near $3.5$. Any constant $c > 3$, if it exists, is trapped in the corridor $3 < c \le 3.5$ and must come from something non-abelian.

---

## 1 · One identity to rule them all

Everything below flows from a single count. For $A \subseteq C$, the sets strictly between them correspond to the subsets of the difference $C\setminus A$ other than $\varnothing$ and $C\setminus A$ itself. Hence

$$|(A,C)| \;=\; 2^{|C|-|A|} - 2 .$$

Two values matter:

| height $|C|-|A|$ | interior sets | consequence |
|---|---|---|
| $2$ | $2$ | a three-layer family can never host $3$ middle sets → weakly $D_3$-free |
| $3$ | $6$ | a four-layer family hosts exactly $6$ → $D_6$ is a *knife-edge* |

<details>
<summary><strong>Click to reveal the proof of the interval formula</strong></summary>

The maps $B \mapsto B\setminus A$ and $D \mapsto A\cup D$ are mutually inverse bijections between $(A,C)$ and $\{D \subseteq C\setminus A : D \ne \varnothing,\ D \ne C\setminus A\}$. Indeed $A\subsetneq B\subsetneq C$ forces $A\subseteq B\subseteq C$, so $B$ is determined by $B \setminus A \subseteq C\setminus A$; strictness at the bottom says $B\setminus A \ne \varnothing$, strictness at the top says $B \setminus A \ne C\setminus A$. The target set has $2^{|C\setminus A|}-2$ elements. $\blacksquare$

</details>

So a three-layer family is free automatically. To beat $3$ we must use a fourth layer, and then each height-$3$ interval hosts exactly the six middle sets a $D_6$ needs. **Every such interval must lose at least one rung.**

---

## 2 · Break a ladder with your own hands

The next widget is the whole theory in miniature. The left panel draws a height-$3$ interval: bottom $A$, three sets $A+x$, $A+y$, $A+z$, three sets $A+xy$, $A+xz$, $A+yz$, top $C$. Click a green node to delete it.

Then scale up: the right panel builds a real four-layer family, thinned by keeping only those sets of layer $k+2$ whose *sum label* lies in a keep-set $U$, and checks **every** ladder in your browser. Try growing $U$ and watch what happens.

{{interactive_demo:0}}

> **What to notice.** Freeness never depends on anything global. It flips the instant a single ladder becomes complete. And as soon as $|U| \ge 3$, some ladder always completes — no matter which residues you pick. That is not luck; Section 4 explains why.

<details>
<summary><strong>Click to reveal the exact statement you just verified</strong></summary>

**Interval-Exclusion Criterion.** Let every member of $\mathcal{F}$ have size in $[k, k+3]$. Then $\mathcal{F}$ is weakly $D_6$-free **if and only if** for every $A, C \in \mathcal{F}$ with $A \subseteq C$ and $|C| = |A|+3$, at least one $B$ with $A \subsetneq B \subsetneq C$ is missing from $\mathcal{F}$.

*Proof.* If a height-$3$ interval is complete, its six interior sets are a weak $D_6$. Conversely, six distinct middle sets force $6 \le 2^{|C|-|A|}-2$, hence height exactly $3$ within the window, hence the six sets *are* the whole interval — so the interval is complete. $\blacksquare$

The point is the *only if* direction: it means no clever probabilistic construction can beat the best deterministic one, because the constraint is purely local. See the [Boolean lattice](https://en.wikipedia.org/wiki/Boolean_algebra_(structure)) and the general area of [extremal set theory](https://en.wikipedia.org/wiki/Extremal_combinatorics) for background.

</details>

---

## 3 · Why you cannot simply add a fourth layer

Before hunting for a rule, ask whether the baseline can be extended at all. It cannot — in the strongest sense.

- **Saturation.** Add any single set $X$ of size $k+3$ to the three-layer family. Pick $A\subseteq X$ of size $k$. The six sets strictly between $A$ and $X$ all have size $k+1$ or $k+2$, so they are already there. Complete ladder → weak $D_6$. The same works downward.
- **Corollary.** Four consecutive *full* layers are never weakly $D_6$-free. Any four-layer construction must delete.

The picture below makes both the ladder and the driving identity visible at a glance.

{{visualization:0}}

---

## 4 · The natural rule — and the pigeonhole that kills it

The most attractive deletion rule is algebraic. Give each ground point $i$ a label $v(i)$ in a finite abelian group $V$; colour a set $S$ by its **sum label** $\sigma(S) = \sum_{i\in S} v(i)$; keep the sets whose colour lies in a keep-set $U \subseteq V$.

This interacts perfectly with ladders. If $\sigma(A) = g$ and $C = A\cup\{x,y,z\}$, the three upper rungs have colours
$$g + v(x)+v(y), \qquad g+v(x)+v(z), \qquad g+v(y)+v(z).$$
The lower rungs are always kept, so exclusion says precisely:

> **Safety.** There is no shift $g$ and no three distinct $x,y,z$ with all three pair-labels in $U$.

Now play. Choose the group, the labelling and the keep-set, and try to keep three colours alive.

{{interactive_demo:1}}

<details>
<summary><strong>Click to reveal the two theorems the sandbox is illustrating</strong></summary>

**Label multiplicity.** If $(v,U)$ is safe and $U \ne \varnothing$, every label class has at most two points.
*Proof.* If $v(x)=v(y)=v(z)=a$ with $x,y,z$ distinct, pick $u\in U$ and take $g = u-2a$; all three pair-labels equal $u$. $\blacksquare$
*Consequence:* $|V| \ge |v([n])| \ge n/2$. The group is forced to be large.

**The closure obstruction.** If $(v,U)$ is safe and the label set $L = v([n])$ satisfies $3|L| > 2|V|$, then $|U| \le 2$.
*Proof.* Suppose $u_1,u_2,u_3 \in U$ are distinct; set $\alpha = u_1-u_3$, $\beta = u_1-u_2$, both nonzero and distinct. The sets $L$, $L-\alpha$, $L-\beta$ each have more than $\tfrac23|V|$ elements, so
$$|L\cap(L-\alpha)\cap(L-\beta)| \ge 3|L|-2|V| > 0 .$$
Take $c$ in the intersection; there are points $z,x,y$ with $v(z)=c$, $v(x)=c+\alpha$, $v(y)=c+\beta$, pairwise distinct. With $g = u_2+u_3-u_1-2c$ the three pair-labels are exactly $u_1,u_2,u_3 \in U$. $\blacksquare$

**Small groups cannot help.** Combining the two: if $4|V| < 3n$ and $U\ne\varnothing$, then $|U|\le 2$ automatically.

</details>

The certifier behind the sandbox is worth reading on its own: it eliminates the shift $g$ analytically, turning an $O(q n^3)$ search into an $O(|U|^3 q + n)$ one.

{{algorithm:1}}

---

## 5 · So how much *does* the algebra buy?

Two colours out of $|V| \ge n/2$. If $b$ bounds one colour class inside the interior layer, the family has at most $3\binom{n}{\lfloor n/2\rfloor} + 2b$ members, so whenever $Kb \le \binom{n}{\lfloor n/2\rfloor}$,
$$c \;\le\; 3 + \frac{2}{K}.$$
With equidistribution $b \approx \binom{n}{k+2}/|V|$ and $K \approx |V| \ge n/2$ this is $c \le 3 + 4/n$.

**The gain is real, positive, and vanishing.** No fixed rational $c>3$ survives. Run the census yourself — every labelling, every keep-set, all enumerated:

{{demo:1}}

---

## 6 · A wall from the other side: triangle-free links

Now forget labellings. What can *any* four-layer construction do?

For a bottom set $A$, define its **link graph**: vertices are the points outside $A$, and $\{x,y\}$ is an edge when $A\cup\{x,y\}$ is kept. If layers $k+1$ and $k+3$ are full, a triangle $\{x,y\},\{x,z\},\{y,z\}$ completes the ladder above $A$ — so **every link graph is triangle-free**.

[Mantel's theorem](https://en.wikipedia.org/wiki/Tur%C3%A1n%27s_theorem) — a triangle-free graph on $m$ vertices has at most $m^2/4$ edges — plus a double count gives the ceiling
$$4\binom{k+2}{2}\bigl|\mathcal{F}\cap\text{layer}(k{+}2)\bigr| \;\le\; \binom{n}{k}(n-k)^2 ,$$
which at the balanced $k \approx (n-3)/2$ keeps at most **half** the interior layer and caps the constant near $3.5$.

{{algorithm:2}}

Here is the whole landscape in one picture: the baseline climbing to $3$, the abelian ceiling collapsing onto it, and the Turán ceiling rising to $3.5$ — with the corridor between them shaded.

{{visualization:1}}

> **The factor-$n$ gap.** Extremal graph theory *permits* half the interior layer to survive. Abelian algebra *delivers* $2/|V| = O(1/n)$ of it. Closing that gap is the whole game.

---

## 7 · Six was never special

Everything above is the case $m = 3$ of a hierarchy governed by $2^m - 2$.

| window height $m$ | interval size $2^m-2$ | automatic | critical threshold |
|---|---|---|---|
| $2$ | $2$ | weakly $D_3$-free | $D_2$ ⇔ exclusion at height $2$ |
| $3$ | $6$ | weakly $D_7$-free | $D_6$ ⇔ exclusion at height $3$ |
| $4$ | $14$ | weakly $D_{15}$-free | $D_{14}$ ⇔ exclusion at height $4$ |

<details>
<summary><strong>Click to reveal the general statements</strong></summary>

**Automatic freeness.** A family with all sizes in $[k,k+m]$ is weakly $D_{2^m-1}$-free: the tallest interval it can host has $2^m-2 < 2^m-1$ interior sets.

**Critical criterion.** For $m \ge 2$, such a family is weakly $D_{2^m-2}$-free iff every height-$m$ interval with both endpoints kept misses an interior set.

**Saturation.** For $m\ge2$, adding to the $m$-layer window any set of the next layer up creates a weak $D_{2^m-2}$.

For larger $m$ the number of intervals grows much faster than the number of sets, so each deletion breaks more constraints — which is exactly why higher windows are the most promising place to look for a genuine constant gain.

</details>

---

## 8 · Verify everything yourself

The full verification suite reproduces every claim on explicit small instances: the interval formula, the baseline and its cardinality, saturation, the equivalence of freeness with exclusion over hundreds of random thinnings, the collapse of the keep-set, the constant $3 + O(1/n)$, triangle-freeness of link graphs, the Turán ceiling, and the hierarchy for $m = 2,3,4$.

{{demo:0}}

And the exclusion certifier that powers the search — the routine that turns a quadratic diamond hunt into a linear sweep over ladders:

{{algorithm:0}}

---

## 9 · Where to go next

The map now has walls on both sides, and a small number of doors:

1. **Bipartite-link thresholds.** Fix a reference set $X$ and keep a set according to $|S\cap X|$. Keeping only *split* pairs makes every link graph complete bipartite — triangle-free by design, and complete bipartite graphs are exactly Mantel's extremal examples. This is the unique shape that can approach $3.5$.
2. **Nonabelian or nonlinear rules.** The whole collapse rests on the free shift $g$, available because $\sigma$ is a homomorphism and $v(x)+v(y)$ is symmetric. Break either and the pigeonhole loses its grip.
3. **Higher windows.** Take $m \ge 4$, where deletion is cheaper per interval broken.
4. **Sharper Mantel.** Link graphs at nested bottoms are highly correlated; a stability version should push $3.5$ down, perhaps far down.
5. **Two-sided thinning as a covering LP.** Thin two interior layers and the problem becomes: cover all height-$3$ intervals by removed sets at minimum cost. The LP value, exactly computable for small $n$, would settle whether four layers can beat $3$ at all.

**The takeaway.** A single counting identity, $|(A,C)| = 2^{|C|-|A|}-2$, produced the baseline, its rigidity, the exclusion criterion, the safety condition, the pigeonhole collapse, and the Mantel ceiling. Whatever finally settles the corridor $3 < c \le 3.5$ will almost certainly be built on it too.
