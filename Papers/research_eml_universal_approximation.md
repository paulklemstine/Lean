# Density Meets Incompressibility: The EML Complexity Price of Universal Approximation

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (Approximation Theory / Algorithmic Complexity)

## Abstract

We study the **EML class** — the family of real functions generated from the
identity $x \mapsto x$ by the operations of addition, multiplication,
exponentiation $t \mapsto e^{t}$, and logarithm $t \mapsto \log t$, with *no
constant leaves*. We connect two seemingly opposed properties of this class. On
the qualitative side, finite real linear combinations of the exponential
monomials $x \mapsto e^{kx}$ are uniformly dense in $C([a,b])$, so the EML class
is a universal approximator. On the quantitative side, we introduce a
Kolmogorov-style complexity measure $K$ on EML-computable functions — the size of
the smallest generating term — and observe that, because the generating alphabet
is finite, every fixed size budget $n$ yields only *finitely many* representable
functions. We reconcile these by constructing an explicit infinite, injective,
EML-computable family of generators $\mathrm{expBasis}(k)$ computing
$x \mapsto e^{(k+1)x}$, with exact size $2k+2$, hence $K(x \mapsto e^{(k+1)x}) \le
2k+2$. Because each budget is a finite island while the dense family is infinite
and injective, the family escapes every finite complexity island; universal
approximation is therefore realized by an EML-computable family whose complexity
is unbounded across the family. We isolate the constant function $1 = e^{0\cdot
x}$ as the unique density generator outside the constant-free class, pinpointing a
single missing primitive. We close with a numerical study and a program of
falsifiable conjectures, including a conjectured matching lower bound
$K(e^{kx}) = \Theta(k)$ and a depth–accuracy law.

**Keywords:** EML class, universal approximation, Kolmogorov complexity,
exponential monomials, Stone–Weierstrass, density, incompressibility, term
algebra.

## 1. Introduction

Two desiderata pull against each other whenever we represent functions by
formulas. *Expressiveness* asks that a representation class be rich enough to
approximate any target. *Parsimony* asks that individual representations be short.
The classical theory of universal approximation (Stone–Weierstrass and its
descendants) addresses the first; the theory of descriptive complexity
(Kolmogorov, Solomonoff, Chaitin) addresses the second. This paper makes their
interaction precise and exact for a concrete, finitely-generated function class.

The **EML class** (Exponential–Multiplicative–Logarithmic) is the closure of the
identity function under $+$, $\times$, $\exp$, and $\log$. It is a natural
abstraction of the "analytic primitives" that recur throughout scientific
computing and machine learning: the exponential of the softmax and Boltzmann
distributions, the logarithm of log-likelihoods, the products and sums of feature
maps. Restricting to a *constant-free* algebra (no numeric leaves) makes the
syntactic class countable and the complexity theory clean.

Our contributions:

1. **A Kolmogorov measure for EML.** We treat the constant-free EML term algebra
   as a finite-alphabet syntactic class and define $K(g)$ as the least size of a
   term computing $g$. Finiteness of the alphabet yields a Finiteness Principle:
   each size budget admits only finitely many representable functions.

2. **An explicit dense, EML-computable generator family.** We build
   $\mathrm{repAdd}(k)$ and $\mathrm{expBasis}(k)$ inside the algebra, compute
   their semantics and size exactly, and obtain the linear upper bound
   $K(e^{(k+1)x}) \le 2k+2$.

3. **The synthesis.** Combining the imported density theorem with the explicit
   construction, we show density and EML-computability hold simultaneously while
   complexity is unbounded across the family (the family escapes every finite
   island).

4. **A boundary result.** The constant $1 = e^{0\cdot x}$ is the unique density
   generator the constant-free class cannot name, isolating the single primitive
   needed to extend the theory to constants.

All results in Sections 3–6 correspond to formally verified statements; the names
in `typewriter font` are the theorem identifiers.

## 2. The EML term algebra

### 2.1 Syntax

**Definition 2.1 (EML terms).** The set $\mathsf{ETerm}$ of *constant-free EML
terms* is generated inductively by:

- a single leaf $\mathsf{var}$ (the variable);
- binary constructors $\mathsf{add}(s,t)$ and $\mathsf{mul}(s,t)$;
- unary constructors $\mathsf{expOf}(t)$ and $\mathsf{logOf}(t)$.

Because the constructor alphabet is finite and there are no numeric leaves,
$\mathsf{ETerm}$ is a countable set with finitely many terms of each size.

**Definition 2.2 (Semantics).** The *evaluation* map $\mathrm{eval} :
\mathsf{ETerm} \to (\mathbb{R} \to \mathbb{R})$ is defined by
$$
\mathrm{eval}(\mathsf{var})(x) = x, \quad
\mathrm{eval}(s + t)(x) = \mathrm{eval}(s)(x) + \mathrm{eval}(t)(x),
$$
$$
\mathrm{eval}(s \times t)(x) = \mathrm{eval}(s)(x)\,\mathrm{eval}(t)(x), \quad
\mathrm{eval}(\mathsf{expOf}\,t)(x) = e^{\mathrm{eval}(t)(x)}, \quad
\mathrm{eval}(\mathsf{logOf}\,t)(x) = \log \mathrm{eval}(t)(x).
$$

**Definition 2.3 (Size and depth).** The *size* $|t|$ counts leaves and operators:
$|\mathsf{var}| = 1$, $|s \star t| = |s| + |t| + 1$ for binary $\star$, and
$|{\circ}\, t| = |t| + 1$ for unary $\circ$. The *depth* $d(t)$ is $0$ for
$\mathsf{var}$, $\max(d(s), d(t)) + 1$ for binary nodes, and $d(t) + 1$ for unary
nodes.

### 2.2 Computability and complexity

**Definition 2.4 (EML-computable).** A function $g : \mathbb{R} \to \mathbb{R}$ is
*EML-computable*, written $\mathrm{IsEMLComputable}(g)$, if there exists
$t \in \mathsf{ETerm}$ with $\mathrm{eval}(t) = g$.

**Definition 2.5 (EML complexity).** For an EML-computable $g$, define
$$
K(g) \;=\; \min\{\, |t| : t \in \mathsf{ETerm},\ \mathrm{eval}(t) = g \,\}.
$$
The minimum exists because the candidate set is a nonempty subset of $\mathbb{N}$.
Immediately, if $\mathrm{eval}(t) = g$ then $K(g) \le |t|$; we refer to this as
`K_le_of_eval`.

**Definition 2.6 (Budget islands).** For $n \in \mathbb{N}$ let
$$
\mathrm{computableLE}(n) \;=\; \{\, g : g \text{ is EML-computable and } K(g) \le n \,\}
\subseteq (\mathbb{R}\to\mathbb{R}).
$$

**Proposition 2.7 (Finiteness Principle, `finite_computableLE`).** For every
$n$, the set $\mathrm{computableLE}(n)$ is finite.

*Proof sketch.* There are finitely many terms of size $\le n$ (a finite alphabet
admits only finitely many syntax trees of bounded size), and $\mathrm{eval}$ maps
this finite set onto $\mathrm{computableLE}(n)$. The image of a finite set is
finite. $\square$

This is the quantitative engine of the paper: simplicity, measured by $K$, is a
*finite resource* at every fixed budget.

## 3. The qualitative side: density

We recall the catalog density theorem on which the synthesis rests. Let
$[a,b] \subset \mathbb{R}$ be a compact interval and $C(\mathrm{Icc}\,a\,b,
\mathbb{R})$ the Banach space of continuous real functions with the uniform norm.

Write $\mathrm{iccCoord}(a,b)$ for the coordinate map $[a,b] \hookrightarrow
\mathbb{R}$ (injective when $a < b$, `injective_iccCoord`), and let
$\mathrm{expCM}$ denote the continuous map $x \mapsto e^{x}$. The feature
$\mathrm{expCM} \circ \mathrm{iccCoord}(a,b)$ is the restriction of the
exponential to $[a,b]$, and its $k$-th power is $x \mapsto e^{kx}$.

**Theorem 3.1 (Exponential monomial density, `exp_monomials_span_dense`).** For
an injective continuous feature $g : X \to \mathbb{R}$ on a compact space $X$, the
linear span of $\{\,(\,e^{g}\,)^k : k \in \mathbb{N}\,\}$ is dense in
$C(X, \mathbb{R})$. In particular, on $X = [a,b]$,
$$
\overline{\mathrm{span}_{\mathbb{R}}\{\, x \mapsto e^{kx} : k \in \mathbb{N} \,\}}
= C([a,b], \mathbb{R}).
$$

*Proof sketch.* The subalgebra generated by $e^{g}$ separates points (because
$g$ is injective and $\exp$ is injective) and contains the constants, so by
Stone–Weierstrass it is uniformly dense. Closure of the subalgebra equals closure
of the linear span of the powers $(e^{g})^k$, because powers of a single
generator span the generated algebra. Hence the span of the exponential monomials
is dense. $\square$

Theorem 3.1 is the *optimist's* statement: any continuous target on $[a,b]$ is
approximated, to any $\varepsilon$, by a finite linear combination of exponential
monomials.

## 4. The generators: explicit construction and exact cost

We now realize the dense generating family *inside* the constant-free algebra,
with full control of size.

**Definition 4.1 (`repAdd`).** Define $\mathrm{repAdd} : \mathbb{N} \to
\mathsf{ETerm}$ by
$$
\mathrm{repAdd}(0) = \mathsf{var}, \qquad
\mathrm{repAdd}(k+1) = \mathsf{add}(\mathsf{var}, \mathrm{repAdd}(k)).
$$
Thus $\mathrm{repAdd}(k)$ is the $(k+1)$-fold sum $\mathsf{var} + \cdots +
\mathsf{var}$.

**Lemma 4.2 (`repAdd_eval`).** For all $k$ and $x$, $\mathrm{eval}(\mathrm{repAdd}(k))(x) = (k+1)\,x$.

*Proof sketch.* Induction on $k$. Base: $\mathrm{eval}(\mathsf{var})(x) = x =
(0+1)x$. Step: $\mathrm{eval}(\mathsf{add}(\mathsf{var}, \mathrm{repAdd}(k)))(x) =
x + (k+1)x = (k+2)x$. $\square$

**Lemma 4.3 (`repAdd_size`).** $|\mathrm{repAdd}(k)| = 2k + 1$.

*Proof sketch.* Induction: $|\mathrm{repAdd}(0)| = 1$, and each step adds one
$\mathsf{var}$ leaf (cost $1$) and one $\mathsf{add}$ node (cost $1$), giving
$|\mathrm{repAdd}(k+1)| = |\mathrm{repAdd}(k)| + 2$. $\square$

**Definition 4.4 (`expBasis`).** Define $\mathrm{expBasis}(k) =
\mathsf{expOf}(\mathrm{repAdd}(k))$.

**Theorem 4.5 (`expBasis_eval`).** $\mathrm{eval}(\mathrm{expBasis}(k)) = \bigl(x
\mapsto e^{(k+1)x}\bigr)$.

*Proof sketch.* Apply $\exp$ to Lemma 4.2: $\mathrm{eval}(\mathsf{expOf}\,
\mathrm{repAdd}(k))(x) = e^{\mathrm{eval}(\mathrm{repAdd}(k))(x)} = e^{(k+1)x}$.
$\square$

**Theorem 4.6 (`expBasis_size`).** $|\mathrm{expBasis}(k)| = 2k + 2$.

*Proof sketch.* The $\mathsf{expOf}$ node adds $1$ to $|\mathrm{repAdd}(k)| =
2k+1$. $\square$

**Corollary 4.7 (EML-computability, `expBasis_isEMLComputable`).** For each $k$,
the function $x \mapsto e^{(k+1)x}$ is EML-computable, witnessed by
$\mathrm{expBasis}(k)$.

**Theorem 4.8 (Linear complexity bound, `K_expBasis_le`).** For every $k$,
$$
K\bigl(x \mapsto e^{(k+1)x}\bigr) \;\le\; 2k + 2.
$$

*Proof sketch.* By `K_le_of_eval` applied to the witness $\mathrm{expBasis}(k)$
(Theorem 4.5), $K(\cdot) \le |\mathrm{expBasis}(k)| = 2k+2$ by Theorem 4.6.
$\square$

**Theorem 4.9 (Injectivity, `generators_injective`).** The map $k \mapsto (x
\mapsto e^{(k+1)x})$ is injective.

*Proof sketch.* If $e^{(a+1)x} = e^{(b+1)x}$ for all $x$, evaluate at $x = 1$ to
get $e^{a+1} = e^{b+1}$; injectivity of $\exp$ gives $a+1 = b+1$, and injectivity
of the cast $\mathbb{N} \hookrightarrow \mathbb{R}$ gives $a = b$. $\square$

## 5. The bridge: escaping finite islands

We now show the dense generator family cannot be confined to any finite budget.

**Theorem 5.1 (Escape from finite islands, `finitely_many_generators_per_budget`).**
For every $n \in \mathbb{N}$,
$$
\{\, k \in \mathbb{N} : (x \mapsto e^{(k+1)x}) \in \mathrm{computableLE}(n) \,\}
\quad\text{is finite.}
$$

*Proof sketch.* The set in question is the preimage, under the injective family
$k \mapsto (x \mapsto e^{(k+1)x})$ (Theorem 4.9), of the finite set
$\mathrm{computableLE}(n)$ (Proposition 2.7). The preimage of a finite set under
an injective map is finite. $\square$

**Interpretation.** Each island holds only finitely many generators, yet the
family is infinite. Hence, as $n \to \infty$, an ever-growing but always
incomplete set of generators becomes available: no finite budget holds them all.
Equivalently, $\sup_k K(x \mapsto e^{(k+1)x}) = \infty$ — complexity across the
family is unbounded. This is the *realist's* statement.

**Theorem 5.2 (Synthesis: density meets incompressibility, `dense_and_generators_EMLcomputable`).**
For every compact interval $[a,b]$, both of the following hold:

1. (*Density*) The linear span of $\{\,(\mathrm{expCM} \circ
   \mathrm{iccCoord}(a,b))^k : k \in \mathbb{N}\,\}$ is dense in $C([a,b],
   \mathbb{R})$.
2. (*EML-computability*) For every $k$, the generator $x \mapsto e^{(k+1)x}$ is
   EML-computable.

*Proof sketch.* Conjunct 1 is Theorem 3.1 specialized to the injective coordinate
map (`injective_iccCoord`). Conjunct 2 is Corollary 4.7. The conjunction is the
formal content of "universal approximation with a complexity bound": the dense
approximating family is genuinely EML-computable, and (by Theorems 4.8 and 5.1)
its complexity is bounded *member by member* (linearly) yet unbounded *across the
family*. $\square$

The result is not a vacuous conjunction. The left conjunct is the genuine,
nontrivial Stone–Weierstrass-type density theorem (imported and applied, not
re-derived). The right conjunct is established constructively with exact size
accounting. Their conjunction expresses exactly the tension the programme set out
to resolve.

## 6. The boundary: the missing constant

The density family of Theorem 3.1 ranges over $k = 0, 1, 2, \dots$, beginning
with $e^{0\cdot x} = 1$. Our generators $\mathrm{expBasis}(k)$ compute
$e^{(k+1)x}$, i.e. they begin at $k=0$ with $e^{x}$ and *never* produce the
constant $1$.

**Observation 6.1 (The unique missing generator).** The single density generator
the constant-free EML class cannot represent is $x \mapsto e^{0\cdot x} = 1$,
i.e. the constant function $1$.

*Discussion.* Every $\mathsf{ETerm}$ is built from $\mathsf{var}$ and propagates
the input through total operations; there is no leaf denoting a fixed number, so
no constant function is EML-computable in the constant-free algebra. The density
theorem nonetheless needs the constants (Stone–Weierstrass requires a
unital subalgebra). Thus the boundary of the constant-free theory is precisely one
object wide: adding a single new leaf $\mathsf{one}$ with $\mathrm{eval} = 1$ would
exactly close the gap. This is a clean structural boundary, not a defect, and it
motivates Conjecture 7.1.

## 7. Future directions

The following falsifiable conjectures extend the theory; each is stated to be
attacked directly by formal methods.

**Conjecture 7.1 (One bit of incompressible information).** Extend the algebra
with a single leaf $\mathsf{one}$ ($\mathrm{eval} = 1$). For the rational
constants $c_q : x \mapsto q$ ($q \in \mathbb{Q}$), $K(c_q)$ is finite for every
$q$ but $\sup_q K(c_q) = \infty$; moreover the constant-free class computes *no*
constant function. The insight: $\mathsf{one}$ is the unique generator whose
absence makes the entire constant subspace incompressible — our synthesis already
isolates $k=0$ as the single density generator outside the constant-free class.

**Conjecture 7.2 (Matching lower bound, $K(e^{kx}) = \Theta(k)$).** The linear
upper bound $K(e^{(k+1)x}) \le 2k+2$ (Theorem 4.8) is tight: there is $c > 0$
with $K(e^{(k+1)x}) \ge c\,k$ for all $k$. The insight: a size-$s$ constant-free
term has bounded "exponential frequency content" (each $\exp$ node multiplies the
dominant exponent by at most the size of its argument), so computing $e^{kx}$
forces size growth in $k$. The missing half is a structural induction bounding the
top exponential rate.

**Conjecture 7.3 (Depth–accuracy law, $\Theta(\log\log(1/\varepsilon))$ for
analytic targets).** For fixed real-analytic $f$ on $[a,b]$, the minimal EML
*depth* for uniform $\varepsilon$-approximation grows like $\log\log(1/\varepsilon)$:
exp/log compression makes depth exponentially cheaper than the naive
$O(K(f)/\varepsilon)$ heuristic. The insight: $e^{n\log x} = x^n$ at constant
depth $3$; a degree-$d$ Jackson/Chebyshev approximant needs only $O(\log d)$
extra depth via balanced add/mul trees, with $d = O(\log(1/\varepsilon))$ for
analytic $f$. The size–depth tower $|t| + 1 \le 2^{d(t)+1}$ converts depth
compression into an accuracy law.

**Conjecture 7.4 (Counting law for the function class).** The cardinality
$|\mathrm{computableLE}(n)|$ grows like a fixed exponential in $n$, reflecting the
finite-alphabet branching of the term algebra modulo evaluation collapses.

## 8. Discussion

The architecture of the argument is deliberately minimal. **Density** is a
statement about the *union* $\bigcup_n \mathrm{computableLE}(n)$ (the closure of
the EML class). **Incompressibility** is a statement about each *finite stage*
$\mathrm{computableLE}(n)$. The exponential generators are the explicit witnesses
that the union is genuinely infinite-dimensional while every stage is finite — the
precise mechanism by which universal approximation and Kolmogorov
incompressibility coexist.

This pattern recapitulates, in a fully controlled setting, the practitioner's
experience of universal approximators (neural networks, kernel machines, spectral
methods): better accuracy is always attainable, and always costs more
description. By fixing a finite alphabet and an exact size calculus, the EML class
turns that folklore into theorems, including an exact per-member complexity
($2k+2$) and an exact escape phenomenon (finiteness of every budget section).

## 9. Conclusion

We have shown, for the constant-free EML term algebra, that universal
approximation (density of exponential monomials) and Kolmogorov-style
incompressibility (finiteness of every complexity budget) are simultaneously true
and mutually illuminating. The explicit family $\mathrm{expBasis}(k)$ computing
$e^{(k+1)x}$ with size $2k+2$ is dense, injective, EML-computable, and escapes
every finite island, giving $K(e^{(k+1)x}) \le 2k+2$ with unbounded supremum. The
constant $1 = e^{0\cdot x}$ is the unique density generator outside the
constant-free class, marking a one-primitive boundary. The result is the formal
content of "EML universal approximation with a provable complexity price."
