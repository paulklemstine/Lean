# Future Directions — Model Theory ⟷ Algebra Bridge (Ax–Kochen & Morley)

The file `Catalog/Bridges/AxKochenMorleyBridge.lean` installs the ultraproduct
transfer engine behind the Ax–Kochen–Ershov theorem (via Łoś's theorem) and a
fully proved Łoś–Vaught categoricity test, extending the catalog's
`Bridges.ModelTheoryBridge`. The directions below are concrete, falsifiable next
steps that build on exactly these results.

## 1. Henselian valued fields as a multi-sorted language, and the AKE input lemma

Formalize the three-sorted language of valued fields (field sort, value-group
sort, residue-field sort with the place map) and prove the *input* hypothesis of
`ultraproduct_ee_of_eventually`: if residue fields are elementarily equivalent
and value groups are elementarily equivalent, then the henselian valued fields
are componentwise elementarily equivalent. Combined with the existing
`axKochen_almost_all_transfer`, this would yield a machine-checked Ax–Kochen
theorem for the family `ℚ_p`.

The key insight is that `ultraproduct_ee_of_eventually` already discharges the
*hard analytic half* (the ultraproduct/Łoś step), so the remaining work is the
purely syntactic relative quantifier-elimination of henselian fields down to the
residue field and value group — a finite, checkable reduction rather than an
ultrafilter argument. Why now? Mathlib has gained `Valued`, henselian-field, and
`ModelTheory.Ultraproducts` infrastructure, so the language and place map can be
declared without inventing new foundations.

## 2. Effective bound on the Artin-conjecture exceptional set

Ax–Kochen famously implies that for each degree `d`, every homogeneous form of
degree `d` in more than `d²` variables over `ℚ_p` has a nontrivial zero for all
but finitely many `p`. Formalize this exceptional-set statement as a corollary of
`axKochen_almost_all_transfer` applied to the sentence "every degree-`d` form in
`d²+1` variables has a nontrivial zero", transferred from the function-field side
`𝔽_p((t))` where it is true for all `p`.

The key insight is that the "for all but finitely many `p`" quantifier in
Ax–Kochen is *exactly* the cofinite filter, so phrasing the corollary over the
hyperfilter (the cofinite ultrafilter on primes) makes it a direct instance of
the already-proved transfer, with no new model theory required. Why now? The
transfer lemma is in hand and the function-field truth is an elementary
Chevalley–Warning count already formalizable in Mathlib.

## 3. Keisler–Shelah from the ultraproduct transfer

Prove the easy direction of the Keisler–Shelah isomorphism theorem in the form
already reachable here: if `M ≅[L] N` then for a suitable ultrafilter the
ultrapowers `∏ᵤ M` and `∏ᵤ N` are elementarily equivalent, by feeding the
constant families into `ultraproduct_ee_of_forall`. Then attempt the genuine
isomorphism (not just equivalence) of ultrapowers for countable structures.

The key insight is that elementary equivalence is *preserved* by ultrapowers for
free from our lemma, so the only remaining content is upgrading equivalence to
isomorphism, isolating precisely where saturation (not Łoś) is needed. Why now?
The equivalence half is a one-line corollary of the new file, cleanly separating
the trivial part from the part that needs `ℵ₁`-saturation.

## 4. Łoś–Vaught without the uniform-cardinality hypothesis

`losVaught_isComplete` currently assumes *every* model has cardinality κ. Replace
this with the standard hypothesis "`T` has no finite models and is κ-categorical
for some `κ ≥ |L| + ℵ₀`", deriving the uniform-cardinality conclusion from the
Löwenheim–Skolem theorems (`ModelTheory.Skolem`).

The key insight is that downward and upward Löwenheim–Skolem turn "categorical at
one large κ" into "all infinite models are pairwise elementarily equivalent",
which is exactly the hypothesis our catalog lemma `isComplete_of_allModels_ee`
consumes — so the test reduces to two cardinal-arithmetic transport lemmas. Why
now? Mathlib's `ModelTheory.Skolem` provides elementary substructures of
controlled cardinality, the one missing ingredient.

## 5. Morley rank and the totally-transcendental core of Morley's theorem

Discharge the `sorry` in `morley_categoricity` by building Morley rank for
definable sets: define `RM(φ) : Ordinal∞`, prove it is monotone and additive over
Boolean combinations, and show ω-stability forces every formula to have ordinal
Morley rank. This is the genuine engine of Morley's categoricity theorem.

The key insight is that uncountable categoricity is equivalent to "ω-stable +
no Vaughtian pair", and ω-stability is detectable as *finiteness of Morley rank*,
turning a statement about all uncountable cardinals into a single ordinal-valued
dimension that transfers between cardinals. Why now? The conjecture is already
stated and type-checks in the project; isolating Morley rank as a standalone
`Ordinal`-valued invariant makes the remaining proof a sequence of finite
rank-calculus lemmas rather than one monolithic argument.
