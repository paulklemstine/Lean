Produce a single self-contained Lean 4 file that cleanly formalizes the finished core theorem behind tropical hull recovery for binary linear codes, with no unrelated declarations and no placeholders.

Target file: `Catalog/Applications/SmoothPoincare/TropicalHullRecovery.lean`.

Primary instruction: focus narrowly on the mathematically verified core. Do not include speculative extensions, extra domains, or orphan declarations. Every definition and theorem in the file must have a complete body and proof term and the file should compile without `sorry`.

Mathematical scope:
1. Work over the existing binary linear code infrastructure already present in the SmoothPoincare catalog.
2. Use the tropical weight enumerator viewpoint already introduced in the previous attempt, but restate all needed definitions locally or import them from the relevant code file if already available.
3. Define the relevant weight set and endpoint quantities precisely:
   - `minWt C hC`
   - `maxWt C hC`
   where `hC` is the nonempty-code hypothesis if needed.
4. Define `realizedSlope C hC w` as: there exists `t : ℝ` such that `w` is a realized codeword weight and for every other realized weight `w' ≠ w`, one has strict inequality `w + t*w < w' + t*w'` or the exact affine form used by your tropicalization convention. The key point is that `w` must be the unique minimizer at some parameter value. Make the convention completely explicit.
5. Prove the central theorem in a precise iff form:
   `realizedSlope C hC w ↔ w = minWt C hC ∨ w = maxWt C hC`.
   The proof strategy should follow the direction already discovered: analyze the sign of the witness parameter `t`, show negative `t` forces the maximum weight, positive `t` forces the minimum weight, and show strict uniqueness fails at the degenerate parameter where all terms tie.
6. Derive at least the following concrete corollaries with full proofs:
   - endpoint realizability lemmas for `minWt` and `maxWt`
   - non-realizability of any strict interior weight `w` with `minWt C hC < w < maxWt C hC`
   - a direct-sum corollary explaining how endpoint recovery behaves under append/direct sum if the needed append operation already exists in the catalog
   - an instantiated corollary for the extended Hamming code already present in the catalog: prove that weight `4` is not a realized slope because the endpoints are `0` and `8`
7. Keep the file small and polished. If a theorem from the previous attempt is unnecessary, omit it.

Proof engineering requirements:
- Prefer elementary finite-set and order arguments over introducing heavy convex-geometry infrastructure.
- If the previous tropical enumerator file contains useful proved lemmas, import and reuse them. If not, rebuild only the minimal needed layer here.
- Avoid any theorem statements without proofs, and avoid declarations unrelated to tropical codes.
- Include short module documentation explaining the information-loss phenomenon: the tropical profile only detects endpoint weights under the strict unique-minimizer notion.

Deliverable standard:
- The artifact should read like a finalized catalog contribution, not a research sketch.
- It must be standalone enough that a reviewer can inspect the file and understand the exact theorem proved.
- If the append/direct-sum corollary is too expensive because of missing infrastructure, replace it with a simpler fully proved structural corollary about endpoint behavior, but do not leave a stub.

The key insight is that for the min-plus tropicalization built from affine functions indexed by realized weights, strict minimizers can only occur at the extreme weights because the parameter sign selects one endpoint or the other, and the tie point destroys uniqueness. Why now? The catalog already appears to contain binary-code primitives, direct-sum operations, and the tropical weight enumerator setup, so the remaining work is to isolate and fully verify the completed hull-recovery theorem in a compact file rather than extending the unfinished broader development.