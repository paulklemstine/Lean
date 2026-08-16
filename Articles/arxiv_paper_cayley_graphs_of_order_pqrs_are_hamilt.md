# The Knight Who Must Visit Every Room: Hamiltonian Cycles in Cayley Graphs

## A conjecture that refuses to die

Here is a question a child can ask and no mathematician can answer.

Take a finite group $G$ — a set of symmetries that can be composed and undone. Pick a handful of them, say $S = \{s_1, \dots, s_t\}$, and build a map of the group: put a dot for every element $g \in G$, and draw an edge between $g$ and $gs$ whenever $s \in S$. This map is called the **Cayley graph** $\mathrm{Cay}(G,S)$. It is the group's own picture of itself: every vertex looks exactly like every other one, because multiplying on the left by any fixed $x$ slides the whole picture onto itself without distorting a single edge.

Now the question. Can you take a walk that visits every element of $G$ exactly once and returns to where you started? Such a tour is called a **hamiltonian cycle**, after William Rowan Hamilton, who in 1857 sold a puzzle — find such a tour on the dodecahedron — to a London toy dealer for £25.

For Cayley graphs, nobody has ever found an example without one, apart from four small, well-understood exceptions (the Petersen graph and three relatives, none of which is a Cayley graph in the strict sense). The conjecture that **every connected Cayley graph on more than two vertices has a hamiltonian cycle** has stood, in one form or another, for over five decades. It has resisted every general attack. So the field advances the way a besieging army advances: by taking the group orders one at a time.

Orders $p$, $2p$, $3p$, $4p$, $pq$, $p^2q$, $p^3$, $pqr$ … and then $pqrs$: the product of four distinct primes. That is the frontier this article visits. Along the way we will meet a beautiful little machine — the *factor group lemma* — that turns algebra into a closed loop, and we will see exactly why the hardest cases are hard.

## What "connected" means, and why it is the only hypothesis you need

Before hunting for cycles, you need to know when the map is even in one piece. The answer is as clean as it could be:

> **Connectivity Theorem.** $\mathrm{Cay}(G,S)$ is connected if and only if $S$ generates $G$.

The reason is that the set of elements reachable from the identity is closed under multiplication and inversion — it is a subgroup — and it obviously contains $S$. So it contains everything $S$ generates; conversely every walk out of the identity spells a word in $S$ and $S^{-1}$, so it can never escape the subgroup $S$ generates. One more useful triviality: the graph does not care about the direction you traverse an edge, so $\mathrm{Cay}(G,S)$ and $\mathrm{Cay}(G, S \cup S^{-1})$ are literally the same graph. That innocuous remark will later do real work.

And there is one honest caveat. A group of order $2$ has a Cayley graph consisting of a single edge, which is not a cycle. That is why the prime $2$ always has to be handled separately, and why the conjecture is stated for groups of order at least $3$.

## The easy half of the world: one generator that does everything

If $S$ contains an element $a$ whose order equals $|G| = n$, you are done in one line. Walk
$$1,\ a,\ a^2,\ \dots,\ a^{n-1},\ \text{and back to } 1 .$$
Each step multiplies by $a$, so each step is an edge; the powers are distinct because $a$ has order $n$; and the walk closes because $a^n = 1$. This handles every *cyclic* group and, more generally, every connection set that happens to contain a generator.

That already settles a surprising amount. A finite abelian group whose order is **squarefree** — no prime appears twice — is necessarily cyclic. Since $pqrs$ is squarefree, every abelian group of order $pqrs$ is cyclic, and therefore has a generator $a$ such that *any* connection set containing $a$ produces a hamiltonian Cayley graph. The abelian world of order $pqrs$ collapses to a single line of argument.

But that is not the whole abelian world, because a connection set need not contain a generator. Take the abelian group of order $210 = 2 \cdot 3 \cdot 5 \cdot 7$ written as $\mathbb{Z}_{105} \times \mathbb{Z}_2$, and let $S$ consist of $a = (1,0)$ of order $105$ and $b = (0,1)$ of order $2$. Neither generates. Yet the graph is hamiltonian — and to see why, you have to learn to plough a field.

## Ploughing the torus

When $G$ is abelian and splits as $\langle a\rangle \times \langle b\rangle$ with $|a| = m$, $|b| = k$, the Cayley graph on $\{a, b\}$ is a **torus grid**: $k$ rings of $m$ vertices each, the ring $j$ being the coset $\langle a\rangle b^j$, with vertical edges joining ring $j$ to ring $j+1$.

The classical solution is the *boustrophedon*, Greek for "as the ox ploughs": go right along the first row, drop down, come back left along the second, drop down, go right again, and so on. When the number $k$ of rows is even, you end up under your starting point and the cycle closes.

When $k$ is odd, the ox gets stuck — and the classical fix is to use the *wrap-around* of each ring. Here is the sharper way to think about it. Traverse each row *completely*, going all the way around the ring, in a direction $d_j \in \{+1, -1\}$ of your choosing. Traversing ring $j$ in direction $d$ and then stepping down shifts your entry column by $-d$. After all $k$ rings, your total horizontal displacement is $-\sum_{j<k} d_j$, and the tour closes precisely when

$$m \ \Big|\ \sum_{j<k} d_j .$$

This is the **direction-sequence criterion**, and it dissolves the parity problem entirely:

> **Two-Generator Abelian Theorem.** If $G$ is abelian of order $mk$ with $m, k \geq 2$, generated internally by $\langle a\rangle$ of order $m$ and $\langle b\rangle$ of order $k$ meeting trivially, then $\mathrm{Cay}(G,\{a,b\})$ — and any Cayley graph whose connection set contains $a$ and $b$ — is hamiltonian.

*Why:* if $k$ is even, take half the rows in each direction, so the sum is $0$. If $k$ is odd, the sum $\sum d_j$ of $k$ odd terms is odd, so we need $m$ odd too — and then choosing $(k+m)/2$ rows in the positive direction makes the sum exactly $m$. This needs $m \le k$, which we may always arrange by swapping the roles of $a$ and $b$. Applied to $\mathbb{Z}_{105} \times \mathbb{Z}_2$ it gives a hamiltonian cycle through all $210$ vertices, built from a $105$-step ring and a two-row plough.

## The twist: when the group refuses to commute

Now break the symmetry. Suppose $\langle a\rangle$ is *normal* but $b$ does not commute with $a$; instead
$$b\,a\,b^{-1} = a^{e}$$
for some exponent $e$. Groups of this shape — $\langle a \rangle \rtimes \langle b \rangle$ — are called **metacyclic**, and they are exactly the non-abelian groups you meet in orders $pq$ and $pqrs$.

Geometrically, nothing changes: you still have $k$ rings of $m$ vertices. Algebraically, everything twists. Iterating the relation gives $b^{\,j} a^{z} = a^{z e^{j}} b^{\,j}$: inside the $j$-th ring, a step "to the right" no longer shifts your column by $1$ but by $e^{j}$. The ploughing calculation goes through verbatim with this correction, and the closing condition becomes a *geometric* congruence:

> **Twisted Direction-Sequence Criterion.** With $|a| = m$, $|b| = k$, $|G| = mk$, $\langle a\rangle \cap \langle b\rangle = 1$, $b a b^{-1} = a^e$, and signs $d_j \in \{\pm 1\}$, the Cayley graph on any connection set containing $a$ and $b$ is hamiltonian as soon as
> $$m \ \Big|\ \sum_{j<k} d_j e^{\,j} .$$

The beautiful part is what happens when you simply take all signs positive. Then the sum is $1 + e + e^2 + \cdots + e^{k-1}$, and multiplying by $e-1$ telescopes it to $e^k - 1$, which is $\equiv 0 \pmod m$ because conjugating $a$ by $b^k = 1$ must return $a$. So whenever $e - 1$ is invertible modulo $m$ — in particular whenever $m$ is prime and $a, b$ genuinely fail to commute — the constant direction sequence closes the cycle *by itself*. Non-commutativity, usually an obstacle, here does the work for you.

The dihedral groups are the friendliest instance. In the dihedral group of order $2n$, with rotation $a$ of order $n$ and a reflection $b$, the cycle
$$1,\ a,\ a^2,\ \dots,\ a^{n-1},\ a^{n-1}b,\ a^{n-2}b,\ \dots,\ ab,\ b,\ 1$$
sweeps the rotations one way and the reflections back the other. In particular, for distinct odd primes $q, r, s$, the dihedral group of order $2qrs = pqrs$ has a hamiltonian Cayley graph for every connection set containing a rotation of full order and a reflection.

## The factor group lemma: making a loop out of a word

All of these constructions are instances of one principle, the workhorse of the entire subject. Strip away the geometry and here is what remains.

Let $s_0, s_1, s_2, \dots$ be a $k$-periodic sequence of nonidentity elements drawn from $S \cup S^{-1}$, and let
$$P_i = s_0 s_1 \cdots s_{i-1}$$
be its prefix products, so $P_0 = 1$ and each step $P_i \to P_{i+1}$ is an edge. The element $z = P_k$ — the product of one full period — is the **voltage** of the closed walk.

> **Factor Group Lemma.** Suppose $z$ has order $m$, that $|G| = mk$, and that the first $k$ prefix products $P_0, \dots, P_{k-1}$ lie in pairwise distinct cosets of $\langle z\rangle$. Then the walk, run $m$ times around, is a hamiltonian cycle of $\mathrm{Cay}(G,S)$.

The proof is a single identity: periodicity gives $P_{kt+i} = z^{t} P_i$. So the $t$-th lap is the zeroth lap translated by $z^t$; the $k$ distinct cosets are each swept exactly once per lap; after $m$ laps every one of the $mk$ elements has been visited exactly once, and $z^m = 1$ brings you home. The name comes from the usual formulation: a hamiltonian cycle in the quotient group $G/\langle z\rangle$ lifts to a hamiltonian cycle in $G$ provided the voltage generates $\langle z \rangle$ of exactly the complementary order.

Everything above is now a corollary. The abelian plough is the word "$a$ repeated $m$ times, then $b$", read $k$ times, with voltage $a^{-\sum d_j} $. The dihedral cycle is the word "$a$ repeated $n-1$ times, then $b$", with voltage of order $2$.

## The hardest configuration, and how it falls

Now consider a group of order $pq$ with $p < q$. Its Sylow $q$-subgroup $N = \langle a\rangle$ has index $p$, the smallest prime dividing $|G|$, which forces $N$ to be normal. So the quotient $G/N$ is cyclic of order $p$: a ring of $p$ cosets, each containing $q$ elements.

A **reduction theorem** now squeezes the problem into a corner. If $S$ contains any nonidentity element *inside* $N$, or two nonidentity elements in the *same* coset of $N$, we win — the first case by the twisted criterion, the second by the factor group lemma. Formally: either $\mathrm{Cay}(G,S)$ is hamiltonian, or the nonidentity elements of $S$ avoid $N$ entirely and lie in pairwise *distinct* cosets of $N$; a **partial transversal**. Because the graph only depends on $S \cup S^{-1}$, one can say more: no two elements of $S$ may lie in mutually inverse cosets either, unless they are genuinely inverse to one another. A pleasant corollary: any connection set with at least $p$ nonidentity elements is hamiltonian, since there are only $p-1$ nontrivial cosets to go around.

The symmetric form of the reduction kills $p = 3$ instantly: a group of order $3$ has only two nonidentity elements and they are inverse to each other, so a transversal $S$ would satisfy $S \subseteq \{1, x, x^{-1}\}$ with $x$ of order $3$ — far too small to generate a group of order $3q$. Hence **every connected Cayley graph of a group of order $3q$ is hamiltonian**.

For larger $p$ the transversal configuration is genuinely different from everything that came before, and here is the precise reason. If you try to lift a hamiltonian cycle of the quotient ring $\mathbb{Z}_p$ using only *positive* powers of the two connection elements $x$ and $y$, the word must use only $x$'s or only $y$'s — and both have order $p$, so its voltage is trivial and the lift collapses into $p$ disjoint short cycles. **You must use inverses.** The smallest instance is the Frobenius group of order $21$, the group of affine maps $t \mapsto 2^{a}t + b$ on $\mathbb{Z}_7$, with $x = (1,0)$ and $y = (2,1)$ in different cosets of the normal subgroup of order $7$. An explicit hamiltonian cycle exists, spelled by the word
$$x\,x\,y\,x\,x\,y\,x\,y\,x\,x\,y\,y\,x^{-1}x^{-1}y\,x^{-1}x^{-1}y^{-1}x\,y\,y,$$
and, as promised, it uses inverses.

The general pattern is a beautifully economical word. Let $x$ have odd order $k$, let $A \neq 1$ lie in the normal subgroup of prime order, and let $y = A x^{m}$ with $0 < m < k$. Read the $k$-periodic word
$$\underbrace{x, \dots, x}_{},\ y,\ \underbrace{x^{-1}, \dots, x^{-1}}_{},\ y$$
with the block lengths dictated by $m$. It visits every coset exactly once, and its voltage works out to $B \cdot (x B x^{-1})$ for a suitable conjugate $B$ of $A^{\pm 1}$ — an element of a group of *odd prime* order which is never trivial. The factor group lemma then delivers the cycle.

Putting the pieces together yields the headline theorem of this circle of ideas:

> **The Order-$pq$ Theorem.** Let $p \neq q$ be primes and let $G$ be any group of order $pq$ — abelian or not. Then **every** connected Cayley graph of $G$ is hamiltonian. No hypothesis whatsoever is placed on the connection set beyond generating the group.

Specialising, every connected Cayley graph of a group of order $2p$, of order $3q$, of order $5q$ is hamiltonian; and by the direction-sequence machinery, so is every Cayley graph of a group of order $pqrs$ that contains a generator, or two commuting elements whose orders multiply to $pqrs$, or a normal-and-twisted pair $a, b$ with $\gcd(e-1, |a|) = 1$.

## Why anyone should care

Hamiltonian cycles in Cayley graphs are not an isolated curiosity. A hamiltonian cycle in $\mathrm{Cay}(G,S)$ is exactly a **Gray code** for $G$: an ordering of all group elements in which consecutive entries differ by a single generator. Gray codes on the symmetric group drive bell-ringing (change ringing has been generating them by hand since the seventeenth century), combinatorial generation algorithms, and error-resilient encodings. In the theory of interconnection networks, Cayley graphs of order $n$ are the standard designs for parallel architectures precisely because vertex-transitivity means no processor is privileged; a hamiltonian cycle is an embedded ring, the substrate for pipelined computation and for fault-tolerant routing. And on the pure side, the conjecture is a probe of how far the local homogeneity of a group forces global structure on the graph it draws of itself.

What makes the $pqrs$ programme worth the effort is that squarefree orders are where group theory is at its most rigid: Sylow subgroups are cyclic, the group is metacyclic or close to it, and every obstruction you meet is a genuinely combinatorial one, not an algebraic accident. The tools built here — voltages, direction sequences, twisted geometric congruences, coset-pair words — are the vocabulary in which the general conjecture, if it is ever proved, will be written.

The ox still has fields to plough. But it now knows how to turn.
