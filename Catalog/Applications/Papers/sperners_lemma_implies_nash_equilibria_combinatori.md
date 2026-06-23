# Computational Evidence — Sperner ⟹ Fixed Points ⟹ Nash

This note records the small-case checks that motivated the formal theorems in
`SpernerOneDim.lean`, `PotentialNash.lean`, and `TarskiNash.lean`.

## 1. One-dimensional Sperner parity (`sperner1D_parity`)

Color the vertices `0..n` with two colors and count *bichromatic* edges
(`c i ≠ c (i+1)`).

| coloring (c 0 .. c n)        | bichromatic edges | count mod 2 | endpoints differ? |
|------------------------------|-------------------|-------------|-------------------|
| `0 0 0`                      | 0                 | 0           | no  (0)           |
| `0 0 1`                      | 1                 | 1           | yes (1)           |
| `0 1 0`                      | 2                 | 0           | no  (0)           |
| `0 1 1`                      | 1                 | 1           | yes (1)           |
| `0 1 0 1`                    | 3                 | 1           | yes (1)           |
| `0 0 1 1 0`                  | 2                 | 0           | no  (0)           |

In every row `count mod 2` equals the endpoint-difference indicator. This is
exactly the statement `edgeCount c n % 2 = (if c 0 = c n then 0 else 1)`, and in
particular a `0 … 1` coloring always has an *odd* (hence positive) number of
bichromatic edges — the 1D "fully colored simplex".

## 2. Discrete IVT / Brouwer bracket (`discrete_ivt`, `discrete_brouwer`)

For `f 0 ≤ 0 < f n`, the first index `k` with `f k > 0` satisfies `f (k-1) ≤ 0`,
giving the upward crossing. Sample `f = [-2, -1, 1, 3]` (n = 3): crossing at i = 1
(`f 1 = -1 ≤ 0 < 1 = f 2`). ✓

For the diagonal bracket `discrete_brouwer`, take a self-map `h : {0..n} → ℤ` with
`0 ≤ h 0` and `h n < n`. Example `h = [0, 0, 1, 2]` with n = 3 (so `h 3 = 2 < 3`):
displacement `h j - j = [0, -1, -1, -1]`, the bracket `i ≤ h i ∧ h (i+1) ≤ i`
holds at i = 0 (`0 ≤ h 0 = 0` and `h 1 = 0 ≤ 0`). ✓ This is an approximate fixed
point of `h`.

## 3. Potential games (`potential_game_has_pure_nash`)

2×2 coordination game (a potential game), payoffs `(pA, pB)`:

```
            b0        b1
   a0   (2, 2)    (0, 0)
   a1   (0, 0)    (1, 1)
```

A potential is `Φ = pA = pB` here (identical-interest game). The global maximizer
of `Φ` is `(a0, b0)` with value 2, and indeed `(a0, b0)` is a pure Nash
equilibrium: A deviating to a1 gets 0 < 2, B deviating to b1 gets 0 < 2. The
theorem's "argmax of the potential is Nash" recipe selects exactly this profile.
(Note `(a1, b1)` is also a pure Nash but is *not* the potential maximizer — the
theorem only certifies the global maximizer, which is the point of the existence
claim.)

## 4. Supermodular games via Tarski (`supermod_game_has_nash`)

Smallest instance: both strategy lattices the one-point lattice `PUnit`. Best
responses are constant (hence monotone), and the unique profile is trivially a
fixed point of the joint best-response map, hence Nash. More informatively, on the
Boolean lattice `Bool` with `brA = brB = id` (each player matches the other — a
supermodular coordination game), the joint map `(a,b) ↦ (b,a)` has fixed points
`(false,false)` and `(true,true)`, both pure Nash equilibria; Tarski's theorem
returns the least one, `(false,false)`.

## OEIS

The bichromatic-edge parity table is governed by the indicator sequence and does
not match a distinctive OEIS entry on its own; the underlying "number of sign
changes" combinatorics is folklore (Sperner / discrete IVT) rather than a tabled
integer sequence, so no OEIS ID is claimed.

## Counterexample hunt

- Dropping `Nonempty A` (or `B`) in `potential_game_has_pure_nash` breaks the
  argmax existence — confirmed necessary.
- Dropping the strict `h n < n` in `discrete_brouwer` admits the boundary
  fixed-point `h n = n` with no interior bracket — confirmed the strict
  hypothesis is load-bearing.
- Dropping `Monotone brA`/`brB` in `supermod_game_has_nash` is fatal: a game whose
  joint best response is the order-reversing map on a chain with no fixed point
  (e.g. anti-coordination on a 2-chain) has no pure Nash equilibrium, matching the
  known failure of pure Nash for non-supermodular games.
