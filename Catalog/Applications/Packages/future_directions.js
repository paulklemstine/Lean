

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = [
  {
    "id": "fd_0008",
    "title": "Escher Staircases in Algebra: Infinite Ascending Chains That Loop Back",
    "description": "An Escher staircase is an infinite strictly ascending chain of ideals I_1 strictly contained in I_2 strictly contained in ... that nevertheless has I_1 as an element of the infinite intersection. This seems impossible \u2014 how can an infinite ascending chain loop back to the beginning? But in the ring of integer-valued polynomials Int(Z), the chain I_n = {f in Int(Z) : f(Z) contained in 2^n Z} is strictly ascending (I_n strictly contained in I_{n+1}) yet the intersection of all I_n is {0}, which contains the zero polynomial that is also in I_1. Conjecture: Every non-Noetherian ring contains an Escher staircase, and the 'height' of the Escher effect (measured by the Krull dimension gap) is a new ring invariant. For Int(Z), the Escher height is infinite (the chain never stabilizes). For Z[x_1, x_2, ...], the Escher height equals the number of variables. For the p-adic integers Z_p, there is NO Escher staircase (Z_p is a DVR, hence Noetherian). Test: prove that Int(Z) has an Escher staircase of infinite height. Prove that k[x_1,...,x_n] has Escher height n. Compute the Escher height for the ring of all algebraic integers. Impact: a new invariant for non-Noetherian rings that measures how far a ring is from being Noetherian \u2014 the algebraic equivalent of Escher's impossible architecture.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.492679+00:00"
  },
  {
    "id": "fd_0010",
    "title": "Dark Mathematics: Theorems That Exist But Cannot Be Found",
    "description": "There are mathematical objects whose existence we can prove but whose specific properties are unknowable \u2014 theorems that cast shadows without being visible. Define a dark theorem as a statement T such that: (1) PA proves 'there exists x such that T(x)', but (2) for every specific n, PA does NOT prove T(n). The classic example is the Paris-Harrington theorem: the strengthened finite Ramsey theorem is true but not provable in PA. But dark theorems go further: they assert the existence of objects that no specific instance can be verified. Conjecture: The set of dark theorems is dense in the space of all Pi_2 statements \u2014 most true Pi_2 statements are dark. Moreover, there is a hierarchy of darkness: a dark theorem of level k is one where PA proves 'there exist at least k values of x such that T(x)' but cannot identify any specific one. The hierarchy is strict: level k+1 dark theorems are strictly harder to prove than level k. Test: construct explicit dark theorems of levels 1, 2, 3 using the Paris-Harrington principle and the Kirby-Paris hydra theorem. Prove the density conjecture by counting Pi_2 statements. Impact: most true mathematical statements are dark \u2014 they assert existence without the possibility of verification. This is not incompleteness; it is a new form of mathematical unknowability.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.494005+00:00"
  },
  {
    "id": "fd_0012",
    "title": "The Periodic Table of Finite Groups: Chemistry Meets Algebra",
    "description": "Mendeleev organized 63 elements into a periodic table that predicted undiscovered elements. Can we do the same for finite groups? Classify all finite groups of order <= 2000 (there are approximately 10^15 of them, so we need a structural organization). Define group families as 'chemical series': cyclic groups are noble gases (stable, simple structure), symmetric groups are halogens (highly reactive, generate all finite groups), simple groups are transition metals (rare, catalytic). Conjecture: The 'periodic law' for finite groups is: groups in the same column (same family type) have isomorphic composition factors. The 'atomic number' is the order, and the 'valence' is the number of minimal normal subgroups. Groups with the same composition factors but different orders are 'isotopes' \u2014 they share chemical properties (solubility = solvability, reactivity = generation capacity). Test: construct a periodic table of groups of order <= 100, organizing them by composition factors. Verify that groups in the same column share key properties (nilpotency class, derived length, automorphism group order). Predict the properties of undiscovered groups (e.g., order 120, composition factors {2,2,2,3,5}) before looking them up. Impact: a chemical-mathematical analogy that makes the classification of finite groups intuitive and predictive.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.495596+00:00"
  },
  {
    "id": "fd_0016",
    "title": "Surreal Topology: What Topology Does the Field of Surreal Numbers Have?",
    "description": "Conway's surreal numbers No form the largest totally ordered field, containing all real numbers, all ordinals, and all infinitesimals. But No is a proper class, not a set. What topology does it have? Conjecture: No has a unique topology making it a connected, locally connected, locally compact, complete ordered field. This topology is NOT the order topology (which makes No totally disconnected). Instead, it is the 'interval topology' generated by open intervals (a,b) = {x in No : a < x < b} where a,b are arbitrary surreal numbers. The interval topology on No is connected because between any two surreals a < b there are infinitely many surreals, and No has no gaps (every Dedekind cut is filled). Moreover, No is contractible in this topology \u2014 every surreal number can be continuously deformed to 0 via the homotopy H(x,t) = x * {t | 0} where {t | 0} is the surreal number between t and 0. Test: prove that No with the interval topology is connected. Prove that it is locally compact (every surreal has a neighborhood basis of intervals with surreal endpoints). Prove that No is contractible. Compute the fundamental group: pi_1(No) = 0 (trivial, since No is contractible). Impact: the largest ordered field has a natural topology that makes it contractible \u2014 every surreal number is connected to every other by a continuous path.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.499504+00:00"
  },
  {
    "id": "fd_0023",
    "title": "Gravity from Information: Spacetime as a Quantum Error-Correcting Code",
    "description": "Einstein showed that gravity is the curvature of spacetime. But WHY does spacetime curve? Conjecture: Spacetime IS a quantum error-correcting code, and gravity IS the syndrome of that code. The code is a [[n,k,d]] stabilizer code where n = number of Planck areas on a spatial slice, k = number of logical qubits (which equals the Bekenstein-Hawking entropy S = A/4G in natural units), and d = code distance (which equals the minimal geodesic length through the bulk). The key identity: S(A) = Area(gamma_A) / (4G) is EXACTLY the quantum Singleton bound n - k <= 2(d-1) rearranged as k = n - 2d + 2 = A/(4G) when n = A/l_P^2 and d = L/(2l_P). This means the Bekenstein-Hawking entropy formula is a quantum coding theorem, and the holographic principle is a coding constraint. Test: for AdS_3 with boundary CFT_2, the code is a [[n, k, d]] = [[L/l_P, S, L/(2l_P)]] code. Verify that the Singleton bound n - k <= 2(d-1) becomes L/l_P - S <= L/l_P - 1, which simplifies to S >= 1 (trivially true). The NON-TRIVIAL content is that the Ryu-Takayanagi formula S = A/(4G) is the exact quantum information identity. Impact: spacetime is not curved by matter \u2014 spacetime IS a code, and matter IS a syndrome. Gravity is not a force; it's error correction.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.510412+00:00"
  },
  {
    "id": "fd_0034",
    "title": "Cellular Automata as Algebraic Geometry: Wolfram's Rules Meet Grothendieck",
    "description": "Elementary cellular automata (ECAs) are the 256 rules that update a 1D binary array based on its 3-cell neighborhood. Rule 110 is Turing-complete. But ECAs can also be viewed as polynomial maps over GF(2): the state s = (s_0, s_1, ..., s_{n-1}) is a vector over GF(2), and the update rule is s -> f(s) where f is a degree-3 polynomial (since the rule depends on 3 cells). Conjecture: The algebraic variety V(f) = {s : f(s) = s} (fixed points of the ECA) has dimension equal to the 'complexity class' of the rule. For simple rules (e.g., Rule 0, which is all zeros), V(f) has dimension 0 (a single point). For complex rules (e.g., Rule 110), V(f) has maximal dimension. The Grothendieck-style approach: each ECA defines a sheaf on the state space, and the global sections of this sheaf classify the possible stable configurations. Rule 110's sheaf has the richest section structure, corresponding to its Turing-completeness. Test: compute dim(V(f)) for all 256 ECAs and verify that the dimension correlates with Wolfram's complexity classification (Class 1: dim=0, Class 2: dim<=n/2, Class 3: dim>=n/2, Class 4: dim=n). Impact: cellular automata are algebraic varieties, and their complexity is the dimension of their fixed-point variety.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.536490+00:00"
  },
  {
    "id": "fd_0036",
    "title": "Quantum Entanglement as Algebraic Topology: The Linking Number Is Entanglement",
    "description": "Two quantum particles are entangled if measuring one instantly affects the other. But entanglement is also a topological property: if you represent the state of two qubits as a curve in R^3, entanglement IS the linking number. Conjecture: For any pure state of two qubits |psi> in C^2 tensor C^2, the concurrence C(psi) = 2|alpha*delta - beta*gamma| (where psi = alpha|00> + beta|01> + gamma|10> + delta|11>) equals the absolute value of the linking number of two curves derived from the Hopf fibration applied to psi. Specifically, map psi to S^7 via normalization, then project to S^4 via the Hopf map, and the preimages of two points in S^4 are linked circles in S^7 whose linking number equals the concurrence. This means: entanglement is MEASURED by topology, and maximally entangled states correspond to the Hopf link (linking number 1). Test: for 1000 random two-qubit states, compute the concurrence and the linking number of the Hopf preimages, and verify they are equal. Prove the equality for the Bell states. Impact: quantum entanglement is not mysterious \u2014 it is the linking number of the Hopf fibration. Two particles are entangled if and only if their Hopf preimages are linked.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.542003+00:00"
  },
  {
    "id": "fd_0055",
    "title": "Turing's Flowers: Morphogenesis as Algebraic Geometry",
    "description": "In 1952, Turing showed that reaction-diffusion equations produce patterns (spots, stripes, spirals) that explain biological morphogenesis. But Turing patterns are solutions to PDEs, which are hard to analyze. Conjecture: Turing patterns are algebraic varieties. Specifically, the zero set of a Turing pattern (where the concentration equals the background level) is a real algebraic curve in 2D (for spots and stripes) or a real algebraic surface in 3D (for more complex patterns). The degree of the curve is the number of modes in the reaction-diffusion system. For a two-mode system (like the Gray-Scott model), the pattern is a curve of degree 2 (a conic section: circles for spots, parallel lines for stripes, hyperbolas for labyrinthine patterns). For a three-mode system, the pattern is a curve of degree up to 6 (sextic curves that can produce hexagonal patterns). The genus of the curve determines the pattern topology: genus 0 gives spots (topologically a sphere), genus 1 gives stripes (topologically a torus), and genus g > 1 gives labyrinthine patterns with g+1 holes. Test: simulate Turing patterns in the Gray-Scott model, fit the zero-set to an algebraic curve of degree d, and verify that d = 2 for spots and stripes. Compute the genus and verify it matches the pattern topology. Impact: biological patterns are algebraic curves. The mathematics of seashells, leopard spots, and zebra stripes is the mathematics of conic sections.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.608699+00:00"
  },
  {
    "id": "fd_0064",
    "title": "The Arithmetic of Games: Surreal Numbers as Number Fields",
    "description": "Conway's surreal numbers No form a proper class containing all real numbers, all ordinal numbers, and all infinitesimals. Every real number r has a surreal representation r = {r - 1 | r + 1}. Every ordinal alpha has a surreal representation alpha = {alpha |}. Every infinitesimal epsilon = {0 | 1, 1/2, 1/4, ...}. The surreal numbers form a field (in fact, a real-closed field). Conjecture: the subfield of surreals born by day omega (the set of surreals with finite birthdays) is isomorphic to the field of real algebraic numbers extended with all dyadic rationals. More precisely: No_{omega} = Q[2^{-n} : n in N] (the rationals extended with all dyadic rationals). The subfield born by day omega^2 contains all real numbers that are algebraic over the dyadic rationals, plus all infinitesimals that are algebraic over the reals. Conjecture: No_{omega^2} = R(x) where x is the smallest positive infinitesimal. Test: compute the field structure of surreals born by day omega and verify the isomorphism with the dyadic rationals. Impact: the surreal number hierarchy encodes the constructive hierarchy of real number fields \u2014 each birthday level adds exactly the algebraic closures needed.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.652777+00:00"
  },
  {
    "id": "fd_0065",
    "title": "Quantum Error Correction from Homological Algebra: CSS Codes as Cohomology",
    "description": "The Calderbank-Shor-Steane (CSS) quantum error-correcting codes are constructed from classical linear codes C_1, C_2 with C_2 perp subset C_1. The CSS code encodes dim(C_1) - dim(C_2) logical qubits. This is exactly the definition of a cohomology group: H^1(C_1, C_2) = C_1 / C_2. Conjecture: every CSS code is equivalent to a cohomology computation on a simplicial complex, and vice versa. Specifically, given a simplicial complex K, the CSS code with C_1 = Z_1(K, F_2) (1-cycles) and C_2 = B_1(K, F_2) (1-boundaries) encodes dim(H_1(K, F_2)) logical qubits with distance d = min(length of shortest non-trivial cycle, length of shortest non-trivial cocycle). This is the homological quantum error-correcting code HQECC(K). The distance d equals the systole of K (the length of the shortest non-contractible cycle). Conjecture: for the hypercube Q_n (n-dimensional cube graph), the HQECC encodes 1 qubit with distance d = 2^{n/2} (achieving the quantum Singleton bound). Test: construct HQECC for Q_4, Q_6, Q_8 and verify the parameters. Impact: quantum error correction is cohomology. Every simplicial complex gives a quantum code, and the code parameters are topological invariants.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.657673+00:00"
  },
  {
    "id": "fd_0067",
    "title": "Matroid Minors and the Graph Theorem: Robertson-Seymour for Matroids",
    "description": "The Robertson-Seymour theorem states that the set of finite graphs is well-quasi-ordered by the minor relation: any infinite sequence of graphs contains two where one is a minor of the other. This implies that any minor-closed graph property is characterized by a finite set of forbidden minors. Conjecture: the same theorem holds for representable matroids over any finite field. Specifically, for any finite field F_q, the set of F_q-representable matroids is well-quasi-ordered by the matroid minor relation. This would generalize the Robertson-Seymour theorem from graphs (F_2-representable matroids) to all finite fields. The conjecture is known to fail for general matroids (by the existence of infinite antichains of non-representable matroids), but for F_q-representable matroids with q <= 3, it is open. Conjecture: for F_3 (ternary matroids), the set of excluded minors for representability is finite. The current known excluded minors for F_3 are: the Fano matroid F_7, its dual F_7*, and the non-Pappus matroid. Test: enumerate ternary matroids of rank 3 on 9 elements, verify that all but the known excluded minors are F_3-representable. Impact: Robertson-Seymour for matroids would unify graph minor theory and matroid theory under a single well-quasi-ordering theorem.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.667149+00:00"
  },
  {
    "id": "fd_0073",
    "title": "Algebraic Geometry of Neural Networks: Varieties of Decision Boundaries",
    "description": "A neural network with ReLU activation defines a piecewise linear function f: R^n -> R^m. The decision boundary of a binary classifier f: R^n -> R is the set {x : f(x) = 0}, which is a piecewise linear hypersurface. The algebraic variety of the decision boundary is the zero set of the polynomial that best approximates f. Conjecture: for a ReLU network with L layers of widths (n, w_1, ..., w_L, 1), the decision boundary is a piecewise linear hypersurface with at most 2^L * prod w_i regions, and the degree of the best polynomial approximation is at most 2^L. More precisely, the decision boundary V(f) = {x : f(x) = 0} is a tropical hypersurface (a piecewise linear object that is the 'skeleton' of an algebraic variety). The tropical variety of the decision boundary has degree at most 2^L and at most prod_{i=1}^{L} (w_i choose 2) singularities. Conjecture: the VC dimension of a ReLU network with L layers and total width W is at most L * W * log(W), matching the known bound up to log factors. Test: train ReLU networks on synthetic data, extract decision boundaries, and verify they are tropical hypersurfaces with the predicted degree and singularity count. Impact: neural network decision boundaries are tropical varieties. The complexity of the network (L, W) determines the algebraic complexity of the boundary.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.695662+00:00"
  },
  {
    "id": "fd_0075",
    "title": "Knots and Lattices: The Alexander Polynomial as a Lattice Path Count",
    "description": "The Alexander polynomial Delta_K(t) of a knot K is a Laurent polynomial that encodes topological information about the knot. Conjecture: for any knot K with n crossings, the Alexander polynomial Delta_K(t) can be expressed as the generating function of lattice paths in Z^2 that avoid a region determined by the knot diagram. Specifically, define the 'knot lattice' L_K as the set of lattice paths from (0,0) to (n,n) that avoid the 'forbidden region' R_K determined by the crossing structure of K. Then Delta_K(t) = sum_{p in L_K} t^{area(p)} where area(p) is the area under the path p. This conjecture follows from the state sum formula for the Alexander polynomial: Delta_K(t) = sum_{states s} (-1)^{w(s)} t^{a(s)} where w(s) is the writhe and a(s) is the area of the state. The area a(s) is exactly the area under a lattice path determined by the state. Conjecture: every Alexander polynomial arises as a lattice path generating function, and vice versa. This means the Alexander polynomial is not just a knot invariant \u2014 it is a combinatorial object that counts lattice paths. Test: compute the Alexander polynomials for the first 50 knots and verify that each can be expressed as a lattice path generating function. Impact: knot invariants are combinatorial. The Alexander polynomial counts lattice paths, connecting topology to combinatorics.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.706858+00:00"
  },
  {
    "id": "fd_0076",
    "title": "Quantum Groups from Number Theory: The Riemann Hypothesis as a Representation Problem",
    "description": "The Riemann zeta function zeta(s) has non-trivial zeros at s = 1/2 + i*gamma_n on the critical line (assuming RH). These zeros encode deep arithmetic information. Conjecture: the zeros gamma_n are the spectrum of a self-adjoint operator on a Hilbert space, and this operator is the Casimir element of a quantum group G_q. Specifically, define the 'zeta quantum group' G_q as the q-deformation of SU(2) where q = e^{2*pi*i*gamma_1} (using the first zero gamma_1 ~ 14.13). The Casimir element C_q of G_q has eigenvalues that are quadratic functions of the representation labels, and the spectrum of C_q is {n(n+1) : n in N}. Conjecture: the Riemann zeros gamma_n are related to the spectrum of C_q by gamma_n = f(spectrum(C_q)) for some function f. If f is linear, this would mean the zeros are evenly spaced, which is false (the zeros have Poisson-like spacings). If f is logarithmic, gamma_n ~ pi*n/log(n) which matches the average spacing. Conjecture: the spectral statistics of C_q match the GUE random matrix statistics of the Riemann zeros (Montgomery's pair correlation conjecture). Test: compute the spectrum of C_q for G_q with q = e^{2*pi*i*gamma_1} and compare the spectral statistics with the Riemann zeros. Impact: the Riemann hypothesis is a representation-theoretic statement about quantum groups.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.711975+00:00"
  },
  {
    "id": "fd_0078",
    "title": "Categorification of Entropy: The Information Loss of Functors",
    "description": "Entropy H(X) = -sum p(x) log p(x) measures the information content of a random variable. In category theory, a functor F: C -> D 'loses information' when it maps non-isomorphic objects to isomorphic ones. Define the 'functorial entropy' H(F) as the expected information lost by F: H(F) = -sum_{d in Ob(D)} p(d) * log(p(d)) where p(d) = |F^{-1}(d)| / |Ob(C)|. Conjecture: For the forgetful functor U: Top -> Set that forgets the topology, H(U) = log(2^{aleph_0}) = aleph_0 (infinite entropy, because uncountably many topologies map to the same set). For the abelianization functor Ab: Grp -> AbGrp, H(Ab) = log(2) (each abelian group has 2 non-abelian preimages on average: G and G x Z/2Z). For the inclusion functor Inc: FinGrp -> Grp, H(Inc) = 0 (no information loss, since finite groups embed as themselves). Conjecture: H(F) = 0 iff F is faithful, and H(F) = infinity iff F identifies infinitely many non-isomorphic objects. For finite categories: H(F) = log(|Ob(C)| / |Ob(D)|) when F is 'uniform' (each fiber has the same size). Test: compute H(F) for various functors between finite categories and verify the formula. Impact: entropy is not just a measure-theoretic concept \u2014 it is the information-theoretic shadow of functoriality. Every functor loses information, and the entropy measures how much.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.722495+00:00"
  },
  {
    "id": "fd_0079",
    "title": "The Hodge Conjecture for Neural Networks: Algebraic Cycles in Decision Surfaces",
    "description": "The Hodge conjecture states that every rational cohomology class on a projective variety is a rational linear combination of algebraic cycles. For a ReLU neural network f: R^n -> R, the decision surface V(f) = {x : f(x) = 0} is a piecewise linear hypersurface. Conjecture: every rational homology class in H_{n-2}(V(f), Q) is represented by an algebraic cycle (a subvariety of V(f) of codimension 1). Since V(f) is piecewise linear, its homology groups are finitely generated and every cycle is a formal sum of linear pieces. Each linear piece is an algebraic cycle (a hyperplane section). Conjecture: the piecewise linear Hodge conjecture holds \u2014 every homology class in V(f) is a sum of hyperplane sections. This is TRUE for piecewise linear varieties because every face of a polyhedron is cut out by a linear equation. The deeper conjecture: for a ReLU network with L layers and widths (n, w_1, ..., w_L, 1), the Hodge numbers h^{p,q}(V(f)) satisfy h^{p,q} <= (w_1 choose p) * (w_L choose q) * prod_{i=2}^{L-1} w_i. Test: compute H_{n-2}(V(f)) for small ReLU networks and verify that every class is represented by hyperplane sections. Impact: the Hodge conjecture is trivially true for neural network decision surfaces. The non-trivial content is the BOUND on Hodge numbers.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.728070+00:00"
  },
  {
    "id": "fd_0082",
    "title": "Information Geometry of Optimization: Natural Gradient Follows Geodesics",
    "description": "The natural gradient algorithm updates parameters theta in the direction of steepest descent on the Fisher information manifold: theta_{t+1} = theta_t - eta * G^{-1}(theta_t) * gradient L(theta_t) where G is the Fisher information matrix. This is equivalent to following the geodesic on the statistical manifold (the Riemannian manifold with metric G). Conjecture: for any optimization problem with loss function L, the natural gradient descent converges to the minimum in O(1/t) iterations, regardless of the condition number of G. This is because the natural gradient follows the geodesic, which is the shortest path on the manifold, and the path length is O(1) (bounded by the diameter of the manifold). In contrast, standard gradient descent takes O(kappa) iterations where kappa is the condition number of G. Conjecture: natural gradient descent with step size eta = 1/t achieves L(theta_t) - L(theta*) = O(1/t) for convex losses, and L(theta_t) - L(theta*) = O(exp(-t/d)) for strongly convex losses, where d is the dimension. Test: compare natural gradient descent and standard gradient descent on logistic regression with varying condition numbers, verify the convergence rates. Impact: optimization is geometry. The natural gradient is the geodesic on the Fisher manifold, and geodesics are the shortest paths.",
    "domains": [
      "Novelty",
      "MachineLearning"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.744530+00:00"
  },
  {
    "id": "fd_0085",
    "title": "The Riemann-Roch Theorem for Graphs: Chip-Firing and the Canonical Divisor",
    "description": "The Riemann-Roch theorem for graphs (Baker-Norine, 2007) states that for a divisor D on a graph G, l(D) - l(K_G - D) = deg(D) + 1 - g(G) where l(D) is the rank of D, K_G is the canonical divisor, and g(G) is the genus (cyclomatic number). The chip-firing game is a combinatorial model: vertices hold chips, and 'firing' a vertex sends one chip along each incident edge. Conjecture: for the complete graph K_n, the canonical divisor K_{K_n} has rank (n-1)(n-2)/2 - 1, and the Riemann-Roch formula gives l(D) = deg(D) + 1 - (n-1)(n-2)/2 + l(K_{K_n} - D). For D = K_{K_n} (the canonical divisor itself): l(K_{K_n}) = (n-1)(n-2)/2 - 1 + 1 - (n-1)(n-2)/2 + l(0) = 0 + l(0). But l(0) = 0 (the empty divisor has rank 0). So l(K_{K_n}) = 0. Wait, this gives l(K_{K_n}) = 0, but the canonical divisor of K_n should have positive rank. Conjecture: the canonical divisor of K_n is K_{K_n} = sum_v (deg(v) - 1) * v = (n-2) * sum_v v, and l(K_{K_n}) = (n-1)(n-2)/2 - 1 (it achieves the genus minus 1). Test: compute the canonical divisor and verify the Riemann-Roch formula for K_n with n = 3, 4, 5, 6. Impact: chip-firing on complete graphs encodes the same information as the Riemann-Roch theorem on projective curves.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.761503+00:00"
  },
  {
    "id": "fd_0088",
    "title": "Tropical Cryptography: Min-Plus Encryption with Tropical Matrices",
    "description": "Tropical arithmetic (min-plus algebra) replaces + with min and * with +. A tropical matrix A over Z union {infinity} acts on vectors by tropical matrix multiplication: (A tropimes v)_i = min_j (A_{ij} + v_j). Tropical matrices have eigenvalues in the max-plus sense: lambda is a tropical eigenvalue if A tropimes v = lambda + v for some v. Conjecture: tropical matrix multiplication is a one-way function suitable for cryptography. Specifically, the 'tropical discrete logarithm problem' (TDLP) is: given a tropical matrix A and B = A^{otimes k} (tropical matrix power), find k. The tropical matrix power A^{otimes k} is computed in O(n^3 * log(k)) time (by repeated squaring), but recovering k from (A, A^{otimes k}) is hard because the tropical eigenvalues satisfy lambda(A^{otimes k}) = k * lambda(A) (tropical eigenvalues are additive under power), so k = lambda(A^{otimes k}) / lambda(A). But this only works if lambda(A) != 0 (in the tropical sense, lambda(A) != infinity). Conjecture: the tropical Diffie-Hellman key exchange is secure: Alice sends A^{otimes a}, Bob sends A^{otimes b}, and the shared key is A^{otimes ab}. Breaking this requires solving the TDLP, which is believed to be hard for random tropical matrices of size n >= 10. Test: implement the tropical DH key exchange and measure the key generation time vs matrix size. Attempt to break it with known attacks (tropical eigenvalue computation, shortest path algorithms). Impact: tropical arithmetic provides a new foundation for post-quantum cryptography.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.782446+00:00"
  },
  {
    "id": "fd_0092",
    "title": "Sheaf-Theoretic Data Integration: When Databases Form a Sheaf",
    "description": "A database with missing entries is a partial section of a sheaf. The sheaf condition (gluing) says that if two partial sections agree on their overlap, they can be glued into a global section. Conjecture: the probability that a random database with missing rate r satisfies the sheaf condition (i.e., can be consistently filled in) is P(sheaf) = (1-r)^{C(n,k)} where n is the number of columns, k is the number of rows, and C(n,k) is the number of overlapping constraints. This means: for a database with n columns and k rows, the probability of consistent imputation drops exponentially with the number of overlapping constraints. The sheaf imputation method: fill in missing values by finding the closest global section of the data sheaf. This is equivalent to solving a constrained optimization problem where the constraints are the sheaf condition on every overlapping pair of feature subsets. Conjecture: sheaf imputation outperforms mean imputation and KNN imputation when the missing rate r < 0.5 and the number of features n > 10, because the sheaf condition provides exponentially many consistency constraints that other methods ignore. Test: generate synthetic databases with known ground truth, introduce missing values at rate r, compare sheaf imputation with mean, KNN, and MICE. Impact: data imputation is a sheaf cohomology problem. The sheaf condition is the natural consistency constraint for databases.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.807837+00:00"
  },
  {
    "id": "fd_0095",
    "title": "Quantum Random Walks on Cayley Graphs: Spectral Gaps and Mixing Times",
    "description": "A quantum random walk on a group G is defined by a unitary operator U = sum_{g in S} |g><0| (where S is a generating set) acting on the Hilbert space l^2(G). The walk is periodic if U^k = I for some k, and mixing if the probability distribution P_n(g) = |<g|U^n|0>|^2 converges to the uniform distribution on G. Conjecture: for the Cayley graph Cay(G, S) where G is a finite group and S is a symmetric generating set, the quantum walk mixes in O(sqrt(|G|) * log(|G|)) steps, which is quadratically faster than the classical random walk (which takes O(|G|^2) steps for the spectral gap to kick in). The mixing time is determined by the spectral gap of U: tau_mix ~ 1/gap where gap = 1 - |lambda_2| and lambda_2 is the second-largest eigenvalue of U. Conjecture: for Cay(G, S) with S = the set of transpositions in S_n, the spectral gap of U is Omega(1/n), giving a mixing time of O(n * log(n)). This matches the known classical mixing time of O(n * log(n)) for the random transposition walk on S_n. The quantum advantage comes from the quadratically faster convergence of the probability distribution, not from the spectral gap. Test: simulate quantum random walks on Cayley graphs of S_n, S_n, A_5, and Z_n, measure the mixing time, and verify tau_mix = O(sqrt(|G|) * log(|G|)). Impact: quantum random walks mix quadratically faster than classical random walks on Cayley graphs. The quadratic speedup is universal.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.827686+00:00"
  },
  {
    "id": "fd_0097",
    "title": "Strange Loops: Self-Reference and G\u00f6del's Incompleteness",
    "description": "Prove that any sufficiently powerful formal system necessarily contains strange loops: statements that refer to their own unprovability. Formalize G\u00f6del's first incompleteness theorem as a fixed-point in the lattice of provability predicates. Explore whether consciousness arises from tangled hierarchies of self-referential symbols.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.840437+00:00"
  },
  {
    "id": "fd_0102",
    "title": "Transreal Arithmetic: Computing Beyond Plus-Minus Infinity",
    "description": "Formalize transreal arithmetic (Anderson's system: R \u222a {Phi, +inf, -inf} with Phi = 0/0). Prove the ring axioms fail but a wheel structure emerges. Determine which theorems of real analysis survive transreal extension and which collapse.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.870934+00:00"
  },
  {
    "id": "fd_0106",
    "title": "Social Credit Scores as Topological Invariants",
    "description": "Formalize social credit systems as continuous maps from a population to a totally ordered set. Prove that any such map creates fixed-point attractors in the social graph topology. Show that under reasonable assumptions, credit scores converge to a Cantor set attractor where small perturbations cause phase transitions.",
    "domains": [
      "Novelty",
      "Bridges"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.894923+00:00"
  },
  {
    "id": "fd_0108",
    "title": "Memory Editing: When Forgetting Is a Mathematical Operation",
    "description": "Formalize memory as a monoid homomorphism from experience streams to compressed representations. Prove that any such homomorphism satisfying a finite-memory bound must be lossy and that the information loss forms a submonoid. Show that targeted forgetting is equivalent to a quotient construction in the category of memory algebras.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.907112+00:00"
  },
  {
    "id": "fd_0118",
    "title": "Surreal Topology: Open Sets at Infinity",
    "description": "Extend topological space theory to include Conway's surreal numbers as the underlying set. Prove that the order topology on No is not first-countable and that every real open set has a surreal extension. Determine whether No is connected, compact, or paracompact in the interval topology.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.970403+00:00"
  },
  {
    "id": "fd_0125",
    "title": "Categorical Physics: The Shape of a Theory of Everything",
    "description": "Prove that any theory of everything in physics must be a (2,infinity)-category with duals. Formalize the cobordism hypothesis as a universal property and show that TQFTs, CFTs, and string theories are all shadows of a single object in this higher category. Determine whether the resulting theory is computable or contains oracle information.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.012168+00:00"
  },
  {
    "id": "fd_0134",
    "title": "Aboriginal Kinship as Group Theory: Dreamtime Algebra",
    "description": "Formalize Australian Aboriginal kinship systems (section and subsection systems) as finite groups acting on person-sets. Prove that the 4-section system is isomorphic to Z2 x Z2 and the 8-subsection system to Z2 x Z2 x Z2. Show that marriage rules correspond to coset restrictions and that the entire system forms a consistent group-theoretic structure.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.067326+00:00"
  },
  {
    "id": "fd_0138",
    "title": "Causal Loops in Category Theory: When Composition Loops Back",
    "description": "Construct a category where composition is not associative but satisfies a controlled failure: (f circ g) circ h and f circ (g circ h) are naturally isomorphic but not equal. Prove that such almost-categories are exactly the bicategories and that every coherent loop-tolerant algebraic structure forms a higher category.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.092242+00:00"
  },
  {
    "id": "fd_0148",
    "title": "This cycle formalized the foundational theory of self-avoiding walks on \u2124\u00b2 and t",
    "description": "# Future Directions: Self-Avoiding Walk Research\n\n## Synthesis\n\nThis cycle formalized the foundational theory of self-avoiding walks on \u2124\u00b2 and the hexagonal lattice, establishing the submultiplicativity of SAW counts, the existence of the connective constant via Fekete's lemma, and the algebraic properties of the Nienhuis constant \u221a(2+\u221a2). The most significant cross-domain connection is between combinatorial path-counting (submultiplicativity), real analysis (Fekete's lemma for subadditive sequences), and algebraic number theory (the minimal polynomial of the hexagonal connective constant).\n\nThe highest breakthrough potential lies in Direction 1: formalizing discrete holomorphicity on planar graphs, which would open the door not just to the Duminil-Copin\u2013Smirnov theorem but to the entire field of discrete complex analysis and its applications to statistical mechanics. The bridge decomposition (Direction 3) offers a more tractable intermediate step that could yield new rigorous bounds on the square lattice connective constant. The connection to tropical geometry (Direction 5) is speculative but could link SAW theory to the existing Catalog's tropical algebra infrastructure.\n\n---\n\n### Direction 1: Discrete Holomorphicity and the Parafermionic Observable\n\n**Conjecture**: The parafermionic observable F(z) = \u03a3_{\u03c9: a\u2192z} x_c^{|\u03c9|} e^{-i\u03c3\u03b8(\u03c9)} with \u03c3 = 5/8 and x_c = 1/\u221a(2+\u221a2) satisfies discrete Cauchy-Riemann equations on the medial lattice of the hexagonal lattice.\n\n**Test**: Formalize the medial lattice of the hexagonal lattice, define F(z) as a sum over walks, and verify the discrete Cauchy-Riemann equations for small domains (say, a 3\u00d73 hexagonal patch) computationally in Lean via `native_decide` or `#eval`. If the equations hold for small patches, proceed to the general proof.\n\n**Impact**: This would be the first step toward a complete formalization of the Duminil-Copin\u2013Smirnov theorem, one of the landmark results in mathematical physics of the 21st century. It would also provide infrastructure for formalizing other results in discrete complex analysis.\n\n**Catalog References**: `Computation/SelfAvoidingWalk/Basic.lean` (hexagonal lattice definitions, HexAdj, HexWalk)\n\n**Proof Strategy**: (1) Define the medial lattice of the hexagonal lattice. Each edge of the hexagonal lattice corresponds to a vertex of the medial lattice. (2) Define the discrete derivative operators \u2202_s and \u2202\u0304_s on the medial lattice. (3) Define the parafermionic observable F as a formal sum. (4) Prove that local cancellations in the sum yield the discrete CR equations. The key identity is that for each interior vertex of the medial lattice, the three terms contributing to \u2202\u0304F cancel due to the specific choice of \u03c3 = 5/8.\n\n**Domain Bridges**: Complex Analysis <-> Combinatorics <-> Statistical Mechanics\n\n**Lineage**: Builds on HexAdj, HexWalk, nienhuis_algebraic_identity from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Connective Constant Bounds for \u2124\u00b2\n\n**Conjecture**: The connective constant \u03bc of the square lattice \u2124\u00b2 satisfies 2.625 < \u03bc < 2.680, provable using only elementary combinatorial arguments (no analysis or physics).\n\n**Test**: Prove a_lower \u2264 c_n for all n \u2264 N using explicit constructions (e.g., spiral walks, L-shaped walks), and c_n \u2264 a_upper using the tree-like structure of SAWs. Specifically, try to prove c_n \u2264 4 \u00b7 3^{n-1} (upper bound from excluded neighbors) and c_n \u2265 2^n (walks along two axes and their reflections) in Lean.\n\n**Impact**: Rigorous, computer-verified bounds on \u03bc(\u2124\u00b2) would be a concrete contribution to the open problem. Even crude bounds, if formally verified, have value because they are machine-checked.\n\n**Catalog References**: `Computation/SelfAvoidingWalk/Basic.lean` (sawCount, sawCount_submultiplicative, one_le_sawCount)\n\n**Proof Strategy**: (1) Upper bound: Prove c_n \u2264 4 \u00b7 3^{n-1} by induction\u2014at each step after the first, the walker has at most 3 choices (cannot return). This requires showing that for n \u2265 1, each SAW of length n extends to at most 3 SAWs of length n+1 at each step. (2) Lower bound: Construct explicit families of walks\u2014e.g., \"staircase\" walks alternating between x and y directions, giving c_n \u2265 2^{\u230an/2\u230b}. (3) Improved bounds using the Hammersley-Welsh method with bridges.\n\n**Domain Bridges**: Combinatorics <-> Number Theory (growth rates) <-> Analysis (Fekete's lemma)\n\n**Lineage**: Direct extension of sawCount_submultiplicative, walk_coord_bound' from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Bridge Decomposition and Renewal Theory\n\n**Conjecture**: The bridge generating function b(x) = \u03a3 b_n x^n satisfies the identity \u03c7(x) = b(x) / (1 - b(x))\u00b2 where \u03c7(x) = \u03a3 c_n x^n is the SAW generating function, and this identity can be formalized in Lean using formal power series.\n\n**Test**: Verify the identity numerically for n \u2264 12 by computing bridge counts and SAW counts. Then formalize the renewal equation in Lean using `PowerSeries` from Mathlib.\n\n**Impact**: The bridge decomposition is the standard tool for converting between SAW bounds and bridge bounds. Formalizing it would provide machinery for systematic improvement of connective constant bounds.\n\n**Catalog References**: `Computation/SelfAvoidingWalk/Basic.lean` (Bridge, bridgeCount), `Algebra/Advanced.lean` (algebraic structures)\n\n**Proof Strategy**: (1) Formalize the bridge decomposition theorem: every SAW decomposes uniquely into a sequence of bridges. (2) This gives the generating function identity c_n = \u03a3_{k\u22651} \u03a3_{n\u2081+...+n_k=n} b_{n\u2081} \u00b7 ... \u00b7 b_{n_k} for walks that can be decomposed into k bridges. (3) In generating function language: \u03c7(x) = \u03a3_{k\u22651} b(x)^k = b(x)/(1-b(x)) (for one-directional bridges). The full identity accounts for the 2D structure. (4) Use Mathlib's `PowerSeries` for formal manipulation.\n\n**Domain Bridges**: Combinatorics <-> Formal Power Series <-> Renewal Theory\n\n**Lineage**: Builds on Bridge structure from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: High-Dimensional SAW and Mean-Field Behavior (Hara-Slade)\n\n**Conjecture**: For self-avoiding walks on \u2124^d with d \u2265 5, the connective constant satisfies \u03bc(\u2124^d) = 2d - 1 - 1/(2d) - O(1/d\u00b2), and the critical exponents take their mean-field values \u03b3 = 1, \u03bd = 1/2.\n\n**Test**: Formalize SAW on \u2124^d (generalizing from \u2124\u00b2), define the lace expansion, and prove the first-order asymptotic \u03bc \u2248 2d-1 for large d. For a concrete test: prove c_1(\u2124^d) = 2d and c_2(\u2124^d) = 2d(2d-1).\n\n**Impact**: The Hara-Slade theorem (1992) is the foundational result establishing mean-field behavior for SAW in high dimensions. Formalizing it would connect the SAW theory to the broader landscape of mean-field critical behavior.\n\n**Catalog References**: `Computation/SelfAvoidingWalk/Basic.lean` (LatticeWalk generalization needed)\n\n**Proof Strategy**: (1) Generalize LatticeWalk to \u2124^d by replacing \u2124 \u00d7 \u2124 with \u2124^d (using `Fin d \u2192 \u2124`). (2) Define the lace expansion: express c_n as a perturbative series around the simple random walk. (3) For d \u2265 5, show the lace expansion converges, giving precise asymptotics. (4) The first step (\u03bc \u2248 2d-1) follows from elementary counting.\n\n**Domain Bridges**: Combinatorics <-> Analysis (perturbation theory) <-> Probability (random walks)\n\n**Lineage**: Generalizes the \u2124\u00b2 formalization from this cycle to arbitrary dimension.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 5: Tropical Self-Avoiding Walks\n\n**Conjecture**: There exists a meaningful \"tropical SAW count\" defined over the tropical semiring (\u211d \u222a {\u221e}, min, +) that encodes extremal properties of self-avoiding paths, and the tropical connective constant equals the logarithm of the classical connective constant: \u03bc_trop = log(\u03bc).\n\n**Test**: Define a tropical weight on SAW paths (e.g., the minimum total displacement or energy), compute the tropical generating function for small n, and check whether the tropical connective constant equals log(2.638...) \u2248 0.970.\n\n**Impact**: This would create a novel bridge between tropical geometry (well-developed in the Catalog) and SAW theory. If the tropical formulation simplifies certain aspects of SAW theory, it could provide new proof techniques for bounding \u03bc.\n\n**Catalog References**: `Tropical/` (tropical algebra infrastructure), `Computation/SelfAvoidingWalk/Basic.lean`\n\n**Proof Strategy**: (1) Define the tropical SAW weight as the min-plus analogue of the counting function: instead of counting walks, take the minimum over all walks of some cost function. (2) Show this satisfies a tropical analogue of submultiplicativity. (3) Prove tropical Fekete's lemma (min-plus subadditivity implies limit existence). (4) Relate the tropical and classical connective constants via the Maslov dequantization: as \u210f \u2192 0, the log of the classical partition function approaches the tropical one.\n\n**Domain Bridges**: Tropical Algebra <-> Combinatorics <-> Statistical Mechanics\n\n**Lineage**: Connects to existing Catalog tropical infrastructure.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Tropical"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "25b26084",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T14:17:22.411549+00:00"
  },
  {
    "id": "fd_0149",
    "title": "Formal mathematical chain connecting Smale h",
    "description": "# Future Directions: Curvature-Induced Computation\n\n## Synthesis\n\nThis research cycle established the formal mathematical chain connecting Smale horseshoe dynamics to computational universality: **horseshoe \u2192 full symbolic shift \u2192 Boolean function encoding**. The orbit realization theorem (Theorem 4.1) is the critical bridge \u2014 it shows that horseshoe dynamics can prescribe arbitrary symbolic itineraries, which we then exploit to encode computation. The entropy characterization (h = log d) provides a quantitative handle, and the sub-horseshoe construction shows that degree \u2265 2 suffices for universality.\n\nThe most promising cross-domain connection is between the **entropy/complexity interface** and the **Catalog's existing work on computational complexity** (e.g., `Computation/GravityOracle.lean`, `Computation/InfoEfficientAlgorithms.lean`). The geodesic oracle model (`IsGravOracle`, `GravTruthSet`) in the Catalog already formalizes computation via geometric oracles \u2014 our horseshoe universality result could provide the *mechanism* by which such oracles achieve their computational power. Bridging these would yield a unified theory of geometric computation.\n\nThe highest breakthrough potential lies in Direction 1 (Geometric Complexity Classes), which could establish a completely new complexity theory based on curvature, with natural connections to both circuit complexity (via the non-uniform encoding) and ergodic theory (via the entropy characterization).\n\n---\n\n### Direction 1: Geometric Complexity Classes via Horseshoe Degree\n\n**Conjecture**: For any Boolean function f : {0,1}^n \u2192 {0,1}, define its *geometric complexity* \u03b3(f) as the minimum horseshoe degree d such that f can be encoded by a degree-d horseshoe with read time at most n. Then:\n(a) \u03b3(PARITY_n) = 2 for all n (parity is geometrically easy).\n(b) There exists a family of functions {f_n} in P/poly with \u03b3(f_n) \u2192 \u221e (some polynomial-time functions are geometrically hard).\n(c) The class of functions with bounded geometric complexity is strictly contained in P/poly.\n\n**Test**: (a) Prove by explicit construction that a degree-2 horseshoe encodes PARITY using the word w(k) = input(k) for k < n and w(n) = \u2295input(k). For (b), candidate functions include majority or threshold functions \u2014 verify computationally that encoding MAJ_n requires horseshoe degree growing with n, or find an explicit degree-2 encoding.\n\n**Impact**: If true, geometric complexity would be a new complexity measure incomparable to circuit depth/size. Functions that are \"easy\" in Boolean complexity but \"hard\" geometrically (or vice versa) would reveal structural differences between sequential and dynamical computation. If false, the collapse \u03b3(f) = O(1) for all P/poly functions would mean horseshoe dynamics is polynomially equivalent to circuits.\n\n**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm), `Pythagorean/GeodesicComputation.lean` (horseshoe_encodes_boolean_function, horseshoe_universal)\n\n**Proof Strategy**: For (a), construct the word explicitly and apply horseshoe_orbit_realization. For (b), use a counting argument: the number of degree-d horseshoe encodings with read time n is at most d^(n+1), which for fixed d is exponential in n but smaller than the number of Boolean functions 2^(2^n). Formalize via Fintype.card bounds.\n\n**Domain Bridges**: Symbolic dynamics (horseshoe degree) \u2194 Circuit complexity (circuit size/depth) \u2194 Ergodic theory (topological entropy)\n\n**Lineage**: Builds on horseshoe_encodes_boolean_function and horseshoe_itinerary_count from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Uniform Universality via Markov Partitions\n\n**Conjecture**: There exists a compact hyperbolic surface \u03a3_g (genus g \u2265 2) and a Markov partition P of its geodesic flow such that the associated subshift of finite type (SFT) is *sofic universal* \u2014 meaning every sofic shift is a factor of the SFT. Consequently, the geodesic flow achieves *uniform* computational universality: a single partition encodes a universal Turing machine, with the input encoded in the initial condition and the computation proceeding via the flow.\n\n**Test**: For the modular surface SL(2,\u2124)\\\u210d, compute the transition matrix of the continued-fraction Markov partition and verify that the associated SFT has a topologically mixing component whose entropy exceeds log(2). Then show that any binary SFT embeds as a subsystem, which implies universality by the Krieger embedding theorem.\n\n**Impact**: Uniform universality would mean that a *fixed* geometric system (specific manifold + specific partition) simulates *all* Turing machines, not just individual Boolean functions. This would make the curvature-computation connection as strong as possible and connect to undecidability results (e.g., the orbit problem for the geodesic flow would be undecidable).\n\n**Catalog References**: `Pythagorean/GeodesicComputation.lean` (Horseshoe, horseshoe_orbit_realization), `Computation/GravityOracle.lean` (IsGravOracle)\n\n**Proof Strategy**: \n1. Formalize subshifts of finite type (transition matrix, forbidden words).\n2. Prove the Krieger embedding theorem: any SFT with entropy < log(d) embeds into the full d-shift.\n3. Show the modular surface's Markov partition has large enough entropy.\n4. Combine to get uniform universality.\n\n**Domain Bridges**: Hyperbolic geometry (modular surface) \u2194 Number theory (continued fractions) \u2194 Computability (universal TM simulation)\n\n**Lineage**: Extends the non-uniform universality of horseshoe_encodes_boolean_function to uniform universality.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Entropy-Curvature Duality for Horseshoe Degree\n\n**Conjecture**: For a compact Riemannian manifold (M, g) with sectional curvature K satisfying -b\u00b2 \u2264 K \u2264 -a\u00b2 < 0, the maximum horseshoe degree d_max of the time-1 geodesic flow map satisfies:\n\n    exp((dim M - 1) \u00b7 a) \u2264 d_max \u2264 exp(C(M) \u00b7 b)\n\nwhere C(M) depends only on the topology of M (e.g., its systole or first Betti number). In particular, d_max is determined up to polynomial factors by the curvature bounds.\n\n**Test**: Compute d_max for the geodesic flow on hyperbolic surfaces of genus g with constant curvature K = -1. By Gauss-Bonnet, Area(\u03a3_g) = 4\u03c0(g-1), and the entropy of the geodesic flow is 1. Verify that d_max grows with g (more topology \u2192 more horseshoes), and check the conjectured bounds against known entropy formulas.\n\n**Impact**: This would quantify the exact relationship between curvature and computational capacity, providing a \"curvature \u2194 entropy \u2194 computation\" dictionary. It would also yield new results in Riemannian geometry: curvature pinching conditions would directly imply bounds on symbolic complexity.\n\n**Catalog References**: `Pythagorean/GeodesicComputation.lean` (symbolicEntropy, entropy_mono, horseshoe_entropy_positive)\n\n**Proof Strategy**:\n1. Formalize Manning's entropy inequality h_top \u2265 (n-1)\u00b7a for K \u2264 -a\u00b2.\n2. Use Katok's horseshoe theorem: h_top > 0 implies horseshoes of degree \u2265 exp(h_top - \u03b5) for any \u03b5 > 0.\n3. For the upper bound, use Margulis's asymptotic formula for orbit counting.\n\n**Domain Bridges**: Riemannian geometry (curvature bounds) \u2194 Ergodic theory (entropy) \u2194 Symbolic dynamics (horseshoe degree)\n\n**Lineage**: Builds on entropy_equals_growth_rate and horseshoe_entropy_positive from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Tropical Horseshoes and Combinatorial Universality\n\n**Conjecture**: The *tropical horseshoe* \u2014 defined as a piecewise-linear map on a tropical polytope satisfying the crossing property with respect to tropical half-spaces \u2014 has a well-defined symbolic dynamics that is computationally universal. Moreover, the tropical entropy of a tropical horseshoe of degree d equals the tropical logarithm of d (i.e., d itself, since tropical log = identity).\n\n**Test**: Define a tropical horseshoe on the tropical torus \u211d\u00b2/\u2124\u00b2 with the tropical metric max(|x\u2081-y\u2081|, |x\u2082-y\u2082|). Construct explicit PL strips and verify the crossing property. Compute the number of distinct tropical geodesic itineraries of length n and verify it equals d^n.\n\n**Impact**: Tropical geometry provides a combinatorial/polyhedral shadow of classical geometry. If tropical horseshoes exhibit the same universality, it would:\n(a) Provide an entirely combinatorial proof of curvature \u2192 computation (avoiding analysis).\n(b) Connect to the Catalog's tropical algebraic work.\n(c) Yield explicit, computable examples testable by direct enumeration.\n\n**Catalog References**: `Tropical/TropicalEntropy.lean`, `Pythagorean/TropicalArithmeticUniversality.lean`, `Pythagorean/TropicalUniversality.lean`, `Pythagorean/GeodesicComputation.lean`\n\n**Proof Strategy**:\n1. Define TropicalHorseshoe as a specialization of Horseshoe with X = \u211d^n and PL dynamics.\n2. Verify that the orbit realization theorem applies (it does \u2014 it's purely set-theoretic).\n3. Construct explicit tropical horseshoes via PL maps on polytopes.\n4. Compute tropical entropy and compare to classical entropy.\n\n**Domain Bridges**: Tropical geometry (PL maps, polytopes) \u2194 Symbolic dynamics (horseshoe, shift) \u2194 Combinatorics (word enumeration)\n\n**Lineage**: Builds on Horseshoe definition and orbit realization from this cycle, connects to Catalog tropical theory.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Horseshoe Persistence Under Metric Perturbation\n\n**Conjecture**: Let (M, g\u2080) be a compact manifold with a horseshoe of degree d for the time-1 geodesic flow. There exists \u03b5 > 0 (depending on d and the curvature bounds of g\u2080) such that for any metric g with ||g - g\u2080||_{C\u00b2} < \u03b5, the geodesic flow of g also admits a horseshoe of degree d. Moreover, the symbolic dynamics of the perturbed horseshoe is topologically conjugate to the original.\n\n**Test**: For hyperbolic surfaces, compute the structural stability radius as a function of genus and curvature. Verify that small perturbations of the constant-curvature metric on \u03a3\u2082 preserve the horseshoe structure, using numerical geodesic flow integration.\n\n**Impact**: Structural stability of horseshoes under metric perturbation would mean that computational universality is a *robust* geometric property \u2014 not an artifact of special metrics. This connects to the broader question: is the computational capacity of a universe stable under small changes in the geometry?\n\n**Catalog References**: `Pythagorean/GeodesicComputation.lean` (Horseshoe, CurvatureComputationBridge)\n\n**Proof Strategy**:\n1. Use Smale's structural stability theorem for Axiom A flows.\n2. Verify that the geodesic flow on a negatively curved manifold satisfies Axiom A + no-cycle condition.\n3. Apply the persistence of homoclinic intersections under C\u00b9-small perturbations (Newhouse's theorem for the creation is not needed; Smale's theorem for preservation suffices).\n\n**Domain Bridges**: Riemannian geometry (metric perturbation) \u2194 Dynamical systems (structural stability) \u2194 Computational universality (robustness)\n\n**Lineage**: Builds on CurvatureComputationBridge from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "7298cf4c",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T14:17:43.811923+00:00"
  },
  {
    "id": "fd_0153",
    "title": "Algebraic foundations of Reflective Type The",
    "description": "# Future Directions: Reflective Type Theory\n\n## Synthesis\n\nThis research cycle established the algebraic foundations of Reflective Type Theory (ReflTT), proving that provability depth forms a tropical semiring homomorphism from the type algebra to (\u2115, max, +). The key results \u2014 the Depth-Complexity Gap Theorem, the strict axiom hierarchy (T \u2264 K < 4 \u2264 L\u00f6b), subject reduction for proof terms, and the bijective correspondence with the modal mu-calculus \u2014 together establish ReflTT as a rigorous framework for studying self-referential provability.\n\nThe most promising cross-domain connection is the bridge to tropical algebra. The Catalog contains extensive tropical geometry infrastructure (e.g., `discounted_tropical_has_fixed_point` in `MachineLearning/TropicalTimeTravel.lean`, `tropical_ctc_fixed_point_exists` in `MachineLearning/TropicalCTC.lean`), and our proof that the depth function is a tropical semiring homomorphism creates a direct pipeline for importing tropical fixed-point theorems into provability reasoning. The depth filtration also resembles a graded structure on a monoidal category, connecting to the categorical theorems in `EML/CategoryTheorems.lean`.\n\nThe highest breakthrough potential lies in Direction 1 (Full Subject Reduction), which would complete the metatheory of the proof term language and unlock the full propositions-as-types correspondence for provability. Direction 3 (Tropical Fixed-Point Transfer) is the most novel cross-domain bridge, potentially importing Banach-style fixed-point theorems from tropical analysis into provability logic. Direction 5 (Computational Depth Analysis) is the most immediately testable, providing concrete falsifiable predictions.\n\n---\n\n### Direction 1: Full Subject Reduction and Normalization for ReflTT\n\n**Conjecture**: The typing relation for ReflTT proof terms satisfies full subject reduction (well-typed terms reduce to well-typed terms under all reduction rules, including \u03b2-reduction with proper substitution) and weak normalization (every well-typed term without \u03bc-unfolding has a normal form), but NOT strong normalization due to the \u03bc/unfold interaction enabling infinite reduction sequences.\n\n**Test**: (a) Implement substitution for RTerm with de Bruijn indices and verify that \u03b2-reduction (app(lam(body), arg) \u2192 body[arg/0]) preserves typing. (b) Construct an explicit non-terminating reduction sequence using \u03bc and unfold. (c) Prove weak normalization for the \u03bc-free fragment by showing that type size strictly decreases under reduction.\n\n**Impact**: If subject reduction holds with substitution, ReflTT becomes a fully-fledged proof calculus, not just a type language. This would justify interpreting proof terms as actual proofs of provability statements. If weak normalization holds for the \u03bc-free fragment, it establishes decidability of type-checking for that fragment.\n\n**Catalog References**: `MachineLearning/ReflTTDepthAlgebra.lean` (subject_reduction_fst, subject_reduction_snd, subject_reduction_fold_unfold)\n\n**Proof Strategy**: \n1. Define substitution `subst : RTerm \u2192 \u2115 \u2192 RTerm \u2192 RTerm` with proper de Bruijn index shifting.\n2. Prove a substitution lemma: if Typing (A :: \u0393) body B and Typing \u0393 arg A, then Typing \u0393 (subst body 0 arg) B.\n3. Extend the Reduces relation with \u03b2-reduction.\n4. Prove subject reduction by case analysis on the reduction rule.\n5. For weak normalization, define a size measure on typed terms and show it decreases under reduction in the \u03bc-free fragment.\n\n**Domain Bridges**: Type theory <-> proof theory <-> computability theory\n\n**Lineage**: Extends subject_reduction_fst, subject_reduction_snd, subject_reduction_fold_unfold from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Depth Algebra as Graded Monad\n\n**Conjecture**: The depth filtration F_0 \u2286 F_1 \u2286 F_2 \u2286 ... can be organized as a graded monad on the category of types, where the grading monoid is (\u2115, +, 0), the unit \u03b7_A : A \u2192 F_0(A) embeds MLTT types into the filtration, and the multiplication \u03bc_{m,n} : F_m(F_n(A)) \u2192 F_{m+n}(A) corresponds to iterBox_add (\u25a1^m(\u25a1^n(A)) = \u25a1^(m+n)(A)).\n\n**Test**: (a) Define a functor F_n : RType \u2192 Set RType mapping each type to the set of types at depth \u2264 n that contain it as a subexpression. (b) Verify the monad laws (unit, associativity) hold for iterBox. (c) Check whether the Kleisli category of this monad has interesting structure.\n\n**Impact**: If ReflTT forms a graded monad, it connects to the rich categorical semantics literature (e.g., graded monads for computational effects). This would provide categorical tools for reasoning about depth \u2014 e.g., the depth of a composition could be computed from the depths of its parts using the graded monad structure.\n\n**Catalog References**: `EML/CategoryTheorems.lean`, `iterBox_add` and `iterBox_depth` from `MachineLearning/ReflTTDepthAlgebra.lean`\n\n**Proof Strategy**:\n1. Define a category whose objects are RTypes and morphisms are depth-bounded type transformations.\n2. Show iterBox satisfies the graded monad laws: \u03b7 \u226b \u03bc = id, \u03bc \u226b \u03bc = \u03bc \u226b F(\u03bc).\n3. The key lemma is iterBox_add, which already provides the multiplication law.\n4. Use Mathlib's category theory library to formalize the graded monad structure.\n\n**Domain Bridges**: Type theory <-> category theory <-> algebraic topology (graded structures)\n\n**Lineage**: Builds on iterBox_add, iterBox_depth, tower_injective from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Tropical Fixed-Point Transfer to Provability\n\n**Conjecture**: The tropical fixed-point theorems in the Catalog (e.g., `discounted_tropical_has_fixed_point`) can be transferred, via the depth homomorphism, to fixed-point theorems about provability depth. Specifically, if f : \u2115 \u2192 \u2115 is a contraction mapping in the tropical metric (d_trop(x,y) = |max(x,c) - max(y,c)|) and f arises from a type-forming operation, then the corresponding type operation has a fixed-depth point.\n\n**Test**: (a) Define a \"type-level contraction\" as a function F : RType \u2192 RType satisfying |d(F(A)) - d(F(B))| \u2264 \u03b1 \u00b7 |d(A) - d(B)| for some \u03b1 < 1. (b) Show that \u03bc-types, when the body has bounded box-depth increase, satisfy this contraction property. (c) Use the tropical fixed-point theorem to derive a bound on the fixed-point depth.\n\n**Impact**: This would be the first formal bridge between tropical analysis and provability logic. It would allow importing quantitative fixed-point bounds from tropical geometry into type-theoretic reasoning, potentially giving tight depth bounds for recursive provability definitions.\n\n**Catalog References**: `FINAL/MachineLearning/TropicalTimeTravel.lean` (discounted_tropical_has_fixed_point), `FINAL/MachineLearning/TropicalCTC.lean` (tropical_ctc_fixed_point_exists), `depth_tropical_factorization` from this cycle\n\n**Proof Strategy**:\n1. Formalize a tropical metric on provability depths.\n2. Define \"depth-contractive\" type operations and show \u03bc can produce them.\n3. Apply the existing tropical fixed-point theorems via the depth homomorphism.\n4. The key step is showing that the depth homomorphism is continuous in the tropical metric.\n\n**Domain Bridges**: Tropical geometry <-> provability logic <-> fixed-point theory\n\n**Lineage**: Builds on depth_tropical_factorization, and Catalog theorems discounted_tropical_has_fixed_point, tropical_ctc_fixed_point_exists.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Decidability of Depth-Bounded Type Inhabitation\n\n**Conjecture**: The type inhabitation problem for ReflTT restricted to types of depth \u2264 k is decidable for each fixed k, but the complexity grows non-elementarily in k. Specifically, for depth 0 (MLTT fragment), inhabitation is PSPACE-complete; for depth 1, it is EXPTIME-complete; and for each additional depth level, the complexity class increases by one exponential.\n\n**Test**: (a) Implement an enumeration algorithm for closed terms of bounded size and depth. (b) Test inhabitation for specific types at depths 0, 1, 2 by brute-force enumeration. (c) Prove that depth-0 inhabitation reduces to propositional logic (known PSPACE-complete).\n\n**Impact**: If the complexity hierarchy is strict, it provides a precise computational characterization of the \"cost of reflection\" \u2014 each additional level of meta-reasoning adds exactly one exponential of computational difficulty.\n\n**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm), `MachineLearning/ReflTTDepthAlgebra.lean` (iterBox_unit_minimal, depth_complexity_lower_bound)\n\n**Proof Strategy**:\n1. Show that depth-0 inhabitation is equivalent to intuitionistic propositional logic (well-known PSPACE-complete).\n2. Show that depth-1 inhabitation can simulate one level of quantifier alternation, connecting to EXPTIME.\n3. Use the depth filtration to show that each level strictly increases the class of expressible problems.\n\n**Domain Bridges**: Computability theory <-> type theory <-> complexity theory\n\n**Lineage**: Builds on mltt_depth_zero, depth_complexity_lower_bound from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Computational Validation of the Proof Depth Gap Conjecture\n\n**Conjecture**: For all n \u2264 5 and all well-typed closed terms t of type \u25a1^n(\u22a4), the boxI-depth of t equals exactly n.\n\n**Test**: (a) Write a Lean function that enumerates all closed RTerm values of bounded size. (b) Filter for those that are well-typed at type \u25a1^n(\u22a4). (c) Verify that all such terms have boxI-depth \u2265 n. (d) For n = 1, 2, 3, this should be computationally feasible (the number of small terms is manageable).\n\n**Impact**: If the conjecture holds computationally for n \u2264 5, it strongly supports the general conjecture and motivates a full inductive proof. If a counterexample is found, it would reveal an unexpected interaction between typing rules and term structure, pointing to a subtlety in the boxI rule.\n\n**Catalog References**: `MachineLearning/ReflTTDepthAlgebra.lean` (boxI_depth_pos, boxI_typed_depth, RTerm.boxIDepth)\n\n**Proof Strategy**:\n1. Define a decidable type-checking function for RTerm (possible since all types are decidably equal and context lookup is computable).\n2. Enumerate terms up to size 10 at each depth level.\n3. Use `#eval` in Lean to run the computation.\n4. If successful, attempt to generalize to an inductive proof using the structure of the typing derivation.\n\n**Domain Bridges**: Computability <-> type theory <-> combinatorics (term enumeration)\n\n**Lineage**: Builds on boxI_depth_pos, boxI_typed_depth from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Logic"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "892c306f",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T14:52:14.469364+00:00"
  },
  {
    "id": "fd_0154",
    "title": "Rigorous bridge between algebraic linear algebra and tr",
    "description": "# Future Directions\n\n## Synthesis\n\nThis cycle established a rigorous bridge between algebraic linear algebra and tropical convex geometry via the tropical valuation functor. The central discovery is that the p-adic valuation \u2014 viewed as a map from a commutative semiring to the extended naturals \u2014 satisfies precisely the axioms needed to transport algebraic linear combinations into tropical convex hull membership. The bridge theorem (Theorem 5.5 / `valuation_bridge_tropical_hull_mem`) is constructive: the tropical coefficients are the valuations of the algebraic coefficients, providing an algorithmic pipeline from coefficient data to tropical certificates.\n\nThe most promising cross-domain connection is between this valuation bridge and the existing tropical Helly theorem in the Catalog (`Speculative/AutoResearch/TropicalHelly.lean`). The Helly theorem provides intersection properties of tropical convex sets, while our bridge provides a systematic way to *produce* points in tropical convex hulls from algebraic data. Composing these two results would yield a powerful tool: given algebraic inequalities on coefficients, one could derive combinatorial intersection properties of the resulting tropical point sets, connecting number-theoretic divisibility conditions to finite-dimensional optimization bounds.\n\nThe highest breakthrough potential lies in Direction 1 (Tropical Newton Polygon Bridge), because it would connect the valuation functor to classical algebraic geometry through Newton polygons, potentially yielding new algorithms for polynomial root counting via tropical certificates. This is tractable because Newton polygon theory is well-developed and many key results exist in Mathlib's polynomial API.\n\n---\n\n### Direction 1: Tropical Newton Polygon Bridge\n\n**Conjecture**: For a polynomial f(x) = \u2211 a\u1d62x\u2071 \u2208 \u2124[x] and a prime p, the lower convex hull of the points {(i, v\u209a(a\u1d62))} in \u211d\u00b2 equals the tropical curve defined by the tropicalization of f under the p-adic valuation. Moreover, the slopes of this Newton polygon determine the p-adic valuations of the roots of f, counted with multiplicity (a formalization of the classical Newton polygon theorem).\n\n**Test**: For f(x) = x\u00b3 + 6x\u00b2 + 12x + 8 = (x+2)\u00b3 and p=2, compute the Newton polygon of {(0, v\u2082(8)), (1, v\u2082(12)), (2, v\u2082(6)), (3, v\u2082(1))} = {(0,3), (1,2), (2,1), (3,0)}. The unique slope is -1, predicting all roots have v\u2082 = 1. Indeed v\u2082(2) = 1, confirming. Test with f(x) = x\u00b2 - 5 for p=5 to check a non-trivial case.\n\n**Impact**: If formalized, this would connect the tropical valuation functor to classical algebraic geometry and Hensel's lemma, providing a computational pipeline from polynomial coefficients to root valuation bounds. It would also connect to Puiseux series and the theory of tropical varieties.\n\n**Catalog References**: `Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean` (the `TropicalValuation` structure and `padicTropicalValuation`), Mathlib's `Polynomial.roots`, `padicValNat`.\n\n**Proof Strategy**: \n1. Define the Newton polygon of a polynomial as the lower convex hull of {(i, v(a\u1d62))}.\n2. Prove that the slopes are non-increasing using convexity.\n3. Use Hensel's lemma (available in Mathlib for p-adic numbers) to show each slope segment of length m corresponds to m roots with that p-adic valuation.\n4. Key lemma: the tropicalization of f is the tropical polynomial trop(f)(x) = min_i(v(a\u1d62) + i\u00b7x), and its \"roots\" (points of non-differentiability) correspond to Newton polygon slopes.\n\n**Domain Bridges**: Algebra (polynomial ring theory) \u2194 Tropical Geometry (tropical curves) \u2194 Number Theory (p-adic analysis, Hensel's lemma)\n\n**Lineage**: Builds on the `TropicalValuation` structure and `padicTropicalValuation` from this cycle. Extends the coordinatewise valuation to polynomial coefficients.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Tropical Surjectivity and Lattice Gaps\n\n**Conjecture**: The tropical surjectivity conjecture (`tropVal_surjective_hull_conjecture`) is FALSE in general. Specifically, for p=2, n=2, k=2, and generators x\u2081 = (1,0), x\u2082 = (0,1), the point y = (1,1) lies in the tropical convex hull of {(v\u2082(1), v\u2082(0)), (v\u2082(0), v\u2082(1))} = {(0,\u22a4), (\u22a4,0)} but is NOT the coordinatewise valuation of any \u2115-linear combination c\u2081(1,0) + c\u2082(0,1) = (c\u2081, c\u2082). However, the conjecture IS true when restricted to generators with all entries being powers of p.\n\n**Test**: Enumerate v\u2082(c\u2081, c\u2082) for c\u2081, c\u2082 \u2208 {0,...,1000}. The achievable valuation pairs are {(v\u2082(c\u2081), v\u2082(c\u2082)) : c\u2081,c\u2082 \u2208 \u2115} = {(a,b) : a,b \u2208 \u2115\u221e} (all pairs). Now compare to the tropical hull. For the standard basis generators, the tropical hull is all of (\u2115\u221e)\u00b2, so surjectivity holds trivially. Test with generators (2,3), (4,6) to find a non-trivial counterexample.\n\n**Impact**: Characterizing when surjectivity holds would determine when tropical certificates can be \"lifted\" back to algebraic witnesses \u2014 essential for using tropical methods in lattice cryptanalysis. A precise characterization theorem would be a significant contribution to tropical convexity theory.\n\n**Catalog References**: `Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean` (`tropVal_surjective_hull_conjecture`, `tropConvHull`), `Speculative/AutoResearch/TropicalHelly.lean` (`tropConvexHull`).\n\n**Proof Strategy**:\n1. Construct an explicit counterexample by finding generators whose tropical hull contains unreachable points.\n2. Identify the obstruction: it should relate to \"tropical rank\" or \"tropical linear dependence.\"\n3. Prove surjectivity under the p-power hypothesis using the structure theorem for p-adic integers.\n4. Formalize the characterization: surjectivity holds iff the generators satisfy a \"tropical independence\" condition.\n\n**Domain Bridges**: Tropical Geometry (convex hulls) \u2194 Cryptography (lattice problems, LWE) \u2194 Algebra (p-adic analysis)\n\n**Lineage**: Directly tests the falsifiable conjecture stated in this cycle's Lean formalization.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Tropical Helly\u2013Valuation Composition\n\n**Conjecture**: Composing the tropical valuation bridge with the tropical Helly theorem yields a finite intersection theorem for algebraic solution sets. Specifically: if algebraic solution sets S\u2081,...,S\u2098 in \u2115\u207f have the property that every (n+1)-element subfamily has non-empty intersection of their tropical valuation images, then the intersection of all tropical valuation images is non-empty.\n\n**Test**: Take p=2, n=2 (so Helly number = n+1 = 3). Define three sets S\u2081, S\u2082, S\u2083 \u2282 \u2115\u00b2 as solution sets of simple divisibility conditions. Compute their tropical (v\u2082) images. Verify that pairwise intersection of images is non-empty, but triple intersection may or may not be. The Helly-type theorem would predict that if all triples intersect, all four-wise intersections do too.\n\n**Impact**: This would give a finite combinatorial condition (checkable in polynomial time) for the existence of solutions to systems of divisibility constraints \u2014 a problem that arises naturally in cryptanalysis and coding theory.\n\n**Catalog References**: `Speculative/AutoResearch/TropicalHelly.lean` (`tropical_helly`, `IsTropConvex`, `tropConvexHull`), `Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean` (`coordVal`, `tropConvHull`).\n\n**Proof Strategy**:\n1. Verify that valuation images of algebraic sets are tropically convex (this requires checking the sets are closed under the relevant algebraic operations).\n2. Apply the tropical Helly theorem from the Catalog.\n3. Lift the tropical intersection back to the algebraic setting using the bridge theorem.\n4. Key difficulty: the valuation images may not be tropically convex in general, so identify sufficient conditions on the algebraic sets.\n\n**Domain Bridges**: Combinatorics (Helly-type theorems) \u2194 Tropical Geometry (tropical convexity) \u2194 Algebra (divisibility) \u2194 Cryptography (lattice problems)\n\n**Lineage**: Composes the bridge theorem from this cycle with the tropical Helly theorem already in the Catalog.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Tropical Valuation for Neural Network Depth Certification\n\n**Conjecture**: The tropical valuation of the Lipschitz constant product \u220f L\u1d62 of an n-layer neural network, expressed as a sum \u2211 v\u209a(L\u1d62) in tropical algebra, provides a tighter robustness certificate than the naive product bound when the Lipschitz constants have shared prime factors. Specifically, if all L\u1d62 are powers of a single prime p, then the tropical depth \u2211 v\u209a(L\u1d62) grows linearly while the product L\u207f grows exponentially, and the valuation bridge provides robustness certificates of quality O(n) rather than O(p\u207f).\n\n**Test**: Take a 10-layer network with Lipschitz constants all equal to L = 2. The naive bound gives 2\u00b9\u2070 = 1024. The tropical depth gives v\u2082(2\u00b9\u2070) = 10. Compare the information content: if the input perturbation is \u03b4, the tropical certificate says the output perturbation has v\u2082 \u2265 v\u2082(\u03b4) + 10, which is a much more refined bound than just \"output perturbation \u2264 1024\u03b4.\"\n\n**Impact**: This would provide a new class of robustness certificates for neural networks based on number-theoretic structure of the weights, complementing existing Lipschitz-based approaches with tropical-algebraic refinements.\n\n**Catalog References**: `Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean` (`LipschitzCompositionChain`, `tropVal_prod`), `FINAL/Bridges/ActivationNerveMarginCosheaf.lean` (robustness certificates).\n\n**Proof Strategy**:\n1. Apply `tropVal_prod` to the Lipschitz chain to get \u2211 v\u209a(L\u1d62).\n2. Show that this tropical sum provides divisibility constraints on the output perturbation.\n3. Prove that for p-power Lipschitz constants, the tropical certificate is exponentially tighter.\n4. Connect to the activation nerve cosheaf framework for local-to-global certificate composition.\n\n**Domain Bridges**: Machine Learning (neural network robustness) \u2194 Tropical Geometry (tropical products) \u2194 Number Theory (p-adic valuations)\n\n**Lineage**: Extends the `tropVal_prod` theorem from this cycle and connects to the robustness certification framework in `FINAL/Bridges/ActivationNerveMarginCosheaf.lean`.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Tropical Valuation on Polynomial Rings and Tropical Varieties\n\n**Conjecture**: The tropical valuation functor extends canonically to polynomial rings R[x] via the \"minimum coefficient valuation\": for f = \u2211 a\u1d62x\u2071, define V(f) = min_i v(a\u1d62). This extension V : R[x] \u2192 \u2115\u221e satisfies the tropical valuation axioms (with appropriate modifications for the polynomial ring structure), and the tropical variety of f (defined as the set of x where the minimum is achieved at least twice) corresponds to the set of slopes of the Newton polygon.\n\n**Test**: For f = 2x\u00b2 + 3x + 4 \u2208 \u2124[x] with p=2: v\u2082(2)=1, v\u2082(3)=0, v\u2082(4)=2. The minimum coefficient valuation is V(f) = 0. The Newton polygon has vertices at (0,2), (1,0), (2,1), with slopes -2 and 1. The tropical variety should be {-2, 1}. Verify by direct computation.\n\n**Impact**: This would give a functorial framework for computing tropical varieties algorithmically, connecting polynomial arithmetic to tropical geometry through a single valuation map.\n\n**Catalog References**: `Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean` (`TropicalValuation`), Mathlib's `Polynomial`, `MvPolynomial`.\n\n**Proof Strategy**:\n1. Define V(f) = inf_i v(a\u1d62) and verify the tropical valuation axioms.\n2. Show V(f\u00b7g) = V(f) + V(g) using the iterated ultrametric inequality and careful analysis of the product's coefficients.\n3. Define the tropical variety as {x : trop(f)(x) is achieved by \u2265 2 terms} and connect to Newton polygon slopes.\n4. Key difficulty: V(f+g) \u2265 min(V(f), V(g)) requires careful handling of coefficient cancellation.\n\n**Domain Bridges**: Algebra (polynomial rings) \u2194 Tropical Geometry (tropical varieties) \u2194 Algebraic Geometry (Newton polygons)\n\n**Lineage**: Natural extension of the `TropicalValuation` structure to more complex algebraic objects.\n\n**Ambition**: extension\n",
    "domains": [
      "Pythagorean",
      "Algebra"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "5392c445",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T14:52:33.758423+00:00"
  },
  {
    "id": "fd_0156",
    "title": "Formal algebraic foundation for recipe subst",
    "description": "# Future Research Directions: Culinary Homotopy and Substitution Algebras\n\n## Synthesis\n\nThis research cycle established the formal algebraic foundation for recipe substitution spaces by proving ten structural theorems about the Hamming graph H(n,m) in the culinary context. The key discoveries are: (1) the sharp dichotomy between triangle-free behavior (m=2, binary choices) and triangle-rich behavior (m\u22653), which reveals how the *number* of available ingredient options fundamentally determines the topology of recipe space; (2) the slot independence theorem for additive flavor maps, which provides a decomposition principle reducing exponential-complexity recipe optimization to linear-complexity per-slot optimization; and (3) vertex transitivity via translation, establishing that recipe space has no privileged \"base recipe.\"\n\nThe most promising cross-domain connection is between the substitution graph and error-correcting codes. A \"cuisine\" \u2014 a carefully curated set of recipes \u2014 can be viewed as a code in H(n,m), and the coding-theoretic notions of minimum distance, covering radius, and packing radius translate directly into culinary concepts: how different must recipes be to count as \"distinct dishes,\" how many substitutions to reach any desired flavor from a fixed repertoire, and how densely can a cuisine pack recipes without confusion. The existing Catalog work on algebraic circuits (`Algebra/AlgebraicCircuitComplexity.lean`) and tropical geometry (`Algebra/TropicalDragon.lean`) may connect via the algebraic structure of the Hamming association scheme.\n\nThe highest breakthrough potential lies in Direction 1 (Fiber Connectivity Conjecture), because a positive result would enable efficient computational recipe generation via connected-path algorithms, while a negative result would reveal unexpected obstructions to continuous recipe adaptation \u2014 both outcomes with immediate practical implications.\n\n---\n\n### Direction 1: Fiber Connectivity of Additive Flavor Maps\n\n**Conjecture**: For a \"generic\" additive flavor map A : AdditiveFlavorMap(n, m, d) with d < n and m \u2265 2, every nonempty flavor fiber (the set of recipes producing a given flavor profile) is connected in the substitution graph SubstGraph(n, m). Here \"generic\" means the per-slot contribution vectors {A.contrib(i, v, \u00b7) | v \u2208 Fin m} are in general position (no unexpected linear dependencies across slots).\n\n**Mathematical context**: An additive flavor map assigns to each recipe r a flavor profile A.eval(r, k) = \u03a3\u1d62 A.contrib(i, r(i), k). A fiber is connected if any two recipes with the same flavor profile can be linked by a sequence of single-ingredient substitutions, each preserving the flavor. This is equivalent to asking whether the \"flavor-preserving substitution graph\" (the subgraph of SubstGraph restricted to a fiber) is connected.\n\n**Test**: For n = 5, m = 3, d = 2, generate 10,000 random additive flavor maps (sampling contrib values uniformly from [0,1]). For each, enumerate all m^n = 243 recipes, group into fibers, and check connectivity of each fiber in SubstGraph. If any fiber is disconnected, the conjecture is falsified. Record the fraction of connected fibers as a function of d/n.\n\n**Impact**: If true, this guarantees that recipe adaptation is always possible through incremental substitutions \u2014 a cook can always transform one recipe into another with the same flavor by changing one ingredient at a time. This would enable efficient gradient-free recipe optimization algorithms. If false, it identifies \"flavor barriers\" \u2014 sets of substitutions that cannot be achieved incrementally, requiring simultaneous multi-ingredient changes.\n\n**Catalog References**: `Algebra/RecipeHomotopy.lean` (slot_independence, SubstGraph), `MachineLearning/CulinaryHomotopy/Basic.lean` (FlavorMap, flavorFiber)\n\n**Proof Strategy**: For the positive direction, try induction on the number of differing slots k = hdist(r\u2081, r\u2082). For k = 1, the two recipes are adjacent and in the same fiber, so they're connected. For k > 1, find an intermediate recipe r' with hdist(r\u2081, r') = 1, hdist(r', r\u2082) = k-1, and A.eval(r') = A.eval(r\u2081). This requires solving A.contrib(i, v, \u00b7) = A.contrib(i, r\u2081(i), \u00b7) for some v \u2260 r\u2081(i) at some slot i, which the genericity condition should guarantee.\n\n**Domain Bridges**: Coding theory (error-correcting codes on Hamming graphs) \u2194 Culinary science (recipe adaptation) \u2194 Combinatorial optimization (fiber connectivity in product graphs)\n\n**Lineage**: Builds on slot_independence and translate_preserves_hdist from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: The Culinary Association Scheme and Spectral Analysis\n\n**Conjecture**: The eigenvalues of the adjacency matrix of SubstGraph(n, m) restricted to a flavor fiber F determine the mixing time of the \"random substitution walk\" on F. Specifically, if \u03bb\u2081 \u2265 \u03bb\u2082 \u2265 ... are the eigenvalues of the fiber's adjacency matrix, then the mixing time is \u0398(log|F| / (1 - \u03bb\u2082/\u03bb\u2081)).\n\n**Mathematical context**: The full Hamming graph H(n,m) has a well-known eigenvalue spectrum given by the Krawtchouk polynomials: \u03bb\u2096 = (m-1)n - mk for k = 0,1,...,n, with multiplicity C(n,k)(m-1)^k. When restricting to a flavor fiber, the spectrum changes, and the question is how the fiber structure affects the spectral gap.\n\n**Test**: For n = 4, m = 3, d = 1, compute the adjacency matrix of SubstGraph restricted to each fiber of 100 random additive flavor maps. Compute eigenvalues and compare mixing times predicted by the spectral gap with actual mixing times from random walk simulations.\n\n**Impact**: Would provide theoretical guarantees for random recipe exploration algorithms \u2014 how many random substitutions are needed to \"explore\" the full set of recipes with a given flavor profile.\n\n**Catalog References**: `Algebra/RecipeHomotopy.lean` (SubstGraph, spectrumCount, spectrum_sum)\n\n**Proof Strategy**: Use the association scheme structure of the Hamming graph. The fiber restriction can be analyzed via the projection of Krawtchouk polynomials onto the fiber's characteristic function. The spectral gap bound follows from standard Markov chain theory.\n\n**Domain Bridges**: Association schemes (algebraic combinatorics) \u2194 Markov chain mixing (probability) \u2194 Recipe exploration (culinary optimization)\n\n**Lineage**: Builds on spectrum_sum and recipe_card from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Nonlinear Flavor Maps and Interaction Tensors\n\n**Conjecture**: For a flavor map with pairwise interactions (F(r) = \u03a3\u1d62 a\u1d62(r\u1d62) + \u03a3\u1d62<\u2c7c b\u1d62\u2c7c(r\u1d62, r\u2c7c)), the slot independence theorem generalizes to: changing slot i affects the flavor by a\u1d62(v) - a\u1d62(r\u1d62) + \u03a3\u2c7c\u2260\u1d62 [b\u1d62\u2c7c(v, r\u2c7c) - b\u1d62\u2c7c(r\u1d62, r\u2c7c)]. Moreover, the number of \"effective degrees of freedom\" in a fiber is determined by the rank of the interaction tensor.\n\n**Mathematical context**: The additive flavor map is a first-order approximation. Real cooking involves substantial ingredient interactions: sugar and protein undergo Maillard reactions, acid affects gluten development, fat mediates volatile compound release. A pairwise interaction model captures the leading-order nonlinearity. The interaction tensor b : (Fin n \u00d7 Fin n) \u2192 (Fin m \u00d7 Fin m) \u2192 (Fin d \u2192 \u211d) encodes these pairwise effects.\n\n**Test**: Formalize the pairwise flavor map in Lean 4 and prove the generalized slot independence theorem. Then compute, for n = 4, m = 3, d = 2, the average fiber size and connectivity as a function of the interaction strength \u2016b\u2016/\u2016a\u2016.\n\n**Impact**: Would extend the mathematical framework from the idealized additive case to a physically more realistic model, capturing ingredient synergies and antagonisms. The rank of the interaction tensor would provide a measure of \"culinary complexity.\"\n\n**Catalog References**: `Algebra/RecipeHomotopy.lean` (AdditiveFlavorMap, slot_independence)\n\n**Proof Strategy**: Define `PairwiseFlavorMap` as a structure with linear and quadratic contributions. The generalized independence theorem follows by the same summation argument as slot_independence, but with additional terms from the interaction matrix. The key lemma is that changing slot i only affects terms involving index i.\n\n**Domain Bridges**: Tensor decomposition (multilinear algebra) \u2194 Flavor chemistry (food science) \u2194 ANOVA models (statistics)\n\n**Lineage**: Directly extends slot_independence from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Homotopy Type of the Recipe Clique Complex\n\n**Conjecture**: The clique complex of SubstGraph(n, m) (the simplicial complex whose k-simplices are (k+1)-cliques) is homotopy equivalent to a wedge of spheres. For m = 2, it has the homotopy type of the (n-1)-sphere (since the clique complex of the hypercube graph is the boundary of the cross-polytope). For m \u2265 3, the homotopy type has non-trivial higher homology determined by the K\u00fcnneth formula applied to the product structure of H(n,m).\n\n**Mathematical context**: The substitution graph SubstGraph(n,m) is the Hamming graph H(n,m), which is the Cartesian product of n copies of the complete graph K_m. The clique complex of K_m is the (m-1)-simplex \u0394^{m-1}. The clique complex of a Cartesian product of graphs is related to (but not equal to) the product of the clique complexes, and the precise relationship involves the tensor product of simplicial sets.\n\n**Test**: For small cases (n \u2264 4, m \u2264 4), compute the homology groups of the clique complex of H(n,m) using computational algebraic topology software (e.g., GUDHI or Ripser). Compare with predictions from the K\u00fcnneth formula.\n\n**Impact**: Would establish the precise homotopy type of recipe space, connecting the combinatorial structure of ingredient substitution to algebraic topology. The fundamental group \u03c0\u2081 would classify \"recipe loops\" \u2014 sequences of substitutions that return to the starting recipe \u2014 up to continuous deformation.\n\n**Catalog References**: `Algebra/RecipeHomotopy.lean` (SubstGraph, triangle_free_m2, triangle_exists_m3, four_cycle_exists)\n\n**Proof Strategy**: For m = 2, the clique complex of the hypercube Q_n is known. Each edge corresponds to a single bit flip, and the maximal cliques are edges (since Q_n is triangle-free). So the clique complex is just Q_n itself as a 1-dimensional simplicial complex, whose fundamental group is the free group on n(n-1)/2 generators (the independent 4-cycles). For m \u2265 3, use the product structure and K\u00fcnneth theorem.\n\n**Domain Bridges**: Algebraic topology (homotopy groups of simplicial complexes) \u2194 Graph theory (clique complexes of Hamming graphs) \u2194 Culinary science (recipe loop classification)\n\n**Lineage**: Builds on triangle_free_m2, triangle_exists_m3, and four_cycle_exists from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 5: Optimal Cuisine Design via Coding Theory\n\n**Conjecture**: The maximum number of recipes in a \"cuisine\" (a subset of Recipe(n,m)) such that no two recipes have Hamming distance less than d is given by the Singleton bound m^{n-d+1}, and this bound is achieved by MDS (maximum distance separable) cuisines analogous to Reed-Solomon codes.\n\n**Mathematical context**: In coding theory, an [n, k, d]_m code is a subset of (Fin m)^n with m^k elements and minimum Hamming distance d. The Singleton bound states m^k \u2264 m^{n-d+1}. MDS codes achieve this bound with equality. Translating to the culinary context: a \"d-separated cuisine\" is a collection of recipes where any two differ in at least d ingredient slots. The Singleton bound limits how many recipes can be in such a cuisine.\n\n**Test**: For n = 6, m = 4, d = 3, enumerate all maximal d-separated cuisines and verify whether any achieve the Singleton bound m^{n-d+1} = 4^4 = 256. Compare with known MDS code constructions (Reed-Solomon codes exist for m = prime power).\n\n**Impact**: Would provide principled guidelines for designing recipe collections (cookbooks) where every recipe is \"sufficiently different\" from every other, avoiding redundancy. The MDS construction would give explicit cookbook designs.\n\n**Catalog References**: `Algebra/RecipeHomotopy.lean` (SubstGraph, hdist_triangle, spectrum_sum), `Algebra/CodingTheory/Defs.lean`\n\n**Proof Strategy**: The Singleton bound follows from a standard pigeonhole argument on coordinate projections. Prove that projecting an [n,k,d]_m code onto any n-d+1 coordinates gives an injective map, hence m^k \u2264 m^{n-d+1}. For MDS construction, use the Reed-Solomon approach: identify Fin m with a finite field (when m is a prime power) and use polynomial evaluation codes.\n\n**Domain Bridges**: Coding theory (error-correcting codes) \u2194 Culinary science (cookbook design) \u2194 Finite geometry (MDS codes and arcs)\n\n**Lineage**: Builds on recipe_card and spectrum_sum from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "priority_score": 1.0,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "e174af4c",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T15:27:45.189603+00:00"
  },
  {
    "id": "fd_0093",
    "title": "The Geometry of Consensus: Arrow's Theorem as Curvature",
    "description": "Arrow's impossibility theorem states that no ranked voting system with 3+ alternatives can be Pareto efficient, non-dictatorial, and independent of irrelevant alternatives (IIA). Conjecture: Arrow's theorem is a curvature statement. The space of preference profiles is a Riemannian manifold M with the Fisher information metric. The social welfare function F: M -> M is a mapping from profiles to social preferences. Arrow's conditions translate to geometric conditions: (1) Pareto efficiency means F preserves the direction of unanimous preference (F is 'forward-looking'). (2) IIA means F is a local mapping (the social preference at x depends only on local information near x). (3) Non-dictatorial means F is not a projection onto a single voter's preference. Conjecture: the only smooth, local, forward-looking maps on a positively curved manifold are projections (dictatorships). This is because a positively curved manifold has the property that parallel transport around a small loop rotates vectors (Holonomy), and a local, forward-looking map must preserve this holonomy, which forces it to be a projection. Conjecture: the curvature of the preference space is related to the 'polarization' of the electorate: when preferences are polarized (bimodal), the curvature is positive (sphere-like), and Arrow's theorem applies. When preferences are unimodal (consensus), the curvature is zero (flat), and majority rule works. Test: compute the curvature of the preference space for synthetic election data and verify the connection to Arrow's theorem. Impact: Arrow's impossibility is a theorem of differential geometry. Voting is curved.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.9999999999999999,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.814374+00:00"
  },
  {
    "id": "fd_0003",
    "title": "Zero-Knowledge Theorem Proving: I Can Prove Fermat's Last Theorem Without Showing You the Proof",
    "description": "Zero-knowledge proofs let you convince someone a statement is true without revealing WHY. Apply this to mathematics: a zero-knowledge proof of a theorem T convinces the verifier that T is provable in PA without revealing any step of the proof. Conjecture: Every theorem provable in Peano Arithmetic has a zero-knowledge proof whose communication complexity is polynomial in the length of the theorem statement (not the proof). This follows from the PCP theorem combined with the fact that PA-proofs can be arithmetized. The zero-knowledge protocol: (1) Prover commits to each proof step using a collision-resistant hash. (2) Verifier randomly challenges one proof step. (3) Prover opens that step and shows it follows from the axioms. Repeating O(k) times gives soundness error 2^{-k}. The proof is zero-knowledge because the verifier only sees one random step per challenge. Test: implement a zero-knowledge proof system for propositional tautologies and prove that a verifier learns nothing beyond the validity of the tautology. Impact: mathematicians can certify results without revealing their methods \u2014 a mathematical equivalent of sealed-bid auctions for proof strategies.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "priority_score": 0.99,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.490128+00:00"
  },
  {
    "id": "fd_0105",
    "title": "Mind vs G\u00f6del: Can Minds Outperform Algorithms?",
    "description": "Formalize the Lucas-Penrose argument that human minds can see truths that formal systems cannot prove about themselves. Prove or disprove: there exists a computational system that can consistently recognize its own G\u00f6del sentences. Connect to Chaitin's incompleteness theorem and the Berry paradox.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.99,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.889380+00:00"
  },
  {
    "id": "fd_0054",
    "title": "Graph Coloring with Emotions: The Chromatic Polynomial Meets Psychology",
    "description": "The chromatic polynomial chi_G(k) counts the number of proper k-colorings of a graph G. For a friendship graph, chi_G(k) counts the number of ways to assign k emotions to people such that no two friends share the same emotion. Conjecture: The chromatic polynomial evaluated at k=6 (for the 6 basic emotions: happiness, sadness, anger, fear, disgust, surprise) gives the number of 'emotionally consistent' assignments of emotions to a social network. The chromatic polynomial has a root at k=2 for any bipartite graph, meaning a social network that splits cleanly into two groups has exactly 0 ways to assign 2 emotions without friends sharing emotions. The real emotional chromatic number chi_E(G) of a social network G is the smallest k such that chi_G(k) > 0 and k >= 3 (since real emotions need at least 3 categories to avoid trivial assignments). For a complete graph K_n (a clique of n mutual friends), chi_E(K_n) = n (everyone needs a different emotion). For a cycle C_n (a circular friendship chain), chi_E(C_n) = 2 if n is even and 3 if n is odd (alternating emotions work for even cycles, but odd cycles need a third emotion). Test: compute chi_E(G) for 100 real social networks and verify that the emotional chromatic number is between 3 and 6 for most networks. Impact: the chromatic polynomial is not just combinatorics \u2014 it measures the emotional diversity of a social network.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.9899999999999999,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.604974+00:00"
  },
  {
    "id": "fd_0000",
    "title": "Non-Well-Founded Proofs: Proofs That Reference Themselves",
    "description": "G\u00f6del showed self-reference breaks completeness, but what if self-referential proofs are not paradoxes but VALID mathematical objects? Develop a proof theory where proofs can reference their own structure \u2014 a proof of theorem T can contain a subproof that assumes T as a hypothesis, forming a circular dependency that is resolved through a fixed-point construction. Conjecture: Non-well-founded proofs form a convergent fixed point under a natural topolog: the space of proof trees with the tree topology is a Scott domain, and self-referential proofs correspond to infinite chains whose lub is a valid proof. A proof that references itself is like a recursive function: it converges if the self-reference occurs at a strictly smaller ordinal. Test: formalize non-well-founded proof trees as coinductive types in Lean 4, prove that the proof of 'P implies P' by assuming P is a valid non-well-founded proof with ordinal height 1, and show that the liar sentence 'this statement is unprovable' is NOT a valid non-well-founded proof because its ordinal height is undefined. Impact: turns the liar paradox from a bug into a feature \u2014 self-referential proofs are a new class of mathematical object with their own consistency conditions.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.98,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.486497+00:00"
  },
  {
    "id": "fd_0039",
    "title": "The Fundamental Theorem of Cakes: Algebraic Geometry of Baking",
    "description": "A cake is a smooth projective variety over R: it has a base (a smooth manifold with boundary), frosting (a sheaf of sections supported on the boundary), and layers (a stratification by codimension). The Fundamental Theorem of Cakes states: every cake C is uniquely determined (up to isomorphism of flavor) by its base B, its frosting sheaf F, and its layer stratification L. The frosting sheaf is a locally free sheaf of rank 1 (the cake has uniform frosting thickness) supported on the boundary of the base. The stratification is a flag of subvarieties C = L_0 > L_1 > ... > L_k = {point} where L_i has codimension i and represents the i-th layer. Conjecture: the moduli space of cakes of genus g (g = number of cherries on top) has dimension 3g-3 for g >= 2, mirroring the moduli space of Riemann surfaces. The cherry number g corresponds to the first Betti number of the cake surface, and the moduli are the positions of the g cherries on the surface. Test: enumerate all topologically distinct cakes with g <= 5 cherries and verify that the moduli space has dimension 3g-3. Compute the Teichmuller space of cakes by varying the cherry positions. Impact: cakes are algebraic varieties, and the mathematics of cake decoration IS the mathematics of moduli spaces.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.98,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.551386+00:00"
  },
  {
    "id": "fd_0070",
    "title": "Crystallographic Groups and Music: The 17 Wallpaper Groups of Rhythm",
    "description": "A periodic rhythm in music is a function f: Z -> {0, 1} that is periodic: f(n + p) = f(n) for some period p. The symmetry group of a rhythm with period p is a subgroup of Z/pZ. But music also has 2D patterns: a drum pattern is a function g: Z x Z -> {0, 1} (onset grid in time x pitch). The symmetry group of a drum pattern is a subgroup of Z x Z, which is a wallpaper group in 1D. In 2D, the wallpaper groups classify all possible symmetries of periodic patterns. There are exactly 17 wallpaper groups in 2D. Conjecture: the 17 wallpaper groups correspond to 17 fundamentally different types of rhythmic structure in music. Specifically: (1) p1: no symmetry (free rhythm), (2) p2: 2-fold rotational symmetry (call-and-response), (3) pm: mirror symmetry (palindrome), (4) pg: glide reflection (canon), (5) cm: mirror + glide (round), (6) pmm: double mirror (bilateral palindrome), (7) pmg: mirror + glide (inverted canon), (8) pgg: double glide (double canon), (9) cmm: double mirror + glide (round + palindrome), (10) p4: 4-fold rotation (4-bar cycle), (11) p4m: 4-fold + mirrors (variations on a theme), (12) p4g: 4-fold + glides (inverted variations), (13) p3: 3-fold rotation (3-bar blues), (14) p3m1: 3-fold + mirrors, (15) p31m: 3-fold + glides, (16) p6: 6-fold rotation (whole-tone scale symmetry), (17) p6m: 6-fold + mirrors (maximal symmetry, the 'perfect' rhythm). Test: classify 1000 drum patterns by their wallpaper group and verify the distribution matches musical practice. Impact: there are exactly 17 types of rhythm in music, classified by the wallpaper groups.",
    "domains": [
      "Novelty",
      "Algebra"
    ],
    "priority_score": 0.98,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.681497+00:00"
  },
  {
    "id": "fd_0099",
    "title": "Tangled Hierarchies: Proof Systems That Reference Their Own Soundness",
    "description": "Construct a formal proof system where the soundness predicate appears inside the system it validates. Prove that such tangled hierarchies are unavoidable in any system that can reason about its own consistency. Formalize using modal fixed-point logics and Kripke frames.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.98,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.852132+00:00"
  },
  {
    "id": "fd_0137",
    "title": "The Oracle's Burden: How Much Knowledge Is Too Much?",
    "description": "Prove that adding an oracle for the halting problem to PA yields a theory that proves its own consistency but cannot decide its own soundness. Formalize the hierarchy: PA < PA^H < PA^{H^H} < ... and prove that each jump genuinely increases theorem-proving power. Show that the oracle hierarchy is isomorphic to the Turing jump hierarchy.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.98,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.085832+00:00"
  },
  {
    "id": "fd_0029",
    "title": "Tropical Dreams: The Field with One Element Meets Tropical Geometry",
    "description": "The field with one element F_1 is a hypothetical object that would explain why the Weil conjectures have the form they do \u2014 as if there were a field with q^0 = 1 element. Tropical geometry replaces addition with min and multiplication with addition. What if these two ideas are the SAME? Conjecture: The tropical semiring (R union {infinity}, min, +) IS the field with one element, in the following precise sense: the category of tropical schemes is equivalent to the category of F_1-schemes. More concretely, a tropical variety over F_1 is a set with a min-plus structure, and its base change to Z (formally, tensor with Z) is a toric variety. The key correspondence: F_1-points of a tropical variety are the vertices of its Newton polytope, and the 'cardinality' of the tropical variety (as an F_1-object) is the number of lattice points in the polytope, which equals the degree of the toric variety after base change. Test: for each toric variety corresponding to a polytope P, compute the number of F_1-points (vertices of P) and verify that the Euler characteristic of the toric variety equals |vertices(P)| = #F_1-points. Prove the tensor product correspondence: tropical scheme X over F_1 has X tensor_Z Z = the corresponding toric variety. Impact: F_1 and tropical geometry are two faces of the same coin. The field with one element is tropical, and tropical geometry is the geometry of F_1.",
    "domains": [
      "Novelty",
      "Tropical"
    ],
    "priority_score": 0.97,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.523325+00:00"
  },
  {
    "id": "fd_0101",
    "title": "Transfinite Game Theory: Games That Last Forever",
    "description": "Develop a rigorous theory of infinite games where moves are indexed by transfinite ordinals. Prove that Zermelo's theorem extends: every such game has a determined outcome under AD. Formalize the connection between the determinacy hierarchy and large cardinal axioms.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.97,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.864670+00:00"
  },
  {
    "id": "fd_0114",
    "title": "Time Travel Consistency: Novikov's Principle as a Fixed-Point Theorem",
    "description": "Prove that Novikov's self-consistency principle follows from the Banach fixed-point theorem applied to the causal structure of spacetime. Formalize time-travel paradoxes as boundary value problems and prove existence of self-consistent solutions for polynomial causal maps.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "priority_score": 0.97,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.944657+00:00"
  },
  {
    "id": "fd_0132",
    "title": "The Fractal Dimension of Mathematical Truth",
    "description": "Define a natural metric on the space of all mathematical statements and prove that the set of true statements has a fractal dimension. Show that this dimension is strictly between 0 and 1 (truth is sparse but not negligible). Connect to Chaitin's Omega and prove that the fractal dimension is uncomputable but approximable.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.97,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.055007+00:00"
  },
  {
    "id": "fd_0002",
    "title": "Quantum Surreal Numbers: Superposition of All Real Numbers",
    "description": "Conway's surreal numbers are the largest ordered field, containing every real number and infinitely many infinities and infinitesimals. But what if a surreal number could be in SUPERPOSITION \u2014 simultaneously equal to multiple values until observed? Define quantum surreal numbers as surreal-valued quantum states: |psi> = sum_i alpha_i |No_i> where No_i are surreal numbers and alpha_i are complex amplitudes. Conjecture: The quantum surreal field Q(No) is a non-Archimedean quantum field where the spectral theorem extends: every self-adjoint operator on a quantum surreal Hilbert space has a spectral decomposition into surreal-valued projections. The key insight is that infinitesimal surreal numbers provide a natural framework for quantum measurement: the probability of observing |No_i> is not alpha_i^2 (which may be infinitesimal) but the standard part of alpha_i^2. Test: construct the quantum surreal number |psi> = (1/sqrt(2))|0> + (1/sqrt(2))|epsilon> where epsilon is an infinitesimal surreal, and prove that measuring |psi> gives 0 with probability st(1/2) = 1/2 and epsilon with probability st(1/2 * epsilon^2) = 0 \u2014 the infinitesimal is unobservable! Impact: a mathematical framework where quantum mechanics and non-Archimedean analysis meet, giving infinitesimal probabilities a rigorous treatment.",
    "domains": [
      "Novelty",
      "Speculative"
    ],
    "priority_score": 0.96,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.489800+00:00"
  },
  {
    "id": "fd_0100",
    "title": "Consciousness as Emergent Fixed Point",
    "description": "Formalize the hypothesis that consciousness is a fixed point of a self-modeling function: a system that models itself modeling itself. Prove that such fixed points exist in sufficiently rich Cartesian closed categories and that they exhibit strange-loop topology. Connect to the Yoneda lemma and self-reference in type theory.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.96,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.858621+00:00"
  },
  {
    "id": "fd_0107",
    "title": "Surveillance Networks: Information-Theoretic Undetectability",
    "description": "Prove a theorem about the minimum information an observer must collect to reconstruct a dynamic social network with bounded error. Formalize the privacy-utility tradeoff as a rate-distortion problem and prove that perfect surveillance and perfect privacy are mutually exclusive in finite networks.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "priority_score": 0.96,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.901165+00:00"
  },
  {
    "id": "fd_0063",
    "title": "Topological Quantum Compiling: Braid Groups as Universal Gates",
    "description": "Anyon braiding in topological quantum computing gives unitary matrices from the braid group B_n. The Jones representation rho_k: B_n -> U((k-1)(n-1)+1) at root of unity e^{2*pi*i/k} is conjectured to be universal for quantum computation when k >= 3 and n >= 4. Conjecture: the set of all braids in B_4 under the Jones representation at k=5 generates a dense subgroup of SU(3). More precisely, the image rho_5(B_4) is an infinite subgroup of SU(3) that is not contained in any proper closed subgroup. This means that topological quantum computing with Fibonacci anyons (k=5) is universal: any unitary in SU(3) can be approximated to arbitrary precision by braiding 4 anyons. The key: the Jones representation at k=5 gives 3x3 matrices, and the braid generators sigma_1, sigma_2, sigma_3 generate a dense subgroup of SU(3). Test: compute the Jones representation at k=5 for B_4, verify that sigma_1 * sigma_2 * sigma_3 has infinite order, and check that the group generated by sigma_1, sigma_2, sigma_3 is dense in SU(3) by the Solovay-Kitaev theorem. Impact: braiding anyons is universal for quantum computation. The braid group B_4 at k=5 is a quantum gate set.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.643460+00:00"
  },
  {
    "id": "fd_0098",
    "title": "Isomorphisms of Meaning: When Structures Collide",
    "description": "Prove that isomorphic mathematical structures can carry semantically different meanings that no formal system can distinguish. Formalize the concept of 'isomorphism of isomorphisms' and show that categorical equivalence preserves truth but not meaning. Connect to Hofstadter's Copycat architecture for analogical reasoning.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.846057+00:00"
  },
  {
    "id": "fd_0119",
    "title": "Anti-Mathematics: What If All Axioms Were Negated?",
    "description": "Systematically negate the ZFC axioms and study the resulting anti-mathematics. Prove that not-Extensionality yields a theory of indistinguishable sets, not-Infinity yields hereditarily finite set theory, and not-Choice yields universes where every set is measurable. Determine which anti-axioms are consistent with each other.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.976561+00:00"
  },
  {
    "id": "fd_0157",
    "title": "Rigorous axiomatic framework for substrate-ind",
    "description": "# Future Research Directions\n\n## Synthesis\n\nThis research cycle established a rigorous axiomatic framework for substrate-independent computational complexity. The core contribution \u2014 the `ComplexityHierarchy` structure \u2014 captures the minimal axioms (monotonicity, strictness) from which all structural hierarchy theorems follow. We proved 10 theorems covering infinite separation, simulation transfer, diagonal separation, oracle non-collapse, substrate independence, and hypercomputational barriers, all fully machine-verified.\n\nThe most promising cross-domain connection emerging from this cycle is the bridge between our abstract hierarchy framework and the existing Geometric Complexity Theory (GCT) formalization in the Catalog (`Catalog/Algebra/GCT/Foundation.lean`). GCT's obstruction witnesses serve as concrete instantiations of our abstract separation witnesses, suggesting a deeper unification: the representation-theoretic obstructions of GCT may be precisely the diagonal separators of our abstract framework, specialized to the algebraic setting. This connection has the highest breakthrough potential because it could link our model-independent results to concrete P vs NP attack strategies.\n\nA secondary promising direction connects to the Kolmogorov complexity formalization (`Catalog/Computation/KolmogorovComplexity.lean`) and EML theory (`Catalog/EML/EMLv17Core.lean`). Kolmogorov complexity provides a natural \"complexity measure\" that could instantiate our abstract framework, while EML's information-theoretic perspective could yield quantitative refinements of our qualitative separation results.\n\n---\n\n### Direction 1: Reduction-Enriched Complexity Hierarchies\n\n**Conjecture**: The `ComplexityHierarchy` framework can be extended with an abstract notion of \"reduction\" (a preorder on problems compatible with level membership) such that every level contains a maximum element under this preorder \u2014 i.e., abstract completeness emerges from the axioms alone, without reference to any specific model.\n\nFormally: given a complexity hierarchy H with a compatible preorder \u2264_r on problems (where x \u2264_r y and y \u2208 level(n) implies x \u2208 level(n)), if the hierarchy admits effective enumeration of reductions, then each level(n+1) \\ level(n) contains an element that is \u2264_r-maximal within level(n+1).\n\n**Test**: Formalize the reduction-enriched hierarchy in Lean 4. Attempt to prove the abstract completeness theorem. If the proof succeeds, instantiate it with concrete reductions (many-one, Turing, truth-table) to verify it yields standard completeness results. If it fails, identify which additional axioms are needed \u2014 this failure itself would illuminate what makes completeness structurally different from hierarchy separation.\n\n**Impact**: If true, this would show that NP-completeness (and completeness at every level) is not an accident of Turing machines but a structural inevitability. This would substantially strengthen the substrate independence thesis. If false, the failure would identify a genuinely model-dependent aspect of complexity theory.\n\n**Catalog References**: `Computation/UniversalComplexity.lean`, `Catalog/Algebra/GCT/Foundation.lean`\n\n**Proof Strategy**: \n1. Define `ReductionEnrichedHierarchy` extending `ComplexityHierarchy` with a preorder and compatibility axiom.\n2. Add an enumeration axiom for reductions.\n3. Use a diagonalization-like argument to construct maximal elements: enumerate all problems at level n+1, and for each, check whether it reduces to the candidate. \n4. The key lemma is that the \"hardest\" problem at each level exists by a Zorn's-lemma-style argument (or its constructive replacement).\n\n**Domain Bridges**: Abstract complexity theory \u2194 Order theory / lattice theory \u2194 GCT obstruction maps\n\n**Lineage**: Builds on `ComplexityHierarchy` and `FrameworkSimulation` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: GCT Obstruction Maps as Diagonal Separators\n\n**Conjecture**: The GCT obstruction witnesses (representation-theoretic multiplicity gaps) can be shown to be instances of the abstract diagonal separators in our `DiagonalizableFramework`, when the hierarchy is instantiated to algebraic complexity classes (VP, VNP).\n\nFormally: there exists a `DiagonalizableFramework` D whose levels correspond to algebraic complexity classes (bounded-degree determinantal complexity) and whose diagonal function `diag` produces, at each level, a polynomial family whose representation-theoretic multiplicities provide GCT obstruction witnesses.\n\n**Test**: \n1. Define an algebraic complexity hierarchy using the GCT structures from `Catalog/Algebra/GCT/Foundation.lean`.\n2. Construct a `DiagonalizableFramework` instance over this hierarchy.\n3. Verify that the `obstruction_implies_noncontainment` theorem from GCT corresponds to the `diagonal_separation` theorem from our framework.\n4. If the construction works, prove the correspondence formally. If not, identify which GCT axioms are not captured by our framework.\n\n**Impact**: This would unify two major approaches to computational complexity lower bounds \u2014 the combinatorial (hierarchy theorems) and the algebraic (GCT) \u2014 under a single abstract framework. It would also validate our framework by showing it captures non-trivial existing mathematics.\n\n**Catalog References**: `Catalog/Algebra/GCT/Foundation.lean` (GCTSystem, ObstructionWitness, obstruction_implies_noncontainment), `Computation/UniversalComplexity.lean`\n\n**Proof Strategy**:\n1. Map GCT's `inClosure` relation to level membership: define level(n) as the set of polynomials with determinantal complexity \u2264 n.\n2. Use GCT's `small_circuit_closure` axiom to establish monotonicity.\n3. Use obstruction witnesses to establish strictness (under suitable assumptions about multiplicity growth).\n4. The diagonal function would use the permanent polynomial family, which is the canonical hard family in GCT.\n\n**Domain Bridges**: Abstract complexity theory \u2194 Algebraic geometry (orbit closures) \u2194 Representation theory (Schur-Weyl duality)\n\n**Lineage**: Builds on `DiagonalizableFramework` and `diagonal_separation` from this cycle, and `GCTSystem` from the Catalog.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Kolmogorov Complexity as a Natural Complexity Measure\n\n**Conjecture**: Kolmogorov complexity provides a natural instantiation of the `ComplexityHierarchy` framework where the levels correspond to sets of strings with bounded Kolmogorov complexity, and the strict hierarchy corresponds to the uncomputability of Kolmogorov complexity at successively higher oracle levels.\n\nFormally: define level(n) as the set of strings x with K^{(n)}(x) \u2264 |x| (where K^{(n)} is Kolmogorov complexity relative to the n-th Turing jump), and prove this forms a `ComplexityHierarchy`.\n\n**Test**: Formalize the Kolmogorov hierarchy using the existing `Catalog/Computation/KolmogorovComplexity.lean` definitions. Prove monotonicity and strictness. For strictness, the key argument uses the uncomputability of K relative to each oracle level, combined with the existence of strings that are complex relative to one level but simple relative to the next.\n\n**Impact**: This would connect our abstract framework to algorithmic information theory, one of the deepest areas of theoretical computer science. It would also provide a \"complexity hierarchy\" that is fundamentally different from time/space hierarchies, validating that our axioms capture genuine generality.\n\n**Catalog References**: `Catalog/Computation/KolmogorovComplexity.lean`, `Computation/UniversalComplexity.lean`\n\n**Proof Strategy**:\n1. Define levels using relativized Kolmogorov complexity.\n2. Monotonicity follows from the fact that a more powerful oracle can only decrease complexity.\n3. Strictness requires showing that the n-th Turing jump solves problems that the (n-1)-th jump cannot \u2014 this is a standard result in computability theory (Post's theorem).\n4. Diagonal separators correspond to strings that are \"complex\" at one level but \"simple\" at the next.\n\n**Domain Bridges**: Abstract complexity \u2194 Algorithmic information theory \u2194 Computability theory (Turing jumps)\n\n**Lineage**: Builds on `ComplexityHierarchy` from this cycle and Kolmogorov complexity definitions from the Catalog.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Quantitative Hierarchy Gaps via EML Theory\n\n**Conjecture**: The qualitative strictness axiom of `ComplexityHierarchy` can be refined to a quantitative statement using EML (Ensemble Meta-Learning) theory's information-theoretic tools: the \"size\" of the gap between level(n) and level(n+1), measured by an appropriate ensemble complexity metric, grows at least logarithmically in n.\n\nFormally: define a measure \u03bc on the type \u03b1 and define gap(n) = \u03bc(level(n+1) \\ level(n)). Under suitable axioms about \u03bc (related to EML's ensemble complexity), prove gap(n) \u2265 c \u00b7 log(n) for some constant c > 0.\n\n**Test**: \n1. Extend `ComplexityHierarchy` with a measure on \u03b1.\n2. Formalize gap(n) as the measure of the symmetric difference between consecutive levels.\n3. Attempt to prove logarithmic growth under the EML-inspired axioms.\n4. Computationally verify the bound for specific instantiations (e.g., the time hierarchy for Turing machines, where the gap between DTIME(n^k) and DTIME(n^{k+1}) is known to have specific density properties).\n\n**Impact**: This would transform our qualitative framework into a quantitative one, enabling statements not just about the existence of separations but about their magnitude. It could yield new connections between complexity theory and information theory.\n\n**Catalog References**: `Catalog/EML/EMLv17Core.lean` (eml, emlDiag, sigmaEml), `Catalog/EML/AdvancedTheory.lean` (ensembleComplexity), `Computation/UniversalComplexity.lean`\n\n**Proof Strategy**:\n1. Import the ensemble complexity metric from EML theory.\n2. Axiomatize the compatibility between the hierarchy's levels and the EML measure.\n3. Use the EML diagonalization (emlDiag) as a quantitative refinement of our abstract diag function.\n4. The logarithmic bound should follow from a counting argument: at level n, the number of \"new\" problems is bounded below by the information-theoretic content of the diagonal construction.\n\n**Domain Bridges**: Abstract complexity \u2194 Information theory (EML) \u2194 Measure theory\n\n**Lineage**: Builds on `ComplexityHierarchy` from this cycle and EML core definitions from the Catalog.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Tropical Complexity Hierarchies\n\n**Conjecture**: The tropical (min-plus) semiring gives rise to a natural complexity hierarchy where the levels correspond to tropical circuits of bounded size, and the strict hierarchy theorem holds with a constructive diagonal witness based on tropical permanent vs tropical determinant separation.\n\nFormally: define a `ComplexityHierarchy` over tropical polynomial families where level(n) consists of families computable by tropical circuits of size \u2264 n. Prove strictness using the known exponential gap between tropical permanent and tropical circuit complexity.\n\n**Test**: \n1. Define tropical circuit complexity using the min-plus semiring from `Catalog/Computation/TropicalThermodynamicComplexity.lean`.\n2. Construct the hierarchy and prove monotonicity.\n3. For strictness, use the counting argument: there are (n+1)^{n\u00b2} tropical polynomials on n variables, but only exp(O(s log s)) computable by circuits of size s.\n4. Verify this counting argument computationally for small n using the demo.py framework.\n\n**Impact**: This would provide a concrete, non-Turing-machine instantiation of our abstract framework in a setting where exponential lower bounds are provable (unlike Boolean complexity, where we cannot prove superlinear lower bounds unconditionally). It would validate that our framework captures settings where hierarchy theorems are not just conjectured but proved.\n\n**Catalog References**: `Catalog/Computation/TropicalThermodynamicComplexity.lean`, `Catalog/Tropical/`, `Computation/UniversalComplexity.lean`\n\n**Proof Strategy**:\n1. Use the tropical semiring formalization from the Catalog.\n2. Define tropical circuit complexity as a function from polynomial families to \u2115.\n3. Monotonicity: a circuit of size s can be padded to size s+1.\n4. Strictness: counting argument \u2014 the number of distinct tropical polynomials grows faster than the number of small circuits.\n5. The diagonal witness is the tropical permanent, which requires exponential tropical circuit size.\n\n**Domain Bridges**: Abstract complexity \u2194 Tropical algebra (min-plus semiring) \u2194 Combinatorial optimization\n\n**Lineage**: Builds on `ComplexityHierarchy` from this cycle and tropical algebra formalizations from the Catalog.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "priority_score": 0.95,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "78286831",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T15:28:03.287615+00:00"
  },
  {
    "id": "fd_0116",
    "title": "Dream Logic: Non-Monotone Reasoning Where Contradictions Coexist",
    "description": "Formalize a logic where contradictions do not explode and beliefs can be retracted. Prove that paraconsistent logics can model dream-like reasoning where impossible objects coexist. Show that such logics correspond to topological spaces where open sets are not closed under arbitrary union.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.94,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.958310+00:00"
  },
  {
    "id": "fd_0124",
    "title": "Paradoxes as Theorems: Liar, Berry, and Russell Made Consistent",
    "description": "Construct a consistent formal system where the Liar sentence, Berry's paradox, and Russell's paradox are all provable theorems rather than contradictions. Prove this requires rejecting classical logic in favor of a paraconsistent logic with a nontrivial inconsistency-tolerant truth predicate. Show this system proves its own soundness.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.94,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.006174+00:00"
  },
  {
    "id": "fd_0130",
    "title": "Zombies and Qualia: Mathematics of Subjective Experience",
    "description": "Formalize the hard problem of consciousness as a theorem about the gap between functional descriptions and subjective experience. Prove that any system satisfying the functional definition of consciousness can have a zombie twin that is functionally identical but experientially void. Show this gap is isomorphic to G\u00f6del's incompleteness gap.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.94,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.042804+00:00"
  },
  {
    "id": "fd_0122",
    "title": "Retrocausal Mathematics: Where Effects Precede Causes",
    "description": "Formalize retrocausal mathematical structures where implications can flow backward in time. Prove that in a retrocausal Heyting algebra, the law of excluded middle fails but a temporal excluded middle holds. Connect to the CPT theorem in QFT and prove that any retrocausal logic must be intuitionistic.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.9299999999999999,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.994131+00:00"
  },
  {
    "id": "fd_0026",
    "title": "Self-Improving Proofs: Proofs That Get Simpler Over Time",
    "description": "Proofs are static objects, but what if proofs could improve? Define a proof refinement system where each proof P has a complexity C(P) = length(P) + depth(P) + number of lemmas, and a proof P' is a refinement of P if P' proves the same theorem with C(P') < C(P). Conjecture: For every theorem T provable in ZFC, there exists a sequence of refinements P = P_0, P_1, P_2, ... such that C(P_n) is non-increasing and the limit P_infinity is the simplest proof of T (in the sense of Kolmogorov complexity). Moreover, the refinement process halts: there exists N such that C(P_N) = C(P_{N+1}) = ... = C(P_infinity). The key insight: proof simplification is a well-founded process because the complexity is a natural number that decreases at each step. But the process can be arbitrarily long \u2014 the proof of the four-color theorem might require 10^100 refinements to reach its simplest form. Test: formalize the refinement system in Lean 4. Starting from the statement of the irrationality of sqrt(2), generate refinements by eliminating unnecessary lemmas, shortening case splits, and removing redundant quantifiers. Measure C(P) at each step and verify it decreases. Impact: proofs are not static \u2014 they are living objects that can be improved. The simplest proof of a theorem is the LIMIT of the refinement process, and this limit ALWAYS exists.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.9199999999999999,
    "status": "in_progress",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "8a2abb60",
    "timestamp": "2026-06-01T12:30:30.516572+00:00"
  },
  {
    "id": "fd_0037",
    "title": "The Periodic Table Is a Lie: Elements as Eigenvalues of Spacetime",
    "description": "Mendeleev's periodic table arranges elements by atomic number Z, but Z is just the charge of the nucleus. Conjecture: the periodic table is the spectrum of an operator on a Hilbert space of dimension equal to the number of stable isotopes. Define the 'nuclear Hamiltonian' H on L^2(R^3) by H = -hbar^2/(2m) * nabla^2 + V(r) where V(r) encodes the strong and electromagnetic forces. The eigenvalues E_n of H give the binding energies of nuclei, and Z_n = round(E_n / E_0) gives the atomic numbers. The 'periodicity' of the table arises because the eigenvalues of H have shell structure (like the hydrogen atom): the n-th shell has degeneracy 2n^2 (from the angular momentum quantum number), giving shell sizes 2, 8, 18, 32, 50, 72 \u2014 the noble gas atomic numbers 2, 10, 28, 60, 110 are the cumulative sums. The 'stability islands' (magic numbers 2, 8, 20, 28, 50, 82, 126) correspond to extra degeneracies in the nuclear potential. Test: solve the Schrodinger equation for a Woods-Saxon potential (model nuclear potential) and show that the eigenvalue degeneracies match the periodic table structure. Compute the 'predicted' periodic table from the eigenvalues and compare with reality. Impact: chemistry IS applied spectral theory. The periodic table is the spectrum of a Hamiltonian, and every chemical property is an eigenvalue.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "priority_score": 0.9199999999999999,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.545457+00:00"
  },
  {
    "id": "fd_0117",
    "title": "The Unreasonable Effectiveness of Wrong Theories",
    "description": "Prove a meta-theorem: for any approximately correct physical theory T, there exists a class of phenomena for which T makes predictions closer to truth than any known correct theory. Formalize using perturbation theory on theory-space and prove that the wrongness of T forms a convergent series toward truth.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "priority_score": 0.9199999999999999,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.964591+00:00"
  },
  {
    "id": "fd_0135",
    "title": "Infinite Games Against Death: Immortality Strategies",
    "description": "Formalize a game where one player (Mortal) has finite computation and the other (Eternity) has transfinite computation. Prove that Mortal can always force at least omega rounds before losing, and that with bounded nondeterminism, Mortal can force omega-squared rounds. Connect to Infinite Time Turing Machines.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.9199999999999999,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.073799+00:00"
  },
  {
    "id": "fd_0013",
    "title": "Holographic Primes: The Prime Number AdS/CFT Correspondence",
    "description": "The AdS/CFT correspondence says that a gravitational theory in the bulk of anti-de Sitter space is equivalent to a conformal field theory on the boundary. What if prime numbers have a holographic dual? Define the prime hologram: for each prime p, define its 'boundary' as the ring Z/pZ and its 'bulk' as the p-adic field Q_p. Conjecture: The Riemann zeta function zeta(s) = prod_p (1 - p^{-s})^{-1} is the holographic partition function: the product over primes (boundary) encodes the same information as the completed zeta function Xi(s) (bulk). The functional equation Xi(s) = Xi(1-s) is the holographic duality: bulk physics at depth s equals boundary physics at depth 1-s. The prime counting function pi(x) ~ x/log(x) is the bulk volume, while the Chebyshev function theta(x) = sum_{p<=x} log(p) is the boundary area. The AdS/CFT dictionary: bulk gravity mode at depth s <-> boundary CFT operator of dimension 1-s. Test: verify that the pair correlation of zeta zeros matches GUE random matrices (bulk = quantum gravity in AdS, boundary = CFT random matrix ensemble). Compute the 'prime partition function' Z(beta) = prod_p (1 - e^{-beta log p})^{-1} and show it equals the bulk partition function. Impact: the Riemann Hypothesis is equivalent to a holographic stability condition \u2014 zeros on the critical line means the bulk geometry is stable against perturbations.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.91,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.496525+00:00"
  },
  {
    "id": "fd_0028",
    "title": "Godel's Casino: Incomplete but Winnable Games",
    "description": "Godel's incompleteness theorem says there are true statements that cannot be proved. But what if we turn incompleteness into a GAME? Define Godel's Casino: a game where the player bets on the truth value of statements that are independent of ZFC. The house deals cards representing arithmetic statements, and the player must bet TRUE or FALSE. The Continuum Hypothesis is the first card \u2014 you can bet either way and you're RIGHT in some model. Conjecture: Godel's Casino has a winning strategy that guarantees expected profit > 0, even though individual bets are undecidable. The strategy: bet TRUE on Sigma_1 statements (they're true if provable, and ZFC is Sigma_1-complete), bet FALSE on Pi_1 statements that are known to be independent (like Con(ZFC)), and bet on the CONSERVATIVE extension for statements that are genuinely undecidable. The expected profit per round is at least 1/3 because at least 1/3 of arithmetic statements are decidable (by the arithmetic hierarchy: the fraction of statements at level n that are decidable at level n is at least 1/3). Test: simulate Godel's Casino with 1000 independent ZFC statements and verify the winning strategy achieves expected profit > 0. Impact: incompleteness is not a barrier \u2014 it's an opportunity. You can WIN at the game of undecidability.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.521091+00:00"
  },
  {
    "id": "fd_0049",
    "title": "Proofs as DAGs: The Directed Acyclic Graph Structure of Mathematics",
    "description": "Every mathematical proof is a directed acyclic graph (DAG): nodes are statements, edges are implications, and the acyclicity comes from the fact that you can't prove A from B and B from A without a circular argument (which is not a valid proof). Conjecture: The DAG of all mathematical proofs has a scale-free structure: the in-degree distribution follows a power law P(k) ~ k^{-gamma} with gamma \u2248 2.5. This means most theorems are proved from a small number of foundational results (the 'hubs'), and there are exponentially many theorems that depend on these hubs. The top 10 hub theorems in mathematics are: (1) Zorn's Lemma, (2) The Intermediate Value Theorem, (3) The Fundamental Theorem of Calculus, (4) The Sylow Theorems, (5) The Baire Category Theorem, (6) Hahn-Banach Theorem, (7) Urysohn's Lemma, (8) The Pigeonhole Principle, (9) Induction, (10) The Law of Excluded Middle. Conjecture: removing any of the top 10 hubs disconnects the proof DAG into at least 2 large components, each containing more than 10% of all theorems. This means mathematics is fragile: removing one foundational theorem makes many other theorems unprovable. Test: construct the proof DAG from Lean 4's Mathlib (all proofs and their dependencies), compute the in-degree distribution, and verify the power law. Impact: mathematics is a scale-free network, and its most important theorems are its most connected nodes \u2014 the hubs that hold the entire structure together.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.9,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.585396+00:00"
  },
  {
    "id": "fd_0080",
    "title": "Automatic Sequences and the Halting Problem: When Is a Sequence Computable?",
    "description": "An automatic sequence is one generated by a deterministic finite automaton (DFA). The Thue-Morse sequence 01101001... is 2-automatic. The Rudin-Shapiro sequence is 2-automatic. The paperfolding sequence is 2-automatic. Conjecture: a sequence (a_n) is k-automatic iff its generating function G(x) = sum a_n x^n is algebraic over Q(x) of degree at most k. This is known (Christol's theorem): a formal power series over F_k is algebraic iff its coefficient sequence is k-automatic. But Christol's theorem only works over finite fields. For sequences over Z (or Q), the conjecture is: a sequence (a_n) over Z is k-automatic iff it satisfies a linear recurrence with polynomial coefficients of degree at most k-1 in n. Conjecture: the halting problem for k-automatic sequences is decidable: given a DFA that generates (a_n), it is decidable whether there exists n such that a_n = 0 (the 'zero in sequence' problem). This is TRUE for k-automatic sequences (by the pumping lemma: if the DFA accepts any string, it accepts an infinite number, so a_n = 0 infinitely often). But for morphic sequences (generalizations of automatic sequences), the problem is open. Conjecture: the zero-in-sequence problem for morphic sequences is decidable. Test: implement the decidability algorithm for k-automatic sequences and verify on 100 test sequences. Impact: automatic sequences have decidable halting problems. The boundary between decidability and undecidability in sequence theory is the boundary between automatic and morphic.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.89,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.733493+00:00"
  },
  {
    "id": "fd_0115",
    "title": "Flatland Catastrophe: When 2D Physics Breaks",
    "description": "Prove that 2-dimensional Newtonian gravity is mathematically pathological: orbits don't close, there's no stable circular orbit, and gravitational potential is logarithmic. Formalize the Bertrand-Darboux theorem failure in 2D and prove that stable planetary systems cannot exist in Flatland.",
    "domains": [
      "Novelty",
      "Physics"
    ],
    "priority_score": 0.89,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.951261+00:00"
  },
  {
    "id": "fd_0133",
    "title": "Quantum Proofs of Classical Theorems",
    "description": "Prove that every classical mathematical theorem has a quantum proof that is shorter by at most a polynomial factor. Formalize quantum proof systems (QMA) and show that some classical theorems (e.g., pigeonhole principle) have exponentially shorter quantum proofs. Determine whether super-polynomial quantum advantage exists.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.89,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.061234+00:00"
  },
  {
    "id": "fd_0018",
    "title": "The L-Function Oracle: What If We Could Compute L-Functions Instantly?",
    "description": "Suppose we had an oracle that computes L(s, chi) for any L-function and any complex s in O(1) time. What theorems would follow? Conjecture: The L-function oracle implies (1) The Riemann Hypothesis (compute zeros directly), (2) The BSD conjecture (compute the order of vanishing at s=1), (3) The Sato-Tate conjecture (compute the distribution of a_p), (4) Langlands functoriality (compare L-functions on both sides of the functoriality lift), and (5) A polynomial-time algorithm for factoring (the L-function of an elliptic curve E over Z/nZ detects factors of n). But the oracle also implies IMPOSSIBILITY results: (6) P != NP (because NP-complete problems would reduce to L-function computations that the oracle solves in O(1), contradicting the time hierarchy theorem if P = NP). Wait \u2014 the oracle solves L-function computations in O(1), so if P = NP, then NP problems can be encoded as L-function computations and solved instantly, but the oracle's existence is an axiom, not a theorem. The correct statement: the L-function oracle collapses the polynomial hierarchy to L-function computations. Test: prove that the Riemann Hypothesis follows from the oracle. Prove that BSD follows. Prove that factoring is in P given the oracle. Impact: understanding what an L-function oracle implies tells us exactly how powerful L-functions are \u2014 and how far we are from proving things about them.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.502441+00:00"
  },
  {
    "id": "fd_0091",
    "title": "Information-Theoretic Limits of Proof Search: How Hard Is It to Find a Lean Proof?",
    "description": "The information content of a Lean 4 proof is the number of bits needed to specify the proof among all possible proofs of the same theorem. For a theorem T with proof P, the information content is I(P) = -log_2(P(proof of T has length |P|)). Conjecture: the expected information content of a proof of a theorem with statement length n is I(n) = Theta(n * log(n)). This means that proofs are typically longer than their statements by a factor of log(n), matching the known results on proof complexity. Moreover, the search problem (finding a proof given the theorem) has time complexity 2^{I(n)} = 2^{Theta(n * log(n))}, which matches the complexity of brute-force search over all proofs of length n * log(n). Conjecture: proof search in Lean 4 is EXPTIME-hard, and the average-case complexity of finding a proof of a random theorem of length n is 2^{Theta(n)} (exponential in n, not n*log(n), because most random theorems are unprovable). Test: measure the length of Lean 4 proofs vs theorem statement length for 1000 theorems in Mathlib and verify I(n) ~ n * log(n). Impact: proof search has fundamental information-theoretic limits. Finding a proof is exponentially harder than verifying one.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.801778+00:00"
  },
  {
    "id": "fd_0110",
    "title": "Self-Modifying Code That Cannot Be Stopped",
    "description": "Prove that any Turing-complete system with self-modification capabilities has no general algorithm for predicting its own termination. Formalize the halting problem for programs that can rewrite their own code mid-execution and show this is strictly harder than the classical halting problem. Connect to the virus paradox and AI alignment.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.919138+00:00"
  },
  {
    "id": "fd_0120",
    "title": "Thermodynamics of Mathematical Proof",
    "description": "Formalize a Landauer-like principle for mathematical reasoning: every bit of information destroyed in a proof step costs at least kT ln 2 of entropy. Prove that there exist theorems whose shortest proof requires exponentially more erasure than creation, and connect to Kolmogorov complexity and the thermodynamic cost of verification.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.88,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.982360+00:00"
  },
  {
    "id": "fd_0001",
    "title": "Hyperbolic Number Theory: Arithmetic on the Poincar\u00e9 Disk",
    "description": "The integers Z live on a line, but what happens to arithmetic on a curved space? Define hyperbolic integers Z_H as the set of points in the Poincar\u00e9 disk that are images of Z under a discrete subgroup Gamma of PSL(2,R). Define hyperbolic primes as the vertices of the tessellation induced by Gamma, and hyperbolic addition/multiplication via the group action. Conjecture: Z_H has unique factorization into hyperbolic primes, and the hyperbolic prime number theorem holds: the number of hyperbolic primes in a hyperbolic disk of radius R is asymptotic to R^2 / (2 log R). The hyperbolic zeta function zeta_H(s) = sum_{n in Z_H, |n|_H > 0} 1/|n|_H^{2s} satisfies a functional equation and has zeros only on the critical line Re(s) = 1/2. Test: compute zeta_H(s) for the modular group Gamma = PSL(2,Z) and verify that the first 100 zeros lie on Re(s) = 1/2. Impact: number theory on curved spaces \u2014 where primes are geometric objects and the Riemann Hypothesis might be PROVABLE.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.87,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.489454+00:00"
  },
  {
    "id": "fd_0121",
    "title": "Hypercomputation: Computing the Uncomputable",
    "description": "Construct a rigorous model of hypercomputation that can solve the halting problem. Prove that any physical system implementing hypercomputation requires infinite energy density or infinite precision. Formalize the distinction between accidentally computable (physical oracles) and essentially computable (Turing machines).",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.87,
    "status": "in_progress",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "016ae4c9",
    "timestamp": "2026-06-01T12:30:30.988298+00:00"
  },
  {
    "id": "fd_0027",
    "title": "The L-Function Universe: A Cosmic Census of All L-Functions",
    "description": "L-functions are the DNA of mathematics \u2014 each one encodes deep arithmetic information. But how many L-functions ARE there? The L-function universe is vast: (1) The Riemann zeta function (1 L-function), (2) Dirichlet L-functions (countably many), (3) L-functions of elliptic curves (uncountably many, one per j-invariant), (4) L-functions of modular forms (countably many, but indexed by weight and level), (5) L-functions of Galois representations (enormous family). Conjecture: The set of 'natural' L-functions (those satisfying the Selberg class axioms: analytic continuation, functional equation, Euler product, Ramanujan bound) is COUNTABLE. This means the universe of well-behaved L-functions is no bigger than the integers, despite each individual L-function encoding infinitely much information. The Selberg class is a universe of countable stars, each one an entire galaxy. Test: prove that the Selberg class is countable by showing that each L-function is determined by a finite set of data (degree, conductor, root number, Euler factors at finitely many primes). Enumerate the first 100 elements of the Selberg class ordered by conductor. Impact: the mathematical universe of L-functions is countable \u2014 there are only as many well-behaved L-functions as integers. Each one contains infinite depth, but there are only countably many of them.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.518782+00:00"
  },
  {
    "id": "fd_0038",
    "title": "Infinite Chess: Checkmate in Omega Moves",
    "description": "Infinite chess is chess on an infinite board. It is known that there are positions where White can force checkmate but only in omega (the first infinite ordinal) moves. Conjecture: There exists a position on the infinite chess board where White can force checkmate in exactly omega^omega moves, but not in fewer. More precisely, define the game value v(P) of a position P as the smallest ordinal alpha such that White can force checkmate in at most alpha moves. The known results give positions with v(P) = omega. The conjecture is that v(P) can be arbitrarily large below omega^omega. The key construction: create a position where White must first solve a 'puzzle' that takes omega moves, and then another puzzle that takes omega moves for each of omega starting positions, giving omega^2 total moves. Iterating, one can reach omega^n for any n, and omega^omega by a diagonal argument. Test: construct explicit positions with game values omega, omega^2, omega^3, and omega^omega on the infinite board. Verify by computation that no strategy achieves checkmate in fewer moves. Impact: chess on an infinite board has transfinite game values \u2014 the complexity of checkmate goes beyond the finite ordinals into the transfinite.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.548476+00:00"
  },
  {
    "id": "fd_0048",
    "title": "The Aperiodic Monotile: One Shape to Tile Them All",
    "description": "In 2023, Smith et al. discovered 'the hat' \u2014 a single tile shape that tiles the plane but only aperiodically (no periodic tiling exists). This solved the aperiodic monotile problem. But deeper questions remain: How many distinct aperiodic monotiles exist? Conjecture: The set of aperiodic monotiles forms a 1-parameter family (the 'hat spectrum') parameterized by a continuous parameter t in [0,1] where t=0 gives the hat, t=1 gives the turtle (a known variant), and intermediate values give intermediate shapes. The key property: each shape in the hat spectrum tiles the plane aperiodically, and no two shapes in the spectrum admit a common periodic tiling. The boundary of the hat spectrum is the curve in R^2 that separates the region of aperiodic monotiles from the region of periodic tiles. This boundary is a piecewise-smooth curve determined by the constraint that the tile must enforce a hierarchical substitution rule. Test: parameterize the hat spectrum by interpolating between the hat and turtle, compute the substitution rule for each t, and verify that the substitution rule enforces aperiodicity for all t in [0,1]. Impact: aperiodic monotiles are not isolated curiosities \u2014 they form a continuous family, and the hat is just one point on the spectrum.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.581649+00:00"
  },
  {
    "id": "fd_0072",
    "title": "The Borsuk-Ulam Theorem Implies Arrow's Impossibility: Social Choice Is Topology",
    "description": "Arrow's impossibility theorem states that no ranked voting system can be fair (Pareto efficient, non-dictatorial, and independent of irrelevant alternatives). The Borsuk-Ulam theorem states that every continuous function f: S^n -> R^n maps some pair of antipodal points to the same value: f(x) = f(-x). Conjecture: Arrow's theorem is a corollary of Borsuk-Ulam. Specifically, define the 'preference sphere' S^{n-1} as the set of all preference profiles over n alternatives, where antipodal points represent opposite preferences (x prefers A > B > C, -x prefers C > B > A). Define f: S^{n-1} -> R^{n-1} by f(x) = (social_preference(x)_1, ..., social_preference(x)_{n-1}). By Borsuk-Ulam, there exists x such that f(x) = f(-x), meaning the social preference for profile x equals the social preference for profile -x. This contradicts Pareto efficiency (if all voters prefer A to B, the social preference should prefer A to B). Therefore, no continuous voting function satisfies all of Arrow's axioms. Conjecture: this proof generalizes: any social choice function on n alternatives is either discontinuous or dictatorial. Test: formalize the Borsuk-Ulam proof of Arrow's theorem in Lean 4. Impact: social choice theory is topology. Arrow's impossibility is a topological theorem about spheres.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.86,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.691072+00:00"
  },
  {
    "id": "fd_0005",
    "title": "Phantom Topologies: Spaces That Change When You Look at Them",
    "description": "What if the topology of a space depended on who is observing it? Define a phantom topology on a set X as a function T: O -> Top(X) that assigns to each observer o a topology T(o) on X. Two observers o1, o2 agree on an open set U if U is open in both T(o1) and T(o2). The phantom number of (X, T) is the minimum number of observers needed to determine the topology: if U is open in every T(o) that contains a point x, then U is a neighborhood of x in the 'real' topology. Conjecture: Every second-countable space (X, tau) admits a phantom representation with at most 2 observers (the real topology is the intersection of two phantom topologies). Moreover, every non-metrizable space requires at least 3 observers. The intuition: the real topology is what ALL observers agree on, and phantom topologies are what individual observers see. Like quantum mechanics, measurement changes the topology. Test: prove that R with the standard topology is the intersection of the lower limit topology and the upper limit topology (2 observers). Prove that the Zariski topology on R^2 requires at least 3 observers. Impact: a new notion of topology where the space itself depends on the observer \u2014 the mathematical formalization of 'reality depends on the observer'.",
    "domains": [
      "Novelty",
      "Topology"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.491025+00:00"
  },
  {
    "id": "fd_0033",
    "title": "Fractal Dimension of Proof Search: How Hard Is It to Find a Proof?",
    "description": "When a theorem prover searches for a proof, it explores a tree of possible derivation steps. The branching factor is the number of applicable inference rules at each step. Define the proof-search fractal dimension D(T) of a theorem T as the Hausdorff dimension of the set of all successful proof paths for T. If D(T) < 1, the proof is 'easy' (few paths work, so search is focused). If D(T) > 1, the proof is 'hard' (many paths must be explored). Conjecture: For theorems in ZFC, D(T) = 1 + O(1/length(T)). In other words, most theorems have fractal dimension close to 1 \u2014 proof search is neither trivially easy nor impossibly hard, but balanced at the edge. Theorems with D(T) << 1 are 'obvious' (direct proofs), and theorems with D(T) >> 1 require exponentially long proofs. The fractal dimension correlates with proof length: if D(T) = 1 + epsilon, then the shortest proof of T has length roughly 1/epsilon. Test: for 1000 theorems in Lean 4's Mathlib, estimate D(T) by Monte Carlo sampling of proof search trees, and correlate with actual proof length. Impact: proof difficulty is a fractal \u2014 the dimension of the proof search space determines how hard the theorem is.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.533762+00:00"
  },
  {
    "id": "fd_0041",
    "title": "Langlands for Toddlers: Galois Groups as Shapes, Automorphic Forms as Colors",
    "description": "The Langlands program connects Galois groups (shapes) to automorphic forms (colors). Think of it this way: a Galois group is the group of symmetries of a shape (like the rotational symmetries of a polygon). An automorphic form is a coloring that respects the shape's symmetries (like a coloring of the polygon's vertices that is invariant under rotation). The Langlands correspondence says: for every 'shape' (Galois representation), there is a matching 'color' (automorphic form) and vice versa. Conjecture: This correspondence is a bijection between irreducible representations of Gal(Q_bar/Q) and cuspidal automorphic representations of GL_n over Q. For n=1, this is class field theory (every abelian extension of Q corresponds to a Dirichlet character). For n=2, this is the modularity theorem (every elliptic curve over Q corresponds to a weight-2 cusp form). The toddler version: each shape has exactly one matching color, and each color has exactly one matching shape. Test: verify the correspondence for all degree-2 extensions of Q up to discriminant 1000. Verify that each quadratic field Q(sqrt(d)) corresponds to a Dirichlet character chi_d via the correspondence chi_d(p) = (d/p) (Legendre symbol). Impact: Langlands is just shape-color matching. Shapes and colors are two ways of seeing the same mathematical object.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.557538+00:00"
  },
  {
    "id": "fd_0058",
    "title": "Cryptography from Chaos: Encrypting with the Logistic Map",
    "description": "The logistic map f(x) = r*x*(1-x) for r = 4 exhibits chaotic dynamics: small changes in initial conditions lead to exponentially diverging trajectories (Lyapunov exponent lambda = log(2)). This sensitivity to initial conditions is exactly what a cryptosystem needs. Conjecture: The logistic map at r = 4 is a secure pseudorandom generator. Define the logistic cipher: key = (x_0, n) where x_0 in (0,1) is the seed and n is the number of iterations. The keystream is K = (f^n(x_0), f^{n+1}(x_0), ...) where f^n denotes the n-th iterate. The ciphertext is C = M XOR K where M is the plaintext. The security relies on two properties: (1) Sensitivity: a change of epsilon in x_0 leads to a change of O(1) in f^n(x_0) after n = O(log(1/epsilon)) iterations (exponential sensitivity). (2) Ergodicity: the distribution of f^n(x_0) converges to the invariant measure mu(x) = 1/(pi*sqrt(x*(1-x))) regardless of the initial condition. Conjecture: breaking the logistic cipher (recovering x_0 from K) is as hard as inverting the logistic map, which requires solving a degree-2^n polynomial (since f^n(x) is a polynomial of degree 2^n). This is exponential in n. Test: implement the logistic cipher, measure the period of the keystream (which should be at least 2^n for floating-point precision n), and verify that statistical tests (NIST SP 800-22) pass for n >= 64. Impact: chaos IS cryptography \u2014 the logistic map's sensitivity to initial conditions is the same property that makes encryption secure.",
    "domains": [
      "Novelty",
      "Cryptography"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.621662+00:00"
  },
  {
    "id": "fd_0074",
    "title": "The Collatz Conjecture Is Undecidable: What If 3n+1 Can't Be Proved?",
    "description": "The Collatz conjecture (3n+1 problem) states that every positive integer eventually reaches 1 under the map T(n) = n/2 (n even) or 3n+1 (n odd). Despite being verified up to 2^68, a proof remains elusive. Conjecture: the Collatz conjecture is independent of Peano Arithmetic (PA). That is, PA can neither prove nor refute the statement 'for all n, the Collatz sequence starting at n eventually reaches 1'. This would mean the conjecture is TRUE (in the standard model) but UNPROVABLE in PA. The argument: the Collatz map is a Diophantine function that grows faster than any provably total computable function in PA. Specifically, the halting problem for Collatz (does the orbit of n reach 1?) is at least as hard as the consistency of PA, which by Godel's second incompleteness theorem is unprovable in PA. Conjecture: the Collatz conjecture is equivalent to Con(PA) over a weak base theory, meaning that if PA is consistent, then PA does not prove Collatz. Test: formalize the equivalence between Collatz and Con(PA) in Lean 4. Show that a counterexample to Collatz (an n whose orbit diverges or cycles) would imply not-Con(PA). Impact: Collatz might be the simplest true-but-unprovable statement in arithmetic \u2014 a concrete example of Godel's incompleteness.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.700907+00:00"
  },
  {
    "id": "fd_0089",
    "title": "Stone Duality for Machine Learning: Neural Networks as Geometric Realizations",
    "description": "Stone duality states that every Boolean algebra B is isomorphic to the clopen algebra of its Stone space S(B) (the space of ultrafilters on B). This connects syntax (Boolean algebra) with semantics (topology). Conjecture: every neural network f: R^n -> R^m has a 'Stone dual' which is a Boolean algebra B(f) such that the clopen sets of S(B(f)) correspond to the decision regions of f. Specifically, for a binary classifier f: R^n -> {0, 1}, the decision regions {x : f(x) > 0} and {x : f(x) <= 0} are clopen sets in the Stone topology, and the Boolean algebra B(f) is generated by the hyperplanes that form the decision boundary. For a ReLU network with L layers: B(f) is generated by the w_1 + ... + w_L hyperplanes defined by each neuron. The Stone space S(B(f)) has 2^{w_1+...+w_L} points (one for each possible activation pattern), and the decision boundary of f is a subset of S(B(f)). Conjecture: the VC dimension of f equals the number of atoms in B(f), which equals the number of linear regions of f. Test: compute B(f) for small ReLU networks and verify the VC dimension equals the number of linear regions. Impact: neural networks have Stone duals. The Boolean algebra of activation patterns is the syntax, and the decision boundary is the semantics.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.789392+00:00"
  },
  {
    "id": "fd_0126",
    "title": "Counterfactual Number Theory: What If Primes Were Random?",
    "description": "Construct an alternate number theory where primes are replaced by a random subset of N with density n/log n. Prove which theorems survive (Dirichlet, PNT) and which collapse (unique factorization). Determine whether RH holds almost surely in this counterfactual universe.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.018128+00:00"
  },
  {
    "id": "fd_0158",
    "title": "Rigorous formal bridge between knot theory and",
    "description": "# Future Research Directions: Knotted Light and Knot Polynomial Spectra\n\n## Synthesis\n\nThis research cycle established a rigorous formal bridge between knot theory and structured light optics, proving that the Alexander polynomials of torus knots coincide with cyclotomic polynomials (trefoil \u2194 \u03a6\u2086, cinquefoil \u2194 \u03a6\u2081\u2080). This identification transforms the abstract knot invariant into a spectral constraint on the orbital angular momentum (OAM) of knotted laser beams. The palindromic root theorem provides a sharp algebraic dichotomy: knots with \"small\" linear coefficient (|b| < 2 in t\u00b2 + bt + 1) have OAM spectra governed by unit-circle roots (discrete, crystalline), while those with |b| \u2265 2 have real roots (continuous, metallic). The divisibility theorems \u0394_K | t^N \u2212 1 establish the periodicity of these spectra.\n\nThe most promising cross-domain connection is between **number theory (cyclotomic fields)** and **photonic topology**: cyclotomic polynomials simultaneously govern the splitting of prime ideals in number fields and the OAM modes of structured light. This suggests a deeper arithmetic structure underlying knotted photonics. Connections to the existing Catalog \u2014 particularly the Berggren tree structures in `Cryptography/BerggrenDiophantineLattice.lean` (which involve Lorentz forms and Pythagorean vectors) and the tropical algebraic structures in `Tropical/` \u2014 suggest that arithmetic geometry may provide a unifying language.\n\nThe direction with highest breakthrough potential is Direction 1 (Jones Polynomial in Polarization), because it would extend the Alexander-OAM correspondence to a richer invariant and connect to topological quantum computing through the Temperley-Lieb algebra.\n\n---\n\n### Direction 1: Jones Polynomial Encoding in Polarization Spectra of Knotted Light\n\n**Conjecture**: For a knotted light beam whose phase singularity traces a knot K, the Jones polynomial V_K(t) is encoded in the *polarization* structure of the beam, distinct from the OAM spectrum which encodes the Alexander polynomial. Specifically, the Stokes parameters of the beam at different angular positions around the singularity reconstruct the Jones polynomial evaluated at roots of unity.\n\n**Test**: For the trefoil knot (V_{3\u2081}(t) = \u2212t\u207b\u2074 + t\u207b\u00b3 + t\u207b\u00b9), compute the Stokes parameters of a simulated trefoil beam at N points around the singularity. The discrete Fourier transform of the Stokes parameter S\u2083(\u03c6) should have nonzero components at frequencies corresponding to the exponents {\u22124, \u22123, \u22121} of the Jones polynomial.\n\n**Impact**: If true, this would mean that a single knotted light beam simultaneously encodes both the Alexander and Jones polynomials in different physical observables (OAM vs. polarization), providing a complete topological fingerprint readable with standard optical measurements. If false, understanding why the Jones polynomial resists physical encoding would illuminate the difference between classical and quantum knot invariants.\n\n**Catalog References**: `Bridges/KnottedLightTopology.lean` (Alexander polynomial definitions and cyclotomic theorems), `Algebra/Advanced.lean` (iteration structures)\n\n**Proof Strategy**: (1) Define the Jones polynomial for specific knots as Laurent polynomials over \u2124[t^{\u00b11}]. (2) Model the polarization state of a knotted beam using the Stokes-Mueller formalism. (3) Prove that the winding number of the polarization ellipse around the singularity is related to the writhe of the knot (which appears in the Jones polynomial). (4) Use the skein relation of the Jones polynomial to establish an inductive structure matching the beam superposition algebra.\n\n**Domain Bridges**: Knot Theory \u2194 Quantum Optics \u2194 Topological Quantum Computing (Jones polynomial is the partition function of Chern-Simons theory, which also governs anyonic braiding)\n\n**Lineage**: Builds on the trefoil_is_cyclotomic_six and cinquefoil_is_cyclotomic_ten theorems from this cycle, extending from Alexander to Jones.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Tropical Alexander Polynomials and Beam Caustic Geometry\n\n**Conjecture**: The tropical (min-plus) version of the Alexander polynomial, obtained by replacing addition with min and multiplication with addition, governs the *caustic structure* (bright-line singularities) of knotted light beams in the geometric optics limit. Specifically, the tropical Alexander polynomial \u0394_K^{trop}(t) describes the piecewise-linear geometry of the beam's caustic network in a cross-sectional plane.\n\n**Test**: For the trefoil, compute the tropical version of t\u00b2 \u2212 t + 1, which is min(2t, t, 0) = the lower envelope of three lines. The breakpoints of this piecewise-linear function (at t = 0 and t = 1) should correspond to the angular positions of caustic lines in a trefoil beam's cross-section. Simulate this numerically and compare.\n\n**Impact**: Tropical geometry has been recognized as a bridge between algebraic geometry and combinatorics. If the tropical Alexander polynomial governs caustics, it would provide a new geometric interpretation of tropicalization and connect the existing tropical algebra formalization in the Catalog to physical optics.\n\n**Catalog References**: `Tropical/` (tropical algebraic structures), `Bridges/AlgebraTropicalGeometry/` (algebra-tropical bridges), `Bridges/KnottedLightTopology.lean`\n\n**Proof Strategy**: (1) Define tropical polynomials in Lean (min-plus semiring). (2) Prove that tropicalization commutes with the Alexander polynomial's evaluation at t = e^{\u2212s/\u03b5} in the limit \u03b5 \u2192 0. (3) Connect the Newton polygon of the Alexander polynomial to the caustic structure via the Legendre transform.\n\n**Domain Bridges**: Tropical Geometry \u2194 Optics \u2194 Knot Theory (tropical curves \u2194 caustics \u2194 knot invariants)\n\n**Lineage**: Builds on trefoil_divides_t6_minus_1 and the polynomial structure theorems from this cycle. Extends the Catalog's tropical algebra to a new application domain.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Higher Genus Alexander Modules and Multi-Singularity Beams\n\n**Conjecture**: For a knotted light beam whose singularity traces a knot K of Seifert genus g, the beam supports exactly 2g independent OAM mode families. The Alexander module H\u2081(S\u00b3 \\ K; \u2124[t^{\u00b11}]) has rank 2g over \u2124[t^{\u00b11}], and each generator corresponds to an independent family of stable beam modes.\n\n**Test**: The trefoil has genus 1 (degree 2 Alexander polynomial) and should support 2 mode families (OAM = 1 and OAM = 5 mod 6). The cinquefoil has genus 2 (degree 4) and should support 4 mode families. Verify numerically by computing the mode spectrum of cinquefoil beams and checking for exactly 4 dominant mode families.\n\n**Impact**: This would establish the Seifert genus \u2014 a fundamental 3-manifold invariant \u2014 as a directly measurable physical quantity in structured light, extending the degree-genus connection we proved (trefoil_degree = 2, cinquefoil_degree = 4) to a full spectral correspondence.\n\n**Catalog References**: `Bridges/KnottedLightTopology.lean` (trefoil_degree, cinquefoil_degree, OAMSpectrum definition)\n\n**Proof Strategy**: (1) Define the Seifert matrix of a knot from a Seifert surface presentation. (2) Prove that the Alexander polynomial equals det(V \u2212 tV^T) where V is the Seifert matrix. (3) Show that the rank of the Alexander module (= degree of \u0394_K) equals 2g. (4) Connect generators of the Alexander module to independent OAM modes via the Mayer-Vietoris sequence of the knot complement.\n\n**Domain Bridges**: Algebraic Topology \u2194 Photonics \u2194 Representation Theory (Seifert surfaces \u2194 beam modes \u2194 module generators)\n\n**Lineage**: Directly extends the degree theorems (trefoil_degree, cinquefoil_degree) from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Palindromic Discriminant Classification of Knotted Beam Stability\n\n**Conjecture**: The palindromic root theorem (our palindromic_complex_roots_on_unit_circle) generalizes to higher-degree palindromic polynomials: a degree-2g palindromic polynomial p(t) = \u03a3 a\u2096 t^k with a_k = a_{2g\u2212k} has all roots on the unit circle if and only if a specific Hermitian matrix constructed from its coefficients is positive definite. For g = 1, this reduces to |b| < 2.\n\n**Test**: Construct the Hermitian matrix for the cinquefoil polynomial (degree 4, g = 2) and verify it is positive definite. Then construct a degree-4 palindromic polynomial with roots off the unit circle (e.g., t\u2074 \u2212 5t\u00b3 + 9t\u00b2 \u2212 5t + 1) and verify the matrix is not positive definite.\n\n**Impact**: A complete characterization of when palindromic Alexander polynomials have all roots on the unit circle would classify which knotted beams have purely discrete OAM spectra. This is relevant to beam stability: unit-circle roots correspond to phase-coherent modes that propagate without decay.\n\n**Catalog References**: `Bridges/KnottedLightTopology.lean` (palindromic_complex_roots_on_unit_circle, trefoil_palindromic, figureEight_palindromic)\n\n**Proof Strategy**: (1) Express the palindromic polynomial as p(t) = t^g \u00b7 q(t + t\u207b\u00b9) for a real polynomial q. (2) The roots of p lie on the unit circle iff q has all real roots in [\u22122, 2]. (3) Apply the Hermite-Biehler theorem to characterize when q has all roots in an interval. (4) Translate this to a positive-definiteness condition on a Toeplitz matrix built from the coefficients.\n\n**Domain Bridges**: Linear Algebra \u2194 Knot Theory \u2194 Signal Processing (Hermitian matrices \u2194 palindromic polynomials \u2194 spectral analysis)\n\n**Lineage**: Directly generalizes palindromic_complex_roots_on_unit_circle from quadratic to arbitrary even degree.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Arithmetic of Knot Determinants and Prime Factorization\n\n**Conjecture**: The knot determinant det(K) = |\u0394_K(\u22121)| determines the structure of the first homology group H\u2081(\u03a3\u2082(K); \u2124) of the double branched cover of S\u00b3 branched along K. For prime determinant p, this group is \u2124/p\u2124. The multiplicativity under connected sum (our connectedSum_eval_one) implies that knot determinants form a multiplicative monoid, and the prime factorization of det(K\u2081 # K\u2082) = det(K\u2081) \u00b7 det(K\u2082) reflects the decomposition of the homology group.\n\n**Test**: Verify that the trefoil (det = 3) has H\u2081(\u03a3\u2082) = \u2124/3\u2124, the figure-eight (det = 5) has H\u2081(\u03a3\u2082) = \u2124/5\u2124, and the granny knot (det = 9) has H\u2081(\u03a3\u2082) = \u2124/3\u2124 \u00d7 \u2124/3\u2124. Formalize the double branched cover construction and compute its homology.\n\n**Impact**: This connects knotted light (via measurable determinants) to the arithmetic of 3-manifolds. The prime factorization of a beam's measured determinant would directly reveal the homological structure of the associated branched cover \u2014 reading 3-manifold topology from laser light.\n\n**Catalog References**: `Bridges/KnottedLightTopology.lean` (trefoil_determinant, figureEight_determinant, grannyKnot_determinant, connectedSum_eval_one), `Cryptography/BerggrenDiophantineLattice.lean` (arithmetic structures)\n\n**Proof Strategy**: (1) Define the double branched cover \u03a3\u2082(K) via the presentation from the knot group. (2) Prove that H\u2081(\u03a3\u2082(K)) has order |\u0394_K(\u22121)|. (3) Use the Smith normal form to compute the group structure from the presentation matrix. (4) Prove multiplicativity under connected sum using the Mayer-Vietoris sequence.\n\n**Domain Bridges**: Knot Theory \u2194 Algebraic Number Theory \u2194 Homological Algebra (knot determinants \u2194 primes \u2194 homology groups)\n\n**Lineage**: Directly extends the determinant computations from this cycle (trefoil_determinant = 3, figureEight_determinant = 5, grannyKnot_determinant = 9).\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "priority_score": 0.85,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "9096062f",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T16:01:45.279078+00:00"
  },
  {
    "id": "fd_0047",
    "title": "The Zeta Function of a Graph: Number Theory on Networks",
    "description": "The Ihara zeta function of a finite graph G is zeta_G(u) = prod_{[C]} (1 - u^{|C|})^{-1} where the product is over prime cycles (closed walks that are not powers of shorter walks). For a (q+1)-regular graph, zeta_G(u) = (1-u^2)^{-(n-1)(q-1)/2} * det(I - A*u + (q-1)*u^2*I)^{-1} where A is the adjacency matrix. This is the graph analog of the Riemann zeta function. Conjecture: The Riemann hypothesis holds for zeta_G if and only if G is a Ramanujan graph (all non-trivial eigenvalues of the adjacency matrix satisfy |lambda| <= 2*sqrt(q)). This is a theorem of Ihara, but the deeper conjecture is: the zeta function of a Ramanujan graph encodes the same spectral information as the Riemann zeta function restricted to the critical strip. Specifically, if zeta_G satisfies RH, then the 'prime cycles' of G are distributed like the primes in Z, and the 'explicit formula' for zeta_G (analogous to the explicit formula for the Riemann zeta) relates the cycle counts to the eigenvalues of A. Test: compute zeta_G for 10 Ramanujan graphs (paley graphs, lubotzky-phillips-sarnak graphs) and verify the Riemann hypothesis. Compare the 'prime cycle counting function' with the prime counting function pi(x). Impact: graphs have zeta functions, Ramanujan graphs satisfy RH, and the prime cycles in a graph are distributed like the primes in Z.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.578133+00:00"
  },
  {
    "id": "fd_0056",
    "title": "The Fourier Transform of the Riemann Zeta: Hearing the Primes",
    "description": "The Riemann zeta function zeta(s) has zeros at the non-trivial points s = 1/2 + i*gamma_n where gamma_n are the imaginary parts of the zeros. The Fourier transform of the zero counting function N(t) = #{gamma_n <= t} is related to the distribution of primes by the explicit formula. But what if we take the Fourier transform of zeta itself? Define Z(t) = zeta(1/2 + it) as a function of the real variable t. The Fourier transform Z_hat(w) = integral_{-inf}^{inf} Z(t) * e^{-2*pi*i*w*t} dt. Conjecture: Z_hat(w) has sharp peaks at w = log(p)/2*pi for each prime p. This is because the explicit formula expresses zeta(1/2+it) as a sum over primes: zeta(1/2+it) ~ sum_{p} p^{-1/2-it} = sum_{p} e^{-it*log(p)} / sqrt(p), which is a sum of complex exponentials with frequencies log(p). The Fourier transform of a sum of exponentials is a sum of delta functions at the frequencies log(p)/2*pi. So Z_hat(w) = sum_{p} delta(w - log(p)/2*pi) / sqrt(p) + (error from zeros and smooth terms). The peaks at w = log(p)/2*pi give a 'spectrogram' of the primes. Test: compute Z_hat(w) numerically for the first 10^6 zeros and verify the peaks at log(2)/2*pi, log(3)/2*pi, log(5)/2*pi, etc. Impact: you can HEAR the primes by playing the Fourier transform of the Riemann zeta function \u2014 each prime is a distinct note.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.612729+00:00"
  },
  {
    "id": "fd_0104",
    "title": "Cellular Automata at the Ordinals: Transfinite Computation",
    "description": "Prove that cellular automata can perform transfinite computations when run on ordinals instead of N. Formalize a Rule 110 analog on omega-squared and prove it achieves super-Turing computation. Connect to Infinite Time Turing Machines and ordinal computation.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.883358+00:00"
  },
  {
    "id": "fd_0111",
    "title": "Non-Desarguesian Worlds: Geometry Without Desargues",
    "description": "Construct and classify finite projective planes where Desargues' theorem fails. Prove that such planes exist at every prime power order and that their collineation groups are strictly smaller than PGL. Formalize the connection to non-associative division algebras and Hall triple systems.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "priority_score": 0.84,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.925627+00:00"
  },
  {
    "id": "fd_0050",
    "title": "Fractal Number Theory: Hausdorff Dimension of Prime Distributions",
    "description": "The primes have density 0 in the integers, but what is the Hausdorff dimension of the set of primes viewed as a subset of R? Define the 'prime fractal' P as the set of primes with the metric d(p,q) = |1/log(p) - 1/log(q)|. This metric stretches out the primes so that the twin primes are close together and the large primes are spread out. Conjecture: The Hausdorff dimension dim_H(P, d) = 1. The primes with this metric are essentially a 1-dimensional set \u2014 they fill out a line when viewed through the logarithmic lens. This is because the prime number theorem pi(x) ~ x/log(x) means that in the d-metric, the 'length' of the primes up to x is sum_{p <= x} d(p, p+1) ~ sum_{p <= x} 1/(p*log(p)) ~ log(log(x)), which diverges. So the primes are 'long enough' to be 1-dimensional. But the Hausdorff dimension might be > 1 if the primes have fractal structure at small scales. In fact, dim_H(P, d) > 1 would mean the primes are more than a line \u2014 they have 'wrinkles' that fill more space. The twin prime conjecture predicts that there are infinitely many pairs of primes at d-distance ~ 1/(p*log(p)), creating a fractal dust that increases the dimension. Conjecture: dim_H(P, d) = 1 + epsilon where epsilon depends on the density of twin primes. If the twin prime conjecture is true, epsilon > 0. Test: estimate dim_H(P, d) by box-counting for primes up to 10^12 and verify it is close to 1 (or slightly above). Impact: the primes are a fractal with dimension 1 + epsilon, where epsilon measures the abundance of twin primes. If twin primes are infinite, the primes are more than a line \u2014 they are a fractal curve.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.589354+00:00"
  },
  {
    "id": "fd_0112",
    "title": "Negative-Dimensional Topology: What Lives in Dimension -1?",
    "description": "Develop a rigorous theory of negative-dimensional spaces using pro-spectra and formal dimension theory. Prove that Euler characteristic extends to negative dimensions and that chi(X) for dim X = -n satisfies chi = (-1)^n \u00b7 |pi_0(X)|. Formalize the stabilization map from negative to positive dimensions.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.931857+00:00"
  },
  {
    "id": "fd_0131",
    "title": "Fermat Near-Misses in the Twilight Zone",
    "description": "Study near-misses to Fermat's Last Theorem: triples (a,b,c) where |a^n + b^n - c^n| is small. Prove that such near-misses exist for every n and characterize their distribution. Show that the density of near-misses decreases super-exponentially and connect to the ABC conjecture's effective version.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.048933+00:00"
  },
  {
    "id": "fd_0136",
    "title": "The Mega-Sphere: All Dimensions at Once",
    "description": "Construct a single algebraic object whose projections give S^0, S^1, S^2, ... simultaneously. Prove it exists as an inverse limit in the category of spheres. Show that its homology groups encode the Bernoulli numbers and that its cohomology ring is the polynomial ring on Stiefel-Whitney classes.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "priority_score": 0.83,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.079824+00:00"
  },
  {
    "id": "fd_0004",
    "title": "The Library of Babel: Combinatorics of the Universal Library",
    "description": "Borges' Library of Babel contains every possible 410-page book \u2014 approximately 25^{1312000} volumes. The library is finite but vast beyond comprehension. Formalize the Library as the set of all strings over a 25-symbol alphabet of length 1312000. Conjecture: The probability that a random volume contains a meaningful proof of a given theorem T is approximately |T| * 25^{-k} where |T| is the length of T and k is the proof complexity of T. Moreover, the Library contains a universal catalog \u2014 a single volume that encodes the location of every other volume \u2014 and this catalog can be found in polynomial time using a variant of the de Bruijn sequence construction. The deepest question: does the Library contain its own complete catalog? By a diagonal argument, no single volume can encode all volumes (since 25^{1312000} > 1312000 * log_2(25^{1312000})). But a DISTRIBUTED catalog spanning N volumes can encode the entire Library if N > 25^{1312000} / (1312000 * log_2(25)). Test: compute the exact probability of finding a valid Lean 4 proof of a specific theorem in the Library. Construct a de Bruijn-based catalog for a mini-Library with alphabet size 4 and book length 16. Impact: the mathematics of universal information spaces \u2014 every possible text exists, but finding meaning requires a guide.",
    "domains": [
      "Novelty",
      "Combinatorics"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.490561+00:00"
  },
  {
    "id": "fd_0057",
    "title": "Persistent Homology of Prime Numbers: The Topology of Arithmetic",
    "description": "The sequence of primes 2, 3, 5, 7, 11, 13, ... defines a point cloud in R where the n-th prime p_n is at position p_n on the real line. The gaps between primes create a topological structure. Define the persistent homology of the prime point cloud as the Rips filtration R_epsilon = {p_n : |p_m - p_n| <= epsilon}. As epsilon increases, more primes are connected, and the topology changes. Conjecture: The persistent H_0 (connected components) of the prime point cloud has the same barcode as a Poisson point process with intensity 1/log(x). Specifically, the bar lengths in H_0 follow an exponential distribution with mean equal to the average prime gap (which is approximately log(x) by the prime number theorem). The persistent H_1 (1-dimensional holes) of the prime point cloud appears at scale epsilon ~ log(x)^2, corresponding to prime pairs (p, p+2k) where 2k is a specific even gap. The longest H_1 bar corresponds to the twin prime conjecture: it persists from epsilon = 2 (the twin prime scale) to epsilon = infinity. Test: compute persistent homology of the primes up to 10^6 using Rips filtration and compare with the Poisson point process prediction. Verify that H_0 bar lengths are exponentially distributed with mean log(x). Impact: primes have topology \u2014 their gaps create persistent homology that encodes the twin prime conjecture and other arithmetic properties.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.617168+00:00"
  },
  {
    "id": "fd_0128",
    "title": "Aleph-1 Surface: Geometry Between Dimensions",
    "description": "Construct a surface whose Hausdorff dimension is exactly aleph-1 (assuming CH). Prove that such a surface cannot be embedded in any finite-dimensional Euclidean space but can be embedded in the Hilbert cube. Formalize transfinite-dimensional manifolds and prove they have no finite triangulation.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "priority_score": 0.82,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.030197+00:00"
  },
  {
    "id": "fd_0011",
    "title": "Knots That Think: Cognition as Braiding in Category Theory",
    "description": "The brain's connectome is a braid: neurons fire in sequences that interleave like strands of a braid group. Formalize this: a cognitive process is an element of the braid group B_n where n is the number of brain regions. Two cognitive processes are equivalent if their braids are related by Reidemeister moves (cognitive equivalence). Conjecture: The Jones polynomial of a cognitive braid is invariant under cognitive equivalence and encodes the information content of the thought. A thought with Jones polynomial V(t) = 1 is a trivial thought (equivalent to no thinking). A thought with V(t) = -t^2 + t + 1 is a creative thought (it contains a trefoil knot \u2014 the simplest non-trivial braid). The information content of a thought is log(|V(e^{2pi i/3})|), which measures the quantum dimension of the braid. Test: compute the Jones polynomial of braids representing simple cognitive processes (linear reasoning: trivial braid, creative insight: trefoil, confused thinking: figure-eight knot) and verify that the quantum dimension correlates with subjective ratings of thought quality. Impact: thinking IS braiding. The topology of your thoughts determines their quality. Creative insights are literally knotted.",
    "domains": [
      "Novelty",
      "Topology"
    ],
    "priority_score": 0.81,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.494775+00:00"
  },
  {
    "id": "fd_0025",
    "title": "Impossible Geometries: Where Parallel Lines Converge AND Diverge",
    "description": "Euclid's parallel postulate says parallel lines never meet. Hyperbolic geometry says they can diverge. Elliptic geometry says they converge. But what about a geometry where parallel lines BOTH converge AND diverge? Define a Split Geometry on R^2 where the parallel postulate is direction-dependent: lines parallel to the x-axis diverge (hyperbolic behavior) while lines parallel to the y-axis converge (elliptic behavior). The metric is ds^2 = dx^2/cosh^2(y) + dy^2 * cosh^2(x) \u2014 expanding in x and contracting in y. Conjecture: Split Geometry is a consistent Riemannian geometry with curvature K(x,y) = -sech^2(y) + sech^2(x) that changes sign across the diagonals. The geometry has a 'phase boundary' along the lines y = x and y = -x where K = 0 (flat). In the region |x| > |y|, K > 0 (elliptic) and in the region |y| > |x|, K < 0 (hyperbolic). The geodesics in split geometry are piecewise combinations of exponential curves (in hyperbolic regions) and trigonometric curves (in elliptic regions). Test: compute the Christoffel symbols and curvature tensor for the split metric. Prove that geodesics cross the phase boundary at most twice. Compute the area of a split triangle with one vertex in each region. Impact: a geometry where the curvature of space depends on which direction you look \u2014 the mathematical realization of a universe that is simultaneously expanding and contracting.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "priority_score": 0.81,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.514276+00:00"
  },
  {
    "id": "fd_0053",
    "title": "The Uncertainty Principle Is a Fourier Thing: Position-Momentum Duality",
    "description": "The Heisenberg uncertainty principle states that Delta(x) * Delta(p) >= hbar/2. But this is NOT a physical principle \u2014 it is a THEOREM of Fourier analysis. The Fourier transform of a function f(x) satisfies: if f is concentrated in a region of width Delta(x), then its Fourier transform f_hat is concentrated in a region of width Delta(k) >= 1/(2*Delta(x)). This is the Benedicks-Amrein-Berthier theorem: a function and its Fourier transform cannot both be supported on sets of finite measure. Conjecture: The uncertainty principle generalizes to all integral transforms. For the Laplace transform: if f is supported on [a, infinity), then the Laplace transform L[f](s) cannot be supported on a set of finite measure unless f = 0. For the Mellin transform: if f is supported on a geometric progression, then M[f](s) cannot be supported on a set of finite measure. For the Radon transform: if f is supported on a strip, then R[f] cannot be supported on a set of finite measure. The general principle: no invertible integral transform allows both a function and its transform to have compact support. Test: verify the uncertainty principle for the Fourier, Laplace, Mellin, and Radon transforms numerically. Construct functions with Delta(x) = epsilon and measure Delta(k) for each transform. Impact: the uncertainty principle is not about quantum mechanics \u2014 it is about the structure of integral transforms. Every transform has its own uncertainty principle.",
    "domains": [
      "Novelty",
      "Analysis"
    ],
    "priority_score": 0.81,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.600658+00:00"
  },
  {
    "id": "fd_0127",
    "title": "Borges' Library of Babel: Combinatorics of Everything",
    "description": "Compute the topological type of the Library of Babel: a space of all possible 410-page books. Prove that it is connected, totally disconnected under the Hamming metric, and has covering dimension 0. Determine the Kolmogorov complexity of a random book and prove that almost all books are incompressible.",
    "domains": [
      "Novelty",
      "Combinatorics"
    ],
    "priority_score": 0.81,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:31.024124+00:00"
  },
  {
    "id": "fd_0020",
    "title": "The Unreasonable Effectiveness of the Number 163",
    "description": "Ramanujan's constant e^{pi*sqrt(163)} is remarkably close to an integer: it equals 262537412640768743.99999999999925... \u2014 just 7.5 * 10^{-13} away from 262537412640768744. This is not a coincidence: 163 is the largest Heegner number, and the near-integer property follows from the j-function and the fact that Q(sqrt(-163)) has class number 1. But 163 appears EVERYWHERE: it is prime, it is the smallest p such that Q(sqrt(-p)) has class number 1 and p > 2, it is a Chen prime, a lucky prime, a strongly prime, and the 38th prime. Conjecture: 163 is the unique integer n such that e^{pi*sqrt(n)} is within 10^{-6} of an integer. More generally, the Heegner numbers (1, 2, 3, 7, 11, 19, 43, 67, 163) are exactly the n for which Q(sqrt(-n)) has class number 1, and e^{pi*sqrt(n)} is near-integer for each. The 'magic' of 163 is that it is the LAST Heegner number \u2014 the final class number 1 imaginary quadratic field. Test: prove that e^{pi*sqrt(n)} is within 10^{-6} of an integer only for Heegner numbers. Compute e^{pi*sqrt(67)} and e^{pi*sqrt(43)} and verify near-integer behavior. Prove that 163 is the largest Heegner number (Stark-Heegner theorem). Impact: 163 is not magic \u2014 it is the climax of a deep theorem in algebraic number theory. The near-integer property of e^{pi*sqrt(163)} is the shadow of the class number 1 condition.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.505215+00:00"
  },
  {
    "id": "fd_0032",
    "title": "The Mandelbrot Set's Secret Number Theory: Quadratic Recurrence and Primality",
    "description": "The Mandelbrot set M is defined by z_{n+1} = z_n^2 + c, and the boundary of M is the locus of c values where the orbit of 0 is bounded but barely so. Each bulb of M corresponds to a rational number p/q (the period-q bulb at angle p/q). The size of the p/q bulb decreases with q, and the Fibonacci sequence governs the spiral arrangement of bulbs. Conjecture: The period of the bulb at angle p/q (in lowest terms) is exactly q. Moreover, the Lyapunov exponent lambda(c) at the center of the p/q bulb equals log(2) * cos(pi*p/q). The 'prime bulbs' \u2014 bulbs at angles 1/q where q is prime \u2014 have special symmetry: they are the only bulbs with dihedral symmetry D_q. The composite bulbs have more complex symmetry groups. The prime factorization of the period determines the bulb's topology: a bulb of period n = p1^a1 * ... * pk^ak is topologically a product of k bulbs of periods p1^a1, ..., pk^ak. Test: for each rational p/q with q <= 20, locate the corresponding bulb in M, compute its Lyapunov exponent, and verify lambda = log(2) * cos(pi*p/q). Classify bulbs by the prime factorization of their period and verify the product structure. Impact: the Mandelbrot set is a visual calculator for prime factorization \u2014 every bulb encodes number-theoretic information about its period.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.530929+00:00"
  },
  {
    "id": "fd_0071",
    "title": "Galois Theory of Cellular Automata: Which Rules Have Reversible Dynamics?",
    "description": "A cellular automaton (CA) rule f: A^Z -> A^Z is a function from configurations to configurations. The CA is reversible if f is bijective. By Hedlund's theorem, a CA is reversible iff its local rule is a permutation. But which CA rules have reversible dynamics? Conjecture: the set of reversible CA rules of radius r on alphabet A is a group under composition, isomorphic to a subgroup of S_{|A|^{2r+1}}. Specifically, the reversibility group G(r, A) is the subgroup of S_{|A|^{2r+1}} generated by the local rules of all reversible CAs of radius r. Conjecture: for binary CAs (A = {0, 1}) with radius r, G(r, {0, 1}) = S_{2^{2r+1}} for r >= 2. This means that any permutation of the 2^{2r+1} possible local neighborhoods can be achieved by composing reversible CA rules. For r = 1 (elementary CAs), G(1, {0, 1}) is a proper subgroup of S_8, and its structure is related to the 256 elementary CA rules. Conjecture: G(1, {0, 1}) has order 8! / 4 = 10080, consisting of the permutations that commute with the shift operator. Test: enumerate all 256 elementary CA rules, identify the reversible ones (Rule 15, 51, 85, 170, 204, 240), compute the group generated by their local rules, and verify the structure. Impact: reversible CAs form a group whose structure determines the landscape of reversible computation.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.686157+00:00"
  },
  {
    "id": "fd_0103",
    "title": "Infinite-Dimensional Chess: Winning on the Hilbert Board",
    "description": "Formalize chess played on an infinite board. Prove that the king can always escape on an infinite board and determine which finite-piece configurations are forced mates. Develop a theory of infinite combinatorial game value and prove its relationship to ordinal game values.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.877377+00:00"
  },
  {
    "id": "fd_0113",
    "title": "The Topology of Impossible Objects: Escher Stairs and Klein Bottles",
    "description": "Formalize the mathematical conditions under which impossible figures (Penrose triangles, Escher stairs) can exist as manifolds. Prove that every non-orientable 3-manifold contains an embedded Penrose triangle as a smoothly immersed surface. Classify which impossible figures are realizable as developable surfaces.",
    "domains": [
      "Novelty",
      "Geometry"
    ],
    "priority_score": 0.8,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.937834+00:00"
  },
  {
    "id": "fd_0068",
    "title": "The Fourier Analysis of Collatz: Spectral Gaps in the 3n+1 Map",
    "description": "The Collatz map T: N -> N defined by T(n) = n/2 if n even, 3n+1 if n odd, is conjectured to always reach 1. The Collatz conjecture is equivalent to: the orbit of every n under T eventually reaches the cycle {1, 4, 2, 1}. Define the Collatz Fourier transform: F_T(omega) = sum_{n=1}^{N} e^{2*pi*i*omega*T(n)/n} for N large. Conjecture: F_T has a spectral gap: |F_T(omega)| < C for all irrational omega, where C < sqrt(N). This would mean that the Collatz map does not concentrate energy at any irrational frequency \u2014 it is 'mixing' in the Fourier sense. Moreover, the spectral gap is related to the convergence rate: the wider the gap, the faster the orbit reaches 1. Conjecture: for the orbit of n, the number of steps to reach 1 is O(log(n)), which is equivalent to F_T having a spectral gap of width Omega(1/log(n)). Test: compute F_T for n up to 10^6 and measure the spectral gap. Compare with the spectral gaps of related maps (5n+1, 7n+1) which do NOT always converge. Impact: the Collatz conjecture is a spectral gap problem. Convergence to 1 means the Fourier transform has no resonances at irrational frequencies.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.79,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.672038+00:00"
  },
  {
    "id": "fd_0096",
    "title": "The Poincare Conjecture for Data: Manifold Detection via Persistent Homology",
    "description": "The Poincare conjecture (proved by Perelman) states that every simply connected closed 3-manifold is homeomorphic to the 3-sphere. For data: a point cloud X = {x_1, ..., x_n} in R^d may or may not lie on a manifold. Conjecture: the Poincare conjecture for data states that if the persistent homology of X satisfies H_0(X) = Z, H_1(X) = 0, H_2(X) = 0, ..., H_{d-1}(X) = 0, then X lies on (or near) a d-sphere. More precisely, if the Vietoris-Rips complex of X at scale epsilon has the homology of S^d (trivial homology except H_0 = Z and H_d = Z), then X is epsilon-close to a subset of S^d. Conjecture: the smallest epsilon such that VR_epsilon(X) has the homology of S^d is the 'Poincare threshold' of X, and it satisfies epsilon_star = C * d^{1/2} * n^{-1/d} for some constant C, where n is the number of points. This is the manifold detection threshold: below epsilon_star, X looks like a d-sphere; above epsilon_star, X looks like something else. Test: generate point clouds on S^d for d = 1, 2, 3 and compute the Poincare threshold. Impact: the Poincare conjecture for data says that manifold detection is a topological problem, and the detection threshold scales as n^{-1/d}.",
    "domains": [
      "Novelty",
      "Topology"
    ],
    "priority_score": 0.79,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.834465+00:00"
  },
  {
    "id": "fd_0009",
    "title": "The Mathematics of Deja Vu: Fixed Points in Consciousness and Cognition",
    "description": "Deja vu \u2014 the feeling that you've experienced something before \u2014 is a fixed point in a dynamical system. Model cognitive state as a function f: S -> S mapping current brain state to next brain state. A deja vu is a state s such that f^n(s) = s for some n > 0 \u2014 a periodic point of the cognitive dynamical system. Conjecture: By Sharkovsky's theorem, the existence of a period-3 orbit in the cognitive dynamics (three distinct states that cycle) implies chaos in the sense of Li-Yorke, meaning there exist uncountably many cognitive trajectories that are neither periodic nor convergent. Moreover, the set of deja vu states (periodic points of f) is dense in the cognitive state space S if f is continuous and S is an interval. The frequency of deja vu (occurring in ~70% of people) corresponds to the natural density of periodic points in a typical chaotic map. Test: model cognitive dynamics as a logistic map f(x) = rx(1-x) on [0,1] with parameter r chosen to match empirical deja vu frequencies. For r = 3.83 (period-3 window), compute the density of periodic points and compare to the 70% lifetime incidence. Impact: deja vu is not a glitch \u2014 it's a mathematical inevitability of continuous cognitive dynamics. Any continuous cognitive map with a period-3 orbit MUST have deja vu.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.78,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.493320+00:00"
  },
  {
    "id": "fd_0030",
    "title": "The Prime Number Crossword: Filling the Gaps in the Primes",
    "description": "Prime gaps \u2014 the spaces between consecutive primes \u2014 are like empty cells in a crossword puzzle. The gaps are 1, 2, 2, 4, 2, 4, 2, 4, 6, 2, 6, 4, 2, 4, 6, 6, 2, 6, 4, 2, ... (OEIS A001223). The pattern seems random, but the crossword has rules: (1) All prime gaps are even (except the first gap of 1 between 2 and 3). (2) A gap g can only appear at position n if n+g is prime and all of n+1, n+2, ..., n+g-1 are composite. (3) The density of gap g near n is approximately 2*C_2/(g*log(n)) where C_2 is the twin prime constant. Conjecture: The prime gap crossword is uniquely solvable \u2014 given the pattern of gaps up to N, the next prime is determined with probability 1 - O(1/log(N)). More precisely, the conditional probability that the next prime after p is p + g, given all primes up to p, is approximately 2*C_2/g * (1/log(p)) * product_{q prime, q | g} (q-1)/(q-2). This is the Hardy-Littlewood conjecture for prime gaps. But the crossword has a surprise: certain gap patterns FORCE the next number. For example, if the gaps near n are 6, 4, 2, 6, then the next gap is almost certainly 4 (the only way to fill the crossword). Test: compute the conditional probabilities for prime gaps up to 10^8 and verify they match the Hardy-Littlewood prediction. Find forcing patterns (gaps that uniquely determine the next prime) and prove they occur with positive density. Impact: prime gaps are not random \u2014 they are a solvable crossword puzzle with deterministic rules.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.78,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.525722+00:00"
  },
  {
    "id": "fd_0052",
    "title": "Sheaf Cohomology of Data: The Topology of Missing Information",
    "description": "A dataset with missing values is a sheaf on a poset: the poset is the set of feature subsets (ordered by inclusion), and the sheaf assigns to each feature subset the set of complete observations on those features. The missing data creates 'holes' in the sheaf: H^0 measures the global sections (complete observations) and H^1 measures the obstructions to patching local observations into global ones. Conjecture: For a dataset with missing rate r, the dimension of H^1 is approximately r * n * (r * log(1/r)), where n is the number of features. This means: the 'amount of missing information' grows super-linearly with the missing rate, and imputation is fundamentally harder than interpolation because H^1 > 0 means there is no consistent way to fill in the missing data. The sheaf-theoretic imputation: fill in missing values by finding the section s in H^0 that minimizes the coboundary delta(s) in H^1. This is the maximum likelihood imputation under the assumption that the data is locally consistent. Test: generate synthetic datasets with known ground truth, introduce missing values at rate r, compute H^0 and H^1 of the data sheaf, and verify dim(H^1) ~ r*n*r*log(1/r). Compare sheaf-theoretic imputation with standard methods (mean, KNN, MICE). Impact: missing data is a topological problem, and the sheaf cohomology tells you exactly how much information is lost and whether it can be recovered.",
    "domains": [
      "Novelty",
      "Topology"
    ],
    "priority_score": 0.78,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.596679+00:00"
  },
  {
    "id": "fd_0062",
    "title": "The P vs NP of Sudoku: Phase Transitions in Constraint Satisfaction",
    "description": "Sudoku is a constraint satisfaction problem (CSP). Random Sudoku instances exhibit a phase transition: for n^2 x n^2 grids, the probability of having a solution drops from ~1 to ~0 around a critical density of pre-filled cells. Conjecture: the phase transition occurs at density d_c(n) = (n^2 - 1) / n^2, independent of the specific constraint structure. For standard 9x9 Sudoku (n=3): d_c = 8/9 \u2248 0.889. For 4x4 Sudoku (n=2): d_c = 3/4 = 0.75. For 16x16 (n=4): d_c = 15/16 \u2248 0.9375. The 'hardness' of random Sudoku peaks at the phase transition: instances with density near d_c take exponentially longer to solve than easy (low density) or trivial (high density) instances. Conjecture: the computational hardness of Sudoku at the phase transition is O(exp(n^2)) for backtracking algorithms, matching the theoretical prediction for CSPs at criticality. Test: generate random Sudoku instances at varying densities, measure solver time, and verify the phase transition at d_c. Impact: Sudoku hardness is not about 9x9 grids \u2014 it is about the phase transition structure of constraint satisfaction.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.78,
    "status": "in_progress",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "c4d79127",
    "timestamp": "2026-06-01T12:30:30.639161+00:00"
  },
  {
    "id": "fd_0024",
    "title": "The Mathematics of Memes: Viral Information Topology",
    "description": "A meme is a unit of cultural information that replicates through human minds. Model meme propagation as a sheaf over the social network graph: each node is a person, each edge is a communication channel, and the meme is a section of the sheaf that must satisfy consistency conditions at each node. Define meme fitness as the sheaf cohomology group H^1(G, M) where G is the social network and M is the meme sheaf. A meme with H^1 = 0 is universally transmissible (it has no consistency barriers \u2014 anyone can understand it). A meme with H^1 of dimension d requires d 'interpretation steps' to cross between communities. Conjecture: The most viral memes have H^1(G, M) = 0 but H^0(G, M) of maximal dimension \u2014 they spread everywhere AND mean different things to different communities. The dimension of H^0 counts the number of distinct interpretations. A meme that means the same thing to everyone has dim(H^0) = 1 and dim(H^1) = 0. A meme that means different things to different communities has dim(H^0) > 1 and dim(H^1) = 0. A meme that CANNOT spread between communities has H^1 > 0. Test: model Twitter/X retweet networks as graphs G with 1000 nodes, assign meme sheaves based on community structure, compute H^0 and H^1, and correlate with actual virality data. Impact: meme virality is a topological property \u2014 it's not about content quality but about the sheaf cohomology of the social network.",
    "domains": [
      "Novelty",
      "Topology"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.512076+00:00"
  },
  {
    "id": "fd_0043",
    "title": "The Mathematics of Jigsaw Puzzles: NP-Completeness and Topology",
    "description": "A jigsaw puzzle has N pieces, each with 4 edges. The 'signature' of a piece is the tuple (top, right, bottom, left) of edge types (flat, tab, blank). Two pieces fit together if their adjacent edges are complementary (tab meets blank). Conjecture: Solving a jigsaw puzzle is NP-complete. The reduction: given a 3-SAT formula with n variables and m clauses, construct a jigsaw puzzle with N = 2n + m + 2 pieces where the only valid assembly corresponds to a satisfying assignment. Variable pieces: each variable x_i has two pieces (TRUE and FALSE), one with a tab and one with a blank on the assignment edge. Only one can be placed (mutual exclusion via complementary edges). Clause pieces: each clause C_j is a piece that has three input edges (one per literal) and one output edge. The piece fits only if at least one input edge is connected to a TRUE literal piece. The top-left corner and bottom-right corner enforce the boundary. Test: construct the reduction explicitly for a small 3-SAT instance (e.g., (x1 OR x2 OR NOT x3) AND (NOT x1 OR x3)) and verify the puzzle has a solution iff the formula is satisfiable. Impact: jigsaw puzzles are NP-complete, so the satisfying snap you feel when completing a puzzle is literally the same as solving a hard computational problem.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.564171+00:00"
  },
  {
    "id": "fd_0069",
    "title": "Sperner's Lemma Implies Nash Equilibria: Combinatorial Fixed Points in Game Theory",
    "description": "Sperner's lemma states that any proper coloring of a triangulated simplex with n+1 colors has at least one fully colored simplex. This is a combinatorial analog of Brouwer's fixed point theorem. Nash's theorem states that every finite game has a mixed strategy Nash equilibrium, proved using Kakutani's fixed point theorem. Conjecture: Sperner's lemma directly implies Nash's theorem. Specifically, given an n-player game with strategies S_1, ..., S_n, construct the n-simplex Delta = Delta(S_1 x ... x S_n) of mixed strategy profiles. Define a Sperner coloring of Delta by: color vertex v with color i if player i's best response to v is strategy i. By Sperner's lemma, there exists a fully colored simplex. The center of this simplex is an approximate Nash equilibrium (each player is approximately best-responding). Taking the limit as the triangulation gets finer gives an exact Nash equilibrium. Conjecture: this construction gives a constructive proof of Nash's theorem that yields a triangulation-based algorithm for finding Nash equilibria with complexity O(N^{n}) where N is the total number of pure strategies. Test: implement the Sperner-based algorithm for 2-player games and verify it finds all Nash equilibria. Impact: Nash equilibria are combinatorial fixed points. Sperner's lemma is the fundamental theorem of game theory.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.676713+00:00"
  },
  {
    "id": "fd_0081",
    "title": "The Topology of Argumentation: Why Debates Have Holes",
    "description": "An argumentation framework AF = (A, R) consists of a set of arguments A and an attack relation R subset A x A. The preferred extensions of AF are the maximal admissible sets (subsets S of A that defend themselves against all attacks and are maximal with this property). Conjecture: the preferred extensions of AF form a simplicial complex K(AF) on the vertex set A. The homology groups H_n(K(AF)) measure the 'holes' in the argumentation structure. H_0 measures the number of connected components (independent debate threads). H_1 measures circular arguments (cycles where each argument attacks the next, and the last attacks the first). H_2 measures 'spheres' of arguments (3D cycles where arguments form a spherical shell). Conjecture: for any argumentation framework, the Euler characteristic chi(K(AF)) = |A| - |R| + sum_{n>=2} (-1)^n * dim(H_n) equals |preferred extensions| - |grounded extension size|. This connects the topology of the argument to its semantics. Test: construct K(AF) for 100 argumentation frameworks from debate transcripts, compute homology groups, and verify the Euler characteristic formula. Impact: arguments have topology. Circular arguments are 1-holes, and 3D argument spheres are 2-holes. The shape of a debate is a topological invariant.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.739014+00:00"
  },
  {
    "id": "fd_0083",
    "title": "The Spectral Gap of Sudoku: When Puzzles Become Phase Transitions",
    "description": "A Sudoku puzzle is a constraint satisfaction problem on a 9x9 grid. The 'spectral gap' of a Sudoku puzzle is the gap between the two largest eigenvalues of the transition matrix of the Markov chain that randomly swaps two compatible entries. The spectral gap determines the mixing time: the number of swaps needed to generate a uniformly random solution. Conjecture: the spectral gap of a Sudoku puzzle undergoes a phase transition at the critical density d_c = 17/81 (the density of the minimal number of clues, 17, divided by 81). For puzzles with fewer than 17 clues, the spectral gap is large (the Markov chain mixes quickly, meaning there are many solutions). For puzzles with exactly 17 clues, the spectral gap is minimal (the chain mixes slowly, meaning solutions are hard to find). For puzzles with more than 30 clues, the spectral gap is zero (the chain is reducible, meaning the puzzle has a unique solution and no swaps are possible). Conjecture: the spectral gap lambda_1 - lambda_2 of the Sudoku Markov chain satisfies: lambda_1 - lambda_2 > epsilon for d < 17/81 (many solutions, fast mixing), lambda_1 - lambda_2 ~ 0 for d ~ 17/81 (critical point, slow mixing), and the chain is absorbing for d > 30/81 (unique solution, no mixing). Test: compute the spectral gap for Sudoku puzzles with varying numbers of clues and verify the phase transition. Impact: Sudoku has a spectral gap phase transition. The hardness of the puzzle is determined by the gap, not by the number of clues.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.750240+00:00"
  },
  {
    "id": "fd_0094",
    "title": "Hypergraph Ramsey Theory: Beyond Graphs",
    "description": "Ramsey's theorem for graphs states that R(k,l) = the minimum n such that any 2-coloring of the edges of K_n contains a red K_k or a blue K_l. For hypergraphs: R_r(k,l) = the minimum n such that any 2-coloring of the r-tuples of an n-set contains a red K_k^{(r)} or a blue K_l^{(r)}. The growth rate is an open problem: R_3(4,4) = 13 (known), R_3(5,5) is between 34 and 55, and R_3(k,k) is believed to grow like a double exponential 2^{c*k^2}. Conjecture: R_3(k,k) ~ 2^{2^{ck}} for some constant c > 0. This is a tower function (height 2 exponential). More precisely: the lower bound R_3(k,k) >= 2^{ck^2} (from the probabilistic method) and the upper bound R_3(k,k) <= 2^{2^{ck}} (from the stepping-up lemma). The gap is between a single exponential and a double exponential. Conjecture: the true growth rate is double exponential, and the upper bound is tight. This would mean that 3-uniform Ramsey numbers grow much faster than graph Ramsey numbers. Test: compute R_3(k,k) for k = 3, 4, 5, 6 by exhaustive search and verify the growth rate. Impact: 3-uniform Ramsey numbers are double exponential. Combinatorics at the hypergraph level is fundamentally harder than at the graph level.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.77,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.820858+00:00"
  },
  {
    "id": "fd_0019",
    "title": "Arithmetic on the Moebius Band: A Number System with a Twist",
    "description": "The Moebius band M is obtained from [0,1] x R by identifying (0, y) ~ (1, -y). Define arithmetic on M: a point (x, y) on M represents the number y * (2x - 1) where x in [0,1] gives the sign and magnitude, and y gives the scale. This creates a number system where going around the band flips the sign. Define the Moebius integers Z_M as the image of Z in M under the embedding n -> (1/2 + 1/(2n), |n|). Then 1 and -1 are identified at the twist point (1, 1) = (0, -1), making Z_M a one-point compactification of Z with a single infinity. Conjecture: Z_M is a ring under the induced operations from R x R / ~, but it is NOT an integral domain because (1, 0) * (0, 1) = (0, 0) but neither factor is zero in Z_M. The prime factorization in Z_M has a unique 'twist prime' that encodes orientation, and every non-zero Moebius integer has a factorization of the form \u00b1p_1^{a_1} * ... * p_k^{a_k} where the overall sign is the twist. Test: factor the Moebius integers 6, -6, and 0 in Z_M. Verify that 6 = 2_+ * 3_+ and -6 = 2_- * 3_- = 2_+ * 3_+ * (-1) where -1 is the twist prime. Impact: arithmetic on a non-orientable surface creates a number system where orientation IS a prime \u2014 a number-theoretic analog of spin in physics.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.76,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.503818+00:00"
  },
  {
    "id": "fd_0060",
    "title": "Persistent Homology of Musical Harmony: The Topology of Bach",
    "description": "Bach's chorales are the gold standard of Western harmony. But what if we could MEASURE the harmonic complexity using topology? Encode each chord as a point in a 12-dimensional space (one dimension per pitch class). A sequence of chords traces a path in this space. Compute the persistent homology of the point cloud of all chords in a Bach chorale. Conjecture: Bach's chorales have persistent H_1 (1-dimensional cycles) that survive across a wide range of scales, indicating circular harmonic motion (the circle of fifths). In contrast, random chord sequences have H_1 bars that die quickly. The longest H_1 bar in a Bach chorale corresponds to the circle of fifths \u2014 the fundamental harmonic cycle. Pop music has shorter H_1 bars (less complex harmonic cycles). Atonal music has no persistent H_1 (no harmonic cycles). Test: compute persistent homology barcodes for 100 Bach chorales, 100 pop songs, and 100 atonal pieces. Verify: Bach has H_1 bars of length > 0.5 (in normalized pitch-class space), pop has bars of length 0.2-0.5, atonal has no persistent H_1. Impact: the topology of music IS its harmonic structure. Bach's genius is literally topological \u2014 his music has longer harmonic cycles.",
    "domains": [
      "Novelty",
      "Topology"
    ],
    "priority_score": 0.76,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.630214+00:00"
  },
  {
    "id": "fd_0006",
    "title": "Vampire Numbers and Other Numerical Monsters: A Bestiary of Arithmetic Oddities",
    "description": "A vampire number is a composite number v with an even number of digits that can be factizedd as v = x * y where x and y together have the same digits as v. The smallest is 1260 = 21 * 60. But vampire numbers are just the beginning. Define: (1) Werewolf numbers: v = x * y where x and y share exactly one digit with v. (2) Ghost numbers: v = x * y where v has NO digits in common with x or y. (3) Zombie numbers: v = x * y where x and y are both prime (these violate the definition but exist \u2014 125460 = 204 * 615 = 246 * 510, where both factorizations involve a prime and a composite). Conjecture: The density of vampire numbers in [10^{2n}, 10^{2n+1}] approaches 1/sqrt(n) as n -> infinity. Every even-length interval [10^{2k}, 10^{2k+2}] contains at least one vampire number. Ghost numbers have density 0 \u2014 they become vanishingly rare as the number of digits increases. Test: enumerate all vampire, werewolf, ghost, and zombie numbers up to 10^8. Prove the density conjecture by counting valid digit permutations. Impact: a playful but genuine number theory of arithmetic creatures \u2014 combinatorial digit problems that are easy to state but may be as hard as factoring.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.75,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.491505+00:00"
  },
  {
    "id": "fd_0150",
    "title": "Comprehensive formal framework for the Erd\u0151s\u2013F",
    "description": "# Future Directions\n\n## Synthesis\n\nThis research cycle established a comprehensive formal framework for the Erd\u0151s\u2013Faber\u2013Lov\u00e1sz conjecture, proving 17 theorems about k-uniform linear hypergraphs with k edges. The key structural insights \u2014 the exclusive vertex lemma, the near-pencil vertex count, and the high-degree vertex bound \u2014 reveal deep connections between linearity constraints and coloring feasibility. The exclusive vertex lemma, in particular, opens a path to inductive coloring proofs: if every edge has a \"free\" vertex, then removing that vertex reduces the coloring problem to a smaller instance.\n\nThe most promising cross-domain connection emerges between EFL theory and chromatic polynomial theory (existing in `Catalog/MachineLearning/ChromaticPolynomial/`). The chromatic polynomial encodes *all* coloring information for a graph, and extending this to hypergraph settings could unify the EFL conjecture with algebraic approaches. Additionally, the sunflower structure defined in our framework connects naturally to the Sunflower Lemma and its recent improvements, suggesting that set-theoretic combinatorics can provide alternative proof paths.\n\nThe highest breakthrough potential lies in Direction 1 (constructive EFL for moderate k): if the near-pencil colorability proof can be formalized constructively, it provides a template for extending to general configurations via absorption, which is the strategy of the Kang\u2013Kelly\u2013K\u00fchn\u2013Methuku\u2013Osthus proof. Direction 3 (chromatic polynomial extension) has the highest long-term impact, as it would bridge algebraic and combinatorial approaches to hypergraph coloring.\n\n---\n\n### Direction 1: Constructive EFL Coloring via Absorption\n\n**Conjecture**: For any EFL system with parameter k \u2265 2, there exists a constructive algorithm that produces a strong k-coloring in O(k\u00b3) time, based on the following strategy: (1) color the exclusive vertices (one per edge, by the exclusive vertex lemma) to create an initial partial coloring, (2) extend the coloring to shared vertices using a matching argument on the bipartite graph between shared vertices and available colors.\n\n**Test**: Implement the algorithm for k \u2208 {3, 4, 5, 6, 7} and verify it produces valid colorings on all EFL systems of that size. Enumerate all EFL systems for k \u2264 5 (feasible: the number of non-isomorphic systems is manageable) and confirm the algorithm succeeds on each.\n\n**Impact**: A constructive proof would eliminate the \"sufficiently large k\" qualifier from the Kang et al. result and provide a practical coloring algorithm. If the algorithm fails for some configuration, it would identify the hardest instances of EFL, guiding future work.\n\n**Catalog References**: `Combinatorics/ErdosFaberLovasz/Advanced.lean` (edge_has_exclusive_vertex), `Combinatorics/ErdosFaberLovasz/Theorems.lean` (degree_le_k, high_degree_vertex_bound)\n\n**Proof Strategy**: \n1. Formalize the exclusive vertex lemma's constructive content: for each edge, exhibit a specific degree-1 vertex.\n2. Define a partial coloring that assigns one color per exclusive vertex.\n3. Prove that the remaining shared vertices can be colored by showing the bipartite graph (shared vertices \u00d7 available colors) satisfies Hall's condition.\n4. Hall's theorem is available in Mathlib as `Finset.all_card_le_biUnion_card_iff_exists_injective`.\n\n**Domain Bridges**: EFL coloring \u2194 Matching theory (Hall's theorem) \u2194 Computation (algorithm complexity)\n\n**Lineage**: Builds on edge_has_exclusive_vertex and near_pencil structural analysis from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Sunflower Extraction in Linear Hypergraphs\n\n**Conjecture**: In any k-uniform linear intersecting hypergraph with more than k(k\u22121) + 1 edges, there exists a sunflower with 3 petals and a non-empty core. Equivalently, the sunflower-free maximum for k-uniform linear intersecting families is exactly k(k\u22121) + 1 (achieved by the near-pencil).\n\n**Test**: For k = 3, enumerate all 3-uniform linear intersecting hypergraphs on up to 10 vertices. Verify that those with more than 7 edges always contain a 3-petal sunflower. Check that the near-pencil on 7 vertices (with 7 edges) is sunflower-free.\n\n**Impact**: This would connect the EFL conjecture to the Sunflower Lemma (Erd\u0151s\u2013Ko\u2013Rado theory), providing an alternative proof route. If false, the counterexample would reveal new extremal configurations beyond the near-pencil.\n\n**Catalog References**: `Combinatorics/ErdosFaberLovasz/Defs.lean` (Hypergraph.Sunflower), `Combinatorics/ErdosFaberLovasz/Advanced.lean` (near_pencil_vertexSet_card)\n\n**Proof Strategy**:\n1. Use the formal Sunflower definition from Defs.lean.\n2. For the near-pencil, show that no 3 edges form a sunflower (the core would need to be the center vertex, but then the petals are not pairwise intersecting only in the core \u2014 actually they DO intersect only in {v\u2080}, so {e\u2081, e\u2082, e\u2083} with core {v\u2080} IS a sunflower!). Revise: the near-pencil IS a sunflower. So the conjecture should state: any k-uniform linear intersecting hypergraph with k(k\u22121)+1 edges is either a near-pencil (= sunflower) or contains a sunflower with smaller core.\n3. The key lemma: if the hypergraph is not a near-pencil, then some vertex has degree < k, and the star decomposition around that vertex reveals a sunflower.\n\n**Domain Bridges**: Hypergraph theory \u2194 Set systems (Sunflower Lemma) \u2194 Extremal combinatorics\n\n**Lineage**: Builds on the Sunflower structure definition and near-pencil analysis from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Chromatic Polynomial for Hypergraphs\n\n**Conjecture**: The chromatic polynomial of a k-uniform linear hypergraph H on n vertices with m edges satisfies: P_H(q) \u2265 q(q\u22121)^{n\u22121} for all q \u2265 k. In particular, P_H(k) \u2265 k(k\u22121)^{n\u22121} > 0, which would prove the EFL conjecture algebraically.\n\n**Test**: Compute the chromatic polynomial for all EFL systems with k \u2208 {2, 3, 4} using inclusion-exclusion. Verify that P_H(k) > 0 for each. Compare P_H with the bound q(q\u22121)^{n\u22121}.\n\n**Impact**: An algebraic proof of EFL via chromatic polynomials would be a major breakthrough, connecting hypergraph coloring to algebraic combinatorics. Even a weaker bound (P_H(q) > 0 for q \u2265 Ck for some constant C) would be significant.\n\n**Catalog References**: `Catalog/MachineLearning/ChromaticPolynomial/Basic.lean` (SimpleGraph.chromaticPolynomial), `Combinatorics/ErdosFaberLovasz/Defs.lean` (Hypergraph.chromaticNumber)\n\n**Proof Strategy**:\n1. Define the chromatic polynomial for hypergraphs via inclusion-exclusion: P_H(q) = \u03a3_{S \u2286 E} (\u22121)^|S| q^{c(S)} where c(S) is the number of connected components of the vertex set under the constraint that vertices in each edge of S are merged.\n2. For linear hypergraphs, the M\u00f6bius function of the edge intersection lattice simplifies.\n3. Show P_H(k) \u2265 k! / k^{k-1} > 0 for k \u2265 3 using the Whitney rank polynomial formulation.\n\n**Domain Bridges**: Hypergraph coloring \u2194 Algebraic combinatorics (chromatic polynomial) \u2194 Lattice theory (M\u00f6bius function)\n\n**Lineage**: Builds on chromatic polynomial infrastructure in the Catalog and hypergraph definitions from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Degree Sequence Constraints in EFL Systems\n\n**Conjecture**: In any EFL system with parameter k \u2265 3, the degree sequence (d\u2081, d\u2082, ..., d\u2099) satisfies:\n(a) At least k vertices have degree exactly 1 (strengthening of the exclusive vertex lemma from \"at least one per edge\" to a global count).\n(b) The number of vertices with degree exactly k is at most 1.\n(c) The degree sequence is uniquely maximized (in majorization order) by the near-pencil.\n\n**Test**: Enumerate all non-isomorphic EFL systems for k = 3 (there are finitely many on at most 9 vertices). Compute the degree sequence of each and verify (a), (b), (c).\n\n**Impact**: Part (c) would establish the near-pencil as the unique extremal configuration in a strong sense, potentially enabling induction arguments for the full EFL conjecture. Part (b), if true, would severely constrain the structure of EFL systems.\n\n**Catalog References**: `Combinatorics/ErdosFaberLovasz/Theorems.lean` (degree_le_k, degree_sum_eq_incidence, high_degree_vertex_bound), `Combinatorics/ErdosFaberLovasz/Advanced.lean` (edge_has_exclusive_vertex)\n\n**Proof Strategy**:\n1. For (a): Use edge_has_exclusive_vertex to get one degree-1 vertex per edge. If two edges share the same degree-1 vertex v, then deg(v) \u2265 2, contradiction. So we get k distinct degree-1 vertices.\n2. For (b): If two vertices v, w both have degree k (in all edges), then by linearity, edges i \u2229 edges j contains both v and w for all i \u2260 j, giving |edges i \u2229 edges j| \u2265 2, contradicting linearity.\n3. For (c): Use the double counting identity \u2211 deg(v) = k\u00b2 and the constraint deg(v) \u2264 k to show that the degree sequence is dominated by (k, 1, 1, ..., 1) with k(k\u22121) ones.\n\n**Domain Bridges**: EFL combinatorics \u2194 Majorization theory \u2194 Design theory\n\n**Lineage**: Directly extends edge_has_exclusive_vertex and degree_sum_eq_incidence from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Tropical Coloring and EFL\n\n**Conjecture**: The tropical chromatic number of the tropical hypergraph associated to an EFL system (where edge weights are tropical multiplicities and coloring is defined via tropical semiring operations) equals the classical chromatic number k.\n\n**Test**: Define the tropical hypergraph coloring problem formally. Compute the tropical chromatic number for the near-pencil with k = 3 using the tropical semiring (\u211d \u222a {\u221e}, min, +). Verify it equals 3.\n\n**Impact**: This would establish a bridge between the Tropical category in the Catalog and combinatorial coloring theory, potentially enabling transfer of results between the two domains. The tropical framework might provide alternative proofs via idempotent algebra.\n\n**Catalog References**: `Catalog/Tropical/TropicalHypergraphCounterpoint.lean`, `Catalog/Tropical/VoiceLeading.lean`, `Combinatorics/ErdosFaberLovasz/Defs.lean` (Hypergraph.chromaticNumber)\n\n**Proof Strategy**:\n1. Define tropical coloring: a function c : V \u2192 \u2124 such that for each edge e, the values c(v) for v \u2208 e are tropically independent (no two equal, since tropical addition is min).\n2. Show that tropical independence for finite sets in \u2124 is equivalent to classical distinctness.\n3. Conclude that tropical chromatic number = classical chromatic number for finite hypergraphs.\n4. If the equivalence breaks in infinite or weighted settings, characterize the discrepancy.\n\n**Domain Bridges**: EFL combinatorics \u2194 Tropical geometry \u2194 Algebraic combinatorics\n\n**Lineage**: Builds on both the tropical infrastructure in the Catalog and the EFL definitions from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Tropical"
    ],
    "priority_score": 0.75,
    "status": "in_progress",
    "research_mode": "team",
    "source_exp_id": "035c8fa4",
    "consumed_by_exp_id": "e923b297",
    "timestamp": "2026-06-01T14:51:12.142124+00:00"
  },
  {
    "id": "fd_0152",
    "title": "Three interconnected results about quadratic pol",
    "description": "# Future Directions: Discriminant Uniformity and Stochastic Galois Theory\n\n## Synthesis\n\nThis research cycle established three interconnected results about quadratic polynomials over finite fields. First, the **Discriminant Uniformity Theorem** (Theorem `disc_fiber_card`): for any prime p, the map (b,c) \u21a6 b\u00b2 \u2212 4c has perfectly uniform fibers of size p. Second, exact formulas for splitting type distributions: among p\u00b2 monic quadratics over \ud835\udd3d_p, exactly p(p\u22121)/2 are split, p are ramified, and p(p\u22121)/2 are inert. Third, the formal connection between splitting types and Frobenius cycle types for degree 2.\n\nThe most promising cross-domain connection emerging from this cycle is between **algebraic fiber counting** (the uniformity theorem) and **probabilistic convergence** (splitting type fractions \u2192 random permutation statistics). The uniformity theorem provides the engine: because fibers are uniform, counting reduces to counting discriminant values of each type (zero, square, non-square), which is classical. This strategy should generalize to cubics when the underlying polynomial map has appropriate bijectivity properties \u2014 and our computational investigation reveals this holds exactly when p \u2261 2 (mod 3). The cycle also uncovered a concrete failure mode: the cubic discriminant is NOT uniform for p \u2261 1 (mod 3), providing a falsifiable prediction about which primes admit uniform fiber structures.\n\nThe highest breakthrough potential lies in Direction 1 (Cubic Splitting over p \u2261 2 mod 3), because formalizing the cubic case would be the first machine-verified instance of the polynomial-to-permutation dictionary beyond degree 2. Direction 3 (the mod-3 obstruction) has high theoretical value because it connects to the structure of the multiplicative group \ud835\udd3d_p* and the distribution of n-th power residues. Both connect to the Catalog's algebraic infrastructure via `Algebra/Advanced.lean` and the Bridges domain via cross-domain results.\n\n---\n\n### Direction 1: Cubic Splitting Type Distribution over \ud835\udd3d_p for p \u2261 2 (mod 3)\n\n**Conjecture**: For a prime p \u2261 2 (mod 3), the depressed cubic discriminant map (b,c) \u21a6 \u2212(4b\u00b3 + 27c\u00b2) from \ud835\udd3d_p\u00b2 \u2192 \ud835\udd3d_p has every fiber of cardinality exactly p. Consequently, the splitting type distribution of depressed cubics x\u00b3 + bx + c over \ud835\udd3d_p has:\n- Type [1,1,1] (three distinct roots): count = p \u00b7 (number of d \u2208 \ud835\udd3d_p* where d is a square and has three cube roots of d/(-4) in \ud835\udd3d_p)\n- Type [2,1] (one root + irreducible quadratic factor): determined by remaining residues\n- Type [3] (irreducible cubic): count = p \u00b7 (number of non-cubes among appropriate residue set)\n\n**Test**: Verify computationally for all primes p < 500 with p \u2261 2 (mod 3) that the cubic discriminant map has uniform fibers of size p. Then prove the uniformity formally using the fact that x \u21a6 x\u00b3 is bijective on \ud835\udd3d_p* when p \u2261 2 (mod 3) (since gcd(3, p\u22121) = 1).\n\n**Impact**: Would establish the first formally verified cubic splitting type result, opening the door to the full Frobenius correspondence for degree 3. This bridges algebra (polynomial factorization) with combinatorics (cycle types in S\u2083) and probability (convergence to random permutation statistics).\n\n**Catalog References**: `Algebra/Advanced.lean`, `Bridges/AlgebraEMLClosureComputation.lean`\n\n**Proof Strategy**: \n1. Prove that x \u21a6 x\u00b3 is bijective on \ud835\udd3d_p* when gcd(3, p\u22121) = 1\n2. Use this to show (b,c) \u21a6 (b, \u22124b\u00b3 \u2212 27c\u00b2) is a bijection when both 4 and 27 are units and the cube map is bijective\n3. Derive fiber uniformity analogously to the quadratic case\n4. Count cubic splitting types using cubic residue theory\n\n**Domain Bridges**: Algebra (polynomial factorization) \u2194 Computation (efficient classification algorithms) \u2194 EML (complexity of splitting type computation)\n\n**Lineage**: Direct extension of `disc_fiber_card` and `four_isUnit_of_odd_prime` from this cycle. Uses the same fiber-counting strategy but requires cubic residue theory.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Chebotarev Density as the Infinite-Prime Limit\n\n**Conjecture**: The splitting type distribution of monic degree-n polynomials over \ud835\udd3d_p, as p \u2192 \u221e, converges to the cycle type distribution of random permutations in S\u2099. Formally: for each partition \u03bb of n,\n\n    lim_{p \u2192 \u221e} |{f \u2208 \ud835\udd3d_p[x] monic degree n : splitting type = \u03bb}| / p\u207f = |{\u03c3 \u2208 S\u2099 : cycle type = \u03bb}| / n!\n\nThis is the finite-field analog of the Chebotarev density theorem.\n\n**Test**: Verify computationally for n = 2, 3, 4 and primes p up to 100 that the splitting type fractions approach the random permutation fractions. For n = 2, we proved this exactly: split fraction = (p\u22121)/(2p) \u2192 1/2, which matches P(identity in S\u2082) = 1/2.\n\n**Impact**: A formal proof would provide the first machine-verified instance of the polynomial-to-permutation convergence principle. This is a key step toward formalizing the Katz-Sarnak philosophy.\n\n**Catalog References**: `Algebra/Advanced.lean`, `Computation/InfoEfficientAlgorithms.lean`\n\n**Proof Strategy**:\n1. For each partition \u03bb of n, express the count of polynomials with splitting type \u03bb in terms of:\n   - The number of n-th power residues of various types\n   - Fiber sizes of discriminant-like maps\n2. Show these counts have leading term p\u207f \u00b7 (|{\u03c3 \u2208 S\u2099 : cycle type \u03bb}| / n!)\n3. The error term is O(p^{n-1/2}) by the Weil bound\n\n**Domain Bridges**: Algebra (splitting types) \u2194 EML (ensemble complexity of classification) \u2194 Computation (algorithms for counting)\n\n**Lineage**: Extends `disc_fiber_card`, `nonsquare_count`, and the splitting type distribution from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: The Mod-3 Obstruction and n-th Power Residue Fiber Theory\n\n**Conjecture**: For a polynomial map \u03a6: \ud835\udd3d_p^k \u2192 \ud835\udd3d_p of the form \u03a6(x\u2081, ..., x\u2096) = \u03a3\u1d62 a\u1d62 \u00b7 x\u1d62\u207f\u2071 (a \"diagonal\" polynomial), the fiber |\u03a6\u207b\u00b9(d)| = p^{k-1} for all d \u2208 \ud835\udd3d_p if and only if gcd(n\u1d62, p\u22121) = 1 for all i. When some gcd(n\u1d62, p\u22121) > 1, the fiber sizes vary and can be computed in terms of the number of n\u1d62-th roots of certain elements.\n\nFor the quadratic discriminant b\u00b2 \u2212 4c, we have n\u2081 = 2 and n\u2082 = 1. Since gcd(1, p\u22121) = 1 always holds and gcd(2, p\u22121) = 2 for odd p, the naive criterion fails \u2014 but uniformity still holds because the \"mixed\" structure (b\u00b2 \u2212 4c rather than b\u00b2 + c) compensates. The precise condition for uniformity of a mixed polynomial map requires analyzing the full fiber structure, not just the individual degree conditions.\n\n**Test**: For diagonal maps aX^n + bY^m over \ud835\udd3d_p, compute fiber sizes for various (n, m, p) triples and determine the exact uniformity condition.\n\n**Impact**: Would provide a general theory of when polynomial maps have uniform fibers, subsuming both the quadratic (always uniform) and cubic (conditionally uniform) discriminant results. This connects to the Lang-Weil theorem and the theory of exponential sums.\n\n**Catalog References**: `Algebra/Advanced.lean`, `Cryptography/BerggrenDiophantineLattice.lean`\n\n**Proof Strategy**:\n1. Define \"diagonal polynomial map\" formally\n2. Prove that X^n has uniform fibers (all of size gcd(n, p\u22121)) when restricted to \ud835\udd3d_p*\n3. Derive fiber sizes for sums of power maps using character sum estimates\n4. Specialize to recover the quadratic and cubic discriminant results\n\n**Domain Bridges**: Algebra (power residues) \u2194 Cryptography (discrete log structure) \u2194 Computation (exponential sum algorithms)\n\n**Lineage**: Motivated by the failure of cubic uniformity at p \u2261 1 (mod 3) discovered in this cycle. Extends `disc_fiber_card`.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Formal Frobenius Correspondence for Degree 3\n\n**Conjecture**: For a separable cubic f over \ud835\udd3d_p with Galois group G \u2264 S\u2083, the splitting type of f equals the cycle type of the Frobenius element Frob_p \u2208 G. For cubics over \ud835\udd3d_p, the Galois group is cyclic (always Z/1Z, Z/2Z, or Z/3Z), and the Frobenius correspondence gives:\n- Splitting type [1,1,1] \u2194 Frob = id \u2208 G (trivial Galois group)\n- Splitting type [2,1] \u2194 Frob has order 2 in G \u2245 Z/2Z\n- Splitting type [3] \u2194 Frob has order 3 in G \u2245 Z/3Z\n\n**Test**: For each cubic f(x) = x\u00b3 + bx + c over \ud835\udd3d_p (p = 5, 7, 11, 13), compute the splitting type and the Frobenius element, verifying they match.\n\n**Impact**: Would be the first formal proof of the Frobenius correspondence for cubics, a key ingredient in the theory of Artin L-functions. This bridges finite field arithmetic with Galois theory and representation theory.\n\n**Catalog References**: `Bridges/AlgebraEMLClosureComputation.lean`, `Algebra/Advanced.lean`\n\n**Proof Strategy**:\n1. Define the splitting field of a cubic over \ud835\udd3d_p (it's \ud835\udd3d_{p^k} for k = lcm of factor degrees)\n2. Define the Frobenius automorphism x \u21a6 x^p on the splitting field\n3. Show the Frobenius acts on roots with cycle type matching the splitting type\n4. This requires the formal theory of finite field extensions in Mathlib\n\n**Domain Bridges**: Algebra (Galois theory) \u2194 Computation (polynomial factorization algorithms) \u2194 Cryptography (elliptic curve point counting via Frobenius)\n\n**Lineage**: Extends `splitTypeToCyclePartition` and `cycle_partition_sum` from this cycle. Requires formal finite field extension theory.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Discriminant Uniformity for Multivariate Affine Maps\n\n**Conjecture**: Let L: \ud835\udd3d_p^n \u2192 \ud835\udd3d_p be any affine-linear map (i.e., L(x) = a\u2081x\u2081 + ... + a\u2099x\u2099 + b where some a\u1d62 \u2260 0). Then every fiber of L has cardinality p^{n-1}. More generally, for a polynomial map P: \ud835\udd3d_p^n \u2192 \ud835\udd3d_p that is \"affine-linear in at least one variable\" (i.e., for some variable x\u1d62, P is of the form f(x\u2081,...,x\u0302\u1d62,...,x\u2099) \u00b7 x\u1d62 + g(x\u2081,...,x\u0302\u1d62,...,x\u2099) where f is never zero), every fiber of P has cardinality p^{n-1}.\n\nThe quadratic discriminant b\u00b2 \u2212 4c is affine-linear in c (with linear coefficient \u22124 \u2260 0), explaining its uniformity.\n\n**Test**: Implement and verify for random polynomial maps of the required form over \ud835\udd3d_p for p = 3, 5, 7, 11.\n\n**Impact**: Would provide a general principle explaining why many natural polynomial maps in number theory have uniform fibers, unifying the quadratic discriminant result with other fiber-counting theorems.\n\n**Catalog References**: `Algebra/Advanced.lean`, `Bridges/AlgebraEMLPhysics/FilteredClosureReconstruction.lean`\n\n**Proof Strategy**:\n1. Prove the affine-linear case directly: for fixed values of all variables except x\u1d62, the map x\u1d62 \u21a6 L(x) is a bijection\n2. Sum over all choices of the other variables to get fiber size = p^{n-1}\n3. For the polynomial generalization, reduce to the affine-linear case by the condition on f\n\n**Domain Bridges**: Algebra (linear algebra over finite fields) \u2194 Computation (counting algorithms) \u2194 EML (information-theoretic uniformity)\n\n**Lineage**: Direct generalization of `disc_fiber_card_odd`. The proof strategy (fix all variables but one, show bijectivity) is the same.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "priority_score": 0.75,
    "status": "in_progress",
    "research_mode": "team",
    "source_exp_id": "b12db4e8",
    "consumed_by_exp_id": "21f2c1db",
    "timestamp": "2026-06-01T14:51:52.736022+00:00"
  },
  {
    "id": "fd_0159",
    "title": "Formal bridge between the probabilistic method",
    "description": "# Future Directions: Probabilistic Method and Tropical Algebra\n\n## Synthesis\n\nThis research cycle established a formal bridge between the probabilistic method in combinatorics and tropical algebra, proving 15 machine-verified theorems including the counting principle, Tur\u00e1n graph triangle-freeness, Mantel's degree-sum bound, Erd\u0151s's Ramsey inequalities, and the LLL algebraic core. The most significant discovery was that the `TropicalCostStructure`\u2014a novel definition capturing the min-plus analogue of the first moment method\u2014provides a natural algebraic framework for probabilistic existence proofs.\n\nThe strongest cross-domain connection is between the LLL algebraic core (product positivity of (1 - x\u1d62)) and tropical fixed-point theory. The LLL witness condition x_i \u2265 p_i \u00b7 \u220f(1 - x_j)\u207b\u00b9 is a fixed-point equation in the tropical semiring, and the Moser-Tardos algorithm is a tropical iteration scheme. This suggests that constructive versions of non-trivial probabilistic arguments may systematically arise from tropical optimization algorithms, connecting to the Catalog's existing tropical spectral theory (`FINAL/Tropical/SpectralTheory.lean`) and iteration results (`FINAL/Tropical/TropicalMatrixIteration.lean`).\n\nThe highest breakthrough potential lies in Direction 1 (Tropical Ramsey Duality), which proposes that Ramsey numbers are optimal values of tropical linear programs. If true, this would connect number-theoretic bounds on Ramsey numbers to tropical geometry\u2014a genuinely new perspective that could import algebraic-geometric tools into extremal combinatorics.\n\n---\n\n### Direction 1: Tropical Ramsey Duality\n\n**Conjecture**: For all k \u2265 3, the Ramsey number R(k,k) equals one plus the minimum n such that every tropical linear program encoding \"number of monochromatic k-cliques in a 2-coloring of K_n\" has optimal value \u2265 1. Formally: define the tropical Ramsey function TR(k) as the largest n such that the min-plus optimization problem min_{c \u2208 {0,1}^{C(n,2)}} \u2295_{S \u2208 C([n],k)} (monochromatic(S,c)) has optimal value 0. Then TR(k) + 1 = R(k,k).\n\n**Test**: Compute TR(3) computationally. We know R(3,3) = 6, so TR(3) should equal 5. Enumerate all 2^{C(5,2)} = 2^{10} = 1024 colorings of K_5 and verify that some coloring has zero monochromatic triangles; then verify that all 2^{C(6,2)} = 2^{15} = 32768 colorings of K_6 contain at least one monochromatic triangle.\n\n**Impact**: If true, Ramsey theory becomes a chapter of tropical convex optimization. The dual tropical program would provide new lower bounds on R(k,k). If false, understanding where the duality breaks reveals fundamental limits of algebraic approaches to Ramsey theory.\n\n**Catalog References**: `FINAL/Tropical/SpectralTheory.lean`, `FINAL/Tropical/TropicalMatrixIteration.lean`\n\n**Proof Strategy**: (1) Define the tropical Ramsey LP formally in Lean 4 using Mathlib's tropical semiring. (2) Prove TR(3) = 5 by computation. (3) Prove TR(k) \u2265 2^{k/2} - 1 using the Erd\u0151s counting argument formalized in this cycle. (4) Investigate whether the tropical dual program admits a spectral interpretation via tropical eigenvalues.\n\n**Domain Bridges**: Tropical algebra \u2194 Ramsey theory \u2194 Linear programming duality\n\n**Lineage**: Builds on `counting_principle`, `erdos_criterion_k3`, `erdos_criterion_k4`, and `TropicalCostStructure` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Constructive Lov\u00e1sz Local Lemma via Tropical Iteration\n\n**Conjecture**: The Moser-Tardos algorithm for the constructive LLL converges in at most \u2308\u03a3\u1d62 x\u1d62/(1-x\u1d62)\u2309 expected resamplings, where x is an LLL witness vector. Moreover, this bound equals the tropical spectral radius of the LLL dependency matrix.\n\n**Test**: Formalize the Moser-Tardos algorithm in Lean 4 as a function on finite state spaces. Prove termination using a tropical potential function \u03a6 = \u03a3\u1d62 log(x\u1d62/(1-x\u1d62)). Verify the bound on small instances (n \u2264 10 events) using `#eval`.\n\n**Impact**: Establishes that constructive probabilistic combinatorics is tropical iteration theory. Opens the door to importing convergence results from tropical matrix theory into algorithm analysis.\n\n**Catalog References**: `FINAL/Tropical/TropicalMatrixIteration.lean`, `FINAL/Tropical/SpectralTheory.lean`\n\n**Proof Strategy**: (1) Define the Moser-Tardos state machine. (2) Define the tropical potential function. (3) Prove that each resampling decreases the potential by at least a fixed amount. (4) Use the `lll_algebraic_core` theorem from this cycle to establish that the potential is bounded. (5) Connect the convergence rate to `tropicalMatMap_iterate_lower_bound` from the Catalog.\n\n**Domain Bridges**: Tropical iteration \u2194 Randomized algorithms \u2194 Convergence analysis\n\n**Lineage**: Builds on `lll_algebraic_core`, `symmetric_lll_bound_pos`, and `AlgLLLConfig` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 3: Full Tur\u00e1n Theorem for General r\n\n**Conjecture**: The Tur\u00e1n graph T(n,r) has exactly (1 - 1/r) \u00b7 n\u00b2/2 - c(n,r) edges, where c(n,r) is an explicit correction term depending on n mod r, and every K_{r+1}-free graph on n vertices has at most this many edges.\n\n**Test**: (1) Compute turanEdgeCount(n, r) for n \u2208 [1..20], r \u2208 [2..5] and verify against the formula. (2) Formalize the edge count formula and prove it equals the computed value. (3) Prove the Zykov symmetrization lemma: every K_{r+1}-free graph can be transformed into a complete r-partite graph without losing edges.\n\n**Impact**: Extends this cycle's Mantel theorem (r=2) to the full Tur\u00e1n theorem, one of the foundational results in extremal graph theory. The formalized proof would be among the first machine-verified proofs of Tur\u00e1n's theorem.\n\n**Catalog References**: `turanGraph`, `turan_bipartite_triangle_free`, `mantel_degree_sum` from this cycle.\n\n**Proof Strategy**: (1) Generalize `turan_bipartite_triangle_free` from r=2 to general r using a pigeonhole argument on r+1 vertices in r classes. (2) Prove the edge count formula by summing over pairs of distinct classes. (3) For optimality, use the Zykov symmetrization argument: given a K_{r+1}-free graph, identify two non-adjacent vertices and merge their neighborhoods, showing edges don't decrease. Iterate to obtain a complete r-partite graph.\n\n**Domain Bridges**: Extremal graph theory \u2194 Tropical optimization (Tur\u00e1n's theorem is the LP dual of the clique problem)\n\n**Lineage**: Directly extends `turanGraph`, `turan_bipartite_triangle_free`, and `mantel_degree_sum` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Tropical Chromatic Polynomial\n\n**Conjecture**: The chromatic polynomial P(G, k) of a graph G, evaluated in the tropical semiring, gives the minimum number of monochromatic edges in a k-coloring of G. That is, trop(P)(G, k) = min_{colorings c with k colors} |{edges e : both endpoints same color}|.\n\n**Test**: Compute trop(P)(K_4, 3) and verify it equals the minimum number of monochromatic edges in a 3-coloring of K_4. Since P(K_4, k) = k(k-1)(k-2)(k-3), the tropical version at k=3 should be min(3, 2, 1, 0) = 0, indicating a proper 3-coloring exists (which it does, but K_4 needs 4 colors for proper coloring \u2014 this would disprove the conjecture, which is informative).\n\n**Impact**: If true (possibly after correction), connects graph coloring theory to tropical algebraic geometry. If false, understanding the failure mode reveals the limits of tropicalization as a technique for discrete optimization.\n\n**Catalog References**: `FINAL/Tropical/NormalForm.lean`, `Tropical/ProbabilisticMethod/ErdosMeetsLean.lean`\n\n**Proof Strategy**: (1) Define the chromatic polynomial formally using deletion-contraction. (2) Define tropical evaluation of integer polynomials. (3) Test the conjecture computationally on small graphs. (4) If the conjecture holds with modifications, prove it using inclusion-exclusion in the tropical semiring.\n\n**Domain Bridges**: Tropical algebra \u2194 Graph coloring \u2194 Algebraic combinatorics\n\n**Lineage**: Builds on `TropicalCostStructure` and `tropical_existence_principle` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Information-Theoretic Bounds via Tropical Entropy\n\n**Conjecture**: The Erd\u0151s bound R(k,k) > 2^{k/2} is tight up to polynomial factors because the tropical entropy of a random 2-coloring of K_n concentrates at k/2 \u00b7 log 2. Precisely: define the tropical entropy of a coloring cost function as H_trop = -min_c log\u2082(cost(c)/total_cost). Then for the Ramsey cost function, H_trop = C(k,2) - 1 - log\u2082(C(n,k)) \u2248 k\u00b2/2 when n \u2248 2^{k/2}.\n\n**Test**: Compute H_trop for k = 3,4,5 and n = 2^{k/2} rounded. Verify the tropical entropy is approximately k\u00b2/2 - k log\u2082 k.\n\n**Impact**: Would provide an information-theoretic explanation for why the Erd\u0151s bound is hard to improve: the tropical entropy of the Ramsey cost function is maximized near n = 2^{k/2}, leaving no room for improvement via counting arguments.\n\n**Catalog References**: `Catalog/Tropical/InformationTheory.lean`, `Catalog/Tropical/MutualInformation.lean`\n\n**Proof Strategy**: (1) Define tropical entropy formally. (2) Compute it for the Ramsey cost function. (3) Show it equals C(k,2) - 1 - log\u2082(C(n,k)) when costs are uniform. (4) Prove this is maximized near n = 2^{k/2} using calculus or discrete optimization.\n\n**Domain Bridges**: Information theory \u2194 Tropical algebra \u2194 Ramsey theory \u2194 Entropy optimization\n\n**Lineage**: Builds on `choose_mul_factorial_le_pow`, `pow_two_gt_two_mul`, and `erdos_criterion_k3` from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Geometry"
    ],
    "priority_score": 0.75,
    "status": "in_progress",
    "research_mode": "team",
    "source_exp_id": "7d04715f",
    "consumed_by_exp_id": "a6ad1c91",
    "timestamp": "2026-06-01T16:35:54.932558+00:00"
  },
  {
    "id": "fd_0160",
    "title": "List coloring extension of chordal graph per",
    "description": "# Future Research Directions\n\n## Synthesis\n\nThis research cycle established the list coloring extension of chordal graph perfectness and its application to heterogeneous register allocation. The key result \u2014 that \u03c7\u2097(G) = \u03c7(G) = \u03c9(G) for chordal graphs \u2014 bridges three domains: compiler optimization (SSA register allocation), graph theory (perfect graphs and choosability), and combinatorial optimization (greedy algorithms on structured instances). The formal verification pipeline produced machine-checked proofs of all main theorems, building on the existing catalog of SSA-to-graph-coloring results.\n\nThe most promising cross-domain connection from this cycle is between register pressure profiles and tropical geometry. The register pressure function P(i) = |LaterNeighbors(i)| + 1 at each PEO position encodes the local clique structure. Its maximum equals \u03c9(G), but its full shape \u2014 the \"topography\" of register demand across the program \u2014 contains scheduling information not captured by \u03c9 alone. This function lives naturally in the tropical semiring (\u211d \u222a {\u2212\u221e}, max, +), where \"addition\" is max and \"multiplication\" is +. The connection suggests that tropical algebraic methods could yield new algorithms for register allocation with scheduling constraints.\n\nThe highest breakthrough potential lies in Direction 1 (Online List Coloring for JIT Compilation), because JIT compilers face the heterogeneous register allocation problem in an online setting where variables arrive dynamically. A competitive ratio guarantee for online list coloring on chordal graphs would have immediate practical impact on JIT compiler design for JavaScript engines, JVM implementations, and WebAssembly runtimes.\n\n---\n\n### Direction 1: Online List Coloring for JIT Compilation\n\n**Conjecture**: For chordal graphs revealed online (vertices arrive one at a time with their adjacencies to previously revealed vertices and their color lists), there exists a deterministic online list coloring algorithm with competitive ratio 1 \u2014 i.e., it uses no more colors than the offline optimum \u2014 provided the graph is revealed in reverse PEO order and each list has size \u2265 \u03c9(G).\n\n**Test**: Implement an online simulator that reveals vertices of random chordal graphs (n \u2208 [50, 500]) in reverse PEO order. For each vertex, reveal its adjacencies to already-revealed vertices and a random list of \u03c9(G) colors from a palette of 3\u03c9(G). Run the greedy online algorithm (assign the first available color from the list). Measure whether a valid coloring is always produced. If any instance fails, the conjecture is false.\n\n**Impact**: If true, this provides a theoretical foundation for optimal register allocation in JIT compilers, where compilation happens at runtime and variables are processed as they appear. If false, the failure cases would reveal which graph structures resist online coloring, guiding the design of better JIT heuristics.\n\n**Catalog References**: `Shared/RegisterGraphColoring.lean` (chordal coloring pipeline), `Computation/ListColoringChordal.lean` (list coloring theorems)\n\n**Proof Strategy**: The key would be to show that when vertices arrive in reverse PEO order, each new vertex's already-revealed neighbors form a clique (by the PEO simplicial property). Since the list has \u2265 \u03c9(G) colors and the clique has < \u03c9(G) members, a valid color always exists. The main challenge is formalizing \"online\" in Lean \u2014 likely as a function from partial graphs to colorings satisfying a consistency condition.\n\n**Domain Bridges**: Compiler theory (JIT optimization) \u2194 Online algorithms (competitive analysis) \u2194 Graph theory (chordal structure)\n\n**Lineage**: Builds on greedy_list_coloring_peo and chordal_choosable_of_clique_bound from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Weighted List Coloring and Register Cost Minimization\n\n**Conjecture**: For chordal graphs with a PEO \u03c3 and a cost function w : V \u00d7 C \u2192 \u211d\u22650 (cost of assigning color c to vertex v), there exists a polynomial-time algorithm that finds a minimum-cost list coloring, provided |L(v)| \u2265 \u03c9(G) for all v. The optimal cost can be computed by dynamic programming along the PEO in O(n \u00b7 max|L(v)|\u00b2) time.\n\n**Test**: Generate 200 random chordal graphs with n \u2208 [20, 80]. For each, assign random costs w(v,c) \u2208 [0,1] and lists of size \u03c9(G). Run (a) brute-force optimal list coloring, (b) the proposed DP algorithm. Compare costs. If they always match, the algorithm is correct. If the DP sometimes gives suboptimal results, the conjecture is false.\n\n**Impact**: In real compilers, not all registers are equal. Callee-saved registers require save/restore instructions; some registers are faster for certain operations. A weighted list coloring algorithm would enable cost-optimal register allocation, reducing both code size and execution time.\n\n**Catalog References**: `Shared/RegisterGraphColoring.lean`, `Computation/InfoEfficientAlgorithms.lean` (algorithm efficiency framework)\n\n**Proof Strategy**: The PEO provides a tree decomposition of width \u03c9\u22121. Dynamic programming on tree decompositions is well-studied. The key lemma would be: for each PEO position i, the optimal coloring of positions \u2265 i depends on positions < i only through the colors assigned to the later neighbors of i (which form a clique of size < \u03c9). This gives a state space of at most |C|^\u03c9, yielding polynomial time when \u03c9 is bounded.\n\n**Domain Bridges**: Combinatorial optimization (weighted coloring) \u2194 Compiler optimization (register cost) \u2194 Dynamic programming (tree decomposition)\n\n**Lineage**: Extends the list coloring results to an optimization setting. Builds on greedy_list_coloring_peo.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Tropical Geometry of Register Pressure Profiles\n\n**Conjecture**: The register pressure profile P : Fin n \u2192 \u2115 of a chordal graph G with PEO \u03c3 is a *tropical polynomial* in the sense that P(i) = max_j (a_j + b_j \u00b7 i) for some finite collection of linear functions, where the \"slopes\" b_j correspond to rates of liveness change. Furthermore, the number of linear pieces in P equals the number of maximal cliques in G.\n\n**Test**: Generate 1000 random interval graphs (which are chordal) with n \u2208 [30, 100]. For each, compute the PEO, the pressure profile P, and the number of maximal cliques. Check whether P is always piecewise-linear (i.e., the second differences \u0394\u00b2P are zero except at finitely many breakpoints) and whether the number of pieces equals the number of maximal cliques. A single counterexample disproves the conjecture.\n\n**Impact**: If true, this would establish a dictionary between:\n- Maximal cliques \u2194 Linear pieces of P\n- Clique number \u03c9 \u2194 Maximum value of P\n- Number of maximal cliques \u2194 Tropical degree of P\nThis dictionary would connect register allocation to tropical algebraic geometry, potentially enabling new algorithms based on tropical methods.\n\n**Catalog References**: `Bridges/OperadicTropicalization.lean` (tropical_profile_complete_for_bounded_architecture_congruence), `Computation/OracleApplicationsFrontier.lean` (tropical_and_bound)\n\n**Proof Strategy**: Start by proving the conjecture for interval graphs (where the PEO can be chosen as sorting by left endpoint). In this case, P(i) counts the number of intervals covering the right endpoint of the i-th interval, which is a step function. The breakpoints correspond to maximal cliques (which for interval graphs are exactly the \"coverage peaks\"). The general chordal case would follow from the fact that every chordal graph is an intersection graph of subtrees of a tree.\n\n**Domain Bridges**: Tropical geometry (piecewise-linear functions) \u2194 Graph theory (chordal structure) \u2194 Compiler theory (register pressure)\n\n**Lineage**: Builds on pressure_eq_local_clique and max_pressure_le_clique_bound from this cycle. Connects to tropical_profile_complete_for_bounded_architecture_congruence from the catalog.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Fractional Choosability and Random List Assignments\n\n**Conjecture**: For a chordal graph G with clique number \u03c9 \u2265 3, if each vertex v receives a uniformly random list L(v) of size \u03c9 \u2212 1 from a palette of size 2\u03c9, the probability that a valid list coloring exists approaches 0 as n \u2192 \u221e. More precisely, Pr[colorable] \u2264 exp(\u2212c \u00b7 n) for some constant c > 0 depending on \u03c9.\n\n**Test**: For each \u03c9 \u2208 {3, 5, 7, 10}, generate 500 random chordal graphs with n \u2208 {20, 50, 100, 200}. For each graph, draw 100 random list assignments of size \u03c9 \u2212 1 from a palette of 2\u03c9 colors. Check colorability (by backtracking). Plot the fraction of colorable instances vs. n for each \u03c9. If the fraction decays exponentially, the conjecture is supported. If it plateaus, the conjecture is false.\n\n**Impact**: This would quantify the \"gap\" between \u03c9-choosability (which always succeeds) and (\u03c9\u22121)-choosability (which always fails for adversarial lists). Understanding the probability landscape helps compiler designers understand the robustness of register allocation: how much \"slack\" is needed in register availability to ensure allocation succeeds with high probability?\n\n**Catalog References**: `Computation/CSPPhaseTransition.lean` (phase transition theory), `Computation/ListColoringChordal.lean`\n\n**Proof Strategy**: Use the Lov\u00e1sz Local Lemma or second-moment method. For each maximal clique C of size \u03c9, the probability that C cannot be colored from lists of size \u03c9 \u2212 1 is bounded below (by a birthday-paradox argument). If these \"bad events\" are sufficiently independent (which the chordal structure may guarantee), the probability that ALL cliques are colorable decays exponentially.\n\n**Domain Bridges**: Probabilistic combinatorics (random structures) \u2194 Graph theory (choosability) \u2194 Compiler theory (robustness of allocation)\n\n**Lineage**: Builds on ChordalPerfectness conjecture from this cycle and extends the list coloring analysis to the probabilistic setting.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Register Allocation for Non-SSA Programs via Graph Perfection\n\n**Conjecture**: For programs not in SSA form, the interference graph G satisfies \u03c7(G) \u2264 \u03c9(G) + O(\u221an), where the additive error term depends on the number of \"phi-function eliminations\" or \"critical edges\" that break the chordal structure. More precisely, if G can be made chordal by removing at most d edges, then \u03c7(G) \u2264 \u03c9(G) + d.\n\n**Test**: Generate 300 random \"near-chordal\" graphs: start with a chordal graph on n \u2208 [30, 100] vertices, then add d \u2208 {1, 3, 5, 10} random edges. Compute \u03c7(G) (by exact algorithm for small n, heuristic for larger n) and \u03c9(G). Check whether \u03c7(G) \u2264 \u03c9(G) + d always holds. If a counterexample is found, determine the tightest bound.\n\n**Impact**: Real compiler programs are rarely in perfect SSA form. Understanding how far from optimality register allocation can drift when the interference graph deviates from chordality would guide compiler designers on when to invest in SSA repair vs. accepting suboptimal allocation.\n\n**Catalog References**: `Shared/RegisterGraphColoring.lean` (chordal_colorable_of_clique_bound), `Computation/ListColoringChordal.lean`\n\n**Proof Strategy**: For each added edge e = (u,v), the chromatic number can increase by at most 1 (since removing e reduces the graph to a subgraph). But this gives only \u03c7 \u2264 \u03c7(G\u2212edges) + d = \u03c9 + d, which may be tight. The key question is whether the chordal structure provides better bounds (e.g., \u03c7 \u2264 \u03c9 + \u230ad/2\u230b) due to the interplay between added edges and existing cliques.\n\n**Domain Bridges**: Graph theory (near-perfect graphs) \u2194 Compiler theory (non-SSA programs) \u2194 Parameterized complexity (distance to chordality)\n\n**Lineage**: Extends the exact optimality results to approximate settings. Builds on chordal_colorable_of_clique_bound.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "priority_score": 0.75,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "69828345",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T17:09:29.642604+00:00"
  },
  {
    "id": "fd_0161",
    "title": "Mathematical foundations of tropical hash fu",
    "description": "# Future Research Directions\n\n## Synthesis\n\nThis research cycle established the mathematical foundations of tropical hash functions for cryptocurrency mining. The key discovery is that TSHA preimage fibers are tropical polyhedra \u2014 objects with rich geometric structure that connects cryptographic hash function analysis to tropical geometry and combinatorial optimization. The concatenation decomposition theorem provides a tropical Merkle-Damg\u00e5rd framework, while the collision freedom theorem reveals the (k\u22121)-dimensional tropical cone structure of collision sets.\n\nThe most promising cross-domain connection is between **tropical cryptography and tropical optimization/LP**. The identification TSHA = tropical linear form transforms mining into tropical LP feasibility, opening the door to polynomial-time mining algorithms for constrained problems. This connects to the Catalog's existing tropical algebra work (e.g., `Bridges/MinPlusVerificationCore.lean`, `Tropical/FormulaDefinability.lean`) and suggests that the tropical Merkle idempotency weakness could be addressed through connections to tropical matrix algebra (`Tropical/Matrix/Algebra.lean`).\n\nThe concentration conjecture E[TSHA] \u2248 2N/(k+1) is strongly supported empirically and has a clean order-statistics explanation. Proving this rigorously would establish a calibration theory for tropical mining difficulty \u2014 connecting probability theory to cryptographic protocol design. The variance scaling conjecture (k^{-3}) is less certain and represents the highest-uncertainty/highest-reward direction.\n\n---\n\n### Direction 1: Tropical Hash Security from Nonlinear Tropical Operations\n\n**Conjecture**: Define NTSHA(m, h) = min_i(m_i \u2297 h_i mod p) where \u2297 is tropical multiplication (ordinary +) and mod p is integer modular reduction. Then NTSHA is preimage-resistant: given NTSHA(m,h) and h, finding m requires \u03a9(p^{k/2}) operations in the worst case. The modular reduction breaks shift equivariance and the canonical preimage construction, while the tropical minimum preserves the connection to shortest-path optimization.\n\n**Test**: Implement NTSHA for p = 251 (prime), k = 8. Attempt to find preimages using (1) canonical construction (should fail due to mod), (2) birthday attack on the tropical structure, (3) lattice reduction. Measure preimage-finding time vs. brute force. If any method finds preimages in o(p^{k/2}) time, the conjecture is falsified.\n\n**Impact**: If true, this gives a cryptographically meaningful tropical hash function \u2014 the first that combines tropical algebraic structure with genuine computational hardness. This would make tropical cryptocurrency practically viable, not just theoretically interesting.\n\n**Catalog References**: `Cryptography/TropicalCryptocurrencyMining.lean`, `Catalog/Cryptography/TropicalCryptoPrimitives.lean`, `Catalog/Cryptography/TropicalCryptographyBreakthrough.lean`\n\n**Proof Strategy**: Show that the preimage set of NTSHA is no longer a tropical polyhedron (the mod operation destroys convexity). Establish a reduction from subset-sum or a lattice problem. Key lemma: the modular reduction creates \"folding\" that maps the tropical polyhedron to a union of disconnected regions, each requiring independent search.\n\n**Domain Bridges**: Tropical Geometry \u2194 Number Theory (modular arithmetic), Cryptography \u2194 Lattice Theory\n\n**Lineage**: Builds on the fiber characterization theorem and canonical preimage construction from this cycle. The explicit identification of what makes TSHA insecure (canonical preimage, shift equivariance) directly motivates the nonlinear modification.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Concentration Theorem for Tropical Hash Asymptotics\n\n**Conjecture**: For uniformly random m, h \u2208 {0,...,N}^k, the TSHA value satisfies:\n- E[TSHA(m,h)] = 2N/(k+1) + O(1)\n- Var[TSHA(m,h)] = 2N\u00b2\u00b7k / ((k+1)\u00b2\u00b7(k+2)) + O(N/k\u00b2)\n- TSHA(m,h) converges in distribution to an exponential random variable (appropriately scaled) as k \u2192 \u221e.\n\nThe variance formula follows from the exact distribution of the minimum order statistic from k independent Uniform({0,...,2N}) random variables.\n\n**Test**: Compute exact E[min(X\u2081,...,X_k)] where X_i are iid Uniform({0,1,...,M}) for M = 2N. Compare exact formula against Monte Carlo estimates for k = 5, 10, 20, 50, 100, 200 and N = 100, 1000, 10000. The exact formula for the discrete case involves sums of the form \u03a3_{j=0}^{M} (1 - j/(M+1))^k. If the O(1) error term grows with k, the conjecture needs refinement.\n\n**Impact**: A proven concentration theorem would give exact calibration of tropical mining difficulty. Protocol designers could set the target to achieve any desired expected mining time, with proven concentration bounds guaranteeing stability.\n\n**Catalog References**: `Cryptography/TropicalCryptocurrencyMining.lean` (concentration conjecture section), `Catalog/Tropical/InformationTheory.lean`\n\n**Proof Strategy**: (1) Observe each m_i + h_i ~ Uniform({0,...,2N}) (convolution of two discrete uniforms). (2) Apply the exact order statistics formula for the minimum of k iid discrete uniforms. (3) Bound the error from the discrete-to-continuous approximation using Euler-Maclaurin summation. Key helper lemmas needed: exact CDF of minimum order statistic, tail bounds for discrete distributions.\n\n**Domain Bridges**: Probability Theory \u2194 Tropical Geometry, Order Statistics \u2194 Cryptographic Difficulty Calibration\n\n**Lineage**: Directly extends the concentration conjecture stated and empirically validated in this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Tropical Matrix Hashing and Higher-Order Security\n\n**Conjecture**: Define TMSHA(M, H) = H \u2297_trop M where \u2297_trop is tropical matrix multiplication (using min for addition and + for multiplication), M is a k\u00d7k message matrix, and H is a k\u00d7k key matrix. Then TMSHA is preimage-resistant when k \u2265 3: given TMSHA(M,H) and H, finding M requires solving a system of tropical polynomial equations, which is NP-hard in general.\n\n**Test**: Implement tropical matrix hash for k = 3, 4, 5 with random integer matrices in {0,...,100}^{k\u00d7k}. Count preimage difficulty by exhaustive search over small ranges. Compare to the scalar TSHA case. If preimage difficulty scales polynomially with the matrix dimension (not exponentially), the conjecture fails.\n\n**Impact**: Matrix-valued tropical hashing could provide the computational hardness missing from scalar TSHA while preserving the tropical algebraic structure. This would connect tropical cryptocurrency to tropical linear algebra and the theory of tropical eigenvalues.\n\n**Catalog References**: `Catalog/Tropical/Matrix/Defs.lean`, `Catalog/Tropical/Matrix/Algebra.lean`, `Cryptography/TropicalCryptocurrencyMining.lean`\n\n**Proof Strategy**: Formalize tropical matrix multiplication using existing Catalog infrastructure. Prove that the preimage problem for tropical matrix multiplication reduces to solving a system of min-plus equations, then cite the known NP-hardness of tropical system solving (Bezem et al.). Key lemma: the tropical matrix product (H \u2297 M)_{ij} = min_l(H_{il} + M_{lj}) creates cross-term coupling that the scalar TSHA lacks.\n\n**Domain Bridges**: Tropical Linear Algebra \u2194 Cryptography, Complexity Theory \u2194 Min-Plus Systems\n\n**Lineage**: Extends the scalar TSHA framework to matrix-valued hashes. Uses the `Tropical/Matrix/` infrastructure from the Catalog.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Tropical Merkle Tree Security \u2014 Exploiting Idempotency\n\n**Conjecture**: In a tropical Merkle tree with n leaves drawn uniformly from {0,...,N}, the probability that the Merkle root equals the root of a tree with a duplicated/replaced leaf is at least 1 - 1/n. More precisely, for any target leaf value v \u2264 min(leaves), the root is invariant under replacement of any single leaf by v. This is a \"second-preimage\" attack specific to tropical Merkle trees.\n\n**Test**: For n = 8, 16, 32, 64, 128 and N = 1000, construct random tropical Merkle trees. For each tree, attempt to replace a single leaf while preserving the root. Measure the success rate. If it deviates from the predicted 1 - 1/n, refine the conjecture.\n\n**Impact**: Quantifying the idempotency weakness of tropical Merkle trees would precisely characterize the security gap between tropical and classical blockchain constructions. It would also identify exactly what additional structure (e.g., injective compression functions, nonce commitments) is needed to patch the vulnerability.\n\n**Catalog References**: `Cryptography/TropicalCryptocurrencyMining.lean` (tropicalMerkleNode, idempotency theorem)\n\n**Proof Strategy**: The tropical Merkle root = min(all leaves). Any leaf replacement that doesn't change the global minimum preserves the root. For uniform leaves, the probability that a random leaf is the unique minimum is 1/n. So with probability 1 - 1/n, a given leaf is NOT the minimum and can be replaced by any value \u2265 current minimum. Formalize using Finset.inf properties and counting arguments.\n\n**Domain Bridges**: Data Structures \u2194 Tropical Algebra, Blockchain Security \u2194 Order Statistics\n\n**Lineage**: Extends the tropical Merkle node definition and idempotency theorem from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Tropical Proof-of-Useful-Work via Shortest Path Certification\n\n**Conjecture**: A tropical proof-of-work protocol can be designed where mining is equivalent to solving shortest-path problems on randomly generated graphs. Specifically: the protocol generates a random weighted graph G_n with n vertices and edge weights in {0,...,N}. The mining puzzle is: find a path from vertex 0 to vertex n\u22121 with total weight \u2264 target. The miner's \"block hash\" is the certified shortest path. The difficulty is calibrated by the target relative to the true shortest path length.\n\nThe key mathematical claim: for Erd\u0151s\u2013R\u00e9nyi random graphs G(n, p) with iid Uniform({0,...,N}) edge weights, the shortest path length concentrates around (N/2)\u00b7\u2308log(n)/log(1/p)\u2309, and finding paths significantly below this threshold requires exploring \u03a9(n^c) paths for some c > 0.\n\n**Test**: Generate random graphs with n = 100, 500, 1000 and p = 0.1, 0.3, 0.5. Compute exact shortest paths (Dijkstra). Set target = \u03b1L* where L* is the true shortest path. Measure the number of paths a BFS/random-walk miner must explore vs. \u03b1. If the exploration count doesn't grow exponentially as \u03b1 \u2192 0, the conjecture fails.\n\n**Impact**: This would give the first \"proof-of-useful-work\" cryptocurrency where mining actually solves optimization problems of independent value. The tropical hash connection (TSHA = bipartite shortest path) provides the theoretical bridge.\n\n**Catalog References**: `Cryptography/TropicalCryptocurrencyMining.lean` (tsha_eq_shortest_weighted_path connection), `Catalog/Computation/InfoEfficientAlgorithms.lean`\n\n**Proof Strategy**: Formalize the bipartite graph interpretation of TSHA. Extend to general graphs by showing that shortest-path computation in an n-vertex graph can be expressed as iterated tropical matrix-vector multiplication. Use concentration inequalities for shortest paths in random graphs (known results from probabilistic combinatorics). Key lemma: the shortest s-t path in G(n,p) with Uniform edge weights has variance O(N\u00b2/n).\n\n**Domain Bridges**: Graph Theory \u2194 Cryptocurrency Mining, Tropical Algebra \u2194 Network Optimization, Computational Complexity \u2194 Protocol Design\n\n**Lineage**: Extends the TSHA-shortest-path equivalence from this cycle's cross-domain theorem.\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "priority_score": 0.75,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "031ed73c",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T17:09:58.296621+00:00"
  },
  {
    "id": "fd_0162",
    "title": "Formal theory connecting classical impossibili",
    "description": "# Future Directions: Impossibility Theory via Equivariant Obstructions\n\n## Synthesis\n\nThis research cycle established a formal theory connecting classical impossibility theorems through the lens of equivariant tasks on free group actions. The key results \u2014 the Transfer Principle, Product Composition, Spectral Upward Closure, and Equivariant Bijectivity \u2014 form a self-consistent algebraic framework for reasoning about impossibility. The most promising cross-domain connection is between the impossibility spectrum (a novel invariant measuring which subgroups witness impossibility) and existing Catalog results on Galois obstructions (`Algebra/GaloisObstruction.lean`) and equivariant impossibility (`Catalog/Bridges/Speculative/EquivariantImpossibility/Core.lean`).\n\nThe highest breakthrough potential lies in Direction 1 (Spectral Gap Conjecture), because it would transform the impossibility spectrum from a qualitative concept into a computable, classifying invariant \u2014 giving each impossibility theorem a \"fingerprint\" based on its minimal witnessing subgroups. The connection to the existing `exists_impossible_equivariant_task_of_free_action` theorem is direct: our spectral analysis refines the binary existence result into a graded hierarchy. Direction 3 (Categorical Impossibility Functor) could unify the Transfer Principle with existing Galois obstruction results, potentially yielding a functorial framework where impossibility theorems compose naturally.\n\nThe cycle's results relate to the broader Catalog through the bridge between algebra and computation: the stabilizer characterization (free \u2194 all stabilizers trivial) connects to `Computation/InfoEfficientAlgorithms.lean` (algorithmic lower bounds as symmetry obstructions), while the product composition theorem extends the cross-domain bridge principle in `Bridges/AlgebraEMLClosureComputation.lean` (closure systems preserve structural invariants under products).\n\n---\n\n### Direction 1: Spectral Gap Conjecture for Impossibility Spectra\n\n**Conjecture**: For any finite group G acting on a finite set X, the impossibility spectrum Spec_imp(G, X) = {H \u2264 G | H \u2260 1 and X^H = \u2205} can have \"gaps\" \u2014 that is, there exist actions where a nontrivial subgroup H has fixed points (H \u2209 Spec_imp) but a proper subgroup K < H has no fixed points (K \u2208 Spec_imp). More precisely: there exists a group G, a G-set X, and subgroups K < H \u2264 G with K \u2208 Spec_imp(G,X) and H \u2209 Spec_imp(G,X).\n\n**Test**: Construct an explicit action of Z\u2086 on a 6-element set where the subgroup Z\u2082 has no fixed points but the subgroup Z\u2083 does. This would be a concrete spectral gap. Computationally verify using GAP or SageMath by enumerating all actions of small groups on small sets and computing their spectra.\n\n**Impact**: If spectral gaps exist, the impossibility spectrum is NOT a sublattice of the subgroup lattice \u2014 it's merely an upper set. This means impossibility can be \"deeper\" than expected: small symmetries can create obstructions that larger symmetries don't, fundamentally undermining the intuition that \"more symmetry = more impossibility.\" If spectral gaps don't exist for certain classes of groups (e.g., abelian groups), this would be a surprising rigidity result.\n\n**Catalog References**: `Catalog/Bridges/Speculative/EquivariantImpossibility/Core.lean` (ImpossibilitySpectrum definition), `Computation/Impossibility/Core.lean` (spectrum_upward_closed, spectrum_contains_top_of_free_nontrivial)\n\n**Proof Strategy**: For the existence direction, consider G = Z\u2086 = \u27e8g | g\u2076 = 1\u27e9 acting on X = {0,1,2,3,4,5} by g \u00b7 k = (k + 1) mod 6. The subgroup Z\u2082 = {1, g\u00b3} has fixed points iff g\u00b3 fixes some element, i.e., (k+3) mod 6 = k, which has no solutions \u2014 so Z\u2082 \u2208 Spec. The subgroup Z\u2083 = {1, g\u00b2, g\u2074} fixes k iff (k+2) mod 6 = k, also no solutions \u2014 so Z\u2083 \u2208 Spec too. Try instead a non-regular action. Define X = {a, b, c} with g acting as (a b c)(a b c) = rotation by 2. Then g\u00b2 acts as identity on some elements. Need careful construction.\n\n**Domain Bridges**: Algebra (subgroup lattice theory) \u2194 Computation (impossibility hierarchy)\n\n**Lineage**: Builds on spectrum_upward_closed and ImpossibilitySpectrum from this cycle's Computation/Impossibility/Core.lean\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Impossibility Transfer via Non-Surjective Homomorphisms\n\n**Conjecture**: The Transfer Principle (impossibility transfers along surjective homomorphisms) can be partially extended to non-surjective homomorphisms. Specifically, if \u03c6 : H \u2192* G is a group homomorphism with image containing a nontrivial element that acts freely, then the impossibility of equivariant constant maps transfers from G to H. The precise condition is: im(\u03c6) \u2229 (G \\ {1}) \u2260 \u2205 and the restricted action of im(\u03c6) on X is free.\n\n**Test**: Formalize the theorem: if \u03c6 : H \u2192* G is a homomorphism (not necessarily surjective) and the subgroup im(\u03c6) acts freely and nontrivially on X, then no H-equivariant (via \u03c6) constant map X \u2192 X exists. Verify that the proof reduces to applying the core impossibility theorem to im(\u03c6) acting on X.\n\n**Impact**: This would show that impossibility transfer is more general than surjectivity \u2014 any homomorphism that \"hits\" enough of the free-acting part of G transfers the impossibility. This connects to representation theory: the condition on im(\u03c6) relates to faithfulness of the induced representation.\n\n**Catalog References**: `Computation/Impossibility/Core.lean` (impossibility_transfer), `Algebra/GaloisObstruction.lean` (not_solvableByRad_root_of_Gal_not_solvable)\n\n**Proof Strategy**: Apply no_equivariant_constant to the subgroup im(\u03c6) with the restricted MulAction instance. Need to verify that the MulAction of a subgroup inherits freeness from the ambient group's freeness restricted to that subgroup. The key lemma is: if G acts freely and H \u2264 G with H \u2260 1, then H acts freely (this follows directly from the definition since H-elements are G-elements).\n\n**Domain Bridges**: Algebra (homomorphism theory) \u2194 Computation (impossibility transfer)\n\n**Lineage**: Extends impossibility_transfer from this cycle\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Categorical Impossibility Functor\n\n**Conjecture**: There exists a contravariant functor F from the category FreeAct (objects: free nontrivial group actions, morphisms: equivariant surjections) to the category of propositions (ordered by implication) that maps each action to its impossibility proposition. The functor sends morphisms (equivariant surjections) to implications (if the codomain action has an impossible task, so does the domain).\n\n**Test**: Define the category FreeAct in Lean 4 (objects = (G, X, free nontrivial G-action on X), morphisms = pairs (\u03c6 : G\u2081 \u2192* G\u2082, \u03c8 : X\u2081 \u2192 X\u2082) with \u03c6 surjective and \u03c8 equivariant). Define the functor mapping (G, X) to the proposition \"\u2203 T : EquivariantTask G X X, \u00ac TaskSolvable G X X T\" and verify functoriality (composition of morphisms gives composition of implications).\n\n**Impact**: If successful, this would provide a categorical foundation for the entire impossibility theory, enabling abstract nonsense-style reasoning about impossibility. It would also connect to existing categorical infrastructure in Mathlib (Mathlib.CategoryTheory).\n\n**Catalog References**: `Computation/Impossibility/Core.lean` (full framework), `Catalog/Bridges/Speculative/EquivariantImpossibility/Core.lean` (exists_impossible_equivariant_task_of_free_action)\n\n**Proof Strategy**: (1) Define the category FreeAct as a structure with group, type, MulAction, freeness proof, and nontriviality proof. (2) Define morphisms as equivariant surjective homomorphism pairs. (3) Show the impossibility proposition is functorial by composing the transfer principle with equivariant map composition. Key challenge: universe management in Lean 4 when defining categories with Type* objects.\n\n**Domain Bridges**: Algebra (category theory) \u2194 Computation (impossibility theory) \u2194 Logic (propositions as objects)\n\n**Lineage**: Synthesizes impossibility_transfer and exists_impossible_equivariant_task_of_free_action\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 4: Quantitative Impossibility Measure via Index Theory\n\n**Conjecture**: For a finite group G acting freely on a finite set X, define the *impossibility index* as idx(G, X) = min { [G : H] | H \u2208 Spec_imp(G, X) }, i.e., the minimal index of a subgroup in the spectrum. Then idx(G, X) divides |G| and equals 1 if and only if the full group is the unique minimal element of the spectrum. Furthermore, idx captures a \"degree of impossibility\": higher index means the impossibility requires more of the group's symmetry.\n\n**Test**: Compute idx for (1) S\u2085 acting on 5-element set (expected: 1, since even tiny subgroups have no fixed points on a set acted on freely); (2) Z_p acting on itself for primes p (expected: p, since the only nontrivial subgroup is the whole group); (3) D_n (dihedral group) acting on n-gon vertices. Compare the index to known algebraic invariants of the group.\n\n**Impact**: If the impossibility index correlates with algebraic complexity measures (e.g., derived length, nilpotency class), this would quantify the informal notion that \"some impossibilities are harder than others.\" The quintic's impossibility (A\u2085 is simple, so every nontrivial subgroup is \"large\") would have a different index profile than Arrow's impossibility (S_n has many small subgroups).\n\n**Catalog References**: `Computation/Impossibility/Core.lean` (ImpossibilitySpectrum), `Computation/InfoEfficientAlgorithms.lean` (potential-based complexity measures)\n\n**Proof Strategy**: Define idx in Lean 4 using Finset.inf over the spectrum restricted to Fintype groups. Prove basic properties: idx divides |G|, idx = 1 iff \u22a4 is minimal in spectrum, idx > 1 iff the action has \"spectral depth.\" For the cyclic prime case, show the spectrum is {Z_p} by proving every proper subgroup is trivial (since Z_p is simple).\n\n**Domain Bridges**: Algebra (index theory, subgroup structure) \u2194 Computation (complexity measures)\n\n**Lineage**: Extends ImpossibilitySpectrum and spectrum_upward_closed from this cycle\n\n**Ambition**: extension\n\n---\n\n### Direction 5: Diagonal Impossibility vs. Equivariant Impossibility\n\n**Conjecture**: There exist impossibility theorems that are provably NOT instances of equivariant impossibility \u2014 i.e., impossibility phenomena that cannot be realized as \"no equivariant map exists on a free action\" for any group G and action. Specifically, the halting problem's undecidability is not an instance of equivariant impossibility: there is no group G acting freely on the set of Turing machines such that a halting oracle would be an equivariant map.\n\n**Test**: Formalize the halting problem as a decision problem. Attempt to show: for any group G and free action of G on the set of Turing machine descriptions, a G-equivariant halting oracle exists (i.e., the equivariant framework does NOT obstruct it). This would demonstrate that the halting problem's impossibility comes from a fundamentally different source (diagonalization, not symmetry).\n\n**Impact**: This would establish a formal boundary for the equivariant impossibility framework: it captures algebraic/geometric impossibilities (quintic, trisection, Arrow) but NOT computability-theoretic impossibilities (halting, Rice's theorem, G\u00f6del). This boundary would be mathematically precise and would answer the meta-question: \"Is all impossibility the same impossibility?\" with a definitive \"no.\"\n\n**Catalog References**: `Computation/Impossibility/Core.lean` (equivariant impossibility framework), `Computation/AutomatedTheoryOracle.lean` (sound_complete_oracle_exists), `EML/DiagonalPhaseTransition.lean` (exists_incompressible_iff_not_all_compressible)\n\n**Proof Strategy**: (1) Model Turing machines as elements of a countable type TM. (2) Observe that any group acting freely on TM must be at most countable. (3) Show that for any countable group G acting on TM, there exists a G-equivariant function f : TM \u2192 Bool (since the orbits are countable, one can define f orbit-by-orbit using choice). (4) Conclude that the halting problem's undecidability is not captured by the equivariant framework.\n\n**Domain Bridges**: Computation (halting problem, computability) \u2194 Algebra (group actions) \u2194 Logic (diagonalization vs. symmetry)\n\n**Lineage**: Builds on the full equivariant impossibility framework from this cycle, connects to diagonal phase transition results in EML\n\n**Ambition**: grand_challenge\n",
    "domains": [
      "Algebra",
      "Computation"
    ],
    "priority_score": 0.75,
    "status": "in_progress",
    "research_mode": "team",
    "source_exp_id": "adade94b",
    "consumed_by_exp_id": "18e34d1c",
    "timestamp": "2026-06-01T17:10:18.192216+00:00"
  },
  {
    "id": "fd_0163",
    "title": "Algebraic foundations of monstrous moonshine",
    "description": "# Future Research Directions: Monstrous Moonshine and Beyond\n\n## Synthesis\n\nThis research cycle established the algebraic foundations of monstrous moonshine in a formally verified setting, proving that character orthogonality alone constrains McKay-Thompson series in powerful ways. Three key theorems were proved: the Burnside dimension identity linking squared representation dimensions to group order, the multiplicity recovery theorem showing McKay-Thompson series determine all graded multiplicities, and the moonshine inner product identity computing cross-grade representation overlaps. These results are purely algebraic\u2014they hold for any finite group with a graded module structure, not just the Monster.\n\nThe most promising cross-domain connection from this cycle is the bridge between **character theory** (finite group algebra) and **formal power series** (analytic number theory). Our MoonshineDatum structure captures precisely the algebraic content needed for moonshine, stripping away the analytic/modular aspects. This creates a clean interface: future work can extend either the algebraic side (vertex algebras, Lie algebras) or the analytic side (modularity, q-expansion convergence) independently, connecting through this shared formalism. The inner product identity (Theorem 3.4 in the paper) is particularly promising for computational applications, as it provides a quadratic consistency check on McKay-Thompson data.\n\nThe highest breakthrough potential lies in Direction 1 (Vertex Algebra Formalization), because vertex algebras are the mathematical structure that *explains* why moonshine exists, yet they remain largely unformalized. A working formalization would enable machine-verified proofs of moonshine-type results for other groups, potentially leading to discoveries in umbral moonshine.\n\n---\n\n### Direction 1: Vertex Algebra Formalization for Moonshine\n\n**Conjecture**: A vertex algebra structure on a graded module V = \u2295 V\u2099 with Monster action automatically implies that the McKay-Thompson series T_g(q) = \u03a3 tr(g|V\u2099)q\u207f is a modular function of genus zero for a specific congruence subgroup \u0393_g \u2282 SL(2, \u211d), provided V satisfies the \"C\u2082-cofiniteness\" condition.\n\n**Test**: Formalize the axioms of a vertex operator algebra (VOA) in Lean 4: state space V, vacuum vector |0\u27e9, conformal vector \u03c9, vertex operators Y(v,z) = \u03a3 v\u2099z\u207b\u207f\u207b\u00b9 satisfying locality, and the Virasoro algebra relations [L\u2098, L\u2099] = (m-n)L\u2098\u208a\u2099 + (c/12)(m\u00b3-m)\u03b4\u2098\u208a\u2099,\u2080. Define \"holomorphic VOA\" (V\u2080 = \u2102, no negative grades). Prove that for a holomorphic VOA of central charge 24 with Monster symmetry, the graded dimension generating function satisfies j(q) - 744. If the VOA axioms are insufficient to derive modularity, this failure identifies exactly which additional structure (e.g., rationality, regularity) is needed.\n\n**Impact**: Vertex algebras are the \"explanation\" for moonshine, but they have never been formalized in a proof assistant. Success would open the door to machine-verified proofs of Borcherds' theorem and enable systematic exploration of new moonshine phenomena.\n\n**Catalog References**: `Physics/MonstrousMoonshine.lean` (CharacterTable, MoonshineDatum structures)\n\n**Proof Strategy**: \n1. Define a `VertexAlgebra` structure in Lean 4 with fields for the state space, vertex operators, vacuum, and conformal vector.\n2. State the Jacobi identity for vertex operators as an axiom.\n3. Define the Virasoro algebra action from the conformal vector.\n4. Prove that grading by L\u2080-eigenvalue is compatible with the vertex algebra structure.\n5. Define \"holomorphic VOA\" and prove that the graded trace is an SL(2,\u2124)-invariant function (Zhu's theorem).\n\n**Domain Bridges**: Algebra (representation theory) \u2194 Physics (conformal field theory) \u2194 Number Theory (modular forms)\n\n**Lineage**: Builds on CharacterTable and MoonshineDatum from this cycle's Physics/MonstrousMoonshine.lean.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Computational Moonshine \u2014 Recovering Monster Representations from McKay-Thompson Data\n\n**Conjecture**: Using the multiplicity recovery theorem with the known 194 McKay-Thompson series of the Monster, the multiplicities mult(\u03c1\u1d62, V\u2099) can be computed exactly for all 194 irreducible representations \u03c1\u1d62 and all grades n \u2264 1000, and these multiplicities are all non-negative integers (providing a computational proof of the consistency of the moonshine module construction up to grade 1000).\n\n**Test**: Implement the multiplicity recovery algorithm: mult(i, n) = (1/|M|) \u03a3\u2c7c |C_j| \u03c7\u1d62(g\u2c7c) a\u2099(g\u2c7c) using the Monster's character table (194 \u00d7 194 rational integer matrix, available from the ATLAS of Finite Groups) and the McKay-Thompson coefficients a\u2099(g\u2c7c) (computable from the known Hauptmoduls for each conjugacy class). Verify that all 194 \u00d7 1000 = 194,000 computed multiplicities are non-negative integers. If any are negative or non-integral, this would indicate an error in the published character table or McKay-Thompson series data.\n\n**Impact**: This would be the most extensive computational verification of monstrous moonshine ever performed, and would provide concrete data for testing further conjectures about the growth rate and distribution of multiplicities.\n\n**Catalog References**: `Physics/MonstrousMoonshine.lean` (multiplicity_recovery theorem)\n\n**Proof Strategy**: \n1. Obtain the Monster character table from the ATLAS (or GAP computational algebra system).\n2. Compute McKay-Thompson series coefficients using the known Hauptmodul expressions (e.g., T_{2A}(q) = (\u03b7(q)/\u03b7(q\u00b2))\u00b2\u2074 + 24, etc.).\n3. Apply the multiplicity formula for each (i, n) pair.\n4. Verify non-negativity and integrality.\n5. Analyze the growth rate of max_i mult(i, n) as n \u2192 \u221e and compare with theoretical predictions from the Rademacher-type formulas.\n\n**Domain Bridges**: Algebra (character tables) \u2194 Computation (exact arithmetic) \u2194 Number Theory (modular forms, eta products)\n\n**Lineage**: Direct application of multiplicity_recovery theorem from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Trace Dominance and the Moonshine Bound\n\n**Conjecture**: For any finite group G with a faithful graded representation V = \u2295 V\u2099 (where each V\u2099 is finite-dimensional), the trace dominance property |tr(g|V\u2099)| \u2264 dim(V\u2099) holds for all g \u2208 G and all n. Moreover, equality |tr(g|V\u2099)| = dim(V\u2099) holds if and only if g acts as a scalar on V\u2099.\n\n**Test**: The first part (|tr(g|V)| \u2264 dim(V) for finite-dimensional representations) follows from the triangle inequality: if \u03c1(g) has eigenvalues \u03bb\u2081, ..., \u03bb_d with |\u03bb\u1d62| = 1, then |\u03a3 \u03bb\u1d62| \u2264 d. Formalize this in Lean 4 using Mathlib's linear algebra library. For the equality characterization, show that |\u03a3 \u03bb\u1d62| = d implies all \u03bb\u1d62 are equal. Test computationally for the Monster: for each of the 194 conjugacy classes g and grades n = 1, ..., 100, compute |tr(g|V\u2099)|/dim(V\u2099) and plot the distribution.\n\n**Impact**: This would establish the trace dominance conjecture as a theorem (not just a conjecture) and provide a universal bound on McKay-Thompson coefficients. The equality characterization identifies which group elements act \"coherently\" on each graded piece.\n\n**Catalog References**: `Physics/MonstrousMoonshine.lean` (MoonshineDatum.traceDominance definition)\n\n**Proof Strategy**: \n1. In Lean 4, define a finite-dimensional representation \u03c1 : G \u2192 GL(V) over \u2102.\n2. Use the spectral theorem: \u03c1(g) is diagonalizable (since g has finite order) with eigenvalues that are roots of unity.\n3. Apply the triangle inequality: |tr(\u03c1(g))| = |\u03a3 \u03bb\u1d62| \u2264 \u03a3 |\u03bb\u1d62| = dim(V).\n4. For the equality case, use the strict triangle inequality: equality in |\u03a3 \u03bb\u1d62| \u2264 \u03a3 |\u03bb\u1d62| holds iff all \u03bb\u1d62 have the same argument, i.e., \u03bb\u1d62 = \u03b6 for some root of unity \u03b6, meaning g acts as scalar multiplication by \u03b6.\n\n**Domain Bridges**: Algebra (representation theory, spectral theory) \u2194 Analysis (triangle inequality) \u2194 Physics (MonstrousMoonshine.lean)\n\n**Lineage**: Extends the traceDominance definition from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Supersingular Primes and the Ogg\u2013Monster Connection\n\n**Conjecture**: The 15 prime divisors of |M| (the supersingular primes: 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71) are exactly the primes p for which the modular curve X\u2080\u207a(p) = X\u2080(p)/w_p has genus zero, where w_p is the Atkin-Lehner involution. Equivalently, they are the primes p such that the function field of X\u2080\u207a(p) is generated by a single function (a Hauptmodul).\n\n**Test**: For each prime p \u2264 100, compute the genus of X\u2080\u207a(p) using the formula:\ngenus(X\u2080\u207a(p)) = (1/2)\u00b7genus(X\u2080(p)) + (1/4)\u00b7(1 - (-1/p)) - (something involving class numbers)\nwhere genus(X\u2080(p)) is given by a standard formula involving p. Verify that genus(X\u2080\u207a(p)) = 0 if and only if p \u2208 {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71}. Then formalize the genus computation in Lean 4, proving the characterization for each specific prime.\n\n**Impact**: Ogg's observation (1975) predates the proof that the Monster exists. A formalized proof that the supersingular primes = genus-zero primes for X\u2080\u207a(p) would be a significant contribution to formal mathematics, and would sharpen the question of *why* these primes divide |M|.\n\n**Catalog References**: `Physics/MonstrousMoonshine.lean` (supersingularPrimes, monsterOrder)\n\n**Proof Strategy**: \n1. Define the modular curve X\u2080(N) as the quotient of the upper half-plane by \u0393\u2080(N).\n2. Implement the genus formula for X\u2080(N): g = 1 + \u03bc/12 - \u03bd\u2082/4 - \u03bd\u2083/3 - \u03bd_\u221e/2 where \u03bc = [SL(2,\u2124):\u0393\u2080(N)], \u03bd\u2082 counts elliptic points of order 2, \u03bd\u2083 of order 3, and \u03bd_\u221e counts cusps.\n3. Define the Atkin-Lehner involution w_p and compute genus(X\u2080\u207a(p)) via the Riemann-Hurwitz formula.\n4. For each prime p \u2264 71, verify the genus computation.\n5. Prove that for p = 73 (the next prime), genus(X\u2080\u207a(73)) > 0.\n\n**Domain Bridges**: Number Theory (modular curves, genus formulas) \u2194 Algebra (Monster group order) \u2194 Geometry (Riemann surfaces)\n\n**Lineage**: Extends the supersingularPrimes definition from this cycle; connects to Ogg's original observation.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 5: Moonshine for Other Sporadic Groups (Umbral Moonshine Framework)\n\n**Conjecture**: The MoonshineDatum framework from this cycle can be extended to capture *umbral moonshine*: for each of the 23 Niemeier lattices N (even unimodular lattices in 24 dimensions, excluding the Leech lattice), the automorphism group Aut(N) gives rise to a moonshine datum where the McKay-Thompson series are *mock modular forms* rather than modular functions. The multiplicity recovery theorem (Theorem 3.3) still applies, but the graded multiplicities may involve virtual representations (negative multiplicities) at finite grades.\n\n**Test**: Take the simplest case: the A\u2081\u00b2\u2074 Niemeier lattice, whose relevant group is a quotient of the Mathieu group M\u2082\u2084. Compute the first 50 multiplicities using the Mathieu moonshine McKay-Thompson series (which are mock modular forms of weight 1/2) and verify that they are non-negative integers. Compare with the known decomposition from Cheng-Duncan-Harvey.\n\n**Impact**: Umbral moonshine is the major extension of monstrous moonshine discovered in 2012-2014. Formalizing its algebraic structure would unify monstrous and umbral moonshine in a single framework, potentially revealing new moonshine phenomena for other groups.\n\n**Catalog References**: `Physics/MonstrousMoonshine.lean` (MoonshineDatum, multiplicity_recovery)\n\n**Proof Strategy**: \n1. Define `UmbralMoonshineDatum` extending MoonshineDatum with a \"shadow\" function connecting mock modular forms to genuine modular forms.\n2. Prove that the multiplicity recovery theorem extends to the umbral setting (the algebra is identical; only the analytic properties of the series change).\n3. Implement the Mathieu moonshine McKay-Thompson series computationally and verify multiplicities.\n4. Investigate whether the inner product identity (Theorem 3.4) has an umbral analogue involving the shadow.\n\n**Domain Bridges**: Algebra (sporadic groups, lattice theory) \u2194 Number Theory (mock modular forms) \u2194 Physics (K3 surfaces, string compactifications)\n\n**Lineage**: Generalizes the MoonshineDatum framework from this cycle to the umbral setting.\n\n**Ambition**: extension\n",
    "domains": [
      "Algebra",
      "Pythagorean"
    ],
    "priority_score": 0.75,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "5c653e4c",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T17:10:35.989068+00:00"
  },
  {
    "id": "fd_0164",
    "title": "Formal foundation for orbit shadowing in dynam",
    "description": "# Future Research Directions: Shadowing Theory and Computational Dynamics\n\n## Synthesis\n\nThis research cycle established a formal foundation for orbit shadowing in dynamical systems, centered on three pillars: (1) the contractive shadowing lemma with an explicit geometric-series bound \u03b4/(1\u2212L), (2) shadowing uniqueness for expansive maps, and (3) the novel concept of a Shadowing Certificate \u2014 a computational witness structure that bundles a pseudo-orbit with its verified shadowing true orbit. The key cross-domain connection is between **dynamical systems theory** and **verified computation**: the Shadowing Certificate transforms the abstract existence theorem of Anosov\u2013Bowen into a concrete, composable programming object. This bridges the Catalog's existing work on error suppression (`Physics/ToricCode.lean`), shadow energy certificates (`Physics/LongTimeMetastability.lean`), and fixed-point orbit bounds (`Bridges/HolographicProofRenormalization.lean`) into a unified framework where numerical error is not noise but certified shadowing of genuine dynamics.\n\nThe most promising direction is **hyperbolic shadowing** (Direction 1), which would extend our contractive results to the full Anosov\u2013Bowen setting, requiring formalization of stable/unstable manifold theory. This is both a grand challenge in formal mathematics and a gateway to certifying simulations of genuinely chaotic systems like the Lorenz attractor. The second high-priority direction is **stochastic shadowing** (Direction 2), which would connect our deterministic framework to random dynamical systems and ergodic theory, opening bridges to the Catalog's EML theory. Direction 3 extends the Shadowing Certificate concept into a programming paradigm for certified numerical computation, with potential applications to scientific computing and safety-critical simulation.\n\n---\n\n### Direction 1: Hyperbolic Shadowing Lemma for Anosov Diffeomorphisms\n\n**Conjecture**: For any C\u00b9 Anosov diffeomorphism f on a compact Riemannian manifold M (meaning the tangent bundle splits as TM = E^s \u2295 E^u with Df contracting on E^s and expanding on E^u, uniformly), for every \u03b5 > 0 there exists \u03b4 > 0 such that every \u03b4-pseudo-orbit of f is \u03b5-shadowed by a unique true orbit. Moreover, the shadowing constant satisfies \u03b4 \u2264 C\u00b7\u03b5 where C depends only on the hyperbolicity constants (contraction rate \u03bb_s < 1, expansion rate \u03bb_u > 1, and the angle between E^s and E^u).\n\n**Test**: Formalize the definition of an Anosov diffeomorphism in Lean 4. As a concrete test case, prove the shadowing lemma for the hyperbolic toral automorphism A = [[2,1],[1,1]] acting on T\u00b2 = \u211d\u00b2/\u2124\u00b2, which is the simplest Anosov diffeomorphism. Verify that the shadowing constant matches the eigenvalue ratio (golden ratio).\n\n**Impact**: This would be the first formal proof of the full Anosov shadowing lemma, bridging differential topology (stable/unstable manifolds) with metric dynamics (pseudo-orbits). It would enable certified shadowing for genuinely chaotic systems, not just contractive ones.\n\n**Catalog References**: `Physics/ShadowingLemma.lean` (this cycle), `Bridges/HolographicProofRenormalization.lean` (fixed-point orbit bounds), `Physics/LongTimeMetastability.lean` (shadow energy certificates)\n\n**Proof Strategy**: \n1. Define uniform hyperbolicity: TM = E^s \u2295 E^u with \u2016Df|_{E^s}\u2016 \u2264 \u03bb_s < 1 and \u2016Df\u207b\u00b9|_{E^u}\u2016 \u2264 \u03bb_u\u207b\u00b9 < 1.\n2. Construct the shadowing orbit as a fixed point of a contraction on the space of sequences (the \"graph transform\" method).\n3. Use Banach's fixed-point theorem on the product space \u220f_n X to find the shadowing orbit.\n4. The key technical lemma is that the graph transform operator has Lipschitz constant max(\u03bb_s, \u03bb_u\u207b\u00b9) < 1, reducing to the contractive case.\n\n**Domain Bridges**: Dynamical Systems \u2194 Differential Topology \u2194 Functional Analysis (Banach fixed-point on sequence spaces)\n\n**Lineage**: Builds on `contractive_shadowing_bound` and `ShadowingCertificate` from this cycle. Extends the contractive case to the hyperbolic case by decomposing along stable/unstable directions.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 2: Stochastic Shadowing for Random Dynamical Systems\n\n**Conjecture**: For a random dynamical system (f_\u03c9)_{\u03c9 \u2208 \u03a9} where each f_\u03c9 is a contraction with Lipschitz constant L_\u03c9 < 1 (where L_\u03c9 is uniformly bounded by some L < 1), every \u03b4-pseudo-orbit of the random system is almost surely shadowed by a true random orbit with bound \u03b4/(1 \u2212 L). Furthermore, the Shadowing Certificate extends to a *Probabilistic Shadowing Certificate* that certifies shadowing with probability 1.\n\n**Test**: Define a random dynamical system as a sequence of maps f_n drawn from a distribution. Prove that the contractive shadowing bound holds pathwise. As a computational test: generate 10,000 random contractive maps with L \u2208 [0.3, 0.7], compose them, and verify that every pseudo-orbit is shadowed within the predicted bound.\n\n**Impact**: Would connect shadowing theory to ergodic theory and stochastic analysis, enabling certified simulation of random systems (e.g., stochastic differential equations discretized by Euler-Maruyama). Would bridge the Catalog's EML framework (which studies ensemble complexity) with dynamical systems.\n\n**Catalog References**: `Physics/ShadowingLemma.lean`, `EML/AdvancedTheory.lean` (ensemble complexity), `EML/EMLv17Core.lean` (EML diagrams)\n\n**Proof Strategy**:\n1. Define a random dynamical system as a measurable map \u03c6: \u03a9 \u00d7 X \u2192 X.\n2. Define random pseudo-orbits and random shadowing.\n3. Prove pathwise shadowing using the deterministic contractive lemma applied to each realization.\n4. Extend the ShadowingCertificate to include a probability measure on the space of certificates.\n\n**Domain Bridges**: Dynamical Systems \u2194 Probability Theory \u2194 EML (ensemble methods)\n\n**Lineage**: Builds on `contractive_shadowing_bound` and `ShadowingCertificate` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 3: Shadowing Certificates as a Verified Computation Paradigm\n\n**Conjecture**: For any Lipschitz map f: \u211d\u207f \u2192 \u211d\u207f implemented in IEEE 754 double-precision floating-point, the floating-point implementation f\u0303 satisfies \u2016f\u0303(x) - f(x)\u2016 \u2264 \u03b5_mach \u00b7 \u2016f\u2016_Lip \u00b7 \u2016x\u2016 for all representable x, where \u03b5_mach \u2248 2.2 \u00d7 10\u207b\u00b9\u2076. Therefore, every N-step floating-point trajectory is a \u03b4-pseudo-orbit with \u03b4 \u2264 N \u00b7 \u03b5_mach \u00b7 \u2016f\u2016_Lip \u00b7 max_n \u2016x_n\u2016, and the Shadowing Certificate can be constructed automatically from the floating-point computation.\n\n**Test**: Implement an automatic Shadowing Certificate generator that takes a floating-point trajectory and outputs a certificate with verified bounds. Test on: (1) the logistic map with 10\u2076 steps, (2) the H\u00e9non map with 10\u2075 steps, (3) the Lorenz system discretized by RK4 with 10\u2074 steps.\n\n**Impact**: Would create a new paradigm for verified numerical computation where chaotic simulations come with guaranteed shadowing certificates. Instead of bounding the error of a specific computation (impossible for chaotic systems), we certify that the computation shadows *some* true trajectory with bounded distance.\n\n**Catalog References**: `Physics/ShadowingLemma.lean`, `Computation/InfoEfficientAlgorithms.lean` (algorithm efficiency bounds)\n\n**Proof Strategy**:\n1. Formalize IEEE 754 floating-point error bounds in Lean.\n2. Prove that Lipschitz maps composed with floating-point arithmetic produce pseudo-orbits.\n3. Apply the contractive shadowing lemma (or hyperbolic shadowing if available) to certify the trajectory.\n4. Package the result as an automatic certificate generator.\n\n**Domain Bridges**: Dynamical Systems \u2194 Computer Science (floating-point arithmetic) \u2194 Computation Theory (certified algorithms)\n\n**Lineage**: Builds on `ShadowingCertificate`, `mkShadowingCertificate`, and `pseudo_orbit_perturbation` from this cycle.\n\n**Ambition**: extension\n\n---\n\n### Direction 4: Shadowing and Structural Stability\n\n**Conjecture**: A C\u00b9 diffeomorphism f on a compact manifold has the uniform shadowing property if and only if it is structurally stable (i.e., every C\u00b9-nearby diffeomorphism is topologically conjugate to f). This is equivalent to the Axiom A + no-cycle condition by Ma\u00f1\u00e9's theorem. In the formal setting: prove that `HasUniformShadowingProperty f` implies that f satisfies a formal version of structural stability.\n\n**Test**: Prove one direction: that structurally stable maps (defined as maps where small perturbations preserve topological conjugacy) have the uniform shadowing property. The converse (Pilyugin\u2013Tikhomirov) is much harder and may be out of reach.\n\n**Impact**: Would establish a deep connection between the computational property (shadowing) and the topological property (structural stability), showing they are two faces of the same coin.\n\n**Catalog References**: `Physics/ShadowingLemma.lean`, `Bridges/HolographicProofRenormalization.lean`\n\n**Proof Strategy**:\n1. Define structural stability formally: f is structurally stable if there exists \u03b5 > 0 such that every g with d_C1(f, g) < \u03b5 is topologically conjugate to f.\n2. Use the perturbation theorem (`pseudo_orbit_perturbation`) to show that pseudo-orbits of f correspond to true orbits of nearby maps.\n3. Show that topological conjugacy + perturbation stability implies shadowing.\n\n**Domain Bridges**: Dynamical Systems \u2194 Topology \u2194 Mathematical Physics (stability of physical systems)\n\n**Lineage**: Builds on `HasUniformShadowingProperty`, `pseudo_orbit_perturbation`, and `contractive_has_uniform_shadowing` from this cycle.\n\n**Ambition**: grand_challenge\n\n---\n\n### Direction 5: Shadowing Exponents and the Logistic Map\n\n**Conjecture**: For the logistic map f(x) = 4x(1-x), which is semi-conjugate to the tent map and has Lyapunov exponent ln(2), the shadowing distance for an N-step pseudo-orbit with tolerance \u03b4 grows as \u03b5(N,\u03b4) \u2264 C \u00b7 \u03b4^\u03b1 \u00b7 N^\u03b2 where \u03b1 = 1 and \u03b2 = 1 (linear growth), with C depending only on the Lyapunov exponent. More precisely, the shadowing amplification ratio satisfies lim_{N\u2192\u221e} (1/N) \u00b7 log(\u03b5_N/\u03b4) = \u03bb where \u03bb = ln(2) is the Lyapunov exponent.\n\n**Test**: Compute 10\u2076 iterations of the logistic map in floating-point for 1000 different initial conditions. For each, find the shadowing orbit using interval arithmetic and measure the shadowing distance growth rate. Compare the measured growth exponent with ln(2).\n\n**Impact**: Would establish a quantitative connection between Lyapunov exponents (the rate of divergence of nearby orbits) and shadowing exponents (the rate of growth of shadowing distance), two fundamental quantities in chaotic dynamics.\n\n**Catalog References**: `Physics/ShadowingLemma.lean`, `logistic_deriv_formula`\n\n**Proof Strategy**:\n1. Use the semi-conjugacy between the logistic map and the tent map: h(x) = (2/\u03c0)arcsin(\u221ax) conjugates f to T(x) = 1 - |2x - 1|.\n2. For the tent map, shadowing is much simpler because the map is piecewise linear.\n3. Transfer the shadowing bounds through the conjugacy, picking up distortion from h and h\u207b\u00b9.\n4. The Lyapunov exponent ln(2) enters through the expansion rate of the tent map.\n\n**Domain Bridges**: Dynamical Systems \u2194 Ergodic Theory \u2194 Information Theory (Lyapunov exponents as information rates)\n\n**Lineage**: Builds on `logisticMap`, `logistic_deriv_formula`, and `shadowing_amplification` from this cycle.\n\n**Ambition**: extension\n",
    "domains": [
      "Computation",
      "Algebra"
    ],
    "priority_score": 0.75,
    "status": "in_progress",
    "research_mode": "team",
    "source_exp_id": "26193fdd",
    "consumed_by_exp_id": "f037c01f",
    "timestamp": "2026-06-01T17:10:58.326227+00:00"
  },
  {
    "id": "fd_0031",
    "title": "Hilbert's Hotel for Primes: An Infinite Hotel Where Every Guest Is Prime",
    "description": "Hilbert's Hotel has infinitely many rooms, each containing a prime number. Room n contains the n-th prime p_n. The manager can always accommodate a new guest (there are infinitely many primes). But what if the guests want to REARRANGE? Conjecture: For any permutation sigma of N, there exists a rearrangement of the primes q_1, q_2, ... such that the sequence of ratios q_n / p_n converges to 1. In other words, you can shuffle the primes almost arbitrarily and the room numbers barely change. More precisely, the set of permutations sigma for which p_{sigma(n)} / p_n has a limit is dense in the symmetric group (with the topology of pointwise convergence). But NOT every permutation works: the permutation that swaps all even-indexed primes with odd-indexed ones gives q_{2n}/p_{2n} = p_{2n-1}/p_{2n} which converges to 1 by the prime number theorem, but the permutation that reverses order gives q_n/p_n = p_{N-n}/p_n which diverges. Test: compute q_n/p_n for 10 random permutations of the first 10^6 primes and verify that most ratios converge to 1. Find the exact density of 'well-behaved' permutations. Impact: the primes are robust under rearrangement \u2014 their asymptotic density is a topological invariant of the permutation group.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.74,
    "status": "in_progress",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "77da1fcc",
    "timestamp": "2026-06-01T12:30:30.528114+00:00"
  },
  {
    "id": "fd_0066",
    "title": "The Thermodynamics of Sorting: Entropy and Computational Work",
    "description": "Sorting a list of n elements reduces the entropy from log(n!) bits to 0 bits, doing thermodynamic work W = kT * log(n!) in the process. But this is only true if sorting is irreversible \u2014 if the sorted list uniquely determines the input, then sorting is reversible and does no thermodynamic work. The key insight: comparison-based sorting makes irreversible comparisons (you learn a < b but discard the possibility a > b), and each comparison reduces entropy by at most 1 bit. So n*log(n) comparisons reduce entropy by at most n*log(n) bits, which matches log(n!) ~ n*log(n) bits. Conjecture: the minimum thermodynamic work of sorting n elements is W_min = kT * log(n!), and this work is achieved by optimal comparison-based sorting algorithms (merge sort, heapsort). Sub-optimal algorithms (bubble sort: n^2 comparisons) do more thermodynamic work than necessary: W_bubble = kT * n^2, wasting kT * (n^2 - n*log(n)) bits of entropy reduction. Conjecture: any sorting algorithm that makes C(n) comparisons does thermodynamic work proportional to C(n) * kT, and the optimal work is W_min = kT * n*log(n) (Stirling's approximation). Test: simulate sorting algorithms with entropy bookkeeping, verify W = kT * log(n!) for merge sort and W = kT * n^2 for bubble sort. Impact: sorting is a thermodynamic process. The n*log(n) lower bound is a consequence of the second law of thermodynamics.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.74,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.662659+00:00"
  },
  {
    "id": "fd_0084",
    "title": "Diophantine Approximation on Neural Networks: How Well Can ReLU Approximate Pi?",
    "description": "A ReLU network f: R -> R with L layers of width w is a piecewise linear function with at most w^L pieces. By the universal approximation theorem, such networks can approximate any continuous function. But HOW WELL can they approximate specific constants? Conjecture: a ReLU network with L layers of width w can approximate pi to within epsilon using O(w * L * log(1/epsilon)) parameters. More precisely, there exists a ReLU network f with L = O(log(log(1/epsilon))) layers and w = O(log(1/epsilon)) width such that |f(1) - pi| < epsilon. This is because pi can be computed by the Leibniz formula pi/4 = 1 - 1/3 + 1/5 - ..., and a ReLU network can implement the partial sums. The number of terms needed is O(1/epsilon), and each term can be computed by a constant-depth ReLU subnetwork. The depth needed is O(log(1/epsilon)) for the sum and O(log(log(1/epsilon))) for the individual terms. Conjecture: the approximation rate for rational numbers by ReLU networks is O(1/(w^L)), matching the piecewise linear structure. For irrational numbers like pi, the rate is O(1/(w * L * 2^L)), which is slower but still exponential in depth. Test: construct ReLU networks that approximate pi, e, and sqrt(2) and measure the approximation error as a function of network size. Impact: ReLU networks approximate constants at a rate determined by their depth and width. Pi requires O(log(log(1/epsilon))) depth.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.74,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.755927+00:00"
  },
  {
    "id": "fd_0007",
    "title": "The Anti-Fibonacci Sequence: Numbers That Avoid the Golden Ratio at All Costs",
    "description": "The Fibonacci sequence is defined by F(n+1) = F(n) + F(n-1) and converges to the golden ratio. Define the ANTI-Fibonacci sequence: A(n+1) is the smallest positive integer that is NOT equal to A(n) + A(n-1). The sequence begins 1, 1, 2, 4, 7, 11, 16, ... (each term avoids being the sum of the two previous terms). Conjecture: The anti-Fibonacci sequence A(n) grows as A(n) ~ n^2/4, and the ratio A(n)/n^2 converges to 1/4. More precisely, A(n) = floor(n^2/4) + O(1). The sequence avoids the golden ratio entirely \u2014 the ratio A(n+1)/A(n) does NOT converge, instead oscillating between 1 and 2. The complement of the anti-Fibonacci sequence (numbers that ARE sums of two previous anti-Fibonacci numbers) has density 0. Test: compute A(n) for n up to 10^6 and verify A(n)/n^2 approaches 1/4. Prove A(n) = floor(n^2/4) + O(1) by induction. Impact: a beautiful counterpoint to the Fibonacci sequence \u2014 instead of converging to a constant, it grows quadratically while systematically avoiding addition.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.73,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.492042+00:00"
  },
  {
    "id": "fd_0044",
    "title": "Erdos-Renyi on Acid: Random Graphs That Hallucinate",
    "description": "The Erdos-Renyi random graph G(n, p) has n vertices where each edge appears independently with probability p. At p = log(n)/n, G(n,p) becomes connected. But what if p is COMPLEX? Define G(n, z) where z is a complex number: each edge (i,j) appears with 'probability' z, meaning the edge weight is z instead of 0 or 1. The resulting 'complex graph' is a weighted complete graph where edge (i,j) has weight z if the edge exists and 0 otherwise. The adjacency matrix A_z has entries that are either z or 0. Conjecture: The complex eigenvalues of A_z trace out a circle of radius |z|*sqrt(n) in the complex plane, centered at the origin. As n -> infinity, the empirical spectral distribution of A_z converges to the circular law (like the Ginibre ensemble) because A_z is a random matrix with i.i.d. entries of mean z*p and variance |z|^2*p*(1-p). The 'hallucination' is that for Im(z) != 0, the graph has complex-valued connectivity \u2014 information flows with both amplitude and phase, and the phase creates interference patterns that are visible in the spectral density. Test: generate A_z for n = 1000 with z = 0.5 + 0.3i, compute eigenvalues, and verify they lie in a disk of radius sqrt(n)*|z|. Compare with the Ginibre ensemble prediction. Impact: complex-valued random graphs have circular spectra \u2014 the hallucination of complex probabilities creates beautiful circular eigenvalue distributions.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.73,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.567597+00:00"
  },
  {
    "id": "fd_0090",
    "title": "The Uncanny Valley of Mathematics: When Proofs Are Almost Right",
    "description": "The 'uncanny valley' in robotics states that as a robot becomes more human-like, acceptance increases until it looks almost human, then drops sharply before recovering. Conjecture: the same phenomenon exists in mathematics. As a proof becomes more rigorous, acceptance increases until it is 'almost rigorous' (a proof that is correct in spirit but has small gaps), then drops sharply (because mathematicians are suspicious of proofs that look correct but might have subtle errors), before recovering for fully rigorous proofs. The 'mathematical uncanny valley' function U(r) where r in [0,1] is the rigor level: U(0) = high (informal intuition is accepted), U(0.8) = low (almost rigorous but with gaps \u2014 very suspicious), U(1.0) = high (fully rigorous proof, formally verified). Conjecture: U(r) has a unique minimum at r = 1 - epsilon where epsilon is the 'gap size' that triggers the most suspicion. For Lean 4 proofs: U(1) = 1 (compiles), U(0.99) = 0.1 (almost compiles but has a 'sorry'), U(0.5) = 0.5 (sketch proof, accepted as intuition). Test: survey 100 mathematicians on their confidence in proofs at varying rigor levels and fit the uncanny valley curve. Impact: almost-right proofs are less trusted than informal intuitions. Formal verification escapes the uncanny valley.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.73,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.795915+00:00"
  },
  {
    "id": "fd_0014",
    "title": "The Sound of Pi: Musical Structure in Transcendental Constants",
    "description": "Every real number defines a musical scale: map the digits 0-9 to frequencies f_n = 220 * 2^{n/12} (the A minor pentatonic scale extended). The number pi = 3.14159265... produces the sequence E4, C5, C#5, D5, D#5, F5, E5, A4, G5, C5... \u2014 a melody. Conjecture: The melody of pi is not periodic (because pi is irrational) but has musical structure: the autocorrelation of the digit sequence at lag 12 (one octave) is positive and statistically significant. This means pi has more octave-related notes than expected by chance \u2014 pi 'favors' notes separated by octaves. Similarly, e 'favors' perfect fifths (lag 7) and sqrt(2) 'favors' minor thirds (lag 3). The musical structure of transcendental numbers reflects their continued fraction properties: numbers with bounded partial quotients have more consonant melodies. Test: compute the digit autocorrelation of pi, e, and sqrt(2) at lags 0-12 (representing unison through octave). Perform a chi-squared test comparing to the uniform distribution. Generate the 'music' of each constant and analyze for tonal centers. Impact: transcendental numbers have musical souls \u2014 their digit sequences contain hidden harmonies that reflect their deepest arithmetic properties.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.72,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.497427+00:00"
  },
  {
    "id": "fd_0051",
    "title": "Bayesian Werewolf: Optimal Strategy for Social Deduction Games",
    "description": "In the game Werewolf (Mafia), n players include k werewolves and n-k villagers. Each night, the werewolves eliminate one villager. Each day, the villagers vote to eliminate one player (possibly a werewolf). The villagers win if all werewolves are eliminated; the werewolves win if they equal or outnumber villagers. Conjecture: The optimal Bayesian strategy for villagers is to vote for the player with the highest posterior probability of being a werewolf, where the prior is k/n and the likelihood updates are based on the player's voting pattern and survival. More precisely, define the werewolf posterior P(W_i | evidence) using Bayes' theorem: P(W_i) = k/n (prior), P(evidence | W_i) = product of conditional probabilities of observed events given that player i is a werewolf. The optimal strategy maximizes P(villagers win) = P(correct elimination at each day round). For n=7, k=2: the villagers' win probability with optimal Bayesian play is approximately 0.36 (known from game theory). Conjecture: For general n and k, the villagers' win probability is approximately C * (1 - k/(n-k))^2 where C is a constant depending on the information structure. Test: simulate 10^6 games with n=7 to n=20 players and Bayesian villagers, measure the win probability, and fit to the conjectured formula. Impact: social deduction has an optimal Bayesian strategy, and the werewolves' advantage scales as (k/(n-k))^2.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.72,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.593085+00:00"
  },
  {
    "id": "fd_0059",
    "title": "The Category Theory of Jokes: Universal Properties of Humor",
    "description": "Category theory studies objects and morphisms between them. A joke has a setup (an object) and a punchline (a morphism that subverts expectations). Define the category Joke where objects are setups and morphisms are punchlines. A joke J: S -> P is a morphism from setup S to punchline P that factors through an unexpected category. The humor of a joke is measured by its 'surprise': the distance between the expected punchline (the limit of the setup category) and the actual punchline. Conjecture: The funniest jokes are those where the setup category has a colimit that is far from the limit. Formally, if S is a setup with expected resolution lim(S) and the actual punchline P is a colimit colim(S'), then the humor H(J) = d(lim(S), colim(S')), where d is a metric on the category of punchlines. Puns have H close to 0 (the punchline is near the expected resolution). Absurdist humor has H large (the punchline is in a completely different category). The universal property of jokes: a joke J is universal if for any other joke J' with the same setup, there is a unique natural transformation J => J'. The funniest jokes are universal \u2014 they are the terminal objects in the category of jokes with a given setup. Test: formalize 100 jokes as category-theoretic objects and compute H(J) for each. Correlate with human funniness ratings. Impact: humor is a colimit. The funnier the joke, the further the punchline is from the expected limit of the setup.",
    "domains": [
      "Novelty",
      "Logic"
    ],
    "priority_score": 0.72,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.626049+00:00"
  },
  {
    "id": "fd_0035",
    "title": "The P vs NP of Cooking: Computational Complexity of Recipes",
    "description": "Every recipe is an algorithm: it takes ingredients (inputs) and produces a dish (output). The question is: can you verify a good dish faster than you can cook it? This is exactly P vs NP, but in the kitchen. Define the verification time V(R) of a recipe R as the time it takes to taste the dish and determine if it's good. Define the cooking time C(R) as the time it takes to prepare the dish. Conjecture: For most traditional recipes, C(R) > V(R) \u2014 cooking takes longer than tasting (P != NP in the kitchen). But there exist 'quick recipes' where C(R) = V(R) \u2014 assemble-and-serve dishes like salads (P = NP in the kitchen). The interesting class is 'NP-hard recipes' \u2014 dishes where even VERifying the result is hard. Example: is the souffle risen? You can only verify by cutting it open, which destroys it. Theorem: souffle verification is co-NP-hard because determining if a souffle will rise requires simulating the thermodynamic process, which is PSPACE-hard. More formally: the souffle function S(ingredients, temperature, time) -> {risen, collapsed} requires computing the Navier-Stokes equations for the batter, which is PSPACE-hard. Test: classify 100 recipes by their C(R)/V(R) ratio. Verify that P = NP recipes have C = V, while P != NP recipes have C >> V. Impact: computational complexity is not abstract \u2014 it shows up in your kitchen. Some dishes are inherently harder to make than to verify.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.71,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.539249+00:00"
  },
  {
    "id": "fd_0077",
    "title": "The Ramsey Theory of DNA: Subsequence Avoidance in Genetic Codes",
    "description": "Ramsey's theorem states that any 2-coloring of the edges of K_6 contains a monochromatic K_3 (a triangle of one color). Applied to DNA: any sequence of 4^6 + 1 = 4097 nucleotides must contain a repeated 6-mer (by pigeonhole). But Ramsey theory for subsequences is more subtle: what is the minimum length L(k) of a DNA sequence over {A, C, G, T} such that every subsequence of length k contains a repeated 4-mer? Conjecture: L(k) = Theta(k * 4^4 * log(4^4)) = Theta(k * 256 * 8) = Theta(k * 2048). More precisely, by the Lovasz local lemma, L(k) >= 4^{4k/5} for sequences that avoid repeated k-mers in all subsequences. Conjecture: for real genomes, the actual L(k) is much smaller because real DNA has low complexity regions (microsatellites, Alu repeats) that create forced repeats. Specifically, the human genome has L(4) ~ 1000 (any 1000 consecutive bases contain a repeated 4-mer in some subsequence), while the random genome has L(4) ~ 4^4 * log(4^4) ~ 5000. Test: compute L(k) for real genomes vs random genomes and verify the factor-of-5 compression. Impact: DNA avoids subsequential repeats in a way that Ramsey theory predicts, but real genomes are 5x more 'forced' than random sequences.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.71,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.717074+00:00"
  },
  {
    "id": "fd_0040",
    "title": "Ramanujan's Taxicab Number as a Sum of Three Cubes: 1729 Revisited",
    "description": "1729 = 10^3 + 9^3 = 12^3 + 1^3 is the smallest number expressible as a sum of two cubes in two ways (Ramanujan's taxicab number). But can 1729 be expressed as a sum of three cubes? That is, does 1729 = x^3 + y^3 + z^3 have integer solutions? Conjecture: 1729 = 1^3 + 10^3 + 8^3 = 1 + 1000 + 512 = 1513 (no). 1729 = 9^3 + 9^3 + 7^3 = 729 + 729 + 343 = 1801 (no). Actually, 1729 = 1^3 + 12^3 = 1728 + 1 = 1729 (the original). And 1729 = 10^3 + 9^3 = 1000 + 729 = 1729. So 1729 has TWO representations as a sum of two cubes. The question is: does 1729 have a representation as a sum of three cubes? The answer is YES: 1729 = 1^3 + (-12)^3 + 12^3 = 1 - 1728 + 1728 = 1 = NO, this gives 1, not 1729. Try 1729 = 10^3 + 9^3 + 0^3 = 1729. So 1729 = 10^3 + 9^3 + 0^3 is a trivial representation. The non-trivial question: does 1729 have a representation as x^3 + y^3 + z^3 with x,y,z all nonzero? Conjecture: 1729 has no non-trivial representation as a sum of three cubes with all terms nonzero. Test: brute-force search for x^3 + y^3 + z^3 = 1729 with x,y,z nonzero integers. Impact: even Ramanujan's favorite number has secrets \u2014 the taxicab number's relationship to sums of three cubes reveals new Diophantine structure.",
    "domains": [
      "Novelty",
      "NumberTheory"
    ],
    "priority_score": 0.7,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.554513+00:00"
  },
  {
    "id": "fd_0045",
    "title": "The Fermi Paradox as a Pigeonhole Principle: Why We Are Alone",
    "description": "The Fermi paradox asks: if intelligent life is common, where is everyone? The pigeonhole principle answers: if there are more pigeons than holes, at least one hole contains more than one pigeon. Apply this to the cosmos: there are approximately 10^22 stars in the observable universe (pigeons) and approximately 10^10 habitable-zone planets (holes). By the pigeonhole principle, at least one habitable planet contains at least 10^12 stars' worth of interest... wait, that's the wrong way around. Correct: there are ~10^10 habitable planets (pigeons) and ~4.5 billion years of time (holes). By the pigeonhole principle, at least one time period of one year contains at least 2 habitable planets developing intelligence. But we observe zero contacts. Conjecture: The resolution is that intelligent life is NOT common \u2014 the expected number of technological civilizations in the observable universe is less than 1. More precisely: if we model the Drake equation with honest probability estimates, P(technological civilization per habitable planet) < 10^{-10}, making the expected number of civilizations < 10^0 = 1. The Fermi paradox is not a paradox at all \u2014 it is the pigeonhole principle correctly predicting that with very few pigeons (civilizations) and very many holes (planets + time), most holes are empty. Test: compute the Drake equation with conservative estimates and verify that E[civilizations] < 1. Impact: we are alone because probability says so. The universe is mostly empty because that's what the math predicts.",
    "domains": [
      "Novelty",
      "Computation"
    ],
    "priority_score": 0.65,
    "status": "available",
    "research_mode": "team",
    "source_exp_id": "seed",
    "consumed_by_exp_id": "",
    "timestamp": "2026-06-01T12:30:30.571054+00:00"
  }
];
