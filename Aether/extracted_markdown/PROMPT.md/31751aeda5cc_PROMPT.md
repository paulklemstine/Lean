

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

## YOUR ASSIGNMENT: Berggren–Farey Correspondence: Free Monoid Structure, PSL(2,ℤ) Faithfulness, and Continued Fraction Descent Encoding for Primitive Pythagorean Triples

**DOMAIN**: Pythagorean × Modular Group × Computational Number Theory

**CONCEPT**: Prove the complete Berggren–Farey correspondence establishing a tripartite bridge: (1) The Berggren monoid ⟨A,B,C⟩ is free — no non-trivial relations among the three generators — which is equivalent to (2) the representation ι: ⟨A,B,C⟩ → SL(2,ℤ) via A↦pA=[[2,−1],[1,0]], B↦pB=[[2,1],[1,0]], C↦pC=[[1,2],[0,1]] being injective (faithful), and (3) for every primitive Pythagorean triple (a,b,c) with Farey fraction q=b/(a+c)=n/m in lowest terms, the Berggren descent path from (a,b,c) to (3,4,5) encodes the continued fraction expansion of q — each A⁻¹-step (via pA⁻¹=[[0,1],[−1,2]]) performs a Euclidean inversion and each C⁻¹-step (via pC⁻¹=[[1,−2],[0,1]]) performs a Euclidean translation, exactly matching the continued fraction algorithm on (m,n), which terminates at (m,n)=(2,1)↔q=1/2↔(3,4,5). This opens the field of **modular Pythagorean geometry** — studying Diophantine equations via the modular surface — with direct applications to lattice-based post-quantum cryptography (the faithful SL(2,ℤ)-action on ℤ² gives certified word problem certificates) and certified robustness in discrete ML classifiers (descent paths certify membership in the primitive triple manifold with O(log c) verification).

---

### PRECISE ASSIGNMENT: Formalize and Prove the Berggren–Farey Correspondence

Build a complete theory file `BerggrenFareyCorrespondence.lean` (target: 500+ lines, 20+ theorems, 10+ definitions) establishing the following results with ZERO sorries.

---

### REQUIRED DEFINITIONS (5+ new, with precise Lean 4 signatures)

```lean
/-- The three Berggren generators as a finite type -/
inductive BerggrenLetter where
  | A : BerggrenLetter
  | B : BerggrenLetter
  | C : BerggrenLetter
deriving DecidableEq, Repr

/-- A Berggren word is a finite sequence of generators -/
abbrev BerggrenWord := List BerggrenLetter

/-- The 2×2 integer matrix associated to each Berggren letter.
    Bridge: connects Pythagorean triples to SL(2,ℤ) lattice automorphisms. -/
def berggrenLetterMatrix : BerggrenLetter → Matrix (Fin 2) (Fin 2) ℤ
  | .A => !![2, -1; 1, 0]
  | .B => !![2, 1; 1, 0]
  | .C => !![1, 2; 0, 1]

/-- The monoid homomorphism from the free monoid on Berggren letters
    to SL(2,ℤ). This is the representation whose faithfulness we prove.
    Bridge: connects free monoid theory to matrix groups. -/
def berggrenRep (w : BerggrenWord) : Matrix (Fin 2) (Fin 2) ℤ :=
  (berggrenLetterMatrix ∘ Subtype.val) <$> w |>.foldl (· * ·) 1
  -- More precisely: fold over the list, multiplying matrices

/-- A descent step in the Berggren tree: either apply A⁻¹ or C⁻¹.
    The B⁻¹ step is never needed in the standard descent.
    Bridge: connects tree descent to Euclidean algorithm steps. -/
inductive BerggrenDescentStep where
  | A_inv : BerggrenDescentStep  -- Euclidean inversion: [[0,1],[-1,2]]
  | C_inv : BerggrenDescentStep  -- Euclidean translation: [[1,-2],[0,1]]

/-- The Farey fraction of a primitive Pythagorean triple (a,b,c):
    q = b / (a + c). Always lies in (0, 1/2) for primitive triples.
    Bridge: connects Pythagorean parameterization to Farey sequences. -/
def fareyFraction (a b c : ℕ) (h : a^2 + b^2 = c^2) : ℚ :=
  (b :ℚ) / ((a + c : ℕ) : ℚ)

/-- Certificate of Berggren descent: a verified path from any primitive
    triple back to (3,4,5), with continued fraction encoding.
    Application: lattice_crypto certified membership in primitive triple set. -/
structure BerggrenDescentCert where
  triple : ℕ × ℕ × ℕ
  path : List BerggrenDescentStep
  triple_is_ppt : IsPrimitiveTriple triple.1 triple.2.1 triple.2.2
  descent_valid : descentPreservesTriple path triple (3, 4, 5)
  cf_match : cfEncode path = cfExpand (fareyFraction triple.1 triple.2.1 triple.2.2 triple_is_ppt.pythag)
  deriving Repr
```

---

### REQUIRED THEOREMS (10+, with proof strategies)

**THEOREM 1: Berggren matrices lie in SL(2,ℤ)**
```lean
/-- Each Berggren generator has determinant 1, hence lies in SL(2,ℤ).
    This establishes the representation lands in the special linear group. -/
theorem berggren_det_one (l : BerggrenLetter) :
    (berggrenLetterMatrix l).det = 1 := by
  -- Proof: direct computation for each constructor using matrix det formula
  -- cases l <;> simp [berggrenLetterMatrix, Matrix.det_fin_two]
  -- For A: det = 2*0 - (-1)*1 = 1
  -- For B: det = 2*0 - 1*1 = -1... WAIT
```

**CRITICAL CORRECTION**: Let me verify: pB = [[2,1],[1,0]], det = 2·0 − 1·1 = −1. So pB has determinant −1, not 1! This means pB ∈ GL(2,ℤ) \ SL(2,ℤ). The representation lands in GL(2,ℤ), not SL(2,ℤ). Adjust all signatures accordingly.

```lean
theorem berggren_det (l : BerggrenLetter) :
    (berggrenLetterMatrix l).det = match l with
      | .A => 1 | .B => -1 | .C => 1 := by
  -- cases l <;> rfl  -- after unfolding matrix det_fin_two
```

**THEOREM 2: Products preserve determinant**
```lean
/-- The determinant of a Berggren word's matrix is (−1)^(#B's in word).
    Bridge: connects word combinatorics to determinant theory. -/
theorem berggren_rep_det (w : BerggrenWord) :
    (berggrenRep w).det = (-1 : ℤ) ^ (w.count BerggrenLetter.B) := by
  -- Proof strategy: induction on the list w
  -- Base: empty word → identity matrix → det = 1 = (-1)^0
  -- Step: berggrenRep (l :: w) = berggrenLetterMatrix l * berggrenRep w
  -- Use det_mul and berggren_det
  -- Key lemma: count_cons for the B-count
```

**THEOREM 3: FAITHFULNESS — The representation is injective (FREE MONOID)**
```lean
/-- MAIN THEOREM: The Berggren representation is faithful.
    Different words produce different matrices.
    This proves ⟨A,B,C⟩ is a free monoid.
    Bridge: connects free monoid theory to GL(2,ℤ) representation theory.
    Application: lattice_crypto word problem certificates. -/
theorem berggren_faithful (w₁ w₂ : BerggrenWord) :
    berggrenRep w₁ = berggrenRep w₂ → w₁ = w₂ := by
```

**PROOF STRATEGY for berggren_faithful** (3 approaches, ranked by promise):

*Strategy A (CHOSEN — most direct)*: **Column vector tracking**. Define a "signature" function `σ : BerggrenWord → Fin 2 → ℤ × ℤ` that maps each word to the image of the standard basis vectors under the corresponding matrix. Show that the signature uniquely determines the word by structural induction on the word, using the key invariant that the column vectors of `berggrenRep w` satisfy a specific "reduced form" property (analogous to reduced words in free groups). Key lemma:

```lean
/-- Key lemma: the first column of a Berggren word matrix
    satisfies a strict positivity condition that encodes the word. -/
theorem berggren_first_column_pos (w : BerggrenWord) (h : w ≠ []):
    0 < (berggrenRep w) 0 0 ∧ 0 ≤ (berggrenRep w) 1 0 := by
  -- induction on w
```

*Strategy B*: **Action on the upper half-plane**. The matrices act on ℍ = {z : ℂ | z.im > 0} via Möbius transformations. Show that different words move the base point i ∈ ℍ to different points. This is geometrically intuitive but requires developing the Möbius action theory.

*Strategy C*: **Normal form via word reduction**. Develop a confluent rewriting system on Berggren words (analogous to the standard presentation of PSL(2,ℤ) = ⟨S,T | S²=(ST)³=I⟩) and show that each word has a unique normal form. Express pA, pB, pC in terms of S and T: pC = T², pA = T²S, and derive pB from these. Then faithfulness follows from the free product structure of PSL(2,ℤ). This is the most theoretically illuminating but requires substantial infrastructure.

**I recommend Strategy A with elements of C**: Track column vectors directly (Strategy A), but use the PSL(2,ℤ) presentation (Strategy C) to organize the proof that the signature is injective. The key insight is that in the free product ℤ/2 ∗ ℤ/3, reduced words are unique, and the Berggren words correspond to a specific set of reduced words.

**THEOREM 4: Farey fraction lies in (0, 1/2)**
```lean
/-- For any primitive Pythagorean triple (a,b,c) with a odd,
    the Farey fraction q = b/(a+c) satisfies 0 < q < 1/2.
    Explicit bounds: q ∈ (1/(c+1), 1/2 - 1/(2c²)).
    Bridge: connects Diophantine geometry to Farey sequence theory. -/
theorem farey_fraction_bounds {a b c : ℕ} (h : a^2 + b^2 = c^2)
    (hprim : a.gcd b = 1) (ha : Odd a) (hpos : 0 < a) :
    (0 : ℚ) < fareyFraction a b c h ∧
    fareyFraction a b c h < 1/2 := by
  -- Proof: b > 0 gives lower bound. For upper bound: b/(a+c) < 1/2
  -- iff 2b < a + c iff 2b < a + √(a²+b²) iff (2b-a)² < a²+b²
  -- iff 4b²-4ab+a² < a²+b² iff 3b² < 4ab iff 3b < 4a
  -- Since a²+b²=c² and a odd, b even, we get a ≥ 3, b ≥ 4
  -- and 3·4 = 12 < 4·3 = 12... borderline. Need careful analysis.
  -- Actually: for a=3,b=4: q = 4/7 ≈ 0.571... wait, 4/7 > 1/2!
  -- CORRECTION: need to re-examine the Farey fraction definition.
```

**CRITICAL CORRECTION**: The standard Farey fraction for Pythagorean triples uses q = b/(a+c). For (3,4,5): q = 4/8 = 1/2. So q ≤ 1/2 with equality only at the root. The bound should be 0 < q ≤ 1/2.

```lean
theorem farey_fraction_le_half {a b c : ℕ} (h : a^2 + b^2 = c^2)
    (hprim : a.gcd b = 1) (hpos : 0 < b) :
    fareyFraction a b c h ≤ 1/2 := by
  -- b/(a+c) ≤ 1/2 iff 2b ≤ a+c
  -- Since c² = a²+b² and c ≥ a, we have c ≥ a
  -- So a+c ≥ 2a ≥ 2b when a ≥ b. But a can be < b...
  -- Need: 2b ≤ a + c. Since c = √(a²+b²) ≥ b, we get a+c ≥ a+b.
  -- And 2b ≤ a+b iff b ≤ a. But if b > a, then swap.
  -- Key: for primitive triples, either a or b is the leg < c.
  -- Use c² = a²+b² > a² so c > a, and c² > b² so c > b.
  -- Then a+c > 2a and a+c > 2b, so b/(a+c) < 1 iff b < a+c (true).
  -- For ≤1/2: need 2b ≤ a+c, i.e., (2b-a)² ≤ c² = a²+b²
  -- i.e., 4b²-4ab+a² ≤ a²+b², i.e., 3b² ≤ 4ab, i.e., 3b ≤ 4a.
  -- For (3,4,5): 3·4 = 12 = 4·3. Equality! So q = 1/2 exactly at root.
```

**THEOREM 5: Descent terminates at (3,4,5)**
```lean
/-- Every primitive Pythagorean triple descends to (3,4,5) via the
    Berggren descent. The descent length is at most ⌈log₂(c)⌉.
    Bridge: connects Pythagorean tree to algorithm termination theory.
    Application: certified_robustness — O(log c) verification path. -/
theorem descent_terminates_at_root {a b c : ℕ} (h : a^2 + b^2 = c^2)
    (hprim : a.gcd b = 1) (hc : 3 ≤ c) :
    ∃ (path : List BerggrenDescentStep),
      descentPathResult path (a, b, c) = (3, 4, 5) ∧
      path.length ≤ Int.log2 c + 1 := by
  -- Proof: strong induction on c
  -- Base: c = 5, (3,4,5) is the root, path = []
  -- Step: c > 5, find which child subtree we're in
  -- Apply appropriate inverse matrix, get triple with smaller c'
  -- Key lemma: c' < c for each descent step
```

**THEOREM 6: Descent step decreases hypotenuse**
```lean
/-- Each Berggren descent step strictly decreases the hypotenuse.
    This is the well-founded measure for termination.
    Explicit bound: c' ≤ ⌊(c+1)/2⌋ for A⁻¹ steps. -/
theorem descent_step_decreases_hypotenuse {a b c : ℕ}
    (h : a^2 + b^2 = c^2) (step : BerggrenDescentStep)
    (hvalid : descentStepValid step (a, b, c))
    {a' b' c' : ℕ} (h' : a'^2 + b'^2 = c'^2)
    (heq : applyDescentStep step (a,b,c) = (a',b',c')) :
    c' < c ∧ c' ≤ (c + 1) / 2 := by
  -- For A⁻¹ step: new triple from [[0,1],[-1,2]] action
  -- Direct computation with the matrix
  -- Key: the new hypotenuse c' satisfies c'² = (a'² + b'²)
  -- and c' < c follows from the tree structure
```

**THEOREM 7: Continued fraction encoding is sound**
```lean
/-- The continued fraction encoding of the descent path matches
    the actual CF expansion of the Farey fraction.
    Bridge: connects Pythagorean descent to Diophantine approximation.
    Application: post_quantum_security — CF-based hash preimage resistance. -/
theorem cf_encoding_sound {a b c : ℕ} (h : a^2 + b^2 = c^2)
    (hprim : a.gcd b = 1) (path : List BerggrenDescentStep)
    (hdescent : descentPathResult path (a, b, c) = (3, 4, 5)) :
    cfEncode path = cfExpand (fareyFraction a b c h) := by
  -- Proof: induction on the descent path
  -- Base: empty path → triple is (3,4,5) → q = 1/2 → CF = [0; 2]
  -- Step: A⁻¹ step corresponds to Euclidean inversion in CF algorithm
  --       C⁻¹ step corresponds to Euclidean translation in CF algorithm
  -- Key lemma: matrix action on Farey fraction matches CF step
```

**THEOREM 8: Word problem solvability in O(n)**
```lean
/-- The word problem for the Berggren monoid is solvable in O(n)
    where n is the word length, via matrix comparison.
    Bridge: connects combinatorial group theory to computational complexity.
    Application: lattice_crypto — efficient group-theoretic hash functions. -/
theorem berggren_word_problem_linear (w₁ w₂ : BerggrenWord) :
    decideEq w₁ w₂ = (berggrenRep w₁ = berggrenRep w₂) ∧
    (berggrenRep w₁).sizeLessThan (4 * max w₁.length w₂.length + 1) := by
  -- Faithfulness gives logical equivalence
  -- Matrix entries grow at most exponentially in word length
  -- But size is bounded by 2^(n+1) which fits in O(n) bits... 
  -- Actually, entries can grow exponentially, so comparison is O(n·M(n))
  -- where M(n) is multiplication time for n-bit numbers
```

**THEOREM 9: Lattice action preserves gcd structure**
```lean
/-- The Berggren representation acts faithfully on ℤ² and preserves
    the gcd of the column vector. For any word w with B-count even,
    the image of (1,0)ᵀ has coprime entries.
    Bridge: connects lattice geometry to Pythagorean coprimality.
    Application: certified_robustness — lattice point certification. -/
theorem berggren_lattice_coprime (w : BerggrenWord)
    (hEven : Even (w.count BerggrenLetter.B)) :
    ((berggrenRep w) 0 0).gcd ((berggrenRep w) 1 0) = 1 := by
  -- Proof: induction on w
  -- Base: identity matrix, columns (1,0) and (0,1), gcd = 1
  -- Step: multiplication by SL(2,ℤ) matrix preserves gcd
  -- (since det = 1 implies the matrix is a unimodular transformation)
  -- For B-words (det = -1): still in GL(2,ℤ) with det = ±1, preserves gcd
```

**THEOREM 10: Descent uniqueness**
```lean
/-- The Berggren descent path from any primitive triple to (3,4,5) is unique.
    This is equivalent to the tree structure of the Berggren tree.
    Bridge: connects graph theory (tree uniqueness) to Pythagorean geometry.
    Application: certified_robustness — unique verification path. -/
theorem descent_path_unique {a b c : ℕ} (h : a^2 + b^2 = c^2)
    (hprim : a.gcd b = 1) :
    ∀ (p₁ p₂ : List BerggrenDescentStep),
      descentPathResult p₁ (a, b, c) = (3, 4, 5) →
      descentPathResult p₂ (a, b, c) = (3, 4, 5) →
      p₁ = p₂ := by
  -- Proof: each triple has at most one valid parent in the tree
  -- The inverse matrices A⁻¹, C⁻¹ are uniquely determined by
  -- which subtree the triple belongs to
  -- Key lemma: the three subtrees are disjoint
```

**THEOREM 11: Bijectivity between triples and CF encodings**
```lean
/-- The Berggren–Farey correspondence is a bijection:
    primitive Pythagorean triples ↔ finite CF expansions terminating at 1/2.
    This is the main structural theorem of modular Pythagorean geometry.
    Bridge: connects Diophantine equations to modular forms.
    Application: post_quantum_security — CF-based encoding for lattice problems. -/
theorem berggren_farey_bijection :
    ∃ (f : PPT → List ℕ) (g : List ℕ → Option PPT),
      ∀ (t : PPT), g (f t) = some t ∧
      ∀ (cf : List ℕ), cfTerminatesAtHalf cf → ∃ (t : PPT), f t = cf := by
  -- Construction: f = cfEncode ∘ descentPath
  -- g = tripleFromCF (reconstruct by running CF in reverse via Berggren matrices)
  -- Proof of bijection uses descent_terminates_at_root and descent_path_unique
```

**THEOREM 12: Matrix entry growth rate**
```lean
/-- The entries of berggrenRep w grow at most like the Fibonacci numbers.
    Explicit bound: |(berggrenRep w) i j| ≤ F_{|w|+2} where F_n is the n-th
    Fibonacci number. This gives O(φ^n) growth where φ = (1+√5)/2.
    Bridge: connects matrix growth to analytic number theory.
    Application: lattice_crypto — key size bounds for Berggren-based crypto. -/
theorem berggren_entry_fibonacci_bound (w : BerggrenWord) (i j : Fin 2) :
    |(berggrenRep w) i j| ≤ fib (w.length + 2) := by
  -- Proof: induction on w
  -- Each Berggren matrix has entries ≤ 2
  -- Matrix multiplication: new entries bounded by 2·max + 2·max
  -- This gives Fibonacci-like recurrence: M(n) ≤ 2·M(n-1) + 2·M(n-1) ... 
  -- Actually need more careful analysis per matrix
  -- Key: entries of Berggren matrices are in {0, 1, 2, -1, -2}
  -- so |new_entry| ≤ 2·|old₁| + 2·|old₂| ≤ 4·max(old)
  -- This gives M(n) ≤ 4·M(n-1), so M(n) ≤ 4^n
  -- But Fibonacci bound is tighter: each step multiplies by matrix with max entry 2
  -- so growth is at most like 2^n... need to refine
```

---

### PROOF ARCHITECTURE: Three-Phase Strategy

**Phase 1 — Matrix Infrastructure** (Theorems 1, 2, 12):
Establish that Berggren matrices lie in GL(2,ℤ), compute their determinants, and bound entry growth. Build on `det_pA`, `pA_root`, `pB_root`, `pC_root` from the catalog. Key tactic: `simp [Matrix.det_fin_two]`, `omega`, direct computation.

**Phase 2 — Faithfulness and Lattice Action** (Theorems 3, 8, 9):
Prove the representation is injective using column-vector tracking. This is the hardest theorem. Break it into lemmas:
- `berggren_column_signature_injective`: different words give different first columns
- `berggren_word_reduction`: develop a normal form by analyzing how A, B, C act on column vectors
- `berggren_faithful`: combine the above

Key tactics: `induction w with`, `rcases`, `by_contra h`, `omega` for integer arithmetic.

**Phase 3 — Descent and Continued Fractions** (Theorems 4, 5, 6, 7, 10, 11):
Connect the Berggren tree descent to continued fractions. Define the Farey fraction map, prove it lands in (0, 1/2], show descent terminates with the O(log c) bound, and prove the CF encoding is both sound and complete. Key tactics: `strong_induction`, `field_simp`, `linarith`, `omega`.

---

### CROSS-DOMAIN BRIDGES (must appear in doc comments)

1. **Pythagorean ↔ Modular Group**: The Berggren matrices live in GL(2,ℤ) and their action on ℤ² encodes the tree structure. This connects Diophantine equations to the modular group PSL(2,ℤ).

2. **Free Monoid ↔ Lattice Cryptography**: The faithful representation means the word problem for ⟨A,B,C⟩ is decidable in O(n·M(n)) time, giving efficient certificates for lattice-based cryptographic primitives. The O(φ^n) entry growth bounds key sizes for post-quantum lattice crypto schemes.

3. **Continued Fractions ↔ Certified Robustness**: The descent path provides a O(log c)-length certificate that a triple is primitive Pythagorean. In ML, this gives certified robustness for discrete classifiers: verifying membership in a structured set via a short proof path.

4. **Euclidean Algorithm ↔ Thermodynamic Descent**: The continued fraction descent is an entropy-decreasing process (each step reduces the "energy" c), connecting to thermodynamic relaxation in statistical mechanics.

---

### APPLICATION KEYWORDS (must appear in theorem names or doc comments)

- `lattice_crypto` — Theorem 8 (word problem), Theorem 9 (coprime preservation), Theorem 12 (entry bounds)
- `post_quantum_security` — Theorem 7 (CF encoding), Theorem 11 (bijection)
- `certified_robustness` — Theorem 5 (descent termination), Theorem 10 (descent uniqueness)
- `hamiltonian_descent` — Theorem 6 (energy decrease), connecting to thermodynamic relaxation

---

### BUILDING ON CATALOG INFRASTRUCTURE

- `step_preserves_eta`: Use this to show that descent steps preserve the key invariant η = b/(a+c) mapping to the Farey fraction
- `pA_root`, `pB_root`, `pC_root`: Use these characteristic polynomial roots to analyze the spectral properties of the Berggren matrices (eigenvalues of pA are 1 and 1, pB eigenvalues are 1 and -1, etc.)
- `det_pA`: Extend to compute det_pB and det_pC, then generalize to `berggren_det`

---

### EXPLICIT COMPUTATIONAL BOUNDS (required for UTILITY scoring)

- Descent path length: ≤ ⌈log₂(c)⌉ (Theorem 5)
- Matrix entry growth: |Mᵢⱼ(w)| ≤ 4^|w| (Theorem 12, refinable to O(φ^|w|))
- Word problem decision: O(|w| · M(|w|)) where M(n) is n-bit integer multiplication (Theorem 8)
- CF encoding length: equals descent path length, hence O(log c) (Theorem 7)

---

### DEMAND: FUTURE_DIRECTIONS.md

After completing the above, produce a structured `FUTURE_DIRECTIONS.md` with 3-5 concrete breakthrough-level next steps, including:

1. **Tropical Berggren Theory**: Define tropical Berggren matrices over the min-plus semiring and prove a tropical version of the faithfulness theorem. This connects to tropical geometry and tropical hash collision resistance.

2. **Quantum Berggren Circuits**: The Berggren matrices are 2×2 unitaries (up to normalization). Construct quantum circuits implementing Berggren word evaluation and prove circuit complexity bounds. This connects to quantum computing and Hamiltonian simulation.

3. **Berggren–Satake Correspondence**: Extend the Berggren–Farey bijection to higher-dimensional Pythagorean structures (Pythagorean quadruples, n-tuples) via the Satake transform. This opens the field of modular higher-dimensional Diophantine geometry.

4. **Certified Neural Pythagorean Classifier**: Use the O(log c) descent certificates to build a provably robust neural network classifier for primitive Pythagorean triples with certified Lipschitz bounds.

5. **Post-Quantum Berggren Key Exchange**: Design a key exchange protocol based on the word problem in the Berggren monoid modulo a congruence subgroup of SL(2,ℤ), with provable security reduction to the shortest vector problem.

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
            Prove the complete Berggren–Farey correspondence: (1) The Berggren monoid ⟨A,B,C⟩ is free (no non-trivial relations among the three generators), (2) the representation ι: ⟨A,B,C⟩ → GL(2,ℤ) via A↦pA=[[2,-1],[1,0]], B↦pB=[[2,1],[1,0]], C↦pC=[[1,2],[0,1]] is injective (faithful), and (3) for every primitive Pythagorean triple (a,b,c) with Farey fraction q=b/(a+c)=n/m in lowest terms, the Berggren descent path from (a,b,c) to (3,4,5) encodes the continued fraction expansion of q — each A⁻¹-step (via pA⁻¹=[[0,1],[-1,2]]) performs a Euclidean inversion and each C⁻¹-step (via pC⁻¹=[[1,-2],[0,1]]) performs a translation, exactly matching the continued fraction algorithm on (m,n), which terminates at (m,n)=(2,1)↔q=1/2↔(3,4,5). This opens the field of modular Pythagorean geometry — studying Diophantine equations via the modular surface.

            ### Precise Mathematical Framing
            Let PPT = {(a,b,c) ∈ ℕ³ : a²+b²=c², gcd(a,b)=1, a odd} be the set of primitive Pythagorean triples. The Berggren matrices A=[[1,-2,2],[2,-1,2],[2,-2,3]], B=[[1,2,2],[2,1,2],[2,2,3]], C=[[-1,2,2],[-2,1,2],[-2,2,3]] act on PPT via (a,b,c)ᵀ ↦ M·(a,b,c)ᵀ. Their 2×2 projections pA=[[2,-1],[1,0]], pB=[[2,1],[1,0]], pC=[[1,2],[0,1]] act on the Farey fraction parameterization (m,n) via (m,n)ᵀ ↦ pM·(m,n)ᵀ. The key theorems are: (T1) FREE_MONOID: For any two distinct words w₁,w₂ ∈ {A,B,C}*, the products M_{w₁} ≠ M_{w₂} as matrices (equivalently, the Berggren tree has no non-trivial automorphisms). (T2) FAITHFUL_2D: The map ι is injective; equivalently, pA^{k₁}·pB^{k₂}·pC^{k₃} uniquely determines the word. (T3) CF_ENCODING: For (a,b,c) ∈ PPT with q=b/(a+c), if the Berggren descent applies C⁻¹ exactly r₁ times, then A⁻¹, then C⁻¹ r₂ times, etc., reaching (3,4,5), then q = 1/(r₁ + 1/(r₂ + 1/(...))) is the continued fraction [0;r₁,r₂,...,r_k] with r_k chosen so the algorithm terminates at 1/2. Proof strategy for T3: Show pC⁻¹·(m,n)ᵀ = (m-2n,n)ᵀ subtracts 2n from m (a translation in the Euclidean algorithm), while pA⁻¹·(m,n)ᵀ = (n,2n-m)ᵀ inverts and adjusts (the inversion step). The composition of these exactly implements the continued fraction algorithm on the pair (m,n), terminating at (2,1).



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `descent_step_primitive` : theorem descent_step_primitive (a b c : ℤ) (h : a^2 + b^2 = c^2)
     (file: Pythagorean/BerggrenDescentComplete.lean)
  2. `root_triple_pythagorean` : theorem root_triple_pythagorean :
     (file: Pythagorean/Berggren/TropicalPAdicBerggren.lean)
  3. `descent_step_gcd` : theorem descent_step_gcd (a b N : ℤ) :
     (file: Pythagorean/Core/AdvancedFactoringResearch.lean)
  4. `trivial_triple_identity` : theorem trivial_triple_identity (N : ℕ) (hN3 : 1 ≤ N) :
     (file: Pythagorean/Core/BerggrenLorentzComplexity.lean)
  5. `descent_preserves_pythagorean` : theorem descent_preserves_pythagorean (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
     (file: Pythagorean/Core/O31_Generators.lean)

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



Recent successful concepts: Max-Plus One-Way Functions and Quantum Resistance from Idempotent Semiring Intractability, Berggren–Modular Correspondence: Pythagorean Light Cone Geodesics, PSL(2,ℤ) Embedding, and Gaussian Factorization Recovery, Algebraic Neural Architecture: Module-Theoretic Universal Approximation via Prime-Spectral Stratification and Tropical Specialization


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

Research domain: Pythagorean
Research mode: prove
