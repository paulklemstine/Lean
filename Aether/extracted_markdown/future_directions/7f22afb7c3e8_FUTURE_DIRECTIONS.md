# Future Directions: Pythagorean Valuation Descent

## 1. Full Berggren Completeness via Descent

**Conjecture**: Every primitive Pythagorean triple `(a, b, c)` with `a` odd, `b` even, `gcd(a,b) = 1`, and all entries positive, lies in the Berggren tree — i.e., there exists a unique word `w : OrbitWord` such that `wordTriple w = (a, b, c)`.

The key insight is that our descent bounds (`inv_hyp_pos` and `inv_hyp_lt`) show the hypotenuse strictly decreases under *any* inverse, so a natural "greedy descent" strategy is to try all three inverses and pick the one that yields a positive triple. The conjecture is that exactly one inverse always yields positive entries for non-root triples, and iteration terminates at `(3, 4, 5)`.

**Why now?** We already have the strict descent on hypotenuse (`inv_hyp_descent`) and the Pythagorean preservation (`invBerggren_pythag`). The missing piece is showing that among the three candidate inverses, at least one produces all-positive entries — this requires a case analysis on the parity and ordering of `a` and `b` that interacts with the primitivity condition `gcd(a,b) = 1`. The existing `berggrenStep_distinct` theorem ensures uniqueness once existence is established.

**Falsifiable test**: Computationally verify for all primitive triples with `c ≤ 10000` that exactly one inverse gives positive entries; then attempt formalization.

---

## 2. Optimal Descent Rate and Logarithmic Complexity

**Conjecture**: The descent algorithm terminates in at most `⌈log₂(c/5)⌉ + O(1)` steps, not just the trivial `c - 5` bound from strict decrease by at least 1.

The key insight is that `inv_hyp_rate` gives `3c - 2(a+b) ≤ c - 2`, but the *typical* descent is much steeper. For balanced triples (where `a ≈ b ≈ c/√2`), the inverse hypotenuse is approximately `(3 - 2√2)c ≈ 0.172c`, giving geometric convergence. For highly unbalanced triples (like the A-ray where `a ∼ 2n+3`, `b ∼ 2n²`, `c ∼ 2n²+1`), descent through the A-inverse gives `c' ≈ c/(2n)`, also contracting rapidly.

**Why now?** The existing `inv_hyp_rate` already proves a universal constant gap (the `c - 2` bound), but establishing the logarithmic bound requires a geometric contraction ratio. The Lorentz form `a² + b² - c² = 0` constrains `(a+b)/c ∈ (1, √2]`, so `3 - 2(a+b)/c ∈ [3 - 2√2, 1)`, giving a contraction factor of at most `3 - 2√2 ≈ 0.172`. Formalizing this with `Real.sqrt` would give a tight logarithmic bound.

**Falsifiable test**: Compute the maximal descent depth over all primitive triples with `c ≤ 10^6` and verify it stays below `4 · log₂(c)`.

---

## 3. Canonical Normal Forms and Minimal Descent Paths

**Conjecture**: Among all Berggren words `w` evaluating to a given primitive triple, the one produced by the greedy descent (always choosing the inverse with smallest resulting hypotenuse) is the lexicographically least word under the ordering `U < A < D`.

The key insight is that the descent score `3c - 2a - 2b` is direction-independent (our `inv_hyp_formula`), so all three inverses descend at the same rate in hypotenuse. The tie-breaking must happen on the first two coordinates, and we conjecture that the inverse producing the smallest `a'` value (the first coordinate) corresponds to a canonical choice that is lexicographically minimal.

**Why now?** The `inv_hyp_formula` theorem proves the direction-independence of the descent score, which means canonical form selection must come from secondary criteria. This opens a connection to lattice basis reduction: just as LLL chooses a canonical short basis, the Berggren descent could choose a canonical word via a secondary ordering on the non-hypotenuse coordinates.

**Falsifiable test**: For all primitive triples with `c ≤ 1000`, enumerate all valid descent paths and verify the greedy-smallest-a choice matches the lexicographic minimum.

---

## 4. Valuation-Weighted Descent and p-adic Tree Stratification

**Conjecture**: Define `S_p(a, b, c) = c + p^{v_p(c)}` for a prime `p`. Then for `p = 2`, the quantity `S_2` is a strictly decreasing Berggren descent invariant that additionally stratifies the tree by 2-adic valuation depth of the hypotenuse.

The key insight is that the 2-adic valuation of the hypotenuse `c` shifts predictably under Berggren steps: since `c' = 2a ± 2b + 3c` and `v_2(2a ± 2b) ≥ 1` while `v_2(3c) = v_2(c)`, the ultrametric inequality gives `v_2(c') ≥ min(1, v_2(c))`. Combined with the strict hypotenuse descent, the composite score `S_2` could provide both termination and a stratification of the Berggren tree by arithmetic depth.

**Why now?** The catalog already contains `PadicValuationDepth.lean` with the `ValuationDepthMeasure` typeclass and ultrametric composition laws. Combining these with our `inv_hyp_descent` would produce the first bridge between p-adic valuation theory and Pythagorean tree dynamics — connecting three distinct mathematical domains in a single theorem.

**Falsifiable test**: Compute `v_2(c)` for all Berggren tree nodes up to depth 8 and verify that `c + 2^{v_2(c)}` is monotonically decreasing along every descent path.

---

## 5. Berggren Descent as a Lattice Reduction Algorithm

**Conjecture**: The Berggren descent algorithm, when viewed as acting on the lattice `Λ_t = \{v ∈ ℤ³ : Q(v) = 0, v ≡ t \pmod{M}\}` for suitable `M`, produces a certified short vector in `O(log c)` steps, with the shortest vector being `(3, 4, 5)`.

The key insight is that the Gram matrix `G(a,b,c) = [[c, a], [a, c]]` from `BerggrenLatticeReductionDuality.lean` has determinant `b²` and shortest vector norm related to `c`. Each Berggren descent step replaces `G(a,b,c)` with `G(a', b', 3c-2a-2b)` where the determinant and norm both decrease. This makes Berggren descent a *lattice reduction algorithm* on the family of rank-2 lattices parameterized by Pythagorean triples, analogous to Gauss reduction for binary quadratic forms.

**Why now?** The existing `gramPD_injective` theorem in `BerggrenLatticeReductionDuality.lean` proves that the Gram map is injective, and our `descent_step_correct` proves the algebraic correctness of each step. The missing piece is showing that Gram matrix "size" (trace, determinant, or Minkowski reduced form) decreases at each step — this would complete the analogy with classical lattice reduction and give an entirely new characterization of Berggren descent as a Gauss-style algorithm on Lorentzian lattices.

**Falsifiable test**: For 100 random primitive triples with `c ∼ 10^{10}`, run Berggren descent and verify that the Gram trace decreases at each step and the total number of steps is at most `4 · log₂(c)`.
