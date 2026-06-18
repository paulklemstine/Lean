

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

## TASK: Causal Reconstruction of Zariski Topology — Finite Causal Decomposition, Depth-Dimension Identity, and Holographic Uniqueness

### I. THE GRAND VISION

We establish that the Zariski topology on $\operatorname{Spec}(R)$ is *completely determined* by its causal (specialization) order — the same mathematical structure governing light-cone causality in Lorentzian spacetime. This is not an analogy but a theorem: closed sets are finite causal-orbit unions, algebraic dimension *is* causal depth, and the topology is holographically unique. This bridges **algebraic geometry** (Zariski spectra), **causal theory** (Lorentzian spacetime structure per Hawking-King-McCarthy), and **post-quantum cryptography** (lattice ideal structure determines hardness via spectral causal depth).

---

### II. PRECISE THEOREM STATEMENTS WITH LEAN 4 SIGNATURES

**Theorem 1: Finite Causal Decomposition (causal_finite_decomposition_theorem)**
```lean
/-- Bridge: connects algebraic geometry (Zariski closed sets) to causal spacetime
    structure (finite unions of forward light cones). 
    
    The Zariski-closed sets in Spec(R) for a Noetherian ring R are precisely
    the finite unions of causal futures J⁺(pᵢ) = V(pᵢ).
    
    Computational bound: finding the minimal prime decomposition requires
    O(n · d²) operations where n = number of generators of I and d = Krull dim R.
    This bound governs certified_robustness verification for algebraic neural networks.
-/
theorem causal_finite_decomposition_theorem 
    (R : Type*) [CommRing R] [IsNoetherianRing R]
    (S : Set (PrimeSpectrum R)) :
    IsZariskiClosed S ↔ ∃ (primes : Finset (PrimeSpectrum R)),
      S = ⋃ p ∈ primes, causalFuture p := by
  sorry -- DO NOT USE: prove this fully
```

**Theorem 2: Causal Depth-Dimension Identity (causal_depth_dimension_identity)**
```lean
/-- Bridge: connects ring-theoretic dimension to causal hierarchy depth.
    
    The Krull dimension of R equals the maximum length of a strict causal chain
    in Spec(R), establishing algebraic dimension AS causal depth.
    
    Application: lattice_crypto hardness parameter — the causal depth of the
    ideal lattice determines the security parameter Ω(2^(d/2)) for Ring-SIS.
-/
theorem causal_depth_dimension_identity 
    (R : Type*) [CommRing R] [IsNoetherianRing R] :
    ringKrullDim R = causalChainMaxLength R := by
  sorry -- DO NOT USE: prove this fully
```

**Theorem 3: Holographic Uniqueness (holographic_uniqueness_theorem)**
```lean
/-- Bridge: connects spectral topology to holographic principle in quantum gravity.
    
    The Zariski topology on Spec(R) is the unique compact T₀ topology whose
    specialization order recovers the causal order. The causal structure alone
    holographically encodes the full topology.
    
    Application: post_quantum_security of spectral hash functions relies on
    the uniqueness of topological reconstruction from causal data.
-/
theorem holographic_uniqueness_theorem
    (R : Type*) [CommRing R] [IsNoetherianRing R]
    (τ : TopologicalSpace (PrimeSpectrum R))
    (h_compact : @CompactSpace (PrimeSpectrum R) τ)
    (h_t0 : @T0Space (PrimeSpectrum R) τ)
    (h_spec_order : ∀ p q, @Specializes (PrimeSpectrum R) τ p q ↔ p ≤ q) :
    τ = inferInstance := by
  sorry -- DO NOT USE: prove this fully
```

---

### III. PROOF STRATEGIES (MULTIPLE PATHS)

**Strategy A (Direct Decomposition — RECOMMENDED for Theorem 1):**
1. *Forward direction* (already in catalog): Every Zariski-closed set is upward-closed under specialization. Prove `upward_closed_of_Zariski_closed`.
2. *Key Lemma* (`minimal_prime_finite_union`): For a Noetherian ring, the minimal primes over a radical ideal $I$ are finite: use `IsNoetherianRing` to extract finitely many minimal elements from the set of primes containing $I$, since the prime spectrum satisfies DCC on prime ideals containing $I$.
3. *Decomposition step*: Prove `V_eq_union_minimal_primes`: $V(I) = \bigcup_{p \text{ minimal over } I} V(p)$, using the radical equality $\sqrt{I} = \bigcap_{p \text{ minimal over } I} p$ from commutative algebra.
4. *Causal identification*: Each $V(p)$ is exactly the causal future `causalFuture p` by the existing catalog theorem `zariski_closure_eq_causal_future`.

**Strategy B (Causal Chain Induction — RECOMMENDED for Theorem 2):**
1. Define `causalChainMaxLength` as the supremum of lengths of strict chains $p_0 \subset p_1 \subset \cdots \subset p_k$ in $\operatorname{Spec}(R)$.
2. *Key Lemma* (`causal_chain_length_eq_ht_plus_one`): For any prime $p$, the length of the longest causal chain ending at $p$ equals $\operatorname{ht}(p) + 1$. Prove by Noetherian induction on the complement of the set of primes below $p$.
3. *Supremum step*: `ringKrullDim R = ⨆ p, ht(p)` by definition. Transfer via the height-chain correspondence.
4. *Computational bound*: Establish that computing `causalChainMaxLength` requires $\Omega(d)$ ideal membership tests, where $d$ is the Krull dimension.

**Strategy C (Spectral Space Characterization — RECOMMENDED for Theorem 3):**
1. *Key Lemma* (`zariski_is_spectral`): The Zariski topology makes $\operatorname{Spec}(R)$ a spectral space (compact, T₀, sober, with compact opens closed under finite intersection). Use Hochster's characterization.
2. *Key Lemma* (`spectral_order_determines_topology`): For spectral spaces, the specialization order uniquely determines the topology. Prove by showing the open sets are precisely the upward-closed sets whose complements are compact and downward-closed.
3. *Uniqueness step*: Any other compact T₀ topology with the same specialization order must be the patch topology of the spectral space, which coincides with the Zariski topology for $\operatorname{Spec}(R)$.
4. *Alternative path*: Use the fact that compact T₀ topologies with the same specialization order are ordered by refinement, and the Zariski topology is both the finest spectral and coarsest compact T₀ topology with that order.

---

### IV. REQUIRED DEFINITIONS AND STRUCTURES (5+ NEW)

```lean
/-- The causal future of a point in Spec(R): the set of all specializations.
    Analogous to J⁺(p) in Lorentzian causality. -/
def causalFuture (p : PrimeSpectrum R) : Set (PrimeSpectrum R) :=
  {q | p ≤ q}

/-- The causal past of a point: all points that specialize to it.
    Analogous to J⁻(p) in Lorentzian causality. -/
def causalPast (p : PrimeSpectrum R) : Set (PrimeSpectrum R) :=
  {q | q ≤ p}

/-- A causal chain is a strictly increasing sequence of prime ideals.
    Its length is one less than the number of elements. -/
structure CausalChain (R : Type*) [CommRing R] where
  primes : List (PrimeSpectrum R)
  chain_strict : ∀ i (hi₁ : i + 1 < primes.length) (hi₂ : i < primes.length),
    (primes.get ⟨i, hi₂⟩).asIdeal < (primes.get ⟨i + 1, hi₁⟩).asIdeal

/-- The maximum causal chain length — equals the Krull dimension for Noetherian rings.
    Security application: Ω(2^(causalChainMaxLength/2)) bound on Ring-SIS hardness. -/
noncomputable def causalChainMaxLength (R : Type*) [CommRing R] : ℕ :=
  sSup {n | ∃ (c : CausalChain R), c.primes.length = n + 1}

/-- A causally reconstructible topology is one uniquely determined by its
    specialization order among compact T₀ topologies. -/
class CausallyReconstructible (α : Type*) [TopologicalSpace α] : Prop where
  h_compact : CompactSpace α
  h_t0 : T0Space α
  h_unique : ∀ (τ : TopologicalSpace α), 
    @CompactSpace α τ → @T0Space α τ → 
    (∀ x y, @Specializes α τ x y ↔ @Specializes α _ x y) → τ = _

/-- The causal depth of a prime ideal: length of longest causal chain below it.
    Equals the height of the prime ideal. -/
noncomputable def causalDepth (p : PrimeSpectrum R) : ℕ :=
  sSup {n | ∃ (c : CausalChain R), c.primes.getLast? = some p ∧ c.primes.length = n + 1}
```

---

### V. CONCRETE LEMMA SEQUENCE (BUILD BOTTOM-UP)

Prove these in order. Each is non-trivial and requires specific tactics:

1. **`causalFuture_eq_zeroLocus`**: `causalFuture p = PrimeSpectrum.zeroLocus {p.asIdeal}` — unfold definitions, use `Set.ext` and `PrimeSpectrum.mem_zeroLocus`. *Tactics: ext, simp, exact*

2. **`upward_closed_of_zeroLocus`**: For any `s : Set R`, `PrimeSpectrum.zeroLocus s` is upward-closed under `≤` — use the transitivity of inclusion on prime ideals. *Tactics: intro, exact, transitivity*

3. **`minimal_primes_finite_of_noetherian`**: For a Noetherian ring `R` and radical ideal `I`, the minimal primes over `I` form a `Finset` — use `IsNoetherianRing` to extract finitely many minimal elements from the well-founded order on prime ideals containing `I`. *Tactics: induction, classical, exact*

4. **`radical_eq_inter_minimal_primes`**: For Noetherian `R` and ideal `I`, `√I = ⋂ p ∈ minimalPrimesOver I, (p : Ideal R)` — this is the standard commutative algebra result. Build from `Inf_eq_sInf` and Noetherianness. *Tactics: le_antisymm, intro, rcases*

5. **`zeroLocus_eq_union_minimal_primes`**: `V(I) = ⋃ p ∈ minimalPrimesOver I, V(p)` — use `radical_eq_inter_minimal_primes` and the correspondence between radical ideals and closed sets. *Tactics: rw, apply, exact*

6. **`causal_future_decomposition_forward`**: Every Zariski-closed set is a finite union of causal futures — compose `zeroLocus_eq_union_minimal_primes` with `causalFuture_eq_zeroLocus`. *Tactics: intro, rw, exact*

7. **`causal_future_decomposition_backward`**: Every finite union of causal futures is Zariski-closed — use finiteness and the fact that each `causalFuture p = V(p)` is closed. *Tactics: induction, apply, exact*

8. **`causal_chain_length_ge_height`**: For any prime `p`, `causalDepth p ≥ ht(p)` — construct a causal chain from any height chain. *Tactics: intro, use, exact*

9. **`causal_chain_length_le_height`**: For any prime `p` in a Noetherian ring, `causalDepth p ≤ ht(p)` — use Noetherian induction on the complement of primes below `p`. *Tactics: induction, by_contra, omega*

10. **`causal_depth_dimension_identity`**: The main theorem combining 8 and 9 with the definition of Krull dimension. *Tactics: le_antisymm, apply, exact*

11. **`zariski_is_spectral_space`**: `Spec(R)` is a spectral space — prove compact, T₀, sober, and compact opens closed under intersection. *Tactics: constructor, apply, exact, intro*

12. **`specialization_order_of_spectral_determines_topology`**: For spectral spaces, two topologies with the same specialization order and both spectral must be equal. *Tactics: ext, contrapose, exact*

13. **`holographic_uniqueness_theorem`**: The main uniqueness theorem combining 11 and 12. *Tactics: exact, apply, intro*

14. **`causal_depth_lattice_crypto_bound`**: For a Noetherian ring `R` with Krull dim `d`, Ring-SIS over `R` has security parameter `Ω(2^(d/2))`. *Tactics: omega, linarith, exact*

15. **`certified_robustness_spectral_bound`**: If a polynomial neural network has decision boundary defined by ideal `I ⊂ R[X₁,...,Xₙ]`, the certified robustness radius is at least `1/(causalDepth (radical I))`. *Tactics: linarith, exact, apply*

---

### VI. SIGNIFICANCE AND CROSS-DOMAIN IMPACT

**Algebraic Geometry → Causal Theory**: Theorems 1-3 establish that Zariski spectra *are* causal spacetimes in a precise mathematical sense. The specialization order, previously viewed as an algebraic curiosity, is the exact analog of the Lorentzian causal order. This opens the field of **causal-topological algebraic geometry**.

**Causal Theory → Post-Quantum Cryptography**: Theorem 2 directly impacts lattice-based cryptography. The security of Ring-SIS and Ring-LWE schemes depends on the ideal structure of the ring. The `causalChainMaxLength` provides a *topological invariant* for hardness: rings with deeper causal hierarchies (higher Krull dimension) yield exponentially harder lattice problems. This gives a **certified_robustness** bound for post-quantum key exchange: security parameter $\Omega(2^{d/2})$ where $d$ = `causalChainMaxLength`.

**Algebraic Geometry → ML Certified Robustness**: Theorem 1 decomposes decision boundaries of polynomial neural networks into causal futures of minimal primes. The number of such primes (the `causal_complexity`) bounds the Lipschitz constant of the network, enabling **Lipschitz_certified_robustness** verification in $O(k \cdot d^2)$ time where $k$ = number of minimal primes and $d$ = `causalChainMaxLength`.

---

### VII. DELIVERABLE REQUIREMENTS

- **File**: `CausalZariskiReconstruction.lean` (target: 800+ lines)
- **Theorems**: 15+ non-trivial theorems with ZERO sorries
- **Definitions**: 6+ new structures/classes (causalFuture, causalPast, CausalChain, causalChainMaxLength, CausallyReconstructible, causalDepth)
- **Tactic diversity**: Use `induction`, `rcases`, `by_contra`, `omega`, `linarith`, `field_simp`, `le_antisymm`, `Set.ext` — not just `simp`/`rfl`/`decide`
- **Typeclass abstraction**: Use `[CommRing R]`, `[IsNoetherianRing R]`, `[PartialOrder (PrimeSpectrum R)]` — not concrete types only
- **Quantifier alternation**: Include theorems with `∀∃∀` or `∀∃` structure
- **Doc comments**: Every theorem must have a doc comment with `Bridge: connects X to Y` and application keywords

**FUTURE_DIRECTIONS**: After completing the proofs, produce a `FUTURE_DIRECTIONS.md` with 3-5 concrete breakthrough-level next steps:
1. Causal holography for non-Noetherian rings (does uniqueness fail?)
2. Tropical causal reconstruction (replace Spec with Val)
3. Quantum error correction via causal depth (CSS codes from spectral causal chains)
4. Adversarial robustness bounds from causal complexity of decision boundaries
5. Causal sheaf cohomology and its connection to quantum field anomalies

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
            Open the field of causal-topological algebraic geometry by proving three foundational theorems that establish the complete reconstruction of the Zariski topology from causal structure alone. (1) Finite Causal Decomposition Theorem: For a Noetherian ring R, S ⊆ Spec(R) is Zariski closed if and only if S is a finite union of causal futures J⁺(pᵢ) = V(pᵢ), proving that closed sets are precisely finite causal-orbit unions—the forward direction (closed ⟹ upward-closed) is in catalog; the converse requires minimal prime decomposition V(I) = V(p₁) ∪ ... ∪ V(pₖ) for minimal primes over I. (2) Causal Depth-Dimension Identity: The Krull dimension of a Noetherian ring R equals the maximum length of a strict causal chain p₀ ⊂ p₁ ⊂ ... ⊂ pₖ in Spec(R), establishing algebraic dimension as causal depth—dimension of the algebraic variety IS the depth of its causal hierarchy. (3) Holographic Uniqueness Theorem: The Zariski topology on Spec(R) is uniquely determined by the specialization (causal) order among all compact T₀ topologies on the set of prime ideals—the causal structure alone holographically encodes the full topology.

            ### Precise Mathematical Framing
            The specialization order p ≤ q ⟺ p ⊆ q on Spec(R) defines a causal structure where J⁺(p) = {q : p ⊆ q} = V(p) is the causal future. The catalog already contains zariski_closure_eq_causal_future and closed_upward_closed. Theorem (1) requires showing V(I) = ⋃_{p minimal over I} J⁺(p) using Noetherianness (finitely many minimal primes), and conversely that finite unions of J⁺(pᵢ) are closed since each V(pᵢ) is closed. Theorem (2) requires connecting Order.krullDim or Ideal.height to maximum causal chain length: a chain p₀ ⊂ ... ⊂ pₖ witnesses height ≥ k for pₖ, and Noetherian induction constructs maximum-length chains. Theorem (3) is the deepest: any compact T₀ topology with specialization order = inclusion must have closed sets = finite unions of closures of points = finite unions of J⁺(pᵢ), which uniquely determines the topology. This is the algebraic geometry analogue of the causal reconstruction theorems in Lorentzian geometry (Hawking-King-McCarthy).



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `valuation_depth_strict_hierarchy` : theorem valuation_depth_strict_hierarchy (α : Type*) [Semiring α]
     (file: Bridges/NonArchimedeanComputation.lean)
  2. `elimination_prime_code_complete` : theorem elimination_prime_code_complete (Γ : Finset α) (y : α) (φ : α)
     (file: Bridges/BooleanThermodynamicEliminationDuality.lean)
  3. `EMLClosure'_depth_mono_set` : theorem EMLClosure'_depth_mono_set (n : ℕ) :
     (file: Bridges/EntropyClosureSeparation.lean)
  4. `leech_from_three_e8` : theorem leech_from_three_e8 : 3 * (8 : ℕ) = 24 := by norm_num
     (file: Bridges/Moonshine/MoonshineCodingTheory.lean)
  5. `eq_of_same_on_all_primes` : theorem eq_of_same_on_all_primes
     (file: Bridges/ProofSemiringStone.lean)

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



Recent successful concepts: Berggren-Hopf Algebra: Graded Coproduct Decomposition, Antipode-Factoring Correspondence, and Birkhoff Renormalization of Pythagorean Triples, Ultrametric Deep Learning: p-Adic Saddle Elimination, Valuation Generalization Bounds, and Hensel Pruning Certification, Algebraic Spacetime: Prime Spectrum Causal Structure, Zariski Holographic Reconstruction, and Ideal-Theoretic Conservation Laws


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - Detailed proofs and explanations

            3. **DISCUSSION.md** — MANDATORY Scientific American-style popular science article
               - Written for a mathematically literate but non-specialist audience
               - Use analogies, examples, and narrative to explain WHY this matters
               - Include at least one surprising connection to everyday life or another field
               - 1000-2000 words, accessible but not dumbed-down
               - This makes your research accessible to a broad audience

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables,
                 what unexpected connections it reveals
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale (1 = one clever lemma, 5 = multi-theorem development)

               ## Under-explored Territory
               - Domains with many definitions but few deep theorems
               - Unexpected structural similarities across domains
               - "Orphan" results that could seed new research programs

               ## Cross-Domain Bridges
               - Specific, precise connections between domains
               - Conjectured functorial correspondences or isomorphisms
               - Algorithmic pipelines combining results from multiple domains

               ## Open Problems Encountered
               - Problems you couldn't solve but identified as important
               - Conjectures you can state precisely but not yet prove
               - Connections that seem to exist but need more catalog infrastructure

            5. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            6. **diagram.svg** — visualization of key mathematical structures

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Bridges
Research mode: prove
