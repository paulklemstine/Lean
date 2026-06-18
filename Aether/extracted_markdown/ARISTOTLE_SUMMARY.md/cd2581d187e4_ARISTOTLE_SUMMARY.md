# Summary of changes for run 8547e5d7-9075-4711-9a29-e1b1bafb61d4
## Research cycle: Fibonacci rank of apparition & the Pisano period

Building on the existing Novelty thread (`Catalog/Novelty/FibonacciEntryPointDuality.lean` and `FibCarmichaelStructure.lean`), I deepened the theory of the Fibonacci rank of apparition `z(p) = fibEntry p` and connected it to the Pisano period. All new results are axiom-clean (only `propext`, `Classical.choice`, `Quot.sound`) and the file compiles with **0 sorries**.

### Deliverable 1 — Lean 4 proofs: `Catalog/Novelty/FibEntryPisano.lean`
Validated each claim computationally (moduli ≤ 60) before formalizing, then fully proved:
- **`fibEntry_lcm`** — the *unconditional* join law `z(lcm m n) = lcm(z m, z n)` for all `m,n`. This strictly generalizes the catalog's `fibEntry_coprime_mul` (the coprime restriction was an artifact of the old proof, not the truth).
- **`fibEntry_dvd_of_dvd`** — monotonicity `m ∣ n → z m ∣ z n`. Together with the inherited meet law (`fib_dvd_gcd_iff`), this shows `z` is a full lattice homomorphism of `(ℕ, ∣)`.
- **Pisano period** `fibPeriod p` constructed from the Fibonacci-shift dynamics on `ZMod p × ZMod p`: existence/positivity (`exists_pos_fibPair_eq`, `fibPeriod_pos`, `fibPair_fibPeriod`), `fib_dvd_fibPeriod`, and the bridge **`fibEntry_dvd_fibPeriod`** (`z(p) ∣ π(p)`).
- **`fibPeriod_dvd_iff`** — return-time duality: the orbit returns to its start at index `k` iff `π(p) ∣ k`, i.e. the return times form exactly the principal ideal `(π p)`.

### Deliverable 2 — Lab notes
Inline `-- !-- Lab Notebook -- !--` blocks in the file record the hypotheses, the computational experiments, the key insight (the duality `p ∣ F n ↔ z(p) ∣ n` makes every divisibility-set identity descend to an identity of generators), and the failure analysis (finiteness/`NeZero p` needed for period existence).

### Deliverable 3 — `Catalog/Novelty/FUTURE_DIRECTIONS.md`
Five bold, falsifiable, Lean-ready conjectures: (C1) the Pisano period is itself a lattice morphism; (C2) the cofactor `π(p)/z(p) ∈ {1,2,4}`; (C3) Wall's conjecture `z(p²) ≠ z(p)`; (C4) closing the standing Carmichael composite-tail `sorry` in `Catalog/Shared/CarmichaelProof.lean`; (C5) extending the lattice-morphism results to general Lucas sequences.

### Infrastructure note
The build configuration's `lean_lib` globs did not cover the `Catalog.*` modules, so they were not buildable by name. I added a `Catalog` library (glob `Catalog.+`) to `lakefile.toml`; this is additive and non-conflicting, and lets `Catalog.Novelty.FibEntryPisano` (and the rest of the catalog) be built and verified directly.