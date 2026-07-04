# Computational Evidence — General-`m` Tamari / `(m+1)`-Constellation Generating Trees

We model the recursive decomposition of both families by a **generating tree**
with a *succession rule* `succ : ℕ → List ℕ` on labels (the tracked active-site /
valley statistic) and a root label.  The two encodings are:

* **active-sites rule** (Dyck / `m`-Tamari side)
  `sitesRuleM m k = range' 1 (m*k + 1)`  with root label `1`;
* **shifted rule** (`(m+1)`-constellation side)
  `shiftedRuleM m k = range' 2 (m*k - m + 1)`  with root label `2`.

The candidate label bijection is `relabel k = k + 1`.

## 1. Intertwining check (the heart of the isomorphism)

For all `0 ≤ m,a < 4` we verified
`shiftedRuleM m (a+1) = (sitesRuleM m a).map (·+1)`  — all `true`:

```
[[true,true,true,true],[true,true,true,true],
 [true,true,true,true],[true,true,true,true]]
```

## 2. Counting sequences `levelCount sitesRuleM m` (number of nodes per level)

```
m = 1 :  1, 2, 5, 14, 42        (Catalan numbers, OEIS A000108)
m = 2 :  1, 3, 15, 113, 1273
m = 3 :  1, 4, 34, 586, 21721
```

* `m = 1` reproduces the Catalan numbers, matching the `m = 1` theorem of the
  motivating paper (the base layer proved in the previous cycle).
* Level-1 count is `m + 1`, so the trees are genuinely distinct for distinct `m`.
* Growth is super-exponential; in particular each level is `≥ 2×` the previous
  one (every node has at least two children when `m ≥ 1`).

## 3. Equi-enumeration check (unrefined bijection)

For `m = 2`, `levelCount shiftedRuleM 2` (root `2`) equals
`levelCount sitesRuleM 2` (root `1`) at every tested level — all `true`:

```
[true, true, true, true, true]
```

## 4. Counterexample hunt

No counterexample to the intertwining identity was found across the sampled
`(m,a)` grid; the identity is subsequently **proved for all `m, a`** in
`GeneralM.lean` (`sitesM_shiftedM_intertwine`), so the bijection is unconditional.

## Conclusion

The active-sites and shifted encodings of the recursive decomposition are
isomorphic generating trees for **every** `m`, via the single relabelling
`k ↦ k+1`.  This yields, for all `m`, both the plain equi-enumeration and the
refined (statistic-preserving) equinumerosity — the general-`m` analogue of the
`m = 1` result.  These claims are formalized and proved in `GeneralM.lean`.
