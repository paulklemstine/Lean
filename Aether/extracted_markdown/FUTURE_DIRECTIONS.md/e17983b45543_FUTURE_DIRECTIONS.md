# Future Directions: Fermat Near-Misses in the Twilight Zone

## Synthesis

The formalization in `Catalog/Pythagorean/FermatNearMisses.lean` reframes the
study of near-misses to Fermat's Last Theorem around a single organizing object:
the **defect** `defect n a b c = aⁿ + bⁿ − cⁿ`, together with its normalization,
the **relative defect** `|defect| / cⁿ`. The central structural discovery is that
these two quantities transform differently under the multiplicative scaling action
`(a,b,c) ↦ (ta,tb,tc)`:

* the *absolute* defect carries the **weight-`n` character** `t ↦ tⁿ`
  (`defect_scale`), so a fixed nonzero defect *cannot* be propagated along a scale
  orbit — it explodes;
* the *relative* defect is the **scale invariant** of the action
  (`relative_defect_scale_invariant`), so any single bounded-relative-defect seed
  automatically generates an infinite family.

This dichotomy explains, in formal terms, two empirical facts about near-misses.
First, near-misses with a *small absolute* defect (like the celebrated
`6³ + 8³ = 9³ − 1`, verified as `famous_cube_near_miss`) are **sporadic** — they
are arithmetic accidents rather than members of scaling families. Second,
near-misses with *small relative* defect are **ubiquitous and exist for every
exponent**: the diagonal family `(a, 1, a)` realizes absolute defect exactly `1`
for all `n` (`trivial_defect_one`), with arbitrarily large entries
(`trivial_near_miss_arbitrarily_large`), and its relative defect `1/aⁿ` decays
**super-exponentially**, `≤ (1/2)ⁿ` once `a ≥ 2` (`trivial_relative_superexp_decay`).
Finally, at `n = 3` we proved the gap `±1` is *optimal*: defect `1` is attained but
defect `0` is impossible (`cube_defect_one_is_optimal`, via Mathlib's
`fermatLastTheoremThree`). This is the bridge to the catalog's
`MachineLearning/ABCTriple.lean`: a defect-`d` near-miss is precisely the additive
perturbation `aⁿ + bⁿ = cⁿ + d` whose effective control is the content of the abc
conjecture, and it extends the *exact* sum-of-cubes theory of
`Pythagorean/TaxicabNumbers.lean` to the *approximate* regime.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `defect_zero_iff` | defect `= 0` ⇔ Fermat equation | proved |
| `defect_scale` | `defect n (ta)(tb)(tc) = tⁿ · defect n a b c` | proved |
| `trivial_defect_one` | `defect n a 1 a = 1` for all `n` | proved |
| `trivial_near_miss_arbitrarily_large` | defect-1 near-misses with entries `> M`, every `n` | proved |
| `relative_defect_scale_invariant` | relative defect is scale-invariant | proved |
| `trivial_relative_superexp_decay` | relative defect of `(a,1,a)` `≤ (1/2)ⁿ` | proved |
| `famous_cube_near_miss` | `6³+8³ = 9³−1` is a genuine near-miss | proved |
| `cube_near_miss_family` | infinitely many nontrivial cube near-misses | proved |
| `no_exact_cube_solution` | no positive triple has defect 0 at `n=3` | proved (FLT₃) |
| `cube_defect_one_is_optimal` | gap `±1` attained, gap `0` impossible (cubes) | proved |

All main results are `sorry`-free and depend only on `propext`, `Classical.choice`,
and `Quot.sound`.

## Research Directions

### 1. The Super-Miss Conjecture: nontrivial relative decay for every exponent

We proved super-exponential relative decay only along the *trivial* diagonal family
`(a, 1, a)`, where one entry is pinned at `1`. The natural strengthening is that for
**every** exponent `n` there is a sequence of *fully nontrivial* triples
(`min(a,b,c) → ∞`) whose relative defect tends to `0`. The key insight is that the
trivial family achieves decay by *degenerating* one coordinate, whereas a genuine
super-miss must keep all three coordinates comparable while still beating the
generic `Θ(cⁿ)` defect of a random triple — which forces an arithmetic coincidence
that strengthens with `n`. This is falsifiable: a single proven lower bound of the
form `|aⁿ+bⁿ−cⁿ| ≥ ε·cⁿ` for all nontrivial triples at some fixed `n` would refute
it. Why now? The scaling dichotomy we formalized (`defect_scale` vs.
`relative_defect_scale_invariant`) gives, for the first time, a clean Lean-level
criterion separating "trivial" (degenerate / scale-orbit) decay from "genuine"
decay, so the conjecture can be stated precisely and attacked construction-by-construction.

### 2. Optimal gaps for higher exponents conditioned on FLT

For cubes we proved the minimal absolute gap among positive triples is exactly `1`
(`cube_defect_one_is_optimal`). The key insight is that this "gap-1 optimality"
factors into two independent ingredients — an *existence* witness (the sporadic
`6,8,9`) and a *nonexistence* theorem (FLT₃) — and the same template applies to any
exponent `n` for which both a defect-`±1` witness is known and Fermat's Last
Theorem holds. Conjecture: for every `n ≥ 3` with a known defect-`1` near-miss, the
optimal positive-triple gap is exactly `1`, conditional on `FermatLastTheoremFor n`.
This is falsifiable by exhibiting an `n` with a verified defect-`1` triple but where
the gap is provably forced larger (impossible if FLT holds) — i.e. it tests the
witness-search side. Why now? Mathlib already provides `fermatLastTheoremFour` and
the general `FermatLastTheoremFor`/`FermatLastTheoremWith` API, so the nonexistence
half is available *today* for `n = 4` (and as a hypothesis for general `n`), and our
`defect`/`IsNearMiss` scaffolding makes the existence half a finite `decide` search.

### 3. Catalan-type isolation: gaps of size ±1 are arithmetically rigid

Mihăilescu's theorem (Catalan) says `8` and `9` are the only consecutive perfect
powers. Recast through the defect, this says the *pure* near-miss `defect with b
absent`, `aᵐ − cⁿ = ±1`, is essentially unique. The key insight is that our
defect formalism unifies the two-term Catalan equation and the three-term Fermat
near-miss under one signed invariant, suggesting a "three-term Catalan" question:
are defect-`±1` triples `aⁿ + bⁿ = cⁿ ± 1` (all entries `> 1`) finite for each fixed
`n ≥ 3`? This is sharply falsifiable — a single parametric family of nontrivial
defect-`±1` cube triples would refute finiteness for `n = 3`. Why now? The catalog's
`TaxicabNumbers.lean` already formalizes the rigidity of *exact* two-cube
representations (`same_sum_implies_same_pair`); porting that injectivity machinery
to the `±1`-perturbed setting is a concrete next formal step.

### 4. Effective abc ⇒ effective near-miss density bounds

The catalog's `ABCTriple.lean` proves `abc_implies_asymptotic_FLT` from a discrete
abc formulation. The key insight is that a near-miss `aⁿ + bⁿ = cⁿ + d` *is* an abc
triple `(aⁿ, bⁿ, cⁿ+d)` (up to the perturbation `d`), so an *effective* abc bound
translates directly into an explicit upper bound on the number of near-misses with
`c ≤ B` and `|d| ≤ δ` — and that bound should decay super-exponentially in `n`,
matching the relative-decay phenomenon we proved for the diagonal family.
Conjecture: under `ABCConjectureDiscrete`, the count of nontrivial near-misses in
the box `[1,B]³` with `n ≥ 4` and `|defect| ≤ δ` is `O_δ(B^{3−n+o(1)})`. This is
falsifiable by an unconditional lower bound exceeding the predicted count. Why now?
Both halves already exist in this repository — `ABCConjectureDiscrete` (as a `Prop`
to assume) and our computable `defectN` with `#eval`/`decide` counting — so the
implication can be stated and partially discharged without any new imports.

### 5. The relative defect as a height: a dynamical/heights reformulation

Because the relative defect is the exact scale invariant of the `t`-action
(`relative_defect_scale_invariant`), it behaves like a **projective height** on the
Fermat surface `Xⁿ + Yⁿ = Zⁿ` in `ℙ²`. The key insight is that "near-miss quality"
is then a height function, and the distribution of near-misses becomes a question
about height-counting (à la Manin–Batyrev) on a smooth projective variety. Concrete
falsifiable prediction: the number of primitive triples with relative defect `< ε`
and `max(a,b,c) ≤ B` grows like `c(ε)·B^{κ}` for an exponent `κ = κ(n)` independent
of `ε`, with `κ(n)` decreasing in `n`. A measured growth rate depending on `ε`
would falsify the height interpretation. Why now? Mathlib's projective-space and
height infrastructure has matured enough to *state* such counting functions
formally, and our scale-invariance theorem supplies the precise invariant on which
any height-theoretic treatment must be built.
