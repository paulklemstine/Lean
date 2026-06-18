# The Hidden Geometry of Computation: How Exponentials and Logarithms Build a Universe

## A question that shouldn't have an answer

Take any recipe that uses only five ingredients: addition, multiplication, raising to a power, exponentials, and logarithms. How complicated can the result get?

At first glance, the answer seems obvious: *arbitrarily complicated.* After all, you can nest these operations as deeply as you like. Compose an exponential inside a logarithm inside another exponential, multiply the result by a power, add a constant, and repeat. The expressions grow without bound. The functions they describe twist and curve through space in ways that resist easy classification.

But a team of researchers has discovered something surprising. These five operations, when applied to functions of multiple variables, organize themselves into a mathematical structure with a hidden skeleton — one that obeys the same architectural laws as the categories mathematicians use to describe everything from quantum mechanics to database queries. And on a special but remarkably important subdomain — functions of strictly positive inputs — the entire multiplicative fragment of this computational universe secretly *is* affine geometry wearing a logarithmic disguise.

This is not just a curiosity. It is a structural theorem with consequences for economics, chemistry, machine learning, and the foundations of scientific modeling.

## The five building blocks

The story begins with a simple observation. Many of the formulas that appear in science share the same small vocabulary. The radioactive decay law: *N(t) = N₀ · e^{−λt}*. The Richter scale: *M = log₁₀(A/A₀)*. The compound interest formula: *A = P(1 + r/n)^{nt}*. The Boltzmann distribution in statistical physics. The logistic growth curve in ecology. The Cobb-Douglas production function in economics.

All of these are built from the same five operations: addition, multiplication, exponentiation (*e^x*), logarithm (*log x*), and raising to a real power (*x^r*). Mathematicians call this the **EML fragment** — for Exponential, Multiplicative, and Logarithmic.

The question that launched this research program is deceptively simple: *What is the totality of all functions you can build this way?* Not just one function at a time, but the entire ecosystem — all the ways these building blocks can be composed, combined, and stacked to produce maps from multi-dimensional spaces to multi-dimensional spaces.

## From recipes to architecture

To understand what the researchers found, imagine a very large cookbook. Each recipe takes some number of ingredients (inputs) and produces some number of dishes (outputs). Each step in a recipe uses one of the five basic operations. The question is: what architectural principles govern this cookbook as a whole?

The answer turns out to involve a branch of mathematics called **category theory**, which studies not objects in isolation but the relationships between them. A category is a collection of objects together with arrows (called morphisms) connecting them, where arrows can be composed end-to-end, and every object has an identity arrow that does nothing.

The researchers proved that EML-computable maps — functions of finitely many real variables that can be built from the five operations — form a category. The objects are finite-dimensional real vector spaces (or more precisely, their dimensions: 1, 2, 3, …). The morphisms are the EML-computable maps between them. Three fundamental theorems establish the categorical structure:

**Identity.** The "do nothing" function — which takes an input vector and returns it unchanged — is EML-computable. (This is trivial but necessary: every category needs identity morphisms.)

**Composition.** If you can build a function *f* from ℝⁿ to ℝᵐ and a function *g* from ℝᵐ to ℝᵏ using EML operations, then their composition *g ∘ f* from ℝⁿ to ℝᵏ is also EML-computable. (You can chain recipes.)

**Products.** If you have two EML-computable functions *f* : ℝⁿ → ℝᵐ and *g* : ℝⁿ → ℝᵏ, then the combined function that outputs both results — *(f, g)* : ℝⁿ → ℝᵐ⁺ᵏ — is also EML-computable. (You can cook two dishes from the same ingredients.)

The product theorem is the genuinely new result. It upgrades EML from a *class of formulas* into a *semantic universe* — a structured space in which computations can be freely combined, split, and recombined. This is the same kind of product structure that underlies circuit design, probabilistic programming, and neural network architectures.

## The logarithmic mirror

The most striking discovery lies not in the general category but in a special fragment. Consider only functions of strictly positive inputs, and restrict to the *multiplicative* operations: multiplication, powers, and positive constants (no addition). This is the world of scaling laws, where doubling an input multiplies the output by some fixed factor.

The researchers proved a normalization theorem for this fragment. Every multiplicative EML expression — no matter how deeply nested — can be reduced to a single canonical form:

> *f(x₁, x₂, …, xₙ) = C · x₁^{w₁} · x₂^{w₂} · ⋯ · xₙ^{wₙ}*

This is a **weighted geometric monomial**: a product of the inputs raised to various powers, times a constant. The weights *w₁, …, wₙ* and the constant *C* completely determine the function.

But here is the key insight. Write this in logarithmic coordinates: let *yᵢ = log(xᵢ)*. Then

> *log f = w₁ · y₁ + w₂ · y₂ + ⋯ + wₙ · yₙ + log C*

This is an **affine function** — the simplest kind of function in mathematics, the straight-line generalization to multiple dimensions. The entire multiplicative EML world, viewed through the logarithmic lens, becomes *linear algebra*.

This is what the researchers call the **log-affine bridge**: in logarithmic coordinates, multiplicative computation is secretly affine geometry.

## Why the bridge matters

The log-affine bridge is not just an elegant mathematical curiosity. It connects the EML framework to some of the deepest structures in applied mathematics.

**Economics.** The Cobb-Douglas production function *Y = A · L^α · K^β*, which relates economic output to labor and capital inputs, is a log-affine map. The theorem guarantees that any product of such production functions remains log-affine — you can combine economic sectors and the aggregate still has the same clean structure. In log coordinates, the production function becomes the linear equation *log Y = log A + α · log L + β · log K*, which is why economists routinely work in log-log plots: they are literally applying the log-affine bridge.

**Chemistry.** The mass-action law says that reaction rates equal a constant times the product of reactant concentrations raised to stoichiometric powers: *rate = k · [A]^a · [B]^b*. This is a log-affine function of concentrations. The closure theorem means that combining multiple reaction pathways preserves log-affine structure, and in log coordinates, reaction kinetics becomes a linear system.

**Machine learning.** The weighted geometric mean *GM(x) = exp(∑ wᵢ · log xᵢ)* is a fundamental operation in ensemble methods, attention mechanisms, and statistical aggregation. It is a log-affine map, and the normalization theorem guarantees that any chain of such aggregations collapses to a single weighted geometric mean with known weights.

**Information theory.** The connections to entropy, KL divergence, and exponential families run deep. The natural parameters of an exponential family are precisely the log-coordinates in which the sufficient statistics become linear. The EML category provides a rigorous computational framework for these objects.

## The currying theorem: computation with parameters

Beyond products and log-affine structure, the researchers proved a **currying theorem** that makes the EML category relevant to modern computational paradigms like differentiable programming and neural architecture design.

The theorem says: if you have an EML-computable function *F(θ, x)* that takes both parameters θ and inputs *x*, then for any fixed value of θ, the specialized function *x ↦ F(θ, x)* is also EML-computable. This sounds obvious, but it is not — it requires showing that fixing some inputs of an EML expression always produces another EML expression, which is a structural property of the inductive definition.

The practical consequence is that EML-computable maps can serve as **trainable families**: a single EML expression on the joint parameter-input space generates an entire family of models, each of which is itself EML-computable. This is exactly the structure needed for gradient-based optimization in machine learning, where you fix the model architecture and optimize over parameters.

## A verified foundation

What makes this work unusual in mathematics is its level of certainty. The theorems were not merely stated and argued informally — they were **machine-verified**, checked step-by-step by a computer proof system that guarantees logical correctness down to the axioms of mathematics. Every claim about closure, composition, and normalization has been reduced to a chain of elementary logical deductions that a machine has verified to be valid.

This matters because the theorems serve as a *foundation* — other results will be built on top of them. A single subtle error in a foundational theorem can invalidate an entire tower of dependent results. Machine verification eliminates this risk.

## Looking ahead: tropical shadows and analytic structure

The log-affine bridge suggests tantalizing directions for future work. When you take the "temperature" of a log-sum-exp expression to infinity — a technique familiar from statistical physics — the smooth maximum becomes a hard maximum, and the geometry transitions from smooth curves to piecewise-linear surfaces. This is the regime of **tropical geometry**, where multiplication becomes addition and addition becomes maximum.

The EML framework appears to be the natural smooth analog of tropical computation. As the temperature rises, EML expressions tropicalize: their smooth log-affine structure degrades gracefully into the piecewise-linear world. Formalizing this connection would bridge differentiable computation with combinatorial optimization, connecting gradient descent to linear programming.

Another frontier is **analyticity**. The five EML operations all produce real-analytic functions (functions that equal their Taylor series). This means every EML-computable function should be analytic — infinitely differentiable and determined by its local behavior. If proved, this would separate EML computation from the continuous but non-smooth functions that arise in neural networks with ReLU activations, giving the EML category a distinctive geometric character.

## The deeper lesson

Behind the technical results lies a philosophical point about the nature of scientific computation. The functions that appear most often in science — exponentials, logarithms, power laws, scaling relations — are not arbitrary. They share a common algebraic structure, and that structure has now been made precise.

When an economist writes a Cobb-Douglas function, a chemist writes a rate law, and a physicist writes a Boltzmann factor, they are all working in the same category. Their formulas compose, their products factor cleanly, and in logarithmic coordinates their multiplicative relationships become linear. This is not a coincidence. It reflects the deep fact that the natural world operates through processes — growth, decay, scaling, equilibrium — that are generated by a small, closed set of mathematical operations.

The EML category makes this closure precise and proves it correct. It gives the computational vocabulary of science a skeleton — and that skeleton, it turns out, is made of straight lines in a logarithmic mirror.
