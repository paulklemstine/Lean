# Future Directions: Provability Logic as a Fixed-Point Theory (cycle: DCC core)

## Synthesis of this cycle

The previous cycle built the order-theoretic core of Gödel–Löb provability logic `GL`
as a `GLOperator` typeclass on a Heyting algebra (`Catalog/Logic/LobFixedPoint.lean`),
proving axiom `4` from Löb, Gödel's second incompleteness theorem algebraically, the
explicit de Jongh–Sambin fixed point `glFix c = □c ⇨ c`, and — crucially — the
*uniqueness* of modalised fixed points for **arbitrary** box-congruent operators
(`modalised_fixedPoint_unique`). Existence, however, was only ever exhibited for the one
explicit map `p ↦ □p ⇨ c`.

This cycle (`Catalog/Logic/LobFixedPointIteration.lean`) closes that asymmetry by
isolating the **exact order condition** under which the de Jongh–Sambin fixed point
becomes a *terminating computation*. The headline result is that on any `GLOperator`
whose order satisfies the descending chain condition (`WellFoundedLT`), every
box-congruent operator `f` with `Monotone (f ∘ f)` has a **unique** fixed point, obtained
constructively as the stabilised value of the descending iteration `(f ∘ f)^[n] ⊤`. The
hypothesis `Monotone (f ∘ f)` is met by monotone *and* antitone `f`, so the canonical
(antitone) Gödel/Sambin map is a special case and the iterative fixed point is provably
the closed form `glFix c`. The finite frames `(Fin n, <)` are exhibited (`FinGL`) as the
clean home where DCC holds automatically and the iteration always terminates.

## Results summary

* `exists_fixedPoint_of_monotone_wf` — purely order-theoretic: on a `WellFoundedLT` order
  with top, a monotone map has a fixed point, found as the minimum of `g^[n] ⊤`.
* `GLOperator.boxCongruent_comp` — box-congruence is closed under composition; this is the
  single place where transitivity / axiom `4` is consumed.
* `GLOperator.boxCongruent_existsUnique_fixedPoint` — the full de Jongh–Sambin theorem
  (existence + uniqueness) under DCC, decoupling existence (DCC, order-theoretic) from
  uniqueness (Löb's rule, modal).
* `GLOperator.sambin_existsUnique_fixedPoint` + `sambin_fixedPoint_eq_glFix` — the
  canonical map's iterative fixed point equals the explicit `glFix c`.
* `FinGL`, `finGL_fixedPoint_property`, `finGL_sambin_fixedPoint` — finite GL frames have
  the constructive fixed-point property; all theorems are axiom-clean
  (`propext`, `Classical.choice`, `Quot.sound`).

## Research directions

### 1. Quantitative convergence: the iteration stabilises in two steps
The descending iteration `(f ∘ f)^[n] ⊤` provably stabilises under DCC, but for the
Sambin map it is observed to reach `glFix c` after only `f^[2](⊤) = □c ⇨ c`. **Conjecture:**
for the Sambin map `p ↦ □p ⇨ c`, `(f ∘ f)^[1] ⊤ = (f ∘ f)^[2] ⊤ = glFix c` in *every*
`GLOperator`, with no DCC hypothesis — the iteration is eventually constant from step one.
*The key insight is* that `glFix_box` already pins the provability of the fixed point
(`□(glFix c) = □c`), so one extra application of the map cannot move it; convergence is
therefore an identity, not a limit. *Why now?* The iteration machinery and `glFix_box` are
both in hand, so this is a direct two-line `Function.iterate` computation that would upgrade
the existence theorem from "a limit exists under DCC" to "a closed form is reached in a
bounded number of steps unconditionally."

### 2. Simultaneous (vectorial) fixed points
The de Jongh–Sambin theorem extends to *systems* `pᵢ = fᵢ(p₁,…,p_k)` where each `pⱼ`
occurs only under `□`. **Conjecture:** a tuple of jointly box-congruent operators on a DCC
algebra has a unique simultaneous fixed point, again computable by componentwise descending
iteration on the product order. *The key insight is* that the product of finitely many DCC
orders is DCC, and joint box-congruence on `H^k` is exactly componentwise box-congruence
plus the diagonal `□`, so `boxCongruent_comp` and `exists_fixedPoint_of_monotone_wf` lift
verbatim to `H^k`. *Why now?* `exists_fixedPoint_of_monotone_wf` is stated for an abstract
`WellFoundedLT` order, so instantiating it at the product order requires no new analysis —
only a `Pi`/`Prod` `WellFoundedLT` instance and a vectorial `BoxCongruent`.

### 3. DCC is necessary, not just sufficient
We proved DCC ⇒ constructive existence, and noted the canonical non-DCC models
`Set ℕ`, `Set Ordinal` rely on the explicit `glFix` instead. **Falsifiable conjecture:**
there is a `GLOperator` and a *monotone* box-congruent operator with **no** fixed point,
witnessing that DCC (or some chain condition) is genuinely required for the monotone case.
*The key insight is* that monotone box-congruent operators are unconstrained by Löb's rule
(which only forces uniqueness, never existence), so a strictly increasing monotone map with
no fixed point on a non-DCC GL algebra should exist. *Why now?* The `OrdGL` model already
exhibits proper-class strictly increasing chains (`ordinal_consistency_strictMono`); turning
one into a fixed-point-free monotone box-congruent operator would sharply delimit the new
existence theorem and confirm the Lab-Notebook failure analysis.

### 4. The fixed-point property as a finiteness/Noetherianity invariant
`FinGL` shows finite frames enjoy the constructive fixed-point property. **Conjecture:**
a `GLOperator` on a complete Heyting algebra has the constructive (iterative) fixed-point
property for all monotone-square box-congruent operators **iff** its order is `WellFoundedLT`
(Noetherian). *The key insight is* that the descending iteration is the universal fixed-point
construction, so its termination for *all* such operators should be equivalent to the order
admitting no infinite descent. *Why now?* One direction is exactly this cycle's theorem; the
converse asks for a single operator whose iteration encodes a given descending chain, which
the frame-box construction `wfBox` is well suited to build.

### 5. Bridge to the Kripke semantics: completeness of the DCC core
`Catalog/Logic/GLKripke.lean` validates Löb on finite transitive irreflexive frames, and
`FinGL` is exactly the algebra of such a frame. **Conjecture:** the explicit fixed points
computed algebraically by the descending iteration coincide, world-by-world, with the
semantic fixed points definable in the Kripke model, giving an algebraic *proof* of the
semantic fixed-point lemma underlying GL completeness. *The key insight is* that `wfBox` is
the algebraic shadow of `GLFrame.boxSet`, so the iteration `(f ∘ f)^[n] ⊤` is literally the
stagewise evaluation of a modal fixed point over frame depth. *Why now?* `FinGL` already
identifies the two boxes definitionally (`finGL_box`), so the remaining step is to match the
iteration index with the frame's converse-well-founded rank — a computation the `Iio`-ladder
results (`ordBox_Iio`, `natBox_iterate_eq_Iio`) have already templated.
