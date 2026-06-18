# Future Directions: Quantum Proofs of Classical Theorems & Tropical Proof Complexity

The file `Catalog/Tropical/QuantumProofComplexity.lean` establishes a small but
load-bearing result: **proof complexity is a homomorphism into the tropical
semiring**. Disjunction becomes tropical addition (`min`), conjunction becomes
tropical multiplication (`+`), and unprovability is the tropical zero (`⊤`). On top
of this we formalized the prototypical "succinct certificate" phenomenon for the
pigeonhole principle and an affine simulation preorder between proof systems. The
directions below push each of these threads toward a quantitative theory of quantum
proof advantage.

## 1. The proof-complexity semiring homomorphism is *full*, not just on `∨`/`∧`

We proved `complexity (A ∪ B) = complexity A ⊓ complexity B` and
`complexity (sumSpec A B) = complexity A + complexity B`, i.e. the map
`L ↦ Tropical.trop (complexity L)` respects the two connectives. The conjecture is
that this map is a genuine semiring homomorphism from the *full* spectrum algebra
(union, sumset, the empty spectrum `0`, and the singleton `{0}` as `1`) into
`Tropical ℕ∞`, including the distributive law
`complexity (sumSpec A (B ∪ C)) = complexity (sumSpec A B) ⊓ complexity (sumSpec A C)`.

The key insight is that distributivity of "concatenate" over "choose" is exactly the
tropical distributive law `x + min(y,z) = min(x+y, x+z)`, which already holds
definitionally in `Tropical ℕ∞`; so the proof reduces to `complexity_and` plus
`complexity_or` with no new analytic content. Why now? Both halves are already proven
in the file, so the distributive law is a 10-line corollary that would upgrade the
result from "two identities" to "a verified semiring homomorphism", a citable
structural theorem.

## 2. A provable *exponential* (not merely unbounded) certificate separation

`succinct_separation` shows the colliding-pair certificate beats exhaustive
enumeration by an unbounded additive gap, and `pair_search_space` shows the pair sits
in a `(n+1)^2` search space encoded in `2·clog₂(n+1)` bits. The conjecture is the
sharp logarithmic law: there is a statement family whose shortest *self-certifying*
proof has length `Θ(log N)` while its shortest *enumerative* proof has length `Θ(N)`,
made precise as `enumLen n ≥ 2 ^ (witnessBits n / 2 - 1)` with `witnessBits` measured
in `Nat.clog 2`.

The key insight is that `Nat.clog 2` already gives both bounds for free —
`Nat.le_pow_clog` gives the lower envelope and `Nat.pow_pred_clog_lt`/`Nat.pow_clog_le`
the upper one — so the separation is a packaging of existing `clog` lemmas rather than
a new combinatorial argument. Why now? The constant-vs-unbounded version is already
formalized; replacing the additive gap by the `2 ^ (·)` bound turns a soft statement
into the exponential separation that the QMA framing actually claims.

## 3. From affine simulation to a genuine polynomial-simulation preorder

`Dominates` and `dominates_trans` give an affine ("degree 1") simulation preorder. The
conjecture is that the polynomial version `g x ≤ c · (f x)^k + c` is also a preorder
and, crucially, that composition controls the degree: simulating with degree `k` then
degree `m` yields degree `k·m`. This is the abstract backbone of "every classical
proof has a quantum proof shorter by at most a polynomial factor".

The key insight is that the degree multiplies under composition exactly as exponents
do, so transitivity is `(h x)^k` substituted into a degree-`m` bound and bounded by a
single `c'·(h x)^{k·m}+c'` via `Nat`-monotonicity of `pow` — no real analysis needed.
Why now? The affine case is already a clean two-line `nlinarith` proof; generalizing
the exponent is the natural next increment and yields the quotient preorder of "proof
systems up to polynomial equivalence", a reusable object for later cycles.

## 4. Tropical eigenvalue = asymptotic proof rate

Iterating a connective (e.g. an `n`-fold conjunction `A^{⊗n}`) multiplies tropical
complexities, so `complexity (A^{⊗n}) = n · complexity A`. The conjecture is that for a
recursively defined statement family given by a tropical *matrix* recurrence
`v_{n+1} = M ⊗ v_n` (min-plus matrix-vector product), the per-step growth of proof
complexity equals the **tropical (max-plus/min-plus) eigenvalue** of `M`, i.e. the
minimum mean cycle of the associated weighted graph.

The key insight is that the catalog already contains min-plus matrix algebra
(`Tropical.MinPlusAlgebra`, `Tropical.CollatzWielandt`, `Tropical.PerronFrobenius`):
the asymptotic proof rate `lim complexity(v_n)/n` is literally the Collatz–Wielandt
value those files compute, so this bridges *proof complexity* to *spectral tropical
geometry* with no new spectral theory. Why now? With `complexity_and` proven, the
`n`-fold law is immediate, and the eigenvalue identity is a direct application of an
existing catalog Perron–Frobenius theorem — a high-novelty cross-domain link that is
mostly assembly.

## 5. A measurement-collapse model of certificate verification

The "quantum" side of the title is still informal. The conjecture is that a QMA-style
verifier can be modeled tropically: a witness is a probability-weighted superposition
over certificates, and the verifier's accepting branch selects the `min`-cost
certificate, so the *expected verified cost* is exactly `complexity` of the spectrum —
measurement collapse is the tropical `sInf`. Formally: define a `Qubit`-indexed family
of certificates (reusing `Bridges.QuantumTropicalComputation.Qubit`) and prove the
Born-rule-weighted minimum cost equals `complexity`.

The key insight is that the Born rule's `argmax` over amplitudes and the tropical
`min` over costs are dual under Maslov dequantization (`exp(-cost/ħ)` amplitudes,
`ħ → 0`), a correspondence the catalog already exploits in
`Tropical_Feynman_Calculus_via_Maslov_Dequantization`. Why now? It connects the
existing `Qubit` formalization to the new `complexity` map, giving the first rigorous
(if idealized) sense in which a "quantum proof" and a tropical shortest certificate are
the same object — the precise statement the project's title promises.
