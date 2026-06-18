# Summary of changes
## Completed: Full Analysis, Formalization, Verification, and Research Output

### What I Did

I analyzed the Tropical AI Python script — a GPT-2 variant using tropical geometry-inspired components — extracted its mathematical claims, and formally verified them in Lean 4.

### Deliverables

**1. `RequestProject/TropicalOracle.lean`** — 18 formally verified theorems (zero `sorry`, clean build, standard axioms only):

| Category | Theorems Proved |
|---|---|
| **Idempotent Oracle Theory** | Image = truth set, oracle on truth set = identity, O∘O = O, output is always truth |
| **Tropical Gate** | Equals -ReLU(-x), is idempotent, truth set = (-∞,0], monotone, bounded |
| **Compression** | Non-injective oracles have |truth set| < |domain| |
| **Geodesic Descent** | Zero gradient → no movement, positive gradient → descent |
| **Strange Loops** | Iteration converges in one step, meta-oracle stability |
| **Holographic Bottleneck** | Idempotent compositions have range = fixed points |

**2. `research_paper.md`** — Full research paper with:
- Formal definitions and theorem statements
- Proofs and analysis of all 7 sections (oracle theory, tropical gates, compression, geodesic descent, strange loops, holographic bottleneck, experimental observations)
- Critical analysis: the 0.3/0.7 convex combination breaks exact idempotency
- Identification that the "geodesic optimizer" is mathematically equivalent to RMSProp
- Open questions for future work

**3. `scientific_american_article.md`** — Popular science article explaining the key ideas for a general audience.

**4. `research_notes.md`** — Lab notebook documenting the research team's iterative exploration across 5 iterations, including hypotheses tested, discoveries made, and future directions.

**5. `tropical_ai_original.py`** — Annotated copy of the original script with formal verification annotations.

### Key Findings

- **The math is sound**: All 18 claimed properties of idempotent oracles are formally verified.
- **The implementation gaps**: The actual architecture uses tanh (not idempotent) and a 0.3/0.7 convex combination (not idempotent), so the theoretical guarantees don't directly apply to the implementation.
- **The optimizer is RMSProp**: The "geodesic gradient descent" is mathematically identical to RMSProp with decay 0.99.
- **Tropical gates are genuinely interesting**: min(x,0) as an idempotent retraction onto (-∞,0] has nice mathematical properties worth exploring further.