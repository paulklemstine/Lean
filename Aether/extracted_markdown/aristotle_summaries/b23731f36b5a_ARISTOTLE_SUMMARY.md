# Summary of changes for run a9a9155b-6921-4a95-9b4c-65de9c1d64c8
Added a new self-contained Lean development on **code-based cryptography (the McEliece cryptosystem from Goppa codes)** plus a research-directions companion.

**New files**
- `Catalog/Cryptography/McElieceGoppa.lean` — compiles cleanly, **0 sorries**, depends only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).
- `Catalog/Cryptography/McElieceGoppa_FUTURE_DIRECTIONS.md` — five falsifiable conjectures (Goppa designed-distance theorem, verified Patterson decoder, NP-hardness of syndrome decoding, the Gilbert–Varshamov counterpart, and distinguishing-equals-decoding), each with a "The key insight is…" and a "Why now?" justification.

**Theorems proved (all with brief `-- !-- … -- !--` proof sketches and docstrings)**
1. `unique_decoding` — a code with minimum distance ≥ 2t+1 has at most one codeword within Hamming radius t (the fundamental theorem of error correction, via the triangle inequality).
2. `hammingNorm_comp_equiv` — coordinate permutations preserve Hamming weight (the algebraic content of the McEliece permutation matrix P).
3. `mceliece_correct` — **end-to-end decryption correctness**: for public key modeled as G' = S·G·P and ciphertext y = m·G' + e with wt(e) ≤ t, the decrypt-and-unscramble procedure returns the plaintext m, given a code that corrects t errors. This is the centerpiece and combines results 1–2.
4. `sphere_packing_bound` — the Hamming bound: |C|·(ball volume) ≤ q^n, via disjointness of radius-t balls (`hammingBall_disjoint`) and translation-invariance of ball volume (`hammingBall_card_eq`).
5. Concrete parameters: `cm6960119` (Classic McEliece, NIST level 5 / 256-bit, GF(2^13), n=6960, t=119), with `cm6960119_dimension` (k = 5413), `cm6960119_designedDistance` (= 239), and `cm6960119_corrects_119_errors` instantiating the abstract decoding guarantee at t = 119.

**Catalog synthesis:** the work extends the project's existing coding-theory thread (the Reed–Muller minimum-distance machinery in `Cryptography/MinimumDistance.lean`) from one specific algebraic code to the abstract minimum-distance hypothesis underlying a deployed cryptosystem.

**Infrastructure fix:** the project's `lakefile.toml` was missing `srcDir = "Catalog"`, so no module (including pre-existing ones) could be located or built; I added that single line, after which the project builds. This was required for the project to compile at all.