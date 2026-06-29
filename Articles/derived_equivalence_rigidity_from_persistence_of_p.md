# The Shape of Counting: How Mathematicians Found Hidden Geometry in Prime Numbers

## A surprising connection between counting solutions, persistence, and the deep structure of shapes

---

In 1949, André Weil sat in a French prison cell and imagined a bridge that would take fifty years to cross. He saw that counting — the simplest mathematical act — could reveal the invisible geometry of shapes defined by polynomial equations. His insight launched one of the greatest mathematical programs of the twentieth century. Now, a new discovery suggests that Weil's bridge extends even further than he imagined, connecting the ancient art of counting to a revolutionary tool from data science: persistent homology.

## The Puzzle of Point Counting

Here is a deceptively simple question. Take an equation like *y² = x³ + x + 1*. Over the real numbers, this traces out a smooth curve — one of the famous "elliptic curves" that appear everywhere from cryptography to string theory. But what happens if you only allow whole-number solutions, working modulo a prime number?

Over a field with 5 elements, there are only finitely many points on the curve: perhaps 4, or 7, or 10. Call this count *N₁*. Now enlarge the field to 25 elements (5²), and count again: *N₂*. Keep going: 125 elements gives *N₃*, and so on. You get a sequence of integers — a "fingerprint" of the curve at the prime 5.

The deep theorem, proved by Weil himself and later refined by Pierre Deligne (who won the Fields Medal partly for this work), says that this sequence of counts is not random. It is controlled by a handful of special numbers called **Frobenius eigenvalues** — complex numbers that encode the geometric DNA of the curve. For an elliptic curve, there are exactly two such eigenvalues, and once you know them, you can predict every single point count *Nᵣ* for all extensions simultaneously.

This is remarkable: infinite information (all the *Nᵣ*) is compressed into finite data (the eigenvalues). It's as if someone handed you a genome and you could predict the entire life history of an organism.

## The Persistence Revolution

Meanwhile, in a completely different corner of mathematics, a revolution was brewing. Around 2000, researchers in computational topology developed a technique called **persistent homology**. The idea is startlingly intuitive: given a cloud of data points, gradually inflate balls around each point. As the balls grow, they start to overlap, creating shapes — loops, voids, tunnels. Some of these features persist across many scales; others appear and vanish quickly. The features that persist are the "real" topological structure of the data, while the ephemeral ones are noise.

Persistent homology has become one of the most successful tools in applied mathematics. It can detect the circular structure of periodic signals, find hidden loops in protein folding data, and distinguish cancerous tissue from healthy tissue in medical images. Its power lies in a simple principle: **features that persist are features that matter**.

But what does data science have to do with counting points on curves?

## The Bridge

The connection is this: when you look at the sequence *N₁, N₂, N₃, ...* of point counts over successively larger fields, you are already looking at a persistence module.

Each extension degree *r* acts like a "scale" parameter, analogous to the growing radius in persistent homology. The power sums *s_r = α₁ʳ + α₂ʳ + ...* of the Frobenius eigenvalues evolve as *r* increases, and the way they grow, oscillate, and interact encodes the same information as a persistence barcode.

For a single eigenvalue α, the sequence *1, α, α², α³, ...* is just a geometric progression — a single bar in the barcode, starting at birth and never dying. For a pair of eigenvalues α and β with different absolute values, the larger one eventually dominates, creating a transition that looks exactly like a "death" event in persistence.

The key theorem, proved using Newton's identities from the 18th century, is that **the persistence module determines the eigenvalues**. More precisely, the power sum sequence *s₀, s₁, ..., sₙ* uniquely determines the multiset of eigenvalues whenever you have *n* or fewer of them. This is not obvious — it's the reason why the familiar Vieta's formulas (relating roots to coefficients) work.

## The Conjecture: When Counting Is Enough

This mathematical framework leads to a bold conjecture: **if two geometric shapes have the same persistence modules at almost all primes, then their derived categories are equivalent**.

In plain terms: if two shapes produce the same counting fingerprints at enough primes, they must be the same in a deep algebraic sense — not just sharing superficial features, but having equivalent "linear algebra." This is the notion of **derived equivalence**, introduced by Alexander Grothendieck and developed by his students, which has become one of the most important equivalence relations in modern algebraic geometry.

The conjecture says that you can detect this sophisticated algebraic equivalence just by counting. No need for the full machinery of homological algebra — the point-count persistence modules do the job.

## Evidence and Experiments

Computational experiments provide striking evidence for the conjecture. For elliptic curves — the simplest case — two curves over a number field are derived equivalent if and only if they are isomorphic. And indeed, their persistence modules differ at the very first extension degree if their Frobenius traces differ.

For K3 surfaces — the two-dimensional analogues of elliptic curves — the situation is more subtle. There exist pairs of non-isomorphic K3 surfaces that are derived equivalent (they share the same derived category). The conjecture predicts that these pairs should have identical persistence modules. Conversely, non-derived-equivalent K3 surfaces should be separated by their persistence data. Numerical experiments with known examples confirm both predictions.

The most interesting test case involves mirror pairs: certain Calabi-Yau manifolds that are "mirror" to each other in the sense of string theory. Mirror symmetry predicts a precise relationship between the Hodge numbers of mirror pairs, and this relationship translates into a specific transformation of the persistence modules. The conjecture predicts that mirror pairs that are derived equivalent (which is not always the case) should be identified by their persistence data, while mirror pairs that are not derived equivalent should be separated.

## The Tropical Connection

Perhaps the most surprising aspect of this work is its connection to **tropical geometry** — a strange world where addition is replaced by maximum and multiplication is replaced by addition. Tropical geometry has been called "geometry over the Boolean semiring" and has found applications from optimization to phylogenetics.

The connection goes through the Newton polygon. For each prime *p*, the *p*-adic valuations of the Frobenius eigenvalues give the "slopes" of the Newton polygon of the characteristic polynomial. These slopes are exactly the data of tropical geometry: they describe the tropical curve associated to the algebraic curve.

The persistence framework reveals that the tropical slopes are a shadow of the full persistence module. Just as a topographic map is a shadow of a three-dimensional landscape, the tropical data captures the "silhouette" of the arithmetic persistence module at each prime. This gives a new way to think about tropical geometry: it is the single-prime cross-section of a richer multi-prime persistence structure.

## Why It Matters

If the conjecture is true — and the evidence is mounting — it would provide a computable criterion for detecting derived equivalence. Currently, proving that two varieties are derived equivalent requires constructing an explicit equivalence functor, a task that can be extremely difficult. The persistence approach would reduce this to a finite computation: check the point counts over enough extensions at enough primes.

For physics, the implications are equally tantalizing. Derived equivalence is intimately related to T-duality in string theory, and the persistence framework provides a new way to detect T-dual pairs. If the Calabi-Yau version of the conjecture holds — that persistence-equivalent Calabi-Yau manifolds have the same Gromov-Witten invariants — it would give a arithmetic handle on one of the deepest structures in mathematical physics.

More broadly, the persistence framework shows that some of the most sophisticated constructions in algebraic geometry — derived categories, motives, zeta functions — leave fingerprints in the humblest mathematical operation: counting. It's a reminder that mathematics, at its best, reveals unexpected unity. The same structure that topologists use to analyze point clouds in medical imaging is, in disguise, the same structure that number theorists use to study solutions of polynomial equations. The persistence module doesn't care where it came from — it only cares about what persists.

## The Road Ahead

The immediate challenge is to prove the conjecture, or find a counterexample. The theory of motives — Grothendieck's grand vision of "universal cohomology" — predicts that derived-equivalent varieties should have the same motive, and hence the same zeta function at all primes (not just a density-1 set). If the motivic framework can be completed, the persistence conjecture would follow as a consequence.

But the computational approach offers something the motivic framework does not: testability. Every pair of varieties provides a test case. Every mismatch in persistence data rules out derived equivalence. And every match provides evidence for one of the deepest connections between counting, geometry, and algebra.

André Weil would have appreciated the irony. He went to prison for refusing military service, and used his enforced solitude to imagine connections between number theory and geometry that seemed fantastical at the time. Now, seventy-five years later, a tool from data science — persistent homology — is illuminating the very bridge he built. Mathematics has a long memory, and the shapes that persist are, indeed, the shapes that matter.
