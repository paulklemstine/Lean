# Future Directions — Berggren-Tree Lattice Reduction as a Terminating Factorization Descent

## Synthesis

This cycle turned the Berggren tree on primitive Pythagorean triples from a
*search heuristic* into a *certified reduction algorithm*. The catalog already
held the two halves of the bridge: the algebraic Lorentz core
(`Algebra/BerggrenLorentz/Core.lean`: `lorentzQ`, `IsPythag`) and the executable
word actions (`Cryptography/BerggrenLatticeReduction.lean`: `actGen`,
`evalWord`, `rootTriple`, the discriminants `discX`/`discY`, freeness
`evalAtRoot_injective`, and strict height growth `tripleHeight_strict_mono`).

`Bridges/BerggrenReductionDescent.lean` welds them together. The decisive
observation is that the discriminants `discX`/`discY` from the cryptography file
secretly encode *which* generator was applied last: their sign pattern is
`A ↦ (+,−)`, `B ↦ (+,+)`, `C ↦ (−,+)`. This lets the parent of a triple be
recovered from the triple alone — no word, no oracle — so descent becomes a
genuine algorithm `reduce : Triple → BerggrenWord`, defined by structural
recursion on the hypotenuse used as fuel.

## Results summary

* **Invariant cone (geometry/algebra bridge).** `actGen_preserves_lorentzQ` and
  `invGen_preserves_lorentzQ`: generators and their inverses preserve
  `Q(a,b,c)=a²+b²−c²`. The whole search space is one Lorentz light cone.
* **Bijective generators.** `invGen_actGen`, `actGen_invGen`: each `actGen g` is
  a bijection of ℤ³ with explicit inverse `invGen g` (from `M⁻¹ = Q Mᵀ Q`).
* **Last-letter recovery.** `detectGen_actGen`: the discriminant signs recover
  the last generator applied to any good triple.
* **Descent invariant.** `root_height_minimal` (root minimality of `μ =
  tripleHeight`), `predecessor_exists` (every non-root reachable triple has a
  strictly-`μ`-smaller predecessor via an inverse step), and
  `tripleHeight_descent_wellFounded` (noetherianity).
* **Certified pipeline.** `reduce_eval` (soundness/round-trip),
  `eval_reduce` (completeness), `normalForm_unique` and `reduce_is_normalForm`
  (canonical normal form), and `reduce_evalAtRoot_bijection` (mutual inverse of
  `evalAtRoot` and `reduce` on reachable triples).
* **Quantitative bound.** `reduce_length_le`: `path_length + 5 ≤ hypotenuse`.
* **Executable certificates.** `reduce_root`, `reduce_5_12_13`,
  `reduce_15_8_17` (e.g. `reduce (5,12,13) = [A]`, `reduce (15,8,17) = [C]`).

All main results are `sorry`-free and depend only on
`propext, Classical.choice, Quot.sound`.

---

## Direction 1 — Barning–Hall surjectivity: `reduce` is a normal form for *all* primitives

**Conjecture.** Define a primitive Pythagorean triple as `(a,b,c)` with
`a,b,c > 0`, `a² + b² = c²`, `gcd(a,b)=1`, and `a` odd (the standard
orientation). Then *every* such triple is reachable: `IsReachable (a,b,c)`.
Consequently `reduce` restricted to oriented primitives is a total bijection onto
`BerggrenWord`, upgrading our reachable-only `normalForm_unique` to the entire
arithmetic universe of primitives.

The key insight is that `detectGen`/`invGen` already give a *deterministic*
parent map, so surjectivity reduces to a single closure lemma: the
discriminant-selected `invGen` step sends an oriented primitive with `c > 5`
to another oriented primitive with strictly smaller `c` (i.e. `invGen` preserves
primitivity, positivity, and orientation, not just `lorentzQ`). Combined with
`tripleHeight_descent_wellFounded` this forces termination at the unique fixed
point `(3,4,5)`.

Why now? The hard half (freeness, strict descent, parent recovery) is already
formal in this cycle; only the arithmetic preservation lemma for primitivity
under `invGen` is missing, and it is a finite gcd/parity computation well within
reach of `omega`/`decide`-style automation. This is falsifiable: if some
oriented primitive's `invGen` image fails to be primitive or positive, the
conjecture dies immediately and exposes the true generating set.

## Direction 2 — A logarithmic path-length law

**Conjecture.** There is a constant `K` with `(reduce t).length ≤ K · Nat.log2 (tripleHeight t)`
for every reachable `t`; equivalently, the hypotenuse grows at least
*geometrically* along any descent, `tripleHeight (actGen g t) ≥ ⌈φ · tripleHeight t⌉`
for some fixed ratio `φ > 1` on good triples.

The key insight is that our current `reduce_length_le` (linear, `length ≤ c − 5`)
is loose because it only uses `+1` per step from `tripleHeight_strict_mono`,
whereas the three child hypotenuses `2a±2b+3c` are each bounded below by a
fixed multiple of `c` once `a,b` are controlled by `a²+b²=c²`. Proving even a
modest multiplicative floor `c' ≥ (1+δ)c` converts the additive bound into a
genuine `O(log c)` depth theorem — matching the catalog's informal "O(log c)
tree depth" claim and turning it into a proved length bound on the *canonical*
word.

Why now? The growth inequality is a single `nlinarith` obligation over good
triples, and the logarithm packaging is standard `Nat.log` arithmetic. Both
sit directly on top of the proved `descend`/`reduce` machinery. Falsifiable: a
family of triples whose canonical word length grows faster than `log c` (e.g.
along the all-`A` or all-`C` branch) would refute it and pin down the exact rate.

## Direction 3 — Reduction transcripts as factorization certificates

**Conjecture.** The transcript `reduce (a,b,c)` deterministically produces a
divisibility/factorization decomposition of the companion quadratics
`c² − a² = b²` and `c² − b² = a²`: each generator letter corresponds to one of
Euclid's `(m,n)` parameter moves, so reading the word off recovers the unique
`(m,n)` with `m > n > 0`, `gcd(m,n)=1`, `m ≢ n (mod 2)` and
`a = m²−n², b = 2mn, c = m²+n²`. Formally: there is a length-preserving,
computable bijection between `BerggrenWord` and the Stern–Brocot/`(m,n)` path of
the triple.

The key insight is that the 3×3 Berggren action is conjugate to the classical
2×2 `SL(2,ℤ)` generators on `(m,n)` already present in the catalog
(`EML/LatticeTreeCorrespondence.lean`: `berggren_M₁'`, `berggren_M₃'` and their
inverse "subtraction/swap" steps). Our `invGen`/`detectGen` descent is the
3×3 shadow of Gauss's continued-fraction reduction on `(m,n)`; making the
conjugacy explicit lets the certified 3×3 transcript *be* a certified 2×2
factorization transcript.

Why now? Both endpoints are formalized — the 3×3 descent here and the 2×2
lattice steps in `LatticeTreeCorrespondence` — so the work is a single
intertwining lemma `π (actGen g t) = M_g · π t` for the projection
`π (a,b,c) = (m,n)`. Falsifiable: a triple whose Berggren word and `(m,n)` path
have different lengths, or disagree letter-for-letter, breaks the conjugacy.

## Direction 4 — Canonical coordinates on the integer Lorentz group O(2,1;ℤ)

**Conjecture.** The monoid generated by `actGen A,B,C` together with the
inverses `invGen` is a free product structure inside the orientation-preserving
integer Lorentz group `O⁺(2,1;ℤ)`, and `reduce` extends to a canonical
(geodesic) normal form for the *orbit* of `(3,4,5)` under the full group, with
word-metric distance equal to `|len(reduce t₁) − len(reduce t₂)|` along a common
ancestor (an explicit `lcp`-based formula, building on the catalog's
`lcpWord`/`height_ge_lcp_plus_five`).

The key insight is that `lorentzQ`-preservation (proved here for both `actGen`
and `invGen`) places the entire system inside `O(2,1;ℤ)`, so the Berggren tree
is literally a fundamental domain for a discrete Lorentz action; normal forms
are geodesics in the Cayley graph and the hypotenuse is a Busemann/horocycle
height function.

Why now? `invGen_preserves_lorentzQ` and the bijectivity lemmas already certify
the group-theoretic ambient; the remaining content is identifying relations
(or proving their absence) via the discriminant classifier `detectGen`.
Falsifiable: exhibiting a nontrivial relation among the generators, or two
distinct geodesic words for one group element, refutes freeness/canonicity.

## Direction 5 — Cryptographic hardness of oracle-free inversion

**Conjecture.** Without access to the discriminant oracle (`discX`/`discY`),
recovering `reduce t` from `t` for *scaled, non-primitive* targets `k·(a,b,c)`
or for nodes in a *forest* of multiple primitive roots is as hard as integer
factorization of `k` (resp. distinguishing which root-class a target belongs to).
The certified descent thus doubles as a trapdoor: `detectGen` is the trapdoor,
and removing it restores worst-case search.

The key insight is that `detectGen` collapses an exponential branching search
(catalog `candidateWordSet_finite`, `finite_nearby_words`) into a linear-time
unique descent; the cryptographic question is precisely *how much* the
discriminant signs reveal, i.e. whether the sign information is recoverable from
`t` alone when `t` is perturbed by an unknown scalar or embedded among several
roots.

Why now? The honest (oracle-equipped) pipeline is now fully certified, giving a
rigorous baseline against which to measure the hardness of the oracle-free
variant; the catalog's branch-and-bound pruning theorems (`prune_prepend_sound`,
`prune_excludes_candidates`) supply the exact search model to reduce from.
Falsifiable: a polynomial-time oracle-free inverter for scaled targets would
collapse the conjectured trapdoor.
