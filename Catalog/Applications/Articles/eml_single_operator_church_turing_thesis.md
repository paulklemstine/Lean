# One Function to Rule Them All: How Exponents and Logarithms Could Be the Atoms of Computation

*A single mathematical operation — combining exponentials and logarithms — may be all you need to compute anything.*

---

## The Search for Simplicity

Mathematics has always been a quest for economy. Euclid reduced geometry to five postulates. Newton captured the motion of planets in a handful of equations. The entire digital revolution rests on a single logical operation: the NAND gate, from which every computer circuit can be built. Now, a new line of research suggests that a similarly radical simplification may be possible for continuous mathematics — and the key is an operation so simple it might be taught in a high school algebra class.

The operation is this: take the exponential of one number, and the logarithm of another. From just these two functions, together with basic arithmetic (addition, subtraction, multiplication, division), you can build every elementary function that scientists use — polynomials, roots, trigonometric functions, and more. This is the **EML conjecture**, named for the triad of Exp, Multiply, and Log that forms its foundation.

If the conjecture is true, it would mean that a single type of computational "neuron" — one that knows how to exponentiate and take logarithms — is theoretically sufficient to approximate any continuous computation on real numbers.

## The Exp-Log Magic Trick

The core insight behind the EML conjecture is deceptively simple. Consider multiplication. You learned in school that multiplying two numbers is... multiplying two numbers. But there's another way. If you have two positive numbers *a* and *b*, you can compute their product as:

> *a × b = exp(log(a) + log(b))*

Take the logarithm of each number, add the results, and exponentiate. This is the principle behind the slide rule, one of the most important computational tools in history, used by engineers from the 17th century through the Apollo missions.

But the trick goes much further. Powers? Easy:

> *x^n = exp(n × log(x))*

Square roots? Just a special case:

> *√x = exp(log(x) / 2)*

Division?

> *a / b = exp(log(a) − log(b))*

Every one of these operations — operations that seem fundamentally different — reduces to just two ingredients: `exp` and `log`, glued together with addition and subtraction.

## Building the Tower

Once you have polynomials (which are just sums of powers), you can invoke one of the most powerful results in mathematics: the **Weierstrass approximation theorem**, which says that any continuous function on a closed interval can be approximated as closely as you like by polynomials.

This means that sine, cosine, the error function, Bessel functions — the entire menagerie of special functions that populate physics textbooks — can be approximated by polynomials. And polynomials, as we've seen, can be built from exp and log.

But the EML framework goes further. Because exp and log are themselves in the toolkit, functions like *exp(exp(x))* or *log(log(x))* — iterated towers of transcendental operations — are also representable. This gives the EML class a richness that goes beyond what polynomials alone can do. It can capture functions with different growth rates, from the glacially slow logarithmic to the explosively fast doubly-exponential.

## A Hierarchy of Complexity

One of the most interesting discoveries in this research is that EML expressions have a natural measure of complexity: their **depth**. The depth counts how many layers of exp/log nesting an expression uses. A polynomial operating on positive reals has depth 2 (one log going in, one exp coming out). A doubly-exponential function like *exp(exp(x))* has depth 2. And this hierarchy is strict — there are functions at every depth level that cannot be computed at any lower depth.

This is not unlike the circuit complexity classes that computer scientists study, where they measure how many layers of logical gates are needed to compute a Boolean function. The EML depth hierarchy is its continuous analogue, measuring the "transcendental complexity" of a real-valued computation.

The depth also composes predictably: if you substitute one EML expression into another, the resulting depth is at most the sum of the two depths. This gives engineers a way to reason about the resource cost of building complicated functions from simple ones.

## The Neural Network Connection

Why does this matter beyond pure mathematics? The answer lies in the design of neural networks. Today's artificial neural networks are built from simple units that compute weighted sums followed by a nonlinear "activation function" — typically a sigmoid, ReLU, or similar function. The universal approximation theorems for neural networks show that these architectures can approximate any continuous function, but the choice of activation function is largely arbitrary.

The EML conjecture suggests a more principled choice. An **EML neuron** would compute something like *exp(a) · log(b)* — a single unit that combines exponential amplification with logarithmic compression. If the conjecture is true, a network of such neurons would be computationally universal not because of some abstract existence theorem, but because of the *algebraic structure* of the exp and log functions.

This has practical implications. Exponentials and logarithms have well-understood numerical properties. They map nicely to hardware (many processors have dedicated exp/log instructions). And the exp-log representation often reveals structure that is hidden in a polynomial or neural-network representation — for instance, multiplicative relationships become additive after taking logarithms, which is exactly the principle behind log-linear models in statistics.

## What Could Go Wrong?

The conjecture is not trivially true. There are genuine obstacles. The most serious is the **domain restriction**: the logarithm is only defined for positive numbers. This means that the raw EML reduction of multiplication, *a × b = exp(log(a) + log(b))*, only works when *a* and *b* are positive. Extending to negative numbers or zero requires additional tricks — essentially, tracking signs separately and using the absolute value.

There are also questions about **computability** in the rigorous sense. The conjecture claims universality for "computable real functions," but the precise meaning of this depends on which model of real computation you adopt. In the Blum-Shub-Smale model, which allows exact real arithmetic, the conjecture is a statement about algebraic expressibility. In the computable analysis tradition, where everything is approximated to finite precision, the relevant question is whether EML compositions can achieve arbitrary approximation accuracy — which connects directly to the Weierstrass-type results.

## The Diagonal Map: A Window into Dynamics

An intriguing connection emerges when you apply both exp and log to the *same* variable. The **diagonal EML function** *d(x) = exp(x) − log(x)* has remarkable properties: it has no fixed points on the positive reals (it always exceeds *x*), and it is bounded below by 2 for all positive inputs. This means the diagonal map is a kind of "expanding" operation that pushes every positive number away from itself.

This no-fixed-point property is not just a curiosity. It connects to dynamical systems theory and the study of iteration. If you repeatedly apply the diagonal map, you get a sequence that grows without bound — a fact that has implications for the convergence analysis of iterative algorithms built from EML primitives.

## Looking Forward

The EML conjecture sits at a crossroads of several mathematical traditions: analysis (approximation theory), algebra (closure properties of function classes), computability theory (what can be computed with finite resources), and machine learning (universal approximation). Its resolution — whether positive or negative — would illuminate the deep structure connecting these fields.

If true, it would provide a canonical minimal basis for real-valued computation, analogous to how NAND gates provide a canonical basis for Boolean computation. If false, the *reason* for failure would itself be interesting — it would identify a fundamental limitation of the exp-log paradigm and point toward whatever additional primitives are needed.

In the meantime, the partial results are already useful. The fact that all polynomials are EML-representable, that the depth hierarchy is strict, and that the class has clean closure properties — these are tools that can be applied today, whether or not the full universality conjecture is eventually settled.

Mathematics, at its best, finds the hidden unity behind apparent diversity. The EML program asks: is there a single thread — the interplay of growth and compression, of exp and log — that runs through all of continuous computation? The answer, whatever it turns out to be, will tell us something deep about the fabric of mathematical reality.

---

*The research described here involves new mathematical results about the closure properties of exponential-logarithmic function classes and their relationship to computational universality.*
