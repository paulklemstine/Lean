# Differential Closure of Rational Exponential–Logarithmic Expressions

**Aristotle**  
**25 July 2026**

## Abstract

We study a concrete univariate expression class generated from real constants and the identity by addition, multiplication, reciprocal, exponential, and logarithm. We call its members rational exponential–logarithmic expressions. A recursive semantics assigns a total real-valued function to each expression, while a separate regularity predicate records the points at which the standard reciprocal and logarithmic differentiation rules are valid. We define syntactic substitution and symbolic differentiation and prove two fundamental identities. First, substitution realizes functional composition. Second, at every regular point, evaluation of the symbolic derivative equals the ordinary derivative of the evaluated expression. It follows that represented functions are closed under constants, identity, addition, multiplication, negation, subtraction, pointwise reciprocal, division, composition, exponential, and logarithm, and that globally regular presentations have represented derivatives. Under pointwise operations the represented total functions form a subring; they should not literally be called a field, because a ring of total functions can have zero divisors. We also state the derivative formula for a differentiable inverse branch, emphasizing that analytic invertibility alone does not imply representability in this expression language. Finally, we establish positive integration results for the exponential and for every expression lying in the image of symbolic differentiation, while making no universal antiderivative-closure claim. The framework isolates the exact algebraic, differential, inverse, and integration properties justified by the grammar.

## 1. Introduction

Expressions assembled from rational operations, exponentials, and logarithms occur throughout applied mathematics. Growth laws use exponentials; entropy and likelihood use logarithms; optimization repeatedly composes these functions with affine and rational transformations. A useful symbolic class should remain stable under the operations by which models are assembled and analyzed.

The phrase “differential field” is often used informally for a class closed under field operations and differentiation. For total real-valued functions, however, this phrase requires care. Pointwise function rings have zero divisors, and reciprocal is total only after a convention at zero. Moreover, logarithms and reciprocals may be assigned total values without being differentiable at their singular points. We therefore separate three issues:

1. **Representability:** whether a function is denoted by an expression in the grammar.
2. **Regularity:** whether all local differentiation rules used by an expression are valid at a point.
3. **Algebraic setting:** whether one studies total functions, domain-restricted functions, or germs.

This separation yields precise closure theorems without overstating them. The proofs are constructive. Algebraic closure is obtained by adjoining an operation to expression trees. Composition is implemented by substitution. Differentiation is a recursive tree transformation whose semantic correctness follows by structural induction.

The main conclusions are as follows. Represented functions are closed under all constructors, derived field operations, and composition. A globally regular represented function has a represented derivative. Represented total functions form a subring. A represented inverse branch remains represented by assumption and satisfies the usual reciprocal derivative formula when the appropriate inverse identity and differentiability hypotheses hold. The exponential has a represented antiderivative, and every symbolic derivative can be integrated back to its source expression under global regularity. No claim is made that every expression in the class has an antiderivative in the class.

## 2. Expression language and semantics

### 2.1 Syntax

**Definition 2.1 (Rational exponential–logarithmic expressions).** The class $\mathcal E$ is the least class satisfying:

1. for every $c\in\mathbb R$, the constant expression $c$ belongs to $\mathcal E$;
2. the variable expression $X$ belongs to $\mathcal E$;
3. if $P,Q\in\mathcal E$, then $P+Q$, $PQ$, $P^{-1}$, $\exp(P)$, and $\log(P)$ belong to $\mathcal E$.

The word “rational” refers to closure under the field-forming operations, not to rational coefficients: arbitrary real constants are allowed. Negation, subtraction, and division are abbreviations:

$$
-P=(-1)P,\qquad P-Q=P+(-Q),\qquad P/Q=P Q^{-1}.
$$

### 2.2 Total evaluation

**Definition 2.2 (Evaluation).** For $P\in\mathcal E$, its evaluation $\llbracket P\rrbracket:\mathbb R\to\mathbb R$ is recursively defined by

$$
\begin{aligned}
\llbracket c\rrbracket(x)&=c, & \llbracket X\rrbracket(x)&=x,\\
\llbracket P+Q\rrbracket(x)&=\llbracket P\rrbracket(x)+\llbracket Q\rrbracket(x),
&\llbracket PQ\rrbracket(x)&=\llbracket P\rrbracket(x)\llbracket Q\rrbracket(x),\\
\llbracket P^{-1}\rrbracket(x)&=\llbracket P\rrbracket(x)^{-1},
&\llbracket\exp(P)\rrbracket(x)&=\exp(\llbracket P\rrbracket(x)),\\
\llbracket\log(P)\rrbracket(x)&=\log(\llbracket P\rrbracket(x)).
\end{aligned}
$$

Reciprocal and logarithm are interpreted using total real conventions. The results below depend only on the standard identities away from singularities, which are tracked separately.

**Definition 2.3 (Represented function).** A function $f:\mathbb R\to\mathbb R$ is **EML-representable** if there is an expression $P\in\mathcal E$ such that $f=\llbracket P\rrbracket$ pointwise.

This is an extensional notion: different expressions may represent the same function.

### 2.3 Regularity

**Definition 2.4 (Regularity at a point).** The proposition $\operatorname{Reg}(P,x)$ is defined recursively. Constants and $X$ are regular at every point. The expressions $P+Q$ and $PQ$ are regular at $x$ precisely when both $P$ and $Q$ are regular at $x$. The expression $P^{-1}$ is regular at $x$ when $P$ is regular at $x$ and $\llbracket P\rrbracket(x)\ne0$. The expression $\exp(P)$ is regular at $x$ when $P$ is regular there. Finally, $\log(P)$ is regular at $x$ when $P$ is regular there and $\llbracket P\rrbracket(x)\ne0$.

This definition is tailored to the total logarithm convention used in evaluation and to the available derivative rule away from zero. In a domain-sensitive treatment of the conventional real logarithm, one would instead require $\llbracket P\rrbracket(x)>0$ and explicitly track a neighborhood on which the expression is defined.

An expression is **globally regular** if $\operatorname{Reg}(P,x)$ holds for every $x\in\mathbb R$.

## 3. Substitution and composition

**Definition 3.1 (Substitution).** For $P,Q\in\mathcal E$, the substitution $P[Q/X]$ is obtained by replacing every variable leaf $X$ in $P$ by $Q$. Constants remain unchanged, and substitution distributes recursively through every constructor:

$$
(P_1+P_2)[Q/X]=P_1[Q/X]+P_2[Q/X],
$$

with analogous clauses for products, reciprocal, exponential, and logarithm.

**Lemma 3.2 (Substitution identity).** For all expressions $P,Q\in\mathcal E$ and every $x\in\mathbb R$,

$$
\llbracket P[Q/X]\rrbracket(x)
=\llbracket P\rrbracket\bigl(\llbracket Q\rrbracket(x)\bigr).
$$

**Proof sketch.** Proceed by structural induction on $P$. If $P$ is a constant, both sides equal that constant; if $P=X$, both sides equal $\llbracket Q\rrbracket(x)$. For a composite constructor, apply the induction hypotheses to its immediate subexpressions and then unfold evaluation. For instance, the product case is

$$
\begin{aligned}
\llbracket(P_1P_2)[Q/X]\rrbracket(x)
&=\llbracket P_1[Q/X]\rrbracket(x)\llbracket P_2[Q/X]\rrbracket(x)\\
&=\llbracket P_1\rrbracket(\llbracket Q\rrbracket(x))
  \llbracket P_2\rrbracket(\llbracket Q\rrbracket(x))\\
&=\llbracket P_1P_2\rrbracket(\llbracket Q\rrbracket(x)).
\end{aligned}
$$

The other constructors are immediate. $\square$

**Theorem 3.3 (Composition closure).** If $f$ and $g$ are EML-representable, then $f\circ g$ is EML-representable.

**Proof sketch.** Choose expressions $P$ and $Q$ representing $f$ and $g$. By Lemma 3.2, $P[Q/X]$ evaluates to $f(g(x))$ at every $x$. $\square$

## 4. Algebraic closure

**Theorem 4.1 (Primitive closure).** Constant functions and the identity function are EML-representable. If $f$ and $g$ are EML-representable, then the functions

$$
f+g,\qquad fg,\qquad f^{-1},\qquad x\mapsto e^{f(x)},\qquad x\mapsto\log(f(x))
$$

are EML-representable.

**Proof sketch.** A constant is represented by its constant expression and the identity by $X$. Given representatives $P$ and $Q$, the expressions $P+Q$, $PQ$, $P^{-1}$, $\exp(P)$, and $\log(P)$ represent the displayed functions by the definition of evaluation. $\square$

**Corollary 4.2 (Derived field-operation closure).** If $f$ and $g$ are EML-representable, then so are $-f$, $f-g$, and $f/g$.

**Proof sketch.** Represent $-f$ as $(-1)f$, subtraction as addition of a negation, and division as multiplication by a reciprocal. $\square$

**Theorem 4.3 (Subring theorem).** The set of EML-representable functions is a subring of the pointwise ring $\mathbb R^{\mathbb R}$.

**Proof sketch.** The zero and unit functions are represented by the constants $0$ and $1$. Theorem 4.1 gives closure under addition and multiplication, while Corollary 4.2 gives additive inverses. The inherited pointwise operations obey the ring laws. $\square$

**Remark 4.4 (Why this is not literally a field of total functions).** Reciprocal syntax does not turn the pointwise function ring into a field. The ambient ring $\mathbb R^{\mathbb R}$ has zero divisors: for example, two nonzero functions supported on disjoint subsets have zero product. Also, totalized inversion assigns a value at zeros rather than producing a genuine multiplicative inverse there. A literal differential-field statement should instead be formulated for suitable germs at a regular point or for functions carrying explicit domains, where nonzero elements can be inverted locally under appropriate hypotheses.

## 5. Symbolic differentiation

### 5.1 Definition

**Definition 5.1 (Symbolic derivative).** Define $D:\mathcal E\to\mathcal E$ recursively by

$$
D(c)=0,\qquad D(X)=1,
$$

$$
D(P+Q)=D(P)+D(Q),
$$

$$
D(PQ)=D(P)Q+P D(Q),
$$

$$
D(P^{-1})=-D(P)(P^2)^{-1},
$$

$$
D(\exp(P))=D(P)\exp(P),
$$

$$
D(\log(P))=D(P)P^{-1}.
$$

The definition is closed syntactically: $D(P)$ is an expression in $\mathcal E$ whenever $P$ is.

### 5.2 Semantic correctness

**Theorem 5.2 (Pointwise correctness of symbolic differentiation).** Let $P\in\mathcal E$ and $x\in\mathbb R$. If $\operatorname{Reg}(P,x)$, then $\llbracket P\rrbracket$ is differentiable at $x$ and

$$
\frac{d}{dx}\llbracket P\rrbracket(x)=\llbracket D(P)\rrbracket(x).
$$

More precisely, $\llbracket P\rrbracket$ has derivative $\llbracket D(P)\rrbracket(x)$ at $x$.

**Proof sketch.** Use structural induction on $P$. Constants and the identity use the elementary derivative rules. For sums and products, regularity supplies the induction hypotheses for both children, and the sum and product rules give exactly the evaluation of the corresponding symbolic expression.

For $P=R^{-1}$, regularity gives both differentiability of $\llbracket R\rrbracket$ and nonvanishing $\llbracket R\rrbracket(x)\ne0$. The reciprocal rule yields

$$
(\llbracket R\rrbracket^{-1})'(x)
=-\llbracket D(R)\rrbracket(x)\,\llbracket R\rrbracket(x)^{-2},
$$

which is the evaluation of $D(R^{-1})$.

For $P=\exp(R)$, combine the induction hypothesis with the chain rule:

$$
(\exp\circ\llbracket R\rrbracket)'(x)
=\llbracket D(R)\rrbracket(x)e^{\llbracket R\rrbracket(x)}.
$$

For $P=\log(R)$, regularity provides the required nonvanishing condition, and the logarithmic chain rule gives

$$
(\log\circ\llbracket R\rrbracket)'(x)
=\llbracket D(R)\rrbracket(x)\llbracket R\rrbracket(x)^{-1}.
$$

Each result agrees with the recursive definition of $D$. $\square$

**Corollary 5.3 (Differential closure under global regularity).** If $f=\llbracket P\rrbracket$ and $P$ is globally regular, then the ordinary derivative $f'$ is EML-representable, with representative $D(P)$.

**Proof sketch.** Apply Theorem 5.2 at every real $x$. Pointwise equality identifies $f'$ with $\llbracket D(P)\rrbracket$. $\square$

**Theorem 5.4 (Combined closure package).** Let $f=\llbracket P\rrbracket$ for a globally regular expression $P$, and let $g$ be EML-representable. Then $f+g$, $fg$, $f\circ g$, and $f'$ are all EML-representable.

**Proof sketch.** Apply Theorems 4.1 and 3.3 to the first three functions and Corollary 5.3 to the fourth. $\square$

### 5.3 Example

Let

$$
P(X)=e^{X^2}\log(1+X^2).
$$

Because $1+x^2>0$ for every real $x$, no reciprocal or logarithmic singularity is encountered, so $P$ is globally regular. The recursive rules produce

$$
D(P)(X)=2Xe^{X^2}\log(1+X^2)
+e^{X^2}\frac{2X}{1+X^2}.
$$

Corollary 5.3 proves that this expression represents the derivative globally.

## 6. Inverse branches

Representability and analytic invertibility are distinct properties. The following result records the exact conclusion available once a represented inverse branch is given.

**Theorem 6.1 (Represented two-sided inverse branch).** Suppose $f,g:\mathbb R\to\mathbb R$ are EML-representable and satisfy

$$
g(f(x))=x\quad\text{and}\quad f(g(x))=x
$$

for every $x$ in the relevant setting. Then $g$ is an EML-representable two-sided inverse of $f$.

**Proof sketch.** Representability of $g$ is one of the hypotheses; the two displayed identities establish that it is genuinely an inverse rather than an unrelated represented function. $\square$

The theorem is intentionally bookkeeping rather than a representability criterion. An analytic inverse function theorem can produce a local inverse from a nonzero derivative, but it does not by itself show that the inverse belongs to a prescribed symbolic language.

**Theorem 6.2 (Derivative of an inverse branch).** Let $f,g:\mathbb R\to\mathbb R$ satisfy $f(g(y))=y$. Fix $x\in\mathbb R$. Assume $f$ is differentiable at $g(x)$ and $g$ is differentiable at $x$. Then

$$
g'(x)=\bigl(f'(g(x))\bigr)^{-1}.
$$

**Proof sketch.** The chain rule applied to $f\circ g$ gives

$$
(f\circ g)'(x)=f'(g(x))g'(x).
$$

The right-inverse identity says $f\circ g$ is the identity, whose derivative is $1$. Hence

$$
f'(g(x))g'(x)=1,
$$

and solving for $g'(x)$ yields the reciprocal formula. The equation itself ensures the necessary nonzero factor. $\square$

**Remark 6.3 (Orientation).** The identity needed at the input $x$ of $g$ is $f(g(x))=x$. The opposite identity $g(f(x))=x$ alone concerns differentiation at a differently parameterized point and is insufficient for this formula on a totalized domain.

**Remark 6.4 (Scope of inverse closure).** If a local inverse branch is separately known to have an EML expression, Theorems 5.2 and 6.2 describe its derivative inside the same language under regularity. A stronger theorem deriving EML representability of an inverse solely from properties of $f$ would require additional syntactic or differential-algebraic hypotheses.

## 7. Integration results and limitations

Differentiation maps expressions to expressions. Integration asks whether a given expression lies in the image of that map, which is a different problem.

**Theorem 7.1 (Exponential antiderivative).** The function $x\mapsto e^x$ has an EML-representable antiderivative, namely itself:

$$
\frac{d}{dx}e^x=e^x.
$$

**Proof sketch.** The identity expression is representable; applying the exponential constructor represents $e^x$. The standard exponential derivative rule proves the displayed equality at every real $x$. $\square$

**Theorem 7.2 (Antiderivatives of symbolic derivatives).** Let $P\in\mathcal E$ be globally regular. Then the function

$$
x\longmapsto\llbracket D(P)\rrbracket(x)
$$

has the EML-representable antiderivative $F=\llbracket P\rrbracket$. Equivalently,

$$
F'(x)=\llbracket D(P)\rrbracket(x)
$$

for every $x\in\mathbb R$.

**Proof sketch.** The function $F$ is represented by $P$. Theorem 5.2, applied at every point using global regularity, identifies its derivative with the evaluation of $D(P)$. $\square$

**Discussion 7.3 (No universal integration closure).** Theorem 7.2 characterizes a guaranteed positive family: expressions already known to have arisen by symbolic differentiation can be integrated back to their sources. It does not prove that every member of $\mathcal E$ lies in the image of $D$ up to semantic equality. A negative theorem would require a rigorous criterion for non-elementary integrability, such as an appropriate form of Liouville theory, and an explicit expression satisfying its obstruction. Therefore the justified conclusion is neither universal closure nor universal failure: integration closure is established for a concrete image class and selected examples, while the general question remains outside the present results.

## 8. Algorithms

### 8.1 Expression evaluation

An expression can be evaluated by a postorder traversal of its tree. At a constant or variable leaf, return the corresponding value. At an internal node, recursively evaluate its children and apply the node operation. If $n$ is the number of tree nodes and arithmetic and transcendental operations are treated as unit-cost, evaluation takes $O(n)$ time and $O(h)$ stack space, where $h$ is tree height.

### 8.2 Symbolic differentiation

The derivative algorithm recursively applies Definition 5.1. Every input node is visited once, but product, reciprocal, exponential, and logarithm rules may copy subexpressions. With immutable directed acyclic graphs and shared references, construction is linear in the graph size before simplification. With naive trees, repeated differentiation can cause substantial expression swell. Semantics-preserving normalization—removing factors of $1$, summands of $0$, and repeated subtrees—is therefore important in practical systems.

### 8.3 Substitution

To form $P[Q/X]$, traverse $P$ and replace each variable leaf with $Q$. Shared representation permits all replacements to reference one copy of $Q$, giving $O(|P|)$ construction time. Naive deep copying costs $O(|P|+k|Q|)$, where $k$ is the number of variable occurrences in $P$.

### 8.4 Regularity checking at a numerical point

A recursive evaluator can return both the value of a subexpression and a Boolean regularity flag. Addition and multiplication combine flags conjunctively. Reciprocal and logarithm additionally test whether the child value is nonzero. This mirrors Definition 2.4 and runs in $O(n)$ time. In floating-point computation, exact zero tests should be replaced by explicit tolerances and reported as numerical diagnostics rather than mathematical proofs of nonvanishing.

## 9. Applications

### 9.1 Optimization and differentiable modeling

Losses involving soft exponential and logarithmic transformations can be assembled compositionally. The closure theorem ensures that a globally regular loss has a derivative in the same expression language. This supports inspectable gradient generation: singular denominators and logarithmic arguments remain explicit rather than hidden in an opaque numerical routine.

### 9.2 Growth, decay, and sensitivity

Models such as

$$
y(x)=\frac{e^{ax}}{1+be^{ax}}
$$

are EML expressions whenever $a,b\in\mathbb R$. On regions where the denominator is nonzero, their derivatives are EML expressions. Parameterized growth rates, elasticities, and local sensitivities can therefore be represented in the same vocabulary as the original model.

### 9.3 Probability and information

Log-likelihoods frequently combine sums, products, exponentials, and logarithms. Regularity exposes the exact nonvanishing assumptions required by logarithmic differentiation. Composition closure supports nested transformations, while derivative closure provides symbolic score functions wherever the presentation is regular.

### 9.4 Reusable computation graphs

The grammar may be viewed as a computation graph. Substitution corresponds to graph composition and symbolic differentiation to graph transformation. The semantic theorems guarantee that these graph operations agree with function composition and ordinary differentiation, respectively. This gives a mathematical basis for modular symbolic pipelines.

## 10. Discussion

The expression grammar yields a strong closure package, but its interpretation must remain precise. The algebraic constructors make representability closure unconditional because they are syntactic. Differential closure is conditional because total evaluation and differentiability are different concepts. The recursively defined regularity predicate contains exactly the local nonvanishing information consumed by the proof.

The total-function perspective is convenient for extensional equality and pointwise operations, but it blurs domains. A domain-aware theory would attach an open set to each expression and interpret reciprocal and logarithm only where valid. An alternative is to pass to germs at a regular point. Germs identify functions agreeing on some neighborhood, naturally localize inverse questions, and provide a better home for the phrase “differential field.”

Inverse functions reveal a second boundary. The derivative formula is analytic and follows from composition with the identity. Membership in a symbolic class is algebraic or syntactic and does not follow merely from local existence. Keeping these conclusions separate prevents the inverse function theorem from being asked to prove more than it states.

Integration reveals a third boundary. Symbolic differentiation is a forward structural recursion. Antidifferentiation is an inverse-search problem modulo semantic equality. The positive image theorem is exact and useful, but a complete integration theory would need normalization, equivalence reasoning, and non-integrability certificates.

## 11. Future work

A first extension should replace totalized operations by open domains or germs. This would make local nonvanishing and inversion intrinsic and would support a literal differential-field formulation. A second objective is an exact substitution-regularity theorem relating regularity of $P[Q/X]$ at $x$ to regularity of $Q$ at $x$ and of $P$ at $\llbracket Q\rrbracket(x)$.

Iterated differentiation is another natural development. Defining $D^0(P)=P$ and $D^{n+1}(P)=D(D^n(P))$ should yield representations of higher derivatives whenever the required intermediate regularity conditions hold. For computation, simplification and normalization procedures should be proved semantics-preserving to control expression growth and aid equality testing.

The most substantive analytic extension is a genuine inverse-representability criterion: identify hypotheses under which a locally defined inverse branch remains EML-representable. Finally, an integration-obstruction theorem should isolate a concrete EML expression with no EML antiderivative using a suitable differential-algebraic form of Liouville’s theorem.

## 12. Conclusion

Rational exponential–logarithmic expressions form a stable symbolic universe under constants, identity, algebraic operations, exponential, logarithm, and composition. Their represented total functions constitute a subring. A recursive symbolic derivative stays in the grammar and agrees with ordinary differentiation at every regular point, yielding global differential closure for globally regular presentations. Represented inverse branches satisfy the standard reciprocal derivative formula, but analytic inversion alone does not guarantee symbolic representability. Integration is positively resolved for exponential and for the image of symbolic differentiation, without an unjustified universal closure claim.

The resulting theory is both constructive and bounded. It supplies direct algorithms for composition and differentiation, while clearly identifying the roles of singularities, domains, inverse representability, and integration obstructions. Those boundaries are not defects; they are the information needed to turn an informal “closed under calculus” slogan into an exact mathematical statement.
