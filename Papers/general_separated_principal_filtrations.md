# How Far Down Can You Divide?

### A guided tour of separated principal filtrations

---

## 1. The question a child can ask

Name a whole number divisible by $2$, and by $4$, and by $8$, and by $16$, and by every power of $2$ after that.

There is exactly one: **zero**. The reason is a ruler. If $m \neq 0$ and $2^n \mid m$, then $2^n \le |m|$ — and no fixed number outruns every power of two. In the language of ideals,

$$\bigcap_{n \ge 0} (2^n) = \{0\} \qquad \text{in } \mathbb{Z}.$$

This page is about what happens when you replace $\mathbb{Z}$ by *any* ring without zero divisors and $2$ by *any* element $a$. The tower of ideals

$$R = (a^0) \supseteq (a) \supseteq (a^2) \supseteq (a^3) \supseteq \cdots$$

is called the **principal filtration at $a$**, and it is called **separated** when the intersection of all its stages is $\{0\}$ — equivalently, when *the only element divisible by every power of $a$ is $0$*.

Before reading another line, go break it. The explorer below lets you choose the ring, the divisor $a$, and a target $x$, then divides as far as it can. Two of the three rings behave; the third does not.

{{interactive_demo:0}}

> **Try this first.** Start in $\mathbb{Z}$ with $a = 2$, $x = 96$: the descent halts after five steps, and $\mathrm{ord}_2(96) = 5$. Then press **“Show me the surprise.”**

---

## 2. Two degenerate cases, out of the way

Two elements decide themselves instantly.

- If $a = 0$, then $(a^1) = \{0\}$ already, so the filtration is separated for a boring reason.
- If $a$ is a **unit** (invertible, like $\pm 1$ in $\mathbb{Z}$), then $a^n$ divides everything, the filtration is constantly all of $R$, and separation fails as badly as possible.

So the interesting elements are the **nonzero non-units**: $2$ in $\mathbb{Z}$, $X$ in $k[X]$, a prime, an irreducible polynomial. The naive guess is that being a nonzero non-unit is enough. Section 6 will demolish that guess.

---

## 3. The first idea: a ruler that grows

Why does the schoolchild's argument work? Not because integers are special — because integers carry a **size** that multiplication by $2$ inflates.

> **Definition.** A function $v : R \to \mathbb{N}$ is a **height function for $a$** if
> $$v(x) < v(ax) \qquad \text{for every } x \neq 0.$$

It need not be additive, need not be canonical, need not be anything. It only has to tick upward.

> **Height Criterion.** In a domain, if *any* height function for $a$ exists, then the principal filtration at $a$ is separated.

<details>
<summary><strong>Click to reveal the two-line proof</strong></summary>

An induction gives the growth bound

$$n + v(y) \;\le\; v(a^n y) \qquad \text{for all } n \ge 0,\ y \neq 0,$$

since each multiplication by $a$ raises $v$ by at least one and $a^n y \ne 0$ in a domain.

Now suppose $x \ne 0$ is divisible by every power of $a$. Choose the *single* index $n = v(x) + 1$ and write $x = a^n y$. Since $x \ne 0$ we have $y \ne 0$, so

$$v(x) = v(a^n y) \;\ge\; n + v(y) \;=\; v(x) + 1 + v(y) \;>\; v(x),$$

which is absurd. Hence $x = 0$. $\blacksquare$

Notice what is absent: no Noetherian hypothesis, no unique factorization, no chain condition, no finiteness of any kind. One natural number that goes up is the whole engine.
</details>

Two instant consequences, and they are the two classical pillars of local algebra:

| Ring | Height | Conclusion |
|---|---|---|
| $\mathbb{Z}$, $a$ with $\lvert a\rvert \ge 2$ | $v(x) = \lvert x\rvert$ | $\bigcap_n (a^n) = 0$ |
| $k[X]$ over a domain $k$, $a = X$ | $v(p) = \deg p$ | $\bigcap_n (X^n) = 0$ |

The picture below draws all three moving parts at once: the filtration thinning out inside a window of $\mathbb{Z}$, the adic absolute value it induces, and the linear growth bound that drives the proof.

{{visualization:0}}

And here is the height check, made executable — a routine that verifies a candidate ruler on a sample and converts it into an explicit bound on how long divisibility can persist.

{{algorithm:1}}

---

## 4. The second idea: chains instead of rulers

Textbooks usually take a different road. Say a domain is **well founded for divisibility** if it contains no infinite sequence $x_0, x_1, x_2, \dots$ in which each $x_{i+1}$ *properly* divides $x_i$. Every [Noetherian](https://en.wikipedia.org/wiki/Noetherian_ring) domain qualifies, and so does every [unique factorization domain](https://en.wikipedia.org/wiki/Unique_factorization_domain).

> **Krull Separation (principal case).** In a domain well founded for divisibility, the principal filtration at every non-unit $a$ is separated.

<details>
<summary><strong>Click to reveal the proof, and the dichotomy it produces</strong></summary>

If $x \ne 0$ were divisible by every power of $a$, write $x = a^n y_n$. Then $y_n = a\,y_{n+1}$, and $y_{n+1}$ properly divides $y_n$ — properly, because if $y_{n+1} \mid y_n$ as well then cancelling would make $a$ a unit. That is an infinite properly descending divisibility chain, contradicting well-foundedness.

Combining with the fact that units never separate, one gets a clean dichotomy in any nontrivial domain well founded for divisibility:

$$\text{the filtration at } a \text{ is separated} \iff a \text{ is not a unit}.$$

This is the principal-ideal case of the **Krull intersection theorem**, and it specialises separately to Noetherian domains and to unique factorization domains — separately, because [UFDs need not be Noetherian](https://en.wikipedia.org/wiki/Unique_factorization_domain).
</details>

---

## 5. The surprise: the two ideas are the same idea

Chain conditions look strictly stronger than rulers. They are not. Over a domain, the soft criterion is also **necessary**.

> **Heights Characterise Separation.** For a domain $R$ and $a \in R$:
> $$\bigcap_n (a^n) = 0 \iff \text{there exists } v : R \to \mathbb{N} \text{ with } v(x) < v(ax) \text{ for all } x \ne 0.$$

The reason is that separation *manufactures its own ruler*: when it holds, every nonzero $x$ has a largest exponent $\mathrm{ord}_a(x)$ with $a^{\mathrm{ord}_a(x)} \mid x$, and multiplying by $a$ raises it by **exactly** one.

<details>
<summary><strong>Click to reveal the increment law — and where the domain hypothesis is spent</strong></summary>

Let $m = \mathrm{ord}_a(x)$ and $x = a^m c$. Then $ax = a^{m+1}c$, so $\mathrm{ord}_a(ax) \ge m+1$. Conversely, if $a^{m+2} \mid ax$, say $ax = a^{m+2}c'$, then cancelling a single factor of $a$ — legitimate **only** in a ring without zero divisors — gives $x = a^{m+1}c'$, contradicting maximality of $m$. Hence

$$\mathrm{ord}_a(ax) = \mathrm{ord}_a(x) + 1.$$

So $\mathrm{ord}_a$ is itself a height function. Better still, it is the *smallest* one: if $v$ is any height and $x = a^m c$ with $c \ne 0$, the growth bound gives $m + v(c) \le v(x)$, hence

$$\mathrm{ord}_a(x) \le v(x) \quad \text{for every } x \ne 0.$$

The adic order is therefore the canonical, tightest witness of separation — a universal object among rulers.
</details>

**This is the conceptual payoff of the whole subject.** A Krull-type intersection theorem is not fundamentally a statement about ascending chains of ideals. It is a statement about the existence of an $\mathbb{N}$-valued height. Chain conditions matter only because they are a convenient factory for producing heights.

Here is the canonical height, computed:

{{algorithm:0}}

And here is the same theory exercised end to end, across all the results on this page:

{{demo:0}}

---

## 6. Breaking it: a ring where the child is wrong

Now the promised counterexample. Let

$$S = \mathbb{Z} + X\,\mathbb{Q}[X]$$

be the ring of rational polynomials whose **constant term is an integer**. So $3 + \tfrac{1}{7}X - \tfrac{5}{2}X^3$ belongs to $S$, but $\tfrac{1}{2} + X$ does not. It is a subring of $\mathbb{Q}[X]$, hence a domain, and $2$ is a nonzero non-unit of it (its inverse would be the constant $\tfrac12$, whose constant term is not an integer).

And yet

$$X = 2^n \cdot \frac{X}{2^n}, \qquad \frac{X}{2^n} \in S \text{ for every } n,$$

because $X/2^n$ has constant term $0$, which is certainly an integer. So $X$ is divisible by every power of $2$ inside $S$, while $X \neq 0$. **Separation fails.**

Go back to the explorer above, choose $\mathbb{Z} + X\mathbb{Q}[X]$, and watch the descent refuse to stop.

<details>
<summary><strong>Click to reveal the exact computation of the intersection</strong></summary>

$$\bigcap_{n} (2^n) \;=\; X\,\mathbb{Q}[X] \;=\; \{p \in S : p(0) = 0\}.$$

($\supseteq$) is the trick above. For ($\subseteq$): if $p \in S$ has constant term $m \in \mathbb{Z}$ and $p = 2^n q$ with $q \in S$ of constant term $k \in \mathbb{Z}$, then comparing constant terms gives $m = 2^n k$. So $m$ is an integer divisible by every power of $2$, whence $m = 0$ by the schoolchild's theorem. Note the delicious circularity: the *failure* in $S$ is proved by *invoking* the original fact in $\mathbb{Z}$.
</details>

The failure is not a curiosity; it is a cascade. Every consequence below follows from that single computation:

1. Being a nonzero non-unit is **not** enough for separation.
2. $S$ is not well founded for divisibility ($X, X/2, X/4, \dots$ descends forever), hence is **neither Noetherian nor a UFD**.
3. By the characterisation of Section 5, **no $\mathbb{N}$-valued height function for $2$ exists on $S$ at all** — for *every* conceivable $v$ there is a nonzero $x$ with $v(2x) \le v(x)$. A purely ideal-theoretic computation rules out every possible measuring device.
4. The $2$-adic topology on $S$ is not Hausdorff, and $X\mathbb{Q}[X]$ is exactly what the map into the $2$-adic completion destroys.

{{visualization:1}}

Why does $S$ misbehave? It has **two independent scales**. Dividing by $2$ costs one unit on the integer scale of the constant term, and *nothing* on the rational scale of the higher coefficients. The value monoid is lexicographic of rank two, and a lexicographic order is **non-archimedean**: no finite number of steps of size $(1,0)$ ever spans a gap of type $(0,1)$. Since $\mathbb{N}$ *is* archimedean, Section 5 says it precisely:

> **Separation is an archimedean axiom in disguise.**

The exact intersection is decidable by a single test on the constant coefficient — here is the routine, with the divisibility witnesses printed out:

{{algorithm:2}}

---

## 7. A third face: fixed points on the ideal lattice

Instead of asking *when* $J = \bigcap_n (a^n)$ vanishes, ask what it *is*. Call an ideal $I$ **$a$-divisible** if $I \subseteq (a)\cdot I$ — every element of $I$ is $a$ times another element of $I$, forever.

> **Greatest Fixed Point.** Over a domain, $J = (a)\cdot J$, and $J$ is the *greatest* $a$-divisible ideal. Hence separation says exactly: **the map $I \mapsto (a)I$ has no nonzero fixed point.**

<details>
<summary><strong>Click to reveal both inclusions, and the Nakayama proof they unlock</strong></summary>

*Any ideal $I$ with $I \subseteq (a)I$ lies inside $J$*: by induction $I \subseteq (a^n)$ for each $n$, since $I \subseteq (a)I \subseteq (a)(a^n) = (a^{n+1})$.

*$J$ is itself $a$-divisible*: if $x \in J$, write $x = ay$; for each $n$ write $x = a^{n+1}c$, and cancelling $a$ gives $y = a^n c$. So $y \in J$ and $x \in (a)J$.

**Nakayama's proof of the Noetherian case.** In a Noetherian ring $J$ is finitely generated, and $J \subseteq (a)J$. The determinant-trick form of [Nakayama's lemma](https://en.wikipedia.org/wiki/Nakayama%27s_lemma) produces $r$ with $r \equiv 1 \pmod{(a)}$ and $rJ = 0$. Writing $r - 1 = at$: if $r = 0$ then $a(-t) = 1$, making $a$ a unit. So $r \ne 0$, and in a domain $rJ = 0$ forces $J = 0$. Two structurally different proofs of one theorem — multiplicity counting and Nakayama — which is usually a sign that the theorem is pointing at something real.
</details>

In $S$, this description identifies the obstruction precisely: $X\mathbb{Q}[X]$ is the **greatest $2$-divisible ideal** of $\mathbb{Z} + X\mathbb{Q}[X]$. Failure of separation is not a void; it is a canonical object you can name.

---

## 8. Why anyone cares: the $p$-adic world

Separation is the licence that makes [$p$-adic analysis](https://en.wikipedia.org/wiki/P-adic_number) possible. Let $a$ be a **prime** element of a domain whose filtration is separated. Then the adic order is additive, $\mathrm{ord}_a(xy) = \mathrm{ord}_a(x) + \mathrm{ord}_a(y)$, and ultrametric, $\mathrm{ord}_a(x+y) \ge \min\{\mathrm{ord}_a x, \mathrm{ord}_a y\}$ — the latter simply because a common divisor of two elements divides their sum. Define

$$\|x\|_a = 2^{-\mathrm{ord}_a(x)}, \qquad \|0\|_a = 0.$$

> **The Adic Absolute Value.** $\|\cdot\|_a$ is a genuine absolute value: nonnegative, vanishing exactly at $0$, multiplicative, and satisfying the **strong triangle inequality**
> $$\|x+y\|_a \le \max\{\|x\|_a, \|y\|_a\} \le \|x\|_a + \|y\|_a,$$
> with $\|a\|_a = 1/2$.

The crucial clause is "vanishing exactly at $0$" — **that clause *is* separation**. Without it, some nonzero element would have infinite order, the norm would vanish where it must not, and the metric would die. Specialising:

- $R = \mathbb{Z}$, $a = p$: the $p$-adic absolute value, and on completing, the $p$-adic numbers.
- $R = k[X]$, $a = X$: the order of vanishing at the origin, and on completing, formal power series.

Separation also has a purely topological and a purely categorical face:

> **Separation $\iff$ the $a$-adic topology is Hausdorff $\iff$ the map $R \to \varprojlim_n R/(a^n)$ is injective.**

In words: *nothing is invisible to the $a$-adic microscope*. Two distinct elements are always distinguished at some finite level.

Finally, a warning against equating "well behaved" with "Noetherian". The ring $\mathbb{Q}[X_0, X_1, X_2, \dots]$ in countably many variables is **not** Noetherian — its ideal of all variables is not finitely generated, since any finite generating set mentions only finitely many variables and an evaluation detects a missing one. But it *is* a unique factorization domain, so every non-unit there has separated filtration, $\bigcap_n (X_0^n) = 0$, and it carries a bona fide non-archimedean absolute value with $\|X_0\| = 1/2$. Adic analysis reaches genuinely beyond the Noetherian world.

---

## 9. What to take away

Five statements, one condition. Over a domain, all of these are equivalent:

| Face | Statement |
|---|---|
| **Arithmetic** | every nonzero element has finite $a$-multiplicity |
| **Combinatorial** | there is an $\mathbb{N}$-valued height $v$ with $v(x) < v(ax)$ off zero |
| **Order-theoretic** | the only ideal $I$ with $I \subseteq (a)I$ is $0$ |
| **Topological** | the $a$-adic topology is Hausdorff |
| **Categorical** | the map into the $a$-adic completion is injective |

Chain conditions — Noetherian, unique factorization, well-founded divisibility — are **sufficient, not necessary**; their role is to manufacture a height, and $\mathrm{ord}_a$ is the minimal height they manufacture. The boundary is marked exactly by $\mathbb{Z} + X\mathbb{Q}[X]$, where $X$ survives division by $2$ forever and all five faces fail at once.

The moral, one sentence: **repeated division terminates precisely when the ring's scale of measurement is archimedean.**
