# Computational Evidence

Exploratory numerics carried out *before* formalisation, to decide which of the
five thread conjectures were worth attacking and in which direction.  These
computations are **not** the verification; the verification is the sorry-free
Lean file `Catalog/Algebra/DataSheafCohomology.lean`.  Everything reported here
was subsequently re-proved in Lean over an arbitrary field (or over `ℚ` where a
specific scalar is used), so no claim below rests on the numerics alone.

Method: exact rational Gaussian elimination (`fractions.Fraction`) on the
coboundary matrices; `dim H¹ = dim C¹ - rank δ⁰` for the 1-skeleton and
`dim H¹ = dim ker δ¹ - rank δ⁰` for the full nerve.

---

## 1. Triangle nerve: does the pairwise (flag) complex compute `H¹`?

Nerve: `U₀, U₁, U₂` with all three pairwise overlaps and the triple overlap
nonempty.  Constant (scalar) stalks, identity restriction maps.

```
δ⁰ = [ -1  1  0 ]        (rows = overlaps 01, 12, 02)
     [  0 -1  1 ]
     [ -1  0  1 ]
δ¹ = [  1  1 -1 ]        (the 2-cell U₀∩U₁∩U₂)
```

| quantity | value |
|---|---|
| `rank δ⁰` | 2 |
| `dim C¹` | 3 |
| `dim H¹` from the 1-skeleton (pairwise only) | **1** |
| `rank δ¹` | 1 |
| `dim ker δ¹` | 2 |
| `dim H¹` from the full nerve | **0** |

**Conclusion.**  The two coboundary matrices give unequal dimensions on the
smallest flag nerve.  This is exactly the refutation the conjecture asked for
("a single flag nerve producing unequal dimensions would refute the
conjecture").  Formalised as `DataSheafCohomology.flag_reduction_fails`.

---

## 2. Cyclic nerve with scalar restriction maps: is there a rank law?

Nerve: the `n`-cycle.  Coboundary `(δf)ᵢ = aᵢ·f(i+1) - f(i)`, indices mod `n`.
Holonomy `h = ∏ aᵢ`.

| `n` | `a` | holonomy | `dim H¹` |
|---|---|---|---|
| 1 | `(1)` | 1 | 1 |
| 1 | `(2)` | 2 | 0 |
| 2 | `(1,1)` | 1 | 1 |
| 2 | `(2,2)` | 4 | 0 |
| 2 | `(2,½)` | 1 | 1 |
| 3 | `(1,1,1)` | 1 | 1 |
| 3 | `(2,2,2)` | 8 | 0 |
| 3 | `(2,½,1)` | 1 | 1 |
| 4 | `(1,1,1,1)` | 1 | 1 |
| 4 | `(2,2,2,2)` | 16 | 0 |
| 4 | `(2,½,1,1)` | 1 | 1 |
| 5 | `(1,…,1)` | 1 | 1 |
| 5 | `(2,…,2)` | 32 | 0 |
| 5 | `(2,½,1,1,1)` | 1 | 1 |
| 6 | `(1,…,1)` | 1 | 1 |
| 6 | `(2,…,2)` | 64 | 0 |
| 6 | `(2,½,1,1,1,1)` | 1 | 1 |

**Pattern.**  `dim H¹` depends on `a` only through the single scalar `∏ aᵢ`, and
equals `1` iff that product is `1`.  Note the row `a = (2,½,1,…)`: the individual
restriction maps are *not* identities, yet the obstruction is present — only the
loop product matters.  Formalised as
`DataSheafCohomology.cyclic_holonomy_criterion`.

Note also that `dim H¹ ≤ 1` for every `n`: a *connected* cyclic nerve cannot
produce an obstruction growing with the feature count.  This is what motivated
looking at a fragmented nerve for the missing-rate conjecture.

---

## 3. Disjoint-loop nerve: exhaustive rank-law check

Nerve: `N` self-loops.  `(δf)ᵢ = aᵢ·f i - f i`.

Exhaustive enumeration of all `a ∈ {1,2,3}^N` for `N = 1,2,3,4` (3 + 9 + 27 + 81
= 120 cases).  In every case

```
dim H¹  ==  #{ i : aᵢ = 1 }
```

with no exceptions.  So on a *fixed* nerve with *invertible* restriction maps the
obstruction dimension sweeps the whole range `0 … N`.  Formalised (for an
arbitrary field, arbitrary `N`) as
`DataSheafCohomology.finrank_H1_disjointLoops`, and turned into the
realisability statement `missing_rate_does_not_determine_H1`.

---

## 4. Counterexample hunt against the surviving statements

* Against `finrank_H1full_le_finrank_H1` ("refining the nerve can only shrink
  `H¹`"): no counterexample can exist, since `ker δ¹ ⊆ C¹` and the coboundary
  subspace is the same in both quotients.  Proved rather than sampled.
* Against `cyclic_holonomy_criterion` with a *singular* restriction map: taking
  `a = (0,1,…,1)` on the `n`-cycle gives holonomy `0 ≠ 1` but the transport
  argument breaks; numerically `dim H¹ = 0` still, but the kernel argument needs
  `aᵢ ≠ 0`, so the hypothesis is kept in the Lean statement.  (The invertibility
  hypothesis is also what makes the counterexample to the missing-rate law
  non-degenerate.)

## 5. Integral coefficients (cycle 2/3)

Same nerves, stalks `ℤ` instead of a field.

Single loop, restriction scalar `a`; coboundary is multiplication by `a - 1`:

| `a` | `H¹(ℤ) = ℤ/(a-1)` | `dim_ℚ H¹` |
|---|---|---|
| 1 | `ℤ` (infinite) | 1 |
| 2 | `0` | 0 |
| 3 | `ℤ/2` | 0 |
| 4 | `ℤ/3` | 0 |
| −1 | `ℤ/2` | 0 |

Rows `a = 3, 4, −1` are the barrier: a nonzero integral obstruction with a
vanishing rational one.  Formalised for `a = 3` as
`torsion_obstruction_invisible_to_field_coefficients`, in general as
`integral_H1_torsion` + `rational_H1_vanishes_of_no_trivial_loop`.

The `2`-cycle over `ℤ`, coboundary matrix `[[-1, a₀], [a₁, -1]]`:

| `a` | `det` | `∏aᵢ - 1` |
|---|---|---|
| (2,2) | −3 | 3 |
| (2,3) | −5 | 5 |
| (3,3) | −8 | 8 |
| (1,1) | 0 | 0 |

`|det| = |∏aᵢ - 1|` in every case, which is the numerical origin of the general
statement `det_smul_H1Zmat_eq_zero` (proved: the determinant annihilates the
integral obstruction of *any* square integer coboundary) and of next-cycle
sub-conjecture D1 (the module is exactly `ℤ/(∏aᵢ - 1)`, still open).

## 6. OEIS

No new integer sequence arises: the two closed forms are `[∏aᵢ = 1]` and
`#{i : aᵢ = 1}`, both trivial as sequences.  No OEIS entry is claimed.
