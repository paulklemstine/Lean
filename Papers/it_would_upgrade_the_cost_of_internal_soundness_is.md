# Computational evidence — tangled hierarchies

All structural claims below are *proved* in the Lean files in
`Catalog/Computation/`.  This note records the exhaustive enumeration that was
run **before** the proofs, to check that the conjectured statements were not
false.  The enumeration is `#eval` exploration inside Lean (a `Bool`-valued
mirror of the `Prop`-valued semantics `TangledHierarchy.eval`), cross-checked by
an independent script; it is *not* itself a kernel-checked theorem.

## Set-up

One atom `a`, one name `c`.  A single-name tangle is a denotation `den c = φ`,
i.e. the loop equation `w ↔ φ(v, w)`.  All formulas of `→`/`⊥`-depth `≤ 2` over
`{a, ⊥, tr c}` were enumerated: **156 formulas** (12 at depth `≤ 1`).  For each
formula and each of the two atomic valuations `v ∈ {F, T}`, the number of
solutions `w ∈ {F, T}` of the loop equation was computed.

## Small-case table

Distribution of the pair `(#models at v = F, #models at v = T)` over the 156
denotations:

| `(#models_F, #models_T)` | count |
|---|---|
| `(1,1)` | 106 |
| `(2,2)` | 9 |
| `(1,2)` | 11 |
| `(2,1)` | 5 |
| `(0,1)` | 11 |
| `(1,0)` | 5 |
| `(0,0)` | 9 |

Canonical single-loop denotations (matching
`selfLoop_model_ncard_trichotomy`):

| `den c` | #models |
|---|---|
| `⊥` (grounded) | 1 |
| `tr c` (truth-teller, positive loop) | 2 |
| `¬ tr c` (liar, negative loop) | 0 |
| `tr c → tr c` (mixed polarity) | 1 |

## Counterexample hunt

1. **"Positive ⇒ solvable"** — tested on all 156 denotations: every formula with
   `polar true φ` has at least one model under *both* valuations.  No
   counterexample.  (Now proved in general: `exists_tangleModel_of_positive`,
   via Knaster–Tarski.)
2. **"Unsolvable ⇒ some negative occurrence"** — 25 of the 156 denotations lose
   a model for at least one valuation; all 25 contain a negative occurrence of
   `tr c`.  No counterexample.  (This is the contrapositive of 1.)
3. **"Solvability is valuation-dependent"** — 16 denotations are solvable for
   one valuation and not for the other (`(0,1)` and `(1,0)` rows).  This was the
   reason for stating conservativity as *"every valuation expands to a model"*
   rather than *"some model exists"*, and it is exactly what
   `conservative_iff_exists_model` proves to be the right criterion.
4. **"Is local stratification necessary?"** — no: `tr c → tr c` has a negative
   occurrence of `c` in its own definition (so no rank can stratify it) but has
   exactly one model for each valuation.  Formalized as
   `tautDen_not_locallyStratified` / `tautDen_conservative`.

## Sequences

The trichotomy `1, 2, 0` for grounded / positive-loop / negative-loop is too
short to be an OEIS entry.  The one counting sequence that is proved here is
`2 ^ k` (models of `k` independent strange loops, `loopDen_models_ncard`),
i.e. A000079 — the point being that the *number of theorems added* stays `0`
while the number of models grows like `2 ^ k`.

## Lab notes

* First hypothesis tested was the naive Hofstadter claim "tangling is always
  free".  It is **false**: the liar loop makes the tangled theory inconsistent
  (`liar_not_conservative`), so it proves *every* old sentence.
* Second hypothesis, "positivity is the right hypothesis", survived
  enumeration and was then proved.
* Third hypothesis, "positivity is *necessary*", was killed within the
  enumeration by `tr c → tr c`; the exact criterion turned out to be
  model existence, which is what the characterization theorem states.
* The height question ("can a well-founded tangle be taller than `ω`?") was
  settled negatively by hand and then formalized as `wellFounded_iff_rank`:
  finiteness of sentences forces every name to a finite level.
