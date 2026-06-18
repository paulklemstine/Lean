# Future Directions: One-Way Functions, Amplification, and Separations

The new module `Cryptography/HardnessSeparation.lean` recasts one-wayness as a purely
combinatorial property of finite functions through their **image density**
`|Im f| / |β|` and their **collision count** `∑_y |f⁻¹(y)|²`. It proves the Yao
direct-product image identity `|Im(fᵏ)| = |Im f|ᵏ`, the multiplicativity of image
density, a strict-amplification separation under parallel repetition, a Cauchy–Schwarz
inversion lower bound, and a cross-domain separation showing lossy functions are not
one-way against a random-guess adversary. The following directions extend this frontier.

## 1. A two-sided amplification law: collision count is supermultiplicative

Conjecture: for the direct product `fᵏ`, the collision count satisfies
`collisionCount (directProduct f k) = (collisionCount f)ᵏ`, and consequently the
random-guess inversion success probability of `fᵏ` equals the `k`-th power of that of
`f`. This upgrades the one-sided `inversion_lower_bound` to an exact tensorization law.
The key insight is that fibers of a product map are products of fibers, so
`∑_{ȳ} |f⁻¹(ȳ)|² = (∑_y |f⁻¹(y)|²)ᵏ` factors coordinatewise exactly as the image count
does in `directProduct_image_card`. Why now? The pi-finset image decomposition
(`directProduct_image_eq_piFinset`) is already formalized, and the same product structure
applies verbatim to squared fiber sizes, so the proof reduces to a `Finset.prod`/`Fintype.piFinset`
computation that the existing machinery directly supports. This is the precise quantitative
core of Yao's hardness-amplification theorem and would make the OWF→stronger-OWF step of
the catalog's `CryptoLevel` lattice fully effective.

## 2. Quantitative separation between OWF and PRG via the output-gap exponent

Conjecture: define the *expansion exponent* of `f : α → β` as `log|β| / log|α|`. Then a
function whose image density is bounded below by a constant cannot have expansion exponent
exceeding `1 + o(1)`, whereas `directProduct`-amplified non-surjective functions realize an
output gap `|β|ᵏ − |Im f|ᵏ` that grows strictly faster than any fixed power of `|α|ᵏ`. This
separates "image-sparse" (OWF-like) functions from "stretching" (PRG-like) maps
quantitatively. The key insight is that `directProduct_density_strict_lt` already shows the
*relative* image shrinks geometrically, so the *absolute* uncovered mass `|β|ᵏ(1 − dᵏ)`
dominates, giving a provable gap between the two regimes. Why now? The catalog's
`prg_output_gap` and `owf_to_prg_image_gap` give the single-shot bound, and our density
multiplicativity supplies the missing exponential iteration, so the two combine into a clean
asymptotic separation statement.

## 3. Tightness of the Cauchy–Schwarz inversion bound (regular functions)

Conjecture: equality `|α|² = |Im f| · collisionCount f` holds if and only if `f` is
*regular*, i.e. all nonempty fibers have equal size `|α| / |Im f|`. Hence regular functions
are exactly the hardest to invert by random guessing at a given image size, and the bound
`randomGuess_success_ge` is tight precisely there. The key insight is that the Cauchy–Schwarz
step `sq_sum_le_card_mul_sum_sq` used in `inversion_lower_bound` is an equality iff the summed
quantities (the fiber sizes) are constant on the index set (the image). Why now? The equality
case of the discrete Cauchy–Schwarz inequality is available in Mathlib, and our proof already
isolates the exact sum it is applied to, so characterizing the extremal functions is a direct
specialization rather than new analysis. This pins down the optimal one-way candidates in the
finite model.

## 4. Hybrid composition: from per-level density bounds to end-to-end inversion security

Conjecture: chaining `n` density-preserving reductions through the `CryptoLevel` lattice, the
end-to-end random-guess inversion advantage is bounded by the product of the per-level image
densities, mirroring the multiplicative `SecurityProfile.totalDegradation` of the catalog's
`HardnessHierarchy`. The key insight is that image density is a *multiplicative monoid
homomorphism* under both direct products (proved here) and functional composition
(`Im(g ∘ f) ⊆ Im g`), so it transports through reduction chains exactly like the catalog's
degradation factors. Why now? `SecurityProfile.end_to_end_security` already formalizes the
multiplicative telescoping of degradation through a chain; replacing the abstract degradation
factor with the concrete image-density invariant turns that scaffold into a quantitative,
fully grounded composition theorem.

## 5. A combinatorial PRF lower bound via GGM tree image saturation

Conjecture: for the GGM construction `GGMTree G` from the catalog, if the underlying length
doubler `G : α → α × α` has image density `d < 1`, then the set of values reachable on depth-`t`
paths has size at most `|α| · dᵗ⁻¹`-fraction of `α`, giving an explicit collision rate and hence
a random-guess distinguishing advantage that decays geometrically in tree depth. The key insight
is that each GGM level applies `G` once, so image density composes multiplicatively down the
tree exactly as in `directProduct_density`, and the catalog's `ggm_image_bounded` provides the
ambient `|α|` ceiling that the geometric decay refines. Why now? The GGM tree and its crude
image bound are already in `HardnessHierarchy`, and our density-multiplicativity lemma is the
exact tool needed to sharpen that bound from "≤ |α|" to a quantitative decay, bridging the
PRG→PRF edge of the lattice with a concrete, falsifiable rate.
