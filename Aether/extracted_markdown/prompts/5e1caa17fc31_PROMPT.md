            # Phase A Research Mission v18: Derived from the v16b research cycle that produced

            ## Concept
            **Domain**: Bridges
            **Research mode**: team
            **Title**: Derived from the v16b research cycle that produced
            **Description**: # Future Directions — Korselt's Criterion & the Multiplicative-Order Bridge

Derived from the v16b research cycle that produced
`Catalog/Shared/KorseltCriterion.lean` and
`Catalog/Cryptography/KorseltGroupActionBridge.lean`.

This cycle proved, unconditionally, the *constructive* direction of Korselt's
criterion (squarefree + `(p-1) ∣ (n-1)` ⇒ absolute Fermat pseudoprime) and lifted
its conclusion to an order-divisibility condition on `(ℤ/nℤ)ˣ`, then bridged it into
the `CryptoGroupAction` framework. The cycle's analysis (the converse is "true but
harder"; `n-1` is not special to the proof; freeness recovers the order condition)
suggests the following falsifiable conjectures.

## C1 — Korselt's criterion is an iff (the hard converse)

**Conjecture.** If `n > 1` is composite and `a^(n-1) ≡ 1 [MOD n]` for every `a`
coprime to `n` (i.e. `IsFermatPsp n`), then `IsKorselt n`: `n` is squarefree and
`(p-1) ∣ (n-1)` for every prime `p ∣ n`.

**The key insight is** that the converse is forced by the *existence of a primitive
root mod each prime power factor*: if `p^2 ∣ n`, a generator of `(ℤ/p^2ℤ)ˣ` has order
`p(p-1) ∤ n-1`, contradicting the pseudoprime property; and a primitive root mod `p`
shows `(p-1) ∣ n-1`. Formalizing this needs only `ZMod.instIsCyclicUnits` (cyclicity
of `(ℤ/p^kℤ)ˣ` for odd `p`) plus a CRT splitting, both available in Mathlib.

**Why now?** The forward direction and the CRT reassembly lemma
(`dvd_of_squarefree_forall_prime_dvd`) are already proved in this cycle; the converse
reuses the same decomposition machinery in reverse, so the marginal cost is a single
cyclic-group lemma rather than a new theory.

## C2 — Generalized Korselt with an arbitrary exponent

**Conjecture.** For squarefree `n` and any `e ≥ 1`, `a^e ≡ 1 [MOD n]` for all `a`
coprime to `n` **iff** `(p-1) ∣ e` for every prime `p ∣ n`. The classical Korselt
criterion is the case `e = n-1`.

**The key insight is** that the value `n-1` plays *no role* in the forward proof:
`pow_modEq_one_of_prime_factor` only consumes `(p-1) ∣ e`. The exponent `n-1` is a
historical artifact of the Fermat test, not a mathematical necessity — so the true
invariant is the universal exponent `λ(n) = lcm{p-1}` (Carmichael's lambda).

**Why now?** `korselt_imp_fermatPsp` is already parametric in the divisibility
hypothesis; abstracting `n-1` to a free `e` is a direct generalization that
immediately connects to `Nat.Carmichael`-style universal-exponent results.

## C3 — Order spectrum collapse is detectable by a single random base

**Conjecture.** For a Korselt number `n` with `k` distinct prime factors, the
fraction of bases `a ∈ (ℤ/nℤ)ˣ` whose order is a *proper* divisor of `n-1` is at
least `1 - 2^{-(k-1)}`; hence a single uniformly random Fermat–Miller–Rabin witness
already exposes the order collapse with probability bounded away from `0`.

**The key insight is** that `korselt_orderOf_dvd` says *every* unit has order dividing
`n-1`, so the Miller–Rabin refinement detects compositeness precisely by finding a
unit whose order is even with a `2`-adic valuation incompatible with the per-prime
factors — a counting statement over the product group `∏ (ℤ/pℤ)ˣ`.

**Why now?** The bridge file already exposes `orderOf g ∣ n-1` as a first-class fact;
turning it into a density statement only needs `Fintype.card` arithmetic on the CRT
product decomposition, with no new number theory.

## C4 — Free torsors encode pseudoprimality (geometric Korselt)

**Conjecture.** A composite `n` is Carmichael **iff** in the regular `FreeTrans` of
`(ℤ/nℤ)ˣ` on itself, the "exponentiate-by-`n-1`" endomorphism of the torsor is the
constant identity map; and the *number* of fixed points of `act (g^d)` for `d ∣ n-1`
recovers the full order spectrum of `(ℤ/nℤ)ˣ`.

**The key insight is** that `korselt_freeTrans_recovers_order` shows freeness turns
the algebraic order condition into a *geometric* triviality of the torsor — so
pseudoprimality is literally a statement about the action having no nontrivial
"rotations of period `n-1`". This is the precise sense in which the CSI-FiSh torsor
model "sees" Carmichael numbers.

**Why now?** Both halves of the equivalence (action-trivial ⇐ Korselt, and order ⇐
action-trivial via freeness) are proved in this cycle; only the fixed-point counting
direction remains, and it is a clean orbit–stabilizer computation.

## C5 — Cross-domain hardness transfer

**Conjecture.** No `CryptoGroupAction` of `(ℤ/nℤ)ˣ` can be *both* free and have its
GAIP (group-action inverse problem) be classically hard when `n` is Korselt, because
the universal relation `g^(n-1) = 1` shrinks the effective key space to exponent
`λ(n) ∣ n-1`, giving a `√λ(n)`-time baby-step/giant-step attack.

**The key insight is** that the multiplicative-order bridge converts a *number-
theoretic* defect (Carmichael-ness) into a *cryptographic* weakness (small group
exponent), so pseudoprimality of the modulus is a direct security reduction, not a
heuristic.

**Why now?** The bridge `korselt_action_pow_trivial` already lives in the
Cryptography namespace and consumes the Shared-domain theorem; quantifying the
resulting key-space collapse is the natural next theorem on this exact interface.

            **Mathematical framing**: # Future Directions — Korselt's Criterion & the Multiplicative-Order Bridge

Derived from the v16b research cycle that produced
`Catalog/Shared/KorseltCriterion.lean` and
`Catalog/Cryptography/KorseltGroupActionBridge.lean`.

This cycle proved, unconditionally, the *constructive* direction of Korselt's
criterion (squarefree + `(p-1) ∣ (n-1)` ⇒ absolute Fermat pseudoprime) and lifted
its conclusion to an order-divisibility condition on `(ℤ/nℤ)ˣ`, then bridged it into
the `CryptoGroupAction` framework. The cycle's analysis (the converse is "true but
harder"; `n-1` is not special to the proof; freeness recovers the order condition)
suggests the following falsifiable conjectures.

## C1 — Korselt's criterion is an iff (the hard converse)

**Conjecture.** If `n > 1` is composite and `a^(n-1) ≡ 1 [MOD n]` for every `a`
coprime to `n` (i.e. `IsFermatPsp n`), then `IsKorselt n`: `n` is squarefree and
`(p-1) ∣ (n-1)` for every prime `p ∣ n`.

**The key insight is** that the converse is forced by the *existence of a primitive
root mod each prime power factor*: if `p^2 ∣ n`, a generator of `(ℤ/p^2ℤ)ˣ` has order
`p(p-1) ∤ n-1`, contradicting the pseudoprime property; and a primitive root mod `p`
shows `(p-1) ∣ n-1`. Formalizing this needs only `ZMod.instIsCyclicUnits` (cyclicity
of `(ℤ/p^kℤ)ˣ` for odd `p`) plus a CRT splitting, both available in Mathlib.

**Why now?** The forward direction and the CRT reassembly lemma
(`dvd_of_squarefree_forall_prime_dvd`) are already proved in this cycle; the converse
reuses the same decomposition machinery in reverse, so the marginal cost is a single
cyclic-group lemma rather than a new theory.

## C2 — Generalized Korselt with an arbitrary exponent

**Conjecture.** For squarefree `n` and any `e ≥ 1`, `a^e ≡ 1 [MOD n]` for all `a`
coprime to `n` **iff** `(p-1) ∣ e` for every prime `p ∣ n`. The classical Korselt
criterion is the case `e = n-1`.

**The key insight is** that the value `n-1` plays *no role* in the forward proof:
`pow_modEq_one_of_prime_factor` only consumes `(p-1) ∣ e`. The exponent `n-1` is a
historical artifact of the Fermat test, not a mathematical necessity — so the true
invariant is the universal exponent `λ(n) = lcm{p-1}` (Carmichael's lambda).

**Why now?** `korselt_imp_fermatPsp` is already parametric in the divisibility
hypothesis; abstracting `n-1` to a free `e` is a direct generalization that
immediately connects to `Nat.Carmichael`-style universal-exponent results.

## C3 — Order spectrum collapse is detectable by a single random base

**Conjecture.** For a Korselt number `n` with `k` distinct prime factors, the
fraction of bases `a ∈ (ℤ/nℤ)ˣ` whose order is a *proper* divisor of `n-1` is at
least `1 - 2^{-(k-1)}`; hence a single uniformly random Fermat–Miller–Rabin witness
already exposes the order collapse with probability bounded away from `0`.

**The key insight is** that `korselt_orderOf_dvd` says *every* unit has order dividing
`n-1`, so the Miller–Rabin refinement detects compositeness precisely by finding a
unit whose order is even with a `2`-adic valuation incompatible with the per-prime
factors — a counting statement over the product group `∏ (ℤ/pℤ)ˣ`.

**Why now?** The bridge file already exposes `orderOf g ∣ n-1` as a first-class fact;
turning it into a density statement only needs `Fintype.card` arithmetic on the CRT
product decomposition, with no new number theory.

## C4 — Free torsors encode pseudoprimality (geometric Korselt)

**Conjecture.** A composite `n` is Carmichael **iff** in the regular `FreeTrans` of
`(ℤ/nℤ)ˣ` on itself, the "exponentiate-by-`n-1`" endomorphism of the torsor is the
constant identity map; and the *number* of fixed points of `act (g^d)` for `d ∣ n-1`
recovers the full order spectrum of `(ℤ/nℤ)ˣ`.

**The key insight is** that `korselt_freeTrans_recovers_order` shows freeness turns
the algebraic order condition into a *geometric* triviality of the torsor — so
pseudoprimality is literally a statement about the action having no nontrivial
"rotations of period `n-1`". This is the precise sense in which the CSI-FiSh torsor
model "sees" Carmichael numbers.

**Why now?** Both halves of the equivalence (action-trivial ⇐ Korselt, and order ⇐
action-trivial via freeness) are proved in this cycle; only the fixed-point counting
direction remains, and it is a clean orbit–stabilizer computation.

## C5 — Cross-domain hardness transfer

**Conjecture.** No `CryptoGroupAction` of `(ℤ/nℤ)ˣ` can be *both* free and have its
GAIP (group-action inverse problem) be classically hard when `n` is Korselt, because
the universal relation `g^(n-1) = 1` shrinks the effective key space to exponent
`λ(n) ∣ n-1`, giving a `√λ(n)`-time baby-step/giant-step attack.

**The key insight is** that the multiplicative-order bridge converts a *number-
theoretic* defect (Carmichael-ness) into a *cryptographic* weakness (small group
exponent), so pseudoprimality of the modulus is a direct security reduction, not a
heuristic.

**Why now?** The bridge `korselt_action_pow_trivial` already lives in the
Cryptography namespace and consumes the Shared-domain theorem; quantifying the
resulting key-space collapse is the natural next theorem on this exact interface.





### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


            ## v16 Research Core Methodology — Scientific Team Loop

You are the Principal Investigator leading a research team with four
roles: **Hypothesizer**, **Experimenter**, **Analyst**, and **Critic**.
Run the following loop and record notes at each stage.

### Stage 1 — Hypothesize (team: Hypothesizer)
Brainstorm 5–7 falsifiable conjectures about the topic. At least two
must be surprising or counter-intuitive. Rank them by expected
scientific impact, not by ease of proof.

### Stage 2 — Experiment (team: Experimenter)
For each conjecture, attempt to prove it in Lean 4 or disprove it with
a concrete counterexample. Prioritize the most surprising conjectures
first. If a proof is beyond reach, prove the strongest lemma you can
and mark the remaining step with exactly one `sorry` that is clearly
documented.

### Stage 3 — Analyze (team: Analyst)
Summarize what survived, what failed, and **why** failures failed.
Distinguish "true but hard", "false", and "needs a different
definition". These insights are as valuable as the proofs.

### Stage 4 — Critique / Adversarial Review (team: Critic)
Before finalizing, challenge every theorem:
- Is any theorem trivial (True, definitional equality, `native_decide`)?
- Does every main theorem have 0 sorries?
- Do the results genuinely extend the attached catalog files?
- Are there hidden assumptions or corner cases that break the claim?
If you find a weakness, fix it or replace the theorem with a guarded
version and explain the boundary.

### Stage 5 — Synthesize (team: Principal Investigator)
Combine the verified results into clean, compiling Lean 4 files.
Write a `FUTURE_DIRECTIONS.md` that lists 3–5 **bold, testable**
conjectures derived from Stage 3 and Stage 4. Each conjecture must
include a "The key insight is..." sentence and a "Why now?"
justification.

### Mode-Specific Mission: prove
Your team is proving a targeted theorem. The Hypothesizer breaks
the main claim into lemmas; the Experimenter proves each lemma;
the Analyst ensures the pieces assemble into the main result;
the Critic tries to break the proof with edge cases. Main results
must have 0 sorries.


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
