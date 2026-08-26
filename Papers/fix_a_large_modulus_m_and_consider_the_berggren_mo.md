# Computational Evidence — Berggren moves on `(ℤ/m)³`

All numbers below were produced with `#eval` inside the project's Lean environment
(kernel-evaluated `ℤ`/`ℕ` arithmetic on the definitions of
`Catalog/Cryptography/BerggrenModular/`), not by an external script.  They guided
the theorem statements that were subsequently proved; the *proved* facts are the
Lean theorems, and the tables here are evidence, including for the conjectures
recorded in `FUTURE_DIRECTIONS.md`.

## 1. The integer classifier and exact seed recovery

The classifier under test is

```
whichMove (a,b,c) = if 5a < 3c then B₁ else if 5a < 4c then B₂ else B₃.
```

Exhaustive check: for every `k ≤ 6` and every one of the `3^k` control words `u`
(1093 words in total up to length 6), `recoverFrom 6 (applyWord u root) = u`.

```
k              : 0     1     2     3     4     5     6
all words OK   : true  true  true  true  true  true  true
```

Level 1 and level 2 of the tree (leftmost entry = last move applied):

```
depth 1: (5,12,13)  (21,20,29)  (15,8,17)
depth 2: (7,24,25) (55,48,73) (45,28,53) (39,80,89) (119,120,169)
         (77,36,85) (33,56,65) (65,72,97) (35,12,37)
```

This is the classical Barning–Hall tree of primitive Pythagorean triples, and it
matches the proved theorem `whichMove_applyMove`.

## 2. The `B₂` spine is a Pell ladder

```
t        : 0        1          2            3              4
orbit2 t : (3,4,5)  (21,20,29) (119,120,169) (697,696,985) (4059,4060,5741)

pellS t = a_t+b_t : 7, 41, 239, 1393, 8119, 47321, 275807, 1607521, 9369319
pellC t = c_t     : 5, 29, 169,  985, 5741, 33461, 195025, 1136689, 6625109
pellS² − 2·pellC² : −1, −1, −1, −1, −1, −1, −1, −1, −1
```

* `pellS` is the NSW sequence **OEIS A002315** (`1, 7, 41, 239, 1393, 8119, …`).
* `pellC` is **OEIS A001653** (`1, 5, 29, 169, 985, 5741, …`), the odd-indexed
  Pell-related numbers, i.e. the `y` of the negative Pell equation `x²−2y²=−1`.
* Both satisfy `x_{t+2} = 6x_{t+1} − x_t`; the legs differ by `±1` alternately.

Proved in Lean as `pellS_recurrence`, `pellC_recurrence`, `pell_conic`,
`leg_difference`.  The structural reason is the spectral identity
`(B₂+I)(B₂²−6B₂+I) = 0` (`silver_factorization_B2`), whose quadratic factor has
roots `3 ± 2√2 = (1 ± √2)²`.

## 3. Collision hunt modulo `m`

First length `k` at which two distinct length-`k` control words already produce
the same state modulo `m`:

```
m            : 3   5   7   11  13
first k      : 1   2   2   3   3
```

Number of *distinct* modular states reachable by words of length exactly `k`,
compared with the `3^k` words:

```
m = 7 :  k        0   1   2   3   4    5    6    7
         3^k      1   3   9  27  81  243  729 2187
         #states  1   3   8  19  24   24   24   24

m = 11:  k        0   1   2   3   4    5    6    7
         3^k      1   3   9  27  81  243  729 2187
         #states  1   3   9  20  34   47   60   60
```

So the observation saturates at a fixed set long before the word length grows —
this is the information-theoretic collapse quantified by
`mod_ambiguity_lower_bound` and `not_modSeedRecoverable_of_card`.

## 4. Size of the reachable set (a *conjecture*, computationally supported)

Saturated reachable-set sizes, computed by closing the root under the three
moves modulo `m`:

```
p                : 3   5   7   11  13   17   19   23
|reachable|      : 4  12  24   60  84  144  180  264
(p²−1)/2         : 4  12  24   60  84  144  180  264      ← exact match

m                : 9   25   15   21
|reachable|      : 36  300  48   96
m²∏_{p|m}(1−p⁻²)/2: 36  300  48   96                       ← exact match
```

Conjecturally therefore `|reachable set mod m| = ½ m² ∏_{p∣m}(1 − p⁻²)`, i.e. the
Berggren monoid orbit fills **exactly half** of the punctured null cone
`{a²+b²=c²} \ {0}` modulo a prime.  This is *not* proved.  What **is** proved is
the containment half: every reachable state is a primitive null vector
(`Prim_applyWord`, `lorentzM_stateMod`, `stateMod_ne_zero`) and the cone has at
most `2p²` points (`card_nullCone_le`), which already gives the sharpened
impossibility threshold `2p² < 3^k`.

## 5. Where the absolute classifier starts to fail

Number of the `81` depth-4 words whose last move is still read correctly by the
classifier applied to the *reduced* state (`m` chosen along the `B₂` spine so
that the wrap-around threshold moves):

```
m        : 5    29   169   985   5741
correct  : 27   21   30    45    80      (out of 81)
```

The accuracy is not monotone for small `m` (below the threshold the classifier
is essentially guessing), and it reaches `80/81` exactly when `m = 5741` exceeds
the hypotenuse of all but one depth-4 state.  This matches the proved statement
`whichMoveMod_redTri` (soundness whenever the hypotenuse is `< m`) together with
the explicit failure `whichMoveMod_fails_mod_seven`.
