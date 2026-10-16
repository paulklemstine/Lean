# RESULT — the generalised "known recurrence" attack: OPEN, and my prediction was wrong

Round 117, `factor-scratch/r117/recurrence-law/`.
**Status: INCOMPLETE / OPEN, with a definite negative finding about the naive prediction.**
This is recorded as an open direction, not a result, and the reason is stated precisely.

## 1. What was being tested

The campaign's one positive result is that nonces obeying `k_{i+1} = a·k_i + b (mod 2^m)`
with `a` **known** are broken: the key falls from 4–6 signatures with **zero** nonce
leakage (verified, round 115). The mechanism is that the second difference
`k_{i+2} − k_{i+1} = a(k_{i+1} − k_i)` is a *homogeneous linear relation with known
coefficients*.

Natural generalisation, and the claim tested here: **any** nonce generator whose states obey
a known homogeneous recurrence

```
k_{i+j} = Σ_l c_l · k_{i+l}   (mod M),      c_l and M known
```

is broken, and the number of signatures needed is `t* = j + O(1)`, because the system has
`(t−1)` signature relations and `(t−j)` recurrence relations in `t` unknown nonces, which is
over-determined exactly when `t ≥ j+1`. The LCG is the case `j = 2`, where the measured
`t*` was 4 — consistent.

## 2. What was measured (and the failure)

A self-standing implementation (`law.sage`) builds the integer system with slack
variables, extracts the kernel by `right_kernel()`, reduces with LLL, and harvests the
short solution. It returns **0/8 at every `(j, t)`**, including `j = 1, t = 2`, where the
system is 3 equations in 3 unknowns and ought to be trivially solvable.

Three bugs were found and fixed along the way (difference rows that do not eliminate `d`;
coefficients reduced mod `M` inside an integer system, which deletes the slack; and a
`(-M) % M = 0` slack coefficient). After all three the answer is still 0/8, so the
remaining problem is structural, not a coding slip:

**The naive counting prediction is wrong.** The kernel of the stacked integer system has
rank `t+1`, not 1: unknowns are `t` nonces + `d` + `t` signature slacks + `(t−j)` recurrence
slacks = `3t+1−j`, against `2t−j` equations. Bounding the box `{k_i < M, |u_i| ≲ n+M,
d < n, |v_i| ≲ M}` and dividing by `det = n^t·M^{t−j}` gives approximately
`M^t·(n+M)^t / n^{t−1}` lattice points, which is `≫ 1` for every `M, n, t`. So the
over-determination count that produced `t ≥ j+1` counted equations, not *independent
information*: the slack variables are unknowns too, and they are large.

The verified LCG construction must therefore be cutting the slack variables down in a way
my formulation does not, and its script's own comment states a different bound —
`t·(ℓ + m) ≥ 3m` — which I have not re-derived. **The correct counting bound for a general
order-`j` recurrence is the missing piece, and it is not the equation count.**

## 3. What this does and does not threaten

- **Nothing in the campaign is affected.** The verified positive (I2, known multiplier)
  stands on the worker's own construction and was re-run; this file does not weaken it.
- **The generalisation is open and now correctly scoped.** The obstacle is a specific one:
  find the right counting bound for a general order-`j` linear recurrence, of the shape
  `t·(ℓ + something(M, j)) ≥ c·M`, and then verify the attack achieves it. The `j = 2`
  LCg case suggests the bound grows with `j`.

## 4. Reproduce

```
cd /home/raver1975/lean/factor-scratch/r117/recurrence-law
/home/raver1975/sage_mamba/envs/sage/bin/sage law.sage     # 0/8 grid, see above
```

## 5. Lessons (the third one is the one worth keeping)

1. **A kernel-lattice claim needs its counting bound re-derived, not guessed.** The
   equation count ignored the slack variables; the slack variables are where the difficulty
   lives. (The same lesson as the round-117 HNP mechanism, where the *invalid* solutions —
   out-of-box points — were the obstruction rather than the count of in-box ones.)
2. **`(-M) % M = 0` silently deletes a slack coefficient**, and reducing coefficients mod
   `M` inside an integer lattice construction destroys the structure. Both were silent.
3. **Do not generalise a verified attack by re-deriving its construction.** The right move
   was to take the worker's verified LCG construction — which contains a correct counting
   argument — and vary the recurrence *inside* it. That is the recommended next step, and
   it is what I did not do.
