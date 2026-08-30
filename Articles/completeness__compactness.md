# The Shape of an Infinite Questionnaire

## How a simple rule — *never say yes twice in a row* — turns a space of infinite answers into a Fibonacci fractal

---

### An infinite quiz

Imagine an examiner with an infinite list of yes/no questions, numbered $0, 1, 2, 3, \dots$, and a candidate who must answer all of them. The candidate's entire performance is a single infinite string of bits:

$$x = (x_0, x_1, x_2, \dots), \qquad x_k \in \{\texttt{yes}, \texttt{no}\}.$$

Call such a string a **truth stream**, and call the collection of all of them the **truth space** $\mathcal{C}$. It is a big set — uncountably big, the same size as the real line. At first glance it seems hopelessly unwieldy: infinitely many independent binary choices, $2^{\aleph_0}$ of them, with no obvious structure to hold onto.

But there *is* a structure, and it is the most natural one imaginable. It comes from asking a single question about two candidates:

> **Where do they first disagree?**

If two candidates agree on the first million questions and diverge on the millionth-and-first, they are, for all practical purposes, nearly identical: no examiner with a finite budget of questions could tell them apart. If they disagree already on question $0$, they are as different as can be. This intuition becomes a genuine notion of distance.

### The first-disagreement distance

Given two distinct streams $x \neq y$, let $\mathrm{fd}(x,y)$ be the smallest index $k$ at which $x_k \neq y_k$. Define

$$d(x,y) = \begin{cases} 0 & x = y, \\[2pt] 2^{-\mathrm{fd}(x,y)} & x \neq y.\end{cases}$$

Two streams are within distance $2^{-n}$ of each other exactly when they give **identical answers to the first $n$ questions**. So the closed ball of radius $2^{-n}$ around a stream is nothing more or less than its *prefix class*: everyone who would look the same after $n$ questions.

This distance obeys a strengthening of the usual triangle inequality, the **ultrametric inequality**:

$$d(x,z) \le \max\big(d(x,y),\, d(y,z)\big).$$

The reason is transparent. If $x$ and $y$ agree to depth $m$, and $y$ and $z$ agree to depth $n$, then $x$ and $z$ agree to depth $\min(m,n)$. Ultrametric spaces are strange and wonderful places: every triangle is isosceles, every point of a ball is its centre, and — crucially for us — balls of a given radius are either identical or disjoint. There is no partial overlap. The prefix classes at depth $n$ tile the space perfectly.

The whole space has diameter at most $1$, since any two streams agree "to depth $0$" vacuously.

---

### Small in the way that matters: compactness

Infinite sets can nevertheless be *small* in a topological sense. The interval $[0,1]$ contains uncountably many points, yet it is **compact**: every sequence in it has a convergent subsequence, every open cover has a finite subcover, and — the version we will use — it is both *complete* and *totally bounded*. The truth space has exactly this virtue.

**Total boundedness** means: for every tolerance $\varepsilon > 0$, finitely many balls of radius $\varepsilon$ suffice to cover everything. Here the proof is a single sentence. Choose $n$ with $2^{-n} < \varepsilon$. Given any stream $x$, chop it off after $n$ answers and pad the rest with "no". The truncated stream agrees with $x$ on the first $n$ questions, so it lies within $2^{-n}$ of $x$. And there are only $2^n$ possible truncations. So $2^n$ balls cover the entire uncountable space.

> **Theorem (Total boundedness).** For each $n$, the $2^n$ streams obtained by fixing the first $n$ answers and answering "no" forever after form a $2^{-n}$-net for the whole truth space.

**Completeness** means: every Cauchy sequence converges — no "holes". Suppose $u^{(1)}, u^{(2)}, u^{(3)}, \dots$ is a sequence of streams that is Cauchy. Being Cauchy at scale $2^{-n}$ says precisely that beyond some index $N(n)$, all the streams in the sequence give the *same first $n$ answers*. In other words: **each coordinate eventually freezes**. Define the limit stream $u^\star$ by reading off, coordinate by coordinate, the value each coordinate freezes at:

$$u^\star_k = u^{(N(k+1))}_k.$$

A short check confirms that beyond index $N(n)$ every term of the sequence agrees with $u^\star$ to depth $n$, i.e. lies within $2^{-n}$ of it. So $u^{(i)} \to u^\star$.

> **Theorem (Completeness).** In the truth space, Cauchy sequences stabilise coordinatewise, and the coordinatewise limit is their metric limit.

Putting the two together:

> **Theorem (Compactness).** The truth space, with the first-disagreement distance, is a compact metric space.

This is not a formality. Compactness is the reason that infinitely many candidates must "bunch up": from any infinite population of answer streams you can extract a subsequence converging to a single limiting stream. It is the reason that any continuous real-valued score on truth streams attains its maximum. In learning-theoretic language, it is the finiteness that makes an infinite hypothesis class tractable at every finite resolution.

---

### Adding a rule: the golden-mean constraint

Now let us restrict attention to a **sub**-population. Impose one constraint:

> A candidate may never answer **yes twice in a row**.

Write $\mathcal{G}$ for the set of admissible streams — those $x$ with no $k$ satisfying $x_k = x_{k+1} = \texttt{yes}$. This is the **golden-mean subshift**, one of the most-studied objects in symbolic dynamics, and it appears everywhere: in the Fibonacci substitution, in hard-square models of statistical physics, in run-length-limited codes for magnetic and optical storage (where consecutive marks would be unreadable), and in models of quasicrystals.

The first thing to notice is that the constraint is *local and finitely checkable*. A violation happens at a specific place, involving exactly two adjacent answers. That makes $\mathcal{G}$ a **closed** subset.

> **Theorem (Closedness).** The golden-mean subshift is a closed subset of the truth space; being closed inside a compact space, it is itself compact.

The proof is the ultrametric's finest hour. Suppose $x$ is *not* admissible — it says yes at positions $k$ and $k+1$. Then *every* stream within distance $2^{-(k+2)}$ of $x$ agrees with $x$ on the first $k+2$ answers, hence shares the offending pair, hence is also inadmissible. So the complement of $\mathcal{G}$ contains a ball around each of its points: it is open, and $\mathcal{G}$ is closed. One violation, detected at a finite depth, contaminates an entire neighbourhood.

The constraint is also compatible with **forgetting the first question**. Let $\sigma$ be the *shift*, which deletes the first answer:

$$\sigma(x_0, x_1, x_2, \dots) = (x_1, x_2, x_3, \dots).$$

Deleting an answer cannot create a new adjacent yes-pair, so $\sigma$ maps $\mathcal{G}$ into itself. Moreover $\sigma$ is continuous — indeed $2$-Lipschitz, $d(\sigma x, \sigma y) \le 2\, d(x,y)$, since deleting one letter can advance the first disagreement by at most one place. So $(\mathcal{G}, \sigma)$ is a compact dynamical system.

Finally, $\mathcal{G}$ is **perfect**: it has no isolated points.

> **Theorem (Perfectness).** For every admissible stream $x$ and every $\varepsilon > 0$ there is a *different* admissible stream $y$ with $d(x,y) < \varepsilon$.

The construction is charmingly concrete. Fix $n$ with $2^{-n} < \varepsilon$. Take $x$, keep its first $n$ answers, and after that answer "no" forever: the result is admissible (truncating cannot create a yes-pair) and within $2^{-n}$ of $x$. If that happens to equal $x$ itself, instead keep the first $n$ answers, then answer "no", then a single "yes", then "no" forever — a lone spike, isolated from its neighbours, so still admissible, still within $2^{-n}$, and now genuinely different. Either way we have found a distinct near neighbour.

A nonempty, compact, perfect, totally disconnected metric space is — by a classical theorem of Brouwer — a *Cantor set*. The golden-mean subshift is one.

---

### Counting: where Fibonacci enters

Here is the arithmetic heart of the story. What does the subshift look like *at resolution $2^{-n}$* — that is, how many genuinely different first-$n$-answer patterns can an admissible candidate produce?

Call a finite word of $n$ bits **admissible** if it has no two consecutive yeses, and let $A_n$ be the number of them. Classify by the first letter:

- If the word starts with **no**, the remaining $n-1$ letters form an arbitrary admissible word: $A_{n-1}$ possibilities.
- If it starts with **yes**, the next letter is forced to be **no**, and the remaining $n-2$ letters are an arbitrary admissible word: $A_{n-2}$ possibilities.

These two families are disjoint (they differ in the first letter), so

$$A_n = A_{n-1} + A_{n-2}, \qquad A_0 = 1,\; A_1 = 2.$$

That is the Fibonacci recursion, shifted by two places:

$$A_n = F_{n+2}, \qquad F_0 = 0,\ F_1 = 1,\ F_{k+2} = F_{k+1} + F_k.$$

So there are $1, 2, 3, 5, 8, 13, 21, 34, \dots$ admissible answer patterns of length $0,1,2,3,\dots$ — against $1, 2, 4, 8, 16, 32, \dots$ with no constraint.

> **Theorem (Fibonacci prefix count).** The set of length-$n$ prefixes of golden-mean streams is exactly the set of admissible $n$-letter words, and there are $F_{n+2}$ of them.

Both halves of that statement need proof. Every prefix of an admissible stream is clearly an admissible word. Conversely, every admissible word *is* realised: pad it with "no" forever, and the resulting stream is admissible and has the given prefix. The correspondence is exact — nothing is lost and nothing is spurious.

### Covering equals packing

This exact count has a beautiful geometric consequence: at every dyadic scale, the subshift's **covering number** and its **packing number** coincide.

> **Theorem (Optimal covering).** The golden-mean subshift is covered by the $F_{n+2}$ closed balls of radius $2^{-n}$ centred at the padded admissible words.
>
> **Theorem (Matching packing).** Any two distinct admissible words of length $n$, padded with "no", are points of the subshift lying at distance **strictly greater** than $2^{-n}$.

The second theorem says the $F_{n+2}$ ball centres are themselves a $2^{-n}$-separated set inside $\mathcal{G}$: no ball of radius $2^{-n}$ could contain two of them, so no covering by fewer than $F_{n+2}$ such balls exists. Covering and packing pinch the count from both sides, and the answer is a Fibonacci number on the nose. This is the rare situation where a fractal's metric combinatorics are known *exactly*, at every scale, rather than up to constants.

### The dimension of a constraint

From the exact count, the dimension falls out. Since $F_{n+2}$ grows like $\varphi^n$, where

$$\varphi = \frac{1+\sqrt 5}{2} = 1.6180\ldots$$

is the golden ratio — precisely, $\varphi^n \le F_{n+2} \le \varphi^{n+1}$ — the box-counting dimension of the subshift is

$$\dim_{\mathrm B}\,\mathcal{G} \;=\; \lim_{n\to\infty} \frac{\log F_{n+2}}{\log 2^{\,n}} \;=\; \frac{\log \varphi}{\log 2} \;=\; 0.6942\ldots$$

The unconstrained truth space, by the same computation with $2^n$ in place of $F_{n+2}$, has dimension $1$. So the single rule "never yes twice in a row" costs about $30.6\%$ of the space's dimension. Equivalently, an admissible candidate carries only $\log_2 \varphi \approx 0.694$ bits of genuinely free choice per question, rather than a full bit. That number, $\log \varphi$, is the **topological entropy** of the golden-mean shift, and it is the exact channel capacity of the corresponding run-length-limited code — the information rate a storage medium can achieve if it may never write two marks in adjacent cells.

---

### The punchline: dimension is not shape

Here is where the story acquires a twist. We have just seen that $\mathcal{G}$ is strictly thinner than $\mathcal{C}$: dimension $0.694$ versus $1$. And yet — being nonempty, compact, perfect and totally disconnected — $\mathcal{G}$ is, by Brouwer's characterisation, **homeomorphic to the whole truth space**. As topological spaces they are indistinguishable. There is even an explicit correspondence, the *golden substitution*, which reads a stream of arbitrary bits and rewrites $\texttt{no} \mapsto \texttt{no}$, $\texttt{yes} \mapsto \texttt{yes},\texttt{no}$ — automatically inserting the forbidden-pair-avoiding spacer — and which is a homeomorphism from $\mathcal{C}$ onto $\mathcal{G}$.

So the missing $30.6\%$ of dimension is **invisible to topology**. It lives entirely in the metric: in *how fast* the balls shrink, not in *which* sets are open. This is the cleanest illustration one could ask for of the difference between the topological and the metric-geometric worlds. Two spaces can be the same space, wearing different rulers.

And the difference resurfaces the moment we bring back the dynamics. The shift on the full truth space has exactly two fixed points ("always no" and "always yes"); the shift on the golden-mean subshift has exactly one, since "always yes" is forbidden. A conjugacy between dynamical systems must match fixed points, and $1 \ne 2$. So although $\mathcal{C}$ and $\mathcal{G}$ are homeomorphic as spaces, the shift maps on them are **rigidly non-conjugate** as dynamical systems. Shape is shared; motion is not.

---

### Why any of this matters

Strip away the symbols and the picture is this. A learner faces an unbounded stream of yes/no questions. The space of all possible behaviours is uncountable, but *compact*: at every finite resolution it is a finite object, and that finiteness is what makes learning, approximation, and optimisation possible at all. Impose a constraint — a rule of consistency, a physical exclusion, a coding restriction — and you carve out a closed, hence still compact, sub-population. The constraint's *strength* is measured by exactly one number: the exponential growth rate of the count of allowed finite behaviours. For the golden-mean rule that number is the golden ratio, and it is the same number whether you arrived at it by counting admissible words, by covering the space with balls, by packing separated points into it, or by asking how many bits per symbol a storage device can safely record.

The lesson generalises far past this one example. The constraint is a local rule about adjacent symbols; the consequence is a global growth rate; and the bridge between them is compactness, which lets a finite computation at each resolution add up to an exact statement about an infinite object. That bridge — finite observation controlling infinite behaviour — is the same one that underlies statistical learning, the theory of codes, the thermodynamic formalism, and the study of quasicrystals.

There is also a cautionary note in the punchline. If you only look at the topology, the constrained and unconstrained worlds are the same world. All of the content — all of the information, all of the entropy, all of the compression — is in the metric. Choosing the right ruler is not a technicality. It is the whole subject.

---

*Numbers to keep: $F_{n+2}$ admissible patterns at depth $n$; covering number equals packing number equals $F_{n+2}$; growth rate $\varphi = 1.618\ldots$; dimension and entropy rate $\log_2\varphi = 0.6942\ldots$ bits per question.*
