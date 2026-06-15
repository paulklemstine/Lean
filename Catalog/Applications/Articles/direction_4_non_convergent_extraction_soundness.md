# The Optimizer That Doesn't Need a Destination

## How mathematicians proved that software can be optimized without knowing what "simple" means

---

Imagine you're lost in a city with no map. You can see the buildings around you, and you know that certain streets connect equivalent neighborhoods — walk down any of them and you'll end up somewhere just as good. A friend tells you there's a cheaper apartment somewhere in your neighborhood. Can you find it?

The conventional wisdom in computer science has been: only if you know the *best* address in advance. If you can compute the "simplest" or "canonical" version of your neighborhood, then sure, you can find the cheapest equivalent. But if the city is too tangled — if streets loop back on themselves, if there's no clear "downtown" — then you're stuck.

A new mathematical result overturns this conventional wisdom. It proves that you don't need a canonical address at all. You just need one guarantee: every street connects genuinely equivalent places. With that single promise, *any* apartment you find in your neighborhood will work just as well as the one you started with.

This isn't just an abstract curiosity. It's a theorem about how computers optimize programs, circuits, and mathematical expressions — and it opens the door to optimization in domains where the classical approach has always failed.

---

## The Problem with Normal Forms

Since the 1930s, mathematicians and computer scientists have relied on a powerful idea: *normal forms*. Given a mathematical expression, apply simplification rules until you can't apply any more. The result is the normal form — a canonical representative of all equivalent expressions.

Normal forms are beautiful when they work. The number 12 is the normal form of "3 × 4" and "2 × 6" and "1 + 1 + 1 + ... + 1" (twelve times). When you want to check if two expressions are equal, just compute their normal forms and compare.

But normal forms require two properties of the simplification rules:

1. **Termination**: you must eventually stop. You can't keep simplifying forever.
2. **Confluence**: no matter which rule you apply first, you reach the same final answer.

Together, these properties make a rewrite system *convergent*. Convergent systems are the workhorses of computer algebra, compiler optimization, and automated reasoning.

The trouble is, many important systems aren't convergent. Commutativity — the fact that *a + b = b + a* — is a perfectly valid rule, but it's not oriented. Applying it doesn't simplify anything; it just shuffles terms around. And if you add both "remove zero" (*x + 0 → x*) and "add zero" (*x → x + 0*), you get a system that never terminates.

In programming languages, the situation is even worse. The lambda calculus — the mathematical foundation of functional programming — has reduction rules (called β and η) that are non-terminating for many programs. Some programs have no normal form at all. The term Ω = (λx. x x)(λx. x x) reduces to itself forever.

For decades, this seemed like a fundamental barrier. If you can't compute normal forms, how can you optimize?

---

## Enter the E-Graph

In the early 2000s, a data structure called the *e-graph* (equality graph) began to transform the landscape. Originally developed for theorem provers, e-graphs were repurposed for optimization through a technique called *equality saturation*.

The idea is radical. Instead of simplifying an expression step by step toward a normal form, an e-graph records *all* the equivalent expressions simultaneously. It's like building a map of your entire neighborhood at once, rather than trying to navigate to a single destination.

Here's how it works. Start with a program. Apply every applicable rewrite rule in every possible way, but instead of choosing one result, record all of them as equivalent. Keep going. Eventually, the e-graph contains a rich set of alternatives. Then — and this is the key step — *extract* the cheapest one.

Equality saturation has proven spectacularly effective. It powers optimizers for floating-point arithmetic, hardware synthesis, database query planning, and machine learning compilers. The egg library (e-graphs good) and its descendants have enabled optimizations that traditional compilers miss entirely.

But there was always a nagging theoretical question: *why does extraction work?*

---

## The Missing Theorem

Every practitioner knew intuitively that extraction should preserve meaning. If you only merge expressions that compute the same thing, then picking any representative from a merged group should give you something that computes the same thing.

But the formal justification was tangled up with convergence. The existing proofs typically went like this: "If the rewrite system is convergent, then equivalent terms have the same normal form, so they have the same semantics." Convergence was doing the heavy lifting.

This created an uncomfortable situation. The systems that equality saturation worked *best* on — non-confluent algebraic identities, commutative and associative laws, bidirectional rules — were exactly the systems where the convergence-based proof didn't apply.

It was as if someone had proved that bridges can support cars by showing that the steel is strong — but only for bridges over rivers less than 100 meters wide. The wider bridges worked too, everyone could see that, but the theorem didn't cover them.

---

## The Breakthrough

The new result cuts through this confusion with a single clean theorem:

> **If every rewrite step preserves the meaning of an expression, then the equivalence closure of those steps also preserves meaning. No confluence, no termination, no orientation required.**

The proof is almost embarrassingly natural once you see it. The equivalence closure of a rewrite relation is built from four operations: applying a rule forward, applying it backward, doing nothing (reflexivity), and chaining steps together (transitivity). If each forward step preserves meaning, then backward steps do too (by symmetry of equality). Doing nothing obviously preserves meaning. And chaining meaning-preserving steps preserves meaning.

That's it. Four cases. The theorem falls out by structural induction on how the equivalence was built, with no reference to convergence at all.

From this foundation, a second theorem follows immediately:

> **Any extractor that returns a representative from the same equivalence class preserves semantics.**

If the extractor picks a term equivalent to the original, and equivalence preserves meaning, then the extracted term has the same meaning. The proof is two lines.

---

## Why This Changes Everything

These theorems are simple, but their implications are profound. They reframe what equality saturation *is*.

Under the old view, equality saturation was a clever heuristic for exploring the space of equivalent programs, with correctness guaranteed by the underlying theory of convergent rewriting. If your rules didn't converge, you were in uncharted territory.

Under the new view, equality saturation is a **theorem about semantic quotients**. An equivalence class of expressions is really a point in a quotient space — a mathematical structure where equivalent things are identified. The denotation function (the map from expressions to their meanings) factors through this quotient. Extraction is just choosing a representative from a quotient class.

This is a much older and more powerful idea. Quotient structures appear everywhere in mathematics: the integers modulo *n*, the rational numbers (equivalence classes of fractions), topological spaces (identification of boundary points). The theory of quotients is one of the most well-developed areas of mathematics.

By connecting equality saturation to quotient theory, the new result makes the entire apparatus of abstract algebra, universal algebra, and category theory available to optimizer designers.

---

## Compositional Soundness

But the abstract theorem is only the beginning. Real programs are not flat expressions; they're built compositionally. An expression *a + b* contains subexpressions *a* and *b*, and optimizing a subexpression should preserve the meaning of the whole.

A third theorem addresses this: if a rewrite relation preserves meaning, then its *contextual closure* — the relation obtained by allowing rewrites inside subexpressions — also preserves meaning. And the equivalence closure of the contextual closure preserves meaning too.

This is the theorem that justifies real compilers. When a compiler rewrites `x * (y + 0)` to `x * y` inside a larger program, the meaning of the whole program is preserved, even though the rewrite system (with commutativity, identity elements, and distribution) is hopelessly non-confluent.

---

## Beyond Arithmetic: Combinators and Circuits

The theorems are stated at a level of generality that makes them portable across domains. To demonstrate this, the researchers applied them to two notoriously difficult settings.

**SK combinators.** The SK combinator calculus is a model of computation where every program is built from just two symbols, S and K, combined by application. It's Turing-complete: it can compute anything a modern computer can. But it's also famously non-normalizing. Many SK terms have no normal form — they reduce forever without reaching a fixed point.

Despite this, the theorem applies. If you interpret S and K in any mathematical model satisfying their defining equations (S x y z = (x z)(y z) and K x y = x), then the equivalence closure of SK reduction preserves meaning. You can extract optimized SK programs without ever computing a normal form.

**Boolean circuits.** Digital circuits are optimized using algebraic identities: De Morgan's laws, double negation elimination, idempotence, absorption. These identities overlap in complex ways, creating a non-confluent rewrite system. The theorem guarantees that any circuit extracted from an e-graph of equivalent circuits computes the same boolean function as the original.

---

## The Deeper Pattern

Step back and look at what's really going on. The theorem identifies a pattern that recurs across mathematics and engineering:

1. You have a language of expressions (programs, circuits, formulas).
2. You have a notion of meaning (semantics, denotation, interpretation).
3. You have local transformation rules that preserve meaning.
4. You want to know: does *any chain of transformations* preserve meaning?

The answer is always yes, and the reason is always the same: meaning factors through the equivalence quotient. This is not a fact about rewriting. It's a fact about algebra.

In category theory, this pattern has a name: the meaning function is a *morphism* that is constant on equivalence classes. The quotient by the equivalence relation carries a unique *induced morphism* from the quotient to the semantic domain. Extraction is a *section* — a choice of representative from each equivalence class.

These are standard concepts, studied for a century. What's new is the realization that they are exactly the right language for talking about program optimization.

---

## What Comes Next

The immediate practical impact is in compiler and optimizer design. Engineers can now use equality saturation with confidence in domains where convergence fails — higher-order languages, effect systems, quantum circuits, algebraic data types. The theorem provides a correctness guarantee that doesn't depend on the details of the rewrite rules, only on their semantic soundness.

The deeper impact is conceptual. By connecting optimization to quotient theory, the result opens doors to:

- **Synthesis**: searching for programs by exploring equivalence classes rather than individual terms.
- **Verification**: proving program equivalences by showing they have the same quotient representative.
- **Machine learning**: using e-graphs as semantics-preserving compression of neural network architectures.
- **Physics**: symbolic simplification of quantum mechanical expressions where canonical forms are inaccessible.

Perhaps most intriguingly, the result suggests a new way to think about the relationship between syntax and semantics. Traditionally, we think of semantics as assigning meaning to syntactic objects. The quotient perspective inverts this: syntax is a *presentation* of semantic objects, and equivalence classes are the "true" mathematical entities. Optimization is not transformation of syntax; it's choice of presentation.

This is an old philosophical idea — dating back to Frege's distinction between sense and reference — but it has never before been given such precise mathematical form in the context of program optimization.

The city has many streets, and they loop and twist and double back. There is no downtown, no canonical address. But every street connects equivalent places. And that, it turns out, is all you need.
