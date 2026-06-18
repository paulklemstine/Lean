# Future Directions

## Synthesis

This cycle established a formalized framework connecting Collatz dynamics to proof-theoretic barriers. The central insight is that the Collatz conjecture's difficulty arises from a structural tension: the even branch (n ↦ n/2) is a strict descent for n ≥ 2, while the odd branch (n ↦ 3n+1) strictly increases n. We proved this dichotomy formally as `collatz_descent_ascent_dichotomy`, and showed that these branches compose in predictable ways: two steps on an odd number yield (3n+1)/2, which is always ≥ n (the `collatz_two_step_lower_bound`).

The orbit descent theorem (`pow_two_reaches_one`) demonstrates that pure powers of 2 reach 1 in exactly k steps — making them the minimal-complexity orbits. The proof uses induction with `collatzStep_pow_two` at each step. This establishes a baseline: any number that eventually hits a power of 2 will converge, and the total stopping time is the sum of the pre-power-of-2 trajectory length plus the logarithmic descent.

The key structural gap that remains is quantifying how often odd steps occur relative to even steps in a generic Collatz orbit. If we could show that for any n, the density of odd-parity iterates is bounded below 1/2, the conjecture would follow from the asymptotic dominance of the halving steps. This connects directly to the ergodic theory of the Collatz map.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|-------------|
| `collatzStep_pow_two` | proved | Establishes that collatzStep halves positive powers of 2 |
| `pow_two_reaches_one` | proved | Powers of 2 reach 1 in exactly k steps — baseline orbit complexity |
| `pow_two_reachesOne` | proved | Corollary: 2^k satisfies the Collatz property |
| `collatz_two_step_odd` | proved | Two-step acceleration: odd n maps to (3n+1)/2 |
| `collatz_two_step_lower_bound` | proved | The odd branch always produces net increase: (3n+1)/2 ≥ n |
| `collatzStep_even_descent` | proved | Even branch strictly decreases for n ≥ 2 |
| `collatzStep_odd_increase` | proved | Odd branch strictly increases |
| `collatz_descent_ascent_dichotomy` | proved | Structural dichotomy: the fundamental tension in Collatz dynamics |

## Research Directions

### Direction 1: Parity Density Bounds for Collatz Orbits

**Hypothesis**: For any n > 1, if we define δ(n, K) = (number of odd iterates in the first K steps) / K, then lim sup_{K→∞} δ(n, K) < 1/2 implies n reaches 1.

**Test**: Formalize the connection between parity density and orbit descent. Prove that if δ < 1/2, the net multiplicative effect per step is < 1, forcing convergence. Compute δ for specific orbit families (e.g., n = 2^a · 3 - 1).

**Why now**: We proved `collatz_descent_ascent_dichotomy` which quantifies the per-step effect. The key insight is that an even step multiplies by 1/2 and an odd step multiplies by roughly 3/2, so the net effect over K steps is approximately (3/2)^{δK} · (1/2)^{(1-δ)K} = (3^δ / 2)^K. This is < 1 when δ < log(2)/log(3) ≈ 0.63.

**If true**: Reduces the Collatz conjecture to proving δ < log(2)/log(3) for all n — a concrete ergodic-theoretic statement.

**If false**: Would indicate that some orbits have anomalously high odd-parity density, suggesting the conjecture might fail or require fundamentally different methods.

### Direction 2: Accelerated Collatz Transfer Operator Spectral Gap

**Hypothesis**: The transfer operator T_s associated with the accelerated Collatz map (as defined in `MachineLearning/CollatzSpectral/Defs.lean`) has spectral radius < 1 at s = 1, which would imply finite total trajectory weight.

**Test**: Formalize the transfer operator on finite truncations of the odd-positive integers. Compute eigenvalues for truncations up to N = 1000, 10000. Prove monotonicity of the spectral radius as a function of s.

**Why now**: The `acceleratedCollatz_isOddPos` theorem (in `CollatzSpectral/Defs.lean`) ensures the accelerated map preserves the space of odd positives, making the transfer operator well-defined. The key insight is that the spectral gap encodes the average contraction rate of the dynamics — the same quantity as the parity density in Direction 1, but in operator-algebraic language.

**If true**: Provides a spectral proof of Collatz convergence, connecting dynamical systems to analytic number theory.

**If false**: The spectral radius equals 1, suggesting a critical (marginal) dynamical regime where standard contraction arguments fail.

### Direction 3: Proof Complexity of Collatz Verification

**Hypothesis**: The length of the shortest proof that "n reaches 1 under Collatz" in Peano Arithmetic grows as Ω(log²(n)) for generic n, but only O(log(n)) for n = 2^k.

**Test**: Formalize a measure of proof complexity as the number of steps in a formal verification. Prove that for n = 2^k, the proof of `pow_two_reaches_one` has exactly k induction steps. For n = 2^k - 1 (Mersenne-type), compute the actual trajectory and bound the proof length.

**Why now**: Our `pow_two_reaches_one` proof directly witnesses the O(log n) bound for powers of 2. The key insight is that powers of 2 have monotone-decreasing orbits (each step halves), while generic numbers have non-monotone orbits requiring tracking both ascent and descent — this non-monotonicity is what inflates proof complexity.

**If true**: Establishes a precise proof-theoretic barrier: Collatz verification has inherently superlogarithmic complexity for most inputs, explaining why no uniform proof strategy works.

**If false**: Would suggest a surprising shortcut — perhaps all Collatz proofs can be compressed to O(log n), which would itself be a breakthrough.

### Direction 4: Three-Step Net Effect Classification

**Hypothesis**: For any odd n ≥ 3, exactly one of three cases holds after the two-step acceleration (3n+1)/2: (a) the result is even and the next step halves it (net effect: 3n+1 → (3n+1)/4, descent if n > 1), (b) the result is odd and > n (ascent continues), or (c) the result is 1 (termination). Classify which n fall into each case.

**Test**: Prove that case (a) holds when n ≡ 3 (mod 4), case (b) when n ≡ 1 (mod 4), and case (c) only for n = 1. Verify computationally for n up to 10^6.

**Why now**: Our `collatz_two_step_odd` gives the two-step formula. The key insight is that the parity of (3n+1)/2 depends only on n mod 4, so three-step behavior is determined by residue classes — this gives a tree structure to Collatz orbits based on mod-4 classification.

**If true**: Provides the first level of a complete classification of Collatz orbit behavior by residue classes, potentially enabling proof by structural induction on the orbit tree.

**If false**: The mod-4 classification is too coarse — would need mod-8 or higher, suggesting fractal-like behavior in the orbit structure.

### Direction 5: Collatz Orbit Energy Function

**Hypothesis**: The function E(n) = n · 2^{-ν₂(n)} · 3^{-ν₃(n)} (where ν_p is the p-adic valuation) is a Lyapunov function for the accelerated Collatz map restricted to numbers with bounded 3-adic valuation.

**Test**: Define E formally and prove E(T(n)) < E(n) for odd n with ν₃(3n+1) = 0. Identify the exceptional set where E increases and prove it has density 0.

**Why now**: The `collatzNu2` definition in `CollatzSpectral/Defs.lean` already handles the 2-adic part. The key insight is that the Collatz map's interaction with both 2-adic and 3-adic structure is what makes it hard — a successful Lyapunov function must account for both simultaneously.

**If true**: Provides a constructive convergence proof for a positive-density subset of integers, the largest such result in the Collatz literature.

**If false**: No simple Lyapunov function exists, confirming the conventional wisdom that Collatz requires fundamentally non-constructive methods.
