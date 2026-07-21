# When Proof Space Changes Phase

## A census of mathematical possibility

A mathematician confronting a difficult theorem sees a challenge of ingenuity: find the decisive definition, the hidden symmetry, or the chain of implications that turns mystery into proof. But step far enough back and another picture appears. Every theorem, proof, and failed attempt is also a finite string written in an alphabet. At that scale, mathematics begins to resemble statistical physics. There is an enormous ambient population of possible strings, a much smaller distinguished population of derivable statements, and a natural question about how their relative abundance changes as longer expressions are admitted.

This viewpoint is often described metaphorically as a “phase transition in proof space.” The metaphor is attractive. Water abruptly freezes as temperature crosses a threshold; perhaps mathematical accessibility changes just as sharply when statement length crosses a critical scale. Yet metaphors become useful only after their terms are measurable. What is proof space? What is its volume? What quantity plays the role of an order parameter? What exactly counts as a sharp transition?

A clean counted model answers those questions—and also marks the limits of the analogy.

Fix an alphabet containing $k$ symbols, where $k\ge 2$. Consider every word whose length is at most $n$, including the empty word. The number of such words is

$$
S_k(n)=\sum_{i=0}^{n}k^i=\frac{k^{n+1}-1}{k-1}.
$$

This is the ambient syntactic universe at cutoff $n$. It intentionally counts nonsense along with meaningful formulas: at this stage, syntax is simply the space in which a deductive system lives. Now let $P(n)$ be the number of words of length at most $n$ belonging to some distinguished derivable family. The family might consist of encoded theorems, certified deductions, or any other rigorously counted class. Its density is

$$
\rho(n)=\frac{P(n)}{S_k(n)}.
$$

Whenever $0\le P(n)\le S_k(n)$, this order parameter lies in the unit interval: $0\le\rho(n)\le1$. It is the fraction of the available language occupied by the distinguished family.

## A crowded universe with an empty-looking core

The central phenomenon is an entropy–sparsity separation. Suppose the distinguished family grows no faster than

$$
P(n)\le C a^n
$$

for constants $C\ge0$ and $0\le a<k$. The total language grows at exponential base $k$, while the derivable family grows at the strictly smaller base $a$. Since $S_k(n)\ge k^n$, one obtains

$$
0\le\rho(n)\le C\left(\frac{a}{k}\right)^n.
$$

The ratio $a/k$ is less than $1$, so the right-hand side vanishes. Therefore

$$
\lim_{n\to\infty}\rho(n)=0.
$$

This theorem says something more subtle than “there are few theorems.” The number $P(n)$ may itself grow exponentially and become fantastically large. Nevertheless, it occupies an asymptotically negligible fraction of the even faster-growing ambient language. A city can add millions of residents while becoming less dense relative to a territory expanding still faster.

At the same time, the ambient language retains positive entropy. Define its entropy per unit cutoff by

$$
h(n)=\frac{\log S_k(n)}{n}
$$

for positive $n$. Because $S_k(n)$ is trapped between exponential quantities with base $k$, its logarithm grows like $n\log k$. Consequently,

$$
\lim_{n\to\infty}h(n)=\log k.
$$

The most informative observable is therefore not one number but a pair,

$$
\Phi(n)=\bigl(\rho(n),h(n)\bigr).
$$

Under exponential sparsity, this phase vector approaches

$$
\lim_{n\to\infty}\Phi(n)=\bigl(0,\log k\bigr).
$$

The two coordinates tell different stories. The first says that derivability becomes sparse. The second says that syntactic possibility remains exponentially rich. Vanishing density is not the collapse of proof space; it is the separation of a lower-growth family from a high-entropy background.

This pattern has analogues far beyond logic. Valid computer programs are sparse among arbitrary character strings, yet programming languages have enormous expressive entropy. Error-correcting codewords form a tiny portion of all bit strings, yet the ambient communication channel remains combinatorially vast. Chemically viable molecules occupy a constrained subset of possible molecular descriptions. In each case, structure is rare not because the universe is small, but because the universe grows faster than the structured region.

## Turning an asymptotic trend into a critical index

A limit at infinity does not by itself produce a single transition point. A density can fall, rise, and fall again while still tending to zero. To make the phase-transition language precise, one needs a regularity condition.

Assume that $\rho(n)$ is antitone: whenever $m\le n$, one has $\rho(n)\le\rho(m)$. In ordinary language, the density never increases as the cutoff expands. Choose a positive observation level $\varepsilon$ satisfying

$$
0<\varepsilon\le\rho(0).
$$

Because $\rho(n)$ tends to zero, it must eventually fall below $\varepsilon$. Because it never rises, there is a last index at which it remains at or above that level. Thus there exists a unique natural number $c$ such that

$$
\varepsilon\le\rho(c),\qquad \rho(c+1)<\varepsilon,
$$

and, more strongly, for every $n$,

$$
\rho(n)<\varepsilon\quad\Longleftrightarrow\quad c<n.
$$

This is the sharp finite crossing theorem. It partitions all cutoffs exactly: at or before $c$, the density is at least the chosen level; after $c$, it is below that level. Meanwhile the full phase vector still converges to $\bigl(0,\log k\bigr)$.

The theorem captures a genuine critical index, but it is deliberately conditional. The index depends on the encoding, the alphabet, the selected family, and the level $\varepsilon$. Most importantly, antitonicity is not automatic. Cumulative counts can acquire bursts of new derivable objects at particular lengths, causing the density to oscillate. Exponential sparsity guarantees eventual smallness, not a unique clean crossing. Monotonicity is what converts asymptotic decay into an exact one-time threshold.

A concrete example makes the scale visible. For a binary alphabet, the number of words of length at most $3$ is

$$
S_2(3)=1+2+4+8=15.
$$

If a binary derivable family contains at most $7$ words at every cutoff, then $P(n)\le7\cdot1^n$. Here $a=1<2=k$, so its density tends to zero. The numerator need not shrink; the denominator simply outruns it.

## Why the power-law prediction fails in the homogeneous model

The phase-transition analogy often travels with another suggestion: theorem lengths should follow a power law, perhaps with an exponent related to a geometric dimension of proof space. The counted model warns against making that leap.

Consider the natural geometric length profile

$$
L_k(n)=\left(1-\frac1k\right)\exp\bigl(-n\log k\bigr).
$$

Since $\exp(-\log k)=1/k$, this is simply a geometric distribution on nonnegative lengths. Its successive ratio is exactly

$$
\frac{L_k(n+1)}{L_k(n)}=\exp(-\log k)=\frac1k.
$$

That ratio is constant. By contrast, a power law of the form $n^{-\alpha}$ has successive ratio

$$
\left(\frac{n}{n+1}\right)^{\alpha},
$$

which varies with $n$ and approaches $1$. A fixed exponential entropy scale therefore predicts geometric decay, not a power law. Exponential growth of the ambient language does not force scale-free theorem lengths.

Power laws may still arise, but they need an additional mechanism. One plausible source is heterogeneity. Imagine many proof regimes, each with its own geometric decay parameter, mixed across scales. If the mixture places substantial weight near very slow decay, the aggregate can acquire a heavy tail. In that picture, the power law comes not from one homogeneous proof space but from variation among many proof environments.

## What the model does—and does not—say about incompleteness

The language of “Gödel thresholds” can be misleading. Incompleteness theorems concern what sufficiently expressive formal systems can prove about arithmetic, subject to hypotheses such as consistency. They do not, by themselves, supply a numerical statement length at which provability suddenly changes. A critical index in the counted model requires far more data: a concrete encoding, a cumulative count $P(n)$, a positive level $\varepsilon$, exponential sparsity, and antitone density.

Accordingly, the sharp crossing theorem is not a numerical consequence of incompleteness alone. Nor is its index universal across encodings. Change the code and lengths change; change the alphabet and the entropy scale changes; change $\varepsilon$ and the crossing moves. The theorem identifies sufficient mathematical conditions for a threshold rather than claiming that every deductive system possesses an intrinsic one.

That distinction is a strength. It separates three questions that are too easily blended together. First, incompleteness asks whether every truth of a relevant kind is derivable. Second, counting asks how a chosen derivable family grows within an ambient syntax. Third, threshold geometry asks whether a density crosses a selected level once and for all. These questions interact, but none substitutes for the others.

## A research program after the metaphor

The counted framework turns a speculative image into a tractable program. The first challenge is recoding. If two efficient prefix-free encodings translate into one another with at most a bounded additive overhead, their metric balls differ mainly by a bounded radial shift. One may then ask whether their critical indices move by a comparably bounded amount after correcting for alphabet entropy.

The second challenge is oscillation. Real deductive counts may not be antitone in density. Submultiplicative growth, perhaps up to polynomial factors, could suppress fluctuations after logarithmic smoothing and yield a bounded transition window rather than a perfectly sharp step.

The third challenge is internal geometry. A single density treats all derivable statements alike. Partitioning them by proof-theoretic complexity could reveal several entropy dimensions—a multifractal spectrum of theorem families—even when every stratum has zero density in the full language.

Finally, the failure of the naive power-law prediction points toward mixtures. A continuum of geometric regimes, especially one weighted toward small entropy parameters, may generate regularly varying tails. That hypothesis is both more precise and more testable than the claim that exponential syntax alone creates a power law.

The phase-transition metaphor survives, but in disciplined form. The ambient universe expands with entropy $\log k$. A derivable family whose exponential rate is smaller than $k$ fades to zero density. If that density never increases, every admissible positive level has one and only one finite crossing. And a homogeneous entropy model yields geometric, not power-law, lengths.

The deepest lesson is not that all great theorems sit at a universal critical point. It is that proof space has multiple observables, and they must not be confused. Syntactic abundance can coexist with derivational scarcity. Asymptotic decay can exist without a sharp transition. Entropy can control exponential ratios without producing scale-free laws. Once those distinctions are visible, “phase transition” stops being merely a dramatic phrase and becomes a collection of exact mathematical questions.