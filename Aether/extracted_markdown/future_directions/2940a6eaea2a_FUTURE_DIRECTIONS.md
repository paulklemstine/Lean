# Future Directions: The Boltzmann Bridge III — From Stable Filtrations to Persistence Modules

The new file `PersistenceStability.lean` closes the gap between the catalog's
combinatorial persistence machinery (`HigherPersistence.lean`: `ASC`,
`Filtration`, the Vietoris–Rips construction, `euler_char_full_simplex`) and the
*robustness* theory that makes persistent homology usable on noisy data. We now
have, fully formalized and `sorry`-free:

* functoriality of the inclusion preorder `ASC.Sub` (`Sub_refl`, `Sub_trans`)
  and the connecting maps of the sublevel persistence module
  (`sublevelComplex_sub`);
* the algebraic stability theorem as a δ-interleaving of sublevel families
  (`stability_interleaving`), its additive composition law / triangle inequality
  (`stability_compose`), and the symmetric two-sided form
  (`stability_two_sided`);
* lattice compatibility of sublevel/Vietoris–Rips complexes with `min`
  (`sublevelFaces_min`, `VRfaces_min`).

These results turn the filtration calculus into a genuine functor and equip the
space of filtrations with a sub-additive interleaving pseudometric. The natural
next cycles push toward an honest *interleaving distance*, the Euler-characteristic
curve as a stable signature, and the metric-to-combinatorics dictionary.

---

## Direction 1 — The interleaving pseudometric is a genuine pseudometric

`stability_compose` is exactly the triangle inequality, and
`stability_two_sided` gives symmetry, for the candidate distance
`d(F, G) = sInf { δ ≥ 0 | ∀ σ, |F.weight σ − G.weight σ| ≤ δ }`. Define this
quantity (`Filtration.interleavingDist`) as `⨆ σ, |F.weight σ − G.weight σ|` (a
weighted sup-metric, finite on bounded-difference filtrations) and prove it is a
pseudometric: `d F F = 0`, `d F G = d G F`, and `d F H ≤ d F G + d G H`, with the
stability theorems as the bridge to the topological interleaving.

**The key insight is** that the *additivity of interleavings* already proved
(`stability_compose`) is the triangle inequality of the sup-metric in disguise —
so the metric axioms reduce to elementary facts about `⨆` of absolute values,
not to any homological computation.

**Why now?** With `stability_interleaving` and `stability_compose` in hand, the
remaining obligations are pure order/`iSup` lemmas already in Mathlib
(`Real.iSup_le`, `abs_sub_comm`, `csSup`/`ciSup` API); no new persistence theory
is required, making this an immediately tractable, high-value cycle.

## Direction 2 — A stable Euler-characteristic curve

Generalize `euler_char_full_simplex` from the full simplex to an arbitrary
*finite* complex `K` by defining `eulerChar K = ∑_σ (−1)^(card σ − 1)` over the
nonempty faces, then define the **Euler curve** `t ↦ eulerChar (F.sublevelComplex t)`
of a filtration. Prove (a) it is a right-continuous step function with finitely
many jumps for finitely supported filtrations, and (b) a stability bound: if
`d(F, G) ≤ δ` then the Euler curves agree outside a set of measure `≤ 2δ ·
(number of faces)`.

**The key insight is** that the Euler characteristic is *additive* over the
filtration's birth events, so the Euler curve changes only at the finitely many
weights `{F.weight σ}` — turning a topological invariant into a piecewise-constant
function whose stability is controlled face-by-face by `stability_two_sided`.

**Why now?** `euler_char_full_simplex` already supplies the alternating-sum
backbone, and `sublevelFaces_min` lets us decompose complexes along `min`; the
Euler curve is the simplest *numerical* persistence summary, so it is the natural
first invariant to certify stable before tackling barcodes.

## Direction 3 — Metric stability of the Vietoris–Rips diameter weight

Lift `stability_two_sided` from abstract weights to geometry: if two pseudometrics
`d, d'` on a common finite vertex set satisfy `|d x y − d' x y| ≤ δ` pointwise,
then their diameter weights satisfy `|diamWeight_d σ − diamWeight_{d'} σ| ≤ δ`
for every simplex, hence the VR filtrations are δ-interleaved. This is the
geometric incarnation of stability and the precise statement underlying
"Gromov–Hausdorff close data have close persistence."

**The key insight is** that `diamWeight` is a `sup'` of pairwise distances, and
`sup'` is 1-Lipschitz in its entries, so a uniform `δ`-perturbation of the
distances perturbs the `sup'` by at most `δ` — reducing geometric stability to
the order lemma `Finset.sup'_le`/`Finset.le_sup'` already used in
`diamFiltration`.

**Why now?** The diameter weight and its monotonicity are already built in
`HigherPersistence.lean`; the only new ingredient is a Lipschitz bound for
`sup'`, after which `stability_two_sided` discharges the rest verbatim, giving a
clean cross-over from combinatorics to metric geometry.

## Direction 4 — Nerve-style gluing and a Mayer–Vietoris Euler identity

The lattice law `sublevelFaces_min` (intersection) has a missing partner: the
`max`/union law `F.sublevelFaces (max t₁ t₂) = sublevelFaces t₁ ∪ sublevelFaces t₂`
fails in general but holds for the *pointwise-max* of two filtrations. Formalize
the union complex `K ⊔ L`, prove `eulerChar (K ⊔ L) = eulerChar K + eulerChar L −
eulerChar (K ⊓ L)` (inclusion–exclusion / combinatorial Mayer–Vietoris), and use
`sublevelFaces_min` to identify `K ⊓ L` with a single sublevel set.

**The key insight is** that on finite complexes the Euler characteristic is a
*valuation* (finitely additive on the lattice of subcomplexes), so the
Mayer–Vietoris identity is inclusion–exclusion for the counting measure
`σ ↦ (−1)^(card σ − 1)`, with `sublevelFaces_min` supplying the meet term for free.

**Why now?** We already have the intersection law and a worked Euler-characteristic
computation; adding the join and the valuation identity completes the lattice
picture and is the algebraic prerequisite for any future homological
Mayer–Vietoris sequence in the catalog.

## Direction 5 — Persistence modules as functors `(ℝ, ≤) ⥤ ASC`

Package the data `t ↦ F.sublevelComplex t` together with `sublevelComplex_sub`
into a genuine `CategoryTheory` functor from the thin category `(ℝ≥0, ≤)` to the
category of abstract simplicial complexes with `ASC.Sub`-morphisms (a thin
category by `Sub_refl`/`Sub_trans`). Prove that δ-interleaving of two such
functors, in the categorical sense (a pair of natural transformations whose
composites are the structure maps), is *equivalent* to the weight bound
`|F.weight − G.weight| ≤ δ`, tying `stability_two_sided` to the standard
definition of interleaving.

**The key insight is** that `ASC.Sub` is already a preorder (`Sub_refl`,
`Sub_trans`), so the target is automatically a (thin) category and the sublevel
assignment is automatically functorial via `sublevelComplex_sub` — the
persistence module exists "for free," and stability becomes a statement about
natural transformations rather than raw set inclusions.

**Why now?** The catalog contains substantial `CategoryTheory` infrastructure,
and the two preorder lemmas proved here are precisely the hypotheses needed to
instantiate a functor; connecting persistence to that infrastructure is the
highest-leverage cross-domain bridge currently available, and unlocks importing
Mathlib's categorical machinery (limits, Kan extensions) into persistence theory.
