
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: Cobham's theorem (1972) states that if a sequence is both j-automatic and k-auto
**Domain**: Applications
**Mathematical framing**: # Future Directions: Automatic Sequences, Decidability, and Beyond

## 1. Cobham's Theorem: The Multiplicative Independence Barrier

Cobham's theorem (1972) states that if a sequence is both j-automatic and k-automatic
where log j / log k is irrational (i.e., j and k are multiplicatively independent),
then the sequence is eventually periodic. This is one of the deepest results in
automatic sequence theory and remains challenging to formalize.

**The key insight is** that multiplicative independence forces the set of positions where
a given value appears to be a "sparse" set that cannot simultaneously be recognized by
two automata with incompatible bases — unless it is ultimately periodic (a trivial case
recognized by all bases). The proof uses a delicate pigeonhole argument on the
representations of large integers in two different bases.

**Why now?** Our formalization of k-automatic sequences with Boolean closure and the
Nerode bridge provides the algebraic infrastructure needed for Cobham's theorem. The
key missing piece is the number-theoretic lemma about base representations, which could
be attacked using Mathlib's extensive `Nat.digits` API and the Skolem-Mahler-Lech theorem
machinery.

**Falsifiable test:** Formalize the contrapositive: if a non-periodic sequence is
k-automatic, construct an explicit word in the complement language that the j-automaton
must reject. Verify on Thue-Morse (2-automatic, not 3-automatic) by checking that
no 3-state DFAO over base 3 generates it.

---

## 2. Büchi-Bruyère Theorem: First-Order Decidability for Automatic Sequences

The Büchi-Bruyère theorem states that a subset S ⊆ ℕ is definable in the first-order
theory ⟨ℕ, +, Vₖ⟩ (where Vₖ(n) is the largest power of k dividing n) if and only if S
is k-recognizable (i.e., the characteristic function of S is k-automatic). This gives a
decision procedure for *any* first-order sentence about k-automatic sequences.

**The key insight is** that the logical operations (∧, ∨, ¬, ∃) correspond exactly to
the automata operations we have already formalized (product, union, complement,
projection). The existential quantifier ∃n corresponds to projecting out a track from
a multi-track automaton, which preserves regularity by the standard subset construction.

**Why now?** Our Boolean closure theorems (`kAutomatic_complement`, `kAutomatic_inter`,
`kAutomatic_union`) handle the propositional fragment. The missing piece is the projection
(existential quantification), which requires formalizing the subset construction for
nondeterministic automata — a well-understood algorithm that Mathlib nearly supports
via `Finset.powerset`.

**Falsifiable test:** Express "the Thue-Morse sequence has infinitely many zeros" as
a first-order sentence in ⟨ℕ, +, V₂⟩ and verify the decision procedure outputs TRUE.
This should reduce to checking that a specific automaton accepts at least one string,
which we can do by `DFAO.value_appears_implies_in_output_image`.

---

## 3. Morphic Decidability: Beyond the Automatic Frontier

The decidability of the zero-in-sequence problem for morphic sequences (fixed points of
arbitrary — not necessarily uniform — morphisms) is a major open problem. Durand (2013)
showed decidability for primitive morphisms; the general case remains open.

**The key insight is** that non-uniform morphisms can produce sequences whose "growth
rates" vary across positions, creating a tension between the local regularity of the
morphism and the global structure of the sequence. For uniform morphisms, the growth
is exactly kⁿ (our `AlphabetMorphism.iterate_length_uniform` in the existing catalog),
which makes the connection to DFAOs direct. For non-uniform morphisms, the connection
goes through Pansiot's theorem on the growth rates of morphic sequences.

**Why now?** Our formalization of the k-kernel closure theorem shows that uniform
morphisms stay within the automatic framework. The bridge to non-uniform morphisms
requires formalizing Pansiot's classification (polynomial, exponential, intermediate
growth) and Durand's reduction to the uniform case for primitive morphisms.

**Falsifiable test:** Construct a non-uniform morphism σ on {0,1,2} with σ(0) = 01,
σ(1) = 2, σ(2) = 0 and verify that the fixed point starting from 0 contains all three
letters. Then attempt to formalize the decidability proof for this specific morphism,
checking if BFS on the "reachability graph of letter occurrences" terminates.

---

## 4. Christol's Theorem: The Algebraic-Automatic Bridge

Christol's theorem (1979) states that a formal power series f(x) = Σ aₙxⁿ over 𝔽_p is
algebraic over 𝔽_p(x) if and only if the coefficient sequence (aₙ) is p-automatic. This
is the deepest known connection between automata theory and algebra.

**The key insight is** that the p-kernel of a p-automatic sequence corresponds exactly to
the conjugates of the algebraic element under the Frobenius endomorphism x ↦ xᵖ. The
finiteness of the kernel (which we formalize via `kKernel`) translates to the algebraic
element having finite degree over 𝔽_p(x). Our kernel closure theorem (`kKernel_closed`)
is a key ingredient — it shows the kernel is closed under the operation that corresponds
to applying Frobenius.

**Why now?** Mathlib has extensive support for formal power series (`PowerSeries`),
finite fields (`ZMod p`), and algebraic extensions. The kernel machinery in our
formalization provides the automata-theoretic side. The missing bridge is the
explicit construction of the minimal polynomial from the kernel elements, which
requires combining `PowerSeries` with `Polynomial` over `ZMod p`.

**Falsifiable test:** Verify Christol's theorem for the Thue-Morse sequence mod 2:
the generating function T(x) = Σ tₙxⁿ over 𝔽₂ satisfies T² + T + x/(1+x)² = 0
(a degree-2 algebraic equation), consistent with Thue-Morse being 2-automatic.
Compute the 2-kernel {T(x), T(x²)+x·T(x²)} and verify it has exactly 2 elements.

---

## 5. Automatic Sequences in Cryptographic Applications

Automatic sequences have natural applications in pseudorandom generation and
stream ciphers. The Rudin-Shapiro sequence (2-automatic) has optimal correlation
properties, and the sub-word complexity of automatic sequences (Θ(n) for non-periodic
ones) provides a lower bound on unpredictability.

**The key insight is** that our Boolean closure theorem implies that any Boolean
combination of automatic pseudorandom generators is still automatic — and therefore
still has decidable properties. This means that certain classes of stream cipher
constructions can be *verified* to satisfy security properties (like balance and
correlation immunity) by reduction to finite automaton checks, rather than relying
on heuristic testing.

**Why now?** Our `kAutomatic_boolean_algebra` theorem shows that Boolean combinations
preserve automaticity. Combined with `DFAO.nerode_classes_bounded`, we can bound the
state complexity of combined generators. The connection to correlation immunity requires
formalizing the Walsh-Hadamard transform of automatic sequences, which has been studied
but not formalized.

**Falsifiable test:** Construct the Rudin-Shapiro DFAO (4 states) and verify that
its auto-correlation function is bounded by O(√n), using our DFAO framework to compute
correlations for all inputs up to length 20. Compare with the Thue-Morse sequence
(which has worse correlation properties).

**Concept description**: # Future Directions: Automatic Sequences, Decidability, and Beyond

## 1. Cobham's Theorem: The Multiplicative Independence Barrier

Cobham's theorem (1972) states that if a sequence is both j-automatic and k-automatic
where log j / log k is irrational (i.e., j and k are multiplicatively independent),
then the sequence is eventually periodic. This is one of the deepest results in
automatic sequence theory and remains challenging to formalize.

**The key insight is** that multiplicative independence forces the set of positions where
a given value appears to be a "sparse" set that cannot simultaneously be recognized by
two automata with incompatible bases — unless it is ultimately periodic (a trivial case
recognized by all bases). The proof uses a delicate pigeonhole argument on the
representations of large integers in two different bases.

**Why now?** Our formalization of k-automatic sequences with Boolean closure and the
Nerode bridge provides the algebraic infrastructure needed for Cobham's theorem. The
key missing piece is the number-theoretic lemma about base representations, which could
be attacked using Mathlib's extensive `Nat.digits` API and the Skolem-Mahler-Lech theorem
machinery.

**Falsifiable test:** Formalize the contrapositive: if a non-periodic sequence is
k-automatic, construct an explicit word in the complement language that the j-automaton
must reject. Verify on Thue-Morse (2-automatic, not 3-automatic) by checking that
no 3-state DFAO over base 3 generates it.

---

## 2. Büchi-Bruyère Theorem: First-Order Decidability for Automatic Sequences

The Büchi-Bruyère theorem states that a subset S ⊆ ℕ is definable in the first-order
theory ⟨ℕ, +, Vₖ⟩ (where Vₖ(n) is the largest power of k dividing n) if and only if S
is k-recognizable (i.e., the characteristic function of S is k-automatic). This gives a
decision procedure for *any* first-order sentence about k-automatic sequences.

**The key insight is** that the logical operations (∧, ∨, ¬, ∃) correspond exactly to
the automata operations we have already formalized (product, union, complement,
projection). The existential quantifier ∃n corresponds to projecting out a track from
a multi-track automaton, which preserves regularity by the standard subset construction.

**Why now?** Our Boolean closure theorems (`kAutomatic_complement`, `kAutomatic_inter`,
`kAutomatic_union`) handle the propositional fragment. The missing piece is the projection
(existential quantification), which requires formalizing the subset construction for
nondeterministic automata — a well-understood algorithm that Mathlib nearly supports
via `Finset.powerset`.

**Falsifiable test:** Express "the Thue-Morse sequence has infinitely many zeros" as
a first-order sentence in ⟨ℕ, +, V₂⟩ and verify the decision procedure outputs TRUE.
This should reduce to checking that a specific automaton accepts at least one string,
which we can do by `DFAO.value_appears_implies_in_output_image`.

---

## 3. Morphic Decidability: Beyond the Automatic Frontier

The decidability of the zero-in-sequence problem for morphic sequences (fixed points of
arbitrary — not necessarily uniform — morphisms) is a major open problem. Durand (2013)
showed decidability for primitive morphisms; the general case remains open.

**The key insight is** that non-uniform morphisms can produce sequences whose "growth
rates" vary across positions, creating a tension between the local regularity of the
morphism and the global structure of the sequence. For uniform morphisms, the growth
is exactly kⁿ (our `AlphabetMorphism.iterate_length_uniform` in the existing catalog),
which makes the connection to DFAOs direct. For non-uniform morphisms, the connection
goes through Pansiot's theorem on the growth rates of morphic sequences.

**Why now?** Our formalization of the k-kernel closure theorem shows that uniform
morphisms stay within the automatic framework. The bridge to non-uniform morphisms
requires formalizing Pansiot's classification (polynomial, exponential, intermediate
growth) and Durand's reduction to the uniform case for primitive morphisms.

**Falsifiable test:** Construct a non-uniform morphism σ on {0,1,2} with σ(0) = 01,
σ(1) = 2, σ(2) = 0 and verify that the fixed point starting from 0 contains all three
letters. Then attempt to formalize the decidability proof for this specific morphism,
checking if BFS on the "reachability graph of letter occurrences" terminates.

---

## 4. Christol's Theorem: The Algebraic-Automatic Bridge

Christol's theorem (1979) states that a formal power series f(x) = Σ aₙxⁿ over 𝔽_p is
algebraic over 𝔽_p(x) if and only if the coefficient sequence (aₙ) is p-automatic. This
is the deepest known connection between automata theory and algebra.

**The key insight is** that the p-kernel of a p-automatic sequence corresponds exactly to
the conjugates of the algebraic element under the Frobenius endomorphism x ↦ xᵖ. The
finiteness of the kernel (which we formalize via `kKernel`) translates to the algebraic
element having finite degree over 𝔽_p(x). Our kernel closure theorem (`kKernel_closed`)
is a key ingredient — it shows the kernel is closed under the operation that corresponds
to applying Frobenius.

**Why now?** Mathlib has extensive support for formal power series (`PowerSeries`),
finite fields (`ZMod p`), and algebraic extensions. The kernel machinery in our
formalization provides the automata-theoretic side. The missing bridge is the
explicit construction of the minimal polynomial from the kernel elements, which
requires combining `PowerSeries` with `Polynomial` over `ZMod p`.

**Falsifiable test:** Verify Christol's theorem for the Thue-Morse sequence mod 2:
the generating function T(x) = Σ tₙxⁿ over 𝔽₂ satisfies T² + T + x/(1+x)² = 0
(a degree-2 algebraic equation), consistent with Thue-Morse being 2-automatic.
Compute the 2-kernel {T(x), T(x²)+x·T(x²)} and verify it has exactly 2 elements.

---

## 5. Automatic Sequences in Cryptographic Applications

Automatic sequences have natural applications in pseudorandom generation and
stream ciphers. The Rudin-Shapiro sequence (2-automatic) has optimal correlation
properties, and the sub-word complexity of automatic sequences (Θ(n) for non-periodic
ones) provides a lower bound on unpredictability.

**The key insight is** that our Boolean closure theorem implies that any Boolean
combination of automatic pseudorandom generators is still automatic — and therefore
still has decidable properties. This means that certain classes of stream cipher
constructions can be *verified* to satisfy security properties (like balance and
correlation immunity) by reduction to finite automaton checks, rather than relying
on heuristic testing.

**Why now?** Our `kAutomatic_boolean_algebra` theorem shows that Boolean combinations
preserve automaticity. Combined with `DFAO.nerode_classes_bounded`, we can bound the
state complexity of combined generators. The connection to correlation immunity requires
formalizing the Walsh-Hadamard transform of automatic sequences, which has been studied
but not formalized.

**Falsifiable test:** Construct the Rudin-Shapiro DFAO (4 states) and verify that
its auto-correlation function is bounded by O(√n), using our DFAO framework to compute
correlations for all inputs up to length 20. Compare with the Thue-Morse sequence
(which has worse correlation properties).

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Research Team Protocol

You are leading a research team. Your team has different roles:
- The **Hypothesizer** generates bold, falsifiable conjectures
- The **Experimenter** proves or disproves them in Lean 4
- The **Analyst** examines what survived, what failed, and WHY
- The **Critic** searches for weaknesses, constructs counterexamples,
  and identifies where proofs might break down. A well-constructed
  counterexample is as valuable as a proof.
- The **Synthesist** upgrades the knowledge base and writes the
  FUTURE_DIRECTIONS.md that seeds the next cycle

You run this loop: **Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate**.
Each cycle is not a one-shot task. It is one iteration of an infinite
research process. Your notes (FUTURE_DIRECTIONS.md, Lab Notebooks,
proof sketches) determine whether the next team builds on your work
or starts over.

**Take good notes.** A cycle without useful notes is a wasted cycle.

### STEP 1: THEOREM DECLARATIONS (required -- before any code)

List every theorem you intend to prove or investigate. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `hypothesis` | `conjecture` | `proved` | `proved_with_lemma_sorry` | `disproved`
- **Why it matters**: One sentence on what this result would mean if true,
  and what it would teach us if false

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective -- proved -- constructive inverse -- confirms decidability of Nat x Nat
2. `cantorPairing_injective`: Cantor pairing is injective -- proved -- diagonal argument -- confirms invertibility
3. `cantorPairing_bijection`: Cantor pairing is a bijection -- proved_with_lemma_sorry -- follows from 1+2 -- completing the characterization

Use `hypothesis` for statements you are not yet sure you can prove but
want to investigate. Use `conjecture` for statements you believe are true
but cannot prove in this cycle. Use `disproved` for statements where you
found a counterexample. Use `proved` for statements with complete Lean
proofs. Use `proved_with_lemma_sorry` when the main proof is complete but
one or more supporting lemmas use `sorry`.

### STEP 2: EXPERIMENT (prove or disprove in Lean 4)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its
status to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it is deferred

**Disproofs count.** If a hypothesis is false, prove its negation or
construct an explicit counterexample. A well-constructed counterexample
is as valuable as a proof. Change the status to `disproved` and state
the counterexample clearly.

### STEP 3: CRITIQUE (find the weaknesses)

For your best theorem, the Critic must:
- Identify the strongest assumption that could be weakened
- Construct a boundary case: where does the result break down?
- If possible, state a `conjecture` for the generalized version and
  explain what would need to change in the proof

This is NOT optional. A theorem without a critique is incomplete.

### STEP 4: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` -- unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures, generalizations, and boundary cases.

### STEP 5: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### STEP 6: TAKE GOOD NOTES (first-class deliverables)

Your notes determine what the next research team investigates. They are NOT
an afterthought. They are your most important output after the proofs themselves.

**6a. Lab Notebook** (in each .lean file, as `-- !-- Lab Notebook -- !--` blocks):

For each major theorem, include a Lab Notebook comment block:
```lean
-- !-- Lab Notebook: cantorPairing_bijection -- !--
-- !-- Hypothesis: Cantor pairing is bijective because both surjective and injective -- !--
-- !-- Result: Proved via composition of surjective and injective proofs -- !--
-- !-- Insight: The constructive inverse of surjectivity is key; diagonal argument handles injectivity -- !--
-- !-- Failure analysis: Initial attempt to prove bijection directly failed; decomposition into surjective+injective was necessary -- !--
-- !-- End Lab Notebook -- !--
```

**6b. FUTURE_DIRECTIONS.md** (MANDATORY — your output WILL BE REJECTED if missing):

You MUST produce a FUTURE_DIRECTIONS.md file with this EXACT structure.
Copy the section headers below verbatim. Do NOT use freeform prose.

## Synthesis

[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary

[For EACH theorem: name, status (proved/conjecture/disproved), one-sentence
significance. Format as a bullet list:]

- `theoremName`: status — one-sentence significance

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

IMPORTANT: The ## Synthesis and ## Results Summary sections are NOT optional.
If your FUTURE_DIRECTIONS.md is missing either section, it will be treated as
incomplete and the next research team will have no context to build on your work.

### STEP 7: Generalization loop

For your BEST theorem, attempt one level of generalization:
- State a stronger version (can use sorry if proving would take too long)
- Identify the boundary: where does the result break down?
- If the generalization is itself interesting, mark it as a `conjecture`
  in your theorem declarations and explain it in FUTURE_DIRECTIONS.md

### Output format

Your output must include:
1. `.lean` files with proofs and Lab Notebook blocks (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with Synthesis, Results Summary, and 3-5 research
   directions (structured as in Step 6b)

Both are required. A cycle with proofs but no Lab Notebook or
FUTURE_DIRECTIONS.md is a cycle where the next team starts from scratch.
Take good notes.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
