# Future Directions: Barcode Homology Codes

This cycle established a rigorous linear-algebraic backbone for the slogan
*"the bars of a degree-1 persistence barcode ARE the logical qubits of a CSS
code"*, in `Catalog/Physics/BarcodeHomologyCode.lean`. We model a CSS code as a
length-three chain complex `V₂ →(∂₂) V₁ →(∂₁) V₀` over a field and prove, at the
honest level of `Module.finrank`:

* `boundaries_le_cycles` — `im ∂₂ ⊆ ker ∂₁` (the homological avatar of CSS
  stabilizer commutation, generalising the matrix statement
  `stabilizer_commutation_from_boundary_sq` from `CechStabilizerCode.lean`);
* `finrank_homology_add_boundaries` — `dim H₁ + rank ∂₂ = dim ker ∂₁`;
* `logical_qubit_count` — the counting law `n = k + rank ∂₁ + rank ∂₂`, the
  vector-space form of the `ℕ`-arithmetic stub `logical_qubit_bound`;
* `rate_le_one`, `finrank_homology_le` — the rate `k/n ≤ 1`;
* `circle_encodes_one_qubit` (β₁ = 1) and `torus_encodes_two_qubits` (β₁ = 2,
  matching `StabilizerBounds.toric_k L = 2`).

The natural next steps all concern the one invariant we deliberately did **not**
yet capture — the *length* of the bars, i.e. the code **distance**. Each
direction below is stated so that it can be falsified by a single explicit
counterexample chain complex.

## Direction 1: A systolic distance theorem over `V₁`

Equip `V₁` with a weight function `w : V₁ → ℕ` (Hamming weight relative to a fixed
basis) and define the code distance `d` as the minimum weight of a nonzero
homology class, `d = min { w v | v ∈ cycles, v ∉ boundaries }`. Conjecture: for
the `circleCode`/`torusCode` family refined to genuine triangulations of `S¹` and
`T²`, this `d` equals the graph systole (shortest essential cycle length), so the
length-`L` torus lattice gives `d = L`, reproducing `StabilizerBounds.toric_d`.
**The key insight is** that distance is not a quotient *dimension* (which our
current theorems compute) but a quotient *metric*: it is the diameter of the
shortest representative inside a fixed coset of `boundaries C`, so it lives on the
weighted `V₁` rather than on `H₁` alone. **Why now?** We already have the exact
coset structure (`boundaries_le_cycles`, `Homology`) compiled and axiom-clean;
adding a weight and minimising over a `Finset` of representatives is a finite,
decidable layer on top, and the toric target values are already proven in the
catalog, giving an immediate falsification test.

## Direction 2: Künneth / hypergraph-product rate law

For two chain complexes `C, C'` build the homological product complex and prove
`dim H₁(C ⊗ C') = dim H₁(C)·dim H₀(C') + dim H₀(C)·dim H₁(C')`, turning the
unproven `def hgpLogical` of `PersistentHomologicalQEC2.lean` into a theorem and
recovering the toric code as `circleCode ⊗ circleCode` with `k = 2`. **The key
insight is** that the logical-qubit count is *multiplicative across a tensor
product of complexes* exactly because `finrank` of a homology is additive over
the Künneth short exact sequence, which over a field always splits — so no Tor
terms appear and the count is purely a product of Betti numbers. **Why now?**
Our `finrank_homology_add_boundaries` is precisely the rank bookkeeping the
Künneth argument needs, and Mathlib's `TensorProduct` finrank lemmas
(`Module.finrank_tensorProduct`) are available, so the product law reduces to
algebra we already control.

## Direction 3: Persistence stability ⇒ code-parameter stability

Give `H₁` a filtration (a monotone family of subcomplexes) and prove that the
interleaving distance between two filtrations bounds the change in `(n, k, d)`:
a small perturbation of the data moves the code parameters by a controlled
amount. **The key insight is** that the barcode bottleneck/interleaving distance
is a Lipschitz functional of the input, so the *number of long bars* — and hence
`k` at a fixed scale — is robust to noise, which is exactly the fault-tolerance
property one wants from a quantum code. **Why now?** `PersistentHomologicalQEC2`
already defines `PersistenceBarcode`, `totalPersistence`, and interleaving-style
monotonicity lemmas; pairing them with our exact `dim H₁` count converts a
qualitative "barcodes are stable" slogan into a quantitative `(n,k,d)` bound.

## Direction 4: A barcode CSS code is LDPC iff the complex is sparse

Define the check weight of `∂₁, ∂₂` (max nonzeros per row/column in a fixed basis)
and prove that the resulting CSS code is low-density parity-check (bounded check
weight) exactly when the underlying simplicial complex has bounded vertex degree.
**The key insight is** that the *sparsity* of a quantum code — the property that
makes syndrome extraction local and physically realizable — is a combinatorial
invariant of the complex's incidence structure, completely decoupled from the
*homology* that fixes `k`; so one can independently tune rate (via `H₁`) and
locality (via degree). **Why now?** Our abstract `ChainCode` makes the boundary
maps first-class objects, so "bounded row weight of `∂`" is a clean predicate to
state and the bounded-degree simplicial families needed as test cases (lattices,
expander graphs) already appear in `Catalog/Algebra/ClassicalGroupExpanders.lean`.

## Direction 5: Field dependence — when does the prime `p` change `k`?

Replace the base field `ℚ` by `ZMod p` and study how `dim_{F_p} H₁` varies with
`p`. Conjecture: `dim_{F_p} H₁` is independent of `p` precisely when the integral
homology `H₁(K; ℤ)` is torsion-free, and otherwise jumps at the primes dividing
the torsion. **The key insight is** that the logical-qubit count of a homological
code is a *characteristic-sensitive* invariant: the universal-coefficient theorem
predicts extra logical qubits exactly at primes dividing the homological torsion,
so torsion in a dataset's persistent homology manifests as `p`-dependent code
capacity. **Why now?** Our theorems are already stated over an arbitrary field
`K`, so instantiating at `ZMod p` is free; the only new ingredient is a small
integral complex with prescribed torsion (e.g. the Klein bottle / `ℤ/2`), which
is a finite explicit matrix and hence an immediately checkable falsification.
