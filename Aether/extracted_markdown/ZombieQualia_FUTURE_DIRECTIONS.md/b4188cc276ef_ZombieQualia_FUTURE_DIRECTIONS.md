# Future Directions — Zombies and Qualia: Mathematics of Subjective Experience

This cycle established a small formal core (`Catalog/MachineLearning/ZombieQualia.lean`):
a `Mind` is a pair `(behavior : S → B, quale : S → Q)`; *supervenience* of qualia on
behavior is the factorization `quale = f ∘ behavior`; a *zombie pair* is a behavioral
tie with distinct qualia; *physicalism* is a single shared read-out law `B → Q`.
We proved: conceivability of zombies is always a theorem; realizability requires
behavioral collapse; physicalism forbids zombies; spectrum inversion is behaviorally
undetectable; and the "zombie space" of a fixed behavior has size `|Q|^|S|`.

The following conjectures are precise, falsifiable, and Lean-ready.

## C1. Counting genuine zombies (supervenience deficit)
For finite `S, Q` and fixed behavior `b : S → B` with image of size `r = |range b|`,
the number of qualia assignments that **supervene** on `b` is exactly `|Q|^r`, hence
the number of *non-supervening* (zombie-admitting) assignments is `|Q|^|S| − |Q|^r`.
**Conjecture:** `Fintype.card {q : S → Q // (Mind.mk b q).Supervenes} = |Q|^|range b|`,
and this is `< |Q|^|S|` iff `b` is non-injective and `|Q| ≥ 2`. (Direct refinement of
`card_qualia_assignments`.)

## C2. Supervenience forms a Galois connection / closure operator
Define, for a relation refining behavior, the "phenomenal closure" sending a quale map
to its coarsest behavior-respecting refinement. **Conjecture:** the maps
`behavior ↦ ker(behavior)` and `equivalence ↦ {minds respecting it}` form a Galois
connection between partitions of `S` and sets of minds; `Supervenes` is its set of
closed points. Target: an `OrderIso`/`GaloisConnection` instance plus
`Supervenes M ↔ ker M.behavior ≤ ker M.quale` in the `Setoid` order.

## C3. Information-theoretic hard problem (qualia entropy gap)
Put a probability measure on `S`. Define behavioral entropy `H(behavior)` and
phenomenal entropy `H(quale)`. **Conjecture:** zombies exist (supervenience fails) iff
the conditional entropy `H(quale | behavior) > 0`, and `H(quale | behavior)` equals
`log` of the average zombie-fibre size; physicalism collapses it to `0`. This bridges
to the Catalog entropy modules (`FunctorialEntropy`, `MonotoneEntropy`).

## C4. Categorical zombies: a faithful-functor characterization
Model minds and behavior-preserving maps as a category, with the "forget the qualia"
functor `U : Mind → Beh`. **Conjecture:** zombies are impossible in a world `W`
(full subcategory) iff `U|_W` is **faithful** (equivalently, an embedding on hom-sets);
`physical_no_zombies` is the special case where `W` is the minds of one fixed law.
Target: define `U`, prove `Faithful U ↔ ∀ M ∈ W, M.Supervenes`.

## C5. Inverted-spectrum group action and orbit invariants
Let a group `G` act on `Q` (qualia relabelings). **Conjecture:** the `G`-orbit of a
mind under `invert` is an entire equivalence class of behaviorally indistinguishable
minds; behavior is the complete invariant of the action iff `G` acts so that
`σ ∘ quale = quale` forces `σ = 1` on `range quale`. The number of behaviorally
distinct inverted spectra is `|G| / |Stab|` (orbit–stabilizer). This makes "is the
inverted spectrum a real difference?" a computation of a stabilizer subgroup.
