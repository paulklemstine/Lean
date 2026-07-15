# Computational Evidence: Recurrence and Parity of Causal Loops

Concise numerical evidence for the two central claims of this cycle before the
general proofs.

## 1. Discrete recurrence / universal period

For an invertible loop `f` on a finite phase space, iterating `f` must eventually
return every state, with a single common period `N`.

Examples (loop map given as a permutation in one-line notation on `{0,…,n-1}`):

| loop map | orbit lengths | universal period N |
|----------|---------------|--------------------|
| `not` on `{alive, dead}` (grandfather) | `[2]` | 2 |
| `[1,2,0]` (3-cycle) | `[3]` | 3 |
| `[1,0,3,2]` (double transposition) | `[2,2]` | 2 |
| `[1,2,0,4,3]` | `[3,2]` | 6 |
| `[1,2,3,0,5,4]` | `[4,2]` | 4 |

In every case `N = lcm(orbit lengths)` and `f^[N] = id`, so `f^[N]` fixes every
state. This matched the proved statement `loop_universally_consistent` and
motivated proving it via the order of the induced permutation.

The grandfather loop is the sharp boundary witness: fixed-point-free in one
traversal, yet `not^[2] = id`, so two traversals are universally self-consistent
(`grandfather_recurrent`).

## 2. Parity law for involutions

For an involution `f` on a finite phase space, `#{fixed points} ≡ |S| (mod 2)`.

| involution | |S| | fixed points | #fix | #fix mod 2 | |S| mod 2 |
|------------|-----|--------------|------|-----------|-----------|
| `id` on 4 elts | 4 | all | 4 | 0 | 0 |
| `[1,0,2,3]` | 4 | `{2,3}` | 2 | 0 | 0 |
| `[1,0,3,2]` | 4 | none | 0 | 0 | 0 |
| `id` on 5 elts | 5 | all | 5 | 1 | 1 |
| `[1,0,2,3,4]` | 5 | `{2,3,4}` | 3 | 1 | 1 |
| `[1,0,3,2,4]` | 5 | `{4}` | 1 | 1 | 1 |

Parities always agree, and every odd-size involution has at least one fixed
point, confirming the corollary `involutive_odd_selfConsistent`. Non-fixed points
always come in pairs (transpositions), which is exactly the support-evenness fact
used in the proof.

## Counterexample hunt (boundaries)

* **Recurrence needs invertibility.** The constant loop `f x = 0` on `{0,1}` is
  not injective; no positive iterate equals the identity, so recurrence fails.
* **Recurrence needs finiteness.** Translation `n ↦ n+1` on the integers is
  invertible but no state ever returns.
* **Parity needs the involution hypothesis.** The 3-cycle `[1,2,0]` on 3 elements
  has `0` fixed points, while `|S| = 3` is odd — parities disagree — so the parity
  law is genuinely special to self-inverse loops.
