# Future Directions: Tropical Mixing Theory

## Synthesis

The theorems established in this work — direct geometric mixing bounds from tropical congestion and diameter, the Lorentzian diameter bound, and the toric model bridge — create a new interface between polyhedral geometry and Markov chain theory. The five directions below extend this interface along complementary axes: deepening the geometric theory (Directions 1–2), broadening to new combinatorial domains (Direction 3), and bridging to statistical physics and algebraic statistics (Directions 4–5). Together, they outline a program to make tropical geometry a standard tool in the analysis of random processes, comparable in power and generality to spectral methods.

---

## Direction 1: Tropical Ricci Curvature and Entropic Contraction

**Conjecture:** There exists a notion of *tropical Ricci curvature* on the state graph of a Lorentzian polynomial chain — defined in terms of the Newton subdivision — such that positive tropical Ricci curvature implies contraction in transportation distance, and hence a mixing bound independent of the canonical path method.

**Test:** For grid graphs modeling Lorentzian subdivisions of degree $d$ in $n$ variables:
1. Compute the Ollivier-Ricci curvature on each edge of the state graph.
2. Compute a "tropical curvature" derived from the local geometry of the Newton subdivision (e.g., the number of adjacent cells, the solid angle at each vertex).
3. Test whether tropical curvature ≥ c · Ollivier-Ricci curvature for a universal constant c > 0.
4. If so, this provides a second, independent geometric route to mixing bounds.

**Impact:** A tropical Ricci curvature theory would give mixing bounds from *local* geometric data (curvature at each vertex) rather than *global* data (congestion across all paths). This is analogous to the difference between Ricci curvature and isoperimetric constants in Riemannian geometry. It would dramatically simplify mixing analysis for high-dimensional chains.

**Catalog References:** Builds on `tropical_path_length_le_dn` (Theorem B) and `mixing_time_le_of_tropical_congestion` (Theorem A) from `Pythagorean/TropicalMixingTheorems.lean`.

**Proof Strategy:** Define tropical curvature as a discrete Laplacian of the tropical potential function (the piecewise-linear function whose graph is the tropical hypersurface). Use the Lorentzian signature condition to show this Laplacian has a sign, implying contraction. Connect to Ollivier's framework via Wasserstein distance.

**Domain Bridges:** Riemannian geometry (Ricci curvature), optimal transport (Wasserstein distance), information geometry (Fisher-Rao metric on distributions).

**Lineage:** Extends the spectral-gap-free approach of this paper to a curvature-based approach, inspired by Ollivier (2009) and the Erbar-Maas gradient flow framework.

**Ambition:** Grand challenge — would unify tropical geometry and optimal transport theory.

---

## Direction 2: Proving the Linear Tropical-Mixing Conjecture

**Conjecture:** For Lorentzian polynomial chains, the tropical congestion $\Gamma$ is bounded by $C \cdot D$ where $D$ is the tropical diameter and $C$ is a universal constant. Formally:

$$\exists C > 0 : \forall \text{ Lorentzian } f, \quad \Gamma(P_f) \leq C \cdot D(P_f)$$

**Test:**
1. For random Lorentzian polynomials of degrees 3–10 in 3–15 variables, compute $\Gamma/D$.
2. If the ratio stays bounded, the conjecture is supported.
3. If a family with superlinear growth $\Gamma \sim D^{1+\epsilon}$ is found, the conjecture fails.
4. Check whether the ratio depends on degree, number of variables, or both.

**Impact:** If true, this would strengthen the quadratic mixing bound (Theorem C) to a *linear* bound: $\tau_{\text{mix}} \leq C' \cdot dn \cdot \log(1/\pi_{\min})$. This would match the best known bounds for many log-concave chains, obtained by much more complex spectral methods.

**Catalog References:** `TropicalLinearMixingConjecture` in `Pythagorean/TropicalMixingTheorems.lean`, `lorentzian_mixing_time_le_direct_tropical` (Theorem C).

**Proof Strategy:** Use the Lorentzian exchange property: for Lorentzian polynomials, the Hessian restricted to the positive cone has Lorentzian signature. This forces a "spreading" property on the tropical subdivision that should prevent congestion concentration. Alternatively, use a discrete Brunn-Minkowski inequality for mixed volumes of Newton polytopes.

**Domain Bridges:** Convex geometry (Brunn-Minkowski), matroid theory (exchange axiom), algebraic geometry (mixed volumes).

**Lineage:** Direct extension of Theorems A–C; would close the gap between the geometric bound and the conjectured optimal rate.

**Ambition:** Solid extension — requires a single new inequality, but the inequality is deep.

---

## Direction 3: Tropical Mixing for Matroid Base Exchange Chains

**Conjecture:** For the base exchange walk on a matroid $M$ of rank $r$ on $n$ elements, the tropical path system induced by the matroid polytope subdivision has diameter at most $r(n-r)$ and congestion at most $O(r \cdot n)$, yielding a mixing bound of $O(r^2 n^2 \log(1/\pi_{\min}))$ from geometry alone.

**Test:**
1. For uniform matroids $U_{r,n}$ with $r \in \{2,3,4\}$ and $n \in \{4, \ldots, 10\}$, construct the base exchange graph.
2. Build the tropical path system from the matroid polytope.
3. Compute diameter and congestion.
4. Compare against the known spectral gap bound (Anari–Liu–Oveis Gharan–Vinzant 2019).

**Impact:** Would give the first purely geometric proof of rapid mixing for matroid base exchange chains, removing the dependence on the deep spectral analysis of ALOV. This is a major open problem in combinatorial probability.

**Catalog References:** `IsLorentzianSubdivision` and `tropical_path_length_le_dn` from `Pythagorean/TropicalMixingDefs.lean` and `Pythagorean/TropicalMixingTheorems.lean`.

**Proof Strategy:** The generating polynomial of matroid bases is Lorentzian (Brändén-Huh). Its Newton polytope is the matroid polytope. The exchange walk corresponds to edge adjacency. Route canonical paths along the 1-skeleton using the matroid exchange axiom to bound path length, and use the Lorentzian property to control congestion.

**Domain Bridges:** Matroid theory, combinatorial optimization (matroid intersection), theoretical computer science (approximate counting).

**Lineage:** Applies the tropical mixing framework to the most important class of Lorentzian polynomials.

**Ambition:** Grand challenge — would resolve a major open problem in combinatorial probability.

---

## Direction 4: Polyhedral Metastability in Statistical Mechanics

**Conjecture:** For the Ising model on a graph $G$ at inverse temperature $\beta$, the tropical subdivision of the partition function polynomial exhibits a *phase transition* in its structure: below the critical temperature, the subdivision develops exponentially long "corridors" (sequences of cells with no shortcuts), causing the tropical diameter to diverge and the mixing bound to reflect metastability.

**Test:**
1. For the Ising model on complete graphs $K_n$ and lattices $\mathbb{Z}^d_L$, compute the Newton subdivision of the partition function at various temperatures.
2. Track the tropical diameter as $\beta$ crosses the critical value.
3. Compare the tropical mixing bound against known mixing times (polynomial above $\beta_c$, exponential below).
4. Check whether the subdivision topology changes at $\beta_c$.

**Impact:** Would provide a geometric explanation for metastability — one of the deepest phenomena in statistical physics — in terms of the shape of the Newton subdivision. The tropical diameter would serve as an order parameter for phase transitions.

**Catalog References:** `tropicalDiameterBound` from `Pythagorean/TropicalMixingDefs.lean`, `canonicalPathMixingBound` and `mixing_time_le_of_tropical_congestion` from `Pythagorean/TropicalMixingTheorems.lean`.

**Proof Strategy:** At high temperature ($\beta$ small), the partition function has a simple Newton polytope with small diameter. At low temperature, the polytope becomes more complex, and the subdivision develops elongated cells corresponding to metastable states. Use the tropical mixing bound to translate subdivision complexity into mixing time.

**Domain Bridges:** Statistical physics (Ising model, phase transitions), dynamical systems (metastability), condensed matter physics.

**Lineage:** Extends the tropical mixing framework from polynomial-time algorithms to understanding fundamental physical phenomena.

**Ambition:** Grand challenge — would bridge tropical geometry to statistical physics.

---

## Direction 5: Newton-Polytope Certificates for Algebraic Statistics

**Conjecture:** For toric models arising in algebraic statistics (log-linear models, contingency tables), the tropical mixing certificate can be computed efficiently from the toric ideal generators, without explicitly constructing the fiber or the Markov chain.

**Test:**
1. For $r \times c$ contingency tables with fixed margins, compute the Graver basis of the toric ideal.
2. From the Graver basis, construct the Newton polytope and its tropical subdivision.
3. Compute the tropical mixing certificate.
4. Compare against the best known mixing bounds for the Diaconis-Sturmfels walk.
5. Test for table sizes up to $5 \times 5$ with various margin constraints.

**Impact:** Would make tropical mixing certificates practical for algebraic statistics, where rapid mixing of fiber walks is essential for goodness-of-fit testing, Bayesian inference, and disclosure limitation. Currently, mixing bounds for these chains are extremely difficult to obtain.

**Catalog References:** `ToricModel` and `toric_model_mixing_certificate` from `Pythagorean/TropicalMixingDefs.lean` and `Pythagorean/TropicalMixingTheorems.lean`.

**Proof Strategy:** Use the fact that Graver basis elements correspond to edges of the fiber polytope. The tropical subdivision of the toric ideal's A-polynomial encodes the combinatorial structure of the fiber. Route canonical paths along the 1-skeleton of the fiber polytope and bound congestion using mixed-volume estimates.

**Domain Bridges:** Algebraic statistics, computational algebra (Gröbner and Graver bases), statistical testing (Fisher exact test, log-linear models).

**Lineage:** Direct application of the toric model bridge theorem to the most important class of toric Markov chains.

**Ambition:** Solid extension — builds directly on established algebra and the toric bridge theorem.
