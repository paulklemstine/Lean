# Future Directions: Transseries and Asymptotic Growth Hierarchies

## Synthesis

This cycle established the foundational algebraic framework for transseries theory: growth levels with depth filtration, the exp-log shift involution, and the asymptotic separation hierarchy (log ≪ polynomial ≪ exponential ≪ double-exponential). The key structural insight is that depth — the number of iterated exponentiations — provides a natural grading on the space of transmonomials that is compatible with both algebraic operations and asymptotic analysis.

The most promising cross-domain connection is between the depth filtration and the EML (exp-minus-log) algebra already present in the catalog. The EML operation `eml(a,b) = exp(a) - log(b)` naturally bridges between depth levels 1 and -1, and the catalog's `eml_chain_exp_log_cancel` theorem is precisely the shift involution at the analytic level. Future work should exploit this connection to build a differential algebra on transseries using EML as the primitive operation.

The highest breakthrough potential lies in Direction 1 (Transmonomial Independence), because it would establish that the transseries representation is a faithful invariant — not just a convenient notation but a complete description. This would be the analogue of the fundamental theorem of algebra for asymptotic expansions. Direction 3 (Tropical Valuation) has the highest novelty potential, connecting transseries to the tropical geometry already formalized in the catalog.

---

### Direction 1: Transmonomial Linear Independence Over ℝ

**Conjecture**: For any finite set of pairwise distinct growth levels {g₁, ..., gₖ}, the transmonomials m_{g₁}, ..., m_{gₖ} are linearly independent as functions from ℝ to ℝ on any interval [a, ∞). That is, if Σᵢ cᵢ · m_{gᵢ}(x) = 0 for all x ≥ a, then all cᵢ = 0.

**Test**: Verify computationally for specific triples of growth levels, e.g., {(−1,1), (0,1), (1,1)} corresponding to {log(x), x, exp(x)}. Check that the Wronskian determinant is nonzero for large x.

**Impact**: If true, this establishes that the transseries representation is an isomorphism — every function has at most one transseries expansion. This is the asymptotic analogue of the uniqueness of Taylor coefficients and would justify the entire transseries framework as a faithful invariant. If false, it would reveal unexpected algebraic relations between transmonomials at different depths.

**Catalog References**: `Applications/TransseriesTheorems.lean` (exponential dominance, three-level hierarchy), `EML/EMLv17Core.lean` (eml definition)

**Proof Strategy**: For distinct-depth transmonomials, use the dominance hierarchy: if gₖ has the highest depth, then dividing the linear relation by m_{gₖ}(x) makes all other terms vanish as x → ∞, forcing cₖ = 0. Repeat by induction. For same-depth transmonomials with different exponents (e.g., x^α and x^β), use the asymptotic behavior of x^(α−β) to separate them.

**Domain Bridges**: Transseries <-> Linear Algebra (Wronskian theory), Transseries <-> Model Theory (o-minimality of exp-log structures)

**Lineage**: Builds on `exp_dominates_pow`, `rpow_dominates_log_pow`, and `single_ratio_converges` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Differential Algebra of Transseries via EML

**Conjecture**: There exists a derivation D on the Graded Transseries Algebra such that: (a) D is depth-preserving (the derivative of a depth-d term has depth ≤ d), (b) D satisfies the Leibniz rule for products, and (c) exp(x) is an eigenvector of D with eigenvalue 1.

**Test**: Define D on single-term transseries (D(c · x^α) = cα · x^(α−1), D(c · exp(αx)) = cα · exp(αx)) and verify that the Leibniz rule holds for products of transmonomials. Check that the depth bound holds for mixed-depth products.

**Impact**: If true, this would make transseries into a differential field, enabling the study of asymptotic solutions to differential equations. The depth-preservation property would mean that differentiation respects the filtration — a strong structural constraint that mirrors the analytic fact that the derivative of exp(x) is still exp(x), not something of higher depth. This connects directly to Écalle's theory of resurgent functions.

**Catalog References**: `Applications/TransseriesDefs.lean` (GrowthLevel, depth filtration), `EML/EMLv17Core.lean` (eml as exp-log bridge), `EML/KolmogorovArnoldEMLDeep.lean` (eml_chain_exp_log_cancel)

**Proof Strategy**: Define D on transmonomials using the standard derivatives, extend linearly. The key lemma is that for depth-d transmonomials, differentiation either preserves or lowers the depth. For depth 0: d/dx(x^α) = αx^(α−1), still depth 0. For depth 1: d/dx(exp(αx)) = α·exp(αx), still depth 1. The product rule introduces lower-depth correction terms.

**Domain Bridges**: Transseries <-> Differential Algebra (Hardy fields), Transseries <-> EML Theory (derivative of eml(a,b))

**Lineage**: Builds on depth filtration and shift operations from this cycle, connects to EML chain operations in catalog.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Valuation on Transseries

**Conjecture**: The "leading growth level" function v: Transseries → GrowthLevel ∪ {−∞} is a valuation in the tropical semiring sense: v(S + T) = max(v(S), v(T)) and v(S · T) = v(S) ⊕ v(T) where ⊕ is the tropical addition on growth levels (which is the max operation on the depth, and addition of exponents when depths agree).

**Test**: Verify the valuation axioms for products of single-term transseries at various depth levels. Check that v(exp(x) · x^3) = v(exp(x)) = (1,1) (the higher-depth term dominates).

**Impact**: If true, this would connect transseries theory to tropical geometry, enabling the use of tropical techniques (Newton polygons, tropical curves) for asymptotic analysis. The tropical valuation would provide a systematic way to extract the dominant asymptotics of complicated expressions.

**Catalog References**: `Tropical/` (tropical semiring formalization), `Applications/TransseriesDefs.lean` (growth levels with lexicographic order)

**Proof Strategy**: Define tropical addition on growth levels as max in the lexicographic order. Define tropical multiplication as: if depths agree, add exponents; if depths differ, take the higher-depth term. Verify this satisfies the tropical semiring axioms. Then show the leading-term extraction is a homomorphism.

**Domain Bridges**: Transseries <-> Tropical Geometry (valuations), Transseries <-> Algebraic Geometry (Newton polygons for asymptotic expansions)

**Lineage**: Builds on growth level ordering and three-level hierarchy from this cycle.

**Ambition**: extension

---

### Direction 4: Real Closure of Transseries Fields

**Conjecture**: The ordered field of transseries (with the natural ordering induced by asymptotic comparison) is real closed: every odd-degree polynomial over transseries has a root, and every positive element has a square root.

**Test**: Construct explicit square roots for single-term transseries: √(c·exp(αx)) = √c · exp(αx/2). Verify that cubic polynomials t³ + a·t + b have roots when a, b are transseries.

**Impact**: Real closure is the key structural property that makes transseries a viable alternative to the reals for asymptotic analysis. It implies the intermediate value theorem holds for transseries, which is the foundation for the transfer principle between real analysis and transseries algebra. This is one of the deepest results in transseries theory (proved by Aschenbrenner, van den Dries, and van der Hoeven).

**Catalog References**: `Applications/TransseriesTheorems.lean` (asymptotic comparison), `EML/EMLv17Core.lean` (eml as ordered structure)

**Proof Strategy**: Start with square roots of positive single-term transseries (halve the exponent). For polynomials, use Newton's method in the transseries setting: the leading term of the root is determined by balancing the leading terms of the polynomial. This gives an iterative algorithm that converges in the valuation topology.

**Domain Bridges**: Transseries <-> Model Theory (real closed fields, o-minimality), Transseries <-> Algebra (algebraic closure)

**Lineage**: Builds on the complete ordered structure of growth levels from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Surreal-Transseries Bridge via Conway Normal Form

**Conjecture**: There exists an order-preserving embedding from the Graded Transseries Algebra into Conway's surreal numbers such that the depth filtration maps to the birthday (simplicity) filtration of surreals, and the exp-log shift corresponds to the surreal exponential function.

**Test**: Map single-term transseries to surreals: c·x^α ↦ ω^α · c, c·exp(x) ↦ ω^ω · c. Verify that the ordering is preserved and that the depth-1 embedding is consistent with the surreal exponential.

**Impact**: This would provide a concrete bridge between two of the most important extensions of the real numbers: transseries (analytic/asymptotic) and surreals (combinatorial/game-theoretic). Berarducci and Mantova have shown that surreal numbers form a field of transseries, but the explicit connection via depth filtrations is new.

**Catalog References**: `EML/` (surreal topology results in catalog), `Applications/TransseriesDefs.lean` (growth levels)

**Proof Strategy**: Use the Conway normal form of surreal numbers, which represents each surreal as a formal sum of ω^α terms. Map growth level (0, α) to ω^α, growth level (1, α) to ω^{ω·α}, growth level (2, α) to ω^{ω^ω · α}. Show this is order-preserving using the lexicographic structure.

**Domain Bridges**: Transseries <-> Surreal Numbers (Conway normal form), Transseries <-> Game Theory (combinatorial game values)

**Lineage**: Builds on growth level structure and exp-log duality from this cycle, connects to surreal topology in catalog.

**Ambition**: extension
