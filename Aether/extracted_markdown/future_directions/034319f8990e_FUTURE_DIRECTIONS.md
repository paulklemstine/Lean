# Future Directions: Benford Renormalization Theory

## Synthesis

The five directions below form a coherent program to develop Benford renormalization from a collection of theorems about digit statistics into a fully realized invariant theory of arithmetic dynamics. The throughline is the **logarithmic cocycle** k ↦ fract(log_b(T^k(n))) as the central object: Directions 1–2 strengthen its theoretical foundations, Direction 3 extends the obstruction theory to richer dynamical classes, Direction 4 builds computational infrastructure for empirical certification, and Direction 5 bridges to information-theoretic and statistical-mechanical frameworks. Together, they would establish Benford compliance as a computable dynamical invariant on par with entropy or Lyapunov exponents.

---

## Direction 1: Formal Weyl Equidistribution and Quantitative Bounds

**Conjecture:** Weyl's equidistribution theorem for irrational rotations can be formalized in Lean 4 with Mathlib, including quantitative discrepancy bounds of the form D_N ≤ C/(N·‖qα‖) for continued fraction convergents q.

**Test:** Formalize the theorem statement and proof in Lean 4. Verify that it plugs directly into Theorem 3.3 (rotation model) to eliminate the equidistribution hypothesis, yielding an unconditional Benford theorem for geometric sequences.

**Impact:** This would upgrade the rotation model theorem from a conditional result (assuming Weyl) to an unconditional result, making the entire Benford theory self-contained within the formal development. The quantitative bounds would also yield convergence rates for Benford frequencies.

**Catalog References:** `Speculative/BenfordRenormalization/Theorems.lean` — Theorem `benford_freq_of_rotation_model` and Definition `WeylEquidistribution`.

**Proof Strategy:** Formalize Weyl's theorem via the Erdős–Turán inequality or the three-distance theorem. The key technical challenge is formalizing trigonometric sum estimates. An alternative route uses the unique ergodicity of irrational rotations on the circle, leveraging Mathlib's `AddCircle` infrastructure.

**Domain Bridges:** Connects to **analytic number theory** (exponential sum estimates) and **ergodic theory** (unique ergodicity). The quantitative bounds bridge to **computational number theory** (effective equidistribution).

**Lineage:** Extends Theorems 3.3 and 3.4 of the current development. Builds on Weyl (1916), Kuipers & Niederreiter (1974).

**Ambition:** 🟡 Challenging but achievable — Weyl's theorem is well-understood mathematically; the difficulty is purely in formalization.

---

## Direction 2: Asymptotic Cocycle Stability (Summable Perturbation Theorem)

**Conjecture:** If u_k and v_k are positive integer sequences with Σ |log_b(u_k) - log_b(v_k)| < ∞ (summable logarithmic perturbation), then u is Benford if and only if v is.

**The key insight is** that summable perturbation of the cocycle preserves the spectral type: the Fourier modes of the perturbed sequence converge to those of the original, so obstruction/non-obstruction is invariant.

**Why now?** The current development proves stability under *eventual equality* (Theorem 3.6). The summable perturbation theorem is the natural quantitative strengthening, and the formal infrastructure (filter language, asymptotic estimates) is already in place.

**Test:** Formalize and prove the summable perturbation theorem in Lean 4. As a corollary, show that T(n) = r·n + p(n) with p(n) = O(n^{1-ε}) produces Benford orbits whenever log_b(r) is irrational.

**Impact:** This would cover a large class of "asymptotically multiplicative" maps, including affine maps T(n) = an + c (where the +c is summably perturbative in log-space) and polynomially perturbed multiplicative systems.

**Catalog References:** `Speculative/BenfordRenormalization/Theorems.lean` — Theorem `benford_stable_of_eventually_eq`.

**Proof Strategy:** Show that if Σ |x_k - y_k| < ∞ and fract(y_k) is equidistributed mod 1, then fract(x_k) is also equidistributed. Use the Weyl criterion: the m-th Fourier mode satisfies |c_m(x) - c_m(y)| ≤ (2π|m|/N) Σ |x_k - y_k| → 0.

**Domain Bridges:** Connects to **perturbation theory** in functional analysis and **stability theory** in dynamical systems.

**Lineage:** Extends Theorem 3.6. Builds on standard summability criteria for equidistribution (Kuipers & Niederreiter, Chapter 1).

**Ambition:** 🟢 Highly feasible — the mathematical argument is clean and the formalization infrastructure exists.

---

## Direction 3: Spectral Classification for Piecewise-Affine Maps

**Conjecture:** For piecewise-affine maps T : ℕ → ℕ of the form T(n) = a_i n + b_i when n ∈ I_i (where {I_i} partitions ℕ into finitely many arithmetic progressions), the Benford status is determined by whether the weighted average log-slope Σ p_i log_b(a_i) is irrational, where p_i is the natural density of visits to branch I_i.

**The key insight is** that piecewise-affine maps generate a Markov chain on digit intervals, and the logarithmic cocycle becomes a random walk with drift equal to the weighted average slope. Benford behavior corresponds to the drift being irrational.

**Why now?** The geometric and affine cases are now formally established. Piecewise-affine maps are the natural next class, and they include many systems of number-theoretic interest (Collatz-type maps, digit-based recurrences).

**Test:** Prove the conjecture for maps with two branches (e.g., T(n) = 2n if n even, T(n) = 3n+1 if n odd, on upward-trending orbits). Compute digit frequencies for systematic families and compare with the predicted weighted-slope criterion.

**Impact:** This would give a complete Benford classification for a rich class of integer maps, and provide a framework for approaching the Collatz conjecture's digit statistics.

**Catalog References:** `Speculative/BenfordRenormalization/Defs.lean` — all core definitions.

**Proof Strategy:** Model the piecewise map as a Markov chain on the digit partition of [0,1). Show that the cocycle's drift is the average log-slope, and apply the law of large numbers + equidistribution for random walks with irrational drift.

**Domain Bridges:** Connects to **Markov chain theory**, **random matrix products**, and **symbolic dynamics**. The weighted-slope criterion has analogs in **Lyapunov exponent theory**.

**Lineage:** Builds on all current theorems. Extends toward Lagarias (1985) on Collatz-type systems.

**Ambition:** 🔴 Grand challenge — full proof for general piecewise-affine maps requires control of the Markov chain's mixing, which may be as hard as proving specific instances of the Collatz conjecture.

---

## Direction 4: Certified Computational Benford Diagnostics

**Conjecture:** There exists an efficient, formally verified algorithm that, given an oracle for T^k(n), certifies whether the first N terms of the orbit are ε-close to Benford in a precisely specified sense (total variation distance from Benford frequencies ≤ ε).

**The key insight is** that the Fourier-based obstruction detection provides a computationally efficient and mathematically grounded diagnostic: computing the first M Fourier modes of the fractional-log sequence requires O(NM) time and provides a spectral certificate.

**Why now?** The formal definitions of `benfordFreqUpTo` and `benfordTheoretical` are verified, and the connection to Fourier analysis is established conceptually (via the Weyl criterion). What remains is to formally verify the computational pipeline itself.

**Test:** Implement and formally verify a function that computes benfordFreqUpTo and compares it to benfordTheoretical, with a proven error bound. Apply to 10+ map families and tabulate results.

**Impact:** This would create the first formally verified Benford analysis tool, useful for fraud detection, pseudorandomness testing, and dynamical system classification.

**Catalog References:** `Speculative/BenfordRenormalization/Defs.lean` — `benfordFreqUpTo`, `benfordTheoretical`, `leadingDigitBase`.

**Proof Strategy:** Verify that the integer computation of `leadingDigitBase` matches the logarithmic interval characterization (already partly proved in the rotation model theorem's proof). Formally bound the rounding errors in finite-precision Fourier mode computation.

**Domain Bridges:** Connects to **verified computation**, **numerical analysis**, and **forensic accounting** (Benford-based fraud detection).

**Lineage:** Builds on all current definitions and the rotation model theorem.

**Ambition:** 🟢 Feasible — the computational components are straightforward; the challenge is formal verification of numerical bounds.

---

## Direction 5: Benford Entropy and Information-Theoretic Classification

**Conjecture:** The **Benford entropy** H_B(u) = -Σ_d freq(d) log(freq(d)), computed from the limiting leading-digit frequencies, is maximized exactly when the sequence is Benford, and the gap H_Benford - H_B(u) is controlled by the largest Fourier mode of the cocycle.

**The key insight is** that Benford's law maximizes the entropy of the leading-digit distribution subject to the scale-invariance constraint, and spectral obstruction creates a measurable entropy deficit. This connects the obstruction theory to information theory and statistical mechanics.

**Why now?** The formal framework for digit frequencies and obstruction is established. The entropy interpretation provides a natural scalar invariant (a single number rather than a full frequency profile) and connects to the deep theory of maximum entropy distributions.

**Test:** Compute H_B for the sequence families in the computational experiments. Verify that H_B is maximized for Benford-compliant sequences and that the entropy gap correlates with the maximum Fourier mode magnitude. Formalize the entropy inequality in Lean 4.

**Impact:** This would provide a single-number summary of Benford compliance with a precise information-theoretic interpretation, and would connect the theory to the broader framework of maximum entropy methods in statistical physics and machine learning.

**Catalog References:** `Speculative/BenfordRenormalization/Defs.lean` — `benfordTheoretical`, `benfordFreqUpTo`.

**Proof Strategy:** The Benford distribution maximizes entropy among distributions on {1,...,b-1} satisfying the scale-invariance property P(d) = Σ_k P(kb+d). This can be proved via Lagrange multipliers. The entropy gap bound follows from Pinsker's inequality applied to the Fourier expansion.

**Domain Bridges:** Connects to **information theory** (maximum entropy), **statistical physics** (Gibbs distributions, free energy), and **machine learning** (entropy-based anomaly detection). The entropy gap has an analog in the **thermodynamic formalism** of dynamical systems.

**Lineage:** Builds on the digit frequency definitions. Extends toward Berger & Hill (2015), Chapter 7 on entropy and Benford.

**Ambition:** 🟡 Challenging — the mathematical ideas are well-established, but formalizing entropy inequalities and connecting to the Fourier-based obstruction requires new infrastructure.
