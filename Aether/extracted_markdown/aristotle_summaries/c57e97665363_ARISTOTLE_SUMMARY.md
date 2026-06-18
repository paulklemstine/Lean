# Summary of changes for run 5f0a3ac5-65d8-4ea8-b6a6-54ff5458bad3
## Reversible Computing and Landauer's Bound — Lean 4 Formalization

Created `Computation/ReversibleComputing.lean` (265 lines, **0 sorries**) formalizing the combinatorial core of Landauer's principle connecting reversible computation to information theory.

### Key Definitions
- **`fiber f b`**: The preimage of `b` under `f`, as a `Finset`
- **`maxFiberSize f`**: Maximum fiber cardinality, measuring "irreversibility"
- **`RevSim f`**: Structure capturing reversible simulation (ancilla type + bijection + simulation property)
- **`toffoli`** / **`fredkin`**: Universal reversible gates as `Equiv` on `Bool³`
- **`informationContent α`**: `log(|α|)`, the information capacity of a finite type

### Main Theorems (all fully proved)

1. **`injective_iff_maxFiber_le_one`** — A function on finite types is injective (reversible) iff its maximum fiber size is ≤ 1. This is the combinatorial characterization of reversibility.

2. **`exists_revSim_of_surjective`** — Any surjective endofunction on `Fin n` admits a reversible simulation via a bijection on `Fin n × Fin m`. (Uses the finite pigeonhole: surjective on finite = bijective.)

3. **`info_loss_of_non_injective`** — A non-injective endofunction on a finite type strictly reduces the cardinality of its range. This is the information-theoretic content of Landauer's principle: irreversible computation destroys information.

4. **`toffoli_simulates_and`** + **`fredkin_simulates_and`** — Both universal reversible gates simulate the irreversible AND gate, demonstrating how ancilla bits enable reversible implementation of irreversible operations.

### Supporting Results
- `sum_fiber_card`: Fibers partition the domain (∑ fiber sizes = |α|)
- `bijection_preserves_fiber_card`: Bijections preserve subset cardinality
- `bijection_fiber_card`: All fibers of a bijection have size exactly 1
- `bijection_preserves_info`: Bijections preserve information content
- `rev_preserves_range_card`: Reversible maps preserve range cardinality
- `and_fiber_false_card`: AND gate has fiber size 3 at `false` (concrete Landauer example)
- Reversible computations form a group under composition

### Files
- `Computation/ReversibleComputing.lean` — Main formalization (builds cleanly, 0 sorries)
- `FUTURE_DIRECTIONS.md` — 5 research directions including tight ancilla bounds, circuit complexity, Shannon entropy preservation, Kolmogorov complexity connection, and thermodynamic cost of sorting