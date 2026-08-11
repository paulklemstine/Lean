# Forbidden Shapes in the Cube of Subsets

*How a single counting trick, a fractional knapsack, and a four-element "butterfly" pin down how large a family of sets can be before a forbidden pattern is forced to appear.*

---

## A city of subsets

Take a set of $n$ objects — call it $[n] = \{1, 2, \dots, n\}$ — and imagine every one of its $2^n$ subsets as a point in a vast city. Two points are joined by a road going *uphill* whenever one subset is contained in the other. The empty set sits at the very bottom; the full set $[n]$ sits at the top. Everything else is stacked in $n+1$ horizontal **layers**: layer $i$ consists of the $\binom{n}{i}$ subsets of size exactly $i$. The layers bulge in the middle: the largest one, layer $\lfloor n/2 \rfloor$, contains $\binom{n}{\lfloor n/2\rfloor}$ subsets, more than any other.

This city is the *Boolean lattice*, and one of the oldest games in combinatorics is played inside it. You are allowed to choose a family $\mathcal{F}$ of subsets — a collection of points in the city — but there is a rule: your family must not contain a particular *shape*. How many points can you grab?

The most famous instance of the game is Sperner's theorem from 1928. The forbidden shape is a single uphill road: no member of your family may be contained in another. Sperner's answer is as clean as it is memorable: you can take at most $\binom{n}{\lfloor n/2 \rfloor}$ subsets, and the best you can do is to grab a whole middle layer.

Nearly a century later, the general version of the game — forbid an arbitrary pattern $P$, not just a two-step chain — is still wide open. This article is about a set of results that push it forward: an exact answer for the "no three mutually unrelated sets" problem, a sharpening of the standard upper bound that removes an entire layer of slack, a two-sided bracket valid for *every* forbidden pattern, and a small four-element poset — the butterfly — that reveals exactly why one side of that bracket is doomed to be lossy.

---

## Two kinds of copies, and a gap between them

Before we can forbid a shape, we must say what it means for a family to *contain* one. A shape is a finite partially ordered set $P$ — a collection of abstract elements, some of which are declared to lie below others. A **weak copy** of $P$ in a family $\mathcal{F}$ is an assignment of a distinct set $\iota(p) \in \mathcal{F}$ to each element $p$ of $P$ such that whenever $p$ lies below $q$ in $P$, the set $\iota(p)$ is a *strict subset* of $\iota(q)$. A **strong copy** demands more: the containment must go *both ways*, so that $\iota(p) \subsetneq \iota(q)$ happens **only** when $p$ lies below $q$. A strong copy is an exact, induced replica; a weak copy is a replica that is allowed to have extra containments the pattern never asked for.

Write $\mathrm{La}(n,P)$ for the largest family with no weak copy of $P$, and $\mathrm{La}^*(n,P)$ for the largest family with no strong copy. Since every strong copy is in particular a weak copy, avoiding weak copies is the harder constraint, and always $\mathrm{La}(n,P) \le \mathrm{La}^*(n,P)$.

How different can the two be? Spectacularly different — and the smallest possible pattern already proves it. Let $A_m$ denote the $m$-element **antichain**: $m$ elements, none below any other. A weak copy of $A_m$ has no order requirements at all; it is nothing but a choice of $m$ distinct sets. So a family avoids weak copies of $A_m$ precisely when it has fewer than $m$ members:

> **Theorem (weak antichain freeness is a counting condition).** A family contains no weak copy of the $m$-element antichain if and only if it has fewer than $m$ members. Consequently $\mathrm{La}(n, A_{m+1}) = m$ for every $m \le 2^n$.

Strong copies are an entirely different animal. A strong copy of $A_2$ is a pair of sets neither of which contains the other; so a family avoids strong copies of $A_2$ exactly when it is a **chain** — totally ordered by inclusion. The longest chain in the cube runs from $\emptyset$ up to $[n]$ one element at a time and has $n+1$ members, so $\mathrm{La}^*(n, A_2) = n+1$ while $\mathrm{La}(n,A_2) = 1$. The two invariants differ by exactly $n$: their gap is unbounded, and no inequality of the form $\mathrm{La}^* \le c \cdot \mathrm{La}$ can hold with a constant $c$.

---

## Three sets that see nothing of each other

The case $\mathrm{La}^*(n, A_2) = n+1$ is one-dimensional: avoid *two* mutually unrelated sets and you are stuck on a single ladder. The first genuinely two-dimensional case is $A_3$: **no three pairwise incomparable sets**. Now you may run two ladders in parallel — but not three. How much can you collect?

> **Theorem.** For every $n \ge 1$, the largest family of subsets of an $n$-element set containing no three pairwise incomparable members has exactly $2n$ sets.

Both halves of the proof are short and, pleasingly, neither uses any heavy machinery — no Dilworth theorem, no Greene–Kleitman theory.

**The ceiling.** Any two distinct sets of the *same size* are incomparable, since neither can contain the other. So if a family had three sets of a common size, those three would already form the forbidden configuration. Hence the family meets each layer in at most $2$ sets. But the bottom layer contains only one subset — the empty set — and the top layer only one — the whole ground set $[n]$. So the count is at most
$$1 + \underbrace{2 + 2 + \cdots + 2}_{n-1 \text{ middle layers}} + 1 = 2n .$$

**The floor.** Fix the natural order $1 < 2 < \cdots < n$ on the ground set and let $S_i = \{1, 2, \dots, i\}$ be the $i$-th *initial segment*. The $n+1$ sets $S_0 = \emptyset, S_1, \dots, S_n = [n]$ form a chain. Now take the complements of the *proper nonempty* initial segments: $\overline{S_1}, \overline{S_2}, \dots, \overline{S_{n-1}}$, another chain, this one descending, with $n-1$ members. These two chains are disjoint: every set in the first chain that is nonempty contains the element $1$, whereas no complement $\overline{S_i}$ with $i \ge 1$ does — and the empty set is not a complement of a proper initial segment either. Together they give $ (n+1) + (n-1) = 2n$ sets. Could three of them be pairwise incomparable? No: three sets drawn from two chains must, by the pigeonhole principle, include two from the same chain, and those two are comparable. So the family is legal, and the ceiling is reached.

The same layer argument gives a general ceiling for every $m$: a family with no $m$ pairwise incomparable sets has at most $\sum_i \min\!\left(m-1, \binom{n}{i}\right)$ members. For $m = 2$ this reads $n+1$ and for $m=3$ it reads $2n$ — both exactly attained. This matches a prediction one gets by chopping the cube into *symmetric chains*, chains that run from level $i$ up to level $n-i$: taking the $m-1$ longest of them gives $\sum_{i<m-1}(n+1-2i)$, which is $n+1$ for $m=2$ and $2n$ for $m=3$. The prediction is now confirmed in both cases.

---

## Weighing sets instead of counting them

Return to weak copies, where the real difficulty lies. The key device is almost embarrassingly simple: instead of counting the sets in a family, *weigh* them. Assign to a subset $A$ of size $|A|$ the weight $1/\binom{n}{|A|}$, and define the **Lubell function** of a family as
$$\lambda(\mathcal{F}) \;=\; \sum_{A \in \mathcal{F}} \frac{1}{\binom{n}{|A|}} .$$
The weight has a beautiful probabilistic meaning. A *maximal chain* is a path from $\emptyset$ to $[n]$ adding one element at a time; pick one uniformly at random. The chance it passes through a given $A$ is precisely $1/\binom{n}{|A|}$, so $\lambda(\mathcal{F})$ is the expected number of members of $\mathcal{F}$ that a random maximal chain meets.

Read that way, the celebrated **LYM inequality** is a triviality with a punch: if $\mathcal{F}$ is an antichain, a chain can meet it at most once, so $\lambda(\mathcal{F}) \le 1$. Peeling this off repeatedly gives a bound for taller families. If a family contains no chain of $k+1$ sets, strip away its maximal members — they form an antichain of weight at most $1$ — and repeat; after $k$ rounds nothing is left. Hence:

> **Theorem (weight bound for short families).** A family with no chain of $k+1$ members has Lubell function at most $k$.

Now the crucial step, which turns *weight* back into *count*. Levels are of very different sizes, and a set on a thin level (near the top or bottom of the cube) is expensive: it costs a lot of Lubell weight per set. To maximize the number of sets under a weight budget of $k$, you should spend the budget on the cheapest levels — that is, the fattest ones. This is a fractional knapsack problem, and the greedy solution is optimal:

> **Theorem (knapsack step).** If $\lambda(\mathcal{F}) \le k$, then $\mathcal{F}$ has at most as many members as the union of the $k$ central layers, i.e. at most the sum of the $k$ largest binomial coefficients $\binom{n}{i}$.

The proof is a one-line comparison done level by level. Let $c$ be the smallest layer size inside the central window. For each level $i$, the number $m_i$ of chosen sets satisfies
$$m_i - c\cdot\frac{m_i}{\binom{n}{i}} \;\le\; \begin{cases} \binom{n}{i} - c & i \text{ inside the window},\\ 0 & i \text{ outside}. \end{cases}$$
Inside the window the factor $1 - c/\binom{n}{i}$ is nonnegative, so replacing $m_i$ by its maximum $\binom{n}{i}$ can only increase the left side; outside the window the factor is nonpositive, so the left side is at most zero. Summing over all levels and using the weight bound $\sum_i m_i / \binom{n}{i} \le k$ produces exactly the stated inequality.

Combining the two theorems gives Erdős' $k$-Sperner theorem — a family with no chain of $k+1$ sets has at most the sum of the $k$ largest binomial coefficients — with Sperner's theorem as the case $k=1$. And because a chain of $k+1$ sets *is* both a weak and a strong copy of the $(k+1)$-element chain, we get the exact extremal number for every chain pattern:

> **Theorem (chains are solved).** For a chain $C$ with $k+1$ elements, $\mathrm{La}(n, C) = \mathrm{La}^*(n, C)$ equals the sum of the $k$ largest binomial coefficients, whenever $k \le n+1$.

---

## A bracket for every pattern

Only two facts about a pattern $P$ are needed to squeeze $\mathrm{La}(n,P)$ from both sides.

*From below:* if $P$ has a chain of $h$ elements, then any family with no chain of $h$ sets automatically avoids weak copies of $P$ — a weak copy carries chains to chains. So taking the $h-1$ central layers is always safe.

*From above:* Szpilrajn's classical theorem says every finite partial order can be extended to a linear order. Sorting $P$ into a line embeds it, strictly monotonically, into a chain with $|P|$ elements. So any chain of $|P|$ sets in a family already contains a weak copy of $P$; a $P$-free family therefore has no chain of $|P|$ sets and Erdős' theorem applies.

Writing $h(P)$ for the height of $P$ (the largest number of elements in a chain of $P$), the two observations sandwich the answer:

> **Theorem (the pattern bracket).** For every finite poset $P$,
> $$\sum \text{of the } h(P)-1 \text{ largest } \binom{n}{i} \;\le\; \mathrm{La}(n,P) \;\le\; \sum \text{of the } |P|-1 \text{ largest } \binom{n}{i} .$$
> Both ends are exact extremal numbers of chain patterns, and they coincide precisely when $P$ is itself a chain.

This is already a sharpening of the folklore bound. The classical route bounds a $P$-free family by $(|P|-1)\binom{n}{\lfloor n/2 \rfloor}$ — as if all the relevant layers were as fat as the middle one. They are not. The binomial row grows strictly as you approach the middle, so as soon as three or more layers are involved, the sum of the $k$ largest binomial coefficients is *strictly* smaller than $k \binom{n}{\lfloor n/2\rfloor}$. For the eight-element Boolean pattern $B_3$ (all subsets of a three-element set) on a ground set of size $10$, the old bound is $7\binom{10}{5} = 1764$, while the new one is
$$\binom{10}{2} + \binom{10}{3} + \cdots + \binom{10}{8} = 45+120+210+252+210+120+45 = 1002 .$$
A saving of over forty percent, from nothing more than accounting honestly for the shape of the binomial row.

---

## Why the floor of the bracket must be lossy: the butterfly

The upper end of the bracket uses only the *size* of $P$; the lower end uses only its *height*. Height is a crude invariant, and there is a beautiful, purely local reason why it must under-count.

Call a poset **butterfly-containing** if it has two distinct elements $p_1 \ne p_2$ each lying strictly below two distinct elements $q_1 \ne q_2$ — a four-element crossing pattern, wings up and wings down. The **butterfly poset** itself has exactly these four elements and nothing more; its height is only $2$.

> **Theorem (two-layer rigidity).** If $P$ contains a butterfly, then any two *consecutive* layers of the cube contain no weak copy of $P$ — whatever the height of $P$.

Here is the whole argument. Suppose the four butterfly elements were realized by sets inside layers $a$ and $a+1$. The relations $p_j < q_j$ force $|\iota(p_j)| < |\iota(q_j)|$, and with only two available sizes this pins everything down: both $\iota(p_1), \iota(p_2)$ have size $a$ and both $\iota(q_1), \iota(q_2)$ have size $a+1$. But $\iota(p_1)$ and $\iota(p_2)$ are distinct sets of the same size, so their union is strictly bigger, hence has size at least $a+1$. Each $\iota(q_j)$ contains that union and has size exactly $a+1$ — so each $\iota(q_j)$ *equals* the union. Two distinct elements have been sent to the same set, contradicting injectivity. The upper wings of a butterfly simply have nowhere to go.

Consequently, for the butterfly poset the height bound offers only one central layer, whereas two central layers are already butterfly-free. So the floor of the bracket is genuinely lossy, and the true value satisfies
$$\binom{n}{a} + \binom{n}{a+1} \;\le\; \mathrm{La}(n, \text{butterfly}) \;\le\; \binom{n}{b} + \binom{n}{b+1} + \binom{n}{b+2}$$
for the appropriate central windows — two layers from below, three from above, because the butterfly has four elements.

There is one more twist. The **diamond** $B_2$ — one bottom element, two middle elements, one top — does *not* contain a butterfly: in the diamond, no two elements have two distinct common strict upper bounds. So the diamond escapes this argument entirely, which is a precise explanation of why the notorious diamond problem is hard for reasons the butterfly method cannot touch.

---

## One principle behind all the layer theorems

The two-layer theorem for butterflies and the classical fact that $d$ consecutive layers avoid the Boolean pattern $B_d$ look like separate results. They are the same theorem.

Say $P$ has a **tall butterfly of height $m$** if it contains a butterfly whose two lower wings $p_1, p_2$ are each at the top of a chain of $m+1$ elements of $P$.

> **Theorem (rank rigidity).** A chain of $L$ sets confined to $L$ consecutive layers must occupy each layer exactly once, in order: the $i$-th set of the chain has size exactly $a+i$.

The reason is a squeeze from both directions: strict inclusions force sizes to increase by at least one at each step, so the $i$-th size is at least $a+i$; running the same argument down from the top forces it to be at most $a+i$. With ranks pinned, the butterfly argument runs verbatim one storey higher:

> **Theorem (tall butterfly obstruction).** If $P$ has a tall butterfly of height $m$, then $m+2$ consecutive layers of the cube contain no weak copy of $P$. Hence $\mathrm{La}(n,P)$ is at least the sum of the $m+2$ largest binomial coefficients.

For $m = 0$ this is exactly the butterfly theorem. For $m=1$ it recovers, from a single general principle, the fact that three consecutive layers avoid $B_3$: inside $B_3$, the chains $\emptyset \subset \{1\}$ and $\emptyset \subset \{2\}$ sit below the two distinct sets $\{1,2\}$ and $\{1,2,3\}$.

---

## What is still out there

Three sharp, testable questions remain in view.

**The diamond.** Is $\mathrm{La}(n, B_2) = \binom{n}{\lfloor n/2\rfloor} + \binom{n}{\lfloor n/2\rfloor + 1}$? The bracket gives two layers from below and three from above; exhaustive search confirms the lower end for small $n$. The upper bound wastes a whole layer because it uses only the height of the pattern and never its branching. A Lubell-type argument that charges the branching should remove the third layer — and because the knapsack step converts *any* weight bound into a cardinality bound automatically, only the local analysis remains.

**The butterfly.** Is $\mathrm{La}(n, \text{butterfly})$ exactly the sum of the two largest binomial coefficients for $n \ge 3$? The rigidity theorem suggests the mechanism: in a butterfly-free family, any two sets have at most one common strict upper bound in the family, so the map from pairs to their common upper set is injective — a counting statement that should close the remaining layer. Notably, weights alone cannot settle it: the family $\{\emptyset\} \cup \{\text{all singletons}\} \cup \{[n]\}$ is butterfly-free and has Lubell value exactly $3$, so no bound of the form $\lambda \le 2$ is available. This one is genuinely about cardinality, not weight.

**A new invariant.** For a poset $P$, let $e(P)$ be the largest $k$ such that $k$ consecutive layers are always $P$-free. The results above give $e(P) \ge m+2$ whenever $P$ has a tall butterfly of height $m$, and $e(P) \ge h(P)-1$ always. Is the tall butterfly the *only* obstruction — is $e(P)$ determined exactly by the tallest butterfly in $P$? If so, a purely local, four-element pattern would control an entire family of extremal constants.

---

## The moral

The story here is one of translation. Counting sets is hard; weighing them with $1/\binom{n}{|A|}$ turns the problem into a probability question about random maximal chains, where the answer is nearly obvious. Turning weight back into count is a knapsack problem, where greed is provably optimal. And when weighing is not enough — as with the butterfly — the answer comes from rigidity: inside a narrow band of layers, containment leaves so little room that sets are *forced* to be unions of each other, and forbidden patterns collapse under their own constraints. The objects are as simple as anything in mathematics, yet the answers hinge on a handful of ideas that, once seen, feel inevitable.
