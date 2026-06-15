# Future Directions

Follow-up conjectures arising from
`Catalog/Bridges/TropicalValuationPersistence.lean` ("Categorical tropicalization of
valuation-depth sublevel filtrations into persistence modules"). Each is stated to be
*falsifiable* and *Lean-formalizable* in the next cycle.

The current cycle established, fully proved (0 sorries):

- the sublevel filtration of a valuation `v : X → ℝ` is a persistence module
  (`PersMod`, `sublevel_mono`, `sublevelPM`);
- entrance-time recovery `IsGLB {t | x ∈ sublevel v t} (v x)` (`valuation_isGLB_entrance`);
- categorical tropicalization `min ↦ ∪`, `max ↦ ∩` (`sublevel_min`, `sublevel_max`);
- interleaving is an extended pseudometric (`Interleaved.symm/.trans/.mono_shift`,
  `interleaved_zero_self`) and the stability theorem `sublevel_stability`;
- ultrametric ball nesting (`ultrametric_sublevel_nested`) and non-archimedean additive
  closure of sublevels, instantiated p-adically (`sublevel_add_closed`,
  `padicNorm_sublevel_add_closed`).

---

## Conjecture 1 — Lattice-homomorphism upgrade of tropicalization

The current `sublevel_min`/`sublevel_max` are pointwise. **Conjecture:** the map
`v ↦ sublevelPM v` is a *complete-lattice homomorphism* from the function lattice
`(X → ℝ, ⊓, ⊔)` (pointwise inf/sup) to the lattice of persistence modules, i.e. it
commutes with **arbitrary** indexed infima and suprema:
`sublevel (⨅ i, v i) t = ⋂ i, sublevel (v i) t` is **false in general** (inf over an
infinite family need not be attained), but `sublevel (⨆ i, v i) t = ⋂ i, sublevel (v i) t`
holds, and `⋃ i, sublevel (v i) t ⊆ sublevel (⨅ i, v i) t` with equality iff each pointwise
infimum is attained. Formalize the exact attainment criterion (e.g. for `Finite` index, or
for lower-semicontinuous `v i` on a compact space).

## Conjecture 2 — Interleaving distance is exactly the sup-distance (tightness)

`sublevel_stability` gives `interleaving ≤ sup-distance`. **Conjecture:** for the sublevel
model the bound is *tight*: define `interleavingDist M N = sInf {δ ≥ 0 | Interleaved δ M N}`;
then for valuations `v, w` with `‖v - w‖_∞ < ∞`,
`interleavingDist (sublevelPM v) (sublevelPM w) = ‖v - w‖_∞`.
The `≤` direction is `sublevel_stability`; the `≥` direction should follow from
entrance-time recovery (Conjecture-1-style): an interleaving forces `|v x - w x| ≤ δ` at the
entrance time of each `x`. This would make `v ↦ sublevelPM v` an **isometry**, not merely
1-Lipschitz.

## Conjecture 3 — Ultrametric ⇒ the filtration is a *tree* (dendrogram functor)

In an ultrametric space, `ultrametric_sublevel_nested` says equal-scale balls that meet
coincide. **Conjecture:** the whole sublevel filtration of `IsUltrametricDist X` is a
*hierarchical clustering / dendrogram*: the relation `x ∼_t y ⟺ x, y ∈ a common sublevel
ball at scale t` is, for each `t`, an **equivalence relation**, and the quotients form a
monotone tower of partitions (refined as `t` decreases). Equivalently, the π₀ of the Rips
filtration of `MetricFiltration.lean` is, for ultrametric inputs, the canonical ultrametric
dendrogram. Formalize `Equivalence (sameBall t)` and the partition-refinement functor; this
directly bridges to `Applications/PoincareData/MetricFiltration.lean`.

## Conjecture 4 — p-adic sublevels are a subgroup filtration with index `p^k`

`padicNorm_sublevel_add_closed` shows each p-adic sublevel is additively closed.
**Conjecture:** for `t = p^(-k)` the sublevel `{q : ℚ | padicNorm p q ≤ p^(-k)}` is exactly
the additive subgroup `p^k ℤ_(p)` (localization), the levels form a strictly decreasing
filtration of subgroups with successive quotient `ℤ/pℤ`, and the associated graded is the
polynomial ring `𝔽_p[t]`. This makes the tropical persistence module the *Rees / associated-
graded* construction of the p-adic valuation, linking to `Computation/PadicValuationDepth.lean`
and giving a concrete computation of the "tropical event profile" of `SheafPersistence.lean`.

## Conjecture 5 — Decategorified rank profile is the pushforward of a constructible sheaf

Define the **rank profile** `r(t) = (sublevel v t).ncard` for finite `X`. **Conjecture:** `r`
is a monotone non-decreasing step function whose jump set is exactly the (finite) image
`v '' X`, with jump at `c` equal to `#{x | v x = c}`; moreover `r` is the global-section rank
of a constructible sheaf on `ℝ` in the sense of `Bridges/SheafPersistence.lean`, and the
`min ↦ ∪` law refines to an inclusion–exclusion identity
`r_{min(v,w)}(t) = r_v(t) + r_w(t) - r_{max(v,w)}(t)`. This unifies the tropicalization
(§3) with the sheaf-theoretic event-profile machinery already in the catalog.
