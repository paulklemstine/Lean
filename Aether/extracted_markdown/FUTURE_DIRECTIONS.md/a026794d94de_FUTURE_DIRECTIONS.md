# Future Directions: From Discriminant Uniformity to Arithmetic Statistics

## Synthesis

This research cycle established the **Discriminant Uniformity Theorem**: for any odd prime $p$, the discriminant map $(b,c) \mapsto b^2 - 4c$ on monic quadratics over $\mathbb{F}_p$ has perfectly uniform fibers of size $p$. This uniformity is the engine that converts the classification of field elements (squares, non-squares, zero) into exact splitting type counts: $p(p-1)/2$ split, $p$ ramified, $p(p-1)/2$ inert. The split fraction $(p-1)/(2p) \to 1/2$ recovers the degree-2 Chebotarev density theorem.

The most promising cross-domain connection is between **algebraic fiber geometry** (uniformity of coefficient-to-discriminant maps) and **probabilistic convergence** (splitting fractions → random permutation statistics). The uniformity theorem provides a precise mechanism: because fibers are uniform, counting reduces to classifying discriminant values, which is a classical problem in finite field arithmetic. This mechanism should generalize to higher-degree polynomials when the underlying coefficient-to-discriminant map preserves fiber uniformity — and our analysis predicts this holds for cubics exactly when $p \equiv 2 \pmod{3}$.

The **Discriminant Profile** abstraction introduced in this cycle provides a clean interface between the algebraic and probabilistic sides. Direction 1 (Cubic Uniformity) has the highest breakthrough potential because it would be the first verified instance of the polynomial-to-permutation dictionary beyond degree 2. Direction 3 (Profile Convergence) connects to the deepest open problems in arithmetic statistics.

---

### Direction 1: Cubic Discriminant Uniformity for $p \equiv 2 \pmod{3}$

**Conjecture**: For primes $p \equiv 2 \pmod{3}$, the map $(b, c) \mapsto -4b^3 - 27c^2$ from $\mathbb{F}_p^2$ to $\mathbb{F}_p$ has uniform fibers of size $p$.

**Test**: Compute fiber sizes for $p = 5, 11, 17, 23, 29$ (all $\equiv 2 \pmod{3}$). If any fiber has size $\neq p$, the conjecture is false. If all match, attempt a formal proof.

**Impact**: If true, this provides the algebraic engine for computing exact cubic splitting type counts over $\mathbb{F}_p$ when $p \equiv 2 \pmod{3}$. Combined with the classification of elements into cubes, non-cubes, and zero, this would yield exact formulas analogous to the quadratic case. This would be the first machine-verified instance of the coefficient-to-splitting-type dictionary for degree 3.

**Proof Strategy**: The key is that when $p \equiv 2 \pmod{3}$, the map $x \mapsto x^3$ is a bijection on $\mathbb{F}_p$ (since $\gcd(3, p-1) = 1$). The parametrization would be: for fixed target $d$, and for each $c \in \mathbb{F}_p$, solve $-4b^3 = d + 27c^2$ for $b$. Since the cubing map is bijective, $b$ is uniquely determined. This gives a bijection $\mathbb{F}_p \to F(d)$ via $c \mapsto ((-{(d + 27c^2)}/4)^{1/3}, c)$. The proof requires formalizing the bijectivity of the cubing map (via `ZMod.pow_card_sub_one_eq_one` and coprimality) and then following the quadratic proof template.

**Catalog References**: `Speculative/DiscriminantUniformity.lean` (disc_fiber_card, fiberParam, DiscriminantProfile)

**Domain Bridges**: Algebra (finite field arithmetic) ↔ Probability (cubic splitting statistics) ↔ Number Theory (Chebotarev for $S_3$)

**Lineage**: Extends the quadratic discriminant uniformity theorem from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: The Mod-3 Obstruction — Non-Uniformity for $p \equiv 1 \pmod{3}$

**Conjecture**: For primes $p \equiv 1 \pmod{3}$ (e.g., $p = 7, 13, 19$), the cubic discriminant map $(b, c) \mapsto -4b^3 - 27c^2$ does NOT have uniform fibers. Specifically, the fiber over $0$ has cardinality $\neq p$.

**Test**: For $p = 7$: enumerate all 49 pairs $(b, c) \in \mathbb{F}_7^2$, compute $-4b^3 - 27c^2 \pmod{7}$, and tabulate fiber sizes. If any value $d$ has fiber size $\neq 7$, the non-uniformity is confirmed.

**Impact**: If confirmed, this identifies the precise obstruction to generalizing the quadratic uniformity theorem: the existence of nontrivial $n$-th roots of unity in $\mathbb{F}_p^*$ (equivalently, $n \mid p - 1$) prevents the power map $x \mapsto x^n$ from being bijective, which breaks the fiber parametrization. This connects to the structure of the multiplicative group $\mathbb{F}_p^*$ and the distribution of $n$-th power residues — a bridge between algebra and analytic number theory.

**Proof Strategy**: For $p \equiv 1 \pmod{3}$, the cubing map $x \mapsto x^3$ is 3-to-1 on $\mathbb{F}_p^*$ (since $3 \mid p - 1$). This means the equation $-4b^3 = d + 27c^2$ may have 0 or 3 solutions for $b$ depending on whether $(d + 27c^2)/(-4)$ is a cube. The fiber size over $d$ then depends on how many values of $c$ make $(d + 27c^2)/(-4)$ a cube, a zero, or a non-cube. This count varies with $d$, breaking uniformity. A constructive proof would exhibit two values $d_1, d_2$ with different fiber sizes.

**Catalog References**: `Speculative/DiscriminantUniformity.lean` (disc_fiber_card, DiscriminantProfile)

**Domain Bridges**: Algebra (power residues, multiplicative group structure) ↔ Combinatorics (non-uniform fiber counting) ↔ Number Theory (cubic reciprocity)

**Lineage**: Extends this cycle's analysis by identifying where the quadratic proof strategy fails.

**Ambition**: extension

---

### Direction 3: Profile Convergence — Splitting Statistics Approach $S_n$ Cycle Types

**Conjecture**: For degree $n$ and large primes $p$, the fraction of monic degree-$n$ polynomials over $\mathbb{F}_p$ with a given factorization pattern (i.e., cycle type of the associated Frobenius permutation) converges to the fraction of permutations in $S_n$ with that cycle type.

Specifically, for $n = 3$: as $p \to \infty$, among $p^2$ depressed cubics $x^3 + bx + c$:
- Fraction with 3 distinct roots → $1/6$ (cycle type $(1)(2)(3)$ in $S_3$, probability $1/6$)
- Fraction that factor as (linear)(irreducible quadratic) → $1/2$ (cycle type $(1)(23)$, probability $3/6 = 1/2$)
- Fraction that are irreducible → $1/3$ (cycle type $(123)$, probability $2/6 = 1/3$)
- Fraction with a repeated root → $0$ (measure zero)

**Test**: For primes $p = 101, 1009, 10007$, compute the factorization pattern distribution of all $p^2$ depressed cubics over $\mathbb{F}_p$. Check whether the fractions approach $1/6, 1/2, 1/3$ respectively.

**Impact**: A formal proof of this convergence for degree 3 would establish the first formalized connection between finite field polynomial statistics and the Chebotarev density theorem for $S_3$. It would validate the Discriminant Profile as a tool for studying arithmetic statistics and open the door to formalizing the general degree-$n$ case.

**Proof Strategy**: 
1. Establish cubic discriminant fiber counts (Direction 1 for $p \equiv 2 \pmod{3}$, separate analysis for $p \equiv 1 \pmod{3}$).
2. Count elements of $\mathbb{F}_p$ by cubic residue type: cubes, non-cubes of type 1, non-cubes of type 2.
3. Use the fiber counts to derive exact splitting type counts.
4. Take the limit as $p \to \infty$ using elementary analysis.

**Catalog References**: `Speculative/DiscriminantUniformity.lean` (split_fraction_limit, DiscriminantProfile)

**Domain Bridges**: Algebra (polynomial factorization) ↔ Probability (random permutation statistics) ↔ Number Theory (Chebotarev density) ↔ Representation Theory ($S_n$ conjugacy classes)

**Lineage**: Generalizes split_fraction_limit from degree 2 to degree 3.

**Ambition**: grand_challenge

---

### Direction 4: Discriminant Profiles for Polynomial Families with Constraints

**Conjecture**: For the family of *Eisenstein quadratics* $x^2 + bx + c$ over $\mathbb{F}_p$ where $p \mid c$ (i.e., $c = 0$ in $\mathbb{F}_p$), the discriminant profile is $(p-1)/2$ split, $1$ ramified, $(p-1)/2$ inert, with total $p$.

**Test**: Verify for $p = 5, 7, 11$: among the $p$ quadratics $x^2 + bx$ (with $c = 0$), count those with $b^2$ a nonzero square, zero, or non-square.

**Impact**: This shows how constraining the coefficient space changes the discriminant profile. For Eisenstein polynomials (where the constant term is divisible by the prime), the ramified fraction jumps from $1/p$ to $1/p$ of a family of size $p$ instead of $p^2$ — the total changes but the ramified count drops to exactly 1. This connects to ramification theory in algebraic number theory.

**Proof Strategy**: With $c = 0$, the discriminant is $b^2$, which is always a square. So the classification reduces to: $b = 0$ gives ramified, $b \neq 0$ gives split. Wait — that means there are NO inert quadratics in this family! The conjecture needs revision: the profile should be $(p-1)$ split, $1$ ramified, $0$ inert. This is because a perfect square $b^2$ is always a square (or zero). This corrected conjecture is easily provable and illustrates how sub-family selection can dramatically alter the profile.

**Catalog References**: `Speculative/DiscriminantUniformity.lean` (DiscriminantProfile, classifyQuad)

**Domain Bridges**: Algebra (Eisenstein criterion) ↔ Number Theory (ramification theory)

**Lineage**: Applies DiscriminantProfile to constrained polynomial families.

**Ambition**: extension

---

### Direction 5: Tropical Discriminant and Valuation-Theoretic Fiber Counting

**Conjecture**: Over a valued field $(K, v)$, the tropicalization of the discriminant map $(b, c) \mapsto b^2 - 4c$ — given by $(\beta, \gamma) \mapsto \min(2\beta, \gamma)$ — has fibers whose structure can be read off from the Newton polygon of $x^2 + bx + c$.

**Test**: For $K = \mathbb{Q}_p$ with $p$-adic valuation: fix a tropical discriminant value $\delta$. Parametrize the "tropical fiber" $\{(\beta, \gamma) : \min(2\beta, \gamma) = \delta\}$ and verify it decomposes into exactly two rays (one where $2\beta < \gamma$, one where $\gamma < 2\beta$) plus a vertex (where $2\beta = \gamma = \delta$). The vertex corresponds to the ramified locus.

**Impact**: This would bridge the Discriminant Uniformity Theorem (a finite field result) with tropical geometry (a valuation-theoretic framework). The fiber structure of the tropical discriminant governs the possible Newton polygons of quadratics, which in turn determine splitting behavior over local fields. This connects to the Catalog's tropical infrastructure.

**Proof Strategy**: Define the tropical discriminant as a piecewise-linear function. Show that the tropical fiber decomposes into polyhedral cells indexed by the cases $2\beta < \gamma$, $2\beta = \gamma$, $2\beta > \gamma$. Connect each cell to a splitting type via the Newton polygon classification.

**Catalog References**: `Tropical/TropicalStructure.lean` (prediction_bound_from_fiber_size), `Computation/PadicValuationDepth.lean` (ValuationDepthMeasure)

**Domain Bridges**: Algebra (discriminant fibers) ↔ Tropical Geometry (Newton polygons) ↔ Number Theory ($p$-adic analysis)

**Lineage**: Bridges the discriminant uniformity results with the Catalog's tropical and $p$-adic infrastructure.

**Ambition**: extension
