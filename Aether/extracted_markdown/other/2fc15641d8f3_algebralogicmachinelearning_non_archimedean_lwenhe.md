# When Proofs Learn to Compress: A Strange Bridge Between Logic and Machine Intelligence

## The Problem No One Thought to Ask

Imagine you have a library containing every mathematical proof ever written — billions of derivations, each a chain of logical steps. Now imagine someone tells you: "Summarize this entire library using just a handful of seed proofs and a single rule for transforming them." It sounds impossible. But it turns out that if the space of proofs has the right kind of geometric structure — a structure that appears naturally in number theory and computer science — then such radical compression is not only possible, it is mathematically *guaranteed*.

This is the core of a new result that connects three fields long thought to live in separate universes: the exotic geometry of "ultrametric" spaces, the model theory of mathematical logic, and the compression theory of machine learning.

## A Geometry Where Triangles Are Always Isosceles

To understand why this works, we need to talk about a strange kind of distance.

In everyday geometry, the triangle inequality tells us that the shortest path between two points is a straight line: the distance from A to C is never more than the sum of the distances from A to B and B to C. This is the geometry of rulers and road maps.

But there is a stricter rule, one that arises naturally in number theory and computer science: the *ultrametric inequality*. It says that the distance from A to C is never more than the *maximum* of the distances from A to B and B to C — not the sum, but the larger of the two. This single change in the rule transforms the entire geometry.

In an ultrametric space, every triangle is isosceles. Balls (neighborhoods of a point) are either completely nested inside each other or completely disjoint — they never partially overlap. Points near each other are *exactly* as near as the closest of their mutual neighbors. The geometry is tree-like: every configuration of points forms a hierarchy, like the branching structure of a family tree or the directory structure of a computer's file system.

This kind of distance is not just a mathematical curiosity. It appears naturally in:

- **p-adic number theory**, where the distance between two integers depends on the highest power of a prime dividing their difference
- **DNA sequence analysis**, where evolutionary distance follows a tree
- **Computer science**, where prefix codes and tries have exactly this structure
- **Clustering algorithms**, where hierarchical dendrograms are ultrametric by construction

## The Contraction Principle: Proofs That Simplify Themselves

Now add a second ingredient: a *contraction*. This is a function that maps every proof to a "simpler" version of itself, bringing distant proofs closer together at each step. Think of it as a proof normalizer — a machine that, when you feed it any derivation, outputs a cleaned-up, canonical version. Crucially, this normalization is *distance-reducing*: if two proofs are distance d apart, their normalized versions are at most q·d apart, where q is some number strictly less than 1.

In ordinary metric spaces, contractions are already powerful — the famous Banach fixed-point theorem guarantees they converge to a unique fixed point. But in ultrametric spaces, contractions are *dramatically* more powerful. The rigid, tree-like ball structure means that contraction doesn't just bring points closer; it collapses entire branches of the hierarchy simultaneously.

## The Compression Theorem

The new result says this: if you have an ultrametric space that is "totally bounded" (meaning it can be covered by finitely many balls of any given radius — a weakened form of compactness), then the contraction dynamics force the existence of a **finite compression core**.

What is a compression core? It is a small, finite set of "seed" points such that every point in the entire (possibly infinite) space can be reached — to any desired precision — by repeatedly applying the contraction to one of the seeds. The number of seeds you need is finite, and the number of contraction steps is bounded.

This is not just an abstract existence result. The proof is constructive: total boundedness gives you a finite covering, and the contraction dynamics ensure this covering works for all iterates simultaneously. The ultrametric structure is crucial because it prevents the cascading error accumulation that would plague the same argument in ordinary Euclidean space.

## The Duality: Proofs as Hypotheses

Here is where the bridge to machine learning appears.

In learning theory, a central concept is the *compression certificate*: a small set of examples that suffice to reconstruct (approximately) the entire hypothesis class. If you can compress your hypothesis class to size k, then you need only about log(k) samples to learn — a profound connection between compression and generalization.

The new result shows that proof compression cores and learning-theoretic compression certificates are, in a precise sense, *the same mathematical object seen from two different angles*.

Given a "realization functor" — a map that translates proof states into hypotheses — the proof compression core pushes forward to a compression certificate for the hypothesis class, and conversely, a faithful compression certificate pulls back to a proof core. The two notions are equivalent when connected by a sufficiently well-behaved translation.

This is what the discoverers call the **Löwenheim–Sample Duality**, named after the Löwenheim–Skolem theorem from model theory (which says that if a theory has infinite models, it has models of every infinite cardinality) and the sample compression theorem from statistical learning theory.

The analogy is deep: just as Löwenheim–Skolem extracts finite substructures that preserve logical properties, the new theorem extracts finite cores that preserve observational properties — where "observations" are uniformly continuous functions playing the role of first-order formulas.

## The Approximate Löwenheim Principle

The most striking result is the **finite elementary compression core theorem**: if you have a totally bounded ultrametric proof space equipped with a finite family of "observers" (measurements that respect the ultrametric structure), then there exists a finite set of seed proofs such that:

1. Every proof in the space is approximated by a contraction iterate of some seed.
2. Every observer value is preserved up to the prescribed precision.

This is an *approximate Löwenheim–Skolem theorem* — a finite, approximate version of one of the most powerful tools in mathematical logic. The observers play the role of formulas, proximity replaces elementary equivalence, and the compression core plays the role of an elementary substructure.

The result says that no matter how complex or infinite the proof space, its observational content — everything that can be measured by the observers — is captured by a finite skeleton.

## Why This Matters

The implications span several fields:

**For artificial intelligence:** This provides a mathematical foundation for *proof compression in reasoning systems*. If an AI's internal representations form an ultrametric space (which tree-structured representations naturally do), then there exists a guaranteed-finite summary that captures all observationally relevant information. This could lead to more efficient theorem provers, smaller knowledge bases, and certified compression of learned models.

**For machine learning theory:** The duality theorem shows that proof-geometric structure directly implies learnability. Finite compression cores give finite covering numbers, which give finite sample complexity bounds via standard uniform convergence arguments. This opens a new route to proving learnability that starts from the *geometry of the hypothesis class* rather than from combinatorial measures like VC dimension.

**For mathematical logic:** The approximate Löwenheim principle suggests a new direction in model theory: the study of approximate elementary substructures in topological and metric settings. Classical Löwenheim–Skolem is an exact, all-or-nothing result. The new theorem shows that approximate versions with quantitative control are possible and natural.

**For number theory and p-adic analysis:** The ultrametric structure is not just a convenience — it is the geometry of p-adic numbers, which are foundational in modern number theory. The compression theorem applies to any p-adic dynamical system that is contractive, potentially yielding new finiteness results in arithmetic geometry.

## A New Kind of Theorem

What makes this result unusual is that it lives at the intersection of three fields that rarely interact directly. Ultrametric geometry, model theory, and learning theory each have their own deep traditions, but they share a hidden common structure: the interplay between infinite objects and finite approximations.

The compression theorem makes this common structure precise. It says that a specific kind of geometric compactness (ultrametric total boundedness plus contraction) is *equivalent* to a specific kind of logical compactness (finite approximate elementary substructures) and a specific kind of statistical compactness (finite compression certificates).

This is not a loose analogy. It is a mathematical theorem with precise quantitative content: the size of the compression core, the number of contraction steps, the approximation precision — all are explicitly controlled.

The result suggests that there may be a much deeper unity between the theory of proofs and the theory of learning than has been previously recognized. If proofs can be learned in the statistical sense — if finite samples of a proof system suffice to reconstruct its essential content — then proof theory and learning theory may be two aspects of the same mathematical reality.

That is a startling possibility, and pursuing it will require building new bridges between fields that have, until now, developed in splendid isolation. This theorem is one of the first solid planks in that bridge.
