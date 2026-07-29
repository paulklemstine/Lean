# Exact Descriptions, Approximation, and the Price of Precision

## A small mathematical language with an unexpectedly sharp guarantee

Approximation is one of mathematics’ central acts of translation. A complicated curve is replaced by a polynomial; a turbulent flow by a finite simulation; a noisy signal by a compact model. In each case, two questions travel together. Can the target be approximated? And how complicated must the approximating object be?

A particularly transparent setting begins with a tiny language of expressions. Start with a real input $x$. From expressions already built, allow four operations: addition, multiplication, exponentiation, and logarithm. Call this the **exponential–multiplicative–logarithmic language**, or EML language. An EML expression is therefore a finite tree. Leaves contain the variable $x$; binary internal nodes add or multiply; unary internal nodes apply $exp$ or $log$.

The phrase “finite tree” matters. It turns an analytic formula into a combinatorial object that can be measured. Two measurements will guide the story:

- the **size** $|T|$, the number of nodes in an expression tree $T$;
- the **depth** $d(T)$, the length of its longest chain of nested operations.

Size measures total descriptive material. Depth measures sequential nesting: how many dependent layers must be traversed along the longest route from the root to a leaf. A balanced tree may have many nodes but modest depth, while a deeply nested formula may force a long sequence of evaluations.

Now fix a real-valued target function $f$, a set $S\subseteq\mathbb R$, and an error tolerance $\varepsilon$. An expression $T$ **uniformly approximates** $f$ on $S$ within $\varepsilon$ when

$$
|f(x)-T(x)|\leq \varepsilon\qquad\text{for every }x\in S.
$$

The **minimum approximation depth**, written $D_S(f,\varepsilon)$, is the least depth among all EML expressions satisfying this inequality. If no such expression exists, one may adopt the bookkeeping convention $D_S(f,\varepsilon)=0$; the results below concern targets for which an approximant is explicitly available, so this convention never drives the conclusion.

The central quantity on the descriptive side is $K(f)$: the smallest node count of an EML expression that computes $f$ exactly at every real input. This number is defined only for functions possessing such a finite exact description. It resembles Kolmogorov complexity in spirit—short descriptions signal structure—but here the description language and cost model are fixed concretely.

## The combinatorial hinge

The first result is elementary and decisive.

**Depth–size theorem.** For every finite EML expression $T$,

$$
d(T)<|T|.
$$

Why is the inequality strict? A single variable has depth $0$ and size $1$. Adding a unary operation increases both quantities by one. Joining two expressions under addition or multiplication increases the larger child depth by one, while the new size contains both child sizes plus the new root. Following only the deepest branch can never encounter every node in the tree. Induction over the way expressions are assembled proves the claim.

This simple inequality connects two kinds of complexity that are often confused. Description length pays for every node. Depth pays only for the longest dependency chain. Consequently, any exact description of size $m$ automatically has depth at most $m-1$, and hence certainly at most $m$.

## Exactness makes approximation immediate

Suppose $f$ has a finite EML description, and choose a shortest one, $T_*$. Then $|T_*|=K(f)$ and $T_*(x)=f(x)$ for every real $x$. On any chosen set $S$,

$$
|f(x)-T_*(x)|=0.
$$

Therefore $T_*$ meets every nonnegative tolerance, no matter how small. Compactness, continuity, differentiability, and boundedness are irrelevant: the error vanishes pointwise before any analytic estimate is needed.

This yields the first main theorem.

**Exact-description approximation theorem.** If $f$ has a finite EML description, then for every set $S\subseteq\mathbb R$ and every $\varepsilon\geq0$, there exists an EML expression $T$ such that

$$
|f(x)-T(x)|\leq\varepsilon\quad(x\in S),
\qquad d(T)\leq K(f).
$$

The theorem uses “universal” in a precise, restricted sense: every target in the finite-description EML class is covered, on every domain and at every nonnegative tolerance. It does **not** assert that this constant-free language is dense in all continuous functions. Enlarging the target class would require an independent density theorem, perhaps after adding encoded rational constants.

The same witness controls the minimum:

**Minimum-depth bound.** Under the same hypotheses,

$$
D_S(f,\varepsilon)\leq K(f)
$$

for every $\varepsilon\geq0$.

This is stronger than a tolerance-dependent estimate. As precision increases, one does not need to deepen the expression at all: the exact shortest description remains available.

## Why an inverse-error bound still appears

Complexity estimates are often stated in terms of $1/\varepsilon$. For $0<\varepsilon\leq1$, the reciprocal obeys $1/\varepsilon\geq1$, and therefore its natural-number ceiling satisfies

$$
\left\lceil\frac1\varepsilon\right\rceil\geq1.
$$

Multiplying the direct estimate by this factor gives the quantitative headline:

**Reciprocal-tolerance depth theorem.** If $f$ has a finite EML description, $S\subseteq\mathbb R$, and $0<\varepsilon\leq1$, then

$$
D_S(f,\varepsilon)
\leq K(f)\left\lceil\frac1\varepsilon\right\rceil.
$$

Thus the depth is $O(K(f)/\varepsilon)$, with coefficient one after taking the integer ceiling.

There is an important interpretive nuance. The proof does not reveal a deterioration proportional to $1/\varepsilon$. Quite the opposite: it first establishes the sharper, tolerance-independent inequality $D_S(f,\varepsilon)\leq K(f)$. The displayed reciprocal bound follows because $\lceil1/\varepsilon\rceil$ is at least one. The $O(K(f)/\varepsilon)$ statement is correct and useful for comparison with familiar approximation rates, but it is deliberately loose for exactly describable targets.

Combining existence and complexity gives a compact summary: for every finitely EML-described function and every $0<\varepsilon\leq1$, there is a single expression whose error on any set $S$ is at most $\varepsilon$ and whose depth is at most $K(f)$; moreover the least possible approximation depth is at most $K(f)\lceil1/\varepsilon\rceil$.

## A numerical picture

Consider

$$
f(x)=\exp(x)+x^2.
$$

One expression tree has a root addition node. Its left branch applies exponentiation to $x$; its right branch multiplies $x$ by itself. Counting nodes gives size $6$. With leaves at depth $0$, both branches have depth $1$ and the full tree has depth $2$. Because this expression computes $f$ exactly, its sampled maximum error is $0$ on $[-1,1]$, or on any other domain.

At tolerance $\varepsilon=0.2$, the reciprocal ceiling is $5$. The general estimate using this known six-node description is

$$
D_{[-1,1]}(f,0.2)\leq 6\cdot5=30,
$$

while the concrete tree immediately gives the much sharper bound $D_{[-1,1]}(f,0.2)\leq2$. If the six-node tree is not known to be shortest, then $6$ is merely an upper bound for $K(f)$; that distinction is essential in honest complexity accounting.

Other examples reveal the same pattern. The expression $\exp(\log x)$ has size $3$ and depth $2$; wherever the adopted real logarithm and exponential compose to the identity, it exactly represents $x$. A balanced product such as $(x+x)(x+x)$ has more nodes than its depth suggests. Tree shape, not only operation count, determines sequential complexity.

## Connections beyond symbolic formulas

The depth–size distinction echoes computer circuits. Circuit size measures total hardware; depth measures latency under ideal parallel evaluation. An expression with two independent branches can evaluate them simultaneously and combine the results afterward. The theorem $d(T)<|T|$ says that a finite symbolic description always supplies a sequential-depth budget smaller than its total construction budget.

The result also clarifies the role of compression. A short exact description is not merely a concise way to write a function. It is a certificate of low approximation depth at every precision. In this restricted language, descriptive economy transfers directly to computational economy.

There are possible scientific applications whenever exponential growth, multiplicative interaction, and logarithmic scaling coexist: compound growth models, chemical rate laws, multiplicative noise, information measures, and log-linear transformations. The theorem does not claim that every model in these fields belongs to the EML class. It says that once a model does have such an exact finite expression, its approximation guarantee is immediate and domain-independent.

## The frontier

The sharpest questions begin where exact representability ends. Add rational constants encoded by finite binary strings, and ask whether the resulting expressions are dense among continuous functions on $[0,1]$. Relate approximation depth not only to description length but also to a modulus of continuity. Seek lower bounds showing that some Lipschitz functions resist every short finite-alphabet expression. Separate size from depth by finding functions with compact trees that nonetheless require deep approximants at fine precision.

These directions would transform a clean exact-description theorem into a broader approximation theory. The current result supplies the baseline. It identifies the mechanism with unusual clarity: a shortest exact expression has zero error; its longest branch is shorter than its total node count; and every conventional inverse-error estimate follows from that stronger fact.

There is also a methodological lesson about bounds. A mathematically valid asymptotic estimate may conceal a much better invariant. Here, the advertised factor $1/\varepsilon$ is not the engine of the argument. The real engine is exact representation, which freezes the required depth as $\varepsilon$ tends to zero. Reporting both statements—the familiar asymptotic form and the stronger direct estimate—prevents a correct theorem from creating the wrong intuition.

Finally, the arbitrary choice of $S$ is more than cosmetic. Many approximation theorems need compact intervals so that continuity can turn pointwise control into uniform control. Here the same expression agrees with the target before restriction to $S$. One may choose a compact interval, a disconnected set, a finite experimental grid, or all of $\mathbb R$; the zero-error witness is unchanged. The domain is a lens through which the result is viewed, not an ingredient used to obtain it.

The lesson is simple but durable. Precision is expensive only when the language cannot already say exactly what the target is. When it can, approximation becomes a shadow of description, and the cost of accuracy is paid once—in the structure of the formula itself.