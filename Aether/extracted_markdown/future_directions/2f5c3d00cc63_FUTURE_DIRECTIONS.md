# Future Directions: Reversible Computing and Thermodynamic Efficiency

## Hypothesis 1: Rank-Entropy Law for Finite Fields

**Conjecture:** For any prime power $q$ and linear map $A : \mathbb{F}_q^n \to \mathbb{F}_q^m$, the Shannon entropy drop of the pushforward under uniform input is exactly
$$H(X) - H(AX) = \dim \ker(A) \cdot \log q$$
where $X$ is uniformly distributed over $\mathbb{F}_q^n$.

**Test:** Formalize for $\mathbb{F}_2 = \text{ZMod}\ 2$ first, using Mathlib's `LinearMap.ker` and `Module.finrank`. Verify computationally for all $2 \times 3$ matrices over $\mathbb{F}_2$ (there are $2^6 = 64$ such matrices). Then prove the identity by showing that the pushforward of the uniform distribution through $A$ is uniform on the image of $A$, with each fiber having exactly $q^{\dim \ker A}$ elements.

**Impact:** This would create a clean algebraic formula connecting linear-algebraic rank deficiency to thermodynamic dissipation cost, providing a precise bridge between coding theory and thermodynamics.

## Hypothesis 2: Garbage-Compression Tradeoff

**Conjecture:** For a reversible implementation $R : \alpha \times \gamma \to \alpha \times \gamma$ of a function $f : \alpha \to \beta$ that produces structured garbage in $\gamma$, if the garbage is compressible to $k$ bits via an injective compressor $C$, then the description complexity of the implementation satisfies a tighter bound via `compressor_gives_complexity_bound` than the generic $\log |\gamma|$.

**Test:** Instantiate on the parity function with $n$ input bits. The reversible lift produces $(x, \text{parity}(x))$ — the garbage is the full input $x$, which has structure (it encodes its own parity). Construct an explicit compressor that removes one redundant bit, and verify the resulting complexity bound is $n - 1$ rather than $n$. Compare with the bound from `complexity_bound_implies_finite_entropy_bound`.

**Impact:** This would establish that reversible implementations with algorithmically compressible garbage enjoy strictly better thermodynamic efficiency guarantees, formalizing the intuition that "predictable garbage is cheap to erase."

## Hypothesis 3: Tropicalization of Entropy Loss

**Conjecture:** The classical Shannon entropy loss $H(X) - H(f(X))$ for a finite function $f$ admits a min-plus (tropical) shadow: define the tropical entropy loss as $\max_y \log |f^{-1}(y)|$ (the log of the maximum fiber size). Then:
1. The tropical bound is always $\leq$ the classical entropy loss for uniform input.
2. Equality holds when $f$ has uniform fibers (all fibers the same size).
3. The tropical bound composes multiplicatively under function composition in the min-plus semiring, compatible with `tropical_landauer_bound`.

**Test:** Verify parts (1) and (2) on all 2-input Boolean functions. For part (3), compose AND gates in a binary tree of depth 2 and check whether the tropical cost of the composition equals the tropical sum (min-plus product) of individual gate costs. Formalize the inequality for general finite functions and prove equality for the uniform-fiber case.

**Impact:** This would open a new subfield of "tropical thermodynamics of computation," where min-plus algebra provides tight lower bounds on irreversible cost, directly connecting to the existing `tropical_landauer_bound` and `tropical_and_bound` theorems.

## Hypothesis 4: Optimal Ancilla Conjecture

**Conjecture:** For a finite function $f : \alpha \to \beta$ with maximum fiber size $M = \max_y |f^{-1}(y)|$, any reversible implementation $R : \alpha \times \gamma \to \alpha \times \gamma$ (where $R$ is bijective and projects to compute $f$) that resets the ancilla register to a standard state must use an ancilla space of size $|\gamma| \geq M$.

Equivalently, the minimum number of ancilla bits is $\lceil \log_2 M \rceil$.

**Test:** Exhaustively verify on all Boolean functions $f : \{0,1\}^n \to \{0,1\}$ for $n = 2, 3$. For each function:
1. Compute the maximum fiber size $M$.
2. Attempt to construct a bijective implementation with ancilla space of size $M - 1$ (should fail).
3. Construct a successful implementation with ancilla space of size $M$.
Then isolate the proof pattern: the pigeonhole principle applied to the reset condition forces $|\gamma| \geq M$.

**Impact:** This would provide a precise, constructive lower bound on the physical resources needed for irreversible computation, directly certifiable in the formal system.

## Hypothesis 5: Complexity-Thermodynamics Equivalence

**Conjecture:** For finite-state computations with bounded reversible description complexity $K$, the Shannon entropy of the reachable state ensemble is bounded by $K \cdot \log 2$ plus a universal constant. More precisely, a reversible specialization of `complexity_bound_implies_finite_entropy_bound` yields:

If a reversible implementation $R$ has description complexity at most $K$ (in the sense of injective encoding into $\text{Fin}(2^K)$), then the support of any reachable distribution has at most $2^K$ elements, and the Shannon entropy is at most $K \cdot \log 2$.

**Test:** Formalize using the existing `complexity_bound_implies_finite_entropy_bound` theorem. Instantiate on reversible circuits composed of Toffoli gates (which are universal for reversible computation). Show that a circuit with $K$ Toffoli gates on $n$ wires has description complexity $O(K \cdot n)$, yielding an entropy bound of $O(K \cdot n \cdot \log 2)$ on the output ensemble.

**Impact:** This would complete the bridge between Kolmogorov-style description complexity and physical entropy, creating a formal framework where circuit complexity bounds automatically yield thermodynamic efficiency guarantees — the foundation of a Lean-certified "thermodynamic complexity theory."
