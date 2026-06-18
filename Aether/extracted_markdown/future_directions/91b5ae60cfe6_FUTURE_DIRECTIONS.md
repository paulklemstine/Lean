# Future Directions: Semantic Entropy for Monotone Complexity

## Conjecture 1: Entropy–KW Equivalence

**Statement.** There exist universal constants a, b > 0 such that for every monotone Boolean function f : {0,1}^n → {0,1}:
$$a \cdot \text{depth}_{\text{KW}}(f) \leq \max_{x \leq y} \Delta_f(x,y) \leq b \cdot \text{depth}_{\text{KW}}(f)$$
where depth_KW(f) is the monotone circuit depth of f (equivalently, the communication complexity of the Karchmer–Wigderson relation R_f).

**Test.** Enumerate all monotone Boolean functions for n = 3, 4, 5. For each, compute both the maximum semantic entropy drop and the exact monotone circuit depth (via exhaustive search over circuits of increasing depth). Plot the ratio and check if it remains bounded.

**Disconfirmation criterion.** If the ratio max_Δ / depth_KW grows unboundedly with n for some explicit family, the conjecture is false. Conversely, if a super-polynomial separation is found for any family, the conjecture fails.

**Impact.** If true, semantic entropy provides an alternative polynomial-time computable proxy for monotone circuit depth, enabling automated lower bound certification.

---

## Conjecture 2: Clique Entropy Barrier

**Statement.** For the monotone clique function Clique_{k,m} (does a graph on m vertices contain a k-clique?), the maximum semantic entropy drop satisfies:
$$\max_{x \leq y} \Delta_{\text{Clique}_{k,m}}(x,y) = \Omega\left(\binom{m}{2} / k^2\right)$$
This would give a depth lower bound of Ω(m²/(k² log k)) for fan-in-2 circuits.

**Test.** Compute the entropy profiles for Clique_{3,m} (triangle detection) for m = 4, 5, 6, 7 and measure the maximum entropy drop. Compare the growth rate with m²/9.

**Disconfirmation criterion.** If the maximum entropy drop grows slower than m² / k² for any constant k, or if it saturates at a much smaller value, the conjecture is false.

**Impact.** Would provide a new proof technique for monotone depth lower bounds for clique, potentially matching or exceeding known Razborov-style bounds.

---

## Conjecture 3: Cover Drop Uniformity for Threshold Functions

**Statement.** For the threshold function Thr_{t,n} (output 1 iff sum ≥ t), the maximum single-step (cover) entropy drop is exactly 1, independent of n and t (for 1 ≤ t ≤ n):
$$\max_{u \prec v} \Delta_{\text{Thr}_{t,n}}(u, v) = 1$$

**Test.** Compute the cover entropy drop for all threshold functions Thr_{t,n} for n = 2, ..., 8 and all valid t. Check if the maximum is always 1.

**Disconfirmation criterion.** Find any (n, t) where the maximum cover drop differs from 1.

**Impact.** If true, this identifies threshold functions as having the most "regular" entropy landscape, suggesting they are extremal objects in the entropy framework. This could lead to tight entropy-based depth bounds for sorting networks.

---

## Conjecture 4: Entropy Drop Additivity on Product Functions

**Statement.** For monotone functions f : B^m → {0,1} and g : B^n → {0,1}, define (f ⊗ g)(x,y) = f(x) ∧ g(y). Then:
$$\max_{(x_1,y_1) \leq (x_2,y_2)} \Delta_{f \otimes g}((x_1,y_1), (x_2,y_2)) = \max_{x_1 \leq x_2} \Delta_f(x_1, x_2) + \max_{y_1 \leq y_2} \Delta_g(y_1, y_2)$$

**Test.** Compute entropy drops for products of small threshold/OR functions and verify the additive formula.

**Disconfirmation criterion.** Find any f, g where the product entropy drop is strictly less than the sum of individual max drops.

**Impact.** Additivity would make entropy lower bounds compose tensorially, which is a crucial property for scaling to large problems. This is analogous to the direct-sum property in communication complexity.

---

## Conjecture 5: Entropy Chains Realize Saturated Chains

**Statement.** For every monotone f and every pair x ≤ y achieving the maximum entropy drop, there exists a saturated chain (path of cover relations) from x to y such that every step contributes a positive entropy drop, and the sum equals the total drop. Moreover, the optimal chain visits points in order of decreasing semantic entropy.

**Test.** For all monotone functions on n = 4, 5 bits, find the optimal drop pair and check that every greedy saturated chain (choosing the highest-drop next step) achieves the full drop.

**Disconfirmation criterion.** Find a monotone function where the greedy chain achieves strictly less than the maximum drop, forcing a non-greedy chain decomposition.

**Impact.** Would establish that the entropy landscape has no "dead ends" — the optimal drop can always be realized step by step. This would simplify the connection to communication protocols, where each round corresponds to one step in the chain.
