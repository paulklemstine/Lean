# The Coloring That Guarantees a Fixed Point: From a Children's Puzzle to the Foundations of Game Theory

## A rumor about coffee

There is a famous piece of mathematical folklore. Take your cup of coffee, stir it however you like — swirl it, slosh it, spin it gently or violently — and then let it settle. The claim is that, no matter how you stirred, at least one molecule of coffee has ended up exactly where it started.

This is not a trick of language. It is a theorem, and it is one of the most consequential facts in all of mathematics: **Brouwer's fixed point theorem**. Stated cleanly, it says that any continuous way of moving the points of a solid disk (or a ball, or a filled triangle) back into itself must leave at least one point unmoved. Stir as you like; something stays put.

What makes the theorem astonishing is *that it is true at all*. The stirring map can be wild. There is no formula for where the fixed point is. The theorem simply promises, against all intuition, that one exists.

This article is about a second astonishment: that this deep, continuous, topological fact has a hidden combinatorial heart — a fact about *coloring the corners of triangles*. The bridge is a gem called **Sperner's lemma**, and walking across that bridge takes us, in the end, to the theorem that founded modern economics: every game has an equilibrium.

## The triangle game

Forget continuity for a moment. Forget coffee. Here is a puzzle you could give to a clever child.

Draw a big triangle. Label its three corners with three colors: corner $A$ is **red**, corner $B$ is **green**, corner $C$ is **blue**. Now chop the big triangle into many small triangles, however you like — a fine mesh of little triangular tiles. You must now color *every* vertex in this mesh with one of the three colors, but you have to obey two boundary rules:

1. A vertex sitting on the edge between two corners may only use one of *those two* colors. (A point on the red–green edge $AB$ may be red or green, but never blue.)
2. The three original corners keep their original colors.

The interior vertices? Color them any way you please. Total freedom.

Now the question: **must there exist a tiny triangle whose three corners show all three colors — one red, one green, one blue?**

The answer, proven by Emanuel Sperner in 1928, is *yes, always*. In fact something stronger is true: the number of such "rainbow" triangles is always **odd**, so in particular it can never be zero. No matter how cunningly you color the interior, you cannot avoid creating a fully-colored cell.

This is **Sperner's lemma**. It is purely combinatorial — it is about colors and corners and counting, with not a whiff of continuity or limits. A grade-schooler can verify it on a small example. And yet, as we shall see, it secretly *is* Brouwer's fixed point theorem in disguise.

## Why the rainbow triangle cannot escape

The classical proof of Sperner's lemma is a small marvel of "follow the corridor" reasoning, and it is worth seeing because the same idea reappears as an *algorithm* later.

Call an edge of a small triangle a **door** if its two endpoints are colored red and green. Now play a game: walk through the mesh by passing through doors. Count, for each small triangle, how many doors it has. A little case-checking shows:

- A *rainbow* triangle (red, green, blue) has exactly **one** door.
- A triangle using only red and green (any combination) has **zero or two** doors.
- Any other triangle has zero doors.

So a triangle is rainbow **exactly when it has an odd number of doors** (namely one). Now think of doors as connecting rooms; the "rooms" are the little triangles plus one "outside" room beyond the big triangle's boundary. The number of doors on the *outer boundary* of the big triangle turns out to be odd — this is the one-dimensional version of the same lemma, applied to the red–green edge $AB$. A classical parity argument (every interior door is shared by exactly two rooms, so it cannot change the global parity) then forces the number of rainbow triangles to be odd. Odd numbers are never zero. The rainbow triangle is inescapable.

This door-counting argument is not a curiosity — it is constructive. Start outside, walk in through a boundary door, and keep walking: each room you enter either is a rainbow triangle (you have found your prize) or has exactly one other door to leave by. You can never get stuck, and you can never revisit a room, so the path must terminate — at a rainbow triangle. This is the seed of the **Scarf algorithm** for actually computing fixed points, which we return to at the end.

## Building the bridge to Brouwer

Now we connect the two worlds. Suppose we have a continuous map $f$ that takes the filled triangle into itself. We want to find a point that $f$ leaves fixed. Here is the trick that turns *analysis* into *coloring*.

Every point of the triangle can be written in **barycentric coordinates** $v = (v_0, v_1, v_2)$ with $v_0, v_1, v_2 \ge 0$ and $v_0 + v_1 + v_2 = 1$. These are the three "weights" telling you how much of each corner you are. The set of all such points is what mathematicians call the **standard simplex**,
$$\Delta = \{\, v = (v_0,\dots,v_n) : v_i \ge 0,\ \textstyle\sum_i v_i = 1 \,\},$$
written here for a general dimension $n$; the filled triangle is the case $n=2$, a line segment is $n=1$, a tetrahedron is $n=3$.

Apply the map $f$ to a point $v$ and look at the result $f(v) = (f(v)_0, \dots, f(v)_n)$. Both $v$ and $f(v)$ are weight-vectors summing to $1$. Now ask: as we move from $v$ to $f(v)$, which weights went *down* (or stayed the same)? Since both sets of weights sum to exactly $1$, if some coordinates increased, others *must* have decreased to compensate. More precisely, among the coordinates that are actually present (where $v_i > 0$), at least one must satisfy $f(v)_i \le v_i$ — it could not have grown. This is the first formal result on which everything rests:

> **The Descent Coordinate Lemma.** *For every point $v$ of the simplex and every continuous self-map $f$, there is a coordinate $i$ with $v_i > 0$ and $f(v)_i \le v_i$.*

The proof is a one-line accounting argument: if *every* present coordinate strictly increased, the total weight would exceed $1$, contradicting $\sum_i f(v)_i = 1$. (In the formalization this is the lemma `label_exists`.)

This lemma is the secret handshake between continuity and combinatorics. It tells us how to **color** each point: give the point $v$ the color $i$ of one of its descent coordinates. Because a descent coordinate always has $v_i > 0$, a point on the face where coordinate $i$ is absent (where $v_i = 0$) is *never* colored $i$. And that is *exactly* the boundary rule of Sperner's lemma! The coloring induced by the map $f$ is automatically a legal Sperner coloring.

## Squeezing out the fixed point

Now we let Sperner do the heavy lifting. Lay a fine triangular mesh over the simplex — formally, the vertices of the $m$-th subdivision are the lattice points $k = (k_0, \dots, k_n)$ of non-negative integers with $k_0 + \dots + k_n = m$, placed at $\big(\tfrac{k_0}{m}, \dots, \tfrac{k_n}{m}\big)$. Color each lattice vertex by one of its descent coordinates, as above. This is a legal Sperner coloring, so Sperner's lemma hands us a **rainbow cell**: a tiny simplex of $n+1$ vertices that, between them, display *all* $n+1$ colors.

Here is the payoff. The rainbow cell contains, for *every* color $i$, some vertex $p_i$ that was colored $i$ — meaning $f$ did not increase $p_i$'s $i$-th coordinate: $f(p_i)_i \le (p_i)_i$. And because all $n+1$ of these vertices lie in one tiny cell, they are crammed within a distance of about $1/m$ of one another. This is the content of the central approximation result:

> **The Approximation Lemma.** *At every subdivision level $m \ge 1$, there is a base point $x$ and, for each color $i$, a vertex $p_i$ within $1/m$ of $x$ in every coordinate, such that $f(p_i)_i \le (p_i)_i$.*

(This is the lemma `approx`, built directly on the assumed Sperner's lemma and the descent coloring.)

Now refine the mesh: take $m = 1, 2, 3, \dots$, ever finer. The simplex is **compact** — a closed, bounded region — so the sequence of base points $x^{(m)}$ has a subsequence converging to some limit point $x^\star$. Because each $p_i^{(m)}$ is squeezed within $1/m$ of $x^{(m)}$, and $1/m \to 0$, *all* of the $p_i^{(m)}$ converge to the same limit $x^\star$ as well. (This squeezing is the small but essential lemma `tendsto_of_close`.)

Now pass to the limit in the inequality $f(p_i^{(m)})_i \le (p_i^{(m)})_i$. The left side, by **continuity of $f$**, tends to $f(x^\star)_i$; the right side tends to $x^\star_i$. So for *every* coordinate $i$ simultaneously,
$$f(x^\star)_i \le x^\star_i.$$

And here the simplex springs its final trap. We have a point $f(x^\star)$ that is coordinatewise *less than or equal to* $x^\star$ — yet both are legitimate weight-vectors summing to $1$. If even one coordinate were strictly smaller, the total would fall below $1$. So no coordinate can be strictly smaller; equality must hold everywhere:

> **The Pinning Lemma.** *Two points of the simplex that are coordinatewise comparable ($x_i \le y_i$ for all $i$) must be equal.*

(This is `eq_of_le_on_stdSimplex`.) Applying it, $f(x^\star) = x^\star$. We have found our fixed point. Stirring the coffee, $x^\star$ is the molecule that did not move.

> **Sperner $\Rightarrow$ Brouwer.** *Granting Sperner's lemma, every continuous map of the standard simplex into itself has a fixed point.*

(In the formalization this capstone is `sperner_implies_brouwer`.) Notice what just happened: a fact about *coloring corners and counting* produced a fact about *every continuous deformation of a solid shape*. The discrete implies the continuous.

## From fixed points to the founding theorem of game theory

Why should anyone outside topology care? Because fixed points are where **equilibrium** lives.

In 1950, John Nash proved that every finite game — any number of players, each with finitely many strategies — has at least one **equilibrium**: a way for everyone to (possibly randomly) choose their strategies so that *no single player can improve their expected payoff by unilaterally switching*. This single theorem underwrites modern economics, auction design, evolutionary biology, network routing, and the cold logic of nuclear deterrence. It is no exaggeration to call it the central theorem of the social sciences.

Nash's proof is, at its core, a fixed-point argument. Each player has a set of **mixed strategies** — probability distributions over their options — and the joint space of all players' mixed strategies is precisely a product of simplices, itself essentially a simplex. Nash built a continuous map on this space that nudges each player toward better responses: strategies that are currently underperforming get less weight, strategies that beat the current average get more. A point left *unmoved* by this nudging map is one where no one wishes to move — exactly a Nash equilibrium. Brouwer's theorem guarantees such a fixed point exists. Game over: every game has an equilibrium.

So the chain is complete, and it runs *downhill from the discrete*:
$$\textbf{Coloring triangles (Sperner)} \;\Longrightarrow\; \textbf{Fixed points (Brouwer)} \;\Longrightarrow\; \textbf{Equilibria (Nash)}.$$

The deepest existence theorem of economics rests, ultimately, on the impossibility of three-coloring a subdivided triangle without making a rainbow.

## Equilibrium you can actually compute

There is a final, practical twist. Most existence proofs are maddeningly non-constructive — they promise a thing exists while giving no recipe to find it. But Sperner's proof, recall, came with the **door-walking algorithm**: start outside, walk through doors, and you are *guaranteed* to arrive at a rainbow cell.

H. Scarf realized in the 1960s that this very walk can be run on the descent-coloring of a game's strategy simplex. The result is a genuine algorithm — the **simplicial / Scarf algorithm** — that *computes* approximate equilibria by following a combinatorial path from cell to cell, refining the mesh to sharpen the answer. For a two-player game with a total of $N$ pure strategies on a grid of mesh $1/m$, a single sweep visits on the order of $m^{N}$ cells, and the approximation error in each player's payoff shrinks in proportion to the mesh size. As the grid tightens, the approximate equilibria converge to a true one.

In other words, the same children's-puzzle reasoning that *proves* equilibria exist also *finds* them. The companion code with this article does exactly this: it verifies Sperner's lemma on small triangulations, follows the door-walk to a rainbow cell, uses that machinery to pin down fixed points of explicit maps, and computes Nash equilibria of small games — recovering, for instance, the textbook mixed equilibrium of Matching Pennies, the game with no equilibrium in pure strategies.

## The moral

Mathematics is full of secret passageways between rooms that look unrelated. A puzzle about coloring corners; a rumor about coffee; the strategy of a poker player. They are, beneath the surface, the same fact wearing three costumes. Sperner's combinatorial lemma is the plainest of the three — you can check it by hand — and yet from it tumble out the fixed point theorems of topology and the equilibria of game theory.

There is something deeply reassuring in this. The grand existence theorems that the social sciences lean on are not articles of faith; they are consequences of a fact so concrete a child can color it in. Stir the coffee all you like. Somewhere in the cup, the math is standing perfectly still.
