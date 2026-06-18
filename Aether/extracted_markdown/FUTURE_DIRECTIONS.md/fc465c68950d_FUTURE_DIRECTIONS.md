# Future Directions: Reversible Computing and Thermodynamic Efficiency

## 1. Shannon Entropy Preservation for Bijective Maps

The current formalization proves fiber-size preservation under bijections (fiber_card_equiv), which is the combinatorial skeleton of entropy preservation. The natural next step is to formalize Shannon entropy H(X) = -Σ p(x) log p(x) for discrete probability distributions on finite types, and prove that bijections preserve it exactly: H(f(X)) = H(X) when f is a bijection.

The key insight is that Shannon entropy depends only on the multiset of probabilities, which in turn depends only on fiber sizes — and we have already proved fiber sizes are invariant under bijective pre-composition. This reduces the entropy theorem to a purely combinatorial fact we have already established.

Why now? Mathlib now has `Real.log` and `Finset.sum` infrastructure mature enough to support this formalization. The fiber_card_equiv theorem provides the missing bridge between the combinatorial and measure-theoretic views.

## 2. Landauer's Bound in Bits: The kT ln 2 Connection

Our infoDeficiency measures information loss in units of "collapsed states." The physical Landauer bound states that erasing one bit dissipates at least kT ln 2 energy. Formalizing this requires defining a discrete energy functional E(f) = kT · ln 2 · (card α - card(image f)) and proving it is a lower bound on heat dissipation for any implementation of f.

The key insight is that this is really a theorem about the logarithm of the fiber partition function: the energy cost is proportional to log₂(card α / card(image f)), which our infoDeficiency already captures in exponentiated form.

Why now? The deficiency_subadditive theorem shows our information-loss measure composes correctly, which is the crucial property needed for the energy functional to be physically meaningful across composed circuits.

## 3. Toffoli Gate Universality for Reversible Boolean Circuits

Any bijection on {0,1}^n can be decomposed into Toffoli gates (controlled-controlled-NOT). This is the reversible analog of the universality of NAND gates for classical circuits. Formalizing this requires defining Toffoli gates as Equiv.Perm (Fin 2 ^ n) and proving that they generate the full symmetric group on Boolean strings of sufficient width.

The key insight is that Toffoli universality reduces to showing that every even permutation on {0,1}^n (n ≥ 3) decomposes into Toffoli gates, plus showing that the Fredkin gate (which is a product of Toffolis) generates all transpositions when combined with Toffoli.

Why now? Our algebraic framework (reversible_comp, reversible_inverse) already establishes the group structure of reversible computations. The missing piece is the generator theorem, which is a finite group theory result that should be accessible with Mathlib's permutation group infrastructure.

## 4. Garbage-Free Reversible Simulation and Space Complexity

Bennett's embedding theorem (bennett_injective) shows any function can be made reversible, but it uses the entire input as "garbage" ancilla. Bennett's 1989 result shows that any T-time, S-space computation can be simulated reversibly in time O(T^(1+ε)) and space O(S · log T), with no garbage output. Formalizing this space-time tradeoff would connect reversible computing theory to computational complexity.

The key insight is that the garbage can be "uncomputed" by running the computation forward, copying the output, then running backward — but this naive approach cubes the time. The pebble game on computation graphs gives the tight tradeoff.

Why now? The ancilla_lower_bound_erasure theorem establishes that garbage is sometimes unavoidable (for erasure), creating the right contrast with Bennett's result that garbage can always be cleaned up for invertible-output functions. This duality is the mathematical core of reversible complexity theory.

## 5. Entropy Production Rate for Markov Chains on Reversible vs. Irreversible Circuits

Extend the discrete formalization to stochastic computation: define discrete-time Markov chains on finite state spaces and prove that detailed-balance (reversible) Markov chains have zero entropy production, while non-reversible chains have strictly positive entropy production rate. This connects our algebraic reversibility to the thermodynamic arrow of time.

The key insight is that detailed balance is the stochastic generalization of bijectivity: a Markov chain satisfies detailed balance iff its transition matrix, weighted by the stationary distribution, is symmetric — which is exactly the condition that makes the process time-reversible.

Why now? The fiber_sum_eq_card theorem provides the partition-of-unity structure needed for probability distributions, and bijection_fiber_size characterizes when fibers are uniform (the deterministic case of detailed balance). The generalization to stochastic maps is the natural next step.
