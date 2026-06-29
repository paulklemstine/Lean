# Decoder-Level Certified Robustness for ECOC Classifiers via Tropical Satake Score Gaps

## Abstract

We establish a formally verified theory of certified robustness for multiclass classifiers built using Error-Correcting Output Codes (ECOC) over tropical Satake score gaps. Our central result is a decomposition theorem showing that pairwise class separation in the soft-decoding regime factors exactly over the bits on which two codewords disagree, with each disagreeing bit contributing a perturbation-controlled margin. From this algebraic structure, we derive explicit certified robustness radii for both soft (signed-margin) and hard (Hamming) ECOC decoders, expressed as a weighted code-distance induced by tropical per-bit margins. All results are formalized and machine-verified in Lean 4 with Mathlib, establishing what we believe is the first complete formal verification of decoder-level multiclass robustness in the tropical representation-theoretic setting.

## 1. Introduction

Certified robustness for neural classifiers has become a central concern in trustworthy machine learning. Given a classifier *f* and an input *x*, the goal is to prove that *f(x') = f(x)* for all perturbations *x'* within some radius *r* of *x*, measured in an appropriate metric. While significant progress has been made for binary classifiers and simple argmax rules, realistic multiclass architectures — especially those using error-correcting output codes (ECOC) — have resisted formal analysis at the decoder level.

The GL3 tropical Satake program provides a natural source of Lipschitz-controlled score functions. In this setting, score gaps *g_j(x)* between classes satisfy perturbation bounds of the form |*g_j(x) − g_j(x')*| ≤ *L* · dist(*x, x'*), where *L* is a tropical Hecke constant (typically *L = 2K_d* for a GL₃ representation of depth *d*). Previous work has established robustness for individual gaps, argmax rules, and top-*k* selection. Our contribution is to show that these per-bit certificates compose through an ECOC decoder in a precisely quantifiable way.

### Main Contributions

1. **Exact Decomposition Theorem** (Theorem 1): The pairwise soft-score difference between any two classes decomposes as a sum over disagreeing code bits, with each bit contributing exactly *2 · C(y,j) · g_j(x)*.

2. **Score-Gap Robustness** (Theorem 2): The most general form of certified robustness, showing that if the pairwise soft-score gap exceeds the Lipschitz perturbation budget weighted by disagreeing bits, then the decoder output is invariant on the entire ball.

3. **Margin-Based Robustness** (Theorems 3–5): Under a natural sign-correctness condition, certified margins compose through the ECOC decoder according to weighted Hamming separation, yielding explicit certified radii.

4. **Hard Decoding Robustness** (Theorems 6–7): Sign stability under Lipschitz perturbation implies exact preservation of hard Hamming scores on perturbation balls.

5. **Machine Verification**: All results are formalized and verified in Lean 4 with Mathlib, using only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

## 2. Setup and Definitions

### 2.1 Code Matrices

We work over a finite class set `Fin n` and a finite bit set `Fin m`. A **code matrix** *C : Fin n → Fin m → ℤ* assigns an integer code value to each (class, bit) pair. A code matrix is **valid** if all entries are ±1:

> *ValidCodeMatrix(C)* ⟺ ∀ y j, C(y,j) = 1 ∨ C(y,j) = -1

A code matrix is **injective** if distinct classes have distinct codewords:

> *CodeInjective(C)* ⟺ *C* is injective as a function

### 2.2 Scores and Decoders

Given gap functions *g : Fin m → α → ℝ*, the **signed bit score** is:

> *SignedBitScore(C, g, y, j, x) = C(y,j) · g_j(x)*

The **soft score** aggregates over all bits:

> *softScore(C, g, y, x) = Σ_j SignedBitScore(C, g, y, j, x)*

The **hard score** counts positive signed bit scores:

> *hardScore(C, g, y, x) = |{j : 0 < SignedBitScore(C, g, y, j, x)}|*

### 2.3 Disagreeing Bits and Margins

The **disagreeing bits** between classes *y* and *z* are:

> *disagreeBits(C, y, z) = {j ∈ Fin m : C(y,j) ≠ C(z,j)}*

The **pairwise advantage** is the sum of doubled certified margins on disagreeing bits:

> *pairAdvantage(C, g, y, z, x) = Σ_{j ∈ D(y,z)} 2|g_j(x)|*

### 2.4 Lipschitz Condition

The per-bit Lipschitz condition abstracts the tropical Hecke perturbation bound:

> *BitGapLipschitzOn(g, L)* ⟺ ∀ j x x', |g_j(x) − g_j(x')| ≤ L · dist(x, x')

In the GL₃ tropical Satake application, *L = 2K_d* where *K_d* is the tropical Hecke constant.

## 3. Main Results

### 3.1 Theorem 1: Exact Decomposition

**Theorem** (*softScore_diff_eq_sum_disagree*). *Let C be a valid code matrix, g gap functions, and y, z classes. Then:*

> *softScore(C, g, y, x) − softScore(C, g, z, x) = Σ_{j ∈ D(y,z)} 2·C(y,j)·g_j(x)*

**Proof sketch.** Expand the soft-score difference as a sum over all bits of per-bit differences. On agreeing bits (*C(y,j) = C(z,j)*), the signed bit scores are equal, so the difference vanishes. On disagreeing bits, since *C(y,j), C(z,j) ∈ {±1}* and *C(y,j) ≠ C(z,j)*, we have *C(z,j) = −C(y,j)*, giving a per-bit contribution of *2·C(y,j)·g_j(x)*. □

This is the algebraic bridge between code geometry and tropical margins. It shows that class separation decomposes exactly along the Hamming support of the codeword difference.

### 3.2 Margin Lower Bound

**Theorem** (*softScore_diff_lower_bound_by_margins*). *Under the sign-correctness condition*

> *∀ j ∈ D(y,z), C(y,j)·g_j(x) ≥ 0*

*the soft-score gap is bounded below by the pairwise advantage:*

> *Σ_{j ∈ D(y,z)} 2|g_j(x)| ≤ softScore(C, g, y, x) − softScore(C, g, z, x)*

The sign condition says that the reference class's codeword "agrees with the sign of the gap" — i.e., the gap function supports the reference class on every disagreeing bit. When this holds, *C(y,j)·g_j(x) = |g_j(x)|*, and the decomposition identity yields the bound directly.

### 3.3 Theorem 2: Score-Gap Robustness

**Theorem** (*soft_ecoc_robust_of_score_gap*). *Let C be valid, g Lipschitz with constant L ≥ 0, and suppose for every competitor z ≠ y\*:*

> *Σ_{j ∈ D(y\*,z)} 2Lr < softScore(C, g, y\*, x) − softScore(C, g, z, x)*

*Then for all x' with dist(x, x') ≤ r and all z ≠ y\*:*

> *softScore(C, g, y\*, x') > softScore(C, g, z, x')*

**Proof sketch.** The score-gap difference |(softScore y\* x' − softScore z x') − (softScore y\* x − softScore z x)| is bounded by the sum of per-bit perturbations. By the decomposition theorem and the Lipschitz condition, each disagreeing bit contributes at most 2Lr to the perturbation. The hypothesis ensures the gap at *x* exceeds this total budget, so the gap remains positive at *x'*. □

### 3.4 Theorem 3: Margin Robustness

**Theorem** (*soft_ecoc_robust_of_margin*). *Under the additional sign-correctness condition for every competitor, if:*

> *Σ_{j ∈ D(y\*,z)} 2Lr < Σ_{j ∈ D(y\*,z)} 2|g_j(x)|*

*then the decoder output is invariant on the ball of radius r.*

This follows from combining the margin lower bound with score-gap robustness.

### 3.5 Theorem 4: Uniform Margin Corollary

**Theorem** (*soft_ecoc_robust_of_uniform_margin*). *If C is injective, the sign condition holds, and every bit has margin at least γ > Lr, then the decoder output is invariant on the ball.*

The injectivity condition ensures that every pair of distinct classes has at least one disagreeing bit, making the per-bit margin comparison meaningful. This is the "every active bit-gap exceeds 2K_d · r" narrative that directly connects to the tropical Hecke analysis.

### 3.6 Theorem 5: Certified Radius from Weighted Code-Distance

**Theorem** (*robust_of_radius_lt_min_ratio*). *Under the sign condition, if:*

> *2Lr · |D(y\*,z)| < pairAdvantage(C, g, y\*, z, x)     ∀ z ≠ y\**

*then the decoder output is invariant on the ball.*

This is the weighted code-distance formulation. The certified radius for each competitor *z* is:

> *r_z = pairAdvantage(C, g, y\*, z, x) / (2L · |D(y\*,z)|)*

and the overall certified radius is *min_z r_z*. The key insight is that robustness improves with both the margin (numerator) and the Hamming distance (which appears in both numerator and denominator, but the margin can grow faster).

### 3.7 Theorems 6–7: Hard Decoding Robustness

**Theorem** (*sign_stable_of_gap_margin*). *If Lr < |g_j(x)|, then sign(g_j(x')) = sign(g_j(x)) for all x' with dist(x,x') ≤ r.*

**Theorem** (*hard_ecoc_robust_of_bit_sign_stability*). *If every bit margin exceeds Lr, then every class's hard score is constant on the ball.*

These bypass the soft-score analysis entirely: by preserving each bit's sign, the entire hard agreement pattern is fixed, and Hamming scores are invariant.

## 4. Formal Verification

All theorems are formalized in Lean 4 (v4.28.0) with Mathlib. The formalization consists of three files:

- **`ECOCDefs.lean`** (≈130 lines): Core definitions and algebraic lemmas about ±1 codes
- **`ECOCRobustSoft.lean`** (≈220 lines): Soft decoding robustness theorems
- **`ECOCRobustHard.lean`** (≈80 lines): Hard decoding robustness theorems

The proofs use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`). Key Mathlib tools include `Finset.sum_sub_distrib`, `Finset.abs_sum_le_sum_abs`, `Finset.sum_lt_sum_of_nonempty`, and `abs_le`.

### Observations from Formalization

1. **Sign condition is essential.** During formalization, we discovered that the margin-based robustness theorem (originally stated without a sign condition) is actually false. The sign condition *C(y\*,j)·g_j(x) ≥ 0* is necessary because margins *|g_j(x)|* do not determine the direction of the score contribution. The score-gap formulation (`soft_ecoc_robust_of_score_gap`) is the correct unconditional version.

2. **Code injectivity matters for uniform margins.** The uniform margin theorem requires `CodeInjective C` to ensure that every pair of distinct classes has at least one disagreeing bit. Without this, the strict inequality `Σ 2Lr < Σ 2|g_j|` over an empty set becomes `0 < 0`, which is false.

3. **Lipschitz non-negativity.** The perturbation bound requires *L ≥ 0*, which is explicit in the formalization. For negative *L*, the Lipschitz condition forces all gap functions to be constant, making the bound trivially true but the hypothesis `L ≥ 0` cleaner to work with.

## 5. Applications

### 5.1 Adversarial Robustness Certification

The primary application is certifying that multiclass ECOC classifiers are robust to adversarial perturbations. Given a trained classifier using ECOC decoding with tropical Satake score gaps:

1. Compute per-bit margins *|g_j(x)|* at the input
2. Compute pairwise advantages and disagree counts
3. Apply Theorem 5 to get the certified radius

Our experiments (Python demo) show that ECOC-based certification can yield radii an order of magnitude larger than naive argmax-based bounds, because the ECOC structure distributes robustness requirements across multiple bits.

### 5.2 Code Design for Robustness

The theorems suggest concrete design principles for ECOC codes optimized for robustness:

- **Maximize minimum Hamming distance**: The certified radius is proportional to per-bit margin and depends on how margins distribute across disagree sets
- **Balance code weights**: Codes where each class has a roughly equal number of +1 and -1 entries tend to produce more balanced margins
- **Match code geometry to margin profiles**: If some bits have larger margins, the code should be designed so that critical class pairs disagree on those high-margin bits

### 5.3 Integration with Tropical Hecke Analysis

In the GL₃ setting, the Lipschitz constant *L = 2K_d* is determined by the tropical Hecke operator analysis. Our theorems show that this constant propagates cleanly through the ECOC decoder: the certified radius at decoder level is determined by per-bit margins (which come from the tropical score construction) and the code geometry (which is a design choice). This separation of concerns — tropical analysis provides *L*, code design provides *C*, and our theorems connect them — is the key architectural insight.

## 6. Discussion: Making Error-Correcting Codes Work for Robustness

*A Scientific American–style perspective*

Imagine you're sending a message through a noisy channel. You can't prevent the noise, but you can encode your message with redundancy so that the receiver can still decode it correctly even after some bits get corrupted. This is the fundamental idea of error-correcting codes, which underpin everything from QR codes to deep-space communications.

Now imagine the "message" is the true class of an image — is it a cat, a dog, or a bird? — and the "noisy channel" is an adversary who can perturb the input image by a small amount. A classifier looks at the image and produces "bits" of evidence (each bit says something like "this looks more cat-like than dog-like"). The adversary can corrupt these bits by changing the image, but only by a bounded amount per bit.

An ECOC classifier assigns each class a unique binary codeword and trains one binary classifier per bit. To classify a new input, it checks which codeword the evidence best matches. The beautiful insight of error-correcting codes is that if the codewords are far apart (in Hamming distance), the decoder can tolerate many bit errors and still recover the correct class.

Our theorem makes this intuition precise and provable. We show that:

- Each bit contributes a "margin" — how confident the classifier is about that bit
- The total robustness comes from summing margins over the bits where two classes differ
- The adversary can erode each bit's margin by at most *2Lr* (twice the Lipschitz constant times the perturbation radius)
- If the total margin exceeds the total erosion, the correct class survives

This is exactly analogous to the error-correction guarantee: instead of correcting random bit flips, we're correcting adversarial perturbations. The "distance" between codewords determines how many bits the adversary must corrupt, and the per-bit margins determine how hard each bit is to corrupt.

What makes this particularly exciting is the connection to tropical geometry. The Lipschitz constant *L* comes from deep mathematics — the theory of tropical Satake transforms in representation theory. This means the robustness guarantees are not just empirical observations but mathematical theorems, verified by a computer proof assistant to eliminate any possibility of error.

The practical upshot: by choosing good error-correcting codes and training classifiers with healthy per-bit margins, we can build multiclass systems with provably guaranteed robustness regions around every correctly classified input. This is a meaningful step toward trustworthy AI systems where safety-critical decisions can be backed by mathematical certificates.

## 7. Future Directions

1. **Truncated margins**: The `truncatedScore` variant (with a cap *τ*) would yield tighter bounds by reducing the influence of outlier margins.

2. **List decoding**: Instead of unique decoding, allow the decoder to output a small list of candidate classes. This naturally connects to top-*k* robustness and could provide graceful degradation.

3. **q-ary codebooks**: Extend from binary codes ({±1}) to *q*-ary tropical codebooks, where each bit can take values in a larger alphabet. The decomposition theorem generalizes naturally.

4. **Abstaining decoders**: Add a "reject" option when the certified margin is too small, providing a formal basis for selective prediction.

5. **Optimal code design**: Given a margin profile, find the code matrix *C* that maximizes the minimum certified radius. This is a combinatorial optimization problem connecting coding theory to robust machine learning.

## References

The formal proofs can be found in the Lean 4 files:
- `Bridges/ECOCDefs.lean` — Definitions and algebraic foundations
- `Bridges/ECOCRobustSoft.lean` — Soft decoding robustness theorems
- `Bridges/ECOCRobustHard.lean` — Hard decoding robustness theorems

Python demonstrations and visualizations:
- `Bridges/demo_ecoc_robustness.py` — Interactive demos with numerical examples
