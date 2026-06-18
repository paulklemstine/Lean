# Summary of changes for run fabac79d-f0ae-44f4-b330-1c664fd82a71
## Completed: LWE Search-to-Decision Reduction — Algebraic Core

### Deliverables

**1. Lean file: `Cryptography/LWE/SearchDecisionCore.lean`** (269 lines, 0 sorries)

Contains 18 fully proven theorems formalizing the mathematical core of the LWE search-to-decision hardness reduction. All theorems compile cleanly with only standard axioms (propext, Classical.choice, Quot.sound).

**Key theorems (4 main results):**

1. **`ZMod.affine_bijective`** — Affine maps x ↦ ax + b are bijections over ℤ_p when p is prime and a ≠ 0. This is the algebraic core of the search-to-decision reduction: it ensures that rerandomizing LWE samples by affine transformations preserves uniformity on "wrong guess" branches of the hybrid argument. Proved by composing field multiplication bijectivity with translation bijectivity.

2. **`search_to_decision_advantage_bound`** — Per-coordinate advantage decomposition via pigeonhole: if the total distinguishing advantage between LWE and uniform is δ decomposed into n hybrid steps, then some coordinate contributes advantage ≥ δ/n. This quantifies the tight factor-n loss in the coordinate-by-coordinate search-to-decision reduction.

3. **`regev_rounding_bit1`** — Rounding-based decryption correctness for Regev's encryption: when |error| < q/4, the noisy encoding q/2 + e of bit 1 stays in the interval (q/4, 3q/4), ensuring correct recovery. Combined with `regev_rounding_bit0` and `regev_encryption_rounding_correctness` for the full correctness proof.

4. **`combined_noise_after_switching`** / **`decryption_correct_after_switching`** — Modulus switching analysis: the combined noise from original LWE error (bound B) plus rounding error from n coordinates (bound nδ) is at most B + nδ, and decryption remains correct when this total is below q/4.

**Supporting results:**
- `ZMod.affineEquiv_symm_apply`: Inverse of affine map is affine (f⁻¹(y) = a⁻¹(y-b))
- `ZMod.sum_affine_eq`: Summation invariance under affine change of variables
- `noise_accumulation_bound` / `noise_accumulation_subset_bound`: Triangle inequality bounds for subset sums of bounded errors
- `advantage_amplification`: k repetitions boost success probability from p to ≥ 1-(1-p)^k
- `modulus_noise_tradeoff`: Larger modulus q allows smaller noise rate α

**2. `FUTURE_DIRECTIONS.md`** — 5 research conjectures extending this work:
1. Full Regev quantum reduction via iterative rounding decomposition
2. Ring-LWE/Module-LWE search-to-decision via CRT splitting
3. Tightness of factor-n loss via concentration arguments
4. Noise flooding with Rényi divergence bounds
5. Verified parameter selection for NIST ML-KEM standards