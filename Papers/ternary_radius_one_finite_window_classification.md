# Computational Evidence — ternary radius-one finite-window classification

**Scope.** All numbers in this file come from *external* exhaustive/enumerative programs
(C + Python) run during the investigation, **not** from Lean.  They are reported as
experimental evidence only; every claim that is asserted as a theorem lives in
`Catalog/Cryptography/TernaryReversible/*.lean` with a machine-checked, sorry-free proof.
Where a statement below is also proved in Lean, the Lean name is given.

Notation: alphabet `A = {0,1,2}`, local rule `g : A³ → A` given by its 27-digit table
`g(0,0,0) g(0,0,1) … g(2,2,2)`, global map on the cycle `ℤ/n` is
`G(s)_i = g(s_{i-1}, s_i, s_{i+1})`.  A rule is *cycle-bijective* when `G` is bijective on
`ℤ/n` for every `n ≥ 1`.

---

## 1. The exact criterion used by the search

Two configurations `s ≠ t` on `ℤ/n` with `G(s) = G(t)` are the same thing as a closed walk
of length `n` in the **pair graph**

* vertices `V = (A²) × (A²)`, written `(x,y | x',y')` — `|V| = 81`;
* edge `(x,y | x',y') → (y,z | y',z')` whenever `g(x,y,z) = g(x',y',z')`,

that visits at least one *non-diagonal* vertex `(x,y) ≠ (x',y')`.  Hence

> `g` is cycle-bijective  ⟺  no non-diagonal vertex of the pair graph lies on a directed
> cycle.

This criterion (transitive closure of the 81×81 adjacency matrix) was applied to all
`3²⁷ = 7 625 597 484 987` rules; the brute-force check on cycles `n ≤ 10` was used on
samples to confirm agreement.

## 2. Counting the cycle-bijective ternary rules

| quantity | value |
|---|---|
| rules bijective on all cycles of length `≤ 4` | **4 920** |
| rules bijective on **every** cycle (exact criterion) | **1 800** |
| of these, single coordinate ∘ permutation | **18** |
| depending on exactly two window cells | **108** |
| depending on all three window cells | **1 674** |
| involutive (`G ∘ G = id`) among the 1 800 | **82** |

So the falsifiable claim of the mission — *every* cycle-bijective ternary radius-one rule
is a single coordinate followed by a permutation — is **false by a factor of 100**: only
18 of the 1 800 have that form.  This refutation is formalised (with explicit rules and
proofs, not by enumeration) in `Refutation.lean`:
`classification_claim_false`, `eighteen_counterexamples` (an explicit 18-element family of
counterexamples), and in `General.lean` the alphabet-uniform version
`claim_fails_of_three_elements`.

## 3. First failure length: how long a cycle do you need?

For every rule, the *first failure length* is the least `n` with `G` non-injective on
`ℤ/n` (computed as the shortest directed cycle through a non-diagonal pair-graph vertex,
by BFS from each of the 72 non-diagonal vertices).

| first failure length | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | never |
|---|---|---|---|---|---|---|---|---|---|
| random sample of 20 000 rules | 15 600 | 4 105 | 294 | 1 | 0 | 0 | 0 | 0 | 0 |
| the 4 920 rules surviving `n ≤ 4` | — | — | — | — | 3 072 | 36 | 0 | **12** | 1 800 |

Because every rule either fails at some `n ≤ 4` or belongs to the 4 920 survivors, the two
rows together are exhaustive over all `3²⁷` rules.  Consequence (experimental):

> **For `q = 3` the maximal first failure length is exactly 8**: a ternary radius-one rule
> is cycle-bijective iff its global map is injective on the cycles of length `1,…,8`, and
> the bound `8` is attained (12 rules first fail at `8`).

The pair graph has `q⁴ = 81` vertices, so the splicing bound is `81`; this bound is now a
**theorem** (`Shortening.lean`: `cycleBijectiveA_iff_upTo`, ternary form
`cycleBijective_iff_upTo_81`), while the observed optimum `8` is far smaller.  Closing that
gap is Direction 1 of `FUTURE_DIRECTIONS.md`.

Formalised counterparts of this experiment:
* `Shortening.lean` — the finite test itself: cycle-bijectivity is equivalent to injectivity
  on the cycle lengths `1, …, q⁴`, proved by splicing closed walks of the pair graph; it
  follows that cycle-bijectivity is decidable and that the single length `(q⁴)!` suffices;
* `Periodicity.lean` — `injective_globalMapA_of_dvd` (bad lengths are closed under
  multiples, so first failure lengths are the only interesting data) and
  `cycleBijectiveA_iff_factorial`;
* `AffineTest.lean` — inside the affine class the whole infinite test collapses to the
  **single** length `8` (`addRule_cycleBijective_iff_injective_at_eight`);
* `AffineTightness.lean` — length `8` cannot be lowered: `a+b+2c` is injective on all
  cycles of length `≤ 7` and fails at `8` (`affine_eight_test_sharp`).  The 12 rules in the
  table above that first fail at `8` include exactly this affine family.

## 4. Inverse radius: the decoder-window distribution

For a cycle-bijective rule the inverse is again a cellular automaton (Hedlund), of some
window size `k`: `s_i = d(y_{i+o}, …, y_{i+o+k-1})`.  Minimal `k` over all offsets `o`, for
the 1 800 rules:

| minimal decoder window `k` | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| number of rules | 18 | 72 | 774 | 576 | 216 | 144 |

The `k = 1` rules are exactly the 18 single-coordinate rules.  The maximum is `6`, i.e.
the inverse of a radius-one ternary reversible rule needs radius at most `2` (window `≤ 5`
centred, `6` unaligned).  Formalised: `InverseRadius.lean` exhibits `gTwist` with a
window-4 decoder and proves that **no** window-3 decoder and no radius-one inverse exists
(`gTwist_no_window3_decoder`, `gTwist_no_radiusOne_inverse`), so the inverse radius really
does grow beyond the rule's own radius.

## 5. Binary alphabet (control experiment)

| quantity | value |
|---|---|
| binary rules `2⁸ = 256`, bijective on all cycles | **6** |
| binary rules bijective on cycles `n ≤ 3` | 20 |
| binary rules bijective on cycles `n ≤ 4` | **6** |

So for `q = 2` the four lengths `1,2,3,4` already decide reversibility, and all 6 survivors
are single coordinate ∘ permutation.  Formalised by exhaustive kernel-level evaluation in
`General.lean`: `binary_bijUpTo4_classification`, `binary_classification`, and the
dichotomy `singleCoordinate_classification_iff : (claim holds for Fin q) ↔ q ≤ 2`.

## 6. Affine rules over 𝔽₃ (kernel table)

`addRule α β γ δ : (a,b,c) ↦ αa + βb + γc + δ`.  Minimal cycle length carrying a nonzero
kernel vector of the linear part (`—` = no kernel at any length, i.e. reversible):

| `(α,β,γ)` | min length | kernel vector |
|---|---|---|
| `(0,0,0)` | 1 | `(1)` |
| `(1,0,0)`, `(2,0,0)`, `(0,1,0)`, `(0,2,0)`, `(0,0,1)`, `(0,0,2)` | — | reversible |
| `(1,1,1)`, `(2,2,2)`, `(0,1,2)`, `(0,2,1)`, `(1,0,2)`, `(2,0,1)`, `(1,2,0)`, `(2,1,0)` | 1 | `(1)` |
| `(0,1,1)`, `(0,2,2)`, `(1,1,0)`, `(2,2,0)`, `(1,2,1)`, `(2,1,2)` | 2 | `(1,2)` |
| `(1,0,1)`, `(2,0,2)` | 4 | `(0,1,0,2)` |
| `(1,1,2)`, `(2,2,1)` | 8 | `(0,1,1,2,0,2,2,1)` |
| `(1,2,2)`, `(2,1,1)` | 8 | `(0,1,2,2,0,2,1,1)` |

Exactly the 6 triples with a single nonzero coefficient are reversible; the lengths
`1,2,4,8` are the orders of elements of `𝔽₉ˣ` (cyclic of order 8), which is why no affine
obstruction ever needs a cycle longer than `8`.  Fully formalised in `Additive.lean`
(`addRule_cycleBijective_iff`) and used in `AffineTest.lean` / `AffineTightness.lean`.

## 7. OEIS

The sequence produced by this project is

`R(q) = #{ radius-one reversible rules over an alphabet of size q } : R(1) = 1, R(2) = 6, R(3) = 1800, …`

No OEIS lookup was performed (the working environment has no network access), so **no OEIS
identifier is claimed**.  Computing `R(4)` — a `4^64`-sized rule space, so only reachable
by the pair-graph criterion together with symmetry reduction — is listed as a testable
future direction.

## 8. Reproducibility

The searches used (i) a C program enumerating all `3²⁷` tables with early pruning and the
`n ≤ 4` brute-force filter, (ii) a C program applying the exact pair-graph criterion, and
(iii) Python post-processing for the dependency/decoder/first-failure statistics.  The
Lean files do not depend on any of these programs: every theorem is self-contained and
kernel-checked.
