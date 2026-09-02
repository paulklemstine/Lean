# Checking Algebra by Counting: How Finitely Many Numbers Prove an Identity Everywhere

## A very old trick, taken seriously

Every student of algebra learns to expand
$$(a+b)^3 = a^3 + 3a^2b + 3ab^2 + b^3.$$
And every student learns to *verify* it the same way: multiply everything out, collect terms, hope the bookkeeping went right.

There is another way. Plug in numbers. Try $a=0,b=0$; then $a=1,b=0$; then $a=0,b=1$; and so on across a small square of integer pairs. If the two sides agree at enough well-chosen points, they are *the same expression* — not merely for those numbers, not merely for the real numbers, but for matrices, for polynomials, for the integers modulo $7$, for any system whatsoever in which addition and multiplication behave the way we expect.

That statement sounds too strong to be true, and yet it is exactly true, provided one is precise about what "enough points" means. This article is about making it precise, pushing it to its logical limit, and discovering that the answer is a piece of geometry: the *shape* of an identity determines the *shape* of the finite set of numbers that certifies it.

## The two questions

Fix a number of variables $n$ and a *degree budget* $d$. Two questions organise everything that follows.

**Question 1 (sufficiency).** Which finite sets $T$ of points have the property that any two polynomial expressions of total degree at most $d$ that agree at every point of $T$ are the same expression?

Call such a $T$ a **uniqueness set** for degree $d$.

**Question 2 (economy).** Among all uniqueness sets, which are the smallest?

The first question is about correctness of a testing procedure. The second is about its cost, and — as we shall see — the cost is where the interesting mathematics lives.

## The naive answer, and why it works

The naive uniqueness set is a grid. Take the integers $\{0,1,2,\dots,d\}$ in each coordinate and form the box
$$G(n,d) = \{0,1,\dots,d\}^n,$$
a set of $(d+1)^n$ points. The **Degree-Graded Exactness Theorem** says this always works:

> *If two polynomial expressions in $n$ variables, each of total degree at most $d$ and with integer coefficients, take equal values at all $(d+1)^n$ points of $\{0,\dots,d\}^n$, then they are literally the same polynomial — and consequently they define the same function on every commutative ring.*

Why $d+1$ points per coordinate and not fewer? Because of the single most famous fact about polynomials: a nonzero polynomial in one variable of degree $d$ has at most $d$ roots. Consider the difference $p - q$ of the two sides; it has total degree at most $d$ and vanishes on the whole grid. Freeze all coordinates but the first at grid values; what remains is a one-variable polynomial of degree at most $d$ with $d+1$ roots, hence identically zero. Peel off one variable at a time and the whole difference collapses.

And $d+1$ cannot be lowered. The single-variable expression
$$x(x-1)(x-2)\cdots(x-(d-1))$$
has degree $d$ and vanishes at all $d$ points $0,1,\dots,d-1$ — yet it is emphatically not the zero expression, as $x=d$ shows. So $d$ values per coordinate never suffice, for any $d$. The grid bound is sharp on the nose.

## From integers to *everything*

Here is the part that deserves a moment's astonishment. The check happens at integers. The conclusion holds in every commutative ring.

The reason is that an expression built from variables, integer constants, $+$, $-$, $\times$ has a *generic* value: the polynomial in $\mathbb{Z}[x_1,\dots,x_n]$ obtained by leaving the variables uninterpreted. Whatever ring you eventually substitute into, the answer is the image of that generic polynomial under the unique map from the integers into the ring. So if two expressions have the *same* generic polynomial, they agree everywhere, in every ring, automatically. The finite grid check does not verify infinitely many instances; it pins down a single algebraic object.

This closes into an exact equivalence, which one might call the **Completeness Theorem**:

> *For expressions of degree at most $d$, the following three statements are equivalent: (i) the two sides agree at the $(d+1)^n$ grid points; (ii) they denote the same polynomial with integer coefficients; (iii) they define the same function on every commutative ring.*

Nothing is lost by testing on the grid: the test is **sound** (a pass proves universal validity) *and* **complete** (a universally valid identity always passes). Since the grid is finite and integer arithmetic is exact, this makes the question "is this a universally valid ring identity?" **decidable**. There is an algorithm. It terminates. It is never wrong in either direction.

A pleasant corollary: the integers alone form a *test ring*. If an identity between such expressions holds for all integer inputs, it holds in every commutative ring — no degree hypothesis needed, because $\mathbb{Z}$ is infinite.

The theorem also swallows the classical low-degree arguments as special cases. Degree $1$ needs the two-point chart $\{0,1\}$; degree $2$ the three-point chart $\{0,1,2\}$; degree $3$ the four-point chart. The degree-three case was traditionally proved by extracting three linear constraints from the linear independence of the coordinate functions; that independence is now itself a corollary — a linear function $c_0 + \sum_i c_i x_i$ vanishing on the cube $\{0,1\}^n$ has all $c_i = 0$, since substituting the zero point gives $c_0=0$ and substituting the $i$-th standard basis vector gives $c_i = 0$.

## Being wasteful

$(d+1)^n$ is a large number. For three variables and degree three it is $64$; for five variables and degree five, $7776$. Is all that testing necessary?

Certainly not, and one can see why by counting. A polynomial of total degree at most $d$ in $n$ variables is determined by its coefficients, and the number of monomials $x_1^{a_1}\cdots x_n^{a_n}$ with $a_1+\cdots+a_n \le d$ is the binomial coefficient
$$\binom{n+d}{n}.$$
For $n=d=3$ that is $20$, not $64$. A uniqueness set is exactly a set of points at which the evaluation map from this coefficient space is injective — and a linear map from a space of dimension $\binom{n+d}{n}$ into functions on $|T|$ points cannot be injective if $|T|$ is smaller. So:

> **Dimension Lower Bound.** *Every uniqueness set for total degree $\le d$ in $n$ variables contains at least $\binom{n+d}{n}$ points.*

There is also a cruder but very robust statement in the same spirit, valid over any integral domain, cleverly chosen point sets included:

> **No small uniqueness set.** *For any finite set $T$ of at most $d$ points in $R^n$ (with $n\ge 1$ and $R$ a domain), there is a nonzero polynomial of total degree at most $d$ vanishing on all of $T$.*

The witness is disarmingly simple: take the product $\prod_{t\in T}(x_1 - t_1)$ over the first coordinates of the points of $T$. It has degree $|T| \le d$, it is nonzero, and it kills every point of $T$. So no amount of cleverness rescues a set of $d$ points or fewer.

Now there is a gap: the grid uses $(d+1)^n$ points, and the lower bound only demands $\binom{n+d}{n}$. Which is right?

## The simplex closes the gap

The answer is the smaller number, and the optimal node set is beautiful: keep only the *corner* of the grid.

$$S(n,d) = \{(a_1,\dots,a_n)\in\mathbb{N}^n : a_1 + \cdots + a_n \le d\}$$

This is the **simplex lattice** — the lattice points in a right-angled simplex with legs of length $d$. For $n=2,d=3$ it is the triangular array
$$(0,0),(1,0),(2,0),(3,0),(0,1),(1,1),(2,1),(0,2),(1,2),(0,3),$$
ten points rather than sixteen. In general $|S(n,d)| = \binom{n+d}{n}$ exactly — the same hockey-stick count as the monomials.

> **Simplex Unisolvence.** *Over a field of characteristic zero, a polynomial of total degree at most $d$ that vanishes at every point of the simplex lattice $S(n,d)$ is identically zero.*

The proof is a double induction, on the degree and on the number of variables, and it has a genuinely geometric flavour. Look at the outer face of the simplex, the hyperplane $x_1+\cdots+x_n = d$. Substituting $x_1 \mapsto d - (x_2+\cdots+x_n)$ turns $p$ into a polynomial in $n-1$ variables that still has degree at most $d$ and still vanishes on the simplex lattice of *its* dimension; by the induction on the number of variables it is zero. That means the linear form $x_1+\cdots+x_n-d$ divides $p$. Dividing it out leaves a cofactor of degree at most $d-1$ vanishing on the smaller simplex $S(n,d-1)$ — and the induction on degree finishes the job. The simplex is peeled like an onion, one face at a time.

Combined with the dimension bound, this is a satisfying pincer: the simplex lattice is a uniqueness set, and it has exactly the minimum possible number of points. It is optimal, and for $n\ge 2$, $d\ge 1$ it is *strictly* smaller than the box grid.

Concretely: the binomial cube is now certified by $10$ evaluations rather than $16$; the classical factorisation
$$a^3+b^3+c^3-3abc = (a+b+c)(a^2+b^2+c^2-ab-bc-ca)$$
by $20$ evaluations rather than $64$ — and, once certified, it holds in every commutative ring on Earth.

## A crack in the floor: characteristic

Characteristic zero was not a technicality. In characteristic $p$, the polynomial
$$x^p - x$$
vanishes at every element of the prime field — Fermat's little theorem, in its algebraic dress. So as soon as $d \ge p$, the simplex lattice contains only points whose coordinates are integers reduced mod $p$, and the Artin–Schreier polynomial $x_1^p - x_1$ is a nonzero degree-$p$ witness vanishing at all of them. The lattice fails.

And the failure is exactly calibrated:

> *Over a domain, the simplex lattice $S(n,d)$ is a uniqueness set for total degree $\le d$ whenever $d < \operatorname{char}$, and — in prime characteristic $p$ — fails as soon as $d \ge p$.*

The threshold $d < p$ is not an artefact of the proof. It is the truth.

## The shape of an identity

Total degree is a blunt instrument. Consider the two-variable inclusion–exclusion identity
$$(1-a)(1-b) = 1 - a - b + ab.$$
Its total degree is $2$, so the total-degree machinery demands nine points, or six after the simplex improvement. But look at the identity: no variable ever appears squared. Such an expression is **multilinear**, affine in each variable separately, and a much cheaper theorem applies:

> **Multilinear Exactness.** *Two expressions that are affine in each variable separately and agree at the $2^n$ points of the Boolean cube $\{0,1\}^n$ define the same function on every commutative ring.*

Four points suffice for the identity above. More generally, if variable $i$ occurs to degree at most $D_i$, the box $\prod_i \{0,\dots,D_i\}$ of $\prod_i (D_i+1)$ points does the job. This is a real saving: for $n \ge 2$, $2^n < (n+1)^n$.

Once you see this, the right question emerges. Total degree tracks a triangle; per-variable degree tracks a box. Both are crude approximations to the real invariant of a polynomial, which is its **support**: the set of exponent vectors that actually occur.

## Downsets: the final form

Say a set $D$ of exponent vectors is a **downset** (a lower set) if whenever $a$ is in $D$ and $b \le a$ coordinatewise, then $b$ is in $D$ too. Downsets are exactly the "staircase" shapes: the lattice points of a Newton polytope, closed under moving toward the origin. Both earlier examples are downsets — the simplex $\{\sum a_i \le d\}$ and the box $\{a_i \le D_i\}$ — but downsets are far more flexible: an L-shape, a staircase, any monomial-ideal complement.

To each downset attach its own node set: the points of $\mathbb{N}^n$ that *are* the exponent vectors of $D$, read as coordinates. Then:

> **Downset Unisolvence.** *Let $D$ be a downset of exponents. Over a domain of characteristic zero, a polynomial whose support lies inside $D$ and which vanishes at all $|D|$ lattice nodes of $D$ is identically zero.*

The proof is one induction on the number of variables, and it is short enough to describe. Write $p$ as a polynomial in $x_1$ with coefficients in the remaining variables, and let $N$ be its top $x_1$-degree. The leading coefficient is supported in the *fibre* of $D$ over height $N$; and because $D$ is a downset, above every such fibre point the entire column of nodes at heights $0,1,\dots,N$ lies in $D$. Restricting $p$ to that column gives a univariate polynomial of degree at most $N$ with $N+1$ distinct roots — so it vanishes, killing the leading coefficient. Descend and repeat.

The converse holds too. Evaluation at the $|D|$ nodes is a *bijection* from the space of polynomials supported in $D$ onto arbitrary functions on the nodes. That means downset interpolation always exists and is unique — and since $|D|$ is exactly the dimension of the space, the node set is of minimum cardinality. There is no fat left to trim.

Three consequences fall out immediately. Sublevel sets of a **weighted degree** $\sum_i w_i a_i \le d$ are downsets, giving unisolvence for quasi-homogeneous polynomials. Setting all $w_i=1$ recovers the simplex; the per-variable box recovers the box grid. And the characteristic threshold is again exact: coordinates must stay below the characteristic, with $x_1^c - x_1$ the witness when they don't.

Weights buy real savings. The identity
$$(a^2+b)(a^2-b) = a^4 - b^2$$
is quasi-homogeneous of weighted degree $4$ for the weights $w=(1,2)$. Its weighted node set has **nine** points. The total-degree simplex for degree $4$ in two variables has $15$; the box grid $\{0,\dots,4\}^2$ has $25$. As weights grow, the saving is unbounded.

Are downsets *strictly* more general than weighted sublevel sets, or is the weighted picture already everything? Strictly more general — and a two-variable example settles it. The staircase
$$D = \{(a,0): a\le 2\} \cup \{(0,b): b \le 2\}$$
(the two arms of a cross, but not the corner) is a downset that omits the exponent $(1,1)$. Yet *every* weighted simplex $\{w_1 a + w_2 b \le d\}$ containing $D$ must contain $(1,1)$: from $2w_1 \le d$ and $2w_2 \le d$ one gets $w_1 + w_2 \le d$. So no choice of weights isolates this downset. The support-adapted theory sees shapes the weighted theory cannot.

## What has actually been built

Step back and the picture is a single, complete theory of *finite certificates for universal algebraic identities*, with four moving parts.

**Sufficiency.** A finite set of integer points certifies an identity, and the certificate transfers to every commutative ring — box grid, simplex lattice, or general downset, according to the shape of the identity.

**Sharpness.** Each bound is exactly attained: $d$ points per coordinate always fail; no set of $\le d$ points ever works; the characteristic thresholds are precise, with Artin–Schreier witnesses on the wrong side.

**Optimality.** Uniqueness sets need at least $\binom{n+d}{n}$ points for total degree $d$, and at least $|D|$ points for a downset $D$; the simplex lattice and the downset node set attain these bounds. There is nothing better.

**Completeness.** The finite check is not merely sufficient — it is equivalent to universal validity. Hence identity testing in this calculus is decidable, and interpolation on the nodes is a linear isomorphism onto functions.

## Why it matters beyond the pleasure of it

The pattern "test at finitely many points, conclude everywhere" is the engine of a surprising amount of modern computing.

*Polynomial identity testing* is the archetypal problem for which randomised algorithms hugely outperform known deterministic ones, and the Schwartz–Zippel lemma — evaluate at random points from a large enough set — is its workhorse. The theorems above are the *deterministic*, *exact*, and *optimal* version of the same instinct: no randomness, no error probability, and a provably minimum number of evaluation points once the support shape is known.

*Error-correcting codes.* Reed–Muller codes are precisely evaluations of bounded-degree polynomials on a grid; the unisolvence statements are the statements that the encoding map is injective, and the interpolation statements are the decoding maps. The downset version is the sparse, support-adapted refinement.

*Finite elements and numerical analysis.* The simplex lattice is the classical node set for Lagrange elements on triangles and tetrahedra. The unisolvence theorem here is exactly the statement, made airtight, that those nodes determine the shape functions — with the characteristic condition an unexpected reminder of what fails outside the real numbers.

*Symbolic computation.* Verifying a proposed algebraic identity by expansion is expensive and error-prone; verifying it by evaluation at a minimum-size, support-adapted node set is cheap, mechanical, and — by completeness — never gives a false negative.

There is a moral, too. Testing polynomials with numbers is not a heuristic that happens to work. Rightly organised, it is *complete information*. And the right organisation is not a matter of taking more points, but of taking the points that match the shape of the question.

The oldest trick in algebra turns out, on inspection, to be an exact science.
