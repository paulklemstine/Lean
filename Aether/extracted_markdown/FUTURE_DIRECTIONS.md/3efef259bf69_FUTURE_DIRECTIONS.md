# Future Directions — Isogeny-Based Cryptography (CSI-FiSh / CSIDH)

Conjectures below are stated to be *formalizable and testable* in Lean 4, building
directly on `Catalog/Cryptography/CSIFiShClassGroup.lean` (torsor model of the
class-group action) and `Catalog/Cryptography/CSIFiShAdvanced.lean`.

## C1 — Exact Cayley diameter (RESOLVED this cycle; next: general generating sets)
`zmod_cayley_diameter_exact` now proves the diameter of `ZMod n` with `{±1}` is
*exactly* `⌊n/2⌋` (`IsLeast`). **Next conjecture**: for the generating set
`{±1, ±g}` with `g` a unit of order `m`, the diameter is
`Θ(n / m + m)`, minimized near `g ≈ √n` giving diameter `Θ(√n)` — the
quantitative bridge to the `√`-step structure exploited by Kuperberg-style
attacks. Test: BFS over `n ∈ {16,25,36,49}`, `g = round(√n)`.

## C2 — Self-reducibility ⇒ uniform extractor advantage
Strengthen `gaip_self_reducible`: an oracle solving GAIP on a *positive fraction*
`ε` of instances `(g +ᵥ x₀, ·)` can be amplified, via random shifts, to solve a
*fixed worst-case* instance with success probability `≥ ε`. Conjecture: in the
finite torsor model the success set under random shift `g` has measure exactly
`ε` (shift-invariance of `connector`), giving a clean worst-case ↔ average-case
equivalence `gaip_worst_avg`.

## C3 — k-special soundness ⇒ negligible cheating mass
Generalize `multi_round_extract`: for `t` parallel rounds with binary challenges,
a prover lacking the secret can satisfy at most one challenge per round, so the
set of acceptable transcripts has relative size `≤ 2^{-t}` of all `2^t` challenge
strings. Conjecture and formalize `csifish_soundness_error t = 2^(-t)` as a
counting statement over `Fin t → Bool`.

## C4 — Torsor = unique simply-transitive model (rigidity)
Conjecture: any two free transitive `G`-actions on a finite `X` are isomorphic as
`G`-sets, and the isomorphism is unique up to the choice of base point. I.e. the
catalog's abstract `FreeTrans G X` is **categorically equivalent** to the
`AddTorsor` instance. Formalize `FreeTrans.equivTorsor` and prove the
key-space/curve-space `card` equality (`card_key_eq_card_curve`) is forced.

## C5 — Commutativity is necessary for non-interactive key agreement
Conjecture: `csidh_correct` (order independence of two parties) holds for a free
transitive action **iff** the acting group is abelian. Test the forward direction
is `add_comm`; conjecture the converse: if `a +ᵥ (b +ᵥ x₀) = b +ᵥ (a +ᵥ x₀)` for
all `a b` and one base point `x₀` in a free transitive action, then `G` is
commutative. Formalize as `csidh_correct_iff_abelian`.
