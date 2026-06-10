# When Is Evaluating the Same as Simplifying?

## The Surprising Mathematics Behind Every Calculator, Compiler, and Search Engine

There's a peculiar magic trick hiding inside every piece of software you've ever used. When your calculator computes `2 + 3 × 4`, it doesn't just find the answer — it *simplifies* an expression. When a search engine processes your query, it doesn't just look up results — it *reduces* a complex logical formula to its essential meaning. And when a compiler translates code into machine instructions, it doesn't just translate — it *normalizes* your program into a canonical form.

For decades, mathematicians and computer scientists treated these as separate activities. Evaluation was one thing — plug in values, get an answer. Simplification was another — rewrite an expression into a shorter, cleaner form. The two happened to produce the same result, but surely that was just a coincidence?

It turns out it's not a coincidence at all. It's a theorem.

## The Thought Experiment

Imagine you're an accountant tallying up a complex expense report. The report is organized into departments, each with its own sub-list of expenses. You could add up all the numbers in one long sum — flattening the entire report into a single list and totaling it. Or you could total each department first, then add up the department totals.

Common sense says these should give the same answer. But *why*? And more importantly: is this always true, regardless of what operation you're performing, regardless of how deeply nested the structure is, and regardless of what mathematical system you're working in?

The answer comes from a branch of mathematics called *category theory*, which studies the patterns that recur across all of mathematics. In the 1960s, mathematicians Samuel Eilenberg and John Moore discovered a framework — now called Eilenberg-Moore algebras — that captures this "departmental accounting" property in its most general form. What they found was stunning: the very conditions that make an operation well-defined are *exactly* the conditions that guarantee simplification works correctly.

## The Two Laws of Correct Simplification

To understand the insight, consider any operation that takes a list of things and produces a single result. Addition takes a list of numbers and produces their sum. Multiplication takes a list of numbers and produces their product. String concatenation takes a list of words and produces a sentence.

Any such operation must satisfy two basic laws to be "well-behaved":

**The Unit Law**: If you give it a list containing just one item, you get that item back. The sum of `[7]` is `7`. The product of `[42]` is `42`. This seems trivially obvious — but it's actually saying something profound. It means the operation doesn't distort individual values. It's a *faithful* evaluator.

**The Composition Law**: If you have a list of lists — say, departments containing expenses — then flattening everything into one big list and evaluating gives the same result as evaluating each sub-list first, then evaluating the results. In symbols:

> evaluate(flatten(list_of_lists)) = evaluate(map(evaluate, list_of_lists))

This is the compositionality principle: you can break a big computation into pieces, compute each piece independently, and then combine — and you'll get the same answer as if you'd done it all at once.

## The Punchline: Structure = Simplification

Here's where it gets remarkable. These two laws — the unit law and the composition law — are not just nice properties of evaluation. They are *exactly equivalent* to the axioms of a monoid, one of the most fundamental structures in all of algebra.

A monoid is a set with a binary operation (like addition or multiplication) that is associative and has an identity element. Think of the integers under addition (identity: 0), or the positive reals under multiplication (identity: 1), or strings under concatenation (identity: empty string).

The theorem we've proved states: **A type carries a list-evaluation structure satisfying the two laws if and only if it carries a monoid structure.** The evaluation map *is* the monoid product. The unit law *is* the identity axiom. The composition law *is* associativity in disguise.

This isn't just an analogy. It's a mathematical equivalence, proved rigorously. Every monoid gives you a correct simplifier (just fold the list using the monoid operation). And every correct simplifier gives you a monoid (define multiplication as "evaluate a two-element list").

## Why This Matters: The Verification Is Free

The practical consequence is extraordinary. Once you know your operation forms a monoid — which for most operations in computing, it does — you get a *verified* simplification algorithm for free. You don't need to separately prove that your simplifier is correct. The algebraic structure *guarantees* it.

Consider the Berggren tree, a beautiful structure from number theory that generates all primitive Pythagorean triples — the integer solutions to a² + b² = c² like (3, 4, 5) and (5, 12, 13). The tree works by multiplying 3×3 integer matrices. Matrix multiplication forms a monoid. Therefore, the matrix evaluation map is automatically a correct normalizer: you can compute the product of a long chain of Berggren matrices in any order — grouping sub-chains, parallelizing across processors, caching intermediate results — and the answer is guaranteed to be the same.

This isn't just a theoretical nicety. In distributed computing, where calculations are split across hundreds of machines, knowing that your reduction operation is associative and has an identity is exactly what frameworks like MapReduce and Apache Spark rely on. The monoid structure is what makes parallel aggregation correct. Our theorem says this is not just a convenient property — it's the *only* property that matters.

## The Uniqueness Surprise

There's a further surprise. Not only does every monoid give you a correct normalizer — it gives you the *only* correct normalizer (up to the natural boundary conditions). If your normalizer handles the empty list by returning the identity, and handles two-element lists by multiplying, then for *every* list, it must agree with the standard product. There's no room for creativity. The algebra forces your hand.

This uniqueness result means that any two "reasonable" implementations of the same algebraic simplification must agree. It's an impossibility theorem for alternative implementations: if you satisfy the basic contracts, your algorithm is determined. This has implications for software verification — you don't need to test all possible inputs. If you verify the contracts, correctness follows everywhere.

## The Deeper Pattern

The equivalence between evaluation and simplification is an instance of a much deeper pattern in mathematics. Category theorists call it the *Eilenberg-Moore comparison theorem*, and it applies far beyond lists and monoids.

Replace "list" with "tree" and you get the theory of operads — algebraic structures that govern multi-input operations. Replace "monoid" with "ring" or "lattice" or "group" and you get analogous equivalences for those structures. The pattern is universal: **for any algebraic theory, there is a monad whose algebras are exactly the models of that theory, and the algebra structure map is exactly the evaluation/normalization map.**

This is why the same ideas keep showing up across seemingly unrelated fields. The word "normalization" appears in:
- **Database theory**: putting tables into normal forms
- **Quantum mechanics**: normalizing wave functions
- **Logic**: reducing proofs to normal form
- **Linguistics**: reducing sentences to canonical parse trees

In each case, the mathematical structure is the same. There is a "free" construction (formal expressions), a "forgetful" operation (throwing away structure), and an evaluation map that reduces formal expressions to values. The correctness of that evaluation map is guaranteed by the same abstract laws.

## The Complexity Bonus

One might worry that verified simplification comes at a computational cost — that all this mathematical structure slows things down. In fact, the opposite is true.

For a list of *n* elements in a monoid, normalization requires exactly *n − 1* multiplications. No verification overhead. No additional passes. The algebraic structure doesn't add cost — it just guarantees that the straightforward left-to-right fold is already optimal.

This is why the connection to Pythagorean triples is more than a curiosity. Generating all primitive Pythagorean triples up to a given bound requires walking the Berggren tree — which means multiplying sequences of matrices. The compositionality theorem guarantees that this can be done in any order with the same result, enabling massive parallelization. And the complexity theorem says each multiplication chain of length *n* costs exactly *n − 1* matrix multiplications. Structure, correctness, and efficiency — all from the same source.

## A Bridge Between Worlds

Perhaps the most surprising aspect of this work is how many bridges it builds. The same theorem connects:

- **Algebra** (monoids) to **category theory** (Eilenberg-Moore algebras)
- **Formal language theory** (free monoids, words) to **term rewriting** (normalization, confluence)
- **Number theory** (Pythagorean triples, Berggren trees) to **linear algebra** (matrix products)
- **Abstract mathematics** to **practical computing** (MapReduce, compilers, interpreters)

Each of these connections was known informally. What's new is seeing them all as instances of a single, precise theorem — and proving that theorem rigorously.

The next time your calculator instantly simplifies a complex expression, or your code compiles in seconds, or a distributed system aggregates results from a thousand machines — remember that behind the scenes, a piece of abstract algebra is quietly guaranteeing that everything works. Evaluation and simplification are not two different things. They never were. They are the same mathematical act, viewed from two different angles. And we can prove it.
