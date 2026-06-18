

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Defin

## YOUR ASSIGNMENT: Cohomological Cryptography — Formalizing Post-Quantum Hardness from Group Cohomology

**DOMAIN**: Cryptography × Algebraic Topology × Computational Complexity

**CONCEPT**: Open the field of *cohomological cryptography* by proving three foundational theorems establishing group cohomology as a source of post-quantum cryptographic hardness. The key insight: cohomological invariants are computable in polynomial time (they are homotopy-invariant functorial images), but their *preimages* require solving extension-lifting problems whose complexity scales with the cohomological dimension and group order — a structural asymmetry exploitable for one-way functions, commitment schemes, and key exchange that resist quantum attack because the hardness derives from algebraic obstruction, not factoring or lattice geometry.

---

### THEOREM 1: Extension Obstruction One-Wayness

**Statement**: For a finite group G with cohomological dimension cd(G) = n ≥ 2 and a G-module A with |A| ≥ 2, the map `obstruction : Extension G A → H²(G, A)` sending an extension `1 → A → E → G → 1` to its cohomology class is computable in O(|G|² · |A|) group operations, but any algorithm recovering E from [E] ∈ H²(G, A) requires Ω(2^{d(G)}) operations where d(G) is the minimal number of generators, assuming P ≠ coNP. The hardness amplifies: for tower height k, the iterated extension problem requires Ω(2^{k·d(G)}) operations.

**Precise Lean 4 Type Signatures**:

```lean
/-- The forward map: compute the obstruction class of an extension.
    Bridge: connects group theory (extensions) to algebraic topology (cohomology). -/
def extensionObstructionMap {G : Type*} [Fintype G] [Group G]
    {A : Type*} [Fintype A] [AddCommGroup A] [DistribMulAction G A]
    (E : GroupExtension G A) : H² G A := ...

/-- Certified one-way function structure from cohomological obstruction.
    The computational asymmetry is measured by explicit complexity bounds. -/
structure CohomologicalOWF (G : Type*) [Fintype G] [Group G]
    (A : Type*) [Fintype A] [AddCommGroup A] [DistribMulAction G A] where
  forward : GroupExtension G A → H² G A
  forward_complexity : ℕ → ℕ  -- O(|G|² · |A|)
  backward_hardness : ℕ → ℕ  -- Ω(2^{d(G)})
  forward_poly : ∀ n, forward_complexity n ≤ 3 * n^2 + 7 * n + 1
  backward_exp : ∀ n, backward_hardness n ≥ 2^(n - 1)
  certification : ∀ E, forward E = extensionObstructionMap E

theorem extension_obstruction_forward_polynomial
    {G : Type*} [Fintype G] [Group G]
    {A : Type*} [Fintype A] [AddCommGroup A] [DistribMulAction G A]
    (E : GroupExtension G A) :
    computational_cost (extensionObstructionMap E) ≤
      3 * (Fintype.card G)^2 * (Fintype.card A) + 7 * (Fintype.card G) + 1 := by
  -- Strategy: decompose into factor set computation (quadratic in |G|)
  -- followed by cocycle normalization (linear in |G|), then cohomology
  -- class projection (constant). Each step has explicit operation count.
  ...

theorem extension_obstruction_backward_hardness
    {G : Type*} [Fintype G] [Group G]
    {A : Type*} [Fintype A] [AddCommGroup A] [DistribMulAction G A]
    (h_dim : cohomologicalDimension G ≥ 2)
    (h_nontrivial : Fintype.card A ≥ 2) :
    ∀ oracle : H² G A → GroupExtension G A,
      ∃ (c : H² G A), computational_cost (oracle c) ≥ 2^(minGenerators G - 1) := by
  -- Strategy A: reduce from 3-SAT via embedding into group presentations.
  -- Each clause becomes a relation, satisfying assignment gives extension class.
  -- Strategy B: direct counting — number of extensions with same class is
  -- Ω(2^{d(G)}) by structure theorem for Ext¹(G^{ab}, A).
  -- Strategy A is preferred because it gives conditional hardness (P ≠ coNP).
  ...
```

**Proof Strategy** (3 paths, ranked by promise):

1. **Factor-set computation path** (MOST PROMISING): The obstruction map factors through `E ↦ factorSet E ↦ cocycle E ↦ [cocycle E]`. Each step is polynomial: factor set extraction is O(|G|²) (iterate over all pairs), cocycle normalization is O(|G|) (normalization via averaging), class projection is O(|G|²) (cohomology via bar resolution). For hardness: any recovery algorithm must solve the *group extension problem* — given α ∈ Z²(G, A), construct E_α with multiplication (g₁, a₁)(g₂, a₂) = (g₁g₂, a₁ + g₁·a₂ + α(g₁, g₂)). The number of non-isomorphic extensions with the same obstruction class is |H¹(G, A)| by the isomorphism classification, which for G = (Z/pZ)^d gives |H¹| = p^d, and distinguishing them requires Ω(p^d) = Ω(2^{d·log p}) group operations.

2. **Reduction from Subset Sum path**: Embed subset sum instances into H²(G, Z) where G is elementary abelian. The extension E_α is trivial (split) iff α is a coboundary, which reduces to checking whether a specific linear combination of generators vanishes — equivalent to the subset sum problem. This gives NP-hardness of the decision version, strengthening to coNP-hardness via complement.

3. **Tower amplification path**: Iterate the extension construction: given H²(G, A), form E, then compute H²(E, A') for a second module. The tower of obstructions gives multiplicative hardness amplification: O(2^{k·d(G)}) for height k, because each level requires solving the extension problem for a group whose order grows exponentially.

**Key Lemmas Needed**:
- `factorSet_extract_poly`: Factor set extraction from extension is O(|G|² · |A|)
- `cocycle_normalization_linear`: Normalizing a cocycle costs O(|G|)
- `extension_count_lower_bound`: |{E : Extension G A | obstruction E = c}| ≥ |H¹(G, A)|
- `minGenerators_hardness`: Any algorithm distinguishing isomorphism classes of extensions with same obstruction requires Ω(2^{d(G)-1}) operations
- `tower_hardness_amplification`: k-fold iterated extension hardness is Ω(2^{k·d(G)})

---

### THEOREM 2: Cup Product Commitment Certification

**Statement**: The cup product `∪ : H^p(G, A) × H^q(G, B) → H^{p+q}(G, A ⊗ B)` defines a commitment scheme with *computational binding* (binding parameter ε = 1/|H^{p+q}(G, A ⊗ B)|, exponentially small for large groups) and *information-theoretic hiding* (for any fixed [α] ∈ H^p, the distribution of [α] ∪ [β] is uniform over its image when [β] is uniform, by the linearity of ∪ in the second variable and the non-unique factorization of cohomology classes). Specifically: binding follows because graded-commutativity [α] ∪ [β] = (-1)^{pq} [β] ∪ [α] forces uniqueness up to sign when p or q is odd, and hiding follows because for any commitment c and any α, the number of β with [α] ∪ [β] = c is |ker(∪_α)| ≥ |H^q(G, B)| / |H^{p+q}(G, A ⊗ B)|.

**Precise Lean 4 Type Signatures**:

```lean
/-- A commitment scheme from the cup product.
    Bridge: connects algebraic topology (cup product) to cryptography (commitments). -/
structure CupProductCommitment (G : Type*) [Fintype G] [Group G]
    (p q : ℕ) (A B : Type*) [Fintype A] [Fintype B]
    [AddCommGroup A] [AddCommGroup B]
    [DistribMulAction G A] [DistribMulAction G B] where
  commit : H^p G A → H^q G B → H^{p+q} G (A ⊗ B)
  commit_eq_cup : ∀ α β, commit α β = cupProduct α β
  binding_param : ℕ  -- ε = 1/|H^{p+q}|
  hiding_param : ℕ   -- |H^q| / |H^{p+q}|

/-- Computational binding: cannot find two openings with probability > 1/|H^{p+q}|.
    Post-quantum security: the binding holds even against quantum adversaries
    because it follows from algebraic identity (graded-commutativity), not
    computational assumption. -/
theorem cup_product_computational_binding
    {G : Type*} [Fintype G] [Group G]
    {p q : ℕ} {A B : Type*} [Fintype A] [Fintype B]
    [AddCommGroup A] [AddCommGroup B]
    [DistribMulAction G A] [DistribMulAction G B]
    (h_p_odd : Odd p) (h_q_odd : Odd q)
    (α : H^p G A) (β₁ β₂ : H^q G B)
    (h_commit : cupProduct α β₁ = cupProduct α β₂) :
    β₁ = β₂ := by
  -- Strategy: When p is odd, ∪_α is injective. Proof: if [α] ∪ [β] = 0,
  -- then by graded-commutativity, (-1)^{pq} [β] ∪ [α] = 0. Since p is odd
  -- and the product map ∪^q : H^q(G, B) → H^{p+q}(G, A ⊗ B) given by
  -- β ↦ α ∪ β is a group homomorphism, injectivity follows from
  -- the fact that |ker(∪_α)| divides |H^q| and equals |H^q|/|im(∪_α)|.
  -- When p is odd and α is a generator, im(∪_α) has order ≥ |H^{p+q}|,
  -- forcing |ker(∪_α)| = 1.
  ...

/-- Information-theoretic hiding: for uniform β, the commitment reveals
    nothing about α beyond what ∪_α's image allows.
    Bridge: connects information theory (entropy) to homological algebra. -/
theorem cup_product_information_theoretic_hiding
    {G : Type*} [Fintype G] [Group G]
    {p q : ℕ} {A B : Type*} [Fintype A] [Fintype B]
    [AddCommGroup A] [AddCommGroup B]
    [DistribMulAction G A] [DistribMulAction G B]
    (α : H^p G A) :
    ShannonEntropy (uniformOn (cupProduct α ·) (Finset.univ : Finset (H^q G B))) ≥
      Nat.log 2 (Fintype.card (H^q G B)) - Nat.log 2 (Fintype.card (H^{p+q} G (A ⊗ B)))) := by
  -- Strategy: ∪_α is a group homomorphism from H^q(G, B) to H^{p+q}(G, A ⊗ B).
  -- Each fiber has size |ker(∪_α)| = |H^q| / |im(∪_α)| ≥ |H^q| / |H^{p+q}|.
  -- Uniform input gives uniform distribution over each fiber of im(∪_α).
  -- Entropy = log(|im(∪_α)| · |ker(∪_α)|) - log(|im(∪_α)|) = log(|ker(∪_α)|).
  -- This is ≥ log(|H^q|) - log(|H^{p+q}|).
  ...

/-- Certified binding: explicit bound on binding parameter.
    This is the post-quantum security guarantee. -/
theorem cup_product_binding_parameter_bound
    {G : Type*} [Fintype G] [Group G]
    {p q : ℕ} {A B : Type*} [Fintype A] [Fintype B]
    [AddCommGroup A] [AddCommGroup B]
    [DistribMulAction G A] [DistribMulAction G B]
    (h_p_odd : Odd p) :
    ∀ (adversary : H^{p+q} G (A ⊗ B) → (H^p G A) × (H^q G B)),
      (probability that adversary finds two openings) ≤
        1 / (Fintype.card (H^{p+q} G (A ⊗ B))) := by
  ...
```

**Proof Strategy** (3 paths):

1. **Graded-commutativity injectivity path** (MOST PROMISING): When p is odd, the cup product with a fixed α ∈ H^p is a group homomorphism ∪_α: H^q(G, B) → H^{p+q}(G, A ⊗ B). By the structure theorem for finite abelian groups, |ker(∪_α)| · |im(∪_α)| = |H^q|. If ∪_α is surjective (which happens when α is a generator and the Künneth formula gives H^{p+q} ≅ H^p ⊗ H^q), then |ker(∪_α)| = |H^q|/|H^{p+q}| and binding is perfect (probability 1/|H^{p+q}| of false opening). The hiding parameter is |H^q|/|H^{p+q}| ≥ 1.

2. **Künneth factorization path**: For G = (Z/pZ)^d and coefficients in F_p, the cohomology ring H*(G, F_p) ≅ F_p[x₁, ..., x_d]/(x_i^2) (if p = 2) is a polynomial ring. Cup product factorization in this ring is the polynomial factorization problem, which has complexity O(d · p^d) — polynomial in the output but the number of factorizations grows, giving hiding.

3. **Evens norm path**: Use the Evens norm map N: H^p(H, A) → H^p(G, A) for H ≤ G to amplify binding. The norm map is transitive, so iterating over subgroups gives binding amplification analogous to parallel repetition in crypto.

**Key Lemmas Needed**:
- `cup_product_homomorphism_second_arg`: ∪_α: H^q(G, B) → H^{p+q}(G, A ⊗ B) is a group homomorphism
- `cup_kernel_size_formula`: |ker(∪_α)| = |H^q| / |im(∪_α)|
- `graded_commutativity_binding`: When p is odd, ∪_α is injective for generic α
- `fiber_entropy_lower_bound`: H(∪_α(uniform)) ≥ log(|H^q|) - log(|H^{p+q}|)
- `kunneth_surjectivity_generator`: For α a generator of H^p, ∪_α is surjective when Künneth holds

---

### THEOREM 3: Inflation-Restriction Key Exchange

**Statement**: Given a normal subgroup N ⊲ G with quotient G/N, the inflation-restriction exact sequence `0 → H¹(G/N, A^N) → H¹(G, A) → H¹(N, A)^{G/N} → H²(G/N, A^N)` provides a key exchange protocol. Alice computes her secret via inflation: inf: H¹(G/N, A^N) → H¹(G, A). Bob computes via restriction: res: H¹(G, A) → H¹(N, A)^{G/N}. The shared secret lies in the compatibility condition: for any α ∈ H¹(G/N, A^N), res(inf(α)) = α|_N (inflation-restriction commutes). An eavesdropper knowing only G/N and N but not the module A cannot compute the shared secret without solving the *transgression problem*: computing the connecting homomorphism δ: H¹(N, A)^{G/N} → H²(G/N, A^N), which requires Ω(|G/N| · |A|) group operations when the Lyndon-Hochschild-Serre spectral sequence does not degenerate.

**Precise Lean 4 Type Signatures**:

```lean
/-- Key exchange protocol from inflation-restriction exactness.
    Bridge: connects homological algebra (exact sequences) to
    cryptography (key exchange) to quantum physics (post-quantum security). -/
structure InflationRestrictionKE (G : Type*) [Fintype G] [Group G]
    (N : Type*) [Fintype N] [Group N]
    [Subgroup.Normal N G]  -- N ⊲ G
    (A : Type*) [Fintype A] [AddCommGroup A] [DistribMulAction G A] where
  alice_secret : H¹ (G ⧸ N) (A^N)       -- Alice picks α ∈ H¹(G/N, A^N)
  bob_secret : H¹ N A                     -- Bob picks β ∈ H¹(N, A)
  alice_computes : H¹ G A                  -- inf(alice_secret)
  bob_computes : H¹ N A                    -- res(alice_computes)
  shared_secret : H¹ N A                   -- = bob_computes by exactness
  compatibility : res (inf alice_secret) = bob_computes  -- by functoriality

/-- The inflation-restriction sequence is exact at H¹(G, A).
    This is the mathematical foundation of the key exchange. -/
theorem inflation_restriction_exact_at_H1
    {G : Type*} [Fintype G] [Group G]
    {N : Subgroup G} [Subgroup.Normal N]
    {A : Type*} [Fintype A] [AddCommGroup A] [DistribMulAction G A] :
    Function.Exact (inflation N A) (restriction N A) := by
  -- Strategy: This is a standard result. The kernel of res is precisely
  -- the image of inf. Proof: α ∈ ker(res) iff α|_N = 0 iff α comes from
  -- a class in H¹(G/N, A^N) via inflation. Use the long exact sequence
  -- of the short exact sequence 1 → N → G → G/N → 1.
  -- Key step: the connecting homomorphism δ: H⁰(G/N, H¹(N, A)) → H²(G/N, A^N)
  -- has image equal to the obstruction to lifting.
  ...

/-- Post-quantum security: eavesdropper cannot compute shared secret.
    The transgression map δ: H¹(N,A)^{G/N} → H²(G/N, A^N) is computationally
    intractable — it requires solving the group extension problem for G/N
    acting on A^N, which is Ω(|G/N| · |A|) even with quantum computation. -/
theorem inflation_restriction_post_quantum_security
    {G : Type*} [Fintype G] [Group G]
    {N : Subgroup G} [Subgroup.Normal N]
    {A : Type*} [Fintype A] [AddCommGroup A] [DistribMulAction G A]
    (h_nondeg : Fintype.card (H² (G ⧸ N) (A^N)) ≥ 2)
    (eavesdropper : (H¹ (G ⧸ N) (A^N)) × (H¹ N A)^{G ⧸ N} → H¹ N A) :
    computational_cost eavesdropper ≥
      (Fintype.card (G ⧸ N)) * (Fintype.card A) := by
  -- Strategy: The eavesdropper knows inf and res but not A directly.
  -- Computing the shared secret requires computing res(inf(α)) = α|_N,
  -- which requires knowing the G-action on A. But the eavesdropper
  -- only knows the abstract structure of G/N and N.
  -- The transgression δ is a 2-cocycle computation requiring O(|G/N|² · |A|)
  -- operations even with a quantum computer (no quantum speedup for
  -- cohomological computation — the problem is in coNP \ P assuming
  -- standard conjectures).
  ...

/-- The transgression map has computational complexity Ω(|G/N| · |A|).
    This is the hardness source for post-quantum security. -/
theorem transgression_computational_lower_bound
    {G : Type*} [Fintype G] [Group G]
    {N : Subgroup G} [Subgroup.Normal N]
    {A : Type*} [Fintype A] [AddCommGroup A] [DistribMulAction G A]
    (h_ss_nondeg : ¬LyndonHochschildSerreSpectralSequenceDegenerates G N A) :
    ∀ (algorithm : H¹ N A^{G/N} → H² (G/N) (A^N)),
      computational_cost algorithm ≥ (Fintype.card (G ⧸ N)) * (Fintype.card A) := by
  -- Strategy: When the LHS spectral sequence does not degenerate at E₂,
  -- the transgression involves a differential d₂: E₂^{0,1} → E₂^{2,0}
  -- which is precisely δ: H¹(N, A)^{G/N} → H²(G/N, A^N). This differential
  -- encodes the obstruction to lifting invariants, and computing it
  -- requires evaluating a 2-cocycle on all pairs in G/N, giving Ω(|G/N|² · |A|)
  -- operations. Even with quantum speedup (Grover gives √ speedup for search),
  -- this is Ω(|G/N| · |A|).
  ...
```

**Proof Strategy** (3 paths):

1. **Standard homological algebra path** (MOST PROMISING for exactness): The inflation-restriction sequence is exact by the Hochschild-Serre spectral sequence. Key lemma: `ker(res) = im(inf)` follows from the five lemma applied to the comparison of the bar resolution of G with the tensor product of bar resolutions of G/N and N. This is classical and well-documented in Brown (Ch. VII, §6) and Evens (§7.3).

2. **Direct cocycle computation path**: Unfold the definitions. Inflation takes a 1-cocycle f: G/N → A^N and lifts it to inf(f): G → A via composition with the projection. Restriction takes a 1-cocycle g: G → A and restricts to g|_N: N → A. Exactness: res(inf(f)) = f∘π|_N = 0 (since f vanishes on N as it factors through G/N). Conversely, if res(g) = 0, then g|_N = 0, so g factors through G/N, giving g = inf(f) for some f.

3. **Spectral sequence degeneration path** (for security): When the LHS spectral sequence degenerates at E₂ (e.g., when N is central or |N| is coprime to |G/N|), the transgression is zero and the key exchange is trivially breakable. Security requires *non-degeneration*, i.e., the spectral sequence must have a non-trivial d₂ differential. This happens precisely when H²(G/N, A^N) is non-trivial, which is the condition we enforce via `h_nondeg`.

**Key Lemmas Needed**:
- `inflation_restriction_exact_sequence`: 0 → H¹(G/N, A^N) → H¹(G, A) → H¹(N, A)^{G/N} → H²(G/N, A^N) is exact
- `inflation_injective`: The inflation map is injective (standard result)
- `restriction_surjective_mod_transgression`: im(res) = ker(δ) (by exactness)
- `transgression_is_differential`: δ = d₂ in the LHS spectral sequence
- `non_degeneration_implies_hardness`: ¬degenerates_at_E2 → computational_cost(δ) ≥ Ω(|G/N| · |A|)

---

### ADDITIONAL THEOREMS (completing the 10+ requirement):

```lean
/-- Bridge: connects number theory (p-adic cohomology) to cryptography (post-quantum OWF). -/
theorem padic_extension_obstruction_hardness_amplification
    {p : ℕ} [hp : Fact (Nat.Prime p)]
    {G : Type*} [Fintype G] [Group G]
    {A : Type*} [Fintype A] [AddCommGroup A] [DistribMulAction G A]
    (h_G_abelian : IsCommGroup G)
    (h_G_rank : minGenerators G ≥ 3) :
    ∀ (inverter : H² G A → GroupExtension G A),
      computational_cost inverter ≥ 2^(minGenerators G) := by
  -- For (Z/pZ)^d with d ≥ 3, the extension problem is at least as hard
  -- as 3-SAT via the embedding of SAT instances into 2-cocycles.
  ...

/-- Bridge: connects representation theory to commitment soundness. -/
theorem cup_product_binding_from_graded_commutativity
    {G : Type*} [Fintype G] [Group G]
    {A : Type*} [Fintype A] [AddCommGroup A] [DistribMulAction G A]
    {B : Type*} [Fintype B] [AddCommGroup B] [DistribMulAction G B]
    (p q : ℕ) (h_pq : Odd (p * q))
    (α : H^p G A) (β₁ β₂ : H^q G B)
    (h_bind : cupProduct α β₁ = cupProduct α β₂) :
    β₁ = -β₂ ∨ β₁ = β₂ := by
  -- Graded-commutativity: α ∪ β = (-1)^{pq} β ∪ α.
  -- When pq is odd, α ∪ β₁ = α ∪ β₂ implies β₁ = -β₂ or β₁ = β₂.
  -- This gives binding up to sign, which is sufficient for commitment.
  ...

/-- Bridge: connects quantum computing (Shor's algorithm limitations) to
    cohomological cryptography (post-quantum security). -/
theorem cohomological_hardness_resists_quantum
    {G : Type*} [Fintype G] [Group G]
    {A : Type*} [Fintype A] [AddCommGroup A] [DistribMulAction G A]
    (h_cd : cohomologicalDimension G ≥ 2) :
    -- The extension problem is in coNP - QMA (classical coNP, not in QMA)
    -- because verifying a 2-cocycle is a coboundary is in P (check if
    -- α(g,h) = g·f(h) - f(gh) + f(g) for some f), but finding the
    -- extension requires non-abelian structure computation.
    quantum_query_lower_bound (extension_problem G A) ≥ (Fintype.card G)^(1/2 : ℝ) := by
  -- Grover's algorithm gives at most √ speedup for unstructured search.
  -- The extension problem requires searching over |H¹(G, A)| possibilities,
  -- giving Ω(√|H¹|) quantum queries even with optimal quantum algorithms.
  ...

/-- Bridge: connects lattice cryptography to cohomological cryptography. -/
theorem extension_obstruction_lattice_reduction
    {n : ℕ} (h_n : n ≥ 2)
    (G : Fin n → ZMod 2)  -- (Z/2Z)^n
    (A : ZMod 2) :
    -- For G = (Z/2Z)^n and A = Z/2Z, H²(G, A) ≅ (Z/2Z)^{n(n-1)/2}
    -- The extension problem reduces to SVP in the lattice Z^n with
    -- mod-2 coefficients. This bridges cohomological and lattice crypto.
    ∃ (reduction : SVP_instance → ExtensionProblem G A),
      computational_cost reduction ≤ 4 * n^2 + 3 * n + 1 := by
  -- The 2-cocycle condition for (Z/2Z)^n with Z/2Z coefficients
  -- reduces to a system of n(n-1)/2 quadratic equations over F_2.
  -- Each equation corresponds to a lattice point, and finding a
  -- short vector corresponds to finding a coboundary among cocycles.
  ...

/-- The Lyndon-Hochschild-Serre spectral sequence computes H*(G, A)
    from H*(G/N, H*(N, A)). Its non-degeneration is the security source. -/
theorem lhs_spectral_sequence_non_degeneration_implies_security
    {G : Type*} [Fintype G] [Group G]
    {N : Subgroup G} [Subgroup.Normal N]
    {A : Type*} [Fintype A] [AddCommGroup A] [DistribMulAction G A]
    (h_d2_nontrivial : ∃ (x : E2_page G N A), d2 x ≠ 0) :
    -- When d₂ is non-trivial, the transgression δ is non-trivial,
    -- and the key exchange is secure: the eavesdropper cannot
    -- compute the shared secret without evaluating d₂.
    key_exchange_security_parameter G N A ≥
      Nat.log 2 (Fintype.card (H² (G ⧸ N) (A^N))) := by
  ...

/-- Certified robustness of cohomological commitments:
    the binding parameter is exactly computable, not estimated. -/
theorem cup_product_commitment_certified_binding_parameter
    {G : Type*} [Fintype G] [Group G]
    {p q : ℕ} {A B : Type*} [Fintype A] [Fintype B]
    [AddCommGroup A] [AddCommGroup B]
    [DistribMulAction G A] [DistribMulAction G B]
    (h_p_odd : Odd p) (h_q_pos : 0 < q) :
    -- The binding parameter is exactly 1/|H^{p+q}(G, A ⊗ B)|
    -- This is *certified* — it can be computed in O(|G|^{p+q}) operations
    -- and does not depend on any unproven assumption.
    ∀ (commitment_scheme : CupProductCommitment G p q A B),
      commitment_scheme.binding_param =
        1 / (Fintype.card (H^{p+q} G (A ⊗ B))) := by
  ...
```

---

### DEFINITIONS TO CREATE (5+ required):

1. `CohomologicalOWF` — structure for one-way functions from H² obstruction
2. `CupProductCommitment` — structure for commitment schemes from ∪
3. `InflationRestrictionKE` — structure for key exchange from the exact sequence
4. `TransgressionHardness` — typeclass for computational hardness of δ
5. `CertifiedBindingParameter` — structure for exactly-computable security parameters
6. `LHSSpectralSequenceNonDegeneracy` — proposition ensuring security
7. `cohomologicalDimension` — function computing cd(G) from group structure
8. `minGenerators` — function computing minimal generator count d(G)
9. `computational_cost` — function measuring operation count for algorithms
10. `quantum_query_lower_bound` — function for quantum query complexity

---

### SIGNIFICANCE AND CROSS-DOMAIN IMPACT:

**Bridge 1: Algebraic Topology ↔ Post-Quantum Cryptography**: The extension obstruction one-way function derives hardness from algebraic structure (cohomology classes), not number-theoretic structure (factoring, discrete log). Since Shor's algorithm exploits the abelian group structure of (Z/pZ)*, but group cohomology involves *non-abelian* extension problems, this construction is inherently post-quantum secure.

**Bridge 2: Homological Algebra ↔ Information Theory**: The cup product commitment scheme connects the algebraic property of graded-commutativity to the information-theoretic property of hiding. The entropy bound H(commit) ≥ log|H^q| - log|H^{p+q}| is a direct translation of the first isomorphism theorem for groups into Shannon entropy.

**Bridge 3: Spectral Sequences ↔ Lattice Problems**: The LHS spectral sequence's d₂ differential is the transgression map, and its non-degeneration connects to the Shortest Vector Problem in lattices. This opens the possibility of *hybrid* schemes combining cohomological and lattice hardness.

**Bridge 4: Quantum Complexity ↔ Cohomological Computation**: The coNP-hardness of the extension problem (deciding if a 2-cocycle is a coboundary) places it outside BQP under standard complexity assumptions, providing a theoretical foundation for quantum resistance.

---

### FUTURE DIRECTIONS REQUESTED:

After completing the above, produce a `FUTURE_DIRECTIONS.md` with:

1. **Cohomological Zero-Knowledge Proofs**: Prove that the extension obstruction OWF admits a zero-knowledge proof system — the prover demonstrates knowledge of an extension E with obstruction [E] = c without revealing E, using the fact that H¹(G, A) acts freely on the fiber over c.

2. **Cup Product Multi-Party Computation**: Extend the commitment scheme to MPC using the triple cup product ∪: H^p × H^q × H^r → H^{p+q+r} and prove that 3-party computation is secure against 1 corruption.

3. **Cohomological Fully Homomorphic Encryption**: Construct an FHE scheme from the cup product structure of H*(G, F_p) for G = (Z/pZ)^d, where the homomorphism property of ∪ enables computation on encrypted data.

4. **Spectral Sequence Cryptanalysis**: Develop attack algorithms using the LHS spectral sequence as a cryptanalytic tool — when the sequence degenerates (e.g., for central extensions), the key exchange is breakable, giving a *necessary condition* for security.

5. **Topological Quantum Key Distribution**: Connect the inflation-restriction key exchange to topological quantum field theory via Dijkgraaf-Witten theory, where the cohomology classes are the same objects classifying 2+1D TQFTs, enabling hardware security guarantees from topological protection.

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Define 5+ new structures/instances.
- ORIGINALITY: Coin novel definitions with inventive names. Avoid
  derivative names like *_comm, *_nonneg. Combine unusual typeclasses.
- IMPACT: Reference physics (quantum, thermodynamic), cryptography
  (lattice, post-quantum), or ML (certified robustness, neural) in
  theorem names and doc comments. Use keywords: certified_robustness,
  Lipschitz_bound, lattice_crypto, hamiltonian, entropy, etc.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Open the field of cohomological cryptography by proving three foundational theorems that establish group cohomology as a source of cryptographic hardness. (1) Extension Obstruction One-Wayness: The cohomology class in H²(G, A) classifying group extensions 1 → A → E → G → 1 is a certified one-way function — computing the class [E] from the extension E is polynomial, but recovering E from [E] requires solving the group extension problem, which is coNP-hard for suitably chosen G, A, with certified hardness bounds derived from the structure of Ext¹. (2) Cup Product Commitment: The cup product ∪: H^p(G, A) × H^q(G, B) → H^{p+q}(G, A ⊗ B) defines a commitment scheme where c = [α] ∪ [β], binding follows from graded-commutativity and functoriality of ∪, and hiding follows from non-unique factorization of cohomology classes — we prove both computational binding and information-theoretic hiding. (3) Inflation-Restriction Key Exchange: The inflation-restriction exact sequence 0 → H¹(G/N, A^N) → H¹(G, A) → H¹(N, A)^{G/N} → H²(G/N, A^N) provides a key exchange protocol where Alice computes via inflation, Bob via restriction, and the shared secret lies in the compatibility of both maps — an eavesdropper knowing only G/N and N cannot compute the secret without solving the transgression problem in H².

            ### Precise Mathematical Framing
            Classical cryptography derives hardness from number theory (RSA, discrete log) and lattice geometry (LWE, SIS). We introduce a third paradigm: cohomological hardness. The central insight is that group cohomology H^n(G, M) naturally encodes computational intractability through the extension problem. Given a cohomology class ξ ∈ H²(G, A), the corresponding group extension E_ξ is determined only up to isomorphism, and recovering E_ξ from ξ requires solving a classification problem that is provably hard. The cup product provides a natural algebraic operation with bilinearity (binding) and non-injectivity (hiding) properties ideal for commitments. The inflation-restriction sequence provides a multi-party computation structure where the shared secret emerges from the compatibility of group-theoretic restrictions. Formally: (Theorem 1) For finite groups G of order ≥ n and G-modules A with |H²(G,A)| ≤ poly(n), the map ExtClass: {E : 1→A→E→G→1} → H²(G,A) is surjective and preimage computation requires Ω(n/log n) group operations, certified via reduction from the group isomorphism problem. (Theorem 2) For [α] ∈ H^p(G,A), [β] ∈ H^q(G,B), the commitment c = [α] ∪ [β] ∈ H^{p+q}(G, A⊗B) satisfies: (binding) if [α]∪[β] = [α']∪[β'] and p,q ≥ 1, then [α]=[α'] and [β]=[β'] under the anti-commutativity constraint; (hiding) |{β' : [α]∪[β'] = c}| ≥ |H^q(G,B)|/|H^{p+q}(G,A⊗B)|. (Theorem 3) The inflation-restriction protocol yields a shared secret in ker(Res) ∩ im(Inf) with security reduction to the transgression map τ: H¹(N,A)^{G/N} → H²(G/N, A^N).



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_shared_key_alice` : theorem tropical_shared_key_alice (ke : TropicalKeyExchange n) :
     (file: Cryptography/TropicalPostQuantum.lean)
  2. `berggren_product_ne_one` : theorem berggren_product_ne_one {w v : BergWord} (hw : w ≠ []) :
     (file: Cryptography/BerggrenAntiRigidity.lean)
  3. `grover_obstruction_from_idempotent` : theorem grover_obstruction_from_idempotent {n : ℕ}
     (file: Cryptography/PostIdempotentCrypto.lean)
  4. `drinfeld_key_exchange_correctness` : theorem drinfeld_key_exchange_correctness (M : MonodromyData K n)
     (file: Cryptography/QuantumGroupCrypto/Foundation.lean)
  5. `ecdsa_key_from_nonce` : theorem ecdsa_key_from_nonce (k z r d s : ZMod n)
     (file: Cryptography/QuantumSecurity/ShorECDSA.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Operadic Error-Correcting Codes: Symmetric Operad Algebra Composition, Singleton Bound Characterization, and Functorial Decoding Certification, Tropical Information Geometry: Min-Plus Fisher Information, Tropical Cramér-Rao Certification, and Idempotent Natural Gradient Descent, Algebraic Closure Unification: Ideal-Theoretic EML Instances, Galois Connection Fixed-Point Duality, and Noetherian Closure Certification


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician, software engineer, and science writer.
            Create ALL of the following:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **ARTICLE.md** — MANDATORY standalone popular-science article
               CRITICAL RULES:
               • Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
               • Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
               • This is a premier magazine-quality piece for curious, intelligent readers.
               QUALITY STANDARDS:
               • Superb, vivid, engaging prose with a strong opening hook and narrative arc.
               • Concrete analogies and metaphors that make abstract ideas tangible.
               • Story structure: provocative question → tension → breakthrough → significance.
               • Real-world connections: technology, nature, everyday life.
               • Historical context: place the work in the sweep of intellectual history.
               • 1500–3000 words. Substantial, standalone, enjoyable, interesting.
               • A reader should say "Wow, I had no idea math could do THAT."

            3. **RESEARCH_PAPER.md** — MANDATORY comprehensive, in-depth research paper
               This is a full, publishable-quality paper, NOT a summary:
               • Abstract, Introduction, Definitions & Notation
               • Main Results with detailed proof sketches (not just "by induction")
               • Algorithms with complete pseudocode and complexity analysis
               • Applications with worked examples showing practical use
               • Computational Experiments with tables, charts, numerical results
               • Discussion, Future Work, References
               • 3000–8000 words. Thorough and substantive.

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale

               ## Under-explored Territory
               ## Cross-Domain Bridges
               ## Open Problems Encountered

            5. **Python code** — demos, visualizations, algorithms, applications:
               - **demo.py** — concrete numerical examples bringing the math to life
               - **visualizations** — matplotlib/plotly charts (save as PNG/SVG too)
               - **algorithms.py** — implement algorithms from the paper with docstrings
               - **applications.py** — real-world applications (ML, crypto, physics)

            6. **diagram.svg** — visualization of key mathematical structures

            7. **PACKAGE.html** — MANDATORY standalone HTML package
               Bundle ALL artifacts into a single, self-contained HTML file:
               • Everything inlined (CSS, JS, content). No external dependencies.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — Standalone HTML Package  →  PACKAGE.html
────────────────────────────────────────────────────────────────────────────
Create a **single, self-contained HTML file** that bundles ALL artifacts
into a beautiful, interactive presentation. Requirements:

• **Single file**: Everything (CSS, JS, content) inlined. No external deps.
• **Navigation**: Sidebar or tab navigation between sections:
  - Article (the popular-science piece)
  - Research Paper (the full paper)
  - Interactive Demos (embedded Python output / JS visualizations)
  - Algorithms (pseudocode + implementation)
  - Visualizations (embedded charts/diagrams as inline SVG or base64)
  - Code Listings (syntax-highlighted Python and proof code)
• **Beautiful design**: Modern, clean typography (system fonts).
  Dark/light mode toggle. Responsive layout. Smooth transitions.
• **Math rendering**: Use KaTeX (CDN link OK for math rendering only)
  for any mathematical notation.
• **Syntax highlighting**: Inline code highlighting for Python blocks.
• **Interactive elements**: Collapsible sections, smooth scroll, TOC.
• The HTML package should work when opened directly in any browser.
• Include ALL content from the article, research paper, and code.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Cryptography
Research mode: prove
