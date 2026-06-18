# Future Directions

## Synthesis

This research cycle introduced the Accuracy-Parameterized Elimination Game (APEG), a novel mathematical structure for analyzing social deduction games like Werewolf/Mafia. The APEG decouples information quality (voting accuracy *p*) from game structure (player counts *v*, *w*), revealing that these two factors interact in non-trivial ways. Three main theorems were formalized: the Parity Paradox (non-monotonicity of win probability in villager count), Information Monotonicity (better accuracy always helps), and the Adaptive Advantage (dynamic recalibration outperforms fixed accuracy).

The most promising cross-domain connection is between the APEG's recursive structure and the recursive majority functions studied in the Catalog's `RecursiveMajorityDepthRigidity.lean`. Both involve analyzing how *local decision quality* propagates through a *recursive composition* — in one case, Boolean function composition; in the other, sequential elimination rounds. The noise sensitivity of recursive majority (how small changes in input accuracy affect output) has a direct analog in the APEG: the derivative of win probability with respect to accuracy measures how sensitive the game outcome is to information quality.

The threshold accuracy result (the minimum *p* needed for 50% win probability) exhibits a tantalizing numerical regularity: the ratio threshold/base_rate appears to converge to approximately √3 across different game sizes. If this scaling law holds, it would connect elimination game theory to classical results in random walk theory and Brownian motion, where √3 appears as a critical scaling constant for certain first-passage problems.

---

### Direction 1: Universal Threshold Scaling via Random Walk Embedding

**Conjecture**: For the APEG with fixed wolf-to-player ratio w/(v+w) = r, the threshold accuracy p* satisfying apegWinProb(v, w, p*) = 1/2 scales as p* ~ r · √3 as v → ∞. More precisely, p*/(w/(v+w)) → √3 for all fixed ratios r ∈ (0, 1/2).

**Test**: Compute p* for game sizes v = 50, 100, 200, 500 with r = 0.2, 0.3, 0.4 and measure convergence of the ratio. A deviation greater than 5% from √3 at v = 500 would refute the conjecture.

**Impact**: If true, this provides a universal law governing information requirements in sequential elimination games. The appearance of √3 suggests a deep connection to random walk theory (where √3 appears in critical exponents for biased random walks on lattices). If false, the actual scaling constant and its dependence on r would itself be interesting — it could reveal phase transitions in the information structure.

**Catalog References**: `Pythagorean/BayesianWerewolf.lean` (APEG definitions and monotonicity theorem)

**Proof Strategy**: Embed the APEG dynamics as a biased random walk on ℤ, where steps of +1 (werewolf eliminated) and -1 (villager eliminated, plus night kill) occur with probabilities depending on p. The win probability corresponds to the walk reaching 0 before reaching a negative threshold. Apply Wald's identity or optional stopping theorem to derive the threshold.

**Domain Bridges**: Elimination Game Theory ↔ Random Walk Theory ↔ Information Theory

**Lineage**: Builds on the APEG structure and information monotonicity from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Noise Sensitivity of Recursive Elimination and the Majority Connection

**Conjecture**: The sensitivity of wolfProb(v, w) to small perturbations in the accuracy parameter (the derivative ∂/∂p apegWinProb(v, w, p) at p = w/(v+w)) is asymptotically equivalent to the noise sensitivity of the depth-⌊log₃(v+w)⌋ recursive majority function on 3^d inputs, up to multiplicative constants.

**Test**: Compute the APEG sensitivity numerically for v+w = 9, 27, 81, 243 (powers of 3) and compare to known noise sensitivity formulas for recursive majority. Match within 10% would be strong evidence.

**Impact**: This would establish a formal bridge between elimination game theory and Boolean function analysis, two seemingly unrelated areas. It would show that the APEG is a "continuous relaxation" of recursive majority, opening up the powerful toolkit of Boolean analysis (hypercontractivity, Fourier methods) for studying social deduction games.

**Catalog References**: `Pythagorean/RecursiveMajorityDepthRigidity.lean` (recursive majority structure), `Pythagorean/BayesianWerewolf.lean` (APEG)

**Proof Strategy**: 
1. Show that the APEG recurrence with w=1 and balanced accuracy has the same tree structure as recursive majority on 3 inputs.
2. Define a "game tree" version of the APEG that makes the recursive majority connection explicit.
3. Apply the Mossel-O'Donnell noise sensitivity framework to the game tree.

**Domain Bridges**: Elimination Game Theory ↔ Boolean Function Analysis ↔ Recursive Majority Theory

**Lineage**: Builds on APEG (this cycle) and recursive majority depth rigidity (prior Catalog result).

**Ambition**: grand_challenge

---

### Direction 3: Multi-Wolf Parity Classification

**Conjecture**: The parity paradox generalizes to w ≥ 2 werewolves, but the "good" and "bad" residue classes depend on w. Specifically, for w werewolves, the villager count v is "favorable" if v mod (w+1) is in a specific subset S(w) ⊂ {0, 1, ..., w}, and the win probability restricted to favorable residue classes is strictly monotone increasing.

**Test**: Compute wolfProb(v, w) for w = 2, 3, 4 and v ranging from w+1 to 30. Classify which residue classes v mod (w+1) yield higher win probabilities. Verify monotonicity within each favorable class.

**Impact**: Extending the parity paradox to multiple werewolves would reveal the full combinatorial structure of elimination game dynamics. The dependence of favorable residues on w could connect to modular arithmetic and cyclic group theory.

**Catalog References**: `Pythagorean/BayesianWerewolf.lean` (wolfProb, parity paradox for w=1)

**Proof Strategy**: 
1. Compute the loss recurrence for general w: show it has period w+1 structure.
2. Identify the dominant eigenvalue of the transfer matrix for each residue class.
3. Prove monotonicity within favorable classes by bounding ratios of consecutive terms.

**Domain Bridges**: Elimination Game Theory ↔ Modular Arithmetic ↔ Linear Recurrence Theory

**Lineage**: Extends the parity paradox from w=1 (this cycle) to general w.

**Ambition**: extension

---

### Direction 4: Strategic Night Kills and Nash Equilibria

**Conjecture**: When werewolves choose night kill targets strategically (targeting players with highest probability of identifying them), the resulting game has a unique Nash equilibrium in mixed strategies, and the equilibrium win probability for villagers with Bayesian play is strictly lower than the optimal Bayesian probability computed against random werewolf play.

**Test**: For the 7-player game (5v, 2w), compute the Nash equilibrium of the simultaneous game where villagers choose voting strategies and werewolves choose night kill strategies. Compare the equilibrium value to the non-strategic baseline.

**Impact**: This addresses the fundamental game-theoretic question: does strategic werewolf behavior qualitatively change the information structure? If the werewolf strategy has a unique equilibrium, it provides a definitive answer to "how hard is Werewolf?" in the game-theoretic sense.

**Catalog References**: `Pythagorean/BayesianWerewolf.lean` (APEG framework)

**Proof Strategy**: Model as a finite extensive-form game. Apply Zermelo's theorem (backward induction) for the finite-horizon version. Characterize the value function and optimal strategies via dynamic programming.

**Domain Bridges**: Elimination Game Theory ↔ Game Theory ↔ Mechanism Design

**Lineage**: Extends the APEG from this cycle by adding strategic werewolf behavior.

**Ambition**: extension

---

### Direction 5: Wallis Product Connection and Asymptotic Win Probability

**Conjecture**: The product formula for the loss probability Q(2m) = ∏ᵢ₌₁ᵐ 2i/(2i+1) has the asymptotic behavior Q(2m) ~ √(π/(4m+2)) as m → ∞. Consequently, wolfProb(2m, 1) → 1 as m → ∞, with rate of convergence 1 - √(π/(4m+2)).

**Test**: Compute Q(2m) for m = 10, 100, 1000 and verify the asymptotic formula matches to within 1%.

**Impact**: This connects the Werewolf game to the Wallis product for π, one of the most classical results in analysis. The π/2 connection would provide a beautiful closed-form asymptotic for the win probability and potentially lead to exact central limit theorem-type results for the game duration.

**Catalog References**: `Pythagorean/BayesianWerewolf.lean` (loss recurrence, product formula)

**Proof Strategy**: Use Stirling's approximation on the double factorial product. The product Q(2m) = (2m)!!/(2m+1)!! can be expressed in terms of Gamma functions, and the asymptotic follows from the duplication formula.

**Domain Bridges**: Elimination Game Theory ↔ Classical Analysis ↔ Number Theory (Wallis product)

**Lineage**: Builds on the loss recurrence proven in this cycle.

**Ambition**: extension
