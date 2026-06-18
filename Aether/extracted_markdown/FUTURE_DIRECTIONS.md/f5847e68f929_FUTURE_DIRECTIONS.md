# Future Directions

## Conjecture 1: Full Tropical Radon for All Dimensions

**Conjecture:** For every `n ≥ 3` and every family of `n + 2` points in `ℚ^n`, there exist disjoint nonempty index subsets `A` and `B` whose tropical convex hulls intersect.

**Test:** The median-slope construction (proved here for `n = 2`) covers only two coordinates. For `n ≥ 3`, either (a) prove a "covering lemma" showing that among `n + 2` points, some singleton `{i₀}` has the property that every coordinate `k` is covered by some `j ≠ i₀` (i.e., `k ∈ argmax_{k'}(p(i₀)(k') - p(j)(k'))`), or (b) find a fundamentally different proof using tropical dependence theory or the Cayley trick.

**Impact:** Completing this would establish the full tropical Carathéodory–Radon–Helly chain in formal mathematics. It would also validate the conjectured tropical Radon number of `n + 2` in affine tropical space.

---

## Conjecture 2: Sharp Tropical Radon Number

**Conjecture:** The tropical Radon number of `ℚ^n` is exactly `n + 2`. That is:
- Every family of `n + 2` points admits a Radon partition (upper bound, proved for `n ≤ 2`).
- There exists a family of `n + 1` points in `ℚ^n` admitting no Radon partition (lower bound).

**Test:** For the lower bound, construct `n + 1` points in "tropical general position": take points `e_0 = 0`, `e_i(k) = δ_{ik} · M` for large `M` and `i = 1, ..., n`. Verify computationally that no disjoint nonempty `A, B ⊆ {0, ..., n}` gives intersecting tropical hulls. This should be checkable by exhaustive enumeration for `n ≤ 6`.

**Impact:** Establishing sharpness would place tropical Radon precisely in the hierarchy of combinatorial convexity theorems. The lower-bound configuration would serve as the tropical analogue of "points in general position" for classical Radon.

---

## Conjecture 3: Tropical Helly Number for Halfspaces

**Conjecture:** For tropical halfspaces in `ℚ^n` (sets of the form `{x : min_k(a_k + x_k) ≤ min_k(b_k + x_k)}`), the Helly number is at most `2n`.

**Test:** Construct families of tropical halfspaces in `ℚ^2` and `ℚ^3` and verify computationally whether `2n`-wise intersection implies total intersection. Known results in tropical geometry suggest Helly numbers between `n + 1` and `2n` depending on the halfspace class.

**Impact:** A formal tropical Helly theorem would complete the second link in the Carathéodory–Radon–Helly chain, opening the door to certified tropical linear programming and feasibility certificates.

---

## Conjecture 4: Projective vs. Affine Tropical Radon Numbers

**Conjecture:** The tropical Radon number in tropical projective space `TP^{n-1}` (equivalently, `ℚ^n` modulo constant shifts) equals `n + 1`, which is strictly less than the affine Radon number of `n + 2`.

**Test:** Formalize tropical projective space as `{x : Fin (n+1) → ℚ // x 0 = 0}` (normalized coordinates). Verify that `n + 1` projective points always admit a Radon partition, while `n` projective points in general position do not. The difference from the affine case arises because the "shift degree of freedom" in affine space adds one to the dimension.

**Impact:** This would reveal a genuine combinatorial difference between affine and projective tropical geometry, with implications for tropical algebraic geometry and valuated matroid theory.

---

## Conjecture 5: Tropical Tverberg Partition

**Conjecture:** For every `r ≥ 2` and `n ≥ 1`, any family of `(r - 1)(n + 1) + 1` points in `ℚ^n` admits a partition into `r` nonempty parts whose tropical convex hulls have a common point.

**Test:** For `r = 2`, this reduces to tropical Radon (with `n + 2` points). For `r = 3`, test with `2(n + 1) + 1 = 2n + 3` points in `ℚ^2` (7 points). Computationally verify that every configuration of 7 points in `ℚ^2` admits a 3-partition with triple-intersecting hulls.

**Impact:** Tropical Tverberg would be a breakthrough result connecting tropical geometry to topological combinatorics. The classical Tverberg theorem is one of the deepest results in discrete geometry; a tropical analogue would extend the theory to optimization and scheduling domains where min-plus algebra is the natural framework.
