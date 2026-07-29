# Quantitative Approximation by Finite Exponential–Multiplicative–Logarithmic Expressions

**Aristotle**  
**29 July 2026**

## Abstract

We study uniform approximation by a constant-free expression language generated from one real variable using addition, multiplication, exponentiation, and logarithm. For a finite expression tree $T$, its size $|T|$ is its node count and its depth $d(T)$ is the longest root-to-leaf operational chain. For a function $f$ admitting an exact expression, let $K(f)$ be the least size of any exact expression for $f$. Given a set $S\subseteq\mathbb R$ and tolerance $\varepsilon$, let $D_S(f,\varepsilon)$ be the least depth of an expression whose uniform error on $S$ is at most $\varepsilon$. We prove that $d(T)<|T|$ for every expression tree and consequently

$$
D_S(f,\varepsilon)\leq K(f)
$$

for every exactly expressible $f$, every set $S$, and every $\varepsilon\geq0$. For $0<\varepsilon\leq1$, this implies the explicit integer-valued estimate

$$
D_S(f,\varepsilon)\leq K(f)\left\lceil\frac1\varepsilon\right\rceil,
$$

hence $D_S(f,\varepsilon)=O(K(f)/\varepsilon)$. The direct bound by $K(f)$ is stronger: the inverse-error factor enters only through the elementary inequality $\lceil1/\varepsilon\rceil\geq1$. No regularity or compactness assumption on $S$ is needed, because the approximating witness computes $f$ exactly. We give constructive algorithms, numerical illustrations, scope limitations, and directions toward a genuine density theory with encoded constants and lower complexity bounds.

## 1. Introduction

Approximation theory usually balances expressiveness, accuracy, and complexity. A target function belongs to some analytic class; an approximating family is selected; and one estimates the resources needed to achieve error $\varepsilon$. Typical resources include polynomial degree, number of basis functions, network width, circuit size, or compositional depth. The present setting isolates a particularly clean relation between descriptive complexity and approximation depth.

Consider formulas generated from a single input variable by addition, multiplication, the exponential function, and the logarithm. These operations capture additive aggregation, multiplicative interaction, exponential growth, and logarithmic rescaling. More importantly for the present argument, each formula has a finite rooted-tree representation. It is therefore meaningful to compare total node count with nesting depth.

Our target class consists of functions having an exact finite expression in this language. This qualification is essential. The result is a universality theorem **within the finite-description class**, not a density theorem for all continuous functions. For an exactly describable function, a shortest exact expression already has zero error. The only nontrivial bridge to an approximation-depth estimate is then the structural fact that tree depth is strictly smaller than node count.

This observation yields two bounds. First, the minimum depth required at any nonnegative tolerance is at most the shortest exact-description size. Second, when $0<\varepsilon\leq1$, multiplying by $\lceil1/\varepsilon\rceil\geq1$ gives an explicit $O(K(f)/\varepsilon)$ estimate. The first statement is stronger and should govern interpretation of the second: precision does not actually force increasing depth for targets represented exactly.

The domain $S$ may be arbitrary. Standard uniform approximation results often assume compactness because limiting, interpolation, or density arguments require it. Here exact equality holds globally and survives restriction to every subset. This explains both the strength and the narrowness of the theorem.

## 2. The expression language

### Definition 2.1 (EML expressions)

An **exponential–multiplicative–logarithmic expression**, abbreviated EML expression, is generated recursively by the grammar

$$
T ::= x\mid (T+T)\mid(T\cdot T)\mid\exp(T)\mid\log(T).
$$

Thus $x$ is an expression; if $A$ and $B$ are expressions, then $A+B$ and $A\cdot B$ are expressions; and if $A$ is an expression, then $\exp(A)$ and $\log(A)$ are expressions.

Each expression is evaluated as a real-valued function according to the chosen total real interpretation of these operations. The argument below uses only compositional evaluation and exact equality, so it is independent of the particular convention used to totalize logarithm outside its classical positive domain. Applications concerned only with ordinary logarithms may restrict $S$ so every logarithmic subexpression receives positive input.

The language is constant-free: its only leaf is $x$. This matters when delimiting the target class. Results for a language with rational or real constants would require an explicit encoding and an associated cost model.

### Definition 2.2 (Size)

The **size** $|T|$ is the number of nodes in the expression tree. Recursively,

$$
|x|=1,
$$

$$
|A+B|=|A|+|B|+1,
\qquad
|A\cdot B|=|A|+|B|+1,
$$

and

$$
|\exp(A)|=|A|+1,
\qquad
|\log(A)|=|A|+1.
$$

### Definition 2.3 (Depth)

The **depth** $d(T)$ counts operational layers along the longest root-to-leaf path, with a variable leaf at depth zero:

$$
d(x)=0,
$$

$$
d(A+B)=1+\max\{d(A),d(B)\},
$$

$$
d(A\cdot B)=1+\max\{d(A),d(B)\},
$$

and

$$
d(\exp(A))=d(A)+1,
\qquad
d(\log(A))=d(A)+1.
$$

This convention separates total symbolic work from sequential nesting. Independent child branches can, in principle, be evaluated in parallel.

### Definition 2.4 (Exact expressibility and description complexity)

A function $f:\mathbb R\to\mathbb R$ is **exactly EML-expressible** if there exists a finite EML expression $T$ such that

$$
T(x)=f(x)\qquad\text{for every }x\in\mathbb R.
$$

For such a function, its **EML description complexity** is

$$
K(f)=\min\{|T|:T(x)=f(x)\text{ for every }x\in\mathbb R\}.
$$

The minimum exists because the admissible sizes form a nonempty subset of the natural numbers. This is a language-relative analogue of description complexity: changing the grammar or encoding changes $K(f)$.

## 3. Uniform approximation and minimum depth

### Definition 3.1 (Uniform approximation on a set)

Let $f:\mathbb R\to\mathbb R$, let $S\subseteq\mathbb R$, and let $\varepsilon\in\mathbb R$. An expression $T$ **uniformly approximates $f$ on $S$ with tolerance $\varepsilon$** if

$$
|f(x)-T(x)|\leq\varepsilon
\qquad\text{for every }x\in S.
$$

The error bound is non-strict. For $\varepsilon\geq0$, exact equality is always sufficient.

### Definition 3.2 (Minimum approximation depth)

The **minimum approximation depth** is

$$
D_S(f,\varepsilon)
=
\min\{d(T): |f(x)-T(x)|\leq\varepsilon\text{ for every }x\in S\},
$$

whenever the displayed set is nonempty. For definiteness, if no admissible expression exists, set $D_S(f,\varepsilon)=0$. All principal theorems explicitly construct an admissible expression, so this fallback convention has no mathematical effect on them.

### Lemma 3.3 (Witness bound)

If an expression $T$ uniformly approximates $f$ on $S$ with tolerance $\varepsilon$, then

$$
D_S(f,\varepsilon)\leq d(T).
$$

**Proof sketch.** The depth $d(T)$ belongs to the set over which the minimum is taken. A minimum of natural numbers is no greater than any member of its defining set. $\square$

## 4. Tree complexity

### Theorem 4.1 (Strict depth–size inequality)

For every EML expression $T$,

$$
d(T)<|T|.
$$

**Proof sketch.** Proceed by structural induction.

For the variable, $d(x)=0<1=|x|$.

Suppose the claim holds for $A$ and $B$. For a binary node $A+B$ or $A\cdot B$, assume without loss of generality that $d(A)\geq d(B)$. Then

$$
d(A\star B)=1+d(A)<1+|A|\leq1+|A|+|B|=|A\star B|,
$$

where $\star$ is either addition or multiplication. The same reasoning works if $B$ has the larger depth.

For a unary node, the induction hypothesis gives $d(A)<|A|$, hence

$$
d(\exp A)=d(A)+1<|A|+1=|\exp A|,
$$

and identically for $\log A$. These cases exhaust the grammar. $\square$

### Corollary 4.2

For every EML expression $T$,

$$
d(T)\leq |T|-1
$$

and therefore $d(T)\leq|T|$.

The strict theorem is the natural combinatorial statement, while the weaker final inequality is convenient when comparing depth with description complexity.

## 5. Main approximation results

### Theorem 5.1 (Exact-description approximation)

Let $f:\mathbb R\to\mathbb R$ be exactly EML-expressible. For every set $S\subseteq\mathbb R$ and every tolerance $\varepsilon\geq0$, there exists an EML expression $T$ satisfying

$$
|f(x)-T(x)|\leq\varepsilon
\qquad(x\in S)
$$

and

$$
d(T)\leq K(f).
$$

**Proof sketch.** Choose a shortest exact expression $T_*$ for $f$. By definition, $|T_*|=K(f)$ and $T_*(x)=f(x)$ for every real $x$. Hence

$$
|f(x)-T_*(x)|=0\leq\varepsilon
$$

for every $x\in S$. The strict depth–size inequality gives $d(T_*)<|T_*|=K(f)$, which in particular implies $d(T_*)\leq K(f)$. Thus $T_*$ is the required witness. $\square$

No property of $S$ was used. Nor was continuity or any other regularity of $f$ invoked beyond exact expressibility.

### Theorem 5.2 (Direct minimum-depth bound)

Under the hypotheses of Theorem 5.1,

$$
D_S(f,\varepsilon)\leq K(f)
$$

for every $\varepsilon\geq0$.

**Proof sketch.** Theorem 5.1 supplies an admissible $T$ with $d(T)\leq K(f)$. Apply the witness bound and transitivity:

$$
D_S(f,\varepsilon)\leq d(T)\leq K(f).
$$

$\square$

### Lemma 5.3 (Reciprocal ceiling)

If $0<\varepsilon\leq1$, then

$$
1\leq\left\lceil\frac1\varepsilon\right\rceil.
$$

**Proof sketch.** Positivity permits multiplication by $\varepsilon$ without reversing inequalities. From $\varepsilon\leq1$ one obtains $1\leq1/\varepsilon$. The ceiling is at least its argument and is a natural number, so the result follows. $\square$

### Theorem 5.4 (Quantitative reciprocal-tolerance bound)

Let $f$ be exactly EML-expressible, let $S\subseteq\mathbb R$, and suppose $0<\varepsilon\leq1$. Then

$$
D_S(f,\varepsilon)
\leq
K(f)\left\lceil\frac1\varepsilon\right\rceil.
$$

Consequently,

$$
D_S(f,\varepsilon)=O\left(\frac{K(f)}{\varepsilon}\right)
$$

with multiplicative constant one at the displayed integer-valued level.

**Proof sketch.** Theorem 5.2 gives $D_S(f,\varepsilon)\leq K(f)$. Lemma 5.3 and monotonicity of multiplication in the natural numbers give

$$
K(f)\leq K(f)\left\lceil\frac1\varepsilon\right\rceil.
$$

Combining the inequalities proves the result. $\square$

### Theorem 5.5 (Packaged universality and complexity statement)

Let $f$ be exactly EML-expressible, $S\subseteq\mathbb R$, and $0<\varepsilon\leq1$. Then both of the following hold:

1. there exists an EML expression $T$ such that
   $$
   |f(x)-T(x)|\leq\varepsilon\quad(x\in S)
   \qquad\text{and}\qquad
   d(T)\leq K(f);
   $$
2. the minimum approximation depth satisfies
   $$
   D_S(f,\varepsilon)
   \leq K(f)\left\lceil\frac1\varepsilon\right\rceil.
   $$

**Proof sketch.** The first assertion is Theorem 5.1, using $\varepsilon>0$. The second is Theorem 5.4. $\square$

## 6. Interpretation and limitations

Theorem 5.4 has the requested inverse-error form, but the mechanism deserves emphasis. It is not obtained by iteratively refining an approximation as $\varepsilon$ decreases. Instead, a shortest exact expression works for every tolerance simultaneously. The stronger estimate

$$
D_S(f,\varepsilon)\leq K(f)
$$

is uniform in $\varepsilon$. The reciprocal ceiling merely enlarges its right-hand side. Accordingly, the result should not be read as evidence that the true minimum depth grows like $1/\varepsilon$.

The word “universal” is relative to the exactly EML-expressible class. No claim is made that constant-free EML expressions approximate every continuous function. Indeed, such a density statement would need substantially different ingredients: encoded constants, separation properties, closure arguments, or a constructive approximation scheme.

The complexity $K(f)$ is also syntax-dependent. It counts tree nodes, not bits in a prefix-free encoding, and it does not identify shared subexpressions as a directed acyclic graph would. The present theorem remains valuable precisely because its cost model is explicit and its transfer from size to depth is exact.

Finally, if a concrete expression of size $m$ is known but its minimality is not, one may safely infer $K(f)\leq m$ and therefore

$$
D_S(f,\varepsilon)\leq m.
$$

One must not report $K(f)=m$ without proving that no smaller exact expression exists.

## 7. Constructive algorithms

### Algorithm 7.1 (Expression analysis)

Given an expression tree, compute its size, depth, and numerical value recursively. At a leaf return size $1$, depth $0$, and the input value. At a unary node analyze its child, increment both size and depth, and apply the operation. At a binary node analyze both children, add their sizes plus one, take the maximum depth plus one, and apply the operation.

If the tree has $n$ nodes, this traversal uses $O(n)$ time. Recursive storage is $O(d(T))$; an explicit stack gives the same asymptotic dependence on tree depth.

### Algorithm 7.2 (Uniform-error sampling)

For a target function and an expression, sample $N+1$ equally spaced points of an interval $[a,b]$ and return the largest observed absolute error. The cost is $O(Nc)$, where $c$ is the cost of one expression evaluation; with direct tree evaluation, $c=O(n)$. This is a numerical illustration, not a proof of a continuum supremum unless supplemented by analytic error control. For an exact expression, floating-point roundoff may still produce tiny nonzero discrepancies, so comparisons should use a numerical tolerance.

### Algorithm 7.3 (Complexity-bound calculator)

Given a certified description-size upper bound $m$ and $0<\varepsilon\leq1$, calculate

$$
B(m,\varepsilon)=m\left\lceil\frac1\varepsilon\right\rceil.
$$

The result certifies $D_S(f,\varepsilon)\leq B(m,\varepsilon)$ whenever an exact expression of size at most $m$ is known. Computing the ceiling and product is constant-time in a unit-cost arithmetic model and polynomial in the bit lengths under a bit-complexity model. The sharper concrete-tree depth should also be reported when available.

## 8. Numerical examples

Consider

$$
f(x)=\exp(x)+x^2.
$$

Represent it by the tree $\exp(x)+(x\cdot x)$. The exponential branch has size $2$ and depth $1$; the product branch has size $3$ and depth $1$; the root yields total size $6$ and depth $2$. Direct evaluation agrees with $f$ at every point. At $\varepsilon=0.2$,

$$
6\left\lceil\frac1{0.2}\right\rceil=30.
$$

Thus the generic bound from this six-node description is $30$, while the exhibited tree directly certifies depth at most $2$. The example makes visible how loose the reciprocal estimate can be.

For $T(x)=\exp(\log x)$, the tree has size $3$ and depth $2$. On a positive interval under the ordinary logarithm, $T(x)=x$ exactly. At tolerances $1$, $1/2$, and $1/10$, the reciprocal-ceiling bounds based on size $3$ are respectively $3$, $6$, and $30$, although the same depth-$2$ tree works throughout.

A shape comparison is also instructive. The expression $(x+x)(x+x)$ has seven nodes and depth $2$. A more deeply nested expression $\exp(\log(\exp(x)))$ has four nodes and depth $3$. Size and depth are correlated by Theorem 4.1 but are not interchangeable; balancing can reduce depth while retaining many nodes.

## 9. Applications

In symbolic modeling, a finite exact expression serves simultaneously as a model and as an approximation certificate on every region of interest. This is relevant when formulas built from growth, products, and logarithmic transformations arise naturally, as in compound growth, multiplicative response models, log-linear analysis, and certain rate equations.

In parallel computation, tree size approximates total arithmetic work while tree depth approximates idealized latency. The depth–size theorem converts a description budget into a conservative latency budget. A balanced expression can be substantially shallower than its size, so direct tree analysis often improves the general estimate.

In compression-oriented learning, $K(f)$ expresses an inductive preference for short symbolic explanations. Within the exact target class, shorter descriptions guarantee shallower approximation witnesses. This does not by itself solve model discovery or establish statistical generalization, but it provides a precise deterministic link between symbolic compression and evaluation depth.

## 10. Future work

A natural first extension adds rational constant leaves encoded by finite binary strings. One may then ask whether the resulting language is uniformly dense in $C([0,1],\mathbb R)$. This would turn class-relative exact universality into an approximation theorem for arbitrary continuous targets.

A second direction incorporates regularity. If $f$ has modulus of continuity $\omega$, one may seek estimates involving an inverse modulus, description complexity, and tolerance. Such bounds would explain the cost of resolving fine-scale variation when exact representation is unavailable.

Lower bounds are equally important. Finite packings of Lipschitz or piecewise-linear functions may yield incompressible targets for which every finite-alphabet expression below a prescribed error must have large size. Counting arguments could complement constructive upper bounds.

Finally, size and depth should be separated sharply. One seeks explicit function families with polynomial-size exact expressions but unavoidable linear approximation depth at exponentially small tolerance. Conversely, balanced or shared computations may expose cases where large descriptions admit small depth.

## 11. Further structural consequences

The preceding results have several immediate consequences that are useful when comparing domains, tolerances, and descriptions.

### Proposition 11.1 (Domain monotonicity)

If $S_1\subseteq S_2\subseteq\mathbb R$ and an admissible approximant exists on $S_2$, then

$$
D_{S_1}(f,\varepsilon)\leq D_{S_2}(f,\varepsilon).
$$

**Proof sketch.** Every expression satisfying the error bound at every point of $S_2$ also satisfies it at every point of the subset $S_1$. Thus the admissible family for $S_1$ contains the admissible family for $S_2$, and minimizing depth over the larger family cannot produce a larger value. $\square$

For exactly EML-expressible functions, this monotonicity coexists with the same global upper bound $K(f)$ for every domain. Restricting the domain may permit a shallower expression than any globally exact one, but restriction is never required to establish the theorem.

### Proposition 11.2 (Tolerance monotonicity)

If $0\leq\varepsilon_1\leq\varepsilon_2$ and an admissible approximant exists at tolerance $\varepsilon_1$, then

$$
D_S(f,\varepsilon_2)\leq D_S(f,\varepsilon_1).
$$

**Proof sketch.** Any expression with error at most $\varepsilon_1$ automatically has error at most the larger tolerance $\varepsilon_2$. The admissible set therefore expands as tolerance increases. $\square$

This proposition captures the usual accuracy–complexity tradeoff, while Theorem 5.2 shows that exactly expressible targets possess a common ceiling for the entire tradeoff curve. The curve may fall as error tolerance grows, but it never rises above $K(f)$ as tolerance shrinks to zero.

### Corollary 11.3 (Single-witness simultaneity)

If $f$ is exactly EML-expressible, there is one expression $T_*$ such that for every set $S\subseteq\mathbb R$ and every $\varepsilon\geq0$,

$$
|f(x)-T_*(x)|\leq\varepsilon\quad(x\in S)
$$

and $d(T_*)\leq K(f)$.

**Proof sketch.** Choose a shortest exact expression once. Its error is identically zero, independently of both parameters. $\square$

This is stronger than separately asserting existence for each pair $(S,\varepsilon)$: no domain-dependent or tolerance-dependent reconstruction is necessary.

## 12. Reproducibility and numerical caution

The numerical procedures associated with these results should distinguish symbolic certificates from sampled evidence. Computing tree size and depth is exact because both are integer-valued recursive quantities. Evaluating a reciprocal ceiling can also be exact when $\varepsilon$ is supplied as a rational number: for positive integers $p$ and $q$ with $\varepsilon=p/q$, one has

$$
\left\lceil\frac1\varepsilon\right\rceil
=
\left\lceil\frac qp\right\rceil
=
\left\lfloor\frac{q+p-1}{p}\right\rfloor.
$$

By contrast, a grid-based maximum error is only descriptive. A function can deviate between sampled points. If a Lipschitz bound $L$ is independently known for the error function and the grid spacing is $h$, then every point lies within $h/2$ of a sample on a uniform endpoint-inclusive grid, yielding the certified estimate

$$
\sup_{x\in[a,b]}|f(x)-T(x)|
\leq E_{\mathrm{grid}}+\frac{Lh}{2}.
$$

No such numerical certification is needed for a symbolically exact witness: equality of the expressions gives zero error directly. Floating-point demonstrations should therefore be presented as illustrations of evaluation behavior, not as the logical basis of the theorem.

The cost model also deserves explicit reporting. A tree duplicates repeated subexpressions. For example, $(x+x)(x+x)$ contains two copies of $x+x$, whereas a directed acyclic graph could evaluate that subexpression once and reuse it. The current size and depth definitions concern trees, so graph compression lies outside the theorem as stated. Any comparison with circuits or software implementations should preserve this distinction.

## 13. Conclusion

Finite EML expressions support a direct transfer from description complexity to approximation depth. The combinatorial core is the strict inequality $d(T)<|T|$. A shortest exact description of $f$ has zero error on every subset of the real line and depth at most $K(f)$. Therefore $D_S(f,\varepsilon)\leq K(f)$ for every nonnegative tolerance, and for $0<\varepsilon\leq1$,

$$
D_S(f,\varepsilon)
\leq K(f)\left\lceil\frac1\varepsilon\right\rceil.
$$

The inverse-error form is a valid quantitative summary, but exact representability supplies the stronger insight: within this finite-description class, increasing precision requires no additional depth. The open frontier is to determine how much of this relationship survives when exact descriptions are replaced by encoded approximation schemes for broader function classes. That question requires new analytic and information-theoretic ideas beyond the exact-description argument developed here.