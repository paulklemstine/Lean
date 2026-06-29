# The EML Single-Operator Church–Turing Thesis: Algebraic and Applications Completeness

## Abstract

We study the expressive power of a single binary transcendental primitive on the
real numbers, the **EML operator**
$$\mathrm{eml}(x, y) = e^{x} - \ln(y),$$
when combined with the field operations $(+, \times, \mathrm{neg}, \mathrm{inv})$
and arbitrary real constants. Our central thesis is a continuous analogue of the
Church–Turing thesis: this lone operator generates a class of total real functions
that is closed under all elementary constructions — including $\exp$, $\ln$, and
$\mathrm{eml}$ themselves — and that coincides exactly with the two-operator
$\{\exp, \ln\}$-elementary class. We harvest two concrete completeness payoffs.
**(Algebraic completeness)** every multivariate real polynomial function is
single-operator representable. **(Applications completeness)** every standard
smooth neural-network activation function — the logistic sigmoid, softplus,
hyperbolic tangent, and SiLU/swish — is single-operator representable. We give the
fusion identities $\exp(x) = \mathrm{eml}(x, 1)$ and $\ln(y) = 1 - \mathrm{eml}(0,
y)$, establish a bidirectional, semantics-preserving compilation between the
one-operator and two-operator languages with linear size bounds (forward
$\le 5\cdot\text{size}$, reverse $\le 4\cdot\text{size}$), and develop the
function-algebra closure properties that make the completeness results possible.
All results have been formalized and machine-checked in Lean 4 with no unproved
assumptions beyond the standard foundational axioms.

**Keywords:** single-operator completeness, elementary functions, analog
computation, Church–Turing thesis, neural activation functions, functional
completeness, symbolic compilation, expression normal forms.

---

## 1. Introduction

### 1.1 Functional completeness in the continuous setting

The history of computation is, in large part, a search for minimal generating
primitives. In Boolean logic, the single gate NAND (or NOR) is functionally
complete: every Boolean function is a composition of copies of it. In combinatory
logic, the single combinator $S$ (with $K$ derivable, or via a single combinator
such as $\iota$) suffices to express all of computation. These discrete results are
the backbone of the Church–Turing thesis: the robust observation that many
independently motivated models of computation define the same class of functions.

The continuous analogue is subtler. When the objects of computation are real
functions $f : \mathbb{R}^n \to \mathbb{R}$, one must first decide what counts as a
primitive operation and what counts as a legal mode of combination. Shannon's
General Purpose Analog Computer (GPAC) takes constants, addition, multiplication,
and integration as primitive; Grzegorczyk's and others' theories of *elementary*
real functions take $\exp$ and $\ln$ together with field operations and
composition. In all these frameworks, the exponential and logarithm play a
distinguished role as the canonical transcendental atoms: nearly every named
special function of classical analysis is an elementary composite of $\exp$ and
$\ln$ with arithmetic.

### 1.2 The single-operator thesis

This paper pursues a sharper question. Two transcendental atoms ($\exp$ and $\ln$)
are convenient, but are they *necessary as separate primitives*? We answer no: a
single fused binary operator suffices. Define
$$\mathrm{eml}(x, y) = e^{x} - \ln(y).$$
The name records its construction (**e**xp **m**inus **l**og). The decisive
observation is that EML re-derives each of its constituent halves by feeding it
appropriate constants:
$$\mathrm{eml}(x, 1) = e^{x} - \ln 1 = e^{x}, \qquad
\mathrm{eml}(0, y) = e^{0} - \ln y = 1 - \ln y \;\Rightarrow\;
\ln y = 1 - \mathrm{eml}(0, y).$$
Consequently the single operator $\mathrm{eml}$, together with the field operations
and constants, has exactly the expressive power of the two operators $\exp$ and
$\ln$. We call the resulting principle the **single-operator Church–Turing
thesis**.

### 1.3 Contributions

1. **Fusion identities and language equivalence (§3).** We make precise two
   expression languages — a two-operator language with separate $\exp$/$\ln$ nodes
   and a one-operator language with a sole $\mathrm{eml}$ node — and prove that the
   induced classes of representable functions coincide, via a bidirectional
   semantics-preserving compilation with linear size bounds.

2. **Function-algebra closure (§4).** We establish that the single-operator class
   is closed under constants, projections, $+$, $\times$, negation, reciprocal,
   $\exp$, $\ln$, the operator $\mathrm{eml}$ itself, and finite sums and products.

3. **Algebraic completeness (§5).** Every multivariate real polynomial function
   $p \in \mathbb{R}[x_1, \dots, x_n]$, evaluated as a function, is single-operator
   representable.

4. **Applications completeness (§6).** Every standard smooth feed-forward
   activation — logistic sigmoid, softplus, $\tanh$, SiLU/swish — is single-operator
   representable.

5. **Formalization.** All statements are mechanically verified in Lean 4 / Mathlib,
   with no `sorry` and only standard foundational axioms.

---

## 2. Preliminaries and semantics

### 2.1 Totalization conventions

We work with **total** functions $\mathbb{R}^n \to \mathbb{R}$. To keep every
expression well-defined we adopt the standard Mathlib totalization of the partial
primitives:
$$\ln(x) = 0 \text{ for } x \le 0, \qquad x^{-1} = 0 \text{ for } x = 0.$$
With these conventions every syntactic expression denotes a genuine total real
function, and all closure and completeness claims below are statements about total
functions. (A domain-faithful *partial* variant, in which undefinedness is tracked
explicitly, is discussed in §8 as future work.)

### 2.2 The two expression languages

We use $n$ for the arity (number of input variables) and identify a variable
assignment with a tuple $x \in (\mathrm{Fin}\,n \to \mathbb{R}) \cong \mathbb{R}^n$.

**Two-operator language `EMLExpr`.** An inductive syntax tree with constructors

- $\mathrm{const}\,c$ for $c \in \mathbb{R}$,
- $\mathrm{var}\,i$ for an input index $i$,
- $\mathrm{add}$, $\mathrm{mul}$, $\mathrm{neg}$, $\mathrm{inv}$ (field operations),
- $\mathrm{exp}$, $\mathrm{log}$ (separate transcendental nodes),

with the evident evaluation map $\mathrm{eval} : \texttt{EMLExpr} \to (\mathbb{N}
\to \mathbb{R}) \to \mathbb{R}$ sending each node to its semantic counterpart under
the totalization conventions.

**One-operator language `EMLOnlyExpr`.** The same field-operation and atom
constructors, but with the *single* transcendental node $\mathrm{eml}(e_1, e_2)$
in place of separate $\mathrm{exp}$/$\mathrm{log}$ nodes, evaluated by
$$\mathrm{eml}(e_1, e_2) \mapsto \exp(\mathrm{eval}\,e_1) - \ln(\mathrm{eval}\,e_2).$$

### 2.3 Representability

> **Definition 2.1 (Representability).** A function $f : (\mathrm{Fin}\,n \to
> \mathbb{R}) \to \mathbb{R}$ is **EML-representable**, written
> $\mathrm{EMLRepresentable}\,f$, if there exists $e : \texttt{EMLExpr}$ such that
> $f(x) = e.\mathrm{eval}(x)$ for all $x$. It is **single-operator representable**
> (**EML-only representable**), written $\mathrm{EMLOnlyRepresentable}\,f$, if there
> exists $e : \texttt{EMLOnlyExpr}$ with the same property.

We also use a syntactic *size* measure on each language: $\mathrm{size}$ counts the
number of nodes in the expression tree, with leaves (constants, variables) of size
$1$ and each internal node adding $1$ to the sum of its children's sizes.

---

## 3. Fusion identities and language equivalence

### 3.1 The fusion identities

> **Lemma 3.1 (Fusion).** For all $x, y \in \mathbb{R}$ with $y > 0$,
> $$\mathrm{eml}(x, 1) = e^{x}, \qquad \mathrm{eml}(0, y) = 1 - \ln y, \qquad
> \ln y = 1 - \mathrm{eml}(0, y).$$
> Moreover $\mathrm{eml}(\ln a, e^{b}) = a - b$ for all $a > 0$, $b \in \mathbb{R}$.

*Proof.* Direct computation from $\ln 1 = 0$, $e^{0} = 1$, $e^{\ln a} = a$ (for
$a > 0$), and $\ln(e^{b}) = b$. $\qquad\blacksquare$

The first two identities are the engine of the compilation; the last
($\mathrm{eml}(\ln a, e^{b}) = a - b$) exhibits subtraction itself as an EML
composite on positive inputs, underscoring how arithmetic and the transcendental
primitive interlock.

### 3.2 Forward compilation: two operators to one

> **Definition 3.2 (Forward compiler).** Define $\mathcal{C} : \texttt{EMLExpr}
> \to \texttt{EMLOnlyExpr}$ recursively, acting as the identity on constants,
> variables, and field operations, and on the transcendental nodes by
> $$\mathcal{C}(\mathrm{exp}\,e) = \mathrm{eml}(\mathcal{C}(e),\ \mathrm{const}\,1),
> \qquad
> \mathcal{C}(\mathrm{log}\,e) = \mathrm{const}\,1 + \bigl(-\,\mathrm{eml}(
> \mathrm{const}\,0,\ \mathcal{C}(e))\bigr).$$

> **Theorem 3.3 (Forward correctness).** For every $e : \texttt{EMLExpr}$ and
> assignment $\mathrm{env}$,
> $$\mathcal{C}(e).\mathrm{eval}(\mathrm{env}) = e.\mathrm{eval}(\mathrm{env}).$$

*Proof sketch.* Structural induction on $e$. The field-operation and leaf cases are
immediate from the inductive hypotheses. The $\mathrm{exp}$ case uses
$\mathrm{eml}(t, 1) = e^{t} - \ln 1 = e^{t}$; the $\mathrm{log}$ case uses
$1 + (-(e^{0} - \ln t)) = 1 - (1 - \ln t) = \ln t$. $\qquad\blacksquare$

> **Theorem 3.4 (Forward size bound).** For every $e : \texttt{EMLExpr}$,
> $\mathrm{size}(\mathcal{C}(e)) \le 5 \cdot \mathrm{size}(e)$.

*Proof sketch.* Induction. The worst case is the $\mathrm{log}$ node, which expands
to a five-node skeleton $\mathrm{add}(\mathrm{const}\,1, \mathrm{neg}(\mathrm{eml}(
\mathrm{const}\,0, \cdot)))$ wrapped around the compiled child; the factor $5$
dominates all other cases. $\qquad\blacksquare$

### 3.3 Reverse compilation: one operator to two

> **Definition 3.5 (Reverse compiler).** Define $\mathcal{D} : \texttt{EMLOnlyExpr}
> \to \texttt{EMLExpr}$ as the identity on leaves and field operations, and on the
> single transcendental node by
> $$\mathcal{D}(\mathrm{eml}(e_1, e_2)) = \mathrm{exp}(\mathcal{D}(e_1)) +
> \bigl(-\,\mathrm{log}(\mathcal{D}(e_2))\bigr).$$

> **Theorem 3.6 (Reverse correctness).** For every $e : \texttt{EMLOnlyExpr}$ and
> assignment $\mathrm{env}$, $\mathcal{D}(e).\mathrm{eval}(\mathrm{env}) =
> e.\mathrm{eval}(\mathrm{env})$.

*Proof sketch.* Structural induction; the $\mathrm{eml}$ case is exactly the
definition $\mathrm{eml}(a, b) = e^{a} - \ln b$, matched after a `ring`
normalization. The reverse size bound $\mathrm{size}(\mathcal{D}(e)) \le 4 \cdot
\mathrm{size}(e)$ holds by the same node-counting argument. $\qquad\blacksquare$

### 3.4 The equivalence theorem

> **Theorem 3.7 (Language equivalence).** For every $f : (\mathrm{Fin}\,n \to
> \mathbb{R}) \to \mathbb{R}$,
> $$\mathrm{EMLOnlyRepresentable}\,f \iff \mathrm{EMLRepresentable}\,f.$$

*Proof.* ($\Leftarrow$) Given a witness $e \in \texttt{EMLExpr}$ for $f$, the
expression $\mathcal{C}(e)$ is a single-operator witness by Theorem 3.3.
($\Rightarrow$) Given $e \in \texttt{EMLOnlyExpr}$, the expression $\mathcal{D}(e)$
is a two-operator witness by Theorem 3.6. $\qquad\blacksquare$

Theorem 3.7 is the formal core of the single-operator thesis: collapsing two
transcendental primitives into one costs nothing in expressive power and only a
constant factor in size.

---

## 4. The single-operator function algebra

The completeness results rest on closure properties: a toolbox of constructors
showing that representability is preserved under each elementary operation. We
record them as a single proposition; each clause is an independently formalized
lemma, and via Theorem 3.7 each may be proved in whichever language is more
convenient.

> **Proposition 4.1 (Closure).** Fix arity $n$. The class of single-operator
> representable functions $(\mathrm{Fin}\,n \to \mathbb{R}) \to \mathbb{R}$
> contains the constants $\mathrm{const}\,c$ and the coordinate projections
> $x \mapsto x_i$, and is closed under each of the following: if $f, g$ are
> representable, then so are
> $$f + g, \quad f \cdot g, \quad -f, \quad f^{-1}, \quad \exp \circ f, \quad
> \ln \circ f, \quad (x \mapsto \mathrm{eml}(f(x), g(x))),$$
> and, for any natural number $k$, the power $x \mapsto f(x)^{k}$, as well as the
> compositions $\sinh \circ f$ and $\cosh \circ f$.

*Proof sketch.* Constants, projections, and the field operations are immediate from
the corresponding syntactic constructors. The transcendental closures follow from
the fusion identities of Lemma 3.1: $\exp \circ f$ via $\mathrm{eml}(\cdot, 1)$,
$\ln \circ f$ via $1 - \mathrm{eml}(0, \cdot)$, and the $\mathrm{eml}$-closure
directly. Powers follow by induction on $k$ from closure under products (with the
base case the constant $1$); $\sinh$ and $\cosh$ are field combinations of $\exp$
of $f$ and $\exp$ of $-f$. $\qquad\blacksquare$

We further lift binary closure to the finite case, which is what the polynomial
argument needs.

> **Lemma 4.2 (Finite sum closure).** Let $s$ be a finite index set and
> $\{f_i\}_{i \in s}$ a family of representable functions. Then $x \mapsto
> \sum_{i \in s} f_i(x)$ is representable.

> **Lemma 4.3 (Finite product closure).** Under the same hypotheses, $x \mapsto
> \prod_{i \in s} f_i(x)$ is representable.

*Proof sketch.* Both proceed by finite-set induction. The empty case yields the
representable constants $0$ (for sums) and $1$ (for products). The insertion step
applies binary closure under $+$ (resp. $\times$) to the new term and the inductive
hypothesis, with the membership bookkeeping handled by the standard
$\mathrm{mem\_insert}$ lemmas and $\mathrm{sum\_insert}$ / $\mathrm{prod\_insert}$
rewrites. $\qquad\blacksquare$

---

## 5. Algebraic completeness: all polynomials

> **Theorem 5.1 (Polynomial completeness).** For every multivariate polynomial
> $p \in \mathbb{R}[x_1, \dots, x_n]$, the evaluation function $x \mapsto p(x)$ on
> $\mathrm{Fin}\,n \to \mathbb{R}$ is single-operator representable. Equivalently,
> the single primitive $\mathrm{eml}$ together with arithmetic and constants
> captures the entire polynomial algebra $\mathbb{R}[x_1, \dots, x_n]$ as evaluated
> functions.

*Proof.* Write the polynomial in its monomial expansion. By the standard
evaluation identity,
$$p(x) = \sum_{d \in \mathrm{supp}(p)} \mathrm{coeff}_d(p) \cdot
\prod_{i \in \mathrm{supp}(d)} x_i^{\,d_i},$$
a finite sum over the support of $p$, each term a constant coefficient times a
finite product of natural-number powers of the coordinates. Each power $x_i^{d_i}$
is representable by the power clause of Proposition 4.1 (applied to the projection
$x \mapsto x_i$). Each interior product is representable by Lemma 4.3; multiplying
by the constant coefficient preserves representability by binary product closure;
and the outer finite sum is representable by Lemma 4.2. $\qquad\blacksquare$

Theorem 5.1 shows that a transcendental primitive, properly fused, subsumes the
purely algebraic world *for free*: no $\exp$ or $\ln$ is visibly needed to write a
polynomial, yet the closure machinery driven by $\mathrm{eml}$ delivers them all.

---

## 6. Applications completeness: neural activations

We now turn to the application that gives the thesis "teeth" in the Applications
domain. A feed-forward neural network alternates affine pre-activations (degree-one
polynomials, representable by Theorem 5.1) with a fixed coordinate-wise activation.
We show that every standard smooth activation is single-operator representable; we
state each at arity $1$ (a single input coordinate $x_0$), which suffices since
activations act coordinate-wise.

> **Theorem 6.1 (Logistic sigmoid).** The function
> $$\sigma(x_0) = \bigl(1 + e^{-x_0}\bigr)^{-1}$$
> is single-operator representable.

*Proof.* $\sigma = \mathrm{inv}\bigl(\mathrm{const}\,1 + \exp(-\,\mathrm{proj}_0)
\bigr)$, a composite of the reciprocal, addition, constant, exponential, and
negation closures of Proposition 4.1. $\qquad\blacksquare$

> **Theorem 6.2 (Softplus).** The function $\zeta(x_0) = \ln\bigl(1 + e^{x_0}\bigr)$
> is single-operator representable.

*Proof.* $\zeta = \ln\bigl(\mathrm{const}\,1 + \exp(\mathrm{proj}_0)\bigr)$, using
the logarithm, addition, constant, and exponential closures. This is the unique
activation in our list that exercises the $\ln$ half of $\mathrm{eml}$. $\qquad
\blacksquare$

> **Theorem 6.3 (Hyperbolic tangent).** The function $\tanh(x_0)$ is single-operator
> representable.

*Proof.* Using $\tanh = \sinh / \cosh = \sinh \cdot \cosh^{-1}$, both $\sinh$ and
$\cosh$ are representable by Proposition 4.1, hence so is their product with the
reciprocal. Rewriting $\sinh(x_0)\cdot \cosh(x_0)^{-1}$ to $\tanh(x_0)$ via the
identity $\tanh = \sinh/\cosh$ completes the proof. $\qquad\blacksquare$

> **Theorem 6.4 (SiLU / swish).** The function
> $$\mathrm{swish}(x_0) = x_0 \cdot \bigl(1 + e^{-x_0}\bigr)^{-1} = x_0 \cdot
> \sigma(x_0)$$
> is single-operator representable.

*Proof.* The product of the projection $\mathrm{proj}_0$ with the sigmoid of
Theorem 6.1, closed under multiplication. $\qquad\blacksquare$

Collecting the four theorems:

> **Corollary 6.5 (Applications completeness).** Every standard smooth
> feed-forward activation function — logistic sigmoid, softplus, hyperbolic
> tangent, and SiLU/swish — is single-operator representable. Consequently any
> function computed by a feed-forward network with polynomial (affine)
> pre-activations and any of these activations lies in the single-operator class.

**A structural remark.** Of the four activations, only softplus uses the $\ln$ half
of $\mathrm{eml}$. The other three appear "log-free." Yet none of them could be
written without $\mathrm{eml}$, because the exponential they all rely on is itself
available *only through* $\mathrm{eml}$ via $e^{x} = \mathrm{eml}(x, 1)$. Even the
log-free-looking activations secretly exercise the single fused primitive — the
clearest evidence that one binary operator is the genuine generator of the family.

---

## 7. Algorithms

The constructive content of the results above is a pair of compilers and an
evaluator. We summarize their logic; full pseudocode and reference Python
implementations accompany this package.

**(A) Forward compiler $\mathcal{C}$ (two operators $\to$ one).** A single
post-order traversal of the syntax tree. Field and leaf nodes are copied; an
$\mathrm{exp}$ node becomes $\mathrm{eml}(\cdot, 1)$; a $\mathrm{log}$ node becomes
$1 - \mathrm{eml}(0, \cdot)$. Time and output size are linear in the input size,
with the explicit bound $\mathrm{size}(\mathcal{C}(e)) \le 5\cdot\mathrm{size}(e)$.

**(B) Reverse compiler $\mathcal{D}$ (one operator $\to$ two).** The dual
traversal: each $\mathrm{eml}(a, b)$ node expands to $\exp(a) - \ln(b)$. Linear
time, with $\mathrm{size}(\mathcal{D}(e)) \le 4\cdot\mathrm{size}(e)$.

**(C) Total evaluator.** A recursive evaluator honoring the totalization
conventions ($\ln$ of non-positive inputs and reciprocal of zero both return $0$),
so that every expression denotes a total real function.

**(D) Polynomial-to-EML elaborator.** Given a polynomial as a list of
(coefficient, exponent-vector) monomials, emit an EML-only expression by Lemma 4.2
and Lemma 4.3: build each monomial as a product of repeated multiplications and sum
them. This realizes Theorem 5.1 constructively.

---

## 8. Discussion and future work

### 8.1 What the thesis does and does not claim

The single-operator thesis as established here is an *exact-representation* result
about the elementary class: every elementary function (in particular every
polynomial and every standard activation) is a finite single-operator composite,
and the one-operator and two-operator classes coincide. It is *not yet* a density
(approximation) statement about arbitrary continuous functions; that is the subject
of conjecture C4 below.

### 8.2 Future directions

**C1. Necessity / minimality of the single operator.** The field-operations-only
fragment (no $\mathrm{eml}$) represents exactly the rational functions, and
$\exp$ is not among them, so the transcendental primitive is genuinely necessary.

> **Conjecture C1.** Let $\mathrm{FieldOnlyRepresentable}$ be the closure of
> constants and projections under $+, \times, \mathrm{neg}, \mathrm{inv}$. Then
> $\mathrm{FieldOnlyRepresentable}\,f \iff f = (\mathrm{eval}\,\cdot\,p) /
> (\mathrm{eval}\,\cdot\,q)$ for polynomials $p, q$ (as total functions with junk
> value $\mathrm{inv}\,0 = 0$), and $\neg\,\mathrm{FieldOnlyRepresentable}(x \mapsto
> e^{x_0})$. The negative half follows from $\exp$ outgrowing every rational
> function (e.g. via $\exp(x)/x^k \to \infty$) and the transcendence of $\exp$ over
> $\mathbb{R}(x)$.

**C2. Tightness of the size bounds.** The overhead constants $5$ (forward) and $4$
(reverse) should be optimal.

> **Conjecture C2.** There is a family $e_k$ of $\log$-only expressions with
> $\mathrm{size}(\mathcal{C}(e_k)) = 5\,\mathrm{size}(e_k) - o(\mathrm{size})$, and
> dually a family of $\mathrm{eml}$-only expressions saturating the reverse bound.
> Equivalently, no compiler achieves a constant $< 5$ (resp. $< 4$) for all inputs.

**C3. Domain-faithful (partial) single-operator thesis.** Our semantics is total
(junk values for $\ln$ and $\mathrm{inv}$). The sharper statement uses partial
$\mathrm{Option}\,\mathbb{R}$ semantics.

> **Conjecture C3.** There is a compilation $\texttt{UExpr} \to \texttt{EMLExpr}$
> (single primitive, partial semantics) that is domain-faithful: the partial
> evaluation of the source agrees with that of the target on all inputs, including
> the undefined (`none`) cases, with the $\mathrm{eml}$ node guarded by its
> positivity side-condition, and with linear size blow-up.

**C4. Stone–Weierstrass universality.** The natural summit: density of the
single-operator class among continuous functions.

> **Conjecture C4.** On any compact box $K \subset \mathbb{R}^n$, the
> single-operator representable functions are uniformly dense in $C(K)$. Since the
> class is a subalgebra containing the constants and separating points (it contains
> all coordinate projections), a Stone–Weierstrass argument should apply, upgrading
> exact representation of the elementary class to approximate representation of
> *all* continuous functions.

### 8.3 Implications

For **hardware**, EML is an attractive candidate for a single reconfigurable
nonlinear cell in analog or neuromorphic accelerators: one $\exp$–$\ln$–subtract
unit, wired with arithmetic and reprogrammed only through constants, can be coaxed
into any of the standard activations. For **theory**, the results recast $\exp$ and
$\ln$ not as two independent pillars of analysis but as two faces of a single
primitive, with subtraction as the glue (via $\mathrm{eml}(\ln a, e^b) = a - b$).

---

## 9. Conclusion

We have formalized and machine-checked the affirmative content of the EML
single-operator Church–Turing thesis. A single binary primitive
$\mathrm{eml}(x, y) = e^x - \ln y$, with field operations and constants, generates a
function class that (i) is closed under all elementary constructions, (ii)
coincides exactly with the two-operator elementary class up to a constant-factor
compilation overhead, (iii) contains every multivariate polynomial, and (iv)
contains every standard smooth neural activation. One operator suffices.
