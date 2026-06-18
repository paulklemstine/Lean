
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "descriptive_name",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: The file `Catalog/Physics/ProofPhaseTransitions/RandomKSAT.lean` establishes, fu
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Proof Phase Transitions in Random k-SAT

The file `Catalog/Physics/ProofPhaseTransitions/RandomKSAT.lean` establishes, fully
formally and `sorry`-free, the **first-moment (annealed) counting identity** for the
random `k`-SAT model with replacement,

>  `∑_F #{a : a ⊨ F} = 2^n · ((2n)^k − n^k)^m`  (`first_moment`),

together with the **sharp existence threshold** it implies: once the first moment falls
below the number of formulas, an unsatisfiable instance is forced to exist
(`exists_unsat`), and its statistical-physics density form
`2^n · (1 − 2^{−k})^m < 1 ⟹ ∃` unsatisfiable formula (`exists_unsat_of_real_density`).

These results are the rigorous "upper half" of the satisfiability phase transition. The
directions below are concrete, falsifiable, and each is a natural next Lean target. They
also indicate cross-domain bridges to existing catalog material (entropy/partition
functions in `Shared/EntropyAlgebra.lean`, tropical/idempotent counting in `Tropical/`,
and the probabilistic method in `Speculative/ProbabilisticMethod/Core.lean`).

## Direction 1 — A second-moment satisfiability lower bound

Prove the complementary half: if the clause density is *below* the first-moment
threshold by a constant factor, then a uniformly random formula is satisfiable with
probability bounded away from `0`. Concretely, formalize the inequality
`(E[X])^2 ≤ P(X > 0) · E[X^2]` (Paley–Zygmund / Cauchy–Schwarz) for `X` = number of
satisfying assignments, and bound `E[X^2]` by computing the exact two-assignment
correlation `∑_{a,b} (per-clause joint-sat probability)^m` as an explicit function of the
Hamming distance `d(a,b)`.

The key insight is that the second moment factorizes over clauses exactly as the first
moment does, so `E[X^2] = ∑_{a,b} ((2n)^k − 2·n^k + u(a,b))^m / (2n)^{km}` where
`u(a,b)` counts clauses falsified by *both* `a` and `b`, a quantity that depends only on
`|a Δ b|`; this reduces the whole estimate to a one-dimensional sum over Hamming
distance that the same `subtypePiEquivPi`/`Fintype.card_pi` machinery already in the file
can evaluate. Why now? The counting infrastructure (`card_unsat_clause`, `card_sat_form`)
is exactly the per-clause factorization needed, so the second moment is a *finite,
closed-form* `Fintype.card` computation rather than an analytic estimate — no new
probability theory is required, only one more application of the tools already proved.

## Direction 2 — Sharpness of the threshold (a 0/1 transition window)

Conjecture and formalize that the existence threshold is *sharp* in `m`: there is an
explicit width `w(n,k)` such that for `m` below `m*(n,k) − w` every formula in a positive
fraction is satisfiable, while for `m` above `m*(n,k) + w` the first moment already forces
unsatisfiability, with `w(n,k) = O(1)` independent of `n` for fixed `k`.

The key insight is that `m ↦ 2^n(1 − 2^{−k})^m` is strictly log-linear, so the crossing
of the value `1` happens within a single unit interval of `m`, giving a transition window
whose width is governed entirely by `−1/log(1 − 2^{−k})` and not by `n`. Why now? The
density criterion `exists_unsat_of_real_density` already isolates the exact real-analytic
quantity whose sign flips; bounding the integer crossing point is a monotonicity argument
on a concrete real sequence, well within reach of `Mathlib`'s `StrictMono`/`Real.log`
API and directly extends the theorem just proved.

## Direction 3 — The "without replacement" model and an exact binomial identity

Re-derive the first moment for the *combinatorial* random `k`-SAT model in which each
clause uses `k` distinct variables with independent signs. Conjecture the exact identity
`∑_F #{a : a ⊨ F} = 2^n · (C(n,k)·2^k − C(n,k))^m = 2^n · (C(n,k)·(2^k − 1))^m`
over the space of `m`-tuples of such clauses, and the corresponding threshold
`2^n · (1 − 2^{−k})^m < 1` (identical density form, different normalization).

The key insight is that switching from "literals with replacement" to "distinct-variable
clauses" only replaces the per-clause base count `(2n)^k` by `C(n,k)·2^k` while the
*unsatisfied* fraction stays exactly `2^{−k}`, so the physics-level density threshold is
model-independent even though the underlying `Fintype` changes. Why now? The proof reuses
`subtypePiEquivPi` verbatim after replacing `Lit n` with the subtype of injective
literal tuples; the only new ingredient is `Fintype.card` of `k`-subsets, for which
`Mathlib` already has `Finset.card_powersetCard`, making this a clean re-instantiation of
the existing file.

## Direction 4 — General finite-domain CSP and a product partition function

Generalize from Boolean variables to variables over a finite domain of size `q` and from
clauses forbidding one assignment-pattern to constraints forbidding `r` of the `q^k`
local patterns. Conjecture the first-moment identity
`∑_F #{a : a ⊨ F} = q^n · (q^k − r)^m` and the threshold
`q^n · (1 − r·q^{−k})^m < 1 ⟹ ∃` unsatisfiable instance, recovering the Boolean case at
`q = 2, r = 1`.

The key insight is that the entire argument is a statement about the *partition function*
`Z = ∑_a w(a)` of a product weight `w(a) = ∏_clauses [a satisfies clause]`, so the
annealed average `E[Z]` always factorizes as `q^n · (fraction of allowed local
patterns)^m` regardless of the alphabet — the threshold is a sign change of `log E[Z]`,
i.e. of an annealed free energy. Why now? This reframes the catalog's
`Shared/EntropyAlgebra.lean` partition-function/entropy results as the `q`-ary free energy
of a random CSP, turning a Physics-domain counting theorem into an honest cross-domain
bridge (Physics ↔ Algebra/Entropy) with `q^n(1 − r q^{−k})^m` as the shared invariant.

## Direction 5 — Tropical (min-plus) free energy and a zero-temperature transition

Lift the partition function `Z = ∑_a w(a)` to the **tropical semiring**, where addition
is `min` and multiplication is `+`, so that `Z_trop(F) = min_a (#clauses falsified by a)`
is the minimum number of unsatisfied clauses (the MAX-SAT optimum). Conjecture a tropical
first-moment law bounding `E[Z_trop]` and a *zero-temperature* threshold: above the
density at which `2^n(1 − 2^{−k})^m < 1`, we have `Z_trop(F) ≥ 1` for almost all `F`
(every assignment falsifies a clause), matching the Boolean `exists_unsat`.

The key insight is that the ordinary first moment `E[X] = E[∑_a 1_{Z_trop = 0}]` is
exactly the count of *zero-temperature ground states*, so `exists_unsat` is precisely the
statement that the tropical optimum jumps off `0`; the tropical lift therefore reinterprets
the satisfiability transition as a discontinuity in a min-plus free energy. Why now? The
`Tropical/` catalog already develops min-plus algebra and `Tropical/FiberEntropy.lean`
develops fiber counting, so the tropical free energy `Z_trop` can be built directly on
that infrastructure, connecting the Physics phase-transition theorem to the project's
largest (1353-theorem) tropical corpus through a single shared object: the random-formula
partition function.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Physics/ProofPhaseTransitions/RandomKSAT.lean
/-
# Proof Phase Transitions in Random k-SAT (the first-moment / annealed bound)

This file gives a fully formal account of the **first-moment (annealed) counting
identity** for random `k`-SAT in the "literals with replacement" model, and the sharp
*existence* threshold it implies.

The engine is a general **partition-function first-moment law** for an arbitrary finite
constraint-satisfaction problem (CSP): if every assignment satisfies exactly `S` of the
constraints, then summing the number of satisfying assignments over all `m`-constraint
formulas equals `|A| · S^m`, where `A` is the assignment space.  A pigeonhole on this
identity forces an unsatisfiable formula to exist as soon as `|A| · S^m < |C|^m`.

Specializing to Boolean `k`-SAT (assignments `Fin n → Bool`, literals `Fin n × Bool`,
clauses `Fin k → Lit`) gives

* `RandomKSAT.first_moment` :  `∑_F #{a : a ⊨ F} = 2^n · ((2n)^k − n^k)^m`
* `RandomKSAT.exists_unsat`  :  `2^n·((2n)^k − n^k)^m < (2n)^{km} ⟹ ∃ F` unsatisfiable
* `RandomKSAT.exists_unsat_of_real_density` :
      `2^n · (1 − 2^{−k})^m < 1 ⟹ ∃ F` unsatisfiable

the last being the statistical-physics density form of the satisfiability transition.
-/

import Mathlib

open scoped Classical
open Finset

namespace RandomKSAT

/-! ## A general partition-function first-moment law

We work with an abstract finite assignment space `A`, a finite constraint space `C`, and
a satisfaction relation `sat`.  A *formula* on `m` constraints is `Fin m → C`, and an
assignment `a` *models* a formula `F` when it satisfies every constraint of `F`. -/

section General

variable {A C : Type*} [Fintype A] [Fintype C] (sat : A → C → Prop)

/-
!-- The set of formulas satisfied by a fixed assignment factorizes over the `m`
independent constraint slots via `Equiv.subtypePiEquivPi`, so its cardinality is the
`m`-th power of the per-assignment satisfied-constraint count. -- !--
-/
omit [Fintype A] in
theorem card_models_form (a : A) (m : ℕ) :
    Fintype.card {F : Fin m → C // ∀ j, sat a (F j)}
      = (Fintype.card {c // sat a c}) ^ m := by
  -- By definition of $F$, we can rewrite the set of formulas Fix as a product of sets.
  have h_prod : {F : (Fin m) → C | ∀ j, (sat a (F j))} ≃ ((Fin m) → {c : C | (sat a c)}) := by
    exact ⟨ fun F => fun j => ⟨ F.val j, F.prop j ⟩, fun F => ⟨ fun j => F j, fun j => F j |>.2 ⟩, fun F => rfl, fun F => rfl ⟩;
  simpa using Fintype.card_congr h_prod

/-
!-- Fubini for finite sums: summing the number of satisfying assignments over all
formulas equals summing the number of satisfied formulas over all assignments, each of
which is the constant `S^m` by `card_models_form`. -- !--
-/
theorem first_moment_general (m S : ℕ)
    (hS : ∀ a, Fintype.card {c // sat a c} = S) :
    ∑ F : Fin m → C, Fintype.card {a // ∀ j, sat a (F j)}
      = Fintype.card A * S ^ m := by
  -- Rewrite each `Fintype.card {a // P a}` as `∑ a, if P a then 1 else 0` using `Fintype.card_subtype` together with `Finset.card_filter` (or `Fintype.card_eq_sum_ones`/`Finset.sum_boole`).
  have h_rewrite : ∑ F : (Fin m) → C, Fintype.card {a : A // ∀ j, sat a (F j)} = ∑ F : (Fin m) → C, ∑ a : A, if ∀ j, sat a (F j) then 1 else 0 := by
    simp +decide [ Fintype.card_subtype ];
  rw [ h_rewrite, Finset.sum_comm ];
  convert Finset.sum_congr rfl fun a _ => card_models_form sat a m;
  · simp +decide [ Fintype.card_subtype ];
  · simp +decide [ hS ]

/-
!-- Pigeonhole: if the total satisfying-assignment count summed over all `|C|^m`
formulas is strictly below the number of formulas, some formula must have zero
satisfying assignments, i.e. is unsatisfiable. -- !--
-/
theorem exists_unsat_general (m S : ℕ)
    (hS : ∀ a, Fintype.card {c // sat a c} = S)
    (hlt : Fintype.card A * S ^ m < (Fintype.card C) ^ m) :
    ∃ F : Fin m → C, ∀ a, ¬ (∀ j, sat a (F j)) := by
  contrapose! hlt;
  convert first_moment_general sat m S hS |> le_of_eq |> le_trans _ using 1;
  exact le_trans ( by simp +decide [ Fintype.card_pi ] ) ( Finset.sum_le_sum fun F _ => Fintype.card_pos_iff.mpr ⟨ Classical.choose ( hlt F ), Classical.choose_spec ( hlt F ) ⟩ )

end General

/-! ## Boolean `k`-SAT specialization -/

section Boolean

/-- An assignment of Boolean values to `n` variables. -/
abbrev Assign (n : ℕ) := Fin n → Bool

/-- A literal: a variable together with the sign that makes it true. -/
abbrev Lit (n : ℕ) := Fin n × Bool

/-- A `k`-clause: a `k`-tuple of literals (the "with replacement" model). -/
abbrev Clause (n k : ℕ) := Fin k → Lit n

/-- A literal `(v, s)` is satisfied by `a` iff `a v = s`. -/
def satLit {n : ℕ} (a : Assign n) (l : Lit n) : Prop := a l.1 = l.2

/-- A clause is satisfied iff at least one of its literals is. -/
def satClause {n k : ℕ} (a : Assign n) (c : Clause n k) : Prop := ∃ i, satLit a (c i)

/-- An assignment models a formula iff it satisfies every clause. -/
def models {n k m : ℕ} (a : Assign n) (F : Fin m → Clause n k) : Prop :=
  ∀ j, satClause a (F j)

/-
!-- The literals falsified by `a` are exactly those of the form `(v, !(a v))`, one per
variable, giving a bijection with `Fin n`. -- !--
-/
theorem card_falseLit {n : ℕ} (a : Assign n) :
    Fintype.card {l : Lit n // a l.1 ≠ l.2} = n := by
  rw [ Fintype.card_subtype ];
  convert Finset.card_image_of_injective ( Finset.univ : Finset ( Fin n ) ) ( show Function.Injective ( fun k : Fin n ↦ ( k, !a k ) ) from fun i j h ↦ by aesop ) using 2;
  · ext ⟨ i, j ⟩ ; by_cases hi : a i <;> aesop;
  · simp +decide [ Finset.card_univ ]

/-
!-- A clause is falsified iff every coordinate is a falsified literal; by
`Equiv.subtypePiEquivPi` this set is the `k`-fold product of falsified literals, of
size `n^k`. -- !--
-/
theorem card_unsat_clause {n k : ℕ} (a : Assign n) :
    Fintype.card {c : Clause n k // ∀ i, a (c i).1 ≠ (c i).2} = n ^ k := by
  rw [ Fintype.card_subtype ];
  -- By definition of $satClause$, we know that $satClause a c$ holds if and only if there exists an $i$ such that $a (c i).1 = (c i).2$.
  set S := Finset.filter (fun c : Fin k → Lit n => ∀ i, a (c i).1 ≠ (c i).2) Finset.univ;
  rw [ show S = Finset.image ( fun x : Fin k → Fin n => fun i => ( x i, !a ( x i ) ) ) ( Finset.univ : Finset ( Fin k → Fin n ) ) from ?_ ];
  · rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
    simp +contextual [ funext_iff ];
  · ext c; simp [S];
    constructor <;> intro h;
    · exact ⟨ fun i => ( c i |>.1 ), funext fun i => by cases h' : c i |>.2 <;> specialize h i <;> aesop ⟩;
    · grind

/-
!-- Satisfied clauses are the complement of falsified clauses, so their count is the
total clause count `(2n)^k` minus the falsified count `n^k`. -- !--
-/
theorem card_sat_clause {n k : ℕ} (a : Assign n) :
    Fintype.card {c : Clause n k // satClause a c} = (n * 2) ^ k - n ^ k := by
  by_contra h;
  -- The set of clauses that are not satisfied by `a` is the complement of the set of clauses that are satisfied by `a`.
  have h_compl : Fintype.card {c : Clause n k // ¬satClause a c} = n ^ k := by
    convert card_unsat_clause a using 4 ; unfold satClause ; aesop;
  have h_total : Fintype.card {c : Clause n k // satClause a c} + Fintype.card {c : Clause n k // ¬satClause a c} = (n * 2) ^ k := by
    rw [ Fintype.card_subtype, Fintype.card_subtype ];
    rw [ Finset.card_filter_add_card_filter_not ] ; aesop;
  exact h ( eq_tsub_of_add_eq <| by linarith )

/-
!-- Instance of `first_moment_general` with `S = (2n)^k − n^k` (constant by
`card_sat_clause`) and `|A| = 2^n`. -- !--
-/
theorem first_moment (n k m : ℕ) :
    ∑ F : Fin m → Clause n k, Fintype.card {a : Assign n // models a F}
      = 2 ^ n * ((n * 2) ^ k - n ^ k) ^ m := by
  by_contra h_contra;
  -- Let's rewrite the sum using the fact that multiplication by a constant out of the sum can be taken outside.
  have h_sum : ∑ F : Fin m → Clause n k, (Fintype.card {a : Assign n // ∀ j, satClause a (F j)}) = Fintype.card (Assign n) * ((n * 2) ^ k - n ^ k) ^ m := by
    convert first_moment_genera
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Proof Phase Transitions in Random k-SAT

The file `Physics/ProofPhaseTransitions/RandomKSAT.lean` now establishes, fully formally
and `sorry`-free (only `propext`, `Classical.choice`, `Quot.sound`):

* an **abstract partition-function first-moment law** `first_moment_general`: for any finite
  CSP whose every assignment satisfies a *constant* number `S` of constraints,
  `∑_F #{a : a ⊨ F} = |A| · S^m`, with the pigeonhole corollary `exists_unsat_general`
  (`|A|·S^m < |C|^m ⟹ ∃` unsatisfiable formula);
* the **Boolean k-SAT** instantiation `first_moment` (`= 2^n·((2n)^k − n^k)^m`),
  `exists_unsat`, and the density form `exists_unsat_of_real_density`
  (`2^n·(1 − 2^{−k})^m < 1 ⟹ ∃` unsat);
* **threshold monotonicity** `exists_unsat_of_density_mono`: the unsatisfiable region is an
  up-set in the clause count `m`;
* the **q-ary CSP generalization** `Qary.first_moment`
  (`= q^n·((nq)^k − (n(q−1))^k)^m`), `Qary.exists_unsat`, and
  `Qary.exists_unsat_of_real_density` with the model-independent density factor
  `1 − ((q−1)/q)^k` reducing to `1 − 2^{−k}` at `q = 2`.

These are the rigorous "upper half" (annealed/first-moment) of the satisfiability phase
transition, plus its monotonicity and its alphabet-independence. The directions below are
the natural next Lean targets. They reuse the per-constraint factorization machinery
(`card_models_form`, `card_sat_clause`, `card_qsat_clause`) already proved, and they
bridge to other catalog corpora (`Shared/EntropyAlgebra.lean`, `Tropical/`,
`Speculative/ProbabilisticMethod/Core.lean`).

## Direction 1 — A second-moment satisfiability lower bound

Prove the complementary "lower half": if the clause density is below the first-moment
threshold by a constant factor, a uniformly random formula is satisfiable with probability
bounded away from `0`. Formalize the Paley–Zygmund / Cauchy–Schwarz inequality
`(E[X])^2 ≤ P(X > 0)·E[X^2]` for `X = #{a : a ⊨ F}`, and compute `E[X^2]` as the exact
two-assignment correlation sum.

The key insight is that the second moment factorizes over clauses *exactly as the first
moment does* in `first_moment_general`, so
`E[X^2] = ∑_{a,b} ((2n)^k − 2·n^k + u(a,b))^m / (2n)^{km}`, where `u(a,b)` counts clauses
falsified by both `a` and `b` and depends only on the Hamming distance `|a Δ b|`; this
collapses the estimate to a one-dimensional sum over Hamming distance evaluable by the same
`Equiv.subtypePiEquivPi`/`Fintype.card_pi` toolkit already used for `card_unsat_clause`.
Why now? The single-assignment factorization is finished and proved; the joint
two-assignment count is the *same* `Fintype.card` computation with two predicates instead of
one, so the second moment is a finite closed-form cardinality rather than an analytic
estimate — no measure theory is needed, only one more application of the proved tools.

## Direction 2 — Exact integer crossing point of the threshold window

Strengthen `exists_unsat_of_density_mono` (which already shows the unsat phase is up
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a name, a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
