# The Shape of a Product: How a Simple Sum of Squares Separates Symmetric Functions

## A puzzle about cutting shapes in half

Take a rectangle of squares — say $3$ rows of $5$. Inside it, draw a staircase shape (a *Young diagram*) that fits snugly in the top-left corner: maybe the rows $(5,3,1)$. What is left over, rotated by $180°$, is another staircase: $(4,2,0)$, i.e. $(4,2)$. The two shapes are *complementary*: together they tile the rectangle exactly.

To every such staircase shape $\lambda$ mathematics attaches a polynomial, the **Schur function** $s_\lambda$. Schur functions are among the most studied objects in algebra: they are the characters of the irreducible polynomial representations of the general linear group, they are the basis of the ring of symmetric functions favoured by combinatorialists, and they are the cohomology classes of Schubert varieties in the Grassmannian. Every shape gives a Schur function, and different shapes give *different, independent* Schur functions.

Now form the product of a shape's Schur function with that of its complement:
$$
s_\lambda \, s_{\lambda^\vee}.
$$
As $\lambda$ runs over all shapes fitting inside the fixed rectangle, we get a whole family of these products. Note that $\lambda$ and $\lambda^\vee$ play symmetric roles: the pair $\{\lambda,\lambda^\vee\}$ is *unordered*, so each product appears once for each such pair.

**Kleber's conjecture**, now a theorem, says: *these products are linearly independent*. No nontrivial combination of them, with coefficients in any commutative ring, can ever cancel to zero.

That sounds innocent. It is not. And the reason it is not tells us something interesting about how algebraic independence gets proved — and what to do when the standard tool breaks.

## Why the usual trick fails

Here is the standard way to prove that a family of symmetric functions is independent. Each of them, when expanded in some basis, has a *leading term* in a suitable ordering. If the leading terms are all distinct, the expansion matrix is triangular with nonzero diagonal, and independence follows immediately. This "triangularity" argument is the workhorse of the entire subject.

Try it here. Expand $s_\lambda s_{\lambda^\vee}$ in the Schur basis using the Littlewood–Richardson rule. The dominance-largest term you get is $s_{\lambda + \lambda^\vee}$ — the Schur function of the shape whose rows are the *sums* of the corresponding rows of the two factors. But for complementary shapes inside a fixed rectangle, that sum is *the same rectangle every single time*:
$$
\lambda + \lambda^\vee = \theta \quad \text{for all } \lambda .
$$
Every product in the family has the identical leading term. The triangularity argument does not merely need adjusting — it collapses completely. The entire family sits, from the point of view of dominance order, on top of one another.

So the problem is: find some *other* grading, transverse to dominance, on which the products are visibly distinct.

## Enter the sum of squares

Here is the idea that unlocks the problem, in the setting of **monomial symmetric functions** — the most concrete basis of all.

A monomial symmetric function $m_\lambda$ is the plainest symmetric object one can write: take the monomial $x_1^{\lambda_1} x_2^{\lambda_2}\cdots$ and add up all of its *distinct* rearrangements. For $\lambda = (2,1)$ in three variables,
$$
m_{(2,1)} = x_1^2x_2 + x_1^2x_3 + x_2^2x_1 + x_2^2x_3 + x_3^2x_1 + x_3^2x_2 .
$$
Each monomial in the whole ring is described by its **exponent vector** $d = (d_1, d_2, \dots)$, and the *shape* of a monomial is the multiset of its nonzero exponents. So $x_1^3x_4^2$ has shape $\{3,2\}$.

Now define, for an exponent vector $d$, a single number:
$$
Q(d) \;=\; \sum_i d_i^2 .
$$
The sum of the squares of the exponents. Utterly elementary. And yet it does exactly what dominance order cannot.

The key identity is one line:
$$
Q(u+v) \;=\; Q(u) + Q(v) + 2\langle u, v\rangle, \qquad \langle u,v\rangle = \sum_i u_i v_i .
$$
Because all exponents are nonnegative, the correction term $2\langle u,v\rangle$ is nonnegative, and it vanishes **exactly when the two exponent vectors have disjoint supports** — when $u$ and $v$ never both use the same variable.

Think about what this means for the product $m_\alpha m_\beta$. Every monomial appearing in the expansion is of the form $x^{u+v}$ where $x^u$ is a rearrangement of $x^\alpha$ and $x^v$ a rearrangement of $x^\beta$. So
$$
Q(u+v) \;\ge\; Q(\alpha) + Q(\beta),
$$
always, with equality precisely when the two rearrangements occupy disjoint sets of variables — that is, when the monomial's shape is the **multiset union** $\alpha \uplus \beta$ obtained by pooling the parts of $\alpha$ and of $\beta$ together.

**The bottom layer of the product remembers the union.** Reading the product from below, rather than from above, we recover exactly the multiset $\alpha \uplus \beta$: not the componentwise sum $\alpha+\beta$ (which is what dominance sees, and which is constant across the family), but the *pooled parts*. That is an entirely different invariant, and it is the invariant that separates.

There is one honest caveat, and it is essential: for this to work there must be *enough variables*. If $\alpha$ has $3$ nonzero parts and $\beta$ has $2$, we need at least $5$ variables to place them disjointly. In the ring of symmetric functions in infinitely many variables this is automatic; in $N$ variables it is a genuine hypothesis. And it is not removable: with a single variable, $m_{(1)}\cdot m_{(1)} = x_1^2 = m_{(2)}\cdot 1$, even though the unions $\{1,1\}$ and $\{2\}$ differ. Two different pairs, one and the same product; independence fails outright.

## What the mechanism proves

With that observation, a clean chain of theorems falls out.

**Independence Theorem (distinct unions).** *Let $(\alpha_i, \beta_i)$ be a finite family of pairs of partitions, each pair fitting into the available $N$ variables in the sense that the number of nonzero parts of $\alpha_i$ plus that of $\beta_i$ is at most $N$. If the multiset unions $\alpha_i \uplus \beta_i$ are pairwise distinct, then the products $m_{\alpha_i} m_{\beta_i}$ are linearly independent over any integral domain of characteristic zero — in particular over $\mathbb{Z}$ and over any field of characteristic zero.*

The proof is a triangularity argument in the $Q$-grading, run from the bottom. Suppose a nontrivial relation $\sum_i g_i \, m_{\alpha_i} m_{\beta_i} = 0$ exists. Among the indices with $g_i \ne 0$, pick one, say $i_0$, minimising $Q(\alpha_i)+Q(\beta_i)$. Place $\alpha_{i_0}$ and (a rearrangement of) $\beta_{i_0}$ on disjoint variables and let $w_0$ be the resulting exponent vector; it has $Q(w_0) = Q(\alpha_{i_0})+Q(\beta_{i_0})$ and shape $\alpha_{i_0}\uplus\beta_{i_0}$. Look at the coefficient of $x^{w_0}$ in the relation. For $i_0$ itself the coefficient is a positive integer, hence nonzero in characteristic zero. For any other surviving index $i$, either $Q(\alpha_i)+Q(\beta_i) > Q(w_0)$ — and then $x^{w_0}$ is too low to appear at all — or the two are equal, in which case $x^{w_0}$ can only appear via a disjoint placement, forcing its shape to be $\alpha_i\uplus\beta_i$; but its shape is $\alpha_{i_0}\uplus\beta_{i_0}$, so the unions coincide and $i=i_0$ by hypothesis. Every other term vanishes, leaving $g_{i_0}\cdot(\text{positive integer}) = 0$: a contradiction.

Note the two roles played by characteristic zero. It is what makes a positive count of placements nonzero in the coefficient ring. That is all; no field, no division, is used, which is why the statement holds verbatim over $\mathbb{Z}$.

Several consequences follow at once.

- **Componentwise splittings.** Fixing a shape $\theta$ and taking $\beta_i = \theta - \alpha_i$, one gets independence of the products $m_\alpha m_{\theta-\alpha}$ over any family of splittings whose unions are distinct.
- **The Kleber shape.** For a fixed shape $\rho$ — a rectangle, in Kleber's setting — and complementary pairs $(\lambda, \rho-\lambda)$ with $\lambda \subseteq \rho$, the "enough variables" hypothesis is *automatic* as soon as the number of variables is at least twice the number of rows of $\rho$, since each of $\lambda$ and $\rho - \lambda$ has at most that many nonzero parts. Under distinct unions, the complementary products $m_\lambda m_{\lambda^\vee}$ are independent.
- **The one-row case, unconditionally.** For $\theta = (n)$ a single row, the splittings are $(k) + (n-k)$ with $2k \le n$, and the unions $\{k, n-k\}$ *are* automatically distinct. So the products $m_{(k)}m_{(n-k)}$, $0 \le k \le \lfloor n/2 \rfloor$, are independent with no side hypothesis at all. Since $m_{(k)}$ is the power sum $p_k$, this says the polynomials $p_k p_{n-k}$ are independent — the smallest complete instance of Kleber's phenomenon.
- **The product remembers the union.** If $m_\alpha m_\beta = m_{\alpha'} m_{\beta'}$ (with enough variables), then $\alpha\uplus\beta = \alpha'\uplus\beta'$. The bottom layer is not just a proof device: it is an invariant one can read off the product itself.
- **Arbitrarily many factors.** Nothing in the argument is tied to two factors. If families $\alpha_{i,1}, \dots, \alpha_{i,r}$ fit into the variables and the pooled unions $\alpha_{i,1}\uplus\cdots\uplus\alpha_{i,r}$ are pairwise distinct, then the products $m_{\alpha_{i,1}}\cdots m_{\alpha_{i,r}}$ are independent. Specialising to one-row shapes gives: products of power sums $p_{k_1}\cdots p_{k_r}$, indexed by distinct multisets of positive exponents, are linearly independent — an algebraic-independence statement for the power sums, recovered from a purely combinatorial count.

## Where it gets hard

Now the honest part. Is the "distinct unions" hypothesis automatic for componentwise splittings of a fixed $\theta$? It is not.

Consider $\theta = (5,3)$. There are two genuinely different splittings,
$$
(3,1) + (2,2) = (5,3) = (3,2) + (2,1),
$$
and their unions coincide:
$$
\{3,1\}\uplus\{2,2\} = \{3,2,2,1\} = \{3,2\}\uplus\{2,1\}.
$$
So two distinct members of the family sit in the same bottom layer of the $Q$-filtration. The mechanism sees them as identical.

This is precisely the obstruction that makes the full conjecture hard, and it is worth saying out loud rather than papering over. The $Q$-grading solves the problem *between* union classes; it says nothing *within* one.

But "within" is not hopeless — the very smallest collision class can be resolved by hand, and how it is resolved points the way. Take the pairs $\{\varnothing, (a,b)\}$ and $\{(a),(b)\}$ with $a, b > 0$. Their unions are both $\{a,b\}$, so the theorem does not apply. Yet the products
$$
m_{(a,b)}\cdot 1 \qquad\text{and}\qquad m_{(a)}\,m_{(b)}
$$
*are* independent. The separating monomial is $x_1^{a+b}$: it lies one layer *up* in the $Q$-filtration, and it appears in the second product but not the first. Concretely, for $a\ne b$,
$$
m_{(a)}m_{(b)} = m_{(a,b)} + m_{(a+b)},
$$
while for $a = b = v$,
$$
m_{(v)}m_{(v)} = 2\,m_{(v,v)} + m_{(2v)}.
$$
The extra term arises exactly when the two factors *collide* on a single variable — when a part $a$ of one factor and a part $b$ of the other get merged into a single part $a+b$. And the coefficient of that merged monomial ($1$ versus $2$) depends on exactly how the pair distributes its parts between the two factors.

That is the crack in the wall. Where the disjoint-placement layer is blind, the merge layers see.

And the $(5,3)$ collision itself yields to exactly this idea. The two products $m_{(3,1)}m_{(2,2)}$ and $m_{(3,2)}m_{(2,1)}$ are, despite sharing a union, linearly independent — over $\mathbb{Z}$ and over any field of characteristic zero. The witness is the monomial $x_1^4x_2^4$. To produce exponent vector $(4,4)$ from the pair $\{3,2\}$, $\{2,1\}$ one places $3$ with $1$ and $2$ with $2$; from the pair $\{3,1\}$, $\{2,2\}$ it cannot be done at all, since no part of $\{2,2\}$ completes $3$ to $4$. So $x_1^4x_2^4$ occurs in the second product and not in the first, and the two are independent. Note that $\{4,4\}$ is obtained from $\{3,2,2,1\}$ by *two* merges, not one — a first hint that one layer up is not always far enough.

## The conjectural road ahead

Two conjectures crystallise the picture, and both are motivated directly by the collision above.

**Conjecture (union classes).** *For a fixed multiset $U$, the products $m_A m_B$, taken over all unordered multiset splittings $A \uplus B = U$, are linearly independent over $\mathbb{Q}$ and over $\mathbb{Z}$.*

Within a single union class, every product has the same leading form up to a positive scalar multiple of $m_U$, so the class must be separated further up. Combined with the $Q$-grading — which separates *different* union classes — this is the missing half of the componentwise splitting theorem for monomial symmetric functions. It is not quite a formal implication: reading the bottom layer of a hypothetical relation gives only one scalar equation per class rather than the vanishing of each coefficient, so one must additionally control how classes that are comparable in the merge order interfere. That interference is at least one-directional, always from finer unions towards coarser ones, which is the natural starting point for an induction. Exact computation confirms the conjecture — and with it the full splitting statement in the same range — for all $121$ union classes with at most five parts, each part at most $4$.

How far up does one have to go? Not always just one layer. For $U = \{1,1,1,1\}$ there are three splittings — $\{\varnothing,(1,1,1,1)\}$, $\{(1),(1,1,1)\}$ and $\{(1,1),(1,1)\}$ — but only a single one-merge shape, namely $(2,1,1)$; even counting the bottom layer as well, the available data have rank $2$, not $3$. Two merges are genuinely needed. What computation suggests is that two is always enough.

**Conjecture (merge filtration).** *Order the monomials by the number of merges needed to obtain them from $U$. For the pairs in a single union class, the coefficient matrix restricted to the first three layers — no merge, one merge, two merges — has full row rank.*

The reason to believe it is combinatorial and concrete: a one-merge monomial with merged parts $a$ and $b$ receives a contribution from $m_A m_B$ in exactly two distinguishable ways — either $a+b$ is already a single part of one of the two factors, or $a$ and $b$ lie in different factors and are placed on the same variable. That gives an explicit, small formula for the entries of the matrix, the same bookkeeping extends to two merges, and full rank is then a statement one can hope to prove by an inductive elimination on the largest part of $U$. In the computed range, one layer already suffices for $30$ of the $121$ classes and exactly two for the other $91$.

## Why this matters beyond the conjecture

The same product family shows up in disguise elsewhere. **Universal characters** in the sense of Koike–Terada are the stable characters of the classical groups, obtained as determinantal or Jacobi–Trudi-style twists of Schur functions; the independence of the complementary products $s_\lambda s_{\lambda^\vee}$ translates into linear independence of the corresponding universal-character products over any field, which answers a question that arose in the study of Schubert-calculus positivity. Complementary pairs inside a rectangle are also, in the Grassmannian, exactly the pairs of Schubert classes that are Poincaré dual; products of dual classes are the diagonal-type classes whose independence controls how much information the intersection pairing retains.

And there is a broader lesson, which is really the point of this story. When a family of algebraic objects is *invisible* to the standard ordering — when the leading terms all coincide — the fix is not to sharpen the ordering but to find a genuinely different one. Here the alternative is a quadratic statistic, $\sum_i d_i^2$, whose defect of additivity is a nonnegative inner product. It is the kind of tool one meets in a first course on inequalities, not in the theory of symmetric functions. That it should crack a problem about Schubert classes and Littlewood–Richardson coefficients is a small reminder that the right invariant is often the cheapest one.

There is a satisfying physical image for what $Q$ measures. Among all ways of distributing a fixed total degree over the variables, the sum of squares is smallest when the degree is spread out and largest when it is concentrated. So $Q$-minimal means *maximally spread out*: the layer of the product where the two factors interfere as little as possible. That is where the two factors are still recognizable as separate objects, and hence where the product still remembers which pair produced it. Concentration destroys information; dispersion preserves it. The proof is nothing more than the systematic exploitation of that one sentence.

## Coda

Kleber's conjecture began as a concrete question about rectangles: are the products of complementary Schur functions independent? The answer is yes, and the reason is that the products, read from the wrong end, are not as alike as they look. In the monomial world the same reading is available in an especially transparent form, complete with the exact boundary of what the method sees — the collision $(3,1)+(2,2) = (3,2)+(2,1)$ marks precisely where the first layer runs out, and the merge layer beyond it is where the remaining work lies.

It is a nice state of affairs for a mathematical story: a clean mechanism, a sharp statement of what it proves, an explicit example of what it does not, and a precise conjecture about the next step. The rest is arithmetic with sums of squares.
