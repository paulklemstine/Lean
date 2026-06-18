# The Hidden Language of Functions: How Two 19th-Century Ideas Unlock the Architecture of Mathematics

## A surprising connection between exponentials, logarithms, and a 70-year-old theorem reveals that nature's complexity may rest on remarkably simple foundations.

---

In 1957, a young Russian mathematician named Andrey Kolmogorov shocked the mathematical world by proving something that many had believed impossible. He showed that *any* continuous function of multiple variables — no matter how complicated — could be broken down into a sum of functions that each depend on only one variable at a time. It was as if he had demonstrated that any recipe, no matter how exotic, could be prepared using only single-ingredient dishes.

Kolmogorov's theorem was elegant but abstract. It told you the decomposition existed, but not how to build it efficiently. For nearly seven decades, mathematicians and computer scientists have wondered: what kinds of simple functions do you actually need for these building blocks?

Now, a new line of research suggests a startling answer: you may need nothing more than the two most fundamental operations in mathematics — the exponential function and its mirror image, the logarithm.

## The Exp-Log Universe

The exponential function — the one that describes radioactive decay, compound interest, and population growth — and the logarithm — which measures earthquake intensity, sound volume, and information content — are arguably the two most important functions in all of science. They are inverses of each other: what one does, the other undoes.

The key insight of the new research is that these two functions, combined with simple scaling and shifting (multiplying by a constant, adding a constant), form a complete toolkit for expressing mathematical relationships. The researchers call chains of these operations "EML chains" — sequences where you might take the logarithm of a number, scale it, then exponentiate the result, and so on.

What makes this remarkable is how *few* layers you need. To express multiplication — one of the most fundamental operations in mathematics — you need exactly one logarithm and one exponential: since log(x) + log(y) = log(xy), you can compute the product of two positive numbers by taking their logarithms, adding (a one-variable operation!), and exponentiating back. Slide rule users knew this trick centuries ago. But the new results show this pattern extends far beyond multiplication.

## The Depth-3 Miracle

Consider the mathematical expression x³y⁵ — the cube of one number times the fifth power of another. This is a function of two variables, and Kolmogorov's theorem guarantees it can be decomposed into single-variable pieces. But how complex must those pieces be?

The answer turns out to be remarkably uniform: *every* monomial, no matter how high the powers, can be decomposed using EML chains of depth at most 3. That's one logarithm, one scaling operation, and one exponentiation. Whether you're computing xy or x¹⁰⁰y²⁰⁰, the depth of the decomposition stays fixed at 3.

This is deeply counterintuitive. You might expect that higher-degree expressions would require more complex building blocks. Instead, the EML framework achieves a kind of "depth independence" — the complexity of the representation doesn't grow with the complexity of the function being represented.

## From Monomials to Polynomials

Every polynomial — every expression like 3x²y + 7xy³ - 2y² — is just a sum of monomials. Since each monomial gets its own depth-3 decomposition, the entire polynomial can be decomposed using one term per monomial. A polynomial with M monomials needs exactly M terms in its EML-Kolmogorov-Arnold decomposition.

This is significantly better than the classical Kolmogorov-Arnold theorem, which requires 2n+1 terms for a function of n variables regardless of its structure. For a bivariate polynomial, the classical bound is 5 terms. But many important bivariate functions — multiplication, division, any power function — need only 1 term in the EML framework.

## The Geometric Mean Connection

One of the most beautiful results connects the EML decomposition to a fundamental inequality in mathematics: the AM-GM inequality, which states that the arithmetic mean of two positive numbers is always at least as large as their geometric mean.

In EML terms, this becomes: exp((log x + log y)/2) ≤ (x + y)/2. The left side is the geometric mean expressed through EML — encode with log, average, decode with exp. The right side is the arithmetic mean. The inequality says that the EML-decoded average is always conservative — it underestimates the plain average.

This isn't just a curiosity. It reveals that the relationship between EML encoding and linear operations has a definite direction: the logarithmic world is "smaller" than the linear world. This asymmetry has deep connections to information theory, thermodynamics, and the structure of physical laws.

## Fenchel-Young: The Variational Foundation

Perhaps the deepest result connects EML to optimization theory through the Fenchel-Young inequality: for any real number x and any positive number s,

  x·s ≤ exp(x) + s·log(s) - s

This elegant bound says that the linear function x·s is always dominated by a combination of exponential and logarithmic terms. The bound is *tight* — equality holds when x = log(s), precisely where the exponential and logarithmic functions are inverses.

This inequality is the mathematical foundation for many optimization algorithms, and it shows that exp and log are not just convenient — they are *optimal* in a precise variational sense. They provide the tightest possible bound on linear functions, making them the natural building blocks for function decomposition.

## The Universality Conjecture

The proven results cover monomials and polynomials — already a vast class of functions. But the researchers have proposed a far more ambitious conjecture: that *any* continuous function on the positive quadrant can be approximated to arbitrary accuracy using EML-Kolmogorov-Arnold decompositions.

If true, this would mean that exp and log, combined with addition and scaling, form a universal approximation system. Every continuous relationship in nature — from fluid dynamics to neural firing patterns to economic equilibria — could be approximated by chains of exponentials and logarithms.

The conjecture comes with a concrete test: can the function sin(xy) be approximated to within 1% accuracy on the square [1,2]² using a 10-term EML decomposition? This is a specific, falsifiable prediction that can be checked computationally.

## Why It Matters

The practical implications are significant. Modern artificial intelligence relies heavily on neural networks, which use specific nonlinear functions (like ReLU or sigmoid) as building blocks. The EML framework suggests an alternative architecture: networks built from exponentials and logarithms, where multiplication emerges naturally as addition in the log domain.

This is already happening in practice. The Kolmogorov-Arnold Network (KAN) architecture, introduced in 2024, replaces fixed activation functions with learnable univariate functions, inspired directly by Kolmogorov's theorem. The EML perspective suggests that these learnable functions should be parameterized as chains of exponentials and logarithms — a principled choice grounded in both classical analysis and modern representation theory.

Beyond machine learning, the depth-independence result has implications for computational complexity. If mathematical expressions can always be evaluated with bounded-depth EML chains, then parallel computation of these expressions requires only constant depth, regardless of the degree of the polynomial. This connects to fundamental questions about the power of parallel algorithms.

## The Bigger Picture

At its core, this research reveals something profound about the structure of mathematics itself. The two most fundamental transcendental functions — exp and log — are not just useful tools. They are the *atoms* from which mathematical relationships can be built, just as chemical elements are the atoms from which physical substances are constructed.

Kolmogorov showed that multivariate complexity can always be reduced to univariate simplicity. The EML framework shows that this simplicity has a specific character: it is the simplicity of exponentials and logarithms, the functions that translate between addition and multiplication, between linear and geometric growth, between the world of sums and the world of products.

In a sense, the entire edifice of continuous mathematics rests on two pillars: the exponential, which turns addition into multiplication, and the logarithm, which turns multiplication into addition. Everything else is commentary.

---

*The research described here establishes rigorous mathematical foundations connecting EML (exponential-minus-logarithm) function chains to the Kolmogorov-Arnold representation theorem. Key results include depth-uniform monomial decompositions, AM-GM and Fenchel-Young connections, and a falsifiable universality conjecture.*
