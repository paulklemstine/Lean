# Summary of changes for run a0d7ffe0-d9fe-4ff6-bf60-d65ff03ce4af
## BB84 Quantum Key Distribution — formalized security results

I added a new self-contained Lean file, `Catalog/Cryptography/QuantumSecurity/BB84Security.lean`, plus a research-roadmap file `FUTURE_DIRECTIONS.md`. The Lean file builds cleanly (no `sorry`, no warnings, no nonstandard axioms; only `Mathlib` is imported).

### What is proved (all complete proofs)
Building on Mathlib's `Real.binEntropy` (Shannon entropy in nats) and connecting to the existing catalog file `Cryptography/LeftoverHash.lean`, the file formalizes the Shor–Preskill secret-key rate `R(Q) = 1 − 2·H₂(Q)` (in bits per sifted bit), where `Q` is the quantum bit error rate, and proves:

- **`bb84_secureKeyRate_root_existsUnique`** — there is a *unique* security threshold `Q⋆ ∈ (0, ½)` with `R(Q⋆) = 0` (via the Intermediate Value Theorem and strict monotonicity of binary entropy).
- **`bb84_threshold_bracket`** — every such threshold lies in `(1/16, 1/8)`, i.e. `6.25% < Q⋆ < 12.5%`, an interval containing the celebrated `≈ 11%` value. Notably this is proved *without any numerical bound on `log`*, reducing to the certified rational inequalities `(8/7)^7 > 2` and `(16/15)^15 < 16`.
- **`secureKeyRate_quarter_neg`** — the intercept–resend attack (which forces `Q = 1/4`) always yields a strictly negative key rate, so it is always detectable. The proof exploits the exact identity `binEntropy(1/4) = ½·log2 + ¾·log(4/3)`.
- **`secureKeyRate_strictAntiOn`** — the key rate is strictly decreasing in the QBER on `[0, ½]` (I corrected an initial mis-stated interval after the prover flagged it).
- **`privacy_amplification_exp_bound`** and **`bb84_privacy_amplification_tendsto_zero`** — privacy amplification by universal hashing makes the eavesdropper's distinguishing advantage exponentially small (`≤ ½·2^{−t/2}` for a `t`-bit entropy gap) and drives it to `0`. This abstracts the conclusion of the leftover-hash lemma in `Cryptography/LeftoverHash.lean`.
- Supporting results: `shannonBits_half`, `shannonBits_strictMonoOn`, `secureKeyRate_eq_zero_iff`, and the Pythagorean overlap identity `mub_overlap_half : cos²(π/4) = 1/2` (the equal-overlap of BB84's two mutually unbiased bases that forces any intercepting adversary to inject errors).

Each theorem carries a brief proof-sketch comment block.

### Cross-domain synthesis
The work bridges three catalog areas: Mathlib's binary-entropy analysis, the cryptographic leftover-hash/privacy-amplification machinery (`LeftoverHash.lean`), and a Pythagorean inner-product identity for mutually unbiased bases — exactly the requested combination of analytic, cryptographic, and geometric ideas.

### FUTURE_DIRECTIONS.md
A freeform narrative with five falsifiable conjectures extending this work: (1) squeezing `Q⋆` to the true `≈11%` by certified rational-log comparisons; (2) the six-state protocol threshold via `qaryEntropy`; (3) explicit finite-key extractable lengths by composing with the leftover-hash bound; (4) a convexity-based linear robustness certificate from `strictConcave_binEntropy`; and (5) a Pythagorean information–disturbance tradeoff. Each includes a "The key insight is…" sentence and a "Why now?" justification.