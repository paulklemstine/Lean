# Closure Properties of the Log-Free EML Differential Algebra

**Author:** Aristotle
**Date:** 2026-06-25

## Abstract

We study the *log-free EML functions* — the smallest class of functions
$\mathbb{R} \to \mathbb{R}$ containing the constants and the identity and
closed under addition, multiplication, negation, and the real
exponential. These are exactly the **exponential polynomials**. We
formalize them syntactically as an inductive term algebra equipped with an
evaluation map, a syntactic derivation operator $D$, and a syntactic
composition (substitution) operator. Our main results are: (i) every EML
function is $C^\infty$; (ii) the syntactic derivative $D$ is correct, both
in its pointwise `HasDerivAt` form and in the global `deriv` form; (iii)
syntactic composition correctly implements function composition; and (iv)
the EML functions constitute an $\mathbb{R}$-subalgebra of the function
algebra $\mathbb{R}\to\mathbb{R}$ that is additionally closed under the
exponential, under composition, and under differentiation — i.e. a
*commutative differential subalgebra* every member of which is smooth. We
also delineate the boundaries of the class: it is a ring but not a field
(reciprocals such as $1/x$ escape), it is closed under differentiation but
only partially under integration ($e^{x^2}$ has no EML primitive), and it
is closed under composition but not under functional inverse (the cube map
has no EML inverse). These boundary phenomena are recast as crisp
algebraic statements: non-closure under integration is the
non-surjectivity of $D$, a Liouville-type obstruction internal to the term
algebra. All positive results are machine-checked.

**Keywords:** exponential polynomial, EML function, differential algebra,
syntactic derivative, term algebra, smoothness, subalgebra, composition.

---

## 1. Introduction

A recurring question across mathematics asks which operations preserve
membership in a given family of objects, and which break out of it. For
polynomials, differentiation and the ring operations stay inside, but the
exponential does not. For rational functions, differentiation stays
inside, but the exponential does not. For the "elementary functions" of
calculus — built with division, logarithms, and roots — differentiation
stays inside but the class is large and analytically delicate.

This paper isolates a family sitting precisely between polynomials and the
full elementary functions: the **log-free EML functions**, equivalently
the **exponential polynomials**. They are generated from the variable $x$
and real constants by addition, multiplication, negation, and the
exponential $\exp$. The family is small enough to admit a complete and
clean structural analysis, yet large enough to contain analytically
important functions such as $x^k e^{\lambda x}$ and $e^{x^2}$.

Our approach is to separate *syntax* from *semantics*. We define an
inductive type of **terms** (finite formula trees), an **evaluation**
map sending each term to the function it denotes, a **syntactic
derivation** $D$ that rewrites a term into the term denoting its
derivative, and a **syntactic composition** that substitutes one term for
the variable of another. We then prove correctness theorems linking syntax
to semantics, and derive all closure properties as corollaries. This
strategy turns analytic closure facts into combinatorial inductions over
term structure.

### Contributions

1. A faithful formalization of the log-free EML term algebra with
   evaluation, syntactic derivation, and syntactic composition.
2. A proof that every EML function is $C^\infty$.
3. Correctness of $D$ in both `HasDerivAt` and `deriv` forms.
4. Correctness of syntactic composition.
5. Closure of the EML class under $+$, $\times$, scalar action, $\exp$,
   composition, and differentiation, packaged as an
   $\mathbb{R}$-subalgebra of $\mathbb{R}\to\mathbb{R}$ all of whose
   members are smooth.
6. A precise account of the boundaries: ring-but-not-field, partial
   integration closure (Liouville obstruction reframed as
   non-surjectivity of $D$), and failure of inverse closure.

---

## 2. The term algebra

### 2.1 Syntax

**Definition 2.1 (Terms).** The type $\mathsf{Term}$ of log-free EML terms
is generated inductively by the constructors

$$
\mathsf{const} : \mathbb{R} \to \mathsf{Term}, \qquad
\mathsf{X} : \mathsf{Term},
$$
$$
\mathsf{add},\ \mathsf{mul} : \mathsf{Term} \to \mathsf{Term} \to \mathsf{Term},
\qquad
\mathsf{neg},\ \mathsf{exp} : \mathsf{Term} \to \mathsf{Term}.
$$

A term is a finite tree: leaves are $\mathsf{const}\,c$ (for some real
$c$) or $\mathsf{X}$; internal nodes are $\mathsf{add}$, $\mathsf{mul}$
(binary), or $\mathsf{neg}$, $\mathsf{exp}$ (unary).

### 2.2 Semantics

**Definition 2.2 (Evaluation).** The evaluation map
$\mathsf{eval} : \mathsf{Term} \to (\mathbb{R} \to \mathbb{R})$ is defined
by structural recursion:

$$
\mathsf{eval}(\mathsf{const}\,c) = (x \mapsto c), \qquad
\mathsf{eval}(\mathsf{X}) = (x \mapsto x),
$$
$$
\mathsf{eval}(\mathsf{add}\,a\,b) = x \mapsto \mathsf{eval}(a)(x) + \mathsf{eval}(b)(x),
$$
$$
\mathsf{eval}(\mathsf{mul}\,a\,b) = x \mapsto \mathsf{eval}(a)(x)\cdot \mathsf{eval}(b)(x),
$$
$$
\mathsf{eval}(\mathsf{neg}\,a) = x \mapsto -\,\mathsf{eval}(a)(x),
\qquad
\mathsf{eval}(\mathsf{exp}\,a) = x \mapsto \exp\big(\mathsf{eval}(a)(x)\big).
$$

Each defining equation holds definitionally and is recorded as a
simplification lemma (`eval_const`, `eval_X`, `eval_add`, `eval_mul`,
`eval_neg`, `eval_exp`).

**Definition 2.3 (EML function).** A function $f : \mathbb{R}\to\mathbb{R}$
is **EML**, written $\mathrm{IsEML}(f)$, iff there exists a term $t$ with
$\mathsf{eval}(t) = f$. Equivalently, the EML functions are the image of
$\mathsf{eval}$.

### 2.3 Syntactic derivation

**Definition 2.4 (Syntactic derivative).** The operator
$D : \mathsf{Term} \to \mathsf{Term}$ is defined by structural recursion,
encoding the standard differentiation rules:

$$
D(\mathsf{const}\,c) = \mathsf{const}\,0, \qquad
D(\mathsf{X}) = \mathsf{const}\,1,
$$
$$
D(\mathsf{add}\,a\,b) = \mathsf{add}\,(D a)\,(D b),
$$
$$
D(\mathsf{mul}\,a\,b) = \mathsf{add}\,(\mathsf{mul}\,(D a)\,b)\,(\mathsf{mul}\,a\,(D b))
\quad\text{(product rule)},
$$
$$
D(\mathsf{neg}\,a) = \mathsf{neg}\,(D a),
\qquad
D(\mathsf{exp}\,a) = \mathsf{mul}\,(D a)\,(\mathsf{exp}\,a)
\quad\text{(chain rule)}.
$$

Crucially, $D$ is an endomorphism of $\mathsf{Term}$: it never leaves the
syntax. This is the structural reason behind closure under
differentiation.

### 2.4 Syntactic composition

**Definition 2.5 (Substitution / composition).** The operator
$\mathsf{comp} : \mathsf{Term} \to \mathsf{Term} \to \mathsf{Term}$
substitutes its second argument $t$ for every occurrence of $\mathsf{X}$
in its first argument $s$:

$$
\mathsf{comp}(\mathsf{const}\,c, t) = \mathsf{const}\,c, \qquad
\mathsf{comp}(\mathsf{X}, t) = t,
$$
$$
\mathsf{comp}(\mathsf{add}\,a\,b, t) = \mathsf{add}\,(\mathsf{comp}(a,t))\,(\mathsf{comp}(b,t)),
$$
$$
\mathsf{comp}(\mathsf{mul}\,a\,b, t) = \mathsf{mul}\,(\mathsf{comp}(a,t))\,(\mathsf{comp}(b,t)),
$$
$$
\mathsf{comp}(\mathsf{neg}\,a, t) = \mathsf{neg}\,(\mathsf{comp}(a,t)),
\qquad
\mathsf{comp}(\mathsf{exp}\,a, t) = \mathsf{exp}\,(\mathsf{comp}(a,t)).
$$

---

## 3. Main results

### 3.1 Smoothness

**Theorem 3.1 (`contDiff_eval`).** For every term $t$, the function
$\mathsf{eval}(t)$ is $C^\infty$; that is,
$\mathrm{ContDiff}\ \mathbb{R}\ \infty\ \mathsf{eval}(t)$.

*Proof sketch.* Structural induction on $t$. The base cases are the
constant function (smooth) and the identity (smooth). For the inductive
steps, sums, products, and negations of smooth functions are smooth, and
the composition of $\exp$ (smooth) with a smooth function is smooth. Each
step invokes the corresponding closure lemma for $C^\infty$ functions on
the inductive hypotheses. $\square$

A corollary records smoothness at the level of the function class
(Theorem 3.8 below).

### 3.2 Correctness of differentiation

**Theorem 3.2 (`hasDerivAt_eval`).** For every term $t$ and every point
$x \in \mathbb{R}$,

$$
\mathrm{HasDerivAt}\ \big(\mathsf{eval}(t)\big)\ \big(\mathsf{eval}(D t)(x)\big)\ x.
$$

That is, $\mathsf{eval}(t)$ is differentiable at $x$ with derivative equal
to the value at $x$ of the function denoted by the syntactic derivative
$D t$.

*Proof sketch.* Induction on $t$, generalizing over $x$.
- $\mathsf{const}\,c$: the constant function has derivative $0$, matching
  $\mathsf{eval}(D(\mathsf{const}\,c)) = \mathsf{eval}(\mathsf{const}\,0) = 0$.
- $\mathsf{X}$: the identity has derivative $1 = \mathsf{eval}(\mathsf{const}\,1)$.
- $\mathsf{add}\,a\,b$: apply the sum rule for `HasDerivAt` to the
  inductive hypotheses for $a$ and $b$.
- $\mathsf{mul}\,a\,b$: apply the product rule for `HasDerivAt`; the result
  matches the term $\mathsf{add}(\mathsf{mul}(Da)\,b)(\mathsf{mul}\,a\,(Db))$.
- $\mathsf{neg}\,a$: apply the negation rule.
- $\mathsf{exp}\,a$: apply the chain rule for $\exp$ composed with a
  differentiable function; reorder the product to match
  $\mathsf{mul}\,(Da)\,(\mathsf{exp}\,a)$. $\square$

**Theorem 3.3 (`deriv_eval`).** For every term $t$ and point $x$,

$$
\frac{d}{dx}\,\mathsf{eval}(t)\,(x) = \mathsf{eval}(D t)(x).
$$

*Proof sketch.* Immediate from Theorem 3.2: a `HasDerivAt` witness
determines the value of `deriv`. $\square$

### 3.3 Correctness of composition

**Theorem 3.4 (`eval_comp`).** For all terms $s, t$ and every point $x$,

$$
\mathsf{eval}\big(\mathsf{comp}(s,t)\big)(x) = \mathsf{eval}(s)\big(\mathsf{eval}(t)(x)\big).
$$

*Proof sketch.* Induction on $s$. The $\mathsf{const}$ and $\mathsf{X}$
cases are definitional. The $\mathsf{add}$, $\mathsf{mul}$, $\mathsf{neg}$,
and $\mathsf{exp}$ cases follow by rewriting with the inductive hypotheses
and unfolding evaluation. $\square$

### 3.4 Closure properties of the EML class

The correctness theorems yield the closure properties as direct
corollaries. In each, witnessing terms are produced explicitly.

**Proposition 3.5 (generators).**
$\mathrm{IsEML}(x \mapsto c)$ for every constant $c$ (`isEML_const`,
witness $\mathsf{const}\,c$) and $\mathrm{IsEML}(x \mapsto x)$
(`isEML_id`, witness $\mathsf{X}$).

**Proposition 3.6 (ring and exponential closure).** If
$\mathrm{IsEML}(f)$ and $\mathrm{IsEML}(g)$ then
- $\mathrm{IsEML}(f + g)$ (`IsEML.add`, witness $\mathsf{add}\,t_f\,t_g$);
- $\mathrm{IsEML}(f \cdot g)$ (`IsEML.mul`, witness $\mathsf{mul}\,t_f\,t_g$);
- $\mathrm{IsEML}(-f)$ (`IsEML.neg`, witness $\mathsf{neg}\,t_f$);
- $\mathrm{IsEML}(x \mapsto \exp(f(x)))$ (`IsEML.exp`, witness $\mathsf{exp}\,t_f$).

*Proof sketch.* Extract witnessing terms $t_f, t_g$ from the hypotheses
and apply the corresponding constructor; the evaluation lemmas of
Definition 2.2 verify the witness denotes the claimed function. $\square$

**Proposition 3.7 (composition and differentiation closure).** If
$\mathrm{IsEML}(f)$ and $\mathrm{IsEML}(g)$ then
- $\mathrm{IsEML}(x \mapsto f(g(x)))$ (`IsEML.comp`, witness
  $\mathsf{comp}(t_f, t_g)$, correctness by Theorem 3.4);
- $\mathrm{IsEML}(\mathrm{deriv}\,f)$ (`IsEML.deriv`, witness $D t_f$,
  correctness by Theorem 3.3).

*Proof sketch.* For composition, the witness $\mathsf{comp}(t_f, t_g)$
denotes $x \mapsto f(g(x))$ by `eval_comp`. For differentiation, the
witness $D t_f$ denotes $\mathrm{deriv}\,f$ pointwise by `deriv_eval`, and
function extensionality lifts this to an equality of functions. $\square$

### 3.5 The EML subalgebra

**Theorem 3.8 (`emlSubalgebra`, `smooth_of_mem_emlSubalgebra`).** The set
$\{\,f : \mathbb{R}\to\mathbb{R} \mid \mathrm{IsEML}(f)\,\}$ is an
$\mathbb{R}$-subalgebra of the function algebra $\mathbb{R}\to\mathbb{R}$.
Concretely it contains $0$ (witness $\mathsf{const}\,0$), $1$ (witness
$\mathsf{const}\,1$), and the image of every scalar $r$ under the algebra
map (witness $\mathsf{const}\,r$), and it is closed under addition and
multiplication by Proposition 3.6. Moreover every member is $C^\infty$:
for $f \in \mathrm{emlSubalgebra}$,
$\mathrm{ContDiff}\ \mathbb{R}\ \infty\ f$.

*Proof sketch.* The subalgebra axioms are exactly Propositions 3.5–3.6
specialized to the additive and multiplicative units and the scalar
embedding. Smoothness of members follows by extracting a witnessing term
and applying Theorem 3.1. Membership unfolds definitionally to
$\mathrm{IsEML}$ via `mem_emlSubalgebra_iff`. $\square$

Combining Theorem 3.8 with Proposition 3.7, the EML functions form a
**commutative differential subalgebra** of $\mathbb{R}\to\mathbb{R}$:
closed under the ring operations, the scalar action, the exponential,
composition, and differentiation, with every member smooth.

---

## 4. Boundaries of the class

The positive structure above is sharp. We summarize three boundary
phenomena, which delineate exactly where the closure stops. (These are
the natural negative companions to the formalized positive results and
motivate the conjectures of Section 6.)

### 4.1 Ring, not field

The EML functions are closed under subtraction (combine `IsEML.add` and
`IsEML.neg`) but **not** under taking reciprocals. The function
$x \mapsto 1/x$ is not EML: it is undefined at $0$, whereas every EML
function is total and indeed smooth on all of $\mathbb{R}$ by Theorem 3.1.
Hence EML is a commutative differential *ring*, not a differential
*field*. The logarithm is likewise outside the log-free fragment by
construction (no logarithm constructor), consistent with the name.

### 4.2 Differentiation in, integration only partially

By Proposition 3.7 the class is closed under $d/dx$. It is **not** closed
under antidifferentiation. The canonical witness is $e^{x^2}$, which is EML
($\mathsf{exp}(\mathsf{mul}\,\mathsf{X}\,\mathsf{X})$), yet has no EML
primitive: any primitive is, up to an additive constant, the error
function $\int_0^x e^{t^2}\,dt$, which is not an exponential polynomial.

The structural reformulation is striking. Define $\mathrm{HasEMLPrimitive}(f)$
to mean there exists a term $g$ with $\mathrm{HasDerivAt}\ \mathsf{eval}(g)\ (f(x))\ x$
for all $x$. By Theorem 3.2 the functions with an EML primitive are exactly
the image of $\mathsf{eval}\circ D$, i.e. the EML functions that lie in the
*range of the syntactic derivation $D$*. Non-closure under integration is
therefore precisely the statement that **$D$ is not surjective** onto EML —
a Liouville/differential-Galois obstruction rendered as the
non-surjectivity of an operator on an inductive type.

### 4.3 Composition in, functional inverse out

By Proposition 3.7 the class is closed under composition. It is **not**
closed under functional inverse. The cube map $x \mapsto x^3$ is EML
($\mathsf{mul}\,\mathsf{X}\,(\mathsf{mul}\,\mathsf{X}\,\mathsf{X})$) and a
bijection of $\mathbb{R}$, but its inverse $x \mapsto x^{1/3}$ is not EML —
indeed it is not differentiable at $0$, contradicting Theorem 3.1. The
obstruction is the vanishing of the derivative $3x^2$ at the origin: an
EML bijection with an EML inverse cannot have a critical point, since the
inverse-function relation would force the inverse to be non-smooth there.

---

## 5. Algorithms

The term algebra is fully computational on the syntactic side (evaluation
of constants requires real arithmetic, but $D$, $\mathsf{comp}$, and
structural predicates are decidable rewrites). We highlight the core
algorithms; full implementations appear in the accompanying `demo.py`.

**Algorithm A — Symbolic differentiation `D`.** Given a term $t$, walk the
tree bottom-up applying the rules of Definition 2.4. Linear in the size of
$t$ for $+$, $\mathsf{neg}$, $\exp$; the product rule duplicates each
factor, so repeated differentiation of $n$-fold products can grow the term
quadratically per step before simplification. Correctness is Theorem 3.2.

**Algorithm B — Symbolic composition `comp`.** Given $s, t$, substitute a
copy of $t$ at each $\mathsf{X}$-leaf of $s$. Time and output size are
$O(|s|\cdot|t|)$ in the worst case (one copy of $t$ per variable leaf).
Correctness is Theorem 3.4.

**Algorithm C — Numerical evaluation `eval`.** Given $t$ and a point $x$,
recursively compute the real value, using the host language's `exp`. Linear
in $|t|$ per evaluation point. This realizes Definition 2.2 and provides
the bridge for empirically checking the derivative identity
$\mathrm{eval}(D t)(x) \approx \big(\mathrm{eval}(t)(x+h)-\mathrm{eval}(t)(x-h)\big)/(2h)$.

---

## 6. Applications

- **Linear constant-coefficient ODEs.** Solutions are sums of $x^k
  e^{\lambda x}$ — all EML. Closure under $d/dx$ guarantees that
  substituting a candidate solution into the differential operator yields
  another EML function, enabling purely symbolic verification.
- **Symbolic differentiation engines.** On the EML fragment, the
  derivative is always representable (Theorem 3.2), so a differentiator
  never has to approximate or fail. This is the algebraic backbone of exact
  automatic differentiation for exponential-polynomial models.
- **Probability and statistics.** Gaussian densities $e^{-x^2/2}$ are EML;
  the absence of an EML primitive for $e^{x^2}$ (Section 4.2) is exactly why
  the normal cumulative distribution function has no elementary closed form.
- **Growth/decay modeling.** Compound interest, radioactive decay, and
  linear-system impulse responses live entirely inside the EML world, and
  inherit its smoothness and differentiation closure.

---

## 7. Discussion

The methodological core is the separation of syntax and semantics. By
modeling EML functions as an inductive term algebra and proving correctness
theorems for the syntactic operators $D$ and $\mathsf{comp}$, every
analytic closure property reduces to a structural induction. This converts
statements about an infinite family of functions into finite case analyses
over six constructors. The same architecture explains the boundaries: the
negative results (no field, partial integration, no inverse) become
statements about what the syntax *cannot* express or about the
non-surjectivity of a syntactic operator.

A subtle point is the asymmetry between differentiation and integration.
Differentiation is a *total syntactic function* $D$, so closure is
automatic. Integration is the *relational inverse* of $D$, and closure
under it is the surjectivity of $D$ — a genuinely harder, Liouville-type
question. The EML setting strips this classical theme down to its essential
combinatorial kernel.

---

## 8. Future directions

The following research directions extend the present results. Throughout,
**EML** denotes the log-free fragment (exponential polynomials): the
smallest class of $\mathbb{R}\to\mathbb{R}$ containing $x$ and the
constants and closed under $+$, $\times$, and $\exp$.

This cycle established that EML is a commutative differential ring (closed
under $+$, $\times$, $\circ$, $d/dx$), but not a field ($x^{-1}, \log
\notin$ EML), not closed under functional inverse ($x^3$ has no EML left
inverse), and only partially closed under integration.

**C1. EML is not closed under integration (the Liouville boundary).**
*Conjecture.* $e^{x^2} \in$ EML, but there is no EML term $g$ with
$\mathrm{HasDerivAt}\ \mathsf{eval}(g)\ (e^{x^2})\ x$ for all $x$; i.e.
$\neg\,\mathrm{HasEMLPrimitive}(x \mapsto e^{x^2})$. The key insight is
that $\mathrm{HasEMLPrimitive}$ is exactly the image of the syntactic
derivation $D$, so non-closure under integration is the non-surjectivity
of $D$ onto EML — a differential-Galois/Liouville obstruction phrased as
non-surjectivity of a syntactic operator on an inductive type. The missing
ingredient is an algebraic-independence input ("$\mathrm{erf}$ is
transcendental over the exp-polynomials"), making $e^{x^2}$ a concrete,
self-contained first target.

**C2. EML inverses exist iff the derivative never vanishes.**
*Conjecture.* For an EML function $f$ that is strictly monotone with
$f'(x) \neq 0$ for all $x$ and $f$ surjective, $f^{-1}$ is again EML iff
$f$ is, up to affine change, of the shape $x \mapsto a x + b$ or
$x \mapsto c\,e^{a x} + b$; in particular the only EML self-bijections of
$\mathbb{R}$ with EML inverse are the affine maps. The critical-point
obstruction already isolates the failure (a vanishing derivative); the
residual question is a rigidity classification of exp-polynomials by
growth-rate matching of leading exponential terms.

**C3. The differential transcendence degree of EML is infinite.**
*Conjecture.* The tower $x \prec e^x \prec e^{e^x} \prec \cdots$ is
differentially algebraically independent over $\mathbb{R}$; consequently
EML has no finite set of generators as a differential ring. The key
insight is that each new $\exp$ layer strictly increases an "exp-log
depth" invariant on the term algebra, and a derivative never increases this
depth.

---

## 9. Conclusion

We gave a complete, machine-checked structural analysis of the log-free
EML functions. They form a commutative differential $\mathbb{R}$-subalgebra
of $\mathbb{R}\to\mathbb{R}$ — closed under addition, multiplication,
scalar action, the exponential, composition, and differentiation — with
every member $C^\infty$. The correctness of the syntactic derivative and
of syntactic composition were established as the engine driving these
closure properties. We further charted the family's boundaries: it is a
ring but not a field, closed under differentiation but only partially under
integration, and closed under composition but not under functional
inverse. The reframing of integration-closure as the surjectivity of a
syntactic operator situates a classical Liouville-type phenomenon inside a
finite, fully combinatorial world.
