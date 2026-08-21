# Erdős's Coin Flips Were Algorithms All Along

## A proof that proves nothing you can hold

In 1947 Paul Erdős published a two-page paper that changed combinatorics. The question it answered was old and stubborn: how large must a party be before you can guarantee that some $k$ people all know each other, or some $k$ people are all mutual strangers? Call the smallest such size $R(k,k)$ — the *Ramsey number*. Frank Ramsey had proved in 1930 that this number is finite. Nobody knew how big it was.

Erdős's move was startling. Instead of building a party with no clique of $k$ friends and no clique of $k$ strangers — a hard, fiddly, combinatorial construction — he flipped coins. Take $n$ people, and for every pair, toss a fair coin: heads they are friends, tails they are strangers. Now fix any particular group of $k$ people. There are $\binom{k}{2}$ pairs inside that group, and for all of them to come out the same way has probability $2 \cdot 2^{-\binom{k}{2}}$. There are $\binom{n}{k}$ groups to worry about. So the chance that *some* group is monochromatic is at most

$$\binom{n}{k}\, 2^{1-\binom{k}{2}}.$$

If that number is less than $1$, then the chance that *no* group is monochromatic is positive — and an event of positive probability must sometimes happen. So a good party exists. A little arithmetic shows the bound is less than $1$ whenever $n \le 2^{k/2}$, which gives

$$R(k,k) > 2^{k/2}.$$

The proof is a masterpiece of economy, and also a masterpiece of frustration. Seventy-five years later, nobody can *write down* a party of size $2^{k/2}$ with no monochromatic $k$-clique. Erdős proved that almost every such party works, without exhibiting a single one. It became the founding example of what is now called the **probabilistic method**, and the standard gloss on the method is: it is *non-constructive*. It tells you a needle exists in the haystack without telling you where.

This article is about the opposite reading. Look closely at Erdős's argument and there is no randomness in it at all — only *counting*. The probability that a random colouring is bad is a fraction whose numerator is a number of colourings and whose denominator is $2^{\binom{n}{2}}$, the total number of colourings. Saying "the probability is less than one" is saying "the bad colourings do not exhaust the list". Erdős's proof, stripped of its measure-theoretic clothing, is a statement about two integers:

$$2\binom{n}{k} \cdot 2^{\binom{n}{2} - \binom{k}{2}} \;<\; 2^{\binom{n}{2}}.$$

The left side counts bad colourings; the right counts all colourings. Everything else is arithmetic. And once the argument is arithmetic, the "existence" it delivers is not mystical: it is the guarantee that a finite search through a finite list must succeed. The existence proof *is* an algorithm — a slow one, but an algorithm.

That reframing is what this work makes precise, across the four great landmarks of the probabilistic method: Erdős's Ramsey bound, the deletion method, the Lovász Local Lemma, and Turán's theorem. Each is re-derived as pure finite counting, greedy search, or local search. In two cases the de-randomised version turns out to be *stronger* than the textbook probabilistic statement.

## Counting, not measuring: the Ramsey bound

Here is the first result, stated without a probability space anywhere in sight.

> **Theorem (Erdős, counted).** Let $3 \le k \le n$ and suppose $n^2 \le 2^{k}$ (that is, $n \le 2^{k/2}$). Then there is a graph on $n$ vertices such that neither it nor its complement contains a clique on $k$ vertices. Consequently $R(k,k) > 2^{k/2}$.

The proof identifies a two-colouring of the edges of the complete graph $K_n$ with a *subset* of the pair set — the set of red edges. There are $2^{\binom{n}{2}}$ subsets. For a fixed $k$-set $K$ of vertices, the colourings that are monochromatic on $K$ are exactly those subsets that either contain all of $K$'s internal pairs or are disjoint from all of them, and each of those two families has exactly $2^{\binom{n}{2} - \binom{k}{2}}$ members. A union bound — which here is the completely elementary fact that the size of a union is at most the sum of the sizes — gives at most $\binom{n}{k}\cdot 2 \cdot 2^{\binom{n}{2}-\binom{k}{2}}$ bad colourings. If that is smaller than $2^{\binom{n}{2}}$, some colouring survives.

Making the arithmetic work requires one clean inequality, which the analysis reduces to: for every $k \ge 3$,

$$2^{k+2} < (k!)^2 .$$

That single fact (equivalently $2 \cdot 2^{k/2} < k!$) is what converts the counting inequality into the bound $n \le 2^{k/2}$. It is proved by induction: the step multiplies the left side by $2$ and the right side by $(k+1)^2 \ge 16$.

No measure, no expectation, no sample space — and the theorem is exactly Erdős's.

## Sharpening the knife: deletion

Erdős's union bound is wasteful. If a colouring has *one* monochromatic $k$-set, we throw the whole colouring away. But we could instead throw away one *vertex* — puncture the offending clique — and keep the rest.

That is the **deletion method**, and it also becomes pure counting. Add up, over all $2^{\binom{n}{2}}$ colourings, the number of monochromatic $k$-sets each one has. Exchanging the order of summation, this double count equals $\binom{n}{k}$ times the number of colourings monochromatic on a fixed $k$-set, i.e. $2\binom{n}{k}2^{\binom{n}{2}-\binom{k}{2}}$. If the average is below $t+1$, some colouring has at most $t$ bad sets. Concretely:

> **Theorem (deletion, counted).** If $1 \le k \le n$ and $2\binom{n}{k} < (t+1)2^{\binom{k}{2}}$, then there is a two-colouring of the complete graph on $n - t$ vertices with no monochromatic $k$-clique; that is, $R(k,k) > n-t$.

The deletion step is where non-constructivity usually creeps back in — "pick a vertex from each bad set" sounds like a choice principle. It isn't. Take the *minimum* vertex of each bad set (the vertices are numbered, after all). The resulting transversal has at most as many elements as there are bad sets, and it meets every one of them. Delete it, restrict the colouring to what remains, and the restriction has no monochromatic $k$-set — a completely explicit operation.

And the gain is real, not cosmetic. At $k = 6$: the union bound needs $2\binom{n}{6} < 2^{15} = 32768$, and at $n=18$ it already fails, since $2\binom{18}{6} = 37128$. The deletion bound with $t = 1$ needs $2\binom{n}{6} < 2 \cdot 32768 = 65536$, and at $n = 19$ we have $2\binom{19}{6} = 54264 < 65536$. Delete one vertex from that colouring of $K_{19}$ and you get a Ramsey colouring on $18$ vertices: $R(6,6) > 18$, a bound the union bound cannot reach.

Erdős's upper bound partner comes from the Erdős–Szekeres recursion, which says a graph on $\binom{2k}{k}$ vertices always has a clique or an independent set of size $k+1$; a short induction gives $\binom{2m}{m}\le 4^m$, hence the **sandwich**

$$2^{k/2} < R(k,k) \le 4^{k-1},$$

both sides established by finite arguments.

## The greedy shadow of a random permutation

The second landmark is more surprising, because the de-randomisation is not just possible but *simpler* than the original.

The **Caro–Wei inequality** says that every finite graph $G$ has an independent set — a set of vertices no two of which are adjacent — of size at least

$$\sum_{v} \frac{1}{\deg(v)+1}.$$

The classical proof is a jewel of the probabilistic method: shuffle the vertices into a uniformly random order and keep every vertex that comes before all of its neighbours. The kept set is independent, and vertex $v$ is kept exactly when it is first among the $\deg(v)+1$ members of its closed neighbourhood, which happens with probability $1/(\deg(v)+1)$. Linearity of expectation finishes it, and some ordering must do at least as well as the average.

The de-randomised proof throws away the permutation entirely and runs an algorithm: **repeatedly pick a vertex of minimum degree, put it in your independent set, delete it and all its neighbours, repeat**. To make the induction work you track degrees *relative to the surviving vertex set*: write $\deg_t(v)$ for the number of neighbours of $v$ inside a set $t$. The statement that carries the induction is:

> **Theorem (relative Caro–Wei).** For every set $t$ of vertices there is an independent set $s \subseteq t$ with $\displaystyle |s| \;\ge\; \sum_{v \in t} \frac{1}{\deg_t(v)+1}.$

The proof is three lines of bookkeeping. Pick $v \in t$ of minimum relative degree $d$, and let $B$ be its closed neighbourhood inside $t$, of size exactly $d+1$. Every vertex of $B$ has relative degree at least $d$, so its term $1/(\deg_t(u)+1)$ is at most $1/(d+1)$, and the whole block $B$ contributes at most $(d+1)\cdot\frac{1}{d+1} = 1$ to the sum. Recursing on $t \setminus B$ — whose relative degrees can only have gone down, so whose terms can only have gone up — produces an independent set $s'$ that already beats the sum over $t\setminus B$. Adding $v$ back costs nothing in independence (its neighbours are all gone) and buys exactly the $1$ we needed. Setting $t$ to be everything gives Caro–Wei.

That one induction pays for a cascade of classical results. Since every degree is at most the maximum degree $\Delta$,

$$\alpha(G) \;\ge\; \frac{n}{\Delta+1},$$

and applying the Cauchy–Schwarz inequality in Sedrakyan's form $\sum 1/a_v \ge n^2/\sum a_v$ to $a_v = \deg(v)+1$, together with the handshake identity $\sum_v \deg(v) = 2m$, gives Turán's bound on the independence number,

$$\alpha(G) \;\ge\; \frac{n^2}{2m+n}.$$

## Turán's theorem, upside down

Apply the same machine to the *complement* graph and something classical falls out. A graph with no clique on $r+1$ vertices has complement with no independent set of size $r+1$, i.e. $\alpha(G^c) \le r$. Feeding Caro–Wei on $G^c$ into Sedrakyan, and using that the complement's degrees sum to $n(n-1)-2m$:

> **Theorem (Turán, via greedy).** For $r \ge 1$, every graph on $n$ vertices with no clique of size $r+1$ has at most $\left(1-\frac1r\right)\frac{n^2}{2}$ edges.

No divisibility hypothesis, no assumption on the vertex set beyond finiteness. And the bound is attained: on four vertices with $r=2$ the four-cycle is triangle-free with exactly $4 = (1-\frac12)\cdot\frac{16}{2}$ edges.

But "attained" is a subtle word, and this is where the counting viewpoint pays an unexpected dividend. The extremal graph is the **Turán graph** $T(n,r)$: split $n$ vertices into $r$ classes as equally as possible and join every pair in different classes. When $r \nmid n$ the classes cannot be equal, and the clean formula $\left(1-\frac1r\right)\frac{n^2}{2}$ overshoots. Counting the classes exactly — with $s = n \bmod r$ classes of size $\lceil n/r\rceil$ and $r-s$ of size $\lfloor n/r \rfloor$ — yields a subtraction-free identity valid for *all* $n$ and all $r\ge 1$:

$$2r\,e\big(T(n,r)\big) + s(r-s) = (r-1)\,n^2, \qquad s = n \bmod r,$$

equivalently

$$e\big(T(n,r)\big) = \left(1-\frac1r\right)\frac{n^2}{2} \;-\; \frac{s(r-s)}{2r},$$

with equality to the clean value **exactly** when $r \mid n$. So the exact extremal number is

$$\mathrm{ex}(n, K_{r+1}) = \frac{(r-1)n^2 - s(r-s)}{2r},$$

and this is a genuine maximum, not merely an upper bound.

Textbooks often round the clean value down and assert $\mathrm{ex}(n,K_{r+1}) = \left\lfloor \left(1-\frac1r\right)\frac{n^2}{2}\right\rfloor$. That is true precisely when the correction $s(r-s)$ is smaller than $2r$ — and it is *not* always true. The first failure is at $n = 12$, $r = 8$: here $s = 4$, the correction is $4\cdot 4 = 16 = 2r$, and the true extremal number is $62$ while the floor formula predicts $63$. For every modulus $r < 8$ the floor formula is correct for all $n$; $r=8$ is exactly where it first breaks. That is the kind of fact that only surfaces when you insist on counting rather than estimating.

## When the events are almost independent: the Local Lemma

The third landmark is the **Lovász Local Lemma**, the tool that rescues the probabilistic method when the union bound fails. Suppose you have bad events $A_1,\dots,A_n$, each of probability at most $p$, and each depending on at most $d$ of the others. The union bound needs $np < 1$ — hopeless if $n$ is huge. The Local Lemma needs only a *local* condition:

> **Theorem (Symmetric Local Lemma).** If every bad event has probability at most $p$, every dependency set has at most $d$ members, each event satisfies the one-sided independence bound with respect to the events outside its dependency set, and $e\,p\,(d+1) \le 1$, then some outcome avoids all the bad events simultaneously.

Note there is no $n$ in the hypothesis. A million events, each of probability $1/100$, each interacting with only two others, are all avoidable at once.

Here the setting is a *finite weighted probability space*: a finite set $\Omega$ of outcomes with nonnegative weights summing to $1$, and the probability of an event being the sum of the weights of its members. That is a purely finitary object — no $\sigma$-algebras, no measure theory. The general asymmetric version reads: if there are numbers $x_i \in [0,1)$ with

$$\mathbb{P}(A_i) \le x_i \prod_{j \in \Gamma(i)} (1 - x_j),$$

then $\mathbb{P}\left(\bigcap_i \overline{A_i}\right) \ge \prod_i (1-x_i) > 0$. The proof is the classical Erdős–Lovász double induction, in which one shows, for every index $i$ and every set $S$ of indices, that

$$\mathbb{P}\Big(A_i \cap \bigcap_{j\in S}\overline{A_j}\Big) \;\le\; x_i \cdot \mathbb{P}\Big(\bigcap_{j\in S}\overline{A_j}\Big),$$

by splitting $S$ into the part inside $\Gamma(i)$ and the part outside, bounding the numerator with the outside part (where the one-sided independence hypothesis applies) and the denominator with the induction hypothesis. The symmetric form follows by setting every $x_i = 1/(d+1)$ and using the inequality $\left(1 - \frac{1}{d+1}\right)^{d} \ge e^{-1}$, itself a consequence of $1+x \le e^x$.

And then the punchline. The conclusion "the good event has positive probability" means, in a finite weighted space, "the good event is not empty as a set". So the following algorithm is *guaranteed to succeed*: list the outcomes, and return the first one that avoids every bad event. Exhaustive search is sound by construction, and the Local Lemma is precisely the certificate that it never returns "failure". Erdős's existence proof has become a terminating program with a correctness proof.

## Local search: half the edges, always

The fourth landmark shows the same duality in its cleanest form. The **MAX-CUT** problem asks you to split the vertices of a graph into two sides so as to cut as many edges as possible. The probabilistic proof that you can always cut half the edges is one line: put each vertex on a random side; each edge is cut with probability $1/2$; the expected cut is $m/2$.

De-randomise by counting: summing the cut size over *all* $2^n$ subsets of the vertex set gives exactly (number of ordered adjacent pairs) times $2^{n-2}$, so the average over all subsets is $m/2$, so some subset achieves it. Exhaustive search over all subsets — a terminating computation — therefore returns a cut of at least $m/2$.

De-randomise by *algorithm* and you get something better. Call a bipartition **locally maximal** if moving any single vertex to the other side does not increase the cut. The key identity is an exchange formula: flipping vertex $v$ changes the cut by exactly $\deg(v) - 2\,c(v)$, where $c(v)$ is the number of $v$'s edges currently crossing the cut. So local maximality says $\deg(v) \le 2c(v)$ for every $v$: every vertex has at least half of its edges cut. Summing over all vertices and using $\sum_v c(v) = 2\cdot(\text{cut})$ and $\sum_v \deg(v) = 2m$ gives $m \le 2\cdot(\text{cut})$ — half the edges, from a purely local condition. And local search terminates fast: the cut is a strictly increasing integer bounded by $m$, so any improving run has at most $m$ steps.

For the complete graph the search returns the balanced bipartition, of size $\lfloor n/2\rfloor \cdot \lceil n/2 \rceil$ — which is precisely the number of edges of the Turán graph $T(n,2)$. The largest bipartite subgraph of $K_n$ *is* the extremal triangle-free graph. Two of our four landmarks turn out to be the same theorem in different clothing.

## Not last, but adjacent: property B

One more, because it costs nothing. Erdős's **property B** theorem says that a family of fewer than $2^{k-1}$ sets, each of size $k$, can be two-coloured with no set monochromatic. In the counting language this is the Ramsey computation again, with the pair set replaced by the vertex set: at most $|H|\cdot 2\cdot 2^{n-k}$ of the $2^n$ colourings are bad, and $|H| < 2^{k-1}$ makes that a strict inequality. The two counting facts from the Ramsey argument — the subsets containing a fixed $k$-set, and those disjoint from it, each number $2^{n-k}$ — transfer verbatim.

## What the exercise teaches

The moral is not that randomness is useless. The probabilistic language is enormously suggestive: it tells you *what to count* long before you know how to count it. The moral is about what the word "non-constructive" is actually doing.

There are two different things one might mean by it. One is *finitary non-constructivity*: the object exists but the only proof is an averaging argument. That version dissolves under examination: in a finite universe, "positive probability" means "non-empty", and the argument hands you a terminating search. The other is *practical* non-constructivity: the search is exponential and no polynomial algorithm is known. That version is real and stubborn — the exhaustive searches above would outlive the universe.

Between those two poles lies the interesting territory. Caro–Wei's random permutation collapses to a greedy algorithm running in near-linear time, *easier* than the probabilistic proof. MAX-CUT's random bipartition collapses to a local search terminating in at most $m$ improvement steps. The Local Lemma collapses only to exhaustive search — the same statement that the Moser–Tardos resampling algorithm later made efficient. Turán's theorem never needed randomness at all: it needed an exact count of a specific graph, and doing that count carefully exposed a folklore formula as wrong at $n=12$, $r=8$.

Erdős liked to speak of "The Book", in which God keeps the perfect proof of every theorem. The probabilistic method has always looked like a Book proof: short, luminous, and slightly miraculous. What this exercise suggests is that the miracle is a translation artifact. Underneath, there is a second Book proof — longer, more explicit, and with an algorithm at the end of it. Erdős's existence proofs were algorithms in disguise, and the disguise was the word "probability".
