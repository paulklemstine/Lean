# When Can You Simplify Just Part of a Calculation?

## The Mathematics of Selective Normalization

---

Imagine you're baking a cake. You realize that you can substitute one brand of flour for another — they're interchangeable for all practical purposes. Do you need to re-test every single step of the recipe? The sifting, the mixing, the folding of egg whites? Of course not. As long as the flour interacts the same way with every other ingredient, swapping it changes nothing about the final result.

This intuition — that you can simplify one component of a complex process without disrupting the whole — turns out to be a profound mathematical principle. And proving it rigorously has been surprisingly difficult.

---

## The Tyranny of Total Simplification

Mathematics and computer science are full of **simplification procedures**: algorithms that take a complicated expression and reduce it to a canonical, cleaned-up form. Think of reducing a fraction like 42/56 to 3/4, or simplifying an algebraic expression like *x² + 2x + 1* to *(x + 1)²*.

These simplifiers are workhorses. Compilers use them to optimize code. Computer algebra systems use them to make equations readable. Automated theorem provers use them to cut through logical clutter.

But here's the problem: most real-world expressions aren't made of just one kind of thing. A physics calculation mixes numbers with vectors. A financial model mixes interest rates with portfolio weights. A programming language mixes integers with data structures. When you simplify the numbers, you don't necessarily want to — or even *can* — simplify the vectors at the same time.

For decades, the standard approach has been all-or-nothing: simplify everything, or simplify nothing. If your system has five different kinds of mathematical objects interacting with each other, you need a simplifier that understands all five kinds simultaneously. This is expensive to build, expensive to verify, and fragile — change one kind, and you might break the others.

What if there were a better way?

---

## The Key Insight: Sort-Selective Normalization

The breakthrough comes from an old idea in logic called **multi-sorted algebra**. In ordinary algebra, everything is the same kind of thing — numbers, say. But in multi-sorted algebra, you explicitly distinguish different *sorts* of objects. Integers are one sort. Vectors are another. And the operations that connect them — like multiplying a vector by a scalar — are *cross-sort* operations.

The critical question becomes: **under what conditions can you simplify objects of one sort without breaking the cross-sort operations?**

The answer, it turns out, is elegant and surprising. You need exactly one condition: the simplification must be *compatible* with every cross-sort operation. In the language of the theory, the equivalence relation induced by your simplifier on sort A must be a *congruence* with respect to every operation that takes an A-input and produces a B-output.

Let's unpack this with a concrete example. Suppose you're working with a ring *R* (think: the integers) and a module *M* over that ring (think: a vector space, but over integers instead of real numbers). The cross-sort operation is **scalar multiplication**: you can multiply a ring element by a module element to get another module element.

Now suppose you have a simplification procedure for the ring — say, reducing integers modulo 6. The condition for sort-selective correctness is simply this: if two ring elements are equivalent under your simplification (they differ by a multiple of 6), then multiplying either one by any module element gives the same result.

That's it. One condition. And from it, a remarkable chain of consequences unfolds.

---

## The Fibrational Correctness Theorem

The main result can be stated informally as follows:

> **Theorem.** Let *E* be an expression built from ring operations, module operations, and scalar multiplications. Let *norm* be a simplifier for the ring that maps every ring element to an equivalent one. If ring equivalence is compatible with scalar multiplication, then evaluating *E* gives the same result (up to ring equivalence on ring-sorted parts, and exact equality on module-sorted parts) whether or not you apply *norm* to every ring-sorted subexpression.

The proof proceeds by structural induction on the expression *E*. For pure ring operations — addition, multiplication, negation — the result follows from the fact that the ring equivalence is a congruence (compatible with these operations by definition). For pure module operations, nothing changes because the module sort isn't being simplified.

The interesting case is scalar multiplication: *r* • *m*, where *r* is a ring expression and *m* is a module expression. After simplification, this becomes *norm(r)* • *m'*, where *m'* is the result of recursively simplifying the module subexpression. By induction, *norm(r)* is ring-equivalent to *r*, and *m'* equals *m* (since module simplification is the identity). The compatibility condition then gives *norm(r)* • *m* = *r* • *m*.

This is where the magic happens. The compatibility condition — which seems like a small technical requirement — is doing all the heavy lifting at the boundary between the two sorts.

---

## A Bridge to Classical Mathematics

Here's where the story takes an unexpected turn. The compatibility condition for sort-selective normalization turns out to be *exactly the same condition* that appears in a completely different area of mathematics: the **change of rings** construction in module theory.

In abstract algebra, a fundamental question is: given a module over a ring *R*, can you turn it into a module over a quotient ring *R/I*? The answer is yes, precisely when the ideal *I* acts trivially on the module — that is, when equivalent ring elements (those differing by an element of *I*) produce the same result under scalar multiplication.

This is the same condition! The mathematics of simplifying expressions and the mathematics of algebraic quotients are secretly the same theory, viewed from different angles.

This connection is not merely aesthetic. It means that every result proved in one domain automatically translates to the other. Decades of theorems about change of rings — developed for purposes completely unrelated to computation — become immediately available as tools for reasoning about optimizer correctness. And conversely, computational insights about simplification can shed light on algebraic structure.

---

## What Selective Normalization Cannot Do

No account of a mathematical result would be complete without understanding its limits. And sort-selective normalization has a sharp, provable limitation.

**Conjecture (now disproved):** If your ring simplifier is *complete* — meaning it reduces every ring element to a unique canonical form — then sort-selective normalization achieves full observational equivalence. That is, two expressions evaluate to the same result if and only if they normalize to the same expression.

This sounds plausible. If you've perfectly simplified the ring part, shouldn't that be enough? The answer is no, and the counterexample is illuminating.

Consider the expressions *2·m + 4·m* and *6·m*, where *m* is a module variable and we're working modulo 6. Both evaluate to *0·m = 0* (since 6 ≡ 0 mod 6 and 2 + 4 = 6). But sort-selective normalization only simplifies the integer literals, not the expression tree structure. The first expression normalizes to *2·m + 4·m* (the literals 2 and 4 are already in canonical form mod 6), while the second normalizes to *0·m*. Same value, different normalized forms.

This is not a bug — it's a fundamental feature. Sort-selective normalization is *sound* (it never identifies things that are different) but *incomplete* (it can fail to identify things that are the same). Completeness would require understanding the *algebraic* structure of the module, not just the ring. And that would require a module-level simplifier — exactly what we were trying to avoid.

The incompleteness result is itself a theorem, proved by explicit construction of the counterexample. It draws a clear boundary around what selective approaches can achieve.

---

## Why This Matters Beyond Mathematics

The principle of selective normalization has immediate practical implications.

**In compiler design:** Modern programming languages have rich type systems with many sorts — integers, floating-point numbers, strings, lists, trees, functions. A compiler optimization that simplifies integer arithmetic doesn't need to understand list operations, as long as the interface between integers and lists (indexing, length, etc.) is respected. Sort-selective normalization provides the theoretical foundation for proving such optimizations correct *modularly*.

**In software verification:** As software systems grow more complex, verifying them monolithically becomes impossible. The ability to verify one component at a time — and know that the verification is preserved when components are assembled — is the holy grail of modular verification. Sort-selective normalization shows exactly when this is possible: when the congruence is compatible with cross-component operations.

**In scientific computing:** Numerical simulations often mix different physical quantities — temperatures, pressures, velocities — each with their own precision requirements and simplification rules. Sort-selective normalization tells you when you can use a faster approximation for temperatures without invalidating the pressure calculations.

---

## The Deeper Pattern

Stepping back, the theory of sort-selective normalization reveals something about the nature of mathematical structure itself. Complex systems are built from interacting components of different kinds. The conditions under which you can modify one kind without breaking the others are not arbitrary engineering constraints — they are deep structural invariants that connect to the foundations of algebra.

The compatibility condition — that an equivalence on one sort must be respected by all cross-sort operations — is an instance of what mathematicians call a *fibration*. Just as a fiber bundle in geometry describes how local pieces fit together into a global whole, a fibration in algebra describes how equivalences on individual sorts combine into a coherent equivalence on the whole system.

This perspective opens the door to generalizations: three-sorted systems, infinitely-sorted systems, systems where the sorts themselves can vary. Each generalization brings new mathematical challenges, but the core principle remains the same. You can simplify part of a system precisely when the simplification respects the interfaces between parts.

It's a simple idea. But simple ideas, rigorously developed, have a way of reshaping how we think. The next time you substitute one ingredient for another in a recipe — or swap out a software library for a compatible replacement — you're practicing sort-selective normalization. The mathematics just makes it precise.

---

*The research described in this article was verified using machine-checked mathematical proofs, ensuring that every theorem is not just plausible but provably correct.*
