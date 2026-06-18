# Future Directions: Polymodal Provability, Ordinal Ranks, and the Category of GL Frames

## Synthesis

This cycle extended the Kripke-semantic core of Gödel–Löb provability logic
(`Catalog/Logic/GLKripke.lean`'s `GLFrame`, `gl_frame_validates_loeb`,
`gl_frame_well_founded`) in three directions that the previous GL cycle flagged as
open, and which together push the frame theory toward set theory, proof theory, and
category theory. The unifying structural insight is that **the defining feature of a
GL frame — converse well-foundedness of accessibility — is exactly enough to carry an
ordinal rank**, and that this rank, once available frame-internally, behaves
functorially under the polymodal and product constructions. Concretely, `GLFrame.rank`
assigns every world an ordinal from the well-foundedness of `flip R`, and
`gl_rank_lt_of_R` shows it strictly drops along accessibility; this is the qualitative,
*every-frame* generalization of the quantitative `natBox_iterate_eq_Iio` computation
from `Catalog/Logic/LobNatModel.lean`, where the rank of world `n` of the canonical
frame `(ℕ, >)` is literally `n`.

Building on that rank, we formalized **polymodal GLP frames** (`GLPFrame`): one world
set with a nested family `R₀ ⊇ R₁ ⊇ ⋯` of transitive irreflexive relations. The key
discovery here is a *reduction*, not a new soundness proof — each level `GLPFrame.level n`
is a genuine `GLFrame`, so the entire single-modal apparatus (Löb, well-foundedness,
rank) applies level by level (`glp_level_validates_loeb`, `glp_level_rank_lt`).
Monotonicity of the boxes in the index (`glp_box_mono_in_level`) is the frame-semantic
root of the GLP axiom `[n]φ → [n+1]φ`, and it falls directly out of the antitone
nesting of the relations (`R_anti`). What initially looked like it might need a separate
polymodal Löb argument turned out to be a corollary of the single-modal theory plus the
nesting bookkeeping.

The third strand opens the **category of GL frames**: the synchronized product
`GLFrame.prod` is again a GL frame, and the diamond of a rectangle factors *exactly* as
a rectangle of diamonds (`prod_diamond_rectangle`). The failure analysis is as
informative as the theorem: the box operator does **not** factor, because a world with
no successor in one coordinate makes `□` vacuously true there — so the categorical
product is detected by `◇`, not `□`. This asymmetry (◇ factors, □ does not) is the
seed for the next cycle's categorical-logic direction.

## Results Summary

- `GLFrame.flip_wellFounded`: proved — the converse accessibility relation of any GL frame is well-founded (converse well-foundedness), the structural fact underlying ordinal ranks.
- `gl_rank_lt_of_R`: proved — every GL frame carries an ordinal rank `GLFrame.rank` that strictly decreases along accessibility, a frame-internal ordinal analysis.
- `GLPFrame.R_anti`: proved — the polymodal accessibility family is antitone in the index (`R m ⊆ R n` for `n ≤ m`).
- `GLPFrame.glp_level_validates_loeb`: proved — every modality of a GLP frame validates Löb's axiom, reducing polymodal soundness to the single-modal case.
- `GLPFrame.glp_box_mono_in_level`: proved (axiom-free) — higher polymodal boxes are weaker (`□ₙS ⊆ □ₘS` for `n ≤ m`), the semantic content of `[n]φ → [n+1]φ`.
- `GLPFrame.glp_level_rank_lt`: proved — ordinal rank strictly decreases along each modality `R n`.
- `GLFrame.prod_diamond_rectangle`: proved — in the synchronized product, `◇(A ×ˢ B) = (◇A) ×ˢ (◇B)`, the modal signature of a categorical product.
- `GLFrame.prod_validates_loeb`: proved — synchronized products of GL frames preserve Löb's axiom (the product is an object of the same category).

## Research Directions

### Direction 1: An ε₀-valued rank for the standard polymodal frame
**Hypothesis**: There is a concrete `GLPFrame` on an ordinal-indexed world set whose
level-0 `GLFrame.rank` of the standard world equals `ε₀`, with higher levels realizing
the Veblen/Japaridze tower `ω`, `ω^ω`, …, reproducing the proof-theoretic ordinal of PA.
**Test**: Instantiate `GLPFrame` with `World := Ordinal` below ε₀ and `R n` a level-shifted
order, then compute `(level 0).rank` of the top world and prove it equals `ε₀` using the
already-proved `gl_rank_lt_of_R` as the descent lemma.
**Why now**: This cycle just produced a *general* ordinal rank (`GLFrame.rank`) valid in
every GL frame; previously there was only the ℕ-valued rank of `(ℕ,>)`. The rank now
takes ordinal values, so an ε₀ target is type-correct and the descent inequality is in hand.
**If true**: First machine-verified bridge from polymodal frame semantics to a named
proof-theoretic ordinal.
**If false**: Pinpoints that the GLP–ordinal correspondence needs arithmetical
interpretation beyond the bare frame, sharpening exactly what extra structure is required.

### Direction 2: Box does not factor — a categorical obstruction theorem
**Hypothesis**: For the synchronized product, `(F.prod G).boxSet (A ×ˢ B)` strictly
contains `(F.boxSet A) ×ˢ (G.boxSet B)` whenever either frame has a world with no
successor, and the two coincide iff both frames are successor-total (serial).
**Test**: Prove the inclusion `⊇` in general, then construct an explicit two-world
counterexample to equality using a dead-end world, and prove the seriality
characterization.
**Why now**: `prod_diamond_rectangle` shows ◇ factors perfectly; the failure analysis
already located the obstruction (vacuous box at dead ends). Formalizing the obstruction
turns an informal remark into a theorem.
**If true**: Gives a clean criterion separating ◇ (a product-preserving functor) from □,
the categorical core of why GL is a "◇-natural" logic.
**If false**: Would reveal an unexpected coincidence forcing reexamination of the product's
universal property.

### Direction 3: Coproducts and a full categorical structure on GL frames
**Hypothesis**: The disjoint union of GL frames (accessibility internal to each summand)
is the coproduct, and together with `GLFrame.prod` it makes finite GL frames a category
with finite products and coproducts; bounded morphisms (p-morphisms) are the maps that
preserve `boxSet` along preimages.
**Test**: Define `GLFrame.disjointUnion` and `GLFrameMorphism`, prove the universal
properties of product and coproduct, and verify rank is additive/maximizing under the two
operations.
**Why now**: `GLFrame.prod` and `prod_validates_loeb` already give one half; the rank
machinery gives an invariant to test functoriality against.
**If true**: Provability logic acquires a verified categorical semantics, enabling
limit/colimit arguments about consistency strength.
**If false**: Identifies which closure property (probably equalizers) fails, bounding how
"complete" the category can be.

### Direction 4: Rank as a quantitative Löb / consistency-strength gauge
**Hypothesis**: In any GL frame, `GLFrame.rank w` equals the length of the longest
ascending accessibility chain from `w`, and the iterated box `□^k ⊥` is satisfied exactly
at worlds of rank `< k` — generalizing `natBox_iterate_eq_Iio` from `(ℕ,>)` to every GL
frame.
**Test**: Prove `rank w = sSup {chain lengths}` (finite frames), then prove the
rank-stratification of `boxSet^[k] ∅` by induction using `gl_rank_lt_of_R`.
**Why now**: We now have both the ordinal rank and the single-frame Löb validation in the
same file; the only missing link is the chain-length identity.
**If true**: Makes "consistency strength = ordinal rank" a theorem for arbitrary GL
frames, unifying the semantic and the `LobNatModel` quantitative pictures.
**If false**: Shows rank and box-iteration depth diverge on branching frames, revealing a
genuinely two-dimensional notion of provability depth.

### Direction 5: Tropical/cost semantics layered on the rank
**Hypothesis**: Replacing the boolean `boxSet` by a cost function
`cost(w, □φ) = sup over successors + 1` yields a real-valued semantics in which
`cost(w, □^k⊥)` grows linearly in `k`, and the growth rate is bounded below by
`GLFrame.rank w`.
**Test**: Define `tropicalForces` by well-founded recursion on `flip R` (reusing
`flip_wellFounded`), prove a tropical Löb inequality, and relate the cost to the ordinal
rank.
**Why now**: `flip_wellFounded` gives exactly the well-founded relation needed to define a
total recursive cost function, which was the missing ingredient for a tropical layer.
**If true**: Produces a quantitative "tropical incompleteness" gauge tying proof cost to
ordinal rank.
**If false**: Indicates the cost recursion is not monotone under the GL axioms, isolating
where quantitative and qualitative provability part ways.
