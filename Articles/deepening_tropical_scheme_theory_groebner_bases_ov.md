# When Algebra Forgets How to Subtract: Tropical Ideals and Their Hidden Matroids

## A world with only *min* and *plus*

Imagine an arithmetic in which addition of two numbers means *taking the smaller one*, and multiplication means *adding them*. This is not a joke; it is the **tropical semiring**, one of the most productive simplifications in modern mathematics. Write $\oplus$ for the new addition and $\odot$ for the new multiplication:

$$a \oplus b = \min(a, b), \qquad a \odot b = a + b .$$

Work with the rational numbers together with a symbol $\infty$, so that $\mathbb{T} = \mathbb{Q} \cup \{\infty\}$. Then $\infty$ behaves exactly like zero, because $\min(a,\infty) = a$; and the ordinary number $0$ behaves like one, because $a + 0 = a$. All the comfortable laws survive: both operations are associative and commutative, multiplication distributes over addition, and there is a zero and a one.

One law does *not* survive, and its absence is the whole story. There is no subtraction. If $\min(a,b) = \infty$ then both $a$ and $b$ must already be $\infty$; nothing can cancel anything. An algebra without subtraction is called a *semiring*, and doing geometry over a semiring — tropical geometry — has turned into a serious industry, because tropical shadows of classical varieties are piecewise-linear objects that a computer can actually manipulate. Curves become graphs, surfaces become polyhedral complexes, and hard enumerative questions become combinatorics.

But there is a catch, and everyone who has tried to build tropical *scheme* theory has run into it.

## The catch: ideals are too floppy

In classical algebraic geometry, the fundamental object is an ideal: a set of polynomials closed under addition and under multiplication by arbitrary polynomials. Ideals are rigid enough to encode a geometric object completely; the dictionary between ideals and varieties is the foundation of the subject.

Over the tropical semiring, the naive analogue collapses. Take the set of tropical polynomials closed under $\oplus$ and under $\odot$-multiplication — a *subsemimodule*. Because there is no subtraction, one can hardly ever "clean up" a combination: everything you form is a coordinatewise minimum of scaled copies of what you started with. The resulting objects are so plentiful and so unstructured that they carry almost no geometric information. Ideals over a semiring are too floppy to be schemes.

The repair, due to Maclagan and Rincón, is startling and beautiful: **add a combinatorial axiom borrowed from matroid theory**. A *tropical ideal* is a subsemimodule which, in each bounded degree, is not merely closed under the semiring operations but is the set of **vectors of a valuated matroid**. In one stroke this restores rigidity: tropical ideals have well-defined Hilbert functions, finitely many associated primes, and a genuine theory of Gröbner degeneration. The extra axiom is the whole difference between a shapeless semimodule and a scheme-like object.

This article is about that extra axiom: what it says, why it is not automatic, when it holds, when it fails, and what combinatorial structure it secretly encodes.

## Vectors, supports, and the elimination axiom

Fix a finite index set $E$ — think of it as a finite list of monomials. A **tropical vector** is a function $x : E \to \mathbb{T}$, one tropical number per coordinate. Coordinates equal to $\infty$ are "absent"; the set of coordinates where $x$ is finite is its **support**, $\operatorname{supp}(x)$. Two operations act on such vectors: coordinatewise minimum $x \oplus y$, and rescaling $a \odot x$, which adds the constant $a$ to every coordinate.

A set $V$ of tropical vectors is a **tropical linear space** if it contains the all-$\infty$ vector, is closed under $\oplus$ and under rescaling, and satisfies the following:

> **Vector elimination axiom.** If $x, y \in V$ and $e$ is a coordinate where $x_e = y_e \neq \infty$, then there exists $z \in V$ with
> - $z_e = \infty$ (the coordinate $e$ has been eliminated),
> - $z_i \geq \min(x_i, y_i)$ for every $i$, and
> - $z_i = \min(x_i, y_i)$ at every coordinate where $x_i \neq y_i$.

The classical shadow of this axiom is Gaussian elimination. Over a field, if two vectors have the same $e$-th coordinate you subtract them and that coordinate dies. Tropically you cannot subtract, so *existence of an eliminated vector must be postulated* — and the postulate is precisely what a valuated matroid provides. Notice how carefully the statement is worded: $z$ must be *pinned exactly* to $\min(x_i, y_i)$ where $x$ and $y$ disagree, and may only float *upward* where they agree. Without the pinning, the axiom would be vacuous — the all-$\infty$ vector would always work.

The basic example is a **tropical hyperplane**. Fix a coefficient vector $c : E \to \mathbb{T}$ and let
$$H(c) = \Big\{ x : E \to \mathbb{T} \ \Big|\ \min_{i \in E} (c_i + x_i) \text{ is attained at least twice} \Big\}.$$
This is the tropical solution set of the linear equation $c_1 \odot x_1 \oplus \dots \oplus c_n \odot x_n = \infty$: since a tropical sum cannot cancel, the honest definition of "the sum vanishes" is *the minimum is achieved by at least two terms*. It is convenient to state the same condition relationally — for every coordinate $i$ there is some other coordinate $j$ with $c_j + x_j \leq c_i + x_i$ — and over a finite index set the two formulations agree.

## The main theorem, and a lemma about lonely minima

**Theorem (Elimination for tropical hyperplanes).** *Every tropical hyperplane $H(c)$ satisfies the vector elimination axiom; consequently $H(c)$ is a tropical linear space.*

Why is this not obvious? Given $x, y \in H(c)$ agreeing at $e$, the obvious candidate is
$$z^0_i = \begin{cases} \infty, & i = e, \\ \min(x_i, y_i), & i \neq e. \end{cases}$$
It satisfies the two numerical conditions by construction. The trouble is membership: knocking one coordinate up to $\infty$ can destroy the "minimum attained twice" property. Exactly one thing can go wrong — the vector $z^0$ can have a **lonely minimum**: a coordinate $i_0$ with $c_{i_0} + z^0_{i_0}$ *strictly* below every other $c_j + z^0_j$.

The repair is to raise the lonely coordinate until the tie is restored. Let $\beta = \min_{j \neq i_0}(c_j + z^0_j)$ be the *second-smallest* value and choose $t$ with $c_{i_0} + t = \beta$ — possible because $c_{i_0}$ is finite, and tropical division is just ordinary subtraction. Replacing $z^0_{i_0}$ by $t$ produces a vector whose minimum is now attained at both $i_0$ and the coordinate realizing $\beta$, so it lies in $H(c)$. And since $t \ge z^0_{i_0}$, we only moved *upward*, which the axiom permits.

But permission is granted only where $x$ and $y$ agree. So the argument is complete only if we know:

**Rigidity Lemma.** *If the truncated minimum vector $z^0$ has a strictly unique minimal coordinate $i_0$, then $x$ and $y$ must already agree at $i_0$.*

This is the combinatorial heart, and it is proved by a short chase. Suppose the two disagreed, say $x_{i_0} < y_{i_0}$, so $\min(x_{i_0},y_{i_0}) = x_{i_0}$; write $\alpha = c_{i_0} + x_{i_0}$, which is finite because it is strictly below the value at $e$, namely $\infty$. Note the *exclusion principle*: at any coordinate $j$ other than $i_0$ and $e$ we have $z^0_j = \min(x_j,y_j)$, so an inequality $c_j + x_j \le \alpha$ or $c_j + y_j \le \alpha$ would contradict the strict minimality at $i_0$.

Now chase. Since $x$ lies in $H(c)$, some coordinate $j \ne i_0$ satisfies $c_j + x_j \le \alpha$; by exclusion, $j$ must be $e$, so $c_e + x_e \le \alpha$, and since $x_e = y_e$ also $c_e + y_e \le \alpha$. Since $y$ lies in $H(c)$, some coordinate $j' \ne e$ satisfies $c_{j'} + y_{j'} \le c_e + y_e \le \alpha$; by exclusion again, $j'$ must be $i_0$, giving $c_{i_0} + y_{i_0} \le \alpha = c_{i_0} + x_{i_0}$. Cancelling the finite $c_{i_0}$ yields $y_{i_0} \le x_{i_0}$, contradicting $x_{i_0} < y_{i_0}$. Hence the lonely minimum can never sit at a coordinate of disagreement, the upward move is legal, and the theorem follows.

## Sharpness: elimination is real content

Is the elimination axiom perhaps a formal consequence of closure under $\oplus$ and rescaling? No — and there is a small, explicit witness in four coordinates.

Take $c^{(1)} = (0,0,0,0)$ and $c^{(2)} = (0,0,0,1)$, and consider the intersection $H(c^{(1)}) \cap H(c^{(2)})$. Both vectors
$$x = (0,0,1,0), \qquad y = (0,0,1,1)$$
lie in the intersection, and they agree at coordinate $1$ (with finite value $0$). Suppose an eliminated $z$ existed. Then $z_1 = \infty$; at coordinate $4$, where $x$ and $y$ disagree, $z$ is *pinned* to $\min(0,1) = 0$; and $z_2 \ge 0$, $z_3 \ge 1$. Now membership in the first hyperplane, applied at coordinate $4$, forces $z_2 = 0$ (the only candidate left, since $z_1 = \infty$ and $z_3 \ge 1$). But then membership in the second hyperplane, applied at coordinate $2$, needs a coordinate whose $c^{(2)}$-adjusted value is at most $0$: coordinate $1$ is $\infty$, coordinate $3$ is at least $1$, and coordinate $4$ contributes $1 + 0 = 1$. All three fail. No such $z$ exists.

The intersection *is* a subsemimodule — closed under $\oplus$ and rescaling, since each hyperplane is. So the failure is a failure of elimination alone. Tropical linear spaces are not closed under set-theoretic intersection; the correct operation is *stable intersection*, which perturbs one hyperplane slightly before intersecting and takes a limit, thereby destroying exactly the accidental coincidence of minima that broke the example.

By contrast, two operations *do* survive. Rescaling all coordinates by a vector of finite tropical scalars — a tropical diagonal automorphism — preserves tropical linear spaces. And **deletion**, which keeps the members supported inside a chosen subset of coordinates and restricts them there, also preserves them. These are the two elementary minor operations of matroid theory, now available tropically.

## From tropical algebra to matroids: circuits

Forget the numerical values for a moment and remember only *which coordinates are finite*. A **circuit** of a tropical linear space is a minimal nonempty support of a nonzero member. Circuits are the classical combinatorial fingerprint of a matroid, and the tropical elimination axiom hands them over.

First, the numerical axiom implies a purely combinatorial one. Given two members $x,y$ whose supports both contain $e$, rescale $y$ by the constant $x_e - y_e$ so the two agree at $e$; apply elimination; the resulting $z$ has $z_e = \infty$ and is $\infty$ wherever both inputs were, so
$$\operatorname{supp}(z) \subseteq (\operatorname{supp}(x) \cup \operatorname{supp}(y)) \setminus \{e\}.$$
This is exactly Minty's vector elimination property for matroids. Strengthening it slightly — if $x$ has a support coordinate $f$ that $y$ lacks, the eliminated vector retains $f$ and hence is nonzero — and combining it with the fact that every nonzero member contains a circuit inside its support (take a support of minimal cardinality), one obtains:

**Theorem (Circuit elimination).** *In any tropical linear space over a finite ground set, if $C_1 \ne C_2$ are circuits and $e \in C_1 \cap C_2$, then there is a circuit $C_3 \subseteq (C_1 \cup C_2) \setminus \{e\}$.*

That is precisely the circuit axiom of a matroid. Every tropical linear space therefore carries an honest underlying matroid on its ground set — the combinatorial skeleton beneath the tropical numerics.

For a hyperplane with all coefficients finite, one can compute that skeleton exactly. Every nonzero member has at least two finite coordinates (a single lonely finite coordinate would be an unmatched minimum), and conversely, for any pair $\{i,j\}$ the vector with $x_i = -c_i$, $x_j = -c_j$, and $\infty$ elsewhere lies in $H(c)$ and has support exactly $\{i,j\}$. Hence:

**Theorem (Uniform matroid).** *The circuits of a tropical hyperplane with finite coefficients are exactly the two-element subsets: its underlying matroid is the uniform matroid $U_{n-1,n}$ on $n$ coordinates.*

## Bringing it home: the ideal of a point

All of the above is linear algebra. The reason to care is that it feeds a *scheme* theory, and for that one needs genuine tropical ideals of a polynomial semiring — and, ideally, one you can compute with.

Let $w$ be a point with rational coordinates. A tropical polynomial $f$ assigns to each exponent vector $u$ a tropical coefficient, and its $u$-th term takes the value $\operatorname{val}_u(f) = \text{coeff}_u(f) + \langle u, w\rangle$ at $w$. Say that **$f$ vanishes at $w$** if for every monomial $u$ there is a *different* monomial $u'$ with $\operatorname{val}_{u'}(f) \le \operatorname{val}_u(f)$ — the tropical minimum is attained at least twice, the only sensible meaning of vanishing without subtraction.

**Theorem (The vanishing set is an ideal).** *The polynomials vanishing at $w$ form an ideal of the tropical polynomial semiring.*

Closure under addition is a short case analysis, because the coefficients of a tropical sum are coordinatewise minima. Closure under multiplication is the substantive point. Let $f$ vanish at $w$ and let $g$ be arbitrary (both nonzero). Choose a monomial $a$ minimizing $\operatorname{val}(f)$; by vanishing there is a *second* minimizer $a' \ne a$. Choose $b$ minimizing $\operatorname{val}(g)$. Since the term values of a product are the tropical convolution
$$\operatorname{val}_v(fg) = \min_{p+q=v}\big(\operatorname{val}_p(f) + \operatorname{val}_q(g)\big),$$
every term of $fg$ is at least $M = \operatorname{val}_a(f) + \operatorname{val}_b(g)$, and both $a + b$ and $a' + b$ achieve $M$. These are distinct exponents because exponent addition cancels. So the global minimum of $fg$ is attained at least twice — and in fact at two exponents dominating any given one, which is exactly the relational form of vanishing.

**Theorem (It is a tropical ideal).** *For any finite set $E$ of at least two monomials, the coefficient vectors of the polynomials that vanish at $w$ and are supported on $E$ form exactly the tropical hyperplane $H(\langle \cdot, w\rangle)$ with coefficient vector $(\langle u, w \rangle)_{u \in E}$.*

One inclusion is a bookkeeping argument, with a wrinkle: a vanishing witness $u'$ might lie outside $E$, but then its term is $\infty$, which forces the term at $u$ to be $\infty$ too, and any other monomial of $E$ serves as a witness. The other inclusion reconstructs a polynomial from a vector of the hyperplane. Combining with the elimination theorem: **each finite-monomial truncation of the vanishing ideal of a point is a tropical linear space**, so the vanishing ideal is a tropical ideal in the Maclagan–Rincón sense — and its degreewise matroid is uniform, its circuits in every degree being exactly the pairs of monomials.

Concretely, elimination now reads as a statement about polynomials: two polynomials vanishing at $w$, supported on $E$, whose coefficients agree in a finite value at some monomial $e$, can be combined into a third polynomial that vanishes at $w$, is supported on $E$, has *no* $e$-term, dominates their tropical sum everywhere, and equals it at every monomial where they differ. That is tropical Gaussian elimination on polynomials, and it is exactly the step a Gröbner-style algorithm needs.

Finally, the machinery runs. Relative to any finite test set $U$ of tropical polynomials and any monomial order, a Buchberger-style completion process — repeatedly enlarging a candidate family by an element of the ideal inside $U$ that is not yet reducible — terminates on the vanishing ideal of a point in at most $|U|$ steps, and a family is a Gröbner basis relative to $U$ exactly when the completion step leaves it unchanged. Termination is by a counting argument: each non-trivial step strictly increases the size of a family confined to $U$.

## Why it matters

The moral is that tropical geometry is *matroid theory wearing numerical clothes*. The single axiom that turns a floppy semimodule into a scheme-like object is a statement about eliminating a coordinate — the same statement that defines a matroid, decorated with values.

The results above assemble the smallest complete example of that philosophy: hyperplanes satisfy elimination; the axiom is genuine, since intersections can break it; minor operations preserve it; the axiom's shadow is a matroid, computed exactly for hyperplanes; and a real ideal of a polynomial semiring, the vanishing ideal of a point, satisfies it in every degree, providing the first concrete instance on which tropical Gröbner machinery can be exercised.

The natural next steps are equally concrete. Does *stable* intersection repair the failure exhibited above — is the perturbed-and-limited intersection of two hyperplanes always a tropical linear space? Is every tropical linear space obtainable from hyperplanes by stable intersection and deletion, reassembled along its circuits? And do more interesting tropical ideals — the vanishing ideal of two points, or the tropicalization of a curve — have *non-uniform* degreewise matroids, with strictly fewer circuits than all pairs? The single-point case computed here is the base of that comparison: it is the maximally generic answer, and anything more interesting must be strictly smaller.

Min and plus, and one axiom about elimination. It is remarkable how far that goes.
