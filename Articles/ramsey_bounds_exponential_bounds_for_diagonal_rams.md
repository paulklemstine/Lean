# Breaking the Barrier of Four

## How a tiny exponential saving survives every change of language

Imagine a large group of people at a reception. Connect two people with a red line if they know one another and with a blue line if they do not. Ramsey theory says that once the group is large enough, there must be a set of $k$ people whose mutual connections all have the same color: either every pair are acquaintances or every pair are strangers. The smallest group size that guarantees this outcome is the diagonal Ramsey number $R(k,k)$.

This simple party-game formulation hides a formidable quantitative question. How quickly does $R(k,k)$ grow with $k$? A classical counting argument places its exponential scale near the base $4$. The difference between a bound resembling $4^k$ and one resembling $(4-\varepsilon)^k$, where $\varepsilon$ is one fixed positive number, may look cosmetic. It is not. Because the base is raised to the $k$th power, even a minute reduction compounds at every step. The ratio

$$
\frac{(4-\varepsilon)^k}{4^k}=\left(1-\frac{\varepsilon}{4}\right)^k
$$

decays exponentially. A fixed crack in the base becomes a widening gulf as $k$ grows.

The deepest work in modern Ramsey bounds is combinatorial: it discovers structure inside enormous families of colored graphs and extracts a uniform saving. But after that discovery, a quieter analytic problem remains. The saving may emerge in several different dialects. It might appear as a proportional factor $q<1$, as an exponential damping term $e^{-\delta}$, or with an inconvenient polynomial factor $k^d$ attached. To announce a clean “base strictly below four” theorem, one must prove that these dialects really express the same phenomenon and that lower-order losses cannot erase it.

That conversion is the subject here.

## Two ways to say “below four”

Let $r(k)$ be any sequence of nonnegative integers. The intended example is $r(k)=R(k,k)$, but the analysis does not depend on the internal definition of Ramsey numbers.

We say that $r$ has an **eventual sub-four upper bound** if there are a real number $\varepsilon$ with $0<\varepsilon<4$ and an integer threshold $k_0$ such that

$$
r(k)\le (4-\varepsilon)^k
$$

for every $k\ge k_0$. The word “eventual” matters: exponential estimates describe long-term growth, so finitely many early exceptions do not affect the base.

There is another natural description. We say that $r$ has a **proportional saving** if there are $q$ with $0<q<1$ and a threshold $k_0$ such that

$$
r(k)\le (4q)^k
$$

for every $k\ge k_0$. Here $q$ records the fraction of the classical base that remains. If $q=0.99$, for example, the new base is $3.96$.

The first central result is an exact equivalence.

**Normalization Theorem.** A nonnegative integer sequence has an eventual sub-four upper bound if and only if it has a proportional saving.

The proof is elementary but decisive. Starting from $q$, set

$$
\varepsilon=4(1-q).
$$

Since $0<q<1$, this gives $0<\varepsilon<4$, and the identity

$$
4q=4-4(1-q)=4-\varepsilon
$$

makes the two bounds literally identical. Conversely, starting from $\varepsilon$, set

$$
q=\frac{4-\varepsilon}{4}=1-\frac{\varepsilon}{4}.
$$

Again $0<q<1$, and $4q=4-\varepsilon$. The threshold does not change in either direction.

Why dignify a one-line algebraic identity with the name “theorem”? Because it is an interface between two styles of reasoning. A probabilistic or combinatorial argument often measures a relative saving, while a final asymptotic statement is usually advertised as an additive gap below $4$. The normalization theorem guarantees that no quantitative meaning is lost in translation.

## Exponential damping becomes an explicit gap

In analytic estimates, a saving often arrives as $e^{-\delta}$ for some $\delta>0$. Suppose that, beyond a threshold,

$$
r(k)\le \left(4e^{-\delta}\right)^k.
$$

Because $\delta>0$, one has $0<e^{-\delta}<1$. Thus the proportional factor is $q=e^{-\delta}$, and the exact additive gap is

$$
\varepsilon=4\left(1-e^{-\delta}\right).
$$

This yields the following explicit statement.

**Exponential-Saving Theorem.** If $\delta>0$ and $r(k)\le (4e^{-\delta})^k$ for all sufficiently large $k$, then $r$ has an eventual sub-four upper bound with

$$
\varepsilon=4\left(1-e^{-\delta}\right).
$$

There is no asymptotic hand-waving here. The new base is exactly

$$
4-\varepsilon=4e^{-\delta}.
$$

For small $\delta$, the approximation $1-e^{-\delta}\approx\delta$ shows that $\varepsilon\approx4\delta$. Yet the exact formula works for every positive $\delta$.

## Safe rounding of a saving

Real proofs rarely produce pretty constants. One may derive a factor such as $q=0.973418\ldots$ and prefer to report the simpler $q'=0.98$. Is this safe? Yes, provided the replacement is larger and still below $1$.

**Monotonicity Lemma.** Suppose $0<q\le q'$. If

$$
r(k)\le(4q)^k
$$

for all sufficiently large $k$, then

$$
r(k)\le(4q')^k
$$

for all sufficiently large $k$.

Both bases are positive, and raising nonnegative quantities to the same natural power preserves order. The lemma permits conservative rounding: a slightly weaker but cleaner saving remains a genuine exponential improvement whenever $q'<1$.

## Why polynomial clutter eventually disappears

The most useful stability result concerns estimates of the form

$$
r(k)\le k^d(4q)^k,
$$

where $d$ is a fixed nonnegative integer and $0<q<1$. At first glance the factor $k^d$ seems dangerous. It grows without bound, so one cannot simply discard it. But exponential scales have room to absorb fixed polynomial losses.

Choose a slightly larger proportional factor halfway between $q$ and $1$:

$$
q'=\frac{q+1}{2}.
$$

Then $q<q'<1$. Dividing the desired comparison by $(4q)^k$ reduces the question to whether

$$
k^d\le\left(\frac{q'}{q}\right)^k
$$

holds eventually. The ratio $q'/q$ is strictly greater than $1$. Every fixed power of $k$ is eventually dominated by an exponential with base greater than $1$. Therefore some threshold $N$ exists beyond which

$$
k^d(4q)^k\le(4q')^k.
$$

Now normalize $q'$ into an additive gap. Since

$$
\varepsilon=4(1-q')=2(1-q),
$$

we obtain a concrete choice of sub-four base.

**Polynomial-Absorption Theorem.** Let $d$ be a fixed nonnegative integer and let $0<q<1$. If

$$
r(k)\le k^d(4q)^k
$$

for all sufficiently large $k$, then $r$ has an eventual sub-four upper bound. In particular, after increasing the threshold if necessary, one may use

$$
r(k)\le(4-\varepsilon)^k
\qquad\text{with}\qquad
\varepsilon=2(1-q)>0.
$$

This theorem captures an important hierarchy of growth. Constants and fixed powers affect thresholds and finite-scale performance. The exponential base governs the enduring rate. A polynomial can delay when the improvement becomes visible—sometimes dramatically—but it cannot overturn a strict exponential advantage.

For example, take $q=0.9$ and $d=3$. The original estimate has the form

$$
k^3(3.6)^k.
$$

Choosing $q'=0.95$ gives the cleaner target $(3.8)^k$. The needed comparison is $k^3\le(19/18)^k$. It may fail for many moderate values of $k$, but it eventually holds. Once it does, the polynomially decorated base $3.6$ is bounded by the pure exponential base $3.8$, still safely below $4$.

## The architecture of a sub-four result

These statements clarify how a large Ramsey-theoretic proof can be organized. The combinatorial engine has one principal job: establish a fixed factor $q<1$, perhaps accompanied by a polynomial loss. The analytic interface then performs three dependable operations:

1. round a complicated factor upward if a simpler constant is desired;
2. absorb any fixed polynomial factor into a slightly larger exponential base;
3. convert the surviving proportional factor into an additive gap $\varepsilon$ below $4$.

The separation is conceptually valuable. It tells researchers exactly where the true difficulty lies. The algebra does not manufacture a saving; it preserves and translates one. If the combinatorial argument only gives factors $q_k$ that creep toward $1$ with $k$, these theorems do not magically produce a fixed gap. Uniformity is essential. But once one fixed $q<1$ has been secured, the final passage is robust.

The same architecture reaches far beyond Ramsey numbers. In randomized algorithms, a success probability may gain an exponential factor while paying polynomial overhead. In coding theory, the count of admissible words may include polynomial prefactors around a dominant exponential rate. In statistical physics, finite-size corrections often decorate a free-energy exponential. In each setting, the lesson is the same: fixed polynomial noise does not alter a strict exponential separation.

There is also a practical computational lesson. Directly evaluating $k^d(4q)^k$ for large $k$ can overflow ordinary numerical systems even when the comparison itself is easy. Taking logarithms turns the absorption test into

$$
d\log k\le k\log(q'/q).
$$

The right-hand side is linear in $k$, while the left-hand side grows only like $\log k$. This view not only avoids huge numbers; it makes the eventual victory of the exponential visually unmistakable. Plotting the two sides reveals a crossing point after which the gap only widens.

## A small gap with a large future

The practical value of these results lies in their precision. The formulas expose exactly how constants move:

$$
q\longleftrightarrow\varepsilon=4(1-q),
$$

$$
e^{-\delta}\longmapsto\varepsilon=4(1-e^{-\delta}),
$$

and, in the presence of a fixed polynomial loss,

$$
q\longmapsto q'=\frac{q+1}{2}
\longmapsto\varepsilon=2(1-q).
$$

No unspecified “small enough” gap is required, except for the threshold at which polynomial absorption begins. Even that threshold can be found numerically for concrete $q$ and $d$.

Ramsey theory is famous for the vast distance between what must exist and what can be explicitly located. Its numbers grow so rapidly that improving an exponential base by a sliver is a major qualitative event. The results developed here explain why that sliver survives the messy final stages of an argument. It survives changes of notation. It survives conservative rounding. It survives every fixed polynomial tax.

A strict exponential saving is fragile only until it becomes uniform. After that, the arithmetic is on its side: repeated multiplication turns a tiny advantage into an exponential divide.