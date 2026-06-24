# The Private Lives of Set Families: How "Missing Traces" Bound the Size of a Combinatorial Universe

## A puzzle about shadows

Imagine you are cataloguing committees. Your town has $n$ residents, numbered $1$ through $n$, and every committee you record must have *exactly* $d+1$ members. You could, in principle, write down every possible committee of that size — there are
$$\binom{n}{d+1}$$
of them, an enormous number even for a modest town. But suppose you are not free to choose any committees you like. Suppose your collection of committees obeys a subtle structural rule, one phrased not in terms of the committees themselves but in terms of their *shadows*.

When you remove a single person from a committee of $d+1$ people, you get a smaller group of $d$ people — call it a **facet**. Each committee of size $d+1$ casts $d+1$ such facet-shadows. Now here is the crucial idea. A facet is **shared** if it shows up underneath two or more of your committees; it is **private** if it lurks beneath exactly one. A private facet is a fingerprint: a $d$-person group that points unambiguously to a single committee in your collection.

The structural rule we study is this: *every committee in the collection has exactly $s$ private facets.* The number $s$ is a kind of "missing-trace size" — it measures how much each committee fails to overlap with its neighbours. And the question that animates this article is deceptively simple:

> If every committee has exactly $s$ private fingerprints, how large can the whole collection possibly be?

The answer turns out to be governed by an elegant counting principle, and the proof is a small gem of combinatorial reasoning. This article tells that story.

## Traces, shattering, and why combinatorialists care

The language of facets and shadows is not arbitrary. It belongs to one of the most influential circles of ideas in modern discrete mathematics: the theory of **traces** and **shattering**, which underlies the famous Sauer–Shelah lemma and, through it, the Vapnik–Chervonenkis dimension that quietly powers statistical learning theory.

Here is the connection in miniature. Think of each subset of our ground set $[n] = \{1, 2, \dots, n\}$ as a yes/no pattern over the $n$ residents: in or out. A *family* of subsets is then a collection of patterns. When we restrict attention to a few coordinates — a few residents — and look at which patterns appear, we are taking a **trace**. If every conceivable pattern on those coordinates appears, we say the family **shatters** that set of coordinates. The Sauer–Shelah lemma says, roughly, that a family which avoids shattering any large set cannot itself be large. It is a statement that "local poverty forces global poverty."

Our committees-and-facets puzzle is a close cousin. A facet $D$ of a committee $F$ is *present as a trace* of $F$ exactly when some **other** committee $G$ realises it — when $G \cap F = D$, which for $(d+1)$-sets means $D$ sits inside two committees at once. A facet is a *missing trace* of $F$ precisely when it is private: contained in $F$ and nowhere else. So "$F$ has $s$ missing traces" is the same as "$F$ has $s$ private facets." The combinatorial object and the learning-theoretic object are two faces of one coin.

This is why the bound we are about to prove deserves a name: the **uniform witness bound**. Each private facet *witnesses* its committee, and the arithmetic of witnesses limits how many committees can coexist.

## Setting the stage precisely

Let us fix the cast of characters once and for all, so that everything that follows is self-contained.

- The ground set is $[n] = \{1, 2, \dots, n\}$.
- A family $\mathcal{F}$ is a collection of subsets of $[n]$.
- $\mathcal{F}$ is **$(d+1)$-uniform** if every member $A \in \mathcal{F}$ has exactly $d+1$ elements. We assume throughout that $d \ge 2$.
- For a $d$-element set $D$, its **facet-degree** $\deg_{\mathcal F}(D)$ is the number of members of $\mathcal{F}$ that contain $D$.
- The **private facets** of a member $A$ are the $d$-element subsets $D \subseteq A$ with $\deg_{\mathcal F}(D) = 1$ — those contained in $A$ and in no other member.
- $\mathcal{F}$ has **missing-trace size $s$** if every member $A \in \mathcal{F}$ has exactly $s$ private facets.

We will also meet two natural example families:

- The **complete family** consists of *all* $(d+1)$-subsets of $[n]$. It is the most crowded uniform family possible, and — as we will see — it is the unique extremiser when $s = 0$.
- The **trivial star** consists of all $(d+1)$-subsets that contain a single fixed resident, say person $0$. It is a tightly-clustered family, every committee sharing one universal member.

With this vocabulary, the central quantity is the **witness bound**
$$
W(d, s, n) =
\begin{cases}
\dbinom{n}{d+1}, & s = 0, \\[2mm]
\left\lfloor \dfrac{1}{s}\dbinom{n}{d} \right\rfloor, & s \ge 1,
\end{cases}
$$
and the theorem we will explain says that $|\mathcal{F}| \le W(d, s, n)$ whenever $\mathcal F$ is $(d+1)$-uniform with missing-trace size $s$, under the mild size conditions $d \ge 2$, $s \le d$, and $n \ge 2(d+1)$.

The two cases of $W$ tell two genuinely different stories, and we treat them in turn.

## The saturated case: when nothing is private

Start with the extreme $s = 0$. A family of missing-trace size $0$ is one in which **no committee has a private facet at all**: every $d$-person group beneath every committee is shared with some other committee. The family is, in a sense, perfectly "saturated" — there are no fingerprints, no committee can be singled out by a shadow.

How big can such a family be? The bound says $|\mathcal F| \le \binom{n}{d+1}$, and the reason is almost embarrassingly direct: *every* $(d+1)$-uniform family, regardless of its missing-trace size, is a sub-collection of the complete family of all $(d+1)$-subsets, and there are exactly $\binom{n}{d+1}$ of those. This is the content of the lemma we call **card_le_choose_succ**: uniformity alone caps the family at $\binom{n}{d+1}$.

The interesting part is the *equality* statement. When does a saturated family actually achieve the maximum? The answer is crisp and total:

> **Saturated equality.** A $(d+1)$-uniform family $\mathcal F$ with missing-trace size $0$ satisfies $|\mathcal F| = \binom{n}{d+1}$ **if and only if** $\mathcal F$ is the complete family of all $(d+1)$-subsets.

One direction is trivial: the complete family obviously has $\binom{n}{d+1}$ members. The other direction is the heart of the matter — a maximal family is forced to be *everything*. Intuitively, if even one $(d+1)$-subset were missing, the absence would ripple downward and expose a private facet somewhere, contradicting saturation; the only way to have no private facets and maximal size is to leave nothing out. This is the theorem we call **uniform_witness_eq_zero**, and it pins down the saturated extremiser with no ambiguity.

## The witnessed case: counting fingerprints

Now the substantive case, $s \ge 1$. Here each committee carries exactly $s$ private facets, and we want to show
$$
|\mathcal{F}| \le \left\lfloor \frac{1}{s}\binom{n}{d}\right\rfloor,
\quad\text{equivalently}\quad
|\mathcal{F}| \cdot s \le \binom{n}{d}.
$$
The second, multiplied-out form is the clue to the whole proof. It says: *the total inventory of private facets, counted across all committees, never exceeds the number of $d$-subsets available.* And once you see why the private facets cannot collide, the inequality writes itself.

### The disjointness principle

Here is the single observation that makes everything work — the lemma we call **privateFacets_pairwiseDisjoint**:

> The private facets of two *different* committees are completely disjoint as sets of $d$-subsets. No $d$-set can be a private facet of two committees at once.

Why? Suppose a $d$-set $D$ were a private facet of both committee $A$ and committee $B$, with $A \ne B$. Being a private facet means $D$ has facet-degree $1$ — it lies in exactly one member of $\mathcal F$. But $D \subseteq A$ and $D \subseteq B$ exhibit *two* members containing $D$, so its facet-degree is at least $2$. That contradicts $\deg_{\mathcal F}(D) = 1$. Hence no such $D$ exists, and the private-facet sets of distinct committees never overlap. A private fingerprint really does point to a unique committee — that is what "private" means, made into arithmetic.

### Adding it all up

Now the counting is a one-line miracle. Because the private-facet sets are pairwise disjoint, their grand union has size equal to the *sum* of the individual sizes:
$$
\left|\bigcup_{A \in \mathcal F} \text{(private facets of }A)\right|
= \sum_{A \in \mathcal F} s
= |\mathcal F| \cdot s,
$$
using that each of the $|\mathcal F|$ committees contributes exactly $s$ private facets (this is precisely the missing-trace-size hypothesis). On the other hand, every private facet is, by definition, a $d$-element subset of $[n]$, and there are only $\binom{n}{d}$ of those in total. So the union is a subset of the universe of $d$-sets, giving
$$
|\mathcal F| \cdot s \le \binom{n}{d}.
$$
That is the lemma **card_mul_le_choose**. Dividing by $s$ (and remembering that the number of committees is a whole number) yields the witness bound
$$
|\mathcal F| \le \left\lfloor \frac{1}{s}\binom{n}{d}\right\rfloor,
$$
which is the genuine combinatorial heart of the main theorem, **uniform_witness_bound**.

It is worth pausing on how little machinery this required. There is no clever algebra, no generating function, no probabilistic flourish. The entire argument rests on a definition ("private means degree one") and a single act of bookkeeping ("disjoint things add up"). The deepest combinatorial truths often have exactly this texture: a sharp definition does most of the work, and the inequality falls out of honest counting.

## A worked miniature

Concrete numbers make the principle vivid. Take $d = 2$, so committees are *triples* (size $d + 1 = 3$) and facets are *pairs* (size $d = 2$). Set $n = 6$. There are $\binom{6}{2} = 15$ possible pairs.

Suppose each triangle in our family has missing-trace size $s = 2$: each triple owns exactly $2$ private pairs. The witness bound then says
$$
|\mathcal F| \le \left\lfloor \frac{15}{2} \right\rfloor = 7.
$$
The disjointness principle is what enforces this: $7$ triangles, each claiming $2$ private pairs, would consume $14$ of the $15$ available pairs without any two triangles fighting over the same pair — just barely fitting. An eighth triangle would need $2$ more private pairs, demanding $16$ in all, which is impossible. The arithmetic of fingerprints draws a hard ceiling, and the ceiling is exactly $\lfloor \binom{n}{d}/s\rfloor$.

Change $s$ to $1$ and the ceiling jumps to $\lfloor 15/1\rfloor = 15$; change it to $3$ and the ceiling drops to $\lfloor 15/3\rfloor = 5$. The witness bound is a clean, monotone trade: the more private facets each committee must own, the fewer committees the universe can hold. Privacy is expensive.

## Two landmark families

The theorem would be hollow without examples showing the framework is non-vacuous, and two natural constructions anchor it.

The **complete family** — all $(d+1)$-subsets — has cardinality exactly $\binom{n}{d+1}$ and is $(d+1)$-uniform by construction. It realises the saturated extremum: it is the family that the $s = 0$ equality theorem singles out as the unique maximiser. It is the "everything" of the uniform world.

The **trivial star** — all $(d+1)$-subsets through a single fixed vertex — is the opposite temperament: maximally clustered rather than maximally spread. Every committee shares one universal member. It is again genuinely $(d+1)$-uniform, and its cardinality is the number of ways to fill the remaining $d$ seats from the other $n - 1$ residents, namely $\binom{n-1}{d}$. The star is the prototype of the *witnessed* regime, and it is the seed of the extremal constructions conjectured to be sharp deep inside the parameter range.

These two families — the complete spread and the trivial star — frame the entire landscape. Everything that can happen happens between them.

## Why this matters beyond committees

It would be a mistake to read this as a story only about committees, or only about set systems. The "missing-trace" invariant is a unifying lens.

In **learning theory**, the size of a family of patterns controls how much data you need to learn a concept; bounds like Sauer–Shelah are the reason finite-VC-dimension classes are learnable at all. A bound that says "each pattern must own $s$ private witnesses, therefore there cannot be too many patterns" is exactly the kind of capacity control that translates into sample-complexity guarantees.

In **coding theory and combinatorial design**, private facets behave like error-correcting fingerprints: a $d$-set of degree one identifies its codeword unambiguously. The witness bound becomes a packing bound — how many codewords can carry disjoint private identifiers.

In **extremal set theory**, the result sits in the lineage of the Frankl–Pach bound and the Erdős–Ko–Rado theorem, the great results that say uniform families obeying a local intersection rule cannot be too large. The witness bound adds a new dial — the missing-trace size $s$ — and shows precisely how turning that dial squeezes the family. As $s$ grows from $0$ toward $d$, the ceiling slides from the lavish $\binom{n}{d+1}$ down through the austere $\lfloor \binom{n}{d}/s\rfloor$, tracing a quantitative phase transition from saturation to scarcity.

## The frontier

The two regimes settled here — the saturated $s = 0$ end, characterised completely, and the witnessed $s \ge 1$ bound, proved in general — are the anchors of a larger conjectural picture. The deepest content lies in the *middle* of the range, in the window $\lceil (d+2)/2\rceil \le s \le d-1$, where recent work suggests entirely new extremal families appear, neither the complete spread nor the trivial star but subtle "tree-like liftings" of the two-dimensional case. Classifying exactly which families achieve the witness bound across that window — turning the inequality into a census of extremisers — is the open horizon.

What is striking is how much certainty already lives at the foundations. The disjointness of private facets is not a heuristic; it is a theorem, secure as arithmetic. The saturated extremiser is not a conjecture; it is pinned down to the last set. From a definition as humble as "a facet beneath exactly one committee," an entire quantitative theory unfolds — a reminder that in combinatorics, as in life, the most revealing thing about a collection is often what it keeps private.
