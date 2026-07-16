# Computational Evidence

## Small-case calculations

For the natural-number line with distance `Nat.dist`, take two objects with singleton supports `{0}` and `{3}` and radius `d = 2`. Their unique cross-distance is 3, so they form a far packing. This instance appears as a checked example in `Core.lean`.

For a maximal packing containing `m` objects whose supports each have at most `ℓ` vertices, direct union counting gives the following centre bounds:

| ℓ | m | bound `ℓm` |
|---:|---:|---:|
| 3 | 1 | 3 |
| 3 | 2 | 6 |
| 4 | 3 | 12 |
| 10 | 4 | 40 |

Overlaps can only reduce the actual union size, so these are worst-case bounds.

## OEIS search

No sequence search is relevant: the proved statements are structural inequalities for arbitrary finite support families, not an enumeration problem.

## Counterexample hunt

A one-sided version of insertion was tested conceptually on a two-point directed distance: let `ρ(a,b) = 2` and `ρ(b,a) = 0`, with radius `d = 1`. The singleton support `{a}` is far from `{b}` in one direction but not in the reverse direction. Thus one-sided separation does not preserve packing under insertion. The theorem accordingly assumes symmetry of `ρ`.

The empty-support boundary was also checked. An empty support cannot meet any ball; consequently, the theorem covering packed objects requires nonempty packed supports. The theorem covering only unpacked objects does not require this condition.

## Table of structural outcomes

| Candidate claim | Outcome | Boundary |
|---|---|---|
| Maximal symmetric far packing dominates unpacked supports | Established | finite object universe |
| Union of `m` supports of size at most `ℓ` has size at most `ℓm` | Established | overlaps improve the bound |
| One-sided far packing is preserved by insertion | Counterexample | restored by symmetry |
| Every packed object meets its own centre union | Established with guard | support must be nonempty |
| Full long-cycle bound `O(ℓ k log k)` | Not tested computationally | requires the paper's graph-structural anchor theory |
