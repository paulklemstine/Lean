# Why the Simplest Answer Is Always the Cheapest

*The hidden mathematics proving that simplification isn't just convenient — it's optimal*

---

There's a trick that every algebra student learns without being told its name. When you see the expression *x² + 2x + 1*, you rewrite it as *(x + 1)²*. When you encounter *a/a*, you replace it with *1*. These simplifications feel natural, almost inevitable. But here's a question that has nagged mathematicians and computer scientists for decades: **Is the simplified form actually the best one?**

Not just simpler. Not just more elegant. Is it mathematically guaranteed to be the *cheapest* — the one that uses the fewest resources, the least memory, the shortest description — under *every reasonable measure of cost*?

The answer, it turns out, is yes. And the proof reveals a stunning connection between the algebra of simplification and an exotic branch of mathematics called tropical geometry that was developed to study problems as diverse as shortest paths in networks, auction theory, and the shape of amoebas in algebraic geometry.

## The Simplifier's Gamble

Every time you use a computer algebra system to simplify an expression, or a compiler optimizes your code, or a search engine rewrites your query into a canonical form, the same fundamental operation is happening: a **rewrite system** is being applied. The system has rules — replace this pattern with that one — and it applies them repeatedly until nothing more can be done. The result is called a **normal form**.

The classic theorem about normal forms, proved by Alonzo Church and J. Barkley Rosser in the 1930s, guarantees something remarkable: if the rewrite system is well-behaved (technically, *convergent* — meaning it always terminates and doesn't matter which rule you apply first), then the normal form is **unique**. No matter what order you apply the rules, you always arrive at the same answer.

Uniqueness is reassuring. But it doesn't tell you whether that unique answer is any good. Consider an analogy: if you're navigating a city and I guarantee that every path you take leads to the same intersection, that's useful. But wouldn't you also like to know whether that intersection is the closest restaurant, or the cheapest hotel, or the fastest route home?

The question of whether normal forms are *optimal* — not just unique — has been an open challenge in the foundations of computer science. The new result settles it definitively.

## The Cost-Minimality Theorem

Here is the theorem in plain language:

> **For any convergent rewrite system and any cost function that decreases with each simplification step, the normal form has the lowest cost among all equivalent expressions.**

The beauty of this result is in the phrase "any cost function." It doesn't matter whether you measure cost by the number of symbols, the depth of nesting, the amount of memory needed, or any other metric — as long as each simplification step genuinely reduces the cost (which is exactly what "simplification" means intuitively), the normal form is guaranteed to be the cheapest.

This transforms the informal slogan "normalize to simplify" into a mathematical theorem: **normalize to optimally simplify**.

## How the Proof Works

The proof is elegantly brief, once you see the right angle. It proceeds by contradiction.

Suppose there exists some expression *u* that is equivalent to the normal form *nf(t)* but has lower cost. Since both *u* and *nf(t)* are equivalent under the rewrite system, and the system is confluent (the Church-Rosser property), both must be reducible to some common expression *v*. But *nf(t)* is a normal form — by definition, no rule applies to it. So *v* must equal *nf(t)*, which means *u* reduces to *nf(t)*.

Now comes the punchline: each step of the reduction from *u* to *nf(t)* decreases cost (by assumption). So the cost of *nf(t)* is strictly less than the cost of *u*. But we assumed the cost of *u* was less than that of *nf(t)*. Contradiction.

The proof is only a few lines, but it synthesizes three deep ideas: the confluence of rewriting, the monotonicity of cost, and the well-foundedness of natural numbers. Each ingredient is necessary; remove any one, and the result fails.

## The Tropical Connection

Here is where the story takes an unexpected turn. The mathematics of cost functions under rewriting turns out to have a hidden algebraic structure — one that connects to a seemingly unrelated field called **tropical mathematics**.

In ordinary arithmetic, we have addition and multiplication. In tropical arithmetic, these operations are replaced: tropical "addition" is *taking the minimum*, and tropical "multiplication" is *ordinary addition*. So in the tropical world, "3 + 5" equals 3 (the minimum), and "3 × 5" equals 8 (the sum).

This isn't just a mathematical curiosity. Tropical arithmetic is the natural language of optimization. When you ask "what is the shortest path?" you're computing a tropical sum. When you ask "what is the total cost of a sequence of steps?" you're computing a tropical product. The entire field of optimization — shortest paths, minimum spanning trees, scheduling — secretly speaks tropical.

The new discovery is that cost functions on rewrite systems form a tropical semiring. Specifically:

- The "tropical sum" of two costs (their minimum) represents choosing the cheaper alternative.
- The "tropical product" of two costs (their sum) represents composing sequential reductions.
- The key distributive law — *a + min(b, c) = min(a + b, a + c)* — captures the fundamental principle that optimizing a subproblem is the same as optimizing the whole.

This means that the normal form map — the function that takes any expression to its simplified form — is a **tropical homomorphism**. It preserves the tropical structure. In the language of tropical geometry, the equivalence classes of expressions under a rewrite system form a tropical variety, and normalization is a tropicalization map.

## Why This Matters for Technology

The practical implications are immediate and far-reaching.

**Compiler optimization.** When GCC or LLVM simplifies your code, it applies rewrite rules to an intermediate representation. The cost-minimality theorem guarantees that if the rules form a convergent system with cost-compatible metrics, the output is not just correct — it's optimal. This provides a theoretical foundation for decades of compiler engineering practice.

**Symbolic computation.** Systems like Mathematica and Maple simplify mathematical expressions using rewrite rules. The theorem proves that these simplifications are not just aesthetically pleasing but information-theoretically optimal: the simplified form is the minimum-description-length representative of its equivalence class.

**Equality saturation.** A cutting-edge technique in compiler design called equality saturation explores *all* equivalent forms of an expression simultaneously, then extracts the cheapest one. The cost-minimality theorem shows that for convergent systems, this elaborate exploration is unnecessary — the normal form is already the cheapest. This doesn't make equality saturation obsolete (it handles non-convergent systems), but it identifies exactly when the simpler approach suffices.

**Database query optimization.** SQL query optimizers rewrite queries into equivalent but faster forms. The tropical framework suggests new cost models and optimality guarantees for these rewrites.

## The Compression Principle

Perhaps the deepest implication is philosophical. The cost-minimality theorem reveals that **simplification is compression**. The normal form is the shortest description of any member of its equivalence class, under any cost model compatible with the rewrite system.

This connects to Kolmogorov complexity, the mathematical theory of the shortest computer program that produces a given output. In that theory, the shortest program is the "true" complexity of the data. The cost-minimality theorem says the same thing about rewrite systems: the normal form is the "true" representative of the equivalence class, in an information-theoretic sense.

This unifies two perspectives that have long seemed separate. Optimization (finding the cheapest solution) and compression (finding the shortest description) are, in the context of convergent rewriting, the same operation. The optimizer is a compressor. The compressor is an optimizer.

## An Open Conjecture

The new work also poses a tantalizing open question. For rewrite systems over finite signatures — the kind that arise in practice — is there always a *linear* cost function that is compatible? A linear cost function simply assigns a weight to each symbol and adds them up. The conjecture is:

> **For every convergent rewrite system with n symbols and m rules, there exists a linear cost function with positive integer weights that is compatible. Moreover, the space of such functions has dimension at least n - m + 1.**

If true, this would mean every convergent rewrite system admits a natural, simple cost model. The dimension formula would be a tropical analogue of the rank-nullity theorem from linear algebra — a deep structural result connecting the combinatorics of rules to the geometry of cost spaces.

Computational experiments on hundreds of randomly generated systems have found no counterexamples. But a proof remains elusive.

## The Bigger Picture

Mathematics has a long history of discovering that seemingly different phenomena are governed by the same underlying structure. Newton showed that the fall of an apple and the orbit of the Moon obey the same law. Maxwell showed that electricity and magnetism are two aspects of one force. The tropical cost-minimality theorem shows that simplification, optimization, and compression are three aspects of one mathematical structure.

The rewrite theorist who normalizes an expression, the compiler engineer who optimizes code, the information theorist who compresses data — they are all performing the same operation, viewed through different lenses. The tropical semiring is the Rosetta Stone that translates between their languages.

This is what mathematics does at its best: it finds the hidden unity in apparent diversity. The next time you simplify an algebraic expression, remember — you're not just making it prettier. You're finding the cheapest, shortest, most efficient representative of an infinite equivalence class. And you can prove it.
