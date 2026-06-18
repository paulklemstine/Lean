
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: The file `Catalog/Logic/OrdinalCollapsingBridge.lean` formalizes a genuine
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Proof-Theoretic Bridge: Ordinal Analysis Across Systems

The file `Catalog/Logic/OrdinalCollapsingBridge.lean` formalizes a genuine
fragment of ordinal analysis inside Mathlib's Veblen hierarchy. It defines
ε₀ = `veblen 1 0` (the proof-theoretic ordinal of Peano Arithmetic) and
Γ₀ = `nfp (veblen · 0) 0`, which in Bachmann–Buchholz ordinal collapsing
notation is exactly ψ(Ω^ω) (the Feferman–Schütte ordinal). The headline result
`eps0_lt_psiOmegaOmega` proves ε₀ < ψ(Ω^ω); supporting theorems show ε₀ is the
least epsilon number, Γ₀ is the least strongly critical ordinal, and the diagonal
Veblen map `ptStrength : o ↦ veblen o 0` is a strictly monotone order-preserving
"bridge" whose values below Γ₀ stay below Γ₀. One strengthening,
`epsilon_numbers_unbounded_below_psi`, is left as an explicit open `sorry`.

The five directions below are concrete, falsifiable next steps. Each builds on the
exact definitions and lemmas already proven, so progress is measurable by whether
the corresponding Lean statement type-checks without `sorry`.

## 1. Close the unboundedness of epsilon numbers below Γ₀

Prove `epsilon_numbers_unbounded_below_psi`: for every `b < Γ₀` there is an epsilon
number `a` with `b < a < Γ₀`. The natural witness is `a := nfp (veblen 0) (Order.succ b)`,
which is a fixed point of `veblen 0` (hence `ω^a = a`) and exceeds `b`; the missing
piece is `a < Γ₀`. **The key insight is** that Γ₀, being strongly critical
(`psiOmegaOmega_fp`), is closed not just under the diagonal map `veblen · 0` but
under `veblen 1 = deriv (veblen 0)` applied to any argument below it, so the next
epsilon number after `b` cannot escape the ceiling. **Why now?** The closure lemma
`ptStrength_lt_psiOmegaOmega` already proven is the `a = 0` slice of exactly the
two-variable closure `veblen o c < Γ₀` for `o, c < Γ₀` needed here; generalizing
its one-line proof from `0` to arbitrary second argument is the whole task.

## 2. The Veblen-closure characterization of Γ₀

Prove the two-variable closure theorem `∀ o c, o < Γ₀ → c < Γ₀ → veblen o c < Γ₀`
and its converse, giving Γ₀ = least ordinal closed under binary Veblen. **The key
insight is** that strong criticality (`veblen Γ₀ 0 = Γ₀`) is equivalent to full
Veblen-closure, because `veblen o c` for `o < Γ₀` lies in the range of `veblen o`
whose fixed points are cofinal below Γ₀. **Why now?** Mathlib already supplies
`veblen_veblen_of_lt`, `veblen_lt_veblen_iff`, and `right_le_veblen`; combining them
with `psiOmegaOmega_fp` turns this into a finite case split rather than new theory.

## 3. A second rung of the bridge: ε₁ and the successor epsilon ordinals

Define `epsAt : Ordinal → Ordinal := veblen 1` so that `epsAt 0 = ε₀`, and prove
`epsAt` is a strictly monotone normal function whose values are all `< Γ₀`,
realizing the tower ε₀ < ε₁ < ε₂ < ⋯ of successive proof-theoretic ordinals.
**The key insight is** that `veblen 1 = deriv (veblen 0)` is normal by
`isNormal_deriv`, so the entire ε-tower is just the orbit of one normal function,
and each rung lands below Γ₀ by Direction 2. **Why now?** `veblen_succ` already
identifies `veblen 1` with `deriv (veblen 0)`, so the tower needs no new
definitions — only the normality and boundedness wrappers.

## 4. An order embedding `PA ↪ KP` of ordinal notations

Package `ptStrength` as a bundled `o ↪o veblen o 0` `OrderEmbedding` and prove it
restricts to an order isomorphism from `Set.Iio Γ₀` onto the strongly-critical-free
ordinals, formalizing the "explicit order-preserving map from the proof-theoretic
ordinals of one system into another." **The key insight is** that a strictly
monotone map on a linear order is automatically order-reflecting, so
`ptStrength_strictMono` already gives the embedding; only the surjectivity onto the
fixed-point-free segment is new. **Why now?** Mathlib's `StrictMono.orderEmbedding`
and `OrderIso` API make the bundling mechanical once the range is characterized by
Direction 2.

## 5. Connect ε₀ to PA's actual consistency strength via `Ordinal.CNF`

Bridge the abstract ordinal ε₀ to the *syntactic* side by proving that the Cantor
normal form `Ordinal.CNF ω` terminates exactly on ordinals `< ε₀`, i.e. ε₀ is the
least ordinal not reachable by finite ω-base CNF towers. **The key insight is** that
`ω^a = a` (our `omega_opow_eps0`) is precisely the failure of CNF to make progress,
so ε₀ is the supremum of the iterated-exponential ordinals that index PA proofs.
**Why now?** Mathlib's `Mathlib.SetTheory.Ordinal.CantorNormalForm` provides
`Ordinal.CNF` with completeness lemmas, and `omega_opow_eps0` / `eps0_least` give the
fixed-point boundary, so the statement reduces to an induction on CNF length.

**Concept description**: # Future Directions — Proof-Theoretic Bridge: Ordinal Analysis Across Systems

The file `Catalog/Logic/OrdinalCollapsingBridge.lean` formalizes a genuine
fragment of ordinal analysis inside Mathlib's Veblen hierarchy. It defines
ε₀ = `veblen 1 0` (the proof-theoretic ordinal of Peano Arithmetic) and
Γ₀ = `nfp (veblen · 0) 0`, which in Bachmann–Buchholz ordinal collapsing
notation is exactly ψ(Ω^ω) (the Feferman–Schütte ordinal). The headline result
`eps0_lt_psiOmegaOmega` proves ε₀ < ψ(Ω^ω); supporting theorems show ε₀ is the
least epsilon number, Γ₀ is the least strongly critical ordinal, and the diagonal
Veblen map `ptStrength : o ↦ veblen o 0` is a strictly monotone order-preserving
"bridge" whose values below Γ₀ stay below Γ₀. One strengthening,
`epsilon_numbers_unbounded_below_psi`, is left as an explicit open `sorry`.

The five directions below are concrete, falsifiable next steps. Each builds on the
exact definitions and lemmas already proven, so progress is measurable by whether
the corresponding Lean statement type-checks without `sorry`.

## 1. Close the unboundedness of epsilon numbers below Γ₀

Prove `epsilon_numbers_unbounded_below_psi`: for every `b < Γ₀` there is an epsilon
number `a` with `b < a < Γ₀`. The natural witness is `a := nfp (veblen 0) (Order.succ b)`,
which is a fixed point of `veblen 0` (hence `ω^a = a`) and exceeds `b`; the missing
piece is `a < Γ₀`. **The key insight is** that Γ₀, being strongly critical
(`psiOmegaOmega_fp`), is closed not just under the diagonal map `veblen · 0` but
under `veblen 1 = deriv (veblen 0)` applied to any argument below it, so the next
epsilon number after `b` cannot escape the ceiling. **Why now?** The closure lemma
`ptStrength_lt_psiOmegaOmega` already proven is the `a = 0` slice of exactly the
two-variable closure `veblen o c < Γ₀` for `o, c < Γ₀` needed here; generalizing
its one-line proof from `0` to arbitrary second argument is the whole task.

## 2. The Veblen-closure characterization of Γ₀

Prove the two-variable closure theorem `∀ o c, o < Γ₀ → c < Γ₀ → veblen o c < Γ₀`
and its converse, giving Γ₀ = least ordinal closed under binary Veblen. **The key
insight is** that strong criticality (`veblen Γ₀ 0 = Γ₀`) is equivalent to full
Veblen-closure, because `veblen o c` for `o < Γ₀` lies in the range of `veblen o`
whose fixed points are cofinal below Γ₀. **Why now?** Mathlib already supplies
`veblen_veblen_of_lt`, `veblen_lt_veblen_iff`, and `right_le_veblen`; combining them
with `psiOmegaOmega_fp` turns this into a finite case split rather than new theory.

## 3. A second rung of the bridge: ε₁ and the successor epsilon ordinals

Define `epsAt : Ordinal → Ordinal := veblen 1` so that `epsAt 0 = ε₀`, and prove
`epsAt` is a strictly monotone normal function whose values are all `< Γ₀`,
realizing the tower ε₀ < ε₁ < ε₂ < ⋯ of successive proof-theoretic ordinals.
**The key insight is** that `veblen 1 = deriv (veblen 0)` is normal by
`isNormal_deriv`, so the entire ε-tower is just the orbit of one normal function,
and each rung lands below Γ₀ by Direction 2. **Why now?** `veblen_succ` already
identifies `veblen 1` with `deriv (veblen 0)`, so the tower needs no new
definitions — only the normality and boundedness wrappers.

## 4. An order embedding `PA ↪ KP` of ordinal notations

Package `ptStrength` as a bundled `o ↪o veblen o 0` `OrderEmbedding` and prove it
restricts to an order isomorphism from `Set.Iio Γ₀` onto the strongly-critical-free
ordinals, formalizing the "explicit order-preserving map from the proof-theoretic
ordinals of one system into another." **The key insight is** that a strictly
monotone map on a linear order is automatically order-reflecting, so
`ptStrength_strictMono` already gives the embedding; only the surjectivity onto the
fixed-point-free segment is new. **Why now?** Mathlib's `StrictMono.orderEmbedding`
and `OrderIso` API make the bundling mechanical once the range is characterized by
Direction 2.

## 5. Connect ε₀ to PA's actual consistency strength via `Ordinal.CNF`

Bridge the abstract ordinal ε₀ to the *syntactic* side by proving that the Cantor
normal form `Ordinal.CNF ω` terminates exactly on ordinals `< ε₀`, i.e. ε₀ is the
least ordinal not reachable by finite ω-base CNF towers. **The key insight is** that
`ω^a = a` (our `omega_opow_eps0`) is precisely the failure of CNF to make progress,
so ε₀ is the supremum of the iterated-exponential ordinals that index PA proofs.
**Why now?** Mathlib's `Mathlib.SetTheory.Ordinal.CantorNormalForm` provides
`Ordinal.CNF` with completeness lemmas, and `omega_opow_eps0` / `eps0_least` give the
fixed-point boundary, so the statement reduces to an induction on CNF length.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
