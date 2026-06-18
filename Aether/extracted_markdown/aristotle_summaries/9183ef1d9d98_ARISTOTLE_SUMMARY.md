# Summary of changes for run 2069e296-37b0-4a34-b294-59a947d209c9
## BabelCode: Error-Correcting Codes in the Library of Babel

Created `Shared/BabelCode.lean` — a self-contained Lean 4 formalization establishing the BabelCode as a novel mathematical structure connecting Borges' Library of Babel to coding theory. The file compiles with zero `sorry` statements and uses only standard axioms (propext, Classical.choice, Quot.sound).

### Definitions (4)
- **`Volume A L`** — Words of length `L` over alphabet `Fin A` (the Library)
- **`IsBabelCode C d`** — Minimum pairwise Hamming distance ≥ d
- **`hammingNeighbors v`** — Words at Hamming distance exactly 1
- **`hammingBall v r`** — Words within Hamming distance r

### Proved Theorems (16 total, all sorry-free, with PEGB structure)

**Singleton Bound** (4 items):
- `agree_prefix_implies_close` — Key lemma: prefix agreement implies closeness
- `singleton_bound` — |C| ≤ A^(L−d+1) via projection injectivity argument
- `singleton_bound_generalized` — Extension to non-uniform alphabets (Π-types with per-coordinate bounds)
- `singleton_bound_trivial_at_d_one` — Boundary: d=1 gives the trivial bound |C| ≤ A^L

**Plotkin Bound** (4 items):
- `column_disagreement_bound` — Per-coordinate contribution bound via Cauchy-Schwarz inequality
- `plotkin_bound` — |C|·(dA − L(A−1)) ≤ dA when dA > L(A−1), via double-counting
- `plotkin_bound_equality` — Equality characterization: tight iff code is equidistant
- `plotkin_threshold_binary` — Boundary: bound is vacuous when d ≤ L/2

**Babel-Lawvere Impossibility** (3 items):
- `babel_lawvere` — No surjection Volume → (Volume → Fin A) when A ≥ 2 (diagonal argument)
- `lawvere_finite` — Generalization to arbitrary finite types with |Y| ≥ 2
- `lawvere_fails_A_one` — Boundary: fails for |A| = 1 (trivial alphabet)

**Hamming Graph Structure** (5 items):
- `hamming_degree` — Each vertex has exactly L·(A−1) neighbors
- `hamming_vertex_transitive` — All vertices have equal degree
- `hamming_degree_A_one` — Boundary: degree 0 when A = 1
- `hamming_ball_card_eq` — Ball size is center-independent
- `hamming_bound_via_packing` — Sphere-packing bound: |C|·|Ball(t)| ≤ A^L

### Concrete Examples (3)
- Binary [5,_,3] code: |C| ≤ 8 (Singleton)
- Binary [6,_,4] code: |C| ≤ 4 (Plotkin)
- Binary cube {0,1}³: degree = 3 (Hamming degree)

### Future Directions (in trailing comment)
1. Harper's vertex isoperimetric inequality for the Hamming graph
2. Spectral gap of H(L,A) via Krawtchouk polynomials
3. Plotkin equality ↔ equidistant codes (characterization beyond what's proved)
4. Gilbert-Varshamov existence bound
5. BabelCode lattice structure under inclusion