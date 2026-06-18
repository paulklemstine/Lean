# Future Directions: Nonlinear Σ-Protocol Extraction Theory

## Synthesis

The results in `Pythagorean/NonlinearSigmaExtraction.lean` establish that two-transcript extraction in Σ-protocols is governed by a single algebraic invariant: the polynomial observation map factors through the image of the response function $f$, and witness recovery is controlled by the fiber structure of $f$. This opens five interconnected research directions that collectively build toward a **polynomial theory of extraction** — a framework where transcript consistency defines algebraic varieties and extraction becomes an elimination problem.

The directions below form a coherent progression: Direction 1 formalizes the fiber law that governs extraction ambiguity; Direction 2 extends the theory to multivariate witnesses; Direction 3 connects extraction to computational algebra via Gröbner bases; Direction 4 develops the symmetry-theoretic perspective; and Direction 5 attacks the grand challenge of extraction complexity bounds for arbitrary polynomial protocols. Each direction builds on the formal infrastructure already established and introduces testable predictions that can be refuted by finite computation.

---

## Direction 1: Power-Map Fiber Law and Extraction Multiplicity

**Conjecture.** For $f(w) = w^d$ over $\mathbb{Z}/p\mathbb{Z}$ with $p$ prime and $y \neq 0$ in the image of $f$, the fiber $f^{-1}(y)$ has size exactly $\gcd(d, p-1)$. Consequently, two-transcript extraction for the $d$-th power response function has witness ambiguity exactly $\gcd(d, p-1)$.

**Test.** For each prime $p \in \{7, 11, 13, 17, 19, 23, 29, 31, 37, 41\}$ and degree $d \in \{2, 3, 4, 5, 6, 8, 10, 12\}$: enumerate all fibers of $w \mapsto w^d$ over $\mathbb{Z}/p\mathbb{Z}$; verify that every nonzero fiber has size $\gcd(d, p-1)$. A single prime-degree pair where any nonzero fiber has a different size refutes the conjecture. Computational testing in `demo.py` confirms the conjecture for all tested cases.

**Impact.** This would give protocol designers a closed-form formula for extraction ambiguity, enabling precise security loss bounds without exhaustive search. It would also connect Σ-protocol theory to the classical theory of power residues and multiplicative characters.

**Catalog References.** `Pythagorean/NonlinearSigmaExtraction.lean`: `two_transcript_eq_image_of_ne`, `zmod_square_noninjective_of_odd_prime`. `Catalog/Cryptography/AffineSigmaExtraction.lean`: `no_unique_extract_of_noninj`.

**Proof Strategy.** The key is that $(\mathbb{Z}/p\mathbb{Z})^\times$ is cyclic of order $p-1$. Let $g$ be a generator. Then $w^d = y$ iff $g^{dk} = y$ for some $k$, i.e., $dk \equiv \log_g y \pmod{p-1}$. This linear congruence has exactly $\gcd(d, p-1)$ solutions iff $\gcd(d, p-1) \mid \log_g y$, which holds for all $y$ in the image. The formalization requires `ZMod.IsCyclic` and `ZMod.primitiveRoot` from Mathlib.

**Domain Bridges.** Number theory (multiplicative characters), coding theory (Reed–Solomon decoding ambiguity), algebraic statistics (identifiability degree).

**Lineage.** Extends `zmod_square_noninjective_of_odd_prime` from $d=2$ to general $d$.

**Ambition.** Solid extension — well-known in number theory but novel in the formalized extraction context.

---

## Direction 2: Multivariate Witness Extraction

**Conjecture.** For $f : \mathbb{F}^n \to \mathbb{F}$ and the response equation $z = t + c \cdot f(\mathbf{w})$, two distinct challenges determine $f(\mathbf{w})$ (identical to the univariate case), and witness extraction reduces to injectivity of $f$ restricted to the witness domain. The observation map factors as $\Phi_{f,\mathbf{c}}(t, \mathbf{w}) = \Psi_{\mathbf{c}}(t, f(\mathbf{w}))$ where $\Psi$ is affine.

**Test.** For $f(\mathbf{w}) = w_1^2 + w_2^2$ over $\mathbb{Z}/p\mathbb{Z}$ with $p \in \{5, 7, 11, 13\}$: enumerate all pairs $(\mathbf{w}_1, \mathbf{w}_2) \in (\mathbb{Z}/p\mathbb{Z})^2 \times (\mathbb{Z}/p\mathbb{Z})^2$ producing equal transcript pairs; verify that all such pairs satisfy $f(\mathbf{w}_1) = f(\mathbf{w}_2)$. Test with quadratic forms of different ranks.

**Impact.** This would extend the entire polynomial extraction framework to the multivariate setting relevant to practical proof systems (R1CS, Plonk). The fiber structure of multivariate polynomial maps connects to algebraic geometry in earnest — level sets become algebraic varieties of dimension $n-1$.

**Catalog References.** `Pythagorean/NonlinearSigmaExtraction.lean`: `two_transcript_eq_image_of_ne`, `image_extractable_of_two_distinct_challenges`. `Catalog/Cryptography/AffineSigmaExtraction.lean`: `multi_dim_affine_extract`.

**Proof Strategy.** The factorization $\Phi = \Psi \circ (t, f)$ holds by construction; the challenge is formalizing vector-valued witnesses using `Fin n → F` and relating extraction to `MvPolynomial`-level fiber analysis. Start by proving the factorization for bilinear and quadratic forms.

**Domain Bridges.** Algebraic geometry (variety dimension), optimization (level set analysis), machine learning (latent variable identifiability in polynomial models).

**Lineage.** Generalizes the scalar theory in `NonlinearSigmaExtraction.lean` to vector witnesses.

**Ambition.** Grand challenge — requires new Lean infrastructure for multivariate polynomial extraction and connects to deep algebraic geometry.

---

## Direction 3: Gröbner-Based Extraction for Polynomial Protocols

**Conjecture.** For bounded-degree polynomial response functions $f : \mathbb{F}^n \to \mathbb{F}^m$ and $k$ transcripts with pairwise distinct challenges, the extraction problem reduces to computing an elimination ideal of the transcript equations. For $n \leq 3$ and $\deg f \leq 3$, this elimination is computationally feasible via Gröbner bases in degree-reverse-lexicographic order, and the resulting extractor runs in time polynomial in $p$.

**Test.** Implement Gröbner basis computation for transcript systems with $n = 2$, $f(\mathbf{w}) = (w_1 w_2, w_1^2 + w_2)$, $k = 3$ transcripts. Measure computation time for $p \in \{7, 11, 13, 17, 23, 29, 31\}$. Verify that the elimination ideal determines a finite number of witness candidates. Test whether computation time grows polynomially in $\log p$.

**Impact.** This would provide the first constructive extraction algorithms for genuinely nonlinear protocols, moving beyond the "recover image then enumerate fibers" approach to a systematic algebraic method.

**Catalog References.** `Pythagorean/NonlinearSigmaExtraction.lean`: `poly_transcript_consistent_iff_pairwise`, `extractImage_correct`.

**Proof Strategy.** Model transcript equations as elements of `MvPolynomial (Fin (n+1)) (ZMod p)` (variables are $t, w_1, \ldots, w_n$). Use Buchberger's algorithm to eliminate $t$, reducing to a system in the $w_i$ alone. Bound the degree of the elimination ideal using Bézout's theorem.

**Domain Bridges.** Computational algebra (Gröbner bases), algebraic geometry (elimination theory, resultants), complexity theory (polynomial system solving).

**Lineage.** Extends `extractImage_correct` from rational-formula extraction to algorithmic extraction via elimination.

**Ambition.** Grand challenge — connecting cryptographic extraction to computational algebraic geometry is a paradigm shift.

---

## Direction 4: Symmetry Groups and Extraction Orbits

**Conjecture.** For any polynomial $f : \mathbb{F} \to \mathbb{F}$ of degree $d$, the *extraction symmetry group* $G_f = \{\sigma \in \text{Aut}(\mathbb{F}) : f \circ \sigma = f\}$ has order dividing $d$, and two-transcript extraction recovers the witness up to the orbit of $G_f$. For $f(w) = w^d$, $G_f$ is the group of $\gcd(d, p-1)$-th roots of unity, acting by multiplication.

**Test.** For $f(w) = w^2 + w$ over $\mathbb{Z}/p\mathbb{Z}$: enumerate all $\sigma : \mathbb{Z}/p\mathbb{Z} \to \mathbb{Z}/p\mathbb{Z}$ with $f(\sigma(w)) = f(w)$ for all $w$. Verify $|G_f|$ divides $\deg f = 2$. Repeat for $f(w) = w^3 - w$, $f(w) = w^4 + w^2$. A counterexample where $|G_f| > \deg f$ refutes the conjecture.

**Impact.** This gives a group-theoretic classification of extraction obstructions, analogous to gauge symmetries in physics. It would predict extraction ambiguity from the algebraic structure of $f$ without computing fibers explicitly.

**Catalog References.** `Pythagorean/NonlinearSigmaExtraction.lean`: `two_transcript_eq_image_of_ne`, `zmod_square_noninjective_of_odd_prime`. The $w \mapsto -w$ symmetry for squares is the prototypical example.

**Proof Strategy.** Define $G_f$ as a subgroup of the symmetric group on $\mathbb{F}$. For $f(w) = w^d$, show $G_f = \mu_{\gcd(d,p-1)}$ (roots of unity) using the cyclic group structure. For general polynomials, bound $|G_f|$ by $\deg f$ using the fact that $f(w) = f(\sigma(w))$ means $\sigma(w)$ is a root of $f(x) - f(w)$, which has degree $\leq d$.

**Domain Bridges.** Group theory (automorphism groups), physics (gauge invariance), algebraic geometry (automorphisms of curves).

**Lineage.** Conceptualizes the $w \mapsto -w$ obstruction as part of a general symmetry framework.

**Ambition.** Solid extension with deep conceptual payoff — makes the "symmetry obstruction" principle precise and general.

---

## Direction 5: Lower Bounds on Transcript Complexity

**Conjecture.** For a polynomial response function $f$ of degree $d$ over $\mathbb{F}_p$, $k$ transcripts with pairwise distinct challenges determine the witness up to a set of size at most $d^{k-1}/k!$ (a Bézout-type bound). In particular, $k = d + 1$ transcripts suffice for unique extraction whenever $f$ is a polynomial map, even without injectivity of $f$.

**Test.** For $f(w) = w^3$ over $\mathbb{Z}/p\mathbb{Z}$ with $p \equiv 1 \pmod{3}$ (so $\gcd(3, p-1) = 3$): generate $k = 2, 3, 4$ transcripts with distinct challenges and a fixed witness $w$. For each $k$, enumerate all witnesses $w'$ consistent with all $k$ transcript equations. Measure the number of consistent witnesses as a function of $k$. Verify that 4 transcripts uniquely determine the witness.

**Impact.** This would establish the first formal *transcript complexity* theory for nonlinear proof systems: how many rounds of interaction are needed for extraction as a function of the algebraic degree. It would provide constructive alternatives to the current "2-special-soundness or nothing" paradigm.

**Catalog References.** `Pythagorean/NonlinearSigmaExtraction.lean`: `two_transcript_eq_image_of_ne` (the $k=2$ case), `image_extractable_of_two_distinct_challenges` (general challenge lists). `Catalog/Cryptography/AffineSigmaExtraction.lean`: `matrix_affine_extract` (the $d=1$ case where $k=2$ always suffices).

**Proof Strategy.** Each transcript equation $z_i = t + c_i f(w)$ restricts $(t, w)$ to a curve. After eliminating $t$ (using the pairwise-difference criterion), the remaining equations are $f(w)(c_i - c_j) = z_i - z_j$ for pairs $(i,j)$, which for polynomial $f$ of degree $d$ have at most $d$ solutions. Multiple independent equations from different challenge pairs reduce the solution set further.

**Domain Bridges.** Algebraic complexity theory (arithmetic circuits), information theory (sample complexity), combinatorics (intersection patterns of algebraic curves).

**Lineage.** Extends from the binary "extractable vs. not" classification to a quantitative transcript complexity measure.

**Ambition.** Grand challenge — establishing tight bounds on transcript complexity for polynomial protocols would be a major contribution to both theory and practice.
