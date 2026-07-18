# Graph Coloring with Emotions

## How a classical counting polynomial measures diversity in friendship networks

Imagine arriving at a party where every guest wears a badge showing one of several emotions: happiness, sadness, anger, fear, disgust, or surprise. There is one unusual rule. Whenever two guests are friends, their badges must show different emotions. How many assignments obey the rule? How many emotional categories are needed before any assignment is possible? And what does the architecture of the friendship network have to do with the answers?

These questions turn a familiar idea from psychology into a precise problem in graph theory. The emotional labels are metaphors, not claims about how real people feel. Yet the metaphor illuminates a powerful piece of mathematics: the chromatic polynomial, a function that does much more than decide whether a network can be colored. It counts every valid assignment and reveals the exact point at which impossibility gives way to possibility.

## Networks, colors, and emotional palettes

A finite social network can be represented by a graph $G$. Its vertices are people, and an edge joins two people when they are friends. Choose a palette of $k$ labels. A **proper assignment** gives one label to each vertex so that adjacent vertices receive different labels.

The chromatic counting function, traditionally written $P_G(k)$, is the number of proper assignments using labels from a palette of size $k$. It is called the chromatic polynomial because, for every finite graph, this counting function is a polynomial in $k$.

The emotional interpretation simply renames the colors. At $k=6$, the labels may be the six basic emotions happiness, sadness, anger, fear, disgust, and surprise. Then $P_G(6)$ counts the emotionally consistent assignments: assignments in which no pair of friends shares a label.

Counting and existence are linked by a basic fact:

> **Positivity Principle.** A graph admits a proper assignment from a palette of size $k$ exactly when $P_G(k)>0$.

This may look obvious, but it is the bridge on which the entire story rests. The polynomial is not merely an algebraic decoration. Its positivity records whether a social constraint can be satisfied.

We now impose an interpretive floor. Define the **emotional chromatic number** $	au_E(G)$ to be the smallest palette size $k$ satisfying both $k\ge 3$ and $P_G(k)>0$. The lower bound of three is part of the model: the emotional palette is required to have at least three categories. Thus $	au_E(G)$ is a truncated version of the ordinary chromatic number. Even an empty or edgeless network has emotional chromatic number $3$, because palettes of size $0$, $1$, or $2$ are excluded by definition.

This distinction matters. Without it, an even cycle needs only two colors. With the emotional floor, its emotional chromatic number is $3$. One should therefore never silently identify the ordinary and emotional notions.

## The threshold theorem

The central result says that, once we are above the floor, the algebraic count and the order-theoretic threshold carry exactly the same information.

> **Emotional Threshold Theorem.** For every finite graph $G$ and every integer $k\ge 3$,
> $$
> \tau_E(G)\le k \quad\Longleftrightarrow\quad P_G(k)>0.
> $$

Why? If $	au_E(G)\le k$, then a proper assignment exists at the minimum admissible palette. Any extra labels may simply go unused, so the same assignment works with $k$ labels. Hence $P_G(k)>0$. Conversely, if $P_G(k)>0$, then a proper $k$-assignment exists. Since $k$ is admissible, the smallest admissible palette cannot exceed it.

The theorem turns the graph’s emotional chromatic number into a boundary. Below the boundary, all admissible counts vanish. At and above it, the counts are positive. The whole threshold can therefore be read from a sequence such as

$$
P_G(3),\;P_G(4),\;P_G(5),\;P_G(6),\ldots
$$

by finding the first positive term.

This gives a sharper characterization.

> **Minimal-Positive-Value Theorem.** For every finite graph $G$ and integer $k$,
> $$
> \tau_E(G)=k
> $$
> exactly when all three of the following hold:
> 
> 1. $k\ge 3$;
> 2. $P_G(k)>0$;
> 3. $P_G(j)=0$ for every integer $j$ with $3\le j<k$.

The forward direction follows from minimality: the chosen palette works, and no smaller admissible palette can work. For the reverse direction, positivity at $k$ shows that the threshold is no larger than $k$. If the threshold were smaller, its own proper assignment would force positivity at an earlier admissible value, contradicting the stipulated zeros.

The result gives the roots of the counting function a social interpretation. Consecutive zeros at admissible palette sizes describe a corridor of impossibility; the first positive evaluation marks the exact onset of feasible emotional diversity.

## Why two colors require care

A tempting but false slogan says that every bipartite graph has a chromatic-polynomial root at $2$. A single edge disproves it. Its endpoints must receive different labels, and with two labels there are exactly two assignments. Thus

$$
P_G(2)=2
$$

for the one-edge graph, not zero.

What is true is that a bipartite graph is properly two-colorable. If it has at least one edge, its ordinary chromatic number is $2$, and its count at $2$ is positive. The emotional model nevertheless begins at $3$ by convention. This correction is more than housekeeping: it prevents the psychology-inspired language from distorting the combinatorics.

## The six-emotion test

The six-label palette has an especially clean interpretation.

> **Six-Emotion Characterization.** For every finite graph $G$,
> $$
> P_G(6)>0
> \quad\Longleftrightarrow\quad
> 3\le \tau_E(G)\le 6.
> $$

The lower inequality always follows from the definition. The upper inequality says that six labels suffice. By the Emotional Threshold Theorem, this is equivalent to positivity of the chromatic count at $6$.

This theorem makes a proposed empirical study conceptually simple. Given a real network, compute or estimate whether $P_G(6)$ is positive. If it is, the emotional chromatic number lies between $3$ and $6$. But the mathematics does not predict that most real networks will pass this test; that is an empirical hypothesis requiring data. Dense networks can need more than six labels. A clique of seven mutual friends, for example, needs seven distinct labels and has $P_G(6)=0$.

## Friendship graphs: triangles around a hub

The most vivid exact example is the **friendship graph** $F_n$, also called a windmill graph. It consists of $n$ triangles sharing one common central vertex. Each triangle contributes two outer vertices, and those two are joined to one another as well as to the hub. Different outer pairs have no edges between them.

This geometry makes the count transparent. With $k$ labels, first choose the hub’s label in $k$ ways. In each triangle, the first outer vertex has $k-1$ choices because it must differ from the hub. The second outer vertex has $k-2$ choices because it must differ from both the hub and its partner. The $n$ outer pairs are independent once the hub is fixed. Therefore

$$
P_{F_n}(k)=k(k-1)^n(k-2)^n
=k\bigl((k-1)(k-2)\bigr)^n.
$$

At the minimum admissible palette $k=3$, this becomes

$$
P_{F_n}(3)=3\cdot 2^n.
$$

There are three choices for the hub. In every triangle, the outer pair must use the other two labels, but their order can be swapped, producing two independent choices per triangle.

At the six-emotion palette,

$$
P_{F_n}(6)=6\cdot 20^n,
$$

because each outer pair has $5\cdot 4=20$ ordered choices after the hub is labeled.

We obtain the complete profile.

> **Friendship-Network Profile.** For every integer $n\ge 0$, the friendship graph $F_n$ has emotional chromatic number
> $$
> \tau_E(F_n)=3.
> $$
> It has exactly
> $$
> 3\cdot 2^n
> $$
> proper assignments at its minimum admissible palette and exactly
> $$
> 6\cdot 20^n
> $$
> assignments from a six-label palette.

The ratio between these counts is

$$
\frac{6\cdot 20^n}{3\cdot 2^n}=2\cdot 10^n.
$$

Every new triangle multiplies the minimum-palette count by $2$, but multiplies the six-palette count by $20$. Additional palette richness therefore creates an exponential explosion in global assignments even though the minimum required palette remains fixed at three.

## Geometry becomes combinatorial entropy

The friendship formula exposes a broader principle. Network geometry controls not only feasibility but abundance. Two networks can share the same emotional chromatic number while having radically different numbers of valid assignments. The threshold tells us when solutions begin; the polynomial tells us how much room there is above the threshold.

This distinction resembles the difference between knowing that a scheduling problem has a solution and knowing how many schedules are available. In frequency assignment, neighboring transmitters must avoid interference. In register allocation, incompatible program variables must occupy different registers. In classroom grouping, participants linked by a conflict relation must receive different groups. In each setting, a threshold answers “how many categories are necessary?” while a chromatic evaluation answers “how many configurations remain?”

The emotional metaphor makes these two questions intuitive. A network may require only three categories but permit millions of six-category assignments. Minimal diversity and available diversity are different statistics.

## From exact formulas to testable questions

For arbitrary graphs, evaluating the chromatic polynomial can be computationally demanding. Yet the threshold theorem suggests several practical strategies. To test whether six labels suffice, one need not calculate the entire polynomial; a graph-coloring search at $k=6$ is enough to determine positivity. To find the emotional chromatic number, test $k=3,4,5,\ldots$ until the first successful palette appears. For structured families such as friendship graphs, closed formulas replace search entirely.

A study of $100$ observed social networks could report the distribution of $	au_E(G)$ and the fraction lying in the interval from $3$ through $6$. Such a study would test an empirical claim, not a universal theorem. It would also need to state how friendship edges were defined, how large the networks were, and whether the networks contained dense cliques or other obstructions.

The mathematics supplies a clean measurement framework. It does not pretend that human emotions literally behave like mutually exclusive graph colors. Rather, it offers a rigorous model of constrained labeling and a memorable language for distinguishing impossibility, minimal feasibility, and abundance.

## The first positive note

The deepest idea here is simple enough to hear as a musical change. For admissible palette sizes, the chromatic count is silent—zero, zero, zero—until the network can finally be labeled. Then the first positive value sounds. That first positive note is the emotional chromatic number.

For friendship windmills, it sounds immediately at three, with $3\cdot 2^n$ possible harmonies, and swells at six to $6\cdot 20^n$. For general networks, the same threshold law remains: existence is positivity, minimality is a preceding interval of zeros, and six emotions suffice exactly when the count at six is positive.

A polynomial that began as a device for coloring maps thus becomes a profile of constrained diversity. Its roots mark forbidden palette sizes. Its first positive admissible value marks the threshold. Its later values measure the widening landscape of choice.