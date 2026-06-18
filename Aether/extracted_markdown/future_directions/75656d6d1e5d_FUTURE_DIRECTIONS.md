# Future Directions: Perfect Cuboid Formalization Program

## Status

We have formally verified:
- **Mod-3 face diagonal obstruction**: If x² + y² = k², then 3 | x or 3 | y
- **Divisibility-by-3 theorem**: A primitive perfect cuboid has exactly two edges divisible by 3
- **Mod-5 divisibility**: Every Euler brick has at least one edge divisible by 5
- **Combined divisibility**: A primitive perfect cuboid satisfies both the mod-3 and mod-5 constraints
- **Certified density counts** mod 3, 5, 7, 15, 21, and 35 (all via exhaustive computation)
- **Density subadditivity**: The CRT product bounds the composite modulus density from above

---

## Hypothesis 1: Mod-1155 Total Obstruction

**Conjecture:** There exist no triples (x, y, z) ∈ (ℤ/1155ℤ)³ satisfying the full cuboid QR conditions together with the primitive parity constraint (exactly two even, one odd, both even edges divisible by 4), where 1155 = 3 × 5 × 7 × 11.

**Test:** Enumerate all 1155³ ≈ 1.54 × 10⁹ triples modulo 1155 with parity constraints and check all four QR conditions. This is computationally feasible (several hours on modern hardware) and can be parallelized. Use Python or C for the enumeration and then certify any non-empty survivor set.

**Predicted outcome:** The survivor set will be non-empty but very small — likely fewer than 10⁴ classes out of ~10⁹ total. If empty, this would give a machine-checkable proof that no primitive perfect cuboid exists.

**Impact if true:** A formally verified mod-1155 total obstruction would resolve the perfect cuboid problem as a consequence of finite modular arithmetic — no algebraic geometry needed. This would be one of the most significant results in certified number theory.

**Fallback if false:** The surviving classes define a certified constraint satisfaction problem. Each survivor can be analyzed for further obstructions via higher prime moduli (13, 17, 19, ...) or algebraic descent arguments.

---

## Hypothesis 2: Elliptic Fibration of the Residual Surface

**Conjecture:** After parametrizing the constraints u² − 1 = a² and v² − 1 = b² via the rational hyperbola parametrization u = (r² + 1)/(2r), a = (r² − 1)/(2r), the residual equation w² = u² + v² − 1 becomes an elliptic curve over ℚ(r) when expressed as a curve in (s, w) (where v = (s² + 1)/(2s)).

Specifically, substituting gives:
w² = ((r² + 1)/(2r))² + ((s² + 1)/(2s))² − 1

which, after clearing denominators, yields a quartic in s that generically has genus 1.

**Test:**
1. Compute the genus of the resulting curve over ℚ(r) using a computer algebra system (SageMath or Magma).
2. If genus 1, compute the Mordell-Weil group of the generic fiber.
3. Determine the rank — if rank 0, no non-trivial rational points exist generically.

**Predicted outcome:** The generic fiber has genus 1 with rank 0 or 1 over ℚ(r). This would transform the cuboid problem into an explicit elliptic curve computation.

**Impact if true:** Proves that the perfect cuboid problem reduces to understanding the Mordell-Weil group of a specific elliptic surface. If the rank is 0 generically, this gives a strong structural reason for non-existence (outside a thin set of special fibers). If rank 1, the generator encodes the unique family of rational points, and integrality constraints can be analyzed via standard descent.

**Fallback if false:** If the surface is rational (genus 0 over ℚ(r)), then a two-parameter family of rational points exists, and the problem reduces to integrality — a different but equally interesting direction.

---

## Hypothesis 3: Asymptotic Density Zero of Admissible Residues

**Conjecture:** Let f(M) = |{(x,y,z) ∈ (ℤ/Mℤ)³ : GoodCuboidMod M x y z}| / M³. Then for squarefree M equal to the product of the first k primes, f(M) → 0 as k → ∞.

More precisely, we conjecture f(M) = O(∏_{p | M} (1 − c_p)) where c_p > 0 is the proportion of triples excluded by prime p alone, and this product diverges (i.e., ∑ c_p = ∞).

**Test:**
1. Compute f(M) for M = 2, 6, 30, 210, 2310, 30030 (products of first 1–6 primes).
2. Verify the product formula against exact counts.
3. Test whether c_p → 0 or remains bounded away from 0.

**Predicted outcome:** c_p ≈ C/p for some constant C > 0, and ∑ c_p diverges like the harmonic series. This gives f(M) → 0, meaning the "probability" that a random triple is admissible vanishes.

**Impact if true:** This is a formal analogue of the Borel-Cantelli lemma for the cuboid problem — it shows that "almost all" residue classes are excluded, and surviving candidates are measure-zero in the profinite completion. Combined with effective bounds, this could be used to prove that any perfect cuboid (if it exists) has edges exceeding 10^{100} or more.

**Fallback if false:** If c_p → 0 fast enough that ∑ c_p converges, then a positive-density set of residue classes survives at every modulus, and the modular approach alone cannot resolve the problem. This would be equally interesting as it would prove the limits of local methods.

---

## Hypothesis 4: Brauer-Manin Obstruction on the Constrained Surface

**Conjecture:** The affine variety V defined by:
- u² − a² = 1
- v² − b² = 1
- w² = u² + v² − 1

has rational points locally (over ℚ_p for all primes p and over ℝ) but the Brauer-Manin obstruction is non-trivial. That is, the Brauer set V(𝔸_ℚ)^Br is strictly smaller than V(𝔸_ℚ), and possibly empty.

**Test:**
1. Verify local solubility at all primes p ≤ 100 by finding rational p-adic solutions.
2. Compute the Brauer group Br(V)/Br₀(V) using étale cohomology (requires Magma or specialized software).
3. Check whether the Brauer-Manin pairing annihilates all adelic points.

**Predicted outcome:** Local points exist everywhere (the variety is locally soluble), but the Brauer group is non-trivial (likely ℤ/2ℤ or (ℤ/2ℤ)²), and the Brauer-Manin obstruction eliminates all rational points.

**Impact if true:** This would be a landmark result in arithmetic geometry — the first known natural example of a Brauer-Manin obstruction resolving a classical Diophantine problem. It would prove that the perfect cuboid problem is not solvable by local methods alone, but that the global obstruction has a cohomological origin. This would open a new chapter in formal arithmetic geometry.

**Fallback if false:** If the Brauer-Manin obstruction is trivial, then the non-existence of rational points (if true) must come from a deeper geometric reason — possibly related to the Shafarevich-Tate group of an associated elliptic surface.

---

## Hypothesis 5: Descent Obstruction via Denominator Growth

**Conjecture:** For every rational point (u, v, w, a, b) on the constrained surface V (Hypothesis 4), after writing u = p/q, v = r/s in lowest terms and clearing denominators in the original integer cuboid equations x² + y² = d₁², x² + z² = d₂², etc., the denominators q and s satisfy gcd(q, s) > 1 and the resulting integer system has no solution.

More precisely: if x = q·s·x', y = q·s·y', z = q·s·z' for the denominator clearing, then gcd(x', y', z') > 1 always, violating primitivity.

**Test:**
1. For the known parametric families of rational solutions to u² + v² − w² = 1 (from Pythagorean-like constructions), substitute into the extra constraints u² − 1 = a² and v² − 1 = b².
2. Analyze the resulting Diophantine equations for integrality obstructions.
3. Check whether denominators from the rational parametrization prevent integer solutions after clearing.

**Predicted outcome:** The denominators in the rational parametrization introduce forced common factors in the integer reconstruction, making primitivity impossible.

**Impact if true:** This would give a constructive proof that the rational-to-integer bridge fails for perfect cuboids — every rational candidate self-destructs when lifted to integers. This is a descent argument in the classical sense and would be formalizable in the existing framework.

**Fallback if false:** If some rational point does lift to integers, we have constructed a perfect cuboid. This outcome, while undermining the conjecture, would resolve the original problem affirmatively.

---

## Priority Ordering

1. **Hypothesis 3** (Density zero) — most accessible, builds directly on current formalization
2. **Hypothesis 1** (Mod-1155 total obstruction) — computationally intensive but definitive
3. **Hypothesis 2** (Elliptic fibration) — requires algebraic geometry infrastructure
4. **Hypothesis 5** (Descent obstruction) — bridges rational and integer worlds
5. **Hypothesis 4** (Brauer-Manin) — deepest mathematically, hardest to formalize

Each hypothesis is falsifiable, testable with specific computations, and either resolves the perfect cuboid problem or reveals new structural information about why it resists resolution.
