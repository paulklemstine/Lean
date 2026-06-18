# Future Directions: Collatz Parity Cylinder Theory

## Synthesis

The formal verification of Collatz parity cylinders establishes a rigorous foundation at the intersection of arithmetic dynamics, symbolic coding theory, and density analysis. The five directions below form a coherent research program: Direction 1 (density-one descent) and Direction 2 (affine iterate formula) complete the Terras-style density theory at finite depth; Direction 3 (p-adic dynamics) opens the non-Archimedean perspective; Direction 4 (iterated descent chains) bridges finite-depth surrogates to total stopping time; and Direction 5 (entropy and mixing) connects to ergodic theory and information theory. Together, they constitute a formal "arithmetic renormalization" program for the Collatz map — each verified layer enabling the next.

---

## Direction 1: Density-One of Descent Words via Binomial Concentration

**Conjecture.** For every ε > 0, there exists K such that for all k ≥ K, the fraction of parity words w ∈ {0,1}^k with 3^(oddCount w) < 2^(evenCount w) (i.e., descent words) satisfies:

density(k) := |{a < 2^k : parityWord k a is a descent word}| / 2^k ≥ 1 − ε.

More precisely, the density of non-descent residue classes decays exponentially: there exist C > 0 and λ < 1 such that 1 − density(k) ≤ C · λ^k.

**Test.** Compute density(k) for k = 1, ..., 30 using the cylinder enumeration algorithm (O(2^k) time). Fit an exponential decay model to 1 − density(k). The conjecture is refuted if the decay rate is slower than exponential, or if density(k) fails to exceed 0.99 for any k ≤ 30.

Current computational evidence (k ≤ 20) shows density oscillating around 0.5 but with a general upward trend. More data is needed at larger k.

**Impact.** A formal proof would establish that Collatz descent is a "generic" phenomenon — almost all integers begin contracting within finite (but growing) depth. This is the quantitative bridge between cylinder classification and Terras's density-one result.

**Catalog References.** Builds on `Collatz/ParityCylinders.lean` (parityWord_determined_by_residue, residue_count_upper/lower) and `Collatz/AffineWords.lean` (exists_descent_word, countUpTo_partition).

**Proof Strategy.** The key challenge is that descent depends on the *fiber structure* of the parity-word map (how many residue classes map to each word), not just on word counting. Strategy: (1) prove an upper bound on non-descent fibers using the Fibonacci structure and binomial tail estimates; (2) connect fiber sizes to combinatorial properties of the parity word; (3) apply Hoeffding-type concentration.

**Domain Bridges.** Probability theory (concentration inequalities), combinatorics (Fibonacci-constrained binary strings), information theory (capacity of constrained channels).

**Lineage.** Direct extension of exists_descent_word and countUpTo_partition.

**Ambition.** Grand challenge — this is the core quantitative step toward Terras's theorem.

---

## Direction 2: Formal Affine Iterate Formula

**Conjecture.** For all k, n, w with parityWord k n = w:

(affineCoeffs k w).2.2 * ↑(step^[k] n) = (affineCoeffs k w).1 * ↑n + (affineCoeffs k w).2.1

That is, D · step^[k](n) = A · n + B where (A, B, D) = affineCoeffs k w.

**Test.** Already computationally verified for all k ≤ 10 and all residue classes plus random large values. The test succeeds for every value tried. To refute, find any n and k where the formula fails (none expected).

**Impact.** This is the algebraic linchpin connecting parity words to multiplicative dynamics. Once formalized, it immediately yields: (a) the precise descent criterion A < D; (b) integrality conditions determining which residue classes realize which words; (c) explicit bounds on orbit growth.

**Catalog References.** Uses `Collatz/ParityCylinders.lean` (affineCoeffs, step_even, step_odd) and standard Mathlib modular arithmetic.

**Proof Strategy.** Induction on k. The key technical step is handling ℕ ↔ ℤ coercions: in the even case, we need 2 * (x/2) = x when x is even (Nat.two_mul_div_two_of_even). In the odd case, step(x) = 3x+1 is direct substitution. The ℤ cast must be threaded carefully through the induction.

**Domain Bridges.** Algebra (affine maps over ℤ), number theory (integrality constraints), formal verification (coercion management).

**Lineage.** Direct formalization of the affineCoeffs definition already in `Collatz/ParityCylinders.lean`.

**Ambition.** Solid extension — high probability of success with careful coercion handling.

---

## Direction 3: 2-adic and 3-adic Collatz Dynamics

**Conjecture.** (a) The accelerated odd Collatz map A(n) = (3n+1)/2^{v₂(3n+1)} is locally affine on suitable residue classes: for each k, there exist explicit affine maps φ_{a,k} : ℤ → ℤ such that A(n) = φ_{a,k}(n) for all odd n ≡ a (mod 2^k) with v₂(3a+1) < k.

(b) The 2-adic valuation v₂(3n+1) is locally constant: if n ≡ m (mod 2^k) are both odd and v₂(3n+1) < k, then v₂(3m+1) = v₂(3n+1).

**Test.** For each k ≤ 10 and each odd residue class a mod 2^k, compute v₂(3a+1) and verify that the accelerated map agrees with the affine prediction for 1000 random elements of the class. The conjecture is refuted if any discrepancy is found.

**Impact.** Establishes the Collatz map as a piecewise-affine dynamical system over the 2-adic integers, connecting to the rich theory of p-adic dynamical systems (Anashin, Khrennikov). This opens the door to using non-Archimedean analysis — fixed-point theory, Mahler expansions, Volkenborn integration — for Collatz.

**Catalog References.** Builds on `Collatz/AffineWords.lean` (v2_mod_preserved_on_odd, iterate_congr_mod).

**Proof Strategy.** Part (b) follows from v2_mod_preserved_on_odd: if n ≡ m (mod 2^k), then 3n+1 ≡ 3m+1 (mod 2^k), and the 2-adic valuation is determined by the first k binary digits. Part (a) combines this with the affine coefficient recursion.

**Domain Bridges.** p-adic analysis, non-Archimedean dynamical systems, algebraic number theory.

**Lineage.** Extension of v2_mod_preserved_on_odd.

**Ambition.** Grand challenge — opens a new formal-methods front in p-adic dynamics.

---

## Direction 4: Iterated Descent Chains and Total Stopping Time

**Conjecture.** For all ε > 0, the set of positive integers n such that step^[k](n) < n^ε for some k ≤ C · log(n) has natural density 1, where C depends on ε.

This is a finite-depth analogue of Tao's (2019) "almost all orbits attain almost bounded values."

**Test.** For N = 10^6, compute for each n ≤ N the first k such that step^[k](n) < n^{0.5}, and verify that k ≤ C · log(n) for at least 99.9% of integers. The conjecture is refuted if the exceptional fraction exceeds 0.1% for any N ≤ 10^6.

**Impact.** This bridges the gap between single-descent events (Direction 1) and convergence to 1. Chaining multiple descents requires controlling dependencies between successive parity words — the core difficulty of the Collatz problem.

**Catalog References.** Would build on all results from `Collatz/ParityCylinders.lean` and `Collatz/AffineWords.lean`, plus Direction 1 (density-one descent).

**Proof Strategy.** Key idea: after one descent event of depth k₁, the new starting value is in a known residue class mod 2^{k₁}. Track the "renewal" structure: each descent event consumes some modular information and resets the parity-word analysis. The total stopping time is a sum of independent-like descent times.

**Domain Bridges.** Probability (renewal theory), dynamical systems (return maps), ergodic theory (mixing).

**Lineage.** Depends on Directions 1 and 2.

**Ambition.** Grand challenge — would represent significant progress toward Tao's result with explicit formal infrastructure.

---

## Direction 5: Entropy and Mixing of Parity Distributions

**Conjecture.** The Shannon entropy of the parity-word distribution on {0,...,N} converges to log₂(F(k+2)) as N → ∞, where F(k+2) is the (k+2)-th Fibonacci number. Moreover, the distribution over realized words approaches uniformity in a quantifiable sense.

Equivalently: for large N, the empirical distribution of parity words among {0,...,N} has entropy within O(1/N) of the uniform distribution on realized words.

**Test.** For k = 5, 10, 15 and N = 10^4, 10^5, 10^6, compute the empirical Shannon entropy and compare to log₂(F(k+2)). The conjecture is refuted if the entropy deficit does not shrink with N.

**Impact.** Establishes that the Collatz map is "maximally mixing" at finite depth — the symbolic dynamics behaves like a maximum-entropy process subject to the Fibonacci constraint. This is the information-theoretic analogue of equidistribution.

**Catalog References.** Uses `Collatz/AffineWords.lean` (countUpTo_partition, parityCylinder_partition) and the Fibonacci counting structure.

**Proof Strategy.** The entropy is maximized when all cylinders have equal density. By the cylinder classification, each cylinder's density is proportional to its fiber size. Show that fiber sizes are approximately equal using the structure of the parity-word map and residue-class counting.

**Domain Bridges.** Information theory (Shannon entropy, channel capacity), ergodic theory (entropy of shifts), coding theory (constrained codes).

**Lineage.** Extension of countUpTo_partition and the Fibonacci counting observation.

**Ambition.** Solid extension — connects the formal framework to quantitative information theory.
