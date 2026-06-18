# Future Directions: Subgroup Pressure Theory for Finite Groups

## Synthesis

The O'Nan–Scott logarithmic pressure bound establishes a new paradigm: **classification theorems from finite group theory can be systematically converted into analytic pressure laws**. The certificate framework — polynomial class count plus power-law index growth implies bounded pressure — is completely general and applies far beyond wreath products. The five directions below extend this paradigm along complementary axes: sharpening the bounds (Direction 1), generalizing the groups (Direction 2), connecting to analytic number theory (Direction 3), building computational tools (Direction 4), and reframing the entire theory in the language of statistical mechanics (Direction 5). Together, they define a research program that bridges finite group theory, analytic combinatorics, algorithmic complexity, and mathematical physics.

---

## Direction 1: Sharp Asymptotic Constants for Non-Coordinate Pressure

**Conjecture:** For each fixed $k \geq 5$, the non-coordinate pressure of $W_{k,m} = S_k \wr S_m$ satisfies
$$P_{\text{noncoord}}(W_{k,m}) = c_k \cdot \frac{\log m}{m} + O(m^{-2})$$
where $c_k$ is an explicitly computable constant depending on the structure of maximal subgroups of $S_k$.

**Test:** Compute $P_{\text{noncoord}}(W_{k,m})$ exactly using GAP for $k = 5, 6, 7$ and $m \leq 50$. Fit the sequence $m \cdot P_{\text{noncoord}}(W_{k,m})$ to $c_k \log m + d_k$. If the fit residuals exceed $O(m^{-1})$, the conjecture fails.

**Impact:** This would upgrade the logarithmic bound to an exact asymptotic formula, providing the first rigorous asymptotic expansion of maximal subgroup pressure for any infinite family of groups. It would also yield explicit error bounds for generation probability estimates.

**Catalog References:** `Pythagorean/WreathONanScott.lean` (certified_pressure_bounded), `Pythagorean/WreathPhaseTransition.lean` (noncoord_pressure_log_bound)

**Proof Strategy:** Refine the conservative certificates ($C = k!$, $d = 2$, $\alpha = 3$) with type-specific bounds. For the top-group-induced type, use the exact classification of maximal subgroups of $S_m$ to get $d = 1$ (linear class count). For the diagonal type, use subdirect product rigidity to show $\alpha \geq m$ (exponential index growth). Sum the refined contributions.

**Domain Bridges:** Analytic number theory (Dirichlet series asymptotics), enumerative combinatorics (partition function asymptotics)

**Lineage:** Extends `certified_pressure_bounded` and `certifiedNoncoordUpperBound_bounded`

**Ambition:** Grand challenge — requires exact enumeration data and new asymptotic methods

---

## Direction 2: Pressure Universality for General Wreath Products $G \wr H$

**Conjecture:** For any finite group $G$ with $|G| \geq 60$ (i.e., $G$ has a nonabelian composition factor) and any transitive group $H \leq S_m$, the non-coordinate pressure of $G \wr H$ is $O(\log m)$, with constants depending only on $G$.

**The key insight is** that the O'Nan–Scott classification applies to primitive groups of product-action type regardless of whether the base group is symmetric. The certificate framework requires only polynomial class count and superlinear index growth, both of which follow from the structure of wreath products over any sufficiently complex base.

**Why now?** The certificate framework from `WreathONanScott.lean` is already formulated for arbitrary `PressureCertificate` structures, independent of the specific group. Extending to $G \wr H$ requires only constructing certificates for the appropriate O'Nan–Scott types, which the existing classification literature supports.

**Test:** For $G = A_5$ (the smallest nonabelian simple group) and $H = S_m$, compute $P_{\text{noncoord}}(G \wr H)$ for $m \leq 30$ and verify the logarithmic bound.

**Impact:** Would establish a universal subgroup pressure law for wreath products, covering the most important building blocks in the structure theory of finite groups.

**Catalog References:** `Pythagorean/WreathONanScott.lean` (PressureCertificate, certifiedNoncoordUpperBound), `Pythagorean/WreathPerturbation.lean` (ImprimitivePerturbation)

**Proof Strategy:** Classify non-coordinate maximal subgroups of $G \wr H$ using Kovács' theorem for wreath products with arbitrary base. For each O'Nan–Scott type, construct a certificate using |Aut(G)|, the number of maximal subgroups of $G$, and the minimal index of proper subgroups of $G$.

**Domain Bridges:** Finite group theory (CFSG applications), representation theory (Clifford theory for wreath products)

**Lineage:** Generalizes the main pipeline from symmetric to arbitrary base groups

**Ambition:** Solid extension — the mathematical infrastructure exists, requires careful case analysis

---

## Direction 3: Subgroup Zeta Functions and Analytic Continuation

**Conjecture:** For each fixed $k \geq 5$, the non-coordinate subgroup zeta function
$$\zeta^{\text{noncoord}}_{k}(s) = \sum_{m=1}^{\infty} P_{\text{noncoord}}(W_{k,m}) \cdot m^{-s}$$
has an analytic continuation to $\text{Re}(s) > -1$ with a simple pole at $s = 0$ of residue $c_k$.

**The key insight is** that the pressure certificates give pointwise bounds $P_{\text{noncoord}}(W_{k,m}) \leq K/m$, so $\zeta^{\text{noncoord}}_k(s)$ is bounded term-by-term by $K \cdot \zeta(s+1)$, which converges for $\text{Re}(s) > 0$. The analytic continuation question asks whether this bound is essentially sharp.

**Why now?** The certified bound $P_{\text{noncoord}} = O(1/m)$ provides the first rigorous convergence result for any subgroup zeta function of a non-trivially varying family. This opens the door to Tauberian methods connecting the zeta function's analytic properties to asymptotic subgroup counts.

**Test:** Compute partial sums of $\zeta^{\text{noncoord}}_5(s)$ for $s = 0.5, 1.0, 1.5, 2.0$ using GAP data for $m \leq 50$. Check whether the partial sums converge and whether Richardson extrapolation suggests a pole at $s = 0$.

**Impact:** Would create a bridge between finite group theory and analytic number theory, potentially connecting subgroup growth to L-function theory.

**Catalog References:** `Pythagorean/WreathONanScott.lean` (subgroupZeta, certified_pressure_bounded)

**Proof Strategy:** Use the Mellin transform of the pressure function and asymptotic estimates from Direction 1 to establish meromorphic continuation via contour shifting.

**Domain Bridges:** Analytic number theory (Dirichlet series, Tauberian theorems), complex analysis (meromorphic continuation)

**Lineage:** Builds on the Dirichlet-series viewpoint introduced in WreathONanScott.lean

**Ambition:** Grand challenge — connecting group theory to analytic number theory in a novel way

---

## Direction 4: Certified Generation Algorithms with Quantified Error

**Conjecture:** There exists a polynomial-time algorithm that, given $k \geq 5$ and $m \geq 1$, computes a rational number $\hat{P}$ such that
$$P(W_{k,m}) \leq \hat{P} \leq P(W_{k,m}) + \frac{C_k}{m}$$
where $C_k$ depends only on $k$.

**The key insight is** that the coordinate pressure $m \cdot P(S_k)$ is exactly computable (given the known classification of maximal subgroups of $S_k$), and the non-coordinate pressure is bounded by $5k!/m$. The certified upper bound $\hat{P} = m \cdot P(S_k) + 5k!/m$ is therefore computable in O(1) time and has error at most $5k!/m - P_{\text{noncoord}} \leq 5k!/m$.

**Why now?** The `certifiedNoncoordBound` function in WreathONanScott.lean already provides the mathematical foundation. What remains is to formalize the exact computation of $P(S_k)$ for small $k$ and package the result as a verified algorithm.

**Test:** Implement the algorithm and compare its output to exact computations via GAP for $k = 5, m \leq 20$. The error should decrease as $1/m$.

**Impact:** Would provide the first polynomial-time certified estimator for maximal subgroup pressure, enabling practical applications in random generation and cryptographic group selection.

**Catalog References:** `Pythagorean/WreathONanScott.lean` (certifiedNoncoordBound, certifiedNoncoordBound_uniform), `Pythagorean/WreathPhaseTransition.lean` (VerifiedPressureEstimate)

**Proof Strategy:** Formalize $P(S_k)$ as a computable rational number for $k \leq 10$ using the known maximal subgroup indices. Combine with the certified non-coordinate bound.

**Domain Bridges:** Algorithmic complexity (certified algorithms), computational group theory (maximal subgroup enumeration)

**Lineage:** Direct application of the certified bound framework

**Ambition:** Solid extension — mainly engineering, but with significant practical value

---

## Direction 5: Thermodynamic Limit and Phase Diagram for Subgroup Spectra

**Conjecture:** The sequence of pressure functions $P(W_{k,m})/m$ converges as $m \to \infty$ to a "free energy density" $f(k) = P(S_k)$, and the convergence is exponentially fast in $m$:
$$\left|\frac{P(W_{k,m})}{m} - P(S_k)\right| \leq \frac{C_k}{m}$$

Moreover, there exists a "phase diagram" in the $(k, s)$-plane (where $s$ parametrizes the subgroup zeta function) with critical curves separating regions of convergent/divergent pressure sums.

**The key insight is** that the wreath product structure mirrors that of a classical statistical-mechanical lattice model: the $m$ coordinate copies play the role of lattice sites, coordinate defects are "bulk excitations," and non-coordinate defects are "boundary/interaction corrections." The $O(1/m)$ bound on non-coordinate pressure is the group-theoretic analogue of surface-to-volume corrections in thermodynamics.

**Why now?** The formal proof that $P_{\text{noncoord}} = o(m)$ (via `ONanScott_implies_subcritical`) establishes for the first time that the "thermodynamic limit" exists: the pressure per site converges. This opens the door to defining temperature, entropy, and free energy for subgroup spectra.

**Test:** Plot $P(W_{k,m})/m$ versus $m$ for $k = 5, 6, 7$ to confirm convergence. Compute the "specific heat" $\partial^2_s \log \zeta(s)$ at $s = 1$ for small $k$ and $m$ to check for divergence (indicating a phase transition).

**Impact:** Would establish a new field of "subgroup thermodynamics" connecting finite group theory to statistical mechanics, with potential applications to random matrix theory, quantum information, and the study of symmetry breaking.

**Catalog References:** `Pythagorean/WreathPhaseTransition.lean` (partitionFunctionFromPressure, subgroupEnergy), `Pythagorean/WreathONanScott.lean` (complete_ONanScott_pipeline)

**Proof Strategy:** Formalize the thermodynamic limit as a Filter.Tendsto statement using the existing subcriticality results. The phase diagram requires extending the subgroup zeta function to complex $s$ and identifying critical curves via singularity analysis.

**Domain Bridges:** Statistical mechanics (thermodynamic limits, phase transitions), random matrix theory (universal distribution laws), quantum information (symmetry-protected topological phases)

**Lineage:** Culmination of the wreath product pressure program, synthesizing all prior results

**Ambition:** Grand challenge — paradigm-shifting connection between group theory and physics
