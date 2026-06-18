# FUTURE_DIRECTIONS — Beal's Conjecture: Structure, Reduction, and Evidence

## Synthesis

This cycle attacked Beal's conjecture (`A^x + B^y = C^z` with `x,y,z > 2` and
positive `A,B,C` implies `gcd(A,B,C) > 1`) not by trying to settle the open problem,
but by isolating and *fully proving* the unconditional scaffolding that every serious
approach relies on. The central structural result, formalized in
`Catalog/Pythagorean/BealConjecture.lean`, is the **coprimality reduction**: in any
solution of `A^x + B^y = C^z`, a prime dividing two of the three terms must divide
the third (`beal_prime_dvd_third_AB/AC/BC`), and therefore `gcd(A,B,C) = 1` forces the
triple to be *pairwise* coprime (`beal_pairwise_coprime`). This collapses the full
conjecture to its pairwise-coprime restriction — proved as a genuine logical
equivalence `BealFull ↔ BealCoprime` in `beal_full_iff_coprime`. The "engine" lemmas
are mild: in `ℕ` each summand is `≤` the total, so `B^y = C^z − A^x` is well-defined
(`beal_le_AB`, `beal_sub_AB`) and divisibility transfers cleanly.

A sharp by-product of the proof refactor is a tight **minimal-hypothesis** boundary
for the three transfer lemmas: each needs only the two exponents attached to the
terms the prime *divides*, leaving the *target* exponent entirely free. Concretely
`beal_prime_dvd_third_AB` frees `z` (needs `x,y ≥ 1`), `AC` frees `y` (needs
`x,z ≥ 1`), and `BC` frees `x` (needs `y,z ≥ 1`). The free exponent is explained by a
hidden vacuity: dropping its positivity forces the prime to divide `1`, so the
degenerate slice is contradictory and the conclusion holds for free. This discipline
is the structural insight that should propagate to the next cycle.

On the evidence side, `beal_verified_box` exhaustively confirms (`native_decide`) that
there is no counterexample for `A,B,C ≤ 50` and exponents in `{3,4,5}` — and crucially
the box *does* contain real non-coprime solutions (`beal_box_nonvacuous`:
`3^3 + 6^3 = 3^5`), so the verification is not vacuous. Two honest special cases close
out: equal bases `A = B > 1` force a common factor needing only `x,y ≥ 1`
(`beal_equal_bases`), and the cube case `x=y=z=3` is settled through Mathlib's
`fermatLastTheoremThree` (`beal_cubes`). The cube case is the deepest exponent slice
currently reachable precisely because it is the one with a machine-checked FLT theorem
available.

## Results Summary

- `beal_le_AB`, `beal_sub_AB` — the `ℕ`-subtraction engine: `A^x ≤ C^z` and
  `C^z − A^x = B^y`.
- `beal_prime_dvd_third_AB` — a prime dividing `A` and `B` divides `C` (needs `x,y ≥ 1`).
- `beal_prime_dvd_third_AC` — a prime dividing `A` and `C` divides `B`; needs only
  `x,z ≥ 1` (`y` free).
- `beal_prime_dvd_third_BC` — symmetric transfer; needs only `y,z ≥ 1` (`x` free).
- `beal_pairwise_coprime` — `gcd(A,B,C)=1` on a solution forces pairwise coprimality.
- `beal_full_iff_coprime` — Beal's conjecture (`BealFull`) is logically equivalent to
  its pairwise-coprime restriction (`BealCoprime`).
- `beal_verified_box` — no counterexample for `A,B,C ≤ 50`, exponents `{3,4,5}`.
- `beal_box_nonvacuous` — the box contains a genuine non-coprime solution.
- `beal_equal_bases` — `A = B > 1` forces `gcd > 1` (needs only `x,y ≥ 1`).
- `beal_cubes` — the `x=y=z=3` case, via `fermatLastTheoremThree`.

The open problem itself is recorded as the statement `BealFull : Prop` (and its clean
equivalent `BealCoprime : Prop`); these are *definitions*, so the file carries no
`sorry` and no axioms beyond `propext, Classical.choice, Quot.sound` (plus
`Lean.ofReduceBool, Lean.trustCompiler` for the `native_decide` box).

## Research Directions

### Direction 1: Prime-power descent for the not-coprime generalization
**Hypothesis.** If `A^x + B^y = C^z` with `x,y,z > 2` and `A, B` share a common prime
`p` (not necessarily `A = B`), then `gcd(A,B,C) > 1`.
**Test.** Extend `beal_prime_dvd_third_AB`: a prime `p ∣ A` and `p ∣ B` already gives
`p ∣ C` unconditionally in `ℕ`, so prove the strictly weaker hypothesis "`A,B` not
coprime" suffices, then quotient by `p` and induct on `A + B`.
**Why now?** `beal_prime_dvd_third_AB` already proves the single-prime transfer, and
`beal_equal_bases` is literally this argument specialized to `A = B`; the inductive
shell is all that is missing.
**If true.** It generalizes `beal_equal_bases` from `A = B` to "`A, B` not coprime"
and reduces Beal to the pairwise-coprime case with a one-line corollary.
**If false.** A counterexample would be a pairwise-non-primitive solution that still
has `gcd = 1`, contradicting `beal_pairwise_coprime` — so falsity would expose a bug,
making this a strong consistency check.
The key insight is that the conjecture's conclusion is a statement purely about the
*radical* (squarefree kernel) of `A, B, C`, not about their exponents.

### Direction 2: Modular obstruction sieve to enlarge the verified box
**Hypothesis.** For each fixed modulus `m`, the set of residue patterns
`(A,B,C,x,y,z) mod m` admitting `A^x + B^y ≡ C^z` with all three coprime to `m` is a
proper subset; intersecting over `m ∈ {7, 8, 9, 13}` rules out all coprime solutions
with `A,B,C ≤ 10^4`.
**Test.** Replace the `native_decide` brute force of `beal_verified_box` with a
`Decidable` predicate that first filters by residues mod a few small `m`, then checks
survivors; benchmark the reachable bound.
**Why now?** `beal_verified_box` shows `native_decide` is viable but cubic in the
bound; a residue sieve changes the constant dramatically and is purely combinatorial.
**If true.** Pushes machine-checked evidence from `50` toward the folklore
`1000`-and-beyond range with no new mathematics.
**If false.** Identifies the first modulus where the residue obstruction is *not*
restrictive — a concrete hint about where the conjecture's difficulty concentrates.
The key insight is that coprimality (made automatic by `beal_pairwise_coprime`) turns
every term into a unit mod small primes, so residue arithmetic is unusually rigid.

### Direction 3: The `(3, n)` slice via Fermat-type theorems in Mathlib
**Hypothesis.** A first genuinely mixed-exponent Beal case is reachable now: for
`(x,y,z)` containing one `3` and the others a value `n` for which Mathlib has a
Fermat/Catalan non-existence theorem (e.g. `fermatLastTheoremFour`), the equation has
no primitive solution, hence `gcd > 1`.
**Test.** Mirror `beal_cubes`: locate the relevant FLT-`n` lemma, show the mixed
equation has no primitive solution, then combine with `beal_pairwise_coprime` to
conclude `gcd > 1`.
**Why now?** `beal_cubes` demonstrates the exact pattern — "no primitive solution ⇒
Beal conclusion via the reduction" — and Mathlib already carries `fermatLastTheoremThree`.
**If true.** Converts a first mixed-exponent slice from an open statement into a
theorem.
**If false (unreachable).** Pinpoints exactly which small-exponent Fermat–Catalan
equations Mathlib still lacks — a precise formalization to-do list.
The key insight is that every exponent pattern for which a Fermat/Catalan
non-existence theorem exists yields a Beal special case *for free* through
`beal_full_iff_coprime`.

### Direction 4: Quantifying primitivity — a "Beal defect" invariant
**Hypothesis.** Define `defect(A,B,C) = gcd(A,B,C)`; for all solutions with `x,y,z > 2`
in the verified box, `defect > 1` is equivalent to `radical(A·B·C) < A·B·C` along
solutions (i.e. the common factor is exactly the failure of squarefreeness).
**Test.** Compute `defect` and `radical` for every in-box solution (extend the
enumeration behind `beal_verified_box`) and check the equivalence by `decide`.
**Why now?** `beal_verified_box` already enumerates the solutions; extracting the
invariant is a small additional computation, and `beal_pairwise_coprime` gives the
clean dichotomy `defect = 1` ⟺ pairwise coprime.
**If true.** Connects Beal to the `abc`/radical circle of ideas with a checkable
finite statement — a bridge to the catalog's number-theoretic corpus.
**If false.** A solution whose common factor is "invisible" to the radical heuristic
would be a striking object worth isolating.
The key insight is that Beal is fundamentally an `abc`-type statement: the conclusion
`gcd > 1` is a lower bound on how far `A·B·C` is from squarefree.

### Direction 5: Pairwise-coprime non-existence as the canonical descent target
**Hypothesis.** `BealCoprime` is the *right* object to formalize-and-attack, and it
admits an infinite-descent skeleton: any minimal pairwise-coprime solution yields a
smaller one under a suitable height.
**Test.** State a height function `h(A,B,C,x,y,z) = A^x + B^y` and attempt the descent
step as a `sorry`-stubbed lemma feeding `BealCoprime`, validating the logical shape
before the arithmetic is filled.
**Why now?** `beal_full_iff_coprime` proves that settling `BealCoprime` settles
everything, so all future effort can target the cleaner coprime statement without loss.
**If true.** Provides a reusable proof architecture (height + descent) that the next
team can populate exponent-class by exponent-class.
**If false.** A coprime solution resisting descent would localize the obstruction to a
specific height stratum.
The key insight is that `beal_full_iff_coprime` makes "WLOG pairwise coprime" a
*theorem*, not a hand-wave, so descent arguments can be carried out in the coprime
category safely.
