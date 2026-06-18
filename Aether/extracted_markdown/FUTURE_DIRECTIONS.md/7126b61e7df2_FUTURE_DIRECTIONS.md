# Future Research Directions

## Synthesis

This research cycle established a rigorous mathematical framework for analyzing social deduction games through recursive probability theory over the rationals. The central object — the win probability function P(v, w) defined by a two-branch recurrence — exhibits surprisingly rich structure despite its elementary definition. The key discovery, the **Parity Paradox**, shows that P(v, w) is not monotone in v: adding a villager can strictly decrease the win probability. This counterintuitive result arises from a phase alignment mechanism where the game's fixed two-elimination-per-round cadence creates parity-dependent terminal states.

The most promising cross-domain connections emerged between the random elimination game and two established fields: (1) **urn models** from classical probability, where the game maps exactly to a Pólya-type urn with asymmetric removal, importing powerful martingale-based asymptotic tools; and (2) the Catalog's **information-efficient search** framework (`Computation/InfoEfficientAlgorithms.lean`), since the werewolf-finding problem is fundamentally a search with one-bit queries (was the eliminated player a werewolf?). The `parityDefect` quantity introduced in this cycle is novel — it does not appear in existing game-theoretic literature and provides a precise scalar measure of the parity paradox's strength. The direction with highest breakthrough potential is Direction 1 (proving Skip-Two Monotonicity), as it would establish the complete monotonicity structure of the game and likely yield Diagonal Monotonicity as a corollary.

---

### Direction 1: Proof of Skip-Two Monotonicity via Generating Functions

**Conjecture**: For all natural numbers v ≥ w + 2 with w ≥ 1, the random elimination win probability satisfies P(v + 2, w) ≥ P(v, w). That is, adding two villagers to any viable game configuration (weakly) improves the villagers' win probability.

**Test**: Compute P(v + 2, w) - P(v, w) for all v ≤ 200, w ≤ 20 using exact rational arithmetic. If any value is negative, the conjecture is false. Additionally, attempt a formal Lean proof by strong induction on v + w — the recurrence relates P(v+2, w) and P(v, w) through four recursive calls that are themselves instances of the inequality at smaller parameter values.

**Impact**: If true, this completely characterizes the even/odd monotonicity structure: the even subsequence {P(2k, w)} and odd subsequence {P(2k+1, w)} are both increasing in k. Combined with the Parity Paradox, this gives a complete picture of how P varies with v. If false, the counterexample would reveal unexpected non-monotonicity at large parameters.

**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (information-efficient search structure), `Computation/GravityOracle.lean` (oracle-based convergence patterns)

**Proof Strategy**: Define G(v, w) = P(v+2, w) - P(v, w). Expand both terms using the recurrence to express G(v, w) as a non-negative linear combination of G(v', w') at smaller parameters, plus non-negative correction terms. The key algebraic step is showing that the coefficients in this expansion are all non-negative, which requires v ≥ w + 2 and the non-negativity/boundedness of P. Alternative: use generating functions F_w(x) = Σ P(v, w) x^v and show that the recurrence implies F_w has only non-negative Taylor coefficients in an appropriate transform.

**Domain Bridges**: Recursive probability <-> Generating function analysis <-> Urn model theory

**Lineage**: Builds on `winProb_nonneg`, `winProb_le_one`, `winProb_w1_recursion`, and the computational verification of skip-two for small parameters.

**Ambition**: grand_challenge

---

### Direction 2: Closed-Form Formula for P(v, 1)

**Conjecture**: The win probability with one werewolf has the closed form:
- P(2k, 1) = 1 - Π_{j=1}^{k-1} (2j)/(2j+1) · (2j-1)/(2j+1) for even v = 2k
- Equivalently, there exists a product formula involving ratios of odd and even numbers.

**Test**: Compute P(2k, 1) for k = 1, ..., 50 and compare against candidate closed forms. The recursion P(v, 1) = 1/(v+1) + v/(v+1) · P(v-2, 1) (proved in this cycle) should telescope into a product or sum of products. Test whether P(2k, 1) = 1 - Π_{j=1}^{k-1} (2j/(2j+1))² or similar expressions.

**Impact**: A closed form would immediately prove skip-two monotonicity for w = 1 (since the product formula would be visibly increasing) and establish the convergence rate P(v, 1) → 1. It would also connect to classical combinatorial identities involving double factorials and Wallis-type products.

**Catalog References**: `Algebra/Basic.lean` (product identities), `Computation/PadicValuationDepth.lean` (depth measures via valuations)

**Proof Strategy**: Unwind the recursion P(v, 1) = 1/(v+1) + v/(v+1) · P(v-2, 1) starting from P(2, 1) = 1/3. Each step multiplies by v/(v+1) and adds 1/(v+1). After k steps: P(2k, 1) = Σ_{j=1}^{k} [1/(2j+1)] · Π_{i=j+1}^{k} [2i/(2i+1)]. This sum-product form may simplify using partial fractions or Wallis-type identities. Formalize in Lean using Finset.sum and Finset.prod.

**Domain Bridges**: Recursive probability <-> Combinatorial identities <-> Wallis products

**Lineage**: Builds on `winProb_w1_recursion` (the clean recursion for w = 1).

**Ambition**: extension

---

### Direction 3: Urn Model Embedding and Martingale Analysis

**Conjecture**: The win probability P(v, w) equals the probability that a specific stopped martingale remains positive, where the martingale is the log-ratio process log(V_t / W_t) in a Pólya urn with asymmetric removal (V_t = villagers at time t, W_t = werewolves at time t). Specifically, define M_t = V_t - W_t; then M_t is a supermartingale under the game dynamics, and P(v, w) = P(M_t > 0 for all t | M_0 = v - w).

**Test**: Verify computationally that the martingale property holds: E[M_{t+1} | M_t] ≤ M_t for the random elimination process. Compute the explicit conditional expectation and check the sign of E[M_{t+1} - M_t | state = (v, w)].

**Impact**: If M_t is a supermartingale, Doob's optional stopping theorem and maximal inequalities would immediately give bounds on P(v, w) in terms of v - w. This would provide the first analytic (non-recursive) bounds on the win probability and could prove the convergence conjectures. More broadly, it would establish a formal bridge between combinatorial game theory and stochastic process theory.

**Catalog References**: `Computation/GravityOracle.lean` (convergence of oracle processes), `Bridges/AlgebraEMLClosureComputation.lean` (closure under algebraic operations)

**Proof Strategy**: Define the process (V_t, W_t) formally as a Markov chain on ℕ × ℕ. Compute E[V_{t+1} - W_{t+1} | (V_t, W_t) = (v, w)] explicitly using the transition probabilities. Show this equals (v-w) · (1 - 2/(v+w)) - 1, which is ≤ v - w when v + w ≥ 3. Then apply optional stopping to bound P(v,w). Formalize using Mathlib's `MeasureTheory.Martingale` or construct the necessary measure theory from scratch.

**Domain Bridges**: Game theory <-> Stochastic processes <-> Measure-theoretic probability

**Lineage**: Builds on the urn model interpretation described in the research paper. New direction.

**Ambition**: grand_challenge

---

### Direction 4: Parity Defect Asymptotics and Rate of Convergence

**Conjecture**: The parity defect satisfies D(v, w) = 1 + c_w / v² + O(1/v³) as v → ∞ for fixed w, where c_w is a constant depending on w. For w = 1, we conjecture c_1 = 1/2 based on numerical fitting.

**Test**: Compute D(v, 1) for v = 2, 4, 6, ..., 200 and fit (D(v,1) - 1) · v² against a constant. If the fit converges, extract c_1. Repeat for w = 2, 3. Alternatively, expand the recursion for P(v, w) asymptotically in 1/v to derive the leading-order correction term.

**Impact**: The rate of convergence determines how quickly the parity paradox becomes negligible in large games. If the convergence is 1/v², the paradox is practically irrelevant for games with more than ~20 players. If slower (e.g., 1/v), it could matter in moderately-sized games. The constant c_w might reveal a clean formula relating the convergence rate to the werewolf count.

**Catalog References**: `Computation/PadicValuationDepth.lean` (asymptotic depth analysis), `EML/AdvancedTheory.lean` (complexity measures)

**Proof Strategy**: Write P(v, w) = 1 - g(v, w) where g(v, w) → 0 as v → ∞. Substitute into the recurrence to derive a recurrence for g. Show g(v, w) ~ C_w · Π_{j}(j/(j+1)) ~ C_w / v^{w} or similar. Then D(v,w) = (1 - g(v,w))/(1 - g(v+1,w)) ≈ 1 + g(v+1,w) - g(v,w) ≈ 1 + c_w/v². Formalize the asymptotic expansion using Lean's `Asymptotics` library.

**Domain Bridges**: Probability <-> Asymptotic analysis <-> Number theory (factorial growth rates)

**Lineage**: Builds on `parityDefect_decreasing_w1` and `parityDefect_convergence` (conjectured).

**Ambition**: extension

---

### Direction 5: Strategic Play and the Value of Information

**Conjecture**: Under optimal play (where the village uses a Bayesian-optimal voting strategy given observed votes), the win probability P*(v, w) satisfies P*(v, w) = 1 - (w/v)^w · (1 + o(1)) as v → ∞, and the parity paradox *disappears*: P*(v+1, w) ≥ P*(v, w) for all v > w. Information eliminates the phase alignment problem.

**Test**: Define a Bayesian voting model where each player's vote reveals partial information about their type. Compute P*(v, w) for small v, w using backward induction on the game tree. Check whether P*(3, 1) ≥ P*(2, 1) (the reverse of the random-play paradox).

**Impact**: If the parity paradox disappears under strategic play, it would show that the paradox is fundamentally an artifact of the *random* elimination model, not an intrinsic property of the game structure. This would have implications for the design of social deduction games: games that encourage strategic play are "smoother" than those that encourage random play. It would also connect to the Catalog's information-efficient algorithm framework.

**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (information-efficient search), `Computation/SearchTheory.lean` (search algorithms), `Algebra/BayesOptimal.lean` (Bayesian optimality)

**Proof Strategy**: Model strategic play as a signaling game where each player's vote is a function of their type (villager/werewolf) and the history of votes. Define the value function V(v, w, info_state) that tracks the village's win probability given their current information. Show that optimal voting makes V monotone in v by proving that additional villagers provide strictly more information per round. This requires formalizing the notion of "information value" in the game tree.

**Domain Bridges**: Game theory <-> Information theory <-> Bayesian inference <-> Search theory

**Lineage**: Builds on the random elimination baseline established in this cycle.

**Ambition**: grand_challenge
