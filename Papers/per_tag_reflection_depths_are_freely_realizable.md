# Computational evidence — per-tag reflection depths

All searches below evaluate *finite tag-indexed Kripke models* exactly (no sampling
inside a model): for a model on the worlds `0, …, M` with tag relations `R_i` and a
valuation, the truth sets of all formulas of box depth `≤ k` form a finite Boolean
algebra `F_k` (`F_0` = Boolean closure of the atom sets, `F_{k+1}` = Boolean closure of
`F_k ∪ {□_i a : a ∈ F_k}`), which is computed as a set of bitmasks. Then

* **inconsistency height** of tag `i` = least `h` with `□_i^{h+1} ⊥` true at every world;
* **reflection depth** of tag `i` = least `k` such that some `a ∈ F_k` is true throughout
  the *image* `Im_i = {n : ∃ m ≤ M, n < m ∧ R_i m n}` but false at some world `≤ M`
  (by `provable_frameSys_box_iff`, this is exactly the least `k` with
  `¬ DepthReflection (k+1) i S`).

These are the two invariants named in the conjecture, computed by brute force.
Everything reported here was subsequently either **proved in Lean** (the entries marked
✔) or turned into a future direction; nothing in the Lean files depends on the searches.

## 1. The realizable quadruples at `N = 2` (two tags)

The conjecture predicts that every quadruple `(h₀, h₁, ρ₀, ρ₁)` with `ρ_t ≤ h_t ≤ 2`
— there are `6 × 6 = 36` of them — is realized by the common refinement of `capC` and
`valSys`, i.e. by some `cvSys c V 2`.

Exhaustive search over all truncation vectors `c` (values `0, …, 3`) and **all**
valuations on the worlds `0, 1, 2` (all set partitions of the world set, which is the
same as all Boolean algebras of atom sets):

```
conjecturally realizable quadruples (N = 2) : 36
realized inside the refinement class        : 22
missing from the class                      : 14
```

The 14 missing quadruples are

```
(1,1,0,1) (1,1,1,0) (1,2,0,2) (1,2,1,0) (1,2,1,2) (2,1,0,1) (2,1,2,0)
(2,1,2,1) (2,2,0,1) (2,2,0,2) (2,2,1,0) (2,2,1,2) (2,2,2,0) (2,2,2,1)
```

and every one of them is explained by a theorem that is now proved:

| pattern | missing quadruples | theorem |
|---|---|---|
| equal heights, different depths | `(1,1,0,1) (1,1,1,0) (2,2,·,·)` off-diagonal | `cvSys_depthReflection_congr_of_min_eq` ✔ |
| strictly lower tag with depth `≥ 2` | `(2,1,2,·) (1,2,·,2)` | `classRealizes_low_tag_le_one` ✔ |
| depth exceeding the height gap | `(1,2,1,0)` etc. | `classRealizes_gap_bound` ✔ |

**Counterexample hunt.** The universal claim of the conjecture is therefore *false*, and
the smallest witnesses are the pairs `(exD, exR)` (equal heights `2`, depths `1` and `0`)
and `(exD2, exR2)` (heights `2, 1`, depths `2, 1`), both refuted in Lean
(`not_classRealizes_exD_exR`, `not_classRealizes_exD2_exR2`).

## 2. The same quadruples for arbitrary GL frames

Exhaustive search over **all** transitive tag relations on the 4 worlds `0, …, 3`
(40 transitive relations below the diagonal), all pairs of them, and all valuations:

```
realized by general transitive tag frames on 4 worlds : 36 of 36   (nothing missing)
```

So the conjecture is *true in spirit*: it fails only because the refinement of `capC`
and `valSys` is too narrow a class. This is what the Lean file establishes structurally:
the refinement produces only the nested initial-segment images `[0, min N (c i))`
(`frameImage_capRel_iff` ✔), while decoupling requires incomparable images
(`frameImage_not_subset_of_depthReflection_ne` ✔), which window frames provide
(`famSys_images_incomparable` ✔).

## 3. Which whole profiles are simultaneously realizable?

At `N = 2` there are five live classes `(h, ρ) ∈ {(1,0), (1,1), (2,0), (2,1), (2,2)}`
(plus the dead class `(0,0)`, which is free). A stochastic search over rectangle frames
`R_i = (A_i × B_i) ∩ {n < m}` (always transitive) with a two-colour valuation found a
realization of **every one of the 26 subsets of size ≥ 2, including the full profile**,
on `M + 1 = 5` worlds; e.g. for the full profile

```
worlds 0..4,  atom true at {0,1}
(1,0): sources {0,2}        targets {0,1,4}
(1,1): sources {0,3,4}      targets {0,2}
(2,0): sources {0,1,2,3,4}  targets {0,1}
(2,1): sources {0,1,3,4}    targets {1,2,3}
(2,2): sources {0,3,4}      targets {0,1,2,3,4}
```

No obstruction to *simultaneous* realizability of a full profile was found — this is the
evidence behind future direction **D1** (full GL realizability of arbitrary `(d, r)`).

## 4. Two uniform constructions that fail, and why

Both attempts to make the witness *uniform in the class* failed, which is why the Lean
file proves the positive results only for the constant profile and for the two-tag
family `famSys`:

* **Chain + per-tag window `[b_i, H_i]`, valuation cut `w = N`,
  `b_i = N + ρ_i − h_i`, `H_i = N + ρ_i`.** Heights come out right for all classes, but
  every class with `ρ_i = h_i` gets measured depth `0`: its image starts exactly at the
  valuation cut, so the box-free formula `¬p` already separates it. Measured at
  `N = 1, 2, 3`.
* **Chain + per-tag activity band `[lo_i, H_i]` (all worlds below are visible),
  `lo_i = N + ρ_i − h_i + 1`, `H_i = N + ρ_i`.** All heights and all depths `≤ 1` come
  out right, but every class with `ρ_i ≥ 2` collapses to depth `1`
  (`N = 2, 3, 4`): the depth-`1` formula `□_j ⊥` of a tag `j` whose band lies above the
  image separates it. The bands themselves refine the depth-`1` type structure.

Both failures are instances of one phenomenon: *adding tags refines the modal types, so
a construction for a whole profile must control the type ladder of the entire frame*,
which is the content of future direction **D1**.

## 5. The exact class spectrum (empirical)

For the refinement class with a constant valuation and two height values `H > L ≥ 1`,
the measured reflection depths are

```
ρ(H) = H − L,      ρ(L) = 1        (and ρ(H) = H when L = 0)
```

matching the proved upper bounds `classRealizes_gap_bound` and
`classRealizes_low_tag_le_one` with equality. The two-valued case of this observation is
now a theorem (`classRealizes_twoValue`, `classRealizes_gap_bound_sharp`): for
`1 ≤ L < N` the refinement class realizes exactly the depths `N − L` on the tags of
height `N` and `1` on the tags of height `L`. The case of three or more distinct height
values is future direction **D2**.

## OEIS

No integer sequence of independent interest arises: the counts here (`22`, `36`,
`(N+1)(N+2)/2` classes) are small polynomial quantities, and a search for `22, 36` in
this context returns nothing relevant. No OEIS identifier is claimed.

## Reproducibility

The searches are short standalone Python programs (exact enumeration of the Boolean
algebras `F_k` described above); the essential routine is

```python
def boxop(mask, R, worlds):           # truth set of □_R a, given truth set of a
    return bits(all((mask >> n) & 1 for n in worlds if (m, n) in R) for m in worlds)
```

with `F_{k+1}` the Boolean closure of `F_k ∪ {boxop(a, R_i)}`. All numbers quoted above
are outputs of exhaustive enumeration except those in §3, which come from a stochastic
hill-climbing search (a *positive* search: every reported realization was verified
exactly, only the absence of a realization would be inconclusive).
