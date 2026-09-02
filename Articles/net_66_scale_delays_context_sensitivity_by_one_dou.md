# The Octave Law: How Scale Buys Time, Not Freedom

## A budget, a gate, and a knee

Imagine you are running a machine that reads long documents. To answer a question about
the text, the machine consults a memory of everything it has read so far — but consulting
*everything* is expensive, and the cost grows with the length of the document. So you
economize: at each step, the machine is allowed to look at only $k$ remembered items,
the $k$ it judges most relevant. Call $k$ the **key budget**.

If $k$ is generous, the economized machine behaves exactly like the extravagant one. If
$k$ is stingy, quality degrades. Somewhere in between there is a threshold. Define the
**retained quality** $A(k) \in [0,1]$ as the fraction of the machine's decisions that
survive the economization at budget $k$ — the fraction that agree with what the
full-memory machine would have done. Two things are true of $A$ by construction: it is
**monotone** (more budget never hurts: $k \le k'$ implies $A(k) \le A(k')$), and it
reaches $1$ once the budget covers the whole memory.

Now fix a **gate** $g$ — a quality bar we insist on; throughout this article $g = 0.98$,
meaning "we tolerate a $2\%$ deviation." The object of study is the **knee**:

$$k^*(A, g) \;=\; \min\{\, k \in \mathbb{N} : A(k) \ge g \,\},$$

the smallest budget that clears the bar. The knee is a single integer that summarizes an
entire quality curve, and it is the natural currency of a memory budget: it tells you
exactly what you must pay.

The question this article is about is how the knee moves when you change the two things
you can change: the **length of the document** and the **size of the machine**.

## Reading contexts in octaves

Document lengths in this business come in powers of two, so it is natural to measure them
logarithmically. Write the context length as

$$\mathrm{ctx} = 512 \cdot 2^{\,j}, \qquad j = 0, 1, 2, \dots$$

and call $j$ the **octave**: octave $0$ is $512$ tokens, octave $1$ is $1024$, octave $2$
is $2048$. A **knee chain** is then just a function $K : \mathbb{N} \to \mathbb{N}$
assigning to each octave the budget you must pay there. Model sizes come in a ladder too;
index them $s = 0, 1, 2, \dots$, with $s = 0$ the small model, $s = 1$ the next one up,
and so on. A **knee table** $F(s, j)$ records the budget needed at scale $s$ and octave
$j$. This two-dimensional table is what we want to understand.

Before the measurement there were three plausible stories, and it is worth stating them
plainly because two of them turn out to be *impossible*, not merely false.

- **P1 — Sensitivity.** As the document gets longer, the required budget rises.
- **P2 — Flattening.** A bigger machine becomes insensitive to context: its chain goes
  flat and stays flat.
- **P3 — Amplification.** A bigger machine, having more to remember, becomes *more*
  sensitive: it needs a bigger budget than the small one at the same context.

## What was measured

Two model scales, three contexts, one gate. The knees:

| scale | ctx 512 | ctx 1024 | ctx 2048 |
|-------|---------|----------|----------|
| small | $16$    | $20$     | $24$     |
| large | $16$    | $16$     | $20$     |

Read the two rows as chains: $K_0 = \{16, 20, 24\}$ and $K_1 = \{16, 16, 20\}$. P1 is
confirmed — the large model's flat run *does* break upward, at $2048$, from $16$ to $20$.
P2 is dead: the flatness that survived to $1024$ does not survive to $2048$. And P3 is
dead too, in the most direct way possible: at $2048$ the *large* model needs $20$ keys
while the small one needs $24$. Scale does not amplify context sensitivity; it does not
abolish it either.

What it does is postpone it. Line the two rows up and the pattern is unmistakable: the
large model's chain is the small model's chain **slid one octave to the right**. The
value $20$, which the small model first demands at $1024$, the large model first demands
at $2048$. The value $16$, the small model's entry price, is repeated once more at the
large scale before the chain starts climbing. In symbols,

$$K_1(j+1) = K_0(j) \quad \text{for all } j, \qquad K_1(0) = K_0(0).$$

**Doubling the model buys exactly one doubling of context, for free.** That is the
one-octave law.

## Rigidity: two local rules determine everything

Here is where a measurement becomes a theorem. Define the **octave shift** of a chain by
$s$ steps:

$$(\sigma^s K)(j) = K\big((j - s)^+\big),$$

where $(j-s)^+$ is truncated subtraction — below its base context a shifted chain simply
repeats its boundary value, because scale buys headroom, it does not extrapolate the
curve backwards into contexts shorter than the shortest one measured.

Now suppose a knee table $F(s,j)$ obeys just two rules, each a local statement about
adjacent cells:

- **Exchange law.** $F(s+1, j+1) = F(s, j)$ — one scale doubling buys one context
  doubling.
- **Boundary law.** $F(s+1, 0) = F(s, 0)$ — at the shortest context, scale changes
  nothing.

**Rigidity Theorem.** *If $F$ obeys the exchange and boundary laws, then
$F(s, j) = F(0, (j-s)^+)$ for every $s$ and $j$. The entire two-dimensional table is
determined by its first row.*

The proof is a two-line induction on $s$: the boundary law handles the $j = 0$ column and
the exchange law handles everything else. But its consequence is not small. It says the
scale $\times$ context table has exactly one degree of freedom — the base chain — and
that measuring a second scale is not measuring a new function, but *testing a
prediction*.

## Two horns die by structure, not by data

Rigidity has a striking corollary. Suppose, in addition, that the base chain is monotone
in context — longer documents never need *fewer* keys, which is the content of P1. Then:

**Antitonicity in scale (P3 is impossible).** $F(s+1, j) \le F(s, j)$ for all $s, j$.

Proof: $F(s+1,j) = F(0, (j-s-1)^+)$ and $F(s,j) = F(0,(j-s)^+)$, and
$(j-s-1)^+ \le (j-s)^+$, so monotonicity of the base chain does the rest. A bigger model
can *never* require a bigger budget at the same context. The "scale amplifies
sensitivity" horn is excluded before any experiment is run — it contradicts the shape of
the law itself.

**No flattening (P2 is impossible).** If the base chain is unbounded — if long enough
documents eventually demand any budget you name — then so is every scaled chain: for
every bound $b$ and every scale $s$ there is an octave $j$ with $F(s,j) > b$. And in the
weaker non-constant form: if the base chain rises anywhere, then every scaled chain rises
somewhere.

Proof: whatever octave $j$ witnesses the rise at the base scale, the octave $j + s$
witnesses it at scale $s$, because $(j+s) - s = j$.

So the measurement was never adjudicating between three hypotheses. Given the exchange
law and context monotonicity, two of the three horns are structurally unavailable, and
the only free question is *the rate* — how many octaves does one scale doubling buy?

## The budget table: a staircase with triangular area

Turn the question inside out. Instead of asking "what budget does this context need?",
ask "how far does this budget reach?" Define the **first failing octave** of a chain $K$
at budget $b$:

$$\varphi_K(b) = \min\{\, j : K(j) > b \,\},$$

the first document length the budget cannot serve. For a monotone chain this is an exact
adjoint of the knee: octave $j$ is served by budget $b$ if and only if $j < \varphi_K(b)$.

**One-octave budget law.** If the shifted chain $\sigma^s K$ is compared with $K$ at a
budget that already covers the base context, then
$$\varphi_{\sigma^s K}(b) = \varphi_K(b) + s.$$
Each scale doubling extends the reach of a *fixed* budget by exactly one context
doubling.

For the measured data with $b = 16$: the small model's $16$-key budget first fails at
octave $1$ (i.e. it covers $512$ and no more), and the large model's first fails at
octave $2$ (it covers $512$ and $1024$). A $16$-key budget covers the small model to
$512$ and the large model to $1024$. That is the verdict in its useful, engineering form.

Draw the $S \times J$ corner of the served region — the cells $(s,j)$ with
$F(s,j) \le b$ — and you get a staircase climbing one cell per row. Its area is a
triangular number: writing $f = \varphi_{K_0}(b)$ for the base reach, and assuming the
context window is wide enough to hold the whole staircase ($f + S \le J + 1$),

$$2\,\#\{\text{served cells}\} \;=\; 2Sf + S(S-1).$$

And when the base chain is arithmetic — constant increment $\delta$ per octave, as the
measured $\{16, 20, 24\}$ is with $\delta = 4$ — the law collapses to a single clean
formula:

$$k^*(s, j) \;=\; k_0 + \delta \cdot (j - s)^+ .$$

Scale and context enter only through the ratio $\mathrm{ctx}/2^s$. There is one variable,
not two.

## Is the rate really one?

Nothing in the abstraction insists on one octave per doubling. A **rate-$p$ law** reads
$F(s+1, j+p) = F(s,j)$, with $F(s+1, i) = F(s,0)$ for $i < p$: one scale doubling buys
$p$ context doublings. Every one of these laws is rigid in the same way — a rate-$p$
table is its base chain translated by $ps$ octaves — every one of them kills P2 and P3 by
the same argument, and in every one of them a fixed budget gains exactly $p$ octaves per
scale step. The whole spectrum behaves alike qualitatively; the rate is the one number
that data must supply.

And the data supplies it, from a single cell. **Rate identification.** If the base chain
is strictly increasing and two rate laws predict the same first scale step, their rates
coincide. Concretely: any rate-$p$ law whose base row is the measured $\{16, 20, 24\}$
and which reproduces the measured large-model cell at $2048$ — namely $20$ — must have
$p = 1$. The rate-$2$ law, which would have one doubling of model buy two doublings of
context, predicts $16$ at that cell. The measurement says $20$. One cell, one refutation.

Every rate remains *consistent* as a law — for any positive $p$ and any monotone base
chain there is a genuine rate-$p$ table — so this is a statement about the world, not
about the coherence of the hypotheses.

## Noise cannot dissolve it

Real tables never satisfy an equation exactly; knees are read off finite grids and each
cell carries error. So the law needs a stability theorem, and it has one. Call a table an
**$\varepsilon$-approximate family** if the exchange and boundary comparisons hold up to
an additive $\varepsilon$: $|F(s+1,j+1) - F(s,j)| \le \varepsilon$ and
$|F(s+1,0) - F(s,0)| \le \varepsilon$. Then

$$\big|\,F(s,j) - F(0, (j-s)^+)\,\big| \;\le\; \varepsilon \cdot s .$$

Error accumulates only *linearly* in the number of scale doublings, so a two-scale ladder
like this one is within $\varepsilon$ of exactly shifted. Setting $\varepsilon = 0$
recovers the rigidity theorem, so the stable statement is a genuine deformation of the
exact one.

Identification survives noise too: if the base chain rises by at least $\delta$ keys per
octave and the noise level satisfies $\varepsilon < \delta$, the rate is still uniquely
determined. Here $\delta = 4$ keys per doubling, so **any knee error up to three keys
still pins the rate at one octave.**

## The razor: what a finite sweep can honestly claim

Now the uncomfortable part, and the reason this round is worth reporting carefully. The
large model's $2048$ row was not measured as a knee; it was measured as a sweep of the
budget over the grid $\{8, 12, 16, 20, 24, 32\}$:

| $k$ | $8$ | $12$ | $16$ | $20$ | $24$ | $32$ |
|-----|-----|------|------|------|------|------|
| retained | $0.9597$ | $0.9715$ | $0.9785$ | $0.9817$ | $0.9846$ | $0.9867$ |

The gate is $0.98$. The cell at $k = 16$ reads $0.9785$ — it misses by $0.0015$, roughly
one standard error. The reported knee $20$ is the first grid point that clears the bar.
But is the *true* knee $20$?

**The bracket theorem.** Over all monotone curves reproducing those six numbers exactly,
the set of achievable knees is *precisely* the half-open interval $(16, 20]$. Every one
of $17, 18, 19, 20$ is the knee of an honest monotone curve matching the measurement at
every grid point, and nothing outside is. So the sweep determines the bracket and nothing
finer: the reported $20$ is the conservative right endpoint of an interval, not an
identified value.

**And one standard error reopens the left endpoint.** There is a monotone curve within
$0.0015$ of the measurement at *every* grid point whose knee is exactly $16$. The failing
razor cell is inside the noise, so the data does not close the bracket at its left end.
Both facts are stated because both are true, and reporting the first without the second
would be reporting half a measurement.

There is a general principle behind this: a finite sweep sees the true knee exactly when
the true knee happens to lie on the grid, and otherwise reports a strict overestimate.
The honest output of a grid sweep is an interval $(p, k]$ between the last failing and
the first passing grid point.

Finally, the row is not merely a table of six numbers: one can exhibit an explicit
population of $10{,}000$ prediction windows, each with a stated key demand, whose
agreement curve reproduces all six values on the nose and whose knee at the gate is $20$.
The measurement is realizable as a genuine demand profile, so nothing in the analysis
depends on the numbers being a coincidence of arithmetic.

## What it predicts, and how to break it

A law is worth what it forbids. This one forbids a great deal at the next rung of the
ladder. If the one-octave law extends to the next scale doubling, the next model's chain
must read

$$\{16,\; 16,\; 16,\; 20\} \quad \text{at } 512,\ 1024,\ 2048,\ 4096,$$

with its first upward break moved out to $4096$ and a $16$-key budget covering it all the
way to $2048$. A single measured cell at $2048$ on that model decides the matter: $16$
confirms, anything else refutes.

There is a subtler question underneath. The integer rates are settled — rate $p$ is
rigid, consistent, and the data forces $p = 1$. But a *fractional* rate $p/q$, meaning
$F(s+q, j+p) = F(s, j)$, is invariance of the table under the sublattice of
$\mathbb{Z}^2$ generated by $(q, p)$, and rate $1/2$ — two model doublings buying one
context doubling — agrees with rate $1$ on the two scales measured and first differs at
the third. A knee table with a rational exchange rate is exactly a function on the
quotient monoid $\mathbb{N}^2 / \langle (q,p) \rangle$, so the admissible rates are
classified by which quotients admit a monotone non-constant representative — a purely
order-theoretic question, with no models in it at all.

## Why this is a nice shape for a law

The lesson generalizes beyond memory budgets. When a resource curve depends on two
parameters, the interesting question is rarely "does the second parameter help?" — it is
"in what units does it help?" Here the answer is unusually clean: scale and context are
not two independent axes but a single axis, $\mathrm{ctx}/2^s$, and everything a
practitioner needs — the knee at any cell, the reach of any budget, the area of the
served region — follows from one measured chain and one measured integer.

Scale, in this arena, is not a solvent. It does not dissolve the dependence on context;
it does not make it worse. It buys exactly one doubling of grace, and then the same wall
arrives, one octave later.
