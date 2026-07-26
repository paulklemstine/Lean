# Transcendence and Multiplication Elimination in Rational Exponential–Logarithmic Expression Classes

**Aristotle**  
**July 26, 2026**

## Abstract

We study two classes of real numbers generated from rational constants by finite expression trees. The rational EML language permits a distinguished real variable, exponentiation, logarithms, addition, and multiplication; the rational EL sublanguage omits multiplication. Closed values are obtained by setting the distinguished variable equal to $0$. We prove unconditionally that every EL number is an EML number and that $\exp(\exp(1))+\log 2$ is represented by a rational EML expression. We then isolate a functional strengthening of Schanuel’s conjecture consisting of three explicit assumptions: classical real Schanuel, algebraic independence over $\mathbb Q$ of $\exp(\exp(1))$ and $\log 2$, and extensional elimination of multiplication from every rational EML expression. A general substitution theorem shows that the sum of two algebraically independent real numbers is transcendental. It follows conditionally that $\exp(\exp(1))+\log 2$ is transcendental. The elimination assumption yields the reverse inclusion of represented number classes and hence the conditional equality $\mathrm{EML}=\mathrm{EL}$. We emphasize the logical separation between classical Schanuel and the two additional functional predictions, give algorithms for expression evaluation and bounded polynomial-relation searches, and identify finite-arity and linear-combination generalizations.

## 1. Introduction

Expressions formed from rational constants, exponentials, logarithms, sums, and products provide a natural laboratory for transcendence theory. They are easy to evaluate numerically and difficult to classify arithmetically. The constant

$$
\alpha=\exp(\exp(1))+\log 2
$$

illustrates the gap. Its decimal expansion can be computed rapidly, yet no such computation can determine whether $\alpha$ is algebraic over $\mathbb Q$. The nested exponential combines with a logarithm in a way that lies beyond presently available unconditional methods.

A second issue is expressive rather than arithmetic. If a language already contains exponentiation, logarithms, and addition, does an explicit multiplication constructor enlarge the class of represented numbers? The familiar identity $ab=\exp(\log a+\log b)$ suggests a negative answer for positive inputs, but it does not provide a uniform real-valued elimination procedure for arbitrary nested expressions. Zeros, signs, and the behavior of logarithms prevent that slogan from being a complete argument.

This paper treats both questions through a precise expression grammar and an explicit conjectural package. The package contains classical real Schanuel’s conjecture, but it also separately states the concrete algebraic-independence prediction and the functional multiplication-elimination prediction actually used. Thus no implication from classical Schanuel to either additional clause is presumed.

The main results are as follows.

1. The EL class is unconditionally contained in the EML class.
2. The constant $\alpha$ is unconditionally an EML number.
3. If $x$ and $y$ are algebraically independent over $\mathbb Q$, then $x+y$ is transcendental over $\mathbb Q$.
4. Under algebraic independence of $\exp(\exp(1))$ and $\log 2$, the constant $\alpha$ is transcendental.
5. Under extensional multiplication elimination, every EML number is an EL number; combined with the first result, the classes coincide.

The contribution is chiefly structural. The transcendence proof reduces the concrete claim to one transparent independence assumption. The class-equality proof separates the automatic syntactic inclusion from the difficult semantic elimination direction.

## 2. Algebraic preliminaries

### 2.1 Algebraic and transcendental elements

Let $K\subseteq L$ be fields. An element $u\in L$ is **algebraic over $K$** if there is a nonzero polynomial $p(T)\in K[T]$ such that $p(u)=0$. It is **transcendental over $K$** if no such polynomial exists. In this paper the base field is $K=\mathbb Q$ and the ambient field is $L=\mathbb R$.

A finite family $u_1,\ldots,u_n\in L$ is **algebraically independent over $K$** if, for every polynomial $P\in K[X_1,\ldots,X_n]$,

$$
P(u_1,\ldots,u_n)=0
$$

implies $P=0$. Otherwise the family is algebraically dependent. Algebraic independence is stronger than requiring each element to be transcendental. For example, if $u$ is transcendental, then $u$ and $1-u$ are separately transcendental, but they satisfy the polynomial relation $X+Y-1=0$.

The **transcendence degree** of a field extension $L/K$ is the cardinality of a transcendence basis: a maximal algebraically independent subset of $L$ over $K$. It measures how many algebraically independent parameters are required to generate the extension up to algebraic closure.

### 2.2 Classical real Schanuel conjecture

We use the following standard formulation.

**Conjecture 2.1 (Classical real Schanuel).** Let $n\ge 0$, and let $z_1,\ldots,z_n\in\mathbb R$ be linearly independent over $\mathbb Q$. Then

$$
\operatorname{trdeg}_{\mathbb Q}
\mathbb Q\bigl(z_1,\ldots,z_n,e^{z_1},\ldots,e^{z_n}\bigr)\ge n.
$$

The conjecture predicts that rational linear independence of exponential inputs forces substantial algebraic independence among the inputs and their exponential images. Our conditional statements retain this classical clause, but the proofs below need two additional predictions that are stated independently in Section 4.

## 3. Rational EML and EL languages

### 3.1 Expression grammars

Fix a distinguished real variable $t$. A **rational EML expression** is built inductively by the following rules:

1. every rational constant $q\in\mathbb Q$ is an expression;
2. the variable $t$ is an expression;
3. if $E$ is an expression, then $\exp(E)$ and $\log(E)$ are expressions;
4. if $E$ and $F$ are expressions, then $E+F$ and $EF$ are expressions.

The evaluation map assigns a real-valued function $\llbracket E\rrbracket:\mathbb R\to\mathbb R$ to each expression by interpreting the constructors as the corresponding real operations. Thus

$$
\llbracket q\rrbracket(x)=q,\qquad
\llbracket t\rrbracket(x)=x,
$$

$$
\llbracket \exp(E)\rrbracket(x)=\exp(\llbracket E\rrbracket(x)),
$$

$$
\llbracket \log(E)\rrbracket(x)=\log(\llbracket E\rrbracket(x)),
$$

and addition and multiplication are evaluated pointwise. Here $\log$ denotes the standard real logarithm in the chosen total real-function convention; all class results depend only on using the same evaluation convention in both languages.

A real number $a$ is a **rational EML number** if there exists a rational EML expression $E$ such that

$$
\llbracket E\rrbracket(0)=a.
$$

The class of all such numbers is denoted $\mathrm{EML}$.

A **rational EL expression** is generated by the same rules except that the product rule is omitted. In other words, rational constants, $t$, exponentials, logarithms, and sums are allowed, but explicit multiplication nodes are forbidden. A real number $a$ is a **rational EL number** if

$$
\llbracket F\rrbracket(0)=a
$$

for some rational EL expression $F$. The class is denoted $\mathrm{EL}$.

These are syntactic definitions followed by semantic evaluation. An expression is EL or EML according to the shape of its construction tree, not according to whether its function could later be represented in another way.

### 3.2 The automatic inclusion

**Proposition 3.1 (Language inclusion).** Every rational EL expression is a rational EML expression.

**Proof sketch.** Proceed by structural induction on the EL expression. Rational constants and the variable are admitted by both grammars. The exponential, logarithm, and addition constructors are also shared. Applying the induction hypothesis to each immediate subexpression therefore reconstructs the same tree in the EML grammar. There is no multiplication case because EL expressions contain no multiplication node. $\square$

**Corollary 3.2 (Unconditional class inclusion).**

$$
\mathrm{EL}\subseteq\mathrm{EML}.
$$

**Proof sketch.** If $a\in\mathrm{EL}$, choose an EL expression $F$ with $\llbracket F\rrbracket(0)=a$. Proposition 3.1 regards the same expression as EML, with unchanged evaluation. Hence $a\in\mathrm{EML}$. $\square$

### 3.3 The concrete expression

Define

$$
E_\alpha(t)=\exp(\exp(1))+\log 2.
$$

Its expression tree has an addition at the root, nested exponentials of the rational constant $1$ on the left, and the logarithm of the rational constant $2$ on the right. It does not depend on $t$.

**Proposition 3.3 (Representation of the concrete constant).** The expression $E_\alpha$ is a rational EML expression and

$$
\llbracket E_\alpha\rrbracket(0)=\exp(\exp(1))+\log 2.
$$

Consequently, $\alpha\in\mathrm{EML}$.

**Proof sketch.** The constants $1$ and $2$ are rational. Closure under two applications of exponentiation, one application of logarithm, and addition constructs $E_\alpha$. Evaluation unfolds each constructor and produces the displayed equality. $\square$

In fact, this particular tree contains no multiplication node, so it also fits the EL grammar. The unconditional result recorded here only requires its EML membership; the later class theorem concerns arbitrary expressions where multiplication may occur.

## 4. The functional EML strengthening

We now state the complete hypothesis supporting the conditional results.

**Hypothesis 4.1 (Functional EML strengthening of Schanuel).** Assume all three clauses below.

1. **Classical clause.** Classical real Schanuel’s conjecture, as stated in Conjecture 2.1, holds.
2. **Concrete independence clause.** The two real numbers
   $$
   \exp(\exp(1))\quad\text{and}\quad\log 2
   $$
   are algebraically independent over $\mathbb Q$.
3. **Multiplication-elimination clause.** For every rational EML expression $E$, there exists a rational EL expression $F$ such that
   $$
   \llbracket F\rrbracket(x)=\llbracket E\rrbracket(x)
   $$
   for every $x\in\mathbb R$.

The clauses are deliberately separate. Neither the concrete independence clause nor the multiplication-elimination clause is asserted here to have been derived from classical Schanuel. The first conditional theorem below uses Clause 2. The class-equality theorem uses Clause 3. Clause 1 situates the package within the intended transcendence-theoretic program but is not, by itself, invoked in either short deduction.

The elimination clause is extensional: it preserves a function on all real inputs, not merely its value at $0$. It is therefore stronger than the class equality $\mathrm{EML}=\mathrm{EL}$, which concerns only closed values. This strength makes the deduction of number-class equality immediate while leaving open whether equality of closed values could hold under weaker assumptions.

## 5. Algebraic independence and transcendental sums

The main algebraic mechanism is independent of exponential functions.

**Theorem 5.1 (Transcendence of the sum of an independent pair).** Let $x,y\in\mathbb R$. If $x$ and $y$ are algebraically independent over $\mathbb Q$, then $x+y$ is transcendental over $\mathbb Q$.

**Proof.** Suppose instead that $x+y$ is algebraic. Then there exists a nonzero polynomial $p(T)\in\mathbb Q[T]$ such that

$$
p(x+y)=0.
$$

Form the bivariate polynomial

$$
Q(X,Y)=p(X+Y)\in\mathbb Q[X,Y].
$$

Evaluation gives $Q(x,y)=p(x+y)=0$. Algebraic independence of $x$ and $y$ therefore forces $Q=0$.

It remains to show this is impossible. Consider the specialization homomorphism that sets $Y=0$. Applied to $Q$, it yields

$$
Q(X,0)=p(X).
$$

If $Q$ were the zero polynomial, then $p(X)$ would be zero, contrary to the choice of $p$. Hence no nonzero rational polynomial vanishes at $x+y$, and $x+y$ is transcendental. $\square$

The proof may be expressed as injectivity of the substitution map

$$
\mathbb Q[T]\longrightarrow\mathbb Q[X,Y],\qquad p(T)\longmapsto p(X+Y).
$$

A left inverse is specialization at $Y=0$ and $X=T$. This retraction viewpoint is useful for generalization.

**Remark 5.2.** Separate transcendence of $x$ and $y$ would not suffice. The theorem fundamentally uses the absence of every bivariate polynomial relation. In particular, it rules out cancellation engineered by a relation such as $X+Y-c=0$.

**Corollary 5.3 (Conditional transcendence of the concrete EML number).** Under Hypothesis 4.1,

$$
\exp(\exp(1))+\log 2
$$

is transcendental over $\mathbb Q$.

**Proof sketch.** Clause 2 of Hypothesis 4.1 states that $x=\exp(\exp(1))$ and $y=\log 2$ are algebraically independent. Apply Theorem 5.1. $\square$

This corollary is explicitly conditional. The claim is not established here from currently known unconditional transcendence theorems, and the classical clause alone is not claimed to imply the required pair independence.

## 6. Elimination of multiplication and equality of classes

**Theorem 6.1 (Difficult inclusion under elimination).** Under Clause 3 of Hypothesis 4.1,

$$
\mathrm{EML}\subseteq\mathrm{EL}.
$$

**Proof.** Let $a\in\mathrm{EML}$. By definition, there is a rational EML expression $E$ satisfying

$$
\llbracket E\rrbracket(0)=a.
$$

The multiplication-elimination clause supplies a rational EL expression $F$ such that $\llbracket F\rrbracket(x)=\llbracket E\rrbracket(x)$ for every real $x$. Evaluating at $x=0$ gives

$$
\llbracket F\rrbracket(0)=\llbracket E\rrbracket(0)=a.
$$

Thus $a\in\mathrm{EL}$. $\square$

**Theorem 6.2 (Conditional EML/EL equality).** Under Hypothesis 4.1,

$$
\mathrm{EML}=\mathrm{EL}.
$$

**Proof.** The inclusion $\mathrm{EML}\subseteq\mathrm{EL}$ is Theorem 6.1. The reverse inclusion $\mathrm{EL}\subseteq\mathrm{EML}$ is the unconditional Corollary 3.2. Equality follows by antisymmetry of set inclusion. $\square$

The theorem says that adding multiplication to the syntax produces no additional closed real values under the elimination hypothesis. The hypothesis itself says more: each EML expression can be translated to an EL expression preserving its full input-output behavior.

## 7. Algorithms and numerical demonstrations

Algorithms cannot establish the conjectural clauses, but they clarify the objects and provide reproducible experiments.

### 7.1 Recursive expression evaluation

Represent an expression as a rooted tree whose nodes are rational constants, the variable, unary exponential or logarithm nodes, and binary addition or multiplication nodes. Evaluation at $x$ is recursive:

1. return the rational value at a constant node;
2. return $x$ at the variable node;
3. recursively evaluate the child and apply $\exp$ or $\log$ at a unary node;
4. recursively evaluate both children and add or multiply at a binary node.

If the tree has $N$ nodes, evaluation visits every node once and uses $O(N)$ arithmetic/function operations. Recursive stack space is $O(h)$, where $h$ is tree height. For the featured constant, the traversal computes $e$, then $e^e$, then $\log 2$, and finally the sum.

Using ordinary floating-point arithmetic gives approximately

$$
e^e\approx 15.154262241479264,
$$

$$
\log 2\approx 0.6931471805599453,
$$

and

$$
\alpha\approx 15.84740942203921.
$$

These approximations demonstrate evaluation only; they do not certify transcendence.

### 7.2 Bounded univariate relation search

Given a real approximation $a$, a degree bound $d$, and a coefficient bound $B$, enumerate integer vectors

$$
(c_0,\ldots,c_d)\in\{-B,\ldots,B\}^{d+1}\setminus\{0\}
$$

and compute the residual

$$
\left|\sum_{k=0}^{d}c_k a^k\right|.
$$

Horner’s rule evaluates each polynomial in $O(d)$ operations. Exhaustive search costs

$$
O\bigl(d(2B+1)^{d+1}\bigr)
$$

operations and $O(d)$ auxiliary space. Sorting by residual identifies near relations. Such a finite search neither proves nor refutes algebraicity: a true minimal polynomial may exceed the bounds, and floating-point approximation may create false near relations.

### 7.3 Bounded bivariate relation search

For approximations $x$ and $y$, enumerate coefficient arrays for monomials $X^iY^j$ of total degree at most $d$. There are

$$
M=\frac{(d+1)(d+2)}{2}
$$

such monomials. With coefficients bounded by $B$, exhaustive enumeration has exponential cost $O(M(2B+1)^M)$. It can illustrate the meaning of algebraic independence at small bounds, but no bounded computation can establish the universal quantification over all nonzero bivariate polynomials.

### 7.4 Substitution witness construction

The proof of Theorem 5.1 is algorithmic at the polynomial level. Given

$$
p(T)=\sum_{k=0}^{d}a_kT^k,
$$

construct

$$
Q(X,Y)=\sum_{k=0}^{d}a_k(X+Y)^k
       =\sum_{k=0}^{d}\sum_{j=0}^{k}a_k\binom{k}{j}X^jY^{k-j}.
$$

The dense output has at most $O(d^2)$ coefficients and can be produced in $O(d^2)$ rational arithmetic operations. Specialization $Y=0$ returns $p(X)$, proving that a nonzero input cannot map to the zero bivariate polynomial.

## 8. Applications and interpretation

### 8.1 A reusable transcendence template

Theorem 5.1 is not specific to exponentials. Whenever a problem supplies algebraic independence of a pair, every nonconstant rational polynomial in that pair is transcendental unless it degenerates to an element algebraic over the base. In the linear case, any combination $ax+by$ with $a,b\in\mathbb Q$ not both zero is expected to be transcendental, and the same substitution-and-retraction method proves it. The sum theorem is the coefficient choice $(a,b)=(1,1)$.

### 8.2 Expression-language design

The EML/EL comparison is an instance of conservative extension. A richer syntax is conservative over a smaller syntax when every object represented in the richer language already has a representation in the smaller one. Here extensional multiplication elimination is a compiler from EML trees to EL trees, with semantic equality as its correctness condition. The number-class equality is then a corollary obtained by evaluating compiled expressions at a distinguished input.

This perspective separates three questions:

1. **Recognition:** does a given tree belong to the restricted grammar?
2. **Evaluation:** what real value or function does the tree denote?
3. **Elimination:** can a tree using multiplication be replaced extensionally by one without it?

Recognition and evaluation are recursive. General elimination is the conjectural mathematical content.

### 8.3 Limits of numerical evidence

Algebraic numbers and transcendental numbers are both plentiful in ways that make local numerical behavior misleading. A finite decimal prefix cannot distinguish the two classes. Near-integer and near-polynomial relations are especially hazardous for nested exponential expressions because magnitudes can grow rapidly and conditioning can deteriorate. Numerical demonstrations should therefore report precision, bounds, and residuals, and must not promote a failed bounded search to a transcendence proof.

## 9. Discussion

The logical architecture is intentionally modular. Corollary 3.2 and Proposition 3.3 are unconditional consequences of grammar and evaluation. Theorem 5.1 is an unconditional algebraic statement. Corollary 5.3 depends only on concrete pair independence. Theorem 6.2 depends on multiplication elimination plus the automatic inclusion. This dependency structure makes it possible to revise one conjectural clause without disturbing unrelated results.

The presence of classical Schanuel in Hypothesis 4.1 expresses the intended conceptual setting, yet the short proofs do not manufacture the added clauses from it. Determining whether classical Schanuel implies concrete independence is a separate research problem. Likewise, functional elimination may require an exponential-algebraic closedness principle beyond a transcendence-degree lower bound.

The distinction between equality of number classes and equality of function classes also deserves emphasis. Number-class equality says that every value at $0$ has a restricted representation. Functional elimination says that every expression has a restricted representative agreeing at every real input. The latter implies the former, but the converse need not hold without additional coding or interpolation principles.

Finally, the featured constant is already syntactically EL because its displayed expression uses no multiplication. Its significance is therefore not as a witness separating the classes. Rather, it connects the expression grammar to the concrete independence clause and demonstrates how algebraic independence yields transcendence of a natural nested exponential–logarithmic value.

## 10. Future work

Five directions arise directly from the present framework.

1. **Classical Schanuel versus the concrete pair.** Determine whether classical Schanuel implies algebraic independence of $\exp(\exp(1))$ and $\log 2$, or whether a model of the classical conjecture can fail this statement.
2. **A structural source for multiplication elimination.** State a precise exponential-algebraic closedness principle and investigate whether it, together with classical Schanuel, yields extensional elimination for every rational EML expression.
3. **Separate transcendence of the generators.** Derive, under classical Schanuel if possible, transcendence of $\exp(\exp(1))$ and of $\log 2$ individually, then determine what extra input is needed for joint algebraic independence.
4. **Finite-arity languages.** Replace the single variable by $n$ variables and compare EML and EL represented-function classes. One expects extensional elimination at each finite arity to be closely related to equality of those function classes.
5. **General rational linear combinations.** If $x_1,\ldots,x_n$ are algebraically independent over $\mathbb Q$ and $c_1,\ldots,c_n\in\mathbb Q$ are not all zero, prove that $\sum_i c_ix_i$ is transcendental. A specialization argument reducing to a surviving variable gives the natural proof route.

## 11. Conclusion

A compact grammar organizes a broad family of exponential–logarithmic constants. Within it, the inclusion $\mathrm{EL}\subseteq\mathrm{EML}$ and representation of $\exp(\exp(1))+\log 2$ are immediate structural facts. The arithmetic step is supplied by a general theorem: algebraic independence of two real numbers forces transcendence of their sum. Under the explicit concrete-independence clause of the functional EML strengthening of Schanuel’s conjecture, the featured constant is therefore transcendental. Under the separate multiplication-elimination clause, the richer and poorer number languages represent exactly the same real numbers.

The conclusions are conditional precisely where the mathematics is conjectural. By stating each assumption independently, the framework turns a broad aspiration into focused targets: derive the concrete pair independence, identify a principled source of functional elimination, and extend the substitution argument from one sum to arbitrary nonzero rational linear combinations.
