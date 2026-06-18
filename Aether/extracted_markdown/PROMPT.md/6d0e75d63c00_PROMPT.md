
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
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
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

**Title**: The foundational file `Catalog/Computation/SelfModifyingHalt.lean` established t
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Discrete Dynamics of Self-Modification

## Synthesis

The foundational file `Catalog/Computation/SelfModifyingHalt.lean` established that a
self-modifying machine is *behaviourally* a standard machine over the product space
`P × S` (the simulation theorem `selfmod_halts_iff_standard`), so its halting problem
is Turing-equivalent to the classical one. The new file
`Catalog/Computation/SelfModDynamics.lean` pushes past behavioural equivalence into the
**dynamics** of the orbit itself, treating a never-halting (`Total`) machine as a
self-map `dyn : P × S → P × S` and transporting the elementary theory of finite
dynamical systems through the bridge lemma `run_eq_iter` (run = iterate of `dyn`).

Three structural facts emerge, two of them in tension:

1. **Finiteness makes prediction trivial.** `orbit_mem_initial_segment` confines every
   iterate to the first `card (P × S)` steps, so `selfmod_reaches_bad_iff_bounded`
   turns any infinite-horizon orbit property into a bounded search. On bounded memory,
   self-modification adds *no* analytic difficulty — a sharp counterpoint to the
   undecidability of the unbounded case.
2. **Finiteness forces self-reproduction.** `selfmod_quine_cycle` shows a total finite
   machine re-enters a previously visited configuration within `card` steps: a
   finitary Kleene/quine fixed point, answering Future Direction #2 of the foundation.
3. **Reachability — not step complexity — is where control fails.**
   `alignment_obstruction` shows that under strong connectivity a single misaligned
   state poisons the whole space: there is no nonempty forward-invariant safe region,
   so no state-based monitor can keep the agent aligned (Future Direction #4).

These results pin the difficulty of "alignment" squarely on the *reachability
relation* of the dynamics, not on the complexity of the step map.

## Results Summary

| Theorem | Statement |
|---|---|
| `dyn_eventually_periodic` | Every point of a finite self-map reaches a periodic point within `card` steps, with period `≤ card`. |
| `orbit_mem_initial_segment` | Every iterate already occurs among the first `card+1` iterates. |
| `selfmod_quine_cycle` | A total finite self-modifying machine reproduces a past configuration within `card (P×S)` steps and runs forever. |
| `selfmod_reaches_bad_iff_bounded` | "Ever reaches a bad config" reduces to a length-`card` search. |
| `alignment_obstruction` / `selfmod_alignment_obstruction` | Strong connectivity + one bad state ⇒ no nonempty safe region; every start reaches a bad state. |

All theorems compile with `sorry = 0` and depend only on `propext`,
`Classical.choice`, `Quot.sound`.

## Falsifiable Research Directions

### 1. Tight cycle-length bounds for linear self-modification
The quine-cycle bound `card (P × S)` is generic and almost never tight. Conjecture:
for *affine* self-modification on `P × S = (ZMod n)^d` — step `c ↦ Ac + b` for fixed
`A, b` — the maximal cycle length equals the multiplicative order of `A` in
`GL_d(ZMod n)` (times the additive contribution of `b`), which is exponentially
smaller than `n^d` for generic `A`. **The key insight is** that affine dynamics
factor through group theory, so cycle length is an *order* computation, not a search.
**Why now?** `selfmod_quine_cycle` already isolates "cycle length" as the right
invariant and Mathlib's `ZMod`, `Matrix`, and `orderOf` APIs make the affine case
fully formalizable today. *Falsifier:* exhibit an affine `A` whose realized cycle
length strictly exceeds `orderOf A` times the `b`-period.

### 2. Minimal reachability hypothesis for the alignment obstruction
`alignment_obstruction` assumes full strong connectivity, which is stronger than
needed. Conjecture: the obstruction survives under the strictly weaker hypothesis
"every configuration reaches *some* configuration from which a bad state is
reachable" (a single recurrent bad attractor in the condensation graph). **The key
insight is** that only the *terminal strongly connected component* of the orbit graph
matters, so alignment is possible iff there exists a bad-free terminal component.
**Why now?** The proof currently routes through `forwardInvariant_eq_univ_of_stronglyConnected`;
replacing "= univ" with "contains the terminal SCC" is a localizable edit, and the
condensation of a finite relation is elementary to define. *Falsifier:* a finite
machine with a bad-free terminal SCC yet no nonempty forward-invariant safe region.

### 3. Decidability lifts to a quantitative complexity bound
`selfmod_reaches_bad_iff_bounded` proves an *iff* with a bounded search but stops short
of a `Decidable` instance and a cost. Conjecture: for a `Total` machine on `P × S` the
predicate "the run ever enters `R`" is decidable in `O(card · cost(step))` time and
`O(card · log card)` space — a Floyd cycle-detection bound — and this is optimal.
**The key insight is** that orbit confinement means you never need more than `card`
simulated steps, so the halting/safety analysis is *linear* in the memory size despite
self-modification. **Why now?** The mathematical iff is already formalized; promoting it
to `Decidable` and proving the step count is a direct application of
`orbit_mem_initial_segment`. *Falsifier:* a family of total machines forcing
`ω(card)` step simulations to decide an orbit property.

### 4. Oracle stratification by self-modification depth
Generalize `Total` to a *depth-`k`* machine that may rewrite its program at most `k`
times before becoming fixed. Conjecture: the halting problem for depth-`k` machines is
`Σ⁰₁`-complete for every `k ≥ 0` (no climb in the arithmetical hierarchy), but the
*orbit-eventual-periodicity radius* on finite memory grows like `card^{k+1}`,
separating the depth levels *quantitatively* even though they coincide
*degree-theoretically*. **The key insight is** that self-modification depth is a
*resource* parameter (refining `card`-bounds) rather than a *degree* parameter — it
cannot cross the bridge that `selfmod_halts_iff_standard` already collapses. **Why now?**
This directly fuses the catalog's `OracleBurden` jump hierarchy with the new dynamics
layer; the depth filtration is definable on top of the existing `SelfModMachine`.
*Falsifier:* a depth-`1` machine whose halting set is properly `Σ⁰₂`, or a depth-`k`
family whose periodicity radius stays `O(card)`.

### 5. Probabilistic quine cycles and absorbing alignment
Replace the deterministic `dyn` by a Markov kernel on the finite space `P × S`
(stochastic code rewriting, as in real learning/malware systems). Conjecture: the
deterministic quine cycle becomes a *recurrent class*, and the alignment obstruction
becomes "if the unique recurrent class contains a bad state, the agent visits it
infinitely often almost surely". **The key insight is** that `IsPeriodic` is the `1`-step
specialization of "positive-recurrent communicating class", so the whole Section-2 theory
is the deterministic shadow of finite Markov-chain ergodics. **Why now?** Mathlib's
growing probability/finite-state-Markov infrastructure makes the stochastic lift feasible,
and the deterministic theorems give exact targets to specialize back to. *Falsifier:* a
finite kernel whose unique recurrent class contains a bad state yet which avoids that
state with positive probability from some start.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Computation/SelfModDynamics.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Discrete Dynamics of Self-Modifying Computation

The foundational file `Catalog/Computation/SelfModifyingHalt.lean` showed that a
self-modifying machine is *behaviourally* a standard machine over the product space
`P × S` (`selfmod_halts_iff_standard`), so its halting problem is Turing-equivalent to
the classical one.  That result is about *behaviour*.  This file pushes past behaviour
into the **dynamics** of the orbit itself.

A machine that never halts (`SelfModMachine.Total`) is, on a finite configuration
space, a *self-map* `dyn : P × S → P × S`.  We transport the elementary theory of
finite dynamical systems through the bridge lemma `run_eq_iter` (run = iterate of
`dyn`) and extract three structural facts:

* **Finiteness makes prediction trivial.**  `orbit_mem_initial_segment` confines every
  iterate to the first `card (P × S)` steps, so `selfmod_reaches_bad_iff_bounded` turns
  an infinite-horizon orbit property into a bounded search.
* **Finiteness forces self-reproduction.**  `selfmod_quine_cycle` shows a total finite
  machine re-enters a previously visited configuration within `card (P × S)` steps — a
  finitary Kleene/quine fixed point.
* **Reachability — not step complexity — is where control fails.**
  `alignment_obstruction` / `selfmod_alignment_obstruction` show that under strong
  connectivity a single misaligned state poisons the whole space: there is no nonempty
  forward-invariant safe region, and every start reaches a bad state.

## Main results

* `FiniteDynamics.dyn_eventually_periodic`
* `FiniteDynamics.orbit_mem_initial_segment`
* `FiniteDynamics.alignment_obstruction`
* `selfmod_quine_cycle`
* `selfmod_reaches_bad_iff_bounded`
* `selfmod_alignment_obstruction`
-/

import Mathlib
import Catalog.Computation.SelfModifyingHalt

open Function

namespace SelfModHalt

/-
-- !-- Lab Notebook (Section 1: abstract finite dynamics) -- !--
Hypothesis: On a finite type every self-map is "eventually periodic with bounded
preperiod and period", and its whole orbit is already visible in the first `card`
iterates.  Strong connectivity should then make a single bad point unavoidable.
Result: All four abstract lemmas below proved with `sorry = 0`.
Insight: The single pigeonhole collision `i < j ≤ card`, `f^[i] = f^[j]`, is the
generator of *every* finite-dynamics fact used downstream — eventual periodicity,
orbit confinement, and (via `ForwardInvariant`) the alignment obstruction.
Failure analysis: A naive `rw [← e]` to fold `n = (n - p) + p` rewrote both sides;
the fix was a directed `conv_lhs` rewrite.  `omega` discharges all index arithmetic.
-/

namespace FiniteDynamics

variable {A : Type*}

/-- `Reaches f x y`: `y` lies on the forward orbit of `x` under `f`. -/
def Reaches (f : A → A) (x y : A) : Prop := ∃ n : ℕ, f^[n] x = y

/-- `f` is strongly connected: every configuration reaches every other. -/
def StronglyConnected (f : A → A) : Prop := ∀ x y, Reaches f x y

/-- A set is forward-invariant under `f` if `f` maps it into itself. -/
def ForwardInvariant (f : A → A) (R : Set A) : Prop := ∀ x ∈ R, f x ∈ R

section Finite

variable [Fintype A]

/-- **Pigeonhole collision.**  On a finite type, two distinct iterate indices in
`[0, card A]` already collide.

-- !-- The orbit map `Fin (card+1) → A` cannot be injective (`card+1 > card`), so
two iterate indices agree; order them. --!-- -/
theorem iterate_collision (f : A → A) (x : A) :
    ∃ i j : ℕ, i < j ∧ j ≤ Fintype.card A ∧ f^[i] x = f^[j] x := by
  have h : Fintype.card A < Fintype.card (Fin (Fintype.card A + 1)) := by simp
  obtain ⟨a, b, hab, hfab⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun k : Fin (Fintype.card A + 1) => f^[k] x) h
  rcases lt_or_gt_of_ne hab with h1 | h1
  · exact ⟨a, b, h1, Nat.lt_succ_iff.mp b.2, hfab⟩
  · exact ⟨b, a, h1, Nat.lt_succ_iff.mp a.2, hfab.symm⟩

/-- **Eventual periodicity with bounded preperiod and period.**  Every point of a
finite self-map reaches, within `card A` steps, a point that is periodic with a
positive period `≤ card A`.

-- !-- Take the collision `i < j`; the preperiod is `i` and the period is `j - i`,
since `f^[j-i] (f^[i] x) = f^[j] x = f^[i] x`. --!-- -/
theorem dyn_eventually_periodic (f : A → A) (x : A) :
    ∃ k p : ℕ, k ≤ Fintype.card A ∧ 0 < p ∧ p ≤ Fintype.card A ∧
      f^[p] (f^[k] x) = f^[k] x := by
  obtain ⟨i, j, hij, hj, heq⟩ := iterate_collision f x
  refine ⟨i, j - i, le_trans (le_of_lt hij) hj, by omega, by omega, ?_⟩
  rw [← Function.iterate_add_apply]
  have : j - i + i = j := by omega
  rw [this, heq]

/-- **Orbit confinement.**  Every iterate of a finite self-map already occurs among
the first `card A + 1` iterates.

-- !-- From the collision, the orbit is periodic past index `i` with period `p`;
strong induction folds any `n > card A` down by `p` while staying `≥ i`. --!-- -/
theorem orbit_mem_initial_segment (f : A → A) (x : A) (n : ℕ) :
    ∃ k : ℕ, k ≤ Fintype.card A ∧ f^[n] x = f^[k] x := by
  obtain ⟨i, j, hij, hj, heq⟩ := iterate_collision f x
  set p := j - i with hp
  have hper : ∀ m, i ≤ m → f^[m + p] x = f^[m] x := by
    intro m hm
    have : m + p = (m - i) + (i + p) := by omega
    rw [this, Function.iterate_add_apply]
    have hjj : i + p = j := by omega
    rw [hjj, ← heq, ← Function.iterate_add_apply]
    congr 1; omega
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    by_cases hn : n ≤ Fintype.card A
    · exact ⟨n, hn, rfl⟩
    · have hge : i ≤ n - p := by omega
      have e : n - p + p = n := by omega
      have key : f^[n] x = f^[n - p] x := by
        conv_lhs => rw [← e]; rw [hper _ hge]
      obtain ⟨k, hk, hkeq⟩ := ih (n - p) (by omega)
      exact ⟨k, hk, by rw [key, hkeq]⟩

end Finite

/-- Forward invariance is preserved by iteration. -/
theorem iterate_mem_of_forwardInvariant (f : A → A) (R : Set A)
    (h : ForwardInvariant f R) {x : A} (hx : x ∈ R) (n : ℕ) : f^[n] x ∈ R := by
  induction n with
  | zero => simpa
  | succ n ih => rw [Function.iterate_succ_apply']; exact h _ ih

/-- A nonempty forward-invariant set of a strongly connected self-map is everything.

-- !-- Pick `x ∈ R`; for any `y`, strong connectivity gives `f^[n] x = y`, and
`iterate_mem_of_forwardInvariant` keeps the orbit inside `R`. --!-- -/
theorem forwardInvariant_eq_univ_of_stronglyConnected (f : A → A)
    (hsc : StronglyConnected f) (R : Set A) (hne : R.Nonempty)
    (hinv : ForwardInvariant f R) : R = Set.univ := by
  ext y
  simp only [Set.mem_univ, iff_true]
  obtain ⟨x, hx⟩ := hne
  obtain ⟨n, hn⟩ := hsc x y
  rw [← hn]; exact iterate_mem_of_forwardInvariant f R hinv hx n

/-- **Alignment obstruction (abstract).**  If a self-map is strongly connected and at
least one state is "bad", then there is no nonempty forward-invariant set of
exclusively safe (non-bad) states: no state-based monitor can confine the dynamics to
a safe region.

-- !-- A safe forward-invariant region would, by
`forwardInvariant_eq_univ_of_stronglyConnected`, be all of `A` — but it must then
contain the bad state, contradiction. --!-- -/
theorem alignment_obstruction (f : A → A) (hsc : StronglyConnected f)
    (bad : A → Prop) (hbad : ∃ b, bad b) :
    ¬ ∃ R : Set A, R.Nonempty ∧ ForwardInvariant f R ∧ (∀ x ∈ R, ¬ bad x) := by
  rintro ⟨R, hne, hinv, hsafe⟩
  obtain ⟨b, hb⟩ := hbad
  have : R = Set.univ := forwardInvariant_eq_univ_of_stronglyConnected f hsc R hne hinv
  exact hsafe b (this ▸ Set.mem_univ b) hb

/-- Under strong connectivity, every state reaches every bad state, hence reaches the
bad set. -/
theorem reaches_bad_of_stronglyConnected (f : A → A) (hsc : StronglyConnected f)
    (bad : A → Prop) {b : A} (hb : bad b) (x : A) :
    ∃ n : ℕ, bad (f^[n] x) := by
  obtain ⟨n, hn⟩ := hsc x b
  exact ⟨n, hn ▸ hb⟩

end FiniteDynamics

/-
-- !-- Lab Notebook (Section 2: self-modifying machines as dynamics) -- !--
Hypothesis: A `Total` (never-h
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Discrete Dynamics of Self-Modification

## Synthesis

The foundational file `Catalog/Computation/SelfModifyingHalt.lean` established that a
self-modifying machine is *behaviourally* a standard machine over the product space
`P × S` (the simulation theorem `selfmod_halts_iff_standard`), so its halting problem
is Turing-equivalent to the classical one. The new file
`Catalog/Computation/SelfModDynamics.lean` pushes past behavioural equivalence into the
**dynamics** of the orbit itself, treating a never-halting (`SelfModMachine.Total`)
machine as a self-map `dyn : P × S → P × S` and transporting the elementary theory of
finite dynamical systems through the bridge lemma `run_eq_iter` (run = iterate of `dyn`).

Three structural facts emerge, two of them in tension:

1. **Finiteness makes prediction trivial.** `FiniteDynamics.orbit_mem_initial_segment`
   confines every iterate to the first `card (P × S)` steps, so
   `selfmod_reaches_bad_iff_bounded` turns any infinite-horizon orbit property into a
   bounded search. On bounded memory, self-modification adds *no* analytic difficulty —
   a sharp counterpoint to the undecidability of the unbounded case
   (`no_selfmod_halting_decider`).
2. **Finiteness forces self-reproduction.** `selfmod_quine_cycle` shows a total finite
   machine re-enters a previously visited configuration within `card (P × S)` steps: a
   finitary Kleene/quine fixed point, answering Future Direction #2 of the foundation.
3. **Reachability — not step complexity — is where control fails.**
   `selfmod_alignment_obstruction` (built on the abstract `alignment_obstruction`) shows
   that under strong connectivity a single misaligned state poisons the whole space:
   there is no nonempty forward-invariant safe region, so no state-based monitor can keep
   the agent aligned (Future Direction #4 of the foundation).

These results pin the difficulty of "alignment" squarely on the *reachability relation*
of the dynamics, not on the complexity of the step map. The bridge `run_eq_iter`
collapses the machine-theoretic and dynamical pictures: every machine fact below is a
specialization of a one-line fact about the self-map `dyn`, all generated by the single
pigeonhole collision `iterate_collision`.

## Results Summary

| Theorem | Statement |
|---|---|
| `FiniteDynamics.iterate_collision` | Two iterate indices `i < j ≤ card A` collide for any finite self-map. |
| `FiniteDynamics.dyn_eventually_periodic` | Every point reaches a periodic point within `card A` steps, period `≤ card A`. |
| `FiniteDynamics.orbit_mem_initial_segment` | Every iterate already occurs among the first `card A + 1` iterates. |
| `FiniteDynamics.alignment_obstruction` | Strong connectivity + one bad state ⇒ no nonempty safe forward-invariant region. |
| `run_eq_iter` | A total machine's `run` equals iteration of `dyn`. |
| `selfmod_quine_cycle` | A total finite machine reproduces a past configuration within `card (P×S)` steps and runs forever. |
| `se
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
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
