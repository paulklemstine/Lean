# Future Directions: Perfect Cuboid Modular Sieve Program

## Summary of Established Results

We have formally verified the following:
- **Mod-105 sieve**: Exactly 14,245 out of 1,157,625 residue classes mod 105 survive the four quadratic residue conditions (face + space diagonals). This is a density collapse to 1.23%.
- **CRT multiplicativity**: The count factorizes as 7 × 37 × 55, perfectly matching the product of individual prime counts at 3, 5, and 7. This means the quadratic residue conditions are independent across these primes.
- **Space diagonal obstruction**: At mod 7, the space diagonal kills 24 additional face-diagonal survivors (from 79 to 55), a 30.4% reduction.
- **Bridge theorem**: Any integer perfect cuboid must have residues in one of these 14,245 classes.

---

## Hypothesis 1: Higher-Modulus Sieve via Prime 11

**Conjecture:** The mod-1155 sieve (= 3 × 5 × 7 × 11) reduces the survivor density below 0.2% of the total residue space, and the count factorizes multiplicatively as `count(3) × count(5) × count(7) × count(11)`.

**Test:** Compute `countSquareSurvivors 11` and `countSquareSurvivors 1155`. If the count at 1155 equals `7 × 37 × 55 × count(11)`, multiplicativity is confirmed at this level. If not, genuine inter-prime interaction exists between 11 and the smaller primes.

**Predicted count at mod 11:** Approximately 11³ × 0.16 ≈ 213 (extrapolating from prime 7's density ~16%). So mod-1155 survivors ≈ 14,245 × 213/11³ ≈ 2,279 — roughly 0.15% density.

**Impact if true:** This would establish that the quadratic residue obstruction has a universal multiplicative structure across primes, and that density decreases geometrically with each new prime. A density of 0.15% at mod 1155 would give a search reduction factor of ~667×. This would provide strong computational evidence that the asymptotic density of admissible residues is zero (see Hypothesis 3).

**Impact if false:** Non-multiplicativity at prime 11 would reveal a fundamentally new interaction between quadratic residue structures across primes. This would be mathematically significant in its own right, suggesting deep correlations in the number-theoretic structure of the cuboid equations.

---

## Hypothesis 2: Elliptic Fibration of the Constrained Surface

**Conjecture:** After the double hyperbola parametrization
\[
u = \frac{r^2+1}{2r}, \quad v = \frac{s^2+1}{2s},
\]
the remaining equation `w² = u² + v² - 1` becomes a genus-1 curve over ℚ(r) (or ℚ(s)), i.e., the constrained surface `w² = u² + v² - 1, u² − 1 = □, v² − 1 = □` admits an elliptic fibration.

**Test:**
1. Substitute the parametrization into `w² = u² + v² - 1`.
2. Clear denominators to get an equation in `r, s, w`.
3. For fixed rational `r`, determine the genus of the resulting curve in `(s, w)`.
4. If genus = 1 for generic `r`, identify the elliptic curve and compute its rank over ℚ(r).

**Computation:** After substitution:
\[
w^2 = \frac{(r^2+1)^2}{4r^2} + \frac{(s^2+1)^2}{4s^2} - 1
= \frac{r^4 + 2r^2 + 1}{4r^2} + \frac{s^4 + 2s^2 + 1}{4s^2} - 1.
\]
Clearing denominators with `W = 2rsw`:
\[
W^2 = s^2(r^4 + 2r^2 + 1) + r^2(s^4 + 2s^2 + 1) - 4r^2s^2.
\]
For fixed `r`, this is a degree-4 curve in `(s, W)` — generically genus 1.

**Impact if true:** The perfect cuboid problem would reduce to finding rational points on an explicit family of elliptic curves parametrized by `r ∈ ℚ`. Tools from the arithmetic of elliptic curves (BSD conjecture, descent, Heegner points) would become applicable. If most fibers have rank 0, this would give strong evidence against perfect cuboid existence.

**Impact if false:** If the generic fiber has genus 0 (rational), then the constrained surface is rational and admits a dense parametrization — making the perfect cuboid problem purely a question of integrality, not existence of rational points.

---

## Hypothesis 3: Asymptotic Density Zero

**Conjecture:** Let `D(M)` denote the fraction of triples in (ℤ/Mℤ)³ satisfying all four quadratic residue conditions. Then for squarefree `M = p₁ · p₂ · ... · pₖ`,
\[
D(M) = \prod_{i=1}^{k} D(p_i),
\]
and `D(M) → 0` as `M → ∞` through squarefree integers.

**Test:**
1. Verify multiplicativity `D(M) = ∏ D(pᵢ)` for M = 3·5·7·11, 3·5·7·11·13, etc.
2. Compute `D(p)` for primes `p ≤ 50` and check whether `∏ D(p)` converges to 0.
3. Analyze the average `D(p)` and determine whether `∑ -log D(p)` diverges.

**Key computation:** From our data, `D(3) = 7/27 ≈ 0.259`, `D(5) = 37/125 ≈ 0.296`, `D(7) = 55/343 ≈ 0.160`. The geometric mean density per prime factor is approximately `(0.259 × 0.296 × 0.160)^{1/3} ≈ 0.232`. If this average persists, the product over the first `k` primes decreases as `0.232^k → 0`.

**Impact if true:** This would prove that the "natural density" of integers satisfying the modular cuboid conditions is 0. While this does not prove nonexistence (thin sets can be nonempty), it would quantify the arithmetic scarcity of perfect cuboids and provide rigorous backing for the heuristic expectation that they do not exist.

**Impact if false:** If the product stabilizes at a positive constant, that would suggest a finite positive density of admissible residue classes persists at every level. This would mean modular obstructions alone cannot rule out perfect cuboids — geometric or global methods would be essential.

---

## Hypothesis 4: Brauer–Manin Obstruction on the Constrained Surface

**Conjecture:** The constrained surface
\[
S: \quad w^2 = u^2 + v^2 - 1, \quad u^2 - 1 = a^2, \quad v^2 - 1 = b^2
\]
has local points everywhere (i.e., over ℝ and over ℚₚ for all primes p) but has no Zariski-dense set of rational points. The obstruction is explained by a nontrivial Brauer–Manin obstruction on a smooth compactification of S.

**Test:**
1. Verify local solubility: construct explicit solutions over ℝ and over ℚₚ for all p ≤ 100. (Over ℝ, e.g., u = 5/4, v = 5/4, w, a, b chosen appropriately.)
2. Compute the Brauer group Br(S̃)/Br(ℚ) for a smooth projective model S̃.
3. Evaluate the Brauer–Manin pairing for candidate local points.

**Impact if true:** This would be a landmark result connecting the perfect cuboid problem to the deepest tools in arithmetic geometry. It would show that the obstruction is fundamentally global, not just local, and would align the problem with the general philosophy of the Brauer–Manin program.

**Impact if false:** If no Brauer–Manin obstruction exists, and local points exist everywhere, then by the Hasse principle philosophy, global rational points should be expected. Finding them (or proving they give integer solutions) would become the central challenge.

---

## Hypothesis 5: Descent Obstruction via Denominator Growth

**Conjecture:** For every rational point `(u, v, w, a, b)` on the constrained surface `S` with `u = p/q, v = r/s` in lowest terms, the denominators `q` and `s` satisfy `q · s > C · max(|p|, |r|)^{1+ε}` for some absolute constants `C > 0` and `ε > 0`. In particular, there is no rational point with `q = s = 1` (i.e., no integer point with `x = 1`).

**Test:**
1. For Euler bricks (44, 117, 240), (85, 132, 720), etc., compute the rational surface point and measure denominator sizes.
2. Parametrically scan rational points near known Euler brick solutions.
3. Look for families where denominators shrink — these would be counterexample candidates.

**Concrete data point:** For the (44, 117, 240) brick:
- `u = a/x = 125/44`, denominator 44
- `v = b/x = 244/44 = 61/11`, denominator 11
- `q · s = 44 · 11 = 484`, while `max(125, 61) = 125`, ratio = 3.87

**Impact if true:** A formally verified lower bound on denominator growth would prove that rational points on the constrained surface cannot be "close" to integer points, giving a rigorous obstruction to perfect cuboid existence via descent.

**Impact if false:** If denominators can be made arbitrarily small relative to numerators, this would suggest that the surface has rational points approaching integer points arbitrarily closely — making the integer point problem more delicate and potentially solvable.

---

## Priority Ordering

1. **Hypothesis 1** (highest priority): Immediately testable with existing infrastructure. Extends the modular sieve to prime 11 and verifies multiplicativity.
2. **Hypothesis 3**: Flows directly from Hypothesis 1 data. The density-zero conjecture is the key asymptotic result.
3. **Hypothesis 2**: Requires symbolic computation but gives the deepest geometric insight.
4. **Hypothesis 5**: Computationally accessible from known Euler brick data.
5. **Hypothesis 4**: Most ambitious; requires Brauer group computation. Long-term target.
