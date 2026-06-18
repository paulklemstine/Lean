# Future Directions: Reversible Computing and Thermodynamic Efficiency

## 1. Tight Ancilla Bound for General (Non-Surjective) Functions

Our `exists_revSim_of_surjective` proves that surjective endofunctions on `Fin n` can be made reversible with 1 ancilla bit (since surjective = bijective on finite types). The genuinely hard case is non-surjective functions where the max fiber size exceeds 1.

**Conjecture**: For any `f : Fin n → Fin n` with maximum fiber size `k`, there exists a reversible simulation using exactly `Fin k` ancilla, and this is tight — no simulation with `Fin (k-1)` ancilla exists.

The key insight is that the lower bound follows from a pigeonhole argument: if the ancilla space has fewer than `k` elements, then two inputs in the same fiber with the same ancilla must collide, violating injectivity of the simulation bijection.

**Why now?** We have the fiber infrastructure (`fiber`, `maxFiberSize`, `injective_iff_maxFiber_le_one`) and the `RevSim` structure already in place. The upper bound construction requires enumerating fibers and constructing an explicit bijection using `Finset.equivFin`, which is available in Mathlib.

## 2. Circuit Complexity of Reversible Simulation

The Toffoli gate is universal for reversible Boolean computation (any bijection on `Bool^n` can be decomposed into Toffoli gates). We formalized the Toffoli gate and showed it simulates AND.

**Conjecture**: Any function `f : (Fin 2)^n → (Fin 2)^n` can be expressed as a composition of at most `O(n · 2^n)` Toffoli gates applied to `(Fin 2)^(n + O(n))` (i.e., with O(n) ancilla bits). Furthermore, there exist functions requiring `Ω(2^n / n)` Toffoli gates (a counting/Shannon-style lower bound).

The key insight is that the upper bound follows from the standard construction: decompose f into a sequence of controlled-NOT operations using the truth table, and each row requires at most n Toffoli gates. The lower bound is a counting argument comparing the number of possible circuits of given size to the number of bijections.

**Why now?** The Toffoli and Fredkin gate formalizations provide the atomic building blocks. Formalizing circuit composition as lists of gate applications on `(Fin 2)^n` would connect to the existing `rev_compose` theorem and the group structure of `Equiv.Perm`.

## 3. Shannon Entropy Preservation Under Bijections

We proved that bijections preserve cardinality (`bijection_preserves_fiber_card`) and information content of uniform distributions (`bijection_preserves_info`). The natural next step is full Shannon entropy.

**Conjecture**: For any probability distribution `p : α → ℝ≥0∞` on a finite type and any bijection `σ : α ≃ α`, the Shannon entropy `H(p) = -∑_x p(x) log p(x)` equals `H(p ∘ σ⁻¹)`. Moreover, for any non-injective function `f : α → α`, there exists a distribution `p` such that `H(f_* p) < H(p)` (entropy strictly decreases under irreversible maps for some distributions).

The key insight is that Shannon entropy is a symmetric function of the probability vector, and bijections merely permute the vector. The strict decrease for non-injective maps follows because collapsing fibers forces probability mass to merge, which strictly decreases entropy by the strict concavity of `-x log x`.

**Why now?** Mathlib has `MeasureTheory.entropy` and related infrastructure. The challenge is connecting our finite combinatorial setup to the measure-theoretic entropy definition, but `Finset.sum` over explicit distributions avoids most measure theory overhead.

## 4. Reversible Computation and Kolmogorov Complexity

**Conjecture**: For any computable bijection `f : ℕ → ℕ`, the Kolmogorov complexity satisfies `K(f(n)) ≤ K(n) + O(1)` and `K(n) ≤ K(f(n)) + O(1)`. That is, reversible computation preserves Kolmogorov complexity up to an additive constant. For non-injective computable `f`, there exist infinitely many `n` with `K(f(n)) < K(n) - log(|f⁻¹(f(n))|) + O(1)`.

The key insight is that reversibility in the Kolmogorov setting means the description of the inverse is bounded (since it's computable), so the overhead is O(1). The loss for non-injective functions comes from the coding theorem: you lose the information needed to distinguish elements within a fiber.

**Why now?** While Kolmogorov complexity is not directly computable, the inequalities can be stated as relations between program sizes in a fixed universal Turing machine model. Our fiber-size infrastructure provides the combinatorial backbone, and Lean's computability library provides the TM model.

## 5. Thermodynamic Cost of Sorting

**Conjecture**: Any comparison-based sorting algorithm on `n` elements, when implemented reversibly, requires at least `⌈log₂(n!)⌉` ancilla bits, and merge sort achieves this bound (up to lower-order terms). The thermodynamic cost (in units of `kT ln 2`) of irreversible sorting is exactly `log₂(n!)`.

The key insight is that sorting maps `n!` permutations to a single sorted output, so the fiber of the "sort" function has size `n!`. By our `maxFiberSize` framework, this requires `n!` ancilla states, which is `⌈log₂(n!)⌉` bits. This connects algorithmic complexity (comparison lower bounds) to thermodynamic cost via Landauer's principle.

**Why now?** We have the fiber framework and the Landauer bound infrastructure. Formalizing sorting as a function `Equiv.Perm (Fin n) → Fin 1` (collapsing all permutations to one output) makes the fiber size exactly `n!`, directly applying our theory. Mathlib's `Nat.factorial` and Stirling's approximation provide the asymptotic analysis.
