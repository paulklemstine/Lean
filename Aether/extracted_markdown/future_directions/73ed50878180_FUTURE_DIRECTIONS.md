# Future Directions: Formal Novelty Certification for Theorem Spaces

## 1. Injective Descriptor Hypothesis

**Conjecture:** There exists a finite extension of the `Descriptor` structure — adding fields such as subexpression depth histogram, type universe level, dependency count, and a hash of the normalized head symbol — such that `embed` is injective on all well-typed theorem statements of syntax-tree size ≤ N, for N ≤ 50.

**Mathematical Rationale:** The current 9-dimensional embedding is injective on the `Descriptor` type itself (proved as `embed_injective`), but many structurally different theorems can share the same descriptor. Richer descriptors narrow the collision space. The key question is whether finitely many syntactic invariants suffice to separate bounded-size statements, or whether semantic collisions are unavoidable.

**Formal Test:** Enumerate all well-typed closed propositions over `Nat`, `Bool`, `Fin n` (for small n) with syntax-tree size ≤ N. Compute extended descriptors for each. Check whether any two non-alpha-equivalent statements share a descriptor.

**Criterion for Refutation:** Exhibit two semantically inequivalent, non-alpha-equivalent statements of size ≤ N that produce identical extended descriptors. This would demonstrate a fundamental information-theoretic barrier to syntactic novelty detection.

---

## 2. Dimension-vs-Certification Tradeoff Hypothesis

**Conjecture:** For any embedding `embed : Descriptor → (Fin d) → ℝ`, there exists a family of ≥ 2^d + 1 pairwise-distinct descriptors such that at least two share the same embedding image. Consequently, no d-dimensional embedding can certify novelty for archives of size > 2^d when descriptors have d boolean features.

**Mathematical Rationale:** This is a pigeonhole argument: a d-dimensional embedding into ℝ^d can be injective on at most |ℝ|^d points (uncountably many), but if the descriptor family has combinatorial structure (e.g., 2^k boolean fields with k > d), collisions are forced. The interesting question is the exact tradeoff curve for structured descriptor families.

**Formal Test:** For each d ∈ {1, 2, ..., 9}, construct a family of descriptors with 2^(d+1) distinct boolean combinations. Prove in Lean that any embedding into `Fin d → ℝ` that only reads d of the boolean fields must have collisions.

**Criterion for Refutation:** Exhibit an embedding into `Fin d → ℝ` that separates more than 2^d descriptors from a combinatorial family, using nonlinear coordinate functions.

---

## 3. Lipschitz Novelty Stability Hypothesis

**Conjecture:** For a natural class of "perturbation operations" on theorem statements (variable renaming, weakening hypotheses, strengthening conclusions, adding unused binders), the induced change in `archiveDist` is bounded by a computable function of the perturbation magnitude, with Lipschitz constant ≤ √9 = 3 in the sup-norm embedding.

**Mathematical Rationale:** The `novelty_transfer` theorem proves that archive distance is 1-Lipschitz in the embedding norm. The open question is whether natural syntactic perturbations induce bounded descriptor changes. If so, novelty certificates are robust: a theorem that is novel remains novel under small edits.

**Formal Test:**
1. Define a type `Perturbation` with constructors for each perturbation kind.
2. Define `applyPerturbation : Perturbation → Descriptor → Descriptor`.
3. Prove `‖embed (applyPerturbation p d) - embed d‖ ≤ perturbationBound p` for explicit bounds.
4. Compose with `novelty_transfer` to get stability theorems.

**Criterion for Refutation:** Exhibit a perturbation that changes only one binder but causes the descriptor to jump by more than the claimed bound (e.g., if adding a binder changes multiple fields simultaneously in an unbounded way).

---

## 4. Oracle Lower Bound Hypothesis

**Conjecture:** Any novelty certification algorithm that inspects at most k < 9 coordinates of the descriptor embedding cannot distinguish all pairs of descriptors differing in the unqueried coordinates. Formally, for k-query strategies, there exist descriptors d₁ ≠ d₂ with the same query outputs but different novelty status relative to some archive.

**Mathematical Rationale:** This connects to information-theoretic lower bounds for property testing. A k-query algorithm extracts at most k real-valued features; the remaining 9 − k coordinates are invisible. If two descriptors agree on the k queried coordinates but differ on the rest, and one is in the archive while the other is not, the algorithm cannot distinguish them.

**Formal Test:**
1. Model a k-query strategy as a function that selects k indices from `Fin 9` and reads those coordinates.
2. Prove that for any such strategy and any k < 9, there exist d₁, d₂ with the same query output but d₁ ∈ A and d₂ ∉ A.
3. This yields a formal impossibility theorem for bounded-query novelty certification.

**Criterion for Refutation:** Show that some nonlinear combination of k < 9 coordinates suffices to reconstruct the full descriptor (this would require the descriptor space to have low intrinsic dimension).

---

## 5. Semantic Compression Hypothesis

**Conjecture:** For theorem statements over a fixed signature with ≤ S symbols and quantifier depth ≤ D, the descriptor captures enough information to achieve a false-novelty rate below 1/(S·D) on uniformly random archives of size ≤ 100.

**Mathematical Rationale:** The descriptor is a lossy compression of the theorem statement. The question is whether this compression retains enough information for practical novelty detection. A low false-novelty rate means that when the descriptor says "novel," the theorem genuinely differs from all archived theorems in at least one structural dimension.

**Formal Test:**
1. Implement a random theorem generator over the restricted signature.
2. Generate 10,000 random archives of size 100.
3. For each, compute descriptors and check: when `archiveDist > 0`, does the theorem actually differ from all archived theorems?
4. Measure the false-novelty rate (archiveDist > 0 but theorem is semantically equivalent to an archived one).

**Criterion for Refutation:** Observe a false-novelty rate exceeding 1/(S·D), indicating that the descriptor misses too much semantic information. This would motivate adding semantic invariants (e.g., normal forms, proof-irrelevance classes) to the descriptor.

---

## Summary Table

| # | Hypothesis | Key Technique | Expected Difficulty |
|---|-----------|---------------|-------------------|
| 1 | Injective descriptors | Enumeration + collision search | Medium |
| 2 | Dimension tradeoff | Pigeonhole + combinatorics | Easy–Medium |
| 3 | Lipschitz stability | Perturbation theory | Medium |
| 4 | Oracle lower bound | Information theory | Medium–Hard |
| 5 | Semantic compression | Computational experiments | Easy (empirical) |

Each hypothesis is designed to be falsifiable within a single research cycle and, if confirmed, would extend the formal novelty certification framework in a mathematically meaningful direction.
