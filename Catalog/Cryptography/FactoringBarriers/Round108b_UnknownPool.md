# Round 108b — the unknown-pool door is OPEN: batch GCD alone, no pool knowledge

**2026-10-04. A real algorithmic result, and a bug caught by the data.** Round 108
opened the many-instance models and named the open problem: batching
*independent* semiprimes from an **unknown** small prime pool. This round resolves
it — **batch GCD alone factors the entire batch with no pool knowledge, at `O(B)`
per instance**, provably below `L[1/3]`.**

Empirical companion: `Experiments/UMWWindow/unknown_pool_batch.py` (deterministic,
`out_unknown.txt`).

---

## 1. The open problem (from round 108)

> Can a batch of `t` semiprimes `N_i = p·q`, primes from an **unknown** pool of
> `2r` primes, be factored fast — without being told the pool?

Round 108 verified the *known-pool* case (O(B)/instance via factoring-into-coprimes)
but flagged the unknown-pool version as open. **It is not.**

## 2. The result: batch GCD alone suffices

**Algorithm** (Bernstein batch GCD, product/remainder trees, `O(total input) =
O(t·B)` bit-ops). For each `i`,
`g_i = gcd(N_i, ∏_{j≠i} N_j)` = the product of the **distinct shared** prime
powers of `N_i`. Three cases:

| `g_i` | meaning | outcome |
|---|---|---|
| `1` | no shared prime | needs individual work |
| `1 < g_i < N_i` | one factor shared | `g_i` and `N_i/g_i` — **factored** |
| `g_i = N_i` | **both** factors shared | split via `gcd(N_i, N_j)` for a single `j` — **factored** |

Because the moduli are semiprimes from a small pool, for `t/r ≫ 1` nearly every
modulus has at least one shared prime, so nearly every modulus factors. Measured
(40-bit primes, unknown pool):

| r (pool/2) | t | t/r | factored | correct |
|---|---|---|---|---|
| 4 | 64 | 16 | **100%** | yes |
| 8 | 512 | 64 | **100%** | yes |
| 16 | 2048 | 128 | **100%** | yes |
| 32 | 2048 | 64 | **100%** | yes |

> **Batch GCD factors the entire unknown-pool batch, with no pool knowledge, in
> `O(t·B)` total = `O(B)` per instance — provably below `L[1/3]`.** The key-reuse
> per-instance door is now open **without** a pool assumption.

## 3. A bug the data caught (the round-104 trap, again)

My first implementation reported `factored_frac = 0.0000` at every scale — yet
the narrative text asserted success. The data (0.000) contradicted the claim.
Root cause: the `g_i = N_i` case (both factors shared) was mislabelled
"unfactored" instead of being split via a single `gcd(N_i, N_j)`. Fixed; the
corrected version gives 100%.

This is the **third** instance of the round-104 guard firing (after the round-96c
budget escape and the round-104 `lcm`-prefix budget escape): **a narrative claim
of success contradicted by the measured data must be resolved before it is
recorded.** The guard is working exactly as designed; it is now the program's
most-reused correctness mechanism.

## 4. Scope, honestly

* **A genuine per-instance complexity improvement** below `L[1/3]` for batches of
  semiprimes sharing a small prime pool — the second real per-instance result of
  the investigation, and the first that needs **no pool knowledge**.
* **Still distribution-limited:** it requires the moduli to share primes from a
  pool (key reuse). It is *not* a worst-case factoring improvement, and does not
  touch independent random RSA keys.
* **Not claimed:** any heuristic-free sub-`L[1/3]` per-instance result for
  independent keys. The genuinely open problem remains: batching semiprimes from
  an unknown pool that is **not** small (where pigeonhole no longer forces
  sharing).

## 5. Where this leaves the program

The many-instance line now has a complete, verified result:

* known small pool → `O(B)`/instance (r108);
* **unknown small pool → `O(B)`/instance via batch GCD, no pool needed** (r108b).

The only remaining door in this model is an unknown pool that is **not** small,
where no pigeonhole forces prime reuse — and where batch GCD correctly finds
nothing.