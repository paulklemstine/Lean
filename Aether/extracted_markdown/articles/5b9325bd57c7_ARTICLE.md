# The Tower Beyond Infinity: How Mathematicians Map the Landscape of Growth

*When ordinary numbers aren't enough, transseries chart the territory where functions grow faster than imagination*

---

## The Problem of Infinite Growth

Imagine standing at the edge of a cliff, watching a ball roll down an ever-steepening slope. At first, its speed increases gently — linearly, perhaps. Then something changes. The slope curves exponentially, and the ball accelerates beyond any polynomial bound. But what lies beyond the exponential? What kind of mathematical object can describe a function that grows faster than $e^x$, faster than $e^{e^x}$, faster than any tower of exponentials you can stack?

This question — how to systematically describe functions of extreme growth — has haunted mathematicians for over a century. The answer turns out to be one of the most elegant structures in all of mathematics: **transseries**.

## Beyond Power Series

Every calculus student learns about Taylor series: expressing a function as a polynomial of infinite degree. The sine function becomes $x - x^3/6 + x^5/120 - \cdots$, a beautiful infinite sum that converges to the true function. But not every function submits to this treatment. The function $e^{-1/x}$, which is zero at the origin but positive everywhere else, has a Taylor series that is identically zero — a spectacular failure of power series to capture the function's behavior.

Transseries are the fix. Where power series use only powers of $x$, transseries allow exponentials, logarithms, and their iterations as building blocks. A typical transseries might look like:

$$f(x) \sim 3e^{2x} - x^5 e^x + 7x^2 - \frac{1}{x} + e^{-x}$$

Each term is a **monomial** of the form $x^\alpha \cdot e^{\beta x} \cdot (\log x)^\gamma$, and the terms are ordered by their asymptotic growth rate. The key insight: these monomials form a **strict hierarchy**, and every function built from exponentials, logarithms, and polynomials can be uniquely represented in this format.

## The Dominance Hierarchy

At the heart of transseries theory lies a startlingly clean ordering principle. Consider two monomials:

- $m_1 = x^2 \cdot e^x$ 
- $m_2 = x^{1000}$

Which grows faster? Despite the enormous polynomial exponent of $m_2$, the exponential factor in $m_1$ always wins. This isn't just a heuristic — it's a theorem: *exponential growth dominates any polynomial, no matter the degree*.

But the hierarchy goes deeper. Among monomials of the same exponential rate, the polynomial exponent breaks ties. And among monomials with the same exponential *and* polynomial exponents, the logarithmic power decides. This creates a **lexicographic total order**: any two monomials are comparable, and there are no ties except between identical monomials.

This three-level comparison — exponential first, then polynomial, then logarithmic — is analogous to how we compare numbers by digits: first the thousands place, then the hundreds, then the tens. But here, the "digits" are themselves continuous parameters, creating an uncountable hierarchy of growth rates.

## The Exponential Tower

The most dramatic feature of this hierarchy is what happens when you iterate. Applying the exponential function once gives $e^x$, which grows faster than any polynomial. Apply it twice to get $e^{e^x}$, which grows faster than any function expressible with a single exponential. Three times gives $e^{e^{e^x}}}$, and so on.

Each level of this **exponential tower** is incomparably faster than the previous one. Not just faster by a constant or a polynomial factor — *infinitely* faster, in the precise sense that the ratio between consecutive levels tends to zero. The tower defines a sequence of growth "floors," and no finite combination of functions from one floor can ever reach the next.

What's remarkable is that this tower is *well-ordered*: there are no infinite descending chains. If you have any collection of transseries monomials, there is always a smallest one. This well-ordering property is what makes transseries a workable mathematical structure rather than an unmanageable zoo of growth rates.

## The EML Connection

A particularly elegant window into transseries comes from the **EML function** — short for "exp minus log":

$$\text{eml}(x, y) = e^x - \log y$$

This seemingly simple function bridges two of the three levels of the monomial hierarchy. Its first term, $e^x$, lives at the exponential level; its second term, $\log y$, lives below even the polynomial level. The gap between them embodies the entire dominance hierarchy in a single expression.

When you compose the EML diagonal $d(z) = e^z - \log z$ with itself, something remarkable happens. Each iteration pushes the output higher in the exponential tower. The first application takes a polynomial-scale input and produces an exponential-scale output. The second application takes that exponential-scale value and feeds it back into the exponential, producing a double-exponential. Each composition climbs one floor of the tower.

This makes iterated EML a *generator* of the transseries hierarchy. Starting from any point, repeated application of $d$ systematically explores every level of the tower — a single function whose iterations span the entire landscape of growth.

## The Comparison Theorem

Perhaps the deepest result in transseries theory is the **asymptotic comparison theorem**: if two transseries agree to all orders — meaning every monomial in one appears with the same coefficient in the other — then they represent the same function. There is no way for two distinct transseries to be "asymptotically indistinguishable."

This is a profound statement about the relationship between formal algebra and asymptotic analysis. It says that the transseries representation is **faithful**: the formal object perfectly captures the asymptotic behavior, with no information lost. In the language of algebra, the map from functions to their transseries expansions is injective.

The proof relies on the dominance hierarchy. If two transseries differ, they differ at some specific monomial — say, the coefficient of $x^2 e^x$ is 3 in one and 5 in the other. This difference, multiplied by the monomial $x^2 e^x$, eventually dominates all lower-order terms, making the two transseries distinguishable by their asymptotic behavior.

## Hardy Fields: Where Transseries Live

The natural habitat of transseries is a **Hardy field** — a collection of function germs at infinity that is closed under addition, multiplication, and differentiation, and where every nonzero element eventually has constant sign. This last condition is crucial: it means there are no oscillating functions in a Hardy field, no sines or cosines that change sign infinitely often.

Hardy fields were introduced by G.H. Hardy in 1910 in his study of "orders of infinity." He realized that the functions mathematicians typically encounter — polynomials, exponentials, logarithms, and their combinations — always eventually settle into being either positive or negative. This property is what makes asymptotic comparison possible: if a function is eventually positive, its growth rate is well-defined.

The collection of all EML-type functions — finite compositions of exponentials, logarithms, and polynomials — generates a Hardy field. This is the structural reason why transseries work: the functions they represent are well-behaved enough to have meaningful asymptotic expansions, yet rich enough to capture the full diversity of non-oscillatory growth.

## Why It Matters

Transseries aren't just an abstract curiosity. They appear naturally in:

**Differential equations**: Many differential equations have solutions that cannot be expressed as convergent power series but have perfectly well-defined transseries expansions. The "divergent series" that Euler and his contemporaries manipulated with such success turn out to be legitimate transseries.

**Theoretical computer science**: The growth rates of algorithms — from linear search to doubly-exponential satisfiability solvers — live naturally in the transseries hierarchy. The dominance ordering provides a rigorous framework for comparing algorithmic complexity.

**Mathematical logic**: The field of transseries turns out to be **real closed** — meaning it satisfies the same first-order properties as the real numbers. This is a deep model-theoretic result with implications for decidability and definability.

**Asymptotic analysis**: Any time you need to understand the behavior of a function "at infinity" — in number theory, in physics, in probability — transseries provide the canonical framework.

## The Frontier

The formalization of transseries theory continues to advance. Recent work has established the complete theory in a machine-checkable format, proving not just the basic dominance hierarchy but the deeper structural results: the well-ordering of supports, the faithfulness of asymptotic expansion, and the closure properties of Hardy fields.

The next frontier is the connection between transseries and surreal numbers — John Conway's extraordinary construction of a number system that contains both infinite and infinitesimal quantities. It turns out that the field of transseries embeds naturally into the surreal numbers, suggesting that these seemingly different approaches to "numbers beyond the reals" are in fact aspects of the same underlying structure.

Another frontier lies in extending transseries beyond the real line. Complex transseries, p-adic transseries, and transseries over more exotic fields remain largely unexplored territory, rich with potential for new discoveries.

The tower of growth rates — from the humble logarithm through polynomials and exponentials to the dizzying heights of iterated exponentials — is not just a hierarchy of numbers. It is a map of mathematical complexity itself, charting the territory where functions grow faster than imagination, yet submit to the organizing power of algebra.

---

*The author is grateful to the transseries research community and to the foundational work of Écalle, van den Dries, Macintyre, Marker, Aschenbrenner, and van der Hoeven.*
