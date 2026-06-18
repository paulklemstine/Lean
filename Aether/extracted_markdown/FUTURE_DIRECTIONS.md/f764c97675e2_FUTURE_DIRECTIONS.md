# Future Directions: The Prime Gap Crossword

The file `Crossword.lean` establishes the *forcing layer* of the prime gap
crossword: it proves that an inadmissible constellation of offsets
(`inadmissible_eventually_composite`, `inadmissible_forcing`) can never be
all-prime past its witnessing prime, recovers the classical "only prime triplet
is `(3,5,7)`" (`prime_triplet_unique`) as a one-line corollary of the catalog's
inadmissibility witness `not_admissible_0_2_4`, and pins down the parity and
residue lanes of the crossword (`gap_even`, `odd_gap_unique`, `prime_mod_six`).
These are the *deterministic rules* of the puzzle. What remains is to quantify
how strongly the rules constrain the solution. Below are five concrete,
falsifiable directions that extend this work.

## 1. A general "covering radius" forcing theorem

The current bridge fires once a single prime `p` covers all residue classes of
`H`. The natural generalization is quantitative: for an inadmissible `H` with
witnessing prime `p`, *what fraction* of the offsets `n + h` are forced composite
at a given `n`, and how does that fraction grow as more small primes partially
cover `H`? Conjecture: if the primes `p_1 < ... < p_k` jointly cover `H` (no
single one suffices), then for every `n` at least `k` of the entries `n + h` are
composite, and this bound is sharp.

The key insight is that admissibility is not a binary switch but a *graded*
obstruction: each prime removes a slice of the residue torus, and the forcing
strength is the total measure removed. **Why now?** The catalog already contains
the decidable admissibility machinery (`admissible_iff_bounded`) and this file
turns the binary version into a theorem; the graded version is the immediate,
provable refinement that connects to sieve weights.

## 2. Density of cousin-forcing positions

`cousin_forces_composite` shows that for `n > 3` prime with `n + 4` prime, the
middle `n + 2` is *forced* composite by divisibility by `3`. Conjecture: the set
of `n ≤ N` at which a mod-3 forcing event occurs (i.e. exactly one of
`n, n+2, n+4` is killed by `3`) has natural density `2/3`, and more generally the
mod-`q` forcing events partition the integers with the predicted densities
`(q-1)/q` minus overlaps.

The key insight is that forcing events are *exactly the complement of the
admissible residue classes*, so their density is computable by inclusion–exclusion
over small primes — no unproven analytic input is needed for the lower bound.
**Why now?** Density of a fixed residue condition is provable in Lean today with
`Nat.count`/`Finset.filter` cardinalities; this turns the informal "positive
density of forcing patterns" claim into a finite, certifiable statement.

## 3. Forcing chains and the longest deterministic run

Iterating the local rules (`twin_forces_composite`, `cousin_forces_composite`)
produces *chains*: a twin pair forbids gap `2` next, which combined with the
residue law forbids further patterns. Conjecture: define a gap word to be
*forcing* if the admissible-tuple constraint admits a unique continuation; then
forcing words of every finite length occur, and the count of forcing words of
length `k` grows like `C^k` for an explicit constant `C < 2` strictly below the
naive `2^k`.

The key insight is that the crossword's local rules are a *subshift of finite
type* on the alphabet of residues mod a primorial, so its complexity is governed
by the spectral radius of an explicit transfer matrix. **Why now?** The transfer
matrix is finite and integer, so its characteristic polynomial — and hence `C` —
is exactly computable and verifiable in Lean via `Matrix.charpoly`, linking this
file to the catalog's `CharpolyRecognition` work.

## 4. The admissibility–Hardy–Littlewood bridge as an inequality

The Hardy–Littlewood prediction for the density of a gap `g` is
`2 C_2 / g · (1/\log p) · \prod_{q \mid g} (q-1)/(q-2)`. Conjecture (one-sided,
provable form): for every admissible `H`, the singular series `\mathfrak{S}(H)`
is strictly positive and bounded below by an explicit product over primes
`p \le |H|`, with `\mathfrak{S}(H) = 0` *iff* `H` is inadmissible — exactly the
dichotomy proven qualitatively here.

The key insight is that `inadmissible_forcing` is the *vanishing* half of this
equivalence; the missing half is a positive lower bound on the local factors,
which is a finite product and therefore elementary. **Why now?** Proving
`\mathfrak{S}(H) > 0 ↔ Admissible H` requires no progress on the (open) twin
prime conjecture — it is a statement about the local factors alone, and the
local factors are precisely what the catalog's admissibility checker computes.

## 5. Minimal inadmissible constellations and excluded patterns

`triplet_offsets_inadmissible` identifies `{0,2,4}` as inadmissible. Conjecture:
the minimal inadmissible constellations (inadmissible, but every proper subset
admissible) are exactly characterized by a finite *excluded-pattern* list for
each prime `p`, and the number of minimal inadmissible sets inside `{0,...,m}`
grows polynomially in `m` for fixed covering prime, exponentially when the prime
is allowed to grow.

The key insight is a duality with matroid excluded minors: "minimal
inadmissible" is a minor-closed obstruction in the lattice of offset sets,
mirroring the catalog's `Novelty/Structural.lean` excluded-minor theory.
**Why now?** Both the admissibility predicate (decidable, in the catalog) and
the excluded-minor framework (in `Novelty`) already exist, so the cross-domain
bridge is assemblable from proven components rather than built from scratch.
