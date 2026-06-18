            # Phase A Research Mission v17: Infinite-Dimensional Chess: Winning on the Hilbert Board

            ## Concept
            **Domain**: Logic
            **Research mode**: team
            **Title**: Infinite-Dimensional Chess: Winning on the Hilbert Board
            **Description**: Formalize chess played on an infinite board. Prove that the king can always escape on an infinite board and determine which finite-piece configurations are forced mates. Develop a theory of infinite combinatorial game value and prove its relationship to ordinal game values.
            **Mathematical framing**: Formalize chess played on an infinite board. Prove that the king can always escape on an infinite board and determine which finite-piece configurations are forced mates. Develop a theory of infinite combinatorial game value and prove its relationship to ordinal game values.




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

### Perpetual Scientific Iteration (do not stop at first synthesis)
When the research team comes together with results, do not stop. Treat the synthesized findings as the next problem statement and immediately run the full scientific-method loop again: hypothesize, experiment, review, synthesize, critique. Repeat this cycle continuously within the available context window, refining, deepening, and cross-checking until forced to emit output. Use Aristotle to its fullest.


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
