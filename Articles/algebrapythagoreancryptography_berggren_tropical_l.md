# The Ancient Triangle That Could Break Codes

## How a 4,000-year-old geometry trick may hold the key to a new kind of cryptography

The Babylonians knew about them. The Greeks obsessed over them. Every middle-school math student has memorized at least one: Pythagorean triples, those magical sets of three whole numbers where the squares of the two smaller ones add up to the square of the largest. Three, four, five. Five, twelve, thirteen. Eight, fifteen, seventeen.

What the Babylonians couldn't have known—what nobody knew until very recently—is that these humble triangles harbor a hidden optical system. Like the lenses inside a telescope, the family tree of Pythagorean triples can focus arithmetic information into sharp, certified images. And that discovery might change how we think about one of the hardest problems in all of mathematics: finding the factors of large numbers.

## A Family Tree of Perfect Triangles

In 1934, a relatively unknown mathematician named B. Berggren made a beautiful observation. He found three specific transformations—think of them as recipes—that, when applied to any primitive Pythagorean triple (one where the three numbers share no common factor), produce three new primitive Pythagorean triples. Start with (3, 4, 5), apply the three recipes, and you get (5, 12, 13), (21, 20, 29), and (15, 8, 17). Apply the recipes to each of those, and you get nine more. Keep going, and you generate every primitive Pythagorean triple that exists, exactly once, arranged in a perfect ternary tree.

This is remarkable enough on its own. But for decades, the Berggren tree was treated as a curiosity—a clever enumeration scheme, nothing more. The tree was a filing cabinet for triangles, not a computational engine.

Until someone asked a different question: What if you stop thinking about the *triangles* and start thinking about the *distances between them*?

## The Geometry of Costs

Imagine you're standing at the root of the Berggren tree—at the triple (3, 4, 5)—and you want to reach a specific descendant. Each step from a parent triple to a child triple has a cost: the increase in the hypotenuse (the largest number in the triple). Moving from (3, 4, 5) to (5, 12, 13) costs 8, because 13 − 5 = 8. Moving to (21, 20, 29) costs 24.

Now suppose you're looking for a triple that has some special arithmetic property—say, one of its legs divides a particular number you're interested in. You don't care *which* triple; you just want the cheapest one to reach. What's the minimum total cost to get from the root to a compatible triple?

This is a shortest-path problem, the same kind of problem that GPS navigation systems solve millions of times a day. But the underlying graph isn't a road network—it's an arithmetic tree, and the "destination" isn't a specific location but a number-theoretic condition.

## Tropical Mathematics: The Algebra of Optimization

To solve this problem rigorously, researchers turned to an exotic branch of mathematics called *tropical geometry*. The name has nothing to do with palm trees—it honors the Brazilian mathematician Imre Simon, who pioneered the field.

Tropical mathematics replaces ordinary arithmetic with a strange variant. Instead of addition, you use minimum. Instead of multiplication, you use addition. So the "tropical sum" of 3 and 7 is min(3, 7) = 3, and the "tropical product" is 3 + 7 = 10.

This sounds absurd, but it's secretly the mathematics of optimization. When you compute a shortest path, you're doing tropical arithmetic: you take the minimum over all possible routes (tropical addition) and sum up edge costs along each route (tropical multiplication). The Bellman equation of dynamic programming—the workhorse of modern optimization—is really a statement in tropical algebra.

## The Bellman Lens

Here's where the breakthrough happens. The Berggren tree, equipped with its hypotenuse-difference costs, becomes a *tropical optical system*. Think of each triple as a point in a landscape, and the cost function as defining the curvature of that landscape. An arithmetic compatibility condition—"does one of this triple's legs divide my target number?"—acts like a light source at compatible nodes.

The tropical Bellman equation propagates this light backward through the tree. At each node, it computes the minimum cost to reach any compatible descendant. The result is a *potential function* that encodes, at every point in the tree, the cheapest way to find useful arithmetic information.

This is exactly how a lens works in physical optics: light propagates according to Fermat's principle (shortest time), and a lens focuses it by shaping the potential landscape. In the Berggren tree, the "lens" is the tree structure itself, and the "light" is arithmetic compatibility.

The set of nodes lying on optimal paths to compatible triples forms what physicists would call a *caustic*—the bright curve where light concentrates after passing through a lens. In our setting, it's the *geodesic funnel*, the set of tree nodes through which optimal arithmetic information flows.

## From Geodesics to Divisors

The real surprise is what emerges at the other end of the telescope.

Suppose you trace the cheapest path from the root of the Berggren tree to a compatible node. The compatible node, by definition, has a leg that divides your target number. That leg is a *certified divisor witness*: a number you can verify divides your target, with a complete audit trail showing how you found it.

This is not just any divisor—it comes equipped with a proof of optimality. The tropical potential guarantees that no cheaper path exists. The path itself serves as a certificate that anyone can verify by checking each step against the Berggren transformation rules.

Finding divisors of large numbers is, famously, the hard problem underlying most modern encryption. The RSA cryptosystem, which secures trillions of dollars in online transactions every day, relies on the assumption that given a large number that's the product of two primes, finding those primes is computationally intractable.

Nobody is claiming that the Berggren tropical lens can crack RSA. The tree has to be enormous to contain relevant triples for large numbers, and searching it is still expensive. But the conceptual reframing is profound: *factor search is geodesic reconstruction in a tropical metric geometry*.

## A Three-Way Bridge

What makes this result genuinely novel is that it connects three previously unrelated mathematical worlds.

**Diophantine arithmetic** studies integer solutions to polynomial equations—a tradition stretching back to ancient Alexandria. The Berggren tree is a perfect example: it organizes all primitive Pythagorean solutions into a single structure.

**Tropical optimization** is the mathematics of min-plus algebras and dynamic programming—the computational backbone of operations research, machine learning, and theoretical computer science.

**Certified reconstruction** is the practice of extracting verifiable witnesses from optimization problems—a key concern in cryptography, where you need to prove that a computation was done correctly.

The tropical lensing theorem weaves these three threads into a single fabric. It shows that the Berggren tree is not just a catalog of triangles but a computational device whose geometry encodes arithmetic information, and whose geodesics produce certified outputs.

## What Lies Ahead

The immediate implications are conceptual rather than practical. But the framework opens several concrete research programs.

First, the same tropical lensing theory should apply to other arithmetic trees. Markov triples—solutions to $a^2 + b^2 + c^2 = 3abc$—form their own binary tree with a similar structure. So do continued fraction expansions, Farey sequences, and binary quadratic forms. Each of these trees might harbor its own tropical optical system.

Second, the tropical spectral theory of the Bellman operator connects to deep questions about growth rates and equidistribution in number theory. The eigenvalues of the min-plus transfer matrix govern how fast the tree explores arithmetic space—and might reveal fundamental limits on how quickly any tree-based search can find factors.

Third, the geodesic funnel concept has no analogue in classical number theory. The idea that arithmetic information concentrates along caustics in a tropical geometry is genuinely new, and might provide new tools for understanding the distribution of prime factors.

Finally, there's the tantalizing question of complexity. How deep into the Berggren tree must you search to find a divisor of a given composite number? If this depth is bounded by a polynomial in the number of digits, that would be a major result. If it's not—if the search must be exponentially deep—then the tropical framework provides a new lens on why factoring is hard.

## The View from the Telescope

Mathematics progresses by finding unexpected connections between distant domains. The link between Pythagorean triples and tropical geometry is one of those connections that, in retrospect, seems almost inevitable: both are concerned with discrete structures satisfying quadratic constraints, and both have natural notions of cost and optimization.

What's not inevitable is the precise mechanism—the lensing, the caustics, the certified reconstruction. These are specific, provable phenomena, not vague analogies. They suggest that the geometry of ancient triangles contains computational resources that we are only beginning to understand.

The Babylonians carved their triples into clay tablets four thousand years ago. It took until now to realize that those tablets were, in a precise mathematical sense, lenses.
