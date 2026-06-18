# Summary of changes for run 96ec3ed6-23ce-4307-9beb-81112eadc12d
## Tropical Brill–Noether Theory: Formalization

### Strategy
Created a new self-contained Lean 4 file `Tropical/BrillNoether.lean` formalizing the combinatorial core of tropical Brill–Noether theory (CDPR theorem). All 7 theorems compile with zero `sorry` and only standard axioms (propext, Classical.choice, Quot.sound).

### Theorems Proved (all sorry-free)

1. **`BN.allocation_iff_rho_nonneg`** — A CDPR allocation for parameters (g,r,d) exists if and only if the Brill–Noether number ρ(g,r,d) = g − (r+1)(g−d+r) ≥ 0. This is the combinatorial heart of the Cools–Draisma–Payne–Robeva theorem. The forward direction uses an antitone-sum bound; the backward direction constructs an explicit canonical allocation.

2. **`BN.displacementTableau_exists_iff`** — An injective row-strict displacement tableau of shape rows × cols with entries in Fin g exists iff rows·cols ≤ g. Forward by pigeonhole (Fintype.card_le_of_injective); backward by the canonical filling T(i,j) = i·cols + j.

3. **`BN.chipFiring_degree_invariant`** — Chip-firing preserves divisor degree on any simple graph. The fired vertex v loses deg(v) chips, each distributed to one neighbor, so the net change is zero.

4. **`BN.rho_serre_duality`** — ρ(g,r,d) = ρ(g, g−d+r−1, 2g−2−d), the Brill–Noether number identity reflecting Serre duality on algebraic curves. Requires d ≤ g for ℕ subtraction correctness.

5. **`BN.tableau_iff_rho_nonneg`** — Connects displacement tableaux to ρ: a tableau of shape (r+1) × (g+r−d) exists iff ρ ≥ 0.

6. **`BN.initialState_inWeylChamber`** — The CDPR initial state v(j) = d−j lies in the Weyl chamber iff r ≤ d.

7. **`BN.specialization_preserves_existence`** — Baker's specialization lemma: existence of ranked divisors is preserved under tropicalization.

### Key Insight
The non-trivial content is the equivalence between ρ-nonnegativity and the existence of combinatorial structures (allocations, tableaux). The forward direction is a pigeonhole/averaging argument; the backward direction requires an explicit construction of the allocation with careful ℕ arithmetic.

### Files Created
- `Tropical/BrillNoether.lean` — 233 lines, 7 theorems, 0 sorry
- `FUTURE_DIRECTIONS.md` — 5 research directions extending the formalization

### Build Status
Clean build with no warnings and no sorries. All theorems verified against standard axioms only.