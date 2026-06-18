## Assignment: 196-Algorithm Non-Termination

**Mode:** `prove`

Prove genuinely new, structurally meaningful theorems about the reverse-and-add dynamics centered on `196`, with formal definitions that make the problem extensible beyond brute-force digit computation. The target is not a finite verification that “many steps do not yield a palindrome,” but a framework for **digit-dynamical obstructions** to palindromicity and a formal notion of **Lychrel-type non-termination certificates**.

This project should turn the folklore around `196` into a formal theory of **carry-constrained digit dynamics**, with bridges to automata, congruence dynamics, and discrete dynamical systems.

---

## Core Vision

The classical “196 problem” asks whether repeated application of the map
\[
T(n) = n + \operatorname{rev}(n)
\]
ever produces a palindrome when started at `196`. This is usually treated experimentally. That is not enough.

Your goal is to formalize a **mathematical obstruction theory** for palindrome formation under reverse-and-add. The breakthrough is to replace raw computation by **digit-level invariants, carry propagation laws, and modular/dynamical certificates** showing that large classes of iterates cannot be palindromic, and to isolate what would constitute a formal certificate of Lychrel behavior.

The key conceptual leap: study the iteration not merely on naturals, but on a richer state space:
- digit vectors,
- carry profiles,
- symmetry defects,
- congruence signatures,
- and growth functionals.

This opens a new formal field: **palindrome-avoidance dynamics**.

---

## Precise Formalization Targets

You should define the reverse-and-add map and the palindrome predicate in a way that supports both arithmetic and digitwise proofs.

### Proposed Lean 4 definitions / signatures

These signatures are indicative targets; adjust exact names/types to Mathlib conventions, but preserve the mathematical content.

```lean
def digits10 (n : ℕ) : List ℕ := Nat.digits 10 n

def ofDigits10 (L : List ℕ) : ℕ := Nat.ofDigits 10 L

def reverseNat (n : ℕ) : ℕ := ofDigits10 (digits10 n).reverse

def revAdd (n : ℕ) : ℕ := n + reverseNat n

def IsPalindromeNat (n : ℕ) : Prop :=
  digits10 n = (digits10 n).reverse

def revAddIter : ℕ → ℕ → ℕ
| 0, n => n
| k+1, n => revAdd (revAddIter k n)

def IsLychrelCandidate (n : ℕ) : Prop :=
  ∀ k : ℕ, ¬ IsPalindromeNat (revAddIter k n)
```

You should also define at least one genuinely new structure not already present in the catalog, for example:

```lean
structure CarryProfile where
  inputLen : ℕ
  carries  : Fin (inputLen + 1) → ℕ

def symmetryDefect (L : List ℕ) : ℕ :=
  ((List.range (L.length / 2)).map (fun i => Nat.abs (L.get! i - L.get! (L.length - 1 - i)))).sum

def DigitState where
  digits   : List ℕ
  carries  : List ℕ
  value    : ℕ
  coherent : value = ofDigits10 digits
```

or a more abstract certificate object:

```lean
structure PalindromeObstruction where
  witnessMod   : ℕ
  witnessResid : Fin witnessMod
  excludes     : ∀ n, n % witnessMod = witnessResid.val → ¬ IsPalindromeNat n
```

Even if the final obstruction notion must be weakened, **you must define a new concept** that captures “why a state cannot yet be palindromic.”

---

## Exact Theorem Ambitions

You must prove at least 3 nontrivial theorems. The strongest possible theorem “196 never yields a palindrome” is likely beyond present formal reach unless you discover a true invariant; however, the project is only worthwhile if you establish **structural theorems that make such a proof plausible**.

Here are the target theorems.

### Theorem A: Arithmetic–digit compatibility of reverse-and-add
Formalize that digit reversal and arithmetic reverse agree in the normalized base-10 expansion.

```lean
theorem reverseNat_spec (n : ℕ) :
  reverseNat n = Nat.ofDigits 10 (Nat.digits 10 n).reverse
```

This theorem itself may be definitional, so it is not one of the required deep theorems unless you strengthen it. A deeper form is:

```lean
theorem revAdd_digits_control
    (n : ℕ) :
    ∃ C : CarryProfile,
      -- the base-10 digits of revAdd n are determined by pairwise digit sums of digits10 n
      True
```

You should replace `True` by an actual formal relation between output digits, reversed input digits, and carries.

**Why it matters:** this is the bridge from integer dynamics to symbolic dynamics.

---

### Theorem B: Palindrome criterion via symmetry defect
Define a symmetry defect on digit lists and prove it characterizes palindromes.

```lean
theorem symmetryDefect_eq_zero_iff_palindrome
    (L : List ℕ) :
    symmetryDefect L = 0 ↔ L = L.reverse
```

Then transport this to naturals:

```lean
theorem symmetryDefect_digits_eq_zero_iff
    (n : ℕ) :
    symmetryDefect (digits10 n) = 0 ↔ IsPalindromeNat n
```

This is a deep theorem if your `symmetryDefect` is defined numerically and the proof requires induction/list decomposition rather than trivial rewriting.

**Why it matters:** it turns palindrome detection into a quantitative Lyapunov-style observable.

---

### Theorem C: Reverse-and-add weak monotonic growth and nontrivial lower bounds
A theorem of the following flavor should be proved:

```lean
theorem self_le_revAdd (n : ℕ) : n ≤ revAdd n
```

This alone is too easy, so strengthen it. For non-palindromic numbers with no trailing zero pathology, prove strict growth or a quantified lower bound:

```lean
theorem strict_growth_of_nonpalindrome
    (n : ℕ)
    (hnp : ¬ IsPalindromeNat n)
    (h0 : n % 10 ≠ 0) :
    n < revAdd n
```

Or a digit-length growth criterion:

```lean
theorem length_growth_under_leading_carry
    (n : ℕ)
    (hcarry : -- suitable carry condition)
    : (digits10 n).length < (digits10 (revAdd n)).length
```

**Why it matters:** monotone growth plus symmetry obstruction is the beginning of a non-termination framework.

---

### Theorem D: Congruence obstruction theorem
This is where you should be bold. Establish a modular obstruction linking digit symmetry to number-theoretic residues.

A plausible theorem:

```lean
theorem palindrome_mod11_of_even_length
    (n : ℕ)
    (hpal : IsPalindromeNat n)
    (hlen : Even (digits10 n).length) :
    n % 11 = 0
```

Then use reverse-and-add dynamics to derive constraints on even-length palindrome hits:

```lean
theorem even_length_palindrome_hit_implies_mod11
    (k : ℕ) :
    Even (digits10 (revAddIter k 196)).length →
    revAddIter k 196 % 11 = 0
```

This does not prove non-termination, but it gives a **certified sieve**.

**Why it matters:** this is the key cross-domain bridge between digit combinatorics and modular arithmetic.

---

### Theorem E: Automata-style state evolution on digit signatures
Define a reduced signature of a number, e.g. length, endpoint digits, parity of center carry, mod 9, mod 11, symmetry defect parity. Prove the reverse-and-add map induces a deterministic transition on these signatures.

```lean
structure DigitSignature where
  len        : ℕ
  mod9       : Fin 9
  mod11      : Fin 11
  firstDigit : ℕ
  lastDigit  : ℕ
  defectParity : Bool

def signature (n : ℕ) : DigitSignature := ...

theorem signature_transition_deterministic
    (n : ℕ) :
    ∃ s', signature (revAdd n) = s'
```

This is tautological as stated, so strengthen it into a theorem that the next signature is constrained by the current one and carry conditions. For example, prove a theorem describing `mod 9` evolution:

```lean
theorem revAdd_mod9
    (n : ℕ) :
    revAdd n % 9 = (2 * n) % 9
```

and combine it with a digit theorem for richer signatures.

**Why it matters:** this reframes the problem as finite-state symbolic dynamics with arithmetic labels.

---

## Bold Main Conjecture

You should state a falsifiable conjecture, and it must have a clear computational disproof criterion.

### Conjecture
```lean
conjecture lychrel_196 :
  IsLychrelCandidate 196
```

This is mathematically famous but too raw. State a more structured conjecture as well:

```lean
conjecture eventual_positive_symmetry_defect_196 :
  ∀ k : ℕ, 0 < symmetryDefect (digits10 (revAddIter k 196))
```

or stronger:

```lean
conjecture modular_carry_obstruction_196 :
  ∀ k : ℕ,
    -- a specific signature obstruction excluding palindromes
    ¬ PalindromeCompatible (signature (revAddIter k 196))
```

### Clear computational test
A disproof consists of producing:
- some `k` such that `IsPalindromeNat (revAddIter k 196)`, or
- some `k` such that your proposed obstruction predicate fails.

This must be documented in `FUTURE_DIRECTIONS.md` as an explicit falsifiable experiment.

---

## Proof Strategy Architecture

You must pursue multiple proof paths, not a single line of attack.

### Strategy 1: Digit-list induction with carry decomposition
Most promising for the core structural theorems.

1. Prove lemmas about `Nat.digits 10` / `Nat.ofDigits 10` interaction, especially normalization and behavior under reversal.
2. Introduce pairwise digit-sum plus carry recurrences for reverse-and-add.
3. Use induction on digit-list length or mirrored decomposition
   \[
   L = a :: M ++ [b]
   \]
   to prove palindrome criteria and symmetry-defect theorems.
4. Derive carry constraints that force nonzero defect in broad families of states.

**Why promising:** it attacks the true structure of the problem instead of merely computing iterates.

---

### Strategy 2: Congruence-dynamical sieve
Best for cross-domain theorems and partial non-termination certificates.

1. Prove modular evolution laws such as
   \[
   T(n) \equiv 2n \pmod 9,
   \quad
   T(n) \equiv n + \operatorname{rev}(n) \pmod{11}.
   \]
2. Prove necessary modular conditions for palindromes, especially even-length palindromes mod 11.
3. Combine these to obtain “if a palindrome occurs at step `k`, then the iterate lies in a sharply constrained residue class.”
4. Use these to define a `PalindromeObstruction` certificate.

**Why promising:** modular arithmetic is highly formalizable in Lean and yields genuine scientific structure, even if it does not settle the full 196 problem.

---

### Strategy 3: Symbolic dynamics / automata abstraction
Most visionary; may produce the strongest new concept.

1. Define a finite or finitely parameterized signature capturing enough carry information to predict whether palindrome formation is possible.
2. Prove that reverse-and-add induces a transition relation on signatures.
3. Search for an invariant forbidden region containing the orbit of `196`.
4. If successful, this becomes a bona fide non-termination certificate.

**Why promising:** this is the route to a paradigm shift—transforming the 196 problem into an automata-invariant theorem.

---

## Catalog Building Blocks and How to Use Them

The injected catalog is not directly about digit dynamics, so your task is to **extract reusable proof patterns**, especially around additive normalization and compatibility.

1. `flattenAdd_normalize_aci_add`  
   **Use:** as conceptual precedent for proving that a complicated additive construction has a canonical normalized form. Your digit/carry formalism should similarly normalize reverse-and-add into a canonical digit-state update. This is not a direct import, but a methodological model for an “addition followed by normalization” theorem.

2. `add_left`  
   **Use:** if you introduce congruence relations or equivalence classes on digit states/signatures, this theorem suggests how additive compatibility should be packaged. A custom congruence on signatures under additive updates could mirror this pattern.

3. `natLE_add_left`  
   **Use:** directly relevant for lower-bound theorems like `n ≤ revAdd n`; strengthen beyond the immediate additive monotonicity into strict-growth statements using positivity of `reverseNat n`.

4. `encode_add`  
   **Use:** as precedent for proving compatibility of an encoding with addition. Your `signature` or `DigitState` encoding should satisfy analogous “addition-aware” laws, especially for modular components.

5. `cycleCost_add_const`, `observerKernel_add_compatible`, `walk_produces_consistent_amplitude_data`  
   **Use:** these are bridges showing that additive dynamics can preserve or transform higher-level observables. Treat them as design inspiration for proving that reverse-and-add updates structured observables like defect, carry parity, or modular signature.

Do not cite these superficially. Explicitly explain in comments or paper text how the proof architecture echoes “normalize-after-addition” and “observable compatibility under additive evolution.”

---

## Cross-Domain Connections You Must Include

At least one theorem must connect reverse-and-add dynamics to another mathematical domain.

### Recommended bridge 1: Number theory + automata theory
Interpret the digit evolution as a finite-state transducer with carry memory. Prove that some signature component evolves deterministically. This turns a recreational number problem into a theorem about symbolic dynamics.

### Recommended bridge 2: Number theory + dynamical systems
Treat `symmetryDefect` as a discrete energy / Lyapunov-like observable. Even if it is not monotone, proving quantitative recurrence constraints is a genuine dynamical-systems statement.

### Recommended bridge 3: Number theory + information/computation
Define a complexity measure such as digit length plus carry entropy proxy, and prove reverse-and-add cannot remain in a bounded state class unless a palindrome appears. This connects Lychrel dynamics to termination certificates in computation theory.

---

## Application Keywords

Use these in the paper and article:

- Lychrel numbers
- reverse-and-add dynamics
- palindrome obstruction
- carry propagation
- digit automata
- symbolic dynamics
- modular sieve
- finite-state transducer
- discrete dynamical systems
- arithmetic invariants
- non-termination certificates
- computational number theory
- formal verification
- Lean 4
- Mathlib

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with:
   - at least 3 nontrivial theorems,
   - at least one novel definition,
   - no trivialization by brute-force enumeration,
   - minimized `sorry`.

2. **`FUTURE_DIRECTIONS.md`** containing 3–5 falsifiable scientific hypotheses, each with:
   - a precise conjecture,
   - what data/computation would test it,
   - what outcome would refute it.

3. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - define reverse-and-add and Lychrel candidates,
   - explain the new obstruction framework,
   - state and interpret the formal theorems,
   - discuss what remains open about `196`,
   - include a section on how the formalization changes the research landscape.

4. **`ARTICLE.md`** in Scientific American style:
   - explain the 196 problem accessibly,
   - describe how formal mathematics attacks a notorious mystery,
   - emphasize carry patterns, symmetry, and dynamical obstruction.

5. **A verified algorithm / computational method**
   - implement a certified checker for your obstruction predicate, symmetry defect, or signature evolution;
   - prove correctness of the checker relative to the mathematical definition.

6. **`demo.py`**
   - interactive exploration of reverse-and-add orbits,
   - display digit strings, reversals, carries, symmetry defect, and modular signature,
   - allow testing of the conjectures and obstruction predicates on arbitrary seeds.

---

## Hard Constraints

### Depth requirements
Your output must satisfy all of these:

1. **NO trivial proofs**  
   Do not rely on `native_decide`, `decide`, `norm_num`, or `rfl` unless the theorem itself is genuinely substantial.

2. **At least 3 theorems with deep proof tactics**  
   Use induction, `rcases`, `by_contra`, `field_simp` where relevant, or substantial `calc` chains.

3. **Novel definitions**  
   Introduce at least one new concept such as `symmetryDefect`, `CarryProfile`, `DigitSignature`, or `PalindromeObstruction`.

4. **Cross-domain connection theorem**  
   At least one theorem must explicitly connect digit dynamics to modular arithmetic, automata, or dynamical systems.

5. **Conjecture with testable prediction**  
   Include at least one falsifiable conjecture with a clear computational disproof criterion.

---

## Concrete Theorem List to Aim For

A strong submission would include formal versions of at least 3 of the following:

```lean
theorem symmetryDefect_eq_zero_iff_palindrome
    (L : List ℕ) :
    symmetryDefect L = 0 ↔ L = L.reverse

theorem symmetryDefect_digits_eq_zero_iff
    (n : ℕ) :
    symmetryDefect (digits10 n) = 0 ↔ IsPalindromeNat n

theorem strict_growth_of_nonpalindrome
    (n : ℕ)
    (hnp : ¬ IsPalindromeNat n)
    (h0 : n % 10 ≠ 0) :
    n < revAdd n

theorem palindrome_mod11_of_even_length
    (n : ℕ)
    (hpal : IsPalindromeNat n)
    (hlen : Even (digits10 n).length) :
    n % 11 = 0

theorem revAdd_mod9
    (n : ℕ) :
    revAdd n % 9 = (2 * n) % 9

theorem revAddIter_monotone_left
    (k : ℕ) (n : ℕ) :
    n ≤ revAddIter k n
```

If you can prove a true obstruction theorem specifically for `196`, that is exceptional. For example:

```lean
theorem obstruction_196_step
    (k : ℕ) :
    ObstructedSignature (signature (revAddIter k 196))
```

But do not fake depth. A robust framework plus several serious structural theorems is more valuable than an ungrounded claim of full non-termination.

---

## Final Scientific Goal

Do not treat this as a recreational exercise. Treat it as the foundation of a new formal theory:

> **Reverse-and-add dynamics can be studied via certified digit-state invariants, carry profiles, and modular obstruction signatures; the `196` problem is then recast as a theorem about invariant forbidden regions in arithmetic symbolic dynamics.**

That reframing is the real breakthrough.

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
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
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
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Speculative
Research mode: prove
