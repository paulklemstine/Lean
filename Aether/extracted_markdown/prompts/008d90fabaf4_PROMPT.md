You are working in sorry_fill mode. The previous attempt failed because it created a new off-topic file about Nullstellensatz/PIT instead of completing the intended SmoothPoincare self-dual-code → lattice/intersection-form pipeline. Do not introduce any unrelated material.

Task:
1. Locate the actual files in the repository that implement the SmoothPoincare pipeline from binary self-dual codes to lattices / intersection forms. Prefer files under Catalog/FINAL/ if they are part of this pipeline; otherwise use the precise SmoothPoincare source files already present in the repo.
2. In only those target files, identify declarations that still contain `sorry` and are directly on the algebraic bridge from:
   - binary self-dual code data
   - to the associated lattice / ℤ-module / bilinear form
   - to evenness, unimodularity, Gram/intersection matrix structure, or direct-sum/block decomposition facts.
3. Fill only a minimal coherent set of these placeholders. Prioritize lemmas of the following kinds:
   - direct sum decomposition and projection/inclusion identities actually used downstream;
   - block matrix or Gram matrix simplification lemmas;
   - determinant or invertibility lemmas needed to conclude unimodularity;
   - parity/evenness lemmas for the associated quadratic/bilinear form;
   - immediate translation lemmas from code self-duality to form/lattice self-duality.
4. Do not create new files unless a tiny helper file is absolutely necessary and still within the same pipeline. Do not touch unrelated domains. Do not add broad new abstractions or conjectural statements.
5. If a target declaration is malformed or far too ambitious, replace it only with the nearest correct statement that is already clearly intended by downstream use in the same pipeline, and prove that. Keep such repairs minimal.

Output expectations:
- Produce compilable Lean code edits only in the identified pipeline files.
- Leave no `sorry` in the declarations you modify.
- Add a concise audit summary in comments or accompanying notes: which files were inspected, which sorries were filled, and which remaining gaps were intentionally left untouched because they are outside the direct pipeline.

Important constraints:
- No new theory outside the self-dual-code / lattice / intersection-form bridge.
- No unrelated examples, no PIT, no persistence, no neural systems, no ultrametric material.
- Favor short, robust proofs using existing mathlib and existing local lemmas.
- If the exact target files cannot be found, stop and report that fact rather than inventing a replacement project.