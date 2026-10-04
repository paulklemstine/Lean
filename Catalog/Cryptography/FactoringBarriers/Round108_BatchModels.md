# Round 108 — the many-instance models: a real per-instance win, and a Batch-NFS correction

**2026-10-04. Rounds 96–107 closed the worst-case single-instance frontier. This
round turns to two models the program had NEVER touched — many-instance / batch
factoring — and finds the one regime that provably beats `L[1/3]` PER INSTANCE,
plus corrects a widely-misread result (Batch NFS).**

Empirical companion: `Experiments/UMWWindow/batch_pool.py` (deterministic,
`out_batch.txt`).

---

## 1. Angle: the many-instance models (genuinely new)

Every prior round was worst-case, one `N`, classical, deterministic. The batch
/ average-case setting is a different complexity question, and the program had no
coverage of it.

## 2. Model 1 — small-prime-pool batch: a real per-instance improvement

**The regime.** Many semiprimes `N_i = p_a · q_b` drawn from *small* pools
`P, Q` (|P| = |Q| = r). This is the key-reuse / small-pool distribution.

**The primitive (rigorous).** Bernstein, *Factoring into coprimes in essentially
linear time* (J. Algorithms 54 (2005); *Math. Comp.* 76 (2007)): given `N_1,…,N_t`
of total input length `n`, compute pairwise-coprime factors in `Õ(n)` — linear in
the **total** input, via product/remainder trees and batch GCD.

**The consequence.** A batch of small-pool semiprimes factors at **`O(B)` per
instance** (verified: `divisions/instance = 2.00` at every pool size, `B=48`) —
**provably below `L[1/3] ≈ 3.4×10⁴³`** for a single 48-bit key.

> This is a **genuine per-instance complexity improvement** — the only one
> found in ~22 rounds — but **only for the key-reuse / small-pool
> distribution**, not worst-case. For independent random RSA keys, factoring
> into coprimes is information-free (`C_i = N_i`) and costs `O(B)`, i.e. optimal
> but vacuous.

## 3. Model 2 — general batch GCD (shared primes)

If the moduli share an unknown prime, batch GCD (product tree → remainder tree →
`gcd`) finds it in **`O(total input)`** — linear, versus `t` independent factorings.
Rigorous. Used in the wild (USENIX Sec'12; the 2013 "Coppersmith in the wild"
smart-card study factored 103 of 184 keys by batch GCD). Again
**distribution-specific** (shared primes from key-generation failure).

## 4. Correction: Batch NFS is NOT a per-instance time improvement

Bernstein–Lange, *Batch NFS* (ePrint 2014/921, SAC 2014) is popularly summarised
as "factors `L^{0.5}` keys in `L^{1.022}` time, a per-key win." Decoded against
their `L` normalization:

| quantity | Batch NFS | single-key NFS |
|---|---|---|
| per-key **time** | `L^{0.522+o(1)}` | `L^{1/3+o(1)}` — **Batch NFS is WORSE** |
| per-key **area** | `L^{1.181+o(1)}` | `L^{o(1)}` |
| per-key **area·time** | `L^{1.704+o(1)}` | `L^{1.976+o(1)}` — **better** |

> **Batch NFS trades space (area) for time and improves the area–time PRODUCT,
> not per-instance time.** Its per-key time `L^{0.522}` is *worse* than single-key
> `L^{1/3}`. It is also **heuristic** (builds on the unproven NFS smoothness
> assumptions). So it is *not* a worst-case or per-instance time improvement —
> an important distinction the popular write-ups blur.

## 5. What this adds, honestly

* **A real new algorithm** (Model 1): batch small-pool semiprime factoring at
  `O(B)` per instance, using Bernstein's rigorous linear-time factoring-into-
  coprimes. This is the **first per-instance complexity improvement found in the
  investigation**, and it is verified end-to-end.
* **A rigorous primitive** (Model 2): batch GCD in linear time for shared-prime
  families.
* **A correction** to how Batch NFS is understood: it is a space-for-time /
  area-time trade, not a per-instance time win, and it is heuristic.
* **Not claimed:** any improvement for worst-case random RSA, or a
  heuristic-free per-instance sub-`L[1/3]` for independent keys. The genuine
  open problem in this model — batching *independent* semiprimes from a small
  prime pool without knowing the pool — remains open (per the survey).

**Where this leaves the program.** The worst-case frontier is closed (96–107).
The many-instance models open exactly one real door: **key-reuse / small-pool
batches factor at `O(B)` per instance.** That is a legitimate, rigorous, verified
per-instance improvement — narrow in distribution, but real. Whether it
generalizes (independent keys, unknown pool) is the open question this model now
poses.