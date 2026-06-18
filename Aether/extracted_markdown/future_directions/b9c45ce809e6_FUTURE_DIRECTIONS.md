# Future Directions: Berggren Canonical Certificates

The file `Bridges/BerggrenCanonicalReduction.lean` turns the *abstract* freeness of
the positive Berggren semigroup (`evalAtRoot_injective` in
`Cryptography/BerggrenLatticeReduction.lean`) into a *constructive* certificate
pipeline: a Lorentz-discriminant classifier `classifyGen`, explicit inverse
generators `invActGen` living in `O(2,1;ℤ)`, a unique-parent reduction `reduceStep`,
and a fuel-bounded decoder `decodeWord` whose round-trip
(`decodeWord_evalAtRoot`, `canonicalWord_evalAtRoot`) is a computable left inverse of
evaluation. The bridge theorem `canonical_certificate_unique` re-proves rigidity
constructively, and `normal_form_decides_equality` packages it as a decision
procedure. The directions below extend this from the *orbit of (3,4,5)* to all
primitive triples, to quantitative complexity, and across the catalog.

## 1. Surjectivity: every primitive triple has a canonical certificate

Right now `canonicalWord` is proved to invert `evalAtRoot` only on words already in
the Berggren orbit. The classical Berggren/Barning theorem states that *every*
primitive Pythagorean triple with the usual ordering is reachable from `(3,4,5)`.
The conjecture to formalize: for every primitive `(a,b,c)` (with `a` odd, `b` even,
`gcd = 1`, `a²+b²=c²`), `reduceStep` strictly decreases `c` until it hits the root,
so `canonicalWord (a,b,c)` is a genuine certificate with
`evalAtRoot (canonicalWord (a,b,c)) = (a,b,c)`.

The key insight is that the existing descent measure `reduceStep_height_lt` is already
half of a well-founded recursion — what is missing is a *coverage* lemma showing
`reduceStep` keeps a normalized triple primitive and positive (never escaping the
cone), which can be checked entirely with the Lorentz form `invActGen_preserves_lorentzQ`
plus a primitivity-preservation lemma. Why now: descent and Lorentz-invariance are
already proved in this file, so only the cone/primitivity bookkeeping remains, making
this a finite, tractable extension rather than a new theory.

## 2. Tight certificate-length law from the hypotenuse

`canonicalWord` uses `tripleHeight t` as a (very loose) fuel bound. The conjecture:
the *exact* certificate length satisfies `(canonicalWord t).length ≤ log₂ c` with an
explicit constant, because each generator at least roughly doubles the hypotenuse
(`hyp_strictly_increases` can be sharpened to a multiplicative bound).

The key insight is that the additive descent `5 + w.length ≤ tripleHeight` proved in
the catalog can be upgraded to a *geometric* descent once one shows
`(actGen g t).2.2 ≥ 2 * t.2.2 - O(1)`, converting the linear fuel bound into a
logarithmic one. Why now: this only needs a single new inequality on the explicit
generator formulas (provable by `nlinarith` on `GoodTriple` data), and immediately
yields an `O(log c)` certificate-verification complexity statement of direct
cryptographic interest.

## 3. Certificate stability under the catalog's lattice-reduction pruning

`Cryptography/BerggrenLatticeReduction.lean` formalizes sound branch-and-bound pruning
(`prune_prepend_sound`, `prune_excludes_candidates`). The conjecture: the canonical
certificate is *stable* under these reduction operators, i.e. pruning never discards
the unique word whose certificate matches a target triple, so certificate search and
height-pruned search return identical answers.

The key insight is that `canonicalWord` is a *deterministic* left inverse, so the
candidate set of the catalog and the singleton `{canonicalWord t}` must coincide
whenever `t` is reachable — turning the catalog's finiteness/pruning results into an
exact uniqueness-of-search-output theorem. Why now: both the pruning soundness and the
round-trip inverse now exist in the same import graph, so the equivalence is a direct
combination rather than new infrastructure.

## 4. A confluent rewriting system on raw Berggren words

We proved `normalizeWord = id` because the semigroup is free, but a richer datatype
that also allows *inverse* letters (`invActGen` as formal generators) is no longer
free: words like `g g⁻¹` are redundant. The conjecture: the rewriting system that
deletes adjacent inverse pairs and reorders by the `classifyGen` branch order is
*confluent and terminating*, with unique normal forms given by `canonicalWord` of the
evaluated triple.

The key insight is that `invActGen_actGen` already supplies the only nontrivial
rewriting rule (`g⁻¹ g → ε`), and `reduceStep_height_lt` supplies the termination
measure, so confluence reduces to a finite critical-pair check on the three
generators. Why now: with both the inverse generators and the descent measure proved,
the Newman's-lemma argument has all its hypotheses available and can be attacked with
the existing `Triple` machinery.

## 5. Cross-domain: certificates as collision-free cryptographic fingerprints

`Cryptography/BerggrenFingerprintRigidity.lean` proves that a word's abelianized
generator profile is determined by its action. The conjecture: the *ordered*
canonical certificate `canonicalWord` is a strictly stronger, collision-free
fingerprint — two triples collide under `canonicalWord` iff they are equal — giving a
keyed hash whose preimage resistance is exactly the hardness of Berggren descent.

The key insight is that `canonical_certificate_unique` already establishes injectivity
of the certificate map, so the fingerprint is collision-free by construction; the
remaining work is to relate inverting `canonicalWord` to a standard lattice/descent
hardness assumption. Why now: the fingerprint-rigidity file and this certificate file
share the same generators and `evalAtRoot`, so the comparison is a concrete bridge
theorem connecting ordered certificates (here) to abelianized fingerprints (there),
rather than a speculative new primitive.
