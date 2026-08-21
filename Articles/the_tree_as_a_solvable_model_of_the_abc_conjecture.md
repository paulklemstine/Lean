# The Oldest Equation Meets the Hardest Conjecture

*How the ancient tree of Pythagorean triples becomes a laboratory for the $abc$ conjecture — and what its exact "quality spectrum" reveals.*

## A conjecture about addition and multiplication

Almost everything hard in number theory comes from a single tension: addition and multiplication do not get along. Multiplication has a beautiful structure — every whole number factors uniquely into primes. Addition ignores all of it. Add two numbers with lovely factorizations, and the result can be a stubborn prime, or a number whose factorization looks like noise.

In 1985 Joseph Oesterlé and David Masser proposed a way to measure exactly how badly the two operations interfere. Take three positive whole numbers with no common factor satisfying
$$A + B = C.$$
Now strip all repetition out of their product: let the *radical* $\operatorname{rad}(n)$ be the product of the distinct primes dividing $n$. So $\operatorname{rad}(12) = \operatorname{rad}(2^2\cdot 3) = 6$, and $\operatorname{rad}(1000) = \operatorname{rad}(2^3 5^3) = 10$. Radicals are small exactly when a number is rich in repeated prime factors.

The $abc$ conjecture says: $C$ can never be much larger than $\operatorname{rad}(ABC)$. Precisely, for every $\varepsilon > 0$ there is a constant $K_\varepsilon$ with
$$C \le K_\varepsilon \cdot \operatorname{rad}(ABC)^{1+\varepsilon}.$$

The natural way to score a single triple is its **quality**
$$q(A,B,C) = \frac{\log C}{\log \operatorname{rad}(ABC)}.$$
Quality above $1$ means the sum $C$ has outrun the radical — the triple is, in the trade's slang, an *$abc$ hit*. Hits are rare but real: the famous $1 + 8 = 9$ has $\operatorname{rad}(1\cdot 8\cdot 9) = 6$ and quality $\log 9/\log 6 \approx 1.226$. The reigning champion, found by Eric Reyssat, is
$$2 + 3^{10}\cdot 109 = 23^5,$$
with quality about $1.6299$. Nobody has ever found a triple of quality $2$, and the conjecture predicts that only finitely many exceed $1 + \varepsilon$ for any fixed $\varepsilon > 0$.

The conjecture is famous both for its consequences — it implies Fermat's Last Theorem for large exponents, the Erdős–Woods conjecture, effective forms of results on Diophantine equations — and for its resistance. A claimed proof by Shinichi Mochizuki remains disputed. Meanwhile, no one can even exhibit an infinite family of $abc$ triples whose qualities we can *completely describe*. The parameter space is too wild.

Unless, that is, we look somewhere very old.

## The tree that grows every right triangle

A **Pythagorean triple** is a solution of $a^2 + b^2 = c^2$ in positive integers: $(3,4,5)$, $(5,12,13)$, $(8,15,17)$, and so on. It is *primitive* when $a$ and $b$ share no common factor. Babylonian scribes tabulated them; Euclid parametrized them; and in 1934 (rediscovered by B. Berggren, and again by several others since) it was noticed that they organize themselves into a perfect ternary tree.

Start at the root $(3,4,5)$. Apply the three matrices
$$
A=\begin{pmatrix}1&-2&2\\2&-1&2\\2&-2&3\end{pmatrix},\qquad
B=\begin{pmatrix}1&2&2\\2&1&2\\2&2&3\end{pmatrix},\qquad
C=\begin{pmatrix}-1&2&2\\-2&1&2\\-2&2&3\end{pmatrix}
$$
to the column vector $(a,b,c)$. Each produces a new primitive triple; and every primitive triple in existence appears exactly once, at the end of exactly one finite word in $\{A,B,C\}$. From $(3,4,5)$ the three children are $(5,12,13)$, $(21,20,29)$ and $(15,8,17)$; below them, nine grandchildren; and so on forever. Descent is equally clean: apply the inverse matrices and any triple marches, in finitely many steps, back to $(3,4,5)$.

Here is the observation that starts everything. **Every Pythagorean triple is an $abc$ triple.** Just read $a^2 + b^2 = c^2$ as $A + B = C$ with $A = a^2$, $B = b^2$, $C = c^2$. Primitivity of $(a,b)$ makes $a^2$ and $b^2$ coprime, exactly as the $abc$ setup demands. So the quality of a node of the tree is
$$q(a,b,c) = \frac{\log (c^2)}{\log \operatorname{rad}(a^2b^2c^2)}.$$

The tree is thus an infinite family of $abc$ triples with a completely explicit generating mechanism, an explicit descent, and an explicit growth law. The question is what its qualities look like — and here the first small miracle occurs.

## Squares are free

Radicals do not see exponents. $\operatorname{rad}(n^2) = \operatorname{rad}(n)$, because squaring changes no prime's presence, only its multiplicity. Hence
$$\operatorname{rad}(a^2b^2c^2) = \operatorname{rad}(abc),$$
and the quality of a tree node simplifies to something involving only the triple itself:
$$\boxed{\;q(a,b,c) = \frac{2\log c}{\log \operatorname{rad}(abc)}.\;}$$

That single identity is what makes the tree tractable. The three squares — the hard part of any $abc$ instance — evaporate, and all the arithmetic lives in the plain product $abc$.

Two exact criteria follow immediately, just by comparing logarithms:

- **A node is an $abc$ hit ($q > 1$) precisely when $\operatorname{rad}(abc) < c^2$.**
- **A node has quality below $2$ precisely when $\operatorname{rad}(abc) > c$.**

More generally, for any rational threshold $m/k$, the statement $q > m/k$ is *exactly equivalent* to the integer inequality $\operatorname{rad}(abc)^m < c^{2k}$. The whole quality spectrum of the tree is encoded in comparisons between the powers of a single integer and a single radical. No analysis; pure arithmetic.

## The floor: no node is ever dull

How bad can a Pythagorean triple's quality be? Not very. The arithmetic–geometric mean inequality applied to $a^2 + b^2 = c^2$ gives $2ab \le c^2$, so
$$abc \le \tfrac{1}{2}c^3,$$
and since the radical never exceeds its argument, $\operatorname{rad}(abc) \le c^3/2$. Feeding this into the boxed formula:

> **Theorem (lower edge of the spectrum).** Every Pythagorean triple with both legs at least $3$ satisfies
> $$q(a,b,c) \;\ge\; \frac{2\log c}{3\log c - \log 2} \;>\; \frac{2}{3},$$
> and, in cruder but more transparent form, $q \ge \frac23 + \dfrac{2\log 2}{9\log c}$.

So $2/3$ is a hard floor for the entire infinite tree, and the theorem tells us more: the floor can only be *approached*, never touched, and only along nodes whose hypotenuse runs off to infinity — at the glacial rate $1/\log c$. In a scan of the tree out to hypotenuse $300{,}000$, the smallest quality found was $0.6920$; the bound at that size is $0.6785$, so the floor is genuinely being felt.

The shape of the argument also explains the number $2/3$: it is the quality of a triple whose product $abc$ is *completely squarefree*, so that $\operatorname{rad}(abc) = abc \approx c^3$, giving $q \approx 2\log c/(3\log c) = 2/3$. Squarefree products are the worst possible $abc$ material. The tree's floor is exactly the squarefree regime.

## The ceiling: where the real difficulty hides

At the other end, quality below $2$ needs only $\operatorname{rad}(abc) > c$ — an almost embarrassingly weak requirement, since $abc$ itself exceeds $c^3$ in size. Concretely, if the product $abc$ is not extravagantly *powerful* — if it satisfies the mild condition $abc \le \operatorname{rad}(abc)^2$, which holds for instance whenever $abc$ is squarefree — then, combined with the inequality $2c \le ab$ valid for every Pythagorean triple with legs at least $3$, one gets $c < \operatorname{rad}(abc)$ and hence:

> **Theorem (unconditional gap).** Any Pythagorean triple with legs at least $3$ whose product satisfies $abc \le \operatorname{rad}(abc)^2$ has quality strictly less than $2$.

But — and this is the honest part of the story — the gap this yields is only of size $\Theta(1/\log c)$. It shrinks as the triple grows. **No uniform bound of the form $q \le 2 - \varepsilon$ follows from this mechanism**, and that is not a defect of the argument. A uniform gap for the tree is a genuinely $abc$-strength statement.

We can say precisely how much $abc$-strength: assume an *effective* version of the conjecture, an explicit constant $K$ with $C^{12} \le K\cdot \operatorname{rad}(ABC)^{13}$ for all coprime $A + B = C$. Then every tree node whose hypotenuse satisfies $K \le c^4$ has
$$q(a,b,c) \le \frac{13}{10},$$
a clean gap of $7/10$ below the ceiling, with only finitely many nodes escaping. And under the full Masser–Oesterlé conjecture, for every $\varepsilon > 0$ there is a threshold $C_0$ beyond which *every* Pythagorean triple has $q \le 1 + 2\varepsilon$. Combined with the floor, the limiting quality spectrum of the tree is squeezed into the window $(2/3, 1]$.

That is the conditional picture. What can we prove outright?

## Hits, forever, from a two-line trick

Plenty, as it turns out — including that hits are not accidents of small numbers.

Walk down the tree using only the matrix $A$. The nodes are gorgeously simple: at step $n$ you sit at
$$(2n+1,\; 2n(n+1),\; 2n^2+2n+1),$$
the "almost-isosceles" triples with $c = b+1$: $(3,4,5)$, $(5,12,13)$, $(7,24,25)$, $(9,40,41)$, …. Along this spine the product is
$$abc = (2n+1)\cdot 2n(n+1)\cdot(2n^2+2n+1),$$
so the radical is controlled by $\operatorname{rad}(n)$ and $\operatorname{rad}(n+1)$: a hit occurs as soon as $n$ and $n+1$ are both rich in repeated prime factors.

That is easy to arrange, using the oldest trick in the $abc$ book — the lifting-the-exponent phenomenon. Fix an odd $d \ge 3$ and set
$$n = d^{\,2^k} - 1.$$
Then $n+1$ is a pure power of $d$, so $\operatorname{rad}(n+1) = \operatorname{rad}(d) \le d$ — a factor of $d^{2^k}$ collapses to $d$. And $n$ itself factors as $(d-1)(d+1)(d^2+1)(d^4+1)\cdots$, an accumulation of even numbers, so $2^{k+2}$ divides $n$: the radical of $n$ loses at least the factor $2^{k+1}$. Two independent collapses, each engineered.

> **Theorem (infinitely many hits).** For every odd $d \ge 3$ and every $k$ with $d \le 2^k$, the $A$-spine node with parameter $n = d^{2^k} - 1$ has quality greater than $1$. In particular, for every bound $N$ there is a node of the tree with hypotenuse exceeding $N$ and quality $> 1$: the tree contains infinitely many $abc$ hits, along a family attached to *every* odd base.

The condition $d \le 2^k$ is exactly the balance point: the collapse $2^{k+1}$ in $\operatorname{rad}(n)$ must outweigh the loss $d$ incurred at $n+1$.

There is a catch, and it is instructive. Consecutive members of this family satisfy
$$c_{k+1} < c_k^2 < 4c_{k+1},$$
so each step essentially *squares* the hypotenuse. The family therefore contributes only about $\log\log X$ hits below $X$. The mechanism we can control is doubly exponentially sparse — a numerical echo of why $abc$ hits are so hard to find in the wild.

## The silver ratio governs the whole tree

One more structure completes the picture. How fast does the tree grow?

Every Pythagorean triple satisfies $a + b \le \sqrt2\,c$ (again the AM–QM inequality). Each Berggren matrix produces a new hypotenuse of the form $c' = 3c \pm 2(a \mp b)$, so
$$c' \le 3c + 2\sqrt2\,c = (3+2\sqrt2)\,c.$$
The constant $3 + 2\sqrt2 = (1+\sqrt2)^2 \approx 5.8284$ is the square of the **silver ratio** — the number that plays for $\sqrt2$ the role the golden ratio plays for $\sqrt5$. It is not an accident: the tree is built from the symmetry group of the form $a^2+b^2-c^2$, and $1+\sqrt2$ is the fundamental unit hiding inside it.

> **Theorem (universal depth law).** Every node at depth $n$ in the tree, along *any* of the $3^n$ paths, has hypotenuse at most $5(3+2\sqrt2)^n$. Consequently its quality lies in the window
> $$\frac23 \;<\; q \;\le\; \frac{2\bigl(\log 5 + n\log(3+2\sqrt2)\bigr)}{\log \operatorname{rad}(abc)}.$$

The bound is sharp: along the all-$B$ branch the hypotenuses are the Pell-type numbers $5, 29, 169, 985, 5741, \dots$ satisfying $c_{n+1} = 6c_n - c_{n-1}$, and they sit within one half of a percent of $5(3+2\sqrt2)^n$ — while never dropping below $5^{n+1}$.

The consequence is conceptually the sharpest thing here. In the quality $q = 2\log c/\log\operatorname{rad}(abc)$, the numerator is *completely determined by depth*, up to a bounded factor: the geometry of the tree pins it. **Every bit of the mystery lives in the denominator, the radical.** The tree cleanly separates the algebraic-geometric half of the $abc$ problem, which it solves exactly, from the multiplicative half, which is the conjecture itself.

## What the spectrum actually looks like

Computation fills in the portrait. Among the $159{,}139$ tree nodes with hypotenuse below $10^6$:

- The root $(3,4,5)$, with $\operatorname{rad}(60) = 30$, has quality $\log 25/\log 30 \approx 0.9464$: not a hit.
- Its child $(5,12,13)$, with $\operatorname{rad}(780) = 390$, drops to $0.8598$.
- *Its* child $(7,24,25)$, with $\operatorname{rad}(4200) = 210$, jumps to $1.2040$: a hit, and a good one.
- The very next step, to $(105,88,137)$, collapses back to $0.7769$.

So quality is emphatically **not monotone** under the tree's descent. There is no branch you can follow uphill; hits are scattered.

The best node found in the whole scan is
$$36207^2 + 18424^2 = 40625^2,\qquad \operatorname{rad}(abc) = 19118190,$$
reached by the word $CCCACCBC$ — only eight steps from the root. Its quality is bracketed exactly:
$$\frac54 \;<\; q(36207,18424,40625) \;<\; \frac43,$$
numerically $1.2659$. Fewer than half a percent of nodes are hits at all, and the distribution is a single hump peaking around $q \approx 0.73$ with a thin tail crossing $1$.

And here is the punchline of the numerics: the tree's best quality, $1.2659$, is nowhere near the $abc$ record $1.6299$. The most structured infinite family of $abc$ triples we possess is a *mediocre* source of hits. The record-setters are not structured; they are lucky.

## What was and wasn't achieved

The original hope was bolder: an exactly computed supremum for the tree's quality, attained or approached along an identifiable branch, plus an exact distribution law at each depth. That hope is not fulfilled, and the analysis says precisely why. The supremum question for this family is *equivalent* to an $abc$-strength statement — proving $q \le 2 - \varepsilon$ uniformly over the tree would already be a serious theorem about radicals. And the distribution at depth $n$ is governed by the radicals of $n(n+1)$ along the spines, which are exactly as hard as general $abc$ heuristics.

But the negative result is not a shrug; it is a localization. We now know exactly which half of the problem the tree solves. The geometry — growth rate, descent, the structure of every node, the collapse $\operatorname{rad}(a^2b^2c^2) = \operatorname{rad}(abc)$, the floor $2/3$ and its exact rate, the existence of infinitely many hits — is completely explicit. The arithmetic — how small radicals can be — is untouched, and provably must be, because it *is* the conjecture.

That is what a solvable model is for. In physics you study the harmonic oscillator not because springs are interesting but because the exactly solvable case shows you what an approximate answer should look like. The Berggren tree is the harmonic oscillator of the $abc$ conjecture: everything except the essential difficulty can be computed in closed form, and the essential difficulty stands out in sharp relief, alone, in the denominator of a single logarithm.
