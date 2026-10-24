# Counting Arrangements Up to Symmetry: The Multiplicative Hierarchy

*How cutting a list in two explains a family of inequalities, and why the most natural guess about them is false.*

---

## A seating puzzle

Four friends arrive at a square table with one chair on each side. Before anyone sits, the host asks a different question: in how many *genuinely different* ways can she pick out an ordered list of seats, say a first, a second and a third chair, if two lists count as the same whenever a rotation or reflection of the table turns one into the other?

Without the symmetry the count is easy. There are $4$ choices for the first chair, $3$ for the second and $2$ for the third, so $4\cdot 3\cdot 2 = 24$ ordered lists. The symmetries of the square glue many of these together. The square has $8$ symmetries ($4$ rotations and $4$ reflections), and once three distinct corners are fixed, no symmetry other than the identity leaves all three in place. So the $24$ lists fall into groups of exactly $8$, and there are $24/8 = 3$ genuinely different ones.

For lists of length two the count changes in character. There are $12$ ordered pairs of distinct chairs, and they come in exactly two kinds: the two chairs are *adjacent*, or they are *opposite*. So the number of different pairs is $2$, not the $12/8 = 1.5$ that naive division would predict. Division fails here because some symmetry fixes both chairs of an opposite pair: the reflection through the diagonal on which they lie.

Mathematicians write these counts as a sequence:

$$t_0, \; t_1, \; t_2, \; t_3, \; t_4 \;=\; 1,\; 1,\; 2,\; 3,\; 3 \qquad\text{(the square table)}.$$

Here $t_r$ is the number of essentially different ordered lists of $r$ distinct seats. ($t_0 = 1$ counts the empty list, and $t_4 = t_3$ because the last chair is forced once three are chosen.) This article is about the hidden structure of such sequences. Our two questions are how fast they must grow and what controls them.

## The general setting

Replace the table by any finite set $X$ with $n$ elements. Replace its symmetries by any group $G$ of permutations of $X$. An *injective $r$-tuple* is an ordered list $(x_1, \dots, x_r)$ of $r$ distinct elements of $X$. The group moves such lists around entry by entry, sending $(x_1,\dots,x_r)$ to $(g x_1, \dots, g x_r)$. Two lists are equivalent when some element of $G$ carries one to the other, and the equivalence classes are called **orbits**. The number of orbits is the **spectrum**:

$$t_r \;=\; \#\{\text{orbits of } G \text{ on injective } r\text{-tuples of } X\}.$$

The spectrum is a fingerprint of how symmetric the action is.

* If $G$ does nothing (the *trivial action*), no lists are glued together and $t_r = n(n-1)\cdots(n-r+1)$. This product is the **falling factorial**, written $n^{\underline{r}}$.
* If $G$ is the full symmetric group, every list of length $r$ can be carried to every other, and $t_r = 1$ for every $r \le n$.
* Interesting groups lie in between: rotations of a polygon, symmetries of a cube, automorphisms of a graph or a code.

The number $t_1$ deserves its own name: it is the number of orbits on single points, that is, the number of "kinds" of point. It turns out to control the whole sequence.

## The key idea: cut the list in two

Take an injective list of length $r+s$ and cut it after the $r$-th entry:

$$(\underbrace{x_1, \dots, x_r}_{u}, \underbrace{x_{r+1}, \dots, x_{r+s}}_{v}).$$

The head $u$ is an injective $r$-tuple. The tail $v$ is an injective $s$-tuple whose entries all **avoid** the entries of $u$. Forgetting the tail turns lists of length $r+s$ into lists of length $r$, and this commutes with the symmetries: moving a list and then cutting it gives the same result as cutting it and then moving the head.

Geometers call a map like this a **fibration**: a big space projected onto a smaller one, with a "fibre" sitting over each point downstairs. Here the downstairs points are orbits of heads. The fibre over a head $u$ consists of all tails that can follow it. We want to count big orbits, and the question is how many of them sit over a given orbit of heads.

The answer is clean. Fix a head $u$. The only symmetries that can still act on its possible tails without disturbing $u$ are those that fix every entry of $u$. These form the **stabiliser** of $u$, written $\mathrm{Stab}(u)$. Two lists with head $u$ lie in the same big orbit exactly when some element of $\mathrm{Stab}(u)$ carries one tail to the other. This gives the first main result.

> **The Exact Fibration Formula.** For every $r$ and $s$,
> $$t_{r+s} \;=\; \sum_{[u]} \#\Big(\text{orbits of } \mathrm{Stab}(u) \text{ on injective } s\text{-tuples avoiding } u\Big),$$
> where the sum runs over the $t_r$ orbits $[u]$ of injective $r$-tuples, with one representative $u$ chosen from each.

The square table shows the formula at work. With $r = 1$ there is one orbit of heads, since all corners look alike. Fix corner $0$. Its stabiliser has two elements: the identity, and the reflection through the diagonal from corner $0$ to the opposite corner $2$. That reflection swaps corners $1$ and $3$. The $6$ ordered pairs drawn from the remaining corners $\{1,2,3\}$ are therefore paired up by the reflection, giving $3$ stabiliser-orbits. The formula predicts $t_3 = 3$, which agrees with the count by hand.

## From the exact formula to a hierarchy of inequalities

An exact formula is valuable, but stabilisers can be complicated, and one would like bounds that use only the spectrum itself. Two such bounds follow almost at once.

**The upper bound.** A group cannot create orbits: at best it leaves every tail in its own orbit. There are $(n-r)^{\underline{s}}$ injective $s$-tuples avoiding a given head, so each summand is at most that number.

**The lower bound.** Different orbits of the *whole group* $G$ remain different under the smaller group $\mathrm{Stab}(u)$. So each summand is at least the number of $G$-orbits of $s$-tuples that contain *some* list avoiding $u$. Call this number the **avoidance count** $a([u], s)$. For $s = 1$ it is easy to estimate. There are $t_1$ kinds of point, and the $r$ entries of $u$ occupy at most $r$ of those kinds. Every other kind lies wholly outside $u$. Hence

$$a([u], 1) \;\ge\; t_1 - r .$$

That gives one step, $t_{r+1} \ge t_r\,(t_1 - r)$. Repeating the step, with $t_1 - r$ decreasing by one each time, gives the second main result.

> **The Multiplicative Hierarchy (Sandwich Theorem).** For every action of a group on a finite set of size $n$ and all $r, s \ge 0$,
> $$t_r \cdot (t_1 - r)^{\underline{s}} \;\le\; t_{r+s} \;\le\; t_r \cdot (n - r)^{\underline{s}} .$$

(When $t_1 < r$, read $t_1 - r$ as $0$, so the left side is simply $0$.)

The case $r = 0$ is already worth noting: $t_s \ge t_1(t_1 - 1)\cdots(t_1 - s + 1)$. If your points come in $k$ kinds, there are at least as many different arrangements of $s$ points as there are ordered selections of $s$ distinct kinds, because points of different kinds can never be confused. The hierarchy extends this simple fact to every intermediate level.

## Both bounds are best possible

A bound is only as good as the examples that attain it. Both halves of the sandwich are attained.

**Trivial actions attain the lower bound.** If $G$ fixes everything, then $t_1 = n$ and $t_r = n^{\underline{r}}$. The lower and upper bounds coincide, and both reduce to the identity $n^{\underline{r+s}} = n^{\underline{r}}\,(n-r)^{\underline{s}}$, which says that choosing $r+s$ seats in order means choosing the first $r$ and then $s$ more.

**Free actions attain the upper bound.** Suppose no symmetry other than the identity fixes an injective $r$-tuple. Rotations of a polygon are an example for every $r \ge 1$. Then every stabiliser in the fibration formula is trivial, no tails are ever glued, and

$$t_{r+s} \;=\; t_r \cdot (n - r)^{\underline{s}}.$$

For the $6$ rotations of a hexagon, the spectrum is $1, 1, 5, 20, 60, 120, 120$, and with $r = 1$ the upper bound $1 \cdot 5^{\underline{s}}$ is attained for every $s$. The full symmetry group of the hexagon, which adds $6$ reflections, gives $1, 1, 3, 10, 30, 60, 60$. That lies strictly between the two bounds, because reflections do fix some pairs of vertices.

## The tempting guess, and why it fails

Look again at the one-step inequality $t_{r+1} \ge t_r\,(t_1 - r)$. It invites an obvious generalisation: replace the "$1$" by any $s$ and conjecture

$$t_{r+s} \;\overset{?}{\ge}\; t_r \cdot (t_s - r).$$

The intuition is that the head $u$ "uses up" at most $r$ of the $t_s$ kinds of tail. This guess was the original coarse form of the conjecture, and it is **false**.

The smallest counterexample has no symmetry at all. Let the trivial group act on three points, and take $r = 1$, $s = 2$. Then $t_1 = 3$, $t_2 = 6$ and $t_3 = 6$, and the guess would require

$$6 \;\ge\; 3 \cdot (6 - 1) \;=\; 15,$$

which is absurd. The flaw in the intuition is that a single head point does not spoil only one kind of pair. It spoils *every* pair that uses it, and there are four such pairs: $(p, \cdot)$ and $(\cdot, p)$, two of each. Failures are not confined to trivial groups either. For the five rotations of a pentagon with $r = 2$ and $s = 3$, the spectrum gives $t_5 = 24$ while the guess demands $t_2(t_3 - 2) = 4 \cdot 10 = 40$.

The repair follows from the diagnosis. The orbits of $s$-tuples that are "spoiled" by $u$ consist entirely of tuples that meet $u$, and the number of injective $s$-tuples meeting $u$ is exactly $n^{\underline{s}} - (n-r)^{\underline{s}}$, all of them minus those that avoid $u$. Different orbits are disjoint, so at most that many orbits are spoiled.

> **The Repaired Coarse Inequality.** For all $r, s$,
> $$t_{r+s} \;\ge\; t_r \cdot \Big(t_s - \big(n^{\underline{s}} - (n-r)^{\underline{s}}\big)\Big).$$

When $s = 1$ the correction $n - (n - r)$ equals $r$, and the one-step inequality returns. So the naive guess was right for $s = 1$ and wrong for larger $s$, and the repaired form shows the correct correction term in general.

## Why bother? Connections beyond counting

Orbits of injective tuples come up in many places.

* **Transitivity in group theory.** A group is called *$k$-transitive* when it can carry any list of $k$ distinct points to any other; in our language, $t_k = 1$. The Mathieu groups, among the most famous exceptional objects in mathematics, are prized for being $4$- and $5$-transitive. The spectrum $t_r$ measures *how far* a group is from being $r$-transitive, level by level, and the sandwich theorem limits how that distance can change from one level to the next.
* **Chemistry and combinatorial enumeration.** Counting molecules or colourings "up to symmetry" is the classical domain of Burnside's lemma and Pólya theory. Ordered lists of distinct sites are the labelled substructures of such problems, and the fibration formula breaks their count into pieces indexed by smaller substructures.
* **Model theory and oligomorphic groups.** For infinite structures with finitely many orbits on $r$-tuples for each $r$, the growth rate of the orbit-counting sequence is a central invariant. The finite inequalities here are of the same kind as the growth constraints studied in that setting.
* **Computation.** The sandwich theorem gives instant upper and lower estimates for orbit counts that would otherwise require enumerating a group and its action on an exponentially large set of tuples.

## The shape of the argument

The whole development rests on one idea used three times.

1. **Cut.** Splitting a list into head and tail organises the orbits of long lists over the orbits of short ones.
2. **Count the fibres exactly.** Over each head, the big orbits are the stabiliser-orbits on avoiding tails. That is the exact fibration formula.
3. **Estimate the fibres.** Each fibre count lies between the number of whole-group orbits that can avoid the head and the total number of avoiding tails. That gives the sandwich, the iterated hierarchy and the repaired coarse inequality.

The first step is the simplest. Once the problem is seen as a fibration, with long lists sitting over short ones and stabilisers acting on the fibres, the remaining results follow from short estimates on each fibre.

## Open doors

Several natural questions remain.

* **A Burnside formula for each fibre.** An element of $\mathrm{Stab}(u)$ fixes all $r$ entries of $u$, so it should fix exactly $\mathrm{fix}(h) - r$ points away from $u$. Averaging over the stabiliser should then express each fibre count as $\frac{1}{|\mathrm{Stab}(u)|}\sum_{h} (\mathrm{fix}(h) - r)^{\underline{s}}$, and summing over orbits should recover the classical formula $|G|\, t_{r+s} = \sum_{g} \mathrm{fix}(g)^{\underline{r+s}}$.
* **When is the upper bound attained?** Free stabilisers suffice. It is conjectured that, for $s \ge 1$, equality holds exactly when each stabiliser acts freely on the tails that avoid its head.
* **Rigidity of the lower bound.** It is conjectured that equality in the lower bound at *every* level forces the action to be trivial. For transitive actions ($t_1 = 1$) the lower bound is empty as soon as $r \ge 1$, and there the exact formula and the upper bound carry the information.

Counting arrangements up to symmetry is an old subject. Cutting a list in two still gives a clear account of how the counts at different lengths constrain one another, and it shows exactly where the most natural guess goes wrong.
