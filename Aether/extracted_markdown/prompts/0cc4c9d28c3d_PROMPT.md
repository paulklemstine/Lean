
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.


## Concept

**Title**: Formalized bridge between ReLU neural network decision
**Domain**: MachineLearning
**Mathematical framing**: # Future Directions: Tropical Geometry of Neural Networks

## Synthesis

This cycle established a formalized bridge between ReLU neural network decision boundaries and tropical algebraic geometry. The key results — depth-width asymmetry ($(w+1)^L \geq Lw+1$), tropical sum distributivity, Maslov dequantization bounds, and the tropical Bézout bridge — form a coherent framework connecting network architecture to decision boundary complexity.

The most promising cross-domain connection is the **Maslov dequantization**, which provides an exact quantitative bridge between smooth algebraic varieties and tropical (piecewise linear) objects. This connection suggests that results from classical algebraic geometry (Bézout's theorem, Harnack's theorem, Morse theory) have tropical analogs that directly bound neural network behavior. The dequantization gap of $\varepsilon \log K$ provides a precise "resolution" at which the tropical approximation becomes exact.

The highest breakthrough potential lies in Direction 1 (Tropical Morse Theory), which would connect the *topology* of decision boundaries to network architecture through a tropical analog of Morse theory. If successful, this would give tight bounds on Betti numbers (connected components, holes, voids) of decision boundaries in terms of depth and width — going far beyond the region-counting bounds established in this cycle.

---

### Direction 1: Tropical Morse Theory for Decision Boundaries

**Conjecture**: For a ReLU network $f: \mathbb{R}^n \to \mathbb{R}$ with $L$ layers of width $w$, the sum of Betti numbers of the decision boundary $B = \{x : f(x) = 0\}$ satisfies:
$$\sum_k \beta_k(B) \leq 2 \cdot (w+1)^L \cdot \binom{n-1+L}{L}$$

This would be a tropical analog of the Milnor-Thom bound $\sum \beta_k(V) \leq d(2d-1)^{n-1}$ for degree-$d$ real algebraic varieties.

**Test**: Compute Betti numbers of decision boundaries for small networks (2D input, varying depth/width) using persistent homology. Compare to the conjectured bound.

**Impact**: If true, this gives the first *topological* complexity bound on neural network decision boundaries in terms of architecture. It would explain why deep networks can learn topologically complex decision regions (e.g., regions with holes) that shallow networks cannot. If false, the failure would reveal which topological features escape depth control.

**Catalog References**: `Catalog/Tropical/TropicalNNFrontier.lean` (region bounds), `Catalog/Tropical/Canonical/Basic.lean` (tropical rational forms)

**Proof Strategy**: 
1. Define tropical Morse index for a piecewise linear function (number of sign changes in the gradient at a critical point)
2. Prove a tropical Morse inequality: $\beta_k(B) \leq$ number of tropical critical points of index $k$
3. Count tropical critical points using the tropical degree and the hyperplane arrangement bound
4. Key lemma needed: each linear region contributes at most $\binom{n-1}{k}$ critical points of index $k$

**Domain Bridges**: Algebraic Topology ↔ Neural Networks ↔ Tropical Geometry

**Lineage**: Builds on depth_width_asymmetry, hyperplane_arrangement_bound, and decision_boundary_1d from this cycle

**Ambition**: grand_challenge

---

### Direction 2: Tropical VC Dimension Theory

**Conjecture**: The VC dimension of the function class computed by depth-$L$, width-$w$ ReLU networks with $n$-dimensional input satisfies:
$$\text{VCdim} \leq C \cdot L \cdot w \cdot n \cdot \log(Lw)$$
for a universal constant $C$, and this bound is tight up to the logarithmic factor: there exist networks achieving $\text{VCdim} \geq c \cdot L \cdot w \cdot n$.

The tropical perspective suggests the tighter bound $\text{VCdim} \leq L \cdot \sum_{k=0}^n \binom{w}{k}$ using the hyperplane arrangement bound.

**Test**: Compute exact VC dimension for small network architectures ($n \leq 3$, $w \leq 5$, $L \leq 3$) by exhaustive search over point configurations. Compare upper and lower bounds.

**Impact**: A tight VC dimension bound would directly give PAC learning sample complexity bounds for ReLU networks: $m \geq \frac{1}{\varepsilon}(\text{VCdim} \cdot \log(1/\varepsilon) + \log(1/\delta))$. This is the most direct route from tropical geometry to practical machine learning guarantees.

**Catalog References**: `MachineLearning/TropicalDecisionBoundary.lean` (activation_pattern_card, depth_width_asymmetry), `Catalog/Tropical/FreivaldsLocal.lean` (zero-set bounds)

**Proof Strategy**:
1. Upper bound: Use Goldberg-Jerrum (1995) technique — bound the number of sign patterns using Warren's theorem applied to each activation region
2. Lower bound: Construct explicit shattering configurations using the canonical tropical form
3. Key technical step: show that the number of sign patterns of $P$ piecewise linear functions on $m$ points is at most $(4ePm/\text{VCdim})^{\text{VCdim}}$

**Domain Bridges**: Statistical Learning Theory ↔ Tropical Geometry ↔ Combinatorics

**Lineage**: Extends vc_param_bound and activation_pattern_card from this cycle

**Ambition**: grand_challenge

---

### Direction 3: Tropical Canonical Forms for Convolutional Networks

**Conjecture**: A convolutional ReLU network with $L$ layers, filter size $k$, and $c$ channels computes a tropical rational function whose canonical form has at most $c^L \cdot k^L$ essential terms. The *translation invariance* of convolution implies that the tropical polynomial has a specific symmetry: its Newton polygon is invariant under lattice translations.

**Test**: Implement the canonical tropical rational extraction algorithm for small ConvNets (e.g., 2-layer, 3×3 filters, 8 channels on MNIST). Verify the term count bound and check for Newton polygon symmetry.

**Impact**: ConvNets are the workhorse of computer vision. Understanding their tropical structure would give certified bounds on what image features they can detect (controlled by the tropical degree) and how many distinct classification regions they create. The symmetry of the Newton polygon would formally explain *why* ConvNets are translation-invariant.

**Catalog References**: `Catalog/Tropical/Canonical/Basic.lean` (TropicalPoly, TropicalRat, canonical forms), `MachineLearning/TropicalAlgebraicBridge.lean` (layer composition)

**Proof Strategy**:
1. Define tropical convolution: $f \star g$ in the tropical semiring
2. Show convolution preserves the tropical polynomial structure
3. Bound the term count after $L$ convolution-ReLU layers
4. Characterize the Newton polygon symmetry induced by weight sharing

**Domain Bridges**: Computer Vision ↔ Tropical Geometry ↔ Lattice Theory

**Lineage**: Extends layer_composition_bound and total_term_count_crude

**Ambition**: extension

---

### Direction 4: Tropical Persistent Homology of Training Dynamics

**Conjecture**: During training of a ReLU network by gradient descent, the tropical degree of the network output (viewed as a tropical rational function) is *non-increasing* after the initial rapid growth phase. More precisely, the number of essential terms in the canonical tropical form follows a phase transition: rapid growth during the "memorization phase" followed by monotonic decrease during the "generalization phase."

**Test**: Train small networks (1D input, 2-3 layers, width 5-10) on synthetic datasets. At each training step, extract the canonical tropical form and track the term count, tropical degree, and Betti numbers of the decision boundary.

**Impact**: This would provide the first *geometric* characterization of the implicit regularization in neural network training. The conjecture that tropical degree decreases during generalization would explain Occam's razor in deep learning: gradient descent naturally simplifies the tropical structure of the function.

**Catalog References**: `MachineLearning/TropicalDecisionBoundary.lean` (depth_width_asymmetry, tropical_sum_distrib), `Catalog/Tropical/Canonical/Basic.lean` (canonical forms)

**Proof Strategy**:
1. Show that gradient descent on a loss function $L(f)$ with weight decay induces a "tropical flow" on the space of tropical rational functions
2. Prove that weight decay is equivalent to a penalty on tropical degree (the $L_1$ norm of the coefficient vector in tropical form)
3. Use the Maslov dequantization to connect SGD dynamics to a tropical flow
4. Key lemma: weight decay in the smooth (high-$\varepsilon$) regime corresponds to term elimination in the tropical ($\varepsilon \to 0$) regime

**Domain Bridges**: Optimization ↔ Tropical Geometry ↔ Statistical Learning

**Lineage**: Extends maslov_dequantization_upper/lower and the dequantization gap analysis

**Ambition**: grand_challenge

---

### Direction 5: Tropical Error-Correcting Codes from Network Decision Boundaries

**Conjecture**: The decision boundary arrangement of a depth-$L$, width-$w$ ReLU network in $\mathbb{R}^n$ defines a *tropical code*: a collection of $\leq (w+1)^L$ regions that can be used as codewords. The minimum "tropical distance" between adjacent regions is $\geq 1/\text{Lip}(f)$ where $\text{Lip}(f)$ is the Lipschitz constant. The resulting code achieves a rate-distance tradeoff of $R \leq 1 - d/\sqrt{n}$ (analogous to the Singleton bound).

**Test**: Construct explicit tropical codes from trained binary classifiers. Measure the minimum distance between class regions and compare to the conjectured Singleton-type bound.

**Impact**: This would establish a novel connection between neural network architectures and coding theory. The tropical code construction would give a new family of codes with structured decoder (the neural network itself). If the rate-distance tradeoff is competitive, this could yield practical applications in communication systems.

**Catalog References**: `MachineLearning/TropicalAlgebraicBridge.lean` (hyperplane_arrangement_bound, decision_boundary_1d), `Catalog/Tropical/FreivaldsLocal.lean` (Freivalds/Schwartz-Zippel connection)

**Proof Strategy**:
1. Define tropical distance between regions as the Hausdorff distance of their boundaries
2. Show this distance is bounded below by $1/\text{Lip}(f)$ where $f$ is the network function
3. Count the number of regions to get the rate
4. Derive the Singleton-type bound from the volume argument: regions of minimum distance $d$ in $\mathbb{R}^n$ pack at most $(R/d)^n$ efficiently

**Domain Bridges**: Coding Theory ↔ Neural Networks ↔ Tropical Geometry

**Lineage**: Extends boundary_perturbation_bound and hyperplane_arrangement_bound

**Ambition**: extension

**Concept description**: # Future Directions: Tropical Geometry of Neural Networks

## Synthesis

This cycle established a formalized bridge between ReLU neural network decision boundaries and tropical algebraic geometry. The key results — depth-width asymmetry ($(w+1)^L \geq Lw+1$), tropical sum distributivity, Maslov dequantization bounds, and the tropical Bézout bridge — form a coherent framework connecting network architecture to decision boundary complexity.

The most promising cross-domain connection is the **Maslov dequantization**, which provides an exact quantitative bridge between smooth algebraic varieties and tropical (piecewise linear) objects. This connection suggests that results from classical algebraic geometry (Bézout's theorem, Harnack's theorem, Morse theory) have tropical analogs that directly bound neural network behavior. The dequantization gap of $\varepsilon \log K$ provides a precise "resolution" at which the tropical approximation becomes exact.

The highest breakthrough potential lies in Direction 1 (Tropical Morse Theory), which would connect the *topology* of decision boundaries to network architecture through a tropical analog of Morse theory. If successful, this would give tight bounds on Betti numbers (connected components, holes, voids) of decision boundaries in terms of depth and width — going far beyond the region-counting bounds established in this cycle.

---

### Direction 1: Tropical Morse Theory for Decision Boundaries

**Conjecture**: For a ReLU network $f: \mathbb{R}^n \to \mathbb{R}$ with $L$ layers of width $w$, the sum of Betti numbers of the decision boundary $B = \{x : f(x) = 0\}$ satisfies:
$$\sum_k \beta_k(B) \leq 2 \cdot (w+1)^L \cdot \binom{n-1+L}{L}$$

This would be a tropical analog of the Milnor-Thom bound $\sum \beta_k(V) \leq d(2d-1)^{n-1}$ for degree-$d$ real algebraic varieties.

**Test**: Compute Betti numbers of decision boundaries for small networks (2D input, varying depth/width) using persistent homology. Compare to the conjectured bound.

**Impact**: If true, this gives the first *topological* complexity bound on neural network decision boundaries in terms of architecture. It would explain why deep networks can learn topologically complex decision regions (e.g., regions with holes) that shallow networks cannot. If false, the failure would reveal which topological features escape depth control.

**Catalog References**: `Catalog/Tropical/TropicalNNFrontier.lean` (region bounds), `Catalog/Tropical/Canonical/Basic.lean` (tropical rational forms)

**Proof Strategy**: 
1. Define tropical Morse index for a piecewise linear function (number of sign changes in the gradient at a critical point)
2. Prove a tropical Morse inequality: $\beta_k(B) \leq$ number of tropical critical points of index $k$
3. Count tropical critical points using the tropical degree and the hyperplane arrangement bound
4. Key lemma needed: each linear region contributes at most $\binom{n-1}{k}$ critical points of index $k$

**Domain Bridges**: Algebraic Topology ↔ Neural Networks ↔ Tropical Geometry

**Lineage**: Builds on depth_width_asymmetry, hyperplane_arrangement_bound, and decision_boundary_1d from this cycle

**Ambition**: grand_challenge

---

### Direction 2: Tropical VC Dimension Theory

**Conjecture**: The VC dimension of the function class computed by depth-$L$, width-$w$ ReLU networks with $n$-dimensional input satisfies:
$$\text{VCdim} \leq C \cdot L \cdot w \cdot n \cdot \log(Lw)$$
for a universal constant $C$, and this bound is tight up to the logarithmic factor: there exist networks achieving $\text{VCdim} \geq c \cdot L \cdot w \cdot n$.

The tropical perspective suggests the tighter bound $\text{VCdim} \leq L \cdot \sum_{k=0}^n \binom{w}{k}$ using the hyperplane arrangement bound.

**Test**: Compute exact VC dimension for small network architectures ($n \leq 3$, $w \leq 5$, $L \leq 3$) by exhaustive search over point configurations. Compare upper and lower bounds.

**Impact**: A tight VC dimension bound would directly give PAC learning sample complexity bounds for ReLU networks: $m \geq \frac{1}{\varepsilon}(\text{VCdim} \cdot \log(1/\varepsilon) + \log(1/\delta))$. This is the most direct route from tropical geometry to practical machine learning guarantees.

**Catalog References**: `MachineLearning/TropicalDecisionBoundary.lean` (activation_pattern_card, depth_width_asymmetry), `Catalog/Tropical/FreivaldsLocal.lean` (zero-set bounds)

**Proof Strategy**:
1. Upper bound: Use Goldberg-Jerrum (1995) technique — bound the number of sign patterns using Warren's theorem applied to each activation region
2. Lower bound: Construct explicit shattering configurations using the canonical tropical form
3. Key technical step: show that the number of sign patterns of $P$ piecewise linear functions on $m$ points is at most $(4ePm/\text{VCdim})^{\text{VCdim}}$

**Domain Bridges**: Statistical Learning Theory ↔ Tropical Geometry ↔ Combinatorics

**Lineage**: Extends vc_param_bound and activation_pattern_card from this cycle

**Ambition**: grand_challenge

---

### Direction 3: Tropical Canonical Forms for Convolutional Networks

**Conjecture**: A convolutional ReLU network with $L$ layers, filter size $k$, and $c$ channels computes a tropical rational function whose canonical form has at most $c^L \cdot k^L$ essential terms. The *translation invariance* of convolution implies that the tropical polynomial has a specific symmetry: its Newton polygon is invariant under lattice translations.

**Test**: Implement the canonical tropical rational extraction algorithm for small ConvNets (e.g., 2-layer, 3×3 filters, 8 channels on MNIST). Verify the term count bound and check for Newton polygon symmetry.

**Impact**: ConvNets are the workhorse of computer vision. Understanding their tropical structure would give certified bounds on what image features they can detect (controlled by the tropical degree) and how many distinct classification regions they create. The symmetry of the Newton polygon would formally explain *why* ConvNets are translation-invariant.

**Catalog References**: `Catalog/Tropical/Canonical/Basic.lean` (TropicalPoly, TropicalRat, canonical forms), `MachineLearning/TropicalAlgebraicBridge.lean` (layer composition)

**Proof Strategy**:
1. Define tropical convolution: $f \star g$ in the tropical semiring
2. Show convolution preserves the tropical polynomial structure
3. Bound the term count after $L$ convolution-ReLU layers
4. Characterize the Newton polygon symmetry induced by weight sharing

**Domain Bridges**: Computer Vision ↔ Tropical Geometry ↔ Lattice Theory

**Lineage**: Extends layer_composition_bound and total_term_count_crude

**Ambition**: extension

---

### Direction 4: Tropical Persistent Homology of Training Dynamics

**Conjecture**: During training of a ReLU network by gradient descent, the tropical degree of the network output (viewed as a tropical rational function) is *non-increasing* after the initial rapid growth phase. More precisely, the number of essential terms in the canonical tropical form follows a phase transition: rapid growth during the "memorization phase" followed by monotonic decrease during the "generalization phase."

**Test**: Train small networks (1D input, 2-3 layers, width 5-10) on synthetic datasets. At each training step, extract the canonical tropical form and track the term count, tropical degree, and Betti numbers of the decision boundary.

**Impact**: This would provide the first *geometric* characterization of the implicit regularization in neural network training. The conjecture that tropical degree decreases during generalization would explain Occam's razor in deep learning: gradient descent naturally simplifies the tropical structure of the function.

**Catalog References**: `MachineLearning/TropicalDecisionBoundary.lean` (depth_width_asymmetry, tropical_sum_distrib), `Catalog/Tropical/Canonical/Basic.lean` (canonical forms)

**Proof Strategy**:
1. Show that gradient descent on a loss function $L(f)$ with weight decay induces a "tropical flow" on the space of tropical rational functions
2. Prove that weight decay is equivalent to a penalty on tropical degree (the $L_1$ norm of the coefficient vector in tropical form)
3. Use the Maslov dequantization to connect SGD dynamics to a tropical flow
4. Key lemma: weight decay in the smooth (high-$\varepsilon$) regime corresponds to term elimination in the tropical ($\varepsilon \to 0$) regime

**Domain Bridges**: Optimization ↔ Tropical Geometry ↔ Statistical Learning

**Lineage**: Extends maslov_dequantization_upper/lower and the dequantization gap analysis

**Ambition**: grand_challenge

---

### Direction 5: Tropical Error-Correcting Codes from Network Decision Boundaries

**Conjecture**: The decision boundary arrangement of a depth-$L$, width-$w$ ReLU network in $\mathbb{R}^n$ defines a *tropical code*: a collection of $\leq (w+1)^L$ regions that can be used as codewords. The minimum "tropical distance" between adjacent regions is $\geq 1/\text{Lip}(f)$ where $\text{Lip}(f)$ is the Lipschitz constant. The resulting code achieves a rate-distance tradeoff of $R \leq 1 - d/\sqrt{n}$ (analogous to the Singleton bound).

**Test**: Construct explicit tropical codes from trained binary classifiers. Measure the minimum distance between class regions and compare to the conjectured Singleton-type bound.

**Impact**: This would establish a novel connection between neural network architectures and coding theory. The tropical code construction would give a new family of codes with structured decoder (the neural network itself). If the rate-distance tradeoff is competitive, this could yield practical applications in communication systems.

**Catalog References**: `MachineLearning/TropicalAlgebraicBridge.lean` (hyperplane_arrangement_bound, decision_boundary_1d), `Catalog/Tropical/FreivaldsLocal.lean` (Freivalds/Schwartz-Zippel connection)

**Proof Strategy**:
1. Define tropical distance between regions as the Hausdorff distance of their boundaries
2. Show this distance is bounded below by $1/\text{Lip}(f)$ where $f$ is the network function
3. Count the number of regions to get the rate
4. Derive the Singleton-type bound from the volume argument: regions of minimum distance $d$ in $\mathbb{R}^n$ pack at most $(R/d)^n$ efficiently

**Domain Bridges**: Coding Theory ↔ Neural Networks ↔ Tropical Geometry

**Lineage**: Extends boundary_perturbation_bound and hyperplane_arrangement_bound

**Ambition**: extension

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: MachineLearning
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
