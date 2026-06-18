# Future Directions — Post-Quantum Lattice Cryptography (Regev / LWE)

## Synthesis

This cycle delivered `Cryptography/LWE/RegevINDCPA.lean`, which closes two gaps
left open by the existing catalog files `Cryptography/LWE/SearchDecisionCore.lean`
and `Cryptography/Security.lean`.

1. **Modular decryption correctness.** The catalog previously proved only the
   *real-line* rounding window for Regev's decoder (`regev_rounding_bit0/bit1`,
   on `ℝ`). We now prove `decodeBit_correct`, the genuinely **modular** statement
   in `ℤ_q`: the canonical representative `(μ·h + e) % (2h)` is decoded back to
   `μ` for *both* bits under the single uniform noise budget `4|e| < q`. The
   adversarial corner case — a small **negative** error wraps to the top cell
   `(3q/4, q)` rather than staying near `0` — is exactly what forces a two-sided
   "0" cell, and is what a naive one-sided threshold decoder gets wrong.

2. **IND-CPA security from perfect uniform masking.** We model distinguishing
   advantage (`distAdv`) as a difference of `PMF` expectations, prove it is a
   genuine pseudo-metric step (`distAdv_triangle`, `distAdv_self`), and prove
   **perfect secrecy of one-time uniform masking** (`regev_mask_uniform`,
   `regev_mask_indistinguishable`) from the translation-invariance of the uniform
   measure on a finite abelian group (`map_uniform_equiv`). These compose into
   `indcpa_advantage_bound`/`indcpa_advantage_le_two_eps`: IND-CPA advantage
   `≤ 2·(LWE advantage)`. Unlike the `Security.lean` `linarith` wrapper, the
   zero-leakage middle hybrid is here *proved*, not assumed.

3. **End-to-end fusion.** `regev_subsetSum_decrypt_correct` ties the subset-sum
   noise accumulation (cf. catalog `noise_accumulation_subset_bound`) to the
   modular decoder, yielding correctness whenever `4·(|S|·B) < q`.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `decodeBit_correct` | Modular rounding decode recovers `μ` when `4|e| < q` | proved (axioms: propext, choice, Quot.sound) |
| `regev_subsetSum_identity` | `v − ⟨s,u⟩ = μh + ∑e_i` for subset-sum ciphertexts | proved |
| `regev_subsetSum_decrypt_correct` | End-to-end correctness under `4(|S|·B) < q` | proved |
| `distAdv_triangle` | Hybrid triangle inequality for advantage | proved |
| `regev_mask_uniform` / `regev_mask_indistinguishable` | Uniform masking is perfectly secret | proved |
| `indcpa_advantage_bound` / `..._le_two_eps` | IND-CPA advantage `≤ 2·LWE advantage` | proved |

All main results are `sorry`-free and depend only on `propext`,
`Classical.choice`, and `Quot.sound`.

---

## Direction 1 — Tightness of the noise budget (falsifiable boundary)

**Conjecture.** The budget `4|e| < q` in `decodeBit_correct` is *exactly* tight:
there exists an error `e` with `4|e| = q` (i.e. `e = ±q/4` when `4 ∣ q`) for which
`decodeBit (2h) (μ·h + e) ≠ μ` for some bit `μ`. Formally, decoding fails on the
cell boundary.

The key insight is that the rounding cells partition `[0,q)` into half-open
intervals whose shared endpoints `q/4` and `3q/4` are decoded *against* the
encoded bit, so the first failing error is the smallest integer reaching a cell
wall — making `4|e| < q` not improvable to `4|e| ≤ q`.

**Why now?** We already have the positive direction proved and the exact decoder
definition in hand; constructing the boundary counterexample is a finite
`decide`/`omega` computation on a concrete small modulus (e.g. `q = 8`, `e = 2`),
so the falsification test is immediate and cheap.

## Direction 2 — Decryption error probability over a discrete Gaussian

**Conjecture.** If each `e_i` is drawn from a discrete distribution with
sub-Gaussian tail of parameter `σ`, the per-ciphertext decryption-failure
probability is `≤ 2·exp(−q²/(32·|S|·σ²))`, obtained by a Hoeffding/Azuma bound on
`∑_{i∈S} e_i` combined with `decodeBit_correct`.

The key insight is that `decodeBit_correct` reduces correctness to the *single*
scalar event `4|∑ e_i| < q`, so probabilistic correctness is purely a
concentration statement about a bounded-increment sum — fully decoupled from the
algebraic scheme.

**Why now?** Mathlib has Hoeffding-type inequalities and the `PMF`/measure
machinery we already invoke for `distAdv`; the deterministic correctness core is
done, so only the tail bound remains to be formalized and plugged in.

## Direction 3 — From two-hybrid IND-CPA to multi-message CPA

**Conjecture.** For `k` challenge ciphertexts, the IND-CPA advantage is bounded
by `2k·ε` via a `k`-fold hybrid, and this linear-in-`k` loss is necessary:
there is a distinguisher achieving advantage `Ω(k·ε)`.

The key insight is that `distAdv_triangle` chains across a sequence of
`encUnif`-bridged hybrids exactly like the catalog `hybrid_telescope_bound`, so
multi-message security is a telescoping sum of single-message gaps each killed by
`regev_mask_indistinguishable`.

**Why now?** Both ingredients already exist in the catalog — our
`distAdv_triangle`/`regev_mask_uniform` here and `hybrid_telescope_bound` in
`Security.lean`; unifying them gives the multi-message bound with no new
mathematical machinery.

## Direction 4 — Worst-case GapSVP → average-case LWE, quantitative core

**Conjecture.** A GapSVP_γ oracle for `γ = Õ(n/α)` yields an LWE solver with
polynomially related advantage, and the *combinatorial* core — that an affine
re-randomization over `ℤ_p` (catalog `ZMod.affine_bijective`) maps a wrong secret
guess to a perfectly uniform sample — can be stated as a measure-preservation
theorem `map (affineEquiv a b) uniform = uniform`, a direct cousin of our
`map_uniform_equiv`.

The key insight is that `map_uniform_equiv` is *already* the general lemma: every
re-randomization step in the Regev worst-case reduction is an instance of
"pushforward of uniform under a bijection is uniform," so the whole reduction's
secrecy bookkeeping factors through one reusable theorem.

**Why now?** We just proved `map_uniform_equiv` in full generality and the
catalog supplies `ZMod.affineEquiv`; instantiating one at the other formalizes the
re-randomization invariance that the worst-case reduction repeatedly relies on.

## Direction 5 — Robustness of the decoder to a one-sided vs two-sided cell

**Conjecture (adversarial).** The "obvious" one-sided decoder
`decode'(y) := if 2·(y%q) < q then 0 else 1` is **provably incorrect**: there is a
negative error `e` with `4|e| < q` such that `decode'(2h, 0·h + e) = 1 ≠ 0`,
whereas our two-sided `decodeBit` succeeds on the same input.

The key insight is that the failure is concentrated entirely on the wrap-around
region `(q/2, q)` reachable only by negative noise, so the one-sided decoder's
error set is exactly `decodeBit`'s top "0" cell — a crisp, checkable separation
between the two decoders.

**Why now?** Both decoders are one-line definitions and the separating witness is
a concrete small integer (`q=8, e=-1`); this is an immediate `decide` experiment
that hardens the design rationale for the two-sided cell with a machine-checked
counterexample.
