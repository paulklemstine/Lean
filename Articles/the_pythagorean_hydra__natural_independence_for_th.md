# The Pythagorean Hydra: A Monster Made of Right Triangles

## A tree older than algebra

Everyone meets the triple $(3,4,5)$ in school: three whole numbers with $3^2 + 4^2 = 5^2$, the smallest right triangle whose sides are all integers. Fewer people learn that $(3,4,5)$ is not merely the first such triple — it is the *ancestor of all of them*.

Call a triple $(a,b,c)$ of positive integers **primitive Pythagorean** if
$$a^2 + b^2 = c^2, \qquad \gcd(a,b) = 1,$$
and put the odd leg first (in any primitive triple exactly one leg is odd and the hypotenuse is odd too, so this convention costs nothing). In 1934 the Dutch mathematician B. Berggren discovered something startling. Define three transformations of a triple $(a,b,c)$:
$$
\begin{aligned}
A(a,b,c) &= (\,a - 2b + 2c,\ \ 2a - b + 2c,\ \ 2a - 2b + 3c\,),\\
B(a,b,c) &= (\,a + 2b + 2c,\ \ 2a + b + 2c,\ \ 2a + 2b + 3c\,),\\
C(a,b,c) &= (-a + 2b + 2c,\ -2a + b + 2c,\ -2a + 2b + 3c\,).
\end{aligned}
$$
Each of these sends a primitive triple to a primitive triple. Start at $(3,4,5)$ and apply them in all possible ways, and you get an infinite ternary tree:

$$(3,4,5) \longrightarrow (5,12,13),\ (21,20,29),\ (15,8,17) \longrightarrow \cdots$$

Berggren's theorem is that this tree contains **every** primitive Pythagorean triple, exactly once. The chaotic-looking set of integer right triangles — $(3,4,5)$, $(5,12,13)$, $(8,15,17)$, $(7,24,25)$, $(20,21,29)$, $(9,40,41)$, ... — is secretly a perfectly regular tree in which every node has precisely three children and precisely one parent.

That "precisely one parent" is the interesting half, and it is where our story begins.

## Every triangle knows its way home

Given a primitive triple other than $(3,4,5)$, which of the three moves produced it? Classically one answers with a case analysis, checking three inverse matrices and seeing which one lands back inside the set of triples. There is a cleaner way. Set
$$u = a + 2b - 2c, \qquad v = 2a + b - 2c, \qquad h = 3c - 2a - 2b,$$
and define the **parent** of $(a,b,c)$ to be
$$P(a,b,c) = \bigl(|u|,\ |v|,\ h\bigr).$$

This single formula is the entire descent. Four facts make it work, and each is a short computation with the Pythagorean equation:

* **$u$ is never zero.** Since $a$ is odd, $u = a + 2b - 2c$ is odd.
* **$v$ vanishes only at the root.** If $2a + b = 2c$ and $a^2 + b^2 = c^2$, then $3b = 4a$, so $a = 3t$, $b = 4t$; coprimality forces $t = 1$, giving $(3,4,5)$.
* **$u$ and $v$ are never both negative.** This is a genuine inequality about right triangles, and it is what guarantees that *some* backwards move always applies.
* **The signs name the move.** If $u > 0 > v$ the last move was $A$; if $u, v > 0$ it was $B$; if $u < 0 < v$ it was $C$.

So the absolute values in $P$ are doing something rather elegant: they silently perform the case analysis. The *magnitudes* $|u|, |v|, h$ are the parent's sides; the *sign pattern* of $(u,v)$ is the label of the edge you just walked up. One formula; no cases.

Two more facts complete the picture: the parent of a primitive triple is primitive (the coprimality transfers because $a$ and $b$ are fixed integer combinations of the parent's entries), and — crucially —
$$0 < h < c.$$
The hypotenuse strictly shrinks. Since there is no infinite strictly decreasing sequence of positive integers, iterating $P$ must terminate, and it can only terminate where the descent breaks down: at $(3,4,5)$, the unique primitive triple with hypotenuse at most $5$. That is a complete, self-contained proof of Berggren's classification:

> **Classification.** A triple lies in the tree grown from $(3,4,5)$ by $A$, $B$, $C$ if and only if it is a primitive Pythagorean triple with positive entries and odd first leg.

And because the right-hand condition is an elementary arithmetic test — positivity, one quadratic equation, a gcd, a parity check — membership in the Berggren tree is **decidable**. Hold that thought.

## Addresses

If every triple has a unique parent, every triple has a unique route home, and that route is a word. Let $\mathrm{addr}$ send a word in the letters $A$, $B$, $C$ to a triple by reading it right to left from the root:
$$\mathrm{addr}(\varepsilon) = (3,4,5), \qquad \mathrm{addr}(s\,w) = s\bigl(\mathrm{addr}(w)\bigr).$$
Then $\mathrm{addr}(BB) = B(B(3,4,5)) = B(21,20,29) = (119,120,169)$ — the famous near-isoceles triple.

The parent map is exactly the operation of *deleting the first letter*: $P(\mathrm{addr}(sw)) = \mathrm{addr}(w)$. From this, injectivity follows by an induction that is almost pure bookkeeping: two words with the same triple have, by peeling with $P$, the same tail, and then the same head, because a node's three children are always distinct. Combined with the classification we get:

> **The tree is free.** The address map is a bijection from the set of finite words in three letters onto the set of primitive Pythagorean triples with odd first leg. Its inverse is computed by iterating the parent map and recording the sign patterns.

So a primitive Pythagorean triple *is* a word in a three-letter alphabet, and the dictionary runs both ways by hand-computable arithmetic. This settles, in the negative, a natural hope: one might have wished to hide a Diophantine machine inside the relation "$w$ is the address of $t$" and thereby produce an undecidable theory on a structure as classical as the Pythagorean triples — a Matiyasevich phenomenon on Berggren's tree. There is nothing to hide. The relation is decidable, and worse (for the hopeful), it is *free*: no relations at all hold between the generators, so the structure is as simple as a structure can be.

## Enter the Hydra

The second, more ambitious hope concerned logic's most beautiful family of theorems: the **natural independence results**. Goodstein's theorem and the Kirby–Paris Hydra game are statements about finite, concrete, entirely elementary objects — sequences of integers, or a monster with heads — that are *true*, but *cannot be proved from the axioms of ordinary arithmetic*. They are the sharpest known demonstration that Peano Arithmetic, the formal theory of $+$, $\times$ and induction, does not reach all of finite mathematics.

Kirby and Paris's hydra is a finite rooted tree. Hercules chops a leaf; the hydra retaliates by growing $n$ fresh copies of an entire subtree near the wound. Hercules always wins, no matter how stupidly he plays — but proving so requires assigning to each hydra an ordinal below $\varepsilon_0 = \omega^{\omega^{\omega^{\cdots}}}$ and observing that it strictly decreases. That transfinite bookkeeping is not a convenience; it is *necessary*. The termination of the Kirby–Paris hydra is unprovable in Peano Arithmetic.

Berggren's tree is a well-founded structure with canonical descent. So: is there a **Pythagorean Hydra**?

Here is the natural candidate. A hydra is a finite multiset of heads, each head a primitive Pythagorean triple. Hercules chops one head $t$. The hydra retaliates by growing at most $k$ new heads, each of which must be a **Berggren ancestor** of $t$ — a triple obtained from $t$ by one or more inverse Berggren moves. Regrowth is thus governed by the tree's own geometry, and the only inert head is the root $(3,4,5)$, which has no ancestors at all.

Does Hercules win? Yes — and the proof tells us exactly how strong the game is.

## The potential

Give each head a **level**: its depth $d(t)$ in the Berggren tree, i.e. the length of its address. (Its hypotenuse works too, more crudely.) The descent theorem says ancestors have strictly smaller depth; in fact the parent has depth exactly one less. So the Pythagorean Hydra is an instance of an abstract game: heads carry natural numbers, and a chop replaces one head by at most $k$ heads of strictly smaller number.

For such a game define, for a single head of level $n$,
$$\varphi_k(n) = 1 + k + k^2 + \cdots + k^n,$$
and for a hydra $H$, $\Phi_k(H) = \sum_{t \in H} \varphi_k(d(t))$.

Chop a head of level $m$ and regrow $r \le k$ heads of levels $< m$. The potential loses $\varphi_k(m) = 1 + k\varphi_k(m-1)$ and gains at most $k \varphi_k(m-1)$, because $\varphi_k$ is increasing. Net change: **at least $-1$**. The potential is a natural number, so the battle cannot last longer than $\Phi_k(H)$ moves.

That already proves Hercules wins. But the striking part is the converse. From any non-empty hydra there is always a move dropping the potential by *exactly* one: chop a deepest head and regrow the full complement of $k$ heads at level one less (the parent, repeated — an ancestor is an ancestor however many times you list it), or, at level $0$, regrow nothing. Playing this way, the hydra survives precisely $\Phi_k(H)$ moves and not one more:

> **Length of the Pythagorean Hydra game.** Against a hydra $H$ of Pythagorean heads with branching bound $k$, the longest possible battle has exactly $\Phi_k(H) = \sum_{t \in H} (1 + k + \cdots + k^{d(t)})$ moves. In particular a battle against a single head at depth $d$ lasts exactly $1 + k + \cdots + k^{d}$ moves, hence at most $(k+1)^{d+1}$.

Some concrete numbers. A single head at depth $4$ with branching bound $3$ survives $1+3+9+27+81 = 121$ moves. The root $(3,4,5)$ survives exactly one move: you chop it, nothing regrows, and the fight is over. Measuring levels by the hypotenuse instead of the depth — a legitimate but lossy choice — the same root fight is bounded by $1+3+9+27+81+243 = 364$.

## The verdict: no independence, and exactly why

An exact, elementary formula for the length of the longest battle is the death of any hope of independence. Independence results require the opposite: a termination proof whose *only* witnesses grow faster than every function Peano Arithmetic can prove total. Here the witness is a geometric series. The Pythagorean Hydra's termination is provable by the most modest induction — count down the potential.

Where exactly does the game sit? Even if we allow **unbounded** regrowth (chop one head, grow as many strictly-lower heads as you like), Hercules still always wins: the multiset of levels strictly decreases in the Dershowitz–Manna multiset order, which is well-founded because the natural numbers are. That order has type $\omega^\omega$. And $\omega^\omega$ is exactly right, in the sense that no uniform bound survives: the single head at level $1$ admits, for every $N$, a battle of length $N+1$ — chop it and regrow $N$ heads at level $0$. So the game's ordinal is genuinely infinite, but it is $\omega^\omega$, comfortably inside Peano Arithmetic's reach ($\mathrm{PA}$ proves transfinite induction up to every ordinal below $\varepsilon_0$).

Compare with Kirby–Paris at $\varepsilon_0$. The gap is not an accident of our proof; it is structural. A Kirby–Paris head is a *tree*, and the regrowth rule copies subtrees of unbounded **height** — which is why the ordinals stack up into a tower. A Pythagorean head is a *word*, and its only invariant is a single natural number, its depth. The Berggren tree is, as an ordinal notation, **flat**: one number per head, hence $\omega^\omega$ and no more.

## Descent is the whole story

Two counterexamples make the boundary exact, and both are one line long.

Relax the rule so that a regrown head may keep the *same* level: then the hydra $\{1\}$ can chop its only head and regrow a single head at level $1$, forever. Hercules loses.

Better yet, keep the Pythagorean setting but reverse the direction of regrowth: let the hydra regrow the Berggren **children** of the chopped head instead of its ancestors. Then chopping $(3,4,5)$ and regrowing $(21,20,29)$, then chopping that and regrowing $(119,120,169)$, and so on up the $B$-spine, gives an explicit infinite battle. The hydra never dies.

So the Pythagorean Hydra sits precisely on the boundary: strict Berggren descent is both sufficient and necessary for Hercules to win. Turn the arrows around, or even merely allow them to stall, and termination collapses immediately.

## What we learn

Two natural conjectures fell, and both fell *precisely*, which in mathematics is worth more than a vague success.

The undecidability conjecture fell because the Berggren tree is free and its address map is a computable bijection with a computable inverse — the sign pattern of $(a+2b-2c,\ 2a+b-2c)$ literally spells out the last move. There is no room for a Diophantine machine in a structure that transparent.

The independence conjecture fell because the Berggren tree is flat. Descent gives each triple one number, its depth, and one number per head buys you $\omega^\omega$, not $\varepsilon_0$. What we get instead is a **calibration theorem**: the Pythagorean Hydra terminates, its longest battle is exactly $\sum_{t} (1 + k + \cdots + k^{d(t)})$, its termination is elementary, and any relaxation of descent breaks it.

That calibration is also a map of where to look next. To manufacture height from Pythagorean data one must iterate the construction: the address of a triple is a word, and a word can be re-read as an address, giving triples of triples, and hydras whose heads are Berggren words of Berggren words. That construction climbs to $\omega^{\omega^\omega}$, and iterating it approaches $\varepsilon_0$ from below. A genuine Pythagorean independence result, if it exists, will not come from descent alone. It will come from a rule that builds *height* — and Berggren's tree, alone among elementary number-theoretic structures, hands you the raw material for exactly that: words that are triples that are words.

Meanwhile there is a smaller pleasure to take away. The next time you see $(3,4,5)$, remember that it is not one triangle among many. It is the empty word: the root from which every integer right triangle in existence descends, by a route that its own three sides encode, and that you can read off in a single line of arithmetic.
