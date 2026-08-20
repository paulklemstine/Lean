# The Machine That Knows Nothing

## How one counting trick proves theorems in three different subjects — and why the real work is deciding what to feed it

### A machine with no opinions

Imagine a machine with one input slot and one output slot. Into the slot you drop a
collection of finite sets — any collection, of anything at all. Out of the other end comes
an inequality relating their total size, the size of their union, and the total size of
their pairwise overlaps.

The machine knows nothing about your sets. It does not know whether they are subsets of a
group, neighbourhoods in a graph, lines in a plane, or lists of grocery items. It never
asks. It is, in the most literal sense, an *empty* device: everything it outputs was
already contained in the shape of what you fed in.

And yet this machine, in the space of a single afternoon, will hand you Erdős and Turán's
theorem on Sidon sets, Reiman's theorem on graphs without four-cycles, and a chunk of the
Kővári–Sós–Turán theory of forbidden bipartite subgraphs. Same machine. Same lever. Three
famous theorems.

This is a story about that machine — and about the discovery, made precise here, that when
a "clever" combinatorial proof works, the cleverness is almost never in the machine. It is
in the *choice of what to feed it*.

---

### Multiplicity: the one idea

Start with a finite family of finite sets $A_1, A_2, \dots, A_k$, all living inside some
ambient world. For each point $x$ in the union, define its **multiplicity**
$$m(x) = \#\{\, i : x \in A_i \,\},$$
the number of members of the family that contain $x$. That is the whole idea. Everything
below is bookkeeping about $m$.

The bookkeeping starts with an identity so simple it feels like cheating. Suppose you have
any weight function $f$ assigning a number to each point. Then

$$\sum_{i=1}^{k} \sum_{x \in A_i} f(x) \;=\; \sum_{x \in \bigcup_i A_i} m(x)\, f(x).$$

This is just counting the pairs $(i,x)$ with $x \in A_i$ in two different orders — first
grouping by set, then grouping by point. Picture a big grid with sets down the side and
points across the top, and a mark in a cell when the point lies in the set. Sum the marks
row by row, or column by column: you get the same total. Mathematicians call this
*Fubini's principle*, or just *double counting*. It is the closest thing combinatorics has
to a free lunch.

Feeding this identity the constant weight $f \equiv 1$ gives the **first moment**:
$$\sum_i |A_i| = \sum_x m(x).$$
Total size equals total multiplicity. Obvious, once you see it.

Feeding it the weight $f = m$ itself gives the **second moment**:
$$\sum_{i}\sum_{j} |A_i \cap A_j| = \sum_x m(x)^2.$$
The left side runs over *all* ordered pairs of indices, including $i = j$. Peel off the
diagonal and you get the quantity that will do all the work in this article — the
**pair-correlation sum**
$$P \;=\; \sum_{i \neq j} |A_i \cap A_j| \;=\; \sum_x m(x)\bigl(m(x)-1\bigr).$$

The right-hand expression is worth staring at. The number $m(m-1)$ is the count of ordered
pairs of *distinct* sets both containing $x$. So $P$ is a census of collisions: how badly,
in total, the family overlaps itself.

---

### Two inequalities the machine emits

Now watch what falls out of nothing but the elementary fact that
$(m-1)^2 \ge 0$, i.e. $2m \le 1 + m^2$, applied at every point.

**The second Bonferroni inequality.** For *any* finite family of finite sets,
$$\sum_i |A_i| \;\le\; \Bigl|\bigcup_i A_i\Bigr| \;+\; \sum_{i \neq j} |A_i \cap A_j|.$$

Read it as a warning about greedy packing: if you want the sets to be big, either their
union must be big, or they must collide a lot. There is no third option.

There is a pleasing rigidity here: the inequality is an *equality exactly when the sets
are pairwise disjoint*. Any slack at all comes from some point that lies in either zero or
at least two of the sets; conversely, if every point of the union has multiplicity exactly
one, the two sides agree. So the inequality's boundary is precisely the trivial case, and
every nontrivial family is strictly inside it. (For instance, two copies of the single-point
set $\{0\}$ give $2 < 1 + 2$.)

**The double-collision bound.** Call $x$ a *double collision* if $m(x) \ge 2$. Then
$$2 \cdot \#\{x : m(x) \ge 2\} \;\le\; \sum_{i \neq j} |A_i \cap A_j|.$$
Each doubly-covered point contributes at least $2\cdot 1 = 2$ to the collision census, so
the count of such points cannot exceed half of it. This one is sharp: take $A_1 = A_2 =
\{0\}$ and both sides equal $2$.

**And the strong form.** Apply the Cauchy–Schwarz inequality to $\sum_x m(x)$ instead of
the pointwise bound, and the same identity yields a genuinely stronger statement, usually
attributed to Corrádi:
$$\Bigl(\sum_i |A_i|\Bigr)^{\!2} \;\le\; \Bigl|\bigcup_i A_i\Bigr| \cdot
\Bigl(\sum_i |A_i| \;+\; \sum_{i\neq j} |A_i \cap A_j|\Bigr).$$

Squaring the left-hand side is what turns a linear statement into one with real teeth: it
is the difference between bounds of the form "$|A| \lesssim N$" and "$|A| \lesssim
\sqrt{N}$".

That is the entire machine. Three lines of output, all consequences of one double count
and one application of Cauchy–Schwarz. **None of the three knows anything about arithmetic,
geometry, or graphs.**

---

### Turning the crank: uniform marginals

Suppose now you feed the machine $k$ sets, each of size exactly $m$, any two of which meet
in at most $t$ points. Corrádi's form immediately gives
$$k\,m^2 \;\le\; \Bigl|\bigcup_i A_i\Bigr| \cdot \bigl(m + (k-1)t\bigr).$$

This one inequality is the workhorse. Everything that follows is obtained by choosing
*what the $k$ sets are*.

---

### First crank: perfect rulers

A set $A$ inside an abelian group $G$ is called a **Sidon set** if all its pairwise sums
are as distinct as possible: whenever $a + b = c + d$ with $a,b,c,d \in A$, the pair
$\{a,b\}$ must equal the pair $\{c,d\}$. Equivalently, all differences $a - b$ with
$a \ne b$ are distinct. These are the "perfect rulers" of additive number theory — mark
a ruler at the positions of a Sidon set and every distance appears at most once. Sidon
sets underpin radar-pulse design, sonar sequences, error-correcting codes and
collision-free frequency-hopping schemes; a big Sidon set is a good set of channels
because no two pairs interfere in the same way.

How large can a Sidon set in a group of size $N$ be? Here is where the marginal choice
enters, in a way that is startlingly clean.

Take the Sidon set $A$ and consider its **translates** $A + g = \{a + g : a \in A\}$. Two
facts are immediate. First, every translate has exactly $|A|$ elements. Second — and this
is the entire arithmetic content of the argument — *two distinct translates of a Sidon set
share at most one point*. Indeed, if $A+g$ and $A+h$ shared two points, we would get two
genuinely different representations of one group element as a sum of two elements of $A$,
which is exactly what the Sidon condition forbids.

So a Sidon set manufactures, for free, a family of equal-sized sets with pairwise
intersections $t = 1$: precisely the input the machine wants. Choose any nonempty set $S$
of shifts, feed in the family $\{A + g : g \in S\}$, and the uniform bound reads

$$\boxed{\;|S| \cdot |A|^2 \;\le\; |G| \cdot \bigl(|A| + |S| - 1\bigr).\;}$$

That is the master inequality. And now the punchline: **different choices of $S$ give
genuinely different theorems.**

*Choice one: $S = A$.* Use only the $|A|$ translates by elements of $A$ itself. Then
$|S| = |A|$ and the master inequality collapses to
$$|A|^3 \;\le\; (2|A| - 1)\cdot |G|,$$
which says roughly $|A| \lesssim \sqrt{2|G|}$.

*Choice two: $S = G$.* Use *all* $|G|$ translates. Then $|S| = |G|$, the factor $|G|$
cancels from both sides, and out drops
$$|A| \,(|A| - 1) \;\le\; |G| - 1,$$
the sharp **Erdős–Turán bound**, giving $|A| \lesssim \sqrt{|G|}$ with the correct
constant. This is the classical theorem, and it is the best possible: for infinitely
many orders $N$ — namely $N = q^2+q+1$ with $q$ a prime power — there are Sidon sets, the
perfect difference sets, for which $|A|(|A|-1) = |G|-1$ holds with *equality*.

Same set $A$. Same machine. Same universal inequality. The only difference is *which
marginals were fed in* — and the second choice is better by a factor of $\sqrt{2}$ in the
constant.

Is that gap real, or just sloppiness in the estimates? It is real, and one can pin it down
exactly. First, the all-translate output always implies the self-translate output:
whenever $m(m-1) \le N - 1$ holds, so does $m^3 \le (2m-1)N$. So the two conclusions are
*ordered*. Second, the ordering is strict, and one can name the witness: at $N = 100$ and
$m = 13$ we have $m^3 = 2197 \le 2500 = (2m-1)N$, but $m(m-1) = 156 > 99 = N - 1$. A
hypothetical set of size $13$ in a group of size $100$ passes the weak test and fails the
strong one. The self-translate marginal simply cannot see that such a set is impossible.

---

### Second crank: graphs with no rectangles

Now feed the same machine something completely unrelated. Take a finite graph, and for
each vertex $v$ let $A_v = N(v)$ be its set of neighbours. The intersection $N(u) \cap
N(v)$ is the set of *common neighbours* of $u$ and $v$. So the hypothesis "any two distinct
vertices have at most one common neighbour" — equivalently, the graph contains no
four-cycle $C_4$, no "rectangle" — is exactly the input condition $t = 1$.

The sum of all neighbourhood sizes is the sum of the degrees, which is $2|E|$ by the
handshake lemma; the union of the neighbourhoods lives inside the vertex set. Corrádi's
form spits out

$$(2|E|)^2 \;\le\; |V| \cdot \bigl(2|E| + |V|(|V|-1)\bigr),$$

which rearranges to $|E| = O(|V|^{3/2})$: **Reiman's theorem**. A rectangle-free graph on
$n$ vertices has at most about $\tfrac12 n^{3/2}$ edges — dramatically fewer than the
$\binom{n}{2} \approx \tfrac12 n^2$ available. And once again the bound is essentially
attained, this time by the incidence graph of a finite projective plane.

Nothing in the machine changed. Only the marginals: translates of a Sidon set became
neighbourhoods of a graph, and additive number theory became extremal graph theory.

---

### The separation of concerns

Here, then, is the thesis, now a theorem rather than a slogan:

> The Bonferroni/Corrádi inequalities are **universal** — they hold for every finite family
> and carry no arithmetic, geometric or combinatorial information whatsoever. All content
> of a bound obtained from them is contained in the *marginals*: the index set, the common
> size of the members, and the pair-intersection bound.

This reframes what a "clever proof" is. When somebody proves an extremal bound by double
counting, the reader's admiration should not go to the double count — that step is
mechanical, and always available. It should go to the *design of the family*. Erdős and
Turán's insight was not the counting; it was seeing that the right thing to count is *all*
translates rather than a natural-looking subfamily.

And this reframing is productive, because it tells you where to look for improvements. If
your bound is too weak, do not sharpen the machine — the machine is exact at its boundary
and cannot be sharpened. Enlarge or re-design the family. Or, if you have exhausted the
pairwise information entirely, climb a level.

---

### Climbing a level

The double count that produced the second moment does not stop there. Run it once more and
you obtain the *triple*-correlation identity
$$\sum_{i}\sum_{j}\sum_{k} |A_i \cap A_j \cap A_k| \;=\; \sum_x m(x)^3,$$
and from it a clean third-order relation, free of any subtraction:
$$\sum_x m(x)\bigl(m(x)-1\bigr)\bigl(m(x)-2\bigr) \;+\; 3\sum_{i,j}|A_i \cap A_j|
\;=\; \sum_{i,j,k}|A_i \cap A_j \cap A_k| \;+\; 2\sum_i |A_i|.$$
This is inclusion–exclusion for ordered triples of *distinct* indices covering a point, and
it yields the exact analogue of the double-collision bound one storey up:
$$6\cdot\#\{x : m(x) \ge 3\} \;\le\; \sum_x m(x)(m(x)-1)(m(x)-2).$$

Why bother? Because the second-moment machinery is *blind* by design: it sees only pair
correlations. For questions where the essential structure is genuinely higher-order — sets
in which every element has at most one representation as a sum of $h \ge 3$ members, the
so-called $B_h$-sets — no cunning choice of two-set marginals can beat the naive counting
argument, because the pairwise data simply does not contain the answer. The improvement
must come from the third floor of the building, not a better arrangement of furniture on
the second.

---

### Why this matters beyond the theorems

There is a broader lesson here about how mathematics is actually done. We tend to describe
proofs as monolithic acts of ingenuity. Very often they are not: they are a *universal
engine* plus a *choice*. The engine is public, reusable, and provable once and for all. The
choice is where the mathematics lives.

Making that split explicit has practical consequences. It tells you which parts of an
argument transfer across fields for free — the machine works identically on groups, graphs,
designs and set systems. It tells you which parts must be reinvented every time — the
marginals. And it tells you, when a bound stubbornly refuses to improve, whether you are
fighting a limitation of your method or a limitation of the mathematics.

The machine knows nothing. That is exactly why it works everywhere. What it produces is
whatever you were wise enough to put in.
