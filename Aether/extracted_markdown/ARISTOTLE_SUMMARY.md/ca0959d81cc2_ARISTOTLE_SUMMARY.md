# Summary of changes for run 416e0685-9043-498a-8c44-3363b7de5566
## Cycle complete: Automatic Sequences via the k-Kernel

This was a **cold start** — the concept brief referenced an existing catalog of automatic-sequence machinery (`DFAO`, `kAutomatic`, `kKernel`, Boolean closure, Nerode bridge), but a full project search confirmed **none of it existed**. So the theory was built from scratch using the Eilenberg kernel characterization as the working definition of k-automaticity.

### New file
- `Catalog/Computation/AutomaticSequences.lean` (module `Computation.AutomaticSequences`), builds cleanly as part of the default `Computation` target. It contains Lab Notebook blocks and `!--` proof-sketch comments throughout.

### Definitions
- `kSub`, `kKernel`, `IsKAutomatic` — a sequence `a : ℕ → α` is k-automatic iff its k-kernel (all decimations `n ↦ a(kᵉn+r)`, `r < kᵉ`) is finite.
- `tm` — the Thue–Morse sequence (parity of the binary digit-sum).
- `EventuallyPeriodic`.

### Theorems proved (no `sorry`, verified to depend only on `propext`/`Classical.choice`/`Quot.sound`)
- `self_mem_kKernel`, `IsKAutomatic.const`, `IsKAutomatic.map`, `IsKAutomatic.not`, `IsKAutomatic.prod`, and the headline closure result `IsKAutomatic.boolCombine` (any binary Boolean combination of two k-automatic sequences is k-automatic).
- `tm_two_mul`, `tm_two_mul_add_one` (the two Thue–Morse recurrences).
- `thueMorse_add_pow_two` — the carry-free additivity identity `tm(2ᵉn+r) = tm(r) ⊕ tm(n)` for `r < 2ᵉ`, by induction on the exponent.
- `thueMorse_kernel_subset` — the 2-kernel of Thue–Morse is contained in the explicit 2-element set `{tm, not∘tm}`.
- `thueMorse_isKAutomatic` — **the flagship result: Thue–Morse is 2-automatic.**

### Conjectures (intentional `sorry`, seeding the next cycle)
- `cobham_two_three` — a sequence both 2- and 3-automatic is eventually periodic (Cobham's multiplicative-independence barrier).
- `thueMorse_not_eventuallyPeriodic` — the boundary witness for Cobham.

### Notes deliverable
- `FUTURE_DIRECTIONS.md` at the project root, with the required `## Synthesis`, `## Results Summary`, and five `## Research Directions` (each with Hypothesis / Test / "key insight" / Why now / If true / If false), prioritising the non-periodicity proof, exact kernel cardinality, kernel-size submultiplicativity, shift closure, and Cobham.

The structural insight of the cycle: defining automaticity via kernel finiteness turns every Boolean closure property into a one-line "image/product of a finite set is finite" argument, and the Thue–Morse 2-automaticity collapses to a single digit-sum additivity identity yielding the sharpest possible (two-element) kernel bound.