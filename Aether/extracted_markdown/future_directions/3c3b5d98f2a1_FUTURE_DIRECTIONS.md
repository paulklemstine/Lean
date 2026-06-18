# Future Directions: Agreement Geometry of Low-Degree Functions

This document outlines breakthrough-level research opportunities opened by the formalized agreement geometry framework established in this project.

---

## 1. Multivariate Schwartz–Zippel on Cartesian Grids

**Theorem Target:** For a nonzero multivariate polynomial $p \in K[x_1, \ldots, x_n]$ of total degree at most $d$ and a finite set $S \subseteq K$:
$$|\{x \in S^n : p(x) = 0\}| \leq d \cdot |S|^{n-1}.$$

**Why it is hard:** The univariate root bound (our `card_roots_filter_le_natDegree`) is the base case. The multivariate extension requires induction on dimension with careful treatment of the leading coefficient's zero set. Formalizing this in Lean requires handling `MvPolynomial (Fin n) K`, its evaluation, and a well-founded induction on the number of variables.

**What infrastructure from this cycle enables it:** Our `card_roots_filter_le_natDegree` provides the base case. The agreement set definitions (`agreeSetPoly`) and the overlap-bounding machinery (`card_eval_eq_filter_le`) provide templates for the multivariate generalization. The Bonferroni list-decoding bound (`univariate_list_bound_bonferroni`) would generalize to give multivariate list-decoding bounds once the multivariate root bound is established.

**Cross-domain impact:** Schwartz–Zippel is foundational for probabilistic polynomial identity testing in computational complexity, and for bounding error probabilities in interactive proof systems.

---

## 2. Certified List-Decoding Radius for Reed–Solomon Codes

**Theorem Target:** Define the Reed–Solomon evaluation code $\mathcal{C}_d(S) = \{(\text{eval}_s(p))_{s \in S} : \deg p \leq d\}$. Prove that its minimum Hamming distance is $|S| - d$, and that the list size for decoding at agreement radius $t$ satisfies:

- **Johnson bound:** If $t > \sqrt{|S| \cdot d}$, then $L \leq |S| / (t - \sqrt{|S| \cdot d})$.
- **Guruswami–Sudan bound:** If $t > \sqrt{|S| \cdot d}$, then $L \leq |S|^2$.

**Why it is hard:** The Johnson bound requires a non-trivial application of the Cauchy–Schwarz inequality to the multiplicity function, beyond the Bonferroni bound we proved. The Guruswami–Sudan bound requires formalizing bivariate polynomial interpolation and factorization. Both require significant algebraic infrastructure beyond what Mathlib currently provides for coding theory.

**What infrastructure from this cycle enables it:** Our `pairwise_disjoint_family_card_bound` gives the combinatorial engine. The agreement set overlap bound (`agreeSet_inter_card_le`) directly gives the pairwise distance bound. The Bonferroni list bound (`univariate_list_bound_bonferroni`) is the first step; the Johnson bound is the next natural strengthening.

**Cross-domain impact:** Certified list decoding is directly applicable to error-correcting codes in communication systems and to constructions of pseudorandom objects in complexity theory.

---

## 3. Boolean Low-Degree Agreement Rigidity

**Theorem Target:** For multilinear polynomials $p : \{0,1\}^n \to \mathbb{F}_2$ of degree at most $d$, and a target function $f : \{0,1\}^n \to \mathbb{F}_2$:

If $L$ distinct multilinear polynomials of degree $\leq d$ each agree with $f$ on at least $t$ of the $2^n$ inputs, then $L$ satisfies a bound of the form:
$$L \leq \binom{n}{\leq d} \cdot \frac{2^n}{t}.$$

**Why it is hard:** Over $\mathbb{F}_2$, every polynomial is multilinear, so degree bounds behave differently. The zero set of a nonzero multilinear polynomial of degree $d$ has size exactly $2^{n-1}$ (by the Schwartz–Zippel specialization), not $d \cdot 2^{n-1}$ as in the general case. The agreement structure is richer because the polynomial space has dimension $\binom{n}{\leq d}$. Formalizing multilinear polynomials and their evaluation on Boolean cubes requires specialized Lean definitions.

**What infrastructure from this cycle enables it:** The agreement set definitions and the Bonferroni counting framework transfer directly. The pairwise overlap bound becomes: for distinct multilinear $p, q$, their agreement set has size exactly $2^{n-1}$ (since $p - q$ is nonzero multilinear). The covering bound then gives $L \cdot (t - 2^{n-1}) \leq 2^n$ when $t > 2^{n-1}$, which is the Boolean analogue of our main theorem.

**Cross-domain impact:** Boolean agreement rigidity connects to property testing (the BLR linearity test), learning theory (Fourier analysis of Boolean functions), and circuit complexity (correlation bounds for small circuits against parity).

---

## 4. Tropical Agreement Geometry

**Theorem Target:** Define tropical polynomials as $p(x) = \max_{i}(a_i + i \cdot x)$ for $a_i \in \mathbb{R} \cup \{-\infty\}$, and tropical agreement sets as $A(p, f) = \{x \in S : p(x) = f(x)\}$. Prove that for distinct tropical polynomials of "degree" $\leq d$:
$$|A(p, f) \cap A(q, f)| \leq d$$
where the bound comes from the number of "breakpoints" of $p - q$ (the tropical analogue of roots).

**Why it is hard:** Tropical geometry replaces field operations with $(\max, +)$, which breaks ring-theoretic arguments. The "root bound" for tropical polynomials is different: a tropical polynomial of degree $d$ has at most $d$ breakpoints, but the structure of agreement sets is non-algebraic. Formalizing tropical polynomials in Lean requires entirely new definitions, and the Lean/Mathlib support for tropical semirings is nascent.

**What infrastructure from this cycle enables it:** The combinatorial covering framework (`pairwise_disjoint_family_card_bound`, `univariate_list_bound_bonferroni`) is purely combinatorial and transfers verbatim to tropical settings once the overlap bound is established. The proof architecture—separate the algebraic overlap bound from the combinatorial counting—is the key design pattern.

**Cross-domain impact:** Tropical geometry has applications in optimization (linear programming duality), phylogenetics (tree reconstruction), and algebraic geometry (limits of algebraic varieties). Tropical agreement geometry would be genuinely novel.

---

## 5. Rank/Interpolation Strengthening via Vandermonde Determinants

**Theorem Target:** Improve the Bonferroni bound $2Lt \leq 2|S| + L(L-1)d$ to an exponent-sensitive bound:
$$L \leq \binom{|S|}{d+1}^{1/(d+1)}$$
or similar, using the rank of the Vandermonde-type evaluation matrix.

**Why it is hard:** The argument requires showing that the evaluation vectors of $L$ distinct degree-$\leq d$ polynomials on $S$ are linearly independent when $L \leq d + 1$ (by Vandermonde non-singularity), and then using this to derive tighter list-size bounds. Formalizing Vandermonde determinants and their non-vanishing requires substantial linear algebra infrastructure.

**What infrastructure from this cycle enables it:** The polynomial evaluation framework (`Polynomial.eval`) and the agreement set definitions provide the starting point. The key new ingredient is the connection between polynomial evaluation and linear algebra, which our current framework sets up but does not exploit. The pairwise overlap bound (`card_eval_eq_filter_le`) is the "zeroth-order" version; the rank argument gives the "first-order" version.

**Cross-domain impact:** Vandermonde-based arguments are central to interpolation theory, signal processing (DFT/FFT), and cryptographic constructions (secret sharing, polynomial commitments). Formalizing the rank argument would create reusable infrastructure for all these domains.
