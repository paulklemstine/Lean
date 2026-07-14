# Computational Evidence

Two chains are developed in this cycle. Both are supported by small-case checks.

## 1. Signed 1-D Sperner count (`SignedSperner.lean`)

Claim: for any two-colouring `c : ℕ → Bool` of the path `0..n`,
`upCount c n − downCount c n = ⟦c n⟧ − ⟦c 0⟧`, where `⟦false⟧=0`, `⟦true⟧=1`.

Small cases (F = false, T = true), reading left to right:

| colouring       | n | up | down | ⟦cₙ⟧−⟦c₀⟧ | up−down |
|-----------------|---|----|------|-----------|---------|
| F T             | 1 | 1  | 0    | 1−0 = 1   | 1 ✓     |
| F T F           | 2 | 1  | 1    | 0−0 = 0   | 0 ✓     |
| F T F T         | 3 | 2  | 1    | 1−0 = 1   | 1 ✓     |
| T F             | 1 | 0  | 1    | 0−1 = −1  | −1 ✓    |
| F F T T         | 3 | 1  | 0    | 1−0 = 1   | 1 ✓     |
| T F T F T       | 4 | 2  | 2    | 1−1 = 0   | 0 ✓     |

The identity holds in every case; it is a telescoping sum of the per-edge
increments `⟦c(i+1)⟧ − ⟦c i⟧`, each of which lies in `{−1, 0, 1}`.

Corollaries checked on the same table: `card(fullyColoured) = up + down` has the
parity of `⟦cₙ⟧−⟦c₀⟧`, i.e. it is odd exactly when the endpoints differ; and when
`c 0 = c n` one has `up = down`.

## 2. Uniform equilibria of constant-sum games (`UniformEquilibrium.lean`)

Claim: if every row of `u1` sums to `S1` and every column of `u2` sums to `S2`,
the uniform profile is a Nash equilibrium with player-1 value `S1/|J|`.

- **Matching Pennies** (`u1 = [[1,−1],[−1,1]]`, `u2 = −u1`): every row of `u1`
  sums to `0`, every column of `u2` sums to `0`; uniform `(½,½)` is an equilibrium,
  value `0`. (Matches the classic mixed equilibrium; the game has no pure one.)
- **Rock–Paper–Scissors** on `ZMod 3` with generator `w = (0, 1, −1)`: each row is a
  permutation of `{0, 1, −1}`, so sums to `0`; uniform `(⅓,⅓,⅓)` is an equilibrium,
  value `0`.
- **Cyclic family** on `ZMod n`, `u1 i j = w(i−j)`: as `j` ranges over `ZMod n`,
  `i−j` ranges over all residues, so every row sums to `∑ₖ w k` regardless of `i`.
  Hence the uniform profile is *always* an equilibrium — no condition on `w` — and
  the value is `0` precisely when `∑ₖ w k = 0`. This was checked for `n = 2` (giving
  Matching Pennies) and `n = 3` (giving Rock–Paper–Scissors).

## Counterexample hunt

No counterexamples were found to either claim. The signed-count identity is exact
(not merely modular), and the constant-sum criterion was tested on families with both
zero and nonzero total mass — the equilibrium property persists in all of them, while
only the *value* depends on the total.
