# The Half-Full Element: How One Extra Set Can Save a Conjecture (and How Two Can Ruin It)

## A conjecture you can explain over coffee

Take a finite collection $F$ of finite sets — say

$$F = \{\ \{1\},\ \{2\},\ \{1,2\},\ \{1,2,3\}\ \}.$$

Notice something: if you take any two members of $F$ and glue them together with a union, you land back inside $F$. Such a collection is called **union-closed**. Union-closed families are everywhere once you start looking: the collection of all subgroups-generated-by, the collection of "reachable states" in a process where information only accumulates, the sets of features activated by at least one example in a dataset. Anything that can only grow when you combine two things gives you a union-closed family.

In 1979 Péter Frankl asked a question about such families that sounds almost too simple to be hard:

> **Frankl's union-closed sets conjecture.** If a union-closed family has at least one nonempty member, then some element belongs to at least half of the members.

In our example above, the element $1$ lies in three of the four members — comfortably more than half. Frankl conjectured this is never an accident. Almost fifty years later, nobody knows whether he was right. It is one of the most stubbornly elementary open problems in combinatorics: no algebra, no topology, no analysis — just sets, and counting.

Call an element $x$ **abundant** in a family $F$ when

$$|F| \le 2 \cdot \deg_F(x), \qquad \deg_F(x) := \#\{A \in F : x \in A\}.$$

Frankl's conjecture says: every union-closed family with a nonempty member has an abundant element. This article is about a much humbler question — one that turns out to expose the exact shape of the difficulty.

## The humble question

Every family $F$ has a **top**: the union $\bigvee F$ of all of its members, the smallest set containing everything in sight. If $F$ is union-closed and nonempty, the top is already a member of $F$. If $F$ is not union-closed, the top may be missing, and adjoining it is the most natural first step toward union-closing the family.

So here is the question. Suppose $x$ is abundant in $F$, and $x$ lies in the top. Adjoin the top:

$$F^{+} := F \cup \{\textstyle\bigvee F\}.$$

**Is $x$ still abundant in $F^{+}$?**

The reason this is not obviously "yes" is parity. Abundance is a threshold condition, $|F| \le 2\deg$, and thresholds are fragile: if $|F| = 5$ and $\deg = 3$, then $x$ is abundant with one unit to spare; but adding a member could tip $6 \le 2\deg$ out of reach if the degree fails to keep up. One naturally suspects a parity obstruction — that odd families behave differently from even ones, and that the claim fails on one of the two.

It doesn't. And the reason it doesn't is the whole point.

## The two-for-one accounting

Define the **surplus** of $x$ in $F$ to be the integer

$$\sigma_F(x) := 2\deg_F(x) - |F|.$$

Abundance is exactly the statement $\sigma_F(x) \ge 0$. Now watch what happens when you adjoin a single new set $A$ to $F$:

- if $x \in A$, then $\deg$ goes up by $1$ and $|F|$ goes up by $1$, so the surplus changes by $2 - 1 = \mathbf{+1}$;
- if $x \notin A$, then $\deg$ is unchanged and $|F|$ goes up by $1$, so the surplus changes by $\mathbf{-1}$.

That is the entire mechanism. A new member is charged **once** against the family size but **twice** in favour of the degree, provided it contains $x$. Since the top $\bigvee F$ contains $x$ by hypothesis, adjoining it moves the surplus up by exactly one.

**Theorem (Adjoining the top preserves a witness).** *If $x$ is abundant in $F$ and $x \in \bigvee F$, then $x$ is abundant in $F^{+}$. Quantitatively, if the top was not already a member, then $\sigma_{F^{+}}(x) = \sigma_F(x) + 1$.*

Parity never enters. In fact parity turns out to be a *free bonus* rather than an obstruction: if $|F|$ is odd, then $|F| \le 2\deg_F(x)$ forces $|F| + 1 \le 2\deg_F(x)$, because an odd number can never equal an even one. On odd families abundance is automatically strict — there is always at least one member of slack.

## Where the claim really breaks

The conjecture-in-miniature was proposed with a suspected weak point (parity) and it turned out to have a completely different one. There is exactly one counterexample to the unguarded claim, and it is the emptiest possible object.

If $F = \varnothing$, every element is abundant — vacuously, since $0 \le 2 \cdot 0$. But the top of the empty family is the empty set, so $F^{+} = \{\varnothing\}$: a family with one member, containing nothing. No element is abundant there, since $1 \le 2 \cdot 0$ is false. The witness is destroyed.

That single degenerate case is the whole story:

**Theorem (Exact boundary).** *Let $x$ be abundant in $F$. Then $x$ is abundant in $F^{+}$ **if and only if** $F$ is nonempty.*

So the "additional hypothesis needed" — the thing one hunts for when a plausible claim might be false — is precisely nonemptiness, and nothing else. Even the hypothesis "$x$ lies in the top" turns out to be redundant once $F$ is nonempty: an abundant element of a nonempty family has positive degree, hence lies in some member, hence in the union of all members.

What is *not* redundant is that the adjoined set contains $x$. Take $F = \{\varnothing, \{0\}\}$ with $x = 0$: two members, one contains $0$, so $x$ is abundant on the nose. Adjoin the set $\{1\}$, which misses $x$. Now three members, still one containing $0$, and $1 \le 3/2$ fails. Abundance is gone. The surplus ledger predicted it: a new set avoiding $x$ costs exactly one unit.

## Batches, schedules, and the moment things go wrong

Once you see the surplus as a ledger, a stronger statement writes itself. Surplus is **additive**: if $F$ and $G$ are disjoint families, then

$$\sigma_{F \cup G}(x) = \sigma_F(x) + \sigma_G(x),$$

and the surplus of a batch $G$ is simply (number of sets in $G$ containing $x$) minus (number avoiding $x$). So abundance survives adjoining *any* batch of new sets, provided at least half of them contain $x$. Adjoining the top is just the smallest possible good batch: one set, surplus $+1$.

This reframing immediately locates the boundary between the easy and the hard. Adjoining the top is one step toward union-closing a family. What about the *next* step — adjoining all pairwise unions? Or the full **union closure**, the smallest union-closed family containing $F$ (concretely: all unions of nonempty subfamilies of $F$)?

There the ledger goes red. Consider the four-member family over the ground set $\{0,1,2\}$

$$F = \{\ \{0,1,2\},\ \{0,1\},\ \{1\},\ \{2\}\ \}, \qquad x = 0.$$

Two of the four members contain $0$, so $x$ is abundant, and the top $\{0,1,2\}$ is already present, so adjoining it changes nothing — the witness survives, as promised. But one round of pairwise unions creates the new set $\{1\} \cup \{2\} = \{1,2\}$, which does **not** contain $0$. Now five members, still only two containing $0$, and $5 \le 4$ is false. The union closure

$$\{\ \{1\},\ \{2\},\ \{1,2\},\ \{0,1\},\ \{0,1,2\}\ \}$$

has destroyed the witness.

This is a precise diagnosis of why Frankl's conjecture is hard. The closure operation is not monotone for abundance. Every individual adjunction is either $+1$ or $-1$ on the ledger, and the good steps and bad steps are interleaved; the conjecture asserts that the *endpoint* of the process is always favourable to somebody, even though the path there can be arbitrarily unfavourable to everybody you were watching.

## Making abundance appear out of thin air

The results so far transport a witness you already have. Can we manufacture one? Yes — with an averaging argument that needs no union-closedness at all.

There are two ways to count the incidences of a family: element by element, or set by set. Summing degrees over a ground set $s$ that contains every member gives the same number as summing the sizes of the members:

$$\sum_{x \in s} \deg_F(x) = \sum_{A \in F} |A| =: T(F).$$

This is the classical double count — the number of $1$'s in the incidence matrix, read by columns or by rows. It converts a global statistic (the total size $T(F)$) into a statement about local statistics (the degrees), and that conversion is exactly what an averaging argument needs.

**Theorem (Averaging criterion).** *Let $s$ be a nonempty ground set containing every member of $F$. If the members of $F$ are on average at least half the size of $s$, i.e.*

$$|s| \cdot |F| \le 2\, T(F),$$

*then some element of $s$ is abundant in $F$.*

The proof is a one-liner in the contrapositive: if every element of $s$ had $2\deg_F(x) < |F|$, summing that strict inequality over the nonempty set $s$ would give $2T(F) < |s|\,|F|$. This is a genuinely checkable sufficient condition for Frankl-type abundance, and it is entirely independent of the singleton and pair cases that classical arguments handle.

It is not necessary, and we can say exactly how it fails. The union-closed family

$$\{\ \varnothing,\ \{0\},\ \{1\},\ \{0,1\},\ \{0,1,2\}\ \}$$

has the abundant element $0$ (degree $3$ out of $5$ members), but its total size is $0+1+1+2+3 = 7$, while the criterion demands $2T \ge 3 \cdot 5 = 15$. Sparse families can still have abundant elements; the criterion just doesn't see them.

## The two mechanisms agree

Here the story closes a loop. We have two quite different sources of abundance: transport (a witness survives adjoining the top) and creation (the averaging hypothesis produces a witness). Do they interact?

**Theorem (Stability of the averaging criterion).** *If the averaging criterion holds for $F$ on its own top as ground set, then it still holds after adjoining the top.*

Adjoining a new top adds exactly $|\bigvee F|$ incidences to $T(F)$ while adding one member — and $2|\bigvee F| \ge |\bigvee F|$ is precisely what the bookkeeping needs. So the operation preserves not only an individual witness but the *global hypothesis that manufactures witnesses*. The local and global pictures are consistent, which is what one expects when both are shadows of the same incidence matrix: adjoining the top adds one row that is maximal in every column of the top.

Better still, the operation is not merely harmless but strictly helpful. Define the **density** of $x$ as the fraction $\deg_F(x)/|F|$ of members containing $x$. If the top is genuinely new, contains $x$, and $x$ misses at least one member of $F$, then the density strictly increases. (And the excluded case is exactly the trivial one: if $x$ is in every member the density is already $1$ and cannot improve.)

## What one set can and cannot tell you

The last thread is a quantitative limit. Frankl's conjecture is known unconditionally when the family contains a singleton $\{a\}$ — then $a$ is abundant, because $A \mapsto A \cup \{a\}$ injects the members avoiding $a$ into the members containing $a$. It is also known when the family contains a two-element set $\{a,b\}$ — then $a$ or $b$ is abundant.

What if the smallest member you can find has size $k$? A fibre-counting argument gives: for a union-closed $F$ with a member $A \ni a$,

$$|F| \le \left(2^{|A|-1} + 1\right) \deg_F(a).$$

The idea: the map $B \mapsto B \cup A$ sends every member avoiding $a$ to a member containing $a$, and a fibre of this map is determined by $B \cap A$, which lies in the $2^{|A|-1}$-element power set of $A \setminus \{a\}$; the "$+1$" is the members containing $a$ themselves.

And this constant is optimal for **every** size of $A$. Take the family consisting of all subsets of $A \setminus \{a\}$, plus $A$ itself. It is union-closed, it has $2^{|A|-1} + 1$ members, and exactly one of them — namely $A$ — contains $a$. Equality throughout.

For $|A| = 1$ this recovers the singleton case, $|F| \le 2\deg$. For $|A| = 2$ it gives $|F| \le 3\deg$, which is a real constraint but *not* abundance. And the extremal family shows this is not a weakness of the argument: **no route to Frankl's conjecture can go through a single member of size $\ge 2$.** You must use several members at once. That is a genuine structural obstruction, cleanly quantified.

## Two families where the conjecture is simply true

Two unconditional cases fall out, and they are at opposite extremes of the same counting.

*Chains.* If $F$ is totally ordered by inclusion — $A \subseteq B$ or $B \subseteq A$ for any two members — then $F$ is automatically union-closed, and it has an abundant element whatever its size. Reason: take a nonempty member $M$ of minimum cardinality. Every nonempty member contains $M$ (a chain comparison plus minimality forces it), so each element of $M$ has degree at least $|F| - 1$, and $2(|F|-1) \ge |F|$ as soon as $|F| \ge 2$.

*Small families.* Every union-closed family with a nonempty member and at most four members has an abundant element. Two distinct nonempty members always produce an element of degree at least two, and degree two carries a family of size four.

Chains maximise how many members can contain a single minimal element; small families minimise how many members there are to cover. Both dodge the exponential loss that the $2^{k-1}+1$ law shows to be unavoidable in general.

Finally, deciding abundance needs no search: over a nonempty ground set $s$, the family has an abundant element of $s$ if and only if $|F| \le 2\max_{x \in s}\deg_F(x)$. That single maximum is a certificate — and adjoining the top can only increase it, the algorithmic shadow of the surplus ledger.

## What we learned from a small question

The original question — does adjoining the top preserve an abundant witness? — was chosen because it looked falsifiable, with parity as the suspected culprit. The answer is that parity was a red herring; the honest boundary is degeneracy, and the accounting that reveals this ($+1$ per good set, $-1$ per bad set) turns out to be a general-purpose instrument. It explains why one step of closure is safe, why two need not be, why an averaging hypothesis survives the same operation, and how the density of a witness strictly improves.

Frankl's conjecture remains open. But there is a clear statement of what would have to change for it to close: not a cleverer bound from a single small member — the $2^{k-1}+1$ law forbids that — but a way to *schedule* the closure. The closure of a family is reached by many single adjunctions, each worth exactly $+1$ or $-1$ to a chosen element. The conjecture would follow if, for every union-closed target, some element admits a schedule of these adjunctions along which its running surplus never drops below where it started. Adjoining the top is safe precisely because it is the batch of size one with positive surplus. The question is not which batches are dangerous — it is whether danger can always be rescheduled away.

That is a purely combinatorial question about lattice paths, and unlike the conjecture itself, you can start testing it on a three-element ground set this afternoon.
