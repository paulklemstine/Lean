# Computational evidence — NET-60 tail-pair epistasis in the tropical model

All numbers below are in **hundredths of an accuracy point** (so `42` = `0.42 pts`),
and all of them are *also* proved as theorems in
`Catalog/Tropical/NetEpistasis/TailPair.lean`; the computations here were used to
design and cross-check the model before formalization.

## 1. The model

A prunable net is a finite family of computation paths.  The path indexed by a
retention target `T ⊆ {0,…,23}` survives a pruning `S` exactly when `S ⊆ T`, and
then incurs the loss recorded for `T`.  The tropical (min-plus) loss after
pruning `S` is `netLoss S = min { loss T : S ⊆ T }`, and `cost S = netLoss S -
netLoss ∅`.

Retention targets and losses used for the NET-60 replica (20 paths):

| target `T` | loss | target `T` | loss |
|---|---|---|---|
| `∅` | 0 | `{0,1}` | 25 |
| `{0}` | 13 | `{10,11}` | 40 |
| `{1}` | 12 | `{12,15}` | 60 |
| `{10}` | 14 | `{12,22}` | 59 |
| `{11}` | 14 | `{22,23}` | 42 |
| `{12}` | 57 | `{21,22,23}` | 76 |
| `{15}` | 22 | `{21,22}` | 45 |
| `{21}` | 13 | `{21,23}` | 45 |
| `{22}` | 3 | `univ \ {0,1,10,11,12,15,21,22,23}` | 20 |
| `{23}` | 3 | `univ` | 10000 |

## 2. Recomputation of the cost profile

Executable replica (run inside the project, `import Tropical.NetEpistasis.TailPair`):

```lean
def costOf (S : Finset (Fin 24)) : ℚ :=
  ((List.finRange 20).filter (fun j => S ⊆ target j)).foldl
    (fun acc j => min acc (lossVal j)) 10000
```

Output:

```
[("L0", 13), ("L1", 12), ("L10", 14), ("L11", 14), ("L12", 57), ("L15", 22),
 ("L21", 13), ("L22", 3), ("L23", 3),
 ("front_0_1", 25), ("mid_10_11", 40), ("bulk_12_15", 60), ("cross_22_12", 59),
 ("tail_22_23", 42), ("t21_22", 45), ("t21_23", 45), ("triple", 76)]
```

Every entry agrees with the corresponding theorem
(`net60_cost_L22`, …, `net60_cost_triple`).

## 3. Epistasis table (recomputed, then proved)

| arm | cost | Σ solo | epistasis `cost − Σ solo` | class |
|---|---|---|---|---|
| `tail_22_23` | 42 | 6 | **+36** | SUPER, ratio 7× |
| `bulk_12_15` | 60 | 79 | −19 | sub |
| `front_0_1` | 25 | 25 | 0 | additive |
| `mid_10_11` | 40 | 28 | +12 | super (10/7×) |
| `cross_22_12` | 59 | 60 | −1 | sub |
| `triple_21_22_23` | 76 | 19 | +57 | SUPER, ratio 4× |

Sample outputs: `(costOf {22,23}, solo sum, epistasis) = (42, 6, 36)`;
triple excess `= 57`; `epi(21,22) = epi(21,23) = 29`.

## 4. Third-order interaction

The Möbius coefficient of the triple,

```
cost{21,22,23} − cost{21,22} − cost{21,23} − cost{22,23}
  + cost{21} + cost{22} + cost{23} − cost ∅
```

evaluates to `-37`, matching `net60_triple_moebius`.  Hence the decomposition
`76 = 19 + (29 + 29 + 36) + (−37)`: the tail epistasis is genuinely *pairwise*
and saturates at order three rather than compounding without bound.

## 5. Counterexample hunt (against the "additivity law" horn P2)

Searching the tropical model class for a universal law relating joint to solo
costs fails immediately, and the failure was then proved in general:

* solo costs `0, 0` with joint cost `r` for **any** `r > 0`
  (`exists_pure_pair_epistasis`) — super-additivity ratio unbounded;
* solo costs `1, 1` with joint cost `1` (`exists_subadditive_pair`);
* exact additivity for every modular damage profile
  (`epi_eq_zero_of_modular`).

Since `realizable_iff` shows that *every* monotone normalized profile is
realizable, no counterexample-free additivity law can exist: P2 is refuted at the
level of the model class, not just for one measured network.

## 6. Sanity checks performed

* Monotonicity of the target/loss table (needed for the min-formula to be a
  genuine cost profile) was checked on all listed subsets: no superset of a
  listed set carries a smaller loss.
* Every singleton of `Fin 24` — including the 15 layers not appearing in the
  table — was checked to cost at most `57` (`net60_singleton_cheap`, proved by
  exhaustive decision over the 24 layers and 20 paths).
* Both the model and the tail subsystem were verified to have a fallback path of
  empty support, so `netLoss` is always defined.
