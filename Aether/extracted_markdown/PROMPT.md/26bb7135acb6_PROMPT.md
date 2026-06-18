You are continuing a partial project, but you must sharply narrow scope and finish one coherent theorem file with complete Lean proofs.

Target the existing bridge in `Catalog/Bridges/SpeciesTropicalValuation.lean` rather than introducing new material about algebraic circuits, PIT, or cryptography. The previous attempt failed because it mixed many unrelated domains and produced incomplete declarations. Your job is to fill actual proof gaps in the species/tropical valuation bridge and leave behind a small, fully compiling development with no `sorry`.

Concrete objective:
1. Inspect `Catalog/Bridges/SpeciesTropicalValuation.lean` and identify the strongest existing definitions and partially proved lemmas around `ordEGF`.
2. Choose exactly one tightly related theorem family already suggested by that file’s API, such as compatibility of `ordEGF` with addition, multiplication, composition, or a coefficientwise valuation/order inequality.
3. Formalize at most 2–4 theorems total, but each must be complete, useful, and directly extend the file’s current bridge from order-only data toward a tropical interpretation.
4. Prefer theorem statements that can be proved from existing lemmas in the same file or nearby FINAL catalog files. Do not invent a large new framework.
5. If some intended theorem is false or currently underpowered by the library, replace it with the strongest true theorem you can fully prove, and document that choice clearly.

Deliverables:
- A single coherent Lean file, ideally by editing or extending `Catalog/Bridges/SpeciesTropicalValuation.lean` or by adding one small adjacent file importing it.
- No placeholders, no malformed declarations, no unrelated theorem headers.
- A standalone `RESEARCH_PAPER.md` explaining the exact definitions used, the completed theorem(s), proof strategy, and what tropical/valuation consequence was obtained.
- A `FUTURE_DIRECTIONS.md` with 3–5 paragraph-style directions. Each paragraph must include a sentence beginning `The key insight is...` and a sentence answering `Why now?`.

Technical guidance:
- Build on the strongest verified material in `Catalog/FINAL/` when possible.
- Favor lemmas of the form “order/valuation of a species construction is bounded by / equals a tropical combination of the inputs”.
- Keep the development minimal and robust: exact hypotheses, explicit namespaces, and proofs using existing algebraic facts rather than ad hoc automation.
- If there are lingering `sorry`s in the target file, prioritize the most central one first and only prove additional results if the first is complete.

Do not return another broad bridge to PIT or Nullstellensatz. This cycle succeeds only if the resulting Lean file is small, coherent, directly tied to `ordEGF`, and fully checked.