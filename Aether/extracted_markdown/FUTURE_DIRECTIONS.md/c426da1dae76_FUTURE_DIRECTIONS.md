# Beal's Conjecture — Future Directions

## Synthesis

This cycle mapped the *provability boundary* of Beal's Conjecture
(`A^x + B^y = C^z`, `x,y,z > 2` ⟹ a prime divides `A, B, C`) and discharged every
fragment that lies inside it. Two structural mechanisms turned out to be decisive.

First, **shared structure in the bases**: when the two summand bases coincide
(`A = B`), any prime factor of the common base is forced through the sum into `C`,
so Beal holds non-vacuously (`beal_equal_bases`, witnessed by `2^3 + 2^3 = 2^4` in
`beal_equal_bases_witness`). This complements the catalog's primitive reduction
(`MachineLearning.Beal.PrimitiveReduction.coprime_*_of_no_common_prime`), which
already disposes of the case where two bases share a prime.

Second, **shared structure in the exponents**: on the diagonal `x = y = z = n` the
Beal equation is literally the Fermat equation, so wherever Fermat's Last Theorem
is known the diagonal Beal case holds (vacuously). We converted Mathlib's
`fermatLastTheoremThree` and `fermatLastTheoremFour` — and, through
`FermatLastTheoremFor.mono`, the multiples `6` and `8` — into clean Beal theorems
(`beal_of_flt`, `beal_diagonal_{three,four,six,eight}`, and the unifying
`beal_diagonal_no_primitive`).

What failed, instructively, is the residue-obstruction route. The catalog's
`PrimitiveResidueSolution` records *unit* solutions in `ZMod N` and descends across
divisors (`MachineLearning.Beal.Monotonicity`). We hoped to bridge "no unit
solution mod `N`" to "no coprime integer solution", but a pairwise-coprime integer
solution does *not* reduce to a unit solution modulo an arbitrary `N`: if a prime of
`N` divides one base, that base is a non-unit residue. So a single modular
obstruction cannot settle a mixed-exponent case — precisely why Beal is open there.
No theorem in this cycle relies on the unit obstruction for that reason.

The emergent picture is a sharp trichotomy. Solutions split into (i) non-primitive
(handled by primitive reduction), (ii) primitive with equal exponents (handled by
FLT on the diagonal), and (iii) primitive with genuinely mixed exponents — the open
core, whose smallest entry is `(3,4,5)` (`beal_mixed_345`, recorded as a `Prop`).
The computational fragment (`beal_verified_box`) gives a kernel-checked certificate
inside an explicit finite box and exposes the scaling wall the next cycle should
attack.

## Results Summary

- `beal_equal_bases` — **proved**: Beal holds whenever the two summand bases coincide,
  for all positive exponents (strictly more general than the `> 2` requirement).
- `beal_equal_bases_witness` — **proved**: the equal-base case is non-vacuous
  (`2^3 + 2^3 = 2^4`).
- `beal_of_flt` — **proved**: generic adapter turning any `FermatLastTheoremFor n`
  into the diagonal Beal case `A^n + B^n = C^n`.
- `beal_diagonal_three`, `beal_diagonal_four` — **proved**: diagonal Beal for
  `(3,3,3)`, `(4,4,4)` from Mathlib's FLT.
- `beal_diagonal_six`, `beal_diagonal_eight` — **proved**: diagonal Beal for
  `(6,6,6)`, `(8,8,8)` via `FermatLastTheoremFor.mono`.
- `beal_diagonal_no_primitive` — **proved**: cross-domain bridge unifying the FLT
  diagonal with the catalog primitive reduction.
- `beal_verified_box` — **proved** (`native_decide`): every solution with bases in
  `[1,20]` and exponents in `[3,5]` has `gcd(A,B,C) > 1`.
- `beal_mixed_345` — **conjecture** (stated as a `Prop`): the smallest mixed-exponent
  triple `(3,4,5)`, the boundary of current techniques.
- `Speculative.Beal.Defs` (`BealConjecture`, `PrimitiveResidueSolution`) —
  **infrastructure**: supplied the previously-missing shared definitions, repairing
  the build of the existing `PrimitiveReduction` and `Monotonicity` catalog files.

## Research Directions

### Direction 1: Push the computational box toward base 1000
**Hypothesis.** Beal holds for all `A,B,C ≤ 1000` and `3 ≤ x,y,z ≤ 5`: every solution
in that box has `gcd(A,B,C) > 1`.
**Test.** Replace the `native_decide` brute force in `beal_verified_box` with a pruned
search — fix `(x,y,z)`, enumerate `C^z`, and binary-search `A^x` complements — then
certify the result, scaling the bounds from 20 toward 1000.
**Why now.** `beal_verified_box` already proves the statement is decidable and true on
a small box; the only obstacle is the `O(N^3·27)` cost with `N^5`-sized values, which
a complement search collapses to near `O(N^2)`.
**If true:** a reusable, kernel-checked "Beal up to N" certificate that future cycles
can cite as a base case for descent. **If false:** a counterexample would refute Beal
outright (none expected below 1000).
The key insight is that the search is *complement-bounded*: for fixed exponents each
`C^z` admits at most one matching `A^x + B^y`, so the cube of candidates is really a
near-quadratic lookup.

### Direction 2: A descent attack on the boundary case `(3,4,5)`
**Hypothesis.** `A^3 + B^4 = C^5` with `A, B` coprime has no positive solution
(`beal_mixed_345`).
**Test.** Following Darmon–Granville, treat `(3,4,5)` as a hyperbolic signature
(`1/3 + 1/4 + 1/5 < 1`) and reduce to finitely many twists of a fixed curve; as a
first Lean step, formalize the genus computation bounding the number of primitive
solutions.
**Why now.** The `beal_of_flt` pattern shows how to ingest a deep number-theory input
as a Beal case, and `(3,4,5)` is the unique smallest open triple isolated by this
cycle's trichotomy.
**If true:** the first primitive mixed-exponent Beal case in the catalog. **If false:**
a primitive counterexample, which would itself disprove Beal.
The key insight is that hyperbolic signatures `(p,q,r)` make the solution set a finite,
curve-theoretic object rather than an unbounded Diophantine search.

### Direction 3: Strengthen the equal-base case to "shared factor ⟹ shared factor"
**Hypothesis.** If `A^x + B^y = C^z` and `gcd(A,B) > 1`, then `gcd(A,B,C) > 1` for all
positive exponents (not only `> 2`).
**Test.** Generalize `beal_equal_bases` by replacing `A = B` with `gcd(A,B) = d > 1`,
extracting a prime `p ∣ d`, and pushing it through the sum exactly as in
`PrimitiveReduction.prime_dvd_pair_implies_dvd_third`.
**Why now.** `beal_equal_bases` is the `d = A = B` instance and the catalog already
proves the prime-divides-third step; merging them removes the equal-base restriction.
**If true:** collapses the entire non-primitive case of Beal to a one-line corollary
that subsumes both this cycle's equal-base result and the catalog reduction.
**If false:** would expose an exponent-sensitive bug in the divisibility step,
contradicting the catalog lemma.
The key insight is that `beal_equal_bases` never used `A = B` beyond extracting a
single shared prime, so the hypothesis weakens to `gcd(A,B) > 1` verbatim.

### Direction 4: Make the modular obstruction faithful to coprime solutions
**Hypothesis.** There is a modulus invariant — not `PrimitiveResidueSolution` but a
"at most one non-unit base" residue predicate — whose absence mod some `N` does rule
out primitive integer solutions for a fixed exponent triple.
**Test.** Define `WeakResidueSolution N x y z` allowing at most one of `a,b,c` to be a
non-unit (mirroring pairwise coprimality), reprove the `Monotonicity` descent for it,
and search for an obstructing `N` for a chosen exponent triple.
**Why now.** This cycle pinpointed exactly why the unit-based obstruction fails to
bridge to Beal; the fix is a precisely identified weakening of the unit condition.
**If true:** revives modular obstructions as a genuine Beal tool, potentially settling
mixed-exponent triples by a finite mod-`N` check. **If false:** confirms that no
congruence obstruction suffices, sharpening the case that the mixed core is global.
The key insight is that pairwise coprimality permits *one* non-unit residue per
modulus, so the obstruction object must mirror that asymmetry rather than demand three
units.

### Direction 5: Diagonal Beal for every exponent via a packaged FLT interface
**Hypothesis.** `∀ n ≥ 3, FermatLastTheoremFor n`, hence diagonal Beal holds for all
`n ≥ 3` through `beal_of_flt`.
**Test.** Track the Mathlib formalization of FLT; as `FermatLastTheoremFor n` becomes
available for general `n` (or new specific `n`), instantiate `beal_of_flt` to extend
the diagonal coverage with zero extra proof.
**Why now.** `beal_of_flt` is already a clean adapter, so the diagonal coverage is now
exactly as wide as Mathlib's FLT and grows for free on every FLT advance.
**If true:** diagonal Beal becomes a permanent corollary of FLT, leaving only the
mixed-exponent core open. **If false:** impossible for `n ≥ 3` (FLT is a theorem); the
only risk is a library gap, not a mathematical one.
The key insight is decoupling: `beal_of_flt` isolates the *only* number-theoretic
input the diagonal needs, so the Beal diagonal automatically tracks FLT forever.
