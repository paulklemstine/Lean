# Future Directions: Topological Quantum Error Correction from Homological Persistence

The file `BarcodeCode.lean` establishes the algebraic core of the
"barcode-as-code" program. A length-3 chain complex `C₂ → C₁ → C₀` over a field
`K` is realized as a CSS quantum code: qubits are a basis of `C₁`, X- and
Z-stabilizers are the rows of `d₂` and `d₁`, and the logical operators are the
first homology `H₁ = ker d₁ / im d₂`. We proved (1) the CSS commutation law
`range_le_ker`, (2) the `[[n, k]]` parameter identity
`css_parameters : n = rank d₁ + rank d₂ + k`, and (3) the persistence bridge:
a chain map (filtration inclusion) induces a map on homology whose rank — the
**persistent first Betti number** — is bounded by the logical-qubit count at
*both* the birth and the death scale (`persistentBetti_le_birth`,
`persistentBetti_le_death`).

These results suggest several concrete, falsifiable next steps.

## 1. The barcode distance theorem (homological code distance)

Define the code distance `d(C)` as the minimum Hamming weight (number of nonzero
basis coordinates, with respect to a fixed basis of `C₁`) over the nonzero
classes of `H₁` — equivalently the *homological systole* of the complex. The
conjecture is that for a persistent bar with birth `ε` and death `δ`, the
induced code at any threshold `t ∈ [ε, δ)` has distance at least the
combinatorial length of the cycle representing that bar, and that this length is
monotone in the persistence interval `δ − ε`.

**The key insight is** that code distance is not an extra datum but the
*minimal weight representative* of a homology class, so the longest bar of the
barcode literally is the most robust logical operator. This refines
`css_parameters` from counting `k` to bounding `d`, completing the `[[n, k, d]]`
triple from purely topological data. **Why now?** `BarcodeCode.lean` already
gives `H₁` as a concrete `Submodule`-quotient over a field, so the minimum-weight
functional is definable today with Mathlib's `Finset`/`Finsupp` support;
distance was the one missing leg of the `[[n,k,d]]` tripod and the homology
object is now in hand.

## 2. The toric-code instance: barcode code of the 2-torus

Construct the cellular chain complex of the `L × W` square lattice on the torus
explicitly (cells indexed by `Fin L × Fin W`) and prove that the barcode code it
produces has exactly `k = 2` logical qubits and `n = 2·L·W` physical qubits,
matching Kitaev's toric code, with `persistentBetti = 2` across the whole
filtration.

**The key insight is** that the surface code is *not analogous to* `H₁` of a grid
— it *is* `H₁` of a grid, so verifying `logicalQubits = 2` for the explicit torus
complex is a direct corollary of `css_parameters` once the boundary maps are
written down. **Why now?** The abstract accounting theorem
`css_parameters` is already proven, so the toric code reduces to a finite
rank computation `rank d₂ = L·W − 1`, `rank d₁ = L·W − 1`, which Mathlib's
matrix-rank machinery can discharge; no new theory is required, only the explicit
complex.

## 3. Interleaving stability of the code family

Persistence modules enjoy the celebrated *stability theorem*: a small change in
the input data produces a small change in the barcode (bottleneck distance is
1-Lipschitz). Conjecture a coding analogue: if two filtrations are
`q`-interleaved, then their logical-qubit counts differ by a controlled amount
and there is a rank-preserving correspondence between long bars, hence between
robust logical operators.

**The key insight is** that an interleaving is a pair of chain maps whose
composites are the structure maps of the filtration, so `inducedHom` composes
functorially and rank is sandwiched — exactly the `persistentBetti_le_birth/death`
bound applied in both directions. **Why now?** We have already built `inducedHom`
and proven the two-sided rank bound; interleaving stability is the natural
two-map generalization and would make "noisy data still yields a good code" a
theorem rather than a heuristic.

## 4. Higher homology = higher-dimensional codes

Replace the length-3 complex by an unbounded one `… → C_{n+1} → C_n → C_{n-1} → …`
and define the degree-`n` barcode code from `H_n`. Prove the analogue of
`css_parameters` at every degree and that the Euler characteristic
`Σ (−1)^i dim C_i = Σ (−1)^i k_i` relates the per-degree logical counts.

**The key insight is** that the CSS construction only ever uses two consecutive
boundary maps, so degree-`n` homology gives a code on the `n`-cells with the
*same* commutation proof shifted in degree, and the alternating sum of logical
counts is a topological invariant. **Why now?** All three of our core lemmas
(`range_le_ker`, `logical_add_xchecks`, `css_parameters`) are stated for abstract
linear maps with no reference to degree, so they transport verbatim; Mathlib's
`HomologicalComplex` then supplies the Euler-characteristic bookkeeping.

## 5. Persistent rate and the asymptotic good-code question

Define the *persistent rate* of a filtered family as
`liminf_t persistentBetti(t) / n(t)` and study families of complexes (e.g. from
expander-based or Ramanujan-complex filtrations) for which this stays bounded
below as `n → ∞`. Conjecture that a positive persistent rate together with a
linear barcode-distance bound (Direction 1) yields a family of asymptotically
good quantum LDPC codes whose logical operators are *stable* features of the
data.

**The key insight is** that "asymptotically good" is exactly "long bars whose
count grows linearly in `n` and whose minimal-weight representatives grow
linearly too" — a purely persistence-theoretic statement once Directions 1–2 are
in place. **Why now?** The recent resolution of the good qLDPC conjecture used
chain complexes from high-dimensional expanders; phrasing those constructions as
*filtered* complexes and tracking `persistentBetti` connects that breakthrough to
TDA, and the rank-bound infrastructure to make the connection precise already
exists in `BarcodeCode.lean`.
