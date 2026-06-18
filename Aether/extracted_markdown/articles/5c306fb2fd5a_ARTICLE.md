# How Information Theory Teaches Computers to Invent Mathematical Lemmas

**When machines try to prove algebraic identities, they often drown in a sea of symbols. A new framework reveals that the drowning is not accidental — it's an information-theoretic necessity. And the same theory that explains the drowning also points the way to a life raft.**

---

## The Explosion Problem

Imagine you're a student confronted with this identity:

$$(1 + a)(1 + b)(1 + c) = 1 + a + b + c + ab + ac + bc + abc$$

Not so bad. Seven terms on the right. But what if you had ten factors instead of three? The right-hand side would balloon to 1,023 terms — one for every possible subset of the ten variables. With twenty factors, you'd be staring at over a million terms.

A human mathematician handles this effortlessly. "It's just the powerset expansion," she says, waving her hand. "Each factor $(1 + x_i)$ either contributes $x_i$ to a product or contributes $1$. By induction, adding one more factor doubles the number of subsets." The proof is five lines long, regardless of how many factors there are.

But a computer, tasked with *verifying* this identity without understanding its structure, must check every single term. For $n$ factors, that's $2^n$ terms to verify — an exponential explosion that no amount of raw computing power can overcome as $n$ grows.

This gap between the human five-line proof and the computer's $2^n$-step verification isn't just an inconvenience. It's a fundamental barrier, rooted in the same mathematics that governs how much information a telephone line can carry or how efficiently a zip file can compress data. And understanding this connection — between proof complexity and information theory — turns out to be the key to teaching computers to think more like mathematicians.

## The Bottleneck

The core insight comes from a field called *communication complexity*, pioneered by Andrew Yao in 1979. Here's the setup: Alice holds some data, Bob holds some other data, and they need to jointly compute something. How many bits must they exchange?

Now apply this to identity verification. Think of Alice as holding the left-hand side of the identity (the product) and Bob as holding the right-hand side (the sum). To verify they're equal, Alice and Bob must exchange enough information to rule out every possible discrepancy. If the identity involves $2^n$ independent coefficients, they need to communicate at least $n$ bits — the logarithm of the coefficient space dimension.

This is the *communication bottleneck*: the minimum information that must flow through the verification channel, no matter how clever the protocol. It's a hard floor imposed by information theory, as immovable as the speed of light.

But here's the twist. When a human mathematician invents a *lemma* — a reusable intermediate result — she's essentially compressing the communication. The inductive step "adding one more factor doubles the subsets" encapsulates $2^n$ bits of information into a single reusable statement. It's like inventing a new word that captures a complex idea, allowing you to communicate more efficiently.

The *communication bottleneck ratio* measures the gap between the raw information content (the coefficient space dimension) and the compressed proof size (the cost after lemma factoring). When this ratio is large, lemma invention isn't just helpful — it's *informationally necessary*.

## The Detector

This insight leads to something practical: a *bottleneck detector*. Given any family of algebraic identities — say, the powerset expansion, or the telescoping sum $(x-1)(1 + x + x^2 + \cdots + x^{n-1}) = x^n - 1$, or even the Pythagorean identity $(m^2 - n^2)^2 + (2mn)^2 = (m^2 + n^2)^2$ — the detector computes three things:

1. **The coefficient dimension**: How many independent coefficients does the identity involve? This is the raw information content.

2. **The communication lower bound**: The logarithm of the coefficient dimension — the minimum number of bits any verification protocol must exchange.

3. **The bottleneck ratio**: How much compression is available through lemma invention. A large ratio means there's a huge payoff to finding the right lemmas.

For the powerset expansion, the detector reports: coefficient dimension $2^n$, lower bound $n$ bits, bottleneck ratio growing exponentially. This immediately suggests the inductive factorization — break the identity into $n$ lemmas, one per factor — and confirms it's essentially optimal.

For the telescoping sum, the detector reports a much smaller gap: polynomial coefficient dimension, polynomial lower bound. The bottleneck is gentler, and a single lemma (the telescoping principle) suffices.

For the Pythagorean family, the detector reveals a quadratic-vs-linear gap: the naive expansion cost grows as the fourth power of the parameter, but structured proof remains linear. Even this "simple" identity from ancient number theory hides an information-theoretic compression opportunity.

## Tropical Shadows

The connection goes deeper than counting bits. There's a beautiful mathematical structure lurking beneath the bottleneck — a structure that lives in the *tropical* world.

Tropical mathematics replaces ordinary addition with "take the minimum" and ordinary multiplication with "take the sum." It sounds bizarre, but it turns out to be the natural algebra for optimization problems. Where classical algebra asks "what is the total?", tropical algebra asks "what is the cheapest?"

In the communication bottleneck framework, tropical arithmetic captures exactly the right question: what is the *hardest* coefficient to verify? The tropical product of verification costs gives the bottleneck — the coefficient that requires the most communication, the one that forces the proof to be long.

The tropical semiring satisfies all the familiar algebraic laws — commutativity, associativity, distributivity — but in a min-plus world. And crucially, the distributive law for tropical multiplication over tropical addition

$$a \otimes (b \oplus c) = (a \otimes b) \oplus (a \otimes c)$$

translates to: "the cost of verifying a compound identity equals the minimum of the costs of verifying its parts." This is exactly the principle that makes lemma factoring work — breaking a hard verification into easier pieces.

The full tropical chain identity shows that the cost of verifying a product of sums factors into a minimum over individual verification costs. This isn't just an analogy; it's a precise mathematical correspondence between proof compression and tropical optimization.

## The Phase Transition

Perhaps the most striking result is the existence of a *phase transition* in proof complexity. Below a critical threshold, automated verification keeps pace with human proofs — the overhead is at most a constant factor. Above the threshold, no constant factor suffices: the gap between automated and structured proofs grows without bound.

This phase transition is not gradual. It's sharp, like the freezing of water or the magnetization of iron. And it's inevitable — a mathematical theorem, not an empirical observation.

The proof relies on a simple but powerful fact: exponential functions eventually dominate any linear function. If the coefficient dimension grows exponentially while the factored proof cost grows linearly, then for any fixed constant $K$, there exists a level $n$ beyond which the automation cost exceeds $K$ times the factored cost. No matter how generous you are with the constant factor, the exponential eventually wins.

This is why lemma invention matters. It's not about elegance or aesthetics (though those are nice). It's about *computability*. Without lemma invention, automated provers face an information-theoretic barrier that grows exponentially. With the right lemmas, the barrier collapses to linear.

## From Pythagoras to Proof Search

The connection to the Pythagorean identity reveals something unexpected: even the most ancient mathematics contains hidden information structure.

The identity $(m^2 - n^2)^2 + (2mn)^2 = (m^2 + n^2)^2$ generates Pythagorean triples — integer solutions to $a^2 + b^2 = c^2$. A human proves it in one line: expand and simplify. But a naive verifier, treating each coefficient independently, must check a number of terms that grows with the parameters.

The bottleneck detector reveals that the Pythagorean family, while simpler than the powerset family, still has a gap: quadratic automation cost versus linear structured cost. This gap is smaller than the powerset's exponential gap, but it's still real and still information-theoretic.

Moreover, for sufficiently large parameters, the powerset family's coefficient dimension strictly dominates the Pythagorean family's. This isn't just a quantitative comparison — it's a *qualitative* statement about the relative hardness of two families of identities, measured in information-theoretic terms.

## The Frontier

Where does this lead? The bottleneck framework opens several intriguing directions:

**Tropical information theory.** If the communication bottleneck equals a tropical entropy, then the entire apparatus of information theory — channel capacity, rate-distortion, source coding — has tropical analogues that apply to proof compression. What is the "tropical channel capacity" of a proof system?

**Algorithmic lemma discovery.** The bottleneck detector doesn't just measure gaps — it suggests *how to close them*. The singular value decomposition of the coefficient matrix reveals the natural factorization into lemmas. Each significant singular value corresponds to a lemma. This transforms lemma discovery from heuristic search into linear algebra.

**Universal compression bounds.** Does every identity family with super-polynomial coefficient dimension require lemma invention? The conjecture says yes: the minimum number of lemmas is $\Theta(\log_2(\text{coeffDim}/\text{factoredCost}))$. For the powerset family, this gives $n$ lemmas, matching the known optimal. For polynomial families, it gives $O(\log n)$ lemmas.

**Cross-domain bridges.** The bottleneck framework applies not just to algebraic identities but to any family of mathematical statements with a measurable "naive verification cost." Combinatorial identities, geometric theorems, even number-theoretic conjectures could be analyzed through the same lens.

## The Bigger Picture

Mathematics has always progressed by *abstraction* — finding the common structure behind diverse phenomena. The communication bottleneck framework abstracts the common structure behind diverse *proofs*: the information that must flow, regardless of the proof strategy.

This is a shift in perspective. Instead of asking "How do we prove this theorem?", we ask "How much information must any proof of this theorem convey?" The answer, measured in bits, gives a hard floor on proof complexity. And the gap between this floor and the ceiling imposed by naive verification reveals exactly where human-like reasoning — lemma invention, structural insight, abstraction — adds value.

The computers that will eventually rival human mathematicians won't do so by being faster at symbol manipulation. They'll do so by understanding, at an information-theoretic level, where the bottlenecks lie — and by inventing the lemmas that break through them.

The ancient Pythagoreans believed that "all is number." The communication bottleneck framework suggests a modern update: all proofs are information. And information, as Claude Shannon taught us, has structure. Understanding that structure is the key to mathematical discovery, whether by humans or machines.
