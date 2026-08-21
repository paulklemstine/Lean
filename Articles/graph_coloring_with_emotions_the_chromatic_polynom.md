# Six Emotions, One Hundred Networks: What Coloring a Friendship Graph Tells Us About Feeling

## A party problem

Imagine you are organising an unusual dinner party. Every guest must arrive wearing exactly one of six moods — happiness, sadness, anger, fear, disgust, surprise — and there is one rule: **no two friends may show up in the same mood.** Strangers may match freely; friends must differ.

How many ways are there to run this party?

The question sounds whimsical, but strip away the moods and it is one of the oldest questions in combinatorics. Draw the guests as dots and the friendships as lines between them; you have a *graph*. Assign one of $q$ labels to each dot so that no line joins two dots with the same label; you have a *proper coloring*. The number of such colorings is a function of $q$ that mathematicians have studied since 1912, when George Birkhoff introduced it while attacking the Four Color Problem. It is called the **chromatic polynomial**, written $P_G(q)$.

What follows is a small theory of that function read as a theory of emotional diversity: how many moods a social group *needs*, how many mood-assignments it *admits*, and which features of the group control each. Along the way three pieces of appealing folklore turn out to be false, and the corrections are more interesting than the originals.

## The counting function

Fix a finite population $V$ of people and a symmetric, irreflexive friendship relation $G$ on it — a social network. For a palette of $q$ emotions, write
$$P_G(q) \;=\; \#\{\,c : V \to \{1,\dots,q\} \;:\; c(x) \neq c(y) \text{ whenever } x \text{ and } y \text{ are friends}\,\}.$$
We call such a $c$ an **emotionally consistent assignment**. Two extremes anchor the intuition:

- If nobody is friends with anybody, every assignment works, and $P_G(q) = q^{n}$, where $n$ is the population.
- If *everybody* is friends with everybody — a clique of $n$ people — then all $n$ moods must differ, and $P_G(q) = q(q-1)(q-2)\cdots(q-n+1)$, the falling factorial $q^{\underline{n}}$.

Everything else lies between these two, and that "between" is a theorem, not a slogan, as we will see.

## How many emotions does a group *need*?

The classical **chromatic number** $\chi(G)$ is the least $q$ with $P_G(q) > 0$. In the psychological reading it is the number of distinct moods the group is forced to display. But psychologists studying affect rarely take a two-valued model seriously: "positive versus negative" is a caricature. So we impose a floor of three and define the **emotional chromatic number**
$$\chi_E(G) \;=\; \min\{\,q \ge 3 \;:\; P_G(q) > 0\,\}.$$

The first result says this definition contains no surprises — the floor is a floor and nothing more.

> **Structure Theorem.** For every finite social network, $\chi_E(G) = \max\{\chi(G),\, 3\}$. In particular $\chi_E(G) = \chi(G)$ as soon as the network genuinely needs three or more emotions, and $\chi_E(G) = 3$ exactly when two emotions would have sufficed.

The proof is two inequalities. A coloring with $\max\{\chi,3\}$ colors exists because one with $\chi$ colors does and extra colors never hurt; conversely $\chi_E$ is by definition a number of colors that works, so $\chi \le \chi_E$, and $3 \le \chi_E$ by fiat.

Innocuous as it looks, the Structure Theorem immediately kills a popular claim. One often hears that *a social network splitting cleanly into two camps has no consistent two-emotion assignment, because the chromatic polynomial has a root at $k=2$ for bipartite graphs*. This is exactly backwards. A network splits into two camps — is *bipartite* — precisely when two colors **do** work; a connected bipartite network has exactly two consistent two-emotion assignments (choose which camp is happy). The chromatic polynomial vanishes at $2$ for the networks that are **not** bipartite, the ones containing an odd cycle of friendships. What the emotional floor does to bipartite networks is different and gentler: it lifts them all to exactly the same value,
$$\chi_E(G) = 3 \quad\text{for every bipartite } G,$$
so under the three-emotion convention "cleanly split" and "minimally demanding" are the same condition.

A second correction follows. It is tempting to say that a friendship circle $C_n$ — $n$ people seated in a ring, each friends with their two neighbours — needs two emotions when $n$ is even (alternate them) and three when $n$ is odd. In the classical chromatic number that is right. Under the emotional floor it is not: *every* friendship circle, even or odd, has
$$\chi_E(C_n) = 3 .$$
The parity of the ring is invisible to $\chi_E$. Parity does not vanish from the theory — it reappears in the *count* $P_{C_n}(q)$, not in the threshold — but the number of emotions a circle needs is three, always. Meanwhile a clique of $n$ mutual friends has $\chi_E(K_n) = \max\{n,3\}$: cliques are the only mechanism that pushes emotional demand arbitrarily high.

## Two monotonicity laws, and a universal floor

Before asking *which* networks need many emotions, it pays to know how the counting function behaves qualitatively. Two laws, both provable in a few lines, organise everything else.

> **More friendships, fewer assignments.** If $G$ is a subnetwork of $H$ on the same people (every friendship of $G$ is a friendship of $H$), then $P_H(q) \le P_G(q)$ for every $q$.

Every assignment consistent for $H$ is consistent for $G$, since $G$ imposes fewer constraints; the set of good assignments only shrinks as friendships accumulate.

> **More emotions, more assignments.** If $q \le r$ then $P_G(q) \le P_G(r)$.

Reading a palette of $q$ emotions as a sub-palette of $r$ embeds the consistent $q$-assignments injectively into the consistent $r$-assignments.

Combining the first law with the clique computation gives a bound that holds with no hypotheses at all:

> **Universal floor.** For every social network on $n$ people and every palette size $q$,
> $$q^{\underline{n}} \;=\; q(q-1)\cdots(q-n+1)\;\le\; P_G(q).$$

The worst conceivable case is total mutual friendship, and even that case is computable. Specialising to the six basic emotions and a group of at most six people:

> **Small groups are emotionally rich.** Any group of $n \le 6$ people, whatever their friendships, admits at least $6^{\underline{n}}$ consistent assignments of the six basic emotions — for $n = 6$ that is $720$; for a ten-person group containing a six-person clique, as we compute below, it is $933{,}120$.

Emotional consistency, in other words, is never a scarce resource in small groups. Scarcity is a large-clique phenomenon.

## Positivity is a threshold

Everything about $\chi_E$ hinges on one structural fact: the palette sizes that admit an assignment form an *upward-closed* set. Once you have enough emotions, more emotions can never hurt.

> **Threshold Law.** For $q \ge 3$: $P_G(q) > 0$ if and only if $\chi_E(G) \le q$.

This is what earns $\chi_E$ the name "the number of emotions the network needs". Without it, $\chi_E$ would merely be the *first* palette size that works, with no guarantee that later ones do; the counting function might in principle flicker on and off. It does not.

## Sandwiched between cliques and popularity

Now the central question: what features of a social network predict its emotional demand? Two local statistics offer themselves. The **clique number** $\omega(G)$ is the size of the largest set of people who are all mutually friends. The **maximum degree** $\Delta(G)$ is the largest number of friends any one person has.

> **Sandwich Theorem.** For every finite social network,
> $$\max\{\omega(G),\,3\} \;\le\; \chi_E(G) \;\le\; \max\{\Delta(G)+1,\,3\}.$$

The lower bound is immediate: within a clique of $m$ mutual friends, all $m$ moods must differ. The upper bound is the classical *greedy* argument, and it is worth spelling out because it is genuinely constructive. Line the population up in any order and hand out emotions one person at a time. When you reach a person, at most $\Delta$ of their friends have already been served, so at most $\Delta$ emotions are forbidden; with $\Delta+1$ emotions on the table one is always free. Hence $\chi(G) \le \Delta(G)+1$, and the emotional version follows by the Structure Theorem.

Two consequences deserve names:

> **Six emotions suffice.** If nobody in the network has more than five friends, then six emotions can be distributed consistently, and $3 \le \chi_E(G) \le 6$.

> **Local decidability.** A network in which nobody has more than five friends automatically has largest clique at most six and emotional chromatic number inside the window $[3,6]$ — no global computation required.

Is the sandwich tight? Both sides can be strict simultaneously, and the smallest witness is charming: take five people seated in a circle plus one *hub* who is friends with all five — a six-person "hub-and-circle" network. Its largest clique is a triangle (hub plus two adjacent circle-dwellers), so the lower bound reads $3$. Its most popular person, the hub, has five friends, so the upper bound reads $6$. And the truth is
$$\chi_E(\text{hub-and-circle}) = 4,$$
strictly between. There are exactly $120$ consistent four-emotion assignments and *zero* three-emotion assignments. Neither local statistic explains the answer; the geometry of the odd circle underneath the hub does. This is the smallest instance of a general phenomenon — the gap $\chi - \omega$ is unbounded — and it is a warning to anyone hoping to read "emotional diversity" off a single number like density or popularity.

## Abundance: not just *whether*, but *how many*

Positivity is a crude question. The richer one is quantitative: given that a network can be colored, how many ways are there? Here the greedy argument can be upgraded from an existence proof to a *counting* proof.

> **Greedy Abundance.** If every person has at most $d$ friends, then for every palette size $q$,
> $$(q-d)^{\,n} \;\le\; P_G(q),$$
> where $n$ is the population.

The proof is the greedy algorithm with bookkeeping. Color the population one person at a time; at each step, at least $q - d$ colors remain available regardless of previous choices, because at most $d$ neighbours have been colored. Multiplying the choices over all $n$ steps gives the bound. (Formally: one shows by induction over the growing set of colored people that the fibres of the "forget the last person" map each have at least $q-d$ elements.)

The bound has real teeth. In a community of one hundred people where nobody has more than five friends, the number of consistent assignments of ten emotions is at least
$$5^{100} \approx 7.9 \times 10^{69},$$
comfortably more than the number of atoms in the observable universe. It is also *sharp* at the trivial end: for a friendless population $d = 0$ and the bound $q^n$ is exactly the truth.

## A closed formula, and a census

To test the theory against data one needs families of networks whose counting functions are known exactly. Here is one such family, chosen because it models a tight-knit core inside a larger, unconnected crowd.

> **Cliques with bystanders.** Let $N$ people be given, of whom the first $k$ are mutual friends while everyone else has no friends at all. Writing $s = \min\{k,N\}$, the counting function is
> $$P(q) \;=\; q^{\underline{s}} \cdot q^{\,N-s},$$
> and the emotional chromatic number is $\chi_E = \max\{s,3\}$.

The formula is a clean bijective count: an assignment is consistent exactly when it is injective on the clique and arbitrary elsewhere, so the consistent assignments biject with (injections of the $s$-clique into the palette) $\times$ (arbitrary maps from the $N-s$ bystanders).

With that in hand, consider a census of one hundred social networks: fifty **friendship circles** $C_3, C_4, \dots, C_{52}$, and fifty **clique networks**, each on ten people, whose core clique cycles through sizes $3,4,5,6$.

Every circle has $\chi_E = 3$. The $i$-th clique network has $\chi_E = 3 + (i \bmod 4)$. Therefore:

> **Census Result.** All one hundred networks have emotional chromatic number in the window $[3,6]$. The value $3$ occurs $63$ times, $4$ occurs $13$ times, and $5$ and $6$ occur $12$ times each. The total emotional load — the sum of $\chi_E$ over the census — is $373$, an average of $3.73$ emotions per network.

The six-emotion counts for the ten-person clique networks are exact:

| core clique size | consistent six-emotion assignments |
|---|---|
| 3 | $33{,}592{,}320$ |
| 4 | $16{,}796{,}160$ |
| 5 | $5{,}598{,}720$ |
| 6 | $933{,}120$ |

Read that column downward. As the core gets tighter, the number of consistent assignments falls by a factor of two, then three, then six. Here is the moral of the whole subject in one table: **a group that demands more emotions offers fewer ways to feel them.** Emotional demand and emotional freedom are in tension, and the chromatic polynomial measures both. The minimum over the census, $933{,}120$, is attained exactly at the six-person clique, and is a genuine lower bound for every clique network in the census.

Finally, the honest caveat. Is $\chi_E \in [3,6]$ a theorem? No — it is a property of this sample. Seven people who are all mutual friends have
$$P(6) = 0, \qquad \chi_E = 7 .$$
Six emotions are then not merely strained but *impossible*. The general truth is the Sandwich Theorem; the window is what the sandwich yields when cliques stay small and nobody is too popular.

## The dual network: emotional simplicity is never free

There is one more law, and it is the most philosophically loaded. Alongside the friendship network $G$, consider the **stranger network** $\overline{G}$: the same people, joined whenever they are *not* friends. Color both. If person $x$ and person $y$ are distinct, they are either friends or strangers, so at least one of the two colorings separates them — the pair (friendship-mood, stranger-mood) identifies a person uniquely. Counting pairs:

> **Conservation Law (Nordhaus–Gaddum form).** For every population of $n$ people,
> $$n \;\le\; \chi_E(G)\cdot\chi_E(\overline{G}), \qquad\text{and consequently}\qquad 4n \;\le\; \bigl(\chi_E(G)+\chi_E(\overline{G})\bigr)^2 .$$
> (The same inequalities hold with the classical chromatic number in place of $\chi_E$.)

The second form says $\chi_E(G) + \chi_E(\overline{G}) \ge 2\sqrt{n}$: a network and its complement cannot both be emotionally simple.

The consequences are striking. In a community of one hundred people whose friendships need only the six basic emotions, the stranger network needs **at least seventeen**. If additionally nobody has more than five friends, then somebody in that community has at least sixteen people they are on record as not being friends with, in the strong sense that the stranger network has maximum degree at least $16$. And a *self-complementary* community — one whose pattern of friendships is a relabelling of its pattern of strangerhood — can contain at most $\chi_E(G)^2$ people.

The inequality is not an equality: for the five-person friendship circle, the stranger network is again a five-cycle, so the product is $3 \cdot 3 = 9 > 5$. But it cannot be improved to an equality in general, and its two extremes are both realised — on a clique the product law is attained once the emotional floor is stripped away.

## What the polynomial is really measuring

Three more structural facts round out the picture, and each has a plain-language reading. Relabelling the people of a network does not change its emotional chromatic number — the quantity is intrinsic, not an artefact of who is called what. Adding friendships never decreases it. And if a population splits into two communities with no friendships between them, then
$$\chi_E(G \sqcup H) = \max\{\chi_E(G), \chi_E(H)\}:$$
the emotional demand of a society is the demand of its most tangled component, not the sum of its parts. Isolation is emotionally free.

So what has the chromatic polynomial told us? That the number of emotions a social group *requires* is squeezed between its tightest clique and its most popular member, and pinned to neither. That the number of ways a group can *feel consistently* is astronomically large unless the group is dominated by a clique — and falls sharply as the clique grows. That a group and its complement cannot both be simple. And that three appealing pieces of folklore — bipartite networks having no two-emotion assignments, even circles needing only two emotions, six emotions always sufficing — are, respectively, backwards, an artefact of the floor, and false in general, with a seven-person clique as the counterexample.

Birkhoff invented $P_G(q)$ to count colorings of maps. A century later it is a general-purpose instrument for measuring how much *variety* a constraint system forces. Friendship networks with moods are only one dial on that instrument — the same mathematics schedules exams without conflicts, allocates radio frequencies to transmitters that must not interfere, and assigns registers to variables inside a compiler. What makes the emotional reading worth keeping is that it makes the two halves of the story audible at once. A society with a large clique of intimates is a society under emotional strain: it demands many distinct feelings, and it grants very few ways to distribute them. That tension is not a metaphor. It is a falling factorial.
