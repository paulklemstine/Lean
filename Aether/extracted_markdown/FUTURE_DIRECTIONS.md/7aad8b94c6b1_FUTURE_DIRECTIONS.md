# FUTURE DIRECTIONS — Gravity from Information: Spacetime as a Quantum Error-Correcting Code

This research cycle built a fully verified, manifold-free combinatorial core of
the holographic principle in `Catalog/Geometry/HolographicCode/`:

* `AreaEntropy.lean` — the discrete Ryu–Takayanagi **area functional**
  `cut w A = ∑_{u∈A, v∉A} w u v`, with purity (`cut_compl`), subadditivity,
  **strong subadditivity** (`cut_submodular`), and Araki–Lieb (`cut_arakiLieb`).
* `Monogamy.lean` — the key finding `cut_tripartite_eq`: the bare boundary cut
  has **identically vanishing tripartite information** (`I₃ ≡ 0`), so it
  saturates Monogamy of Mutual Information (`cut_monogamy`).
* `MutualInformation.lean` — the information dictionary: `mutualInfo` and
  `condMutualInfo` defined from geometry, with nonnegativity = subadditivity /
  strong subadditivity (`mutualInfo_nonneg`, `condMutualInfo_nonneg`).

The single sharpest discovery is that **the fixed boundary cut is too rigid**:
it makes `I₃ = 0` exactly, whereas genuine holographic states have `I₃ < 0`.
The quantum-information content of geometry therefore lives in the *minimization*
over bulk surfaces — the entanglement-wedge / min-cut prescription. The
conjectures below are organized around closing that gap.

---

## Conjecture 1 (Strict Monogamy needs the min-cut). 

Define the **min-cut RT entropy** on a weighted graph with a distinguished
boundary `∂ ⊆ V`:
`minCut w A = ⨅ { cut w X | X ⊆ V, X ∩ ∂ = A }` (surfaces homologous to `A`).
Then `minCut` still satisfies subadditivity and strong subadditivity, **and** its
tripartite information is genuinely nonpositive:
`minCut(A)+minCut(B)+minCut(C) − minCut(A∪B) − minCut(B∪C) − minCut(A∪C) + minCut(A∪B∪C) ≤ 0`,
with *strict* inequality for some graph (a witness already exists on the
"triangle of bulk legs" graph). **Testable:** the strictness is exactly the
phenomenon absent from our `cut_tripartite_eq`.

## Conjecture 2 (Full holographic entropy cone). 

For `minCut` of Conjecture 1, *all* facet inequalities of the known holographic
entropy cone hold — in particular the 5-party HHM/cyclic inequalities that are
strictly stronger than MMI. Conversely, the *bare* `cut` satisfies every
inequality that is a consequence of submodularity **and saturates exactly those
that are linear combinations of `I₃ = 0`-type identities**. Goal: classify which
facets the fixed cut saturates versus which require minimization.

## Conjecture 3 (Complementary recovery / QEC duality). 

Model a holographic code by a bulk vertex set and a boundary `∂`, with a bulk
"operator" localized at a vertex `p`. Define `A` *recovers* `p` iff `p` lies on
the `A`-side of every minimum cut `minCut w A`. Conjecture: for a pure global
state (symmetric `w`), **exactly one** of `A`, `Aᶜ` recovers `p`
(complementary recovery), and the set of recovering regions is an up-set closed
under the min-cut "entanglement wedge." This is the discrete Knill–Laflamme /
operator-algebra QEC statement, and should follow from submodular uncrossing of
minimum cuts.

## Conjecture 4 (Discrete area law ⇒ continuum RT). 

For a sequence of graphs `G_n` discretizing a Riemannian surface with edge
weights `w_n` approximating the metric, the rescaled cut entropies
`(1/n) · cut w_n A_n` **Γ-converge** to the geometric area
`∫_{∂A} ds` of the minimal surface bounding `A`. This would derive the continuum
Ryu–Takayanagi area law as a scaling limit of the verified combinatorial
inequalities, with the entropy inequalities passing to the limit by lower
semicontinuity.

## Conjecture 5 (Cut distance and the Singleton bound). 

The functional `dist(A,B) = cut w (A △ B)` (symmetric difference) is a
pseudometric on regions, and for a code defined by the min-cut, the code
**distance** `d` (minimum weight of an undetectable boundary perturbation) and
the number `k` of protected bulk degrees of freedom obey a discrete
**quantum-Singleton-type bound** `k ≤ |∂| − 2(d − 1)` expressible purely via
`minCut`. Saturation should characterize "perfect-tensor" / maximally
holographic graphs (the HaPPY pentagon tiling).
