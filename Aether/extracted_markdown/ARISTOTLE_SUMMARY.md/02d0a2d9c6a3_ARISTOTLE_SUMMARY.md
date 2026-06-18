# Summary of changes for run af71ed4c-c13d-4002-84cc-02feff1747bf
Researched the CSI-FiSh / CSIDH (isogeny-based cryptography) direction and delivered a new, fully-verified Lean 4 module plus a future-directions document, extending the existing `Catalog/Cryptography/CSIFiShAdvanced.lean`.

## Deliverables

**1. Lean proofs — `Catalog/Cryptography/CSIFiShClassGroup.lean` (0 sorries).**
Key insight driving the cycle: the cryptographic core of CSI-FiSh/CSIDH is *exactly* a simply-transitive additive action, i.e. an `AddTorsor` of the (abelian) class group on the curve set. Re-casting the protocol over `AddTorsor G X` collapses each security property to a short, machine-checked torsor identity. Fully proved results include:
- Key generation / inversion: `connector_pubKey`, `pubKey_connector`, `secret_eq_connector_iff`.
- One-wayness as a bijection `G ≃ X`: `pubKey_injective/surjective/bijective`, `pubKeyEquiv`, and key-space = curve-space cardinality `card_key_eq_card_curve`.
- Information-theoretic key uniqueness: `secret_key_unique`, `secret_key_ncard` (exactly one secret per public key).
- Connector algebra: cocycle law `connector_cocycle`, quadratic-twist identity `connector_twist`, and **random self-reducibility of GAIP** `gaip_self_reducible` (worst-case = average-case structure).
- CSIDH correctness and order-independence: `csidh_correct`, `csidh_shared_eq`, `multiparty_perm_invariant` (via list-sum permutation invariance).
- Σ-protocol soundness/completeness: `special_soundness` (2-special soundness extractor), `extracted_is_secret`, `completeness`, and a `multi_round_extract` packaging parallel-repetition soundness.
- Concrete instance: the regular action exhibits any abelian group as a torsor over itself.
- **Closed a previously-conjectural catalog target**: `CSIFiShAdvanced.CayleyDiameterConj` (only a `≤` reachability statement) is now proved (`zmod_cayley_diameter`) and, in a second iteration, sharpened to the *exact* diameter via a tight lower bound `zmod_cayley_diameter_tight` and the `IsLeast` characterization `zmod_cayley_diameter_exact` — the Cayley graph of `ZMod n` with generators `{±1}` has diameter exactly `⌊n/2⌋`.

**2. Lab notes.** Inline `-- !-- Lab Notes -- !--` blocks document the H0 hypothesis (FreeTrans ≈ AddTorsor), the H1 diameter hypothesis with proof strategy and failure analysis (an early `ZMod`-level attempt failed on modular wraparound; lifting to `ℕ` via `ZMod.val` fixed it), and the second-iteration tightness reasoning.

**3. `Catalog/Cryptography/FUTURE_DIRECTIONS.md`.** Five bold, testable conjectures: (C1) extending the exact-diameter result to general generating sets `{±1,±g}` toward `Θ(√n)` (Kuperberg-attack structure); (C2) self-reducibility ⇒ uniform extractor advantage (worst/average-case equivalence); (C3) k-special soundness ⇒ `2^{-t}` cheating mass; (C4) categorical rigidity of free transitive actions vs. `AddTorsor`; (C5) commutativity necessity for non-interactive key agreement.

All declarations were verified by Lean elaboration against Mathlib; the module imports only Mathlib, so it stands independently of an unrelated pre-existing dangling import elsewhere in the project (in `Algebra/UltrametricCondNeg.lean`), which I left untouched. No axioms or `@[implemented_by]` were introduced. Per the stated constraints, no prose articles, Python, HTML, or package files were produced.