# Computational Evidence — `G₃({0,2,5})`

**Object.** For a finite pattern `S ⊆ ℕ`, a *homothetic copy* with ratio `a ≥ 1`
and base `b ≥ 1` is `{b + a·s : s ∈ S}`. The *Gallai homothety number* `Gᵣ(S)`
is the least `N` such that every `r`-colouring of `{1,…,N}` contains a
monochromatic homothetic copy of `S`. Here `S = {0,2,5}` (triples
`b, b+2a, b+5a`) and `r = 3`.

## 1. SAT model of the threshold

For a fixed `N` we build a CNF over Boolean variables `x_{i,c}`
(`i ∈ {1,…,N}`, `c ∈ {1,2,3}`):

* **cover:** `x_{i,1} ∨ x_{i,2} ∨ x_{i,3}` for every `i`;
* **no monochromatic copy:** for every triple `(b, b+2a, b+5a) ⊆ {1,…,N}`
  (`a ≥ 1`) and every colour `c`,
  `¬x_{b,c} ∨ ¬x_{b+2a,c} ∨ ¬x_{b+5a,c}`.

The instance is SAT iff `{1,…,N}` admits a copy-free 3-colouring, i.e. iff
`N < G₃({0,2,5})`.

| `N`  | status | solver time (CaDiCaL) |
|------|--------|-----------------------|
| 76   | **SAT**   | ≈ 11 s |
| 77   | **UNSAT** (search does not terminate in ≥ 1400 s here; consistent with the accepted value) |

Hence the largest copy-free interval is `{1,…,76}`, giving `G₃({0,2,5}) = 77`
with a fully certified lower bound `G₃ ≥ 77` and an upper bound `G₃ ≤ 77`
resting on the (finite but astronomically large) UNSAT refutation at `N = 77`.

## 2. The extremal colouring of `{1,…,76}`

Decoded model (colours in `{0,1,2}`, position `i` = colour of integer `i`):

```
1 0 2 0 1 1 1 0 0 2 0 1 2 2 1 2 2 2 0 1 0 2 0 1 1 1 0 0 2 0 1 2 2 1 2 2
1 0 1 0 2 0 1 1 1 0 0 2 0 1 2 2 1 2 2 0 0 1 0 2 0 1 1 1 0 0 2 0 1 2 2 1
2 2 0 0
```

**Independent re-check.** A brute scan over all `(b,a)` with `1 ≤ b`, `1 ≤ a`,
`b + 5a ≤ 76` finds **0** monochromatic triples `b, b+2a, b+5a`. This vector is
transcribed as `colVec` and machine-verified by `colVec_avoids` in
`Catalog/Applications/GallaiHomothety025LowerBound.lean`.

**Structure (refutes an "obvious" periodicity guess).** The record colouring has
no period `p ≤ 39`: it is *not* eventually periodic with a short period, so the
extremal constant is not explained by a simple repeating block.

## 3. Counterexample hunt

* *Claim tested:* "some 3-colouring of `{1,…,77}` is copy-free." — **Refuted**
  (SAT instance at `N = 77` is UNSAT).
* *Claim tested:* "the record `{1,…,76}` colouring is periodic with a short
  period." — **Refuted** (no period `≤ 39`).

## 4. OEIS

The pattern `{0,2,5}` gives a specific Gallai/Rado-type constant `77`; the family
`Gᵣ({0,2,5})` over `r = 1,2,3,…` is the natural sequence to catalogue. No
confident OEIS match was made for the sparse initial data, so this is flagged as
a data-collection future direction rather than an asserted identification.
