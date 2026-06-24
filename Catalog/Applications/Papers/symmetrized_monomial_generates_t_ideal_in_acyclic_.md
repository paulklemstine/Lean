# Computational Evidence — Symmetrized Monomial / Standard Identity on `𝔽Q≥1`

The mission statement concerns a finite acyclic quiver `Q` with longest path
length `n - 1` and the principal subalgebra `𝔽Q≥1` (spanned by nonempty paths).
We model `𝔽Q≥1` by its faithful avatar: the strictly upper triangular `n × n`
matrices `N_n(𝔽)` (obtained by indexing vertices via a topological order, so that
every arrow goes `i → j` with `i < j`).

## 1. Small-case calculations

**Nilpotency index (matrix model).**

| `n` | longest path length | claim about products |
|----|----|----|
| 1 | 0  | `N_1 = {0}`; empty product already `0` |
| 2 | 1  | `N_2 = {[[0,a],[0,0]]}`; any 2-fold product `= 0` |
| 3 | 2  | `N_3` strictly upper; any 3-fold product `= 0`, but 2-fold need not be |

Concrete `n = 3` witness that index is *sharp* (a 2-fold product can be nonzero):
`E_{12} · E_{23} = E_{13} ≠ 0`, yet `E_{12} · E_{23} · (anything strictly upper) = 0`.
Here `E_{ij}` is the matrix unit. This matches "longest path length `n-1 = 2`":
the path `1→2→3` has length 2, and concatenating one more arrow is impossible.

**Symmetrized monomial `S` and standard polynomial `Sₙ`.**
For `n = 2`, `a = E_{12}`, `b = E_{12}` (both strictly upper):
`S(a,b) = a·b + b·a = 0 + 0 = 0` and `S₂(a,b) = a·b − b·a = 0`.
Every individual monomial is a 2-fold product of strictly-upper matrices, hence
`0`; the sign is irrelevant. This is exactly the structural mechanism proved in
`StrictUpperNilpotent.lean`.

## 2. Contrast with the full matrix algebra (Amitsur–Levitzki)

On `M_n(𝔽)` (no triangularity), the *unsigned* symmetrized monomial does **not**
vanish: e.g. for `n = 2`, taking `a = E_{11}, b = E_{12}` gives
`a·b + b·a = E_{12} + 0 = E_{12} ≠ 0`. So the unsigned identity is genuinely a
*nilpotent* phenomenon. Amitsur–Levitzki (MR36751) says the minimal *signed*
standard identity of `M_n` has degree `2n`, whereas on `N_n` the signed (and
unsigned) identity already appears in degree `n`. The gap `2n` vs `n` quantifies
how much "more identities" the nilpotent subalgebra satisfies.

## 3. Counterexample hunt

- *Is the degree `n` optimal for `N_n`?* On `N_n`, `E_{12}E_{23}⋯E_{n-1,n} =
  E_{1,n} ≠ 0` is a nonzero product of `n-1` strictly-upper matrices, so no
  degree `< n` monomial identity holds with these arguments. Thus the degree `n`
  in the theorem is sharp. (Not formalized here; recorded as a future direction.)
- *Does dropping acyclicity break it?* Yes: a single loop `e : v → v` yields
  arbitrarily long paths `e^k`, the arrow ideal is not nilpotent, and no degree
  bound on identities survives. Acyclicity (= existence of the topological order
  `r`) is load-bearing, which is why `AcyclicBound.lean` derives the length bound
  from `r`.

## 4. Formal verification status

All claims marked "proved" are machine-checked in
`StrictUpperNilpotent.lean` and `AcyclicBound.lean`, depending only on the
standard axioms `propext`, `Classical.choice`, `Quot.sound` (verified via
`#print axioms`). The sharpness/optimality observations in §3 are evidence-level
only and are listed in `FUTURE_DIRECTIONS.md`.
