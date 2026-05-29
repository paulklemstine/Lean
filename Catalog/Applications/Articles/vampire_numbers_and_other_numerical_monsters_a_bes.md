# When Multiplication Plays Anagrams: The Hidden Structure of Arithmetic Monsters

*What happens when you multiply two numbers and the digits rearrange themselves perfectly? A new mathematical framework reveals that these playful curiosities hide deep structural truths about how numbers work.*

---

In 1994, a Colorado computer scientist named Pete Hartley published a short note about a peculiar class of numbers he called "vampires." The number 1260, for instance, can be written as 21 × 60 — and if you take the digits of both factors and rearrange them, you get exactly the digits of 1260 itself. The digits of the product are, in a precise sense, an anagram of the digits of its factors.

For years, vampire numbers lived in the mathematical equivalent of a cabinet of curiosities: interesting to collect, fun to show at parties, but not obviously *about* anything. They appeared alongside other digit-based oddities — numbers whose digits, when rearranged, produced other special numbers — in what mathematicians politely call "recreational" number theory. The implication, sometimes unstated, was that these objects were too frivolous for serious attention.

That judgment turns out to be wrong.

## The Digit Bag: Seeing Numbers Differently

The breakthrough comes from asking a deceptively simple question: what exactly is a "digit"?

When we write 1260 in base 10, we get the sequence 1-2-6-0. But the *order* of these digits doesn't matter for the vampire property. What matters is the *inventory*: one copy of 1, one copy of 2, one copy of 6, one copy of 0. This inventory — mathematicians call it a **multiset** or, more informally, a **digit bag** — is the right object to study.

Once you think in terms of digit bags rather than digit strings, something remarkable happens: the definitions stop depending on base 10. A "vampire pair" in base 7, or base 16, or base 1000 makes exactly the same structural sense. The digit bag of the product must equal the combined digit bags of its two factors.

And that single abstraction — replacing digit strings with digit bags — unlocks a cascade of theorems.

## The First Surprise: Casting Out Nines, Generalized

Most people who took arithmetic in school have encountered "casting out nines" — the trick where you can check multiplication by adding up digits and comparing remainders when divided by 9. The number 1260 has digit sum 1+2+6+0 = 9, which leaves remainder 0 when divided by 9. The factors 21 and 60 have digit sums 3 and 6, totaling 9, also remainder 0. Coincidence?

Not at all. For vampire numbers, this relationship is not just a pattern — it is a theorem, and it works in every base.

Here is the precise statement: if *v* = *x* × *y* is a vampire number in base *b*, then

> *v* ≡ *x* + *y* (mod *b* − 1)

In words: the product, when divided by *b* − 1, leaves the same remainder as the *sum* of its factors. Since *v* = *x* × *y*, this means *x* × *y* ≡ *x* + *y* (mod *b* − 1), which algebraically rearranges to the elegant condition:

> (*x* − 1)(*y* − 1) ≡ 1 (mod *b* − 1)

In base 10, this becomes (*x* − 1)(*y* − 1) ≡ 1 (mod 9). This single congruence eliminates over 90% of candidate factor pairs before you even check their digits. It transforms a brute-force search into something closer to a sieve — the same strategy that number theorists have used since Eratosthenes to hunt for primes.

The proof is surprisingly clean. Every integer is congruent to its digit sum modulo *b* − 1 (because *b* ≡ 1 mod *b* − 1, so powers of the base contribute nothing to the remainder). And the digit-bag equality guarantees that the digit sum of the product equals the sum of the digit sums of the factors.

## Ghost Numbers and the Binary Wall

With the framework in place, mathematicians can define new creatures. A **ghost number** is a product *v* = *x* × *y* where the product shares *no* digits with either factor. The digit bags of *v* and *x* are completely disjoint, and so are those of *v* and *y*.

This sounds like it should be easy to construct: just pick factors whose product uses entirely different digits. And indeed, in base 10, ghost numbers appear freely. The number 52 = 4 × 13, for example: the digits of 52 are {5, 2}, the digits of 4 are {4}, and the digits of 13 are {1, 3}. No overlap at all.

But try to construct a ghost number in base 2 — binary — and you hit a wall. A *theorem*, in fact:

> **Ghost numbers are impossible in base 2.**

The proof is elegant in its simplicity. In binary, the only digits are 0 and 1. Every positive number, written in binary, must contain at least one 1 (otherwise it would be zero). So the digit bag of any positive number includes the digit 1. But that means the digit bags of *v*, *x*, and *y* all contain at least one 1, so *v* and *x* necessarily share a digit. Ghost condition violated.

This is not just a curiosity — it is a **phase transition**. The ghost species goes extinct precisely at the boundary between base 2 and base 3. In base 3 and above, digit-disjoint pairs become plentiful; in base 2, they vanish entirely. The theory depends sharply on the size of the digit alphabet.

## The Digit Length Theorem

A third theorem captures another piece of vampire folklore and makes it rigorous. If *v* = *x* × *y* is a vampire number, then:

> The number of digits of *v* equals the number of digits of *x* plus the number of digits of *y*.

Traditional vampire number hunters knew this as the rule that "a 4-digit vampire has two 2-digit fangs." But the theorem shows it holds in every base and for every combination of fang lengths. The proof is simple once you have digit bags: the total number of digits is just the total count across all bag entries, and bag equality preserves this sum.

This has a striking corollary for equal-length fangs: if both factors have the same number of digits, then the product must have an even number of digits. No 5-digit number can be a vampire with equal-length fangs.

## An Infinite Graph of Non-Overlapping Numbers

Perhaps the most visually striking result concerns the **digit-disjointness graph**. Imagine drawing a vertex for every positive integer and connecting two vertices with an edge whenever those numbers share no base-*b* digits.

In base 2, this graph has no edges at all among positive integers — the binary impossibility theorem again. But for any base *b* ≥ 3, the graph has infinitely many edges.

The proof constructs explicit witnesses. In base *b*, the number *b*^*k* has the digit representation [0, 0, ..., 0, 1] (a 1 followed by *k* zeros). The number *b*^(*k*+1) − 1 has the representation [*b*−1, *b*−1, ..., *b*−1] (all digits equal to *b*−1). Since digits 0 and 1 are distinct from *b*−1 when *b* ≥ 3, these two numbers are digit-disjoint. And since *k* can be arbitrarily large, there are infinitely many such pairs.

This is a true structural dichotomy: the digit-disjointness graph undergoes a phase transition at base 3, going from a graph with no edges to one with infinitely many.

## Why This Matters Beyond Puzzles

At first glance, all of this might seem like mathematical stamp collecting elevated by fancy language. But there is a deeper point.

The digit bag of a number is a **finite invariant** of an arithmetic object. It captures how the symbolic representation of a number (its string of digits) relates to its multiplicative structure. This is the same kind of question that drives some of the deepest problems in number theory: how does the *additive* structure of numbers (digits, sums) interact with their *multiplicative* structure (factors, primes)?

The congruence obstruction for vampire numbers is, in miniature, the same phenomenon that powers the theory of sieves in analytic number theory. The phase transition in the digit-disjointness graph is structurally analogous to percolation thresholds in statistical physics. And the digit bag itself is a finite-state invariant of the kind that appears in automata theory and symbolic dynamics.

These connections are not metaphorical. The set of positive integers whose base-*b* representation uses only digits from a prescribed alphabet forms a regular language — a set recognizable by a finite automaton. Digit-disjointness is then a property of pairs of regular languages. The digit-disjointness graph becomes a combinatorial object whose structure reflects the interaction between multiplication and finite-state constraints.

## The Sieve at Work

The practical impact of the congruence theorem is immediate. When searching for 6-digit vampire numbers in base 10, a naive approach must check roughly 180,000 factor pairs. The mod-9 sieve eliminates about 92.5% of them, reducing the search to under 14,000 pairs. For 8-digit vampires, the savings are even more dramatic.

This is exactly how sieves are supposed to work: a cheap arithmetic test that discards most candidates, leaving a manageable set for expensive verification. The mod-(*b*−1) condition is the analogue, for digit-rearrangement problems, of the Eratosthenes sieve for primes.

Computational experiments confirm the theory. Among 4-digit vampire candidates in base 10, the sieve eliminates 92.4% of factor pairs. The surviving pairs include all actual vampires — the sieve is provably sound, meaning it never rejects a genuine vampire pair.

## The Monsters as a Laboratory

What makes this framework genuinely promising is not any single theorem but the architecture. The definitions are base-independent. The theorems are structural, not just computational. And the proofs use techniques — congruences, counting arguments, explicit constructions — that connect to established mathematical traditions.

The vampire, ghost, and their kin are not the point. They are specimens in a laboratory for studying a question that turns out to be surprisingly rich: **how does multiplication rearrange the finite symbolic information in a number's digits?**

That question touches coding theory (digit-constrained codes), combinatorics (multiset invariants), graph theory (adjacency by disjoint support), and even information theory (digit entropy under multiplication). The playful names are bait. The mathematics is real.

## What Comes Next

The immediate frontier is density: how common are vampire numbers? Computational evidence suggests they become increasingly sparse as numbers grow, but proving this rigorously requires new tools. The ghost scarcity conjecture — that the counting function of ghost numbers grows slower than any power of *N* — remains open and testable.

Beyond density, the digit-disjointness graph invites graph-theoretic investigation. What is its chromatic number? Does it contain large cliques? Is there a spectral theory for this graph that connects to the arithmetic properties of its vertices?

And there is a tantalizing connection to automatic sequences and finite automata. Numbers whose digit strings belong to a regular language form a class with rich algebraic structure. The interaction between this structure and multiplication is largely unexplored territory.

The arithmetic monsters were born as curiosities. They may yet grow into a theory.
