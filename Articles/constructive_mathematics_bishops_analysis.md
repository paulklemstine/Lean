# The Number You Can Actually Compute

## What Errett Bishop's constructive analysis asks of a theorem, and what it gives back

There is a moment in every first analysis course that ought to feel stranger than it does. The instructor draws a continuous curve starting below the $x$-axis and ending above it, and says: *therefore it crosses zero somewhere*. Everyone nods. The picture is overwhelming. The Intermediate Value Theorem is proved.

Then someone asks the obvious question. *Where?*

And the honest answer is: the proof does not say. The standard argument takes the set of points where the function is still negative, and invokes the completeness of the real numbers to produce its supremum. Completeness hands you a number. It does not hand you a procedure for finding it, and — this is the surprising part — in general there is no procedure to be had.

This is not a technicality about pathological functions. It is a genuine crack in the foundations, and in the 1960s Errett Bishop decided to build a version of analysis without it. His book *Constructive Analysis* redevelops the subject under a single discipline: **every existence claim must come with a construction, and every convergence claim must come with a rate**. What is remarkable is not that this is possible, but how much of ordinary analysis survives, and how sharp the surviving statements turn out to be.

This article is about that discipline and the shape of the theory it produces: what a real number is when you insist on being able to compute it, what completeness means when you insist on knowing how fast, what the Intermediate Value Theorem becomes when you insist on knowing where — and exactly where the classical theorem breaks, quantitatively.

---

## Part I. A real number is a sequence with a promise

Classically, a real number is defined by a Cauchy sequence of rationals: a sequence $q_0, q_1, q_2, \dots$ such that for every $\varepsilon > 0$ there is some $N$ beyond which all terms are within $\varepsilon$ of each other. The trouble is the *"there is some $N$"*. If you are handed such a sequence, you know that $N$ exists, but you may have no way to find it — and without it, you cannot say how good any particular $q_n$ is. You have a number you cannot bound.

Bishop's fix is disarmingly simple. Build the rate into the definition.

> **Definition (regular sequence).** A *regular sequence of rationals* is a sequence $x_0, x_1, x_2, \dots$ of rational numbers satisfying
> $$|x_m - x_n| \;\le\; \frac{1}{m+1} + \frac{1}{n+1} \qquad \text{for all } m, n .$$

That's it. There is no quantifier to be dodged: the sequence carries its own modulus of convergence, on the nose. And the payoff is immediate and quantitative.

> **Theorem (explicit modulus).** If $x$ is a regular sequence, then the real number $\hat{x}$ it denotes satisfies
> $$|\hat{x} - x_n| \;\le\; \frac{1}{n+1} \qquad \text{for every } n .$$

So the index *is* the error bar. Ask for $x_{999}$ and you get a rational number guaranteed to be within $1/1000$ of the answer, with no further computation and no further thought. The proof is one line of limit-taking: let $j \to \infty$ in $|x_j - x_n| \le \frac{1}{j+1} + \frac{1}{n+1}$.

There is a subtlety here that is invisible classically. When are two regular sequences the same number? Not when they are equal term by term — $1/2, 1/2, 1/2, \dots$ and $0.4, 0.49, 0.499, \dots$ should be the same real. Bishop *defines* equality:
$$x = y \quad \text{means} \quad |x_n - y_n| \le \frac{2}{n+1} \text{ for all } n .$$
Constructively this is a definition and not a derived notion, and one has to check it behaves. It does, and the reason is clean:

> **Theorem.** Two regular sequences are Bishop-equal exactly when they denote the same classical real number.

Reflexivity and symmetry are then free; transitivity — which requires a genuine three-term estimate constructively — comes along too. And the correspondence is a perfect one:

> **Theorem (nothing is lost).** Every classical real number is denoted by some regular sequence, and the regular sequences modulo Bishop equality are in bijection with the real numbers.

So the constructive reals are not a smaller, impoverished number system. They are the *same* number system, presented in a way that makes every element carry its own error estimates. What changes is not which numbers exist but what a *proof* about them must supply.

---

## Part II. Completeness, and a shift you cannot remove

Completeness — every Cauchy sequence converges — is the engine of analysis. Constructively it must be restated with rates on both ends: from a sequence of reals $x_0, x_1, \dots$ satisfying $|x_k - x_l| \le \frac{1}{k+1} + \frac{1}{l+1}$, produce a real $L$ with $|L - x_k| \le \frac{1}{k+1}$.

Bishop's construction is a diagonal — but a *shifted* one. The limit's $n$-th rational approximation is
$$L_n \;=\; \big(x_{2n+1}\big)_{2n+1},$$
the $(2n+1)$-st approximation of the $(2n+1)$-st term. And it works: the resulting sequence is regular, and the limit it denotes satisfies the promised $|L - x_k| \le \frac{1}{k+1}$.

Why the shift? Why not the obvious diagonal $(x_n)_n$? The answer is not a matter of convenience — the naive diagonal is genuinely broken, and one can see it in a two-line example. Consider the family
$$\big(x_k\big)_n \;=\; \frac{1}{k+1} + (-1)^k \cdot \frac{1}{n+1} .$$
Each $x_k$ is a perfectly good regular sequence denoting the real number $1/(k+1)$; the second term is the built-in wobble, sitting exactly at the edge of the allowed error, with a sign that flips with $k$. The reals $1/(k+1)$ form a regular sequence of reals. But the naive diagonal has
$$\big(x_0\big)_0 = 1 + 1 = 2, \qquad \big(x_1\big)_1 = \tfrac{1}{2} - \tfrac{1}{2} = 0,$$
so its first two terms differ by $2$, where regularity permits at most $\frac{1}{1} + \frac{1}{2} = \frac{3}{2}$. The naive diagonal is not a real number at all. Doubling the index halves the wobble, and that is precisely enough. It is a small thing, but it is the kind of small thing that constructive mathematics forces you to notice: an error term that classical analysis would sweep into "for sufficiently large $n$" here has nowhere to hide.

---

## Part III. Arithmetic that runs

Because a Bishop real is *data* — a function from $\mathbb{N}$ to $\mathbb{Q}$ — arithmetic on Bishop reals is a program, and the index shifts are the interesting part.

**Addition.** You cannot set $(x+y)_n = x_n + y_n$: the errors add, and the sum is only regular with a factor of $2$ too much slack. Take instead
$$(x+y)_n = x_{2n+1} + y_{2n+1},$$
computing each summand to twice the required accuracy so their sum meets it.

**Multiplication.** Here the shift must depend on the *size* of the numbers, because an error of $\delta$ in a factor of size $B$ becomes an error of $B\delta$ in the product. Every regular sequence carries a canonical bound: since $|x_n - x_0| \le \frac{1}{n+1} + 1 \le 2$, the integer
$$B_x = \lceil |x_0| \rceil + 2$$
dominates $|x_n|$ for every $n$. With $M = B_x + B_y$ the definition
$$(x \cdot y)_n = x_{M(n+1)} \cdot y_{M(n+1)}$$
is regular, and denotes the classical product. The bound is not decoration: it is the reason the constructive real numbers are a ring in the first place, and it must be computed from the data.

**A worked irrational.** Nothing forces constructive reals to be rational or simple. Set
$$(\sqrt{2}\,)_n \;=\; \frac{\big\lfloor \sqrt{2(n+1)^2} \big\rfloor}{n+1},$$
where the square root is the *integer* square root — pure integer arithmetic. Regularity follows from the elementary estimate $\frac{\lfloor\sqrt{2m^2}\rfloor}{m} \le \sqrt{2} < \frac{\lfloor\sqrt{2m^2}\rfloor}{m} + \frac{1}{m}$, and the sequence denotes a real whose square is exactly $2$. Its fourth term is $7/5$; its hundredth is $141/100$. You can run it.

---

## Part IV. Order: an inequality is a witness

Here constructive analysis parts company with classical logic most visibly. Classically, $x < y$ means "not $y \le x$". Constructively that is useless: from a refutation you can compute nothing. So positivity is defined *positively*, in terms of evidence:
$$x > 0 \quad \text{means} \quad \text{there is an } n \text{ with } x_n > \tfrac{1}{n+1},$$
$$x < y \quad \text{means} \quad \text{there is an } n \text{ with } x_n + \tfrac{2}{n+1} < y_n .$$
A proof of $x < y$ is not an assertion — it is a number $n$, from which the rational $y_n - x_n - \frac{2}{n+1} > 0$ is an explicit, certified lower bound for the gap. These relations agree extensionally with the classical ones; the difference is in what a proof of one *is*.

What replaces trichotomy? Classically, for any $z$ at all, $x < y$ implies $x < z$ or $z < y$. Constructively this survives — and, delightfully, survives *effectively*:

> **Theorem (cotransitivity, explicit form).** Suppose the index $n$ witnesses $x < y$, with certified gap $g = y_n - x_n - \frac{2}{n+1} > 0$. Let $m$ be any index with $\frac{1}{m+1} \le g/8$. Then for **any** third real $z$, comparing the single rational $z_m$ with the midpoint $\frac{x_m + y_m}{2}$ decides the disjunction: if $z_m$ is at least the midpoint then $x < z$; otherwise $z < y$.

One rational comparison, at an index computed from the gap, and the case split is resolved. The two alternatives may overlap — that is exactly why the test can be effective — but *some* true alternative is always returned. The same idea gives a location principle: for rationals $a < b$ and any real $x$, one comparison at an index with $\frac{4}{m+1} \le b - a$ decides "$a < x$" or "$x < b$". You cannot decide $x \le a$ versus $a < x$; you can always decide the overlapping version, and in practice the overlapping version is all anyone needs.

What you cannot do is bound the work in advance:

> **Theorem (no uniform witness bound).** For every $N$ there are reals $x < y$ for which no index $n \le N$ witnesses the inequality.

The example is embarrassingly simple: $x = 0$ and $y = \frac{1}{N+1}$. The inequality is true; the certificate lives beyond index $N$. Comparing reals is decidable *eventually* and never *uniformly*, and this single sentence is the precise content of the folklore that "you can't decide equality of real numbers".

---

## Part V. The Intermediate Value Theorem, in three acts

Now the main event. In Bishop's framework a continuous function on $[a,b]$ is not merely continuous: it comes with a **modulus of uniform continuity**, an explicit map $\omega$ from accuracies to accuracies such that
$$|x - y| \le \omega(\varepsilon) \implies |f(x) - f(y)| \le \varepsilon .$$

### Act 1: the approximate theorem, which is true and computable

> **Theorem (approximate IVT with explicit modulus).** Let $f$ have modulus $\omega$ on $[a,b]$ with $f(a) \le 0 \le f(b)$. Fix $\varepsilon > 0$ and any $N \ge 1$ with mesh $\frac{b-a}{N} \le \omega(\varepsilon)$. Then among the $N+1$ grid points $a + k\frac{b-a}{N}$ there is one where $|f| \le \varepsilon$.

The proof is a finite search and the witness is explicit: take $k^\ast$ to be the *largest* index with $f \le 0$ at that grid point. If $k^\ast = N$ then $f(b) \le 0 \le f(b)$, so $f(b) = 0$ and we are done exactly. Otherwise the next grid point has $f > 0$, the two are one mesh apart, so the modulus gives $f(\text{grid } k^\ast{+}1) - f(\text{grid } k^\ast) \le \varepsilon$; since the left value is $\le 0$ and the right is $> 0$, the left value is at least $-\varepsilon$. Hence $|f| \le \varepsilon$ there. No search over the reals, no appeal to completeness, no choice: $N+1$ evaluations and a comparison.

### Act 2: the exact theorem is false — and here is the machine that breaks it

Can we upgrade $|f(x)| \le \varepsilon$ to $f(r) = 0$? Not constructively, and the obstruction is a beautiful one due to Bishop. Consider the *shelf family*, parametrised by $t \in [-1,1]$ and defined on $[0,3]$:
$$S_t(x) \;=\; \min\big(x - 1,\; \max(t,\; x-2)\big).$$
Picture it: a ramp rising to height $0$ at $x=1$, then a flat shelf at height $t$ across $[1,2]$, then a ramp rising again after $x=2$. Every member is $1$-Lipschitz — so they all share the modulus $\omega(\varepsilon) = \varepsilon$, uniformly in $t$ — and every member satisfies $S_t(0) \le 0 \le S_t(3)$. The approximate theorem applies to the whole family with a mesh depending on $\varepsilon$ alone.

But where is the root? If $t > 0$, the shelf sits above zero and the only root is $x = 1$. If $t < 0$, the shelf sits below zero and the only root is $x = 2$. At $t = 0$ the whole shelf is a root. So as the parameter passes through zero, the root *teleports* from $1$ to $2$.

> **Theorem (no continuous root selector).** There is no continuous function $t \mapsto r(t)$ on $[-1,1]$ with $S_t(r(t)) = 0$ for all $t$.

The argument is a lovely piece of judo. Such an $r$ would have $r(1) = 1$ and $r(-1) = 2$, so by the *classical* Intermediate Value Theorem applied to $r$ itself, $r$ takes every value in $[1,2]$ — in particular both $3/2$ and $7/4$. But a root strictly between $1$ and $2$ forces the parameter to be exactly $0$: at $t=0$, and only there, does the shelf lie at height zero. So $r(0) = 3/2$ and $r(0) = 7/4$ simultaneously. Contradiction.

Since every constructively defined function $\mathbb{R} \to \mathbb{R}$ is continuous, no constructive procedure can extract exact roots from these data. And the failure is not marginal — it is total:

> **Theorem (quantitative failure).** Let $r$ be *any* choice of a root of $S_t$ for each $t \in [-1,1]$ — continuous or not, definable or not. For every $\eta > 0$, the oscillation of $r$ on the parameters with $|t| \le \eta$ is at least $1$.

Because every root of every $S_t$ lies in $[1,2]$, and just inside any window around $0$ there are parameters of both signs, forcing the values $1$ and $2$ to both be attained. No selector is even approximately continuous at the critical parameter. The obstruction is a jump of unit size that cannot be shrunk by any choice whatsoever.

### Act 3: the exact theorem, rescued by a slope

What exactly did the shelf family exploit? Flatness. $S_0$ is constant on $[1,2]$, so knowing that $|f|$ is small tells you nothing about where you are. Forbid that quantitatively and everything comes back.

Say $f$ has **slope bound $c > 0$** on $[a,b]$ if $f(y) - f(x) \ge c(y-x)$ whenever $x \le y$ in $[a,b]$ — the function increases at rate at least $c$.

> **Theorem (constructive IVT with explicit modulus).** Let $f$ have modulus $\omega$ and slope bound $c > 0$ on $[a,b]$, with $f(a) \le 0 \le f(b)$. Then $f$ has a unique root $r$, and for every desired accuracy $\delta > 0$, any grid of mesh at most $\omega(c\delta)$ contains a point within $\delta$ of $r$ — found by the same finite search as before. The modulus of the root is $\delta \mapsto \omega(c\delta)$.

The heart is a one-line estimate that deserves to be better known:

> **Lemma (root modulus).** Under a slope bound $c$, if $f(r) = 0$ and $|f(x)| \le \varepsilon$, then $|x - r| \le \varepsilon/c$.

Small value implies small distance, at the exchange rate $1/c$. Run the grid search at accuracy $c\delta$ and you land within $\delta$ of the root. Uniqueness is the case $\varepsilon = 0$. And the root itself can be packaged as a Bishop real: its $n$-th rational approximation is literally one of the grid points, an explicitly computed rational.

Is the factor $1/c$ the truth, or an artifact? It is the truth, and one need only look at $f(x) = cx$ on $[-1,1]$, whose root is $0$ and whose slope bound is exactly $c$. The point $x = \varepsilon/c$ has $|f(x)| = \varepsilon$ and sits at distance *exactly* $\varepsilon/c$ from the root. Hence no constant $\kappa < 1$ can replace the $1$ in $\varepsilon/c$: the estimate is attained, and sharp.

### A coda: the search already knows more than it says

Here is a pleasant surprise buried in the same grid search. The estimate above uses the *size* of $|f|$ to locate the root — that is what needs the slope bound. But the search also produces a *bracket*: a consecutive pair of grid points with $f \le 0$ on the left and $f > 0$ on the right. And a bracket locates a root all by itself.

> **Theorem (bracketing).** For $f$ with a modulus of uniform continuity on $[a,b]$ and $f(a) \le 0 \le f(b)$, and *no* non-degeneracy hypothesis at all, the sign-change grid search returns a grid point within one mesh $\frac{b-a}{N}$ of a genuine root.

The accuracy of the *location* is the mesh itself. Of course, the root produced is a classical one — finding the bracket is effective, but pinning the root inside it needs the classical theorem — which is exactly the boundary this whole subject is mapping.

Finally, one might hope to weaken the slope bound to Bishop's more permissive *local non-constancy*: on every interval of length $h$, the function attains absolute value at least $\nu(h)$ for some explicit $\nu$. It is not enough. Take
$$D_\eta(x) \;=\; \min\big(x-1,\; |x-3| + \eta\big)$$
on $[0,4]$. It is $1$-Lipschitz, its only root is $x = 1$, and it satisfies local non-constancy with the explicit modulus $\nu(h) = h/8$. Yet $D_\eta(3) = \eta$ — a false alarm as small as you like — at distance $2$ from the only root. The near-miss is real. So the passage from "$|f(x)|$ is small" to "$x$ is near a root" is a strictly stronger requirement than local non-constancy, and the slope bound in the theorem above is not laziness.

---

## Part VI. Suprema, and a race between search strategies

One more pillar. Classically every nonempty bounded set of reals has a least upper bound. The classical proof decides, for a rational $q$, whether $q$ is an upper bound — a question no algorithm can answer in general. Bishop's replacement demands that the decision be supplied as part of the data.

> **Definition (located set).** A set $S$ is *located* if it comes with a procedure $L$ such that for rationals $p < q$: if $L(p,q)$ answers *yes*, then $q$ is an upper bound of $S$; if it answers *no*, then some member of $S$ exceeds $p$.

The two alternatives may both be true — the procedure must simply return one that is correct. This overlapping form is precisely what makes such oracles obtainable in practice. (Assume the classical decision "is $q$ an upper bound?" and you get a located datum for free, so the constructive principle is classically just completeness again: all the content is in the extra datum.)

From it, the supremum is *computed*, by a search that maintains a rational enclosure $p_n \le \sup S \le q_n$. Bishop's version trisects: query the oracle at the two interior trisection points; on *yes* keep $[p, p + \frac23(q-p)]$, on *no* keep $[p + \frac13(q-p), q]$. Either way the width is exactly $\frac23$ of what it was, so
$$q_n - p_n = \left(\tfrac{2}{3}\right)^n (q_0 - p_0)$$
on the nose. Take the first stage narrower than $\frac{1}{k+1}$ and its left endpoint as the $k$-th approximation, and the supremum is itself a Bishop real.

But is $2/3$ the right rate? Formulate the general one-query scheme: pick fractions $\alpha < \beta$, query the oracle at $p + \alpha(q-p)$ and $p + \beta(q-p)$, keep $[p, p+\beta(q-p)]$ on *yes* and $[p+\alpha(q-p), q]$ on *no*. The enclosure invariant survives for every such choice, and the worst-case contraction factor is
$$\max\big(\beta,\; 1-\alpha\big).$$
Bishop's trisection is $\alpha = \frac13, \beta = \frac23$, giving $\max(\frac23,\frac23) = \frac23$. But nothing forces the two query points to be symmetric about the midpoint! Take $\alpha = \frac{2}{5}$, $\beta = \frac{1}{2}$: the factor is $\max(\frac12, \frac35) = \frac35 < \frac23$. **Trisection is not optimal.** Ten steps of the faster search beat ten steps of trisection by a factor of more than three.

How far can this go? Exactly to one half, and no further:

> **Theorem.** For every $\alpha < \beta$, the contraction factor $\max(\beta, 1-\alpha)$ is strictly greater than $\frac12$. But for every $\eta > 0$ there is a choice — take $\alpha = \frac12 - \frac{t}{2}$, $\beta = \frac12 + \frac{t}{2}$ for small $t$ — whose factor is below $\frac12 + \eta$.

The reason is transparent once you see it: a single query splits the interval at two points, and the two possible answers keep the left $\beta$-portion or the right $(1-\alpha)$-portion. To make both small you must push $\beta$ down and $\alpha$ up, but $\alpha < \beta$ is required for the query to be legitimate — the oracle needs a genuine gap to work in. In the limit the two query points collide at the midpoint and each answer halves the interval, but that limit is unreachable: the oracle has nothing to compare. One half is the infimum of what a single yes/no question about a located set can buy you, and it is never attained.

That last fact is a small, sharp piece of information theory hiding inside a constructive existence proof — which is, in a sense, the whole moral.

---

## Why this matters outside the seminar room

The obvious reading is philosophical: constructive analysis is classical analysis with the non-computable steps flagged. That is true and it is not the interesting part.

The interesting part is that **the flags are quantitative**. Every theorem above carries a number. The approximate root is found in $N+1$ function evaluations with $N$ determined by the modulus. The root's accuracy converts to function accuracy at the exchange rate $1/c$, and that rate is exactly attained. The supremum search contracts by $3/5$ per oracle call, not $2/3$, and no scheme of its kind can beat $1/2$. The completeness diagonal needs index $2n+1$ and would fail at $n$, with an explicit two-line counterexample.

This is the language that numerical analysis and computer algebra actually speak. When a computer algebra system represents an algebraic number, it stores something very like a regular sequence and an interval enclosure. When a root-finder reports convergence, the honest statement is the bracketing theorem, not the classical Intermediate Value Theorem. When an interval-arithmetic library multiplies two enclosures, it computes a bound on each factor and shifts precision accordingly — which is exactly the $M = B_x + B_y$ index shift. Bishop was not describing a restricted mathematics. He was describing the mathematics that runs, and insisting that its proofs be written in a form that says so.

And the shelf function is the standing reminder of why one should care. It is $1$-Lipschitz. It is as tame as a function can be. It changes sign. Its root is a real number that exists, that any student can locate on a picture — and that no algorithm, no continuous rule, no choice function of any kind can track as the picture is nudged. The gap between *there is* and *here is* is not a philosopher's quibble. It is a flat shelf, two units wide, sitting at height zero.
