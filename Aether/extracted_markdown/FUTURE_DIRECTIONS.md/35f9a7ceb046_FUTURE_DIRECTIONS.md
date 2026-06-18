# Future Directions: Adelic Persistent Homology

## Synthesis

The Adelic Structure Theorem established in this work — showing that torsion in persistence filtrations decomposes into independent p-primary channels — opens a systematic bridge between topological data analysis and arithmetic geometry. The five directions below form a coherent research program: H1 and H2 extend the core theory with refined structural and metric results; H3 formulates a local-global principle that would make the adelic analogy precise; H4 connects to probabilistic topology via random models; and H5 reaches toward the Langlands program by attaching L-functions to persistence modules. Together, they aim to establish *arithmetic persistent homology* as a new subdiscipline spanning algebraic topology, number theory, and data science.

---

## Direction 1: Adelic Barcode Determines Group Structure

**Conjecture:** The adelic barcode of a filtered Z/nZ-module determines n up to a square factor. More precisely, if two filtrations of Z/nZ and Z/mZ have identical adelic barcodes (same primes, same birth-death intervals at each prime), then rad(n) = rad(m), where rad denotes the radical (product of distinct prime factors).

**Test:** Enumerate all cyclic groups Z/nZ for n ≤ 500. For each pair (n, m), compute the adelic barcodes of the trivial filtration (identity maps). Check whether identical barcodes imply rad(n) = rad(m). A pair with identical barcodes but different radicals falsifies the conjecture.

**Impact:** If true, this establishes the adelic barcode as a *complete invariant* up to square factors, making it as powerful as the radical for detecting arithmetic structure.

**Catalog References:** `Pythagorean/AdelicPersistentHomology.lean` — `adelic_structure_theorem`, `torsionPrime_dvd_card`, `prime_count_le_log2`.

**Proof Strategy:** Use the CRT decomposition to show that the adelic barcode determines the set of primes dividing n. Then use the p-primary order bound (`pPrimary_order_bound`) to recover the p-adic valuation up to a factor related to the filtration depth. The "up to square factor" relaxation is needed because the barcode doesn't distinguish Z/4Z from Z/2Z ⊕ Z/2Z.

**Domain Bridges:** Number theory (radical of an integer) ↔ Persistent homology (barcode).

**Lineage:** Extends `adelic_structure_theorem` and `torsionPrime_dvd_card`.

**Ambition:** solid_extension

---

## Direction 2: Adelic Interleaving Triangle Inequality

**Conjecture:** Define the adelic interleaving distance d_A(F, F') = sup_p d_p(F, F') where d_p is the interleaving distance of the p-primary persistence modules. Then d_A satisfies a triangle inequality with an error term: d_A(F, F'') ≤ d_A(F, F') + d_A(F', F'') + O(log T), where T = max_i max(|G_i|, |G'_i|, |G''_i|).

**Test:** For all filtrations of groups of order ≤ 50 and length ≤ 4, compute the three pairwise adelic interleaving distances and verify the triangle inequality holds with the log T correction. Determine the optimal constant in the O(log T) term.

**Impact:** A metric structure on the space of adelic barcodes would enable adelic stability theorems — the foundation for using adelic barcodes in applications where data is noisy.

**Catalog References:** `Pythagorean/AdelicPersistentHomology.lean` — `pPrimary_subgroups_disjoint`, `coprime_annihilation_zero`.

**Proof Strategy:** The key difficulty is that the interleaving distance is defined via morphisms between persistence modules, and the p-primary restriction changes the module structure. Use the disjointness of p-primary subgroups to bound the cross-prime interference. The log T error term arises from the prime count bound ω(T) ≤ log₂ T.

**Domain Bridges:** Metric geometry ↔ Number theory (prime counting) ↔ TDA (stability).

**Lineage:** Extends `pPrimary_subgroups_disjoint` and the classical stability theorem.

**Ambition:** solid_extension

---

## Direction 3: Local-Global Principle for Persistence Modules

**Conjecture:** A collection {M_p}_p of p-adic persistence modules (one for each prime p, with M_p trivial for all but finitely many p) arises from a global persistence module M over Z if and only if:
(a) The modules are "compatible at infinity": for each level i, the rank of M_p(i) is bounded independently of p.
(b) The total torsion is consistent: Σ_p dim_{F_p}(M_p(i)/pM_p(i)) < ∞ for each i.

**Test:** Construct explicit collections {M_p} satisfying (a)-(b) for small parameters (n ≤ 5, groups of order ≤ 30). Verify that each arises from a global module by explicit construction. Then construct a collection violating (a) or (b) and verify it does not arise globally.

**Impact:** A local-global principle for persistence modules would be a direct analogue of the Hasse-Minkowski theorem in number theory, establishing that adelic persistence modules are precisely the "global" objects.

**Catalog References:** `Pythagorean/AdelicPersistentHomology.lean` — `AdelicTorsionData`, `adelic_structure_theorem`.

**Proof Strategy:** For the "global → local" direction, apply the p-primary decomposition (Theorem 3.7). For "local → global," use the CRT to reconstruct the global module from its p-primary components. The key subtlety is ensuring the persistence maps are compatible across primes, which requires the coprime annihilation lemma.

**Domain Bridges:** Number theory (Hasse-Minkowski) ↔ Algebraic topology (persistence modules) ↔ Adelic geometry (restricted products).

**Lineage:** Extends `AdelicTorsionData` toward a complete characterization.

**Ambition:** grand_challenge

---

## Direction 4: Central Limit Theorem for Random Adelic Barcodes

**Conjecture:** For the adelic barcode of the homology of a random Erdős-Rényi simplicial complex on n vertices (with edge probability p = c/n for a constant c > 1), the number of bars at each prime p converges in distribution to a Poisson random variable with parameter λ_p(c) as n → ∞. The parameters satisfy Σ_p λ_p(c) = λ(c) where λ(c) is the expected total number of torsion bars.

**Test:** Generate 10,000 random Erdős-Rényi complexes on 20 vertices with p = 0.3. Compute the adelic barcode of each. For each prime p ≤ 19, fit the count of p-bars to a Poisson distribution and compute the Kolmogorov-Smirnov statistic. Verify that the KS test does not reject Poisson at the 5% level.

**Impact:** Would provide the first probabilistic model for torsion in random topology, enabling statistical inference on adelic barcodes.

**Catalog References:** `Pythagorean/AdelicPersistentHomology.lean` — `prime_count_le_log2`.

**Proof Strategy:** Use the Acyclic Closure Theorem for random complexes combined with the CRT decomposition. The Poisson limit should follow from the independence of p-primary components (Corollary 3.6) and the rare-event nature of torsion classes at each prime.

**Domain Bridges:** Probability theory (Poisson limits) ↔ Random topology ↔ Arithmetic (prime decomposition).

**Lineage:** Extends `crt_pPrimary_independent` to a probabilistic setting.

**Ambition:** grand_challenge

---

## Direction 5: Zeta Functions of Adelic Barcodes

**Conjecture:** For each prime p, define the *barcode zeta function* ζ_p(s) = Σ_{bars [b,d)} p^{-s(d-b)} associated to the p-adic barcode. Then:
(a) ζ_p(s) converges for Re(s) > 0.
(b) ζ_p has a meromorphic continuation to Re(s) > -1 with a simple pole at s = 0.
(c) The product L(s) = Π_p ζ_p(s) satisfies a functional equation L(s) = ε · L(1-s) for some root number ε ∈ {±1}.

**Test:** Compute ζ_p(s) for the adelic barcodes of all filtrations of Z/nZ with n ≤ 30 and n_levels ≤ 4. Numerically evaluate at s = 0.5 + it for t ∈ [0, 10]. Check whether the Euler product converges and whether the functional equation holds to within numerical precision (10^{-6}).

**Impact:** Would establish a connection between adelic barcodes and L-functions, the central objects of the Langlands program. Even a partial result (e.g., convergence of ζ_p) would be significant.

**Catalog References:** `Pythagorean/AdelicPersistentHomology.lean` — `pPrimary_order_bound`, `AdelicTorsionData`.

**Proof Strategy:** Convergence follows from the finiteness of the barcode. Meromorphic continuation requires understanding the asymptotics of bar lengths. The functional equation, if it exists, would follow from some duality in the persistence module (e.g., Poincaré duality for the underlying topological space).

**Domain Bridges:** Analytic number theory (L-functions, functional equations) ↔ TDA (barcodes) ↔ Representation theory (Langlands).

**Lineage:** Extends the entire adelic framework toward the Langlands vision.

**Ambition:** grand_challenge
