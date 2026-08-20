# Computational evidence — finite-state Shtarkov sums

All numbers below were produced with Lean `#eval` (Float / Nat arithmetic) during
exploration.  **They are numerical exploration, not machine-checked theorems.**
Every mathematical claim that this project *asserts* is proved in
`Catalog/Tropical/Shtarkov/*.lean` with no `sorry`.

## 1. The memoryless class (`k = 1`)

Grouping words of length `n` by their number of ones, the Shtarkov sum is

```
S_n(1) = ∑_{j=0}^n C(n,j) (j/n)^j ((n-j)/n)^{n-j}.
```

| n | S_n(1) | √(πn/2) | proved bound (n+1)² |
|---|--------|---------|---------------------|
| 1 | 2.0000 | 1.2533  | 4    |
| 2 | 2.5000 | 1.7725  | 9    |
| 4 | 3.2188 | 2.5066  | 25   |
| 6 | 3.7747 | 3.0700  | 49   |
| 8 | 4.2450 | 3.5449  | 81   |
| 10| 4.6602 | 3.9633  | 121  |
| 12| 5.0361 | 4.3416  | 169  |

The data match the classical asymptotic `S_n(1) ~ √(πn/2) + 2/3`, i.e. regret
`≈ ½ log n`.  Our proved bound `S_n ≤ ((n+1)²)^k` is therefore correct but not
constant-sharp — exactly what Conjecture C1 of `FUTURE_DIRECTIONS.md` addresses.

The cleared-denominator sequence `n^n · S_n(1) = ∑_j C(n,j) j^j (n-j)^{n-j}` is
integral:

```
n = 0..10 :  1, 2, 10, 78, 824, 10970, 176112, 3309110, 71219584, 1727242866, 46602156800
```

(no OEIS lookup was performed in this sandbox, so no identifier is claimed).

## 2. The order-1 Markov class (`k = 2`, state = previous symbol)

Brute force over all `2^n` words, taking for each word the maximum-likelihood
product over the two states:

| n | S_n(2) |
|---|--------|
| 1 | 2.0000 |
| 2 | 3.2500 |
| 4 | 5.0175 |
| 6 | 6.6087 |
| 8 | 8.1185 |
| 10| 9.5795 |
| 12| 11.0070 |

Growth is close to linear in `n`, i.e. regret `≈ log n = (k/2) log n` with
`k = 2`.  Again consistent with (and far below) the proved bound `(n+1)^4`.

## 3. Saturation

For the counter machine (`k = n+1` states) every word is memorised exactly, so
`S_n = 2^n`; this is *proved* in `PhaseTransition.lean`
(`shtarkovSum_counter_eq`), not merely observed.  The contrast with §1–§2
(`S_n` polynomial for fixed `k`) is the phase transition studied in that file.

## 4. Counterexample hunt

* Is the maximum-likelihood plug-in always dominant?  Tested implicitly by §1–§2:
  the brute-force evaluation uses the plug-in and never exceeds `2^n`; the
  general statement is proved (`prob_le_prob_ml`).
* Is `S_n` monotone in the number of states?  No counterexample found; the
  simulation-monotone version is proved (`shtarkovSum_le_of_simulates`).
* Can a `1`-state machine memorise all words of length `6`?  Numerically
  `S_6(1) = 3.77 < 64`, so no; proved in `memoryless_not_memorisable`.

## 5. Lab notes: what survived, what failed, and why

**Cycle 1 (counting).**  Hypothesis: the maximum-likelihood envelope of a
finite-state class factors through per-state counts, so the Shtarkov sum is
bounded by the number of count vectors.  *Survived*, as
`shtarkovSum_fsmClass_le`.  The only analytic input needed was
`bernoulli_ml_le`, proved by `log x ≤ x - 1`; an attempt to prove it by
`positivity`-style automation failed because `positivity` cannot use
hypotheses such as `0 < θ`, and the degenerate cases `a = 0`, `b = 0`,
`θ ∈ {0,1}` had to be split off by hand (`0^0 = 1` makes the endpoints true but
not uniform).

**Cycle 1b (saturation).**  Hypothesis: memorising an arbitrary word needs
`2^n` states (a full prefix tree).  *Failed — the guess was wrong, and the truth
is better*: the state needs only to record the **time index**, so `n+1` states
suffice, which is what `counterFSM` implements.  This is why the phase
transition sits at `k ≈ n`, not at `k ≈ 2^n`, and it is the single most
informative failure of the run.

**Cycle 2 (entropy).**  Hypothesis: the tropical envelope is *exactly*
`exp(-Ĥ(x))`.  *Survived*, as `shtarkovSum_eq_sum_exp_neg_empEntropy`; the
non-obvious point is that every maximum-likelihood factor is strictly positive
even in the degenerate cases (`mlFactor_pos`), which is what makes
`Real.log_prod` applicable with no side conditions left over.

**Cycle 3 (structure).**  Tensorisation over *arbitrary* classes was
**abandoned as stated**: for classes whose supremum is not attained, the
identity `sup (P·Q) = sup P · sup Q` needs an approximation argument that adds
nothing here.  The guarded version `shtarkovSum_prodClass`, hypothesising an
attaining selector (which the finite-state class has, by `prob_le_prob_ml`), is
what is proved — an instance of "needs a different definition" rather than
"false".

**Cycle 4 (sharpening).**  The general bound charges `(n+1)^2` per state; for
`k = 1` the identity `a + b = n` removes one power (`shtarkovSum_memoryless_le`).
The same trick for general `k` only removes *one* power in total (the single
linear constraint `∑_s (a_s+b_s) = n`), which is why the sharp `n^{k/2}` law is
posted as Conjecture C1 rather than attempted: it needs fibre *mass*, not fibre
*count*.
