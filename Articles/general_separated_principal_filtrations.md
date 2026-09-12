# How Far Down Can You Divide? The Hidden Geometry of Repeated Division

## A child's question

Ask a schoolchild for a whole number divisible by $2$, then by $4$, then by $8$, then by $16$, and so on forever. After a few rounds they will shrug and say: *only zero*. And they are right. If $n$ is an integer and $2^k$ divides $n$ for every $k$, then $|n| \ge 2^k$ unless $n = 0$, and no fixed number beats every power of two. So the chain of ideals
$$(2) \supset (4) \supset (8) \supset (16) \supset \cdots$$
shrinks all the way down to nothing:
$$\bigcap_{n \ge 0} (2^n) = \{0\}.$$

This is the sort of fact that feels too obvious to be interesting. It is not. Pull on it and out comes a surprisingly deep thread: the Krull intersection theorem, the $p$-adic numbers, Nakayama's lemma, fixed points on lattices of ideals, and — at the end — a strange ring of polynomials in which the schoolchild's answer is *wrong*.

This article is about what happens when you replace "the integers and the number $2$" with "any ring $R$ and any element $a$", and ask the same question: **what survives infinitely many divisions by $a$?**

## Setting the stage

Let $R$ be a commutative ring without zero divisors — a *domain*. (Think of the integers $\mathbb{Z}$, or the polynomials $k[X]$ with coefficients in a field $k$.) Fix an element $a \in R$. For each $n \ge 0$, let
$$(a^n) = \{a^n y : y \in R\}$$
be the set of multiples of $a^n$. These sets nest downward:
$$R = (a^0) \supseteq (a) \supseteq (a^2) \supseteq \cdots$$
We call this descending tower the **principal filtration at $a$**, and we say it is **separated** if its total intersection collapses:
$$\bigcap_{n \ge 0} (a^n) = \{0\}.$$
Unwinding the definition, separation says exactly this:

> **The only element of $R$ divisible by every power of $a$ is $0$.**

That single sentence is the object of study. A fair amount of algebra turns out to be encoded in it.

Two degenerate cases settle themselves immediately. If $a = 0$, then $(a^1) = \{0\}$ already, so the filtration is separated in the most boring possible way. At the other extreme, if $a$ is a *unit* — invertible, like $\pm 1$ in $\mathbb{Z}$ — then every power of $a$ divides everything, the filtration is constantly all of $R$, and separation fails as badly as it can (in any ring with $1 \neq 0$). So the interesting elements are the nonzero non-units: $2$ in $\mathbb{Z}$, $X$ in $k[X]$, an irreducible polynomial, a prime.

Naively, one might guess: *nonzero non-unit $\Rightarrow$ separated.* That guess is false, and finding out precisely why it is false is where the subject becomes beautiful.

## The first idea: a ruler that grows

Why does the argument work for $\mathbb{Z}$ and $2$? Because integers carry a **size**. If $x \ne 0$, then $|2x| = 2|x| > |x|$. Multiplication by $2$ strictly inflates a nonnegative integer measurement, so $2^n y$ has absolute value at least $n$ bigger than $y$'s, and a fixed nonzero $x$ cannot be $2^n y$ for arbitrarily large $n$.

Nothing about this argument used $\mathbb{Z}$. It used only the existence of a ruler. Call a function $v : R \to \mathbb{N}$ a **height function for $a$** if
$$v(x) < v(ax) \qquad \text{for every nonzero } x \in R.$$
The ruler need not be a valuation, need not be additive, need not be canonical in any way. It only has to tick upward whenever you multiply by $a$.

> **Height Criterion.** Let $R$ be a domain and $a \in R$. If there exists *any* function $v : R \to \mathbb{N}$ with $v(x) < v(ax)$ for all $x \ne 0$, then the principal filtration at $a$ is separated.

The proof is an induction so short it fits in a breath. First, since each multiplication by $a$ raises $v$ by at least one, an easy induction gives
$$n + v(x) \le v(a^n x) \qquad \text{for all } n \ge 0 \text{ and } x \neq 0.$$
Now suppose $x$ is divisible by every power of $a$ and $x \ne 0$. Take $n = v(x) + 1$ and write $x = a^n y$. Since $R$ is a domain and $x \ne 0$, we have $y \ne 0$, so
$$v(x) = v(a^{n} y) \ge n + v(y) = v(x) + 1 + v(y) > v(x),$$
which is absurd. Hence $x = 0$. $\blacksquare$

Notice what is *not* in that proof: no finiteness hypotheses, no chain conditions, no Noetherian assumption, no factorization theory. Just a natural number that goes up. This single criterion instantly disposes of the classical examples:

- In $\mathbb{Z}$, take $v(x) = |x|$. Then $|2x| = 2|x| > |x|$ for $x \ne 0$, so $\bigcap_n (2^n) = 0$. More generally every integer $a$ with $|a| \ge 2$ works.
- In $k[X]$ over a domain $k$, take $v(p) = \deg p$. Then $\deg(Xp) = \deg p + 1$, so $\bigcap_n (X^n) = 0$: a nonzero polynomial cannot be divisible by arbitrarily high powers of $X$.

The child's argument, correctly abstracted, is not "integers are small"; it is "integers have a ruler".

## The second idea: chains instead of rulers

There is a completely different route to the same conclusion, and it is the one textbooks usually take. Suppose the ring satisfies a *chain condition* on divisibility: there is no infinite sequence of elements
$$x_0, x_1, x_2, \dots \quad \text{with each } x_{i+1} \text{ a proper divisor of } x_i,$$
where "proper" means the divisibility is strict (not an associate). Domains with this property — call them **well-founded for divisibility** — include every Noetherian domain and every unique factorization domain.

> **Krull Separation (principal case).** In a domain well-founded for divisibility, the principal filtration at $a$ is separated for every non-unit $a$.

The mechanism: if $x \ne 0$ were divisible by every power of $a$, then $x, x/a, x/a^2, \dots$ would be an infinite strictly descending divisibility chain, contradicting well-foundedness. Equivalently, every nonzero $x$ has a *finite $a$-multiplicity*: a largest $n$ with $a^n \mid x$. In fact one can say:

> **Separation $\iff$ every nonzero element has finite $a$-multiplicity.**

And in a well-founded domain with $1 \ne 0$ the picture becomes a clean dichotomy:

> **Trichotomy-Free Characterisation.** In a nontrivial domain well-founded for divisibility, the principal filtration at $a$ is separated **if and only if $a$ is not a unit**.

Units fail; everything else succeeds. This is the principal-ideal case of the classical Krull intersection theorem, specialising to Noetherian domains and — separately, since unique factorization domains need not be Noetherian — to UFDs.

## The surprise: the two ideas are the same idea

At first glance the two criteria live in different worlds. One is a soft, hands-on inequality; the other is a hard structural finiteness. The theorem that ties the subject together says they are not merely both sufficient — **the soft one is also necessary**.

> **Heights Characterise Separation.** Let $R$ be a domain and $a \in R$. The principal filtration at $a$ is separated *if and only if* there exists a function $v : R \to \mathbb{N}$ with $v(x) < v(ax)$ for all nonzero $x$.

One direction is the Height Criterion. For the other, separation *manufactures its own ruler*. If the filtration is separated, every nonzero $x$ has a well-defined **$a$-adic order** $\mathrm{ord}_a(x)$: the largest $n$ with $a^n \mid x$. And multiplying by a nonzero $a$ raises the order by exactly one:
$$\mathrm{ord}_a(ax) = \mathrm{ord}_a(x) + 1.$$
(The inequality $\ge$ is obvious; the reverse is a cancellation argument: if $a^{m+2} \mid ax$ with $m = \mathrm{ord}_a(x)$, cancel the $a$ to get $a^{m+1} \mid x$, contradicting maximality.) So the order is itself a height function, and it is the canonical one.

More is true. Among all rulers, the $a$-adic order is the *shortest*:

> **Minimality of the Order.** If $v$ is any height function for a nonzero $a$ in a separated situation, then $\mathrm{ord}_a(x) \le v(x)$ for every nonzero $x$.

So the $a$-adic order is a universal object: every witness to separation dominates it. This reframes the whole subject. **A Krull-type intersection theorem is not fundamentally a statement about ascending chains of ideals; it is a statement about the existence of an $\mathbb{N}$-valued height.** Chain conditions matter only because they are a convenient machine for producing heights. That is the conceptual payoff.

## A third face: fixed points and Nakayama

Rather than asking *when* the intersection vanishes, one can ask what the intersection *is*. Set
$$J = \bigcap_{n} (a^n).$$
A short cancellation argument shows that over a domain $J$ reproduces itself under multiplication by $a$:
$$J = (a) \cdot J.$$
Indeed if $x \in J$, write $x = ay$; then $y$ is again divisible by every power of $a$ (cancel one $a$ from $x = a^{n+1}c$), so $y \in J$ and $x \in (a)J$. Conversely $(a)J \subseteq J$ always. Even better, $J$ is *the largest* such ideal:

> **Greatest Fixed Point.** Over a domain, $J = \bigcap_n (a^n)$ is the greatest ideal $I$ satisfying $I \subseteq (a)\cdot I$. Consequently, the filtration at $a$ is separated **if and only if the only ideal $I$ with $I \subseteq (a) I$ is the zero ideal.**

Call such an $I$ an *$a$-divisible ideal*: every element of $I$ is $a$ times another element of $I$, forever. Separation says no nonzero ideal is infinitely divisible by $a$.

This vantage point yields a second, structurally different proof of the Noetherian case, using **Nakayama's lemma**. In a Noetherian ring $J$ is finitely generated, so from $J \subseteq (a)\,J$ the determinant-trick form of Nakayama produces a ring element $r$ with
$$r \equiv 1 \pmod{(a)} \qquad \text{and} \qquad r\,J = 0.$$
Write $r - 1 = a t$. If $r$ were $0$ we would get $a \cdot (-t) = 1$, making $a$ a unit — excluded by hypothesis. So $r \ne 0$, and in a domain $rJ = 0$ forces $J = 0$. Two entirely different proofs — multiplicity counting and Nakayama — for one theorem, which is usually a sign that the theorem is pointing at something real.

## Why anyone should care: the $p$-adic world

Separation is the license that makes $p$-adic analysis possible. Suppose $a$ is a *prime* element of a domain $R$ (so $a \mid xy$ implies $a \mid x$ or $a \mid y$) and the filtration at $a$ is separated. Then $\mathrm{ord}_a$ is additive on products,
$$\mathrm{ord}_a(xy) = \mathrm{ord}_a(x) + \mathrm{ord}_a(y),$$
and satisfies the ultrametric bound
$$\mathrm{ord}_a(x + y) \ge \min\{\mathrm{ord}_a(x), \mathrm{ord}_a(y)\}$$
(whenever the terms are nonzero), simply because a common divisor of two elements divides their sum. Define
$$\|x\|_a = 2^{-\mathrm{ord}_a(x)}, \qquad \|0\|_a = 0.$$

> **The Adic Absolute Value.** For a prime $a$ with separated principal filtration in a domain, $\|\cdot\|_a$ is a genuine absolute value: it is nonnegative, vanishes exactly at $0$, is multiplicative, and satisfies the *strong triangle inequality*
> $$\|x + y\|_a \le \max\{\|x\|_a, \|y\|_a\} \le \|x\|_a + \|y\|_a.$$
> Moreover $\|a\|_a = 1/2$.

And here is the point: the step "$\|x\|_a$ is well defined and nonzero for $x \ne 0$" *is* separation. Without it, $\mathrm{ord}_a(x)$ would be infinite for some nonzero $x$, the "absolute value" would vanish on a nonzero element, and the entire metric structure would collapse. Taking $R = \mathbb{Z}$ and $a = 2$ gives the $2$-adic absolute value and, upon completion, the $2$-adic numbers. Taking $R = k[X]$ and $a = X$ gives the order of vanishing at the origin and, upon completion, formal power series. One theorem, two of the most-used constructions in number theory and algebraic geometry.

The same idea has a purely topological face. Declaring the ideals $(a^n)$ to be a basis of neighbourhoods of $0$ makes $R$ a topological ring — the **$a$-adic topology**. Then:

> **Separation $\iff$ Hausdorff $\iff$ Injective into the completion.** The $a$-adic topology on $R$ is Hausdorff exactly when the principal filtration at $a$ is separated, and this holds exactly when the canonical map from $R$ into its $a$-adic completion is injective.

Separation, in other words, is the statement that *nothing is invisible to the $a$-adic microscope*: two distinct elements are eventually distinguished by some power of $a$. It is the condition under which "approximate modulo higher and higher powers of $a$" is a faithful way of describing elements.

## The counterexample: a ring where the child is wrong

All of this raises the sharp question: is the hypothesis needed at all? Could every nonzero non-unit give a separated filtration? No. And the counterexample is concrete enough to hold in your hand.

Let
$$S = \mathbb{Z} + X\,\mathbb{Q}[X]$$
be the ring of polynomials with rational coefficients whose **constant term happens to be an integer**. So $3 + \tfrac{1}{7}X - \tfrac{5}{2}X^3 \in S$, but $\tfrac{1}{2} + X \notin S$. This is a subring of $\mathbb{Q}[X]$, hence a domain.

Inside $S$, the element $2$ is nonzero. It is not a unit: its inverse in $\mathbb{Q}[X]$ is the constant $\tfrac12$, whose constant term is not an integer. And yet — here is the trick —
$$X = 2^n \cdot \left(\frac{X}{2^n}\right),$$
and $X/2^n$ lies in $S$, because its constant term is $0$, which is certainly an integer! So $X$ is divisible by $2$, by $4$, by $8$, by every power of $2$, inside $S$ — while $X \ne 0$.

> **Failure of Separation.** In $S = \mathbb{Z} + X\mathbb{Q}[X]$, the element $2$ is a nonzero non-unit whose principal filtration is not separated. In fact the intersection can be computed exactly:
> $$\bigcap_{n} (2^n) = X\,\mathbb{Q}[X] = \{p \in S : p(0) = 0\},$$
> the ideal of elements with vanishing constant term.

The containment $\supseteq$ is the trick above, applied coefficientwise. For $\subseteq$: if $p \in S$ has constant term $m \in \mathbb{Z}$ and $p = 2^n q$ with $q \in S$ having integer constant term $k$, then $m = 2^n k$, so $m$ is an integer divisible by every power of $2$ — and *now* the schoolchild's theorem in $\mathbb{Z}$ applies, giving $m = 0$.

There is something delicious about this: the counterexample in $S$ is proved by *using* the original fact in $\mathbb{Z}$. And the answer fits the fixed-point picture perfectly: $X\mathbb{Q}[X]$ is precisely the greatest $2$-divisible ideal of $S$.

The consequences cascade. Since separation would follow from well-founded divisibility, $S$ is **not** well-founded for divisibility (visibly: $X, X/2, X/4, \dots$ is an infinite proper divisibility chain), hence $S$ is **neither Noetherian nor a UFD**. And by the equivalence between separation and heights, **no $\mathbb{N}$-valued height function for $2$ can exist on $S$** — for every conceivable $v : S \to \mathbb{N}$ there is a nonzero $x$ with $v(2x) \le v(x)$. That is a strong non-existence statement, obtained for free from the ideal-theoretic computation.

Why does $S$ behave this way? Intuitively, $S$ has *two independent scales*: the integer scale of the constant term and the rational scale of the higher coefficients. Dividing by $2$ costs you something on the first scale but is free on the second. The "value monoid" is lexicographic $\mathbb{Z} \times \mathbb{Z}$ rather than $\mathbb{Z}$, and a lexicographic order is not archimedean — no finite number of steps of size $(1,0)$ ever exhausts a gap of type $(0,1)$. Separation, at bottom, is an **archimedean** axiom in disguise. That is exactly why it is equivalent to the existence of an $\mathbb{N}$-valued height: $\mathbb{N}$ is archimedean, and a rank-two value group cannot be squeezed into it.

## Beyond Noetherian

One might suspect the chain-condition hypothesis is just the Noetherian hypothesis wearing a hat. It is not. Consider the polynomial ring in countably many variables
$$\mathbb{Q}[X_0, X_1, X_2, \dots].$$
Its *irrelevant ideal*, generated by all the variables, is not finitely generated: any finite generating set mentions only finitely many variables, and evaluating at a point that sets all of those to $0$ but one missing variable to $1$ separates the ideal from that variable. So this ring is **not Noetherian**. But it *is* a unique factorization domain, hence well founded for divisibility, hence every non-unit there has a separated principal filtration — for instance
$$\bigcap_n (X_0^n) = 0,$$
and one gets a bona fide $X_0$-adic absolute value on this non-Noetherian ring, with $\|X_0\| = 1/2$. The chain-condition formulation genuinely covers more ground than the classical Noetherian statement.

## The moral

We started with a fact a child can prove and ended with a small map of commutative algebra. Along the way the same statement — *only zero survives division by $a$ forever* — showed four faces:

1. **Arithmetic:** every nonzero element has a finite $a$-multiplicity.
2. **Combinatorial:** there is an $\mathbb{N}$-valued ruler that ticks up when you multiply by $a$ — and the $a$-adic order is the minimal such ruler.
3. **Order-theoretic:** the map $I \mapsto (a)I$ on ideals has no nonzero fixed point.
4. **Topological/analytic:** the $a$-adic topology is Hausdorff; the map to the $a$-adic completion is injective; for prime $a$ one gets a non-archimedean absolute value.

And the boundary is real, marked by the ring $\mathbb{Z} + X\mathbb{Q}[X]$, where $X$ is divisible by every power of $2$ and the whole edifice fails at once. The lesson the counterexample teaches is the most useful one in the subject: what makes repeated division terminate is not that the ring is small, nor that its ideals form nice chains, but that the *scale of measurement is archimedean*. Give a ring a ruler with values in $\mathbb{N}$, and infinity has nowhere to hide.
