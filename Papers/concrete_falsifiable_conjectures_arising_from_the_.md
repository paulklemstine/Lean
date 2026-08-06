# Adding an Antichain

### A guided tour of how forbidden cubes make room for more sets

---

## 1. The question, in one picture

Take an $n$-element ground set — say $[n] = \{1,\dots,n\}$ — and look at all $2^n$ of its subsets, ordered by inclusion. This is the **Boolean lattice** $2^{[n]}$, the combinatorial shape of the $n$-dimensional cube.

Now ban a pattern and ask how many subsets you can still collect.

The oldest instance is [Sperner's theorem](https://en.wikipedia.org/wiki/Sperner%27s_theorem) (1928): ban a single strict containment $A \subsetneq B$ and you are left with at most $\binom{n}{\lfloor n/2\rfloor}$ sets — the size of the middle layer, and no more.

The modern version bans an arbitrary pattern $P$ and writes

$$\mathrm{La}(n,P) \;=\; \max\{\,|\mathcal F| \;:\; \mathcal F \subseteq 2^{[n]} \text{ contains no copy of } P \,\}.$$

The patterns that fight back hardest are the small cubes themselves. Write $B_d$ for the lattice of all subsets of a $d$-element set — $2^d$ elements, so $B_1$ is a containment, $B_2$ the *diamond*, $B_3$ an eight-element cube.

<details>
<summary><b>What exactly is a "copy" of $B_d$? (two versions, and why both matter)</b></summary>

A **weak copy** of $B_d$ in a family $\mathcal F$ is an injective map $\iota$ from the $2^d$ elements of $B_d$ to members of $\mathcal F$ such that

$$X \subsetneq Y \text{ in } B_d \quad\Longrightarrow\quad \iota(X) \subsetneq \iota(Y).$$

A **strong copy** demands the converse too:

$$X \subsetneq Y \text{ in } B_d \quad\Longleftrightarrow\quad \iota(X) \subsetneq \iota(Y),$$

so unrelated elements of the pattern must receive unrelated sets. Every strong copy is a weak copy, so avoiding *all* weak copies is the harder demand, and consequently

$$\mathrm{La}(n,B_d) \;\le\; \mathrm{La}^*(n,B_d),$$

where the starred quantity is the extremal number for strong copies. Whether the inequality is ever strict is still open — see the Future Directions.
</details>

The easy construction is always the same, and it is the benchmark everything is measured against: **take $d$ consecutive layers of the cube.** A chain $A_1 \subsetneq A_2 \subsetneq \cdots$ inside such a family cannot have more than $d$ links, because chain members have strictly increasing sizes and only $d$ sizes are on offer; and a copy of $B_d$ needs a chain of $d+1$ sets. Taking the $d$ *central* layers gives

$$\mathrm{La}(n,B_d) \;\ge\; \binom{n}{k} + \cdots + \binom{n}{k+d-1} \;\approx\; d\binom{n}{\lfloor n/2\rfloor}.$$

For $d=1$ this is exactly right. For $d=2$ — the notorious [diamond problem](https://en.wikipedia.org/wiki/Forbidden_subposet_problem) — nobody knows. For $d=3$ it is known to be beatable, but only by a whisker.

---

## 2. The one move that runs the whole subject

Everything below follows from a single sentence:

> **Adding an antichain raises the forbidden dimension by at most one.**

An **antichain** is a family of pairwise non-nested sets — Sperner's objects. Formally:

> **Antichain Union Theorem.** If $\mathcal F$ contains no copy of $B_d$ and $\mathcal L$ is an antichain, then $\mathcal F \cup \mathcal L$ contains no copy of $B_{d+1}$. The same holds verbatim for strong copies.

Why should that be? Suppose $\mathcal F \cup \mathcal L$ *did* contain a copy of $B_{d+1}$. To reach a contradiction we must find a sub-lattice of $B_{d+1}$ isomorphic to $B_d$ whose image dodges $\mathcal L$ entirely. The obvious candidates — "the bottom half" and "the top half" of $B_{d+1}$ — might both be unlucky. The point of the next section is that there are far more candidates than two.

---

## 3. Weaving between two faces

Picture $B_{d+1}$ as two parallel copies of $B_d$: the **bottom face** (subsets avoiding the last atom) and the **top face** (subsets containing it). To build a copy of $B_d$ you may choose, independently for each element $X$, its bottom avatar or its top avatar — *provided the choice is monotone*: once you go up, you never come back down.

That monotonicity condition says exactly that the set $U$ of elements sent upward is an **up-set** ($X \in U$ and $X \subseteq Y$ imply $Y \in U$), and it is exactly what makes the resulting map

$$\lambda_U(X) = \begin{cases}X \cup \{\text{last atom}\}, & X \in U,\\ X, & X \notin U\end{cases}$$

an *order embedding*: $X \subseteq Y$ **if and only if** $\lambda_U(X) \subseteq \lambda_U(Y)$.

So the available copies of $B_d$ inside $B_{d+1}$ are indexed by the up-sets of $B_d$ — there are [Dedekind-many](https://en.wikipedia.org/wiki/Dedekind_number) of them ($3, 6, 20, 168, 7581, \dots$ for $d = 1,2,3,4,5$), wildly more than two. And that is enough room to dodge anything flat:

> **Lifting Lemma.** For every antichain $A \subseteq B_{d+1}$ there is an order embedding of $B_d$ into $B_{d+1}$ whose image misses $A$ entirely — namely $\lambda_U$ for $U = \{Y : \text{some } Z \subseteq Y \text{ has its bottom avatar in } A\}$.

**Play with it.** Click nodes to place obstacles; the widget keeps them an antichain automatically, computes the canonical up-set, and draws the surviving copy of $B_d$ in green. Try the middle layer — the largest antichain there is — and try to trap the lemma. You cannot.

{{interactive_demo:0}}

<details>
<summary><b>Click to reveal the two-case proof</b></summary>

Take $U = \{Y \in B_d : \exists Z \subseteq Y \text{ with } \widehat Z \in A\}$, where $\widehat Z$ denotes the bottom-face avatar of $Z$. This is an up-set: a witness $Z$ for $Y$ is a witness for every superset of $Y$. By the discussion above, $\lambda_U$ is an order embedding. Now fix $X \in B_d$.

* **If $X \notin U$**, then $\lambda_U(X) = \widehat X$. Were $\widehat X \in A$, the witness $Z = X$ would put $X$ into $U$ — contradiction. So $\lambda_U(X) \notin A$.
* **If $X \in U$**, pick $Z \subseteq X$ with $\widehat Z \in A$. Then $\widehat Z \subsetneq \widehat X \cup \{\text{last atom}\} = \lambda_U(X)$, strictly, since $\widehat Z$ omits the last atom. If $\lambda_U(X)$ were also in $A$, then $A$ would contain two distinct comparable sets — impossible for an antichain. $\blacksquare$

Composing this dodging embedding with the hypothetical copy of $B_{d+1}$ yields a copy of $B_d$ living entirely in $\mathcal F$, which proves the Antichain Union Theorem.
</details>

Here is the same picture as a static diagram you can read at leisure — the copy stays low until an obstacle appears beneath it, then rises and stays risen:

{{visualization:0}}

And here is the algorithm behind the widget, with a subset-sum transform that computes the up-set in $O(2^d d)$ instead of the naive $O(4^d)$:

{{algorithm:0}}

<details>
<summary><b>How much slack is there? (an experiment)</b></summary>

The lemma promises *at least one* escape route. Enumerating all up-sets and all antichains shows that the promise is exactly tight: for $d = 1, 2, 3$ there are antichains dodged by precisely **one** of the $3$, $6$, $20$ available lifts. The canonical up-set is always among the survivors.

{{demo:1}}
</details>

---

## 4. Consequence I: height is all you need

Peel the maximal sets off a family. They form an antichain, and what remains is one level shorter. Iterate, apply the Antichain Union Theorem at each step, and you get a criterion that has nothing to do with layers:

> **Height Criterion.** A family with no chain of $d+1$ sets contains no copy of $B_d$ — nor any strong copy.
>
> **Few-Sizes Criterion.** A family whose members realise at most $d$ distinct cardinalities contains no copy of $B_d$. It need not contain *all* sets of those sizes, the sizes need not be consecutive, and no symmetry is required.

There is a converse, and the two together bracket the notion exactly:

> **Height Sandwich.** Height $\le d$ forces $B_d$-freeness; $B_d$-freeness forces height $\le 2^d - 1$. Both thresholds are attained.

<details>
<summary><b>Why the upper bound, and why both thresholds are sharp</b></summary>

*Upper bound.* A chain of $2^d$ sets already contains a copy of $B_d$: list the elements of $B_d$ along any linear extension of its order and match them, in order, with the links of the chain. Containment in the pattern implies earlier position, hence containment of images.

*Sharpness below.* The lattice $B_d$ itself, sitting inside the ground set, has height exactly $d+1$ and obviously contains a copy of $B_d$. So "height $\le d$" cannot be weakened to "height $\le d+1$".

*Sharpness above.* A chain of $2^d - 1$ sets is $B_d$-free for the silliest possible reason: a copy needs $2^d$ distinct sets and there are not enough. So "height $\le 2^d-1$" cannot be strengthened.
</details>

The upper end of the sandwich is what gives the standard general bound. Split the cube into $\binom{n}{\lfloor n/2\rfloor}$ symmetric chains; a $B_d$-free family meets each in at most $2^d - 1$ sets. Hence

$$\mathrm{La}(n,B_d) \;\le\; (2^d-1)\binom{n}{\lfloor n/2\rfloor},$$

so for $d = 3$ the truth is trapped between roughly $3$ and $7$ central binomial coefficients — a gap nobody has closed.

Detecting copies by hand is unpleasant; here is the backtracking search used for all the exhaustive checks on this page, with the height criterion wired in as a free shortcut:

{{algorithm:1}}

---

## 5. Consequence II: the extremal numbers really do grow

Now the payoff. Is banning a bigger cube genuinely a weaker constraint — for *every* ground set, not just asymptotically?

> **Strict Monotonicity Theorem.** For all $n$ and $d$,
> $$\mathrm{La}(n,B_d) < \mathrm{La}(n,B_{d+1}) \iff d \le n,$$
> and identically for the strong extremal numbers. For $d > n$ both sides equal $2^n$, because the whole cube has height $n+1 \le d$ and is therefore already $B_d$-free.

The proof is three lines. Let $\mathcal F$ be a largest $B_d$-free family. If $d \le n$ it cannot be everything, since the full power set contains a copy of $B_d$; pick a missing set $A$. A single set is an antichain. So $\mathcal F \cup \{A\}$ is $B_{d+1}$-free and one bigger. Done.

But a single set is a wasteful antichain. Be greedy instead:

> **Pigeonhole Gain Theorem.** For all $n$ and $d$,
> $$2^n + n\,\mathrm{La}(n,B_d) \;\le\; (n+1)\,\mathrm{La}(n,B_{d+1}), \qquad\text{i.e.}\qquad \mathrm{La}(n,B_{d+1}) - \mathrm{La}(n,B_d) \;\ge\; \frac{2^n - \mathrm{La}(n,B_d)}{n+1}.$$

<details>
<summary><b>Click to reveal the proof (it is pure pigeonhole)</b></summary>

Let $\mathcal F$ be extremal $B_d$-free and look at its complement, of size $2^n - |\mathcal F|$. Sort the complement by cardinality into $n+1$ classes. Every class is an antichain — equal sizes are incomparable — so by pigeonhole one class $\mathcal L$ has at least $(2^n - |\mathcal F|)/(n+1)$ members, and it is disjoint from $\mathcal F$ by construction. The Antichain Union Theorem makes $\mathcal F \cup \mathcal L$ a $B_{d+1}$-free family of size $|\mathcal F| + |\mathcal L|$. Rearranging gives the displayed inequality. $\blacksquare$

A free by-product with no construction at all: $\mathrm{La}(n,B_{d+1}) \ge 2^n/(n+1)$ for every $d \ge 0$.
</details>

That greedy move is an algorithm, and a cheap one — $O(2^n)$, with no pattern search anywhere. Run it on the three central layers of an eight-element ground set and it hands back exactly the four central layers:

{{algorithm:2}}

**Explore the numbers.** Move $n$ and $d$ and watch the sandwich: the layer construction creeping up towards $d$ from below, the chain bound sitting at $2^d - 1$, and the construction-free floor $2^n/(n+1)$ sliding down like $1/\sqrt n$ — which is precisely why the pigeonhole gain, unconditional as it is, cannot yet deliver a full central binomial coefficient.

{{interactive_demo:1}}

{{visualization:1}}

---

## 6. Ground truth: exhaustive small cases

Theory is cheap; here is brute force. Enumerating all $2^{2^n}$ families for $n \le 3$ gives the exact values

| $n$ | $\mathrm{La}(n,B_1)$ | $\mathrm{La}(n,B_2)$ | $\mathrm{La}(n,B_3)$ | $\mathrm{La}(n,B_4)$ | $2^n$ |
|---|---|---|---|---|---|
| $1$ | $1$ | $2$ | $2$ | $2$ | $2$ |
| $2$ | $2$ | $3$ | $4$ | $4$ | $4$ |
| $3$ | $3$ | $6$ | $7$ | $8$ | $8$ |

and the strong extremal numbers agree in every cell. Read across row $n=3$: growth is strict through $d = 3$ and stops at $2^3$ thereafter — exactly the criterion $d \le n$. Read the boundary: $\mathrm{La}(d+1,B_d) = 2^{d+1}-2$ (so $\mathrm{La}(3,B_2) = 6$) and $\mathrm{La}(d,B_d) = 2^d - 1$ (so $\mathrm{La}(3,B_3) = 7$).

The script below reproduces all of it from scratch, and in addition checks the Lifting Lemma against every antichain of the $2$-, $3$- and $4$-atom cubes and the Antichain Union Theorem against every pair of a free family and an antichain on a three-element ground set.

{{demo:0}}

---

## 7. Where the frontier is

The antichain move explains the benchmark — applied greedily from nothing, it *builds* the central layers — but it cannot beat it. Meanwhile two rigidity facts say that beating it requires genuine asymmetry: a family determined by a set of allowed sizes never exceeds the central $d$-layer value, and neither does any family invariant under permutations of the ground set. So the known families of size $(3+\varepsilon)\binom{n}{\lfloor n/2\rfloor}$ for the three-atom cube must break the symmetry of the cube in an essential way.

Three questions worth carrying away:

1. **Subadditivity.** If $\mathcal F$ avoids $B_d$ and $\mathcal G$ avoids $B_e$, does $\mathcal F \cup \mathcal G$ avoid $B_{d+e}$? The case $e = 1$ is the Antichain Union Theorem; exhaustive search on small cubes finds no counterexample. A proof would turn one move into a full calculus of forbidden dimension.
2. **A full binomial coefficient of gain.** Is $\mathrm{La}(n,B_{d+1}) - \mathrm{La}(n,B_d) \ge \binom{n}{\lfloor n/2\rfloor}$? True for the level-restricted problem; the pigeonhole bound is short by a factor $\Theta(\sqrt n)$.
3. **How big is $\mathrm{La}(n,B_3)$ really?** Somewhere in $[3+\varepsilon,\,7]$ central binomial coefficients. Narrowing that interval is the open problem the whole apparatus is built for.

> **The image to remember.** A cube is two parallel faces. To find a smaller cube inside a bigger one while dodging obstacles, you need not commit to one face; you can weave between them, rising wherever you must, so long as you never descend. Monotone weaving preserves the shape — and there are enough monotone weavings to dodge anything flat.
