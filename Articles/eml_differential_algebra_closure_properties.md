# A Calculus That Stays Inside Its Own Language

## How exponential–logarithmic formulas survive algebra, composition, and differentiation

A formula is more than a way to obtain a number. It is also a language: a compact vocabulary for describing how quantities depend on one another. In science and engineering, one especially useful vocabulary starts with real constants and a variable, then permits addition, multiplication, reciprocals, exponentials, and logarithms. It contains familiar expressions such as $e^{x^2}$, $x/(1+x^2)$, and $\u200blog(1+e^x)$. Call these **rational exponential–logarithmic expressions**, or EML expressions for short.

The natural question is whether ordinary mathematical operations force us to leave this language. If two models are written as EML expressions, can we add or multiply them and remain in the same class? Can one model be fed into another? Most importantly for calculus, does differentiation preserve the language?

The answer is strikingly robust: algebraic combinations and compositions remain EML, and every EML expression has an EML symbolic derivative wherever the original expression is regular. This creates a self-contained calculus for a broad family of formulas used in growth models, information theory, optimization, and statistical mechanics. Yet the boundary cases are as revealing as the positive results. Total real-valued functions form a ring rather than literally a field; inverse functions require more than the ordinary inverse function theorem to remain representable; and indefinite integration does not come with a universal closure theorem.

## Building the expression language

Begin with constants $c\in\mathbb R$ and the identity expression $x$. If $P$ and $Q$ have already been built, allow

$$
P+Q,\qquad PQ,\qquad P^{-1},\qquad e^P,\qquad \log P.
$$

Repeated use of these constructors generates the whole language. Subtraction and division need not be primitive: they arise from multiplication by $-1$ and reciprocal. For example,

$$
F(x)=\frac{e^{x^2}+3}{1+x^2}
$$

is assembled from $x$, constants, products, sums, an exponential, and a reciprocal.

To discuss every real input uniformly, one may adopt totalized conventions for reciprocal and logarithm. Those conventions make evaluation a function on all of $\mathbb R$, but they do not magically create differentiability at singular points. The calculus therefore carries a **regularity condition**. A reciprocal $1/P$ is regular at $x$ only when $P$ is regular there and $P(x)\ne0$. A logarithm $\log P$ is regular at $x$ only when $P$ is regular there and $P(x)\ne0$. Sums, products, and exponentials inherit regularity from their ingredients.

This distinction between “has a numerical value under a total convention” and “obeys the ordinary differential rule” is essential. It prevents a symbolic calculation from silently crossing a pole or logarithmic singularity.

## The closure engine

The first main result is the **Algebraic and Compositional Closure Theorem**:

> If $f$ and $g$ are represented by rational exponential–logarithmic expressions, then so are $f+g$, $fg$, $-f$, $f-g$, $1/f$, $f/g$, $e^f$, $\log f$, and the composition $f\circ g$.

For algebraic operations, the proof is almost visible in the statement. Place the expression trees for $f$ and $g$ beneath a new addition or multiplication node. Add a reciprocal node to represent $1/f$, an exponential node to represent $e^f$, and so on.

Composition is subtler but equally constructive. Replace every occurrence of the variable in the expression for $f$ by the entire expression for $g$. This operation is called substitution. A structural induction on the expression for $f$ proves the substitution identity

$$
(P[Q/x])(t)=P(Q(t)).
$$

Thus substitution in syntax exactly realizes composition of functions. If

$$
P(x)=e^x+x^{-1}
\quad\text{and}\quad
Q(x)=1+x^2,
$$

then substitution produces

$$
P(Q(x))=e^{1+x^2}+\frac{1}{1+x^2},
$$

still in the same language.

Constants, the identity, addition, negation, and multiplication show that the represented total functions form a subring of all real-valued functions. Reciprocal is also available as an expression-forming operation. Nevertheless, it is misleading to call the resulting set of total functions a field without qualification. The ambient ring of functions has zero divisors: two nonzero functions can have disjoint supports and multiply to the zero function. A literal field statement is more naturally made locally, using germs of functions near a regular point, or by tracking domains explicitly.

## Differentiation without escape

The heart of the theory is a symbolic derivative operator. It uses the familiar rules

$$
(c)'=0,\qquad x'=1,
$$

$$
(P+Q)'=P'+Q',\qquad (PQ)'=P'Q+PQ',
$$

$$
(P^{-1})'=-P'P^{-2},
$$

$$
(e^P)'=P'e^P,\qquad (\log P)'=P'P^{-1}.
$$

Every right-hand side is itself an EML expression. This observation becomes the **Regular Differentiation Closure Theorem**:

> Let $P$ be a rational exponential–logarithmic expression. At every point $x$ where $P$ is regular, the ordinary derivative of the function represented by $P$ equals the value of the symbolic derivative $P'$ at $x$. Consequently, if $P$ is regular at every real point, its derivative is globally represented by an EML expression.

The proof follows the construction of $P$. Constants and the variable give the base cases. At each addition, multiplication, reciprocal, exponential, or logarithm node, the corresponding rule of calculus combines the already-established derivative statements for the children. The nonvanishing clauses in regularity provide exactly the hypotheses needed at reciprocal and logarithm nodes.

Consider

$$
F(x)=e^{x^2}\log(1+x^2).
$$

The expression is regular everywhere because $1+x^2$ never vanishes. Symbolic differentiation gives

$$
F'(x)=2xe^{x^2}\log(1+x^2)
      +e^{x^2}\frac{2x}{1+x^2},
$$

which remains in the language. No new special function appears. The same remains true after any finite sequence of algebraic combinations and compositions, provided regularity is respected at the point of differentiation.

This matters computationally. Automatic differentiation is often described as propagating numerical derivatives through a computation graph. Here the graph itself can be transformed into a new graph representing the derivative. The result can be evaluated, composed again, or differentiated further. In optimization, this supports exact gradient formulas for losses assembled from exponentials and logarithms. In probability, it covers log-likelihoods and log-sum-exp constructions. In growth and decay models, it keeps sensitivity equations inside the original vocabulary.

## Inverses: calculus is not representability

Suppose $g$ is an inverse branch of $f$, so that $f(g(x))=x$ on the branch under consideration. If both functions are differentiable at the corresponding points, differentiating the identity gives

$$
f'(g(x))g'(x)=1.
$$

Therefore the **Inverse-Branch Derivative Theorem** states

$$
g'(x)=\frac{1}{f'(g(x))}.
$$

The orientation of the inverse identity matters: the formula at $x$ uses $f(g(x))=x$. Merely knowing $g(f(x))=x$ is not the same statement on a totalized domain.

There is also an important logical boundary. If an inverse branch $g$ already has an EML representation, then it belongs to the class and the derivative formula above applies under differentiability. The analytic inverse function theorem alone, however, only supplies a local inverse as a function. It does not guarantee that this inverse can be written using a prescribed expression language. Familiar pairs such as $e^x$ and $\log x$ do fit, but a general representability theorem needs extra algebraic or syntactic hypotheses.

## Integration: a one-way door?

Differentiation is algorithmic here; integration is not. There are strong positive cases. Since

$$
\frac{d}{dx}e^x=e^x,
$$

$e^x$ has an EML antiderivative. More generally, if $P$ is globally regular, then its symbolic derivative $P'$ has the EML antiderivative $P$. This is the **Symbolic Antiderivative Theorem**:

> Every expression known to arise as the symbolic derivative of a globally regular EML expression has an EML antiderivative, namely its source expression.

That theorem does not say that every EML expression possesses an EML antiderivative. Symbolic integration asks the reverse problem: given a target expression, recover a source whose derivative it is. The derivative transformation can lose structural clues, and elementary-function integration is famous for genuine obstructions. Establishing a universal negative result requires a precise non-elementary-integrability criterion and an explicit witness. Thus the present conclusion is exact but deliberately limited: integration closure holds for the image of symbolic differentiation and for concrete examples such as $e^x$; unrestricted closure under integration is not established.

## A durable boundary for symbolic models

The deepest lesson is not simply that a list of formulas differentiates nicely. It is that an expression language can be treated as a mathematical object in its own right. Its grammar dictates closure under algebra. Substitution explains composition. A recursively defined derivative, paired with recursively defined regularity, turns the rules of calculus into a theorem that scales to expressions of arbitrary size.

The caveats sharpen the picture. Global total functions supply a convenient ring, while local domains or germs are the right setting for a literal differential field. Inverse differentiation follows from an inverse identity, but inverse representability needs additional structure. Differentiation stays inside the language; arbitrary integration may not.

There is also a practical payoff in transparency. A numerical black box may produce accurate values while concealing why its sensitivities behave as they do. An explicit EML derivative exposes every factor responsible for growth, decay, saturation, or instability. Researchers can inspect singular denominators, locate logarithmic hazards, and reuse the transformed formula in later stages of a model. Because the construction is recursive, the same method applies to a three-line formula or to a large expression assembled by software.

This combination of closure and restraint is useful wherever formulas become pipelines. A model can be assembled, nested, differentiated, and numerically explored without losing its symbolic vocabulary. At the same time, singularities, local inverses, and antiderivatives remain visible rather than being hidden by notation. The result is a compact calculus with clearly marked borders—a language powerful enough to transform itself, and precise enough to say when it cannot promise more.
