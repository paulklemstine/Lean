

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

## YOUR ASSIGNMENT: Berggren–Chronometric Reversible Automata via Primitive Triple Orbit Groupoids and Causal Entropy Separation

Work in Lean 4 with a self-contained development centered on the Berggren tree of primitive Pythagorean triples, a reversible word semantics on Berggren generators, and a Myhill–Nerode style quotient controlled by a chronometric length and a causal congruence. The target is not a single isolated theorem but a coherent formal theory connecting number theory, automata, reversible computation, entropy monotonicity, and post-quantum / quantum-style semantics.

You should build a mathematically rich file with at least 10 new definitions and 20+ proved theorems. Use doc comments to mark cross-domain significance, e.g. `Bridge: connects primitive triple dynamics to reversible computation and post_quantum_security.`

### Core mathematical objects to define

Use a concrete, Lean-friendly encoding. Prefer structures over opaque predicates where this improves transport lemmas.

#### 1. Berggren generators and words
Define a finite alphabet of Berggren moves:
```lean
inductive BerggrenStep
| A | B | C
deriving DecidableEq, Fintype, Repr
```

Define words as lists:
```lean
abbrev BerggrenWord := List BerggrenStep
```

Define a reversal with involution:
```lean
def BerggrenStep.inv : BerggrenStep → BerggrenStep
| .A => .A
| .B => .B
| .C => .C

def BerggrenWord.reverseInv (w : BerggrenWord) : BerggrenWord :=
  List.reverse (w.map BerggrenStep.inv)
```

Prove:
```lean
theorem reverseInv_involutive : Function.Involutive BerggrenWord.reverseInv
```

#### 2. Primitive triples
Use a concrete structure:
```lean
structure PrimitiveTriple where
  a b c : ℤ
  pos_a : 0 < a
  pos_b : 0 < b
  pos_c : 0 < c
  pythagorean : a*a + b*b = c*c
  coprime_ab : Int.gcd a b = 1
  odd_add : Odd (a + b)
```

Also define a normalized version if needed to avoid ordering ambiguity:
```lean
structure NormalizedPrimitiveTriple extends PrimitiveTriple where
  le_ab : a ≤ b
```

Define the root triple:
```lean
def rootTriple : NormalizedPrimitiveTriple := ...
```

If direct matrix formalization is cumbersome, define Berggren action abstractly but constructively on normalized triples:
```lean
def berggrenAct : BerggrenStep → NormalizedPrimitiveTriple → NormalizedPrimitiveTriple := ...
def evalWord : BerggrenWord → NormalizedPrimitiveTriple
| [] => rootTriple
| s :: w => evalWord w |> berggrenAct s
```

Also define the state reached from an arbitrary start:
```lean
def evalFrom : BerggrenWord → NormalizedPrimitiveTriple → NormalizedPrimitiveTriple
| [], t => t
| s :: w, t => evalFrom w (berggrenAct s t)
```

You should prove at least one explicit preservation theorem using arithmetic tactics:
```lean
theorem berggrenAct_preserves_pythagorean (s : BerggrenStep) (t : NormalizedPrimitiveTriple) :
  let u := berggrenAct s t
  u.a*u.a + u.b*u.b = u.c*u.c
```
and at least one primitive-preservation theorem using `omega`, `linarith`, or gcd lemmas.

#### 3. Orbit histories and groupoid semantics
Define history as source, word, and target:
```lean
structure OrbitHistory where
  src : NormalizedPrimitiveTriple
  word : BerggrenWord
  tgt : NormalizedPrimitiveTriple
  valid : evalFrom word src = tgt
```

Define composition when targets/sources match:
```lean
def OrbitHistory.comp (h₁ h₂ : OrbitHistory) : Option OrbitHistory := ...
```

Define reversal:
```lean
def OrbitHistory.reverse (h : OrbitHistory) : OrbitHistory := ...
```

Define a history equivalence/groupoid-style relation:
```lean
def HistoryHom (x y : NormalizedPrimitiveTriple) := {h : OrbitHistory // h.src = x ∧ h.tgt = y}
```

Then define a thin `HistoryGroupoid` structure adequate for proofs:
```lean
class HistoryGroupoidLike
  (Obj : Type) (Hom : Obj → Obj → Type) where
  id : ∀ X, Hom X X
  comp : ∀ {X Y Z}, Hom X Y → Hom Y Z → Hom X Z
  inv : ∀ {X Y}, Hom X Y → Hom Y X
```

Instantiate it for histories modulo causal congruence or exact equality, whichever is most tractable:
```lean
instance : HistoryGroupoidLike NormalizedPrimitiveTriple HistoryHom := ...
```

#### 4. Chronometric length
Define a weighted length on words; to get nontrivial theorems, assign distinct positive weights:
```lean
def stepCost : BerggrenStep → ℕ
| .A => 1
| .B => 2
| .C => 2

def chronometricLength : BerggrenWord → ℕ :=
  List.foldr (fun s n => stepCost s + n) 0
```

Also define history length:
```lean
def OrbitHistory.chronometricLength (h : OrbitHistory) : ℕ :=
  chronometricLength h.word
```

Main additive theorem:
```lean
theorem chronometricLength_append (u v : BerggrenWord) :
  chronometricLength (u ++ v) = chronometricLength u + chronometricLength v
```

and groupoid-compatible version:
```lean
theorem chronometricLength_comp
  (h₁ h₂ : OrbitHistory) (hcomp : h₁.tgt = h₂.src) :
  ∃ h : OrbitHistory,
    h.src = h₁.src ∧ h.tgt = h₂.tgt ∧
    h.word = h₁.word ++ h₂.word ∧
    h.1.chronometricLength = h₁.chronometricLength + h₂.chronometricLength
```
If this exact signature is awkward, use:
```lean
theorem chronometricLength_comp
  {x y z : NormalizedPrimitiveTriple}
  (h₁ : HistoryHom x y) (h₂ : HistoryHom y z) :
  (HistoryGroupoidLike.comp h₁ h₂).1.chronometricLength
    = h₁.1.chronometricLength + h₂.1.chronometricLength
```

#### 5. Causal congruence
Define a Myhill–Nerode style right-congruence using future chronometric behavior. A robust and provable version is:
```lean
def CausalCongruence (u v : BerggrenWord) : Prop :=
  ∀ w : BerggrenWord,
    evalWord (u ++ w) = evalWord (v ++ w) ∧
    chronometricLength (u ++ w) = chronometricLength (v ++ w)
```
This may be too strong unless injectivity is easy. A more flexible version:
```lean
def CausalCongruence (u v : BerggrenWord) : Prop :=
  ∀ w : BerggrenWord,
    evalWord (u ++ w) = evalWord (v ++ w) ↔
    evalWord (v ++ w) = evalWord (u ++ w)
```
Better still, use future-state equality only:
```lean
def CausalCongruence (u v : BerggrenWord) : Prop :=
  ∀ w : BerggrenWord, evalWord (u ++ w) = evalWord (v ++ w)
```
Then separately prove length equality consequences if your action is injective enough.

Prove:
```lean
theorem causalCongruence_refl : Reflexive CausalCongruence
theorem causalCongruence_symm : Symmetric CausalCongruence
theorem causalCongruence_trans : Transitive CausalCongruence
theorem causalCongruence_is_equiv : Equivalence CausalCongruence
```

Also prove right-invariance:
```lean
theorem causalCongruence_append_right
  {u v : BerggrenWord} (h : CausalCongruence u v) (w : BerggrenWord) :
  CausalCongruence (u ++ w) (v ++ w)
```

#### 6. Reversible orbit automaton
Define a deterministic automaton whose states are normalized primitive triples or causal classes:
```lean
structure ReversibleOrbitAutomaton where
  State : Type
  start : State
  step : State → BerggrenStep → State
  backstep : State → BerggrenStep → State
  left_inverse : ∀ q s, backstep (step q s) s = q
  right_inverse : ∀ q s, step (backstep q s) s = q
```

Construct the canonical automaton on triple states:
```lean
def primitiveTripleAutomaton : ReversibleOrbitAutomaton := ...
```

Define language semantics or observation semantics:
```lean
def ReversibleOrbitAutomaton.run (M : ReversibleOrbitAutomaton) :
  BerggrenWord → M.State
| [] => M.start
| s :: w => M.run w |> fun q => M.step q s
```

Define observation to causal classes:
```lean
def historyClass : BerggrenWord → Quot CausalCongruence := Quot.mk _

def factorsThroughHistoryGroupoid
  (M : ReversibleOrbitAutomaton) : Prop := ...
```

Then prove:
```lean
theorem reversible_automaton_factors_through_history_groupoid
  (M : ReversibleOrbitAutomaton)
  (hobs : ∀ u v, CausalCongruence u v → M.run u = M.run v) :
  ∃ F : Quot CausalCongruence → M.State, ∀ w, F (Quot.mk _ w) = M.run w
```

#### 7. Entropy / capacity / irreversibility proxies
Because full Shannon entropy on finite distributions may be heavy, define combinatorial entropy proxies that are still mathematically meaningful and provable.

Define branching-count entropy proxy:
```lean
def nonbacktrackingExtensions (w : BerggrenWord) : Finset BerggrenWord := ...
def extensionCount (n : ℕ) (w : BerggrenWord) : ℕ := ...
def causalEntropy (n : ℕ) (w : BerggrenWord) : ℕ := extensionCount n w
```

A simple and strong choice is to exclude immediate cancellation under reverse semantics; if steps are self-inverse, nonbacktracking can mean “no immediate repetition of a designated forbidden pattern,” or use a history-based predicate:
```lean
def Nonbacktracking : BerggrenWord → Prop := ...
```

Then prove monotonicity in the horizon parameter:
```lean
theorem entropy_monotone_nonbacktracking
  (w : BerggrenWord) :
  Monotone (fun n => causalEntropy n w)
```
Give an explicit bound:
```lean
theorem causalEntropy_le_explicit
  (w : BerggrenWord) (n : ℕ) :
  causalEntropy n w ≤ 3^n
```
and, if your nonbacktracking definition removes one immediate return option after the first step:
```lean
theorem causalEntropy_nonbacktracking_le_explicit
  (w : BerggrenWord) (n : ℕ) :
  causalEntropy n w ≤ 3 * 2^n
```
This explicit exponential bound is important for utility and computational significance.

Define a normalized capacity proxy:
```lean
def chronometricCapacity (n : ℕ) : ℚ :=
  (causalEntropy n []).toRat / (n + 1)
```
or a max-over-states version:
```lean
def chronometricCapacity (n : ℕ) : ℕ := sSup ((Finset.image (causalEntropy n) ... ) : Set ℕ)
```
Use a simpler type if needed.

Prove a time-reversal invariant upper bound:
```lean
theorem time_reversal_invariant_capacity_le
  (n : ℕ) :
  chronometricCapacity n ≤ 3^n
```
or in a word-parametrized form:
```lean
theorem time_reversal_invariant_capacity_le
  (w : BerggrenWord) (n : ℕ) :
  causalEntropy n (BerggrenWord.reverseInv w) ≤ 3^n
```

#### 8. Strict separation of irreversible quotients
Define an irreversible quotient relation coarser than causal congruence, for instance equality of reached triple only:
```lean
def IrreversibleQuotient (u v : BerggrenWord) : Prop :=
  evalWord u = evalWord v
```
Then define strict separation:
```lean
def StrictlyFiner (r s : BerggrenWord → BerggrenWord → Prop) : Prop :=
  (∀ ⦃u v⦄, r u v → s u v) ∧ ∃ u v, s u v ∧ ¬ r u v
```

Prove:
```lean
theorem strict_separation_of_irreversible_quotients :
  StrictlyFiner CausalCongruence IrreversibleQuotient
```
If this exact direction fails with your chosen definitions, reverse the relations but state and prove a genuine strictness theorem. The point is to formalize that reversible/chronometric semantics distinguish histories that irreversible state collapse forgets.

---

## Precise theorem targets

At minimum, include the following theorem statements with Lean-ready signatures, adjusting only if required for definitional coherence:

```lean
theorem chronometricLength_comp
  {x y z : NormalizedPrimitiveTriple}
  (h₁ : HistoryHom x y) (h₂ : HistoryHom y z) :
  (HistoryGroupoidLike.comp h₁ h₂).1.chronometricLength
    = h₁.1.chronometricLength + h₂.1.chronometricLength
```

```lean
theorem causalCongruence_is_equiv : Equivalence CausalCongruence
```

```lean
theorem history_reversal_involutive (h : OrbitHistory) :
  OrbitHistory.reverse (OrbitHistory.reverse h) = h
```

```lean
theorem reversible_automaton_factors_through_history_groupoid
  (M : ReversibleOrbitAutomaton)
  (hobs : ∀ u v, CausalCongruence u v → M.run u = M.run v) :
  ∃ F : Quot CausalCongruence → M.State, ∀ w, F (Quot.mk _ w) = M.run w
```

```lean
theorem myhill_nerode_chronometric_minimality
  (M : ReversibleOrbitAutomaton)
  (hsep : ∀ u v, ¬ CausalCongruence u v → M.run u ≠ M.run v) :
  Nat.card (Quot CausalCongruence) ≤ Nat.card M.State
```
If `Nat.card` is difficult for your chosen state universe, prove an injective embedding:
```lean
theorem myhill_nerode_chronometric_minimality
  (M : ReversibleOrbitAutomaton)
  (hsep : ∀ u v, ¬ CausalCongruence u v → M.run u ≠ M.run v) :
  ∃ f : Quot CausalCongruence → M.State, Function.Injective f
```

```lean
theorem entropy_monotone_nonbacktracking
  (w : BerggrenWord) :
  Monotone (fun n => causalEntropy n w)
```

```lean
theorem time_reversal_invariant_capacity_le
  (w : BerggrenWord) (n : ℕ) :
  causalEntropy n (BerggrenWord.reverseInv w) ≤ 3^n
```

```lean
theorem strict_separation_of_irreversible_quotients :
  StrictlyFiner CausalCongruence IrreversibleQuotient
```

---

## Additional definitions and structures required for richness

Include at least 5 of the following, preferably more:

```lean
def BerggrenDepth : BerggrenWord → ℕ := List.length
def weightedSlopeGap (t : NormalizedPrimitiveTriple) : ℤ := t.b - t.a
def chronometricPotential (w : BerggrenWord) : ℕ := chronometricLength w + BerggrenDepth w
def CausalFrontier (n : ℕ) : Finset BerggrenWord := ...
def OrbitHistory.nonbacktracking : Prop := ...
def entropyRateUpper (w : BerggrenWord) (n : ℕ) : ℚ := ...
def quantumCertifiedRadiusProxy (w : BerggrenWord) : ℕ := chronometricLength w
def postQuantumSecurityLevel (w : BerggrenWord) : ℕ := 2 * chronometricLength w
def latticeTrapdoorCostProxy (w : BerggrenWord) : ℕ := chronometricLength w + BerggrenDepth w
```

and/or structures:
```lean
structure ChronometricSemiringWitness where
  carrier : Type
  instSemiring : Semiring carrier
  measure : BerggrenWord → carrier

structure CausalObserver where
  Obs : Type
  observe : NormalizedPrimitiveTriple → Obs
  reversible_invariant : ∀ s t g, observe s = observe t → observe (berggrenAct g s) = observe (berggrenAct g t)

structure NonbacktrackingLanguage where
  accepts : BerggrenWord → Prop
  suffix_closed : ∀ u v, accepts (u ++ v) → accepts u
```

If some of these are mathematically decorative, still connect them to explicit theorem statements.

---

## Required theorem count and diversity

Prove at least 10 theorems, ideally 20+, including the target theorems and supporting lemmas such as:

```lean
theorem chronometricLength_nil : chronometricLength [] = 0
theorem chronometricLength_cons (s : BerggrenStep) (w : BerggrenWord) :
  chronometricLength (s :: w) = stepCost s + chronometricLength w
theorem chronometricLength_reverseInv (w : BerggrenWord) :
  chronometricLength (BerggrenWord.reverseInv w) = chronometricLength w
theorem evalFrom_append (u v : BerggrenWord) (t : NormalizedPrimitiveTriple) :
  evalFrom (u ++ v) t = evalFrom v (evalFrom u t)
theorem history_comp_assoc ...
theorem history_id_left ...
theorem history_id_right ...
theorem history_inv_left ...
theorem history_inv_right ...
theorem causalCongruence_respects_chronometricLength
  (h : CausalCongruence u v) :
  chronometricLength u = chronometricLength v
theorem irreversibleQuotient_coarser_or_finer ... -- whichever is true in your setup
theorem nonbacktrackingExtensions_card_le (w : BerggrenWord) (n : ℕ) :
  extensionCount n w ≤ 3^n
theorem certified_lipschitz_chronometric_proxy (u v : BerggrenWord) :
  Int.natAbs (chronometricLength u - chronometricLength v) ≤ chronometricLength (u ++ v)
```

Use a range of tactics:
- induction on words/horizon
- `rcases` for quotient/groupoid witnesses
- `simp` for definitional reductions
- `omega` / `linarith` for arithmetic bounds
- `by_contra` in at least one separation/minimality proof
- `field_simp` if you introduce rational entropy-rate proxies
- `have` chains and explicit rewriting with `List.append_assoc`

---

## Concrete proof strategy hints

### A. Word semantics and chronometric additivity
1. Prove `chronometricLength_cons` and `chronometricLength_append` by induction on the first list.
2. Prove `evalFrom_append` by induction on the first word, using the chosen recursion direction.
3. Build history composition from append and `evalFrom_append`.
4. Deduce `chronometricLength_comp` by unpacking `HistoryHom`, simplifying the composed word, and applying additivity.

Most promising route: make `evalFrom` recurse on the first word and define composition literally by word concatenation. This makes the key theorem nearly algebraic.

### B. Reversal and involution
1. Prove `List.reverse_map_reverse_map` style lemmas for `reverseInv`.
2. Since `BerggrenStep.inv = id`, `reverseInv_involutive` is mostly `List.reverse_reverse`.
3. Define `OrbitHistory.reverse` by swapping source/target and applying `reverseInv`.
4. To prove validity of reversed histories, you need either:
   - an involutive/backstep action on triples, or
   - define reverse on histories only after quotienting by exact words and using a reversible automaton semantics.
   
Most promising route: equip `berggrenAct` with a matching `berggrenBackAct` and prove `berggrenBackAct (berggrenAct s t) s = t`. Then reverse-validity follows by induction on words.

### C. Causal congruence and Myhill–Nerode
1. Choose a definition of `CausalCongruence` that is obviously reflexive/symmetric/transitive.
2. Prove right invariance under append.
3. Use quotient lift to define the factor map `F`.
4. For minimality, show that if an automaton separates non-congruent words, then `run` induces an injective map on quotient classes.
5. Convert injectivity to a cardinal inequality only if universe/cardinality issues remain manageable.

Most promising route: quotient by a right congruence and apply `Quot.lift`; this is standard and Lean-friendly.

### D. Entropy monotonicity and capacity
1. Define `extensionCount n w` via a finite set of words of length `n` satisfying a decidable predicate.
2. Show inclusion from horizon `n` to `n+1` by extending with a fixed step, e.g. `A`.
3. For explicit bounds, compare cardinality to all words of length `n`; use `Fintype.card (Fin n → BerggrenStep)` or list counting.
4. For nonbacktracking, after the first step there are at most `2` legal successors, yielding `≤ 3 * 2^n` or similar.
5. For time reversal invariance, prove your nonbacktracking predicate is preserved by `reverseInv`.

Most promising route: formulate entropy as counting admissible words in a finite ambient set and use `Finset.card_le_card` with an explicit embedding.

### E. Strict separation
1. Pick two words `u`, `v` that reach the same state but have different chronometric signatures or histories.
2. Show they are equivalent under the irreversible quotient by reflexive state equality.
3. Show they are not causally congruent by choosing a witness suffix `w = []` or a short explicit suffix.
4. Use `rcases` and `by_contra` to package the witness into `StrictlyFiner`.

Most promising route: engineer `stepCost` so two distinct words can reach the same state but have different chronometric lengths, then `w = []` already separates them.

---

## Cross-domain significance to encode in theorem names/doc comments

Explicitly use application language:
- `quantum_control_history_reversal`
- `post_quantum_security_chronometric_bound`
- `lattice_trapdoor_orbit_cost_upper`
- `certified_robustness_chronometric_lipschitz`
- `thermodynamic_entropy_nonbacktracking_monotone`

Bridge at least two domains in theorem names or comments:
1. Number theory + automata: primitive triple languages and Myhill–Nerode classes.
2. Reversible computation + physics: time reversal, entropy, causal histories.
3. Cryptography + lattice complexity: chronometric cost as a trapdoor / search complexity proxy.
4. ML robustness + semantics: Lipschitz-like bounds on observation change under word perturbation.

Example doc comment style:
```lean
/--
Bridge: connects primitive Pythagorean orbit semantics to reversible quantum-style control.
The chronometric length is an exact additive action functional on history composition,
providing a certified cost proxy for post_quantum_security and thermodynamic reversibility.
-/
theorem chronometricLength_comp ...
```

---

## Computational / asymptotic utility requirements

State at least 3 explicit bounds, with concrete formulas:
```lean
theorem extensionCount_bigO_exponential
  (w : BerggrenWord) :
  ∃ C : ℕ, ∀ n : ℕ, extensionCount n w ≤ C * 3^n
```

```lean
theorem nonbacktracking_extensionCount_sharp
  (w : BerggrenWord) :
  ∀ n ≥ 1, extensionCount n w ≤ 3 * 2^(n-1)
```

```lean
theorem chronometricLength_linear_in_depth
  (w : BerggrenWord) :
  BerggrenDepth w ≤ chronometricLength w ∧ chronometricLength w ≤ 2 * BerggrenDepth w
```

If you define rational entropy rates:
```lean
theorem entropyRateUpper_le_log_branching
  (w : BerggrenWord) (n : ℕ) :
  entropyRateUpper w n ≤ 3
```
A simpler algebraic inequality is acceptable if logarithms are inconvenient.

---

## Lean engineering constraints

- Prefer decidable predicates for finite counting constructions.
- Use `abbrev` and small structures to keep quotient/groupoid proofs manageable.
- If full matrix Berggren action is too expensive, define a simplified but faithful algebraic action preserving enough structure for the automata/groupoid theory.
- Zero `sorry`.
- If a full theorem is too strong, prove the strongest exact special case and state the remaining conjecture precisely in a comment, but the file itself must compile cleanly.

---

## Deliverables inside the formalization

1. Definitions:
   `BerggrenWord`, `PrimitiveTriple`, `OrbitHistory`, `HistoryGroupoidLike`/`HistoryGroupoid`,
   `chronometricLength`, `CausalCongruence`, `ReversibleOrbitAutomaton`,
   plus 5+ auxiliary notions.

2. Main theorems:
   - `chronometricLength_comp`
   - `causalCongruence_is_equiv`
   - `history_reversal_involutive`
   - `reversible_automaton_factors_through_history_groupoid`
   - `myhill_nerode_chronometric_minimality`
   - `entropy_monotone_nonbacktracking`
   - `time_reversal_invariant_capacity_le`
   - `strict_separation_of_irreversible_quotients`

3. Supporting theorem ecosystem:
   10+ additional lemmas with varied proof styles.

4. A structured `FUTURE_DIRECTIONS.md` proposing 3–5 concrete next breakthroughs, such as:
   - a true Berggren matrix groupoid with `SL(3, ℤ)` semantics,
   - a Shannon-style entropy formalization on orbit distributions,
   - a certified robustness theorem for perturbations of Berggren words,
   - a lattice/post-quantum reduction from chronometric orbit complexity,
   - a quantum control interpretation of reversible primitive-triple automata.

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
            Develop a mathematically precise connection between Berggren-tree dynamics of primitive Pythagorean triples and reversible time-structured computation. Define a groupoid of Berggren orbit histories, equip it with a chronometric congruence measuring causal depth and reversibility cost, and prove that finitely generated reversible automata encoded by orbit words admit a normal-form factorization through this groupoid. Target results include: (1) a reconstruction statement that every bounded-depth reversible Berggren automaton is determined by its orbit-history congruence class; (2) a causal entropy monotonicity law along non-backtracking orbit extensions; and (3) a separation principle showing that time-reversal-invariant orbit automata have strictly lower ambiguity/capacity than irreversible quotients unless the chronometric congruence collapses. This opens a new field linking Diophantine generation, automata, and reversible computation without repeating current oracle/time-reversal semiring work.

            ### Precise Mathematical Framing
            Use the existing Berggren-generated structures from Pythagorean/cryptographic work as the arithmetic substrate, but shift the computational semantics from quantum/trapdoor settings to reversible automata and causal history groupoids. Let primitive triples form vertices of the Berggren tree; morphisms are reduced generator words with inverse formal rewinds, giving an orbit-history groupoid. Define a chronometric length on morphisms and a causal congruence identifying histories with equal observable output and equal reversal budget. Then prove functorial transfer from orbit-history groupoids to deterministic reversible transducers, with a Myhill–Nerode-style minimization over chronometric congruence classes. The central formal statements should avoid overlap with current in-flight oracle hierarchy and causal sheaf semantics by focusing on Berggren arithmetic automata rather than semiring-oracle semantics. Algorithmically, this yields a minimization pipeline for reversible arithmetic automata indexed by primitive triples and explicit bounds on state complexity in terms of orbit depth and congruence growth. Structurally, it synthesizes Pythagorean arithmetic, computation, and speculative temporal semantics in a way not yet present in the catalog.

            ### Lean 4 Sketch
Define `BerggrenWord`, `PrimitiveTriple`, `OrbitHistory`, `HistoryGroupoid`, `chronometricLength`, `CausalCongruence`, `ReversibleOrbitAutomaton`, and prove lemmas `chronometricLength_comp`, `causalCongruence_is_equiv`, `history_reversal_involutive`, `reversible_automaton_factors_through_history_groupoid`, `myhill_nerode_chronometric_minimality`, `entropy_monotone_nonbacktracking`, `time_reversal_invariant_capacity_le`, `strict_separation_of_irreversible_quotients`.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `berggren_renyi2_entropy_lower_bound` : theorem berggren_renyi2_entropy_lower_bound (S : ShellPartition)
     (file: Bridges/BerggrenEntropyExtractor.lean)
  2. `berggren_depth_monotone_capacity_bound` : theorem berggren_depth_monotone_capacity_bound
     (file: Bridges/QuantumPythagoreanInformation.lean)
  3. `field_causal_depth_zero` : theorem field_causal_depth_zero (K : Type*) [Field K] :
     (file: Bridges/CausalZariskiReconstruction.lean)
  4. `depth_capacity_lower` : theorem depth_capacity_lower (k : ℕ) (d : Fin k → ℝ)
     (file: Bridges/QuantumNeuralCapacity.lean)
  5. `entropy_decrease_bounded` : theorem entropy_decrease_bounded (h : ℕ → ℝ) (h_anti : Antitone h) (_h_pos : ∀ n, 0 ≤ h n)
     (file: Bridges/DifferentialAlgebraicLearning.lean)

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



Recent successful concepts: Algebraic–Speculative Chronometric Semiring Dynamics via Time-Reversal Congruences and Causal Fixed-Point Separation, Algebraic–EML Thermodynamic Formalism via Closure Pressure and Gibbs Fixed-Point States, Algebraic–EML Phase-Space Reconstruction via Closure Bialgebras and Koopman Spectra


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
