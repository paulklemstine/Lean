## Assignment: Beal's Conjecture via Formal Obstruction Theorems, Not Empty Grandiosity

**Mode:** `prove` + `formalize` +, if needed, `counterexample` to overstrong intermediate claims.

You should **not** pretend to solve Beal’s Conjecture outright unless you can genuinely do so. Instead, produce **new, non-trivial formal obstruction theorems** that carve out mathematically meaningful territory around Beal, and formalize precise bridges to **Fermat–Catalan**, **abc-style inequalities**, and **coprime exponential Diophantine equations**. The right target is a theorem package that would make future resolution of Beal modular and machine-checkable.

The breakthrough goal is to turn Beal from a single unreachable sentence into a **network of formally verified reduction principles**:
1. reductions from Beal to primitive/coprime cases,
2. impossibility theorems in key exponent regimes,
3. formal implications from explicit abc/Fermat–Catalan hypotheses,
4. valuation- and gcd-based structural lemmas strong enough to support later attacks.

If the full conjecture remains inaccessible, then the correct revolutionary move is to prove the strongest **certified conditional and partial results** in Lean 4, with clean interfaces.

---

## Core Mathematical Target

### Primary theorem family
Let
\[
A^x + B^y = C^z,\qquad A,B,C,x,y,z \in \mathbb N,\quad A,B,C>0,\quad x,y,z>2.
\]
Beal predicts:
\[
\exists p,\; p \text{ prime} \land p \mid A \land p \mid B \land p \mid C.
\]

A direct proof is likely out of reach. So target the following precise theorems.

---

## Theorem 1: Primitive reduction equivalence

Prove that any counterexample to Beal yields a **pairwise coprime primitive counterexample**.

### Precise statement
If there exist positive integers \(A,B,C,x,y,z\) with \(x,y,z>2\) such that
\[
A^x + B^y = C^z
\]
and \(A,B,C\) do **not** share a common prime factor, then there exist positive integers
\[
A',B',C',x,y,z
\]
with the same exponents, satisfying
\[
(A')^x + (B')^y = (C')^z,
\]
such that
\[
\gcd(A',B')=\gcd(B',C')=\gcd(A',C')=1.
\]

This is not Beal itself, but it is a decisive formal reduction: it isolates the true primitive obstruction.

### Lean 4 target signature
```lean
theorem beal_counterexample_has_pairwise_coprime_model
  {A B C x y z : ℕ}
  (hA : 0 < A) (hB : 0 < B) (hC : 0 < C)
  (hx : 2 < x) (hy : 2 < y) (hz : 2 < z)
  (hEq : A ^ x + B ^ y = C ^ z)
  (hNoCommon :
    ¬ ∃ p : ℕ, Nat.Prime p ∧ p ∣ A ∧ p ∣ B ∧ p ∣ C) :
  ∃ A' B' C' : ℕ,
    0 < A' ∧ 0 < B' ∧ 0 < C' ∧
    A' ^ x + B' ^ y = C' ^ z ∧
    Nat.Coprime A' B' ∧ Nat.Coprime A' C' ∧ Nat.Coprime B' C' := by
  sorry
```

### Why this matters
This theorem converts Beal into a primitive generalized Fermat problem. Once formalized, every future attack can assume pairwise coprimality without reproving the descent/gcd cleanup. This is exactly the kind of infrastructure theorem that opens a field of machine-verified exponential Diophantine reduction.

---

## Theorem 2: Pairwise coprime solutions force radical growth bounds

For primitive solutions, prove a sharp divisibility/radical inequality that exposes the abc/Fermat–Catalan structure.

Define the radical
\[
\operatorname{rad}(n)=\prod_{p\mid n} p.
\]

### Precise theorem
For pairwise coprime positive integers \(A,B,C\) with
\[
A^x+B^y=C^z,\qquad x,y,z\ge 3,
\]
one has
\[
\operatorname{rad}(A^xB^yC^z)=\operatorname{rad}(ABC),
\]
and hence
\[
\operatorname{rad}(ABC) < C
\]
whenever \(A,B<C\), making the equation structurally resemble an abc-exceptional triple.

The theorem should be formalized in a way that cleanly supports a later conditional implication from abc.

### Lean 4 target signature
A full `rad` API may need to be defined if absent in your local environment. Target something like:

```lean
def Nat.radical (n : ℕ) : ℕ := sorry

theorem radical_pow (n k : ℕ) (hk : 0 < k) :
  Nat.radical (n ^ k) = Nat.radical n := by
  sorry

theorem radical_mul_of_coprime
  {a b : ℕ} (h : Nat.Coprime a b) :
  Nat.radical (a * b) = Nat.radical a * Nat.radical b := by
  sorry

theorem beal_primitive_radical_identity
  {A B C x y z : ℕ}
  (hAB : Nat.Coprime A B) (hAC : Nat.Coprime A C) (hBC : Nat.Coprime B C)
  (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) :
  Nat.radical (A ^ x * B ^ y * C ^ z) = Nat.radical A * Nat.radical B * Nat.radical C := by
  sorry
```

You may also prove a bundled version:
```lean
theorem beal_primitive_radical_eq_rad_ABC
  {A B C x y z : ℕ}
  (hAB : Nat.Coprime A B) (hAC : Nat.Coprime A C) (hBC : Nat.Coprime B C)
  (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) :
  Nat.radical (A ^ x * B ^ y * C ^ z) = Nat.radical (A * B * C) := by
  sorry
```

### Why this matters
This is the exact formal gateway from Beal to abc/Fermat–Catalan. The equation is not just “like” an abc triple; the radical is rigid under powers, and pairwise coprimality makes the triple arithmetically sparse. This opens formal interaction with height inequalities, effective Diophantine approximation, and arithmetic geometry.

---

## Theorem 3: Conditional Beal from an explicit abc-style hypothesis

Do not merely “mention abc.” Formalize a precise implication.

### Explicit conditional theorem
Assume the following abc-style schema:

> For every pairwise coprime positive integers \(a,b,c\) with \(a+b=c\), if
> \[
> c > \operatorname{rad}(abc)^{1+\varepsilon},
> \]
> then no such triple exists, for some explicit \(\varepsilon > 0\).

Under a sufficiently strong explicit choice, prove that primitive Beal solutions cannot exist for exponents satisfying
\[
\frac1x+\frac1y+\frac1z < 1-\delta
\]
for an appropriate \(\delta>0\) derived from the abc exponent.

This is a formal bridge theorem: “abc hypothesis ⇒ no primitive Beal solutions in a specified exponent cone.”

### Lean 4 target signature
A clean abstraction is preferable:

```lean
def ABCStatement (ε : ℝ) : Prop :=
  ∀ a b c : ℕ,
    0 < a → 0 < b → 0 < c →
    Nat.Coprime a b →
    a + b = c →
    ¬ ((c : ℝ) > (Nat.radical (a * b * c) : ℝ) ^ (1 + ε))

theorem abc_implies_no_primitive_beal
  (ε : ℝ) (hε : 0 < ε)
  (hABC : ABCStatement ε) :
  ∀ {A B C x y z : ℕ},
    0 < A → 0 < B → 0 < C →
    2 < x → 2 < y → 2 < z →
    Nat.Coprime A B → Nat.Coprime A C → Nat.Coprime B C →
    A ^ x + B ^ y = C ^ z →
    -- add explicit exponent-growth hypothesis here
    False := by
  sorry
```

You may need a more realistic hypothesis than the exact exponent cone above, e.g. a sufficient numerical growth condition implying
\[
C^z > \operatorname{rad}(ABC)^{1+\varepsilon}.
\]

### Why this is revolutionary
This turns a famous open problem into a **formal dependency graph**: if abc is instantiated at strength \(1+\varepsilon\), then entire sectors of Beal vanish automatically. That is exactly how theorem-proving systems should organize frontier mathematics.

---

## Theorem 4: Exponent-specialized impossibility results

A major opportunity is to prove genuinely unconditional special cases in Lean.

### Candidate target
Prove that there are no pairwise coprime solutions to
\[
A^3 + B^3 = C^z,\qquad z>2,
\]
under additional structural assumptions you can formalize and discharge, for example:
- parity restrictions,
- squarefreeness of one base,
- valuation constraints at 2 or 3,
- modular obstructions modulo \(7, 9, 13\), etc.

Or prove impossibility for a concrete infinite family:
\[
A^{2k+1}+B^{2k+1}=C^z
\]
when \(A,B\) satisfy a specific congruence class pattern.

### Lean 4 target signature example
```lean
theorem no_pairwise_coprime_solution_cube_cube_eq_even_power
  {A B C t : ℕ}
  (hA : 0 < A) (hB : 0 < B) (hC : 0 < C)
  (hAB : Nat.Coprime A B) (hAC : Nat.Coprime A C) (hBC : Nat.Coprime B C)
  (ht : 1 < t)
  (hEq : A ^ 3 + B ^ 3 = C ^ (2 * t)) :
  False := by
  sorry
```

If that exact statement is too strong, weaken it to a provable modular obstruction theorem, e.g. with hypotheses
`A % 3 ≠ 0`, `B % 3 ≠ 0`, `C % 3 ≠ 0`, or parity assumptions. A good theorem here is better than an impossible theorem with many sorries.

### Why this matters
Special-case impossibility theorems are not consolation prizes. They are the empirical geometry of the conjecture. They reveal which local obstructions dominate, and they seed future automated searches for complete coverings by congruence classes.

---

## Proof Strategy Architecture

### Strategy A: gcd extraction + primitive descent
**Most promising for immediate formal success.**

1. Let \(g = \gcd(A,B,C)\), or more subtly use pairwise gcds.
2. Factor common prime powers using `Nat.factorization`, valuations, or divisibility lemmas.
3. Construct a primitive model by dividing out maximal shared prime powers and proving the equation survives.
4. Use coprimality lemmas to show any true obstruction lives in the primitive case.

**Why promising:** Mathlib is strongest on gcd/divisibility/Nat.Prime structure. This yields a substantial theorem package even without deep arithmetic geometry.

---

### Strategy B: radical/valuation formalization leading to abc bridge
1. Define or recover `Nat.radical`.
2. Prove `radical_pow` and multiplicativity on coprime products.
3. For primitive Beal solutions, rewrite the equation as an abc triple:
   \[
   a=A^x,\quad b=B^y,\quad c=C^z.
   \]
4. Show
   \[
   \operatorname{rad}(abc)=\operatorname{rad}(ABC),
   \]
   while the size of \(c\) grows much faster than the radical when exponents are large.
5. Deduce conditional nonexistence from an explicit abc hypothesis.

**Why promising:** This creates a formal theorem interface of lasting value. Even if conditional, it is mathematically deep and reusable.

---

### Strategy C: local obstruction engine via congruences and valuations
1. Analyze \(A^x+B^y=C^z\) modulo small primes \(p\in\{2,3,5,7,9,13\}\).
2. Enumerate power residues for exponents \(>2\) in these moduli.
3. Build finite exclusion lemmas for families of congruence classes.
4. Combine with coprimality to derive contradictions in infinite subfamilies.

**Why promising:** This can produce unconditional new theorems quickly, and it cross-pollinates with computational number theory and SAT-style residue covering arguments.

---

## How to Build on the Catalog Theorems

Even if these theorems were developed in other contexts, use them as structural tools.

1. `smaller_factor_sqrt_bound`  
   Use it in any factor-splitting or descent argument where a nontrivial factorization of an auxiliary integer arises. In particular, if you derive
   \[
   C^z - A^x = B^y
   \]
   and factor the left-hand side in a special exponent case, this theorem can help control the size of nontrivial factors and support a minimal-counterexample contradiction.

2. `peel_factor_bound`  
   This suggests a certified way to “peel off” bounded divisors. Use it to formalize repeated extraction of common factors or prime powers in gcd descent.

3. `reduction_terminates_with_height_bound`  
   This is especially interesting conceptually: import the **height-bounded termination** viewpoint into arithmetic descent. If you define a measure like
   \[
   H(A,B,C)=A+B+C
   \]
   or a weighted logarithmic height, you may be able to formalize “if a non-primitive solution exists, repeated gcd reduction terminates at a primitive one.” This is exactly the kind of cross-domain reuse that can create a new proof architecture.

4. `prime_congruence_separation_conjecture`  
   Even if speculative, mine it for congruence-separation ideas: primitive Beal candidates should force simultaneous residue conditions at several primes. This may help automate modular exclusion.

5. `krull_height_theorem_security_prime`  
   The cross-domain idea here is not cryptographic fluff; it is the analogy between **height** in commutative algebra and **arithmetic complexity** of exponential Diophantine solutions. If the theorem exposes a certified “prime witness” mechanism, adapt that pattern to witness common-prime obstructions or valuation concentration.

---

## Cross-Domain Connections You Must Exploit

### 1. Arithmetic geometry / generalized Fermat
Beal is a generalized Fermat equation. Primitive solutions correspond to rational/integral points on high-genus curves or higher-dimensional moduli spaces. Even if you do not formalize Faltings, explicitly structure your Lean development so that future arithmetic-geometry theorems can plug in.

### 2. abc and height theory
The equation is fundamentally a tension between **height growth** and **radical sparsity**. Make this explicit. Formalize “size versus support of prime divisors” as a reusable concept.

### 3. Computational number theory
Build residue obstruction lemmas that can later be paired with brute-force search or certified finite covering arguments. This invites a `demo.py` or generated congruence tables, even if optional.

### 4. Proof theory / automated theorem proving
Beal is an ideal testbed for a hybrid architecture:
- symbolic gcd descent,
- local modular contradiction search,
- conditional high-level implication from abstract hypotheses.
This is not just one theorem; it is a blueprint for formal frontier Diophantine reasoning.

### 5. Complexity and cryptography
Primitive exponential Diophantine equations encode sparse prime-support phenomena. There is a plausible bridge to hardness assumptions about extracting hidden common prime structure from power-sum identities. Even a clean formal API here could seed later work in arithmetic cryptography.

---

## Concrete Lean 4 Development Plan

### Phase I: Foundational arithmetic API
Prove and package:
- gcd divisibility lemmas for powers,
- coprimality transfer through powers,
- pairwise coprime factorization lemmas,
- `Nat.radical` and its basic properties,
- valuation lemmas if feasible (`padicValNat` or factorization-based).

### Phase II: Primitive reduction theorem
Formalize `beal_counterexample_has_pairwise_coprime_model`.

### Phase III: abc/Fermat–Catalan bridge
Formalize:
- primitive radical identity,
- an abstract `ABCStatement`,
- conditional impossibility theorem.

### Phase IV: Unconditional special cases
Target one or two actual impossible families with complete proofs and minimal sorry.

---

## Precision about Fermat–Catalan Connection

You must make explicit the relation:
- Beal primitive solutions are instances of the generalized Fermat equation
  \[
  X^p+Y^q=Z^r,\qquad \gcd(X,Y,Z)=1.
  \]
- Fermat–Catalan predicts finiteness when
  \[
  \frac1p+\frac1q+\frac1r<1.
  \]
- Since Beal assumes \(p,q,r>2\), one always has
  \[
  \frac1p+\frac1q+\frac1r \le 1,
  \]
  with equality only at \((3,3,3)\).
Thus Beal sits at the exact threshold between the classical cubic case and the hyperbolic finite regime. This is a profound conceptual point: formalizing it clarifies why abc/Fermat–Catalan technology is naturally adjacent.

A useful Lean theorem here is:

```lean
theorem beal_exponents_reciprocal_bound
  {x y z : ℕ} (hx : 2 < x) (hy : 2 < y) (hz : 2 < z) :
  (1 : ℚ) / x + (1 : ℚ) / y + (1 : ℚ) / z ≤ 1 := by
  sorry
```

and ideally:
```lean
theorem reciprocal_sum_eq_one_iff_three_three_three
  {x y z : ℕ} (hx : 2 < x) (hy : 2 < y) (hz : 2 < z) :
  ((1 : ℚ) / x + (1 : ℚ) / y + (1 : ℚ) / z = 1) ↔ x = 3 ∧ y = 3 ∧ z = 3 := by
  sorry
```

This is elementary but conceptually powerful: it formally positions Beal inside Fermat–Catalan geometry.

---

## Application Keywords
Beal conjecture, generalized Fermat equation, Fermat–Catalan, abc conjecture, radical of an integer, pairwise coprime reduction, valuations, local obstructions, modular arithmetic, arithmetic geometry, Diophantine height, formalized number theory, Lean 4, Mathlib, proof automation, computational congruence covering, prime support sparsity.

---

## Deliverables

1. **Lean 4 files** proving as many of the theorem targets above as possible.
2. Minimize `sorry`; if a theorem is too strong, weaken it to the strongest true formal statement you can finish.
3. Include comments explaining where Mathlib lemmas are reused and where catalog theorems enter.
4. If you discover an overstrong target is false, switch modes and provide a **counterexample theorem** or explicit computation.
5. Produce `FUTURE_DIRECTIONS.md` with **3–5 falsifiable hypotheses**, each with:
   - a precise conjecture,
   - a clear computational or formal test,
   - what evidence would refute it.

---

## Required FUTURE_DIRECTIONS.md hypotheses

Include hypotheses of this form, but sharpen them if your proofs suggest better versions:

### Direction 1: Residue-class covering for primitive Beal triples
**Hypothesis:** There exists a finite set of moduli \(M\) such that every pairwise coprime primitive solution to \(A^x+B^y=C^z\) with \(x,y,z>2\) violates at least one power-residue constraint modulo some \(m\in M\).  
**Test:** Compute power residue tables for moduli up to a fixed bound and search for a covering certificate.  
**Refutation:** Find a primitive residue pattern surviving all tested moduli.

### Direction 2: Quantitative abc threshold sufficient for Beal
**Hypothesis:** There exists an explicit \(\varepsilon_0>0\) such that `ABCStatement ε₀` formally implies absence of primitive Beal solutions for all \(x,y,z>2\).  
**Test:** Derive the exact inequality chain in Lean from \(A^x+B^y=C^z\) to \(C^z > \operatorname{rad}(ABC)^{1+\varepsilon_0}\).  
**Refutation:** Show the inequality cannot be made uniform for any positive \(\varepsilon_0\).

### Direction 3: Descent by common-prime extraction is height-complete
**Hypothesis:** Every non-primitive generalized Fermat solution admits a terminating canonical reduction to a pairwise coprime primitive solution under a height measure formalizable in Lean.  
**Test:** Define the reduction relation and prove well-foundedness by a strict height decrease.  
**Refutation:** Exhibit a reduction ambiguity or non-decreasing branch.

### Direction 4: Valuation rigidity at small primes
**Hypothesis:** For primitive Beal candidates, the \(2\)-adic and \(3\)-adic valuations of \(A^x,B^y,C^z\) satisfy a finite list of rigid patterns that exclude all but finitely many congruence classes.  
**Test:** Formalize LTE-style or modular valuation lemmas and enumerate surviving patterns.  
**Refutation:** Produce infinitely many compatible valuation patterns.

### Direction 5: The \((3,3,3)\) boundary controls all primitive cases
**Hypothesis:** Any primitive Beal counterexample would admit a reduction to a structurally analogous obstruction in the cubic boundary case \(A^3+B^3=C^3\) or \(C^z\).  
**Test:** Seek exponent-lowering or factorization-based reductions in odd-exponent families.  
**Refutation:** Prove a family of primitive high-exponent configurations with no cubic shadow.

Go build the formal obstruction theory that Beal has always needed.

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
