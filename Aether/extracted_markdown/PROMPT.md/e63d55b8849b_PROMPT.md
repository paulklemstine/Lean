

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new

## ASSIGNMENT: Valuation–Stabilizer Correspondence and Tropical Quantum Code Geometry

Formalize a min-plus/tropical theory of quantum stabilizer weight data that turns closure-theoretic stabilizer certification into explicit lower bounds on code distance and explicit inf-convolution formulas for concatenated recovery. Work in maximal typeclass generality wherever possible, but ensure at least one concrete executable specialization to `ℕ`, `ℤ`, or `WithTop ℕ` so that algorithmic bounds are meaningful.

Bridge: connects quantum error correction, tropical/idempotent algebra, lattice fixed-point theory, polyhedral support functions, and certified robustness style min-plus verification.

### Core new definitions to introduce

You should define at least the following, with doc comments that explicitly mention `quantum`, `post_quantum_security`, `certified`, `lattice`, or `tropical`:

```lean
/-- Tropical valuation data attached to finitely supported Pauli-weight observables.
Bridge: connects quantum stabilizer enumerators to tropical lattice valuations. -/
structure StabilizerValuation
    (ι : Type _) (R : Type _) [DecidableEq ι]
    [CanonicallyOrderedCommSemiring R] [OrderBot R] where
  carrier : ι →₀ ℕ →₀ R
  monotone_weight :
    ∀ ⦃f g : ι →₀ ℕ⦄, f ≤ g → carrier f ≤ carrier g
  zero_exact : carrier 0 = 0
  add_subadditive :
    ∀ f g, carrier (f + g) ≤ carrier f + carrier g
```

Also define at least 9 more nontrivial objects/structures, for example:

```lean
def pauliWeightFinsupp (n : ℕ) := Fin n →₀ ℕ

def supportRadius
    {ι R} [DecidableEq ι] [CanonicallyOrderedCommSemiring R] [OrderBot R]
    (v : StabilizerValuation ι R) : R := ...

def tropWeightEnumerator
    {ι R} [DecidableEq ι] [LinearOrder R] [CanonicallyOrderedCommSemiring R] [OrderBot R]
    (v : StabilizerValuation ι R) (S : Finset (ι →₀ ℕ)) : ℕ → R := ...

def tropBreakpoint
    {ι R} [DecidableEq ι] [LinearOrder R] [CanonicallyOrderedCommSemiring R] [OrderBot R]
    (W : ℕ → R) : Prop := ...

def closureFixedWeightSet
    {α : Type _} [CompleteLattice α] (c : α → α) := {x | c x = x}

def tropicalDistanceLowerBound
    {ι R} [DecidableEq ι] [LinearOrder R] [CanonicallyOrderedCommSemiring R] [OrderBot R]
    (v : StabilizerValuation ι R) : ℕ := ...

def infConvolutionNat
    (f g : ℕ → WithTop ℕ) : ℕ → WithTop ℕ := ...

def concatenatedRecoveryProfile
    (f g : ℕ → WithTop ℕ) : ℕ → WithTop ℕ := infConvolutionNat f g

def tropicalSupportFunction
    {ι R} [DecidableEq ι] [LinearOrder R] [CanonicallyOrderedCommSemiring R] [OrderBot R]
    (S : Finset (ι →₀ ℕ)) (x : ι →₀ ℕ) : R := ...

def valuationPolytope
    {ι R} [DecidableEq ι] [LinearOrder R] [CanonicallyOrderedCommSemiring R] [OrderBot R]
    (v : StabilizerValuation ι R) (S : Finset (ι →₀ ℕ)) : Set (ι →₀ ℕ) := ...

class TropicalClosureCompatible
    {α R : Type _} [CompleteLattice α] [Preorder R] (c : α → α) (φ : α → R) : Prop where
  mono_closed : ∀ ⦃x y⦄, x ≤ y → φ (c x) ≤ φ (c y)
  idempotent_shadow : ∀ x, φ (c (c x)) = φ (c x)
```

You may refine these signatures if needed for provability, but preserve the conceptual content:
- finitely supported Pauli-weight data,
- tropical valuation/enumerator,
- closure/fixed-point transport,
- breakpoint-to-distance lower bound,
- concatenation = inf-convolution.

### Precise theorem targets

Prove a coherent chain of at least 20 theorems, including the following named milestones with exact or essentially equivalent Lean signatures.

#### 1. Basic valuation algebra

```lean
theorem StabilizerValuation.map_zero
    {ι R} [DecidableEq ι]
    [CanonicallyOrderedCommSemiring R] [OrderBot R]
    (v : StabilizerValuation ι R) :
    v.carrier 0 = 0 := v.zero_exact
```

```lean
theorem StabilizerValuation.monotone
    {ι R} [DecidableEq ι]
    [CanonicallyOrderedCommSemiring R] [OrderBot R]
    (v : StabilizerValuation ι R) :
    Monotone v.carrier := by
  intro f g hfg
  exact v.monotone_weight hfg
```

```lean
theorem StabilizerValuation.self_domination
    {ι R} [DecidableEq ι]
    [CanonicallyOrderedCommSemiring R] [OrderBot R]
    (v : StabilizerValuation ι R) (f : ι →₀ ℕ) :
    v.carrier f ≤ v.carrier (f + f)
```

This theorem should not be trivialized; prove it using monotonicity and `f ≤ f + f`, not `simp`.

#### 2. Tropical enumerator monotonicity and support control

```lean
def tropWeightEnumerator
    {ι R} [DecidableEq ι] [LinearOrder R]
    [CanonicallyOrderedCommSemiring R] [OrderBot R]
    (v : StabilizerValuation ι R) (S : Finset (ι →₀ ℕ)) : ℕ → R :=
  fun k => S.inf' (by
    rcases Finset.card_pos.mp (Finset.card_pos.mpr ?_) with h
    exact ?_) (fun f => v.carrier f + if f.sum (fun _ m => m) = k then 0 else ⊤)
```

If this exact shape is awkward, switch to `WithTop ℕ` or finite minima over filtered subsets. The crucial point is that `tropWeightEnumerator` is a min-plus profile by Hamming/Pauli weight.

Prove:

```lean
theorem tropWeightEnumerator_mono_set
    {ι R} [DecidableEq ι] [LinearOrder R]
    [CanonicallyOrderedCommSemiring R] [OrderBot R]
    (v : StabilizerValuation ι R) {S T : Finset (ι →₀ ℕ)}
    (hST : S ⊆ T) :
    ∀ k, tropWeightEnumerator v T k ≤ tropWeightEnumerator v S k
```

```lean
theorem tropWeightEnumerator_weight_witness
    {ι} [DecidableEq ι] (v : StabilizerValuation ι (WithTop ℕ))
    (S : Finset (ι →₀ ℕ)) :
    ∀ {k}, (∃ f ∈ S, f.sum (fun _ m => m) = k) →
      ∃ f ∈ S, f.sum (fun _ m => m) = k ∧
        tropWeightEnumerator v S k = v.carrier f
```

This is the first major `∀ k, ∃ f` quantifier-alternating theorem. Use `Finset.exists_min_image` or a custom finite minimization lemma.

#### 3. Closure/fixed-point transport through Knaster–Tarski style certification

Define a reusable closure-operator structure if the catalog does not already provide one:

```lean
structure IsClosureOperator {α : Type _} [Preorder α] (c : α → α) : Prop where
  extensive : ∀ x, x ≤ c x
  monotone' : Monotone c
  idempotent' : ∀ x, c (c x) = c x
```

Then define fixed points:

```lean
def fixedPoints {α : Type _} (c : α → α) : Set α := {x | c x = x}
```

Prove:

```lean
theorem tropWeightEnumerator_mono_through_closure
    {α ι : Type _} {R : Type _}
    [CompleteLattice α] [DecidableEq ι]
    [LinearOrder R] [CanonicallyOrderedCommSemiring R] [OrderBot R]
    (c : α → α) (hc : IsClosureOperator c)
    (Φ : α → Finset (ι →₀ ℕ))
    (hmono : Monotone Φ)
    (v : StabilizerValuation ι R) :
    ∀ x, tropWeightEnumerator v (Φ (c x)) ≤ tropWeightEnumerator v (Φ x)
```

If function-order comparison on `ℕ → R` is inconvenient, state pointwise:

```lean
    ∀ x k, tropWeightEnumerator v (Φ (c x)) k ≤ tropWeightEnumerator v (Φ x) k
```

Also prove a fixed-point invariance theorem:

```lean
theorem tropWeightEnumerator_fixedpoint_shadow
    {α ι : Type _} {R : Type _}
    [CompleteLattice α] [DecidableEq ι]
    [LinearOrder R] [CanonicallyOrderedCommSemiring R] [OrderBot R]
    (c : α → α) (hc : IsClosureOperator c)
    (Φ : α → Finset (ι →₀ ℕ))
    (hfix : ∀ x, Φ (c x) = Φ x)
    (v : StabilizerValuation ι R) :
    ∀ x k, tropWeightEnumerator v (Φ (c x)) k = tropWeightEnumerator v (Φ x) k
```

#### 4. Tropical breakpoint implies distance lower bound

Define a concrete breakpoint notion that is provable. A good choice:

```lean
def IsTropicalBreakpoint (W : ℕ → WithTop ℕ) (d : ℕ) : Prop :=
  ∀ k < d, W k = ⊤
```

Interpretation: no nontrivial codeword/recovery witness exists below weight `d`.

Then define a distance lower bound extracted from an enumerator:

```lean
def codeDistanceLowerBound (W : ℕ → WithTop ℕ) : ℕ :=
  Nat.findGreatest (fun d => ∀ k < d, W k = ⊤) someBound
```

Or avoid `findGreatest` and state a direct theorem:

```lean
theorem distance_lb_of_tropical_breakpoint
    {ι : Type _} [DecidableEq ι]
    (v : StabilizerValuation ι (WithTop ℕ))
    (S : Finset (ι →₀ ℕ)) {d : ℕ}
    (hbreak : ∀ k < d, tropWeightEnumerator v S k = ⊤) :
    ∀ f ∈ S, f.sum (fun _ m => m) < d → False
```

Then derive the cleaner existential-free corollary:

```lean
theorem distance_lb_of_tropical_breakpoint'
    {ι : Type _} [DecidableEq ι]
    (v : StabilizerValuation ι (WithTop ℕ))
    (S : Finset (ι →₀ ℕ)) {d : ℕ}
    (hbreak : ∀ k < d, tropWeightEnumerator v S k = ⊤) :
    ∀ f ∈ S, d ≤ f.sum (fun _ m => m)
```

This theorem should explicitly connect to quantum distance certification in the doc comment:
`quantum certified distance lower bound via tropical breakpoint`.

#### 5. Concatenation and inf-convolution

Define min-plus inf-convolution on `WithTop ℕ`:

```lean
def infConvolutionNat (f g : ℕ → WithTop ℕ) (n : ℕ) : WithTop ℕ :=
  Finset.inf' (Finset.range (n + 1)) (by simp) (fun i => f i + g (n - i))
```

Or if `Finset.inf'` is awkward, use `sInf` over the finite image set.

Prove the algebraic lemmas:

```lean
theorem infConvolutionNat_comm
    (f g : ℕ → WithTop ℕ) :
    infConvolutionNat f g = infConvolutionNat g f
```

This should use the symmetry `i ↦ n - i`; do not prove by extensional simplification alone—use a genuine combinatorial reindexing lemma.

```lean
theorem infConvolutionNat_assoc
    (f g h : ℕ → WithTop ℕ) :
    infConvolutionNat (infConvolutionNat f g) h =
      infConvolutionNat f (infConvolutionNat g h)
```

A full proof may be technical; if needed, first prove pointwise inequalities both directions using witnesses and arithmetic identities. This is an ideal place for `omega`.

Now define a concatenation profile for two recovery schemes:

```lean
def concatRecoveryEnumerator
    {ι κ : Type _} [DecidableEq ι] [DecidableEq κ]
    (v₁ : StabilizerValuation ι (WithTop ℕ))
    (v₂ : StabilizerValuation κ (WithTop ℕ))
    (S₁ : Finset (ι →₀ ℕ)) (S₂ : Finset (κ →₀ ℕ)) :
    ℕ → WithTop ℕ := ...
```

The exact implementation can use product witnesses and split total weight into outer/inner contributions. Then prove:

```lean
theorem concat_trop_polytope_eq_infConvolution
    {ι κ : Type _} [DecidableEq ι] [DecidableEq κ]
    (v₁ : StabilizerValuation ι (WithTop ℕ))
    (v₂ : StabilizerValuation κ (WithTop ℕ))
    (S₁ : Finset (ι →₀ ℕ)) (S₂ : Finset (κ →₀ ℕ)) :
    concatRecoveryEnumerator v₁ v₂ S₁ S₂ =
      infConvolutionNat (tropWeightEnumerator v₁ S₁) (tropWeightEnumerator v₂ S₂)
```

This is the flagship theorem. Name auxiliary lemmas evocatively, e.g.
- `quantum_tropical_split_witness`
- `lattice_pauli_weight_decompose`
- `certified_concat_upper_channel`
- `certified_concat_lower_channel`

#### 6. Polyhedral/support-function viewpoint

Even if you only formalize a finite combinatorial shadow of a polytope, make the bridge explicit. Define a support function from finite sets of finitely supported vectors and prove min-plus behavior:

```lean
theorem tropicalSupportFunction_infimal
    {ι : Type _} [DecidableEq ι]
    (S T : Finset (ι →₀ ℕ)) :
    ∀ x, tropicalSupportFunction (S ∪ T) x =
      min (tropicalSupportFunction S x) (tropicalSupportFunction T x)
```

Then connect concatenation to Minkowski-sum style support behavior, in whatever finite version is provable.

### Additional theorem quota and diversity requirements

In addition to the named theorems above, prove enough supporting results to exceed 20 total theorems and use diverse tactics:
- induction on `n : ℕ` for decomposition of inf-convolution range;
- `rcases` on witness existence in finite minima;
- `by_contra` for the breakpoint-to-distance contradiction;
- `omega` for identities like `i + (n - i) = n` under `i ≤ n`;
- `linarith` if you move through `ℤ`/`ℚ` support-function inequalities;
- `field_simp` only if you introduce rational normalization or average-weight bounds;
- `simp` should appear, but not dominate.

Good additional theorem targets:

```lean
theorem supportRadius_mono ...
theorem supportRadius_union_eq_max ...
theorem fixedPoints_completeLattice ...
theorem closureFixedWeightSet_nonempty ...
theorem tropWeightEnumerator_top_of_no_witness ...
theorem tropWeightEnumerator_eq_top_iff ...
theorem infConvolutionNat_top_left ...
theorem infConvolutionNat_top_right ...
theorem infConvolutionNat_mono ...
theorem concatRecoveryEnumerator_mono_left ...
theorem concatRecoveryEnumerator_mono_right ...
theorem quantum_certified_lipschitz_profile ...
theorem tropical_hash_collision_lower_bound ...
```

For the last two, it is acceptable to formalize mathematically modest but precise corollaries:
- a Lipschitz bound of the form `W (n+1) ≤ W n + C`,
- a collision lower bound interpretation for repeated inf-convolution profiles.

### Computational and algorithmic content

State explicit complexity bounds in comments and, where feasible, as theorems about finite search domains:
- computing `tropWeightEnumerator v S k` by scanning `S` is `O(|S|)`;
- computing `infConvolutionNat f g n` by scanning `0..n` is `O(n)`;
- computing the first `N` values is `O(N^2)` naively.

Formalize at least one theorem that bounds search size:

```lean
theorem infConvolutionNat_search_domain_card
    (n : ℕ) :
    (Finset.range (n + 1)).card = n + 1
```

and one theorem that turns a finite search into a certified witness theorem:

```lean
theorem tropWeightEnumerator_certified_attainment
    {ι : Type _} [DecidableEq ι]
    (v : StabilizerValuation ι (WithTop ℕ))
    (S : Finset (ι →₀ ℕ)) :
    ∀ k, S.Nonempty →
      ∃ f ∈ S, tropWeightEnumerator v S k ≤ v.carrier f
```

### Suggested proof architecture

1. **Build the finite-minimum infrastructure first.**
   Prove small lemmas about `Finset.inf'`, filtered finsets, and witness extraction. If `inf'` is painful, define your own finite min over `WithTop ℕ` using `Finset.fold min ⊤`. This often simplifies proofs dramatically.

2. **Use `WithTop ℕ` as the main concrete tropical semiring.**
   It gives a literal `⊤` for “no witness below this weight,” which makes breakpoint and distance statements natural and easy to prove by contradiction.

3. **Reduce closure statements to set inclusion on finite witness sets.**
   The theorem `tropWeightEnumerator_mono_set` should be the engine. Then closure/fixed-point theorems become one-line applications once `Φ (c x) ⊆ Φ x` or equality is established.

4. **For concatenation, prove ≤ and ≥ separately.**
   - Upper bound: choose a split `i + (n-i) = n` and combine minimizing witnesses from each side.
   - Lower bound: every concatenated witness induces a split, hence dominates one term of the inf-convolution.
   The lower bound proof should use `rcases` on the concatenated witness decomposition.

5. **For breakpoint ⇒ distance, argue by contradiction.**
   Assume a witness `f ∈ S` of weight `< d`; set `k := weight f`; then `tropWeightEnumerator v S k ≠ ⊤` because `v.carrier f` is a finite witness. Contradict the breakpoint hypothesis. This is an ideal use of `by_contra`.

### Lean design preferences

Prefer type signatures like these when possible:

```lean
variable {ι κ α : Type _}
variable {R : Type _}
variable [DecidableEq ι] [DecidableEq κ]
variable [CompleteLattice α]
variable [LinearOrder R] [CanonicallyOrderedCommSemiring R] [OrderBot R]
```

For concrete executable sections:

```lean
section WithTopNat
open scoped BigOperators

variable {ι κ : Type _} [DecidableEq ι] [DecidableEq κ]
```

Use separate namespaces:
- `QuantumTropical`
- `QuantumTropical.Stabilizer`
- `QuantumTropical.Concat`
- `QuantumTropical.Polytope`

### Significance to make explicit in doc comments and theorem names

This formalization should read as a blueprint for:
- **quantum** code distance certification via tropical breakpoints,
- **cryptographic / post_quantum_security** interpretation of stabilizer weight growth as hardness profile,
- **certified robustness** style min-plus composition laws for concatenated recovery channels,
- **lattice** fixed-point semantics for closure-certified codespaces,
- **polyhedral/tropical** support-function control of enumerators.

Use theorem names that carry this significance:
- `quantum_certified_breakpoint_distance`
- `post_quantum_security_via_tropical_gap`
- `lattice_fixedpoint_pauli_shadow`
- `certified_concat_recovery_infimal`
- `thermodynamic_pauli_free_energy_bound`

The last can be a corollary interpreting `tropWeightEnumerator` as a zero-temperature free energy:
```lean
theorem thermodynamic_pauli_free_energy_bound ...
```
Even a simple monotonicity/infimum statement is acceptable if the doc comment makes the bridge precise.

### If a full polytope API is unavailable

Do not stall. Replace geometric statements by finite support-function shadows on `Finset (ι →₀ ℕ)`. The research-critical content is the min-plus convexity pattern, not Euclidean geometry machinery. State any remaining stronger polyhedral statement as a precise conjecture at the end, but prove all finite combinatorial versions with zero sorries.

### Deliverable shape

Produce a substantial Lean development with:
- 10+ definitions/structures,
- 20+ proved theorems,
- at least one section specialized to `WithTop ℕ`,
- explicit algorithmic/certified interpretations in doc comments,
- no placeholders.

Also produce a structured `FUTURE_DIRECTIONS.md` containing 3–5 concrete next targets such as:
1. tropical MacWilliams duality for stabilizer valuations,
2. entropy/free-energy asymptotics for repeated concatenation,
3. lattice/post-quantum hardness profiles from enumerator gaps,
4. certified robustness analogues for min-plus neural decoders,
5. tropical Satake style symmetry actions on stabilizer polytopes.

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

            Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


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
            Establish a precise bridge between tropical/idempotent geometry and quantum stabilizer coding by proving that min-plus valuations of Pauli weight enumerators induce a canonical tropical code polytope whose faces control distance, concatenation monotonicity, and certifiable decoding thresholds. The core result should show that the closure-operator stabilizer structures recently formalized in EML Quantum Stabilizer Theory admit a valuation functor to a tropical semimodule, and that this degeneration preserves enough combinatorial data to recover lower bounds on code distance and logical operator growth. This would open a new program of tropical quantum coding, distinct from existing in-flight closure-classifier and Pauli-equivariant classification work because it focuses on valuation geometry, code polytopes, and decoding certificates rather than classifier semantics or lattice classification.

            ### Precise Mathematical Framing
            Let S be a finite Pauli stabilizer family equipped with the closure operator cl_S from EML Quantum Stabilizer Theory, and let W_S(x,y) denote a formal Pauli weight enumerator or support-count generating function attached to cl_S-fixed subsets. Define a non-Archimedean/min-plus valuation v on coefficients and tropicalize W_S to a piecewise-linear support function Trop(W_S). Prove three foundational statements: (1) a valuation-stabilizer correspondence: Trop(W_S) is functorial under stabilizer-preserving morphisms and factors through the Knaster-Tarski fixed-point lattice of cl_S; (2) a tropical distance bound: the first nontrivial slope break or exposed face of the tropical code polytope gives a certified lower bound on stabilizer distance and logical operator support growth; (3) a concatenation/decoder theorem: under idempotent recovery concatenation, tropical code polytopes combine by min-plus convolution/Minkowski sum, yielding computable threshold monotonicity and a certified dynamic-programming decoder on the tropicalized support complex. This leverages recent success on EML Quantum Stabilizer Theory, uses under-exploited Tropical+Bridges infrastructure, creates an algorithmic pipeline for code certification, and connects to physics/quantum computing without repeating prior cohomological or toric-code tracks.

            ### Lean 4 Sketch
Define a structure `StabilizerValuation` on finitely supported Pauli-weight functions into a linearly ordered idempotent semiring; formalize `tropWeightEnumerator`, prove monotonicity/functoriality through closure fixed points, then derive `distance_lb_of_tropical_breakpoint` and `concat_trop_polytope_eq_infConvolution` for concatenated recovery schemes. Likely needs finitely supported functions, order lattices, idempotent semiring lemmas, and convex/polyhedral support-function APIs.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `quantum_code_distance_from_obstruction` : theorem quantum_code_distance_from_obstruction
     (file: Bridges/HomologicalDeepLearning.lean)
  2. `e8_quantum_code_distance` : theorem e8_quantum_code_distance : 2 * 2 = (4 : ℕ) := by norm_num
     (file: Bridges/FiveFrontiers.lean)
  3. `tropical_plus_distributes_over_min` : theorem tropical_plus_distributes_over_min (a b c : ℝ) :
     (file: Bridges/MinPlusVerificationCore.lean)
  4. `tropical_lattice_dimension_bound` : theorem tropical_lattice_dimension_bound (n : ℕ) (hn : 8 ≤ n) :
     (file: Bridges/ProofAlgGeomBridge.lean)
  5. `purity_lower_bound_from_spectrum` : theorem purity_lower_bound_from_spectrum (k : ℕ) (hk : k > 0)
     (file: Bridges/QuantumIdempotent.lean)

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



Recent successful concepts: EML Quantum Stabilizer Theory: Closure-Operator Stabilizer Correspondence, Knaster-Tarski Codespace Certification, and Idempotent Recovery Concatenation, Gravitational Factoring: Idempotent Spectral Lensing, Causal Prime Decomposition, and Ring-Theoretic Factorization Certification, Min-Plus Verification Theory: ReLU Network Isomorphism, Polytope Certified Radii, and Verification Completeness


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
Research mode: formalize
