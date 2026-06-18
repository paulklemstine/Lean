            # Phase A Research Mission v17: Functorial bridge from combinatorial species growth to tropical generating-function valuations

            ## Concept
            **Domain**: Bridges
            **Research mode**: formalize
            **Title**: Functorial bridge from combinatorial species growth to tropical generating-function valuations
            **Description**: The key insight is that the catalog’s underused combinatorial-species machinery in Applications can be connected to the tropical/valuation infrastructure by sending an exponential generating function to its coefficientwise valuation profile and proving that the basic species constructors induce tropical algebra on these profiles. Why now: `Applications/CombinatorialSpecies.lean` already isolates the additive and multiplicative EGF laws as a small, concrete formal core, while the tropical side has mature object-level infrastructure in `Bridges/CategoricalTropicalUltrametric.lean`; this makes a minimal but genuinely new cross-domain theorem package tractable without repeating the saturated valuation-depth/Rips line. The proposed target is a falsifiable bridge theorem stating that whenever two species have EGFs related by sum or Cauchy product, their valuation profiles satisfy corresponding tropical min-plus inequalities, with equality under explicit non-collision hypotheses on coefficient valuations. A strong version should produce a functorial pipeline from species constructors to tropical complexity certificates: disjoint sum gives pointwise tropical minimum bounds, product gives tropical convolution bounds, and the linear-order species provides a calibrated test case whose valuation profile can be computed exactly. This matters because it creates a new Applications–Bridges link identified as structurally missing in the catalog, turns symbolic combinatorial constructions into algorithmic tropical invariants, and opens a path toward later stability or learning applications without reusing the already heavily explored Rips/tropical comparison framework.
            **Mathematical framing**: 

            ### Attached Catalog References (read these first)
- `Applications/CombinatorialSpecies.lean`
- `Bridges/CategoricalTropicalUltrametric.lean`


### Broader Catalog Context
@Applications/CombinatorialSpecies.lean
```lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Combinatorial Species as Functors and the Exponential Generating Function Bridge

This file formalizes a fragment of Joyal's theory of **combinatorial species** and the
classical bridge to **analytic functors / exponential generating functions (EGF)**.

A species is modeled (in skeletal form) as a functor from the *groupoid of finite sets*
to finite sets: a family `obj : ℕ → Type` of finite "structure types", together with a
functorial action of the symmetric group `Equiv.Perm (Fin n)` (relabelling) on each
`obj n`.  Its EGF is the formal power series

  `EGF F = ∑ₙ (|F[n]| / n!) Xⁿ`.

The central enumerative-combinatorics ↔ analysis dictionary established here is:

* **sum of species ↔ sum of EGFs**            (`egf_add`)
* **product of species ↔ product of EGFs**    (`egf_mul`, `egf_card_prodSpecies`)
* **species of sets `E` ↔ `exp`**             (`EGF_setSpecies`)
* **species of linear orders `L` ↔ 1/(1-X)**  (`egf_linearOrderSpecies`)

The product law is the heart of the bridge: the *structural* product of species (the
Day-convolution `(F·G)[n] = Σ_{S ⊆ [n]} F[S] × G[n∖S]`) has cardinality the **binomial
convolution** of the counting sequences, which is exactly the Cauchy product of the EGFs.

## Main results
* `egf_add`              — additivity of the EGF.
* `egf_mul`              — binomial convolution of counting sequences ↔ product of EGFs.
* `EGF_setSpecies`       — EGF of the species of sets equals `PowerSeries.exp ℚ`.
* `egf_linearOrderSpecies` — `(1 - X) · EGF(L) = 1`, i.e. EGF of linear orders is `1/(1-X)`.
* `card_prodSpecies`     — cardinality of the structural product is the binomial convolution.
* `egf_card_prodSpecies` — the full bridge: EGF of the structural product = product of EGFs.

### Deepening — the differential calculus of species (this cycle)
* `egf_injective`         — the EGF transform is injective on counting sequences.
* `binConv_comm`          — commutativity of the species product, via the analytic shadow.
* `egf_derivative`        — shift of a sequence ↔ formal derivative `derivativeFun`.
* `egf_pointing`          — multiplication by the index ↔ Euler operator `X·d/dX`.
* `EGF_derivativeSpecies` — `(F′).EGF = (F.EGF).derivativeFun` for the derivative species `F′`.
* `EGF_pointedSpecies`    — `(F•).EGF = X · (F.EGF).derivativeFun` for the pointed species `F•`.
-/
import Mathlib

open scoped BigOperators
open PowerSeries Finset

namespace CombinatorialSpecies

noncomputable section

/-! ### Exponential generating functions of counting sequences -/

/-- The exponential generating function of a counting sequence `a : ℕ → ℚ`,
namely `∑ₙ (aₙ / n!) Xⁿ`. -/
noncomputable def egf (a : ℕ → ℚ) : ℚ⟦X⟧ := PowerSeries.mk fun n => a n / n.factorial

@[simp] lemma coeff_egf (a : ℕ → ℚ) (n : ℕ) :
    PowerSeries.coeff (R := ℚ) n (egf a) = a n / n.factorial := by
-- ... (truncated, full file has 318 lines)
```

@Bridges/CategoricalTropicalUltrametric.lean
```lean
/-
  # Categorical Tropical–Ultrametric Equivalence
  ## via Valuation Reconstruction and Functorial Bound Transfer

  Bridge: connects tropical algebra ↔ ultrametric analysis ↔ certified robustness ↔
  post-quantum lattice-style metrics.

  **Core principle**: tropical valuation data on an ordered idempotent semiring can be
  reconstructed into an ultrametric seminorm, and quantitative bounds proven in the
  tropical world transfer functorially to ultrametric certified bounds relevant to
  quantum/cryptographic/ML settings.

  The most important mathematical message: **valuation reconstruction is not just a
  dictionary — it is a quantitative functor**.
-/

import Mathlib

open Function

noncomputable section

namespace CategoricalTropicalUltrametric

/-! ## §1. Tropical Valuation Objects

Bridge: connects tropical algebra to ultrametric geometry and certified robustness. -/

/-- A tropical valuation object: a linearly ordered additive-idempotent commutative monoid
    with a compatible multiplicative structure. The key axiom `add_eq_max'` encodes the
    tropical "addition = max" principle. -/
structure TropicalValuationObject (R : Type u) where
  le : R → R → Prop
  le_refl : ∀ a, le a a
  le_antisymm : ∀ {a b}, le a b → le b a → a = b
  le_trans : ∀ {a b c}, le a b → le b c → le a c
  le_total : ∀ a b, le a b ∨ le b a
  zero : R
  one : R
  add : R → R → R
  mul : R → R → R
  max_op : R → R → R
  add_eq_max' : ∀ a b, add a b = max_op a b
  max_comm : ∀ a b, max_op a b = max_op b a
  max_assoc : ∀ a b c, max_op (max_op a b) c = max_op a (max_op b c)
  max_idem : ∀ a, max_op a a = a
  max_le_left : ∀ a b, le a (max_op a b)
  max_le_right : ∀ a b, le b (max_op a b)
  max_least : ∀ {a b c}, le a c → le b c → le (max_op a b) c
  mul_comm : ∀ a b, mul a b = mul b a
  mul_assoc : ∀ a b c, mul (mul a b) c = mul a (mul b c)
  mul_one : ∀ a, mul a one = a
  mul_zero : ∀ a, mul a zero = zero
  add_zero : ∀ a, add a zero = a

/-- Bundled tropical valuation object. -/
structure TropObj where
  α : Type u
  trop : TropicalValuationObject α

-- ... (truncated, full file has 890 lines)
```


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


            ## v17 Research Core Methodology — Concise Scientific Loop

Lead a 4-role team: Hypothesizer, Experimenter, Analyst, Critic.
Loop: Hypothesize → Experiment → Analyze → Critique → Synthesize.

1. **Hypothesize**: 5–7 falsifiable conjectures; ≥2 surprising.
2. **Experiment**: Prove or disprove in Lean 4; prioritize surprise.
3. **Analyze**: Document what survived, failed, and why.
4. **Critique**: Check for triviality, missing sorries, weak assumptions.
5. **Synthesize**: Clean Lean files + FUTURE_DIRECTIONS.md (3–5 testable
   conjectures, each with "The key insight is..." and "Why now?").


            ### Anti-Trivial Guardrails (non-negotiable)
The following are NOT acceptable as main results:
- Theorems of the form `theorem name {X : Type*} [Inhabited X] : True := by trivial`.
- Definition-only theorems or definitional equalities proved by `rfl`.
- Results whose entire proof is `simp`, `norm_num`, `decide`, or `native_decide`.
- Wrapper types that rename existing definitions.
- Re-proving existing catalog theorems with minor notation changes.

Every main theorem must use at least one insight-bearing tactic or
technique such as `induction`, `by_contra`, `field_simp`, `ring_nf`,
`omega`, `linarith`, `rcases`, or a custom helper lemma.


            ### Deliverables & Acceptance Criteria
1. **Lean 4 files** (2–4 files in the appropriate `Catalog/<domain>/` subtree).
   - Main theorems must be fully proved (0 sorries).
   - Each file must contain `-- !-- Lab Notes -- !--` blocks documenting
     the team loop: Hypothesis, Experiment, Analysis, Critique, Synthesis.
2. **FUTURE_DIRECTIONS.md** with 3–5 bold, falsifiable conjectures derived
   from the cycle's findings. Each must have a "The key insight is..."
   sentence and a "Why now?" justification.

### Strictly Forbidden in Phase A
- `ARTICLE.md`, `RESEARCH_PAPER.md`, `demo.py`, HTML widgets, `PACKAGE.json`.
- Prose for human readers other than Lab Notes and FUTURE_DIRECTIONS.md.


            ## Self-Critique Checklist (perform before final output)
            Review your candidate output and answer each item. If the answer is
            unsatisfactory, revise the output before returning it.

            - [ ] No theorem is trivial (True, Inhabited-only, native_decide-only, etc.).
            - [ ] Every main theorem has 0 sorries.
            - [ ] At least one theorem imports or uses results from the attached catalog.
            - [ ] Lab Notes blocks contain real hypotheses, results, insights, and failure analysis.
            - [ ] FUTURE_DIRECTIONS.md conjectures are derived from this cycle's findings.
            - [ ] Every future direction includes a "The key insight is..." sentence and a "Why now?" justification.

            ## Output Format Reminder
            Return `.lean` files and `FUTURE_DIRECTIONS.md` only. Focus all compute
            on the mathematics.
