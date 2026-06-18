# Summary of changes for run c558d751-8e2c-412b-8a5e-788fad887cf8
Delivered a self-contained Lean 4 formalization of code-based cryptography (McEliece / Goppa codes) plus the required research-directions file.

**New files**
- `Cryptography/McElieceGoppa.lean` — compiles cleanly (no `sorry`, only standard axioms `propext`/`Classical.choice`/`Quot.sound`).
- `Cryptography/FUTURE_DIRECTIONS.md` — 5 falsifiable conjectures, each with a "key insight" and "Why now?" justification, building on the new lemmas.

**Theorems proved (all sorry-free)**
1. `unique_decoding` — Bounded-distance decoding: a code of minimum distance ≥ 2t+1 has at most one codeword within Hamming distance t of any received word (the foundational error-correction theorem). This is the centerpiece result; it comes with a generalization route (FUTURE_DIRECTIONS) and an explicit boundary counterexample.
2. `decoding_fails_at_even_distance` — Tightness/boundary case: the explicit binary code {00,11} with received word 10 shows the 2t+1 threshold cannot be weakened to 2t.
3. `mcEliece_correct` — Main correctness theorem for the full McEliece round-trip: with an invertible scrambler S (S·Sinv = 1), a coordinate permutation σ, a t-error-correcting decoder for G, and any error of Hamming weight ≤ t, decryption recovers the plaintext. Supporting isometry lemmas `hammingDist_perm` and `hammingNorm_perm` (coordinate permutations preserve Hamming distance/weight) are proved via explicit bijections.
4. `code_card` — Code dimension/rate: a full-row-rank [n,k] code over a finite field has exactly |F|^k codewords (via injectivity of the encoder `m ↦ m·G`).
5. `mceliece8192128_params` / `mceliece8192128_codespace_size` — the standardized Classic McEliece *mceliece8192128* parameter set (m=13, n=2^13=8192, t=128, k=6528) and the resulting 2^6528 binary codeword space targeting ≈256-bit post-quantum security.

The decoder is abstracted by a `CorrectsErrors` predicate, cleanly isolating the single guarantee a Goppa code must supply, and an `example` block instantiates the whole API on the trivial identity code as a sanity check. Brief proof sketches are included as `-- !-- … -- !--` comment blocks. The file is placed at the build-resolved location (root-level `Cryptography/`, matching the lakefile's `Cryptography.+` glob) and verified with a successful `lake` build.