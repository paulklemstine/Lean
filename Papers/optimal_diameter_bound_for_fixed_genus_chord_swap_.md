# Computational Evidence: Descent Potentials and Chord–Swap Diameters

## 1. Small-case calculations (bit–swap graph as a reconfiguration proxy)

The bit–swap graph on `d` coordinates is the cleanest reconfiguration graph on
which every ingredient of the descent argument is visible. Its diameter is
exactly `d` (flip all differing coordinates one at a time), while the descent
theorem certifies the upper bound `2d`.

| d | vertices `2^d` | true diameter | descent bound `2d` | radius = ecc(hub) |
|---|----------------|---------------|--------------------|-------------------|
| 1 | 2              | 1             | 2                  | 1                 |
| 2 | 4              | 2             | 4                  | 2                 |
| 3 | 8              | 3             | 6                  | 3                 |
| 4 | 16             | 4             | 8                  | 4                 |

Observation: the *radius* witnessed by the all-zero hub equals `d` exactly,
whereas the diameter equals `d` as well (the hub is centrally located). The
factor-2 gap in the general theorem is the price of routing through a hub; it is
attained only when the potential is not centered. This is precisely the
phenomenon behind the `C = 1` (radius) versus `C = 2` (diameter) split.

## 2. Chord-diagram framing

For chord diagrams of size `n` and genus `g` with `n > 2g`, the paper's bound is
`diam = O(n + g^2)`. The descent architecture predicts:

- **Radius form (conjectural sharp constant):** the canonical diagram has
  eccentricity `n + g^2`, i.e. every diagram reaches the canonical one in
  `≤ n + g^2` swaps. This is the `C = 1` conjecture, expressed as a statement
  about a single monovariant potential.
- **Diameter form (proved architecture):** routing two diagrams through the
  canonical one yields `diam ≤ 2(n + g^2)`, an explicit universal constant.

## 3. Counterexample hunt for the abstract principle

The abstract claim tested is: *"a hub `c` plus a potential `φ` that strictly
decreases along some edge out of every non-hub vertex forces diameter
`≤ 2·max φ`."*

- Removing the descent hypothesis: a graph with an isolated vertex has infinite
  diameter while admitting a bounded potential — so the monovariant hypothesis
  is load-bearing (no counterexample to the *guarded* claim; a clear
  counterexample to the *unguarded* claim).
- Non-strict descent (`φ w ≤ φ v`) admits plateaus / cycles at fixed potential
  and does not terminate — strictness is essential. No counterexample survives
  against the strict version.

No counterexample was found to the strict, hub-anchored formulation, which is the
one proved.

## 4. Why the sequence `2d` is not directly an OEIS entry of interest

The bound sequence `2, 4, 6, 8, …` (`A005843`, the even numbers) is trivial; the
content is the *inequality* between the geometric diameter and the potential
bound, not the sequence itself. The genuinely interesting sequence — the exact
fixed-genus chord-swap diameter `D(n, g)` — is the object of the sharp-constant
conjecture and is left for future computation.
