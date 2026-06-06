# The Number Machine: How a Simple Function Unlocks the Deepest Secrets of Transcendental Numbers

*A two-function recipe — one exponential, one logarithm — generates an entire universe of numbers that may forever elude polynomial capture.*

---

Take any rational number — say, 1. Feed it into the exponential function. Out comes *e*, Euler's constant, approximately 2.71828. Now subtract the logarithm of 2. The result, *e* − ln 2, is roughly 2.025. This number, produced by one exponential and one logarithm, almost certainly cannot be the root of any polynomial equation with rational coefficients. It is, in the language of mathematics, *transcendental*.

But here is what makes this interesting: nobody has ever proved it.

## The EML Machine

The operation is deceptively simple. Given two inputs *x* and *y*, compute:

**eml(*x*, *y*) = e^*x* − ln *y***

This is the EML function — Exponential Minus Logarithm. It combines the two most fundamental transcendental functions in mathematics into a single operation. When you plug in rational numbers, it produces outputs that inhabit a strange twilight zone: almost certainly transcendental, but provably so only if one of the deepest unproven conjectures in mathematics turns out to be true.

That conjecture is Schanuel's conjecture, proposed by Stephen Schanuel in the 1960s. It makes a sweeping claim about the algebraic independence of exponentials — roughly, that exponential function cannot secretly satisfy polynomial equations unless there is an obvious reason for it to do so.

## A Universe of Numbers

What makes the EML function remarkable is not any single output but the entire class of numbers it generates. Start with the rationals. Apply the EML function. Take the outputs and feed them back in — as inputs to new EML operations. Repeat. The resulting collection of numbers, which we call *EML numbers*, turns out to have a beautiful algebraic structure.

Every rational number is an EML number. The sum of two EML numbers is an EML number. So is their product, their difference, and their negation. The exponential of any EML number is an EML number. The logarithm of any EML number is an EML number. In short, EML numbers form a self-contained mathematical universe — a *field* closed under the two fundamental operations of transcendental analysis.

This universe contains some of the most famous constants in mathematics:
- *e* = eml(1, 1) — Euler's number
- *e*² = eml(2, 1) — the square of Euler's number
- ln 2 = log of the EML number 2
- *e* − ln 2 = eml(1, 2)
- exp(exp(1)) = eml(eml(1,1), 1) — a double exponential

## The Displacement Theorem

Our first key result is what we call the *Algebraic Displacement Theorem*. It states a principle so clean it seems almost obvious, yet it has profound consequences:

> *A transcendental number plus (or minus) an algebraic number is always transcendental.*

The proof is elegant. Suppose α is transcendental and β is algebraic, but α + β is algebraic. Then (α + β) − β = α would be algebraic, since algebraic numbers are closed under subtraction. But α is transcendental — contradiction.

This simple observation is the engine that drives EML transcendence. If we know that exp(*x*) is transcendental, and we know that log(*y*) is algebraic, then eml(*x*, *y*) = exp(*x*) − log(*y*) is automatically transcendental. The exponential's transcendence "survives" the subtraction of an algebraic logarithm.

## The Schanuel Conditional

The real depth comes when we invoke Schanuel's conjecture. Under this conjecture, we can prove a cascade of transcendence results:

**Result 1: Exp at algebraic inputs.** If α is any nonzero algebraic number, then exp(α) is transcendental. This is actually a known theorem — the Hermite-Lindemann theorem, proved in the 19th century. But our proof derives it as a special case of Schanuel's conjecture, showing the conjecture's enormous power.

**Result 2: Algebraic independence of exponentials.** If α and β are algebraic numbers that are "independent over the rationals" (meaning no rational combination aα + bβ equals zero), then exp(α) and exp(β) are *algebraically independent* — no polynomial in two variables with rational coefficients vanishes at the point (exp(α), exp(β)). This is far stronger than transcendence: it says these numbers are not just individually beyond algebraic capture, but jointly so.

**Result 3: EML composition transcendence.** The EML function can be composed with itself. Under Schanuel, if eml(*x*, *y*) happens to be algebraic and nonzero, then eml(eml(*x*, *y*), *z*) is transcendental for any *z* whose logarithm is algebraic. The EML function acts as a "transcendence pump" — even if one application accidentally produces an algebraic output, the next application pushes the result back into transcendental territory.

## The Diagonal and Its Positivity

One beautiful side result concerns the *diagonal* of the EML function — the function emlDiag(*z*) = exp(*z*) − log(*z*), where both inputs are the same. For any positive *z*, this function is strictly positive. The reason interweaves two fundamental inequalities:

- The exponential dominates the identity: exp(*z*) ≥ 1 + *z* for all *z*
- The logarithm is dominated by the identity: log(*z*) ≤ *z* − 1 for all *z* > 0

Combining these: emlDiag(*z*) = exp(*z*) − log(*z*) ≥ (1 + *z*) − (*z* − 1) = 2. The diagonal is not merely positive — it is at least 2 everywhere on the positive reals.

This positivity has geometric meaning. The EML function defines a surface in three-dimensional space. The diagonal slice through this surface — where both coordinates are equal — rises above the plane, creating a valley whose floor never touches zero.

## Why It Matters

The significance of this work lies in the connections it reveals. Transcendental number theory, which began with Liouville's construction in 1844 and matured through the work of Hermite, Lindemann, and Gelfond, has always proceeded by studying individual numbers or small families. Our approach is different: we study an *entire class* of numbers generated by a specific algebraic-analytic recipe.

The EML function is not arbitrary. It arises naturally in information theory (where exp and log appear in entropy formulas), in physics (where the partition function involves exponentials), and in machine learning (where the softmax function combines exp and log). Every time a scientist computes a likelihood ratio or an information gain, they are implicitly working with EML-type expressions.

Under Schanuel's conjecture, these computations produce numbers that are fundamentally beyond polynomial capture. The natural constants of science are not just irrational — they are transcendental in a deep, structured way that reflects the algebraic independence of the exponential function.

## The Next Frontier

The tower construction hints at where this research leads. Start with 1. Apply eml(·, 1) = exp(·) once to get *e*. Apply it again to get exp(*e*) ≈ 15.15. Again: exp(exp(*e*)) ≈ 3,814,279. Each step in this tower produces a number of strictly increasing "transcendence complexity" — under Schanuel, no polynomial relation connects any level of the tower to the levels below it.

This is mathematics at the edge of what can be proved. Schanuel's conjecture remains unproven after sixty years. But the conditional results are so rich, so structurally illuminating, that they justify the conjecture's central role in modern transcendence theory. If the conjecture is true, the EML function reveals a hierarchy of transcendence that mirrors the hierarchy of computational complexity — with each level strictly more complex than the last.

And if the conjecture is false? Then something even more surprising is true: the exponential function satisfies hidden algebraic relations that nobody has yet discovered. Either way, the mathematics wins.

---

*The research described here establishes a formal framework connecting the EML function to transcendental number theory via Schanuel's conjecture. All results conditional on Schanuel's conjecture are explicitly marked as such; unconditional results include the Algebraic Displacement Theorem, the EML ring structure, and the diagonal positivity bound.*
