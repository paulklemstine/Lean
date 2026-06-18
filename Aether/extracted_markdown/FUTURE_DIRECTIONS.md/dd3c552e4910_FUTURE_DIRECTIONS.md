# Future Directions: Shadow Decay Profiles and Circuit Lower Bounds

## Synthesis

The shadow decay profile framework established in this work opens a new corridor between algebraic complexity theory, extremal combinatorics, and discrete convex geometry. The proven theorems — Newton polytope contraction, exact elementary symmetric shadow formulas, subadditivity, and simplex counting — form the foundation of a circuit lower bound program based on support geometry. The key bridge is the exact derivative–shadow correspondence (from `Pythagorean/IteratedShadowGeometry.lean`): derivative complexity *is* shadow complexity, so any combinatorial constraint on shadows translates directly to algebraic constraints on circuits. The directions below extend this bridge in five specific ways, each testable with current tools and each potentially transformative.

---

## Direction 1: Kruskal–Katona Optimal Shadow Bounds for Circuit Supports

**Conjecture:** For any polynomial $f$ of degree $d$ in $n$ variables computed by an algebraic circuit of size $s$, the support $\mathrm{supp}(f)$ satisfies the Kruskal–Katona inequality: there exists an initial segment $\mathcal{I}$ of the colex order on $\mathbb{N}^n$ with $|\mathcal{I}| = |\mathrm{supp}(f)|$ such that $|\mathrm{Sh}_1(\mathrm{supp}(f))| \geq |\mathrm{Sh}_1(\mathcal{I})|$. Moreover, for circuit-generated supports, the gap between $|\mathrm{Sh}_1(\mathrm{supp}(f))|$ and the Kruskal–Katona minimum is at most polynomial in $s$.

**Test:** Compute $|\mathrm{Sh}_1|$ for permanent supports of sizes $m = 3, 4, 5$ and compare with the Kruskal–Katona lower bound for families of size $m!$. If permanent supports exceed the KK minimum by a superpolynomial factor in $m$, this provides evidence for a new lower bound route.

**Impact:** This would give the first circuit lower bound method that exploits extremal set theory directly. The Kruskal–Katona theorem is one of the deepest results in extremal combinatorics, and connecting it to circuit complexity would open an entirely new proof technique.

**Catalog References:**
- `Pythagorean/CircuitLowerBounds/ShadowDecay.lean`: `kthShadow_elemSymm_eq`, `shadowProfile_elemSymm`
- `Pythagorean/IteratedShadowGeometry.lean`: `mem_kthShadow_iff_exists_iteratedDerivative`

**Proof Strategy:** Formalize the Kruskal–Katona theorem for integer multi-index shadows (extending from the classical set-family version). Then prove that circuit operations preserve the KK-gap invariant under addition (subadditivity) and bound the gap under multiplication (Minkowski sum analysis).

**Domain Bridges:** Extremal combinatorics → algebraic complexity → discrete optimization (LP relaxations of shadow bounds).

**Lineage:** Builds directly on `shadowProfile_elemSymm` and `shadowProfile_union_le`.

**Ambition:** *Grand challenge.* A successful Kruskal–Katona circuit barrier would be the first genuine lower bound from extremal set theory, potentially complementing all existing methods.

**The key insight is** that the Kruskal–Katona theorem provides *optimal* lower bounds on shadow sizes, and circuit-computable supports may be provably far from the optimizers (initial segments), creating an exploitable gap.

**Why now?** The exact shadow theorem for elementary symmetric supports (`kthShadow_elemSymm_eq`) shows that the shadow framework correctly interfaces with uniform set families. The natural next step is to import the full power of extremal set theory.

---

## Direction 2: Shadow Entropy and Information-Theoretic Circuit Barriers

**Conjecture:** Define the **shadow entropy** $H_S(k) = \log_2 |\mathrm{Sh}_k(S)| - \log_2 \binom{n+d-k}{n}$. For polynomials computed by circuits of size $s$, $H_S(k) \leq \log_2 s$ for all $k \leq d$. Moreover, the shadow entropy satisfies a **data processing inequality**: for any circuit gate $g$ combining inputs $f_1, f_2$, $H_{\mathrm{supp}(g)}(k) \leq H_{\mathrm{supp}(f_1)}(k) + H_{\mathrm{supp}(f_2)}(k) + O(\log n)$.

**Test:** Compute $H_S(k)$ for permanent supports at $m = 3, 4, 5$ and verify that $H$ grows with $m$ at each fixed $k > 0$. Compare growth rate with $\log_2(m!)$ (the logarithm of the support size).

**Impact:** If shadow entropy obeys a data processing inequality, it would provide a clean, information-theoretic lower bound method entirely orthogonal to rank-based approaches.

**Catalog References:**
- `Pythagorean/CircuitLowerBounds/ShadowDecay.lean`: `shadowProfile_le_simplexLatticeCount`, `shadowProfile_union_le`
- `Bridges/Catalog/Pythagorean/SupportCompression.lean`: `supportCompressedLeafCount_le_active_choose`

**Proof Strategy:** Prove the data processing inequality by structural induction on circuit gates. Addition gates use subadditivity. Multiplication gates require bounding the shadow of a Minkowski sum, which may use log-concavity of binomial coefficients.

**Domain Bridges:** Information theory → algebraic complexity → statistical physics (entropy of accessible states under energy constraints ↔ shadow profiles under degree constraints).

**Lineage:** Extends `shadowProfile_union_le` (subadditivity) to a multiplicative/entropic setting.

**Ambition:** *Grand challenge.* An entropic circuit barrier would be a fundamentally new proof technique in complexity theory, connecting to the broader theme of information-theoretic lower bounds.

**The key insight is** that the normalized shadow decay $\delta(k) = |\mathrm{Sh}_k|/\binom{n+d-k}{n}$ behaves like a probability distribution over degree strata, and circuit operations act as noisy channels that can only decrease entropy.

**Why now?** The proven simplex bound (`shadowProfile_le_simplexLatticeCount`) provides the normalization needed to define shadow entropy, and subadditivity (`shadowProfile_union_le`) is the first step toward a data processing inequality.

---

## Direction 3: Multiplication Gate Analysis via Minkowski Sum Shadows

**Conjecture:** For supports $A, B \subseteq \mathbb{N}^n$, let $A + B = \{a + b : a \in A, b \in B\}$ (the Minkowski sum, corresponding to polynomial multiplication). Then $|\mathrm{Sh}_k(A + B)| \leq \sum_{j=0}^{k} |\mathrm{Sh}_j(A)| \cdot |\mathrm{Sh}_{k-j}(B)|$. This "convolution bound" would control multiplication gates in circuits.

**Test:** Compute $|\mathrm{Sh}_k(A + B)|$ for pairs of elementary symmetric supports and verify the convolution bound. Specifically, test $A = \mathrm{supp}(e_2)$, $B = \mathrm{supp}(e_3)$ in $n = 6$ variables.

**Impact:** This would complete the circuit decomposition framework: addition is handled by subadditivity, multiplication by the convolution bound, and the circuit size enters through iterated application of both.

**Catalog References:**
- `Pythagorean/CircuitLowerBounds/ShadowDecay.lean`: `shadowProfile_union_le`, `kthShadow_subset_degreeSimplex`
- `Pythagorean/IteratedShadowGeometry.lean`: `kthShadow_add` (semigroup law)

**Proof Strategy:** Prove that if $\gamma = \alpha + \beta$ with $\alpha \in A, \beta \in B$, then any shadow element of $\gamma$ decomposes as the sum of a shadow element of $\alpha$ and a shadow element of $\beta$. This follows from the additive structure of the shadow operation combined with a careful accounting of how degree drops distribute across the sum.

**Domain Bridges:** Additive combinatorics (sumset theory) → algebraic complexity → convex geometry (Minkowski sum volumes).

**Lineage:** Directly extends the semigroup law `kthShadow_add` from `IteratedShadowGeometry.lean`.

**Ambition:** *Solid extension.* This is the critical missing piece for applying the shadow framework to general circuits, not just additive ones.

**The key insight is** that the semigroup law for shadows ($\mathrm{Sh}_b(\mathrm{Sh}_a(S)) = \mathrm{Sh}_{a+b}(S)$) composes vertically, while the Minkowski sum $A + B$ composes horizontally. The convolution bound would connect both.

**Why now?** The proven semigroup law and subadditivity provide the infrastructure. The convolution bound is the natural next theorem to prove, and it is checkable computationally before attempting formal proof.

---

## Direction 4: Tropical Shadow Decay and Optimization Barriers

**Conjecture:** In the tropical semiring $(\mathbb{R} \cup \{+\infty\}, \min, +)$, define the **tropical shadow** of a support set $S$ as the set of points reachable by tropical differentiation (subtracting unit vectors and taking minimum over surviving terms). Then the tropical shadow profile $\sigma^{\mathrm{trop}}_S(k)$ provides lower bounds on the tropical circuit complexity of the corresponding tropical polynomial. Moreover, for polytope-supported polynomials, the tropical shadow profile is determined by the normal fan of the Newton polytope.

**Test:** Compute tropical shadow profiles for the Newton polytopes of permanent and determinant. Compare the tropical and classical shadow profiles for elementary symmetric polynomials (they should agree since the support is 0-1).

**Impact:** Tropical geometry provides a bridge between algebraic complexity and combinatorial optimization. A tropical shadow barrier could yield lower bounds on the complexity of optimization problems via algebraic detours.

**Catalog References:**
- `Pythagorean/CircuitLowerBounds/ShadowDecay.lean`: `kthShadow_subset_degreeSimplex`
- `Pythagorean/IteratedShadowGeometry.lean`: `iteratedPDeriv`, `mem_kthShadow_iff_exists_iteratedDerivative`

**Proof Strategy:** Formalize tropical differentiation as a min-plus operation on supports. Show that the classical shadow is a refinement of the tropical shadow (every classical shadow element is a tropical shadow element). Then prove that tropical circuit operations (min and +) constrain tropical shadow profiles analogously to classical circuits.

**Domain Bridges:** Tropical geometry → optimization → algebraic complexity → convex analysis (support functions of polytopes).

**Lineage:** Extends the Newton polytope contraction theorem (`kthShadow_subset_degreeSimplex`) to the tropical setting.

**Ambition:** *Solid extension with speculative upside.* The tropical connection is well-motivated by existing work in tropical algebraic geometry but has not been explored in the circuit complexity context.

**The key insight is** that tropical polynomials correspond to piecewise-linear functions, and their "shadows" correspond to face structures of Newton polytopes. Circuit operations in the tropical world (min/max composition) have rigid polytope-theoretic consequences.

**Why now?** The Lean formalization of Newton polytope contraction provides a verified foundation. The tropical extension requires only replacing the arithmetic semiring with the tropical semiring, and many of the same combinatorial arguments carry over.

---

## Direction 5: Permanent Support Separation via Shadow Expansion

**Conjecture:** For the $m \times m$ permanent, the shadow expansion ratio $|\mathrm{Sh}_1(\mathrm{supp}(\mathrm{perm}_m))| / |\mathrm{supp}(\mathrm{perm}_m)| = m$ grows linearly with $m$. For any polynomial of degree $m$ in $m^2$ variables computed by a circuit of size $\mathrm{poly}(m)$, the shadow expansion ratio is $O(\sqrt{m})$. This would give a separation proving $\Omega(m^2)$ lower bounds on circuit size for the permanent.

**Test:** Verify the expansion ratio $|\mathrm{Sh}_1|/|S| = m$ for $m = 2, 3, 4, 5$ computationally. For the circuit upper bound, construct explicit small circuits for easy polynomials (e.g., power sums) and verify that their shadow expansion ratio is $O(\sqrt{m})$.

**Impact:** Even a quadratic lower bound on permanent circuit size would be a significant advance, and the shadow expansion approach provides a clean, checkable path.

**Catalog References:**
- `Pythagorean/CircuitLowerBounds/ShadowDecay.lean`: `shadowProfile_union_le`, `kthShadow_subset_degreeSimplex`
- `Bridges/Catalog/Pythagorean/SupportCompression.lean`: `supportCompressedLeafCount_le_active_choose`

**Proof Strategy:** (1) Prove that $|\mathrm{Sh}_1(\mathrm{supp}(\mathrm{perm}_m))| = m \cdot m!$ exactly (each permutation matrix generates $m$ distinct shadow elements by deleting one entry, and all are distinct). (2) Prove that support-compressed circuits of size $s$ have shadow expansion ratio $\leq s$ using the leaf count bound from `SupportCompression.lean`. (3) Combine to get $m \leq s$, giving a linear lower bound.

**Domain Bridges:** Algebraic complexity → permutation combinatorics → representation theory (permanent as a character sum).

**Lineage:** Builds on the computational observation that permanent shadow expansion ratio equals $m$, connecting to `supportCompressedLeafCount_le_active_choose`.

**Ambition:** *Solid extension.* A linear lower bound is modest but rigorously achievable with current infrastructure, and the method could potentially be sharpened to superlinear bounds.

**The key insight is** that permanent supports have maximal shadow expansion among multilinear degree-$m$ supports (each permutation contributes $m$ new shadow elements, and they don't cancel), while circuit-generated supports have bounded expansion.

**Why now?** The subadditivity theorem and support compression bound provide the two halves of the argument. The missing piece is the exact permanent shadow computation, which is a concrete, verifiable combinatorial claim.
