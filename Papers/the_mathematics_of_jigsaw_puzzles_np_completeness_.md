# Computational Evidence: Jigsaw Assembly ⇔ Satisfiability

Concise numerical support for the claims formalized in `JigsawNPComplete.lean`.

## 1. Edge complementation table

Complementation `comp` on `{flat, tab, blank}`:

| e     | comp e | comp (comp e) | self-complementary? |
|-------|--------|---------------|---------------------|
| flat  | flat   | flat          | yes                 |
| tab   | blank  | tab           | no                  |
| blank | tab    | blank         | no                  |

Observations (all verified in the formal file):
- `comp (comp e) = e` for every `e` — complementation is an involution.
- The only self-complementary edge is `flat`, matching
  `comp_fixed_iff_flat`: the border is the fixed-point set of the symmetry.

## 2. The literal dictionary on all cases

For a literal `(i, pol)` under assignment value `v = a i`, the input edge
`(enc pol).comp` interlocks with the output edge `enc v` iff `v = pol`:

| v (a i) | pol | enc v | (enc pol).comp | interlock? | literal satisfied? |
|---------|-----|-------|----------------|------------|--------------------|
| true    | true  | tab   | blank | yes | yes |
| true    | false | tab   | tab   | no  | no  |
| false   | true  | blank | blank | no  | no  |
| false   | false | blank | tab   | yes | yes |

The "interlock?" and "literal satisfied?" columns coincide — this is the content
of `litFits_iff`.

## 3. Piece count of the construction

For `n` variables and `m` clauses the construction emits `2n + m + 2` pieces
(two corners, two per variable, one per clause):

| n | m | 2n + m + 2 |
|---|---|------------|
| 0 | 0 | 2  |
| 1 | 1 | 5  |
| 3 | 2 | 10 |
| 5 | 7 | 19 |

The row `n = 3, m = 2` is the running example; `exampleF_pieceCount` confirms the
value `10`.

## 4. Running example `(x₁ ∨ x₂ ∨ ¬x₃) ∧ (¬x₁ ∨ x₃)`

Enumerating all eight assignments of `(x₁, x₂, x₃)`:

| x₁ | x₂ | x₃ | clause 1 | clause 2 | formula |
|----|----|----|----------|----------|---------|
| F  | F  | F  | T (¬x₃)  | T (¬x₁)  | **SAT** |
| F  | F  | T  | F        | T (¬x₁)  | unsat   |
| F  | T  | F  | T        | T        | **SAT** |
| F  | T  | T  | T (x₂)   | T        | **SAT** |
| T  | F  | F  | T        | F        | unsat   |
| T  | F  | T  | F        | T (x₃)   | unsat   |
| T  | T  | F  | T        | F        | unsat   |
| T  | T  | T  | T        | T        | **SAT** |

Four satisfying assignments exist; the witness `x₁ = F, x₂ = T, x₃ = F` is the one
used in `exampleF_solvable`. Since a satisfying assignment exists, the puzzle is
solvable — consistent with the equivalence theorem.

## 5. Counterexample hunt (unsolvable instances)

The universal claim under test is `PuzzleSolvable F ↔ F.Satisfiable`. We looked
for an unsatisfiable formula whose puzzle is nonetheless solvable:

- `x₁ ∧ ¬x₁`: both assignments of `x₁` leave one clause piece unplaceable →
  unsolvable, as proved in `unsatF_not_solvable`. No counterexample.
- `(x₁ ∨ x₂) ∧ (¬x₁ ∨ x₂) ∧ (x₁ ∨ ¬x₂) ∧ (¬x₁ ∨ ¬x₂)`: unsatisfiable; every
  assignment leaves some clause piece unplaceable. No counterexample.

No counterexample to the equivalence was found, in agreement with the formal
proof that none can exist.
