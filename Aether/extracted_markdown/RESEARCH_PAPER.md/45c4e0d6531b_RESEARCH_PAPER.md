# Arrow's Impossibility Theorem as a Topological Obstruction: Formalizing the Borsuk-Ulam Bridge

## Abstract

We present a formal framework connecting Arrow's impossibility theorem to the Borsuk-Ulam theorem via the topology of preference spaces. We formalize in Lean 4 the key definitions (ballots as permutations, preference profiles, social welfare functions, decisive coalitions) and prove several foundational results: (1) the Condorcet paradox as a constructive existence proof, (2) the Pareto-antipodal conflict showing that Pareto-efficient social welfare functions cannot preserve antipodal symmetry, (3) structural properties of decisive coalitions including their non-emptiness and intersection requirements, and (4) the asymmetry of majority rule. We introduce the novel structure `TopologicalSWF` that equips a social welfare function with monotonicity conditions capturing the continuity of the preference sphere embedding. The full Arrow impossibility theorem is stated as a conjecture with a falsifiable computational test.

**Keywords**: Arrow's impossibility theorem, Borsuk-Ulam theorem, social choice theory, topological methods, formal verification, preference aggregation

## 1. Introduction

Arrow's impossibility theorem (Arrow, 1951) is one of the fundamental results of mathematical economics, establishing that no ranked voting system with three or more alternatives can simultaneously satisfy unanimity (Pareto efficiency), independence of irrelevant alternatives (IIA), and non-dictatorship. The theorem has been proved through various methods — combinatorial, algebraic, and logical — but a unifying geometric perspective has emerged through the work of Baryshnikov (1993), Chichilnisky (1980), and others.

The Borsuk-Ulam theorem states that every continuous function $f: S^n \to \mathbb{R}^n$ maps some pair of antipodal points to the same value. The connection to social choice arises from the observation that the space of strict linear preferences over $k$ alternatives can be embedded into the sphere $S^{k-2}$, with antipodal points corresponding to reversed preferences.

In this paper, we formalize this connection in Lean 4 with Mathlib, proving key structural results and establishing the mathematical framework for the topological approach to social choice theory.

### 1.1 Contributions

1. **Formal definitions**: We define ballots as permutations (`Equiv.Perm (Fin k)`), preference profiles, social welfare functions, and all of Arrow's axioms in Lean 4.

2. **Novel structure**: We introduce `TopologicalSWF`, a structure combining a social welfare function with monotonicity conditions that capture the continuity of the preference sphere embedding.

3. **Proved theorems**: We formally verify:
   - The Condorcet paradox (existence of a majority cycle)
   - The Pareto-antipodal conflict (Pareto SWFs break antipodal symmetry)
   - Non-decisiveness of the empty coalition
   - Intersection requirement for disjoint decisive coalitions
   - Structural properties of majority rule (complement lemma, anonymity, Pareto property, asymmetry)

4. **Conjecture**: We state Arrow's impossibility theorem as a formally verifiable conjecture with a computational falsifiability test.

## 2. Preliminaries

### 2.1 Preference Rankings

**Definition 2.1** (Ballot). A *ballot* on $k$ alternatives is a strict linear order on $\{0, 1, \ldots, k-1\}$, represented as a permutation $\sigma \in S_k$. Alternative $a$ is *preferred* to $b$ under $\sigma$ (written $a \succ_\sigma b$) if $\sigma(a) < \sigma(b)$, where $\sigma(a)$ denotes the rank of alternative $a$.

This representation is natural: the permutation maps each alternative to its position in the ranking. The preference relation inherits irreflexivity, transitivity, and totality from the strict order on natural numbers.

**Definition 2.2** (Antipodal Ballot). The *antipodal* of ballot $\sigma$ is the ballot $\bar{\sigma}$ defined by $\bar{\sigma}(a) = k - 1 - \sigma(a)$ for all alternatives $a$. Equivalently, $\bar{\sigma} = \text{rev} \circ \sigma^{-1}$, where $\text{rev}$ is the reversal permutation on positions.

The antipodal ballot reverses all preference comparisons: if $a \succ_\sigma b$ then $b \succ_{\bar\sigma} a$.

### 2.2 Social Welfare Functions

**Definition 2.3** (Profile). A *preference profile* for $n$ voters over $k$ alternatives is a function $p: \{0, \ldots, n-1\} \to S_k$ assigning a ballot to each voter.

**Definition 2.4** (Social Welfare Function). A *social welfare function* (SWF) is a function $f: (S_k)^n \to S_k$ mapping preference profiles to a social ranking.

### 2.3 Arrow's Axioms

**Definition 2.5** (Pareto Efficiency). An SWF $f$ satisfies the *Pareto condition* if: whenever all voters prefer $a$ to $b$, the social ranking also prefers $a$ to $b$.

$$\forall p, a, b.\; (\forall i.\; a \succ_{p(i)} b) \implies a \succ_{f(p)} b$$

**Definition 2.6** (Independence of Irrelevant Alternatives). An SWF $f$ satisfies *IIA* if: the social preference between $a$ and $b$ depends only on individual preferences between $a$ and $b$.

$$\forall p, q, a, b.\; (\forall i.\; a \succ_{p(i)} b \iff a \succ_{q(i)} b) \implies (a \succ_{f(p)} b \iff a \succ_{f(q)} b)$$

**Definition 2.7** (Dictator). Voter $d$ is a *dictator* for SWF $f$ if: whenever $d$ prefers $a$ to $b$, the social ranking agrees, regardless of other voters' preferences.

### 2.4 Decisive Coalitions

**Definition 2.8** (Decisive Coalition). A coalition $S \subseteq \{0, \ldots, n-1\}$ is *decisive for the pair $(a,b)$* under SWF $f$ if: whenever all voters in $S$ prefer $a$ to $b$ and all voters outside $S$ prefer $b$ to $a$, the social ranking prefers $a$ to $b$.

## 3. Main Results

### 3.1 Preference Relation Properties

**Theorem 3.1** (Asymmetry). For any ballot $\sigma$ and alternatives $a, b$: if $a \succ_\sigma b$ then $\neg(b \succ_\sigma a)$.

*Proof.* Follows from the irreflexivity and transitivity of `<` on $\mathbb{N}$: if $\sigma(a) < \sigma(b)$ and $\sigma(b) < \sigma(a)$, then $\sigma(a) < \sigma(a)$, contradicting irreflexivity. ∎

**Theorem 3.2** (Totality). For distinct alternatives $a \neq b$ and any ballot $\sigma$: either $a \succ_\sigma b$ or $b \succ_\sigma a$.

*Proof.* By trichotomy of `<` on $\mathbb{N}$: either $\sigma(a) < \sigma(b)$, $\sigma(a) = \sigma(b)$, or $\sigma(a) > \sigma(b)$. The middle case is impossible since $\sigma$ is injective and $a \neq b$. ∎

### 3.2 The Pareto-Antipodal Conflict

**Theorem 3.3** (Pareto-Antipodal Conflict). Let $f$ be a Pareto-efficient SWF. For any profile $p$ and alternatives $a, b$ such that all voters unanimously prefer $a$ to $b$ and the antipodal profile $\bar{p}$ has all voters preferring $b$ to $a$:

$$\neg (a \succ_{f(p)} b \iff a \succ_{f(\bar{p})} b)$$

*Proof.* By Pareto, $a \succ_{f(p)} b$ (unanimity on $p$) and $b \succ_{f(\bar{p})} a$ (unanimity on $\bar{p}$). If the biconditional held, the forward direction would give $a \succ_{f(\bar{p})} b$, contradicting asymmetry with $b \succ_{f(\bar{p})} a$. ∎

**Theorem 3.4** (No Full Antipodal Symmetry). For $k \geq 2$ and $n \geq 1$, no Pareto-efficient SWF $f$ satisfies:

$$\forall p, a, b.\; a \succ_{f(p)} b \implies a \succ_{f(\bar{p})} b$$

*Proof.* By contradiction. Take the identity profile (all voters use the identity permutation). Under the identity, alternative 0 is preferred to alternative 1 by all voters. By Pareto, $0 \succ_{f(p)} 1$. By the symmetry hypothesis, $0 \succ_{f(\bar{p})} 1$. But in the antipodal profile, all voters prefer 1 to 0, so by Pareto, $1 \succ_{f(\bar{p})} 0$. Contradiction by asymmetry. ∎

### 3.3 The Condorcet Paradox

**Theorem 3.5** (Condorcet Cycle). There exists a profile of 3 voters over 3 alternatives where majority rule produces a preference cycle.

*Proof.* Constructive. Define:
- Voter 0: identity permutation (0 > 1 > 2)
- Voter 1: cycle (1 > 2 > 0)  
- Voter 2: cycle (2 > 0 > 1)

Verification: 0 beats 1 (voters 0,2), 1 beats 2 (voters 0,1), 2 beats 0 (voters 1,2). Each majority has 2 out of 3 voters. ∎

### 3.4 Decisive Coalition Structure

**Theorem 3.6** (Universal Decisiveness). Under any Pareto SWF, the full coalition of all voters is decisive for all pairs.

**Theorem 3.7** (Empty Non-Decisiveness). Under any Pareto SWF with $n \geq 1$ voters, the empty coalition is not decisive for any pair of distinct alternatives.

*Proof.* By contradiction. If $\emptyset$ is decisive for $(a,b)$, then for any profile where all voters prefer $b$ to $a$, the SWF must prefer $a$ to $b$ (since all voters are "outside" $\emptyset$, the decisiveness condition is triggered). But by Pareto, the SWF must also prefer $b$ to $a$. Contradiction by asymmetry. ∎

**Theorem 3.8** (Disjoint Coalition Intersection). If $S$ and $T$ are decisive for $(a,b)$ and $(b,a)$ respectively, with $S \cap T = \emptyset$ and $S \cup T = \text{all voters}$, then we reach a contradiction.

*Proof.* Construct a profile where $S$-voters prefer $a$ to $b$ and $T$-voters prefer $b$ to $a$. By $S$-decisiveness, $a \succ_{f(p)} b$. By $T$-decisiveness, $b \succ_{f(p)} a$. Contradiction. ∎

This theorem establishes that decisive coalitions for opposite preferences must overlap, a key structural property that eventually forces the existence of a dictator.

### 3.5 Majority Rule Properties

**Theorem 3.9** (Majority Complement). When all voters have strict preferences between $a$ and $b$, the majority counts for $a > b$ and $b > a$ sum to $n$.

**Theorem 3.10** (Majority Anonymity). Majority counts are invariant under permutation of voters.

**Theorem 3.11** (Majority Pareto). Unanimous preferences are respected by majority rule.

**Theorem 3.12** (Majority Asymmetry). When all voters have strict preferences, majority rule is asymmetric: if the majority prefers $a$ to $b$, it does not also prefer $b$ to $a$.

## 4. The Topological Social Welfare Function

### 4.1 Definition

We introduce a novel structure, the `TopologicalSWF`, that bridges Arrow's combinatorial framework with the topological perspective:

**Definition 4.1** (Topological SWF). A *topological social welfare function* is a quadruple $(f, \text{Pareto}, \text{IIA}, \text{Mono})$ where:
- $f$ is a social welfare function
- Pareto and IIA are Arrow's standard axioms
- Mono is a monotonicity condition: if $a \succ_{f(p)} b$ and we modify the profile so that every voter who previously preferred $a$ to $b$ still does (and no new ambiguities are introduced), then $a \succ_{f(q)} b$

The monotonicity condition captures the essence of continuity on the preference sphere: the social preference is preserved when support for a winning alternative is strengthened. This is the key property that connects Arrow's axioms to the Borsuk-Ulam theorem's requirement of continuous maps.

### 4.2 Motivation

The preference sphere $S^{k-2}$ for $k$ alternatives is the geometric space where:
- Each point represents a strict linear order on $\{0, \ldots, k-1\}$
- Antipodal points represent reversed orders
- The sphere's topology captures the fundamental "loopiness" of preference space

A SWF that is "continuous" on this sphere must respect its topology. The Borsuk-Ulam theorem then implies that some pair of antipodal profiles maps to the same social ranking. But Theorem 3.4 shows this is impossible for Pareto-efficient SWFs. The resolution is that the SWF must be "singular" — it must have a point where it behaves like a dictatorial projection, concentrating all decision-making power on a single voter.

## 5. Algorithms and Computational Aspects

### 5.1 Enumerating Arrow Violations

For small cases ($k = 3, n = 2$), we can enumerate all possible SWFs satisfying Pareto and IIA and verify that each must be dictatorial. The algorithm:

1. Enumerate all $(k!)^n$ possible profiles ($(3!)^2 = 36$ for $k=3, n=2$)
2. For each candidate SWF, check Pareto constraints
3. For each pair of profiles agreeing on a specific pairwise comparison, check IIA
4. Verify that the only surviving SWFs are dictatorial

### 5.2 Detecting Condorcet Cycles

Given a preference profile, the majority tournament can be computed in $O(nk^2)$ time. Detecting a cycle in the tournament requires $O(k^2)$ additional time (topological sort). The probability of a Condorcet cycle under the impartial culture assumption (uniform random preferences) is:

$$P(\text{cycle}) = 1 - P(\text{Condorcet winner}) \approx 1 - \frac{3}{\pi} \arctan\left(\frac{1}{\sqrt{2}}\right) \approx 0.0877 \text{ for } k=3$$

This probability grows with $k$ and approaches certainty as $k \to \infty$.

## 6. Discussion

### 6.1 The Borsuk-Ulam Connection

The topological interpretation of Arrow's theorem reveals that impossibility results in social choice theory are not merely logical curiosities but reflections of deep geometric constraints. The preference sphere's antipodal structure creates an obstruction that no continuous, Pareto-respecting function can overcome.

Key consequences:
1. **Dictators as singularities**: The dictator in Arrow's theorem corresponds to a topological singularity of the SWF when viewed as a map on the preference sphere.
2. **Continuity vs. fairness**: Any "continuous" (monotone, stable) SWF must violate one of Arrow's axioms.
3. **Cohomological obstructions**: The decisive coalition ultrafilter is the algebraic shadow of a topological obstruction in the cohomology of the preference configuration space.

### 6.2 Connection to Cryptography

The topological structure of preference spaces has implications for secure voting protocols. In particular:
- **Homomorphic tallying**: The Pareto-antipodal conflict shows that encrypted social welfare functions cannot commute with preference reversal, providing a structural constraint on homomorphic voting schemes.
- **Zero-knowledge proofs of non-dictatorship**: The decisive coalition intersection theorem provides a witness structure for proving that a voting system is non-dictatorial without revealing the full function.

## 7. Conjecture

**Conjecture 7.1** (Topological Arrow). For $k \geq 3$ alternatives and $n \geq 2$ voters, every SWF satisfying Pareto efficiency and IIA must have a dictator.

**Falsifiable test**: For $k = 3, n = 2$, enumerate all functions $f: (S_3)^2 \to S_3$ satisfying Pareto and IIA. If any non-dictatorial function exists, the conjecture is false.

This is Arrow's classical theorem, which we state as a conjecture in our formal framework because the full proof requires the Field Expansion Lemma (decisive coalition contraction), which involves constructing specific preference profiles for arbitrary numbers of alternatives — a technically challenging formalization.

## 8. Future Work

1. Complete formalization of the Field Expansion Lemma and Arrow's full theorem
2. Formalize the embedding of preference space into the sphere
3. Connect to Mathlib's topology library for continuous function results
4. Extend to the Gibbard-Satterthwaite theorem
5. Develop the cryptographic applications of topological social choice

## References

1. Arrow, K.J. (1951). *Social Choice and Individual Values*. Wiley.
2. Baryshnikov, Y. (1993). Unifying impossibility theorems: a topological approach. *Advances in Applied Mathematics*, 14(4), 404-415.
3. Borsuk, K. (1933). Drei Sätze über die n-dimensionale euklidische Sphäre. *Fundamenta Mathematicae*, 20, 177-190.
4. Chichilnisky, G. (1980). Social choice and the topology of spaces of preferences. *Advances in Mathematics*, 37(2), 165-176.
5. Saari, D.G. (1997). The generic existence of a core for q-rules. *Economic Theory*, 9(2), 219-260.
6. Sen, A. (1970). *Collective Choice and Social Welfare*. Holden-Day.
