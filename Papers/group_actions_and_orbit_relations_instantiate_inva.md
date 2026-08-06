# Build notes for the WallpaperRhythm files

All Lean files of this thread live under

* `Catalog/Applications/WallpaperRhythm/`
* `Catalog/Computation/WallpaperRhythm/`

and use the module names the library globs of `lakefile.toml` declare, i.e.
`Applications.WallpaperRhythm.QuotientEntropy`,
`Computation.WallpaperRhythm.OrbitCounting`, and so on.

`lakefile.toml` declares the libraries with globs such as `Computation.+` but
does not set `srcDir`, so Lake looks for `Computation/...` at the repository
root while the sources are kept in `Catalog/Computation/...`.  This mismatch is
pre-existing and the lakefile has been left untouched.  To build (and re-verify)
the files, make the module roots visible to Lake in one of the two usual ways:

```sh
# either: expose the source roots where the globs expect them
ln -s Catalog/Computation Computation
ln -s Catalog/Applications Applications
lake build Computation.WallpaperRhythm.GlideCapacity

# or: add   srcDir = "Catalog"   to each [[lean_lib]] block of lakefile.toml
```

Every file of this thread was verified this way: it compiles with no `sorry`,
and each main theorem depends only on the standard axioms `propext`,
`Classical.choice`, `Quot.sound`.

## Files and dependencies

```
Applications.WallpaperRhythm.QuotientEntropy      (earlier cycle)
└── Computation.WallpaperRhythm.OrbitCounting     (earlier cycle)
    └── Computation.WallpaperRhythm.OrbitEntropy  (earlier cycle)
        ├── Computation.WallpaperRhythm.QuarterTurnCapacity
        │   └── Computation.WallpaperRhythm.GlideCapacity
        ├── Computation.WallpaperRhythm.BernoulliEntropy
        └── Computation.WallpaperRhythm.CanonSharpness
```


# Computational evidence

All numbers below were computed inside Lean (`#eval` on `Finset.filter` over the
finite function type `ZMod p × ZMod q → Bool`), i.e. by brute-force enumeration of
*all* `2^(p*q)` binary grids, before the corresponding theorems in
`Catalog/Computation/WallpaperRhythm/OrbitCounting.lean` were proved.

## 1. Point reflection (retrograde–inversion) `(t, n) ↦ (-t, -n)`

Count of `f : ZMod p × ZMod q → Bool` with `f (-a) = f a` for all `a`:

| p | q | cells `pq` | brute force count | `2 ^ ((pq + t(p)·t(q))/2)` |
|---|---|-----|--------|--------|
| 3 | 1 | 3  | 4   | `2^2` |
| 5 | 1 | 5  | 8   | `2^3` |
| 3 | 3 | 9  | 32  | `2^5` |
| 3 | 5 | 15 | 256 | `2^8` |
| 4 | 3 | 12 | 128 | `2^7` |

Here `t(n) = 2` if `n` is even and `1` if `n` is odd (the number of solutions of
`-x = x` in `ZMod n`). The last row is the even case, where the half-period cell
`(2, 0)` is fixed in addition to the origin — this is why the naive "odd-only"
formula `2^((pq+1)/2)` is *not* valid in general, and the proved theorem
`card_pattern_pointReflection` carries the `twoTorsionCard` correction.

Both are theorems now:
`card_pattern_pointReflection_three_three : ... = 32` and
`card_pattern_pointReflection_four_three : ... = 128`.

## 2. Cyclic time shifts `(t, n) ↦ (t + g, n)`

Count of `f` invariant under every time shift:

| p | q | brute force count | `2 ^ q` |
|---|---|--------|-------|
| 4 | 3 | 8 | `2^3` |
| 3 | 2 | 4 | `2^2` |

Matching the theorem `card_pattern_translation : Nat.card (...) = 2 ^ q`
(the shift action has exactly `q` orbits, one per pitch row).

## 3. Symmetry group of a single pattern

For the "backbeat" pattern on `ZMod 4 × ZMod 1` with onsets at beats `0, 2`, an
exhaustive check over the four shifts (`decide`, hence machine-verified in the
Lean file as `mem_symmetryGroup_backbeat`) shows that the shift `g` preserves the
pattern iff `g ∈ {0, 2}`. So its symmetry group has order `2` inside an ambient
group of order `4`: a pattern's symmetry group is strictly between `⊥` and `⊤`.

## 4. OEIS

The orbit counts of the inversion action on `ZMod n` (`n = 1, 2, 3, …` giving
`1, 2, 2, 3, 3, 4, …`, i.e. `⌊n/2⌋ + 1`) are the "necklace under reflection"
counts; the derived pattern capacities are the powers of two of those values.
No new integer sequence is claimed here — the point of the file is that the
capacity is an *exact* function of Burnside fixed-point data.

## 5. Evidence for the second-cycle results

### 5.1 Strict antitonicity

On `ZMod 4 × ZMod 1` the trivial subgroup `⊥` of the shift group has `4` orbits
(`16` patterns) while `⊤` has `1` orbit (`2` patterns).  The two cells `(0,0)`
and `(1,0)` are merged by `⊤` and separated by `⊥`, which is precisely the
hypothesis of the proved theorem `card_pattern_antitone_strict`; the concrete
instance `card_pattern_shift_lt_card_pattern_bot` records `2 < 16`.

Conversely, any strictly larger subgroup that produces the *same* orbit
partition leaves the count unchanged — for instance a subgroup acting trivially
on extra generators — which is why the strictness hypothesis has to be
orbit-theoretic rather than "`H < K`".  That is the content of
`card_pattern_eq_of_orbits_eq`, and it refutes the naive subgroup-only form of
conjecture C2 of the previous cycle.

### 5.2 Canon divisibility

For the backbeat on `ZMod 4 × ZMod 1` (onsets at beats `0, 2`), the shift by `2`
is a symmetry (`isCanonAt_backbeat`) and the onset count is
`onsetCount backbeat = 2`, verified by exhaustive evaluation over the four cells.
The order of `2` in `ZMod 4` is `2`, and indeed `2 ∣ 2`
(`addOrderOf_two_dvd_onsetCount_backbeat`).  Exhaustive enumeration of the
`16` patterns on this grid (computed in Lean by `#eval` over the whole function
type) shows that exactly `4` of them are invariant under the shift by `2`, and
the set of their onset counts is `{0, 2, 4}` — always even, never odd, matching
the proved obstruction `addOrderOf_dvd_onsetCount`.

### 5.3 Quarter-turn descent

Testing the map `(t, n) ↦ (-n, t)` on the sublattices `pℤ × qℤ` for all
`1 ≤ p, q ≤ 6`: the image of `(p, 0)` is `(0, p)`, which lies in the lattice iff
`q ∣ p`, and the image of `(0, q)` is `(-q, 0)`, which lies in it iff `p ∣ q`.
Both hold exactly on the diagonal `p = q`, matching
`quarterTurn_mapsTo_torusLattice_iff`.  On a square torus, iterating the
descended map twice gives `v ↦ -v`, the retrograde–inversion whose capacity was
computed in the previous cycle.

## 6. Evidence for the present cycle

### 6.1 Quarter-turn orbit counts on square tori

Brute-force enumeration of the orbits of the quarter turn `(t, n) ↦ (-n, t)` on
`ZMod p × ZMod p` (an exploratory `#eval` in Lean, run over all `p²` cells and
grouping them into rotation orbits) gives, for `p = 1, …, 8`:

| `p`             | 1 | 2 | 3 | 4 | 5 | 6 | 7  | 8  |
|-----------------|---|---|---|---|---|---|----|----|
| orbits (counted)| 1 | 3 | 3 | 6 | 7 | 11| 13 | 18 |
| `(p² + 2t + t²)/4`, `t = gcd(2,p)` | 1 | 3 | 3 | 6 | 7 | 11 | 13 | 18 |

The two rows agree everywhere in the range, which is what suggested the
parity-corrected closed form.  The formula is *proved* (not merely tested) in
`card_pattern_quarterTurn`, together with the specializations
`2 ^ ((p² + 3)/4)` for odd `p` and `2 ^ ((p² + 8)/4)` for even `p`; the enumerated
values above were only used to find the right statement.  Note that the naive
odd-only guess `(p² + 3)/4` is wrong for even `p` (it gives `7/4 → 1` at `p = 2`
instead of `3`), the same parity phenomenon already observed for the point
reflection in Section 2.

### 6.2 Glide reflections

For the glide `γ(t, n) = (t + p/2, -n)` on `ZMod p × ZMod q` with `p` even, no
cell can be fixed: the first coordinate would force `p/2 ≡ 0 (mod p)`, which
fails because `0 < p/2 < p`.  Hence the orbits all have size two and there are
`p q / 2` of them.  Checked by hand for `2 × 2` (2 orbits, 4 patterns) and
`4 × 3` (6 orbits, 64 patterns); both values are proved in
`card_pattern_glide_two_two` and `card_pattern_glide_four_three`.

### 6.3 Canon onset spectra

On `ZMod 4 × ZMod 1` with the half-bar shift `g = 2` (of additive order `2`), the
achievable onset counts are `{0, 2, 4}`: exactly the multiples of `2` bounded by
`4 · 1 = 4`.  This is the enumeration reported in Section 5.2, and it is now a
theorem — `canon_onsetCount_four_one`, an instance of the general spectrum
theorem `isCanonAt_onsetCount_iff`.

### 6.4 Status of the evidence

Every numerical claim in this section is backed by a machine-checked theorem in
the accompanying Lean files, except the brute-force orbit table of Section 6.1,
which was an exploratory computation used to *find* the closed form that is
proved in `card_pattern_quarterTurn`.
