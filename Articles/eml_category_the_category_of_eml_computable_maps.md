# The Shape That Parameters Cannot Change

## A small language, a large categorical question

Many scientific formulas are assembled from a surprisingly compact kit: real constants, input variables, addition, multiplication, exponentials, and logarithms. These operations describe growth and decay, likelihoods and partition functions, compound interest and information. Call a finite formula built from this kit an **EML expression**, where EML recalls the two nonlinear operations, exponential and logarithm, that supplement ordinary arithmetic.

At first sight, the collection of all such expressions seems extraordinarily well behaved. One expression can be plugged into another. Several expressions can be bundled into a vector-valued calculation. There are identity calculations that simply return their inputs. These are precisely the ingredients from which category theory builds a world of objects and arrows.

The natural objects here are finite-dimensional real spaces $\mathbb{R}^n$. An arrow from $\mathbb{R}^n$ to $\mathbb{R}^m$ is an ordered list of $m$ finite EML expressions in $n$ variables. The first expression computes the first output coordinate, the second computes the second, and so on. This creates a clean mathematical universe of finite symbolic computations.

A tempting next step is to claim that this universe supports higher-order computation: programs taking programs as inputs, and a universal evaluator from which every EML expression can be recovered by supplying parameters. Category theory packages that ambition in the language of **exponential objects** and **currying**. Yet there is a simple obstruction. A parameter can change what sits at a leaf of a fixed formula tree, but it cannot make the tree grow a new branch.

That observation draws a sharp line between first-order composition, which works perfectly, and higher-order universality, which does not follow from parameter sharing alone.

## Expressions are trees

An EML expression in $n$ variables is constructed recursively. It may be a real constant $c$, one of the variables $x_1,\ldots,x_n$, a sum $a+b$, a product $ab$, an exponential $\exp(a)$, or a logarithm $\log(a)$. Every finite expression therefore has a rooted syntax tree. Constants and variables are leaves; addition and multiplication are binary nodes; exponential and logarithm are unary nodes.

For example,

$$
\exp(x_1x_2+3)
$$

has a top exponential node. Beneath it is an addition node, with a multiplication subtree on one side and the constant $3$ on the other. The expression is not merely a real-valued function. It is a finite recipe with a particular internal shape.

The **size** $|e|$ of an expression $e$ is the number of nodes in its tree. Thus constants and variables have size $1$; binary operations obey

$$
|a+b|=1+|a|+|b|,
\qquad
|ab|=1+|a|+|b|,
$$

and unary operations obey

$$
|\exp(a)|=1+|a|,
\qquad
|\log(a)|=1+|a|.
$$

This modest integer will become the decisive invariant.

Expressions also have numerical meanings. Given an input vector $x\in\mathbb{R}^n$, evaluate constants as themselves, variables as the corresponding coordinates, and operations by their usual real meanings. To make every expression globally defined, logarithm may be treated as a fixed totalized real operation; the structural results below are independent of the particular convention at nonpositive arguments.

## Plugging computations into computations

Suppose $e$ is an expression in variables $y_1,\ldots,y_m$, while $\sigma_1,\ldots,\sigma_m$ are expressions in variables $x_1,\ldots,x_n$. Simultaneous substitution replaces every occurrence of $y_i$ in $e$ by $\sigma_i$. We write the resulting expression as $e[\sigma]$.

The first fundamental result says that syntax and numerical evaluation agree.

**Substitution Semantics Theorem.** For every expression $e$, substitution list $\sigma$, and input $x\in\mathbb{R}^n$,

$$
\operatorname{eval}(e[\sigma],x)
=
\operatorname{eval}\bigl(e,
(\operatorname{eval}(\sigma_1,x),\ldots,
\operatorname{eval}(\sigma_m,x))\bigr).
$$

The proof follows the tree of $e$. It is immediate for constants and variables. At a sum or product, apply the result to both children; at an exponential or logarithm, apply it to the single child. In other words, symbolic plugging-in really is ordinary function composition.

Substitution has two further laws. Replacing every variable by itself leaves an expression unchanged. Moreover, two successive rounds of substitution can be merged into one: substituting $\sigma$ into $e$ and then substituting $\tau$ into the result is the same as first substituting $\tau$ into every member of $\sigma$ and then performing a single substitution into $e$.

These facts yield the category laws. The identity arrow on $\mathbb{R}^n$ is the list $(x_1,\ldots,x_n)$. Composition is substitution coordinate by coordinate. Identity arrows act as identities on both sides, and composition is associative. No numerical approximation is involved: these are exact structural equations between finite recipes.

## Bundling outputs

The same universe also supports pairing. If

$$
f:\mathbb{R}^n\to\mathbb{R}^m
\quad\text{and}\quad
g:\mathbb{R}^n\to\mathbb{R}^k
$$

are represented by lists of expressions, their pairing is the concatenated list

$$
\langle f,g\rangle:\mathbb{R}^n\to\mathbb{R}^{m+k},
\qquad
x\longmapsto (f(x),g(x)).
$$

Pairing is stable under preprocessing.

**Pairing–Composition Theorem.** For every EML program $h:\mathbb{R}^a\to\mathbb{R}^b$,

$$
\langle f,g\rangle\circ h
=
\langle f\circ h,g\circ h\rangle.
$$

The reason is transparent: concatenating output coordinates and then substituting into each coordinate gives the same list as substituting separately and concatenating afterward. This is a key equation behind finite products. It confirms that ordinary multi-output data flow fits naturally into the EML setting.

One should distinguish this established pairing law from a complete construction of categorical products. A full product treatment would also specify the two projections and establish their defining uniqueness law. The present results supply the central computational operation and its compatibility with composition, but they do not silently assume the remaining universal property.

## The dream of one universal template

Higher-order computation asks for more. Given a two-input calculation $F(x,y)$, currying would regard it as a one-input calculation that returns a calculation of $y$. In a Cartesian closed category this is controlled by an exponential object and an evaluation map. Every map $A\times B\to C$ corresponds uniquely to a map $A\to C^B$.

How might this arise for finite EML expressions? A seductive proposal is to choose one evaluator template containing parameter leaves. Different parameter values would specialize the template to different expressions. The template would be fixed; only its leaves would change.

To isolate exactly this proposal, call a substitution a **leaf substitution** when every parameter variable is replaced by an expression of size $1$—that is, by a single constant or a single variable. A template $T$ would be **universal by parameter sharing** if every target expression could be obtained as $T[\sigma]$ for some leaf substitution $\sigma$.

The crucial invariant is immediate but powerful.

**Leaf-Substitution Size Theorem.** If $\sigma$ is a leaf substitution, then

$$
|T[\sigma]|=|T|.
$$

The proof again follows the tree. At a parameter leaf, the replacement has size $1$, exactly matching the node it replaces. Every operation node remains in place, so the recursive size equations preserve the total node count.

Parameter sharing can alter labels at the leaves. It cannot alter topology. It cannot add another multiplication, wrap the whole expression in a logarithm, or deepen a chain of exponentials.

## A tower that always escapes

For each nonnegative integer $k$, define an exponential tower $E_k$ by

$$
E_0=0,
\qquad
E_{k+1}=\exp(E_k).
$$

This is a perfectly legitimate EML expression with any chosen number of ambient input variables, even though it ignores them. Its tree contains one constant leaf and $k$ exponential nodes.

**Exponential-Tower Size Theorem.** For every $k\ge 0$,

$$
|E_k|=k+1.
$$

This follows by induction: $E_0$ has one node, and each new exponential adds exactly one.

Now take any proposed finite universal template $T$ and let $s=|T|$. Consider the target $E_s$. Its size is $s+1$. If $T$ produced $E_s$ by leaf parameter sharing, the leaf-substitution theorem would force the result to have size $s$. But identical expression trees must have identical sizes, so one expression would have to have both sizes $s$ and $s+1$. That is impossible.

We obtain the main conclusion.

**Finite-Template Obstruction Theorem.** No fixed finite EML expression template can generate every finite EML expression solely by replacing parameter leaves with constants or variables.

The diagonal flavor of the argument is worth noticing. Whatever finite bound a proposed template presents, the escaping target is built directly from that bound by adding one more operation node. There is no need to estimate enormous numerical values or compare the analytic behavior of functions. The obstruction lives entirely in structural complexity.

## What the obstruction means—and what it does not

The theorem defeats a specific route to currying: a single finite evaluator cannot represent every finite expression merely through shared leaf parameters. Therefore Cartesian closure does not follow from that mechanism.

It does **not** establish that every imaginable category of EML-computable real functions fails to be Cartesian closed. Two expressions with different trees can denote the same function. For example, $x+0$ and $x$ differ syntactically while agreeing numerically. If arrows are identified whenever they compute the same function, tree size no longer descends automatically to the quotient. A stronger impossibility result would need a semantic invariant—perhaps from differential algebra, transcendence theory, model theory, or the complexity of definable families.

Nor does the theorem deny that richer computational worlds can support higher-order structure. A language might include expression codes as data, together with an interpreter; it might use closures, inductive datatypes, partial maps, or represented spaces. But each such choice changes the objects or arrows. Its evaluator and currying law must be constructed explicitly rather than inferred from parameter sharing.

There is also a separate caution about natural numbers. Taking the whole real line $\mathbb{R}$ as a natural-numbers object requires far more than naming $0$ and defining successor by $x\mapsto x+1$. A natural-numbers object must solve a unique recursion problem for every target object and every choice of initial point and step map. The continuous exp–log–arithmetic setting gives no automatic reason for all those recursively specified maps to exist.

## The wider lesson

In applications, parameters are often treated as if enough of them could express any model. The finite-template obstruction reveals the hidden qualifier: parameters move a model within a fixed architecture. They do not, by themselves, create unbounded architecture.

This distinction appears across science. Coefficients tune a differential equation but do not add new state variables. Weights tune a neural network but do not add another layer. Constants specialize a symbolic expression but do not insert another operation node. A family may be broad in numerical behavior while remaining rigid in structural form.

The EML universe therefore has a clean first-order foundation. Substitution supplies exact composition and obeys identity and associativity. Tuples supply multi-output pairing compatible with preprocessing. At the higher-order frontier, however, one finite tree cannot contain all finite trees in its leaves.

That boundary is not a failure of the theory. It is the theory doing its most useful job: separating what follows from the definitions from what requires a genuinely new representation. If universal evaluation is desired, the architecture must be allowed to carry architecture—not just parameters.