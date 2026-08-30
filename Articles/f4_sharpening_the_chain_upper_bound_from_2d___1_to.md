# How Big Can a Family of Sets Be If It Refuses to Contain a Cube?

## A parlour game with subsets

Take a set of $n$ labelled objects — call it $[n] = \{1, 2, \dots, n\}$ — and consider all $2^n$ of its subsets. Order them by inclusion. What you get is one of the most studied objects in combinatorics: the **Boolean lattice** $2^{[n]}$, a vast diamond-shaped city of sets where $\emptyset$ sits at the bottom, $[n]$ at the top, and everything else is stacked in $n+1$ horizontal *levels*, level $k$ being the $\binom{n}{k}$ subsets of size $k$.

Now play the following game. You want to choose as many subsets as you can — a *family* $\mathcal{F}$ — subject to a single prohibition: your family must not contain a certain forbidden pattern. The pattern we forbid here is a **$d$-dimensional cube**: $2^d$ sets in your family, arranged so that they mimic the inclusion pattern of all subsets of a $d$-element set. For $d = 1$ that is just a pair $A \subsetneq B$; for $d = 2$ it is a *diamond*: sets $A \subseteq B, C \subseteq D$ with $B$ and $C$ incomparable; for $d = 3$ it is a genuine cube with eight corners.

Write $\mathrm{La}(n, B_d)$ for the largest possible size of such a family. How does it grow?

The answer is dominated by one number: the size of the largest level, the **central binomial coefficient**
$$\binom{n}{\lfloor n/2 \rfloor}.$$
By Stirling's formula this is about $2^n \sqrt{2/(\pi n)}$ — a $\Theta(1/\sqrt n)$ fraction of everything. The middle level is, in a precise sense, the natural currency of the whole problem, and the real question is:

> **How many middle levels' worth of sets can a cube-free family afford?**

## The classical answer, and why it is embarrassing

Here is the standard argument, and it is genuinely lovely.

**Step 1: long chains are cubes in disguise.** Suppose your family contains a *chain* of $2^d$ sets,
$$A_0 \subsetneq A_1 \subsetneq \cdots \subsetneq A_{2^d - 1}.$$
Then it already contains a copy of the $d$-cube. Why? Because the Boolean lattice $2^{[d]}$ has exactly $2^d$ elements, and every finite partial order admits a *linear extension*: a way of listing its elements $S_0, S_1, \dots, S_{2^d-1}$ so that whenever $S \subseteq T$, the set $S$ appears no later than $T$. Now match the $i$-th element of the list to the $i$-th set of the chain. Distinct subsets of $[d]$ go to distinct sets of the chain (injectivity), and if $S \subseteq T$ then $S$ comes earlier in the list, so its image sits lower in the chain and is therefore contained in the image of $T$. A chain is a cube that has been flattened, and flattening never destroys a containment.

**Step 2: chain-free families are small.** For this we use the celebrated LYM inequality — after Lubell, Yamamoto and Meshalkin. Assign to each set $A$ the weight $1/\binom{n}{|A|}$, which is exactly the probability that a uniformly random *maximal* chain $\emptyset \subset \cdots \subset [n]$ passes through $A$. The total weight of a family,
$$\lambda(\mathcal{F}) = \sum_{A \in \mathcal{F}} \frac{1}{\binom{n}{|A|}},$$
is called its **Lubell mass**. LYM says: if $\mathcal{F}$ is an *antichain* — no two of its members nested — then $\lambda(\mathcal{F}) \le 1$, because a random maximal chain can meet an antichain at most once.

Now peel. Let $\mathcal{F}$ contain no chain of $k+1$ sets. The **maximal** members of $\mathcal{F}$ (those with nothing strictly above them inside $\mathcal{F}$) form an antichain, so they carry Lubell mass at most $1$. Delete them; every chain in what remains is one shorter than a chain in $\mathcal{F}$, so the leftovers contain no chain of $k$ sets. Induction gives
$$\lambda(\mathcal{F}) \le k.$$
This layered peeling is Mirsky's theorem meeting LYM, and it is strictly stronger than any statement about cardinality, because every single term of the Lubell mass is at least $1/\binom{n}{\lfloor n/2\rfloor}$, whence
$$|\mathcal{F}| \le k \binom{n}{\lfloor n /2 \rfloor}.$$

**Putting them together.** A cube-free family contains no chain of $2^d$ sets, hence no chain of $(2^d - 1) + 1$ sets, hence
$$\mathrm{La}(n, B_d) \;\le\; (2^d - 1)\binom{n}{\lfloor n/2\rfloor}.$$

That is the **chain bound**, and it is where the embarrassment starts. The bound is *exponential in $d$*. But every construction anybody has ever found is *linear in $d$*: take $d$ consecutive levels of the Boolean lattice, say all sets of size $a, a+1, \dots, a+d-1$. Such a family cannot contain a $d$-cube, because inside a cube you can always find a strictly increasing chain of $d+1$ sets (walk from the bottom corner to the top one coordinate at a time), and $d+1$ nested sets have $d+1$ distinct sizes, which will not fit into $d$ levels. So
$$\mathrm{La}(n, B_d) \;\ge\; \binom{n}{a} + \binom{n}{a+1} + \cdots + \binom{n}{a+d-1},$$
and choosing the levels around the middle makes this roughly $d \binom{n}{\lfloor n/2 \rfloor}$.

Linear from below, exponential from above. For $d = 3$: at least about $3$ central binomials, at most $7$. Which is the truth?

## The conjecture

> **Conjecture.** There is an absolute constant $c$, independent of both $n$ and $d$, such that
> $$\mathrm{La}(n, B_d) \le (d + c) \binom{n}{\lfloor n/2 \rfloor}.$$
> Concretely for $d = 3$: $\mathrm{La}(n, B_3) \le 4\binom{n}{\lfloor n/2 \rfloor}$ for every $n$.

This is not idle optimism. The case $d = 2$ — the notorious *diamond problem* — has resisted decades of attack, with the truth widely believed to be $2.25$ central binomials while the best general upper bounds hover above $2.2$. The chain bound gives $3$ there. In every case where an exact answer is known, the truth is on the *level-construction* side, not the chain-bound side.

## What is now proved

Several pieces of the conjecture are now nailed down, and — just as importantly — we can say precisely *why* the classical argument cannot be pushed further.

**The case $d = 1$ is exactly Sperner's theorem.** A family is $B_1$-free precisely when it is an antichain, and the maximum antichain is a single middle level:
$$\mathrm{La}(n, B_1) = \binom{n}{\lfloor n/2 \rfloor}.$$
So the conjecture is true with $c = 0$ at $d = 1$, and it is tight.

**The conjecture is true, with $c = 0$, for every family built out of complete levels.** Call $\mathcal{F}$ a *level union* if membership depends only on cardinality: whenever $|A| = |B|$ and $A \in \mathcal{F}$, also $B \in \mathcal{F}$. The key new fact is a converse to the levels construction:

> **Complete Levels Theorem.** Fix $d \le n$ and any $d+1$ sizes $i_0 < i_1 < \cdots < i_d \le n$. If a family contains *every* subset of $[n]$ whose size is one of these, then it contains a copy of the $d$-cube.

The construction is pretty. Reserve the $d$ largest points of $[n]$ as *markers* $m_1, \dots, m_d$, and let $L_j$ be the block of the $j$ smallest points. To a subset $S \subseteq [d]$ associate
$$f(S) = L_{\,i_{|S|} - |S|} \;\cup\; \{\, m_t : t \in S \,\}.$$
Its size is exactly $i_{|S|}$, so it lies in the family. If $S \subseteq T$ then $|S| \le |T|$, and since the $i_j$ increase strictly, $i_{|S|} - |S| \le i_{|T|} - |T|$: the low block grows and the marker set grows, so $f(S) \subseteq f(T)$. And $f$ is injective because the markers read off $S$ exactly. A cube built from a staircase of blocks and a set of flags.

Consequently a $B_d$-free level union can occupy at most $d$ levels, so
$$|\mathcal{F}| \le d \binom{n}{\lfloor n/2 \rfloor}.$$
For $d = 3$ this delivers $3$, comfortably below the conjectured $4$. Whatever a counterexample to the conjecture looks like, it must be a family that is *not* symmetric under permutations of the ground set.

**The conjecture holds for small ground sets.** Two independent regimes. First, no chain in $2^{[n]}$ has more than $n+1$ sets, so *every* family — cube-free or not — satisfies $|\mathcal{F}| \le (n+1)\binom{n}{\lfloor n/2\rfloor}$. Hence the conjectured bound $(d+1)\binom{n}{\lfloor n/2 \rfloor}$ is unconditionally true whenever $n \le d$. Second, for $d = 3$ one just checks that the *entire* power set is small enough: $2^n \le 4\binom{n}{\lfloor n/2\rfloor}$ for all $n \le 8$ (at $n = 8$ this reads $256 \le 280$), so
$$\mathrm{La}(n, B_3) \le 4 \binom{n}{\lfloor n/2 \rfloor} \quad \text{for all } n \le 8.$$
The inequality fails at $n = 9$ ($512 > 504$), which is exactly where the real difficulty begins.

**A genuine sharpening of the chain bound.** The chain bound throws away information: it charges every set in the family the *cheapest possible* weight $1/\binom{n}{\lfloor n/2 \rfloor}$, as though the whole family lived in the middle level. But the middle level only holds $\binom{n}{\lfloor n/2 \rfloor}$ sets; everything else is strictly more expensive. Splitting the Lubell mass accordingly gives, on an even ground set $n = 2m$,
$$(m+1)\,\mathrm{La}(2m, B_d) \;\le\; \bigl((2^d - 1) m + 1\bigr) \binom{2m}{m},$$
that is, $\mathrm{La}(2m, B_d) \le \left(2^d - 1 - \frac{2^d - 2}{m+1}\right)\binom{2m}{m}$, which is strictly better than the chain bound for every $d \ge 2$. On an odd ground set $n = 2m+1$ the two middle levels tie for largest, and the same split yields
$$(m+2)\,\mathrm{La}(2m+1, B_d) \;\le\; \bigl((2^d-1)m + 4\bigr)\binom{2m+1}{m}.$$
The proof is a one-line accounting argument once the Lubell mass is in hand: a set off the middle level of $2^{[2m]}$ has $\binom{2m}{|A|} \le \binom{2m}{m-1} = \frac{m}{m+1}\binom{2m}{m}$, so it costs a factor $\frac{m+1}{m}$ more Lubell mass than a middle set; the family can therefore afford at most $\binom{2m}{m}$ cheap sets and must pay the premium on all the rest.

For $d = 3$ this pins the truth into a corridor:
$$(3m+1)\binom{2m}{m} \;\le\; (m+1)\,\mathrm{La}(2m, B_3) \;\le\; (7m+1)\binom{2m}{m}.$$
Divide by $(m+1)\binom{2m}{m}$: the answer, measured in central binomials, lies between $3 - \frac{2}{m+1}$ and $7 - \frac{6}{m+1}$. The conjecture says the truth is at most $4$.

## Why the classical method is stuck — and what should replace it

Here is the structural obstruction, and it is worth stating plainly, because it explains why "just be cleverer with chains" is doomed.

**A chain of $2^d - 1$ sets is itself $B_d$-free.** So any argument whose only input is "the family has no long chain" cannot possibly prove a bound better than $(2^d-1)\binom{n}{\lfloor n/2 \rfloor}$. Layer-by-layer refinements of the Lubell mass, of the sort described above, buy only $O(1/n)$. To break the exponential barrier one must forbid something more than length: one must forbid **branching**.

And a cube *is* branching. Here is the criterion that makes this precise.

> **Doubling Criterion.** Suppose a family contains two copies of the $d$-cube, given by maps $f$ and $g$ from the subsets of $[d]$, such that (i) $f(S) \subseteq g(S)$ for every $S$, and (ii) no value of $f$ equals any value of $g$. Then the family contains a copy of the $(d+1)$-cube.

The proof is the obvious one, and that is the point: given $U \subseteq [d+1]$, write $U' = U \cap [d]$ and set
$$h(U) = \begin{cases} g(U') & \text{if } d+1 \in U, \\ f(U') & \text{otherwise.}\end{cases}$$
Monotonicity in the "new" coordinate is exactly hypothesis (i), injectivity across the two halves is exactly hypothesis (ii). Two parallel cubes, stacked, make a cube one dimension higher.

Specialising $f$ and $g$ to chains gives the striking statement: **two pointwise-nested, disjoint chains of $2^d$ sets already contain a copy of the $(d+1)$-cube.** Compare with what the chain bound uses: a single chain of $2^{d+1}$ sets. The parallel-chain configuration is strictly weaker, i.e. strictly easier to find. A $B_{d+1}$-free family is therefore forbidden much more than the chain bound ever exploits — it must avoid every pair of parallel chains of length $2^d$, not merely every single chain of length $2^{d+1}$.

This suggests the shape of the eventual proof. Instead of a bound that doubles with $d$, one wants a **recursion**:
$$\mathrm{La}(n, B_{d+1}) \le \mathrm{La}(n, B_d) + c_0 \binom{n}{\lfloor n/2 \rfloor}$$
for an absolute constant $c_0$. Iterating a recursion of that shape gives exactly the linear bound the conjecture demands: $\mathrm{La}(n, B_d) \le (c_0 d + O(1))\binom{n}{\lfloor n/2 \rfloor}$. The doubling criterion says the ingredients for such a step are present; what is missing is the averaging argument that converts "no two parallel chains" into a quantitative deficit in the Lubell mass.

For $d = 3$ specifically, the concrete target is:
$$\text{every } B_3\text{-free family satisfies } \sum_{A \in \mathcal{F}} \frac{1}{\binom{n}{|A|}} \le 6 + o(1),$$
a first improvement on $7$ obtained purely from the branching structure, with $4$ the ultimate goal.

## Why care?

Forbidden-subposet problems are the order-theoretic descendants of Turán's theorem, the founding result of extremal graph theory: how large can a structure be if it omits a fixed pattern? Replace "graph omitting a triangle" by "family of sets omitting a diamond" and you land here. The techniques — LYM weights, random maximal chains, level decompositions — are the same ones that underlie set-pair inequalities in extremal combinatorics, the analysis of Boolean functions, and lower bounds in circuit complexity, where the Boolean lattice is the state space of everything.

There is also a pleasing epistemic moral. The chain bound is a proof that works for the wrong reason: it succeeds by converting a two-dimensional obstruction (a cube) into a one-dimensional one (a chain), and the price of that flattening is exponential. The task of the next decade — of which the results above are the first stones — is to find an argument that keeps the cube three-dimensional.

## The scoreboard

| Statement | Status |
|---|---|
| $\mathrm{La}(n, B_d) \le (2^d - 1)\binom{n}{\lfloor n/2\rfloor}$ | proved (chain bound) |
| Lubell mass of a family with no chain of $k+1$ sets is $\le k$ | proved |
| $\mathrm{La}(n, B_1) = \binom{n}{\lfloor n/2\rfloor}$ | proved (Sperner, both directions) |
| $\mathrm{La}(n, B_d) \ge \binom{n}{a} + \cdots + \binom{n}{a+d-1}$ | proved |
| $d+1$ complete levels contain a $d$-cube | proved |
| $\mathrm{La}(n, B_d) \le d \binom{n}{\lfloor n/2\rfloor}$ for level unions | proved ($c = 0$) |
| $(m+1)\mathrm{La}(2m, B_d) \le ((2^d-1)m+1)\binom{2m}{m}$ | proved (sharpening) |
| $(m+2)\mathrm{La}(2m+1, B_d) \le ((2^d-1)m+4)\binom{2m+1}{m}$ | proved (sharpening) |
| $\mathrm{La}(n, B_3) \le 4\binom{n}{\lfloor n/2\rfloor}$ for $n \le 8$ | proved |
| Two parallel chains of $2^d$ sets contain a $(d+1)$-cube | proved |
| $\mathrm{La}(n, B_3) \le 4\binom{n}{\lfloor n/2\rfloor}$ for all $n$ | **open** |
| $\mathrm{La}(n, B_d) \le (d + c)\binom{n}{\lfloor n/2\rfloor}$ | **open** |

The gap between $3$ and $7$, for the humblest interesting case $d = 3$, is where the mathematics now lives. A single construction beating $4\binom{n}{\lfloor n/2\rfloor}$ would refute the conjecture outright; no search in the accessible range has produced one. The likeliest outcome is that the conjecture is true and that proving it requires taking branching seriously.
