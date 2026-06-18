# Future Directions: KW Witness Counting Theory

## Conjecture 1: Threshold Functions Maximize Witness Count Among Monotone Symmetric Profiles

**Precise Statement:** Among all monotone symmetric Boolean functions on n variables with exactly m true layers (i.e., profile p with exactly m values equal to true and monotone: p(k)=true, k≤l implies p(l)=true), the threshold function Thresh(n, n+1-m) maximizes |KWWitness(f)|.

**Test:** For each n ≤ 10, enumerate all monotone symmetric profiles with fixed m and compare witness counts using `kw_witness_count_symmetric`. The threshold profile (contiguous block at the top) should always win. For larger n, verify computationally up to n=50 using the O(n²) formula.

**Refutation criterion:** A single monotone symmetric profile with the same number of true layers but higher witness count disproves this.

**Impact:** If true, this establishes thresholds as canonical extremal objects in witness-counting complexity, analogous to how threshold functions are extremal for sensitivity, certificate complexity, and influence. It would give the sharpest possible lower bounds from the witness-counting method for any monotone symmetric function.

---

## Conjecture 2: Witness Entropy Approaches 2n for Majority

**Precise Statement:** For the majority function Maj_n (threshold at ⌈n/2⌉), the witness entropy satisfies:

    log₂|KWWitness(Maj_n)| = 2n - (1/2)log₂(n) - O(1)

More precisely, |KWWitness(Maj_n)| = Θ(4^n / √n).

**Test:** Compute log₂|KWWitness(Maj_n)| for n = 1, ..., 100 using the exact formula, and verify that log₂|KW| - 2n + (1/2)log₂(n) converges to a constant. Determine the constant (conjectured: -(1/2)log₂(π/2) ≈ -0.326).

**Refutation criterion:** If the difference log₂|KW| - 2n + (1/2)log₂(n) diverges or oscillates without converging, the conjecture is false in the stated form.

**Impact:** An exact asymptotic for majority witnesses would connect KW theory to the central limit theorem on the Boolean cube and enable entropy-based lower bounds for majority circuits. The 2n exponent matches 2^(2n) ≈ |{(x,y)}|, suggesting majority is "almost" as complex as a random function in witness terms.

---

## Conjecture 3: KW/W₁ Ratio Universality

**Precise Statement:** For threshold functions Thresh(n, t) with t = αn for fixed α ∈ (0,1), define:
- KW(n,t) = the exact KW witness count
- W₁(n,t) = Σ_{k≥t, l<t} C(n,k)·C(n,l)·|k-l| (the "naive" Wasserstein-1 cost)

Then KW(n,t)/W₁(n,t) → ρ(α) as n → ∞ for an explicit function ρ : (0,1) → (1,∞), with:
- ρ(1/2) = 5/3 (exact at the balanced case)
- ρ(α) → 1 as α → 0 or α → 1
- ρ is continuous and unimodal with maximum at α = 1/2

**Test:** Compute KW/W₁ for n = 10, 20, 50, 100 at t = ⌊αn⌋ for α = 0.1, 0.2, ..., 0.9. Check convergence and shape of ρ.

**Refutation criterion:** Non-convergence of KW/W₁ as n → ∞, or ρ(1/2) ≠ 5/3, or non-unimodality.

**Impact:** This would establish a precise "transport correction factor" that quantifies exactly how the coordinate structure of the Boolean cube inflates witness counts beyond the naive weight-distance formula. It bridges KW theory to optimal transport and could yield new inequalities.

---

## Conjecture 4: Parity Has Maximum Witness Count Among Non-Monotone Symmetric Functions

**Precise Statement:** Among all symmetric Boolean functions on n variables with exactly ⌊(n+1)/2⌋ true layers (half the layers mapped to true), the parity function (alternating profile p(k) = (k mod 2 = 1)) maximizes |KWWitness(f)|.

**Test:** For n ≤ 8, enumerate all symmetric profiles with ⌊(n+1)/2⌋ true layers and compare witness counts. For larger n, use random sampling of balanced profiles and compare with parity.

**Refutation criterion:** Any balanced profile with higher witness count than parity.

**Impact:** If true, this identifies parity as the extremal non-monotone symmetric function for witness complexity, providing a counterpart to the monotone threshold extremality conjecture. It would connect to the fact that parity has maximal sensitivity and certificate complexity.

---

## Conjecture 5: Fiber Concentration Near Diagonal for Majority

**Precise Statement:** For the majority function Maj_n, let W(k,l) = fiberTotal(n,k,l) be the witness count from the weight pair (k,l). Then the total witness count is dominated by pairs (k,l) with k and l both within O(√n) of n/2:

    Σ_{|k-n/2| ≤ C√n, |l-n/2| ≤ C√n} W(k,l) ≥ (1-ε) · |KWWitness(Maj_n)|

for any ε > 0 and sufficiently large C (depending on ε).

**Test:** For n = 20, 50, 100, 200, compute the fraction of total witnesses contributed by pairs (k,l) within distance C√n of (n/2, n/2-1) for C = 1, 2, 3, 4. Verify that C=3 captures >99% of witnesses.

**Refutation criterion:** If the fraction does not converge to 1 as C grows, or if a significant fraction of witnesses comes from pairs far from the diagonal.

**Impact:** This concentration result would enable saddle-point approximation of the witness count, connecting the exact formula to asymptotic analysis via the local central limit theorem. It's the key step toward proving Conjecture 2 rigorously and would justify treating majority witnesses as a "Gaussian" phenomenon on the Hamming cube.
