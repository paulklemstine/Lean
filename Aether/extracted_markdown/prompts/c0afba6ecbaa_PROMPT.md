Formalize the originally intended bridge theorem, but narrow it aggressively to a complete relation-level file that definitely type-checks. The previous attempt drifted into generic search certificates and appears truncated; do not pursue that direction. Create a new self-contained file in the Bridges domain proving a concrete comparison between ultrametric Rips relations and thresholded depth/valuation relations.

Target scope:

1. Core Rips relation
- Define `ripsRel (d : α → α → ℕ) (ε : ℕ) : α → α → Prop := fun x y => d x y ≤ ε`.
- Assume explicit hypotheses:
  - `h_refl : ∀ x, d x x = 0`
  - `h_symm : ∀ x y, d x y = d y x`
  - `h_ultra : ∀ x y z, d x z ≤ max (d x y) (d y z)`
- Prove:
  - reflexivity of `ripsRel d ε`
  - symmetry of `ripsRel d ε`
  - transitivity of `ripsRel d ε` using the ultrametric inequality and the fact that if both distances are `≤ ε`, then the max is `≤ ε`
- Package this as a `Setoid` for each threshold `ε`.

2. Core depth/valuation relation
- Define `depthRel (v : α → α → ℕ) (n : ℕ) : α → α → Prop := fun x y => n ≤ v x y`.
- Use explicit axioms suited to the threshold relation:
  - `hvrefl : ∀ x, n ≤ v x x` for the threshold under consideration, or alternatively a stronger bounded-diagonal axiom from which this follows
  - `hvsymm : ∀ x y, v x y = v y x`
  - `hv_ultra : ∀ x y z, min (v x y) (v y z) ≤ v x z`
- Prove reflexivity, symmetry, and transitivity of `depthRel v n`.
- Package this as a `Setoid`.

3. Explicit comparison theorem
- Avoid abstract category/functor language.
- Introduce a bounded discrete model with a constant `K : ℕ` and hypothesis `hbounded : ∀ x y, d x y ≤ K`.
- Define `v (x,y) := K - d x y` (Lean nat subtraction).
- Prove symmetry immediately from `d` symmetry.
- Prove the key equivalence for every `x y` and threshold `ε` under a side condition such as `ε ≤ K`:
  - `ripsRel d ε x y ↔ depthRel v (K - ε) x y`
- Keep the proof elementary, using only arithmetic on naturals; if useful, isolate a lemma of the form `d x y ≤ ε ↔ K - ε ≤ K - d x y` under `d x y ≤ K` and `ε ≤ K`.

4. Worked concrete model
- Give one explicit toy ultrametric on a concrete finite type, preferably something very simple to prove:
  - either the discrete metric on `Fin n` valued in `ℕ` (0 if equal, 1 otherwise), which is ultrametric,
  - or another tiny hand-crafted ultrametric on a finite type.
- Instantiate the above theorems for that model.
- Show at least one example theorem demonstrating the comparison theorem specializes correctly.

5. File engineering constraints
- One complete file, no placeholders, no `admit`, no `sorry`.
- Keep imports minimal and relevant; prefer existing Bridges/Core files only if genuinely useful.
- Do not introduce a generic filtration API, graph reachability layer, search procedure, or theory morphism machinery unless absolutely required (it should not be required).
- The theorem statements should be small, concrete, and directly usable.

If there is any risk that the full generality over arbitrary `α` causes friction, it is acceptable to parameterize the relation lemmas over arbitrary `α` but keep the comparison model and example specialized to a simpler concrete type. The priority is a finished formalization of the bridge theorem promised by the original concept.