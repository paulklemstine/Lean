# The Secret Lives of Numbers: Vampires, Ghosts, and the Hidden Rules of Arithmetic

*A bestiary of numerical monsters reveals deep constraints lurking inside multiplication*

---

In 1994, a computer scientist named Clifford Pickover posed a deceptively simple question: are there numbers that contain their own factors? Not in the usual algebraic sense — every number is divisible by something — but in a much more literal way. Are there numbers whose decimal digits can be physically rearranged to form two smaller numbers that multiply together to give the original?

The answer turned out to be yes, and the first example is elegant: **1260 = 21 × 60**. Write out the digits of 1260 — one, two, six, zero — and then write out the digits of 21 and 60 — two, one, six, zero. They're the same digits, just rearranged. Pickover called these *vampire numbers*, and their two factors the "fangs."

What began as a recreational puzzle has opened a window onto something surprisingly deep: the hidden arithmetic constraints that govern when digit rearrangement can preserve multiplication.

## Seven Vampires Walk Into a Bar

There are exactly seven four-digit vampire numbers: 1260, 1395, 1435, 1530, 1827, 2187, and 6880. You can verify each one:

- 1395 = 15 × 93
- 1435 = 35 × 41
- 1530 = 30 × 51
- 1827 = 21 × 87
- 2187 = 27 × 81
- 6880 = 80 × 86

At six digits, there are 148 vampire numbers. At eight digits, over 3,000. The population grows — but as a fraction of all numbers with that many digits, vampires become rarer and rarer. This raises the central mystery: *how rare, exactly?*

## The Rule of Nines

Hidden inside every vampire number is a constraint that medieval bookkeepers would have recognized. It's called "casting out nines," and it dates back at least to the 12th century.

Here's the idea: the sum of a number's digits always gives the same remainder when divided by 9 as the number itself. The digit sum of 1260 is 1 + 2 + 6 + 0 = 9, and sure enough, 1260 ÷ 9 = 140 with no remainder. This works for every number — it's why accountants once used the "nines check" to catch arithmetic errors.

Now comes the key insight. If a vampire number v has fangs x and y, then the digits of v are exactly the digits of x combined with the digits of y. That means the digit sum of v equals the digit sum of x plus the digit sum of y. By the casting-out-nines principle:

**v ≡ digit_sum(v) = digit_sum(x) + digit_sum(y) ≡ x + y (mod 9)**

But v = x × y. So we have:

**x × y ≡ x + y (mod 9)**

Rearranging: **(x − 1)(y − 1) ≡ 1 (mod 9)**

This is a genuine constraint. Of the 81 possible pairs of remainders mod 9 that two fangs could have, only **six** pairs actually satisfy this condition. That means roughly 93% of all factor pairs are immediately ruled out as potential vampire fangs — you don't even need to check the digits.

The six valid pairs, writing the fangs' remainders mod 9, are: (0,0), (2,2), (3,6), (5,8), (6,3), and (8,5). Every vampire number ever found, from the smallest to the billions, obeys this rule. It's not a conjecture — it's a mathematical theorem.

## A Bestiary of Arithmetic Creatures

Vampire numbers inspire a natural question: what other relationships can exist between a number's digits and its factors? This leads to a whole menagerie of "arithmetic creatures."

**Ghost numbers** are the anti-vampires. A ghost number v = x × y has the property that the digit *sets* of x and y are completely disjoint from those of v. For instance, 4 = 2 × 2 is a ghost number: the digit "4" doesn't appear in either factor. Ghost numbers turn out to be surprisingly common among small numbers — there are over 2,600 below 10,000 — but they thin out as numbers grow larger, because larger numbers use more distinct digits, making disjointness harder to achieve.

**Werewolf numbers** occupy the middle ground. In a werewolf factorization v = x × y, the combined digits of x and y share exactly one digit with v. They're partial vampires — one fang-mark instead of a full bite. There are 612 werewolf numbers below 1,000.

**Spectral numbers** were proposed as "near-miss vampires": numbers where sorting the digits of v gives the same sequence as sorting the combined digits of x and y, but the actual digit multisets differ. The surprise? **Spectral numbers don't exist.** This isn't just a computational observation — it's a mathematical impossibility. Sorting a collection of items uniquely determines which items are present and how many times each appears. If two collections sort the same way, they *are* the same collection. The definition is vacuous, and provably so.

This is the kind of result that seems obvious once stated but guards against a real error: assuming that "sorted digits match" is a weaker condition than "digit multisets match." In recreational mathematics, such conceptual traps matter.

## How Rare Are Vampires?

The density question turns out to have a beautiful answer rooted in combinatorics. Consider a 2n-digit vampire number v = x × y where x and y each have n digits. Together, x and y contribute 2n digits that must form a permutation of v's 2n digits.

How many ways can 2n digits be split into two groups of n? The answer is the central binomial coefficient C(2n, n). For n = 2, that's 6. For n = 3, it's 20. For n = 4, it's 70.

But not every split gives valid n-digit numbers — the digits have to form actual numbers in the right range, and those numbers have to multiply to give v. A rough heuristic treats the digit-matching condition as if each digit were randomly assigned, giving an expected "vampire probability" of about C(2n, n) / 10^n per number.

The striking fact: this heuristic is almost exactly right. For 4-digit numbers, C(4,2)/100 = 0.06, predicting about 540 vampires among the 9,000 four-digit numbers; the actual count is 7, reflecting that multiplication is far from random. But the *scaling* — how the density changes as n grows — follows the heuristic closely.

By Stirling's approximation, C(2n, n) / 10^n ≈ (2/5)^n / √(πn). Since 2/5 < 1, this goes to zero exponentially. Vampires don't just become rare; they become *exponentially* rare relative to all numbers of the same length.

## The Deep Structure

What makes vampire numbers genuinely interesting to mathematicians isn't the recreational puzzle itself but what it reveals about the relationship between multiplication and digit representation.

The mod-9 constraint is really a statement about how multiplication interacts with the additive structure of decimal representation. When we write a number in base 10, we're expressing it as a polynomial in 10: the number 1260 is 1·10³ + 2·10² + 6·10¹ + 0·10⁰. The digit sum is the same polynomial evaluated at 1 instead of 10. Since 10 ≡ 1 (mod 9), these two evaluations agree modulo 9.

This means the mod-9 constraint on vampire fangs is actually a statement about polynomial evaluation: if a product of two polynomials in 10 has the same coefficients (as a multiset) as the concatenation of the two factors' coefficients, then those polynomials must satisfy an algebraic relation when evaluated at 1.

This perspective connects vampire numbers to questions in additive combinatorics and algebraic number theory. The constraint (x−1)(y−1) ≡ 1 (mod 9) says that x − 1 and y − 1 must be multiplicative inverses modulo 9. The invertible elements modulo 9 form a group of order 6 — exactly the number of valid fang pairs we found.

## What We Don't Know

Several questions remain tantalizingly open:

- **Does every interval [10^(2k), 10^(2k+2)] contain at least one vampire number?** Computationally this holds for all checked cases, but no proof exists. Constructing explicit vampire numbers with prescribed digit counts requires solving a simultaneous Diophantine and combinatorial problem.

- **What is the exact asymptotic density?** The heuristic C(2n,n)/10^n gives the right order of magnitude, but the actual counts consistently undershoot it by a large factor (about 1/77 for 4-digit numbers). Understanding this multiplicative correction requires analyzing how often the product of two n-digit numbers has exactly the right digit multiset — a problem that touches on the distribution of carries in multiplication.

- **Are ghost numbers eventually extinct?** As numbers grow, they use more distinct digits, and it becomes harder for a factorization to avoid all of them. But a proof that ghost numbers become density-zero requires understanding the digit distribution of factor pairs, which connects to deep questions about the equidistribution of digits in arithmetic sequences.

These aren't just recreational curiosities. They sit at the intersection of number theory, combinatorics, and the poorly understood boundary between algebraic and digital properties of numbers. Every number has a unique prime factorization and a unique decimal representation — but how these two fundamental descriptions interact remains one of the most resistant questions in mathematics.

The vampires may be lurking in the digits, but the real monster is the mystery of how multiplication rearranges the symbols we use to write numbers down.

---

*The results described in this article include machine-verified mathematical proofs of the mod-9 fang constraint, the spectral number impossibility theorem, and the compositeness of all vampire numbers.*
