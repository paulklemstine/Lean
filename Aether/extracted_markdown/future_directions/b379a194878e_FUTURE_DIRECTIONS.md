# FUTURE_DIRECTIONS — Beal's Conjecture: Structure, Reduction, and Evidence

## Synthesis

This cycle attacked Beal's conjecture (`A^x + B^y = C^z` with `x,y,z > 2` and
positive `A,B,C` implies `gcd(A,B,C) > 1`) not by trying to settle the open problem,
but by isolating and *fully proving* the unconditional scaffolding that every serious
approach relies on. The central structural discovery, formalized in
`Pythagorean/BealConjecture.lean`, is the **coprimality reduction**: in any solution
of `A^x + B^y = C^z`, a prime dividing two of the three terms must divide the third
(`beal_prime_dvd_third_AB/AC/BC`), and therefore `gcd(A,B,C) = 1` forces the triple to
be *pairwise* coprime (`beal_pairwise_coprime`). This collapses the full conjecture to
its pairwise-coprime restriction — proved as a genuine logical equivalence in
`beal_full_iff_coprime`. The "engine" lemmas are mild: each summand is `≤` the total in
`ℕ`, so the subtraction `B^y = C^z − A^x` is well-defined and divisibility transfers.

A sharp by-product of the proof refactor: the three prime-transfer lemmas need *fewer*
hypotheses than first guessed. `beal_prime_dvd_third_AC` is true with `y` an arbitrary
exponent (only `x,z ≥ 1` matter), and `BC` symmetrically frees `x`. The boundary is
genuinely tight: each lemma becomes *false* if one drops the exponent positivity it does
keep (e.g. `AC` fails at `x = 0` via `3^0 + 2^1 = 3^1`). This "minimal-hypothesis"
discipline is the structural insight that should propagate to the next cycle.

On the evidence side, `beal_verified_box` exhaustively confirms there is no
counterexample for `A,B,C ≤ 100` and exponents in `{3,4,5}` — and crucially the box
*does* contain real non-coprime solutions (e.g. `3^3 + 6^3 = 3^5`), so the verification
is not vacuous. Two honest special cases close out: equal bases `A = B > 1` force a
common factor with no exponent hypothesis at all (`beal_equal_bases`), and the cube case
`x=y=z=3` is settled through Mathlib's `fermatLastTheoremThree`. The cube case is the
deepest exponent slice currently reachable precisely because it is the one with a
machine-checked FLT theorem available; the mixed-exponent Darmon–Granville range
(one exponent `3`, others `≤ 5`) is left as the headline conjecture.

## Results Summary

- `beal_prime_dvd_third_AB`: proved — a prime dividing `A` and `B` divides `C` (needs `x,y ≥ 1`).
- `beal_prime_dvd_third_AC`: proved — a prime dividing `A` and `C` divides `B`; surprisingly needs only `x,z ≥ 1`, `y` free.
- `beal_prime_dvd_third_BC`: proved — symmetric transfer; needs only `y,z ≥ 1`, `x` free.
- `beal_pairwise_coprime`: proved — `gcd(A,B,C)=1` on a solution forces pairwise coprimality (the standard reduction).
- `beal_full_iff_coprime`: proved — Beal's conjecture is logically equivalent to its pairwise-coprime restriction.
- `beal_verified_box`: proved — no counterexample for `A,B,C ≤ 100`, exponents `{3,4,5}`; box contains genuine non-coprime solutions.
- `beal_equal_bases`: proved — `A = B > 1` forces `gcd > 1` with no exponent restriction (cheapest non-vacuous slice).
- `beal_cubes`: proved — the `x=y=z=3` case, via `fermatLastTheoremThree` (no positive solution exists).
- `beal_conjecture` (`BealFull`): conjecture — the full open problem, stated, `sorry`.
- `beal_exponent_three_bounded`: conjecture — one exponent `3`, others `≤ 5` (Darmon–Granville range), stated, `sorry`.

## Research Directions

### Direction 1: Prime-power descent for the equal-bases generalization
**Hypothesis**: If `A^x + B^y = C^z` with `x,y,z > 2` and `A, B` share a common prime
`p` (not necessarily `A = B`), then `gcd(A,B,C) > 1`.
**Test**: Extend `beal_prime_dvd_third_AB`: a prime `p ∣ A` and `p ∣ B` already gives
`p ∣ C` unconditionally in `ℕ`, so prove the strictly weaker hypothesis "`A,B` not
coprime" suffices, then quotient by `p` and induct on `A + B`.
**Why now**: `beal_prime_dvd_third_AB` already proves the single-prime transfer; the
equal-bases proof (`beal_equal_bases`) is literally this argument specialized to `A = B`.
**If true**: It reduces Beal to the *pairwise-coprime* case with a one-line corollary and
generalizes `beal_equal_bases` from `A = B` to "`A, B` not coprime".
**If false**: A counterexample would be a pairwise-non-primitive solution that still has
`gcd = 1`, contradicting `beal_pairwise_coprime` — so falsity would expose a bug, making
this a strong consistency check.
The key insight is that the conjecture's conclusion is a statement purely about the
*radical* (squarefree kernel) of `A, B, C`, not their exponents.

### Direction 2: Modular obstruction sieve to enlarge the verified box
**Hypothesis**: For each fixed modulus `m`, the set of exponent/residue patterns
`(A,B,C,x,y,z) mod m` admitting `A^x + B^y ≡ C^z` with all three coprime to `m` is a
proper subset; intersecting over `m ∈ {7, 8, 9, 13}` rules out all coprime solutions with
`A,B,C ≤ 10^4`.
**Test**: Replace the `native_decide` brute force of `beal_verified_box` with a
`Decidable` predicate that first filters by residues mod a few small `m`, then checks
survivors; benchmark the bound reachable.
**Why now**: `beal_verified_box` shows `native_decide` is viable but cubic in the bound;
a sieve changes the constant dramatically and is purely combinatorial.
**If true**: Pushes machine-checked evidence from `100` toward the conjecture's folklore
`1000`-and-beyond range without new mathematics.
**If false**: Identifies the first modulus where the residue obstruction is *not*
restrictive — a concrete hint about where the conjecture's difficulty concentrates.
The key insight is that coprimality (proved automatic by `beal_pairwise_coprime`) makes
every term a unit mod small primes, so residue arithmetic is unusually rigid.

### Direction 3: The `(3, n)` slice via Fermat-type theorems in Mathlib
**Hypothesis**: `beal_exponent_three_bounded` holds at least for `y = z = 3` and for
`(y,z) = (3,4)` using existing or near-existing Mathlib FLT results.
**Test**: Mirror `beal_cubes`: locate `fermatLastTheoremFour` / catalogued FLT-`n` lemmas
and show the relevant mixed equations have no primitive solution, then combine with
`beal_pairwise_coprime` to conclude `gcd > 1`.
**Why now**: `beal_cubes` demonstrates the exact pattern — "no primitive solution ⇒ Beal
conclusion via the reduction" — and Mathlib already carries `fermatLastTheoremThree`.
**If true**: Converts part of the headline conjecture `beal_exponent_three_bounded` from
`sorry` to theorem, the first genuinely mixed-exponent case.
**If false (unreachable)**: Pinpoints exactly which small-exponent Fermat–Catalan
equations Mathlib still lacks, a precise formalization to-do list.
The key insight is that every exponent pair for which a Fermat/Catalan non-existence
theorem exists yields a Beal special case *for free* through `beal_full_iff_coprime`.

### Direction 4: Quantifying primitivity — a "Beal defect" invariant
**Hypothesis**: Define `defect(A,B,C) = gcd(A,B,C)`; for all solutions with `x,y,z > 2`
in the verified box, `defect` is always divisible by a prime `p ≤ min(A,B,C)` that also
divides the *exponent-reduced* radical, and `defect > 1` is equivalent to `radical(ABC) <
ABC` along solutions.
**Test**: Compute `defect` and `radical` for every in-box solution (extend
`beal_verified_box`'s enumeration) and check the equivalence by `decide`.
**Why now**: `beal_verified_box` already enumerates the solutions; extracting the invariant
is a small additional computation, and `beal_pairwise_coprime` gives the clean dichotomy
`defect = 1` ⟺ pairwise coprime.
**If true**: Connects Beal to the `abc`/radical circle of ideas with a checkable finite
statement, a bridge to the catalog's number-theoretic corpus.
**If false**: A solution whose common factor is "invisible" to the radical heuristic would
be a striking object worth isolating.
The key insight is that Beal is fundamentally an `abc`-type statement: the conclusion
`gcd > 1` is a lower bound on how far `ABC` is from squarefree.

### Direction 5: Pairwise-coprime non-existence as the canonical target
**Hypothesis**: `BealCoprime` (no pairwise-coprime solution with `x,y,z > 2`) is the
*right* object to formalize-and-attack, and it admits an infinite-descent skeleton: any
minimal pairwise-coprime solution yields a smaller one under a suitable height.
**Test**: State a height function `h(A,B,C) = A^x + B^y` and attempt the descent step as a
`sorry`-stubbed lemma feeding `BealCoprime`, validating the logical shape even before the
arithmetic is filled.
**Why now**: `beal_full_iff_coprime` proves that settling `BealCoprime` settles everything,
so all future effort can target the cleaner coprime statement without loss.
**If true**: Provides a reusable proof architecture (height + descent) that the next team
can populate exponent-class by exponent-class.
**If false**: A coprime solution resisting descent would localize the obstruction to a
specific height stratum.
The key insight is that `beal_full_iff_coprime` makes "WLOG pairwise coprime" a *theorem*,
not a hand-wave, so descent arguments can be carried out in the coprime category safely.
