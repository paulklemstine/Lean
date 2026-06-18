# Future Directions: Non-Archimedean Probability Theory

## What We Built

This cycle established `FinProbSpace F n` and `RegularFinProbSpace F n` — finite
probability spaces over arbitrary linearly ordered fields — with 7 machine-verified
theorems (zero sorries) covering inclusion-exclusion, Bayes, Markov, the Dutch Book
theorem (both directions), regular conditional probability, and a tropical bridge.

The central insight: **all classical finite probability is purely algebraic**. Nothing
in the proofs of Bayes' theorem, Markov's inequality, or the Dutch Book argument
uses completeness, the Archimedean property, or any analytic structure. The only
requirements are the ordered field axioms.

---

## Direction 1: Countable Non-Archimedean Probability via Formal Power Series

The key insight is that the Levi-Civita field ℝ((ε)) admits a natural "formal summation"
for countable sums of infinitesimals: ∑_{n≥0} ε is not convergent in the order topology
but is a well-defined element in an extension that tracks infinite sums as formal objects.
This suggests defining countable probability not via limits but via algebraic extension.

**Falsifiable prediction**: Define `CountableProbSpace` over the Levi-Civita field with
weight function w(n) = c·ε^{f(n)} where f : ℕ → ℕ is strictly increasing and c is a
normalization constant. Conjecture: the resulting structure satisfies countable additivity
if and only if f grows at least linearly, since ∑ ε^n converges iff it's a formal geometric
series.

**Why now?** Our `FinProbSpace` framework is parametric in the field — the same typeclass
constraints (`Field`, `LinearOrder`, `IsStrictOrderedRing`) apply to the Levi-Civita field.
The finite theory lifts directly via truncation arguments.

---

## Direction 2: Full Dutch Book Characterization (Both Directions, Negative Weights)

The key insight is that our `dutch_book_of_sum_ne_one` handles mispriced totals, but the
full Dutch Book theorem should also cover negative prices. The complete characterization
is: `¬ Nonempty (DutchBook F n p) ↔ (∀ i, 0 ≤ p i) ∧ ∑ p = 1`. The backward direction
is already `no_dutch_book`; the forward direction needs: if some p(i) < 0, construct an
explicit Dutch book by buying that single bet.

**Falsifiable prediction**: The explicit construction for negative prices is: stake s(i) = 1,
s(j) = 0 for j ≠ i, when p(i) < 0. Then profit at ω = i is 1 - p(i) > 0 (since p(i) < 0),
and profit at ω ≠ i is 0 - p(i) = -p(i) > 0. This should be formally verifiable in < 20
lines.

**Why now?** We have both `no_dutch_book` and `dutch_book_of_sum_ne_one`. The missing piece
is a single additional lemma handling negative weights, completing the iff.

---

## Direction 3: Tropical-Probability Functor via Valuation Maps

The key insight is that our `prob_weight_power_bound` theorem is already a *shadow* of the
tropical correspondence: when weights are ε^{k(i)}, probability is controlled by min(k(i)),
which is exactly the tropical sum. A formal functor F : NonArchProb → TropProb would send
weight ε^k ↦ k and probability (sum of ε^{k(i)}) ↦ min(k(i)).

**Falsifiable prediction**: Under the valuation map v(∑ a_k ε^k) = min{k : a_k ≠ 0},
the Bayes identity v(P(A|B)) + v(P(B)) = v(P(B|A)) + v(P(A)) holds exactly (not just
approximately) when all intersection probabilities are dominated by a single term.
Construct a 4-element counterexample where it fails due to cancellation in the leading term.

**Why now?** The `prob_weight_power_bound` provides the key estimate. Formalizing the
valuation map and connecting to existing tropical algebra structures in the Catalog
(`Tropical/` directory) would create a genuine cross-domain bridge.

---

## Direction 4: Non-Archimedean Game Values and Trembling-Hand Equilibria

The key insight is that the simplex method for linear programming is purely algebraic —
it works over any ordered field. This means minimax values of finite games exist over
non-Archimedean fields, yielding game values that are formal power series in ε encoding
both the standard value and sensitivity to dominated-strategy trembles.

**Falsifiable prediction**: For the 2×2 game with payoff matrix [[1,0],[0,1]] (matching
pennies), the minimax value over F = ℝ((ε)) with minimum probability ε is exactly
1/2 + O(ε). Compute the exact coefficient of ε and verify it equals 0 (by symmetry).
For the asymmetric game [[2,0],[0,1]], predict the coefficient is nonzero and compute it.

**Why now?** Our `FinProbSpace` already models mixed strategies over ordered fields.
The game-theoretic application requires only defining payoff matrices and the minimax
optimization problem, both of which are algebraic.

---

## Direction 5: Non-Archimedean Entropy via Khinchin Axioms

The key insight is that Shannon entropy can be characterized axiomatically (Khinchin 1957)
without reference to logarithms: it is the unique function H satisfying continuity,
maximality at uniform, additivity, and the grouping axiom. Over non-Archimedean fields,
"continuity" must be replaced by an algebraic condition, but the other three axioms
transfer directly.

**Falsifiable prediction**: Define H algebraically for `FinProbSpace F n` via the grouping
axiom: H(p₁,...,pₙ) = H(p₁+p₂, p₃,...,pₙ) + (p₁+p₂)·H(p₁/(p₁+p₂), p₂/(p₁+p₂)).
Conjecture: this recursion, together with H(1/n,...,1/n) = log(n) (for a formal log),
uniquely determines H. Test: verify H(1/2,1/3,1/6) = log(6) - (1/2)log(2) - (1/3)log(3)
matches the classical formula.

**Why now?** The `expectation` function in our framework already computes weighted sums.
Entropy is just `expectation` applied to the function i ↦ -log(w(i)), so the algebraic
scaffolding exists. The challenge is defining a formal logarithm compatible with the
ordered field structure.
