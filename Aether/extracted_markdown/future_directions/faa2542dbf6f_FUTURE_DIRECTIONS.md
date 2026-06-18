# Future Directions: Certified Domain-Specific Proof Automation

## 1. Gershgorin Disc Theorem — Certified Spectral Enclosure

**Theorem Statement (target):**
```
theorem eigenvalue_mem_gershgorin
  {n : ℕ} (A : Matrix (Fin n) (Fin n) ℂ) (μ : ℂ) (hμ : IsEigenvalue A μ) :
  ∃ i : Fin n, Complex.abs (μ - A i i) ≤ ∑ j in Finset.univ.erase i, Complex.abs (A i j)
```

**Why it matters:** Gershgorin's circle theorem is the most widely used spectral enclosure result in numerical linear algebra, control theory, and quantum chemistry. A machine-verified version would provide the first *certified* spectral localization tool inside a proof assistant, enabling automated verification of stability bounds for dynamical systems, convergence guarantees for iterative solvers, and spectral gap certificates for Markov chains.

**Proof strategy:** Starting from the eigenvalue equation Av = μv, pick the index i where |v_i| is maximal. The i-th row gives μv_i = Σ_j A_ij v_j. Rearranging: (μ - A_ii)v_i = Σ_{j≠i} A_ij v_j. Taking absolute values and using |v_j/v_i| ≤ 1 gives the result. The key dependency is `matrix_mul_vec_entry_bound` from the current work, extended to complex matrices.

**Dependencies from current work:** `spectral_bound_sound`, `spectral_bound_vec`, `matrix_mul_vec_entry_bound`. The row-sum bounding infrastructure directly supports Gershgorin disc computation.

**Cross-domain connection:** Connects spectral graph theory (adjacency matrix bounds for expander graphs), quantum information (Hamiltonian spectral gaps), and control theory (stability regions for feedback systems).

---

## 2. Tropical Affine Envelope — Canonical Piecewise-Linear Normal Form

**Theorem Statement (target):**
```
def AffForm (n : ℕ) := (Fin n → ℕ) × ℕ  -- coefficients + constant

def evalAffForm (σ : Fin n → ℕ) (af : AffForm n) : ℕ :=
  (∑ i, af.1 i * σ i) + af.2

theorem TropExpr.exists_affine_nf {n : ℕ} :
  ∀ e : TropExpr (Fin n), ∃ nf : List (AffForm n),
    nf ≠ [] ∧ ∀ σ, TropExpr.eval σ e = nf.map (evalAffForm σ) |>.minimum
```

**Why it matters:** This theorem says every tropical expression has a canonical representation as the minimum of finitely many affine forms — the tropical analogue of converting a polynomial to its Newton polytope. This is the mathematical foundation for tropical convexity, tropical linear programming, and connections to neural network verification (ReLU networks compute piecewise-linear functions, which are exactly tropical rational expressions).

**Proof strategy:** Extend the current `toNF` normalization to collect variable multiplicities into a canonical `(Fin n → ℕ) × ℕ` form. The key step is showing that `evalMonomial` on a monomial consisting of variables and constants equals an affine evaluation. Then prove that sorting and deduplicating the affine forms yields a unique canonical representative.

**Dependencies from current work:** `TropExpr.toNF_sound`, `evalNF_bind_map`, `evalMonomial_append`. The min-of-sums infrastructure is the direct precursor to the min-of-affine-forms representation.

**Cross-domain connection:** Links to tropical geometry (tropical hypersurfaces as loci where the minimum is achieved by ≥2 terms), optimization (tropical linear programming), and machine learning (certified analysis of ReLU network expressivity).

---

## 3. Certified Bounded Diophantine Search with Witness Extraction

**Theorem Statement (target):**
```
inductive BoundedDioph where
  | dvd : ℕ → ℕ → BoundedDioph
  | eq : ℕ → ℕ → BoundedDioph
  | and : BoundedDioph → BoundedDioph → BoundedDioph
  | or : BoundedDioph → BoundedDioph → BoundedDioph
  | existsLe : ℕ → (ℕ → BoundedDioph) → BoundedDioph
  | forallLe : ℕ → (ℕ → BoundedDioph) → BoundedDioph

theorem BoundedDioph.decide_sound_complete (φ : BoundedDioph) :
  φ.check = true ↔ φ.toProp

theorem BoundedDioph.witness (φ : BoundedDioph) (h : φ.check = true) :
  φ.extractWitness = some w → φ.verifyWitness w = true
```

**Why it matters:** This creates a formal analogue of NP-witness checking: for any bounded arithmetic formula with quantifiers over finite ranges, we can compute a boolean answer and extract a certificate. This bridges computational complexity (P vs NP at finite scale), automated theorem proving (bounded model checking), and number theory (pseudoprime search, Goldbach verification up to bounds).

**Proof strategy:** Extend the current `DivPred` checker to handle bounded quantifiers via recursive enumeration. Soundness and completeness follow by structural induction. Witness extraction logs the choices made during existential search.

**Dependencies from current work:** `NatCheckDivisible_sound/complete`, `NatCheckExistsUpTo_sound/complete`, `DivPred.check_sound/complete`. The current checkers are the base cases; bounded quantifiers add the recursive structure.

**Cross-domain connection:** Connects to SAT solving (bounded model checking), cryptography (certified brute-force search for small keys), and combinatorics (finite obstruction proofs).

---

## 4. Operator Norm Submultiplicativity from Row-Sum Certificates

**Theorem Statement (target):**
```
theorem operator_norm_submultiplicative_rowsum
  {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ) (CA CB : ℝ)
  (hA : ∀ i, ∑ j, |A i j| ≤ CA) (hB : ∀ i, ∑ j, |B i j| ≤ CB) :
  ∀ i, ∑ j, |(A * B) i j| ≤ CA * CB
```

**Why it matters:** This shows that row-sum certificates compose multiplicatively under matrix multiplication. This is the key property that makes the `spectral_bound` approach scalable: bounding the norm of a product of matrices reduces to bounding each factor separately. Applications include stability analysis of iterated linear systems, convergence proofs for power methods, and mixing time bounds for Markov chains.

**Proof strategy:** Expand (A * B)_ij = Σ_k A_ik * B_kj. Use triangle inequality: Σ_j |Σ_k A_ik B_kj| ≤ Σ_j Σ_k |A_ik| |B_kj| = Σ_k |A_ik| Σ_j |B_kj| ≤ Σ_k |A_ik| CB ≤ CA * CB. This chains `matrix_mul_vec_entry_bound` with Fubini-style sum interchange.

**Dependencies from current work:** `matrix_mul_vec_entry_bound`, `spectral_bound_sound`. The entry-level bound directly feeds into the column-sum estimation needed for the product bound.

**Cross-domain connection:** Enables certified convergence proofs for iterative algorithms (power method, PageRank), stability analysis in control theory, and mixing time bounds for random walks on graphs.

---

## 5. Reflection Principle Metatheorem — Certified Micro-Solver Framework

**Theorem Statement (target):**
```
structure CertifiedDecider (P : α → Prop) where
  check : α → Bool
  sound : ∀ x, check x = true → P x
  complete : ∀ x, P x → check x = true

theorem CertifiedDecider.iff {P : α → Prop} (d : CertifiedDecider P) (x : α) :
  d.check x = true ↔ P x

theorem CertifiedDecider.compose {P Q : α → Prop}
  (dP : CertifiedDecider P) (dQ : CertifiedDecider Q) :
  CertifiedDecider (fun x => P x ∧ Q x)

theorem CertifiedDecider.map {P : α → Prop} {Q : β → Prop}
  (d : CertifiedDecider P) (f : β → α) (hf : ∀ b, Q b ↔ P (f b)) :
  CertifiedDecider Q
```

**Why it matters:** This abstracts the pattern common to all three tactic families into a reusable framework. A `CertifiedDecider` is a structure bundling a computable checker with its soundness and completeness proofs. The composition and mapping theorems show that certified deciders form a category, enabling modular construction of complex decision procedures from simple certified components.

**Proof strategy:** Direct construction from the component checkers. The tropical, arithmetic, and matrix families each instantiate this framework. The composition theorem uses `Bool.and_eq_true`; the mapping theorem lifts through the equivalence `hf`.

**Dependencies from current work:** All three tactic families (`tropical_simp_sound`, `NatCheckDivisible_sound/complete`, `spectral_bound_sound`) are instances of this pattern. Abstracting it creates a reusable library for future certified automation.

**Cross-domain connection:** This is the mathematical foundation for a *library of certified micro-solvers* — each covering a decidable fragment of mathematics with proven correctness. Future instances could cover: Boolean satisfiability (SAT), linear arithmetic (Simplex certificates), polynomial identity testing (Schwartz-Zippel), and finite group computation (Schreier-Sims certificates).
