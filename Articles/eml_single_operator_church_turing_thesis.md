# One Transcendental Gate, an Entire Exp–Log Language

## How a two-input operation can serve as an exact instruction set for a broad family of real formulas

Modern computing is built on a startling kind of compression. A processor may run a weather model, decode a photograph, or simulate a molecule, yet beneath these varied tasks lies a small instruction set. This raises a mathematical version of the same question: how few primitive operations are needed to express a useful language of real-valued functions?

Consider the two-input operation

$$
D(a,b)=e^a-\log b.
$$

Allow it to coexist with real constants, variables, addition, multiplication, negation, and reciprocal. At first sight, $D$ looks oddly specific: an exponential on its first input, a logarithm on its second, and subtraction between them. Yet this single gate contains enough structure to reproduce every finite formula assembled from exponentials, logarithms, constants, variables, and the ordinary field operations. The conversion is exact, not approximate.

There is a parallel result for the product gate

$$
P(a,b)=e^a\log b.
$$

It, too, can serve as the sole transcendental primitive for the same formula language. These statements concern finite symbolic expressions; they do not imply that every computable real function can be written in this language. In particular, they do not establish exact formulas for sine or cosine. That boundary is as important as the theorem itself.

## A language made of trees

A mathematical formula can be viewed as a tree. Leaves contain constants such as $2$ or variables such as $x_0$. Internal nodes perform operations. Our source language permits

$$
+,\quad \times,\quad -,\quad (\cdot)^{-1},\quad \exp,\quad \log.
$$

Thus

$$
F(x,y)=e^{x+y}+\frac{1}{3-\log y}
$$

is a source expression. It is finite because its syntax tree has finitely many nodes.

To avoid hidden domain qualifications, take reciprocal and logarithm as total real operations: $0^{-1}=0$, $\log 0=0$, and for nonzero real $x$, $\log x$ means $\log |x|$. On positive inputs this is the usual logarithm. This convention is not essential to the central identities, but it lets every expression denote a real number at every real input.

A target language keeps the constants, variables, and field operations but removes separate exponential and logarithm nodes. Its only transcendental node is $D$. The Exact Compilation Theorem says that every source tree can be translated into such a target tree without changing its value at any input.

## The two identities that power the compiler

The heart of the result fits in two lines. Because $\log 1=0$,

$$
D(a,1)=e^a-\log 1=e^a.
$$

Because $e^0=1$,

$$
1-D(0,b)=1-\bigl(e^0-\log b\bigr)=\log b.
$$

So an exponential node can be replaced by $D(a,1)$, while a logarithm node can be replaced by $1-D(0,b)$. Everything else is copied recursively.

For the example above, the translation is

$$
D(x+y,1)+\frac{1}{3-\bigl(1-D(0,y)\bigr)}.
$$

No numerical approximation has entered. The translated expression agrees with the original for every $x$ and $y$, including exceptional inputs under the total conventions.

Why does a local replacement prove a global statement? Because formulas are trees. At a leaf, translation changes nothing. If translated children preserve their values, then addition, multiplication, negation, and reciprocal preserve the equality of the parent values. At an exponential or logarithm node, the two identities above finish the step. Induction over the finite tree therefore proves the following.

**Exact Compilation Theorem.** Every finite real expression formed from constants, variables, addition, multiplication, negation, reciprocal, exponential, and total logarithm has a finite expression with the same value at every real input, formed from constants, variables, field operations, and the single transcendental gate $D(a,b)=e^a-\log b$.

## This is an equivalence, not merely a one-way trick

Every $D$-expression can plainly be expanded back, because

$$
D(a,b)=e^a-\log b.
$$

Replace each $D$ node by its defining exponential-minus-logarithm expression and recurse through the tree. This gives the converse preservation theorem.

**Expressive Equivalence Theorem.** A real function of finitely many variables has a finite expression using constants, field operations, exponential, and total logarithm if and only if it has a finite expression using constants, field operations, and $D$ as its only transcendental primitive.

Compiling an expanded $D$-expression may produce a different-looking syntax tree, but its value remains unchanged at every input. This is an extensional retraction: expand, then compile, and the observable function is the same.

The distinction between syntax and meaning matters. Two circuits can be shaped differently and still compute identical functions. The theorem promises semantic equality, not identical typography.

## The product gate works too

The operation originally motivating the single-gate question is often written as a product:

$$
P(a,b)=e^a\log b.
$$

It contains logarithm immediately, since

$$
P(0,b)=e^0\log b=\log b.
$$

It also contains exponential. Choose the constant $e=e^1$. Since $\log(e)=1$,

$$
P(a,e)=e^a\log(e)=e^a.
$$

These identities yield another recursive compiler: replace $\log b$ by $P(0,b)$ and $e^a$ by $P(a,e)$. Again, field-operation nodes are copied.

**Product-Primitive Compilation Theorem.** Every finite exp–log–field expression can be translated exactly into a finite expression whose only transcendental operation is $P(a,b)=e^a\log b$.

The difference and product gates achieve the same source-language coverage through different algebraic mechanisms. The difference gate extracts exponential by neutralizing logarithm at $1$ and extracts logarithm by subtracting from $1$. The product gate extracts logarithm by setting the exponential factor to $1$, and extracts exponential by setting the logarithmic factor to $1$.

## Polynomials as a transparent test case

Polynomials need no transcendental operation at all, but they provide an ideal test of the recursive machinery. Given coefficients $a_0,a_1,\ldots,a_m$ in ascending order, define the Horner value

$$
H_x([a_0,a_1,\ldots,a_m])
=a_0+x\bigl(a_1+x(\cdots+xa_m)\cdots\bigr).
$$

Recursively, the empty coefficient list has value $0$, and

$$
H_x(a::A)=a+xH_x(A).
$$

Induction on the coefficient list proves that this is precisely

$$
a_0+a_1x+\cdots+a_mx^m.
$$

Likewise, the recursively built monomial expression computes $x^m$: start with $1$ at exponent $0$, then multiply by $x$ at each successor step.

**Polynomial Representation Theorem.** Every univariate real polynomial presented by a finite coefficient list has an exact finite representation in both the difference-gate and product-gate languages.

This result may sound modest, since field operations already express polynomials. Its role is illustrative: it gives a concrete family whose source syntax, numerical evaluation, and target compilation can all be watched step by step. Horner form also evaluates a degree-$m$ polynomial using $m$ multiplications and $m$ additions, rather than separately computing every power.

## Why “one operator” does not mean one physical neuron

The phrase “single operator” can mislead. A compiled expression may contain many occurrences of $D$ or $P$, arranged in a finite tree and combined with field operations. The theorem says there is one *type* of transcendental gate, not that every function is computed by one gate occurrence.

Nor is the statement a numerical-stability theorem. Algebraically equal formulas can behave differently in floating-point arithmetic: subtraction can amplify cancellation, exponentials can overflow, and logarithms near zero are sensitive. Exact expressibility is a prerequisite for compilation, but efficient and stable implementation is a separate engineering problem.

Still, the instruction-set viewpoint has practical resonance. Specialized hardware often supports a small menu of nonlinear operations. Symbolic regression seeks compact formulas from data. Neural architectures ask which nonlinearities generate rich classes under composition. In each setting, a semantics-preserving compiler can separate two questions: what can be expressed in principle, and how well can it be evaluated in practice?

## The frontier: sine, computability, and approximation

The boldest possible thesis would claim that every computable real function has an exact finite expression of this kind. The results above do not establish that thesis. They establish a precise equivalence between two finite expression languages.

The gap appears immediately with trigonometry. Sine and cosine were not part of the source grammar, and familiar complex identities such as

$$
\sin x=\frac{e^{ix}-e^{-ix}}{2i}
$$

use complex constants and complex exponentials. They do not automatically produce a finite formula over the real exp–log field.

There is good structural reason to suspect exact global non-representability. The zeros of sine form the infinite discrete set

$$
\{k\pi:k\in\mathbb Z\}.
$$

By contrast, one expects one-variable functions definable using the ordered real field and real exponential to have tame zero sets, built from finitely many points and intervals. Turning that expectation into a theorem requires substantial theory beyond the elementary compiler, but it suggests a falsifiable dividing line.

Approximation is a different story. On a compact interval, polynomials approximate continuous functions, so the polynomial representation result points toward approximating sine and cosine arbitrarily closely with single-gate expressions. That does not supply one exact finite expression valid on all real numbers; it supplies a family of expressions whose accuracy improves as their size grows.

## A small theorem with a large lesson

The deepest lesson is not that exponential and logarithm mysteriously vanish. They remain present, fused inside a gate. The lesson is that the boundary between a language with two named transcendental operations and one with a single combined operation can be erased by exact, recursive translation.

The final picture is sharp:

1. The difference gate $D(a,b)=e^a-\log b$ exactly generates every finite exp–log–field expression.
2. The resulting single-gate language is expressively equivalent to the original language.
3. The product gate $P(a,b)=e^a\log b$ also exactly generates the same source language.
4. Monomials and coefficient-list polynomials receive explicit representations, with Horner evaluation providing a concrete algorithm.
5. None of these results proves an exact expression for sine, cosine, or every computable real function.

That combination of power and restraint is what makes the result useful. It gives a complete compiler theorem for a clearly defined language, while marking the next frontier rather than pretending it has already been crossed.