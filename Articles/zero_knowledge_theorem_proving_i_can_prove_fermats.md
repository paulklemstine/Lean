# The Sealed Proof: What Random Challenges Can—and Cannot—Hide

Imagine a mathematician arriving with a theorem of enormous value: a new optimization method, a security result, perhaps a proof whose strategic insight is itself a trade secret. She wants the world to trust the conclusion, but she does not want to reveal the route by which she reached it. Cryptography suggests a tantalizing bargain: convince a skeptic that a claim is true while disclosing nothing beyond its truth.

That bargain is called **zero knowledge**. It sounds almost magical when applied to mathematics. Could someone certify a theorem without showing its proof? Could one even certify a theorem as famous as Fermat’s Last Theorem while keeping every proof step sealed?

A finite model reveals both why the dream is plausible and why a popular shortcut fails. The model has two clean ingredients. Random tests can catch false propositional formulas, and additive masks can hide local values perfectly. Yet these ingredients solve different problems. Repeating a weak test does not make it efficient, and hiding a line does not establish that the surrounding argument is valid.

## A small logical universe

Begin with formulas built from three pieces: variables, falsity, and implication. If $p$ and $q$ are formulas, their implication $p\to q$ is false only when $p$ is true and $q$ is false. This tiny vocabulary is complete: familiar connectives such as negation, conjunction, and disjunction can all be expressed from falsity and implication.

Suppose a formula uses $m$ Boolean variables. A **valuation** assigns either false or true to each variable, so there are exactly $2^m$ valuations. Evaluating the formula at one valuation produces one Boolean answer. A **tautology** is a formula that evaluates to true under every one of those $2^m$ assignments.

This gives the most direct possible randomized test. Choose a valuation uniformly at random, evaluate the formula, and accept if the answer is true. A genuine tautology always passes. A false claim has at least one rejecting valuation, so it can never pass on more than $2^m-1$ rows of its truth table.

This elementary observation is the first central result:

**Single-challenge soundness theorem.** If a formula in $m$ variables is not a tautology, then the probability that it passes one uniformly random valuation test is at most

$$
\frac{2^m-1}{2^m}=1-2^{-m}.
$$

The proof is a counting argument. Non-tautologicity supplies a concrete valuation where the formula is false. Remove that row from the full set of $2^m$ rows. Every accepting valuation must lie among the remaining $2^m-1$ rows.

Now repeat the test $k$ times, choosing the valuations independently. If the formula passes on a fraction $a/2^m$ of all valuations, its probability of surviving every test is exactly $(a/2^m)^k$. Since $a\le 2^m-1$, we obtain the second result:

**Repeated-challenge soundness theorem.** A non-tautology in $m$ variables survives $k$ independent random valuation tests with probability at most

$$
\left(\frac{2^m-1}{2^m}\right)^k
=\left(1-2^{-m}\right)^k.
$$

The bound is sharp. Consider a formula that fails on exactly one valuation. It accepts on all other rows, so equality holds.

## The arithmetic reality check

This exact bound corrects a seductive but incorrect slogan: “Repeat the test $k$ times and the error becomes $2^{-k}$.” That conclusion would require each round to catch a false claim with probability at least $1/2$. Truth-table sampling guarantees only $2^{-m}$ in the worst case. For a formula with $m=20$ variables, a uniquely falsified formula escapes one round with probability $1-1/1{,}048{,}576$. Even one thousand independent tests leave its chance of escape above $0.999$.

To drive the error below a target $\varepsilon$, one needs

$$
\left(1-2^{-m}\right)^k\le \varepsilon.
$$

Equivalently,

$$
k\ge \frac{\log \varepsilon}{\log(1-2^{-m})}.
$$

For large $m$, the denominator is approximately $-2^{-m}$, so the required number of rounds is approximately $2^m\log(1/\varepsilon)$. Repetition does produce geometric decay, but the geometry starts from a rate perilously close to one. The challenge space is exponentially large, and a single defect is exponentially sparse.

This lesson reaches beyond logic. A factory inspector who samples one component cannot efficiently detect a single defective item hidden among a million. Repeating the same sampling method helps, but roughly a million samples are needed for a constant chance of discovery. Authentication can establish that the sampled component is genuine; it cannot make the defect less sparse.

The missing resource is **robustness**. An efficient local test needs an encoding in which one underlying mistake contaminates a noticeable fraction of local views. Probabilistically checkable encodings aim to spread inconsistency in precisely this way. Raw proof lines do not automatically have that property.

## A perfect veil from addition

Soundness asks whether a false claim can fool the verifier. Zero knowledge asks a different question: what does the verifier learn from the interaction?

A simple finite-group mask gives an exact answer for one local value. Choose a positive integer $q$ and work modulo $q$. A secret is an element $s$ of the cyclic group $\mathbb Z/q\mathbb Z$. Choose a mask $r$ uniformly from the same group and publish

$$
c=s+r\pmod q.
$$

This is an additive one-time pad. For every fixed secret $s$, addition by $s$ permutes the $q$ possible masks. Therefore $c$ is uniform, regardless of $s$.

**Uniform-mask theorem.** For every secret $s\in\mathbb Z/q\mathbb Z$, the masked value $s+r$, with $r$ uniform, is itself uniformly distributed on $\mathbb Z/q\mathbb Z$.

**Perfect-hiding theorem.** For any two secrets $s,t\in\mathbb Z/q\mathbb Z$, the distributions of $s+r$ and $t+r$ are identical. More strongly, for every observed value $c$,

$$
\Pr[s+r=c]=\Pr[t+r=c]=\frac1q.
$$

The proof is a bijection: the unique mask producing observation $c$ from secret $s$ is $r=c-s$. Every observation therefore has exactly one equally likely preimage.

This is stronger than saying that recovery is computationally difficult. No amount of computation can distinguish the two secrets from the masked value alone, because their probability distributions are exactly the same. A simulator that knows no secret can simply output a uniform element of $\mathbb Z/q\mathbb Z$, and its output has precisely the verifier’s distribution.

## Two guarantees, not one

The finite protocol can now be summarized by a paired statement.

**Combined finite guarantee.** Let a non-tautology use $m$ variables, let the verifier perform $k$ independent valuation tests, and let local values be masked in a nontrivial cyclic group $\mathbb Z/q\mathbb Z$. Then the probability that the formula passes every test is at most

$$
\left(1-2^{-m}\right)^k,
$$

while the distribution of a masked local value is identical for every possible underlying value.

The conjunction matters because neither half implies the other. A perfectly hidden message may encode nonsense. A powerful test may reveal everything it examines. Soundness and privacy must be established independently and then composed with care.

That distinction exposes the flaw in the naive “open one random proof line” story. First, one malformed line among a very long derivation is unlikely to be sampled. Second, seeing one line may reveal a crucial idea. Third, checking that a line follows from earlier lines can require opening its dependencies, which creates correlated disclosures. A one-symbol mask hides one symbol; it does not automatically hide a jointly opened neighborhood subject to logical constraints.

Commitment also requires binding as well as hiding. The additive mask described here proves perfect hiding of a local value, but by itself it is not a complete commitment scheme: if the mask is unconstrained, the same displayed value can later be explained as different secrets with different masks. A full protocol must prevent such equivocation while preserving privacy. This is usually achieved with additional cryptographic structure.

## What this says about secret mathematics

The grand vision remains compelling, but its honest form is subtler than the slogan. To certify large derivations privately and succinctly, one needs at least three layers.

First comes an **arithmetization or encoding layer**, turning a derivation into a structured object with local constraints. Second comes a **robust testing layer**, ensuring that an invalid object violates a fixed positive fraction of those constraints rather than hiding its error in one location. Third comes a **zero-knowledge layer**, committing to the encoded object and revealing only simulated local views, including all correlations among jointly opened values.

If each round catches cheating with a constant probability $\delta>0$, then $k$ rounds leave error at most $(1-\delta)^k$, and only $O(\log(1/\varepsilon))$ rounds are needed to reach error $\varepsilon$. That is the amplification regime people often have in mind. The truth-table model shows exactly why it is unavailable when $\delta=2^{-m}$.

The next promising laboratory is not unrestricted theorem proving but structured propositional formulas. Formulas of bounded treewidth decompose into small overlapping regions. Dynamic programming can test global validity through compatible local states, while finite-group masks may conceal those states. The challenge is to simulate the entire correlated view across overlaps, not merely each coordinate in isolation.

There is also a geometric way to phrase the problem. Each local test sees a patch of a larger proof. Simulators describe what can be seen on individual patches. On overlaps, their distributions must agree, and compatible local views must glue into a global transcript distribution. Making that principle precise could turn privacy composition into a mathematical theory of local-to-global consistency.

The finite results therefore deliver both a construction and a warning. Random valuation tests have an exact, sharp soundness law. Additive one-time pads provide exact, perfect local hiding. But efficient secret theorem certification demands a bridge between them: robust local encodings whose dependency-closed views remain simulatable.

The dream is not “trust me, I checked a random line.” It is more disciplined and more interesting: redesign the proof so that falsehood is everywhere locally visible, then reveal local evidence in a distribution that truth alone can explain. Only then can a sealed proof speak convincingly without giving away its voice.
