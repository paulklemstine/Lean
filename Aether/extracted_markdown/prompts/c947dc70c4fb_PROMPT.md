

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

## YOUR ASSIGNMENT: Cryptography–Pythagorean Isogeny-Free Trapdoors via Berggren Tree Lattice Minors and Orbit Separation

Work in a new file logically placed at
`Bridges/CryptographyPythagorean/BerggrenMinorTrapdoors.lean`.

Build a self-contained formal bridge between:
- arithmetic dynamics of the Berggren tree of primitive Pythagorean triples,
- lattice-style collision resistance / orbit separation for post-quantum cryptography,
- explicit finite-depth algorithmics with certified recovery bounds.

The central idea is to package a primitive triple together with a finite set of integer minor invariants derived from its Berggren ancestry, and prove that these invariants are stable enough to certify uniqueness of ancestry up to bounded depth. This is an isogeny-free arithmetic trapdoor toy model: public data are low-dimensional minor profiles, secret data are ancestral words, and the trapdoor is uniqueness of parent recovery inside the primitive orbit.

You should formalize the strongest version you can prove with zero sorries. If full global injectivity is too strong, prove bounded-depth injectivity with explicit constants.

---

## Core definitions to introduce

Define at least the following, with doc comments explicitly naming `post_quantum_security`, `lattice`, `certified`, and `orbit separation`.

Use exact or near-exact Lean 4 signatures of this shape; adapt only if required by existing catalog infrastructure.

```lean
/-- A finite Berggren instruction word; intended as a post_quantum_security key seed. -/
abbrev BerggrenWord := List BerggrenGenerator
```

If `BerggrenGenerator` does not already exist, define an inductive three-letter alphabet:
```lean
inductive BerggrenGenerator
| A | B | C
deriving DecidableEq, Repr
```

Define word evaluation on triples:
```lean
def evalWord : BerggrenWord → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
```

Define the canonical root packet:
```lean
def rootTriplePacket : ℤ × ℤ × ℤ := (3, 4, 5)
```

Define primitive packet predicate:
```lean
def primitiveTriplePacket (t : ℤ × ℤ × ℤ) : Prop :=
  let (a,b,c) := t
  0 < a ∧ 0 < b ∧ 0 < c ∧ a^2 + b^2 = c^2 ∧ Int.gcd a b = 1
```

Define a nondegeneracy certificate stronger than primitivity, suitable for computational recovery:
```lean
def packetNondegenerate (t : ℤ × ℤ × ℤ) : Prop :=
  primitiveTriplePacket t ∧ t.1 ≠ 0
```
If tuples are awkward, use a structure:
```lean
structure TriplePacket where
  x : ℤ
  y : ℤ
  z : ℤ
deriving DecidableEq, Repr
```

Define the integer minor profile. It should not be a trivial restatement of the triple; use several 2×2-style minors or asymmetric combinations so that symmetry/orientation matters:
```lean
structure MinorProfile where
  m_xy : ℤ
  m_yz : ℤ
  m_zx : ℤ
  skew : ℤ
deriving DecidableEq, Repr
```

A recommended definition:
```lean
def minorProfile (t : TriplePacket) : MinorProfile :=
{ m_xy := t.x + t.y
, m_yz := t.y + t.z
, m_zx := t.z + t.x
, skew := t.z - t.x - t.y
}
```
But if catalog infrastructure supports actual Berggren matrices, prefer genuine row/column minors extracted from the matrix product defining the orbit action.

Define ancestry certificates:
```lean
structure AncestralCertificate where
  depth : ℕ
  word : BerggrenWord
  packet : TriplePacket
  valid_eval : evalWord word rootTriplePacket = (packet.x, packet.y, packet.z)
deriving Repr
```

Define collision relation and bounded-depth orbit separation:
```lean
def sameMinorProfile (u v : TriplePacket) : Prop :=
  minorProfile u = minorProfile v

def depthBoundedCollision (N : ℕ) : Prop :=
  ∀ ⦃w₁ w₂ : BerggrenWord⦄,
    w₁.length ≤ N →
    w₂.length ≤ N →
    sameMinorProfile (packetOfWord w₁) (packetOfWord w₂) →
    w₁ = w₂
```

Define computational size and explicit complexity measures:
```lean
def bitSizeTriple (t : TriplePacket) : ℕ := ...
def certComplexity (c : AncestralCertificate) : ℕ := ...
def recoveryCostBound (N : ℕ) : ℕ := ...
```

Also define at least five additional original notions, for example:
- `orbitSeparationRadius : ℕ → ℤ`
- `minorEntropy : MinorProfile → ℕ`
- `trapdoorPublicKey : BerggrenWord → MinorProfile`
- `trapdoorSecretKey : Type := BerggrenWord`
- `cryptographicCollisionSurface (N : ℕ) : Finset (BerggrenWord × BerggrenWord)`
- `quantumResistantDepthScore : BerggrenWord → ℕ`
- `lipschitzMinorDrift : ℕ → ℤ`
- `ancestralParent : TriplePacket → Option TriplePacket`

At least 10 definitions/structures/instances total.

---

## Main theorem targets

Prove as many of the following as possible, with these names or stronger. The first five are mandatory targets.

### 1. Minor profile invariance under certificate equality
```lean
theorem minorProfile_invariant
  {c₁ c₂ : AncestralCertificate}
  (h : c₁.packet = c₂.packet) :
  minorProfile c₁.packet = minorProfile c₂.packet
```

Strengthen if possible to:
```lean
theorem minorProfile_evalWord_congr
  {w₁ w₂ : BerggrenWord}
  (h : evalWord w₁ rootTriplePacket = evalWord w₂ rootTriplePacket) :
  minorProfile (packetOfWord w₁) = minorProfile (packetOfWord w₂)
```

### 2. Nondegeneracy of packets produced by Berggren words
```lean
theorem packet_nondegenerate
  ∀ w : BerggrenWord, packetNondegenerate (packetOfWord w)
```

This should be proved by induction on `w`, using the Berggren generators’ preservation of positivity, the Pythagorean equation, and gcd-primitive structure. Use `omega`, `linarith`, and arithmetic lemmas on `Int.gcd`.

### 3. Unique parent theorem
```lean
theorem parent_unique
  ∀ {t p₁ p₂ : TriplePacket},
    packetNondegenerate t →
    parentRel p₁ t →
    parentRel p₂ t →
    p₁ = p₂
```

If a direct parent relation already exists in the catalog, reuse it. Otherwise define:
```lean
def parentRel (p t : TriplePacket) : Prop :=
  ∃ g : BerggrenGenerator, evalGen g p = t
```

A stronger and more algorithmic version is encouraged:
```lean
theorem ancestralParent_sound_complete
  ∀ {t : TriplePacket},
    packetNondegenerate t →
    match ancestralParent t with
    | none => t = rootPacket
    | some p => parentRel p t
```

### 4. Explicit bounded-depth collision bound
State an actual quantified bounded injectivity theorem with a concrete bound. If you can only prove exact equality of evaluated packets rather than profiles, then prove profile equality implies packet equality under a side condition.

A recommended shape:
```lean
theorem bounded_depth_collision_bound
  ∀ N : ℕ,
    ∀ ⦃w₁ w₂ : BerggrenWord⦄,
      w₁.length ≤ N →
      w₂.length ≤ N →
      sameMinorProfile (packetOfWord w₁) (packetOfWord w₂) →
      packetOfWord w₁ = packetOfWord w₂
```

Then derive:
```lean
theorem bounded_depth_word_collision_bound
  ∀ N : ℕ,
    ∀ ⦃w₁ w₂ : BerggrenWord⦄,
      w₁.length ≤ N →
      w₂.length ≤ N →
      sameMinorProfile (packetOfWord w₁) (packetOfWord w₂) →
      w₁ = w₂
```

If full profile injectivity is false for your chosen `minorProfile`, enrich the profile by one extra parity/sign/orientation coordinate and prove the theorem for the enriched profile. If needed, state and prove a counterexample for the weaker profile first; that would score originality.

### 5. Correctness of trapdoor recovery
Define a recovery algorithm by repeated parent extraction:
```lean
def recoverWord : TriplePacket → BerggrenWord
```
or bounded:
```lean
def recoverWordAux : ℕ → TriplePacket → Option BerggrenWord
```

Then prove:
```lean
theorem trapdoor_recover_correct
  ∀ w : BerggrenWord,
    recoverWord (packetOfWord w) = w
```
or bounded:
```lean
theorem trapdoor_recover_correct_bounded
  ∀ {N : ℕ} {w : BerggrenWord},
    w.length ≤ N →
    recoverWordAux N (packetOfWord w) = some w
```

This theorem is the cryptographic heart: secret ancestry is recoverable by the holder of the arithmetic trapdoor.

---

## Additional theorem suite required for AEM rigor

Prove at least 10 more theorems beyond the mandatory five, aiming for 20+ total. Suggested names and signatures:

```lean
theorem evalWord_nil :
  evalWord [] t = t

theorem evalWord_append :
  evalWord (u ++ v) t = evalWord v (evalWord u t)

theorem primitive_rootTriplePacket :
  primitiveTriplePacket rootPacket

theorem primitive_preserved_by_gen :
  ∀ g t, primitiveTriplePacket t → primitiveTriplePacket (evalGen g t)

theorem minorProfile_root_explicit :
  minorProfile rootPacket = ...

theorem minorProfile_skew_growth :
  ∀ w, 0 ≤ (minorProfile (packetOfWord w)).skew + bitSizeTriple (packetOfWord w)

theorem generator_expansion_monotone_hypotenuse :
  ∀ g t, packetNondegenerate t → thirdCoord t < thirdCoord (evalGen g t)

theorem depth_strictly_decreases_under_parent :
  ∀ {w}, w ≠ [] →
    certComplexity (certificateOfWord (parentWord w)) < certComplexity (certificateOfWord w)

theorem orbit_separation_quantum_certified :
  ∀ N, depthBoundedCollision N

theorem lattice_minor_entropy_lower_bound :
  ∀ w, w.length ≤ N →
    minorEntropy (minorProfile (packetOfWord w)) ≥ Nat.log2 (w.length + 1)

theorem post_quantum_security_no_short_cycle :
  ∀ w, w ≠ [] → packetOfWord w ≠ rootPacket

theorem tropical_hash_collision_barrier :
  ∀ {w₁ w₂}, sameMinorProfile (packetOfWord w₁) (packetOfWord w₂) →
    quantumResistantDepthScore w₁ = quantumResistantDepthScore w₂ → w₁ = w₂
```

If some of these exact statements are too ambitious, replace them with slightly weaker but precise proved variants. The theorem names should retain explicit application keywords:
- `quantum`
- `post_quantum_security`
- `lattice`
- `certified`
- `trapdoor`
- `collision`
- `robustness`
- `entropy`

---

## Exact proof architecture

### Phase I: Word semantics and algebraic normal form
1. Define `evalGen` and `evalWord`.
2. Prove `evalWord_nil`, `evalWord_cons`, `evalWord_append`.
3. If the catalog contains Berggren matrices in `SL(3, ℤ)`, prove:
   ```lean
   theorem evalWord_matrix_mul :
     matrixOfWord (u ++ v) = matrixOfWord v ⬝ matrixOfWord u
   ```
   and connect matrix action to triple evaluation.
4. Derive positivity and primitivity preservation by each generator.

Most promising tactic mix:
- `induction w with`
- `simp [evalWord]`
- `rcases t with ⟨x,y,z⟩`
- `omega` / `linarith` for positivity and strict growth
- `ring_nf` / `nlinarith` for the Pythagorean identity
- `simpa` using catalog orbit-freeness lemmas

### Phase II: Minor profiles as orbit-separation invariants
1. Compute explicit formulas for `minorProfile (evalGen g t)`.
2. Prove that your chosen profile is sufficiently informative.
3. If the first profile is too coarse, define an enriched profile:
   ```lean
   structure SignedMinorProfile extends MinorProfile where
     parityTag : Fin 2
     orientationTag : Fin 2
   ```
4. Prove:
   ```lean
   theorem signedMinorProfile_injective_on_primitive_orbit :
     ∀ {u v},
       packetNondegenerate u →
       packetNondegenerate v →
       signedMinorProfile u = signedMinorProfile v →
       u = v
   ```
5. Deduce bounded-depth collision results.

Most promising tactic mix:
- `ext <;> simp [minorProfile]`
- `have hx : ... := ...`
- `linarith`
- `omega`
- `by_contra hneq`
- use explicit reconstruction formulas from profile coordinates

A particularly strong route is to choose `minorProfile` so that one can reconstruct:
- `x = (m_xy + m_zx - m_yz) / 2`
- `y = (m_xy + m_yz - m_zx) / 2`
- `z = (m_yz + m_zx - m_xy) / 2`
Then profile injectivity is immediate after parity/divisibility lemmas. This is highly Lean-friendly and gives an explicit “lattice decoding” interpretation.

### Phase III: Parent uniqueness and recovery
1. Define `ancestralParent` by inversion formulas or case distinction on which Berggren generator could have produced the child.
2. Prove existence of a parent for every non-root nondegenerate packet.
3. Prove uniqueness:
   ```lean
   theorem parent_unique ...
   ```
4. Define bounded recursion:
   ```lean
   def recoverWordAux : ℕ → TriplePacket → Option BerggrenWord
   ```
5. Prove termination using strict decrease of the hypotenuse or certificate complexity:
   ```lean
   theorem parent_hypotenuse_drop :
     ∀ {p t}, parentRel p t → thirdCoord p < thirdCoord t
   ```
6. Prove soundness and completeness of recovery, then the main trapdoor theorem.

Most promising tactic mix:
- strong induction on `thirdCoord t.natAbs`
- `match` on `ancestralParent t`
- `have hlt : ... < ... := ...`
- `omega`
- `cases hroot : ancestralParent t <;> simp [recoverWordAux, hroot]`
- use `parent_unique` to identify the recursively recovered branch

### Phase IV: Computational and cryptographic bounds
State and prove explicit complexity bounds, even if simple:
```lean
theorem recoverWordAux_time_O_depth :
  ∀ N t, certComplexityOfInput t ≤ N →
    recoveryCostBound N ≤ C * N + D
```
or a more Lean-manageable arithmetic inequality:
```lean
theorem recoverWordAux_cost_linear :
  ∃ C : ℕ, ∀ N t, costRecover N t ≤ C * N + C
```

Also prove size-growth bounds:
```lean
theorem hypotenuse_exponential_lower_bound :
  ∀ w, 2 ^ w.length ≤ Int.natAbs (thirdCoord (packetOfWord w))
```
or a weaker monotone lower bound sufficient for uniqueness/termination.

This is important: it gives a formalized `O(N)` recovery and `Ω(2^N)` output growth separation, exactly the kind of utility metric that turns a combinatorial construction into a cryptographic toy primitive.

---

## Precise Lean-friendly statements you should try to realize

If using a `TriplePacket` structure:
```lean
def packetOfWord (w : BerggrenWord) : TriplePacket := ...

def thirdCoord (t : TriplePacket) : ℤ := t.z
```

Then target these statements verbatim if possible:

```lean
theorem minorProfile_eq_iff_packet_eq
  {u v : TriplePacket}
  (hu : packetNondegenerate u)
  (hv : packetNondegenerate v) :
  minorProfile u = minorProfile v ↔ u = v
```

```lean
theorem bounded_depth_collision_bound
  (N : ℕ) :
  ∀ {w₁ w₂ : BerggrenWord},
    w₁.length ≤ N →
    w₂.length ≤ N →
    minorProfile (packetOfWord w₁) = minorProfile (packetOfWord w₂) →
    packetOfWord w₁ = packetOfWord w₂
```

```lean
theorem bounded_depth_word_collision_bound
  (N : ℕ) :
  ∀ {w₁ w₂ : BerggrenWord},
    w₁.length ≤ N →
    w₂.length ≤ N →
    minorProfile (packetOfWord w₁) = minorProfile (packetOfWord w₂) →
    w₁ = w₂
```

```lean
theorem trapdoor_recover_correct
  : ∀ w : BerggrenWord, recoverWord (packetOfWord w) = w
```

```lean
theorem trapdoor_public_key_injective_bounded
  (N : ℕ) :
  Function.Injective fun w : {w : BerggrenWord // w.length ≤ N} =>
    minorProfile (packetOfWord w.1)
```

And a certified robustness style theorem:
```lean
theorem certified_lipschitz_minor_drift
  ∀ g t,
    packetNondegenerate t →
    Int.natAbs ((minorProfile (evalGen g t)).skew - (minorProfile t).skew)
      ≤ lipschitzMinorDrift 1
```

This explicitly bridges arithmetic dynamics to certified robustness / Lipschitz analysis.

---

## Cross-domain bridge requirements

Your doc comments and theorem names should make the following bridges explicit:

1. **Cryptography ↔ Arithmetic dynamics**
   - Berggren words as secret keys
   - minor profiles as public keys / hashes
   - bounded-depth injectivity as collision resistance

2. **Lattice methods ↔ Integer geometry**
   - reconstruction from linear minor coordinates
   - parity/divisibility constraints as lattice decoding certificates

3. **Certified ML robustness ↔ Orbit separation**
   - Lipschitz drift bounds for profile updates
   - stability of profile under bounded generator perturbations

4. **Physics / thermodynamic language**
   - define a toy `minorEntropy`
   - prove monotonicity or lower bounds along nontrivial words if possible

Suggested doc comment phrases:
- `Bridge: connects primitive Pythagorean orbits to post_quantum_security via certified orbit separation.`
- `Bridge: interprets minor reconstruction as a lattice decoding primitive.`
- `Bridge: exports arithmetic growth to a certified robustness / entropy estimate.`

---

## Strong fallback plan if global trapdoor recovery is too hard

If exact recovery for arbitrary words is blocked by missing infrastructure, do not stop. Instead prove the finite-depth certified version:

1. Define
```lean
def enumerateWords (N : ℕ) : Finset BerggrenWord := ...
```
2. Define a lookup-based recovery:
```lean
def recoverWordBySearch (N : ℕ) (p : MinorProfile) : Option BerggrenWord := ...
```
3. Prove:
```lean
theorem recoverWordBySearch_sound
theorem recoverWordBySearch_complete
theorem trapdoor_recover_correct_bounded
theorem bounded_search_cost_O_three_pow :
  ∀ N, searchCost N ≤ 3 ^ N
```

This still yields a nontrivial certified trapdoor theorem with explicit `O(3^N)` search complexity and exact correctness on the bounded Berggren subtree. That is entirely acceptable and mathematically meaningful.

---

## Tactical diversity mandate inside the file

Ensure the proofs genuinely use diverse tactics and not just `simp`:
- induction on words / depth
- `rcases` on packets and certificates
- `ext` for structure equality
- `by_contra` for injectivity / uniqueness
- `omega` for length/depth arithmetic
- `linarith` / `nlinarith` for integer inequalities
- `ring_nf` / `noncomm_ring` if matrix formulas appear
- `field_simp` if you use reconstruction formulas with halves and then clear denominators
- `have`, `calc`, `constructor`, `aesop?` only as support, not as the main proof method

At least one theorem should use each of:
- induction
- contradiction
- explicit witness construction (`refine ⟨...⟩`)
- arithmetic normalization (`ring_nf` or `nlinarith`)
- finite search / `Finset` reasoning

---

## Significance to the research program

The file should not read as an isolated exercise. It should formalize a new paradigm: an arithmetic-dynamical trapdoor primitive with certified recovery and bounded collision resistance, avoiding isogenies entirely while retaining the “secret path in a structured orbit” intuition. This is a plausible toy precursor to post-quantum constructions from integer orbits and tree actions.

What matters is not only the main theorem but the infrastructure:
- a formal language for Berggren words as cryptographic secrets,
- minor profiles as low-dimensional public summaries,
- certified parent recovery as trapdoor inversion,
- entropy/growth bounds as evidence of expanding arithmetic dynamics,
- Lipschitz-style profile control as a bridge to certified robustness and ML verification.

This opens at least three future lines:
- richer orbit invariants from actual matrix minors in `SL(3, ℤ)`,
- average-case collision bounds and entropy amplification,
- transfer of these ideas to other arithmetic trees, Markov triples, or tropicalized dynamics.

---

## Deliverables inside the file

Produce a substantial file, not a stub:
- 10+ definitions / structures / instances
- 20+ theorems / lemmas
- zero sorries
- explicit examples computed for short words `[A]`, `[B]`, `[C]`, `[A,B]`
- at least one theorem with an explicit complexity bound like linear recovery cost or `3^N` bounded search
- doc comments that explicitly include keywords:
  `quantum`, `post_quantum_security`, `cryptographic`, `lattice`, `certified`, `entropy`, `robustness`

At the end, include a precise conjecture section if needed, for example:
```lean
/-- Conjecture: global minor-profile injectivity on the full primitive Berggren orbit,
a candidate post_quantum_security strengthening beyond bounded-depth certified recovery. -/
def GlobalMinorTrapdoorConjecture : Prop := ...
```
and prove all consequences that follow from it conditionally, clearly separated from unconditional results.

Also produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, including at least:
1. replacing synthetic minor profiles by genuine matrix minors,
2. average-case collision exponents / entropy growth,
3. extension to Markov-type or tropical orbit trapdoors,
4. certified robustness interpretation for arithmetic hash families,
5. possible quantum-resistant public-key abstractions from orbit separation.

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
            Develop a post-quantum cryptographic primitive built from Berggren-tree generated primitive Pythagorean triples by encoding public keys as low-dimensional lattice minor profiles of bounded orbit packets and proving a trapdoor inversion/separation result from unique parent decomposition and orbit freeness. The central mathematical goal is to show that finitely generated Berggren orbit packets admit canonically recoverable ancestral certificates from secret branch words, while their public minor invariants are efficiently computable yet collision-resistant within bounded depth under explicit orbit-separation inequalities. This extends the recently productive Berggren matrix groupoid work, but moves into a different domain combination than current inflight jobs and avoids repeating the already explored Berggren–lattice reduction correspondence by focusing on lattice minors, ancestral certification, and cryptographic one-wayness rather than reduction equivalence.

            ### Precise Mathematical Framing
            Let A,B,C ∈ SL(3,ℤ) be the Berggren generators acting on primitive triples, and let w range over words in {A,B,C}. For a root primitive triple t0, define the secret key as a branch word w of depth n and the derived triple tw = w • t0. From a bounded packet P(w,k) consisting of k selected descendants/ancestors of tw, form a public invariant M(P) given by ordered gcd-normalized 2×2 minors, parity signatures, and norm-growth strata of the corresponding integer vectors. Prove: (1) orbit-packet freeness and parent uniqueness imply canonical secret reconstruction from full ancestral certificates; (2) the public invariant is stable under packet enumeration order and computable in polynomial time; (3) within any fixed depth window, equal public invariants force strong ancestral overlap, yielding explicit collision bounds; (4) a recovery algorithm with trapdoor access reconstructs w from certificate data, while without the trapdoor inversion reduces to solving a constrained orbit-separation problem on Berggren minors. This opens a concrete pipeline toward a formally specified Berggren-hash / Berggren-PKE family using arithmetic dynamics rather than lattices or isogenies. The likely Lean path is to formalize packet invariants, prove invariance under canonical enumeration, establish minor nondegeneracy and separation lemmas from primitive-triple coprimality, and derive bounded-depth injectivity theorems for selected packet classes.

            ### Lean 4 Sketch
Likely file under Bridges/CryptographyPythagorean/BerggrenMinorTrapdoors. Define BerggrenWord, evalWord, primitiveTriplePacket, minorProfile, ancestralCertificate, and prove lemmas minorProfile_invariant, packet_nondegenerate, parent_unique, bounded_depth_collision_bound, trapdoor_recover_correct.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `post_quantum_security_residual_collision_bound` : theorem post_quantum_security_residual_collision_bound (N : ℕ) :
     (file: Bridges/BerggrenResidualAutomata.lean)
  2. `post_quantum_lattice_skeleton_cover_bound` : theorem post_quantum_lattice_skeleton_cover_bound (S : PadicSkeletonRegion K) :
     (file: Bridges/PadicOperadicNetworks.lean)
  3. `post_quantum_security_separation_existence` : theorem post_quantum_security_separation_existence
     (file: Bridges/613c6a31_aristotle/Bridges/TropicalAutomataComplexity/TropicalNerode.lean)
  4. `berggren_post_quantum_leftover_hash_extractor` : theorem berggren_post_quantum_leftover_hash_extractor
     (file: Bridges/BerggrenEntropyExtractor.lean)
  5. `post_quantum_closure_hash_stable_under_idempotent_round` : theorem post_quantum_closure_hash_stable_under_idempotent_round
     (file: Bridges/ClosureKoopmanReconstruction.lean)

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



Recent successful concepts: MachineLearning–Speculative Ultrametric Proof Dynamics via p-adic Neural Compression and Diagonal Stability, Algebra–MachineLearning Coalgebraic Myhill–Nerode Semantics for Neural State Compression, Algebra–Speculative Cobham Invariance for Oracle-Trace Semirings via Prefix Ultrametrics and Rational Trace Transductions


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

            7. **PACKAGE.json** — MANDATORY JSON Data Package
               Bundle ALL artifacts into a single JSON file for the web frontend:
               • Output a strictly valid JSON object:
                 {
                   "title": "Title", "domain": "Domain",
                   "article": "Markdown content...",
                   "research_paper": "Markdown content...",
                   "future_directions": "Markdown content...",
                   "demos": [ { "name": "...", "code": "..." } ],
                   "algorithms": [ { "name": "...", "pseudocode": "..." } ],
                   "visualizations": [ { "name": "...", "data": "base64 URI or inline SVG" } ],
                   "lean_proofs": "Raw lean code..."
                 }
               • Ensure all Markdown and code is properly JSON-escaped.
               • ALL images MUST be embedded as base64 data URIs or inline SVG within the `data` field.
                 If you generate matplotlib/plotly charts, convert to base64.
                 NEVER reference external image files — they won't exist standalone.
               • This JSON file powers the dynamic web UI. Include ALL content.

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
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "..." } ],
    "algorithms": [ { "name": "...", "pseudocode": "..." } ],
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: formalize
