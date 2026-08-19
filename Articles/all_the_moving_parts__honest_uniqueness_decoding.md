# The Honest Arithmetic of Looking Things Up

## Why every lookup table in the world pays the same tax

Somewhere in the machine you are reading this on, a piece of software is looking
something up. A browser is asking which font glyph belongs to a character code; a
database is asking where row 4,812,993 lives; a compiler is asking whether the
identifier `x` has been declared. All of them use the same ancient trick: throw the
keys into a modest number of labelled boxes, and when you need a key, open its box
and look through it.

The trick has a name — hashing with buckets — and a reputation for being fast. But
"fast" is a slippery word, and the interesting question is not whether the trick is
fast but exactly *how* fast it can be forced to be. If you have $N$ keys and you are
only willing to pay for $m$ boxes, what is the *best possible* total amount of
looking that any scheme, however clever, can achieve? Not asymptotically. Not up to
a constant. Exactly.

That question has a complete answer, and it is prettier than one might expect. This
article tells the whole story: what the model is, what the exact optimum is, which
schemes achieve it (all of them, and only them), what happens at the extreme
opposite end, and what universal barrier separates memory from time.

---

## The model, stripped to the bone

Fix a finite set of $N$ keys, totally ordered — think of them as $0, 1, \dots, N-1$
— and a set of $m$ bucket labels. A **scan scheme** is nothing more than a function
$\beta$ assigning to each key a bucket label. That's it. No hash function magic, no
probability, no assumptions about the key distribution: just a map from keys to
boxes.

To find a key $x$, you go to bucket $\beta(x)$, read out its contents in the
canonical order, and compare one at a time until you hit $x$. If $x$ is the fifth
entry, you paid five comparisons. So define the **decoding cost**
$$\mathrm{cost}(x) = (\text{position of } x \text{ in its own bucket}) + 1,$$
counted with the first position being $0$, so the cost is a genuine $1$-based count
of comparisons. The quantity to study is the **total decoding cost**
$$C(\beta) \;=\; \sum_{x} \mathrm{cost}(x),$$
the price of looking up every key exactly once — equivalently, $N$ times the average
lookup cost under the uniform distribution on keys.

Two questions immediately need answering, and they are the two questions people
usually skip.

**First: is the model honest?** A cost model that quietly assumes something
impossible is worthless. Here, the thing we must not fudge is that the scan really
does identify the key — that the "address" a scan produces is unambiguous. Define
the **scan code** of a key $x$ to be the pair
$$\mathrm{enc}(x) = \bigl(\beta(x),\, i(x)\bigr),$$
where $i(x)$ is the *intra-bucket index*: the position of $x$ inside the ordered
list of its own bucket. And define decoding of a pair $(b, i)$ to be: go to bucket
$b$, return its $i$-th entry if there is one, and otherwise fail.

> **Honest Uniqueness Decoding.** For every key $x$, the scan code $\mathrm{enc}(x)$
> decodes to $x$. Moreover, for every pair $(b,i)$ and every key $x$, the pair
> $(b,i)$ decodes to $x$ **if and only if** $(b,i) = \mathrm{enc}(x)$. In particular
> the map $x \mapsto \mathrm{enc}(x)$ is injective.

The proof is a two-line argument built on one fact: a bucket's contents form a list
with no repetitions, and in a repetition-free list the position of an element
determines the element and vice versa. But the *statement* is what matters. It says
the cost model is not hiding a cheat: the bucket label plus a small integer is a
complete, unambiguous address for every key, and no scheme-level ambiguity has been
swept under the carpet. Every comparison we are about to count buys real
information.

**Second: what exactly is the total cost?** Suppose a bucket holds $k$ keys. The
first key in it costs $1$, the second costs $2$, and so on, so looking up all of them
costs $1 + 2 + \cdots + k$. Write
$$T(k) \;=\; \frac{k(k+1)}{2}$$
for this triangular number. Summing over buckets gives, with no error term of any
kind:

> **Exact Cost Accounting.** For every scan scheme,
> $$\sum_{x} \mathrm{cost}(x) \;=\; \sum_{b} T\bigl(|\beta^{-1}(b)|\bigr).$$

This identity is the hinge of the whole subject. It converts a question about
comparisons, orderings, and lists into a question about nothing but a *list of
bucket sizes*. The internal structure of a scheme — which key goes where, in what
order — is invisible to the total cost. Only the multiset of bucket sizes survives.

So the optimisation problem has collapsed to something a schoolchild can state:

> Minimise $T(k_1) + T(k_2) + \cdots + T(k_m)$ over non-negative integers with
> $k_1 + \cdots + k_m = N$.

---

## The exact optimum, and why balance wins

Everyone's instinct says: spread the keys evenly. The instinct is right, and the
reason is a discrete version of convexity — but with an integer twist that turns out
to be the source of everything interesting.

The function $T$ is convex, so it lies above each of its tangent lines. In the
discrete setting the right "tangent" at an integer $q$ uses the *upper* slope
$q+1$, and the resulting inequality is exact for all integers:

> **Integral Tangent-Line Inequality.** For all integers $k, q \ge 0$,
> $$T(q) + (q+1)(k - q) \;\le\; T(k),$$
> and the difference — the **slack** — is exactly
> $$T(k) - T(q) - (q+1)(k-q) \;=\; \frac{(k-q)(k-q-1)}{2}.$$

Everything follows from staring at that slack. It is a product of two consecutive
integers, hence never negative; and it is *zero* precisely when $k - q \in \{0, 1\}$
— that is, when the bucket has size $q$ or size $q+1$. A bucket of size $q+2$ pays
a slack of $1$; a bucket of size $q+3$ pays $3$; an empty bucket, when $q = 4$, pays
$10$.

Now sum the inequality over all $m$ buckets, taking $q = \lfloor N/m \rfloor$ as the
tangent point. The linear terms telescope into something that depends only on
$\sum_i k_i = N$, so the sum of tangent values is a constant independent of the
scheme. Writing $q = \lfloor N/m\rfloor$ and $r = N \bmod m$, that constant is
$$\mathrm{Opt}(N,m) \;=\; r\,T(q+1) \;+\; (m-r)\,T(q).$$

And this constant is not merely a bound — it is achieved, by the most obvious scheme
imaginable, the **residue scheme** that sends key $x$ to bucket $x \bmod m$. Its
buckets have sizes $q+1$ (the first $r$ of them) and $q$ (the rest), exactly the
balanced profile. So:

> **The Exact Optimum.** Among all scan schemes storing $N$ keys in $m \ge 1$
> buckets, the least achievable total decoding cost is exactly
> $$\mathrm{Opt}(N,m) = r\,T(q+1) + (m-r)\,T(q), \qquad q = \lfloor N/m \rfloor,\ r = N \bmod m,$$
> and it is attained by the residue scheme $x \mapsto x \bmod m$.

For a concrete taste: with $N=5$ keys and $m=3$ buckets, $q=1$ and $r=2$, so
$\mathrm{Opt} = 2 \cdot T(2) + 1 \cdot T(1) = 6 + 1 = 7$. Exhaustive search over all
$3^5 = 243$ schemes confirms that $7$ is the minimum and that it is achieved.

---

## Rigidity: not just how good, but who

The tangent argument gives more than a number. Since the total slack is a sum of
non-negative terms, the bound is met with equality if and only if *every single*
slack vanishes. And we know exactly when a slack vanishes.

> **Rigidity of the Optimum.** A scan scheme has total decoding cost exactly
> $\mathrm{Opt}(N,m)$ if and only if every bucket has size $\lfloor N/m \rfloor$ or
> $\lceil N/m \rceil$.

This is the difference between "the best schemes are balanced" as folklore and as a
theorem with an "only if". The optimal locus is not merely populated by balanced
schemes; it *consists* of them, with nothing else allowed in and nothing balanced
left out. Optimisation has become classification.

Two further facts complete the picture of what a scheme's cost can see. First, the
cost is blind to the identity of the keys and to the names of the buckets:

> **Symmetry Invariance.** Permuting the keys before applying the bucket map, or
> relabelling the buckets by any bijection, leaves the total decoding cost unchanged.

That is a formal statement of the "only the size profile matters" slogan, and
together with rigidity it says the optimal schemes form a single orbit under the
natural symmetry group $\mathrm{Sym}(\text{keys}) \times \mathrm{Sym}(\text{buckets})$.
Second, the extreme case of perfect efficiency is characterised too:

> **Perfect Hashing.** Every key decodes in exactly one comparison if and only if the
> bucket map is injective. Consequently, if there are fewer buckets than keys, some
> key must cost at least two comparisons — no compressing scheme is collision-free.

And the pigeonhole makes a sharper appearance:

> **Failure Analysis.** In every scan scheme on $N \ge 1$ keys with $m$ buckets there
> is a key $x$ with $m \cdot \mathrm{cost}(x) \ge N$; that is, some key costs at least
> the average bucket load.

---

## The other end of the spectrum

If convexity pins the floor, superadditivity pins the ceiling. Because
$T(a) + T(b) \le T(a+b)$ — merging two buckets never helps — the worst you can ever
do is put everything in one bucket:

> **The Cost Spectrum.** Every scan scheme on $N$ keys with $m \ge 1$ buckets has
> total decoding cost in the closed window
> $$\bigl[\,\mathrm{Opt}(N,m),\; T(N)\,\bigr],$$
> and both endpoints are realised: the lower one by the residue scheme, the upper one
> by the degenerate scheme that puts every key in a single bucket.

There is a temptation to guess that everything in between is achievable too. It is
not. With $N=5$ and $m=3$, exhaustive enumeration shows the achievable total costs
are exactly $\{7, 8, 9, 11, 15\}$ — the window is $[7,15]$, both ends occur, but
$10$, $12$, $13$, $14$ are impossible. The reason is visible from the accounting
identity: the achievable costs are precisely the numbers $\sum_i T(k_i)$ over
partitions of $N$ into at most $m$ parts, a sparse set of sums of triangular numbers,
not an interval. The window is tight at its endpoints and porous inside.

---

## The compression barrier: what you pay for saving space

Now the punchline, the statement that a systems engineer would tape to a wall.
Convert the exact optimum into an average. Dividing $\mathrm{Opt}(N,m)$ by $N$ and
doing a little integer arithmetic yields a bound with genuine real division:

> **Mean-Cost Lower Bound.** For every scan scheme on $N \ge 1$ keys with $m \ge 1$
> buckets, the mean decoding cost satisfies
> $$\frac{1}{N}\sum_x \mathrm{cost}(x) \;\ge\; \frac{1}{2}\left(\frac{N}{m} + 1\right).$$

Read this as a trade-off: halving the number of buckets roughly doubles the average
number of comparisons. Now suppose you insist on *compression* — you will spend only
an $\varepsilon$ fraction as many buckets as there are keys, $m \le \varepsilon N$.
Substituting gives the clean form:

> **The $\varepsilon$-Compression Barrier.** If $m \le \varepsilon N$ for some
> $\varepsilon > 0$, then the mean decoding cost of any scan scheme is at least
> $$\frac{1}{2\varepsilon}.$$

Space $\varepsilon$; time $1/(2\varepsilon)$. Their product is bounded below by a
constant, and the constant is $1/2$ exactly — no better, because the residue scheme
meets the mean-cost bound with equality whenever $m$ divides $N$. Concretely, with
$4096$ keys and $256$ buckets ($\varepsilon = 1/16$), the barrier says at least $8$
comparisons on average; the exact bound says $8.5$; and the residue scheme achieves
exactly $8.5$. The theory and the practice agree to the last decimal, because there
is no slack left to hide in.

---

## What this is really about

Three ideas deserve to be lifted out of the arithmetic.

The first is **honesty in a cost model**. It is easy to prove impressive lower bounds
about a model that cannot actually be implemented. Insisting up front that the
address a scan produces is a genuine, uniquely decodable code — and proving it —
means the bound applies to real lookups, not to a convenient fiction.

The second is **exactness**. Almost every statement in this story is an identity or a
sharp inequality with an attainment: not $O(N^2/m)$, but $r\,T(q+1) + (m-r)\,T(q)$;
not "roughly balanced is best", but "balanced, and nothing else". Exactness is what
makes the constant $1/2$ in the compression barrier meaningful, and it is what turns
an optimisation problem into a classification.

The third is **rigidity as a gateway**. Once you know the optimal schemes are exactly
the balanced ones, you can *count* them: the optimal locus is a single symmetry
orbit, and orbit–stabiliser should give the number of cost-optimal maps from $N$ keys
to $m$ buckets as
$$\binom{m}{r} \cdot \frac{N!}{\bigl((q+1)!\bigr)^{r}\,(q!)^{m-r}}.$$
For $N=5$, $m=3$ that formula predicts $3 \cdot 30 = 90$, and exhaustive enumeration
finds exactly $90$ optimal schemes. This is the natural next theorem, and it exists
only because the "only if" half of rigidity was proved.

Beyond it lie two more questions. What is the exact achievable cost set — the sums of
triangular numbers over partitions of $N$ into at most $m$ parts — as an explicit
arithmetic object? And can a *two-level* scheme, a bucket map followed by a second
bucket map inside each bucket, beat the one-level barrier at equal total space? The
accounting identity suggests not: costs add up the same way at every level, so
$1/(2\varepsilon)$ ought to be a barrier for hierarchies as well as for flat tables.
Proving it would say something clean and general about the price of memory.

Until then, the flat story is complete, and it is worth remembering how little it
took. One triangular number, one tangent line with an integer slope, and the
observation that $(k-q)(k-q-1)$ is zero exactly twice.
