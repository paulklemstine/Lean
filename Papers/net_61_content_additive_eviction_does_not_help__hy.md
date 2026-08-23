# Computational evidence — NET-61 additive-hybrid eviction law

Scope: exploratory numerics used to *choose* the conjectures before formalising.
**Nothing in this file is a verification.** The verified statements are the Lean
theorems in `Catalog/Combinatorics/HybridEvictionAdditiveLaw.lean` and
`Catalog/Combinatorics/EvictionOnlineLowerBound.lean`, which build with no
`sorry` and depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Model used in the exploration

Slots `0 … n-1`; cheap signals `a` (accumulated usage) and `p` (static content
probe); hidden utility `v`. The policy at probe weight `λ` keeps the `B` slots of
largest `a i + λ p i`; retained value is `∑_{i kept} v i`. The oracle keeps the
`B` slots of largest `v`.

## 1. Monotone degradation under an anti-aligned probe

3000 random instances (`n ∈ [3,9]`, `B ∈ [1,n-1]`, `v` decreasing and `p`
increasing in the index, `a` uniform), λ-grid `0, .25, .5, 1, 2, 4, 8, 16`:

```
anti-aligned probe: monotonicity violations in 0 of 3000 instances
```

This is the pattern later proved as `retained_antitone_in_lambda`
(and, with a genuine exchange, `retained_strictAnti_in_lambda`).

## 2. The hypothesis is necessary

Same sweep with `v`, `p`, `a` all independent uniform:

```
unrestricted probe: some lambda>0 beat lambda=0 in 1489 of 3000 instances
```

So `λ = 0` is *not* universally optimal: a probe that carries information does
show up as a positive-λ gain. This forced the guarded formulation and produced
the sharpness theorem `positive_lambda_can_strictly_help` (a two-slot instance
where `λ = 2` strictly beats `λ = 0`).

## 3. Kept sets visited along a sweep

```
max distinct kept sets over a lambda-sweep (n<=7): 6
```

(2000 random instances, λ from 0 to 20 in steps of 0.005.) This is well below
`C(n,2)` and suggested the still-open bound `B(n-B)+1` recorded in
`FUTURE_DIRECTIONS.md`.

## 4. The calibrated four-slot instance

`a = (4,3,2,1)`, `p = (8,6,4,2)`, `v = (0.4692, 0.4692, 0.4977, 0.4977)`, `B = 2`:

| λ | kept | retained |
|---|------|----------|
| 0 | {0,1} | 0.9384 |
| 0.25 | {0,1} | 0.9384 |
| 1 | {0,1} | 0.9384 |
| 4 | {0,1} | 0.9384 |
| 100 | {0,1} | 0.9384 |
| oracle | {2,3} | 0.9954 |

gap `= 0.0570`, i.e. exactly the measured 5.7 points, uniformly in λ. Proved as
`net61_calibrated_gap`.

## 5. Sequential model: online vs offline on `B+1` pages

Adversary always requests the page the online policy just evicted (here LRU);
offline evicts a page not requested during the next `B-1` steps; `m = 200`.

```
B=2 online faults=200  offline faults=100  ratio=2.00  ceil(m/B)=100
B=3 online faults=200  offline faults= 67  ratio=2.99  ceil(m/B)= 67
B=4 online faults=200  offline faults= 50  ratio=4.00  ceil(m/B)= 50
B=8 online faults=200  offline faults= 25  ratio=8.00  ceil(m/B)= 25
```

The offline heuristic attains `⌈m/B⌉` exactly and the ratio equals `B`. Proved
as `offline_cost_bound`, `runCost_advSeq`, `online_lower_bound_factor_budget`
(the last for *every* deterministic eviction rule, not just LRU).

## Counterexample hunt

* Universal claim "`λ = 0` is optimal": **false without hypotheses** — §2, and a
  minimal counterexample is formalised (`positive_lambda_can_strictly_help`).
* Universal claim "the retained value is antitone in λ under anti-alignment":
  no counterexample in 3000 random instances; proved.
* Universal claim "some cheap score beats the oracle at matched budget":
  impossible; proved (`cheap_signal_le_oracle`).

## Reproduction script

```python
import random
random.seed(11)

def topset(score, B, n):
    idx = sorted(range(n), key=lambda i: (-score[i], i))
    return frozenset(idx[:B])

def val(S, v): return sum(v[i] for i in S)

lams = [0, 0.25, 0.5, 1, 2, 4, 8, 16]

# 1. anti-aligned probe
viol = 0
for _ in range(3000):
    n = random.randint(3, 9); B = random.randint(1, n - 1)
    v = sorted([random.random() for _ in range(n)], reverse=True)
    p = sorted([random.random() for _ in range(n)])
    a = [random.random() for _ in range(n)]
    vals = [val(topset([a[i] + l * p[i] for i in range(n)], B, n), v) for l in lams]
    if any(vals[k + 1] > vals[k] + 1e-12 for k in range(len(vals) - 1)):
        viol += 1
print("violations:", viol)

# 5. paging, B+1 pages, adaptive adversary vs greedy offline
def offline_cost(seq, C0, B):
    C = set(C0); k = 0
    for i, r in enumerate(seq):
        if r in C: continue
        k += 1
        nxt = set(seq[i + 1:i + B])
        C.discard(next(e for e in C if e not in nxt)); C.add(r)
    return k

for B in [2, 3, 4, 8]:
    U = list(range(B + 1)); C = set(range(B)); Cc = set(C)
    seq = []; last = {u: -1 for u in U}
    for t in range(200):
        r = next(u for u in U if u not in Cc)
        seq.append(r)
        victim = min(Cc, key=lambda u: last[u])
        Cc.discard(victim); Cc.add(r); last[r] = t
    print(B, len(seq), offline_cost(seq, C, B))
```
