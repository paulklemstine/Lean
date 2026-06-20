# Six Friends, One Guarantee: The Hidden Order Inside Every Crowd

## A party trick that never fails

Invite six people to a party. Look at every pair among them and ask a single
question: do these two already know each other, or are they strangers? Color the
link between every pair of guests **red** if they are acquaintances and **blue**
if they are strangers. You now have a tangle of fifteen colored links crisscrossing
the room.

Here is a claim that sounds far too strong to be true: no matter who you invited,
no matter how the friendships happen to fall, somewhere in that room there are
**three people who are all mutual acquaintances, or three people who are all mutual
strangers**. A monochromatic triangle is unavoidable. You cannot design a guest
list to dodge it.

Try it with five people and you *can* dodge it. With six, you never can. That sharp
jump from "possible to avoid" to "impossible to avoid" is the smallest visible
crack of one of the most beautiful ideas in modern mathematics: **complete disorder
is impossible**. This is Ramsey theory, and this article is about a fully verified,
machine-checked account of its first landmark facts — including the exact statement
that six is the magic number, and a clean, general bound that controls how the magic
number grows as we ask for larger and larger monochromatic groups.

## Turning a party into a graph

To reason carefully, mathematicians replace the party with a **complete graph**. Put
a dot (a *vertex*) for each guest, and draw a line (an *edge*) between every pair of
dots. A two-coloring paints each edge red or blue. A set of vertices where *all*
internal edges share the same color is called a **monochromatic clique**: a red
clique is a group of mutual acquaintances, a blue clique a group of mutual strangers.

The central object of the whole theory is a relation that combinatorialists write
compactly as
$$ n \to (s, t). $$
Read it aloud as: "$n$ arrows $(s,t)$." It means that *every* red/blue coloring of a
complete graph on at least $n$ vertices is forced to contain a red clique of size $s$
**or** a blue clique of size $t$. There is no escape coloring.

In the verified development, this is captured by a predicate `Arrows n s t`. Crucially,
it is stated not just for one fixed graph but for *any* vertex set $W$ with at least
$n$ vertices: for every coloring $G$ (the red edges) of $W$, there is either a red
$s$-clique inside $W$ or a blue $t$-clique inside $W$ (a blue clique being a clique in
the complement coloring $G^{c}$). Phrasing it over arbitrary vertex sets bakes in a
small but vital fact for free: if the guarantee holds at threshold $n$, it still holds
for any larger crowd $n' \ge n$. More people can only make a forced pattern *more*
forced, never less. This monotonicity — `Arrows.mono` in the formal text — is the
quiet backbone of everything that follows.

## The number that started it all

Define the **Ramsey number** $R(s,t)$ to be the smallest crowd size $n$ for which the
guarantee $n \to (s,t)$ holds. By definition it is the exact tipping point: at
$R(s,t)$ guests a monochromatic red-$s$ or blue-$t$ group is unavoidable, and at one
fewer guest you can still arrange the colors to avoid both.

The party puzzle is the assertion
$$ R(3,3) = 6, $$
and proving it cleanly requires two completely different kinds of argument, like
proving a high jump record requires both clearing the bar once and showing nobody
ever cleared it higher.

## Why six always works

The "six is enough" half is a small marvel of pigeonhole reasoning. Pick any one
guest — call her Alice. Alice has five links to the other five people, each red or
blue. Five links in two colors: by the pigeonhole principle at least three of them
share a color. Say three are red, connecting Alice to Bob, Carol, and Dave.

Now look only at the triangle Bob–Carol–Dave. If *any* edge among them is red — say
Bob–Carol — then Alice, Bob, Carol form a red triangle and we are done. If *none* of
their three edges is red, then Bob, Carol, Dave form a blue triangle and we are done.
Either way a monochromatic triangle appears. (If the three same-colored links from
Alice were blue instead of red, swap the words and the identical argument works.)

This little case split is exactly the shape of the general engine that drives the
whole theory, which we meet next.

## The recursion that tames every Ramsey number

The genius of Frank Ramsey's successors Paul Erdős and George Szekeres was to see the
Alice argument as a *recursion*. Suppose you already know two facts about smaller
problems:
$$ m \to (s, t+1) \qquad \text{and} \qquad n \to (s+1, t). $$
Then they proved the combined guarantee
$$ (m + n) \to (s+1, t+1). $$

The proof is the Alice argument grown up. Take any coloring of a crowd of at least
$m+n$ people and single out one vertex $v$. Split everyone else into the people joined
to $v$ by a **red** edge (call them $R$) and those joined by a **blue** edge (call them
$B$). Together $R$ and $B$ account for all the remaining $m+n-1$ vertices, so by
pigeonhole either $|R| \ge m$ or $|B| \ge n$.

Suppose $|R| \ge m$. Apply the first guarantee $m \to (s, t+1)$ inside $R$. It hands us
either a blue $(t+1)$-clique — which already lives in the full graph, so we are finished
— or a red $s$-clique. But every vertex in $R$ is joined to $v$ in red, so gluing $v$
onto that red $s$-clique produces a red $(s+1)$-clique. The case $|B| \ge n$ is the
mirror image, building a blue $(t+1)$-clique by attaching $v$. This is the formally
verified lemma `arrows_step`, and it is the heart of the machine.

To kick the recursion off you need the simplest possible facts, the base cases. A
single person is, all by themselves, a "group of mutual acquaintances of size one" and
also a "group of mutual strangers of size one." Formally, one vertex is both a red
$1$-clique and a blue $1$-clique, giving
$$ 1 \to (1, t) \quad\text{and}\quad 1 \to (s, 1) $$
for all $s$ and $t$ — the lemmas `arrows_one_red` and `arrows_one_blue`.

## A clean formula for the worst case

Feed the base cases into the recursion and turn the crank. The crowd sizes you need
add up exactly the way binomial coefficients do — through **Pascal's rule**
$\binom{s+t}{s} = \binom{s+t-1}{s-1} + \binom{s+t-1}{s}$, the same rule that builds
Pascal's triangle one row from the row above. The payoff is a single, gorgeous,
fully verified bound:
$$ \binom{s+t}{s} \to (s+1,\, t+1), \qquad \text{equivalently} \qquad R(s+1, t+1) \le \binom{s+t}{s}. $$

In its more familiar shifted form this is the celebrated **Erdős–Szekeres bound**
$$ R(s, t) \le \binom{s+t-2}{s-1}. $$

This one inequality controls *every* Ramsey number at once. Want six mutual friends or
six mutual strangers? The bound tells you a finite party size always suffices, and
hands you an explicit ceiling. In the verified text this is the theorem
`arrows_recursion`, restated as `arrows_binomial_bound`.

It also instantly resolves the easy half of the party puzzle. Plug in $s = t = 2$:
$$ R(3,3) \le \binom{4}{2} = 6. $$
Six guests always force a monochromatic triangle — the theorem `arrows_three_three`,
which is literally this special case of the general bound. The hand-tailored "Alice
has five edges" argument and the industrial recursion give the same number, and the
machine confirms both.

## Why five is not enough: the pentagon

A bound only tells half the story. To pin $R(3,3)$ to *exactly* six, we must show five
guests can still escape — that there is a coloring of the complete graph on five
vertices with no red triangle and no blue triangle. The witness is one of the most
elegant objects in combinatorics: the **pentagon**.

Arrange five vertices in a circle, labeled $0,1,2,3,4$. Color an edge **red** exactly
when its endpoints are neighbors around the cycle — $0\!-\!1$, $1\!-\!2$, $2\!-\!3$,
$3\!-\!4$, $4\!-\!0$. These five red edges form a perfect five-pointed ring, the cycle
$C_5$ (the formal definition `pentagon`). The remaining five edges — the ones joining
vertices two steps apart, like $0\!-\!2$ — are **blue**, and they trace out a five-pointed
star. Remarkably, that star is *itself* another pentagon.

Now hunt for a monochromatic triangle. A red triangle would need three pairwise-adjacent
points on a five-cycle, but a cycle of length five contains no triangle at all — pick any
three of its vertices and at least one pair is not adjacent. So there is no red triangle.
By the perfect symmetry between the cycle and its star-shaped complement, there is no
blue triangle either. Both facts are checked exhaustively and certified: the theorems
`pentagon_no_triangle` and `pentagon_compl_no_triangle`. Together they prove
`not_arrows_five_three_three`: the guarantee $5 \to (3,3)$ is **false**, so $R(3,3) > 5$.

Squeeze the two halves together — $R(3,3) \le 6$ from the bound and $R(3,3) > 5$ from
the pentagon — and the tipping point is nailed down with no wiggle room:
$$ R(3,3) = 6. $$

## How big do these numbers get?

Once you accept that the magic number always exists, the natural question is how fast it
grows. Here the story turns humbling. The Erdős–Szekeres bound shows $R(s,s)$ grows at
most like roughly $4^s$. Erdős later showed, by a now-legendary probabilistic argument,
that it grows at least like roughly $2^{s/2}$: a random coloring almost never contains a
large monochromatic clique. So $R(s,s)$ lives somewhere between $2^{s/2}$ and $4^s$ — and
closing that exponential gap has resisted the world's best mathematicians for ninety
years. Only a handful of exact values are known at all. Beyond $R(3,3)=6$ come
$R(3,4)=9$, $R(4,4)=18$, and then a wall: $R(5,5)$ is unknown to this day, pinned only
between 43 and 48. Erdős's famous quip captures the difficulty — if aliens demanded the
value of $R(5,5)$ or they would destroy Earth, we should marshal all our computers to
find it; but if they asked for $R(6,6)$, we had better prepare for war.

What is verified here is the bedrock on which all of that rests: the recursion, the
binomial ceiling that bounds every Ramsey number, and the exact, two-sided determination
of the very first one. Each step — the monotonicity, the inductive gluing of a vertex
onto a smaller clique, the Pascal-rule bookkeeping, and the exhaustive pentagon check —
is a theorem with a complete, machine-checked proof.

## Order out of chaos

The lesson of Ramsey theory reaches far beyond parties. The same forced-pattern
phenomenon explains why large datasets always contain coincidences, why any long enough
sequence of stock movements hides a monotone run, why sufficiently large networks must
contain tightly knit communities, and why "random-looking" structures still obey rigid
laws at scale. The deep moral, in the words the field is built on, is that **total
randomness is impossible**: make any structure big enough and pristine order crystallizes
inside it whether you want it to or not.

That a humble party of six should be the first visible sign of so sweeping a principle is
exactly the kind of surprise that makes mathematics worth doing — and being able to check
every line of the argument by machine makes the surprise something we can trust
completely.
