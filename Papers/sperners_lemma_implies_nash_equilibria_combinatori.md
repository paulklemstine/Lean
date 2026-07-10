# Computational evidence

This project formalizes the combinatorial-fixed-point / game-theory story in two
self-contained Lean files.  The claims are elementary enough that the "evidence"
is itself checked by the Lean kernel (all theorems compile with no `sorry` and only
the standard axioms `propext`, `Classical.choice`, `Quot.sound`).  The small-case
computations that motivated the formal statements are recorded below.

## 1. One-dimensional Sperner lemma (parity)

For a colouring `c : ℕ → Bool`, `fullyColoured c n` counts edges `(i,i+1)`, `i < n`,
whose endpoints differ.  The parity theorem says its cardinality is odd iff
`c 0 ≠ c n`.  Small cases (`•` = false, `|` = true):

| path (n=4)      | fully coloured edges | count | c0 ≠ c4 | parity |
|-----------------|----------------------|-------|---------|--------|
| `• • • • •`     | none                 | 0     | no      | even ✓ |
| `• • | | |`     | {(1,2)}              | 1     | yes     | odd  ✓ |
| `• | • | •`     | {(0,1),(1,2),(2,3),(3,4)} | 4 | no    | even ✓ |
| `• | | • |`     | {(0,1),(2,3),(3,4)}  | 3     | yes     | odd  ✓ |

Every Sperner colouring (`c 0 = false`, `c n = true`) therefore has an odd, hence
positive, number of fully labelled edges — the 1-D case of Sperner's lemma.

## 2. Discrete Brouwer fixed point

For `g : {0,…,n} → {0,…,n}` the theorem produces `i < n` with `g i ≥ i` and
`g (i+1) ≤ i+1` (an approximate fixed point straddling an edge).  Example
`n = 3`, `g = [2,3,1,3]`:

* `i=0`: `g 0 = 2 ≥ 0` but `g 1 = 3 ≤ 1`? no.
* `i=1`: `g 1 = 3 ≥ 1` and `g 2 = 1 ≤ 2`? yes.  ✔  (edge `(1,2)` is a fixed edge)

This is precisely the discretization used in Scarf/Sperner style algorithms.

## 3. Matching Pennies

Payoffs (row = player 1, `+1` on a match).  Best-response cycling shows there is
**no pure equilibrium**:

```
        H       T
  H   (+1,-1) (-1,+1)
  T   (-1,+1) (+1,-1)
```

Against the uniform column `(1/2,1/2)` every row of player 1 yields expected payoff
`1/2·(+1) + 1/2·(-1) = 0`; symmetrically for player 2.  Hence the uniform profile is
a Nash equilibrium (all deviations tie), which the file proves formally.

## 4. Prisoner's Dilemma

Payoffs (`false` = Cooperate, `true` = Defect), classic `(3,3),(0,5),(5,0),(1,1)`:

```
          C       D
  C     (3,3)   (0,5)
  D     (5,0)   (1,1)
```

Against `D`, player 1 gets `1` from `D` versus `0` from `C`; symmetric for player 2.
So `(D,D)` is the unique pure Nash equilibrium — proved via the pure-deviation
principle `isNash_of_pure`.

## Counterexample hunt

No counterexamples were sought against the *statements* (they are theorems, verified
by Lean).  The design phase did rule out two tempting but false formulations:

* The sign-change / discrete-IVT statements are **false at `n = 0`** (there is no
  edge to straddle), so the theorems carry the hypothesis `0 < n`.
* A naive "`c 0 ≠ c n` ⇒ *odd*" phrased over `ℕ`-truncated subtraction fails; the
  parity is stated with `% 2` over `Finset.card` to avoid this.
