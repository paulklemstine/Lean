# When Numbers Eat Their Own Digits

## The Strange World of Vampire Numbers and the New Mathematics of Digit Interaction

---

There is something deeply peculiar about the number 1,260.

Multiply 21 by 60. You get 1,260. Now look at the digits: the product uses exactly the digits 1, 2, 6, and 0 — the same digits as its factors 21 and 60. The act of multiplication has shuffled the digits without creating or destroying a single one. Mathematicians call 1,260 a **vampire number**, and for three decades, these numerical curiosities have lurked at the margins of mathematics, dismissed as recreational oddities. Until now.

A new body of work has transformed vampire numbers from party tricks into the foundation of a rigorous mathematical theory — one that reveals deep connections between how we write numbers and how arithmetic works. The key insight is deceptively simple: forget about individual digits and think about *digit bags*.

---

## The Digit Bag Revolution

When you write the number 1,260 in base 10, you use the digits {0, 1, 2, 6}. But the *order* of these digits matters for the number's value — 1,260 is very different from 6,210. A digit bag strips away the order and keeps only the inventory: how many of each digit appears. For 1,260, the digit bag is: one 0, one 1, one 2, one 6.

This sounds like a loss of information, and it is. But it turns out to be exactly the right loss. The digit bag captures everything that matters about how multiplication interacts with digit representations.

Think of it like chemistry. When you combine hydrogen and oxygen, you get water. A chemist doesn't care about the *positions* of atoms before the reaction — only about the *inventory*: how many hydrogen atoms, how many oxygen atoms. The digit bag plays the same role for arithmetic that chemical formulas play for reactions. It's the bookkeeping system that makes conservation laws visible.

And conservation laws are exactly what emerge.

---

## The Conservation Laws of Digit Arithmetic

The first discovery is a sieve — a filter that can instantly reject most candidate vampire pairs. For any vampire number v = x × y, the theory proves that v must be congruent to x + y modulo 9 (in base 10). This is a generalization of the ancient technique of "casting out nines," which dates back to medieval Arabic mathematics. But here it gets teeth: in base 10, this single test eliminates roughly 89% of all candidate factor pairs without any digit-by-digit comparison.

The sieve efficiency varies by base. In base 6, it eliminates 80% of candidates. In base 16, it eliminates 93%. The general formula is (b-2)/(b-1) for base b — a clean, universal law.

But the sieve is just the beginning. The deeper result is about **digit length additivity**: if v = x × y is a vampire number, then the number of digits in v equals the sum of the number of digits in x and y. Always. Without exception. This means vampire numbers can only arise from factor pairs whose digit lengths sum to exactly the right value — another powerful constraint that narrows the search space dramatically.

These two results together — the modular sieve and the length constraint — form what might be called the *First Law of Digit Conservation*: multiplication cannot be digit-preserving unless very specific arithmetic conditions are met.

---

## The Ghost Impossibility Theorem

If vampire numbers are products that preserve all digits, what about the opposite extreme? A **ghost number** is a product that shares *no* digits with either of its factors. Can such perfect digit-avoidance exist?

The answer depends on the base, and the proof reveals something beautiful about binary arithmetic.

In base 2, every positive number must contain the digit 1 somewhere in its representation. (A number made entirely of 0s would be... zero.) This means any two positive numbers in binary automatically share the digit 1, making digit-disjointness impossible. Ghost numbers cannot exist in binary.

But in base 3 and higher, ghosts roam freely. Consider base 3: the number 3^k (written in base 3 as a 1 followed by k zeros) shares no digits with 3^(k+1) - 1 (written as k+1 copies of the digit 2). There are infinitely many such pairs in every base ≥ 3.

This clean dichotomy — impossible in base 2, infinite in base 3 — captures something fundamental about how the structure of a number system constrains digit interactions.

---

## When Pythagorean Geometry Meets Digit Theory

Perhaps the most surprising result connects digit theory to one of the oldest problems in mathematics: Pythagorean triples.

For any right triangle with integer sides a, b, and hypotenuse c (so that a² + b² = c²), there is a hidden digit constraint. Take the digit sum of each side, square them, and reduce modulo 9. The theory proves:

**digitSum(a)² + digitSum(b)² ≡ digitSum(c)² (mod 9)**

This is remarkable because it links two seemingly unrelated structures: the additive structure of digit sums (which depends on how we *write* numbers) and the multiplicative structure of Pythagorean equations (which is a fact of pure geometry). The digit representation of a number is an accident of notation — and yet it obeys the same algebraic law as the Pythagorean theorem itself.

The proof works by chaining two insights. First, the casting-out-nines theorem tells us that every number is congruent to its digit sum mod 9. Second, congruence is preserved under squaring and addition. So the Pythagorean equation a² + b² = c² passes through the digit-sum homomorphism undistorted.

---

## Carry-Free Arithmetic: Where Addition Behaves

Every child who learns to add multi-digit numbers learns about carrying. When 7 + 8 = 15, the 1 "carries" to the next column. Carries are the mechanism by which addition scrambles digit sums — they're the source of all the complexity in digit arithmetic.

But what happens when there are no carries? When every column's digits sum to less than the base?

The theory proves that carry-free addition perfectly preserves digit sums: if adding a and b produces no carries, then digitSum(a + b) = digitSum(a) + digitSum(b). Furthermore, the digit length of the sum equals the maximum of the two addends' lengths — no extra digit is ever created.

This might seem like a narrow special case, but it's actually a window into a deeper principle. Carries are the *only* source of non-additivity in digit sums. Every time a digit sum changes under addition, you can trace it to a specific carry event. The carry-free theorem makes this precise: remove the carries, and perfect conservation is restored.

---

## The Digit Interaction Signature

To understand how "far" a multiplication is from being vampire-like, the theory introduces a new concept: the **digit interaction signature**. For any product v = x × y, the signature decomposes the digit transformation into three quantities:

- **Preserved**: digits appearing in both the product and the combined factors
- **Created**: digits appearing in the product but not the factors
- **Destroyed**: digits appearing in the factors but not the product

A vampire number has signature (n, 0, 0) — all digits preserved, none created or destroyed. An ordinary multiplication might have signature (1, 2, 3) — extensive digit reshuffling.

The theory proves a **conservation law** for these signatures: preserved + created always equals the number of digits in the product. Digits aren't really created from nothing; they're transformed from destroyed digits through the mechanism of carries.

Visualizing these signatures across all two-digit multiplications reveals a striking pattern. Most products are surrounded by digit chaos — heavy creation and destruction. Vampire numbers appear as rare islands of perfect conservation, standing out against the turbulent background like calm eyes in a storm.

---

## A Complexity Bound for Vampire Numbers

The theory also establishes a bound on the **digit complexity** of vampire numbers — the number of distinct digits they use. For any vampire v = x × y, the number of distinct digits in v is at most the total number of distinct digits in x and y combined. 

This is a strengthening of the digit-bag conservation law. Not only are total digit counts preserved, but the number of *types* of digits never increases. Multiplication can merge digit types (if x and y happen to share a digit), but it can never split a digit type into new ones.

---

## The Bigger Picture

What makes this work significant is not any single theorem, but the framework. By treating digit bags as the fundamental object — not individual digits, not digit sums, but the full multiset profile — the theory transforms scattered recreational observations into a coherent mathematical structure with conservation laws, impossibility results, and cross-domain connections.

The modular sieve is not just a computational trick; it's the shadow of a homomorphism. The ghost impossibility is not just a curiosity; it's a topological fact about binary representations. The Pythagorean obstruction is not just a coincidence; it's a consequence of functoriality.

And the theory is far from complete. Open questions abound: What is the asymptotic density of vampire numbers? Do they satisfy a power law? Can the digit interaction signature be extended to products of three or more factors? What happens in non-integer bases?

What began as a recreational puzzle — numbers that eat their own digits — has opened a window into the deep structure of arithmetic. The digits we use to write numbers are not passive labels. They are active participants in the drama of multiplication, obeying their own laws, creating their own patterns, and revealing hidden connections between geometry, algebra, and combinatorics.

The monsters, it turns out, were mathematics all along.
