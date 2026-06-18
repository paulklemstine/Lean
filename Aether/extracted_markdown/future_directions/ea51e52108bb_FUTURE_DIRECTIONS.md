# Future Directions: Information-Theoretic Cryptography and Computational Complexity

## 1. Shannon Optimality Characterization

Shannon's theorem gives a lower bound |K| ≥ |M| for perfect secrecy. The natural
next step is to formalize the *converse characterization*: an encryption scheme
achieves perfect secrecy with |K| = |M| = |C| if and only if it is (isomorphic to)
a one-time pad over a group. The key insight is that when |K| = |M|, perfect secrecy
forces each key set {k | enc(k,m) = c} to be a singleton for each (m,c) pair in the
image, which defines a Latin square structure equivalent to a group operation.

**Why now?** We already have `shannon_perfect_secrecy` and `otp_perfect_secrecy`
establishing both directions separately. The characterization theorem would unify
them into a single biconditional, requiring only the formalization of the Latin
square ↔ group correspondence for finite structures, which is within Mathlib's
reach via `Fintype` and `MulAction`.

## 2. Computational Indistinguishability and Pseudorandom Generators

Perfect secrecy requires |K| ≥ |M|, making it impractical. Modern cryptography
relaxes this to *computational* indistinguishability: two distributions are
indistinguishable if no polynomial-time algorithm can distinguish them with
non-negligible advantage. A pseudorandom generator (PRG) is a function
G : {0,1}^s → {0,1}^n (with n > s) that is computationally indistinguishable
from uniform. The key insight is that formalizing PRG security as a statement
about negligible functions (ε(n) = o(1/n^c) for all c) connects our
information-theoretic framework to the computational setting, and one can prove
that PRGs exist if and only if one-way functions exist (the Håstad-Impagliazzo-
Levin-Luby theorem).

**Why now?** Our `functions_exceed_descriptions` theorem already captures the
counting argument that most functions cannot be computed efficiently. Formalizing
negligible functions and asymptotic security notions in Lean 4 would bridge
the gap between information-theoretic and computational cryptography, enabling
a verified treatment of foundational results like Goldreich-Goldwasser-Micali
pseudorandom functions.

## 3. Entropy-Based Proof of Shannon's Bound

Our proof of `shannon_perfect_secrecy` uses a direct combinatorial injection
argument. An alternative proof uses Shannon entropy: H(M|C) = H(M) (perfect
secrecy) implies H(K) ≥ H(M) by the chain rule H(K) ≥ H(K|C) ≥ H(M|C) = H(M),
and since H(K) ≤ log|K| with equality iff K is uniform, we get log|K| ≥ H(M).
The key insight is that formalizing Shannon entropy for finite distributions
would yield not only an alternative proof of Shannon's theorem, but also
*tight* bounds: the entropy proof shows that perfect secrecy requires the key
to be *uniformly distributed* when |K| = |M|, a stronger conclusion than our
current cardinality bound.

**Why now?** Mathlib has `MeasureTheory.Measure.entropy` for general measures,
but discrete Shannon entropy over `Fintype` with clean API for conditioning
and chain rules is still underdeveloped. Building this infrastructure would
enable a wave of information-theoretic results: data processing inequality,
Fano's inequality, and the source coding theorem.

## 4. Circuit Complexity Lower Bounds via the Counting Method

Our `boolean_function_counting` theorem establishes that most Boolean functions
require descriptions longer than any fixed bound. To turn this into a genuine
circuit complexity lower bound, one needs to bound the number of Boolean
circuits of size s over a fixed basis. The key insight is that for circuits
with n inputs and s gates over a basis B, the number of circuits is at most
|B|^s · (n+s)^(2s) (each gate chooses an operation and two inputs from previous
gates/inputs). For s = o(2^n/n), this is less than 2^(2^n), proving that most
functions require circuits of size Ω(2^n/n)—the Shannon-Lupanov bound.

**Why now?** The counting argument infrastructure is in place. What remains is
formalizing a clean inductive definition of Boolean circuits in Lean 4 (as a
DAG with labeled nodes), proving the enumeration bound by induction on circuit
depth, and connecting it to `boolean_function_counting`. This would be the
first machine-verified circuit complexity lower bound.

## 5. Physical Computation Bounds and the Extended Church-Turing Thesis

The original motivation for this work was the connection between P ≠ NP and
physical law. While we cannot formalize the physical Extended Church-Turing
thesis (it is an empirical claim about physics), we *can* formalize its
mathematical consequences. The key insight is that Landauer's principle—erasing
one bit of information dissipates at least kT ln 2 energy—can be stated as a
theorem about reversible vs irreversible computation: any computation that
maps n bits to m < n bits must dissipate at least (n-m) · kT ln 2 energy.
Formalizing this as a theorem about bijections vs non-injective functions on
finite types would connect our cryptographic framework to thermodynamic
constraints.

**Why now?** Our `Decryptable` predicate already captures injectivity
(reversibility) of encryption. Formalizing Landauer's principle would require
defining an abstract energy cost function satisfying: (1) reversible operations
have zero energy cost, (2) erasing a bit costs at least 1 unit. The counting
argument from `functions_exceed_descriptions` then shows that any efficient
*irreversible* computation on an exponentially large function space must
dissipate energy proportional to the information lost—a mathematical shadow
of the second law of thermodynamics.
