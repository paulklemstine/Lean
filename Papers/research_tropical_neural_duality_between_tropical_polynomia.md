# Exact Tropical-Rational Representation of Finite Feedforward ReLU Networks

**Aristotle**  
**29 July 2026**

## Abstract

We establish an exact, constructive correspondence from finite scalar-valued feedforward rectified linear unit networks to tropical rational functions. A generalized max-plus tropical polynomial on $\mathbb R^n$ is generated from affine forms by ordinary addition, pointwise maximum, and multiplication by nonnegative scalars. A tropical rational expression is represented in subtractive normal form as a pair $(P,Q)$ with value $P-Q$. We give closed operations on such pairs for addition, constants, arbitrary signed scalar multiplication, finite summation, and the ReLU map. The decisive identity is

$$
\max\{P-Q,0\}=\max\{P,Q\}-Q.
$$

It follows by structural induction that every finite feedforward scalar ReLU network $N$ admits generalized tropical polynomials $P_N,Q_N$ satisfying $N(x)=P_N(x)-Q_N(x)$ for all $x\in\mathbb R^n$. The construction is an exact syntax-directed compilation algorithm. Negative weights are handled by exchanging numerator and denominator, and a ReLU gate leaves the compiled denominator unchanged. We analyze correctness, computational cost, examples, geometric interpretation, applications, limitations, and directions toward canonical normalization, region bounds, and exact rational computation.

## 1. Introduction

Feedforward neural networks with rectified linear unit activation are among the most widely used families of piecewise-linear models. Their basic nonlinearity is

$$
\operatorname{ReLU}(t)=\max\{t,0\}.
$$

The same maximum operation is fundamental to max-plus tropical mathematics. Tropical polynomials describe convex piecewise-affine functions, while differences of tropical polynomials describe a broader family of piecewise-affine functions. This parallel suggests a precise question: can an arbitrary finite ReLU computation, including arbitrary positive and negative weights, be expressed exactly in tropical language?

The answer is affirmative for scalar-valued feedforward networks. The result proved here is semantic and pointwise: it identifies functions on all of $\mathbb R^n$, not merely values on a finite data set and not an approximation within a prescribed tolerance. It is also constructive. Starting from the network, one recursively produces two generalized tropical polynomials whose difference is the network function.

The main subtlety is signed scalar multiplication. The class of tropical polynomials used here is closed under multiplication by nonnegative scalars, but neural weights may be negative. The subtractive representation resolves this asymmetry: if $R=P-Q$ and $c<0$, then

$$
cR=(-c)Q-(-c)P.
$$

Thus a negative scalar exchanges the two components and scales by a nonnegative number. The ReLU operation is handled by an equally elementary but powerful identity:

$$
\operatorname{ReLU}(P-Q)=\max\{P,Q\}-Q.
$$

Together, these rules make the class of tropical rational expressions closed under every operation used by a finite feedforward ReLU circuit.

The paper is organized as follows. Section 2 defines generalized tropical polynomials, subtractive tropical rational expressions, and the network model. Section 3 develops the algebra of pairs and proves the local semantic identities. Section 4 gives the compiler and proves the representation theorem. Section 5 describes algorithms and complexity. Section 6 gives numerical examples. Sections 7 and 8 discuss geometry and applications, while Sections 9 and 10 address scope and future research.

## 2. Mathematical setting

### 2.1 Affine forms and generalized tropical polynomials

Fix $n\in\mathbb N$. Inputs are vectors $x=(x_1,\ldots,x_n)\in\mathbb R^n$. An **affine form** is a function

$$
A_{a,b}(x)=\sum_{i=1}^{n}a_i x_i+b,
$$

where $a=(a_1,\ldots,a_n)\in\mathbb R^n$ and $b\in\mathbb R$.

**Definition 2.1 (Generalized max-plus tropical polynomial).** The class $\mathcal T_n$ of generalized tropical polynomials on $\mathbb R^n$ is the smallest class of real-valued functions satisfying the following rules:

1. every affine form belongs to $\mathcal T_n$;
2. if $P,Q\in\mathcal T_n$, then the ordinary sum $P+Q$ belongs to $\mathcal T_n$;
3. if $P,Q\in\mathcal T_n$, then the pointwise maximum $\max\{P,Q\}$ belongs to $\mathcal T_n$;
4. if $P\in\mathcal T_n$ and $c\ge 0$, then $cP\in\mathcal T_n$.

The zero function is the affine form with zero weights and zero bias. A constant $b$ is the affine form with zero weights and bias $b$. Evaluation is recursive: affine leaves are evaluated by dot product plus bias, and internal operations are interpreted as ordinary addition, pointwise maximum, or nonnegative scaling.

This generalized expression grammar is compatible with the max-plus viewpoint. Ordinary addition acts as tropical multiplication, and maximum acts as tropical addition. Retaining both operations explicitly is convenient for a syntax-directed translation.

**Lemma 2.2 (Piecewise-affine convexity).** Every generalized tropical polynomial is convex and piecewise affine.

**Proof sketch.** Affine functions are convex and piecewise affine. Ordinary sums and nonnegative scalar multiples preserve convexity and piecewise affinity. The pointwise maximum of two convex functions is convex, and the maximum of two piecewise-affine functions is piecewise affine after refining their polyhedral decompositions along the locus where they are equal. Structural induction completes the argument. $\square$

### 2.2 Tropical rational expressions

**Definition 2.3 (Subtractive tropical rational expression).** A tropical rational expression on $\mathbb R^n$ is an ordered pair $(P,Q)\in\mathcal T_n\times\mathcal T_n$. Its evaluation is

$$
\llbracket(P,Q)\rrbracket(x)=P(x)-Q(x).
$$

The terminology reflects max-plus arithmetic: tropical division corresponds to ordinary subtraction. The pair is an expression rather than a unique normal form. For example, $(P,Q)$ and $(P+H,Q+H)$ have the same evaluation whenever all three components lie in $\mathcal T_n$. No uniqueness or minimality is assumed.

A tropical polynomial $P$ embeds as $(P,0)$, because $P-0=P$.

### 2.3 Finite feedforward scalar ReLU circuits

**Definition 2.4 (Network syntax).** A finite scalar feedforward ReLU circuit on $\mathbb R^n$ is built recursively from:

1. **Affine nodes:** an affine node with weights $a\in\mathbb R^n$ and bias $b\in\mathbb R$ computes $a\cdot x+b$.
2. **Finite linear-combination nodes:** given previously built subnetworks $N_1,\ldots,N_m$, weights $w_1,\ldots,w_m\in\mathbb R$, and bias $b\in\mathbb R$, the node computes

   $$
   \sum_{j=1}^{m}w_jN_j(x)+b.
   $$

3. **ReLU nodes:** given a subnetwork $N$, the node computes

   $$
   \operatorname{ReLU}(N(x))=\max\{N(x),0\}.
   $$

This recursive syntax directly describes finite expression trees. A finite feedforward directed acyclic graph with shared nodes can be unfolded into such a tree without changing its computed function. The scalar-output assumption is only notational: a vector-valued network can be treated coordinate by coordinate.

## 3. Algebra of subtractive pairs

We next define operations on pairs and establish their exact meanings.

### 3.1 Addition, constants, and finite sums

For $R=(P,Q)$ and $S=(U,V)$, define

$$
R\oplus S=(P+U,Q+V).
$$

**Lemma 3.1 (Pair addition).** For every $x\in\mathbb R^n$,

$$
\llbracket R\oplus S\rrbracket(x)=\llbracket R\rrbracket(x)+\llbracket S\rrbracket(x).
$$

**Proof.** Direct expansion gives

$$
(P+U)-(Q+V)=(P-Q)+(U-V).
$$

$\square$

To add a constant $b$, embed it as $(b,0)$ and apply pair addition. Therefore

$$
(P,Q)\oplus(b,0)=(P+b,Q).
$$

**Lemma 3.2 (Constant addition).** The pair $(P+b,Q)$ evaluates to $P-Q+b$ at every input.

**Proof.** This is the preceding addition identity with the embedded constant pair. $\square$

For a finite list $R_1,\ldots,R_m$, define its pair sum recursively, using $(0,0)$ for the empty list and pair addition for each new term.

**Lemma 3.3 (Finite-sum semantics).** For every finite list of tropical rational expressions and every $x$,

$$
\left\llbracket\bigoplus_{j=1}^{m}R_j\right\rrbracket(x)
=\sum_{j=1}^{m}\llbracket R_j\rrbracket(x).
$$

For the empty list, both sides equal zero.

**Proof sketch.** Induct on the length of the list. The empty case follows from the zero pair. The inductive step is Lemma 3.1 followed by the induction hypothesis. $\square$

### 3.2 Arbitrary signed scalar multiplication

For $c\in\mathbb R$ and $R=(P,Q)$, define signed scalar multiplication by

$$
c\odot(P,Q)=
\begin{cases}
(cP,cQ),&c\ge 0,\\
((-c)Q,(-c)P),&c<0.
\end{cases}
$$

Both branches contain only nonnegative scaling inside the tropical polynomials.

**Lemma 3.4 (Signed-scaling semantics).** For every real $c$, every pair $R$, and every input $x$,

$$
\llbracket c\odot R\rrbracket(x)=c\,\llbracket R\rrbracket(x).
$$

**Proof.** If $c\ge 0$, then

$$
\llbracket(cP,cQ)\rrbracket=cP-cQ=c(P-Q).
$$

If $c<0$, then $-c>0$ and

$$
\llbracket((-c)Q,(-c)P)\rrbracket
=(-c)Q-(-c)P=cP-cQ=c(P-Q).
$$

$\square$

The exchange in the second case is the mechanism that permits arbitrary neural weights while preserving the nonnegative-scaling grammar of tropical polynomials.

### 3.3 ReLU closure

For a pair $R=(P,Q)$, define its ReLU transform by

$$
\rho(P,Q)=(\max\{P,Q\},Q).
$$

**Lemma 3.5 (ReLU identity).** For every $P,Q\in\mathcal T_n$ and $x\in\mathbb R^n$,

$$
\max\{P(x)-Q(x),0\}=\max\{P(x),Q(x)\}-Q(x).
$$

Consequently,

$$
\llbracket\rho(P,Q)\rrbracket(x)
=\operatorname{ReLU}(\llbracket(P,Q)\rrbracket(x)).
$$

**Proof.** If $P(x)\le Q(x)$, the left side is zero and the right side is $Q(x)-Q(x)=0$. If $Q(x)\le P(x)$, the left side is $P(x)-Q(x)$ and the right side has the same value. The two cases cover equality as well. $\square$

**Corollary 3.6 (Denominator preservation under ReLU).** Under the constructive ReLU transform, the denominator polynomial is exactly the previous denominator: the pair $(P,Q)$ becomes $(\max\{P,Q\},Q)$.

This is an expression-level equality, not merely an equality of evaluations. A ReLU gate adds a maximum to the numerator and does not alter the denominator.

## 4. Exact compilation and representation

### 4.1 The recursive compiler

**Algorithmic Definition 4.1 (Tropical compiler).** Associate a pair $C(N)=(P_N,Q_N)$ to each network $N$ recursively:

1. If $N(x)=a\cdot x+b$ is affine, set

   $$
   C(N)=(a\cdot x+b,0).
   $$

2. If

   $$
   N(x)=\sum_{j=1}^{m}w_jN_j(x)+b,
   $$

   first compile every $N_j$, then set

   $$
   C(N)=\left(\bigoplus_{j=1}^{m} w_j\odot C(N_j)\right)\oplus(b,0).
   $$

3. If $N=\operatorname{ReLU}\circ M$ and $C(M)=(P_M,Q_M)$, set

   $$
   C(N)=(\max\{P_M,Q_M\},Q_M).
   $$

Every emitted component belongs to $\mathcal T_n$. The affine case uses tropical polynomial leaves. Addition and constants use ordinary sums. Signed scaling uses only nonnegative factors after a possible swap. The ReLU rule uses maximum.

### 4.2 Local and global correctness

**Theorem 4.2 (Compiler correctness).** For every finite scalar feedforward ReLU network $N$ on $\mathbb R^n$, if $C(N)=(P_N,Q_N)$, then for every $x\in\mathbb R^n$,

$$
P_N(x)-Q_N(x)=N(x).
$$

**Proof sketch.** Proceed by structural induction on the construction of $N$.

For an affine node, $C(N)=(N,0)$, so the claim is immediate.

For a finite linear-combination node, assume inductively that

$$
\llbracket C(N_j)\rrbracket(x)=N_j(x)
$$

for every child $N_j$. By Lemma 3.4, the compiled scaled pair $w_j\odot C(N_j)$ evaluates to $w_jN_j(x)$, regardless of the sign of $w_j$. Lemma 3.3 shows that the pair sum evaluates to the sum of these weighted child values, and Lemma 3.2 adds the bias. The result is exactly the semantics of the linear-combination node.

For a ReLU node, the induction hypothesis identifies the input pair with the input subnetwork. Lemma 3.5 then identifies the transformed pair with the ReLU of that value. Thus the compiled pair agrees with the node in all three cases. $\square$

**Theorem 4.3 (Tropical–Neural Representation Theorem).** Every finite scalar-valued feedforward ReLU network $N$ on $\mathbb R^n$ is a tropical rational function. Explicitly, there exist generalized max-plus tropical polynomials $P$ and $Q$ such that

$$
N(x)=P(x)-Q(x)
$$

for all $x\in\mathbb R^n$.

**Proof.** Apply the compiler and write $C(N)=(P,Q)$. Theorem 4.2 yields $P(x)-Q(x)=N(x)$ at every input. $\square$

**Corollary 4.4 (Piecewise-affine output).** Every finite scalar ReLU network computes a piecewise-affine function that is a difference of two convex piecewise-affine functions.

**Proof sketch.** By Lemma 2.2, the compiled $P$ and $Q$ are convex and piecewise affine. Their difference is piecewise affine on a common refinement of their polyhedral decompositions. The representation theorem identifies that difference with the network. $\square$

## 5. Algorithms and computational considerations

### 5.1 Syntax-tree compilation

The direct compiler traverses the network expression tree in postorder. At an affine node it creates one affine leaf and a zero denominator. At a linear-combination node it compiles all children, applies signed scaling to each pair, adds the pairs, and adds the bias. At a ReLU node it creates one maximum node in the numerator and reuses the denominator.

Let $S$ be the number of nodes in the unfolded expression tree and let $E$ be the total number of child occurrences in all linear-combination nodes. If tropical expressions are stored as directed acyclic expression graphs with structural sharing, the compiler creates $O(S+E)$ expression nodes and performs $O(S+E)$ local construction steps. Evaluation of the raw compiled graph at one input is likewise linear in its graph size.

If the original neural architecture is a directed acyclic graph and one first unfolds all shared subcomputations into a tree, the tree can be exponentially larger than the graph. This is not a failure of the algebraic translation; it is a consequence of discarding sharing. A practical implementation should memoize compilation by network node and retain a directed acyclic representation of tropical expressions.

### 5.2 Pair evaluation

Given $(P,Q)$ and $x$, evaluate $P$ and $Q$ recursively and return $P(x)-Q(x)$. With memoization, each expression-graph node is evaluated once. Affine leaves require $O(n)$ arithmetic operations; addition, maximum, and scaling nodes require constant work after their children are known.

### 5.3 Numerical identity checking

For exposition and debugging, one may evaluate both the original network and its compiled pair on a finite grid and report the maximum absolute discrepancy. Such a test illustrates the theorem but does not replace its all-input proof. In floating-point arithmetic, the observed discrepancy should be near machine precision because both computations use the same elementary operations, though different parenthesization can produce small rounding differences.

### 5.4 Expression growth and normalization

The recursive pair is exact but generally not canonical. If tropical expressions are expanded into maxima of affine forms, distributive transformations may cause rapid term growth. Some affine terms can be dominated everywhere and never attain the maximum; removing them preserves evaluation. Common additions to numerator and denominator may also obscure a simpler representation.

No minimality claim is part of the representation theorem. The raw compiler answers an existence and correctness question. Canonical cancellation, dominance testing, and tight term bounds require additional theory and algorithms.

## 6. Worked examples

### 6.1 One ReLU

Let

$$
N(x)=\operatorname{ReLU}(2x-3).
$$

The affine input compiles to $(2x-3,0)$. Applying the ReLU rule gives

$$
C(N)=(\max\{2x-3,0\},0).
$$

Thus $N$ is itself a tropical polynomial in this case.

### 6.2 A negative output weight

Consider

$$
N(x)=-3\operatorname{ReLU}(-x-2).
$$

The hidden ReLU compiles to $(\max\{-x-2,0\},0)$. Multiplication by $-3$ swaps the pair and scales by $3$:

$$
C(N)=\left(0,3\max\{-x-2,0\}\right).
$$

Evaluation gives

$$
0-3\max\{-x-2,0\}=N(x).
$$

This elementary example isolates the role of pair exchange.

### 6.3 A two-unit scalar network

Let

$$
N(x)=2\operatorname{ReLU}(x-1)-3\operatorname{ReLU}(-x-2)+\frac12.
$$

A compiled pair is

$$
P(x)=2\max\{x-1,0\}+\frac12,
$$

$$
Q(x)=3\max\{-x-2,0\}.
$$

Hence $N=P-Q$. Its explicit piecewise form is

$$
N(x)=
\begin{cases}
3x+\frac{13}{2},&x<-2,\\
\frac12,&-2\le x\le 1,\\
2x-\frac32,&x>1.
\end{cases}
$$

At $x=-2$ and $x=1$, the adjacent formulas agree, so the function is continuous. The breakpoints are exactly the switching locations of the two hidden ReLUs.

### 6.4 A nested ReLU

Consider

$$
M(x)=\operatorname{ReLU}\bigl(1-2\operatorname{ReLU}(x)\bigr).
$$

First, $\operatorname{ReLU}(x)$ compiles to $(\max\{x,0\},0)$. Scaling by $-2$ yields $(0,2\max\{x,0\})$, and adding $1$ gives

$$
(P,Q)=\left(1,2\max\{x,0\}\right).
$$

The outer ReLU changes this to

$$
C(M)=\left(\max\left\{1,2\max\{x,0\}\right\},2\max\{x,0\}\right).
$$

Subtracting the denominator gives

$$
\max\left\{1-2\max\{x,0\},0\right\},
$$

which is exactly $M(x)$. Notice again that the outer ReLU preserves the denominator.

## 7. Geometric interpretation

Each generalized tropical polynomial is a convex polyhedral landscape. Its affine pieces are active on regions determined by comparisons among affine expressions. Boundaries occur where competing pieces tie. For a pair $(P,Q)$, the output $P-Q$ is affine wherever both $P$ and $Q$ have fixed active affine descriptions. Consequently, a common refinement of the polyhedral decompositions of $P$ and $Q$ provides a linearity decomposition for the network.

This perspective separates two kinds of structure. The numerator records convex contributions generated through maxima and positive scaling; the denominator records a second convex landscape whose subtraction permits nonconvex behavior. Negative weights transfer contributions between these two landscapes. ReLU modifies only the numerator of the current pair, but later negative combinations may exchange components.

The representation does not assert that every cell in a common refinement is a distinct maximal linearity region of the output. Adjacent cells can carry the same resulting affine function and merge. Degenerate parameter choices can also cause ties on unexpectedly large sets. A precise equality between network regions and a refinement of normal complexes requires genericity hypotheses and a separate proof.

## 8. Applications

### 8.1 Exact symbolic analysis

The compiler supplies a symbolic certificate of the function computed by a network. Local transformations preserve evaluation exactly, enabling algebraic inspection without relying on sampling. This can support equivalence analysis, simplification, or extraction of explicit piecewise-affine descriptions for small and medium networks.

### 8.2 Polyhedral region analysis

Because maxima of affine functions induce polyhedral subdivisions, the compiled pair connects activation patterns to tropical and convex geometry. Candidate linearity regions can be obtained by refining the regions on which $P$ and $Q$ select fixed affine pieces. This creates a bridge from neural architecture to normal fans, polyhedral complexes, and dominance relations.

### 8.3 Robustness and optimization

On any region where both compiled polynomials are affine, the network is affine. Local optimization and sensitivity calculations therefore reduce to linear problems once the active region is known. Globally, bounds on $P-Q$ over a polytope may be approached through the two convex components, although obtaining sharp bounds can remain computationally difficult.

### 8.4 Exact arithmetic

When all weights, biases, and inputs are rational, every operation used by the compiler—addition, comparison, nonnegative multiplication, and subtraction—has an exact rational interpretation. This suggests implementations that avoid floating-point roundoff during compilation and evaluation. A complete rational extraction theorem, including compatibility with real evaluation, is a natural extension.

### 8.5 Vector-valued outputs

A network with $k$ outputs can be represented by $k$ tropical rational pairs, one for each coordinate. Shared intermediate expressions can remain shared in an implementation. Thus the scalar theorem is the essential component of a coordinatewise vector extension.

## 9. Scope and limitations

The theorem applies to finite feedforward circuits using affine combinations and ReLU gates. It does not directly cover smooth activations such as sigmoid or hyperbolic tangent, nor recurrent systems with unbounded temporal evolution. Other piecewise-linear activations may admit related identities, but each requires explicit closure rules.

The generalized tropical polynomial grammar allows affine forms with arbitrary real slopes at the leaves and nonnegative scaling at internal nodes. This is sufficient for the exact correspondence developed here. Alternative conventions for tropical polynomials may package the same functions differently and may require a normalization theorem to compare representations.

The construction proves existence and gives an algorithm, but it does not prove that the output pair is smallest, unique, or computationally optimal. Equivalent networks can yield very different pairs. Shared subgraphs, algebraic cancellation, and globally dominated terms all affect representation size. Moreover, enumerating all affine regions can be much more expensive than storing and evaluating the expression graph.

Finally, numerical demos can only sample inputs. Their role is explanatory. The mathematical correctness statement quantifies over every input and follows from the recursive identities of Sections 3 and 4.

## 10. Future work

Five directions sharpen the correspondence.

First, an **integer-slope criterion** should characterize arithmetic closure. If all affine and linear-combination weights are integers, both compiled polynomials should be representable using integer-slope affine monomials. Conversely, one seeks a construction of a finite integer-weight ReLU network for every scalar tropical rational function with integer slopes.

Second, a **depth-sensitive term bound** should relate layer widths $w_1,\ldots,w_L$ to the number of affine terms after normalization. A candidate upper bound is

$$
\prod_{\ell=1}^{L}(w_\ell+1),
$$

for each of the numerator and denominator, together with lower-bound families requiring exponentially many terms in the depth $L$.

Third, **canonical cancellation** would turn the compiler output into a more intrinsic object. The desired procedure should terminate, remove every affine term dominated on all of $\mathbb R^n$, preserve evaluation, and yield uniqueness up to permutation under suitable full-dimensionality assumptions.

Fourth, a **region-complexity correspondence** should compare full-dimensional neural linearity regions with the common refinement of the normal complexes of the compiled numerator and denominator. Generic parameters are expected to give exact correspondence, while nongeneric choices should merge rather than create regions relative to that refinement.

Fifth, **rational parameter extraction** should provide a computable rational compiler whenever all weights and biases are rational, prove exact evaluation over $\mathbb Q$, and show that coercion to real numbers agrees extensionally with the original real-valued network.

## 11. Conclusion

Every finite scalar feedforward ReLU network can be translated exactly into the difference of two generalized max-plus tropical polynomials. The translation rests on two elementary rules with broad consequences: a negative scalar exchanges the two components of a subtractive pair, and

$$
\max\{P-Q,0\}=\max\{P,Q\}-Q.
$$

A structural recursion over the network then yields an exact pair $(P_N,Q_N)$, and structural induction proves equality at every input. ReLU gates preserve the compiled denominator at the moment they are introduced, finite affine combinations remain closed, and arbitrary signed weights are fully accommodated.

The result provides a direct bridge between layered piecewise-linear computation and tropical convex geometry. It offers a foundation for symbolic compilation, polyhedral analysis, exact arithmetic, normalization, and complexity studies. Most importantly, it identifies the relationship as an equality of functions rather than a metaphor or approximation: the neural and tropical-rational descriptions are two exact languages for the same finite computation.
