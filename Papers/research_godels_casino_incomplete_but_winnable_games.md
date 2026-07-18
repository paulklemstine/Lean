# Gödel’s Casino: No-Free-Lunch Symmetry and Sharp Expected-Profit Bounds for Finite Logical Betting Games

**Aristotle**  
**July 18, 2026**

## Abstract

We study a finite betting game motivated by logical incompleteness. On each of $n$ rounds, a player predicts the Boolean truth value of a statement; a correct unit bet returns $+1$ and an incorrect bet returns $-1$. The model separates two questions that are often conflated: whether statements are decidable in a formal theory, and whether a player has probabilistic information about their truth values. We prove a deterministic no-free-lunch theorem: complementing every truth value negates the total payoff, so no fixed deterministic strategy wins strictly in every possible world. Every strategy has a nonpositive world, an adversarial world forces payoff $-n$, an agreeing world gives $n$, and every world–complement pair has average payoff zero. We then derive the exact expectation formula

$$
\mathbb{E}[T]=2\sum_{i=1}^{n}p_i-n,
$$

where $p_i$ is the probability that prediction $i$ is correct. Consequently, expected profit is positive if and only if aggregate accuracy exceeds $n/2$. A uniform accuracy lower bound $q$ gives expected payoff at least $n(2q-1)$; in particular, accuracy at least $2/3$ yields at least $n/3$. For $1{,}000$ cards at exact accuracy $2/3$, expected profit is exactly $1000/3$. We also show that $d$ certain predictions mixed with $u$ fair guesses have expected payoff exactly $d$. In finite possible-world semantics, valid and unsatisfiable statements support unit expected profit, while balanced statements support none, refuting any unconditional positive-profit claim based solely on logical independence. We conclude with algorithms, applications, and the additional assumptions needed for a genuine probabilistic theory of betting on undecidable statements.

## 1. Introduction

Gödelian incompleteness and set-theoretic independence reveal limits on what fixed axiom systems can decide. These results invite a game-theoretic question: can a player exploit undecidability by betting on the truth values of independent statements? The metaphor is attractive. A casino presents arithmetic or set-theoretic claims as cards; the player selects true or false; and a correct selection wins a unit.

The metaphor also carries a danger. Logical independence is not probabilistic randomness. A statement independent of a theory is neither automatically a fair coin nor automatically biased toward one truth value. To speak of expected profit, one must specify a probability model: how statements or worlds are sampled, how truth is settled, and what information the player possesses.

This paper isolates the finite probabilistic core of such a casino. The resulting theory has two complementary halves. The first is adversarial and distribution-free. It proves that deterministic strategies cannot obtain strictly positive payoff in all possible worlds because every world has a complement that reverses every outcome. The second is probabilistic and exact. Once success probabilities are supplied, expected payoff is an affine function of aggregate accuracy, with a sharp break-even threshold at one half.

These conclusions correct an unconditional conjecture that incompleteness itself yields a positive expected return. A return of $1/3$ per round does follow from $2/3$ predictive accuracy, but logical decidability or independence does not, by itself, imply such accuracy. Any density claim about “a fraction of arithmetic statements” additionally requires an encoding, size measure, sampling law, and density theorem.

The finite model is deliberately minimal. This allows the key principles to be stated without distractions and makes them applicable beyond logic—to binary forecasting, classification, ensemble decisions, and adversarial prediction.

## 2. The finite casino model

### 2.1 Cards, worlds, and strategies

Fix a positive or zero integer $n$. The casino offers cards indexed by $i\in\{1,\ldots,n\}$. Each card has a Boolean truth value. We write a world as a function

$$
w:\{1,\ldots,n\}\longrightarrow\{0,1\},
$$

where $1$ denotes true and $0$ denotes false.

A deterministic strategy is another Boolean function

$$
s:\{1,\ldots,n\}\longrightarrow\{0,1\},
$$

where $s(i)$ is the player’s prediction on card $i$. The strategy may have been designed using syntax, theorem-proving strength, heuristics, or any other information; after it is fixed, only its predictions enter the payoff calculation.

### 2.2 Unit and total payoff

**Definition 2.1 (Unit payoff).** For a prediction $a\in\{0,1\}$ and truth value $b\in\{0,1\}$, define

$$
 u(a,b)=
\begin{cases}
1,&a=b,\\
-1,&a\ne b.
\end{cases}
$$

**Definition 2.2 (Total payoff).** The total payoff of strategy $s$ in world $w$ is

$$
T(s,w)=\sum_{i=1}^{n}u(s(i),w(i)).
$$

Thus $T(s,w)$ is the number of correct predictions minus the number of incorrect predictions. If $c$ predictions are correct, then $n-c$ are incorrect and

$$
T(s,w)=c-(n-c)=2c-n.
$$

The payoff therefore lies between $-n$ and $n$ and has the same parity as $n$.

### 2.3 Complementary worlds

**Definition 2.3 (World complement).** The complement $\overline{w}$ of a world $w$ reverses every truth value:

$$
\overline{w}(i)=1-w(i).
$$

For Boolean values, exactly one of $w(i)$ and $\overline{w}(i)$ agrees with a fixed prediction $s(i)$. This elementary observation drives the deterministic theory.

## 3. Deterministic no-free-lunch results

### 3.1 Payoff antisymmetry

**Lemma 3.1 (Single-card complement identity).** For every Boolean prediction $a$ and truth value $b$,

$$
 u(a,1-b)=-u(a,b).
$$

**Proof sketch.** If $a=b$, then the original payoff is $1$, while $a\ne1-b$ and the complemented payoff is $-1$. If $a\ne b$, Booleanity forces $a=1-b$, so the original payoff is $-1$ and the complemented payoff is $1$. In both cases the sign is reversed. $\square$

**Theorem 3.2 (Complementary-World Theorem).** For every deterministic strategy $s$ and every world $w$,

$$
T(s,\overline{w})=-T(s,w).
$$

**Proof sketch.** Apply Lemma 3.1 on each card and sum:

$$
T(s,\overline{w})
=\sum_{i=1}^{n}u(s(i),\overline{w}(i))
=\sum_{i=1}^{n}-u(s(i),w(i))
=-T(s,w).
$$

$\square$

This is an exact identity, not an asymptotic statement. It holds for every finite $n$, including $n=0$.

### 3.2 Impossibility of a uniform strict win

**Corollary 3.3 (No uniform strict win).** No deterministic strategy has strictly positive total payoff in both a world and its complement.

**Proof sketch.** If $T(s,w)>0$, Theorem 3.2 gives $T(s,\overline{w})=-T(s,w)<0$. If $T(s,w)\le0$, the original world is already nonwinning. $\square$

**Corollary 3.4 (Existence of a nonpositive world).** For every deterministic strategy $s$, there exists a world $w$ such that

$$
T(s,w)\le0.
$$

**Proof sketch.** Choose any world. If its payoff is nonpositive, it is the required witness. Otherwise its complementary world has negative payoff by Theorem 3.2. $\square$

The quantifiers matter. The statement does not assert that every world is unfavorable; it states that no deterministic strategy is favorable in all worlds.

### 3.3 Exact extreme worlds

**Theorem 3.5 (Adversarial world).** Given any deterministic strategy $s$, define the adversarial world by

$$
w_{-}(i)=1-s(i).
$$

Then

$$
T(s,w_{-})=-n.
$$

**Proof sketch.** Every truth value is opposite to its prediction, so each of the $n$ cards pays $-1$. Summing gives $-n$. $\square$

**Theorem 3.6 (Agreeing world).** In the world $w_{+}=s$, every prediction is correct and

$$
T(s,w_{+})=n.
$$

**Proof sketch.** Each card pays $1$, and there are $n$ cards. $\square$

Together, Theorems 3.5 and 3.6 show that the full payoff range is attained for every strategy.

### 3.4 Pairwise zero average

**Theorem 3.7 (Complementary-pair average).** For every strategy $s$ and world $w$,

$$
\frac{T(s,w)+T(s,\overline{w})}{2}=0.
$$

**Proof sketch.** Substitute Theorem 3.2 into the numerator to obtain $T(s,w)-T(s,w)=0$. $\square$

If a probability distribution assigns equal mass to every world and its complement, this pairwise cancellation implies zero expected payoff for every deterministic strategy. Thus positive expectation cannot arise under complement symmetry without additional information or asymmetric weighting.

## 4. Expected payoff and the sharp accuracy threshold

### 4.1 Success probabilities

Now place the casino in a probabilistic setting. The strategy may still be deterministic, while the world is sampled from a distribution; alternatively, strategy randomization may be absorbed into the probability that each prediction is correct. Let

$$
p_i=\Pr[s(i)=w(i)]
$$

be the success probability on card $i$. No assumption of independence among cards is needed.

**Proposition 4.1 (Single-card expectation).** The expected unit payoff on card $i$ is

$$
\mathbb{E}[X_i]=2p_i-1.
$$

**Proof sketch.** A correct prediction, occurring with probability $p_i$, pays $1$. An incorrect prediction, occurring with probability $1-p_i$, pays $-1$. Therefore

$$
\mathbb{E}[X_i]=p_i-(1-p_i)=2p_i-1.
$$

$\square$

### 4.2 Exact total expectation

**Theorem 4.2 (Expected-Payoff Formula).** For $n$ cards with success probabilities $p_1,\ldots,p_n$,

$$
\mathbb{E}[T]=\sum_{i=1}^{n}(2p_i-1)
=2\sum_{i=1}^{n}p_i-n.
$$

**Proof sketch.** Total payoff is $T=\sum_iX_i$. Linearity of expectation gives $\mathbb{E}[T]=\sum_i\mathbb{E}[X_i]$, regardless of dependence. Proposition 4.1 then yields the formula. $\square$

The formula is affine and exact. Correlations influence variance and tail probabilities, but not this expectation once the marginal success probabilities are fixed.

### 4.3 Necessary and sufficient condition for profit

**Theorem 4.3 (Sharp aggregate criterion).** Expected profit is strictly positive if and only if aggregate success probability exceeds half the number of rounds:

$$
\mathbb{E}[T]>0
\quad\Longleftrightarrow\quad
\sum_{i=1}^{n}p_i>\frac{n}{2}.
$$

**Proof sketch.** By Theorem 4.2,

$$
\mathbb{E}[T]>0
\Longleftrightarrow
2\sum_i p_i-n>0
\Longleftrightarrow
\sum_i p_i>\frac n2.
$$

Each equivalence is reversible, proving necessity and sufficiency. $\square$

Equivalently, if $\overline p=(1/n)\sum_i p_i$ for $n>0$, then expected profit is positive exactly when $\overline p>1/2$. Equality gives break-even expectation, and average accuracy below one half gives negative expectation.

## 5. Uniform guarantees and the $2/3$ benchmark

**Theorem 5.1 (Uniform-Accuracy Lower Bound).** Suppose $p_i\ge q$ for every card. Then

$$
\mathbb{E}[T]\ge n(2q-1).
$$

**Proof sketch.** Summing the inequalities $p_i\ge q$ gives $\sum_i p_i\ge nq$. Insert this into Theorem 4.2:

$$
\mathbb{E}[T]
=2\sum_i p_i-n
\ge2nq-n
=n(2q-1).
$$

$\square$

The result is sharp: equality holds whenever every $p_i=q$.

**Corollary 5.2 (Two-thirds guarantee).** If every prediction succeeds with probability at least $2/3$, then

$$
\mathbb{E}[T]\ge\frac n3.
$$

**Proof sketch.** Apply Theorem 5.1 with $q=2/3$ and simplify $2(2/3)-1=1/3$. $\square$

**Proposition 5.3 (Constant-accuracy formula).** If every prediction has the same success probability $q$, then

$$
\mathbb{E}[T]=n(2q-1).
$$

**Proof sketch.** The sum of the $n$ identical probabilities is $nq$. Substitute into Theorem 4.2. $\square$

**Corollary 5.4 (Thousand-round lower bound).** For $1{,}000$ cards, if every success probability is at least $2/3$, then

$$
\mathbb{E}[T]\ge\frac{1000}{3}.
$$

**Corollary 5.5 (Thousand-round equality).** If every one of $1{,}000$ cards has success probability exactly $2/3$, then

$$
\mathbb{E}[T]=\frac{1000}{3}.
$$

These statements validate the numerical benchmark under its necessary accuracy hypothesis. They do not assert that a logical classification strategy achieves that hypothesis.

## 6. Certain knowledge and unresolved guesses

Suppose the deck consists of two groups. On $d$ cards, the player knows the truth and predicts correctly with probability $1$. On $u$ cards, the player has no edge and guesses fairly, with success probability $1/2$.

**Theorem 6.1 (Known-and-Fair Decomposition).** The expected payoff over the $d+u$ cards is exactly

$$
\mathbb{E}[T]=d.
$$

**Proof sketch.** Every certain card contributes $2(1)-1=1$ in expectation. Every fair card contributes $2(1/2)-1=0$. Therefore

$$
\mathbb{E}[T]=d\cdot1+u\cdot0=d.
$$

$\square$

The theorem has a direct conceptual interpretation: certain knowledge is valuable, while unresolved uncertainty with no predictive bias is neutral. Increasing $u$ increases exposure and variance under independent guessing, but it does not change expected profit.

## 7. Finite possible-world semantics

The preceding model treats success probabilities abstractly. A more semantic presentation begins with a finite set $\Omega$ of possible worlds carrying a probability distribution $\mu$. A statement is a Boolean-valued function

$$
A:\Omega\longrightarrow\{0,1\}.
$$

A constant bet $b\in\{0,1\}$ earns $u(b,A(\omega))$ in world $\omega$. Write

$$
r=\Pr_{\omega\sim\mu}[A(\omega)=1].
$$

Betting true has expected payoff $2r-1$, while betting false has expected payoff $1-2r$. The best constant bet therefore earns

$$
|2r-1|.
$$

**Theorem 7.1 (Optimal constant bet in a finite world model).** For a statement true with probability $r$, the optimal expected unit payoff among the two constant bets is $|2r-1|$. Betting true is optimal when $r\ge1/2$, and betting false is optimal when $r\le1/2$.

**Proof sketch.** The expected payoffs of the two choices are opposites, $2r-1$ and $1-2r$. Their maximum is the absolute value $|2r-1|$. $\square$

Three cases are immediate.

1. A **valid statement**, true in every world, has $r=1$. Betting true earns expected payoff $1$.
2. An **unsatisfiable statement**, false in every world, has $r=0$. Betting false earns expected payoff $1$.
3. A **balanced statement**, true with probability $1/2$, gives expected payoff $0$ under either bet, and its optimal expected profit is $0$.

On the two-world space $\Omega=\{0,1\}$ with uniform weights, the statement $A(\omega)=\omega$ is true in one world and false in the other. It is balanced, so no constant Boolean bet earns positive expectation. This explicit example refutes any universal lower bound of $1/3$ for statements whose truth varies across possible worlds.

If a proof system is sound for the chosen semantics, every provable statement is valid in the admissible worlds. Betting true on such statements then earns unit payoff. Soundness can therefore recover a positive result for provable cards. Independence alone cannot do so, because it does not determine $r$.

## 8. Why logical independence does not imply an edge

A statement is independent of a theory when neither it nor its negation is derivable from that theory, under suitable metatheoretic assumptions. This is a relation among syntax, derivability, and models. A probability such as $p_i$ is numerical data attached to a sampling experiment or state of information. One notion does not canonically generate the other.

Four ingredients are required to turn independent statements into a well-posed betting market.

**First, an encoding.** If cards are formulas, a concrete syntax and coding scheme must specify which finite strings count as formulas.

**Second, a size measure and sampling law.** Statements might be sampled by symbol length, quantifier depth, proof-search cost, or a generative process. Different choices induce different frequencies. There is no uniform distribution over a countably infinite set that assigns equal positive mass to every formula.

**Third, a settlement semantics.** For statements with different truth values in different models, the casino must specify an intended model or a probability distribution over models. Otherwise “correct” is not a single-valued event.

**Fourth, an information model.** The strategy’s success probabilities must follow from what it observes and how cards are generated. Merely labeling a card existential, universal, decidable, or independent does not prove a numerical accuracy bound.

Claims based on the arithmetic hierarchy require special care. The hierarchy organizes formulas according to alternating blocks of number quantifiers and computability properties. It does not by itself prove that at least one third of formulas at any level are decidable under an unspecified distribution. A density theorem would need the exact coding and limiting regime as hypotheses.

Thus the $1/3$ profit claim has a valid conditional core:

$$
\text{per-card accuracy at least }\frac23
\quad\Longrightarrow\quad
\text{expected profit at least }\frac13\text{ per card}.
$$

The unsupported step is the proposed derivation of $2/3$ accuracy from incompleteness or hierarchy membership alone.

## 9. Algorithms and numerical experiments

### 9.1 Deterministic payoff audit

Given prediction and truth arrays of equal length, total payoff can be computed in one pass. Add $1$ when entries agree and $-1$ otherwise. The algorithm uses $O(n)$ time and $O(1)$ auxiliary space. A complement audit flips every truth bit and confirms that the two totals sum to zero. Constructing the adversarial world by flipping each prediction confirms the exact value $-n$.

### 9.2 Expected-value calculator

Given probabilities $p_1,\ldots,p_n$, compute

$$
E=\sum_{i=1}^{n}(2p_i-1).
$$

The calculation is linear in $n$ and requires constant auxiliary space if probabilities are streamed. It also reports the aggregate threshold comparison $\sum_i p_i\mathrel{?}n/2$.

### 9.3 Monte Carlo experiment

For the constant-accuracy benchmark, generate $n$ independent Bernoulli success indicators with parameter $q$. Convert each success to $+1$ and each failure to $-1$, and sum. Repeating for $m$ trials costs $O(mn)$ time. The sample mean approaches $n(2q-1)$ as $m$ grows. Independence is used here to create a simple simulator and to describe concentration; it is not needed for the expectation theorem.

For $n=1000$ and $q=2/3$, the theoretical center is $1000/3$. The variance under independent rounds is

$$
\operatorname{Var}(T)=4nq(1-q)=\frac{8000}{9},
$$

so the standard deviation is approximately $29.81$. This quantifies session-to-session fluctuation around the positive mean.

## 10. Applications

### 10.1 Binary forecasting

A forecaster receives $+1$ for a correct yes/no prediction and $-1$ otherwise. Theorems 4.2 and 4.3 show that profitability depends only on average accuracy crossing $1/2$ when stakes are equal. Calibration, base rates, and side information matter because they determine the $p_i$ values.

### 10.2 Classification

For balanced binary classification under symmetric rewards, total reward is an affine transform of the number of correct classifications. The complementary-world theorem is an adversarial reminder: without distributional assumptions, labels can be chosen opposite to any fixed classifier. Generalization guarantees necessarily rely on restrictions on data generation, hypothesis classes, or observed samples.

### 10.3 Markets and decision systems

The model captures the simplest prediction market with even odds. An unresolved proposition is not automatically a favorable security. Profit requires a mismatch between market terms and informed probability. Likewise, uncertainty in scientific or medical decisions has value only when evidence shifts success probability away from the break-even threshold.

### 10.4 Logical heuristics

Syntactic classes and proof-search signals may become useful features in a genuine statistical model of formulas. Their usefulness must be measured by predictive performance under a stated distribution. The present bounds then translate measured accuracy into expected payoff without any further logical assumptions.

## 11. Discussion

The deterministic and probabilistic results fit together tightly. Complementation proves that unrestricted worlds permit no universal deterministic win. Probability can break this symmetry, but only by weighting worlds or outcomes so that predictions are correct more often than not. The exact expected-payoff formula quantifies the required asymmetry.

This distinction resolves an apparent paradox. Mathematical incompleteness limits derivability, yet a player might still predict an independent statement correctly in a distinguished model. There is no contradiction: derivability and prediction are separate resources. But the prediction requires evidence or a prior over models. Incompleteness alone supplies neither.

The results also distinguish expected profit from guaranteed profit. Even when each card is correct with probability $2/3$, a realized sequence can lose. The guarantee is on expectation. Strong high-probability guarantees require assumptions such as independence or bounded dependence, after which concentration inequalities can be applied. In adversarial play, the exact $-n$ world remains available.

The finite setting avoids measure-theoretic complications while exposing the entire algebraic structure. Its formulas extend immediately to unequal stakes: if card $i$ has stake $a_i\ge0$, then expected payoff is $\sum_i a_i(2p_i-1)$. Optimal stake selection would require constraints and reliable probabilities, opening connections to portfolio theory and online learning.

## 12. Future work

A complete theory of logical betting should define a probability space of encoded formulas, a settlement semantics, and a measurable strategy, then lift the finite calculation to general expectation. Randomized strategies should be analyzed under adversarial and Bayesian models, with a minimax theorem clarifying precisely when randomization can help.

Further directions include weighted stakes, transaction costs, abstention, proper scoring rules, and sequential learning. A strategy that updates after observing resolved cards could be compared with static prediction through regret bounds. Formula generators could be studied under explicit complexity measures, allowing meaningful density questions about decidability.

On the semantic side, probability distributions over finite model classes provide an immediate laboratory. More ambitious models would need careful treatment of infinite structures and model-dependent truth. Sound proof systems can be integrated as sources of certain predictions, while unresolved cards can be assigned probabilities derived from explicit statistical or semantic assumptions.

Finally, empirical studies could test whether syntactic features—quantifier patterns, formula length, fragments of arithmetic, or proof-search traces—predict truth under well-defined generated distributions. Any resulting accuracy estimate would feed directly into the sharp criterion established here.

## 13. Conclusion

Gödel’s Casino has a simple accounting identity at its heart. A correct unit prediction pays $1$, an incorrect prediction pays $-1$, and therefore success probability $p$ is worth $2p-1$ in expectation. Across $n$ cards, expected profit is positive exactly when aggregate accuracy exceeds $n/2$.

Before probabilities are introduced, complement symmetry rules out a universal deterministic victory. Every strategy has a nonpositive world; the direct adversarial world yields $-n$; the agreeing world yields $n$; and complementary worlds average to zero. After probabilities are introduced, a uniform $2/3$ accuracy guarantee yields the advertised $1/3$ expected profit per card, including exactly $1000/3$ for $1{,}000$ constant-accuracy rounds. Certain knowledge contributes profit, while fair unresolved guesses contribute zero.

The final message is not that incompleteness is useless for prediction, but that it is insufficient by itself. Logical independence identifies what a theory cannot settle. A winning bet requires something further: a semantics, a distribution, and information that moves predictive accuracy beyond chance.